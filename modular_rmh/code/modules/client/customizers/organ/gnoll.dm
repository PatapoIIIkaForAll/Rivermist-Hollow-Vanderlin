/datum/customizer/organ/ears/gnoll
	name = "Gnoll Ears"
	allows_disabling = FALSE
	customizer_choices = list(/datum/customizer_choice/organ/ears/gnoll)

/datum/customizer_choice/organ/ears/gnoll
	name = "Gnoll Ears"
	organ_type = /obj/item/organ/ears/anthro
	allows_accessory_color_customization = TRUE
	generic_random_pick = TRUE
	default_accessory = /datum/sprite_accessory/ears/bigwolf_inner
	sprite_accessories = list(
		/datum/sprite_accessory/ears/bigwolf,
		/datum/sprite_accessory/ears/bigwolf_inner,
		/datum/sprite_accessory/ears/husky,
		/datum/sprite_accessory/ears/lab,
		/datum/sprite_accessory/ears/perky,
		/datum/sprite_accessory/ears/wolf,
	)

/datum/customizer/organ/snout/gnoll
	name = "Gnoll Snout"
	allows_disabling = FALSE
	customizer_choices = list(/datum/customizer_choice/organ/snout/gnoll)

/datum/customizer_choice/organ/snout/gnoll
	name = "Gnoll Snout"
	organ_type = /obj/item/organ/snout/anthro
	allows_accessory_color_customization = TRUE
	generic_random_pick = TRUE
	default_accessory = /datum/sprite_accessory/snout/hspots
	sprite_accessories = list(
		/datum/sprite_accessory/snout/hspots,
		/datum/sprite_accessory/snout/hjackal,
		/datum/sprite_accessory/snout/lcanid,
		/datum/sprite_accessory/snout/lcanidalt,
		/datum/sprite_accessory/snout/scanid,
		/datum/sprite_accessory/snout/scanidalt3,
		/datum/sprite_accessory/snout/wolf,
		/datum/sprite_accessory/snout/wolfalt,
	)

/datum/customizer/organ/tail/gnoll
	name = "Gnoll Tail"
	allows_disabling = FALSE
	customizer_choices = list(/datum/customizer_choice/organ/tail/gnoll)

/datum/customizer_choice/organ/tail/gnoll
	name = "Gnoll Tail"
	organ_type = /obj/item/organ/tail/anthro
	allows_accessory_color_customization = TRUE
	generic_random_pick = TRUE
	default_accessory = /datum/sprite_accessory/tail/jackal
	sprite_accessories = list(
		/datum/sprite_accessory/tail/australian_shepherd,
		/datum/sprite_accessory/tail/husky,
		/datum/sprite_accessory/tail/jackal,
		/datum/sprite_accessory/tail/straighttail,
		/datum/sprite_accessory/tail/wolf,
	)
