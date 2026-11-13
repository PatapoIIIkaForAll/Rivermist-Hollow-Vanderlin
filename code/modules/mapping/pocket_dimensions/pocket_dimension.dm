/datum/pocket_movable_snapshot
	var/atom/movable/movable
	var/offset_x = 0
	var/offset_y = 0
	var/removed = FALSE

/datum/turf_reservation/pocket_dimension
	/// Exact pocket instance owning this reservation. Area datums cannot provide this because loaded copies share them.
	var/datum/weakref/pocket_instance_ref

/datum/turf_reservation/pocket_dimension/Destroy()
	pocket_instance_ref = null
	return ..()

/datum/pocket_dimension
	var/instance_id
	var/instance_key
	var/datum/map_template/pocket/template
	var/lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	var/idle_timeout = POCKET_DEFAULT_IDLE_TIMEOUT
	var/persistence_mode = POCKET_PERSISTENCE_NONE
	var/state = POCKET_STATE_HIBERNATING
	/// TRUE while our template is loading. The loader sleeps, so teardown must not wipe turfs it is still filling.
	var/loading = FALSE
	var/last_touched = 0
	var/datum/turf_reservation/reservation
	var/turf/load_turf
	var/list/last_reservation_bottom_left
	var/last_reservation_width = 0
	var/last_reservation_height = 0
	var/datum/weakref/pocket_holder_ref
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

/datum/pocket_dimension/New(datum/map_template/pocket/template, instance_key, instance_id, lifecycle_policy, idle_timeout, atom/pocket_holder = null)
	src.template = template
	src.instance_key = instance_key
	src.instance_id = instance_id
	apply_lifecycle_settings(lifecycle_policy, idle_timeout)
	set_pocket_holder(pocket_holder)
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
	pocket_holder_ref = null
	return_turf = null
	return_anchor_ref = null
	last_reservation_bottom_left = null
	last_reservation_width = 0
	last_reservation_height = 0
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

/datum/pocket_dimension/proc/process_pocket()
	return FALSE

/datum/pocket_dimension/proc/release_reservation()
	if(!reservation)
		return

	var/datum/turf_reservation/current_reservation = reservation
	reservation = null
	if(!QDELETED(current_reservation))
		current_reservation.RefreshTurfs()
		if(length(current_reservation.bottom_left_coords))
			last_reservation_bottom_left = current_reservation.bottom_left_coords.Copy()
			last_reservation_width = current_reservation.width
			last_reservation_height = current_reservation.height
		if(current_reservation.Release())
			SSmapping.cache_released_pocket_reservation(last_reservation_bottom_left, last_reservation_width, last_reservation_height)
		qdel(current_reservation)

/datum/pocket_dimension/proc/set_pocket_holder(atom/new_pocket_holder)
	if(!new_pocket_holder || QDELETED(new_pocket_holder))
		return

	pocket_holder_ref = WEAKREF(new_pocket_holder)

/datum/pocket_dimension/proc/get_pocket_holder()
	if(!pocket_holder_ref)
		return null

	var/atom/pocket_holder = pocket_holder_ref.resolve()
	if(pocket_holder && !QDELETED(pocket_holder))
		return pocket_holder

	pocket_holder_ref = null
	return null

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

	release_reservation()
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
	var/list/preferred_bottom_left
	if(last_reservation_width == padded_width && last_reservation_height == padded_height && length(last_reservation_bottom_left))
		preferred_bottom_left = last_reservation_bottom_left
	reservation = SSmapping.RequestPocketBlockReservation(
		padded_width,
		padded_height,
		type = /datum/turf_reservation/pocket_dimension,
		preferred_bottom_left = preferred_bottom_left,
	)
	if(!reservation)
		return FALSE

	var/datum/turf_reservation/pocket_dimension/pocket_reservation = reservation
	pocket_reservation.pocket_instance_ref = WEAKREF(src)

	load_turf = locate(
		reservation.bottom_left_coords[1] + template.padding,
		reservation.bottom_left_coords[2] + template.padding,
		reservation.bottom_left_coords[3],
	)
	var/load_x = load_turf?.x
	var/load_y = load_turf?.y
	var/load_z = load_turf?.z
	// Touch before loading too: the loader sleeps, and a stale timestamp reads as idle while it runs
	touch()
	var/loaded = FALSE
	if(load_turf)
		loading = TRUE
		loaded = load_layout()
		loading = FALSE
	if(!loaded)
		load_turf = null
		release_reservation()
		return FALSE

	load_turf = locate(load_x, load_y, load_z)
	if(!load_turf)
		release_reservation()
		return FALSE
	reservation.RefreshTurfs()
	seal_padding_ring()
	reservation.RefreshTurfs()
	cache_loaded_layout()
	state = POCKET_STATE_ACTIVE
	restore_hibernated_layout()
	refresh_loaded_lighting()
	touch()
	return TRUE

/datum/pocket_dimension/proc/load_layout()
	return template.load(load_turf)

/datum/pocket_dimension/proc/refresh_loaded_lighting()
	if(!SSlighting.initialized)
		return

	reservation?.RefreshTurfs()
	var/list/turf/turfs_to_refresh = reservation?.reserved_turfs
	if(!length(turfs_to_refresh))
		turfs_to_refresh = affected_turfs

	for(var/turf/current_turf as anything in turfs_to_refresh)
		if(QDELETED(current_turf))
			continue

		clear_displaced_lighting_overlay(current_turf)
		current_turf.lighting_build_overlay()

		if(current_turf.light_system == STATIC_LIGHT && current_turf.light_power && current_turf.light_outer_range && current_turf.light_on)
			current_turf.update_light()

		for(var/atom/contained_atom as anything in current_turf)
			if(contained_atom.light_system != STATIC_LIGHT)
				continue
			if(!contained_atom.light_power || !contained_atom.light_outer_range || !contained_atom.light_on)
				continue

			contained_atom.update_light()

/datum/pocket_dimension/proc/clear_displaced_lighting_overlay(turf/current_turf)
	var/atom/movable/lighting_object/light_overlay = current_turf?.lighting_object
	if(!light_overlay || light_overlay.loc == current_turf)
		return

	current_turf.lighting_object = null
	current_turf.luminosity = 1

	var/turf/actual_turf = get_turf(light_overlay)
	if(actual_turf?.lighting_object == light_overlay)
		actual_turf.lighting_object = null
		actual_turf.luminosity = 1

	light_overlay.myturf = null
	light_overlay.moveToNullspace()
	qdel(light_overlay, force = TRUE)

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

/// Render machinery the turf owns and recreates on its own. Never our content, never a visitor's cargo.
/datum/pocket_dimension/proc/is_turf_render_movable(atom/movable/movable)
	return istype(movable, /atom/movable/lighting_object) || istype(movable, /atom/movable/outdoor_effect)

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
			// Lighting objects churn constantly, so holding one here strands a dead ref until round end.
			if(is_turf_render_movable(movable))
				continue
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

/datum/pocket_dimension/proc/get_holder_exit_destination()
	var/atom/pocket_holder = get_pocket_holder()
	if(!pocket_holder)
		return null

	var/turf/holder_turf = get_turf(pocket_holder)
	if(holder_turf && !QDELETED(holder_turf))
		return holder_turf

	var/atom/holder_loc = pocket_holder.loc
	if(holder_loc && !QDELETED(holder_loc))
		return holder_loc

	return null

/datum/pocket_dimension/proc/get_exit_destination(atom/override_destination = null)
	if(override_destination && !QDELETED(override_destination))
		return override_destination

	var/atom/holder_destination = get_holder_exit_destination()
	if(holder_destination)
		return holder_destination

	var/atom/return_anchor = return_anchor_ref?.resolve()
	if(return_anchor && !QDELETED(return_anchor))
		var/turf/anchor_turf = get_turf(return_anchor)
		if(anchor_turf && !QDELETED(anchor_turf))
			return anchor_turf

		var/atom/anchor_loc = return_anchor.loc
		if(anchor_loc && !QDELETED(anchor_loc))
			return anchor_loc

	if(isturf(return_turf) && !QDELETED(return_turf))
		return return_turf

	return find_safe_turf()

/datum/pocket_dimension/proc/get_return_turf()
	var/atom/exit_destination = get_exit_destination()
	if(!exit_destination)
		return null
	if(isturf(exit_destination))
		return exit_destination
	return get_turf(exit_destination)

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

	var/atom/target = get_exit_destination()
	if(!target)
		return FALSE

	touch()
	user.forceMove(target)
	return TRUE

/datum/pocket_dimension/proc/can_exit_mob(mob/user, obj/structure/pocket_dimension_exit/exit_object, show_feedback = TRUE)
	return TRUE

/datum/pocket_dimension/proc/eject_occupants(message = null, atom/override_destination = null)
	var/atom/target = get_exit_destination(override_destination)
	if(!target)
		return

	for(var/mob/occupant as anything in get_occupants())
		if(!ismob(occupant) || QDELETED(occupant))
			continue
		if(message)
			to_chat(occupant, span_warning(message))
		occupant.forceMove(target)

/datum/pocket_dimension/proc/eject_all(message = null, atom/override_destination = null)
	return eject_occupants(message, override_destination)

/datum/pocket_dimension/proc/is_native_snapshot_movable(atom/movable/movable)
	if(!movable || QDELETED(movable))
		return FALSE
	return native_movables[movable] || snapshotted_native_movables[movable]

/datum/pocket_dimension/proc/should_preserve_foreign_movable(atom/movable/movable, items_only = FALSE)
	if(!movable || QDELETED(movable) || is_native_snapshot_movable(movable) || ismob(movable))
		return FALSE
	if(is_turf_render_movable(movable))
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

/datum/pocket_dimension/proc/eject_foreign_movables(items_only = FALSE, atom/override_destination = null)
	var/atom/target = get_exit_destination(override_destination)
	if(!target)
		return

	for(var/atom/movable/movable as anything in get_preservable_foreign_movables(items_only))
		transfer_foreign_movable(movable, target)

	QDEL_LIST_ASSOC_VAL(hibernated_foreign_movables)
	if(storage && !length(storage.contents))
		QDEL_NULL(storage)

/datum/pocket_dimension/proc/collapse_nested_pockets(message = null, atom/override_destination = null)
	if(!SSpocket_dimensions)
		return FALSE

	var/list/child_instances = SSpocket_dimensions.get_child_instances(src)
	if(!length(child_instances))
		return FALSE

	var/atom/child_exit_target = get_exit_destination(override_destination)
	for(var/datum/pocket_dimension/child_instance as anything in child_instances)
		if(QDELETED(child_instance))
			continue
		SSpocket_dimensions.delete_instance(child_instance, message, child_exit_target)

	return TRUE

/datum/pocket_dimension/proc/eject_teardown_contents(message = null, atom/override_destination = null)
	collapse_nested_pockets(message, override_destination)
	eject_occupants(message, override_destination)
	eject_foreign_movables(FALSE, override_destination)

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

/datum/pocket_dimension/proc/format_debug_atom(atom/target)
	if(!target || QDELETED(target))
		return "none"
	if(isturf(target))
		var/turf/target_turf = target
		return "[html_encode("[target_turf]")] ([target_turf.x], [target_turf.y], [target_turf.z])"
	return "[html_encode("[target]")] ([html_encode("[target.type]")])"

/datum/pocket_dimension/proc/format_debug_turf(turf/target)
	return format_debug_atom(target)

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
	html += "<li><b>Pocket holder:</b> [format_debug_atom(get_pocket_holder())]</li>"
	html += "<li><b>Exit destination:</b> [format_debug_atom(get_exit_destination())]</li>"
	html += "<li><b>Reservation:</b> [html_encode(get_debug_reservation_text())]</li>"
	html += "<li><b>Return turf fallback:</b> [format_debug_turf(return_turf)]</li>"
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
	if(loading)
		return FALSE
	if(is_hibernating())
		return TRUE
	if(has_occupants())
		return FALSE

	capture_hibernation_state()
	release_loaded_layout()
	state = POCKET_STATE_HIBERNATING
	return TRUE

/datum/pocket_dimension/proc/process_idle_lifecycle()
	if(loading)
		return FALSE
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
