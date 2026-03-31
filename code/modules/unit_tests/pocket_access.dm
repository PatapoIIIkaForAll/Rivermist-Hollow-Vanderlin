/datum/unit_test/pocket_access/Run()
	var/obj/item/storage/backpack/test_anchor = allocate(/obj/item/storage/backpack, run_loc_floor_bottom_left)
	var/datum/component/pocket_access/access = test_anchor.AddComponent(/datum/component/pocket_access, /datum/map_template/pocket/test_chamber, POCKET_ACCESS_INSTANCE_USER, POCKET_LIFECYCLE_HIBERNATE, 1)
	TEST_ASSERT_NOTNULL(access, "Pocket access component should attach to a valid owner.")

	var/mob/living/carbon/human/user_one = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/user_two = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/origin_one = get_turf(user_one)
	var/turf/origin_two = get_turf(user_two)
	var/turf/moved_anchor_turf = run_loc_floor_top_right

	TEST_ASSERT(access.enter_user(user_one), "Pocket access should let the first user enter.")
	var/datum/pocket_dimension/instance_one = access.get_instance_for_user(user_one)
	TEST_ASSERT_NOTNULL(instance_one, "Pocket access should resolve the first user's instance.")
	TEST_ASSERT(instance_one.contains_turf(get_turf(user_one)), "First user should arrive inside their pocket.")
	test_anchor.forceMove(moved_anchor_turf)
	TEST_ASSERT(access.leave_user(user_one), "Pocket access should let the first user leave.")
	TEST_ASSERT_EQUAL(get_turf(user_one), moved_anchor_turf, "First user should return to the holder's current turf, not the original entry turf.")

	var/obj/item/natural/cloth/foreign_item = allocate(/obj/item/natural/cloth, origin_one)
	TEST_ASSERT(access.store_movable_for_user(user_one, foreign_item, origin_one), "Pocket access should let a user stash foreign movables in their pocket.")
	TEST_ASSERT(instance_one.contains_turf(get_turf(foreign_item)), "Stored foreign movables should arrive inside the user's pocket.")

	TEST_ASSERT(access.hibernate_pocket(user_one), "Pocket access should let a user hibernate their pocket.")
	TEST_ASSERT(instance_one.is_hibernating(), "Pocket access hibernation should unload the user's pocket.")
	TEST_ASSERT(access.enter_user(user_one), "Pocket access should wake a hibernating pocket on entry.")
	TEST_ASSERT(instance_one.contains_turf(get_turf(user_one)), "First user should re-enter the same pocket instance after hibernation.")
	TEST_ASSERT(instance_one.contains_turf(get_turf(foreign_item)), "Stored foreign movables should survive hibernation and return on wake.")
	TEST_ASSERT(access.leave_user(user_one), "Pocket access should still allow leaving after waking the pocket.")

	TEST_ASSERT(access.enter_user(user_two), "Pocket access should let the second user enter.")
	var/datum/pocket_dimension/instance_two = access.get_instance_for_user(user_two)
	TEST_ASSERT_NOTNULL(instance_two, "Pocket access should resolve the second user's instance.")
	TEST_ASSERT_NOTEQUAL(instance_one.instance_key, instance_two.instance_key, "Per-user access should create distinct pocket instances.")
	TEST_ASSERT(instance_two.contains_turf(get_turf(user_two)), "Second user should arrive inside their own pocket.")
	TEST_ASSERT(access.leave_user(user_two), "Pocket access should let the second user leave.")
	TEST_ASSERT_EQUAL(get_turf(user_two), moved_anchor_turf, "Second user should return to the holder's current turf.")

	var/instance_key_one = "[instance_one.instance_key]"
	var/instance_key_two = "[instance_two.instance_key]"
	qdel(test_anchor, force = TRUE)
	TEST_ASSERT_NULL(SSpocket_dimensions.get_instance(instance_key_one), "Destroying the access owner should collapse the first tracked pocket.")
	TEST_ASSERT_NULL(SSpocket_dimensions.get_instance(instance_key_two), "Destroying the access owner should collapse the second tracked pocket.")
	TEST_ASSERT_EQUAL(get_turf(foreign_item), moved_anchor_turf, "Destroying the access owner should eject stored foreign movables to the holder's tile.")
