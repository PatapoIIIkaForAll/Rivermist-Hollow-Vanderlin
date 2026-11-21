// Family word tables, act availability by body, variant and portal lines, and act beat barks.

/// Every text inside a word slot, nested lists included.
/datum/unit_test/npc_act_text/proc/slot_texts(value)
	if(istext(value))
		return list(value)
	var/list/texts = list()
	if(!islist(value))
		return texts
	var/list/entries = value
	for(var/key in entries)
		var/entry = (istext(key) && !isnull(entries[key])) ? entries[key] : key
		texts += slot_texts(entry)
	return texts

/// Problems with each beat of one act; tied adds the knot stage.
/datum/unit_test/npc_act_text/proc/check_act(datum/sex_action/npc/act, mob/living/hunter, mob/living/victim, tied = FALSE)
	var/list/beats = collect_beats(act, hunter, victim)
	if(tied)
		beats["tied"] = act.get_perform_lines(hunter, victim, "tied")
	var/list/problems = list()
	for(var/beat in beats)
		var/mob/living/subject = beat == "victim climax" ? victim : hunter
		for(var/problem in check_lines(beats[beat], beat, subject))
			problems += "[act.type] [problem]"
	return problems

/// The base acts that can knot.
/datum/unit_test/npc_act_text/proc/get_knotting_act_types()
	return list(
		/datum/sex_action/npc/npc_vaginal_sex,
		/datum/sex_action/npc/npc_anal_sex,
		/datum/sex_action/npc/npc_vaginal_ride_sex,
		/datum/sex_action/npc/npc_anal_ride_sex,
	)

/// Every family profile singleton, the base one included.
/datum/unit_test/npc_act_text/proc/get_family_profiles()
	horny_profile_for_flag(NONE)
	var/list/profiles = list()
	for(var/key in GLOB.horny_family_profiles)
		profiles += GLOB.horny_family_profiles[key]
	return profiles

/datum/unit_test/npc_act_text/family_act_words_are_complete

/datum/unit_test/npc_act_text/family_act_words_are_complete/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	var/datum/horny_family_profile/humanoids = horny_profile_for_flag(HORNY_MOB_TYPE_HUMANOIDS)
	var/list/slots = humanoids.get_act_words(hunter, victim)
	var/list/banned = list("..", "~", "  ", "your target", " his ")
	for(var/datum/horny_family_profile/profile as anything in get_family_profiles())
		var/list/words = profile.get_act_words(hunter, victim)
		for(var/slot in slots)
			var/list/texts = slot_texts(words[slot])
			if(!length(texts))
				TEST_FAIL("[profile.type] has no '[slot]' words.")
				continue
			for(var/text in texts)
				if(!length(text))
					TEST_FAIL("[profile.type] '[slot]' holds an empty text.")
				for(var/bad in banned)
					if(findtext(" [text] ", bad))
						TEST_FAIL("[profile.type] '[slot]' holds '[bad]': [text]")
		var/list/thrusts = words["thrusts"]
		TEST_ASSERT_EQUAL(length(thrusts), 3, "[profile.type] gives three thrust verbs.")
		var/list/body_tails = words["body_tails"]
		TEST_ASSERT_EQUAL(length(body_tails), 2, "[profile.type] gives two body tails.")

/datum/unit_test/npc_act_text/family_act_lines_are_well_formed

/datum/unit_test/npc_act_text/family_act_lines_are_well_formed/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	TEST_ASSERT_NOTNULL(hunter.ai_controller, "Test setup: the goblin hunter has a controller.")
	var/old_flag = hunter.ai_controller.horny_pref_family_flag
	var/list/knotting = get_knotting_act_types()
	for(var/datum/horny_family_profile/profile as anything in get_family_profiles())
		hunter.ai_controller.horny_pref_family_flag = profile.family_flag
		TEST_ASSERT_EQUAL(hunter.get_horny_family_profile(), profile, "Test setup: the hunter takes the [profile.type] words.")
		for(var/act_type in get_act_types())
			var/datum/sex_action/npc/act = make_act(act_type)
			for(var/problem in check_act(act, hunter, victim, (act_type in knotting)))
				TEST_FAIL("[profile.type]: [problem]")
	hunter.ai_controller.horny_pref_family_flag = old_flag

/datum/unit_test/npc_act_text/handless_families_offer_no_hand_acts

/datum/unit_test/npc_act_text/handless_families_offer_no_hand_acts/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	hunter.gender = MALE
	hunter.give_genitals()
	TEST_ASSERT_NOTNULL(hunter.getorganslot(ORGAN_SLOT_PENIS), "Test setup: the hunter has a penis.")
	var/mob/living/carbon/human/victim = make_victim()
	var/list/hand_acts = list(/datum/sex_action/npc/npc_handjob, /datum/sex_action/npc/npc_jerk_over)
	var/list/handless_flags = list(
		HORNY_MOB_TYPE_BEASTS,
		HORNY_MOB_TYPE_LYCANS,
		HORNY_MOB_TYPE_SPIDERS,
		HORNY_MOB_TYPE_BOG_BUGS,
		HORNY_MOB_TYPE_LAMIAS,
		HORNY_MOB_TYPE_LIZARDS,
	)
	for(var/family_flag in handless_flags)
		var/datum/horny_family_profile/profile = horny_profile_for_flag(family_flag)
		TEST_ASSERT(!profile.has_hands, "[profile.type] has no hands.")
		var/list/choices = list()
		profile.add_act_choices(choices, hunter, victim)
		TEST_ASSERT(length(choices), "[profile.type] still offers acts to a male hunter.")
		for(var/act_type in hand_acts)
			TEST_ASSERT(!(act_type in choices), "[profile.type] offers [act_type].")
	var/datum/horny_family_profile/humanoids = horny_profile_for_flag(HORNY_MOB_TYPE_HUMANOIDS)
	var/list/humanoid_choices = list()
	humanoids.add_act_choices(humanoid_choices, hunter, victim)
	for(var/act_type in hand_acts)
		TEST_ASSERT(act_type in humanoid_choices, "Humanoids offer [act_type].")

/datum/unit_test/npc_act_text/variant_act_lines_are_well_formed

/datum/unit_test/npc_act_text/variant_act_lines_are_well_formed/Run()
	var/mob/living/carbon/human/victim = make_victim()

	var/mob/living/carbon/human/species/skeleton/skeleton = allocate(/mob/living/carbon/human/species/skeleton)
	skeleton.name = "skeleton"
	skeleton.real_name = "skeleton"
	skeleton.pronouns = IT_ITS
	skeleton.gender = MALE
	skeleton.replace_genitals_with_bones()
	TEST_ASSERT(istype(skeleton.getorganslot(ORGAN_SLOT_PENIS), /obj/item/organ/genitals/penis/funny_bone), "Test setup: the skeleton carries a funny bone.")
	var/list/bone_acts = list(
		/datum/sex_action/npc/npc_throat_sex/funny_bone,
		/datum/sex_action/npc/npc_anal_sex/funny_bone,
		/datum/sex_action/npc/npc_vaginal_sex/funny_bone,
		/datum/sex_action/npc/npc_jerk_over/funny_bone,
	)
	for(var/act_type in bone_acts)
		for(var/problem in check_act(make_act(act_type), skeleton, victim, ispath(act_type, /datum/sex_action/npc/npc_vaginal_sex) || ispath(act_type, /datum/sex_action/npc/npc_anal_sex)))
			TEST_FAIL(problem)
	var/datum/sex_action/npc/petting = make_act(/datum/sex_action/npc/npc_bony_petting)
	var/list/petting_beats = list(
		"start" = petting.get_start_lines(skeleton, victim),
		"finish" = petting.get_finish_lines(skeleton, victim),
	)
	for(var/variant in 1 to 4)
		petting_beats["middle [variant]"] = petting.get_perform_lines(skeleton, victim, "middle", variant)
	for(var/beat in petting_beats)
		for(var/problem in check_lines(petting_beats[beat], beat, skeleton))
			TEST_FAIL("Bony petting [problem]")

	var/mob/living/simple_animal/hostile/retaliate/tentacle/tentacle = allocate(/mob/living/simple_animal/hostile/retaliate/tentacle)
	TEST_ASSERT_EQUAL(tentacle.get_horny_family_profile(), horny_profile_for_flag(HORNY_MOB_TYPE_TENTACLES), "Test setup: the tentacle mass speaks as a tentacle.")
	var/list/tentacle_acts = list(
		/datum/sex_action/npc/npc_vaginal_sex/tentacle,
		/datum/sex_action/npc/npc_anal_sex/tentacle,
		/datum/sex_action/npc/npc_throat_sex/tentacle,
	)
	for(var/act_type in tentacle_acts)
		for(var/problem in check_act(make_act(act_type), tentacle, victim))
			TEST_FAIL(problem)
	var/datum/sex_action/npc/tentacle_vaginal = make_act(/datum/sex_action/npc/npc_vaginal_sex/tentacle)
	var/list/tentacle_start = tentacle_vaginal.get_start_lines(tentacle, victim)
	TEST_ASSERT(findtext(tentacle_start["room"], "tentacle"), "The tentacle start names a tentacle: [tentacle_start["room"]]")
	TEST_ASSERT(!findtext(tentacle_start["room"], "cock"), "The tentacle start does not say cock: [tentacle_start["room"]]")
	check_jerk(allocate(/datum/sex_action/tentacle_jerk), tentacle, victim)

	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small/burrow = allocate(/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small)
	burrow.emerge_from_ground()
	for(var/kind_type in subtypesof(/datum/tentacle_kind))
		burrow.tentacle_kind_type = kind_type
		burrow.apply_tentacle_kind()
		var/datum/tentacle_kind/kind = burrow.get_tentacle_kind()
		TEST_ASSERT_EQUAL(kind?.type, kind_type, "Test setup: the burrow tentacle takes [kind_type].")
		var/list/kind_acts = ispath(kind_type, /datum/tentacle_kind/feeler) ? list(/datum/sex_action/npc/npc_feeler_caress) : tentacle_acts
		for(var/act_type in kind_acts)
			for(var/problem in check_act(make_act(act_type), burrow, victim, !ispath(act_type, /datum/sex_action/npc/npc_throat_sex) && !ispath(act_type, /datum/sex_action/npc/npc_feeler_caress)))
				TEST_FAIL("[kind_type] [problem]")
		check_jerk(allocate(/datum/sex_action/tentacle_jerk), burrow, victim)

	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/tendril = allocate(/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater)
	var/list/maneater_acts = list(
		/datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater,
		/datum/sex_action/npc/npc_anal_sex/tentacle/maneater,
		/datum/sex_action/npc/npc_throat_sex/tentacle/maneater,
	)
	for(var/act_type in maneater_acts)
		for(var/problem in check_act(make_act(act_type), tendril, victim, !ispath(act_type, /datum/sex_action/npc/npc_throat_sex)))
			TEST_FAIL(problem)
	check_jerk(allocate(/datum/sex_action/tentacle_jerk/maneater), tendril, victim)

/// Fails on any malformed beat of a tentacle or vine jerk.
/datum/unit_test/npc_act_text/proc/check_jerk(datum/sex_action/tentacle_jerk/jerk, mob/living/hunter, mob/living/victim)
	var/list/beats = list(
		"start" = jerk.compose_start_lines(hunter, victim),
		"middle" = jerk.compose_perform_lines(hunter, victim, "middle", 1),
		"climax" = jerk.get_climax_lines(hunter, victim, FALSE),
		"victim climax" = jerk.get_climax_lines(victim, hunter, TRUE),
		"finish" = jerk.compose_finish_lines(hunter, victim),
	)
	for(var/beat in beats)
		var/mob/living/subject = beat == "victim climax" ? victim : hunter
		for(var/problem in check_lines(beats[beat], beat, subject))
			TEST_FAIL("[jerk.type] [problem]")

/datum/unit_test/npc_act_text/portal_wearer_lines_speak_to_me

/datum/unit_test/npc_act_text/portal_wearer_lines_speak_to_me/Run()
	var/list/portal_acts = list(
		/datum/sex_action/portal_base/portal_penis_vaginal,
		/datum/sex_action/portal_base/portal_penis_anal,
		/datum/sex_action/portal_base/portal_vagina_vaginal,
		/datum/sex_action/portal_base/portal_vagina_anal,
	)
	for(var/act_type in portal_acts)
		var/datum/sex_action/act = allocate(act_type)
		var/checked = 0
		for(var/var_name in act.vars)
			if(!findtext(var_name, "_message_target"))
				continue
			var/line = act.vars[var_name]
			checked++
			TEST_ASSERT(istext(line) && length(line), "[act_type] [var_name] is set.")
			TEST_ASSERT(findtext(line, " me") || findtext(line, " my"), "[act_type] [var_name] speaks to me: [line]")
			TEST_ASSERT(!findtext(line, "you"), "[act_type] [var_name] still says you: [line]")
		TEST_ASSERT(checked >= 3, "Test setup: [act_type] has its wearer lines, found [checked].")

/datum/unit_test/npc_act_text/humanoids_bark_at_act_beats

/datum/unit_test/npc_act_text/humanoids_bark_at_act_beats/Run()
	var/mob/living/carbon/human/hunter = make_hunter()
	var/mob/living/carbon/human/victim = make_victim()
	var/datum/horny_family_profile/humanoids = horny_profile_for_flag(HORNY_MOB_TYPE_HUMANOIDS)
	var/datum/horny_family_profile/base = horny_profile_for_flag(NONE)
	TEST_ASSERT_NOTEQUAL(humanoids, base, "Test setup: humanoids have their own profile.")
	for(var/context in list(HORNY_BARK_ACT_START, HORNY_BARK_ACT_CLIMAX))
		var/line = humanoids.get_bark(hunter, victim, context)
		TEST_ASSERT(istext(line) && length(line), "Humanoids bark at [context].")
		TEST_ASSERT_NULL(base.get_bark(hunter, victim, context), "The base profile stays quiet at [context].")

/datum/unit_test/npc_act_text/npc_rimming_is_gone

/datum/unit_test/npc_act_text/npc_rimming_is_gone/Run()
	TEST_ASSERT_NULL(text2path("/datum/sex_action/npc/npc_rimming"), "The dead NPC rimming act is removed.")
