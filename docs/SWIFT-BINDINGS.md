# Swift bindings

How the app builds the Rust core and the Swift bindings to it, with **UniFFI
0.31.2 and Swift 6**. What core exports, and the rules an export follows, are
core's: `spectra/docs/FFI-BOUNDARY.md`.

## Building core

The Xcode “Build Rust Core” phase runs `scripts/build-apple.sh` for the
platform being built. It compiles `spectra/core` as a static library, in
DerivedData rather than a `target/` directory, from inside the `spectra/`
checkout: rustup takes the toolchain `spectra/rust-toolchain.toml` pins, and
cargo still reads this repository's `.cargo/config.toml`, which pins the iOS
minimum the C half of the library is stamped with. `scripts/apple-rust-build-env.sh`
takes the same minimum from the Xcode project for a build Xcode did not start.

The submodule is the version of core the app builds. An edit in `spectra/`
reaches the next build; the app's commits record which core commit they built
against.

## Regenerating bindings

```sh
make ios
```

Change the Rust API in `spectra/`, then build: in Xcode, or with `make ios` or
`make mac`.
Never edit `swift/generated/` by hand. The Xcode “Build Rust Core” phase runs
`scripts/build-apple.sh`, which builds the library for the platform being built
and generates the bindings from that same library, replacing a file only when its text changed. It is the
only writer of the generated sources and
post-processes nothing, so a Swift 6 problem in them is a UniFFI version or
API-shape problem, not something to patch downstream. 0.31.2 is the floor
because it is the release that emits `nonisolated(unsafe)` on the
callback-interface `vtablePtr` statics itself.

## Callers

An export's callers are this app and core's CLI. `scripts/unreachable-exports.py`
reads both, the CLI through the submodule, and fails on an export neither
calls. A call inside a `WalletServiceBridge` method counts only while that
method is itself called. `SecretStore` and `RefreshObserver` are foreign
callback protocols: their Swift implementations need no Swift caller.

## Common errors

| Symptom | Check |
|---|---|
| `Cannot find type 'Foo' in scope` | Regenerate bindings and confirm the declaration is exported |
| `does not conform to protocol 'Codable'` | UniFFI does not generate `Codable`; add the appropriate Swift conformance |
| A key path into a subscript will not compile | Avoid `dict[key, default:]` in key paths; provide a suitable subscript |
| `the spectra submodule is not checked out` | Run `git submodule update --init` |
