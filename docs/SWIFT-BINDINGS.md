# Swift bindings

How the app links the Rust core and the Swift bindings to it, with **UniFFI
0.31.2 and Swift 6**. What core exports, and the rules an export follows, are
core's: spectra's `docs/FFI-BOUNDARY.md`.

## The core package

The app links core as `core-apple/`, a local Swift package at this
repository's root that is not checked in. Xcode compiles no Rust. spectra's
`make apple` builds the package into its `target/core-apple/`, with its
`scripts/build-apple-package.sh`, and a developer copies that directory here.
It holds:

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

Nothing here assumes where a spectra checkout is, and nothing records which
core commit the package came from. In spectra, `make apple` takes:

| Variable | Default | Use |
|---|---|---|
| `PROFILE` | `dev` | `release` for a build that ships; a Release build refuses a dev package |
| `PLATFORMS` | `ios ios-sim macos` | Fewer build faster; a build for a platform the package lacks fails |
| `IPHONEOS_DEPLOYMENT_TARGET`, `MACOSX_DEPLOYMENT_TARGET` | `26.0` | This app's minimums, which every object in the libraries is stamped with |

A run that finds nothing changed takes seconds and leaves the package as it
was. The Rust build stays in spectra's `target/apple/`, so Clean Build Folder
and a new DerivedData leave it alone.

## Changing the Rust API

Change the Rust API in spectra, run `make apple` there, then copy the package
here with its modification times, replacing the old one:

```sh
cp -Rp <spectra>/target/core-apple .
```

A Finder drag or `ditto` keeps the times too. Then build: in Xcode, or with
`make ios` or `make mac`. Never edit `core-apple/` by hand.

The build script rewrites the header and bindings only when their text
changed, and a copy that keeps their times lets Xcode see that: a core edit
that leaves the FFI as it was relinks the app and recompiles no Swift. A copy
with new times recompiles every Swift file. The script post-processes nothing,
so a Swift 6 problem in the bindings is a UniFFI version or API-shape problem,
not something to patch downstream. 0.31.2 is the floor because it is the
release that emits `nonisolated(unsafe)` on the callback-interface `vtablePtr`
statics itself.

## Callers

An export's callers are this app's production Swift: core's CLI links core as
Rust and needs no export. `scripts/unreachable-exports.py` reads the exports in
the core checkout `SPECTRA` names and fails on one the app does not call, apart
from the fixtures it lists with their reasons. A call inside a
`WalletServiceBridge` method counts only while that method is itself called. `SecretStore` and `RefreshObserver` are
foreign callback protocols: their Swift implementations need no Swift caller.

## Common errors

| Symptom | Check |
|---|---|
| Xcode reports the `SpectraCore` package or product missing | Run `make apple` in spectra and copy `target/core-apple/` here |
| `Cannot find type 'Foo' in scope` | `import SpectraCore` in that file; then rebuild and copy the package, and confirm the declaration is exported |
| `… is not available due to missing import of defining module 'SpectraCore'` | `import SpectraCore` in that file |
| `a Release build needs the release core package` | Run `make apple PROFILE=release` in spectra and copy the package |
| No library for this platform in `spectra_core.xcframework` | The package lacks that platform: build it with that platform in `PLATFORMS` |
| `the scans read core: set SPECTRA to a spectra checkout` | Pass `SPECTRA=<spectra checkout>` to `make lint` |
