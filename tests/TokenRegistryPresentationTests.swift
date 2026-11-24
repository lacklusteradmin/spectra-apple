import Foundation
import SpectraCore
import Testing
import SwiftUI

@testable import Spectra

@MainActor
@Suite(.isolatedAppState)
struct TokenRegistryPresentationTests: IsolatedAppStateSuite {
    @Test func customEditorPersistsBothPriceSourcesAndKeepsIdentity() async throws {
        let state = makeState()
        let identifier = "0x1111111111111111111111111111111111111111"
        let added = await state.tokenPreferences.addCustom(chain: .ethereum, symbol: "DEMO", name: "Demo",
            contractAddress: identifier, coinpaprikaId: "demo-token", decimals: 6)
        #expect(added == nil)
        let entry = try #require(state.tokenPreferences.entries.first { !$0.isBuiltIn })
        #expect(entry.token.coinpaprikaId == "demo-token")
        #expect(entry.token.coingeckoId == "")
        let edited = await state.tokenPreferences.addCustom(chain: .ethereum, symbol: "NEW", name: "New Demo",
            contractAddress: identifier, coingeckoId: "demo", coinpaprikaId: "demo-new", decimals: 8, editing: entry)
        #expect(edited == nil)
        let current = try #require(state.tokenPreferences.entries.first { $0.id == entry.id })
        #expect(current.token.tokenId == entry.token.tokenId)
        #expect(current.token.name == "New Demo")
        #expect(current.token.coinpaprikaId == "demo-new")
        #expect(current.token.coingeckoId == "demo")
        let reopened = WalletServiceBridge(databasePath: directory.appendingPathComponent("state.sqlite").path,
            service: try WalletService(endpoints: []))
        let persisted = try await reopened.ready().appState()
        #expect(persisted.tokenPreferences.first { $0.id == entry.id }?.token == current.token)
    }

    /// The form names the protocol: Tron offers two, so none named is refused
    /// in words, and a TRC-10 ID is kept as TRC-10 when named.
    @Test func aTokenIsAddedUnderTheStandardTheFormNames() async throws {
        let state = makeState()
        let standards = try #require(Chain.tron.entry?.tokenStandards)
        #expect(standards.map(\.standard) == [.trc10, .trc20])
        #expect(standards.map(\.identifierPrompt) == ["Token ID", "Contract Address"])
        let unnamed = await state.tokenPreferences.addCustom(
            chain: .tron, symbol: "OLD", name: "Old", contractAddress: "1009999", decimals: 6)
        #expect(unnamed == AppLocalization.string("Choose the standard the token was issued under."))
        let named = await state.tokenPreferences.addCustom(
            chain: .tron, standard: .trc10, symbol: "OLD", name: "Old", contractAddress: "1009999", decimals: 6)
        #expect(named == nil)
        #expect(state.tokenPreferences.entries.contains { $0.token.tokenStandard == .trc10 && $0.token.contract == "1009999" })
    }

    @Test func tokenManagementScreensRenderInARealWindow() async throws {
        let state = makeState()
        state.applyCoreState(try await bridge.ready().appState())
        let entry = try #require(state.tokenPreferences.entries.first { $0.token.symbol == "USDC" })
        let views: [(String, AnyView)] = [
            ("Known tokens", AnyView(NavigationStack { TokenRegistrySettingsView(tokens: state.tokenPreferences) })),
            ("Token detail", AnyView(NavigationStack { TokenRegistryDetailView(tokens: state.tokenPreferences, groupKey: entry.token.tokenId) })),
            ("Custom token form", AnyView(NavigationStack { AddCustomTokenView(tokens: state.tokenPreferences) }))
        ]
        let window = try RenderWindow(takesKey: true)
        defer { window.close() }
        for (name, view) in views {
            window.show(view)
            try await Task.sleep(for: .milliseconds(300))
            window.layout()
            try window.record(named: name)
        }
    }
}
