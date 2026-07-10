import Foundation

/// Generates challenges deterministically from the content pools.
///
/// The daily challenge for a given date is a pure function of that date:
/// every install of the app sees the same prompt on the same day, and the
/// sequence never repeats a combination until the pool of combinations is
/// exhausted (years, for every type).
enum ChallengeEngine {

    /// Day zero of the daily-challenge sequence.
    static let epoch: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        return Calendar(identifier: .gregorian).date(from: components)!
    }()

    static func dayIndex(for date: Date = .now) -> Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: epoch),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        return max(0, days)
    }

    /// Today's featured challenge. Game types rotate daily; within a type,
    /// each appearance advances an occurrence counter that strides through
    /// the combination space without repeating.
    static func daily(for date: Date = .now) -> Challenge {
        let day = dayIndex(for: date)
        let types = ChallengeType.games
        let type = types[day % types.count]
        let occurrence = day / types.count
        return challenge(type: type, occurrence: occurrence)
    }

    /// A random practice challenge of the given type.
    static func practice(type: ChallengeType) -> Challenge {
        challenge(type: type, occurrence: Int.random(in: 0..<100_000))
    }

    // MARK: - Deterministic generation

    static func challenge(type: ChallengeType, occurrence: Int) -> Challenge {
        switch type {
        case .alternateUse:
            let object = pick(ContentLibrary.objects, occurrence: occurrence, salt: 1)
            return Challenge(type: type, primary: object.name, secondary: nil, emoji: object.emoji)

        case .constrainedUse:
            let object = pick(ContentLibrary.objects, occurrence: occurrence, salt: 2)
            let constraint = pick(ContentLibrary.useConstraints, occurrence: occurrence, salt: 3)
            return Challenge(type: type, primary: object.name, secondary: constraint, emoji: object.emoji)

        case .realityShift:
            let scenario = pick(ContentLibrary.scenarios, occurrence: occurrence, salt: 4)
            let twist = pick(ContentLibrary.realityTwists, occurrence: occurrence, salt: 5)
            return Challenge(type: type, primary: scenario, secondary: twist, emoji: "🌀")

        case .fusion:
            let first = pick(ContentLibrary.concepts, occurrence: occurrence, salt: 6)
            var second = pick(ContentLibrary.concepts, occurrence: occurrence, salt: 7)
            if second == first {
                let pool = ContentLibrary.concepts
                second = pool[(pool.firstIndex(of: first)! + 1) % pool.count]
            }
            return Challenge(type: type, primary: first.name, secondary: second.name, emoji: first.emoji + second.emoji)

        case .backstory:
            let scene = pick(ContentLibrary.backstories, occurrence: occurrence, salt: 8)
            return Challenge(type: type, primary: scene, secondary: nil, emoji: "🔍")

        case .perspectiveFlip:
            let scenario = pick(ContentLibrary.scenarios, occurrence: occurrence, salt: 9)
            let perspective = pick(ContentLibrary.perspectives, occurrence: occurrence, salt: 10)
            return Challenge(type: type, primary: scenario, secondary: perspective, emoji: "👁️")

        case .redefine:
            let word = pick(ContentLibrary.words, occurrence: occurrence, salt: 11)
            return Challenge(type: type, primary: word, secondary: nil, emoji: "📖")

        case .neologism:
            let definition = pick(ContentLibrary.definitions, occurrence: occurrence, salt: 12)
            return Challenge(type: type, primary: definition, secondary: nil, emoji: "✍️")

        case .wordLink:
            let first = pick(ContentLibrary.linkWords, occurrence: occurrence, salt: 13)
            var second = pick(ContentLibrary.linkWords, occurrence: occurrence, salt: 14)
            if second == first {
                let pool = ContentLibrary.linkWords
                second = pool[(pool.firstIndex(of: first)! + 1) % pool.count]
            }
            return Challenge(type: type, primary: first, secondary: second, emoji: "🧵")

        case .positiveSpin:
            let idea = pick(ContentLibrary.terribleIdeas, occurrence: occurrence, salt: 16)
            return Challenge(type: type, primary: idea, secondary: nil, emoji: "🙃")

        case .invention:
            let object = pick(ContentLibrary.objects, occurrence: occurrence, salt: 17)
            return Challenge(type: type, primary: object.name, secondary: nil, emoji: object.emoji)

        case .miniMyth:
            let inconvenience = pick(ContentLibrary.inconveniences, occurrence: occurrence, salt: 18)
            return Challenge(type: type, primary: inconvenience, secondary: nil, emoji: "🏛️")

        case .diary:
            // Diary is journal-only; the engine never features it, but the
            // switch stays exhaustive for safety.
            return Challenge(type: type, primary: "Diary", secondary: nil, emoji: "📓")
        }
    }

    /// Walks a pool with a stride coprime to its size, so consecutive
    /// occurrences visit every element before any repeat, in a scrambled order.
    /// Different salts give different-looking sequences per pool role.
    static func pick<T>(_ pool: [T], occurrence: Int, salt: Int) -> T {
        precondition(!pool.isEmpty, "Content pool is empty")
        let step = coprimeStride(for: pool.count, salt: salt)
        return pool[(occurrence * step + salt &* 31) %% pool.count]
    }

    static func coprimeStride(for count: Int, salt: Int) -> Int {
        let candidates = [53, 71, 83, 97, 101, 113, 127, 131]
        for offset in 0..<candidates.count {
            let candidate = candidates[(salt + offset) % candidates.count]
            if gcd(candidate, count) == 1 { return candidate }
        }
        return 1
    }

    static func gcd(_ a: Int, _ b: Int) -> Int {
        var (a, b) = (abs(a), abs(b))
        while b != 0 { (a, b) = (b, a % b) }
        return a
    }
}

infix operator %%: MultiplicationPrecedence

/// Non-negative modulo.
func %% (lhs: Int, rhs: Int) -> Int {
    let result = lhs % rhs
    return result >= 0 ? result : result + rhs
}
