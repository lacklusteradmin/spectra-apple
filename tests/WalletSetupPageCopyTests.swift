import Foundation
import Testing

@testable import Spectra

@MainActor
struct WalletSetupPageCopyTests {
    @Test func backupQuizRemainsRequiredOnlyForWalletCreation() {
        let draft = WalletImportDraft()
        draft.chain = .ethereum
        draft.seedEntry.paste("abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about")
        #expect(draft.canImportWallet)
        draft.mode = .setup(.createPhrase)
        #expect(!draft.canImportWallet)
        draft.backupVerificationWordIndices = [0, 5, 11]
        draft.backupVerificationEntries = ["abandon", "abandon", "about"]
        #expect(draft.canImportWallet)
        draft.backupVerificationEntries[2] = "abandon"
        #expect(!draft.canImportWallet)
    }

    private let modes: [WalletDraftMode] = [
        .edit, .setup(.createPhrase), .setup(.importPhrase), .setup(.importPrivateKey), .setup(.watchAddresses),
        .setup(.watchAccountXpub),
    ]

    /// Nothing may come back blank, on any page a flow visits.
    @Test func everyPageNamesItselfInEveryMode() {
        let pages: [WalletSetupPage] = [.watchAddresses, .seedPhrase, .backupVerification, .walletName]
        let flowPages = modes.flatMap { mode -> [WalletSetupPage] in
            switch mode {
            case .edit: SetupFlow.editWallet.pages
            case .setup(let method): SetupFlow.forMethod(method).pages
            }
        }
        for page in flowPages {
            #expect(pages.contains(page), "Flow page \(page) is missing from the copy coverage")
        }
        for page in pages {
            for mode in modes {
                let copy = page.copy(mode: mode)
                #expect(!copy.title.isEmpty, "\(page) has no title in \(mode)")
                #expect(!copy.subtitle.isEmpty, "\(page) has no subtitle in \(mode)")
            }
        }
    }

    @Test func theSecretPageNamesWhichSecretItIsAskingFor() {
        let cases: [(WalletDraftMode, String, String)] = [
            (.setup(.importPhrase), AppLocalization.string("import_flow.enterSeedPhraseTitle"), AppLocalization.string("import_flow.enterRecoveryPhraseSubtitle")),
            (.setup(.createPhrase), AppLocalization.string("import_flow.recordSeedPhraseTitle"), AppLocalization.string("import_flow.saveRecoveryPhraseSubtitle")),
            (.setup(.importPrivateKey), AppLocalization.string("import_flow.enterPrivateKeyTitle"), AppLocalization.string("import_flow.privateKeySubtitle")),
        ]
        for (mode, title, subtitle) in cases {
            let copy = WalletSetupPage.seedPhrase.copy(mode: mode)
            #expect(copy.title == title, "\(mode)")
            #expect(copy.subtitle == subtitle, "\(mode)")
        }
    }

    /// Watching addresses and watching an account ask for different things.
    @Test func theWatchPageNamesWhatItWatches() {
        let addresses = WalletSetupPage.watchAddresses.copy(mode: .setup(.watchAddresses))
        let account = WalletSetupPage.watchAddresses.copy(mode: .setup(.watchAccountXpub))
        #expect(addresses.title == AppLocalization.string("import_flow.watchAddressesTitle"))
        #expect(account.title != addresses.title)
    }

    /// The editing flow shows its edit heading on the actual name page.
    @Test func editingNamesTheEdit() {
        #expect(WalletSetupPage.walletName.copy(mode: .edit).title == AppLocalization.string("import_flow.editWalletTitle"))
        #expect(WalletSetupPage.walletName.copy(mode: .edit).subtitle == AppLocalization.string("import_flow.editWalletSubtitle"))
        #expect(WalletSetupPage.walletName.copy(mode: .setup(.importPhrase)).title != AppLocalization.string("import_flow.editWalletTitle"))
    }
}
