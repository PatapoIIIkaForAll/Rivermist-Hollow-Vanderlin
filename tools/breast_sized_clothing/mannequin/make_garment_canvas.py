"""Aseprite canvas for drawing one breast-sized garment over the female mannequin, and the way back to a DMI.

Usage:
    python tools/breast_sized_clothing/mannequin/make_garment_canvas.py to-aseprite <drawing.dmi> <out.aseprite> [--detail <detail.dmi>]
    python tools/breast_sized_clothing/mannequin/make_garment_canvas.py to-dmi <in.aseprite> <out.dmi> [--detail-out <detail.dmi>]
        [--mirror auto|east|west|none] [--original <drawing.dmi>]

The drawing holds "<state>_f_<N>" (N = 0-8, 4 dirs), the detail "<state>_f_detail_<N>".
The canvas is 128x32: the four directions side by side in DMI order (south, north, east, west), one frame per breast
size tagged "size N". Layers, bottom to top: "mannequin: breasts behind", "mannequin: body", "mannequin: breasts"
(locked, skin coloured; breasts where they are in game for humans: breasts.dmi shifted 1 px down), "clothing" (the
drawing) and "detail" (the paint layer, if any). Name the file "<state>_f<anything>.aseprite": to-dmi takes the state
from the name, reads only "clothing" and "detail" back (pixel alpha kept, layer opacity ignored), into "<state>_f_<N>" /
"<state>_f_detail_<N>", so the result can go straight to make_archive.py. Give --detail-out the same path as <out.dmi> to
write both into one file.
Side views: the artist may draw only one side when both are alike. --mirror east copies the east view, mirrored, over
the west one in every size (west the other way); --mirror auto (default) compares both sides with --original (the
drawing the canvas was made from; default: the only other "<state>_f*.dmi" drawing next to the .aseprite) and mirrors
the side that was redrawn onto the one left as it was, per size; when both or neither changed it leaves them alone and
says so. The detail layer is never mirrored (it is redone after the drawing).
Needs the Aseprite CLI: the ASEPRITE env var, "aseprite" on PATH or a usual install path; without it the script
stops with "Aseprite not found".
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from dmi import Dmi  # noqa: E402
from PIL import Image, ImageOps  # noqa: E402

ASEPRITE_PATHS = (
    r"C:\Program Files\Aseprite\Aseprite.exe",
    r"C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe",
    r"G:\SteamLibrary\steamapps\common\Aseprite\Aseprite.exe",
)
BODY_ICON = os.path.join(ROOT, "icons/roguetown/mob/bodies/f/fm.dmi")
BREASTS = os.path.join(ROOT, "modular_rmh/icons/mob/sprite_accessory/genitals/breasts.dmi")
SKIN = (232, 183, 150)
SIZES = range(9)
DIRS = 4  # DMI order: south, north, east, west

LUA = r'''
local dir = app.params["dir"]
local out = app.params["out"]
local layers = {}
for name in string.gmatch(app.params["layers"], "[^|]+") do table.insert(layers, name) end
local locked = tonumber(app.params["locked"])
local spr = Sprite(128, 32, ColorMode.RGB)
for i = 2, 9 do spr:newEmptyFrame() end
for i, name in ipairs(layers) do
  local layer = (i == 1) and spr.layers[1] or spr:newLayer()
  layer.name = name
  for f = 1, 9 do
    local path = dir .. "/" .. i .. "_" .. (f - 1) .. ".png"
    local img = Image { fromFile = path }
    spr:newCel(layer, f, img, Point(0, 0))
  end
  if i <= locked then layer.isEditable = false end
end
for f = 1, 9 do
  local tag = spr:newTag(f, f)
  tag.name = "size " .. (f - 1)
  spr.frames[f].duration = 0.5
end
spr.gridBounds = Rectangle(0, 0, 32, 32)
spr:saveAs(out)
'''


def find_aseprite():
    """Path of the Aseprite CLI, or exit with "Aseprite not found"."""
    candidates = [os.environ.get("ASEPRITE"), shutil.which("aseprite")] + list(ASEPRITE_PATHS)
    for path in candidates:
        if path and os.path.isfile(path):
            return path
    sys.exit("Aseprite not found: set ASEPRITE to the Aseprite executable")


def frames(path):
    return {s.name: [f.convert("RGBA") for f in s.frames] for s in Dmi.from_file(path).states if not s.movement}


def shifted(image, dy):
    out = Image.new("RGBA", image.size, (0, 0, 0, 0))
    out.paste(image, (0, dy))
    return out


def pixels(image):
    """Row-major RGBA tuples."""
    access = image.load()
    return [access[x, y] for y in range(image.size[1]) for x in range(image.size[0])]


def tint(image):
    out = Image.new("RGBA", image.size)
    out.putdata([(p[0] * SKIN[0] // 255, p[1] * SKIN[1] // 255, p[2] * SKIN[2] // 255, p[3]) for p in pixels(image)])
    return out


def strip(images):
    out = Image.new("RGBA", (32 * DIRS, 32), (0, 0, 0, 0))
    for d, image in enumerate(images):
        out.alpha_composite(image, (d * 32, 0))
    return out


def find_state(states, suffix_re):
    for name in states:
        m = re.match(suffix_re, name)
        if m:
            return m.group(1)
    return None


def to_aseprite(drawing, out, detail=None):
    draw = frames(drawing)
    state = find_state(draw, r"^(\w+?)_f_0$")
    if not state:
        sys.exit(f"{drawing}: no <state>_f_0 state")
    body = frames(BODY_ICON)["fm"]
    breasts = frames(BREASTS)
    det = frames(detail) if detail else None
    layers = ["mannequin: breasts behind", "mannequin: body", "mannequin: breasts", "clothing"] + (["detail"] if det else [])
    with tempfile.TemporaryDirectory() as tmp:
        for n in SIZES:
            parts = []
            behind = breasts.get(f"pair_{n}_BEHIND")
            parts.append(strip([tint(shifted(behind[d], 1)) if behind else Image.new("RGBA", (32, 32)) for d in range(DIRS)]))
            parts.append(strip([tint(body[d]) for d in range(DIRS)]))
            adj = breasts.get(f"pair_{n}_ADJ")
            parts.append(strip([tint(shifted(adj[d], 1)) if adj else Image.new("RGBA", (32, 32)) for d in range(DIRS)]))
            parts.append(strip(draw[f"{state}_f_{n}"]))
            if det:
                parts.append(strip(det[f"{state}_f_detail_{n}"]))
            for i, image in enumerate(parts, 1):
                image.save(os.path.join(tmp, f"{i}_{n}.png"))
        subprocess.run([find_aseprite(), "-b", "--script-param", f"dir={tmp}", "--script-param", f"out={os.path.abspath(out)}",
                        "--script-param", "layers=" + "|".join(layers), "--script-param", "locked=3",
                        "--script", write_lua(tmp)], check=True, capture_output=True)
    if state_from_name(out) != state:
        print(f"warning: {out} should be named {state}_f....aseprite, to-dmi takes the state from the name")
    print(f"{out}: {state}, {len(layers)} layers")


def write_lua(tmp):
    path = os.path.join(tmp, "make.lua")
    open(path, "w").write(LUA)
    return path


def state_from_name(path):
    """"stewarddress_f__v4.aseprite" -> "stewarddress"."""
    m = re.match(r"^(\w+?)_f(?:_|$)", os.path.splitext(os.path.basename(path))[0])
    return m.group(1) if m else None


OPAQUE_LUA = 'local s = app.open(app.params["src"]) local function f(l) if l.isGroup then for _, c in ipairs(l.layers) do f(c) end else l.opacity = 255 end end for _, l in ipairs(s.layers) do f(l) end s:saveAs(app.params["dst"])'


def export_layers(source):
    """{layer name: [9 frames of 128x32]} via the Aseprite CLI. Layer opacity is an editor setting and is reset to
    full on a copy first; the pixels' own alpha (sheer fabric) is kept as drawn."""
    with tempfile.TemporaryDirectory() as tmp:
        data, sheet = os.path.join(tmp, "s.json"), os.path.join(tmp, "s.png")
        copy, script = os.path.join(tmp, "copy.aseprite"), os.path.join(tmp, "opaque.lua")
        open(script, "w").write(OPAQUE_LUA)
        aseprite = find_aseprite()
        subprocess.run([aseprite, "-b", "--script-param", f"src={os.path.abspath(source)}", "--script-param", f"dst={copy}",
                        "--script", script], check=True, capture_output=True)
        subprocess.run([aseprite, "-b", "--all-layers", "--split-layers", copy, "--data", data,
                        "--format", "json-array", "--filename-format", "{layer}|{frame}", "--sheet", sheet,
                        "--sheet-type", "rows"], check=True, capture_output=True)
        info = json.load(open(data))
        image = Image.open(sheet).convert("RGBA")
        out = {}
        for frame in info["frames"]:
            layer, index = frame["filename"].split("|")
            r = frame["frame"]
            cell = image.crop((r["x"], r["y"], r["x"] + 128, r["y"] + 32))
            out.setdefault(layer, {})[int(index)] = cell
    return out


EAST, WEST = 2, 3


def find_original(source, state):
    """The drawing the canvas was made from: the only "<state>_f*" / "<state>_all_sizes*" DMI with "<state>_f_0" next
    to it (a folder with several versions needs --original)."""
    folder = os.path.dirname(os.path.abspath(source))
    found = []
    for f in os.listdir(folder):
        if not f.endswith(".dmi") or not (f.startswith(state + "_f") or f.startswith(state + "_all_sizes")):
            continue
        if f"{state}_f_0" in [s.name for s in Dmi.from_file(os.path.join(folder, f)).states]:
            found.append(os.path.join(folder, f))
    return found[0] if len(found) == 1 else None


def mirror_sides(clothing, state, mode, original):
    """clothing: {size: 128x32}. Returns it with one side view mirrored onto the other, per mode."""
    if mode == "none":
        return clothing
    orig = None
    if mode == "auto":
        if not original:
            print("mirror auto: no original drawing found, sides left as they are (pass --original or --mirror east/west)")
            return clothing
        orig = frames(original)
    for n in SIZES:
        strip_img = clothing[n]
        east = strip_img.crop((EAST * 32, 0, EAST * 32 + 32, 32))
        west = strip_img.crop((WEST * 32, 0, WEST * 32 + 32, 32))
        source_side = mode
        if mode == "auto":
            o_east, o_west = orig[f"{state}_f_{n}"][EAST], orig[f"{state}_f_{n}"][WEST]
            east_changed = east.tobytes() != o_east.convert("RGBA").tobytes()
            west_changed = west.tobytes() != o_west.convert("RGBA").tobytes()
            if east_changed == west_changed:
                if east_changed:
                    print(f"size {n}: both sides redrawn, kept as drawn")
                continue
            source_side = "east" if east_changed else "west"
        target = WEST if source_side == "east" else EAST
        flipped = ImageOps.mirror(east if source_side == "east" else west)
        strip_img.paste(Image.new("RGBA", (32, 32), (0, 0, 0, 0)), (target * 32, 0))
        strip_img.paste(flipped, (target * 32, 0))
        print(f"size {n}: {source_side} mirrored onto {'west' if target == WEST else 'east'}")
    return clothing


def to_dmi(source, out, detail_out=None, mirror="auto", original=None):
    state = state_from_name(source)
    if not state:
        sys.exit(f"{source}: name it <state>_f....aseprite")
    layers = export_layers(source)
    if "clothing" in layers and mirror != "none":
        layers["clothing"] = mirror_sides(layers["clothing"], state, mirror, original or find_original(source, state))
    files = {}
    for layer, path, prefix in (("clothing", out, f"{state}_f"), ("detail", detail_out, f"{state}_f_detail")):
        if not path:
            continue
        if layer not in layers:
            sys.exit(f"{source}: no layer {layer!r}")
        key = os.path.normcase(os.path.abspath(path))
        dmi = files.setdefault(key, (path, Dmi(32, 32)))[1]
        for n in SIZES:
            st = dmi.state(f"{prefix}_{n}", dirs=DIRS)
            st.frames.extend(layers[layer][n].crop((d * 32, 0, d * 32 + 32, 32)) for d in range(DIRS))
    for path, dmi in files.values():
        dmi.to_file(path)
        print(path)


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("to-aseprite")
    a.add_argument("drawing")
    a.add_argument("out")
    a.add_argument("--detail")
    b = sub.add_parser("to-dmi")
    b.add_argument("source")
    b.add_argument("out")
    b.add_argument("--detail-out")
    b.add_argument("--mirror", default="auto", choices=("auto", "east", "west", "none"))
    b.add_argument("--original")
    args = parser.parse_args()
    if args.cmd == "to-aseprite":
        to_aseprite(args.drawing, args.out, args.detail)
    else:
        to_dmi(args.source, args.out, args.detail_out, args.mirror, args.original)


if __name__ == "__main__":
    main()
