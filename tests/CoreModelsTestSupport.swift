// Conversions from the Swift view models back into the core records, used by
// the bridge tests to seed state through the same commands the app issues.
//
// They live in the test target because nothing in the app converts in this
// direction: the app renders core's records, and core builds its own. Swift has
// no `#[cfg(test)]`, so the target boundary is the gate.
import Foundation
import SpectraCore

@testable import Spectra

extension WalletState {
    /// A wallet record with every field a test does not name defaulted. The
    /// app never builds one; core returns them.
    init(
        id: UUID = UUID(),
        name: String,
        chainId: Chain,
        address: String? = nil,
        xpub: String? = nil,
        derivationPath: String? = nil,
        derivationFlags: WalletDerivationFlags = WalletDerivationFlags(passphrase: false, hmacKey: false, uniformExpansion: false),
        holdings: [AssetHolding] = [],
        includeInPortfolioTotal: Bool = true,
        signing: WalletSigning = .watchOnly
    ) {
        self.init(
            id: id.uuidString, name: name, signing: signing, chainId: chainId,
            includeInPortfolioTotal: includeInPortfolioTotal,
            address: address,
            xpub: xpub,
            derivationPath: derivationPath,
            derivationProfile: nil,
            derivationFlags: derivationFlags,
            holdings: holdings,
            restoreHeight: nil,
            hiddenHoldings: [],
            icpPrincipal: nil,
            nearAccountKey: nil,
            multisigPolicy: nil
        )
    }
}

extension TransactionRecord {
    /// A record with every field a test does not name left empty. The app never
    /// builds one — core records what was sent and fetched.
    init(
        id: String, walletId: String? = nil, deploymentId: String? = nil, kind: TransactionKind,
        status: TransactionStatus, walletName: String, assetDisplayName: String, symbol: String,
        chainId: Chain, amount: String, address: String, transactionHash: String? = nil,
        nonce: Int64? = nil, failureReason: TransactionFailure? = nil,
        direction: TransactionDirection = .neutral, submitted: Bool? = nil
    ) {
        self.init(
            actions: TransactionActions(recheckUnavailableReason: "Not evaluated", rebroadcastUnavailableReason: "Not evaluated"),
            direction: direction, submitted: submitted ?? (kind != .receive),
            deploymentId: deploymentId, id: id, walletId: walletId, kind: kind, status: status,
            walletName: walletName, assetDisplayName: assetDisplayName, symbol: symbol,
            chainId: chainId, amount: amount, address: address, transactionHash: transactionHash,
            nonce: nonce, receiptBlockNumber: nil, receiptGasUsed: nil,
            receiptEffectiveGasPriceGwei: nil, receiptNetworkFee: nil,
            feeRateDescription: nil, confirmationCount: nil, confirmedNetworkFee: nil,
            usedChangeOutput: nil, sourceDerivationPath: nil,
            changeDerivationPath: nil, sourceAddress: nil, changeAddress: nil,
            failureReason: failureReason, historySource: nil,
            createdAtUnix: Date().timeIntervalSince1970)
    }
}

extension AssetHolding {
    /// A holding as core would project it. The id follows core's
    /// `deployment_id` for the EVM-style contracts these tests use.
    static func fixture(
        name: String, symbol: String, coingeckoId: String = "", chainId: Chain, tokenStandard: TokenStandard? = nil,
        contractAddress: String? = nil, amount: String
    ) -> AssetHolding {
        let id = contractAddress.map { "\(chainId.id):\(tokenStandard?.name.lowercased() ?? ""):\($0.lowercased())" } ?? "\(chainId.id):native"
        return AssetHolding(
            id: id, name: name, symbol: symbol, coingeckoId: coingeckoId, chainId: chainId,
            tokenStandard: tokenStandard, contractAddress: contractAddress, amount: amount)
    }
}

@MainActor
extension WalletDiagnosticsState {
    func flushPendingPersistence() async { await pendingCommand?.value }
}

extension SendProgress {
    /// A staged send as a test sets it up. Core decides the status and the
    /// next step; a test names them, or takes the ones the artifact's stage,
    /// submissions and record first reach.
    static func staged(
        _ artifact: SendArtifact, transaction: TransactionRecord? = nil, status: SendStatus? = nil,
        next: SendNextStep? = nil, canRebroadcast: Bool = false, canRepair: Bool = false,
        canRecheck: Bool = false
    ) -> SendProgress {
        let reached: SendNextStep =
            artifact.stage == .prepared ? .sign
            : artifact.attempts.contains { $0.outcome == .accepted } ? .done
            : artifact.attempts.isEmpty ? .broadcast : .rebroadcast
        let settled = artifact.attempts.isEmpty ? nil : transaction?.status
        let stands: SendStatus =
            settled == .confirmed ? .confirmed
            : settled == .failed ? .failed
            : artifact.stage == .prepared ? .awaitingSignature
            : artifact.attempts.isEmpty ? .signed
            : artifact.attempts.contains { $0.outcome == .accepted } ? .awaitingConfirmation
            : artifact.attempts.contains { $0.outcome == .uncertain } ? .uncertain : .rejected
        return SendProgress(
            artifact: artifact, transaction: transaction, status: status ?? stands,
            next: next ?? reached, canRebroadcast: canRebroadcast, canRepair: canRepair,
            canRecheck: canRecheck)
    }
}
