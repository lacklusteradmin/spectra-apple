import Foundation
import Network
import SpectraCore

extension AppState {
    func startNetworkPathMonitorIfNeeded() {
        networkPathMonitor.pathUpdateHandler = { [weak self] path in
            let reachable = path.status == .satisfied
            let constrained = path.isConstrained
            let expensive = path.isExpensive
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isNetworkReachable = reachable
                self.isConstrainedNetwork = constrained
                self.isExpensiveNetwork = expensive
                self.reportDeviceConditions()
            }
        }
        networkPathMonitor.start(queue: networkPathMonitorQueue)
    }
    /// Core's engine starts both refresh loops in the foreground and stops
    /// them in the background. Called on entering the foreground and the
    /// background only; `.inactive` is not leaving the app.
    func setAppIsActive(_ isActive: Bool) {
        appIsActive = isActive
        if !isActive, preferences.useDeviceAuthentication, preferences.useAutoLock {
            isAppLocked = true
            appLockError = nil
        }
        reportDeviceConditions()
    }
    /// Watch the battery and the network path, which core's refresh policy
    /// reads through `deviceConditions()`. Domain state all arrives from core.
    func startDeviceMonitoring() {
        DeviceBattery.startMonitoring()
        startNetworkPathMonitorIfNeeded()
    }
    func refreshForForegroundIfNeeded() async {
        await performCoreRefresh(.foreground)
        #if os(iOS)
            await notifications.reconcileSendLiveActivities(amounts: amounts)
        #endif
    }
}
