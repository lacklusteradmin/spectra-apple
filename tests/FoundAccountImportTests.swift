import Foundation
import SpectraCore
import Testing

@testable import Spectra

/// An account a funds scan found is imported from its phrase and passphrase
/// exactly as they were scanned, deriving as it was found: by Funds
/// Finder's single import, by its Import All, and by choosing it in the
/// import's own used-account list.
@MainActor
struct FoundAccountImportTests {
    private func words(_ chain: Chain, _ count: UInt32) throws -> [String] {
        try generateSeedPhrase(chain: chain, wordCount: count).split(separator: " ").map(String.init)
    }

    private func candidate(
        _ chain: Chain, profile: DerivationProfile?, account: UInt32, version: TonWalletVersion? = nil
    ) -> FundsFinderCandidate {
        FundsFinderCandidate(
            chainId: chain, profile: profile, account: account, tonWalletVersion: version,
            derivationPath: "", address: "address")
    }

    /// The passphrase is carried as typed, surrounding spaces included: a
    /// trimmed one derives a different wallet.
    private let passphrase = " correct horse "

    @Test func theSingleImportOpensOnTheFoundAccount() throws {
        let words = try words(.bitcoin, 12)
        let draft = WalletImportDraft()
        draft.configure(foundAccount: candidate(.bitcoin, profile: .taproot, account: 2), words: words, passphrase: passphrase)
        #expect(draft.chain == .bitcoin)
        #expect(draft.method == .importPhrase)
        #expect(draft.seedPhraseWords == words)
        #expect(draft.overridePassphrase == passphrase)
        #expect(draft.derivationProfile == .taproot)
        #expect(draft.derivationAccount == 2)
        let commit = try #require(draft.importCommit(name: ""))
        #expect(commit.seedPhrase == words.joined(separator: " "))
        #expect(commit.derivationOverrides.passphrase == passphrase)
        #expect(commit.derivationPath == "m/86'/0'/2'/0/0")
        #expect(commit.password == nil)
    }

    @Test func importAllSealsEachFoundAccountWithItsPassword() throws {
        let words = try words(.bitcoin, 12)
        let found = candidate(.bitcoin, profile: .nativeSegWit, account: 1)
        let sealed = try #require(WalletImportDraft.importCommit(
            foundAccount: found, words: words, passphrase: passphrase, password: "a long enough password"))
        #expect(sealed.password == "a long enough password")
        #expect(sealed.request.walletName.isEmpty)
        #expect(sealed.seedPhrase == words.joined(separator: " "))
        #expect(sealed.derivationOverrides.passphrase == passphrase)
        #expect(sealed.derivationPath == "m/84'/0'/1'/0/0")
        let open = try #require(WalletImportDraft.importCommit(
            foundAccount: found, words: words, passphrase: passphrase, password: ""))
        #expect(open.password == nil)
    }

    /// A pathless network keeps the derivation its import starts with.
    @Test func aPathlessAccountKeepsTheNetworksDerivation() throws {
        let words = try words(.monero, 25)
        let draft = WalletImportDraft()
        draft.configure(foundAccount: candidate(.monero, profile: nil, account: 0), words: words, passphrase: "")
        #expect(draft.seedPhraseWords == words)
        #expect(draft.derivationProfile == nil)
        #expect(try #require(draft.importCommit(name: "")).derivationPath == nil)
    }

    /// Choosing a used account changes how the import derives and nothing
    /// else the form holds.
    @Test func choosingAUsedAccountKeepsTheRestOfTheForm() throws {
        let words = try words(.bitcoin, 12)
        let draft = WalletImportDraft()
        draft.configure(chain: .bitcoin, method: .importPhrase, upgrading: "watched")
        draft.seedEntry.load(words, wordCount: words.count)
        draft.overridePassphrase = passphrase
        draft.walletName = "Savings"
        draft.customDerivationPath = "m/84'/0'/9'/0/0"
        #expect(draft.derive(as: candidate(.bitcoin, profile: .legacy, account: 1)))
        #expect(draft.derivationProfile == .legacy)
        #expect(draft.derivationAccount == 1)
        #expect(draft.customDerivationPath.isEmpty)
        #expect(draft.seedPhraseWords == words)
        #expect(draft.overridePassphrase == passphrase)
        #expect(draft.walletName == "Savings")
        #expect(draft.upgradeWalletId == "watched")
        #expect(try #require(draft.importCommit(name: "")).derivationPath == "m/44'/0'/1'/0/0")
        // An account with neither a path nor a wallet version is not a choice.
        #expect(!draft.derive(as: candidate(.bitcoin, profile: nil, account: 0)))
        #expect(draft.derivationProfile == .legacy)
    }

    @Test func aTonAccountIsFoundAtItsWalletVersion() throws {
        let draft = WalletImportDraft()
        draft.configure(
            foundAccount: candidate(.ton, profile: nil, account: 0, version: .v4r2), words: try words(.ton, 24),
            passphrase: "")
        #expect(draft.tonWalletVersion == .v4r2)
    }
}
