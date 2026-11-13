/mob/living/carbon/human/species/gnoll_champion
	race = /datum/species/gnoll_champion
	age = AGE_ADULT
	skip_initial_outfit = TRUE
	footstep_type = FOOTSTEP_MOB_HEAVY
	base_pixel_x = -8
	base_pixel_y = -4
	pixel_x = -8
	pixel_y = -4

/mob/living/carbon/human/species/gnoll_champion/male
	gender = MALE

/mob/living/carbon/human/species/gnoll_champion/female
	gender = FEMALE

/datum/attribute_holder/sheet/job/species/gnoll_champion
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_PERCEPTION = 1,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 2,
		STAT_SPEED = 1,
	)

/// Separate from SPEC_ID_GNOLL and its character creation/customizer entries.
/datum/species/gnoll_champion
	name = "Gnoll Champion"
	id = "gnoll_champion"
	desc = "A fully mature, supernatural champion of Gorellik's living pack."
	changesource_flags = WABBAJACK
	possible_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	species_traits = list(NO_UNDERWEAR, NO_ORGAN_FEATURES, NO_BODYPART_FEATURES, NOEYESPRITES)
	inherent_traits = list(TRAIT_LONGSTRIDER, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_HARDDISMEMBER, TRAIT_STEELHEARTED, TRAIT_STRONGBITE)
	inherent_biotypes = MOB_HUMANOID | MOB_BEAST
	no_equip = list(ITEM_SLOT_SHIRT, ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_ARMOR, ITEM_SLOT_GLOVES, ITEM_SLOT_SHOES, ITEM_SLOT_PANTS, ITEM_SLOT_CLOAK)
	statsheet_male = /datum/attribute_holder/sheet/job/species/gnoll_champion
	statsheet_female = /datum/attribute_holder/sheet/job/species/gnoll_champion
	offset_features_m = list(OFFSET_HANDS = list(0, 2))
	offset_features_f = list(OFFSET_HANDS = list(0, 2))
	soundpack_m = /datum/voicepack/gnoll_champion
	soundpack_f = /datum/voicepack/gnoll_champion
	enflamed_icon = "widefire"
	var/pelt = "darkpelt"
	var/previous_pixel_x
	var/previous_pixel_y
	var/previous_rotation
	var/previous_footstep
	// These humanoid layers do not fit the donor's complete 48x48 body sprites.
	var/static/list/humanoid_layers = list(
		BODY_BEHIND_LAYER, BODY_UNDER_LAYER, BODYPARTS_LAYER,
		BODY_ADJ_LOWEST_LAYER, BODY_ADJ_LOW_LAYER, BODY_ADJ_LAYER,
		BODY_ADJ_MID_LAYER, BODY_ADJ_UPPER_LAYER, BODY_ADJ_TOP_LAYER, BODY_ADJ_TOP_TOP_LAYER,
		BODY_LAYER, BODY_FRONT_LAYER, ABOVE_BODY_FRONT_LAYER, BOTTOM_ARM_LAYER, LEG_PART_LAYER, HANDS_PART_LAYER,
		DAMAGE_LAYER, LEG_DAMAGE_LAYER, ARM_DAMAGE_LAYER,
		UNDERWEAR_BOT_LAYER, UNDERWEAR_TOP_LAYER, UNDERSHIRT_LAYER, UNDERSLEEVE_LAYER,
		SHIRT_LAYER, SHIRTSLEEVE_LAYER, PANTS_LAYER, LEGSLEEVE_LAYER, LEGWEAR_LAYER,
		SHOES_LAYER, SHOESLEEVE_LAYER, GLOVES_LAYER, GLOVESLEEVE_LAYER,
		WRISTS_LAYER, WRISTSLEEVE_LAYER, ARMSLEEVE_LAYER,
		ARMOR_LAYER, ARMORSLEEVE_LAYER, TABARD_LAYER, UNDER_CLOAK_LAYER,
		BELT_LAYER, BELT_BEHIND_LAYER, NECK_LAYER, BACK_LAYER, BACK_BEHIND_LAYER,
		CLOAK_LAYER, CLOAK_BEHIND_LAYER, HEAD_LAYER, MASK_LAYER, MOUTH_LAYER,
		HAIR_LAYER, HAIREXTRA_LAYER, CHOKER_LAYER, GARTER_LAYER, EARRING_L_LAYER, EARRING_R_LAYER,
	)

/datum/species/gnoll_champion/New()
	. = ..()
	organs = organs.Copy()
	organs[ORGAN_SLOT_EYES] = /obj/item/organ/eyes/night_vision/werewolf
	var/static/list/paw_offsets = list(
		"[SOUTH]" = list(list(9, 6), list(8, 5)),
		"[NORTH]" = list(list(8, 5), list(9, 6)),
		"[EAST]" = list(list(11, 4), list(4, 3)),
		"[WEST]" = list(list(12, 3), list(6, 4)),
	)
	held_item_dir_offsets = paw_offsets

/datum/species/gnoll_champion/check_roundstart_eligible()
	return FALSE

/datum/species/gnoll_champion/regenerate_icons(mob/living/carbon/human/champion)
	champion.icon = 'modular_rmh/icons/mob/monster/gnoll.dmi'
	var/prone = champion.body_position == LYING_DOWN
	champion.icon_state = prone ? "[pelt]_down" : pelt
	champion.remove_overlay(ARMOR_LAYER)
	if(champion.skin_armor?.icon_state)
		// Class states are armor pieces, not complete bodies.
		var/armor_state = champion.skin_armor.icon_state
		if(prone)
			armor_state = "[armor_state]_down"
		var/mutable_appearance/armor_overlay = mutable_appearance(champion.icon, armor_state, -ARMOR_LAYER)
		champion.overlays_standing[ARMOR_LAYER] = armor_overlay
		champion.add_overlay(armor_overlay)
	return TRUE

/datum/species/gnoll_champion/update_damage_overlays(mob/living/carbon/human/champion)
	champion.remove_overlay(DAMAGE_LAYER)
	champion.remove_overlay(LEG_DAMAGE_LAYER)
	champion.remove_overlay(ARM_DAMAGE_LAYER)
	return TRUE

/datum/species/gnoll_champion/proc/on_overlay_applied(mob/living/carbon/human/champion, cache_index)
	SIGNAL_HANDLER
	if(!(cache_index in humanoid_layers))
		return
	champion.remove_overlay(cache_index)
	if(cache_index == ARMOR_LAYER)
		regenerate_icons(champion)

/datum/species/gnoll_champion/proc/on_transform_updated(mob/living/carbon/human/champion)
	SIGNAL_HANDLER
	regenerate_icons(champion)

/datum/species/gnoll_champion/on_species_gain(mob/living/carbon/body, datum/species/old_species)
	previous_pixel_x = body.base_pixel_x
	previous_pixel_y = body.base_pixel_y
	previous_rotation = body.rotate_on_lying
	. = ..()
	body.grant_language(/datum/language/common)
	body.grant_language(/datum/language/beast)
	if(ishuman(body))
		var/mob/living/carbon/human/champion = body
		previous_footstep = champion.footstep_type
		if(champion.get_taur_tail())
			champion.ensure_not_taur()
		QDEL_NULL(champion.skin_armor)
		champion.skin_armor = new /obj/item/clothing/armor/regenerating/skin/gnoll(champion)
		champion.set_base_pixel_x(-8)
		champion.set_base_pixel_y(-4)
		// A transformed quarry may already have a rotated humanoid appearance.
		if(champion.rotate_on_lying && champion.lying_prev)
			var/matrix/upright_transform = matrix(champion.transform)
			upright_transform.Turn(-champion.lying_prev)
			champion.transform = upright_transform
		champion.rotate_on_lying = FALSE
		if(champion.footstep_type != FOOTSTEP_MOB_HEAVY)
			if(!(champion.status_flags & BUILDING_ORGANS))
				champion.RemoveElement(/datum/element/footstep, champion.footstep_type, 1, -6)
			champion.footstep_type = FOOTSTEP_MOB_HEAVY
			if(!(champion.status_flags & BUILDING_ORGANS))
				champion.AddElement(/datum/element/footstep, champion.footstep_type, 1, -6)
		RegisterSignal(champion, COMSIG_LIVING_APPLY_OVERLAY, PROC_REF(on_overlay_applied))
		RegisterSignal(champion, COMSIG_LIVING_POST_UPDATE_TRANSFORM, PROC_REF(on_transform_updated))
		RegisterSignal(champion, COMSIG_MOB_SAY, PROC_REF(handle_speech))
		add_verb(champion, /mob/living/carbon/human/proc/inspect_gnoll_pelt)
		for(var/cache_index in humanoid_layers)
			champion.remove_overlay(cache_index)
		regenerate_icons(champion)

/datum/species/gnoll_champion/on_species_loss(mob/living/carbon/body)
	body.remove_status_effect(/datum/status_effect/invisibility/gnoll_stalk)
	if(ishuman(body))
		var/mob/living/carbon/human/champion = body
		UnregisterSignal(champion, list(COMSIG_LIVING_APPLY_OVERLAY, COMSIG_LIVING_POST_UPDATE_TRANSFORM, COMSIG_MOB_SAY))
		remove_verb(champion, /mob/living/carbon/human/proc/inspect_gnoll_pelt)
		champion.remove_overlay(ARMOR_LAYER)
		if(istype(champion.skin_armor, /obj/item/clothing/armor/regenerating/skin/gnoll))
			QDEL_NULL(champion.skin_armor)
		champion.set_base_pixel_x(previous_pixel_x)
		champion.set_base_pixel_y(previous_pixel_y)
		champion.rotate_on_lying = previous_rotation
		if(previous_rotation && champion.lying_prev)
			var/matrix/humanoid_transform = matrix(champion.transform)
			humanoid_transform.Turn(champion.lying_prev)
			champion.transform = humanoid_transform
		if(champion.footstep_type != previous_footstep)
			champion.RemoveElement(/datum/element/footstep, champion.footstep_type, 1, -6)
			champion.footstep_type = previous_footstep
			champion.AddElement(/datum/element/footstep, champion.footstep_type, 1, -6)
		champion.icon = initial(champion.icon)
		champion.icon_state = initial(champion.icon_state)
	return ..()

/datum/species/gnoll_champion/send_voice(mob/living/carbon/human/champion)
	if(champion.m_intent != MOVE_INTENT_SNEAK)
		playsound(champion, pick('sound/vo/mobs/wwolf/wolftalk1.ogg', 'sound/vo/mobs/wwolf/wolftalk2.ogg'), 100, TRUE, -1)
	else
		playsound(champion, 'sound/misc/talk.ogg', 100, TRUE, -1)

/datum/voicepack/gnoll_champion
	parent_type = /datum/voicepack/werewolf

/datum/voicepack/gnoll_champion/get_sound(soundin, modifiers)
	switch(soundin)
		if("scream", "howl")
			return 'sound/vo/mobs/hyena/yeen_howl.ogg'
		if("cackle", "chuckle", "laugh")
			return 'sound/vo/mobs/hyena/laugh.ogg'
		if("whimper")
			return 'sound/vo/mobs/hyena/groan.ogg'
	return ..()

/mob/living/carbon/human/proc/inspect_gnoll_pelt()
	set name = "Inspect Pelt"
	set category = "Gnoll"
	if(!istype(skin_armor, /obj/item/clothing/armor/regenerating/skin/gnoll))
		return
	var/list/entries = list(span_notice("PROPERTIES OF YOUR PELT"))
	skin_armor.get_inspect_entries(entries)
	to_chat(src, examine_block(entries.Join()))

/obj/item/clothing/armor/regenerating/skin/gnoll
	name = "gnoll's pelt"
	icon = 'modular_rmh/icons/mob/monster/gnoll.dmi'
	mob_overlay_icon = 'modular_rmh/icons/mob/monster/gnoll.dmi'
	slot_flags = null
	body_parts_covered = FULL_BODY
	armor_type = /datum/armor/leather
	max_integrity = 300
	repair_time = 30 SECONDS
	item_flags = DROPDEL

/obj/item/clothing/armor/regenerating/skin/gnoll/Destroy()
	var/mob/living/carbon/human/champion = loc
	if(istype(champion) && champion.skin_armor == src)
		champion.skin_armor = null
	return ..()

