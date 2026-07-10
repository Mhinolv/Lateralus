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
    /// The bundled pool snapshot used by daily schedule version 1. Pool order
    /// and values are protected by a test fingerprint.
    static let version = 1

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
        case .diary, .unknown: 1
        }
    }

    /// Stable FNV-1a fingerprint of the complete ordered v1 content snapshot.
    static var versionFingerprint: UInt64 {
        var hash: UInt64 = 14_695_981_039_346_656_037

        func add(_ value: String) {
            for byte in value.utf8 {
                hash ^= UInt64(byte)
                hash &*= 1_099_511_628_211
            }
            hash ^= 0xFF
            hash &*= 1_099_511_628_211
        }

        for item in objects { add(item.name); add(item.emoji) }
        useConstraints.forEach(add)
        scenarios.forEach(add)
        realityTwists.forEach(add)
        for item in concepts { add(item.name); add(item.emoji) }
        backstories.forEach(add)
        perspectives.forEach(add)
        words.forEach(add)
        definitions.forEach(add)
        linkWords.forEach(add)
        terribleIdeas.forEach(add)
        inconveniences.forEach(add)
        return hash
    }
}
