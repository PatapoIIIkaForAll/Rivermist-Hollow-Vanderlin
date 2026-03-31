/datum/job/seelie
	title = "Seelie"
	tutorial = "You are a tiny fae wanderer welcome in town so long as your tricks stay kind. \
	Your wings carry you where others cannot go, and your small store of magic is best spent helping, meddling, and surviving. \
	Because seelies arrive as itinerant visitors, this role is intended as a latejoin option."
	department_flag = TOWN
	faction = FACTION_TOWN
	total_positions = 1
	spawn_positions = 1
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_SEELIE
	bypass_lastclass = TRUE
	magic_user = TRUE

	allowed_races = list(SPEC_ID_SEELIE)
	allowed_ages = ALL_AGES_LIST

	selection_color = JCOLOR_TOWN
	give_bank_account = FALSE
	exp_types_granted = list(EXP_TYPE_MAGICK)

	jobstats = list(
		STATKEY_SPD = 1,
		STATKEY_PER = 1,
	)

	skills = list(
		/datum/skill/misc/swimming = 1,
		/datum/skill/misc/athletics = 1,
		/datum/skill/misc/climbing = 2,
		/datum/skill/magic/arcane = 3,
		/datum/skill/misc/medicine = 1,
		/datum/skill/misc/reading = 3,
		/datum/skill/craft/crafting = 1,
		/datum/skill/misc/sneaking = 2,
	)

	spells = list(
		/datum/action/cooldown/spell/status/seelie_dust,
		/datum/action/cooldown/spell/seelie_call_beast,
		/datum/action/cooldown/spell/seelie_strip,
		/datum/action/cooldown/spell/seelie_drain,
		/datum/action/cooldown/spell/seelie_replenish,
		/datum/action/cooldown/spell/seelie_kiss,
		/datum/action/cooldown/spell/projectile/water_bolt,
		/datum/action/cooldown/spell/aoe/repulse,
	)

	outfit = /datum/outfit/seelie

/datum/outfit/seelie
	name = "Seelie"
	head = null
	mask = null
	neck = null
	cloak = /obj/item/clothing/cloak/half/colored/random
	armor = null
	shirt = /obj/item/clothing/shirt/shortshirt/colored/random
	wrists = null
	gloves = null
	pants = /obj/item/clothing/pants/trou/shadowpants
	shoes = /obj/item/clothing/shoes/sandals
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather
	beltl = /obj/item/weapon/knife/dagger/steel
	beltr = null
	ring = null
	l_hand = null
	r_hand = null
