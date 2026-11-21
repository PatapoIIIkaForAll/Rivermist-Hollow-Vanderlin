/// Act text of the horny NPC acts: line shape, pronouns, the fixed beats, state tails and climax fluid routing.
/datum/unit_test/npc_act_text
	abstract_type = /datum/unit_test/npc_act_text

/// The nine acts the base hunt picks.
/datum/unit_test/npc_act_text/proc/get_act_types()
	return list(
		/datum/sex_action/npc/npc_vaginal_sex,
		/datum/sex_action/npc/npc_anal_sex,
		/datum/sex_action/npc/npc_throat_sex,
		/datum/sex_action/npc/npc_vaginal_ride_sex,
		/datum/sex_action/npc/npc_anal_ride_sex,
		/datum/sex_action/npc/npc_facesitting,
		/datum/sex_action/npc/npc_handjob,
		/datum/sex_action/npc/npc_jerk_over,
		/datum/sex_action/npc/npc_body_rub,
	)

/// Acts whose victim climax has a line of its own.
/datum/unit_test/npc_act_text/proc/has_victim_climax(act_type)
	return !(act_type in list(/datum/sex_action/npc/npc_facesitting, /datum/sex_action/npc/npc_handjob, /datum/sex_action/npc/npc_body_rub))

/// A goblin hunter with a fixed name and pronouns.
/datum/unit_test/npc_act_text/proc/make_hunter(hunter_pronouns = IT_ITS)
	var/mob/living/carbon/human/species/goblin/npc/hunter = allocate(/mob/living/carbon/human/species/goblin/npc)
	hunter.name = "goblin"
	hunter.real_name = "goblin"
	hunter.pronouns = hunter_pronouns
	return hunter

/// A named human victim with they/them pronouns.
/datum/unit_test/npc_act_text/proc/make_victim()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.name = "Abigail"
	victim.real_name = "Abigail"
	victim.pronouns = THEY_THEM
	return victim

/// A fresh act; the body rub rubs with a cock.
/datum/unit_test/npc_act_text/proc/make_act(act_type)
	var/datum/sex_action/npc/act = allocate(act_type)
	if(istype(act, /datum/sex_action/npc/npc_body_rub))
		var/datum/sex_action/npc/npc_body_rub/rub = act
		rub.selected_genital_slot = ORGAN_SLOT_PENIS
	return act

/// Every beat's lines for one act, keyed by beat name.
/datum/unit_test/npc_act_text/proc/collect_beats(datum/sex_action/npc/act, mob/living/hunter, mob/living/victim)
	var/list/beats = list()
	beats["start"] = act.get_start_lines(hunter, victim)
	beats["opening"] = act.get_perform_lines(hunter, victim, "opening")
	for(var/variant in 1 to 3)
		beats["middle [variant]"] = act.get_perform_lines(hunter, victim, "middle", variant)
	beats["late"] = act.get_perform_lines(hunter, victim, "late")
	beats["climax"] = act.get_climax_lines(hunter, victim, FALSE)
	if(has_victim_climax(act.type))
		beats["victim climax"] = act.get_climax_lines(victim, hunter, TRUE)
	beats["finish"] = act.get_finish_lines(hunter, victim)
	return beats

/// Problems with one beat's lines as text; empty when well formed.
/datum/unit_test/npc_act_text/proc/check_lines(list/lines, beat, mob/living/subject)
	if(!islist(lines))
		return list("[beat]: no lines")
	var/list/problems = list()
	var/list/banned = list("..", "~", "  ", " his ", " her ", "himself", "herself", "themselves", "your target")
	for(var/key in list("room", "me", "hear"))
		var/line = lines[key]
		if(!istext(line) || !length(line))
			problems += "[beat] [key]: empty"
			continue
		for(var/bad in banned)
			if(findtext(line, bad))
				problems += "[beat] [key] holds '[bad]': [line]"
		var/last = copytext(line, -1)
		if(last != "." && last != "!")
			problems += "[beat] [key] does not end in . or !: [line]"
	var/room = lines["room"]
	if(istext(room) && findtext(room, "[subject]") != 1)
		problems += "[beat] room does not start with [subject]: [room]"
	var/me = lines["me"]
	if(istext(me) && !findtext(me, " me") && !findtext(me, " my") && findtextEx(me, "I ") != 1)
		problems += "[beat] me line does not speak to me: [me]"
	return problems

/datum/unit_test/npc_act_text/npc_act_lines_are_well_formed

/datum/unit_test/npc_act_text/npc_act_lines_are_well_formed/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	for(var/act_type in get_act_types())
		var/datum/sex_action/npc/act = make_act(act_type)
		var/list/beats = collect_beats(act, hunter, victim)
		for(var/beat in beats)
			var/mob/living/subject = beat == "victim climax" ? victim : hunter
			for(var/problem in check_lines(beats[beat], beat, subject))
				TEST_FAIL("[act_type] [problem]")
		act.act_cycles = 0
		TEST_ASSERT_EQUAL(act.get_act_stage(hunter, victim), "opening", "[act_type] opens on its first cycles.")
		act.act_cycles = 5
		TEST_ASSERT_EQUAL(act.get_act_stage(hunter, victim), "middle", "[act_type] reaches the middle without arousal.")

/datum/unit_test/npc_act_text/npc_act_lines_follow_pronouns

/datum/unit_test/npc_act_text/npc_act_lines_follow_pronouns/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	for(var/hunter_pronouns in list(SHE_HER, THEY_THEM))
		hunter.pronouns = hunter_pronouns
		for(var/act_type in get_act_types())
			var/datum/sex_action/npc/act = make_act(act_type)
			var/list/beats = collect_beats(act, hunter, victim)
			for(var/beat in beats)
				var/list/lines = beats[beat]
				for(var/key in lines)
					var/line = " [lines[key]]"
					if(findtext(line, " his ") || findtext(line, " himself"))
						TEST_FAIL("[act_type] [beat] [key] with [hunter_pronouns] says his: [line]")

/datum/unit_test/npc_act_text/npc_act_throat_has_a_start_line

/datum/unit_test/npc_act_text/npc_act_throat_has_a_start_line/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	var/datum/sex_action/npc/act = make_act(/datum/sex_action/npc/npc_throat_sex)
	var/list/lines = act.get_start_lines(hunter, victim)
	TEST_ASSERT_NOTNULL(lines, "The throat act has a start beat.")
	TEST_ASSERT(findtext(lines["room"], "throat"), "The throat start line names the throat: [lines["room"]]")
	TEST_ASSERT(findtext(lines["me"], "my throat"), "The throat me line names my throat: [lines["me"]]")

/datum/unit_test/npc_act_text/npc_act_facesitting_says_pussy

/datum/unit_test/npc_act_text/npc_act_facesitting_says_pussy/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	var/datum/sex_action/npc/act = make_act(/datum/sex_action/npc/npc_facesitting)
	var/list/start = act.get_start_lines(hunter, victim)
	TEST_ASSERT(findtext(start["room"], "pussy"), "Facesitting starts with the hunter's pussy: [start["room"]]")
	var/list/beats = collect_beats(act, hunter, victim)
	for(var/beat in beats)
		var/list/lines = beats[beat]
		for(var/key in lines)
			if(findtext(lines[key], "butt"))
				TEST_FAIL("Facesitting [beat] [key] still says butt: [lines[key]]")

/datum/unit_test/npc_act_text/npc_act_tail_never_repeats

/datum/unit_test/npc_act_text/npc_act_tail_never_repeats/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	var/datum/sex_action/npc/act = make_act(/datum/sex_action/npc/npc_vaginal_sex)
	victim.pulledby = hunter
	hunter.grab_state = GRAB_AGGRESSIVE
	var/list/tails = act.get_state_tails(hunter, victim)
	TEST_ASSERT(length(tails) >= 2, "Test setup: an aggressive hold offers at least two tails, got [length(tails)].")
	var/last_id
	for(var/i in 1 to 20)
		var/list/tail = act.pick_state_tail(hunter, victim, 100)
		TEST_ASSERT_NOTNULL(tail, "A forced roll always gives a tail.")
		TEST_ASSERT_NOTEQUAL(tail["id"], last_id, "Tail [i] repeats the one before it.")
		TEST_ASSERT(findtext(tail["me"], "my") || findtext(tail["me"], "me"), "The me tail speaks to me: [tail["me"]]")
		last_id = tail["id"]
	TEST_ASSERT_NULL(act.pick_state_tail(hunter, victim, 0), "A failed roll gives no tail.")
	victim.pulledby = null
	hunter.grab_state = GRAB_PASSIVE

/datum/unit_test/npc_act_text/npc_act_climax_keeps_fluid_routing

/datum/unit_test/npc_act_text/npc_act_climax_keeps_fluid_routing/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	// Straight (the hunter climaxes) and flipped (the victim climaxes), as the acts returned before their text pass.
	var/list/expected = list(
		/datum/sex_action/npc/npc_vaginal_sex = list(ORGASM_LOCATION_INTO, ORGASM_LOCATION_ONTO),
		/datum/sex_action/npc/npc_anal_sex = list(ORGASM_LOCATION_INTO, ORGASM_LOCATION_SELF),
		/datum/sex_action/npc/npc_throat_sex = list(ORGASM_LOCATION_ORAL, ORGASM_LOCATION_SELF),
		/datum/sex_action/npc/npc_vaginal_ride_sex = list(ORGASM_LOCATION_ONTO, ORGASM_LOCATION_INTO),
		/datum/sex_action/npc/npc_anal_ride_sex = list(ORGASM_LOCATION_SELF, ORGASM_LOCATION_INTO),
		/datum/sex_action/npc/npc_jerk_over = list(ORGASM_LOCATION_ONTO, ORGASM_LOCATION_ONTO),
		/datum/sex_action/npc/npc_facesitting = list(null, null),
		/datum/sex_action/npc/npc_handjob = list(null, null),
		/datum/sex_action/npc/npc_body_rub = list(null, null),
	)
	for(var/act_type in expected)
		var/list/want = expected[act_type]
		var/datum/sex_action/npc/act = make_act(act_type)
		TEST_ASSERT_EQUAL(act.handle_climax_message(hunter, victim, FALSE), want[1], "[act_type] routes the hunter's climax as before.")
		TEST_ASSERT_EQUAL(act.handle_climax_message(victim, hunter, TRUE), want[2], "[act_type] routes the victim's climax as before.")
