/datum/map_template/pocket
	name = "_pocket_base"
	id = "_pocket_base"
	keep_cached_map = TRUE
	var/padding = 1
	var/lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	var/idle_timeout = POCKET_DEFAULT_IDLE_TIMEOUT
	var/persistence_mode = POCKET_PERSISTENCE_NONE
	var/exit_structure_type = /obj/structure/pocket_dimension_exit

/proc/is_valid_pocket_lifecycle_policy(policy)
	return policy == POCKET_LIFECYCLE_KEEP_LOADED || policy == POCKET_LIFECYCLE_HIBERNATE || policy == POCKET_LIFECYCLE_COLLAPSE

/proc/format_pocket_lifecycle_policy(policy)
	switch(policy)
		if(POCKET_LIFECYCLE_KEEP_LOADED)
			return "keep loaded"
		if(POCKET_LIFECYCLE_HIBERNATE)
			return "hibernate"
		if(POCKET_LIFECYCLE_COLLAPSE)
			return "collapse"
	return "unknown"

/proc/is_valid_pocket_persistence_mode(mode)
	return mode == POCKET_PERSISTENCE_NONE || mode == POCKET_PERSISTENCE_MOVABLES

/proc/format_pocket_persistence_mode(mode)
	switch(mode)
		if(POCKET_PERSISTENCE_NONE)
			return "none"
		if(POCKET_PERSISTENCE_MOVABLES)
			return "movables"
	return "unknown"

/datum/pocket_movable_snapshot
	var/atom/movable/movable
	var/offset_x = 0
	var/offset_y = 0
	var/removed = FALSE

/datum/pocket_dimension
	var/instance_id
	var/instance_key
	var/datum/map_template/pocket/template
	var/lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	var/idle_timeout = POCKET_DEFAULT_IDLE_TIMEOUT
	var/persistence_mode = POCKET_PERSISTENCE_NONE
	var/state = POCKET_STATE_HIBERNATING
	var/last_touched = 0
	var/datum/turf_reservation/reservation
	var/turf/load_turf
	var/turf/return_turf
	var/datum/weakref/return_anchor_ref
	var/list/affected_turfs = list()
	var/list/turf/entry_turfs = list()
	var/list/turf/drop_turfs = list()
	var/list/obj/structure/pocket_dimension_exit/exit_objects = list()
	var/list/area/managed_areas = list()
	var/list/atom/movable/native_movables = list()
	var/list/native_movable_keys = list()
	var/list/atom/movable/native_movables_by_key = list()
	var/list/native_slot_offsets = list()
	var/list/atom/movable/snapshotted_native_movables = list()
	var/list/datum/pocket_movable_snapshot/native_snapshots = list()
	var/list/datum/pocket_movable_snapshot/hibernated_foreign_movables = list()
	var/obj/effect/abstract/pocket_dimension_storage/storage

/datum/pocket_dimension/New(datum/map_template/pocket/template, instance_key, instance_id, lifecycle_policy, idle_timeout)
	src.template = template
	src.instance_key = instance_key
	src.instance_id = instance_id
	apply_lifecycle_settings(lifecycle_policy, idle_timeout)
	touch()
	. = ..()

/datum/pocket_dimension/Destroy(force)
	if(SSpocket_dimensions)
		SSpocket_dimensions.unregister_instance(src)

	// Fail safe: even if someone qdel()s the pocket datum directly, expel any
	// living occupants and foreign movables before we tear the room or storage down.
	eject_teardown_contents()
	release_loaded_layout()
	QDEL_LIST_ASSOC_VAL(native_snapshots)
	QDEL_LIST_ASSOC_VAL(hibernated_foreign_movables)
	snapshotted_native_movables.Cut()
	QDEL_NULL(storage)

	template = null
	instance_key = null
	persistence_mode = null
	state = null
	last_touched = 0
	return_turf = null
	return_anchor_ref = null
	return ..()

/datum/pocket_dimension/proc/apply_lifecycle_settings(new_lifecycle_policy = null, new_idle_timeout = null)
	if(!isnull(new_lifecycle_policy) && is_valid_pocket_lifecycle_policy(new_lifecycle_policy))
		lifecycle_policy = new_lifecycle_policy
	else
		lifecycle_policy = template?.lifecycle_policy || POCKET_LIFECYCLE_KEEP_LOADED

	if(!isnull(new_idle_timeout))
		idle_timeout = max(0, new_idle_timeout)
	else
		idle_timeout = max(0, template?.idle_timeout || 0)

	if(is_valid_pocket_persistence_mode(template?.persistence_mode))
		persistence_mode = template.persistence_mode
	else
		persistence_mode = POCKET_PERSISTENCE_NONE

/datum/pocket_dimension/proc/touch()
	last_touched = world.time

/datum/pocket_dimension/proc/is_hibernating()
	return state == POCKET_STATE_HIBERNATING && !reservation

/datum/pocket_dimension/proc/uses_movable_snapshot_persistence()
	return persistence_mode == POCKET_PERSISTENCE_MOVABLES

/datum/pocket_dimension/proc/release_loaded_layout()
	for(var/obj/structure/pocket_dimension_exit/exit_object as anything in exit_objects)
		exit_object.linked_pocket = null

	for(var/area/current_area as anything in managed_areas)
		if(!istype(current_area, /area/pocket_dimension))
			continue
		var/area/pocket_dimension/pocket_area = current_area
		if(pocket_area.linked_pocket == src)
			pocket_area.linked_pocket = null

	QDEL_LIST(exit_objects)
	managed_areas.Cut()
	entry_turfs.Cut()
	drop_turfs.Cut()
	affected_turfs.Cut()
	native_movables.Cut()
	native_movable_keys.Cut()
	native_movables_by_key.Cut()
	native_slot_offsets.Cut()
	load_turf = null

	QDEL_NULL(reservation)
	state = POCKET_STATE_HIBERNATING

/datum/pocket_dimension/proc/activate()
	if(reservation)
		state = POCKET_STATE_ACTIVE
		touch()
		return TRUE
	if(!template?.width || !template?.height)
		return FALSE

	var/padded_width = template.width + (template.padding * 2)
	var/padded_height = template.height + (template.padding * 2)
	reservation = SSmapping.RequestPocketBlockReservation(padded_width, padded_height)
	if(!reservation)
		return FALSE

	load_turf = locate(
		reservation.bottom_left_coords[1] + template.padding,
		reservation.bottom_left_coords[2] + template.padding,
		reservation.bottom_left_coords[3],
	)
	if(!load_turf || !template.load(load_turf))
		load_turf = null
		QDEL_NULL(reservation)
		return FALSE

	seal_padding_ring()
	cache_loaded_layout()
	state = POCKET_STATE_ACTIVE
	restore_hibernated_layout()
	touch()
	return TRUE

/datum/pocket_dimension/proc/seal_padding_ring()
	if(!reservation || !load_turf || !template?.padding)
		return

	var/min_inner_x = load_turf.x
	var/min_inner_y = load_turf.y
	var/max_inner_x = load_turf.x + template.width - 1
	var/max_inner_y = load_turf.y + template.height - 1

	for(var/turf/border_turf as anything in reservation.reserved_turfs)
		var/is_inside_loaded_room = border_turf.x >= min_inner_x && border_turf.x <= max_inner_x && border_turf.y >= min_inner_y && border_turf.y <= max_inner_y
		if(is_inside_loaded_room)
			continue
		if(istype(border_turf, /turf/closed/indestructible/pocket_border))
			continue

		border_turf.ChangeTurf(/turf/closed/indestructible/pocket_border, /turf/closed/indestructible/pocket_border)

/datum/pocket_dimension/proc/should_track_native_movable(atom/movable/movable)
	if(!movable || QDELETED(movable) || ismob(movable))
		return FALSE
	if(istype(movable, /obj/structure/pocket_dimension_exit))
		return FALSE
	if(istype(movable, /obj/effect/abstract/pocket_dimension_storage))
		return FALSE
	return TRUE

/datum/pocket_dimension/proc/build_native_slot_key(atom/movable/movable, turf/current_turf, list/slot_counts)
	var/offset_x = current_turf.x - load_turf.x
	var/offset_y = current_turf.y - load_turf.y
	var/slot_prefix = "[movable.type]@[offset_x],[offset_y]"
	var/slot_index = (slot_counts[slot_prefix] || 0) + 1
	slot_counts[slot_prefix] = slot_index
	return "[slot_prefix]#[slot_index]"

/datum/pocket_dimension/proc/register_native_movable(atom/movable/movable, slot_key, turf/current_turf)
	if(!movable || !slot_key)
		return

	native_movables[movable] = TRUE
	native_movable_keys[movable] = slot_key
	native_movables_by_key[slot_key] = movable
	native_slot_offsets[slot_key] = list(
		current_turf.x - load_turf.x,
		current_turf.y - load_turf.y,
	)

/datum/pocket_dimension/proc/create_exit_object(obj/effect/landmark/pocket_dimension/exit/exit_marker, turf/current_turf)
	var/exit_type = exit_marker?.exit_structure_type || template?.exit_structure_type || /obj/structure/pocket_dimension_exit
	if(!ispath(exit_type, /obj/structure/pocket_dimension_exit))
		exit_type = /obj/structure/pocket_dimension_exit

	var/obj/structure/pocket_dimension_exit/exit_object = new exit_type(current_turf)
	exit_object.linked_pocket = src
	return exit_object

/datum/pocket_dimension/proc/cache_loaded_layout()
	affected_turfs.Cut()
	entry_turfs.Cut()
	drop_turfs.Cut()
	managed_areas.Cut()
	native_movables.Cut()
	native_movable_keys.Cut()
	native_movables_by_key.Cut()
	native_slot_offsets.Cut()
	QDEL_LIST(exit_objects)
	exit_objects = list()
	var/list/native_slot_counts = list()

	var/list/turfs = template.get_affected_turfs(load_turf)
	for(var/turf/current_turf as anything in turfs)
		affected_turfs[current_turf] = TRUE

		var/area/current_area = get_area(current_turf)
		managed_areas |= current_area

		for(var/obj/effect/landmark/pocket_dimension/entry/entry_marker in current_turf)
			entry_turfs += current_turf
			qdel(entry_marker)

		for(var/obj/effect/landmark/pocket_dimension/drop_spot/drop_marker in current_turf)
			drop_turfs += current_turf
			qdel(drop_marker)

		for(var/obj/effect/landmark/pocket_dimension/exit/exit_marker in current_turf)
			var/obj/structure/pocket_dimension_exit/exit_object = create_exit_object(exit_marker, current_turf)
			if(exit_object)
				exit_objects += exit_object
			qdel(exit_marker)

		for(var/atom/movable/movable as anything in current_turf)
			native_movables[movable] = TRUE
			if(!should_track_native_movable(movable))
				continue

			var/slot_key = build_native_slot_key(movable, current_turf, native_slot_counts)
			register_native_movable(movable, slot_key, current_turf)

	if(!length(entry_turfs))
		var/turf/fallback_entry = get_center_turf()
		if(fallback_entry)
			entry_turfs += fallback_entry

	if(!length(exit_objects) && length(entry_turfs))
		var/obj/structure/pocket_dimension_exit/fallback_exit = create_exit_object(null, entry_turfs[1])
		if(fallback_exit)
			exit_objects += fallback_exit

	for(var/area/current_area as anything in managed_areas)
		if(!istype(current_area, /area/pocket_dimension))
			continue

		var/area/pocket_dimension/pocket_area = current_area
		pocket_area.linked_pocket = src
		pocket_area.name = "[template.name] #[instance_id]"

	for(var/obj/structure/pocket_dimension_exit/exit_object as anything in exit_objects)
		native_movables[exit_object] = TRUE

/datum/pocket_dimension/proc/get_occupants()
	var/list/occupants = list()

	for(var/turf/current_turf as anything in affected_turfs)
		for(var/atom/movable/potential_occupant as anything in current_turf.get_all_contents())
			if(!ismob(potential_occupant))
				continue
			var/mob/occupant = potential_occupant
			if(QDELETED(occupant) || occupants[occupant] || !contains_turf(get_turf(occupant)))
				continue
			occupants[occupant] = TRUE

	return occupants

/datum/pocket_dimension/proc/has_occupants()
	return !!length(get_occupants())

/datum/pocket_dimension/proc/get_center_turf()
	if(!load_turf)
		return null
	return locate(
		load_turf.x + round((template.width - 1) * 0.5),
		load_turf.y + round((template.height - 1) * 0.5),
		load_turf.z,
	)

/datum/pocket_dimension/proc/get_entry_turf()
	if(length(entry_turfs))
		return pick(entry_turfs)
	return get_center_turf()

/datum/pocket_dimension/proc/get_relative_turf(offset_x, offset_y)
	if(!load_turf)
		return null
	return locate(load_turf.x + offset_x, load_turf.y + offset_y, load_turf.z)

/datum/pocket_dimension/proc/is_valid_drop_turf(turf/target, atom/movable/movable)
	if(!target || QDELETED(target) || !contains_turf(target) || !isopenturf(target))
		return FALSE
	return !target.is_blocked_turf(TRUE, movable)

/datum/pocket_dimension/proc/get_drop_turf(atom/movable/movable)
	if(length(drop_turfs))
		var/list/turf/valid_drop_spots = list()
		for(var/turf/drop_turf as anything in drop_turfs)
			if(is_valid_drop_turf(drop_turf, movable))
				valid_drop_spots += drop_turf
		if(length(valid_drop_spots))
			return pick(valid_drop_spots)

	var/list/turf/fallback_turfs = list()
	for(var/turf/current_turf as anything in affected_turfs)
		if(!is_valid_drop_turf(current_turf, movable))
			continue
		fallback_turfs += current_turf

	if(length(fallback_turfs))
		return pick(fallback_turfs)
	return get_entry_turf() || get_center_turf()

/datum/pocket_dimension/proc/get_return_turf()
	var/atom/return_anchor = return_anchor_ref?.resolve()
	if(return_anchor && !QDELETED(return_anchor))
		var/turf/anchor_turf = get_turf(return_anchor)
		if(anchor_turf && !QDELETED(anchor_turf))
			return anchor_turf
	if(isturf(return_turf) && !QDELETED(return_turf))
		return return_turf
	return find_safe_turf()

/datum/pocket_dimension/proc/set_return_target(turf/new_return_turf = null, atom/new_return_anchor = null)
	if(new_return_anchor && !QDELETED(new_return_anchor))
		return_anchor_ref = WEAKREF(new_return_anchor)
	else if(new_return_turf)
		return_anchor_ref = null

	if(new_return_turf)
		return_turf = new_return_turf

/datum/pocket_dimension/proc/contains_turf(turf/target)
	if(!target)
		return FALSE
	return !!affected_turfs[target]

/datum/pocket_dimension/proc/enter_mob(mob/user, turf/new_return_turf, atom/new_return_anchor = null)
	if(!user)
		return FALSE
	if(!reservation && !activate())
		return FALSE

	if(new_return_turf || new_return_anchor)
		set_return_target(new_return_turf, new_return_anchor)

	var/turf/entry_turf = get_entry_turf()
	if(!entry_turf)
		return FALSE

	touch()
	user.forceMove(entry_turf)
	return TRUE

/datum/pocket_dimension/proc/send_movable_inside(atom/movable/movable, turf/new_return_turf = null, turf/forced_drop_turf = null, atom/new_return_anchor = null)
	if(!movable || QDELETED(movable))
		return FALSE
	if(!reservation && !activate())
		return FALSE

	if((new_return_turf || new_return_anchor) && (!isturf(return_turf) || QDELETED(return_turf) || !has_occupants() || new_return_anchor))
		set_return_target(new_return_turf, new_return_anchor)

	var/turf/drop_turf = forced_drop_turf
	if(!is_valid_drop_turf(drop_turf, movable))
		drop_turf = get_drop_turf(movable)
	if(!drop_turf)
		return FALSE

	touch()
	return transfer_foreign_movable(movable, drop_turf)

/datum/pocket_dimension/proc/exit_mob(mob/user)
	if(!user)
		return FALSE

	var/turf/target = get_return_turf()
	if(!target)
		return FALSE

	touch()
	user.forceMove(target)
	return TRUE

/datum/pocket_dimension/proc/eject_occupants(message = null)
	var/turf/target = get_return_turf()
	if(!target)
		return

	for(var/mob/occupant as anything in get_occupants())
		if(!ismob(occupant) || QDELETED(occupant))
			continue
		if(message)
			to_chat(occupant, span_warning(message))
		occupant.forceMove(target)

/datum/pocket_dimension/proc/eject_all(message = null)
	return eject_occupants(message)

/datum/pocket_dimension/proc/is_native_snapshot_movable(atom/movable/movable)
	if(!movable || QDELETED(movable))
		return FALSE
	return native_movables[movable] || snapshotted_native_movables[movable]

/datum/pocket_dimension/proc/should_preserve_foreign_movable(atom/movable/movable, items_only = FALSE)
	if(!movable || QDELETED(movable) || is_native_snapshot_movable(movable) || ismob(movable))
		return FALSE
	if(items_only && !isitem(movable))
		return FALSE
	return TRUE

/datum/pocket_dimension/proc/collect_preservable_foreign_movables(atom/source, list/targets, list/visited, items_only = FALSE, skip_native_snapshot_contents = FALSE)
	if(!source)
		return

	for(var/atom/movable/movable as anything in source.contents)
		if(QDELETED(movable) || visited[movable])
			continue
		visited[movable] = TRUE

		if(should_preserve_foreign_movable(movable, items_only))
			targets += movable
			continue

		if(skip_native_snapshot_contents && native_movable_keys[movable])
			continue

		collect_preservable_foreign_movables(movable, targets, visited, items_only, skip_native_snapshot_contents)

/datum/pocket_dimension/proc/get_preservable_foreign_movables(items_only = FALSE, skip_native_snapshot_contents = FALSE)
	var/list/foreign_movables = list()
	var/list/visited = list()

	for(var/turf/current_turf as anything in affected_turfs)
		collect_preservable_foreign_movables(current_turf, foreign_movables, visited, items_only, skip_native_snapshot_contents)

	if(storage)
		collect_preservable_foreign_movables(storage, foreign_movables, visited, items_only, skip_native_snapshot_contents)

	return foreign_movables

/datum/pocket_dimension/proc/transfer_foreign_movable(atom/movable/movable, atom/new_loc)
	if(!movable || !new_loc || QDELETED(movable))
		return FALSE

	var/mob/item_holder = ismob(movable.loc) ? movable.loc : null
	if(item_holder && isitem(movable) && !item_holder.temporarilyRemoveItemFromInventory(movable, TRUE))
		return FALSE

	return movable.forceMove(new_loc)

/datum/pocket_dimension/proc/eject_foreign_movables(items_only = FALSE)
	var/turf/target = get_return_turf()
	if(!target)
		return

	for(var/atom/movable/movable as anything in get_preservable_foreign_movables(items_only))
		transfer_foreign_movable(movable, target)

	QDEL_LIST_ASSOC_VAL(hibernated_foreign_movables)
	if(storage && !length(storage.contents))
		QDEL_NULL(storage)

/datum/pocket_dimension/proc/eject_teardown_contents(message = null)
	eject_occupants(message)
	eject_foreign_movables()

/datum/pocket_dimension/proc/ensure_storage()
	if(!storage)
		storage = new
	return storage

/datum/pocket_dimension/proc/capture_foreign_movables_for_hibernation(skip_native_snapshot_contents = FALSE)
	var/obj/effect/abstract/pocket_dimension_storage/hibernate_storage = ensure_storage()
	if(!hibernate_storage || !load_turf)
		return

	QDEL_LIST_ASSOC_VAL(hibernated_foreign_movables)

	for(var/atom/movable/movable as anything in get_preservable_foreign_movables(FALSE, skip_native_snapshot_contents))
		var/turf/movable_turf = get_turf(movable)
		if(!contains_turf(movable_turf))
			continue

		var/datum/pocket_movable_snapshot/snapshot = new
		snapshot.movable = movable
		snapshot.offset_x = movable_turf.x - load_turf.x
		snapshot.offset_y = movable_turf.y - load_turf.y

		if(!transfer_foreign_movable(movable, hibernate_storage))
			qdel(snapshot)
			continue

		hibernated_foreign_movables[movable] = snapshot

/datum/pocket_dimension/proc/capture_native_snapshots()
	if(!uses_movable_snapshot_persistence())
		QDEL_LIST_ASSOC_VAL(native_snapshots)
		snapshotted_native_movables.Cut()
		return

	var/obj/effect/abstract/pocket_dimension_storage/hibernate_storage = ensure_storage()
	if(!hibernate_storage || !load_turf)
		return

	QDEL_LIST_ASSOC_VAL(native_snapshots)
	snapshotted_native_movables.Cut()

	for(var/slot_key in native_slot_offsets)
		var/datum/pocket_movable_snapshot/snapshot = new
		var/atom/movable/native_movable = native_movables_by_key[slot_key]
		if(!native_movable || QDELETED(native_movable))
			snapshot.removed = TRUE
			native_snapshots[slot_key] = snapshot
			continue

		var/turf/native_turf = get_turf(native_movable)
		if(!contains_turf(native_turf))
			snapshot.removed = TRUE
			native_snapshots[slot_key] = snapshot
			continue

		snapshot.movable = native_movable
		snapshot.offset_x = native_turf.x - load_turf.x
		snapshot.offset_y = native_turf.y - load_turf.y

		if(!native_movable.forceMove(hibernate_storage))
			snapshot.movable = null
			snapshot.removed = TRUE
		else
			snapshotted_native_movables[native_movable] = TRUE

		native_snapshots[slot_key] = snapshot

/datum/pocket_dimension/proc/restore_native_snapshots()
	if(!uses_movable_snapshot_persistence() || !length(native_snapshots) || !load_turf)
		return

	var/turf/fallback_turf = get_entry_turf() || get_center_turf()
	for(var/slot_key in native_snapshots)
		var/atom/movable/template_movable = native_movables_by_key[slot_key]
		if(template_movable)
			native_movables -= template_movable
			native_movable_keys -= template_movable
			native_movables_by_key -= slot_key
			template_movable.moveToNullspace()
			qdel(template_movable)

		var/datum/pocket_movable_snapshot/snapshot = native_snapshots[slot_key]
		if(!snapshot || snapshot.removed || !snapshot.movable || QDELETED(snapshot.movable))
			continue

		var/turf/restore_turf = get_relative_turf(snapshot.offset_x, snapshot.offset_y)
		if(!restore_turf || !contains_turf(restore_turf))
			restore_turf = fallback_turf
		if(!restore_turf)
			continue

		if(!snapshot.movable.forceMove(restore_turf))
			continue

		register_native_movable(snapshot.movable, slot_key, restore_turf)

	QDEL_LIST_ASSOC_VAL(native_snapshots)
	snapshotted_native_movables.Cut()

/datum/pocket_dimension/proc/restore_hibernated_foreign_movables()
	if(!length(hibernated_foreign_movables) || !load_turf)
		return

	var/turf/fallback_turf = get_entry_turf() || get_center_turf()
	for(var/atom/movable/movable as anything in hibernated_foreign_movables)
		if(QDELETED(movable))
			continue

		var/datum/pocket_movable_snapshot/snapshot = hibernated_foreign_movables[movable]
		if(!snapshot || QDELETED(snapshot))
			continue

		var/turf/restore_turf = get_relative_turf(snapshot.offset_x, snapshot.offset_y)
		if(!restore_turf || !contains_turf(restore_turf))
			restore_turf = fallback_turf
		if(!restore_turf)
			continue

		movable.forceMove(restore_turf)

/datum/pocket_dimension/proc/capture_hibernation_state()
	if(uses_movable_snapshot_persistence())
		capture_foreign_movables_for_hibernation(TRUE)
		capture_native_snapshots()
		return

	capture_foreign_movables_for_hibernation()

/datum/pocket_dimension/proc/restore_hibernated_layout()
	restore_native_snapshots()
	restore_hibernated_foreign_movables()

	QDEL_LIST_ASSOC_VAL(hibernated_foreign_movables)
	if(storage && !length(storage.contents))
		QDEL_NULL(storage)

/datum/pocket_dimension/proc/get_debug_label()
	var/template_name = template?.name || "Unknown Template"
	var/state_text = is_hibernating() ? "hibernating" : "active"
	return "#[instance_id] [template_name] ([state_text])"

/datum/pocket_dimension/proc/format_debug_turf(turf/target)
	if(!target || QDELETED(target))
		return "none"
	return "[html_encode("[target]")] ([target.x], [target.y], [target.z])"

/datum/pocket_dimension/proc/get_debug_reservation_text()
	if(!reservation?.bottom_left_coords)
		return "none"

	var/start_x = reservation.bottom_left_coords[1]
	var/start_y = reservation.bottom_left_coords[2]
	var/start_z = reservation.bottom_left_coords[3]
	var/reserved_width = template ? (template.width + (template.padding * 2)) : 0
	var/reserved_height = template ? (template.height + (template.padding * 2)) : 0
	var/end_x = start_x + max(reserved_width - 1, 0)
	var/end_y = start_y + max(reserved_height - 1, 0)
	return "[start_x], [start_y], [start_z] to [end_x], [end_y], [start_z]"

/datum/pocket_dimension/proc/get_storage_content_count()
	return storage ? length(storage.contents) : 0

/datum/pocket_dimension/proc/build_debug_html(include_snapshot_details = FALSE)
	var/list/html = list()
	html += "<html><body>"
	html += "<h2>[html_encode(get_debug_label())]</h2>"
	html += "<ul>"
	html += "<li><b>Reference:</b> <code>[html_encode(REF(src))]</code></li>"
	html += "<li><b>Instance key:</b> <code>[html_encode("[instance_key]")]</code></li>"
	html += "<li><b>Template:</b> [html_encode("[template?.type || "unknown"]")]</li>"
	html += "<li><b>Lifecycle:</b> [html_encode(format_pocket_lifecycle_policy(lifecycle_policy))]</li>"
	html += "<li><b>Persistence:</b> [html_encode(format_pocket_persistence_mode(persistence_mode))]</li>"
	html += "<li><b>Idle timeout:</b> [idle_timeout ? html_encode(DisplayTimeText(idle_timeout)) : "disabled"]</li>"
	html += "<li><b>Last touched:</b> [last_touched ? html_encode("[DisplayTimeText(world.time - last_touched)] ago") : "never"]</li>"
	html += "<li><b>Reservation:</b> [html_encode(get_debug_reservation_text())]</li>"
	html += "<li><b>Return turf:</b> [format_debug_turf(return_turf)]</li>"
	html += "<li><b>Load turf:</b> [format_debug_turf(load_turf)]</li>"
	html += "<li><b>Occupants:</b> [length(get_occupants())]</li>"
	html += "<li><b>Affected turfs:</b> [length(affected_turfs)]</li>"
	html += "<li><b>Entry turfs:</b> [length(entry_turfs)]</li>"
	html += "<li><b>Drop turfs:</b> [length(drop_turfs)]</li>"
	html += "<li><b>Tracked native movables:</b> [length(native_movables_by_key)]</li>"
	html += "<li><b>Stored native snapshots:</b> [length(native_snapshots)]</li>"
	html += "<li><b>Stored foreign snapshots:</b> [length(hibernated_foreign_movables)]</li>"
	html += "<li><b>Storage contents:</b> [get_storage_content_count()]</li>"
	html += "</ul>"

	if(include_snapshot_details)
		html += "<h3>Native Snapshots</h3>"
		if(!length(native_snapshots))
			html += "<p>None.</p>"
		else
			html += "<ul>"
			for(var/slot_key in native_snapshots)
				var/datum/pocket_movable_snapshot/snapshot = native_snapshots[slot_key]
				if(!snapshot)
					continue

				var/entry_text
				if(snapshot.removed || !snapshot.movable || QDELETED(snapshot.movable))
					entry_text = "removed"
				else
					entry_text = "[html_encode("[snapshot.movable]")] ([html_encode("[snapshot.movable.type]")]) at ([snapshot.offset_x], [snapshot.offset_y])"

				html += "<li><code>[html_encode("[slot_key]")]</code>: [entry_text]</li>"
			html += "</ul>"

		html += "<h3>Foreign Snapshots</h3>"
		if(!length(hibernated_foreign_movables))
			html += "<p>None.</p>"
		else
			html += "<ul>"
			for(var/atom/movable/movable as anything in hibernated_foreign_movables)
				var/datum/pocket_movable_snapshot/snapshot = hibernated_foreign_movables[movable]
				if(!snapshot)
					continue
				html += "<li>[html_encode("[movable]")] ([html_encode("[movable.type]")]) at ([snapshot.offset_x], [snapshot.offset_y])</li>"
			html += "</ul>"

		html += "<h3>Storage Contents</h3>"
		if(!storage || !length(storage.contents))
			html += "<p>None.</p>"
		else
			html += "<ul>"
			for(var/atom/movable/movable as anything in storage.contents)
				var/entry_kind = snapshotted_native_movables[movable] ? "native snapshot" : "foreign snapshot"
				html += "<li>[html_encode("[movable]")] ([html_encode("[movable.type]")]) - [entry_kind]</li>"
			html += "</ul>"

	html += "</body></html>"
	return html.Join()

/datum/pocket_dimension/proc/hibernate()
	if(is_hibernating())
		return TRUE
	if(has_occupants())
		return FALSE

	capture_hibernation_state()
	release_loaded_layout()
	state = POCKET_STATE_HIBERNATING
	return TRUE

/datum/pocket_dimension/proc/process_idle_lifecycle()
	if(!idle_timeout || world.time < last_touched + idle_timeout)
		return FALSE
	if(has_occupants())
		return FALSE

	switch(lifecycle_policy)
		if(POCKET_LIFECYCLE_KEEP_LOADED)
			return FALSE
		if(POCKET_LIFECYCLE_HIBERNATE)
			if(is_hibernating())
				return FALSE
			return hibernate()
		if(POCKET_LIFECYCLE_COLLAPSE)
			if(!SSpocket_dimensions)
				return FALSE
			return SSpocket_dimensions.delete_instance(src)

	return FALSE

/area/pocket_dimension
	name = "Pocket Dimension"
	area_flags = NO_TELEPORT | HIDDEN_AREA
	var/datum/pocket_dimension/linked_pocket

/area/pocket_dimension/Destroy(force)
	linked_pocket = null
	return ..()

/area/pocket_dimension/test_chamber
	name = "Pocket Test Chamber"

/area/pocket_dimension/bag_of_holding
	name = "Bag of Holding Cache"

/area/pocket_dimension/magic_closet
	name = "Magic Closet Interior"

/turf/closed/indestructible/pocket_border
	name = "folded-space boundary"
	desc = "Looking at this is making your head hurt."
	icon_state = "shroud1"

/obj/effect/landmark/pocket_dimension
	name = "pocket dimension marker"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE

/obj/effect/landmark/pocket_dimension/entry
	name = "pocket entry marker"

/obj/effect/landmark/pocket_dimension/drop_spot
	name = "pocket drop spot marker"

/obj/effect/landmark/pocket_dimension/exit
	name = "pocket exit marker"
	var/exit_structure_type = /obj/structure/pocket_dimension_exit

/obj/effect/landmark/pocket_dimension/exit/closet
	name = "pocket closet exit marker"
	exit_structure_type = /obj/structure/pocket_dimension_exit/closet

/obj/effect/abstract/pocket_dimension_storage
	invisibility = INVISIBILITY_ABSTRACT

/obj/structure/pocket_dimension_exit
	name = "return seam"
	desc = "A stable tear in space. Touch it to return to where you entered from."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "ladder01"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/pocket_dimension/linked_pocket

/obj/structure/pocket_dimension_exit/Destroy(force)
	linked_pocket = null
	return ..()

/obj/structure/pocket_dimension_exit/examine(mob/user)
	. = ..()
	. += span_notice("Touch it to step back out of the pocket dimension.")

/obj/structure/pocket_dimension_exit/proc/use_exit(mob/user)
	if(!linked_pocket)
		to_chat(user, span_warning("The seam wavers, but nowhere answers."))
		return
	linked_pocket.exit_mob(user)

/obj/structure/pocket_dimension_exit/attack_hand(mob/user, list/modifiers)
	. = ..()
	use_exit(user)

/obj/structure/pocket_dimension_exit/attack_animal(mob/user, list/modifiers)
	use_exit(user)

/obj/structure/pocket_dimension_exit/attack_paw(mob/user, list/modifiers)
	use_exit(user)

/obj/structure/pocket_dimension_exit/closet
	name = "return wardrobe"
	desc = "A wardrobe door humming with folded space. Touch it to return outside."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "closet3"
	density = TRUE

/datum/map_template/pocket/test_chamber
	name = "Pocket Test Chamber"
	id = "pocket_test_chamber"
	mappath = "_maps/templates/pockets/pocket_test_chamber.dmm"

/datum/map_template/pocket/bag_of_holding
	name = "Bag of Holding Cache"
	id = "pocket_bag_of_holding"
	mappath = "_maps/templates/pockets/pocket_bag_of_holding.dmm"
	lifecycle_policy = POCKET_LIFECYCLE_HIBERNATE
	idle_timeout = 2 MINUTES
	persistence_mode = POCKET_PERSISTENCE_MOVABLES

/datum/map_template/pocket/magic_closet
	name = "Magic Closet Interior"
	id = "pocket_magic_closet"
	mappath = "_maps/templates/pockets/pocket_magic_closet.dmm"
	lifecycle_policy = POCKET_LIFECYCLE_HIBERNATE
	idle_timeout = 2 MINUTES
	persistence_mode = POCKET_PERSISTENCE_MOVABLES
	exit_structure_type = /obj/structure/pocket_dimension_exit/closet

/datum/map_template/pocket/magic_closet/dungeon
	name = "Dungeon Closet Interior"
	id = "pocket_magic_closet_dungeon"
	mappath = "_maps/templates/pockets/intimate_dungeon.dmm"
	lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	persistence_mode = POCKET_PERSISTENCE_MOVABLES
	exit_structure_type = /obj/structure/pocket_dimension_exit/closet

/obj/item/pocket_dimension_tester
	name = "folded-space scroll"
	desc = "A debugging scroll that opens a small test pocket dimension."
	icon_state = "skub"
	item_state = "skub"
	w_class = WEIGHT_CLASS_SMALL
	var/template_ref = /datum/map_template/pocket/test_chamber
	var/access_mode = POCKET_ACCESS_INSTANCE_OWNER
	var/pocket_lifecycle_policy = POCKET_LIFECYCLE_HIBERNATE
	var/pocket_idle_timeout = 2 MINUTES

/obj/item/pocket_dimension_tester/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pocket_access, template_ref, access_mode, pocket_lifecycle_policy, pocket_idle_timeout, null, TRUE, TRUE, TRUE, "Pocket Dimension", "The scroll hums with folded space. What do you want it to do?", "The pocket dimension buckles and throws you back into mundane space!", "The scroll burns away, and the pocket dimension collapses around you!")
