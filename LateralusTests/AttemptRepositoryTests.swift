import Foundation
import SwiftData
import Testing
@testable import Lateralus

@MainActor
struct AttemptRepositoryTests {
    @Test func saveAndDeleteCommitDatabaseAndAttachmentTogether() throws {
        let container = try AppPersistence.makeContainer(inMemoryOnly: true)
        let context = ModelContext(container)
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let attachments = AttachmentStore(directory: root.appendingPathComponent("VoiceNotes"))
        let repository = AttemptRepository(context: context, attachments: attachments)
        let temporaryRecording = try makeTemporaryRecording(in: root)

        let attempt = try repository.save(
            challenge: ChallengeEngine.challenge(type: .fusion, occurrence: 42),
            responseText: "A lighthouse library",
            isDaily: false,
            temporaryVoiceNoteURL: temporaryRecording,
            drawingData: nil
        )

        #expect(!FileManager.default.fileExists(atPath: temporaryRecording.path))
        #expect(attempt.voiceNoteFile != nil)
        #expect(attachments.containsVoiceNote(named: attempt.voiceNoteFile!))
        #expect(try context.fetchCount(FetchDescriptor<Attempt>()) == 1)

        try repository.delete(attempt)

        #expect(try context.fetchCount(FetchDescriptor<Attempt>()) == 0)
        #expect(try attachments.voiceNoteFilenames().isEmpty)
    }

    @Test func failedDatabaseSaveRollsBackCommittedAttachment() throws {
        enum ProbeError: Error { case saveFailed }
        let container = try AppPersistence.makeContainer(inMemoryOnly: true)
        let context = ModelContext(container)
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let attachments = AttachmentStore(directory: root.appendingPathComponent("VoiceNotes"))
        let repository = AttemptRepository(
            context: context,
            attachments: attachments,
            saveChanges: { throw ProbeError.saveFailed }
        )
        let temporaryRecording = try makeTemporaryRecording(in: root)
        var didThrow = false

        do {
            _ = try repository.save(
                challenge: ChallengeEngine.challenge(type: .backstory, occurrence: 7),
                responseText: "This should fail",
                isDaily: false,
                temporaryVoiceNoteURL: temporaryRecording,
                drawingData: nil
            )
        } catch {
            didThrow = true
        }

        #expect(didThrow)
        #expect(FileManager.default.fileExists(atPath: temporaryRecording.path))
        #expect(try attachments.voiceNoteFilenames().isEmpty)
        #expect(try context.fetchCount(FetchDescriptor<Attempt>()) == 0)
    }

    @Test func reconciliationClearsMissingReferencesAndOrphans() throws {
        let container = try AppPersistence.makeContainer(inMemoryOnly: true)
        let context = ModelContext(container)
        let root = temporaryRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let attachments = AttachmentStore(directory: root.appendingPathComponent("VoiceNotes"))
        let repository = AttemptRepository(context: context, attachments: attachments)
        let temporaryRecording = try makeTemporaryRecording(in: root)
        let attempt = try repository.save(
            challenge: ChallengeEngine.challenge(type: .redefine, occurrence: 2),
            responseText: "A new definition",
            isDaily: true,
            temporaryVoiceNoteURL: temporaryRecording,
            drawingData: nil
        )
        let missingFilename = attempt.voiceNoteFile!
        try attachments.removeVoiceNote(named: missingFilename)

        try attachments.prepare()
        let orphanURL = attachments.directory.appendingPathComponent("orphan.m4a")
        try Data([4, 5, 6]).write(to: orphanURL)

        try repository.reconcileAttachments()

        #expect(attempt.voiceNoteFile == nil)
        #expect(!FileManager.default.fileExists(atPath: orphanURL.path))
    }

    @Test func attachmentPathsRejectTraversal() {
        let store = AttachmentStore(directory: temporaryRoot())
        #expect(store.url(forFile: "../../escape.m4a") == nil)
        #expect(store.url(forFile: "note.wav") == nil)
        #expect(store.url(forFile: "valid.m4a") != nil)
    }

    private func temporaryRoot() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    private func makeTemporaryRecording(in root: URL) throws -> URL {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let url = root.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
        try Data([0, 1, 2, 3]).write(to: url)
        return url
    }
}
