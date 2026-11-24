import SpectraCore
import SwiftUI

/// One account the scan found used: funded, or with history.
struct FundsFinderHit: Identifiable {
    let read: FundsScanRead
    var id: FundsFinderCandidate { read.candidate }
    var candidate: FundsFinderCandidate { read.candidate }
    /// The balance, or `nil` for an account used and since emptied.
    var balanceDisplay: String? { read.funded ? read.balance?.amountDisplay : nil }
}

/// Scan a seed's derivation paths for funded addresses.
///
/// The scan's state is this screen's: nothing else reads it, and leaving the
/// screen cancels it. Importing a found account is not leaving: the import
/// opens over this screen, and the results are still here on the way back,
/// for the next account to import.
struct FundsFinderView: View {
    let store: AppState
    /// The same entry the import page reads a phrase with, so a phrase the
    /// import would refuse is not scanned here either.
    @State private var seedEntry = SeedPhraseEntry()
    @State private var passphrase: String = ""
    @State private var showPassphrase: Bool = false
    @State private var hasStarted: Bool = false
    @State private var run = FundsScanRun()
    @State private var isImportingAll = false

    private var canStart: Bool { seedEntry.verdict.isValid && !run.isRunning }
    private var hits: [FundsFinderHit] { run.used.map(FundsFinderHit.init) }

    var body: some View {
        ZStack {
            SpectraBackdrop().ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: SpectraLayout.Space.m) {
                    if !hasStarted {
                        inputSection
                    } else {
                        scanProgressSection
                        if !hits.isEmpty {
                            hitsSection
                        }
                        ForEach(run.unreadChains, id: \.chain) { unread in
                            errorBanner(AppLocalization.format(
                                "%@ addresses could not be checked: %@", unread.chain.displayName, unread.reason))
                        }
                        if let error = run.error {
                            errorBanner(error)
                        }
                        // Unread addresses are not empty ones.
                        if !run.isRunning && hits.isEmpty && run.error == nil && run.unreadChains.isEmpty {
                            emptyResultsSection
                        }
                    }
                }
                .spectraScreenPadding()
            }
        }
        .navigationTitle(AppLocalization.string("Funds Finder"))
        .inlineNavigationTitle()
        .toolbar {
            if hasStarted && !run.isRunning {
                ToolbarItem(placement: .barTrailing) {
                    // Back to the phrase as it was: the next scan is most often
                    // the same phrase with a passphrase, or one word fixed.
                    Button(AppLocalization.string("New Scan")) {
                        run.cancel()
                        hasStarted = false
                    }
                }
            }
        }
        .onDisappear {
            // Covered by the import it opened, not closed.
            guard !store.walletImport.isPresented else { return }
            run.cancel()
        }
        .navigationDestination(
            isPresented: Binding(
                get: { store.walletImport.isPresented && store.walletImport.editingWalletId == nil },
                set: { isPresented in
                    if !isPresented { store.walletImport.isPresented = false }
                }
            )
        ) {
            SetupView(store: store, draft: store.walletImport.draft)
        }
    }

    /// A found account opens the single-wallet import on its network, with
    /// the phrase, passphrase, profile and account it was found at.
    private func importHit(_ hit: FundsFinderHit) {
        let words = seedEntry.verdict.words
        let passphrase = passphrase
        store.walletImport.begin { $0.configure(foundAccount: hit.candidate, words: words, passphrase: passphrase) }
    }

    // MARK: - Input section

    private var inputSection: some View {
        VStack(spacing: SpectraLayout.Space.m) {
            headerCard
            seedPhraseCard
            passphraseCard
            disclaimerCard
            startButton
        }
    }

    private var headerCard: some View {
        HStack(alignment: .top, spacing: SpectraLayout.Space.m) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(.tint)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
                Text(AppLocalization.string("Scan All Derivation Paths"))
                    .font(.headline)
                Text(AppLocalization.string("Enter your seed phrase to check every network's derivation profiles at their first three accounts, revealing which accounts hold funds or have been used."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(SpectraLayout.Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }

    private var seedPhraseCard: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            Text(AppLocalization.string("Seed Phrase")).font(.subheadline.weight(.semibold))
            SeedPhraseEntryView(entry: seedEntry)
        }
        .padding(SpectraLayout.Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
        .secretShield()
    }

    private var passphraseCard: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.s) {
            HStack {
                Text(AppLocalization.string("BIP-39 Passphrase")).font(.subheadline.weight(.semibold))
                Spacer()
                Text(AppLocalization.string("Optional")).font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Group {
                    if showPassphrase {
                        TextField(AppLocalization.string("Leave blank if none"), text: $passphrase)
                    } else {
                        SecureField(AppLocalization.string("Leave blank if none"), text: $passphrase)
                    }
                }
                .font(.body)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                Button {
                    showPassphrase.toggle()
                } label: {
                    Image(systemName: showPassphrase ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppLocalization.string(showPassphrase ? "Hide" : "Show"))
            }
            .padding(SpectraLayout.Space.m)
            .spectraInputFieldStyle(cornerRadius: SpectraLayout.Radius.inner)
            Text(AppLocalization.string("A passphrase creates a different wallet. Leave blank unless you set one up."))
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(SpectraLayout.Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }

    private var disclaimerCard: some View {
        HStack(alignment: .top, spacing: SpectraLayout.Space.s) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(.green)
                .font(.subheadline)
            Text(AppLocalization.string("fundsFinder.privacy"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(SpectraLayout.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }

    private var startButton: some View {
        Button {
            guard canStart else { return }
            hasStarted = true
            run.start(
                FundsFinderRequest(seedPhrase: seedEntry.phrase, passphrase: passphrase.isEmpty ? nil : passphrase),
                chain: nil, bridge: store.bridge)
        } label: {
            Label(AppLocalization.string("Start Scan"), systemImage: "magnifyingglass")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 46)
        }
        .buttonStyle(.glassProminent)
        .disabled(!canStart)
    }

    // MARK: - Progress section

    private var scanProgressSection: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.m) {
            HStack {
                if run.isRunning {
                    SpectraLoadingGlyph(size: 26, tint: .accentColor)
                    Text(AppLocalization.string("Scanning…"))
                        .font(.headline)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(AppLocalization.string("Scan Complete"))
                        .font(.headline)
                }
                Spacer()
                if run.total > 0 {
                    Text(AppLocalization.format("%lld / %lld", run.checked, run.total))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            if run.total > 0 {
                ProgressView(value: run.progress)
                    .progressViewStyle(.linear)
            }
            if run.isRunning {
                Text(AppLocalization.string("Checking addresses across all derivation paths…"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if hits.isEmpty, run.unreadChains.isEmpty {
                Text(AppLocalization.format("Checked %lld paths — no funds found", count: run.checked, run.checked))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if !hits.isEmpty {
                Text(AppLocalization.format("Found %lld paths with funds across %lld checked",
                    count: hits.count, hits.count, run.checked))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(SpectraLayout.Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }

    // MARK: - Hits section

    private var hitsSection: some View {
        SpectraRowGroup(
            title: AppLocalization.format("%lld paths with funds found", count: hits.count, hits.count),
            data: hits, dividerInset: SpectraLayout.rowHorizontal,
            footer: {
                // Every found account at once, each its own wallet — the
                // scan's usual end is more than one.
                if hits.count > 1, !run.isRunning {
                    Divider().opacity(SpectraLayout.dividerOpacity)
                    Button {
                        isImportingAll = true
                    } label: {
                        Label(AppLocalization.format("Import All %lld", hits.count), systemImage: "square.and.arrow.down.on.square")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .spectraRowPadding()
                    }
                    .buttonStyle(.plain).foregroundStyle(.tint)
                }
            }
        ) { hit in
            FundsFinderHitRow(hit: hit) { importHit(hit) }
        }
        .pageSheet(isPresented: $isImportingAll) {
            let words = seedEntry.verdict.words
            let passphrase = passphrase
            ImportAllFoundSheet(store: store, hits: hits) { hit, password in
                WalletImportDraft.importCommit(
                    foundAccount: hit.candidate, words: words, passphrase: passphrase, password: password)
            }
        }
    }

    private var emptyResultsSection: some View {
        SpectraEmptyStateCard(
            title: AppLocalization.string("No funds found"),
            message: AppLocalization.string("No balance was detected at any of the scanned derivation paths. Double-check your seed phrase and try with a BIP-39 passphrase if you set one."),
            systemImage: "tray")
    }

    @ViewBuilder
    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: SpectraLayout.Space.s) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.spectraWarning)
            Text(message).font(.caption).foregroundStyle(.secondary)
        }
        .padding(SpectraLayout.Space.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .spectraCardFill()
    }
}

// MARK: - Hit row

private struct FundsFinderHitRow: View {
    let hit: FundsFinderHit
    let importAccount: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
            HStack {
                VStack(alignment: .leading, spacing: SpectraLayout.Space.xxs) {
                    Text(hit.candidate.chainName)
                        .font(.subheadline.weight(.semibold))
                    if let profile = hit.candidate.profileTitle {
                        Text(profile)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(hit.balanceDisplay ?? AppLocalization.string("Used"))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.tint)
            }
            Text(hit.candidate.derivationPath)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack(spacing: SpectraLayout.Space.xs) {
                Text(hit.candidate.address)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer(minLength: SpectraLayout.Space.xs)
                CopyButton(value: hit.candidate.address)
            }
            Button(AppLocalization.string("Import This Account"), action: importAccount)
                .font(.caption.weight(.semibold)).buttonStyle(.glass)
        }
        .spectraRowPadding()
    }
}

/// Importing every found account: one optional password for them all, then
/// each import in turn and what core said to it.
private struct ImportAllFoundSheet: View {
    let store: AppState
    let hits: [FundsFinderHit]
    let commit: (FundsFinderHit, String) -> WalletImportCommit?
    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var confirmation = ""
    @State private var importingIndex: Int?
    /// Each account's answer, by its hit, once its import has run.
    @State private var results: [FundsFinderCandidate: String?] = [:]
    @State private var isFinished = false

    private var passwordProblem: String? {
        guard let reason = validateWalletPassword(password: password, confirmation: confirmation) else { return nil }
        switch reason {
        case .tooShort(let minChars):
            return AppLocalization.format("Wallet password must be at least %lld characters, or leave it blank.", Int(minChars))
        case .confirmationMismatch: return AppLocalization.string("Wallet password confirmation does not match.")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(hits) { hit in
                        HStack(spacing: SpectraLayout.Space.s) {
                            VStack(alignment: .leading, spacing: SpectraLayout.Space.xxs) {
                                Text(hit.candidate.chainName).font(.subheadline.weight(.semibold))
                                Text(hit.candidate.derivationPath).font(.caption.monospaced()).foregroundStyle(.secondary)
                                if case .some(.some(let refusal)) = results[hit.id] {
                                    Label(refusal, systemImage: "exclamationmark.triangle.fill").font(.caption).foregroundStyle(.red)
                                }
                            }
                            Spacer(minLength: SpectraLayout.Space.s)
                            status(of: hit)
                        }
                    }
                } footer: {
                    Text(AppLocalization.string("fundsFinder.importAll.footer"))
                }
                if !isFinished {
                    Section {
                        SecureField(AppLocalization.string("import_flow.wallet_password_field"), text: $password)
                        SecureField(AppLocalization.string("import_flow.wallet_password_confirmation_field"), text: $confirmation)
                    } header: {
                        Text(AppLocalization.string("import_flow.wallet_password_optional"))
                    } footer: {
                        if let passwordProblem {
                            Label(passwordProblem, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.red)
                        } else {
                            Text(AppLocalization.string("import_flow.wallet_password_subtitle"))
                        }
                    }
                    .disabled(importingIndex != nil)
                }
            }
            .navigationTitle(AppLocalization.string("Import All"))
            .inlineNavigationTitle()
            .toolbar {
                if isFinished {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(AppLocalization.string("Done")) { dismiss() }
                    }
                } else {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(AppLocalization.string("Cancel")) { dismiss() }.disabled(importingIndex != nil)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(AppLocalization.string("Import"), action: importAll)
                            .disabled(importingIndex != nil || passwordProblem != nil)
                    }
                }
            }
            .interactiveDismissDisabled(importingIndex != nil)
        }
    }

    @ViewBuilder
    private func status(of hit: FundsFinderHit) -> some View {
        switch results[hit.id] {
        case .some(.none):
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                .accessibilityLabel(AppLocalization.string("Imported"))
        case .some(.some):
            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                .accessibilityLabel(AppLocalization.string("Not imported"))
        case .none:
            if let importingIndex, hits.indices.contains(importingIndex), hits[importingIndex].id == hit.id {
                ProgressView()
            }
        }
    }

    private func importAll() {
        let password = password
        let commits = hits.map { commit($0, password) }
        importingIndex = 0
        Task {
            let built = commits.compactMap { $0 }
            let refusals = await store.importWallets(built) { importingIndex = $0 }
            var answers = refusals.makeIterator()
            for (hit, commit) in zip(hits, commits) {
                results[hit.id] = commit == nil
                    ? AppLocalization.string("Not imported") : (answers.next() ?? nil)
            }
            importingIndex = nil
            isFinished = true
            spectraNotificationHaptic(refusals.allSatisfy { $0 == nil } ? .success : .warning)
        }
    }
}
