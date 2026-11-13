#define BELLY_FULLNESS_MESSAGE_COOLDOWN (30 SECONDS)

/obj/item/organ/genitals/belly
	name = "belly"
	icon_state = "belly"
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_STOMACH
	slot = ORGAN_SLOT_BELLY
	accessory_type = /datum/sprite_accessory/genitals/belly
	organ_size = DEFAULT_BELLY_SIZE
	var/resting_size = DEFAULT_BELLY_SIZE
	/// Stuffing level from what is held inside, 0 to BELLY_BUMP_MAX, shown with the preg_N sprites.
	var/fullness_growth_steps = 0
	/// Conventional pregnancy stage, shown with the same preg_N sprites.
	var/pregnancy_stage = 0

/obj/item/organ/genitals/belly/Initialize()
	. = ..()
	resting_size = CLAMP(organ_size, MIN_BELLY_SIZE, MAX_BELLY_SIZE)

/obj/item/organ/genitals/belly/Insert(mob/living/M, special, drop_if_replaced, new_zone = null)
	. = ..()
	resting_size = CLAMP(resting_size, MIN_BELLY_SIZE, MAX_BELLY_SIZE)
	organ_size = resting_size
	if(!GetComponent(/datum/component/belly_fullness))
		AddComponent(/datum/component/belly_fullness)

/obj/item/organ/genitals/belly/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	set_fullness_growth_steps(0)
	pregnancy_stage = 0
	organ_size = resting_size

	var/datum/component/belly_fullness/fullness = GetComponent(/datum/component/belly_fullness)
	qdel(fullness)

/// The larger of stuffing and pregnancy, on the preg_N scale.
/obj/item/organ/genitals/belly/proc/get_bump_level()
	return max(fullness_growth_steps, pregnancy_stage)

/// The resting belly shows unless a stuffed or pregnant bump outsizes it.
/obj/item/organ/genitals/belly/proc/get_visible_belly_state()
	var/bump = get_bump_level()
	if(bump > resting_size)
		return "preg_[bump]"
	return "pair_[resting_size]"

/obj/item/organ/genitals/belly/get_render_key_state()
	return get_visible_belly_state()

/obj/item/organ/genitals/belly/proc/set_pregnancy_stage(stage)
	var/new_stage = CLAMP(stage, 0, PREGNANCY_MAX_STAGE)
	if(pregnancy_stage == new_stage)
		return FALSE
	pregnancy_stage = new_stage
	return TRUE

/obj/item/organ/genitals/belly/proc/set_fullness_growth_steps(growth_steps)
	var/new_growth_steps = CLAMP(growth_steps, 0, BELLY_BUMP_MAX)
	if(fullness_growth_steps == new_growth_steps)
		return FALSE

	fullness_growth_steps = new_growth_steps
	return TRUE

/obj/item/organ/genitals/belly/internal
	name = "internal belly"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none

/datum/component/belly_fullness
	dupe_mode = COMPONENT_DUPE_UNIQUE

	COOLDOWN_DECLARE(fullness_expand_message_cooldown)
	COOLDOWN_DECLARE(fullness_shrink_message_cooldown)

	var/obj/item/organ/genitals/belly/belly
	var/mob/living/carrier
	var/list/tracked_organs = list()
	var/fullness_message_initialized = FALSE

/datum/component/belly_fullness/Initialize()
	if(!istype(parent, /obj/item/organ/genitals/belly))
		return COMPONENT_INCOMPATIBLE

	belly = parent
	carrier = belly.owner
	return ..()

/datum/component/belly_fullness/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ORGAN_INSERTED, PROC_REF(on_inserted))
	RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))
	if(carrier)
		register_carrier()
	refresh_tracked_organs(TRUE)
	recalculate_size()

/datum/component/belly_fullness/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ORGAN_INSERTED)
	UnregisterSignal(parent, COMSIG_ORGAN_REMOVED)
	clear_tracked_organs()
	if(carrier)
		unregister_carrier()

/datum/component/belly_fullness/Destroy(force, ...)
	clear_tracked_organs()
	if(carrier)
		unregister_carrier()
	carrier = null
	belly = null
	return ..()

/datum/component/belly_fullness/proc/register_carrier()
	RegisterSignal(carrier, COMSIG_LIVING_ORGAN_CHANGED, PROC_REF(on_carrier_organ_changed))
	RegisterSignal(carrier, COMSIG_PARENT_QDELETING, PROC_REF(on_carrier_qdeleting))

/datum/component/belly_fullness/proc/unregister_carrier()
	UnregisterSignal(carrier, list(COMSIG_LIVING_ORGAN_CHANGED, COMSIG_PARENT_QDELETING))

/datum/component/belly_fullness/proc/register_tracked_organ(obj/item/organ/organ)
	if(!organ)
		return

	RegisterSignal(organ, COMSIG_BODYSTORAGE_CHANGED, PROC_REF(on_storage_changed))
	RegisterSignal(organ, COMSIG_ORGAN_INSERTED, PROC_REF(on_tracked_organ_changed))
	RegisterSignal(organ, COMSIG_ORGAN_REMOVED, PROC_REF(on_tracked_organ_changed))
	RegisterSignal(organ, COMSIG_PARENT_QDELETING, PROC_REF(on_tracked_organ_qdeleting))

/datum/component/belly_fullness/proc/unregister_tracked_organ(obj/item/organ/organ)
	if(!organ)
		return

	UnregisterSignal(organ, list(
		COMSIG_BODYSTORAGE_CHANGED,
		COMSIG_ORGAN_INSERTED,
		COMSIG_ORGAN_REMOVED,
		COMSIG_PARENT_QDELETING,
	))

/datum/component/belly_fullness/proc/register_tracked_organs()
	for(var/key in tracked_organs)
		var/obj/item/organ/organ = tracked_organs[key]
		register_tracked_organ(organ)

/datum/component/belly_fullness/proc/unregister_tracked_organs()
	for(var/key in tracked_organs)
		var/obj/item/organ/organ = tracked_organs[key]
		unregister_tracked_organ(organ)

/datum/component/belly_fullness/proc/clear_tracked_organs()
	unregister_tracked_organs()
	tracked_organs = list()

/datum/component/belly_fullness/proc/on_inserted(datum/source, mob/living/new_owner)
	SIGNAL_HANDLER

	if(carrier == new_owner)
		return

	if(carrier)
		unregister_carrier()
	carrier = new_owner
	if(carrier)
		register_carrier()

	refresh_tracked_organs(TRUE)
	recalculate_size()

/datum/component/belly_fullness/proc/on_removed(datum/source, mob/living/old_owner)
	SIGNAL_HANDLER

	if(carrier)
		unregister_carrier()
	carrier = null
	clear_tracked_organs()

/datum/component/belly_fullness/proc/on_carrier_qdeleting(datum/source, force)
	SIGNAL_HANDLER

	if(carrier)
		unregister_carrier()
	carrier = null
	clear_tracked_organs()

/datum/component/belly_fullness/proc/on_carrier_organ_changed(datum/source, obj/item/organ/changed_organ, changed_slot, inserted)
	SIGNAL_HANDLER

	if(!(changed_slot in list(ORGAN_SLOT_GUTS, ORGAN_SLOT_STOMACH, ORGAN_SLOT_VAGINA, ORGAN_SLOT_WOMB, ORGAN_SLOT_ANUS)))
		return

	refresh_tracked_organs(TRUE)
	recalculate_size()

/datum/component/belly_fullness/proc/on_storage_changed(datum/source, datum/component/body_storage/storage)
	SIGNAL_HANDLER

	recalculate_size()

/datum/component/belly_fullness/proc/on_tracked_organ_changed(datum/source)
	SIGNAL_HANDLER

	refresh_tracked_organs(TRUE)
	recalculate_size()

/datum/component/belly_fullness/proc/on_tracked_organ_qdeleting(obj/item/organ/source, force)
	SIGNAL_HANDLER

	var/changed = FALSE
	for(var/key in tracked_organs)
		if(tracked_organs[key] != source)
			continue

		tracked_organs[key] = null
		changed = TRUE

	unregister_tracked_organ(source)
	if(changed)
		recalculate_size()

/datum/component/belly_fullness/proc/refresh_tracked_organs(force_rebind = FALSE)
	var/list/new_tracked = list(
		"mouth" = find_mouth_storage_organ(),
		ORGAN_SLOT_VAGINA = carrier?.getorganslot(ORGAN_SLOT_VAGINA),
		ORGAN_SLOT_WOMB = carrier?.getorganslot(ORGAN_SLOT_WOMB),
		ORGAN_SLOT_ANUS = carrier?.getorganslot(ORGAN_SLOT_ANUS),
	)

	var/changed = force_rebind
	for(var/key in new_tracked)
		if(tracked_organs[key] != new_tracked[key])
			changed = TRUE
			break

	if(!changed)
		return FALSE

	unregister_tracked_organs()
	tracked_organs = new_tracked
	register_tracked_organs()
	return TRUE

/datum/component/belly_fullness/proc/find_mouth_storage_organ()
	if(!carrier)
		return null

	var/obj/item/organ/mouth_storage = carrier.getorganslot(ORGAN_SLOT_GUTS)
	if(mouth_storage)
		return mouth_storage

	mouth_storage = carrier.getorganslot(ORGAN_SLOT_STOMACH)
	if(mouth_storage?.GetComponent(/datum/component/body_storage/mouth))
		return mouth_storage

	return null

/datum/component/belly_fullness/proc/recalculate_size()
	if(!belly)
		return FALSE

	var/old_growth_steps = belly.fullness_growth_steps
	var/old_state = belly.get_visible_belly_state()
	var/new_growth_steps = get_total_growth_steps()
	var/was_initialized = fullness_message_initialized
	fullness_message_initialized = TRUE

	var/size_changed = belly.set_fullness_growth_steps(new_growth_steps)
	var/stage_changed = belly.set_pregnancy_stage(get_pregnancy_stage())
	if(!size_changed && !stage_changed)
		return FALSE

	// Stuffing hidden under a bigger belly or pregnancy changes nothing the carrier would notice.
	if(size_changed && was_initialized && old_state != belly.get_visible_belly_state())
		send_fullness_change_message(old_growth_steps, belly.fullness_growth_steps)

	if(iscarbon(carrier))
		var/mob/living/carbon/carbon_owner = carrier
		// Belly size lives on a visible organ overlay, so force a redraw when it changes.
		carbon_owner.update_body_parts(TRUE)
	return TRUE

/datum/component/belly_fullness/proc/send_fullness_change_message(old_growth_steps, new_growth_steps)
	if(!carrier || old_growth_steps == new_growth_steps)
		return FALSE

	if(new_growth_steps > old_growth_steps)
		if(!COOLDOWN_FINISHED(src, fullness_expand_message_cooldown))
			return FALSE
		COOLDOWN_START(src, fullness_expand_message_cooldown, BELLY_FULLNESS_MESSAGE_COOLDOWN)
		to_chat(carrier, span_small(span_love("My belly bulges outward from all that's stuffed in me.")))
		return TRUE

	if(!COOLDOWN_FINISHED(src, fullness_shrink_message_cooldown))
		return FALSE
	COOLDOWN_START(src, fullness_shrink_message_cooldown, BELLY_FULLNESS_MESSAGE_COOLDOWN)
	to_chat(carrier, span_small(span_love("My belly settles back down as the fullness eases.")))
	return TRUE

/datum/component/belly_fullness/proc/get_total_growth_steps()
	var/total_growth = 0
	var/max_growth = BELLY_BUMP_MAX

	for(var/key in tracked_organs)
		total_growth += get_growth_steps_for_organ(tracked_organs[key])
		if(total_growth >= max_growth)
			return max_growth

	return total_growth

/datum/component/belly_fullness/proc/get_growth_steps_for_organ(obj/item/organ/organ)
	if(!organ)
		return 0

	var/datum/component/body_storage/storage = organ.GetComponent(/datum/component/body_storage)
	if(!storage)
		return 0

	var/inner_capacity = max(1, storage.layer_storage_max_bulk[STORAGE_LAYER_INNER] || 0)
	var/deep_capacity = max(1, storage.layer_storage_max_bulk[STORAGE_LAYER_DEEP] || 0)
	var/inner_bulk = 0
	var/deep_bulk = 0
	if(storage.available_layers[STORAGE_LAYER_INNER])
		inner_bulk += storage.layer_storage_cur_bulk[STORAGE_LAYER_INNER]
	if(storage.available_layers[STORAGE_LAYER_DEEP])
		deep_bulk += storage.layer_storage_cur_bulk[STORAGE_LAYER_DEEP]

	if(istype(organ, /obj/item/organ/genitals/filling_organ))
		var/obj/item/organ/genitals/filling_organ/filling_organ = organ
		if(fluid_fullness_counts_for_organ(filling_organ) && filling_organ.reagents?.maximum_volume > 0)
			// Only foreign fluid inflates; the organ's own wetness or milk never does, matching bloat.
			var/foreign_volume = max(0, filling_organ.reagents.total_volume - filling_organ.get_own_fluid_amount())
			deep_bulk += deep_capacity * foreign_volume / filling_organ.reagents.maximum_volume * 0.5

	return min(
		growth_steps_from_inner_fullness(inner_bulk, inner_capacity) + growth_steps_from_fullness(deep_bulk, deep_capacity),
		BELLY_BUMP_MAX
	)

/datum/component/belly_fullness/proc/get_pregnancy_stage()
	var/obj/item/organ/genitals/filling_organ/womb/womb = tracked_organs[ORGAN_SLOT_WOMB]
	if(!istype(womb) || !womb.pregnant)
		return 0
	return womb.conventional_pregnancy_stage

/datum/component/belly_fullness/proc/fluid_fullness_counts_for_organ(obj/item/organ/genitals/filling_organ/filling_organ)
	if(!istype(filling_organ, /obj/item/organ/genitals/filling_organ/anus) && !istype(filling_organ, /obj/item/organ/genitals/filling_organ/vagina) && !istype(filling_organ, /obj/item/organ/genitals/filling_organ/womb))
		return TRUE
	if(!carrier)
		return FALSE
	return carrier.get_cached_allow_belly_inflation()

/datum/component/belly_fullness/proc/growth_steps_from_fullness(current_bulk, capacity)
	if(current_bulk <= 0 || capacity <= 0)
		return 0
	if(current_bulk >= capacity)
		return 3
	if(current_bulk * 3 >= capacity * 2)
		return 2
	if(current_bulk * 3 >= capacity)
		return 1
	return 0

/datum/component/belly_fullness/proc/growth_steps_from_inner_fullness(current_bulk, capacity)
	if(current_bulk <= 0 || capacity <= 0)
		return 0
	if(current_bulk >= capacity)
		return 2
	if(current_bulk * 2 >= capacity)
		return 1
	return 0

#undef BELLY_FULLNESS_MESSAGE_COOLDOWN
