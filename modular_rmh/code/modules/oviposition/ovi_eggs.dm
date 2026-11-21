// Egg profiles keep appearance and hatch behavior together so new egg types only
// need one local subtype instead of special cases spread across the system.
/datum/oviposition_egg_profile
	var/egg_type = OVI_EGG_NORMAL
	var/display_name = "hardshell egg"
	var/display_desc = "A soft, warm egg that feels alive even before it starts to twitch."
	/// Greyscale body, tinted by display_color or the player's colour.
	var/display_icon_state = "egg_hardshell"
	var/display_icon = 'modular_rmh/icons/obj/items/ovi_eggs.dmi'
	var/display_color = "#e8dcc4"
	/// Untinted overlay over the body: speckles, silk, roots. Null for none.
	var/display_marks_state = "egg_hardshell_marks"
	var/default_scale = OVI_EGG_DEFAULT_SCALE
	/// Width in centimetres a ripe egg of this kind passes the opening with, before the egg's own scale.
	var/birth_girth = OVI_EGG_DEFAULT_BIRTH_GIRTH
	/// What a birth leaves in the canal, reagent type to units; traits add theirs on top.
	var/list/residue_reagents
	/// What the egg holds when eaten, reagent type to units at scale one.
	var/list/egg_reagents = list(/datum/reagent/consumable/nutriment = 3)
	/// Chance in percent that an egg of this kind forms laced with aphrodisiac.
	var/aphrodisiac_chance = 15
	/// A ripe egg starts labour this long after ripening; zero keeps the per-minute roll.
	var/labour_delay = 0
	/// Chance per minute that a ripe egg starts labour, without a delay.
	var/labour_chance = OVI_EGG_LABOUR_CHANCE
	var/list/default_traits = null
	var/production_interval_multiplier = 1
	var/resource_cost_multiplier = 1
	var/hatch_result_type = /obj/item/reagent_containers/food/snacks/oviposition_egg/color/green //placeholder because we don't want human hatching
	var/requires_fertilization = TRUE
	var/poll_for_ghost = FALSE
	var/require_ghost_to_hatch = TRUE
	var/incubation_stage_duration = 5 MINUTES
	var/list/stage_messages = null
	var/ready_message = null
	var/hatch_message = null
	var/auto_hatch_when_laid = TRUE
	/// How this kind hatches: on the floor once laid, inside its host, or either by a roll.
	var/hatch_mode = OVI_HATCH_OUTSIDE
	/// Base chance to hatch inside when the kind may do either; the host's fill adds to it.
	var/inside_hatch_chance = 0
	/// What the hatchling does while it stays inside, or null for nothing.
	var/inside_behaviour_type
	var/allow_manual_host_removal = TRUE
	var/newborn_start_scale = 0.5
	var/newborn_growth_duration = 10 MINUTES
	var/internal_hatch_layer = STORAGE_LAYER_INNER
	var/internal_hatch_holder_type = /obj/item/mob_holder/internal_womb
	var/internal_hatch_holder_bulk = 2
	var/internal_hatch_message = null
	var/internal_contraction_message = null
	var/internal_birth_message = null

/datum/oviposition_egg_profile/proc/get_stage_message(stage)
	if(!islist(stage_messages) || stage < 1 || stage > length(stage_messages))
		return null
	return stage_messages[stage]

/datum/oviposition_egg_profile/proc/get_default_traits()
	if(!islist(default_traits))
		return list()
	return default_traits.Copy()

/datum/oviposition_egg_profile/proc/apply_to_egg(obj/item/oviposition_egg/egg)
	if(!egg)
		return
	// Apply base profile values, then let player custom overrides take priority
	egg.name = egg.custom_egg_name ? egg.custom_egg_name : display_name
	egg.desc = egg.custom_egg_desc ? egg.custom_egg_desc : display_desc
	egg.icon_state = display_icon_state
	egg.color = egg.custom_egg_color ? egg.custom_egg_color : display_color
	var/list/profile_traits = get_default_traits()
	if(isnull(egg.egg_traits))
		egg.egg_traits = profile_traits
	else if(length(profile_traits))
		egg.egg_traits = sanitize_oviposition_trait_list(profile_traits + egg.egg_traits)
	if(isnull(egg.egg_scale))
		egg.egg_scale = default_scale
	if(display_icon)
		egg.icon = display_icon
	// The lace is rolled once per kind, so the egg, its coat and its birth residue agree.
	if(egg.has_egg_trait(OVI_EGG_TRAIT_APHRODISIAC))
		egg.laced = TRUE
	else if(isnull(egg.laced) || egg.laced_for_type != egg_type)
		egg.laced = prob(aphrodisiac_chance)
	egg.laced_for_type = egg_type
	egg.fill_egg_reagents(src)
	egg.update_appearance(UPDATE_OVERLAYS)
	egg.auto_hatch_when_laid = auto_hatch_when_laid
	egg.hatch_inside_host = (hatch_mode == OVI_HATCH_INSIDE)
	egg.body_storage_manual_removal = allow_manual_host_removal
	egg.body_storage_random_removal = allow_manual_host_removal
	egg.newborn_start_scale = newborn_start_scale
	egg.newborn_growth_duration = newborn_growth_duration
	egg.internal_hatch_layer = internal_hatch_layer
	egg.internal_hatch_holder_type = internal_hatch_holder_type
	egg.internal_hatch_holder_bulk = internal_hatch_holder_bulk
	egg.internal_hatch_message = internal_hatch_message
	egg.internal_contraction_message = internal_contraction_message
	egg.internal_birth_message = internal_birth_message
	egg.apply_scale_to_appearance()

/datum/oviposition_egg_profile/spider
	egg_type = OVI_EGG_SPIDER
	display_name = "spider egg"
	display_desc = "A soft, web-slick egg with a faint, unsettling pulse."
	display_icon_state = "egg_spider"
	display_marks_state = "egg_spider_marks"
	display_color = "#8d96a6"
	hatch_result_type = /mob/living/simple_animal/hostile/retaliate/spider
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = 4 MINUTES
	birth_girth = 12
	hatch_mode = OVI_HATCH_EITHER
	inside_hatch_chance = 40
	inside_behaviour_type = /datum/hatchling_inside_behaviour/spider
	ready_message = "The spider egg in my %CONTAINER% twitches with hungry little movements."
	hatch_message = "%EGG% splits open in a spray of web and skittering legs!"
	egg_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/egg_slime = 1, /datum/reagent/toxin/spidervenom_paralytic = 0.5)
	aphrodisiac_chance = 25

/datum/oviposition_egg_profile/bog_bug
	egg_type = OVI_EGG_BOG_BUG
	display_name = "bog bug egg"
	display_desc = "A damp, swamp-dark egg with a shell that flexes around something hungry."
	display_icon_state = "egg_bogbug"
	display_marks_state = "egg_bogbug_marks"
	display_color = "#6d8a5b"
	hatch_result_type = /mob/living/simple_animal/hostile/retaliate/bogbug
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = 7 MINUTES
	birth_girth = 16
	residue_reagents = list(/datum/reagent/water = 3)
	hatch_mode = OVI_HATCH_EITHER
	inside_hatch_chance = 50
	inside_behaviour_type = /datum/hatchling_inside_behaviour/bog_bug
	ready_message = "The bog bug egg in my %CONTAINER% churns like a swamp creature is kicking to get free."
	hatch_message = "%EGG% bursts with a wet pop, spilling out a ravenous bog bug!"
	egg_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/water = 2, /datum/reagent/poison/herbal/swamp_miasma = 0.5)
	aphrodisiac_chance = 20

/datum/oviposition_egg_profile/tentacle
	egg_type = OVI_EGG_TENTACLE
	display_name = "tentacle egg"
	display_desc = "A soft, wine-dark egg whose slick shell twitches beneath the fingers."
	display_icon_state = "egg_tentacle"
	display_marks_state = "egg_tentacle_marks"
	display_color = "#9a5a88"
	hatch_result_type = /mob/living/simple_animal/hostile/retaliate/tentacle
	requires_fertilization = FALSE
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	internal_hatch_holder_bulk = 6
	incubation_stage_duration = 1.5 MINUTES
	birth_girth = 13
	residue_reagents = list(/datum/reagent/consumable/egg_slime = 6)
	hatch_mode = OVI_HATCH_INSIDE
	inside_behaviour_type = /datum/hatchling_inside_behaviour/tentacle
	ready_message = "The tentacle egg in my %CONTAINER% squirms with impatient coils."
	hatch_message = "%EGG% splits with a wet tear, spilling out a writhing tentacle mass!"
	egg_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/egg_slime = 4)
	aphrodisiac_chance = 70

/datum/oviposition_egg_profile/maneater
	egg_type = OVI_EGG_MANEATER
	display_name = "maneater seed egg"
	display_desc = "A soft green egg threaded through with fine roots and restless veins."
	display_icon_state = "egg_maneater"
	display_marks_state = "egg_maneater_marks"
	display_color = "#8fa653"
	hatch_result_type = /obj/item/maneaterseed/seedling
	requires_fertilization = FALSE
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = 90 SECONDS
	birth_girth = 18
	ready_message = "The green egg in my %CONTAINER% tightens around a vigorously rooting seedling."
	hatch_message = "%EGG% peels open like a wet flower, releasing a maneater seedling!"
	residue_reagents = list(/datum/reagent/consumable/egg_slime = 2)
	egg_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/tree_sap = 2, /datum/reagent/consumable/egg_slime = 1)
	aphrodisiac_chance = 40
	labour_delay = 1 MINUTES
	stage_messages = list(
		"Something settles deep in my %CONTAINER% and sends out a thin, questing root.",
		"A green ache spreads low in my belly; the seed in my %CONTAINER% is swelling.",
		"The pod in my %CONTAINER% is heavy now, roots pressing at my walls.",
		"The seed in my %CONTAINER% strains against me. It wants out.",
	)

/datum/oviposition_egg_profile/harpy
	egg_type = OVI_EGG_HARPY
	display_name = "hardshell egg"
	display_desc = "A smooth, birdlike egg with a sturdy shell and a gentle, nest-warm weight."
	display_icon_state = "egg_avian"
	display_marks_state = "egg_avian_marks"
	display_color = "#f0e4ca"
	default_scale = 1.15
	production_interval_multiplier = 1.15
	birth_girth = 13
	ready_message = "The harpy egg in my %CONTAINER% feels full and heavy, like a ripe nesting egg ready to be laid."
	egg_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	aphrodisiac_chance = 10

/datum/oviposition_egg_profile/avian
	egg_type = OVI_EGG_AVIAN
	display_name = "avian egg"
	display_desc = "A warm birdlike egg with a smooth shell, faint speckles, and a nesting weight."
	display_icon_state = "egg_avian"
	display_marks_state = "egg_avian_marks"
	display_color = "#f2e3c2"
	default_scale = 1.1
	production_interval_multiplier = 1.1
	birth_girth = 13
	ready_message = "The avian egg in my %CONTAINER% feels heavy, warm, and ready to be laid."
	egg_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	aphrodisiac_chance = 10

/datum/oviposition_egg_profile/softshell
	egg_type = OVI_EGG_SOFTSHELL
	display_name = "softshell egg"
	display_desc = "A flexible, translucent egg whose shell gives gently under the fingers."
	display_icon_state = "egg_softshell"
	display_marks_state = "egg_softshell_marks"
	display_color = "#efc2b6"
	default_scale = 0.85
	production_interval_multiplier = 0.8
	resource_cost_multiplier = 0.8
	incubation_stage_duration = 4 MINUTES
	birth_girth = 13
	residue_reagents = list(/datum/reagent/consumable/egg_slime = 2)
	ready_message = "The softshell egg in my %CONTAINER% feels pliant, warm, and ready to pass."
	egg_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/egg_slime = 2)
	aphrodisiac_chance = 35

/datum/oviposition_egg_profile/parasitic
	egg_type = OVI_EGG_PARASITIC
	display_name = "parasitic egg"
	display_desc = "A clinging, slick egg with a faint pulse and an unsettling hunger."
	display_icon_state = "egg_parasitic"
	display_marks_state = "egg_parasitic_marks"
	display_color = "#a4b56e"
	default_scale = 0.9
	default_traits = list(OVI_EGG_TRAIT_PARASITE, OVI_EGG_TRAIT_FAST_GROWTH)
	production_interval_multiplier = 1.35
	resource_cost_multiplier = 1.4
	incubation_stage_duration = 6 MINUTES
	birth_girth = 12
	residue_reagents = list(/datum/reagent/consumable/egg_slime = 2)
	ready_message = "The parasitic egg in my %CONTAINER% twitches with needy, invasive warmth."
	egg_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/egg_slime = 2, /datum/reagent/toxin/venom = 0.5)
	aphrodisiac_chance = 50

/datum/oviposition_egg_profile/embryo
	egg_type = OVI_EGG_EMBRYO
	display_name = "embryo sac"
	display_desc = "A fleshy pseudo-egg, soft and alive with a growing creature inside."
	display_icon_state = "egg_embryo"
	display_marks_state = "egg_embryo_marks"
	display_color = "#e0a9a3"
	incubation_stage_duration = 8 MINUTES
	stage_messages = list(
		"Something fertile settles deep in my %CONTAINER%.",
		"The embryo in my %CONTAINER% grows heavier and more alive.",
		"A tight, restless pressure builds in my %CONTAINER%."
	)
	birth_girth = 24
	ready_message = "The embryo in my %CONTAINER% is fully grown and about to hatch inside me."
	hatch_message = "Something alive hatches from %EGG% inside my %CONTAINER%!"
	auto_hatch_when_laid = FALSE
	hatch_mode = OVI_HATCH_INSIDE
	inside_behaviour_type = /datum/hatchling_inside_behaviour/embryo
	allow_manual_host_removal = FALSE
	internal_hatch_layer = STORAGE_LAYER_INNER
	internal_hatch_holder_bulk = 2
	internal_hatch_message = "Something alive hatches inside my %CONTAINER%, forcing it to clench around the newborn."
	internal_contraction_message = "My %CONTAINER% clenches in sharp contractions around the hatchling inside."
	internal_birth_message = "%CARRIER% doubles over as a newborn forces its way out of %CONTAINER%!"
	egg_reagents = list(/datum/reagent/consumable/nutriment = 2)
	aphrodisiac_chance = 0

/datum/oviposition_egg_profile/leech
	egg_type = OVI_EGG_LEECH
	display_name = "leech egg"
	display_desc = "A small dark egg, slick and faintly twitching."
	display_icon_state = "egg_leech"
	display_marks_state = "egg_leech_marks"
	display_color = "#5a3f6e"
	hatch_result_type = /obj/item/natural/worms/leech/erotic/burrowing
	requires_fertilization = FALSE
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = 90 SECONDS
	stage_messages = list(
	"A tiny leech egg settles in my %CONTAINER%.",
	"The leech egg in my %CONTAINER% twitches with small, eager movements.",
	"The leech egg in my %CONTAINER% feels ready to split.",
	)
	birth_girth = 6
	ready_message = "The leech egg in my %CONTAINER% is ready to hatch."
	hatch_message = "%EGG% splits open with a wet little twitch!"
	auto_hatch_when_laid = TRUE
	hatch_mode = OVI_HATCH_INSIDE
	allow_manual_host_removal = TRUE
	internal_hatch_layer = STORAGE_LAYER_DEEP
	egg_reagents = list(/datum/reagent/consumable/nutriment = 0.5, /datum/reagent/consumable/egg_slime = 0.5)
	aphrodisiac_chance = 0

/proc/get_oviposition_egg_profile(egg_type)
	var/profile_type = /datum/oviposition_egg_profile
	switch(egg_type)
		if(OVI_EGG_AVIAN)
			profile_type = /datum/oviposition_egg_profile/avian
		if(OVI_EGG_SOFTSHELL)
			profile_type = /datum/oviposition_egg_profile/softshell
		if(OVI_EGG_PARASITIC)
			profile_type = /datum/oviposition_egg_profile/parasitic
		if(OVI_EGG_SPIDER)
			profile_type = /datum/oviposition_egg_profile/spider
		if(OVI_EGG_BOG_BUG)
			profile_type = /datum/oviposition_egg_profile/bog_bug
		if(OVI_EGG_HARPY)
			profile_type = /datum/oviposition_egg_profile/harpy
		if(OVI_EGG_EMBRYO)
			profile_type = /datum/oviposition_egg_profile/embryo
		if(OVI_EGG_LEECH)
			profile_type = /datum/oviposition_egg_profile/leech
		if(OVI_EGG_TENTACLE)
			profile_type = /datum/oviposition_egg_profile/tentacle
		if(OVI_EGG_MANEATER)
			profile_type = /datum/oviposition_egg_profile/maneater
		if(OVI_EGG_MOTHBUG)
			profile_type = /datum/oviposition_egg_profile/mothbug
	return new profile_type

/proc/get_species_oviposition_egg_type(mob/living/owner)
	if(isharpy(owner))
		return OVI_EGG_AVIAN
	return null

/proc/get_oviposition_egg_type_options(include_unsafe = TRUE)
	var/list/options = list(
		OVI_EGG_NORMAL,
		OVI_EGG_AVIAN,
		OVI_EGG_SOFTSHELL,
		OVI_EGG_PARASITIC,
		OVI_EGG_HARPY
	)
	if(include_unsafe)
		options += list(OVI_EGG_SPIDER, OVI_EGG_BOG_BUG, OVI_EGG_TENTACLE, OVI_EGG_MANEATER)
	return options

/proc/get_oviposition_egg_trait_options()
	return list(
		OVI_EGG_TRAIT_APHRODISIAC,
		OVI_EGG_TRAIT_POISON,
		OVI_EGG_TRAIT_PARASITE,
		OVI_EGG_TRAIT_FAST_GROWTH
	)

/proc/sanitize_oviposition_scale(scale)
	var/scale_number = text2num("[scale]")
	if(isnull(scale_number))
		scale_number = OVI_EGG_DEFAULT_SCALE
	return clamp(scale_number, OVI_EGG_MIN_SCALE, OVI_EGG_MAX_SCALE)

/proc/sanitize_oviposition_trait_list(list/raw_traits)
	var/list/sanitized_traits = list()
	var/list/valid_traits = get_oviposition_egg_trait_options()
	for(var/trait_flag in raw_traits)
		if(trait_flag in valid_traits)
			sanitized_traits |= trait_flag
	return sanitized_traits

/proc/sanitize_oviposition_text(text_input, max_length = OVI_EGG_MAX_CUSTOM_DESC_LENGTH, allow_newlines = TRUE)
	if(!istext(text_input))
		return ""
	var/text_value = copytext_char("[text_input]", 1, max_length + 1)
	var/static/cr = ascii2text(13)
	var/static/lf = ascii2text(10)
	var/static/tab = ascii2text(9)
	text_value = replacetext(text_value, "[cr][lf]", lf)
	text_value = replacetext(text_value, cr, lf)
	text_value = replacetext(text_value, tab, " ")
	if(allow_newlines)
		while(findtext(text_value, "[lf][lf][lf]"))
			text_value = replacetext(text_value, "[lf][lf][lf]", "[lf][lf]")
	else
		text_value = replacetext(text_value, lf, " ")
	return trim(html_encode(text_value))

/proc/get_oviposition_egg_type_interval_multiplier(egg_type)
	var/datum/oviposition_egg_profile/profile = get_oviposition_egg_profile(egg_type)
	return profile?.production_interval_multiplier || 1

/proc/get_oviposition_egg_type_resource_cost_multiplier(egg_type)
	var/datum/oviposition_egg_profile/profile = get_oviposition_egg_profile(egg_type)
	return profile?.resource_cost_multiplier || 1

/proc/get_oviposition_capacity_interval_multiplier(capacity)
	return 1 + (max(0, capacity - 3) * 0.03)

/proc/get_oviposition_trait_interval_multiplier(list/trait_flags)
	var/multiplier = 1
	if(islist(trait_flags))
		if(OVI_EGG_TRAIT_FAST_GROWTH in trait_flags)
			multiplier *= 0.75
		if(OVI_EGG_TRAIT_POISON in trait_flags)
			multiplier *= 1.15
		if(OVI_EGG_TRAIT_PARASITE in trait_flags)
			multiplier *= 1.2
	return multiplier

/proc/get_oviposition_nutrient_cost(egg_type, scale = OVI_EGG_DEFAULT_SCALE, list/trait_flags = null, clutch_size = 1)
	var/cost = 0.35 * sanitize_oviposition_scale(scale)
	cost *= get_oviposition_egg_type_resource_cost_multiplier(egg_type)
	cost += max(0, clutch_size - 1) * 0.05
	if(islist(trait_flags))
		if(OVI_EGG_TRAIT_POISON in trait_flags)
			cost += 0.25
		if(OVI_EGG_TRAIT_PARASITE in trait_flags)
			cost += 0.35
	return round(max(0.1, cost), 0.1)

/proc/can_pay_oviposition_nutrients(mob/living/carrier, cost)
	if(!carrier || cost <= 0)
		return TRUE
	return carrier.get_reagent_amount(/datum/reagent/consumable/nutriment) >= cost

/proc/consume_oviposition_nutrients(mob/living/carrier, cost)
	if(!carrier || cost <= 0)
		return TRUE
	if(!can_pay_oviposition_nutrients(carrier, cost))
		return FALSE
	carrier.reagents?.remove_reagent(/datum/reagent/consumable/nutriment, cost)
	return TRUE

/proc/get_oviposition_color_presets(mob/living/owner)
	var/list/presets = list(
		list("id" = "shell", "name" = "Shell", "color" = "#eee3c7"),
		list("id" = "soft", "name" = "Soft Pink", "color" = "#e9b6a9"),
		list("id" = "moss", "name" = "Moss", "color" = "#8aa05b"),
		list("id" = "spider", "name" = "Spider Grey", "color" = "#6d7685"),
		list("id" = "blood", "name" = "Blood", "color" = "#9c3838"),
	)
	if(isharpy(owner))
		presets += list(list("id" = "avian", "name" = "Avian Cream", "color" = "#f0e0bd"))
	return presets

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
	/// Player-set custom name override (blank = use profile default)
	var/custom_egg_name = ""
	/// Player-set custom description override
	var/custom_egg_desc = ""
	/// Player-set custom color override (hex string, uses grayscale icon_state)
	var/custom_egg_color = null
	/// Visual/mechanical egg scale. Null means profile default until first appearance update.
	var/egg_scale = null
	/// Optional modifier flags applied to this egg. Null means profile default.
	var/list/egg_traits = null
	/// Rolled once from the kind's chance: the egg, its coat and its residue carry aphrodisiac. Null until rolled.
	var/laced = null
	/// The kind the lace was rolled for; a kind change at creation rerolls it.
	var/laced_for_type
	/// Kind, scale and lace the reagents were last filled for, so a bite is not refilled.
	var/filled_signature
	var/auto_hatch_when_laid = TRUE
	var/hatch_inside_host = FALSE
	var/newborn_start_scale = 0.5
	var/newborn_growth_duration = 10 MINUTES
	var/internal_hatch_layer = STORAGE_LAYER_INNER
	var/internal_hatch_holder_type = /obj/item/mob_holder/internal_womb
	var/internal_hatch_holder_bulk = 2
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

/obj/item/oviposition_egg/proc/apply_custom_overrides(c_name, c_desc, c_color, c_scale = null, list/c_traits = null)
	if(c_name && istext(c_name) && length(c_name))
		custom_egg_name = c_name
	if(c_desc && istext(c_desc) && length(c_desc))
		custom_egg_desc = c_desc
	if(c_color && istext(c_color) && length(c_color))
		custom_egg_color = c_color
	if(!isnull(c_scale))
		egg_scale = sanitize_oviposition_scale(c_scale)
	if(islist(c_traits))
		egg_traits = sanitize_oviposition_trait_list(c_traits)
	update_egg_appearance()

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

/// The kind's own mix, scaled, plus the lace; refilled only when kind, scale or lace changed.
/obj/item/oviposition_egg/proc/fill_egg_reagents(datum/oviposition_egg_profile/profile)
	var/scale = get_egg_scale()
	var/signature = "[egg_type]|[scale]|[laced]"
	if(signature == filled_signature)
		return
	filled_signature = signature
	if(!reagents)
		create_reagents(20)
	reagents.clear_reagents()
	for(var/reagent_type in profile.egg_reagents)
		reagents.add_reagent(reagent_type, profile.egg_reagents[reagent_type] * scale, length(tastes) ? list("tastes" = tastes) : null)
	if(laced)
		reagents.add_reagent(/datum/reagent/consumable/aphrodisiac, OVI_EGG_LACE_UNITS * scale)

/// The kind's untinted marks over the tinted body.
/obj/item/oviposition_egg/update_overlays()
	. = ..()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	if(profile?.display_marks_state)
		var/mutable_appearance/marks = mutable_appearance(icon, profile.display_marks_state)
		marks.appearance_flags |= RESET_COLOR
		. += marks

/obj/item/oviposition_egg/examine(mob/user)
	. = ..()
	if(laced && !istype(loc, /obj/item/organ))
		. += span_love("A heady, sweet scent clings to it.")

/obj/item/oviposition_egg/proc/requires_fertilization()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return isnull(profile?.requires_fertilization) ? TRUE : profile.requires_fertilization

/obj/item/oviposition_egg/proc/get_hatch_result_type()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.hatch_result_type

/obj/item/oviposition_egg/proc/get_incubation_stage_duration()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	var/duration = profile?.incubation_stage_duration || 15 MINUTES
	duration *= get_incubation_multiplier()
	return max(1 MINUTES, round(duration))

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
	return clamp(newborn_start_scale * ((get_egg_scale() + 1) / 2), 0.25, 1.25)

/obj/item/oviposition_egg/proc/get_newborn_growth_duration()
	return round(newborn_growth_duration * get_egg_scale())

/obj/item/oviposition_egg/proc/get_egg_scale()
	if(isnull(egg_scale))
		var/datum/oviposition_egg_profile/profile = get_egg_profile()
		egg_scale = sanitize_oviposition_scale(profile?.default_scale || OVI_EGG_DEFAULT_SCALE)
	return sanitize_oviposition_scale(egg_scale)

/obj/item/oviposition_egg/proc/has_egg_trait(trait_flag)
	return islist(egg_traits) && (trait_flag in egg_traits)

/// The behaviour a hatchling of this kind follows while it stays inside, or null.
/obj/item/oviposition_egg/proc/get_inside_behaviour_type()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.inside_behaviour_type

/// How this kind hatches, from its profile.
/obj/item/oviposition_egg/proc/get_hatch_mode()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.hatch_mode || OVI_HATCH_OUTSIDE

/// The kind's base chance to hatch inside when it may do either.
/obj/item/oviposition_egg/proc/get_inside_hatch_base_chance()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	return profile?.inside_hatch_chance || 0

/// Width this egg passes the opening with: the profile's ripe girth, scaled, and smaller while unripe.
/obj/item/oviposition_egg/proc/get_birth_girth()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	var/ripe = (profile?.birth_girth || OVI_EGG_DEFAULT_BIRTH_GIRTH) * get_egg_scale()
	var/datum/component/pregnancy/pregnancy = get_pregnancy_component()
	if(!pregnancy || !pregnancy.max_stage)
		return ripe
	return ripe * clamp(pregnancy.stage / pregnancy.max_stage, 0.5, 1)

/// What a birth leaves in the canal: the profile's residue plus what the traits add, reagent type to units.
/obj/item/oviposition_egg/proc/get_birth_residue()
	var/datum/oviposition_egg_profile/profile = get_egg_profile()
	var/list/residue = islist(profile?.residue_reagents) ? profile.residue_reagents.Copy() : list()
	if(laced)
		residue[/datum/reagent/consumable/aphrodisiac] += OVI_EGG_RESIDUE_APHRODISIAC
	if(has_egg_trait(OVI_EGG_TRAIT_POISON))
		residue[/datum/reagent/toxin/venom] += OVI_EGG_RESIDUE_VENOM
	var/scale = get_egg_scale()
	for(var/reagent_type in residue)
		residue[reagent_type] *= scale
	return residue

/obj/item/oviposition_egg/proc/get_incubation_multiplier()
	var/multiplier = get_egg_scale()
	if(has_egg_trait(OVI_EGG_TRAIT_FAST_GROWTH))
		multiplier *= 0.65
	if(has_egg_trait(OVI_EGG_TRAIT_PARASITE))
		multiplier *= 0.9
	return clamp(multiplier, 0.25, 4)

/obj/item/oviposition_egg/proc/get_storage_bulk_for_stage(stage)
	return max(1, round(max(1, stage) * 2 * get_egg_scale()))

/obj/item/oviposition_egg/proc/apply_scale_to_appearance()
	var/scale = get_egg_scale()
	var/matrix/scaled_transform = matrix()
	scaled_transform.Scale(scale)
	transform = scaled_transform
	body_storage_bulk = max(1, round(initial(body_storage_bulk) * scale))

/obj/item/oviposition_egg/proc/apply_trait_reagents_to(obj/item/reagent_containers/food/snacks/hatch_item)
	if(!hatch_item)
		return
	if(!hatch_item.reagents)
		hatch_item.create_reagents(10)
	if(laced)
		hatch_item.reagents.add_reagent(/datum/reagent/consumable/aphrodisiac, OVI_EGG_LACE_UNITS)
	if(has_egg_trait(OVI_EGG_TRAIT_POISON))
		hatch_item.reagents.add_reagent(/datum/reagent/toxin/venom, 1)

/obj/item/oviposition_egg/proc/get_pregnancy_component()
	return GetComponent(/datum/component/pregnancy)

/obj/item/oviposition_egg/proc/has_pregnancy()
	return !isnull(get_pregnancy_component())

/obj/item/oviposition_egg/proc/is_fertilized()
	var/datum/component/pregnancy/pregnancy = get_pregnancy_component()
	return pregnancy?.fertilized
