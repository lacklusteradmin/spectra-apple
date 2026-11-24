import Foundation
import SpectraCore

// Core assembles the bundle from what it recorded; Swift supplies what only
// the platform knows about itself and owns the files.

extension AppState {
    private var diagnosticsPlatformInfo: DiagnosticsPlatformInfo {
        let info = Bundle.main.infoDictionary ?? [:]
        return DiagnosticsPlatformInfo(
            appVersion: (info["CFBundleShortVersionString"] as? String) ?? "unknown",
            buildNumber: (info["CFBundleVersion"] as? String) ?? "unknown",
            osVersion: ProcessInfo.processInfo.operatingSystemVersionString,
            localeIdentifier: Locale.current.identifier,
            timeZoneIdentifier: TimeZone.current.identifier)
    }

    /// The bundle, written where the share sheet can hand it on. It is the
    /// system's temporary file to clear: the app keeps no copy.
    func exportDiagnosticsBundle() async throws -> URL {
        let json = try await bridge.ready().diagnosticsBundle(platform: diagnosticsPlatformInfo)
        let stamp = Self.exportFilenameTimestampFormatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("spectra-diagnostics-\(stamp)")
            .appendingPathExtension("json")
        try Data(json.utf8).write(to: fileURL, options: .atomic)
        return fileURL
    }
}
