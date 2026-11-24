import Foundation
import SpectraCore
import SwiftUI
import Testing

@testable import Spectra

@MainActor
@Suite(.isolatedAppState, .serialized)
struct StakingRenderTests: IsolatedAppStateSuite {
    enum RenderStage: String, CaseIterable {
        case positions, queuedRewards, prepared, withdrawalFees, signed, pending, confirmed, recovery, repaired
    }

    @Test(arguments: RenderStage.allCases)
    func reviewAndPositionsRenderWithoutSigningOrSubmitting(stage: RenderStage) async throws {
        let store = makeState()
        var operations = StakingTestSupport.operations()
        var signed = false
        var broadcast = false
        operations.sign = { _, _, _ in
            signed = true
            return StakingTestSupport.artifact(stage: .signed)
        }
        operations.broadcast = { _, _ in
            broadcast = true
            return StakingTestSupport.artifact(stage: .signed, submitted: true)
        }
        let chain: Chain = [.queuedRewards, .recovery, .withdrawalFees, .repaired].contains(stage) ? .icp : .solana
        let staking = StakingState(chain: chain, bridge: bridge, operations: operations)
        staking.selectWallet("wallet")
        var artifact = StakingTestSupport.artifact(
            stage: [.prepared, .withdrawalFees, .repaired].contains(stage) ? .prepared : .signed,
            submitted: stage == .pending || stage == .confirmed || stage == .recovery, chain: chain)
        if stage == .withdrawalFees {
            artifact.staking?.action = .withdraw
            artifact.staking?.positionId = "42"
            artifact.review.networkFee = NetworkFee(amount: "0.0001", bound: .exact, value: nil)
            artifact.review.staking?.refundableDeposit = nil
            artifact.review.staking?.feeIsDeductedFromAmount = true
        }
        if stage == .repaired {
            artifact.revision = 2
            artifact.reviewDigest = "reviewed-recovery"
            artifact.staking?.lockupSeconds = 600
            artifact.review.staking?.lockupSeconds = nil
            artifact.review.networkFee = NetworkFee(amount: "0", bound: .exact, value: nil)
            artifact.review.staking?.refundableDeposit = nil
            artifact.review.staking?.fundingAlreadyCompleted = true
        }
        var progress = StakingTestSupport.progress(artifact)
        staking.session.endpoints = ["node-a", "node-b"]
        staking.positions = [StakingTestSupport.position()]
        if stage == .queuedRewards {
            staking.positions[0].pendingRewardsSmallestUnit = "123456789"
            staking.positions[0].rewardsUnlockTimeUnix = 1_800_604_800
        }
        staking.hasLoadedPositions = true
        if stage == .confirmed {
            progress = .staged(
                artifact, transaction: StakingTestSupport.transaction(status: .confirmed), next: .done)
        }
        if stage == .recovery {
            progress = .staged(
                artifact, transaction: StakingTestSupport.transaction(status: .failed), next: .done, canRepair: true)
        }
        staking.session.progress = progress
        let view = ScrollView {
            if stage == .positions || stage == .queuedRewards {
                StakingPositionsView(staking: staking, canSign: true, requiresPassword: false, hidesBalances: false)
            } else {
                StakingTransactionView(
                    store: store, staking: staking, progress: progress,
                    confirmsSigning: .constant(false), confirmsBroadcast: .constant(false))
            }
        }.frame(width: RenderWindow.phoneSize.width, height: RenderWindow.phoneSize.height).background(.background)
        let window = try RenderWindow()
        defer { window.close() }
        window.show(view)
        try await Task.sleep(for: .milliseconds(300))
        window.layout()
        try window.record(named: "Staking: \(stage.rawValue)")
        #expect(!signed && !broadcast, "Rendering must never use a key or submit a transaction")
        #expect(staking.session.artifact == artifact)
        #expect(staking.session.selectedEndpoints.isEmpty)
        #expect(staking.password.isEmpty)
    }
}
