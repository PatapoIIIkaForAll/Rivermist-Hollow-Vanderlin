// Lubrication: any reagent with lubricity eases an opening; saliva and slick balm are made for it.

/// Units a reagent needs inside an opening before its sting, numbing, limbering or warming counts.
#define LUBE_EFFECT_MIN_UNITS 0.5
/// Receiver pain per cycle from each stinging reagent inside an opening.
#define LUBE_IRRITANT_PAIN 5
#define LUBE_NUMBING_PAIN_MULT 0.5
/// Strain a numbing balm lets pass before it hurts.
#define LUBE_NUMBING_STRAIN_SLACK 0.1
#define LUBE_LIMBER_ELASTICITY 0.3
/// Units a toy's lube coat holds.
#define TOY_LUBE_CAPACITY 5
#define SPIT_LUBE_UNITS 2
#define SPIT_HYDRATION_COST 2
#define FINGER_LUBE_UNITS 1
/// Fingering stretches a hole toward this girth, closing this share of the gap per cycle.
#define FINGER_STRETCH_GIRTH 8
#define FINGER_STRETCH_SHARE 0.04

/datum/reagent
	/// How slick this reagent is as a lubricant, 0 to 1.
	var/lubricity = 0
	/// How fast a hole loses this lube; above one fades faster than the organ's own tick.
	var/lube_fade = 1
	/// Stings inside an opening.
	var/irritant = FALSE
	/// Arousal per second the hole's owner gains while this lube is inside.
	var/lube_warming = 0

/datum/reagent/consumable/femcum
	lubricity = 0.8

/datum/reagent/consumable/cum
	lubricity = 0.6

/datum/reagent/consumable/milk
	lubricity = 0.3

/datum/reagent/consumable/honey
	lubricity = 0.35
	lube_fade = 0.5

/datum/reagent/consumable/herbal/rosa_oil
	lubricity = 0.9

/datum/reagent/medicine/herbal/mentha_oil
	lubricity = 0.9
	lube_warming = 0.1

/datum/reagent/medicine/woundwrack_oil
	lubricity = 0.9

/datum/reagent/medicine/fever_oil
	lubricity = 0.8

/datum/reagent/water
	lubricity = 0.15
	lube_fade = 3

/datum/reagent/blood
	lubricity = 0.2

/datum/reagent/consumable/ethanol
	irritant = TRUE

/datum/reagent/toxin/acid
	irritant = TRUE

/datum/reagent/rogueacid
	irritant = TRUE

/datum/reagent/consumable/saliva
	name = "Spittle"
	description = "Warm spit. Slick enough for a while."
	color = "#d7e3e8"
	taste_description = "someone's spit"
	lubricity = 0.5
	lube_fade = 2
	nutriment_factor = 0
	metabolization_rate = REAGENTS_METABOLISM

/// The slime a tentacle egg leaves behind: clinging, slick and slow to fade.
/datum/reagent/consumable/egg_slime
	name = "Egg Slime"
	description = "A clinging, wine-dark slime left behind by a tentacle egg. It stays slick for a long while."
	color = "#8a4f7a"
	taste_description = "something briny and alive"
	lubricity = 0.9
	lube_fade = 0.6
	nutriment_factor = 0
	metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/lubricant
	name = "Slick Balm"
	description = "A clear, slippery balm made for easing things in."
	color = "#f2f2e6"
	taste_description = "slick oil"
	lubricity = 1
	lube_fade = 0.7

/datum/reagent/lubricant/warming
	name = "Warming Balm"
	description = "Slick balm cut with mentha oil. It tingles, then warms wherever it is worked in."
	color = "#d4ecd0"
	taste_description = "slick mint"
	lube_warming = 0.2

/datum/reagent/lubricant/numbing
	name = "Numbing Balm"
	description = "Slick balm that dulls the flesh it touches, so a rough stretch hurts far less."
	color = "#d6e2ee"
	taste_description = "slick oil that numbs the tongue"

/datum/reagent/lubricant/limber
	name = "Limber Balm"
	description = "Slick balm with a drop of Phlogiston Elasticum in it. Flesh it touches gives and stretches."
	color = "#c8eef7"
	taste_description = "slick oil with a crackle of static"

/// Lube level of this opening from the lubricating reagents inside it.
/datum/orifice/proc/get_lube_level()
	var/datum/reagents/holder = organ?.reagents
	if(!holder?.total_volume)
		return 0
	var/slick = 0
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(reagent.lubricity > 0)
			slick += reagent.volume * reagent.lubricity
	return clamp(slick / LUBE_FULL_UNITS, 0, 1)

/// Adds lube into the opening; returns the units that fit.
/datum/orifice/proc/add_lube(reagent_type, amount, mob/living/giver)
	var/datum/reagents/holder = organ?.reagents
	if(!holder || amount <= 0 || !ispath(reagent_type, /datum/reagent))
		return 0
	var/room = max(0, holder.maximum_volume - holder.total_volume)
	var/added = min(amount, room)
	if(added <= 0)
		return 0
	holder.add_reagent(reagent_type, added)
	var/mob/living/owner = get_owner()
	if(giver && owner && giver != owner)
		owner.add_stress(/datum/stress_event/slick_and_ready)
	return added

/// Fast-fading lubes lose a little extra each fluid tick; warming lubes stir the owner.
/datum/orifice/proc/on_fluid_tick(seconds)
	var/datum/reagents/holder = organ?.reagents
	if(!holder?.total_volume)
		return
	var/warming = 0
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(reagent.lube_warming > 0 && reagent.volume >= LUBE_EFFECT_MIN_UNITS)
			warming += reagent.lube_warming
		if(reagent.lubricity <= 0 || reagent.lube_fade <= 1)
			continue
		holder.remove_reagent(reagent.type, LUBE_FADE_UNITS_PER_SECOND * (reagent.lube_fade - 1) * seconds)
	var/mob/living/owner = get_owner()
	if(owner && warming > 0)
		SEND_SIGNAL(owner, COMSIG_SEX_ADJUST_AROUSAL, warming * seconds)

/// Whether enough of a reagent sits inside the opening to take effect.
/datum/orifice/proc/has_lube_effect(reagent_type)
	return (organ?.reagents?.get_reagent_amount(reagent_type) || 0) >= LUBE_EFFECT_MIN_UNITS

/// Extra receiver pain per cycle from stinging reagents inside the opening.
/datum/orifice/proc/get_irritant_pain()
	. = 0
	var/datum/reagents/holder = organ?.reagents
	if(!holder?.total_volume)
		return
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(reagent.irritant && reagent.volume >= LUBE_EFFECT_MIN_UNITS)
			. += LUBE_IRRITANT_PAIN

/// Pain multiplier from numbing balms inside the opening.
/datum/orifice/proc/get_numbing_multiplier()
	// A numbing balm inside, or a spider's silk-venom in the blood, dulls the opening the same way.
	if(has_lube_effect(/datum/reagent/lubricant/numbing))
		return LUBE_NUMBING_PAIN_MULT
	if(get_owner()?.reagents?.has_reagent(/datum/reagent/toxin/spidervenom_paralytic/weak))
		return LUBE_NUMBING_PAIN_MULT
	return 1

/// Comfort elasticity added by limbering balms inside the opening.
/datum/orifice/proc/get_lube_elasticity_bonus()
	return has_lube_effect(/datum/reagent/lubricant/limber) ? LUBE_LIMBER_ELASTICITY : 0

/// Moves part of the lube on the penetrator's penis or toy into the opening on entry.
/datum/orifice/proc/transfer_penetrator_lube(datum/sex_action/action, mob/living/penetrator)
	if(istype(action, /datum/sex_action/object_fuck))
		var/datum/sex_action/object_fuck/toy_action = action
		var/obj/item/dildo/toy = toy_action.selected_toy
		if(istype(toy))
			take_lube_from(toy.get_lube_reagents(FALSE))
		return
	// A toy in a worn harness keeps its own lube as well as the wearer's groin coat.
	var/obj/item/dildo/strapon_toy = penetrator?.get_strapon_toy()
	if(strapon_toy)
		take_lube_from(strapon_toy.get_lube_reagents(FALSE))
	var/datum/component/fluid_coated/coated = penetrator?.GetComponent(/datum/component/fluid_coated)
	if(!coated)
		return
	var/datum/fluid_coat/coat = coated.coats[FLUID_COAT_GROIN]
	if(!coat?.is_wet() || take_lube_from(coat.fluids) <= 0)
		return
	if(coat.fluids.total_volume)
		coated.update_coat_overlays()
	else
		coated.remove_coat(FLUID_COAT_GROIN)

/// Moves the transfer share of each lubricating reagent in [source] into the opening; returns units moved.
/datum/orifice/proc/take_lube_from(datum/reagents/source)
	. = 0
	var/datum/reagents/holder = organ?.reagents
	if(!holder || !source?.total_volume)
		return
	for(var/datum/reagent/reagent as anything in source.reagent_list)
		if(reagent.lubricity > 0)
			. += source.trans_id_to(holder, reagent.type, reagent.volume * LUBE_TRANSFER_SHARE) || 0

/// Pours from a container into the opening, holding back stinging reagents; returns the units poured.
/datum/orifice/proc/pour_lube(obj/item/reagent_containers/container, amount, mob/living/giver)
	. = 0
	var/datum/reagents/source = container?.reagents
	if(!organ?.reagents || !source?.total_volume || amount <= 0)
		return
	var/list/irritants = list()
	var/list/irritant_names = list()
	for(var/datum/reagent/reagent as anything in source.reagent_list)
		if(reagent.irritant)
			irritants += reagent.type
			irritant_names += LOWER_TEXT(reagent.name)
	if(giver && length(irritants))
		to_chat(giver, span_warning("I keep the [english_list(irritant_names)] out of it; that would only sting."))
	. = source.trans_to(organ, amount, transfered_by = giver, ignored_reagents = irritants) || 0
	var/mob/living/owner = get_owner()
	if(. > 0 && giver && owner && giver != owner)
		owner.add_stress(/datum/stress_event/slick_and_ready)

/// Highest lubricity among a container's non-stinging reagents; zero for anything else.
/proc/get_container_lubricity(obj/item/reagent_containers/container)
	. = 0
	if(!istype(container) || !container.reagents?.total_volume)
		return
	for(var/datum/reagent/reagent as anything in container.reagents.reagent_list)
		if(!reagent.irritant)
			. = max(., reagent.lubricity)

/// Works the best lube at hand into [hole]: a held balm or oil first, else spit.
/mob/living/proc/lube_up_hole(datum/orifice/hole)
	if(!hole?.get_owner())
		return FALSE
	var/obj/item/reagent_containers/container = get_held_lube_container()
	if(container)
		if(hole.pour_lube(container, LUBE_APPLY_UNITS, src) <= 0)
			to_chat(src, span_warning("There is no room for more in there."))
			return FALSE
		announce_lube(hole, "something slick from \the [container]")
		return TRUE
	return spit_lube_into(hole)

/// Slicks a held toy from a container in the other hand, else with spit.
/mob/living/proc/lube_up_toy(obj/item/dildo/toy)
	if(!toy)
		return FALSE
	var/datum/reagents/coat = toy.get_lube_reagents(TRUE)
	var/obj/item/reagent_containers/container = get_held_lube_container()
	if(container)
		var/list/irritants = list()
		for(var/datum/reagent/reagent as anything in container.reagents.reagent_list)
			if(reagent.irritant)
				irritants += reagent.type
		if(container.reagents.trans_to(coat, LUBE_APPLY_UNITS, transfered_by = src, ignored_reagents = irritants) <= 0)
			to_chat(src, span_warning("\The [toy] is as slick as it will get."))
			return FALSE
		visible_message(span_notice("[src] slicks \the [toy] with something from \the [container]."), span_notice("I slick \the [toy] with something from \the [container]."))
		return TRUE
	if(!mouth_is_free(src, cloth_blocks = TRUE))
		to_chat(src, span_warning("My mouth is not free to spit."))
		return FALSE
	if(coat.total_volume + SPIT_LUBE_UNITS > coat.maximum_volume)
		to_chat(src, span_warning("\The [toy] is as slick as it will get."))
		return FALSE
	coat.add_reagent(/datum/reagent/consumable/saliva, SPIT_LUBE_UNITS)
	adjust_hydration(-SPIT_HYDRATION_COST)
	visible_message(span_notice("[src] spits on \the [toy] and works it over."), span_notice("I spit on \the [toy] and work it over."))
	var/spit_sound = gender == MALE ? pick('sound/vo/male/gen/spit.ogg', 'sound/vo/male/gen/spit_floor.ogg') : pick('sound/vo/female/gen/spit.ogg', 'sound/vo/female/gen/spit_floor.ogg')
	playsound(src, spit_sound, 50, FALSE, -1)
	return TRUE

/// Strain a numbing balm lets pass before it hurts.
/datum/orifice/proc/get_strain_slack()
	return has_lube_effect(/datum/reagent/lubricant/numbing) ? LUBE_NUMBING_STRAIN_SLACK : 0

/// The held container with the slickest lube, active hand first on a tie.
/mob/living/proc/get_held_lube_container()
	RETURN_TYPE(/obj/item/reagent_containers)
	var/best = 0
	for(var/obj/item/held as anything in list(get_active_held_item(), get_inactive_held_item()))
		var/lubricity = get_container_lubricity(held)
		if(lubricity > best)
			best = lubricity
			. = held

/// Tells the room this mob worked [what] into an opening.
/mob/living/proc/announce_lube(datum/orifice/hole, what)
	var/mob/living/owner = hole.get_owner()
	if(owner == src)
		visible_message(span_notice("[src] works [what] into [p_their()] [hole.opening_name]."), span_notice("I work [what] into my [hole.opening_name]."))
	else
		visible_message(span_notice("[src] works [what] into [owner]'s [hole.opening_name]."), span_notice("I work [what] into [owner]'s [hole.opening_name]."))
	playsound(owner, 'sound/misc/mat/endin.ogg', 20, TRUE)

/// Spits into an opening and works it in, for a little water; TRUE when the spit went in.
/mob/living/proc/spit_lube_into(datum/orifice/hole)
	var/mob/living/owner = hole?.get_owner()
	if(!owner)
		return FALSE
	if(!mouth_is_free(src, cloth_blocks = TRUE))
		to_chat(src, span_warning("My mouth is not free to spit."))
		return FALSE
	if(hole.add_lube(/datum/reagent/consumable/saliva, SPIT_LUBE_UNITS, src) <= 0)
		to_chat(src, span_warning("There is no room for spit in there."))
		return FALSE
	adjust_hydration(-SPIT_HYDRATION_COST)
	if(owner == src)
		visible_message(span_notice("[src] spits into [p_their()] palm and works it into [p_their()] [hole.opening_name]."), span_notice("I spit into my palm and work it into my [hole.opening_name]."))
	else
		visible_message(span_notice("[src] spits on [owner]'s [hole.opening_name] and works it in."), span_notice("I spit on [owner]'s [hole.opening_name] and work it in."))
		SEND_SIGNAL(src, COMSIG_SPAT_ON, owner)
	var/spit_sound = gender == MALE ? pick('sound/vo/male/gen/spit.ogg', 'sound/vo/male/gen/spit_floor.ogg') : pick('sound/vo/female/gen/spit.ogg', 'sound/vo/female/gen/spit_floor.ogg')
	playsound(owner, spit_sound, 50, FALSE, -1)
	return TRUE

// ---- Oral deposits ----

/// Saliva from an oral act into an opening, never past [cap] units of saliva inside; returns units added.
/proc/deposit_saliva_in_hole(mob/living/giver, mob/living/holder_mob, organ_slot, amount, cap)
	var/obj/item/organ/genitals/filling_organ/hole_organ = holder_mob?.getorganslot(organ_slot)
	if(!istype(hole_organ) || !hole_organ.orifice_type || !hole_organ.reagents)
		return 0
	var/room = cap - hole_organ.reagents.get_reagent_amount(/datum/reagent/consumable/saliva)
	if(room <= 0)
		return 0
	return hole_organ.get_orifice().add_lube(/datum/reagent/consumable/saliva, min(amount, room), giver)

/// Saliva from an oral act onto the penis owner's crotch coat, never past [cap] units there; returns units added.
/proc/coat_penis_with_saliva(mob/living/giver, mob/living/penis_owner, amount, cap)
	if(!ishuman(penis_owner) || !penis_owner.getorganslot(ORGAN_SLOT_PENIS))
		return 0
	var/datum/component/fluid_coated/coated = penis_owner.GetComponent(/datum/component/fluid_coated)
	var/current = 0
	if(coated)
		var/datum/fluid_coat/coat = coated.coats[FLUID_COAT_GROIN]
		current = coat?.fluids?.get_reagent_amount(/datum/reagent/consumable/saliva) || 0
	var/to_add = min(amount, cap - current)
	if(to_add <= 0)
		return 0
	var/datum/reagents/spit = new /datum/reagents(to_add, NO_REACT)
	spit.add_reagent(/datum/reagent/consumable/saliva, to_add)
	// The cock is out for the act, so clothing over the crotch must not soak this up.
	coated = penis_owner.LoadComponent(/datum/component/fluid_coated)
	. = coated.add_coat(FLUID_COAT_GROIN, spit, to_add)
	qdel(spit)

// ---- Toys ----

/obj/item/dildo
	/// Lube coating the toy; made on first use.
	var/datum/reagents/lube_reagents

/// The toy's lube coat, made on demand.
/obj/item/dildo/proc/get_lube_reagents(create = TRUE)
	RETURN_TYPE(/datum/reagents)
	if(!lube_reagents && create)
		lube_reagents = new /datum/reagents(TOY_LUBE_CAPACITY, NO_REACT)
	return lube_reagents

/obj/item/dildo/Destroy(force)
	QDEL_NULL(lube_reagents)
	return ..()

// ---- Fingering ----

/datum/sex_action
	/// Set once fingering has tried the off-hand lube this run.
	var/lube_applied_this_run = FALSE

/// Fingering slicks the hole from a lube container in the off hand, once per run.
/datum/sex_action/proc/apply_finger_lube(mob/living/user, mob/living/hole_owner, organ_slot)
	if(lube_applied_this_run)
		return
	var/obj/item/reagent_containers/container = user?.get_inactive_held_item()
	if(get_container_lubricity(container) <= 0)
		return
	var/obj/item/organ/genitals/filling_organ/hole_organ = hole_owner?.getorganslot(organ_slot)
	if(!istype(hole_organ) || !hole_organ.orifice_type)
		return
	lube_applied_this_run = TRUE
	if(hole_organ.get_orifice().pour_lube(container, FINGER_LUBE_UNITS, user) > 0)
		to_chat(user, span_notice("I slick my fingers from \the [container] first."))

/// Rough, slick fingering slowly opens the hole toward a two-finger width.
/datum/sex_action/proc/stretch_with_fingers(mob/living/hole_owner, organ_slot)
	if(force < SEX_FORCE_HIGH)
		return
	var/obj/item/organ/genitals/filling_organ/hole_organ = hole_owner?.getorganslot(organ_slot)
	if(!istype(hole_organ) || !hole_organ.orifice_type)
		return
	var/datum/orifice/orifice = hole_organ.get_orifice()
	if(orifice.get_lube_level() >= LUBE_DRY_LEVEL)
		orifice.stretch_toward(FINGER_STRETCH_GIRTH, force, FINGER_STRETCH_SHARE)

#undef LUBE_EFFECT_MIN_UNITS
#undef LUBE_IRRITANT_PAIN
#undef LUBE_NUMBING_PAIN_MULT
#undef LUBE_NUMBING_STRAIN_SLACK
#undef LUBE_LIMBER_ELASTICITY
#undef TOY_LUBE_CAPACITY
#undef SPIT_LUBE_UNITS
#undef SPIT_HYDRATION_COST
#undef FINGER_LUBE_UNITS
#undef FINGER_STRETCH_GIRTH
#undef FINGER_STRETCH_SHARE
