import SpectraCore
import SwiftUI

/// Find the accounts a phrase has used on the chosen network: core scans the
/// network's derivation profiles at the first accounts, reading balance and
/// history, or on TON each wallet version's account. The addresses go to a
/// provider before any wallet exists, so the sheet names the endpoints first
/// and scans only when asked. Choosing a used account sets the import's
/// profile and account, or its wallet version.
struct UsedAccountsSheet: View {
    let store: AppState
    @Bindable var draft: WalletImportDraft
    @Environment(\.dismiss) private var dismiss
    /// Where the scan would send its addresses, named before it runs; `nil`
    /// until core has derived them.
    @State private var endpoints: [FundsScanEndpoint]?
    @State private var candidateCount = 0
    /// Why the candidates could not be derived.
    @State private var preparationError: String?
    @State private var run = FundsScanRun()

    var body: some View {
        NavigationStack {
            List {
                if let error = preparationError ?? run.error {
                    Section { Text(error).foregroundStyle(.red) }
                }
                if let endpoints {
                    endpointsSection(endpoints)
                }
                if !run.reads.isEmpty {
                    Section(AppLocalization.string("Accounts")) {
                        ForEach(run.reads, id: \.candidate.address) { read in
                            readRow(read)
                        }
                    }
                }
            }
            .navigationTitle(AppLocalization.string("Find Used Accounts"))
            .inlineNavigationTitle()
            .toolbar {
                // Done, where Done goes: choosing an account has already
                // set it on the import.
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppLocalization.string("Done")) { dismiss() }
                }
            }
            .task { await prepare() }
            .onDisappear { run.cancel() }
        }
    }

    private func endpointsSection(_ endpoints: [FundsScanEndpoint]) -> some View {
        Section {
            ForEach(endpoints, id: \.endpoint) { endpoint in
                Text(endpoint.endpoint).font(.caption.monospaced()).textSelection(.enabled)
            }
            if endpoints.isEmpty {
                Text(AppLocalization.string("No endpoint is configured for this network.")).font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button(action: scan) {
                if run.isRunning {
                    HStack(spacing: SpectraLayout.Space.s) {
                        SpectraLoadingGlyph(size: 18, tint: .accentColor)
                        Text(AppLocalization.string("Scanning…"))
                    }
                } else {
                    Text(AppLocalization.string("Scan Accounts"))
                }
            }.disabled(run.isRunning || endpoints.isEmpty)
        } header: {
            Text(AppLocalization.format("Spectra will send %lld addresses to:", count: candidateCount, candidateCount))
        } footer: {
            Text(AppLocalization.string("Nothing is sent until you scan."))
        }
    }

    private func readRow(_ read: FundsScanRead) -> some View {
        Button {
            guard read.used, draft.derive(as: read.candidate) else { return }
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: SpectraLayout.Space.xxs) {
                HStack {
                    Text(read.candidate.profileTitle ?? "").font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(status(read)).font(.caption.weight(.semibold))
                        .foregroundStyle(read.used ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                }
                Text(read.candidate.address).font(.caption.monospaced()).foregroundStyle(.secondary)
                    .lineLimit(1).truncationMode(.middle)
                if let error = read.error {
                    Text(userErrorMessage(error)).font(.caption).foregroundStyle(.red.opacity(0.9))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!read.used)
    }

    private func status(_ read: FundsScanRead) -> String {
        if read.error != nil { return AppLocalization.string("Not read") }
        if read.funded, let balance = read.balance { return balance.amountDisplay }
        return AppLocalization.string(read.used ? "Used" : "Unused")
    }

    /// The scan the sheet runs: the import's phrase and passphrase, on its
    /// network.
    private var request: FundsFinderRequest {
        FundsFinderRequest(
            seedPhrase: draft.seedPhrase,
            passphrase: draft.overridePassphrase.isEmpty ? nil : draft.overridePassphrase)
    }

    /// Derive the candidates and name the endpoints; nothing is sent.
    private func prepare() async {
        guard endpoints == nil, let chain = draft.chain else { return }
        do {
            let begun = try await FundsScanRun.begin(request, chain: chain, service: store.bridge.service())
            candidateCount = begun.candidates().count
            endpoints = await begun.endpoints()
        } catch {
            preparationError = userErrorMessage(error)
        }
    }

    private func scan() {
        guard let chain = draft.chain else { return }
        run.start(request, chain: chain, bridge: store.bridge)
    }
}
