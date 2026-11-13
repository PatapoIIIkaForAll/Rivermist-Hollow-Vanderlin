/// A torn top drops its chest hide flags, costs integrity without breaking, and sewing puts it all back.
/datum/unit_test/clothing_tear_top_and_mend/Run()
	var/obj/item/clothing/shirt/dress/dress = allocate(/obj/item/clothing/shirt/dress)
	TEST_ASSERT(dress.can_tear_top(), "A plain dress should be tearable at the chest")
	var/start_integrity = dress.get_integrity()
	TEST_ASSERT(dress.tear_open_at(BODY_ZONE_CHEST), "The chest tear should take")
	TEST_ASSERT(dress.torn_top, "The dress should record the top tear")
	TEST_ASSERT(!(dress.flags_inv & HIDEBOOB), "A torn top should stop hiding the breasts")
	TEST_ASSERT(!(dress.flags_inv & HIDEUNDIESTOP), "A torn top should stop hiding the top underwear")
	TEST_ASSERT(dress.flags_inv & HIDECROTCH, "A top tear should leave the hem flags alone")
	TEST_ASSERT(dress.get_integrity() < start_integrity, "A tear should cost integrity")
	TEST_ASSERT(!dress.obj_broken, "A tear should never break the garment")
	TEST_ASSERT(!dress.can_tear_top(), "A torn top should not tear twice")
	TEST_ASSERT(dress.has_clothing_tears(), "The dress should report its tear")
	TEST_ASSERT_EQUAL(length(dress.get_tear_examine_lines()), 1, "A torn top should add one examine line")

	TEST_ASSERT(dress.mend_tears(), "Sewing should close the tear")
	TEST_ASSERT(!dress.torn_top, "Sewing should clear the top tear")
	TEST_ASSERT(dress.flags_inv & HIDEBOOB, "Sewing should put back the breast hide flag")
	TEST_ASSERT(dress.flags_inv & HIDEUNDIESTOP, "Sewing should put back the underwear hide flag")
	TEST_ASSERT_EQUAL(length(dress.get_tear_examine_lines()), 0, "A mended dress should add no examine line")
	TEST_ASSERT(!dress.mend_tears(), "There should be nothing left to mend")

/// A torn hem drops its groin hide flags and leaves the chest covered; sewing puts them back.
/datum/unit_test/clothing_tear_hem_and_mend/Run()
	var/obj/item/clothing/shirt/dress/dress = allocate(/obj/item/clothing/shirt/dress)
	TEST_ASSERT(dress.can_tear_hem(), "A plain dress should be tearable at the hem")
	TEST_ASSERT(dress.tear_open_at(BODY_ZONE_PRECISE_GROIN), "The hem tear should take")
	TEST_ASSERT(dress.torn_hem, "The dress should record the hem tear")
	TEST_ASSERT(!(dress.flags_inv & HIDECROTCH), "A torn hem should stop hiding the groin")
	TEST_ASSERT(!(dress.flags_inv & HIDEBUTT), "A torn hem should stop hiding the butt")
	TEST_ASSERT(!(dress.flags_inv & HIDEUNDIESBOT), "A torn hem should stop hiding the bottom underwear")
	TEST_ASSERT(dress.flags_inv & HIDEBOOB, "A hem tear should leave the chest covered")
	TEST_ASSERT(!dress.can_tear_hem(), "A torn hem should not tear twice")

	TEST_ASSERT(dress.mend_tears(), "Sewing should close the hem")
	TEST_ASSERT(dress.flags_inv & HIDECROTCH, "Sewing should put back the groin hide flag")
	TEST_ASSERT(dress.flags_inv & HIDEBUTT, "Sewing should put back the butt hide flag")
	TEST_ASSERT(dress.flags_inv & HIDEUNDIESBOT, "Sewing should put back the underwear hide flag")

/// Armour, garments a needle cannot mend and garments off the three outer slots never tear.
/datum/unit_test/clothing_tear_rejects_untearable/Run()
	var/obj/item/clothing/shirt/dress/dress = allocate(/obj/item/clothing/shirt/dress)
	dress.armor_class = AC_LIGHT
	TEST_ASSERT(!dress.can_tear_top(), "Armour should never tear at the chest")
	TEST_ASSERT(!dress.can_tear_hem(), "Armour should never tear at the hem")
	TEST_ASSERT(!dress.tear_open_at(BODY_ZONE_CHEST), "A refused tear should change nothing")
	TEST_ASSERT(dress.flags_inv & HIDEBOOB, "A refused tear should leave the hide flags alone")

	dress.armor_class = ARMOR_CLASS_NONE
	dress.sewrepair = null
	TEST_ASSERT(!dress.can_tear_top(), "A garment no needle can mend should not tear")

	dress.sewrepair = /datum/attribute/skill/misc/sewing/mending
	dress.slot_flags = ITEM_SLOT_PANTS
	TEST_ASSERT(!dress.can_tear_top(), "Trousers and underwear should never tear")

	dress.slot_flags = ITEM_SLOT_ARMOR
	TEST_ASSERT(dress.can_tear_top(), "The plain dress should tear again once the rule passes")
	TEST_ASSERT(!dress.can_tear_at(BODY_ZONE_HEAD), "Only the chest and groin zones tear")

/// A tear takes the outermost garment still hiding the spot and skips ones already torn there.
/datum/unit_test/clothing_tear_picks_outermost/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	// Two different types: a body refuses to layer one garment type over itself.
	var/obj/item/clothing/shirt/dress/over = allocate(/obj/item/clothing/shirt/dress)
	var/obj/item/clothing/shirt/tribalrag/under = allocate(/obj/item/clothing/shirt/tribalrag)
	body.equip_to_slot_or_del(over, ITEM_SLOT_ARMOR)
	body.equip_to_slot_or_del(under, ITEM_SLOT_SHIRT)
	TEST_ASSERT_EQUAL(body.wear_armor, over, "Test setup: the outer dress should be worn")
	TEST_ASSERT_EQUAL(body.wear_shirt, under, "Test setup: the inner dress should be worn")

	TEST_ASSERT_EQUAL(body.get_tear_target(BODY_ZONE_CHEST), over, "The tear should take the outer garment")
	TEST_ASSERT(over.tear_open_at(BODY_ZONE_CHEST), "The outer dress should tear")
	TEST_ASSERT_EQUAL(body.get_tear_target(BODY_ZONE_CHEST), under, "The next tear should take the garment below")
	TEST_ASSERT(under.tear_open_at(BODY_ZONE_CHEST), "The inner dress should tear")
	TEST_ASSERT_NULL(body.get_tear_target(BODY_ZONE_CHEST), "With both torn there should be nothing left to tear")
	// A torn outer garment stops hiding the one below it, so both tears are on show.
	var/list/pronouns = list(THEIR = body.p_their(), THEYVE = "[body.p_they(TRUE)] [body.p_have()]")
	TEST_ASSERT_EQUAL(length(body.get_torn_clothes_examine_lines(pronouns)), 2, "Both tears should be described once the outer garment is open")
	TEST_ASSERT(under.mend_tears(), "Sewing the inner garment should close its tear")
	TEST_ASSERT_EQUAL(length(body.get_torn_clothes_examine_lines(pronouns)), 1, "Only the garment still torn should be described")

	// A tear also clears the hide flag. Put it back by hand so the torn check alone is under test.
	over.flags_inv |= HIDEBOOB
	TEST_ASSERT_EQUAL(body.get_tear_target(BODY_ZONE_CHEST), under, "A garment already torn at the chest should be skipped")
	over.torn_hem = TRUE
	over.flags_inv |= HIDECROTCH
	TEST_ASSERT(body.get_tear_target(BODY_ZONE_PRECISE_GROIN) != over, "A garment already torn at the hem should be skipped")

/// A torn top is the only cover left, so the breasts draw above clothes until something covers them again.
/datum/unit_test/clothing_tear_bares_breasts/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	body.gender = FEMALE
	body.give_genitals()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	TEST_ASSERT_NOTNULL(breasts, "Test setup: the body needs breasts")
	TEST_ASSERT_NULL(body.underwear, "Test setup: the body should wear no underwear")
	var/was_shown = breasts.visible_through_clothes

	var/obj/item/clothing/shirt/dress/gen/dress = allocate(/obj/item/clothing/shirt/dress/gen)
	body.equip_to_slot_or_del(dress, ITEM_SLOT_ARMOR)
	TEST_ASSERT_EQUAL(body.wear_armor, dress, "Test setup: the dress should be worn")
	TEST_ASSERT(!body.torn_top_bares_breasts(), "A closed dress should keep the breasts covered")

	TEST_ASSERT(dress.tear_open_at(BODY_ZONE_CHEST), "The dress should tear at the chest")
	TEST_ASSERT(body.torn_top_bares_breasts(), "A torn top alone should bare the breasts")
	TEST_ASSERT_NOTNULL(body.GetComponent(/datum/component/torn_top), "A torn top should add the watcher")
	TEST_ASSERT_EQUAL(breasts.visible_through_clothes, DRAW_ABOVE, "The breasts should draw above the torn top")

	var/obj/item/clothing/shirt/tribalrag/cover = allocate(/obj/item/clothing/shirt/tribalrag)
	body.equip_to_slot_or_del(cover, ITEM_SLOT_SHIRT)
	TEST_ASSERT_EQUAL(body.wear_shirt, cover, "Test setup: the second garment should be worn")
	TEST_ASSERT(!body.torn_top_bares_breasts(), "A second closed garment should cover the breasts again")
	TEST_ASSERT_EQUAL(breasts.visible_through_clothes, was_shown, "Covering the breasts should put back how they were drawn")

	body.dropItemToGround(cover, force = TRUE)
	TEST_ASSERT_EQUAL(breasts.visible_through_clothes, DRAW_ABOVE, "Removing the cover should bare the breasts again")

	TEST_ASSERT(dress.mend_tears(), "Sewing should close the torn top")
	TEST_ASSERT_NULL(body.GetComponent(/datum/component/torn_top), "Sewing should drop the watcher")
	TEST_ASSERT_EQUAL(breasts.visible_through_clothes, was_shown, "Sewing should put back how the breasts were drawn")

/// Taking the torn top off drops the watcher and leaves the breasts as they were.
/datum/unit_test/clothing_tear_cleans_up_on_removal/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	body.gender = FEMALE
	body.give_genitals()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	TEST_ASSERT_NOTNULL(breasts, "Test setup: the body needs breasts")
	var/was_shown = breasts.visible_through_clothes

	var/obj/item/clothing/shirt/dress/gen/dress = allocate(/obj/item/clothing/shirt/dress/gen)
	body.equip_to_slot_or_del(dress, ITEM_SLOT_ARMOR)
	TEST_ASSERT(dress.tear_open_at(BODY_ZONE_CHEST), "The dress should tear at the chest")
	TEST_ASSERT_NOTNULL(body.GetComponent(/datum/component/torn_top), "Test setup: the watcher should be there")

	body.dropItemToGround(dress, force = TRUE)
	TEST_ASSERT_NULL(body.GetComponent(/datum/component/torn_top), "Taking the torn top off should drop the watcher")
	TEST_ASSERT_EQUAL(breasts.visible_through_clothes, was_shown, "Taking it off should put back how the breasts were drawn")
	TEST_ASSERT(dress.torn_top, "The garment should stay torn once it is off")

/// Horny mobs tear a tearable garment instead of pulling it off, but never one with no tear zone.
/datum/unit_test/clothing_tear_horny_strip_roll/Run()
	var/obj/item/clothing/shirt/dress/dress = allocate(/obj/item/clothing/shirt/dress)
	TEST_ASSERT_EQUAL(horny_strip_tear_zone(dress), BODY_ZONE_PRECISE_GROIN, "A dress strip should go for the hem first")
	TEST_ASSERT(horny_rolls_strip_tear(dress, 100), "A certain roll should tear a tearable dress")
	TEST_ASSERT(!horny_rolls_strip_tear(dress, 0), "An impossible roll should never tear")

	TEST_ASSERT(dress.tear_open_at(BODY_ZONE_PRECISE_GROIN), "The hem should tear")
	TEST_ASSERT_EQUAL(horny_strip_tear_zone(dress), BODY_ZONE_CHEST, "With the hem torn the strip should go for the chest")
	TEST_ASSERT(dress.tear_open_at(BODY_ZONE_CHEST), "The top should tear")
	TEST_ASSERT_NULL(horny_strip_tear_zone(dress), "A fully torn dress should have no tear zone left")
	TEST_ASSERT(!horny_rolls_strip_tear(dress, 100), "With no tear zone the strip should pull the garment off")

	var/obj/item/clothing/shirt/dress/armoured = allocate(/obj/item/clothing/shirt/dress)
	armoured.armor_class = AC_LIGHT
	TEST_ASSERT_NULL(horny_strip_tear_zone(armoured), "Armour should have no tear zone")
	TEST_ASSERT(!horny_rolls_strip_tear(armoured, 100), "Armour should always come off instead of tearing")
