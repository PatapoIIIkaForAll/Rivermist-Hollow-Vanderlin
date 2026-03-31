#define OVI_EGG_NORMAL "normal_ovi"
#define OVI_EGG_SPIDER "spider_ovi"
#define OVI_EGG_BOG_BUG "bog_bug_ovi"
#define OVI_EGG_HARPY "harpy_ovi"
#define OVI_EGG_EMBRYO "embryo_ovi"

// Egg profiles keep appearance and hatch behavior together so new egg types only
// need one local subtype instead of special cases spread across the system.
/datum/oviposition_egg_profile
	var/egg_type = OVI_EGG_NORMAL
	var/display_name = "oviposition egg"
	var/display_desc = "A soft, warm egg that feels alive even before it starts to twitch."
	var/display_icon_state = "egg"
	var/display_icon = null
	var/display_color = null
	var/hatch_result_type = /obj/item/reagent_containers/food/snacks/oviposition_egg/color/green //placeholder because we don't want human hatching
	var/requires_fertilization = TRUE
	var/poll_for_ghost = FALSE
	var/require_ghost_to_hatch = TRUE
	var/incubation_stage_duration = 5 MINUTES
	var/list/stage_messages = null
	var/ready_message = null
	var/hatch_message = null
	var/auto_hatch_when_laid = TRUE
	var/hatch_inside_host = FALSE
	var/allow_manual_host_removal = TRUE
	var/newborn_start_scale = 0.5
	var/newborn_growth_duration = 10 MINUTES
	var/internal_hatch_layer = STORAGE_LAYER_INNER
	var/internal_hatch_holder_type = /obj/item/mob_holder/internal_womb
	var/internal_hatch_holder_bulk = 2
	var/internal_hatch_triggers_contractions = FALSE
	var/internal_hatch_auto_birth = FALSE
	var/internal_hatch_birth_delay = 0
	var/internal_hatch_message = null
	var/internal_contraction_message = null
	var/internal_birth_message = null

/datum/oviposition_egg_profile/proc/get_stage_message(stage)
	if(!islist(stage_messages) || stage < 1 || stage > length(stage_messages))
		return null
	return stage_messages[stage]

/datum/oviposition_egg_profile/proc/apply_to_egg(obj/item/oviposition_egg/egg)
	if(!egg)
		return
	egg.name = display_name
	egg.desc = display_desc
	egg.icon_state = display_icon_state
	egg.color = display_color
	if(display_icon)
		egg.icon = display_icon
	egg.auto_hatch_when_laid = auto_hatch_when_laid
	egg.hatch_inside_host = hatch_inside_host
	egg.body_storage_manual_removal = allow_manual_host_removal
	egg.body_storage_random_removal = allow_manual_host_removal
	egg.newborn_start_scale = newborn_start_scale
	egg.newborn_growth_duration = newborn_growth_duration
	egg.internal_hatch_layer = internal_hatch_layer
	egg.internal_hatch_holder_type = internal_hatch_holder_type
	egg.internal_hatch_holder_bulk = internal_hatch_holder_bulk
	egg.internal_hatch_triggers_contractions = internal_hatch_triggers_contractions
	egg.internal_hatch_auto_birth = internal_hatch_auto_birth
	egg.internal_hatch_birth_delay = internal_hatch_birth_delay
	egg.internal_hatch_message = internal_hatch_message
	egg.internal_contraction_message = internal_contraction_message
	egg.internal_birth_message = internal_birth_message

/datum/oviposition_egg_profile/spider
	egg_type = OVI_EGG_SPIDER
	display_name = "spider egg"
	display_desc = "A soft, web-slick egg with a faint, unsettling pulse."
	display_icon_state = "egg_color"
	display_color = "#6d7685"
	hatch_result_type = /mob/living/simple_animal/hostile/retaliate/spider
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = 4 MINUTES
	ready_message = "The spider egg in my %CONTAINER% twitches with hungry little movements."
	hatch_message = "%EGG% splits open in a spray of web and skittering legs!"

/datum/oviposition_egg_profile/bog_bug
	egg_type = OVI_EGG_BOG_BUG
	display_name = "bog bug egg"
	display_desc = "A damp, swamp-dark egg with a shell that flexes around something hungry."
	display_icon_state = "egg_color"
	display_color = "#4d6a3f"
	hatch_result_type = /mob/living/simple_animal/hostile/retaliate/bogbug
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = 7 MINUTES
	ready_message = "The bog bug egg in my %CONTAINER% churns like a swamp creature is kicking to get free."
	hatch_message = "%EGG% bursts with a wet pop, spilling out a ravenous bog bug!"

/datum/oviposition_egg_profile/harpy
	egg_type = OVI_EGG_HARPY
	display_name = "hardshell egg"
	display_desc = "A smooth, birdlike egg with a sturdy shell and a gentle, nest-warm weight."
	display_icon_state = "egg_chicken"
	display_color = "#eee3c7"
	ready_message = "The harpy egg in my %CONTAINER% feels full and heavy, like a ripe nesting egg ready to be laid."

/datum/oviposition_egg_profile/embryo
	egg_type = OVI_EGG_EMBRYO
	display_name = "embryo sac"
	display_desc = "A fleshy pseudo-egg, soft and alive with a growing creature inside."
	display_icon_state = "egg_color"
	display_color = "#d7a29d"
	incubation_stage_duration = 8 MINUTES
	stage_messages = list(
		1 = "Something fertile settles deep in my %CONTAINER%.",
		2 = "The embryo in my %CONTAINER% grows heavier and more alive.",
		3 = "A tight, restless pressure builds in my %CONTAINER%.",
	)
	ready_message = "The embryo in my %CONTAINER% is fully grown and about to hatch inside me."
	hatch_message = "Something alive hatches from %EGG% inside my %CONTAINER%!"
	auto_hatch_when_laid = FALSE
	hatch_inside_host = TRUE
	allow_manual_host_removal = FALSE
	internal_hatch_layer = STORAGE_LAYER_INNER
	internal_hatch_holder_bulk = 2
	internal_hatch_triggers_contractions = TRUE
	internal_hatch_auto_birth = TRUE
	internal_hatch_birth_delay = 1 SECONDS
	internal_hatch_message = "Something alive hatches inside my %CONTAINER%, forcing it to clench around the newborn."
	internal_contraction_message = "My %CONTAINER% clenches in sharp contractions around the hatchling inside."
	internal_birth_message = "%CARRIER% doubles over as a newborn forces its way out of %CONTAINER%!"

/proc/get_oviposition_egg_profile(egg_type)
	var/profile_type = /datum/oviposition_egg_profile
	switch(egg_type)
		if(OVI_EGG_SPIDER)
			profile_type = /datum/oviposition_egg_profile/spider
		if(OVI_EGG_BOG_BUG)
			profile_type = /datum/oviposition_egg_profile/bog_bug
		if(OVI_EGG_HARPY)
			profile_type = /datum/oviposition_egg_profile/harpy
		if(OVI_EGG_EMBRYO)
			profile_type = /datum/oviposition_egg_profile/embryo
	return new profile_type

/proc/get_species_oviposition_egg_type(mob/living/owner)
	if(isharpy(owner))
		return OVI_EGG_HARPY
	return null

/proc/get_oviposition_parent_hatch_result_type(mob/living/parent)
	if(!parent)
		return null
	return parent.get_oviposition_parent_hatch_result_type()

/proc/parent_triggers_oviposition_embryo_pregnancy(mob/living/parent)
	if(!parent)
		return FALSE
	return parent.triggers_oviposition_embryo_pregnancy()

/mob/living/proc/triggers_oviposition_embryo_pregnancy()
	return FALSE

/mob/living/proc/get_oviposition_parent_hatch_result_type()
	if(ispath(type, /mob/living))
		return type
	return null

/mob/living/carbon/human/triggers_oviposition_embryo_pregnancy()
	return dna?.species?.triggers_oviposition_embryo_pregnancy() || FALSE

/mob/living/carbon/human/get_oviposition_parent_hatch_result_type()
	var/datum/species/parent_species = dna?.species
	var/species_hatch_result_type = parent_species?.get_oviposition_parent_hatch_result_type()
	if(species_hatch_result_type)
		return species_hatch_result_type
	return /mob/living/carbon/human

/datum/species/proc/triggers_oviposition_embryo_pregnancy()
	return FALSE

/datum/species/proc/get_oviposition_parent_hatch_result_type()
	return null

/datum/species/goblin/triggers_oviposition_embryo_pregnancy()
	return TRUE

/datum/species/goblin/get_oviposition_parent_hatch_result_type()
	return /mob/living/carbon/human/species/goblin/npc

/datum/species/goblin/hell/get_oviposition_parent_hatch_result_type()
	return /mob/living/carbon/human/species/goblin/npc/hell

/datum/species/goblin/cave/get_oviposition_parent_hatch_result_type()
	return /mob/living/carbon/human/species/goblin/npc/cave

/datum/species/goblin/sea/get_oviposition_parent_hatch_result_type()
	return /mob/living/carbon/human/species/goblin/npc/sea

/datum/species/goblin/moon/get_oviposition_parent_hatch_result_type()
	return /mob/living/carbon/human/species/goblin/npc/moon

/proc/get_oviposition_parent_features(mob/living/parent)
	if(!ishuman(parent))
		return null

	var/mob/living/carbon/human/human_parent = parent
	var/datum/bodypart_feature/hair/parent_hair = human_parent.get_bodypart_feature_of_slot(BODYPART_FEATURE_HAIR)
	var/datum/bodypart_feature/hair/parent_facial_hair = human_parent.get_bodypart_feature_of_slot(BODYPART_FEATURE_FACIAL_HAIR)
	return list(
		"skin_tone" = human_parent.skin_tone,
		"hair_color" = human_parent.get_hair_color(),
		"hair_style" = parent_hair?.accessory_type,
		"facial_hair_color" = human_parent.get_facial_hair_color(),
		"facial_hair_style" = parent_facial_hair?.accessory_type,
		"eye_color" = human_parent.get_eye_color(),
		"species" = human_parent.dna?.species?.type,
	)

/obj/item/oviposition_egg
	parent_type = /obj/item/reagent_containers/food/snacks/oviposition_egg
	name = "oviposition egg"
	desc = "A soft, warm egg that feels alive even before it starts to twitch."
	w_class = WEIGHT_CLASS_SMALL
	body_storage_bulk = 2
	var/egg_type = OVI_EGG_NORMAL
	var/mob/living/oviposition_mother
	var/oviposition_mother_name
	var/list/oviposition_mother_features
	var/auto_hatch_when_laid = TRUE
	var/hatch_inside_host = FALSE
	var/newborn_start_scale = 0.5
	var/newborn_growth_duration = 10 MINUTES
	var/internal_hatch_layer = STORAGE_LAYER_INNER
	var/internal_hatch_holder_type = /obj/item/mob_holder/internal_womb
	var/internal_hatch_holder_bulk = 2
	var/internal_hatch_triggers_contractions = FALSE
	var/internal_hatch_auto_birth = FALSE
	var/internal_hatch_birth_delay = 0
	var/internal_hatch_message = null
	var/internal_contraction_message = null
	var/internal_birth_message = null

/obj/item/oviposition_egg/Initialize(mapload)
	. = ..()
	update_egg_appearance()

/obj/item/oviposition_egg/proc/set_egg_type(new_egg_type)
	if(new_egg_type)
		egg_type = new_egg_type
	update_egg_appearance()
	return egg_type

/obj/item/oviposition_egg/proc/set_oviposition_mother(mob/living/new_mother)
	oviposition_mother = new_mother
	oviposition_mother_name = new_mother?.real_name
	oviposition_mother_features = get_oviposition_parent_features(new_mother)
	return oviposition_mother

/obj/item/oviposition_egg/proc/get_oviposition_mother(mob/living/default_mother = null)
	return oviposition_mother || default_mother

/obj/item/oviposition_egg/proc/get_egg_profile()
	return get_oviposition_egg_profile(egg_type)

/obj/item/oviposition_egg/proc/update_egg_appearance()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	if(!profile)
		return
	profile.apply_to_egg(src)

/obj/item/oviposition_egg/proc/requires_fertilization()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return isnull(profile?.requires_fertilization) ? TRUE : profile.requires_fertilization

/obj/item/oviposition_egg/proc/get_hatch_result_type()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.hatch_result_type

/obj/item/oviposition_egg/proc/get_incubation_stage_duration()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.incubation_stage_duration || 15 MINUTES

/obj/item/oviposition_egg/proc/get_stage_message(stage)
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.get_stage_message(stage)

/obj/item/oviposition_egg/proc/get_ready_message()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.ready_message

/obj/item/oviposition_egg/proc/get_hatch_message()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.hatch_message

/obj/item/oviposition_egg/proc/auto_hatches_when_laid()
	return auto_hatch_when_laid

/obj/item/oviposition_egg/proc/should_poll_for_ghost()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return isnull(profile?.poll_for_ghost) ? FALSE : profile.poll_for_ghost

/obj/item/oviposition_egg/proc/requires_ghost_to_hatch()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return isnull(profile?.require_ghost_to_hatch) ? FALSE : profile.require_ghost_to_hatch

/obj/item/oviposition_egg/proc/get_newborn_start_scale()
	return newborn_start_scale

/obj/item/oviposition_egg/proc/get_newborn_growth_duration()
	return newborn_growth_duration

/obj/item/oviposition_egg/proc/get_pregnancy_component()
	return GetComponent(/datum/component/pregnancy)

/obj/item/oviposition_egg/proc/has_pregnancy()
	return !isnull(get_pregnancy_component())

/obj/item/oviposition_egg/proc/is_fertilized()
	var/datum/component/pregnancy/pregnancy = get_pregnancy_component()
	return pregnancy?.fertilized
