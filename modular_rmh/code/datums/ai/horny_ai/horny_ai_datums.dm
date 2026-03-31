/datum/ai_behavior/horny
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	var/seek_timeout = 1.5 MINUTES
	var/failed_seek_cooldown = 10 SECONDS
	var/successful_seek_cooldown = 15 SECONDS

/datum/ai_behavior/horny/simple_mob
	// Simple mobs currently only use the shared horny flow as-is.

/datum/ai_behavior/horny/human
	// Human-type mobs add prep work before the shared action flow.


/datum/ai_behavior/horny/setup(datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	if(isnull(targetting_datum))
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/target = controller.blackboard[target_key]

	var/mob/living/target_living = target
	var/mob/living/basic_mob = controller.pawn

	if(!basic_mob.GetComponent(/datum/component/arousal)) // give arousal datum if none
		basic_mob.AddComponent(/datum/component/arousal)

	if((basic_mob.gender == MALE && !basic_mob.getorganslot(ORGAN_SLOT_PENIS)) || (basic_mob.gender == FEMALE && !basic_mob.getorganslot(ORGAN_SLOT_VAGINA)))
		basic_mob.give_genitals()

	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN]) // if on cooldown - stop
		return FALSE

	if(!targetting_datum.can_horny(basic_mob, target_living))
		return FALSE

	controller.set_blackboard_key(BB_HORNY_TIME_START, world.time)
	controller.set_blackboard_key(BB_HORNY_TARGET_ATTACK_COUNT, 0)
	controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)
	controller.clear_blackboard_key(BB_HORNY_INITIAL_STRIP_DONE)
	controller.clear_blackboard_key(BB_HORNY_SEEK_START_TIME)
	controller.set_blackboard_key(BB_HORNY_STAND_UP_COUNTER, 0)
	controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
	controller.set_blackboard_key(BB_HORNY_WRONG_ACTION, FALSE)
	controller.set_blackboard_key(BB_HORNY_KNOCKDOWN_NEED, TRUE)

	if(basic_mob.gender == MALE)
		basic_mob.visible_message(span_boldwarning("[basic_mob] has his eyes on [target_living], cock throbbing!"))
	else
		basic_mob.visible_message(span_boldwarning("[basic_mob] has her eyes on [target_living], cunt dripping!"))

	SEND_SIGNAL(basic_mob, COMSIG_SET_ERECT_STATE, 4)

	var/obj/item/organ/genitals/picked_organ
	if(basic_mob.getorganslot(ORGAN_SLOT_PENIS))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_PENIS)
	else if(basic_mob.getorganslot(ORGAN_SLOT_VAGINA))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_VAGINA)
	if(picked_organ)
		picked_organ.toggle_visibility("Show Above clothes")

	basic_mob.start_sex_session(target_living)
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

	RegisterSignal(basic_mob, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

	controller.set_blackboard_key(BB_HORNY_STUN_COOLDOWN, world.time)
	SEND_SIGNAL(controller.pawn, COMSIG_HORNY_TARGET_SET, TRUE)

/datum/ai_behavior/horny/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key)
	. = ..()

	if(world.time < controller.blackboard[BB_HORNY_SEEK_COOLDOWN]) // if on cooldown - stop
		controller.CancelActions()
		controller.modify_cooldown(src, world.time)
		return FALSE

	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum)
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	var/mob/living/basic_mob = controller.pawn

	if(should_interrupt_for_aggro(controller, targetting_datum, current_target))
		stop_active_horny_actions(basic_mob)
		finish_action(controller, FALSE, target_key)
		return

	if(basic_mob.stat > SOFT_CRIT)
		return

	if(!targetting_datum.can_horny(basic_mob, current_target))
		finish_action(controller, FALSE, target_key)
		return

	if(ismob(current_target))
		if(current_target:stat == DEAD)
			finish_action(controller, FALSE, target_key)
			return

	var/mob/living/target_living = current_target
	var/seek_start_time = controller.blackboard[BB_HORNY_SEEK_START_TIME]
	var/stand_up_counter = controller.blackboard[BB_HORNY_STAND_UP_COUNTER]
	if(isnull(stand_up_counter))
		stand_up_counter = 0

	var/knockdown_need = controller.blackboard[BB_HORNY_KNOCKDOWN_NEED]
	if(isnull(knockdown_need))
		knockdown_need = TRUE

	if(!basic_mob.Adjacent(target_living))
		controller.set_blackboard_key(BB_HORNY_KNOCKDOWN_NEED, TRUE)
		if(isnull(seek_start_time))
			controller.set_blackboard_key(BB_HORNY_SEEK_START_TIME, world.time)
		else if(world.time >= seek_start_time + seek_timeout)
			controller.clear_blackboard_key(BB_HORNY_SEEK_START_TIME)
			finish_action(controller, FALSE, target_key)
			return
		return
	else
		controller.clear_blackboard_key(BB_HORNY_SEEK_START_TIME)

	if(target_living.body_position != LYING_DOWN)
		controller.set_blackboard_key(BB_HORNY_KNOCKDOWN_NEED, TRUE)
		knockdown_need = TRUE
	else
		controller.set_blackboard_key(BB_HORNY_KNOCKDOWN_NEED, FALSE)
		knockdown_need = FALSE

	var/list/arousal_data = list()
	SEND_SIGNAL(basic_mob, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/last_orgasm_time = arousal_data["last_ejaculation_time"]
	var/horny_start_time = controller.blackboard[BB_HORNY_TIME_START]
	if(isnull(horny_start_time))
		horny_start_time = world.time
		controller.set_blackboard_key(BB_HORNY_TIME_START, horny_start_time)

	var/datum/sex_session/session = get_sex_session(basic_mob, target_living)
	if(!session) //if we took too long and it's deleted
		session = basic_mob.start_sex_session(target_living)

	//check if we are sated
	if(last_orgasm_time > world.time - 10 SECONDS || horny_start_time < world.time - 5 MINUTES)
		if(session)
			session.stop_current_action()
		finish_action(controller, TRUE, target_key)
		return

	if(basic_mob.body_position == LYING_DOWN) //try to stand before doing anything
		if(!basic_mob.stand_up())
			stand_up_counter += 1
			controller.set_blackboard_key(BB_HORNY_STAND_UP_COUNTER, stand_up_counter)
			if(stand_up_counter >= 5)
				finish_action(controller, FALSE, target_key)
			return
		controller.set_blackboard_key(BB_HORNY_STAND_UP_COUNTER, 0)
		return

	if(try_pre_knockdown_disarm(controller, basic_mob, target_living))
		controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
		return

	if(world.time > controller.blackboard[BB_HORNY_STUN_COOLDOWN] && knockdown_need)
		if(attempt_stamina_knockdown(controller, basic_mob, target_living))
			controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
			return

	if(handle_target_prep(controller, basic_mob, target_living, session))
		controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
		return

	start_horny_action(controller, basic_mob, target_living, session, target_key)

/datum/ai_behavior/horny/proc/stop_active_horny_actions(mob/living/basic_mob)
	if(!basic_mob)
		return

	for(var/datum/sex_session/session as anything in return_sessions_with_user(basic_mob))
		if(session.user != basic_mob)
			continue
		session.stop_current_action()

/datum/ai_behavior/horny/proc/is_valid_aggro_interrupt_target(mob/living/basic_mob, datum/targetting_datum/targetting_datum, atom/target)
	if(!target || target == basic_mob || QDELETED(target))
		return FALSE

	// Human NPCs can consider prone, armed victims "disarm targets"; that should not
	// override horny retargeting while this same mob is still a valid horny partner.
	if(targetting_datum.can_horny(basic_mob, target))
		return FALSE

	if(!targetting_datum.can_attack(basic_mob, target) && !targetting_datum.should_disarm(basic_mob, target))
		return FALSE

	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return FALSE
		if(living_target.rogue_sneaking)
			var/extra_chance = (basic_mob.health <= basic_mob.maxHealth * 0.5) ? 30 : 0
			if(!basic_mob.npc_detect_sneak(living_target, extra_chance))
				return FALSE

	return TRUE

/datum/ai_behavior/horny/proc/should_interrupt_for_aggro(datum/ai_controller/controller, datum/targetting_datum/targetting_datum, atom/current_horny_target)
	var/mob/living/basic_mob = controller?.pawn
	if(!basic_mob || !targetting_datum)
		return FALSE

	if(current_horny_target && targetting_datum.is_horny_target_now_hostile(basic_mob, current_horny_target))
		return TRUE

	var/atom/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(current_target != current_horny_target && is_valid_aggro_interrupt_target(basic_mob, targetting_datum, current_target))
		return TRUE

	var/atom/highest_threat = controller.blackboard[BB_HIGHEST_THREAT_MOB]
	if(highest_threat != current_horny_target && is_valid_aggro_interrupt_target(basic_mob, targetting_datum, highest_threat))
		return TRUE

	return FALSE

/datum/ai_behavior/horny/proc/handle_target_prep(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_session/session)
	// Override this in mob-specific subclasses when they need setup work before the sex action starts.
	return FALSE

/datum/ai_behavior/horny/proc/try_pre_knockdown_disarm(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	return FALSE

/datum/ai_behavior/horny/proc/get_horny_disarm_intent()
	var/static/datum/intent/unarmed/shove/disarm_intent = new()
	return disarm_intent

/datum/ai_behavior/horny/proc/attempt_stamina_knockdown(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(!basic_mob.Adjacent(target_living))
		controller.set_blackboard_key(BB_HORNY_KNOCKDOWN_NEED, TRUE)
		return FALSE
	if(target_living.body_position == LYING_DOWN)
		controller.set_blackboard_key(BB_HORNY_KNOCKDOWN_NEED, FALSE)
		return FALSE

	var/prob2defend
	var/obj/item/mainhand = target_living.get_active_held_item()
	var/obj/item/offhand = target_living.get_inactive_held_item()
	var/list/parry_data = target_living.calculate_parry_values(mainhand, offhand)
	prob2defend += CLAMP(parry_data["defense_bonus"] / 80, 0, 40)
	prob2defend += CLAMP(target_living.STASPD / 20 * 50, 0, 50)
	if(target_living.cmode)
		prob2defend *= 1.2
	if(target_living.surrendering)
		prob2defend *= 0.1
	prob2defend = CLAMP(prob2defend, 0, 85)

	var/base_stamina_drain = iscarbon(basic_mob) ? target_living.maximum_stamina * 0.20 : target_living.maximum_stamina * 0.28
	var/stamina_drain = max(round(base_stamina_drain * (1 - (prob2defend / 125))), 5)
	target_living.adjust_stamina(stamina_drain, null, FALSE, FALSE)

	// Once only 20% stamina remains, the takedown becomes guaranteed
	var/stamina_exhaustion = target_living.maximum_stamina ? (target_living.stamina / target_living.maximum_stamina) : 0
	var/down_chance = CLAMP(round((stamina_exhaustion / 0.8) * 100), 0, 100)

	if(prob(down_chance))
		if(iscarbon(basic_mob))
			target_living.SetStun(30)
			target_living.SetKnockdown(50)
		else
			target_living.SetStun(80)
			target_living.SetKnockdown(200)
		if(target_living.body_position != LYING_DOWN)
			target_living.emote("gasp")
		controller.set_blackboard_key(BB_HORNY_STUN_COOLDOWN, world.time + 10 SECONDS)
		basic_mob.visible_message(span_danger("[basic_mob] batters [target_living]'s guard down and drags them to the ground!"))
	else
		controller.set_blackboard_key(BB_HORNY_STUN_COOLDOWN, world.time + 5 SECONDS)
		basic_mob.visible_message(span_danger("[basic_mob] tries to pull [target_living] to the ground, exhausting them!"))

	return TRUE

/datum/ai_behavior/horny/proc/start_horny_action(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_session/session, target_key)
	if(!session)
		return

	var/action_type = select_horny_ai_act(basic_mob, target_living, session)
	if(isnull(action_type))
		var/actionless_ticks = controller.blackboard[BB_HORNY_ACTIONLESS_TICKS]
		if(isnull(actionless_ticks))
			actionless_ticks = 0
		actionless_ticks += 1
		controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, actionless_ticks)
		if(actionless_ticks >= 6)
			finish_action(controller, FALSE, target_key)
		return

	controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, 0)
	if(isnull(session.current_action))
		session.try_start_action(action_type)
		basic_mob.face_atom(target_living)
		var/force = rand(SEX_FORCE_MID, SEX_FORCE_MAX)
		var/speed = rand(SEX_SPEED_MID, SEX_SPEED_MAX)
		session.set_current_force(force)
		session.set_current_speed(speed)
		target_living.apply_status_effect(/datum/status_effect/debuff/mob_fucked)
		if(isnull(session.current_action))
			var/actionless_ticks = controller.blackboard[BB_HORNY_ACTIONLESS_TICKS]
			if(isnull(actionless_ticks))
				actionless_ticks = 0
			actionless_ticks += 1
			controller.set_blackboard_key(BB_HORNY_ACTIONLESS_TICKS, actionless_ticks)
			if(actionless_ticks >= 3)
				controller.set_blackboard_key(BB_HORNY_WRONG_ACTION, TRUE)
				finish_action(controller, FALSE, target_key)

/datum/ai_behavior/horny/proc/select_horny_ai_act(mob/living/basic_mob, mob/living/target_living, datum/sex_session/session)
	var/list/weighted_actions = list()
	var/has_penis = !!basic_mob.getorganslot(ORGAN_SLOT_PENIS)
	var/has_vagina = !!basic_mob.getorganslot(ORGAN_SLOT_VAGINA)
	var/target_has_penis = !!target_living.getorganslot(ORGAN_SLOT_PENIS)
	var/target_has_vagina = !!target_living.getorganslot(ORGAN_SLOT_VAGINA)

	if(has_penis)
		weighted_actions += /datum/sex_action/npc/npc_throat_sex
		weighted_actions += /datum/sex_action/npc/npc_throat_sex
		weighted_actions += /datum/sex_action/npc/npc_anal_sex
		if(target_has_vagina)
			weighted_actions += /datum/sex_action/npc/npc_vaginal_sex
			weighted_actions += /datum/sex_action/npc/npc_vaginal_sex
			weighted_actions += /datum/sex_action/npc/npc_vaginal_sex

	if(has_vagina)
		weighted_actions += /datum/sex_action/npc/npc_facesitting
		weighted_actions += /datum/sex_action/npc/npc_facesitting
		if(target_has_penis)
			weighted_actions += /datum/sex_action/npc/npc_vaginal_ride_sex
			weighted_actions += /datum/sex_action/npc/npc_vaginal_ride_sex
			weighted_actions += /datum/sex_action/npc/npc_vaginal_ride_sex
			weighted_actions += /datum/sex_action/npc/npc_anal_ride_sex

	if(!length(weighted_actions))
		return null

	var/list/valid_actions = list()
	for(var/datum/sex_action/action_type as anything in weighted_actions)
		if(session.can_perform_action(action_type))
			valid_actions += action_type

	if(!length(valid_actions))
		return null

	return pick(valid_actions)

/datum/ai_behavior/horny/simple_mob/handle_target_prep(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_session/session)
	if(!ishuman(target_living) || !basic_mob.Adjacent(target_living))
		return FALSE

	if(session.current_action)
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	if(!controller.blackboard[BB_HORNY_INITIAL_STRIP_DONE])
		controller.set_blackboard_key(BB_HORNY_INITIAL_STRIP_DONE, TRUE)
		if(pick_strip_target(basic_mob, human_target, allow_regular_clothes = TRUE))
			return strip_human_target(basic_mob, human_target)

	var/has_valid_action = !isnull(select_horny_ai_act(basic_mob, target_living, session))
	if(has_valid_action && !prob(35))
		return FALSE

	return strip_human_target(basic_mob, human_target)

/datum/ai_behavior/horny/simple_mob/try_pre_knockdown_disarm(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(!ishuman(target_living) || !basic_mob.Adjacent(target_living))
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	return disarm_human_target(basic_mob, human_target)

/datum/ai_behavior/horny/simple_mob/disarm_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	if(!human_target.Adjacent(basic_mob))
		return FALSE
	if(!human_target.get_active_held_item() && !human_target.get_inactive_held_item())
		return FALSE
	var/datum/intent/disarm_intent = get_horny_disarm_intent()
	var/datum/intent/cached_intent = basic_mob.used_intent
	basic_mob.used_intent = disarm_intent
	if(human_target.checkdefense(disarm_intent, basic_mob))
		basic_mob.used_intent = cached_intent
		return TRUE
	basic_mob.used_intent = cached_intent
	if(!prob(50))
		human_target.visible_message(span_danger("[basic_mob] swats at [human_target]'s hands, but fails to disarm them!"), \
				span_userdanger("[basic_mob] swats at my hands, but I keep hold of my weapon!"), span_hear("I hear a rough struggle over a weapon!"), COMBAT_MESSAGE_RANGE)
		return TRUE

	for(var/obj/item/I in human_target.held_items)
		human_target.dropItemToGround(I, force = FALSE, silent = FALSE)
	human_target.Stun(5)
	human_target.visible_message(span_danger("[basic_mob] bats at [human_target]'s hands and disarms them!"), \
			span_userdanger("[basic_mob] bats at my hands and disarms me!"), span_hear("I hear someone getting disarmed!"), COMBAT_MESSAGE_RANGE)
	return TRUE

/datum/ai_behavior/horny/proc/disarm_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	return FALSE

/datum/ai_behavior/horny/proc/add_strip_choice(list/choices, mob/living/basic_mob, mob/living/carbon/human/human_target, obj/item/item, weight)
	if(!item || weight <= 0)
		return
	if(item.loc != human_target || !item.canStrip(basic_mob, human_target))
		return
	var/current_weight = choices[item]
	if(isnull(current_weight))
		current_weight = 0
	choices[item] = max(current_weight, weight)

/datum/ai_behavior/horny/proc/pick_strip_target(mob/living/basic_mob, mob/living/carbon/human/human_target, include_mouth_cover = TRUE, allow_regular_clothes = FALSE)
	var/list/weighted_blockers = list()
	var/list/weighted_regular_clothes = list()

	var/list/groin_priority = list(
		human_target.wear_pants = 12,
		human_target.underwear = 10,
		human_target.wear_armor = 6,
		human_target.cloak = 4,
		human_target.wear_shirt = 2,
		human_target.undershirt = 2,
		human_target.wear_mask = 1,
		human_target.head = 1,
		human_target.gloves = 1,
	)

	for(var/obj/item/item as anything in groin_priority)
		var/weight = groin_priority[item]
		if(!item || item.loc != human_target || !item.canStrip(basic_mob, human_target))
			continue

		if(istype(item, /obj/item/clothing))
			var/obj/item/clothing/clothing_item = item
			if(clothing_item.armor_class > AC_LIGHT && zone2covered(BODY_ZONE_PRECISE_GROIN, clothing_item.body_parts_covered))
				add_strip_choice(weighted_blockers, basic_mob, human_target, clothing_item, weight)
				continue
			if((clothing_item.flags_inv & HIDECROTCH) && !clothing_item.genital_access)
				add_strip_choice(weighted_blockers, basic_mob, human_target, clothing_item, weight)
				continue

		if(allow_regular_clothes)
			add_strip_choice(weighted_regular_clothes, basic_mob, human_target, item, weight)

	if(include_mouth_cover)
		var/obj/item/mouth_cover = human_target.is_mouth_covered()
		if(istype(mouth_cover) && mouth_cover.loc == human_target && mouth_cover.canStrip(basic_mob, human_target))
			add_strip_choice(weighted_blockers, basic_mob, human_target, mouth_cover, 3)

	if(length(weighted_blockers))
		return pickweight(weighted_blockers)
	if(allow_regular_clothes && length(weighted_regular_clothes))
		return pickweight(weighted_regular_clothes)
	return null

/datum/ai_behavior/horny/proc/do_strip_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target, strip_delay, damage_chance = 0, damage_ratio = 0, include_mouth_cover = TRUE, allow_regular_clothes = FALSE)
	var/obj/item/stripped_item = pick_strip_target(basic_mob, human_target, include_mouth_cover, allow_regular_clothes)
	if(!stripped_item)
		return FALSE

	if(human_target == basic_mob)
		basic_mob.visible_message(span_danger("[basic_mob] starts hurriedly pulling off [basic_mob.p_their()] [stripped_item]!"))
	else
		basic_mob.visible_message(span_danger("[basic_mob] starts tugging at [human_target]'s [stripped_item]!"))

	if(!do_after(basic_mob, strip_delay, human_target, interaction_key = "horny_strip"))
		return TRUE
	if(QDELETED(stripped_item) || stripped_item.loc != human_target)
		return TRUE
	if(!human_target.dropItemToGround(stripped_item, force = FALSE, silent = FALSE))
		return TRUE

	if(damage_chance && prob(damage_chance) && !istype(stripped_item, /obj/item/storage) && !istype(stripped_item, /obj/item/clothing/ring))
		stripped_item.take_damage(damage_amount = stripped_item.max_integrity * damage_ratio, sound_effect = FALSE)

	if(human_target == basic_mob)
		basic_mob.visible_message(span_danger("[basic_mob] tears off [basic_mob.p_their()] [stripped_item]!"))
	else
		basic_mob.visible_message(span_danger("[basic_mob] tears [human_target]'s [stripped_item] loose!"))
		var/turf/landing_spot = pick(orange(2, get_turf(human_target)))
		if(landing_spot)
			stripped_item.throw_at(landing_spot, 2, 1, basic_mob, TRUE)
	return TRUE

/datum/ai_behavior/horny/simple_mob/proc/strip_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	return do_strip_human_target(basic_mob, human_target, rand(12, 20) DECISECONDS, 35, 0.15, allow_regular_clothes = TRUE)

/datum/ai_behavior/horny/human/handle_target_prep(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living, datum/sex_session/session)
	if(!iscarbon(basic_mob))
		return FALSE

	var/mob/living/carbon/carbon_mob = basic_mob
	ensure_target_grab(carbon_mob, target_living)
	if(session.current_action)
		return FALSE

	var/has_valid_action = !isnull(select_horny_ai_act(basic_mob, target_living, session))
	if(!has_valid_action && ishuman(basic_mob))
		var/mob/living/carbon/human/human_basic_mob = basic_mob
		if(pick_strip_target(basic_mob, human_basic_mob, FALSE))
			return do_strip_human_target(basic_mob, human_basic_mob, 8 DECISECONDS, include_mouth_cover = FALSE)

	if(!ishuman(target_living))
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	if(!controller.blackboard[BB_HORNY_INITIAL_STRIP_DONE])
		controller.set_blackboard_key(BB_HORNY_INITIAL_STRIP_DONE, TRUE)
		if(pick_strip_target(basic_mob, human_target, allow_regular_clothes = TRUE))
			return strip_human_target(basic_mob, human_target)

	if((!has_valid_action || prob(20)) && strip_human_target(basic_mob, human_target))
		return TRUE

	if(tie_human_target(carbon_mob, human_target))
		return TRUE

	return FALSE

/datum/ai_behavior/horny/human/try_pre_knockdown_disarm(datum/ai_controller/controller, mob/living/basic_mob, mob/living/target_living)
	if(!ishuman(target_living))
		return FALSE

	var/mob/living/carbon/human/human_target = target_living
	return disarm_human_target(basic_mob, human_target)

/datum/ai_behavior/horny/human/proc/ensure_target_grab(mob/living/carbon/carbon_mob, mob/living/target_living)
	if(carbon_mob.pulling)
		return

	carbon_mob.drop_all_held_items()
	var/sel_zone
	if(prob(30)) // chance to gag
		sel_zone = BODY_ZONE_PRECISE_MOUTH
	else
		sel_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_NECK, BODY_ZONE_PRECISE_GROIN)

	if(!length(target_living.grabbedby))
		target_living.grabbedby(carbon_mob, FALSE, sel_zone)

/datum/ai_behavior/horny/human/disarm_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	if(!human_target.Adjacent(basic_mob))
		return FALSE
	if(!human_target.get_active_held_item() && !human_target.get_inactive_held_item())
		return FALSE
	var/datum/intent/disarm_intent = get_horny_disarm_intent()
	var/datum/intent/cached_intent = basic_mob.used_intent
	basic_mob.used_intent = disarm_intent
	if(human_target.checkdefense(disarm_intent, basic_mob))
		basic_mob.used_intent = cached_intent
		return TRUE
	basic_mob.used_intent = cached_intent
	if(!prob(50))
		human_target.visible_message(span_danger("[basic_mob] lunges for [human_target]'s weapon, but can't wrench it free!"), \
				span_userdanger("[basic_mob] lunges for my weapon, but I keep hold of it!"), span_hear("I hear a struggle over a weapon!"), COMBAT_MESSAGE_RANGE)
		return TRUE

	for(var/obj/item/I in human_target.held_items)
		human_target.dropItemToGround(I, force = FALSE, silent = FALSE)
	human_target.Stun(5)
	human_target.visible_message(span_danger("[basic_mob] disarms [human_target]!"), \
			span_userdanger("[basic_mob] disarms me!"), span_hear("I hear someone getting punished!"), COMBAT_MESSAGE_RANGE)
	return TRUE

/datum/ai_behavior/horny/human/proc/strip_human_target(mob/living/basic_mob, mob/living/carbon/human/human_target)
	return do_strip_human_target(basic_mob, human_target, 1 SECONDS, 20, 0.2, allow_regular_clothes = TRUE)

/datum/ai_behavior/horny/human/proc/tie_human_target(mob/living/carbon/carbon_mob, mob/living/carbon/human/human_target)
	if(human_target.body_position != LYING_DOWN || human_target.get_active_held_item())
		return FALSE
	if(!carbon_mob.Adjacent(human_target) || human_target.get_num_arms(TRUE) <= 1 || human_target.handcuffed)
		return FALSE

	carbon_mob.visible_message(span_danger("[carbon_mob] begins to tie up [human_target]'s hands!"))
	if(!do_after(carbon_mob, 1 SECONDS, human_target))
		return FALSE

	var/obj/item/rope/rope_item = new /obj/item/rope
	if(rope_item.apply_cuffs(human_target, carbon_mob))
		return TRUE

	qdel(rope_item)
	return FALSE

/datum/ai_behavior/horny/proc/on_attacked(mob/living/source, atom/attacker, damage)
	SIGNAL_HANDLER
	if(!source?.ai_controller || !attacker)
		return
	if(attacker == source || QDELETED(attacker) || isturf(attacker))
		return
	if(ismob(attacker))
		var/mob/M = attacker
		if(M.status_flags & GODMODE || M.stat == DEAD)
			return
	if(source.see_invisible < attacker.invisibility)
		return

	var/datum/ai_controller/controller = source.ai_controller
	var/atom/current_horny_target = controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET]
	var/datum/targetting_datum/targetting_datum = controller.blackboard[BB_TARGETTING_DATUM]

	if(attacker == current_horny_target)
		var/hit_count = controller.blackboard[BB_HORNY_TARGET_ATTACK_COUNT]
		if(isnull(hit_count))
			hit_count = 0
		hit_count += 1
		controller.set_blackboard_key(BB_HORNY_TARGET_ATTACK_COUNT, hit_count)

		var/health_below_breakpoint = source.maxHealth && source.health <= source.maxHealth * 0.75
		if(hit_count < 4 && !(hit_count >= 2 && health_below_breakpoint))
			return

	controller.set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker, world.time)
	targetting_datum?.set_horny_target_hostile(source, attacker)

	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, attacker)

	var/atom/potential_hiding_location = targetting_datum?.find_hidden_mobs(source, attacker)
	if(potential_hiding_location)
		controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, potential_hiding_location)
	else
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

	stop_active_horny_actions(source)
	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	controller.CancelActions()



/datum/ai_behavior/horny/proc/clear_completed_target_hostility(datum/ai_controller/controller, atom/finished_target)
	if(!controller || !finished_target)
		return

	// A partner who just completed an encounter with us should not stay stuck in the
	// retaliation/aggro memory and block horny retargeting after the seek cooldown ends.
	var/mob/living/basic_mob = controller.pawn
	var/datum/targetting_datum/targetting_datum = controller.blackboard[BB_TARGETTING_DATUM]
	if(targetting_datum && basic_mob)
		targetting_datum.clear_horny_target_hostility(basic_mob, finished_target)
	else
		var/list/hostile_targets = controller.blackboard[BB_HORNY_HOSTILE_TARGETS]
		if(hostile_targets && !isnull(hostile_targets[finished_target]))
			controller.remove_thing_from_blackboard_key(BB_HORNY_HOSTILE_TARGETS, finished_target)
		if(controller.blackboard[BB_HORNY_AGGRO_TARGET] == finished_target)
			controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)

	var/list/retaliate_list = controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if(retaliate_list && !isnull(retaliate_list[finished_target]))
		controller.remove_thing_from_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST, finished_target)

	var/list/aggro_table = controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(aggro_table && !isnull(aggro_table[finished_target]))
		aggro_table -= finished_target

	if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] == finished_target)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

	if(controller.blackboard[BB_HIGHEST_THREAT_MOB] == finished_target)
		controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)

/datum/ai_behavior/horny/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic_mob = controller.pawn
	var/atom/finished_target = controller.blackboard[target_key]

	stop_active_horny_actions(basic_mob)

	UnregisterSignal(basic_mob, COMSIG_ATOM_WAS_ATTACKED)

	SEND_SIGNAL(basic_mob, COMSIG_SET_ERECT_STATE, 0)


	var/obj/item/organ/genitals/picked_organ
	if(basic_mob.getorganslot(ORGAN_SLOT_PENIS))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_PENIS)
		picked_organ.toggle_visibility(FALSE)
	if(basic_mob.getorganslot(ORGAN_SLOT_VAGINA))
		picked_organ = basic_mob.getorganslot(ORGAN_SLOT_VAGINA)
		picked_organ.toggle_visibility(FALSE)


	basic_mob.stop_pulling()
	controller.clear_blackboard_key(BB_HORNY_TARGET_ATTACK_COUNT)
	controller.clear_blackboard_key(BB_HORNY_INITIAL_STRIP_DONE)
	controller.clear_blackboard_key(BB_HORNY_SEEK_START_TIME)
	controller.clear_blackboard_key(BB_HORNY_STAND_UP_COUNTER)
	controller.clear_blackboard_key(BB_HORNY_ACTIONLESS_TICKS)
	controller.clear_blackboard_key(BB_HORNY_WRONG_ACTION)
	controller.clear_blackboard_key(BB_HORNY_KNOCKDOWN_NEED)
	controller.clear_blackboard_key(BB_HORNY_AGGRO_TARGET)
	controller.clear_blackboard_key(BB_HORNY_STUN_COOLDOWN)
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(BB_HORNY_TIME_START)
	if(basic_mob.is_dead())
		return
	if(!succeeded)
		//if ran away - be angry
		controller.set_blackboard_key(BB_HORNY_SEEK_COOLDOWN, world.time + failed_seek_cooldown)
		basic_mob.visible_message(span_danger("[basic_mob] stomps on the ground, clearly unsatisfied!"))
		controller.modify_cooldown(src, world.time)
		//controller.CancelActions()
		return



	//if sated - go off and sleep or smth
	clear_completed_target_hostility(controller, finished_target)
	var/success_cooldown = successful_seek_cooldown
	var/datum/component/arousal/arousal_component = basic_mob.GetComponent(/datum/component/arousal)
	var/message = span_danger("[basic_mob] exhales contently!")
	if(arousal_component?.recent_orgasm_count >= 3)
		success_cooldown += 2 MINUTES
		message = span_danger("[basic_mob] lets out a releved sigh and releases [finished_target] for now.")
	controller.set_blackboard_key(BB_HORNY_SEEK_COOLDOWN, world.time + success_cooldown)
	basic_mob.visible_message(message)
	controller.modify_cooldown(src, world.time)
	//controller.CancelActions()

