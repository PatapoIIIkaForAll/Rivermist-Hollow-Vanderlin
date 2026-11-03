#!/usr/bin/env python3

import argparse
import collections
import os
import re
import sys

MODULE = 'modular_rmh/modular/localization'
STRINGS = f'{MODULE}/strings'
REPORT_DIR = 'tmp/localization'
SEPARATOR = ' = '
CASES = 6

VIBELIN_CHAT_FILES = (
	'fragments.txt', 'speech.txt', 'medical.txt', 'world.txt', 'status.txt', 'patterns.txt', 'nouns.txt',
	'honorifics.txt',
)
IMPORTED_ITEMS = 'items.txt'
IMPORTED_TITLES = 'titles.txt'
IMPORTED_DESCRIPTIONS = 'descriptions.txt'
IMPORTED_FRAGMENTS = 'rpg_fragments.txt'
IMPORTED_MAPTEXT = 'maptext.txt'
OWN_FILES = {
	'rmh_items.txt': '# Имена этого билда, склонённые: английское = им. | род. | дат. | вин. | твор. | предл.',
	'rmh_titles.txt': '# Должности и титулы этого билда, склонённые так же, как имена.',
	'rmh_descriptions.txt': '# Описания этого билда: английский текст desc целиком = русский.',
	'rmh_fragments.txt': '# Точные строки чата этого билда: английский текстовый узел = русский.',
	'rmh_patterns.txt': '# Шаблоны чата этого билда (выше общих patterns.txt): ^регулярка$ = шаблон с $1, $2|acc.',
	'rmh_maptext.txt': '# Надписи над картой (balloon alert) этого билда: английский = русский; ключ с ^ — шаблон.',
}
NAME_FILES = ('items.txt', 'rmh_items.txt', 'titles.txt', 'rmh_titles.txt')
BODY_NOUN_FILES = ('nouns.txt',)
DESCRIPTION_FILES = ('descriptions.txt', 'rmh_descriptions.txt')
FRAGMENT_FILES = (
	'rmh_fragments.txt', 'fragments.txt', 'speech.txt', 'medical.txt', 'world.txt', 'status.txt', 'rpg_fragments.txt',
)
PATTERN_FILES = ('rmh_patterns.txt', 'patterns.txt')
MAPTEXT_FILES = ('rmh_maptext.txt', 'maptext.txt')

ARTICLE = re.compile(r'^(?:a|an|the|some)\s+', re.I)
ATOM_ROOTS = ('/obj', '/mob', '/turf', '/area', '/atom')
TEXT_MACRO = re.compile(r'(?:the|The|an|An|a|A|proper|improper|he|He|she|She|his|His|him|Him|himself|herself|hers|Hers|'
	r'th|s|icon|ref|roman|Roman|red|blue|green|black|bold|italic|underline|strike|font)\b')
DROPPED_MACROS = ('proper', 'improper')


class Literal:
	__slots__ = ('pieces', 'static')

	def __init__(self, pieces, static):
		self.pieces = pieces
		self.static = static

	def text(self):
		return ''.join(self.pieces) if self.static else None


class Lexer:
	def __init__(self, text):
		self.text = text
		self.n = len(text)
		self.literals = []

	def run(self):
		out = []
		text, n = self.text, self.n
		i = 0
		while i < n:
			c = text[i]
			nxt = text[i + 1] if i + 1 < n else ''
			if c == '/' and nxt == '/':
				while i < n and text[i] != '\n':
					i += 1
				continue
			if c == '/' and nxt == '*':
				i = self.skip_block_comment(i, out)
				continue
			if c == '@' and (nxt == '"' or (nxt == '{' and i + 2 < n and text[i + 2] == '"')):
				start = i
				i = self.raw_string(i + 1)
				out.append(text[start:i])
				continue
			if c == '"' or (c == '{' and nxt == '"'):
				start = i
				i, literal = self.string(i)
				self.literals.append(literal)
				out.append(text[start:i])
				continue
			if c == "'":
				start = i
				i = self.resource(i)
				out.append(text[start:i])
				continue
			out.append(c)
			i += 1
		return ''.join(out)

	def skip_block_comment(self, i, out):
		depth = 0
		text, n = self.text, self.n
		while i < n:
			if text.startswith('/*', i):
				depth += 1
				i += 2
				continue
			if text.startswith('*/', i):
				depth -= 1
				i += 2
				if depth == 0:
					return i
				continue
			if text[i] == '\n':
				out.append('\n')
			i += 1
		return i

	def raw_string(self, i):
		if self.text[i] == '{':
			end = self.text.find('"}', i + 2)
			return self.n if end < 0 else end + 2
		end = self.text.find('"', i + 1)
		return self.n if end < 0 else end + 1

	def resource(self, i):
		text, n = self.text, self.n
		i += 1
		while i < n and text[i] not in "'\n":
			i += 2 if text[i] == '\\' else 1
		return i + 1

	def string(self, i):
		text, n = self.text, self.n
		long = text[i] == '{'
		i += 2 if long else 1
		pieces, current = [], []
		static = True
		while i < n:
			c = text[i]
			if long and c == '"' and i + 1 < n and text[i + 1] == '}':
				i += 2
				break
			if not long and c == '"':
				i += 1
				break
			if not long and c == '\n':
				break
			if c == '\\':
				i, macro = self.escape(i, current)
				if macro and macro not in DROPPED_MACROS:
					static = False
					pieces.append(''.join(current))
					current = []
				continue
			if c == '[':
				static = False
				pieces.append(''.join(current))
				current = []
				i = self.expression(i + 1)
				continue
			current.append(c)
			i += 1
		pieces.append(''.join(current))
		return i, Literal(pieces, static)

	def escape(self, i, current):
		text, n = self.text, self.n
		nxt = text[i + 1] if i + 1 < n else ''
		if nxt == '\n' or (nxt == '\r' and i + 2 < n and text[i + 2] == '\n'):
			i += 2 if nxt == '\n' else 3
			while i < n and text[i] in ' \t':
				i += 1
			return i, None
		simple = {'n': '\n', 't': '\t', '"': '"', '\\': '\\', '[': '[', ']': ']', "'": "'", '<': '<', '>': '>',
			'{': '{', '}': '}', ' ': ' '}
		match = TEXT_MACRO.match(text, i + 1)
		if match and match.group(0) not in ('n', 't'):
			return match.end(), match.group(0)
		if nxt in simple:
			current.append(simple[nxt])
			return i + 2, None
		current.append(nxt)
		return i + 2, None

	def expression(self, i):
		text, n = self.text, self.n
		depth = 1
		while i < n:
			c = text[i]
			nxt = text[i + 1] if i + 1 < n else ''
			if c == '"' or (c == '{' and nxt == '"'):
				i, literal = self.string(i)
				self.literals.append(literal)
				continue
			if c == "'":
				i = self.resource(i)
				continue
			if c == '[':
				depth += 1
			elif c == ']':
				depth -= 1
				if depth == 0:
					return i + 1
			elif c == '\n':
				return i
			i += 1
		return i


TYPE_LINE = re.compile(r'^/?((?:obj|mob|turf|area|atom|datum)(?:/[A-Za-z0-9_]+)*)/?\s*(?:\{.*)?$')
ALERT_CALL = re.compile(r'balloon_alert(?:_to_viewers)?\(\s*[^,()]+,\s*"([^"\[\]\\]+)"')
VAR_LINE = re.compile(r'^(?:var/)?(name|desc|parent_type)\s*=\s*(.+)$')
INCLUDE = re.compile(r'^\s*#include\s+"([^"]+)"', re.M)


def included_files(root, dme):
	files, seen = [], set()

	def walk(path, base):
		try:
			text = open(path, encoding='utf-8', errors='ignore').read()
		except OSError:
			return
		for match in INCLUDE.finditer(text):
			name = match.group(1).replace('\\', '/')
			if not name.endswith('.dm'):
				continue
			candidates = [os.path.normpath(os.path.join(base, name)), os.path.normpath(os.path.join(root, name))]
			target = next((c for c in candidates if os.path.exists(c)), None)
			if not target or target in seen:
				continue
			seen.add(target)
			files.append(target)
			walk(target, os.path.dirname(target))

	walk(os.path.join(root, dme), root)
	return files


class Codebase:
	def __init__(self, root):
		dme = [f for f in os.listdir(root) if f.endswith('.dme')]
		if len(dme) != 1:
			raise SystemExit(f'expected one .dme in {root}, found {dme}')
		self.root = root
		self.types = collections.defaultdict(dict)
		self.literals = []
		self.alerts = collections.Counter()
		self.files = included_files(root, dme[0])
		for path in self.files:
			self.read(path)

	def read(self, path):
		lexer = Lexer(open(path, encoding='utf-8', errors='ignore').read())
		code = lexer.run()
		self.literals.extend(lexer.literals)
		for text in ALERT_CALL.findall(code):
			self.alerts[text.strip()] += 1
		current = None
		lines = code.split('\n')
		i = 0
		while i < len(lines):
			line = lines[i].rstrip('\r')
			i += 1
			if not line.strip() or line.startswith('#'):
				continue
			if not line.startswith(('\t', ' ')):
				match = TYPE_LINE.match(line.rstrip())
				current = '/' + match.group(1) if match and '(' not in line else None
				if current:
					self.types[current]
				continue
			if current is None:
				continue
			if line.startswith('\t'):
				body = line[1:]
			else:
				body = line.lstrip(' ')
				if len(line) - len(body) > 4:
					continue
			if body.startswith(('\t', ' ')):
				continue
			match = VAR_LINE.match(body.strip())
			if not match:
				continue
			value = match.group(2).strip()
			if value.startswith(('"', '{"')):
				rest = '\n'.join([value] + lines[i:i + 200])
				lexer2 = Lexer(rest)
				end, literal = lexer2.string(0)
				consumed = rest[:end].count('\n')
				i += consumed
				tail = rest[end:].split('\n', 1)[0].strip()
				self.types[current][match.group(1)] = literal if not tail else Literal([], False)
			else:
				self.types[current][match.group(1)] = value

	def parent(self, path):
		parent_type = self.types.get(path, {}).get('parent_type')
		if isinstance(parent_type, str) and parent_type.startswith('/'):
			return parent_type
		return path.rsplit('/', 1)[0] if path.count('/') > 1 else None

	def declaring(self, path, var):
		seen = set()
		while path and path not in seen:
			seen.add(path)
			if var in self.types.get(path, {}):
				return path
			path = self.parent(path)
		return None

	def text_of(self, path, var):
		owner = self.declaring(path, var)
		if not owner:
			return None
		value = self.types[owner][var]
		return value.text() if isinstance(value, Literal) else None


def plain_name(text):
	return ARTICLE.sub('', text.strip()).strip().lower()


def loose_text(text):
	text = re.sub(r'\s+', ' ', text).strip().lower().replace('humen', 'human')
	return re.sub(r'[^\w ]', '', text).strip()


class Matcher:
	def __init__(self, texts, close_pool=None):
		self.exact = set(texts)
		self.loose = {}
		for text in sorted(self.exact):
			self.loose.setdefault(loose_text(text), text)
		pool = close_pool if close_pool is not None else self.exact
		self.close_keys = sorted({loose_text(text) for text in pool})
		self.close_text = {loose_text(text): text for text in sorted(pool)}

	def find(self, text):
		if text in self.exact:
			return text, 'exact'
		found = self.loose.get(loose_text(text))
		return (found, 'loose') if found else (None, None)

	def close(self, text, cutoff):
		import difflib
		match = difflib.get_close_matches(loose_text(text), self.close_keys, n=1, cutoff=cutoff)
		return self.close_text[match[0]] if match else None


class BuildText:
	def __init__(self, base):
		self.base = base
		self.whole = set()
		self.pieces = set()
		self.names = set()
		for literal in base.literals:
			if literal.static:
				text = literal.text().strip()
				if text:
					self.whole.add(text)
					self.names.add(plain_name(text))
			for piece in literal.pieces:
				piece = piece.strip()
				if piece:
					self.pieces.add(piece)
		self.piece_blob = '\x00'.join(sorted(self.pieces))

	def has_text(self, text):
		return text.strip() in self.whole

	def has_name(self, name):
		return plain_name(name) in self.names

	def has_fragment(self, fragment):
		fragment = fragment.strip()
		return fragment in self.pieces or fragment in self.piece_blob


def read_lines(path):
	entries, errors = [], []
	if not os.path.exists(path):
		return entries, errors
	for number, raw in enumerate(open(path, encoding='utf-8-sig'), 1):
		line = raw.strip()
		if not line or line.startswith('#'):
			continue
		if SEPARATOR not in line:
			errors.append((number, 'no " = "', line))
			continue
		key, value = line.split(SEPARATOR, 1)
		key, value = key.strip(), value.strip()
		if not key or not value:
			errors.append((number, 'empty key or value', line))
			continue
		entries.append((number, key.replace('\\n', '\n'), value.replace('\\n', '\n')))
	return entries, errors


def noun_forms(value):
	forms = [form.strip() for form in value.split('|')]
	return forms if len(forms) == CASES else None


def escape(text):
	return text.replace('\r', '').replace('\n', '\\n')


def write_strings(path, header, pairs):
	lines = list(header)
	for pair in pairs:
		if isinstance(pair, str):
			lines.append(pair)
		else:
			lines.append(f'{escape(pair[0])}{SEPARATOR}{escape(pair[1])}')
	os.makedirs(os.path.dirname(path), exist_ok=True)
	with open(path, 'w', encoding='utf-8', newline='\n') as out:
		out.write('\n'.join(lines) + '\n')


def usable_key(key):
	return SEPARATOR not in key and not key.lstrip().startswith('#') and key.strip() == key and key


class Report:
	def __init__(self):
		self.lines = []
		self.tables = {}

	def add(self, text=''):
		print(text)
		self.lines.append(text)

	def table(self, name, rows):
		self.tables[name] = rows

	def write(self, folder):
		os.makedirs(folder, exist_ok=True)
		with open(os.path.join(folder, 'report.md'), 'w', encoding='utf-8', newline='\n') as out:
			out.write('\n'.join(self.lines) + '\n')
		for name, rows in self.tables.items():
			with open(os.path.join(folder, name), 'w', encoding='utf-8', newline='\n') as out:
				for row in rows:
					out.write('\t'.join(escape(str(cell)) for cell in row) + '\n')
		print(f'\nreport: {folder}/report.md')


def atom_names(base):
	names = {}
	for path in sorted(base.types):
		if not path.startswith(ATOM_ROOTS):
			continue
		name = base.text_of(path, 'name')
		if name and name.strip():
			bare = ARTICLE.sub('', name.strip()).strip()
			names.setdefault(loose_text(bare), bare)
	return names


def import_names(report, build, names_by_loose, sources):
	kept, dropped, respelled, seen = [], [], [], set()
	for label, path in sources:
		entries, errors = read_lines(path)
		bad = 0
		for _, key, value in entries:
			if not noun_forms(value):
				bad += 1
				continue
			norm = plain_name(key)
			if norm in seen:
				continue
			seen.add(norm)
			if build.has_name(key):
				kept.append((key, value))
				continue
			found = names_by_loose.get(loose_text(ARTICLE.sub('', key)))
			if found and plain_name(found) not in seen:
				seen.add(plain_name(found))
				kept.append((found, value))
				respelled.append((label, key, found))
				continue
			dropped.append((label, key, value.split('|')[0].strip()))
		report.add(f'- {label}: {len(entries)} lines, {bad + len(errors)} malformed')
	return kept, dropped, respelled


def vibelin_descriptions(report, vibelin_root):
	path = os.path.join(vibelin_root, 'modular_abel/localization/strings/descriptions.txt')
	entries, _ = read_lines(path)
	print('parsing Vibelin', vibelin_root)
	vibelin = Codebase(vibelin_root)
	strong, weak = {}, {}
	missing = interpolated = 0
	for _, key, russian in entries:
		if key not in vibelin.types:
			missing += 1
			continue
		english = vibelin.text_of(key, 'desc')
		if english is None:
			interpolated += 1
			continue
		english = english.strip()
		table = strong if vibelin.declaring(key, 'desc') == key else weak
		table.setdefault(english, (russian, key))
	report.add(f'- Vibelin descriptions.txt: {len(entries)} types; {missing} not found in Vibelin\'s source, '
		f'{interpolated} with a desc that is not one plain string')
	merged = dict(weak)
	merged.update(strong)
	return merged


def rpg_descriptions(report, rpg_root):
	strings = os.path.join(rpg_root, 'modular_redtard/localization/strings')
	english = {key: value for _, key, value in read_lines(os.path.join(strings, 'module_descriptions_en.txt'))[0]}
	russian = {key: value for _, key, value in read_lines(os.path.join(strings, 'module_descriptions_ru.txt'))[0]}
	pairs = {}
	for key in english.keys() & russian.keys():
		pairs.setdefault(english[key].strip(), (russian[key], key))
	report.add(f'- tgstation-RPG module_descriptions_en/ru: {len(pairs)} English descriptions with a Russian one')
	return pairs


def cmd_import(args):
	report = Report()
	report.add('# Импорт наборов перевода')
	report.add()
	print('parsing this build')
	base = Codebase('.')
	build = BuildText(base)
	report.add(f'This build: {len(base.files)} files, {len(base.types)} types, {len(base.literals)} string literals.')
	report.add()

	vibelin_strings = os.path.join(args.vibelin, 'modular_abel/localization/strings')
	rpg_strings = os.path.join(args.rpg, 'modular_redtard/localization/strings')
	for path in (vibelin_strings, rpg_strings):
		if not os.path.isdir(path):
			raise SystemExit(f'no strings folder at {path}')

	report.add('## Чат Vibelin (копируется как есть)')
	for name in VIBELIN_CHAT_FILES:
		source = open(os.path.join(vibelin_strings, name), encoding='utf-8-sig').read().replace('\r\n', '\n')
		header = f'# Imported from Vibelin (modular_abel/localization/strings/{name}) by tools/localization/localization.py.\n'
		with open(os.path.join(STRINGS, name), 'w', encoding='utf-8', newline='\n') as out:
			out.write(header + source)
		entries, errors = read_lines(os.path.join(STRINGS, name))
		report.add(f'- {name}: {len(entries)} lines')
	report.add()

	names_by_loose = atom_names(base)
	report.add('## Имена предметов и существ')
	kept, dropped, respelled = import_names(report, build, names_by_loose, [
		('Vibelin items.txt', os.path.join(vibelin_strings, 'items.txt')),
		('RPG module_items.txt', os.path.join(rpg_strings, 'module_items.txt')),
		('RPG module_nouns.txt', os.path.join(rpg_strings, 'module_nouns.txt')),
	])
	write_strings(os.path.join(STRINGS, IMPORTED_ITEMS), [
		'# Imported by tools/localization/localization.py from Vibelin\'s items.txt and tgstation-RPG\'s module_items.txt',
		'# and module_nouns.txt: only the names this build has. Do not edit: this build\'s own names go to rmh_items.txt.',
		'# english = nom | gen | dat | acc | ins | pre',
	], sorted(kept, key=lambda pair: pair[0].lower()))
	report.add(f'**{len(kept)} kept** ({len(respelled)} of them under this build\'s spelling: case or punctuation), '
		f'**{len(dropped)} dropped** (no such name in this build).')
	report.table('import_dropped_names.tsv', dropped)
	report.table('import_respelled_names.tsv', respelled)
	report.add()

	report.add('## Должности и титулы (склоняемые)')
	kept_titles, dropped_titles, respelled_titles = import_names(report, build, names_by_loose, [
		('RPG module_titles.txt', os.path.join(rpg_strings, 'module_titles.txt')),
	])
	write_strings(os.path.join(STRINGS, IMPORTED_TITLES), [
		'# Imported by tools/localization/localization.py from tgstation-RPG\'s module_titles.txt: only the titles this',
		'# build has. Do not edit: this build\'s own titles go to rmh_titles.txt.',
		'# english = nom | gen | dat | acc | ins | pre',
	], sorted(kept_titles, key=lambda pair: pair[0].lower()))
	report.add(f'**{len(kept_titles)} kept** ({len(respelled_titles)} respelled), **{len(dropped_titles)} dropped.**')
	report.table('import_dropped_titles.tsv', dropped_titles)
	report.add()

	report.add('## Описания (по английскому тексту)')
	sources = [('Vibelin', vibelin_descriptions(report, args.vibelin)), ('tgstation-RPG', rpg_descriptions(report, args.rpg))]
	merged, conflicts = {}, []
	for label, table in sources:
		for english, (russian, key) in table.items():
			if english in merged:
				if merged[english][0] != russian:
					conflicts.append((english, merged[english][2], key))
				continue
			merged[english] = (russian, label, key)
	declared = {}
	for path in sorted(base.types):
		if path.startswith(ATOM_ROOTS) and base.declaring(path, 'desc') == path:
			desc = base.text_of(path, 'desc')
			if desc and desc.strip():
				declared.setdefault(desc.strip(), path)
	matcher = Matcher(build.whole, close_pool=declared)
	kept_desc, respelled_desc, review, dropped_desc, unusable, taken = [], [], [], [], 0, set()
	for english, (russian, label, key) in merged.items():
		found, how = matcher.find(english)
		if found and found in taken:
			continue
		if found and usable_key(found):
			taken.add(found)
			kept_desc.append((found, russian))
			if how == 'loose':
				respelled_desc.append((label, key, english, found))
			continue
		if found:
			unusable += 1
			continue
		close = matcher.close(english, 0.9)
		if close and close not in merged:
			review.append((declared.get(close, ''), close, english, russian, label, key))
		dropped_desc.append((label, key, english))
	write_strings(os.path.join(STRINGS, IMPORTED_DESCRIPTIONS), [
		'# Imported by tools/localization/localization.py from Vibelin\'s descriptions.txt (by its types\' English) and',
		'# tgstation-RPG\'s module_descriptions_en/ru.txt: only the descriptions this build has, keyed by this build\'s',
		'# own English. Do not edit: this build\'s own descriptions go to rmh_descriptions.txt. english desc = Russian',
	], sorted(kept_desc))
	report.add(f'**{len(kept_desc)} kept** ({len(respelled_desc)} of them under this build\'s English, which differs '
		f'only in case, punctuation or spacing), **{len(dropped_desc)} dropped** (no such desc in this build), '
		f'{unusable} unusable as a key, {len(conflicts)} English with two translations (the first kept).')
	report.add(f'Of the dropped, **{len(review)} are close to a desc of this build** (a word changed, often a lore name): '
		'not imported, listed in review_descriptions.tsv with the source\'s Russian to adapt into rmh_descriptions.txt.')
	report.table('import_dropped_descriptions.tsv', dropped_desc)
	report.table('import_respelled_descriptions.tsv', respelled_desc)
	report.table('import_description_conflicts.tsv', conflicts)
	report.table('review_descriptions.tsv', [('type', 'this build', 'source English', 'source Russian', 'source', 'source key')]
		+ sorted(review))
	report.add()

	report.add('## Точные строки чата и надписи над картой tgstation-RPG')
	for label, filename, target, header in (
		('RPG module_fragments.txt', 'module_fragments.txt', IMPORTED_FRAGMENTS, 'exact chat lines'),
		('RPG module_maptext.txt', 'module_maptext.txt', IMPORTED_MAPTEXT, 'balloon alerts and other maptext'),
	):
		entries, _ = read_lines(os.path.join(rpg_strings, filename))
		kept_lines, dropped_lines = [], []
		for _, key, value in entries:
			if key.startswith('^'):
				dropped_lines.append((key, value, 'pattern: not imported'))
			elif not usable_key(key):
				dropped_lines.append((key, value, 'unusable key'))
			elif build.has_fragment(key):
				kept_lines.append((key, value))
			else:
				dropped_lines.append((key, value, 'not in this build'))
		write_strings(os.path.join(STRINGS, target), [
			f'# Imported by tools/localization/localization.py from tgstation-RPG\'s {filename}: the {header} that',
			'# this build\'s code also has. Do not edit by hand.',
		], kept_lines)
		report.add(f'- {label}: {len(entries)} lines, **{len(kept_lines)} kept**, {len(dropped_lines)} dropped')
		report.table(f'import_dropped_{target[:-4]}.tsv', dropped_lines)
	report.add()

	for name, header in OWN_FILES.items():
		path = os.path.join(STRINGS, name)
		if not os.path.exists(path):
			write_strings(path, [header, '# Пишется руками; tools/localization/localization.py этот файл не трогает.'], [])
	report.write(args.report)


def cmd_check(args):
	report = Report()
	report.add('# Проверка строк перевода против билда')
	report.add()
	base = Codebase('.')
	build = BuildText(base)
	report.add(f'This build: {len(base.files)} files, {len(base.types)} types, {len(base.literals)} string literals.')
	report.add()
	malformed = []

	def table(files, nouns=False):
		rows = []
		for name in files:
			entries, errors = read_lines(os.path.join(STRINGS, name))
			malformed.extend((name, number, why, line) for number, why, line in errors)
			for number, key, value in entries:
				if nouns and not noun_forms(value):
					malformed.append((name, number, f'{len(value.split("|"))} forms, expected {CASES}', key))
					continue
				rows.append((name, number, key, value))
		return rows

	report.add('## Имена (склоняемые)')
	names = table(NAME_FILES, nouns=True)
	dead = [(name, number, key) for name, number, key, _ in names if not build.has_name(key)]
	report.add(f'{len(names)} lines, **{len(dead)} match no name in this build**.')
	report.table('check_dead_names.tsv', dead)
	known = {plain_name(key) for _, _, key, _ in names}
	known |= {plain_name(key) for _, _, key, _ in table(BODY_NOUN_FILES, nouns=True)}
	todo, total = {}, set()
	for path in sorted(base.types):
		if not path.startswith(('/obj/', '/mob/')):
			continue
		name = base.text_of(path, 'name')
		if not name:
			continue
		norm = plain_name(name)
		total.add(norm)
		if norm not in known:
			todo.setdefault(norm, (name, path, base.text_of(path, 'desc') or ''))
	report.add(f'Names of /obj and /mob types: {len(total) - len(todo)} of {len(total)} distinct names are translated.')
	report.table('todo_names.tsv', [(name, path, desc) for name, path, desc in todo.values()])
	report.add()

	report.add('## Описания')
	described_rows = table(DESCRIPTION_FILES)
	description_patterns = [row for row in described_rows if row[2].startswith('^')]
	descriptions = [row for row in described_rows if not row[2].startswith('^')]
	dead = [(name, number, key) for name, number, key, _ in descriptions
		if not build.has_text(key) and not build.has_fragment(key)]
	report.add(f'{len(descriptions)} lines and {len(description_patterns)} patterns, '
		f'**{len(dead)} lines match no desc in this build**.')
	report.table('check_dead_descriptions.tsv', dead)
	described = {key for _, _, key, _ in descriptions}
	todo, total = {}, set()
	for path in sorted(base.types):
		if not path.startswith(ATOM_ROOTS):
			continue
		owner = base.declaring(path, 'desc')
		if owner != path:
			continue
		desc = base.text_of(path, 'desc')
		if not desc or not desc.strip():
			continue
		desc = desc.strip()
		total.add(desc)
		if desc not in described:
			todo.setdefault(desc, (path, base.text_of(path, 'name') or ''))
	report.add(f'Plain descs declared on atom types: {len(total) - len(todo)} of {len(total)} distinct texts are translated.')
	report.table('todo_descriptions.tsv', [(path, name, desc) for desc, (path, name) in todo.items()])
	report.add()

	report.add('## Чат и надписи над картой')
	maptext_rows = table(MAPTEXT_FILES)
	for label, rows in (('fragments', table(FRAGMENT_FILES)), ('maptext', maptext_rows)):
		rows = [row for row in rows if not row[2].startswith('^')]
		dead = [(name, number, key) for name, number, key, _ in rows if not build.has_fragment(key)]
		report.add(f'- {label}: {len(rows)} exact lines, {len(dead)} not found in this build\'s code (may be built at runtime)')
		report.table(f'check_dead_{label}.tsv', dead)
	maptext_keys = {row[2] for row in maptext_rows}
	alerts = base.alerts
	todo_alerts = sorted((text, count) for text, count in alerts.items() if text and text not in maptext_keys)
	report.add(f'- balloon alerts written as plain text: {len(alerts) - len(todo_alerts)} of {len(alerts)} translated '
		'(todo_maptext.tsv lists the rest for rmh_maptext.txt)')
	report.table('todo_maptext.tsv', todo_alerts)
	patterns = table(PATTERN_FILES) + [row for row in maptext_rows if row[2].startswith('^')] + description_patterns
	bad_patterns = []
	for name, number, key, value in patterns:
		try:
			compiled = re.compile(key)
		except re.error as error:
			bad_patterns.append((name, number, key, str(error)))
			continue
		for index in re.findall(r'\$(\d+)', value):
			if int(index) > compiled.groups:
				bad_patterns.append((name, number, key, f'${index} but {compiled.groups} groups'))
	report.add(f'- patterns: {len(patterns)} lines, {len(bad_patterns)} broken (bad regex or a $N past the groups)')
	report.table('check_bad_patterns.tsv', bad_patterns)
	report.add()

	report.add('## Формат')
	report.add(f'{len(malformed)} malformed lines (the game skips them).')
	report.table('check_malformed.tsv', malformed + [(n, l, 'pattern', k + ' ' + e) for n, l, k, e in bad_patterns])
	report.write(args.report)
	return 1 if malformed or bad_patterns else 0


def main():
	parser = argparse.ArgumentParser()
	sub = parser.add_subparsers(dest='command', required=True)
	imp = sub.add_parser('import', help='bring the translation sets in, keeping what this build has')
	imp.add_argument('--vibelin', required=True, help='a Vibelin checkout (modular_abel/localization)')
	imp.add_argument('--rpg', required=True, help='a tgstation-RPG checkout (modular_redtard/localization)')
	imp.add_argument('--report', default=REPORT_DIR)
	chk = sub.add_parser('check', help='check the module\'s strings against this build')
	chk.add_argument('--report', default=REPORT_DIR)
	args = parser.parse_args()
	if not os.path.exists('vanderlin.dme'):
		sys.exit('run from the repository root')
	if args.command == 'import':
		cmd_import(args)
		return 0
	return cmd_check(args)


if __name__ == '__main__':
	sys.exit(main())
