/// Heel shoes start heeled, plain shoes do not, and the elixir heels a pair once.
/datum/unit_test/heeled_shoes_var/Run()
	var/obj/item/clothing/shoes/heels/heels = allocate(/obj/item/clothing/shoes/heels)
	TEST_ASSERT(heels.heeled, "Heel shoes are not heeled")
	var/obj/item/clothing/shoes/simpleshoes/plain = allocate(/obj/item/clothing/shoes/simpleshoes)
	TEST_ASSERT(!plain.heeled, "Plain shoes start heeled")

	var/list/heel_types = list(
		/obj/item/clothing/shoes/heels/color,
		/obj/item/clothing/shoes/heels/courtphysician/female,
		/obj/item/clothing/shoes/courtphysician/female,
		/obj/item/clothing/shoes/simpleshoes/heels,
		/obj/item/clothing/shoes/simpleshoes/heels/donator_gold,
		/obj/item/clothing/shoes/simpleshoes/heels/donator_silver,
		/obj/item/clothing/shoes/otavan/inqboots/heels,
		/obj/item/clothing/shoes/boots/armor/baotha,
	)
	for(var/heel_type in heel_types)
		var/obj/item/clothing/shoes/heel_shoes = allocate(heel_type)
		TEST_ASSERT(heel_shoes.heeled, "[heel_type] is not heeled")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/heel_elixir/elixir = allocate(/obj/item/heel_elixir)
	TEST_ASSERT_EQUAL(elixir.interact_with_atom(plain, user), ITEM_INTERACT_SUCCESS, "Elixir use on plain shoes did not succeed")
	TEST_ASSERT(plain.heeled, "Elixir did not heel the shoes")
	TEST_ASSERT(QDELETED(elixir), "Elixir was not used up")

	var/obj/item/heel_elixir/second = allocate(/obj/item/heel_elixir)
	TEST_ASSERT_EQUAL(second.interact_with_atom(plain, user), ITEM_INTERACT_BLOCKING, "Elixir worked on shoes that already have heels")
	TEST_ASSERT(!QDELETED(second), "Elixir was used up on shoes that already have heels")

/// Heeled shoes on the feet cost one Speed, once, until removed or the wearer has the heel walker trait.
/datum/unit_test/heeled_shoes_speed/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	var/base_speed = GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED)
	TEST_ASSERT_NOTNULL(base_speed, "Wearer has no Speed value")

	var/obj/item/clothing/shoes/heels/heels = allocate(/obj/item/clothing/shoes/heels)
	wearer.equip_to_slot_or_del(heels, ITEM_SLOT_SHOES)
	TEST_ASSERT_EQUAL(wearer.get_item_by_slot(ITEM_SLOT_SHOES), heels, "Heels were not worn")
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED), base_speed - 1, "Worn heels did not lower Speed by 1")

	heels.start_heel_effects(wearer)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED), base_speed - 1, "Heel Speed loss stacked")

	heels.set_heeled(FALSE)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED), base_speed, "Removing heels while worn kept the Speed loss")
	heels.set_heeled(TRUE)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED), base_speed - 1, "Adding heels while worn did not lower Speed")

	ADD_TRAIT(wearer, TRAIT_HEEL_WALKER, TRAIT_GENERIC)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED), base_speed, "Heel walker trait did not remove the Speed loss")
	REMOVE_TRAIT(wearer, TRAIT_HEEL_WALKER, TRAIT_GENERIC)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED), base_speed - 1, "Losing the heel walker trait did not bring the Speed loss back")

	wearer.temporarilyRemoveItemFromInventory(heels, TRUE)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED), base_speed, "Taking heels off kept the Speed loss")

	var/obj/item/clothing/shoes/simpleshoes/plain = allocate(/obj/item/clothing/shoes/simpleshoes)
	wearer.equip_to_slot_or_del(plain, ITEM_SLOT_SHOES)
	TEST_ASSERT_EQUAL(GET_MOB_ATTRIBUTE_VALUE(wearer, STAT_SPEED), base_speed, "Plain shoes lowered Speed")

/// The trip roll fires only on a running heeled wearer without the heel walker trait.
/datum/unit_test/heeled_shoes_trip/Run()
	var/mob/living/carbon/human/runner = make_heeled_wearer(MOVE_INTENT_RUN)
	var/obj/item/clothing/shoes/heels = runner.get_item_by_slot(ITEM_SLOT_SHOES)
	TEST_ASSERT_NOTNULL(heels, "Runner wears no heels")
	TEST_ASSERT(!heels.roll_heel_trip(runner, 0), "Trip fired at 0% chance")
	TEST_ASSERT(heels.roll_heel_trip(runner, 100), "Running in heels did not trip at 100% chance")
	TEST_ASSERT(runner.IsKnockdown(), "Trip did not knock the runner down")

	var/mob/living/carbon/human/walker = make_heeled_wearer(MOVE_INTENT_WALK)
	heels = walker.get_item_by_slot(ITEM_SLOT_SHOES)
	TEST_ASSERT_NOTNULL(heels, "Walker wears no heels")
	TEST_ASSERT(!heels.roll_heel_trip(walker, 100), "Walking in heels tripped")

	var/mob/living/carbon/human/practiced = make_heeled_wearer(MOVE_INTENT_RUN)
	heels = practiced.get_item_by_slot(ITEM_SLOT_SHOES)
	TEST_ASSERT_NOTNULL(heels, "Practiced runner wears no heels")
	ADD_TRAIT(practiced, TRAIT_HEEL_WALKER, TRAIT_GENERIC)
	TEST_ASSERT(!heels.roll_heel_trip(practiced, 100), "Heel walker trait did not stop the trip")

	var/mob/living/carbon/human/plain_runner = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/shoes/simpleshoes/plain = allocate(/obj/item/clothing/shoes/simpleshoes)
	plain_runner.equip_to_slot_or_del(plain, ITEM_SLOT_SHOES)
	plain_runner.m_intent = MOVE_INTENT_RUN
	TEST_ASSERT(!plain.roll_heel_trip(plain_runner, 100), "Plain shoes tripped a runner")

	var/obj/item/clothing/shoes/heels/carried = allocate(/obj/item/clothing/shoes/heels)
	plain_runner.put_in_hands(carried)
	TEST_ASSERT(!carried.roll_heel_trip(plain_runner, 100), "Heels held in hand tripped the holder")

/datum/unit_test/heeled_shoes_trip/proc/make_heeled_wearer(move_intent)
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/shoes/heels/heels = allocate(/obj/item/clothing/shoes/heels)
	wearer.equip_to_slot_or_del(heels, ITEM_SLOT_SHOES)
	wearer.m_intent = move_intent
	return wearer
