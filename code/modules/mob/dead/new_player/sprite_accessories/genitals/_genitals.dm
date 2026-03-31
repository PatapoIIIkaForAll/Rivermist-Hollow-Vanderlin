#define TAUR_GENITAL_ICON_OFFSET_X -14

/datum/sprite_accessory/genitals
	abstract_type = /datum/sprite_accessory/genitals

/datum/sprite_accessory/genitals/proc/is_taur_owner(mob/living/carbon/owner)
	return iscarbon(owner) && owner.get_taur_tail()

/datum/sprite_accessory/genitals/proc/shift_for_taur(list/appearance_list)
	for(var/mutable_appearance/appearance as anything in appearance_list)
		appearance.pixel_x += TAUR_GENITAL_ICON_OFFSET_X

#undef TAUR_GENITAL_ICON_OFFSET_X
