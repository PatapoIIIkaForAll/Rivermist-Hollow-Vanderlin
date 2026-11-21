/// Quirk refusal lines and the facial gore wounds that player bodies swap for lighter stand-ins.

/// Every refusal of the quirk menu names its reason in one plain line.
/datum/unit_test/quirk_refusal_reasons/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)

	prefs.quirks = list(/datum/quirk/negative/rough_start)
	TEST_ASSERT_EQUAL(prefs.quirk_refusal_reason(/datum/quirk/negative/rough_start), "You already have Rough Start.", "A held quirk should say it is already taken")
	// Each pair is listed one way only, so each catches one direction of the check.
	prefs.quirks = list(/datum/quirk/positive/iron_will)
	TEST_ASSERT_EQUAL(prefs.quirk_refusal_reason(/datum/quirk/negative/weak_heart), "Weak Heart conflicts with Iron Will.", "A quirk that lists a held quirk as incompatible should name it")
	prefs.quirks = list(/datum/quirk/positive/goodman)
	TEST_ASSERT_EQUAL(prefs.quirk_refusal_reason(/datum/quirk/negative/wanted), "Wanted conflicts with Good man.", "A quirk listed as incompatible by a held quirk should name it")

	prefs.quirks = list()
	var/balance = prefs.calculate_quirk_balance()
	TEST_ASSERT(balance < 10, "A fresh character should not afford a 10 point quirk")
	TEST_ASSERT_EQUAL(prefs.quirk_refusal_reason(/datum/quirk/positive/folk_hero), "Not enough quirk points: Folk Hero costs 10, you have [balance].", "An unaffordable quirk should give its cost and the balance")

	prefs.quirks = list(
		/datum/quirk/positive/keen_eye,
		/datum/quirk/positive/light_footed,
		/datum/quirk/positive/heel_walker,
		/datum/quirk/positive/quick_learner,
		/datum/quirk/positive/iron_will,
		/datum/quirk/positive/composed,
	)
	TEST_ASSERT_EQUAL(prefs.quirk_refusal_reason(/datum/quirk/positive/naturalist), "You cannot take more than [MAX_POSITIVE] positive quirks.", "A positive quirk past the cap should name the cap")

	prefs.quirks = list()
	var/datum/species/old_species = prefs.pref_species
	prefs.pref_species = new /datum/species/kobold
	qdel(old_species)
	TEST_ASSERT_EQUAL(prefs.quirk_refusal_reason(/datum/quirk/negative/tainted_soul), "Tainted Soul is not available to the Kobold species.", "A species-blocked quirk should name the species")
	TEST_ASSERT(!prefs.can_add_quirk(/datum/quirk/negative/tainted_soul), "can_add_quirk should still answer FALSE for a refused quirk")
	TEST_ASSERT(!prefs.add_quirk(/datum/quirk/negative/tainted_soul), "A refused quirk must not be added")
	TEST_ASSERT(!(/datum/quirk/negative/tainted_soul in prefs.quirks), "A refused quirk must stay out of the list")

	TEST_ASSERT_NULL(prefs.quirk_refusal_reason(/datum/quirk/negative/lost_keys), "A valid quirk should have no refusal")
	TEST_ASSERT(prefs.can_add_quirk(/datum/quirk/negative/lost_keys), "can_add_quirk should answer TRUE for a valid quirk")

/// Player bodies get the lighter stand-in, NPC bodies keep facial gore, and the groin wound is unchanged.
/datum/unit_test/gore_wound_player_stand_in/Run()
	var/mob/living/carbon/human/player = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/npc = allocate(/mob/living/carbon/human)
	player.mind = allocate(/datum/mind)
	player.mind.current = player
	player.mind.key = "gore-wound-test-player"
	TEST_ASSERT(player.is_player_character(), "A keyed mind should count as a player")
	TEST_ASSERT(!npc.is_player_character(), "A mindless human should count as an NPC")

	var/list/expected = list(
		/datum/wound/facial/ears = /datum/wound/puncture/large,
		/datum/wound/facial/eyes/right = /datum/wound/fracture/head/eyes,
		/datum/wound/facial/eyes/left/permanent = /datum/wound/fracture/head/eyes,
		/datum/wound/facial/tongue = /datum/wound/fracture/mouth,
		/datum/wound/facial/tongue/permanent = /datum/wound/fracture/mouth,
		/datum/wound/facial/disfigurement = /datum/wound/puncture/large,
		/datum/wound/facial/disfigurement/nose = /datum/wound/fracture/head/nose,
	)
	for(var/gore_type in expected)
		TEST_ASSERT_EQUAL(wound_type_for_victim(gore_type, player), expected[gore_type], "[gore_type] should become its stand-in on a player")
		TEST_ASSERT_EQUAL(wound_type_for_victim(gore_type, npc), gore_type, "[gore_type] should stay as is on an NPC")
	TEST_ASSERT_EQUAL(wound_type_for_victim(/datum/wound/cbt, player), /datum/wound/cbt, "The groin wound must not change for players")

	var/obj/item/bodypart/player_head = player.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT_NOTNULL(player_head, "The player should have a head")
	var/datum/wound/player_wound = player_head.add_wound(/datum/wound/facial/tongue)
	TEST_ASSERT_NOTNULL(player_wound, "A player should still take a wound from a tongue crit")
	TEST_ASSERT(istype(player_wound, /datum/wound/fracture/mouth), "A player should take a jaw fracture, not [player_wound.type]")
	TEST_ASSERT_NULL(player_head.has_wound(/datum/wound/facial/tongue), "A player must not take the tongue wound")
	TEST_ASSERT_NOTNULL(player.getorganslot(ORGAN_SLOT_TONGUE), "A player must keep the tongue")

	var/obj/item/bodypart/npc_head = npc.get_bodypart(BODY_ZONE_HEAD)
	TEST_ASSERT_NOTNULL(npc_head, "The NPC should have a head")
	TEST_ASSERT_NOTNULL(npc.getorganslot(ORGAN_SLOT_TONGUE), "The NPC should start with a tongue")
	var/datum/wound/npc_wound = npc_head.add_wound(/datum/wound/facial/tongue)
	TEST_ASSERT_NOTNULL(npc_wound, "An NPC should take the tongue wound")
	TEST_ASSERT(istype(npc_wound, /datum/wound/facial/tongue), "An NPC should take the tongue wound itself")
	TEST_ASSERT_NULL(npc.getorganslot(ORGAN_SLOT_TONGUE), "An NPC should lose the tongue")

	var/obj/item/bodypart/player_chest = player.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_NOTNULL(player_chest, "The player should have a chest")
	var/datum/wound/groin_wound = player_chest.add_wound(/datum/wound/cbt)
	TEST_ASSERT(istype(groin_wound, /datum/wound/cbt), "A player should still take the groin wound")

	var/mob/living/carbon/human/npc_two = allocate(/mob/living/carbon/human)
	TEST_ASSERT_NOTNULL(npc_two.getorganslot(ORGAN_SLOT_TONGUE), "The second NPC should start with a tongue")
	player.riddle_tongue_penalty()
	TEST_ASSERT_NOTNULL(player.getorganslot(ORGAN_SLOT_TONGUE), "A player must keep the tongue through the riddle")
	TEST_ASSERT_NOTNULL(player.has_status_effect(/datum/status_effect/silenced), "A player should be silenced by the riddle instead")
	npc_two.riddle_tongue_penalty()
	TEST_ASSERT_NULL(npc_two.getorganslot(ORGAN_SLOT_TONGUE), "An NPC should still lose the tongue to the riddle")

	player.acid_scar_face()
	TEST_ASSERT(!HAS_TRAIT(player, TRAIT_DISFIGURED), "Acid must not disfigure a player")
	npc_two.acid_scar_face()
	TEST_ASSERT(HAS_TRAIT(npc_two, TRAIT_DISFIGURED), "Acid should still disfigure an NPC")

	player.lose_face_to_thief()
	TEST_ASSERT(!HAS_TRAIT_FROM(player, TRAIT_DISFIGURED, TRAIT_GENERIC), "A stolen face must not disfigure a player for good")
	player.restore_stolen_face()
	TEST_ASSERT(!HAS_TRAIT(player, TRAIT_DISFIGURED), "A player should get the face back when the timer ends")
	npc.lose_face_to_thief()
	TEST_ASSERT(HAS_TRAIT_FROM(npc, TRAIT_DISFIGURED, TRAIT_GENERIC), "A stolen face should still disfigure an NPC for good")

	player.mind.current = null
	player.mind = null
