// Catalog of the Prosthetics window: slots and the options each one offers.

/// Slot id = list(kind, display name, side). Ordered for the window and examine.
GLOBAL_LIST_INIT(prosthetic_slots, list(
	PROSTHETIC_SLOT_L_EYE = list("kind" = PROSTHETIC_KIND_EYE, "name" = "Left eye"),
	PROSTHETIC_SLOT_R_EYE = list("kind" = PROSTHETIC_KIND_EYE, "name" = "Right eye"),
	PROSTHETIC_SLOT_TONGUE = list("kind" = PROSTHETIC_KIND_TONGUE, "name" = "Tongue", "organ" = ORGAN_SLOT_TONGUE),
	PROSTHETIC_SLOT_HEART = list("kind" = PROSTHETIC_KIND_HEART, "name" = "Heart", "organ" = ORGAN_SLOT_HEART),
	PROSTHETIC_SLOT_LUNGS = list("kind" = PROSTHETIC_KIND_LUNGS, "name" = "Lungs", "organ" = ORGAN_SLOT_LUNGS),
	PROSTHETIC_SLOT_L_ARM = list("kind" = PROSTHETIC_KIND_ARM, "name" = "Left arm"),
	PROSTHETIC_SLOT_R_ARM = list("kind" = PROSTHETIC_KIND_ARM, "name" = "Right arm"),
	PROSTHETIC_SLOT_L_LEG = list("kind" = PROSTHETIC_KIND_LEG, "name" = "Left leg"),
	PROSTHETIC_SLOT_R_LEG = list("kind" = PROSTHETIC_KIND_LEG, "name" = "Right leg"),
))

/// Option id = option datum, built once.
GLOBAL_LIST_INIT(prosthetic_options, build_prosthetic_options())

/proc/build_prosthetic_options()
	. = list()
	for(var/datum/prosthetic_option/option_type as anything in subtypesof(/datum/prosthetic_option))
		if(initial(option_type.abstract_type) == option_type)
			continue
		var/datum/prosthetic_option/option = new option_type()
		.[option.id] = option

/proc/prosthetic_slot_kind(slot)
	var/list/slot_data = GLOB.prosthetic_slots[slot]
	return slot_data?["kind"]

/// The option datum for an id when it fits the slot, else null.
/proc/prosthetic_option_for(slot, option_id)
	var/datum/prosthetic_option/option = GLOB.prosthetic_options[option_id]
	if(!option || !(prosthetic_slot_kind(slot) in option.kinds))
		return null
	return option

/datum/prosthetic_option
	abstract_type = /datum/prosthetic_option
	/// Unique id, saved in the character file
	var/id
	var/name
	var/desc
	/// Slot kinds this option fits
	var/list/kinds = list()
	/// Quirk point value, same sign as quirks: positive gives points, negative costs them.
	var/point_value = 0
	/// Removes the part instead of replacing it
	var/missing = FALSE
	/// Swatch and schematic colour
	var/tint = "#8a8f96"
	/// Short stat bars for the window: name = 0 to 5
	var/list/stats = list()
	/// Slot = path of the part that replaces the natural one
	var/list/part_types = list()

/datum/prosthetic_option/proc/get_part_type(slot)
	return part_types[slot]

// ---- Limbs ----

/datum/prosthetic_option/limb
	abstract_type = /datum/prosthetic_option/limb
	kinds = list(PROSTHETIC_KIND_ARM, PROSTHETIC_KIND_LEG)

/datum/prosthetic_option/limb/missing
	id = "limb_missing"
	name = "Missing"
	desc = "No limb. A prosthetic can be fitted later."
	point_value = 5
	missing = TRUE
	tint = "#3a2a24"

/datum/prosthetic_option/limb/wood
	id = "limb_wood"
	name = "Wood"
	desc = "Cheap and light. Weak, and it burns."
	point_value = 3
	tint = "#9b6b43"
	stats = list("Grip" = 1, "Sturdiness" = 1, "Weight" = 1)
	part_types = list(
		PROSTHETIC_SLOT_L_ARM = /obj/item/bodypart/l_arm/prosthetic/wood,
		PROSTHETIC_SLOT_R_ARM = /obj/item/bodypart/r_arm/prosthetic/wood,
		PROSTHETIC_SLOT_L_LEG = /obj/item/bodypart/l_leg/prosthetic/wood,
		PROSTHETIC_SLOT_R_LEG = /obj/item/bodypart/r_leg/prosthetic/wood,
	)

/datum/prosthetic_option/limb/iron
	id = "limb_iron"
	name = "Iron"
	desc = "Hits harder than a hand. Does not burn."
	point_value = -1
	tint = "#8a8f96"
	stats = list("Grip" = 3, "Sturdiness" = 3, "Weight" = 4)
	part_types = list(
		PROSTHETIC_SLOT_L_ARM = /obj/item/bodypart/l_arm/prosthetic/iron,
		PROSTHETIC_SLOT_R_ARM = /obj/item/bodypart/r_arm/prosthetic/iron,
		PROSTHETIC_SLOT_L_LEG = /obj/item/bodypart/l_leg/prosthetic/iron,
		PROSTHETIC_SLOT_R_LEG = /obj/item/bodypart/r_leg/prosthetic/iron,
	)

/datum/prosthetic_option/limb/steel
	id = "limb_steel"
	name = "Steel"
	desc = "The hardest punch and the toughest limb."
	point_value = -2
	tint = "#c9d1d9"
	stats = list("Grip" = 4, "Sturdiness" = 5, "Weight" = 4)
	part_types = list(
		PROSTHETIC_SLOT_L_ARM = /obj/item/bodypart/l_arm/prosthetic/steel,
		PROSTHETIC_SLOT_R_ARM = /obj/item/bodypart/r_arm/prosthetic/steel,
		PROSTHETIC_SLOT_L_LEG = /obj/item/bodypart/l_leg/prosthetic/steel,
		PROSTHETIC_SLOT_R_LEG = /obj/item/bodypart/r_leg/prosthetic/steel,
	)

/datum/prosthetic_option/limb/bronze
	id = "limb_bronze"
	name = "Bronze"
	desc = "Tough and nimble. Does not burn."
	point_value = -2
	tint = "#b07a3c"
	stats = list("Grip" = 4, "Sturdiness" = 4, "Weight" = 3)
	part_types = list(
		PROSTHETIC_SLOT_L_ARM = /obj/item/bodypart/l_arm/prosthetic/bronze,
		PROSTHETIC_SLOT_R_ARM = /obj/item/bodypart/r_arm/prosthetic/bronze,
		PROSTHETIC_SLOT_L_LEG = /obj/item/bodypart/l_leg/prosthetic/bronze,
		PROSTHETIC_SLOT_R_LEG = /obj/item/bodypart/r_leg/prosthetic/bronze,
	)

/datum/prosthetic_option/limb/gold
	id = "limb_gold"
	name = "Gold"
	desc = "Weaker than iron. Looks expensive."
	point_value = -2
	tint = "#d8b04a"
	stats = list("Grip" = 3, "Sturdiness" = 2, "Weight" = 3)
	part_types = list(
		PROSTHETIC_SLOT_L_ARM = /obj/item/bodypart/l_arm/prosthetic/gold,
		PROSTHETIC_SLOT_R_ARM = /obj/item/bodypart/r_arm/prosthetic/gold,
		PROSTHETIC_SLOT_L_LEG = /obj/item/bodypart/l_leg/prosthetic/gold,
		PROSTHETIC_SLOT_R_LEG = /obj/item/bodypart/r_leg/prosthetic/gold,
	)

// ---- Eyes ----

/datum/prosthetic_option/eye
	abstract_type = /datum/prosthetic_option/eye
	kinds = list(PROSTHETIC_KIND_EYE)

/datum/prosthetic_option/eye/missing
	id = "eye_missing"
	name = "Missing"
	desc = "No eye. You wear an eyepatch and have a blind spot on that side."
	point_value = 2
	missing = TRUE
	tint = "#2a2220"

/datum/prosthetic_option/eye/glass
	id = "eye_glass"
	name = "Glass eye"
	desc = "Looks like your eye. Sees nothing, so you have a blind spot on that side."
	point_value = 2
	tint = "#9fc6d6"
	stats = list("Sight" = 0, "Darkness" = 0)
	part_types = list(
		PROSTHETIC_SLOT_L_EYE = /obj/item/organ/eyes/left/prosthetic/glass,
		PROSTHETIC_SLOT_R_EYE = /obj/item/organ/eyes/prosthetic/glass,
	)

/datum/prosthetic_option/eye/lens
	id = "eye_lens"
	name = "Artificer's lens"
	desc = "Sees like a normal eye."
	tint = "#b07a3c"
	stats = list("Sight" = 3, "Darkness" = 2)
	part_types = list(
		PROSTHETIC_SLOT_L_EYE = /obj/item/organ/eyes/left/prosthetic/lens,
		PROSTHETIC_SLOT_R_EYE = /obj/item/organ/eyes/prosthetic/lens,
	)

/datum/prosthetic_option/eye/gem
	id = "eye_gem"
	name = "Gem eye"
	desc = "Glows in your eye colour. Sees in the dark."
	point_value = -1
	tint = "#b46bff"
	stats = list("Sight" = 3, "Darkness" = 4)
	part_types = list(
		PROSTHETIC_SLOT_L_EYE = /obj/item/organ/eyes/left/prosthetic/gem,
		PROSTHETIC_SLOT_R_EYE = /obj/item/organ/eyes/prosthetic/gem,
	)

// ---- Organs ----

/datum/prosthetic_option/heart
	id = "heart_clockwork"
	name = "Clockwork heart"
	desc = "Works with low blood and takes more damage before it fails."
	kinds = list(PROSTHETIC_KIND_HEART)
	point_value = -2
	tint = "#b07a3c"
	stats = list("Toughness" = 4, "Blood loss" = 4)
	part_types = list(PROSTHETIC_SLOT_HEART = /obj/item/organ/heart/prosthetic/clockwork)

/datum/prosthetic_option/lungs
	id = "lungs_bellows"
	name = "Bellows lungs"
	desc = "Need little air and take more damage before they fail."
	kinds = list(PROSTHETIC_KIND_LUNGS)
	point_value = -1
	tint = "#7a5a3c"
	stats = list("Toughness" = 4, "Air need" = 2)
	part_types = list(PROSTHETIC_SLOT_LUNGS = /obj/item/organ/lungs/prosthetic/bellows)

/datum/prosthetic_option/tongue
	id = "tongue_silver"
	name = "Silver tongue"
	desc = "You can speak, but you cannot taste."
	kinds = list(PROSTHETIC_KIND_TONGUE)
	point_value = 1
	tint = "#c9d1d9"
	stats = list("Speech" = 3, "Taste" = 0)
	part_types = list(PROSTHETIC_SLOT_TONGUE = /obj/item/organ/tongue/prosthetic/silver)
