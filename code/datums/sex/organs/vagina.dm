/obj/item/organ/genitals/filling_organ/vagina
	name = "vagina"
	icon = 'modular_rmh/icons/eaglephntm/icons/obj/surgery.dmi'
	icon_state = "vagina"
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_VAGINA
	//var/fertility = TRUE
	reagent_to_make = /datum/reagent/consumable/femcum
	refilling = FALSE
	reagent_generate_rate = 0.5
	max_femcum = 5
	max_reagents = 40 //big cap, ordinary absorbtion.
	altnames = list("vagina", "cunt", "womb", "pussy", "slit", "kitty", "snatch") //used in thought messages.
	absorbing = TRUE
	fertility = TRUE
	allows_conventional_impregnation = TRUE
	allows_oviposition_pregnancy = TRUE
	spawn_embryo_on_fertilization = TRUE
	oviposition_storage_component_type = /datum/component/body_storage/vagina
	oviposition_location_name = "womb"
	spiller = TRUE
	blocker = ITEM_SLOT_PANTS
	additional_blocker = "underwear"
	bloatable = TRUE
	stretchable = FALSE
	// Passive egg production is enabled by a mob trait; these vars only tune the output.
	var/oviposition_egg_production_type = null // Null keeps the default safe egg type.
	var/oviposition_egg_production_interval = 20 MINUTES
	var/oviposition_egg_production_limit = 3
	var/next_oviposition_egg_generation = 0

/obj/item/organ/genitals/filling_organ/vagina/Insert(mob/living/M, special, drop_if_replaced)
	. = ..()
	if(M.femcum)
		reagent_to_make = M.femcum
	add_bodystorage(M, null, /datum/component/body_storage/vagina)
	next_oviposition_egg_generation = 0

/obj/item/organ/genitals/filling_organ/vagina/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	var/datum/component/body_storage/vagina/comp = GetComponent(/datum/component/body_storage/vagina)
	comp?.RemoveComponent()

/obj/item/organ/genitals/filling_organ/vagina/proc/get_womb_storage()
	return get_oviposition_storage()

/obj/item/organ/genitals/filling_organ/vagina/proc/is_womb_egg(obj/item/oviposition_egg/egg)
	return is_oviposition_egg(egg)

/obj/item/organ/genitals/filling_organ/vagina/proc/get_womb_oviposition_eggs(include_growing = null)
	return get_oviposition_eggs(include_growing)

/obj/item/organ/genitals/filling_organ/vagina/proc/get_generated_oviposition_egg_type()
	if(oviposition_egg_production_type)
		return oviposition_egg_production_type

	var/species_egg_type = get_species_oviposition_egg_type(owner)
	if(species_egg_type)
		return species_egg_type

	var/datum/quirk/peculiarity/egg_layer/egg_layer_quirk = owner?.get_quirk(/datum/quirk/peculiarity/egg_layer)
	if(!egg_layer_quirk)
		return null
	if(egg_layer_quirk.customization_value in egg_layer_quirk.customization_options)
		return egg_layer_quirk.customization_value
	return null

// Slowly forms unfertilized eggs directly in the womb when the owner has the egg-layer trait.
/obj/item/organ/genitals/filling_organ/vagina/proc/try_generate_oviposition_egg()
	if(!owner || owner.stat == DEAD || !HAS_TRAIT(owner, TRAIT_EGG_LAYER))
		return FALSE
	if(!fertility || !supports_oviposition_pregnancy())
		return FALSE
	if(oviposition_egg_production_limit <= 0 || oviposition_egg_production_interval <= 0)
		return FALSE

	if(!next_oviposition_egg_generation)
		next_oviposition_egg_generation = world.time + oviposition_egg_production_interval
		return FALSE
	if(world.time < next_oviposition_egg_generation)
		return FALSE

	next_oviposition_egg_generation = world.time + oviposition_egg_production_interval

	if(length(get_oviposition_eggs()) >= oviposition_egg_production_limit)
		return FALSE

	var/obj/item/oviposition_egg/egg = new
	var/egg_type = get_generated_oviposition_egg_type()
	if(egg_type)
		egg.set_egg_type(egg_type)
	egg.set_oviposition_mother(owner)

	var/fit_result = SEND_SIGNAL(src, COMSIG_BODYSTORAGE_TRY_INSERT, egg, STORAGE_LAYER_DEEP)
	switch(fit_result)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			to_chat(owner, span_love("I feel a new egg form in my [get_oviposition_location_name()]."))
			return TRUE

	qdel(egg)
	return FALSE

/obj/item/organ/genitals/filling_organ/vagina/get_availability(datum/species/owner_species, mob/living/C, datum/preferences/pref_load)
	if(issimple(C))
		return C.gender == FEMALE
	else
		if(pref_load)
			return pref_load.has_enabled_customizer_entry(/datum/customizer_entry/organ/genitals/vagina)
		else
			return C.gender == FEMALE

