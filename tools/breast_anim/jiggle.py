"""Looping jiggle frames derived from a still, for sizes without drawn animation.

Same motion as Ratwood's generate_jiggle_states.py: the whole cell shifts one
pixel per frame. Front and back views sway side to side, side views bob.
Eight frames at one tick each, looping. The frames for sizes whose stills are
shared with Ratwood come out pixel-identical to theirs.
"""
from PIL import Image

from dmi import DIR_ORDER, EAST, WEST, LOOP_UNLIMITED

# Screen-space offsets per frame (+x east, +y north).
CYCLE_FACING = ((1, -1), (0, 0), (-1, -1), (0, 0))
CYCLE_SIDE = ((0, -1), (0, 1), (0, -1), (0, 0))
CYCLES = 2
DELAY = 1


def offsets_for_dir(direction):
    cycle = CYCLE_SIDE if direction in (EAST, WEST) else CYCLE_FACING
    return cycle * CYCLES


def shift(cell, dx, dy):
    if not dx and not dy:
        return cell.copy()
    out = Image.new("RGBA", cell.size, (0, 0, 0, 0))
    out.paste(cell, (dx, -dy))
    return out


def add_jiggle(dmi, source, name):
    """Adds a looping state built from source's first frame."""
    frames = len(offsets_for_dir(DIR_ORDER[0]))
    state = dmi.state(name, dirs=source.dirs, loop=LOOP_UNLIMITED)
    for frame in range(frames):
        for index, direction in enumerate(DIR_ORDER[:source.dirs]):
            dx, dy = offsets_for_dir(direction)[frame]
            state.frames.append(shift(source.frames[index], dx, dy))
    state.delays = [DELAY] * frames
    return state
