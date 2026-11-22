# Spectra for iOS and macOS

[![CI](https://github.com/lacklusteradmin/spectra-apple/actions/workflows/ci.yml/badge.svg)](https://github.com/lacklusteradmin/spectra-apple/actions/workflows/ci.yml)

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
checked out here as the `spectra/` git submodule. Core owns domain state and
decisions; the app renders its results and forwards user intent.

- [AGENTS.md](AGENTS.md): the rules for working in this repository. It loads
  `spectra/AGENTS.md` too, Rule 0 first. Read first.
- [iOS UI](docs/IOS-UI.md): layout, typography and Liquid Glass rules, and
  what the Mac does differently.
- [Swift bindings](docs/SWIFT-BINDINGS.md): how the app builds core and
  generates its bindings.
- [Open items](docs/OPEN-ITEMS.md): remaining app work. Core's are in
  `spectra/docs/OPEN-ITEMS.md`.
- [Scripts](scripts/README.md): the tools behind the Makefile.

### Building

Clone with the submodule:

```sh
git clone --recurse-submodules https://github.com/lacklusteradmin/spectra-apple.git
```

or run `git submodule update --init` in an existing clone. The build needs a
Rust toolchain; `spectra/rust-toolchain.toml` pins it, so `cargo` installs the
right one on first use.

Open `swift/Spectra.xcodeproj`, pick an iPhone or My Mac as the destination and
build: one target and one set of sources make both apps. The Xcode “Build Rust
Core” phase runs `scripts/build-apple.sh`, which compiles the Rust core in
`spectra/` for the device, the arm64 simulator or the Mac and generates
`swift/generated/` from it, so a fresh clone needs no separate step. Simulators
and Macs are arm64 only. The Swift bindings are **not** checked in; never
hand-edit `swift/generated/` — change the Rust API and rebuild.

The Mac app is sandboxed and keeps its secrets in the data protection keychain,
which macOS opens only to an app signed with its keychain access group. Xcode's
automatic signing does that with a Mac development profile for the team; an
unsigned or ad-hoc build runs, and is refused the Keychain.

### Verification

Four targets gate a change, each run by name; [AGENTS.md](AGENTS.md#verification)
says which a change needs:

| Target | What it runs |
|---|---|
| `make lint` | the source scans, which read core through the submodule |
| `make check-ui` | the design-token check |
| `make test-ios` | `xcodebuild test` on an iPhone simulator |
| `make test-mac` | `xcodebuild test` on this Mac, the app signed for its Keychain |

CI runs `lint` and `check-ui`; `test-ios` and `test-mac` need Xcode. Core's own
targets run in its checkout: `make -C spectra lint`, and so on.

## License

Spectra is free software under the [GNU General Public License v3.0](LICENSE).
It comes with no warranty. A wallet you cannot inspect is a wallet you are
trusting on someone else's word, so the terms that keep modified versions open
are part of the point rather than an afterthought.
