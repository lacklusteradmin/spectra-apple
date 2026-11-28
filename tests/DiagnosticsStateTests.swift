import Foundation
import SpectraCore
import Testing
@testable import Spectra
@MainActor
@Suite(.isolatedAppState)
struct WalletDiagnosticsStateTests: IsolatedAppStateSuite {
    /// An appended line crosses the binding with every field. Trimming and
    /// the 800-line cap are core's rules, tested in `operational_events.rs`.
    @Test func appendedLogCrossesTheBindingWithEveryField() async throws {
        let state = WalletDiagnosticsState(bridge: bridge)
        state.appendOperationalLog(category: "Network", message: "Request failed", chain: Chain.bitcoin, source: "rpc")
        await state.flushPendingPersistence()
        #expect(state.operationalLogs.first?.input.level == .error)
        #expect(state.operationalLogs.first?.input.category == "Network")
        #expect(state.operationalLogs.first?.input.message == "Request failed")
        #expect(state.operationalLogs.first?.input.chainId == Chain.bitcoin)
        #expect(state.operationalLogs.first?.input.source == "rpc")
    }
    @Test func exportOperationalLogsTextIncludesHeaderAndFields() async throws {
        let state = WalletDiagnosticsState(bridge: bridge)
        state.appendOperationalLog(
            category: "Chain Sync", message: "Ethereum refresh timed out.", chain: Chain.ethereum, source: "network")
        await state.flushPendingPersistence()
        let text = state.exportOperationalLogsText(networkSyncStatusText: "Network Status: Healthy")
        #expect(text.contains("Spectra Operational Logs"))
        #expect(text.contains("Entries: 1"))
        #expect(text.contains("Network Status: Healthy"))
        #expect(text.contains("[ERROR]"))
        #expect(text.contains("source=network"))
        #expect(text.contains("chain=\(Chain.ethereum.id)"))
    }
}
