/datum/unit_test/npc_yield_bonds_accepted_until_untied

/datum/unit_test/npc_yield_bonds_accepted_until_untied/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/obj/item/rope/arm_rope = allocate(/obj/item/rope)

	goblin.apply_status_effect(/datum/status_effect/npc_yield)
	TEST_ASSERT(goblin.surrendering, "A yielding mob must count as surrendering.")
	TEST_ASSERT(HAS_TRAIT(goblin, TRAIT_PACIFISM), "A yielding mob must not attack.")

	arm_rope.apply_cuffs(goblin, null)
	var/datum/status_effect/npc_yield/yield_effect = goblin.has_status_effect(/datum/status_effect/npc_yield)
	TEST_ASSERT(yield_effect?.captive, "Arms tied while yielding must make the mob a captive.")
	goblin.cuff_resist(arm_rope, instant = TRUE)
	TEST_ASSERT_EQUAL(goblin.handcuffed, arm_rope, "A captive must not break the bonds put on while it yielded.")

	goblin.uncuff()
	TEST_ASSERT_NULL(goblin.has_status_effect(/datum/status_effect/npc_yield), "An untied captive must stop yielding.")
	TEST_ASSERT(!goblin.surrendering, "An untied captive must stop surrendering.")
	TEST_ASSERT(!HAS_TRAIT(goblin, TRAIT_PACIFISM), "An untied captive must fight again.")

/datum/unit_test/npc_breaking_point_roll

/datum/unit_test/npc_breaking_point_roll/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	TEST_ASSERT_NOTNULL(goblin.ai_controller, "Setup: an NPC goblin should have an AI controller.")
	goblin.npc_death_damage = null
	goblin.npc_break_damage = 10
	goblin.npc_yield_chance = 100
	goblin.npc_flee_chance = 0

	goblin.setToxLoss(5)
	TEST_ASSERT_NULL(goblin.has_status_effect(/datum/status_effect/npc_yield), "A mob below its breaking point must keep fighting.")
	goblin.setToxLoss(15)
	TEST_ASSERT_NOTNULL(goblin.has_status_effect(/datum/status_effect/npc_yield), "A sure yield chance must make a broken mob yield.")

	goblin.remove_status_effect(/datum/status_effect/npc_yield)
	goblin.npc_yield_chance = 0
	goblin.npc_flee_chance = 100
	goblin.setToxLoss(20)
	TEST_ASSERT_NULL(goblin.has_status_effect(/datum/status_effect/npc_routed), "The breaking point is rolled once per beating.")

	goblin.setToxLoss(0)
	goblin.setToxLoss(15)
	TEST_ASSERT_NOTNULL(goblin.has_status_effect(/datum/status_effect/npc_routed), "A mob that healed up must roll again.")
	TEST_ASSERT(goblin.ai_controller.blackboard[BB_BASIC_MOB_FLEEING], "A routed mob must flee.")
	goblin.remove_status_effect(/datum/status_effect/npc_routed)
	TEST_ASSERT(!goblin.ai_controller.blackboard[BB_BASIC_MOB_FLEEING], "The end of a rout must end the flight.")

/datum/unit_test/npc_death_damage_kills

/datum/unit_test/npc_death_damage_kills/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	goblin.npc_break_damage = null
	goblin.npc_death_damage = 10

	goblin.setToxLoss(5)
	TEST_ASSERT_NOTEQUAL(goblin.stat, DEAD, "A mob below its death damage must live.")
	goblin.setToxLoss(15)
	TEST_ASSERT_EQUAL(goblin.stat, DEAD, "A mob past its death damage must die.")

/datum/unit_test/npc_breaking_point_skips_players_and_pets

/datum/unit_test/npc_breaking_point_skips_players_and_pets/Run()
	var/mob/living/carbon/human/species/goblin/npc/goblin = allocate(/mob/living/carbon/human/species/goblin/npc)
	goblin.npc_yield_chance = 100
	goblin.npc_death_damage = null
	goblin.mind = allocate(/datum/mind)
	goblin.mind.current = goblin
	goblin.mind.key = "npc-breaking-point-player"
	goblin.setToxLoss(goblin.npc_break_damage)
	TEST_ASSERT_NULL(goblin.has_status_effect(/datum/status_effect/npc_yield), "A player's body must never yield on its own.")
	goblin.mind.current = null
	goblin.mind = null

	var/mob/living/carbon/human/species/goblin/slaved/pet = allocate(/mob/living/carbon/human/species/goblin/slaved)
	pet.npc_yield_chance = 100
	pet.npc_death_damage = null
	pet.setToxLoss(pet.npc_break_damage)
	TEST_ASSERT_NULL(pet.has_status_effect(/datum/status_effect/npc_yield), "A pet must keep fighting for its owner.")

/datum/unit_test/npc_gutting_kills

/datum/unit_test/npc_gutting_kills/Run()
	var/mob/living/carbon/human/species/goblin/npc/disemboweled = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/datum/wound/slash/disembowel/disembowel = new
	disembowel.apply_to_bodypart(disemboweled.get_bodypart(BODY_ZONE_CHEST))
	TEST_ASSERT_EQUAL(disemboweled.stat, DEAD, "A disemboweled NPC must die on the spot.")

	var/mob/living/carbon/human/species/goblin/npc/gut_spilled = allocate(/mob/living/carbon/human/species/goblin/npc)
	var/datum/wound/spill/gut/gut_spill = new
	gut_spill.apply_to_bodypart(gut_spilled.get_bodypart(BODY_ZONE_CHEST))
	TEST_ASSERT_EQUAL(gut_spilled.stat, DEAD, "An NPC whose guts spill out must die on the spot.")

	var/mob/living/carbon/human/species/goblin/npc/player = allocate(/mob/living/carbon/human/species/goblin/npc)
	player.mind = allocate(/datum/mind)
	player.mind.current = player
	player.mind.key = "npc-gutting-player"
	player.die_from_gutting()
	TEST_ASSERT_NOTEQUAL(player.stat, DEAD, "Gutting must never kill a player character outright.")
	player.mind.current = null
	player.mind = null
