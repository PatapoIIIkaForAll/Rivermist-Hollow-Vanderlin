import collections
import re
import sys
from pathlib import Path

PROJECT = Path("vanderlin.dme")
STRINGS = Path("modular_rmh/modular/localization/strings")
LOADER = Path("modular_rmh/modular/localization/code/localization.dm")
ITEM = "/obj/item"
SEPARATOR = " = "
INCLUDE = re.compile(r'^\s*#include\s+"([^"]+\.dm)"', re.M)
TOKEN = re.compile(
    r"""//[^\n]*|/\*.*?\*/|\{".*?"\}|@"[^"\n]*"|"(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*'""",
    re.S,
)
TYPE_LINE = re.compile(r"/?((?:obj|mob|turf|area|atom)(?:/\w+)*)/?\s*(?:\{.*)?")
VAR_LINE = re.compile(r"(?:\t| {1,4})(?:var/)?(name|desc|parent_type|abstract_type)\s*=\s*(.+?)\s*")
LITERAL = re.compile(r'"(\d+)"')
EXPRESSION = re.compile(r"(?<!\\)\[")
ARTICLE = re.compile(r"^(?:the|an|a|some) ", re.I)
FILE_GROUP = re.compile(r'"(\w+)" = list\(([^)]*)\)')
FILE_NAME = re.compile(r'"([^"]+\.txt)"')


def read_text(path):
    return path.read_text(encoding="utf-8", errors="ignore").replace("\r\n", "\n")


def read_code(path, files):
    files[path] = read_text(path)
    for name in INCLUDE.findall(files[path]):
        name = name.replace("\\", "/")
        found = next((p for p in (path.parent / name, Path(name)) if p.exists()), None)
        if found and found not in files:
            read_code(found, files)
    return files


def tokenize(text):
    literals = []

    def replace(match):
        token = match.group(0)
        lines = "\n" * token.count("\n")
        if token.startswith(("//", "/*")):
            return lines
        if token.startswith("'"):
            return "''" + lines
        literals.append(token)
        return f'"{len(literals) - 1}"{lines}'

    return TOKEN.sub(replace, text), literals


def literal_text(token):
    if EXPRESSION.search(token):
        return None
    text = token[2:-2] if token.startswith('{"') else token.lstrip("@")[1:-1]
    text = re.sub(r"\\\n\s*", "", text)
    text = re.sub(r"\\(?:im)?proper ?", "", text)
    return re.sub(r'\\(["\[\]])', r"\1", text)


def read_types(files):
    types = collections.defaultdict(dict)
    for text in files.values():
        code, literals = tokenize(text)
        owner = None
        for line in code.split("\n"):
            if not line.strip() or line.startswith("#"):
                continue
            if not line[0].isspace():
                match = TYPE_LINE.fullmatch(line.rstrip())
                owner = "/" + match.group(1) if match and "/var/" not in line else None
                if owner:
                    types[owner]
                continue
            match = VAR_LINE.fullmatch(line) if owner else None
            if not match:
                continue
            var, value = match.groups()
            literal = LITERAL.fullmatch(value)
            if literal:
                types[owner][var] = literal_text(literals[int(literal.group(1))])
            elif var.endswith("_type"):
                types[owner][var] = value
            else:
                types[owner][var] = "" if value == "null" else None
    return types


def parent_of(types, path):
    declared = types[path].get("parent_type") if path in types else None
    if declared and declared.startswith("/"):
        return declared
    return path.rsplit("/", 1)[0] if path.count("/") > 1 else None


def declaring(types, path, var):
    seen = set()
    while path and path not in seen:
        seen.add(path)
        if path in types and var in types[path]:
            return path
        path = parent_of(types, path)
    return None


def read_keys(filename):
    keys = []
    for raw in read_text(STRINGS / filename).lstrip("\ufeff").splitlines():
        line = raw.strip()
        if line and not line.startswith("#") and SEPARATOR in line:
            keys.append(line.split(SEPARATOR, 1)[0].strip())
    return keys


def plain(text, var):
    return ARTICLE.sub("", text.strip()).strip().lower() if var == "name" else text.strip()


def read_translations(types):
    groups = dict(FILE_GROUP.findall(read_text(LOADER)))
    texts = {"name": set(), "desc": set()}
    paths = {"name": set(), "desc": set()}
    for var, group in (("name", "names"), ("desc", "descriptions")):
        for filename in FILE_NAME.findall(groups.get(group, "")):
            for key in read_keys(filename):
                text = key
                if key.startswith("/"):
                    paths[var].add(key)
                    owner = declaring(types, key, var)
                    text = types[owner][var] if owner else None
                if text:
                    texts[var].add(plain(text, var))
    return texts, paths


def item_paths(types):
    for path in sorted(types):
        if path == ITEM or path.startswith(ITEM + "/"):
            if types[path].get("abstract_type") != path:
                yield path


def main():
    types = read_types(read_code(PROJECT, {}))
    texts, paths = read_translations(types)
    shown = collections.Counter()
    left = collections.Counter()
    rows = {}
    for path in item_paths(types):
        for var in ("name", "desc"):
            owner = declaring(types, path, var)
            text = types[owner][var] if owner else ""
            if text is not None and not text.strip():
                continue
            shown[var] += 1
            if text is None:
                done = owner in paths[var] or path in paths[var]
                key = (var, owner)
            else:
                done = plain(text, var) in texts[var]
                key = (var, plain(text, var))
            if done:
                continue
            left[var] += 1
            shown_as = "(not a plain string)" if text is None else re.sub(r"\s+", " ", text)
            rows.setdefault(key, [var, owner, 0, shown_as])[2] += 1
    if rows:
        print("Add /type/path = nom | gen | dat | acc | ins | pre to rmh_items.txt, /type/path = text to rmh_descriptions.txt.")
        print("Columns: kind, type, how many items show this text, English. One line translates all of them.")
    for var, owner, count, text in sorted(rows.values(), key=lambda row: (row[1], row[0])):
        print(f"{var}\t{owner}\t{count}\t{text}")
    for var, label in (("name", "names"), ("desc", "descriptions")):
        done = shown[var] - left[var]
        print(f"{ITEM} {label}: {done} of {shown[var]} translated ({100 * done / shown[var]:.1f}%), {left[var]} left")
    if rows:
        print(f"::error::{ITEM}: {sum(left.values())} of {sum(shown.values())} texts have no translation, lines to write: {len(rows)}")
    return 1 if rows else 0


if __name__ == "__main__":
    sys.exit(main())
