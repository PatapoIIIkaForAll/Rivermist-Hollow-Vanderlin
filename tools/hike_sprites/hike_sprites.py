"""Generates hiked-hem onmob sprites from base clothing DMIs. Run from the repo root: python tools/hike_sprites/hike_sprites.py tools/hike_sprites/manifest.json"""

import argparse
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from dmi import Dmi  # noqa: E402

CLEAR = (0, 0, 0, 0)
SOUTH, NORTH, EAST, WEST = 0, 1, 2, 3
# BYOND dir order inside a state; diagonals borrow the side ramp.
DIR_KIND = [SOUTH, NORTH, EAST, WEST, EAST, WEST, EAST, WEST]
# A back hike is the front hike with the views swapped.
REVERSE_KIND = {SOUTH: NORTH, NORTH: SOUTH, EAST: WEST, WEST: EAST}

HEM_ROWS = 4  # rows at the bottom of each column kept as the hem band
HEM_TOP_LIMIT = 16  # the hem band never starts above this row
WAIST_OFFSET = 20  # peak lift puts the hem band top on row lowest - 20 + 17
MIN_PEAK = 2
MAX_PEAK = 14
SPAN_DEPTH = 5  # columns ending this close to the lowest pixel form the skirt span
MIN_SPAN_COLUMNS = 3
SLOPE = 2  # neighbouring span columns may differ by at most this much lift
NORTH_SCALE = 0.25
SIDE_BACK = 0.3  # side views: back edge lift fraction, front edge is 1.0
ARCH_PLATEAU = 2.5  # front view: columns this close to the centre take the full lift
ARCH_RAMP = 3.0
ARCH_FLOOR = 0.4
UNDER_WINDOW = [(x, y) for x in range(13, 18) for y in range(21, 24)]
# The underwear window is skipped for these bodies and for chest overlays.
NO_WINDOW_TOKENS = ("lamia", "dwarf", "child", "boob")
DERIVED_TOKENS = ("detail", "boob", "alt")


def load_columns(image):
    pixels = image.load()
    return [[pixels[x, y] for y in range(image.height)] for x in range(image.width)]


def store_columns(image, columns):
    out = image.copy()
    pixels = out.load()
    for x, column in enumerate(columns):
        for y, color in enumerate(column):
            pixels[x, y] = color
    return out


def column_bottom(column):
    return max((y for y, c in enumerate(column) if c[3]), default=None)


def bottom_run_length(column):
    bottom = column_bottom(column)
    top = bottom
    while top > 0 and column[top - 1][3]:
        top -= 1
    return bottom - top + 1


def smoothstep(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3 - 2 * t)


def lift_fraction(kind, x, left, right, centre):
    if kind in (SOUTH, NORTH):
        distance = abs(x - centre)
        if distance <= ARCH_PLATEAU:
            return 1.0
        return ARCH_FLOOR + (1 - ARCH_FLOOR) * max(0.0, 1 - (distance - ARCH_PLATEAU) / ARCH_RAMP)
    t = (x - left) / max(1, right - left)
    front = t if kind == EAST else 1 - t
    return SIDE_BACK + (1 - SIDE_BACK) * smoothstep(front)


def plan_frame(columns, kind):
    """Returns {x: (cut row, lift)} for skirt columns; rows [cut, cut + lift) are removed and the column below moves up."""
    runs = {}
    for x, column in enumerate(columns):
        bottom = column_bottom(column)
        if bottom is not None:
            runs[x] = (bottom - bottom_run_length(column) + 1, bottom)
    if not runs:
        return {}
    lowest = max(bottom for _, bottom in runs.values())
    span = sorted(x for x, (_, bottom) in runs.items() if bottom >= lowest - SPAN_DEPTH)
    if len(span) < MIN_SPAN_COLUMNS:
        return {}
    left, right = span[0], span[-1]
    centre = (left + right) / 2
    peak = max(MIN_PEAK, min(MAX_PEAK, lowest - WAIST_OFFSET))
    if kind == NORTH:
        peak = round(peak * NORTH_SCALE)
    lifts = {x: max(0, round(peak * lift_fraction(kind, x, left, right, centre))) for x in span}
    full = [x for x in span if runs[x][1] - runs[x][0] + 1 >= HEM_ROWS]
    if full:
        for x in span:
            if runs[x][1] - runs[x][0] + 1 < HEM_ROWS:
                # Short flare tips borrow the lift of the nearest full skirt column, inward first.
                inward = [c for c in full if (c - x) * (centre - x) > 0] or full
                lifts[x] = lifts[min(inward, key=lambda c: abs(c - x))]
    # Span neighbours count as adjacent even across a sleeve or a gap.
    for a, b in zip(span, span[1:]):
        lifts[b] = max(lifts[b], lifts[a] - SLOPE)
    for a, b in zip(reversed(span[:-1]), reversed(span[1:])):
        lifts[a] = max(lifts[a], lifts[b] - SLOPE)
    plan = {}
    for x in span:
        bottom = runs[x][1]
        lift = max(0, min(lifts[x], bottom - (HEM_TOP_LIMIT + HEM_ROWS - 1)))
        if lift:
            plan[x] = (bottom - (HEM_ROWS - 1) - lift, lift)
    return plan


def apply_plan(columns, plan):
    out = [list(column) for column in columns]
    for x, (cut, lift) in plan.items():
        column = columns[x]
        out[x] = column[:cut] + column[cut + lift:] + [CLEAR] * lift
    return out


def uses_under_window(state_name):
    tokens = state_name.split("_")
    return not any(token in tokens for token in NO_WINDOW_TOKENS)


def parent_state_name(state_name, available, derived_tokens=DERIVED_TOKENS):
    parent = "_".join(token for token in state_name.split("_") if token not in derived_tokens)
    return parent if parent != state_name and parent in available else None


def hike_state(base, state_name, plan_dmi=None, plan_name=None, derived_tokens=DERIVED_TOKENS, reverse=False):
    """Returns hiked frames for one state; plan_dmi and plan_name let a helper icon borrow a worn state's plan."""
    state = base.get_state(state_name)
    if state_name.endswith("_boob"):
        return list(state.frames)
    if plan_dmi is None:
        plan_dmi, plan_name = base, state_name
    names = {s.name for s in plan_dmi.states}
    planner = plan_dmi.get_state(parent_state_name(plan_name, names, derived_tokens) or plan_name)
    window_kind = NORTH if reverse else SOUTH
    frames = []
    for index, frame in enumerate(state.frames):
        kind = DIR_KIND[index % state.dirs] if state.dirs > 1 else SOUTH
        plan_kind = REVERSE_KIND[kind] if reverse else kind
        plan_source = planner.frames[index % len(planner.frames)]
        columns = apply_plan(load_columns(frame), plan_frame(load_columns(plan_source), plan_kind))
        if kind == window_kind and uses_under_window(state_name):
            for x, y in UNDER_WINDOW:
                columns[x][y] = CLEAR
        frames.append(store_columns(frame, columns))
    return frames


def strip_prefix(name, prefixes):
    for prefix in prefixes:
        if name.startswith(prefix):
            return name[len(prefix):]
    return name


def build_hiked_dmi(base_path, state_names, plan_path=None, plan_prefixes=(), derived_tokens=DERIVED_TOKENS, reverse=False):
    base = Dmi.from_file(base_path)
    plan_dmi = Dmi.from_file(plan_path) if plan_path else None
    out = Dmi(base.width, base.height)
    for name in dict.fromkeys(state_names):
        source = base.get_state(name)
        state = out.state(name, loop=source.loop, rewind=source.rewind, movement=source.movement, dirs=source.dirs)
        plan_name = strip_prefix(name, plan_prefixes) if plan_dmi else None
        state.frames = hike_state(base, name, plan_dmi, plan_name, derived_tokens, reverse)
        state.delays = list(source.delays)
        state.hotspots = source.hotspots
    return out


def expand_families(base_path, families, variant_tokens):
    """Picks every base state named after a family plus only known variant suffix tokens."""
    names = [s.name for s in Dmi.from_file(base_path).states]
    picked = []
    for name in dict.fromkeys(names):
        for family in families:
            rest = name[len(family):]
            if name == family or (name.startswith(family + "_") and all(t in variant_tokens for t in rest[1:].split("_"))):
                picked.append(name)
                break
    return picked


def run_job(job, root, variant_tokens):
    base_path = os.path.join(root, job["base"])
    states = list(job.get("states", []))
    if job.get("families"):
        states += [s for s in expand_families(base_path, job["families"], variant_tokens) if s not in states]
    plan_path = os.path.join(root, job["plan_from"]) if job.get("plan_from") else None
    prefixes = job.get("plan_prefixes", [])
    # Some sprite sets use _alt for a different design rather than a restyle of the same cut.
    derived = DERIVED_TOKENS if job.get("alt_uses_parent", True) else tuple(t for t in DERIVED_TOKENS if t != "alt")
    if plan_path:
        # Helper states with no worn counterpart are never requested, so they stay out.
        worn = {s.name for s in Dmi.from_file(plan_path).states}
        kept = []
        for name in states:
            plan_name = strip_prefix(name, prefixes)
            if plan_name in worn or parent_state_name(plan_name, worn, derived):
                kept.append(name)
            else:
                print(f"  skipped {name}: no worn state {plan_name}")
        states = kept
    # output holds the front hike; output_back the same garments raised at the back.
    for key, reverse in (("output", False), ("output_back", True)):
        if not job.get(key):
            continue
        out_path = os.path.join(root, job[key])
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        build_hiked_dmi(base_path, states, plan_path, prefixes, derived, reverse).to_file(out_path)
        print(f"{job[key]}: {len(dict.fromkeys(states))} states")


def compare(base_path, expected_path):
    """Regenerates every state of an existing hiked DMI and counts frame mismatches."""
    expected = Dmi.from_file(expected_path)
    base = Dmi.from_file(base_path)
    bad = 0
    for state in expected.states:
        for index, (mine, theirs) in enumerate(zip(hike_state(base, state.name), state.frames)):
            if mine.tobytes() != theirs.tobytes():
                bad += 1
                print(f"  mismatch {state.name} frame {index}")
    total = sum(len(s.frames) for s in expected.states)
    print(f"{os.path.basename(expected_path)}: {total - bad}/{total} frames identical")
    return bad == 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", nargs="?", help="JSON job list; paths are relative to --root")
    parser.add_argument("--root", default=os.getcwd(), help="repository root for manifest paths")
    parser.add_argument("--compare", nargs=2, metavar=("BASE", "HIKED"), action="append", help="check an existing hiked DMI")
    args = parser.parse_args()
    if args.compare:
        ok = all([compare(base, hiked) for base, hiked in args.compare])
        sys.exit(0 if ok else 1)
    if not args.manifest:
        parser.error("give a manifest or --compare")
    with open(args.manifest, encoding="utf-8") as handle:
        manifest = json.load(handle)
    for job in manifest["jobs"]:
        run_job(job, args.root, set(manifest.get("variant_tokens", [])))


if __name__ == "__main__":
    main()
