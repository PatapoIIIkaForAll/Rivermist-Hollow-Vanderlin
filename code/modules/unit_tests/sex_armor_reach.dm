/// Reach through clothes and armor for sex acts: clothes never block, armor blocks unless the receiver allows players.
/datum/unit_test/sex_armor_reach
	abstract_type = /datum/unit_test/sex_armor_reach

/// A clientless human that counts as a player actor.
/mob/living/carbon/human/sex_reach_test_player

/mob/living/carbon/human/sex_reach_test_player/is_player_sex_actor()
	return TRUE

/// A male receiver with genitals, standing with the actor.
/datum/unit_test/sex_armor_reach/proc/make_receiver(allow_reach = FALSE)
	var/mob/living/carbon/human/receiver = allocate(/mob/living/carbon/human)
	receiver.gender = MALE
	receiver.give_genitals()
	receiver.set_cached_erp_preferences(list(/datum/erp_preference/boolean/allow_reach_under_armor = allow_reach))
	return receiver

/// Puts groin and leg armor heavier than light on [wearer].
/datum/unit_test/sex_armor_reach/proc/wear_armor(mob/living/carbon/human/wearer)
	var/obj/item/clothing/armor/plate = allocate(/obj/item/clothing/armor)
	plate.armor_class = AC_MEDIUM
	plate.body_parts_covered = CHEST|GROIN|LEGS
	wearer.equip_to_slot_or_del(plate, ITEM_SLOT_ARMOR)
	return plate

/// A bare reach check: no same-tile or grab rules, only the garment rule.
/datum/unit_test/sex_armor_reach/proc/make_probe_action()
	var/datum/sex_action/action = allocate(/datum/sex_action)
	action.check_same_tile = FALSE
	action.require_grab = FALSE
	return action

/datum/unit_test/sex_armor_reach/cloth_never_blocks

/datum/unit_test/sex_armor_reach/cloth_never_blocks/Run()
	var/mob/living/carbon/human/sex_reach_test_player/actor = allocate(/mob/living/carbon/human/sex_reach_test_player)
	var/mob/living/carbon/human/receiver = make_receiver(FALSE)
	var/obj/item/clothing/pants/trousers = allocate(/obj/item/clothing/pants)
	trousers.armor_class = AC_LIGHT
	trousers.body_parts_covered = GROIN|LEGS
	receiver.equip_to_slot_or_del(trousers, ITEM_SLOT_PANTS)
	TEST_ASSERT_EQUAL(receiver.wear_pants, trousers, "Test setup: the trousers should be worn")
	TEST_ASSERT_NOTNULL(receiver.getorganslot(ORGAN_SLOT_PENIS), "Test setup: the receiver needs a cock")

	TEST_ASSERT_NULL(receiver.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, actor), "Light trousers must not keep a player off the groin")
	TEST_ASSERT_NULL(receiver.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN), "Light trousers must not block even the strict mob rule")
	var/datum/sex_action/action = make_probe_action()
	TEST_ASSERT(action.check_location_accessible(actor, receiver, BODY_ZONE_PRECISE_GROIN), "The panel reach check must pass through light trousers")
	TEST_ASSERT_NULL(action.armor_refusal, "Clothes must not leave an armor refusal")
	TEST_ASSERT(receiver.is_penis_grippable(actor), "A cock under light trousers can be gripped")

/datum/unit_test/sex_armor_reach/armor_blocks_without_consent

/datum/unit_test/sex_armor_reach/armor_blocks_without_consent/Run()
	var/mob/living/carbon/human/sex_reach_test_player/actor = allocate(/mob/living/carbon/human/sex_reach_test_player)
	var/mob/living/carbon/human/receiver = make_receiver(FALSE)
	var/obj/item/clothing/armor/plate = wear_armor(receiver)
	TEST_ASSERT_EQUAL(receiver.wear_armor, plate, "Test setup: the armor should be worn")
	TEST_ASSERT_NOTNULL(receiver.getorganslot(ORGAN_SLOT_PENIS), "Test setup: the receiver needs a cock")

	TEST_ASSERT_EQUAL(receiver.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, actor), plate, "Armor must block a player when the receiver has not allowed reach")
	var/datum/sex_action/action = make_probe_action()
	TEST_ASSERT(!action.check_location_accessible(actor, receiver, BODY_ZONE_PRECISE_GROIN), "The panel reach check must fail on armor without consent")
	TEST_ASSERT_EQUAL(action.armor_refusal, "[receiver]'s armor is in the way.", "The refusal must name the armor")
	TEST_ASSERT(!receiver.is_penis_grippable(actor), "A cock under armor cannot be gripped without consent")

	var/obj/item/clothing/legwears/stockings = allocate(/obj/item/clothing/legwears)
	receiver.equip_to_slot_or_del(stockings, ITEM_SLOT_SOCKS)
	TEST_ASSERT_EQUAL(receiver.legwear_socks, stockings, "Test setup: the stockings should be worn")
	TEST_ASSERT_NULL(receiver.get_sex_reachable_legwear(actor), "Stockings under leg armor are out of reach without consent")

/datum/unit_test/sex_armor_reach/consent_lets_players_reach

/datum/unit_test/sex_armor_reach/consent_lets_players_reach/Run()
	var/mob/living/carbon/human/sex_reach_test_player/actor = allocate(/mob/living/carbon/human/sex_reach_test_player)
	var/mob/living/carbon/human/receiver = make_receiver(TRUE)
	var/obj/item/clothing/armor/plate = wear_armor(receiver)
	TEST_ASSERT_EQUAL(receiver.wear_armor, plate, "Test setup: the armor should be worn")
	TEST_ASSERT_NOTNULL(receiver.getorganslot(ORGAN_SLOT_PENIS), "Test setup: the receiver needs a cock")

	TEST_ASSERT_NULL(receiver.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, actor), "A player may reach under armor the receiver allowed")
	var/datum/sex_action/action = make_probe_action()
	TEST_ASSERT(action.check_location_accessible(actor, receiver, BODY_ZONE_PRECISE_GROIN), "The panel reach check must pass under allowed armor")
	TEST_ASSERT(receiver.is_penis_grippable(actor), "A player may grip a cock under allowed armor")

	var/obj/item/clothing/legwears/stockings = allocate(/obj/item/clothing/legwears)
	receiver.equip_to_slot_or_del(stockings, ITEM_SLOT_SOCKS)
	TEST_ASSERT_EQUAL(receiver.legwear_socks, stockings, "Test setup: the stockings should be worn")
	TEST_ASSERT_EQUAL(receiver.get_sex_reachable_legwear(actor), stockings, "A player may reach stockings under allowed leg armor")

/datum/unit_test/sex_armor_reach/mobs_ignore_consent

/datum/unit_test/sex_armor_reach/mobs_ignore_consent/Run()
	var/mob/living/carbon/human/npc = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/receiver = make_receiver(TRUE)
	var/obj/item/clothing/armor/plate = wear_armor(receiver)
	TEST_ASSERT_EQUAL(receiver.wear_armor, plate, "Test setup: the armor should be worn")
	TEST_ASSERT_NOTNULL(receiver.getorganslot(ORGAN_SLOT_PENIS), "Test setup: the receiver needs a cock")
	TEST_ASSERT(!npc.is_player_sex_actor(), "Test setup: a clientless mob is no player")

	TEST_ASSERT_EQUAL(receiver.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, npc), plate, "Armor must block a mob even when the receiver allows players")
	TEST_ASSERT_EQUAL(receiver.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN), plate, "No actor means the strict rule")
	var/datum/sex_action/action = make_probe_action()
	TEST_ASSERT(!action.check_location_accessible(npc, receiver, BODY_ZONE_PRECISE_GROIN), "The panel reach check must fail for a mob actor")
	TEST_ASSERT(!receiver.is_penis_grippable(npc), "A mob cannot grip a cock under armor")

	var/obj/item/clothing/legwears/stockings = allocate(/obj/item/clothing/legwears)
	receiver.equip_to_slot_or_del(stockings, ITEM_SLOT_SOCKS)
	TEST_ASSERT_EQUAL(receiver.legwear_socks, stockings, "Test setup: the stockings should be worn")
	TEST_ASSERT_NULL(receiver.get_sex_reachable_legwear(npc), "A mob cannot reach stockings under leg armor")

/datum/unit_test/sex_armor_reach/consent_defaults_off

/datum/unit_test/sex_armor_reach/consent_defaults_off/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	prefs.setup_default_erp_preferences()
	var/datum/erp_preference/boolean/allow_reach_under_armor/pref = new
	TEST_ASSERT_EQUAL(pref.get_value(prefs), FALSE, "Armor must block by default")
	var/mob/living/carbon/human/npc = allocate(/mob/living/carbon/human)
	prefs.has_spawned = TRUE
	npc.erp_preference_edit_grace_expires_at = 0
	var/datum/erp_preference/boolean/auto_clench/locked_pref = new
	TEST_ASSERT_NOTNULL(locked_pref.get_edit_lock_reason(npc, prefs), "Test setup: other ERP prefs lock after spawning")
	TEST_ASSERT_NULL(pref.get_edit_lock_reason(npc, prefs), "The consent must stay editable mid-round")
	TEST_ASSERT(!npc.allows_reach_under_armor(npc), "A clientless mob without saved prefs keeps its armor closed")

/// A worn face cover over the mouth; light cloth unless told otherwise.
/datum/unit_test/sex_armor_reach/proc/wear_mouth_cover(mob/living/carbon/human/wearer, gag = FALSE)
	var/obj/item/clothing/face/cover = allocate(/obj/item/clothing/face)
	cover.flags_cover = MASKCOVERSMOUTH
	cover.clothing_flags = gag ? BLOCKS_SPEECH : NONE
	cover.armor_class = ARMOR_CLASS_NONE
	wearer.equip_to_slot_or_del(cover, ITEM_SLOT_MASK)
	return cover

/datum/unit_test/sex_armor_reach/cloth_mask_does_not_block_oral

/datum/unit_test/sex_armor_reach/cloth_mask_does_not_block_oral/Run()
	var/mob/living/carbon/human/sex_reach_test_player/actor = allocate(/mob/living/carbon/human/sex_reach_test_player)
	var/mob/living/carbon/human/receiver = make_receiver(FALSE)
	var/obj/item/clothing/face/veil = wear_mouth_cover(receiver)
	TEST_ASSERT_EQUAL(receiver.wear_mask, veil, "Test setup: the veil should be worn")
	TEST_ASSERT(receiver.is_mouth_covered(), "Test setup: the veil should cover the mouth")

	TEST_ASSERT(receiver.mouth_is_free(actor), "A cloth veil must not block an oral act")
	TEST_ASSERT(receiver.mouth_is_free(), "A cloth veil must not block even the strict mob rule")
	var/datum/sex_action/action = make_probe_action()
	TEST_ASSERT(action.check_location_accessible(actor, receiver, BODY_ZONE_PRECISE_MOUTH), "The panel mouth check must pass through a veil")
	TEST_ASSERT(!receiver.mouth_is_free(actor, cloth_blocks = TRUE), "Callers that need a bare mouth still see the veil")

/datum/unit_test/sex_armor_reach/gag_blocks_oral

/datum/unit_test/sex_armor_reach/gag_blocks_oral/Run()
	var/mob/living/carbon/human/sex_reach_test_player/actor = allocate(/mob/living/carbon/human/sex_reach_test_player)
	var/mob/living/carbon/human/receiver = make_receiver(TRUE)
	var/obj/item/clothing/face/gag = wear_mouth_cover(receiver, gag = TRUE)
	TEST_ASSERT_EQUAL(receiver.wear_mask, gag, "Test setup: the gag should be worn")

	TEST_ASSERT(!receiver.mouth_is_free(actor), "A gag must block oral acts even with armor consent")
	var/datum/sex_action/action = make_probe_action()
	TEST_ASSERT(!action.check_location_accessible(actor, receiver, BODY_ZONE_PRECISE_MOUTH), "The panel mouth check must fail on a gag")
	TEST_ASSERT_NULL(action.armor_refusal, "A gag is no armor refusal")

/datum/unit_test/sex_armor_reach/armored_helmet_blocks_oral_without_consent

/datum/unit_test/sex_armor_reach/armored_helmet_blocks_oral_without_consent/Run()
	var/mob/living/carbon/human/sex_reach_test_player/actor = allocate(/mob/living/carbon/human/sex_reach_test_player)
	var/mob/living/carbon/human/npc = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/closed = make_receiver(FALSE)
	var/mob/living/carbon/human/open = make_receiver(TRUE)
	for(var/mob/living/carbon/human/wearer as anything in list(closed, open))
		var/obj/item/clothing/head/helm = allocate(/obj/item/clothing/head)
		helm.flags_cover = HEADCOVERSMOUTH
		helm.armor_class = AC_HEAVY
		wearer.equip_to_slot_or_del(helm, ITEM_SLOT_HEAD)
		TEST_ASSERT_EQUAL(wearer.head, helm, "Test setup: the helmet should be worn")

	TEST_ASSERT(!closed.mouth_is_free(actor), "An armored helmet must block oral acts without consent")
	TEST_ASSERT(open.mouth_is_free(actor), "A player may reach under an allowed armored helmet")
	TEST_ASSERT(!open.mouth_is_free(npc), "A mob never reaches under an armored helmet")
	TEST_ASSERT(!open.mouth_is_free(actor, cloth_blocks = TRUE), "Callers that need a bare mouth still see the helmet")
	var/datum/sex_action/action = make_probe_action()
	TEST_ASSERT(!action.check_location_accessible(actor, closed, BODY_ZONE_PRECISE_MOUTH), "The panel mouth check must fail on a closed helmet")
	TEST_ASSERT_EQUAL(action.armor_refusal, "[closed]'s armor is in the way.", "A helmet over the mouth must name the armor")

/datum/unit_test/sex_armor_reach/status_lines_follow_examine

/datum/unit_test/sex_armor_reach/status_lines_follow_examine/Run()
	var/mob/living/carbon/human/receiver = allocate(/mob/living/carbon/human)
	receiver.gender = FEMALE
	receiver.give_genitals()
	TEST_ASSERT_NOTNULL(receiver.getorganslot(ORGAN_SLOT_BUTT), "Test setup: the receiver needs a butt")
	TEST_ASSERT_NOTNULL(receiver.get_visible_groin_summary_description(/datum/mob_descriptor/butt), "A bare butt shows in the status lines")

	// A shirt covers no groin but hides the butt from examine.
	var/obj/item/clothing/shirt/tunic = allocate(/obj/item/clothing/shirt)
	tunic.body_parts_covered = CHEST|VITALS
	tunic.flags_inv = HIDEBUTT
	receiver.equip_to_slot_or_del(tunic, ITEM_SLOT_SHIRT)
	TEST_ASSERT_EQUAL(receiver.wear_shirt, tunic, "Test setup: the shirt should be worn")
	var/datum/mob_descriptor/butt/descriptor = new
	TEST_ASSERT(!descriptor.can_describe(receiver), "Test setup: examine hides the butt under the shirt")
	TEST_ASSERT_NULL(receiver.get_visible_groin_summary_description(/datum/mob_descriptor/butt), "The status lines must hide what examine hides")
	TEST_ASSERT_NOTNULL(receiver.get_visible_groin_summary_description(/datum/mob_descriptor/butt, FALSE), "The older rule reads only body coverage")
	var/butt_line = receiver.get_character_information_line("have [receiver.get_visible_groin_summary_description(/datum/mob_descriptor/butt, FALSE)]")
	TEST_ASSERT(!(butt_line in receiver.return_character_information()), "By default the status lines follow examine")
	TEST_ASSERT(butt_line in receiver.return_character_information(FALSE), "With the switch off the status lines use the older rule")

/datum/unit_test/sex_armor_reach/ring_gag_lets_oral_through

/datum/unit_test/sex_armor_reach/ring_gag_lets_oral_through/Run()
	var/mob/living/carbon/human/sex_reach_test_player/actor = allocate(/mob/living/carbon/human/sex_reach_test_player)
	var/mob/living/carbon/human/ringed = make_receiver(FALSE)
	var/mob/living/carbon/human/balled = make_receiver(FALSE)
	var/obj/item/clothing/face/ring = allocate(/obj/item/clothing/face/bdsm_gag/ring/black)
	var/obj/item/clothing/face/ball = allocate(/obj/item/clothing/face/bdsm_gag/ball/black)
	ringed.equip_to_slot_or_del(ring, ITEM_SLOT_MASK)
	balled.equip_to_slot_or_del(ball, ITEM_SLOT_MASK)
	TEST_ASSERT_EQUAL(ringed.wear_mask, ring, "Test setup: the ring gag should be worn")
	TEST_ASSERT_EQUAL(balled.wear_mask, ball, "Test setup: the ball gag should be worn")
	TEST_ASSERT(ringed.is_muzzled(), "Test setup: the ring gag still muffles speech")

	var/datum/sex_action/action = make_probe_action()
	TEST_ASSERT(ringed.mouth_is_free(actor), "A ring gag keeps the mouth open for oral acts")
	TEST_ASSERT(action.check_location_accessible(actor, ringed, BODY_ZONE_PRECISE_MOUTH), "The panel mouth check must pass a ring gag")
	TEST_ASSERT(!ringed.mouth_is_free(actor, cloth_blocks = TRUE), "Callers that need a bare mouth still see the ring gag")
	TEST_ASSERT(!balled.mouth_is_free(actor), "A ball gag fills the mouth")
	TEST_ASSERT(!action.check_location_accessible(actor, balled, BODY_ZONE_PRECISE_MOUTH), "The panel mouth check must fail on a ball gag")
