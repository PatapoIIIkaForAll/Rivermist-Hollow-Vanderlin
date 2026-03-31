/obj/item/organ/genitals/belly
	name = "belly"
	icon = 'modular_rmh/icons/eaglephntm/icons/obj/surgery.dmi'
	icon_state = "belly"
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_STOMACH
	slot = ORGAN_SLOT_BELLY
	accessory_type = /datum/sprite_accessory/genitals/belly
	organ_size = DEFAULT_BELLY_SIZE
	var/resting_size = DEFAULT_BELLY_SIZE

/obj/item/organ/genitals/belly/Initialize()
	. = ..()
	resting_size = organ_size

/obj/item/organ/genitals/belly/Insert(mob/living/M, special, drop_if_replaced)
	. = ..()
	resting_size = CLAMP(organ_size, MIN_BELLY_SIZE, MAX_BELLY_SIZE)
	if(!GetComponent(/datum/component/belly_fullness))
		AddComponent(/datum/component/belly_fullness)

/obj/item/organ/genitals/belly/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	organ_size = resting_size

	var/datum/component/belly_fullness/fullness = GetComponent(/datum/component/belly_fullness)
	qdel(fullness)

/obj/item/organ/genitals/belly/internal
	name = "internal belly"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none

/datum/component/belly_fullness
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/obj/item/organ/genitals/belly/belly
	var/mob/living/carrier
	var/list/tracked_organs = list()

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
	carrier = null
	belly = null
	return ..()

/datum/component/belly_fullness/proc/register_carrier()
	RegisterSignal(carrier, COMSIG_LIVING_LIFE, PROC_REF(handle_life))
	RegisterSignal(carrier, COMSIG_PARENT_QDELETING, PROC_REF(on_carrier_qdeleting))

/datum/component/belly_fullness/proc/unregister_carrier()
	UnregisterSignal(carrier, list(COMSIG_LIVING_LIFE, COMSIG_PARENT_QDELETING))

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

/datum/component/belly_fullness/proc/handle_life(seconds)
	SIGNAL_HANDLER

	refresh_tracked_organs()
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

	var/base_size = CLAMP(belly.resting_size, MIN_BELLY_SIZE, MAX_BELLY_SIZE)
	var/target_size = CLAMP(base_size + get_total_growth_steps(), MIN_BELLY_SIZE, MAX_BELLY_SIZE)
	if(belly.organ_size == target_size)
		return FALSE

	belly.organ_size = target_size
	if(iscarbon(carrier))
		var/mob/living/carbon/carbon_owner = carrier
		// Belly size lives on a visible organ overlay, so force a redraw when it changes.
		carbon_owner.update_body_parts(TRUE)
	return TRUE

/datum/component/belly_fullness/proc/get_total_growth_steps()
	var/total_growth = 0

	for(var/key in tracked_organs)
		total_growth += get_growth_steps_for_organ(tracked_organs[key])
		if(total_growth >= MAX_BELLY_SIZE)
			return MAX_BELLY_SIZE

	return total_growth

/datum/component/belly_fullness/proc/get_growth_steps_for_organ(obj/item/organ/organ)
	if(!organ)
		return 0

	var/datum/component/body_storage/storage = organ.GetComponent(/datum/component/body_storage)
	if(!storage)
		return 0

	var/deep_capacity = max(1, storage.layer_storage_max_bulk[STORAGE_LAYER_DEEP] || 0)
	var/current_bulk = 0
	if(storage.available_layers[STORAGE_LAYER_INNER])
		current_bulk += storage.layer_storage_cur_bulk[STORAGE_LAYER_INNER]
	if(storage.available_layers[STORAGE_LAYER_DEEP])
		current_bulk += storage.layer_storage_cur_bulk[STORAGE_LAYER_DEEP]

	if(istype(organ, /obj/item/organ/genitals/filling_organ))
		var/obj/item/organ/genitals/filling_organ/filling_organ = organ
		if(fluid_fullness_counts_for_organ(filling_organ) && filling_organ.reagents?.maximum_volume > 0)
			current_bulk += deep_capacity * filling_organ.reagents.total_volume / filling_organ.reagents.maximum_volume * 0.5
		current_bulk += round(deep_capacity * filling_organ.conventional_pregnancy_stage / 3)

	return growth_steps_from_fullness(current_bulk, deep_capacity)

/datum/component/belly_fullness/proc/fluid_fullness_counts_for_organ(obj/item/organ/genitals/filling_organ/filling_organ)
	if(!istype(filling_organ, /obj/item/organ/genitals/filling_organ/anus) && !istype(filling_organ, /obj/item/organ/genitals/filling_organ/vagina))
		return TRUE
	if(!carrier?.client?.prefs)
		return TRUE
	return carrier.get_erp_pref(/datum/erp_preference/boolean/allow_belly_inflation)

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
