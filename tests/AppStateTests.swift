import Foundation
import SpectraCore
import SwiftUI
import Testing
@testable import Spectra
@MainActor
@Suite(.isolatedAppState)
struct AppStatePlatformBridgeTests: IsolatedAppStateSuite {
    @Test func unpinningAllAssetsPersistsAcrossAsyncBridge() async throws {
        let service = try WalletService(endpoints: [])
        let path = directory
            .appendingPathComponent("pins-\(UUID().uuidString).sqlite").path
        let initial = try await service.openState(databasePath: path)
        #expect(initial.settings.pinnedDashboardTokenIds.count == 4)
        for tokenId in initial.settings.pinnedDashboardTokenIds {
            _ = try await service.applyStateCommand(
                command: .setDashboardAssetPinned(tokenId: tokenId, isPinned: false))
        }
        let reopened = try WalletService(endpoints: [])
        let saved = try await reopened.openState(databasePath: path)
        #expect(saved.settings.pinnedDashboardTokenIds.isEmpty)
        let reset = try await reopened.applyStateCommand(command: .resetPinnedDashboardAssets)
        #expect(reset.state.settings.pinnedDashboardTokenIds == initial.settings.pinnedDashboardTokenIds)
    }

    @Test func manualStatusRecheckRefusesMissingTransactionAcrossAsyncBridge() async throws {
        let id = UUID().uuidString
        let error = await #expect(throws: (any Error).self, "a missing transaction must not produce a successful status") {
            try await bridge.ready().recheckTransactionStatus(transactionId: id)
        }
        if let error { #expect(String(describing: error).contains("Transaction not found")) }
        let store = makeState()
        let message = await store.retryUTXOTransactionStatus(for: id)
        #expect(message.contains("Transaction not found"))
    }

    /// A wallet answers for the chains it was imported for and for no
    /// others. It reads what core stored: the EVM family shares one slot,
    /// so an Ethereum wallet answers for every EVM mainnet, and a
    /// Solana wallet is not asked to produce a Bitcoin address.
    @Test func aRenameThatLandsAfterADeleteDoesNotResurrectTheWallet() async throws {
        let store = makeState()
        let wallet = try await store.importWalletForTesting("Probe", on: .ethereum)
        let removed = await store.removeWallet(id: wallet.id)
        #expect(removed)
        await store.renameWallet(id: wallet.id, to: "Late rename")
        let after = try await bridge.ready().portfolioSnapshot().wallets
        #expect(after.isEmpty)
        #expect(store.wallets.isEmpty)
    }

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
    @Test func importingBitcoinWalletPersistsDerivedAddress() async {
        let store = makeState()
        store.walletImport.draft.walletName = "Primary BTC"
        store.walletImport.draft.seedEntry.paste("test test test test test test test test test test test junk")
        store.walletImport.draft.chain = .bitcoin
        await store.importWallet()
        #expect(store.walletImport.error == nil)
        #expect(store.wallets.count == 1)
        #expect(store.wallets.first?.chainId == Chain.bitcoin)
        #expect(store.wallets.first?.address?.isEmpty == false)
    }
    @Test func importingNewEvmNetworksRetainsTheSelectedNetworkAcrossTheBridge() async throws {
        let store = makeState()
        for chain in [Chain.plasma, .monad, .worldChain] {
            try await store.clearWalletsForTesting()
            store.walletImport.draft.walletName = "Import \(chain.id)"
            store.walletImport.draft.seedEntry.paste("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")
            store.walletImport.draft.chain = chain
            await store.importWallet()
            #expect(store.walletImport.error == nil, "\(chain.id)")
            let wallet = try #require(store.wallets.first, "\(chain.id)")
            #expect(wallet.chainId == chain)
            #expect(wallet.address?.lowercased() == "0x9858effd232b4033e47d90003d41ec34ecaeda94")
            let reopened = try await bridge.ready().portfolioSnapshot().wallets
            #expect(reopened.first?.chainId == chain)
            #expect(reopened.first?.address == wallet.address)
        }
    }
    /// A wallet carries its own network.
    @Test func bitcoinWalletDisplayTitleUsesWalletSpecificNetwork() {
        let wallet = WalletState(
            name: "BTC Testnet4", chainId: Chain.bitcoinTestnet4,
            address: "tb1qexample"
        )
        #expect(wallet.networkTitle == "Bitcoin Testnet 4")
    }
    /// Every EVM chain gets the EVM address hint. Asserted against the
    /// generic fallback rather than against the English text so the test
    /// does not depend on which locale it runs in.
    @Test func everyEVMChainGetsAFormatSpecificAddressHint() {
        // Kaspa has no arm of its own, so its message is the fallback.
        let generic = addressBookAddressValidationMessage(for: "", chain: .kaspa)
        let evmMainnets = Chain.mainnets.filter(\.isEVM)
        #expect(!evmMainnets.isEmpty)
        for chain in evmMainnets {
            #expect(addressBookAddressValidationMessage(for: "", chain: chain) != generic, "\(chain.displayName) still gets the generic hint")
            #expect(addressBookAddressValidationMessage(for: "nope", chain: chain) != addressBookAddressValidationMessage(for: "nope", chain: .kaspa), "\(chain.displayName) still gets the generic invalid-address hint")
        }
    }
    @Test func everyCatalogCapabilityHasALocalizedLabel() async throws {
        let capabilities = Set(try await service.endpointDirectory().flatMap(\.record.capabilities))
        #expect(!capabilities.isEmpty)
        for capability in capabilities {
            let key = "endpointCapability.\(endpointCapabilityId(capability: capability))"
            #expect(AppLocalization.string(key) != key)
        }
    }
    /// What the app reads about Ethereum's test networks: that the
    /// registry knows them as EVM testnets of Ethereum, and the RPC
    /// endpoints the catalog gives each. Core's
    /// `evm_chains_carry_their_eip155_ids` checks their EIP-155 ids.
    @Test func ethereumTestNetworksExposeExpectedContextsAndEndpoints() {
        for chain in [Chain.ethereumSepolia, .ethereumHoodi] {
            #expect(chain.isEVM, "\(chain.id)")
            #expect(!Chain.mainnets.contains(chain), "\(chain.id)")
            #expect(chain.mainnetCounterpart == .ethereum, "\(chain.id)")
        }
        #expect(AppEndpointDirectory.groupedSettingsEntries(for: Chain.ethereumSepolia).flatMap(\.endpoints) == ["https://ethereum-sepolia-rpc.publicnode.com", "https://1rpc.io/sepolia", "https://eth-sepolia.blockscout.com"])
        #expect(AppEndpointDirectory.groupedSettingsEntries(for: Chain.ethereumHoodi).flatMap(\.endpoints) == ["https://ethereum-hoodi-rpc.publicnode.com", "https://1rpc.io/hoodi", "https://eth-hoodi.blockscout.com"])
        let groups = AppEndpointDirectory.groupedSettingsEntries(for: Chain.ethereum)
        #expect(groups.contains { $0.chainId == .ethereumSepolia && $0.title == "Ethereum Sepolia" })
        #expect(AppEndpointDirectory.groupedSettingsEntries(for: Chain.ethereumSepolia).map(\.chainId) == [.ethereumSepolia])
    }
    /// A watch-only wallet on any chain survives persistence: "has any
    /// address" is a property of the wallet, not of a list.
    @Test func watchOnlyWalletOnAnyChainSurvivesPersistence() async throws {
        // One `AppState`, as the app has. Several instances sharing one
        // core is not a situation the product creates, and testing it
        // measures the harness rather than the behaviour.
        let store = makeState()
        for chain in [Chain.kaspa, .dash, .zcash, .ton, .icp, .bitcoinGold, .bittensor] {
            try await store.clearWalletsForTesting()

            // A real address of the chain's, from a phrase wallet imported
            // and removed, then watched.
            let derived = try await store.importWalletForTesting("Derived \(chain.id)", on: chain)
            let address = try #require(derived.address)
            try await store.clearWalletsForTesting()
            _ = try await store.importWalletForTesting(
                "Watch \(chain.id)", on: chain, kind: .watchAddresses(addresses: [address]))

            // Read it back the way a fresh launch does.
            let reloaded = try await bridge.ready().portfolioSnapshot().wallets
            #expect(reloaded.count == 1, "\(chain.id) wallet was dropped on load")
            #expect(reloaded.first?.address == address, "\(chain.id) address did not round-trip")
            #expect(reloaded.first?.chainId == chain)
        }
        try await store.clearWalletsForTesting()
    }

    /// Watching an EVM chain that shares Ethereum's address slot imports a
    /// wallet on that chain. The page used to key the typed addresses by the
    /// slot's first chain, Ethereum, and core — planning the chain the user
    /// picked — found none and refused the import.
    @Test func watchingAnEvmLayerTwoImportsAWalletOnIt() async throws {
        let store = makeState()
        try await store.clearWalletsForTesting()
        store.beginWalletSetup(chain: .arbitrum, method: .watchAddresses)
        let draft = store.walletImport.draft
        draft.walletName = "Watch Arbitrum"
        draft.watchOnlyInput = "0x000000000000000000000000000000000000dead"
        #expect(draft.canImportWallet)
        await store.importWallet()
        #expect(store.walletImport.error == nil)
        #expect(store.wallets.count == 1)
        #expect(store.wallets.first?.chainId == .arbitrum)
        try await store.clearWalletsForTesting()
    }

    // ── Core-owned settings ───────────────────────────────────────────
    //
    // The display currency is domain state: core owns it, core persists it,
    // and every front end reads the same value. Swift keeps a mirror it
    // never writes directly.

    /// Choosing a currency sends a command; what the app shows is what
    /// core stored.
    @Test func settingCurrencyGoesThroughCoreAndIsNormalized() async throws {
        let store = makeState()
        store.updateSetting(.fiatCurrency(value: .eur))
        await store.stateCommands.awaitPending()

        let state = try await bridge.ready().appState()
        #expect(state.settings.fiatCurrency == .eur)
        #expect(store.selectedFiatCurrency == .eur)
    }

    /// A fresh `AppState` picks up what core has stored — the same path
    /// that makes a change made in the CLI visible in the app.
    @Test func currencySurvivesIntoAFreshAppState() async throws {
        let writer = makeState()
        writer.updateSetting(.fiatCurrency(value: .jpy))
        await writer.stateCommands.awaitPending()

        let reader = makeState()
        await reader.loadCoreOwnedState()
        #expect(reader.selectedFiatCurrency == .jpy)
    }

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
        let stale = try await bridge.ready().appState()

        for entry in store.addressBook.entries { store.addressBook.remove(id: entry.id) }
        await store.stateCommands.awaitPending()
        store.applyCoreState(stale)
        #expect(store.addressBook.entries.isEmpty, "an earlier read must not resurrect removed contacts")
        let persisted = try await bridge.ready().appState()
        #expect(persisted.addressBook.isEmpty)
    }

    @Test func addingAContactGoesThroughCoreAndPersists() async throws {
        let store = makeState()
        _ = try await bridge.ready()
        await store.loadCoreOwnedState()
        await clearAddressBook(store)

        await store.addressBook.add(
            name: "  Cold Wallet  ", address: "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu",
            chain: .bitcoin, note: " vault ")
        await store.stateCommands.awaitPending()

        #expect(store.addressBook.entries.count == 1)
        #expect(store.addressBook.entries.first?.name == "Cold Wallet", "core trims")
        #expect(store.addressBook.entries.first?.note == "vault")
        #expect(store.addressBook.error == nil)

        // A fresh AppState sees it — same path that makes a CLI change visible.
        let reader = makeState()
        await reader.loadCoreOwnedState()
        #expect(reader.addressBook.entries.count == 1)

        await clearAddressBook(store)
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

    @Test func torDoesNotActivateOrStopForAnUncommittedToggle() async throws {
        _ = try await bridge.ready().applyStateCommand(command: .setAppSetting(update: .torEnabled(value: false)))
        _ = try await service.configureNetworkRuntime(cacheDir: directory.path)
        let store = makeState()
        store.updateSetting(.torUseCustomProxy(value: true))
        store.updateSetting(.torCustomProxyAddress(value: "socks5://127.0.0.1:19050"))
        await store.stateCommands.awaitPending()
        #expect(torStatus() == .stopped)
        store.updateSetting(.torEnabled(value: true))
        #expect(store.appSettings.torEnabled)
        #expect(!store.committedAppSettings.torEnabled)
        #expect(torStatus() == .stopped)
        await store.stateCommands.awaitPending()
        #expect(store.committedAppSettings.torEnabled)
        #expect(torStatus() == .ready)
        store.updateSetting(.torEnabled(value: false))
        #expect(torStatus() == .ready)
        await store.stateCommands.awaitPending()
        #expect(torStatus() == .stopped)
        store.updateSetting(.torUseCustomProxy(value: false))
        store.updateSetting(.torCustomProxyAddress(value: "socks5://127.0.0.1:9050"))
        await store.stateCommands.awaitPending()
    }

    @Test func settingsRuntimeUsesCommittedValuesWhileEditsAreQueued() async throws {
        let store = makeState()
        let state = try await bridge.ready().appState()
        store.applyCoreState(state)
        let initial = store.committedAppSettings.bitcoinStopGap
        let next: UInt32 = initial == 30 ? 40 : 30
        store.updateSetting(.bitcoinStopGap(value: next))
        #expect(store.appSettings.bitcoinStopGap == next)
        #expect(store.committedAppSettings.bitcoinStopGap == initial)
        store.updateSetting(.bitcoinStopGap(value: initial))
        #expect(store.committedAppSettings.bitcoinStopGap == initial)
        await store.stateCommands.awaitPending()
        #expect(store.appSettings.bitcoinStopGap == initial)
        #expect(store.committedAppSettings.bitcoinStopGap == initial)
    }

    /// A setting survives into a fresh `AppState`, and core bounds it —
    /// on screen at once, by core's own rule, not after the round trip.
    @Test func settingsGoThroughCoreAndSurviveIntoAFreshAppState() async throws {
        let store = makeState()
        store.updateSetting(.addCustomEndpoint(capabilities: [.fee, .broadcast, .verification], chainId: Chain.monero, api: "monero-daemon-rpc", endpoint: "  https://wallet.example  "))
        store.updateSetting(.bitcoinStopGap(value: 9_999))
        store.updateSetting(.useLargeMovementNotifications(value: false))
        #expect(store.appSettings.customEndpoints.last?.endpoint == "https://wallet.example", "core's rule trims before the command lands")
        #expect(store.appSettings.bitcoinStopGap == 200, "9999 is outside 1...200")
        await store.stateCommands.awaitPending()

        let fresh = makeState()
        await fresh.loadCoreOwnedState()
        #expect(fresh.appSettings.customEndpoints.last?.endpoint == "https://wallet.example")
        #expect(fresh.appSettings.bitcoinStopGap == 200)
        #expect(!fresh.appSettings.useLargeMovementNotifications)

        store.updateSetting(.bitcoinStopGap(value: 10))
        store.updateSetting(.useLargeMovementNotifications(value: true))
        await store.stateCommands.awaitPending()
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
        let old = try await bridge.ready().appState()
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

    @Test func fiatCatalogSuppliesStableIdentityAndDisplayMetadata() {
        #expect(FiatCurrency.allCases.count == 12)
        #expect(Set(FiatCurrency.allCases.map(\.code)).count == 12)
        #expect(FiatCurrency.jpy.displayRules.decimals == 0)
        #expect(FiatCurrency.usd.displayRules.minimumVisible == 0.01)
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
    func clearWalletsForTesting() async throws {
        let stored = try await bridge.ready().portfolioSnapshot().wallets
        for wallet in stored { _ = try await bridge.ready().applyStateCommand(command: .removeWallet(walletId: wallet.id)) }
        await rebuildWalletDerivedStateFromCore()
    }
}
