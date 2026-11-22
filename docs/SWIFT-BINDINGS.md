# Swift bindings

How the app builds the Rust core and the Swift bindings to it, with **UniFFI
0.31.2 and Swift 6**. What core exports, and the rules an export follows, are
core's: `../Spectra/docs/FFI-BOUNDARY.md`.

## The core package

The app links core as `SpectraCore/`, a local Swift package that is not
checked in. Xcode compiles no Rust: `make core` writes the package with core's
`scripts/build-apple-package.sh`. It holds:

- `spectra_core.xcframework`: core as a static library for the iPhone, the
  arm64 simulator and the Mac;
- the `spectra_coreFFI` module: the C header of core's FFI, kept out of the
  XCFramework so that a core edit that leaves the FFI as it was relinks the
  app and recompiles no Swift;
- the `SpectraCore` target: the Swift bindings generated from that same
  library, compiled as a module of their own, so an app edit does not
  recompile them;
- `build-inputs`: the profile, platforms and minimum OS versions it was built
  with.

A Swift file that uses core imports it: `import SpectraCore`.

`make core` builds from the core checkout beside this repository,
`../Spectra`, whatever it holds: nothing here records a core version. It takes
the app's minimum iOS and macOS versions from the Xcode project, so each
library is stamped with the minimum the app links against. The Rust build
stays in the checkout's `target/apple/`: Clean Build Folder and a new
DerivedData leave it alone.

| Variable | Default | Use |
|---|---|---|
| `PROFILE` | `dev` | `release` for a build that ships; a Release build refuses a dev package |
| `PLATFORMS` | `ios ios-sim macos` | Fewer build faster; a build for a platform the package lacks fails |
| `SPECTRA` | `../Spectra` | Another core checkout, relative to this repository's root; the scans and icon export read it too |

Every build and test target in the Makefile runs `make core` first. A run that
finds nothing changed takes seconds and leaves the package as it was.

## Changing the Rust API

```sh
make core
```

Change the Rust API in the core checkout, run `make core`, then build: in
Xcode, or with `make ios` or `make mac`. Never edit `SpectraCore/` by
hand. The build script replaces the header and bindings only when their text
changed, so a core edit that leaves the FFI as it was recompiles no app Swift.
It post-processes nothing, so a Swift 6 problem in the bindings is a UniFFI
version or API-shape problem, not something to patch downstream.
0.31.2 is the floor because it is the release that emits `nonisolated(unsafe)`
on the callback-interface `vtablePtr` statics itself.

## Callers

An export's callers are this app and core's CLI. `scripts/unreachable-exports.py`
reads both, the CLI in the core checkout, and fails on an export neither
calls. A call inside a `WalletServiceBridge` method counts only while that
method is itself called. `SecretStore` and `RefreshObserver` are foreign
callback protocols: their Swift implementations need no Swift caller.

## Common errors

| Symptom | Check |
|---|---|
| Xcode reports the `SpectraCore` package or product missing | Run `make core` |
| `Cannot find type 'Foo' in scope` | `import SpectraCore` in that file; then run `make core` and confirm the declaration is exported |
| `… is not available due to missing import of defining module 'SpectraCore'` | `import SpectraCore` in that file |
| `a Release build needs the release core package` | Run `make core PROFILE=release` |
| No library for this platform in `spectra_core.xcframework` | The package lacks that platform: run `make core` with it in `PLATFORMS` |
| `does not conform to protocol 'Codable'` | UniFFI does not generate `Codable`; add the appropriate Swift conformance |
| A key path into a subscript will not compile | Avoid `dict[key, default:]` in key paths; provide a suitable subscript |
| `no core checkout at ../Spectra`, or `../Spectra/scripts/build-apple-package.sh: No such file or directory` | Clone spectra beside this repository, or set `SPECTRA` to a checkout |
