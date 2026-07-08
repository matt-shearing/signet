#!/usr/bin/env python3
"""Signet launcher — opens a PDF straight into the local signing view.

Firefox: NO server at all. The chosen PDF is embedded into a throwaway temp
folder as a payload and opened via file:// — nothing listens on any port.
Other browsers (Chrome, etc.): a tiny loopback server runs only while you sign
(Chrome blocks file:// workers) and shuts itself down when you click Done.

Override with SIGNET_MODE=file|server. Usage: signet.py [/path/to/file.pdf]
"""
import sys, os, base64, tempfile, shutil, time, socket, threading, http.server, webbrowser, glob, subprocess
from urllib.parse import quote

APP_DIR = os.path.dirname(os.path.abspath(__file__))
pdf_path = sys.argv[1] if len(sys.argv) > 1 else None
TMP = tempfile.gettempdir()

# garbage-collect throwaway folders from previous runs (>6h old)
for d in glob.glob(os.path.join(TMP, "signet_*")):
    try:
        if time.time() - os.path.getmtime(d) > 6 * 3600:
            shutil.rmtree(d, ignore_errors=True)
    except OSError:
        pass

work = tempfile.mkdtemp(prefix="signet_")
shutil.copy(os.path.join(APP_DIR, "index.html"), os.path.join(work, "index.html"))
os.symlink(os.path.join(APP_DIR, "vendor"), os.path.join(work, "vendor"))

name = ""
if pdf_path and os.path.isfile(pdf_path):
    name = os.path.splitext(os.path.basename(pdf_path))[0]
    data = open(pdf_path, "rb").read()
    with open(os.path.join(work, "payload.js"), "w") as f:      # no-server (file://) mode
        f.write("window.__PDF_B64=%r;window.__PDF_NAME=%r;" % (base64.b64encode(data).decode(), name))
    shutil.copy(pdf_path, os.path.join(work, "document.pdf"))    # server mode fallback

firefox = shutil.which("firefox") or shutil.which("firefox-esr")
mode = os.environ.get("SIGNET_MODE")
use_file = (mode == "file") or (mode is None and firefox)

if use_file:
    url = "file://" + os.path.join(work, "index.html")
    print("Signet (no server) —", url, flush=True)
    try:
        if firefox:
            subprocess.Popen([firefox, url], start_new_session=True,
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            webbrowser.open(url)
    except Exception as e:
        print("could not open browser:", e)
    sys.exit(0)   # fire-and-forget; temp folder is GC'd on a later launch

# ---- server mode: tiny self-terminating loopback server ----
s = socket.socket(); s.bind(("127.0.0.1", 0)); port = s.getsockname()[1]; s.close()
last = [time.time()]; srv = {}
q = ("?pdf=document.pdf&name=" + quote(name)) if name else ""

class H(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k): super().__init__(*a, directory=work, **k)
    def log_message(self, *a): pass
    def do_GET(self):
        last[0] = time.time()
        if self.path.startswith("/__done"):
            self.send_response(200); self.end_headers(); self.wfile.write(b"ok")
            threading.Thread(target=lambda: (time.sleep(.3), srv["s"].shutdown()), daemon=True).start()
            return
        return super().do_GET()

httpd = http.server.ThreadingHTTPServer(("127.0.0.1", port), H); srv["s"] = httpd
url = f"http://127.0.0.1:{port}/index.html{q}"
def watchdog():
    while True:
        time.sleep(30)
        if time.time() - last[0] > 7200: httpd.shutdown(); break
threading.Thread(target=watchdog, daemon=True).start()
threading.Thread(target=lambda: (time.sleep(.6), webbrowser.open(url)), daemon=True).start()
print("Signet (server) —", url, flush=True)
try:
    httpd.serve_forever()
finally:
    shutil.rmtree(work, ignore_errors=True)
