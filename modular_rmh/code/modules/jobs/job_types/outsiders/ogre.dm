/datum/job/ogre
	title = "Ogre"
	tutorial = "You are one of the great hulking wanderers from the rough lands beyond civilization. \
	Some folk fear you, some hire you, and most have the good sense not to stand in your way. \
	Pick the kind of ogre you are and carve out a place in Rivermist Hollow."
	department_flag = OUTSIDERS
	faction = FACTION_NEUTRAL
	total_positions = 0
	spawn_positions = 0
	job_flags = (JOB_EQUIP_RANK) //(JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_OGRE
	bypass_lastclass = TRUE

	allowed_races = list(SPEC_ID_OGRE)
	allowed_ages = ALL_AGES_LIST

	selection_color = JCOLOR_OUTSIDERS
	advclass_cat_rolls = list(CAT_OGRE = 20)
	give_bank_account = TRUE
	exp_types_granted = list(EXP_TYPE_ADVENTURER, EXP_TYPE_COMBAT)

	job_subclasses = list(
		/datum/job/advclass/ogre/dumdum,
		/datum/job/advclass/ogre/avatar,
		/datum/job/advclass/ogre/mercenary,
		/datum/job/advclass/ogre/warlord,
		/datum/job/advclass/ogre/cook,
	)

/datum/job/advclass/ogre
	abstract_type = /datum/job/advclass/ogre
	allowed_races = list(SPEC_ID_OGRE)
	category_tags = list(CAT_OGRE)
	give_bank_account = TRUE
	exp_types_granted = list(EXP_TYPE_ADVENTURER, EXP_TYPE_COMBAT)

/datum/job/advclass/ogre/proc/pick_ogre_weapon(mob/living/carbon/human/spawned, client/player_client, list/selectableweapon, message = "Choose your weapon.", title = "OGRE")
	if(!spawned || !length(selectableweapon))
		return null

	var/selector = player_client ? player_client : spawned
	return spawned.select_equippable(selector, selectableweapon, message = message, title = title)

/datum/job/advclass/ogre/dumdum
	title = "Dum Dum"
	tutorial = "You left your old haunts because food was scarce, tempers were shorter still, and the road at least offered fresh trouble. \
	You are big, hungry, and not especially subtle, but that has never stopped an ogre before."
	outfit = /datum/outfit/ogre/dumdum

	jobstats = list(
		STATKEY_STR = 2,
		STATKEY_CON = 1,
	)

	skills = list(
		/datum/skill/combat/wrestling = 2,
		/datum/skill/combat/unarmed = 2,
		/datum/skill/combat/axesmaces = 2,
		/datum/skill/combat/swords = 1,
		/datum/skill/misc/athletics = 2,
		/datum/skill/misc/climbing = 1,
	)

/datum/job/advclass/ogre/dumdum/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/static/list/selectableweapon = list(
		"Iron Sword" = /obj/item/weapon/sword/iron,
		"Iron Axe" = /obj/item/weapon/axe/iron,
		"Bludgeon" = /obj/item/weapon/mace/bludgeon,
	)

	var/choice = pick_ogre_weapon(spawned, player_client, selectableweapon, message = "Choose your starting weapon.", title = "DUM DUM")
	if(!choice)
		return

	switch(choice)
		if("Iron Sword")
			spawned.clamped_adjust_skillrank(/datum/skill/combat/swords, 3, 3, TRUE)
		if("Iron Axe", "Bludgeon")
			spawned.clamped_adjust_skillrank(/datum/skill/combat/axesmaces, 3, 3, TRUE)

/datum/job/advclass/ogre/avatar
	title = "War Avatar"
	tutorial = "You are a towering chosen warrior, built to break lines and crush resistance. \
	When steel is drawn, you are meant to be the loudest, heaviest thing on the field."
	outfit = /datum/outfit/ogre/avatar

	jobstats = list(
		STATKEY_STR = 4,
		STATKEY_CON = 5,
		STATKEY_END = 4,
		STATKEY_INT = -2,
	)

	skills = list(
		/datum/skill/combat/axesmaces = 4,
		/datum/skill/combat/swords = 3,
		/datum/skill/combat/knives = 4,
		/datum/skill/combat/wrestling = 4,
		/datum/skill/combat/unarmed = 3,
		/datum/skill/misc/athletics = 4,
		/datum/skill/misc/climbing = 1,
	)

	traits = list(
		TRAIT_NOPAINSTUN,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_STRONGBITE,
		TRAIT_MEDIUMARMOR,
		TRAIT_HEAVYARMOR,
	)

/datum/job/advclass/ogre/avatar/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/static/list/selectableweapon = list(
		"Warhammer" = /obj/item/weapon/mace/goden/steel/warhammer,
		"Great Axe" = /obj/item/weapon/greataxe/steel,
		"Flamberge" = /obj/item/weapon/sword/long/greatsword/flamberge,
	)

	var/choice = pick_ogre_weapon(spawned, player_client, selectableweapon, message = "Choose your war-gear.", title = "WAR AVATAR")
	if(!choice)
		return

	switch(choice)
		if("Flamberge")
			spawned.clamped_adjust_skillrank(/datum/skill/combat/swords, 5, 5, TRUE)
		if("Warhammer", "Great Axe")
			spawned.clamped_adjust_skillrank(/datum/skill/combat/axesmaces, 5, 5, TRUE)

/datum/job/advclass/ogre/mercenary
	title = "Ogre Mercenary"
	tutorial = "You sell your strength where coin, meat, and drink are plentiful. \
	You have seen enough battle to know how to survive it, and enough hardship to know why payment comes first."
	outfit = /datum/outfit/ogre/mercenary

	jobstats = list(
		STATKEY_STR = 4,
		STATKEY_CON = 3,
		STATKEY_END = 3,
		STATKEY_INT = -2,
	)

	skills = list(
		/datum/skill/combat/axesmaces = 4,
		/datum/skill/combat/swords = 3,
		/datum/skill/combat/knives = 2,
		/datum/skill/combat/wrestling = 3,
		/datum/skill/combat/unarmed = 3,
		/datum/skill/misc/athletics = 4,
		/datum/skill/misc/climbing = 1,
	)

	traits = list(
		TRAIT_NOPAINSTUN,
		TRAIT_STRONGBITE,
		TRAIT_MEDIUMARMOR,
		TRAIT_HEAVYARMOR,
	)

/datum/job/advclass/ogre/mercenary/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/static/list/selectableweapon = list(
		"Grand Mace" = /obj/item/weapon/mace/goden/steel,
		"Great Axe" = /obj/item/weapon/greataxe/steel,
		"Flamberge" = /obj/item/weapon/sword/long/greatsword/flamberge,
	)

	var/choice = pick_ogre_weapon(spawned, player_client, selectableweapon, message = "Choose your contract weapon.", title = "OGRE MERCENARY")
	if(!choice)
		return

	switch(choice)
		if("Flamberge")
			spawned.clamped_adjust_skillrank(/datum/skill/combat/swords, 5, 5, TRUE)
		if("Grand Mace", "Great Axe")
			spawned.clamped_adjust_skillrank(/datum/skill/combat/axesmaces, 5, 5, TRUE)

/datum/job/advclass/ogre/warlord
	title = "Ogre Warlord"
	tutorial = "You are used to being obeyed. \
	Whether by clan-right, brute reputation, or sheer force of personality, you are the sort of ogre others follow when the shouting starts."
	outfit = /datum/outfit/ogre/warlord

	jobstats = list(
		STATKEY_STR = 3,
		STATKEY_CON = 2,
		STATKEY_END = 2,
	)

	skills = list(
		/datum/skill/combat/axesmaces = 4,
		/datum/skill/combat/swords = 3,
		/datum/skill/combat/knives = 2,
		/datum/skill/combat/wrestling = 3,
		/datum/skill/combat/unarmed = 3,
		/datum/skill/misc/athletics = 4,
		/datum/skill/misc/climbing = 1,
		/datum/skill/misc/reading = 1,
	)

	traits = list(
		TRAIT_NOPAINSTUN,
		TRAIT_STRONGBITE,
		TRAIT_MEDIUMARMOR,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
	)

/datum/job/advclass/ogre/warlord/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	spawned.verbs |= /mob/proc/haltyell

	var/static/list/selectableweapon = list(
		"Grand Mace" = /obj/item/weapon/mace/goden/steel,
		"Great Axe" = /obj/item/weapon/greataxe/steel,
		"Flamberge" = /obj/item/weapon/sword/long/greatsword/flamberge,
	)

	var/choice = pick_ogre_weapon(spawned, player_client, selectableweapon, message = "Choose the weapon of command.", title = "OGRE WARLORD")
	if(!choice)
		return

	switch(choice)
		if("Flamberge")
			spawned.clamped_adjust_skillrank(/datum/skill/combat/swords, 5, 5, TRUE)
		if("Grand Mace", "Great Axe")
			spawned.clamped_adjust_skillrank(/datum/skill/combat/axesmaces, 5, 5, TRUE)

/datum/job/advclass/ogre/cook
	title = "Cook-Cook"
	tutorial = "You feed the hungry, butcher the slain, and know exactly how much heat and salt it takes to make almost anything edible. \
	An ogre camp without a cook does not stay a camp for long."
	outfit = /datum/outfit/ogre/cook

	jobstats = list(
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_END = 1,
		STATKEY_SPD = -2,
	)

	skills = list(
		/datum/skill/misc/athletics = 1,
		/datum/skill/combat/knives = 3,
		/datum/skill/combat/axesmaces = 2,
		/datum/skill/combat/wrestling = 4,
		/datum/skill/combat/unarmed = 2,
		/datum/skill/misc/reading = 1,
		/datum/skill/craft/cooking = 5,
		/datum/skill/craft/tanning = 1,
		/datum/skill/craft/crafting = 2,
		/datum/skill/labor/butchering = 5,
	)

	traits = list(
		TRAIT_MEDIUMARMOR,
	)

/datum/outfit/ogre_base
	name = "Ogre"
	head = null
	mask = null
	neck = /obj/item/clothing/neck/gorget
	cloak = /obj/item/clothing/cloak/apron
	armor = /obj/item/clothing/armor/gambeson
	shirt = /obj/item/clothing/shirt/shortshirt/colored/random
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/trou
	shoes = /obj/item/clothing/shoes/boots
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather
	beltl = null
	beltr = null
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
	)

/datum/outfit/ogre_heavy
	name = "Heavy Ogre"
	head = /obj/item/clothing/head/helmet/heavy/necked
	mask = null
	neck = /obj/item/clothing/neck/gorget
	cloak = null
	armor = /obj/item/clothing/armor/plate
	shirt = /obj/item/clothing/armor/chainmail/hauberk/iron
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = /obj/item/clothing/gloves/plate
	pants = /obj/item/clothing/pants/chainlegs/iron
	shoes = /obj/item/clothing/shoes/boots/armor
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather
	beltl = null
	beltr = null
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rope/chain = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
	)

/datum/outfit/ogre/dumdum
	parent_type = /datum/outfit/ogre_base
	name = "Dum Dum"

/datum/outfit/ogre/avatar
	parent_type = /datum/outfit/ogre_heavy
	name = "War Avatar"
	head = /obj/item/clothing/head/helmet/visored/knight
	pants = /obj/item/clothing/pants/platelegs

/datum/outfit/ogre/mercenary
	parent_type = /datum/outfit/ogre_heavy
	name = "Ogre Mercenary"

/datum/outfit/ogre/warlord
	parent_type = /datum/outfit/ogre_heavy
	name = "Ogre Warlord"
	head = /obj/item/clothing/head/helmet/visored/knight
	cloak = /obj/item/clothing/cloak/apron

	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/rope/chain = 1,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
		/obj/item/signal_horn = 1,
	)

/datum/outfit/ogre/cook
	parent_type = /datum/outfit/ogre_base
	name = "Cook-Cook"
	head = /obj/item/clothing/head/cookhat
	cloak = /obj/item/clothing/cloak/apron
	armor = null
	wrists = null
	beltl = /obj/item/weapon/knife/cleaver
	beltr = /obj/item/cooking/pan

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/meat/steak = 2,
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
	)
