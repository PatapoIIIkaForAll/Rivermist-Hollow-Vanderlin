/datum/sprite_accessory/genitals/breasts
	icon = 'modular_rmh/icons/mob/sprite_accessory/genitals/breasts_anim.dmi'
	color_key_name = "Breasts"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_TOP_LAYER)
	keep_movement_states = TRUE

/datum/sprite_accessory/genitals/breasts/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = organ
	var/still_state = "[icon_state]_[breasts.get_visible_size()]"
	if(!ishuman(owner))
		return still_state
	var/mob/living/carbon/human/human_owner = owner
	var/datum/component/breast_animation/animation = human_owner.GetComponent(/datum/component/breast_animation)
	// Without a breasts child the body overlay plays the jiggle loop itself.
	if(animation?.jiggling && !animation.visual && icon_exists(get_icon(organ, bodypart, owner), "[still_state]_jiggle_ADJ"))
		return "[still_state]_jiggle"
	return still_state

/datum/sprite_accessory/genitals/breasts/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/human/owner)
	gender_genitals_adjust(appearance_list, organ, bodypart, owner, OFFSET_BREASTS)

/datum/sprite_accessory/genitals/breasts/is_visible(obj/item/organ/genitals/organ, obj/item/bodypart/bodypart, mob/living/carbon/human/owner)
	draw_above_clothes = FALSE
	//if(!organ || organ.organ_size <= BREAST_SIZE_FLAT)
	//	return FALSE
	if(organ.visible_through_clothes)
		if(organ.visible_through_clothes == DRAW_ABOVE)
			draw_above_clothes = TRUE
		return TRUE
	if(owner && owner.underwear && owner.underwear.covers_breasts)
		return FALSE

	return breasts_visible_under_clothes(owner)

/datum/sprite_accessory/genitals/breasts/pair
	icon = 'modular_rmh/icons/mob/sprite_accessory/genitals/breasts_anim.dmi'
	icon_state = "pair"
	name = "Pair"
	color_key_defaults = list(KEY_CHEST_COLOR)

// Animated sizes draw only the side views here; the vis_contents child draws the front.
/datum/sprite_accessory/genitals/breasts/pair/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	. = ..()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = organ
	if(!ishuman(owner) || !istype(breasts) || !is_animated_breast_size(breasts.get_visible_size()))
		return
	var/mob/living/carbon/human/human_owner = owner
	var/datum/component/breast_animation/animation = human_owner.GetComponent(/datum/component/breast_animation)
	if(!animation?.visual)
		return
	if(animation.jiggling && icon_exists(get_icon(organ, bodypart, owner), "[.]_jiggle_side_ADJ"))
		. += "_jiggle_side"
		return
	. += animation.running ? "_run_side" : "_side"

/datum/sprite_accessory/genitals/breasts/quad
	icon_state = "quad"
	name = "Quad"
	color_key_defaults = list(KEY_CHEST_COLOR)

/datum/sprite_accessory/genitals/breasts/sextuple
	icon_state = "sextuple"
	name = "Sextuple"
	color_key_defaults = list(KEY_CHEST_COLOR)
