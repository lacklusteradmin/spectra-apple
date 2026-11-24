import Foundation
import SpectraCore
import Testing
import SwiftUI
@testable import Spectra

@MainActor
@Suite(.isolatedAppState, .serialized)
struct SendStagesViewTests: IsolatedAppStateSuite {

    enum RenderStage: String, CaseIterable {
        case prepared, signed, pending, confirmed
    }

    @Test(arguments: RenderStage.allCases)
    func durableStagesRenderWithoutChoosingOrSubmittingNodes(stage: RenderStage) async throws {
        let state = makeState()
        state.sendFlow.session.endpoints = ["https://ethereum.example/rpc"]
        let hasSubmission = stage == .pending || stage == .confirmed
        let hash = "0x3f5d2c8af442824595b091e1761b8db5bf8d9ef8fa93b512d283850d08a7ef11"
        let artifact = SendArtifact(id: "render-fixture", revision: 1,
            stage: stage == .prepared ? .prepared : .signed,
            walletId: "fixture", chainId: Chain.ethereumSepolia,
            sender: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
            recipient: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", memo: nil,
            amount: "0.25", asset: "ETH", symbol: "ETH", staking: nil, operation: nil, createdAt: 0, reviewDigest: "reviewed-content",
            review: SendArtifactReview(
                warnings: [.risk(warning: .newAddress), .ownAddress], staking: nil, transferTerms: nil,
                networkFee: NetworkFee(amount: "0.000021", bound: .estimate, value: nil)),
            preparedDetails: "Nonce: 7\nMaximum gas: 25200", signingPayloadHex: "02",
            signedPayload: stage == .prepared ? nil : "0x02…", transactionHash: hasSubmission ? hash : nil,
            attempts: hasSubmission ? [BroadcastAttempt(endpoint: "https://ethereum.example/rpc", attemptedAt: 0,
                outcome: .accepted, transactionHash: hash, detail: "Accepted by the node.")] : [], selectedEndpoints: [])
        #expect(artifact.reviewWarningMessages.count == 2)
        var record: TransactionRecord? = hasSubmission ? TransactionRecord(
            id: artifact.id, walletId: artifact.walletId, kind: .send,
            status: stage == .confirmed ? .confirmed : .pending,
            walletName: "Main Wallet", assetDisplayName: "Ethereum", symbol: artifact.symbol,
            chainId: artifact.chainId, amount: artifact.amount,
            address: artifact.recipient, transactionHash: hash) : nil
        record?.actions = TransactionActions(recheckUnavailableReason: nil,
            rebroadcastUnavailableReason: stage == .confirmed ? "Transaction is confirmed." : nil)
        let progress = SendProgress.staged(
            artifact, transaction: record, next: stage == .confirmed ? .done : nil,
            canRebroadcast: stage == .pending)
        state.sendFlow.session.progress = progress
        let view = ScrollView {
            SendStagesView(store: state, progress: progress).padding()
        }.frame(width: RenderWindow.phoneSize.width, height: RenderWindow.phoneSize.height).background(.background)
        // This independent render window never takes another parallel suite's key window.
        let window = try RenderWindow()
        defer { window.close() }
        // Lay out the hosting hierarchy before allowing its native compositor
        // to settle. Taking the first layout and snapshot together can omit glyphs.
        window.show(view)
        try await Task.sleep(for: .milliseconds(300))
        window.layout()
        try await Task.sleep(for: .milliseconds(100))
        try window.record(named: "Send stage: \(stage.rawValue)")
        #expect(state.sendFlow.session.selectedEndpoints.isEmpty, "Rendering must not select destinations or submit")
        #expect(state.sendFlow.session.artifact == artifact, "Rendering must leave the durable send unchanged")
    }

    /// A wallet tool's stage sections, in the form its sheet shows them: the
    /// nodes to choose, what they answered and where the transaction stands,
    /// from the same parts as a send's.
    @Test(arguments: [RenderStage.signed, .pending, .confirmed])
    func toolStageSectionsRenderWithoutSubmitting(stage: RenderStage) async throws {
        let state = makeState()
        let session = SendSession(progress: { .staged($0) })
        session.endpoints = ["https://ethereum.example/rpc"]
        let submitted = stage != .signed
        let hash = "0x3f5d2c8af442824595b091e1761b8db5bf8d9ef8fa93b512d283850d08a7ef11"
        let sender = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
        let artifact = SendArtifact(id: "tool-fixture", revision: 1, stage: .signed,
            walletId: "fixture", chainId: Chain.ethereumSepolia, sender: sender,
            recipient: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8", memo: nil,
            amount: "0", asset: "ETH", symbol: "ETH", staking: nil, operation: nil, createdAt: 0,
            reviewDigest: "reviewed-content",
            review: SendArtifactReview(warnings: [], staking: nil, transferTerms: nil,
                networkFee: NetworkFee(amount: "0.000021", bound: .estimate, value: nil)),
            preparedDetails: "", signingPayloadHex: "02", signedPayload: "0x02…",
            transactionHash: submitted ? hash : nil,
            attempts: submitted ? [BroadcastAttempt(endpoint: "https://ethereum.example/rpc", attemptedAt: 0,
                outcome: .accepted, transactionHash: hash, detail: "Accepted by the node.")] : [],
            selectedEndpoints: [])
        let record: TransactionRecord? = submitted ? TransactionRecord(
            id: artifact.id, walletId: artifact.walletId, kind: .revokeApproval,
            status: stage == .confirmed ? .confirmed : .pending, walletName: "Main Wallet",
            assetDisplayName: "Ethereum", symbol: artifact.symbol, chainId: artifact.chainId,
            amount: artifact.amount, address: artifact.recipient, transactionHash: hash) : nil
        session.progress = .staged(artifact, transaction: record, next: submitted ? .done : nil)
        let wallet = WalletState(
            name: "Main Wallet", chainId: .ethereumSepolia, address: sender,
            signing: .seedPhrase(passwordProtected: false))
        let view = Form {
            SendArtifactStageSections(
                store: state, wallet: wallet, session: session, authenticationReason: "Revoke",
                submittedText: "Submitted. The approval ends once it confirms.")
        }.frame(width: RenderWindow.phoneSize.width, height: RenderWindow.phoneSize.height)
        let window = try RenderWindow()
        defer { window.close() }
        window.show(view)
        try await Task.sleep(for: .milliseconds(300))
        window.layout()
        try await Task.sleep(for: .milliseconds(100))
        try window.record(named: "Tool stage: \(stage.rawValue)")
        #expect(session.selectedEndpoints.isEmpty, "Rendering must not select destinations or submit")
        #expect(session.artifact == artifact, "Rendering must leave the durable transaction unchanged")
    }

    /// What a token's own rules do is said before signing, in core's exact
    /// amounts and with the symbol of the coin each is paid in.
    @Test func transferTermWarningsAreWordedWithCoreAmounts() {
        let hook = "8vB8ZeymdzgkRnm9YPGMqAhNfCsc1vN5r5ga58GtYvb1"
        let fee = artifact(on: .solana, symbol: "FEE", warnings: [
            .tokenFee(fee: "0.005", received: "0.995"), .transferHook(program: hook),
        ]).reviewWarningMessages
        #expect(fee.count == 2)
        #expect(fee[0].contains(AmountPresentation.localizedDecimal("0.005"))
            && fee[0].contains(AmountPresentation.localizedDecimal("0.995")) && fee[0].contains("FEE"))
        #expect(fee[1].contains(hook))
        let carried = artifact(on: .cardano, symbol: "TEST", warnings: [.carriesNative(amount: "1.05508")])
            .reviewWarningMessages
        #expect(carried.count == 1)
        #expect(carried[0].contains(AmountPresentation.localizedDecimal("1.05508")) && carried[0].contains("ADA"))
        let registration = artifact(on: .near, symbol: "TEST", warnings: [.registersRecipient(deposit: "0.00125")])
            .reviewWarningMessages
        #expect(registration.count == 1)
        #expect(registration[0].contains(AmountPresentation.localizedDecimal("0.00125"))
            && registration[0].contains("NEAR"))
    }

    private func artifact(on chain: Chain, symbol: String, warnings: [ReviewWarning]) -> SendArtifact {
        SendArtifact(id: "terms-fixture", revision: 0, stage: .prepared,
            walletId: "fixture", chainId: chain, sender: "sender", recipient: "recipient", memo: nil,
            amount: "1", asset: "token", symbol: symbol,
            staking: nil, operation: nil, createdAt: 0, reviewDigest: "reviewed-content",
            review: SendArtifactReview(warnings: warnings, staking: nil, transferTerms: nil),
            preparedDetails: "", signingPayloadHex: "", signedPayload: nil, transactionHash: nil,
            attempts: [], selectedEndpoints: [])
    }
}
