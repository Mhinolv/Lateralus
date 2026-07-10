import Foundation
import Testing
@testable import Lateralus

struct ChallengeEngineTests {

    @Test func dailyChallengeIsDeterministic() {
        let date = Date(timeIntervalSince1970: 1_800_000_000)
        let a = ChallengeEngine.daily(for: date)
        let b = ChallengeEngine.daily(for: date)
        #expect(a == b)
    }

    @Test func dailyTypeRotatesThroughAllGames() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        var seen = Set<ChallengeType>()
        for offset in 0..<ChallengeType.games.count {
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            seen.insert(ChallengeEngine.daily(for: day).type)
        }
        #expect(seen.count == ChallengeType.games.count)
        #expect(!seen.contains(.diary))
    }

    /// The daily sequence must not repeat a prompt combination within two
    /// years for any playable type.
    @Test(arguments: ChallengeType.games)
    func noRepeatsWithinTwoYears(type: ChallengeType) {
        // Each type is featured once per full rotation of all game types.
        let occurrences = 730 / ChallengeType.games.count + 1
        var seen = Set<Challenge>()
        for occurrence in 0..<occurrences {
            let challenge = ChallengeEngine.challenge(type: type, occurrence: occurrence)
            #expect(!seen.contains(challenge), "Repeat at occurrence \(occurrence) for \(type)")
            seen.insert(challenge)
        }
    }

    @Test(arguments: ChallengeType.games)
    func combinationSpaceOutlastsTwoYears(type: ChallengeType) {
        // Featured days per type over two years.
        let needed = 730 / ChallengeType.games.count + 1
        #expect(ContentLibrary.combinationCount(for: type) >= needed)
    }

    @Test func fusionNeverPairsAConceptWithItself() {
        for occurrence in 0..<2_000 {
            let challenge = ChallengeEngine.challenge(type: .fusion, occurrence: occurrence)
            #expect(challenge.primary != challenge.secondary)
        }
    }

    @Test func contentPoolsHaveNoDuplicates() {
        #expect(Set(ContentLibrary.objects).count == ContentLibrary.objects.count)
        #expect(Set(ContentLibrary.useConstraints).count == ContentLibrary.useConstraints.count)
        #expect(Set(ContentLibrary.scenarios).count == ContentLibrary.scenarios.count)
        #expect(Set(ContentLibrary.realityTwists).count == ContentLibrary.realityTwists.count)
        #expect(Set(ContentLibrary.concepts).count == ContentLibrary.concepts.count)
        #expect(Set(ContentLibrary.backstories).count == ContentLibrary.backstories.count)
        #expect(Set(ContentLibrary.perspectives).count == ContentLibrary.perspectives.count)
        #expect(Set(ContentLibrary.words).count == ContentLibrary.words.count)
        #expect(Set(ContentLibrary.definitions).count == ContentLibrary.definitions.count)
        #expect(Set(ContentLibrary.linkWords).count == ContentLibrary.linkWords.count)
        #expect(Set(ContentLibrary.terribleIdeas).count == ContentLibrary.terribleIdeas.count)
        #expect(Set(ContentLibrary.inconveniences).count == ContentLibrary.inconveniences.count)
    }

    @Test func wordLinkNeverPairsAWordWithItself() {
        for occurrence in 0..<2_000 {
            let challenge = ChallengeEngine.challenge(type: .wordLink, occurrence: occurrence)
            #expect(challenge.primary != challenge.secondary)
        }
    }

    @Test func diaryIsNeverAGame() {
        #expect(!ChallengeType.games.contains(.diary))
        #expect(ChallengeType.games.count == ChallengeType.allCases.count - 1)
    }

    @Test func strideIsAlwaysCoprime() {
        for count in [50, 53, 60, 70, 80, 83, 97, 100, 110, 130, 140, 180, 220] {
            for salt in 0..<19 {
                let stride = ChallengeEngine.coprimeStride(for: count, salt: salt)
                #expect(ChallengeEngine.gcd(stride, count) == 1)
            }
        }
    }
}
