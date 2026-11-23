"""Run shipped SCOM HTML/JS checks in Chromium/Edge, without BYOND, TGUI or extra Python packages."""
import argparse
import html
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from urllib.parse import quote_plus

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--edge", default=shutil.which("google-chrome") or shutil.which("chromium") or "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[4]
    assets = root/"modular_rmh/modular/law_documents/assets"
    out = Path(tempfile.mkdtemp(prefix="rmh-scom-checks-"))
    for name in ("scom-frame.png","scom-frame-active.png"):
        shutil.copyfile(assets/name,out/name)
    shutil.copyfile(Path(__file__).with_name("browser_checks.js"),out/"browser_checks.js")
    fixture = {"language":"ru","mode":"normal","laws":[{"id":"bootstrap","text":"Первый закон: 10% tax + A+B & хлеб","text_en":"First law: 10% tax + A+B & bread"}]}
    page = (assets/"scom-reader.html").read_text(encoding="utf-8")
    for key,value in {"@FRAME@":json.dumps((out/"scom-frame.png").as_uri()),
                      "@ACTIVE@":json.dumps((out/"scom-frame-active.png").as_uri()),
                      "@REF@":"preview","@DATA@":quote_plus(json.dumps(fixture, separators=(",", ":")))}.items():
        page = page.replace(key,value)
    # A standalone test must never launch a registered byond:// handler.
    page = page.replace("window.location.href = 'byond://?src=preview;ready=1';","")
    page = page.replace("</body>",'<script src="'+(out/"browser_checks.js").as_uri()+'"></script></body>')
    (out/"checks.html").write_text(page,encoding="utf-8")
    profile = out/"edge-profile"
    command = [args.edge,"--headless","--disable-gpu","--no-first-run",
               "--no-default-browser-check","--disable-background-networking",
               "--user-data-dir="+str(profile),"--window-size=500,750",
               "--virtual-time-budget=2000","--dump-dom",(out/"checks.html").as_uri()]
    result = subprocess.run(command,capture_output=True,encoding="utf-8",errors="replace",
                            timeout=35,creationflags=getattr(subprocess,"CREATE_NO_WINDOW",0))
    (out/"dom.html").write_text(result.stdout,encoding="utf-8")
    match = re.search(r'data-tests="([^"]+)"',result.stdout)
    if not match:
        print("Browser checks produced no result:",result.stderr[-1800:])
        return 1
    report = json.loads(html.unescape(match.group(1)))
    (out/"results.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf-8")
    print(json.dumps(report,ensure_ascii=True,indent=2))
    print("Artifacts:",out)
    return 1 if "error" in report else 0

if __name__ == "__main__":
    raise SystemExit(main())
