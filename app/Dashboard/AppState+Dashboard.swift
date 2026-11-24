import Foundation
import SpectraCore
import SwiftUI
extension AppState {
    /// Pin or unpin one asset. Core applies it to the set the dashboard shows,
    /// defaults included, and each pin option says whether it is pinned.
    func setDashboardAssetPinned(_ isPinned: Bool, tokenId: String) {
        sendStateCommand(.setDashboardAssetPinned(tokenId: tokenId, isPinned: isPinned))
    }
    func resetPinnedDashboardAssets() { sendStateCommand(.resetPinnedDashboardAssets) }
    /// A pricing read that failed is asked again by a refresh.
    private var retryRefresh: AppNoticeAction {
        .retry { [weak self] in _ = await self?.performUserInitiatedRefresh() }
    }
    var appNoticeItems: [AppNoticeItem] {
        var notices: [AppNoticeItem] = []
        if let quoteRefreshError {
            notices.append(
                AppNoticeItem(
                    title: AppLocalization.string("Pricing Notice"), message: quoteRefreshError, severity: .warning,
                    systemImage: "dollarsign.circle", action: retryRefresh
                )
            )
        }
        if let fiatRatesRefreshError {
            notices.append(
                AppNoticeItem(
                    title: AppLocalization.string("Fiat Rates Degraded Mode"), message: fiatRatesRefreshError, severity: .warning,
                    systemImage: "antenna.radiowaves.left.and.right.slash", action: retryRefresh
                )
            )
        }
        notices.append(
            contentsOf: diagnostics.chainDegradedBanners.map { banner in
                AppNoticeItem(
                    title: AppLocalization.format("%@ Degraded Mode", banner.chainName), message: banner.message, severity: .warning,
                    systemImage: "antenna.radiowaves.left.and.right.slash", timestamp: banner.lastGoodSyncAt,
                    action: .openEndpoints
                )
            })
        if let importNotice = walletImport.error?.trimmingCharacters(in: .whitespacesAndNewlines), !importNotice.isEmpty {
            notices.append(
                AppNoticeItem(
                    title: AppLocalization.string("common.walletImportErrorTitle"), message: importNotice, severity: .error,
                    systemImage: "square.and.arrow.down.badge.exclamationmark",
                    action: .dismiss { [weak self] in self?.walletImport.error = nil }
                )
            )
        }
        if let commandNotice = commandError?.trimmingCharacters(in: .whitespacesAndNewlines), !commandNotice.isEmpty {
            notices.append(
                AppNoticeItem(
                    title: AppLocalization.string("Action Failed"), message: commandNotice, severity: .error,
                    systemImage: "exclamationmark.circle", action: .dismiss { [weak self] in self?.commandError = nil }
                )
            )
        }
        if let sendNotice = sendFlow.session.error?.trimmingCharacters(in: .whitespacesAndNewlines), !sendNotice.isEmpty {
            notices.append(
                AppNoticeItem(
                    title: AppLocalization.string("common.sendErrorTitle"), message: sendNotice, severity: .error, systemImage: "paperplane.circle",
                    action: .dismiss { [weak self] in self?.sendFlow.session.error = nil }
                )
            )
        }
        if let secretStoreRegistrationError = secretStoreRegistrationError?.trimmingCharacters(in: .whitespacesAndNewlines),
            !secretStoreRegistrationError.isEmpty
        {
            notices.append(
                AppNoticeItem(
                    title: AppLocalization.string("Secure Storage Unavailable"), message: secretStoreRegistrationError,
                    severity: .error, systemImage: "lock.trianglebadge.exclamationmark"
                )
            )
        }
        if let appLockError = appLockError?.trimmingCharacters(in: .whitespacesAndNewlines), !appLockError.isEmpty {
            notices.append(
                AppNoticeItem(
                    title: AppLocalization.string("common.securityNoticeTitle"), message: appLockError, severity: .error,
                    systemImage: "lock.trianglebadge.exclamationmark", action: .dismiss { [weak self] in self?.appLockError = nil }
                )
            )
        }
        return notices
    }
}
