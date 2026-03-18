#!/usr/bin/env bash
#
# Install codex-keys — automatic key rotation for OpenAI Codex CLI
#
# What this does:
#   1. Finds your codex binary (npm-installed)
#   2. Renames it to codex-bin in the same directory
#   3. Installs the wrapper as codex (same directory, found first in PATH)
#   4. Installs codex-key-add and codex-key-status to ~/.local/bin/
#   5. Creates ~/.codex-keys/ if it doesn't exist
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Find the real codex binary
CODEX_PATH="$(command -v codex 2>/dev/null || true)"

if [[ -z "$CODEX_PATH" ]]; then
    echo "Error: codex not found in PATH" >&2
    echo "Install it first: npm install -g @openai/codex" >&2
    exit 1
fi

# Resolve symlinks to get the real location
CODEX_PATH="$(readlink -f "$(command -v codex)")"
CODEX_DIR="$(dirname "$CODEX_PATH")"
CODEX_BASENAME="$(basename "$CODEX_PATH")"

# Check if already installed (wrapper is a bash script, not node)
WHICH_CODEX="$(command -v codex)"
if head -1 "$WHICH_CODEX" 2>/dev/null | grep -q "bash"; then
    # Wrapper already installed — find the bin dir from it
    BIN_DIR="$(dirname "$WHICH_CODEX")"
    if [[ -x "$BIN_DIR/codex-bin" ]]; then
        echo "codex-keys wrapper already installed at $BIN_DIR"
        echo "Updating wrapper files..."
        cp "$REPO_DIR/bin/codex-wrapper" "$BIN_DIR/codex"
        chmod +x "$BIN_DIR/codex"
        mkdir -p "$HOME/.local/bin"
        cp "$REPO_DIR/bin/codex-key-add" "$HOME/.local/bin/"
        cp "$REPO_DIR/bin/codex-key-status" "$HOME/.local/bin/"
        chmod +x "$HOME/.local/bin/codex-key-add" \
                  "$HOME/.local/bin/codex-key-status"
        echo "Done."
        exit 0
    fi
fi

# Find the directory containing the codex symlink/binary
# (we want the bin dir that's in PATH, not the resolved target)
BIN_DIR="$(dirname "$(command -v codex)")"
echo "Found codex at: $BIN_DIR/codex"

# Rename real codex to codex-bin
if [[ -e "$BIN_DIR/codex-bin" ]]; then
    echo "codex-bin already exists at $BIN_DIR/codex-bin"
else
    echo "Renaming codex → codex-bin"
    mv "$BIN_DIR/codex" "$BIN_DIR/codex-bin"
fi

# Install wrapper
echo "Installing wrapper → $BIN_DIR/codex"
cp "$REPO_DIR/bin/codex-wrapper" "$BIN_DIR/codex"
chmod +x "$BIN_DIR/codex"

# Install helper scripts
mkdir -p "$HOME/.local/bin"
cp "$REPO_DIR/bin/codex-key-add" "$HOME/.local/bin/"
cp "$REPO_DIR/bin/codex-key-status" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/codex-key-add" \
          "$HOME/.local/bin/codex-key-status"

# Create keys directory
mkdir -p "$HOME/.codex-keys"

echo ""
echo "Installed:"
echo "  $BIN_DIR/codex           (wrapper)"
echo "  $BIN_DIR/codex-bin       (real codex)"
echo "  ~/.local/bin/codex-key-add"
echo "  ~/.local/bin/codex-key-status"
echo "  ~/.codex-keys/           (key slots)"
echo ""
echo "Next steps:"
echo "  codex-key-add personal   # add your first key (OAuth)"
echo "  codex-key-add work       # add another key"
echo "  codex --yolo             # auto-selects best key"
echo ""
echo "After npm update -g @openai/codex, re-run:"
echo "  $(realpath "$0")"
