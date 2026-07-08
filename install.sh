#!/usr/bin/env bash
# Installs "Signet" as a Linux app so PDFs can be opened with it
# (right-click -> Open With -> Signet). Per-user, no root needed.
set -e
APP_DIR="$(cd "$(dirname "$0")" && pwd)"
APPS="$HOME/.local/share/applications"
mkdir -p "$APPS"
chmod +x "$APP_DIR/signet.py" 2>/dev/null || true

cat > "$APPS/signet.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Signet
GenericName=PDF signing
Comment=A tiny local, offline PDF signer
Exec=python3 "$APP_DIR/signet.py" %f
Icon=$APP_DIR/icon.svg
Terminal=false
MimeType=application/pdf;
Categories=Office;
StartupNotify=false
EOF
chmod +x "$APPS/signet.desktop"
update-desktop-database "$APPS" 2>/dev/null || true

echo "✓ Installed Signet."
echo "  Use it: right-click any PDF → Open With → Signet."
echo "  (Removes with: $APP_DIR/uninstall.sh)"
