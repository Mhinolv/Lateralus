import Foundation

/// A named prompt element with a display emoji.
struct PromptItem: Hashable, Codable {
    let name: String
    let emoji: String
}

/// Namespace for the bundled content pools. The pools themselves live in
/// ContentObjects.swift, ContentScenarios.swift and ContentFusion.swift as extensions.
///
/// Content longevity comes from combinatorics: constrained uses draw from
/// objects × constraints, reality shifts from scenarios × twists, fusions from
/// concept pairs — thousands of unique combinations per type, so the daily
/// challenge cycle runs for years without repeating.
enum ContentLibrary {

    /// Unique daily combinations available for a type before any repeat.
    static func combinationCount(for type: ChallengeType) -> Int {
        switch type {
        case .alternateUse: objects.count
        case .constrainedUse: objects.count * useConstraints.count
        case .realityShift: scenarios.count * realityTwists.count
        case .fusion: concepts.count * (concepts.count - 1)
        case .backstory: backstories.count
        case .perspectiveFlip: scenarios.count * perspectives.count
        case .redefine: words.count
        case .neologism: definitions.count
        case .wordLink: linkWords.count * (linkWords.count - 1)
        case .positiveSpin: terribleIdeas.count
        case .invention: objects.count
        case .miniMyth: inconveniences.count
        case .diary: 1
        }
    }
}
