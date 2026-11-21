/datum/attribute_holder/sheet/job/matron
	raw_attribute_list = list(
		STAT_STRENGTH = -1,
		STAT_INTELLIGENCE = 2,
		STAT_PERCEPTION = 1,
		STAT_SPEED = 2,
		/datum/attribute/skill/misc/sewing = 30,
		/datum/attribute/skill/misc/sneaking = 40,
		/datum/attribute/skill/misc/stealing = 40,
		/datum/attribute/skill/misc/lockpicking = 40,
		/datum/attribute/skill/craft/traps = 20,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/craft/cooking = 40,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/combat/knives = 50,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30
	)

/datum/job/matron
	title = "Matron"
	tutorial = "You are the Matron of the Drunken Dwarf’s hall — the quiet authority behind its lively atmosphere. \
	You watch over the staff, ensure their safety, keep disputes from boiling over, \
	and guard the tavern’s secrets and unspoken rules. You do not serve tables unless you choose to, \
	and few dare test your patience more than once."
	department_flag = TAVERN
	faction = FACTION_TOWN
	total_positions = 1
	spawn_positions = 1
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_MATRON

	allowed_sexes = list(FEMALE)
	allowed_ages = list(AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST

	selection_color = JCOLOR_TAVERN

	outfit = /datum/outfit/matron
	give_bank_account = 35
	can_have_apprentices = TRUE

	spells = list(
		/datum/action/cooldown/spell/undirected/hag_call
	)

	exp_type = list(EXP_TYPE_LIVING, EXP_TYPE_ADVENTURER, EXP_TYPE_THIEF)
	exp_types_granted = list(EXP_TYPE_ADVENTURER, EXP_TYPE_THIEF)
	exp_requirements = list(
		EXP_TYPE_LIVING = 1200,
		EXP_TYPE_ADVENTURER = 300,
		EXP_TYPE_THIEF = 300
	)

	attribute_sheet = /datum/attribute_holder/sheet/job/matron


	traits = list(
		TRAIT_THIEVESGUILD,
		TRAIT_OLDPARTY,
		TRAIT_EARGRAB,
		TRAIT_KITTEN_MOM,
		TRAIT_GOODLOVER,
		TRAIT_EMPATH,
		TRAIT_RECOGNIZE_ADDICTS
	)

	languages = list(/datum/language/thievescant)

/datum/outfit/matron
	name = "Matron"
	head = null
	mask = null
	neck = null
	cloak = /obj/item/clothing/cloak/matron
	armor = null
	shirt = /obj/item/clothing/shirt/leo_robe
	wrists = null
	gloves = null
	pants = null
	shoes = /obj/item/clothing/shoes/boots/leather
	backr = /obj/item/storage/backpack/satchel
	backl = null
	belt = /obj/item/storage/belt/leather/cloth/lady
	beltl = /obj/item/storage/belt/pouch/coins/rich
	beltr = null
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/weapon/knife/dagger/steel = 1,
		/obj/item/key/tavern = 1
	)
