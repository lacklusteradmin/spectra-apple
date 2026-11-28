#!/usr/bin/env bash
# Syncs spectra's icon sources into app/Assets.xcassets/:
#
#   <spectra>/icons/appicon/ → AppIcon.appiconset/ (SVG → 1024×1024 PNG, and the
#                              light icon again in the Mac's shape and sizes)
#   <spectra>/icons/crypto/  → crypto/             (SVG imageset, no namespace)
#   <spectra>/icons/chain/   → chain/              (SVG imageset, namespace `chain/`)
#
# All are core's, in the spectra checkout SPECTRA names (absolute or relative
# to this repository's root), where the crypto and chain libraries are
# normalized and checked against the catalog's artwork names.
#
# Rules (all):
#   - Refuses a source with no SVGs: that is a wrong SPECTRA, not an empty
#     library, and syncing it would remove every icon.
#
# Rules (crypto and chain):
#   - Creates a new .imageset for every SVG not yet in the catalog.
#   - Updates the SVG inside an existing .imageset when the source has changed.
#   - Removes .imageset folders that no longer have a matching source SVG.
#
# Rules (appicon):
#   - Renders each SVG to a 1024×1024 PNG using ImageMagick, without PNG time
#     chunks, so one source always renders to the same bytes.
#   - Writes a PNG only when its rendering differs from the catalog's.
#   - Renders SpectraLogo-Light.svg as SpectraLogo-Mac-<pixels>.png for macOS:
#     a Mac icon is not masked by the system, so the artwork is cut to the
#     Mac's rounded rectangle inside its margin.
#   - Never touches Contents.json.
#
# --check writes nothing: it fails, naming each icon, when the crypto or chain
# group is not an exact copy of core's library (`make lint` runs it). The app icon is
# left out: it is a rendering, and another ImageMagick may draw other bytes.
set -euo pipefail

CHECK=0
case "${1:-}" in
  "") ;;
  --check) CHECK=1 ;;
  *) echo "usage: SPECTRA=<spectra checkout> $0 [--check]" >&2; exit 2 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -z "${SPECTRA:-}" ]]; then
  echo "error: the icons are core's: set SPECTRA to a spectra checkout" >&2
  exit 2
fi
SPECTRA_ROOT="$(cd "$REPO_ROOT" && cd "$SPECTRA" && pwd)"
APPICON_SRC="$SPECTRA_ROOT/icons/appicon"
CRYPTO_SRC="$SPECTRA_ROOT/icons/crypto"
CHAIN_SRC="$SPECTRA_ROOT/icons/chain"
for src in "$APPICON_SRC" "$CRYPTO_SRC" "$CHAIN_SRC"; do
  if ! compgen -G "$src/*.svg" >/dev/null; then
    echo "error: no icons in $src: SPECTRA must name a spectra checkout" >&2
    exit 2
  fi
done

APPICON_DEST="$REPO_ROOT/app/Assets.xcassets/AppIcon.appiconset"
CRYPTO_DEST="$REPO_ROOT/app/Assets.xcassets/crypto"
CHAIN_DEST="$REPO_ROOT/app/Assets.xcassets/chain"

RENDER_DIR="$(mktemp -d)"
trap 'rm -rf "$RENDER_DIR"' EXIT

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

# A group folder's Contents.json. A namespaced group's images are named
# `<group>/<name>`, so its file names may repeat another group's.
ensure_group_contents() {
  local dir="$1" namespace="$2"
  mkdir -p "$dir"
  local contents
  if ((namespace)); then
    contents='{
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "provides-namespace" : true
  }
}'
  else
    contents='{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}'
  fi
  if [[ ! -f "$dir/Contents.json" ]] || [[ "$(cat "$dir/Contents.json")" != "$contents" ]]; then
    printf '%s\n' "$contents" > "$dir/Contents.json"
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
  local src="$1" dest="$2" label="$3" namespace="$4"
  local added=0 updated=0 removed=0

  ensure_group_contents "$dest" "$namespace"

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

# Fail, naming each one, when a group's icons are not exact copies of src's.
check_svg_group() {
  local src="$1" dest="$2" label="$3"
  local stale=0

  for svg_path in "$src"/*.svg; do
    [[ -e "$svg_path" ]] || continue
    local filename name imageset
    filename="$(basename "$svg_path")"
    name="${filename%.svg}"
    imageset="$dest/${name}.imageset"
    if [[ ! -f "$imageset/Contents.json" || ! -f "$imageset/$filename" ]]; then
      echo "  [$label] missing $name"
      ((stale += 1))
    elif ! cmp -s "$svg_path" "$imageset/$filename"; then
      echo "  [$label] differs $name"
      ((stale += 1))
    fi
  done

  for imageset in "$dest"/*.imageset; do
    [[ -d "$imageset" ]] || continue
    local name
    name="$(basename "$imageset" .imageset)"
    if [[ ! -f "$src/${name}.svg" ]]; then
      echo "  [$label] extra   $name"
      ((stale += 1))
    fi
  done

  if ((stale > 0)); then
    echo "error: $stale $label icons differ from core's: run SPECTRA=<spectra checkout> scripts/export-swift-icons.sh" >&2
    return 1
  fi
  echo "  [$label] matches core's library."
}

# PNG output options: 8 bits per channel and no time chunks, which would make
# every rendering of one source differ.
PNG_OPTS=(-depth 8 -define png:exclude-chunks=date,time)

# Move a rendering into the catalog unless the catalog's PNG has the same
# bytes; succeeds only when it wrote.
place_png() {
  local rendered="$1" png_path="$2"
  if cmp -s "$rendered" "$png_path"; then
    return 1
  fi
  mv "$rendered" "$png_path"
}

# Render the SVGs in icons/appicon/ as 1024×1024 PNGs in AppIcon.appiconset/.
sync_appicon() {
  local src="$1" dest="$2"
  require_convert
  local converted=0 unchanged=0

  for svg_path in "$src"/*.svg; do
    [[ -e "$svg_path" ]] || continue
    local filename name rendered
    filename="$(basename "$svg_path")"
    name="${filename%.svg}"
    rendered="$RENDER_DIR/${name}.png"

    # ImageMagick's built-in SVG renderer flattens curves by user units, not
    # by output size, so sources need a 1024-unit viewBox to render smoothly.
    $MAGICK_BIN -density 144 -background none "$svg_path" -resize 1024x1024 "${PNG_OPTS[@]}" "$rendered"
    if place_png "$rendered" "$dest/${name}.png"; then
      echo "  [appicon] converted $name → ${name}.png"
      ((converted += 1))
    else
      ((unchanged += 1))
    fi
  done

  echo "  [appicon] done: $converted converted, $unchanged unchanged."
}

# The pixel sizes a Mac icon ships in: 16 to 512 points, at 1x and 2x.
MAC_ICON_PIXELS=(16 32 64 128 256 512 1024)

# Render the light icon in the Mac icon grid: on a 1024 canvas the artwork is
# an 824×824 rounded rectangle with a 100-pixel margin all round.
sync_macicon() {
  local svg_path="$1/SpectraLogo-Light.svg" dest="$2"
  require_convert
  local converted=0 unchanged=0

  for pixels in "${MAC_ICON_PIXELS[@]}"; do
    local name="SpectraLogo-Mac-${pixels}"
    local rendered="$RENDER_DIR/${name}.png"
    $MAGICK_BIN -density 144 -background none "$svg_path" -resize 824x824 \
      \( -size 824x824 xc:none -fill white -draw "roundrectangle 0,0 823,823 185,185" \) \
      -alpha set -compose DstIn -composite \
      -compose Over -background none -gravity center -extent 1024x1024 \
      -resize "${pixels}x${pixels}" "${PNG_OPTS[@]}" "$rendered"
    if place_png "$rendered" "$dest/${name}.png"; then
      echo "  [appicon] converted SpectraLogo-Light → ${name}.png"
      ((converted += 1))
    else
      ((unchanged += 1))
    fi
  done

  echo "  [appicon] mac done: $converted converted, $unchanged unchanged."
}

# ── main ───────────────────────────────────────────────────────────────────────

if ((CHECK)); then
  echo "checking crypto..."
  crypto=0
  check_svg_group "$CRYPTO_SRC" "$CRYPTO_DEST" "crypto" || crypto=$?
  echo "checking chain..."
  chain=0
  check_svg_group "$CHAIN_SRC" "$CHAIN_DEST" "chain" || chain=$?
  ((crypto == 0 && chain == 0))
  exit
fi

echo "syncing appicon..."
sync_appicon "$APPICON_SRC" "$APPICON_DEST"
sync_macicon "$APPICON_SRC" "$APPICON_DEST"

echo "syncing crypto..."
sync_svg_group "$CRYPTO_SRC" "$CRYPTO_DEST" "crypto" 0

echo "syncing chain..."
sync_svg_group "$CHAIN_SRC" "$CHAIN_DEST" "chain" 1
