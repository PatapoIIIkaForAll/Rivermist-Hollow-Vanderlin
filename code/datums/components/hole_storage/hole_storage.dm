#define STORAGE_LAYER_OUTER "layer_outer"
#define STORAGE_LAYER_INNER "layer_inner"
#define STORAGE_LAYER_DEEP "layer_deep"

#define INSERT_FEEDBACK_OK "feedback_ok"
#define INSERT_FEEDBACK_OK_FORCE "feedback_ok_force"
#define INSERT_FEEDBACK_OK_OVERRIDE "feedback_override"
#define INSERT_FEEDBACK_ALMOST_FULL "feedback_almost"
#define INSERT_FEEDBACK_STUFFED "feedback_stuffed"
#define INSERT_FEEDBACK_TRY_FORCE "feedback_try_force"

#define OUTER_LAYER_DEFAULT_BULK 1
#define INNER_LAYER_DEFAULT_BULK 8
#define DEEP_LAYER_DEFAULT_BULK 15

#define HOLE_MAX_BULK_INSERT 10 //we want to have it possible that a sufficiently big insertible will trigger stretching on it's own

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
	var/max_stretching_mult = 1 /// Will NOT stretch at 1, must specify for subtypes if you want stretching

	var/list/outer_overlays = list()

/datum/component/body_storage/Initialize(obj/item/organ/org, location = null, mob/living/organ_owner)
	. = ..()
	organ_storing = org
	owner = organ_owner
	if(location)
		applied_slot = location
	else
		location = organ_storing.slot

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

/datum/component/body_storage/Destroy()
	. = ..()
	for (var/obj/item/I in outer_overlays)
		remove_outer_overlay(I)
/**
 * Tries to insert an item into a hole
 * @param incoming_item - The incoming item
 * @param target_layer - The storage layer where we should put the item in
 * @param force - If we are using force to push the item in. Boolean
 * @param override - If the insertion should always succeed. Boolean
*/
/datum/component/body_storage/proc/handle_insertion(datum/source, obj/item/incoming_item, target_layer, force = FALSE, override = FALSE)
	if(!available_layers[target_layer])
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
	if(iscarbon(incoming_item.loc))
		var/mob/living/carbon/M = incoming_item.loc
		M.dropItemToGround(incoming_item, FALSE, TRUE)
	if(!(organ_storing.contains(incoming_item)))
		organ_storing.contents += incoming_item
	incoming_item.forceMove(organ_storing)
	var/list/t_layer = all_layers[target_layer]
	t_layer.Add(incoming_item)
	layer_storage_cur_bulk[target_layer] += incoming_item.body_storage_bulk
	var/diff = layer_storage_cur_bulk[target_layer] - layer_storage_max_bulk[target_layer]
	if(incoming_item.has_body_storage_overlay && incoming_item.bstorage_visible_layer == target_layer)
		apply_outer_overlay(incoming_item)
	if(diff > 0)
		handle_stretch(source, diff)
	owner.encumbrance_to_speed()
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

	if(incoming_item.body_storage_bulk > max_insert_size)
		return FALSE

	var/list/t_layer = all_layers[target_layer]

	if(LAZYLEN(t_layer) >= layer_storage_max_num[target_layer]) //hard cap
		return FALSE

	if(override)
		return INSERT_FEEDBACK_OK_OVERRIDE

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

/**
 * Tries to remove an item from a hole
 * @param removed_item - The removed item
 * @param target_layer - The storage layer where we should put the item in
*/
/datum/component/body_storage/proc/handle_removal(datum/source, obj/item/removed_item, target_layer, removal_reason = BODYSTORAGE_REMOVE_MANUAL)
	if(!target_layer)
		target_layer = find_item_layer(removed_item)
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
	var/list/t_layer = all_layers[target_layer]
	t_layer.Remove(removed_item)
	layer_storage_cur_bulk[target_layer] -= removed_item.body_storage_bulk
	if(removed_item.has_body_storage_overlay)
		remove_outer_overlay(removed_item)
	owner.encumbrance_to_speed()
	notify_storage_changed()

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
	var/obj/item/item_a = return_random_item_from_layer(source, source_layer, BODYSTORAGE_REMOVE_RANDOM)
	if(!item_a)
		return FALSE
	SEND_SIGNAL(parent, COMSIG_BODYSTORAGE_TRY_REMOVE, item_a, source_layer, BODYSTORAGE_REMOVE_RANDOM)
	return handle_insertion(source, item_a, new_layer, force)

/**
 * Handles the stretching of our parent organ
 * @param size_diff - The over-the-limit value of inserted item
*/
/datum/component/body_storage/proc/handle_stretch(datum/source, size_diff)
	if(istype(organ_storing, /obj/item/organ/genitals/filling_organ) || organ_storing.stretchable)
		if(organ_storing.stretched_coefficient < max_stretching_mult)
			organ_storing.get_stretched(size_diff)

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
/datum/component/body_storage/proc/return_random_item_from_layer(datum/source, target_layer, removal_reason = BODYSTORAGE_REMOVE_MANUAL)
	var/list/t_layer = all_layers[target_layer]
	if(!t_layer.len)
		return null

	var/list/removable_items = list()
	for(var/obj/item/stored_item as anything in t_layer)
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

	layer_storage_max_bulk[STORAGE_LAYER_INNER] = (def_bulk_inner + organ_size_add) * organ_storing.stretched_coefficient //setting up default max bulk
	layer_storage_max_bulk[STORAGE_LAYER_DEEP] = (def_bulk_deep + organ_size_add) * organ_storing.stretched_coefficient

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


/mob/living/proc/get_organs_items()
	var/list/res = list()
	for(var/obj/item/organ/org in internal_organs)
		if(org.contents.len)
			for(var/obj/item/el in org.contents)
				res += el
	return res
