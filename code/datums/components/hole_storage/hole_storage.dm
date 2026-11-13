/datum/component/body_storage
	var/obj/item/organ/organ_storing
	var/mob/living/owner
	var/applied_slot

	var/list/available_layers = list(
		STORAGE_LAYER_OUTER = FALSE,
		STORAGE_LAYER_INNER = FALSE,
		STORAGE_LAYER_DEEP = FALSE,
	)

	var/list/layer_storage_max_num = list(
		STORAGE_LAYER_OUTER = 1,
		STORAGE_LAYER_INNER = 10,
		STORAGE_LAYER_DEEP = 20,
	)

	/// Must specify for every subtype through the def_bulk_inner def_bulk_deep vals // Outer has high bulk because it has a limit of only 1 anyway, and it's a special case
	var/list/layer_storage_max_bulk = list(
		STORAGE_LAYER_OUTER = 10,
		STORAGE_LAYER_INNER = 1,
		STORAGE_LAYER_DEEP = 1,
	)

	var/list/layer_storage_cur_bulk = list(
		STORAGE_LAYER_OUTER = 0,
		STORAGE_LAYER_INNER = 0,
		STORAGE_LAYER_DEEP = 0,
	)

	var/list/outer_layer_contents = list()
	var/list/inner_layer_contents = list()
	var/list/deep_layer_contents = list()

	var/def_bulk_inner = INNER_LAYER_DEFAULT_BULK
	var/def_bulk_deep = DEEP_LAYER_DEFAULT_BULK

	//A linker of index to item list
	var/list/all_layers = list(
		STORAGE_LAYER_OUTER = null,
		STORAGE_LAYER_INNER = null,
		STORAGE_LAYER_DEEP = null,
	)
	var/max_insert_size = HOLE_MAX_BULK_INSERT

	var/list/outer_overlays = list()

/// Temporary record for moving stored items from an old organ to its regenerated replacement.
/datum/body_storage_transfer_item
	var/obj/item/stored_item
	var/storage_layer

/datum/body_storage_transfer_item/New(obj/item/new_stored_item, new_storage_layer)
	. = ..()
	stored_item = new_stored_item
	storage_layer = new_storage_layer

/datum/component/body_storage/Initialize(obj/item/organ/org, location, mob/living/organ_owner)
	. = ..()
	organ_storing = org
	owner = organ_owner
	if(location)
		applied_slot = location
	else
		applied_slot = organ_storing.slot

	all_layers[STORAGE_LAYER_OUTER] = outer_layer_contents // assembling the linker list
	all_layers[STORAGE_LAYER_INNER] = inner_layer_contents
	all_layers[STORAGE_LAYER_DEEP] = deep_layer_contents

	calculate_bulk()

/datum/component/body_storage/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_BODYSTORAGE_TRY_INSERT, PROC_REF(handle_insertion))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_FORCE_INSERT, PROC_REF(insert_in_storage))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_CHECK_FIT, PROC_REF(check_fit))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_TRY_REMOVE, PROC_REF(handle_removal))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_FORCE_REMOVE, PROC_REF(remove_from_storage))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_GET_LISTS, PROC_REF(return_contents_lists))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_SELECT_RAND_ITEM, PROC_REF(return_random_item_from_layer))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_REMOVE_RAND_ITEM, PROC_REF(remove_random_item_from_layer))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_IS_ITEM_IN, PROC_REF(check_item_in_layer))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_IS_ITEM_TYPE_IN, PROC_REF(check_item_type_in_layer))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_GET_2D_ITEM_LIST, PROC_REF(return_2d_list))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_UPDATE_SIZE, PROC_REF(update_size))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, PROC_REF(find_item_layer))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND, PROC_REF(rand_item_layer_swap))
	RegisterSignal(parent, COMSIG_BODYSTORAGE_TRY_RESIZE, PROC_REF(try_resize_item))

/datum/component/body_storage/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_TRY_INSERT)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_FORCE_INSERT)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_CHECK_FIT)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_TRY_REMOVE)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_FORCE_REMOVE)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_GET_LISTS)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_SELECT_RAND_ITEM)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_REMOVE_RAND_ITEM)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_IS_ITEM_IN)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_IS_ITEM_TYPE_IN)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_GET_2D_ITEM_LIST)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_UPDATE_SIZE)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_SWAP_LAYERS_RAND)
	UnregisterSignal(parent, COMSIG_BODYSTORAGE_TRY_RESIZE)

/datum/component/body_storage/Destroy()
	for(var/obj/item/I as anything in outer_overlays)
		remove_outer_overlay(I)
	organ_storing = null
	owner = null
	applied_slot = null
	outer_layer_contents.Cut()
	inner_layer_contents.Cut()
	deep_layer_contents.Cut()
	all_layers.Cut()
	outer_overlays.Cut()
	return ..()
/**
 * Tries to insert an item into a hole
 * @param incoming_item - The incoming item
 * @param target_layer - The storage layer where we should put the item in
 * @param force - If we are using force to push the item in. Boolean
 * @param override - If the insertion should always succeed. Boolean
*/
/datum/component/body_storage/proc/handle_insertion(datum/source, obj/item/incoming_item, target_layer, force = FALSE, override = FALSE)
	if(QDELETED(incoming_item) || !available_layers[target_layer])
		return FALSE
	var/fit_condition = check_fit(source, incoming_item, target_layer, force, override)
	if(fit_condition == INSERT_FEEDBACK_OK || fit_condition == INSERT_FEEDBACK_OK_FORCE || fit_condition == INSERT_FEEDBACK_ALMOST_FULL || fit_condition == INSERT_FEEDBACK_OK_OVERRIDE)
		insert_in_storage(source, incoming_item, target_layer)
	return fit_condition

/**
 * Inserts an item into a hole
 * @param incoming_item - The incsoming item
 * @param target_layer - The storage layer where we should put the item in
*/
/datum/component/body_storage/proc/insert_in_storage(datum/source, obj/item/incoming_item, target_layer)
	// Usually the organ itself, but an item carrying a live mob hangs off the body instead - an
	// inserted organ sits in nullspace, which would strand the passenger without a turf.
	var/atom/destination = incoming_item.body_storage_destination(organ_storing, owner) || organ_storing
	if(iscarbon(incoming_item.loc))
		var/mob/living/carbon/M = incoming_item.loc
		// Unequip straight to the destination. dropItemToGround() lands the item on a turf first and
		// only then calls dropped(), which is enough for a mob_holder to decide it was dropped and
		// qdel itself mid-insertion, spilling its occupant and leaving a dead holder in the hole.
		M.transferItemToLoc(incoming_item, destination, FALSE, TRUE)
	if(destination == organ_storing && !organ_storing.contains(incoming_item))
		organ_storing.contents += incoming_item
	incoming_item.forceMove(destination)
	var/list/t_layer = all_layers[target_layer]
	t_layer.Add(incoming_item)
	layer_storage_cur_bulk[target_layer] += incoming_item.body_storage_bulk
	organ_storing.on_body_storage_inserted(incoming_item, target_layer)
	incoming_item.on_body_storage_entered(organ_storing, target_layer)
	if(incoming_item.has_body_storage_overlay)
		if(isnull(incoming_item.bstorage_visible_layer) || incoming_item.bstorage_visible_layer == target_layer)
			apply_outer_overlay(incoming_item)
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.update_carry_weight()
	notify_storage_changed()

/**
 * Checks if an item fits in the selected layer
 * @param incoming_item - The incoming item
 * @param target_layer - The storage layer where we should put the item in
 * @param force - If we are using force to push the item in. Boolean
 * @param override - If the insertion should always succeed. Boolean
*/
/datum/component/body_storage/proc/check_fit(datum/source, obj/item/incoming_item, target_layer, force = FALSE, override = FALSE)
	if(!available_layers[target_layer])
		return FALSE

	if(!incoming_item)
		return FALSE

	// A stretched opening changes its room between checks, so refresh before weighing it.
	if(organ_storing.has_dynamic_body_storage())
		calculate_bulk()

	if(!incoming_item.can_enter_body_storage_layer(target_layer))
		return FALSE

	// Openings with a width check judge size by girth instead of this flat cap.
	if(incoming_item.body_storage_bulk > max_insert_size && !organ_storing.has_body_storage_width_check())
		return FALSE

	var/list/t_layer = all_layers[target_layer]

	if(!override && is_body_storage_insertion_blocked(incoming_item, target_layer))
		return INSERT_FEEDBACK_BLOCKED

	if(LAZYLEN(t_layer) >= layer_storage_max_num[target_layer]) //hard cap
		return FALSE

	if(override)
		return INSERT_FEEDBACK_OK_OVERRIDE

	// Width first: one thing too wide for the opening fails before fullness is weighed.
	var/width_feedback = organ_storing.get_body_storage_width_feedback(incoming_item, target_layer, force)
	if(width_feedback != INSERT_FEEDBACK_OK)
		return width_feedback

	var/incoming_bulk = layer_storage_cur_bulk[target_layer] + incoming_item.body_storage_bulk
	if(incoming_bulk > layer_storage_max_bulk[target_layer])
		if(incoming_bulk > layer_storage_max_bulk[target_layer] * 1.5 )
			return INSERT_FEEDBACK_STUFFED
		else
			if(force)
				return INSERT_FEEDBACK_OK_FORCE
			return INSERT_FEEDBACK_TRY_FORCE
	else
		if((layer_storage_max_bulk[target_layer] - layer_storage_cur_bulk[target_layer]) / layer_storage_max_bulk[target_layer] < 0.2)
			return INSERT_FEEDBACK_ALMOST_FULL
		return INSERT_FEEDBACK_OK

/datum/component/body_storage/proc/is_body_storage_insertion_blocked(obj/item/incoming_item, target_layer)
	return has_layer_insertion_blocker(incoming_item, target_layer) || has_equipped_insertion_blocker()

/datum/component/body_storage/proc/has_layer_insertion_blocker(obj/item/incoming_item, target_layer)
	for(var/blocker_layer in all_layers)
		var/list/blocker_layer_contents = all_layers[blocker_layer]
		for(var/obj/item/stored_item as anything in blocker_layer_contents)
			if(stored_item == incoming_item)
				continue
			if(stored_item.blocks_body_storage_insertion(src, incoming_item, target_layer, blocker_layer))
				return TRUE
	return FALSE

/datum/component/body_storage/proc/has_equipped_insertion_blocker()
	if(!owner || !applied_slot)
		return FALSE
	for(var/obj/item/equipped_item as anything in owner.get_equipped_items())
		if(equipped_item.blocks_body_storage_slot(applied_slot))
			return TRUE
	return FALSE

/**
 * Tries to remove an item from a hole
 * @param removed_item - The removed item
 * @param target_layer - The storage layer where we should put the item in
*/
/datum/component/body_storage/proc/handle_removal(datum/source, obj/item/removed_item, target_layer, removal_reason = BODYSTORAGE_REMOVE_MANUAL)
	if(!target_layer)
		target_layer = find_item_layer(source, removed_item)
	if(!removed_item?.can_remove_from_body_storage(removal_reason))
		return FALSE
	if(check_item_in_layer(source, removed_item, target_layer))
		remove_from_storage(source, removed_item, target_layer)
		return TRUE
	else
		return FALSE

/**
 * Removes an item from a hole
 * @param removed_item - The removed item
 * @param target_layer - The storage layer where we should put the item in
 * @param force - If we are using force to push the item in. Boolean
*/
/datum/component/body_storage/proc/remove_from_storage(datum/source, obj/item/removed_item, target_layer)
	organ_storing.contents -= removed_item
	// contents -= leaves the item in nullspace. Most callers relocate it a line later, but anything
	// that reacts in between - a mob_holder being qdel'd, say - would have nowhere to put its
	// occupant. Park it on the body's turf so the item is never homeless mid-removal.
	if(isnull(removed_item.loc))
		var/turf/fallback = get_turf(organ_storing) || get_turf(owner)
		if(fallback)
			removed_item.forceMove(fallback)
	var/list/t_layer = all_layers[target_layer]
	t_layer.Remove(removed_item)
	layer_storage_cur_bulk[target_layer] -= removed_item.body_storage_bulk
	if(removed_item.has_body_storage_overlay)
		remove_outer_overlay(removed_item)
	removed_item.on_body_storage_exited(organ_storing)
	organ_storing.on_body_storage_removed(removed_item, target_layer)
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.update_carry_weight()
	notify_storage_changed()

/datum/component/body_storage/proc/extract_contents_for_organ_regeneration()
	var/list/transfer_items = list()
	for(var/storage_layer in all_layers)
		var/list/layer_contents = all_layers[storage_layer]
		if(!length(layer_contents))
			continue
		for(var/obj/item/stored_item as anything in layer_contents.Copy())
			var/datum/body_storage_transfer_item/transfer_item = new(stored_item, storage_layer)
			transfer_items += transfer_item
			remove_from_storage(parent, stored_item, storage_layer)
			// Anything that hangs off the body rather than sitting in the organ is carrying something
			// that needs a turf, so parking it in nullspace here would strand that passenger.
			if(stored_item.body_storage_destination(organ_storing, owner) == organ_storing)
				stored_item.moveToNullspace()

	return transfer_items

/datum/component/body_storage/proc/restore_contents_after_organ_regeneration(list/transfer_items)
	if(!length(transfer_items))
		return null

	var/list/unrestored_items = list()
	for(var/datum/body_storage_transfer_item/transfer_item as anything in transfer_items)
		if(!transfer_item?.stored_item || QDELETED(transfer_item.stored_item))
			continue
		if(!available_layers[transfer_item.storage_layer])
			unrestored_items += transfer_item
			continue
		insert_in_storage(parent, transfer_item.stored_item, transfer_item.storage_layer)

	return unrestored_items

/**
 * Swaps a random item between two layers. Layers should be different
 * @param source_layer - The layer we remove an item from
 * @param new_layer - The layer we try to put the item in
 * @param force - If we are using force to push the item in. Boolean
*/
/datum/component/body_storage/proc/rand_item_layer_swap(datum/source, source_layer, new_layer, force = FALSE)
	if(!source_layer || !new_layer)
		return FALSE
	if(source_layer == new_layer)
		return FALSE
	var/obj/item/item_a = return_random_item_from_layer(source, source_layer, BODYSTORAGE_REMOVE_RANDOM, TRUE)
	if(!item_a)
		return FALSE
	SEND_SIGNAL(parent, COMSIG_BODYSTORAGE_TRY_REMOVE, item_a, source_layer, BODYSTORAGE_REMOVE_RANDOM)
	return handle_insertion(source, item_a, new_layer, force)

/// Grows or shrinks a stored item's bulk in place; growing follows the same fullness rules as an insertion.
/datum/component/body_storage/proc/try_resize_item(datum/source, obj/item/stored_item, new_bulk, force = FALSE)
	var/target_layer = find_item_layer(source, stored_item)
	if(!target_layer)
		return FALSE
	var/old_bulk = stored_item.body_storage_bulk
	var/max_bulk = layer_storage_max_bulk[target_layer]
	var/new_total = layer_storage_cur_bulk[target_layer] - old_bulk + new_bulk
	var/result = INSERT_FEEDBACK_OK
	if(new_bulk > old_bulk)
		if(new_total > max_bulk * 1.5)
			return INSERT_FEEDBACK_STUFFED
		if(new_total > max_bulk)
			if(!force)
				return INSERT_FEEDBACK_TRY_FORCE
			result = INSERT_FEEDBACK_OK_FORCE
		else if((max_bulk - new_total) / max_bulk < 0.2)
			result = INSERT_FEEDBACK_ALMOST_FULL
	stored_item.body_storage_bulk = new_bulk
	layer_storage_cur_bulk[target_layer] = new_total
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.update_carry_weight()
	notify_storage_changed()
	return result

/**
 * Returns a 3d list of all the layers
*/
/datum/component/body_storage/proc/return_contents_lists(datum/source)
	return all_layers

/**
 * Returns a 3d list of all the layers
*/
/datum/component/body_storage/proc/return_2d_list(datum/source)
	var/list/return_list = list()
	for(var/list in available_layers)
		for(var/el in all_layers[list])
			if(!isnull(el))
				return_list += el
	return return_list

/**
 * Returns the reference to a random irem from selected layer
 * @param target_layer - The target layer
*/
/datum/component/body_storage/proc/return_random_item_from_layer(datum/source, target_layer, removal_reason = BODYSTORAGE_REMOVE_MANUAL, require_random_layer_swap = FALSE)
	var/list/t_layer = all_layers[target_layer]
	if(!t_layer.len)
		return null

	var/list/removable_items = list()
	for(var/obj/item/stored_item as anything in t_layer)
		if(require_random_layer_swap && !stored_item.can_random_body_storage_layer_swap())
			continue
		if(stored_item.can_remove_from_body_storage(removal_reason))
			removable_items += stored_item

	if(removable_items.len)
		return pick(removable_items)

/**
 * Removes and returns the reference to a random irem from selected layer
 * @param target_layer - The target layer
*/
/datum/component/body_storage/proc/remove_random_item_from_layer(datum/source, target_layer)
	var/obj/item/picked_item = return_random_item_from_layer(source, target_layer, BODYSTORAGE_REMOVE_RANDOM)
	if(picked_item)
		if(SEND_SIGNAL(parent, COMSIG_BODYSTORAGE_TRY_REMOVE, picked_item, target_layer, BODYSTORAGE_REMOVE_RANDOM))
			return picked_item

/**
 * Returns the list of available layers
*/
/datum/component/body_storage/proc/return_available_layers(datum/source)
	return available_layers

/**
 * Checks if an item is in a certain layer
 * @param t_item - Item to check for
 * @param target_layer - The target layer
*/
/datum/component/body_storage/proc/check_item_in_layer(datum/source, obj/item/t_item, target_layer)
	if(t_item in all_layers[target_layer])
		return TRUE
	else
		return FALSE

/**
 * Checks if a type is in a certain layer
 * @param type - Type to check for
 * @param target_layer - The target layer
*/
/datum/component/body_storage/proc/check_item_type_in_layer(datum/source, type, target_layer)
	for(var/el in all_layers[target_layer])
		if(istype(el, type))
			return TRUE
	return FALSE

/**
 * Finds which layer the item is in
 * @param t_item - Item to check for
*/
/datum/component/body_storage/proc/find_item_layer(datum/source, obj/item/t_item)
	for(var/list in available_layers)
		for(var/el in all_layers[list])
			if(el == t_item)
				return list
	return null

/**
 * Applies the mob_overlay_icon as an overlay of selected item to the parent mob
 * @param i_item - Item to get overlay from
*/
/datum/component/body_storage/proc/apply_outer_overlay(obj/item/i_item)
	if(!i_item)
		return

	var/icon = i_item.storage_overlay_icon ? i_item.storage_overlay_icon : i_item.mob_overlay_icon
	var/state = i_item.storage_icon_state ? i_item.storage_icon_state : i_item.icon_state
	if(i_item.bstorage_visible_hole && i_item.bstorage_visible_hole == applied_slot)
		state += "_" + i_item.bstorage_visible_hole

	var/mutable_appearance/item_overlay = mutable_appearance(icon, state, -BODY_LAYER)

	owner.add_overlay(item_overlay)
	outer_overlays[i_item] = item_overlay

/**
 * Removes the overlay of selected item from the parent mob
 * @param i_item - Item to remove overlay of
*/
/datum/component/body_storage/proc/remove_outer_overlay(obj/item/i_item)
	if(!i_item)
		return
	if(!outer_overlays[i_item])
		return
	var/mutable_appearance/i_overlay = outer_overlays[i_item]
	owner.cut_overlay(i_overlay)
	outer_overlays -= i_item
	qdel(i_overlay)

/**
 * Calculates the max bulk of the storage
*/
/datum/component/body_storage/proc/calculate_bulk()
	var/organ_size_mult = 1
	var/organ_size_add = 0
	if(istype(organ_storing, /obj/item/organ/genitals))
		var/obj/item/organ/genitals/storing_gen = organ_storing
		organ_size_mult = storing_gen.organ_size
	if(organ_size_mult != 1)
		organ_size_add = organ_size_mult * 2

	layer_storage_max_bulk[STORAGE_LAYER_INNER] = organ_storing.get_body_storage_capacity(STORAGE_LAYER_INNER, def_bulk_inner + organ_size_add)
	layer_storage_max_bulk[STORAGE_LAYER_DEEP] = organ_storing.get_body_storage_capacity(STORAGE_LAYER_DEEP, def_bulk_deep + organ_size_add)

/**
 * Updates the bulk
*/
/datum/component/body_storage/proc/update_size(datum/source)
	calculate_bulk()
	notify_storage_changed()

/datum/component/body_storage/proc/recalculate_current_bulk(datum/source)
	for(var/layer in all_layers)
		var/current_bulk = 0
		var/list/layer_contents = all_layers[layer]
		if(islist(layer_contents))
			for(var/obj/item/stored_item as anything in layer_contents)
				current_bulk += stored_item.body_storage_bulk
		layer_storage_cur_bulk[layer] = current_bulk

	notify_storage_changed()

/datum/component/body_storage/proc/notify_storage_changed()
	SEND_SIGNAL(parent, COMSIG_BODYSTORAGE_CHANGED, src)

/**
 * Returns the layer list from layer index
 * @param index - Target layer
*/
/datum/component/body_storage/proc/return_layer_list_by_index(datum/source, index)
	switch(index)
		if(STORAGE_LAYER_OUTER)
			return outer_layer_contents

		if(STORAGE_LAYER_INNER)
			return inner_layer_contents

		if(STORAGE_LAYER_DEEP)
			return deep_layer_contents

/**
 * Helper for adding the storage comp to organs
 * @param the_mob - Parent mob
 * @param location - organ_slot, if we somehow want to add the storage to different slot
 * @param hole_type - The hole component type to add
*/
/obj/item/organ/proc/add_bodystorage(mob/living/the_mob, location = null, hole_type)
	if(!GetComponent(hole_type))
		AddComponent(hole_type, src, location, the_mob)
		if(the_mob)
			SEND_SIGNAL(the_mob, COMSIG_LIVING_ORGAN_CHANGED, src, location || slot, TRUE)

/// TRUE if this organ carries a body-storage "hole" (genitals, guts, etc.). Such organs never take
/// damage but DO hold items - plugs, oviposition eggs, pregnancy holders - so a heal must not
/// regenerate them out from under their contents.
/obj/item/organ/proc/is_body_storage_organ()
	return !isnull(GetComponent(/datum/component/body_storage))

/obj/item/organ/proc/extract_body_storage_contents_for_regeneration()
	var/datum/component/body_storage/storage = GetComponent(/datum/component/body_storage)
	if(!storage)
		return null
	return storage.extract_contents_for_organ_regeneration()

/obj/item/organ/proc/restore_body_storage_contents_after_regeneration(list/transfer_items)
	var/datum/component/body_storage/storage = GetComponent(/datum/component/body_storage)
	if(!storage)
		return transfer_items
	return storage.restore_contents_after_organ_regeneration(transfer_items)

/proc/release_body_storage_transfer_items(list/transfer_items, atom/release_location)
	if(!length(transfer_items))
		return

	for(var/datum/body_storage_transfer_item/transfer_item as anything in transfer_items)
		if(!transfer_item?.stored_item || QDELETED(transfer_item.stored_item))
			continue
		if(release_location)
			transfer_item.stored_item.forceMove(release_location)
		else
			transfer_item.stored_item.moveToNullspace()

/obj/item/organ/proc/on_body_storage_inserted(obj/item/inserted_item, target_layer)
	return

/obj/item/organ/proc/on_body_storage_removed(obj/item/removed_item, target_layer)
	return

/// Bulk a layer holds; stretchable openings grow it with their current girth.
/obj/item/organ/proc/get_body_storage_capacity(layer, base_bulk)
	return base_bulk

/// TRUE when capacity can change between checks and must be refreshed first.
/obj/item/organ/proc/has_dynamic_body_storage()
	return FALSE

/// TRUE when insertions are judged by girth, so the flat bulk cap does not apply.
/obj/item/organ/proc/has_body_storage_width_check()
	return FALSE

/// INSERT_FEEDBACK_OK, or the feedback for an item too wide for the opening.
/obj/item/organ/proc/get_body_storage_width_feedback(obj/item/incoming_item, target_layer, force)
	return INSERT_FEEDBACK_OK


/mob/living/proc/get_organs_items()
	var/list/res = list()
	for(var/obj/item/organ/org in internal_organs)
		if(org.contents.len)
			for(var/obj/item/el in org.contents)
				res += el
	return res
