#define LOCALIZATION_STRINGS "modular_rmh/modular/localization/strings"
#define LOCALIZATION_SEPARATOR " = "
#define LOCALIZATION_PATTERN_MARK "^"
#define LOCALIZATION_TYPE_MARK "/"
#define LOCALIZATION_CACHE_LIMIT 4000
/// Bytes of a strings file read at a time: about seventy lines, far under the thousand that trip the string table.
#define LOCALIZATION_BLOCK 16384
#define LOCALIZATION_CHAT_ASSET "data/chat_localization.json"
#define LOCALIZATION_DECLENSION_MAX_LENGTH 128

GLOBAL_LIST_INIT(localization_cases, list("nom", "gen", "dat", "acc", "ins", "pre"))

GLOBAL_LIST_INIT(localization_files, list(
	"names" = list("items.txt", "words.txt", "titles.txt", "rmh_items.txt", "rmh_titles.txt"),
	"body" = list("nouns.txt"),
	"honorifics" = list("honorifics.txt"),
	"descriptions" = list("descriptions.txt", "rmh_descriptions.txt"),
	"fragments" = list("fragments.txt", "speech.txt", "medical.txt", "world.txt", "status.txt", "rpg_fragments.txt", "rmh_fragments.txt"),
	"patterns" = list("rmh_patterns.txt", "patterns.txt"),
	"maptext" = list("rmh_maptext.txt", "maptext.txt"),
))

GLOBAL_LIST(localization_noun_table)
GLOBAL_LIST(localization_names)
GLOBAL_LIST(localization_honorifics)
GLOBAL_LIST(localization_honorific_titles)
GLOBAL_LIST_EMPTY(localization_declensions)
GLOBAL_LIST_EMPTY(localization_dictionaries)
GLOBAL_LIST_EMPTY(localization_dead_types)
GLOBAL_DATUM(localization_description_dictionary, /datum/localization_dictionary)
GLOBAL_DATUM(localization_maptext_dictionary, /datum/localization_dictionary)

/// A strings file cut into blocks of whole lines.
/// The files are sorted by key, and BYOND hangs each new string that arrives in sorted order one level below the
/// last in its string table: a thousand of them alive together make the engine sort every string in the world, in
/// one stall that grows with the server. So a file is never split into lines whole; a reader takes a block, uses
/// its pairs and drops them before the next.
/proc/localization_blocks(filename)
	. = list()
	var/path = "[LOCALIZATION_STRINGS]/[filename]"
	if(!fexists(path))
		stack_trace("Localization: missing strings file [path]")
		return
	var/text = file2text(path)
	var/total = length(text)
	var/position = 1
	while(position <= total)
		var/cut = (position + LOCALIZATION_BLOCK > total) ? 0 : findtext(text, "\n", position + LOCALIZATION_BLOCK)
		. += copytext(text, position, cut)
		if(!cut)
			break
		position = cut + 1

/// The "key = value" pairs of one block of a strings file.
/proc/localization_pairs(block, filename)
	. = list()
	for(var/raw_line in splittext(block, "\n"))
		var/line = trim(raw_line)
		if(!length(line) || copytext(line, 1, 2) == "#")
			continue
		var/split_at = findtext(line, LOCALIZATION_SEPARATOR)
		if(!split_at)
			stack_trace("Localization: [filename] has a line with no \"[LOCALIZATION_SEPARATOR]\", skipped: [copytext_char(line, 1, 60)]")
			continue
		var/key = trim(copytext(line, 1, split_at))
		var/value = trim(copytext(line, split_at + length(LOCALIZATION_SEPARATOR)))
		if(!length(key) || !length(value))
			continue
		. += list(list(replacetext(key, "\\n", "\n"), replacetext(value, "\\n", "\n")))

/proc/localization_table(list/filenames)
	. = list()
	for(var/filename in filenames)
		for(var/block in localization_blocks(filename))
			for(var/list/pair as anything in localization_pairs(block, filename))
				.[pair[1]] = pair[2]

/proc/localization_atom_type(key, filename)
	var/path = text2path(key)
	if(ispath(path, /atom))
		return path
	GLOB.localization_dead_types |= "[filename]: [key]"
	return null

/proc/localization_nouns(list/filenames)
	. = list()
	var/expected = length(GLOB.localization_cases)
	for(var/filename in filenames)
		for(var/block in localization_blocks(filename))
			for(var/list/pair as anything in localization_pairs(block, filename))
				var/list/forms = splittext(pair[2], "|")
				if(length(forms) != expected)
					stack_trace("Localization: [filename] \"[pair[1]]\" lists [length(forms)] forms, expected [expected]")
					continue
				var/list/cases = list()
				for(var/index in 1 to expected)
					var/form = trim(forms[index])
					if(length(form))
						cases[GLOB.localization_cases[index]] = form
				var/key = pair[1]
				if(copytext(key, 1, 2) == LOCALIZATION_TYPE_MARK)
					var/atom/thing = localization_atom_type(key, filename)
					if(!thing)
						continue
					key = localization_bare_name(initial(thing.name))
				if(length(key) && length(cases))
					.[key] = cases

/proc/localization_load_nouns()
	if(!isnull(GLOB.localization_noun_table))
		return
	var/list/files = GLOB.localization_files
	var/list/things = localization_nouns(files["names"])
	GLOB.localization_names = list()
	for(var/key in things)
		var/list/cases = things[key]
		if(cases["nom"])
			GLOB.localization_names[LOWER_TEXT(key)] = cases["nom"]
	var/list/nouns = things.Copy()
	var/list/body = localization_nouns(files["body"])
	for(var/key in body)
		nouns[key] = body[key]
	GLOB.localization_noun_table = nouns
	GLOB.localization_honorifics = localization_nouns(files["honorifics"])
	var/list/titles = list()
	for(var/title in GLOB.localization_honorifics)
		titles += title
	GLOB.localization_honorific_titles = sortTim(titles, GLOBAL_PROC_REF(cmp_localization_longer_first))

/proc/cmp_localization_longer_first(a, b)
	return length(b) - length(a)

/proc/localization_description_dictionary()
	RETURN_TYPE(/datum/localization_dictionary)
	if(!GLOB.localization_description_dictionary)
		var/list/filenames = list()
		for(var/filename in GLOB.localization_files["descriptions"])
			filenames.Insert(1, filename)
		GLOB.localization_description_dictionary = new /datum/localization_dictionary(filenames, TRUE)
	return GLOB.localization_description_dictionary

/proc/localization_description(english)
	if(!istext(english) || !length(english))
		return null
	var/datum/localization_dictionary/dictionary = localization_description_dictionary()
	. = dictionary.translate(english)
	if(.)
		return
	var/text = trim(english)
	var/static/regex/sentence_end = regex(@"[.!?]\s+", "g")
	var/list/cuts = list()
	var/position = 1
	while(sentence_end.Find(text, position))
		cuts += list(list(sentence_end.index + 1, sentence_end.next))
		position = sentence_end.next
	for(var/head_cut in length(cuts) to 1 step -1)
		var/list/cut = cuts[head_cut]
		var/head = dictionary.translate(copytext(text, 1, cut[1]))
		if(!head)
			continue
		var/list/russian = list(head)
		for(var/sentence_cut in head_cut to length(cuts))
			var/list/starts = cuts[sentence_cut]
			var/list/next = sentence_cut < length(cuts) ? cuts[sentence_cut + 1] : null
			var/translated = dictionary.translate(copytext(text, starts[2], next ? next[1] : 0))
			if(!translated)
				russian = null
				break
			russian += translated
		if(russian)
			return jointext(russian, " ")
	return null

/proc/localization_plain_name(name)
	return trim(replacetext(replacetext("[name]", "\proper", ""), "\improper", ""))

/proc/localization_bare_name(name)
	var/static/regex/article = regex(@"^(?:the|an|a|some) ", "i")
	return article.Replace(localization_plain_name(name), "")

/proc/localization_name(english)
	english = localization_bare_name(english)
	if(!length(english))
		return null
	localization_load_nouns()
	return GLOB.localization_names[LOWER_TEXT(english)]

/proc/localization_noun_forms(value)
	if(!length(value))
		return null
	localization_load_nouns()
	. = GLOB.localization_noun_table[value] || GLOB.localization_declensions[value]
	if(.)
		return
	var/static/regex/article = regex(@"^(?:the|an|a)\s+", "i")
	var/bare = article.Replace(value, "")
	if(!length(bare))
		return null
	. = GLOB.localization_noun_table[bare] || GLOB.localization_declensions[bare]
	if(!.)
		. = GLOB.localization_noun_table[LOWER_TEXT(copytext_char(bare, 1, 2)) + copytext_char(bare, 2)]

/proc/localization_decline_titled(value, case_key)
	localization_load_nouns()
	for(var/title in GLOB.localization_honorific_titles)
		var/prefix_length = length(title) + 1
		if(length(value) <= prefix_length || copytext(value, 1, prefix_length + 1) != "[title] ")
			continue
		var/rest = copytext(value, prefix_length + 1)
		var/list/title_cases = GLOB.localization_honorifics[title]
		var/list/rest_cases = GLOB.localization_noun_table[rest] || GLOB.localization_declensions[rest]
		return "[title_cases[case_key] || title] [rest_cases?[case_key] || rest]"
	return null

/proc/localization_decline(value, case_key)
	var/list/cases = localization_noun_forms(value)
	if(cases)
		return cases[case_key]
	return localization_decline_titled(value, case_key)

/proc/localization_dictionaries_forget()
	for(var/datum/localization_dictionary/dictionary as anything in GLOB.localization_dictionaries)
		dictionary.cache.Cut()

/datum/localization_dictionary
	var/list/fragments = list()
	var/list/patterns = list()
	var/list/rejected = list()
	var/list/cache = list()
	var/strict = FALSE

/datum/localization_dictionary/New(list/filenames, strict = FALSE)
	. = ..()
	src.strict = strict
	GLOB.localization_dictionaries += src
	for(var/filename in filenames)
		for(var/block in localization_blocks(filename))
			for(var/list/pair as anything in localization_pairs(block, filename))
				var/key = pair[1]
				var/mark = copytext(key, 1, 2)
				if(mark == LOCALIZATION_PATTERN_MARK)
					add_pattern(key, pair[2])
					continue
				if(mark == LOCALIZATION_TYPE_MARK)
					var/atom/thing = localization_atom_type(key, filename)
					if(!thing)
						continue
					key = trim(initial(thing.desc))
				if(length(key) && isnull(fragments[key]))
					fragments[key] = pair[2]
	if(length(rejected))
		stack_trace("Localization: [length(rejected)] patterns do not compile on the server and are skipped, the first: [rejected[1]]")

/datum/localization_dictionary/Destroy(force)
	GLOB.localization_dictionaries -= src
	return ..()

/datum/localization_dictionary/proc/add_pattern(source, template)
	var/regex/compiled
	try
		compiled = regex(source)
	catch(var/exception/error)
		rejected += "[source] ([error])"
		return
	if(!compiled)
		rejected += source
		return
	patterns += list(list(compiled, template))

/datum/localization_dictionary/proc/translate(text)
	if(!istext(text) || !length(text))
		return null
	var/cached = cache[text]
	if(!isnull(cached))
		return cached || null
	if(length(cache) >= LOCALIZATION_CACHE_LIMIT)
		cache.Cut()
	var/result
	var/core = trim(text)
	if(length(core))
		var/russian = translate_core(core)
		if(!isnull(russian))
			var/static/regex/leading = regex(@"^\s+")
			var/static/regex/trailing = regex(@"\s+$")
			var/before = leading.Find(text) ? leading.match : ""
			var/after = trailing.Find(text) ? trailing.match : ""
			result = "[before][russian][after]"
	cache[text] = result || ""
	return result

/datum/localization_dictionary/proc/translate_markup(text)
	if(!findtext(text, "<"))
		return translate(text) || text
	var/static/regex/tag = regex(@"<[^>]*>", "g")
	var/list/parts = list()
	var/position = 1
	var/changed = FALSE
	while(tag.Find(text, position))
		var/run = copytext(text, position, tag.index)
		var/tag_text = tag.match
		position = tag.next
		var/russian = translate(run)
		if(russian)
			changed = TRUE
		parts += russian || run
		parts += tag_text
	var/rest = copytext(text, position)
	var/rest_russian = translate(rest)
	if(rest_russian)
		changed = TRUE
	parts += rest_russian || rest
	return changed ? jointext(parts, "") : text

/datum/localization_dictionary/proc/translate_core(core)
	var/exact = fragments[core]
	if(!isnull(exact))
		return exact
	for(var/list/pattern as anything in patterns)
		var/regex/compiled = pattern[1]
		if(!compiled.Find(core))
			continue
		var/list/captures = compiled.group?.Copy()
		var/expanded = expand(pattern[2], captures)
		if(!isnull(expanded))
			return expanded
	return null

/datum/localization_dictionary/proc/expand(template, list/captures)
	var/static/regex/token = regex(@"\$(\d+)(?:\|(nom|gen|dat|acc|ins|pre)(\?)?)?", "g")
	var/static/regex/latin = regex(@"[A-Za-z]")
	var/list/parts = list()
	var/position = 1
	while(token.Find(template, position))
		parts += copytext(template, position, token.index)
		position = token.next
		var/whole = token.match
		var/index = text2num(token.group[1])
		var/case_key = token.group[2]
		var/optional = token.group[3] == "?"
		var/captured = (index >= 1 && index <= length(captures)) ? captures[index] : null
		if(isnull(captured))
			parts += whole
			continue
		if(!case_key)
			if(strict && latin.Find(captured))
				return null
			parts += captured
			continue
		var/declined = localization_decline(captured, case_key)
		if(isnull(declined))
			if(strict && !optional)
				return null
			declined = captured
		parts += declined
	parts += copytext(template, position)
	return jointext(parts, "")

/proc/localization_maptext_dictionary()
	RETURN_TYPE(/datum/localization_dictionary)
	if(!GLOB.localization_maptext_dictionary)
		var/list/files = GLOB.localization_files
		var/list/filenames = files["maptext"] + list("rmh_fragments.txt", "rmh_patterns.txt")
		for(var/filename in files["fragments"] + files["patterns"])
			filenames |= filename
		GLOB.localization_maptext_dictionary = new /datum/localization_dictionary(filenames, TRUE)
	return GLOB.localization_maptext_dictionary

/proc/localization_maptext(text, client/reader)
	if(!istext(text) || !length(text) || !reader || get_client_ui_language(reader) != "ru")
		return text
	return localization_maptext_dictionary().translate_markup(text)

/datum/asset/json/chat_localization
	name = "chat_localization"

/// Everything the server translates by is read here, when SSassets builds this asset at init: the strings are
/// read once per round and no player's first examine or balloon alert pays for it.
/datum/asset/json/chat_localization/register()
	. = ..()
	localization_description_dictionary()
	localization_maptext_dictionary()

/// The dictionary is megabytes and only a Russian reader's panel asks for it. The browse_rsc transport can push
/// every registered asset to every client in the background (ASSET_SIMPLE_PRELOAD): keep it out of that list.
/datum/asset_transport/Initialize(list/assets)
	. = ..()
	preload -= LOCALIZATION_CHAT_ASSET

/datum/asset/json/chat_localization/generate()
	var/list/files = GLOB.localization_files
	localization_load_nouns()
	var/list/patterns = list()
	for(var/filename in files["patterns"])
		for(var/block in localization_blocks(filename))
			for(var/list/pair as anything in localization_pairs(block, filename))
				patterns += list(list("re" = pair[1], "ru" = pair[2]))
	return list(
		"version" = 1,
		"nouns" = GLOB.localization_noun_table,
		"honorifics" = GLOB.localization_honorifics,
		"fragments" = localization_table(files["fragments"]),
		"patterns" = patterns,
	)

/datum/tgui_panel/proc/localization_send_config()
	if(!is_ready())
		return
	var/russian = get_client_ui_language(client) == "ru"
	if(russian)
		window.send_asset(get_asset_datum(/datum/asset/json/chat_localization))
	window.send_message("localization/config", list(
		"lang" = russian ? "ru" : "en",
		"dictionaryUrl" = russian ? SSassets.transport.get_asset_url(LOCALIZATION_CHAT_ASSET) : null,
	))
	if(russian)
		localization_send_declensions(GLOB.localization_declensions)

/datum/tgui_panel/proc/localization_send_declensions(list/payload)
	if(!length(payload) || !is_ready())
		return
	window.send_message("localization/declensions", payload)

/datum/tgui_panel/on_message(type, payload)
	. = ..()
	if(type == "ready")
		localization_send_config()

/proc/localization_russian_reader(mob/user)
	return user?.client && get_client_ui_language(user.client) == "ru"

/proc/localization_russian_name(atom/thing)
	if(!thing?.name || istype(thing, /atom/movable/screen))
		return null
	if(ismob(thing) && (iscarbon(thing) || thing.name != initial(thing.name)))
		return null
	return localization_name(thing.name)

/atom/get_examine_desc(mob/user)
	. = ..()
	if(!istext(.) || !localization_russian_reader(user))
		return
	var/russian = localization_description(.)
	if(russian)
		. = russian

/atom/get_examine_name(mob/user, use_article = TRUE)
	. = ..()
	if(!localization_russian_reader(user))
		return
	var/russian = localization_russian_name(src)
	if(russian)
		. = "<b>[russian]</b>"

/mob/living/get_examine_name(mob/user, use_article = FALSE)
	. = ..()
	if(!localization_russian_reader(user))
		return
	var/russian = localization_russian_name(src)
	if(russian)
		. = "<EM>[russian]</EM>"

/atom/get_over_text_content(mob/user)
	. = ..()
	if(. != name || !localization_russian_reader(user))
		return
	var/russian = localization_russian_name(src)
	if(russian)
		. = russian

/datum/component/decal/blood/get_examine_name(datum/source, mob/user, list/override)
	. = ..()
	if(. != COMPONENT_EXNAME_CHANGED || !localization_russian_reader(user))
		return
	override[EXAMINE_POSITION_BEFORE] = " "
	override[EXAMINE_POSITION_BEFORE + 1] = "[override[EXAMINE_POSITION_BEFORE + 1]] <span class='bloody'>в крови</span>"

/atom/balloon_alert_perform(mob/viewer, text, balloon_flag, x_offset = 0, y_offset = 0)
	return ..(viewer, localization_maptext(text, viewer?.client), balloon_flag, x_offset, y_offset)

/datum/preference/text/localization_declension
	abstract_type = /datum/preference/text/localization_declension
	savefile_identifier = PREF_CHARACTER
	category = "character"
	can_randomize = FALSE
	should_apply = FALSE
	should_update_preview = FALSE
	maximum_value_length = LOCALIZATION_DECLENSION_MAX_LENGTH * 4
	var/case_key
	var/prompt

/datum/preference/text/localization_declension/genitive
	savefile_key = "declension_genitive"
	case_key = "gen"
	prompt = "Родительный падеж — кого? (например: Ивана Петрова)"

/datum/preference/text/localization_declension/dative
	savefile_key = "declension_dative"
	case_key = "dat"
	prompt = "Дательный падеж — кому? (например: Ивану Петрову)"

/datum/preference/text/localization_declension/accusative
	savefile_key = "declension_accusative"
	case_key = "acc"
	prompt = "Винительный падеж — кого? (например: Ивана Петрова)"

/datum/preference/text/localization_declension/instrumental
	savefile_key = "declension_instrumental"
	case_key = "ins"
	prompt = "Творительный падеж — кем? (например: Иваном Петровым)"

/datum/preference/text/localization_declension/prepositional
	savefile_key = "declension_prepositional"
	case_key = "pre"
	prompt = "Предложный падеж — о ком? (например: об Иване Петрове)"

/datum/preferences/proc/read_localization_declensions()
	. = list()
	for(var/datum/preference/text/localization_declension/field as anything in subtypesof(/datum/preference/text/localization_declension))
		var/value = trim(read_preference(field))
		if(length(value))
			.[initial(field.case_key)] = value

/proc/localization_register_declensions(name, list/cases)
	if(!name || !length(cases) || (GLOB.localization_declensions[name] ~= cases))
		return
	GLOB.localization_declensions[name] = cases
	localization_dictionaries_forget()
	var/list/delta = list("[name]" = cases)
	for(var/client/target as anything in GLOB.clients)
		if(get_client_ui_language(target) == "ru")
			target.tgui_panel?.localization_send_declensions(delta)

/datum/preferences/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, character_setup = FALSE)
	. = ..()
	if(!character_setup && !QDELETED(character))
		localization_register_declensions(character.real_name, read_localization_declensions())

/client/verb/localization_edit_declensions()
	set name = "Склонения имени / Name Cases"
	set category = "OOC"
	set desc = "Падежи имени вашего персонажа для русского чата / Your character's name in Russian cases, for the Russian chat."

	if(!prefs)
		return
	var/name = prefs.read_preference(/datum/preference/text/real_name)
	while(prefs && mob)
		var/list/choices = list()
		for(var/datum/preference/text/localization_declension/field as anything in subtypesof(/datum/preference/text/localization_declension))
			var/value = prefs.read_preference(field)
			choices["[initial(field.prompt)]: [length(value) ? value : "—"]"] = field
		var/choice = tgui_input_list(mob, "Персонаж: [name]. Пустой падеж — имя как есть.", "Склонения имени", choices)
		if(!choice || !prefs || !mob)
			return
		var/datum/preference/text/localization_declension/field = choices[choice]
		var/new_value = tgui_input_text(mob, initial(field.prompt), "Склонения имени", prefs.read_preference(field), max_length = LOCALIZATION_DECLENSION_MAX_LENGTH, encode = FALSE)
		if(isnull(new_value) || !prefs)
			continue
		prefs.write_preference(field, trim(new_value))
		prefs.save_character()
		localization_register_declensions(name, prefs.read_localization_declensions())

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/datum/unit_test/localization_strings/Run()
	for(var/kind in GLOB.localization_files)
		for(var/filename in GLOB.localization_files[kind])
			if(!fexists("[LOCALIZATION_STRINGS]/[filename]"))
				TEST_FAIL("[LOCALIZATION_STRINGS]/[filename] is missing")
				continue
			var/whole = file2text("[LOCALIZATION_STRINGS]/[filename]")
			var/joined = jointext(localization_blocks(filename), "\n")
			// A cut that lands on the file's last newline leaves no empty block after it.
			if(joined != whole && "[joined]\n" != whole)
				TEST_FAIL("[filename] read by blocks is not the file: a block was cut inside a line or a character")
	var/datum/localization_dictionary/maptext = localization_maptext_dictionary()
	if(length(maptext.rejected))
		TEST_FAIL("[length(maptext.rejected)] chat patterns do not compile in BYOND, the first: [maptext.rejected[1]]")
	var/datum/localization_dictionary/descriptions = localization_description_dictionary()
	if(length(descriptions.rejected))
		TEST_FAIL("[length(descriptions.rejected)] description patterns do not compile in BYOND, the first: [descriptions.rejected[1]]")
	var/datum/asset/json/chat_localization/asset = get_asset_datum(/datum/asset/json/chat_localization)
	var/list/dictionary = asset.generate()
	for(var/section in list("nouns", "honorifics", "fragments", "patterns"))
		if(!length(dictionary[section]))
			TEST_FAIL("the chat dictionary has no [section]")
	if(length(GLOB.localization_dead_types))
		TEST_FAIL("[length(GLOB.localization_dead_types)] strings lines name a type the build does not have, the first: [GLOB.localization_dead_types[1]]")
	var/missing_descs = 0
	var/missing_names = 0
	for(var/atom/thing as anything in subtypesof(/atom))
		var/desc = trim(initial(thing.desc))
		if(length(desc) && !descriptions.fragments[desc])
			missing_descs++
		var/name = initial(thing.name)
		if(name && !GLOB.localization_names[LOWER_TEXT(localization_bare_name(name))])
			missing_names++
	TEST_NOTICE(src, "Localization: [missing_descs] atom types show an untranslated desc, [missing_names] an untranslated name.")

/datum/unit_test/localization_engine/Run()
	var/datum/localization_dictionary/engine = new(list())
	engine.fragments["The door is locked."] = "Дверь заперта."
	engine.add_pattern(@"^(.+?) bites (.+?)!$", "$1 кусает $2|acc!")
	GLOB.localization_declensions["Ivan Unittest"] = list("acc" = "Ивана Юниттеста")
	localization_dictionaries_forget()
	if(engine.translate(" The door is locked. ") != " Дверь заперта. ")
		TEST_FAIL("an exact line loses its edges or its translation")
	if(engine.translate("Wolf bites Ivan Unittest!") != "Wolf кусает Ивана Юниттеста!")
		TEST_FAIL("a pattern does not decline a character's name: [engine.translate("Wolf bites Ivan Unittest!")]")
	engine.strict = TRUE
	engine.cache.Cut()
	if(!isnull(engine.translate("Wolf bites Ivan Unittest!")))
		TEST_FAIL("a strict dictionary leaves an English capture in a translated line")
	engine.add_pattern(@"^I see (.+?)\.$", "Я вижу $1|acc.")
	engine.add_pattern(@"^I hear (.+?)\.$", "Я слышу $1|acc?.")
	if(engine.translate("I see Ivan Unittest.") != "Я вижу Ивана Юниттеста.")
		TEST_FAIL("a strict dictionary does not decline a known name: [engine.translate("I see Ivan Unittest.")]")
	if(!isnull(engine.translate("I see Nobody Known.")))
		TEST_FAIL("a strict dictionary takes a line whose capture nothing declines")
	if(engine.translate("I hear Nobody Known.") != "Я слышу Nobody Known.")
		TEST_FAIL("an optional case ($1|acc?) does not keep a capture nothing declines")
	if(!isnull(engine.translate("Nothing matches this line.")))
		TEST_FAIL("a line no entry takes is translated")
	GLOB.localization_declensions -= "Ivan Unittest"
	qdel(engine)

/datum/unit_test/localization_preferences/Run()
	var/list/seen = list()
	for(var/datum/preference/text/localization_declension/field as anything in subtypesof(/datum/preference/text/localization_declension))
		var/case_key = initial(field.case_key)
		if(case_key == "nom" || !(case_key in GLOB.localization_cases))
			TEST_FAIL("[field] holds the case \"[case_key]\"")
		if(case_key in seen)
			TEST_FAIL("[field] holds \"[case_key]\" a second time")
		seen += case_key
	if(length(seen) != length(GLOB.localization_cases) - 1)
		TEST_FAIL("the name's cases are [length(seen)], not [length(GLOB.localization_cases) - 1]")
	var/datum/preference/choiced/ui_language/language = GLOB.preference_entries[/datum/preference/choiced/ui_language]
	if(!language.is_valid("ru", null) || !language.is_valid("en", null) || language.is_valid("Русский", null))
		TEST_FAIL("the interface language takes something other than \"en\" and \"ru\"")
	if(sanitize_preferred_ui_language("RU") != "ru" || sanitize_preferred_ui_language("de") != "en" || sanitize_preferred_ui_language(null) != "en")
		TEST_FAIL("sanitize_preferred_ui_language() lets a wrong language through")

#endif

#undef LOCALIZATION_STRINGS
#undef LOCALIZATION_SEPARATOR
#undef LOCALIZATION_PATTERN_MARK
#undef LOCALIZATION_TYPE_MARK
#undef LOCALIZATION_CACHE_LIMIT
#undef LOCALIZATION_BLOCK
#undef LOCALIZATION_CHAT_ASSET
#undef LOCALIZATION_DECLENSION_MAX_LENGTH
