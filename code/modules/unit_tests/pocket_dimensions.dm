/datum/unit_test/pocket_dimensions/Run()
	var/obj/item/pocket_dimension_tester/tester_scroll = allocate(/obj/item/pocket_dimension_tester, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/tester = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/origin = get_turf(tester)

	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance(REF(tester_scroll), tester_scroll.template_ref, POCKET_LIFECYCLE_HIBERNATE, 1)
	TEST_ASSERT_NOTNULL(instance, "Pocket dimension instance should be created.")
	TEST_ASSERT(instance.enter_mob(tester, origin), "Pocket dimension should accept a mob entry.")
	TEST_ASSERT(instance.contains_turf(get_turf(tester)), "Tester should wind up inside the pocket dimension.")

	var/obj/item/storage/backpack/foreign_bag = allocate(/obj/item/storage/backpack, origin)
	TEST_ASSERT(instance.send_movable_inside(foreign_bag, origin), "Pocket dimension should accept foreign movables from outside.")
	TEST_ASSERT(instance.contains_turf(get_turf(foreign_bag)), "Foreign items sent inside should count as in-pocket objects.")

	TEST_ASSERT(instance.exit_mob(tester), "Pocket dimension should be able to return a mob.")
	TEST_ASSERT_EQUAL(get_turf(tester), origin, "Tester should return to the entry turf.")
	instance.last_touched = 0
	TEST_ASSERT(instance.process_idle_lifecycle(), "Pocket dimension should hibernate when left idle.")
	TEST_ASSERT(instance.is_hibernating(), "Pocket dimension should enter a hibernating state after idling out.")
	TEST_ASSERT_NULL(instance.reservation, "Hibernating pocket dimensions should release their reservation.")
	TEST_ASSERT(instance.enter_mob(tester, origin), "Pocket dimension should wake back up when entered.")
	TEST_ASSERT(instance.contains_turf(get_turf(foreign_bag)), "Foreign movables should be restored when a hibernating pocket wakes.")
	TEST_ASSERT(SSpocket_dimensions.delete_instance(REF(tester_scroll)), "Pocket dimension should be deletable.")
	TEST_ASSERT_NULL(SSpocket_dimensions.get_instance(REF(tester_scroll)), "Pocket dimension should unregister after deletion.")
	TEST_ASSERT_EQUAL(get_turf(foreign_bag), origin, "Foreign items should be ejected before the pocket collapses.")

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

/datum/unit_test/pocket_dimension_snapshot/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/datum/pocket_dimension/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::snapshot", /datum/map_template/pocket/bag_of_holding, POCKET_LIFECYCLE_HIBERNATE, 1)
	TEST_ASSERT_NOTNULL(instance, "Snapshot test instance should be created.")
	TEST_ASSERT(instance.uses_movable_snapshot_persistence(), "Bag pocket should opt into movable snapshot persistence.")

	var/list/chests = list()
	for(var/turf/current_turf as anything in instance.affected_turfs)
		for(var/obj/structure/closet/crate/chest/chest as anything in current_turf)
			chests += chest

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
