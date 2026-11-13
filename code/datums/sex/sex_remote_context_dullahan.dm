// A detached dullahan head as a remote context: mouth actions reach the head wherever it is held.
// Everything else on the dullahan still needs their body in reach.

/// The detached head of a headless dullahan, or null.
/proc/get_detached_dullahan_head(mob/living/candidate)
	RETURN_TYPE(/obj/item/bodypart/head/dullahan)
	if(!ishuman(candidate))
		return null
	var/mob/living/carbon/human/human = candidate
	var/datum/species/dullahan/dullahan_species = human.dna?.species
	if(!istype(dullahan_species) || !dullahan_species.headless)
		return null
	var/obj/item/bodypart/head/dullahan/head = dullahan_species.my_head
	if(!head || QDELETED(head) || head.owner)
		return null
	return head

/// How close `other` is to a detached head: held or sharing its turf, adjacent, or nothing.
#define DULLAHAN_HEAD_REACH_NONE 0
#define DULLAHAN_HEAD_REACH_ADJACENT 1
#define DULLAHAN_HEAD_REACH_CLOSE 2

/proc/get_dullahan_head_reach(obj/item/bodypart/head/dullahan/head, mob/living/other)
	if(!head || !other || QDELETED(head) || QDELETED(other))
		return DULLAHAN_HEAD_REACH_NONE
	if(other.is_holding(head))
		return DULLAHAN_HEAD_REACH_CLOSE
	var/turf/head_turf = get_turf(head)
	if(!head_turf)
		return DULLAHAN_HEAD_REACH_NONE
	// A head inside a bag or closet is out of reach; a mouth in a sack has no business here.
	if(!isturf(head.loc) && head.loc != other)
		return DULLAHAN_HEAD_REACH_NONE
	var/atom/movable/other_anchor = other.get_sense_anchor()
	if(get_turf(other_anchor) == head_turf)
		return DULLAHAN_HEAD_REACH_CLOSE
	if(other_anchor.Adjacent(head))
		return DULLAHAN_HEAD_REACH_ADJACENT
	return DULLAHAN_HEAD_REACH_NONE

/datum/sex_remote_context/dullahan_head
	requires_range = FALSE
	requires_line_of_sight = FALSE
	allows_visible_messages = TRUE
	var/datum/weakref/head_ref

/datum/sex_remote_context/dullahan_head/New(mob/living/caster, mob/living/target, obj/item/bodypart/head/dullahan/head)
	. = ..(caster, target, 0, 0)
	head_ref = WEAKREF(head)
	RegisterSignal(head, COMSIG_PARENT_QDELETING, PROC_REF(on_participant_invalidated))
	addtimer(CALLBACK(src, PROC_REF(check_validity)), check_interval)

/datum/sex_remote_context/dullahan_head/Destroy(force, ...)
	var/obj/item/bodypart/head/dullahan/head = head_ref?.resolve()
	if(head)
		UnregisterSignal(head, COMSIG_PARENT_QDELETING)
	head_ref = null
	return ..()

/datum/sex_remote_context/dullahan_head/proc/get_head()
	RETURN_TYPE(/obj/item/bodypart/head/dullahan)
	return head_ref?.resolve()

/// The participant whose head this is, and the one reaching for it.
/datum/sex_remote_context/dullahan_head/proc/get_head_owner()
	var/obj/item/bodypart/head/dullahan/head = get_head()
	return head?.get_dullahan_owner()

/datum/sex_remote_context/dullahan_head/proc/get_other_party()
	var/mob/living/head_owner = get_head_owner()
	var/mob/living/caster = get_caster()
	var/mob/living/remote_target = get_target()
	if(head_owner == caster)
		return remote_target
	if(head_owner == remote_target)
		return caster
	return null

/datum/sex_remote_context/dullahan_head/proc/get_reach()
	return get_dullahan_head_reach(get_head(), get_other_party())

/datum/sex_remote_context/dullahan_head/is_valid(datum/sex_scene/owning_scene)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/bodypart/head/dullahan/head = get_head()
	if(!head || QDELETED(head) || head.owner)
		return FALSE
	if(!get_detached_dullahan_head(get_head_owner()))
		return FALSE
	return get_reach() != DULLAHAN_HEAD_REACH_NONE

/// Only actions that use the dullahan's mouth, and nothing else of theirs, go through the head.
/datum/sex_remote_context/dullahan_head/allows_action(datum/sex_action/action)
	if(!action)
		return FALSE
	var/mob/living/head_owner = get_head_owner()
	if(!head_owner)
		return FALSE
	var/mask
	if(head_owner == get_caster())
		mask = action.user_menu_zone_mask
	else if(head_owner == get_target())
		mask = action.target_menu_zone_mask
	else
		return FALSE
	if(!mask || (mask & ~SEX_UI_ZONE_MOUTH))
		return FALSE
	// Standing next to a head on the floor is not the same as holding it.
	if(get_reach() < DULLAHAN_HEAD_REACH_CLOSE && (action.check_same_tile || action.require_grab))
		return FALSE
	return TRUE

/// Makes sure every headless participant has a head context with each partner who can reach the head.
/proc/ensure_dullahan_head_contexts(datum/sex_scene/scene)
	if(!scene || QDELETED(scene))
		return
	for(var/mob/living/head_owner as anything in scene.participants)
		var/obj/item/bodypart/head/dullahan/head = get_detached_dullahan_head(head_owner)
		if(!head)
			continue
		// Holding your own head puts your mouth wherever you want it.
		if(head_owner.is_holding(head))
			ensure_dullahan_head_context(scene, head_owner, head_owner, head)
		for(var/mob/living/other as anything in scene.participants)
			if(other == head_owner)
				continue
			if(get_dullahan_head_reach(head, other) == DULLAHAN_HEAD_REACH_NONE)
				continue
			ensure_dullahan_head_context(scene, head_owner, other, head)
			ensure_dullahan_head_context(scene, other, head_owner, head)

/proc/ensure_dullahan_head_context(datum/sex_scene/scene, mob/living/caster, mob/living/target, obj/item/bodypart/head/dullahan/head)
	var/datum/sex_remote_context/existing = scene.get_remote_context(caster, target, null)
	if(existing)
		if(istype(existing, /datum/sex_remote_context/dullahan_head))
			var/datum/sex_remote_context/dullahan_head/existing_head_context = existing
			if(existing_head_context.get_head() == head)
				return existing
		else
			// Another live context (a mage hand) owns this pair; leave it be.
			return null
	var/datum/sex_remote_context/dullahan_head/context = new(caster, target, head)
	if(!scene.add_remote_context(context))
		qdel(context)
		return null
	return context

/// Drops every head context built on `head`, for when it goes back on or is lost.
/proc/clear_dullahan_head_contexts(obj/item/bodypart/head/dullahan/head)
	if(!head)
		return
	var/mob/living/head_owner = head.get_dullahan_owner()
	var/datum/sex_scene/scene = head_owner?.sex_scene
	if(!scene || QDELETED(scene) || !length(scene.remote_contexts))
		return
	for(var/datum/sex_remote_context/dullahan_head/context as anything in scene.remote_contexts.Copy())
		if(!istype(context) || context.get_head() != head)
			continue
		qdel(context)

/// Dragging yourself onto a detached head opens a scene with its owner.
/obj/item/bodypart/head/dullahan/MiddleMouseDrop_T(atom/movable/dragged, mob/living/user)
	if(!isliving(user) || user.mmb_intent || !is_live_detached_head())
		return ..()
	if(dragged != user && dragged == user.loc)
		dragged = user
	if(dragged != user)
		return ..()
	var/mob/living/carbon/human/head_owner = get_dullahan_owner()
	if(!user.can_do_sex())
		to_chat(user, span_warning("I can't do this."))
		return
	if(get_dullahan_head_reach(src, user) == DULLAHAN_HEAD_REACH_NONE)
		to_chat(user, span_warning("I need to hold [src] or stand over it."))
		return
	if(!user.open_sex_scene(head_owner))
		to_chat(user, span_warning(user.get_sex_scene_refusal(head_owner)))
		return

#undef DULLAHAN_HEAD_REACH_NONE
#undef DULLAHAN_HEAD_REACH_ADJACENT
#undef DULLAHAN_HEAD_REACH_CLOSE
