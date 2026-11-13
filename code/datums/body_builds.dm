/// One body silhouette shared by every species offering it; sprites, cut and offsets live here.
/datum/body_build
	/// BODY_BUILD_* id, also the saved preference value.
	var/id
	/// Name shown in character setup.
	var/name
	/// Skin-tinted limb sprites per sex; null means the build is not offered to that sex.
	var/limbs_icon_m
	var/limbs_icon_f
	/// Greyscale limb sprites per sex, for species recoloured by mutant colour.
	var/limbs_icon_m_grey
	var/limbs_icon_f_grey
	/// BODY_CUT_* clothing cut per sex.
	var/cut_m = BODY_CUT_MASCULINE
	var/cut_f = BODY_CUT_FEMININE
	/// OFFSET_* pixel shifts for worn items and features per sex.
	var/list/offsets_m
	var/list/offsets_f
	/// OFFSET_* pixel shifts for genitals per sex.
	var/list/genital_offsets_m = BODY_GENITAL_OFFSETS_M
	var/list/genital_offsets_f = BODY_GENITAL_OFFSETS_SLIM_F
	/// Damage overlay sheets per sex.
	var/dam_icon_m = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	var/dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	/// Which marking art, "m" or "f", fits this body per sex.
	var/marking_sex_m = "m"
	var/marking_sex_f = "f"
	/// Body zone to pixel_y nudge for marking art per sex; male art is drawn for the mt.dmi frame.
	var/list/marking_offsets_m
	var/list/marking_offsets_f

/datum/body_build/proc/get_limbs_icon(gender, palette)
	if(gender == MALE)
		return (palette == BODY_PALETTE_GREY) ? limbs_icon_m_grey : limbs_icon_m
	return (palette == BODY_PALETTE_GREY) ? limbs_icon_f_grey : limbs_icon_f

/// Whether this build has sprites for the given sex and palette.
/datum/body_build/proc/supports(gender, palette)
	return !!get_limbs_icon(gender, palette)

/datum/body_build/proc/get_cut(gender)
	return (gender == MALE) ? cut_m : cut_f

/datum/body_build/proc/get_offsets(gender)
	return (gender == MALE) ? offsets_m : offsets_f

/datum/body_build/proc/get_genital_offsets(gender)
	return (gender == MALE) ? genital_offsets_m : genital_offsets_f

/datum/body_build/proc/get_dam_icon(gender)
	return (gender == MALE) ? dam_icon_m : dam_icon_f

/datum/body_build/proc/get_marking_sex(gender)
	return (gender == MALE) ? marking_sex_m : marking_sex_f

/datum/body_build/proc/get_marking_offset(gender, zone)
	var/list/nudges = (gender == MALE) ? marking_offsets_m : marking_offsets_f
	return nudges?[zone] || 0

/datum/body_build/slim
	id = BODY_BUILD_SLIM
	name = "Slim"
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mem.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'
	limbs_icon_m_grey = 'modular_rmh/icons/mob/bodies/m/mem_grey.dmi'
	limbs_icon_f_grey = 'modular_rmh/icons/mob/bodies/f/fma.dmi'
	cut_m = BODY_CUT_MIXED
	offsets_m = BODY_OFFSETS_SLIM_M
	offsets_f = BODY_OFFSETS_SLIM_F
	marking_offsets_m = list(
		BODY_ZONE_HEAD = -1,
		BODY_ZONE_CHEST = -1,
		BODY_ZONE_L_ARM = -1,
		BODY_ZONE_R_ARM = -1,
		BODY_ZONE_PRECISE_L_HAND = -1,
		BODY_ZONE_PRECISE_R_HAND = -1,
	)

/// The tall slim body, offered to elves only.
/datum/body_build/lithe
	id = BODY_BUILD_LITHE
	name = "Lithe"
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/met.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/ft.dmi'
	cut_m = BODY_CUT_MIXED
	offsets_m = BODY_OFFSETS_LITHE_M
	offsets_f = BODY_OFFSETS_LITHE_F
	genital_offsets_f = BODY_GENITAL_OFFSETS_LITHE_F
	marking_offsets_f = list(
		BODY_ZONE_HEAD = 1,
		BODY_ZONE_CHEST = 1,
		BODY_ZONE_L_ARM = 1,
		BODY_ZONE_R_ARM = 1,
		BODY_ZONE_PRECISE_L_HAND = 1,
		BODY_ZONE_PRECISE_R_HAND = 1,
	)

/// Masculine only; fm.dmi is already the slim feminine body.
/datum/body_build/average
	id = BODY_BUILD_AVERAGE
	name = "Average"
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mm.dmi'
	limbs_icon_m_grey = 'modular_rmh/icons/mob/bodies/m/mm_grey.dmi'
	offsets_m = BODY_OFFSETS_AVERAGE_M
	marking_offsets_m = list(
		BODY_ZONE_HEAD = -1,
		BODY_ZONE_CHEST = -1,
		BODY_ZONE_L_ARM = -1,
		BODY_ZONE_R_ARM = -1,
		BODY_ZONE_PRECISE_L_HAND = -1,
		BODY_ZONE_PRECISE_R_HAND = -1,
	)

/// Both sexes share the mt.dmi frame, masculine cut and offsets.
/datum/body_build/broad
	id = BODY_BUILD_BROAD
	name = "Broad"
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mt.dmi'
	limbs_icon_f = 'modular_rmh/icons/mob/bodies/f/ft_broad.dmi'
	limbs_icon_m_grey = 'modular_rmh/icons/mob/bodies/m/mta.dmi'
	limbs_icon_f_grey = 'modular_rmh/icons/mob/bodies/f/ft_broad_grey.dmi'
	cut_f = BODY_CUT_MASCULINE
	offsets_m = BODY_OFFSETS_BULKY
	offsets_f = BODY_OFFSETS_BULKY
	genital_offsets_f = BODY_GENITAL_OFFSETS_M
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	marking_sex_f = "m"

/datum/body_build/muscular
	id = BODY_BUILD_MUSCULAR
	name = "Muscular"
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mt_muscular.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/ft_muscular.dmi'
	limbs_icon_m_grey = 'modular_rmh/icons/mob/bodies/m/mt_muscular_grey.dmi'
	limbs_icon_f_grey = 'modular_rmh/icons/mob/bodies/f/ft_muscular_grey.dmi'
	cut_f = BODY_CUT_MASCULINE
	offsets_m = BODY_OFFSETS_BULKY
	offsets_f = BODY_OFFSETS_BULKY
	genital_offsets_f = BODY_GENITAL_OFFSETS_M
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	marking_sex_f = "m"

GLOBAL_LIST_INIT(body_builds, init_body_builds())

/proc/init_body_builds()
	. = list()
	for(var/build_type in subtypesof(/datum/body_build))
		var/datum/body_build/build = new build_type
		.[build.id] = build

/// Whether this species offers the build to the given sex.
/datum/species/proc/is_body_build_valid(build_id, gender)
	if(!(build_id in allowed_body_builds))
		return FALSE
	var/datum/body_build/build = GLOB.body_builds[build_id]
	return build?.supports(gender, body_build_palette)

/// The build used when none or an invalid one is picked; always valid for this species and sex.
/datum/species/proc/get_default_body_build(gender)
	if(!length(allowed_body_builds))
		return null
	var/build_id = (gender == MALE) ? default_body_build_m : default_body_build_f
	if(is_body_build_valid(build_id, gender))
		return build_id
	for(var/fallback in allowed_body_builds)
		if(is_body_build_valid(fallback, gender))
			return fallback
	return null

/// Build ids this species offers to the given sex, in display order.
/datum/species/proc/get_body_build_options(gender)
	. = list()
	for(var/build_id in allowed_body_builds)
		if(is_body_build_valid(build_id, gender))
			. += build_id
