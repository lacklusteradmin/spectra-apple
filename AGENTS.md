## Git

Do not git commit or push unless I said so. Before a commit, tidy the
CHANGELOG as [CHANGELOG](#changelog) says.

## Repositories

This repository is the iOS and macOS app. The Rust core and the CLI are the
`spectra` repository. Its `AGENTS.md` applies here too: read it before a
change that touches core or what the app shows of it. Rule 0, the architecture
rules and Funds and keys there apply to everything here.

- The app links `SpectraCore/`, a package spectra's `make apple` builds into
  its `target/SpectraCore/`. Copy that directory here with its modification
  times — drag it in Finder, or `cp -Rp` or `ditto` — and Xcode compiles no
  Rust. A plain `cp -R` works too, but new times make Xcode recompile every
  Swift file.
- Nothing here assumes where a spectra checkout is. What reads core's source
  takes it as `SPECTRA`, absolute or relative to this repository's root:
  `make lint SPECTRA=<path>`, and the icon export. Each refuses without it.
- Nothing here records which core commit the package came from. Land a core
  change in spectra, pushed, before the app change that needs it.

## Docs

Read the one that covers what you are changing:

| Doc | Covers |
|---|---|
| [IOS-UI.md](docs/IOS-UI.md) | Liquid Glass, typography, color, layout and corner radii, and what the Mac app does differently |
| [SWIFT-BINDINGS.md](docs/SWIFT-BINDINGS.md) | The core package the app links, and its Swift bindings |
| [OPEN-ITEMS.md](docs/OPEN-ITEMS.md) | Remaining app work |
| [CHANGELOG.md](docs/CHANGELOG.md) | What each commit changed, and why |
| [scripts/README.md](scripts/README.md) | Source-scan and icon-export tools |
| spectra's `docs/` | Core's architecture, chain support, FFI boundary and open items |

Keep them true:

- A change that alters what a doc says updates that doc in the same change: a
  script in `scripts/README.md`, a design rule in `IOS-UI.md`.
- A doc states what is true now, and names a file or symbol only while it
  exists. History belongs in `CHANGELOG.md` and git.
- `OPEN-ITEMS.md` holds remaining work only. Delete an item when it is done.

## CHANGELOG

[CHANGELOG.md](docs/CHANGELOG.md) records what each commit changed and why,
newest first. Record a change under `## Uncommitted` as it is made. A section
written before the split covers only this repository's part of that commit;
spectra keeps its own for core.

**Tidy it before a commit.** When I am about to commit, or ask for the
CHANGELOG to be tidied, check `## Uncommitted` against the actual change
(`git diff`). Every sub-item matches one change in the diff: delete one that
does not, which is usually an unchanged part, the whole picture after the
change, or process. Add what the diff has and the entries lack. Numbers match
the code, and no claim goes beyond what was done. Then rename the heading to
the commit's title, such as `## Beta Commit 253`.

How to write it:

- **Voice.** An objective record. Do not address the reader, and write no
  asides. A decision for me goes in the conversation or in `OPEN-ITEMS.md`.
- **The result, not the process.** Write what the changed part is now, with
  the before or the reason in one parenthesised sentence when it helps. No
  process ("first … then", "found … so", "tried …", debugging), and no whole
  picture after the change: the docs hold that, so point there in a few words.
- **One sub-item per change.** Each change is a bullet whose bold headline
  states the result, with where in parentheses (views, files, types). Under
  it, one sub-item per change, in one or two sentences. A change is one thing
  `git diff` shows: a behaviour, a screen or control, a number or default, a
  file that moved, whether stored data still loads. A change with only one
  such thing is the headline alone, with no sub-items.
- **No padding.** Leave out unchanged parts, unless a reader would think they
  changed; per-item visual detail, which `IOS-UI.md` and the code hold; lists
  of functions and call sites; mechanical edits such as an added property, a
  rename or a rebuilt `SpectraCore/`; anything that repeats the headline. A
  refactor that keeps behaviour is one line naming what moved where.
- **Names as they were.** A section names files and symbols as they were at
  that commit, even after they move or go.
- **Each section ends with these, in order, when they apply:**
  - `Measured:` one line per run: date, device or simulator, result, key
    numbers only, before → after.
  - `Tests: N new`: one line per area, "area N: what it guards against". Not
    what each test checks. An existing test that was only updated is left out
    unless what it guards changed.
  - `Docs:` which doc, and which sections.
  - `Total:` always, last: N .swift files changed (M new), +X −Y lines; data,
    resource and config files by name or grouped by folder, or none; tests
    passing in `make test-ios` before → after. "No code changed" when the
    change is docs alone.

## Verification

Match verification to the scope and risk of the change, and report which checks
actually ran.

| Change | Run |
|---|---|
| Docs, copy, resources | Only what the edit can affect |
| Swift views, design tokens, icons | `make check-ui`, plus the target covering any logic touched |
| A localized code change | The target that covers it |
| Broad refactors, FFI and cross-platform changes, or a core change the app depends on | All four targets, and core's own for what changed in the core checkout, unless I say otherwise |

The four targets are `make lint`, `check-ui`, `test-ios` and `test-mac`: the
source scans, which read the core checkout `SPECTRA` names; the design-token check;
and `xcodebuild test` on an iPhone simulator and on this Mac. No target runs
them all: each is run by name. The Makefile holds the exact commands.
`test-mac` needs the Mac app signed with its keychain access group (Xcode's
automatic signing, with a Mac development profile for the team): its Keychain
tests use the real data protection keychain. When another task is building the
same Xcode project, give yours its own directory with
`make test-ios IOS_TEST_DERIVED_DATA=<dir>`. Core's targets run in its
checkout: `make -C <spectra> lint`, and so on.

No test is expected to fail. Treat a failure as real even when it looks
unrelated to the change, and report it; do not write it off as flaky or
pre-existing without evidence.

## Platform constraints

- Check APIs, syntax and generated bindings against **UniFFI 0.31.2 and Swift 6**
  before changing FFI or Swift code. See [SWIFT-BINDINGS.md](docs/SWIFT-BINDINGS.md)
  and spectra's `docs/FFI-BOUNDARY.md`.
- Never hand-edit `SpectraCore/`. Change the Rust API in the core
  checkout and rebuild and copy the package. A Swift file that uses core says `import SpectraCore`.
- [docs/IOS-UI.md](docs/IOS-UI.md) is the authority for Liquid Glass,
  typography, color, layout and corner radii.
- The app targets **iOS 26** and **macOS 26** (the deployment targets in the
  Xcode project) from one target and one set of sources, in the **Swift 6**
  language mode. A view names a platform through the helpers in
  `PlatformChrome.swift`; `#if os(macOS)` belongs where the platform itself
  differs (AppKit views, the camera, the pasteboard), not in a page's layout.
  A change to shared Swift is built for both: `make ios` and `make mac`. Write for that floor with the current idiom:
  no `#available` checks or fallbacks for older releases, `@Observable` rather
  than `ObservableObject`/`@Published`, `NavigationStack` rather than
  `NavigationView`, and async/await rather than completion handlers or GCD
  unless an API requires a queue. If an iOS 26 API is unfamiliar, check
  Apple's current documentation rather than falling back to an older pattern.
- Resolve Swift 6 concurrency diagnostics with correct isolation. Do not add
  `@unchecked Sendable`, `nonisolated(unsafe)` or `@preconcurrency` to silence
  one unless the preceding line explains why it is sound.

## Swift conventions

- `Task` closures in `AppState` and its extensions capture `[weak self]` unless
  the preceding line explains why the task must keep the state alive.
- Pure transformations belong in core or free functions; `AppState` methods
  are thin adapters. Constructing `AppState` pulls in SQLite, Keychain and Rust.
- `app/` holds every app source, grouped by feature: `App/` (the
  `AppState` core, lifecycle and platform services), `Models/` (extensions of
  core records and the catalogs built from them), `Components/` (shared views
  and design tokens), then one folder per feature — `Dashboard/`, `Wallets/`
  (with `Tools/`), `Send/`, `Receive/`, `History/`, `Staking/`, `Settings/`,
  `Diagnostics/`, `Wiki/` — with a feature's state beside its views. The
  folder is an Xcode synchronized group: adding or moving a file under it needs
  no project edit, and file names stay unique across the module. The Live
  Activity extension is in `extensions/`, the tests in `tests/`.
- Name an extension file `<Type>+<Topic>.swift` (`AppState+SendFlow.swift`,
  `SendFlowState+Preview.swift`), a file of free functions or of extensions
  across several types after its topic, and any other file after its type.
  Split growing topics into siblings rather than moving code into unrelated
  files.
- Do not build an observation loop from `withObservationTracking` and
  `withCheckedContinuation`: cancellation does not resume the continuation and
  can retain `self`. Debounce a reaction with a stored, cancellable `Task`
  around `Task.sleep`, as `SendFlowState.scheduleRecipientResolution` does.
- Tests use Swift Testing (`@Test`, `#expect`, `#require`), not XCTest. Tests
  run in parallel, and `.serialized` orders only a suite's own tests, not that
  suite against the others. A test touching process-wide state (the Keychain,
  the network runtime, windows) must stay correct alongside every other suite;
  tests that contend for it belong in one `.serialized` suite. A test that needs
  an `AppState` uses `@Suite(.isolatedAppState)` and conforms to
  `IsolatedAppStateSuite`.

## Resources

`resources/` is the app target's synchronized group, and Xcode copies such a
group in **flat**: every file under it lands at the bundle's resource root,
whatever directory it sat in. `resources/strings/RuntimeStrings.en.json` ships
as `RuntimeStrings.en.json`. Two rules follow:

- **Nothing but a runtime resource belongs here.** Anything under `resources/`
  ships, read or not. Build-time inputs go elsewhere — icon sources in
  `icons/`, the translator glossary in `docs/LocalizationGlossary.json`.
- **A file name must be unique across the whole tree.** A directory such as
  `strings/` groups files for people and scripts; it does not separate them in
  the bundle. Put the locale in the name (`RuntimeStrings.zh-Hans.json`):
  per-locale subdirectories with one shared name would silently overwrite each
  other.

## Icons

Never edit `Assets.xcassets/` by hand: `scripts/export-swift-icons.sh`
generates its icons from two sources.

- `icons/appicon/` holds the 1024-point app icon sources. They export as
  1024×1024 PNGs to `AppIcon.appiconset`; keep that destination name. Exporting
  them needs ImageMagick (`brew install imagemagick`).
- The crypto icons are core's library in spectra's `icons/crypto/`, with its
  rules in spectra's `AGENTS.md`. They export to the matching `crypto` asset
  group, without a namespace.

After editing either, export:

```sh
SPECTRA=<spectra checkout> scripts/export-swift-icons.sh
```
