#define TAUR_TESTICLES_ICON 'modular_rmh/icons/mob/sprite_accessory/genitals/taur_testicles_onmob.dmi'
#define TAUR_TESTICLES_OFFSET_X -2

/datum/sprite_accessory/genitals/testicles
	icon = 'icons/mob/sprite_accessory/genitals/gonads.dmi'
	color_key_name = "Sack"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER)
	abstract_type = /datum/sprite_accessory/genitals/testicles

/datum/sprite_accessory/genitals/testicles/get_appearance(obj/item/organ/organ, obj/item/bodypart/bodypart, color_string)
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

	var/list/appearance_list = list(build_taur_testicles_appearance(taur_icon_state, color_string, owner))
	adjust_appearance_list(appearance_list, organ, bodypart, owner)
	shift_for_taur(appearance_list)
	for(var/mutable_appearance/appearance as anything in appearance_list)
		appearance.pixel_x += TAUR_TESTICLES_OFFSET_X
	return appearance_list

/datum/sprite_accessory/genitals/testicles/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/genitals/filling_organ/testicles/testes = organ
	var/fuck = "[icon_state]_[testes.organ_size]"
	return fuck

/datum/sprite_accessory/genitals/testicles/proc/get_taur_icon_state(obj/item/organ/organ, mob/living/carbon/owner)
	if(!is_taur_owner(owner) || !istype(organ, /obj/item/organ/genitals/filling_organ/testicles))
		return null
	if(icon_state != "pair")
		return null

	var/obj/item/organ/genitals/filling_organ/testicles/testes = organ
	return "m_testicles_pair_[testes.organ_size]_FRONT"

/datum/sprite_accessory/genitals/testicles/proc/build_taur_testicles_appearance(taur_icon_state, color_string, mob/living/carbon/owner)
	color_string = sanitize_color_string(color_string)
	var/cache_key = "[type]-taur-[taur_icon_state]-[color_string]"
	if(!accessory_icon_cache[cache_key])
		var/list/color_list = color_string_to_list(color_string)
		var/icon/result_icon = icon(TAUR_TESTICLES_ICON, taur_icon_state)
		result_icon.Blend(color_list[1], ICON_MULTIPLY)
		result_icon.GetPixel(1, 1)
		accessory_icon_cache[cache_key] = result_icon

	var/icon/cached_icon = icon(accessory_icon_cache[cache_key])
	var/mutable_appearance/appearance = mutable_appearance(cached_icon, layer = -BODY_ADJ_LAYER)
	appearance.pixel_x = pixel_x
	appearance.pixel_y = pixel_y
	if(!istype(owner, /mob/living/carbon/human/dummy))
		appearance.overlays += emissive_blocker(cached_icon)
	return appearance

/datum/sprite_accessory/genitals/testicles/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	gender_genitals_adjust(appearance_list, organ, bodypart, owner, OFFSET_TESTICLES)

/datum/sprite_accessory/genitals/testicles/is_visible(obj/item/organ/genitals/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	draw_above_clothes = FALSE
	if(organ.visible_through_clothes)
		if(organ.visible_through_clothes == DRAW_ABOVE)
			draw_above_clothes = TRUE
		return TRUE
	if(owner)
		var/obj/item/organ/genitals/penis/penis = owner.getorganslot(ORGAN_SLOT_PENIS)
		if(penis && penis.sheath_type == SHEATH_TYPE_SLIT)
			return FALSE
		return is_human_part_visible(owner, HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH)
	else
		return FALSE

/datum/sprite_accessory/genitals/testicles/pair
	name = "Pair"
	icon_state = "pair"
	color_key_defaults = list(KEY_SKIN_COLOR)

#undef TAUR_TESTICLES_ICON
#undef TAUR_TESTICLES_OFFSET_X
