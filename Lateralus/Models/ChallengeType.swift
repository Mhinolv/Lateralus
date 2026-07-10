import SwiftUI

/// Every kind of journal entry: the twelve playable disciplines plus Diary,
/// the promptless free-writing entry. Raw values are stored in the journal,
/// so they must remain stable across releases.
enum ChallengeType: String, CaseIterable, Identifiable, Codable {
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

    var id: String { rawValue }

    /// The playable disciplines: everything the engine generates prompts for.
    /// Diary is journal-only and never appears in the daily rotation or
    /// practice grid.
    static let games: [ChallengeType] = allCases.filter { $0 != .diary }

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
        }
    }

    /// The standing instruction shown above every prompt of this type.
    /// Each is a single sentence carrying every rule the player needs.
    var directive: String {
        switch self {
        case .alternateUse:
            "Invent a genuinely different use for this object, as far from its intended purpose as you can get."
        case .constrainedUse:
            "Invent a new use for this object that satisfies the constraint below."
        case .realityShift:
            "Walk through what breaks, adapts, and becomes possible once this scenario's one rule of reality changes."
        case .fusion:
            "Combine these two into one invention, service, or idea, making the combination essential rather than decorative."
        case .backstory:
            "Invent the most plausible chain of events that ends in this exact scene."
        case .perspectiveFlip:
            "Describe this scenario entirely from the point of view given below."
        case .redefine:
            "Pretend this word never had a meaning, and define it fresh so the new meaning feels inevitable."
        case .neologism:
            "There's no word for this, so coin one that explains itself and sounds like it was always there."
        case .wordLink:
            "Find a single word or idea that quietly ties these two together, and explain the connection you found."
        case .positiveSpin:
            "Take this genuinely terrible idea and reframe it into something surprisingly useful."
        case .invention:
            "Invent a confidently wrong, completely made-up explanation for how this object actually works."
        case .miniMyth:
            "Write a short myth explaining why this everyday inconvenience was placed in the world."
        case .diary:
            "Write freely."
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
        }
    }

    /// Legible content color on top of a solid `tint` fill.
    var onTint: Color {
        switch self {
        case .realityShift, .neologism, .positiveSpin, .invention, .miniMyth, .diary, .constrainedUse:
            Color(hex: 0x10101A)
        case .alternateUse, .fusion, .backstory, .perspectiveFlip, .redefine, .wordLink:
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
