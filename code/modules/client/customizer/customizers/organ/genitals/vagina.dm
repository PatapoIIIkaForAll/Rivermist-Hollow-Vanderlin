/datum/customizer/organ/genitals/vagina
	abstract_type = /datum/customizer/organ/genitals/vagina
	name = "Vagina"
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = FEMALE
	abstract_type = /datum/customizer/organ/genitals/vagina

/datum/customizer/organ/genitals/vagina/is_allowed(datum/preferences/prefs)
	return TRUE

/datum/customizer_choice/organ/genitals/vagina
	abstract_type = /datum/customizer_choice/organ/genitals/vagina
	name = "Vagina"
	customizer_entry_type = /datum/customizer_entry/organ/genitals/vagina
	organ_type = /obj/item/organ/genitals/filling_organ/vagina
	organ_slot = ORGAN_SLOT_VAGINA
	organ_dna_type = /datum/organ_dna/vagina

/datum/customizer_entry/organ/genitals/vagina
	/// Older saves kept fertility here; the womb entry copies it once and owns it from then on.
	var/fertility = TRUE

/datum/customizer/organ/genitals/vagina/human
	customizer_choices = list(/datum/customizer_choice/organ/genitals/vagina/human)

/datum/customizer_choice/organ/genitals/vagina/human
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/vagina/human,
		/datum/sprite_accessory/genitals/vagina/gaping,
		)
	allows_accessory_color_customization = FALSE

/datum/customizer/organ/genitals/vagina/human_anthro
	customizer_choices = list(/datum/customizer_choice/organ/genitals/vagina/human_anthro)

/datum/customizer_choice/organ/genitals/vagina/human_anthro
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/vagina/human,
		/datum/sprite_accessory/genitals/vagina/gaping,
		)
	allows_accessory_color_customization = TRUE

/datum/customizer/organ/genitals/vagina/animal
	customizer_choices = list(/datum/customizer_choice/organ/genitals/vagina/animal)

/datum/customizer_choice/organ/genitals/vagina/animal
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/vagina/human,
		/datum/sprite_accessory/genitals/vagina/gaping,
		/datum/sprite_accessory/genitals/vagina/spade,
		)

/datum/customizer/organ/genitals/vagina/anthro
	customizer_choices = list(/datum/customizer_choice/organ/genitals/vagina/anthro)

/datum/customizer_choice/organ/genitals/vagina/anthro
	sprite_accessories = list(
		/datum/sprite_accessory/genitals/vagina/human,
		/datum/sprite_accessory/genitals/vagina/gaping,
		/datum/sprite_accessory/genitals/vagina/spade,
		/datum/sprite_accessory/genitals/vagina/cloaca,
		)
