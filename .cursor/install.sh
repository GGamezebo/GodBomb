#!/usr/bin/env bash
# Cloud Agent install script for GodBomb (Tic-Tac-Bada-Boom).
# Installs a pinned Godot 4.7 editor + export templates (idempotent), then
# imports the project so it is ready to run, test, and export.
set -euo pipefail

GODOT_VERSION="4.7.2-stable"
GODOT_TEMPLATE_DIR_VERSION="4.7.2.stable"
GODOT_BASE_URL="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}"
GODOT_BIN="/opt/godot/godot"
TEMPLATE_DIR="${HOME}/.local/share/godot/export_templates/${GODOT_TEMPLATE_DIR_VERSION}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() { printf '\n[install] %s\n' "$*"; }

# --- System packages (headless run + software-rendered GUI testing) ---------
# These let a Cloud Agent run the game under a virtual display (Xvfb) with
# software Vulkan (lavapipe) and capture screenshots/video.
REQUIRED_PKGS=(unzip curl xvfb x11-utils mesa-vulkan-drivers libgl1-mesa-dri xdotool imagemagick ffmpeg)
missing_pkgs=()
for pkg in "${REQUIRED_PKGS[@]}"; do
  dpkg -s "$pkg" >/dev/null 2>&1 || missing_pkgs+=("$pkg")
done
if [ "${#missing_pkgs[@]}" -gt 0 ]; then
  log "Installing system packages: ${missing_pkgs[*]}"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing_pkgs[@]}"
else
  log "System packages already present."
fi

# --- Godot editor binary ----------------------------------------------------
if [ ! -x "$GODOT_BIN" ]; then
  log "Downloading Godot ${GODOT_VERSION} editor..."
  sudo mkdir -p /opt/godot
  sudo chown "$(id -u):$(id -g)" /opt/godot
  tmpzip="$(mktemp --suffix=.zip)"
  curl -fsSL -o "$tmpzip" "${GODOT_BASE_URL}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
  tmpdir="$(mktemp -d)"
  unzip -o -q "$tmpzip" -d "$tmpdir"
  install -m 755 "${tmpdir}/Godot_v${GODOT_VERSION}_linux.x86_64" "$GODOT_BIN"
  rm -rf "$tmpzip" "$tmpdir"
else
  log "Godot binary already installed at ${GODOT_BIN}."
fi
sudo ln -sf "$GODOT_BIN" /usr/local/bin/godot
godot --version

# --- Export templates (needed for `godot --export-*`, e.g. Web) -------------
if [ ! -f "${TEMPLATE_DIR}/web_release.zip" ]; then
  log "Downloading Godot ${GODOT_VERSION} export templates..."
  tmptpz="$(mktemp --suffix=.tpz)"
  curl -fsSL -o "$tmptpz" "${GODOT_BASE_URL}/Godot_v${GODOT_VERSION}_export_templates.tpz"
  tmpdir="$(mktemp -d)"
  unzip -o -q "$tmptpz" -d "$tmpdir"
  mkdir -p "$TEMPLATE_DIR"
  cp -rf "${tmpdir}/templates/." "$TEMPLATE_DIR/"
  rm -rf "$tmptpz" "$tmpdir"
else
  log "Export templates already installed at ${TEMPLATE_DIR}."
fi

# --- Import project assets --------------------------------------------------
log "Importing project resources..."
godot --headless --path "$REPO_ROOT" --import

log "Install complete. Run tests with:"
log "  godot --headless --path . --script res://tests/test_match_clock.gd"
