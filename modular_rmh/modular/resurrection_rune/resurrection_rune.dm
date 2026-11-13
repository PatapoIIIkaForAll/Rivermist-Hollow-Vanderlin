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
#define RUNE_MOB_ERP_ESCAPE_ACTION_DURATION (1 MINUTES)

/proc/find_resurrection_rune_by_tag(rune_tag)
	if(!rune_tag || rune_tag == RUNE_LINK_NONE)
		return

	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		if(rune.rune_tag != rune_tag)
			continue
		return rune

/proc/find_resurrection_rune_by_mind(datum/mind/linked_mind)
	if(!linked_mind)
		return

	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		if(!rune.resrunecontroler)
			continue
		if(linked_mind in rune.resrunecontroler.linked_users_minds)
			return rune

/proc/find_resurrection_rune_destination_marker_by_tag(rune_tag)
	if(!rune_tag || rune_tag == RUNE_LINK_NONE)
		return

	var/list/tagged_markers = GLOB.global_resurrune_markers[rune_tag]
	if(!tagged_markers || !tagged_markers.len)
		return

	return pick(tagged_markers)

/// The rune an unlinked-but-should-be-linked mob falls back to (the defeat-system emergency bond).
/// Prefers the public city rune, then any ordinary sub-rune, and only the master rune as a last resort.
/proc/get_emergency_resurrection_rune()
	var/obj/structure/resurrection_rune/city_rune = find_resurrection_rune_by_tag(RUNE_LINK_CITY)
	if(city_rune?.resrunecontroler)
		return city_rune
	var/obj/structure/resurrection_rune/main_fallback
	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		if(!rune.resrunecontroler)
			continue
		if(rune.is_main)
			main_fallback = rune
			continue
		return rune
	return main_fallback

/proc/get_resurrection_rune_controller_for_user(mob/living/carbon/user)
	if(!ishuman(user))
		return null

	var/mob/living/carbon/human/human_user = user
	if(!human_user.rune_linked || human_user.rune_linked == RUNE_LINK_NONE)
		return null

	var/obj/structure/resurrection_rune/linked_rune = find_resurrection_rune_by_tag(human_user.rune_linked)
	if(!linked_rune)
		return null
	if(!linked_rune.main_rune_link && !linked_rune.is_main)
		linked_rune.find_master()
	return linked_rune.resrunecontroler

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
	if(rune_controller.can_offer_defeat_rune_return(carbon_owner))
		return TRUE

	var/rescue_stage = rune_controller.get_rescue_stage(carbon_owner)
	if(rescue_stage == RUNE_STAGE_SOFT_CRIT || rescue_stage == RUNE_STAGE_HARD_CRIT)
		return TRUE
	return rune_controller.can_offer_mob_erp_rescue(carbon_owner)

/datum/action/innate/resurrection_rune_call/Activate()
	. = ..()
	if(!istype(owner, /mob/living/carbon))
		return
	if(!rune_controller)
		return

	var/mob/living/carbon/carbon_owner = owner
	if(rune_controller.can_offer_defeat_rune_return(carbon_owner))
		var/datum/component/kidnap_captivity/captivity = carbon_owner.GetComponent(/datum/component/kidnap_captivity)
		if(captivity)
			captivity.offer_release_choice(rune_controller)
			return
		var/list/choices = list(KIDNAP_CHOICE_CALL_RUNE, "Not yet")
		// Spell out the price before they spend a charge - the return is powerful but far from free.
		var/confirm = tgui_alert(carbon_owner, "Calling the rune will haul you to safety and mend your wounds - but it is not free:\n\n\
			- You are torn from where you fell and wake beside the rune, far away (a compass points back to where you were taken).\n\
			- The violent pull may rip away your worn clothing and armor - your underwear and bags are spared.\n\
			- A mana backlash burns away half your mana and leaves you with lingering rune-weariness on top of the injuries of your defeat.\n\
			- The rune takes its due: a tithe of coin and a tax of your blood, both growing heavier as your charges run low.\n\
			- This spends one of your limited rune charges. They return slowly over time; spend your last and no rune will answer until they recharge.",
			"Answer the rune's call?", choices)
		if(confirm != KIDNAP_CHOICE_CALL_RUNE)
			return
		rune_controller.trigger_defeat_rune_return(carbon_owner)
		return

	var/rescue_stage = rune_controller.get_rescue_stage(carbon_owner)
	if(rescue_stage == RUNE_STAGE_SOFT_CRIT || rescue_stage == RUNE_STAGE_HARD_CRIT)
		rune_controller.trigger_voluntary_revival(carbon_owner)
		return
	if(rune_controller.can_offer_mob_erp_rescue(carbon_owner))
		rune_controller.trigger_mob_erp_escape(carbon_owner)

/datum/action/innate/resurrection_rune_return
	name = "Return to the Rune"
	desc = "Let the rune remake your lost body."
	button_icon_state = "shieldsparkles"
	var/datum/resurrection_rune_controller/rune_controller
	var/datum/mind/linked_mind

/datum/action/innate/resurrection_rune_return/New(datum/resurrection_rune_controller/controller, datum/mind/new_linked_mind)
	rune_controller = controller
	linked_mind = new_linked_mind
	. = ..(controller)

/datum/action/innate/resurrection_rune_return/Destroy()
	rune_controller = null
	linked_mind = null
	return ..()

/datum/action/innate/resurrection_rune_return/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(!isobserver(owner))
		return FALSE
	if(!rune_controller)
		return FALSE
	if(!linked_mind)
		return FALSE

	var/mob/dead/observer/ghost_owner = owner
	return rune_controller.can_offer_ghost_return(linked_mind, ghost_owner)

/datum/action/innate/resurrection_rune_return/Activate()
	. = ..()
	if(!rune_controller)
		return
	if(!linked_mind)
		return

	var/mob/dead/observer/ghost_owner = owner
	rune_controller.trigger_ghost_return(linked_mind, ghost_owner)


/datum/resurrection_rune_controller
	var/obj/structure/resurrection_rune/control/control_rune
	var/obj/structure/resurrection_rune/sub_rune
	var/list/linked_users = list()
	var/list/linked_users_by_name = list()
	var/list/linked_users_minds = list()
	var/list/linked_body_by_mind = list()
	var/list/resurrecting = list()
	var/list/rescue_actions = list()
	var/list/ghost_return_actions = list()
	var/list/hard_crit_deadlines = list()
	var/list/mob_erp_escape_deadlines = list()
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
	for(var/datum/mind/linked_mind as anything in linked_users_minds)
		UnregisterSignal(linked_mind, COMSIG_PARENT_QDELETING)
	clear_all_ghost_return_actions()

	control_rune = null
	sub_rune = null
	linked_users = null
	linked_users_by_name = null
	linked_users_minds = null
	linked_body_by_mind = null
	resurrecting = null
	rescue_actions = null
	ghost_return_actions = null
	hard_crit_deadlines = null
	mob_erp_escape_deadlines = null
	return ..()

/datum/resurrection_rune_controller/process()
	if(!sub_rune)
		return
	if(!sub_rune.is_main && !sub_rune.main_rune_link)
		sub_rune.find_master()
		return
	if(resurrections_disabled())
		clear_all_linked_user_rescue_states()
		clear_all_ghost_return_actions()
		return
	if(!linked_users_minds.len)
		return

	// Linked souls that fully lost their body can choose to be remade at the rune.
	for(var/datum/mind/linked_mind as anything in linked_users_minds)
		if(should_remove_linked_mind(linked_mind))
			remove_linked_mind(linked_mind)
			return
		prune_deleted_linked_body_state(linked_mind)
		var/mob/living/carbon/temporary_shape_source_body = get_active_noncarbon_shapeshift_source_body(linked_mind)
		if(temporary_shape_source_body)
			clear_ghost_return_action(linked_mind)
			resurrecting -= linked_mind
			replace_linked_body(linked_mind, temporary_shape_source_body)
			clear_linked_user_rescue_state(temporary_shape_source_body)
			continue
		var/mob/living/carbon/current_body = get_current_linkable_body(linked_mind)
		if(current_body)
			clear_ghost_return_action(linked_mind)
			replace_linked_body(linked_mind, current_body)
			continue
		if(linked_mind in resurrecting)
			continue
		ensure_ghost_return_action(linked_mind)

	process_mob_erp_escape_offers()
	process_hard_crit_timeouts()

/datum/resurrection_rune_controller/proc/resurrections_disabled()
	if(!sub_rune)
		return TRUE
	return sub_rune.disabled_res

/datum/resurrection_rune_controller/proc/should_remove_linked_mind(datum/mind/linked_mind)
	if(!linked_mind)
		return FALSE

	// Client handoffs can briefly still point at a lobby mob during spawn. Only
	// sever a link if the mind itself is explicitly sitting in a new-player body.
	var/mob/current_mob = linked_mind.current
	if(!current_mob)
		return FALSE
	return isnewplayer(current_mob)

/datum/resurrection_rune_controller/proc/get_current_linkable_body(datum/mind/linked_mind)
	if(!linked_mind)
		return null

	var/mob/living/current_body = linked_mind.current
	if(is_linkable_body(current_body))
		return current_body
	return get_active_noncarbon_shapeshift_source_body(linked_mind)

/datum/resurrection_rune_controller/proc/is_linkable_body(mob/living/body)
	if(!istype(body, /mob/living/carbon))
		return FALSE
	if(istype(body, /mob/living/brain))
		return FALSE
	if(QDELETED(body))
		return FALSE
	return TRUE

/datum/resurrection_rune_controller/proc/get_active_noncarbon_shapeshift_source_body(datum/mind/linked_mind)
	if(!linked_mind)
		return null

	var/mob/living/current_body = linked_mind.current
	if(!istype(current_body))
		return null
	if(QDELETED(current_body))
		return null
	if(is_linkable_body(current_body))
		return null

	// Rat-style shapeshifts keep the real carbon body inside a temporary non-carbon mob.
	for(var/datum/status_effect/shapechange_mob/shapechange in current_body.status_effects)
		var/mob/living/source_body = shapechange.caster_mob
		if(!is_linkable_body(source_body))
			continue
		if(get_mind(source_body, TRUE) != linked_mind)
			continue
		return source_body

	return null

/datum/resurrection_rune_controller/proc/get_linked_mind_for_body(mob/living/carbon/body)
	if(!body)
		return null

	var/datum/mind/body_mind = body.mind
	if(body_mind && linked_body_by_mind[body_mind] == body)
		return body_mind

	for(var/datum/mind/linked_mind as anything in linked_body_by_mind)
		if(linked_body_by_mind[linked_mind] == body)
			return linked_mind

	return null

/datum/resurrection_rune_controller/proc/is_active_noncarbon_shapeshift_source_body(mob/living/carbon/body)
	if(!body)
		return FALSE

	var/datum/mind/linked_mind = get_linked_mind_for_body(body)
	if(!linked_mind)
		return FALSE
	return get_active_noncarbon_shapeshift_source_body(linked_mind) == body

/datum/resurrection_rune_controller/proc/can_offer_ghost_return(datum/mind/linked_mind, mob/dead/observer/ghost)
	if(!linked_mind || linked_mind.defeat_character_abandoned)
		return FALSE
	if(!(linked_mind in linked_users_minds))
		return FALSE
	if(resurrections_disabled())
		return FALSE
	if(linked_mind in resurrecting)
		return FALSE
	if(get_current_linkable_body(linked_mind))
		return FALSE
	if(ghost && ghost.mind != linked_mind)
		return FALSE
	return TRUE

/datum/resurrection_rune_controller/proc/ensure_ghost_return_action(datum/mind/linked_mind)
	if(!can_offer_ghost_return(linked_mind))
		clear_ghost_return_action(linked_mind)
		return FALSE

	var/mob/dead/observer/ghost = linked_mind.get_ghost(TRUE, TRUE)
	if(!ghost)
		return FALSE

	var/datum/action/innate/resurrection_rune_return/return_action = ghost_return_actions[linked_mind]
	if(QDELETED(return_action))
		return_action = null
	if(!return_action)
		return_action = new(src, linked_mind)
		ghost_return_actions[linked_mind] = return_action
		to_chat(ghost, span_blue("The rune can remake your body. Answer it when you are ready."))

	return_action.Grant(ghost)
	return TRUE

/datum/resurrection_rune_controller/proc/clear_ghost_return_action(datum/mind/linked_mind)
	var/datum/action/innate/resurrection_rune_return/return_action = ghost_return_actions[linked_mind]
	if(!return_action)
		return

	ghost_return_actions.Remove(linked_mind)
	qdel(return_action)

/datum/resurrection_rune_controller/proc/clear_all_ghost_return_actions()
	if(!ghost_return_actions?.len)
		return

	var/list/actions_to_clear = ghost_return_actions.Copy()
	for(var/datum/mind/linked_mind as anything in actions_to_clear)
		clear_ghost_return_action(linked_mind)

/datum/resurrection_rune_controller/proc/trigger_ghost_return(datum/mind/linked_mind, mob/dead/observer/ghost)
	if(!can_offer_ghost_return(linked_mind, ghost))
		clear_ghost_return_action(linked_mind)
		return FALSE

	clear_ghost_return_action(linked_mind)
	queue_body_remake(linked_mind)
	return TRUE

/datum/resurrection_rune_controller/proc/queue_body_remake(datum/mind/linked_mind)
	to_chat(linked_mind.get_ghost(TRUE, TRUE), span_blue("Somewhere, you are being remade anew..."))
	clear_ghost_return_action(linked_mind)
	resurrecting |= linked_mind
	addtimer(CALLBACK(src, PROC_REF(spawn_new_body), linked_mind), RUNE_REBUILD_DELAY)

/datum/resurrection_rune_controller/proc/spawn_new_body(datum/mind/linked_mind)
	if(!sub_rune)
		resurrecting -= linked_mind
		return
	if(!(linked_mind in linked_users_minds))
		resurrecting -= linked_mind
		return
	if(get_current_linkable_body(linked_mind))
		resurrecting -= linked_mind
		return

	var/turf/destination_turf = sub_rune.get_resurrection_destination(linked_mind = linked_mind)
	if(!destination_turf)
		resurrecting -= linked_mind
		return

	var/outlaw_redirected = sub_rune.uses_outlaw_redirect(null, linked_mind)
	var/mob/living/carbon/new_body = new mob_type(destination_turf)
	var/mob/ghostie = linked_mind.get_ghost(TRUE)
	if(ghostie?.client?.prefs)
		linked_mind.apply_prefs_to_remade_body(ghostie.client.prefs, new_body)

	// Mind transfer expects the new body to briefly be the current body first.
	linked_mind.current = new_body
	linked_mind.transfer_to(new_body)
	linked_mind.grab_ghost(TRUE)
	new_body.flash_act()
	if(outlaw_redirected)
		explain_outlaw_redirect(new_body)

	replace_linked_body(linked_mind, new_body)
	resurrecting -= linked_mind
	fail_contracts_on_rune_rescue(new_body)
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

	return add_linked_mind(user.mind)

/datum/resurrection_rune_controller/proc/add_linked_mind(datum/mind/linked_mind)
	if(!linked_mind)
		return FALSE
	if(linked_mind in linked_users_minds)
		var/mob/living/carbon/existing_body = get_current_linkable_body(linked_mind)
		if(existing_body)
			clear_ghost_return_action(linked_mind)
			replace_linked_body(linked_mind, existing_body)
		else
			ensure_ghost_return_action(linked_mind)
		return TRUE

	unlink_mind_from_other_resurrection_runes(linked_mind, sub_rune)
	if(!(linked_mind in linked_users_minds))
		linked_users_minds += linked_mind
		RegisterSignal(linked_mind, COMSIG_PARENT_QDELETING, PROC_REF(handle_linked_mind_deletion), override = TRUE)
	var/mob/living/carbon/current_body = get_current_linkable_body(linked_mind)
	if(current_body)
		clear_ghost_return_action(linked_mind)
		replace_linked_body(linked_mind, current_body)
	else
		ensure_ghost_return_action(linked_mind)
	return TRUE

/datum/resurrection_rune_controller/proc/remove_user(mob/living/carbon/user)
	if(!user)
		return FALSE
	if(!(user in linked_users))
		return FALSE

	var/datum/mind/linked_mind = get_linked_mind_for_body(user)
	unregister_linked_body(user)

	if(linked_mind)
		UnregisterSignal(linked_mind, COMSIG_PARENT_QDELETING)
		linked_users_minds -= linked_mind
		linked_body_by_mind.Remove(linked_mind)
		resurrecting -= linked_mind
		clear_ghost_return_action(linked_mind)

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
	if(old_body == new_body && (new_body in linked_users))
		return
	if(old_body && old_body != new_body)
		unregister_linked_body(old_body)

	linked_body_by_mind[linked_mind] = new_body
	register_linked_body(new_body)

/datum/resurrection_rune_controller/proc/remove_linked_mind(datum/mind/linked_mind)
	if(!linked_mind)
		return

	UnregisterSignal(linked_mind, COMSIG_PARENT_QDELETING)
	var/mob/living/carbon/linked_body = linked_body_by_mind[linked_mind]
	if(linked_body)
		unregister_linked_body(linked_body)

	linked_users_minds -= linked_mind
	linked_body_by_mind.Remove(linked_mind)
	resurrecting -= linked_mind
	clear_ghost_return_action(linked_mind)

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
	if(target.defeat_lethal_bypass || target.defeat_final_death || target.suiciding)
		clear_linked_user_rescue_state(target)
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
	if(is_active_noncarbon_shapeshift_source_body(target))
		resurrecting -= target
		clear_linked_user_rescue_state(target)
		return
	if(target.defeat_mode == DEFEAT_MODE_NO_RETURN)
		clear_linked_user_rescue_state(target)
		return
	if(target in resurrecting)
		clear_linked_user_rescue_state(target)
		return

	var/rescue_stage = get_rescue_stage(target)
	update_linked_user_rescue_state(target, rescue_stage)
	if(rescue_stage != RUNE_STAGE_IMMEDIATE)
		return

	queue_revival(target, rune_charge_result = target.mind?.get_defeat_rune_emergency_result())

/datum/resurrection_rune_controller/proc/handle_linked_user_deletion(mob/living/carbon/target)
	SIGNAL_HANDLER

	if(!target)
		return

	var/datum/mind/linked_mind = get_linked_mind_for_body(target)
	if(!linked_mind)
		linked_mind = target.mind
	clear_linked_user_rescue_state(target)
	linked_users -= target
	linked_users_by_name.Remove(target.name)
	resurrecting -= target

	if(linked_mind && linked_body_by_mind[linked_mind] == target)
		linked_body_by_mind.Remove(linked_mind)
	if(linked_mind && (linked_mind?.current == target || QDELETED(linked_mind?.current)))
		linked_mind.current = null
	if(can_auto_remake_deleted_body(linked_mind))
		queue_body_remake(linked_mind)

/// A linked mind being deleted must be dropped from our lists, or we pin it (a hard-del leak).
/// Bodies are tracked separately; minds can be deleted without their last body going through us.
/datum/resurrection_rune_controller/proc/handle_linked_mind_deletion(datum/mind/source)
	SIGNAL_HANDLER
	remove_linked_mind(source)

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

/datum/resurrection_rune_controller/proc/can_auto_remake_deleted_body(datum/mind/linked_mind)
	// A character given up to captivity decays as a lair NPC; the rune must not rebuild them.
	if(!linked_mind || linked_mind.defeat_character_abandoned)
		return FALSE
	if(!(linked_mind in linked_users_minds))
		return FALSE
	if(resurrections_disabled())
		return FALSE
	if(linked_mind in resurrecting)
		return FALSE
	return TRUE

/datum/resurrection_rune_controller/proc/get_rescue_stage(mob/living/carbon/target)
	if(!target)
		return RUNE_STAGE_NONE
	if(is_active_noncarbon_shapeshift_source_body(target))
		return RUNE_STAGE_NONE

	var/turf/target_turf = get_turf(target)
	if(istype(target_turf, /turf/open/lava))
		return RUNE_STAGE_IMMEDIATE
	if(istype(target_turf, /turf/open/lava/acid))
		return RUNE_STAGE_IMMEDIATE
	if(target.is_dead())
		return RUNE_STAGE_IMMEDIATE
	var/effective_health = get_effective_rescue_health(target)
	var/sleeping_above_crit = target.IsSleeping() && effective_health > target.crit_threshold
	if(effective_health <= RUNE_THRESHOLD_FULLCRIT && target.stat == UNCONSCIOUS && !sleeping_above_crit)
		return RUNE_STAGE_HARD_CRIT
	if((effective_health <= RUNE_THRESHOLD_SOFTCRIT && !sleeping_above_crit) || target.get_num_legs(TRUE) < 2)
		return RUNE_STAGE_SOFT_CRIT
	return RUNE_STAGE_NONE

/datum/resurrection_rune_controller/proc/get_effective_rescue_health(mob/living/carbon/target)
	if(!target)
		return INFINITY

	var/injury_pressure = target.getBruteLoss() + target.getFireLoss() + target.getToxLoss() + target.getOxyLoss() + target.getCloneLoss()
	if(ishuman(target))
		// Human health does not include all bodypart injury, so keep using
		// explicit body pressure. Brain damage is handled by brain death, not
		// living rune rescue.
		return target.maxHealth - injury_pressure

	return min(target.health, target.maxHealth - injury_pressure)

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

	if(can_offer_defeat_rune_return(user))
		// A captive already holds the Captivity button, which offers the rune. Two buttons read as a bug.
		if(user.GetComponent(/datum/component/kidnap_captivity))
			clear_rescue_action(user)
		else
			ensure_rescue_action(user)
		clear_hard_crit_deadline(user)
		return

	switch(rescue_stage)
		if(RUNE_STAGE_SOFT_CRIT)
			ensure_rescue_action(user)
			clear_hard_crit_deadline(user)
			return
		if(RUNE_STAGE_HARD_CRIT)
			ensure_rescue_action(user)
			ensure_hard_crit_deadline(user)
			return

	clear_hard_crit_deadline(user)
	if(can_offer_mob_erp_rescue(user))
		ensure_rescue_action(user)
		return

	clear_rescue_action(user)

/datum/resurrection_rune_controller/proc/clear_all_linked_user_rescue_states()
	for(var/mob/living/carbon/linked_user as anything in linked_users)
		clear_linked_user_rescue_state(linked_user)

/datum/resurrection_rune_controller/proc/clear_linked_user_rescue_state(mob/living/carbon/user)
	clear_mob_erp_escape_offer(user, FALSE)
	clear_rescue_action(user)
	clear_hard_crit_deadline(user)

/datum/resurrection_rune_controller/proc/process_mob_erp_escape_offers()
	if(!mob_erp_escape_deadlines.len)
		return

	var/list/offer_targets = mob_erp_escape_deadlines.Copy()
	for(var/mob/living/carbon/linked_user as anything in offer_targets)
		var/deadline = mob_erp_escape_deadlines[linked_user]
		if(!deadline)
			continue
		if(QDELETED(linked_user))
			clear_mob_erp_escape_offer(linked_user, FALSE)
			continue
		if(!(linked_user in linked_users))
			clear_mob_erp_escape_offer(linked_user, FALSE)
			continue
		if(linked_user in resurrecting)
			clear_mob_erp_escape_offer(linked_user)
			continue
		if(world.time < deadline)
			continue

		clear_mob_erp_escape_offer(linked_user)

/datum/resurrection_rune_controller/proc/offer_mob_erp_escape(mob/living/carbon/user, offer_duration = RUNE_MOB_ERP_ESCAPE_ACTION_DURATION)
	if(!can_queue_rescue_for(user))
		return FALSE

	var/existing_deadline = mob_erp_escape_deadlines[user]
	mob_erp_escape_deadlines[user] = max(existing_deadline || 0, world.time + offer_duration)
	update_linked_user_rescue_state(user)
	return TRUE

/datum/resurrection_rune_controller/proc/can_offer_mob_erp_rescue(mob/living/carbon/user)
	if(!user)
		return FALSE

	var/deadline = mob_erp_escape_deadlines[user]
	if(!deadline)
		return FALSE
	if(world.time >= deadline)
		return FALSE
	return can_queue_rescue_for(user)

/datum/resurrection_rune_controller/proc/clear_mob_erp_escape_offer(mob/living/carbon/user, refresh_rescue_state = TRUE)
	if(!user)
		return
	if(!mob_erp_escape_deadlines[user])
		return

	mob_erp_escape_deadlines.Remove(user)
	if(refresh_rescue_state)
		update_linked_user_rescue_state(user)

/datum/resurrection_rune_controller/proc/ensure_rescue_action(mob/living/carbon/user)
	if(!user)
		return
	if(rescue_actions[user])
		return

	var/datum/action/innate/resurrection_rune_call/rescue_action = new(src)
	rescue_action.Grant(user)
	rescue_actions[user] = rescue_action
	to_chat(user, span_blue("The rune has found you in grave danger and is offering to pull you back. Use <b>Call the Rune</b> to surrender to it; your body will be drawn to its circle and revived."))

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

/datum/resurrection_rune_controller/proc/can_queue_rescue_for(mob/living/carbon/user)
	if(!user)
		return FALSE
	if(user.defeat_lethal_bypass || user.defeat_final_death || user.suiciding || user.defeat_mode == DEFEAT_MODE_NO_RETURN)
		return FALSE
	if(resurrections_disabled())
		return FALSE
	if(!(user in linked_users))
		return FALSE
	if(is_active_noncarbon_shapeshift_source_body(user))
		return FALSE
	if(user in resurrecting)
		return FALSE
	return TRUE

/datum/resurrection_rune_controller/proc/can_trigger_trap_rescue(mob/living/carbon/user)
	return can_queue_rescue_for(user)

/datum/resurrection_rune_controller/proc/trigger_trap_rescue(mob/living/carbon/user)
	if(!can_trigger_trap_rescue(user))
		return FALSE

	queue_revival(user, voluntary = TRUE)
	return TRUE

/datum/resurrection_rune_controller/proc/trigger_voluntary_revival(mob/living/carbon/user)
	if(!can_queue_rescue_for(user))
		return FALSE

	var/rescue_stage = get_rescue_stage(user)
	if(rescue_stage != RUNE_STAGE_SOFT_CRIT && rescue_stage != RUNE_STAGE_HARD_CRIT)
		return FALSE

	queue_revival(user, voluntary = TRUE, allow_outlaw_redirect = FALSE)
	return TRUE

/datum/resurrection_rune_controller/proc/trigger_mob_erp_escape(mob/living/carbon/user)
	if(!can_offer_mob_erp_rescue(user))
		return FALSE

	queue_revival(user, voluntary = TRUE)
	return TRUE

/datum/resurrection_rune_controller/proc/can_offer_defeat_rune_return(mob/living/carbon/user)
	if(!can_queue_rescue_for(user))
		return FALSE
	if(user.defeat_mode != DEFEAT_MODE_KO_RUNE)
		return FALSE
	var/datum/component/kidnap_captivity/captivity = user.GetComponent(/datum/component/kidnap_captivity)
	if(captivity)
		// A captive may call the rune once the hold has loosened, knocked out or awake inside the lair.
		if(!captivity.released)
			return FALSE
	else if(!user.has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	return user.mind?.can_spend_defeat_rune_charge()

/datum/resurrection_rune_controller/proc/trigger_defeat_rune_return(mob/living/carbon/user)
	if(!can_offer_defeat_rune_return(user))
		return FALSE

	var/list/rune_charge_result = user.mind.spend_defeat_rune_charge()
	if(!rune_charge_result)
		update_linked_user_rescue_state(user)
		return FALSE

	var/spend_kind = rune_charge_result[DEFEAT_RUNE_SPEND_KIND]
	if(spend_kind == DEFEAT_RUNE_SPEND_FIRST_FREE)
		to_chat(user, span_blue("The rune answers freely - this once."))
	else if(spend_kind == DEFEAT_RUNE_SPEND_CHARGED && rune_charge_result[DEFEAT_RUNE_CHARGES_REMAINING] <= 0)
		to_chat(user, span_userdanger("That was your final rune charge. The next time you fall, no rune will answer until your charges return - sit tight and stay safe."))

	queue_revival(user, voluntary = TRUE, allow_outlaw_redirect = FALSE, rune_charge_result = rune_charge_result)
	return TRUE

/datum/resurrection_rune_controller/proc/reject_defeat_rune_return(mob/living/carbon/user)
	if(!can_offer_defeat_rune_return(user))
		return FALSE
	var/datum/component/kidnap_captivity/captivity = user.GetComponent(/datum/component/kidnap_captivity)
	if(!captivity || !captivity.reject_rune_and_wake())
		return FALSE
	clear_linked_user_rescue_state(user)
	return TRUE

/datum/resurrection_rune_controller/proc/queue_revival(mob/living/carbon/user, is_linked = TRUE, voluntary = FALSE, allow_outlaw_redirect = TRUE, list/rune_charge_result = null)
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
	addtimer(CALLBACK(src, PROC_REF(complete_revival), user, voluntary, allow_outlaw_redirect, rune_charge_result), RUNE_REVIVE_DELAY)

/datum/resurrection_rune_controller/proc/complete_revival(mob/living/carbon/user, voluntary = FALSE, allow_outlaw_redirect = TRUE, list/rune_charge_result = null)
	var/mob/living/carbon/body = user
	if(resurrections_disabled())
		resurrecting -= user
		return
	if(body?.defeat_final_death || body?.suiciding)
		resurrecting -= user
		return
	if(QDELETED(body))
		body = null
	if(is_active_noncarbon_shapeshift_source_body(body))
		clear_linked_user_rescue_state(body)
		resurrecting -= user
		return
	var/turf/destination_turf = sub_rune?.get_resurrection_destination(body, allow_outlaw_redirect = allow_outlaw_redirect)
	var/datum/component/kidnap_captivity/captivity = body?.GetComponent(/datum/component/kidnap_captivity)
	var/turf/return_turf = captivity?.get_saved_origin() || get_turf(body)
	if(!body || !destination_turf)
		if(sub_rune)
			sub_rune.visible_message(span_blue("The rune flickers, connection to a body suddenly severed."))
		resurrecting -= user
		return
	if(!(body in linked_users))
		resurrecting -= user
		return
	if(captivity)
		captivity.prepare_rune_return()

	var/had_defeat_knockout = body.has_status_effect(/datum/status_effect/defeat_knockout)
	body.visible_message(span_blue("With a loud pop, [body.name] suddenly disappears!"))
	playsound(get_turf(body), 'sound/magic/repulse.ogg', 100, FALSE, -1)
	body.ExtinguishMob()
	maybe_strip_revival_clothes(body, voluntary)
	var/outlaw_redirected = sub_rune.uses_outlaw_redirect(body, null, allow_outlaw_redirect)
	body.forceMove(destination_turf)
	if(outlaw_redirected)
		explain_outlaw_redirect(body)
	body.defeat_suppress_heal_cleanup = TRUE
	body.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE)
	body.defeat_suppress_heal_cleanup = FALSE
	// After the strip and the move, so only quest items that came home count.
	fail_contracts_on_rune_rescue(body)
	if(had_defeat_knockout)
		var/datum/defeat_recovery_profile/rune/rune_profile = new
		rune_profile.additional_aftermath_severity = get_defeat_rune_trauma_severity(rune_charge_result)
		if(!body.perform_defeat_rescue(null, "rune return", rune_profile, sub_rune))
			resurrecting -= user
			return
	else
		body.remove_status_effect(/datum/status_effect/defeat_knockout)
	body.end_pregnancies_after_rune_resurrection()
	body.clear_fullscreens()
	body.reload_fullscreen()
	body.update_cone_show()
	body.update_fov_angles()

	var/was_zombie = body.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(was_zombie || body_has_rot(body))
		clear_rot_and_zombie_state(body, was_zombie)

	body.grab_ghost(TRUE)
	body.flash_act()
	apply_revival_debuffs(body, voluntary, rune_charge_result, apply_defeat_trauma = !had_defeat_knockout)
	apply_defeat_rune_cost(body, rune_charge_result)
	apply_revival_side_effects(body, voluntary, return_turf)
	addtimer(CALLBACK(src, PROC_REF(clear_resurrection_lockout), body), RUNE_REVIVE_LOCKOUT)
	playsound(destination_turf, 'sound/misc/vampirespell.ogg', 100, FALSE, -1)
	to_chat(body, span_blue("Despite everything, you are back to life..."))
	to_chat(body, span_red("...But you remember the gnashing horror of what brought you here in minute detail - and you are terrified of repeating it."))
	if(had_defeat_knockout)
		// A hover-tooltip primer on the rune (like the trauma-alert tooltips): short visible line,
		// full mechanics revealed on hover, so a rescued player can learn the system without spam.
		var/rune_primer = "The rune runs on a handful of charges that return slowly over time. Each call after the first costs more of your coin and blood, and spending your last leaves the rune silent until it recharges. The rune-weariness and wounds it left behind can be mended by a town healer or at a shrine."
		to_chat(body, span_notice("Steady yourself - and remember how [span_tooltip(rune_primer, "the rune that saved you")] works, lest your next fall be your last."))
	apply_resurrection_trauma(body)

/// Outlaws wake in the law's cell, not beside their own rune. Say so, or it reads as a teleport bug.
/datum/resurrection_rune_controller/proc/explain_outlaw_redirect(mob/living/carbon/body)
	if(!body)
		return
	to_chat(body, span_userdanger("Your name is on the outlaw rolls. The rune you bound yourself to will not shelter the condemned: the law's own rune seized your thread and remade you in its cell."))
	to_chat(body, span_notice("Outlaws return this way until the decree is lifted. Vampires and town-hall officers are exempt."))

/datum/resurrection_rune_controller/proc/body_has_rot(mob/living/carbon/target)
	if(!target)
		return FALSE

	for(var/obj/item/bodypart/bodypart as anything in target.bodyparts)
		if(HAS_TRAIT(bodypart, TRAIT_ROTTEN))
			return TRUE
	return FALSE

/datum/resurrection_rune_controller/proc/clear_rot_and_zombie_state(mob/living/carbon/target, was_zombie)
	if(was_zombie)
		target.mind.remove_antag_datum(/datum/antagonist/zombie)

	var/datum/component/rot/rot = target.GetComponent(/datum/component/rot)
	if(rot)
		rot.amount = 0

	for(var/obj/item/bodypart/bodypart as anything in target.bodyparts)
		REMOVE_TRAIT(bodypart, TRAIT_ROTTEN, GERM_LEVEL_TRAIT)
		bodypart.update_limb()
		if(bodypart.can_be_disabled)
			bodypart.update_disabled()

	target.update_body()
	target.visible_message("<span class='notice'>The rot leaves [target]'s body!</span>", "<span class='green'>I feel the rot leave my body!</span>")

/datum/resurrection_rune_controller/proc/apply_revival_debuffs(mob/living/carbon/target, voluntary = FALSE, list/rune_charge_result = null, apply_defeat_trauma = TRUE)
	clear_revival_debuffs(target)
	if(rune_charge_result)
		target.apply_status_effect(get_revival_debuff_for_defeat_rune_result(rune_charge_result))
		if(apply_defeat_trauma)
			target.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/rune, get_defeat_rune_trauma_severity(rune_charge_result))
	else if(voluntary)
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

/datum/resurrection_rune_controller/proc/get_revival_debuff_for_defeat_rune_result(list/rune_charge_result)
	var/spend_kind = rune_charge_result?[DEFEAT_RUNE_SPEND_KIND]
	var/charges_remaining = rune_charge_result?[DEFEAT_RUNE_CHARGES_REMAINING]
	if(spend_kind == DEFEAT_RUNE_SPEND_EMERGENCY)
		return /datum/status_effect/debuff/revived/rune/rough
	if(spend_kind == DEFEAT_RUNE_SPEND_CHARGED && charges_remaining <= 0)
		return /datum/status_effect/debuff/revived/rune/rough
	if(spend_kind == DEFEAT_RUNE_SPEND_CHARGED && charges_remaining <= 2)
		return /datum/status_effect/debuff/revived/rune
	return /datum/status_effect/debuff/revived/rune/light

/datum/resurrection_rune_controller/proc/get_defeat_rune_trauma_severity(list/rune_charge_result)
	var/spend_kind = rune_charge_result?[DEFEAT_RUNE_SPEND_KIND]
	var/charges_remaining = rune_charge_result?[DEFEAT_RUNE_CHARGES_REMAINING]
	if(spend_kind == DEFEAT_RUNE_SPEND_EMERGENCY)
		return DEFEAT_SEVERITY_SEVERE
	if(spend_kind == DEFEAT_RUNE_SPEND_CHARGED && charges_remaining <= 0)
		return DEFEAT_SEVERITY_SEVERE
	if(spend_kind == DEFEAT_RUNE_SPEND_CHARGED && charges_remaining <= 2)
		return DEFEAT_SEVERITY_NORMAL
	return DEFEAT_SEVERITY_LIGHT

/datum/resurrection_rune_controller/proc/clear_revival_debuffs(mob/living/carbon/target)
	if(!target)
		return

	target.remove_status_effect(/datum/status_effect/debuff/revived/rune)
	target.remove_status_effect(/datum/status_effect/debuff/revived/rune/rough)
	target.remove_status_effect(/datum/status_effect/debuff/revived/rune/light)

/// Bills the defeat-rune return: a best-effort coin tithe plus the always-drawn blood tax (D1).
/// First-free and emergency (depleted) returns cost nothing.
/datum/resurrection_rune_controller/proc/apply_defeat_rune_cost(mob/living/carbon/user, list/rune_charge_result)
	if(!user || !rune_charge_result)
		return FALSE
	if(rune_charge_result[DEFEAT_RUNE_SPEND_KIND] != DEFEAT_RUNE_SPEND_CHARGED)
		return FALSE

	var/charges_before = rune_charge_result[DEFEAT_RUNE_CHARGES_REMAINING] + 1
	var/list/cost = defeat_rune_charge_cost(charges_before)

	// Coin tithe - the townsfolk pay the vampires their due. Best-effort: only what they have.
	var/coin = cost["coin"]
	if(coin > 0 && (user in SStreasury.bank_accounts))
		var/paid = min(SStreasury.bank_accounts[user], coin)
		if(paid > 0)
			SStreasury.bank_accounts[user] -= paid
			SStreasury.treasury_value += paid
			SStreasury.log_entries += "+[paid] to treasury (rune defeat tithe from [user.real_name])"

	// Blood tax - literal blood drawn to power the rune (and later the vampire blood bank).
	var/blood = cost["blood"]
	if(blood == DEFEAT_RUNE_BLOOD_FRACTION_SENTINEL)
		blood = round(user.blood_volume * DEFEAT_RUNE_LAST_CHARGE_BLOOD_FRACTION)
	if(blood > 0)
		user.collect_blood_tax(blood)
	return TRUE

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

/obj/structure/resurrection_rune/proc/uses_outlaw_redirect(mob/living/carbon/body = null, datum/mind/linked_mind = null, allow_outlaw_redirect = TRUE)
	if(!allow_outlaw_redirect)
		return FALSE
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

/obj/structure/resurrection_rune/proc/get_resurrection_tag(mob/living/carbon/body = null, datum/mind/linked_mind = null, allow_outlaw_redirect = TRUE)
	if(uses_outlaw_redirect(body, linked_mind, allow_outlaw_redirect))
		return RUNE_LINK_OUTLAW
	return rune_tag

/obj/structure/resurrection_rune/proc/get_resurrection_anchor_rune(mob/living/carbon/body = null, datum/mind/linked_mind = null, allow_outlaw_redirect = TRUE)
	if(uses_outlaw_redirect(body, linked_mind, allow_outlaw_redirect))
		return get_outlaw_redirect_rune()
	return src

/obj/structure/resurrection_rune/proc/get_resurrection_anchor(mob/living/carbon/body = null, datum/mind/linked_mind = null, allow_outlaw_redirect = TRUE)
	// Outlaws keep their original soul link, but can be rerouted to a prison rune or
	// prison marker set on resurrection.
	var/rune_tag_to_use = get_resurrection_tag(body, linked_mind, allow_outlaw_redirect)
	var/obj/effect/landmark/resurrection_rune_destination/marker = find_resurrection_rune_destination_marker_by_tag(rune_tag_to_use)
	var/turf/anchor_turf = get_turf(marker)
	if(anchor_turf)
		return anchor_turf

	var/obj/structure/resurrection_rune/anchor_rune = get_resurrection_anchor_rune(body, linked_mind, allow_outlaw_redirect)
	if(anchor_rune)
		return get_turf(anchor_rune)

	return get_turf(src)

/obj/structure/resurrection_rune/proc/get_resurrection_destination_radius(mob/living/carbon/body = null, datum/mind/linked_mind = null, allow_outlaw_redirect = TRUE)
	var/obj/structure/resurrection_rune/anchor_rune = get_resurrection_anchor_rune(body, linked_mind, allow_outlaw_redirect)
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

/obj/structure/resurrection_rune/proc/get_resurrection_destination(mob/living/carbon/body = null, datum/mind/linked_mind = null, allow_outlaw_redirect = TRUE)
	var/turf/anchor_turf = get_resurrection_anchor(body, linked_mind, allow_outlaw_redirect)
	if(!anchor_turf)
		return

	var/search_radius = get_resurrection_destination_radius(body, linked_mind, allow_outlaw_redirect)
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
	var/choice = input(carbon_user, "What do you wish to do?", "Rune of Souls") in list("Link Soul", "Revive a lost Soul", "Cancel")
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

/obj/structure/resurrection_rune/werewolf
	name = "moon rune"
	rune_tag = RUNE_LINK_WEREWOLF
	icon = 'icons/obj/rune.dmi'
	icon_state =  "summon"
	pixel_x = 0
	pixel_y = 0

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
	var/choice = input(carbon_user, "What do you wish to do?", "Master Rune") in list("Link Soul", "Manage a Rune", "Cancel")
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

/proc/get_resurrection_rune_admin_mind(mob/target)
	if(!target)
		return
	if(isobserver(target))
		return target.mind
	return get_mind(target, TRUE)

/proc/get_resurrection_rune_admin_mind_label(datum/mind/linked_mind)
	if(!linked_mind)
		return "No mind"

	var/name = linked_mind.name || "Unknown"
	var/key = linked_mind.key || "no key"
	var/current_body = linked_mind.current ? "[linked_mind.current]" : "bodyless"
	return "[name] ([key]) - [current_body]"

/proc/get_resurrection_rune_admin_rune_options()
	var/list/rune_options = list()
	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		rune_options["[rune.get_management_name()] ([REF(rune)])"] = rune
	return rune_options

/proc/select_resurrection_rune_for_admin(prompt = "Choose a resurrection rune.")
	var/list/rune_options = get_resurrection_rune_admin_rune_options()
	if(!rune_options.len)
		to_chat(usr, span_warning("No resurrection runes exist."))
		return

	var/selected_name = input(usr, prompt, "Resurrection Runes") as null|anything in rune_options
	if(!selected_name)
		return
	return rune_options[selected_name]

/proc/get_resurrection_rune_admin_online_mind_options()
	var/list/mind_options = list()
	var/list/seen_minds = list()
	for(var/mob/player_mob as anything in GLOB.player_list)
		var/datum/mind/linked_mind = get_resurrection_rune_admin_mind(player_mob)
		if(!linked_mind)
			continue
		if(linked_mind in seen_minds)
			continue
		seen_minds += linked_mind
		mind_options["[get_resurrection_rune_admin_mind_label(linked_mind)] ([REF(linked_mind)])"] = linked_mind
	return mind_options

/proc/select_resurrection_rune_admin_online_mind(prompt = "Choose a player or ghost.")
	var/list/mind_options = get_resurrection_rune_admin_online_mind_options()
	if(!mind_options.len)
		to_chat(usr, span_warning("No online players with minds found."))
		return

	var/selected_name = input(usr, prompt, "Resurrection Runes") as null|anything in mind_options
	if(!selected_name)
		return
	return mind_options[selected_name]

/proc/get_resurrection_rune_admin_linked_mind_options(obj/structure/resurrection_rune/only_rune = null)
	var/list/mind_options = list()
	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		if(only_rune && rune != only_rune)
			continue
		if(!rune.resrunecontroler)
			continue
		for(var/datum/mind/linked_mind as anything in rune.resrunecontroler.linked_users_minds)
			mind_options["[get_resurrection_rune_admin_mind_label(linked_mind)] - [rune.get_management_name()] ([REF(linked_mind)])"] = linked_mind
	return mind_options

/proc/select_resurrection_rune_admin_linked_mind(obj/structure/resurrection_rune/only_rune = null, prompt = "Choose a linked mind.")
	var/list/mind_options = get_resurrection_rune_admin_linked_mind_options(only_rune)
	if(!mind_options.len)
		to_chat(usr, span_warning("No linked minds found."))
		return

	var/selected_name = input(usr, prompt, "Resurrection Runes") as null|anything in mind_options
	if(!selected_name)
		return
	return mind_options[selected_name]

/proc/get_resurrection_rune_player_panel_section(datum/admins/admin_holder, mob/target)
	if(!admin_holder || !target)
		return ""

	var/datum/mind/linked_mind = get_resurrection_rune_admin_mind(target)
	var/current_link = "No mind"
	if(linked_mind)
		var/obj/structure/resurrection_rune/current_rune = find_resurrection_rune_by_mind(linked_mind)
		current_link = current_rune ? current_rune.get_management_name() : "None"

	return "<br>Resurrection Rune: [current_link] \[<a href='byond://?_src_=holder;[HrefToken()];runeadminplayer=[REF(target)]'>Manage</a>\]"

/proc/handle_resurrection_rune_admin_topic(datum/admins/admin_holder, list/href_list)
	if(!href_list["runeadminplayer"])
		return FALSE
	if(!check_rights(R_ADMIN))
		return TRUE

	var/mob/target = locate(href_list["runeadminplayer"]) in GLOB.mob_list
	if(!target)
		to_chat(usr, span_warning("That mob no longer exists."))
		return TRUE

	admin_holder.manage_player_resurrection_rune(target)
	return TRUE

/datum/admins/proc/manage_player_resurrection_rune(mob/target)
	if(!check_rights(R_ADMIN))
		return
	if(!target)
		to_chat(usr, span_warning("That mob no longer exists."))
		return

	var/datum/mind/linked_mind = get_resurrection_rune_admin_mind(target)
	if(!linked_mind)
		to_chat(usr, span_warning("[target] has no mind to manage."))
		return

	var/obj/structure/resurrection_rune/current_rune = find_resurrection_rune_by_mind(linked_mind)
	var/current_text = current_rune ? current_rune.get_management_name() : "None"
	var/action = input(usr, "Current rune link: [current_text]", "Resurrection Rune: [target]") as null|anything in list("Link to Rune", "Unlink from Runes", "Cancel")
	switch(action)
		if("Link to Rune")
			var/obj/structure/resurrection_rune/selected_rune = select_resurrection_rune_for_admin("Link [get_resurrection_rune_admin_mind_label(linked_mind)] to which rune?")
			if(!selected_rune)
				return
			admin_link_mind_to_resurrection_rune(linked_mind, selected_rune)
		if("Unlink from Runes")
			admin_unlink_mind_from_resurrection_runes(linked_mind)
		else
			return

	show_player_panel_next(target)

/proc/admin_link_mind_to_resurrection_rune(datum/mind/linked_mind, obj/structure/resurrection_rune/rune)
	if(!linked_mind)
		to_chat(usr, span_warning("No mind selected."))
		return FALSE
	if(!rune?.resrunecontroler)
		to_chat(usr, span_warning("That rune has no controller."))
		return FALSE
	if(!rune.resrunecontroler.add_linked_mind(linked_mind))
		to_chat(usr, span_warning("Failed to link [get_resurrection_rune_admin_mind_label(linked_mind)] to [rune.get_management_name()]."))
		return FALSE

	var/target_label = get_resurrection_rune_admin_mind_label(linked_mind)
	log_admin("[key_name(usr)] linked [target_label] to resurrection rune [rune.get_management_name()].")
	message_admins("[key_name_admin(usr)] linked [target_label] to resurrection rune [rune.get_management_name()].")
	to_chat(usr, span_notice("Linked [target_label] to [rune.get_management_name()]."))
	return TRUE

/proc/admin_unlink_mind_from_resurrection_runes(datum/mind/linked_mind)
	if(!linked_mind)
		to_chat(usr, span_warning("No mind selected."))
		return FALSE

	var/obj/structure/resurrection_rune/current_rune = find_resurrection_rune_by_mind(linked_mind)
	if(!current_rune)
		to_chat(usr, span_warning("[get_resurrection_rune_admin_mind_label(linked_mind)] is not linked to any resurrection rune."))
		return FALSE

	var/target_label = get_resurrection_rune_admin_mind_label(linked_mind)
	unlink_mind_from_other_resurrection_runes(linked_mind, null)
	log_admin("[key_name(usr)] unlinked [target_label] from all resurrection runes.")
	message_admins("[key_name_admin(usr)] unlinked [target_label] from all resurrection runes.")
	to_chat(usr, span_notice("Unlinked [target_label] from all resurrection runes."))
	return TRUE

/datum/admins/proc/show_resurrection_rune_links(obj/structure/resurrection_rune/rune)
	if(!check_rights(R_ADMIN))
		return
	if(!rune?.resrunecontroler)
		to_chat(usr, span_warning("That rune has no controller."))
		return

	var/list/rune_info = list("<b>[rune.get_management_name()]</b><br>")
	if(!rune.resrunecontroler.linked_users_minds.len)
		rune_info += "No linked minds.<br>"
	else
		for(var/datum/mind/linked_mind as anything in rune.resrunecontroler.linked_users_minds)
			var/mob/living/carbon/linked_body = rune.resrunecontroler.linked_body_by_mind[linked_mind]
			var/body_text = linked_body ? "[linked_body] ([linked_body.type])" : "no stored carbon body"
			rune_info += "[get_resurrection_rune_admin_mind_label(linked_mind)] - [body_text]<br>"

	usr << browse(rune_info.Join(), "window=resurrection_rune_links;size=600x420")

/datum/admins/proc/manage_selected_resurrection_rune(obj/structure/resurrection_rune/rune)
	if(!check_rights(R_ADMIN))
		return
	if(!rune?.resrunecontroler)
		to_chat(usr, span_warning("That rune has no controller."))
		return

	var/toggle_label = rune.disabled_res ? "Enable Resurrections" : "Disable Resurrections"
	var/action = input(usr, "Manage [rune.get_management_name()].", "Resurrection Runes") as null|anything in list("View Linked Minds", "Link Player/Mind", "Unlink Linked Mind", toggle_label, "Jump to Rune", "Cancel")
	switch(action)
		if("View Linked Minds")
			show_resurrection_rune_links(rune)
		if("Link Player/Mind")
			var/datum/mind/linked_mind = select_resurrection_rune_admin_online_mind("Link which player or ghost to [rune.get_management_name()]?")
			if(linked_mind)
				admin_link_mind_to_resurrection_rune(linked_mind, rune)
		if("Unlink Linked Mind")
			var/datum/mind/linked_mind = select_resurrection_rune_admin_linked_mind(rune, "Unlink which mind from [rune.get_management_name()]?")
			if(linked_mind)
				admin_unlink_mind_from_resurrection_runes(linked_mind)
		if("Enable Resurrections")
			rune.disabled_res = FALSE
			log_admin("[key_name(usr)] enabled resurrection rune [rune.get_management_name()].")
			message_admins("[key_name_admin(usr)] enabled resurrection rune [rune.get_management_name()].")
		if("Disable Resurrections")
			rune.disabled_res = TRUE
			rune.resrunecontroler.clear_all_linked_user_rescue_states()
			rune.resrunecontroler.clear_all_ghost_return_actions()
			log_admin("[key_name(usr)] disabled resurrection rune [rune.get_management_name()].")
			message_admins("[key_name_admin(usr)] disabled resurrection rune [rune.get_management_name()].")
		if("Jump to Rune")
			var/turf/rune_turf = get_turf(rune)
			if(rune_turf)
				usr.client.jumptoturf(rune_turf)
		else
			return

/datum/admins/proc/manage_resurrection_runes()
	if(!check_rights(R_ADMIN))
		return

	var/action = input(usr, "What do you want to manage?", "Resurrection Runes") as null|anything in list("Manage a Rune", "Link Player/Mind", "Unlink Linked Mind", "Cancel")
	switch(action)
		if("Manage a Rune")
			var/obj/structure/resurrection_rune/rune = select_resurrection_rune_for_admin()
			if(rune)
				manage_selected_resurrection_rune(rune)
		if("Link Player/Mind")
			var/datum/mind/linked_mind = select_resurrection_rune_admin_online_mind()
			if(!linked_mind)
				return
			var/obj/structure/resurrection_rune/rune = select_resurrection_rune_for_admin("Link [get_resurrection_rune_admin_mind_label(linked_mind)] to which rune?")
			if(rune)
				admin_link_mind_to_resurrection_rune(linked_mind, rune)
		if("Unlink Linked Mind")
			var/datum/mind/linked_mind = select_resurrection_rune_admin_linked_mind()
			if(linked_mind)
				admin_unlink_mind_from_resurrection_runes(linked_mind)
		else
			return

/client/proc/manage_resurrection_runes()
	set category = "Admin.Admin"
	set name = "Manage Resurrection Runes"
	set desc = "Manage resurrection rune links and rune state."

	if(!check_rights(R_ADMIN))
		return

	holder?.manage_resurrection_runes()

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
#undef RUNE_MOB_ERP_ESCAPE_ACTION_DURATION
