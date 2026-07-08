# Signet — install / uninstall. Standard PREFIX + DESTDIR conventions.
#   sudo make install                 # system-wide (/usr/local)
#   make install PREFIX=$HOME/.local  # per-user, no root
#   make DESTDIR=pkg PREFIX=/usr install   # for packagers (AUR)
PREFIX ?= /usr/local
DESTDIR ?=

appdir     = $(DESTDIR)$(PREFIX)/share/signet
bindir     = $(DESTDIR)$(PREFIX)/bin
desktopdir = $(DESTDIR)$(PREFIX)/share/applications
icondir    = $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps

install:
	install -d "$(appdir)" "$(appdir)/vendor" "$(bindir)" "$(desktopdir)" "$(icondir)"
	install -m644 index.html "$(appdir)/index.html"
	install -m644 signet.py  "$(appdir)/signet.py"
	install -m644 vendor/pdf.min.js vendor/pdf.worker.min.js vendor/pdf-lib.min.js vendor/signature_pad.umd.min.js "$(appdir)/vendor/"
	install -m644 icon.svg "$(icondir)/signet.svg"
	sed 's|@APPDIR@|$(PREFIX)/share/signet|' signet.in > "$(bindir)/signet"
	chmod 755 "$(bindir)/signet"
	sed 's|@BIN@|$(PREFIX)/bin/signet|' signet.desktop.in > "$(desktopdir)/signet.desktop"
	@if [ -z "$(DESTDIR)" ]; then \
	  update-desktop-database "$(DESTDIR)$(PREFIX)/share/applications" 2>/dev/null || true; \
	  gtk-update-icon-cache -qf "$(DESTDIR)$(PREFIX)/share/icons/hicolor" 2>/dev/null || true; \
	  echo "✓ Signet installed. Right-click a PDF → Open With → Signet."; \
	fi

uninstall:
	rm -rf "$(appdir)"
	rm -f "$(bindir)/signet" "$(desktopdir)/signet.desktop" "$(icondir)/signet.svg"
	@if [ -z "$(DESTDIR)" ]; then \
	  update-desktop-database "$(DESTDIR)$(PREFIX)/share/applications" 2>/dev/null || true; \
	  echo "✓ Signet uninstalled."; \
	fi

.PHONY: install uninstall
