#!/usr/bin/env bash
# Per-user install (no root). For system-wide use: sudo make install
set -e
cd "$(dirname "$0")"
make install PREFIX="$HOME/.local"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *)
  echo "note: ~/.local/bin isn't on PATH, but the Open-With entry uses the full path, so signing still works." ;;
esac
