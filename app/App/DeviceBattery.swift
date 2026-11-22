#if os(macOS)
    import IOKit.ps
#else
    import UIKit
#endif

/// The battery's charge, which core's refresh policy reads to slow down on a
/// low one. `nil` when the device has no battery or does not report it.
@MainActor
enum DeviceBattery {
    /// Start watching the battery, where a platform needs to be asked.
    static func startMonitoring() {
        #if os(iOS)
            UIDevice.current.isBatteryMonitoringEnabled = true
        #endif
    }

    /// The charge from 0 to 1.
    static var level: Float? {
        #if os(macOS)
            guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
                let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef]
            else { return nil }
            for source in sources {
                guard let description = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any],
                    description[kIOPSTypeKey] as? String == kIOPSInternalBatteryType,
                    let current = description[kIOPSCurrentCapacityKey] as? Int,
                    let capacity = description[kIOPSMaxCapacityKey] as? Int, capacity > 0
                else { continue }
                return Float(current) / Float(capacity)
            }
            return nil
        #else
            let level = UIDevice.current.batteryLevel
            return level < 0 ? nil : level
        #endif
    }
}
