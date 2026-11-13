"""Builds the breast-sized sheet of every garment in GARMENTS.

Source per garment: src/<state>.dmi, the layer archive (hide masks, cloth over
the breasts as pair_<N>_BEHIND/ADJ with _front/_side splits, extra, cover, and
the same under _detail), plus the garment's worn sprite from its own DMI.
Output: modular_rmh/icons/clothing/onmob/breast_sized/<state>.dmi with, for
<p> = <state>_f and (when the worn DMI has a detail state) <state>_f_detail:

    <p>_<N>              N 0-4: base cut by the hide mask plus every cloth layer, 4 dirs, still
    <p>_<N>              N 5-8: south = cut base only; N/E/W = cut base plus side cloth;
                         still + walk movement
    <p>_<N>_run          N 5-8: same, run movement
    <p>_<N>_front        N 5-8: south only: cover + cloth over the breasts; still + walk movement
    <p>_<N>_run_front    N 5-8: run movement
    <p>_<N>_<shot>_front N 5-8: one-shot, loop = 1, frames and delays as in tools/breast_anim
    <p>_<N>_jiggle_front N 5-8: run cycle looping
    <p>_<N>_jiggle       N 5-8: cut base plus side cloth over the run cycle, looping (jiggle emote)
    <p>_<N>_still        N 5-8: the whole garment as for 0-4, no movement (animation preference off)
    <p>_<N>_<tag>...     the same set for a race with its own clothing art (CUSTOM_VARIANTS): that race's
                         worn sprite "<p>_<tag>" as the base, the human layers shifted down by the race's extra breast offset

The south cloth of animated sizes is drawn by a vis_contents child in the game
(modular_rmh/code/modules/mob/breast_visual.dm), so the base keeps only the cut.

usage: python tools/breast_sized_clothing/pack_breast_sized.py [state ...] [--preview <dir>] [--extra state=<worn dmi>]

--extra adds a garment not in GARMENTS for this run (repeatable); with no states named, only the extras build.
"""
import argparse
import os
import sys

from PIL import Image, ImageChops

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
sys.path.insert(0, os.path.join(ROOT, "tools", "breast_anim"))
from dmi import Dmi, SOUTH, DIR_ORDER  # noqa: E402
from build_breast_anims import SHOTS, WALK, RUN, ANIM_SIZES, MOVEMENT_DELAY  # noqa: E402

SRC = os.path.join(HERE, "src")
# Clothing tag -> rows the human layers move down. Dwarf art sits 4 px lower; the layers were drawn for breasts at -1.
CUSTOM_VARIANTS = {"dwarf": 3}
OUT_DIR = os.path.join(ROOT, "modular_rmh/icons/clothing/onmob/breast_sized")
SIZES = range(0, 9)

# state -> worn DMI holding "<state>_f" (and "<state>_f_detail" when the garment paints a detail layer)
GARMENTS = {
    "springgown": "icons/roguetown/clothing/onmob/shirts_gown.dmi",
    "summergown": "icons/roguetown/clothing/onmob/shirts_gown.dmi",
    "wintergown": "icons/roguetown/clothing/onmob/shirts_gown.dmi",
    "fallgown": "icons/roguetown/clothing/onmob/shirts_gown.dmi",
    "royaldress": "icons/roguetown/clothing/onmob/shirts_royalty.dmi",
    "silkdress": "icons/roguetown/clothing/onmob/shirts.dmi",
    "bra": "modular_rmh/icons/clothing/underwear/onmob/bra.dmi",
    "bikini_top": "modular_rmh/icons/clothing/underwear/onmob/bra.dmi",
    "exoticsilkbra": "modular_rmh/icons/clothing/onmob/shirts.dmi",
    "shibari": "modular_rmh/icons/clothing/underwear/onmob/shibari.dmi",
}


def blank(size):
    return Image.new("RGBA", size, (0, 0, 0, 0))


def find(dmi, name, movement=False):
    for state in dmi.states:
        if state.name == name and state.movement == movement:
            return state
    return None


def shift(cells, dy):
    """Cells moved down by dy rows (up when negative); what leaves the cell is dropped."""
    if not dy:
        return cells
    out = []
    for cell in cells:
        moved = blank(cell.size)
        moved.paste(cell, (0, dy))
        out.append(moved)
    return out


class Layers:
    """Reads the archive's cells for one garment and one prefix (<state>_f or <state>_f_detail), shifted by dy rows."""

    def __init__(self, archive, prefix, size, dy=0):
        self.archive = archive
        self.prefix = prefix
        self.cell_size = size
        self.dy = dy

    def cells(self, name):
        state = find(self.archive, name)
        if not state:
            return [blank(self.cell_size) for _ in range(4)]
        return shift(state.frames[:4], self.dy)

    def has(self, name):
        return find(self.archive, name) is not None

    def frame_prefix(self, frame):
        return "%s_%s" % (self.prefix, frame) if frame else self.prefix

    def hide(self, n, frame=""):
        return self.cells("%s_%d_hide" % (self.frame_prefix(frame), n))

    def cover(self, n, frame=""):
        return self.cells("%s_%d_cover_front" % (self.frame_prefix(frame), n))

    def cloth(self, n, part, frame=""):
        """BEHIND, ADJ and extra for one part: "" (all dirs), "_front" or "_side"."""
        fp = self.frame_prefix(frame)
        return [self.cells("%s_pair_%d_BEHIND%s" % (fp, n, part)),
                self.cells("%s_pair_%d_ADJ%s" % (fp, n, part)),
                self.cells("%s_%d_extra%s" % (fp, n, part))]


def cut(base_cells, hide_cells):
    """Base with alpha removed wherever the hide mask is opaque."""
    out = []
    for base, hide in zip(base_cells, hide_cells):
        b = base.copy()
        alpha = b.getchannel("A")
        h = hide.getchannel("A").point(lambda v: 255 - v)
        b.putalpha(ImageChops.multiply(alpha, h))
        out.append(b)
    return out


def stack(*layer_sets):
    """Alpha-composites direction cells, first set at the bottom."""
    out = None
    for cells in layer_sets:
        if out is None:
            out = [c.copy() for c in cells]
            continue
        out = [Image.alpha_composite(a, b) for a, b in zip(out, cells)]
    return out


def add_state(out, name, frame_list, delay, loop=0, movement=False):
    state = out.state(name, dirs=4, loop=loop, movement=movement)
    for cells in frame_list:
        state.frames.extend(cells)
    state.delays = [delay] * len(frame_list)
    return state


def base_frame(layers, base, n, frame=""):
    """Cut base plus side cloth; the south view keeps only the cut."""
    return stack(cut(base, layers.hide(n, frame)), *layers.cloth(n, "_side", frame))


def front_frame(layers, n, frame=""):
    return stack(layers.cover(n, frame), *layers.cloth(n, "_front", frame))


def build_prefix(out, layers, base, prefix, variant=""):
    """States for one prefix; variant ("" or "_<tag>") sits right after the size in every name."""
    for n in SIZES:
        if not layers.has("%s_%d_hide" % (prefix, n)):
            continue
        name = "%s_%d%s" % (prefix, n, variant)
        if n not in ANIM_SIZES:
            add_state(out, name, [stack(cut(base, layers.hide(n)), *layers.cloth(n, ""))], 1)
            continue
        add_state(out, name + "_still", [stack(cut(base, layers.hide(n)), *layers.cloth(n, ""))], 1)
        still = base_frame(layers, base, n)
        add_state(out, name, [still], 1)
        add_state(out, name, [base_frame(layers, base, n, k) for k in WALK], MOVEMENT_DELAY, movement=True)
        add_state(out, name + "_run", [still], 1)
        add_state(out, name + "_run", [base_frame(layers, base, n, k) for k in RUN], MOVEMENT_DELAY, movement=True)
        front_still = front_frame(layers, n)
        add_state(out, name + "_front", [front_still], 1)
        add_state(out, name + "_front", [front_frame(layers, n, k) for k in WALK], MOVEMENT_DELAY, movement=True)
        add_state(out, name + "_run_front", [front_still], 1)
        add_state(out, name + "_run_front", [front_frame(layers, n, k) for k in RUN], MOVEMENT_DELAY, movement=True)
        for shot, (keys, delay) in SHOTS.items():
            add_state(out, "%s_%s_front" % (name, shot), [front_frame(layers, n, k) for k in keys], delay, loop=1)
        add_state(out, name + "_jiggle_front", [front_frame(layers, n, k) for k in RUN], 1)
        add_state(out, name + "_jiggle", [base_frame(layers, base, n, k) for k in RUN], 1)


def find_variant_base(worn, prefix, tag):
    """Worn state of a custom race for prefix: "<state>_f_<tag>", or for the detail prefix either order of the tags."""
    if prefix.endswith("_detail"):
        stem = prefix[:-len("_detail")]
        return find(worn, "%s_%s_detail" % (stem, tag)) or find(worn, "%s_%s" % (prefix, tag))
    return find(worn, "%s_%s" % (prefix, tag))


def build(state_name, worn_path):
    archive = Dmi.from_file(os.path.join(SRC, state_name + ".dmi"))
    worn = Dmi.from_file(os.path.join(ROOT, worn_path))
    out = Dmi(archive.width, archive.height)
    cell_size = (archive.width, archive.height)
    for prefix in ("%s_f" % state_name, "%s_f_detail" % state_name):
        worn_state = find(worn, prefix)
        if not worn_state:
            if prefix.endswith("_f"):
                sys.exit("%s: worn state %s missing in %s" % (state_name, prefix, worn_path))
            continue
        layers = Layers(archive, prefix, cell_size)
        if not layers.has("%s_5_hide" % prefix):
            continue
        build_prefix(out, layers, worn_state.frames[:4], prefix)
        for tag, dy in CUSTOM_VARIANTS.items():
            variant_base = find_variant_base(worn, prefix, tag)
            if not variant_base:
                continue
            build_prefix(out, Layers(archive, prefix, cell_size, dy), variant_base.frames[:4], prefix, "_" + tag)
    os.makedirs(OUT_DIR, exist_ok=True)
    out_path = os.path.join(OUT_DIR, state_name + ".dmi")
    out.to_file(out_path)
    cells = sum(len(s.frames) for s in out.states)
    print("%s: %d states, %d cells, %d KB" % (out_path, len(out.states), cells, os.path.getsize(out_path) // 1024))
    return out


def write_previews(out, directory, state_name):
    """Rest and walk frame 4 of every size, four directions, base with the front over it, 4x."""
    os.makedirs(directory, exist_ok=True)
    rows = []
    for n in SIZES:
        base = find(out, "%s_f_%d" % (state_name, n))
        if not base:
            continue
        front = find(out, "%s_f_%d_front" % (state_name, n))
        row = []
        for frame_set in (("still",), ("walk",)):
            for d in range(4):
                if frame_set[0] == "still":
                    cell = base.frames[d].copy()
                    if front:
                        cell = Image.alpha_composite(cell, front.frames[d])
                else:
                    mb = find(out, "%s_f_%d" % (state_name, n), movement=True)
                    mf = find(out, "%s_f_%d_front" % (state_name, n), movement=True)
                    if not mb:
                        cell = blank((out.width, out.height))
                    else:
                        cell = mb.frames[3 * 4 + d].copy()
                        if mf:
                            cell = Image.alpha_composite(cell, mf.frames[3 * 4 + d])
                row.append(cell)
        rows.append(row)
    if not rows:
        return
    sheet = Image.new("RGBA", (len(rows[0]) * out.width, len(rows) * out.height), (60, 60, 60, 255))
    for y, row in enumerate(rows):
        for x, cell in enumerate(row):
            sheet.alpha_composite(cell, (x * out.width, y * out.height))
    sheet = sheet.resize((sheet.size[0] * 4, sheet.size[1] * 4), Image.NEAREST)
    sheet.save(os.path.join(directory, state_name + ".png"))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("states", nargs="*", help="garment states to build; default all")
    parser.add_argument("--preview", metavar="DIR")
    parser.add_argument("--extra", action="append", default=[], metavar="STATE=WORN_DMI",
                        help="garment not in GARMENTS: archive src/<state>.dmi, worn DMI path")
    args = parser.parse_args()
    garments = dict(GARMENTS)
    extras = []
    for entry in args.extra:
        state_name, sep, worn_path = entry.partition("=")
        if not sep or not state_name or not worn_path:
            parser.error("--extra takes state=<worn dmi>, got %r" % entry)
        garments[state_name] = worn_path
        extras.append(state_name)
    for state_name in args.states or extras or GARMENTS:
        if state_name not in garments:
            parser.error("unknown garment %r; add it to GARMENTS or pass --extra %s=<worn dmi>" % (state_name, state_name))
        out = build(state_name, garments[state_name])
        if args.preview:
            write_previews(out, args.preview, state_name)


if __name__ == "__main__":
    main()
