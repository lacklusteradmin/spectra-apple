# Changelog

## Beta Commit 255

- **Builds, tests and screenshots use the iPhone Air simulator alone**
  (`AGENTS.md` "Verification"): its UDID, what to do when it is missing, and
  asking before a second device or an experiment on its stored wallet.
- **An address hint is built from core's `addressPrefixHint` on every chain**
  (`app/Settings/AddressBookState.swift` `addressBookAddressValidationMessage`)
  - The hint for an empty or invalid address has no per-chain sentence (before:
    11 chains read `addressHint.<chain id>.empty` or `.invalid` first); the 22
    keys are removed in all three languages.
  - `scripts/unused-strings.py` counts a dotted key reached only through
    `"<namespace>.\(…)"` (before: `"<namespace>_\(…)"` too).
- **The transaction page draws its rows with the shared components**
  (`app/History/TransactionDetailView.swift`)
  - The hash, a technical identifier and the From and To addresses copy
    through `CopyButton(value:padded:row:)`, whose `padded: false` suits a
    detail card's rows (before: a private `CopyableValueRow` repeating its
    glyph, reset, haptic and hint).
  - Technical Details is a `DisclosureGroup` in the `.spectra` style, its
    chevron in the accent colour (before: a toggle of its own with a tertiary
    chevron).
  - An identifier in a `SpectraValueRow`, and the page's From and To
    addresses, are in groups of four with the first and last primary, as
    `groupedAddress` draws them (before: `emphasizedEnds`, ungrouped with its
    first four or six and last four characters primary; deleted).
- **Both funds scans are one `FundsScanRun`** (`app/Wallets/FundsScanRun.swift`
  new, `FundsFinderView.swift`, `UsedAccountsSheet.swift`)
  - Funds Finder and Find Used Accounts begin the scan off the main actor,
    read its batches, cancel and word a failed scan through the run (before:
    a loop in each screen, and eight `@State` scan fields in Funds Finder).
  - Closing Find Used Accounts stops its scan (before: it read on to the
    end).
  - A found account's import is set up by
    `WalletImportDraft.configure(foundAccount:words:passphrase:)` and Import
    All's commit by `WalletImportDraft.importCommit(foundAccount:words:passphrase:password:)`;
    choosing an account in Find Used Accounts calls the `derive(as:)` both
    use (before: three copies, in `importHit`, `importCommit` and
    `readRow`).
  - Funds Finder's import of a TON account found at a wallet version takes
    that version, and Find Used Accounts sets a TON account's profile and
    account when it has them (before: Funds Finder set only the profile and
    account, and Find Used Accounts only the version).
- **Words are read through `AppLocalization` alone**
  (`app/Models/StaticContentCatalog.swift`, `CoreModels.swift`)
  - Screens read their dotted keys directly (before: through
    `SettingsContentCopy`, `DiagnosticsContentCopy`, `ImportFlowContent`,
    `CommonLocalizationContent`, `DonationsContentCopy` and
    `EndpointsContentCopy`, deleted).
  - A transaction's title is keyed by its English sentence for every kind:
    `Sent %@`, `Received %@`, `Stake %@`, `Unstake %@`, `Withdraw %@` and
    `Claim %@ Rewards`, renamed in all three languages (before:
    `common.transactionSentTitleFormat`,
    `common.transactionReceivedTitleFormat` and `transaction.title.*`).
  - Seven sentences with values are formatted in `AppLocalization.locale`
    through `AppLocalization.format` (before: `String(format:)` with no
    locale, six in `CoreModels.swift` and one in
    `WalletDiagnosticsState.swift`); `DiagnosticsViews.swift`'s `formatCopy`
    is replaced by it.
  - A component takes finished text and its caller localizes it:
    `SpectraValueRow`, `spectraDetailCard`, `SpectraLoadingRow`,
    `SpectraEmptyStateCard`, `SpectraEmptyStateContent`, `spectraPageHeader`,
    `FlowPageHeading`, `CopyButton`'s title, `WalletToolEmptySection` and the
    pages' own row and header helpers (before: each looked its text up as a
    key, so text already localized was looked up again, among it a node's
    own failure message on the transaction timeline).
- **Hide Balances masks the balances the send, staking and wallet tool pages
  showed** (`BalanceText`, `LabeledContent(_:balance:isHidden:)`)
  - Masked: each asset's balance on Send's asset page; Available to Send and
    the wallet balance under it; Available on the staking page; the MWEB
    page's Spendable and Pending, and the shielded page's with Transparent,
    to Shield; the network account's Balance, Spendable, Free, Reserved,
    Frozen, Transferable, Locked Stake and Rewards; and the coins page's
    maturing amount, coins and address balances (before: shown while Hide
    Balances was on).
  - `BalanceText` takes the sentence a balance sits in and masks the balance
    alone; VoiceOver hears "Hidden" in its place.
- **One model per fact on core's records** (`app/Models/CoreModels.swift`)
  - `AssetHolding.holdingKey` and the `chain` aliases of `AssetHolding`,
    `WalletState` and `TransactionRecord` are removed: callers read `id` and
    `chainId`.
  - `WalletState.networkTitle` is `chainName`, as on the other records, and
    `AssetHolding.isEVMChain` is removed.
  - The receive page starts on the asset `isNativeCoin` names (before: the
    first without a contract address).
  - `HistoryQueryFilter` and `FiatCurrency` list their cases in a `static let
    allCases`, as `PriceAlertCondition`, `DiagnosticLogLevel` and
    `ResetScope` do (before: a retroactive `CaseIterable`).
  - The endpoint catalog by chain and the donation addresses are
    `CoreReferenceTables.endpointGroups(for:)` and `.donationDestinations`,
    read once (before: `AppEndpointDirectory`, and `donationDestinations()`
    called on every read).
  - The Report a Problem address is a constant in `SettingsView` (before:
    `resources/AppLinks.json`, read through `AppLinks`, which stopped the app
    if the file was missing; both deleted).
- **Notification permission is asked with the async API**
  (`PlatformNotifications.requestPermission`): a failure is logged under
  Notifications (before: a completion handler that dropped it).
- **The Tor indicator has no stopped state** (`DashboardView`
  `TorToolbarIndicator`): the toolbar holds it only while Tor runs, connects
  or fails, so its stopped colour, with a macOS branch, and the "Tor off"
  string in all three languages are removed.
- **`SendSessionTests` runs on `.isolatedAppState`**: its `AppState` test has
  the test secret store, and its directory goes after the queued writes
  finish (before: its own service, bridge and directory).
- **The send-authentication preference is `authenticateSends`**
  (`AppUserPreferences`; before: `requireBiometricForSendActions`, a name
  without Touch ID, Optic ID or the passcode): it is stored under
  `settings.platform.authenticateSends`, so a value stored under the old key
  is not read and the preference starts on.
- **The app adopts core's narrower state and its new answers**.
  - A command, the store opening, a reset and each portfolio snapshot give
    the app a `CommittedState`, read with `committedState()` (before: the
    whole `ResidentState`, through `appState()`); the quote notices come from
    the snapshot's `quotes`.
  - The dashboard reads whether its total is still being read, or has no
    figure yet, from `QuotedTotal.unreadWalletCount` and `isUnread`
    (before: `portfolioWalletsReadingBalances` and `portfolioTotalIsUnknown`,
    which the app derived from each wallet; both deleted).
  - The receive screen asks `walletAccountReserve(walletId:)` and shows what
    it answers (before: it checked the chain and the native balance itself,
    through `Chain.requiresAccountReserve`, now deleted).
  - The refresh observer's `onBalanceRefreshed` re-reads the portfolio only
    after a balance landed (before: `onBalanceUpdated`, with a `WalletState`
    it ignored).
  - The custom-endpoint form sends the chosen API as `EndpointApi`, and the
    reset and TON version lists are core's `resetScopes()` and
    `tonWalletVersions()` (before: written out in Swift).
- **A staking position's amounts follow Hide Balances**
  (`StakingPositionsView`; `SpectraValueRow` gains `isHidden`): the staked,
  unbonding, withdrawable and reward amounts are masked as `BalanceText`
  masks a balance (before: shown while balances were hidden).
- Tests: 5 new
  - Found-account import 5: a scanned account imported with a changed phrase,
    passphrase or password, or deriving elsewhere than it was found; choosing
    a used account disturbing the rest of the form.
- Docs: `IOS-UI.md` "Design baseline" (balances) and the label/value row
  (identifiers); `ARCHITECTURE.md` "Presentation" (`CoreReferenceTables`,
  localization and finished text); `AGENTS.md` "Verification".
- Total: 95 .swift files changed (2 new, 1 deleted), +930 −992 lines; data
  and config files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `resources/AppLinks.json`
  (deleted), `scripts/unused-strings.py`; dependencies unchanged; test
  functions 148 → 153.

## Beta Commit 254

- **A diagnostics bundle is shared, not kept or imported**
  (`app/Diagnostics/AppState+DiagnosticsExport.swift`,
  `DiagnosticsViews.swift`; `DiagnosticsExportsBrowserView.swift` deleted)
  - The export is written to the temporary directory and handed to the share
    sheet (before: kept in `Documents/Diagnostics Bundles`, which no reset
    cleared).
  - "Import Diagnostics Bundle", which showed a date and dropped the rest,
    and the "Past Exports" browser are removed, with their seven strings in
    all three languages; the notice reads "Diagnostics bundle ready to
    share."
- **`make apple` needs the current stable Rust** (`README.md`): spectra no
  longer pins a toolchain.
- **Every label/value row is one `SpectraValueRow`**
  (`app/Components/SpectraValueRow.swift`; before: `TransactionDetailRow`,
  `SendSummaryRow`, `WalletDetailRow` and the private `valueRow`,
  `amountRow`, `reviewRow` and `wikiStatRow`)
  - The staking review and a wallet's Details section put a label and its
    value side by side while both fit (before: the label always above its
    value); their values stay selectable.
  - A staking position's amounts and unlock times are rows at the detail
    size (before: caption-size rows).
  - The network account page's amounts are `LabeledContent` rows, as on the
    other wallet tool pages (before: a row of its own, with each section's
    last amount emphasised).
- **One divider weight, `SpectraLayout.dividerOpacity`**
  (`app/Components/SpectraLayout.swift`, `scripts/check-design-tokens.py`)
  - Every divider in a card is at 0.4 (before: 0.25 in row groups, on Home,
    the funds finder and a wallet's pages; 0.3 on the send pages; full
    opacity between staking positions).
  - `make check-ui` refuses a `Divider()` given a literal opacity.
- **The device-check preference is `useDeviceAuthentication`**
  (`AppUserPreferences`; before: `useFaceId`, a name without Touch ID, Optic
  ID or the passcode): it is stored under
  `settings.platform.useDeviceAuthentication`, so a value stored under the old
  key is not read and the preference starts on.
- **Files and test suites are named for what they hold**
  - `SettingsViews.swift` is `SettingsView.swift`, `EndpointsViews.swift`
    `EndpointCatalogSettingsView.swift`, `ChainWikiViews.swift`
    `ChainWikiDetailView.swift` (its `ChainWikiEntry.face` moved to
    `CryptoWikiViews.swift`), `ReceiveFlowViews.swift` `ReceiveView.swift`
    and `WalletSetupViews.swift` `SetupView.swift`; `ImageRendering.swift`
    splits into `CoinBadge.swift` and `SpectraLogo.swift`.
  - The suites are `StakingStateTests`, `MoneroSyncStateTests`,
    `BalanceRefreshTests`, `SpectraSecretStoreAdapterTests` and
    `AppStateTests`, with the files `MoneroSyncStateTests.swift`,
    `BalanceRefreshTests.swift` and `SpectraSecretStoreAdapterTests.swift`
    (before: named for view models, a refresh planner and a seed store that
    do not exist).
- **`scripts/swift-shell-literals.py` has no allowlist** (before: one entry
  for a `"Base"` literal no file holds), and its docstring names
  `AmountPresentation` (before: two functions that do not exist).
- **`docs/LocalizationGlossary.json` is deleted**: no script read it.
- **The app's architecture is documented here** (`docs/ARCHITECTURE.md`):
  the Mac build, `AppState` and its domains, `SendFlowState` and
  `SendSession`, the presentation catalogs and the rules that keep the shell
  thin, moved from spectra's `docs/ARCHITECTURE.md`.
- Tests: none new or removed; the diagnostics bundle test also fails an
  export kept outside the temporary directory, and reads the file as JSON
  (before: through the deleted import).
- Docs: `ARCHITECTURE.md` (new); `IOS-UI.md` "Design baseline" (dividers),
  the label/value row, the design-token check, the shared helpers and the
  examples; `SWIFT-BINDINGS.md` "Common errors" (the `Codable` and key-path
  rows); `scripts/README.md` (`check-design-tokens.py`); `AGENTS.md` "Docs"
  and "Resources"; `README.md` (the Rust toolchain).
- Total: 51 .swift files changed (2 new, 1 deleted, 9 renamed), +565 −731
  lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `docs/LocalizationGlossary.json` (deleted), `scripts/check-design-tokens.py`,
  `scripts/swift-shell-literals.py`; dependencies unchanged; test functions
  unchanged at 148.

## Beta Commit 253

- **Send warnings no longer word three address-format cases**
  (`app/Models/DisplayFormatting.swift` `HighRiskSendWarning.localizedText`):
  core's enum no longer has `nonEvmOnEvm`, `ethOnUtxo` or
  `foreignAddressFormat`, and their strings are removed in all three languages.
- **Derivation overrides reach core exactly as typed**
  (`app/Wallets/WalletImportDraft.swift` `resolvedDerivationOverrides`): the
  passphrase and HMAC key go in a `WalletDerivationOverrides` directly, and core
  reads a blank one as none (before: through core's
  `parseWalletDerivationInput`).
- **Tests put wallets in core through its import** (`tests/AppStateTests.swift`
  `importWalletForTesting`, `tests/RefreshPlannerTests.swift`; before: an
  `upsertWallet` state command with a `WalletState` built in Swift, whose helper
  `WalletView.walletState()` is deleted from
  `tests/CoreModelsTestSupport.swift`): wallets are imported from a phrase core
  generates in the chain's format, or watched at an address derived that way;
  the send composer test hands its funded wallet to the snapshot as view state;
  the `WalletState` fixture (before: `WalletView`) takes `WalletDerivationFlags`
  in place of override values and one `address`; no test sends
  `mergeBuiltInTokens`, and a token test reads `appState()`.
- **`docs/CHANGELOG.md` records what each commit changed, newest first, from the
  Initial Commit on**, written from the git history; `AGENTS.md` gains a
  "CHANGELOG" section on how it is written and tidied before a commit, and its
  Git rule points there.
- **An export counts as reached only by production Swift**
  (`scripts/unreachable-exports.py`; `docs/SWIFT-BINDINGS.md` "Callers")
  - The CLI's calls no longer keep an export alive: core's CLI links core as
    Rust.
  - The allowlist holds `tor_status`, which the Tor test reads because a
    test's `AppState` installs no `RefreshObserver` (before: `new` and two
    names no longer in core).
  - Tests stop calling exports only they reached: the pinned-assets test
    drops its `dashboardPinOptions` read, the pending-sweep bridge test is
    removed, and the colour test lists `listAllBuiltinTokenDeployments`.
- **A wallet is core's `WalletState`, with one `address`** (before:
  `WalletView` with a slot-keyed `addresses` map, read through
  `address(on:)`; `Chain.addressSlot` is removed)
  - The wallet detail, message and send confirmation read `wallet.address`;
    a wallet's path is named from `wallet.derivationProfile` (before:
    `derivationProfileOfPath`).
  - The test that an Ethereum wallet answers for the EVM family is removed:
    core tests the rule.
- **A transaction's direction, submission and history source are the
  record's** (`app/Models/CoreModels.swift`, `AmountPresentation.swift`)
  - The badge colour, amount sign and colour read `direction`, and the
    detail timeline and Live Activity read `submitted` (before: core exports
    asked per record, and the badge colour by kind, so a send of nothing was
    red).
  - The history source row names `historySource`'s indexer; the
    `%@ providers` string is removed in all three languages.
- **A staking action's signing confirmation is the send's, with its fee and
  warnings, and its review lists core's warnings**
  (`sendSigningConfirmationMessage(artifact:amounts:action:)`;
  `app/Components/ReviewWarnings.swift`, used by `SendStagesView` and
  `StakingTransactionView`)
- **Exact amounts read in the reader's decimal separator everywhere**
  (`AmountPresentation.exactAmount(_:symbol:)`): the MWEB, shielded,
  network-account and coins pages (before: core's string with a `.`), and
  the Monero payment proof names its chain's symbol (before: `XMR`).
- **The token form, the phrase lengths and the chain search follow core**
  - A custom token sends its decimals only where its standard fixes none;
    `decimalsRequired` reads "Enter the token's decimal places." in all
    three languages.
  - A created phrase's lengths are `createdPhraseLengths`, and the import
    marks a created wallet `created` instead of asking
    `newWalletRestoreHeight`.
  - A chain row matches `chainMatchesSearch` or its localized name and tag
    titles (before: its own name, symbol, keyword and tag match).
- **Send, staking and wallet-tool pages share their stage parts**
  (`app/Send/SendStageComponents.swift`: `SendStatusLabel`,
  `BroadcastNodePicker`, `SubmissionResults`, `TransactionHashRow`)
  - Each page shows core's `SendProgress.status` (before: the send page
    worked out its title, symbol and colour three times from the stage and
    the nodes' answers, and the staking page in a fourth way).
  - The node picker and the submission results are one each (before:
    written in `SendStagesView`, `StakingTransactionView` and
    `SendArtifactStageSections`); a wallet tool's page now has the empty
    selection warning, each answer's details and the transaction hash, and a
    staking page keeps each answer's details behind a disclosure.
  - A wallet tool's page names the status once submitted and says its
    submitted text only until the chain settles it; its "Broadcast To"
    heading, whose string is removed in all three languages, is the picker's
    own.
- **Two runtime strings core no longer produces are removed** in all three
  languages: "Missing Aptos chain id" and "Missing Aptos gas limit".
- Tests: 2 new, 3 removed
  - Wallet edit 1: a rename dropping the wallet's other settings, such as its
    portfolio inclusion (replaces the test that the edit kept seeded holdings).
  - Wallet tool stages 1: a tool's stage sections that select nodes or change
    the transaction when drawn.
  - The pending-sweep async bridge test and the EVM family address test are
    removed: what they reached is core's, and core tests it.
- Docs: `CHANGELOG.md` (new); `AGENTS.md` "Git", "Docs" (table, "Keep them
  true"), "CHANGELOG" (new); `SWIFT-BINDINGS.md` "Callers"; `IOS-UI.md`
  "Additional constraints"; `scripts/README.md` (`unreachable-exports.py`).
- Total: 63 .swift files changed (2 new), +543 −549 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `scripts/unreachable-exports.py`; dependencies unchanged; test functions
  149 → 148.

## Beta Commit 252

- **The core package is built in spectra and copied here** (`Makefile`,
  `AGENTS.md`, `README.md`, `SWIFT-BINDINGS.md`): `make core` and `make clean`
  are gone; spectra's `make apple` writes `target/SpectraCore/`, which a
  developer copies to this repository's root keeping modification times (`cp
  -Rp`, `ditto` or a Finder drag), so Xcode recompiles no Swift when the FFI is
  unchanged. The Release-build check names `make apple PROFILE=release`.
- **Nothing assumes where a spectra checkout is**: `make lint` and the icon
  export take `SPECTRA`, absolute or relative, and refuse without it (before:
  `../Spectra` by default); `CLAUDE.md` no longer loads core's `AGENTS.md`,
  which `AGENTS.md` tells the reader to read.
- Docs: `AGENTS.md` "Repositories" and "Icons"; `README.md`;
  `SWIFT-BINDINGS.md`; `OPEN-ITEMS.md`; `scripts/README.md`.
- Total: no .swift files changed, +139 −155 lines; data and config files:
  `scripts/` (4), `.gitignore`, `Makefile`, `Spectra.xcodeproj/` (1);
  dependencies unchanged; test functions unchanged at 149.

## Beta Commit 251

- **`swift/` moves to the repository root**: `app/`, `tests/`, `extensions/`,
  `Assets.xcassets/`, `Spectra.xcodeproj`, `Info.plist`,
  `Spectra.macOS.entitlements`, `Spectra.xctestplan`, and the `SpectraCore/`
  package; the scripts, `.gitignore` and docs follow the new paths, and the
  source scans read `app/` and `extensions/`. Behaviour unchanged.
- Docs: `AGENTS.md`, `README.md`, `IOS-UI.md`, `SWIFT-BINDINGS.md` (paths).
- Total: 221 .swift files changed, +56 −54 lines; data and config files:
  `Assets.xcassets/crypto/` (215), `Assets.xcassets/AppIcon.appiconset/` (11),
  `scripts/` (7), `.gitignore`, `Assets.xcassets/AccentColor.colorset/` (1),
  `Assets.xcassets/` (1), `Info.plist`, `Makefile`,
  `Spectra.macOS.entitlements`, `Spectra.xcodeproj/` (1),
  `Spectra.xcodeproj/project.xcworkspace/` (1),
  `Spectra.xcodeproj/xcshareddata/` (1), `Spectra.xctestplan`,
  `extensions/SpectraLiveActivityExtension/` (1); dependencies unchanged; test
  functions unchanged at 149.

## Beta Commit 250

- **The app links core as a `swift/SpectraCore/` Swift package that `make core`
  builds; Xcode compiles no Rust** (`Makefile` `core`, `SPECTRA ?= ../Spectra`,
  `PROFILE`, `PLATFORMS`; `swift/Spectra.xcodeproj/project.pbxproj`)
  - The submodule is removed: `make core` runs core's
    `scripts/build-apple-package.sh` on the checkout beside this repository,
    stamped with the app's minimum iOS and macOS versions from the project;
    every build and test target runs it first.
  - The package holds core as an XCFramework, its FFI header as its own module,
    and the generated bindings as the `SpectraCore` module; every Swift file
    that uses core says `import SpectraCore`, and conformances on core types are
    `@retroactive`.
  - A Release build refuses a dev package.
  - `scripts/build-apple.sh`, `apple-rust-build-env.sh`, `.cargo/config.toml`
    and the CI workflow are deleted; `CLAUDE.md` loads `../Spectra/AGENTS.md`.
- Docs: `SWIFT-BINDINGS.md` ("The core package", "Changing the Rust API", common
  errors); `AGENTS.md` "Repositories"; `README.md`; `OPEN-ITEMS.md`;
  `scripts/README.md`.
- Total: 166 .swift files changed, +406 −472 lines; data and config files:
  `scripts/` (5), `.cargo/` (1), `.github/workflows/` (1), `.gitignore`,
  `.gitmodules`, `Makefile`, `spectra`, `swift/Spectra.xcodeproj/` (1);
  dependencies unchanged; test functions unchanged at 149.

## Take the core as the spectra submodule

- **The app builds core from a `spectra/` git submodule** (`.gitmodules`;
  `scripts/build-apple.sh` compiles `spectra/core` with the toolchain
  `spectra/rust-toolchain.toml` pins and refuses when the submodule is not
  checked out; `scripts/export-swift-icons.sh` reads `spectra/icons/crypto/`;
  the source scans read core through it).
- **This repository holds only the app** (`AGENTS.md`, `CLAUDE.md`,
  `README.md`): Rule 0, Architecture and Funds and keys move to core's
  `AGENTS.md`, which `CLAUDE.md` now loads; the Makefile keeps `lint`,
  `check-ui`, `test-ios`, `test-mac` and the build targets, and core's targets
  run in its checkout; CI runs the source scans (with the submodule) and the
  design-token check.
- Docs: `SWIFT-BINDINGS.md` (new: building core, regenerating bindings, callers,
  common errors); `FFI-BOUNDARY.md` deleted (core's); `OPEN-ITEMS.md` reduced to
  app work (the two Mac items); `AGENTS.md` "Repositories" and Verification
  (four targets); `README.md`; `scripts/README.md`; three Swift comments point
  at `spectra/` paths.
- Total: 3 .swift files changed, +228 −501 lines; data and config files:
  `scripts/` (7), `.github/workflows/` (1), `.gitignore`, `.gitmodules`,
  `Makefile`, `spectra`; dependencies unchanged; test functions unchanged at
  149.

## Beta Commit 249

- **The in-app logo is the app icon's five bars** (`ImageRendering.swift` new
  `SpectraMark`, `SpectraLogo`; `ViewExtensions.swift`): bars in the icon's
  palette on its black tile, geometry shared with `icons/appicon/` (before: a
  glass tile with colour blobs and a rotated "S"); the app icon sources and
  every exported PNG are redrawn to match.
- **`make verify` is removed** (`Makefile`, `AGENTS.md`, `README.md`): the six
  targets are each run by name, and AGENTS.md says which a change needs.
- Docs: `IOS-UI.md` "Logo" and artwork rules; `AGENTS.md`; `README.md`;
  `OPEN-ITEMS.md`; `scripts/README.md`.
- Total: 2 .swift files changed, +74 −59 lines; data and config files:
  `swift/Assets.xcassets/` (10), `icons/appicon/` (3), `Makefile`; dependencies
  unchanged; test functions unchanged at 149.

## Beta Commit 248

- **The app runs on macOS from the same target and sources**
  (`swift/Spectra.macOS.entitlements`, Mac app icons in `AppIcon.appiconset`;
  `README.md`, `IOS-UI.md` "macOS")
  - Views name the platform through `PlatformChrome.swift`
    (`inlineNavigationTitle`, `clearNavigationBar`, `hidesTabBar`,
    `.barLeading`/`.barTrailing`, `pageSheet`, `pageRefreshable` with a Refresh
    button and ⌘R on the Mac, `formRowButtonStyle`); `#if os(macOS)` is kept for
    AppKit views, the camera and the pasteboard (`PlatformImage`,
    `PlatformPasteboard`, `MacInputTraits`, `TextFocus`).
  - One window with the tabs as a sidebar, ⌘, opening settings; pages stop at
    `SpectraLayout.pageMaxWidth`; forms grouped and fields unbezelled.
  - The Mac app is away, and auto-lock locks, when it is hidden, minimized, the
    display sleeps or the session is switched (`SceneCover.swift`; losing focus
    is not leaving); battery state for core's refresh policy comes from
    `DeviceBattery.swift`.
  - A window showing a secret is marked unshareable (`SecretShield.swift`); a
    copied secret stays off Universal Clipboard and is cleared after a minute
    unless something else was copied (`SecretPasteboard.swift`); seed words and
    addresses are AppKit text views with typing aids off
    (`SecretWordField.swift`, `AddressInput.swift`); the QR scanner uses the Mac
    camera (`SendQRScannerSheet.swift`); sharing opens the system menu
    (`ActivityItemSheet.swift`).
  - No send Live Activity on a Mac: a send is followed by its notification alone
    (`PlatformNotifications+SendLiveActivity.swift`,
    `SendLiveActivityAttributes.swift`).
- **The Keychain is used through the Security framework directly**
  (`SecureStores.swift`): every item names the data protection keychain,
  accessible when a passcode (a Mac login password) is set, this device only;
  failures report the `OSStatus` (`KeychainStoreError.keychain`). The
  KeychainAccess Swift package is removed.
- **New targets `make test-mac`, `make mac`, `make macr`** (`Makefile`);
  `scripts/build-ios.sh` becomes `build-apple.sh` and builds core for the Mac
  too, with `apple-rust-build-env.sh` replacing `ios-rust-build-env.sh`;
  `export-swift-icons.sh` also writes the light icon in the Mac's shape and
  sizes. `test-mac` needs the app signed with its keychain access group.
- Render tests share a window helper that works on both platforms
  (`swift/tests/RenderWindow.swift`); the Live Activity and shell-boundary tests
  are nested in their suites.
- Docs: `IOS-UI.md` "macOS" and the chrome, flow and sheet rules; `AGENTS.md`
  (iOS 26 and macOS 26 from one target, `PlatformChrome.swift`, `test-mac`);
  `README.md` (the Mac app, signing, six targets); `OPEN-ITEMS.md` (walk the Mac
  flows by hand, review default-styled buttons); `FFI-BOUNDARY.md`;
  `scripts/README.md`.
- Total: 102 .swift files changed (7 new), +2592 −1171 lines; data and config
  files: `swift/Assets.xcassets/` (8), `scripts/` (4), `resources/strings/` (3),
  `swift/Spectra.xcodeproj/` (2), `.github/workflows/` (1), `Makefile`, `swift/`
  (1); dependencies: removed KeychainAccess 4.2.2 (Swift package,
  `Package.resolved`); test functions unchanged at 149.

## Beta Commit 247

- **`make test-ios` boots its simulator first and keeps it up** (`Makefile`
  `IOS_TEST_SIM`, a UDID; before: a name, and xcodebuild booted and shut it down
  each run).
- The record-field MIR scan leaves `make lint` and the docs; `cargo clippy` and
  `cargo test` no longer pass `--workspace`; the bindings generator builds
  unoptimized.
- Docs: `AGENTS.md` (a row for core changes with no funds, keys or FFI change:
  `make lint test`); `README.md`; `FFI-BOUNDARY.md`; `scripts/README.md`.
- Total: no .swift files changed, +30 −39 lines; data and config files:
  `.github/workflows/ci.yml`, `Makefile`, `scripts/build-ios.sh`; dependencies
  unchanged; test functions unchanged at 149.

## Beta Commit 246

- **`AGENTS.md` is reorganised** into Rule 0 (with what it does not license, now
  including "Widening a change unasked"), Docs (a table of which doc covers
  what, and how to keep them true), Architecture, Funds and keys, a Verification
  table matched to the kind of change, and the Swift, resource and icon
  conventions; no test is expected to fail.
- `make verify` adds `check-ui`, and CI gains a job running it with svgo 4.1.0.
- `Store+AddressPresentation.swift` and `Store+Formatting.swift` are renamed
  `AddressPresentation.swift` and `DisplayFormatting.swift`; behaviour
  unchanged.
- Docs: `AGENTS.md`; `README.md` (chain support, tests and scripts);
  `FFI-BOUNDARY.md`; `IOS-UI.md`; `OPEN-ITEMS.md`; `scripts/README.md`.
- Total: 2 .swift files changed, +158 −94 lines; data and config files:
  `.github/workflows/ci.yml`, `Makefile`; dependencies unchanged; test functions
  unchanged at 149.

## Beta Commit 245

- **The send composer's requests live on `SendFlowState`**
  (`SendFlowState.swift`, `SendFlowState+Preview.swift`, `SendSession.swift`;
  before: `@State` tasks in the view, with a polling loop): recipient resolution
  and quoting start when the form changes and typing pauses, run only while the
  composer is on screen, and adopt only the latest answer; a quote is current
  only for the form it answered; a refused recipient offers Retry only when the
  network could not be reached or read.
- **Core decides the next step** (`SendNextStep+Presentation.swift` replaces
  `SendExecutionAction.swift`; `SendSession.swift`, `StakingState.swift`,
  `StakingTransactionView.swift`): every staged send and staking transaction
  arrives with core's `SendProgress`, which names its next step (sign,
  broadcast, retry, done), whether staking repair is allowed and the review
  warnings; the signing confirmation carries every warning and states the fee
  and whether it is an upper bound.
- **A scanned payment code fills the amount and memo it asks for**
  (`SendFlowState`, new `SendQRScannerSheet.swift`): read by core against the
  network and the asset.
- **Wallet tool sheets share one build-and-review form** (new
  `WalletOperationSheet.swift`; the access-key, approval, coin-object, MWEB,
  network-account, NFT, shielded, token-account, token-storage and trust-line
  views); copy feedback, address shortening and the recipient field
  (`AddressEntryRow`) each have one implementation.
- **One screen per file**: `DashboardViews.swift` splits into `DashboardView`,
  `AssetGroupDetailView`, `AppNoticesView`, `PinnedAssetsView` and
  `PortfolioWalletSelectionView`; `WalletFlowViews.swift` into
  `WalletDetailView`, `WalletAdvancedDetailsView`, `WalletCardView` and
  `WalletDerivationOptionsView`; `SendPrimarySectionsView.swift` and
  `SendFlowViews.swift` into `SendView`, `SendFromPage`, `SendRecipientPage`,
  `SendAmountPage`, `SendAssetContextView`, `SendRecipientIdentityView` and
  `SendComposerPresentation`; plus `QRCodeImage`, `TransactionStatusBadge`,
  `ActivityItemSheet`.
- Tests: 8 new, 13 removed
  - Composer requests 2: a quote adopted for a form it did not answer; an
    off-screen composer scheduling requests.
  - Next step 2: a step core did not name running; staking repair offered before
    core allows it.
  - Signing confirmation 3: the summary rounding the amount, cutting the
    recipient, dropping a warning, or omitting the fee or its bound.
  - Transfer terms 1: token-term warnings worded with other than core's amounts
    (replaces four per-term tests).
  - Removed: the Swift next-action tests, which core now owns.
- Docs: `IOS-UI.md` examples; `OPEN-ITEMS.md` (the iOS technical-debt items
  removed).
- Total: 68 .swift files changed (20 new), +3142 −3221 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 154 → 149.

## Beta Commit 244

- **Source scans and CLI acceptance are Python**
  (`scripts/unreachable-exports.py`, `uncalled-core-fns.py`,
  `unwritten-record-fields.py`, `unused-strings.py`, `swift-shell-literals.py`,
  `check-design-tokens.py` replace their `.sh` versions as modules on
  `source_scan.py`; `make test-cli` runs `python3 -B tests/acceptance`). No app
  code changed.
- Docs: `AGENTS.md`, `README.md`, `FFI-BOUNDARY.md`, `IOS-UI.md`,
  `scripts/README.md` (script names); `OPEN-ITEMS.md` (the CLI and tests debt
  items removed).
- Total: no .swift files changed, +594 −444 lines; data and config files:
  `scripts/` (10), `.github/workflows/` (1), `.gitignore`, `Makefile`;
  dependencies unchanged; test functions unchanged at 154.

## Beta Commit 243

- **A transaction's detail no longer shows its raw signed payload or payload
  format** (`TransactionDetailView.swift`, `CoreModels.swift`): core's record no
  longer carries them.
- Docs: `FFI-BOUNDARY.md` "Timestamps"; `OPEN-ITEMS.md` (core debt items
  removed).
- Total: 5 .swift files changed, +14 −74 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 154.

## Beta Commit 242

- **Regenerated bindings replace a file only when its text changed**
  (`scripts/build-ios.sh`): generation writes to a scratch directory and copies
  over `swift/generated/` file by file, so a core edit that leaves the FFI
  unchanged does not recompile the whole app.
- Docs: `FFI-BOUNDARY.md`; `scripts/README.md` (`build-ios.sh`,
  `unwritten-record-fields.sh` and `emit-mir.sh`); `OPEN-ITEMS.md` (the
  `api`-depends-on-`send` item removed).
- Total: no .swift files changed, +19 −8 lines; data and config files:
  `scripts/build-ios.sh`; dependencies unchanged; test functions unchanged at
  154.

## Beta Commit 241

- The "one fact, two readers" debt item is removed from `OPEN-ITEMS.md`, with
  the strings for three core messages it retired. No code changed.
- Docs: `OPEN-ITEMS.md`.
- Total: no .swift files changed, +0 −19 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 154.

## Beta Commit 240

- **Token standards are core's `TokenStandard` enum** (`RegistryModels.swift`
  `TokenStandard.name`, `AssetHolding.standardLabel`;
  `AddCustomTokenView.swift`, `TokenPreferencesState.swift`,
  `SettingsTokenComponents.swift`, `TokenRegistrySettingsView.swift`,
  `DashboardViews.swift`, `WalletFlowViews.swift`): names come from core's
  `tokenStandardName`, and a native coin's label is the localized "Native"
  (before: core's "Native" string).
- Docs: `OPEN-ITEMS.md` (token-standards item removed).
- Total: 12 .swift files changed, +32 −23 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 154.

## Beta Commit 239

- The `send_stage_protocols.rs` debt item is removed from `OPEN-ITEMS.md`. No
  code changed.
- Docs: `OPEN-ITEMS.md`.
- Total: no .swift files changed, +0 −4 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 154.

## Beta Commit 238

- The network-identity-checks debt item is removed from `OPEN-ITEMS.md`, with
  the strings for two core messages it retired ("Missing confirmed nonce", "The
  Aptos endpoint is on another network."). No code changed.
- Docs: `OPEN-ITEMS.md`.
- Total: no .swift files changed, +0 −13 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 154.

## Beta Commit 237

- `AGENTS.md` drops `fetch` from the layers that call `api`, and `OPEN-ITEMS.md`
  drops the typed-history item (both done in core). No code changed.
- Docs: `AGENTS.md` "Architecture"; `OPEN-ITEMS.md`.
- Total: no .swift files changed, +3 −11 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 154.

## Beta Commit 236

- **App sources move from `swift/` and `swift/views/` into `swift/app/`, one
  folder per feature** (`App/`, `Models/`, `Components/`, `Dashboard/`,
  `Wallets/` with `Tools/`, `Send/`, `Receive/`, `History/`, `Staking/`,
  `Settings/`, `Diagnostics/`, `Wiki/`): the folder is an Xcode synchronized
  group, so the project file loses its per-file entries; `ImportDraft.swift`
  becomes `WalletImportDraft.swift`, `StakingViewModel` `StakingState`,
  `MoneroSyncViewModel` `MoneroSyncState`. Behaviour unchanged.
- `Chain` reads core's `listAllChains()` catalog once (before:
  `chainIdentities()` joined with it) and gains `faucetURL`; `ChainTypes.swift`
  deleted.
- CI runs `make lint`, `make test` and `make test-cli`, so the Makefile is the
  one list of gates; `make test-ios` uses the first available iPhone simulator
  unless one is named; the Android targets are removed and README names two
  front ends.
- Docs: `AGENTS.md` (the `swift/app/` layout); `OPEN-ITEMS.md` "Technical debt"
  (core, CLI and tests, iOS app); `IOS-UI.md`, `FFI-BOUNDARY.md`, `README.md`,
  `scripts/README.md` paths.
- Total: 165 .swift files changed, +249 −444 lines; data and config files:
  `scripts/` (7), `.github/workflows/` (1), `.gitignore`, `Makefile`,
  `swift/Spectra.xcodeproj/` (1); dependencies unchanged; test functions
  unchanged at 154.

## Beta Commit 235

- Staking copy follows core's corrected figures: Aptos's lockup cycle is about
  14 days (before: ~30), NEAR's 4-epoch unbonding about 1–1.5 days (before:
  ~52h). No code changed.
- Total: no .swift files changed, +12 −12 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 154.

## Beta Commit 234

- The string for core's removed "node returned no transaction identifier"
  message is deleted. No code changed.
- Total: no .swift files changed, +0 −3 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 154.

## Beta Commit 233

- **A send preview is one record** (`SendNetworkStep.swift`,
  `SendFlowState.swift`, `AppState+SendFlow.swift`, `CoreModels.swift`): core's
  `SendPreview` carries the fee, spendable balance, maximum and its `terms` (EVM
  fee terms, UTXO inputs and change, or flat) in place of a per-chain enum plus
  `SendPreviewDetails`; the fee card no longer lists Monero's priority, Sui's
  gas budget and reference price, or Aptos's gas amount and unit price.
- History refresh by chain passes chains rather than chain ids
  (`.chains(chains:)`).
- Total: 8 .swift files changed, +44 −86 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 154.

## Beta Commit 232

- **A card taller than the GPU texture limit keeps its glass**
  (`SpectraLayout.swift` `CardGlass`): inside a scroll view the glass is at most
  twice the viewport's height and slides along the card as it scrolls (before: a
  card past about 2,700pt, such as Add Wallet's chain list, lost its glass).
- A wallet's holdings are a row group whose hidden holdings fold under a footer
  button, each with Show (`WalletFlowViews.swift`).
- The Cardano icon is redrawn as circles.
- Total: 2 .swift files changed, +98 −44 lines; data and config files:
  `swift/Assets.xcassets/crypto/cardano.imageset/cardano.svg`; dependencies
  unchanged; test functions unchanged at 154.

## Beta Commit 231

- **CLI acceptance moves to `tests/`** (`Makefile`, `.github/workflows/ci.yml`:
  `tests/cli-acceptance.sh`); `BEHAVIOUR-CHANGES.md` is no longer referenced
  (`AGENTS.md`, `README.md`, `OPEN-ITEMS.md`), and `scripts/README.md` drops the
  suites and generators that moved.
- The wiki lookup dictionaries in `CoreReferenceTables` and
  `AppState.transactionCount` are removed; `WalletDerivationOptionsView` no
  longer takes the store.
- Docs: `AGENTS.md`; `README.md` (`tests/` and fixtures); `OPEN-ITEMS.md`;
  `scripts/README.md`.
- Total: 7 .swift files changed, +23 −142 lines; data and config files:
  `.github/workflows/ci.yml`, `Makefile`; dependencies unchanged; test functions
  unchanged at 154.

## Beta Commit 230

- **An asset's page shows a wallet breakdown instead of where the coin lives**
  (`DashboardViews.swift` `AssetWalletBreakdownCard`; `AssetPlacesCard.swift`
  deleted): for a known token an info button opens its Known Tokens detail; the
  asset's identity comes from its largest holding.
- `AGENTS.md`: "Do not git commit or push unless I said so" replaces the longer
  Git rule.
- Total: 5 .swift files changed, +88 −171 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 154.

## Beta Commit 229

- `scripts/README.md` describes each CLI acceptance suite by what only the
  binary shows: state across processes, sends built, signed and broadcast once
  in separate processes, and multisig across data directories (several suites'
  rule checks dropped from their descriptions). No code changed.
- Docs: `scripts/README.md`.
- Total: no .swift files changed, +31 −44 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 154.

## Beta Commit 228

- **The app's log lines are failures only**
  (`DiagnosticsState.appendOperationalLog`,
  `AppState+OperationalTelemetry.swift`, `LogsView.swift`): the level, wallet
  id, transaction hash and metadata arguments are gone; every line Swift writes
  is an error, and core logs the rest. The logs view no longer shows or searches
  by wallet.
- Unused code removed: `Chain.isTestnet`, `TransactionRecord.statusText`,
  `ImportDraft.isWatchOnlyMode`, the fee-with-fiat formatter,
  `DiagnosticsState.reset`, the `ContentView` preview, several unused view
  parameters; `Date.appFormatted` takes only a time style.
- `scripts/export-swift-icons.sh` exports only the crypto group (the fiat group
  is gone) and skips a PNG newer than its SVG (before: an MD5 sentinel).
- Docs: `OPEN-ITEMS.md` (finished "Single-wallet setup", "Wallet details" and
  multisig items deleted, about 560 lines); `AGENTS.md` (crypto icons only; no
  generator patch); `README.md` (four targets, `check-ui` by hand);
  `FFI-BOUNDARY.md` (`RefreshObserver`); `IOS-UI.md`; `scripts/README.md`.
- Total: 36 .swift files changed, +96 −727 lines; data and config files:
  `resources/strings/` (3), `scripts/` (2), `.gitignore`, `Makefile`;
  dependencies unchanged; test functions unchanged at 154.

## Beta Commit 227

- **A seed reveal answered during Face ID shows on return**
  (`SeedPhraseRevealState.swift`): an inactive scene is not one the app left, so
  a phrase or error that arrives while the authentication sheet is up waits and
  is shown when the scene is active again (before: it was dropped); going to the
  background still drops it.
- **A custom token names its standard where the network has several**
  (`AddCustomTokenView.swift`, `TokenPreferencesState.addCustom(standard:)`):
  the form picks from the network's `tokenStandards` (Tron's TRC-10 and TRC-20,
  Aptos's coin type and fungible asset), each with its own identifier prompt;
  core refuses a missing or unsupported standard in words.
- The reset page and the settings rows that open it are laid out again
  (`ResetWalletWarningView.swift`, `SettingsViews.swift`).
- Tests: 5 new, 1 removed
  - Seed reveal 4: a phrase or error during Face ID lost or shown while
    inactive; a waiting answer shown after the background; a removed wallet's
    phrase shown (replaces the hidden-scene test).
  - Custom tokens 1: a Tron token added without a standard, or a TRC-10 ID
    stored as TRC-20.
- Total: 8 .swift files changed, +222 −90 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 150 → 154.

## Beta Commit 226

- **Launch shows the logo until core has read the store**
  (`AppState.storeStatus`, new `StoreStatus` in `AppStateTypes.swift`,
  `ContentView.swift` `SpectraLogoScreen`): the tabs are drawn only once core
  answers, with the wallets already read (before: Home showed the no-wallet
  welcome first, then the wallets or the unreadable cover). A store that fails
  to open for another reason is logged and opens; only unreadable data gets the
  discard cover, and a discarded store starts again from the launch screen.
- **Receive lists wallets as Home does** (`ReceiveFlowViews.swift`,
  `WalletFlowViews.swift`, new `FlowPageHeading.swift` from
  `SendFlowPageHeading`): network, holdings and watch-only state on each row
  under "Choose a wallet to receive into"; watching is said on the network line.
- A wallet's page closes when the wallet is deleted under it
  (`DashboardViews.swift`).
- Tests: 2 new
  - Store status 2: a readable store opening without its wallets or through the
    welcome; unreadable data not recognised as such.
- Total: 11 .swift files changed (2 new), +191 −120 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 148 → 150.

## Beta Commit 225

- **App-wide UI rules, applied across the screens** (`IOS-UI.md`; new
  `SecretShield.swift`, `SecretWordField.swift`, `BalanceText.swift`,
  `AddressEntryRow.swift` (from `SendAddressInput.swift`, now
  `AddressInput.swift`), `CopyButton.swift`, `KeyboardAnchor.swift`,
  `SpectraDisclosureStyle.swift`, `SendCostRows.swift`,
  `WalletToolSections.swift`, `DeviceBiometry.swift`)
  - A phrase or key on screen is blurred while the screen is recorded or shared,
    and a screenshot is answered with a warning; seed words are typed in a field
    with every keyboard aid off.
  - Every hideable amount goes through `BalanceText`, which masks it and tells
    VoiceOver; prices are never masked.
  - Every recipient field is an `AddressEntryRow`: typed, pasted, scanned (read
    by core against the network, so a payment URI yields its address and another
    network's code is refused) or picked from contacts.
  - Flows put their primary action in a bottom bar that rides the keyboard over
    the content, hide the tab bar, and step back one page at a time; tool sheets
    that send close with Cancel until a node accepted, then Done.
  - Hashes and payloads wrap without hyphens and copy whole; dates and numbers
    are formatted in the app's language.
  - Wallet tool pages share loading, error and empty sections; the unlock button
    names the device's biometry.
- **Home** (`DashboardViews.swift`, `AppState+Dashboard.swift`): rows worth less
  than core's small-balance threshold fold behind one row (new "Hide small
  balances" preference, on by default); a total with no balance read yet shows
  as loading, and one that leaves wallets or unpriced assets out says so under
  the figure; notices open where they are fixed (retry, endpoints) or can be
  dismissed; an asset's page shows its value, where it is held, Send/Receive
  from wallets that can, and where it lives.
- **History** (`HistoryView.swift`): rows grouped by unconfirmed, today,
  yesterday and month; each row names what the transaction did (a stake reads as
  a stake); search runs after typing pauses and keeps old rows dimmed until the
  answer lands; filters narrow the list; Speed Up and Cancel open the composer
  over the transaction. The History tab badges sends still waiting on their
  network, and the tab bar minimizes on scroll.
- **Receive** (`ReceiveFlowViews.swift`): a payment request with an amount in
  the network's coin and a memo where the network takes one, encoded by core's
  payment code; the address shows in core's display form (checksummed EVM case);
  sharing sends the text with the QR image; a watched address carries a warning.
- **Send** (`SendFlowViews.swift`, `SendPrimarySectionsView.swift`,
  `SendFlowState+Preview.swift`, `SendStagesView.swift`): fee overrides start
  from the quote's own terms and an unparsed override asks for no quote; a
  failed quote is shown apart from build and broadcast errors and nothing builds
  without a fee; core's recipient warnings (never sent to, no history) show
  before the build; the signing confirmation states the reviewed network fee;
  the composer is pushed on the tab it was opened from.
- **Funds Finder imports every found account at once** (`FundsFinderView.swift`,
  `AppState.importWallets`): one optional password, each import in turn with
  core's answer; importing one account opens over the results, which stay for
  the next.
- **An unreadable store has a recovery screen** (`ContentView.swift`
  `UnreadableStoreCard`, `discardUnreadableStore`): after authentication the
  store and its wallets' secrets are discarded and the app starts on an empty
  one.
- **Settings** (`SettingsViews.swift`): glass cards grouped by what the user
  looks after, with the display currency chosen in place; the send-confirmation
  switch and the Report a Problem link sit on the tab itself, and the Advanced,
  Pricing and Report a Problem pages are deleted (`AdvancedSettingsView.swift`,
  `PricingSettingsView.swift`, `ReportProblemView.swift`).
- Face ID and photo-library usage descriptions reworded (`Info.plist`).
- Tests: 6 new, 1 removed
  - Send 4: an override starting blank or losing what was typed; an unparsed
    override asking for a quote; the signing summary without the reviewed fee;
    an accepted submission offered a retry (replaces the inspect-or-retry test).
  - Seed entry 1: several words in one slot not filling the slots after it.
  - Staking 1: a failed build dropping the password or showing the error away
    from the form.
- Docs: `IOS-UI.md` (row groups and sections, empty states, flows, secrets,
  balances, addresses, disclosures, keyboard, hashes, dates and numbers,
  unavailable totals).
- Total: 114 .swift files changed (10 new), +4617 −2252 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `swift/Info.plist`;
  dependencies unchanged; test functions 143 → 148.

## Beta Commit 224

- **Closing a wallet form no longer crashes on a created phrase**
  (`WalletImportSession.swift`, `WalletSecretStep.swift`): each form gets a new
  draft and the closing pages keep theirs (before: the draft was cleared in
  place, emptying the phrase under its grid during the pop transition); the
  phrase and backup cells draw the word they were given rather than an index
  into the list.
- Tests: 1 new
  - Import session 1: dismissal clearing the draft a closing page still shows,
    or the next form inheriting it.
- Total: 3 .swift files changed, +29 −6 lines; data and config files: none;
  dependencies unchanged; test functions 142 → 143.

## Beta Commit 223

- **Multisig on every network that has one, from the wallet's page** (new
  `WalletMultisigView.swift`, replacing `WalletPsbtView.swift`): the page shows
  the account's address, signers with weights and thresholds, and what else can
  move or block its funds; sessions are built, read from another signer, signed,
  handed on and submitted once enough have signed. Core decides who may sign and
  how a session reaches the network.
- Watch Multisig takes the network's own policy format
  (`watchMultisig(policy:)`): a `sortedmulti` descriptor, Sui's weighted public
  keys, Aptos's MultiKey, a Cardano native script or a Substrate threshold with
  signatories; the field's prompt comes from core's setup descriptor.
- Staking amounts format through core's `formatNativeAmount` (before:
  `formatStakingAmount`).
- Docs: `OPEN-ITEMS.md` "Multisig accounts" (Safe on EVM, Tron permissions and
  the other networks done; signer-set changes, token spends and Substrate
  cancellation open); `scripts/README.md`.
- Total: 11 .swift files changed (1 new), +1355 −304 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 142.

## Beta Commit 222

- **New watch and import methods** (`ImportDraft.swift`, `SetupFlow.swift`,
  `WalletSetupViews.swift`, `AddWalletEntryView.swift`,
  `WalletSecretStep.swift`)
  - Watch with View Key: a Monero wallet's primary address and private view key,
    with a restore height; the sync screen notes that a view key does not see
    spends.
  - Watch Multisig: a Bitcoin-family multisig account from its output
    descriptor.
  - Substrate phrase imports take an optional junction path (`//hard`, `/soft`).
  - The account public-key field's prompt lists the network's prefixes from core
    (`Chain.accountKeyPrefixes`; before: xpub/ypub/zpub).
  - The restore-height card is shared (new `RestoreHeightCard.swift`).
- **A multisig wallet's page handles its PSBTs** (new `WalletPsbtView.swift`):
  create one, read one a cosigner sent, and open one to sign, hand on or
  broadcast once enough cosigners have signed, each reviewed by core against the
  wallet's policy.
- `Chain.supportsDeepUTXODiscovery` becomes `usesAccountUTXO` (core's
  account-of-addresses flag).
- Docs: `OPEN-ITEMS.md` (Monero subaddresses and view-only import, account
  recovery for ZEC/BTG/DCR/KAS/DASH, Substrate junctions, Bitcoin multisig and
  PSBT, non-Bitcoin account keys done).
- Total: 18 .swift files changed (2 new), +671 −105 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 142.

## Beta Commit 221

- **NEAR token storage deposits can be refunded** (new
  `WalletTokenStorageView.swift`, Token Storage action): lists the token
  contracts holding a deposit the account can have back and unregisters one
  through the send stages; history names Refund Token Storage.
- **A Cardano wallet's network page shows its stake address**
  (`WalletNetworkAccountView.swift`): stake address, rewards, delegated pool and
  voting delegation, with a notice when the stake key is not registered.
- Docs: `OPEN-ITEMS.md` (NEAR storage refunds and Cardano stake address done);
  `scripts/README.md`.
- Total: 5 .swift files changed (1 new), +234 −8 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 142.

## Beta Commit 220

- **Sends carry an XRP destination tag or a Stellar memo** (new
  `SendPaymentMemoField.swift`; `SendFlowState.swift`,
  `SendPrimarySectionsView.swift`, `SendStagesView.swift`,
  `SendTransferPartiesView.swift`): the composer offers the kinds core's
  `paymentMemoKinds(chain:)` names (destination tag, text memo, ID memo), the
  value goes to core with the send and shows on the review; choosing another
  holding clears it. Closing an XRP or Stellar account into another takes one
  too (`WalletNetworkAccountView.swift`).
- **A NEAR token send that registers its recipient says so**
  (`SendStagesView.swift`, `SendFlowState+Execution.swift`): the review shows
  the registration deposit, and the signing confirmation states it.
- Tests: 2 new
  - Payment memo 1: a memo offered where core names no kind, or kept after the
    holding changes.
  - Recipient registration 1: a NEAR registration deposit not confirmed before
    signing.
- Docs: `OPEN-ITEMS.md` (Decred destination scripts, Cardano base addresses,
  XRP/Stellar memos and NEAR recipient registration done; Cardano stake address
  and rewards added); `scripts/README.md`.
- Total: 12 .swift files changed (2 new), +233 −23 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 140 → 142.

## Beta Commit 219

- **Private funds on Zcash and Litecoin** (new `WalletShieldedFundsView.swift`,
  `WalletMwebFundsView.swift`, `ScanRun.swift`): a Zcash wallet's page scans its
  shielded pools through lightwalletd from the restore height, shows its unified
  address, shields transparent funds and pays from the shielded pool; a Litecoin
  wallet's page does the same for MWEB (scan, stealth address, peg-in, payment).
  Scans run one core batch at a time and resume where a cancelled run stopped. A
  restored scanning wallet asks for a restore height (before: Monero only).
- **EVM NFTs** (new `WalletNftsView.swift`): an EVM wallet lists its ERC-721 and
  ERC-1155 tokens from Blockscout and sends one through the send stages; token
  images are not loaded.
- **XRP and Stellar trust lines** (new `WalletTrustLinesView.swift`): list the
  wallet's issued assets, trust another asset and remove an empty line; history
  names Trust Asset, Remove Trust Line and Shield.
- **A token's transfer terms are confirmed before signing**
  (`SendStagesView.swift`, `SendFlowState+Execution.swift`,
  `AssetTransferTerms`): the review shows a Token-2022 fee and what the
  recipient receives, the ADA a Cardano native asset carries, and a
  transfer-hook program; the signing confirmation repeats them.
- Custom tokens use the network's identifier prompt and its fixed decimals where
  the protocol sets them (`AddCustomTokenView.swift`).
- Tests: 3 new, 1 removed
  - Transfer terms 2: a token fee or carried ADA not confirmed before signing.
  - Restore height 1: a restore height asked outside a restored scanning wallet
    (replaces the Monero-only test).
- Docs: `OPEN-ITEMS.md` (MWEB, Zcash shielded, issued assets, Cardano native
  assets, Token-2022 and NFTs done; NEAR storage deposits and recipient
  registration, CIP-113 programmable tokens added); `scripts/README.md` (NFT,
  Zcash, MWEB and issued-asset suites and vector generators).
- Total: 19 .swift files changed (5 new), +1761 −54 lines; data and config
  files: `.github/workflows/ci.yml`, `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 138 → 140.

## Beta Commit 218

- **A wallet's page is its home, drawn from core's `WalletActions`**
  (`WalletFlowViews.swift`, new `WalletActionsViews.swift`)
  - Send, Receive and this wallet's History start from the page
    (`beginReceive(walletId:)`, `HistoryListView` for one wallet); the network's
    own actions are listed one row each with what they do, and the network's
    limits from the setup summary appear when there are any.
  - The address opens in the network's explorer (`explorers()` with address
    templates; Explorer settings show them).
- **The Staking tab is removed; staking starts from the wallet**
  (`StakingView.swift` → `WalletStakingView.swift`, `MainTabView.swift`): a
  wallet on a staking network shows its positions and actions on its page.
  Monero's sync moves from Send to the wallet's page.
- **New wallet actions** (new views under `swift/views/`)
  - Add this wallet's key to another network (`WalletCopyView`): core reads the
    sealed secret and runs the target network's import; each target previews its
    address.
  - Give a watched wallet its keys (`WalletSetupMethodsView` with `upgrading`,
    `walletUpgradeMethods`, `beginWalletUpgrade`): the network's phrase or key
    methods bound to that wallet.
  - Export keys in the network's formats (`WalletKeyExportView`) and sign or
    verify a message (`WalletMessageView`), behind Face ID and the wallet
    password; the app-lock reason `revealSeedPhrase` becomes `secretMaterial`.
  - Bitcoin family: owned addresses and unspent outputs (`WalletCoinsView`).
    EVM: token approvals with revoke (`WalletApprovalsView`). Solana: close
    empty token accounts (`WalletTokenAccountsView`). Sui: merge coin objects
    (`WalletCoinObjectsView`). NEAR: access keys with deletion of function-call
    keys (`WalletAccessKeysView`).
  - Tron resources, XRP and Stellar reserves with account closing, TON contract
    state, Polkadot/Bittensor balance parts, ICP principal and test-network
    faucets (`WalletNetworkAccountView`).
  - The transactions these pages build are signed and broadcast through shared
    stage sections (`SendArtifactStageSections.swift`).
- **A Monero send's detail offers its payment proof** (new
  `MoneroPaymentProofView.swift`, `TransactionDetailView.swift`): transaction,
  tx key and address, checkable with `check_tx_key`.
- Docs: `OPEN-ITEMS.md` "Wallet details" (the plan, with its finished items
  checked; Cardano base addresses and XRP/Stellar destination tags open);
  `scripts/README.md`.
- Total: 38 .swift files changed (12 new), +3010 −235 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 138.

## Beta Commit 217

- **TON imports choose the wallet version** (`ImportDraft.tonWalletVersion`,
  `WalletSecretStep.swift`, `CoreModels.swift` `TonWalletVersion`): a segmented
  W5/v4R2 picker on TON's phrase and key pages, W5 by default, sent with the
  commit when core's setup option asks for it; the used-accounts scan sets the
  version it found used, and the wallet detail names its version.
- Addresses in the setup preview wrap without layout hyphens
  (`breakableAnywhere`, moved to `SpectraLayout.swift`) and are no longer
  selectable.
- `make test-ios` runs with `-collect-test-diagnostics never`.
- Docs: `OPEN-ITEMS.md` (TON wallet version done); `scripts/README.md` (token,
  XRP, derivation-profile, private-key, TON mnemonic and W5, Monero phrase and
  checkpoint vector generators).
- Total: 8 .swift files changed, +122 −37 lines; data and config files:
  `Makefile`, `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 138.

## Beta Commit 216

- **Add Wallet chooses the network first, then how to add it**
  (`AddWalletEntryView.swift` `WalletSetupMethodsView`,
  `AllChainsSelectionView.swift`, `SetupFlow.forMethod`, `ImportDraft.swift`,
  `WalletSetupViews.swift`)
  - Add Wallet is the network picker, with Find Lost Funds above the list; a
    network's page lists the methods core's `walletSetupDescriptor` offers there
    (create, phrase, private key, watched addresses, account xpub), each with
    the formats it accepts (before: a fixed list of five entries, then a chain
    picker).
  - Every setup creates one wallet on one network; the multi-chain selection,
    the chain page and the per-method `SetupFlow`s are gone, and the pages
    follow from the method.
  - The phrase grid follows the network's own formats (`SeedPhraseEntry.chain`,
    `seedPhraseLengths(chain:)`): Monero's 25-word seed and Polyseed, TON's
    mnemonic, BIP-39 elsewhere; created phrases are in the network's format; new
    problems are worded (ambiguous language, encrypted or unsupported Polyseed).
  - The private-key page names the network's expected key format; NEAR's page
    asks for a named account.
  - Seed imports pick a per-network derivation profile and account index
    (before: Standard/Account 1/Account 2 presets for every chain).
- **The setup shows what it will store and what the wallet will do** (new
  `WalletAddressPreviewCard.swift`, `WalletSetupSummaryCard.swift`)
  - Each page previews the address core will store, derived by the same planning
    as the import and refreshed after typing settles; nothing is sent or stored.
  - The last page lists the network's capabilities and limits from core
    (history, token discovery, staking) and the endpoints the first refresh will
    read, with "Use only my endpoints" before the address is sent anywhere.
- **Used accounts are found on request** (new `UsedAccountsSheet.swift`;
  `FundsFinderView.swift`): a network's page can scan its profiles at the first
  accounts after naming the endpoints that will receive the addresses; choosing
  a used account sets the import's profile and account. A Funds Finder hit opens
  the single-wallet import prefilled with network, phrase, profile and account
  (before: the scan ended at the result).
- **A copied seed phrase stays on this device for a minute** (new
  `SecretPasteboard.swift` `copySecretToPasteboard`): local-only and expiring,
  used by the create page and a new Copy button on the wallet's seed sheet.
- **Monero's restore height is set at import** (`MoneroSyncView.swift`,
  `MoneroSyncViewModel.swift`): the sync screen no longer asks for it.
- **Receive warns about a reserve network's first payment**
  (`ReceiveFlowViews.swift`, `accountReserve`): while an XRP- or Stellar-style
  account holds nothing, the page states the minimum it must first receive.
- The wallet detail names its derivation path by profile and account when core
  reads it as one.
- Tests: 15 new, 7 removed
  - Setup methods 9: a network offering a method it cannot do or no phrase; a
    method walking another's pages; the commit missing the profile, account or
    method's data; the preview deriving from an incomplete secret or carrying
    the password; a named account asked on the wrong network; creation on more
    than one network; a restore height asked outside a restored Monero wallet; a
    cleared form still on a network (replace four multi-chain offer tests).
  - Seed formats 2: the grid or a created phrase not in the network's format.
  - Pasteboard 1: a copied secret not reading back as text.
  - Copy and refusals 3: watch-page and edit-page titles; a private key on a
    chain without key derivation refused in English (replace the two-chain
    tests).
- Docs: `OPEN-ITEMS.md` "Single-wallet setup" (the plan, with its finished items
  checked; TON W5 open).
- Total: 39 .swift files changed (5 new), +1898 −869 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 130 → 138.

## Beta Commit 215

- **`AppState`'s domains are their own observable objects** (new
  `AddressBookState.swift`, `TokenPreferencesState.swift`,
  `PriceAlertsState.swift`, `TorState.swift`, `HistoryPagingState.swift`,
  `SendFlowState+Execution.swift`, `SendFlowState+Preview.swift`,
  `StateCommandQueue.swift`; `AppState+Notifications.swift` and
  `AppState+SendLiveActivity.swift` renamed to `PlatformNotifications.swift` and
  `PlatformNotifications+SendLiveActivity.swift`; the matching `AppState+…`
  extensions deleted or emptied): views read the domain object rather than the
  store; every `StateCommand` goes through one queue that keeps the user's order
  and adopts what core committed. Behaviour unchanged.
- Tests: 1 new
  - History paging 1: two page fetches running at once.
- Docs: `OPEN-ITEMS.md` (the `AppState` split item removed).
- Total: 62 .swift files changed (10 new), +1040 −880 lines; data and config
  files: `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 129 → 130.

## Beta Commit 214

- **Core types have one name** (`CoreModels.swift`, `ChainTypes.swift`,
  `RegistryModels.swift`, `DashboardViews.swift` and their callers): the nine
  Swift typealiases are gone and the app uses the binding names (`Coin` →
  `AssetHolding`; `CorePersistedTransactionRecord` → `TransactionRecord`;
  `SeedDerivationPreset`, `TransactionDirection`, `DashboardAssetGroup` without
  `Core`); behaviour unchanged.
- The send fee card no longer lists sequence, last-ledger, TTL-slot or
  sequence-number rows for XRP, Stellar, Cardano and TON; the validator picker
  no longer shows APY.
- `make lint` adds `unwritten-record-fields.sh`, which reads rustc's MIR to find
  FFI record fields production code never writes.
- Docs: `FFI-BOUNDARY.md` (one name per type, `LocalizableMessage`,
  `ResidentState`, the record-field scan); `OPEN-ITEMS.md` (record-field and
  type-naming items removed); `scripts/README.md`.
- Total: 32 .swift files changed, +121 −167 lines; data and config files:
  `.github/workflows/ci.yml`, `Makefile`,
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `scripts/unused-strings.sh`;
  dependencies unchanged; test functions unchanged at 129.

## Beta Commit 213

- **Source scans run in `make lint` and CI** (`Makefile` `SOURCE_SCANS`,
  `.github/workflows/ci.yml`): unreachable exports, uncalled core functions,
  unused strings and `swift-shell-literals.sh` (the app may not spell chain
  names or amount precision itself).
- `AGENTS.md`, `README.md`, `FFI-BOUNDARY.md` and `scripts/README.md`: a rule is
  tested in core with `cargo test`; CLI acceptance covers only what the binary
  alone shows (before: every domain rule had to be drivable from the CLI).
- Docs: `AGENTS.md` architecture and verification; `README.md` targets;
  `FFI-BOUNDARY.md` coverage; `scripts/README.md` acceptance suites and scans.
- Total: no .swift files changed, +42 −26 lines; data and config files:
  `.github/workflows/ci.yml`, `Makefile`; dependencies unchanged; test functions
  unchanged at 129.

## Beta Commit 212

- **Coin tags are core's `TokenTag`** (new `swift/views/TokenTag.swift`,
  `CryptoWikiViews.swift`): the wiki filter is one typed list of coin tags
  (Stablecoin, Meme) and chain tags, titled by the app (before: tag strings).
- Total: 2 .swift files changed (1 new), +48 −12 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 129.

## Beta Commit 211

- **The wiki's chain tags are core's `ChainTag`, the same the chain picker
  uses** (new `swift/views/ChainTag.swift`, moved from
  `ChainSelectionDescriptor.swift`; `CryptoWikiViews.swift`,
  `ChainWikiViews.swift`): tags are titled by the app; chain search also matches
  consensus and state model.
- Tests: 1 new
  - Chain tags 1: the wiki and the picker showing different tags for a chain.
- Total: 5 .swift files changed (1 new), +40 −24 lines; data and config files:
  none; dependencies unchanged; test functions 128 → 129.

## Beta Commit 210

- No app code changed: a test covers Peercoin and its testnet, which core added,
  in the chain picker, the wiki and asset precision.
- Tests: 1 new
  - Peercoin 1: Peercoin missing from the picker or wiki, drawn without its
    mark, its testnet listed as a mainnet, or wrong native precision.
- Docs: `OPEN-ITEMS.md` (endpoint audit; the 2026-10-04 gap list: Decred P2SH
  outputs, Litecoin MWEB, Zcash shielded, XRP/Stellar issued assets, Cardano
  native assets, Token-2022 extensions, NFTs, Monero accounts and view-only
  import, account recovery for ZEC/BTG/DCR/KAS/DASH, Substrate junctions,
  Bitcoin multisig, non-Bitcoin xpubs, EVM and Substrate history providers,
  testnet providers, wider staking, Peercoin minting).
- Total: 2 .swift files changed, +178 −13 lines; data and config files: none;
  dependencies unchanged; test functions 127 → 128.

## Beta Commit 209

- **The staking tab stakes** (`StakingView.swift`, `StakingViewModel.swift`; new
  `StakingOperations.swift`, `StakingPositionsView.swift`,
  `StakingTransactionView.swift`; before: information and validator lists only)
  - A chain's page shows its mechanics card, a wallet picker for wallets with an
    address on the chain, and a watch-only note for wallets that cannot sign.
  - Positions are read from core (`fetchStakingPositions`, with the wallet
    password where the chain's rules require it, plus an optional extra pool);
    each lists staked, unbonding, withdrawable and reward amounts, unlock time
    or epoch, and the actions core allows on it.
  - A stake, unstake, withdraw or claim is built by core (`buildStaking`) from a
    validator (typed or picked from a searchable list with commission and APY),
    an amount where allowed and an ICP dissolve delay.
  - The review shows action, amount, validator, position, fee (or its upper
    bound), refundable deposit and delayed-payout notes; signing and
    broadcasting are separate confirmed steps, broadcast goes to the nodes the
    user selects.
  - Pending staking transactions can be rechecked, an interrupted ICP neuron
    repaired with a new review, and saved staking transactions resumed without
    building or signing again.
- **History and transaction detail know staking kinds** (`CoreModels.swift`,
  `HistoryView.swift`, `TransactionDetailView.swift`): stake, unstake, withdraw
  and claim rewards have titles; the amount's sign and colour come from core's
  `transactionKindDirection` (neutral for unstake), and "Created/Broadcast" from
  `transactionKindIsSubmitted` (before: send versus receive in Swift).
- **The send composer is rebuilt** (`SendPrimarySectionsView.swift`,
  `SendStagesView.swift`, `SendConfirmationStep.swift`, `SendFlowViews.swift`;
  new `SendAddressInput.swift`, `SendAmountSummaryView.swift`,
  `SendTransferPartiesView.swift`, `SendExecutionAction.swift`)
  - Each page has a heading; the asset and exact wallet network stay visible;
    the recipient shows who core says holds it (your wallet, saved contact).
  - The address field wraps by character without hyphens and grows to show the
    whole address at any text size; amounts wrap rather than truncate.
  - From and To parties and fee rows share one card; the signed amount comes
    from the reviewed artifact, not a new quote.
  - The stage action (build, sign, broadcast, retry the same transaction, view
    in explorer, done) is derived from core's artifact and history record; a
    node's acceptance is not shown as confirmation, and retry is offered only
    when core allows a rebroadcast.
  - The signing confirmation lists amount, chain, full recipient and core's
    warnings, including self-send.
- Fiat currency icons (USD, EUR, GBP, CNY) removed; the Monad icon redrawn.
- Strings: staking copy added under `staking.*`; the "stuck after retries"
  failure wording removed.
- Tests: 20 new, 1 removed
  - Staking view model 10: an old wallet's or late position read replacing a
    newer one; closing during authorization still using the key or signing;
    build, sign and broadcast without separate intent or with a different review
    digest; a broadcast lost on closing; a status recheck changing the
    operation; resuming rebuilding or re-signing; a neuron repair without a
    fresh review.
  - Send actions 7: build, sign and broadcast merged; a confirmed or foreign
    receipt not finishing the send; retry offered without core's capability; the
    signing summary rounding the amount or cutting the recipient.
  - Rendering 3: send composer and stage screens, and staking screens, across
    appearances and large type (one stage-render test replaced).
- Docs: `OPEN-ITEMS.md` (OP Stack receipt fees, 59-token provenance, Monad
  history, TON jetton identity, staking execution and staking reads removed);
  `scripts/README.md` (core CLI acceptance and staking vector scripts,
  `source_scan.py`).
- Total: 32 .swift files changed (13 new), +5215 −2781 lines; data and config
  files: `swift/Assets.xcassets/` (10), `scripts/` (4), `resources/strings/`
  (3); dependencies unchanged; test functions 108 → 127.

## Beta Commit 208

- **Detail screens drop a read the screen has moved past**
  (`TransactionDetailView.swift` `loadTransactionDetailProjection`,
  `DiagnosticsViews.swift`, `EndpointsViews.swift`): the transaction and its
  endpoints are read as one projection and adopted only if the task was not
  cancelled, so a late read cannot replace a newer status or address holder;
  diagnostics and the endpoint directory likewise ignore results of a cancelled
  task.
- The "MWEB · Privacy Send" badge on the send recipient field is removed
  (`SendPrimarySectionsView.swift`).
- Core's new `executionFailed` reason reads "The transaction failed during
  on-chain execution."
- Tests: 3 new
  - New EVM chains 2: a Plasma, Monad or World Chain import losing its chain or
    address across the bridge; a new chain missing from the picker or drawn with
    another chain's identity. The badge test also covers World Chain and Ether
    on it.
  - Transaction detail 1: a cancelled read replacing a newer status or holder,
    or starting an endpoints read.
- Docs: `OPEN-ITEMS.md` (OP Stack receipt fees, Monad history and token
  discovery; Plasma and Monad support items removed).
- Total: 10 .swift files changed (1 new), +190 −43 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 105 → 108.

## Beta Commit 207

- **New custom tokens and contacts start without a guessed chain**
  (`AddCustomTokenView.swift`, `AddressBookContactViews.swift`): the chain may
  be unset, Save stays disabled until one is chosen, and an address is checked
  only once a chain is ("Select a chain first."); editing a token whose chain
  cannot hold tokens says so (before: the token form fell back to Ethereum).
- Crypto icons for Gram and WETH; strings for core's Aptos gas-limit and
  gas-budget refusals.
- Docs: `OPEN-ITEMS.md` (certify 59 token contract identities, with the
  deployment list; canonicalize TON jetton master addresses).
- Total: 2 .swift files changed, +181 −15 lines; data and config files:
  `swift/Assets.xcassets/` (4), `resources/strings/` (3); dependencies
  unchanged; test functions unchanged at 105.

## Beta Commit 206

- Chain names follow core's catalog ("Bitcoin Testnet 4", "BNB Smart Chain") in
  a doc comment and the network-title test.
- Docs: `OPEN-ITEMS.md` (support Plasma with EURC and USDC, support Monad with
  CAKE).
- Total: 2 .swift files changed, +13 −2 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 105.

## Beta Commit 205

- **A seed-phrase reveal belongs to the screen that asked for it** (new
  `swift/SeedPhraseRevealState.swift`, `WalletFlowViews.swift`): a reveal that
  completes after the screen disappeared, the app went to the background or the
  wallet was removed is dropped and does not show the phrase or an error;
  backgrounding invalidates the request; the password field is cleared as the
  prompt closes.
- **A Monero sync run has its own lifetime** (new
  `swift/MoneroSyncViewModel.swift`, `MoneroSyncView.swift`): each run carries a
  request id, so a cancelled or replaced run cannot update the status or report
  an error.
- Crypto icons for Monad and Plasma; Raydium and sUSDS icons changed.
- Tests: 7 new, 1 removed
  - Seed reveal 4: a late phrase or error shown on a hidden, dismissed or
    backgrounded screen, or after the wallet was removed; an old cleanup ending
    a new reveal.
  - Monero sync 2: a cancelled run overwriting a restarted scan or submitting
    after its task was queued.
  - Amount presentation 1: a partial total not shown as the valued figure alone
    (moved from `AppStateTests`).
- Docs: `OPEN-ITEMS.md` staking-reads item (ICP and Polkadot make no network
  requests).
- Total: 12 .swift files changed (4 new), +434 −145 lines; data and config
  files: `swift/Assets.xcassets/` (6), `Makefile`, `scripts/` (1),
  `swift/Spectra.xcodeproj/` (1); dependencies unchanged; test functions 99 →
  105.

## Beta Commit 204

- **Crypto icons for Lombard Bitcoin, Peercoin, Pyth Network, Raydium and Rocket
  Pool ETH** (`swift/Assets.xcassets/crypto/`); the Pepe icon is redrawn.
- Total: no .swift files changed, +170 −21 lines; data and config files:
  `swift/Assets.xcassets/` (11); dependencies unchanged; test functions
  unchanged at 99.

## Beta Commit 203: Migration done

- **Rule 0 moves into `AGENTS.md`** and `PLAN.md` is no longer referenced
  (`AGENTS.md`, `README.md`, `FFI-BOUNDARY.md`, `OPEN-ITEMS.md`): README says
  core owns domain state and decisions (before: the migration into Rust was
  underway); "Prefer deleting unnecessary Swift code over moving it into core".
- Core's refusal reasons reach the screen: a token save shows core's message and
  logs the error (before: "This token could not be saved."); the wallet-password
  minimum length comes from core's `tooShort`; an invalid diagnostics bundle
  reads "That file is not a Spectra diagnostics bundle."
- Launch wiring renamed `startDeviceMonitoring` (battery and network path, read
  by core's `deviceConditions()`); the Tor cache directory moved into
  `WalletServiceBridge`.
- Docs: `AGENTS.md` "Rule 0", "Architecture"; `README.md`; `FFI-BOUNDARY.md`;
  `OPEN-ITEMS.md`.
- Total: 8 .swift files changed, +70 −43 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 99.

## Beta Commit 202

- **Core's sentences are translated by template** (`CoreMessage.localizedText`
  in `swift/Store+Formatting.swift`, `AppLocalization.format(_:arguments:)`): a
  refused or failed call's English template is the string-table key and its
  `args` fill it in; about 230 of core's sentences are added in all three
  languages (wallet import, derivation and send refusals among them).
  `scripts/unused-strings.sh` fails on a core sentence with values that the
  tables do not translate.
- **Decimal fields reach core with a point**
  (`AmountPresentation.canonicalDecimalInput`): the send amount, EVM fee
  overrides and the price-alert target replace the region's decimal separator
  (before: only the price alert did).
- **Prices and exchange rates are core's to refresh**
  (`AppState+PricingFiat.swift`)
  - The app no longer refreshes fiat rates at launch or after a currency change;
    core's engine fetches prices and rates in its sweep. The currency picker
    sends `updateSetting(.fiatCurrency)` like any other setting (before:
    `setFiatCurrency` plus a forced rate refresh).
  - Core reports why stored quotes were kept (`QuoteRefreshFailure`: no usable
    quote, unreachable) and the app words it ("… Showing the last known
    prices/rates."; before: core's text shown as is).
- **The wiki lists coins and chains in two sections** (`CryptoWikiViews.swift`,
  `ChainWikiViews.swift`): chains come from `CoreReferenceTables.chainWiki` and
  open their own page; search and tags cover both. A coin's page no longer lists
  where it is deployed (Known Tokens does), and a chain's page no longer has the
  derivation-paths card.
- **The Funds Finder reports a chain it could not read**
  (`FundsFinderView.swift`): the first failure per chain shows as "%@ addresses
  could not be checked", and "no funds found" is not shown while any chain went
  unread (before: a read error replaced the scan's error).
- **Save Recipient asks core who holds the address**
  (`SendConfirmationStep.swift`, `addressHolder`): hidden when the recipient is
  one of the user's wallets, "Recipient Already Saved" for a contact, rechecked
  when the address book changes (`canSaveRecipientToAddressBook` removed).
- Control limits come from core's `inputBounds()`: the custom-token decimals
  stepper and the large-movement percent range (before: 0…30 and 1…90 in Swift).
- Diagnostics state no longer keeps a persistence error;
  `DiagnosticsExportsBrowserModel` removed, the exports browser reads the store.
- Tests: 3 new
  - Decimal input 1: a comma-decimal amount reaching core unconverted.
  - Core messages 2: a templated core sentence shown untranslated or with its
    values lost; a two-chain private-key import refused in English.
- Docs: `OPEN-ITEMS.md` (new: tasks and known limitations); `FFI-BOUNDARY.md`
  `CoreMessage` templates; `README.md` doc list.
- Total: 32 .swift files changed, +1078 −277 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `scripts/unused-strings.sh`;
  dependencies unchanged; test functions 96 → 99.

## Beta Commit 201

- **Core seals seeds and private keys; the app only stores them and wraps core's
  device key** (`swift/SecureStores.swift` `SpectraSecretStoreAdapter`,
  `DeviceKeyWrapping`)
  - The Swift envelope (`SigningMaterialEnvelope`, `SealedSigningStore`,
    `SecureStore`) is removed: core seals signing material under its device key
    before it reaches the adapter and decides when that key is minted, reused or
    refused.
  - The adapter maps each `SecretClass` (seed, private key, generic, device key)
    to its Keychain service and implements the new
    `wrapDeviceKey`/`unwrapDeviceKey` with the Secure Enclave P-256 key (before:
    `MasterKeyWrapping` wrapped a Swift-held master key).
  - Keychain errors collapse to `keyWrapping` (before: `masterKeyUnavailable`,
    `sealFailed`, `openFailed`).
- **Network choice is per chain, not per family** (`AppState+Networks.swift`
  deleted; `AppState.selectedChain(forFamily:)` removed): diagnostics, endpoint
  probes, derivation options and send use the chain itself; watched addresses
  are checked with core's `isValidWatchOnlyAddress`.
- **Errors on screen are sentences** (`userErrorMessage` in
  `swift/Store+Formatting.swift`, used wherever `localizedDescription` was
  shown): core's `InvalidInput`/`Failure` messages are shown capitalized,
  network and decode failures get fixed sentences, other UniFFI errors
  "Something went wrong. Try again."; failed state commands also go to the
  operational log (`reportCommandError`).
- **Core follows wallet changes on its own** (`AppState.swift`,
  `AppState+DerivedState.swift`, `AppState+PricingFiat.swift`): the app no
  longer calls `reconcileWallets` after a wallet change or schedules a refresh
  after an import; `walletIdentityRevision` comes from core's snapshot (before:
  computed in Swift by comparing wallets without balances).
- **Before the first wallet the dashboard is a welcome card**
  (`DashboardWelcomeCard` in `DashboardViews.swift`): logo, "Welcome to Spectra"
  and Add Wallet, without the total, Send/Receive and the assets card. The Tor
  toolbar indicator shows only while Tor is not stopped.
- **Send reads core's answers** (`SendFlowViews.swift`,
  `SendPrimarySectionsView.swift`, `SendStagesView.swift`,
  `SendNetworkStep.swift`)
  - The recipient check keeps core's resolution, and the recipient field shows
    "Resolved ENS … to …" from it; continuing to confirm no longer resolves
    again (`verifySendDestination` call removed).
  - Sent amounts are named by core's `artifact.symbol` (before: looked up from
    the wallet's holdings by contract).
  - The UTXO fee card is gone: a UTXO preview uses the generic fee card, with
    rate, size, inputs and change as detail rows.
- **Lists keep core's order** (`TokenRegistrySettingsView.swift`,
  `WalletFlowViews.swift`): Known Tokens groups and a wallet's holdings are no
  longer re-sorted in Swift; history paging no longer caps a page at 200 and
  follows core's cursor.
- Transaction status notifications are sent only when core's change says
  `notify` (before: gated by the app setting in Swift); every change still
  updates the Live Activity.
- Appearance defaults to System (before: Dark).
- The backdrop is neutral with three faint clouds in the accent colour and one
  cool hue (before: four saturated hues over a blue-tinted gradient).
- The app icon gains a tinted variant (`SpectraLogo-Tinted`); the light and dark
  sources changed.
- The seed-length message lists core's lengths (before: "12, 15, 18, 21 or 24"
  written in the string); the private-key row no longer counts characters toward
  64.
- Tests: 6 new, 15 removed
  - Secret store 5: a class stored in another's Keychain service, a missing
    value not reported as not found, a deleted value still readable, the device
    key stored unwrapped, a corrupt wrapped key read as absent (replace the
    envelope tests).
  - Send stages 1: a token send summarized by its contract instead of core's
    symbol.
  - Removed: the per-family network-name tests, the endpoint-screens window test
    and the staking-table tests.
- Docs: `IOS-UI.md` "Design baseline" (backdrop); `FFI-BOUNDARY.md` (export
  counting dropped); `scripts/README.md` (`count-exports.sh` removed).
- Total: 59 .swift files changed, +409 −688 lines; data and config files:
  `swift/Assets.xcassets/` (4), `icons/appicon/` (3), `resources/strings/` (3),
  `scripts/` (1), `swift/Spectra.xcodeproj/` (1); dependencies unchanged; test
  functions 105 → 96.

## Beta Commit 200

- **One seed-phrase grid for import and the Funds Finder** (new
  `swift/SeedPhraseEntry.swift` and `swift/views/SeedPhraseEntryView.swift`;
  `ImportDraft.swift`, `FundsFinderView.swift`, `WalletSecretStep.swift`)
  - `SeedPhraseEntry` holds the slots, wordlist and length override and asks
    core's `checkSeedPhrase` once per grid; the draft's grid code moved into it.
  - The Funds Finder scans only a phrase core judges checksum-valid (before: any
    12 or more words) and uses the import page's grid (before: its own
    12/24-slot grid).
  - Custom word counts are gone: the length override offers Auto and the BIP-39
    lengths only (before: any typed count from 1 to 48).
  - Core's `SeedPhraseProblem` cases are worded by the app (non-standard length,
    wrong word count, invalid checksum).
- **The staking tab reads its chain table from core**
  (`CoreReferenceTables.stakingChains` from `listStakingChains()`,
  `StakingView.swift`): APY estimate, mechanic, unbonding, minimum and
  explanation come from `StakingChainEntry`; the Swift `StakingChainDescriptor`
  copy and `Chain.stakingChains`/`supportsStaking` are removed; the badge tint
  is the chain's catalog colour.
- **A watch-only import has one address field, for the chain it is on**
  (`WalletImportDraft.watchOnlyInput`, `WalletSetupViews.swift`; before: one
  field per address slot, with EVM chains sharing Ethereum's): watching an EVM
  layer two now imports a wallet on it (before: addresses were keyed to Ethereum
  and core refused the import). The xpub field appears on any chain that
  `acceptsAccountXpub`.
- Send failure reasons show the amount as a localized decimal
  (`AppState+SendExecution.swift`).
- Tests: 4 new, 2 removed
  - Watch-only 1: an EVM layer-two watch import refused or landing on Ethereum.
  - Seed phrase 2: a core problem without app wording; a created phrase judged
    at the wrong length.
  - Staking 1: a core staking row with no detail page (replaces the two
    descriptor-coverage tests).
- Total: 17 .swift files changed (2 new), +479 −752 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 103 → 105.

## Beta Commit 198

- **The backdrop's colour clouds drift** (new
  `swift/views/SpectraBackdrop.swift`, moved out of `ImageRendering.swift`)
  - Each of the four clouds follows its own slow closed path and swells
    slightly; position is a function of wall-clock time, so every instance
    agrees across tabs and pushed screens.
  - Clouds are radial gradients rather than live blurs, redrawn at most 30 times
    a second.
  - It holds still under Reduce Motion, in Low Power Mode and in the background.
- **Known Tokens and the token detail are glass pages over the backdrop**
  (`TokenRegistrySettingsView.swift`, `TokenRegistryDetailView.swift`,
  `SettingsTokenComponents.swift`; before: system `Form`s)
  - A token row reads like the wiki's: name, then symbol and its one chain or
    its chain count, a "Custom" tag and a chevron.
  - The detail page has a hero card with a Built-In/Custom tag, a price-sources
    card, a networks card (chain, standard tag, decimals, identifier) and a
    glass Remove Token button.
  - Core's refusal shows as a dismissible notice (`TokenPreferenceErrorNotice`);
    an empty filter or search shows a `ContentUnavailableView`; New Token is a
    "+" toolbar button.
- Docs: `IOS-UI.md` "Design baseline" (backdrop motion).
- Total: 5 .swift files changed (1 new), +286 −110 lines; data and config files:
  none; dependencies unchanged; test functions unchanged at 103.

## Beta Commit 197

- **Known Tokens no longer has a per-token discovery toggle**
  (`swift/views/TokenRegistrySettingsView.swift`,
  `swift/AppState+TokenPreferences.swift`): each row is a plain link to the
  token's detail; `setTokenPreferenceEnabled`/`setTokenPreferencesEnabled` and
  their `setTokenPreferencesEnabled` state command are gone, and Advanced
  settings no longer shows "Known token checks enabled".
- **Each wallet-setup page is its own pushed screen**
  (`swift/views/WalletSetupViews.swift` `SetupView`, `swift/SetupFlow.swift`):
  the system back button and swipe step back one page at a time (before: one
  screen with a custom Back button that walked the pages and left the flow from
  the first); entering backup verification draws its challenge as the page is
  pushed; `SetupFlow.previous(before:)` removed.
- Chinese strings call known tokens "已知代币" (before: "已跟踪代币").
- Total: 6 .swift files changed, +27 −90 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 103.

## Beta Commit 196

- **Seed-phrase import detects length and wordlist while typing**
  (`ImportDraft.swift`, `WalletSecretStep.swift`; `CoreReferenceTables` lists
  every BIP-39 wordlist)
  - The grid grows to the length core judges the phrase at; pasting 24 words
    fills 24 slots, "More words" steps to the next standard length, and clearing
    returns to the starting length.
  - Word count and wordlist default to Auto and can be fixed in the derivation
    options (`WalletDerivationOptionsView.swift`); a fixed length keeps every
    pasted word and refuses the phrase rather than cutting it short.
  - The status line reports what core read: valid with wordlist and length,
    words not on the chosen list, or words in no BIP-39 list (before:
    English-only messages and a length picker); the keyboard is the default one
    so CJK wordlists can be typed.
- **Import method is chosen on Add Wallet before the chains**
  (`AddWalletEntryView.swift`: "Import Seed Phrase" and "Import Private Key";
  `WalletSecretImportMode` removed): private-key and watch-only imports pick one
  chain and list only the chains they can use (a key that derives an address
  there, or a chain that can be watched); a seed phrase import can pick several.
- **The chain picker filters by tag and sorts by popularity or name**
  (`AllChainsSelectionView.swift`; new `ChainSelectionDescriptor.swift`,
  `ChainSelectionRow.swift`): tags such as Layer 1, Layer 2, EVM, UTXO, Move,
  Substrate and Testnet come from core's `listChainTags()`, with "Selected" for
  multi-select; a testnet follows its mainnet (before: fixed Bitcoin family,
  EVM, L2, other and testnet sections).
- Tests: 9 new
  - Import method 4: a private-key import offering chains a key cannot derive
    on; a watch import offering chains that cannot be watched; a seed import not
    offering every chain or several at once; a chain the method cannot use
    staying selected.
  - Seed entry 4: pasting 24 words not growing the grid; a fixed length dropping
    pasted words instead of refusing; "More words" not stepping to the next
    standard length; clearing not resetting the grid.
  - Setup copy 1: a single-chain import not asking for one chain.
- Total: 16 .swift files changed (4 new), +876 −560 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 94 → 103.

## Beta Commit 195

- **iOS tests use Swift Testing** (`swift/tests/`; new `IsolatedAppState.swift`
  replacing `IsolatedAppStateTestCase.swift`, new `SuspensionGate.swift`):
  `@Test`, `#expect` and `#require` replace XCTest, tests run in parallel, and a
  test that needs an `AppState` uses `@Suite(.isolatedAppState)`; the duplicate
  shared test plan is removed and code coverage is off in `Spectra.xctestplan`.
- **Balance ticks no longer invalidate unchanged views**
  (`AppState+DerivedState.swift`, `AppState+PricingFiat.swift`): each snapshot
  field is assigned only when it changed, and `walletsRevision` becomes
  `walletIdentityRevision`, bumped only when a wallet changes in something other
  than its balances, so history rows and transaction details are not re-read on
  every balance during a sweep.
- **String tables reload when the locale changes**
  (`StaticContentCatalog.swift`, observing
  `NSLocale.currentLocaleDidChangeNotification`) instead of comparing a language
  signature on every read.
- **Launch reads core's state from the already-open database**
  (`bridge.ready().appState()` instead of a second `openState()`).
- Tests: 1 removed
  - Removed: the testnet symbol prefix test.
- Docs: `AGENTS.md` "Swift conventions" (Swift Testing, parallel tests,
  `.serialized` suites, `IsolatedAppStateSuite`).
- Total: 36 .swift files changed (2 new), +1083 −1062 lines; data and config
  files: `swift/Spectra.xcodeproj/project.pbxproj`,
  `swift/Spectra.xcodeproj/xcshareddata/xctestplans/Spectra.xctestplan`,
  `swift/Spectra.xctestplan`; dependencies unchanged; test functions 95 → 94.

## Beta Commit 194

- **The lock screen and app-switcher cover sit in their own window above
  everything** (new `views/SceneCover.swift`; `ContentView.swift`): sheets,
  alerts and dialogs no longer show on top of the cover, the app's view tree is
  not rebuilt when the cover comes and goes, and the window exists only while a
  cover is shown. The snapshot cover wins while the app is not active and lifts
  on return without asking anything.
- **Passing through `.inactive` no longer locks the app**
  (`AppState+Lifecycle.swift`): the Face ID sheet, Control Center and the app
  switcher used to lock it behind every authentication it asked for; auto-lock
  applies on entering the background.
- **Core's refresh events are adopted one at a time in the order sent**
  (`WalletRefreshObserver.swift`, `AppState+BalanceRefresh.swift`): a stream
  that holds neither the state nor core's engine alive.
- **Notifications and price-alert editing moved into their own files** (new
  `AppState+Notifications.swift`, `AppState+PriceAlerts.swift`;
  `Store+Notifications.swift` emptied); core decides what is worth telling the
  user and the app posts it.
- **Plural strings use a singular `#one` form** ("1 asset", "1 confirmation", "1
  path with funds found" and others; `AppLocalization.format(_:count:)`):
  `path(s)`-style text is gone, and `scripts/unused-strings.sh` fails a singular
  form without its key. Fiat currency names come from the system's localized ISO
  4217 names rather than twelve entries in the string tables.
- **Funds Finder derives candidate addresses off the main actor**
  (`FundsFinderView.swift`).
- **`AGENTS.md` sets the Swift floor**: iOS 26 and Swift 6 idioms only (no
  `#available` fallbacks, `@Observable`, `NavigationStack`, async/await), and no
  `@unchecked Sendable`, `nonisolated(unsafe)` or `@preconcurrency` without a
  stated reason.
- Docs: `AGENTS.md` "Platform constraints".
- Total: 70 .swift files changed (3 new), +823 −776 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `scripts/unused-strings.sh`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 95.

## Beta Commit 191

- **Chains cross the FFI as the `Chain` enum, not an id string**
  (`CoreModels.swift`, `Chain+Registry.swift`, `AppState+Networks.swift` and
  callers): records' `chainId` fields are `Chain`, so `chain`, `family` and
  `familyName` are no longer optional and `Chain.displayName(forId:)` is
  removed; `selectChainForFamily` and `resolveDerivationPath` take a `Chain`. An
  unknown network can now only come from stored data or a file.
- **Gas prices are shown exactly as core states them**; only the compact fee row
  rounds (`AmountPresentation.swift`).
- Docs: `FFI-BOUNDARY.md` "Common errors" (`Unknown network: …` replaces
  `unknown chain_id`).
- Total: 65 .swift files changed, +343 −359 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 95.

## Beta Commit 189

- **`AGENTS.md` places every chain-service request in `core/src/api/<api>.rs`**,
  one file per `EndpointApi` named after its `as_str()`; `fetch`, `send`,
  `staking` and `service` call `api`, and `send/` never implements a client.
- **Arbitrum icon scaled down inside its disc**
  (`swift/Assets.xcassets/crypto/arbitrum.imageset/arbitrum.svg`).
- Docs: `AGENTS.md` "Architecture".
- Total: no .swift files changed, +10 −5 lines; data and config files:
  `swift/Assets.xcassets/crypto/arbitrum.imageset/arbitrum.svg`; dependencies
  unchanged; test functions unchanged at 95.

## Beta Commit 188

- **Donation addresses come from core's catalog, validated when it loads**
  (`StaticContentCatalog.swift` `donationDestinations()`;
  `resources/Donations.json` deleted).
- **Endpoint capabilities are a typed enum** (`EndpointCapability`, labelled
  through `endpointCapabilityId`; `AddCustomEndpointView.swift`,
  `EndpointsViews.swift`), replacing strings.
- Tests: 1 removed
  - Removed: the Swift donation-address validity test (core validates the
    catalog).
- Total: 5 .swift files changed, +17 −50 lines; data and config files:
  `resources/Donations.json`; dependencies unchanged; test functions 96 → 95.

## Beta Commit 187

- **New Explorers settings page** (new `views/ExplorerSettingsView.swift`,
  linked from `SettingsViews.swift`): a read-only list of the explorer each
  network's transactions open in, with its URL pattern; the footer states that
  Spectra links to explorers but never sends them requests.
- **Explorer links come from core** (`TransactionRecord.explorerLink` via
  `transactionExplorerLink`; the Swift URL builder in
  `AppEndpointDirectory.swift` removed): the button reads "Open In <explorer>"
  on the transaction detail and send confirmation.
- **Endpoint rows always show their API with capabilities**
  (`EndpointsViews.swift`; an endpoint's API is no longer optional).
- Total: 9 .swift files changed (1 new), +60 −33 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 96.

## Beta Commit 186

- **Every chain's fee card says Spectra signs and broadcasts its transfers
  in-app** (`SendNetworkStep.swift`; `Chain.sendBroadcastMode` removed): the
  "prepares … using the configured backend fee quote" variant is gone.
- Total: 2 .swift files changed, +3 −19 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 96.

## Beta Commit 185

- **Fee priority picker removed** (`SendNetworkStep.swift`,
  `DiagnosticsViews.swift`; `feePriority(forChainId:)`, `setFeePriority`
  removed): the send composer and the chain diagnostics settings no longer offer
  Economy/Normal/Priority, and the preview's "Confirmation Preference" line is
  gone.
- **Diagnostics are recorded and bundled by core** (`DiagnosticsState.swift`,
  `AppState+Diagnostics*.swift`, `DiagnosticsViews.swift`)
  - The app tracks only which runs are in flight per chain; history runs,
    endpoint checks, their errors and the per-chain document are read back from
    what core recorded on the family's current network.
  - Core assembles the diagnostics bundle; the app adds what only the platform
    knows and owns the files (before: Swift built the bundle from its own
    per-chain state).
  - Self-test result wording now comes from core's outcomes; the Swift strings
    for each check are removed.
- **Balances appear as each wallet lands** (`WalletRefreshObserver.swift`,
  `AppState+DerivedState.swift`): during a sweep the portfolio is re-read at
  most once per interval as core commits wallets, instead of only after the
  slowest chain finishes.
- **Monero local sync moved from its view into `AppState+MoneroSync.swift`**:
  the scan runs one core batch at a time and reports why it stopped; core
  persists every batch, so a cancelled scan resumes where it left off.
- **Generic secrets (a sealed wallet's salt and verifier, a Monero view key)
  live under the wallet Keychain service** (`SecureStores.swift`; the leftover
  `com.spectra.pricing` service name removed).
- **A chain without catalog decimals has no precision** (`Chain.nativeDecimals`
  optional; before: defaulted to 8); rates without a catalog precision show
  every digit.
- Tests: 2 new, 2 removed
  - Diagnostics 1: a chain's diagnostics screen differing from the bundle core
    writes.
  - Secrets 1: generic secrets stored under a leftover service name.
  - Removed: the two Swift bundle-table tests, with the table.
- Total: 30 .swift files changed (1 new), +267 −615 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 96.

## Beta Commit 184

- **iOS bridge tests that restated core rules removed** (`swift/tests/`): the
  token-preference, send-destination, EVM fee and nonce, storage, transport,
  send-amount and replaceable-send bridge test files are deleted; the tests kept
  are regrouped into `WalletServiceBridgeTests.swift`,
  `SendPreviewAdoptionTests.swift` and `TokenRegistryPresentationTests.swift`,
  and `EndpointDirectoryBridgeTests` and `SendStagesBridgeTests` become
  `EndpointScreensTests` and `SendStagesViewTests`.
- **Code comments and script headers trimmed to current behaviour**
  (`AppState+SendFlow.swift`, `AppState.swift`, `SecureStores.swift`, views;
  `scripts/check-design-tokens.sh`, `swift-shell-literals.sh`,
  `unreachable-exports.sh`, `unused-strings.sh`): history of earlier bugs
  removed; `register_owned_address` is no longer allowed as a test fixture
  export. Behaviour unchanged.
- Tests: 37 removed
  - Removed: bridge tests for token preference rules, send destination
    resolution, fee and nonce parsing, exact amounts, storage opening and
    history reads, transport, staking, Monero sync, send stages, endpoints,
    alerts, keypool baselines and replacement fields across the binding.
- Docs: `scripts/README.md` "Former test files" table replaced by a short "Test
  organisation" section (CLI tests for cross-process behaviour, Rust unit tests
  for pure functions, scenarios grouped by feature).
- Total: 34 .swift files changed (3 new), +259 −1023 lines; data and config
  files: `scripts/check-design-tokens.sh`, `scripts/swift-shell-literals.sh`,
  `scripts/unreachable-exports.sh`, `scripts/unused-strings.sh`; dependencies
  unchanged; test functions 133 → 96.

## Beta Commit 183

- **Deleting a wallet holds no pending state between confirmation and
  authentication** (`AppState+ImportLifecycle.swift` `deleteWallet(_:)` replaces
  `confirmDeleteWallet` and `deletePendingWallet`; `walletPendingDeletion` and
  the unused dashboard delete alert removed): a refused Face ID leaves no
  half-started deletion behind. The watch-only warning now reads "…unless you
  still have this address" (was "until"); the holdings header drops its count
  badge.
- **Crypto icons `bitcoinsignet` and `bitcointestnet` added** (the Bitcoin mark
  on purple and green discs).
- Total: 5 .swift files changed, +50 −52 lines; data and config files:
  `swift/Assets.xcassets/` (4), `resources/strings/` (3); dependencies
  unchanged; test functions unchanged at 133.

## Beta Commit 182

- **Receive is a wallet list that pushes the address page**
  (`ReceiveFlowViews.swift`): choosing a wallet opens its address, and the
  navigation back button or swipe returns to the list (before: a two-step flow
  with a progress header and a Continue button); with one wallet the list is
  skipped. The address page names the chain and draws its mark rather than the
  gas token's.
- **The "Hide small amounts" menu item uses a checkmark** (`HistoryView.swift`,
  `.toggleStyle(.automatic)`): the app-wide switch style rendered it as a
  disabled item inside a menu.
- Total: 2 .swift files changed, +114 −214 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 133.

## Beta Commit 181

- **Transactions with no known time are shown as such** (`CoreModels.swift`
  `hasKnownDate`, `HistoryView.swift`): a pending record core stores without a
  date is grouped under "Unconfirmed" at the newest end of history, and any
  undated record reads "Unknown date" instead of a 1970 timestamp.
- Total: 2 .swift files changed, +17 −3 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 133.

## Beta Commit 180

- **History can hide small amounts** (`HistoryView.swift`): a "Hide small
  amounts" toggle passes `hideSmallAmounts` to core's history query, labelled
  with core's threshold ("Below …").
- **The portfolio total shows the figure alone**
  (`AmountPresentation.formattedQuotedTotal`): the "N without a price" suffix
  and the "Across N wallets" line are removed, since unpriced rows already show
  "—".
- **Switches take the accent through a root toggle style** (`SpectraApp.swift`
  `AccentSwitchToggleStyle`; before: `UISwitch.appearance()`, which SwiftUI
  overrode on re-render, turning switches green).
- **Small labels scale with Dynamic Type** (`DashboardViews.swift` Tor badge,
  `FundsFinderView.swift`/`WalletSecretStep.swift` word indexes use scaled
  metrics and monospaced digits).
- Docs: `IOS-UI.md` "Theme colour" (root toggle style).
- Total: 7 .swift files changed, +45 −45 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 133.

## Beta Commit 179

- **Reviewed addresses name who holds them** (new
  `views/EndpointHolderLabel.swift`, `views/ReviewAddressBlock.swift`;
  `SendStagesView.swift`, `SendConfirmationStep.swift`,
  `TransactionDetailView.swift`): core's `addressHolder` names one of the user's
  wallets or a saved contact beside the address, and a send under review shows
  every character in groups of four with the first and last groups emphasized.
- **Transaction detail reorganized** (`TransactionDetailView.swift`): what moved
  and its status first, then the one action a pending send can take (speed up or
  cancel), the timeline, each end with its holder, and network, fee and hash;
  gas, paths and payload fold under "Technical Details". Token amounts take the
  symbol from the wallet's holding of that contract; long identifiers are cut in
  the middle with copy-in-full rows.
- **The app is covered whenever it is not active** (`ContentView.swift`), so the
  app-switcher snapshot never shows balances or addresses, independent of the
  app lock.
- **History reloads keep the rows already on screen** (`HistoryView.swift`): a
  refresh or an on-chain fetch no longer snaps the list back to its first page.
- **Asset detail drops the totals card**; the total amount sits under the value
  in the header (`DashboardViews.swift`).
- Docs: `scripts/README.md` `cli-send.py` row (holder of each transfer end).
- Total: 8 .swift files changed (2 new), +524 −260 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 133.

## Beta Commit 178

- **Signing and broadcasting are separate actions again**
  (`AppState+SendFlow.swift`, `SendFlowViews.swift`): confirming signs only, and
  a signed send waits for the user to pick the nodes that receive it (reverting
  the combined action of Beta Commit 177); the primary button reads Build, Sign
  or Broadcast Transaction, and resumable sends show which stage they wait in
  ("Ready to sign", "Ready to broadcast", "Submitted").
- **Wallet name, recovery phrase, identifiers and deletion moved to an Advanced
  page** (`WalletFlowViews.swift`): the wallet details page shows only what the
  wallet holds; deleting from the Advanced page closes both pages.
- **Dashboard card header switches between Assets and Wallets**
  (`DashboardViews.swift`): each title shows its count and the selected page's
  action sits at the end (before: a segmented control above the card and a
  toolbar action); the total reads "Across N wallets".
- **Lists are rows in one card** (new `views/SpectraRowGroup.swift`,
  `spectraRowPadding`; staking, Add Wallet, chain selection, receive, wiki and
  Funds Finder lists): a selectable list marks the choice with a trailing
  checkmark (before: a card per row).
- **Glass stops at the card** (`SpectraLayout.swift`
  `insetFill`/`spectraInsetFill`): inputs, address blocks, chips, tiles and icon
  backplates inside a card use a flat inset fill;
  `scripts/check-design-tokens.sh` fails on glass drawn with an inner or control
  radius, a circle or a capsule.
- Docs: `IOS-UI.md` "Cards", new "Glass stops at the card" and "Lists", "Corner
  radii", shared helpers and examples.
- Total: 20 .swift files changed (1 new), +625 −489 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `scripts/check-design-tokens.sh`, `swift/Spectra.xcodeproj/project.pbxproj`;
  dependencies unchanged; test functions unchanged at 133.

## Beta Commit 177

- **One theme colour, spacing scale and three radii** (`SpectraLayout.swift`,
  new `AccentColor.colorset`, `SpectraApp.swift`; every view)
  - The accent is the asset catalog's `AccentColor` (system orange), set
    globally and applied to switches through `UISwitch.appearance()`; views
    write `.tint` or `Color.accentColor`, warnings and pending states use
    `.spectraWarning`.
  - Spacing is `SpectraLayout.Space` (2, 4, 8, 12, 16, 24, 32 pt), and every
    scrolling page uses `spectraScreenPadding()` (screen inset 16 pt, was 14).
  - Radii are three steps: card 20 pt, inner 14 pt, control 10 pt (before: seven
    steps from 28 to 10).
  - `scripts/check-design-tokens.sh` also fails on numeric spacing and on a
    literal orange outside artwork marked `design-tokens: artwork`.
- **Confirming a send signs and broadcasts in one action**
  (`AppState+SendFlow.swift`, `SendFlowViews.swift`): when core chose where to
  submit, the one confirmation does both; only a send left signed, or whose
  broadcast failed, keeps a Broadcast step.
- **Send composer layout reworked** (`SendPrimarySectionsView.swift`,
  `SendConfirmationStep.swift`, `SendNetworkStep.swift`)
  - Assets are full-width rows; the recipient field wraps the whole address and
    treats Return as done; the keyboard Done toolbar is removed; the step header
    shows only "Step N of M".
  - Amount shortcuts show disabled until priced; the fiat value line is always
    present ("—" without a price); "Available to send" shows the fee-adjusted
    maximum at display precision.
  - Fee rows show compact fees with their fiat value and gas prices at four
    significant digits (`compactNetworkFee`, `compactGasPrice`); preview details
    list only what the fee rows and amount page do not.
  - Wallet rows name the network (e.g. Sepolia) rather than the family.
- **A recipient that is one of the user's own wallets says so** ("This address
  belongs to one of your wallets.") instead of funded or fresh warnings; a valid
  recipient reads "Valid address for this network".
- Docs: `IOS-UI.md` "Buttons", new "Theme colour" and "Spacing", "Corner radii"
  (three steps), examples.
- Total: 48 .swift files changed, +1151 −1097 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `scripts/check-design-tokens.sh`,
  `swift/Assets.xcassets/AccentColor.colorset/Contents.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 133.

## Beta Commit 176

- **The iOS build compiles only the static library** (`scripts/build-ios.sh`
  uses `cargo rustc --lib --crate-type staticlib`; the ffi crate's cdylib is for
  Android); `build/` is no longer ignored in `.gitignore`.
- Total: no .swift files changed, +3 −4 lines; data and config files:
  `.gitignore`, `scripts/build-ios.sh`; dependencies unchanged; test functions
  unchanged at 133.

## Beta Commit 175

- **One build script builds the Rust core and its Swift bindings from Xcode**
  (`scripts/build-ios.sh`, run by the "Build Rust Core" phase, formerly "Build
  Rust Derivation Core"; `scripts/bindgen-ios.sh` deleted)
  - It builds only the target being built (device, or arm64 simulator) into
    Xcode's temp directory and generates `swift/generated/` from that same
    library, so a fresh clone needs no separate step; it must be run from the
    Xcode phase.
  - Simulators are arm64 only: x86_64 is excluded in the project and the lipo
    merge is gone.
  - The project compiles `generated/spectra_core.swift` as a file reference
    instead of a synchronized folder.
- **Rust iOS minimum raised to 26.0** (`.cargo/config.toml`, from 16.0),
  matching the app's deployment target; the separate x86_64 simulator flags are
  removed.
- **Makefile targets removed**: `check`, `ios-artifacts`,
  `ios-artifacts-release`, `bindgen-ios`, `clean-generated` (folded into
  `clean`). The CLI package is `spectra_cli` in CI and the README.
- Docs: `README.md` "The iOS app" (open and build; no `make ios-artifacts`);
  `FFI-BOUNDARY.md` "Regenerate"; `scripts/README.md` build table.
- Total: no .swift files changed, +96 −176 lines; data and config files:
  `scripts/` (3), `swift/Spectra.xcodeproj/` (2), `.cargo/` (1),
  `.github/workflows/` (1), `Makefile`; dependencies unchanged; test functions
  unchanged at 133.

## Beta Commit 173

- **Derivation options are a sheet on the secret step, not a page of the setup
  flow** (new `views/WalletDerivationOptionsView.swift`;
  `WalletSecretStep.swift`, `WalletSetupViews.swift`; `WalletSetupPage.advanced`
  removed)
  - The sheet holds the per-chain derivation paths and the passphrase and HMAC
    overrides; its entry on the secret step names any option moved off its
    default.
  - The Simple/Advanced setup mode choice is removed from Add Wallet
    (`SetupModeChoice`, `setupModePicker`; `beginWalletImport` and
    `beginWalletCreation` take no mode).
- **Unused views removed** (`SettingTextField.swift` contents,
  `SpectraLoadingCard`).
- **`scripts/unused-strings.sh` reads only files a person wrote** (tracked or
  new, never ignored), so generated Swift and Kotlin bindings no longer make
  every check pass.
- Docs: `scripts/README.md` counts 31 scripts and describes the new CLI suites
  (transport, endpoints, token preferences, send stages, ICP/Zcash and Monero
  sends, optional Monero regtest).
- Total: 13 .swift files changed (1 new), +234 −345 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `scripts/unused-strings.sh`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 133.

## Beta Commit 172

- **The envelope master key is wrapped by a Secure Enclave key**
  (`SecureStores.swift` `MasterKeyWrapping`): the Keychain holds the master key
  only encrypted to a P-256 enclave key that cannot leave the device, so a
  copied Keychain opens nothing (before: the master key sat in the Keychain
  beside the material it sealed, under the same access class). No user presence
  is required, so background work is unaffected; on the simulator the wrapping
  key is a software key.
  - An unreadable master key throws instead of reading as absent, so it is never
    replaced while seeds are sealed under it; a wrapped key whose enclave key is
    gone is unreadable, not absent.
  - Seeds and private keys share one store type, told apart by Keychain service
    (`SecureSeedStore`, `SecurePrivateKeyStore` merged).
- **Revealing a seed phrase always requires device authentication**, whatever
  the Face ID preferences (`DeviceAuthenticationAction.revealSeedPhrase`); an
  authentication failure is returned to the flow that asked (unlock, send,
  reset) rather than written into the send error.
- **Core's refresh engine owns both refresh loops** (new
  `WalletRefreshObserver.swift` replacing `WalletBalanceObserver.swift`;
  `AppState+Maintenance.swift`, `AppState+BalanceRefresh.swift`,
  `AppState+Lifecycle.swift`)
  - The app reports device conditions and the visible tab; core starts the loops
    in the foreground, stops them in the background, schedules its own ticks and
    reports Tor status changes, and each completed sweep says what changed so
    the app re-reads only those projections.
  - Removed: the Swift maintenance loop and plan, battery and condition polling
    helpers, the Tor status poll, and `DebouncedAction.swift`.
- **Every state change goes through one ordered command queue**
  (`AppState+CoreStateStore.swift` `enqueueStateCommand`); failures surface in
  `commandError` or the flow's own refusal field (contacts, tokens, alerts).
- **Reset is one core call that returns why it did not complete**
  (`AppState+Reset.swift`), shown on the reset sheet; the per-scope Swift steps
  are removed.
- **All screen copy lives in the `RuntimeStrings` tables**
  (`StaticContentCatalog.swift`): the `CommonContent`, `DiagnosticsContent`,
  `DonationsContent`, `EndpointsContent`, `ImportFlowContent` and
  `SettingsContent` files are deleted and their text moved into
  `RuntimeStrings.<locale>.json`; screens read typed key names. Donation
  addresses move to a locale-independent `resources/Donations.json`, titled by
  chain name.
- **Send destination checks run inside the preview request**
  (`AppState+SendPreview.swift`): the separate risk probe is removed.
- **`WalletServiceBridge` is reduced to the database binding, cache directory
  and secret store**; callers use core's API through `bridge.ready()`, and
  dozens of pass-through wrappers are removed. `scripts/unused-strings.sh` is
  updated for the single string table.
- Tests: 10 new, 9 removed
  - Secrets 2: the master key stored unwrapped; a seed phrase revealed without
    authentication.
  - Strings and data 3: declared locales shipping different string tables;
    locale-independent data shipped more than once; a donation address invalid
    for its chain.
  - Refresh 3: device conditions not reporting the device and visible tab;
    core's refresh engine retaining `AppState`; a refresh re-reading projections
    core did not report as changed.
  - Binding 2: a contact refusal not reaching the form; an appended log losing
    fields across the binding.
  - Removed with the Swift code they covered: the maintenance plan,
    unreachable-network tick and maintenance-sleep tests, the per-file copy
    decoding tests, the log-trimming and contact-rejection tests now core's, the
    Testnet4 mainnet-address import test and the queued-readback refresh test.
- Docs: `AGENTS.md` "Resources" examples name `RuntimeStrings`.
- Total: 76 .swift files changed (1 new), +1304 −2063 lines; data and config
  files: `resources/strings/` (21), `resources/` (1), `scripts/` (1),
  `swift/Spectra.xcodeproj/` (1); dependencies unchanged; test functions 132 →
  133.

## Beta Commit 170

- **No money arithmetic in Swift: amounts are exact decimals and fiat figures
  arrive valued from core** (`AmountPresentation.swift`; `AppState.livePrices`,
  `fiatRatesFromUSD` and the USD conversion helpers removed)
  - Holding values, unit prices, alert targets and fees are read from
    `portfolioValuation` and core's quotes in the display currency, shown as "—"
    when core has none.
  - Compact amounts use core's places and cut rather than round up; detailed
    amounts show every digit the record holds, with only the locale's decimal
    separator applied.
  - Price alert targets are sent to core as typed, with the locale's decimal
    separator normalized; core parses the number.
- **Transaction detail ends come from core** (`TransactionDetailView.swift`,
  `TransactionEndpoints`): which From and To to show and whether each is the
  wallet's own (before: Swift worked it out from owned addresses); "Raw
  Transaction Hex" becomes "Raw Transaction".
- **Address validation and duplicate checks are core's**
  (`AppState+AddressBook.swift`, `AppState+AddressResolution.swift`:
  `AddressValidation`, `isDuplicateAddressBookAddress`,
  `addressBookAddressValidationMessage` removed; core trims, validates, rejects
  duplicates and assigns the contact id).
- **Asset colours are keyed by deployment identity, never by ticker**
  (`AssetPresentationCatalog.swift`): a custom token calling itself `ETH` no
  longer takes Ether's colour.
- **Signing, revealing or scanning asks for a password when a wallet's secret
  state is unknown** (`AppState+SendExecution.swift`, `AppState+Wallets.swift`);
  the password goes to core as typed.
- **Donation destinations name chains by id** (`DonationsContent.*.json`
  `chainName` → `chainId`).
- **Token-preference commands moved to `AppState+TokenPreferences.swift`**;
  unused wrappers removed (`runSelfTests`, `runUTXORescan`, per-chain fee
  priority accessors, `refreshLivePrices`, endpoint-directory lookups and
  others); two degraded-provider strings removed.
- Tests: 9 new, 10 removed (mostly renamed with tightened guards)
  - Amounts 3: unavailable metadata inventing an amount or value; compact
    amounts not cut or detailed ones losing digits; a compact amount rounding
    up.
  - Values and identity 4: unvalued figures shown as zero or partial totals
    unlabelled; coin colours following the ticker instead of the deployment; a
    catalog capability without a localized label; a bundled chain without a
    distinct entry.
  - Binding 2: staking or receive refusals not crossing the async binding; the
    amount shortcut not floored exactly.
  - Removed: the Bitcoin Testnet4 unpriced test and the cached-identity test,
    with the code they covered.
- Total: 79 .swift files changed (1 new), +1017 −1600 lines; data and config
  files: `resources/strings/` (6), `swift/Spectra.xcodeproj/` (1); dependencies
  unchanged; test functions 133 → 132.

## Beta Commit 169

- **Send, receive and import flow state moved out of `AppState`** (new
  `SendFlowState.swift`, `ReceiveFlowState.swift`, `WalletImportSession.swift`;
  `AmountPresentation.swift` and `AssetPresentationCatalog.swift` take amount
  formatting and asset metadata out of `Store+Formatting.swift`).
- **A broadcast finishes even if the composer closed**
  (`AppState+SendExecution.swift`): the completed operation is resolved by its
  own id, so the app still refreshes and records the result without reopening
  the artifact (before: a broadcast completing after close was dropped).
- **Live Activities are reconciled by their stored transaction ids**
  (`AppState+SendLiveActivity.swift`): old records outside the recent window are
  found, a read failure keeps the activity for a retry, and a missing record
  ends it without a status.
- **Import submissions are tied to the form that sent them**
  (`WalletImportSession.submit`): an earlier success cannot close or clear a
  newer form, an earlier failure cannot overwrite its error, a failure keeps the
  form for retry, and dismissal clears entered secrets; inputs are snapshotted
  before core commits.
- **A refresh adopts each projection once** (`AppState+Maintenance.swift`):
  domain changes complete first and price alerts are evaluated before the final
  snapshot (before: alert adoption queued an extra portfolio read).
- **Asset identity and artwork are cached per deployment**
  (`AssetPresentationCatalog`): balance and ticker changes do not change them,
  the network does.
- Tests: 12 new, 1 removed
  - Presentation 4: unavailable metadata inventing an amount or exchange rate;
    compact and detailed amounts converging without an `AppState`; a stale
    precision snapshot adopted; cached identity or artwork changing with balance
    or ticker, or ignoring the network.
  - Send completion 3: a broadcast after close not returning its committed
    result (rewriting the earlier reopen test); a broadcast not refreshing the
    app after the composer is replaced; Live Activity reconciliation missing old
    records or dropping read failures.
  - Import session 3: an old success closing or clearing a new form; an old
    failure overwriting a new error; a failure losing the form or dismissal
    keeping secrets.
  - Refresh and history 2: a refresh adopting a projection twice; the history
    cursor not continuing across the binding and a reopen.
- Total: 57 .swift files changed (9 new), +1349 −1002 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 122 → 133.

## Beta Commit 168

- **A custom endpoint declares which operations it serves**
  (`AddCustomEndpointView.swift`; `.addCustomEndpoint(capabilities:…)`): the
  form lists the capabilities core allows for the chosen API, each with a
  description, and Save needs at least one; only APIs with supported custom
  operations are offered, and core rejects an empty set. The endpoints list
  reloads when custom endpoints change.
- **Large-movement minimum is typed as a number**
  (`LargeMovementAlertsSettingsView.swift`: a decimal field with a keyboard Done
  button instead of a stepper in steps of 5); explanatory paragraphs removed
  here and on the price alerts screen.
- **Crypto icons redrawn**: `ethfi`, `ink`, `leo`, `ondo`, `polkadot`,
  `polygon`, `sei`, `sonic`, `wrappedbitcoin` (coloured discs with white marks
  where they were white discs, transforms baked into 64×64 coordinates).
- Total: 6 .swift files changed, +152 −123 lines; data and config files:
  `swift/Assets.xcassets/` (9), `resources/strings/` (3); dependencies
  unchanged; test functions unchanged at 122.

## Beta Commit 167

- **Custom endpoints are typed entries in one directory**
  (`EndpointsViews.swift`; new `AddCustomEndpointView.swift`;
  `endpointDirectory()`, `.addCustomEndpoint(chainId:api:endpoint:)`)
  - The endpoints screen lists core's directory per network, each row with its
    API, capabilities and built-in or custom source, filterable by source.
  - Adding an endpoint picks the network and API type from the directory and
    enters a URL; core rejects an invalid one and the form says so.
  - Removed: the per-chain custom RPC and backend fields on diagnostics pages,
    the custom Esplora add and clear controls, and the backend picker.
- **"Strict RPC Only (Disable Ledger Fallback)" toggle removed** from Advanced
  Settings.
- **Introductory notes removed** from the pricing and report-a-problem screens,
  with unused strings.
- **Verification guidance in `AGENTS.md` scales with the change**: targeted
  checks for small edits, the full suite for broad, domain, persistence,
  funds/key or FFI changes, and a report of which checks ran (before: every
  change ran all three suites).
- Tests: 2 new
  - Endpoints 2: a typed endpoint losing its source or network across the
    binding; the endpoint screens failing to render in a real window.
- Docs: `AGENTS.md` "Verification".
- Total: 14 .swift files changed (2 new), +232 −303 lines; data and config
  files: `resources/strings/` (12); dependencies unchanged; test functions 120 →
  122.

## Beta Commit 166

- **Custom tokens can be edited and carry a CoinPaprika price id**
  (`AddCustomTokenView.swift` with `editing:`; `.updateCustomToken` command;
  `addCustomTokenPreference(…coinpaprikaId:…editing:)`)
  - The token form is a Network section (picker and "Token Identifier" when
    adding, read-only when editing), the token fields, and an optional "Price
    Sources" section for CoinGecko and CoinPaprika ids; Save is a toolbar action
    that closes the form on success and shows core's refusal otherwise (new
    reason: a URL or name given as a price id).
  - The separate decimals-only update (`updateCustomTokenPreferenceDecimals`) is
    removed.
- **Token detail page is a form** (`TokenRegistryDetailView.swift`): header with
  built-in or custom, price sources, one card per network, Edit for custom
  tokens, and Remove with a confirmation; the page closes when its token is
  gone.
- **One toggle per token turns discovery on or off on every network**
  (`TokenRegistrySettingsView.swift`); the network and source filters move into
  a toolbar menu; core's token error is shown on the list.
- **Diagnostics actions moved off Advanced Settings**
  (`AdvancedSettingsView.swift`, `DiagnosticsViews.swift`)
  - "Run All Endpoint Checks" and the diagnostics bundle export, past exports,
    share and import now sit on the diagnostics hub.
  - Each chain's diagnostics page has "Refresh Balances and History" with its
    outcome, and Rescan wherever the chain supports deep UTXO discovery (before:
    a list of per-chain refresh buttons on Advanced Settings and UTXO-only
    action titles).
- Tests: 3 new
  - Token management 3: a custom token edit losing a price source or its
    identity; the token screens failing to render in a real window; one
    deployment's toggle not applying to every network.
- Total: 9 .swift files changed, +436 −361 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 117 → 120.

## Beta Commit 165

- **Sends are built, signed and broadcast as separate stages of a durable
  artifact core keeps** (new `SendSession.swift`, `views/SendStagesView.swift`;
  `AppState+SendExecution.swift` `submitSend`, `signPreparedSend`,
  `broadcastPreparedSend`, `resumeSend`; bridge `buildOwnedSend`, `signSend`,
  `broadcastSend`, `inspectSend`, `listSends`, `sendEndpoints`)
  - Confirm builds the transaction and shows its amount, asset, network, sender,
    recipient, prepared details, review digest and signing payload; Sign asks
    for device authentication and, for a sealed wallet, the password; Broadcast
    submits to the nodes the user ticks (before: one review then one execute
    call).
  - Each broadcast attempt is listed per node as accepted, rejected or
    uncertain, and a signed transaction can be retried as the same transaction;
    the on-chain status follows from the stored record.
  - Saved sends can be resumed from the From step ("Resume a transaction").
  - Session state is dropped when the composer closes, and a late build,
    endpoint, authentication or broadcast result from a closed session is
    ignored.
- **Monero sends offer a local wallet sync** (new `views/MoneroSyncView.swift`;
  `moneroSyncStatus`, `syncMoneroWallet`): core scans on the device in persisted
  batches with an optional restore height, behind device authentication and the
  wallet password when sealed; cancelling keeps completed batches.
- **Core state is adopted by revision** (`AppState.applyCoreState` checks
  `CoreAppState.revision`; read epochs removed): a slower response with an older
  revision cannot overwrite a newer one, whatever order requests complete in.
- **History rows offer Recheck and Rebroadcast from core's per-transaction
  actions** (`HistoryView.swift`, `transaction.actions.*UnavailableReason`;
  Swift `supportsStatusRecheck` and `supportsSignedRebroadcast` removed).
- **Transaction times are Unix seconds throughout**
  (`TransactionRecord.createdDate` reads `createdAtUnix`; before: Swift
  reference seconds in the persisted payload).
- **Fiat currencies come from core's catalog** with their display rules
  (`FiatCurrency.allCases`, `displayRules`).
- **Watch-only entries are keyed by chain id**
  (`ImportDraft.watchOnlyEntriesByChainId`, replacing address slots and
  `addressSlotMap`).
- **The maintenance loop no longer keeps `AppState` alive**
  (`makeMaintenanceTask` holds a weak reference).
- Tests: 11 new
  - Send session 4: a late endpoint response mixing two resumed artifacts;
    closing during authentication still calling the signer; a closed build
    failure overwriting a new session's error; a broadcast after close reopening
    the artifact.
  - Send stages 3: stage storage and refusals failing across the async runtime;
    a signed stage not rendering its payload and chosen destinations; Monero
    sync status and authorization not crossing the bridge.
  - State and storage 4: an older core version winning by completion order; the
    fiat catalog lacking stable identity or display data; maintenance sleep
    retaining `AppState`; transaction actions and Unix times lost across the
    binding and a reopen.
- Docs: `FFI-BOUNDARY.md` "Timestamps" (Unix seconds everywhere, no epoch
  conversion) and new "Versions" (`CoreAppState.revision` orders state
  publications within a session).
- Total: 32 .swift files changed (5 new), +956 −421 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.manifest.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 106 → 117.

## Beta Commit 164

- **Icon rules in `AGENTS.md` condensed** to four bullets (aligned source and
  asset-group names, the full-disc circle with the `usd1` exception, formatting
  owned by `scripts/svgo.config.mjs`, `appicon/` excluded from normalization);
  the house-style list and source table removed.
- **Links point to `docs/PLAN.md`** (moved from the repository root) in
  `AGENTS.md`, `README.md` and `FFI-BOUNDARY.md`.
- Docs: `AGENTS.md` "Icons"; `README.md` "Development"; `FFI-BOUNDARY.md` header
  and open items link.
- Total: no .swift files changed, +16 −53 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 106.

## Beta Commit 162

- **API key settings removed** (`DiagnosticsViews.swift`): the Etherscan API key
  section and the backend API key field are gone, with their notes
  (`etherscanNote`, `backendAPIKeyNote`); the reset warning and quote-provider
  note no longer mention API keys.
- **Cardano removed from the staking page** (`StakingView.swift`, with its
  strings).
- **EVM diagnostics list only the chain's RPC endpoints**
  (`AppEndpointDirectory.evmRPCEndpoints`; explorer supplemental endpoints and
  `evmEndpointsWithSupplemental` removed).
- **Test-only helpers moved into the test target**
  (`CoreModelsTestSupport.swift`: `AssetHolding.makeCustom`,
  `awaitPendingCoreStateWrites`, `flushPendingPersistence`);
  `TokenHostingChain.forChainName` and the read-only footnote removed.
- Total: 12 .swift files changed, +47 −132 lines; data and config files:
  `resources/strings/` (12); dependencies unchanged; test functions unchanged at
  106.

## Beta Commit 161

- **Device authentication is decided per action** (`AppState+AppLock.swift`
  `DeviceAuthenticationAction`)
  - Unlock, wallet deletion and data reset require Face ID whenever it is on;
    sends and rebroadcasts also need "require for sends" (before: every action
    needed both toggles, so turning off send authentication also turned off
    unlock, delete and reset).
  - Deleting a wallet or resetting data no longer proceeds when authentication
    is unavailable.
- **Tor runs in core; the app only shows its status**
  (`AppState+TorLifecycle.swift` `observeTorStatus`, `reconnectTor`;
  `configureNetworkRuntime(cacheDir:)`): stored transport settings take effect
  in core, and the Swift start, stop and status-polling lifecycle is removed.
- **A send quote is bound to its wallet, holding and network**
  (`SendPreviewTypes.swift` `OwnedSendPreview`,
  `ownedQuote(walletId:holdingKey:)`): amount shortcuts and preview details are
  read only for the matching wallet and holding, and a mainnet and its testnets
  no longer share a preview slot.
- **Destination activity is a typed verdict**
  (`chainRiskProbeMessages(…activity:)`: unused, empty but previously used,
  funded).
- **Import form completeness is checked in the draft** (`ImportDraft.swift`
  `canImportWallet`): the backup quiz is required only when creating a wallet;
  core still validates on import.
- **Endpoint rows show the API and localized capabilities** ("evm-json-rpc ·
  Balance · Fees · Broadcast", `AppEndpointDirectory.swift`).
- Tests: 4 new
  - Device authentication 1: disabling send authentication disabling unlock,
    delete or reset protection.
  - Transport 1: stored Tor settings not taking effect, or a reset not stopping
    Tor, without Swift lifecycle calls.
  - Send quote 1: a quote reused for another wallet, holding or network.
  - Wallet setup 1: the backup quiz required outside wallet creation, or skipped
    when creating.
- Total: 20 .swift files changed (2 new), +167 −180 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `scripts/unused-strings.sh`;
  dependencies unchanged; test functions 102 → 106.

## Beta Commit 160

- **The endpoints screen lists the catalog's groups as core supplies them**
  (`EndpointsViews.swift`; `AppEndpointDirectory.serviceEndpoints`, `backends`):
  the Swift per-network assembly of Esplora and EVM lists and the read-only
  footnote are removed; custom Esplora and backend URLs are shown as their own
  rows; diagnostics read a chain's service endpoints and backends from their own
  catalog fields.
- **A wallet's family and network are separate fields**
  (`WalletView.familyName`, `networkTitle`;
  `selectedNetworkTitle(forFamilyName:)` replaces three `displayChainTitle`
  overloads): wallet rows, badges and the price-alert picker name the family's
  selected network; transaction detail shows the record's network.
- **Network switching is one command method** (`AppState+Networks.swift`
  `selectChainForFamily`; `commitSelectedChain` removed); launch reloads core
  projections and fiat rates together (`reloadCoreProjections`, formerly
  `reloadPersistedStateFromSQLite`).
- **`CachedCoreHelpers` renamed `CoreReferenceTables`**; the unused
  `endpointCapability.read` string removed.
- Total: 22 .swift files changed, +108 −182 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 102.

## Beta Commit 159

- **Naming made uniform across the app; behaviour unchanged**: `ID` suffixes
  become `Id` (`walletID` → `walletId`, `useFaceID` → `useFaceId`, `byChainID` →
  `byChainId`), endpoint lookups take a chain id rather than a "network id",
  core helpers are called by their unprefixed names (`coreValidateAddress` →
  `validateAddress`, `appCoreChainEndpoints` → `chainEndpoints`), and
  `WalletRustEndpointCatalogBridge.swift` is renamed
  `AppEndpointDirectory.swift`. `scripts/swift-shell-literals.sh` reads the
  catalog's `chains` table (was `networks`).
- Total: 69 .swift files changed, +489 −487 lines; data and config files:
  `scripts/swift-shell-literals.sh`, `swift/Spectra.xcodeproj/project.pbxproj`;
  dependencies unchanged; test functions unchanged at 102.

## Beta Commit 158

- **Derivation paths are stored per network, not per family**
  (`Chain+Registry.swift` `seedDerivationPathKey` is the chain's own id, not its
  mainnet's): a Bitcoin Testnet4 wallet keeps `m/84'/1'/0'/0/0` beside mainnet's
  `m/84'/0'/0'/0/0`.
- **Wallet detail and the setup derivation page show the wallet's actual
  network** (`WalletFlowViews.swift` reads `networkChainId`;
  `WalletSetupViews.swift` lists the selected network of each family).
- **Testnet symbols keep their lowercase `t` prefix**
  (`AllChainsSelectionView.swift` no longer upper-cases the symbol: `tBTC`,
  `tETH`).
- Tests: 1 new
  - Testnet symbols 1: a testnet's gas symbol not being `t` plus its mainnet's.
  - The Bitcoin Testnet4 import test now also checks both networks' paths and
    the `tBTC` holding.
- Total: 7 .swift files changed, +26 −16 lines; data and config files: none;
  dependencies unchanged; test functions 101 → 102.

## Beta Commit 157

- **iOS tests run against an isolated store** (new
  `swift/tests/IsolatedAppStateTestCase.swift`,
  `swift/tests/StorageBridgeTests.swift`;
  `AppState.init(bridge:startServices:)`,
  `WalletServiceBridge(databasePath:service:)`): each test case gets its own
  temporary database, bridge and test secret store, and `AppState` can be built
  on an injected bridge without starting services; storage and binding tests
  moved out of `SendAmountBridgeTests` and `ReplaceableSendBridgeTests`.
- **Endpoint capability labels split** (`RuntimeStrings`): "History" becomes
  native history, token transfers, token discovery and token balance
  (`endpointCapability.*`); `scripts/unused-strings.sh` accepts hyphenated
  catalog ids.
- **Secret-store registration is synchronous on a given bridge**
  (`SpectraSecretStoreAdapter.registerWithBridge(_:)`).
- **Unused bridge and catalog helpers removed** (`refreshBalances`,
  `dashboardAssetGroups`, the static sync service, per-chain endpoint lookups in
  `WalletRustEndpointCatalogBridge.swift`).
- **Code comments shortened to state current behaviour** across
  `AppState+*.swift`, models and views; behaviour unchanged.
- **`make test-ios` takes an optional `IOS_TEST_DERIVED_DATA`** to isolate the
  derived-data path (`Makefile`).
- Tests: 4 new, 8 removed
  - Binding 3: a replacement's fields not crossing the async bridge; an offline
    refresh or rescan failing across the binding; a send executed without a core
    review (split from one test).
  - Copy 1: an endpoint token capability without a localized label.
  - Removed: the EVM-mainnet address test, three replaceable-send filter tests,
    three send-destination refusal tests (ENS off Ethereum, wrong family, TON
    checksum) and the combined refresh-and-confirmation test.
- Total: 60 .swift files changed (2 new), +728 −1178 lines; data and config
  files: `Makefile`, `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `scripts/unused-strings.sh`;
  dependencies unchanged; test functions 105 → 101.

## Beta Commit 156

- **`scripts/README.md` translated into English**; content unchanged.
- Docs: `scripts/README.md`, all sections.
- Total: no .swift files changed, +79 −69 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 105.

## Beta Commit 155

- **The Refresh Frequency setting is removed; core owns the automatic refresh
  cadence** (`BackgroundSyncSettingsView.swift` deleted; `SettingsViews.swift`
  "Sync & Automation" section removed; `AppState+BalanceRefresh.swift`): the app
  only forwards whether it is active, and no longer restarts the engine on a
  cadence change; the network status line drops "Auto refresh: N min".
- **The press-scale effect on buttons and cards is removed**
  (`ViewExtensions.swift` `spectraPressable` and its modifier, and every use).
- **Wallet detail drops its stats card** (`WalletFlowViews.swift`): mode and
  asset count are gone, and First Activity moves into the wallet info form
  beside the wallet id and derivation paths.
- **History rows show the wallet name on one line as the subtitle**
  (`HistoryView.swift`).
- **Token settings rows show the chain's display name** instead of its id
  (`SettingsTokenComponents.swift`).
- Docs: new `scripts/README.md` (in Chinese) describing every script: CLI
  acceptance files, build and bindgen scripts, source and resource checks.
- Total: 19 .swift files changed, +129 −212 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 105.

## Beta Commit 154

- **Sends from a password-protected wallet ask for the password at
  confirmation** (`SendFlowViews.swift`; `submitReviewedSend(_:password:)`,
  `executeOwnedSend(reviewID:input:password:)`): when core's review says
  `requiresWalletPassword`, the confirmation sheet shows a password field and
  Send stays disabled until it is filled; the password is cleared when the sheet
  closes.
- **Portfolio values come from one core snapshot**
  (`AppState+DerivedState.swift` `applyPortfolioSnapshot`;
  `WalletServiceBridge.portfolioSnapshot`)
  - Wallets, quotes, dashboard groups and valuation are adopted together, and an
    older snapshot cannot overwrite a newer state command.
  - A missing quote or fiat rate shows "—" instead of zero, and partial totals
    show how many holdings lack a price (`formattedFiatAmountOrUnavailable`,
    `formattedQuotedTotal`, `formattedWalletTotal`); Swift's `quotedTotal`,
    `currentPrice … ?? 0` and USD-fallback fiat rate are removed.
- **History is paged by core** (`HistoryView.swift` `loadPage`;
  `historyPage(HistoryQuery)`): wallet, filter, search and sort go to core 20
  records at a time (before: the app filtered and sorted its whole projection);
  the app keeps a bounded recent and pending projection (`transactionSnapshot`,
  `transaction(id:)`).
- **Send previews are tied to the exact form input**
  (`AppState+SendPreview.swift` `SendPreviewInputSnapshot`,
  `adoptSendPreviewResult`): a success or failure for an earlier edit, including
  invalid text that parses the same, is discarded.
- **Refresh reports partial failure** (`AdvancedSettingsView.swift`
  `refreshOutcomeMessage`; `performUserInitiatedRefresh` returns success):
  "Refresh failed or completed partially. See refresh errors." instead of always
  "completed".
- **Tor and other runtime effects follow committed settings**
  (`AppState+TorLifecycle.swift` `committedAppSettings`): an uncommitted toggle
  no longer starts or stops Tor, and a failed write restores the committed
  projection.
- **Chain self-tests run in core against the configured network and RPC**
  (`runConfiguredSelfTests(chainID:)`), replacing the Swift EVM RPC probe.
- **Wallet password checks return reasons the app words** (`ImportDraft.swift`;
  too short, confirmation mismatch), not English text from core.
- **Unpinning all dashboard assets is a reset command**
  (`.resetPinnedDashboardAssets`).
- **Transaction subtitles name the chain only when it is not the asset**
  (`CoreModels.swift`; "Solana • Main Wallet" instead of "Solana on Solana •
  Main Wallet"); `priceAlertTitleFormat` renamed `assetOnChainFormat`.
- **Import completion keeps a partial-success notice**
  (`finishWalletImportFlow(notice:)`).
- Tests: 13 new, 1 removed
  - Portfolio and settings 5: unpinning all assets not persisting; a missing
    fiat rate read as zero or a partial total unlabelled; Tor reacting to an
    uncommitted toggle; runtime using uncommitted settings; an older snapshot
    overwriting a newer command.
  - History and refresh 4: bounded history reads failing across the binding; a
    delayed older portfolio snapshot adopted; a partial import notice lost; a
    failed refresh claiming completion.
  - Send and diagnostics 3: a stale preview success or failure adopted after a
    form edit; password verdicts crossing as English; configured diagnostics
    failing across the async binding.
  - Copy 1: a transaction subtitle repeating the chain for a native asset.
  - Removed: the Swift unquoted-holdings total test, with the Swift total.
- Docs: `IOS-UI.md` "Numeric presentation boundary" (six significant digits
  capped at the asset's precision and eight places; unavailable values shown as
  "—", never zero).
- Total: 36 .swift files changed, +624 −602 lines; data and config files:
  `resources/strings/CommonContent.en.json`,
  `resources/strings/CommonContent.zh-Hans.json`,
  `resources/strings/CommonContent.zh-Hant.json`,
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 93 → 105.

## Beta Commit 153

- **Dashboard asset rows take their identity from core**
  (`DashboardViews.swift`): name, colour and price come from where most of the
  asset is held, or the catalog entry for a pinned asset held nowhere, which
  shows "No balance on any chain." instead of a breakdown (before:
  `holdings.first?.coin`, with core synthesizing a holding that read as a place
  the user held it).
- **The per-chain breakdown draws each chain's badge** (before: the asset's mark
  on every row, so USDC on Ethereum and on Solana looked identical).
- **Transaction detail copy buttons report only their own copy**
  (`TransactionDetailView.swift`, renamed from `HistoryDetailView`): copying
  From no longer marks To as copied, and the label clears after a moment.
- **About page shows the backdrop under a hidden navigation bar**
  (`AboutView.swift`).
- **Crypto icons added**: `cake`, `cbbtc`, `crv`, `ens`, `ethfi`, `gho`,
  `morpho`, `ondo`, `pendle`, `pepe`, `susde`, `susds`
  (`swift/Assets.xcassets/crypto/`).
- Total: 4 .swift files changed, +1342 −80 lines; data and config files:
  `swift/Assets.xcassets/` (24), `resources/strings/` (3); dependencies
  unchanged; test functions unchanged at 93.

## Beta Commit 152

- **Address book is a list with separate add and contact pages**
  (`AddressBookView.swift`; new `AddressBookContactViews.swift`
  `NewAddressBookContactView`, `AddressBookContactView`)
  - The book opens on the saved contacts, with adding behind the toolbar `+`
    (before: a `Form` whose first section was a five-field new-contact form,
    pushing the contacts below the fold).
  - The new-contact page picks the chain from every mainnet through the shared
    chain picker, shows the chain's address hint as the placeholder, and judges
    the address only once something is typed.
  - Each contact opens a page to rename, copy or delete it (before: rename and
    delete were swipe actions only); core's refusal of a save is shown
    (`addressBookError`).
  - Rows elide the address in the middle on one line; "Copied" clears after a
    moment instead of staying for the screen's life.
- **Receive flow starts with no wallet chosen unless there is only one**
  (`AppState+ReceiveFlow.swift`; before: the first wallet was silently
  preselected without showing as selected).
- **Receive wallet rows no longer show an address** (`ReceiveFlowViews.swift`):
  the stored address and copy button on each row are removed, since the address
  the next screen hands out is core's reserved receive address.
- **One bottom action bar for setup, send and receive** (new
  `SpectraBottomActionBar.swift`): glass that reaches the bottom edge (before:
  send and receive used an opaque material, setup's glass stopped short of the
  tab bar).
- **The single-select chain picker drops the selection count and "Clear all"**
  (`AllChainsSelectionView.swift`).
- Total: 8 .swift files changed (2 new), +695 −319 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 93.

## Beta Commit 151

- **Private keys are sealed under the device master key like seeds**
  (`SecureStores.swift` `SigningMaterialEnvelope`, formerly
  `SeedMaterialEnvelope`): before, a private key reached the Keychain as core
  handed it over, base64 of the key when the wallet had no password.
- **Keychain read failures are errors, not absence** (`SecureStores.swift`,
  `SpectraSecretStoreAdapter`)
  - An envelope that will not open, a missing master key or a failed Keychain
    read throws (`openFailed`, `masterKeyUnavailable`), and core refuses rather
    than treating the wallet as watch-only; only an empty slot is `NotFound`.
  - The bucket holding a sealed wallet's salt and password verifier reads and
    writes with errors, so a read failure cannot tell core a sealed wallet is
    unsealed.
  - Revealing a sealed wallet's phrase is one core call that decrypts with the
    password (`AppState+Wallets.swift`).
- **Core settings are one `appSettings` value changed through commands**
  (`AppState.swift` `appSettings`, `updateSetting`, `settingBinding`;
  `Store+Settings.swift` deleted; new `views/SettingTextField.swift`)
  - Replaces eighteen mirrored properties, each with a debounced commit and
    hand-written diff and adoption; an edit is shown at once by core's own
    applying rule, and core's committed settings replace it when the last edit
    in flight lands or fails.
  - String settings (custom RPC, proxy, backend URLs) edit a draft that is sent
    when typing pauses or focus leaves, so core's trimming and validation no
    longer rewrite text under the cursor.
  - Network switching and custom RPCs are single commands; core resets the
    family's derivation state and history feed with the switch and stores a
    custom RPC only once it is a valid URL.
- **Amounts and fees are priced by deployment, not symbol**
  (`Store+Formatting.swift`): USDC on Base no longer takes Ethereum USDC's
  quote, and a fee's fiat value uses its network's native deployment (before:
  the first `ETH` holding in the portfolio, possibly a mainnet price for a
  testnet fee).
- **Notifications and core reasons are fully localized**
  (`Store+Notifications.swift`, `AppState+Maintenance.swift`,
  `AppState+OperationalTelemetry.swift`): price alerts use one sentence per
  condition (before: the raw condition word inside Chinese text), large-movement
  notifications are worded per direction from the locale files, and core's
  failure reasons are shown in the app's words; staking descriptions moved into
  the locale files.
- **Send warnings are exhaustive** (`highRiskSendMessages`,
  `evmRecipientMessages`): a new warning code fails to compile until it has
  words (before: a `default` dropped it from the confirmation sheet).
- **Refresh and maintenance follow core's plan** (`AppState+DerivedState.swift`,
  `AppState+Maintenance.swift`; `reconcileBalanceRefresh`)
  - The balance engine adopts the wallet list and refreshes only when what it
    fetches changed (before: every sweep's end synced entries, triggered a sweep
    and restarted the engine, so each sweep began the next).
  - Each maintenance tick and its cadence come from core; the loop stops when no
    wallets remain.
  - Core records history diagnostics rows and chain health itself, on scheduled
    refreshes too.
- **After a send, the notice reflects core's stored record**
  (`sendVerificationNotice`; before: every broadcast logged "Broadcast verified
  by provider.").
- **Transaction detail leaves out an address end the record does not name**
  (`TransactionDetailView.swift`; before: the wallet's first known address was
  shown), and normalizes addresses with core's rule (e.g. Sui's `0x`).
- **Import shows addresses core refused** as a notice and returns to the
  Dashboard afterwards (`AppState+ImportLifecycle.swift`).
- **Balance updates are no longer printed to the device log**
  (`WalletBalanceObserver.swift`).
- **One operational-log record type** (`DiagnosticLog`, replacing two Swift
  copies that dropped rows failing a UUID parse); the logs screen filters by
  core's levels.
- **Funds Finder scan state moved into its screen** (`FundsFinderView.swift`;
  `AppState+FundsFinder.swift` deleted): leaving the screen cancels the scan.
- **`AppState` split into one `AppState+<Domain>.swift` file per domain** (new
  `AppState+AddressBook`, `+AppLock`, `+ChainActions`, `+Lifecycle`,
  `+Networks`, `+TransactionActions`, `+Wallets`; `DashboardStore` →
  `AppState+Dashboard`, `MaintenanceStore` → `AppState+Maintenance`,
  `PersistenceStore` → `AppState+Persistence`, `StoreLifecycleReset` →
  `AppState+Reset`, `StorePersistenceNormalization` → `AppState+DerivedState`
  and others; `ContentView.swift` and `SpectraApp.swift` under `views/`). The
  address validation memo is removed.
- **`scripts/unreachable-exports.sh`** extended (+80 lines).
- Tests: 2 new, 2 removed
  - Private-key storage 2: a private key persisted as plaintext; a missing key
    reported as anything but missing.
  - Removed: the EVM pending-refresh recursion test and the `WalletChainID`
    display-name-and-symbol test, with the code they covered; degraded and
    healthy chain tests rewritten to assert core-recorded state.
- Total: 86 .swift files changed (10 new), +2545 −3447 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `scripts/unreachable-exports.sh`, `swift/Spectra.xcodeproj/project.pbxproj`;
  dependencies unchanged; test functions unchanged at 93.

## Beta Commit 150

- **Unused shipped copy removed and gated** (`resources/strings/`; new
  `scripts/unused-strings.sh`)
  - `RuntimeStrings` go from 1389 to 833 keys per locale (575 removed, 19
    added); unread `DiagnosticsContent` keys removed, and the Ethereum- and
    Monero-specific endpoint notes replaced by generic ones (`customRPCNote`,
    `backendNote`, `backendAPIKeyNote`).
  - The script fails on a content key no `Decodable` field reads, a runtime key
    whose text appears nowhere that could produce it, or key sets that differ
    between locales.
- **New gate for chain names and fixed precision in the app** (new
  `scripts/swift-shell-literals.sh`): fails on a string literal that is exactly
  a catalog chain name or id, or a fixed `%.Nf` amount format, outside tests.
- **`scripts/unreachable-exports.sh` no longer counts tests as callers**, with
  `register_owned_address` and `core_wallet_state` allowed as test fixtures.
- **Network fees use core's amount precision for the chain's gas token**
  (`Store+Formatting.swift` `formattedNetworkFee`,
  `formattedNetworkFeeWithFiat`, `formattedGasPrice`): replaces `%.6f`, `%.8f`,
  `%.2f gwei` and `"%.8f ETH"` for every EVM chain whatever its gas token; the
  review sheet no longer prints fees like `2.1e-05 ETH`.
- **Send fee card is driven by the registry and core's preview enum**
  (`SendNetworkStep.swift`): one card for non-UTXO, non-EVM chains, its sentence
  from `sendBroadcastMode` (before: twelve calls naming chains, with Bittensor
  missing a card); loading is shown for every UTXO chain (before: Dogecoin
  only).
- **Chain settings follow what a chain has, not its name**
  (`DiagnosticsViews.swift`, `EndpointsViews.swift`)
  - Every EVM chain's diagnostics screen offers a custom RPC URL (before:
    Ethereum only).
  - Fee priority and custom Esplora bases appear for any chain with Esplora
    bases; backend choice for any chain that sends through a backend, listed
    from the catalog (before: three hardcoded Monero backends, read by index).
  - Endpoint settings group per network for every multi-network family (before:
    separate Bitcoin, Ethereum and Dogecoin copies).
  - Diagnostics export records the selected network for any family with more
    than one (before: Bitcoin only).
- **Fee priority is core's `FeePriority` enum** (`ChainFeePriorityOption`
  removed); a pick is recorded as made, the default included.
- **Platform preferences live in `UserDefaults`** (`AppUserPreferences.swift`):
  hide balances, appearance, Face ID, auto-lock and biometrics for sends are
  read synchronously at launch (before: a JSON blob stored in core through
  `save_state`, so hidden balances showed until it loaded);
  `loadState`/`saveState` and the fresh-install marker removed.
- **Transaction ids are core's strings verbatim** (`TransactionRecord.id:
  String`; before: parsed as `UUID`, and a row that did not parse was dropped);
  `receiptNetworkFeeEth` → `receiptNetworkFee`.
- **Send previews are stored per mainnet id**
  (`SendPreviewStore.slot(forChainNamed:)`), replacing nine per-chain typed
  accessors and `EVMChainContext`.
- **Seed phrase lengths and their entropy come from core**
  (`CachedCoreHelpers.standardSeedPhraseLengths`); mnemonic generation returns
  nothing for a length BIP-39 does not define (before: core substituted twelve
  words).
- **QR payloads are parsed by core** against the wallet's network
  (`SendFlowViews.swift`; the Swift candidate extraction and validation
  removed).
- **The seed envelope master key is minted by core** (`SecureStores.swift`,
  `newSeedEnvelopeMasterKey`); a generator failure throws instead of falling
  back, and a stored key of the wrong shape is kept and refused rather than
  replaced.
- **An unreadable endpoint catalog is reported, not fatal**
  (`WalletRustEndpointCatalogBridge.swift` `loadError`; before:
  `preconditionFailure`).
- **Catalog colours are typed** (`CatalogColor.color`, replacing
  `RegistryColorLookup.color(named:)` whose default drew the accent colour for
  unknown names); default derivation paths resolve through core, including
  testnets (before: empty for every testnet).
- Docs: `docs/iosUI.md` renamed `docs/IOS-UI.md` (no iOS version named; "Glass
  variant" always `.regular`; the radius scale is fixed, not concentric);
  `FFI-BOUNDARY.md` on `scripts/uncalled-core-fns.sh`; links updated in
  `AGENTS.md` and `README.md`.
- Total: 45 .swift files changed, +1003 −2753 lines; data and config files:
  `resources/strings/` (9), `scripts/` (4); dependencies unchanged; test
  functions unchanged at 93.

## Beta Commit 149

- **Crypto icons `aerodrome`, `layerzero`, `lido`, `steth`, `worldcoin` and
  `wsteth` added; `ethereum`, `ethereumclassic` and `mantle` redrawn**
  (`swift/Assets.xcassets/crypto/`): the Ethereum marks use solid fills instead
  of white at partial opacity.
- Total: no .swift files changed, +145 −16 lines; data and config files:
  `swift/Assets.xcassets/` (15); dependencies unchanged; test functions
  unchanged at 93.

## Beta Commit 148

- **Spectra is licensed GPL-3.0** (new `LICENSE`; `README.md` "License").
- **Verification targets and CI** (`Makefile`, new `.github/workflows/ci.yml`)
  - New targets: `verify` (runs `lint test test-cli test-ios`), `lint` (fmt
    check and clippy at `-D warnings`), `fmt`, `test-cli`
    (`scripts/cli-acceptance.sh`), `test-ios` (`xcodebuild test` on an iPhone 17
    Pro simulator); `test` runs the whole workspace; `check-ui` also runs
    `scripts/normalize-icons.sh --check`; the `help` default goal is removed.
  - CI runs fmt, clippy and tests, and the CLI acceptance suite, on pushes to
    `main` and pull requests; `test-ios` stays local.
- **Agent instructions are checked in** (new `AGENTS.md`: Git, Architecture,
  Verification, Platform constraints, Swift conventions, Resources, Icons; new
  `CLAUDE.md` pointing to it; both removed from `.gitignore`).
- **iOS minimum is 26.0 and the Rust C sources are built for it**
  (`project.pbxproj` `IPHONEOS_DEPLOYMENT_TARGET` 26.2 → 26.0, one value across
  targets; new `scripts/ios-rust-build-env.sh` sourced by `build-ios.sh`): the
  deployment target is read from the project and the iOS target caches are
  cleared when it changes, fixing "built for newer iOS version" link warnings.
- **Unsuffixed copies of localized content files removed**
  (`resources/strings/CommonContent.json`, `DiagnosticsContent.json`,
  `DonationsContent.json`, `EndpointsContent.json`, `ImportFlowContent.json`,
  `SettingsContent.json`): they shadowed the `.en` files and were never read.
- **Dashboard toolbar shows a Pin Assets button only on the Assets page**
  (`DashboardViews.swift`; before: a menu that was empty on the Wallets page).
- **History summary card removed** (`HistoryView.swift`: the Activity header
  with visible, pending and send counts).
- Glossary adds "non-custodial", "recovery phrase" and "mnemonic"
  (`docs/LocalizationGlossary.json`).
- Tests: 2 new, 1 removed
  - Localized content 2: a content file failing to decode in a locale the
    manifest declares (replacing a fixed locale list); an unsuffixed copy
    shadowing its `.en` file, or `AppLinks`/`BuyProviders` missing.
- Docs: `README.md` "Development" (AGENTS.md, CLI, iOS app bootstrap with `make
  ios-artifacts`, Verification table, CI badge), "License"; `AGENTS.md` added.
- Total: 6 .swift files changed, +1134 −274 lines; data and config files:
  `resources/strings/` (12), `scripts/` (2), `swift/Spectra.xcodeproj/` (2),
  `.github/workflows/` (1), `.gitignore`, `LICENSE`, `Makefile`, `docs/` (1);
  dependencies unchanged; test functions 92 → 93.

## Beta Commit 147

- **Icon asset groups renamed `cryptoicon` → `crypto` and `fiaticon` → `fiat`**
  (`swift/Assets.xcassets/`, `scripts/export-swift-icons.sh` now reads
  `icons/crypto/` and `icons/fiat/`; fiat icon names in
  `AppState+PricingFiat.swift` become `fiat/usd` etc.); artwork unchanged.
- Total: 1 .swift files changed, +16 −16 lines; data and config files:
  `swift/Assets.xcassets/` (166), `scripts/` (1); dependencies unchanged; test
  functions unchanged at 92.

## Beta Commit 146

- **The send Live Activity now runs** (new `AppState+SendLiveActivity.swift`;
  `SendTransactionLiveActivityAttributes.transactionID`)
  - An activity starts when a broadcast is accepted, ends as Sent or Send failed
    when core reports a terminal status, and lingers five minutes; one that gets
    no update reads as stale after an hour (before: the widget extension shipped
    but nothing requested an activity).
  - Activities whose transaction finished or disappeared while the app was not
    running are ended at the next pending refresh.
  - Addresses and hashes are middle-truncated; the amount is formatted without
    its symbol (`formattedAssetAmountValue`).
- **Popular chains in the setup picker come from the catalog's `popular_rank`**
  (`WalletSetupViews.swift`; before: eight ids hardcoded).
- **Derivation path resolution returns only the path** (`Chain.resolve(path:)`;
  `SeedDerivationResolution`, `SeedDerivationFlavor`,
  `derivationResolution(for:chain:)` removed).
- **Unused state removed**: wallet-secret index caches, Tron last-send-error
  fields and diagnostic title, performance samples, `walletByIDString`, the
  duplicate `gasTokenSymbol` on setup chain rows.
- **`swift-collections` dropped** (`DequeModule` and `OrderedCollections`
  products removed from the project).
- Tests: 6 new
  - Send Live Activity content 6: a phase not naming itself and the chain; a
    generic line shown over a failure reason; the symbol inside the amount text;
    long identifiers losing an end; a hash shown before there is one; the timer
    not starting at the transaction's own time.
- Total: 26 .swift files changed (2 new), +390 −239 lines; data and config
  files: `resources/strings/` (7), `swift/Spectra.xcodeproj/` (2); dependencies:
  removed swift-collections 1.4.1 (`Package.resolved`); test functions 86 → 92.

## Beta Commit 145

- **Generated bindings are no longer patched** (`scripts/bindgen-ios.sh`):
  UniFFI 0.31.2 emits `nonisolated(unsafe)` on the callback `vtablePtr` statics
  itself, so the `sed` patch is removed and 0.31.2 is the stated floor; the
  bindgen tool is always built `--release` (2.4 s against 3.1 s per Xcode build,
  output byte-identical).
- **View-model-to-record conversions moved into the test target** (new
  `swift/tests/CoreModelsTestSupport.swift`; `WalletView.walletState`,
  `TransactionRecord.persistedSnapshot` removed from `CoreModels.swift`): only
  tests convert in that direction.
- **Unused helpers removed**: `WalletView.bitcoinAddress`,
  `AppEndpointDirectory.bitcoinWalletStoreDefaultBaseURLs`,
  `AppEndpointExplorerEntry`, and the `rub` fiat icon.
- Docs: `FFI-BOUNDARY.md` header (UniFFI 0.31.2) and "Regenerate" (the script
  post-processes nothing).
- Total: 6 .swift files changed (1 new), +80 −100 lines; data and config files:
  `scripts/bindgen-ios.sh`,
  `swift/Assets.xcassets/fiaticon/rub.imageset/Contents.json`,
  `swift/Assets.xcassets/fiaticon/rub.imageset/rub.svg`; dependencies unchanged;
  test functions unchanged at 86.

## Beta Commit 144

- **Every send goes through a core-issued review**
  (`AppState+SendExecution.swift` `submitSend`, `submitReviewedSend`;
  `WalletServiceBridge.reviewOwnedSend`, `executeOwnedSend(reviewID:input:)`;
  `AppState.pendingSendReview`)
  - Tapping Send asks core for a review: amount, destination and network, the
    estimated fee, and core's warnings (high-risk reasons, EVM recipient checks,
    self-send), shown in the confirmation sheet; confirming executes that
    review.
  - Execution is refused when the inputs changed since the review ("Send inputs
    changed. Review the transaction again.") or when no review exists.
  - Warnings arrive as codes and the app supplies the words
    (`highRiskSendMessages`, `evmRecipientMessages` in
    `Store+Formatting.swift`); the Swift self-send bookkeeping and
    `highRiskSendReasons`/`evmRecipientPreflight` bridge calls are removed.
- **Refresh scheduling is one core call per intent** (`MaintenanceStore.swift`
  `performCoreRefresh(_:)`;
  `WalletServiceBridge.refreshApp(intent:conditions:)`)
  - User, foreground, scheduled, after-send, balances-updated, per-chain and
    deep-rescan refreshes pass an `AppRefreshIntent` and the device conditions;
    core returns the next poll interval, pending-status changes and failures,
    which are logged.
  - Removed: the background maintenance tick, foreground staleness rule, Swift
    history and pending refresh scheduling, `refreshChainBalances` and UTXO
    discovery and reservation refreshes.
  - A user refresh already in progress is joined rather than started twice; the
    balance refresh engine is configured for the device state
    (`configureBalanceRefresh(appIsActive:)`) and restarted after the
    refresh-frequency setting is committed.
- **UTXO rescan is a core deep rescan** (`runUTXORescan`), logged as started,
  completed or partial.
- **Advanced UTXO send controls removed** (`SendNetworkStep.swift`;
  `sendAdvancedMode`, `sendUTXOMaxInputCount`, `sendEnableRBF`,
  `sendEnableCPFP`, `LitecoinChangeStrategy`): max-input cap, RBF/CPFP intent
  toggles and the Litecoin change strategy picker are gone from the composer.
- **Advanced derivation overrides reduced to passphrase and HMAC key**
  (`ImportDraft.swift`, `WalletSetupViews.swift`;
  `coreParseWalletDerivationInput`): the wordlist, PBKDF2 iteration count, salt
  prefix, curve, derivation and address algorithm, public-key format and
  script-type fields are removed; secret text is used exactly as entered, and
  core refuses unsupported overrides.
- **Wallets are core's `WalletView`** (`ImportedWallet` / `CoreImportedWallet` →
  `WalletView`, `WalletSummary` → `WalletState`): `wallets` is a read-only
  projection; asset names are `assetDisplayName` and artwork names come from
  core's `*ArtworkName` helpers.
- **Swift persistence shapes removed** (`PersistenceStore.swift`
  `PersistedCoin`, `Codable` conformances for derivation overrides and paths).
- Tests: 3 new, 4 removed
  - Core refresh 1: a refresh intent failing across the binding, or a send
    executed without a core-issued review.
  - Derivation input 1: whitespace in a passphrase being trimmed.
  - Network wiki faces 1 (replacing the all-faces artwork test).
  - Removed: the diagnostics bundle-list table test and two setup-copy tests
    made redundant by the simplified switch.
- Total: 55 .swift files changed, +445 −1090 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 87 → 86.

## Beta Commit 143

- **Sends are previewed and executed by core from the wallet and holding**
  (`AppState+SendExecution.swift`, `AppState+SendPreview.swift`;
  `WalletServiceBridge.previewOwnedSend`, `executeOwnedSend`;
  `AppState+SendRouting.swift` deleted)
  - One preview call per selection replaces the per-family previews (EVM,
    Bitcoin HD, UTXO, Dogecoin, Tron and simple chains); stale responses for
    changed input, nonce or fees are dropped and a failure clears the preview
    and shows the error.
  - One submit call replaces the per-chain submit branches, broadcast and
    record-keeping in Swift; EVM nonce and fee overrides are passed through, and
    the app re-reads the projection to find the sent record.
  - Removed: Tron error mapping, `isValidAddressForPolicy`, `mapEvmSendError`
    and the preview types in `SendPreviewTypes.swift`.
- **Speed Up and Cancel drafts come from core**
  (`replacementDraft(transactionID:cancel:)`): wallet, holding, destination,
  amount, nonce and bumped fees arrive filled (before: the app fetched the nonce
  and bumped fees itself).
- **Self-send confirmation is core's plan** (`selfSendConfirmation`), replacing
  the Swift plan builder.
- **Price alerts are core commands** (`AppState.editPriceAlert`;
  `PriceAlertsView.swift`): add, toggle and remove send `StateCommand`s; core
  rejects duplicates and keeps sub-cent targets, and the rejection is shown on
  the form (before: Swift checked duplicates and wrote the list).
- **Large-movement notifications are evaluated by core**
  (`MaintenanceStore.swift` `notifyPortfolioMovement`,
  `evaluatePortfolioMovement(appIsActive:)`; before: Swift compared portfolio
  totals and kept a baseline).
- **Staking is informational only** (`StakingView.swift`,
  `StakingViewModel.swift`; `StakingBridge.swift`, `StakingTypes.swift`
  deleted): the Actions section and the delegate, manage and claim flows are
  removed; validators load through `WalletServiceBridge.fetchStakingValidators`,
  and the page says it does not sign or submit staking transactions.
- **Every bridge call waits for core storage to open**
  (`WalletServiceBridge.readyService`): an open failure refuses the call and can
  be retried, instead of writing to an in-memory store; the bridge registers the
  Keychain secret store when it creates the service.
- **Receive address errors are shown** (`AppState+ReceiveFlow.swift`
  `receiveAddressError`): no address, or a failed request, is reported instead
  of an empty field; a superseded request is ignored.
- **Transaction rows name the network they happened on**
  (`displayChainTitle(for:)` uses the record's chain, not the wallet's current
  network) and draw artwork by deployment id (`coreDeploymentIconAssetName`).
- **Removed Swift writes to core's stores**: `recordWallets`, `clearAllWallets`,
  `recordTransactions`, `removeTransactions`, `clearAllTransactions`,
  `mergeAdoptedProjection`; launch reload adopts what core stored.
- **`scripts/unreachable-exports.sh` counts only calls**: declarations and
  comments are stripped before searching Swift and CLI sources for each export.
- Strings: staking copy replaced; unused import-flow titles and address-format
  strings removed.
- Tests: 8 new, 5 removed
  - Storage 2: a failed open writing in memory or not retryable; a cold bridge
    returning an imported wallet before it is persisted with its secret.
  - Core-owned flows 3: a preview for a missing wallet; portfolio movement,
    unsupported staking and a missing wallet's receive address not refused;
    price alerts losing sub-cent targets or accepting duplicates.
  - History title 1: a record's network title following the current network
    selection.
  - Artwork 2: catalog token identities and held deployments not loading their
    own artwork (replacing two symbol-based artwork tests).
  - Removed with the code they covered: projection adoption, the EVM-only
    preview test and the secret-callback import test.
- Total: 54 .swift files changed, +546 −2328 lines; data and config files:
  `resources/strings/` (11), `scripts/` (1), `swift/Spectra.xcodeproj/` (1);
  dependencies unchanged; test functions 84 → 87.

## Beta Commit 142

- **History refresh is one core call over a scope** (new
  `AppState+History.swift`;
  `WalletServiceBridge.refreshHistory(scope:loadMore:interval:)`;
  `StoreHistoryRefresh.swift` and `ChainRefreshDescriptors.swift` deleted)
  - Scheduled, per-chain, per-wallet "Load more" and diagnostics refreshes all
    pass a `HistoryRefreshScope`; core decides which chains are due and returns
    per-chain outcomes, and the app marks chains degraded or healthy and records
    diagnostics rows.
  - Removed: the per-family refresh functions (`refreshBitcoinTransactions`,
    `refreshMultiAddressUTXOTransactions`, `refreshEVMTokenTransactions`,
    `refreshNormalizedChainTransactions`), the per-chain descriptor table, and
    the bridge's history plan and cursor calls.
- **Reset is one core call** (`StoreLifecycleReset.swift`;
  `resetData(scopes:)`): the app waits for queued wallet and contact writes,
  then adopts the state and plan core returns (before: a sequence of
  Swift-driven cleanup steps).
- **Receive and owned addresses come from core for every chain**
  (`receiveAddress(walletID:chainId:reserve:)`, replacing `utxoReceiveAddress`;
  `discoverChainAddresses(chainId:)` per chain with per-wallet errors)
  - Removed from Swift: receive and change index reservation, owned-address
    registration, live receive-address activation and
    `syncChainOwnedAddressManagementState`.
- **Holdings, prices and dashboard pins are keyed by deployment id, not symbol**
  (`CoreModels.swift` `holdingKey` is the holding's id, e.g.
  `bitcoin-testnet-4:native`; `TransactionRecord.deploymentID`;
  `DashboardStore.swift`)
  - Pinned dashboard assets are core's `pinnedDashboardTokenIds` setting; asset
    groups and pin options are computed by core without the app passing prices.
  - Amount precision is looked up by deployment id
    (`formattedAssetAmount(_:symbol:deploymentID:)`); wiki entries are keyed by
    token id.
  - Chain icons use `network:<id>` identifiers; `WalletChainID` resolves through
    core and a ticker such as "ETH" no longer selects a network.
- **Testnets are never priced** (`coreUnpricedChainNames()`).
- **Price alerts are evaluated by core against its stored quotes**
  (`evaluatePriceAlerts()` with no arguments).
- **Endpoints come from core's catalog** (`WalletService.newCatalog()`): the
  bridge's endpoint payload builders and the Etherscan API key hand-off are
  removed.
- **Send affordability says when the fee cannot be estimated**
  (`sendAffordabilityMessage` `.unavailable` → "Unable to estimate network
  fee.").
- Removed: legacy Keychain account names `wallets.snapshot`,
  `wallets.core.snapshot.v1` and defaults keys for logs, keypool, owned-address
  map and sync state; `deleteWalletSecrets`; `clearAllWalletsDetached`.
- Tests: 1 new
  - Core-owned operations 1: history refresh, price alerts, address discovery,
    receive address for a missing wallet and reset failing across the async
    binding.
  - Existing tests updated to the deployment-id keys; `WalletChainID("ETH")`
    must not resolve.
- Total: 40 .swift files changed (1 new), +310 −1392 lines; data and config
  files: `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 83 → 84.

## Beta Commit 141

- **Pending-transaction maintenance is one core call**
  (`AppState+ReceiveFlow.swift`;
  `WalletServiceBridge.refreshPendingTransactions`, replacing
  `pendingMaintenanceChains`): core returns the chains with work, the status
  changes and per-chain failures, which are logged; core also prunes status
  trackers on its sweep (`pruneStatusTrackers` removed from reset).
- **A manual status recheck is done by core** (`AppState+SendFlow.swift`
  `retryUTXOTransactionStatus`; `recheckTransactionStatus(id:)`, replacing
  `resetStatusTracker`): core validates the transaction, rechecks it and commits
  the result; a missing transaction reports "Transaction not found" (before:
  Swift reset the tracker and re-polled the chain).
- **Chain refresh descriptors lose their pending-only hook**
  (`ChainRefreshDescriptors.swift` `executePendingOnly` → `executeHistoryOnly`):
  pending refresh goes through the core call.
- **Bitcoin account xpub derivation calls core's free function**
  (`deriveBitcoinAccountXpubTyped`), without a service.
- Tests: 2 new
  - Pending maintenance 2: the owned maintenance call failing across the async
    bridge; a recheck of a missing transaction reported as success.
- Total: 7 .swift files changed, +69 −76 lines; data and config files: none;
  dependencies unchanged; test functions 81 → 83.

## Beta Commit 140

- **Wallet changes are core commands; the app adopts the committed projection**
  (`AppState+CoreStateStore.swift` `changeWallet`, `removeWallet`;
  `AppState+ReceiveFlow.swift` `renameWallet`)
  - Rename, remove and portfolio inclusion send `StateCommand`s in order and
    re-read the stored wallets (before: the app wrote whole wallet records back,
    `updateWalletDetached`, `updateWalletsIfPresent`).
  - Deleting a wallet is the one `removeWallet` command (before: the app also
    deleted its secrets, relational data, transactions and keypool itself); when
    core refuses, the error is shown and the app's local cleanup does not run.
  - Import stores the seed or private key through core's registered secret store
    before the wallet is returned (`storeWalletSeedPhrase`,
    `storeWalletPrivateKey` and the per-wallet keypool and relational-data
    deletes removed from the bridge).
- **Balance refresh only reads back what core committed**
  (`AppState+BalanceRefresh.swift`): the Swift batch that applied balance
  summaries to holdings and `refreshKnownTokenBalances` are deleted; a read that
  overlaps a user change is discarded.
- **Prices and fiat rates are refreshed, stored and timestamped by core**
  (`AppState+PricingFiat.swift` `applyQuoteProjection`; `refreshOwnedPrices`,
  `refreshOwnedFiatRates`)
  - Core chooses which coins to price; a response older than the projected one
    is ignored, and fetch errors are shown (`quoteRefreshError`,
    `fiatRatesRefreshError`).
  - Removed: the `pricing.livePrices.v1` store, the six-hour fiat interval and
    60-second backoff in Swift, and `priceRequestCoins`.
- **Diagnostics state and operational logs moved into core**
  (`DiagnosticsState.swift`; `diagnosticState`, `applyDiagnosticCommand`)
  - Degraded chains, last good sync and the log are core's `DiagnosticState`,
    changed through queued `DiagnosticCommand`s (append, healthy, synced,
    degraded, clear, reset); a write failure is kept in `persistenceError`.
  - Removed: the `chain.sync.state.v1` and `operational.logs.v1` keys and their
    debounced persistence.
- **Endpoint probes for every chain run in core** (`probeChainEndpoints`):
  Bitcoin and Monero use the catalog path too; the Swift HTTP and JSON-RPC
  probes are removed.
- **Funds Finder scans through core in batches** (`AppState+FundsFinder.swift`,
  `beginFundsScan`): progress, hits and errors come from `FundsScan.nextBatch`
  (before: Swift checked each candidate).
- **EVM send preview is built by core from the wallet and holding**
  (`previewOwnedEvmSend`, replacing `fetchEvmSendPreviewTyped`); a stale
  response for changed input is dropped.
- **Rebroadcast and pending-send records are core's**
  (`rebroadcastTransaction(id:)`; `rebroadcastSignedTransaction`,
  `recordPendingSentTransaction`, `decoratePendingSendTransaction` removed):
  after a send the app re-reads the projection to find the new record.
- **Pending-maintenance chains come from core** (`pendingMaintenanceChains`).
- **Built-in token list removed from Swift** (`StaticContentCatalog.swift`
  `TokenPreferenceEntry.builtIn`).
- **Wiki pages drop the rotating 3D coin** (`WikiCoinViews.swift`
  `WikiRotatingCoin`; chain and coin pages show a 52 pt badge instead of 38 pt
  beside a rotating coin).
- **Run action in the shared scheme builds Release** (`Spectra.xcscheme`
  LaunchAction `Debug` → `Release`).
- Tests: 1 new
  - Import 1: an imported wallet returned before its secret was stored, or its
    secret kept after removal.
  - The EVM preview test now guards a preview built for a missing wallet.
- Total: 26 .swift files changed, +297 −1314 lines; data and config files:
  `swift/Spectra.xcodeproj/xcshareddata/xcschemes/Spectra.xcscheme`;
  dependencies unchanged; test functions 80 → 81.

## Beta Commit 139

- **Send flow is four steps with inline checks** (`SendFlowViews.swift`; new
  `SendNetworkStep.swift`, `SendConfirmationStep.swift`;
  `SendPrimarySectionsView.swift`)
  - Steps are From, Recipient, Amount, Confirm with a "Step N of 4" progress
    bar; the fee and per-chain network options moved from their own step into
    the confirmation page.
  - The recipient is checked by core 350 ms after typing, showing "Checking
    recipient...", a verified label, or an error with Retry; Next waits for it.
  - Amount shortcuts are 10%, 50% and MAX of the fee-adjusted maximum core
    quotes (`sendAmountShortcut`, `quotedSendAmount`), enabled only when the
    quote matches the current input; an amount beyond the asset's precision is
    refused (`sendAmountIsValid`).
  - Confirm requires a current quote for the entered amount; a provisional quote
    can load before an amount is typed (`sendPreviewAmountInput`).
- **An ENS-resolved recipient must still match the address the user reviewed**
  (`AppState.reviewedSendDestination`;
  `resolveSendDestination(expectedAddress:)` calls core's
  `verifySendDestination`): a send whose name now resolves elsewhere is refused
  with "Review the resolved recipient address before sending."
- **Tracked-token edits are core commands** (`AppState.swift`
  `addCustomTokenPreference`, `setTokenPreferencesEnabled`,
  `removeCustomTokenPreference`, `updateCustomTokenPreferenceDecimals`;
  `AddCustomTokenView.swift`)
  - `tokenPreferences` is a read-only projection; tokens are addressed by chain
    and contract, and core's refusal reason (invalid contract for the chain,
    duplicate, more than 30 decimals, built-in token and others) is shown beside
    the form.
  - Removed: the Swift symbol, contract and duplicate checks, the seven-arm
    contract switch that assumed EVM by default, the `0…30` decimals clamp and
    `commitTokenPreferences`. Reset sends `resetTokenPreferences` to core.
- **Owned-address lookups distinguish failure from empty**
  (`AppState+SendFlow.swift` `knownUTXOAddresses`, `discoverUTXOAddresses`;
  `AppState+OperationalTelemetry.swift`)
  - A failed lookup returns `nil` and is logged; the Dogecoin self-send guard
    then asks the user rather than letting the send through.
  - A wallet whose discovery fails keeps its previous addresses; a failed
    owned-address registration is logged instead of dropped.
- **A network switch drops the chain's keypool and owned addresses in one core
  call** (`WalletServiceBridge.resetChainDerivationState`, replacing two
  separate deletes); failure is logged.
- **Secret-store registration is awaited at launch and its failure shown**
  (`SecureStores.swift` `registerWithBridge() async throws`,
  `AppState.secretStoreRegistrationError`, `DashboardStore.swift` "Secure
  Storage Unavailable" notice; before: a detached task with the error
  swallowed).
- **Reset steps run to completion and log failures**
  (`StoreLifecycleReset.swift` `runResetStep`; before: detached `try?` tasks).
- **Contact edits are applied in order** (`enqueueAddressBookCommand`): a read
  started before a write can no longer bring back removed contacts.
- **Swift derivation layer deleted** (`WalletDerivation.swift`,
  `WalletRustDerivationBridge.swift`), with per-chain balance-service enums and
  known-token tables for Solana, NEAR, Aptos, Sui and TON (`ChainTypes.swift`),
  history pagination helpers and other dead types.
- **History lists 20 rows at a time with "Load more", retries failed reads and
  rechecks pending rows** (`HistoryView.swift`): a pending or failed row with
  status recheck support gets a Recheck button; a read error shows "Unable to
  load history" with Retry (before: pages of 10 with prefetch).
- **Dashboard empty state has an Add Wallet button** (`DashboardViews.swift`);
  the Assets/Wallets picker moved into the header; the "Asset Hub" card on the
  asset detail page is removed.
- **Receive screen warns to receive only on the shown network**
  (`ReceiveFlowViews.swift`), with the actions in a bottom bar.
- **Wallet setup page wording comes from one exhaustive switch**
  (`SetupFlow.swift` `WalletSetupPage.copy(_:mode:)`; secret step split into
  `WalletSecretStep.swift`): replaces two if-chains with three unreachable
  branches.
- **Design tokens** (new `SpectraLayout.swift`,
  `scripts/check-design-tokens.sh`, `make check-ui`): seven named radii and two
  glass tints; the script fails a view that writes a numeric radius or white
  glass tint. Copy notices use `SpectraTransientNotice`; shimmer and step
  transitions respect Reduce Motion; haptic generators are reused and prepared.
- Tests: 14 new
  - Token preferences 4: a contract judged by the wrong chain family; an
    impossible precision clamped instead of refused; a built-in token removed;
    untracking deleting the row.
  - Setup page copy 5: a page with a blank title or subtitle in some mode; the
    secret page naming the wrong secret; editing falling through to the
    chain-picker title.
  - Send destination 3: an invalid TON checksum or test-only flag accepted;
    unopened storage polled as no pending transactions; a changed destination
    sent without a new review.
  - Send amount 1: a fee-adjusted shortcut not floored, or an overflow amount
    parsed.
  - Address book 1: an older read resurrecting removed contacts.
- Docs: `docs/iosUI.md` "Cards" tint steps and the radius table, now named
  tokens, plus the check script.
- Total: 55 .swift files changed (7 new), +2667 −2141 lines; data and config
  files: `Makefile`, `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `scripts/check-design-tokens.sh`, `swift/Spectra.xcodeproj/project.pbxproj`;
  dependencies unchanged; test functions 66 → 80.

## Beta Commit 138

- **Send destinations are resolved by core, ENS included**
  (`AppState+SendFlow.swift` `resolveSendDestination`;
  `WalletServiceBridge.resolveSendDestination`;
  `AppState.cachedResolvedENSAddresses`, `isENSNameCandidate`,
  `resolveEVMRecipientAddress` removed)
  - Which chains resolve a name is core's `Chain::resolves_ens_names`, and the
    resolved-name cache is core's (before: `chainName == "Ethereum"` in three
    Swift call sites and a Swift cache).
  - The preview, the submit path and the destination probe all go through the
    one call; input core refuses clears the probe.
- **The destination risk probe names the wallet and holding; core identifies the
  asset** (`sendDestinationRisk(walletID:holdingKey:destination:)`): an asset
  core cannot identify is an error (before: the composer passed a token
  descriptor and showed nothing when it could not build one).
- **EVM send preview assembles the typed amount string**
  (`AppState+SendPreview.swift`; before: a `Double` was passed, so 1.1 assembled
  1100000000000000089 wei while the send signed 1100000000000000000).
- **NEAR token sends check core's gas reserve** (`AppState+SendExecution.swift`,
  `preflight.tokenSendGasReserve`; before: `0.001` NEAR hardcoded); Tron, Solana
  and NEAR gas balances are read by the chain's gas symbol from the catalog.
- **Receive address source is core's three-way rule**
  (`CachedCoreHelpers.receiveAddressSource`, replacing the 25-variant
  `receiveAddressResolver`): Bitcoin reads its stored account address, Dogecoin
  resolves none of its own, every other chain reads its stored address; the
  watch-address flag now reads the shown chain's address (before: always
  Dogecoin's). `dogecoinAddress` removed.
- **Token registry settings filter offers every hosting chain**
  (`TokenRegistrySettingsView.swift`): the filter is `TokenHostingChain?`
  (before: a Swift enum of 18 of the 28 chains).
- **Custom token contract validation accepts any EVM chain the registry marks**
  (`AppState.swift`, `addressValidationKind == "evm"`; before: twelve EVM chains
  hand-listed).
- **Dashboard default pinned assets come from core** (`DashboardStore.swift`,
  `dashboardDefaultPinnedAssets()`; before: `["BTC", "ETH", "USDT", "USDC"]` in
  Swift).
- **Price requests carry the holding key** (`AppState+PricingFiat.swift`,
  `PriceRequestCoin(holdingKey:coinGeckoId:)`).
- **Icons `usat`, `usdt0`, `xaut0` added, `usdb` updated**
  (`swift/Assets.xcassets/cryptoicon/`).
- Tests: 5 new
  - Send destination 5: a typed address not normalized; an ENS name accepted off
    Ethereum; an empty field resolved to nothing; a risk probe for an unknown
    holding probing something else; an address from another family accepted.
  - The artwork test now fails a token or chain whose named mark does not load
    (before: tokens without artwork failed or passed alike).
- Total: 14 .swift files changed (1 new), +293 −180 lines; data and config
  files: `swift/Assets.xcassets/` (7); dependencies unchanged; test functions 61
  → 66.

## Beta Commit 137

- **Seed-phrase checking moved into core** (`ImportDraft.swift`
  `seedPhraseVerdict`, `coreCheckSeedPhrase`; `WalletSetupViews.swift`)
  - The import grid reads one `SeedPhraseVerdict` from core: words, invalid
    words, checksum, error and length warning (before: Swift's
    `WalletImportDraftValidation`, the `BIP39WordList` loader and
    `rustValidateMnemonic`).
- **Private-key import no longer derives an address in Swift**
  (`AppState+ReceiveFlow.swift`; `derivePrivateKeyImportAddress` and
  `WalletRustDerivationBridge.deriveFromPrivateKey` removed): the key's shape is
  checked on the form, and core derives from the secret at commit and refuses a
  key that derives nothing.
- **A failed history read is shown instead of read as empty**
  (`Store+Formatting.swift`, `StoreLifecycleReset.swift`, `HistoryView.swift`,
  `AppState.historyReadError`)
  - `normalizedHistory`, `earliestTransactionDates`,
    `activeWalletTransactionIDs` and `replaceableSends` throw across the bridge
    (before: an unopened store answered an empty list).
  - On failure the History screen shows "Unable to read transaction history.
    Existing records have been kept." and the existing records stay.
- **Send destination check says when an address's activity could not be
  verified** (`AppState+SendFlow.swift`): a failed risk probe shows "Unable to
  verify this address's activity. Try again later." (before: nothing).
- **Crypto icons redrawn** (`swift/Assets.xcassets/cryptoicon/`): 71 artworks
  updated (e.g. glyphs rescaled into the 64×64 disc with explicit fills),
  `berausd` added.
- Tests: 1 new
  - History bridge 1: an unopened history store returning an empty success.
- Total: 12 .swift files changed, +385 −558 lines; data and config files:
  `swift/Assets.xcassets/` (73), `resources/strings/` (3); dependencies
  unchanged; test functions 60 → 61.

## Beta Commit 136

- **Token sends use the contract and decimals core resolved**
  (`AppState+SendExecution.swift`; `AppState.solanaKnownTokens` removed)
  - Tron: decimals come from core's preflight (before: six hardcoded for every
    Tron token, wrong for the four 18-decimal tokens in the catalog).
  - Solana: the mint comes from core (before: a Swift token map that included
    disabled tokens, so a turned-off token could still be sent).
  - NEAR: a token core cannot resolve is refused (before: a Swift lookup fell
    back to six decimals).
- **A send on a chain that computes its own fee no longer needs a loaded
  preview** (`AppState+SendExecution.swift`): Stellar, XRP and Internet Computer
  were refused whenever no fee estimate had loaded; Internet Computer's separate
  arm that skipped the check is gone.
- **Litecoin MWEB peg-in output is priced by core's preview**
  (`fetchUtxoFeePreviewTyped(destinationAddress:)`): the extra-output arithmetic
  in Swift is removed.
- **Tron send preview follows core's asset routing**
  (`sendAssetRouting(...).previewKind == "tron"`; before: `TRX || USDT` written
  out in Swift).
- **Import passes no wallet ids; core mints them**
  (`AppState+ReceiveFlow.swift`, `plannedWalletIds: []`): the app no longer
  predicts the number of wallets a watch-only import creates, and no longer
  fills both EVM address slots itself.
- **String resources are flat files at the bundle root**
  (`resources/strings/<locale>/X.<locale>.json` →
  `resources/strings/X.<locale>.json`; `StaticContentCatalog.swift`): content
  lookup tries only the flat name (before: three path shapes, of which only the
  flat one existed in the bundle).
- **Icon sources moved under `icons/`** (`resources/appicon/` →
  `icons/appicon/`; `scripts/export-swift-icons.sh` reads `icons/appicon`,
  `icons/cryptoicon`, `icons/fiaticon`); `LocalizationGlossary.json` moved from
  `resources/strings/` to `docs/`.
- Total: 6 .swift files changed, +110 −176 lines; data and config files:
  `resources/strings/` (24), `icons/appicon/` (2), `docs/` (1), `scripts/` (1);
  dependencies unchanged; test functions unchanged at 60.

## Beta Commit 135

- **Pending-transaction polling moved into core**
  (`AppState+DiagnosticsEndpoints.swift`, `AppState+OperationalTelemetry.swift`
  `applyPendingStatusChanges`; `WalletServiceBridge.pollPendingTransactions`)
  - The app now calls core's `poll_pending_transactions` per chain and receives
    only what changed; the three Swift poll loops (UTXO status, address history,
    EVM receipt), the backoff questions to core and
    `PendingTransactionStatusResolution` are deleted.
  - The app keeps the localized operational event and the notification for each
    change.
- **Bitcoin and UTXO-chain history refresh moved into core**
  (`StoreHistoryRefresh.swift`; `WalletServiceBridge.refreshBitcoinHistory`,
  `refreshUTXOChainHistory`)
  - Bitcoin: the Swift xpub derivation from the Keychain seed (by cutting the
    account path out of the derivation path), stored-address and stored-xpub
    fallbacks, and `BitcoinHistoryPage` are replaced by
    `refresh_bitcoin_history`.
  - Other UTXO chains: per-address fetching, aggregation and merging are
    replaced by `refresh_utxo_chain_history` over core's keypool addresses.
- **Bitcoin history diagnostics run the real refresh**
  (`runBitcoinXpubHistoryDiagnostics`): the rows are the refresh's own report,
  the fetched page is merged instead of discarded, and the run is bounded at 20
  seconds (before: a second copy of the source selection fetched a page per
  wallet and threw it away).
- **Bitcoin and UTXO send previews are priced on the wallet's network**
  (`AppState+SendPreview.swift`;
  `fetchBitcoinHdSendPreviewTyped(chainId:xpub:)`): the chain id is resolved
  from the wallet (before: the family's mainnet was passed in, so a testnet send
  would read its balance and fee against mainnet).
- **Asset group `coinicon` renamed `cryptoicon`, exported from
  `resources/cryptoicon/`** (`scripts/export-swift-icons.sh`,
  `swift/Assets.xcassets/cryptoicon/`): stablecoin and gold-token icons renamed
  to their tickers (`tetherusdt` → `usdt`, `circleusdc` → `usdc`, `circleeurc` →
  `eurc`, `ethenausde` → `usde`, `firstdigitalfdusd` → `fdusd`, `paxosusdg` →
  `usdg`, `paxospaxg` → `paxg`, `paypalpyusd` → `pyusd`, `ripplerlusd` →
  `rlusd`, `skyusds` → `usds`, `tetherxaut` → `xaut`, `wlfiusd1` → `usd1`).
- Total: 6 .swift files changed, +300 −594 lines; data and config files:
  `swift/Assets.xcassets/` (158), `scripts/` (1); dependencies unchanged; test
  functions unchanged at 60.

## Beta Commit 134

- **Speed Up and Cancel are offered on every EVM chain, from core's list of
  replaceable sends** (`AppState+SendFlow.swift`
  `replaceableSendForSelectedWallet`, `prepareReplacementContext`,
  `openReplacementComposer`; `WalletServiceBridge.replaceableSends`;
  `SendFlowViews.swift`, `TransactionDetailView.swift`)
  - Which pending sends can be replaced now comes from core's
    `replaceable_sends`, adopted into `AppState.replaceableSends` with the
    transaction projection (before: two Swift filters over the projection that
    matched only the chain named "Ethereum", so a pending Arbitrum or Base send
    offered neither action).
  - The replacement composer moves to the pending send's own chain and its gas
    asset, and refuses with a message when the wallet has no gas holding there
    (before: it always moved to Ethereum).
  - A pending token transfer can be cancelled but not sped up (before: Speed Up
    composed a native transfer of the token's amount, e.g. 100 ETH for a 100
    USDC send).
  - The replacement fee is the chain's live EIP-1559 estimate, bumped; the fixed
    Ethereum defaults apply only when no estimate loads.
  - Strings and the detail card name the chain ("%@ Mempool Actions") instead of
    Ethereum.
- **Custom EIP-1559 fees and a manual nonce apply on every EVM chain**
  (`AppState+SendFlow.swift`; `useCustomEthereumFees` → `useCustomEvmFees`,
  `ethereumManualNonce` → `evmManualNonce` and related)
  - Typed fees and nonce are cleared when the selection leaves the EVM family
    (before: they were parsed only for the chain named "Ethereum", so on the
    other 22 EVM chains they were shown as applied and dropped).
- **Addresses are read from what core stored at import, not re-derived from the
  seed** (`AppState+AddressResolution.swift` `resolvedAddress(for:chainName:)`)
  - The per-chain descriptor table and resolvers (`resolvedEVMAddress`,
    `resolvedTronAddress`, `resolvedCardanoAddress`, `resolvedMoneroAddress` and
    others) are gone; the address is the one core stored for the wallet's
    network slot, with the EVM family sharing Ethereum's slot.
  - A wallet answers only for chains it was imported for (before: any chain in
    the catalog was derived from its seed), and a password-sealed wallet on a
    testnet shows its testnet address (before: the mainnet one).
- **Balance refresh entries are built by core**
  (`AppState+BalanceRefresh.swift`; `WalletServiceBridge.syncRefreshEntries`
  replaces `setRefreshEntriesTyped`): the app no longer resolves addresses and
  hands over `(chain, wallet, address)` triples, so a sealed wallet is no longer
  dropped from refresh.
- **History refresh is planned, fetched and merged by core**
  (`StoreHistoryRefresh.swift`; `WalletServiceBridge.refreshChainHistory`,
  `refreshEVMChainHistory`)
  - The app now uses core's `refresh_chain_history` and
    `refresh_evm_chain_history`; the Swift planning, address grouping, paging,
    record building and merging are deleted, and the app keeps the
    degraded-chain banner and the EVM diagnostics rows.
- **Diagnostics run through one generic path per chain**
  (`AppState+DiagnosticsEndpoints.swift` `runHistoryDiagnostics(for:)`,
  `runEndpointDiagnostics`; `AdvancedSettingsView.swift`)
  - The eight-row `chainDiagDescriptors` table and per-chain endpoint functions
    (Ethereum, BNB, NEAR, Polkadot) are removed; Bitcoin keeps its xpub history
    read, Bitcoin and Monero their own endpoint probes.
  - "Run All" iterates `Chain.mainnets` (before: a hand-written list of 22 calls
    that missed Base, Polygon, Zcash, Kaspa, Dash, Decred, Bitcoin SV, Bitcoin
    Gold, Dogecoin, Sei and newer rollups).
- **Chain self-tests are offered on every chain's diagnostics screen**
  (`AppState+SendFlow.swift` `runSelfTests(for:)`, `DiagnosticsViews.swift`)
  - Core's offline suite runs for any chain, plus an RPC identity probe on EVM
    chains; `runEthereumSelfTests` and its JSON-shape and portfolio probes are
    removed (before: the button sat in the UTXO block, with a separate Ethereum
    button).
- **Keypool reads throw instead of defaulting**
  (`WalletServiceBridge.keypoolState`, `AppState.keypoolState`,
  `chainKeypoolDiagnostics`): an invalid baseline is shown as an error on the
  diagnostics screen rather than becoming index zero.
- **Tor settings and fiat rates moved into core** (`AppState.swift`,
  `Store+Settings.swift`, `AppState+PricingFiat.swift`,
  `PersistenceStore.swift`)
  - Tor on/off, custom proxy, proxy address and kill switch are core settings
    pushed and adopted like the others (before: `UserDefaults` keys `tor.*`);
    core validates the SOCKS5 address and enforces the kill switch.
  - Fiat rates are fetched, merged and stored by core
    (`refreshFiatRatesViaRust`) and adopted from core state; the SQLite key
    `pricing.fiatRatesFromUSD.v1` is no longer read.
- **Unused views removed** (`WalletSetupViews.swift` `primaryActionButton`,
  `privateKeyImportSection`; `ReceiveFlowViews.swift`
  `receiveAddressPlaceholder`; `AppState.storedPrivateKey`).
- Tests: 6 new, 1 removed
  - Replaceable sends 3: a non-EVM or non-pending row offered for replacement; a
    token transfer offered Speed Up.
  - Address resolution 1: a wallet answering for chains it was not imported for.
  - Bridge errors 2: an invalid keypool baseline read as index zero; an EVM
    preview with no endpoints returning defaults.
  - Removed: the diagnostics run-descriptor table test, with the table.
- Total: 27 .swift files changed (1 new), +664 −1101 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 55 → 60.

## Beta Commit 133

- **A send names its wallet; core reads the keys, derivation path and source
  address** (`swift/AppState+SendExecution.swift`; `SendExecutionRequest`
  carries `walletId` and `password` in place of `chainName`, `derivationPath`,
  `seedPhrase`, `privateKeyHex`, `fromAddress` and `derivationOverrides`)
  - Every send arm (ICP, Bitcoin, Dogecoin, Tron, Solana, NEAR, EVM and the
    shared plain-shape path) stops reading the seed phrase or private key from
    the Keychain and stops resolving the source address and derivation path in
    Swift.
  - The app-side refusals that went with that ("This wallet's seed phrase is
    unavailable.", "Unable to resolve this wallet's … address") are removed;
    core refuses instead.
- Tests: 1 new
  - Send request 1: a send for a wallet core does not hold reaching the secret
    store or the network.
- Total: 2 .swift files changed, +41 −120 lines; data and config files: none;
  dependencies unchanged; test functions 54 → 55.

## Beta Commit 132

- **A send request carries the typed amount string only**
  (`swift/AppState+SendExecution.swift`, `AppState+SendFlow.swift`,
  `AppState+SendPreview.swift`; the `amount: Double` argument is removed from
  every send call)
- **A manual EVM nonce is parsed by core, and an invalid one stops the send**
  (core `parseEvmNonce`, `EvmNonceError`; `AppState.explicitEthereumNonce` now
  throws)
  - Before: an invalid manual nonce made `explicitEthereumNonce` return nil, so
    the send went ahead with the automatic nonce.
  - The three validation messages (empty, not a non-negative integer, too large)
    map from `EvmNonceError` (before: from `coreEthereumManualNonceValidation`
    codes).
- Tests: 3 new
  - EVM nonce 2: a large nonce truncated to 32 bits across the binding; an
    invalid manual nonce silently replaced by the automatic one.
  - Send amount 1: an amount with too many decimals, a negative, NaN or
    non-ASCII digits reaching signing material.
- Total: 5 .swift files changed (2 new), +70 −21 lines; data and config files:
  none; dependencies unchanged; test functions 51 → 54.

## Beta Commit 131

- **Custom EIP-1559 fees are parsed by core with typed refusals**
  (`swift/AppState+SendFlow.swift` `parsedCustomEthereumFees`; core
  `parseEvmCustomFees`, `EvmCustomFeeError`; before:
  `coreEthereumCustomFeeValidation` returned a code and Swift parsed the two
  gwei fields with `Double(...)` itself)
- **Token colours come from the built-in token catalog**
  (`swift/RegistryModels.swift`, core `listAllBuiltinTokens`;
  `TokenVisualRegistryEntry` removed); a native chain colour still wins for a
  shared symbol.
- **Unused code and copy removed**: `swift/LoadingTaskRegistry.swift`,
  `LocalizationCatalogReferenceKeeper`, and six keys across `CommonContent`,
  `DiagnosticsContent`, `DonationsContent` and `ImportFlowContent` in every
  locale (`rpcErrorFormat`, `crossChainSectionTitle`, `heroTitle` and three
  import-flow descriptions).
- Tests: 4 new
  - EVM custom fees 2: parsed fees changing across the binding; a fee refusal
    arriving as an untyped error.
  - Presentation catalog 2: coin colours bypassing the catalog or missing an
    untrimmed/lowercase symbol; bundled copy failing to decode in a locale.
- Total: 6 .swift files changed (2 new), +87 −153 lines; data and config files:
  `resources/strings/` (16), `swift/Spectra.xcodeproj/` (1); dependencies
  unchanged; test functions 47 → 51.

## Beta Commit 130

- **"Where can I buy crypto?" lists on-ramps and exchanges from one file** (new
  `resources/BuyProviders.json`, `swift/views/BuyCryptoHelpView.swift`,
  `StaticContentCatalog.swift`)
  - Five on-ramps (Banxa, MoonPay, Onramper, Ramp Network, Transak) and fourteen
    exchanges, alphabetical (before: four on-ramps whose URLs sat in
    `AppLinks.json` and names/descriptions in `SettingsContent`).
  - New copy explains the two kinds: on-ramps send to an address you enter,
    exchanges hold funds until you withdraw; Spectra takes no fee
    (`buyOnrampNote`, `buyExchangeNote`, `buyListingNote`; per-provider
    descriptions removed).
  - The rows are built once per process; before, each settings re-render minted
    new row ids and a tapped link could be torn down before it fired.
- **Swift package versions are pinned in the repository**
  (`swift/Spectra.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`:
  KeychainAccess 4.2.2, swift-collections 1.4.1); `.gitignore` shortened and
  adds the Gradle cache.
- Docs: `README.md` rewritten (product direction; development pointers to
  PLAN.md, ARCHITECTURE.md, FFI-BOUNDARY.md, iosUI.md); `docs/FFI-BOUNDARY.md`
  reorganised into "Export shapes", "Runtime and storage traps", "Callers and
  coverage", "Regenerating bindings", "Common errors"; `docs/iosUI.md` condensed
  ("Examples in the app", "Additional constraints").
- Total: 2 .swift files changed, +270 −537 lines; data and config files:
  `resources/strings/` (4), `resources/` (2), `.gitignore`,
  `swift/Spectra.xcodeproj/` (1); dependencies unchanged; test functions
  unchanged at 47.

## Beta Commit 129

- **Coin artwork is resolved by core from the coin's own symbol**
  (`swift/views/ImageRendering.swift` `CoinBadge`, core `coreIconAssetName`;
  `RegistryModels.swift` drops the native-icon and token-fragment tables)
  - A coin held off its home chain now draws its mark (before: 31 of the wiki's
    66 coins, and ETH on its nine rollups, drew a letter).
  - USDB artwork added (`swift/Assets.xcassets/coinicon/usdb.imageset`).
- **Sends share one broadcast routine** (`swift/AppState+SendExecution.swift`)
  - The concurrent-send check and the in-flight flag are set with no suspension
    between them (before: two sends on one chain could both pass the check).
  - A Dogecoin send now applies its verification status and refreshes the
    balance after broadcast (before: the balance stayed stale until the next
    scheduled refresh).
  - A Tron token send uses the token's own decimals (before: 6 for every Tron
    token; BTT, TUSD, USD1 and USDD have 18).
  - After a send on a UTXO testnet (Bitcoin Testnet, Testnet4, Signet, Litecoin,
    Bitcoin Cash, Bitcoin SV and Dogecoin testnets) the pending poll runs, as on
    mainnet (before: a history refresh).
- **Wallet-derived state is rebuilt as one value** (`AppState.swift`,
  `AppStateTypes.swift`); `LoadingTaskRegistry` trimmed.
- Tests: 5 new
  - Coin artwork 5: a coin on a chain other than its home drawing a letter; a
    held token and its wiki row drawing different marks; a wiki face whose mark
    does not load; a chain badge no longer drawing the chain; an unknown coin
    not falling back to its letter.
- Docs: `docs/FFI-BOUNDARY.md` callers and coverage (look for the camelCase name
  and `with_foreign` traits before calling an export dead; 72 exports have no
  caller in `core/` or `cli/`; `spectra tx assemble` as the CLI caller for
  `prepare_evm_send_assembly`); `docs/iosUI.md` path to
  `swift/views/ViewExtensions.swift`.
- Total: 24 .swift files changed (1 new), +398 −334 lines; data and config
  files: `swift/Assets.xcassets/coinicon/usdb.imageset/Contents.json`,
  `swift/Assets.xcassets/coinicon/usdb.imageset/usdb.svg`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 42 → 47.

## Beta Commit 128

- **Endpoint settings say what each catalog endpoint is**
  (`swift/views/EndpointsViews.swift` `endpointRow`,
  `AppEndpointDirectory.tagSummary`, core `appCoreEndpointTag`): a line under
  each URL such as "Node · Balance · Fees · Broadcast"; a user-typed endpoint
  shows the URL alone. 11 kind and capability strings added in each locale.
- **Bittensor send previews are handled** (`AppState+SendRouting.swift`,
  `SendPreviewTypes.swift`: `bittensor` case in the preview kind and fee
  accessors).
- **Unused members removed** across `AppState.swift`, `CoreModels.swift`,
  `ChainTypes.swift`, `StorePersistenceNormalization.swift` and others
  (maintenance interval constants, `accentMarks`, `primaryAddress`, known SPL
  token metadata, Monero backend defaults keys, `deriveSeedPhraseAddress`).
- Total: 13 .swift files changed, +64 −113 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 42.

## Beta Commit 127

- **EVM pending sends are polled by transaction receipt in core**
  (`swift/AppState+DiagnosticsEndpoints.swift`, `WalletServiceBridge.swift`)
  - A mined-and-reverted send is classified as failed; no receipt yet stays
    pending.
  - Before: the EVM arm of `refreshPendingTransactions(chainName:)` called
    itself with the same argument.
- **The wallet password seals the seed in core**
  (`AppState+ImportLifecycle.swift`, `SecureStores.swift`)
  - Import passes the password to core, which encrypts under it and stores a
    verifier; a wallet without a password is stored unsealed.
  - Revealing a seed is one core call that decrypts with the password (before:
    the password was checked against a verifier stored beside a plaintext
    phrase).
  - The Swift password-verifier store is removed.
- **UTXO address discovery and receive-index reservation run in core**
  (`AppState+ReceiveFlow.swift`): core reads the seed, path, keypool bound,
  balance and history, so the phrase no longer crosses for it; reserve, derive
  and record are one call.
- **Send affordability is decided by core; the app only words it**
  (`swift/Store+Formatting.swift` `sendAffordabilityMessage(SendAffordability)`,
  replacing `AppState.validateSendBalance`); the separate "…to cover the network
  fee" variant is dropped.
- **A recipient balance probe for a token asks the token's balance**
  (`AppState+SendFlow.swift`; before: three arms reported the chain's native
  balance as the token's); the zero-balance warnings name the asset ("zero %@
  balance").
- **The Etherscan key field says which chains still need it**
  (`DiagnosticsContent`: BNB Chain, Linea, Sei, Sonic, opBNB, Hyperliquid and
  Base; Cronos and X Layer have no history provider); label "Etherscan API Key
  (7 chains)".
- Tests: 1 new, 2 removed
  - Pending refresh 1: an EVM pending refresh that never terminates.
  - Removed 2: the Swift password-verifier save/delete tests, with the store
    they covered.
- Total: 12 .swift files changed, +373 −522 lines; data and config files:
  `resources/strings/` (7); dependencies unchanged; test functions 43 → 42.

## Beta Commit 126

- **EVM wallets get an address for balance refresh again**
  (`swift/AppState+AddressResolution.swift`)
  - The EVM branch was unreachable behind the generic descriptor lookup, so all
    23 EVM mainnets resolved to nil and their wallets were dropped from the
    refresh engine's entries; their balances never loaded.
  - Refresh targets resolve only wallets on the chain being refreshed (before:
    every wallet, each resolution reading the seed and deriving).
- **Ownership checks derive only the wallet's own chain address**
  (`AppState+AddressResolution.swift`; before: seventeen per-family derivations
  on every send and transaction open).
- **Receive shows the QR code inline** (`swift/views/ReceiveFlowViews.swift`):
  the address step has Share QR Code and Save QR Code; the separate full-screen
  QR sheet and "Copy Address"/"Open Full QR" buttons are removed.
- **Platform snapshot export removed** (`swift/Platform.swift` deleted, with its
  envelope and per-model snapshot types).
- Tests: 1 new, 1 removed
  - Address resolution 1: an EVM mainnet wallet resolving no address.
  - Removed 1: the platform snapshot envelope export test, with the export.
- Total: 13 .swift files changed, +151 −498 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 43.

## Beta Commit 125

- **Chain Wiki becomes Crypto Wiki, covering coins as well as chains** (new
  `swift/views/CryptoWikiViews.swift`, `WikiCoinViews.swift`,
  `AssetPlacesCard.swift`; `ChainWikiViews.swift` cut down; Settings route
  `cryptoWiki`)
  - The library lists coins and chains with search ("Search coins and chains")
    and a filter; a coin page shows its prose and a "Lives On" card: each chain,
    token standard and contract, or native.
  - The held-asset detail on the dashboard uses the same places card (before:
    the wiki had the prose without contracts and the detail had contracts
    without prose).
  - The rotating coin moved to `WikiCoinViews.swift`; wiki lookups are cached
    per process (`CachedCoreHelpers` `wiki.*`).
- **Renaming a wallet after deleting it no longer brings it back**
  (`swift/AppState+CoreStateStore.swift`: the detached rename and
  portfolio-toggle write is `updateWalletIfPresent`, before `upsertWallet`).
- **The unread cache revision counter is removed** (`AppState.swift`:
  `cachesRevision`, `batchCacheUpdates`).
- **Coin colours come from the chain or token catalog only**
  (`RegistryModels.swift`; four hardcoded symbols MATIC, ARB, TRX, USDT
  removed).
- Tests: 1 new
  - Wallet store 1: a rename landing after a delete resurrecting the wallet.
- Total: 19 .swift files changed (3 new), +820 −629 lines; data and config
  files: `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 42 → 43.

## Beta Commit 124

- **A wallet imported while the launch load reads core is kept**
  (`swift/AppState+CoreStateStore.swift` `mergeAdoptedProjection`,
  `PersistenceStore.swift`): wallets and transactions adopted at launch merge
  core's snapshot with local writes made during the read (before: a wholesale
  replace dropped the import until the next launch).
- **Supplemental explorer endpoints come from the registry**
  (`WalletServiceBridge.swift`, `Chain.supplementalEndpointSlot`; before: a
  sixteen-name table, twelve of them with no supplement and Hyperliquid
  missing).
- **A dashboard asset row is one token on one network**
  (`swift/views/DashboardViews.swift`, `DashboardStore.swift`): the
  chain-breakdown list, "+N more" caption and "Networks" metric are removed;
  four strings removed in each locale.
- **Testnets are identified by the registry, not the `category` column**
  (`WalletSetupViews.swift` `SetupChainCategory(chain:)`, `DashboardStore.swift`
  pin options).
- Tests: 1 new
  - Launch adoption 1: a wallet written while the read was in flight being
    dropped or duplicated.
- Total: 10 .swift files changed, +130 −105 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions 41 → 42.

## Beta Commit 123

- **Prices come from several providers at once, and an unquoted holding is left
  out of the total** (`swift/AppState+PricingFiat.swift`,
  `Store+Formatting.swift`, `views/DashboardViews.swift`,
  `views/PricingSettingsView.swift`)
  - The pricing-provider and fiat-rate-provider pickers are removed; the Pricing
    intro says quotes come from whichever public provider answers.
  - The portfolio total covers quoted holdings and says "N without a price"
    (before: missing quotes fell back to built-in reference prices, and
    USDC/USDT were pinned at $1.00).
  - Four error strings replaced in each locale ("No price provider answered.",
    "No price provider had a quote for these assets.", "No fiat-rate provider
    answered. …").
- **Staking actions go through one build call** (`swift/StakingBridge.swift`,
  `views/StakingViewModel.swift`; before: 23 per-chain-per-action functions,
  repeated in the view model); staking endpoints are built for every chain the
  registry says can stake.
- **Diagnostics history runs share one path and write one row at a time**
  (`AppState+DiagnosticsEndpoints.swift`, `DiagnosticsStore.swift`; before: two
  wallets refreshing at once kept only the later map).
- **Transaction-status trackers are pruned by core** from its own table and each
  chain's poll shape (`StoreHistoryRefresh.swift`).
- **A known token is identified by its contract on its chain**
  (`RegistryModels.swift`, `views/TokenRegistrySettingsView.swift`,
  `TokenRegistryDetailView.swift`; before: a stored UUID regenerated on rebuild;
  `ChainTokenRegistryEntry` removed).
- **`scripts/unreachable-exports.sh` lists FFI exports no Swift or CLI code
  reaches**, exiting non-zero when any are found.
- Tests: 1 new
  - Portfolio total 1: an unquoted holding folded into the total at zero or an
    invented price.
- Total: 38 .swift files changed, +1806 −2269 lines; data and config files:
  `resources/strings/` (7), `scripts/` (1); dependencies unchanged; test
  functions 40 → 41.

## Beta Commit 122

- **Known-token balances are fetched for every token-hosting chain**
  (`swift/AppState+BalanceRefresh.swift`): Tron, Sui, Aptos, TON and NEAR join
  the EVM chains and Solana; contract addresses are normalised by core (before:
  `normalizeEVMAddress`, which would corrupt a case-significant TON jetton
  address).
- **Core decides how many decimals an amount shows**
  (`swift/Store+Formatting.swift`, core `assetAmountDisplay`); the Decimal
  Display settings screen is removed
  (`swift/views/DecimalDisplaySettingsView.swift` deleted).
- **"Tracked Tokens" is renamed "Known Tokens"** (`views/SettingsViews.swift`
  route `knownTokens`; strings in each locale).
- **A custom Dogecoin derivation path is honoured when resolving its address**
  (`AppState+AddressResolution.swift`; Bitcoin and Dogecoin share one
  network-aware resolver).
- **Diagnostics JSON decoding and record construction moved to core**
  (`AppState+DiagnosticsEndpoints.swift`: `diagnosticsHistorySummary`,
  `diagnosticsMakeEvm*`, `diagnosticsParseJsonrpcProbe`); private-key detection
  uses `corePrivateKeyHex`.
- Total: 44 .swift files changed, +553 −931 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 40.

## Beta Commit 121

- **A seed import derives its addresses in core on commit**
  (`swift/AppState+ReceiveFlow.swift`; before: Swift built a path table, added
  Ethereum's path whenever any EVM chain was selected, and called core once per
  chain).
- **A zero-amount send is allowed wherever core allows it**
  (`AppState+SendFlow.swift`; before: only ETH and BNB, so AVAX, HYPE, ETC, POL,
  MNT, S, BERA, CELO, CRO, SEI and OKB were refused after core permitted them).
- **Address-field hints are localized copy keyed by chain id** (`RuntimeStrings`
  `addressHint.<chain>.empty|invalid` for eleven chains); other chains fall back
  to a template built from the catalog's address-prefix example.
- **Core resolves transaction statuses and stale failures and writes the
  records** (`swift/AppState+OperationalTelemetry.swift`); the app keeps the
  localized operational event and the notification.
- **An address is judged against the network its chain is on** for every chain
  with a network choice, using the wallet's own network where it has one
  (`AppState+AddressResolution.swift`; a Dogecoin-only wallet-scoped variant
  removed).
- **Thirteen unused error formats removed from `CommonContent`** in each locale
  (`invalidAmountFormat`, `signingFailedFormat`, `broadcastFailedFormat` and
  others).
- Total: 33 .swift files changed, +517 −1119 lines; data and config files:
  `resources/strings/` (7); dependencies unchanged; test functions unchanged at
  40.

## Beta Commit 120

- **Per-chain lists in settings and send views come from the registry**
  (`swift/views/AddressBookView.swift`, `AdvancedSettingsView.swift`,
  `DecimalDisplaySettingsView.swift`, `SendFlowViews.swift`,
  `ChainWikiViews.swift`)
  - Address-book and advanced-settings chain lists and the decimal-display
    examples cover all mainnets (before: 21–22 hardcoded names).
  - Every EVM chain shows the send network card (before: 13 named EVM chains).
  - Wiki accent colour and token settings icon slug read from the registry
    (hardcoded switches removed).
- **History-narrating doc comments removed** across the Swift sources; no
  behaviour change.
- Total: 35 .swift files changed, +40 −344 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 40.

## Beta Commit 119

- **Every EVM chain can be pointed at a custom RPC, held by core**
  (`swift/AppState.swift`, `AppUserPreferences.swift`,
  `views/EndpointsViews.swift`; before: only Ethereum, via
  `ethereumRPCEndpoint`); the placeholder reads "Custom RPC URL" in each locale.
- **Resetting app settings goes through core** (`StoreLifecycleReset.swift`,
  `StateCommand::ResetAppSettings`); the app resets only the five settings it
  owns.
- **"Retry status" is offered by the registry's poll rule**
  (`swift/CoreModels.swift`; before: a five-name list, so a received Litecoin
  transaction could not be rechecked).
- **Address-slot mapping is one helper** (`CoreModels.swift`; two identical fold
  functions merged; the list variant concatenates EVM entries that share a
  slot).
- Total: 28 .swift files changed, +292 −258 lines; data and config files:
  `resources/strings/base/EndpointsContent.json`,
  `resources/strings/en/EndpointsContent.en.json`,
  `resources/strings/zh-Hans/EndpointsContent.zh-Hans.json`,
  `resources/strings/zh-Hant/EndpointsContent.zh-Hant.json`; dependencies
  unchanged; test functions unchanged at 40.

## Beta Commit 118

- **Endpoint probes follow the catalog's role for every chain**
  (`swift/AppState+DiagnosticsEndpoints.swift`): JSON-RPC for an `rpc` endpoint,
  GET otherwise (before: NEAR and Polkadot decided from hand-written endpoint-id
  lists in `ChainTypes`).
- **Fee priority is one per-chain preference held by core** (`AppState.swift`,
  `Store+Settings.swift`; before: Bitcoin and Dogecoin each had a settings field
  and enum, the rest a dictionary the app persisted).
- **Token contract normalisation is core's** (`StaticContentCatalog.swift`;
  before: a Swift copy that trimmed TON jetton addresses where core lowercased
  them).
- **Generic-shape send submission and post-broadcast recording are shared**
  (`AppState+SendExecution.swift` `recordSuccessfulBroadcast`,
  `Chain::uses_generic_send_submit`).
- **`StakingViewModel.swift` and `ViewExtensions.swift` moved into
  `swift/views/`**.
- Docs: `docs/FFI-BOUNDARY.md` traps (an exported `async fn` block needs
  `async_runtime = "tokio"`, without which `StakingService` was inert while the
  Rust and CLI suites passed; an export's callers may exist only in Swift);
  bindgen-duplication note removed.
- Total: 30 .swift files changed, +377 −604 lines; data and config files:
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 40.

## Beta Commit 117

- **All 24 stored address slots count as the wallet's own**
  (`swift/AppState+ReceiveFlow.swift`; before: seventeen, missing TON, Zcash,
  Bitcoin Gold, Decred, Kaspa, Dash and Bittensor).
- **"Has this address been used" is one question for all deep-UTXO chains,
  testnets included** (`AppState+AddressResolution.swift`): any balance, UTXO or
  history (before: Bitcoin checked UTXOs and balance only; Bitcoin Cash, Bitcoin
  SV, Litecoin and Dogecoin checked balance and history only).
- **Recipient-address hints are one table** (`AppState+SendFlow.swift`): every
  EVM chain gets the EVM hint (before: thirteen named); ten mainnets still use
  the generic hint.
- **Address resolution and EVM endpoint checks read the registry**
  (`AppState+AddressResolution.swift` descriptor reduced to three flags;
  `AppState+DiagnosticsEndpoints.swift` one EVM check builder).
- Total: 16 .swift files changed, +404 −499 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 40.

## Beta Commit 116

- **A Monero wallet can be imported from a seed**
  (`swift/AppState+ReceiveFlow.swift`): Monero is no longer skipped for having
  no derivation path (before: the import then demanded a typed address only the
  watch-only page could take). Only the watch-only form is refused, by
  `supports_watch_only_import`.
- **The staking tab's chains come from the registry** (`Chain.stakingChains`,
  `swift/views/StakingView.swift`; `StakingSupportedChain` enum removed): the
  picker offers mainnets only; per-chain copy stays in Swift.
- **Every EVM chain gets a format-specific recipient hint**
  (`AppState+SendFlow.swift`; before: thirteen names, the other ten got "Enter
  an address for the selected chain.").
- **Pending-status polling reads the registry** (`StoreHistoryRefresh.swift`,
  `Chain::pending_status_poll`); a received Litecoin transaction is rechecked.
- **Endpoint probes take one `publish` callback**
  (`AppState+DiagnosticsEndpoints.swift`); Dogecoin's probe uses the shared one.
- **Unused types removed**: `swift/Identifiers.swift` (typed id wrappers),
  `DashboardDetailRow`, `BundleTokenImage`, `ChainToggleLabel`,
  `SendPrimarySectionsView`; watch-only per-chain address guards in
  `ImportDraft.swift` (core validates).
- Tests: 4 new
  - Recipient hint 1: an EVM chain falling back to the generic hint.
  - Staking chains 3: a staking chain with no descriptor; a descriptor for a
    chain the tab does not offer; a testnet in the picker.
- Total: 29 .swift files changed (1 new), +582 −831 lines; data and config
  files: `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 36 → 40.

## Beta Commit 115

- **App settings and maintenance planning are held by core** (new
  `swift/Store+Settings.swift`, `MaintenanceStore.swift`,
  `AppUserPreferences.swift`)
  - Settings are sent as state commands and survive into a fresh `AppState`.
  - Core returns the maintenance plan with its cadence; an unreachable network
    stops the background tick.
- **A private-key import derives one address, through core**
  (`AppState+ReceiveFlow.swift`): the chain list is
  `coreSupportedPrivateKeyChainNames` (Decred added; twelve chains core cannot
  derive from a key dropped); an EVM key fills both the shared EVM slot and
  Ethereum Classic's.
- **Send preflight and routing are core's** (`AppState+SendFlow.swift`,
  `AppState+SendExecution.swift`)
  - Core reads the wallet, holding, balance and token list itself; the route is
    `preflight.submitKind`.
  - An untracked NEP-141 token routes nowhere and is not sent (before: Swift
    checked chain, standard and contract itself and sent it).
  - Core makes the EVM contract-code probes for recipient warnings and judges
    first-time destinations from its own store.
- **`scripts/bindgen-ios.sh` is the single owner of `swift/generated/`**; the
  Xcode phase calls it, and only the `vtablePtr` patch remains.
- Tests: 3 new, 5 removed
  - Settings 1: a setting not surviving into a fresh `AppState`.
  - Maintenance 2: the plan not reporting this device or returning no cadence; a
    background tick running with the network unreachable.
  - Removed 5: the Swift refresh-planner tests (maintenance plan, background
    run, chain and history plans), with the planner that moved to core.
- Total: 35 .swift files changed (1 new), +1126 −1205 lines; data and config
  files: `scripts/bindgen-ios.sh`, `swift/Spectra.xcodeproj/project.pbxproj`;
  dependencies unchanged; test functions 38 → 36.

## Beta Commit 114

- **The app has one chain type, generated from core's registry** (new
  `swift/Chain+Registry.swift`, `coreChainIdentities`)
  - It replaces `SpectraChainID`, `SeedDerivationChain`, `AppChainID` and
    `StandardDiagnosticsChain`; id, name, symbol and EVM membership are catalog
    columns.
- **Plain-shape native sends go through one dispatch**
  (`AppState+SendExecution.swift`, `Chain::send_execution_shape`; ten per-chain
  arms merged); Monero signs from stored key material, and a missing derivation
  path on other chains is refused rather than sent blank.
- **Send previews for the simple chains go through one function**
  (`AppState+SendPreview.swift`; eleven merged); Polkadot refuses a preview
  without a seed phrase.
- **Owned receive addresses are reported to core** (`AppState.swift`): before,
  the loop used diagnostics titles ("Bitcoin Diagnostics") as chain names and
  did nothing; it now skips EVM chains other than Ethereum and addresses core
  already has.
- **Diagnostics use shared EVM and UTXO descriptors and the hub's chain list
  from core** (`AppState+DiagnosticsEndpoints.swift`,
  `views/DiagnosticsViews.swift`); the UTXO deep rescan is one keyed function.
- Tests: 0 new, 3 removed
  - Removed 3: diagnostics-table checks over `StandardDiagnosticsChain` (view
    dispatch, registry ids, title resolution), with the enum; two remaining
    checks now test the hub's chain list.
- Total: 35 .swift files changed (1 new), +946 −1824 lines; data and config
  files: `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 41 → 38.

## Beta Commit 113

- **A network is a registry chain id** (`swift/ChainTypes.swift`,
  `AppState.swift`, `CoreModels.swift`)
  - `CoreBitcoinNetworkMode`, `CoreDogecoinNetworkMode` and the Swift Ethereum
    mode enum are replaced by one per-family selection (`selectNetworkChain`),
    held by core; a wallet carries `networkChainID`.
  - Network titles ("Bitcoin Testnet4") and the networks offered per family are
    registry lookups.
  - Import stores the mainnet-derived address; the displayed address is
    re-derived for the selected network.
- **Pending-status polling and refresh steps come from the registry**
  (`AppState+DiagnosticsEndpoints.swift`, `ChainRefreshDescriptors.swift`;
  eighteen per-chain pending wrappers and a 24-row table removed); Bitcoin and
  Dogecoin keep their own history fetch.
- **Dashboard asset rows are computed by core** (`swift/DashboardStore.swift`:
  grouping, ordering by value, pinned first).
- **Chains without a diagnostics descriptor use the shared history-count and
  catalog-probe path** (`AppState+DiagnosticsEndpoints.swift`).
- Tests: 2 new, 1 removed
  - Diagnostics tables 2: a descriptor naming a chain the enum dropped; a chain
    on the shared path whose name does not resolve in the registry.
  - Removed 1: one-descriptor-per-chain check, no longer the rule.
- Total: 24 .swift files changed, +419 −770 lines; data and config files: none;
  dependencies unchanged; test functions 40 → 41.

## Beta Commit 112

- **More domain state is held by core and mirrored in the app**
  (`swift/AppState.swift`, `PersistenceStore.swift`,
  `Store+Notifications.swift`, `WalletServiceBridge.swift`)
  - Owned addresses and the keypool baseline (`StoreLifecycleReset.swift`;
    reporting the keypool records nothing).
  - Chain operational events, capped and persisted by core.
  - Price alerts, with core-assigned string ids and core's rule that a target
    must be positive.
  - The selected network per family (`SelectNetworkChain`); which chains are
    testnets and unpriced.
- **Tests can wait for pending core writes** (`awaitPendingCoreStateWrites`); a
  failed write settles its epoch instead of waiting forever.
- Total: 19 .swift files changed, +356 −447 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 40.

## Beta Commit 111

- **Convention comments removed from `swift/AppState.swift` and
  `swift/Store+Formatting.swift`** (task capture, file naming, testability); the
  file points to AGENTS.md. No behaviour change.
- Total: 2 .swift files changed, +2 −73 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 40.

## Beta Commit 110

- **Comment in `swift/AppState+CoreStateStore.swift` corrected**: core is the
  canonical store for wallets, transactions and the address book; the arrays are
  projections. No behaviour change.
- Docs: `docs/FFI-BOUNDARY.md` rewritten as mechanics and traps for UniFFI 0.31
  and Swift 6 ("What crosses, and how", "Traps", "Regenerating bindings",
  "Common errors"; the two-pattern guide removed); `README.md` pointer wording
  for PLAN.md and ARCHITECTURE.md.
- Total: 1 .swift files changed, +101 −320 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 40.

## Beta Commit 109

- **Diagnostics state is keyed by chain** (`swift/DiagnosticsState.swift`,
  `DiagnosticsStore.swift`): self-tests, endpoint health and history run flags
  each one keyed table (before: three stored properties per chain); the two
  endpoint-row types are one.
- **Diagnostics JSON and history records come from core**
  (`StoreDiagnosticsExport.swift` `coreDiagnosticsJson`; ten history record
  types are one).
- **Derivation is one core call whatever the chain**
  (`swift/WalletRustDerivationBridge.swift`; the 212-line per-chain switch
  removed).
- Tests: 4 new
  - Diagnostics tables 4: a diagnostics chain without a run descriptor or view
    dispatch entry; the bundle list and chain enum disagreeing; a chain id not
    resolving in the registry.
- Total: 12 .swift files changed (1 new), +693 −1693 lines; data and config
  files: none; dependencies unchanged; test functions 36 → 40.

## Beta Commit 108

- **Watch-only addresses are validated and normalised by core, which keeps the
  valid ones** (`swift/AppState+ReceiveFlow.swift`, `ImportNetworks`)
  - Invalid entries are reported in `rejectedAddresses` (before: one bad line
    refused the whole import); an import with nothing left still fails.
  - The Swift 16-row validation table, Bitcoin address/xpub guard and EVM guard
    are removed.
- **Keychain seed storage fails loudly** (`swift/SecureStores.swift`)
  - Writes throw; a master key that cannot be read throws instead of reading as
    absent (which would have overwritten the key existing seeds are sealed
    under); a wrong-length key is reported as corruption.
  - A seed is never stored in plaintext when encryption fails; a read never
    creates a master key.
  - `hasPassword` answers yes on a read failure, so the password check before
    revealing a seed is not dropped.
- **EVM chain facts come from the registry** (`swift/SendPreviewTypes.swift`
  `EVMChainContext` is a struct from `coreEvmChainContext`): Sei, Celo, Cronos,
  opBNB, zkSync Era, Sonic, Berachain, Unichain, Ink and X Layer are EVM chains
  to the app (before: `isEVMChain` was false for them).
- **The unbuilt `swift/StakingView.swift` copy is deleted** (added in Beta
  Commit 94, never in the Xcode target).
- Tests: 4 new
  - Chain table 2: a bundled chain that does not resolve or collides with
    another; a bundled chain missing from the switch.
  - Seed store 2: a private key not round-tripping; a deleted seed still
    readable or not reported missing.
- Total: 13 .swift files changed, +566 −1688 lines; data and config files: none;
  dependencies unchanged; test functions 32 → 36.

## Beta Commit 107

- **Core owns wallets, transactions, the address book and app-level settings;
  the app keeps a projection** (`swift/AppState+CoreStateStore.swift`,
  `WalletServiceBridge.swift`, `PersistenceStore.swift`,
  `StorePersistenceNormalization.swift`)
  - Launch opens core's state (`openState`); changes are commands
    (`applyStateCommand`, `applyTransactionCommand`) and the projection updates
    first for responsiveness.
  - Fiat currency, pinned dashboard assets and token preferences are set through
    core, which normalises them.
  - Contacts are added through core, which rejects invalid and duplicate
    entries.
  - A balance-refresh result updates only wallets core still holds (before: a
    refresh landing after a delete re-created the wallet).
  - Swift wallet and address-book persistence and the persistence-delta
    computation are removed.
- **The confirmation-poll backoff schedule is core's**
  (`StorePersistenceNormalization.swift`); polling continues if core is
  unreachable.
- Tests: 5 new
  - Core-owned state 5: a currency change bypassing core or not normalised; the
    currency not surviving into a fresh `AppState`; a contact not persisting; an
    invalid or duplicate contact accepted; a transaction status change not
    persisted.
- Docs: `README.md` new "Architecture" section (one Rust core, the CLI and the
  apps as front ends; the app still owns state that belongs in core);
  `docs/FFI-BOUNDARY.md` regenerating bindings (the Xcode phase runs bindgen
  every build), "Rust keeps the domain state, Swift keeps view state", "Do not
  add a `core_plan_*`".
- Total: 29 .swift files changed, +1152 −946 lines; data and config files: none;
  dependencies unchanged; test functions 27 → 32.

## Beta Commit 106

- **A wallet stores its addresses in one map keyed by core's address slot**
  (`swift/CoreModels.swift` `addresses`, `address(forChainNamed:)`,
  `setAddress`; core `coreAddressSlot`)
  - Replaces 27 per-chain fields on the record; per-chain accessors read through
    the map, and every EVM chain shares Ethereum's slot.
  - A watch-only wallet with any stored address survives loading (before: only
    fourteen chains were checked, so one on Kaspa, Dash, Zcash, TON, ICP, Aptos,
    Bitcoin Cash, Bitcoin SV, Bitcoin Gold, Decred or Bittensor was dropped on
    load).
- **Only the selected chain's send preview crosses to core, tagged with its
  shape** (`swift/SendPreviewTypes.swift` `taggedPreview`): every EVM chain uses
  the Ethereum preview (before: Base, Polygon, Linea, Scroll, Blast, Mantle and
  newer rollups were not matched).
- **Import paths loop over the selected chains** (`AppState+ReceiveFlow.swift`):
  Ethereum's path is added when any EVM chain is selected, as answered by
  `coreIsEvmChain` (before: six named EVM chains).
- **The diagnostics bundle carries per-chain JSON as one chain-keyed map**
  (`StoreDiagnosticsExport.swift`).
- **The chain wiki shows an interactive rotating coin**
  (`swift/views/ChainWikiViews.swift`, `ChainWikiRotatingCoin`).
- Tests: 1 new
  - Wallet persistence 1: a watch-only wallet on a chain outside the old
    fourteen dropped on load.
- Docs: `docs/FFI-BOUNDARY.md` file paths (`swift/shell/`, `swift/rustbridge/` →
  `swift/`), the `SecretStore` trait shared by Keychain, in-memory and file
  backends, and the split-out service files.
- Total: 16 .swift files changed, +914 −789 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 26 → 27.

## Beta Commit 105

- **Settings is a system `Form` again** (`swift/views/SettingsViews.swift`;
  reverts the glass-card layout of Beta Commit 103), with the Tor row showing
  its status badge.
- **Transaction detail shows a timeline**
  (`swift/views/TransactionDetailView.swift`): created/recorded,
  broadcast/detected, awaiting hash, pending, confirmed or failed, with the
  current step marked.
- **Shared empty-state card and press feedback** (`swift/ViewExtensions.swift`
  `SpectraEmptyStateCard`, `spectraPressable`) used on the dashboard, history,
  address book, price alerts, receive, send and staking.
- Total: 12 .swift files changed, +379 −173 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 104

- **Send and Receive are step flows** (`swift/views/SendFlowViews.swift`,
  `SendPrimarySectionsView.swift`, `ReceiveFlowViews.swift`): send is From →
  Recipient → Amount → Network → Confirm → Result; receive is Wallet → Address.
- **History has a header with counts and filter capsules**
  (`swift/views/HistoryView.swift`: visible, pending and sends; wallet, type and
  sort).
- **The asset detail page has an Asset Hub card** (`views/DashboardViews.swift`:
  networks, contracts, symbol, pinned).
- **Shared loading indicators** (`swift/ViewExtensions.swift`
  `SpectraLoadingGlyph`, `SpectraLoadingRow`, `SpectraLoadingCard`) replace
  spinners in send, receive and staking.
- **Settings toggles bind to preferences and show the Tor status**
  (`views/SettingsViews.swift`).
- **A sent transaction stores core's opaque rebroadcast payload**
  (`AppState+SendExecution.swift`: `result.rebroadcastPayload`, before
  `result.resultJson`).
- Docs: `docs/FFI-BOUNDARY.md` (the `ffi/` crate is a re-export shim; JSON
  across the boundary is a migration format; new "Send-result payloads" and
  "Secret material" sections).
- Total: 14 .swift files changed, +1506 −217 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 103

- **Settings and Donations are glass cards instead of `Form`**
  (`swift/views/SettingsViews.swift`, `DonationsView.swift`); top-level cards
  elsewhere move to a 24-point radius.
- **`make ios` builds the app** (`Makefile`): `ios`/`iosr` run `xcodebuild` for
  a Debug/Release simulator build; the standalone Rust libraries and bindings
  move to `ios-artifacts`/`ios-artifacts-release`; `make` with no target prints
  help.
- **`scripts/build-ios.sh` builds the simulator libraries again**
  (aarch64-apple-ios-sim and x86_64-apple-ios, lipo-merged), reversing Beta
  Commit 82; `.gitignore` adds the Android binding and JNI paths.
- Docs: `docs/LiquidGlassUI.md` replaced by `docs/iosUI.md` (product decision to
  put content on glass, design baseline, corner radii, source map, patterns,
  don'ts).
- Total: 11 .swift files changed, +452 −505 lines; data and config files:
  `.gitignore`, `Makefile`, `scripts/build-ios.sh`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 102

- **A chain carries a list of derivation paths** (`swift/RegistryModels.swift`,
  `CachedCoreHelpers.swift`; core `ChainDerivationPathEntry`: tag, path with an
  `{account}` placeholder, default flag, note)
  - The wiki lists every path with a Default badge and its note, or "Not
    user-configurable in Spectra's current UI." (before: one default and one
    alternate path).
  - The default path is the entry marked default, with `{account}` set to 0.
- Total: 4 .swift files changed, +55 −26 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 101

- **Runtime strings are complete in every locale**
  (`resources/strings/RuntimeStrings.*.json`: 1334 keys each, from 1112 English
  and 1155 Chinese); hardcoded view text (chain info sheet, fee messages,
  Cardano TTL line) goes through `AppLocalization`.
- **The chain wiki drops the SLIP-44 row and the Technical Notes card**
  (`swift/views/ChainWikiViews.swift`); chains and tokens carry a `comment`
  shown under the wiki title and searched.
- Total: 8 .swift files changed, +721 −126 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 100

- **Dashboard and history use compact layout metrics**
  (`swift/views/ImageRendering.swift` `SpectraLayout`; the same edits land in
  the unbuilt `swift/StakingView.swift`): smaller padding, rows, icons and a
  24-point card radius; the portfolio total uses `.title` instead of
  `.largeTitle`.
- **Send previews are cleared in one call** (`swift/SendPreviewTypes.swift`
  `resetAll()`).
- **`.gitignore` ignores AI-assistant files** (AGENTS.md, CLAUDE.md, GEMINI.md
  and tool directories).
- Docs: `docs/FFI-BOUNDARY.md` (UniFFI 0.29 → 0.31; no central
  `core/src/ffi.rs`; string chain ids; typed send params in
  `service_send_params.rs`); `docs/LiquidGlassUI.md` radii and surfaces for
  compact tabs.
- Total: 9 .swift files changed, +140 −107 lines; data and config files:
  `.gitignore`; dependencies unchanged; test functions unchanged at 26.

## Beta Commit 99

- **Process-wide caches are lock-guarded** (`swift/StaticContentCatalog.swift`
  `LockedValue`): resource, localization and BIP-39 wordlist caches (before:
  `nonisolated(unsafe)` statics).
- **Memoisation of icon and chain lookups and derivation paths removed**
  (`RegistryModels.swift`, `CachedCoreHelpers.swift`); those lookups call core
  each time.
- Total: 5 .swift files changed, +64 −89 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 98

- **Every send passes the typed amount string to core alongside the number**
  (`swift/AppState+SendExecution.swift`: `amountStr` from the preflight).
- Total: 1 .swift files changed, +27 −25 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 97

- **After each balance cycle the app fetches token balances and prices**
  (`swift/WalletBalanceObserver.swift`, `AppState+BalanceRefresh.swift`)
  - ERC-20 balances for every EVM wallet and SPL balances for Solana wallets are
    merged into holdings (`refreshEVMTokenBalances`,
    `refreshSolanaTokenBalances`).
  - Live prices refresh right after (before: up to the next maintenance tick).
  - The refreshing flag is cleared on every cycle (before: an all-error cycle
    left it set and blocked later refreshes).
  - Refresh entries are set synchronously; `print` logging added on the refresh
    path.
- **Tor is off by default** (`swift/AppState.swift` `torEnabled`).
- **Receive lists every wallet as a card** with address, copy and a QR button
  opening a sheet with share and save (`swift/views/ReceiveFlowViews.swift`).
- **Send screen restyled into cards** (`views/SendFlowViews.swift`,
  `SendPrimarySectionsView.swift`; network, fee priority and preview content as
  card sections).
- **Dashboard: the Tor indicator opens Tor settings; "Customize Assets" becomes
  "Pin Assets" on a pushed page** (`views/DashboardViews.swift`).
- **Buy-crypto providers are localized** (`resources/BuyCryptoProviders.json`
  deleted; URLs in `AppLinks.json`, names and descriptions in `SettingsContent`
  per locale).
- Total: 10 .swift files changed, +1218 −704 lines; data and config files:
  `resources/strings/` (7), `resources/` (2); dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 96

- **Seed phrases can be entered in ten BIP-39 languages**
  (`swift/views/WalletSetupViews.swift` wordlist picker;
  `ImportDraft.seedPhraseLanguage`; `BIP39WordList.words(for:)` from core
  `bip39Wordlist(language:)`): word validation uses the chosen list.
  `resources/BIP39EnglishWordList.txt` deleted.
- **Funds Finder takes the seed in 12 or 24 word slots**
  (`swift/views/FundsFinderView.swift`): pasting a phrase fills the slots, more
  than twelve words opens all 24.
- **Seed and backup-verification word fields are smaller and monospaced**
  (`WalletSetupViews.swift`).
- Total: 4 .swift files changed, +140 −2089 lines; data and config files:
  `resources/BIP39EnglishWordList.txt`; dependencies unchanged; test functions
  unchanged at 26.

## Beta Commit 95

- **Funds Finder scans a seed's derivation paths for balances** (new
  `swift/AppState+FundsFinder.swift`, `swift/views/FundsFinderView.swift`; entry
  "Find Lost Funds" on Add Wallet)
  - Core generates the candidates from the seed and optional passphrase
    (`coreGenerateFundsFinderCandidates`); the app checks native balances four
    at a time with progress, and lists each path that holds funds with chain,
    path, balance and address.
  - A candidate whose balance request fails is skipped.
- **`StakingBridge.swift` and `StakingViewModel.swift` (added in Beta Commit 91)
  join the Xcode target; the seven Swift staking-client stubs leave it.**
- **Endpoint health rows use core's record types**
  (`AppState+DiagnosticsEndpoints.swift`, `DiagnosticsState.swift`,
  `DiagnosticsStore.swift`: `EndpointHealthRow`, `EvmEndpointHealthRow`).
- Total: 9 .swift files changed (2 new), +625 −125 lines; data and config files:
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 94

- **The diagnostics bundle is a core record**
  (`swift/StoreDiagnosticsExport.swift`; struct definitions and serialization in
  core `diagnostics/export.rs`); the app collects data and does file I/O.
- **New `swift/StakingView.swift` with per-action input sheets** (amount,
  validator, dissolve delay; builds the action preview for each of the seven
  chains) and ICP claim maturity (`StakingBridge`, `StakingViewModel`); the file
  is not in the Xcode target, and the built screen stays
  `swift/views/StakingView.swift`.
- **Logging on price and balance paths removed** (`AppState+PricingFiat.swift`,
  `AppState.swift`: `NSLog` lines, telemetry and perf loggers).
- **Token categories come from catalog tags** (`StaticContentCatalog.swift`,
  `DashboardStore.swift`; untagged tokens fall to custom).
- Total: 11 .swift files changed (1 new), +1136 −190 lines; data and config
  files: none; dependencies unchanged; test functions unchanged at 26.

## Beta Commit 93

- **Chain ids crossing to core are string slugs**
  (`swift/WalletServiceBridge.swift` `SpectraChainID`: `"bitcoin"`,
  `"bitcoin-cash"`, `"internet-computer"`, `"bnb"`; before: `UInt32` 0–29);
  every bridge, history, diagnostics, staking and send call takes a `String`
  chain id, and `listTokens(chainId: "")` lists all.
- `shortLabel` removed from `AppChainDescriptor`.
- Total: 13 .swift files changed, +97 −98 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 91

- **Staking chain pages load validators from core** (new
  `swift/StakingBridge.swift`, `swift/StakingViewModel.swift`;
  `swift/views/StakingView.swift`; core `StakingService`)
  - On open the page lists up to five validators with commission and APY, and
    shows errors in an alert; a preview sheet exists for built actions.
  - Action buttons reload validators (before: a "Coming soon" alert); positions
    are not yet loaded.
  - The seven per-chain Swift staking clients, which threw `NotYetImplemented`,
    are deleted; the two new files are not yet in the Xcode target.
- Docs: `swift/views/LiquidGlassUI.md` moved to `docs/LiquidGlassUI.md`;
  `swift/SUMMARY.md` (file-by-file map of `swift/`) deleted.
- Total: 11 .swift files changed (2 new), +546 −320 lines; data and config
  files: none; dependencies unchanged; test functions unchanged at 26.

## Beta Commit 90

- **Chain metadata comes from core's chain list** (`listAllChains`;
  `swift/RegistryModels.swift`, `views/ChainWikiViews.swift`,
  `views/WalletSetupViews.swift`, `DashboardStore.swift`)
  - `resources/ChainVisualRegistry.json` and the four `ChainWikiEntries` files
    (base, en, zh-Hans, zh-Hant) are deleted; wiki text is no longer per-locale.
  - The setup chain list (mainnets and testnets), dashboard pin options (each
    chain's native asset plus enabled stablecoins), token standards, contract
    prompts and chain-id resolution (`coreResolveChainId`) read core.
  - The default derivation path is core's; the per-chain path preset options are
    empty.
- **Derivation calls a per-chain core function**
  (`swift/WalletRustDerivationBridge.swift`: `deriveBitcoin`, `deriveEthereum`,
  …, and `derive…FromPrivateKey`; the Bitcoin script type is read from the
  path); the request-compilation presets are removed.
- **Wallet password and seed-phrase length are validated by core**
  (`swift/ImportDraft.swift`: `coreValidateWalletPassword`,
  `coreValidateSeedPhraseWordCount`); the private-key chain list is
  `coreSupportedPrivateKeyChainNames`.
- **The chain wiki detail is glass cards** (hero, identity, SLIP-44 and paths,
  circulation, technical notes).
- Docs: `resources/strings/LOCALIZATION_GUIDE.md` deleted.
- Total: 11 .swift files changed, +587 −5063 lines; data and config files:
  `resources/ChainVisualRegistry.json`,
  `resources/strings/base/ChainWikiEntries.json`,
  `resources/strings/en/ChainWikiEntries.en.json`,
  `resources/strings/zh-Hans/ChainWikiEntries.zh-Hans.json`,
  `resources/strings/zh-Hant/ChainWikiEntries.zh-Hant.json`; dependencies
  unchanged; test functions unchanged at 26.

## Beta Commit 89

- **The all-chains picker is a list with each chain's gas token**
  (`swift/views/AllChainsSelectionView.swift`; before: a three-column grid): an
  info sheet explains gas tokens and L2 native tokens; Arbitrum and Optimism
  (and their Sepolia testnets) show ETH.
- **Monero and Litecoin join the popular chains in setup**
  (`swift/views/WalletSetupViews.swift`); the staking chain picker is a list
  (`views/StakingView.swift`).
- **English and Chinese wiki entries cover all 46 chains**
  (`resources/strings/en|zh-Hans|zh-Hant/ChainWikiEntries.*.json`; from 30
  English and 24 Chinese).
- **App icon PNGs re-rendered** at higher density
  (`scripts/export-swift-icons.sh` renders at 1152 dpi and rebuilds when the SVG
  is newer; MD5 sentinels removed); Sei artwork edited.
- **Appearance preference is read at property initialisation**
  (`swift/AppUserPreferences.swift`).
- Total: 6 .swift files changed, +1909 −163 lines; data and config files:
  `swift/Assets.xcassets/` (5), `resources/strings/` (3), `scripts/` (1);
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 88

- **Appearance setting: Dark (default), Light or System** (new
  `swift/views/AppearanceSettingsView.swift`;
  `AppUserPreferences.appearanceMode` in UserDefaults; applied with
  `preferredColorScheme`).
- **Icons are synced into named asset groups by a script** (new
  `scripts/export-swift-icons.sh`): `resources/coinicon/` → `coinicon/`,
  `resources/fiaticon/` → `fiaticon/`, `resources/appicon/` SVG → 1024-pixel
  `AppIcon` PNG; the 78 coin imagesets move under `coinicon/`.
- **Confirmations before removing a price alert or a custom token**
  (`views/PriceAlertsView.swift`, `views/SettingsTokenComponents.swift`).
- **Interface polish** (`swift/ViewExtensions.swift`): haptics on taps and
  sends, shimmer placeholders while the receive address resolves,
  `ContentUnavailableView` for empty history, shared hint text and status
  colours; the wallet-setup step counter and custom back button are removed.
- Total: 19 .swift files changed (1 new), +563 −190 lines; data and config
  files: `swift/Assets.xcassets/` (162), `scripts/` (1); dependencies unchanged;
  test functions unchanged at 26.

## Beta Commit 87

- **The app builds in Swift 6 language mode**
  (`swift/Spectra.xcodeproj/project.pbxproj`: `SWIFT_VERSION` 5.0 → 6.0; default
  MainActor isolation and approachable concurrency removed; previews disabled);
  Sendable and isolation annotations added across 17 files.
- **The Xcode Rust build phase follows the build configuration** (Release builds
  the core with `--release`) and patches only `vtablePtr` to
  `nonisolated(unsafe)`; `scripts/bindgen-ios.sh` applies the same patch.
- Total: 17 .swift files changed, +40 −43 lines; data and config files:
  `scripts/bindgen-ios.sh`, `swift/Spectra.xcodeproj/project.pbxproj`;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 86

- **Token-preference saves are debounced** (`swift/AppState.swift`: 50 ms,
  skipped when unchanged).
- **History persistence writes only new records**
  (`swift/StorePersistenceNormalization.swift` `persistTransactionsDelta`;
  before: every record on each change, so a status change to an existing record
  is no longer re-written).
- **The app creates `AppState` once and passes it to `ContentView`**
  (`swift/ViewExtensions.swift`).
- **Seed-phrase word fields use an ASCII keyboard**
  (`views/WalletSetupViews.swift`).
- Total: 7 .swift files changed, +17 −13 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 85

- **Concurrency annotations reworked** (`nonisolated` moved off model extensions
  and onto Codable members and `DebouncedAction`) across 12 files; no behaviour
  change.
- Total: 12 .swift files changed, +136 −135 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 84

- **The bridge to core is a MainActor class**
  (`swift/WalletServiceBridge.swift`; before: an `actor`); many bridge calls
  become synchronous.
- **Core callbacks are protocols the app implements**
  (`swift/SecureStores.swift` `SpectraSecretStoreAdapter: SecretStore`,
  `WalletBalanceObserver: BalanceObserver`; before: subclasses of generated
  `…Impl` classes).
- **The Xcode build phase no longer rewrites the generated bindings** (the
  UniFFI 0.29 Swift 6 sed patch is removed).
- **App icon is PNG again** (`swift/Assets.xcassets/AppIcon.appiconset`, light
  and dark).
- Total: 10 .swift files changed, +80 −102 lines; data and config files:
  `swift/Assets.xcassets/AppIcon.appiconset/Contents.json`,
  `swift/Assets.xcassets/AppIcon.appiconset/SpectraLogo-Dark.png`,
  `swift/Assets.xcassets/AppIcon.appiconset/SpectraLogo-Dark.svg`,
  `swift/Assets.xcassets/AppIcon.appiconset/SpectraLogo-Light.png`,
  `swift/Assets.xcassets/AppIcon.appiconset/SpectraLogo-Light.svg`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 83

- **Coin and chain icons ship as SVG imagesets in the asset catalog**
  (`swift/Assets.xcassets`, 78 imagesets) and load with `UIImage(named:)`
  (`swift/views/ImageRendering.swift`)
  - The WKWebView SVG renderer, `BundleImageLoader`, its memory and disk caches
    and cache warm-up are removed.
- **App icon moves to `swift/Assets.xcassets/AppIcon.appiconset`** as light and
  dark SVGs; a `fiat` group is added.
- Total: 4 .swift files changed, +2031 −527 lines; data and config files:
  `swift/Assets.xcassets/` (161), `resources/appicon/` (5),
  `swift/Spectra.xcodeproj/` (1); dependencies unchanged; test functions
  unchanged at 26.

## Beta Commit 82

- **Rust iOS builds target iOS 16.0** (new `.cargo/config.toml`:
  `IPHONEOS_DEPLOYMENT_TARGET` and matching link args, so C build scripts stop
  emitting `___chkstk_darwin` against the Xcode 26 SDK).
- **`scripts/build-ios.sh` builds the device target only** (simulator targets
  commented out); `make iosr` and `make androidr` build release.
- **Staking actions include Change Validator** (`swift/StakingTypes.swift`).
- **EVM send overrides carry the new optional fields** (`gasLimit`,
  `calldataHex`, `signOnly`, `accessListJson`, all nil from the app).
- **Refresh entries are handed to core on a background queue; the image loader
  is given the screen scale at launch** (`WalletServiceBridge.swift`,
  `AppState.swift`); Sendable conformances and swift-collections imports
  (`DequeModule`, `OrderedCollections`) adjusted.
- Total: 18 .swift files changed, +246 −153 lines; data and config files:
  `.cargo/config.toml`, `Makefile`, `scripts/build-ios.sh`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 81

- **Tor routing with a built-in Arti client or a custom SOCKS5 proxy** (new
  `swift/AppState+TorLifecycle.swift`, `swift/views/TorSettingsView.swift`; core
  `torStart`, `torStop`, `torStatus`, `torActivateCustomProxy`)
  - Settings → Tor: on/off, reconnect, custom proxy address (default
    `socks5://127.0.0.1:9150`), status with bootstrap percent, and a Kill Switch
    toggle that is stored but read by nothing yet.
  - On by default; the choices persist in UserDefaults, Tor starts at launch
    when enabled, and status is polled every second.
  - A dashboard toolbar indicator shows off, connecting with percent, on or
    error.
- **Litecoin MWEB sends are recognised**
  (`swift/views/SendPrimarySectionsView.swift`, `AppState+SendPreview.swift`):
  an `ltcmweb1`/`tmweb1` recipient shows an "MWEB · Privacy Send" badge and the
  fee preview adds 1017 vbytes.
- **Diagnostics runners are table-driven**
  (`AppState+DiagnosticsEndpoints.swift`, `views/DiagnosticsViews.swift`); UTXO
  rescan state and pending preview refreshes are keyed by chain; send previews
  are read from `sendPreviewStore` directly.
- The dashboard asset stats card drops its "Chains" row.
- Total: 12 .swift files changed (2 new), +1057 −700 lines; data and config
  files: none; dependencies unchanged; test functions unchanged at 26.

## Beta Commit 80

- **Send and preview busy state is two sets of chain names**
  (`swift/AppState.swift` `sendingChains`, `preparingChains`; 32 per-chain flags
  removed).
- **Per-chain repetition collapsed into tables**
  (`AppState+AddressResolution.swift`, `ChainRefreshDescriptors.swift`,
  `PersistenceStore.swift`, `views/DiagnosticsViews.swift`, `ImportDraft.swift`,
  `RegistryModels.swift`, `CachedCoreHelpers.swift`); post-send refresh picks
  the pending or history poll from the descriptor table.
- **Icon rendering fixes** (`swift/views/ImageRendering.swift`)
  - Screen scale from `UIScreen.main.scale` (before:
    `UITraitCollection.current.displayScale`, which reads 0 outside layout and
    produced NaN snapshot widths).
  - Launch warm-up only loads disk-cached bitmaps; rendering happens when a
    badge appears, at user-initiated priority; a render with no window returns
    nil instead of a blank image. Disk cache version r5.
- **Wiki ids match the chain registry**
  (`resources/strings/base/ChainWikiEntries.json`: `bitcoin-gold`, `zksync-era`,
  `x-layer`).
- Total: 20 .swift files changed, +980 −1617 lines; data and config files:
  `resources/strings/base/ChainWikiEntries.json`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies: added
  swift-collections 1.4.1 (`OrderedCollections`, Swift package in
  `swift/Spectra.xcodeproj/project.pbxproj`); test functions unchanged at 26.

## Beta Commit 79

- **Balance refresh starts as soon as wallets are known**
  (`swift/AppState+BalanceRefresh.swift`, `AppState.swift`): setting refresh
  entries triggers an immediate refresh, and launch refreshes balances again
  after the SQLite reload; the price-refresh interval has a 60-second floor.
- **Every chain's refresh address comes from the generic resolver**
  (`resolvedAddress(for:chainName:)`; before: a 21-chain switch, others returned
  nil).
- **Holdings from a balance summary are merged in Swift**
  (`holdingsAppliedFromSummary`, keyed by chain and contract or symbol; new
  zero-amount holdings are not added), replacing
  `corePlanApplyHoldingsFromSummary`.
- **The app no longer pushes wallet summaries to core**
  (`initWalletStateDirect`, `upsertWalletDirect` and
  `ImportedWallet.walletSummary` removed); after an import a full
  `refreshBalances()` runs instead of per-chain imported-wallet descriptors.
- **Chain visuals for Kaspa, Bittensor, Sonic, Berachain, X Layer and zkSync
  Era** (`resources/ChainVisualRegistry.json`).
- Total: 9 .swift files changed, +80 −124 lines; data and config files:
  `resources/ChainVisualRegistry.json`; dependencies unchanged; test functions
  unchanged at 26.

## Beta Commit 78

- **App metadata and icon** (new `swift/Info.plist`; `resources/appicon/`)
  - `Info.plist`: en, zh-Hans and zh-Hant localizations, camera, Face ID and
    photo-library usage descriptions, Live Activities, portrait-only iPhone.
  - The app icon moves to `resources/appicon/AppIcon.xcassets` with new light
    and dark artwork and SVG sources, plus a tinted variant; the two-string
    `Localizable.strings` files are deleted.
- **Chain icons are looked up from the visual registry by raw asset identifier**
  (`swift/views/ImageRendering.swift`, `RegistryModels.swift`; registry entries
  gain `symbol` and `chainName`)
  - A token like "ETH on zkSync Era" no longer shows Ethereum's icon; chains
    with an icon but no wiki entry (Dash, Decred, Sei) get theirs; a native
    asset missing from the registry shows no icon.
- **SVG rendering on device** (`ImageRendering.swift`): the SVG is inlined into
  the HTML (file `<img>` was blocked by the WebContent sandbox), the web view is
  attached to a window for snapshots, rendered icons go to a versioned disk
  cache, the memory cache grows to 300 items / 64 MB, and the cache is warmed at
  launch.
- Three import-flow strings added ("Choose Chains", "Name Your Wallet").
- Total: 4 .swift files changed, +369 −130 lines; data and config files:
  `resources/appicon/` (6), `swift/resources/` (5), `resources/` (1),
  `resources/strings/` (1), `swift/` (1), `swift/Spectra.xcodeproj/` (1);
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 77

- **Chain visuals for Bitcoin Gold, Dash, Decred, Zcash, Sei, Ink and Celo**
  (`resources/ChainVisualRegistry.json`); Avalanche and Internet Computer
  artwork names become `avalanche` and `internetcomputer`.
- **Fiat SVG icons load from `icons/fiat/`** under `fiat/<name>` keys
  (`swift/views/ImageRendering.swift`); `FiatCurrency.iconName` names them for
  USD, EUR, GBP and CNY.
- The last seven PNG icons are removed from `resources/icons/`.
- Total: 2 .swift files changed, +52 −3 lines; data and config files:
  `resources/icons/` (7), `resources/` (1); dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 76

- **Tracked tokens are looked up through one helper for every EVM chain**
  (`swift/AppState.swift` `enabledEVMTrackedTokens(for:)`,
  `TokenTrackingChain.forChainName`; twelve per-chain helpers removed)
  - Sending a tracked Arbitrum token is recognised (before: Arbitrum's token
    list was empty in `supportedEVMToken`), and Avalanche history fetches
    include tracked tokens.
- **Load-more history loops over the UTXO and EVM chain lists**
  (`swift/StoreHistoryRefresh.swift`); behaviour unchanged.
- **24 PNG token icons removed from `resources/icons/`; `.swift-format`
  deleted.**
- Total: 4 .swift files changed, +27 −162 lines; data and config files:
  `resources/icons/` (24), `.swift-format`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 75

- **Swift-layer map rewritten for the flat `swift/` layout; the two derivation
  notes deleted** (`swift/SUMMARY.md`; `swift/DerivationChecklist.md`,
  `swift/DerivationTestingFormat.md`)
- Docs: `swift/SUMMARY.md` top-level layout and file sections (the former
  `shell/`, `send/`, `fetch/`, `derivation/`, `rustbridge/` sections merged into
  one list for the root); `swift/DerivationChecklist.md` and
  `swift/DerivationTestingFormat.md` deleted.
- Total: no .swift files changed, +117 −366 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 74

- **UniFFI bindings are no longer committed** (`.gitignore` ignores
  `swift/generated/`; `spectra_core.swift`, `spectra_coreFFI.h`,
  `module.modulemap` and `spectra_coreFFI.modulemap` deleted from the tree)
- **Dogecoin-only transaction fields folded into the shared ones**
  (`TransactionRecord` in `swift/CoreModels.swift`;
  `AppState+SendExecution.swift`, `AppState+OperationalTelemetry.swift`,
  `AppState+DiagnosticsEndpoints.swift`)
  - `dogecoinConfirmations`, `dogecoinFeePriorityRaw`,
    `dogecoinUsedChangeOutput` and `dogecoinRawTransactionHex` are gone;
    Dogecoin sends fill `confirmationCount`, `feePriorityRaw`,
    `usedChangeOutput` and `signedTransactionPayload`.
  - Dogecoin rebroadcast reads the raw transaction from
    `signedTransactionPayload` (`AppState+SendFlow.swift`).
- **Advanced-mode override names are resolved in core**
  (`swift/WalletRustDerivationBridge.swift`): curve, derivation algorithm,
  address algorithm, public-key format and script-type names pass through as
  `*OverrideName` request fields (before: Swift tables turned them into wire
  values).
- **Unused code deleted**: `LiveActivityManager.swift`
  (`SendTransactionLiveActivityManager`, no callers), `ActionResult.swift` (no
  callers), `ManagedTaskRegistry.swift` with `AppState.backgroundTasks`, and
  four unused wallet/transaction mutation helpers in
  `AppState+CoreStateStore.swift`.
- Total: 13 .swift files changed, +49 −46449 lines; data and config files:
  `.gitignore`, `swift/Spectra.xcodeproj/project.pbxproj`,
  `swift/generated/module.modulemap`, `swift/generated/spectra_coreFFI.h`,
  `swift/generated/spectra_coreFFI.modulemap`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 73

- **Swift sources flattened into `swift/`** (everything from `shell/`, `send/`,
  `fetch/`, `derivation/`, `rustbridge/` and `staking/` moved to the root;
  `views/` keeps the SwiftUI screens; Xcode project updated); behaviour
  unchanged.
  - Merged: `derivation/Presets.swift` and `WalletDerivationLayer.swift` into
    `WalletDerivation.swift`; `fetch/ChainBackendModels.swift` into
    `RegistryModels.swift`; `send/SendPreviewStore.swift` into
    `SendPreviewTypes.swift`; `BundleImageLoader.swift`, `IconUIHelpers.swift`
    and `SVGRenderer.swift` into `views/ImageRendering.swift`.
  - Renamed: `views/ContentView.swift` to `ViewExtensions.swift`,
    `shell/AppState+RustObserver.swift` to `WalletBalanceObserver.swift`;
    `ActionResult.swift`, `ImportDraft.swift`, `SetupFlow.swift` and
    `LiveActivityManager.swift` left `views/` for the root.
- Docs: `DerivationChecklist.md` and `DerivationTestingFormat.md` moved from
  `swift/derivation/` to `swift/`.
- Total: 65 .swift files changed, +642 −845 lines; data and config files:
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 72

- **PNG icons for DAI, KCS and LINK removed from `resources/icons/`** (their SVG
  versions were added under `resources/icons/` in the same commit, which this
  repository's filtered history does not carry)
- Total: no .swift files changed, +0 −0 lines; data and config files:
  `resources/icons/dai.png`, `resources/icons/kcs.png`,
  `resources/icons/link.png`; dependencies unchanged; test functions unchanged
  at 26.

## Beta Commit 71

- **Testnets are first-class chains picked from the chain list**
  (`SeedDerivationChain` in `swift/shell/CoreModels.swift`; "Testnets" category
  in `swift/views/WalletSetupViews.swift`)
  - 32 testnet chains: Bitcoin Testnet, Testnet4 and Signet; Litecoin, Bitcoin
    Cash, Bitcoin SV, Dogecoin, Zcash, Decred, Kaspa and Dash testnets; Ethereum
    Sepolia and Hoodi; Arbitrum, Optimism and Base Sepolia; BNB Chain Testnet;
    Avalanche Fuji; Polygon Amoy; Hyperliquid Testnet; Ethereum Classic Mordor;
    Tron Nile; Solana Devnet; XRP Ledger, Stellar, Sui, Aptos, TON and NEAR
    testnets; Cardano Preprod; Polkadot Westend; Monero Stagenet.
  - The separate derivation network argument (`WalletDerivationNetwork`,
    `networkPresets`) is removed: the chain identity carries mainnet or testnet;
    Bitcoin and Dogecoin address resolution pick the testnet chain from the
    wallet's network mode.
  - Advanced setup no longer has Bitcoin, Ethereum and Dogecoin network
    sections.
  - A testnet chain stores its derivation path in its mainnet counterpart's
    slot.
- **Icon rendering takes the display scale from `UITraitCollection.current`**
  (before: `UIScreen.main`) (`BundleImageLoader.swift`, `SVGRenderer.swift`)
- **PNG icons for BGB, BSV, BNB, BTT, Cardano, Monero, PYUSD, Solana, Stellar
  and XRP removed from `resources/icons/`** (SVG versions added in the core
  repository's history in the same commit)
- Total: 15 .swift files changed, +1392 −1423 lines; data and config files:
  `resources/icons/` (10), `swift/Spectra.xcodeproj/` (1); dependencies
  unchanged; test functions unchanged at 26.

## Beta Commit 70

- **16 chains added to wallet setup and import** (descriptors in
  `swift/views/WalletSetupViews.swift`; `SeedDerivationChain` in
  `swift/shell/CoreModels.swift`; `AppState+AddressResolution.swift`,
  `AppState+ReceiveFlow.swift`, `swift/views/ImportDraft.swift`)
  - Bitcoin family: Bitcoin Gold, Decred, Dash; EVM L1: Sei, Celo, Cronos,
    Sonic, Berachain; EVM L2: opBNB, zkSync Era, Unichain, Ink, X Layer; other:
    Zcash, Kaspa, Bittensor.
  - Each has address resolution, receive-address lookup, import selection, a
    stored derivation-path slot and an entry in
    `resources/strings/base/ChainWikiEntries.json` (not in the `en` or Chinese
    files).
- **Setup pages defined once as an ordered list** (new
  `swift/views/SetupFlow.swift`): step count, next and back come from the list;
  the advanced page is a side route outside the count.
- **All-chains picker with search, grouped by category** (new
  `swift/views/AllChainsSelectionView.swift`, split out of
  `WalletSetupViews.swift`)
- **Rendered SVG icons cached on disk** (`swift/views/BundleImageLoader.swift`):
  `Caches/SpectraIconCache/<name>@<size>x<scale>.png`, so later launches skip
  WebKit.
- **Wallet-derived caches assigned as one value** (new
  `swift/shell/WalletDerivedCache.swift`); new helpers `DebouncedAction`,
  `LoadingTaskRegistry`, `ManagedTaskRegistry`; `ActionResult` and typed
  identifiers (`Identifiers.swift`) added without callers.
- **PNG icons for BONK and PEPE removed from `resources/icons/`**
- Docs: `docs/FFI-BOUNDARY.md` added: the typed and chain-dispatched FFI
  patterns, what can and cannot cross UniFFI 0.29, binding regeneration,
  boundary-breaking changes, JSON conventions, state on Rust versus Swift,
  common errors.
- Total: 27 .swift files changed (8 new), +4031 −1773 lines; data and config
  files: `resources/icons/bonk.png`, `resources/icons/pepe.png`,
  `resources/strings/base/ChainWikiEntries.json`,
  `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test functions
  unchanged at 26.

## Beta Commit 69

- **Price alerts, the address book and history records persist as typed core
  records** (`swift/rustbridge/WalletServiceBridge.swift` `loadPriceAlertStore`,
  `savePriceAlertStore`, `loadAddressBookStore`, `saveAddressBookStore`,
  `upsertHistoryRecords([HistoryRecord])`;
  `swift/shell/PersistenceStore.swift`): core's JSON encode/decode exports for
  these stores are gone.
- **EVM send overrides and results cross as typed records**
  (`swift/send/AppState+SendExecution.swift`): nonce and custom fees go as
  `EvmSendOverridesInput` (before: a JSON fragment from
  `buildEvmOverridesJsonFragment`); the result is read from `result.evm`
  (before: decoded from `resultJson`).
- **Asset, contract and wallet detail screens restyled**
  (`AssetGroupDetailView`, `AssetContractsDetailView` in
  `swift/views/DashboardViews.swift`; `WalletDetailView` in
  `swift/views/WalletFlowViews.swift`): backdrop, hero and stats cards, stat
  rows led by an orange SF Symbol.
- **Concurrent requests for one SVG icon share a single render; the warm-up runs
  once** (`swift/views/BundleImageLoader.swift`)
- **PNG icons for AAVE, Aptos, AVAX, Bitcoin, Bitcoin Cash, Dogecoin, Ethereum,
  Ethereum Classic, Litecoin and Optimism removed from `resources/icons/`** (SVG
  versions added in the core repository's history in the same commit)
- Docs: `swift/views/LiquidGlassUI.md` design baseline (backdrop on detail
  destinations, hero/content opacity bands, stat-row pattern, orange and red
  button tints) and corner-radius inventory.
- Total: 10 .swift files changed, +1058 −897 lines; data and config files:
  `resources/icons/` (10), `swift/Spectra.xcodeproj/` (1), `swift/generated/`
  (1); dependencies unchanged; test functions unchanged at 26.

## Beta Commit 68

- **Staking tab lists the chains with protocol staking and opens a screen per
  chain** (`chainPickerCard`, `ChainStakingDetailView` in
  `swift/views/StakingView.swift`)
  - Chains: Solana, Cardano, Sui, Aptos, NEAR, Polkadot, Internet Computer.
  - Stake, unstake, withdraw, restake and claim-rewards actions show a "Coming
    soon" alert (before: the tab was a "Staking (Coming Soon)" page).
- **Staking client stubs per chain** (new `swift/staking/`): every method throws
  `StakingError.NotYetImplemented`; the shared types (`StakingActionKind`,
  `StakingPosition`, `StakingValidator`, `StakingActionPreview`) come from
  core's bindings, with Swift display names.
- **Badges resolve SVG icons on demand** (`resolveImage(named:targetSize:)` in
  `swift/views/BundleImageLoader.swift`): memory cache, then the bundle SVG
  rendered and cached, then the PNG (before: an SVG-only icon showed the letter
  fallback until the launch warm-up had rendered it).
- Total: 12 .swift files changed (8 new), +1379 −38 lines; data and config
  files: `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 67

- **Six EVM chains added: Polygon, Base, Linea, Scroll, Blast, Mantle**
  (`EVMChainContext` in `swift/send/SendPreviewTypes.swift`;
  `swift/shell/CoreModels.swift`, `ChainRefreshDescriptors.swift`,
  `StoreHistoryRefresh.swift`; `resources/ChainVisualRegistry.json`;
  `ChainWikiEntries`)
  - EVM chain IDs 137, 8453, 59144, 534352, 81457 and 5000, derivation path
    `m/44'/60'/0'/0/0`.
  - Balance and history refresh, "load more" history, tracked tokens, wiki
    entries (base and `en` files) and chain visuals for each.
  - Stored seed derivation paths gain the six keys; a wallet stored without them
    loads with each chain's default path.
- **Wallet setup chain picker grouped into Bitcoin family, EVM L1, EVM L2 and
  Other** (`SetupChainCategory` in `swift/views/WalletSetupViews.swift`)
- **Bundle icons can be SVG** (new `swift/views/SVGRenderer.swift`;
  `BundleImageLoader.swift`): an SVG is rendered once through a WebKit snapshot
  into a cached `UIImage`; bundle SVGs are pre-rendered at launch.
- **Fiat-rate refresh waits 60 s after a failed attempt**
  (`fiatRatesRetryBackoff` in `swift/shell/AppState+PricingFiat.swift`; before:
  a failure was retried on every maintenance tick, since only success stamped
  the time); the fiat-rate `NSLog` lines removed.
- `.vscode/settings.json` deleted.
- Total: 24 .swift files changed (1 new), +1224 −258 lines; data and config
  files: `.vscode/settings.json`, `resources/ChainVisualRegistry.json`,
  `resources/strings/base/ChainWikiEntries.json`,
  `resources/strings/en/ChainWikiEntries.en.json`; dependencies unchanged; test
  functions unchanged at 26.

## Beta Commit 66

- **`marketDataId` removed from coins, tokens and stored wallets** (`Coin` in
  `swift/shell/CoreModels.swift`; `RegistryModels.swift`,
  `PersistenceStore.swift`, `DashboardStore.swift`,
  `swift/views/ImportDraft.swift`); the token detail no longer shows "Market
  Data ID".
- `.vscode/settings.json` added (SVG preview background).
- Total: 15 .swift files changed, +99 −173 lines; data and config files:
  `.vscode/settings.json`; dependencies unchanged; test functions unchanged at
  26.

## Beta Commit 65

- **`CoinBadge` maps its asset identifier through a closure instead of a method
  reference** (`swift/views/IconUIHelpers.swift`); behaviour unchanged.
- Total: 1 .swift files changed, +1 −1 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 26.

## Beta Commit 64

- **CoinGecko API key setting removed**
  (`swift/views/PricingSettingsView.swift`, `swift/shell/AppState.swift`,
  `StoreLifecycleReset.swift`): prices are fetched without a key
  (`fetchPricesTyped(provider:coins:)`); the `coingecko.api.key` keychain entry
  is no longer read, written or cleared.
- **Binance and Coinbase Exchange removed as pricing providers**
  (`PricingProvider` in `swift/shell/AppState+PricingFiat.swift`)
- **The Etherscan API key is handed to core when set** (`setEtherscanAPIKey` in
  `swift/rustbridge/WalletServiceBridge.swift`)
- **Fiat-rate refresh skips when one is already running**
  (`isRefreshingFiatRates`); `NSLog` lines added around price and fiat-rate
  refresh.
- **Chain wiki becomes a searchable list; asset detail becomes a form**
  (`swift/views/ChainWikiViews.swift`, `DashboardViews.swift`); decimal-display
  and token-registry settings use the system search field; the address-book
  intro text removed.
- Tests: 0 new, 14 removed (`swift/tests/ChainSupportTests.swift` deleted): wiki
  entry for every registered chain, NEAR history parsing, Tron, Bitcoin Cash and
  XRP preset flavours, Bitcoin Testnet4 and Solana derivation outputs, preset
  listings.
- Total: 18 .swift files changed, +370 −626 lines; data and config files:
  `resources/strings/base/SettingsContent.json`,
  `resources/strings/en/SettingsContent.en.json`,
  `resources/strings/zh-Hans/SettingsContent.zh-Hans.json`,
  `resources/strings/zh-Hant/SettingsContent.zh-Hant.json`,
  `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test functions 40
  → 26.

## Beta Commit 63

- **Donate moves from the tab bar into Settings**
  (`swift/views/MainTabView.swift`, `SettingsViews.swift`; `MainAppTab.donate`
  removed)
- **Fee Priorities and Icon Styles settings removed**
  (`ChainFeePrioritySettingsView.swift`, `TokenIconSettingsView.swift` and the
  icon components in `SettingsTokenComponents.swift` deleted)
  - A coin badge shows the bundled artwork or a circle with the symbol's first
    letter; custom photos and per-token icon styles are gone, and `Coin.mark` is
    removed.
- **Token visuals come from core's built-in token list**
  (`TokenVisualRegistryCatalog.loadEntries` reads `listBuiltinTokens`; before:
  `TokenVisualRegistry.json`).
- **Static resources added to the app** (`resources/ChainVisualRegistry.json`,
  `BuyCryptoProviders.json`, `BIP39EnglishWordList.txt`, removed from
  `core/embedded/` in the same commit); the chain visuals and buy-crypto
  providers are read from the bundle.
  - New `resources/AppLinks.json` holds the report-a-problem URL
    `https://spectrawallet.org/bug/` (before: an example.com placeholder in
    `SettingsContent.json`).
- **Liquid Glass restyle** across Dashboard, History, Donations, Chain Wiki,
  wallet setup and wallet screens (system text styles, semantic colours, glass
  cards over `SpectraBackdrop`).
- **Wallet setup shows "Step N of M"; finishing an import returns to the
  dashboard** (`WalletSetupViews.swift`; `AppState+ReceiveFlow.swift` also pops
  the Add Wallet page)
- **Lock screen strings filled in** (`content.locked.*` in
  `RuntimeStrings.en.json` were their own keys).
- Docs: `swift/views/LiquidGlassUI.md` added: Apple's design principles and
  where Spectra departs, design baseline, corner-radius inventory.
- Total: 31 .swift files changed, +2786 −814 lines; data and config files:
  `resources/strings/` (7), `resources/` (4); dependencies unchanged; test
  functions unchanged at 40.

## Beta Commit 62

- **Background work stops when there are no wallets** (maintenance loop in
  `swift/shell/AppState+SendFlow.swift`; `StorePersistenceNormalization.swift`)
  - The maintenance loop does not start without wallets and exits when the last
    wallet is removed; adding a wallet starts it and the balance refresh engine.
  - Removing the last wallet stops the balance refresh engine.
- **The maintenance loop polls every 30 s only while pending transactions need
  watching**; otherwise it sleeps one price-refresh interval (before: every 30
  s).
- **Balance updates batch per `AppState` instance** (`pendingBalanceUpdates`,
  `balanceFlushTask`; before: static); the balance observer no longer re-runs
  wallet side effects that the batch flush already triggers.
- **Visual pass** (most views): `.secondary` text instead of opacity ramps,
  system text styles, `SpectraBackdrop` behind Dashboard, History, Staking and
  Donations; dashboard wallets are rows (before: a paged carousel); the About
  hero animation stops when the view disappears.
- Total: 18 .swift files changed, +463 −529 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 40.

## Beta Commit 61

- **User preferences split out of `AppState` into `AppUserPreferences`** (new
  `swift/shell/AppUserPreferences.swift`, reached as `store.preferences`): hide
  balances, Face ID, auto-lock, strict RPC, biometric for sends,
  price/transaction/large-movement notifications, refresh frequency and
  large-movement thresholds; views that read only preferences are not
  invalidated by wallet or balance changes; persistence still goes through
  `AppState`.
- **Pure core calls memoized for view bodies** (new
  `swift/shell/CachedCoreHelpers.swift`; `AddressValidationCache` in
  `AppState+AddressResolution.swift`): grouping keys, display decimals,
  stablecoin fallback prices, receive-address resolvers, private-key-hex checks
  (capped at 128 entries) and address validation.
- **Balance refresh follows the refresh-frequency preference**
  (`restartBalanceRefreshForCurrentConfiguration` in
  `AppState+BalanceRefresh.swift`): the interval is
  `automaticRefreshFrequencyMinutes` (default 5, at least 1) (before: fixed 30
  s); the engine stops while the app is inactive and restarts on activation and
  on a frequency change.
- **Icon cache bounded** (`swift/views/BundleImageLoader.swift`): 64 images and
  16 MB total cost (before: 256 images, no cost limit).
- Dashboard and History split into smaller subviews (`DashboardPortfolioHeader`,
  `DashboardActionButtons`, `HistoryControlsCard`); unused imports removed from
  settings views.
- Total: 51 .swift files changed (2 new), +847 −514 lines; data and config
  files: none; dependencies unchanged; test functions unchanged at 40.

## Beta Commit 60

- **Advanced setup sets derivation overrides per wallet** (advanced page in
  `swift/views/WalletSetupViews.swift`; `resolvedDerivationOverrides` in
  `swift/views/ImportDraft.swift`; `CoreWalletDerivationOverrides` from core)
  - Ten optional fields: passphrase, mnemonic wordlist, PBKDF2 iteration count,
    salt prefix, HMAC master key, curve, derivation algorithm, address
    algorithm, public-key format, script type; a blank field keeps the chain
    preset's value.
  - With overrides set, import derives each chain's address one at a time with
    them (without overrides: one batch derivation with preset defaults, as
    before).
  - The overrides are stored on the wallet (`derivationOverrides` in
    `swift/shell/PersistenceStore.swift`; a wallet stored without them loads
    with none) and passed to every `executeSend`.
- **Simple or Advanced is chosen on the Add Wallet page** (segmented picker in
  `swift/views/AddWalletEntryView.swift`; `beginWalletImport(setupMode:)`,
  `beginWalletCreation(setupMode:)`): setup no longer opens on a "Choose Setup
  Type" page; watch-only always uses Simple.
- **Wallet-collection observation guards its continuation with an atomic flag**
  (`AtomicFlag` in `swift/shell/AppState.swift`), since `onChange` can fire from
  any actor.
- Total: 14 .swift files changed, +1095 −412 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 40.

## Beta Commit 59

- **More send, pricing and status rules now come from core**
  (`swift/shell/AppState+SendFlow.swift`, `AppState+OperationalTelemetry.swift`,
  `Store+Notifications.swift`, `AppState+BalanceRefresh.swift`,
  `AppState+DiagnosticsEndpoints.swift`)
  - Ethereum custom-fee and manual-nonce validation, send-error classification
    (`EthereumSendErrorCode`, localized in Swift) and EVM recipient preflight
    warnings.
  - Price-alert evaluation, built-in token preference merge, and whether a
    live-price change rebuilds the dashboard.
  - Pending-transaction status polling: whether to poll, success and failure
    updates, stale pending failures, applying resolved statuses.
  - Operational event append, merging holdings from a balance summary, chain
    keypool state and its baseline.
- **Core exports the app no longer calls are dropped from the bindings**:
  per-chain `build*SendPayload`, send-preview decoders,
  `classifySendBroadcastResult`, `SendStateMachine`,
  `coreMergeBitcoinHistorySnapshots`.
- History rows are computed directly from the store (before: cached `@State`
  rebuilt on change); token icon preferences are observed through
  `TokenIconPreferences.shared` (before: `@AppStorage`).
- Tests: 1 new, 16 removed
  - Chain wiki 1: a registered chain without a wiki entry (replaces the
    per-chain wiki-presence tests).
  - Removed: EVM-context default and import-selection tests for Ethereum
    Classic, Avalanche, Hyperliquid, Aptos and ICP, per-chain wiki-presence
    tests, and the Solana mint-address and address-validator tests
    (`SolanaBalanceTests.swift` deleted); `NetworkClientTests.swift` renamed
    `ChainSupportTests.swift`.
- Docs: `swift/SUMMARY.md` (Observation instead of `ObservableObject`, tests
  list); `swift/derivation/DerivationTestingFormat.md` (typed UniFFI records
  replace the JSON payloads).
- Total: 34 .swift files changed, +3889 −2797 lines; data and config files:
  `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test functions 55
  → 40.

## Beta Commit 58

- **Settings screens split into one file each** (from
  `swift/views/SettingsViews.swift` into 18 new view files such as
  `PricingSettingsView.swift`, `PriceAlertsView.swift`, `AddressBookView.swift`,
  `LogsView.swift`; `MainTabView.swift`; send primary sections into
  `SendPrimarySectionsView.swift`); behaviour unchanged.
- **Built-in tokens read as typed records** (`listBuiltinTokens` returning
  `TokenEntry`; before: JSON parsed in `swift/shell/StaticContentCatalog.swift`)
- **`Coin` reports its chain family** (`chainID`, `isUTXOChain`, `isEVMChain`,
  `isNativeCoin` in `swift/shell/CoreModels.swift`, from the endpoint directory)
- Hand-written send and receive `Binding` accessors removed from `AppState`;
  resetting custom token icons bumps an observable revision (before: deleted a
  UserDefaults key).
- Total: 33 .swift files changed (20 new), +2157 −2632 lines; data and config
  files: `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test
  functions unchanged at 55.

## Beta Commit 57

- **Balance, history and preview data arrive from core as typed records**
  (`swift/rustbridge/WalletServiceBridge.swift`, `swift/fetch/ChainTypes.swift`,
  `StoreHistoryRefresh.swift`, `AppState+SendPreview.swift`,
  `AppState+SendFlow.swift`)
  - `fetchNativeBalanceSummary`, `fetchBitcoinHistorySnapshots`,
    `deriveBitcoinHdAddressStrings`, `fetchEvmHasContractCode` replace the JSON
    calls; the Swift JSON field decoders (`RustBalanceDecoder` field readers,
    `decodeRustHistoryJSON`) are gone.
  - The `…Json` variants of the app-core catalog, derivation and self-test
    exports are removed from the bindings; only state-persistence blobs stay
    JSON.
- **Chain names map to IDs in core** (`coreChainIdForName`; before: a Swift
  table in `SpectraChainID`); endpoint IDs, transaction explorer URLs and
  rebroadcast payloads also come from core.
- **Core-owned enums are typealiases** (`BitcoinNetworkMode =
  CoreBitcoinNetworkMode` and the like; the `RustStringEnum` protocol removed).
- **The balance observer receives the updated wallet summary**
  (`swift/shell/AppState+BalanceRefresh.swift`): core applies the balance to its
  store first and Swift only merges holdings (before: raw balance JSON).
- **Chain diagnostics screens are table-driven** (`StandardDiagnosticsChain`
  keyed by `AppChainID` in `swift/views/DiagnosticsViews.swift`; before: a
  per-chain view factory).
- Views call `AppLocalization.string` and use `@Bindable` directly (per-file
  localization wrappers and hand-written bindings removed); 4 English runtime
  strings added (operational events and owned-address management headings and
  empty states).
- Docs: `swift/SUMMARY.md` `WalletServiceBridge` entry.
- Total: 39 .swift files changed, +3510 −4384 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test functions
  unchanged at 55.

## Beta Commit 56

- **App state uses Swift Observation** (`@Observable` on `AppState`,
  `WalletDiagnosticsState`, `WalletChainDiagnosticsState`, `WalletImportDraft`
  and the other observable stores; before: `ObservableObject` with `@Published`
  and Combine)
  - Views hold the store as a plain property; `ViewRefreshSignal` removed.
  - Wallet-collection side effects run from an observation task (before: a
    debounced Combine sink); diagnostics persistence is debounced with a `Task`
    (before: `DispatchWorkItem`).
- **`.swift-format` added and the Swift sources reformatted** (140 columns,
  4-space indent)
- **Derivation JSON entry points removed**
  (`WalletDerivationLayer.derive(jsonData:)` and `derive(jsonString:)`, with
  their refusals of custom iteration counts and HMAC keys)
- **Endpoint catalog uses core's typed records** (`AppEndpointRecord =
  AppCoreEndpointRecord`, `appCoreEndpointRecordsForChain` in
  `swift/rustbridge/WalletRustEndpointCatalogBridge.swift`; before: JSON decoded
  in Swift).
- **Unused `ChainEndpointReliability` removed** (UserDefaults-backed endpoint
  success counters with no callers), with core's
  `coreOrderEndpointsByReliability` and `coreRecordEndpointAttempt`.
- **A coin's colour is derived from its symbol** (`Coin.color`; the stored
  colour and per-holding overrides removed from `CoreModels.swift` and
  `DashboardStore.swift`)
- Docs: `swift/SUMMARY.md` `StoreDiagnosticsExport` and endpoint catalog bridge
  entries.
- Total: 63 .swift files changed, +9804 −4784 lines; data and config files:
  `.swift-format`, `swift/generated/spectra_coreFFI.h`; dependencies unchanged;
  test functions unchanged at 55.

## Beta Commit 55

- **Wallets, transactions and the address book are owned by Swift again**
  (`swift/shell/AppState.swift`, `AppState+CoreStateStore.swift`,
  `AppState+RustObserver.swift`)
  - The `@Published` arrays are canonical and persist through
    `PersistenceStore.swift` into core's SQLite store (before: mirrors of a core
    store, written through `storeWallets*`, `storeTransactions*`,
    `storeAddressBook*` and refreshed by an `AppStateObserver` callback).
  - Derived caches (wallet lookup, portfolio holdings, send and receive
    availability, token preferences) are stored on `AppState` (before: kept in
    core behind the `caches*` exports).
  - Scalar UI state is stored on `AppState` (before: core's `AppShellState`).
  - Core's state store, caches, shell state and observer exports are gone from
    the bindings; only the balance-refresh observer remains.
- **`WalletRustAppCoreBridge` removed; callers use the `corePlan*` exports
  directly** (`swift/rustbridge/WalletRustAppCoreBridge.swift` deleted)
- **User-facing messages built in Swift** (`AppState+SendFlow.swift`,
  `AppState+SendExecution.swift`, `AppState+PricingFiat.swift`): Ethereum
  send-error mapping, EVM contract-preflight reasons, send-balance validation
  messages and fiat currency names (before: returned as strings by
  `coreMapEthereumSendError`, `coreEvmPreflightContractReasons`,
  `coreValidateSendBalance`, `coreFiatCurrencyDisplayName`).
- **Self-test results are typed outcomes localized in Swift**
  (`ChainSelfTestOutcome.displayMessage` in
  `swift/fetch/DiagnosticsStore.swift`); `selfTestsRunEthereumRpc` added.
- **Tabs are built eagerly again** (`LazyTab` removed from
  `swift/views/SettingsViews.swift`).
- **Add Wallet pushes the importer** (`navigationDestination` to `SetupView` in
  `swift/views/AddWalletEntryView.swift`).
- Docs: `swift/SUMMARY.md` canonical-state, `CoreStateStore`, `RustObserver` and
  rustbridge sections.
- Total: 24 .swift files changed, +34534 −44688 lines; data and config files:
  `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test functions
  unchanged at 55.

## Beta Commit 54

- **Send previews live in their own observable store** (new
  `swift/send/SendPreviewStore.swift`; `AppState` forwards): preview updates no
  longer invalidate every view observing `AppState`.
- **Tab selection lives in its own observable** (`AppTabSelection` in
  `swift/shell/AppStateTypes.swift`); `AppState` no longer forwards the
  diagnostics states' `objectWillChange`.
- **Dashboard, history and wallet rows are `Equatable` views; long stacks are
  `LazyVStack`** (`DashboardViews.swift`, `HistoryView.swift`,
  `SettingsViews.swift`, `SendFlowViews.swift`)
- **Decoded icons cached in memory** (`NSCache` of 256 images plus a URL lookup
  cache in `swift/views/BundleImageLoader.swift`; 128 custom token images in
  `IconUIHelpers.swift`)
- **Bitcoin Cash and Dogecoin sends show the advanced-mode caption** (before:
  Bitcoin only) (`swift/views/SendFlowViews.swift`)
- **Risk-probe settings for Litecoin, Dogecoin, Solana, XRP Ledger, Monero, Sui
  and Aptos come from core** (`coreSimpleChainRiskProbeConfig`; before: balance
  field and divisor per chain in Swift); fiat currency names from
  `coreFiatCurrencyDisplayName`.
- `Localizable.strings` added for `en`, `zh-Hans` and `zh-Hant` with "Language"
  and "Settings".
- Docs: `swift/SUMMARY.md` added: file-by-file map of the Swift layer and how it
  reaches core (static content, state, HTTP, derivation, secrets, platform
  callbacks).
- Total: 32 .swift files changed (1 new), +650 −460 lines; data and config
  files: `swift/generated/spectra_coreFFI.h`,
  `swift/resources/en.lproj/Localizable.strings`,
  `swift/resources/zh-Hans.lproj/Localizable.strings`,
  `swift/resources/zh-Hant.lproj/Localizable.strings`; dependencies unchanged;
  test functions unchanged at 55.

## Beta Commit 53

- **Derivation presets and the endpoint directory now ship in core**
  (`swift/derivation/DerivationPresets.json`,
  `DerivationRequestCompilationPresets.json`,
  `swift/rustbridge/AppEndpointDirectory.json` deleted, moved to
  `core/embedded/`): the Swift preset structs and enums are replaced by core's
  types (`swift/derivation/Presets.swift`).
- **More app logic now in core** (`AppState+AddressResolution.swift`,
  `AppState+ReceiveFlow.swift`, `RegistryModels.swift`,
  `Store+Formatting.swift`, `StoreLifecycleReset.swift`,
  `MaintenanceStore.swift`, `StorePersistenceNormalization.swift`)
  - Choosing the derived or stored address, with validation and normalization
    (`corePlanResolveDerivedOrStoredAddress`).
  - The receive-address resolver per chain (`corePlanReceiveAddressResolver`).
  - Icon identifiers, canonical chain components and display marks.
  - Which chains are priced, whether a wallet exists for a chain, the reset
    dispatch plan, earliest transaction dates, active wallet transaction IDs,
    the normalized history signature, the pending-refresh interval and the
    portfolio composition signature.
- Total: 16 .swift files changed, +1761 −2906 lines; data and config files:
  `swift/derivation/DerivationPresets.json`,
  `swift/derivation/DerivationRequestCompilationPresets.json`,
  `swift/generated/spectra_coreFFI.h`,
  `swift/rustbridge/AppEndpointDirectory.json`; dependencies unchanged; test
  functions unchanged at 55.

## Beta Commit 52

- **Chain diagnostics state and operational logs moved to core**
  (`swift/fetch/DiagnosticsState.swift`)
  - The 24 per-wallet diagnostic dictionaries live in core's diagnostics
    registry; Swift accessors delegate to it and bump `diagnosticsRevision`.
  - Operational logs and chain sync state persist in core's SQLite store
    (`saveState`/`loadState`) and load at launch through `loadFromSQLite()`
    (before: UserDefaults keys `operational.logs.v1` and `chain.sync.state.v1`;
    the UserDefaults readers are removed).
- **Legacy Dogecoin keypool and owned-address UserDefaults readers removed**
  (`swift/shell/PersistenceStore.swift`): only the per-chain maps load.
- **Price merging and display rules now come from core**
  (`AppState+PricingFiat.swift`, `Store+Formatting.swift`,
  `DashboardViews.swift`, `StoreHistoryRefresh.swift`): live-price and fiat-rate
  merges, degraded-detail normalization and templates, fiat amount formatting,
  minimum visible amount, stablecoin fallback prices, dashboard grouping keys
  and supported-token entries, normalized refresh targets, EVM transaction
  record planning.
- **`AddressValidation` collapsed into `isValid(_:kind:networkMode:)` and
  `normalized(_:kind:networkMode:)`** (new
  `swift/shell/AppState+AddressResolution.swift`, with the address resolvers
  moved out of `AppState+SendFlow.swift`)
- **Swift files consolidated**: `providercatalog/` dissolved
  (`AppEndpointDirectory.swift` became
  `rustbridge/WalletRustEndpointCatalogBridge.swift`); `AppLocalization` into
  `StaticContentCatalog.swift`; `SpectraSecretStoreAdapter` into
  `SecureStores.swift`; `PersistenceModels` into `PersistenceStore.swift`;
  `MaintenanceIntervals` and `RefreshPlan` into `MaintenanceStore.swift`;
  diagnostics files into `DiagnosticsState.swift` and `DiagnosticsStore.swift`;
  `CoreModels`, `RegistryModels`, `StaticContentCatalog` and `Platform` moved
  from `views/` to `shell/`.
- Total: 57 .swift files changed (1 new), +3254 −2503 lines; data and config
  files: `swift/Spectra.xcodeproj/project.pbxproj`,
  `swift/generated/spectra_coreFFI.h`,
  `swift/rustbridge/AppEndpointDirectory.json`; dependencies unchanged; test
  functions unchanged at 55.

## Beta Commit 51

- **Simple native-chain sends share one path** (`submitSimpleNativeChainSend` in
  `swift/send/AppState+SendExecution.swift`): Sui, Aptos, TON, NEAR, Polkadot,
  Stellar, XRP Ledger, Cardano and Monero.
- **Derivation-path parsing, private-key hex checks and large-movement
  evaluation now in core** (`coreParseDerivationPath`,
  `coreDerivationPathReplacingLastTwo`, `coreDerivationPathString`,
  `corePrivateKeyHexIsLikely`, `coreEvaluateLargeMovement`); Swift's
  `DerivationPathParser` and `PrivateKeyHex` removed.
- **Persistence and rebuilds debounced** (`swift/shell/AppState.swift`): price
  alerts and address book 100 ms, live prices 200 ms, token-preference rebuild
  and wallet-collection side effects 30 ms (before: on every change).
- **Settings setters publish only on a change** (`notifyIfChanged`; before:
  every set sent `objectWillChange`); keypool and owned-address maps persist
  only the chains that changed (before: all chains).
- **Per-chain `has…Wallets` properties replaced by `hasWalletForChain(_:)`**
  (`AppState+PricingFiat.swift`, `swift/fetch/WalletFetchLayer.swift`); Dogecoin
  owned addresses read the shared per-chain map (`dogecoinOwnedAddressMap`
  facade removed).
- **Unused `SeedPhraseSafety`, `SendPayloadBuilder` and `WalletAddressInventory`
  removed**
- Total: 23 .swift files changed, +724 −663 lines; data and config files:
  `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test functions
  unchanged at 55.

## Beta Commit 50

- **Typed UniFFI records replace JSON across the core bridge**
  (`swift/generated/spectra_core.swift`;
  `swift/rustbridge/WalletRustAppCoreBridge.swift`,
  `WalletRustAppCoreBridgeTypes.swift`,
  `swift/derivation/WalletRustDerivationBridge.swift`,
  `swift/fetch/SelfTests.swift`)
  - App-core catalogs (chain descriptors, backends, presets, endpoints, explorer
    entries, diagnostics checks), derivation (derive, signing material, all
    addresses), self-tests, asset decimals, high-risk send reasons and address
    validation take and return records.
  - The Swift mirror types (`WalletRust*`) and their `toFFI`/`toWalletRust`
    converters are deleted.
- **Sends go through one core call**
  (`WalletServiceBridge.executeSend(SendExecutionRequest)` in
  `swift/send/AppState+SendExecution.swift`): Bitcoin, the other UTXO chains,
  EVM, Dogecoin, Tron, Solana, XRP Ledger, Stellar, Monero, Cardano, Sui, Aptos,
  TON, Internet Computer, NEAR and Polkadot; the balance check before sending is
  `coreValidateSendBalance` (before: per-chain `signAndSend*WithDerivation`
  calls).
- **Seed encryption and the seed password verifier run in core**
  (`swift/shell/SecureStores.swift`):
  `encryptSeedEnvelope`/`decryptSeedEnvelope` with the Keychain-held master key,
  `createPasswordVerifier`/`verifyPasswordVerifier` (before: AES-GCM with
  CryptoKit and PBKDF2 with CommonCrypto in Swift); Keychain storage stays in
  Swift.
- **Wallet import drafts are validated in core**
  (`coreValidateWalletImportDraft` from `swift/views/ImportDraft.swift`; before:
  per-chain watch-address checks in Swift).
- **Swift chain providers and the endpoint registry removed**
  (`swift/providercatalog/ChainProviders.swift`,
  `swift/fetch/ChainBackendRegistry.swift` deleted): Esplora,
  Blockchair/ActorForth, WhatsOnChain, Aptos, Monero, TON, Polkadot and Solana
  response types and URL builders; lookups go through `AppEndpointDirectory`
  backed by core's catalog.
- **Swift derivation wrappers removed** (`WalletDerivationEngine.swift`,
  `SeedPhraseAddressDerivation.swift`, `SeedPhraseSigningMaterial.swift`
  deleted); `WalletDerivationLayer` calls core's derivation directly;
  `WalletAddressResolver` folded into `AppState+SendFlow.swift`.
- **Persistence uses typed core records**
  (`swift/shell/PersistenceStore.swift`): app settings (`PersistedAppSettings`),
  keypool state, owned addresses, history records and wallet summaries (before:
  JSON strings).
  - Dogecoin keypool and owned addresses join the per-chain maps (before:
    separate Dogecoin maps).
  - The wallet core snapshot (legacy wallet-store migration and export,
    persisted snapshot, secret index) is removed, with core's
    `coreMigrateLegacyWalletStoreJson` and `coreExportLegacyWalletStoreJson`.
- **Shell-state setters publish only on a change** (`notifyIfChanged` in
  `swift/shell/AppState.swift`)
- Total: 52 .swift files changed, +17629 −13830 lines; data and config files:
  `swift/Spectra.xcodeproj/project.pbxproj`,
  `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test functions
  unchanged at 55.

## Beta Commit 49

- **Swift 6 strict-concurrency annotations** across the bridges, derivation and
  models (`nonisolated`, `Sendable`); `scripts/bindgen-ios.sh` marks generated
  functions and initializers `nonisolated`.
- **Runtime strings load per locale** (`swift/views/AppLocalization.swift`):
  `RuntimeStrings.manifest.json` first, then `RuntimeStrings.<locale>.json` on
  demand from `strings/` (before: one `RuntimeStrings.json` with every locale).
- **Hard-coded UI text localized** (send, receive, dashboard, wallet setup,
  wallet flow, staking, add-wallet and history views); runtime strings `en` 1053
  → 1101, `zh-Hans` and `zh-Hant` 1104 → 1151.
- **Static JSON and the BIP-39 word list come from core first**
  (`loadFromRustCore` via `coreStaticResourceJson` in
  `swift/views/StaticContentCatalog.swift`; `bip39EnglishWordlist()`); bundle
  fallbacks use the new `strings/` and `icons/` paths.
- **Core planning calls no longer throw; the Swift fallbacks are gone**
  (`AppState+ImportLifecycle.swift`, `StorePersistenceNormalization.swift`,
  `StoreHistoryRefresh.swift`): owned-address aggregation, receive selection,
  transaction merge, derived-state and transfer-availability planning, history
  pagination.
- **Derived-cache rebuilds publish one revision** (`batchCacheUpdates` in
  `swift/shell/AppState.swift`)
- Total: 38 .swift files changed, +1224 −1070 lines; data and config files:
  `resources/strings/RuntimeStrings.en.json`,
  `resources/strings/RuntimeStrings.zh-Hans.json`,
  `resources/strings/RuntimeStrings.zh-Hant.json`, `scripts/bindgen-ios.sh`,
  `swift/Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions unchanged at 55.

## Beta Commit 48

- **Shared resources reorganized** (no Swift change in this commit)
  - Icons renamed from `resources/TokenIcons/<Name>Token.png` to
    `resources/icons/<name>.png` (56 files).
  - `resources/Localization/` became `resources/strings/` (`Base/` → `base/`).
  - `RuntimeStrings.json`, which held every locale, split into
    `RuntimeStrings.en.json`, `RuntimeStrings.zh-Hans.json`,
    `RuntimeStrings.zh-Hant.json` and `RuntimeStrings.manifest.json`.
  - `BIP39EnglishWordList.txt`, `BuyCryptoProviders.json`,
    `ChainVisualRegistry.json` and `TokenVisualRegistry.json` removed here; they
    moved to `core/embedded/` in the core repository.
- Docs: `LOCALIZATION_GUIDE.md` moved to `resources/strings/`.
- Total: no .swift files changed, +3268 −5406 lines; data and config files:
  `resources/icons/` (56), `resources/strings/` (33), `resources/` (4),
  `resources/Localization/` (1); dependencies unchanged; test functions
  unchanged at 55.

## Beta Commit 47

- **Dogecoin uses the shared UTXO address discovery and receive reservation**
  (`swift/shell/ChainRefreshDescriptors.swift`, `AppState+SendFlow.swift`):
  address validation and the activity check (`balance_koin` or history from
  core) join Bitcoin Cash, Bitcoin SV and Litecoin.
- **Bitcoin refresh runs UTXO address discovery and receive reservation**; deep
  discovery no longer special-cases Bitcoin outside `supportsDeepUTXODiscovery`.
- **History-only refresh for Bitcoin, Bitcoin Cash, Bitcoin SV, Litecoin,
  Dogecoin, Ethereum Classic, Avalanche, Polkadot, Aptos and ICP**
  (`executeHistoryOnly`); Ethereum Classic history is now fetched on refresh and
  on a user refresh.
- **Avalanche "load more" history pages for the selected wallets**
  (`swift/fetch/WalletFetchLayer.swift`; before: `loadMore: false`)
- **Tabs other than Home are built on first selection** (`LazyTab` in
  `swift/views/SettingsViews.swift`)
- **Litecoin-specific HTTP retry profiles removed from core**; diagnostics
  probes use `.diagnostics`.
- Total: 6 .swift files changed, +60 −44 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 55.

## Beta Commit 45

- **Secret-store callbacks are typed by secret class and throw**
  (`swift/shell/SpectraSecretStoreAdapter.swift`; `SecretStoreImpl` in core's
  bindings)
  - `loadSecret`, `saveSecret`, `deleteSecret` and `listKeys` take a
    `SecretClass` (seed, private key, generic) and pick `SecureSeedStore`,
    `SecurePrivateKeyStore` or `SecureStore` by it (before: by key prefix
    `wallet.seed.` or `wallet.privatekey.`).
  - A missing secret throws `SecretStoreError.NotFound` and a seed Keychain
    failure throws `Backend` (before: `nil` or `false`).
- **`RustStringEnum` compares cases by name** (`swift/fetch/ChainTypes.swift`),
  so `rawValue` and `==` no longer call each other.
- **Icon lookup asks the bundle first** (`swift/views/BundleImageLoader.swift`):
  `Bundle.main.url(forResource:)`, then `TokenIcons/`, then
  `Resources/TokenIcons/`.
- **`scripts/bindgen-ios.sh` writes its Swift 6 patch through a temp file
  outside the output folder**, so Xcode's synchronized group does not pick up a
  transient file.
- **Swift files consolidated**: eight provider files into
  `swift/providercatalog/ChainProviders.swift`; `ChainRefresh.swift` and
  `ChainRefreshRouter.swift` into `ChainRefreshDescriptors.swift`;
  `RefreshSignal.swift` into `RefreshPlan.swift`; `PortfolioStore.swift` into
  `AppState.swift`; `FlowStore.swift` renamed `AppState+Bindings.swift` and
  absorbs `ReceiveFlowStore.swift`; empty Dogecoin and Litecoin balance test
  classes deleted.
- Docs: deleted `swift/rustbridge/RustFFIPlan.md`,
  `swift/tests/TESTING_WORKFLOW.md`, `swift/tests/TESTS_STRUCTURE.md`,
  `swift/views/VIEWS_STRUCTURE.md`.
- Total: 33 .swift files changed (1 new), +1116 −1121 lines; data and config
  files: `scripts/bindgen-ios.sh`, `swift/Spectra.xcodeproj/project.pbxproj`,
  `swift/generated/spectra_coreFFI.h`; dependencies unchanged; test functions
  unchanged at 55.

## Beta Commit 44

- **Generated bindings and the Rust bridge files get their own folders**
  (`swift/generated/`, `swift/rustbridge/`; `scripts/bindgen-ios.sh`,
  `swift/Spectra.xcodeproj/project.pbxproj`)
  - `spectra_core.swift`, `spectra_coreFFI.h` and both modulemaps move from
    `swift/derivation/generated/` to `swift/generated/`; the bindgen script, the
    Rust build phase, the header search paths and `SWIFT_INCLUDE_PATHS` point
    there (before: `$(SRCROOT)/Derivation/Generated`).
  - `WalletRustAppCoreBridge.swift`, `WalletRustAppCoreBridgeTypes.swift`,
    `WalletServiceBridge.swift` and `RustFFIPlan.md` move from
    `swift/derivation/` to `swift/rustbridge/`, each a synchronized group in the
    project.
  - The shared-resources group points at `../resources` (before: `../Resources`,
    the name before Beta Commit 43's lowercasing).
- **Cloud-sync partial copies deleted and kept out** (`.gitignore`, Rust build
  phase)
  - The two `.!13620!spectra_core.swift` and `.!14147!spectra_core.swift` copies
    committed in Beta Commit 42 (59,750 lines) are deleted.
  - `.gitignore` ignores `.!*!*`, and the Rust build phase deletes every `.!*`
    file under the project before building.
- Docs: `RustFFIPlan.md` moved to `swift/rustbridge/`, unchanged.
- Total: 6 .swift files changed, +25 −59758 lines; data and config files:
  `.gitignore`, `scripts/bindgen-ios.sh`,
  `swift/Spectra.xcodeproj/project.pbxproj`, `swift/generated/module.modulemap`,
  `swift/generated/spectra_coreFFI.h`,
  `swift/generated/spectra_coreFFI.modulemap`; dependencies unchanged; test
  functions unchanged at 55.

## Beta Commit 43

- **Directory names lowercased** (`Swift/` → `swift/`, `Resources/` →
  `resources/`; 233 files renamed, `swift/Spectra.xcodeproj/project.pbxproj`,
  `scripts/bindgen-ios.sh`)
  - Under `swift/`: `derivation/`, `derivation/generated/`, `extensions/`,
    `fetch/`, `providercatalog/`, `resources/`, `send/`, `shell/`, `tests/`,
    `views/`; `Spectra.xcodeproj`, `Localization/`, `TokenIcons/` and the two
    live-activity folders keep their names.
  - The project's synchronized groups follow; the bindgen script writes to
    `swift/derivation/generated/`.
- **Committed bindings carry the Swift 6 isolation patch again**
  (`swift/derivation/generated/spectra_core.swift`):
  `uniffiFutureContinuationCallback` is `nonisolated` and the continuation
  parameter is not `@escaping`, as `bindgen-ios.sh` patches them.
- Docs: all seven docs moved with their folders
  (`resources/Localization/LOCALIZATION_GUIDE.md`, `swift/derivation/*.md`,
  `swift/tests/*.md`, `swift/views/VIEWS_STRUCTURE.md`), unchanged.
- Total: 120 .swift files changed, +47 −47 lines; data and config files:
  `resources/TokenIcons/` (56), `resources/Localization/` (30),
  `swift/derivation/` (5), `resources/` (4), `swift/Spectra.xcodeproj/` (4),
  `swift/resources/` (4), `scripts/` (1), `swift/` (1), `swift/extensions/` (1),
  `swift/providercatalog/` (1); dependencies unchanged; test functions unchanged
  at 55.

## Beta Commit 42

- **Shared resources move from `Swift/Resources/` to a repository-root
  `Resources/`** (`Swift/Spectra.xcodeproj/project.pbxproj` group
  `SharedResources` at `../Resources`; `Swift/Views/BundleImageLoader.swift`
  comment)
  - Moved: `Localization/` (runtime strings, per-locale content JSON, glossary,
    guide), `TokenIcons/` (56 PNGs), `BIP39EnglishWordList.txt`,
    `BuyCryptoProviders.json`, `ChainVisualRegistry.json`,
    `TokenVisualRegistry.json`; `Swift/Resources/` keeps only `Assets.xcassets`.
  - The project's `Store` group is renamed `Shell`, matching the folder renamed
    in Beta Commit 40.
- **Committed bindings lose the Swift 6 isolation patch**
  (`Swift/Derivation/Generated/spectra_core.swift`):
  `uniffiFutureContinuationCallback` is no longer `nonisolated` and the
  continuation parameter is `@escaping` again.
- **Two cloud-sync partial copies of the bindings committed**
  (`Swift/Derivation/Generated/.!13620!spectra_core.swift`,
  `.!14147!spectra_core.swift`; 34,201 and 25,549 lines); deleted in Beta Commit
  44.
- Docs: `VIEWS_STRUCTURE.md` resources line (Swift-only `Swift/Resources/` holds
  the asset catalog, shared data lives in `/Resources/`);
  `LOCALIZATION_GUIDE.md` moved to `Resources/Localization/`.
- Total: 4 .swift files changed (2 new), +59767 −9 lines; data and config files:
  `Resources/TokenIcons/` (56), `Resources/Localization/` (30), `Resources/`
  (4), `Swift/Spectra.xcodeproj/` (1); dependencies unchanged; test functions
  unchanged at 55.

## Beta Commit 41

- **Rust pushes wallet, transaction, address-book and diagnostics changes to the
  app** (new `Swift/Shell/AppState+RustObserver.swift`, `AppStateRustObserver`)
  - `AppState` registers an implementation of the generated `AppStateObserver`
    trait in `init()`; each callback hops to the main actor and replaces the
    matching `@Published` mirror (`applyWalletsFromRust`,
    `applyTransactionsFromRust`, `applyAddressBookFromRust`), or sends
    `objectWillChange` for diagnostics.
- **Swift HTTP retry layer deleted** (`Swift/Fetch/NetworkClient.swift`):
  `NetworkRetryProfile`, `NetworkRetryPolicy`, `NetworkResilience`,
  `LiveSpectraNetworkClient` and the queued stub client are removed; EVM
  endpoint diagnostics post JSON-RPC through the generated `httpPostJson`
  (`AppState+SendFlow.swift`).
- **`EthereumRPCProvider` deleted**
  (`Swift/ProviderCatalog/EthereumRPCProvider.swift`) with its JSON-RPC request
  and response types.
- **EVM replacement fees and contract preflight decided in Rust**
  (`Swift/Shell/AppState+SendFlow.swift`)
  - Speed-up and cancel fees come from `coreEvmReplacementFeeBump` (defaults 4
    and 2 gwei; before: the same rule, +20 % with a 0.1 gwei floor, in Swift).
  - Send warnings about a contract recipient or a missing token contract come
    from `coreEvmPreflightContractReasons`, given the fetched bytecode (before:
    built in Swift).
- **Diagnostics compatibility shims deleted**
  (`Swift/Shell/DiagnosticsTypesCompat.swift`); call sites use the generated
  names (`walletId`, `coinGeckoId`, `bitcoinSvAddress`, `CoreCoin`) across
  shell, send and view files.
- `.gitignore` ignores `.claude/`.
- Tests: 0 new, 2 removed
  - Network client 2: queued stub responses consumed in order and kept apart per
    HTTP method; the stub client is gone.
- Total: 42 .swift files changed (1 new), +2582 −1045 lines; data and config
  files: `.gitignore`, `Swift/Derivation/Generated/spectra_coreFFI.h`;
  dependencies unchanged; test functions 57 → 55.

## Beta Commit 40

- **`WalletStore` renamed `AppState`, and `Swift/Store/` becomes
  `Swift/Shell/`** (new `Swift/Shell/AppState.swift`, `AppStateTypes.swift`;
  `WalletStore+*.swift` → `AppState+*.swift`; send extensions →
  `Swift/Send/AppState+Send*.swift`; `Swift/Tests/AppStateTests.swift`)
- **Rust owns wallets, transactions and the address book; `AppState` keeps
  `@Published` mirrors** (new `Swift/Shell/AppState+CoreStateStore.swift`)
  - Every mutation goes through helpers (`setWallets`, `upsertWallet`,
    `removeWallet`, transaction and address-book equivalents) that call the
    generated `store*` functions first and then update the mirror.
  - Derived caches (portfolio, send- and receive-enabled wallets, token
    preferences, signing-material and password-protected wallet IDs, ENS
    results, dashboard pins, …) are replaced in Rust through `caches*` calls;
    keypool state and diagnostics are stored through `storeChainKeypoolState`
    and `storeDiagnostics`.
- **App model types are the generated Rust records**
  (`Swift/Views/CoreModels.swift`, `PersistenceModels.swift`,
  `RegistryModels.swift`, `Swift/Fetch/ChainTypes.swift`): `Coin`,
  `ImportedWallet`, `TransactionKind`, `TransactionStatus`,
  `PriceAlertCondition`, `SeedDerivationPreset`, `SeedDerivationPaths`,
  `BitcoinNetworkMode`, `DogecoinNetworkMode` and the per-chain
  history-diagnostics structs become typealiases of `Core*` records with Swift
  extensions; new `Swift/Shell/DiagnosticsTypesCompat.swift` maps old names and
  field spellings.
- **Send parameters built by Rust** (`Swift/Send/AppState+SendExecution.swift`,
  new `Swift/Send/SendPayloadBuilder.swift`): every chain's sign-and-send
  payload comes from a generated `build…SendPayload` function (amount conversion
  and JSON in Rust); before: JSON assembled by Swift string interpolation.
- **In-app chain self-tests run in Rust** (`Swift/Fetch/SelfTests.swift`,
  `selfTestsRunChainJson`, `selfTestsRunAllJson`): each chain suite returns
  Rust's results; a failed bridge call is reported as one failed check.
- Token icons re-encoded (56 PNGs in `Swift/Resources/TokenIcons/`).
- Tests: 0 new, 10 removed
  - In-app self-test checks 10 (Dogecoin and Ethereum address acceptance and
    rejection, checksum mutation, receive-address normalization, seed
    derivation, single-provider configuration, transfer pagination): moved to
    Rust.
- Total: 82 .swift files changed (8 new), +43112 −18482 lines; data and config
  files: `Swift/Resources/` (56), `Swift/Derivation/` (1),
  `Swift/Spectra.xcodeproj/` (1); dependencies unchanged; test functions 67 →
  57.

## Beta Commit 39

- **Folder tree flattened** (126 files renamed, contents unchanged;
  `Swift/Spectra.xcodeproj/project.pbxproj`, `scripts/bindgen-ios.sh`)
  - `Swift/Derivation/{Addresses,Catalog,Core}/` → `Swift/Derivation/` (bindings
    in `Swift/Derivation/Generated/`);
    `Swift/Fetch/{Layers,Services,Support,…}/` → `Swift/Fetch/`;
    `Swift/ProviderCatalog/{Core,Providers/*,Registry}/` →
    `Swift/ProviderCatalog/`; `Swift/Send/{Layers,Support/*}/` → `Swift/Send/`;
    `Swift/Store/{App,AppState,Security}/` → `Swift/Store/`; `Swift/Tests/*/` →
    `Swift/Tests/`; `Swift/Views/*/` → `Swift/Views/`.
  - The live-activity folders move from `Swift/Views/Extensions/` to
    `Swift/Extensions/`; the per-feature view groups in the project collapse to
    one `Views` group; the bindgen script writes to
    `Swift/Derivation/Generated/`.
- Docs: `TESTING_WORKFLOW.md` moved from `Swift/Tests/Docs/` to `Swift/Tests/`.
- Total: 118 .swift files changed, +23 −94 lines; data and config files:
  `Swift/Derivation/` (5), `Swift/Extensions/` (1), `Swift/ProviderCatalog/`
  (1), `Swift/Spectra.xcodeproj/` (1), `scripts/` (1); dependencies unchanged;
  test functions unchanged at 67.

## Beta Commit 37

- **App moved into `Swift/`, building the Rust crate at `../ffi`** (all app
  folders, `Spectra.xcodeproj`, `Spectra.xctestplan`; Rust build phase
  `RUST_DIR=${SRCROOT}/../ffi`, bindgen manifest `../tools/uniffi-bindgen`;
  before: `Core/` beside the app folders)
- **Makefile and iOS build scripts** (new `Makefile`, `scripts/build-ios.sh`,
  `scripts/bindgen-ios.sh`)
  - `make ios` builds `libspectra_core.a` for device and simulator (simulator
    slices merged with `lipo` into `build/apple/`) and regenerates the Swift
    bindings into `Swift/Derivation/Core/Generated/` with the Swift 6 isolation
    patch; `make test` and `make check` run cargo.
  - The Makefile also names Android targets whose scripts are not in this
    repository.
- **App-core bridge passes typed UniFFI records instead of JSON strings**
  (`Swift/Derivation/Core/WalletRustAppCoreBridge.swift`,
  `WalletRustAppCoreBridgeTypes.swift`): wallet import planning, maintenance and
  refresh plans, history normalization and merge, EVM and Dogecoin targets,
  transfer availability, derived state, receive selection, self-send
  confirmation and send routing convert through `toFFI()` and `toWalletRust()`;
  the maintenance, refresh, history, target, transfer, derived-state, receive,
  self-send, routing and merge planners stop throwing.
- `Package.resolved` no longer tracked (KeychainAccess stays referenced by the
  project).
- Docs: all seven docs moved under `Swift/`, unchanged.
- Total: 120 .swift files changed (2 new), +15750 −5654 lines; data and config
  files: `Swift/Resources/` (94), `Swift/Derivation/` (5),
  `Swift/Spectra.xcodeproj/` (4), `scripts/` (2), `Makefile`,
  `Spectra.xcodeproj/project.xcworkspace/` (1), `Swift/ProviderCatalog/` (1),
  `Swift/` (1), `Swift/Views/` (1); dependencies unchanged; test functions
  unchanged at 67.

## Beta Commit 36

- **Valid Swift restored after Beta Commit 33's line joining**: the
  `..modifier(` sequences and the declarations joined onto one line are
  reformatted in every file that had them (views, models, stores).
- **Swift package dependencies removed except KeychainAccess**
  (`Spectra.xcodeproj/project.pbxproj`, `Package.resolved`): `wallet-core`
  (WalletCore, WalletCoreSwiftProtobuf), `bdk-swift`, `BigInt` and
  `solana-swift` are dropped from the project.
- **Remaining per-chain balance services, providers and engine helpers deleted**
  (`Fetch/Services/*Balance.swift`, `EVMBalance.swift`,
  `RustBalanceDecoder.swift`; `ProviderCatalog/ChainProviderCatalog.swift` and
  the BlockCypher, Horizon, NEAR RPC, Rosetta, Sui RPC and XRPL providers;
  `UTXOAddressCodec.swift`, `UTXOEngineSupport.swift`, `UTXOEngineTypes.swift`,
  the EVM utility files); the types callers still use are gathered in new
  `Fetch/Services/ChainTypes.swift`.
- **Sub-stores folded into `WalletStore`** (`Store/AppState/`,
  `Store/App/WalletStore.swift`): `DashboardState`, `FlowState`,
  `PortfolioState`, `RuntimeState`, `RuntimeStore`,
  `RuntimeSendPreparationStore`, `SendState`, `SendPreviewStore`,
  `SendExecutionStore`, `TransactionState` and `TransactionStore` are deleted;
  their properties are `@Published` on `WalletStore`.
- **Send layers become `WalletStore` extensions**
  (`Send/Layers/WalletStore+SendExecution.swift`, `+SendPreview.swift`,
  `+SendRouting.swift` replace the `WalletSend*Layer.swift` files);
  `SendMachineDriver.swift`, never instantiated, is deleted.
- **History arrives as normalized records from Rust**
  (`Store/AppState/StoreHistoryRefresh.swift`, `fetchNormalizedHistoryJSON`):
  Rust normalizes each chain's response and Swift maps it to `TransactionRecord`
  with source `rust`, including the Bitcoin and Dogecoin pages.
- **High-risk send reasons evaluated in Rust**
  (`Store/App/WalletStore+SendFlow.swift`,
  `coreEvaluateHighRiskSendReasonsJson`).
- **Bridge types split out and bindings regenerated** (new
  `Derivation/Core/WalletRustAppCoreBridgeTypes.swift`,
  `WalletRustDerivationBridgeTypes.swift`; `spectra_core.swift`): the
  regenerated bindings export the history-record, simple-preview and
  asset-holding methods the bridge already called.
- Total: 130 .swift files changed (6 new), +10429 −7809 lines; data and config
  files: `Derivation/Core/Generated/spectra_coreFFI.h`,
  `Spectra.xcodeproj/project.pbxproj`,
  `Spectra.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`;
  dependencies: removed wallet-core 4.6.0, bdk-swift 2.3.1, BigInt 5.7.0,
  solana-swift 5.0.0 (`Spectra.xcodeproj/project.pbxproj`; `Package.resolved`
  also drops secp256k1.swift 0.1.7, task-retrying-swift 2.0.0,
  tweetnacl-swiftwrap 1.1.0), KeychainAccess 4.2.2 remains; test functions
  unchanged at 67.

## Beta Commit 35

- **Rust crate renamed `spectra_derivation` → `spectra_core`**
  (`Derivation/Core/Generated/spectra_core.swift`, `spectra_coreFFI.h`,
  modulemaps; `Spectra.xcodeproj/project.pbxproj`); the exported function set is
  unchanged.
- **Settings saved as one record in Rust SQLite**
  (`Store/App/WalletStore.swift`,
  `Store/AppState/PersistenceStore.persistAppSettings`)
  - Each setting's `didSet` writes the whole `PersistedAppSettings` (pricing and
    fiat providers, RPC endpoints and API keys, Monero backend, network modes,
    Esplora endpoints, stop gap, fee priorities, privacy, notification and
    refresh settings) instead of its own `UserDefaults` key.
  - The SQLite reload also restores fiat rates and per-chain display decimals.
- **Transaction history persisted in Rust SQLite** (`PersistenceStore.swift`,
  `WalletServiceBridge` history-record calls): history loads from
  `fetchAllHistoryRecords` (one base64 payload per record); the Swift
  `HistoryDatabaseStore` is deleted (`Fetch/Support/HistoryStore.swift`).
- **Send previews for Solana, XRP, Stellar, Monero, Cardano, Sui, Aptos, TON,
  ICP, NEAR and Polkadot from one Rust call**
  (`Send/Layers/WalletSendPreviewLayer.swift`, `refreshSimpleChainSendPreview`,
  `fetchSimpleChainSendPreview`; before: separate fee-estimate and balance calls
  per chain).
- Unused bridge wrappers removed (`WalletRustAppCoreBridge.swift`: bootstrap,
  localized and static documents, state reducer, balance-refresh, balance-health
  and UTXO planners); Monero backend URL and API-key helpers removed
  (`Fetch/Services/MoneroBalance.swift`).
- The committed bindings do not yet export the history-record and simple-preview
  methods the bridge calls; Beta Commit 36 regenerates them.
- Total: 16 .swift files changed, +1103 −1518 lines; data and config files:
  `Derivation/Core/Generated/module.modulemap`,
  `Derivation/Core/Generated/spectra_coreFFI.h`,
  `Derivation/Core/Generated/spectra_coreFFI.modulemap`,
  `Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test functions
  unchanged at 67.

## Beta Commit 34

- **Token icons load from bundled PNG files instead of the asset catalog** (new
  `Views/Models/BundleImageLoader.swift`; `Views/Models/IconUIHelpers.swift`)
  - 56 token images move from `Resources/Assets.xcassets/<Name>.imageset/` to
    `Resources/TokenIcons/<Name>.png`; the asset catalog keeps only the app
    icon.
  - `BundleImageLoader` reads `Resources/TokenIcons/<name>.png` from the bundle,
    then `TokenIcons/<name>.png`; the artwork icon style draws from it.
- Total: 2 .swift files changed (1 new), +60 −1225 lines; data and config files:
  `Resources/Assets.xcassets/` (57), `Resources/TokenIcons/` (56); dependencies
  unchanged; test functions unchanged at 67.

## Beta Commit 33

- **Swift sources compacted by joining lines** (about 150 files across
  `Derivation/`, `Fetch/`, `ProviderCatalog/`, `Send/`, `Store/`, `Views/`,
  `Tests/` and the generated bindings)
  - Blank lines and most comments removed; modifier chains, closing braces and
    short declarations joined onto one line.
  - The joined text contains 675 `..modifier(` sequences (e.g.
    `Text(copy.heroTitle)..font(.title2.bold())` in
    `Views/Donations/DonationsView.swift`) and property declarations on one line
    without separators, which is not valid Swift; Beta Commit 36 reformats them.
- **Per-chain code paths folded into shared helpers**
  (`Store/App/WalletStore+SendFlow.swift`,
  `Send/Layers/WalletSendExecutionLayer.swift`, `WalletSendPreviewLayer.swift`,
  `SendMachineDriver.swift`, `Store/App/WalletStore+DiagnosticsEndpoints.swift`,
  `Store/AppState/StoreDiagnosticsExport.swift`)
  - Sends go through `submitUTXOSatChainSend`, `submitSeedPubKeyChainSend` and
    `submitDualKeyChainSend`; UTXO previews through
    `refreshUTXOSatChainPreview`.
  - Diagnostics use shared runners for EVM, UTXO-style and Rust-history chains
    and shared JSON exporters.
  - The per-chain user-facing send-error formatters (Aptos, Cardano, ICP,
    Monero, NEAR, Polkadot, Stellar, Sui, TON, XRP) are removed.
- **Balance updates go through a wallet state held in Rust**
  (`Store/App/WalletStore+BalanceRefresh.swift`,
  `Derivation/Core/WalletServiceBridge.swift`)
  - `applyRustBalance` sends each pushed balance to `updateNativeBalance` and
    merges the returned holding amounts; the per-chain `apply…Balance(s)`
    functions are replaced by `initialNativeHolding`, `mergeNativeHolding` and
    `applyEVMTokenHoldings`.
  - Imported wallets are upserted into the Rust state
    (`WalletStore+ReceiveFlow.swift`); keypool state and owned addresses are
    written to Rust SQLite as they change
    (`StorePersistenceNormalization.swift`).
- Tests: 0 new, 4 removed
  - Bitcoin balance 4 (`Tests/Balance/BitcoinBalanceTests.swift` deleted):
    Blockstream balance, deterministic stub failures, Mempool fallback,
    Blockchair transaction status.
- Total: 159 .swift files changed, +8243 −39437 lines; data and config files:
  `Derivation/Core/Generated/spectra_derivationFFI.h`; dependencies unchanged;
  test functions 71 → 67.

## Beta Commit 32

- **Balance refresh runs in a Rust engine that pushes results to the app** (new
  `Fetch/Support/WalletBalanceObserver.swift`;
  `Store/App/WalletStore+BalanceRefresh.swift`; generated
  `BalanceRefreshEngine`, `BalanceObserver`)
  - `setupRustRefreshEngine` registers the observer, hands the engine each
    wallet's chain and address, and starts a 30-second cycle.
  - `onBalanceUpdated` decodes the native amount per chain (sats, wei, lamports,
    drops, …) into the wallet's holdings; `onRefreshCycleComplete` clears the
    refreshing flag and records the time.
  - Every per-chain `refresh…Balances()` triggers an immediate Rust cycle; the
    Swift balance fetch layer is deleted (`WalletFetchBalanceRefresh.swift`,
    `WalletFetchRefreshScheduler.swift`, most of `WalletFetchLayer.swift`).
- **History pagination state kept in Rust**
  (`Store/AppState/StoreHistoryRefresh.swift`, `Store/App/WalletStore.swift`):
  the per-chain cursor, page and exhausted-wallet properties leave
  `WalletStore`; the setting changes that cleared them call
  `resetHistoryForChain`.
- **Seed import derives every chain's address in one Rust call**
  (`Store/App/WalletStore+ReceiveFlow.swift`,
  `WalletRustDerivationBridge.deriveAllAddresses`; before: one background
  derivation per chain).
- **Keypool state loads from Rust SQLite**
  (`Store/AppState/PersistenceStore.swift`): when present it replaces the
  Dogecoin and per-chain keypool maps.
- **Bitcoin engine and the UTXO balance services deleted**
  (`Send/Engines/BitcoinEngine.swift`,
  `Fetch/Services/BitcoinCashBalance.swift`, `BitcoinSVBalance.swift`,
  `DogecoinBalance.swift`, most of `LitecoinBalance.swift` and
  `BitcoinBalance.swift`, `Fetch/Support/UTXOEngineSupport.swift`);
  `applyBitcoinRuntimeConfiguration` removed.
- **Rust send state machine driver added** (new
  `Send/Layers/SendMachineDriver.swift`): wraps `SendStateMachine` and routes
  fee-preview and submit effects per chain family; nothing instantiates it.
- Tests: 0 new, 3 removed
  - Dogecoin balance 1 (BlockCypher payload) and Litecoin balance 2
    (litecoinspace response, BlockCypher fallback): their services were deleted.
- Total: 32 .swift files changed (3 new), +3444 −5915 lines; data and config
  files: `Derivation/Core/Generated/spectra_derivationFFI.h`; dependencies
  unchanged; test functions 74 → 71.

## Beta Commit 31

- **Tracked token balances for Sui, Aptos and TON fetched again**
  (`Fetch/Layers/WalletFetchBalanceRefresh.swift`, `fetchTokenBalancesJSON`):
  after the native balance, tracked coin types and jettons are fetched from Rust
  and non-zero balances join the holdings (before: these refreshes returned no
  token balances).
- **Keychain exposed to Rust** (new
  `Store/Security/SpectraSecretStoreAdapter.swift`): implements the generated
  `SecretStore` trait, routing `wallet.seed.*` keys to `SecureSeedStore`,
  `wallet.privatekey.*` to `SecurePrivateKeyStore` and others to `SecureStore`;
  `listKeys` returns nothing; registered with `WalletService` at app start.
- **Bridge gains Rust balance and history caches, a send state machine, and
  SQLite wallet-snapshot and app-settings storage**
  (`Derivation/Core/WalletServiceBridge.swift`); nothing calls them yet.
- **Remaining Swift provider clients deleted** (`ProviderCatalog/Providers/`:
  EVM explorer, Horizon, NEAR RPC, Rosetta, Sui RPC, XRPL) with
  `Send/Engines/UTXOChainPolicy.swift`; send preview types gathered in new
  `Send/Support/SendPreviewTypes.swift`, EVM types in new
  `Fetch/Services/EVMBalance.swift`.
- TON TonCenter v3 secondary endpoints are passed to Rust (chain ID offset 100).
- Total: 25 .swift files changed (3 new), +2133 −978 lines; data and config
  files: `Derivation/Core/Generated/spectra_derivationFFI.h`; dependencies
  unchanged; test functions unchanged at 74.

## Beta Commit 30

- **Swift send engines and balance clients deleted; chain networking and signing
  go through Rust** (`Send/Engines/`, `Fetch/Services/`)
  - Deleted engines: Aptos, Bitcoin Cash, Bitcoin SV, Cardano, Dogecoin,
    Ethereum (`EthereumEngine.swift`, `+Account`, `+History`, `+Send`), ICP,
    Litecoin, Monero, NEAR, Polkadot, Solana, Stellar, Sui, TON, Tron, XRP;
    `BitcoinEngine.swift` remains.
  - The balance services for Aptos, Bitcoin, Cardano, ICP, Monero, NEAR,
    Polkadot, Solana, Stellar, Sui, TON, Tron and XRP shrink to endpoint and
    diagnostics lists.
  - History for every chain comes from `fetchHistory`
    (`Store/AppState/StoreHistoryRefresh.swift`); endpoint diagnostics use
    `fetchBalance` and `fetchHistory`
    (`WalletStore+DiagnosticsEndpoints.swift`); UTXO transaction status from
    `fetchUtxoTxStatus`.
- **Built-in token list served by Rust** (`Resources/BuiltInTokenRegistry.json`
  deleted; `Views/Support/Localization/StaticContentCatalog.swift`,
  `listBuiltinTokensJson`).
- **Seed phrase checks in the import draft use Rust**
  (`Views/Models/ImportDraft.swift`): checksum validation, the BIP39 word list
  and generation go through `WalletServiceBridge`; word count and the
  `xpub`/`ypub`/`zpub` prefix are checked inline (before: `BitcoinWalletEngine`
  helpers).
- Tests: 0 new, 11 removed (balance-service tests whose services were deleted)
  - Cardano balance 3: stake-account balance, invalid address, alternate hash
    and timestamp fields.
  - Monero balance 2, Sui balance 2, XRP balance 2: primary source, fallback
    source, invalid address.
  - Solana balance 2: invalid address for balance and portfolio.
- Total: 59 .swift files changed, +2062 −20600 lines; data and config files:
  `Derivation/Core/Generated/spectra_derivationFFI.h`,
  `Resources/BuiltInTokenRegistry.json`; dependencies unchanged; test functions
  85 → 74.

## Beta Commit 29

- **Sends sign and broadcast in Rust**
  (`Send/Layers/WalletSendExecutionLayer.swift`,
  `WalletServiceBridge.signAndSend*`; generated `WalletService`)
  - Bitcoin, Bitcoin Cash, Bitcoin SV, Litecoin, Dogecoin, Tron, Solana, XRP,
    Stellar, Monero, Cardano, Sui, Aptos, TON, ICP, NEAR, Polkadot, and EVM
    sends of ETH, ETC, BNB and supported tokens on chains in the Rust chain
    table: Swift derives the key from the seed (or takes the imported private
    key), puts the private key hex into a JSON parameter string, and calls
    `signAndSend` or `signAndSendToken`.
  - The transaction hash is read from the returned JSON, which is stored as the
    signed payload with format `<chain>.rust_json`; post-send verification
    status is always `.verified`.
  - UTXO sends pass only amount and fee (Bitcoin: preview fee rate, default 10
    sat/vB; BCH and BSV: preview fee, default 0.00001; Litecoin: default
    0.0001); max input count, RBF and the Litecoin change strategy are no longer
    passed.
  - Chain-specific user-facing send errors are replaced by the error's
    description.
  - Bitcoin SV and BNB Chain join the Rust chain-ID table.
- **Send fee previews from Rust** (`Send/Layers/WalletSendPreviewLayer.swift`):
  UTXO previews from `fetchUtxoFeePreview` (a zero rate asks Rust for a live
  one), EVM previews from Rust with custom max and priority fees applied in
  Swift, the Bitcoin HD preview from the xpub balance and a fee estimate at a
  fixed 250 vB.
- **Prices and fiat rates fetched in Rust**
  (`Store/App/WalletStore+PricingFiat.swift`, `fetchPrices`, `fetchFiatRates`):
  the Swift `LivePriceService` (CoinGecko, Binance, Coinbase, CoinPaprika,
  CoinLore) and `FiatRateService` are deleted from
  `Views/Models/PricingModels.swift`.
- **Bitcoin HD balance through an xpub in Rust**
  (`Fetch/Layers/WalletFetchBalanceRefresh.swift`,
  `WalletStore+ReceiveFlow.swift`): the stored xpub, or one derived at
  `m/84'/0'/0'`, goes to `fetchBitcoinXpubBalance`; single-address
  Blockstream/Mempool lookup is the fallback.
- **EVM balances, token balances, history, receipts, nonces, contract code and
  ENS through Rust** (`WalletStore+BalanceRefresh.swift`,
  `StoreHistoryRefresh.swift`, `WalletStore+PendingTxPolling.swift`,
  `WalletStore+SendFlow.swift`, `WalletStore+DiagnosticsEndpoints.swift`).
- **Mnemonic generation and validation in Rust**
  (`Store/Security/SeedPhraseSafety.swift`, `generateMnemonic`,
  `validateMnemonic`); the file no longer imports WalletCore.
- **Live prices, token preferences, price alerts and the address book also
  written to Rust SQLite** (`Store/AppState/PersistenceStore.swift`,
  `Documents/spectra_state.db`): each `UserDefaults` write is mirrored, and
  after startup `reloadPersistedStateFromSQLite` replaces the in-memory values
  with the SQLite copies.
- EVM address and contract helpers and UTXO engine types moved into new files
  (`Send/Engines/EVM/EVMAddressUtils.swift`, `EVMContractUtils.swift`,
  `Send/Engines/UTXOEngineTypes.swift`).
- Total: 31 .swift files changed (3 new), +3455 −1398 lines; data and config
  files: `Derivation/Core/Generated/spectra_derivationFFI.h`,
  `Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test functions
  unchanged at 85.

## Beta Commit 28

- **Single-wallet balance refresh fetches through a Rust `WalletService`** (new
  `Derivation/Core/WalletServiceBridge.swift`;
  `Fetch/Layers/WalletFetchLayer.refreshWalletBalance`)
  - `WalletServiceBridge` is an actor owning one `WalletService`, configured
    from the endpoint catalog keyed by a fixed chain-ID table (`SpectraChainID`)
    that mirrors Rust's; it exposes balance, history, fee-estimate and
    sign-and-send calls.
  - Bitcoin Cash, Litecoin, Ethereum, Ethereum Classic, Arbitrum, Optimism,
    Avalanche, Tron, Solana, Cardano, XRP, Stellar, Monero, ICP, Polkadot, Sui,
    Aptos, TON and NEAR read the native balance from Rust's JSON in base units;
    Bitcoin SV, BNB Chain and Hyperliquid keep the Swift services.
  - On those chains this path returns no token balances (before: tracked ERC-20,
    TRC-20, SPL, Sui, Aptos, jetton and NEAR tokens).
  - The committed bindings do not yet export `WalletService`; they do from Beta
    Commit 29.
- **Owned-address aggregation, receive selection and self-send confirmation
  planned in Rust, Swift as fallback**
  (`Store/App/WalletStore+ImportLifecycle.swift`,
  `WalletStore+OperationalTelemetry.swift`; `coreAggregateOwnedAddressesJson`,
  `corePlanReceiveSelectionJson`, `corePlanSelfSendConfirmationJson`)
- Unused endpoint constants, `futureIntegrationHeadline` and
  `AppEndpointDirectory.records` removed
  (`Fetch/Support/ChainBackendRegistry.swift`,
  `ProviderCatalog/Registry/AppEndpointDirectory.swift`).
- Total: 11 .swift files changed (1 new), +792 −130 lines; data and config
  files: `Derivation/Core/Generated/spectra_derivationFFI.h`; dependencies
  unchanged; test functions unchanged at 85.

## Beta Commit 27

- **Address validation and normalization run in Rust**
  (`Send/Support/Addressing/AddressValidation.swift`, `coreValidateAddressJson`,
  `coreValidateStringIdentifierJson`): each `isValid…Address` sends the chain
  kind, value and network mode; the normalized EVM, Sui, Aptos, TON, ICP and
  NEAR forms come from the same call (`Store/App/WalletAddressResolver.swift`).
  Before: Swift prefix, alphabet and length checks, and engine validators for
  Bitcoin, Dogecoin and EVM.
- **Signing material built in Rust**
  (`Send/Support/SigningLegacy/SeedPhraseSigningMaterial.swift`,
  `WalletRustDerivationBridge.buildSigningMaterial`,
  `buildSigningMaterialFromPrivateKey`)
  - Address, private key, path, account, branch and index come back from Rust
    (before: `WalletDerivationEngine` plus Swift path parsing; private-key
    imports derived the address in Swift).
  - The C request structs and their Swift-side buffer zeroization are removed
    from `WalletRustDerivationBridge.swift`.
- **Endpoint reliability ordering and counters computed in Rust**
  (`Fetch/Support/Network/EndpointReliability.swift`,
  `coreOrderEndpointsByReliabilityJson`, `coreRecordEndpointAttemptJson`): the
  counters kept in `UserDefaults` change to `UInt32` counts and an `Int64`
  timestamp; when the call fails, candidates keep their given order and the
  attempt is not recorded.
- **Bitcoin history merged in Rust**
  (`Store/AppState/StoreHistoryRefresh.swift`,
  `coreMergeBitcoinHistorySnapshotsJson`): snapshots from several addresses are
  netted per txid there.
- **Balance-refresh health decided in Rust**
  (`Fetch/Layers/WalletFetchBalanceRefresh.swift`,
  `corePlanBalanceRefreshHealthJson`): healthy, degraded with detail text, and
  last-successful-sync come from attempted and resolved wallet counts, with the
  Swift rule as fallback; the separate Tron, Stellar and Polkadot sync notes are
  dropped.
- **Portfolio, price-request list and signing-material sets derived in Rust**
  (`Store/AppState/StorePersistenceNormalization.swift`,
  `corePlanStoreDerivedStateJson`)
  - Included holdings, unique price-request coins, grouped portfolio totals and
    the signing-material and private-key-backed wallet sets come from one plan.
  - The Swift transfer-availability fallback is removed: a failed Rust plan
    asserts in debug builds and yields no send or receive assets.
- **Chain catalog fallback lists removed**
  (`Fetch/Support/ChainBackendRegistry.swift`): a failed Rust load is a
  `preconditionFailure` again.
- The root `ContentView.swift` stub is deleted.
- Docs: `DerivationTestingFormat.md` rewritten for the UniFFI exports and JSON
  request and response payloads; `RustFFIPlan.md` boundary, safety and next
  steps; `VIEWS_STRUCTURE.md` location of `ContentView.swift`.
- Total: 15 .swift files changed, +872 −750 lines; data and config files:
  `Derivation/Core/Generated/spectra_derivationFFI.h`,
  `Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test functions
  unchanged at 85.

## Beta Commit 26

- **Rust core called through UniFFI-generated Swift bindings** (new
  `Derivation/Core/Generated/spectra_derivation.swift`,
  `spectra_derivationFFI.h`, modulemaps; `WalletRustDerivationBridge.swift`,
  `WalletRustAppCoreBridge.swift`,
  `ProviderCatalog/Core/WalletRustEndpointCatalogBridge.swift`)
  - The `@_silgen_name` C-ABI declarations and buffer structs are replaced by
    generated functions taking and returning JSON strings
    (`derivationDeriveJson`, `coreBootstrapJson`, `corePlanUtxoSpendJson`,
    `appCoreEndpointRecordsJson`, …); errors arrive as `SpectraBridgeError`.
  - The Xcode Rust build phase builds into `PROJECT_TEMP_DIR`, runs
    `uniffi-bindgen` into `Derivation/Core/Generated/` and patches the output
    for Swift 6 isolation; the project has one synchronized group per top-level
    folder.
- **`Localizable.xcstrings` and its sync tool deleted; views read strings
  through `AppLocalization`** (`Resources/Localization/`; `HistoryView.swift`,
  `DiagnosticsViews.swift`, `WalletSetupViews.swift`, `ContentView.swift`, …):
  `NSLocalizedString`, `String(localized:)` and literal `Text` keys switch to
  `AppLocalization.string`, and format strings use `AppLocalization.locale`.
- **`StaticContentCatalog` restored as a bundle-file loader**
  (`Views/Support/Localization/StaticContentCatalog.swift`): JSON and text
  resources resolve per preferred locale from the bundle; the Rust-served
  resource paths of Beta Commit 24 are not restored.
- **Chain catalog load failures fall back to built-in lists**
  (`Fetch/Support/ChainBackendRegistry.swift`): a failed Rust chain-backend,
  live-chain or app-chain load returns a Swift list of 24 chains (before:
  `preconditionFailure`).
- **`ContentView.swift` moved to `Views/App/`**; the root file keeps a comment
  pointing there.
- The `AddressValidation` validators are `nonisolated`.
- Docs: `LOCALIZATION_GUIDE.md` drops `Localizable.xcstrings` and the sync
  commands; short strings are edited in `RuntimeStrings.json`, longer copy in
  the per-locale JSON files.
- Total: 50 .swift files changed (2 new), +3184 −26286 lines; data and config
  files: `Derivation/Core/Generated/module.modulemap`,
  `Derivation/Core/Generated/spectra_derivationFFI.h`,
  `Derivation/Core/Generated/spectra_derivationFFI.modulemap`,
  `Resources/Localization/Localizable.xcstrings`,
  `Resources/Localization/Tools/sync_runtime_strings.py`,
  `Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test functions
  unchanged at 85.

## Beta Commit 25

- **Short UI strings come from a platform-neutral `RuntimeStrings.json`** (new
  `Resources/Localization/RuntimeStrings.json`,
  `Resources/Localization/Tools/sync_runtime_strings.py`;
  `Views/Support/Localization/AppLocalization.swift`)
  - `AppLocalization.string` looks a key up in the runtime catalog (preferred
    locales with fallbacks, then the source language) before the Apple bundles.
  - The catalog holds `en` (1,053 strings), `zh-Hans` and `zh-Hant` (1,104
    each), generated from `Localizable.xcstrings` by the sync script, which can
    also regenerate the Apple catalog from the JSON.
  - Supported locales include the catalog's; preferred languages also read
    `Locale.preferredLanguages`; the empty-localization fallback is `en`
    (before: `Base`).
- **Resources moved from `Views/Resources/` to `Resources/`** (asset catalog,
  localization, registries, BIP39 word list).
- **`StaticContentCatalog` loader removed**
  (`Views/Support/Localization/StaticContentCatalog.swift`): the enum that
  loaded bundled and Rust-served JSON and text resources, and the 325-entry
  `LocalizationCatalogReferenceKeeper` list, are deleted while the content
  structs in the same file and `ChainWikiViews.swift` still call it; Beta Commit
  26 re-adds it.
- Docs: `LOCALIZATION_GUIDE.md` moved to `Resources/Localization/`; short
  strings belong in `RuntimeStrings.json`; new "Platform Strategy" and "Sync
  Workflow" sections.
- Total: 2 .swift files changed, +28568 −25648 lines; data and config files:
  `Resources/Assets.xcassets/` (116), `Resources/Localization/` (32),
  `Resources/` (5), `Views/Resources/` (1); dependencies unchanged; test
  functions unchanged at 85.

## Beta Commit 24

- **App sources moved from `Spectra/` to the repository root** (`Derivation/`,
  `Fetch/`, `ProviderCatalog/`, `Send/`, `Store/`, `Tests/`, `Views/`,
  `ContentView.swift`; `Spectra.xcodeproj/project.pbxproj`); the docs place the
  Rust header at `Core/include/spectra_derivation.h` (before:
  `Spectra/Derivation/Rust/include/`).
- **UTXO coin selection and fee previews for Bitcoin Cash, Bitcoin SV, Litecoin
  and Dogecoin come from Rust** (`Send/Engines/*Engine.swift`,
  `WalletRustAppCoreBridge.planUTXOSpend`, `planUTXOPreview`)
  - Each engine sends its UTXO values, target, fee rate and fee policy (sat/vB
    with minimum absolute fee, or per-kB for Dogecoin; dust threshold, relay
    minimum, maximum standard size, 148/34/10-byte input, output and overhead
    sizes) and maps the returned indices back to its UTXOs.
  - Rust error codes (`utxo.insufficientFunds`, `utxo.amountBelowDustThreshold`,
    `utxo.feeBelowRelayPolicy`, `utxo.transactionTooLarge`,
    `utxo.changeBelowDustThreshold`) map to each engine's errors.
  - Swift `UTXOSpendPlanner.buildPlan`, `UTXOSatVBytePolicy` and its plan
    validation are deleted; `UTXOSpendPlan` remains as the result type and
    `UTXOKilobyteFeePolicy` keeps only rate adjustment and per-kB fee
    estimation.
- **Send routing and submit preflight decided in Rust**
  (`Send/Layers/WalletSendRoutingLayer.swift`, `WalletSendExecutionLayer.swift`;
  `planSendPreviewRouting`, `planSendSubmitPreflight`)
  - Which fee preview a selected asset uses comes from Rust (before: a Swift
    `switch` over chain and symbol).
  - Submit checks (wallet and asset found, destination present, amount parses,
    not negative, not above balance) and the normalized destination come from
    Rust; its error text becomes the send error.
  - The native EVM fee symbol and whether the asset is the native EVM coin come
    from the preflight plan (before: hard-coded per chain).
- **Refresh targets planned in Rust, Swift as fallback**
  (`Fetch/Layers/WalletFetchBalanceRefresh.swift`,
  `Store/AppState/StoreHistoryRefresh.swift`,
  `Fetch/Layers/WalletFetchLayer.swift`)
  - EVM balance and history refreshes pick wallets and group them by normalized
    address from `planEVMRefreshTargets`; Dogecoin refreshes pick wallets and
    addresses from `planDogecoinRefreshTargets`.
  - Single-wallet balance refresh routes by the `serviceKind` Rust returns
    (`bitcoinBulk`, `utxoSingleAddress`, `evmPortfolio`, `tronPortfolio`, …).
- **Send and receive availability per wallet from Rust, Swift as fallback**
  (`Store/AppState/StorePersistenceNormalization.swift`,
  `planTransferAvailability`)
- **Wallets also saved as a Rust persisted snapshot with a secret index**
  (`Store/AppState/PersistenceStore.swift`, `Store/App/WalletStore.swift`)
  - On save, the migrated core state and what the keychain holds per wallet
    (seed phrase, private key, password) are built into a snapshot stored under
    `walletsCoreSnapshotAccount`; the legacy `walletsAccount` blob is still
    written.
  - The snapshot's secret index (per-wallet keychain keys, signing-material,
    private-key-backed and password-protected wallet IDs) is cached on load and
    save; keychain lookups use its keys and fall back to the fixed account
    names.
  - Reset and deleting the last wallet delete the snapshot and clear the index.
- **Token, chain and buy-provider registries and the BIP39 word list load
  through Rust first** (`Views/Support/Localization/StaticContentCatalog.swift`,
  `staticDocumentData`, `staticText`); the bundled files stay as fallback.
- Docs: the seven docs moved out of `Spectra/`; `DerivationTestingFormat.md` and
  `RustFFIPlan.md` give the header path as `Core/include/spectra_derivation.h`.
- Total: 182 .swift files changed (3 new), +1543 −825 lines; data and config
  files: `Views/Resources/` (151), `Derivation/Catalog/` (2),
  `ProviderCatalog/Registry/` (1), `Spectra.xcodeproj/` (1), `Views/Extensions/`
  (1); dependencies unchanged; test functions unchanged at 85.

## Beta Commit 23

- **The endpoint catalog is a JSON file served through the Rust core** (new
  `Spectra/ProviderCatalog/Registry/AppEndpointDirectory.json` and
  `ProviderCatalog/Core/WalletRustEndpointCatalogBridge.swift`;
  `AppEndpointDirectory.swift`, `Fetch/Support/ChainBackendModels.swift`,
  `ChainBackendRegistry.swift`)
  - Endpoint records, settings groups, diagnostics probes, EVM RPC endpoints,
    explorer links, Bitcoin Esplora URLs, broadcast-provider options, chain
    backends and the live chain list come from `spectra_app_core_*_json` exports
    (before: Swift tables in those three files, which are deleted).
  - A failed catalog lookup stops the app (`preconditionFailure`).
- **Derivation presets, request-compilation presets, path resolution and
  per-preset path sets come from the Rust core**
  (`WalletRustAppCoreBridge.chainPresets`, `requestCompilationPresets`,
  `resolve`, `derivationPaths`; `Derivation/Catalog/Presets.swift`,
  `Views/Models/CoreModels.swift`); a catalog load failure is fatal.
- **Wallet import is planned by the Rust core**
  (`WalletRustAppCoreBridge.planWalletImport`; `WalletStore+ReceiveFlow.swift`
  −692): the planned wallets and secret instructions replace the Swift per-chain
  import code, and a planning error is shown as the import error.
- **Refresh planning, history normalization and transaction merging call the
  Rust core** (`Store/AppState/RefreshPlan.swift`, `Store+Formatting.swift`, new
  `StorePersistenceNormalization.swift`): active and background maintenance,
  chain and history refresh plans fall back to the Swift rules when the call
  fails; a failed merge yields no result.
- **Wallets are also saved as a Rust core snapshot** (`PersistenceStore.swift`,
  keychain account `wallets.core.snapshot.v1`): loading prefers the snapshot
  exported back to the `PersistedWalletStore` shape and falls back to the legacy
  payload.
- **Localized content documents are read from the Rust core first, then from the
  bundle** (`StaticContentCatalog.loadResource`; ChainWikiEntries,
  CommonContent, DiagnosticsContent, DonationsContent, EndpointsContent,
  ImportFlowContent, SettingsContent).
- **The new `Derivation/Core/WalletRustAppCoreBridge.swift` also declares
  bootstrap and state-reducer calls** that nothing calls yet; the Rust
  `target/debug` library search paths are removed from the Xcode project.
- Total: 15 .swift files changed (2 new), +3917 −1556 lines; data and config
  files: `Spectra.xcodeproj/project.pbxproj`,
  `Spectra/ProviderCatalog/Registry/AppEndpointDirectory.json`; dependencies
  unchanged; test functions unchanged at 85.

## Beta Commit 22

- **Home shows one wallet card at a time in a swipeable pager**
  (`Views/Dashboard/DashboardViews.swift`): "Wallet N of M", previous and next
  buttons, and page dots.
- **Adding a wallet opens a page with three choices: Create New Wallet, Import
  Wallet, Watch Addresses** (new `Views/WalletFlow/AddWalletEntryView.swift`;
  before: a menu on Home).
- **A custom seed-phrase word count from 1 to 48 can be entered**
  (`ImportDraft.applyCustomSeedPhraseWordCount`, `seedPhraseLengthWarning`;
  `WalletSetupViews.swift`): fewer than 12 words or a non-BIP-39 length shows a
  warning, and generating a new phrase is disabled for a non-standard length.
- **Per-chain derivation request settings moved from Swift switches to a JSON
  catalog** (new `Derivation/Catalog/DerivationRequestCompilationPresets.json`,
  `WalletDerivationRequestCompilationPreset`;
  `WalletRustDerivationBridge.swift`): derivation algorithm, address algorithm,
  public-key format and script type per chain, with Bitcoin's script chosen by
  path purpose (44, 49, 84, 86); a missing or invalid catalog is fatal.
- **Tests and views grouped into subfolders** (`Tests/Balance/`, `Networking/`,
  `Diagnostics/`, `Planning/`, `Store/`, `Docs/`; `Views/ChainWiki/`,
  `Diagnostics/`, `Donations/`, `Endpoints/`, `Staking/`); behaviour unchanged.
- Docs: new `Spectra/Tests/TESTS_STRUCTURE.md` and
  `Spectra/Views/VIEWS_STRUCTURE.md` (folder maps); `TESTING_WORKFLOW.md` moved
  to `Spectra/Tests/Docs/`.
- Total: 25 .swift files changed (1 new), +605 −153 lines; data and config
  files: `Spectra.xcodeproj/project.pbxproj`,
  `Spectra/Derivation/Catalog/DerivationRequestCompilationPresets.json`;
  dependencies unchanged; test functions unchanged at 85.

## Beta Commit 21

- **Six tests deleted, and the Xcode project's leftover references to
  `TronBalanceTests.swift` removed** (`BitcoinBalanceTests.swift`,
  `CardanoBalanceTests.swift`, `NetworkClientTests.swift`).
- **The two Rust bridge calls share one response handler**
  (`WalletRustDerivationBridge.withRustResponse`,
  `WalletDerivationQuery(request:)`); behaviour unchanged.
- Tests: 0 new, 6 removed
  - Bitcoin balance 1 (Blockchair dashboard), Cardano 2 (Koios balance,
    stake-account history), Stellar import selection 1, and derivation with a
    curve the chain does not use 2 lose their coverage.
- Total: 7 .swift files changed, +50 −164 lines; data and config files:
  `Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test functions 91
  → 85.

## Beta Commit 20

- **Provider clients moved from `Spectra/Fetch/Providers/` to
  `Spectra/ProviderCatalog/Providers/`**; behaviour unchanged.
- **`Spectra/Tests/TronBalanceTests.swift` deleted.**
- Tests: 0 new, 12 removed
  - Tron balance and history 12: TRX parsing and fallbacks across TronScan and
    TronGrid, token balances, and send classification for hex addresses lose
    their coverage.
- Total: 18 .swift files changed, +0 −337 lines; data and config files: none;
  dependencies unchanged; test functions 103 → 91.

## Beta Commit 19

- **Derivation presets are a JSON catalog** (new
  `Derivation/Catalog/DerivationPresets.json`; `Presets.swift` −300): per chain
  the curve, the networks and the derivation paths with their defaults (Bitcoin:
  mainnet, testnet, testnet4, signet; Taproot, Native SegWit as default, Nested
  SegWit, Legacy, Electrum Legacy, BIP32 Legacy).
- **The Rust bridge always sends the chain's catalog curve**
  (`WalletRustDerivationBridge`); the caller's curve is ignored.
- **Wallet setup starts with a choice of "Simple Setup" or "Advanced Setup"**
  (`Views/WalletFlow/WalletSetupViews.swift`, `SetupPage.setupModeChoice`):
  Simple hides the Advanced page with derivation paths and networks; editing a
  wallet skips the choice.
- Total: 6 .swift files changed, +379 −300 lines; data and config files:
  `Spectra/Derivation/Catalog/DerivationPresets.json`; dependencies unchanged;
  test functions unchanged at 103.

## Beta Commit 18

- **Private-key imports derive their address through the Rust core** (new FFI
  call `spectra_derivation_derive_from_private_key`,
  `WalletRustDerivationBridge.deriveFromPrivateKey`; used by
  `SeedPhraseAddressDerivation` and `UTXOAddressCodec`; before: WalletCore
  `PrivateKey` and `CoinType`); the key buffer is zeroized after the call.
- **Address validation no longer consults WalletCore**
  (`AddressValidation.swift`): the `CoinType.validate` checks are removed,
  leaving Spectra's own per-chain rules.
- **Address and legacy signing helpers moved from `Derivation/` to
  `Send/Support/Addressing/` and `Send/Support/SigningLegacy/`**
  (`WalletAddressValidation.swift` → `AddressValidation.swift`,
  `ChainSeedPhraseAddressDerivation.swift` →
  `SeedPhraseAddressDerivation.swift`).
- Docs: `DerivationChecklist.md`, `DerivationTestingFormat.md` and
  `RustFFIPlan.md` moved back from `Derivation/Docs/` to `Spectra/Derivation/`.
- Total: 6 .swift files changed, +158 −158 lines; data and config files:
  `Spectra.xcodeproj/project.pbxproj`,
  `Spectra/Views/Resources/Localization/Localizable.xcstrings`; dependencies
  unchanged; test functions unchanged at 103.

## Beta Commit 17

- **`WalletStore.swift` split into `Store/App/WalletStore.swift` and area
  extensions; behaviour unchanged** (`+BalanceRefresh`, `+DiagnosticsEndpoints`,
  `+ImportLifecycle`, `+OperationalTelemetry`, `+PendingTxPolling`,
  `+PricingFiat`, `+ReceiveFlow`, `+SendFlow`): store state files moved from
  `Views/Support/Store/` to `Store/AppState/`, secure storage and
  `SeedPhraseSafety` to `Store/Security/`, and
  `Views/App/WalletDerivationLayer.swift` became
  `Store/App/WalletAddressResolver.swift`.
- **`Derivation/` split into `Catalog/`, `Core/`, `Docs/` and `Legacy/`**, with
  a new `Core/WalletDerivationLayer.swift` facade over `WalletDerivationEngine`
  (request, JSON data and JSON string forms); Fetch and Send layer files moved
  under `Layers/`.
- **Derivation tests follow the Rust-backed engine**
  (`NetworkClientTests.swift`): a key request with a curve the chain does not
  use is now expected to fail, an address request with one only to throw, the
  JSON request names the chain and passes an explicit iteration count, and
  presets are checked through `WalletDerivationPresetCatalog` path and network
  lists.
- Docs: `DerivationChecklist.md`, `DerivationTestingFormat.md` and
  `RustFFIPlan.md` moved to `Spectra/Derivation/Docs/`.
- Total: 63 .swift files changed (10 new), +13616 −13546 lines; data and config
  files: none; dependencies unchanged; test functions unchanged at 103.

## Beta Commit 16

- **Xcode builds and links the Rust derivation core** (`project.pbxproj`: a
  "Build Rust Derivation Core" script phase producing `libspectra_derivation.a`
  for simulator and device under `.rust-build/`, plus library search paths and
  linker flags).
- **Seed-phrase addresses and signing keys derive through the Rust core for
  every chain** (`SeedPhraseSigningMaterial`, `ChainSeedPhraseAddressDerivation`
  call `WalletDerivationEngine`;
  `Derivation/WalletCore/WalletCoreDerivationSupport.swift` deleted): FFI chain
  ids go from 3 to all 22 seed chains (`WalletRustFFIChain`); private-key
  imports and address validation still use WalletCore.
- **Derivation path helpers moved to new `Derivation/DerivationSupport.swift`**
  (`WalletDerivationPath`, `WalletDerivationBranch`); address inventory and
  validation moved to `Derivation/Addresses/`, `PrivateKeyHex.swift` to
  `Derivation/SeedPhrase/`.
- **`.gitignore` added** (Xcode user data, SwiftPM build output and
  `Package.resolved`, Rust `target/` and `.rust-build/`, logs, `.env`, key
  files).
- Docs: `RustFFIPlan.md` rewritten as current status (engine derives via Rust
  for all chains, linked by a build phase, WalletCore removal remaining,
  guardrails); new `DerivationTestingFormat.md` (C request and response structs
  and ids at the FFI boundary).
- Total: 12 .swift files changed (1 new), +828 −568 lines; data and config
  files: `.gitignore`, `Spectra.xcodeproj/project.pbxproj`; dependencies
  unchanged; test functions unchanged at 103.

## Beta Commit 15

- **`WalletDerivationEngine` derives through the Rust core** (`deriveViaRust`;
  `WalletRustDerivationBridge.derive` calls `spectra_derivation_derive` and
  frees the reply with `spectra_derivation_response_free`): the WalletCore path
  inside the engine is removed, and a Rust error surfaces as `rustCoreFailed`.
  - The request carries passphrase, PBKDF2 iteration count and HMAC key string;
    the seed phrase and other secret buffers are zeroized after the call.
- Docs: `RustFFIPlan.md` "not done yet" (WalletCore path removed from the
  engine; Xcode linking still pending).
- Total: 2 .swift files changed, +178 −273 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 103.

## Beta Commit 14

- **Seed-phrase derivation goes through one request-based engine** (new
  `Derivation/WalletDerivationEngine.swift`, running on WalletCore): a request
  names chain, network (mainnet, testnet, testnet4, signet), derivation path,
  curve, passphrase and the outputs wanted (address, public key, private key),
  and has a JSON form.
  - Address and signing-key derivation moved out of each engine into
    `Derivation/SeedPhrase/ChainSeedPhraseAddressDerivation.swift` and
    `SeedPhraseSigningMaterial.swift`, and seed-phrase checks from
    `BitcoinWalletEngine` into `SeedPhraseSafety.swift`; the store derives
    addresses off the main thread (`deriveSeedPhraseAddressInBackground`).
  - An address request with a curve the chain does not use is refused
    (`unsupportedAddressCurve`); keys for another curve can still be derived.
- **Swift side of a C ABI to a Rust derivation core** (new
  `Derivation/WalletRustDerivationBridge.swift`): frozen numeric ids for chain
  (Bitcoin, Ethereum, Solana), network, curve, outputs, derivation and address
  algorithms, public-key format and script type; nothing calls it, and per
  `RustFFIPlan.md` the Rust core is Bitcoin-only and not linked.
- **Derivation presets moved from `Views/Models/CoreModels.swift` to
  `Derivation/Presets.swift`**, with per-chain API presets (network, path,
  curve); `UTXOAddressCodec.swift` moved to `Derivation/Addresses/`.
- Tests: 7 new
  - Derivation engine 7: outputs beyond those requested returned (Bitcoin
    testnet4); Solana signing material missing; keys for a custom curve not
    derived, or an address for it not refused; the JSON request ignoring a
    custom path or curve; Bitcoin testnet4 native-SegWit and Solana legacy
    presets missing.
- Docs: `AGENTS.md` deleted; new `Spectra/Derivation/RustFFIPlan.md` (frozen ABI
  ids, scope, next steps) and `DerivationChecklist.md` (the inputs that fix
  mnemonic → seed → key → address).
- Total: 37 .swift files changed (7 new), +3122 −690 lines; data and config
  files: `Spectra.xcodeproj/project.pbxproj`; dependencies unchanged; test
  functions 96 → 103.

## Beta Commit 13

- **Source tree split into `Derivation/`, `Fetch/`, `Send/`, `ProviderCatalog/`
  and `Views/`; behaviour unchanged**
  - Fetch, send and address-resolution code moved out of `WalletStore.swift`
    (21,505 → 13,251 lines) into `Fetch/WalletFetchBalanceRefresh.swift`,
    `WalletFetchLayer.swift`, `WalletFetchRefreshScheduler.swift`,
    `Send/WalletSendExecutionLayer.swift`, `WalletSendPreviewLayer.swift`,
    `WalletSendRoutingLayer.swift`, `WalletSendLayer.swift` and
    `Derivation/WalletDerivationLayer.swift`.
  - Engines moved to `Send/Engines/`; balance services, providers, diagnostics
    and network support to `Fetch/`; address codec, validation and derivation
    helpers to `Derivation/`; `WalletStore`, models, resources, live activity
    and UI support to `Views/`.
  - New `ProviderCatalog/ChainProviderCatalog.swift` filters
    `AppEndpointDirectory` records by role (broadcast, read, explorer).
- Docs: `LOCALIZATION_GUIDE.md` moved to
  `Spectra/Views/Resources/Localization/`.
- Total: 131 .swift files changed (16 new), +14799 −14915 lines; data and config
  files: `Spectra/Views/` (152), `Spectra.xcodeproj/` (1); dependencies
  unchanged; test functions unchanged at 96.

## Beta Commit 12

- **Store and backend files reorganized; behaviour unchanged**:
  `AppEndpointDirectory.swift` moved to `Providers/Registry/`;
  `ChainBackends.swift` split into `ChainBackendRegistry.swift` and
  `ChainBackendModels.swift`; `ContentCatalog.swift` split into
  `StaticContentCatalog.swift` and `AppLocalization.swift`; `ChainRefresh.swift`
  into `ChainRefreshDescriptors.swift` and `ChainRefreshRouter.swift`;
  `MaintenanceStore`, `RuntimeStore` and `SendStore` into
  `MaintenanceIntervals`, `ReceiveFlowStore`, `RuntimeSendPreparationStore`,
  `SendExecutionStore` and `SendPreviewStore`.
- Total: 16 .swift files changed (8 new), +1378 −1357 lines; data and config
  files: none; dependencies unchanged; test functions unchanged at 96.

## Beta Commit 11

- **Settings endpoint lists and diagnostics reachability probes come from
  `AppEndpointDirectory`** (`settingsEndpoints(for:)`,
  `diagnosticsChecks(for:)`), replacing each provider's own list for Aptos,
  Stellar, NEAR, Polkadot, ICP, Solana, Sui, TON, Bitcoin Cash, Bitcoin SV, XRP,
  Cardano, Dogecoin, Litecoin and Tron.
- **`DogecoinEngine+Account`, `+Codec`, `+Network` and `+Send.swift` merged back
  into `DogecoinEngine.swift`**; behaviour unchanged.
- Total: 22 .swift files changed, +645 −699 lines; data and config files: none;
  dependencies unchanged; test functions unchanged at 96.

## Beta Commit 10

- **Chain HTTP clients moved into one module per provider** (new
  `Spectra/Providers/`: Esplora, BlockCypher, EVM explorer, Ethereum JSON-RPC,
  Solana RPC, Sui RPC, Aptos RPC, TONCenter, NEAR RPC, Polkadot, Rosetta for
  ICP, XRPL, Horizon for Stellar, Edge LWS for Monero, Bitcoin Cash and Bitcoin
  SV multi-source, and a shared `ProviderHTTP`); balance services and engines
  call them.
- **One endpoint directory lists every endpoint with its roles** (new
  `Support/AppEndpointDirectory.swift`): read, balance, history, UTXO, fee,
  broadcast, verification, RPC, explorer or backend, with settings visibility
  and a probe URL per record.
- **UTXO spend planning and relay policy are shared by Litecoin, Bitcoin Cash,
  Bitcoin SV and Dogecoin** (new `Engines/UTXOSpendPlanner.swift`,
  `UTXOChainPolicy.swift`, `UTXOAddressCodec.swift`): one coin selection and
  size estimate, sat/vB and per-kB fee policies, and change below the dust
  threshold refused.
- **Dogecoin reads balances, history, status, fee rates and UTXOs from
  BlockCypher alone** (`DogecoinBalance.swift`, `DogecoinEngine+Network.swift`;
  before: Blockchair, BlockCypher and Dogechain, reconciled across providers);
  Blockchair is dropped from Dogecoin's broadcast providers.
- **Dogecoin network choice (mainnet, testnet) is back on the import "Advanced"
  page**, the testnet served by BlockCypher; Endpoints settings list Dogecoin
  endpoints by network.
- Tests: 2 new, 5 removed
  - Dogecoin balance: the BlockCypher payload test replaces the Dogechain one;
    the Dogechain → BlockCypher fallback test is removed.
  - In-app Dogecoin self-tests: a single-provider configuration check added; the
    three multi-provider reconciliation checks removed.
- Total: 77 .swift files changed (21 new), +4220 −3976 lines; data and config
  files: `Spectra/Resources/Localization/Localizable.xcstrings`; dependencies
  unchanged; test functions 99 → 96.

## Beta Commit 9

- **Send fees come from live sources or the preview fails; the fixed fallbacks
  are removed**
  - Bitcoin: no 2/5/10 sat/vB fallback when Esplora estimates are missing.
  - Bitcoin Cash: fee rate from Blockchair stats or ActorForth; Bitcoin SV: from
    WhatsOnChain chain info or Blockchair stats (before: fixed 1 sat/vB).
  - Cardano: fee from the current epoch's parameters (before: 0.2 ADA); ICP:
    from Rosetta construction metadata (before: 10,000 e8s); Solana: current
    lamports fee from RPC (before: 0.000005 SOL); Tron: TRX and TRC-20 fees from
    chain parameters (before: fixed TRX fee, energy price and bandwidth fee).
  - TON: the send preview always fails with "TON live fee estimation is
    unavailable with the current endpoint setup." (before: 0.005 TON).
- **Each wallet stores its own Bitcoin network**
  (`ImportedWallet.bitcoinNetworkMode`, persisted with a mainnet default;
  `BitcoinWalletEngine` derives and signs for the wallet's network); testnet4
  assets are not priced.
- **Dogecoin testnet removed again** (network choice, testnet Electrs reads and
  broadcast; `DogecoinBalance.swift` −394), along with Dogecoin
  provider-reliability ordering.
- **Diagnostics drop the broadcast-reliability section and the history-source
  confidence score** (`DiagnosticsViews.swift`; `historySourceConfidenceText`,
  `sourceConfidenceTag`, `sourceConfidenceScore` removed); the page is renamed
  "History Sources".
- Tests: 3 new
  - Bitcoin network per wallet 3: a testnet4 import not persisting its derived
    address; a wallet titled with the global rather than its own network;
    testnet4 assets getting a price.
- Total: 38 .swift files changed, +1207 −1669 lines; data and config files:
  `Spectra/Resources/Localization/Base/DiagnosticsContent.json`,
  `Spectra/Resources/Localization/Localizable.xcstrings`,
  `Spectra/Resources/Localization/en/DiagnosticsContent.en.json`; dependencies
  unchanged; test functions 96 → 99.

## Beta Commit 8

- **Wallet import has an "Advanced" page again, with network choice and
  derivation paths** (`WalletSetupViews.swift`, `ImportFlowContent.json`
  `advancedTitle`): Bitcoin network (mainnet, testnet, testnet4, signet),
  Ethereum network (mainnet, Sepolia, Hoodi), Dogecoin network (mainnet,
  testnet) and the per-chain path editor with presets; import uses the chosen
  preset and paths (before: defaults only).
- **Ethereum Sepolia and Hoodi** (`EthereumNetworkMode`,
  `EVMChainContext.ethereumSepolia` and `.ethereumHoodi`, chain ids 11155111 and
  560048, PublicNode RPCs; history through Etherscan v2 with the chain id),
  stored under `ethereum.network.mode`.
- **Bitcoin testnet4** (`BitcoinNetworkMode.testnet4`,
  `mempool.space/testnet4/api`).
- **Dogecoin testnet reads balance, history and status from a testnet Electrs
  server** (`DogecoinBalanceService.configureRuntime`,
  `doge-electrs-testnet-demo.qed.me`).
- **Wallet detail, asset rows and diagnostics titles show the selected network**
  (`WalletStore.displayNetworkName`, `displayChainTitle`); Endpoints settings
  list Bitcoin, Ethereum and Dogecoin endpoints grouped by network.
- **A Bitcoin wallet's address is derived from its seed for the selected network
  and stored at import** (`resolvedBitcoinAddress`; before: `nextReceiveAddress`
  under a throwaway wallet id).
- **NEAR broadcast verification asks the RPC `tx` method** (`NearEngine`, three
  attempts across endpoints; before: searched recent history).
- **`DogecoinEngine.swift` split into `+Account`, `+Codec`, `+Network` and
  `+Send`; test files drop `Service`** (`BitcoinBalanceServiceTests.swift` →
  `BitcoinBalanceTests.swift`, `WalletStorePlatformBridgeTests.swift` →
  `WalletStoreTests.swift`).
- Tests: 5 new
  - Wallet store 5: a Bitcoin import not persisting its derived address; Bitcoin
    or Ethereum network names not following the selected mode; testnet4
    endpoints missing; Sepolia or Hoodi contexts and endpoints wrong.
- Total: 50 .swift files changed (4 new), +2568 −1343 lines; data and config
  files: `Spectra.xcodeproj/project.pbxproj`,
  `Spectra/Resources/Localization/Base/ImportFlowContent.json`,
  `Spectra/Resources/Localization/Localizable.xcstrings`,
  `Spectra/Resources/Localization/en/ImportFlowContent.en.json`,
  `Spectra/Resources/Localization/zh-Hans/ImportFlowContent.zh-Hans.json`,
  `Spectra/Resources/Localization/zh-Hant/ImportFlowContent.zh-Hant.json`;
  dependencies unchanged; test functions 91 → 96.

## Beta Commit 7

- **Editing a wallet only renames it** (`WalletStore.renameWallet`,
  `ImportDraft.configureForEditing`; "Edit Wallet" → "Edit Name"): addresses,
  watch addresses, derivation paths and secrets are no longer re-entered or
  re-derived on edit.
- **Wallet import uses the default derivation paths; the "Advanced" derivation
  page and path editor are removed** (`WalletSetupViews.swift`,
  `SeedPathSlotEditor`, `ImportDraft.applyDerivationPreset`); the Solana wiki
  entry no longer offers the `m/44'/501'/0'` legacy path.
- **History shows 10 rows per page and loads more only for the wallets on the
  current page** (`HistoryView.prefetchHistoryIfNeeded`,
  `loadMoreOnChainHistory(for:)`; before: 20 rows, all wallets), with a one-row
  pager.
  - The per-chain history page-size steppers in Settings are removed
    (`bitcoinHistoryFetchLimit` … `moneroHistoryFetchLimit`); UTXO-chain
    refreshes fetch 20 entries per request (`HistoryPaging.endpointBatchSize`).
- The string catalog is written back in Xcode's formatting (3 keys added).
- Tests: 1 new
  - Wallet rename 1: a rename dropping the wallet's holdings.
- Total: 11 .swift files changed, +16587 −16927 lines; data and config files:
  `Spectra/Resources/` (9); dependencies unchanged; test functions 90 → 91.

## Beta Commit 6

- **Files renamed to shorter names; behaviour unchanged**: engines drop `Wallet`
  (`BitcoinWalletEngine.swift` → `BitcoinEngine.swift`), services drop `Service`
  (`BitcoinBalanceService.swift` → `BitcoinBalance.swift`), models and store
  files drop the `Wallet` and `WalletStore` prefixes (`WalletCoreModels.swift` →
  `CoreModels.swift`, `WalletStoreSendCoordinator.swift` → `SendStore.swift`,
  `WalletRefreshPlanner.swift` → `RefreshPlan.swift`); formatting and
  notification code moved out of `WalletStore.swift` into
  `Support/Store/Store+Formatting.swift` and `Store+Notifications.swift`.
- **Tron history tells sends from receipts by comparing base58 and hex forms of
  the addresses** (`TronBalance.swift`, `tronAddressComparisonKeys`; before:
  lowercased strings, so rows whose raw data carries hex `41…` addresses matched
  neither side).
- **The chain wiki can be filtered by tag** (`ChainWikiViews.swift`; `tags`
  added to every entry in `ChainWikiEntries.json`: UTXO, EVM, L2, Move, PoW,
  PoS, Privacy, Payments and others).
- **Every string-catalog entry has Simplified and Traditional Chinese** (57
  translations added per locale, 1,120 keys); the catalog file is reformatted.
- Tests: 1 new
  - Tron history 1: an outgoing TRX transfer with hex addresses in its raw data
    not classified as a send.
- Total: 84 .swift files changed (2 new), +17560 −16539 lines; data and config
  files: `Spectra.xcodeproj/project.pbxproj`,
  `Spectra/Resources/Localization/Base/ChainWikiEntries.json`,
  `Spectra/Resources/Localization/Localizable.xcstrings`,
  `Spectra/Resources/Localization/en/ChainWikiEntries.en.json`,
  `Spectra/Resources/Localization/zh-Hans/ChainWikiEntries.zh-Hans.json`,
  `Spectra/Resources/Localization/zh-Hant/ChainWikiEntries.zh-Hant.json`;
  dependencies unchanged; test functions 89 → 90.

## Beta Commit 5

- **Sends go only through the broadcast providers enabled for the chain**
  (`providerIDs` passed into the sends of Bitcoin, Bitcoin Cash, Bitcoin SV,
  Litecoin, Tron, Solana, Cardano, XRP, Stellar, Monero, Sui, Aptos and NEAR;
  Dogecoin through `synchronizeDogecoinBroadcastProviderSelection`), and the
  provider lists grow (`ChainBackends.swift`): Solana Mainnet and Ankr RPC;
  Koios, Xray and HappyStake Koios; Ripple S1, S2 and XRPL Cluster; Stellar and
  LOBSTR Horizon; three Edge Monero LWS servers; five Sui, three Aptos and three
  NEAR RPCs.
- **Dogecoin's own provider switches and event log are folded into the per-chain
  ones** (`WalletStore`, `DogecoinBalanceService`): the Blockchair/BlockCypher
  broadcast and status toggles, `dogecoinOperationalEvents` and
  `checkProviderHealth` are removed; status reads use Blockchair, then
  BlockCypher.
- **Status retry from History works for all UTXO chains**
  (`retryUTXOTransactionStatus` replaces `retryDogecoinTransactionStatus`;
  offered for Bitcoin, Bitcoin Cash, Bitcoin SV, Litecoin and Dogecoin).
- **Diagnostics gain self-tests and a rescan for Bitcoin, Bitcoin Cash, Bitcoin
  SV and Litecoin** (new `BitcoinSVSelfTestSuite`; `runBitcoinRescan` and
  siblings refresh balances, at least 40 history entries and pending sends,
  logging start and end).
- **The TRX balance fallbacks to TronScan staked resources, TronScan token
  overview and TronGrid wallet RPC are removed** (`TronBalanceService`); the
  token-row fallback stays.
- **Strings built from computed keys are registered in the catalog**
  (`StaticContentCatalog.swift` +233), with 688 lines of catalog changes.
- Total: 26 .swift files changed, +1656 −1338 lines; data and config files:
  `Spectra/Resources/Localization/Localizable.xcstrings`; dependencies
  unchanged; test functions unchanged at 89.

## Beta Commit 4

- **Pending-send tracking, owned-address bookkeeping and rebroadcast work on
  every chain** (before: Dogecoin only; `WalletStore.swift`)
  - Pending sends are polled on every chain (`refreshPendingTronTransactions` …
    `refreshPendingPolkadotTransactions`, `TransactionStatusTrackingState`),
    with per-chain finality confirmations, back-off after a failed poll, and
    stale pending sends marked failed.
  - The signed payload and its format are stored on the transaction record
    (`signedTransactionPayload`, `signedTransactionPayloadFormat`), and any
    chain's send can be rebroadcast from it (`rebroadcastSignedTransaction`).
  - Broadcast errors are classified as already broadcast, retryable or terminal
    (`SendBroadcastFailureDisposition`).
  - Receive and change indexes are reserved per wallet and chain
    (`ChainKeypoolState`), owned addresses are recorded
    (`ChainOwnedAddressRecord`), and UTXO chains scan for used addresses
    (`refreshUTXOAddressDiscovery`); both are persisted.
  - Per-chain operational events are recorded, and diagnostics show them with
    the keypool state ("Owned Address Management", "Operational Events").
- **Fee priority (economy, normal, priority) is stored per chain**
  (`ChainFeePriorityOption`, `setFeePriorityOption`); Bitcoin and Litecoin apply
  it to fee estimation, other chains only store it.
- **Broadcast providers can be chosen per chain in Settings**
  (`ChainBackendRegistry.broadcastProviderOptions`, `setBroadcastProvider`; at
  least one stays enabled), with per-provider success counts.
- **RPC endpoints are tried in order of their recorded success rate** (new
  `Support/Network/ChainEndpointReliability.swift`, UserDefaults
  `chain.endpoint.reliability.<namespace>.v1`) for the EVM chains, Solana, Sui,
  Aptos, TON, NEAR, Polkadot, Tron, XRP, Cardano, Stellar and ICP; Bitcoin
  Esplora endpoints and Litecoin providers get their own success counters.
- **Send previews show fees and limits for more chains** (`SendPreviewDetails`,
  `SendFlowViews.swift`): estimated network fee for Solana, Sui, Aptos, TON and
  Monero, gas parameters, sequence number and nonce, and a "Preview Details"
  block (spendable balance, fee rate, size, inputs, change output, max
  sendable).
- **Sends that break relay policy are refused before broadcast**
  (`validatePolicyRules`): Bitcoin below the 546-sat dust threshold or above
  100,000 vbytes; Litecoin below dust, below 1 sat/vB or oversize; a Solana
  transaction above 1,232 bytes.
- **More UTXO providers**: Bitcoin Cash falls back from Blockchair to ActorForth
  REST, Bitcoin SV from WhatsOnChain to Blockchair, Bitcoin adds Maestro
  Esplora, and Litecoin broadcasts through LitecoinSpace or BlockCypher and
  caches UTXOs (`BitcoinCashBalanceService`, `BitcoinSVBalanceService`,
  `LitecoinWalletEngine`, `ChainBackends.swift`).
- **The Tron TRX balance is read from more TronScan and TronGrid response
  shapes** (`TronBalanceService`): string balances, token rows, staked
  resources, token overview and the TronGrid wallet RPC; TronGrid is preferred
  when TronScan returns zero TRX.
- **Each engine can list its derived addresses** (new
  `Engines/WalletAddressInventoryEngines.swift`, `WalletAddressInventory`); the
  store does not call it yet.
- Tests: 9 new
  - Tron balance 9: a TRX balance missed when TronScan returns it as a string,
    only in token rows, as staked resources, in the token overview or already in
    decimal, or when TronGrid returns it as a string or only through the wallet
    account; TronScan's zero preferred over TronGrid's balance.
- Total: 48 .swift files changed (2 new), +9404 −1737 lines; data and config
  files: `Spectra/Resources/Localization/Localizable.xcstrings`; dependencies
  unchanged; test functions 80 → 89.

## Beta Commit 3

- **Bitcoin SV reads and broadcasts through WhatsOnChain**
  (`BitcoinSVBalanceService.swift`, `BitcoinSVWalletEngine.swift`,
  `ChainBackends.swift`; before: Blockchair): balance, history, UTXOs,
  transaction lookup and raw-transaction broadcast use
  `api.whatsonchain.com/v1/bsv/main`.
- **An account the network does not know yet reads as a zero balance** instead
  of a refresh error: NEAR `unknown_account`, Polkadot and Stellar HTTP 404, XRP
  missing account, Tron empty account rows; Stellar history for such an account
  is empty.
- **Solana SPL token balances try the next RPC endpoint when one fails or
  returns nothing** (`SolanaBalanceService`); the last error is thrown only when
  all fail.
- **Chain and market-data requests send `Accept: application/json` and
  `User-Agent: Spectra`** (Bitcoin, Polkadot, Stellar, Tron and XRP services;
  `WalletPricingModels.fetchMarketData`).
- **CoinLore prices match by coin id before symbol; CoinPaprika ids corrected
  for BSV, XRP and DOT** (`WalletPricingModels.swift`).
- **New derivation presets: Bitcoin Cash "Legacy" `m/44'/0'/0'/0/0`, Tron
  "Simple BIP44" `m/44'/195'/0'`, XRP "Standard" and "Simple BIP44"
  `m/44'/144'/0'`** (`WalletCoreModels.swift`); the import path editor lists
  each chain's presets.
- **Pull to refresh on a wallet refreshes only that wallet**
  (`WalletStore.refreshWalletBalance`, `WalletDetailView`).
- **Bitcoin SV gets history and endpoint-reachability diagnostics**
  (`runBitcoinSVHistoryDiagnostics`, `StandardDiagnosticsChain.bitcoinSV`).
- **Screens observe only the store properties they display** (new
  `Support/Store/ViewRefreshSignal.swift`): settings, send, receive, wallet
  detail, transaction detail and diagnostics views hold the store unobserved and
  subscribe to chosen publishers or sub-states.
- **Transaction status, import mode and other enum titles are localized**
  (`localizedTitle`), with 167 lines of new catalog entries.
- **Monero donation address filled in** (`DonationsContent.json`, all locales).
- Tests: 4 new, 1 removed
  - Derivation presets 4: Tron and XRP "Simple BIP44" paths missing from the
    preset list or not resolving to the legacy flavor (replaces the Tron
    Ethereum-style-path test).
- Total: 33 .swift files changed (1 new), +2164 −744 lines; data and config
  files: `Spectra/Resources/Localization/Base/DonationsContent.json`,
  `Spectra/Resources/Localization/Localizable.xcstrings`,
  `Spectra/Resources/Localization/en/DonationsContent.en.json`,
  `Spectra/Resources/Localization/zh-Hans/DonationsContent.zh-Hans.json`,
  `Spectra/Resources/Localization/zh-Hant/DonationsContent.zh-Hant.json`;
  dependencies unchanged; test functions 77 → 80.

## Beta Commit 2

- **`WalletStore` state and logic split into per-area coordinators and
  observable state objects; behaviour unchanged** (new
  `Support/Diagnostics/WalletChainDiagnosticsState.swift`,
  `Support/Store/WalletSendState.swift`,
  `WalletStoreMaintenanceCoordinator.swift`, `WalletStoreSendCoordinator.swift`;
  `WalletStoreDiagnosticsCoordinator.swift` +755).
- **Engine and balance-service errors use shared message templates**
  (`CommonLocalization`, new `CommonContent.json` in Base, en, zh-Hans and
  zh-Hant): per-chain strings such as "The Aptos address is not valid." come
  from one "The %@ address is not valid." template.
- **A degraded-chain banner stores only the failure detail; the "last good sync"
  suffix is added when shown** (`WalletDiagnosticsState.degradedSyncSuffix`,
  `DiagnosticsContent.json`).
- **Chain sync state and operational logs are written to UserDefaults after a
  short delay** (0.15 s and 0.35 s) instead of on every change.
- **Dashboard, history, send and receive screens build their row text into
  presentation structs** (`HistoryRowPresentation`,
  `DashboardAssetRowPresentation`, `PrimaryPresentation`,
  `ReceiveView.Presentation`); display unchanged.
- Docs: new `Spectra/Resources/Localization/LOCALIZATION_GUIDE.md` (string
  catalog versus feature JSON, canonical chain and token names, review
  checklist) and `LocalizationGlossary.json`.
- Total: 57 .swift files changed (4 new), +3159 −1343 lines; data and config
  files: `Spectra/Resources/` (10); dependencies unchanged; test functions
  unchanged at 77.

## Beta Commit 1

- **Large files split by concern; behaviour unchanged**: `WalletModels.swift`
  into `WalletCoreModels`, `WalletPersistenceModels`, `WalletPricingModels`,
  `WalletRegistryModels` and `WalletIconUIHelpers`; `EthereumWalletEngine.swift`
  into `Engines/EVM/` (`+Account`, `+History`, `+Send`); `WalletFlowViews.swift`
  into `Views/WalletFlow/` (setup, send, receive, flow); dashboard and settings
  components split out; `Support/` regrouped into `Diagnostics/`, `Store/` and
  `Localization/`; the "File Overview" headers and per-function boilerplate
  comments deleted.
- **Chains are keyed by a registry id** (new `WalletChainID` in
  `WalletRegistryModels.swift`, resolving a display name, id or symbol to the
  `ChainRegistryEntry` id): the refresh planner, refresh coordinator,
  pending-transaction maintenance and diagnostics use it, and the planner takes
  `now` explicitly.
  - Stored chain sync state (`chain.sync.state.v1`) is keyed by registry id
    instead of display name.
- **Chain-degraded banners and their log entries are localized**
  (`WalletDiagnosticsState.localizedDegradedMessage`; 232 catalog lines).
- **Versioned JSON snapshot export of wallets, addresses, holdings,
  transactions, address book and live prices** (new
  `Support/Interop/PlatformSnapshotModels.swift`,
  `WalletStorePlatformBridge.swift`; `exportPlatformSnapshotJSON`, schema 1); no
  screen calls it.
- Tests: 11 new
  - Diagnostics state 4: a degraded banner not persisted, recovery not clearing
    it or not logged, logs not trimmed or not capped at 800, the export missing
    its header or metadata.
  - Refresh planner 5: pending or price refresh run when not due, background
    maintenance without network or before its interval, forced, pending or
    degraded chains left out, fresh history refreshed.
  - Platform bridge 2: `WalletChainID` not resolving names and symbols to the
    registry id; the snapshot envelope's shape changing.
- Total: 94 .swift files changed (21 new), +12365 −13126 lines; data and config
  files: `Spectra/Resources/Localization/Localizable.xcstrings`; dependencies
  unchanged; test functions 66 → 77.

## Initial Commit

- **A self-custodial multi-chain wallet for iOS in SwiftUI with 24 networks**
  (`Spectra/Engines/`, `Spectra/Services/`, `Support/ChainBackends.swift`):
  Bitcoin, Bitcoin Cash, Bitcoin SV, Litecoin, Dogecoin, Ethereum, Ethereum
  Classic, Arbitrum, Optimism, BNB Chain, Avalanche, Hyperliquid, Tron, Solana,
  Stellar, XRP Ledger, Monero, Cardano, Sui, Aptos, TON, Internet Computer, NEAR
  and Polkadot, each marked live for seed import, balance refresh, receive and
  send.
  - One engine (derive, sign, broadcast) and one balance service (balance,
    history, provider fallback) per chain; Bitcoin signs with BitcoinDevKit, the
    others with WalletCore, and Monero sends go through a user-configured
    backend.
  - Tokens are tracked on the EVM chains, Tron, Solana, Sui, Aptos, TON and NEAR
    from an 84-entry `BuiltInTokenRegistry.json`, and custom tokens can be
    added.
- **Wallets are created, imported from a seed phrase or private key, or added
  watch-only** (`Views/WalletFlowViews.swift`,
  `Models/WalletImportDraft.swift`): 12–24-word BIP-39 phrases with backup
  verification on create, an optional wallet password, per-chain watch addresses
  (Bitcoin also by xpub), and derivation presets including legacy and
  Electrum-legacy paths (`SeedDerivationChain`).
- **Five tabs: Home, History, Staking, Donate, Settings**
  (`App/ContentView.swift`, `Views/`)
  - Home: portfolio total, wallet cards, assets grouped across chains, pinned
    assets and notices; wallet detail with send and receive (QR code, address
    book).
  - History: on-chain history per wallet kept in a local SQLite store
    (`Support/HistoryDatabaseStore.swift`), paginated, with transaction detail
    and Dogecoin status retry and rebroadcast.
  - Send: fee preview per chain; Bitcoin and Dogecoin fee priority; EVM custom
    fees, manual nonce, and speed-up or cancel of a pending send; RBF and CPFP
    switches; a Live Activity tracks a broadcast send
    (`SpectraLiveActivityExtension/`).
  - Staking is a "coming soon" page; Donate lists donation addresses.
- **Settings**: prices from CoinGecko, Binance, Coinbase, CoinPaprika or
  CoinLore and fiat rates from four providers in 12 currencies; price alerts,
  large-movement alerts and transaction-status notifications; Face ID app lock
  and biometric confirmation for sends; hidden balances; background-sync profile
  and refresh interval; decimal display; endpoint and API-key settings (Ethereum
  RPC, Etherscan, Monero backend, Esplora); token registry; a buy-crypto help
  page linking external on-ramps; logs; wallet reset.
- **Diagnostics hub** (`Views/DiagnosticsViews.swift`,
  `Support/ChainSelfTestSuites.swift`): per-chain endpoint reachability,
  history-source confidence, in-app self-tests for Dogecoin and Ethereum,
  operational-log export and a diagnostics bundle.
- **Seed phrases are stored AES-GCM-sealed in the Keychain**
  (`Support/SecureStores.swift`, `whenPasscodeSetThisDeviceOnly`), with a
  verifier for wallet passwords.
- **A 24-entry chain wiki and UI copy in English, Simplified Chinese and
  Traditional Chinese** (`Resources/Localization/`: `Localizable.xcstrings` plus
  per-feature JSON content).
- Tests: 66 new
  - Chain balance services 26 (Bitcoin 5, Cardano 5, Solana 4; Dogecoin,
    Litecoin, Monero, Sui, Tron and XRP 2 each): a provider payload misparsed,
    no fallback to the next provider, or the wrong error when all fail.
  - Network client and chain setup 22 (`TestSpectraNetworkClientTests.swift`):
    replay queues not deterministic or not isolated by HTTP method; Ethereum
    Classic, Avalanche, Hyperliquid, Aptos, Stellar or ICP imports not producing
    their native coin or missing a wiki entry; NEAR history misparsed; Tron and
    Bitcoin Cash legacy paths missing or resolving to the wrong flavor.
  - Secure seed store 5: a seed not round-tripping or stored as plaintext; the
    password verifier not saved or not cleared.
  - Diagnostics bundle 1: the bundle schema or environment fields changing.
  - In-app self-tests 12 (Dogecoin and Ethereum, run from Diagnostics): address
    validation, multi-provider reconciliation, receive-address normalization,
    seed derivation, transfer pagination.
- Docs: `README.md` (ethos, what Spectra is and is not, security philosophy);
  `AGENTS.md` (ask before applying a change app-wide);
  `Spectra/Tests/TESTING_WORKFLOW.md` (replay-client unit tests, happy, fallback
  and failure paths per chain service, build and test gates).
- Total: 89 .swift files changed (89 new), +95486 −0 lines; data and config
  files: `Spectra/Assets.xcassets/` (116), `Spectra/Resources/` (30),
  `Spectra.xcodeproj/project.xcworkspace/` (2),
  `Spectra.xcodeproj/xcshareddata/` (2), `Spectra.xcodeproj/` (1),
  `Spectra.xctestplan`, `Spectra/SpectraLiveActivityExtension/` (1);
  dependencies: added bdk-swift 2.3.1, bigint 5.7.0, keychainaccess 4.2.2,
  secp256k1.swift 0.1.7, solana-swift 5.0.0, task-retrying-swift 2.0.0,
  tweetnacl-swiftwrap 1.1.0, wallet-core 4.6.0 (SwiftPM,
  `Spectra.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`);
  test functions 0 → 66.
