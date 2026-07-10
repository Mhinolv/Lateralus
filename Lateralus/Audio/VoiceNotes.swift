import AVFoundation
import Foundation

/// Records voice notes as .m4a files in the app's VoiceNotes directory.
/// Audio is captured and stored on-device only — nothing is transcribed
/// or uploaded.
@Observable
@MainActor
final class VoiceNoteRecorder {

    enum State: Equatable {
        case idle
        case recording
        case denied
        case failed(String)
    }

    private(set) var state: State = .idle
    private(set) var duration: TimeInterval = 0
    /// The finished (or in-progress) recording, if any.
    private(set) var fileURL: URL?

    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    var isRecording: Bool { state == .recording }

    /// Where every saved voice note lives.
    static var notesDirectory: URL {
        let dir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("VoiceNotes", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func url(forFile name: String) -> URL {
        notesDirectory.appendingPathComponent(name)
    }

    func toggle() {
        if isRecording {
            stop()
        } else {
            Task { await start() }
        }
    }

    func start() async {
        guard await AVAudioApplication.requestRecordPermission() else {
            state = .denied
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            // A fresh take replaces any previous unsaved one.
            if let fileURL { try? FileManager.default.removeItem(at: fileURL) }

            let url = Self.notesDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.record()
            self.recorder = recorder
            fileURL = url
            duration = 0
            state = .recording
            timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self, let recorder = self.recorder else { return }
                    self.duration = recorder.currentTime
                }
            }
        } catch {
            state = .failed("Recording couldn't start.")
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        recorder = nil
        if state == .recording { state = .idle }
    }

    /// Stops and deletes the current take.
    func discard() {
        stop()
        if let fileURL { try? FileManager.default.removeItem(at: fileURL) }
        fileURL = nil
        duration = 0
    }
}

/// Plays back a saved voice note.
@Observable
@MainActor
final class VoiceNotePlayer: NSObject, AVAudioPlayerDelegate {

    private(set) var isPlaying = false
    private var player: AVAudioPlayer?

    func toggle(url: URL) {
        if isPlaying {
            stop()
        } else {
            play(url: url)
        }
    }

    func play(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.play()
            self.player = player
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.player = nil
        }
    }
}

/// Formats a duration like 0:07 or 1:32.
func voiceNoteDuration(_ interval: TimeInterval) -> String {
    let seconds = Int(interval.rounded())
    return "\(seconds / 60):" + String(format: "%02d", seconds % 60)
}
