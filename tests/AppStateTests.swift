import Foundation
import SpectraCore
import SwiftUI
import Testing
@testable import Spectra
@MainActor
@Suite(.isolatedAppState)
struct AppStateTests: IsolatedAppStateSuite {

    /// An edit renames the wallet and leaves the rest of what core holds.
    @Test func editingAWalletsNameKeepsItsOtherSettings() async throws {
        let store = makeState()
        var wallet = try await store.importWalletForTesting("Primary ETH", on: .ethereum)
        _ = try await bridge.ready().applyStateCommand(
            command: .setWalletPortfolioInclusion(walletId: wallet.id, included: false))
        await store.rebuildWalletDerivedStateFromCore()
        wallet = try #require(store.wallets.first)
        store.beginEditingWallet(wallet)
        store.walletImport.draft.walletName = "Renamed ETH"
                await store.importWallet()
        #expect(store.wallets.count == 1)
        #expect(store.wallets[0].name == "Renamed ETH")
        #expect(!store.wallets[0].includeInPortfolioTotal)
        #expect(store.walletImport.editingWalletId == nil)
        #expect(!store.walletImport.isPresented)
        #expect(store.walletImport.error == nil)
    }

    // ── Core-owned settings ───────────────────────────────────────────
    //
    // The display currency is domain state: core owns it, core persists it,
    // and every front end reads the same value. Swift keeps a mirror it
    // never writes directly.

    // ── Address book ──────────────────────────────────────────────────
    //
    // The list, and the rules about what may go in it, belong to core.
    // Swift sends commands and renders what comes back.

    private func clearAddressBook(_ store: AppState) async {
        for id in store.addressBook.entries.map(\.id) {
            store.addressBook.remove(id: id)
        }
        await store.stateCommands.awaitPending()
        #expect(store.addressBook.entries.isEmpty)
    }

    @Test func queuedContactWritesCannotBeUndoneByAnOlderRead() async throws {
        let store = makeState()
        await store.loadCoreOwnedState()
        await clearAddressBook(store)
        for index in 1...3 {
            await store.addressBook.add(
                name: "Contact \(index)",
                address: "0x" + String(repeating: String(index), count: 40),
                chain: .ethereum)
        }
        await store.stateCommands.awaitPending()
        #expect(store.addressBook.entries.count == 3)
        let stale = try await bridge.ready().committedState()

        for entry in store.addressBook.entries { store.addressBook.remove(id: entry.id) }
        await store.stateCommands.awaitPending()
        store.applyCoreState(stale)
        #expect(store.addressBook.entries.isEmpty, "an earlier read must not resurrect removed contacts")
        let persisted = try await bridge.ready().committedState()
        #expect(persisted.addressBook.isEmpty)
    }

    /// Core refuses, and says why. The UI must not silently do nothing.
    /// A refusal reaches the contact form. Which addresses core refuses —
    /// invalid, duplicate in any case — is tested in `address_book.rs`.
    @Test func aContactRefusalReachesTheForm() async throws {
        let store = makeState()
        _ = try await bridge.ready()
        await store.loadCoreOwnedState()
        await clearAddressBook(store)
        let refusal = await store.addressBook.add(
            name: "Typo", address: "definitely-not-an-address", chain: .bitcoin)
        #expect(store.addressBook.entries.isEmpty)
        #expect(refusal != nil, "the form that asked hears why, before it closes")
        #expect(store.addressBook.error == refusal)
    }

    @Test func settingsRuntimeUsesCommittedValuesWhileEditsAreQueued() async throws {
        let store = makeState()
        let state = try await bridge.ready().committedState()
        store.applyCoreState(state)
        let initial = store.committedAppSettings.largeMovementAlertPercentThreshold
        let next: Double = initial == 30 ? 40 : 30
        store.updateSetting(.largeMovementAlertPercentThreshold(value: next))
        #expect(store.appSettings.largeMovementAlertPercentThreshold == next)
        #expect(store.committedAppSettings.largeMovementAlertPercentThreshold == initial)
        store.updateSetting(.largeMovementAlertPercentThreshold(value: initial))
        #expect(store.committedAppSettings.largeMovementAlertPercentThreshold == initial)
        await store.stateCommands.awaitPending()
        #expect(store.appSettings.largeMovementAlertPercentThreshold == initial)
        #expect(store.committedAppSettings.largeMovementAlertPercentThreshold == initial)
    }

    @Test func importCompletionPreservesAPartialSuccessNotice() async {
        let store = makeState()
        store.beginWalletSetup(chain: .ethereum, method: .watchAddresses)
        await store.walletImport.submit { "Some addresses were refused" }
        // SwiftUI can write the dismissed binding again after completion.
        store.walletImport.isPresented = false
        #expect(store.walletImport.error == "Some addresses were refused")
        #expect(!store.walletImport.isPresented)
        #expect(store.appNoticeItems.contains { $0.message == "Some addresses were refused" })
    }

    @Test func portfolioSnapshotRejectsADelayedOlderResult() async throws {
        let service = try WalletService(endpoints: [])
        let old = try await service.portfolioSnapshot()
        _ = try await service.applyStateCommand(command: .setAppSetting(update: .fiatCurrency(value: .eur)))
        let new = try await service.portfolioSnapshot()
        let store = makeState()

        store.applyPortfolioSnapshot(new)
        store.applyPortfolioSnapshot(old)
        #expect(store.portfolioSnapshotRevision == new.revision)
        #expect(store.portfolioValuation?.currency == .eur)
        #expect(store.portfolioValuation?.portfolio.fiatTotal == nil)
        #expect(store.selectedFiatCurrency == .eur)
    }

    @Test func snapshotCannotPartiallyOverwriteANewerStateCommand() async throws {
        let service = try WalletService(endpoints: [])
        let stale = try await service.portfolioSnapshot()
        let store = makeState()

        let transition = try await service.applyStateCommand(command: .setAppSetting(update: .fiatCurrency(value: .eur)))
        store.applyCoreState(transition.state)
        store.applyPortfolioSnapshot(stale)
        #expect(store.selectedFiatCurrency == .eur)
        #expect(store.portfolioValuation == nil)
        #expect(store.portfolioSnapshotRevision == 0)
    }

    @Test func coreVersionWinsRegardlessOfRequestCompletionOrder() async throws {
        let old = try await bridge.ready().committedState()
        let changed = try await bridge.ready().applyStateCommand(command: .setAppSetting(update: .fiatCurrency(value: .eur)))
        // A failed operation after the successful write must not discard its result.
        await #expect(throws: (any Error).self, "missing transaction must fail") {
            try await bridge.ready().recheckTransactionStatus(transactionId: "missing")
        }
        let store = makeState()
        #expect(store.applyCoreState(changed.state))
        #expect(!store.applyCoreState(old))
        #expect(store.selectedFiatCurrency == .eur)
        #expect(store.appliedCoreStateRevision == changed.state.revision)
    }

    @Test func derivationInputPreservesSecretWhitespace() throws {
        let draft = WalletImportDraft()
        draft.overridePassphrase = " secret "
        draft.overrideHmacKey = " key "
        let parsed = draft.resolvedDerivationOverrides
        #expect(parsed.passphrase == " secret ")
        #expect(parsed.hmacKey == " key ")
    }
}

@MainActor
private extension AppState {
    /// A wallet in core, imported as the app imports one: `kind` on `chain`,
    /// from a phrase core creates in the chain's own format where it takes
    /// one, with no password.
    func importWalletForTesting(
        _ name: String, on chain: Chain, kind: WalletImportKind = .phrase
    ) async throws -> WalletState {
        let words = try #require(seedPhraseLengths(chain: chain).first).wordCount
        let phrase = try generateSeedPhrase(chain: chain, wordCount: words)
        let outcome = try await bridge.ready().importWallets(commit: WalletImportCommit(
            password: nil,
            request: WalletImportRequest(walletName: name, chain: chain, kind: kind),
            derivationPath: nil,
            derivationOverrides: WalletDerivationOverrides(passphrase: nil, hmacKey: nil),
            seedPhrase: kind == .phrase ? phrase : nil,
            privateKey: nil, restoreHeight: nil, namedAccount: nil, tonWalletVersion: nil, upgradeWalletId: nil))
        await rebuildWalletDerivedStateFromCore()
        return try #require(outcome.wallets.first)
    }
}
