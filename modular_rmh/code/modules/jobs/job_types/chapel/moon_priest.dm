/datum/attribute_holder/sheet/job/moon_priest
	raw_attribute_list = list(
		STAT_PERCEPTION = 2,
		STAT_INTELLIGENCE = 3,
		STAT_CONSTITUTION = 1,
		STAT_ENDURANCE = 2,
		STAT_SPEED = 1,
		STAT_FORTUNE = 2,
		/datum/attribute/skill/magic/holy = 50,
		/datum/attribute/skill/misc/reading = 50,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/labor/mathematics = 30
	)

/datum/job/moon_priest
	title = "Moon Priest"
	f_title = "Moon Priestess"
	unique_alt_honorary = TRUE
	alt_honorary = list("Father")
	alt_honorary_female = list("Mother Superior")
	tutorial = "You serve Selune, the Moonmaiden. \
	In darkness and doubt, her silver light guides the lost. \
	This humble chapel is a refuge for travelers and the faithful. \
	You are healer, watcher, and keeper of the night."
	department_flag = CHAPEL
	faction = FACTION_TOWN
	total_positions = 1
	spawn_positions = 1
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_MOON_PRIEST

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST

	outfit = /datum/outfit/moon_priest
	selection_color = JCOLOR_CHAPEL

	give_bank_account = 100

	exp_type = list(EXP_TYPE_CHURCH)
	exp_types_granted = list(EXP_TYPE_CHURCH, EXP_TYPE_CLERIC)
	exp_requirements = list(EXP_TYPE_CHURCH = 700)

	allowed_patrons = list(/datum/patron/faerun/good_gods/Selune)
	attribute_sheet = /datum/attribute_holder/sheet/job/moon_priest


	traits = list(
		TRAIT_HOLY,
		TRAIT_NIGHT_OWL,
		TRAIT_ANTISCRYING
	)

	languages = list(/datum/language/celestial)

	magic_user = TRUE
	spell_points = 30

	spells = list(/datum/action/cooldown/spell/undirected/list_target/convert_role/chapel_acolyte,
		/datum/action/cooldown/spell/undirected/call_bird/priest,
		/datum/action/cooldown/spell/undirected/touch/orison,
		/datum/action/cooldown/spell/healing,
		/datum/action/cooldown/spell/healing/greater,
		/datum/action/cooldown/spell/revive,
		/datum/action/cooldown/spell/attach_bodypart,
		/datum/action/cooldown/spell/diagnose/holy,
		/datum/action/cooldown/spell/cure_rot,
		/datum/action/cooldown/spell/status/guidance,
		/datum/action/cooldown/spell/essence/toxic_cleanse/class_granted,
		/datum/action/cooldown/spell/undirected/touch/darkvision,
		/datum/action/cooldown/spell/undirected/secondsight,
		/datum/action/cooldown/spell/undirected/touch/non_detection,
		/datum/action/cooldown/spell/undirected/feather_falling,
		/datum/action/cooldown/spell/undirected/longstrider,
		/datum/action/cooldown/spell/undirected/conjure_item/light,
		/datum/action/cooldown/spell/undirected/forcewall/breakable,
		/datum/action/cooldown/spell/aoe/churn_undead,
		/datum/action/cooldown/spell/aoe/abrogation,
		/datum/action/cooldown/spell/undirected/locate_dead,
		/datum/action/cooldown/spell/undirected/soul_speak,
		/datum/action/cooldown/spell/projectile/moonlit_dagger,
		/datum/action/cooldown/spell/sacred_flame,
		/datum/action/cooldown/spell/undirected/divine_strike,
		/datum/action/cooldown/spell/pointed/silence,
	)

/datum/job/moon_priest/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	spawned.verbs |= /mob/living/carbon/human/proc/churchannouncement

	var/holder = spawned.patron?.devotion_holder
	if(holder)
		var/datum/devotion/devotion = new holder()
		devotion.make_priest()
		devotion.grant_to(spawned)

//OUTFIT

/datum/outfit/moon_priest
	name = "Moon Priest"
	head = /obj/item/clothing/head/crown/circlet/silverdiadem/moon_priest
	mask = null
	neck = /obj/item/clothing/neck/psycross/silver/selune
	cloak = /obj/item/clothing/cloak/cape/colored/moon_priest
	armor = null
	shirt = /obj/item/clothing/shirt/robe/selune
	wrists = null
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/tights/colored/moon_priest
	shoes = /obj/item/clothing/shoes/boots/leather
	backr = /obj/item/storage/backpack/satchel
	backl = null
	belt = /obj/item/storage/belt/leather/plaquesilver
	beltr = /obj/item/storage/belt/pouch/coins/rich
	beltl = /obj/item/storage/keyring/town_chapel
	ring = /obj/item/clothing/ring/silver/blortz
	l_hand = null
	r_hand = /obj/item/weapon/polearm/woodstaff/quarterstaff/silver

	backpack_contents = list(
		/obj/item/needle/blessed = 1,
		/obj/item/reagent_containers/glass/bottle/stronghealthpot = 2,
		/obj/item/reagent_containers/glass/bottle/alchemical/blessedwater = 1,
	)

/datum/outfit/moon_priest/pre_equip(mob/living/carbon/human/equipped_human, visuals_only)
	. = ..()
	equipped_human.mana_pool?.set_intrinsic_recharge(MANA_ALL_LEYLINES)

//ANNOUNCEMENT

/mob/living/carbon/human/proc/churchannouncement()
	set name = "Announcement"
	set category = "Priest"
	if(stat)
		return
	var/inputty = input("Make an announcement", "RIVERMIST HOLLOW") as text|null
	if(inputty)
		if(!istype(get_area(src), /area/indoors/town/rmh/chapel))
			to_chat(src, "<span class='warning'>I need to do this from the chapel.</span>")
			return FALSE
		priority_announce("[inputty]", title = "The [get_role_title()] Speaks", sound = 'sound/misc/bell.ogg')
		src.log_talk("[TIMETOTEXT4LOGS] [inputty]", LOG_SAY, tag="Priest announcement")

//CONVERSION

/datum/action/cooldown/spell/undirected/list_target/convert_role/chapel_acolyte
	name = "Recruit Acolyte"
	button_icon_state = "recruit_templar"

	new_role = "Chapel Acolyte"
	recruitment_faction = "Town Chapel"
	recruitment_message = "Serve the Divines, %RECRUIT!"
	accept_message = "FOR THE DIVINES!"
	refuse_message = "I refuse."
