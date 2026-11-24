import Foundation
import SpectraCore

/// One run of core's funds scan: Funds Finder's, across every network a
/// phrase restores on, or a network page's used-account list, on one. What
/// it read is this run's: starting again or cancelling drops it, and the
/// screen that owns the run cancels it when it closes.
@MainActor
@Observable
final class FundsScanRun {
    /// Every address read so far, in the order core read them.
    private(set) var reads: [FundsScanRead] = []
    private(set) var checked = 0
    private(set) var total = 0
    private(set) var isRunning = false
    /// Why the scan itself stopped.
    private(set) var error: String?
    @ObservationIgnored private var task: Task<Void, Never>?

    /// The share of the candidates read so far.
    var progress: Double { total == 0 ? 0 : Double(checked) / Double(total) }
    /// The accounts read as used: funded, or with history.
    var used: [FundsScanRead] { reads.filter(\.used) }
    /// Why each network's addresses could not be read: the first failure on
    /// it, worded like any other failed call, in registry order.
    var unreadChains: [(chain: Chain, reason: String)] {
        var reasons: [Chain: String] = [:]
        for read in reads {
            if let error = read.error, reasons[read.candidate.chainId] == nil {
                reasons[read.candidate.chainId] = userErrorMessage(error)
            }
        }
        return Chain.all.compactMap { chain in reasons[chain].map { (chain, $0) } }
    }

    /// Derives the candidate addresses of `request` — on `chain`, or on every
    /// network that restores the phrase — and contacts nothing. Deriving is
    /// synchronous work in core, so it runs off the main actor.
    static func begin(_ request: FundsFinderRequest, chain: Chain?, service: WalletService) async throws -> FundsScan {
        try await Task.detached { try service.beginFundsScan(request: request, chainId: chain) }.value
    }

    /// Scans `request` from the start, in place of what an earlier run read.
    /// A scan session is consumed as it runs, so each run begins its own.
    func start(_ request: FundsFinderRequest, chain: Chain?, bridge: WalletServiceBridge) {
        cancel()
        isRunning = true
        task = Task { [weak self] in await self?.run(request, chain: chain, bridge: bridge) }
    }

    /// Stops the run and drops what it read.
    func cancel() {
        task?.cancel()
        task = nil
        reads = []
        checked = 0
        total = 0
        isRunning = false
        error = nil
    }

    /// A cancelled run writes nothing: `cancel` has already reset the state,
    /// and a new run may own it.
    private func run(_ request: FundsFinderRequest, chain: Chain?, bridge: WalletServiceBridge) async {
        do {
            let scan = try await Self.begin(request, chain: chain, service: bridge.service())
            while !Task.isCancelled {
                let batch = await scan.nextBatch()
                guard !Task.isCancelled else { return }
                total = Int(batch.total)
                checked = Int(batch.checked)
                reads.append(contentsOf: batch.reads)
                if batch.complete { break }
            }
        } catch {
            guard !Task.isCancelled else { return }
            self.error = userErrorMessage(error)
        }
        if !Task.isCancelled { isRunning = false }
    }
}
