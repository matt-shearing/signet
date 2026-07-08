# Signet — local PDF signing

A tiny, fully-local PDF signer. Open a PDF, drop your signature (or a text/date
field), download the signed PDF. Your signature is saved in the browser for next
time. **Nothing leaves your machine** — no accounts, no uploads, works offline
(the PDF libraries are vendored in `vendor/`).

Think of it as a one-file, self-hosted alternative to DocuSign / Dropbox Sign for
the common case: *"I just need to sign this PDF and send it back."*

## Install (Linux — adds a right-click "Open With" entry)
```
./install.sh
```
Then **right-click any PDF → Open With → Signet**. It opens the PDF straight into
the signing view. Remove any time with `./uninstall.sh` (app files stay put).

**Firefox** users get a true **no-server** experience — the PDF is embedded into a
throwaway folder and opened via `file://`, nothing listens on any port. **Chrome**
and others use a tiny loopback server that runs *only while you're signing* and
shuts down when you click **Done** (Chrome blocks `file://` workers, so a server
is required there). Force a mode with `SIGNET_MODE=file` or `SIGNET_MODE=server`.

## Run ad-hoc (no install)
```
python3 signet.py some.pdf     # open that PDF straight into signing
./sign.sh                      # or serve at http://localhost:8000
```

## Use it
1. **My signatures** (or **+ Signature**) — draw or type your signature once; saved for reuse.
2. **+ Signature / + Text / + Date**, then click the page to drop the field. Drag to
   move, corner to resize, ✕ / `Del` to remove. Text & date fields are editable.
3. **Download signed PDF** → `<name>-SIGNED.pdf`. **Done** closes the session.

## Screenshots
_(add screenshots to `screenshots/` and reference them here)_

## Under the hood
Single HTML page + three vendored libraries (all open-source):
[pdf.js](https://mozilla.github.io/pdf.js/) (Apache-2.0) to render,
[pdf-lib](https://pdflib.js.org/) (MIT) to stamp/flatten, and
[signature_pad](https://github.com/szimek/signature_pad) (MIT) to draw. The
`signet.py` launcher just wires "Open With" to the browser. No build step.

## Licence
MIT — see `LICENSE`.
