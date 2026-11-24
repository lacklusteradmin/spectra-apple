import Foundation
import SpectraCore
import SwiftUI
import Synchronization

/// Locale-independent data files at the bundle root: `resources/` ships flat,
/// so the name is the whole address. Localized text lives in one place only,
/// the `RuntimeStrings.<locale>.json` tables `AppLocalization` reads.
enum StaticContentCatalog {
    private static let cache = Mutex<[String: any Sendable]>([:])
    static func loadRequiredResource<T: Decodable & Sendable>(_ name: String, as type: T.Type) -> T {
        guard let value = loadResource(name, as: type) else { fatalError("Missing required resource: \(name).json") }
        return value
    }
    static func loadResource<T: Decodable & Sendable>(_ name: String, as type: T.Type) -> T? {
        if let cached = cache.withLock({ $0[name] as? T }) { return cached }
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let value = try? JSONDecoder().decode(T.self, from: data)
        else { return nil }
        cache.withLock { $0[name] = value }
        return value
    }
}

/// Exhaustive SwiftUI rendering of the core catalog's typed palette.
extension CatalogColor {
    var color: Color {
        switch self {
        case .blue: return .blue
        case .cyan: return .cyan
        case .gray: return .gray
        case .green: return .green
        case .indigo: return .indigo
        case .mint: return .mint
        case .orange: return .orange  // design-tokens: artwork
        case .pink: return .pink
        case .purple: return .purple
        case .red: return .red
        case .teal: return .teal
        case .yellow: return .yellow
        }
    }
}

/// The buy/exchange directory, from `resources/BuyProviders.json`. Names, URLs
/// and domains do not translate; only the section notes are copy. Adding a
/// provider is one row there.
struct BuyProviderSeed: Decodable, Identifiable {
    let id: String
    let name: String
    let url: String
    let label: String
}

struct BuyProviders: Decodable {
    let onramps: [BuyProviderSeed]
    let exchanges: [BuyProviderSeed]
    static var current: BuyProviders { StaticContentCatalog.loadRequiredResource("BuyProviders", as: BuyProviders.self) }
}

/// A donation address, validated by core when its catalog loads. Its title is
/// the chain's name.
extension DonationDestination {
    var title: String { chainId.displayName }
}

/// Every string a person reads, from `RuntimeStrings.<locale>.json`: the
/// reader's preferred languages that ship, then the source language. A key in
/// no table reads as itself.
enum AppLocalization {
    private struct Manifest: Decodable {
        let sourceLanguage: String
        let availableLocales: [String]
    }
    private struct Tables {
        let locale: Locale
        let strings: [[String: String]]
    }
    private static let manifest = StaticContentCatalog.loadResource("RuntimeStrings.manifest", as: Manifest.self)
    private static let cachedTables = Mutex<Tables?>(nil)
    /// Drops the tables when the reader's locale changes, so the next read
    /// rebuilds them. Region and per-app language changes post this; a
    /// system language change relaunches the app.
    /// The center keeps a block observer for the life of the process.
    private static let localeChangeObserver: Void = {
        _ = NotificationCenter.default.addObserver(
            forName: NSLocale.currentLocaleDidChangeNotification, object: nil, queue: nil
        ) { _ in cachedTables.withLock { $0 = nil } }
    }()

    /// The language of the table read first, with the reader's region and
    /// number preferences. Every date, number and currency the app formats
    /// uses it, so figures follow the same settings as the words around them.
    static var locale: Locale { tables().locale }
    static func string(_ key: String) -> String {
        for table in tables().strings {
            if let value = table[key] { return value }
        }
        return key
    }
    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        format(key, arguments: arguments)
    }
    static func format(_ key: String, arguments: [CVarArg]) -> String {
        String(format: string(key), locale: locale, arguments: arguments)
    }
    /// A sentence about `count` things. A table may give the singular beside
    /// the key as `<key>#one`, read only from the table that has `key`, so a
    /// language without number agreement never borrows another's singular.
    static func format(_ key: String, count: Int, _ arguments: CVarArg...) -> String {
        var template = key
        for table in tables().strings {
            guard let value = table[key] else { continue }
            template = count == 1 ? table[key + "#one"] ?? value : value
            break
        }
        return String(format: template, locale: locale, arguments: arguments)
    }

    /// Built once, and again after the reader's locale changes.
    private static func tables() -> Tables {
        if let cached = cachedTables.withLock({ $0 }) { return cached }
        _ = localeChangeObserver
        let source = manifest?.sourceLanguage ?? "en"
        let available = manifest?.availableLocales ?? [source]
        var identifiers: [String] = []
        for preferred in Locale.preferredLanguages {
            if let match = shippedLocalization(for: preferred, in: available), !identifiers.contains(match) {
                identifiers.append(match)
            }
        }
        if !identifiers.contains(source) { identifiers.append(source) }
        let tables = Tables(
            locale: displayLocale(language: identifiers[0]),
            strings: identifiers.compactMap {
                StaticContentCatalog.loadResource("RuntimeStrings.\($0)", as: [String: String].self)
            })
        cachedTables.withLock { $0 = tables }
        return tables
    }

    /// `language` with everything else — region, calendar, numbering — from
    /// the reader's current locale.
    private static func displayLocale(language: String) -> Locale {
        var components = Locale.Components(locale: .current)
        components.languageComponents = Locale.Language.Components(identifier: language)
        return Locale(components: components)
    }

    /// The shipped table for a preferred language: an exact match, the Chinese
    /// script it names (`zh-Hans-US` reads `zh-Hans`), or its bare language.
    private static func shippedLocalization(for identifier: String, in available: [String]) -> String? {
        let normalized = identifier.replacingOccurrences(of: "_", with: "-").lowercased()
        if let exact = available.first(where: { $0.lowercased() == normalized }) { return exact }
        for script in ["zh-hans", "zh-hant"] where normalized.hasPrefix(script) {
            return available.first { $0.lowercased() == script }
        }
        let language = normalized.split(separator: "-").first.map(String.init) ?? normalized
        return available.first { $0.lowercased() == language }
    }
}
