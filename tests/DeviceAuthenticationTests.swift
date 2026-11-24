import Foundation
import Testing
@testable import Spectra

@MainActor
struct DeviceAuthenticationTests {
    @Test func disablingSendAuthenticationDoesNotDisableOtherProtectedActions() {
        for action in [DeviceAuthenticationAction.unlock, .deleteWallet, .resetData] {
            #expect(action.requiresAuthentication(useDeviceAuthentication: true, authenticateSends: false))
        }
        #expect(!DeviceAuthenticationAction.send.requiresAuthentication(useDeviceAuthentication: true, authenticateSends: false))
        #expect(DeviceAuthenticationAction.send.requiresAuthentication(useDeviceAuthentication: true, authenticateSends: true))
    }

    @Test func usingSecretMaterialAlwaysRequiresAuthentication() {
        for useDeviceAuthentication in [true, false] {
            for authenticateSends in [true, false] {
                #expect(DeviceAuthenticationAction.secretMaterial.requiresAuthentication(
                    useDeviceAuthentication: useDeviceAuthentication, authenticateSends: authenticateSends))
            }
        }
    }
}
