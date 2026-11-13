# Sorts schema include blocks in CI order. Flags: --check (report only), --hook (Claude Code stdin), FILE paths.
import bisect
import functools
import glob
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCHEMA_DIR = os.path.join(ROOT, "tools", "ticked_file_enforcement", "schemas")
FILE_EXTENSIONS = ("dm", "dmf")
INCLUDE_PREFIX = "#include \""

def schema_targets():
    targets = []
    for schema_path in sorted(glob.glob(os.path.join(SCHEMA_DIR, "*.json"))):
        with open(schema_path, encoding="utf-8") as schema_file:
            targets.append(os.path.join(ROOT, json.load(schema_file)["file"]))
    return targets

def path_key(path):
    return os.path.normcase(os.path.normpath(os.path.abspath(path)))

def display_name(path):
    try:
        return os.path.relpath(path, ROOT)
    except ValueError:
        return path

# Mirror of compare_lines in ticked_file_enforcement.py; keep the two in sync.
def compare_lines(a, b):
    a = a[len(INCLUDE_PREFIX):-1].lower()
    b = b[len(INCLUDE_PREFIX):-1].lower()

    split_by_period = a.split('.')
    a_suffix = ""
    if len(split_by_period) >= 2:
        a_suffix = split_by_period[len(split_by_period) - 1]
    split_by_period = b.split('.')
    b_suffix = ""
    if len(split_by_period) >= 2:
        b_suffix = split_by_period[len(split_by_period) - 1]

    a_segments = a.split('\\')
    b_segments = b.split('\\')

    for (a_segment, b_segment) in zip(a_segments, b_segments):
        a_is_file = a_segment.endswith(FILE_EXTENSIONS)
        b_is_file = b_segment.endswith(FILE_EXTENSIONS)

        if a_is_file and not b_is_file:
            return -1

        if b_is_file and not a_is_file:
            return 1

        if a_segment != b_segment:
            if a_suffix != b_suffix:
                return (a_suffix > b_suffix) - (a_suffix < b_suffix)
            return (a_segment > b_segment) - (a_segment < b_segment)

    return 0

# compare_lines is not transitive, so sort by a total order: per folder, files (by extension, name) before subfolders.
def include_key(line):
    segments = line[len(INCLUDE_PREFIX):-1].lower().split('\\')
    key = [(1, segment) for segment in segments[:-1]]
    key.append((0, segments[-1].rsplit('.', 1)[-1], segments[-1]))
    return key

# Same test CI runs: its own sort must leave the list unchanged.
def ci_accepts(includes):
    return sorted(includes, key=functools.cmp_to_key(compare_lines)) == includes

def sort_includes(includes):
    result = sorted(includes, key=include_key)
    if not ci_accepts(result):
        result = sorted(result, key=functools.cmp_to_key(compare_lines))
    if not ci_accepts(result):
        raise ValueError("no include order satisfies ticked_file_enforcement.py, sort by hand")
    return result

def plural(count, noun):
    return f"{count} {noun}" + ("" if count == 1 else "s")

# Fewest lines that must move: everything outside the longest already-ordered subsequence.
def count_moved(includes, sorted_includes):
    position = {include: index for (index, include) in enumerate(sorted_includes)}
    tails = []
    for include in includes:
        slot = bisect.bisect_left(tails, position[include])
        if slot == len(tails):
            tails.append(position[include])
        else:
            tails[slot] = position[include]
    return len(includes) - len(tails)

def sort_file(path, write):
    """Returns (changed, message). Raises ValueError when the block cannot be sorted safely."""
    name = display_name(path)
    with open(path, encoding="utf-8", errors="surrogateescape", newline="") as file:
        lines = file.read().splitlines(keepends=True)

    begin = end = None
    for index, line in enumerate(lines):
        stripped = line.strip()
        if begin is None and stripped == "// BEGIN_INCLUDE":
            begin = index
        elif begin is not None and stripped == "// END_INCLUDE":
            end = index
            break
    if begin is None or end is None:
        raise ValueError(f"{name}: no // BEGIN_INCLUDE ... // END_INCLUDE block found")

    newline = "\r\n" if lines[begin].endswith("\r\n") else "\n"
    block = lines[begin + 1:end]

    includes = []
    seen = set()
    duplicates = blanks = 0
    for offset, line in enumerate(block):
        stripped = line.strip()
        if not stripped:
            blanks += 1
            continue
        if not (stripped.startswith(INCLUDE_PREFIX) and stripped.endswith("\"")):
            raise ValueError(f"{name}:{begin + offset + 2}: not an include line, fix it by hand: {stripped}")
        key = stripped.lower()
        if key in seen:
            duplicates += 1
            continue
        seen.add(key)
        includes.append(stripped)

    try:
        sorted_includes = sort_includes(includes)
    except ValueError as error:
        raise ValueError(f"{name}: {error}")
    new_block = [include + newline for include in sorted_includes]
    if new_block == block:
        return (False, f"{name}: includes already in order")

    details = [plural(count_moved(includes, sorted_includes), "line") + " moved"]
    if duplicates:
        details.append(plural(duplicates, "duplicate") + " removed")
    if blanks:
        details.append(plural(blanks, "blank line") + " removed")

    if write:
        with open(path, "w", encoding="utf-8", errors="surrogateescape", newline="") as file:
            file.write("".join(lines[:begin + 1] + new_block + lines[end:]))
        return (True, f"{name}: sorted includes ({', '.join(details)})")
    return (True, f"{name}: includes NOT in order ({', '.join(details)})")

def run_hook():
    payload = json.loads(sys.stdin.buffer.read().decode("utf-8") or "{}")
    event = payload.get("hook_event_name", "")
    targets = schema_targets()

    edited = (payload.get("tool_input") or {}).get("file_path")
    if edited:
        if not os.path.isabs(edited):
            edited = os.path.join(payload.get("cwd") or ROOT, edited)
        targets = [target for target in targets if path_key(target) == path_key(edited)]
    elif event not in ("Stop", "SubagentStop"):
        return

    messages = []
    for target in targets:
        if not os.path.isfile(target):
            continue
        try:
            (changed, message) = sort_file(target, write=True)
        except ValueError as error:
            messages.append(f"Include order hook could not sort {error}")
            continue
        if changed:
            messages.append(f"Include order hook: {message}.")

    if not messages:
        return
    text = "\n".join(messages)
    if event == "PostToolUse":
        text += "\nThe hook rewrote the file on disk; re-read it before you edit it again."
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": text}}))
    else:
        print(json.dumps({"systemMessage": text}))

def main():
    args = sys.argv[1:]
    if "--hook" in args:
        try:
            run_hook()
        except Exception as error:
            print(json.dumps({"systemMessage": f"Include order hook failed: {error!r}"}))
        return 0

    write = "--check" not in args
    paths = [arg for arg in args if not arg.startswith("--")] or schema_targets()
    failed = False
    for path in paths:
        try:
            (changed, message) = sort_file(path, write)
        except ValueError as error:
            print(error)
            failed = True
            continue
        print(message)
        if changed and not write:
            failed = True
    return 1 if failed else 0

if __name__ == "__main__":
    sys.exit(main())
