/datum/job/tavern_wench
	title = "Tavern Wench"
	tutorial = "You are a serving girl of the Drunken Dwarf — friendly, playful, and always watching for a good tip. \
	Your role is to keep the tavern lively, guests comfortable, and rumors flowing. \
	You answer to the Matron, who watches over your safety, earnings, and conduct. \
	Whether carrying trays, entertaining patrons, or tending the baths, your charm is as valuable as your labor."
	department_flag = TAVERN
	faction = FACTION_TOWN
	total_positions = 4
	spawn_positions = 4
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_WAITRESS

	allowed_sexes = list(FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST

	selection_color = JCOLOR_TAVERN
	advclass_cat_rolls = list(CAT_WAITRESS = 20)

	give_bank_account = 15

	exp_type = list(EXP_TYPE_LIVING)
	exp_types_granted = list(EXP_TYPE_LIVING)
	exp_requirements = list(
		EXP_TYPE_LIVING = 100
	)

	job_subclasses = list(
		/datum/job/advclass/tavern_wench/waitress,
		/datum/job/advclass/tavern_wench/courtesan,
		/datum/job/advclass/tavern_wench/bath_wench
	)

//SUBCLASSES
/datum/attribute_holder/sheet/job/advclass/tavern_wench/waitress
	raw_attribute_list = list(
		STAT_SPEED = 2,
		STAT_PERCEPTION = 1,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/sneaking = 10,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/stealing = 20,
		/datum/attribute/skill/craft/cooking = 20
	)

/datum/job/advclass/tavern_wench/waitress
	title = "Tavern Waitress"
	tutorial = "You serve food and drink, flirt for tips, and keep the Drunken Dwarf loud and welcoming. \
	You carry trays, remember orders, and learn more than guests realize — especially after a few ales."

	outfit = /datum/outfit/tavern_wench/waitress
	category_tags = list(CAT_WAITRESS)

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/tavern_wench/waitress


	traits = list(
		TRAIT_GOODLOVER,
		TRAIT_BEAUTIFUL,
		TRAIT_EMPATH,
		TRAIT_EXTEROCEPTION
	)

/datum/outfit/tavern_wench/waitress
	name = "Tavern Waitress"
	head = null
	mask = null
	neck = null
	cloak = null
	armor = /obj/item/clothing/armor/corset/colored/black
	shirt = null
	wrists = /obj/item/clothing/wrists/goldbracelet
	gloves = null
	pants = null
	shoes = /obj/item/clothing/shoes/simpleshoes
	backr = /obj/item/storage/backpack/satchel
	backl = null
	belt = /obj/item/storage/belt/leather
	beltl = /obj/item/storage/belt/pouch/cloth/coins/mid
	beltr = /obj/item/key/tavern
	ring = null
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/perfume/random,
		/obj/item/lipstick,
		/obj/item/lipstick/black,
	)

/datum/job/advclass/tavern_wench/waitress/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/dresses = list("Light blue dress", "Waitress dress", "Sexy dress")
	var/dress_choice = browser_input_list(spawned, "CHOOSE YOUR DRESS.", "DRESS UP", dresses)

	switch(dress_choice)
		if("Light blue dress")
			spawned.put_in_hands(new /obj/item/clothing/shirt/dress/skyrim_dress(get_turf(spawned)), TRUE)
		if("Waitress dress")
			spawned.put_in_hands(new /obj/item/clothing/shirt/dress/skyrim_taven(get_turf(spawned)), TRUE)
		if("Sexy dress")
			spawned.put_in_hands(new /obj/item/clothing/shirt/dress/gen/sexy(get_turf(spawned)), TRUE)

// ─────────────────────────────

/datum/attribute_holder/sheet/job/advclass/tavern_wench/courtesan
	raw_attribute_list = list(
		STAT_INTELLIGENCE = 1,
		STAT_PERCEPTION = 2,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/misc/stealing = 30,
		/datum/attribute/skill/misc/medicine = 10
	)

/datum/job/advclass/tavern_wench/courtesan
	title = "Courtesan"
	tutorial = "You specialize in charm, conversation, and companionship. \
	You entertain guests, listen to secrets, and guide patrons toward rooms — always under the Matron’s watchful eye. \
	Discretion is your true craft."

	outfit = /datum/outfit/tavern_wench/courtesan
	category_tags = list(CAT_WAITRESS)

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/tavern_wench/courtesan


	traits = list(
		TRAIT_SEEPRICES,
		TRAIT_GOODLOVER,
		TRAIT_BEAUTIFUL,
		TRAIT_EMPATH
	)

/datum/outfit/tavern_wench/courtesan
	name = "Courtesan"
	head = null
	mask = null
	neck = null
	cloak = null
	armor = null
	shirt = /obj/item/clothing/shirt/dress/courtesan
	wrists = /obj/item/clothing/wrists/goldbracelet
	gloves = null
	pants = null
	shoes = /obj/item/clothing/shoes/heels/color/courtesan
	backr = /obj/item/storage/backpack/satchel
	backl = null
	belt = /obj/item/storage/belt/leather/cloth/lady
	beltl = /obj/item/storage/belt/pouch/cloth/coins/mid
	beltr = /obj/item/key/tavern
	ring = /obj/item/clothing/ring/gold
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/perfume/random,
		/obj/item/lipstick,
		/obj/item/lipstick/black,
	)

// ─────────────────────────────

/datum/attribute_holder/sheet/job/advclass/tavern_wench/bath_wench
	raw_attribute_list = list(
		STAT_PERCEPTION = 1,
		STAT_SPEED = 1,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/craft/cooking = 10
	)

/datum/job/advclass/tavern_wench/bath_wench
	title = "Bath Wench"
	tutorial = "You tend the baths and private washing rooms. \
	You clean, assist guests, and ensure comfort. \
	You hear everything — steam makes people careless."

	outfit = /datum/outfit/tavern_wench/bath_wench
	category_tags = list(CAT_WAITRESS)

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/tavern_wench/bath_wench


	traits = list(
		TRAIT_GOODLOVER,
		TRAIT_BEAUTIFUL,
		TRAIT_EMPATH,
		TRAIT_BATHHOUSE_DANCER,
	)

/datum/outfit/tavern_wench/bath_wench
	name = "Bath Wench"
	head = null
	mask = null
	neck = null
	cloak = null
	armor = null
	shirt = /obj/item/clothing/shirt/nightgown/colored/random
	wrists = null
	gloves = null
	pants = null
	shoes = /obj/item/clothing/shoes/sandals
	backr = null
	backl = null
	belt = /obj/item/storage/belt/leather/rope
	beltl = /obj/item/storage/belt/pouch/cloth/coins/mid
	beltr = /obj/item/key/tavern
	ring = null
	l_hand = /obj/item/soap/bath
	r_hand = /obj/item/perfume/random
