// Body fluid soaking into clothes: wet spots, drying, lingering smell, wringing and dipping.

#define FLUID_STAIN_ICON 'modular_rmh/icons/obj/genitals/fluid_stains.dmi'
/// Semen globs in two levels and three variants: "semen_[level]_[variant]".
#define SEMEN_COAT_ICON 'modular_rmh/icons/obj/genitals/semen_coat.dmi'
#define SEMEN_COAT_VARIANTS 3
/// Units of semen that start a coat, and the share of capacity that makes it heavy.
#define SEMEN_COAT_MIN 1
#define SEMEN_COAT_HEAVY_RATIO 0.5
/// A garment shows a damp spot from this share of its capacity, and a soaked one from the next.
#define FLUID_STAIN_DAMP_RATIO 0.2
#define FLUID_STAIN_SOAKED_RATIO 0.6
/// Alpha of the grey wet spot drawn over a worn garment.
#define FLUID_STAIN_ALPHA 100
/// Units of soaked fluid that evaporate per second.
#define FLUID_EVAPORATION_PER_SECOND (1 / 60)
/// How often a fluid-dirty garment adds its smell to the air, and how much.
#define FLUID_SCENT_INTERVAL (1 MINUTES)
#define FLUID_SCENT_AMOUNT 15
#define FLUID_SCENT_CAP 20
#define FLUID_WRING_TIME (2 SECONDS)
#define FLUID_DIP_TIME (1 SECONDS)
/// Time to lick a held garment; pressing it to someone else's mouth takes twice as long.
#define FLUID_LICK_TIME (1.5 SECONDS)

/obj/item/clothing
	/// Units of body fluid this garment soaks up before fluid drips through; 0 means it does not soak.
	var/fluid_capacity = 0
	/// Where fluid dipped into this garment shows a wet spot.
	var/fluid_stain_zone = FLUID_STAIN_GROIN

/obj/item/clothing/undies
	fluid_capacity = 10

/obj/item/clothing/bra
	fluid_capacity = 10
	fluid_stain_zone = FLUID_STAIN_CHEST

/obj/item/clothing/pants
	fluid_capacity = 20

/obj/item/clothing/shirt
	fluid_capacity = 15
	fluid_stain_zone = FLUID_STAIN_CHEST

/// Only cloth soaks; metal and chain let nothing through and hold the fluid in.
/obj/item/clothing/proc/can_soak_fluid()
	return fluid_capacity > 0 && material_category == ARMOR_MAT_FABRIC

/// Soaks up to amount from source and returns the units taken.
/obj/item/clothing/proc/soak_fluid(datum/reagents/source, amount, stain_zone = fluid_stain_zone)
	if(!source?.total_volume || amount <= 0 || !can_soak_fluid())
		return 0
	var/datum/component/fluid_soaked/soak = LoadComponent(/datum/component/fluid_soaked)
	return soak.soak(source, amount, stain_zone)

/// Heat or a drying rack speeds up evaporation of soaked body fluid.
/obj/item/clothing/proc/dry_soaked_fluid(amount)
	var/datum/component/fluid_soaked/soak = GetComponent(/datum/component/fluid_soaked)
	soak?.evaporate(amount)

/// Makes sure the garment can take fluid poured straight into it, such as a climax.
/obj/item/clothing/proc/prepare_fluid_holder()
	return can_soak_fluid() ? LoadComponent(/datum/component/fluid_soaked) : null

/obj/item/clothing/proc/has_soaked_fluid()
	return reagents?.total_volume > 0 && GetComponent(/datum/component/fluid_soaked)

/obj/item/clothing/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, dummy_block = FALSE)
	. = ..()
	if(isinhands)
		return
	var/datum/component/fluid_soaked/soak = GetComponent(/datum/component/fluid_soaked)
	if(soak)
		. += soak.get_stain_overlays(standing)

/// A container used on a wet garment gets it wrung out into it.
/obj/item/clothing/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/reagent_containers) && tool.is_refillable() && has_soaked_fluid())
		return wring_into(tool, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	return ..()

/// A held garment is licked when aimed at a mouth, wrung onto the floor, or dipped into a container.
/obj/item/clothing/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!can_soak_fluid())
		return ..()
	if(isliving(interacting_with) && user.zone_selected == BODY_ZONE_PRECISE_MOUTH && has_soaked_fluid())
		return lick_soaked_fluid(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	if(isopenturf(interacting_with) && has_soaked_fluid())
		return wring_onto(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	if(istype(interacting_with, /obj/item/reagent_containers) && interacting_with.is_open_container() && interacting_with.reagents?.total_volume)
		return dip_into(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/clothing/proc/wring_into(obj/item/reagent_containers/container, mob/living/user)
	if(container.reagents.holder_full())
		to_chat(user, span_warning("\The [container] is full."))
		return FALSE
	if(!do_after(user, FLUID_WRING_TIME, container) || !pour_soaked_fluid_into(container, user))
		return FALSE
	user.visible_message(span_small("[user] wrings \the [src] out into \the [container]."), span_small("I wring \the [src] out into \the [container]."), vision_distance = 2)
	playsound(container, pick('sound/foley/waterwash (1).ogg', 'sound/foley/waterwash (2).ogg'), 25, FALSE)
	return TRUE

/obj/item/clothing/proc/wring_onto(turf/open/target_turf, mob/living/user)
	if(!do_after(user, FLUID_WRING_TIME, target_turf) || !spill_soaked_fluid_onto(target_turf))
		return FALSE
	user.visible_message(span_small("[user] wrings \the [src] out."), span_small("I wring \the [src] out."), vision_distance = 2)
	playsound(target_turf, pick('sound/foley/waterwash (1).ogg', 'sound/foley/waterwash (2).ogg'), 25, FALSE)
	return TRUE

/obj/item/clothing/proc/lick_soaked_fluid(mob/living/licker, mob/living/user)
	if(licker.is_mouth_covered())
		to_chat(user, span_warning("[licker == user ? "My" : "[licker]'s"] mouth is covered."))
		return FALSE
	if(!do_after(user, licker == user ? FLUID_LICK_TIME : FLUID_LICK_TIME * 2, licker) || !drink_soaked_fluid(licker, user))
		return FALSE
	if(licker == user)
		user.visible_message(span_love("[user] sucks on \the [src]."), span_love("I suck the fluid out of \the [src]."), vision_distance = 2)
	else
		user.visible_message(span_love("[user] presses \the [src] to [licker]'s mouth."), span_love("I press \the [src] to [licker]'s mouth."), vision_distance = 2)
	return TRUE

/// Moves a mouthful of soaked fluid into a mob and returns the units swallowed.
/obj/item/clothing/proc/drink_soaked_fluid(mob/living/drinker, mob/living/user)
	. = sip_reagents(reagents, drinker, FLUID_LICK_AMOUNT, user)
	var/datum/component/fluid_soaked/soak = GetComponent(/datum/component/fluid_soaked)
	soak?.update_stain()

/// Moves a mouthful from a holder into a mob with a taste message, and returns the units swallowed.
/proc/sip_reagents(datum/reagents/source, mob/living/drinker, amount, mob/living/user)
	if(!source?.total_volume || !drinker?.reagents)
		return 0
	drinker.taste(source)
	return source.trans_to(drinker, min(amount, source.total_volume), transfered_by = user, method = INGEST, show_message = FALSE) || 0

/// Moves the soaked fluid into a container and returns the units moved.
/obj/item/clothing/proc/pour_soaked_fluid_into(obj/item/reagent_containers/container, mob/living/user)
	if(!reagents?.total_volume)
		return 0
	. = reagents.trans_to(container, reagents.total_volume, transfered_by = user) || 0
	var/datum/component/fluid_soaked/soak = GetComponent(/datum/component/fluid_soaked)
	soak?.update_stain()

/// Spills the soaked fluid onto a turf, as a drop or a puddle, and returns the units spilled.
/obj/item/clothing/proc/spill_soaked_fluid_onto(turf/open/target_turf)
	if(!reagents?.total_volume)
		return 0
	. = reagents.total_volume
	spill_fluid_to_turf(target_turf, reagents, .)
	var/datum/component/fluid_soaked/soak = GetComponent(/datum/component/fluid_soaked)
	soak?.update_stain()

/obj/item/clothing/proc/dip_into(obj/item/reagent_containers/container, mob/living/user)
	var/free_space = fluid_capacity - (reagents?.total_volume || 0)
	if(free_space <= 0)
		to_chat(user, span_warning("\The [src] is already soaked."))
		return FALSE
	if(!do_after(user, FLUID_DIP_TIME, container))
		return FALSE
	if(!soak_fluid(container.reagents, free_space))
		return FALSE
	user.visible_message(span_small("[user] dips \the [src] into \the [container]."), span_small("I dip \the [src] into \the [container]."), vision_distance = 2)
	playsound(container, pick('sound/foley/waterwash (1).ogg', 'sound/foley/waterwash (2).ogg'), 25, FALSE)
	return TRUE

/// The outermost worn garment others see over a stain zone: trousers or shirt if they cover it, else underwear.
/mob/living/carbon/human/proc/get_visible_cover(stain_zone)
	if(stain_zone == FLUID_STAIN_CHEST)
		return (wear_shirt?.flags_inv & HIDEBOOB) ? wear_shirt : bra
	return (wear_pants?.flags_inv & HIDECROTCH) ? wear_pants : underwear

/// The visible garment over a stain zone if it holds enough fluid to lick, else null.
/mob/living/carbon/human/proc/get_soaked_cover(stain_zone)
	var/obj/item/clothing/garment = get_visible_cover(stain_zone)
	if(!istype(garment) || garment.reagents?.total_volume < FLUID_LICK_MIN_VOLUME)
		return null
	return garment

/// Examine lines for wet spots on the outermost garment over the groin and the chest.
/mob/living/carbon/human/proc/get_fluid_stain_examine(list/P)
	. = list()
	for(var/obj/item/clothing/garment as anything in list(get_visible_cover(FLUID_STAIN_GROIN), get_visible_cover(FLUID_STAIN_CHEST)))
		if(!istype(garment))
			continue
		var/datum/component/fluid_soaked/soak = garment.GetComponent(/datum/component/fluid_soaked)
		if(!soak?.stain_level)
			continue
		if(soak.stain_level >= 2)
			. += "[capitalize(P[THEIR])] [garment.name] [garment.gender == PLURAL ? "are" : "is"] soaked through."
		else
			. += "[capitalize(P[THEYVE])] a damp spot on [P[THEIR]] [garment.name]."
	var/obj/item/clothing/shoes/heels/heels = shoes
	if(istype(heels) && heels.is_squelching())
		. += "[capitalize(P[THEIR])] heels squelch wetly."

/// Body fluid held by a garment: it dries slowly, leaves a smelly stain until washed, and draws a grey wet spot.
/datum/component/fluid_soaked
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Zones that show a wet spot while the garment is wet.
	var/list/stain_zones
	/// Wet spot drawn now: 0 dry, 1 damp, 2 soaked.
	var/stain_level = 0
	/// Name of the main fluid, kept as a dried stain until washed.
	var/residue_name
	/// Smell given off until washed.
	var/datum/pollutant/residue_scent
	/// Semen globs drawn now: 0 none, 1 light or dried, 2 heavy.
	var/coat_level = 0
	/// Which glob pattern this garment uses, so it keeps its look between redraws.
	var/coat_variant = 1
	/// Semen once soaked in; the dried crust stays until washed.
	var/had_semen = FALSE
	COOLDOWN_DECLARE(scent_cooldown)

/datum/component/fluid_soaked/Initialize()
	var/obj/item/clothing/garment = parent
	if(!istype(garment))
		return COMPONENT_INCOMPATIBLE
	if(!garment.reagents)
		garment.create_reagents(garment.fluid_capacity, NO_REACT)
	coat_variant = rand(1, SEMEN_COAT_VARIANTS)
	START_PROCESSING(SSobj, src)

/datum/component/fluid_soaked/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))

/datum/component/fluid_soaked/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_ATOM_UPDATE_OVERLAYS))

/datum/component/fluid_soaked/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/fluid_soaked/proc/soak(datum/reagents/source, amount, stain_zone)
	var/obj/item/clothing/garment = parent
	amount = min(amount, garment.reagents.maximum_volume - garment.reagents.total_volume)
	if(amount <= 0)
		return 0
	amount = source.trans_to(garment, amount, no_react = TRUE) || 0
	if(amount <= 0)
		return 0
	LAZYOR(stain_zones, stain_zone)
	note_main_fluid()
	update_stain()
	return amount

/// Remembers the main fluid, so its stain and smell outlast the drying.
/datum/component/fluid_soaked/proc/note_main_fluid()
	var/obj/item/clothing/garment = parent
	var/datum/reagent/main_fluid = garment.reagents.get_master_reagent()
	if(!main_fluid || istype(main_fluid, /datum/reagent/water))
		return
	residue_name = LOWER_TEXT(main_fluid.name)
	residue_scent = get_fluid_scent(main_fluid.type)

/datum/component/fluid_soaked/proc/evaporate(amount)
	var/obj/item/clothing/garment = parent
	if(amount <= 0 || !garment.reagents.total_volume)
		return
	garment.reagents.remove_all(amount)
	update_stain()

/datum/component/fluid_soaked/process(delta_time)
	var/obj/item/clothing/garment = parent
	// Fluid can also arrive by direct transfer, such as a climax into the garment.
	if(garment.reagents.total_volume)
		if(!stain_zones)
			LAZYOR(stain_zones, garment.fluid_stain_zone)
		note_main_fluid()
	evaporate(FLUID_EVAPORATION_PER_SECOND * delta_time)
	update_stain()
	if(residue_scent && COOLDOWN_FINISHED(src, scent_cooldown))
		COOLDOWN_START(src, scent_cooldown, FLUID_SCENT_INTERVAL)
		var/turf/garment_turf = get_turf(garment)
		garment_turf?.pollute_turf(residue_scent, FLUID_SCENT_AMOUNT, FLUID_SCENT_CAP)
	if(!garment.reagents.total_volume && !residue_scent)
		qdel(src)

/// Redraws the garment when its wet spot or semen coat changes.
/datum/component/fluid_soaked/proc/update_stain()
	var/obj/item/clothing/garment = parent
	var/fullness = garment.reagents.maximum_volume ? garment.reagents.total_volume / garment.reagents.maximum_volume : 0
	var/new_level = 0
	if(fullness >= FLUID_STAIN_SOAKED_RATIO)
		new_level = 2
	else if(fullness >= FLUID_STAIN_DAMP_RATIO)
		new_level = 1
	// Summed by hand: get_reagent_amount stops at the first match, missing sterile semen mixed with virile.
	var/semen = 0
	for(var/datum/reagent/consumable/cum/seed in garment.reagents.reagent_list)
		semen += seed.volume
	if(semen >= SEMEN_COAT_MIN)
		had_semen = TRUE
	var/new_coat = 0
	if(semen >= garment.fluid_capacity * SEMEN_COAT_HEAVY_RATIO)
		new_coat = 2
	else if(had_semen)
		new_coat = 1
	if(new_level == stain_level && new_coat == coat_level)
		return
	var/coat_changed = new_coat != coat_level
	stain_level = new_level
	coat_level = new_coat
	if(!stain_level)
		stain_zones = null
	garment.update_slot_icon()
	if(coat_changed)
		garment.update_appearance(UPDATE_OVERLAYS)

/datum/component/fluid_soaked/proc/get_coat_state()
	return "semen_[coat_level]_[coat_variant]"

/datum/component/fluid_soaked/proc/get_stain_overlays(mutable_appearance/standing)
	. = list()
	if((!stain_level && !coat_level) || !standing?.icon || istype(standing.icon, /icon))
		return
	if(stain_level)
		for(var/zone in stain_zones)
			var/mutable_appearance/stain = mutable_appearance(get_clipped_fluid_pattern(standing.icon, standing.icon_state, FLUID_STAIN_ICON, "[zone]_[stain_level]"))
			stain.alpha = FLUID_STAIN_ALPHA
			stain.appearance_flags = RESET_COLOR|RESET_ALPHA
			. += stain
	if(coat_level)
		var/mutable_appearance/coat = mutable_appearance(get_clipped_fluid_pattern(standing.icon, standing.icon_state, SEMEN_COAT_ICON, get_coat_state()))
		coat.appearance_flags = RESET_COLOR|RESET_ALPHA
		. += coat

/// Draws the semen coat on the garment's own icon, in hand or on the floor.
/datum/component/fluid_soaked/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	var/obj/item/clothing/garment = parent
	if(!coat_level || !garment.icon || istype(garment.icon, /icon))
		return
	var/mutable_appearance/coat = mutable_appearance(get_clipped_fluid_pattern(garment.icon, garment.icon_state, SEMEN_COAT_ICON, get_coat_state(), TRUE))
	coat.appearance_flags = RESET_COLOR|RESET_ALPHA
	overlays += coat

/datum/component/fluid_soaked/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/obj/item/clothing/garment = parent
	var/datum/reagent/main_fluid = garment.reagents?.get_master_reagent()
	if(main_fluid)
		var/fluid_name = LOWER_TEXT(main_fluid.name)
		switch(stain_level)
			if(2)
				examine_list += span_warning("It is soaked through with [fluid_name].")
			if(1)
				examine_list += span_notice("It is damp with [fluid_name].")
			else
				examine_list += span_notice("It is faintly moist with [fluid_name].")
	else if(residue_name)
		examine_list += span_notice("It has dried stains of [residue_name].")

/// Washing or scrubbing removes the fluid, the stain and the smell.
/datum/component/fluid_soaked/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!(clean_types & CLEAN_TYPE_BLOOD))
		return
	var/obj/item/clothing/garment = parent
	QDEL_NULL(garment.reagents)
	var/was_drawn = stain_level || coat_level
	var/was_coated = coat_level
	stain_level = 0
	stain_zones = null
	coat_level = 0
	had_semen = FALSE
	if(was_drawn)
		garment.update_slot_icon()
	if(was_coated)
		garment.update_appearance(UPDATE_OVERLAYS)
	qdel(src)

/// A pattern shaped to a sprite: the sprite's silhouette filled white, then multiplied by the pattern.
/proc/get_clipped_fluid_pattern(icon_file, icon_state, pattern_file, pattern_state, single_dir = FALSE)
	var/static/list/pattern_cache = list()
	// Generated icons all print as "", so key on the reference instead.
	var/cache_key = "[REF(icon_file)]|[icon_state]|[pattern_file]|[pattern_state]|[single_dir]"
	. = pattern_cache[cache_key]
	if(.)
		return
	var/icon/clipped = single_dir ? icon(icon_file, icon_state, SOUTH) : icon(icon_file, icon_state)
	clipped.Blend("#fff", ICON_ADD)
	clipped.Blend(single_dir ? icon(pattern_file, pattern_state, SOUTH) : icon(pattern_file, pattern_state), ICON_MULTIPLY)
	. = fcopy_rsc(clipped)
	pattern_cache[cache_key] = .

/proc/get_fluid_scent(datum/reagent/reagent_type)
	if(ispath(reagent_type, /datum/reagent/consumable/milk))
		return /datum/pollutant/body_fluid/milk
	if(ispath(reagent_type, /datum/reagent/consumable/cum))
		return /datum/pollutant/body_fluid/seed
	if(ispath(reagent_type, /datum/reagent/consumable/femcum))
		return /datum/pollutant/body_fluid/nectar
	return /datum/pollutant/body_fluid/stale

/// Smells left by body fluid on unwashed clothes; plain smells, so nobody's mood changes.
/datum/pollutant/body_fluid
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL

/datum/pollutant/body_fluid/milk
	name = "stale milk"
	scent = "stale milk"

/datum/pollutant/body_fluid/seed
	name = "musky seed"
	scent = "musky seed"

/datum/pollutant/body_fluid/nectar
	name = "sweet musk"
	scent = "sweet musk"

/datum/pollutant/body_fluid/stale
	name = "stale fluids"
	scent = "stale bodily fluids"

#undef FLUID_STAIN_ICON
#undef SEMEN_COAT_ICON
#undef SEMEN_COAT_VARIANTS
#undef SEMEN_COAT_MIN
#undef SEMEN_COAT_HEAVY_RATIO
#undef FLUID_STAIN_DAMP_RATIO
#undef FLUID_STAIN_SOAKED_RATIO
#undef FLUID_STAIN_ALPHA
#undef FLUID_EVAPORATION_PER_SECOND
#undef FLUID_SCENT_INTERVAL
#undef FLUID_SCENT_AMOUNT
#undef FLUID_SCENT_CAP
#undef FLUID_WRING_TIME
#undef FLUID_DIP_TIME
#undef FLUID_LICK_TIME
