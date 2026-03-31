#define RUNE_REBUILD_DELAY 5 SECONDS
#define RUNE_REVIVE_DELAY 1 SECONDS
#define RUNE_REVIVE_LOCKOUT 10 SECONDS
#define RUNE_HARD_CRIT_AUTO_DELAY 10 MINUTES
#define RUNE_REVIVAL_TITHE_MIN 20
#define RUNE_REVIVAL_TITHE_MAX 50
#define RUNE_WARDROBE_LOSS_CHANCE 100
#define RUNE_STAGE_NONE 0
#define RUNE_STAGE_SOFT_CRIT 1
#define RUNE_STAGE_HARD_CRIT 2
#define RUNE_STAGE_IMMEDIATE 3
#define RUNE_THRESHOLD_FULLCRIT 30
#define RUNE_THRESHOLD_SOFTCRIT 45

/proc/find_resurrection_rune_by_tag(rune_tag)
	if(!rune_tag || rune_tag == RUNE_LINK_NONE)
		return

	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		if(rune.rune_tag != rune_tag)
			continue
		return rune

/proc/find_resurrection_rune_destination_marker_by_tag(rune_tag)
	if(!rune_tag || rune_tag == RUNE_LINK_NONE)
		return

	var/list/tagged_markers = GLOB.global_resurrune_markers[rune_tag]
	if(!tagged_markers || !tagged_markers.len)
		return

	return pick(tagged_markers)

/proc/is_townhall_job(datum/job/assigned_role)
	if(!assigned_role)
		return FALSE

	if(assigned_role.title in GLOB.townhall_positions)
		return TRUE
	if(assigned_role.parent_job?.title in GLOB.townhall_positions)
		return TRUE
	return FALSE

/proc/should_redirect_outlaw_resurrection(mob/living/carbon/body, datum/mind/linked_mind)
	var/datum/mind/checked_mind = linked_mind
	if(body?.mind)
		checked_mind = body.mind

	if(!checked_mind)
		return FALSE
	if(checked_mind.has_antag_datum(/datum/antagonist/vampire))
		return FALSE
	if(is_townhall_job(checked_mind.assigned_role))
		return FALSE

	var/identity_name = body?.real_name
	if(!identity_name)
		identity_name = checked_mind.name
	if(!identity_name)
		return FALSE

	return identity_name in GLOB.outlawed_players

/proc/unlink_mind_from_other_resurrection_runes(datum/mind/linked_mind, obj/structure/resurrection_rune/current_rune)
	if(!linked_mind)
		return

	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		if(rune == current_rune)
			continue
		if(!rune.resrunecontroler)
			continue
		if(!(linked_mind in rune.resrunecontroler.linked_users_minds))
			continue
		rune.resrunecontroler.remove_linked_mind(linked_mind)


/datum/action/innate/resurrection_rune_call
	name = "Call the Rune"
	desc = "Answer the rune's call."
	button_icon_state = "shieldsparkles"
	var/datum/resurrection_rune_controller/rune_controller

/datum/action/innate/resurrection_rune_call/New(datum/resurrection_rune_controller/controller)
	rune_controller = controller
	. = ..(controller)

/datum/action/innate/resurrection_rune_call/Destroy()
	rune_controller = null
	return ..()

/datum/action/innate/resurrection_rune_call/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(!istype(owner, /mob/living/carbon))
		return FALSE
	if(!rune_controller)
		return FALSE

	var/mob/living/carbon/carbon_owner = owner
	var/rescue_stage = rune_controller.get_rescue_stage(carbon_owner)
	return rescue_stage == RUNE_STAGE_SOFT_CRIT || rescue_stage == RUNE_STAGE_HARD_CRIT

/datum/action/innate/resurrection_rune_call/Activate()
	. = ..()
	if(!istype(owner, /mob/living/carbon))
		return
	if(!rune_controller)
		return

	var/mob/living/carbon/carbon_owner = owner
	rune_controller.trigger_voluntary_revival(carbon_owner)


/datum/resurrection_rune_controller
	var/obj/structure/resurrection_rune/control/control_rune
	var/obj/structure/resurrection_rune/sub_rune
	var/list/linked_users = list()
	var/list/linked_users_by_name = list()
	var/list/linked_users_minds = list()
	var/list/linked_body_by_mind = list()
	var/list/resurrecting = list()
	var/list/rescue_actions = list()
	var/list/hard_crit_deadlines = list()
	// If the body is completely gone, rebuild this kind of shell at the rune.
	var/mob_type = /mob/living/carbon/human

/datum/resurrection_rune_controller/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/datum/resurrection_rune_controller/Destroy()
	STOP_PROCESSING(SSobj, src)

	for(var/mob/living/carbon/linked_user as anything in linked_users)
		clear_linked_user_rescue_state(linked_user)
		unregister_linked_user_signals(linked_user)

	control_rune = null
	sub_rune = null
	linked_users = null
	linked_users_by_name = null
	linked_users_minds = null
	linked_body_by_mind = null
	resurrecting = null
	rescue_actions = null
	hard_crit_deadlines = null
	return ..()

/datum/resurrection_rune_controller/process()
	if(!sub_rune)
		return
	if(!sub_rune.is_main && !sub_rune.main_rune_link)
		sub_rune.find_master()
		return
	if(resurrections_disabled())
		clear_all_linked_user_rescue_states()
		return
	if(!linked_users_minds.len)
		return

	// Linked souls that fully lost their body get remade at the rune after a short delay.
	for(var/datum/mind/linked_mind as anything in linked_users_minds)
		if(should_remove_linked_mind(linked_mind))
			remove_linked_mind(linked_mind)
			return
		prune_deleted_linked_body_state(linked_mind)
		if(linked_mind.current && !istype(linked_mind.current, /mob/living/brain))
			continue
		if(linked_mind in resurrecting)
			continue
		queue_body_remake(linked_mind)

	process_hard_crit_timeouts()

/datum/resurrection_rune_controller/proc/resurrections_disabled()
	if(!sub_rune)
		return TRUE
	return sub_rune.disabled_res

/datum/resurrection_rune_controller/proc/should_remove_linked_mind(datum/mind/linked_mind)
	if(!linked_mind)
		return FALSE

	var/mob/current_mob = linked_mind.current
	if(isnull(current_mob?.client))
		return FALSE
	return isnewplayer(current_mob.client.mob)

/datum/resurrection_rune_controller/proc/queue_body_remake(datum/mind/linked_mind)
	to_chat(linked_mind.get_ghost(TRUE, TRUE), span_blue("Somewhere, you are being remade anew..."))
	resurrecting |= linked_mind
	addtimer(CALLBACK(src, PROC_REF(spawn_new_body), linked_mind), RUNE_REBUILD_DELAY)

/datum/resurrection_rune_controller/proc/spawn_new_body(datum/mind/linked_mind)
	if(!sub_rune)
		resurrecting -= linked_mind
		return
	if(!(linked_mind in linked_users_minds))
		resurrecting -= linked_mind
		return
	if(linked_mind.current && !istype(linked_mind.current, /mob/living/brain))
		resurrecting -= linked_mind
		return

	var/turf/destination_turf = sub_rune.get_resurrection_destination(linked_mind = linked_mind)
	if(!destination_turf)
		resurrecting -= linked_mind
		return

	var/mob/living/carbon/new_body = new mob_type(destination_turf)
	var/mob/ghostie = linked_mind.get_ghost(TRUE)
	if(ghostie?.client?.prefs)
		ghostie.client.prefs.apply_prefs_to(new_body, TRUE)

	// Mind transfer expects the new body to briefly be the current body first.
	linked_mind.current = new_body
	linked_mind.transfer_to(new_body)
	linked_mind.grab_ghost(TRUE)
	new_body.flash_act()

	replace_linked_body(linked_mind, new_body)
	resurrecting -= linked_mind
	apply_revival_debuffs(new_body)
	apply_revival_side_effects(new_body, FALSE, null)
	playsound(destination_turf, 'sound/misc/vampirespell.ogg', 100, FALSE, -1)
	to_chat(new_body, span_blue("You are back."))
	apply_resurrection_trauma(new_body)

/datum/resurrection_rune_controller/proc/add_user(mob/living/carbon/user)
	if(!user)
		return FALSE
	if(!user.mind)
		return FALSE

	unlink_mind_from_other_resurrection_runes(user.mind, sub_rune)
	if(user in linked_users)
		return FALSE

	if(!(user.mind in linked_users_minds))
		linked_users_minds += user.mind
	replace_linked_body(user.mind, user)
	return TRUE

/datum/resurrection_rune_controller/proc/remove_user(mob/living/carbon/user)
	if(!user)
		return FALSE
	if(!(user in linked_users))
		return FALSE

	var/datum/mind/linked_mind = user.mind
	unregister_linked_body(user)

	if(linked_mind)
		linked_users_minds -= linked_mind
		linked_body_by_mind.Remove(linked_mind)
		resurrecting -= linked_mind

	return TRUE

/datum/resurrection_rune_controller/proc/register_linked_body(mob/living/carbon/user)
	if(!user)
		return
	if(!(user in linked_users))
		linked_users += user
		register_linked_user_signals(user)

	linked_users_by_name[user.name] = user
	set_rune_link_tag(user, sub_rune?.rune_tag)
	update_linked_user_rescue_state(user)

/datum/resurrection_rune_controller/proc/unregister_linked_body(mob/living/carbon/user)
	if(!user)
		return

	clear_linked_user_rescue_state(user)
	linked_users -= user
	linked_users_by_name.Remove(user.name)
	resurrecting -= user
	unregister_linked_user_signals(user)
	set_rune_link_tag(user, RUNE_LINK_NONE)

/datum/resurrection_rune_controller/proc/replace_linked_body(datum/mind/linked_mind, mob/living/carbon/new_body)
	if(!linked_mind || !new_body)
		return

	var/mob/living/carbon/old_body = linked_body_by_mind[linked_mind]
	if(old_body && old_body != new_body)
		unregister_linked_body(old_body)

	linked_body_by_mind[linked_mind] = new_body
	register_linked_body(new_body)

/datum/resurrection_rune_controller/proc/remove_linked_mind(datum/mind/linked_mind)
	if(!linked_mind)
		return

	var/mob/living/carbon/linked_body = linked_body_by_mind[linked_mind]
	if(linked_body)
		unregister_linked_body(linked_body)

	linked_users_minds -= linked_mind
	linked_body_by_mind.Remove(linked_mind)
	resurrecting -= linked_mind

/datum/resurrection_rune_controller/proc/register_linked_user_signals(mob/living/carbon/user)
	RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(handle_linked_user_update))
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(handle_linked_user_update))
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(handle_linked_user_deletion))

/datum/resurrection_rune_controller/proc/unregister_linked_user_signals(mob/living/carbon/user)
	UnregisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(handle_linked_user_update))
	UnregisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(handle_linked_user_update))
	UnregisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(handle_linked_user_deletion))

/datum/resurrection_rune_controller/proc/set_rune_link_tag(mob/living/carbon/user, rune_tag)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	human_user.rune_linked = rune_tag

/datum/resurrection_rune_controller/proc/handle_linked_user_update(mob/living/carbon/target)
	SIGNAL_HANDLER

	if(!target)
		return
	if(!sub_rune)
		return
	if(!sub_rune.is_main && !sub_rune.main_rune_link)
		if(!sub_rune.find_master())
			return
	if(resurrections_disabled())
		clear_linked_user_rescue_state(target)
		return
	if(!(target in linked_users))
		return
	if(target in resurrecting)
		clear_linked_user_rescue_state(target)
		return

	var/rescue_stage = get_rescue_stage(target)
	update_linked_user_rescue_state(target, rescue_stage)
	if(rescue_stage != RUNE_STAGE_IMMEDIATE)
		return

	queue_revival(target)

/datum/resurrection_rune_controller/proc/handle_linked_user_deletion(mob/living/carbon/target)
	SIGNAL_HANDLER

	if(!target)
		return

	var/datum/mind/linked_mind = target.mind
	clear_linked_user_rescue_state(target)
	linked_users -= target
	linked_users_by_name.Remove(target.name)
	resurrecting -= target

	if(linked_mind && linked_body_by_mind[linked_mind] == target)
		linked_body_by_mind.Remove(linked_mind)
	if(linked_mind && (linked_mind?.current == target || QDELETED(linked_mind?.current)))
		linked_mind.current = null

/datum/resurrection_rune_controller/proc/prune_deleted_linked_body_state(datum/mind/linked_mind)
	if(!linked_mind)
		return

	var/mob/living/carbon/linked_body = linked_body_by_mind[linked_mind]
	if(linked_body && QDELETED(linked_body))
		linked_users -= linked_body
		linked_users_by_name.Remove(linked_body.name)
		resurrecting -= linked_body
		linked_body_by_mind.Remove(linked_mind)

	if(QDELETED(linked_mind.current))
		linked_mind.current = null

/datum/resurrection_rune_controller/proc/get_rescue_stage(mob/living/carbon/target)
	if(!target)
		return RUNE_STAGE_NONE

	var/turf/target_turf = get_turf(target)
	if(istype(target_turf, /turf/open/lava))
		return RUNE_STAGE_IMMEDIATE
	if(istype(target_turf, /turf/open/lava/acid))
		return RUNE_STAGE_IMMEDIATE
	if(target.is_dead())
		return RUNE_STAGE_IMMEDIATE
	if(target.health <= RUNE_THRESHOLD_FULLCRIT && target.stat == UNCONSCIOUS)
		return RUNE_STAGE_HARD_CRIT
	if(target.health <= RUNE_THRESHOLD_SOFTCRIT || target.get_num_legs(TRUE) < 2)
		return RUNE_STAGE_SOFT_CRIT
	return RUNE_STAGE_NONE

/datum/resurrection_rune_controller/proc/process_hard_crit_timeouts()
	if(!hard_crit_deadlines.len)
		return

	for(var/mob/living/carbon/linked_user as anything in linked_users)
		var/deadline = hard_crit_deadlines[linked_user]
		if(!deadline)
			continue
		if(linked_user in resurrecting)
			clear_hard_crit_deadline(linked_user)
			continue
		if(get_rescue_stage(linked_user) != RUNE_STAGE_HARD_CRIT)
			clear_hard_crit_deadline(linked_user)
			continue
		if(world.time < deadline)
			continue

		queue_revival(linked_user)

/datum/resurrection_rune_controller/proc/update_linked_user_rescue_state(mob/living/carbon/user, rescue_stage = get_rescue_stage(user))
	if(!user)
		return

	switch(rescue_stage)
		if(RUNE_STAGE_SOFT_CRIT)
			ensure_rescue_action(user)
			clear_hard_crit_deadline(user)
		if(RUNE_STAGE_HARD_CRIT)
			ensure_rescue_action(user)
			ensure_hard_crit_deadline(user)
		else
			clear_linked_user_rescue_state(user)

/datum/resurrection_rune_controller/proc/clear_all_linked_user_rescue_states()
	for(var/mob/living/carbon/linked_user as anything in linked_users)
		clear_linked_user_rescue_state(linked_user)

/datum/resurrection_rune_controller/proc/clear_linked_user_rescue_state(mob/living/carbon/user)
	clear_rescue_action(user)
	clear_hard_crit_deadline(user)

/datum/resurrection_rune_controller/proc/ensure_rescue_action(mob/living/carbon/user)
	if(!user)
		return
	if(rescue_actions[user])
		return

	var/datum/action/innate/resurrection_rune_call/rescue_action = new(src)
	rescue_action.Grant(user)
	rescue_actions[user] = rescue_action
	to_chat(user, span_blue("You feel the rune's pull stengthening towards you. All you need is to answer it."))

/datum/resurrection_rune_controller/proc/clear_rescue_action(mob/living/carbon/user)
	var/datum/action/innate/resurrection_rune_call/rescue_action = rescue_actions[user]
	if(!rescue_action)
		return

	rescue_actions.Remove(user)
	rescue_action.Remove(user)
	qdel(rescue_action)

/datum/resurrection_rune_controller/proc/ensure_hard_crit_deadline(mob/living/carbon/user)
	if(!user)
		return
	if(hard_crit_deadlines[user])
		return

	hard_crit_deadlines[user] = world.time + RUNE_HARD_CRIT_AUTO_DELAY
	to_chat(user, span_blue("The rune will drag you back in roughly ten minutes if you still cling to life."))

/datum/resurrection_rune_controller/proc/clear_hard_crit_deadline(mob/living/carbon/user)
	if(!user)
		return

	hard_crit_deadlines.Remove(user)

/datum/resurrection_rune_controller/proc/trigger_voluntary_revival(mob/living/carbon/user)
	if(!user)
		return FALSE
	if(resurrections_disabled())
		return FALSE
	if(!(user in linked_users))
		return FALSE
	if(user in resurrecting)
		return FALSE

	var/rescue_stage = get_rescue_stage(user)
	if(rescue_stage != RUNE_STAGE_SOFT_CRIT && rescue_stage != RUNE_STAGE_HARD_CRIT)
		return FALSE

	queue_revival(user, voluntary = TRUE)
	return TRUE

/datum/resurrection_rune_controller/proc/queue_revival(mob/living/carbon/user, is_linked = TRUE, voluntary = FALSE)
	if(!user)
		return
	if(user in resurrecting)
		return

	clear_linked_user_rescue_state(user)
	if(voluntary)
		to_chat(user.mind, span_blue("You surrender yourself to the rune's pull."))
	else if(is_linked)
		to_chat(user.mind, span_blue("You feel a faint force tuggung you back to life..."))
	else
		to_chat(user.mind, span_blue("An alien force suddenly <b>YANKS</b> you back to life!"))

	sub_rune.visible_message(span_blue("The rune begins to grow brighter."))
	resurrecting |= user
	addtimer(CALLBACK(src, PROC_REF(complete_revival), user, voluntary), RUNE_REVIVE_DELAY)

/datum/resurrection_rune_controller/proc/complete_revival(mob/living/carbon/user, voluntary = FALSE)
	var/mob/living/carbon/body = user
	if(QDELETED(body))
		body = null
	var/turf/destination_turf = sub_rune?.get_resurrection_destination(body)
	var/turf/return_turf = get_turf(body)
	if(!body || !destination_turf)
		if(sub_rune)
			sub_rune.visible_message(span_blue("The rune flickers, connection to a body suddenly severed."))
		resurrecting -= user
		return
	if(!(body in linked_users))
		resurrecting -= user
		return

	body.visible_message(span_blue("With a loud pop, [body.name] suddenly disappears!"))
	playsound(get_turf(body), 'sound/magic/repulse.ogg', 100, FALSE, -1)
	body.ExtinguishMob()
	maybe_strip_revival_clothes(body, voluntary)
	body.forceMove(destination_turf)
	body.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE)
	body.clear_fullscreens()
	body.reload_fullscreen()
	body.update_cone_show()
	body.update_fov_angles()

	var/was_zombie = body.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(was_zombie || body_has_rot(body))
		clear_rot_and_zombie_state(body, was_zombie)

	body.grab_ghost(TRUE)
	body.flash_act()
	apply_revival_debuffs(body, voluntary)
	apply_revival_side_effects(body, voluntary, return_turf)
	addtimer(CALLBACK(src, PROC_REF(clear_resurrection_lockout), body), RUNE_REVIVE_LOCKOUT)
	playsound(destination_turf, 'sound/misc/vampirespell.ogg', 100, FALSE, -1)
	to_chat(body, span_blue("Despite everything, you are back to life..."))
	to_chat(body, span_red("...But you remember the gnashing horror of what brought you here in minute detail - and you are terrified of repeating it."))
	apply_resurrection_trauma(body)

/datum/resurrection_rune_controller/proc/body_has_rot(mob/living/carbon/target)
	if(!target)
		return FALSE

	for(var/obj/item/bodypart/bodypart as anything in target.bodyparts)
		if(bodypart.rotted)
			return TRUE
	return FALSE

/datum/resurrection_rune_controller/proc/clear_rot_and_zombie_state(mob/living/carbon/target, was_zombie)
	if(was_zombie)
		target.mind.remove_antag_datum(/datum/antagonist/zombie)
		target.death()

	var/datum/component/rot/rot = target.GetComponent(/datum/component/rot)
	if(rot)
		rot.amount = 0

	for(var/obj/item/bodypart/bodypart as anything in target.bodyparts)
		bodypart.rotted = FALSE
		bodypart.update_limb()
		if(bodypart.can_be_disabled)
			bodypart.update_disabled()

	target.update_body()
	target.visible_message("<span class='notice'>The rot leaves [target]'s body!</span>", "<span class='green'>I feel the rot leave my body!</span>")

/datum/resurrection_rune_controller/proc/apply_revival_debuffs(mob/living/carbon/target, voluntary = FALSE)
	clear_revival_debuffs(target)
	if(voluntary)
		target.apply_status_effect(/datum/status_effect/debuff/revived/rune/light)
	else if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.rune_linked)
			target.apply_status_effect(/datum/status_effect/debuff/revived/rune)
		else
			target.apply_status_effect(/datum/status_effect/debuff/revived/rune/rough)
	else
		target.apply_status_effect(/datum/status_effect/debuff/revived/rune/rough)

	target.apply_status_effect(/datum/status_effect/debuff/rune_glow)

/datum/resurrection_rune_controller/proc/clear_revival_debuffs(mob/living/carbon/target)
	if(!target)
		return

	target.remove_status_effect(/datum/status_effect/debuff/revived/rune)
	target.remove_status_effect(/datum/status_effect/debuff/revived/rune/rough)
	target.remove_status_effect(/datum/status_effect/debuff/revived/rune/light)

/datum/resurrection_rune_controller/proc/apply_revival_side_effects(mob/living/carbon/target, voluntary = FALSE, turf/return_turf = null)
	charge_revival_tithe(target)
	give_revival_compass(target, return_turf)

/datum/resurrection_rune_controller/proc/give_revival_compass(mob/living/carbon/target, turf/return_turf)
	if(!target)
		return FALSE

	// Only keep the freshest trail so each resurrection points home once.
	for(var/obj/item/resurrection_compass/old_compass as anything in target.contents)
		if(istype(old_compass))
			qdel(old_compass)

	if(!return_turf)
		to_chat(target, span_notice("The place of your death remains a mystery..."))
		return FALSE

	var/obj/item/resurrection_compass/compass = new(get_turf(target))
	compass.set_target_turf(return_turf)

	if(!target.put_in_hands(compass, FALSE, TRUE, TRUE))
		compass.forceMove(target.drop_location())
		return FALSE

	to_chat(target, span_notice("The rune leaves a compass in your hand, its needle straining toward where you were taken from."))
	return TRUE

/datum/resurrection_rune_controller/proc/charge_revival_tithe(mob/living/carbon/target)
	if(!(target in SStreasury.bank_accounts))
		return FALSE

	var/deposit = min(SStreasury.bank_accounts[target], rand(RUNE_REVIVAL_TITHE_MIN, RUNE_REVIVAL_TITHE_MAX))
	if(deposit <= 0)
		return FALSE

	SStreasury.bank_accounts[target] -= deposit
	SStreasury.treasury_value += deposit
	SStreasury.log_entries += "+[deposit] to treasury (resurrection tithe from [target.real_name])"
	to_chat(target, span_warning("The rune claims [deposit] amna from your account as its due."))
	return TRUE

/datum/resurrection_rune_controller/proc/maybe_strip_revival_clothes(mob/living/carbon/target, voluntary = FALSE)
	if(!ishuman(target))
		return FALSE

	var/strip_chance = RUNE_WARDROBE_LOSS_CHANCE
	if(voluntary)
		strip_chance *= 2
	if(!prob(strip_chance))
		return FALSE

	var/mob/living/carbon/human/human_target = target
	var/list/slots_to_strip = list(
		ITEM_SLOT_HEAD,
		ITEM_SLOT_MASK,
		ITEM_SLOT_NECK,
		ITEM_SLOT_SHIRT,
		ITEM_SLOT_CLOAK,
		ITEM_SLOT_ARMOR,
		ITEM_SLOT_PANTS,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_SHOES,
		ITEM_SLOT_BELT,
		ITEM_SLOT_BELT_L,
		ITEM_SLOT_BELT_R,
	)
	var/stripped_any = FALSE

	for(var/slot_id in slots_to_strip)
		var/obj/item/equipped_item = human_target.get_item_by_slot(slot_id)
		if(!equipped_item)
			continue
		if(istype(equipped_item, /obj/item/storage))
			continue
		if(human_target.dropItemToGround(equipped_item, TRUE, FALSE))
			stripped_any = TRUE

	if(!stripped_any)
		return FALSE

	human_target.visible_message(
		span_warning("The rune's violent pull tears loose some of [human_target]'s clothing!"),
		span_warning("The rune's violent pull tears away your clothing, but leaves your underwear and bags behind!"),
	)
	return TRUE

/datum/resurrection_rune_controller/proc/apply_resurrection_trauma(mob/living/carbon/target)
	var/datum/mind/target_mind = target?.mind
	if(!target_mind)
		return FALSE

	var/trauma_type = target_mind.pending_resurrection_trauma_type
	var/trauma_name = target_mind.pending_resurrection_trauma_name

	if(!ispath(trauma_type, /mob/living))
		if(target.recent_attacker_damage_time + RESURRECTION_TRAUMA_SOURCE_WINDOW < world.time)
			return FALSE
		if(!ispath(target.recent_attacker_damage_mob_type, /mob/living))
			return FALSE
		if(target.recent_attacker_damage_is_player_controlled || target.recent_attacker_damage_is_human)
			return FALSE

		// Voluntary rescues can happen before the victim actually dies, so fall back
		// to the body's recent attacker record when there is no death-cached trauma.
		trauma_type = target.recent_attacker_damage_mob_type
		trauma_name = target.recent_attacker_damage_name

	var/datum/status_effect/debuff/resurrection_trauma/trauma = target.apply_status_effect(/datum/status_effect/debuff/resurrection_trauma, null, trauma_type, trauma_name)
	if(!trauma)
		return FALSE

	target_mind.pending_resurrection_trauma_type = null
	target_mind.pending_resurrection_trauma_name = null

	var/fear_label = trauma.fear_name
	if(!fear_label)
		fear_label = "that thing"
	to_chat(target, span_red("The memory of dying to [fear_label] still clings to you. The sight of it turns your blood to ice."))
	return TRUE

/datum/resurrection_rune_controller/proc/clear_resurrection_lockout(mob/living/carbon/user)
	resurrecting -= user


// Mapping landmarks can redirect a rune tag to a preferred arrival zone without
// changing which physical rune owns the resurrection link.
/obj/effect/landmark/resurrection_rune_destination
	name = "resurrection rune destination"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	var/rune_tag = RUNE_LINK_CITY

/obj/effect/landmark/resurrection_rune_destination/Initialize(mapload)
	. = ..()
	LAZYADDASSOCLIST(GLOB.global_resurrune_markers, rune_tag, src)

/obj/effect/landmark/resurrection_rune_destination/Destroy()
	LAZYREMOVEASSOC(GLOB.global_resurrune_markers, rune_tag, src)
	return ..()

/obj/effect/landmark/resurrection_rune_destination/city
	name = "city resurrection destination"
	rune_tag = RUNE_LINK_CITY

/obj/effect/landmark/resurrection_rune_destination/antag
	name = "antag resurrection destination"
	rune_tag = RUNE_LINK_ANTAG

/obj/effect/landmark/resurrection_rune_destination/vampire
	name = "vampire resurrection destination"
	rune_tag = RUNE_LINK_VAMPIRE

/obj/effect/landmark/resurrection_rune_destination/outlaw
	name = "outlaw resurrection destination"
	rune_tag = RUNE_LINK_OUTLAW


/obj/structure/resurrection_rune
	name = "grand rune"
	desc = "It emits an otherwordly hum."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "portal"
	anchored = TRUE
	layer = BELOW_OPEN_DOOR_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/datum/resurrection_rune_controller/resrunecontroler
	var/is_main = FALSE
	var/obj/structure/resurrection_rune/control/main_rune_link
	var/rune_tag = RUNE_LINK_CITY
	var/disabled_res = FALSE
	var/allows_soul_linking = TRUE
	// Radius 1 means a 3x3 landing footprint around the chosen destination.
	var/destination_radius = 1
	pixel_x = -64
	pixel_y = -64

/obj/structure/resurrection_rune/Initialize(mapload)
	. = ..()
	resrunecontroler = new /datum/resurrection_rune_controller()
	resrunecontroler.sub_rune = src
	find_master()
	GLOB.global_resurrunes += src

/obj/structure/resurrection_rune/Destroy()
	if(resrunecontroler)
		resrunecontroler.control_rune = null
		resrunecontroler.sub_rune = null
		qdel(resrunecontroler)
		resrunecontroler = null

	main_rune_link = null
	GLOB.global_resurrunes -= src
	return ..()

/obj/structure/resurrection_rune/proc/find_master()
	for(var/obj/structure/resurrection_rune/control/found_master as anything in GLOB.global_resurrunes)
		main_rune_link = found_master
		if(resrunecontroler)
			resrunecontroler.control_rune = found_master
		return TRUE

	main_rune_link = null
	if(resrunecontroler)
		resrunecontroler.control_rune = null
	return FALSE

/obj/structure/resurrection_rune/proc/get_management_name()
	var/linked_count = 0
	if(resrunecontroler)
		linked_count = resrunecontroler.linked_users.len

	var/rune_status = disabled_res ? "disabled" : "enabled"
	return "[name] ([rune_tag]) - [x],[y],[z] - [rune_status] - [linked_count] linked"

/obj/structure/resurrection_rune/proc/uses_outlaw_redirect(mob/living/carbon/body = null, datum/mind/linked_mind = null)
	if(!should_redirect_outlaw_resurrection(body, linked_mind))
		return FALSE

	// An outlaw-specific rune can be disabled by the master rune. Marker-only setups
	// still work without one, so mappers can redirect prisoners without another portal.
	var/obj/structure/resurrection_rune/outlaw_rune = find_resurrection_rune_by_tag(RUNE_LINK_OUTLAW)
	if(outlaw_rune)
		return !outlaw_rune.disabled_res

	return !isnull(find_resurrection_rune_destination_marker_by_tag(RUNE_LINK_OUTLAW))

/obj/structure/resurrection_rune/proc/get_outlaw_redirect_rune()
	var/obj/structure/resurrection_rune/outlaw_rune = find_resurrection_rune_by_tag(RUNE_LINK_OUTLAW)
	if(outlaw_rune?.disabled_res)
		return
	return outlaw_rune

/obj/structure/resurrection_rune/proc/get_resurrection_tag(mob/living/carbon/body = null, datum/mind/linked_mind = null)
	if(uses_outlaw_redirect(body, linked_mind))
		return RUNE_LINK_OUTLAW
	return rune_tag

/obj/structure/resurrection_rune/proc/get_resurrection_anchor_rune(mob/living/carbon/body = null, datum/mind/linked_mind = null)
	if(uses_outlaw_redirect(body, linked_mind))
		return get_outlaw_redirect_rune()
	return src

/obj/structure/resurrection_rune/proc/get_resurrection_anchor(mob/living/carbon/body = null, datum/mind/linked_mind = null)
	// Outlaws keep their original soul link, but can be rerouted to a prison rune or
	// prison marker set on resurrection.
	var/rune_tag_to_use = get_resurrection_tag(body, linked_mind)
	var/obj/effect/landmark/resurrection_rune_destination/marker = find_resurrection_rune_destination_marker_by_tag(rune_tag_to_use)
	var/turf/anchor_turf = get_turf(marker)
	if(anchor_turf)
		return anchor_turf

	var/obj/structure/resurrection_rune/anchor_rune = get_resurrection_anchor_rune(body, linked_mind)
	if(anchor_rune)
		return get_turf(anchor_rune)

	return get_turf(src)

/obj/structure/resurrection_rune/proc/get_resurrection_destination_radius(mob/living/carbon/body = null, datum/mind/linked_mind = null)
	var/obj/structure/resurrection_rune/anchor_rune = get_resurrection_anchor_rune(body, linked_mind)
	if(anchor_rune)
		return max(anchor_rune.destination_radius, 0)

	return max(destination_radius, 0)

/obj/structure/resurrection_rune/proc/get_resurrection_destination_options(turf/anchor_turf, search_radius)
	var/list/valid_turfs = list()
	if(!anchor_turf)
		return valid_turfs

	for(var/turf/candidate_turf as anything in RANGE_TURFS(search_radius, anchor_turf))
		if(istype(candidate_turf, /turf/open/lava))
			continue
		if(istype(candidate_turf, /turf/open/lava/acid))
			continue
		if(candidate_turf.is_blocked_turf())
			continue

		valid_turfs += candidate_turf

	return valid_turfs

/obj/structure/resurrection_rune/proc/get_resurrection_destination(mob/living/carbon/body = null, datum/mind/linked_mind = null)
	var/turf/anchor_turf = get_resurrection_anchor(body, linked_mind)
	if(!anchor_turf)
		return

	var/search_radius = get_resurrection_destination_radius(body, linked_mind)
	var/list/valid_turfs = get_resurrection_destination_options(anchor_turf, search_radius)
	if(valid_turfs.len)
		return pick(valid_turfs)

	return anchor_turf

/obj/structure/resurrection_rune/proc/link_soul(mob/living/carbon/user)
	if(!resrunecontroler)
		return FALSE
	if(!allows_soul_linking)
		to_chat(user, span_blue("This rune waits only for the condemned."))
		return FALSE
	if(user in resrunecontroler.linked_users)
		to_chat(user, span_blue("Your Soul is already linked."))
		return FALSE
	if(!resrunecontroler.add_user(user))
		return FALSE

	to_chat(user, span_blue("You link your Soul to the Rune."))
	return TRUE

/obj/structure/resurrection_rune/attack_hand(mob/user)
	. = ..()
	if(!istype(user, /mob/living/carbon))
		return
	if(!resrunecontroler)
		return
	if(!main_rune_link && !is_main)
		find_master()
	if(!main_rune_link && !is_main)
		to_chat(user, span_blue("Somehow, the main rune is not connected..."))
		return
	if(!is_main && disabled_res)
		to_chat(user, span_blue("Your masters have disabled this rune!"))
		return
	if(is_main)
		return
	if(!allows_soul_linking)
		to_chat(user, span_blue("This rune lies in wait for damned souls alone."))
		return

	var/mob/living/carbon/carbon_user = user
	var/choice = input(carbon_user, "What do you wish to do?", "Rune of Souls") as anything in list("Link Soul", "Revive a lost Soul", "Cancel")
	switch(choice)
		if("Link Soul")
			link_soul(carbon_user)
		if("Revive a lost Soul")
			to_chat(carbon_user, span_blue("The rune sputters, as if offended."))
		else
			return

/obj/structure/resurrection_rune/attacked_by(obj/item/I, mob/living/user)
	return FALSE

/obj/structure/resurrection_rune/city
	rune_tag = RUNE_LINK_CITY

/obj/structure/resurrection_rune/antag
	rune_tag = RUNE_LINK_ANTAG

/obj/structure/resurrection_rune/outlaw
	name = "outlaw rune"
	rune_tag = RUNE_LINK_OUTLAW
	allows_soul_linking = FALSE

/obj/structure/resurrection_rune/control
	name = "master rune"
	is_main = TRUE
	rune_tag = RUNE_LINK_VAMPIRE

/obj/structure/resurrection_rune/control/Initialize(mapload)
	. = ..()

/obj/structure/resurrection_rune/control/proc/get_managed_rune_options()
	var/list/rune_options = list()

	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		if(rune.is_main)
			continue
		rune_options[rune.get_management_name()] = rune

	return rune_options

/obj/structure/resurrection_rune/control/proc/select_managed_rune(mob/living/carbon/user)
	var/list/rune_options = get_managed_rune_options()
	if(!rune_options.len)
		to_chat(user, span_blue("No sub-runes answer the master rune."))
		return

	var/selected_rune_name = input(user, "Which rune do you wish to command?", "Master Rune") as null|anything in rune_options
	if(!selected_rune_name)
		return
	return rune_options[selected_rune_name]

/obj/structure/resurrection_rune/control/proc/manage_selected_rune(mob/living/carbon/user, obj/structure/resurrection_rune/selected_rune)
	if(!selected_rune)
		return
	if(!selected_rune.resrunecontroler)
		return

	var/toggle_label = selected_rune.disabled_res ? "Enable Rune" : "Disable Rune"
	var/action = input(user, "What do you wish to do with [selected_rune.get_management_name()]?", "Master Rune") as null|anything in list(toggle_label, "Unlink a Soul", "Cancel")
	switch(action)
		if("Enable Rune")
			selected_rune.disabled_res = FALSE
			to_chat(user, span_blue("[selected_rune.name] may restore them once more."))
		if("Disable Rune")
			selected_rune.disabled_res = TRUE
			to_chat(user, span_blue("[selected_rune.name] will claim no more souls."))
		if("Unlink a Soul")
			if(!selected_rune.resrunecontroler.linked_users_by_name.len)
				to_chat(user, span_blue("No souls are linked to that rune."))
				return

			var/selected_name = input(user, "Choose.", "Souls") as null|anything in selected_rune.resrunecontroler.linked_users_by_name
			if(!selected_name)
				return

			var/mob/living/carbon/linked_target = selected_rune.resrunecontroler.linked_users_by_name[selected_name]
			if(!linked_target)
				return

			selected_rune.resrunecontroler.remove_user(linked_target)
			to_chat(user, span_blue("They are now damned."))
		else
			return

/obj/structure/resurrection_rune/control/attack_hand(mob/user)
	. = ..()
	if(!istype(user, /mob/living/carbon))
		return

	var/mob/living/carbon/carbon_user = user
	var/choice = input(carbon_user, "What do you wish to do?", "Master Rune") as anything in list("Link Soul", "Manage a Rune", "Cancel")
	switch(choice)
		if("Link Soul")
			link_soul(carbon_user)
		if("Manage a Rune")
			var/obj/structure/resurrection_rune/selected_rune = select_managed_rune(carbon_user)
			if(!selected_rune)
				return
			manage_selected_rune(carbon_user, selected_rune)
		else
			return

/mob/living/carbon/proc/get_rune_linked(rune_target)
	var/obj/structure/resurrection_rune/resrune = rune_target
	if(istext(rune_target))
		resrune = find_resurrection_rune_by_tag(rune_target)

	if(!resrune)
		return FALSE
	if(!resrune.main_rune_link && !resrune.is_main)
		resrune.find_master()
	if(!resrune.resrunecontroler)
		return FALSE
	if(resrune.resrunecontroler.add_user(src))
		to_chat(src, span_blue("You are protected from Death."))
		return TRUE
	return FALSE

/datum/job/roguetown/vampire
	rune_linked = RUNE_LINK_VAMPIRE

#undef RUNE_REBUILD_DELAY
#undef RUNE_REVIVE_DELAY
#undef RUNE_REVIVE_LOCKOUT
#undef RUNE_HARD_CRIT_AUTO_DELAY
#undef RUNE_REVIVAL_TITHE_MIN
#undef RUNE_REVIVAL_TITHE_MAX
#undef RUNE_WARDROBE_LOSS_CHANCE
#undef RUNE_STAGE_NONE
#undef RUNE_STAGE_SOFT_CRIT
#undef RUNE_STAGE_HARD_CRIT
#undef RUNE_STAGE_IMMEDIATE
