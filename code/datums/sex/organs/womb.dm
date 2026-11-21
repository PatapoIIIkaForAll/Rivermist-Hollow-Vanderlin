/// Hidden organ past the vagina. Holds staged seed, eggs and embryos; always paired with a real vagina.
/obj/item/organ/genitals/filling_organ/womb
	name = "womb"
	icon_state = "stomach"
	visible_organ = FALSE
	accessory_type = /datum/sprite_accessory/none
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_WOMB
	altnames = list("womb")
	// Makes nothing of its own; it only keeps what the vagina stages into it.
	reagent_to_make = null
	produces_fluid = FALSE
	max_reagents = 20
	absorbing = TRUE
	absorbrate = 0.2
	driprate = 0
	spiller = FALSE
	can_hold_in = FALSE
	bloatable = FALSE
	processspeed = 20 SECONDS
	blocker = ITEM_SLOT_PANTS
	additional_blocker = "underwear"
	fertility = TRUE
	allows_conventional_impregnation = TRUE
	allows_oviposition_pregnancy = TRUE
	spawn_embryo_on_fertilization = TRUE
	oviposition_storage_component_type = /datum/component/body_storage/womb
	oviposition_location_name = "womb"
	// Passive egg production is enabled by a mob trait; these vars only tune the output.
	var/oviposition_egg_production_type = null // Null keeps the default safe egg type.
	var/oviposition_egg_production_interval = 20 MINUTES
	var/oviposition_egg_production_limit = 6
	var/next_oviposition_egg_generation = 0
	// Player-customizable egg appearance overrides
	var/custom_egg_name = ""
	var/custom_egg_desc = ""
	var/custom_organ_desc = ""
	var/custom_egg_color = null
	var/egg_scale = OVI_EGG_DEFAULT_SCALE
	var/list/egg_traits = list()
	var/resource_dependent_yield = FALSE

/obj/item/organ/genitals/filling_organ/womb/Insert(mob/living/M, special, drop_if_replaced, new_zone = null)
	. = ..()
	if(!.)
		return FALSE
	add_bodystorage(M, null, /datum/component/body_storage/womb)
	next_oviposition_egg_generation = 0
	if(isharpy(M))
		oviposition_egg_production_limit = max(oviposition_egg_production_limit, 12)

/obj/item/organ/genitals/filling_organ/womb/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	var/datum/component/body_storage/womb/comp = GetComponent(/datum/component/body_storage/womb)
	comp?.RemoveComponent()

/// The womb never shows, so it adds nothing to the body render key.
/obj/item/organ/genitals/filling_organ/womb/get_render_key_state()
	return null

/obj/item/organ/genitals/filling_organ/womb/get_availability(datum/species/owner_species, mob/living/C, datum/preferences/pref_load)
	return should_have_vagina_organ(C, pref_load)

/// Excess goes back into the vagina, never onto the floor; a womb that shrinks with pregnancy empties this way.
/obj/item/organ/genitals/filling_organ/womb/spill_reagents(amount)
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = get_real_organ(owner, ORGAN_SLOT_VAGINA)
	if(!reagents || amount <= 0 || !vagina?.reagents)
		return 0
	var/before = reagents.total_volume
	reagents.trans_to(vagina, amount)
	return before - reagents.total_volume

/obj/item/organ/genitals/filling_organ/womb/handle_overflow()
	if(reagents.maximum_volume >= reagents.total_volume)
		return
	spill_reagents(reagents.total_volume - reagents.maximum_volume)

/obj/item/organ/genitals/filling_organ/womb/process_fluids(seconds)
	. = ..()
	try_generate_oviposition_egg()

/// Eggs and hatchlings leave through the vagina in front of the womb.
/obj/item/organ/genitals/filling_organ/womb/get_birth_canal()
	return get_real_organ(owner, ORGAN_SLOT_VAGINA) || src

/// TRUE while an embryo grows or a hatchling waits; other eggs then stay in the vagina instead.
/obj/item/organ/genitals/filling_organ/womb/proc/is_occupied_by_embryos()
	if(count_internal_womb_hatchlings())
		return TRUE
	for(var/obj/item/oviposition_egg/egg as anything in get_oviposition_eggs(TRUE))
		if(egg.hatch_inside_host)
			return TRUE
	return FALSE

/// Whether the womb has room for this egg right now.
/obj/item/organ/genitals/filling_organ/womb/proc/accepts_oviposition_egg(obj/item/oviposition_egg/egg, force = FALSE)
	var/fit_result = SEND_SIGNAL(src, COMSIG_BODYSTORAGE_CHECK_FIT, egg, STORAGE_LAYER_DEEP, force)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			return TRUE
	return FALSE

/obj/item/organ/genitals/filling_organ/womb/attack_self(mob/user, list/modifiers)
	if(!ishuman(owner))
		to_chat(user, span_warning("The womb must be attached before I can tune its egg-laying."))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.open_hole_status(user)

/obj/item/organ/genitals/filling_organ/womb/proc/update_custom_organ_desc()
	desc = custom_organ_desc || initial(desc)

/obj/item/organ/genitals/filling_organ/womb/proc/get_generated_oviposition_egg_type()
	if(oviposition_egg_production_type)
		return oviposition_egg_production_type

	var/species_egg_type = get_species_oviposition_egg_type(owner)
	if(species_egg_type)
		return species_egg_type

	var/datum/quirk/neutral/egg_layer/egg_layer_quirk = owner?.get_quirk(/datum/quirk/neutral/egg_layer)
	if(!egg_layer_quirk)
		return null
	if(egg_layer_quirk.customization_value in egg_layer_quirk.customization_options)
		return egg_layer_quirk.customization_value
	return null

/obj/item/organ/genitals/filling_organ/womb/proc/get_oviposition_egg_generation_interval(egg_type = null)
	if(!egg_type)
		egg_type = get_generated_oviposition_egg_type() || OVI_EGG_NORMAL

	var/effective_interval = oviposition_egg_production_interval
	effective_interval *= get_oviposition_egg_type_interval_multiplier(egg_type)
	effective_interval *= get_oviposition_capacity_interval_multiplier(oviposition_egg_production_limit)
	effective_interval *= sanitize_oviposition_scale(egg_scale)
	effective_interval *= get_oviposition_trait_interval_multiplier(egg_traits)
	return max(1 MINUTES, round(effective_interval))

// Slowly forms unfertilized eggs directly in the womb when the owner has the egg-layer trait.
/obj/item/organ/genitals/filling_organ/womb/proc/try_generate_oviposition_egg()
	if(!owner || owner.stat == DEAD || !HAS_TRAIT(owner, TRAIT_EGG_LAYER))
		return FALSE
	if(!fertility || !supports_oviposition_pregnancy())
		return FALSE
	if(oviposition_egg_production_limit <= 0 || oviposition_egg_production_interval <= 0)
		return FALSE

	var/egg_type = get_generated_oviposition_egg_type()
	var/effective_interval = get_oviposition_egg_generation_interval(egg_type)
	// Resource-dependent: nutriment speeds up egg formation (halved interval at 10+ nutriment)
	if(resource_dependent_yield && owner)
		var/nutriment = owner.get_reagent_amount(/datum/reagent/consumable/nutriment)
		if(nutriment <= 0)
			// Only warn occasionally (when timer would have fired)
			if(next_oviposition_egg_generation && world.time >= next_oviposition_egg_generation)
				to_chat(owner, span_warning("My [get_oviposition_location_name()] aches faintly — I need to eat for my body to form eggs."))
				next_oviposition_egg_generation = world.time + effective_interval
			return FALSE // No nutriment = no egg production
		var/speed_multiplier = 1.5 - clamp(nutriment / 10, 0, 1)
		effective_interval = round(effective_interval * speed_multiplier)

	if(!next_oviposition_egg_generation)
		next_oviposition_egg_generation = world.time + effective_interval
		return FALSE
	if(world.time < next_oviposition_egg_generation)
		return FALSE

	if(length(get_oviposition_eggs()) >= oviposition_egg_production_limit)
		next_oviposition_egg_generation = world.time + effective_interval
		if(prob(5)) // Occasional reminder
			to_chat(owner, span_love("My [get_oviposition_location_name()] feels full and heavy with eggs."))
		return FALSE

	var/nutrient_cost = get_oviposition_nutrient_cost(egg_type || OVI_EGG_NORMAL, egg_scale, egg_traits, oviposition_egg_production_limit)
	if(resource_dependent_yield && !can_pay_oviposition_nutrients(owner, nutrient_cost))
		next_oviposition_egg_generation = world.time + effective_interval
		to_chat(owner, span_warning("My [get_oviposition_location_name()] aches faintly — I need more nutrition to finish forming an egg."))
		return FALSE

	var/obj/item/oviposition_egg/egg = new
	// Apply player custom overrides before setting type
	egg.apply_custom_overrides(custom_egg_name, custom_egg_desc, custom_egg_color, egg_scale, egg_traits)
	if(egg_type)
		egg.set_egg_type(egg_type)
	egg.set_oviposition_mother(owner)

	var/fit_result = SEND_SIGNAL(src, COMSIG_BODYSTORAGE_TRY_INSERT, egg, STORAGE_LAYER_DEEP, FALSE, TRUE)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			if(resource_dependent_yield)
				consume_oviposition_nutrients(owner, nutrient_cost)
			next_oviposition_egg_generation = world.time + effective_interval
			to_chat(owner, span_love("I feel a new egg form in my [get_oviposition_location_name()]."))
			return TRUE

	qdel(egg)
	next_oviposition_egg_generation = world.time + 30 SECONDS
	return FALSE

/// The womb organ, or null; a worn stand-in never counts.
/mob/living/proc/get_womb()
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ/womb)
	return get_real_organ(src, ORGAN_SLOT_WOMB)

/// Pairs a womb with a freshly inserted real vagina; DNA regeneration may replace it a moment later.
/mob/living/proc/ensure_womb(obj/item/organ/genitals/filling_organ/vagina/vagina)
	if(!vagina || vagina.is_false_organ() || get_womb())
		return null
	var/obj/item/organ/genitals/filling_organ/womb/womb
	// A body with womb DNA gets that womb, so a sterile womb stays sterile however the vagina arrived.
	if(iscarbon(src))
		var/mob/living/carbon/carbon = src
		var/list/organ_dna_list = carbon.dna?.organ_dna
		var/datum/organ_dna/womb/womb_dna = organ_dna_list ? organ_dna_list[ORGAN_SLOT_WOMB] : null
		if(istype(womb_dna) && womb_dna.can_create_organ())
			womb = womb_dna.create_organ(species = carbon.dna.species)
	if(!womb)
		womb = new
	womb.Insert(src, TRUE, FALSE)
	return womb
