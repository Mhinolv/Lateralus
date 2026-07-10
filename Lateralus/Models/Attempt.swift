import Foundation
import SwiftData

/// One completed challenge, stored locally. This is the only persisted data in the app.
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

    init(challenge: Challenge, responseText: String, isDaily: Bool) {
        self.id = UUID()
        self.date = .now
        self.typeRaw = challenge.type.rawValue
        self.promptPrimary = challenge.primary
        self.promptSecondary = challenge.secondary
        self.promptEmoji = challenge.emoji
        self.responseText = responseText
        self.isDaily = isDaily
    }

    var type: ChallengeType { ChallengeType(rawValue: typeRaw) ?? .alternateUse }

    /// Reconstructs the challenge this attempt answered.
    var challenge: Challenge {
        Challenge(type: type, primary: promptPrimary, secondary: promptSecondary, emoji: promptEmoji)
    }
}
