import Foundation
import SwiftData

/// Coordinates SwiftData and filesystem changes. SwiftData commits are the
/// source of truth; file operations are rolled back or reconciled around them.
@MainActor
struct AttemptRepository {
    let context: ModelContext
    let attachments: AttachmentStore
    private let saveChanges: @MainActor () throws -> Void

    init(context: ModelContext) {
        self.init(context: context, attachments: .live)
    }

    init(context: ModelContext, attachments: AttachmentStore) {
        self.init(
            context: context,
            attachments: attachments,
            saveChanges: { try context.save() }
        )
    }

    init(
        context: ModelContext,
        attachments: AttachmentStore,
        saveChanges: @MainActor @escaping () throws -> Void
    ) {
        self.context = context
        self.attachments = attachments
        self.saveChanges = saveChanges
        context.autosaveEnabled = false
    }

    func save(
        challenge: Challenge,
        responseText: String,
        isDaily: Bool,
        temporaryVoiceNoteURL: URL?,
        drawingData: Data?,
        date: Date = .now
    ) throws -> Attempt {
        let attempt = Attempt(
            challenge: challenge,
            responseText: responseText,
            isDaily: isDaily,
            date: date
        )
        var committedVoiceNote: String?

        do {
            if let temporaryVoiceNoteURL {
                committedVoiceNote = try attachments.commitVoiceNote(
                    from: temporaryVoiceNoteURL,
                    attemptID: attempt.id
                )
            }
            attempt.voiceNoteFile = committedVoiceNote
            attempt.drawingData = drawingData
            context.insert(attempt)
            try saveChanges()

            if let temporaryVoiceNoteURL {
                try? FileManager.default.removeItem(at: temporaryVoiceNoteURL)
            }
            return attempt
        } catch {
            context.rollback()
            if let committedVoiceNote {
                try? attachments.removeVoiceNote(named: committedVoiceNote)
            }
            throw error
        }
    }

    /// Commits the model deletion first. A crash or cleanup error can leave an
    /// orphan file, but never a live Attempt pointing at a deleted file.
    func delete(_ attempt: Attempt) throws {
        let voiceNote = attempt.voiceNoteFile
        context.delete(attempt)
        do {
            try saveChanges()
        } catch {
            context.rollback()
            throw error
        }

        if let voiceNote {
            try? attachments.removeVoiceNote(named: voiceNote)
        }
    }

    func toggleFavorite(_ attempt: Attempt) throws {
        let previous = attempt.isFavorite
        attempt.isFavorite.toggle()
        do {
            try saveChanges()
        } catch {
            context.rollback()
            attempt.isFavorite = previous
            throw error
        }
    }

    /// Clears missing references and removes unreferenced files left by a
    /// process interruption between the filesystem and database commits.
    func reconcileAttachments() throws {
        let attempts = try context.fetch(FetchDescriptor<Attempt>())
        var referenced = Set<String>()
        var changed = false

        for attempt in attempts {
            guard let filename = attempt.voiceNoteFile else { continue }
            if attachments.containsVoiceNote(named: filename) {
                referenced.insert(filename)
            } else {
                attempt.voiceNoteFile = nil
                changed = true
            }
        }

        if changed { try saveChanges() }

        let orphans = try attachments.voiceNoteFilenames().subtracting(referenced)
        for filename in orphans {
            try? attachments.removeVoiceNote(named: filename)
        }
    }
}
