/// Body sprite file -> art key of the per-body pubic and armpit hair states, built by body_hair_art_generator.
GLOBAL_LIST_INIT(body_hair_art_keys, list(
	"icons/roguetown/mob/bodies/m/mt.dmi" = "mt",
	"icons/roguetown/mob/bodies/m/mm.dmi" = "mm",
	"modular_rmh/icons/mob/bodies/m/mta.dmi" = "mta",
	"icons/roguetown/mob/bodies/m/met.dmi" = "met",
	"icons/roguetown/mob/bodies/m/mem.dmi" = "mem",
	"icons/roguetown/mob/bodies/m/md.dmi" = "md",
	"icons/roguetown/mob/bodies/m/male_short.dmi" = "male_short",
	"icons/roguetown/mob/bodies/m/mt_muscular.dmi" = "mt_muscular",
	"icons/roguetown/mob/bodies/f/fm.dmi" = "fm",
	"modular_rmh/icons/mob/bodies/f/fma.dmi" = "fma",
	"icons/roguetown/mob/bodies/f/ft.dmi" = "ft",
	"icons/roguetown/mob/bodies/f/fd.dmi" = "fd",
	"icons/roguetown/mob/bodies/f/ft_muscular.dmi" = "ft_muscular",
	"modular_rmh/icons/mob/species/anthro_small_malea.dmi" = "anthro_small_m",
	"modular_rmh/icons/mob/species/anthro_small_femalea.dmi" = "anthro_small_f",
	"modular_rmh/icons/mob/species/goblin_male.dmi" = "goblin_m",
	"modular_rmh/icons/mob/species/goblin_female.dmi" = "goblin_f",
	"icons/roguetown/mob/bodies/f/kobold.dmi" = "kobold",
	"icons/roguetown/mob/bodies/m/harpy.dmi" = "harpy_m",
	"icons/roguetown/mob/bodies/f/harpy.dmi" = "harpy_f",
	"modular_rmh/icons/mob/species/moth_male.dmi" = "moth_m",
	"modular_rmh/icons/mob/species/moth_female.dmi" = "moth_f",
	"icons/roguetown/mob/bodies/m/rakshari.dmi" = "rakshari_m",
	"icons/roguetown/mob/bodies/f/rakshari.dmi" = "rakshari_f",
	"icons/roguetown/mob/bodies/f/medicator.dmi" = "medicator",
	"modular_rmh/icons/mob/species/ogre_male.dmi" = "ogre_m",
	"modular_rmh/icons/mob/species/ogre_female.dmi" = "ogre_f",
	// Build recolours and the broad female share a silhouette with an existing body.
	"modular_rmh/icons/mob/bodies/m/mem_grey.dmi" = "mem",
	"modular_rmh/icons/mob/bodies/m/mm_grey.dmi" = "mm",
	"modular_rmh/icons/mob/bodies/m/mt_muscular_grey.dmi" = "mt_muscular",
	"modular_rmh/icons/mob/bodies/f/ft_broad.dmi" = "ft_muscular",
	"modular_rmh/icons/mob/bodies/f/ft_broad_grey.dmi" = "ft_muscular",
	"modular_rmh/icons/mob/bodies/f/ft_muscular_grey.dmi" = "ft_muscular",
))

/// Art keys of 32x64 bodies, drawn from the tall hair dmis.
GLOBAL_LIST_INIT(body_hair_tall_art_keys, list(
	"ogre_m" = TRUE,
	"ogre_f" = TRUE,
))

GLOBAL_LIST_INIT(body_hair_materials, list(
	"Hair" = BODY_HAIR_MATERIAL_HAIR,
	"Fur" = BODY_HAIR_MATERIAL_FUR,
	"Feathers" = BODY_HAIR_MATERIAL_FEATHERS,
	"Fuzz" = BODY_HAIR_MATERIAL_FUZZ,
	"Braids" = BODY_HAIR_MATERIAL_BRAIDS,
))

GLOBAL_LIST_INIT(pubic_hair_styles, list(
	"Landing strip" = /datum/sprite_accessory/body_hair/pubic/style/strip,
	"Heart" = /datum/sprite_accessory/body_hair/pubic/style/heart,
	"Cross" = /datum/sprite_accessory/body_hair/pubic/style/cross,
))

/// Hair, fur or feathers a species may grow below the neck; the first entry is its default.
/datum/species
	var/list/body_hair_materials = BODY_HAIR_MATERIALS_HUMANOID

/proc/get_body_hair_art_key(mob/living/carbon/owner)
	if(!ishuman(owner))
		return null
	if(!owner.dna?.species)
		return null
	return GLOB.body_hair_art_keys["[owner.get_limbs_icon()]"]

/// Keeps material if allowed, else falls back to the first allowed one. Null allowed means any known material.
/proc/sanitize_body_hair_material(material, list/allowed_materials)
	if(!length(allowed_materials))
		allowed_materials = BODY_HAIR_MATERIALS_ANY
	return (material in allowed_materials) ? material : allowed_materials[1]

/proc/body_hair_species_default_accessory(datum/species/species)
	switch(species?.hairyness)
		if("t1")
			return /datum/sprite_accessory/body_hair/body/some_hair
		if("t2")
			return /datum/sprite_accessory/body_hair/body/hairy
		if("t3")
			return /datum/sprite_accessory/body_hair/body/very_hairy
	return /datum/sprite_accessory/body_hair/body/shaved

/datum/sprite_accessory/body_hair
	abstract_type = /datum/sprite_accessory/body_hair
	name = "shaved"
	color_key_name = "Hair"
	color_key_defaults = list(KEY_HAIR_COLOR)
	var/hairiness_level = HAIRINESS_SHAVED
	var/appearance_alpha = 255
	/// Per-body state prefix; the body art key is appended when drawn.
	var/art_state
	/// Dmi used for 32x64 bodies.
	var/tall_icon
	/// Examine text; %MATERIAL% becomes e.g. "pubic fur".
	var/description

/datum/sprite_accessory/body_hair/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	if(hairiness_level <= HAIRINESS_SHAVED)
		return null
	if(!art_state)
		return ..()
	var/art_key = get_body_hair_art_key(owner)
	return art_key ? "[art_state]_[art_key]" : null

/datum/sprite_accessory/body_hair/get_icon(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/art_key = get_body_hair_art_key(owner)
	if(tall_icon && art_key && GLOB.body_hair_tall_art_keys[art_key])
		return tall_icon
	return ..()

/datum/sprite_accessory/body_hair/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	if(appearance_alpha >= 255)
		return
	for(var/mutable_appearance/appearance as anything in appearance_list)
		appearance.alpha = appearance_alpha

// Chest hair, fitted per body by body_hair_art_generator/build_chest_hair.py.
/datum/sprite_accessory/body_hair/body
	abstract_type = /datum/sprite_accessory/body_hair/body
	icon = 'modular_rmh/icons/mob/sprite_accessory/bodyhair/chest_hair.dmi'
	tall_icon = 'modular_rmh/icons/mob/sprite_accessory/bodyhair/chest_hair_tall.dmi'
	layer = FRONT_MUTATIONS_LAYER

/datum/sprite_accessory/body_hair/body/shaved
	name = "shaved"
	icon_state = null
	hairiness_level = HAIRINESS_SHAVED

/datum/sprite_accessory/body_hair/body/some_hair
	name = "some hair"
	icon_state = "t1_mt"
	art_state = "t1"
	hairiness_level = HAIRINESS_SOME_HAIR

/datum/sprite_accessory/body_hair/body/hairy
	name = "hairy"
	icon_state = "t2_mt"
	art_state = "t2"
	hairiness_level = HAIRINESS_HAIRY

/datum/sprite_accessory/body_hair/body/very_hairy
	name = "very hairy"
	icon_state = "t3_mt"
	art_state = "t3"
	hairiness_level = HAIRINESS_VERY_HAIRY

// icon_state only feeds the preferences preview; drawing uses art_state.
/datum/sprite_accessory/body_hair/pubic
	abstract_type = /datum/sprite_accessory/body_hair/pubic
	icon = 'modular_rmh/icons/mob/sprite_accessory/bodyhair/pubic_hair.dmi'
	tall_icon = 'modular_rmh/icons/mob/sprite_accessory/bodyhair/pubic_hair_tall.dmi'
	layer = BODY_ADJ_LAYER

/datum/sprite_accessory/body_hair/pubic/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	return is_human_part_visible(owner, HIDECROTCH)

/datum/sprite_accessory/body_hair/pubic/shaved
	name = "shaved"
	icon_state = null
	hairiness_level = HAIRINESS_SHAVED

/datum/sprite_accessory/body_hair/pubic/stubble
	name = "stubble"
	icon_state = "stubble_fm"
	art_state = "stubble"
	hairiness_level = HAIRINESS_STUBBLE
	description = "a shadow of stubble"

/datum/sprite_accessory/body_hair/pubic/some_hair
	name = "some hair"
	icon_state = "trim_fm"
	art_state = "trim"
	hairiness_level = HAIRINESS_SOME_HAIR
	description = "a neat trim of %MATERIAL%"

/datum/sprite_accessory/body_hair/pubic/hairy
	name = "hairy"
	icon_state = "hairy_fm"
	art_state = "hairy"
	hairiness_level = HAIRINESS_HAIRY
	description = "a dense bush of %MATERIAL%"

/datum/sprite_accessory/body_hair/pubic/very_hairy
	name = "very hairy"
	icon_state = "extreme_fm"
	art_state = "extreme"
	hairiness_level = HAIRINESS_VERY_HAIRY
	description = "a wild, unkempt tangle of %MATERIAL%"

/datum/sprite_accessory/body_hair/pubic/style
	abstract_type = /datum/sprite_accessory/body_hair/pubic/style
	hairiness_level = HAIRINESS_SOME_HAIR

/datum/sprite_accessory/body_hair/pubic/style/strip
	name = "landing strip"
	icon_state = "strip_fm"
	art_state = "strip"
	description = "%MATERIAL% shaved bare save for an inviting strip"

/datum/sprite_accessory/body_hair/pubic/style/heart
	name = "heart"
	icon_state = "heart_fm"
	art_state = "heart"
	description = "a heart-shaped tuft of %MATERIAL%"

/datum/sprite_accessory/body_hair/pubic/style/cross
	name = "cross"
	icon_state = "cross_fm"
	art_state = "cross"
	description = "%MATERIAL% shaved into the shape of a cross"

// Drawn below shirts and bras, so clothing covers it without an is_visible() check.
/datum/sprite_accessory/body_hair/armpit
	abstract_type = /datum/sprite_accessory/body_hair/armpit
	icon = 'modular_rmh/icons/mob/sprite_accessory/bodyhair/armpit_hair.dmi'
	tall_icon = 'modular_rmh/icons/mob/sprite_accessory/bodyhair/armpit_hair_tall.dmi'
	layer = BODY_ADJ_LAYER

/datum/sprite_accessory/body_hair/armpit/shaved
	name = "shaved"
	icon_state = null
	hairiness_level = HAIRINESS_SHAVED

/datum/sprite_accessory/body_hair/armpit/stubble
	name = "stubble"
	icon_state = "trim_fm"
	art_state = "trim"
	hairiness_level = HAIRINESS_STUBBLE
	description = "a prickly spatter of %MATERIAL%"

/datum/sprite_accessory/body_hair/armpit/some_hair
	name = "some hair"
	icon_state = "moderate_fm"
	art_state = "moderate"
	hairiness_level = HAIRINESS_SOME_HAIR
	description = "a few wispy strands of %MATERIAL%"

/datum/sprite_accessory/body_hair/armpit/hairy
	name = "hairy"
	icon_state = "hairy_fm"
	art_state = "hairy"
	hairiness_level = HAIRINESS_HAIRY
	description = "a dense bush of %MATERIAL%"

/datum/sprite_accessory/body_hair/armpit/very_hairy
	name = "very hairy"
	icon_state = "extreme_fm"
	art_state = "extreme"
	hairiness_level = HAIRINESS_VERY_HAIRY
	description = "an utterly unkempt jungle of %MATERIAL%"
