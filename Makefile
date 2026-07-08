# Signet — install / uninstall. Standard PREFIX + DESTDIR conventions.
#   sudo make install                 # system-wide (/usr/local)
#   make install PREFIX=$HOME/.local  # per-user, no root
#   make DESTDIR=pkg PREFIX=/usr install   # for packagers (AUR)
#
# The installed command/paths use NAME (default signet-pdf) because the plain
# "signet" name is already taken on the AUR by an unrelated project.
PREFIX ?= /usr/local
DESTDIR ?=
NAME ?= signet-pdf

appdir     = $(DESTDIR)$(PREFIX)/share/$(NAME)
bindir     = $(DESTDIR)$(PREFIX)/bin
desktopdir = $(DESTDIR)$(PREFIX)/share/applications
icondir    = $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps

install:
	install -d "$(appdir)" "$(appdir)/vendor" "$(bindir)" "$(desktopdir)" "$(icondir)"
	install -m644 index.html "$(appdir)/index.html"
	install -m644 signet.py  "$(appdir)/signet.py"
	install -m644 vendor/pdf.min.js vendor/pdf.worker.min.js vendor/pdf-lib.min.js vendor/signature_pad.umd.min.js "$(appdir)/vendor/"
	install -m644 icon.svg "$(icondir)/$(NAME).svg"
	sed 's|@APPDIR@|$(PREFIX)/share/$(NAME)|' signet.in > "$(bindir)/$(NAME)"
	chmod 755 "$(bindir)/$(NAME)"
	sed -e 's|@BIN@|$(PREFIX)/bin/$(NAME)|' -e 's|@ICON@|$(NAME)|' signet.desktop.in > "$(desktopdir)/$(NAME).desktop"
	@if [ -z "$(DESTDIR)" ]; then \
	  update-desktop-database "$(DESTDIR)$(PREFIX)/share/applications" 2>/dev/null || true; \
	  gtk-update-icon-cache -qf "$(DESTDIR)$(PREFIX)/share/icons/hicolor" 2>/dev/null || true; \
	  echo "✓ Signet installed ($(NAME)). Right-click a PDF → Open With → Signet."; \
	fi

uninstall:
	rm -rf "$(appdir)"
	rm -f "$(bindir)/$(NAME)" "$(desktopdir)/$(NAME).desktop" "$(icondir)/$(NAME).svg"
	@if [ -z "$(DESTDIR)" ]; then \
	  update-desktop-database "$(DESTDIR)$(PREFIX)/share/applications" 2>/dev/null || true; \
	  echo "✓ Signet uninstalled."; \
	fi

.PHONY: install uninstall
