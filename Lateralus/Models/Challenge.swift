import Foundation

/// A single generated prompt. Challenges are derived deterministically from the
/// content library, never stored — only the user's attempts are persisted.
struct Challenge: Identifiable, Hashable {
    let type: ChallengeType
    /// The main subject: an object name, a scenario, or a strange scene.
    let primary: String
    /// The modifier: a constraint, a reality twist, a second concept, or a perspective.
    let secondary: String?
    let emoji: String

    var id: String { "\(type.rawValue)|\(primary)|\(secondary ?? "")" }

    /// Label describing what `secondary` is, for display chips.
    var secondaryLabel: String? {
        switch type {
        case .alternateUse, .backstory, .redefine, .neologism,
             .positiveSpin, .invention, .miniMyth, .diary, .unknown: nil
        case .constrainedUse: "Constraint"
        case .realityShift: "The twist"
        case .fusion: "Merge with"
        case .perspectiveFlip: "Seen by"
        case .wordLink: "And"
        }
    }

    /// A single flattened prompt string, used for the journal.
    var promptSummary: String {
        var text = primary
        if let secondary, let label = secondaryLabel {
            text += " — \(label): \(secondary)"
        }
        return text
    }
}
