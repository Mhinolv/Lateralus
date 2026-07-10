import Foundation
import SwiftData

/// The schema shipped by version 1. Keep this declaration immutable after
/// release; future model changes belong in a new versioned schema.
enum LateralusSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Attempt.self] }

    /// One completed challenge. Voice-note files live in the attachment store;
    /// the database owns only their stable filenames.
    @Model
    final class Attempt {
        var id: UUID = UUID()
        var date: Date = Date()
        var typeRaw: String = ChallengeType.alternateUse.rawValue
        var promptPrimary: String = ""
        var promptSecondary: String?
        var promptEmoji: String = ""
        var responseText: String = ""
        var isFavorite: Bool = false
        var isDaily: Bool = false
        /// Filename of a saved voice note inside the app's VoiceNotes directory.
        var voiceNoteFile: String?
        /// A PencilKit drawing made beneath the answer, if any.
        @Attribute(.externalStorage) var drawingData: Data?

        init(challenge: Challenge, responseText: String, isDaily: Bool, date: Date = .now) {
            self.id = UUID()
            self.date = date
            self.typeRaw = challenge.type.rawValue
            self.promptPrimary = challenge.primary
            self.promptSecondary = challenge.secondary
            self.promptEmoji = challenge.emoji
            self.responseText = responseText
            self.isDaily = isDaily
        }

        /// Unknown future or damaged values remain visible as an explicit
        /// fallback instead of being mislabeled as another discipline.
        var type: ChallengeType { ChallengeType(rawValue: typeRaw) ?? .unknown }

        /// Reconstructs the challenge this attempt answered.
        var challenge: Challenge {
            Challenge(type: type, primary: promptPrimary, secondary: promptSecondary, emoji: promptEmoji)
        }
    }
}

/// The app-facing name stays stable while schema snapshots remain immutable.
typealias Attempt = LateralusSchemaV1.Attempt

enum LateralusMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [LateralusSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
