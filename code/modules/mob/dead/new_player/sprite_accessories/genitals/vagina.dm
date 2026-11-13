/datum/sprite_accessory/genitals/vagina
	icon = 'modular_rmh/icons/mob/sprite_accessory/genitals/nethers.dmi'
	color_key_name = "Nethers"
	relevant_layers = list(BODY_ADJ_LOW_LAYER)

/datum/sprite_accessory/genitals/vagina/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	gender_genitals_adjust(appearance_list, organ, bodypart, owner, OFFSET_VAGINA)

/datum/sprite_accessory/genitals/vagina/is_visible(obj/item/organ/genitals/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	draw_above_clothes = FALSE
	if(owner?.underwear?.hides_organ_slot(organ.slot))
		return FALSE
	if(organ.visible_through_clothes)
		if(organ.visible_through_clothes == DRAW_ABOVE)
			draw_above_clothes = TRUE
		return TRUE
	return is_human_part_visible(owner, HIDEJUMPSUIT|HIDEUNDIESBOT)

/// A gaping vagina draws the gaping state when the sheet has it; layered states carry the layer suffix.
/datum/sprite_accessory/genitals/vagina/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/genitals/filling_organ/hole = organ
	if(istype(hole) && hole.orifice?.gaped && icon_exists(get_icon(organ, bodypart, owner), "gaping_[get_layer_suffix(BODY_ADJ_LOW_LAYER)]"))
		return "gaping"
	return ..()

/datum/sprite_accessory/genitals/vagina/human
	icon_state = "human"
	name = "Plain"
	default_colors = list("ea6767")

/datum/sprite_accessory/genitals/vagina/hairy
	icon_state = "hairy"
	name = "Hairy"
	color_key_defaults = list(KEY_HAIR_COLOR)

/datum/sprite_accessory/genitals/vagina/trimmed
	icon_state = "trimmed"
	name = "Trimmed"
	color_key_defaults = list(KEY_HAIR_COLOR)

/datum/sprite_accessory/genitals/vagina/spade
	icon_state = "spade"
	name = "Spade"
	default_colors = list("C52828")

/datum/sprite_accessory/genitals/vagina/furred
	icon_state = "furred"
	name = "Furred"
	color_key_defaults = list(KEY_MUT_COLOR_ONE)

/datum/sprite_accessory/genitals/vagina/gaping
	icon_state = "gaping"
	name = "Gaping"
	default_colors = list("f99696")

/datum/sprite_accessory/genitals/vagina/cloaca
	icon_state = "cloaca"
	name = "Cloaca"
	default_colors = list("f99696")
