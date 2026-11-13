#define DICE_SYNTAX_HELP "A roll is written as (number of dice)D(faces)(+ or - bonus)/(difficulty). \
	Only the faces are required. D20 throws one twenty-sided die. 2D6+3 throws two six-sided dice and \
	adds three. D20-5/DC15 throws one twenty-sided die, subtracts five, and compares the result against a \
	difficulty of fifteen."

#define DICE_MAX_COUNT 24
#define DICE_MAX_SIDES 99
#define DICE_MAX_BONUS 99
#define DICE_SUM_MAX_TERMS 6

#define DICE_ROLL_COOLDOWN (10 SECONDS)

#define STAT_ROLL_DIE 20
#define STAT_ROLL_MAX_DC 40

#define ROLL_STAT_CHARISMA "charisma"

GLOBAL_LIST_INIT(rollable_stats, list(
	"Strength" = STATKEY_STR,
	"Perception" = STATKEY_PER,
	"Intelligence" = STATKEY_INT,
	"Constitution" = STATKEY_CON,
	"Endurance" = STATKEY_END,
	"Speed" = STATKEY_SPD,
	"Fortune" = STATKEY_LCK,
	"Charisma" = ROLL_STAT_CHARISMA,
))

/mob/living/proc/resolve_stat_key(stat_key)
	if(stat_key == ROLL_STAT_CHARISMA)
		return (get_stat(STATKEY_INT) > get_stat(STATKEY_LCK)) ? STATKEY_INT : STATKEY_LCK
	return stat_key

/proc/stat_roll_modifier(stat_value)
	return floor((stat_value - 10) / 2)

/mob/living/proc/can_roll_dice()
	if(stat)
		return FALSE
	if(world.time < next_emote)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_EMOTEMUTE))
		return FALSE
	if(client?.prefs.muted & MUTE_IC)
		to_chat(src, span_warning("I cannot send IC messages. (muted)"))
		return FALSE
	return TRUE

/proc/contest_partners_valid(mob/living/challenger, mob/living/defender)
	if(QDELETED(challenger) || QDELETED(defender))
		return FALSE
	if(challenger.stat || defender.stat)
		return FALSE
	if(defender.cmode)
		return FALSE
	return (defender in range(challenger, 2))

/proc/stat_god(stat_key)
	var/static/list/god_by_stat = list(
		STATKEY_STR = "tempus",
		STATKEY_PER = "helm",
		STATKEY_INT = "oghma",
		STATKEY_CON = "lathander",
		STATKEY_END = "ilmater",
		STATKEY_SPD = "mask",
		STATKEY_LCK = "tymora",
		ROLL_STAT_CHARISMA = "sune",
	)
	return god_by_stat[stat_key] || "neutral"

/proc/roll_tooltip_colour(roll_class)
	var/static/list/colours = list(
		"good" = "#e8c96a",
		"bad" = "#d4607f",
		"neutral" = "#dcdcb4",
		"tempus" = "#c8665c",
		"helm" = "#9fb4c8",
		"oghma" = "#8eaee0",
		"lathander" = "#e8a06a",
		"ilmater" = "#cdb48a",
		"mask" = "#a89bc9",
		"tymora" = "#d8d8e0",
		"sune" = "#e07a9a",
	)
	return colours[roll_class] || colours["neutral"]

/proc/stat_span(stat_key, str, in_tooltip = FALSE)
	var/god = stat_god(stat_key)
	if(in_tooltip)
		return "<font color='[roll_tooltip_colour(god)]'>[str]</font>"
	return "<span class='roll_[god]'>[str]</span>"

/proc/roll_outcome_span(outcome, str, critical = FALSE, in_tooltip = FALSE)
	var/roll_class = isnull(outcome) ? "neutral" : (outcome ? "good" : "bad")
	if(in_tooltip)
		return "<font color='[roll_tooltip_colour(roll_class)]'>[str]</font>"
	if(critical && !isnull(outcome))
		return "<span class='roll_crit_[outcome ? "good" : "bad"]'>[str]</span>"
	return "<span class='roll_[roll_class]'>[str]</span>"

/proc/roll_tooltip(outcome, headline, list/rows)
	var/body = jointext(rows, "<br>")
	if(headline)
		return roll_outcome_span(outcome, "<b>[headline]</b>", in_tooltip = TRUE) + "<br>" + body
	return body

/proc/roll_dice_token(outcome, label, tooltip, list/dice, sides, list/throw_labels, list/throw_outcomes, list/throw_stats, list/throw_footers, critical = FALSE)
	var/outcome_class = isnull(outcome) ? "neutral" : (outcome ? "good" : "bad")
	var/list/throws = list()
	for(var/list/throw_faces in dice)
		throws += jointext(throw_faces, "-")
	var/list/safe_labels = list()
	for(var/throw_label in throw_labels)
		safe_labels += replacetext("[throw_label]", "|", "")
	var/list/safe_footers = list()
	for(var/throw_footer in throw_footers)
		safe_footers += replacetext("[throw_footer]", "|", "")
	var/list/outcome_classes = list()
	for(var/i in 1 to length(throw_outcomes))
		var/throw_outcome = throw_outcomes[i]
		outcome_classes += isnull(throw_outcome) ? "neutral" : (throw_outcome ? "good" : "bad")
	return "<span data-component=\"RollTooltip\" data-html=\"[html_encode(tooltip)]\" data-dice=\"[html_encode(jointext(throws, "|"))]\" data-labels=\"[html_encode(jointext(safe_labels, "|"))]\" data-sides=\"[sides]\" data-outcome=\"[outcome_class]\" data-outcomes=\"[jointext(outcome_classes, "|")]\" data-stats=\"[html_encode(jointext(throw_stats || list(), "|"))]\" data-footers=\"[html_encode(jointext(safe_footers, "|"))]\" class=\"tooltip\">[roll_outcome_span(outcome, "<b>[label]</b>", critical)]</span>"

/mob/living/proc/announce_roll(chat_message, runechat, show_name = TRUE)
	var/message = show_name ? "[get_emote_name_html()] [chat_message]" : chat_message

	log_message(chat_message, LOG_EMOTE)
	var/turf/our_turf = get_turf(src)
	for(var/mob/ghost as anything in GLOB.dead_mob_list)
		if(!ghost.client || isnewplayer(ghost) || ghost.stat != DEAD)
			continue
		if(!(ghost.client.prefs?.read_preference(/datum/preference/bitwise/chat_toggles) & CHAT_GHOSTSIGHT))
			continue
		if(ghost in viewers(our_turf, null))
			continue
		ghost.show_message(message)
	visible_message(message, runechat_message = runechat)

/proc/stat_header(stat_key, read_stat, stat_value, list/trait_sources)
	var/stat_name = uppertext(stat_key)
	if(read_stat && read_stat != stat_key)
		stat_name += " ([uppertext(copytext(read_stat, 1, 4))])"
	var/header = "[stat_span(stat_key, "<b>[stat_name]</b>", TRUE)] [stat_value] <b>([signed_number(stat_roll_modifier(stat_value))])</b>"
	if(length(trait_sources) == 1)
		var/trait_key = trait_sources[1]
		header += "<br>[trait_key] <b>[signed_number(trait_sources[trait_key])]</b>"
	else if(length(trait_sources) > 1)
		var/trait_total = 0
		for(var/trait_key in trait_sources)
			trait_total += trait_sources[trait_key]
		header += "<br>Traits <b>[signed_number(trait_total)]</b>"
	return header

/proc/stat_trait_breakdown(list/trait_sources)
	if(length(trait_sources) < 2)
		return null
	var/list/entries = list()
	for(var/trait_key in trait_sources)
		entries += "[trait_key] <b>[signed_number(trait_sources[trait_key])]</b>"
	return jointext(entries, ", ")

/proc/roll_sum(outcome, list/terms)
	var/total = 0
	var/sum = ""
	var/added = FALSE
	for(var/i in 1 to length(terms))
		var/term = terms[i]
		total += term
		if(i == 1)
			sum = "[term]"
		else if(term)
			sum += " [term > 0 ? "+" : "-"] [abs(term)]"
			added = TRUE
	if(!added)
		return roll_outcome_span(outcome, "<b>[total]</b>", in_tooltip = TRUE)
	return "[sum] = " + roll_outcome_span(outcome, "<b>[total]</b>", in_tooltip = TRUE)

/proc/signed_number(number)
	return "[number >= 0 ? "+" : "-"][abs(number)]"

/proc/natural_roll_outcome(die)
	if(die == STAT_ROLL_DIE)
		return TRUE
	if(die == 1)
		return FALSE
	return null

/mob/living/carbon/human/verb/roll_dice(expression as text|null)
	set name = "Roll Dice"
	set desc = "Throw dice, optionally against a difficulty and with modifiers."
	set category = "Emotes.Rolling"

	if(!can_roll_dice())
		return

	if(!expression)
		expression = tgui_input_text(src, DICE_SYNTAX_HELP, "PRAISE TYMORA", max_length = 32)
		if(!expression || !can_roll_dice())
			return

	if(!do_dice_roll(expression))
		return

	next_emote = world.time + DICE_ROLL_COOLDOWN

/mob/living/proc/do_dice_roll(expression)
	var/static/regex/dice_expression = regex(@"^(\d*)d(\d+)([+-]\d+)?(?:/?(?:dc)?(\d+))?$", "i")
	var/cleaned = replacetext(LOWER_TEXT(expression), " ", "")

	if(!dice_expression.Find(cleaned))
		to_chat(src, span_warning("That is not a roll I know how to make."))
		to_chat(src, span_notice(DICE_SYNTAX_HELP))
		return FALSE

	var/count = text2num(dice_expression.group[1]) || 1
	var/sides = text2num(dice_expression.group[2])
	var/bonus = text2num(dice_expression.group[3]) || 0
	var/dc = text2num(dice_expression.group[4])

	if(count > DICE_MAX_COUNT)
		to_chat(src, span_warning("I cannot throw more than [DICE_MAX_COUNT] dice at once."))
		return FALSE
	if(sides < 2 || sides > DICE_MAX_SIDES)
		to_chat(src, span_warning("A die has between 2 and [DICE_MAX_SIDES] faces."))
		return FALSE
	if(abs(bonus) > DICE_MAX_BONUS)
		to_chat(src, span_warning("That bonus is beyond reckoning."))
		return FALSE

	var/list/results = list()
	var/total = bonus
	for(var/i in 1 to count)
		var/result = rand(1, sides)
		results += result
		total += result

	var/dice_string = "[count]d[sides]"
	if(bonus)
		dice_string += (bonus > 0 ? "+[bonus]" : "[bonus]")

	var/natural = (count == 1 && sides == STAT_ROLL_DIE) ? natural_roll_outcome(results[1]) : null
	var/critical = !isnull(natural)

	var/outcome = null
	if(!isnull(dc))
		outcome = critical ? natural : (total >= dc)
	else if(critical)
		outcome = natural

	var/header = "<b>[count]D[sides]</b>"
	if(bonus)
		header += "<br>Bonus <b>[signed_number(bonus)]</b>"
	var/list/terms = (count > DICE_SUM_MAX_TERMS) ? list(total - bonus) : results.Copy()
	terms += bonus
	var/footer = roll_sum(outcome, terms)
	if(!isnull(dc))
		footer += "<br>Needs [dc] or more"
	if(critical)
		footer += "<br>[roll_outcome_span(natural, "<b>Natural [results[1]]!</b>", in_tooltip = TRUE)]"

	var/verdict = ""
	var/runechat_verdict = ""
	if(!isnull(dc))
		verdict = " — " + roll_outcome_span(outcome, outcome ? "<b>Success!</b>" : "<b>Failure!</b>", critical)
		runechat_verdict = outcome ? " — success" : " — failure"
	else if(critical)
		verdict = " — " + roll_outcome_span(natural, natural ? "<b>Natural 20!</b>" : "<b>Natural 1!</b>", TRUE)
		runechat_verdict = natural ? " — natural 20" : " — natural 1"

	announce_roll("rolls [roll_dice_token(outcome, "[dice_string] = [total]", "", list(results), sides, list(header), throw_footers = list(footer), critical = critical)][verdict]", "rolls [dice_string] for [total][runechat_verdict]")
	return TRUE

/datum/emote/living/roll_dice_emote
	key = "dice"
	mob_type_allowed_typecache = /mob/living/carbon/human
	nomsg = TRUE
	mute_time = 0

/datum/emote/living/roll_dice_emote/run_emote(mob/user, params, type_override, intentional = FALSE, targetted = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/human = user
	INVOKE_ASYNC(human, TYPE_VERB_REF(/mob/living/carbon/human, roll_dice))

/datum/emote/living/stat_roll
	var/delay = 2.5 SECONDS
	var/list/attempt_message_list
	var/list/success_message_list
	var/list/failure_message_list
	var/list/modifiers_list = list()

/datum/emote/living/stat_roll/proc/get_trait_effect(mob/living/rolling)
	var/total = 0
	var/list/sources = get_trait_sources(rolling)
	for(var/trait_key in sources)
		total += sources[trait_key]
	return total

/datum/emote/living/stat_roll/proc/get_trait_sources(mob/living/rolling)
	var/list/sources = list()
	for(var/trait_key in modifiers_list)
		if(HAS_TRAIT(rolling, trait_key))
			sources[trait_key] = modifiers_list[trait_key]
	return sources

/mob/living/proc/get_roll_trait_effect(stat_key)
	for(var/datum/emote/living/stat_roll/roller in GLOB.emote_list[stat_key])
		return roller.get_trait_effect(src)
	return 0

/mob/living/proc/get_roll_trait_sources(stat_key)
	for(var/datum/emote/living/stat_roll/roller in GLOB.emote_list[stat_key])
		return roller.get_trait_sources(src)
	return list()

/datum/emote/living/stat_roll/run_emote(mob/user, params, type_override, intentional = FALSE, targetted = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/living = user
	living.next_emote = world.time + delay
	sleep(delay)
	if(QDELETED(living) || living.stat)
		return

	var/dc = text2num(params)
	if(!isnum(dc) || dc <= 0)
		dc = null
	else
		dc = clamp(round(dc), 1, STAT_ROLL_MAX_DC)

	var/read_stat = living.resolve_stat_key(key)
	var/stat_value = living.get_stat(read_stat)
	var/modifier = stat_roll_modifier(stat_value)
	var/list/trait_sources = get_trait_sources(living)
	var/trait_effect = get_trait_effect(living)
	var/die = rand(1, STAT_ROLL_DIE)
	var/total = die + modifier + trait_effect

	var/natural = natural_roll_outcome(die)
	var/critical = !isnull(natural)
	var/outcome = natural
	if(!isnull(dc) && !critical)
		outcome = (total >= dc)

	var/header = stat_header(key, read_stat, stat_value, trait_sources)
	var/footer = roll_sum(outcome, list(die, modifier, trait_effect))
	if(!isnull(dc))
		footer += "<br>Needs [dc] or more"
	if(critical)
		footer += "<br>[roll_outcome_span(natural, "<b>Natural [die]!</b>", in_tooltip = TRUE)]"
	var/tooltip = stat_trait_breakdown(trait_sources) || ""

	var/label = "[uppertext(key)] [total]"
	var/runechat = "rolls [key] for [total]"
	if(!isnull(dc))
		label += " — [outcome ? "SUCCEEDS" : "FAILS"]"
		runechat += outcome ? " and succeeds" : " and fails"
	else if(critical)
		label += " — NATURAL [die]"
		runechat += " — natural [die]"
	var/token = roll_dice_token(outcome, label, tooltip, list(list(die)), STAT_ROLL_DIE, list(header), throw_stats = list(key), throw_footers = list(footer), critical = critical)

	var/message = "rolls [token]"
	if(!isnull(outcome))
		var/flavour = replace_pronoun(user, pick(outcome ? success_message_list : failure_message_list))
		message += " and [flavour]"
		runechat += ", [flavour]"
	living.announce_roll(message, show_runechat ? runechat : null)

/datum/emote/living/stat_roll/select_message_type(mob/user, intentional)
	return pick(attempt_message_list)

/mob/living/carbon/human/verb/emote_stat_roll()
	set name = "Roll Stat"
	set desc = "Roll one of your stats against a difficulty, with traits taken into account."
	set category = "Emotes.Rolling"

	if(!can_roll_dice())
		return

	var/choice = tgui_input_list(src, "Which stat will you roll?", "PRAISE TYMORA", GLOB.rollable_stats)
	if(!choice)
		return
	var/dc = tgui_input_number(src, "Difficulty to beat? 0 rolls without one.", "PRAISE TYMORA", 0, STAT_ROLL_MAX_DC, 0)
	if(isnull(dc) || !can_roll_dice())
		return

	emote(GLOB.rollable_stats[choice], message = dc ? "[dc]" : null, intentional = TRUE)

/datum/emote/living/stat_pick_emote
	key = "stat"
	mob_type_allowed_typecache = /mob/living/carbon/human
	nomsg = TRUE
	mute_time = 0

/datum/emote/living/stat_pick_emote/run_emote(mob/user, params, type_override, intentional = FALSE, targetted = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/human = user
	INVOKE_ASYNC(human, TYPE_VERB_REF(/mob/living/carbon/human, emote_stat_roll))

/datum/emote/living/stat_roll/strength
	key = STATKEY_STR
	key_third_person = "str"
	modifiers_list = list(
		TRAIT_STRONG_GRABBER = 1,
		TRAIT_GRAGGAR_CURSE = -2,
		TRAIT_RAVOX_CURSE = -2,
	)

	attempt_message_list = list(
		"tests their strength...",
		"puts their back into it...",
		"begins to flex...",
	)

	success_message_list = list(
		"is brimming with power!",
		"is truly beefy!",
		"shows off their muscle!",
	)

	failure_message_list = list(
		"is a little wet noodle...",
		"would lose in an arm wrestling match against a rous...",
		"should eat more sausage...",
	)

/mob/living/carbon/human/verb/emote_strength_roll()
	set name = "Roll Strength"
	set category = "Emotes.Rolling"

	emote(STATKEY_STR, intentional = TRUE)

/datum/emote/living/stat_roll/perception
	key = STATKEY_PER
	key_third_person = "per"
	modifiers_list = list(
		TRAIT_KEENEARS = 1,
		TRAIT_COMBAT_AWARE = 1,
		TRAIT_PERFECT_TRACKER = 1,
		TRAIT_DEAF = -1,
		TRAIT_CYCLOPS_LEFT = -1,
		TRAIT_CYCLOPS_RIGHT = -1,
	)

	attempt_message_list = list(
		"takes a good, long look...",
		"focuses in...",
		"squints...",
	)

	success_message_list = list(
		"has eyes like a hawk!",
		"sees what others don't!",
		"has perfect 20/20 vision!",
	)

	failure_message_list = list(
		"is totally oblivious...",
		"has cataracts in their eyes...",
		"is blind...",
	)

/mob/living/carbon/human/verb/emote_perception_roll()
	set name = "Roll Perception"
	set category = "Emotes.Rolling"

	emote(STATKEY_PER, intentional = TRUE)

/datum/emote/living/stat_roll/intelligence
	key = STATKEY_INT
	key_third_person = "int"
	modifiers_list = list(
		TRAIT_DUMB = -1,
		TRAIT_ZIZO_CURSE = -2,
		TRAIT_NOC_CURSE = -2,
	)

	attempt_message_list = list(
		"thinks hard...",
		"furrows their brows...",
		"rubs their chin...",
	)

	success_message_list = list(
		"is a genius!",
		"has a mind sharp as a whip!",
		"knows what they're doing!",
	)

	failure_message_list = list(
		"is as dumb as a rock...",
		"has an empty head...",
		"couldn't put 2 and 2 together...",
	)

/mob/living/carbon/human/verb/emote_intelligence_roll()
	set name = "Roll Intelligence"
	set category = "Emotes.Rolling"

	emote(STATKEY_INT, intentional = TRUE)

/datum/emote/living/stat_roll/constitution
	key = STATKEY_CON
	key_third_person = "con"
	modifiers_list = list(
		TRAIT_NOPAIN = 1,
		TRAIT_NOPAINSTUN = 1,
		TRAIT_CRITICAL_RESISTANCE = 1,
		TRAIT_CRITICAL_WEAKNESS = -1,
		TRAIT_NECRA_CURSE = -2,
	)

	attempt_message_list = list(
		"tests their toughness...",
		"braces for impact...",
		"prepares to endure...",
	)

	success_message_list = list(
		"doesn't even flinch!",
		"is solid as an oak!",
		"is one tough nut to crack!",
	)

	failure_message_list = list(
		"has paper skin...",
		"would be torn to shreds by a light breeze...",
		"has a glass jaw...",
	)

/mob/living/carbon/human/verb/emote_constitution_roll()
	set name = "Roll Constitution"
	set category = "Emotes.Rolling"

	emote(STATKEY_CON, intentional = TRUE)

/datum/emote/living/stat_roll/endurance
	key = STATKEY_END
	key_third_person = "end"
	modifiers_list = list(
		TRAIT_FEARLESS = 1,
		TRAIT_STEELHEARTED = 1,
		TRAIT_SCHIZO_FLAW = -1,
	)

	attempt_message_list = list(
		"tests their endurance...",
		"gathers their courage...",
		"prepares to use their determination...",
	)

	success_message_list = list(
		"proves mighty!",
		"never gives up!",
		"persists through anything!",
	)

	failure_message_list = list(
		"is a weak willed chicken...",
		"gives up trying...",
		"faints when they get a splinter...",
	)

/mob/living/carbon/human/verb/emote_endurance_roll()
	set name = "Roll Endurance"
	set category = "Emotes.Rolling"

	emote(STATKEY_END, intentional = TRUE)

/datum/emote/living/stat_roll/speed
	key = STATKEY_SPD
	key_third_person = "spd"
	modifiers_list = list(
		TRAIT_FREERUNNING = 1,
		TRAIT_LIGHT_STEP = 1,
		TRAIT_IGNORESLOWDOWN = 1,
		TRAIT_DODGEEXPERT = 1,
		TRAIT_PARALYSIS_L_LEG = -1,
		TRAIT_PARALYSIS_R_LEG = -1,
		TRAIT_MATTHIOS_CURSE = -2,
	)

	attempt_message_list = list(
		"prepares their moves...",
		"starts to get limber...",
		"tries to get speedy...",
	)

	success_message_list = list(
		"is in perfect control!",
		"is as agile as a cat!",
		"is very flexible!",
	)

	failure_message_list = list(
		"has two left feet...",
		"trips over themselves...",
		"is slower than a snail...",
	)

/mob/living/carbon/human/verb/emote_speed_roll()
	set name = "Roll Speed"
	set category = "Emotes.Rolling"

	emote(STATKEY_SPD, intentional = TRUE)

/datum/emote/living/stat_roll/fortune
	key = STATKEY_LCK
	key_third_person = "for"
	modifiers_list = list(
		TRAIT_SUPERNATURAL_LUCK = 1,
		TRAIT_XYLIX_CURSE = -2,
	)

	attempt_message_list = list(
		"tries their fortune...",
		"takes a chance...",
		"prepares to gamble...",
	)

	success_message_list = list(
		"could make an arrow turn around and climb back into the bow!",
		"has a rabbit's paw in their pocket!",
		"persists through pure luck!",
	)

	failure_message_list = list(
		"realizes the game was rigged from the start...",
		"gets dealt a bad hand...",
		"has the odds stacked against them...",
	)

/mob/living/carbon/human/verb/emote_fortune_roll()
	set name = "Roll Fortune"
	set category = "Emotes.Rolling"

	emote(STATKEY_LCK, intentional = TRUE)

/datum/emote/living/stat_roll/charisma
	key = ROLL_STAT_CHARISMA
	key_third_person = "cha"
	modifiers_list = list(
		TRAIT_BEAUTIFUL = 1,
		TRAIT_EMPATH = 1,
		TRAIT_GOODLOVER = 1,
		TRAIT_CICERONE = 1,
		TRAIT_NOBLE = 1,
		TRAIT_UGLY = -1,
		TRAIT_MISSING_NOSE = -1,
		TRAIT_DISFIGURED = -2,
		TRAIT_BAOTHA_CURSE = -2,
		TRAIT_EORA_CURSE = -2,
	)

	attempt_message_list = list(
		"tries to maintain their composure...",
		"attempts to appear impressive...",
		"starts contemplating their next move...",
	)

	success_message_list = list(
		"is brimming with self-confidence!",
		"has a true poker face!",
		"has the whole room hanging on every word!",
	)

	failure_message_list = list(
		"is brimming with self-doubt...",
		"can't quite sell it...",
		"is holding it together with string and prayer...",
	)

/mob/living/carbon/human/verb/emote_charisma_roll()
	set name = "Roll Charisma"
	set category = "Emotes.Rolling"

	emote(ROLL_STAT_CHARISMA, intentional = TRUE)

/datum/contest_response_prompt
	var/title
	var/challenger_name
	var/attacking_stat
	var/list/stats
	var/choice
	var/answered = FALSE
	var/datum/callback/callback
	var/datum/ui_state/state

/datum/contest_response_prompt/New(mob/user, challenger_name, attacking_stat, title, list/stats, datum/callback/callback, timeout, ui_state)
	src.challenger_name = challenger_name
	src.attacking_stat = attacking_stat
	src.title = title
	src.stats = list()
	for(var/stat_name in stats)
		src.stats += stat_name
	src.callback = callback
	src.state = ui_state
	if(timeout)
		QDEL_IN(src, timeout)

/datum/contest_response_prompt/Destroy(force)
	SStgui.close_uis(src)
	state = null
	stats = null
	// Callbacks are refcounted and refuse qdel.
	callback = null
	return ..()

/datum/contest_response_prompt/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ContestResponse")
		ui.open()

/datum/contest_response_prompt/ui_state(mob/user)
	return state

/datum/contest_response_prompt/ui_static_data(mob/user)
	return list(
		"title" = title,
		"challengerName" = challenger_name,
		"attackingStat" = attacking_stat,
		"stats" = stats,
	)

/datum/contest_response_prompt/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(answered)
		return
	switch(action)
		if("choose")
			if(!(params["stat"] in stats))
				return
			choice = params["stat"]
		if("decline")
			choice = null
		else
			return
	answered = TRUE
	callback.InvokeAsync(choice)
	qdel(src)
	return TRUE

/proc/contest_response_async(mob/user, challenger_name, attacking_stat, title, list/stats, datum/callback/callback, timeout = 2 MINUTES)
	if(isnull(user?.client))
		return
	var/datum/contest_response_prompt/prompt = new(user, challenger_name, attacking_stat, title, stats, callback, timeout, GLOB.always_state)
	prompt.ui_interact(user)

/mob/living/carbon/human/verb/contested_roll()
	set name = "Contested Roll"
	set desc = "Pit one of your stats against another's."
	set category = "Emotes.Rolling"

	if(!can_roll_dice())
		return

	var/list/nearby = list()
	for(var/mob/living/carbon/human/opponent in range(src, 2))
		if(opponent == src || opponent.stat || !opponent.client)
			continue
		nearby |= opponent

	if(!length(nearby))
		to_chat(src, span_warning("There is nobody nearby to measure myself against!"))
		return

	var/mob/living/carbon/human/defender = tgui_input_list(src, "Who will you challenge?", "PRAISE TYMORA", nearby)
	if(!defender)
		return
	if(defender.cmode)
		to_chat(src, span_warning("[defender] is too tense for that!"))
		return
	if(!contest_partners_valid(src, defender))
		return

	var/challenger_choice = tgui_input_list(src, "Which of your stats will you stake?", "PRAISE TYMORA", GLOB.rollable_stats)
	if(!challenger_choice)
		return
	if(!contest_partners_valid(src, defender) || !can_roll_dice())
		return

	var/challenger_stat = GLOB.rollable_stats[challenger_choice]
	next_emote = world.time + DICE_ROLL_COOLDOWN

	to_chat(src, span_notice("Setting my [challenger_stat] against [defender]. Awaiting their answer..."))
	announce_roll("challenges [defender] to a contest of [stat_span(challenger_stat, challenger_stat)]!", "challenges [defender] to a contest of [challenger_stat]")
	to_chat(defender, span_notice("[src] sets their [challenger_stat] against you. Answer with one of your own stats, or let it pass."))

	contest_response_async(
		defender,
		name,
		challenger_choice,
		"ALEA IACTA EST",
		GLOB.rollable_stats,
		CALLBACK(src, PROC_REF(on_contested_roll_response), defender, challenger_stat),
	)

/datum/emote/living/contested_roll_emote
	key = "contested"
	mob_type_allowed_typecache = /mob/living/carbon/human
	nomsg = TRUE
	mute_time = 0

/datum/emote/living/contested_roll_emote/run_emote(mob/user, params, type_override, intentional = FALSE, targetted = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/human = user
	INVOKE_ASYNC(human, TYPE_VERB_REF(/mob/living/carbon/human, contested_roll))

/mob/living/carbon/human/proc/on_contested_roll_response(mob/living/carbon/human/defender, challenger_stat, response)
	if(QDELETED(src))
		return
	if(!response)
		to_chat(src, span_warning("[defender] declines the contest."))
		return
	if(!contest_partners_valid(src, defender))
		to_chat(src, span_warning("My contest with [defender] comes to nothing."))
		return

	var/defender_stat = GLOB.rollable_stats[response]
	if(!defender_stat)
		return
	defender.announce_roll("answers with [stat_span(defender_stat, defender_stat)]!", "answers with [defender_stat]")

	resolve_contested_roll(defender, challenger_stat, defender_stat)
	next_emote = world.time + DICE_ROLL_COOLDOWN
	defender.next_emote = world.time + DICE_ROLL_COOLDOWN

/proc/contest_side_header(mob/living/who, stat_key, read_stat, stat_value, list/trait_sources)
	return "<b>[html_encode("[who]")]</b><br>" + stat_header(stat_key, read_stat, stat_value, trait_sources)

/mob/living/proc/resolve_contested_roll(mob/living/defender, challenger_stat, defender_stat)
	var/challenger_read = resolve_stat_key(challenger_stat)
	var/defender_read = defender.resolve_stat_key(defender_stat)
	var/challenger_stat_value = get_stat(challenger_read)
	var/defender_stat_value = defender.get_stat(defender_read)
	var/challenger_modifier = stat_roll_modifier(challenger_stat_value)
	var/defender_modifier = stat_roll_modifier(defender_stat_value)
	var/list/challenger_trait_sources = get_roll_trait_sources(challenger_stat)
	var/list/defender_trait_sources = defender.get_roll_trait_sources(defender_stat)
	var/challenger_traits = get_roll_trait_effect(challenger_stat)
	var/defender_traits = defender.get_roll_trait_effect(defender_stat)
	var/challenger_die = rand(1, STAT_ROLL_DIE)
	var/defender_die = rand(1, STAT_ROLL_DIE)
	var/challenger_total = challenger_die + challenger_modifier + challenger_traits
	var/defender_total = defender_die + defender_modifier + defender_traits

	var/result = null
	var/verdict = "Neither prevails!"
	if(challenger_total != defender_total)
		result = (challenger_total > defender_total)
		var/mob/living/winner = result ? src : defender
		verdict = "[winner] prevails!"

	var/list/trait_rows = list()
	var/challenger_breakdown = stat_trait_breakdown(challenger_trait_sources)
	if(challenger_breakdown)
		trait_rows += "<b>[html_encode("[src]")]</b> [challenger_breakdown]"
	var/defender_breakdown = stat_trait_breakdown(defender_trait_sources)
	if(defender_breakdown)
		trait_rows += "<b>[html_encode("[defender]")]</b> [defender_breakdown]"
	var/tooltip = roll_tooltip(result, null, trait_rows)

	var/list/throw_labels = list(
		contest_side_header(src, challenger_stat, challenger_read, challenger_stat_value, challenger_trait_sources),
		contest_side_header(defender, defender_stat, defender_read, defender_stat_value, defender_trait_sources),
	)
	var/challenger_outcome = result
	var/defender_outcome = isnull(result) ? null : !result
	var/list/throw_footers = list(
		roll_sum(challenger_outcome, list(challenger_die, challenger_modifier, challenger_traits)),
		roll_sum(defender_outcome, list(defender_die, defender_modifier, defender_traits)),
	)
	var/token = roll_dice_token(result, html_encode(verdict), tooltip, list(list(challenger_die), list(defender_die)), STAT_ROLL_DIE, throw_labels, list(challenger_outcome, defender_outcome), list(challenger_stat, defender_stat), throw_footers)
	announce_roll(token, verdict, show_name = FALSE)

#undef DICE_SYNTAX_HELP
#undef DICE_MAX_COUNT
#undef DICE_MAX_SIDES
#undef DICE_MAX_BONUS
#undef DICE_SUM_MAX_TERMS
#undef DICE_ROLL_COOLDOWN
#undef STAT_ROLL_DIE
#undef STAT_ROLL_MAX_DC
#undef ROLL_STAT_CHARISMA
