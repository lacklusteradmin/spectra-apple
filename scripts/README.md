# Scripts

This directory contains the app's source-check, icon-export and string-sync
tools. Use the Makefile for routine work:

```sh
make lint SPECTRA=<spectra>  # The source scans, which read core
make check-ui                # UI design tokens
```

Core's own tools are in spectra's `scripts/`, among them
`build-apple-package.sh`, which builds the package the app links.

## Code and resource checks

These source scans help identify problems. They read source, core's in the
checkout `SPECTRA` names, and compile nothing; without it they refuse to run.
Review findings for dynamic calls and other cases a scan cannot resolve. Each
scan is a Python script run as `python3 -B scripts/<scan>.py` from any
directory; it prints its findings and a count, and exits non-zero when it found
anything. `make lint` runs every scan below except `check-design-tokens.py`,
which `make check-ui` runs.

| File | Purpose |
|---|---|
| `unreachable-exports.py` | Finds exported Rust interfaces no production Swift calls. |
| `unused-strings.py` | Finds unused text, core sentences the tables do not translate, and inconsistent translation keys across locales. |
| `swift-shell-literals.py` | Finds hard-coded chain names and amount precision in Swift, where domain rules should come from core. |
| `check-design-tokens.py` | Finds corner radii, spacing, literal colours, glass tints, glass shapes and divider opacities that bypass shared UI design tokens. |
| `source_scan.py` | What the scans share: production-source selection for Rust and Swift (test fixtures do not count as runtime callers or copy producers), files listed inside the core checkout, call text with comments and declarations removed, and the report and exit status. |
| `test-source-scan.py` | Tests the shared helpers: production/test source selection, Rust module paths, call text and reporting. |

The export scan matches names rather than resolving receiver types or building
a call graph. An unrelated method with the same name can hide an unused method;
review these candidates manually even when the scan passes.

## Icons

Exporting app icons needs ImageMagick (`brew install imagemagick`).

| File | Purpose |
|---|---|
| `export-swift-icons.sh` | Converts and synchronizes `icons/appicon/` and core's `icons/crypto/`, in the checkout `SPECTRA` names (it refuses without one), into the Xcode asset catalog, rendering app icons as PNGs: each source at 1024 points for iOS, and the light one again in the Mac's shape and sizes. |

## Strings

| File | Purpose |
|---|---|
| `export-swift-strings.sh` | Syncs the string tables from spectra's `strings/`, in the checkout `SPECTRA` names, into `resources/strings/`: copies a new or changed table, removes one whose source is gone, and refuses a checkout with no tables. |
