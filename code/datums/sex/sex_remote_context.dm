/datum/sex_remote_context
	var/datum/weakref/caster_ref
	var/datum/weakref/target_ref
	var/datum/sex_scene/scene
	var/expires_at = 0
	var/range = 7
	var/requires_range = TRUE
	var/requires_line_of_sight = TRUE
	var/line_of_sight_break_grace = 20 SECONDS
	var/line_of_sight_lost_at = 0
	var/check_interval = 2 SECONDS
	/// TRUE lets actions keep their ordinary visible messages and visual effects through this context.
	var/allows_visible_messages = FALSE

/datum/sex_remote_context/New(mob/living/caster, mob/living/target, duration = 2 MINUTES, range_override = 7)
	. = ..()
	if(caster)
		caster_ref = WEAKREF(caster)
		RegisterSignal(caster, COMSIG_LIVING_DEATH, PROC_REF(on_participant_invalidated))
	if(target)
		target_ref = WEAKREF(target)
		if(target != caster)
			RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_participant_invalidated))
	range = range_override
	if(duration > 0)
		expires_at = world.time + duration
		addtimer(CALLBACK(src, PROC_REF(check_validity)), min(duration, check_interval))

/datum/sex_remote_context/Destroy(force, ...)
	clear_all_overlays()
	if(scene && !QDELETED(scene))
		scene.remove_remote_context(src)
	var/mob/living/caster = get_caster()
	if(caster)
		UnregisterSignal(caster, COMSIG_LIVING_DEATH)
	var/mob/living/target = get_target()
	if(target)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)
	caster_ref = null
	target_ref = null
	scene = null
	return ..()

/datum/sex_remote_context/proc/get_caster()
	return caster_ref?.resolve()

/datum/sex_remote_context/proc/get_target()
	return target_ref?.resolve()

/datum/sex_remote_context/proc/is_valid(datum/sex_scene/owning_scene)
	if(owning_scene && scene && owning_scene != scene)
		return FALSE
	var/mob/living/caster = get_caster()
	var/mob/living/remote_target = get_target()
	if(QDELETED(caster) || QDELETED(remote_target))
		return FALSE
	if(!caster.loc || !remote_target.loc)
		return FALSE
	if(owning_scene && (!(caster in owning_scene.participants) || !(remote_target in owning_scene.participants)))
		return FALSE
	if(caster.stat != CONSCIOUS)
		return FALSE
	if(remote_target.stat == DEAD)
		return FALSE
	if(expires_at && world.time > expires_at)
		return FALSE
	if(!requires_line_of_sight && requires_range && get_dist(caster, remote_target) > range)
		return FALSE
	if(!has_required_line_of_sight(caster, remote_target))
		return FALSE
	return TRUE

/datum/sex_remote_context/proc/has_required_line_of_sight(mob/living/caster, mob/living/remote_target)
	if(!requires_line_of_sight)
		line_of_sight_lost_at = 0
		return TRUE
	if(can_see(caster, remote_target, range))
		line_of_sight_lost_at = 0
		return TRUE
	if(line_of_sight_break_grace <= 0)
		return FALSE
	if(line_of_sight_lost_at <= 0)
		line_of_sight_lost_at = world.time
		return TRUE
	return world.time < line_of_sight_lost_at + line_of_sight_break_grace

/datum/sex_remote_context/proc/allows_action(datum/sex_action/action)
	return FALSE

/datum/sex_remote_context/proc/show_action_overlay(datum/sex_action/action)
	return FALSE

/datum/sex_remote_context/proc/show_action_message(datum/sex_action/action, message_stage)
	return FALSE

/datum/sex_remote_context/proc/clear_action_overlay(datum/sex_action/action)
	return

/datum/sex_remote_context/proc/clear_all_overlays()
	return

/datum/sex_remote_context/proc/get_active_overlay_count()
	return 0

/datum/sex_remote_context/proc/check_validity()
	if(QDELETED(src))
		return
	if(!is_valid(scene))
		clear_from_scene()
		return
	addtimer(CALLBACK(src, PROC_REF(check_validity)), check_interval)

/datum/sex_remote_context/proc/clear_from_scene()
	if(scene && !QDELETED(scene))
		scene.remove_remote_context(src)
	qdel(src)

/datum/sex_remote_context/proc/on_participant_invalidated()
	SIGNAL_HANDLER
	clear_from_scene()

/datum/sex_remote_context/mage_hand
	#define MAGE_HAND_RESIST_PROMPT_INTERVAL (12 SECONDS)
	#define MAGE_HAND_RESIST_COOLDOWN (5 SECONDS)
	#define MAGE_HAND_RESIST_STAMINA_FRACTION 0.1
	#define MAGE_HAND_RESIST_COOLDOWN_REFUND (30 SECONDS)

	var/list/active_overlay_counts = list()
	var/list/mutable_appearance/active_overlays = list()
	var/list/action_overlay_zones = list()
	/// Zone to the timer id handing its intro animation over to the looping state.
	var/list/overlay_start_timers = list()
	/// Bind zone to the conjured restraint holding it, or TRUE for binds that need no item.
	var/list/active_binds = list()
	/// The caster's grip on every active bind. Losing it dispels them all.
	var/obj/item/arcyne_binders/binder
	var/next_resist_time = 0
	var/next_resist_prompt_time = 0

/datum/sex_remote_context/mage_hand/Destroy(force, ...)
	release_all_binds()
	return ..()

/datum/sex_remote_context/mage_hand/allows_action(datum/sex_action/action)
	return !!action?.mage_hand_allowed

/datum/sex_remote_context/mage_hand/show_action_message(datum/sex_action/action, message_stage)
	if(!action || !is_valid(scene))
		return FALSE
	var/mob/living/caster = get_caster()
	var/mob/living/remote_target = get_target()
	if(!caster || !remote_target)
		return FALSE

	if(message_stage == MAGE_HAND_ACTION_MESSAGE_PERFORM)
		if(world.time < action.next_message_time)
			return FALSE
		var/speed_time = rand(10, 100 - action.speed * 10)
		action.next_message_time = world.time + speed_time

	var/caster_message = sanitize_action_message(get_action_message(action, message_stage, FALSE), caster)
	var/target_message = sanitize_action_message(get_action_message(action, message_stage, TRUE), caster)
	if(caster_message)
		to_chat(caster, format_action_message(caster_message, action))
	if(target_message && remote_target != caster)
		to_chat(remote_target, format_action_message(target_message, action))
	return TRUE

/datum/sex_remote_context/mage_hand/proc/get_action_message(datum/sex_action/action, message_stage, target_perspective = FALSE)
	if(!action)
		return null
	var/action_phrase = get_action_phrase(action, target_perspective)
	if(!action_phrase)
		return null
	switch(message_stage)
		if(MAGE_HAND_ACTION_MESSAGE_START)
			return "Someone's ghostly hand starts [action_phrase]."
		if(MAGE_HAND_ACTION_MESSAGE_PERFORM)
			return "Someone's ghostly hand continues [action_phrase]."
		if(MAGE_HAND_ACTION_MESSAGE_FINISH)
			return "Someone's ghostly hand stops [action_phrase]."
	return null

/datum/sex_remote_context/mage_hand/proc/get_action_phrase(datum/sex_action/action, target_perspective = FALSE)
	if(!action?.name)
		return null
	var/phrase = LOWER_TEXT(action.remote_phrase || action.name)
	var/mob/living/remote_target = get_target()
	if(target_perspective)
		phrase = replacetext(phrase, "their", "my")
		phrase = replacetext(phrase, "them", "me")
	else
		phrase = replacetext(phrase, "their", "[remote_target]'s")
		phrase = replacetext(phrase, "them", "[remote_target]")
	return gerundize_action_phrase(phrase)

/datum/sex_remote_context/mage_hand/proc/gerundize_action_phrase(phrase)
	if(!phrase)
		return null
	if(findtext(phrase, "play with ") == 1)
		return "playing with [copytext(phrase, length("play with ") + 1)]"

	var/space_position = findtext(phrase, " ")
	var/verb = space_position ? copytext(phrase, 1, space_position) : phrase
	var/rest = space_position ? copytext(phrase, space_position) : ""
	return "[gerundize_action_verb(verb)][rest]"

/datum/sex_remote_context/mage_hand/proc/gerundize_action_verb(verb)
	switch(verb)
		if("finger")
			return "fingering"
		if("rub")
			return "rubbing"
		if("slap")
			return "slapping"
		if("spank")
			return "spanking"
		if("stroke")
			return "stroking"
		if("jerk")
			return "jerking"
		if("play")
			return "playing"
	if(copytext(verb, length(verb), length(verb) + 1) == "e")
		return "[copytext(verb, 1, length(verb))]ing"
	return "[verb]ing"

/datum/sex_remote_context/mage_hand/proc/format_action_message(message, datum/sex_action/action)
	if(!message)
		return null
	if(action)
		return action.spanify_force(message)
	return span_notice(message)

/datum/sex_remote_context/mage_hand/proc/sanitize_action_message(message, mob/living/source)
	if(!message || !source)
		return message

	var/list/source_names = list()
	if(iscarbon(source))
		var/mob/living/carbon/carbon_source = source
		add_portal_message_name_candidate(source_names, carbon_source.get_visible_name(""))
		add_portal_message_name_candidate(source_names, carbon_source.get_face_name("", null, FALSE))
	else
		add_portal_message_name_candidate(source_names, source.get_visible_name())
	add_portal_message_name_candidate(source_names, source.real_name)
	add_portal_message_name_candidate(source_names, source.name)
	add_portal_message_name_candidate(source_names, "[source]")

	var/sanitized_message = message
	for(var/source_name in source_names)
		sanitized_message = replacetext(sanitized_message, source_name, "Someone")
	return sanitized_message

/datum/sex_remote_context/mage_hand/show_action_overlay(datum/sex_action/action)
	if(!action || !is_valid(scene))
		return FALSE
	var/zone = get_action_overlay_zone(action)
	if(!add_zone_overlay(zone))
		return FALSE
	action_overlay_zones[action] = zone
	return TRUE

/datum/sex_remote_context/mage_hand/clear_action_overlay(datum/sex_action/action)
	if(!action)
		return
	var/zone = action_overlay_zones[action] || get_action_overlay_zone(action)
	action_overlay_zones -= action
	remove_zone_overlay(zone)

/datum/sex_remote_context/mage_hand/clear_all_overlays()
	for(var/zone in active_overlays.Copy())
		clear_zone_overlay(zone)
	active_overlay_counts.Cut()
	active_overlays.Cut()
	action_overlay_zones.Cut()
	overlay_start_timers.Cut()

/// Claims one reference on a zone's hand, drawing it if nothing was holding it yet.
/datum/sex_remote_context/mage_hand/proc/add_zone_overlay(zone)
	if(!zone || !GLOB.mage_hand_zone_sprites[zone] || !ishuman(get_target()))
		return FALSE
	active_overlay_counts[zone] = (active_overlay_counts[zone] || 0) + 1
	if(active_overlays[zone])
		return TRUE
	return apply_zone_overlay(zone, TRUE)

/// Drops one reference on a zone's hand, cutting it once nothing holds it.
/datum/sex_remote_context/mage_hand/proc/remove_zone_overlay(zone)
	if(!zone || !active_overlay_counts[zone])
		return
	active_overlay_counts[zone]--
	if(active_overlay_counts[zone] > 0)
		return
	active_overlay_counts -= zone
	clear_zone_overlay(zone)

/// Draws the zone's hand. `animate_start` plays the one-shot intro and schedules the swap to the looping state.
/datum/sex_remote_context/mage_hand/proc/apply_zone_overlay(zone, animate_start = FALSE)
	var/mob/living/remote_target = get_target()
	if(!ishuman(remote_target))
		return FALSE
	var/sprite = GLOB.mage_hand_zone_sprites[zone]
	if(!sprite)
		return FALSE

	var/timer_id = overlay_start_timers[zone]
	if(timer_id)
		deltimer(timer_id)
		overlay_start_timers -= zone

	var/mutable_appearance/previous_overlay = active_overlays[zone]
	if(previous_overlay)
		remote_target.cut_overlay(previous_overlay)

	var/state = "[get_overlay_prefix(remote_target)]_[animate_start ? "start_" : ""][sprite]"
	var/mutable_appearance/hand_overlay = mutable_appearance(MAGE_HAND_OVERLAY_ICON, state, ABOVE_MOB_LAYER)
	hand_overlay.alpha = MAGE_HAND_OVERLAY_ALPHA
	active_overlays[zone] = hand_overlay
	remote_target.add_overlay(hand_overlay)

	if(animate_start)
		overlay_start_timers[zone] = addtimer(CALLBACK(src, PROC_REF(finish_start_animation), zone), GLOB.mage_hand_start_durations[sprite], TIMER_STOPPABLE)
	return TRUE

/datum/sex_remote_context/mage_hand/proc/finish_start_animation(zone)
	overlay_start_timers -= zone
	if(!active_overlays[zone])
		return
	apply_zone_overlay(zone, FALSE)

/// Cuts the zone's appearance and cancels any pending intro handoff, leaving its reference count alone.
/datum/sex_remote_context/mage_hand/proc/clear_zone_overlay(zone)
	var/timer_id = overlay_start_timers[zone]
	if(timer_id)
		deltimer(timer_id)
		overlay_start_timers -= zone
	var/mutable_appearance/hand_overlay = active_overlays[zone]
	if(hand_overlay)
		var/mob/living/remote_target = get_target()
		if(remote_target)
			remote_target.cut_overlay(hand_overlay)
	active_overlays -= zone

/// Mirrors the worn clothing state convention: base name, then _f for the female set, then _dwarf for the dwarf set.
/datum/sex_remote_context/mage_hand/proc/get_overlay_prefix(mob/living/carbon/human/wearer)
	var/prefix = "arcyne_binders"
	var/datum/species/species = wearer.dna?.species
	if(!species)
		return prefix
	if(wearer.get_body_cut() == BODY_CUT_FEMININE)
		prefix += "_f"
	if(species.custom_clothes && ((species.custom_id || species.id) == SPEC_ID_DWARF))
		prefix += "_dwarf"
	return prefix

/datum/sex_remote_context/mage_hand/get_active_overlay_count()
	var/count = 0
	for(var/zone in active_overlay_counts)
		count += active_overlay_counts[zone]
	return count

/datum/sex_remote_context/mage_hand/proc/get_action_overlay_zone(datum/sex_action/action)
	if(action.mage_hand_overlay_zone)
		return action.mage_hand_overlay_zone
	if(action.hole_id == ORGAN_SLOT_BREASTS)
		return MAGE_HAND_ZONE_CHEST
	if(action.hole_id == ORGAN_SLOT_ANUS)
		return MAGE_HAND_ZONE_BUTT
	if(action.hole_id == ORGAN_SLOT_PENIS || action.hole_id == ORGAN_SLOT_VAGINA)
		return MAGE_HAND_ZONE_GROIN
	if(action.target_menu_zone_mask & SEX_UI_ZONE_MOUTH)
		return MAGE_HAND_ZONE_MOUTH
	if(action.target_menu_zone_mask & SEX_UI_ZONE_BODY)
		return MAGE_HAND_ZONE_BODY
	return MAGE_HAND_ZONE_BODY

/// Conjures the bind for `zone`, giving the caster a binder to hold it with. Returns TRUE if the target ended up bound.
/datum/sex_remote_context/mage_hand/proc/try_bind(zone)
	if(!zone || active_binds[zone] || !is_valid(scene))
		return FALSE
	var/mob/living/caster = get_caster()
	var/mob/living/carbon/remote_target = get_target()
	if(!caster || !iscarbon(remote_target))
		return FALSE
	if(!ensure_binder(caster))
		return FALSE
	if(!conjure_bind(zone, remote_target))
		if(!length(active_binds))
			dispel_binder()
		return FALSE
	add_zone_overlay(zone)
	return TRUE

/// Applies the mechanical half of a bind. Callers own the overlay and the binder.
/datum/sex_remote_context/mage_hand/proc/conjure_bind(zone, mob/living/carbon/remote_target)
	switch(zone)
		if(MAGE_HAND_ZONE_ARMS)
			if(remote_target.handcuffed || remote_target.num_hands < 2)
				return FALSE
			var/obj/item/restraints/arcyne/shackles = conjure_shackles(zone, remote_target)
			remote_target.set_handcuffed(shackles)
			remote_target.update_handcuffed()
			active_binds[zone] = shackles
			return TRUE
		if(MAGE_HAND_ZONE_LEGS)
			if(remote_target.legcuffed || remote_target.num_legs < 2)
				return FALSE
			var/obj/item/restraints/arcyne/shackles = conjure_shackles(zone, remote_target)
			remote_target.legcuffed = shackles
			remote_target.add_movespeed_modifier(MOVESPEED_ID_LEGCUFF_SLOWDOWN, multiplicative_slowdown = shackles.legcuff_multiplicative_slowdown)
			remote_target.update_inv_legcuffed()
			active_binds[zone] = shackles
			return TRUE
		if(MAGE_HAND_ZONE_EYES)
			remote_target.become_blind(MAGE_HAND_BLIND_TRAIT)
			active_binds[zone] = TRUE
			return TRUE
	return FALSE

/datum/sex_remote_context/mage_hand/proc/conjure_shackles(zone, mob/living/carbon/remote_target)
	var/obj/item/restraints/arcyne/shackles = new(remote_target)
	shackles.context_ref = WEAKREF(src)
	shackles.bind_zone = zone
	return shackles

/// Undoes one bind. The restraint's own Destroy() reports back through on_bind_lost().
/datum/sex_remote_context/mage_hand/proc/release_bind(zone)
	var/bind = active_binds[zone]
	if(!bind)
		return
	active_binds -= zone
	remove_zone_overlay(zone)
	if(zone == MAGE_HAND_ZONE_EYES)
		var/mob/living/remote_target = get_target()
		remote_target?.cure_blind(MAGE_HAND_BLIND_TRAIT)
		return
	if(istype(bind, /obj/item/restraints/arcyne))
		qdel(bind)

/datum/sex_remote_context/mage_hand/proc/release_all_binds()
	for(var/zone in active_binds.Copy())
		release_bind(zone)
	dispel_binder()

/// Called by a conjured restraint that left the target on its own, most often because they broke out.
/datum/sex_remote_context/mage_hand/proc/on_bind_lost(zone)
	if(!zone || !active_binds[zone])
		return
	active_binds -= zone
	remove_zone_overlay(zone)
	if(!length(active_binds))
		dispel_binder()

/// Builds the target-only counterplay prompt for the active Mage Hand tether.
/datum/sex_remote_context/mage_hand/proc/build_resist_prompt()
	var/target = get_target()
	if(!target)
		return
	return span_warning("A ghostly hand is exploring you. <a href='byond://?src=[REF(src)];pull_away=1'>Pull away!</a>")

/// Sends the target a throttled prompt to resist the Mage Hand tether.
/datum/sex_remote_context/mage_hand/proc/send_resist_prompt(force = FALSE)
	if(QDELETED(src) || !is_valid(scene))
		return
	var/mob/living/remote_target = get_target()
	if(!remote_target?.client)
		return
	if(!force && world.time < next_resist_prompt_time)
		return
	next_resist_prompt_time = world.time + MAGE_HAND_RESIST_PROMPT_INTERVAL
	to_chat(remote_target, build_resist_prompt())

/// Stops all active sexual actions using this remote context.
/datum/sex_remote_context/mage_hand/proc/interrupt_remote_actions()
	if(!scene || QDELETED(scene))
		return
	for(var/datum/sex_action/action as anything in scene.active_actions.Copy())
		if(action.remote_context != src)
			continue
		scene.stop_action(action)

/// Attempts to pull the target away from the Mage Hand tether.
/datum/sex_remote_context/mage_hand/proc/try_pull_away(mob/living/resisting)
	if(!resisting || resisting != get_target() || !is_valid(scene))
		return FALSE
	if(resisting.stat != CONSCIOUS)
		return FALSE
	if(world.time < next_resist_time)
		to_chat(resisting, span_warning("I need a moment before I can pull away again."))
		return FALSE
	if(resisting.stamina >= resisting.maximum_stamina)
		to_chat(resisting, span_warning("I am too exhausted to fight the ghostly hand effectively."))
		return FALSE

	next_resist_time = world.time + MAGE_HAND_RESIST_COOLDOWN
	resisting.adjust_stamina(max(1, resisting.maximum_stamina * MAGE_HAND_RESIST_STAMINA_FRACTION))
	var/result = roll_clench(resisting, get_caster())
	interrupt_remote_actions()

	if(result == CLENCH_RESULT_STOP)
		var/mob/living/caster = get_caster()
		var/datum/action/cooldown/spell/mage_hand/mage_hand
		if(caster)
			mage_hand = caster.get_spell(/datum/action/cooldown/spell/mage_hand, TRUE)
		if(mage_hand)
			mage_hand.next_use_time = max(world.time, mage_hand.next_use_time - MAGE_HAND_RESIST_COOLDOWN_REFUND)
			mage_hand.build_all_button_icons()
		resisting.visible_message(
			span_warning("[resisting] tears free of the ghostly hand!"),
			span_notice("I tear myself free of the ghostly hand!"),
		)
		if(caster)
			to_chat(caster, span_warning("[resisting] tears free of my Mage Hand! Its cooldown recovers slightly."))
		clear_from_scene()
		return TRUE

	if(result == CLENCH_RESULT_INTERRUPT)
		resisting.visible_message(
			span_warning("[resisting] shoves at the ghostly hand and breaks its rhythm!"),
			span_notice("I shove at the ghostly hand and break its rhythm!"),
		)
		var/mob/living/caster = get_caster()
		if(caster)
			to_chat(caster, span_warning("[resisting] breaks the rhythm of my Mage Hand."))
		send_resist_prompt(TRUE)
		return TRUE

	to_chat(resisting, span_warning("I struggle against the ghostly hand, but it keeps its hold."))
	send_resist_prompt(TRUE)
	return TRUE

/datum/sex_remote_context/mage_hand/Topic(href, list/href_list)
	. = ..()
	if(href_list["pull_away"])
		try_pull_away(usr)

#undef MAGE_HAND_RESIST_PROMPT_INTERVAL
#undef MAGE_HAND_RESIST_COOLDOWN
#undef MAGE_HAND_RESIST_STAMINA_FRACTION
#undef MAGE_HAND_RESIST_COOLDOWN_REFUND

/// Puts a binder in the caster's hand if they aren't already holding one.
/datum/sex_remote_context/mage_hand/proc/ensure_binder(mob/living/caster)
	if(binder && !QDELETED(binder))
		if(binder.loc == caster)
			return TRUE
		// It left their hands without telling us. Unravel everything rather than orphan a live binder.
		dispel_binder()
	binder = null
	var/obj/item/arcyne_binders/new_binder = new(caster.drop_location())
	if(!caster.put_in_hands(new_binder))
		qdel(new_binder)
		to_chat(caster, span_warning("I have no free hand to hold the binding with."))
		return FALSE
	new_binder.context_ref = WEAKREF(src)
	binder = new_binder
	return TRUE

/datum/sex_remote_context/mage_hand/proc/dispel_binder()
	var/obj/item/arcyne_binders/held_binder = binder
	binder = null
	if(held_binder && !QDELETED(held_binder))
		held_binder.dispel()

/proc/clear_mage_hand_tethers_for(mob/living/caster)
	if(!caster)
		return
	var/list/contexts_to_clear = caster.sex_scene?.remote_contexts?.Copy()
	for(var/datum/sex_remote_context/mage_hand/context as anything in contexts_to_clear)
		if(!istype(context))
			continue
		if(context.get_caster() != caster)
			continue
		qdel(context)
