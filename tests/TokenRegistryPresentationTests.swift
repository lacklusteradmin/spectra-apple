import Foundation
import SpectraCore
import Testing
import SwiftUI

@testable import Spectra

@MainActor
@Suite(.isolatedAppState)
struct TokenRegistryPresentationTests: IsolatedAppStateSuite {

    @Test func tokenManagementScreensRenderInARealWindow() async throws {
        let state = makeState()
        state.applyCoreState(try await bridge.ready().committedState())
        let usdc = try #require(state.tokenPreferences.tokens.first { $0.symbol == "USDC" })
        let bitcoin = try #require(state.tokenPreferences.tokens.first { $0.tokenId == "bitcoin" })
        let views: [(String, AnyView)] = [
            ("Known tokens", AnyView(NavigationStack { TokenRegistrySettingsView(tokens: state.tokenPreferences) })),
            ("Token detail", AnyView(NavigationStack { TokenRegistryDetailView(tokens: state.tokenPreferences, tokenId: usdc.tokenId) })),
            ("Native coin detail", AnyView(NavigationStack { TokenRegistryDetailView(tokens: state.tokenPreferences, tokenId: bitcoin.tokenId) })),
            ("Chain detail", AnyView(NavigationStack { ChainDetailView(chain: .bitcoin) })),
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
