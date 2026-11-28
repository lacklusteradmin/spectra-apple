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
