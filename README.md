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
core it runs on is [spectra](https://github.com/lacklusteradmin/spectra), which
the app links as a package built there. Core owns domain state and decisions;
the app renders its results and forwards user intent.

- [AGENTS.md](AGENTS.md): the rules for working in this repository, with
  spectra's `AGENTS.md`, Rule 0 first. Read first.
- [iOS UI](docs/IOS-UI.md): layout, typography and Liquid Glass rules, and
  what the Mac does differently.
- [Swift bindings](docs/SWIFT-BINDINGS.md): the core package the app links,
  and how to build it.
- [Open items](docs/OPEN-ITEMS.md): remaining app work. Core's are in
  spectra's `docs/OPEN-ITEMS.md`.
- [Scripts](scripts/README.md): the tools behind the Makefile.

### Building

The app links the core package that
[spectra](https://github.com/lacklusteradmin/spectra) builds. Clone spectra
anywhere and, in that checkout, build it:

```sh
make apple
```

It compiles the Rust core for the iPhone, the arm64 simulator and the Mac, and
writes `target/SpectraCore/`: a local Swift package of the static libraries and
the Swift bindings generated from them. It needs the current stable Rust;
`rustup update` keeps it current.

Copy `target/SpectraCore/` to the root of this repository, keeping its
modification times: drag it in Finder, or

```sh
cp -Rp <spectra>/target/SpectraCore .
```

replacing any copy already here. A copy with new times works, but makes Xcode
recompile every Swift file. Xcode compiles no Rust, so rebuild and copy the
package again after changing core. The package is **not** checked in; never
hand-edit it. A Release build needs `make apple PROFILE=release`.
[Swift bindings](docs/SWIFT-BINDINGS.md) has the rest.

Open `Spectra.xcodeproj`, pick an iPhone or My Mac as the destination and
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
| `make lint SPECTRA=<spectra>` | the source scans, which read that core checkout |
| `make check-ui` | the design-token check |
| `make test-ios` | `xcodebuild test` on an iPhone simulator |
| `make test-mac` | `xcodebuild test` on this Mac, the app signed for its Keychain |

`test-ios` and `test-mac` need Xcode. Core's own targets run in its checkout:
`make -C <spectra> lint`, and so on.

## License

Spectra is free software under the [GNU General Public License v3.0](LICENSE).
It comes with no warranty. A wallet you cannot inspect is a wallet you are
trusting on someone else's word, so the terms that keep modified versions open
are part of the point rather than an afterthought.
