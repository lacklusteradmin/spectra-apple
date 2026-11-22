# Scripts

This directory contains the app's build, source-check and icon-export tools.
Use the Makefile for routine work:

```sh
make lint         # The source scans
make check-ui     # UI design tokens
```

Core's own tools are in `spectra/scripts/`.

## Builds and binding generation

| File | Purpose |
|---|---|
| `build-apple.sh` | Run by the Xcode “Build Rust Core” phase: compiles core from the `spectra` submodule as a static library for the device, the arm64 simulator or the Mac and generates the Swift bindings from it, replacing a binding only when its text changed so an edit that leaves the FFI as it was recompiles no Swift. |
| `apple-rust-build-env.sh` | Sourced by build scripts to set a consistent minimum iOS or macOS version and clear that platform's incompatible build caches when the version changes. |

## Code and resource checks

These source scans help identify problems. They read source, core's through the
`spectra` submodule, and compile nothing. Review findings for dynamic calls and
other cases a scan cannot resolve. Each scan is a Python script run as
`python3 -B scripts/<scan>.py` from any directory; it prints its findings and a
count, and exits non-zero when it found anything. `make lint` runs every scan
below except `check-design-tokens.py`, which `make check-ui` runs; CI runs both.

| File | Purpose |
|---|---|
| `unreachable-exports.py` | Finds exported Rust interfaces with no detected Swift or CLI callers. |
| `unused-strings.py` | Finds unused text, core sentences the tables do not translate, and inconsistent translation keys across locales. |
| `swift-shell-literals.py` | Finds hard-coded chain names and amount precision in Swift, where domain rules should come from core. |
| `check-design-tokens.py` | Finds corner radii, spacing, literal colours, glass tints and glass shapes that bypass shared UI design tokens. |
| `source_scan.py` | What the scans share: production-source selection for Rust and Swift (test fixtures do not count as runtime callers or copy producers), files listed inside the submodule, call text with comments and declarations removed, and the report and exit status. |
| `test-source-scan.py` | Tests the shared helpers: production/test source selection, Rust module paths, call text and reporting. |

The export scan matches names rather than resolving receiver types or building
a call graph. An unrelated method with the same name can hide an unused method;
review these candidates manually even when the scan passes.

## Icons

Exporting app icons needs ImageMagick (`brew install imagemagick`).

| File | Purpose |
|---|---|
| `export-swift-icons.sh` | Converts and synchronizes `icons/appicon/` and core's `spectra/icons/crypto/` into the Xcode asset catalog, rendering app icons as PNGs: each source at 1024 points for iOS, and the light one again in the Mac's shape and sizes. |
