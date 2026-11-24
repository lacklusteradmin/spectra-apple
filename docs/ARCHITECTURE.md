# Architecture

How the app's Swift is put together. What core owns and decides, and the
boundary every front end keeps to, is spectra's `docs/ARCHITECTURE.md`; how
the app links core is [SWIFT-BINDINGS.md](SWIFT-BINDINGS.md), and how a page
looks is [IOS-UI.md](IOS-UI.md).

## One app for iOS and macOS

The Mac app is the iOS app's sources built for macOS: one target, and every
page and flow the same view. A file splits on `#if os(macOS)` only where the
platform itself differs — AppKit's text views, the camera, the pasteboard, the
window that covers a locked app — and a page names the platform only through
the helpers in `PlatformChrome.swift`. A Mac has no Live Activity, so a send
there is followed by its notification alone. What the Mac draws differently is
in [IOS-UI.md](IOS-UI.md#macos).

## AppState and its domains

`AppState` is the app's `@MainActor @Observable` store: the wallet, portfolio
and transaction projections, and the composition root for the domains. It
composes one `@MainActor @Observable` object per domain: the send and receive
flows, wallet import, the address book, token preferences, price alerts, Tor,
history paging, diagnostics and the platform's own preferences. Each holds
that domain's projection or view state — form inputs, loading and error state,
request identities, reset behaviour — and the actions that need nothing else;
views read the object, and no forwarding copies of its fields live on
`AppState`.

A projection of core state (contacts, tokens, alerts) has one writer, its
`adopt`, fed by `AppState.applyCoreState`, and its edits are commands through
the shared `StateCommandQueue`. What needs the wallet projection or several
domains — the selected send holding, a wallet's signing requirement,
post-broadcast work — stays a thin adapter in an `AppState+<Domain>.swift`
extension.

Import and rename completions may update only the session that submitted
them. Dismissal invalidates the session and clears secret inputs; a core
commit still refreshes the domain projection even when its form is gone.

## Sends

The composer's requests — recipient resolution, quotes, core's progress for a
staged send — start in `SendFlowState` when what they depend on changes; its
views only render. `SendSession` owns only workflow identity, in-flight state
and displayed results: an obsolete callback cannot update another session or
start signing after native authentication.

A closed composer rejects stale form updates but still returns a successful
broadcast to application handling, and post-send work resolves the completed
transaction by its ID, not by the current composer. A Live Activity reads its
send by the stored ID and tells a missing record from a read failure: a
failure keeps the activity for the next try, a missing record ends it.

## Presentation

`AmountPresentation` renders explicit projection values without `AppState` or
storage; its native formatter cache is presentation-only.
`AssetPresentationCatalog` indexes core's immutable artwork and colours by
deployment id; balances and display labels do not identify assets. Neither can
authorize a domain mutation. `CoreReferenceTables` holds the process-lifetime
copies of core's compile-time tables — the wikis, the staking entries, the
input bounds, the endpoint catalog and the donation addresses — read once.

Every word on screen comes from `AppLocalization`, keyed by its English
sentence or, for long copy, a dotted name such as `settings.aboutTitle`. A
sentence with values is `AppLocalization.format`, never `String(format:)`, so
its numbers follow the reader's locale. A view or component takes finished
text and its caller localizes: nothing is looked up twice, and a node's own
message is never read as a key.

## Keeping the shell thin

- Swift code that reads core-owned data only to send it back for a decision is
  a misplaced rule: make the owning service compute the answer instead. Audit
  views and record extensions too, not only `AppState`.
- Keep one writer per UI projection. Adopt core-derived answers
  asynchronously; local indexes and button-enabling checks may remain view
  state, with core enforcing validation on writes.
- Delete projection and cache fields when their last reader disappears.
- Keep concrete network, token and deployment identities distinct; never infer
  identity from a ticker or a price provider's id.
- Remove a dead wrapper only after checking direct FFI callers and foreign
  callback implementations. Delete tests of a removed helper only once the
  replacement's meaningful coverage is identified.
- An export that removes a Swift rule can be worthwhile; moving code only to
  lower a line count is not.
