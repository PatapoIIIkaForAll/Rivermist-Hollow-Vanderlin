/// Largest breast size with piercing art for pair breasts; other shapes keep the size 5 placement.
#define PIERCING_MAX_PAIR_SIZE 8
#define PIERCING_MAX_OTHER_SIZE 5

/datum/sprite_accessory/piercing
	abstract_type = /datum/sprite_accessory/piercing
	icon = 'modular_rmh/icons/mob/sprite_accessory/piercings/rings.dmi'
	color_key_name = "Piercings"
	layer = BODY_ADJ_TOP_TOP_LAYER
	// One step above breasts drawn over clothes.
	draw_above_clothes_layer = UNDER_CLOAK_LAYER + 0.01
	var/piercing_type
	/// Shape in piercings_anim.dmi drawn over the animated breasts.
	var/anim_shape = "rings"
	/// Light and dark tones of the art, used to recolour the greyscale animated sheet.
	var/anim_light = "#323232"
	var/anim_dark = "#202020"
	/// Colour matrix built from the two tones on first use.
	var/list/anim_color_matrix

/datum/sprite_accessory/piercing/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	return "[icon_state]-[get_piercing_art_size(owner?.getorganslot(ORGAN_SLOT_BREASTS))]"

/datum/sprite_accessory/piercing/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	gender_genitals_adjust(appearance_list, organ, bodypart, owner, OFFSET_BREASTS)

/datum/sprite_accessory/piercing/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	draw_above_clothes = FALSE
	if(!owner)
		return FALSE
	// The animated breasts child carries its own piercing child, so the body overlay steps aside.
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		if(human_owner.breast_animation_active())
			return FALSE
	return is_shown_on(owner, bodypart)

/// Whether the piercing shows on this body: the breasts' own clothing rule, or the chest rule without breasts.
/datum/sprite_accessory/piercing/proc/is_shown_on(mob/living/carbon/owner, obj/item/bodypart/bodypart)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = owner.getorganslot(ORGAN_SLOT_BREASTS)
	var/datum/sprite_accessory/genitals/breasts/breast_accessory = istype(breasts) ? SPRITE_ACCESSORY(breasts.accessory_type) : null
	if(istype(breast_accessory))
		if(!breast_accessory.is_visible(breasts, bodypart, owner))
			return FALSE
		draw_above_clothes = breast_accessory.draw_above_clothes
		return TRUE
	if(owner.underwear?.covers_breasts)
		return FALSE
	return is_human_part_visible(owner, HIDEBOOB)

/// Colour matrix turning the greyscale animated art (light 255, dark 128) into this piercing's two tones.
/datum/sprite_accessory/piercing/proc/get_anim_color_matrix()
	if(anim_color_matrix)
		return anim_color_matrix
	var/list/light = ReadRGB(anim_light)
	var/list/dark = ReadRGB(anim_dark)
	var/list/scale = list()
	var/list/base = list()
	for(var/channel in 1 to 3)
		var/channel_scale = (light[channel] - dark[channel]) / (255 - 128)
		scale += channel_scale
		base += (light[channel] - channel_scale * 255) / 255
	anim_color_matrix = list(scale[1], 0, 0, 0, scale[2], 0, 0, 0, scale[3], base[1], base[2], base[3])
	return anim_color_matrix

/// Art size for a breasts organ: its visible size, capped by the art drawn for its shape.
/proc/get_piercing_art_size(obj/item/organ/genitals/filling_organ/breasts/breasts)
	if(!istype(breasts))
		return 1
	var/max_size = ispath(breasts.accessory_type, /datum/sprite_accessory/genitals/breasts/pair) ? PIERCING_MAX_PAIR_SIZE : PIERCING_MAX_OTHER_SIZE
	return clamp(breasts.get_visible_size(), 1, max_size)

/datum/sprite_accessory/piercing/rings
	icon = 'modular_rmh/icons/mob/sprite_accessory/piercings/rings.dmi'
	name = "rings"
	icon_state = "rings"
	piercing_type = /obj/item/piercings/rings

/datum/sprite_accessory/piercing/rings/emerald
	name = "emerald rings"
	icon_state = "rings-e"
	piercing_type = /obj/item/piercings/rings/emerald
	anim_light = "#287051"
	anim_dark = "#1e523c"

/datum/sprite_accessory/piercing/rings/gold
	name = "gold rings"
	icon_state = "rings-g"
	piercing_type = /obj/item/piercings/rings/gold
	anim_light = "#ffc90e"
	anim_dark = "#e8b70c"

/datum/sprite_accessory/piercing/rings/silver
	name = "silver rings"
	icon_state = "rings-s"
	piercing_type = /obj/item/piercings/rings/silver
	anim_light = "#c0d2df"
	anim_dark = "#acbdc8"

/datum/sprite_accessory/piercing/rings/tag
	icon = 'modular_rmh/icons/mob/sprite_accessory/piercings/beads.dmi'
	name = "nipple tag"
	icon_state = "beads-tag"
	piercing_type = /obj/item/piercings/beads/tag
	anim_shape = "tag"

/datum/sprite_accessory/piercing/beads
	icon = 'modular_rmh/icons/mob/sprite_accessory/piercings/beads.dmi'
	name = "beads"
	icon_state = "beads"
	piercing_type = /obj/item/piercings/beads
	anim_shape = "beads"

/datum/sprite_accessory/piercing/beads/emerald
	name = "emerald beads"
	icon_state = "beads-e"
	piercing_type = /obj/item/piercings/beads/emerald
	anim_light = "#287051"
	anim_dark = "#1e523c"

/datum/sprite_accessory/piercing/beads/gold
	name = "gold beads"
	icon_state = "beads-g"
	piercing_type = /obj/item/piercings/beads/gold
	anim_light = "#ffc90e"
	anim_dark = "#e8b70c"

/datum/sprite_accessory/piercing/beads/silver
	name = "silver beads"
	icon_state = "beads-s"
	piercing_type = /obj/item/piercings/beads/silver
	anim_light = "#c0d2df"
	anim_dark = "#acbdc8"

#undef PIERCING_MAX_PAIR_SIZE
#undef PIERCING_MAX_OTHER_SIZE
