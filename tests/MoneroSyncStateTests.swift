import Foundation
import SpectraCore
import Testing
@testable import Spectra

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct MoneroSyncStateTests {
    private func status(height: UInt64) -> MoneroSyncStatus {
        MoneroSyncStatus(walletId: "wallet", scannedHeight: height, targetHeight: 100,
                         unlockedPiconeros: 0, complete: false, spendsKnown: true, usedSubaddresses: [])
    }

    @Test func cancelledBatchCannotOverwriteOrFinishRestartedScan() async throws {
        let moneroSync = MoneroSyncState()
        moneroSync.status = status(height: 0)
        moneroSync.password = "old password"
        moneroSync.begin()
        let oldRequest = try #require(moneroSync.requestId)
        let oldGate = SuspensionGate<Void>()
        let currentGate = SuspensionGate<Void>()
        let old = Task {
            await moneroSync.sync(request: oldRequest) { password, progress in
                #expect(password == "old password")
                await oldGate.wait()
                progress(self.status(height: 10))
                return "old failure"
            }
        }
        await oldGate.reached()
        moneroSync.cancel()
        old.cancel()
        moneroSync.password = "new password"
        moneroSync.begin()
        let currentRequest = try #require(moneroSync.requestId)
        let current = Task {
            await moneroSync.sync(request: currentRequest) { password, progress in
                #expect(password == "new password")
                progress(self.status(height: 20))
                await currentGate.wait()
                progress(self.status(height: 30))
                return nil
            }
        }
        await currentGate.reached()
        oldGate.resume()
        await old.value
        #expect(moneroSync.requestId == currentRequest)
        #expect(moneroSync.isRunning)
        #expect(moneroSync.password == "new password")
        #expect(moneroSync.status?.scannedHeight == 20)
        #expect(moneroSync.error == nil)
        currentGate.resume()
        await current.value
        #expect(!moneroSync.isRunning)
        #expect(moneroSync.password.isEmpty)
        #expect(moneroSync.status?.scannedHeight == 30)
        #expect(moneroSync.error == nil)
    }

    @Test func cancelledRunCannotSubmitAfterItsTaskWasQueued() async throws {
        let moneroSync = MoneroSyncState()
        moneroSync.begin()
        let request = try #require(moneroSync.requestId)
        moneroSync.cancel()
        var invoked = false
        await moneroSync.sync(request: request) { _, _ in
            invoked = true
            return nil
        }
        #expect(!invoked)
        #expect(!moneroSync.isRunning)
    }
}
