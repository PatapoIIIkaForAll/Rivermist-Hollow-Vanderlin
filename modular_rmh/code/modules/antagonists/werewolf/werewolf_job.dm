
/datum/attribute_holder/sheet/job/werewolf
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 2,

		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/wrestling = 50,
		/datum/attribute/skill/combat/unarmed = 60,
		/datum/attribute/skill/misc/climbing = 60,
		/datum/attribute/skill/misc/athletics = 60,
		/datum/attribute/skill/misc/medicine = 40,
		/datum/attribute/skill/misc/sneaking = 40

	)

/datum/job/werewolf
	title = "Werewolf"
	tutorial = "You carry a hidden curse and a hungry beast under your skin. Blend in, bide your time, and decide when the town will finally hear you howl."
	department_flag = VILLAINS
	faction = FACTION_TOWN
	total_positions = 1
	spawn_positions = 1
	antag_job = TRUE
	can_random = FALSE
	selection_color = JCOLOR_VILLAINS
	job_flags = (JOB_EQUIP_RANK | JOB_SHOW_IN_CREDITS | JOB_NEW_PLAYER_JOINABLE)
	allowed_races = ALL_RACES_LIST
	job_whitelist_id = "werewolf"
	cmode_music = 'sound/music/cmode/antag/combat_werewolf.ogg'
	outfit = /datum/outfit/antagonist/werewolf
	attribute_sheet = /datum/attribute_holder/sheet/job/werewolf
	antag_role = /datum/antagonist/werewolf
	display_order = JDO_WEREWOLF
	rune_linked = RUNE_LINK_ANTAG

/datum/job/werewolf/proc/can_take_werewolf_job(player_ckey)
	if(!player_ckey)
		return FALSE
	if(is_total_antag_banned(player_ckey))
		return FALSE
	if(is_antag_banned(player_ckey, ROLE_WEREWOLF))
		return FALSE
	return TRUE

/datum/job/werewolf/special_job_check(mob/dead/new_player/player)
	if(!player?.client)
		return FALSE
	return can_take_werewolf_job(player.ckey)

/datum/job/werewolf/special_check_latejoin(client/player_client)
	return can_take_werewolf_job(player_client?.ckey)

/datum/job/werewolf/proc/get_towner_disguise_choices(mob/living/carbon/human/spawned)
	var/list/disguise_choices = list()
	var/datum/job/towner/towner_job = SSjob.GetJobType(/datum/job/towner)
	if(!towner_job)
		return disguise_choices

	for(var/disguise_type in towner_job.job_subclasses)
		var/datum/job/disguise_job = SSjob.GetJobType(disguise_type)
		if(!disguise_job)
			continue
		if(!disguise_job.can_disguise_as)
			continue
		if(!disguise_job.outfit && !disguise_job.outfit_female)
			continue

		var/disguise_title = disguise_job.get_gendered_title(spawned.gender, spawned.pronouns)

		disguise_choices[disguise_title] = disguise_job

	return disguise_choices

/datum/job/werewolf/proc/apply_towner_disguise(mob/living/carbon/human/spawned, client/player_client)
	var/list/disguise_choices = get_towner_disguise_choices(spawned)
	if(!length(disguise_choices))
		return

	var/choice = spawned.select_outfit(
		player_client,
		disguise_choices,
		time_limit = 1 MINUTES,
		message = "Choose the towner role I will pass as.",
		title = "DISGUISE",
		clear_existing = TRUE
	)
	if(!choice)
		return

	spawned.disguise_title_override = choice

/datum/job/werewolf/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	if(!ishuman(spawned))
		return

	apply_towner_disguise(spawned, player_client)
	. = ..()

	try_auto_link_resurrection_rune(spawned)

/datum/outfit/antagonist/werewolf
	name = "Werewolf"
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
	belt = /obj/item/storage/belt/leather/rope
	beltl = /obj/item/storage/belt/pouch/cloth/coins/poor
	beltr = /obj/item/clothing/armor/leather/vest
	ring = null
	l_hand = null
	r_hand = null

/obj/effect/landmark/start/werewolf
	name = "Werewolf"
	icon_state = "arrow"
	jobspawn_override = list("Werewolf")
	delete_after_roundstart = FALSE
