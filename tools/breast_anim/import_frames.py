"""Copies per-frame breast stills out of a built sheet into src/frames.dmi.

The build source is one DMI of stills an artist can edit in Dream Maker:
    pair_<N>_f<K>_<L>   walk cycle frame K (1-8)
    pair_<N>_r<K>_<L>   run cycle frame K (1-8)
    pair_<N>_s<K>_<L>   squeeze frame K (1-6)
for sizes 5-8 and layers ADJ, BEHIND. Used once to migrate the PR 272 sheet;
rerun it against any sheet that carries these stills.

usage: python tools/breast_anim/import_frames.py <built.dmi> tools/breast_anim/src/frames.dmi
"""
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from dmi import Dmi  # noqa: E402

FRAME_RE = re.compile(r"^pair_(\d+)_([frs]\d+)_(ADJ|BEHIND)$")


def main(source_path, out_path):
    source = Dmi.from_file(source_path)
    out = Dmi(source.width, source.height)
    for state in source.states:
        if state.movement or not FRAME_RE.match(state.name):
            continue
        copy = out.state(state.name, dirs=state.dirs, loop=state.loop)
        copy.frames = [f.copy() for f in state.frames]
        copy.delays = list(state.delays)
    out.to_file(out_path)
    print("%s: %d frame states" % (out_path, len(out.states)))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
