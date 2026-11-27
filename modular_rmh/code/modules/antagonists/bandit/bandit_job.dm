GLOBAL_LIST_EMPTY(bandit_player_insertions)

/datum/job/bandit
	title = ROLE_BANDIT
	tutorial = "You belong to a hidden free company operating beyond Rivermist Hollow. Scout the town, trespass, steal valuables and access, and fulfill the contracts shared by every bandit. This is a low-level conflict role: evade, bargain, and escape; never kill for company business."
	department_flag = VILLAINS
	faction = FACTION_NEUTRAL
	total_positions = 3
	spawn_positions = 3
	antag_job = TRUE
	can_random = FALSE
	selection_color = JCOLOR_VILLAINS
	job_flags = (JOB_EQUIP_RANK | JOB_SHOW_IN_CREDITS | JOB_NEW_PLAYER_JOINABLE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST
	outfit = /datum/outfit/antagonist/bandit
	antag_role = /datum/antagonist/bandit
	display_order = JDO_BANDIT
	rune_linked = RUNE_LINK_ANTAG
	advclass_cat_rolls = list(CAT_BANDIT = 3)
	job_subclasses = list(
		/datum/job/advclass/bandit/burglar,
		/datum/job/advclass/bandit/fence,
		/datum/job/advclass/bandit/highwayman,
	)

/datum/job/bandit/proc/can_take_bandit_job(player_ckey)
	if(!player_ckey || is_total_antag_banned(player_ckey) || is_antag_banned(player_ckey, ROLE_BANDIT))
		return FALSE
	return TRUE

/datum/job/bandit/proc/get_camp_spawn_point()
	if(!get_player_bandit_camp())
		return null
	var/list/valid_spawns = list()
	for(var/obj/effect/landmark/start/bandit_player/camp_spawn in GLOB.jobspawn_overrides[title])
		if(!istype(get_area(camp_spawn), /area/pocket_dimension/bandit_camp))
			continue
		valid_spawns += camp_spawn
	if(!length(valid_spawns))
		return null
	return pick(valid_spawns)

/datum/job/bandit/proc/has_required_landmarks()
	return get_camp_spawn_point() && length(GLOB.bandit_player_insertions)

/datum/job/bandit/special_job_check(mob/dead/new_player/player)
	if(!player?.client || !has_required_landmarks())
		return FALSE
	return can_take_bandit_job(player.ckey)

/datum/job/bandit/special_check_latejoin(client/player_client)
	if(!has_required_landmarks())
		return FALSE
	return can_take_bandit_job(player_client?.ckey)

/datum/job/bandit/get_roundstart_spawn_point()
	if(!has_required_landmarks())
		log_world("Refusing to spawn [title]: the map is missing a required player Bandit landmark.")
		return null
	var/obj/effect/landmark/start/bandit_player/camp_spawn = get_camp_spawn_point()
	camp_spawn.used = TRUE
	return camp_spawn

/datum/job/bandit/get_latejoin_spawn_point()
	if(!has_required_landmarks())
		log_world("Refusing to latejoin [title]: the map is missing a required player Bandit landmark.")
		return null
	return get_camp_spawn_point()

/datum/outfit/antagonist/bandit
	name = "Bandit"
	head = null
	mask = null
	neck = null
	cloak = null
	armor = null
	shirt = /obj/item/clothing/shirt/undershirt/colored/random
	wrists = null
	gloves = null
	pants = /obj/item/clothing/pants/trou
	shoes = /obj/item/clothing/shoes/simpleshoes
	backr = /obj/item/storage/backpack/satchel/cloth
	backl = null
	belt = /obj/item/storage/belt/leather
	beltl = /obj/item/storage/belt/pouch/cloth/coins/poor
	beltr = null
	ring = null
	l_hand = null
	r_hand = null

/datum/job/advclass/bandit
	abstract_type = /datum/job/advclass/bandit
	category_tags = list(CAT_BANDIT)
	languages = list(/datum/language/thievescant)
	exp_types_granted = list(EXP_TYPE_ANTAG)

/datum/attribute_holder/sheet/job/advclass/bandit/burglar
	raw_attribute_list = list(
		STAT_STRENGTH = -2,
		STAT_PERCEPTION = 2,
		STAT_SPEED = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/lockpicking = 50,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/sneaking = 50,
		/datum/attribute/skill/misc/stealing = 50,
		/datum/attribute/skill/craft/traps = 20,
	)

/datum/job/advclass/bandit/burglar
	title = "Bandit Burglar"
	tutorial = "You are the company's quiet hand. Case occupied districts, defeat locks, take portable wealth, and leave before a confrontation becomes a fight."
	outfit = /datum/outfit/bandit/burglar
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/bandit/burglar
	traits = list(TRAIT_DODGEEXPERT, TRAIT_LIGHT_STEP)

/datum/outfit/bandit/burglar
	name = "Bandit Burglar"
	shirt = /obj/item/clothing/shirt/undershirt/colored/black
	gloves = /obj/item/clothing/gloves/fingerless
	pants = /obj/item/clothing/pants/trou/leather
	shoes = /obj/item/clothing/shoes/boots
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses
	beltl = /obj/item/storage/belt/pouch/cloth/coins/poor
	beltr = /obj/item/weapon/mace/cudgel
	backpack_contents = list(
		/obj/item/book/bandit_casing_ledger = 1,
		/obj/item/key/bandit = 1,
		/obj/item/lockpick = 2,
		/obj/item/weapon/knife/dagger/steel = 1,
	)

/datum/attribute_holder/sheet/job/advclass/bandit/fence
	raw_attribute_list = list(
		STAT_INTELLIGENCE = 2,
		STAT_PERCEPTION = 2,
		STAT_SPEED = -1,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/misc/athletics = 10,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/craft/crafting = 30,
		/datum/attribute/skill/misc/sewing = 20,
	)

/datum/job/advclass/bandit/fence
	title = "Bandit Fence"
	tutorial = "You know what is valuable, what can be moved, and who might buy it. Direct the company's tribute, assess stolen goods, and keep your companions supplied."
	outfit = /datum/outfit/bandit/fence
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/bandit/fence
	traits = list(TRAIT_LIGHT_STEP)

/datum/outfit/bandit/fence
	name = "Bandit Fence"
	cloak = /obj/item/clothing/cloak/apron/waist
	armor = /obj/item/clothing/armor/leather/vest
	shirt = /obj/item/clothing/shirt/undershirt/colored/random
	pants = /obj/item/clothing/pants/trou/leather
	shoes = /obj/item/clothing/shoes/boots
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather
	beltl = /obj/item/storage/belt/pouch/cloth/coins/poor
	beltr = /obj/item/weapon/knife/hunting
	backpack_contents = list(
		/obj/item/book/bandit_casing_ledger = 1,
		/obj/item/key/bandit = 1,
		/obj/item/lockpick = 1,
	)

/datum/attribute_holder/sheet/job/advclass/bandit/highwayman
	raw_attribute_list = list(
		STAT_STRENGTH = 1,
		STAT_CONSTITUTION = 1,
		STAT_ENDURANCE = 2,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/lockpicking = 20,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 20,
	)

/datum/job/advclass/bandit/highwayman
	title = "Bandit Highwayman"
	tutorial = "You are the company's presence on roads and escape routes. Intimidate, wrestle, restrain, and disengage—but never turn a robbery into a killing."
	outfit = /datum/outfit/bandit/highwayman
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/bandit/highwayman
	traits = list(TRAIT_LIGHT_STEP)

/datum/outfit/bandit/highwayman
	name = "Bandit Highwayman"
	armor = /obj/item/clothing/armor/leather/vest
	shirt = /obj/item/clothing/armor/gambeson
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/trou/leather
	shoes = /obj/item/clothing/shoes/boots
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/rope
	beltl = /obj/item/storage/belt/pouch/cloth/coins/poor
	beltr = /obj/item/weapon/mace/cudgel
	backpack_contents = list(
		/obj/item/book/bandit_casing_ledger = 1,
		/obj/item/key/bandit = 1,
		/obj/item/lockpick = 1,
		/obj/item/rope = 1,
	)

//iconoclast bandit paladin
/datum/job/advclass/bandit/iconoclast
	title = "Bandit Iconoclast"
	tutorial = "You are the group’s moral compass. Do not let them forget who their patron is, and guide your group along the path of thievery."
	outfit = /datum/outfit/bandit/iconoclast
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/bandit/iconoclast
	traits = list(TRAIT_HEAVYARMOR,
					TRAIT_STEELHEARTED,
					TRAIT_HOLY,
					TRAIT_IGNORESLOWDOWN,
					TRAIT_NOPAINSTUN,
					TRAIT_HOLY,
					TRAIT_STRONG_GRABBER,
					TRAIT_COMBAT_AWARE,
					TRAIT_MATTHIOS_EYES,
					TRAIT_SHOCKIMMUNE,
	)

/datum/outfit/bandit/iconoclast
	name = "Bandit Iconoclast"
	head = /obj/item/clothing/head/helmet/heavy/matthios
	mask = /obj/item/clothing/face/facemask/steel
	neck = /obj/item/clothing/neck/highcollier
	cloak = /obj/item/clothing/cloak/matthios
	armor = /obj/item/clothing/armor/plate/full/matthios
	shirt = /obj/item/clothing/armor/chainmail
	wrists = /obj/item/clothing/wrists/bracers
	gloves = /obj/item/clothing/gloves/plate/matthios
	pants = /obj/item/clothing/pants/platelegs/matthios
	shoes = /obj/item/clothing/shoes/boots/armor/matthios
	backr = /obj/item/storage/backpack/satchel
	backl = /obj/item/weapon/sword/long/greatsword/zizo
	belt = /obj/item/storage/belt/leather/steel/adventurers_subclasses
	beltl = /obj/item/storage/belt/pouch/cloth/coins/mid
	r_hand = /obj/item/weapon/flail/peasantwarflail/matthios

/datum/attribute_holder/sheet/job/advclass/bandit/iconoclast
	raw_attribute_list = list(
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/combat/whipsflails = 45,
		/datum/attribute/skill/combat/wrestling = 50,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/mathematics = 30
	)
		spells = list(
		/datum/action/cooldown/spell/undirected/touch/orison,
		/datum/action/cooldown/spell/status/guidance,
		/datum/action/cooldown/spell/pointed/silence,
		/datum/action/cooldown/spell/healing,
		/datum/action/cooldown/spell/diagnose/holy,
		/datum/action/cooldown/spell/essence/neutralize/class_granted,
	)

/datum/outfit/bandit/bandit/iconoclast/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	equipped_human.mana_pool?.set_intrinsic_recharge(MANA_ALL_LEYLINES)
