import collections
import io
import posixpath
import re
import subprocess
import sys
import tarfile

PROJECT = "vanderlin.dme"
STRINGS = "modular_rmh/modular/localization/strings"
LOADER = "modular_rmh/modular/localization/code/localization.dm"
ITEM = "/obj/item"
SOURCES = (":(glob)*.dme", ":(glob)**/*.dm", ":(glob)**/*.txt")
SEPARATOR = " = "
TARGETS = {"name": "rmh_items.txt", "desc": "rmh_descriptions.txt"}
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


def read_tree(ref):
    files = {}
    command = ["git", "archive", "--format=tar", ref, "--", *SOURCES]
    archive = subprocess.run(command, stdout=subprocess.PIPE, check=True).stdout
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        for member in tar:
            if member.isfile():
                text = tar.extractfile(member).read().decode("utf-8", "ignore")
                files[member.name] = text.replace("\r\n", "\n")
    return files


def code_files(files):
    ordered, seen = [], set()

    def walk(path):
        folder = posixpath.dirname(path)
        for name in INCLUDE.findall(files[path]):
            name = name.replace("\\", "/")
            found = posixpath.normpath(posixpath.join(folder, name))
            if found not in files:
                found = posixpath.normpath(name)
            if found in files and found not in seen:
                seen.add(found)
                ordered.append(found)
                walk(found)

    walk(PROJECT)
    return ordered


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
    text = re.sub(r"\\\r?\n\s*", "", text)
    text = re.sub(r"\\(?:im)?proper ?", "", text)
    return re.sub(r'\\(["\[\]])', r"\1", text)


def read_types(files):
    types = collections.defaultdict(dict)
    for path in code_files(files):
        code, literals = tokenize(files[path])
        owner = None
        for number, line in enumerate(code.split("\n"), 1):
            if not line.strip() or line.startswith("#"):
                continue
            if not line[0].isspace():
                match = TYPE_LINE.fullmatch(line.rstrip())
                owner = "/" + match.group(1) if match and "/var/" not in line else None
                if owner:
                    types[owner]
                continue
            match = VAR_LINE.fullmatch(line) if owner else None
            if match:
                var, value = match.groups()
                literal = LITERAL.fullmatch(value)
                text = value if var.endswith("_type") else None
                if literal:
                    text = literal_text(literals[int(literal.group(1))])
                types[owner][var] = (text, path, number)
    return types


def parent_of(types, path):
    declared = types[path].get("parent_type") if path in types else None
    if declared and declared[0].startswith("/"):
        return declared[0]
    return path.rsplit("/", 1)[0] if path.count("/") > 1 else None


def declaring(types, path, var):
    seen = set()
    while path and path not in seen:
        seen.add(path)
        if path in types and var in types[path]:
            return path
        path = parent_of(types, path)
    return None


def shown_text(types, path, var):
    owner = declaring(types, path, var)
    return types[owner][var][0] if owner else None


def read_keys(files, filename):
    keys = []
    for raw in files.get(f"{STRINGS}/{filename}", "").lstrip("\ufeff").splitlines():
        line = raw.strip()
        if line and not line.startswith("#") and SEPARATOR in line:
            keys.append(line.split(SEPARATOR, 1)[0].strip())
    return keys


def plain(text, var):
    return ARTICLE.sub("", text.strip()).strip().lower() if var == "name" else text.strip()


def translated_texts(files, types):
    groups = dict(FILE_GROUP.findall(files.get(LOADER, "")))
    known = {"name": set(), "desc": set()}
    for var, group in (("name", "names"), ("desc", "descriptions")):
        for filename in FILE_NAME.findall(groups.get(group, "")):
            for key in read_keys(files, filename):
                text = shown_text(types, key, var) if key.startswith("/") else key
                if text:
                    known[var].add(plain(text, var))
    return known


def untranslated_items(files):
    types = read_types(files)
    known = translated_texts(files, types)
    found = {}
    for path in types:
        if path != ITEM and not path.startswith(ITEM + "/"):
            continue
        if types[path].get("abstract_type", (None,))[0] == path:
            continue
        for var in ("name", "desc"):
            text = shown_text(types, path, var)
            if text and text.strip() and plain(text, var) not in known[var]:
                found[var, path] = declaring(types, path, var)
    return found, types


def main():
    base_ref = sys.argv[1] if len(sys.argv) > 1 else "HEAD^1"
    head_ref = sys.argv[2] if len(sys.argv) > 2 else "HEAD"
    base, _ = untranslated_items(read_tree(base_ref))
    head, types = untranslated_items(read_tree(head_ref))
    new = collections.Counter((var, owner) for (var, path), owner in head.items() if (var, path) not in base)
    for (var, owner), count in sorted(new.items(), key=lambda row: (row[0][1], row[0][0])):
        text, path, line = types[owner][var]
        text = re.sub(r"\s+", " ", text.replace("%", "%25"))[:120]
        print(f"::error file={path},line={line}::{owner} needs a Russian {var} in {STRINGS}/{TARGETS[var]} (new items with it: {count}): {text}")
    print(f"{ITEM}: {len(new)} new texts without a translation since {base_ref}")
    return 1 if new else 0


if __name__ == "__main__":
    sys.exit(main())
