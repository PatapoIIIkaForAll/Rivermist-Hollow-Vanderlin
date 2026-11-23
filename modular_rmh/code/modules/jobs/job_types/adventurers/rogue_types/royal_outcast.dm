/datum/attribute_holder/sheet/job/advclass/combat/adventurer_rogue/royal_outcast
	raw_attribute_list = list(
		STAT_STRENGTH = 1,
		STAT_PERCEPTION = 1,
		STAT_CONSTITUTION = 1,
		STAT_SPEED = 2,
		STAT_FORTUNE = 1,
		/datum/attribute/skill/combat/axesmaces = 10,
		/datum/attribute/skill/combat/bows = 20,
		/datum/attribute/skill/combat/crossbows = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/knives = 40,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/climbing = 50,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 40,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/misc/riding = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/misc/sewing = 10,
		/datum/attribute/skill/craft/crafting = 10,
		/datum/attribute/skill/labor/mathematics = 30
	)

/datum/job/advclass/combat/adventurer_rogue/royal_outcast
	title = "Royal Outcast"
	tutorial = "Once a member of the royal family, you were cast out by betrayal or misfortune. \
	You now walk in the shadows, your noble training shaping a deadly precision in knife, sword, and crossbow. \
	Will you reclaim your birthright, or craft a new destiny from the ashes?"

	outfit = /datum/outfit/adventurer_rogue/royal_outcast
	category_tags = list(CAT_ADVENTURER_ROGUE)
	give_bank_account = TRUE
	total_positions = 2

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_rogue/royal_outcast


	mind_traits = list(
		TRAIT_KNOW_KEEP_DOORS
	)
	traits = list(
		TRAIT_DODGEEXPERT,
		TRAIT_LIGHT_STEP,
		TRAIT_NOBLE,
	)

/datum/job/advclass/combat/adventurer_rogue/royal_outcast/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	addtimer(CALLBACK(SSfamilytree, TYPE_PROC_REF(/datum/controller/subsystem/familytree, AddRoyal), spawned, FAMILY_PROGENY), 10 SECONDS)

	if(alert("Do you wish to use your rejected royal title?", "", "Yes", "No") == "Yes")
		spawned.honorary = spawned.pronouns == SHE_HER ? "Rejected Princess" : "Rejected Prince"

/datum/outfit/adventurer_rogue/royal_outcast
	name = "Royal Outcast"
	head = /obj/item/clothing/head/crown/circlet
	mask = null
	neck = null
	cloak = /obj/item/clothing/cloak/raincloak
	armor = /obj/item/clothing/armor/leather/advanced
	shirt = null
	wrists = null
	gloves = null
	pants = /obj/item/clothing/pants/trou/leather/advanced
	shoes = /obj/item/clothing/shoes/nobleboot
	backr = /obj/item/storage/backpack/satchel
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	belt = /obj/item/storage/belt/leather/adventurers_subclasses
	beltr = /obj/item/weapon/sword
	beltl = /obj/item/ammo_holder/quiver/bolts
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/reagent_containers/glass/cup/golden = 3,
		/obj/item/reagent_containers/glass/bottle/killersice = 1,
		/obj/item/weapon/knife/dagger/steel/special = 1,
		/obj/item/lockpickring/mundane = 1,
	)

/datum/outfit/adventurer_rogue/royal_outcast/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	if(equipped_human.gender == MALE)
		shirt = /obj/item/clothing/shirt/dress/royal/prince
	if(equipped_human.gender == FEMALE)
		shirt = /obj/item/clothing/shirt/dress/royal/princess
