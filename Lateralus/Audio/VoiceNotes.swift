import AVFoundation
import Foundation

@MainActor
protocol AudioRecordingSession: AnyObject {
    var currentTime: TimeInterval { get }
    func record() -> Bool
    func stop()
}

extension AVAudioRecorder: AudioRecordingSession {}

/// Owns resources whose cleanup must remain safe when an actor-isolated owner
/// is released. Each resource is still mutated only from the main actor.
private final class VoiceNoteCleanup: @unchecked Sendable {
    var timer: Timer?
    var startTask: Task<Void, Never>?
    var interruptionObserver: NSObjectProtocol?

    deinit {
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
        }
        startTask?.cancel()
        timer?.invalidate()
    }
}

/// Records a bounded, temporary voice note. AttemptRepository is responsible
/// for copying a completed take into the committed attachment store.
@Observable
@MainActor
final class VoiceNoteRecorder {
    nonisolated static let defaultMaximumDuration: TimeInterval = 5 * 60

    enum State: Equatable {
        case idle
        case requestingPermission
        case recording
        case recorded
        case denied
        case failed(String)
    }

    struct Dependencies {
        let requestPermission: @MainActor () async -> Bool
        let makeRecorder: @MainActor (URL) throws -> any AudioRecordingSession
        let deactivateAudioSession: @MainActor () -> Void

        static let live = Dependencies(
            requestPermission: {
                await AVAudioApplication.requestRecordPermission()
            },
            makeRecorder: { url in
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try session.setActive(true)

                let settings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVSampleRateKey: 44_100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                ]
                return try AVAudioRecorder(url: url, settings: settings)
            },
            deactivateAudioSession: {
                try? AVAudioSession.sharedInstance().setActive(
                    false,
                    options: [.notifyOthersOnDeactivation]
                )
            }
        )
    }

    private(set) var state: State = .idle
    private(set) var duration: TimeInterval = 0
    private(set) var fileURL: URL?
    private(set) var didReachMaximumDuration = false

    private let dependencies: Dependencies
    private let maximumDuration: TimeInterval
    private let temporaryDirectory: URL
    private let cleanup = VoiceNoteCleanup()
    private var recorder: (any AudioRecordingSession)?

    var isRecording: Bool { state == .recording }
    var isRequestingPermission: Bool { state == .requestingPermission }

    init() {
        self.dependencies = .live
        self.maximumDuration = Self.defaultMaximumDuration
        self.temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("LateralusVoiceNotes", isDirectory: true)
        observeInterruptions()
    }

    init(
        dependencies: Dependencies,
        maximumDuration: TimeInterval = VoiceNoteRecorder.defaultMaximumDuration,
        temporaryDirectory: URL
    ) {
        self.dependencies = dependencies
        self.maximumDuration = maximumDuration
        self.temporaryDirectory = temporaryDirectory
        observeInterruptions()
    }

    func toggle() {
        switch state {
        case .recording:
            stop()
        case .requestingPermission:
            cancelPendingStart()
        case .idle, .recorded, .denied, .failed:
            state = .requestingPermission
            cleanup.startTask = Task { [weak self] in
                await self?.requestPermissionAndStart()
            }
        }
    }

    func stop() {
        if isRequestingPermission {
            cancelPendingStart()
            return
        }

        cleanup.timer?.invalidate()
        cleanup.timer = nil
        recorder?.stop()
        recorder = nil
        dependencies.deactivateAudioSession()

        if state == .recording {
            state = fileURL == nil ? .idle : .recorded
        }
    }

    /// Stops and deletes the current temporary take.
    func discard() {
        cancelPendingStart()
        stop()
        if let fileURL { try? FileManager.default.removeItem(at: fileURL) }
        fileURL = nil
        duration = 0
        didReachMaximumDuration = false
        state = .idle
    }

    /// The repository has copied and committed the take and removed the
    /// temporary file. Clear the stale temporary reference but retain duration
    /// for the just-saved confirmation UI.
    func markCommitted() {
        stop()
        fileURL = nil
        state = .idle
    }

    /// Pulled out of the Timer closure so the duration limit is deterministic
    /// and directly testable.
    func refreshDuration() {
        guard let recorder, state == .recording else { return }
        duration = recorder.currentTime
        if duration >= maximumDuration {
            duration = maximumDuration
            didReachMaximumDuration = true
            stop()
        }
    }

    private func requestPermissionAndStart() async {
        let granted = await dependencies.requestPermission()
        guard !Task.isCancelled, state == .requestingPermission else { return }
        cleanup.startTask = nil

        guard granted else {
            state = .denied
            return
        }

        var pendingURL: URL?
        do {
            try FileManager.default.createDirectory(
                at: temporaryDirectory,
                withIntermediateDirectories: true
            )

            // A new take replaces only the previous uncommitted temporary file.
            if let fileURL { try? FileManager.default.removeItem(at: fileURL) }
            fileURL = nil
            duration = 0
            didReachMaximumDuration = false

            let url = temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("m4a")
            pendingURL = url
            let recorder = try dependencies.makeRecorder(url)
            guard recorder.record() else {
                throw VoiceNoteError.couldNotStart
            }

            self.recorder = recorder
            fileURL = url
            state = .recording
            cleanup.timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refreshDuration() }
            }
        } catch {
            recorder?.stop()
            recorder = nil
            if let url = fileURL ?? pendingURL {
                try? FileManager.default.removeItem(at: url)
            }
            fileURL = nil
            dependencies.deactivateAudioSession()
            state = .failed("Recording couldn’t start.")
        }
    }

    private func cancelPendingStart() {
        cleanup.startTask?.cancel()
        cleanup.startTask = nil
        if state == .requestingPermission { state = .idle }
    }

    private func observeInterruptions() {
        cleanup.interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: typeValue) == .began
            else { return }
            Task { @MainActor [weak self] in self?.stop() }
        }
    }

}

enum VoiceNoteError: LocalizedError {
    case couldNotStart

    var errorDescription: String? { "Recording couldn’t start." }
}

/// Plays back a saved voice note and releases the shared audio session when
/// playback stops or is interrupted.
@Observable
@MainActor
final class VoiceNotePlayer: NSObject, AVAudioPlayerDelegate {
    private(set) var isPlaying = false
    private let cleanup = VoiceNoteCleanup()
    private var player: AVAudioPlayer?
    private var currentURL: URL?

    override init() {
        super.init()
        cleanup.interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
                  AVAudioSession.InterruptionType(rawValue: typeValue) == .began
            else { return }
            Task { @MainActor [weak self] in self?.stop() }
        }
    }

    func toggle(url: URL) {
        if isPlaying, currentURL == url {
            stop()
        } else {
            stop()
            play(url: url)
        }
    }

    func play(url: URL) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            guard player.play() else { throw VoiceNoteError.couldNotStart }
            self.player = player
            currentURL = url
            isPlaying = true
        } catch {
            finishPlayback()
        }
    }

    func stop() {
        player?.stop()
        finishPlayback()
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.finishPlayback() }
    }

    private func finishPlayback() {
        player = nil
        currentURL = nil
        isPlaying = false
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: [.notifyOthersOnDeactivation]
        )
    }

}

/// Formats a duration like 0:07 or 1:32.
func voiceNoteDuration(_ interval: TimeInterval) -> String {
    let seconds = Int(interval.rounded())
    return "\(seconds / 60):" + String(format: "%02d", seconds % 60)
}
