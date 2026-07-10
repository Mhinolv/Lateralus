import Foundation
import Testing
@testable import Lateralus

@MainActor
struct VoiceNoteRecorderTests {
    @Test func aSecondTapCancelsPermissionStartup() async {
        var factoryCalls = 0
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let recorder = VoiceNoteRecorder(
            dependencies: .init(
                requestPermission: {
                    await Task.yield()
                    return true
                },
                makeRecorder: { _ in
                    factoryCalls += 1
                    return FakeRecordingSession()
                },
                deactivateAudioSession: {}
            ),
            temporaryDirectory: root
        )

        recorder.toggle()
        #expect(recorder.state == .requestingPermission)
        recorder.toggle()
        #expect(recorder.state == .idle)

        await drainTasks()

        #expect(factoryCalls == 0)
        #expect(recorder.fileURL == nil)
    }

    @Test func deniedPermissionIsVisibleAndCreatesNoFile() async {
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let recorder = VoiceNoteRecorder(
            dependencies: .init(
                requestPermission: { false },
                makeRecorder: { _ in FakeRecordingSession() },
                deactivateAudioSession: {}
            ),
            temporaryDirectory: root
        )

        recorder.toggle()
        await drainTasks()

        #expect(recorder.state == .denied)
        #expect(recorder.fileURL == nil)
    }

    @Test func maximumDurationStopsAndPreservesTheTake() async throws {
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let session = FakeRecordingSession()
        var deactivationCount = 0
        let recorder = VoiceNoteRecorder(
            dependencies: .init(
                requestPermission: { true },
                makeRecorder: { url in
                    try Data([1, 2, 3]).write(to: url)
                    return session
                },
                deactivateAudioSession: { deactivationCount += 1 }
            ),
            maximumDuration: 300,
            temporaryDirectory: root
        )

        recorder.toggle()
        await drainTasks()
        #expect(recorder.state == .recording)
        let recordedURL = try #require(recorder.fileURL)

        session.currentTime = 301
        recorder.refreshDuration()

        #expect(recorder.state == .recorded)
        #expect(recorder.duration == 300)
        #expect(recorder.didReachMaximumDuration)
        #expect(session.stopCount == 1)
        #expect(deactivationCount == 1)
        #expect(FileManager.default.fileExists(atPath: recordedURL.path))

        recorder.discard()
        #expect(!FileManager.default.fileExists(atPath: recordedURL.path))
        #expect(recorder.state == .idle)
    }

    @Test func failedRecorderStartRemovesPartialFileAndReference() async throws {
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let session = FakeRecordingSession(recordResult: false)
        let recorder = VoiceNoteRecorder(
            dependencies: .init(
                requestPermission: { true },
                makeRecorder: { url in
                    try Data([9, 9, 9]).write(to: url)
                    return session
                },
                deactivateAudioSession: {}
            ),
            temporaryDirectory: root
        )

        recorder.toggle()
        await drainTasks()

        guard case .failed = recorder.state else {
            Issue.record("Expected a failed recorder state")
            return
        }
        #expect(recorder.fileURL == nil)
        let files = try FileManager.default.contentsOfDirectory(atPath: root.path)
        #expect(files.isEmpty)
    }

    private func temporaryRoot() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    private func drainTasks() async {
        for _ in 0..<4 { await Task.yield() }
    }
}

@MainActor
private final class FakeRecordingSession: AudioRecordingSession {
    var currentTime: TimeInterval = 0
    private let recordResult: Bool
    private(set) var stopCount = 0

    init(recordResult: Bool = true) {
        self.recordResult = recordResult
    }

    func record() -> Bool { recordResult }
    func stop() { stopCount += 1 }
}
