#!/usr/bin/env bash
# Build the Rust core for the iOS or macOS app and generate its Swift bindings.
#
# Run by the Xcode "Build Rust Core" phase, which supplies PROJECT_TEMP_DIR,
# CONFIGURATION and PLATFORM_NAME. Puts libspectra_core.a where the app
# target's LIBRARY_SEARCH_PATHS look for it, then generates swift/generated/
# from that same library, so the bindings always describe what the app links.
# Simulators and Macs are arm64 only; the project excludes x86_64 to match.
#
# This is the only writer of swift/generated/, and it patches nothing: a
# Swift 6 problem there is a UniFFI version or API-shape problem. Keep UniFFI
# at 0.31.2 or later; older releases emit bindings Swift 6 rejects.
set -euo pipefail

: "${PROJECT_TEMP_DIR:?run from the Xcode build phase}"
: "${CONFIGURATION:?run from the Xcode build phase}"
: "${PLATFORM_NAME:?run from the Xcode build phase}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUST_BUILD_ROOT="${PROJECT_TEMP_DIR}/spectra-rust"
BINDINGS_DIR="${REPO_ROOT}/swift/generated"
export CARGO_TARGET_DIR="${RUST_BUILD_ROOT}/cargo-target"

# bash 3.2 (what Xcode runs) treats an empty array as unbound under `set -u`.
if [[ "${CONFIGURATION}" == Release ]]; then
  PROFILE=release
  RELEASE_FLAG=--release
else
  PROFILE=debug
  RELEASE_FLAG=""
fi

case "${PLATFORM_NAME}" in
  macosx)
    TARGET=aarch64-apple-darwin
    OUT="${RUST_BUILD_ROOT}/apple/macos"
    ;;
  iphonesimulator)
    TARGET=aarch64-apple-ios-sim
    OUT="${RUST_BUILD_ROOT}/apple/ios-simulator"
    ;;
  iphoneos)
    TARGET=aarch64-apple-ios
    OUT="${RUST_BUILD_ROOT}/apple/ios-device"
    ;;
  *)
    echo "error: no Rust target for platform ${PLATFORM_NAME}" >&2
    exit 1
    ;;
esac

# Xcode build phases run in a minimal shell, so cargo may not be on PATH.
export PATH="${HOME}/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:${PATH}"
if [[ -f "${HOME}/.cargo/env" ]]; then source "${HOME}/.cargo/env"; fi
if ! command -v cargo >/dev/null 2>&1; then
  echo "error: cargo is required to build the Rust core" >&2
  echo "hint: install Rust from https://rustup.rs" >&2
  exit 1
fi

source "${REPO_ROOT}/scripts/apple-rust-build-env.sh"

if command -v rustup >/dev/null 2>&1; then
  rustup target add "${TARGET}" >/dev/null 2>&1 || true
fi
# Core itself is the library the app links: its rlib built as a static one.
cargo rustc ${RELEASE_FLAG} --manifest-path "${REPO_ROOT}/core/Cargo.toml" --target "${TARGET}" \
  --lib --crate-type staticlib

mkdir -p "${OUT}"
cp "${CARGO_TARGET_DIR}/${TARGET}/${PROFILE}/libspectra_core.a" "${OUT}/libspectra_core.a"

# The generator writes into a scratch directory, and a binding replaces the one in
# swift/generated/ only when its text changed. Every Swift file depends on
# spectra_core.swift, so a new modification time alone recompiles the whole
# app, and most core edits leave the FFI surface as it was.
GENERATED="${RUST_BUILD_ROOT}/bindings"
rm -rf "${GENERATED}"
mkdir -p "${GENERATED}" "${BINDINGS_DIR}"
# The generator is a host tool, not part of the app: it is built without the
# app's macOS minimum, so the same build serves an iOS and a macOS app build.
env -u MACOSX_DEPLOYMENT_TARGET \
  cargo run --manifest-path "${REPO_ROOT}/tools/uniffi-bindgen/Cargo.toml" \
  -- generate --language swift --library "${OUT}/libspectra_core.a" --out-dir "${GENERATED}"
cp "${GENERATED}/spectra_coreFFI.modulemap" "${GENERATED}/module.modulemap"
for generated in "${GENERATED}"/*; do
  binding="${BINDINGS_DIR}/$(basename "${generated}")"
  cmp -s "${generated}" "${binding}" || cp "${generated}" "${binding}"
done
