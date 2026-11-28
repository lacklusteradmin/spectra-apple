import SpectraCore
import SwiftUI

/// Every token the wallet's address holds, as core reads it from the
/// network's indexer, and adding one the token list lacks. Core marks each
/// token the list tracks; an untracked one is named by its contract alone,
/// and its name and symbol are the user's to give.
struct WalletHeldTokensView: View {
    let store: AppState
    let wallet: WalletState
    @State private var tokens: [WalletHeldToken]?
    @State private var error: String?
    @State private var isLoading = false

    var body: some View {
        List {
            if let tokens {
                if tokens.isEmpty {
                    WalletToolEmptySection(message: AppLocalization.string("This address holds no tokens."))
                } else {
                    Section {
                        ForEach(tokens, id: \.contract) { row($0) }
                    } footer: {
                        Text(AppLocalization.string("A token not in Known Tokens is shown by its contract: anyone can send a token that calls itself anything. Add one you recognize to see its balance in the wallet."))
                    }
                }
            } else if let error {
                WalletToolErrorSection(message: error)
            } else {
                WalletToolLoadingSection()
            }
        }
        .navigationTitle(WalletAction.heldTokens.title).inlineNavigationTitle()
        .pageRefreshable { await load() }
        // Read again once a token is added, so it reads as tracked.
        .task(id: store.tokenPreferences.tokens.count) { await load() }
    }

    private func row(_ token: WalletHeldToken) -> some View {
        VStack(alignment: .leading, spacing: SpectraLayout.Space.xs) {
            HStack {
                if token.isTracked {
                    Text(verbatim: token.symbol).font(.subheadline.weight(.semibold))
                } else {
                    Text(AppLocalization.string("Unknown Token")).font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(verbatim: token.balance).font(.subheadline).monospacedDigit()
            }
            Text(verbatim: token.contract).font(.caption2.monospaced()).foregroundStyle(.secondary)
                .lineLimit(1).truncationMode(.middle).textSelection(.enabled)
            if !token.isTracked {
                NavigationLink {
                    AddCustomTokenView(
                        tokens: store.tokenPreferences, held: HeldTokenDraft(chain: wallet.chainId, token: token))
                } label: {
                    Text(AppLocalization.string("Add to Known Tokens")).font(.caption.weight(.semibold))
                }
            }
        }.padding(.vertical, SpectraLayout.Space.xxs)
    }

    private func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            tokens = try await store.bridge.ready().walletHeldTokens(walletId: wallet.id)
            error = nil
        } catch {
            self.error = userErrorMessage(error)
        }
    }
}

/// A held token the token list lacks, to add as a custom token: its network,
/// protocol, contract and places are the network's.
struct HeldTokenDraft {
    let chain: Chain
    let token: WalletHeldToken
}
