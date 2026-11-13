/obj/effect/landmark/start/gnoll_champion
	name = ROLE_GNOLL
	icon_state = "arrow"
	jobspawn_override = list(ROLE_GNOLL)
	delete_after_roundstart = FALSE

/datum/job/gnoll
	title = ROLE_GNOLL
	tutorial = "You are a supernatural champion of Gorellik's rebuilding pack. Fulfill shared contracts through living hunts, wilderness rites, provisions and the pack's renewal through captive carriers. Wake and release defeated quarry; never kill for the pack."
	department_flag = VILLAINS
	faction = FACTION_NEUTRAL
	total_positions = GNOLL_FOUNDER_SLOTS
	spawn_positions = GNOLL_FOUNDER_SLOTS
	antag_job = TRUE
	can_random = FALSE
	selection_color = JCOLOR_VILLAINS
	job_flags = JOB_EQUIP_RANK | JOB_SHOW_IN_CREDITS | JOB_NEW_PLAYER_JOINABLE
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	allowed_races = ALL_RACES_LIST
	antag_role = /datum/antagonist/gnoll
	// Equipment is supplied once, when a calling is selected.
	outfit = null
	rune_linked = RUNE_LINK_ANTAG
	display_order = JDO_SUCCUBUS + 0.5
	advclass_cat_rolls = list(CAT_GNOLL = 4)
	job_subclasses = list(/datum/job/advclass/gnoll/hunter, /datum/job/advclass/gnoll/knight, /datum/job/advclass/gnoll/templar, /datum/job/advclass/gnoll/shaman)
	job_whitelist_id = "gnoll"

/datum/job/gnoll/proc/has_required_landmarks()
	return length(GLOB.jobspawn_overrides[title]) && length(GLOB.gnoll_shrines)

/datum/job/gnoll/proc/can_take_gnoll_job(player_ckey)
	if(!player_ckey || is_total_antag_banned(player_ckey) || is_antag_banned(player_ckey, ROLE_GNOLL))
		return FALSE
	for(var/datum/team/gnoll/pack in GLOB.antagonist_teams)
		if(!pack.has_room())
			return FALSE
	return TRUE

/datum/job/gnoll/special_job_check(mob/dead/new_player/player)
	return has_required_landmarks() && can_take_gnoll_job(player?.ckey)

/datum/job/gnoll/special_check_latejoin(client/player_client)
	return has_required_landmarks() && can_take_gnoll_job(player_client?.ckey)

/datum/job/gnoll/get_roundstart_spawn_point()
	if(!has_required_landmarks())
		log_world("Refusing to spawn [title]: a champion landmark and a Gorellik shrine are required.")
		return null
	return pick(GLOB.jobspawn_overrides[title])

/datum/job/gnoll/get_latejoin_spawn_point()
	return get_roundstart_spawn_point()

/datum/outfit/gnoll
	name = "Gnoll Champion"
	backl = /obj/item/storage/backpack/satchel/gnoll
	belt = /obj/item/storage/belt/leather
	neck = /obj/item/storage/belt/pouch/gnoll
	// Bolas and ropes favour taking quarry alive.
	beltl = /obj/item/rope/net/bola
	beltr = /obj/item/rope
	backpack_contents = list(/obj/item/gnoll_trail_charm = 1, /obj/item/rope = 1, /obj/item/natural/cloth/bandage = 3, /obj/item/reagent_containers/food/snacks/hardtack = 1)

/datum/job/advclass/gnoll
	abstract_type = /datum/job/advclass/gnoll
	category_tags = list(CAT_GNOLL)
	// The class menu checks saved character preferences, before/independently of transformation.
	allowed_races = ALL_RACES_LIST
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	exp_types_granted = list(EXP_TYPE_ANTAG)
	outfit = /datum/outfit/gnoll
	var/pelt_overlay
	var/pelt_integrity = 300

/datum/job/advclass/gnoll/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/datum/antagonist/gnoll/champion = get_gnoll_antag(spawned)
	spawned.apply_gnoll_customization()
	champion?.apply_calling(spawned, type)
	champion?.start_customization_window()

/datum/job/advclass/gnoll/hunter
	title = "Gnoll Hunter"
	tutorial = "The pack's mobile hunter and wrestler. Pursue worthy quarry, bring them down without killing, and see them restored and released."
	pelt_overlay = "berserker"
	outfit = /datum/outfit/gnoll/hunter
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/gnoll/hunter

/datum/outfit/gnoll/hunter
	name = "Gnoll Hunter"
	neck = /obj/item/storage/belt/pouch/gnoll/healing
	beltr = /obj/item/rope/net/bola
	backpack_contents = list(/obj/item/gnoll_trail_charm = 1, /obj/item/rope = 2, /obj/item/natural/cloth/bandage = 3, /obj/item/reagent_containers/food/snacks/hardtack = 1)

/datum/attribute_holder/sheet/job/advclass/gnoll/hunter
	raw_attribute_list = list(
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 3,
		STAT_STRENGTH = 3,
		STAT_SPEED = 3,
		/datum/attribute/skill/combat/axesmaces = 20,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/combat/unarmed = 40,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/sewing = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/tracking = 50,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/craft/traps = 20,
	)

/datum/job/advclass/gnoll/knight
	title = "Gnoll Knight"
	tutorial = "The pack's steadfast defender. Hold the wilderness, protect the rites and escort companions and recovering quarry."
	total_positions = 2
	pelt_overlay = "knight"
	pelt_integrity = 450
	outfit = /datum/outfit/gnoll/knight
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/gnoll/knight

/datum/attribute_holder/sheet/job/advclass/gnoll/knight
	raw_attribute_list = list(
		STAT_CONSTITUTION = 3,
		STAT_ENDURANCE = 5,
		STAT_STRENGTH = 5,
		STAT_SPEED = -1,
		/datum/attribute/skill/combat/axesmaces = 10,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/shields = 40,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/sewing = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/misc/tracking = 50,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/craft/traps = 20,
	)

/datum/outfit/gnoll/knight
	name = "Gnoll Knight"
	neck = /obj/item/storage/belt/pouch/gnoll/healing
	r_hand = /obj/item/weapon/shield/wood

/datum/job/advclass/gnoll/templar
	title = "Gnoll Templar"
	tutorial = "Gorellik's oathkeeper. Tend the living hunt, restore defeated quarry with Lesser Miracle and protect the pack's rites."
	total_positions = 1
	pelt_overlay = "templar"
	pelt_integrity = 375
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/gnoll/templar

/datum/attribute_holder/sheet/job/advclass/gnoll/templar
	raw_attribute_list = list(
		STAT_CONSTITUTION = 4,
		STAT_ENDURANCE = 4,
		STAT_STRENGTH = 4,
		/datum/attribute/skill/combat/axesmaces = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/sewing = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/misc/tracking = 50,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/craft/traps = 20,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/reading = 30,
	)

/datum/job/advclass/gnoll/shaman
	title = "Gnoll Shaman"
	tutorial = "Keeper of renewal. Lesser Miracle and Miracle wake the defeated through prepared recovery; Bear Their Burden treats ordinary defeat trauma at a real cost to you. Use silver at a solace shrine for Convalescence."
	total_positions = 1
	pelt_overlay = "shaman"
	pelt_integrity = 250
	outfit = /datum/outfit/gnoll/shaman
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/gnoll/shaman

/datum/attribute_holder/sheet/job/advclass/gnoll/shaman
	raw_attribute_list = list(
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 4,
		STAT_STRENGTH = 1,
		STAT_INTELLIGENCE = 2,
		STAT_PERCEPTION = 1,
		/datum/attribute/skill/combat/axesmaces = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/swords = 10,
		/datum/attribute/skill/combat/shields = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/sewing = 20,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/labor/butchering = 10,
		/datum/attribute/skill/misc/tracking = 40,
		/datum/attribute/skill/misc/sneaking = 30,
		/datum/attribute/skill/craft/traps = 20,
		/datum/attribute/skill/magic/holy = 40,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/craft/alchemy = 30,
	)

/datum/outfit/gnoll/shaman
	name = "Gnoll Shaman"
	neck = /obj/item/storage/belt/pouch/gnoll/alchemy
	r_hand = /obj/item/gnoll_ritual_chalk
	backpack_contents = list(
		/obj/item/gnoll_trail_charm = 1,
		/obj/item/rope = 1,
		/obj/item/natural/bundle/cloth/bandage/full = 2,
		/obj/item/coin/silver = 6,
	)

