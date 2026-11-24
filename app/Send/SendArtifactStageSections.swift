import SpectraCore
import SwiftUI

/// The password, signing and broadcast sections of a page that reviews one
/// core-built transaction itself, such as an approval revocation or an
/// account closing. Core keeps the artifact and says which step comes next;
/// `session` adopts its answers.
struct SendArtifactStageSections: View {
    let store: AppState
    let wallet: WalletState
    let session: SendSession
    /// Why the device asks to authenticate before signing.
    let authenticationReason: String
    /// What the page says once the transaction is submitted, until the chain
    /// settles it.
    let submittedText: String
    /// Whether the page's own confirmation lets the transaction be signed.
    var canSign = true
    @State private var password = ""

    private var needsPassword: Bool { wallet.signing.requiresPassword }

    var body: some View {
        if let progress = session.progress {
            switch progress.next {
            case .sign:
                if needsPassword {
                    Section {
                        SecureField(AppLocalization.string("Wallet Password"), text: $password)
                            .textInputAutocapitalization(.never).autocorrectionDisabled().privacySensitive()
                    }
                }
                Section {
                    Button(AppLocalization.string("Sign Transaction")) {
                        Task {
                            await session.sign(
                                password: needsPassword ? password : nil,
                                authenticate: { await store.authenticate(.send, reason: authenticationReason) },
                                sign: { try await store.bridge.ready().signSend(id: $0, reviewDigest: $1, password: $2) })
                            password = ""
                        }
                    }.disabled(!canSign || session.isBusy || (needsPassword && password.isEmpty))
                }.onDisappear { password = "" }
            case .broadcast, .rebroadcast:
                Section {
                    BroadcastNodePicker(session: session)
                    Button(AppLocalization.string(progress.next.title)) {
                        Task {
                            if await session.broadcast(submit: {
                                try await store.bridge.ready().broadcastSend(id: $0, endpoints: $1)
                            }) != nil {
                                _ = await store.refreshTransactionProjection()
                            }
                        }
                    }.disabled(session.isBusy || session.selectedEndpoints.isEmpty
                               || (progress.next == .rebroadcast && !progress.canRebroadcast))
                }
                if !progress.artifact.attempts.isEmpty {
                    Section {
                        SendStatusLabel(status: progress.status)
                        SubmissionResults(progress: progress)
                    }
                }
            case .done:
                Section {
                    SendStatusLabel(status: progress.status)
                    if !progress.status.isSettled {
                        Text(submittedText).font(.subheadline).foregroundStyle(.secondary)
                    }
                    if let hash = progress.transaction?.transactionHash ?? progress.artifact.transactionHash {
                        TransactionHashRow(hash: hash)
                    }
                }
            }
        }
        if session.isBusy {
            Section { ProgressView().frame(maxWidth: .infinity) }
        }
        if let error = session.error {
            Section { Text(error).foregroundStyle(.red) }
        }
    }
}

extension View {
    /// A send sheet's way out: Cancel, where Cancel goes, until the
    /// transaction is out of the stages' hands; then Done, where Done goes.
    /// "Done" before anything was done read as a confirmation of nothing.
    func sendSheetDismissal(session: SendSession, dismiss: @escaping () -> Void) -> some View {
        toolbar {
            if session.progress?.next == .done {
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppLocalization.string("Done"), action: dismiss)
                }
            } else {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppLocalization.string("Cancel"), action: dismiss)
                }
            }
        }
    }
}
