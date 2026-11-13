// Body sprite, clothing cut and offsets; without a build each proc keeps the old species rules.

/// The build this mob renders on, or null when its species offers none.
/mob/living/carbon/proc/get_body_build()
	var/datum/species/species = dna?.species
	if(!length(species?.allowed_body_builds))
		return null
	var/build_id = dna.features?["body_build"]
	if(!species.is_body_build_valid(build_id, gender))
		build_id = species.get_default_body_build(gender)
	return GLOB.body_builds[build_id]

/// Limb sprite sheet for this mob's body.
/mob/living/carbon/proc/get_limbs_icon()
	var/datum/species/species = dna?.species
	if(!species)
		return null
	var/datum/body_build/build = get_body_build()
	if(build)
		return build.get_limbs_icon(gender, species.body_build_palette)
	return (gender == MALE) ? species.limbs_icon_m : species.limbs_icon_f

/// BODY_CUT_* clothing cut this mob wears.
/mob/living/carbon/proc/get_body_cut()
	var/datum/body_build/build = get_body_build()
	if(build)
		return build.get_cut(gender)
	var/datum/species/species = dna?.species
	if(!species?.sexes)
		return BODY_CUT_MASCULINE
	if(gender == FEMALE)
		return species.swap_female_clothes ? BODY_CUT_MASCULINE : BODY_CUT_FEMININE
	if(gender == MALE)
		if(species.swap_male_clothes)
			return BODY_CUT_FEMININE
		if(species.swap_male_clothes_but_not_offsets)
			return BODY_CUT_MIXED
	return BODY_CUT_MASCULINE

/// Sprite set for ordinary worn slots, MALE_SPRITES or FEMALE_SPRITES.
/mob/living/carbon/proc/get_worn_cut()
	return (get_body_cut() == BODY_CUT_MASCULINE) ? MALE_SPRITES : FEMALE_SPRITES

/// Sprite set for torso garments; FEMALE_BOOB adds the chest overlay on feminine women.
/mob/living/carbon/proc/get_torso_cut(hideboob = FALSE)
	if(get_body_cut() != BODY_CUT_FEMININE)
		return MALE_SPRITES
	if(gender == FEMALE && !hideboob)
		return FEMALE_BOOB
	return FEMALE_SPRITES

/// Whether sleeve overlays use the feminine "_f" set.
/mob/living/carbon/proc/uses_feminine_sleeves()
	if(get_body_build())
		return get_body_cut() == BODY_CUT_FEMININE && gender == FEMALE
	return (gender == FEMALE) ^ !!dna?.species?.swap_female_clothes

/// OFFSET_* table for worn items and features.
/mob/living/carbon/proc/get_offset_features()
	var/datum/body_build/build = get_body_build()
	if(build)
		return build.get_offsets(gender)
	var/datum/species/species = dna?.species
	if(!species)
		return null
	return (get_body_cut() == BODY_CUT_FEMININE) ? species.offset_features_f : species.offset_features_m

/// OFFSET_* table for genital overlays.
/mob/living/carbon/proc/get_genital_offsets()
	var/datum/body_build/build = get_body_build()
	if(build)
		return build.get_genital_offsets(gender)
	var/datum/species/species = dna?.species
	if(!species)
		return null
	return (get_body_cut() == BODY_CUT_FEMININE) ? species.offset_genitals_f : species.offset_genitals_m

/// Damage overlay sheet matching this mob's body.
/mob/living/carbon/proc/get_damage_icon()
	var/datum/body_build/build = get_body_build()
	if(build)
		return build.get_dam_icon(gender)
	var/datum/species/species = dna?.species
	if(!species)
		return null
	return (get_body_cut() == BODY_CUT_FEMININE) ? species.dam_icon_f : species.dam_icon_m

/// Shifts an appearance by this mob's offset for one OFFSET_* key.
/mob/living/carbon/proc/apply_offset(mutable_appearance/appearance, offset_key)
	var/list/offset = LAZYACCESS(get_offset_features(), offset_key)
	if(!offset)
		return
	appearance.pixel_x += offset[1]
	appearance.pixel_y += offset[2]

/// Which marking art, "m" or "f", fits this mob's body.
/mob/living/carbon/proc/get_marking_sex()
	var/datum/body_build/build = get_body_build()
	if(build)
		return build.get_marking_sex(gender)
	return (gender == FEMALE) ? "f" : "m"

/// Pixel_y nudge for marking art on one body zone.
/mob/living/carbon/proc/get_marking_offset(zone)
	var/datum/body_build/build = get_body_build()
	return build ? build.get_marking_offset(gender, zone) : 0
