#!/usr/bin/env bash
#
# Uninstall codex-keys — restore original codex binary
#
set -euo pipefail

WHICH_CODEX="$(command -v codex 2>/dev/null || true)"

if [[ -z "$WHICH_CODEX" ]]; then
    echo "codex not found in PATH" >&2
    exit 1
fi

BIN_DIR="$(dirname "$WHICH_CODEX")"

if [[ ! -x "$BIN_DIR/codex-bin" ]]; then
    echo "codex-bin not found at $BIN_DIR — nothing to uninstall"
    exit 0
fi

echo "Restoring original codex binary..."
rm "$BIN_DIR/codex"
mv "$BIN_DIR/codex-bin" "$BIN_DIR/codex"

rm -f "$HOME/.local/bin/codex-key-add"
rm -f "$HOME/.local/bin/codex-key-status"

echo "Done. Original codex restored at $BIN_DIR/codex"
echo "Key slots at ~/.codex-keys/ were NOT removed."
