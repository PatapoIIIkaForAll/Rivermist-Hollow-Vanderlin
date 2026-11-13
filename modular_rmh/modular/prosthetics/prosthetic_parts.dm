// Prosthetic parts the window fits: material tints, bronze legs, and the artificial eyes and organs.

/obj/item/bodypart
	/// Material colour a prosthetic limb is drawn in on the body. Null draws the sheet as it is.
	var/prosthetic_tint
	/// Id of the Prosthetics window option that fitted this part, so a preview can undo it.
	var/prosthetic_option_id

/obj/item/organ
	/// Id of the Prosthetics window option that fitted this organ, so a preview can undo it.
	var/prosthetic_option_id

/// Colour matrix that greys a sprite by brightness, then paints it in hex, brightened by gain.
/proc/prosthetic_tint_matrix(hex, gain = 2.6)
	var/list/rgb = ReadRGB(hex)
	if(length(rgb) < 3)
		return null
	var/red = rgb[1] / 255 * gain
	var/green = rgb[2] / 255 * gain
	var/blue = rgb[3] / 255 * gain
	return list(
		0.299 * red, 0.299 * green, 0.299 * blue,
		0.587 * red, 0.587 * green, 0.587 * blue,
		0.114 * red, 0.114 * green, 0.114 * blue,
		0, 0, 0,
	)

/obj/item/bodypart/l_arm/prosthetic/iron
	prosthetic_tint = "#8a8f96"
/obj/item/bodypart/r_arm/prosthetic/iron
	prosthetic_tint = "#8a8f96"
/obj/item/bodypart/l_leg/prosthetic/iron
	prosthetic_tint = "#8a8f96"
/obj/item/bodypart/r_leg/prosthetic/iron
	prosthetic_tint = "#8a8f96"

/obj/item/bodypart/l_arm/prosthetic/steel
	prosthetic_tint = "#c9d1d9"
/obj/item/bodypart/r_arm/prosthetic/steel
	prosthetic_tint = "#c9d1d9"
/obj/item/bodypart/l_leg/prosthetic/steel
	prosthetic_tint = "#c9d1d9"
/obj/item/bodypart/r_leg/prosthetic/steel
	prosthetic_tint = "#c9d1d9"

/obj/item/bodypart/l_arm/prosthetic/gold
	prosthetic_tint = "#e2b84a"
/obj/item/bodypart/r_arm/prosthetic/gold
	prosthetic_tint = "#e2b84a"
/obj/item/bodypart/l_leg/prosthetic/gold
	prosthetic_tint = "#e2b84a"
/obj/item/bodypart/r_leg/prosthetic/gold
	prosthetic_tint = "#e2b84a"

/obj/item/bodypart/l_arm/prosthetic/bronze
	prosthetic_tint = "#c0843f"
/obj/item/bodypart/r_arm/prosthetic/bronze
	prosthetic_tint = "#c0843f"

/obj/item/bodypart/l_leg/prosthetic/bronze
	name = "bronze left leg"
	desc = "A bronze left leg."
	icon_state = "bpleg"
	resistance_flags = FIRE_PROOF
	w_class = WEIGHT_CLASS_NORMAL
	max_damage = 170
	max_integrity = 350
	sellprice = 40
	anvilrepair = /datum/attribute/skill/craft/engineering
	smeltresult = /obj/item/ingot/bronze
	prosthetic_tint = "#c0843f"

/obj/item/bodypart/r_leg/prosthetic/bronze
	name = "bronze right leg"
	desc = "A bronze right leg."
	icon_state = "bpleg"
	resistance_flags = FIRE_PROOF
	w_class = WEIGHT_CLASS_NORMAL
	max_damage = 170
	max_integrity = 350
	sellprice = 40
	anvilrepair = /datum/attribute/skill/craft/engineering
	smeltresult = /obj/item/ingot/bronze
	prosthetic_tint = "#c0843f"

/datum/artificer_recipe/prosthetics/bronze/leg_left
	name = "Bronze Left Leg (+2 Cogs)"
	created_item = /obj/item/bodypart/l_leg/prosthetic/bronze

/datum/artificer_recipe/prosthetics/bronze/leg_right
	name = "Bronze Right Leg (+2 Cogs)"
	created_item = /obj/item/bodypart/r_leg/prosthetic/bronze

// ---- Eyes ----

/obj/item/organ/eyes/prosthetic
	abstract_type = /obj/item/organ/eyes/prosthetic
	organ_flags = ORGAN_ROBOTIC
	blood_req = 0
	oxygen_req = 0
	nutriment_req = 0
	hydration_req = 0
	healing_factor = 0

/obj/item/organ/eyes/left/prosthetic
	abstract_type = /obj/item/organ/eyes/left/prosthetic
	organ_flags = ORGAN_ROBOTIC
	blood_req = 0
	oxygen_req = 0
	nutriment_req = 0
	hydration_req = 0
	healing_factor = 0

/obj/item/organ/eyes/prosthetic/glass
	name = "glass eye"
	desc = "A glass eye. It cannot see."
/obj/item/organ/eyes/left/prosthetic/glass
	name = "glass eye"
	desc = "A glass eye. It cannot see."

/obj/item/organ/eyes/prosthetic/lens
	name = "artificer's lens"
	desc = "An artificial eye that sees."
/obj/item/organ/eyes/left/prosthetic/lens
	name = "artificer's lens"
	desc = "An artificial eye that sees."

/obj/item/organ/eyes/prosthetic/gem
	name = "gem eye"
	desc = "A gem eye. It glows and sees in the dark."
	glows = TRUE
	see_in_dark = 12
/obj/item/organ/eyes/left/prosthetic/gem
	name = "gem eye"
	desc = "A gem eye. It glows and sees in the dark."
	glows = TRUE
	see_in_dark = 12

/// The blind-spot trait for the side a glass eye sits on.
/obj/item/organ/eyes/proc/glass_eye_trait()
	return side == LEFT_SIDE ? TRAIT_CYCLOPS_LEFT : TRAIT_CYCLOPS_RIGHT

/obj/item/organ/eyes/prosthetic/glass/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, new_zone = null)
	. = ..()
	ADD_TRAIT(M, glass_eye_trait(), REF(src))
	M.update_fov_angles()

/obj/item/organ/eyes/prosthetic/glass/Remove(mob/living/carbon/M, special = 0)
	REMOVE_TRAIT(M, glass_eye_trait(), REF(src))
	. = ..()
	M.update_fov_angles()

/obj/item/organ/eyes/left/prosthetic/glass/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, new_zone = null)
	. = ..()
	ADD_TRAIT(M, glass_eye_trait(), REF(src))
	M.update_fov_angles()

/obj/item/organ/eyes/left/prosthetic/glass/Remove(mob/living/carbon/M, special = 0)
	REMOVE_TRAIT(M, glass_eye_trait(), REF(src))
	. = ..()
	M.update_fov_angles()

// ---- Organs ----

/obj/item/organ/heart/prosthetic
	abstract_type = /obj/item/organ/heart/prosthetic
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/heart/prosthetic/clockwork
	name = "clockwork heart"
	desc = "An artificial heart. It ticks."
	blood_req = 0
	oxygen_req = 0
	healing_factor = 0
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/lungs/prosthetic
	abstract_type = /obj/item/organ/lungs/prosthetic
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/lungs/prosthetic/bellows
	name = "bellows lungs"
	desc = "Artificial lungs. They wheeze."
	blood_req = 0
	oxygen_req = 0
	healing_factor = 0
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/tongue/prosthetic
	abstract_type = /obj/item/organ/tongue/prosthetic
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/tongue/prosthetic/silver
	name = "silver tongue"
	desc = "An artificial tongue. It cannot taste."

/obj/item/organ/tongue/prosthetic/silver/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, new_zone = null)
	. = ..()
	ADD_TRAIT(M, TRAIT_AGEUSIA, REF(src))

/obj/item/organ/tongue/prosthetic/silver/Remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(M, TRAIT_AGEUSIA, REF(src))
	return ..()

// Each wooden limb turns into the matching iron limb in the metalizer, not always a left arm.
/obj/item/bodypart/r_arm/prosthetic/wood
	metalizer_result = /obj/item/bodypart/r_arm/prosthetic/iron
/obj/item/bodypart/l_leg/prosthetic/wood
	metalizer_result = /obj/item/bodypart/l_leg/prosthetic/iron
/obj/item/bodypart/r_leg/prosthetic/wood
	metalizer_result = /obj/item/bodypart/r_leg/prosthetic/iron
