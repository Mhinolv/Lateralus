import SwiftUI

/// Every kind of journal entry: the twelve playable disciplines plus Diary,
/// the promptless free-writing entry. Raw values are stored in the journal,
/// so they must remain stable across releases.
enum ChallengeType: String, CaseIterable, Identifiable, Codable, Sendable {
    case alternateUse = "alternate_use"
    case constrainedUse = "constrained_use"
    case realityShift = "reality_shift"
    case fusion = "fusion"
    case backstory = "backstory"
    case perspectiveFlip = "perspective_flip"
    case redefine = "redefine"
    case neologism = "neologism"
    case wordLink = "word_link"
    case positiveSpin = "positive_spin"
    case invention = "invention"
    case miniMyth = "mini_myth"
    case diary = "diary"
    /// Used when a stored raw value came from a newer app version or is damaged.
    case unknown = "unknown"

    var id: String { rawValue }

    /// The playable disciplines: everything the engine generates prompts for.
    /// Diary is journal-only and never appears in the daily rotation or
    /// practice grid.
    /// Immutable version-1 daily rotation. Never reorder this array in place;
    /// introduce a new schedule version instead.
    nonisolated static let games: [ChallengeType] = [
        .alternateUse,
        .constrainedUse,
        .realityShift,
        .fusion,
        .backstory,
        .perspectiveFlip,
        .redefine,
        .neologism,
        .wordLink,
        .positiveSpin,
        .invention,
        .miniMyth,
    ]

    nonisolated static let journalFilters: [ChallengeType] = games + [.diary]

    var title: String {
        switch self {
        case .alternateUse: "Alternate Uses"
        case .constrainedUse: "Twisted Uses"
        case .realityShift: "Reality Shift"
        case .fusion: "Fusion"
        case .backstory: "Backstory"
        case .perspectiveFlip: "Perspective Flip"
        case .redefine: "Redefine"
        case .neologism: "Coin a Word"
        case .wordLink: "Common Thread"
        case .positiveSpin: "Positive Spin"
        case .invention: "Inventions"
        case .miniMyth: "Mini Mythology"
        case .diary: "Diary"
        case .unknown: "Unknown Challenge"
        }
    }

    var symbol: String {
        switch self {
        case .alternateUse: "arrow.triangle.branch"
        case .constrainedUse: "link.badge.plus"
        case .realityShift: "sparkles"
        case .fusion: "circle.grid.cross"
        case .backstory: "text.magnifyingglass"
        case .perspectiveFlip: "eye"
        case .redefine: "text.quote"
        case .neologism: "textformat.abc"
        case .wordLink: "point.3.connected.trianglepath.dotted"
        case .positiveSpin: "arrow.uturn.up"
        case .invention: "lightbulb"
        case .miniMyth: "scroll"
        case .diary: "book.pages"
        case .unknown: "questionmark.circle"
        }
    }

    /// One-line description shown on practice cards.
    var blurb: String {
        switch self {
        case .alternateUse: "Find a use nobody intended"
        case .constrainedUse: "Reinvent an object under a constraint"
        case .realityShift: "One rule of reality changes. Think it through"
        case .fusion: "Merge two unrelated things into one idea"
        case .backstory: "Explain how a strange scene came to be"
        case .perspectiveFlip: "Retell the ordinary from an alien point of view"
        case .redefine: "Give a familiar word a whole new meaning"
        case .neologism: "Invent the word the dictionary is missing"
        case .wordLink: "Two words, one hidden link. Find it"
        case .positiveSpin: "Turn a terrible idea into a useful one"
        case .invention: "Explain how it \u{201C}really\u{201D} works"
        case .miniMyth: "Write the myth behind a daily annoyance"
        case .diary: "Free writing, no prompt"
        case .unknown: "A saved challenge from another app version"
        }
    }

    /// The standing instruction shown above every prompt of this type.
    /// Each is a single sentence carrying every rule the player needs.
    var directive: String {
        switch self {
        case .alternateUse:
            "Generate a few possible uses for this object, then develop the one furthest from its intended purpose."
        case .constrainedUse:
            "Invent a new use for this object that works because of the constraint below, not in spite of it."
        case .realityShift:
            "Trace the immediate effect, human adaptation, and long-term possibility created by this changed rule."
        case .fusion:
            "Combine these two into one invention, service, or idea, making the combination essential rather than decorative."
        case .backstory:
            "Build a plausible chain of cause and effect that accounts for every strange detail in this scene."
        case .perspectiveFlip:
            "Describe this scenario only through what this observer can sense, want, and misunderstand."
        case .redefine:
            "Give this familiar word a fresh definition, then make the new meaning feel natural in use."
        case .neologism:
            "Coin a pronounceable word for this missing idea and show how someone would naturally use it."
        case .wordLink:
            "Find one word that connects these two, then explain why the connection holds."
        case .positiveSpin:
            "Keep this idea's defining flaw, but find a person or situation that turns the flaw into an advantage."
        case .invention:
            "Invent a confidently wrong mechanism for this object and support it with one convincing piece of fake evidence."
        case .miniMyth:
            "Write a short myth with a supernatural culprit, an original offense, and the inconvenience that became its curse."
        case .diary:
            "Write freely."
        case .unknown:
            "Review your saved response."
        }
    }

    /// Lightweight, game-specific scaffolding. These are suggestions rather
    /// than required fields so a challenge can still be answered quickly.
    var responseGuide: [String] {
        switch self {
        case .alternateUse:
            ["Imagine several uses", "Choose the least obvious", "Show how it would work"]
        case .constrainedUse:
            ["Name the new use", "Use the constraint", "Explain why it works"]
        case .realityShift:
            ["Immediate effect", "How people adapt", "What becomes possible"]
        case .fusion:
            ["What the first contributes", "What the second contributes", "Why both are essential"]
        case .backstory:
            ["The initiating event", "The chain of consequences", "The final strange detail"]
        case .perspectiveFlip:
            ["What it senses", "What it wants", "What it misunderstands"]
        case .redefine:
            ["A fresh definition", "A natural example sentence"]
        case .neologism:
            ["The new word", "How it is pronounced", "A sample sentence"]
        case .wordLink:
            ["One connecting word", "Why it fits both prompts"]
        case .positiveSpin:
            ["Preserve the flaw", "Find who benefits", "Describe the useful result"]
        case .invention:
            ["The secret mechanism", "How it produces the result", "One piece of fake evidence"]
        case .miniMyth:
            ["A supernatural culprit", "The original offense", "The lasting curse"]
        case .diary, .unknown:
            []
        }
    }

    /// An optional second nudge for players who want a harder round.
    var stretchPrompt: String? {
        switch self {
        case .alternateUse: "Could the object work without being physically altered?"
        case .constrainedUse: "Make the constraint the idea's greatest advantage."
        case .realityShift: "What second-order consequence would nobody predict at first?"
        case .fusion: "Remove either half. If the idea still works, fuse them more deeply."
        case .backstory: "Make the least noticeable detail the key to the explanation."
        case .perspectiveFlip: "Let the observer reach a believable but completely wrong conclusion."
        case .redefine: "Use the new meaning in a sentence without explaining it."
        case .neologism: "Make the word's sound hint at its meaning."
        case .wordLink: "Find an indirect connection rather than a shared category."
        case .positiveSpin: "Improve the idea without removing or repairing its central flaw."
        case .invention: "Add a technical-sounding detail that almost makes the explanation credible."
        case .miniMyth: "Make the punishment fit the original offense."
        case .diary, .unknown: nil
        }
    }

    /// Flat identity color: solid fills on game cards and accents elsewhere.
    /// The background aurora also borrows this tint.
    var tint: Color {
        switch self {
        case .alternateUse: Color(hex: 0x4776E6)
        case .constrainedUse: Color(hex: 0xF09819)
        case .realityShift: Color(hex: 0x00F2FE)
        case .fusion: Color(hex: 0x667EEA)
        case .backstory: Color(hex: 0x11998E)
        case .perspectiveFlip: Color(hex: 0xFF0844)
        case .redefine: Color(hex: 0x8E2DE2)
        case .neologism: Color(hex: 0x30CFD0)
        case .wordLink: Color(hex: 0xEC38BC)
        case .positiveSpin: Color(hex: 0x51CF66)
        case .invention: Color(hex: 0xFFD43B)
        case .miniMyth: Color(hex: 0xB197FC)
        case .diary: Color(hex: 0xC2C1FF)
        case .unknown: Color(hex: 0x918FA0)
        }
    }

    /// Legible content color on top of a solid `tint` fill.
    var onTint: Color {
        switch self {
        case .realityShift, .neologism, .positiveSpin, .invention, .miniMyth, .diary, .constrainedUse:
            Color(hex: 0x10101A)
        case .alternateUse, .fusion, .backstory, .perspectiveFlip, .redefine, .wordLink, .unknown:
            .white
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
