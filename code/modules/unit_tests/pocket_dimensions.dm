/datum/unit_test/pocket_dimensions
	needs_pocket_space = TRUE

/datum/unit_test/pocket_dimensions/Run()
	var/obj/item/pocket_dimension_tester/tester_scroll = allocate(/obj/item/pocket_dimension_tester, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/tester = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/origin = get_turf(tester)
	var/turf/moved_holder_turf = run_loc_floor_top_right

	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance(REF(tester_scroll), tester_scroll.template_ref, POCKET_LIFECYCLE_HIBERNATE, 1, tester_scroll)
	TEST_ASSERT_NOTNULL(instance, "Pocket dimension instance should be created.")
	TEST_ASSERT(instance.enter_mob(tester, origin), "Pocket dimension should accept a mob entry.")
	TEST_ASSERT(instance.contains_turf(get_turf(tester)), "Tester should wind up inside the pocket dimension.")

	var/obj/item/storage/backpack/foreign_bag = allocate(/obj/item/storage/backpack, origin)
	TEST_ASSERT(instance.send_movable_inside(foreign_bag, origin), "Pocket dimension should accept foreign movables from outside.")
	TEST_ASSERT(instance.contains_turf(get_turf(foreign_bag)), "Foreign items sent inside should count as in-pocket objects.")

	tester_scroll.forceMove(moved_holder_turf)
	TEST_ASSERT(instance.exit_mob(tester), "Pocket dimension should be able to return a mob.")
	TEST_ASSERT_EQUAL(get_turf(tester), moved_holder_turf, "Tester should return to the holder's current turf.")
	instance.last_touched = 0
	TEST_ASSERT(instance.process_idle_lifecycle(), "Pocket dimension should hibernate when left idle.")
	TEST_ASSERT(instance.is_hibernating(), "Pocket dimension should enter a hibernating state after idling out.")
	TEST_ASSERT_NULL(instance.reservation, "Hibernating pocket dimensions should release their reservation.")
	TEST_ASSERT(instance.enter_mob(tester, origin), "Pocket dimension should wake back up when entered.")
	TEST_ASSERT(instance.contains_turf(get_turf(foreign_bag)), "Foreign movables should be restored when a hibernating pocket wakes.")
	TEST_ASSERT(SSpocket_dimensions.delete_instance(REF(tester_scroll)), "Pocket dimension should be deletable.")
	TEST_ASSERT_NULL(SSpocket_dimensions.get_instance(REF(tester_scroll)), "Pocket dimension should unregister after deletion.")
	TEST_ASSERT_EQUAL(get_turf(foreign_bag), moved_holder_turf, "Foreign items should be ejected to the holder's current turf before the pocket collapses.")

/datum/unit_test/pocket_dimension_reuses_reserved_z
	needs_pocket_space = TRUE

/datum/unit_test/pocket_dimension_reuses_reserved_z/Run()
	var/initial_maxz = world.maxz
	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::reserved_z_reuse", /datum/map_template/pocket/test_chamber, POCKET_LIFECYCLE_HIBERNATE, 1)
	TEST_ASSERT_NOTNULL(instance, "Pocket dimension instance should be created from existing reserved turf.")
	TEST_ASSERT_EQUAL(world.maxz, initial_maxz, "Creating a small pocket should reuse existing reserved turf before allocating another z-level.")

	TEST_ASSERT(SSpocket_dimensions.delete_instance(instance), "Reserved z reuse test pocket should be deletable.")

/datum/unit_test/pocket_dimension_hibernate_releases_allocator_turfs
	needs_pocket_space = TRUE

/datum/unit_test/pocket_dimension_hibernate_releases_allocator_turfs/Run()
	var/initial_maxz = world.maxz
	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::hibernate_allocator_reuse", /datum/map_template/pocket/test_chamber, POCKET_LIFECYCLE_HIBERNATE, 1)
	TEST_ASSERT_NOTNULL(instance, "Pocket dimension instance should be created for hibernate allocator testing.")
	var/list/expected_bottom_left = instance.reservation.bottom_left_coords.Copy()

	for(var/cycle in 1 to 20)
		TEST_ASSERT_NOTNULL(instance.reservation, "Cycle [cycle]: active pocket should have a reservation.")
		TEST_ASSERT_EQUAL(instance.reservation.bottom_left_coords[1], expected_bottom_left[1], "Cycle [cycle]: active pocket should reuse its original X slot.")
		TEST_ASSERT_EQUAL(instance.reservation.bottom_left_coords[2], expected_bottom_left[2], "Cycle [cycle]: active pocket should reuse its original Y slot.")
		TEST_ASSERT_EQUAL(instance.reservation.bottom_left_coords[3], expected_bottom_left[3], "Cycle [cycle]: active pocket should reuse its original Z slot.")

		var/list/released_coords = list()
		for(var/turf/reserved_turf as anything in instance.reservation.reserved_turfs)
			released_coords += list(list(reserved_turf.x, reserved_turf.y, reserved_turf.z))

		TEST_ASSERT(length(released_coords), "Cycle [cycle]: reservation should contain turfs before hibernating.")
		TEST_ASSERT(instance.hibernate(), "Cycle [cycle]: pocket should hibernate cleanly.")
		TEST_ASSERT(instance.is_hibernating(), "Cycle [cycle]: pocket should report hibernating after release.")

		for(var/list/coords as anything in released_coords)
			var/turf/released_turf = locate(coords[1], coords[2], coords[3])
			var/list/unused_z_turfs = SSmapping.unused_turfs["[coords[3]]"]
			TEST_ASSERT_NOTNULL(released_turf, "Cycle [cycle]: released turf should still exist after reset.")
			TEST_ASSERT(istype(released_turf, RESERVED_TURF_TYPE), "Cycle [cycle]: released turf should reset to the reserved turf type.")
			TEST_ASSERT(released_turf.turf_flags & UNUSED_RESERVATION_TURF, "Cycle [cycle]: released turf should be marked available to the allocator.")
			TEST_ASSERT(length(unused_z_turfs) && (released_turf in unused_z_turfs), "Cycle [cycle]: released turf should be indexed in unused_turfs.")
			TEST_ASSERT_NULL(SSmapping.used_turfs[released_turf], "Cycle [cycle]: released turf should not remain indexed as used.")

		TEST_ASSERT(instance.activate(), "Cycle [cycle]: hibernating pocket should be able to reserve space again.")
		TEST_ASSERT_EQUAL(world.maxz, initial_maxz, "Cycle [cycle]: repeated hibernation should not allocate a new z-level.")

	TEST_ASSERT(SSpocket_dimensions.delete_instance(instance), "Hibernate allocator test pocket should be deletable.")

/datum/unit_test/pocket_dimension_deleted_slot_reused
	needs_pocket_space = TRUE

/datum/unit_test/pocket_dimension_deleted_slot_reused/Run()
	SSmapping.clear_pocket_reservation_cache()
	var/initial_maxz = world.maxz

	var/datum/pocket_dimension/first_instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::deleted_slot_first", /datum/map_template/pocket/test_chamber, POCKET_LIFECYCLE_HIBERNATE, 1)
	TEST_ASSERT_NOTNULL(first_instance, "First pocket should be created for deleted slot reuse testing.")
	TEST_ASSERT_NOTNULL(first_instance.reservation, "First pocket should reserve a slot.")

	var/list/released_bottom_left = first_instance.reservation.bottom_left_coords.Copy()
	var/released_width = first_instance.reservation.width
	var/released_height = first_instance.reservation.height
	TEST_ASSERT(SSpocket_dimensions.delete_instance(first_instance), "First pocket should delete and release its slot.")

	var/datum/pocket_dimension/second_instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::deleted_slot_second", /datum/map_template/pocket/test_chamber, POCKET_LIFECYCLE_HIBERNATE, 1)
	TEST_ASSERT_NOTNULL(second_instance, "Second pocket should be created from the released slot.")
	TEST_ASSERT_NOTNULL(second_instance.reservation, "Second pocket should reserve a slot.")
	TEST_ASSERT_EQUAL(second_instance.reservation.width, released_width, "Second pocket should reuse a slot with the same width.")
	TEST_ASSERT_EQUAL(second_instance.reservation.height, released_height, "Second pocket should reuse a slot with the same height.")
	TEST_ASSERT_EQUAL(second_instance.reservation.bottom_left_coords[1], released_bottom_left[1], "Second pocket should reuse the deleted pocket's X slot.")
	TEST_ASSERT_EQUAL(second_instance.reservation.bottom_left_coords[2], released_bottom_left[2], "Second pocket should reuse the deleted pocket's Y slot.")
	TEST_ASSERT_EQUAL(second_instance.reservation.bottom_left_coords[3], released_bottom_left[3], "Second pocket should reuse the deleted pocket's Z slot.")
	TEST_ASSERT_EQUAL(world.maxz, initial_maxz, "Reusing a deleted pocket slot should not allocate a new z-level.")

	TEST_ASSERT(SSpocket_dimensions.delete_instance(second_instance), "Second pocket should be deletable.")
	SSmapping.clear_pocket_reservation_cache()

/datum/unit_test/pocket_dimension_drop_spot
	needs_pocket_space = TRUE

/datum/unit_test/pocket_dimension_drop_spot/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::drop_spot", /datum/map_template/pocket/bag_of_holding, POCKET_LIFECYCLE_KEEP_LOADED, 0)
	TEST_ASSERT_NOTNULL(instance, "Bag pocket test instance should be created.")

	var/obj/item/natural/cloth/foreign_item = allocate(/obj/item/natural/cloth, origin)
	TEST_ASSERT(instance.send_movable_inside(foreign_item, origin), "Bag pocket should accept foreign movables from outside.")
	TEST_ASSERT(instance.contains_turf(get_turf(foreign_item)), "Foreign item should arrive inside the bag pocket.")
	TEST_ASSERT(get_turf(foreign_item) in instance.drop_turfs, "Bag pocket should use its designated drop spot when one is present.")

	TEST_ASSERT(SSpocket_dimensions.delete_instance(instance), "Bag pocket test instance should be deletable.")
	TEST_ASSERT_EQUAL(get_turf(foreign_item), origin, "Foreign item should be ejected back to the origin turf on collapse.")

/datum/unit_test/pocket_dimension_boundary_cleanup
	needs_pocket_space = TRUE

/datum/unit_test/pocket_dimension_boundary_cleanup/Run()
	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::boundary_cleanup", /datum/map_template/pocket/bag_of_holding, POCKET_LIFECYCLE_KEEP_LOADED, 0)
	TEST_ASSERT_NOTNULL(instance, "Boundary cleanup test pocket should be created.")
	TEST_ASSERT_NOTNULL(instance.reservation, "Boundary cleanup test pocket should reserve turf space.")

	var/list/reserved_turfs = instance.reservation.reserved_turfs.Copy()
	var/list/border_turfs = list()
	for(var/turf/current_turf as anything in reserved_turfs)
		if(instance.contains_turf(current_turf))
			continue
		border_turfs += current_turf

	TEST_ASSERT(length(border_turfs), "Pocket padding should leave a border outside the loaded room.")
	for(var/turf/border_turf as anything in border_turfs)
		TEST_ASSERT(istype(border_turf, /turf/closed/indestructible/pocket_border), "Pocket padding should be sealed with folded-space boundary walls.")

	TEST_ASSERT(SSpocket_dimensions.delete_instance(instance), "Boundary cleanup test pocket should be deletable.")
	for(var/turf/released_turf as anything in reserved_turfs)
		TEST_ASSERT(istype(released_turf, RESERVED_TURF_TYPE), "Released pocket turfs should be restored to reserved turf.")
		TEST_ASSERT(released_turf.turf_flags & UNUSED_RESERVATION_TURF, "Released pocket turfs should be marked as available again.")

/datum/unit_test/pocket_dimension_sound_isolation
	needs_pocket_space = TRUE

/datum/unit_test/pocket_dimension_sound_isolation/Run()
	var/first_key = "[REF(src)]::sound_first"
	var/second_key = "[REF(src)]::sound_second"
	var/datum/pocket_dimension/first_pocket = SSpocket_dimensions.get_or_create_instance(first_key, /datum/map_template/pocket/test_chamber, POCKET_LIFECYCLE_KEEP_LOADED, 0)
	var/datum/pocket_dimension/second_pocket = SSpocket_dimensions.get_or_create_instance(second_key, /datum/map_template/pocket/test_chamber, POCKET_LIFECYCLE_KEEP_LOADED, 0)
	TEST_ASSERT_NOTNULL(first_pocket, "The source pocket should load for sound-isolation testing.")
	TEST_ASSERT_NOTNULL(second_pocket, "The neighboring pocket should load for sound-isolation testing.")

	var/mob/living/carbon/human/source = allocate(/mob/living/carbon/human, first_pocket.get_entry_turf())
	var/mob/living/carbon/human/same_pocket_listener = allocate(/mob/living/carbon/human, first_pocket.get_entry_turf())
	var/mob/living/carbon/human/other_pocket_listener = allocate(/mob/living/carbon/human, second_pocket.get_entry_turf())
	var/mob/living/carbon/human/outside_listener = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(get_pocket_dimension_at(source), first_pocket, "The source turf should resolve to its exact pocket instance.")
	TEST_ASSERT_EQUAL(get_pocket_dimension_at(other_pocket_listener), second_pocket, "A second copy of the same template should resolve to its own pocket instance.")
	TEST_ASSERT_NULL(get_pocket_dimension_at(outside_listener), "A world turf should not resolve to a pocket instance.")

	var/list/listeners = list(same_pocket_listener, other_pocket_listener, outside_listener)
	filter_pocket_sound_listeners(first_pocket, listeners)
	TEST_ASSERT(same_pocket_listener in listeners, "A positional sound should remain audible within its own pocket instance.")
	TEST_ASSERT(!(other_pocket_listener in listeners), "A positional sound must not cross into another pocket instance.")
	TEST_ASSERT(!(outside_listener in listeners), "A positional sound must not escape its pocket into allocator-adjacent space.")

	SSpocket_dimensions.delete_instance(first_pocket)
	SSpocket_dimensions.delete_instance(second_pocket)

/datum/unit_test/magic_closet_transport
	needs_pocket_space = TRUE

/datum/unit_test/magic_closet_transport/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/obj/structure/closet/crate/crafted_closet/magic/magic_closet = allocate(/obj/structure/closet/crate/crafted_closet/magic, origin)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/obj/item/natural/cloth/foreign_item = allocate(/obj/item/natural/cloth, origin)

	TEST_ASSERT(magic_closet.open(user), "Magic closet should open like a normal wardrobe.")
	TEST_ASSERT(magic_closet.close(user), "Magic closet should close and fold its contents into the pocket.")

	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_instance(magic_closet.get_pocket_instance_key())
	TEST_ASSERT_NOTNULL(instance, "Closing the magic closet should create its shared pocket.")
	TEST_ASSERT(instance.contains_turf(get_turf(user)), "Closing the magic closet on an occupant should transport them into the pocket.")
	TEST_ASSERT(instance.contains_turf(get_turf(foreign_item)), "Closing the magic closet on an item should transport it into the pocket.")

	var/obj/structure/pocket_dimension_exit/closet/exit_closet
	for(var/obj/structure/pocket_dimension_exit/closet/found_exit as anything in instance.exit_objects)
		exit_closet = found_exit
		break

	TEST_ASSERT_NOTNULL(exit_closet, "Magic closet pocket should spawn a closet-shaped exit.")
	TEST_ASSERT(instance.exit_mob(user), "Pocket occupants should be able to return outside.")
	TEST_ASSERT_EQUAL(get_turf(user), origin, "Leaving the magic closet pocket should return the user to the wardrobe.")

	TEST_ASSERT(SSpocket_dimensions.delete_instance(instance), "Magic closet pocket should be deletable.")
	TEST_ASSERT_EQUAL(get_turf(foreign_item), origin, "Deleting the magic closet pocket should eject stored foreign items.")

#ifdef FOCUS_POCKET_SOUND_ISOLATION_TEST
TEST_FOCUS(/datum/unit_test/pocket_dimension_sound_isolation)
#endif

/datum/unit_test/pocket_dimension_snapshot
	needs_pocket_space = TRUE

/datum/unit_test/pocket_dimension_snapshot/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::snapshot", /datum/map_template/pocket/bag_of_holding, POCKET_LIFECYCLE_HIBERNATE, 0)
	TEST_ASSERT_NOTNULL(instance, "Snapshot test instance should be created.")
	TEST_ASSERT(instance.uses_movable_snapshot_persistence(), "Bag pocket should opt into movable snapshot persistence.")

	var/list/chests = list()
	for(var/turf/current_turf as anything in instance.affected_turfs)
		for(var/atom/movable/current_movable as anything in current_turf.contents)
			if(!istype(current_movable, /obj/structure/closet/crate/chest))
				continue
			chests += current_movable

	TEST_ASSERT(length(chests) >= 2, "Bag pocket should load both template chests for the snapshot test.")

	var/obj/structure/closet/crate/chest/first_chest = chests[1]
	var/obj/structure/closet/crate/chest/second_chest = chests[2]
	var/turf/second_chest_origin = get_turf(second_chest)
	first_chest.name = "snapshot chest"

	var/obj/item/natural/feather/chest_loot = allocate(/obj/item/natural/feather, first_chest)
	var/obj/item/natural/cloth/loose_item = allocate(/obj/item/natural/cloth, get_turf(first_chest))
	second_chest.forceMove(origin)

	TEST_ASSERT(instance.hibernate(), "Snapshot test pocket should hibernate cleanly.")
	TEST_ASSERT(instance.is_hibernating(), "Snapshot test pocket should enter a hibernating state.")
	TEST_ASSERT(instance.activate(), "Snapshot test pocket should wake back up after hibernation.")

	TEST_ASSERT(instance.contains_turf(get_turf(first_chest)), "Snapshotted native chest should be restored into the pocket.")
	TEST_ASSERT_EQUAL(first_chest.name, "snapshot chest", "Native movable state should survive a hibernation snapshot.")
	TEST_ASSERT_EQUAL(chest_loot.loc, first_chest, "Foreign contents inside a snapshotted native container should stay with that container.")
	TEST_ASSERT(instance.contains_turf(get_turf(loose_item)), "Loose foreign movables should still be restored after a snapshot wake.")
	TEST_ASSERT_NULL(locate(/obj/structure/closet/crate/chest) in second_chest_origin, "A removed template-native chest should not respawn after snapshot restore.")

	TEST_ASSERT(SSpocket_dimensions.delete_instance(instance), "Snapshot test pocket should be deletable after waking.")

/datum/unit_test/bag_of_holding_constraints/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/obj/item/storage/backpack/bag_of_holding/test_bag = allocate(/obj/item/storage/backpack/bag_of_holding, origin)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)
	var/obj/item/pocket_dimension_tester/tester_scroll = allocate(/obj/item/pocket_dimension_tester, origin)

	TEST_ASSERT(test_bag.store_item_in_pocket(tester_scroll, user), "Bag of holding should consume attempts to store another pocket-holder item.")
	TEST_ASSERT_EQUAL(get_turf(tester_scroll), origin, "Bag of holding should refuse to swallow another pocket-holder item.")

/*/datum/unit_test/pocket_dimension_static_lighting/Run()
	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::static_lighting", /datum/map_template/pocket/lighting_test, POCKET_LIFECYCLE_KEEP_LOADED, 0)
	TEST_ASSERT_NOTNULL(instance, "Static lighting test pocket should be created.")

	var/obj/machinery/light/fueled/firebowl/stump/fire_stump
	for(var/turf/current_turf as anything in instance.affected_turfs)
		fire_stump = locate(/obj/machinery/light/fueled/firebowl/stump) in current_turf
		if(fire_stump)
			break

	TEST_ASSERT_NOTNULL(fire_stump, "Static lighting test pocket should load its stump fire fixture.")
	TEST_ASSERT(fire_stump.on, "Static lighting test stump fire should start lit.")

	var/turf/lit_turf = get_step(get_turf(fire_stump), SOUTH)
	TEST_ASSERT(instance.contains_turf(lit_turf), "Static lighting test should check a turf inside the loaded pocket.")

	fire_stump.update(FALSE)
	SSlighting.fire(FALSE, TRUE)

	TEST_ASSERT_NOTNULL(lit_turf.lighting_object, "Pocket lighting refresh should leave nearby turfs with lighting overlays.")
	TEST_ASSERT(lit_turf.lighting_object.luminosity, "Static fixtures loaded from a pocket template should illuminate adjacent turfs.")

	TEST_ASSERT(SSpocket_dimensions.delete_instance(instance), "Static lighting test pocket should be deletable.")

/datum/unit_test/bag_of_holding_destroy_ejection/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/moved_bag_turf = run_loc_floor_top_right

	var/obj/item/storage/backpack/bag_of_holding/live_bag = allocate(/obj/item/storage/backpack/bag_of_holding, origin)
	var/mob/living/carbon/human/live_user = allocate(/mob/living/carbon/human, origin)
	var/obj/item/natural/cloth/live_item = allocate(/obj/item/natural/cloth, origin)
	TEST_ASSERT(live_bag.store_item_in_pocket(live_item, live_user), "Bag of holding should accept a foreign item before the destroy ejection test.")
	live_bag.forceMove(moved_bag_turf)
	qdel(live_bag, force = TRUE)
	TEST_ASSERT_EQUAL(get_turf(live_item), moved_bag_turf, "Destroying a bag on-map should eject stored items onto the turf underneath the bag.")

	var/obj/item/storage/backpack/bag_of_holding/fallback_bag = allocate(/obj/item/storage/backpack/bag_of_holding, origin)
	var/mob/living/carbon/human/fallback_user = allocate(/mob/living/carbon/human, origin)
	var/obj/item/natural/cloth/fallback_item = allocate(/obj/item/natural/cloth, origin)
	TEST_ASSERT(fallback_bag.store_item_in_pocket(fallback_item, fallback_user), "Bag of holding should accept a foreign item before the saved-exit fallback test.")
	fallback_bag.moveToNullspace()
	qdel(fallback_bag, force = TRUE)
	TEST_ASSERT_EQUAL(get_turf(fallback_item), origin, "Destroying a bag without a live turf should eject stored items to the saved exit turf.")*/
