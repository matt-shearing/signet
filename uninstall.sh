#!/usr/bin/env bash
APPS="$HOME/.local/share/applications"
rm -f "$APPS/signet.desktop"
update-desktop-database "$APPS" 2>/dev/null || true
echo "✓ Uninstalled OneQode Sign (files in signing-app/ are untouched)."
