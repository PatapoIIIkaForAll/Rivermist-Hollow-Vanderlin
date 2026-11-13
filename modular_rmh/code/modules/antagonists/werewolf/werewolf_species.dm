/mob/living/carbon/human/species/werewolf
	race = /datum/species/werewolf
	base_strength = 15
	base_constitution = 15
	base_endurance = 15

	var/datum/language_holder/stored_language
	var/list/stored_skills
	var/list/stored_experience
	cmode_music = 'sound/music/cmode/antag/combat_werewolf.ogg'
	limb_destroyer = TRUE
	ambushable = FALSE
	base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)

/mob/living/carbon/human/species/werewolf/male
	gender = MALE

/mob/living/carbon/human/species/werewolf/female
	gender = FEMALE

/datum/attribute_holder/sheet/job/species/werewolf
	raw_attribute_list = list(
		STAT_STRENGTH = 5,
		STAT_PERCEPTION = 5,
		STAT_INTELLIGENCE = -3,
		STAT_CONSTITUTION = 5,
		STAT_ENDURANCE = 5,
		STAT_SPEED = 3,
	)

/datum/species/werewolf
	name = "werewolf"
	id = "werewolf"

	species_traits = list(NO_UNDERWEAR, NO_ORGAN_FEATURES, NO_BODYPART_FEATURES, NOEYESPRITES)
	inherent_traits = list(
		TRAIT_NOSTAMINA,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_STRONGBITE,
		TRAIT_ZJUMP,
		TRAIT_NOFALLDAMAGE1,
		TRAIT_BASHDOORS,
		TRAIT_STEELHEARTED,
		TRAIT_BREADY,
		TRAIT_ORGAN_EATER,
		TRAIT_NASTY_EATER,
		TRAIT_DEADNOSE,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_HARDDISMEMBER,
		TRAIT_UNDODGING,
		TRAIT_UNPARRYING,
		TRAIT_LONGSTRIDER
	)

	inherent_biotypes = MOB_HUMANOID

	no_equip = list(ITEM_SLOT_SHIRT, ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_ARMOR, ITEM_SLOT_GLOVES, ITEM_SLOT_SHOES, ITEM_SLOT_PANTS, ITEM_SLOT_CLOAK, ITEM_SLOT_BELT, ITEM_SLOT_BACK_R, ITEM_SLOT_BACK_L)

	offset_features_m = list(OFFSET_HANDS = list(0,2))
	offset_features_f = list(OFFSET_HANDS = list(0,2))

	soundpack_m = /datum/voicepack/werewolf
	soundpack_f = /datum/voicepack/werewolf

	statsheet_male = /datum/attribute_holder/sheet/job/species/werewolf

	enflamed_icon = "widefire"

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_SPLEEN = /obj/item/organ/spleen,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision/werewolf,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
	)

	meat = list(/obj/item/reagent_containers/food/snacks/meat/steak/human = 1, /obj/item/reagent_containers/food/snacks/meat/steak = 3)

	changesource_flags = WABBAJACK
	bleed_mod = 0.6
	pain_mod = 0.2

	/// Art set this body draws from; read it through get_form_look().
	var/datum/werewolf_form_look/form_look
	/// Eye overlay tint from the beast profile; null uses the look's default glow.
	var/eye_glow
	var/previous_pixel_x
	var/previous_pixel_y
	var/previous_footstep
	// Humanoid layers that do not fit the 48x48 beast sprites; the beast draws damage itself.
	var/static/list/humanoid_layers = list(
		BODY_BEHIND_LAYER, BODY_UNDER_LAYER, BODYPARTS_LAYER,
		BODY_ADJ_LOWEST_LAYER, BODY_ADJ_LOW_LAYER, BODY_ADJ_LAYER,
		BODY_ADJ_MID_LAYER, BODY_ADJ_UPPER_LAYER, BODY_ADJ_TOP_LAYER, BODY_ADJ_TOP_TOP_LAYER,
		BODY_LAYER, BODY_FRONT_LAYER, ABOVE_BODY_FRONT_LAYER, BOTTOM_ARM_LAYER, LEG_PART_LAYER, HANDS_PART_LAYER,
		LEG_DAMAGE_LAYER, ARM_DAMAGE_LAYER,
		UNDERWEAR_BOT_LAYER, UNDERWEAR_TOP_LAYER, UNDERSHIRT_LAYER, UNDERSLEEVE_LAYER,
		SHIRT_LAYER, SHIRTSLEEVE_LAYER, PANTS_LAYER, LEGSLEEVE_LAYER, LEGWEAR_LAYER,
		SHOES_LAYER, SHOESLEEVE_LAYER, GLOVES_LAYER, GLOVESLEEVE_LAYER,
		WRISTS_LAYER, WRISTSLEEVE_LAYER, ARMSLEEVE_LAYER,
		ARMOR_LAYER, ARMORSLEEVE_LAYER, TABARD_LAYER, UNDER_CLOAK_LAYER,
		BELT_LAYER, BELT_BEHIND_LAYER, NECK_LAYER, BACK_LAYER, BACK_BEHIND_LAYER,
		CLOAK_LAYER, CLOAK_BEHIND_LAYER, HEAD_LAYER, MASK_LAYER, MOUTH_LAYER,
		HAIR_LAYER, HAIREXTRA_LAYER, CHOKER_LAYER, GARTER_LAYER, EARRING_L_LAYER, EARRING_R_LAYER,
	)

/datum/species/werewolf/New()
	. = ..()
	var/static/list/paw_offsets = list(
		"[SOUTH]" = list(list(5, 2), list(-4, 2)),
		"[NORTH]" = list(list(-4, 2), list(5, 2)),
		"[EAST]" = list(list(5, 5), list(-6, 2)),
		"[WEST]" = list(list(6, 2), list(-5, 5)),
	)
	held_item_dir_offsets = paw_offsets

/datum/species/werewolf/send_voice(mob/living/carbon/human/H)
	playsound(H, pick('sound/vo/mobs/wwolf/wolftalk1.ogg', 'sound/vo/mobs/wwolf/wolftalk2.ogg'), 100, TRUE, -1)

/datum/species/werewolf/regenerate_icons(mob/living/carbon/human/H)
	var/datum/werewolf_form_look/look = get_form_look(H)
	H.icon = look.icon
	H.icon_state = look.get_body_state(H.gender)
	H.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
	update_beast_overlays(H, look)
	H.update_damage_overlays()
	return TRUE

/// Penis and eye overlays; a state the sheet lacks draws nothing.
/datum/species/werewolf/proc/update_beast_overlays(mob/living/carbon/human/beast, datum/werewolf_form_look/look)
	beast.remove_overlay(WW_BEAST_OVERLAY_LAYER)
	var/list/beast_overlays = list()
	if(beast.getorganslot(ORGAN_SLOT_PENIS))
		var/list/arousal_data = list()
		SEND_SIGNAL(beast, COMSIG_SEX_GET_AROUSAL, arousal_data)
		var/penis_state = look.get_penis_state(arousal_data["arousal"])
		if(look.has_state(penis_state))
			beast_overlays += mutable_appearance(look.icon, penis_state, -WW_BEAST_OVERLAY_LAYER)
	if(look.has_state(look.eyes_state))
		var/mutable_appearance/eyes_overlay = mutable_appearance(look.icon, look.eyes_state, -WW_BEAST_OVERLAY_LAYER)
		eyes_overlay.color = eye_glow || get_werewolf_default_eye_glow(look.id)
		beast_overlays += eyes_overlay
	if(!length(beast_overlays))
		return
	beast.overlays_standing[WW_BEAST_OVERLAY_LAYER] = beast_overlays
	beast.apply_overlay(WW_BEAST_OVERLAY_LAYER)

/datum/species/werewolf/proc/get_form_look(mob/living/carbon/human/beast)
	RETURN_TYPE(/datum/werewolf_form_look)
	if(!form_look)
		form_look = resolve_form_look(beast)
	return form_look

/// The look picked on the body's werewolf antag datum, else lean.
/datum/species/werewolf/proc/resolve_form_look(mob/living/carbon/human/beast)
	RETURN_TYPE(/datum/werewolf_form_look)
	var/datum/antagonist/werewolf/werewolf_antag = IS_WEREWOLF(beast)
	return get_werewolf_form_look(werewolf_antag?.form_look_id)

/// Switches the art set and its tile offsets, then redraws the body.
/datum/species/werewolf/proc/apply_form_look(mob/living/carbon/human/beast, datum/werewolf_form_look/look)
	form_look = look || get_werewolf_form_look(WEREWOLF_LOOK_LEAN)
	beast.set_base_pixel_x(form_look.pixel_x)
	beast.set_base_pixel_y(form_look.pixel_y)
	regenerate_icons(beast)

/datum/species/werewolf/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	previous_pixel_x = C.base_pixel_x
	previous_pixel_y = C.base_pixel_y
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/beast)
	C.add_faction(FACTION_WOLVES)
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/beast = C
	swap_in_beast_footsteps(beast)
	RegisterSignal(beast, COMSIG_LIVING_APPLY_OVERLAY, PROC_REF(on_overlay_applied))
	for(var/cache_index in humanoid_layers)
		beast.remove_overlay(cache_index)
	apply_form_look(beast, resolve_form_look(beast))

/datum/species/werewolf/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	UnregisterSignal(C, list(COMSIG_MOB_SAY, COMSIG_LIVING_APPLY_OVERLAY))
	restore_footsteps(C)
	C.remove_overlay(WW_BEAST_OVERLAY_LAYER)
	C.remove_overlay(DAMAGE_LAYER)
	C.set_base_pixel_x(previous_pixel_x)
	C.set_base_pixel_y(previous_pixel_y)
	C.icon = initial(C.icon)
	C.icon_state = initial(C.icon_state)
	form_look = null
	return ..()

/datum/species/werewolf/proc/on_overlay_applied(mob/living/carbon/human/beast, cache_index)
	SIGNAL_HANDLER
	if(cache_index in humanoid_layers)
		beast.remove_overlay(cache_index)

/// Trades the default step element for quieter terrain-aware beast steps.
/datum/species/werewolf/proc/swap_in_beast_footsteps(mob/living/carbon/human/beast)
	if(beast.footstep_type == FOOTSTEP_MOB_BEAST)
		return
	previous_footstep = beast.footstep_type
	beast.footstep_type = FOOTSTEP_MOB_BEAST
	if(beast.status_flags & BUILDING_ORGANS)
		// Initialize attaches the default element after species setup, so swap once it finishes.
		if(!(beast.flags_1 & INITIALIZED_1))
			RegisterSignal(beast, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE, PROC_REF(on_beast_initialized))
		return
	beast.RemoveElement(/datum/element/footstep, previous_footstep, 1, -6)
	beast.AddElement(/datum/element/footstep, FOOTSTEP_MOB_BEAST, WW_FOOTSTEP_VOLUME, WW_FOOTSTEP_RANGE)

/datum/species/werewolf/proc/on_beast_initialized(mob/living/carbon/human/beast)
	SIGNAL_HANDLER
	UnregisterSignal(beast, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
	if(beast.footstep_type != FOOTSTEP_MOB_BEAST)
		return
	beast.RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_BEAST, 1, -6)
	beast.AddElement(/datum/element/footstep, FOOTSTEP_MOB_BEAST, WW_FOOTSTEP_VOLUME, WW_FOOTSTEP_RANGE)

/datum/species/werewolf/proc/restore_footsteps(mob/living/carbon/human/beast)
	UnregisterSignal(beast, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
	if(beast.footstep_type != FOOTSTEP_MOB_BEAST)
		return
	beast.RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_BEAST, WW_FOOTSTEP_VOLUME, WW_FOOTSTEP_RANGE)
	beast.footstep_type = previous_footstep || FOOTSTEP_MOB_HUMAN
	beast.AddElement(/datum/element/footstep, beast.footstep_type, 1, -6)

/datum/species/werewolf/update_damage_overlays(mob/living/carbon/human/H)
	H.remove_overlay(DAMAGE_LAYER)
	var/worst_damage = 0
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST))
		var/obj/item/bodypart/affecting = H.get_bodypart(zone)
		if(affecting)
			worst_damage = max(worst_damage, affecting.brute_dam / affecting.max_damage, affecting.burn_dam / affecting.max_damage)
	var/datum/werewolf_form_look/look = get_form_look(H)
	var/damage_state = look.get_damage_state(H.gender)
	if(worst_damage <= 0 || !look.has_state(damage_state))
		return TRUE
	var/mutable_appearance/damage_overlay = mutable_appearance(look.icon, damage_state, -DAMAGE_LAYER)
	damage_overlay.alpha = 255 * min(worst_damage, 1)
	H.overlays_standing[DAMAGE_LAYER] = damage_overlay
	H.apply_overlay(DAMAGE_LAYER)
	return TRUE

/datum/species/werewolf/random_name(gender = MALE, unique = FALSE)
	for(var/attempt in 1 to 10)
		. = random_werewolf_name()
		if(!unique || !findname(.))
			return

/datum/species/werewolf/check_species_weakness(obj/item, mob/living/attacker, mob/living/parent)
	if(parent.has_status_effect(/datum/status_effect/debuff/silver_bane))
		return 0.75
	return 0
