import Foundation
import SpectraCore
import Testing

@testable import Spectra

@MainActor
@Suite(.isolatedAppState, .timeLimit(.minutes(1)))
struct StakingStateTests: IsolatedAppStateSuite {
    @Test func changingWalletDiscardsAnOldPositionResponse() async {
        var operations = StakingTestSupport.operations()
        let oldRead = SuspensionGate<[StakingPosition]>()
        operations.positions = { wallet, _, _, _ in
            wallet == "old" ? await oldRead.wait() : [StakingTestSupport.position("new-position")]
        }
        let staking = StakingState(chain: .solana, bridge: bridge, operations: operations)
        staking.selectWallet("old")
        let work = Task { await staking.loadWalletData() }
        await oldRead.reached()
        staking.selectWallet("new")
        await staking.loadWalletData()
        oldRead.resume([StakingTestSupport.position("old-position")])
        await work.value
        #expect(staking.walletId == "new")
        #expect(staking.positions.map(\.id) == ["new-position"])
        #expect(staking.hasLoadedPositions)
    }

    @Test func aLatePositionReadCannotReplaceANewerSnapshotForTheSameWallet() async {
        var operations = StakingTestSupport.operations()
        let oldRead = SuspensionGate<[StakingPosition]>()
        var reads = 0
        operations.positions = { _, _, _, _ in
            reads += 1
            if reads == 1 { return await oldRead.wait() }
            return [StakingTestSupport.position("current-position")]
        }
        let staking = StakingState(chain: .solana, bridge: bridge, operations: operations)
        staking.selectWallet("wallet")
        let old = Task { await staking.loadWalletData() }
        await oldRead.reached()
        await staking.loadWalletData()
        oldRead.resume([StakingTestSupport.position("obsolete-position")])
        await old.value
        #expect(staking.positions.map(\.id) == ["current-position"])
    }

    @Test func closingDuringPreparationAuthorizationNeverUsesTheWalletKey() async throws {
        var operations = StakingTestSupport.operations()
        var built = false
        operations.build = { _, _ in
            built = true
            return StakingTestSupport.artifact()
        }
        let authentication = SuspensionGate<String?>()
        let staking = StakingState(
            chain: .solana, bridge: bridge, operations: operations,
            authentication: { _ in await authentication.wait() })
        staking.selectWallet("wallet")
        staking.validatorId = "validator"
        staking.amount = "1"
        staking.password = "secret"
        staking.begin(.build)
        let id = try #require(staking.request?.id)
        let store = makeState()
        let work = Task { await staking.perform(id, store: store) }
        await authentication.reached()
        staking.cancel()
        authentication.resume(nil)
        await work.value
        #expect(!built)
        #expect(staking.session.artifact == nil)
        #expect(staking.password.isEmpty)
        #expect(!staking.isBusy)
    }

    @Test func closingDuringSigningAuthorizationNeverInvokesSigner() async throws {
        var operations = StakingTestSupport.operations()
        var signed = false
        operations.sign = { _, _, _ in
            signed = true
            return StakingTestSupport.artifact(stage: .signed)
        }
        let authentication = SuspensionGate<String?>()
        let staking = StakingState(
            chain: .solana, bridge: bridge, operations: operations,
            authentication: { _ in await authentication.wait() })
        staking.selectWallet("wallet")
        staking.session.progress = StakingTestSupport.progress(StakingTestSupport.artifact())
        staking.password = "secret"
        staking.begin(.sign)
        let id = try #require(staking.request?.id)
        let store = makeState()
        let work = Task { await staking.perform(id, store: store) }
        await authentication.reached()
        staking.selectWallet("other-wallet")
        authentication.resume(nil)
        await work.value
        #expect(!signed)
        #expect(staking.walletId == "other-wallet")
        #expect(staking.session.artifact == nil)
        #expect(staking.password.isEmpty)
    }

    @Test func buildSignAndBroadcastRequireSeparateIntentAndUseTheReviewedDigest() async throws {
        var operations = StakingTestSupport.operations()
        var builds = 0
        var signs = 0
        var broadcasts = 0
        var completed = false
        operations.build = { request, password in
            builds += 1
            #expect(request.walletId == "wallet")
            #expect(request.amount == "1.234567891")
            #expect(password == "build-password")
            return StakingTestSupport.artifact()
        }
        operations.sign = { id, digest, password in
            signs += 1
            #expect(id == "staking-review")
            #expect(digest == "immutable-review")
            #expect(password == "build-password", "The password typed once signs too")
            return StakingTestSupport.artifact(stage: .signed)
        }
        operations.broadcast = { id, endpoints in
            broadcasts += 1
            #expect(id == "staking-review")
            #expect(endpoints == ["node-b"])
            return StakingTestSupport.artifact(stage: .signed, submitted: true)
        }
        let staking = StakingState(
            chain: .solana, bridge: bridge, operations: operations,
            authentication: { _ in nil }, broadcastCompletion: { _ in completed = true })
        let store = makeState()
        staking.selectWallet("wallet")
        staking.validatorId = "validator"
        staking.amount = "1.234567891"
        staking.password = "build-password"
        staking.begin(.build)
        await staking.perform(try #require(staking.request?.id), store: store)
        #expect(builds == 1 && signs == 0 && broadcasts == 0)
        #expect(staking.session.selectedEndpoints.isEmpty)
        #expect(staking.password == "build-password")
        staking.begin(.sign)
        await staking.perform(try #require(staking.request?.id), store: store)
        #expect(signs == 1 && broadcasts == 0)
        #expect(staking.session.artifact?.stage == .signed)
        staking.session.selectedEndpoints = ["node-b"]
        staking.begin(.broadcast)
        await staking.perform(try #require(staking.request?.id), store: store)
        #expect(broadcasts == 1 && completed)
        #expect(staking.session.progress?.transaction?.status == .pending, "Acceptance never establishes confirmation")
    }

    @Test func broadcastCompletionSurvivesClosingTheScreen() async throws {
        var operations = StakingTestSupport.operations()
        let gate = SuspensionGate<SendArtifact>()
        operations.broadcast = { _, _ in await gate.wait() }
        var completedId: String?
        let staking = StakingState(
            chain: .solana, bridge: bridge, operations: operations,
            broadcastCompletion: { completedId = $0.id })
        staking.selectWallet("wallet")
        staking.session.progress = StakingTestSupport.progress(StakingTestSupport.artifact(stage: .signed))
        staking.session.endpoints = ["node-b"]
        staking.session.selectedEndpoints = ["node-b"]
        staking.begin(.broadcast)
        let id = try #require(staking.request?.id)
        let store = makeState()
        let work = Task { await staking.perform(id, store: store) }
        await gate.reached()
        staking.cancel()
        gate.resume(StakingTestSupport.artifact(stage: .signed, submitted: true))
        await work.value
        #expect(completedId == "staking-review")
        #expect(staking.session.artifact == nil)
    }
    @Test func privateStatusRecheckAuthorizesOnlyTheReadAndKeepsTheOriginalOperation() async throws {
        var operations = StakingTestSupport.operations()
        var reads = 0
        var keyActions = 0
        var authorizations = 0
        operations.build = { _, _ in
            keyActions += 1
            return StakingTestSupport.artifact()
        }
        operations.sign = { _, _, _ in
            keyActions += 1
            return StakingTestSupport.artifact(stage: .signed)
        }
        operations.broadcast = { _, _ in
            keyActions += 1
            return StakingTestSupport.artifact(stage: .signed, submitted: true)
        }
        operations.recheck = { id, password in
            reads += 1
            #expect(id == "staking-review")
            #expect(password == "read-password")
            return StakingTestSupport.artifact(stage: .signed, submitted: true, chain: .icp)
        }
        let staking = StakingState(
            chain: .icp, bridge: bridge, operations: operations,
            authentication: { _ in
                authorizations += 1
                return nil
            })
        staking.selectWallet("wallet")
        staking.session.progress = StakingTestSupport.progress(
            StakingTestSupport.artifact(stage: .signed, submitted: true, chain: .icp))
        staking.password = "read-password"
        staking.begin(.recheck)
        await staking.perform(try #require(staking.request?.id), store: makeState())
        #expect(reads == 1 && authorizations == 1)
        #expect(keyActions == 0, "A receipt query never signs or repeats a staking operation")
        #expect(staking.session.artifact?.id == "staking-review")
        #expect(staking.password == "read-password", "Kept for the page's next step")
    }

    @Test func aFailedBuildKeepsThePasswordAndShowsTheErrorAtTheForm() async throws {
        var operations = StakingTestSupport.operations()
        operations.build = { _, _ in
            throw SpectraBridgeError.InvalidInput(message: LocalizableMessage(template: "Wrong password", args: []))
        }
        let staking = StakingState(
            chain: .solana, bridge: bridge, operations: operations, authentication: { _ in nil })
        staking.selectWallet("wallet")
        staking.validatorId = "validator"
        staking.amount = "1"
        staking.password = "typo"
        staking.begin(.build)
        await staking.perform(try #require(staking.request?.id), store: makeState())
        #expect(staking.password == "typo")
        #expect(staking.stepError != nil)
        #expect(staking.positionsError == nil)
    }

    @Test func resumingLoadsTheSavedReviewWithoutBuildingOrSigningAgain() async throws {
        var operations = StakingTestSupport.operations()
        var keyActions = 0
        operations.build = { _, _ in
            keyActions += 1
            return StakingTestSupport.artifact()
        }
        operations.sign = { _, _, _ in
            keyActions += 1
            return StakingTestSupport.artifact(stage: .signed)
        }
        let restored = StakingTestSupport.artifact("saved-review", stage: .signed)
        operations.inspect = { id in
            #expect(id == "saved-review")
            return restored
        }
        let staking = StakingState(chain: .solana, bridge: bridge, operations: operations)
        staking.selectWallet("wallet")
        staking.begin(.resume("saved-review"))
        await staking.perform(try #require(staking.request?.id), store: makeState())
        #expect(staking.session.artifact == restored)
        #expect(staking.session.endpoints == ["node-a", "node-b"])
        #expect(staking.session.selectedEndpoints.isEmpty)
        #expect(keyActions == 0)
    }

    @Test func repairingAnInterruptedNeuronRequiresANewReviewAndSeparateSigningAndSubmission() async throws {
        var operations = StakingTestSupport.operations()
        var recovered = StakingTestSupport.artifact(chain: .icp)
        recovered.revision = 2
        recovered.reviewDigest = "reviewed-recovery"
        recovered.review.networkFee = NetworkFee(amount: "0", bound: .exact, value: nil)
        recovered.review.staking?.fundingAlreadyCompleted = true
        var repairs = 0
        var signs = 0
        var broadcasts = 0
        operations.repair = { id, password in
            repairs += 1
            #expect(id == "staking-review")
            #expect(password == "repair-password")
            return recovered
        }
        operations.sign = { id, digest, password in
            signs += 1
            #expect(id == "staking-review")
            #expect(digest == "reviewed-recovery")
            #expect(password == "repair-password", "The password typed once signs too")
            var signed = recovered
            signed.stage = .signed
            return signed
        }
        operations.broadcast = { _, nodes in
            broadcasts += 1
            #expect(nodes == ["node-b"])
            return StakingTestSupport.artifact(stage: .signed, submitted: true, chain: .icp)
        }
        let staking = StakingState(
            chain: .icp, bridge: bridge, operations: operations,
            authentication: { _ in nil }, broadcastCompletion: { _ in })
        let store = makeState()
        staking.selectWallet("wallet")
        staking.session.progress = .staged(
            StakingTestSupport.artifact(stage: .signed, submitted: true, chain: .icp),
            transaction: StakingTestSupport.transaction(status: .failed), next: .done, canRepair: true)
        staking.password = "repair-password"
        staking.begin(.repair)
        await staking.perform(try #require(staking.request?.id), store: store)
        #expect(repairs == 1 && signs == 0 && broadcasts == 0)
        #expect(staking.session.artifact == recovered)
        #expect(staking.session.selectedEndpoints.isEmpty)
        #expect(staking.session.progress?.transaction == nil)
        #expect(staking.password == "repair-password")
        staking.begin(.sign)
        await staking.perform(try #require(staking.request?.id), store: store)
        #expect(signs == 1 && broadcasts == 0)
        staking.session.selectedEndpoints = ["node-b"]
        staking.begin(.broadcast)
        await staking.perform(try #require(staking.request?.id), store: store)
        #expect(broadcasts == 1)
    }

    /// Repairing is core's to allow: a review core does not offer it on is
    /// not rebuilt, whatever its stage.
    @Test func repairWaitsForCoreToAllowIt() async throws {
        var operations = StakingTestSupport.operations()
        var repairs = 0
        operations.repair = { id, _ in
            repairs += 1
            return StakingTestSupport.artifact(id, chain: .icp)
        }
        let staking = StakingState(
            chain: .icp, bridge: bridge, operations: operations, authentication: { _ in nil })
        staking.selectWallet("wallet")
        staking.session.progress = .staged(
            StakingTestSupport.artifact(stage: .signed, submitted: true, chain: .icp),
            transaction: StakingTestSupport.transaction(status: .confirmed), next: .done, canRepair: false)
        staking.begin(.repair)
        await staking.perform(try #require(staking.request?.id), store: makeState())
        #expect(repairs == 0)
    }
}
