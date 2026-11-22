# Spectra for iOS and macOS

Spectra is a prelaunch, multi-chain self-custodial crypto wallet focused on
custody, payments, recovery and staking. It aims to be approachable for everyday
use while exposing the network settings, diagnostics and logs advanced users need.

## Product direction

- Local-first, privacy-conscious software that keeps users in control of their
  keys and wallet data.
- Consistent send, receive, history and backup flows across chains.
- Broad import and recovery support, including legacy wallet conventions and
  watch-only wallets.
- Configurable endpoints and providers, exportable diagnostics, and clear
  transaction verification states.
- Biometric protection, optional wallet passwords, customizable dashboards and
  staking where chain support makes sense.

Spectra does not aim to become a trading terminal or a swap-first product;
custody and payments take priority over speculative features and purchase
upsells.

## Development

This repository is the native SwiftUI app for iOS and macOS. The Rust wallet
core it runs on is [spectra](https://github.com/lacklusteradmin/spectra),
cloned beside this repository. Core owns domain state and decisions; the app
renders its results and forwards user intent.

- [AGENTS.md](AGENTS.md): the rules for working in this repository. It loads
  `../Spectra/AGENTS.md` too, Rule 0 first. Read first.
- [iOS UI](docs/IOS-UI.md): layout, typography and Liquid Glass rules, and
  what the Mac does differently.
- [Swift bindings](docs/SWIFT-BINDINGS.md): the core package the app links,
  and how `make core` builds it.
- [Open items](docs/OPEN-ITEMS.md): remaining app work. Core's are in
  `../Spectra/docs/OPEN-ITEMS.md`.
- [Scripts](scripts/README.md): the tools behind the Makefile.

### Building

Clone both repositories side by side, the core as `Spectra`:

```sh
git clone https://github.com/lacklusteradmin/spectra.git Spectra
git clone https://github.com/lacklusteradmin/spectra-apple.git SpectraApple
```

The app builds against `../Spectra`; to use another core checkout, pass
`SPECTRA=<path>` to `make`, relative to this repository's root. Then build the
core package:

```sh
make core
```

It compiles the Rust core in `../Spectra` for the iPhone, the arm64 simulator
and the Mac, and writes `swift/SpectraCore/`: a local Swift package of the static
libraries and the Swift bindings generated from them, which the app links.
Xcode compiles no Rust, so run `make core` again after changing core. It needs
a Rust toolchain; core's `rust-toolchain.toml` pins it, so `cargo` installs the
right one on first use. The package is **not** checked in; never hand-edit it.
A Release build needs `make core PROFILE=release`.
[Swift bindings](docs/SWIFT-BINDINGS.md) has the rest.

Open `swift/Spectra.xcodeproj`, pick an iPhone or My Mac as the destination and
build: one target and one set of sources make both apps. Simulators and Macs
are arm64 only.

The Mac app is sandboxed and keeps its secrets in the data protection keychain,
which macOS opens only to an app signed with its keychain access group. Xcode's
automatic signing does that with a Mac development profile for the team; an
unsigned or ad-hoc build runs, and is refused the Keychain.

### Verification

Four targets gate a change, each run by name; [AGENTS.md](AGENTS.md#verification)
says which a change needs:

| Target | What it runs |
|---|---|
| `make lint` | the source scans, which read the core checkout |
| `make check-ui` | the design-token check |
| `make test-ios` | `xcodebuild test` on an iPhone simulator |
| `make test-mac` | `xcodebuild test` on this Mac, the app signed for its Keychain |

`test-ios` and `test-mac` need Xcode. Core's own targets run in its checkout:
`make -C ../Spectra lint`, and so on.

## License

Spectra is free software under the [GNU General Public License v3.0](LICENSE).
It comes with no warranty. A wallet you cannot inspect is a wallet you are
trusting on someone else's word, so the terms that keep modified versions open
are part of the point rather than an afterthought.
