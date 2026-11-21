/datum/attribute_holder/sheet/job/advclass/combat/adventurer_rogue/assassin
	raw_attribute_list = list(
		STAT_PERCEPTION = 2,
		STAT_SPEED = 2,
		STAT_STRENGTH = 1,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/misc/sneaking = 50,
		/datum/attribute/skill/misc/climbing = 50,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/craft/traps = 30,
		/datum/attribute/skill/misc/reading = 10
	)

/datum/job/advclass/combat/adventurer_rogue/assassin
	title = "Assassin"
	tutorial = "You prefer to deal sublime punishment to a single foe at a time - not in a duel, mind, because a duel implies chivalry, \
	and you're too busy getting the job done for honour."

	category_tags = list(CAT_ADVENTURER_ROGUE)
	give_bank_account = TRUE
	total_positions = 2
	//antags_can_pick = FALSE //Assassins are antagonists by default, so they can't be chosen if you're already an antagonist.
	//antag_role = /datum/antagonist/assassin

	outfit = /datum/outfit/adventurer_rogue/assassin

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_rogue/assassin

	spells = list(
		/datum/action/cooldown/spell/undirected/rogue_vanish
	)

	traits = list(
		TRAIT_ASSASSIN,
		TRAIT_DODGEEXPERT,
		TRAIT_DEADNOSE,
		TRAIT_STEELHEARTED,
		TRAIT_STRONG_GRABBER,
		TRAIT_VILLAIN,
		TRAIT_BLINDFIGHTING,
		TRAIT_LIGHT_STEP,
	)

/datum/outfit/adventurer_rogue/assassin
	name = "Assassin"
	head = null
	mask = null
	neck = null
	cloak = null
	armor = null
	shirt = /obj/item/clothing/shirt/undershirt/colored/black
	wrists = null
	gloves = /obj/item/clothing/gloves/leather/black
	pants = /obj/item/clothing/pants/trou/leather
	shoes = /obj/item/clothing/shoes/boots
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/assassin
	beltr = /obj/item/weapon/knife/dagger/steel/special
	beltl = /obj/item/storage/belt/pouch/cloth/coins/poor
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/lockpick = 1,
		/obj/item/reagent_containers/glass/bottle/poison = 1,
		/obj/item/flint = 1,
	)

/datum/job/advclass/combat/adventurer_rogue/assassin/after_spawn(mob/living/carbon/human/H, client/C)
	. = ..()

	var/list/styles = list(
		"Knife Specialist",
		"Bow Killer",
		"Faceless"
	)

	var/choice = input(H, "Choose your training focus", "Assassin Path") in styles

	switch(choice)
		if("Knife Specialist")
			H.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
		if("Bow Killer")
			H.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)
			H.adjust_skillrank(/datum/skill/combat/crossbows, 1, TRUE)
		if("Faceless")
			ADD_TRAIT(H, TRAIT_FACELESS, TRAIT_GENERIC)
