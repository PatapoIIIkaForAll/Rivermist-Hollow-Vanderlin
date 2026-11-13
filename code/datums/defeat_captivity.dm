/// Pocket template used by Defeat captivity profiles. The first implementation deliberately reuses
/// the existing intimate dungeon layout: profile ownership and lifecycle are independent from art,
/// so dedicated goblin, carrier, and dragon templates can replace it without rewriting captivity.
/datum/map_template/pocket/defeat_captivity
	name = "Defeat Captivity"
	id = "pocket_defeat_captivity"
	mappath = "_maps/templates/pockets/kidnap_lairs/wolf_lair.dmm"
	lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	idle_timeout = 0
	persistence_mode = POCKET_PERSISTENCE_NONE
	instance_type = /datum/pocket_dimension/defeat_captivity
	exit_structure_type = /obj/structure/pocket_dimension_exit/hole

/datum/map_template/pocket/defeat_captivity/wolf
	name = "Wolf Defeat Captivity"
	id = "pocket_defeat_captivity_wolf"
	mappath = "_maps/templates/pockets/kidnap_lairs/wolf_lair.dmm"

/datum/map_template/pocket/defeat_captivity/bandit
	name = "Bandit Defeat Captivity"
	id = "pocket_defeat_captivity_bandit"
	mappath = "_maps/templates/pockets/kidnap_lairs/bandit_lair.dmm"

/datum/map_template/pocket/defeat_captivity/greenskin
	name = "Greenskin Defeat Captivity"
	id = "pocket_defeat_captivity_greenskin"
	mappath = "_maps/templates/pockets/kidnap_lairs/goblin_lair.dmm"

/// Declarative policy for one family of captivity pockets. Content chooses a subtype; the core owns
/// keying, admission, access, ejection, and lifecycle without trying to infer a fuzzy "encounter".
/datum/defeat_captivity_profile
	var/ownership_mode = DEFEAT_CAPTIVITY_SHARED
	var/stable_key = "default"
	var/template_type = /datum/map_template/pocket/defeat_captivity
	var/capacity = 8
	var/access_rule = DEFEAT_CAPTIVITY_ACCESS_RELEASED
	var/delete_when_empty = TRUE
	var/display_name = "captivity pocket"
	/// New arrivals are shackled to a free lair anchor when the map has one.
	var/chains_captives = TRUE

/datum/defeat_captivity_profile/New(stable_key_override)
	if(stable_key_override)
		stable_key = "[stable_key_override]"
	return ..()

/datum/defeat_captivity_profile/proc/build_instance_key(mob/living/captor, mob/living/captive)
	switch(ownership_mode)
		if(DEFEAT_CAPTIVITY_CARRIER)
			if(!captor || QDELETED(captor))
				return null
			return "[DEFEAT_CAPTIVITY_INSTANCE_PREFIX]::[type]::carrier::[REF(captor)]"
		if(DEFEAT_CAPTIVITY_CAPTIVE)
			if(!captive || QDELETED(captive))
				return null
			return "[DEFEAT_CAPTIVITY_INSTANCE_PREFIX]::[type]::captive::[REF(captive)]"
	return "[DEFEAT_CAPTIVITY_INSTANCE_PREFIX]::[type]::shared::[stable_key]"

/datum/defeat_captivity_profile/proc/get_pocket_holder(mob/living/captor)
	if(ownership_mode == DEFEAT_CAPTIVITY_CARRIER)
		return captor
	return null

/datum/defeat_captivity_profile/proc/get_or_create_instance(mob/living/captor, mob/living/captive)
	var/instance_key = build_instance_key(captor, captive)
	if(!instance_key || !SSpocket_dimensions)
		return null
	var/atom/pocket_holder = get_pocket_holder(captor)
	var/datum/pocket_dimension/defeat_captivity/instance = SSpocket_dimensions.get_or_create_instance(
		instance_key,
		template_type,
		POCKET_LIFECYCLE_KEEP_LOADED,
		0,
		pocket_holder,
	)
	if(!istype(instance))
		return null
	instance.configure_profile(type, pocket_holder)
	return instance

/datum/defeat_captivity_profile/proc/can_admit(datum/pocket_dimension/defeat_captivity/instance)
	return instance && instance.captive_count() < capacity

/// Central access hook for future breachable entrances and carrier interactions.
/datum/defeat_captivity_profile/proc/can_access(mob/living/user, access_action, datum/component/kidnap_captivity/captivity, datum/pocket_dimension/defeat_captivity/instance)
	if(!user)
		return FALSE
	switch(access_rule)
		if(DEFEAT_CAPTIVITY_ACCESS_RELEASED)
			if(captivity)
				// KO already prevents use_exit() interaction. Do not layer a component-state gate
				// over it: external recovery must never leave an awake captive trapped by stale state.
				return user == captivity.parent
			// Uncaptured rescuers and native inhabitants may leave a shared lair normally.
			return TRUE
		if(DEFEAT_CAPTIVITY_ACCESS_CAPTOR)
			if(captivity)
				return user == captivity.resolve_captor()
			return user == instance?.carrier_ref?.resolve()
	return FALSE

/datum/defeat_captivity_profile/proc/get_access_denial_message(mob/living/user)
	if(access_rule == DEFEAT_CAPTIVITY_ACCESS_RELEASED)
		return "Defeat still holds you too tightly to cross the threshold."
	return "The folded boundary seals itself against you."

/// Shared profiles may override this with a real exterior anchor. The current legacy markers are
/// inside the old static lairs, so using them as an exterior would only recreate the persistence bug.
/datum/defeat_captivity_profile/proc/get_configured_exterior(datum/component/kidnap_captivity/captivity)
	return null

/datum/defeat_captivity_profile/proc/get_wilds_destination(datum/component/kidnap_captivity/captivity)
	return get_random_kidnap_wilds_turf()

/datum/defeat_captivity_profile/proc/get_ejection_destination(datum/component/kidnap_captivity/captivity, datum/pocket_dimension/defeat_captivity/instance)
	var/turf/destination
	switch(ownership_mode)
		if(DEFEAT_CAPTIVITY_CARRIER)
			destination = instance?.forced_teardown_destination
			if(!is_valid_ejection_turf(destination, instance))
				var/mob/living/captor = captivity.resolve_captor()
				destination = get_turf(captor)
			if(!is_valid_ejection_turf(destination, instance))
				destination = captivity.get_saved_origin()
			if(!is_valid_ejection_turf(destination, instance))
				destination = get_wilds_destination(captivity)
		if(DEFEAT_CAPTIVITY_CAPTIVE)
			destination = get_wilds_destination(captivity)
			if(!is_valid_ejection_turf(destination, instance))
				destination = captivity.get_saved_origin()
		else
			// Wilds before the saved capture turf: a shared lair's capture point is usually the middle of
			// the camp that took you, so returning there hands the escapee straight back to their captors.
			// A profile with a real exterior anchor still wins; the capture turf is only a last resort.
			destination = get_configured_exterior(captivity)
			if(!is_valid_ejection_turf(destination, instance))
				destination = get_wilds_destination(captivity)
			if(!is_valid_ejection_turf(destination, instance))
				destination = captivity.get_saved_origin()

	if(!is_valid_ejection_turf(destination, instance))
		destination = find_safe_turf()
	if(!is_valid_ejection_turf(destination, instance))
		return null
	return destination

/datum/defeat_captivity_profile/proc/is_valid_ejection_turf(turf/destination, datum/pocket_dimension/defeat_captivity/instance)
	if(!isturf(destination) || QDELETED(destination))
		return FALSE
	return !instance?.contains_turf(destination)

/datum/defeat_captivity_profile/shared
	ownership_mode = DEFEAT_CAPTIVITY_SHARED
	access_rule = DEFEAT_CAPTIVITY_ACCESS_RELEASED
	capacity = 8
	// These are stable places, not disposable encounter rooms. Once created, they remain loaded so
	// later captives return to the same lair instead of rebuilding and scattering its contents.
	delete_when_empty = FALSE

/datum/defeat_captivity_profile/shared/greenskin
	stable_key = "greenskin_lair"
	display_name = "greenskin lair"
	template_type = /datum/map_template/pocket/defeat_captivity/greenskin

/datum/defeat_captivity_profile/shared/wolfden
	stable_key = "wolfden_lair"
	display_name = "wolf den"
	template_type = /datum/map_template/pocket/defeat_captivity/wolf

/datum/defeat_captivity_profile/shared/bandit
	stable_key = "bandit_lair"
	display_name = "bandit lair"
	template_type = /datum/map_template/pocket/defeat_captivity/bandit

/// One carrier owns one active pocket for its entire lifetime. Empty carrier pockets remain ready for
/// another swallow; deletion of the carrier tears the pocket down at the carrier's last turf.
/datum/defeat_captivity_profile/carrier
	ownership_mode = DEFEAT_CAPTIVITY_CARRIER
	access_rule = DEFEAT_CAPTIVITY_ACCESS_CAPTOR
	capacity = 4
	delete_when_empty = FALSE
	display_name = "carrier pocket"
	chains_captives = FALSE

/// One isolated pocket per victim. Contextual release deliberately tries the wilds before the saved
/// capture turf so future dragons cannot eject prisoners into a still-hostile encounter by default.
/datum/defeat_captivity_profile/per_captive
	ownership_mode = DEFEAT_CAPTIVITY_CAPTIVE
	access_rule = DEFEAT_CAPTIVITY_ACCESS_SEALED
	capacity = 1
	delete_when_empty = TRUE
	display_name = "isolated captivity pocket"

/// Pocket-dimension specialization that tracks only captivity components, using weak references.
/// It does no polling: membership changes, movement, owner deletion, and subsystem teardown drive it.
/datum/pocket_dimension/defeat_captivity
	var/profile_type = /datum/defeat_captivity_profile
	var/list/captive_refs = list()
	var/datum/weakref/carrier_ref
	var/turf/forced_teardown_destination
	var/teardown_started = FALSE
	/// Surrendered captives left here as distress NPCs, weakly keyed by REF.
	var/list/surrendered_refs = list()
	/// An emptied pocket that should close once its surrendered captives are gone.
	var/close_after_surrendered = FALSE

/datum/pocket_dimension/defeat_captivity/Destroy(force)
	// Parent Destroy dispatches eject_teardown_contents() dynamically. Run our contextual pass while
	// membership and carrier context still exist; teardown_started makes the parent call a no-op.
	eject_teardown_contents()
	var/atom/carrier = carrier_ref?.resolve()
	if(carrier)
		UnregisterSignal(carrier, COMSIG_PARENT_QDELETING)
	carrier_ref = null
	captive_refs = null
	surrendered_refs = null
	forced_teardown_destination = null
	return ..()

/datum/pocket_dimension/defeat_captivity/proc/configure_profile(new_profile_type, atom/pocket_holder)
	if(ispath(new_profile_type, /datum/defeat_captivity_profile))
		profile_type = new_profile_type
	if(!pocket_holder || QDELETED(pocket_holder) || carrier_ref)
		return
	carrier_ref = WEAKREF(pocket_holder)
	RegisterSignal(pocket_holder, COMSIG_PARENT_QDELETING, PROC_REF(on_carrier_qdeleting))

/datum/pocket_dimension/defeat_captivity/proc/on_carrier_qdeleting(datum/source)
	SIGNAL_HANDLER
	forced_teardown_destination = get_turf(source)
	if(SSpocket_dimensions)
		SSpocket_dimensions.delete_instance(src, "Your captor is destroyed, and the pocket convulses around you!", forced_teardown_destination)

/datum/pocket_dimension/defeat_captivity/proc/captive_count()
	prune_captives()
	return length(captive_refs)

/// The nearest unoccupied lair shackles, or null when the map has none left.
/datum/pocket_dimension/defeat_captivity/proc/find_free_lair_anchor(turf/near)
	var/obj/structure/bondage/chains/lair/best
	var/best_distance = INFINITY
	for(var/turf/spot as anything in affected_turfs)
		var/obj/structure/bondage/chains/lair/anchor = locate() in spot
		if(!anchor || length(anchor.buckled_mobs))
			continue
		var/distance = near ? get_dist(near, spot) : 0
		if(distance < best_distance)
			best = anchor
			best_distance = distance
	return best

/datum/pocket_dimension/defeat_captivity/proc/prune_captives()
	if(!captive_refs)
		return
	for(var/captive_key in captive_refs.Copy())
		var/datum/weakref/captive_ref = captive_refs[captive_key]
		var/datum/component/kidnap_captivity/captivity = captive_ref?.resolve()
		if(!istype(captivity) || QDELETED(captivity))
			captive_refs -= captive_key

/datum/pocket_dimension/defeat_captivity/proc/register_captive(datum/component/kidnap_captivity/captivity)
	if(!captivity || QDELETED(captivity))
		return FALSE
	captive_refs["[REF(captivity)]"] = WEAKREF(captivity)
	touch()
	return TRUE

/datum/pocket_dimension/defeat_captivity/proc/unregister_captive(datum/component/kidnap_captivity/captivity, delete_when_empty = TRUE)
	if(!captive_refs)
		return
	captive_refs -= "[REF(captivity)]"
	if(teardown_started || !delete_when_empty || captive_count())
		return
	if(surrendered_count())
		close_after_surrendered = TRUE
		return
	if(SSpocket_dimensions && !QDELETED(src))
		SSpocket_dimensions.delete_instance(src)

/// Keeps a surrendered captive's NPC body in the pocket instead of ejecting it with the last captive.
/datum/pocket_dimension/defeat_captivity/proc/keep_surrendered_captive(mob/living/body)
	if(!body || QDELETED(body) || teardown_started || !contains_turf(get_turf(body)))
		return FALSE
	surrendered_refs["[REF(body)]"] = WEAKREF(body)
	RegisterSignal(body, COMSIG_PARENT_QDELETING, PROC_REF(on_surrendered_qdeleting), override = TRUE)
	return TRUE

/datum/pocket_dimension/defeat_captivity/proc/surrendered_count()
	for(var/body_key in surrendered_refs?.Copy())
		var/datum/weakref/body_ref = surrendered_refs[body_key]
		var/mob/living/body = body_ref?.resolve()
		if(body && !QDELETED(body) && contains_turf(get_turf(body)))
			continue
		surrendered_refs -= body_key
		if(body)
			UnregisterSignal(body, COMSIG_PARENT_QDELETING)
	return length(surrendered_refs)

/datum/pocket_dimension/defeat_captivity/proc/on_surrendered_qdeleting(datum/source)
	SIGNAL_HANDLER
	surrendered_refs?.Remove("[REF(source)]")
	if(close_after_surrendered && !teardown_started)
		addtimer(CALLBACK(src, PROC_REF(close_if_abandoned)), 1, TIMER_DELETE_ME)

/datum/pocket_dimension/defeat_captivity/proc/close_if_abandoned()
	if(QDELETED(src) || teardown_started || captive_count() || surrendered_count())
		return
	SSpocket_dimensions?.delete_instance(src)

/datum/pocket_dimension/defeat_captivity/proc/can_profile_access(mob/living/user, access_action, datum/component/kidnap_captivity/captivity)
	var/datum/defeat_captivity_profile/profile = captivity?.profile
	var/temporary_profile = FALSE
	if(!profile && ispath(profile_type, /datum/defeat_captivity_profile))
		profile = new profile_type
		temporary_profile = TRUE
	var/allowed = profile?.can_access(user, access_action, captivity, src)
	if(temporary_profile)
		qdel(profile)
	return allowed

/datum/pocket_dimension/defeat_captivity/proc/get_profile_access_denial_message(mob/living/user, datum/component/kidnap_captivity/captivity)
	var/datum/defeat_captivity_profile/profile = captivity?.profile
	var/temporary_profile = FALSE
	if(!profile && ispath(profile_type, /datum/defeat_captivity_profile))
		profile = new profile_type
		temporary_profile = TRUE
	var/message = profile?.get_access_denial_message(user) || "The folded boundary refuses you."
	if(temporary_profile)
		qdel(profile)
	return message

/datum/pocket_dimension/defeat_captivity/can_exit_mob(mob/user, obj/structure/pocket_dimension_exit/exit_object, show_feedback = TRUE)
	var/datum/component/kidnap_captivity/captivity = user?.GetComponent(/datum/component/kidnap_captivity)
	if(captivity && captivity.resolve_instance() != src)
		captivity = null
	if(can_profile_access(user, "exit", captivity))
		return TRUE
	if(show_feedback)
		to_chat(user, span_warning(get_profile_access_denial_message(user, captivity)))
	return FALSE

/datum/pocket_dimension/defeat_captivity/exit_mob(mob/user)
	var/datum/component/kidnap_captivity/captivity = user?.GetComponent(/datum/component/kidnap_captivity)
	if(captivity && captivity.resolve_instance() != src)
		captivity = null
	if(!can_profile_access(user, "exit", captivity))
		to_chat(user, span_warning(get_profile_access_denial_message(user, captivity)))
		return FALSE
	if(captivity)
		return captivity.release_to_context("You cross the folded threshold and escape captivity.")
	return ..()

// Captivity pockets can accumulate stripped clothes and other scene debris. If one is explicitly
// torn down, swallow that foreign clutter like an infinite-dungeon room instead of dumping it at a
// random safe turf. Occupants are ejected before this runs, so their carried belongings move with them.
/datum/pocket_dimension/defeat_captivity/eject_foreign_movables(items_only = FALSE, atom/override_destination = null)
	for(var/atom/movable/movable as anything in get_preservable_foreign_movables(items_only))
		qdel(movable)
	QDEL_LIST_ASSOC_VAL(hibernated_foreign_movables)
	if(storage && !length(storage.contents))
		QDEL_NULL(storage)

/datum/pocket_dimension/defeat_captivity/eject_teardown_contents(message = null, atom/override_destination = null)
	if(teardown_started)
		return
	teardown_started = TRUE
	if(isturf(override_destination))
		forced_teardown_destination = override_destination
	prune_captives()
	// A surrendered captive is lost to the lair; never dump the body into the world.
	for(var/body_key in surrendered_refs?.Copy())
		var/datum/weakref/body_ref = surrendered_refs[body_key]
		var/mob/living/body = body_ref?.resolve()
		if(body && !QDELETED(body) && contains_turf(get_turf(body)))
			qdel(body)
	surrendered_refs?.Cut()
	for(var/captive_key in captive_refs?.Copy())
		var/datum/weakref/captive_ref = captive_refs[captive_key]
		var/datum/component/kidnap_captivity/captivity = captive_ref?.resolve()
		if(!istype(captivity) || QDELETED(captivity))
			continue
		captivity.eject_for_teardown(message)
	captive_refs?.Cut()
	return ..(message, override_destination || find_safe_turf())

/// Resolve old lair tags into explicit profile types. Static landmark locations remain valid map
/// content during migration, but no gameplay admission depends on them anymore.
/proc/get_defeat_captivity_profile_for_lair(lair_tag)
	switch(lair_tag)
		if("greenskin_lair")
			return /datum/defeat_captivity_profile/shared/greenskin
		if("wolfden_lair")
			return /datum/defeat_captivity_profile/shared/wolfden
		if("bandit_lair")
			return /datum/defeat_captivity_profile/shared/bandit
	return /datum/defeat_captivity_profile/shared

/// Compatibility wrapper for existing content and tests. New captors should call kidnap_to_pocket()
/// with their configured profile so carrier ownership can retain the actual captor reference.
/mob/living/proc/kidnap_to_lair(lair_tag, list/captor_faction = null)
	return kidnap_to_pocket(get_defeat_captivity_profile_for_lair(lair_tag), null, captor_faction, lair_tag)

/mob/living/proc/kidnap_to_pocket(profile_spec, mob/living/captor, list/captor_faction = null, stable_key = null)
	if(!kidnap_can_be_taken())
		return FALSE
	if(GetComponent(/datum/component/kidnap_captivity))
		return FALSE
	if(!ispath(profile_spec, /datum/defeat_captivity_profile))
		return FALSE

	var/datum/defeat_captivity_profile/profile = new profile_spec(stable_key)
	var/datum/pocket_dimension/defeat_captivity/instance = profile.get_or_create_instance(captor, src)
	if(!instance || !profile.can_admit(instance))
		qdel(profile)
		return FALSE
	var/datum/component/kidnap_captivity/captivity = AddComponent(/datum/component/kidnap_captivity, profile, instance, captor, captor_faction, stable_key)
	if(!istype(captivity) || !captivity.enter_pocket())
		if(captivity)
			qdel(captivity)
		return FALSE
	visible_message(
		span_userdanger("[src] is dragged in and dumped on the ground, freshly captured!"),
		span_userdanger("You are dragged into a lair, far from any help..."),
	)
	return TRUE

/// Admit a defeated victim to a physical lair already present on the active map. This keeps the
/// ordinary captivity component, timers, choices, and consent gates, but replaces pocket transfer
/// with a forceMove to the mapper-provided entrance.
/mob/living/proc/kidnap_to_mapped_lair(profile_spec, mob/living/captor, list/captor_faction = null, stable_key = null, obj/effect/landmark/kidnap/entrance/mapped_entrance)
	if(!kidnap_can_be_taken())
		return FALSE
	if(GetComponent(/datum/component/kidnap_captivity))
		return FALSE
	if(!ispath(profile_spec, /datum/defeat_captivity_profile) || QDELETED(mapped_entrance) || !get_turf(mapped_entrance))
		return FALSE

	var/datum/defeat_captivity_profile/profile = new profile_spec(stable_key)
	var/datum/component/kidnap_captivity/captivity = AddComponent( \
		/datum/component/kidnap_captivity, \
		profile, \
		null, \
		captor, \
		captor_faction, \
		stable_key, \
		mapped_entrance, \
	)
	if(!istype(captivity) || !captivity.enter_pocket())
		if(captivity)
			qdel(captivity)
		return FALSE
	visible_message(
		span_userdanger("[src] is dragged in and dumped among the lair's writhing growth!"),
		span_userdanger("You are dragged into a lair that lies somewhere on this very world..."),
	)
	return TRUE

/// Attach ordinary Defeat captivity to a restraint that already holds the victim in the physical world.
/// No pocket is created and no movement occurs; releasing the restraint must end the component.
/mob/living/proc/kidnap_at_physical_anchor(profile_spec, mob/living/captor, list/captor_faction = null, stable_key = null, atom/movable/physical_anchor)
	if(!kidnap_can_be_taken())
		return FALSE
	if(GetComponent(/datum/component/kidnap_captivity))
		return FALSE
	if(!ispath(profile_spec, /datum/defeat_captivity_profile) || QDELETED(physical_anchor) || buckled != physical_anchor)
		return FALSE

	var/datum/defeat_captivity_profile/profile = new profile_spec(stable_key)
	var/datum/component/kidnap_captivity/captivity = AddComponent( \
		/datum/component/kidnap_captivity, \
		profile, \
		null, \
		captor, \
		captor_faction, \
		stable_key, \
		null, \
		physical_anchor, \
	)
	if(!istype(captivity) || !captivity.enter_pocket())
		if(captivity)
			qdel(captivity)
		return FALSE
	return TRUE

/// Compatibility name retained for callers and old escape landmarks; destination order now belongs
/// to the active profile, including the mandatory wilds-first per-captive policy.
/mob/living/proc/kidnap_escape_to_wilds(datum/component/kidnap_captivity/captivity)
	if(!captivity || captivity.parent != src)
		return FALSE
	var/release_message = captivity.is_mapped_lair() \
		? "You cross the lair's boundary and tear free of its hold." \
		: "You force your way out - free, but far from safety."
	return captivity.release_to_context(release_message)

/// Captivity state and return context. The component owns its profile datum but only weakly refers to
/// the instance, captor, and origin; the pocket owns no captive strongly, avoiding component cycles.
/datum/component/kidnap_captivity
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/lair_tag
	var/datum/defeat_captivity_profile/profile
	var/datum/weakref/instance_ref
	var/datum/weakref/captor_ref
	/// Physical entrance used instead of a pocket instance. Kept weak so map cleanup cannot be pinned.
	var/datum/weakref/mapped_entrance_ref
	/// Area type that bounds a mapped lair. Leaving it ends captivity; the whole z-level no longer counts.
	var/mapped_area_type
	/// TRUE when the captors shackled this captive to a lair anchor on arrival.
	var/chained = FALSE
	/// In-world restraint which owns this captivity state. Kept weak and watched for deletion.
	var/datum/weakref/physical_anchor_ref
	var/turf/saved_origin
	var/list/captor_faction
	var/captive_since = 0
	var/released = FALSE
	var/admitted = FALSE
	var/ending = FALSE
	var/datum/action/innate/defeat_refuse_advances/refuse_action
	var/datum/action/innate/defeat_captivity_choices/choices_action
	var/surrender_available = FALSE
	var/captivity_climaxes = 0
	var/ko_release_timer
	var/surrender_timer
	/// Brings the choice dialog back to a captive who chose to stay knocked out.
	var/reprompt_timer
	var/choice_prompt_open = FALSE

/datum/component/kidnap_captivity/Initialize(profile_spec, datum/pocket_dimension/defeat_captivity/instance, mob/living/captor, list/captor_faction = null, stable_key = null, obj/effect/landmark/kidnap/entrance/mapped_entrance, atom/movable/physical_anchor)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(istype(profile_spec, /datum/defeat_captivity_profile))
		profile = profile_spec
	else
		// Compatibility for old direct AddComponent calls that supplied only a lair tag.
		if(istext(profile_spec))
			stable_key = "[profile_spec]"
			profile_spec = get_defeat_captivity_profile_for_lair(stable_key)
		if(!ispath(profile_spec, /datum/defeat_captivity_profile))
			return COMPONENT_INCOMPATIBLE
		profile = new profile_spec(stable_key)
	if(!instance && !mapped_entrance && !physical_anchor)
		instance = profile.get_or_create_instance(captor, parent)
	lair_tag = stable_key || profile.stable_key
	src.captor_faction = captor_faction?.Copy()
	if(captor)
		captor_ref = WEAKREF(captor)
	saved_origin = get_turf(parent)
	captive_since = world.time
	if(mapped_entrance)
		mapped_entrance_ref = WEAKREF(mapped_entrance)
		mapped_area_type = mapped_entrance.lair_area_type
		return ..()
	if(physical_anchor)
		if(QDELETED(physical_anchor) || !get_turf(physical_anchor))
			QDEL_NULL(profile)
			return COMPONENT_INCOMPATIBLE
		physical_anchor_ref = WEAKREF(physical_anchor)
		return ..()

	if(!instance || !profile.can_admit(instance))
		QDEL_NULL(profile)
		return COMPONENT_INCOMPATIBLE
	instance_ref = WEAKREF(instance)
	if(!instance.register_captive(src))
		QDEL_NULL(profile)
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/kidnap_captivity/RegisterWithParent()
	. = ..()
	ko_release_timer = addtimer(CALLBACK(src, PROC_REF(release_from_knockout)), KIDNAP_KO_RELEASE, TIMER_STOPPABLE)
	surrender_timer = addtimer(CALLBACK(src, PROC_REF(offer_surrender)), KIDNAP_SURRENDER_WINDOW, TIMER_STOPPABLE)
	RegisterSignal(parent, COMSIG_SEX_CLIMAX, PROC_REF(on_captive_climax))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_captive_moved))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_captive_qdeleting))
	var/atom/movable/physical_anchor = resolve_physical_anchor()
	if(physical_anchor)
		RegisterSignal(physical_anchor, COMSIG_PARENT_QDELETING, PROC_REF(on_physical_anchor_qdeleting))

/datum/component/kidnap_captivity/UnregisterFromParent()
	deltimer(ko_release_timer)
	deltimer(surrender_timer)
	deltimer(reprompt_timer)
	ko_release_timer = null
	surrender_timer = null
	reprompt_timer = null
	UnregisterSignal(parent, list(COMSIG_SEX_CLIMAX, COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	var/atom/movable/physical_anchor = resolve_physical_anchor()
	if(physical_anchor)
		UnregisterSignal(physical_anchor, COMSIG_PARENT_QDELETING)
	var/mob/living/victim = parent
	if(victim)
		REMOVE_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES, KIDNAP_TRAIT)
	if(refuse_action)
		refuse_action.Remove(victim)
		QDEL_NULL(refuse_action)
	if(choices_action)
		choices_action.Remove(victim)
		QDEL_NULL(choices_action)
	var/datum/pocket_dimension/defeat_captivity/instance = resolve_instance()
	if(!is_mapped_lair())
		instance?.unregister_captive(src, profile?.delete_when_empty)
	instance_ref = null
	mapped_entrance_ref = null
	physical_anchor_ref = null
	return ..()

/datum/component/kidnap_captivity/Destroy(force)
	. = ..()
	QDEL_NULL(profile)
	captor_ref = null
	mapped_entrance_ref = null
	physical_anchor_ref = null
	saved_origin = null
	captor_faction = null
	return .

/datum/component/kidnap_captivity/proc/resolve_instance()
	var/datum/pocket_dimension/defeat_captivity/instance = instance_ref?.resolve()
	if(istype(instance) && !QDELETED(instance))
		return instance
	instance_ref = null
	return null

/datum/component/kidnap_captivity/proc/resolve_captor()
	var/mob/living/captor = captor_ref?.resolve()
	if(istype(captor) && !QDELETED(captor))
		return captor
	captor_ref = null
	return null

/datum/component/kidnap_captivity/proc/resolve_mapped_entrance()
	var/obj/effect/landmark/kidnap/entrance/entrance = mapped_entrance_ref?.resolve()
	if(istype(entrance) && !QDELETED(entrance))
		return entrance
	mapped_entrance_ref = null
	return null

/datum/component/kidnap_captivity/proc/resolve_physical_anchor()
	var/atom/movable/physical_anchor = physical_anchor_ref?.resolve()
	if(istype(physical_anchor) && !QDELETED(physical_anchor))
		return physical_anchor
	return null

/datum/component/kidnap_captivity/proc/is_physical_anchor(atom/movable/physical_anchor)
	return physical_anchor && physical_anchor == resolve_physical_anchor()

/datum/component/kidnap_captivity/proc/is_mapped_lair()
	return !isnull(mapped_entrance_ref)

/// Inside a mapped lair means inside its area. Without one, fall back to the entrance's z-level.
/datum/component/kidnap_captivity/proc/mapped_lair_contains(turf/spot)
	if(!spot)
		return FALSE
	if(mapped_area_type)
		return istype(get_area(spot), mapped_area_type)
	var/turf/entrance_turf = get_turf(resolve_mapped_entrance())
	return entrance_turf && spot.z == entrance_turf.z

/datum/component/kidnap_captivity/proc/is_physical_captivity()
	return !isnull(physical_anchor_ref)

/datum/component/kidnap_captivity/proc/get_saved_origin()
	if(isturf(saved_origin) && !QDELETED(saved_origin))
		return saved_origin
	return null

/datum/component/kidnap_captivity/proc/enter_pocket()
	var/mob/living/victim = parent
	if(!victim || QDELETED(victim))
		return FALSE
	if(is_physical_captivity())
		var/atom/movable/physical_anchor = resolve_physical_anchor()
		if(!physical_anchor || victim.buckled != physical_anchor)
			return FALSE
	else if(is_mapped_lair())
		var/turf/entrance_turf = get_turf(resolve_mapped_entrance())
		if(!entrance_turf)
			return FALSE
		// Prey already inside the lair's bounds is pinned where it lies, not dragged back to the door.
		if(!mapped_lair_contains(get_turf(victim)))
			victim.forceMove(entrance_turf)
	else
		var/datum/pocket_dimension/defeat_captivity/instance = resolve_instance()
		if(!instance || !instance.send_movable_inside(victim, forced_drop_turf = null))
			return FALSE
		if(profile?.chains_captives)
			chained = chain_to_lair_anchor(victim, instance)
	admitted = TRUE
	announce_arrival(victim)
	return TRUE

/// Captors chain a new arrival to a free wall anchor when the lair has one. Mappers place the anchors.
/datum/component/kidnap_captivity/proc/chain_to_lair_anchor(mob/living/victim, datum/pocket_dimension/defeat_captivity/instance)
	var/obj/structure/bondage/chains/lair/anchor = instance?.find_free_lair_anchor(get_turf(victim))
	if(!anchor)
		return FALSE
	if(iscarbon(victim) && !HAS_TRAIT(victim, TRAIT_RESTRAINED))
		var/mob/living/carbon/carbon_victim = victim
		var/obj/item/rope/rope = new
		if(!rope.apply_cuffs(carbon_victim))
			qdel(rope)
	victim.forceMove(get_turf(anchor))
	if(!anchor.buckle_mob(victim, force = TRUE))
		return FALSE
	victim.visible_message(span_warning("[victim] is shackled to the wall."))
	return TRUE

/// Frees a captive from lair shackles before anything moves them out. Physical anchors own their own release.
/datum/component/kidnap_captivity/proc/unchain(mob/living/victim)
	if(!victim || QDELETED(victim) || !victim.buckled || is_physical_captivity())
		return
	victim.buckled.unbuckle_mob(victim, force = TRUE)

/// A knocked-out captive waits for the hold to loosen; a bound, awake one gets their choices at once.
/datum/component/kidnap_captivity/proc/announce_arrival(mob/living/victim)
	if(chained)
		to_chat(victim, span_userdanger("Rough hands bind your wrists and shackle you to the wall. Resist to work free of the shackles, then of your bonds."))
	if(!victim.has_status_effect(/datum/status_effect/defeat_knockout))
		release_awake()
		return
	if(is_physical_captivity())
		to_chat(victim, span_userdanger("<b>YOU HAVE BEEN CAPTURED.</b><br>\
			Defeat will hold you helpless for about one minute, but you can still speak, emote, and call for help.<br>\
			When that hold loosens, use Refuse Advances to make the lair's denizens leave you alone while you struggle out of your restraint."))
		return
	if(is_mapped_lair())
		to_chat(victim, span_userdanger("<b>YOU HAVE BEEN KIDNAPPED.</b><br>\
			Defeat will hold you helpless for about one minute, but you can still speak, emote, and call for help.<br>\
			This lair lies on the world itself: rescuers can reach it, and leaving its grounds ends captivity. When the hold loosens, your usual captivity and rune choices become available."))
		return
	to_chat(victim, span_userdanger("<b>YOU HAVE BEEN KIDNAPPED.</b><br>\
		Defeat will hold you helpless for about one minute, but you can still speak, emote, and call for help.<br>\
		When that hold loosens you choose: wake up here with ordinary Defeat trauma, call a linked rune at its usual price, stay for now, or give this character up for good.<br>\
		Once awake, the lair's own exit sets you free. The Captivity button holds these choices at any time."))

/// A bound captive arrives awake: no knockout clock, agency and the Captivity button at once.
/datum/component/kidnap_captivity/proc/release_awake()
	var/mob/living/victim = parent
	if(!victim || QDELETED(victim) || released)
		return
	released = TRUE
	deltimer(ko_release_timer)
	ko_release_timer = null
	grant_refuse_advances(victim)
	grant_captivity_choices(victim)
	var/way_out = is_physical_captivity() ? "struggle out of your restraint" : "find the lair's way out"
	to_chat(victim, span_userdanger("<b>YOU HAVE BEEN CARRIED OFF.</b><br>\
		You are bound but awake. Resist to work free of your bonds, then [way_out].<br>\
		Use Refuse Advances to make the lair's denizens leave you be, and Captivity for your other choices."))

/datum/component/kidnap_captivity/proc/on_captive_moved(datum/source, atom/old_loc, direction, forced)
	SIGNAL_HANDLER
	if(ending || !admitted)
		return
	if(is_physical_captivity())
		var/mob/living/physical_victim = parent
		if(physical_victim?.buckled == resolve_physical_anchor())
			return
		ending = TRUE
		physical_victim?.grant_kidnap_release_grace()
		qdel(src)
		return
	if(is_mapped_lair())
		if(mapped_lair_contains(get_turf(parent)))
			return
		ending = TRUE
		var/mob/living/mapped_victim = parent
		mapped_victim?.grant_kidnap_release_grace()
		qdel(src)
		return
	var/datum/pocket_dimension/defeat_captivity/instance = resolve_instance()
	if(instance?.contains_turf(get_turf(parent)))
		return
	ending = TRUE
	var/mob/living/victim = parent
	victim?.grant_kidnap_release_grace()
	qdel(src)

/datum/component/kidnap_captivity/proc/on_captive_qdeleting(datum/source)
	SIGNAL_HANDLER
	ending = TRUE
	qdel(src)

/datum/component/kidnap_captivity/proc/on_physical_anchor_qdeleting(datum/source)
	SIGNAL_HANDLER
	if(ending)
		return
	ending = TRUE
	var/mob/living/victim = parent
	victim?.grant_kidnap_release_grace()
	qdel(src)

/datum/component/kidnap_captivity/proc/get_contextual_destination()
	if(is_mapped_lair() || is_physical_captivity())
		return get_turf(parent)
	return profile?.get_ejection_destination(src, resolve_instance())

/datum/component/kidnap_captivity/proc/release_to_context(message = null)
	if(ending)
		return FALSE
	var/mob/living/victim = parent
	var/turf/destination = get_contextual_destination()
	if(!victim || QDELETED(victim) || !destination)
		return FALSE
	ending = TRUE
	victim.grant_kidnap_release_grace()
	unchain(victim)
	victim.forceMove(destination)
	qdel(src)
	if(message)
		to_chat(victim, span_notice(message))
	return TRUE

/datum/component/kidnap_captivity/proc/eject_for_teardown(message = null)
	if(ending)
		return FALSE
	var/mob/living/victim = parent
	var/turf/destination = get_contextual_destination()
	if(!victim || QDELETED(victim) || !destination)
		return FALSE
	ending = TRUE
	victim.grant_kidnap_release_grace()
	unchain(victim)
	victim.forceMove(destination)
	qdel(src)
	if(message)
		to_chat(victim, span_warning(message))
	return TRUE

/// Rune completion calls this before moving the body. Returning the saved origin lets the rune keep
/// a meaningful compass target rather than pointing back to a temporary pocket reservation.
/datum/component/kidnap_captivity/proc/prepare_rune_return()
	var/turf/origin = get_saved_origin()
	if(!ending)
		ending = TRUE
		var/mob/living/victim = parent
		victim?.grant_kidnap_release_grace()
		unchain(victim)
		qdel(src)
	return origin

/// Shake off the knockout inside the lair. Captivity stays, so the exit and the dialog still work.
/datum/component/kidnap_captivity/proc/wake_up(rebuff = TRUE)
	if(ending || !released)
		return FALSE
	var/mob/living/victim = parent
	if(!victim || QDELETED(victim))
		return FALSE
	if(!victim.perform_defeat_rescue(null, "waking in captivity", /datum/defeat_recovery_profile/environmental, src))
		return FALSE
	grant_refuse_advances(victim)
	if(rebuff)
		ADD_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES, KIDNAP_TRAIT)
		refuse_action?.update_state()
		to_chat(victim, span_warning("You wrench yourself awake inside the lair and steel yourself against its denizens. The Refuse Advances toggle lets you relent later."))
	else
		to_chat(victim, span_warning("You wrench yourself awake inside the lair, open to whatever its denizens want. The Refuse Advances toggle makes them leave you be."))
	return TRUE

/// Kept for the rune's rejection path and older callers: waking always rebuffed the lair before.
/datum/component/kidnap_captivity/proc/reject_rune_and_wake()
	return wake_up(TRUE)

/datum/component/kidnap_captivity/proc/release_from_knockout()
	var/mob/living/victim = parent
	if(!victim || QDELETED(victim) || released)
		return
	if(!victim.has_status_effect(/datum/status_effect/defeat_knockout))
		release_awake()
		return
	released = TRUE
	if(victim.defeat_mode == DEFEAT_MODE_KO_RUNE)
		victim.kidnap_surface_rune_return()
	grant_captivity_choices(victim)
	// Nobody at the keyboard: wake the body rather than leave it knocked out in a lair for hours.
	if(!victim.client)
		wake_up(FALSE)
		return
	to_chat(victim, span_blue("The hold on you has loosened. Wake up, call the rune if it answers, stay for now, or give this character up: the Captivity button holds the choice."))
	INVOKE_ASYNC(src, PROC_REF(offer_release_choice))

/// "Stay for now" while knocked out: the dialog comes back on its own after a while.
/datum/component/kidnap_captivity/proc/schedule_reprompt()
	deltimer(reprompt_timer)
	reprompt_timer = addtimer(CALLBACK(src, PROC_REF(reprompt_if_still_down)), KIDNAP_CHOICE_REPROMPT, TIMER_STOPPABLE)

/datum/component/kidnap_captivity/proc/reprompt_if_still_down()
	reprompt_timer = null
	var/mob/living/victim = parent
	if(ending || !victim || QDELETED(victim) || !victim.has_status_effect(/datum/status_effect/defeat_knockout))
		return
	to_chat(victim, span_blue("The lair still holds you. Your choices return."))
	INVOKE_ASYNC(src, PROC_REF(offer_release_choice))

/// Reconciles external/admin recovery with captivity. Shared exits are permissive as a second line of
/// defense, but this keeps actions, timers, and the released state internally consistent too.
/datum/component/kidnap_captivity/proc/on_knockout_removed()
	if(ending || !admitted)
		return FALSE
	var/was_released = released
	released = TRUE
	deltimer(ko_release_timer)
	ko_release_timer = null
	var/mob/living/victim = parent
	if(!victim || QDELETED(victim))
		return FALSE
	grant_refuse_advances(victim)
	grant_captivity_choices(victim)
	if(!was_released)
		to_chat(victim, span_warning("The grip of defeat is gone. You can move again and use the lair exit whenever you choose."))
	return TRUE

/datum/component/kidnap_captivity/proc/grant_captivity_choices(mob/living/victim)
	if(choices_action || !victim)
		return
	choices_action = new(victim)
	choices_action.Grant(victim)

/datum/component/kidnap_captivity/proc/offer_release_choice(datum/resurrection_rune_controller/rune_controller)
	if(choice_prompt_open || ending || !released)
		return FALSE
	var/mob/living/carbon/human/victim = parent
	if(!ishuman(victim) || QDELETED(victim) || !victim.client)
		return FALSE
	if(!rune_controller)
		rune_controller = get_resurrection_rune_controller_for_user(victim)
	deltimer(reprompt_timer)
	reprompt_timer = null

	var/knocked_out = !!victim.has_status_effect(/datum/status_effect/defeat_knockout)
	var/list/choices = list()
	var/list/lines = list()
	if(knocked_out)
		choices += KIDNAP_CHOICE_WAKE
		lines += "Wake up: shake off the defeat here, with its usual aftermath. You then decide whether the lair's denizens may keep at you."
	if(rune_controller?.can_offer_defeat_rune_return(victim))
		choices += KIDNAP_CHOICE_CALL_RUNE
		lines += "Call the rune: it pulls you to safety and heals you, but spends a charge and takes coin, blood, clothing, mana and lasting weariness."
	choices += KIDNAP_CHOICE_WAIT
	if(knocked_out)
		lines += "Stay for now: remain as you are. These choices return in [DisplayTimeText(KIDNAP_CHOICE_REPROMPT)], or sooner through the Captivity button."
	else
		lines += "Stay for now: remain in the lair. The Captivity button brings these choices back, and the lair's own exit sets you free."
	choices += KIDNAP_CHOICE_GIVE_UP
	lines += "Give up this character: your body stays as the lair's captive and you return to the lobby. This cannot be undone."
	var/intro = knocked_out ? "The hold on you has loosened. Choose your way forward." : "You are captive, but awake. Choose your way forward."

	choice_prompt_open = TRUE
	var/choice = tgui_alert(victim, "[intro]\n\n[lines.Join("\n\n")]", "Captivity", choices)
	if(QDELETED(src))
		return FALSE
	choice_prompt_open = FALSE
	if(ending || !released || parent != victim || QDELETED(victim))
		return FALSE

	switch(choice)
		if(KIDNAP_CHOICE_CALL_RUNE)
			rune_controller = get_resurrection_rune_controller_for_user(victim)
			return rune_controller?.trigger_defeat_rune_return(victim)
		if(KIDNAP_CHOICE_WAKE)
			if(!victim.has_status_effect(/datum/status_effect/defeat_knockout))
				to_chat(victim, span_notice("You are already awake. The lair exit is available whenever you are ready."))
				return FALSE
			var/rebuff = tgui_alert(victim, "Rebuff the lair's denizens so they leave you be? The Refuse Advances toggle changes this later.", "Wake up", list("Rebuff them", "Let them be")) == "Rebuff them"
			if(QDELETED(src) || ending || parent != victim || QDELETED(victim))
				return FALSE
			var/woke = wake_up(rebuff)
			if(woke)
				rune_controller?.clear_linked_user_rescue_state(victim)
			return woke
		if(KIDNAP_CHOICE_GIVE_UP)
			return abandon_character()
	// Staying, or closing the dialog, while still knocked out: ask again later.
	if(victim.has_status_effect(/datum/status_effect/defeat_knockout))
		schedule_reprompt()
	return choice == KIDNAP_CHOICE_WAIT

/datum/component/kidnap_captivity/proc/abandon_character()
	if(ending)
		return FALSE
	var/mob/living/carbon/human/victim = parent
	if(!ishuman(victim) || QDELETED(victim) || !victim.client)
		return FALSE
	if(tgui_alert(victim, "Permanently abandon this character to captivity and return to the lobby? This cannot be undone.", "Abandon Character", list("Abandon Character", "Keep Playing")) != "Abandon Character")
		return FALSE
	if(QDELETED(src) || ending || parent != victim || QDELETED(victim) || !victim.client)
		return FALSE
	return leave_character_to_captivity()

/// Surrender and Abandon both end here: the body stays as the lair's captive, the player goes to the lobby.
/datum/component/kidnap_captivity/proc/leave_character_to_captivity()
	var/mob/living/carbon/human/victim = parent
	if(!ishuman(victim) || QDELETED(victim))
		return FALSE
	ending = TRUE
	var/list/final_captor_faction = captor_faction?.Copy()
	var/datum/pocket_dimension/defeat_captivity/instance = resolve_instance()
	// Job slot, name and every rune bond go first, so nothing can rebuild this character later.
	victim.prepare_abandon_character()
	var/mob/dead/observer/ghost = victim.become_npc_in_distress(decays = TRUE, captor_faction = final_captor_faction)
	// Register the body before our removal, so an emptied pocket waits for the NPC instead of closing.
	instance?.keep_surrendered_captive(victim)
	qdel(src)
	if(ghost && !QDELETED(ghost))
		ghost.returntolobby()
	return TRUE

/datum/component/kidnap_captivity/proc/grant_refuse_advances(mob/living/victim)
	if(refuse_action || !victim)
		return
	refuse_action = new(victim)
	refuse_action.Grant(victim)

/datum/component/kidnap_captivity/proc/offer_surrender()
	var/mob/living/victim = parent
	if(!victim || QDELETED(victim))
		return
	surrender_available = TRUE
	to_chat(victim, span_userdanger("Despair claws at you. Giving this character up to the lair is always on the Captivity button; it cannot be undone."))
	if(released)
		INVOKE_ASYNC(src, PROC_REF(offer_release_choice))

/datum/component/kidnap_captivity/proc/on_captive_climax(datum/source, datum/sex_action/action, mob/living/receiver, mob/living/partner, mob/living/performer)
	SIGNAL_HANDLER
	captivity_climaxes++
	if(captivity_climaxes >= KIDNAP_SURRENDER_CLIMAXES && !surrender_available)
		offer_surrender()

/datum/component/kidnap_captivity/proc/do_surrender()
	if(ending)
		return FALSE
	return leave_character_to_captivity()

/datum/component/kidnap_captivity/proc/end_captivity()
	if(ending)
		return
	ending = TRUE
	qdel(src)
