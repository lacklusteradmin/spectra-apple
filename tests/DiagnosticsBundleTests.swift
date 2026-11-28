import Foundation
import SpectraCore
import Testing
@testable import Spectra
@MainActor
@Suite(.isolatedAppState)
struct DiagnosticsBundleTests: IsolatedAppStateSuite {
    /// The file the app shares is core's bundle, every network's document in it.
    @Test func exportsTheDiagnosticsBundleJSON() async throws {
        let store = makeState()
        let fileURL = try await store.exportDiagnosticsBundle()
        defer { try? FileManager.default.removeItem(at: fileURL) }
        #expect(fileURL.path.hasPrefix(FileManager.default.temporaryDirectory.path))
        let bundle = try Self.bundle(at: fileURL)
        let environment = try #require(bundle["environment"] as? [String: Any])
        #expect(!(environment["osVersion"] as? String ?? "").isEmpty)
        #expect(environment["walletCount"] as? Int == 0)
        let documents = try #require(bundle["chainDiagnosticsJson"] as? [String: String])
        #expect(Set(documents.keys) == Set(Chain.all.map(\.id)))
    }

    private static func bundle(at url: URL) throws -> [String: Any] {
        try #require(try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
    }
}
