#!/usr/bin/env bash
cd "$(dirname "$0")"
make uninstall PREFIX="$HOME/.local"
