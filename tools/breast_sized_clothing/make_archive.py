"""Turns hand-drawn per-size garments into the layer archive src/<state>.dmi that pack_breast_sized.py reads.

usage: python tools/breast_sized_clothing/make_archive.py <drawing.dmi> <worn.dmi> <state>
           [--detail <detail.dmi>] [--profile <json>] [--out <archive.dmi>] [--force]

<drawing.dmi> holds "<state>_f_<N>" for N 0-8 (4 dirs S N E W: the whole female garment drawn over the body breasts
of size N) and, for a paint layer, "<state>_f_detail_<N>" (here or in --detail; the older name
"<state>_f_<N>_detail" is read too). <worn.dmi> is the garment's plain worn DMI with
"<state>_f" (and "<state>_f_detail"). The profile defaults to profiles/<state>_f.json, the output to src/<state>.dmi.

Step 1, split. Per size and direction, against the worn base of the same prefix and the body breast silhouette
(pair_<N>_ADJ for S/E/W, pair_<N>_BEHIND for N, from breasts.dmi, shifted 1 px down into clothing space):
    pair   drawing pixels inside the silhouette, as <p>_pair_<N>_ADJ or <p>_pair_<N>_BEHIND
    extra  drawing pixels outside it that differ from the base, as <p>_<N>_extra
    hide   base pixels where the drawing is empty, as <p>_<N>_hide (white mask)
Base minus hide plus pair plus extra must rebuild the drawing pixel for pixel, or the script stops (--force writes
anyway). Semi-transparent pixels drawn over the base are the usual cause: they blend with the base on rebuild.

Step 2, warp. Sizes the body animates (frames in tools/breast_anim/src/frames.dmi) also get per-frame stills
<p>_f<K>_... (walk), <p>_r<K>_... (run) and <p>_s<K>_... (squeeze), every layer warped per pixel column to follow
the body breast. The profile picks the warp per layer kind, one mode or per direction ("S", "N", "E", "W",
"default"):
    {"pair": "stretch", "extra": "stretch", "hide": {"S": "bottom", "default": "stretch"}}
    "stretch"  top edge pinned, the bottom follows the breast's bottom edge (default)
    "bottom"   the column shifts with the breast's bottom edge, no stretching (cups that hold the breast up)
    "free"     the column moves and stretches with both edges of the breast (closed garments)
    "rigid"    the whole layer shifts by the breast's average bottom edge motion
    "cover"    like "free", but edges only move outwards, so the layer covers its rest place and the breast
    "none"     static
    "cut_under_clothing": true    also cut the base under the clothing's rest position; the body shows there
    "cut_under_clothing": "fill"  the same cut, holes keep the clothing's rest pixels
    "pin_unchanged": ["N"]        in these directions pixels still equal to the plain garment stay put
    "worn": "<dmi>"               ignored here (the worn DMI is an argument); kept for older profiles
The hide mask never retreats from its rest position, and holes it leaves that no warped layer covers keep the
clothing's rest pixels. "stretch", "bottom" and "rigid" smooth the column motion with a 3-column median; "bottom"
also keeps the outline from growing lone pixels.

Every pair and extra state also gets "_front" (south only) and "_side" (north, east, west) copies. Every size and
frame gets "<p>..._<N>_cover_front": the worn base left after that frame's hide cut where the body breast of that
frame is (the detail cover only where the base cover is). Empty pair and extra states are left out; hide states
are always written.
"""

import argparse
import json
import os
import re
import sys

from PIL import Image, ImageChops

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from dmi import Dmi  # noqa: E402

BODY_BREASTS = os.path.join(ROOT, "modular_rmh/icons/mob/sprite_accessory/genitals/breasts.dmi")
BODY_FRAMES = os.path.join(ROOT, "tools/breast_anim/src/frames.dmi")
PROFILE_DIR = os.path.join(HERE, "profiles")
SRC_DIR = os.path.join(HERE, "src")
# Human female OFFSET_BREASTS draws the body breasts 1 px below the clothing frame.
BODY_OFFSET_Y = 1
SIZES = range(9)
DIRS = 4
SOUTH, NORTH, EAST, WEST = range(4)
DIR_NAMES = ("S", "N", "E", "W")
PROFILES = ("stretch", "bottom", "free", "rigid", "cover", "none")
SMOOTHED_PROFILES = ("stretch", "bottom", "rigid")
# Frame key letters in archive order: walk, run, squeeze.
CYCLES = ("f", "r", "s")
WHITE = (255, 255, 255, 255)
CLEAR = (0, 0, 0, 0)


def blank():
    return Image.new("RGBA", (32, 32), CLEAR)


def shifted(image, dy):
    out = blank()
    out.paste(image, (0, dy))
    return out


def is_empty(frame):
    return all(image.getbbox() is None for image in frame)


def stills(path):
    """name -> first frame [4 dirs] of every non-movement state."""
    out = {}
    for state in Dmi.from_file(path).states:
        if state.movement or state.name in out:
            continue
        images = [image.convert("RGBA") for image in state.frames]
        if state.dirs == 1:
            images = images[:1] * DIRS
        out[state.name] = images[:DIRS]
    return out


# ---------------------------------------------------------------- split

def silhouettes(body, size):
    """Per direction: (layer, alpha access) of the body breast in clothing space, or None."""
    out = []
    for d in range(DIRS):
        layer = "BEHIND" if d == NORTH else "ADJ"
        name = f"pair_{size}_{layer}"
        if size == 0 or name not in body:
            out.append(None)
            continue
        out.append((layer, shifted(body[name][d], BODY_OFFSET_Y).split()[3].load()))
    return out


def split_dir(drawing, base, shape):
    """One direction: (breasts, extra, hide) images."""
    breasts, extra, hide = blank(), blank(), blank()
    src, ref = drawing.load(), base.load()
    b, e, h = breasts.load(), extra.load(), hide.load()
    for x in range(32):
        for y in range(32):
            p, q = src[x, y], ref[x, y]
            inside = shape is not None and shape[x, y]
            if p[3]:
                if inside:
                    b[x, y] = p
                elif not q[3] or p != q:
                    e[x, y] = p
            if q[3] and not p[3]:
                h[x, y] = WHITE
    return breasts, extra, hide


def rebuild(base, breasts, extra, hide):
    out = base.copy()
    out.putalpha(Image.composite(Image.new("L", (32, 32), 0), out.split()[3], hide.split()[3]))
    out.alpha_composite(breasts)
    out.alpha_composite(extra)
    return out


def differing_pixels(a, b):
    """Pixels that differ, every fully transparent pixel counting as the same."""
    pa, pb = a.load(), b.load()
    return sum((pa[x, y] if pa[x, y][3] else CLEAR) != (pb[x, y] if pb[x, y][3] else CLEAR)
               for x in range(32) for y in range(32))


def split_prefix(drawing, base, body, prefix, force):
    """Stencil layers of one prefix: list of (rest name, kind, size, frame [4]); hides first, then pairs, extras."""
    hides, pairs, extras = [], [], []
    failed = []
    for n in SIZES:
        name = f"{prefix}_{n}"
        if name not in drawing:
            print(f"warning: no drawing {name!r}, size {n} left out (the game shows the plain sprite)")
            if n == 5:
                print(f"warning: without size 5 the packer skips every size of {prefix}")
            continue
        shapes = silhouettes(body, n)
        per_layer = {"ADJ": [blank() for _ in range(DIRS)], "BEHIND": [blank() for _ in range(DIRS)]}
        hide_frame, extra_frame = [], []
        for d in range(DIRS):
            breasts, extra, hide = split_dir(drawing[name][d], base[d], shapes[d] and shapes[d][1])
            if shapes[d]:
                per_layer[shapes[d][0]][d] = breasts
            wrong = differing_pixels(rebuild(base[d], breasts, extra, hide), drawing[name][d])
            if wrong:
                failed.append(f"{name} {DIR_NAMES[d]}: {wrong} px")
            hide_frame.append(hide)
            extra_frame.append(extra)
        hides.append((f"_{n}_hide", "hide", n, hide_frame))
        extras.append((f"_{n}_extra", "extra", n, extra_frame))
        if n == 0:
            continue
        pairs.append((f"_pair_{n}_ADJ", "pair", n, per_layer["ADJ"]))
        if f"pair_{n}_BEHIND" in body:
            pairs.append((f"_pair_{n}_BEHIND", "pair", n, per_layer["BEHIND"]))
    if failed:
        print(f"{prefix}: base - hide + pair + extra does not rebuild the drawing (semi-transparent pixels over "
              "the base blend with it):")
        for line in failed:
            print("  " + line)
        if not force:
            sys.exit("stopped; fix the drawing or pass --force to write the archive anyway")
    return hides + [layer for layer in pairs + extras if not is_empty(layer[3])]


# ---------------------------------------------------------------- body motion

def load_body_motion():
    """size -> {"rest": [4], "f"/"r"/"s": [frames][4]} of the body breast per direction in clothing space;
    S/E/W from ADJ, N from BEHIND (ADJ when there is no BEHIND)."""
    rest_states, frame_states = stills(BODY_BREASTS), stills(BODY_FRAMES)

    def pick(name, states):
        adj = states[f"{name}_ADJ"]
        behind = states.get(f"{name}_BEHIND", adj)
        return [shifted(image, BODY_OFFSET_Y) for image in (adj[SOUTH], behind[NORTH], adj[EAST], adj[WEST])]

    motion = {}
    for size in SIZES:
        if f"pair_{size}_f1_ADJ" not in frame_states or f"pair_{size}_ADJ" not in rest_states:
            continue
        entry = {"rest": pick(f"pair_{size}", rest_states)}
        for cycle in CYCLES:
            frames, index = [], 1
            while f"pair_{size}_{cycle}{index}_ADJ" in frame_states:
                frames.append(pick(f"pair_{size}_{cycle}{index}", frame_states))
                index += 1
            entry[cycle] = frames
        motion[size] = entry
    return motion


def load_body_still():
    """size -> south view of the still body breast (ADJ) in clothing space."""
    return {int(m.group(1)): shifted(frame[SOUTH], BODY_OFFSET_Y)
            for name, frame in stills(BODY_BREASTS).items() if (m := re.match(r"^pair_(\d+)_ADJ$", name))}


def column_edges(image):
    """x -> (top, bottom) of opaque pixels, or None."""
    alpha = image.split()[3].load()
    edges = []
    for x in range(32):
        rows = [y for y in range(32) if alpha[x, y]]
        edges.append((rows[0], rows[-1]) if rows else None)
    return edges


def column_maps(rest, frame):
    """x -> (t0, b0, t1, b1) for columns covered by the breast, filled from the nearest column."""
    e0, e1 = column_edges(rest), column_edges(frame)
    both = [x for x in range(32) if e0[x] and e1[x]]
    if not both:
        return [None] * 32
    left = min(x for x in range(32) if e0[x] or e1[x])
    right = max(x for x in range(32) if e0[x] or e1[x])
    maps = [None] * 32
    for x in range(left, right + 1):
        nearest = min(both, key=lambda b: abs(b - x))
        maps[x] = e0[nearest] + e1[nearest]
    return maps


def smooth_maps(maps):
    """3-column median of the edge motion, so one odd column (the cleavage) leaves no lone pixel."""
    columns = [x for x in range(32) if maps[x]]
    if not columns:
        return maps
    left, right = columns[0], columns[-1]
    maps = list(maps)
    top = [m[2] - m[0] for m in maps[left:right + 1]]
    bottom = [m[3] - m[1] for m in maps[left:right + 1]]
    last = len(top) - 1
    for i, x in enumerate(range(left, right + 1)):
        if i == 0 or i == last:
            # One neighbour only: a two-value median would pick the larger motion.
            dt, db = top[i], bottom[i]
        else:
            dt = sorted(top[i - 1:i + 2])[1]
            db = sorted(bottom[i - 1:i + 2])[1]
        t0, b0 = maps[x][0], maps[x][1]
        maps[x] = (t0, b0, t0 + dt, b0 + db)
    return maps


def keep_outline(maps, edges):
    """For "bottom": nudge columns so the shifted outline grows no new lone pixel above or below both neighbours."""
    maps = list(maps)
    for _ in range(3):
        changed = False
        for x in range(1, 31):
            if not (maps[x] and maps[x - 1] and maps[x + 1] and edges[x] and edges[x - 1] and edges[x + 1]):
                continue
            delta = [maps[k][3] - maps[k][1] for k in (x - 1, x, x + 1)]
            tops = [edges[k][0] + delta[i] for i, k in enumerate((x - 1, x, x + 1))]
            bottoms = [edges[k][1] + delta[i] for i, k in enumerate((x - 1, x, x + 1))]
            rest_tops = [edges[k][0] for k in (x - 1, x, x + 1)]
            rest_bottoms = [edges[k][1] for k in (x - 1, x, x + 1)]
            fix = 0
            if tops[1] < tops[0] and tops[1] < tops[2] and not (rest_tops[1] < rest_tops[0] and rest_tops[1] < rest_tops[2]):
                fix = min(tops[0], tops[2]) - tops[1]
            elif bottoms[1] > bottoms[0] and bottoms[1] > bottoms[2] and not (rest_bottoms[1] > rest_bottoms[0] and rest_bottoms[1] > rest_bottoms[2]):
                fix = max(bottoms[0], bottoms[2]) - bottoms[1]
                # The top outline matters more: skip a bottom fix that makes the top stick up.
                if tops[1] + fix < tops[0] and tops[1] + fix < tops[2] and not (rest_tops[1] < rest_tops[0] and rest_tops[1] < rest_tops[2]):
                    fix = 0
            if fix:
                t0, b0, t1, b1 = maps[x]
                maps[x] = (t0, b0, t1, b1 + fix)
                changed = True
        if not changed:
            break
    return maps


def warp(image, maps, mode):
    if mode == "none" or image.getbbox() is None:
        return image
    if mode == "rigid":
        deltas = [m[3] - m[1] for m in maps if m]
        dy = round(sum(deltas) / len(deltas)) if deltas else 0
        return shifted(image, dy)
    src = image.load()
    out = blank()
    dst = out.load()
    for x in range(32):
        m = maps[x]
        for y in range(32):
            if m is None:
                sy = y
            else:
                t0, b0, t1, b1 = m
                if mode == "stretch":
                    t1 = t0
                elif mode == "cover":
                    t1, b1 = min(t0, t1), max(b0, b1)
                if mode == "bottom":
                    sy = y - (b1 - b0)
                elif y < t1:
                    sy = y - (t1 - t0)
                elif y > b1:
                    sy = y - (b1 - b0)
                elif b1 == t1:
                    sy = t0
                else:
                    sy = t0 + round((y - t1) * (b0 - t0) / (b1 - t1))
            if 0 <= sy < 32:
                dst[x, y] = src[x, sy]
    return out


def outline(images):
    """x -> (top, bottom) of the union of images, or None."""
    union = blank()
    for image in images:
        union.alpha_composite(image)
    return column_edges(union)


def warp_frame(frame, rest, body_frame, modes, edges=None):
    warped = []
    for d, image in enumerate(frame):
        maps = column_maps(rest[d], body_frame[d])
        if modes[d] in SMOOTHED_PROFILES:
            maps = smooth_maps(maps)
        if modes[d] == "bottom" and edges:
            maps = keep_outline(maps, edges[d])
        warped.append(warp(image, maps, modes[d]))
    return warped


def pin_unchanged(items, warped, garment, dirs):
    """Puts back the rest pixels wherever the rest picture still equals the plain garment, in directions dirs."""
    for d in dirs:
        rest = garment[d].copy()
        for name, kind, frame in items:
            if kind == "hide":
                rest.putalpha(Image.composite(Image.new("L", (32, 32), 0), rest.split()[3], frame[d].split()[3]))
        for name, kind, frame in items:
            if kind != "hide":
                rest.alpha_composite(frame[d])
        g, r = garment[d].load(), rest.load()
        pinned = [(x, y) for x in range(32) for y in range(32) if g[x, y][3] and r[x, y] == g[x, y]]
        if not pinned:
            continue
        for name, kind, frame in items:
            image = warped[name][d].copy()
            src, dst = frame[d].load(), image.load()
            for p in pinned:
                dst[p] = src[p]
            warped[name][d] = image


def warp_group(items, rest, body_frame, profile, garment=None):
    """Warps one size and prefix for one body frame and holds the cut.
    items: (rest name, kind, still frame [4]); garment: plain worn frames for pin_unchanged; returns name -> frame."""
    garment_layers = [frame for name, kind, frame in items if kind != "hide"]
    edges = [outline([frame[d] for frame in garment_layers]) for d in range(DIRS)] if garment_layers else None
    warped = {name: warp_frame(frame, rest, body_frame, profile[kind], edges) for name, kind, frame in items}
    if garment and profile["pin_unchanged"]:
        pin_unchanged(items, warped, garment, profile["pin_unchanged"])
    hides = [(name, frame) for name, kind, frame in items if kind == "hide"]
    if not hides:
        return warped
    hide_name, hide_rest = hides[0]
    clothing = [(name, frame) for name, kind, frame in items if kind != "hide"]
    for d in range(DIRS):
        rest_alpha = hide_rest[d].split()[3]
        # The hide never retreats from its rest place.
        hide = warped[hide_name][d].copy()
        hide.paste(hide_rest[d], (0, 0), rest_alpha)
        if profile["cut_under_clothing"]:
            for name, frame in clothing:
                hide.paste(Image.new("RGBA", (32, 32), WHITE), (0, 0), frame[d].split()[3].point(lambda a: 255 if a else 0))
        warped[hide_name][d] = hide
        if not clothing:
            continue
        covered = Image.new("L", (32, 32), 0)
        for name, _ in clothing:
            covered = ImageChops.lighter(covered, warped[name][d].split()[3])
        held = rest_alpha.point(lambda a: 255 if a else 0)
        if profile["cut_under_clothing"] == "fill":
            for name, frame in clothing:
                held = ImageChops.lighter(held, frame[d].split()[3].point(lambda a: 255 if a else 0))
        hole = ImageChops.multiply(held, ImageChops.invert(covered.point(lambda a: 255 if a else 0)))
        if hole.getbbox() is None:
            continue
        # Rest pixels under the warped layer fill what the cut would show.
        for name, frame in clothing:
            layer = Image.composite(frame[d], blank(), hole)
            layer.alpha_composite(warped[name][d])
            warped[name][d] = layer
    return warped


def cover_frame(worn, hide, body_south, within=None):
    """South only: the worn base where the hide does not cut it and the body breast is; within limits the detail."""
    out = blank()
    if worn is None:
        return [out, blank(), blank(), blank()]
    w, b, o = worn[SOUTH].load(), body_south.load(), out.load()
    h = hide[SOUTH].load() if hide else None
    c = within[SOUTH].load() if within else None
    for y in range(32):
        for x in range(32):
            if w[x, y][3] and b[x, y][3] and not (h and h[x, y][3]) and (c is None or c[x, y][3]):
                o[x, y] = w[x, y]
    return [out, blank(), blank(), blank()]


# ---------------------------------------------------------------- profile

def load_profile(path, state):
    profile = {"pair": "stretch", "extra": "stretch", "hide": "stretch"}
    if path is None:
        path = os.path.join(PROFILE_DIR, f"{state}_f.json")
        if not os.path.exists(path):
            print(f"warning: no profile {path}, using defaults")
            path = None
    if path:
        with open(path) as handle:
            profile.update(json.load(handle))
    where = path or "default profile"
    cut_under = profile.pop("cut_under_clothing", False)
    if cut_under not in (True, False, "fill"):
        sys.exit(f"{where}: cut_under_clothing = {cut_under!r}, expected true, false or \"fill\"")
    pins = profile.pop("pin_unchanged", [])
    for name in pins:
        if name not in DIR_NAMES:
            sys.exit(f"{where}: pin_unchanged {pins!r}, expected direction names from {DIR_NAMES}")
    resolved = {"cut_under_clothing": cut_under, "worn": profile.pop("worn", None),
                "pin_unchanged": [DIR_NAMES.index(name) for name in pins]}
    for kind, value in profile.items():
        modes = value if isinstance(value, dict) else {"default": value}
        per_dir = [modes.get(name, modes.get("default", "stretch")) for name in DIR_NAMES]
        for mode in per_dir:
            if mode not in PROFILES:
                sys.exit(f"{where}: {kind} = {value!r}, expected modes from {PROFILES}")
        resolved[kind] = per_dir
    return resolved


# ---------------------------------------------------------------- archive

def split_parts(frame, keep_south):
    return [image if (d == SOUTH) == keep_south else blank() for d, image in enumerate(frame)]


def add_state(dmi, name, frame):
    state = dmi.state(name, dirs=DIRS)
    state.frames.extend(frame)
    state.delays.append(1)


def add_variants(dmi, name, kind, frame):
    """The state and, for pair and extra, its _front / _side splits."""
    add_state(dmi, name, frame)
    if kind != "hide":
        add_state(dmi, name + "_front", split_parts(frame, True))
        add_state(dmi, name + "_side", split_parts(frame, False))


def build_archive(state, layers, worn, profile):
    """layers: (prefix, rest name, kind, size, frame [4]); worn: prefix -> plain worn frame [4]."""
    base = f"{state}_f"
    motion = load_body_motion()
    body_still = load_body_still()
    garments = worn if profile["pin_unchanged"] else {}
    out = Dmi(32, 32)
    groups, still_hides = {}, {}
    for prefix, rest_name, kind, size, frame in layers:
        if kind == "hide":
            still_hides[(prefix, size)] = frame
        if size not in motion:
            add_variants(out, prefix + rest_name, kind, frame)
            continue
        groups.setdefault((prefix, size), []).append((rest_name, kind, frame))

    base_covers = {}

    def make_cover(prefix, size, key, hide, body_south):
        within = None if prefix == base else base_covers.get((size, key))
        frame = cover_frame(worn.get(prefix), hide, body_south, within)
        if prefix == base:
            base_covers[(size, key)] = frame
        return frame

    # Base first: detail covers are limited to the base covers.
    for (prefix, size), hide in sorted(still_hides.items(), key=lambda item: item[0][0] != base):
        if size not in motion and size in body_still:
            add_state(out, f"{prefix}_{size}_cover_front", make_cover(prefix, size, "rest", hide, body_still[size]))
    for (prefix, size), items in sorted(groups.items(), key=lambda item: item[0][0] != base):
        body = motion[size]
        garment = garments.get(prefix)
        warped = {cycle: [warp_group(items, body["rest"], f, profile, garment) for f in body[cycle]] for cycle in CYCLES}
        hide_name = next((name for name, kind, frame in items if kind == "hide"), None)
        if hide_name:
            rest_cover = make_cover(prefix, size, "rest", still_hides[(prefix, size)], body["rest"][SOUTH])
            add_state(out, f"{prefix}_{size}_cover_front", rest_cover)
            for cycle in CYCLES:
                for index, (group, body_frame) in enumerate(zip(warped[cycle], body[cycle]), 1):
                    key = f"{cycle}{index}"
                    cover = make_cover(prefix, size, key, group[hide_name], body_frame[SOUTH])
                    add_state(out, f"{prefix}_{key}_{size}_cover_front", cover)
        for rest_name, kind, frame in items:
            add_variants(out, prefix + rest_name, kind, frame)
            for cycle in CYCLES:
                for index, group in enumerate(warped[cycle], 1):
                    add_variants(out, f"{prefix}_{cycle}{index}{rest_name}", kind, group[rest_name])
    return out


def make_archive(drawing_path, worn_path, state, profile_path=None, out_path=None, force=False, detail_path=None):
    profile = load_profile(profile_path, state)
    if profile["worn"] and os.path.normcase(os.path.abspath(os.path.join(ROOT, profile["worn"]))) != os.path.normcase(os.path.abspath(worn_path)):
        print(f"note: profile names worn {profile['worn']}, using {worn_path}")
    drawing = stills(drawing_path)
    if detail_path:
        drawing.update(stills(detail_path))
    for name in list(drawing):
        old = re.match(rf"^{re.escape(state)}_f_(\d)_detail$", name)
        if old:
            drawing.setdefault(f"{state}_f_detail_{old.group(1)}", drawing[name])
    worn_states = stills(worn_path)
    body = stills(BODY_BREASTS)
    base = f"{state}_f"
    if base not in worn_states:
        sys.exit(f"{worn_path} has no state {base!r}")
    layers, worn = [], {}
    for prefix in (base, base + "_detail"):
        drawn = any(f"{prefix}_{n}" in drawing for n in SIZES)
        if prefix != base and not drawn:
            if prefix in worn_states:
                print(f"note: {worn_path} has {prefix!r} but the drawing has no {prefix}_<N>; no detail layer written")
            continue
        if not drawn:
            sys.exit(f"{drawing_path} has no {prefix}_<N> state")
        if prefix not in worn_states:
            sys.exit(f"{worn_path} has no state {prefix!r} for the drawn {prefix}_<N>")
        worn[prefix] = worn_states[prefix]
        layers += [(prefix,) + layer for layer in split_prefix(drawing, worn_states[prefix], body, prefix, force)]
    out = build_archive(state, layers, worn, profile)
    out_path = out_path or os.path.join(SRC_DIR, state + ".dmi")
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    out.to_file(out_path)
    print(f"{out_path}: {len(out.states)} states")
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("drawing", help="DMI with <state>_f_<N> (and <state>_f_detail_<N>)")
    parser.add_argument("worn", help="the garment's plain worn DMI")
    parser.add_argument("state", help="garment state, without _f")
    parser.add_argument("--detail", help="separate DMI with <state>_f_detail_<N>")
    parser.add_argument("--profile", help="profile JSON; default profiles/<state>_f.json")
    parser.add_argument("--out", help="archive path; default src/<state>.dmi")
    parser.add_argument("--force", action="store_true", help="write even if the split does not rebuild the drawing")
    args = parser.parse_args()
    make_archive(args.drawing, args.worn, args.state, args.profile, args.out, args.force, args.detail)


if __name__ == "__main__":
    main()
