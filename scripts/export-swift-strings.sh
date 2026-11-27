#!/usr/bin/env bash
# Syncs the string tables both apps read into the app's resources:
#
#   <spectra>/strings/RuntimeStrings.*.json → resources/strings/
#
# The tables are spectra's, in the checkout SPECTRA names (absolute or
# relative to this repository's root): add or change a sentence there, then
# run this. Copies a new or changed table, removes a RuntimeStrings table whose
# source is gone, and refuses a source with no manifest: that is a wrong
# SPECTRA, and syncing it would remove every table.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -z "${SPECTRA:-}" ]]; then
  echo "error: the string tables are spectra's: set SPECTRA to a spectra checkout" >&2
  exit 2
fi
SOURCE="$(cd "$REPO_ROOT" && cd "$SPECTRA" && pwd)/strings"
if [[ ! -f "$SOURCE/RuntimeStrings.manifest.json" ]]; then
  echo "error: no string tables in $SOURCE: SPECTRA must name a spectra checkout" >&2
  exit 2
fi
DEST="$REPO_ROOT/resources/strings"
mkdir -p "$DEST"

copied=0
removed=0
for table in "$SOURCE"/RuntimeStrings.*.json; do
  name="$(basename "$table")"
  if ! cmp -s "$table" "$DEST/$name"; then
    cp "$table" "$DEST/$name"
    copied=$((copied + 1))
  fi
done
for table in "$DEST"/RuntimeStrings.*.json; do
  [[ -e "$table" ]] || continue
  if [[ ! -e "$SOURCE/$(basename "$table")" ]]; then
    rm "$table"
    removed=$((removed + 1))
  fi
done
echo "string tables: ${copied} copied, ${removed} removed"
