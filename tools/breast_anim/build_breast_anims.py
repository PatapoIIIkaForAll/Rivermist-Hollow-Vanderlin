"""Builds breasts_anim.dmi: every breast state, with real animated states.

Inputs
    breasts.dmi           the stills of every type and size (unchanged, copied in)
    src/frames.dmi        walk (f1-8), run (r1-8) and squeeze (s1-6) stills for pair 5-8

Output states, for animated sizes N (5-8), ADJ layer:
    pair_N_side_ADJ          still + walk movement, south frame blank   -> body overlay
    pair_N_run_side_ADJ      still + run movement, south blank          -> body overlay, sprinting
    pair_N_front_ADJ         still + walk movement, south frame only    -> vis_contents child
    pair_N_run_front_ADJ     still + run movement, south only           -> child, sprinting
    pair_N_<shot>_front_ADJ  one-shot, loop = 1, south only             -> flick() on the child
    pair_N_jiggle_front_ADJ  run cycle looping                          -> child, jiggle emote
    pair_N_jiggle_side_ADJ   run cycle looping, south blank             -> body overlay, jiggle emote
BEHIND layer (never has south pixels, so it stays on the body overlay), same
names with _BEHIND so the accessory can append the layer suffix:
    pair_N_side_BEHIND       still + walk movement
    pair_N_run_side_BEHIND   still + run movement
    pair_N_jiggle_side_BEHIND run cycle looping
The marker (side, front, run, shot) sits before the layer because the sprite
accessory code appends "_ADJ" / "_BEHIND" itself.
Every other still (pair 0-4, quad, sextuple) gets <type>_N_jiggle_<L>, a
looping one-pixel sway generated from the still (jiggle.py).
The plain stills (pair_N_ADJ ...) stay as they are, for dummies and for
players who turned the animation off.

usage: python tools/breast_anim/build_breast_anims.py [--check-ratwood <ratwood breasts.dmi>] [--preview <dir>]
"""
import argparse
import os
import re
import sys

from PIL import Image, ImageChops

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
sys.path.insert(0, HERE)
from dmi import Dmi, SOUTH, DIR_ORDER  # noqa: E402
from jiggle import add_jiggle  # noqa: E402

BASE = os.path.join(ROOT, "modular_rmh/icons/mob/sprite_accessory/genitals/breasts.dmi")
FRAMES = os.path.join(HERE, "src", "frames.dmi")
OUT = os.path.join(ROOT, "modular_rmh/icons/mob/sprite_accessory/genitals/breasts_anim.dmi")

ANIM_SIZES = (5, 6, 7, 8)
WALK = ["f%d" % k for k in range(1, 9)]
RUN = ["r%d" % k for k in range(1, 9)]
MOVEMENT_DELAY = 1

# One-shots: frame keys and ticks per frame. Names are what DM flicks.
SHOTS = {
    "walk_half": (WALK[:4], 2),                       # touch, sigh
    "walk": (WALK, 2),                                # giggle, medium intensity
    "laugh": (WALK + WALK[:4], 2),                    # laugh, climax
    "cough": (["f5", "f6", "f7"], 2),
    "clearthroat": (["f5", "f6", "f7"] * 2, 2),
    "jump": (["r2", "r4", "r6", "r8"] + RUN, 1),
    "dance": (WALK * 2, 2),
    "shiver": (["f1", "f2"] * 2, 1),
    "hit": (RUN[:4], 1),                              # hit, jolt, slap first half
    "slap_b": (RUN[3:], 1),                           # slap second half
    "fall": (RUN, 1),
    "land": (RUN[4:] + RUN[:4], 1),
    "stop": (RUN[4:], 1),                             # run stop
    "bounce": (RUN, 1),                               # full run cycle once
    "pump2": (RUN[:4] * 2, 1),
    "pump3": (RUN[:4] * 3, 1),
    "squeeze": (["s%d" % k for k in range(1, 7)], 1),
    "paizuri": (["s1", "s2", "s3", "s3", "s3", "s2", "s1"], 1),
    "heft": (["s2", "s3", "s4", "s5", "s6"], 1),
    "suckle_a": (["r8", "r2"] * 2, 2),                # one breast raised to the mouth
    "suckle_b": (["r4", "r6"] * 2, 2),                # the other breast
}

STILL_RE = re.compile(r"^(pair|quad|sextuple)_(\d+)_(ADJ|BEHIND)$")


def blank(size):
    return Image.new("RGBA", size, (0, 0, 0, 0))


def find(dmi, name, movement=False):
    for state in dmi.states:
        if state.name == name and state.movement == movement:
            return state
    return None


def cells_of(state, frame=0):
    """The direction cells of one frame, in DIR_ORDER."""
    return state.frames[frame * state.dirs:(frame + 1) * state.dirs]


def copy_state(out, state):
    copy = out.state(state.name, dirs=state.dirs, loop=state.loop, rewind=state.rewind, movement=state.movement)
    copy.frames = [f.copy() for f in state.frames]
    copy.delays = list(state.delays)
    return copy


def only_south(cells):
    """Direction cells of one frame with everything but south blanked."""
    return [c if d == SOUTH else blank(c.size) for c, d in zip(cells, DIR_ORDER)]


def blank_south(cells):
    return [blank(c.size) if d == SOUTH else c for c, d in zip(cells, DIR_ORDER)]


def frame_cells(frames, name):
    state = find(frames, name)
    if not state:
        sys.exit("src/frames.dmi lacks %s" % name)
    return cells_of(state)


def add_state(out, name, frame_list, delay, loop=0, movement=False):
    state = out.state(name, dirs=4, loop=loop, movement=movement)
    for cells in frame_list:
        state.frames.extend(cells)
    state.delays = [delay] * len(frame_list)
    return state


def build(base_path, frames_path, out_path):
    base = Dmi.from_file(base_path)
    frames = Dmi.from_file(frames_path)
    out = Dmi(base.width, base.height)

    # Plain stills, as they are.
    for state in base.states:
        copy_state(out, state)

    for n in ANIM_SIZES:
        for layer in ("ADJ", "BEHIND"):
            still = find(base, "pair_%d_%s" % (n, layer))
            if not still:
                continue
            still_cells = cells_of(still)
            walk = [frame_cells(frames, "pair_%d_%s_%s" % (n, k, layer)) for k in WALK]
            run = [frame_cells(frames, "pair_%d_%s_%s" % (n, k, layer)) for k in RUN]
            if layer == "BEHIND":
                add_state(out, "pair_%d_side_BEHIND" % n, [still_cells], 1)
                add_state(out, "pair_%d_side_BEHIND" % n, walk, MOVEMENT_DELAY, movement=True)
                add_state(out, "pair_%d_run_side_BEHIND" % n, [still_cells], 1)
                add_state(out, "pair_%d_run_side_BEHIND" % n, run, MOVEMENT_DELAY, movement=True)
                add_state(out, "pair_%d_jiggle_side_BEHIND" % n, run, 1)
                continue
            side_still = blank_south(still_cells)
            front_still = only_south(still_cells)
            add_state(out, "pair_%d_side_ADJ" % n, [side_still], 1)
            add_state(out, "pair_%d_side_ADJ" % n, [blank_south(f) for f in walk], MOVEMENT_DELAY, movement=True)
            add_state(out, "pair_%d_run_side_ADJ" % n, [side_still], 1)
            add_state(out, "pair_%d_run_side_ADJ" % n, [blank_south(f) for f in run], MOVEMENT_DELAY, movement=True)
            add_state(out, "pair_%d_front_ADJ" % n, [front_still], 1)
            add_state(out, "pair_%d_front_ADJ" % n, [only_south(f) for f in walk], MOVEMENT_DELAY, movement=True)
            add_state(out, "pair_%d_run_front_ADJ" % n, [front_still], 1)
            add_state(out, "pair_%d_run_front_ADJ" % n, [only_south(f) for f in run], MOVEMENT_DELAY, movement=True)
            for shot, (keys, delay) in SHOTS.items():
                cells = [only_south(frame_cells(frames, "pair_%d_%s_ADJ" % (n, k))) for k in keys]
                add_state(out, "pair_%d_%s_front_ADJ" % (n, shot), cells, delay, loop=1)
            add_state(out, "pair_%d_jiggle_front_ADJ" % n, [only_south(f) for f in run], 1)
            add_state(out, "pair_%d_jiggle_side_ADJ" % n, [blank_south(f) for f in run], 1)

    # Generated jiggle for every still without drawn animation.
    for state in base.states:
        match = STILL_RE.match(state.name)
        if not match or state.movement:
            continue
        kind, n, layer = match.group(1), int(match.group(2)), match.group(3)
        if kind == "pair" and n in ANIM_SIZES:
            continue
        add_jiggle(out, state, "%s_%d_jiggle_%s" % (kind, n, layer))

    out.to_file(out_path)
    return out


def check_ratwood(out, ratwood_path):
    """Generated jiggle states must equal Ratwood's where the stills are shared."""
    ratwood = Dmi.from_file(ratwood_path)
    same = diff = 0
    for state in out.states:
        if "_jiggle_" not in state.name or state.movement:
            continue
        theirs = find(ratwood, state.name)
        if not theirs:
            continue
        equal = len(theirs.frames) == len(state.frames) and all(
            ImageChops.difference(a, b).getbbox() is None for a, b in zip(theirs.frames, state.frames))
        same += equal
        diff += not equal
        if not equal:
            print("  differs from Ratwood:", state.name)
    print("Ratwood jiggle check: %d identical, %d different" % (same, diff))


def write_previews(out, directory):
    """One strip per animated state: frames left to right, south direction, 4x."""
    os.makedirs(directory, exist_ok=True)
    for state in out.states:
        if state.framecount < 2:
            continue
        strip = blank((state.framecount * out.width, out.height))
        for frame in range(state.framecount):
            strip.paste(cells_of(state, frame)[DIR_ORDER.index(SOUTH)], (frame * out.width, 0))
        strip = strip.resize((strip.size[0] * 4, strip.size[1] * 4), Image.NEAREST)
        suffix = "_movement" if state.movement else ""
        strip.save(os.path.join(directory, state.name + suffix + ".png"))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--base", default=BASE)
    parser.add_argument("--frames", default=FRAMES)
    parser.add_argument("--out", default=OUT)
    parser.add_argument("--check-ratwood", metavar="DMI", help="Ratwood breasts.dmi with _jiggle states to compare")
    parser.add_argument("--preview", metavar="DIR", help="write a PNG strip per animated state")
    args = parser.parse_args()
    out = build(args.base, args.frames, args.out)
    cells = sum(len(s.frames) for s in out.states)
    print("%s: %d states, %d cells" % (args.out, len(out.states), cells))
    if args.check_ratwood:
        check_ratwood(out, args.check_ratwood)
    if args.preview:
        write_previews(out, args.preview)


if __name__ == "__main__":
    main()
