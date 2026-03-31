#define TAUR_PENIS_ICON 'modular_rmh/icons/mob/sprite_accessory/genitals/taur_penis_onmob.dmi'

/datum/sprite_accessory/genitals/penis
	icon = 'modular_rmh/icons/mob/sprite_accessory/genitals/pintle.dmi'
	color_keys = 2
	color_key_names = list("Member", "Skin")
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_MID_LAYER)
	abstract_type = /datum/sprite_accessory/genitals/penis

/datum/sprite_accessory/genitals/penis/get_appearance(obj/item/organ/organ, obj/item/bodypart/bodypart, color_string)
	var/mob/living/carbon/owner
	if(organ)
		owner = organ.owner
	else if(bodypart)
		owner = bodypart.owner
		if(!owner)
			owner = bodypart.original_owner

	var/taur_icon_state = get_taur_icon_state(organ, owner)
	if(!taur_icon_state)
		return ..()
	if(!is_visible(organ, bodypart, owner))
		return

	var/list/appearance_list = list(build_taur_penis_appearance(taur_icon_state, color_string, owner))
	adjust_appearance_list(appearance_list, organ, bodypart, owner)
	shift_for_taur(appearance_list)
	return appearance_list

/datum/sprite_accessory/genitals/penis/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	gender_genitals_adjust(appearance_list, organ, bodypart, owner, OFFSET_PENIS)

/datum/sprite_accessory/genitals/penis/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/genitals/penis/penis = organ
	if(penis.sheath_type != SHEATH_TYPE_NONE && penis.erect_state != ERECT_STATE_HARD)
		switch(penis.sheath_type)
			if(SHEATH_TYPE_NORMAL)
				if(penis.erect_state == ERECT_STATE_NONE)
					return "sheath_1"
				else
					return "sheath_2"
			if(SHEATH_TYPE_SLIT)
				if(penis.erect_state == ERECT_STATE_NONE)
					return "slit_1"
				else
					return "slit_2"
	if(penis.erect_state == ERECT_STATE_HARD)
		return "[icon_state]_[penis.organ_size]_erect"
	else
		return "[icon_state]_[penis.organ_size]"

/datum/sprite_accessory/genitals/penis/proc/get_taur_icon_state(obj/item/organ/organ, mob/living/carbon/owner)
	if(!is_taur_owner(owner) || !istype(organ, /obj/item/organ/genitals/penis))
		return null

	var/obj/item/organ/genitals/penis/penis = organ
	if(penis.sheath_type != SHEATH_TYPE_NONE && penis.erect_state != ERECT_STATE_HARD)
		switch(penis.sheath_type)
			if(SHEATH_TYPE_NORMAL)
				return "m_penis_sheath_[penis.erect_state == ERECT_STATE_NONE ? 0 : 1]_BEHIND"
			if(SHEATH_TYPE_SLIT)
				return "m_penis_slit_1_BEHIND"

	var/taur_shape = get_taur_shape_name()
	if(!taur_shape)
		return null

	var/arousal_state = (penis.erect_state == ERECT_STATE_HARD) ? 1 : 0
	return "m_penis_[taur_shape]_[penis.organ_size]_[arousal_state]_BEHIND"

/datum/sprite_accessory/genitals/penis/proc/get_taur_shape_name()
	switch(icon_state)
		if("knotted", "knotted2")
			return "knotted"
		if("flared")
			return "flared"
		if("barbknot")
			return "barbknot"
		if("tapered", "tapered_mammal")
			return "tapered"
		if("tentacle")
			return "tentacle"
	return null

/datum/sprite_accessory/genitals/penis/proc/build_taur_penis_appearance(taur_icon_state, color_string, mob/living/carbon/owner)
	color_string = sanitize_color_string(color_string)
	var/cache_key = "[type]-taur-[taur_icon_state]-[color_string]"
	if(!accessory_icon_cache[cache_key])
		var/list/color_list = color_string_to_list(color_string)
		var/icon/result_icon = icon(TAUR_PENIS_ICON, "[taur_icon_state]_primary")
		result_icon.Blend(color_list[1], ICON_MULTIPLY)

		var/secondary_state = "[taur_icon_state]_secondary"
		if(length(color_list) > 1 && icon_exists(TAUR_PENIS_ICON, secondary_state))
			var/icon/secondary_icon = icon(TAUR_PENIS_ICON, secondary_state)
			secondary_icon.Blend(color_list[2], ICON_MULTIPLY)
			result_icon.Blend(secondary_icon, ICON_OVERLAY)

		result_icon.GetPixel(1, 1)
		accessory_icon_cache[cache_key] = result_icon

	var/icon/cached_icon = icon(accessory_icon_cache[cache_key])
	var/mutable_appearance/appearance = mutable_appearance(cached_icon, layer = -BODY_BEHIND_LAYER)
	appearance.pixel_x = pixel_x
	appearance.pixel_y = pixel_y
	if(!istype(owner, /mob/living/carbon/human/dummy))
		appearance.overlays += emissive_blocker(cached_icon)
	return appearance

/datum/sprite_accessory/genitals/penis/is_visible(obj/item/organ/genitals/organ, obj/item/bodypart/bodypart, mob/living/carbon/human/owner)
	draw_above_clothes = FALSE
	if(organ.visible_through_clothes)
		if(organ.visible_through_clothes == DRAW_ABOVE)
			draw_above_clothes = TRUE
		return TRUE
	return is_human_part_visible(owner, HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH)

/datum/sprite_accessory/genitals/penis/human
	icon_state = "human"
	name = "Plain"
	color_key_defaults = list(KEY_CHEST_COLOR, KEY_CHEST_COLOR)

/datum/sprite_accessory/genitals/penis/knotted
	icon_state = "knotted"
	name = "Knotted"
	color_key_defaults = list(null, KEY_CHEST_COLOR)
	default_colors = list("C52828", null)

/datum/sprite_accessory/genitals/penis/knotted2
	name = "Knotted 2"
	icon_state = "knotted2"
	color_key_defaults = list(null, KEY_CHEST_COLOR)
	default_colors = list("C52828", null)

/datum/sprite_accessory/genitals/penis/flared
	icon_state = "flared"
	name = "Flared"
	color_key_defaults = list(KEY_CHEST_COLOR, KEY_CHEST_COLOR)

/datum/sprite_accessory/genitals/penis/barbknot
	icon_state = "barbknot"
	name = "Barbed, Knotted"
	color_key_defaults = list(null, KEY_CHEST_COLOR)
	default_colors = list("C52828", null)

/datum/sprite_accessory/genitals/penis/tapered
	icon_state = "tapered"
	name = "Tapered"
	default_colors = list("C52828", "C52828")

/datum/sprite_accessory/genitals/penis/tapered_mammal
	icon_state = "tapered"
	name = "Tapered"
	color_key_defaults = list(null, KEY_CHEST_COLOR)
	default_colors = list("C52828", null)

/datum/sprite_accessory/genitals/penis/tentacle
	icon_state = "tentacle"
	name = "Tentacled"
	default_colors = list("C52828", "C52828")

/datum/sprite_accessory/genitals/penis/hemi
	icon_state = "hemi"
	name = "Hemi"
	default_colors = list("C52828", "C52828")

/datum/sprite_accessory/genitals/penis/hemiknot
	icon_state = "hemiknot"
	name = "Knotted Hemi"
	default_colors = list("C52828", "C52828")

#undef TAUR_PENIS_ICON
