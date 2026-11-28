// Rain and wading rinse fluid off the skin and out of the clothes, bit by bit.

/// Units rinsed off one zone per rain tick, and per step through water.
#define FLUID_RINSE_RAIN_UNITS 0.5
#define FLUID_RINSE_WATER_UNITS 2
/// Percent chance per rinse that dried crust, or a soaked garment's last stain, washes away.
#define FLUID_RINSE_CRUST_CHANCE 5
/// Least time between two "rinsed clean" messages.
#define FLUID_RINSE_MESSAGE_COOLDOWN (5 MINUTES)

/mob/living/carbon/human
	COOLDOWN_DECLARE(fluid_rinse_message)

/// Called from SoakMob with the body flags getting wet; rinses coats on bare skin and the clothes over the rest.
/mob/living/carbon/human/proc/rinse_fluids(locations, rain)
	var/static/list/zone_flags = list(
		FLUID_COAT_FACE = FACE,
		FLUID_COAT_CHEST = CHEST,
		FLUID_COAT_BELLY = CHEST | VITALS,
		FLUID_COAT_GROIN = GROIN,
		FLUID_COAT_BACK = CHEST,
		FLUID_COAT_THIGHS = LEGS,
		FLUID_COAT_FEET = FEET,
	)
	var/units = rain ? FLUID_RINSE_RAIN_UNITS : FLUID_RINSE_WATER_UNITS
	var/datum/component/fluid_coated/coated = GetComponent(/datum/component/fluid_coated)
	var/list/rinsed_garments = list()
	var/rinsed = FALSE
	for(var/zone in zone_flags)
		if(!(zone_flags[zone] & locations))
			continue
		var/obj/item/clothing/cover = get_coat_zone_cover(zone)
		if(cover)
			if(cover in rinsed_garments)
				continue
			rinsed_garments += cover
			var/datum/component/fluid_soaked/soak = cover.GetComponent(/datum/component/fluid_soaked)
			if(soak?.rinse(units))
				rinsed = TRUE
		else if(coated?.rinse_zone(zone, units))
			rinsed = TRUE
		if(QDELETED(coated))
			coated = null
	if(rinsed && COOLDOWN_FINISHED(src, fluid_rinse_message))
		COOLDOWN_START(src, fluid_rinse_message, FLUID_RINSE_MESSAGE_COOLDOWN)
		to_chat(src, span_notice(rain ? "The rain rinses me clean." : "The water rinses me clean."))

/// Washes some wet fluid off a zone, or with luck the dried crust; TRUE when anything came off.
/datum/component/fluid_coated/proc/rinse_zone(zone, units)
	var/datum/fluid_coat/coat = coats[zone]
	if(!coat)
		return FALSE
	if(coat.is_wet())
		coat.fluids.remove_all(units)
		if(!coat.is_wet())
			remove_coat(zone)
		else
			update_coat_overlays()
		return TRUE
	if(prob(FLUID_RINSE_CRUST_CHANCE))
		remove_coat(zone)
		return TRUE
	return FALSE

/// Rain or water washes fluid out of a garment; once it runs clear, the stain may wash out too.
/datum/component/fluid_soaked/proc/rinse(units)
	var/obj/item/clothing/garment = parent
	if(garment.reagents?.total_volume)
		evaporate(units)
		return TRUE
	if((stain_level || coat_level || residue_kind) && prob(FLUID_RINSE_CRUST_CHANCE))
		garment.wash(CLEAN_WASH)
		return TRUE
	return FALSE

#undef FLUID_RINSE_RAIN_UNITS
#undef FLUID_RINSE_WATER_UNITS
#undef FLUID_RINSE_CRUST_CHANCE
#undef FLUID_RINSE_MESSAGE_COOLDOWN
