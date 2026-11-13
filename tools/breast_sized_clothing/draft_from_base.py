"""Rough per-size drafts of a garment for the artist to finish: full drawings "<state>_f_<N>" (N = 0-8, 4 dirs),
the same format as a hand-drawn garment, ready to edit and then to pass to make_archive.py.

Usage:
    python tools/breast_sized_clothing/draft_from_base.py <worn dmi> <state> <out.dmi> [--style cups|silk|ropes]
        [--cover 0.35] [--preview out.png]

For each size the body breast silhouette of the game sprite (ADJ for S/E/W, BEHIND for N; shifted into the
clothing frame like the split in make_archive.py) decides what changes: base pixels outside it are kept (straps, band),
inside it:
    cups   the lower part of each breast column (below `cover` of its height) is drawn as a cup: the body breast
           shading is remapped onto the base's own palette by brightness rank, the silhouette edge gets the
           darkest colour; the upper part is left empty so the body shows (open-top bra)
    silk   like cups, with the base's brightest warm accent colour as a trim along the cup's top edge
    ropes  nothing covers the breast; the base's colours trace a rope along the top and bottom of each breast
Size 0 is the base unchanged. These are drafts: the shading is borrowed from the body sprite, not drawn.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from dmi import Dmi  # noqa: E402
from PIL import Image  # noqa: E402

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
BODY_BREASTS = os.path.join(ROOT, "modular_rmh/icons/mob/sprite_accessory/genitals/breasts.dmi")
BODY_ICON = os.path.join(ROOT, "icons/roguetown/mob/bodies/f/fm.dmi")
BODY_OFFSET_Y = 1
SIZES = range(9)
SOUTH, NORTH, EAST, WEST = range(4)


def frames(path):
    return {s.name: [f.convert("RGBA") for f in s.frames] for s in Dmi.from_file(path).states if not s.movement}


def pixels(image):
    """Row-major RGBA tuples."""
    access = image.load()
    return [access[x, y] for y in range(image.size[1]) for x in range(image.size[0])]


def shifted(image, dy):
    out = Image.new("RGBA", image.size, (0, 0, 0, 0))
    out.paste(image, (0, dy))
    return out


def luminance(colour):
    r, g, b = colour[:3]
    return 0.299 * r + 0.587 * g + 0.114 * b


def palette_of(base_frames):
    colours = {p[:3] for frame in base_frames for p in pixels(frame) if p[3]}
    return sorted(colours, key=luminance)


def silhouette(body, size, d):
    name = f"pair_{size}_{'BEHIND' if d == NORTH else 'ADJ'}"
    if name not in body:
        return None
    return shifted(body[name][d], BODY_OFFSET_Y)


def columns(image):
    a = image.split()[3].load()
    out = {}
    for x in range(32):
        rows = [y for y in range(32) if a[x, y]]
        if rows:
            out[x] = (rows[0], rows[-1])
    return out


def remap(shade, body_colours, palette):
    """Body breast colour -> base palette colour of the same brightness rank."""
    rank = body_colours.index(shade) / max(len(body_colours) - 1, 1)
    return palette[min(int(rank * len(palette)), len(palette) - 1)]


def draft_frame(base, breast, palette, style, cover):
    out = base.copy()
    if breast is None or breast.getbbox() is None:
        return out
    shape = breast.load()
    px = out.load()
    edge = columns(breast)
    body_colours = sorted({p[:3] for p in pixels(breast) if p[3]}, key=luminance)
    fabric = [c for c in palette if style != "silk" or c[2] >= c[0]] or palette  # silk: cool fabric tones
    accent = max(palette, key=lambda c: c[0] - c[2]) if style == "silk" else None  # silk: warmest colour
    for x in range(32):
        for y in range(32):
            if shape[x, y][3]:
                px[x, y] = (0, 0, 0, 0)
    for x, (top, bottom) in edge.items():
        cut = top + round((bottom - top) * cover)
        for y in range(top, bottom + 1):
            if not shape[x, y][3]:
                continue
            if style == "ropes":
                if y in (cut, bottom):
                    px[x, y] = palette[-1 if y == cut else 0] + (255,)
                continue
            if y < cut:
                continue
            outline = y == bottom or not shape[x - 1, y][3] if x > 0 else True
            outline = outline or (x < 31 and not shape[x + 1, y][3])
            if accent and y == cut:
                colour = accent
            elif outline:
                colour = fabric[0]
            else:
                colour = remap(shape[x, y][:3], body_colours, fabric[1:] or fabric)
            px[x, y] = colour + (255,)
    return out


def preview(dmi_frames, state, path):
    body = frames(BODY_ICON)["fm"]
    breasts = frames(BODY_BREASTS)
    skin = (232, 183, 150)

    def tint(image):
        out = Image.new("RGBA", image.size)
        out.putdata([(p[0] * skin[0] // 255, p[1] * skin[1] // 255, p[2] * skin[2] // 255, p[3]) for p in pixels(image)])
        return out

    sheet = Image.new("RGBA", (32 * len(SIZES), 32 * 4), (70, 70, 90, 255))
    for n in SIZES:
        for d in range(4):
            cell = Image.new("RGBA", (32, 32), (70, 70, 90, 255))
            behind = breasts.get(f"pair_{n}_BEHIND")
            if behind:
                cell.alpha_composite(tint(shifted(behind[d], BODY_OFFSET_Y)))
            cell.alpha_composite(tint(body[d]))
            adj = breasts.get(f"pair_{n}_ADJ")
            if adj:
                cell.alpha_composite(tint(shifted(adj[d], BODY_OFFSET_Y)))
            cell.alpha_composite(dmi_frames[f"{state}_{n}"][d])
            sheet.alpha_composite(cell, (n * 32, d * 32))
    sheet.resize((sheet.width * 4, sheet.height * 4), Image.NEAREST).save(path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("worn")
    parser.add_argument("state")
    parser.add_argument("out")
    parser.add_argument("--style", default="cups", choices=("cups", "silk", "ropes"))
    parser.add_argument("--cover", type=float, default=0.35)
    parser.add_argument("--preview")
    args = parser.parse_args()
    base = frames(args.worn)[args.state]
    body = frames(BODY_BREASTS)
    palette = palette_of(base)
    out = Dmi(32, 32)
    drafted = {}
    for n in SIZES:
        state = out.state(f"{args.state}_{n}", dirs=4)
        result = [draft_frame(base[d], silhouette(body, n, d) if n else None, palette, args.style, args.cover) for d in range(4)]
        state.frames.extend(result)
        state.delays.append(1)
        drafted[f"{args.state}_{n}"] = result
    out.to_file(args.out)
    print(f"{args.out}: {len(SIZES)} sizes, palette {palette}")
    if args.preview:
        preview(drafted, args.state, args.preview)


if __name__ == "__main__":
    main()
