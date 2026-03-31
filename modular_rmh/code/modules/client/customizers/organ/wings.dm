/datum/customizer/organ/wings/moth
	name = "Fluvian Wings"
	allows_disabling = TRUE
	customizer_choices = list(/datum/customizer_choice/organ/wings/moth)

/datum/customizer_choice/organ/wings/moth
	name = "Fluvian Wings"
	organ_type = /obj/item/organ/wings/flight/moth
	sprite_accessories = list(
		/datum/sprite_accessory/wings/moth/plain,
		/datum/sprite_accessory/wings/moth/monarch,
		/datum/sprite_accessory/wings/moth/luna,
		/datum/sprite_accessory/wings/moth/atlas,
		/datum/sprite_accessory/wings/moth/reddish,
		/datum/sprite_accessory/wings/moth/royal,
		/datum/sprite_accessory/wings/moth/gothic,
		/datum/sprite_accessory/wings/moth/lovers,
		/datum/sprite_accessory/wings/moth/whitefly,
		/datum/sprite_accessory/wings/moth/punished,
		/datum/sprite_accessory/wings/moth/firewatch,
		/datum/sprite_accessory/wings/moth/deathhead,
		/datum/sprite_accessory/wings/moth/poison,
		/datum/sprite_accessory/wings/moth/ragged,
		/datum/sprite_accessory/wings/moth/moonfly,
		/datum/sprite_accessory/wings/moth/snow,
		/datum/sprite_accessory/wings/moth/oakworm,
		/datum/sprite_accessory/wings/moth/jungle,
		/datum/sprite_accessory/wings/moth/witchwing,
		/datum/sprite_accessory/wings/moth/rosy,
		/datum/sprite_accessory/wings/moth/featherful,
		/datum/sprite_accessory/wings/moth/brown,
		/datum/sprite_accessory/wings/moth/plasmafire,
	)

/datum/customizer/organ/wings/seelie
	name = "Seelie Wings"
	allows_disabling = FALSE
	customizer_choices = list(/datum/customizer_choice/organ/wings/seelie)

/datum/customizer_choice/organ/wings/seelie
	name = "Seelie Wings"
	organ_type = /obj/item/organ/wings/flight/seelie
	allows_accessory_color_customization = TRUE
	generic_random_pick = TRUE
	default_accessory = /datum/sprite_accessory/wings/seelie/fairy
	sprite_accessories = list(
		/datum/sprite_accessory/wings/seelie/fairy,
		/datum/sprite_accessory/wings/seelie/bee,
		/datum/sprite_accessory/wings/seelie/feathery,
		/datum/sprite_accessory/wings/seelie/feathery_dark,
		/datum/sprite_accessory/wings/seelie/feathery_dark_alt,
		/datum/sprite_accessory/wings/seelie/bat,
	)
