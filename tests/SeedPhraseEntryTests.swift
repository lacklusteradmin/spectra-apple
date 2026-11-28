import Foundation
import SpectraCore
import Testing

@testable import Spectra

/// The entry grid follows core's verdict: it grows to hold what is pasted,
/// and a fixed length is refused by core rather than enforced by cutting.
@MainActor
struct SeedPhraseEntryTests {
    private let zero24 = Array(repeating: "abandon", count: 23).joined(separator: " ") + " art"

    @Test func pastingTwentyFourWordsGrowsTheGridToTwentyFour() {
        let entry = SeedPhraseEntry()
        #expect(entry.slots.count == 12)
        entry.paste(zero24)
        #expect(entry.slots.count == 24)
        #expect(entry.verdict.wordCount == 24)
        #expect(entry.verdict.language?.code == "en")
        #expect(entry.verdict.isValid)
        #expect(entry.phrase == zero24)
    }

    @Test func aFixedLengthKeepsEveryPastedWordAndRefusesThePhrase() {
        let entry = SeedPhraseEntry()
        entry.wordCountOverride = 12
        entry.paste(zero24)
        #expect(entry.slots.count == 24)
        #expect(entry.verdict.problem == .wrongWordCount(expected: 12))
        #expect(!entry.verdict.isValid)
    }

    @Test func moreWordsStepsToTheNextStandardLength() {
        let entry = SeedPhraseEntry()
        entry.addSlots()
        #expect(entry.slots.count == 15)
        entry.paste(zero24)
        #expect(entry.nextSlotCount == nil)
    }

    /// Words typed faster than focus moves arrive in one slot together; each
    /// takes its own slot from there on, and none is lost past the grid's end.
    @Test func severalWordsInOneSlotFillTheSlotsAfterIt() {
        let entry = SeedPhraseEntry()
        entry.update(at: 10, with: "Abandon about zoo ")
        #expect(Array(entry.slots[10...12]) == ["abandon", "about", "zoo"])
        #expect(entry.slots.count >= 13)
        entry.update(at: 10, with: "")
        #expect(entry.slot(at: 10).isEmpty)
        #expect(entry.slot(at: 11) == "about")
    }

    @Test func clearingReturnsTheGridToItsStartingLength() {
        let entry = SeedPhraseEntry()
        entry.paste(zero24)
        entry.clear()
        #expect(entry.slots == Array(repeating: "", count: 12))
    }

    /// A created phrase goes through the same entry, judged at the length
    /// it was generated at.
    @Test func aCreatedPhraseIsJudgedAtItsLength() {
        let draft = WalletImportDraft()
        draft.configure(chain: .bitcoin, method: .createPhrase)
        draft.selectedSeedPhraseWordCount = 24
        #expect(draft.seedPhraseWords.count == 24)
        #expect(draft.seedEntry.verdict.isValid)
    }
}
