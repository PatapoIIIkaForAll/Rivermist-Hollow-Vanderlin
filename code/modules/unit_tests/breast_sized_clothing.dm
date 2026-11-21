/// Quad and sextuple breasts keep showing under a breast-sized garment instead of the plain fallback hiding them.
/datum/unit_test/breast_sized_clothing_keeps_multi_breasts/Run()
	for(var/accessory_path in list(/datum/sprite_accessory/genitals/breasts/pair, /datum/sprite_accessory/genitals/breasts/quad, /datum/sprite_accessory/genitals/breasts/sextuple))
		var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
		body.set_species(/datum/species/kobold)
		body.gender = FEMALE
		body.give_genitals()
		var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
		TEST_ASSERT_NOTNULL(breasts, "Test setup: the kobold needs breasts")
		breasts.organ_size = BREAST_SIZE_NORMAL
		breasts.accessory_type = accessory_path
		var/obj/item/clothing/shirt/dress/royal/dress = allocate(/obj/item/clothing/shirt/dress/royal)
		body.equip_to_slot_or_del(dress, ITEM_SLOT_SHIRT)
		TEST_ASSERT_EQUAL(body.wear_shirt, dress, "Test setup: the gown should be worn")
		TEST_ASSERT_EQUAL(dress.get_breast_sized_size_key(body), "[BREAST_SIZE_NORMAL]_dwarf", "[accessory_path] should wear the sized gown sheet")
		TEST_ASSERT(breasts_visible_under_clothes(body), "[accessory_path] breasts should stay visible under the sized gown")

/// A plain leotard under a sized gown hides the breasts but keeps the gown's front cloth child.
/datum/unit_test/breast_sized_clothing_keeps_front_over_undershirt/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	body.set_species(/datum/species/kobold)
	body.gender = FEMALE
	body.give_genitals()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	TEST_ASSERT_NOTNULL(breasts, "Test setup: the kobold needs breasts")
	breasts.organ_size = 7
	breasts.accessory_type = /datum/sprite_accessory/genitals/breasts/pair
	var/obj/item/clothing/undershirt/athletic_leotard/leotard = allocate(/obj/item/clothing/undershirt/athletic_leotard)
	body.equip_to_slot_or_del(leotard, ITEM_SLOT_UNDERSHIRT)
	TEST_ASSERT_EQUAL(body.undershirt, leotard, "Test setup: the leotard should be worn")
	TEST_ASSERT(leotard.flags_inv & HIDEBOOB, "Test setup: the leotard should hide the breasts")
	var/obj/item/clothing/shirt/dress/royal/dress = allocate(/obj/item/clothing/shirt/dress/royal)
	body.equip_to_slot_or_del(dress, ITEM_SLOT_SHIRT)
	var/datum/component/breast_animation/animation = body.LoadComponent(/datum/component/breast_animation)
	animation.refresh()

	TEST_ASSERT(animation.visual, "Size 7 pair breasts should get the animated child")
	TEST_ASSERT(animation.visual.vis_flags & VIS_HIDE, "The leotard should still hide the breasts")
	TEST_ASSERT_EQUAL(length(animation.garment_visuals), 1, "The gown should keep its front cloth over the leotard")

/// The royal gown's low neckline keeps the animated breasts visible above its front cloth.
/datum/unit_test/breast_sized_clothing_royal_gown_shows_breasts/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	body.set_species(/datum/species/kobold)
	body.gender = FEMALE
	body.give_genitals()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	TEST_ASSERT_NOTNULL(breasts, "Test setup: the kobold needs breasts")
	breasts.organ_size = 7
	breasts.accessory_type = /datum/sprite_accessory/genitals/breasts/pair
	var/obj/item/clothing/shirt/dress/royal/dress = allocate(/obj/item/clothing/shirt/dress/royal)
	body.equip_to_slot_or_del(dress, ITEM_SLOT_SHIRT)
	var/datum/component/breast_animation/animation = body.LoadComponent(/datum/component/breast_animation)
	animation.refresh()

	TEST_ASSERT(animation.visual, "Size 7 pair breasts should get the animated child")
	TEST_ASSERT(!(animation.visual.vis_flags & VIS_HIDE), "The royal gown must not hide the breasts above its neckline")
	TEST_ASSERT_EQUAL(length(animation.garment_visuals), 1, "The royal gown should draw its front cloth over the breasts")
