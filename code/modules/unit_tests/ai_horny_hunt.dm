/// The hunt: the posture gate, temper, the rush, the damage budget, the sprint and the overwhelmed beat.
/datum/unit_test/ai_horny_hunt
	abstract_type = /datum/unit_test/ai_horny_hunt
#ifdef FOCUS_AI_HORNY_HUNT_TEST
	focus = TRUE
#endif

/// A goblin that wants a clientless partner, with the hunt behaviour running.
/datum/unit_test/ai_horny_hunt/proc/start_hunt(mob/living/carbon/human/species/goblin/npc/goblin, mob/living/carbon/human/partner)
	prepare_horny_grab_test_pair(goblin, partner)
	var/datum/ai_controller/controller = goblin.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	controller.queue_behavior(/datum/ai_behavior/horny, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)
	return controller

/// One perform of the hunt behaviour, as SSai_behaviors would run it.
/datum/unit_test/ai_horny_hunt/proc/hunt_tick(datum/ai_controller/controller)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	hunt.perform(0.1, controller, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)

/// Teardown: a floored, grabbed human runtimes in its async get_up() when deleted.
/datum/unit_test/ai_horny_hunt/proc/end_hunt(datum/ai_controller/controller, mob/living/partner)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	if(LAZYACCESS(controller.current_behaviors, hunt))
		hunt.finish_action(controller, FALSE, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	var/mob/living/pawn = controller.pawn
	pawn.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// Nothing starts on a target that is still on its feet and free.
/datum/unit_test/ai_horny_hunt/act_waits_for_a_subdued_target

/datum/unit_test/ai_horny_hunt/act_waits_for_a_subdued_target/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, hunt), "Test setup: the hunt should start.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_SEIZE, "A hunter already next to its target skips the tell and goes for the catch.")
	TEST_ASSERT(!horny_target_is_subdued(goblin, partner), "Test setup: a standing, free partner is not subdued.")

	// Two beats of the ladder: a grab and a grip. The partner is still on their feet.
	for(var/i in 1 to 2)
		goblin.next_move = 0
		hunt_tick(controller)
		TEST_ASSERT_EQUAL(partner.body_position, STANDING_UP, "Test setup: the first two beats grab and grip, they do not floor the partner.")
		TEST_ASSERT(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_USE, "No act may start while the partner stands free (phase [controller.blackboard[BB_HORNY_PHASE]], pulledby [partner.pulledby], grab [goblin.grab_state]).")
	TEST_ASSERT(!length(partner.sex_scene?.get_actions_involving(partner)), "No sex action may run on a standing, free partner.")

	partner.SetKnockdown(30 SECONDS)
	TEST_ASSERT(horny_target_is_subdued(goblin, partner), "A floored partner counts as subdued.")
	for(var/i in 1 to 12)
		goblin.next_move = 0
		hunt_tick(controller)
		if(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_SEIZE)
			break
	TEST_ASSERT(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_SEIZE, "Once the partner is down the hunt moves past the catch within a few beats.")
	end_hunt(controller, partner)

/// A fireball to the face makes the hunter come on faster; it does not end the hunt.
/datum/unit_test/ai_horny_hunt/ranged_hits_rush_without_cancel

/datum/unit_test/ai_horny_hunt/ranged_hits_rush_without_cancel/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)

	for(var/i in 1 to 3)
		controller.set_blackboard_key(BB_LAST_RANGED_ATTACKER, partner)
		controller.set_blackboard_key(BB_LAST_RANGED_HIT_TIME, world.time)
		SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, partner, 1)
	TEST_ASSERT(controller.blackboard[BB_HORNY_TEMPER] >= HORNY_TEMPER_ROUGH, "Three ranged hits should leave the hunter rough-tempered.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_RUSH_UNTIL] > world.time, "A ranged hit should start a rush.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], partner, "Light ranged hits must not end the hunt.")
	TEST_ASSERT_NULL(controller.blackboard[BB_HORNY_AGGRO_TARGET], "Light ranged hits must not turn the hunter hostile.")
	TEST_ASSERT(LAZYACCESS(controller.current_behaviors, hunt), "The hunt behaviour must survive light ranged hits.")
	end_hunt(controller, partner)

/// Damage past the budget turns the hunt into a real fight.
/datum/unit_test/ai_horny_hunt/damage_budget_turns_the_hunt_into_a_fight

/datum/unit_test/ai_horny_hunt/damage_budget_turns_the_hunt_into_a_fight/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	var/budget = goblin.maxHealth * HORNY_LETHAL_DAMAGE_SHARE

	SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, partner, budget * 0.5)
	var/list/hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
	TEST_ASSERT(!hostile_targets || isnull(hostile_targets[partner]), "Half the budget is a rough partner, not a mortal threat.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], partner, "Half the budget keeps the hunt alive.")

	SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, partner, budget * 0.6)
	hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
	TEST_ASSERT(hostile_targets && !isnull(hostile_targets[partner]), "Damage past the budget makes the partner hostile.")
	TEST_ASSERT_NULL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], "A fight clears the horny target.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], partner, "The attacker becomes the combat target.")
	end_hunt(controller, partner)

/// An attacker the hunter may not want is mortal danger: combat first.
/datum/unit_test/ai_horny_hunt/third_party_attack_takes_priority

/datum/unit_test/ai_horny_hunt/third_party_attack_takes_priority/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)

	SEND_SIGNAL(goblin, COMSIG_ATOM_WAS_ATTACKED, stranger, 5)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], stranger, "A stranger's attack must become the combat target at once.")
	TEST_ASSERT_NULL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], "Mortal danger ends the hunt.")
	end_hunt(controller, partner)

/// A furious humanoid wrestles instead of using, then comes back calmer.
/datum/unit_test/ai_horny_hunt/furious_humanoid_breaks_off_and_returns

/datum/unit_test/ai_horny_hunt/furious_humanoid_breaks_off_and_returns/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	controller.set_blackboard_key(BB_HORNY_TEMPER, HORNY_TEMPER_FURIOUS + 10)
	controller.set_blackboard_key(BB_HORNY_TEMPER_TIME, world.time)

	hunt_tick(controller)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_BREAK_OFF, "A furious hunter breaks off.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_BREAK_OFF_UNTIL] > world.time, "The break-off has an end.")
	TEST_ASSERT(!length(partner.sex_scene?.get_actions_involving(partner)), "No act runs during a break-off.")

	controller.set_blackboard_key(BB_HORNY_BREAK_OFF_UNTIL, world.time - 1)
	hunt_tick(controller)
	TEST_ASSERT(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_BREAK_OFF, "The hunt resumes when the window ends.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_TEMPER] <= HORNY_TEMPER_ROUGH, "Coming back calms the hunter to rough at most.")
	end_hunt(controller, partner)

/// A humanoid hunter runs while it rushes, and walks again when the hunt ends.
/datum/unit_test/ai_horny_hunt/hunting_human_runs_and_walks_after

/datum/unit_test/ai_horny_hunt/hunting_human_runs_and_walks_after/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	var/datum/ai_behavior/horny/hunt = GET_AI_BEHAVIOR(/datum/ai_behavior/horny)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_NOTICE, "A hunter with a gap to close starts with the tell.")

	controller.set_blackboard_key(BB_HORNY_PHASE, HORNY_PHASE_STALK)
	controller.set_blackboard_key(BB_HORNY_RUSH_UNTIL, world.time + 10 SECONDS)
	hunt_tick(controller)
	TEST_ASSERT_EQUAL(goblin.m_intent, MOVE_INTENT_RUN, "A rushing humanoid hunter should switch to the run intent.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_SPRINTING], "The hunt should remember that it set the run intent.")

	hunt.finish_action(controller, FALSE, BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	TEST_ASSERT_EQUAL(goblin.m_intent, MOVE_INTENT_WALK, "The hunter walks again when the hunt ends.")
	end_hunt(controller, partner)

/// A hunter at the top of its lust lets go, presents, and gets up again calmer.
/datum/unit_test/ai_horny_hunt/overwhelmed_hunter_presents

/datum/unit_test/ai_horny_hunt/overwhelmed_hunter_presents/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	partner.SetKnockdown(30 SECONDS)
	controller.set_blackboard_key(BB_HORNY_LUST, HORNY_LUST_MAX - HORNY_LUST_PER_CLIMAX + 1)

	SEND_SIGNAL(goblin, COMSIG_SEX_CLIMAX, null, goblin, partner, goblin)
	TEST_ASSERT(controller.blackboard[BB_HORNY_LUST] >= HORNY_LUST_MAX, "The hunter's own climax feeds its lust.")

	hunt_tick(controller)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_PRESENT, "A hunter at the top of its lust lets go and presents.")
	TEST_ASSERT_NULL(goblin.pulling, "Presenting drops the hold.")

	controller.set_blackboard_key(BB_HORNY_PRESENT_UNTIL, world.time - 1)
	hunt_tick(controller)
	TEST_ASSERT(controller.blackboard[BB_HORNY_PHASE] != HORNY_PHASE_PRESENT, "The hunter gets up again when the beat ends.")
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_LUST], HORNY_LUST_AFTER_PRESENT, "Presenting takes the edge off the lust.")
	end_hunt(controller, partner)

/// The real ladder: grab, grip, tackle, get on top, second grip, pin. No invented roll anywhere.
/datum/unit_test/ai_horny_hunt/grab_ladder_reaches_the_pin

/datum/unit_test/ai_horny_hunt/grab_ladder_reaches_the_pin/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(goblin, partner)
	goblin.change_stat(STAT_STRENGTH, 10) // the tackle is strength against constitution; stack the odds so the test does not flake
	var/datum/ai_controller/controller = goblin.ai_controller

	var/result = HORNY_SEIZE_WAIT
	for(var/beat in 1 to 40)
		goblin.next_move = 0
		result = horny_seize_step(goblin, partner, controller)
		if(result == HORNY_SEIZE_DONE)
			break
		TEST_ASSERT(result != HORNY_SEIZE_FAILED, "The ladder must not fail on an adjacent, free partner (beat [beat]).")
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_DONE, "Forty beats of the ladder should end in a pin.")
	TEST_ASSERT_EQUAL(partner.body_position, LYING_DOWN, "The ladder ends with the partner on the ground.")
	TEST_ASSERT_EQUAL(partner.pulledby, goblin, "The hunter still holds the partner.")
	TEST_ASSERT(goblin.grab_state >= GRAB_AGGRESSIVE, "The hold is aggressive.")
	TEST_ASSERT_EQUAL(horny_grabs_on_target(goblin, partner), 2, "The pin takes both hands.")
	TEST_ASSERT_EQUAL(goblin.loc, partner.loc, "The pinner stands over the pinned.")
	TEST_ASSERT(partner.IsStun(), "The real pin stuns the partner.")
	goblin.stop_pulling()
	partner.SetStun(0)
	partner.SetKnockdown(0)
	sleep(1)

/// A yielding target is eased down and held gently, never wrestled.
/datum/unit_test/ai_horny_hunt/yielding_target_is_eased_down

/datum/unit_test/ai_horny_hunt/yielding_target_is_eased_down/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(goblin, partner)
	var/datum/ai_controller/controller = goblin.ai_controller
	partner.surrendering = TRUE

	TEST_ASSERT_EQUAL(horny_seize_step(goblin, partner, controller), HORNY_SEIZE_ACTED, "Easing a yielding target down is one beat.")
	TEST_ASSERT_EQUAL(partner.body_position, LYING_DOWN, "A yielding target is laid down, not wrestled.")
	var/result = HORNY_SEIZE_WAIT
	for(var/beat in 1 to 10)
		goblin.next_move = 0
		result = horny_seize_step(goblin, partner, controller)
		TEST_ASSERT(result != HORNY_SEIZE_FAILED, "Holding a yielding target must not fail (beat [beat]).")
		if(result == HORNY_SEIZE_DONE)
			break
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_DONE, "A yielding target is held and caught within a few beats.")
	TEST_ASSERT_EQUAL(partner.pulledby, goblin, "The yielding target is held.")
	TEST_ASSERT(goblin.grab_state < GRAB_AGGRESSIVE, "A yielding target is held, not gripped.")
	goblin.stop_pulling()
	partner.surrendering = FALSE
	partner.SetKnockdown(0)
	sleep(1)

/// A player outside the mob's prefs is disarmed and brought down with the same moves, and never used.
/datum/unit_test/ai_horny_hunt/out_of_scope_player_is_disarmed_and_held_but_never_used

/datum/unit_test/ai_horny_hunt/out_of_scope_player_is_disarmed_and_held_but_never_used/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	goblin.gender = MALE
	goblin.change_stat(STAT_STRENGTH, 10)
	partner.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_SPIDERS,
		/datum/erp_preference/boolean/nonmatching_horny_mobs_are_nonlethal = TRUE,
	))
	var/datum/ai_controller/controller = goblin.ai_controller
	controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/basic/unit_test_allow_clientless_horny))
	var/datum/targetting_datum/targeting = controller.blackboard[BB_TARGETTING_DATUM]
	TEST_ASSERT(targeting.can_nonlethally_subdue_mob_erp_target(goblin, partner), "Test setup: a player with the disarm pref and another family enabled takes the nonlethal path.")
	TEST_ASSERT(!targeting.can_attack(goblin, partner), "Test setup: such a player is never a lethal target.")
	var/obj/item/weapon/sword/iron/sword = allocate(/obj/item/weapon/sword/iron)
	partner.put_in_hands(sword)
	TEST_ASSERT_EQUAL(sword.loc, partner, "Test setup: the player holds a sword.")

	var/datum/ai_behavior/melee = GET_AI_BEHAVIOR(/datum/ai_behavior/basic_melee_attack)
	for(var/beat in 1 to 40)
		goblin.next_click = 0
		goblin.next_move = 0
		goblin.SetKnockdown(0)
		TEST_ASSERT(melee.attempt_nonlethal_mob_erp_subdue(targeting, goblin, partner), "The nonlethal path must claim every beat on an out-of-scope player (beat [beat]).")
		if(partner.body_position == LYING_DOWN && partner.pulledby == goblin && sword.loc != partner)
			break
	TEST_ASSERT(sword.loc != partner, "The sword must come loose.")
	TEST_ASSERT_EQUAL(partner.body_position, LYING_DOWN, "The player is brought down.")
	TEST_ASSERT_EQUAL(partner.pulledby, goblin, "The player is held.")
	TEST_ASSERT(!length(partner.sex_scene?.get_actions_involving(partner)), "An out-of-scope player is never used.")
	TEST_ASSERT_NULL(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET], "An out-of-scope player never becomes a horny target.")
	goblin.stop_pulling()
	partner.SetStun(0)
	partner.SetKnockdown(0)
	sleep(1)

/// A broken grab feeds the hunter's temper, and the hunter waits out the grace window before it grabs again.
/datum/unit_test/ai_horny_hunt/broken_grab_is_felt_and_waited_out

/datum/unit_test/ai_horny_hunt/broken_grab_is_felt_and_waited_out/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	for(var/beat in 1 to 10)
		goblin.next_move = 0
		hunt_tick(controller)
		if(goblin.pulling == partner)
			break
	TEST_ASSERT_EQUAL(goblin.pulling, partner, "Test setup: the first beats of the catch take a grab.")
	var/temper_before = controller.blackboard[BB_HORNY_TEMPER] || 0

	goblin.stop_pulling(pulling_broke_free = TRUE) // the partner wrenches free
	TEST_ASSERT(TIMER_COOLDOWN_RUNNING(partner, "broke_free"), "Test setup: breaking free opens the grace window.")
	goblin.next_move = 0
	hunt_tick(controller)
	TEST_ASSERT_NULL(goblin.pulling, "During the grace window the hunter does not grab again.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_TEMPER] > temper_before, "A broken grab feeds the hunter's temper.")

	TIMER_COOLDOWN_END(partner, "broke_free")
	for(var/beat in 1 to 10)
		goblin.next_move = 0
		hunt_tick(controller)
		if(goblin.pulling == partner)
			break
	TEST_ASSERT_EQUAL(goblin.pulling, partner, "Once the window closes the hunter grabs again.")
	end_hunt(controller, partner)

/// A hunter of the given family that wants a clientless partner.
/datum/unit_test/ai_horny_hunt/proc/prepare_hunt_pair(mob/living/hunter, mob/living/carbon/human/partner, family_flag)
	hunter.gender = MALE
	partner.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = family_flag,
	))
	hunter.ai_controller?.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/basic/unit_test_allow_clientless_horny))

/// A hunt against a partner some tiles away, left in the stalk phase.
/datum/unit_test/ai_horny_hunt/proc/start_stalk(mob/living/hunter, mob/living/carbon/human/partner)
	var/datum/ai_controller/controller = hunter.ai_controller
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	controller.queue_behavior(/datum/ai_behavior/horny, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)
	controller.set_blackboard_key(BB_HORNY_PHASE, HORNY_PHASE_STALK)
	return controller

/// A beast puts a standing partner down with its own strength roll and pins them with its body.
/datum/unit_test/ai_horny_hunt/handless_hunter_bears_down_and_holds

/datum/unit_test/ai_horny_hunt/handless_hunter_bears_down_and_holds/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/wolf = allocate(/mob/living/simple_animal/hostile/retaliate/wolf)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_hunt_pair(wolf, partner, HORNY_MOB_TYPE_BEASTS)
	var/datum/ai_controller/controller = wolf.ai_controller
	var/datum/horny_family_profile/profile = wolf.get_horny_family_profile()
	TEST_ASSERT_EQUAL(profile.seize_move, HORNY_MOVE_POUNCE, "Test setup: wolves are a pounce family.")

	var/result = HORNY_SEIZE_WAIT
	for(var/beat in 1 to 40)
		wolf.next_move = 0
		result = horny_handless_seize_step(wolf, partner, controller, profile)
		if(result == HORNY_SEIZE_DONE)
			break
		TEST_ASSERT(result != HORNY_SEIZE_FAILED, "The catch must not fail on an adjacent, free partner (beat [beat]).")
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_DONE, "Forty beats should bear the partner down and hold them.")
	TEST_ASSERT_EQUAL(partner.body_position, LYING_DOWN, "The partner ends on the ground.")
	TEST_ASSERT_EQUAL(partner.pulledby, wolf, "The wolf holds the partner.")
	TEST_ASSERT(wolf.grab_state >= GRAB_AGGRESSIVE, "The body hold is aggressive.")
	wolf.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// A coil wraps a standing partner first, squeezes the breath out, then drags them down.
/datum/unit_test/ai_horny_hunt/coil_squeezes_then_drags_down

/datum/unit_test/ai_horny_hunt/coil_squeezes_then_drags_down/Run()
	var/mob/living/simple_animal/hostile/retaliate/tentacle/tentacle = allocate(/mob/living/simple_animal/hostile/retaliate/tentacle)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_hunt_pair(tentacle, partner, HORNY_MOB_TYPE_TENTACLES)
	var/datum/ai_controller/controller = tentacle.ai_controller
	var/datum/horny_family_profile/profile = tentacle.get_horny_family_profile()
	TEST_ASSERT_EQUAL(profile.seize_move, HORNY_MOVE_COIL, "Test setup: tentacles coil.")

	for(var/beat in 1 to 5)
		tentacle.next_move = 0
		horny_handless_seize_step(tentacle, partner, controller, profile)
		if(partner.pulledby == tentacle)
			break
	TEST_ASSERT_EQUAL(partner.pulledby, tentacle, "A coil wraps the partner while they still stand.")
	TEST_ASSERT(tentacle.grab_state >= GRAB_AGGRESSIVE, "The coil is an aggressive hold.")
	var/fatigue_before = partner.stamina

	var/result = HORNY_SEIZE_WAIT
	for(var/beat in 1 to 40)
		tentacle.next_move = 0
		result = horny_handless_seize_step(tentacle, partner, controller, profile)
		if(result == HORNY_SEIZE_DONE)
			break
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_DONE, "The coil drags the partner down within forty beats.")
	TEST_ASSERT_EQUAL(partner.body_position, LYING_DOWN, "The partner ends on the ground.")
	TEST_ASSERT(partner.stamina > fatigue_before, "The squeeze costs the partner stamina.")
	tentacle.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// A tentacle two tiles out lashes and drags the partner a step closer.
/datum/unit_test/ai_horny_hunt/lash_drags_a_step_closer

/datum/unit_test/ai_horny_hunt/lash_drags_a_step_closer/Run()
	var/mob/living/simple_animal/hostile/retaliate/tentacle/tentacle = allocate(/mob/living/simple_animal/hostile/retaliate/tentacle, run_loc_floor_bottom_left)
	var/turf/two_out = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human, two_out)
	prepare_hunt_pair(tentacle, partner, HORNY_MOB_TYPE_TENTACLES)
	var/datum/ai_controller/controller = start_stalk(tentacle, partner)
	TEST_ASSERT_EQUAL(get_dist(tentacle, partner), 2, "Test setup: the partner stands two tiles out.")

	for(var/beat in 1 to 15)
		controller.set_blackboard_key(BB_HORNY_LASH_COOLDOWN, 0)
		hunt_tick(controller)
		if(get_dist(tentacle, partner) <= 1)
			break
	TEST_ASSERT(get_dist(tentacle, partner) <= 1, "The lash drags the partner a step closer within a few beats.")
	end_hunt(controller, partner)

/// A wolf three tiles out pounces, and lands next to its partner.
/datum/unit_test/ai_horny_hunt/pounce_leaps_the_gap

/datum/unit_test/ai_horny_hunt/pounce_leaps_the_gap/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/wolf = allocate(/mob/living/simple_animal/hostile/retaliate/wolf, run_loc_floor_bottom_left)
	var/turf/three_out = locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human, three_out)
	partner.setDir(EAST) // looking away, so the wolf has no reason to circle
	prepare_hunt_pair(wolf, partner, HORNY_MOB_TYPE_BEASTS)
	var/datum/ai_controller/controller = start_stalk(wolf, partner)

	hunt_tick(controller)
	TEST_ASSERT(controller.blackboard[BB_HORNY_POUNCE_COOLDOWN] > world.time, "A wolf three tiles out pounces.")
	sleep(2 SECONDS)
	TEST_ASSERT(get_dist(wolf, partner) <= 1, "The pounce lands the wolf next to its partner.")
	end_hunt(controller, partner)

/// A watched beast works round to its target's back instead of pouncing into a face that sees it coming.
/datum/unit_test/ai_horny_hunt/beast_circles_to_the_back_first

/datum/unit_test/ai_horny_hunt/beast_circles_to_the_back_first/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/wolf = allocate(/mob/living/simple_animal/hostile/retaliate/wolf, run_loc_floor_bottom_left)
	var/turf/three_out = locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human, three_out)
	partner.setDir(WEST) // watching the wolf
	prepare_hunt_pair(wolf, partner, HORNY_MOB_TYPE_BEASTS)
	var/datum/ai_controller/controller = start_stalk(wolf, partner)

	hunt_tick(controller)
	var/turf/behind = get_step(partner, EAST)
	TEST_ASSERT_EQUAL(controller.current_movement_target, behind, "A watched wolf heads for the tile behind its target.")
	TEST_ASSERT_NULL(controller.blackboard[BB_HORNY_POUNCE_COOLDOWN], "It does not pounce while the target is looking at it.")
	end_hunt(controller, partner)

/// The howl brings packmates who pass their own pref gate, and no more than the cap.
/datum/unit_test/ai_horny_hunt/pack_call_shares_the_target_within_prefs_and_cap

/datum/unit_test/ai_horny_hunt/pack_call_shares_the_target_within_prefs_and_cap/Run()
	var/turf/two_out = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/mob/living/simple_animal/hostile/retaliate/wolf/hunter = allocate(/mob/living/simple_animal/hostile/retaliate/wolf, two_out)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	prepare_hunt_pair(hunter, partner, HORNY_MOB_TYPE_BEASTS)
	// The female comes first so that a call which ignores prefs would pick her up before any male.
	var/mob/living/simple_animal/hostile/retaliate/wolf/female = allocate(/mob/living/simple_animal/hostile/retaliate/wolf, run_loc_floor_bottom_left)
	female.gender = FEMALE
	female.ai_controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/basic/unit_test_allow_clientless_horny))
	var/list/males = list()
	for(var/i in 1 to 3)
		var/mob/living/simple_animal/hostile/retaliate/wolf/mate = allocate(/mob/living/simple_animal/hostile/retaliate/wolf, run_loc_floor_bottom_left)
		mate.gender = MALE
		mate.ai_controller.set_blackboard_key(BB_TARGETTING_DATUM, allocate(/datum/targetting_datum/basic/unit_test_allow_clientless_horny))
		males += mate

	var/datum/ai_controller/controller = hunter.ai_controller
	var/datum/horny_family_profile/profile = hunter.get_horny_family_profile()
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	controller.queue_behavior(/datum/ai_behavior/horny, BB_BASIC_MOB_CURRENT_HORNY_TARGET, BB_TARGETTING_DATUM)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_NOTICE, "Test setup: a wolf with a gap to close starts with the tell.")

	// First call, cap off: every male answers, the female never does.
	var/old_cap = profile.pack_cap
	profile.pack_cap = 0
	hunt_tick(controller)
	var/uncapped_males = count_pack_answers(males, partner)
	var/female_answered = female.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] == partner
	for(var/mob/living/mate as anything in males)
		mate.ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	female.ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)

	// Second call, cap on: three hunters at most, so two of the three males answer.
	profile.pack_cap = old_cap
	controller.clear_blackboard_key(BB_HORNY_PACK_CALLED)
	horny_call_pack(hunter, partner, controller, profile)
	var/capped_males = count_pack_answers(males, partner)
	for(var/mob/living/mate as anything in males)
		mate.ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	end_hunt(controller, partner)

	TEST_ASSERT_EQUAL(uncapped_males, 3, "With the cap off, every packmate the partner's prefs allow answers the howl.")
	TEST_ASSERT(!female_answered, "A packmate the partner's prefs exclude never answers.")
	TEST_ASSERT_EQUAL(capped_males, 2, "With the cap on, the howl brings two packmates: three hunters is the cap.")

/datum/unit_test/ai_horny_hunt/proc/count_pack_answers(list/mates, mob/living/partner)
	var/answered = 0
	for(var/mob/living/mate as anything in mates)
		if(mate.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET] == partner)
			answered++
	return answered

/// An angered highwayman throws his bola at a target he cannot reach.
/datum/unit_test/ai_horny_hunt/angered_highwayman_lets_a_bola_fly

/datum/unit_test/ai_horny_hunt/angered_highwayman_lets_a_bola_fly/Run()
	var/mob/living/carbon/human/species/human/northern/highwayman/highwayman = allocate(/mob/living/carbon/human/species/human/northern/highwayman, run_loc_floor_bottom_left)
	sleep(15) // the highwayman dresses one second after spawning
	var/turf/four_out = locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human, four_out)
	prepare_hunt_pair(highwayman, partner, HORNY_MOB_TYPE_HUMANOIDS)
	TEST_ASSERT_EQUAL(highwayman.horny_trap_type, /obj/item/rope/net/bola, "Test setup: highwaymen carry a bola.")
	var/datum/ai_controller/controller = start_stalk(highwayman, partner)
	controller.set_blackboard_key(BB_HORNY_TEMPER, HORNY_TEMPER_ROUGH + 10)
	controller.set_blackboard_key(BB_HORNY_TEMPER_TIME, world.time)

	hunt_tick(controller)
	TEST_ASSERT(controller.blackboard[BB_HORNY_TRAP_COOLDOWN] > world.time, "An angered highwayman throws at a target out of reach.")
	var/obj/item/rope/net/bola/bola = locate() in range(HORNY_TRAP_MAX_RANGE, highwayman)
	TEST_ASSERT_NOTNULL(bola, "A bola is in the air or on the ground.")
	TEST_ASSERT(bola.loc != highwayman, "The bola left the highwayman's hands.")
	end_hunt(controller, partner)

/// A hunter with a nose finds the target's freshest scent mark, but only when the target lets scents matter.
/datum/unit_test/ai_horny_hunt/scent_trail_needs_the_pheromone_pref

/datum/unit_test/ai_horny_hunt/scent_trail_needs_the_pheromone_pref/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/wolf = allocate(/mob/living/simple_animal/hostile/retaliate/wolf, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/turf/mark_turf = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z)
	partner.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_BEASTS,
		/datum/erp_preference/bitflag/pheromones = PHEROMONE_SCENT_HEAT,
	))
	leave_fluid_scent(mark_turf, partner, "musk")
	TEST_ASSERT_EQUAL(horny_find_scent_turf(wolf, partner), mark_turf, "With the pref on, the wolf finds the partner's mark.")

	partner.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_BEASTS,
	))
	TEST_ASSERT_NULL(horny_find_scent_turf(wolf, partner), "With the pref off, there is no trail to follow.")

/// Humanoid hunters talk over their heads; the catch is called out once, through the combat bark channel.
/datum/unit_test/ai_horny_hunt/humanoid_hunter_barks_on_the_catch

/datum/unit_test/ai_horny_hunt/humanoid_hunter_barks_on_the_catch/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/ai_controller/controller = start_hunt(goblin, partner)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_HORNY_PHASE], HORNY_PHASE_SEIZE, "Test setup: a hunter next to its target goes straight for the catch.")
	TEST_ASSERT(controller.blackboard[BB_HUMAN_NPC_COMBAT_BARK_COOLDOWN] > world.time, "A goblin calls the catch out loud.")
	var/datum/horny_family_profile/profile = goblin.get_horny_family_profile()
	TEST_ASSERT_NOTNULL(profile.get_bark(goblin, partner, HORNY_BARK_LOST), "Humanoids have a line for a lost target.")
	var/datum/horny_family_profile/beasts = horny_profile_for_flag(HORNY_MOB_TYPE_BEASTS)
	TEST_ASSERT_NULL(beasts.get_bark(goblin, partner, HORNY_BARK_LOST), "Beasts do not talk.")
	end_hunt(controller, partner)

/// The body hold lands in the same beat as the knockdown, before a short knockdown can run out.
/datum/unit_test/ai_horny_hunt/bear_down_holds_in_the_same_beat

/datum/unit_test/ai_horny_hunt/bear_down_holds_in_the_same_beat/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/wolf = allocate(/mob/living/simple_animal/hostile/retaliate/wolf)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_hunt_pair(wolf, partner, HORNY_MOB_TYPE_BEASTS)
	var/datum/ai_controller/controller = wolf.ai_controller
	var/datum/horny_family_profile/profile = wolf.get_horny_family_profile()

	for(var/beat in 1 to 40)
		wolf.next_move = 0
		horny_handless_seize_step(wolf, partner, controller, profile)
		if(partner.body_position == LYING_DOWN)
			break
	TEST_ASSERT_EQUAL(partner.body_position, LYING_DOWN, "Test setup: the wolf should bring the partner down within forty beats.")
	TEST_ASSERT_EQUAL(partner.pulledby, wolf, "The hold lands in the very beat the partner goes down.")
	TEST_ASSERT(wolf.grab_state >= GRAB_AGGRESSIVE, "That hold is already aggressive.")
	wolf.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// A second beast finds the target already pinned by a packmate and joins in instead of waiting for the hold.
/datum/unit_test/ai_horny_hunt/second_beast_joins_a_held_target

/datum/unit_test/ai_horny_hunt/second_beast_joins_a_held_target/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/first = allocate(/mob/living/simple_animal/hostile/retaliate/wolf)
	var/mob/living/simple_animal/hostile/retaliate/wolf/second = allocate(/mob/living/simple_animal/hostile/retaliate/wolf)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_hunt_pair(first, partner, HORNY_MOB_TYPE_BEASTS)
	prepare_hunt_pair(second, partner, HORNY_MOB_TYPE_BEASTS)
	var/datum/horny_family_profile/profile = first.get_horny_family_profile()
	partner.SetKnockdown(30 SECONDS)
	TEST_ASSERT(horny_handless_hold(first, partner, profile), "Test setup: the first wolf pins the floored partner.")

	second.next_move = 0
	var/result = horny_handless_seize_step(second, partner, second.ai_controller, profile)
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_DONE, "A target a packmate already pins counts as caught for the second wolf.")
	TEST_ASSERT_EQUAL(partner.pulledby, first, "The second wolf does not wrench the partner out of the first one's hold.")
	first.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// A handed hunter does not wrench a floored target out of another hunter's aggressive hold; the target counts as caught.
/datum/unit_test/ai_horny_hunt/handed_hunter_does_not_steal_a_held_target

/datum/unit_test/ai_horny_hunt/handed_hunter_does_not_steal_a_held_target/Run()
	var/mob/living/carbon/human/species/goblin/npc/first = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/species/goblin/npc/second = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(first, partner)
	prepare_horny_grab_test_pair(second, partner)
	partner.SetKnockdown(30 SECONDS)
	for(var/beat in 1 to 10)
		first.next_move = 0
		if(horny_take_grab(first, partner, first.ai_controller))
			break
	TEST_ASSERT_EQUAL(partner.pulledby, first, "Test setup: the first goblin holds the floored partner.")
	partner.grippedby(first)
	TEST_ASSERT(first.grab_state >= GRAB_AGGRESSIVE, "Test setup: the first goblin's hold is aggressive.")

	second.next_move = 0
	var/result = horny_seize_step(second, partner, second.ai_controller)
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_DONE, "A target another hunter already pins counts as caught for the second goblin.")
	TEST_ASSERT_EQUAL(partner.pulledby, first, "The second goblin does not steal the hold.")
	first.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// Every failed takedown makes the next body roll easier, by a fixed step.
/datum/unit_test/ai_horny_hunt/wrestling_pressure_raises_the_body_roll

/datum/unit_test/ai_horny_hunt/wrestling_pressure_raises_the_body_roll/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/calm = horny_bear_down_chance(goblin, partner, 0, 0)
	var/pressed = horny_bear_down_chance(goblin, partner, 0, 3)
	TEST_ASSERT(calm < 60, "Test setup: a fresh goblin against a fresh human should not already be near the cap ([calm]).")
	TEST_ASSERT_EQUAL(pressed, calm + 3 * HORNY_PRESSURE_PER_MISS, "Three failed takedowns add three steps to the next roll.")
	TEST_ASSERT_EQUAL(horny_bear_down_chance(goblin, partner, 10, 0), calm + 10, "A family bonus adds straight to the roll.")

/// A weak goblin that cannot throw you still wrestles you down within a reasonable number of beats, in combat mode.
/datum/unit_test/ai_horny_hunt/weak_goblin_wrestles_a_target_down

/datum/unit_test/ai_horny_hunt/weak_goblin_wrestles_a_target_down/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(goblin, partner)
	var/datum/ai_controller/controller = goblin.ai_controller
	TEST_ASSERT(!goblin.cmode, "Test setup: a goblin out of a fight is not in combat mode.")

	var/fought = FALSE
	var/beats_down = 0
	for(var/beat in 1 to 20)
		goblin.next_move = 0
		goblin.SetKnockdown(0)
		horny_seize_step(goblin, partner, controller)
		if(goblin.cmode)
			fought = TRUE
		if(partner.body_position == LYING_DOWN)
			beats_down = beat
			break
	TEST_ASSERT(fought, "Wrestling a standing target puts the goblin in combat mode.")
	TEST_ASSERT(beats_down, "A weak goblin brings the partner down within twenty beats; the roll grows with every miss.")
	goblin.stop_pulling()
	goblin.cmode = FALSE
	partner.SetKnockdown(0)
	sleep(1)

/// A target strapped into a structure is already caught: no hold is needed, and none would land.
/datum/unit_test/ai_horny_hunt/buckled_target_counts_as_caught

/datum/unit_test/ai_horny_hunt/buckled_target_counts_as_caught/Run()
	var/obj/structure/chair/chair = allocate(/obj/structure/chair)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	TEST_ASSERT(chair.buckle_mob(partner, TRUE, FALSE), "Test setup: the partner should be buckled to the chair.")
	TEST_ASSERT(partner.buckled, "Test setup: the partner is buckled.")
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	prepare_horny_grab_test_pair(goblin, partner)
	goblin.next_move = 0
	TEST_ASSERT_EQUAL(horny_seize_step(goblin, partner, goblin.ai_controller), HORNY_SEIZE_DONE, "A handed hunter counts a buckled target as caught.")

	var/mob/living/simple_animal/hostile/retaliate/wolf/wolf = allocate(/mob/living/simple_animal/hostile/retaliate/wolf)
	prepare_hunt_pair(wolf, partner, HORNY_MOB_TYPE_BEASTS)
	wolf.next_move = 0
	TEST_ASSERT_EQUAL(horny_handless_seize_step(wolf, partner, wolf.ai_controller, wolf.get_horny_family_profile()), HORNY_SEIZE_DONE, "A handless hunter counts a buckled target as caught.")
	chair.unbuckle_mob(partner, TRUE)

/// Humanoid barks start with a capital letter.
/datum/unit_test/ai_horny_hunt/barks_are_capitalised

/datum/unit_test/ai_horny_hunt/barks_are_capitalised/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/horny_family_profile/profile = horny_profile_for_flag(HORNY_MOB_TYPE_HUMANOIDS)
	for(var/context in list(HORNY_BARK_NOTICE, HORNY_BARK_SEIZE, HORNY_BARK_BREAK_OFF, HORNY_BARK_PRESENT, HORNY_BARK_SATED, HORNY_BARK_LOST))
		for(var/i in 1 to 8)
			var/line = profile.get_bark(goblin, partner, context)
			TEST_ASSERT_NOTNULL(line, "Humanoids have a line for every bark context ([context]).")
			var/first = copytext(line, 1, 2)
			TEST_ASSERT_EQUAL(first, uppertext(first), "Barks start with a capital letter: [line]")

/// A second goblin never fights a packmate for the hold: while the first holds a standing target, the second hooks at the legs.
/datum/unit_test/ai_horny_hunt/packmate_hooks_the_legs_of_a_held_target

/datum/unit_test/ai_horny_hunt/packmate_hooks_the_legs_of_a_held_target/Run()
	var/mob/living/carbon/human/species/goblin/npc/first = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/species/goblin/npc/second = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(first, partner)
	prepare_horny_grab_test_pair(second, partner)
	// Live goblins get their faction a second after creation; the frozen test clock never gets there.
	first.set_faction(list(FACTION_ORCS))
	second.set_faction(list(FACTION_ORCS))
	TEST_ASSERT(first.kidnap_is_packmate(second), "Test setup: two goblins are packmates.")
	for(var/beat in 1 to 10)
		first.next_move = 0
		if(horny_take_grab(first, partner, first.ai_controller))
			break
	TEST_ASSERT_EQUAL(partner.pulledby, first, "Test setup: the first goblin holds the standing partner.")
	TEST_ASSERT(first.grab_state < GRAB_AGGRESSIVE, "Test setup: the hold is a loose one, the kind a stranger could pull loose.")
	TEST_ASSERT_EQUAL(partner.body_position, STANDING_UP, "Test setup: the partner is on their feet.")

	second.next_move = 0
	var/result = horny_seize_step(second, partner, second.ai_controller)
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_ACTED, "The second goblin acts on a standing target in a packmate's hold.")
	TEST_ASSERT_EQUAL(partner.pulledby, first, "The second goblin does not pull the partner out of a packmate's hold.")
	TEST_ASSERT(second.cmode, "Hooking at the legs is a fight.")
	TEST_ASSERT(partner.body_position == LYING_DOWN || horny_get_pressure(second.ai_controller) == 1, "The second goblin hooks at the legs: a hit floors the partner, a miss adds pressure.")

	// Floored and still in the first one's hold, the partner is caught for the second as well.
	partner.Knockdown(30 SECONDS)
	second.next_move = 0
	TEST_ASSERT_EQUAL(horny_seize_step(second, partner, second.ai_controller), HORNY_SEIZE_DONE, "A floored target in a packmate's hold counts as caught.")
	TEST_ASSERT(!second.cmode, "The catch over, the second goblin leaves combat mode.")
	first.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// Two hunters after the same target are partners in the catch even without a shared faction: the hold is not pulled loose.
/datum/unit_test/ai_horny_hunt/fellow_hunter_hold_is_not_pulled_loose

/datum/unit_test/ai_horny_hunt/fellow_hunter_hold_is_not_pulled_loose/Run()
	var/mob/living/carbon/human/species/goblin/npc/first = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/species/goblin/npc/second = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(first, partner)
	prepare_horny_grab_test_pair(second, partner)
	TEST_ASSERT(!first.kidnap_is_packmate(second), "Test setup: fresh goblins share no faction yet.")
	first.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, partner)
	for(var/beat in 1 to 10)
		first.next_move = 0
		if(horny_take_grab(first, partner, first.ai_controller))
			break
	TEST_ASSERT_EQUAL(partner.pulledby, first, "Test setup: the first hunter holds the standing partner loosely.")

	second.next_move = 0
	var/result = horny_seize_step(second, partner, second.ai_controller)
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_ACTED, "The second hunter acts on a standing target in a fellow hunter's hold.")
	TEST_ASSERT_EQUAL(partner.pulledby, first, "A fellow hunter's hold is not pulled loose.")
	first.ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	first.stop_pulling()
	second.cmode = FALSE
	partner.SetKnockdown(0)
	sleep(1)

/// A yielding target already in another hunter's hold is caught; the newcomer neither waits nor pulls them loose.
/datum/unit_test/ai_horny_hunt/yielding_target_in_another_hold_is_caught

/datum/unit_test/ai_horny_hunt/yielding_target_in_another_hold_is_caught/Run()
	var/mob/living/carbon/human/species/goblin/npc/first = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/species/goblin/npc/second = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/simple_animal/hostile/retaliate/wolf/wolf = allocate(/mob/living/simple_animal/hostile/retaliate/wolf)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(first, partner)
	prepare_horny_grab_test_pair(second, partner)
	prepare_hunt_pair(wolf, partner, HORNY_MOB_TYPE_BEASTS)
	partner.surrendering = TRUE
	partner.Knockdown(30 SECONDS)
	for(var/beat in 1 to 10)
		first.next_move = 0
		if(horny_take_grab(first, partner, first.ai_controller))
			break
	TEST_ASSERT_EQUAL(partner.pulledby, first, "Test setup: the first goblin holds the yielding partner.")
	TEST_ASSERT(first.grab_state < GRAB_AGGRESSIVE, "Test setup: a yielding target is held loosely.")

	second.next_move = 0
	TEST_ASSERT_EQUAL(horny_seize_step(second, partner, second.ai_controller), HORNY_SEIZE_DONE, "A yielding target in a packmate's hold is caught for a second goblin.")
	wolf.next_move = 0
	TEST_ASSERT_EQUAL(horny_handless_seize_step(wolf, partner, wolf.ai_controller, wolf.get_horny_family_profile()), HORNY_SEIZE_DONE, "A yielding target in another hold is caught for a handless hunter too.")
	TEST_ASSERT_EQUAL(partner.pulledby, first, "Nobody pulls the yielding partner loose.")
	first.stop_pulling()
	partner.surrendering = FALSE
	partner.SetKnockdown(0)
	sleep(1)

/// A coil that finds its target already in another's hold bears down instead of waiting for a wrap that cannot land.
/datum/unit_test/ai_horny_hunt/coil_bears_down_on_a_target_in_another_hold

/datum/unit_test/ai_horny_hunt/coil_bears_down_on_a_target_in_another_hold/Run()
	var/mob/living/simple_animal/hostile/retaliate/tentacle/first = allocate(/mob/living/simple_animal/hostile/retaliate/tentacle)
	var/mob/living/simple_animal/hostile/retaliate/tentacle/second = allocate(/mob/living/simple_animal/hostile/retaliate/tentacle)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_hunt_pair(first, partner, HORNY_MOB_TYPE_TENTACLES)
	prepare_hunt_pair(second, partner, HORNY_MOB_TYPE_TENTACLES)
	var/datum/horny_family_profile/profile = first.get_horny_family_profile()
	TEST_ASSERT(horny_handless_hold(first, partner, profile), "Test setup: the first tentacle coils round the standing partner.")
	TEST_ASSERT(first.grab_state >= GRAB_AGGRESSIVE, "Test setup: the coil is an aggressive hold.")

	second.next_move = 0
	var/result = horny_handless_seize_step(second, partner, second.ai_controller, profile)
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_ACTED, "The second tentacle acts on a standing target in another's coil.")
	TEST_ASSERT_EQUAL(partner.pulledby, first, "The second tentacle does not wrench the partner out of the first one's coil.")
	TEST_ASSERT(partner.body_position == LYING_DOWN || horny_get_pressure(second.ai_controller) == 1, "The second tentacle bears down: a hit floors the partner, a miss adds pressure.")
	first.stop_pulling()
	partner.SetKnockdown(0)
	sleep(1)

/// The pin lands once per catch; when its short stun runs out the hold keeps the target down and no second pin follows.
/datum/unit_test/ai_horny_hunt/pin_lands_once_per_catch

/datum/unit_test/ai_horny_hunt/pin_lands_once_per_catch/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	prepare_horny_grab_test_pair(goblin, partner)
	goblin.change_stat(STAT_STRENGTH, 10)
	var/datum/ai_controller/controller = goblin.ai_controller

	var/result = HORNY_SEIZE_WAIT
	for(var/beat in 1 to 40)
		goblin.next_move = 0
		result = horny_seize_step(goblin, partner, controller)
		if(result == HORNY_SEIZE_DONE)
			break
	TEST_ASSERT_EQUAL(result, HORNY_SEIZE_DONE, "Test setup: the ladder ends in a pin.")
	TEST_ASSERT(partner.IsStun(), "Test setup: the pin stuns the partner.")
	TEST_ASSERT(controller.blackboard[BB_HORNY_PINNED], "The catch remembers that its pin has landed.")

	// The engine's pin stun is a fraction of a second for a weak hunter; its end must not bring another pin.
	partner.SetStun(0)
	for(var/beat in 1 to 3)
		goblin.next_move = 0
		TEST_ASSERT_EQUAL(horny_seize_step(goblin, partner, controller), HORNY_SEIZE_DONE, "With the stun gone and the hold on, the catch stays done (beat [beat]).")
	TEST_ASSERT(!partner.IsStun(), "No second pin lands while the partner stays down.")
	TEST_ASSERT_EQUAL(partner.pulledby, goblin, "The hold is what keeps the partner down.")

	// Back on their feet, the memory of the pin goes, so the next catch pins again. Getting up is async; do it instantly here.
	goblin.stop_pulling()
	partner.SetKnockdown(0)
	partner.get_up(TRUE)
	TEST_ASSERT_EQUAL(partner.body_position, STANDING_UP, "Test setup: the partner is back on their feet.")
	goblin.next_move = 0
	horny_seize_step(goblin, partner, controller)
	TEST_ASSERT(!controller.blackboard[BB_HORNY_PINNED], "A beat against a standing target forgets the old pin.")
	goblin.stop_pulling()
	goblin.cmode = FALSE
	partner.SetStun(0)
	partner.SetKnockdown(0)
	sleep(1)

/// The grab line names the limb for onlookers and for the victim.
/datum/unit_test/ai_horny_hunt/grab_line_names_the_limb

/datum/unit_test/ai_horny_hunt/grab_line_names_the_limb/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/mob/living/carbon/human/partner = allocate(/mob/living/carbon/human)
	var/datum/horny_family_profile/profile = horny_profile_for_flag(HORNY_MOB_TYPE_HUMANOIDS)
	var/line = profile.get_grab_message(goblin, partner, "left arm")
	TEST_ASSERT(findtext(line, "left arm") && findtext(line, "[partner]"), "Onlookers read who was grabbed and where: [line]")
	var/own = profile.get_grab_message(goblin, partner, "mouth", TRUE)
	TEST_ASSERT(findtext(own, "mouth") && findtext(own, " me") && !findtext(own, "[partner]"), "The victim's own line is in the first person: [own]")

/// The brood takes the hunt's consent gates: family prefs, the refuse opt-out and the oviposition pref.
/datum/unit_test/ai_horny_hunt/spider_brood_respects_consent

/datum/unit_test/ai_horny_hunt/spider_brood_respects_consent/Run()
	var/mob/living/simple_animal/hostile/retaliate/mirespider/spider = allocate(/mob/living/simple_animal/hostile/retaliate/mirespider)
	spider.gender = MALE
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/structure/spider/cocoon/cocoon = allocate(/obj/structure/spider/cocoon)
	cocoon.wrap(victim)
	TEST_ASSERT_EQUAL(victim.loc, cocoon, "Test setup: the victim is inside the cocoon.")

	victim.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_SPIDERS,
		/datum/erp_preference/boolean/allow_mob_oviposition = TRUE,
	))
	TEST_ASSERT(spider_can_brood(spider, cocoon), "A consenting victim in an open cocoon can be brooded.")

	victim.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_HUMANOIDS,
		/datum/erp_preference/boolean/allow_mob_oviposition = TRUE,
	))
	TEST_ASSERT(!spider_can_brood(spider, cocoon), "A victim whose family prefs exclude spiders cannot be brooded.")

	victim.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = NONE,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_SPIDERS,
		/datum/erp_preference/boolean/allow_mob_oviposition = TRUE,
	))
	TEST_ASSERT(!spider_can_brood(spider, cocoon), "A victim with horny mobs off entirely cannot be brooded.")

	victim.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_SPIDERS,
		/datum/erp_preference/boolean/allow_mob_oviposition = FALSE,
	))
	TEST_ASSERT(!spider_can_brood(spider, cocoon), "The oviposition pref still gates the brood.")

	victim.set_cached_erp_preferences(list(
		/datum/erp_preference/bitflag/horny_mobs = HORNY_MOBS_TAG_MALES,
		/datum/erp_preference/bitflag/horny_mob_types = HORNY_MOB_TYPE_SPIDERS,
		/datum/erp_preference/boolean/allow_mob_oviposition = TRUE,
	))
	ADD_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES, KIDNAP_TRAIT)
	TEST_ASSERT(!spider_can_brood(spider, cocoon), "A victim who refused advances cannot be brooded.")
	REMOVE_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES, KIDNAP_TRAIT)
	TEST_ASSERT(spider_can_brood(spider, cocoon), "Lifting the refusal lets the brood again.")

/// An NPC captive has no prefs to consult; the brood is unchanged for them.
/datum/unit_test/ai_horny_hunt/spider_brood_allows_prefless_victims

/datum/unit_test/ai_horny_hunt/spider_brood_allows_prefless_victims/Run()
	var/mob/living/simple_animal/hostile/retaliate/mirespider/spider = allocate(/mob/living/simple_animal/hostile/retaliate/mirespider)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/structure/spider/cocoon/cocoon = allocate(/obj/structure/spider/cocoon)
	cocoon.wrap(victim)
	TEST_ASSERT(!victim.cached_erp_preferences, "Test setup: the victim has no cached prefs.")
	TEST_ASSERT(spider_can_brood(spider, cocoon), "A prefless NPC captive can be brooded, as before.")
