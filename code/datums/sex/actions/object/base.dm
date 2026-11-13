
/datum/sex_action/object_fuck
	abstract_type = /datum/sex_action/object_fuck
	name = "object_fuck"
	requires_hole_storage = TRUE
	requires_free_hands = TRUE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	hole_id = ORGAN_SLOT_VAGINA
	stored_item_type = /obj/item/penetration_standin
	/// The toy this runtime action started with. If it leaves the active hand, the action stops.
	var/obj/item/selected_toy
	/// FALSE when the toy is not held, such as a toy standing on a surface; then no hand is claimed.
	var/toy_in_hand = TRUE

/datum/sex_action/object_fuck/proc/get_selected_toy(mob/living/user, mob/living/target)
	var/mob/living/storage_insertor = get_storage_insertor(user, target)
	if(!storage_insertor)
		return null
	return storage_insertor.get_active_held_item()

/datum/sex_action/object_fuck/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/storage_insertor = get_storage_insertor(user, target)
	var/mob/living/storage_receiver = get_storage_receiver(user, target)
	var/obj/item/item_to_check = get_storage_check_item(user, target)
	if(!storage_insertor || !storage_receiver || !item_to_check)
		return FALSE
	if(selected_toy && item_to_check != selected_toy)
		return FALSE

	if(toy_in_hand && check_sex_lock(storage_insertor, storage_insertor.get_active_precise_hand()))
		return FALSE
	if(check_sex_lock(storage_insertor, null, item_to_check))
		return FALSE
	return TRUE

/datum/sex_action/object_fuck/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	// run_runtime() gates on can_run(TRUE) before it calls on_start(), so on the first pass the toy
	// has not been chosen yet. Demanding selected_toy here stopped the action before it ever began -
	// any toy in hand is enough until on_start() picks one.
	if(!selected_toy)
		return get_storage_check_item(user, target) != null
	// Dropping the toy ends the action even if it lands on the tile everyone is standing on.
	return get_storage_check_item(user, target) == selected_toy

/datum/sex_action/object_fuck/on_start(mob/living/user, mob/living/target)
	selected_toy = get_storage_check_item(user, target)
	if(!selected_toy)
		return FALSE
	return ..()

/datum/sex_action/object_fuck/lock_sex_object(mob/living/user, mob/living/target)
	var/mob/living/storage_insertor = get_storage_insertor(user, target)
	var/mob/living/storage_receiver = get_storage_receiver(user, target)
	var/obj/item/item_to_lock = get_storage_check_item(user, target)
	if(storage_insertor)
		add_sex_lock(storage_insertor, storage_insertor.get_active_precise_hand())
	if(storage_insertor && item_to_lock)
		add_sex_lock(storage_insertor, null, item_to_lock)
	if(storage_receiver && hole_id)
		add_sex_lock(storage_receiver, hole_id, null, FALSE)

/datum/sex_action/object_fuck/on_finish(mob/living/user, mob/living/target)
	// The pull-out in the parent still reads the toy, for its flare.
	. = ..()
	selected_toy = null

/datum/sex_action/object_fuck/get_storage_check_item(mob/living/user, mob/living/target)
	var/mob/living/storage_insertor = get_storage_insertor(user, target)
	return get_sextoy_in_hand(storage_insertor)

#define MAX_TOY_SIZE WEIGHT_CLASS_NORMAL

/proc/get_sextoy_in_hand(mob/living/user)
	if(!user)
		return null

	var/obj/item/thing = user.get_active_held_item()
	if(thing != null && thing.w_class <= MAX_TOY_SIZE) // Allow small toys like dildos, not just tiny items.
		return thing
	return null

#undef MAX_TOY_SIZE
