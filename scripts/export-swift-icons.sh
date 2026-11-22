#!/usr/bin/env bash
# Syncs the icon sources into swift/Assets.xcassets/:
#
#   icons/appicon/         → AppIcon.appiconset/ (SVG → 1024×1024 PNG, and the
#                            light icon again in the Mac's shape and sizes)
#   spectra/icons/crypto/  → crypto/             (SVG imageset, no namespace)
#
# The crypto library is core's, in the `spectra` submodule, where it is
# normalized and checked against the catalog's artwork names.
#
# Rules (crypto):
#   - Creates a new .imageset for every SVG not yet in the catalog.
#   - Updates the SVG inside an existing .imageset when the source has changed.
#   - Removes .imageset folders that no longer have a matching source SVG.
#   - Removes the asset group when its source directory has no SVGs.
#
# Rules (appicon):
#   - Converts each SVG to a 1024×1024 PNG using ImageMagick.
#   - Only writes the PNG when the source SVG is newer than it.
#   - Renders SpectraLogo-Light.svg as SpectraLogo-Mac-<pixels>.png for macOS:
#     a Mac icon is not masked by the system, so the artwork is cut to the
#     Mac's rounded rectangle inside its margin.
#   - Never touches Contents.json.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

APPICON_SRC="$REPO_ROOT/icons/appicon"
CRYPTO_SRC="$REPO_ROOT/spectra/icons/crypto"

APPICON_DEST="$REPO_ROOT/swift/Assets.xcassets/AppIcon.appiconset"
CRYPTO_DEST="$REPO_ROOT/swift/Assets.xcassets/crypto"

# ── helpers ────────────────────────────────────────────────────────────────────

MAGICK_BIN=""
require_convert() {
  if command -v magick &>/dev/null; then
    MAGICK_BIN="magick"
  elif command -v convert &>/dev/null; then
    MAGICK_BIN="convert"
  else
    echo "error: ImageMagick not found. Install with: brew install imagemagick" >&2
    exit 1
  fi
}

ensure_group_contents() {
  local dir="$1"
  mkdir -p "$dir"
  if [[ ! -f "$dir/Contents.json" ]]; then
    cat > "$dir/Contents.json" <<'JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON
  fi
}

write_imageset_contents() {
  local imageset="$1" filename="$2"
  cat > "$imageset/Contents.json" <<JSON
{
  "images": [
    {
      "filename": "${filename}",
      "idiom": "universal"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  },
  "properties": {
    "preserves-vector-representation": true
  }
}
JSON
}

# Sync a flat directory of SVGs into an xcassets group folder.
sync_svg_group() {
  local src="$1" dest="$2" label="$3"
  local added=0 updated=0 removed=0

  if ! compgen -G "$src/*.svg" >/dev/null; then
    if [[ -d "$dest" ]]; then
      rm -rf "$dest"
      echo "  [$label] removed empty group"
    fi
    return
  fi

  ensure_group_contents "$dest"

  for svg_path in "$src"/*.svg; do
    [[ -e "$svg_path" ]] || continue
    local filename name imageset dest_svg
    filename="$(basename "$svg_path")"
    name="${filename%.svg}"
    imageset="$dest/${name}.imageset"
    dest_svg="$imageset/$filename"

    mkdir -p "$imageset"
    [[ -f "$imageset/Contents.json" ]] || write_imageset_contents "$imageset" "$filename"

    if [[ ! -f "$dest_svg" ]]; then
      cp "$svg_path" "$dest_svg"
      echo "  [$label] added   $name"
      ((added += 1))
    elif ! cmp -s "$svg_path" "$dest_svg"; then
      cp "$svg_path" "$dest_svg"
      echo "  [$label] updated $name"
      ((updated += 1))
    fi
  done

  for imageset in "$dest"/*.imageset; do
    [[ -d "$imageset" ]] || continue
    local name
    name="$(basename "$imageset" .imageset)"
    if [[ ! -f "$src/${name}.svg" ]]; then
      rm -rf "$imageset"
      echo "  [$label] removed $name"
      ((removed += 1))
    fi
  done

  echo "  [$label] done: $added added, $updated updated, $removed removed."
}

# Convert SVGs in icons/appicon/ to 1024×1024 PNGs in AppIcon.appiconset/.
# A PNG newer than its source SVG is up to date and is skipped.
sync_appicon() {
  local src="$1" dest="$2"
  require_convert
  local converted=0 skipped=0

  for svg_path in "$src"/*.svg; do
    [[ -e "$svg_path" ]] || continue
    local filename name png_path
    filename="$(basename "$svg_path")"
    name="${filename%.svg}"
    png_path="$dest/${name}.png"

    if [[ -f "$png_path" && ! "$svg_path" -nt "$png_path" ]]; then
      ((skipped += 1))
      continue
    fi

    # ImageMagick's built-in SVG renderer flattens curves by user units, not
    # by output size, so sources need a 1024-unit viewBox to render smoothly.
    $MAGICK_BIN -density 144 -background none "$svg_path" -resize 1024x1024 -depth 8 "$png_path"
    echo "  [appicon] converted $name → ${name}.png"
    ((converted += 1))
  done

  echo "  [appicon] done: $converted converted, $skipped up-to-date."
}

# The pixel sizes a Mac icon ships in: 16 to 512 points, at 1x and 2x.
MAC_ICON_PIXELS=(16 32 64 128 256 512 1024)

# Render the light icon in the Mac icon grid: on a 1024 canvas the artwork is
# an 824×824 rounded rectangle with a 100-pixel margin all round.
sync_macicon() {
  local svg_path="$1/SpectraLogo-Light.svg" dest="$2"
  require_convert
  local converted=0 skipped=0

  for pixels in "${MAC_ICON_PIXELS[@]}"; do
    local png_path="$dest/SpectraLogo-Mac-${pixels}.png"
    if [[ -f "$png_path" && ! "$svg_path" -nt "$png_path" ]]; then
      ((skipped += 1))
      continue
    fi
    $MAGICK_BIN -density 144 -background none "$svg_path" -resize 824x824 \
      \( -size 824x824 xc:none -fill white -draw "roundrectangle 0,0 823,823 185,185" \) \
      -alpha set -compose DstIn -composite \
      -compose Over -background none -gravity center -extent 1024x1024 \
      -resize "${pixels}x${pixels}" -depth 8 "$png_path"
    echo "  [appicon] converted SpectraLogo-Light → SpectraLogo-Mac-${pixels}.png"
    ((converted += 1))
  done

  echo "  [appicon] mac done: $converted converted, $skipped up-to-date."
}

# ── main ───────────────────────────────────────────────────────────────────────

echo "syncing appicon..."
sync_appicon "$APPICON_SRC" "$APPICON_DEST"
sync_macicon "$APPICON_SRC" "$APPICON_DEST"

echo "syncing crypto..."
sync_svg_group "$CRYPTO_SRC" "$CRYPTO_DEST" "crypto"
