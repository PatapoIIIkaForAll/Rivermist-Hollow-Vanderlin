/datum/customizer/organ/wings
	name = "Wings"
	abstract_type = /datum/customizer/organ/wings

/datum/customizer_choice/organ/wings
	name = "Wings"
	organ_type = /obj/item/organ/wings
	organ_slot = ORGAN_SLOT_WINGS
	abstract_type = /datum/customizer_choice/organ/wings

/obj/item/organ/wings/anthro
	name = "wild-kin wings"

/obj/item/organ/wings/flight/night_kin
	name = "Vampire Wings"
	accessory_type = /datum/sprite_accessory/wings/large/gargoyle

/datum/customizer/organ/wings/harpy
	customizer_choices = list(/datum/customizer_choice/organ/wings/harpy)
	allows_disabling = FALSE

/datum/customizer_choice/organ/wings/harpy
	name = "Wings"
	organ_type = /obj/item/organ/wings/flight/harpy
	allows_accessory_color_customization = TRUE
	sprite_accessories = list(
		/datum/sprite_accessory/wings/large/harpyswept,
	)

/datum/customizer/organ/wings/anthro
	customizer_choices = list(/datum/customizer_choice/organ/wings/anthro)
	allows_disabling = TRUE
	default_disabled = TRUE

/datum/customizer_choice/organ/wings/anthro
	name = "Wings"
	organ_type = /obj/item/organ/wings/anthro
	sprite_accessories = list(
		/datum/sprite_accessory/wings/bat,
		/datum/sprite_accessory/wings/feathery,
		/datum/sprite_accessory/wings/wide/succubus,
		/datum/sprite_accessory/wings/wide/dragon_alt1,
		/datum/sprite_accessory/wings/wide/dragon_alt2,
		/datum/sprite_accessory/wings/wide/harpywings,
		/datum/sprite_accessory/wings/wide/harpywingsalt1,
		/datum/sprite_accessory/wings/wide/harpywingsalt2,
		/datum/sprite_accessory/wings/wide/harpywings_top,
		/datum/sprite_accessory/wings/wide/harpywingsalt1_top,
		/datum/sprite_accessory/wings/wide/harpywingsalt2_top,
		/datum/sprite_accessory/wings/wide/low_wings,
		/datum/sprite_accessory/wings/wide/low_wings_top,
		/datum/sprite_accessory/wings/wide/spider,
		/datum/sprite_accessory/wings/huge/dragon,
		/datum/sprite_accessory/wings/huge/angel,
		/datum/sprite_accessory/wings/huge/skeleton,
		/datum/sprite_accessory/wings/large/harpyswept,
		/datum/sprite_accessory/wings/large/harpyswept_alt,
		/datum/sprite_accessory/wings/large/harpyfluff,
		/datum/sprite_accessory/wings/large/harpyfolded,
		/datum/sprite_accessory/wings/large/harpyowl,
		/datum/sprite_accessory/wings/large/harpybat_alt,
		)

/datum/customizer/organ/wings/dragonborn
	customizer_choices = list(/datum/customizer_choice/organ/wings/dragonborn)
	allows_disabling = TRUE

/datum/customizer_choice/organ/wings/dragonborn
	name = "Drake Wings"
	organ_type = /obj/item/organ/wings/flight/dragonborn
	sprite_accessories = list(
		/datum/sprite_accessory/wings/wide/dragon_alt1,
		/datum/sprite_accessory/wings/wide/dragon_alt2,
		/datum/sprite_accessory/wings/huge/dragon,
	)

/datum/customizer/organ/wings/aasimar
	customizer_choices = list(/datum/customizer_choice/organ/wings/aasimar)
	allows_disabling = TRUE

/datum/customizer_choice/organ/wings/aasimar
	name = "Wings"
	organ_type = /obj/item/organ/wings/flight/aasimar
	allows_accessory_color_customization = TRUE
	sprite_accessories = list(
		/datum/sprite_accessory/wings/huge/dragon,
		/datum/sprite_accessory/wings/huge/angel,
		/datum/sprite_accessory/wings/huge/skeleton,
		/datum/sprite_accessory/wings/huge/megamoth,
		/datum/sprite_accessory/wings/huge/mothra,
		)
