/datum/attribute_holder/sheet/job/advclass/combat/adventurer_sorcerer/desert_sorceress
	raw_attribute_list = list(
		STAT_ENDURANCE = 2,
		STAT_INTELLIGENCE = 1,
		STAT_ENDURANCE = 1,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/combat/whipsflails = 20
	)

/datum/job/advclass/combat/adventurer_sorcerer/desert_sorceress
	title = "Desert Sorceress"
	tutorial = "You call on the Weave to shape fire and ash. Magic is delicate, but deadly in skilled hands."

	give_bank_account = TRUE
	allowed_sexes = list(FEMALE)
	outfit = /datum/outfit/adventurer_sorcerer/desert_sorceress
	category_tags = list(CAT_ADVENTURER_SORCERER)

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_sorcerer/desert_sorceress


	traits = list(
		TRAIT_GOODLOVER,
		TRAIT_NOFIRE,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/touch/prestidigitation,
		/datum/action/cooldown/spell/undirected/conjure_item/light,
		/datum/action/cooldown/spell/status/guidance,
		/datum/action/cooldown/spell/pointed/silence,
		/datum/action/cooldown/spell/essence/toxic_cleanse/class_granted,
		/datum/action/cooldown/spell/aoe/snuff,
		/datum/action/cooldown/spell/essence/spark/class_granted,
		/datum/action/cooldown/spell/essence/fire_cascade/class_granted,
		/datum/action/cooldown/spell/conjure/bonfire,
		/datum/action/cooldown/spell/projectile/fire_flare,
		/datum/action/cooldown/spell/projectile/fireball,
		/datum/action/cooldown/spell/enrapture,
		/datum/action/cooldown/spell/forced_orgasm,
	)

/datum/outfit/adventurer_sorcerer/desert_sorceress
	name = "Desert Sorceress"
	head = /obj/item/clothing/head/desert_sorceress
	mask = null
	neck = null
	cloak = null
	armor = null
	shirt = /obj/item/clothing/shirt/undershirt/desert_sorceress
	wrists = null
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/loincloth/desert_sorceress
	shoes = /obj/item/clothing/shoes/heels
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses
	beltl = /obj/item/weapon/whip
	beltr = /obj/item/storage/magebag/apprentice
	ring = /obj/item/clothing/ring/active/nomag
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/chalk = 1,
		/obj/item/reagent_containers/glass/bottle/stronghealthpot = 1,
		/obj/item/storage/belt/pouch/cloth/coins/mid = 1,
	)

/datum/outfit/adventurer_sorcerer/desert_sorceress/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	equipped_human.mana_pool?.set_intrinsic_recharge(MANA_ALL_LEYLINES)
