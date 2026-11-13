/obj/item/organ/genitals/filling_organ/vagina
	name = "vagina"
	icon_state = "vagina"
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_VAGINA
	reagent_to_make = /datum/reagent/consumable/femcum
	produces_fluid = TRUE
	production_rate = 0.5
	nutrition_per_unit = 0
	max_reagents = 40 //big cap, ordinary absorbtion.
	altnames = list("vagina", "cunt", "womb", "pussy", "slit", "kitty", "snatch") //used in thought messages.
	absorbing = TRUE
	// Slow drains sized for a few-unit load: it stays about eight minutes, or about twenty when held in.
	absorbrate = 0.1
	driprate = 0.2
	// A slow tick keeps each drop big enough to wet cloth while the hole drains at a quarter pace.
	processspeed = 20 SECONDS
	can_hold_in = TRUE
	// Fertility, conception and pregnancy live on the paired womb; seed only passes through here.
	allows_conventional_impregnation = FALSE
	// Eggs prefer the womb behind this opening; the deep layer only hosts them when the womb cannot.
	allows_oviposition_pregnancy = TRUE
	spawn_embryo_on_fertilization = FALSE
	oviposition_storage_component_type = /datum/component/body_storage/vagina
	oviposition_location_name = "vagina"
	spiller = TRUE
	blocker = ITEM_SLOT_PANTS
	additional_blocker = "underwear"
	bloatable = TRUE
	drips_as_drops = TRUE
	/// Own femcum kept at full arousal, a little more than full lube needs; less arousal keeps less.
	var/max_wetness = 6
	/// Units of a climax burst still free to drip to the floor at any arousal.
	var/burst_to_drip = 0

/obj/item/organ/genitals/filling_organ/vagina/Insert(mob/living/M, special, drop_if_replaced, new_zone = null)
	var/list/nectar = M?.get_femcum_mix()
	if(nectar)
		set_reagent_to_make(nectar)
	. = ..()
	if(!.)
		return FALSE
	add_bodystorage(M, null, /datum/component/body_storage/vagina)
	M.ensure_womb(src)

/obj/item/organ/genitals/filling_organ/vagina/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	var/datum/component/body_storage/vagina/comp = GetComponent(/datum/component/body_storage/vagina)
	comp?.RemoveComponent()

/// The gape is part of the render key, so a gaping body caches its own sprite.
/obj/item/organ/genitals/filling_organ/vagina/get_render_key_state()
	return "[..()]-[orifice?.gaped ? "gaped" : "tight"]"

/// Redraws the body so the gaping sprite follows the gape state.
/obj/item/organ/genitals/filling_organ/vagina/on_orifice_gape_changed(now_gaped)
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.update_body_parts(TRUE)

/obj/item/organ/genitals/filling_organ/vagina/process_fluids(seconds)
	. = ..()
	tag_femcum_donor()
	stage_seed_into_womb()

/// Arousal drives wetness instead of nutrition: own femcum moves toward an arousal-scaled target, fading when above it.
/obj/item/organ/genitals/filling_organ/vagina/produce_fluid(seconds)
	var/own_fluid = get_own_fluid_amount()
	var/target = is_producing() ? get_wetness_target() : 0
	if(own_fluid > target)
		fade_wetness(min(own_fluid - target, VAGINA_WETNESS_FADE_RATE * seconds))
		return
	var/missing = target - own_fluid
	if(missing > 0)
		pay_for_fluid(add_produced_fluid(min(get_base_production(seconds), missing)))

/// Zero at visible arousal, the full wetness cap at the climax threshold.
/obj/item/organ/genitals/filling_organ/vagina/proc/get_wetness_target()
	var/arousal_fraction = clamp((get_owner_arousal() - VISIBLE_AROUSAL_THRESHOLD) / (ACTIVE_EJAC_THRESHOLD - VISIBLE_AROUSAL_THRESHOLD), 0, 1)
	return get_wetness_cap() * arousal_fraction

/// Most own femcum kept inside: a small lube reserve, or all the room while a fluid potion lifts the cap.
/obj/item/organ/genitals/filling_organ/vagina/proc/get_wetness_cap()
	for(var/datum/fluid_modifier/modifier as anything in owner?.get_fluid_modifiers(src))
		if(modifier.lifts_wetness_cap)
			return reagents.maximum_volume
	return max_wetness * get_capacity_multiplier()

/// Takes back own femcum without leaking it, the natural mix evenly before any swap; foreign fluid stays.
/obj/item/organ/genitals/filling_organ/vagina/proc/fade_wetness(amount)
	amount -= remove_fluid_types(get_natural_fluid_types(), amount)
	if(amount > 0)
		remove_fluid_types(get_own_fluid_types(), amount)

/obj/item/organ/genitals/filling_organ/vagina/proc/get_owner_arousal()
	var/list/arousal_data = list()
	SEND_SIGNAL(owner, COMSIG_SEX_GET_AROUSAL, arousal_data)
	return arousal_data["arousal"] || 0

/// Seed or a fresh climax burst always drips; plain wetness only at high arousal, so heat leaves no trail.
/obj/item/organ/genitals/filling_organ/vagina/can_drip_to_floor()
	burst_to_drip = min(burst_to_drip, get_own_fluid_amount())
	if(burst_to_drip > 0 || reagents.total_volume - get_own_fluid_amount() > 0.05)
		return TRUE
	return get_owner_arousal() >= VAGINA_DRIP_AROUSAL

/// A leak spends the climax burst first.
/obj/item/organ/genitals/filling_organ/vagina/leak_reagents(forced_amount)
	var/held = reagents.total_volume
	. = ..()
	burst_to_drip = max(0, burst_to_drip - (held - reagents.total_volume))

/obj/item/organ/genitals/filling_organ/vagina/get_base_climax_release(climax_location)
	return min(8, reagents.total_volume * 0.3)

/obj/item/organ/genitals/filling_organ/vagina/refills_stored_containers()
	return ..() && get_wetness_target() > 0

/// Adds the climax burst of own femcum and returns the units added.
/obj/item/organ/genitals/filling_organ/vagina/proc/produce_climax_fluid()
	if(!is_producing())
		return 0
	. = add_produced_fluid(FEMCUM_ORGASM_VOLUME * get_climax_multiplier())
	pay_for_fluid(.)
	burst_to_drip += .
	// What the wetness cap cannot keep gushes out now instead of filling the opening.
	var/excess = get_own_fluid_amount() - get_wetness_cap()
	if(excess > 0)
		leak_reagents(excess)

/// Stamps held femcum with its producer each tick, so the donor survives transfer out of the organ.
/obj/item/organ/genitals/filling_organ/vagina/proc/tag_femcum_donor()
	if(!owner || !reagents)
		return
	var/datum/reagent/consumable/femcum/nectar = reagents.get_reagent(reagent_to_make)
	if(istype(nectar))
		nectar.sync_femcum_parent(owner)

/// Eggs go to the womb behind this opening unless it is busy, full, or closed off by a plug or chastity.
/obj/item/organ/genitals/filling_organ/vagina/get_oviposition_receiver(obj/item/oviposition_egg/egg, force = FALSE)
	var/obj/item/organ/genitals/filling_organ/womb/womb = owner?.get_womb()
	if(!womb || womb.is_occupied_by_embryos())
		return src
	var/datum/component/body_storage/passage = GetComponent(/datum/component/body_storage)
	if(passage?.is_body_storage_insertion_blocked(egg, STORAGE_LAYER_DEEP))
		return src
	if(egg && !womb.accepts_oviposition_egg(egg, force))
		return src
	return womb

/obj/item/organ/genitals/filling_organ/vagina/get_availability(datum/species/owner_species, mob/living/C, datum/preferences/pref_load)
	return should_have_vagina_organ(C, pref_load)

/// Prefs decide for players; creatures and NPC bodies without prefs go by gender. The womb uses the same rule.
/proc/should_have_vagina_organ(mob/living/C, datum/preferences/pref_load)
	if(issimple(C))
		return C.gender == FEMALE
	if(pref_load)
		return pref_load.has_enabled_customizer_entry(/datum/customizer_entry/organ/genitals/vagina)
	return C.gender == FEMALE

