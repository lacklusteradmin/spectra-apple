import Foundation
import SpectraCore
import SwiftUI

/// The settings tab: glass cards over the backdrop, like the other tabs,
/// grouped by what the user is looking after rather than by implementation.
struct SettingsView: View {
    @Bindable var store: AppState
    @ScaledMetric(relativeTo: .body) private var iconWidth: CGFloat = 28
    private let biometry = DeviceBiometry.current
    private enum Route: Hashable {
        case addressBook
        case knownTokens
        case appearance
        case priceAlerts
        case largeMovementAlerts
        case endpoints
        case explorers
        case diagnostics
        case operationalLogs
        case buyCryptoHelp
        case about
        case cryptoWiki
        case donate
        case tor
        case resetWallet
    }
    var body: some View {
        NavigationStack {
            ZStack {
                SpectraBackdrop().ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: SpectraLayout.sectionSpacing) {
                        securitySection
                        section(AppLocalization.string("Display")) {
                            settingsToggle(AppLocalization.string("Hide Balances"), systemImage: "eye.slash", isOn: preferenceBinding(\.hideBalances))
                            settingsToggle(
                                AppLocalization.string("Hide Small Balances"), systemImage: "line.3.horizontal.decrease",
                                isOn: preferenceBinding(\.hideSmallBalances))
                            settingsLink(AppLocalization.string("Appearance"), systemImage: "circle.lefthalf.filled", route: .appearance) {
                                Text(AppLocalization.string(store.preferences.appearanceMode.label)).foregroundStyle(.secondary)
                            }
                        }
                        section(AppLocalization.string("Notifications")) {
                            settingsLink(AppLocalization.string("Price Alerts"), systemImage: "bell.badge", route: .priceAlerts)
                            settingsToggle(
                                AppLocalization.string("Transaction Status Updates"), systemImage: "clock.badge.checkmark",
                                isOn: store.settingBinding(\.useTransactionStatusNotifications) {
                                    .useTransactionStatusNotifications(value: $0)
                                })
                            settingsLink(AppLocalization.string("Large Movement Alerts"), systemImage: "chart.line.uptrend.xyaxis", route: .largeMovementAlerts)
                        }
                        section(AppLocalization.string("Wallets & Data")) {
                            settingsLink(AppLocalization.string("Address Book"), systemImage: "book.closed", route: .addressBook)
                            settingsLink(AppLocalization.string("Known Tokens"), systemImage: "bitcoinsign.bank.building", route: .knownTokens)
                            currencyRow
                            settingsLink(AppLocalization.string("Endpoints"), systemImage: "network", route: .endpoints)
                            settingsLink(AppLocalization.string("Explorers"), systemImage: "safari", route: .explorers)
                        }
                        section(AppLocalization.string("Help & About")) {
                            settingsLink(AppLocalization.string("Where can I buy crypto?"), systemImage: "creditcard", route: .buyCryptoHelp)
                            settingsLink(AppLocalization.string("Crypto Wiki"), systemImage: "books.vertical", route: .cryptoWiki)
                            reportProblemRow
                            settingsLink(AppLocalization.string("About Spectra"), systemImage: "info.circle", route: .about)
                            settingsLink(AppLocalization.string("Donate"), systemImage: "heart", route: .donate)
                        }
                        section(AppLocalization.string("Developer")) {
                            settingsLink(AppLocalization.string("Diagnostics"), systemImage: "waveform.path.ecg.rectangle", route: .diagnostics)
                            settingsLink(AppLocalization.string("Operational Logs"), systemImage: "doc.text.magnifyingglass", route: .operationalLogs)
                        }
                        SpectraRowSection(dividerInset: dividerInset) {
                            settingsLink(AppLocalization.string("Reset Wallet"), systemImage: "trash", route: .resetWallet, tint: .red)
                        }
                    }.spectraScreenPadding()
                }.scrollBounceBehavior(.always)
            }
            .navigationTitle(AppLocalization.string("Settings"))
            .inlineNavigationTitle()
            .clearNavigationBar()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .addressBook: AddressBookView(store: store)
                case .knownTokens: TokenRegistrySettingsView(tokens: store.tokenPreferences)
                case .appearance: AppearanceSettingsView(preferences: store.preferences)
                case .priceAlerts: PriceAlertsView(store: store)
                case .largeMovementAlerts: LargeMovementAlertsSettingsView(store: store)
                case .endpoints: EndpointCatalogSettingsView(store: store)
                case .explorers: ExplorerSettingsView()
                case .diagnostics: DiagnosticsHubView(store: store)
                case .operationalLogs: LogsView(store: store)
                case .buyCryptoHelp: BuyCryptoHelpView()
                case .about: AboutView()
                case .cryptoWiki: CryptoWikiLibraryView()
                case .donate: DonationsView()
                case .tor: TorSettingsView(store: store)
                case .resetWallet: ResetWalletWarningView(store: store)
                }
            }
        }
    }

    /// Locking and confirming sends both ask the device owner, so neither
    /// does anything while the device check is off.
    private var securitySection: some View {
        let isProtected = store.preferences.useDeviceAuthentication
        return SpectraRowSection(
            title: AppLocalization.string("Security & Privacy"),
            footer: isProtected ? nil : AppLocalization.format("settings.security.off_footer_format", biometry.name),
            dividerInset: dividerInset
        ) {
            Toggle(isOn: preferenceBinding(\.useDeviceAuthentication)) {
                rowTitle(AppLocalization.format("Use %@", biometry.name), systemImage: biometry.symbol)
            }.spectraRowPadding()
            settingsToggle(AppLocalization.string("Auto Lock"), systemImage: "lock.rotation", isOn: preferenceBinding(\.useAutoLock))
                .disabled(!isProtected)
            Toggle(isOn: preferenceBinding(\.authenticateSends)) {
                rowTitle(AppLocalization.format("Confirm Sends with %@", biometry.name), systemImage: "checkmark.shield")
            }.spectraRowPadding().disabled(!isProtected)
            Button {
                store.isAppLocked = true
            } label: {
                rowLabel(AppLocalization.string("Lock Now"), systemImage: "lock")
            }
            .buttonStyle(.plain).disabled(!isProtected)
            settingsLink(AppLocalization.string("Tor Network"), systemImage: "network.badge.shield.half.filled", route: .tor) {
                TorStatusBadge(status: store.tor.status)
            }
        }
    }

    /// The display currency, chosen in place: a page that held one picker
    /// was a tap away from nothing else. A pricing read that fails is a
    /// notice on Home, with its Retry.
    private var currencyRow: some View {
        Menu {
            Picker(
                AppLocalization.string("Display Currency"),
                selection: store.settingBinding(\.fiatCurrency) { .fiatCurrency(value: $0) }
            ) {
                ForEach(FiatCurrency.allCases) { currency in Text(currency.displayName).tag(currency) }
            }
        } label: {
            HStack(spacing: SpectraLayout.Space.s) {
                rowTitle(AppLocalization.string("Display Currency"), systemImage: "dollarsign.circle")
                Spacer(minLength: SpectraLayout.Space.s)
                Text(verbatim: store.selectedFiatCurrency.code).foregroundStyle(.secondary)
                Image(systemName: "chevron.up.chevron.down").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .spectraRowPadding()
        }
        .buttonStyle(.plain)
    }

    private static let reportProblemURL = URL(string: "https://spectrawallet.org/bug/")!

    /// Opens the support page itself; the page in between held only its link.
    private var reportProblemRow: some View {
        Link(destination: Self.reportProblemURL) {
            HStack(spacing: SpectraLayout.Space.s) {
                rowTitle(AppLocalization.string("Report a Problem"), systemImage: "exclamationmark.bubble")
                Spacer(minLength: SpectraLayout.Space.s)
                Image(systemName: "arrow.up.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .spectraRowPadding()
        }
        .buttonStyle(.plain)
    }

    /// A divider starts under a row's title, past its icon.
    private var dividerInset: CGFloat { SpectraLayout.rowHorizontal + iconWidth + SpectraLayout.Space.m }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        SpectraRowSection(title: title, dividerInset: dividerInset, content: content)
    }

    private func preferenceBinding(_ keyPath: ReferenceWritableKeyPath<AppUserPreferences, Bool>) -> Binding<Bool> {
        Binding(
            get: { store.preferences[keyPath: keyPath] },
            set: { store.preferences[keyPath: keyPath] = $0 }
        )
    }

    private func rowTitle(_ title: String, systemImage: String, tint: Color? = nil) -> some View {
        HStack(spacing: SpectraLayout.Space.m) {
            Image(systemName: systemImage).foregroundStyle(tint ?? .accentColor).frame(width: iconWidth)
                .accessibilityHidden(true)
            Text(title).foregroundStyle(tint ?? .primary)
        }
    }

    /// A row that acts in place: no chevron, since it leads nowhere.
    private func rowLabel(_ title: String, systemImage: String) -> some View {
        rowTitle(title, systemImage: systemImage).spectraRowPadding()
    }

    private func settingsLink(_ title: String, systemImage: String, route: Route, tint: Color? = nil) -> some View {
        settingsLink(title, systemImage: systemImage, route: route, tint: tint) { EmptyView() }
    }

    /// A row that leads to a page, with what it is set to on the right.
    private func settingsLink<Trailing: View>(
        _ title: String, systemImage: String, route: Route, tint: Color? = nil, @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        NavigationLink(value: route) {
            HStack(spacing: SpectraLayout.Space.s) {
                rowTitle(title, systemImage: systemImage, tint: tint)
                Spacer(minLength: SpectraLayout.Space.s)
                trailing()
                Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .spectraRowPadding()
        }
        .buttonStyle(.plain)
    }

    private func settingsToggle(_ title: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            rowTitle(title, systemImage: systemImage)
        }.spectraRowPadding()
    }
}
