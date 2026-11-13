/// Knotting for horny NPCs: knotted canines, the living knot component, the tied hunt and its lines.
/datum/unit_test/npc_knotting
	abstract_type = /datum/unit_test/npc_knotting

/// A male volf with its knotted organs built.
/datum/unit_test/npc_knotting/proc/make_volf()
	var/mob/living/simple_animal/hostile/retaliate/wolf/volf = allocate(/mob/living/simple_animal/hostile/retaliate/wolf)
	volf.gender = MALE
	volf.give_genitals()
	if(!volf.GetComponent(/datum/component/arousal))
		volf.AddComponent(/datum/component/arousal)
	return volf

/// A clientless female human who accepts the given horny family.
/datum/unit_test/npc_knotting/proc/make_target(family_flag = HORNY_MOB_TYPE_BEASTS)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	target.name = "Abigail"
	target.real_name = "Abigail"
	target.pronouns = THEY_THEM
	target.gender = FEMALE
	target.give_genitals()
	target.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = family_flag,
	))
	return target

/// A hunter's controller with the hunt queued on the target.
/datum/unit_test/npc_knotting/proc/start_hunt(mob/living/hunter, mob/living/target)
	var/datum/ai_controller/controller = hunter.ai_controller
	controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/basic/unit_test_allow_clientless_horny))
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, target)
	controller.queue_behavior(/datum/ai_behavior/horny, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)
	return controller

/// Starts hunt acts until one can knot; returns that act, or null.
/datum/unit_test/npc_knotting/proc/start_knotting_act(datum/ai_controller/controller, mob/living/hunter, mob/living/target)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	var/datum/sex_scene_controller/scene_controller = hunter.open_sex_scene(target, FALSE)
	if(!scene_controller)
		return null
	for(var/attempt in 1 to 30)
		scene_controller.stop_action()
		hunt.start_horny_action(controller, hunter, target, scene_controller, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
		var/list/active_actions = scene_controller.get_active_actions()
		if(!length(active_actions))
			continue
		var/datum/sex_action/action = active_actions[1]
		if(action.knot_on_finish)
			return action
	return null

/// Unties, stops the scene and clears floors and stuns so deleting the pair does not runtime.
/datum/unit_test/npc_knotting/proc/settle(mob/living/hunter, mob/living/target)
	var/datum/component/knotting/knot = horny_knot_between(hunter, target)
	if(knot?.knotted_owner)
		SEND_SIGNAL(knot.knotted_owner, COMSIG_SEX_REMOVE_KNOT, FALSE, FALSE)
	var/datum/sex_scene_controller/scene_controller = hunter.sex_scene?.get_controller(hunter)
	if(scene_controller)
		scene_controller.stop_action()
		qdel(scene_controller)
	hunter.stop_pulling()
	target.SetKnockdown(0)
	target.SetStun(0)
	sleep(1)

/// Problems with a set of lines as text; empty when well formed. Keys holding me_key are me lines.
/datum/unit_test/npc_knotting/proc/check_lines(list/lines, label, me_key = "me")
	var/list/problems = list()
	var/list/banned = list("..", "~", "  ", " his ", " her ", "themselves", "your target")
	for(var/key in lines)
		var/line = lines[key]
		if(!istext(line) || !length(line))
			problems += "[label] [key]: empty"
			continue
		for(var/bad in banned)
			if(findtext(" [line] ", bad))
				problems += "[label] [key] holds '[bad]': [line]"
		var/last = copytext(line, -1)
		if(last != "." && last != "!")
			problems += "[label] [key] does not end in . or !: [line]"
		if(findtext(key, me_key) && !findtext(line, " me") && !findtext(line, " my") && !findtext(line, " us"))
			problems += "[label] [key] does not speak to me: [line]"
	return problems

/datum/unit_test/npc_knotting/knot_component_fits_a_living_canine

/datum/unit_test/npc_knotting/knot_component_fits_a_living_canine/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/volf = make_volf()
	TEST_ASSERT(istype(volf.getorganslot(ORGAN_SLOT_PENIS), /obj/item/organ/genitals/penis/knotted), "A male volf grows a knotted penis.")
	TEST_ASSERT_NOTNULL(volf.GetComponent(/datum/component/knotting), "A volf with a knotted penis carries the knot component.")

	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	goblin.gender = MALE
	goblin.give_genitals()
	TEST_ASSERT_NOTNULL(goblin.getorganslot(ORGAN_SLOT_PENIS), "Test setup: the goblin has a penis.")
	TEST_ASSERT_NULL(goblin.GetComponent(/datum/component/knotting), "A plain penis never brings the knot component.")

/datum/unit_test/npc_knotting/knotted_hunter_ties_on_climax

/datum/unit_test/npc_knotting/knotted_hunter_ties_on_climax/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/volf = make_volf()
	var/mob/living/carbon/human/target = make_target()
	target.set_body_position(LYING_DOWN)
	var/datum/ai_controller/controller = start_hunt(volf, target)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	var/datum/sex_action/npc/action = start_knotting_act(controller, volf, target)
	TEST_ASSERT_NOTNULL(action, "The hunt starts a knotting act on a female target.")
	TEST_ASSERT(!action.stop_on_climax, "A knotted hunter's knotting act runs on past its climax.")
	TEST_ASSERT(action.can_knot, "NPC penetrations may knot.")

	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/datum/sex_action/npc/plain_act = allocate(/datum/sex_action/npc/npc_vaginal_sex)
	TEST_ASSERT(!hunt.pace_for_knot(goblin, plain_act), "A hunter without a knot keeps the normal climax stop.")
	TEST_ASSERT(plain_act.stop_on_climax, "A plain hunter's act still stops on climax.")

	SEND_SIGNAL(volf, COMSIG_SEX_SET_AROUSAL, 60)
	TEST_ASSERT(action.try_knot_on_climax(volf, target), "A roused knotted hunter ties on climax.")
	var/datum/component/knotting/knot = volf.GetComponent(/datum/component/knotting)
	TEST_ASSERT_EQUAL(knot.knotted_recipient, target, "The target is the one tied.")
	TEST_ASSERT_EQUAL(knot.knotted_owner, volf, "The volf owns the knot.")
	TEST_ASSERT_NOTNULL(target.has_status_effect(/datum/status_effect/knot_tied), "The target carries the knot_tied status.")
	TEST_ASSERT_EQUAL(horny_knot_between(target, volf), knot, "The pair lookup finds the knot from either side.")
	TEST_ASSERT_EQUAL(action.get_act_stage(volf, target), "tied", "A tied act reads as tied.")
	TEST_ASSERT(!action.try_knot_on_climax(target, volf), "The receiver's climax never ties through the hunter's act.")
	hunt.finish_action(controller, TRUE, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	settle(volf, target)

/datum/unit_test/npc_knotting/tied_hunt_waits_then_releases

/datum/unit_test/npc_knotting/tied_hunt_waits_then_releases/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/volf = make_volf()
	var/mob/living/carbon/human/target = make_target()
	target.set_body_position(LYING_DOWN)
	var/datum/ai_controller/controller = start_hunt(volf, target)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, hunt), "Test setup: the hunt starts.")
	var/datum/sex_action/npc/action = start_knotting_act(controller, volf, target)
	TEST_ASSERT_NOTNULL(action, "Test setup: a knotting act runs.")
	SEND_SIGNAL(volf, COMSIG_SEX_SET_AROUSAL, 60)
	TEST_ASSERT(action.try_knot_on_climax(volf, target), "Test setup: the volf ties.")
	var/datum/component/knotting/knot = volf.GetComponent(/datum/component/knotting)
	var/datum/component/arousal/arousal = volf.GetComponent(/datum/component/arousal)
	arousal.last_ejaculation_time = world.time
	// A standing target would fail the posture gate; the knot must stand in for it.
	target.set_body_position(STANDING_UP)
	controller.set_blackboard_key(BB_HORNY_LUST, 10)
	controller.set_blackboard_key(BB_HORNY_PHASE, HORNY_PHASE_USE)
	var/datum/horny_family_profile/profile = volf.get_horny_family_profile()

	hunt.perform_use(controller, volf, target, target, null, profile, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, hunt), "A fresh climax does not end a tied hunt.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_USE, "The tied hunter stays in the use phase.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_TIE_UNTIL], world.time + profile.tie_time, "The tie deadline is set from the family's tie time.")
	TEST_ASSERT_EQUAL(knot.knotted_recipient, target, "The knot still holds.")

	controller.set_blackboard_key(BB_HORNY_TIE_NEXT_TUG, world.time - 1)
	hunt.perform_use(controller, volf, target, target, null, profile, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_TIE_NEXT_TUG], world.time + HORNY_TIE_TUG_INTERVAL, "A tug beat schedules the next one.")
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, hunt), "A tug beat keeps the hunt going.")

	controller.set_blackboard_key(BB_HORNY_TIE_UNTIL, world.time - 1)
	hunt.perform_use(controller, volf, target, target, null, profile, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	TEST_ASSERT_NULL(knot.knotted_recipient, "Past the deadline the knot is released.")
	TEST_ASSERT_NULL(target.has_status_effect(/datum/status_effect/knot_tied), "The target is no longer tied.")
	TEST_ASSERT(!LAZYACCESS(controller.current_behaviors, hunt), "The hunt ends once the tie is over.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_LUST], 0, "The hunt ends sated, which clears the lust.")
	TEST_ASSERT_NULL(controller.blackboard[BB_HORNY_TIE_UNTIL], "The tie deadline is cleared.")
	settle(volf, target)

/datum/unit_test/npc_knotting/interrupted_hunt_tears_the_knot

/datum/unit_test/npc_knotting/interrupted_hunt_tears_the_knot/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/volf = make_volf()
	var/mob/living/carbon/human/target = make_target()
	target.set_body_position(LYING_DOWN)
	var/datum/ai_controller/controller = start_hunt(volf, target)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	var/datum/sex_action/npc/action = start_knotting_act(controller, volf, target)
	TEST_ASSERT_NOTNULL(action, "Test setup: a knotting act runs.")
	SEND_SIGNAL(volf, COMSIG_SEX_SET_AROUSAL, 60)
	TEST_ASSERT(action.try_knot_on_climax(volf, target), "Test setup: the volf ties.")
	var/datum/component/knotting/knot = volf.GetComponent(/datum/component/knotting)

	hunt.finish_action(controller, FALSE, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	TEST_ASSERT_NULL(horny_knot_between(volf, target), "An interrupted hunt leaves no knot.")
	TEST_ASSERT_NULL(knot.knotted_recipient, "The component lets the target go.")
	TEST_ASSERT_NULL(target.has_status_effect(/datum/status_effect/knot_tied), "The target carries no knot_tied.")
	TEST_ASSERT_NULL(volf.has_status_effect(/datum/status_effect/knotted), "The volf carries no knotted.")
	settle(volf, target)

/datum/unit_test/npc_knotting/plain_penis_hunter_never_ties

/datum/unit_test/npc_knotting/plain_penis_hunter_never_ties/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	goblin.gender = MALE
	goblin.give_genitals()
	var/mob/living/carbon/human/target = make_target(HORNY_MOB_TYPE_HUMANOIDS)
	var/datum/sex_scene_controller/scene_controller = goblin.open_sex_scene(target, FALSE)
	TEST_ASSERT_NOTNULL(scene_controller, "Test setup: the goblin opens a scene.")
	var/datum/sex_action/npc/action = scene_controller.try_start_action(/datum/sex_action/npc/npc_vaginal_sex, "ai")
	TEST_ASSERT_NOTNULL(action, "Test setup: the goblin's vaginal act starts.")
	SEND_SIGNAL(goblin, COMSIG_SEX_SET_AROUSAL, 60)
	TEST_ASSERT(!action.try_knot_on_climax(goblin, target), "A plain penis never ties.")
	TEST_ASSERT_NULL(goblin.GetComponent(/datum/component/knotting), "A plain hunter has no knot component.")
	TEST_ASSERT_NULL(target.has_status_effect(/datum/status_effect/knot_tied), "Nothing ties the target.")
	settle(goblin, target)

/datum/unit_test/npc_knotting/human_knot_still_ties

/datum/unit_test/npc_knotting/human_knot_still_ties/Run()
	var/mob/living/carbon/human/knotter = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = make_target()
	knotter.gender = MALE
	var/obj/item/organ/genitals/penis/old_penis = knotter.getorganslot(ORGAN_SLOT_PENIS)
	if(old_penis)
		old_penis.Remove(knotter)
		qdel(old_penis)
	var/obj/item/organ/genitals/penis/knotted/knotted_penis = new
	knotted_penis.Insert(knotter, TRUE)
	var/datum/component/knotting/knot = knotter.GetComponent(/datum/component/knotting)
	TEST_ASSERT_NOTNULL(knot, "A human with a knotted penis carries the knot component.")
	SEND_SIGNAL(knotter, COMSIG_SEX_SET_AROUSAL, 60)

	TEST_ASSERT(SEND_SIGNAL(knotter, COMSIG_SEX_TRY_KNOT, target, SEX_FORCE_MID, null), "A roused human knotter ties.")
	TEST_ASSERT_EQUAL(knot.knotted_recipient, target, "The human target is tied.")
	TEST_ASSERT_NOTNULL(target.has_status_effect(/datum/status_effect/knot_tied), "The target carries knot_tied.")
	TEST_ASSERT_NOTNULL(knotter.has_status_effect(/datum/status_effect/knotted), "The knotter carries knotted.")

	SEND_SIGNAL(knotter, COMSIG_SEX_REMOVE_KNOT, FALSE, TRUE)
	TEST_ASSERT_NULL(knot.knotted_recipient, "The untie clears the recipient.")
	TEST_ASSERT_NULL(target.has_status_effect(/datum/status_effect/knot_tied), "The untie clears knot_tied.")
	TEST_ASSERT_NULL(knotter.has_status_effect(/datum/status_effect/knotted), "The untie clears knotted.")
	target.SetKnockdown(0)
	target.SetStun(0)
	sleep(1)

/datum/unit_test/npc_knotting/tie_lines_are_well_formed

/datum/unit_test/npc_knotting/tie_lines_are_well_formed/Run()
	var/mob/living/carbon/human/species/goblin/npc/hunter = allocate(/mob/living/carbon/human/species/goblin/npc)
	hunter.name = "goblin"
	hunter.real_name = "goblin"
	hunter.pronouns = IT_ITS
	var/mob/living/carbon/human/victim = make_target()
	for(var/family_flag in list(NONE, HORNY_MOB_TYPE_BEASTS, HORNY_MOB_TYPE_LYCANS))
		var/datum/horny_family_profile/profile = horny_profile_for_flag(family_flag)
		var/list/lines = profile.get_tie_lines(hunter, victim)
		for(var/key in list("tug", "tug_me", "tug_hear", "release", "release_me", "release_hear"))
			if(!lines[key])
				TEST_FAIL("[profile.type] has no [key] line.")
		for(var/problem in check_lines(lines, "[profile.type]", "_me"))
			TEST_FAIL(problem)
		TEST_ASSERT_EQUAL(findtext(lines["tug"], "[hunter]"), 1, "[profile.type] tug starts with the hunter: [lines["tug"]]")
	var/datum/horny_family_profile/beasts = horny_profile_for_flag(HORNY_MOB_TYPE_BEASTS)
	var/datum/horny_family_profile/lycans = horny_profile_for_flag(HORNY_MOB_TYPE_LYCANS)
	TEST_ASSERT_EQUAL(beasts.tie_time, 60 SECONDS, "Beasts stay tied a minute.")
	TEST_ASSERT_EQUAL(lycans.tie_time, 90 SECONDS, "Lycans stay tied longest.")

	for(var/act_type in list(/datum/sex_action/npc/npc_vaginal_sex, /datum/sex_action/npc/npc_anal_sex, /datum/sex_action/npc/npc_vaginal_ride_sex, /datum/sex_action/npc/npc_anal_ride_sex))
		var/datum/sex_action/npc/act = allocate(act_type)
		TEST_ASSERT(act.knot_on_finish && act.can_knot, "[act_type] may knot.")
		var/list/lines = act.get_perform_lines(hunter, victim, "tied")
		TEST_ASSERT_NOTNULL(lines, "[act_type] has tied lines.")
		for(var/problem in check_lines(lines, "[act_type] tied"))
			TEST_FAIL(problem)
		TEST_ASSERT_EQUAL(findtext(lines["room"], "[hunter]"), 1, "[act_type] tied room line starts with the hunter: [lines["room"]]")
		TEST_ASSERT(findtext(lines["room"], "knot"), "[act_type] tied room line names the knot: [lines["room"]]")
