# Publishing Signet to the AUR

Everything's ready. The AUR builds packages by downloading the source tarball, so
the **GitHub repo must be public first** (it's private now).

## One-time setup
- `sudo pacman -S --needed base-devel git`
- An AUR account with your SSH public key uploaded: https://aur.archlinux.org/account

## Cut / refresh a release
1. Bump `pkgver` in `packaging/PKGBUILD` if the version changed.
2. Tag, push, and create the GitHub release:
   ```
   git tag -a v1.0.0 -m "signet 1.0.0" && git push origin v1.0.0
   gh release create v1.0.0 --title "Signet 1.0.0" --generate-notes
   ```
3. Fill the checksum from the published tarball and build-test:
   ```
   cd packaging
   updpkgsums                        # rewrites sha256sums from the live tarball
   makepkg --printsrcinfo > .SRCINFO
   makepkg -si                       # local build + install test
   ```
   (Until the repo is public, `updpkgsums`/`makepkg` can't fetch it — leave
   `sha256sums=('SKIP')` and do this step once it's public.)

## Push to the AUR
```
git clone ssh://aur@aur.archlinux.org/signet.git aur-signet
cp packaging/PKGBUILD packaging/.SRCINFO aur-signet/
cd aur-signet && git add PKGBUILD .SRCINFO
git commit -m "signet 1.0.0" && git push
```
Users then install with: `yay -S signet`  (or `paru -S signet`).

## Notes
- `arch=('any')`, `depends=('python')` only — no compile step. Vendored JS libs
  (pdf.js Apache-2.0, pdf-lib MIT, signature_pad MIT) ship inside the tarball.
- If GitHub ever regenerates the tarball with a different hash, just re-run
  `updpkgsums` + `makepkg --printsrcinfo > .SRCINFO` and push again.
