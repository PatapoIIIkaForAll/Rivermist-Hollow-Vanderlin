/datum/job/swamp_witch
	title = "Swamp Witch"
	tutorial = "A reclusive spellcaster living in the misty swamps near the Dark Forest. \
	She forages rare herbs, brews potent potions, and tends to her cauldron by day, \
	offering aid — or a cup of tea — to passing adventurers."
	department_flag = OUTSIDERS
	faction = FACTION_NEUTRAL
	total_positions = 1
	spawn_positions = 1
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_SWAMP_WITCH

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST
	allowed_sexes = list(FEMALE)

	selection_color = JCOLOR_OUTSIDERS
	advclass_cat_rolls = list(CAT_SWAMP_WITCH = 20)
	give_bank_account = 30

	job_subclasses = list(
		/datum/job/advclass/swamp_witch/alchemist,
		/datum/job/advclass/swamp_witch/cinder,
		/datum/job/advclass/swamp_witch/hex,
		/datum/job/advclass/swamp_witch/wild,
	)

	exp_types_granted = list(EXP_TYPE_MAGICK)


/datum/job/swamp_witch/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/holder = spawned.patron?.devotion_holder
	if(holder)
		var/datum/devotion/devotion = new holder()
		devotion.make_cleric()
		devotion.grant_to(spawned)

//SUBCLASSES
/datum/attribute_holder/sheet/job/advclass/swamp_witch/alchemist
	raw_attribute_list = list(
		STAT_INTELLIGENCE = 3,
		STAT_PERCEPTION = 1,
		STAT_SPEED = -1,
		/datum/attribute/skill/craft/alchemy = 40,
		/datum/attribute/skill/magic/arcane = 20,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/labor/farming = 30,
		/datum/attribute/skill/misc/reading = 30
	)

/datum/job/advclass/swamp_witch/alchemist
	title = "Alchemist Witch"
	tutorial = "You practice witchcraft through brews, tinctures, and mutagenic concoctions. \
	Your power simmers in cauldrons rather than spellbooks."

	outfit = /datum/outfit/swamp_witch/alchemist
	category_tags = list(CAT_SWAMP_WITCH)

	magic_user = TRUE
	spell_points = 20
	attunements_max = 5
	attunements_min = 1

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/swamp_witch/alchemist


	traits = list(
		TRAIT_GOODLOVER,
		TRAIT_FORAGER,
		TRAIT_LEGENDARY_ALCHEMIST,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/shapeshift/crow,
		/datum/action/cooldown/spell/undirected/touch/prestidigitation,
		/datum/action/cooldown/spell/undirected/conjure_item/light,
		/datum/action/cooldown/spell/healing,
		/datum/action/cooldown/spell/healing/greater,
		/datum/action/cooldown/spell/essence/toxic_cleanse/class_granted,
		/datum/action/cooldown/spell/essence/purify_water/class_granted,
		/datum/action/cooldown/spell/essence/neutralize/class_granted,
		/datum/action/cooldown/spell/status/guidance,
		/datum/action/cooldown/spell/status/haste,
		/datum/action/cooldown/spell/undirected/conjure_item/poison_bomb,
		/datum/action/cooldown/spell/undirected/conjure_item/aphrodisiac_bomb,
		/datum/action/cooldown/spell/undirected/conjure_item/destroy_clothes_bomb,
		/datum/action/cooldown/spell/undirected/conjure_item/sleeping_bomb,
		/datum/action/cooldown/spell/projectile/acid_splash,
	)

/datum/outfit/swamp_witch/alchemist
	name = "Alchemist Witch"
	head = /obj/item/clothing/head/wizhat/witch
	mask = null
	neck = null
	cloak = /obj/item/clothing/cloak/cape/colored/wizard
	armor = null
	shirt = /obj/item/clothing/shirt/dress/gen/sexy/colored/black
	wrists = null
	gloves = /obj/item/clothing/gloves/leather/thaumgloves
	pants = null
	shoes = /obj/item/clothing/shoes/heels
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather
	beltl = null
	beltr = null
	ring = /obj/item/clothing/ring/active/nomag
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/scrying = 1,
		/obj/item/chalk = 1,
		/obj/item/reagent_containers/glass/bottle/killersice = 1,
		/obj/item/book/granter/spellbook/adept = 1,
		/obj/item/weapon/knife/dagger/silver/arcyne = 1,
		/obj/item/storage/belt/pouch/cloth/coins/mid,
		/obj/item/reagent_containers/glass/bottle/beer/emberwine,
		/obj/item/key/outsider/witch = 1,
	)

/datum/outfit/swamp_witch/alchemist/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	equipped_human.mana_pool?.set_intrinsic_recharge(MANA_ALL_LEYLINES)

// ─────────────────────────────

/datum/attribute_holder/sheet/job/advclass/swamp_witch/cinder
	raw_attribute_list = list(
		STAT_ENDURANCE = 2,
		STAT_INTELLIGENCE = 1,
		STAT_ENDURANCE = 1,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/combat/knives = 10,
		/datum/attribute/skill/combat/whipsflails = 20
	)

/datum/job/advclass/swamp_witch/cinder
	title = "Cinder Witch"
	tutorial = "You channel destructive rites of flame and ash. \
	Fire listens to you — sometimes eagerly, sometimes hungrily."

	outfit = /datum/outfit/swamp_witch/cinder
	category_tags = list(CAT_SWAMP_WITCH)

	magic_user = TRUE
	spell_points = 30
	attunements_max = 10
	attunements_min = 5

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/swamp_witch/cinder


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
	)

/datum/outfit/swamp_witch/cinder
	name = "Cinder Witch"
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
	belt = /obj/item/storage/belt/leather
	beltl = /obj/item/weapon/whip
	beltr = null
	ring = /obj/item/clothing/ring/active/nomag
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/scrying = 1,
		/obj/item/chalk = 1,
		/obj/item/reagent_containers/glass/bottle/killersice = 1,
		/obj/item/book/granter/spellbook/adept = 1,
		/obj/item/weapon/knife/dagger/silver/arcyne = 1,
		/obj/item/storage/belt/pouch/cloth/coins/mid,
		/obj/item/key/outsider/witch = 1,
	)

/datum/outfit/swamp_witch/cinder/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	equipped_human.mana_pool?.set_intrinsic_recharge(MANA_ALL_LEYLINES)

// ─────────────────────────────

/datum/attribute_holder/sheet/job/advclass/swamp_witch/hex
	raw_attribute_list = list(
		STAT_ENDURANCE = 3,
		STAT_INTELLIGENCE = 1,
		STAT_STRENGTH = -1,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/combat/knives = 10
	)

/datum/job/advclass/swamp_witch/hex
	title = "Hex Witch"
	tutorial = "You weave curses, misfortune, and binding words. \
	Your magic clings, lingers, and festers long after the spell is spoken."

	outfit = /datum/outfit/swamp_witch/hex
	category_tags = list(CAT_SWAMP_WITCH)

	magic_user = TRUE
	spell_points = 30
	attunements_max = 10
	attunements_min = 5

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/swamp_witch/hex


	traits = list(
		TRAIT_GOODLOVER,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/shapeshift/crow,
		/datum/action/cooldown/spell/undirected/touch/prestidigitation,
		/datum/action/cooldown/spell/undirected/conjure_item/light,
		/datum/action/cooldown/spell/status/guidance,
		/datum/action/cooldown/spell/pointed/silence,
		/datum/action/cooldown/spell/essence/neutralize/class_granted,
		/datum/action/cooldown/spell/find_flaw,
		/datum/action/cooldown/spell/cone/staggered/eldritch_blast,
		/datum/action/cooldown/spell/status/infestation,
		/datum/action/cooldown/spell/mimicry,
		/datum/action/cooldown/spell/aoe/on_turf/ensnare,
		/datum/action/cooldown/spell/conjure/web,
		/datum/action/cooldown/spell/enchantment/green_flame,
		/datum/action/cooldown/spell/enrapture,
		/datum/action/cooldown/spell/forced_orgasm,
	)

/datum/outfit/swamp_witch/hex
	name = "Hex Witch"
	head = /obj/item/clothing/head/wizhat/witch
	mask = null
	neck = null
	cloak = null
	armor = null
	shirt = /obj/item/clothing/shirt/undershirt/witch_cloth
	wrists = /obj/item/clothing/wrists/goldbracelet
	gloves = /obj/item/clothing/gloves/leather
	pants = null
	shoes = /obj/item/clothing/shoes/anklets
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/cloth/lady
	beltl = null
	beltr = null
	ring = /obj/item/clothing/ring/active/nomag
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/scrying = 1,
		/obj/item/chalk = 1,
		/obj/item/reagent_containers/glass/bottle/killersice = 1,
		/obj/item/book/granter/spellbook/adept = 1,
		/obj/item/weapon/knife/dagger/silver/arcyne = 1,
		/obj/item/storage/belt/pouch/cloth/coins/mid,
		/obj/item/key/outsider/witch = 1,
	)

/datum/outfit/swamp_witch/hex/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	equipped_human.mana_pool?.set_intrinsic_recharge(MANA_ALL_LEYLINES)

// ─────────────────────────────

/datum/attribute_holder/sheet/job/advclass/swamp_witch/wild
	raw_attribute_list = list(
		STAT_ENDURANCE = 2,
		STAT_INTELLIGENCE = 2,
		STAT_PERCEPTION = 1,
		/datum/attribute/skill/magic/arcane = 30,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/athletics = 10
	)

/datum/job/advclass/swamp_witch/wild
	title = "Wild Magic Witch"
	tutorial = "You harness the raw, untamed currents of magic. \
	Spells you cast can have unpredictable side effects, ranging from minor quirks to chaotic surges. \
	Caution and improvisation are your allies — and your enemies."

	outfit = /datum/outfit/swamp_witch/wild
	category_tags = list(CAT_SWAMP_WITCH)

	magic_user = TRUE
	spell_points = 25
	attunements_max = 10
	attunements_min = 5

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/swamp_witch/wild


	traits = list(
		TRAIT_GOODLOVER,
		TRAIT_WILDMAGIC,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/shapeshift/crow,
		/datum/action/cooldown/spell/undirected/touch/prestidigitation,
		/datum/action/cooldown/spell/undirected/conjure_item/light,
		/datum/action/cooldown/spell/status/guidance,
		/datum/action/cooldown/spell/pointed/silence,
		/datum/action/cooldown/spell/essence/neutralize/class_granted,
		/datum/action/cooldown/spell/mimicry,
	)

/datum/outfit/swamp_witch/wild
	name = "Wild Magic Witch"
	head = /obj/item/clothing/head/wizhat/witch
	mask = null
	neck = null
	cloak = /obj/item/clothing/cloak/cape/colored/wizard
	armor = /obj/item/clothing/armor/corset
	shirt = /obj/item/clothing/shirt/undershirt/lowcut
	wrists = null
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/skirt/colored/black
	shoes = /obj/item/clothing/shoes/nobleboot/thighboots
	backr = null
	backl = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather
	beltl = null
	beltr = null
	ring = /obj/item/clothing/ring/active/nomag
	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/scrying = 1,
		/obj/item/chalk = 1,
		/obj/item/reagent_containers/glass/bottle/killersice = 1,
		/obj/item/book/granter/spellbook/adept = 1,
		/obj/item/weapon/knife/dagger/silver/arcyne = 1,
		/obj/item/storage/belt/pouch/cloth/coins/mid,
		/obj/item/key/outsider/witch = 1,
	)

/datum/outfit/swamp_witch/wild/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	equipped_human.mana_pool?.set_intrinsic_recharge(MANA_ALL_LEYLINES)
