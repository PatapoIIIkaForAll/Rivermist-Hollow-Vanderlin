// Pillows to carry and hump: gather up mapped pillows or sew new ones; they soak up body fluid and keep it a while.

#define PILLOW_FLUID_CAPACITY 20
/// A pillow reads soaked through from this share of its capacity.
#define PILLOW_SOAKED_RATIO 0.5
#define PILLOW_DRY_PER_SECOND (1 / 30)
#define PILLOW_SCENT_INTERVAL (1 MINUTES)
#define PILLOW_SCENT_AMOUNT 10
#define PILLOW_SCENT_CAP 20
#define PILLOW_GATHER_TIME (1 SECONDS)

/obj/structure/fluff/pillow
	gender = PLURAL

/obj/item/pillow
	name = "pillows"
	desc = "A pair of soft plush pillows. Resting your head on one is so relaxing."
	gender = PLURAL
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "pillow"
	lefthand_file = 'icons/mob/inhands/misc/bedsheet_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/bedsheet_righthand.dmi'
	item_state = "sheetwhite"
	w_class = WEIGHT_CLASS_NORMAL
	item_weight = 600 GRAMS
	throwforce = 0
	throw_speed = 1
	throw_range = 3
	resistance_flags = FLAMMABLE

/datum/repeatable_crafting_recipe/sewing/pillows
	name = "pillows"
	output = /obj/item/pillow
	requirements = list(
		/obj/item/natural/cloth = 2,
		/obj/item/natural/fibers = 2,
	)
	craftdiff = 1
	category = "Misc Sewing"

/proc/is_pillow(atom/thing)
	return istype(thing, /obj/structure/fluff/pillow) || istype(thing, /obj/item/pillow)

/// An empty hand gathers mapped pillows up into pillows to carry.
/obj/structure/fluff/pillow/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !istype(user) || user.cmode)
		return
	to_chat(user, span_notice("I start gathering up \the [src]."))
	if(!do_after(user, PILLOW_GATHER_TIME, src) || QDELETED(src))
		return TRUE
	var/obj/item/pillow/pillows = new(drop_location())
	pillows.color = color
	if(reagents?.total_volume)
		pillows.LoadComponent(/datum/component/damp_pillow)
		reagents.trans_to(pillows.reagents, reagents.total_volume)
	user.put_in_hands(pillows)
	user.visible_message(span_notice("[user] gathers up \the [pillows]."), span_notice("I gather up \the [pillows]."))
	qdel(src)
	return TRUE

/// Soaks up to amount from source into a pillow; returns the units taken.
/proc/soak_pillow(atom/pillow, datum/reagents/source, amount, mob/living/fluid_owner)
	if(!is_pillow(pillow) || !source?.total_volume || amount <= 0)
		return 0
	pillow.LoadComponent(/datum/component/damp_pillow)
	var/room = pillow.reagents.maximum_volume - pillow.reagents.total_volume
	if(room <= 0)
		return 0
	var/datum/reagent/main = source.get_master_reagent()
	. = source.trans_to(pillow.reagents, min(amount, room), transfered_by = fluid_owner)
	if(. && fluid_owner)
		leave_fluid_scent(get_turf(pillow), fluid_owner, get_fluid_scent_kind(main))

/// Room left in a pillow for body fluid.
/proc/get_pillow_room(atom/pillow)
	if(!is_pillow(pillow))
		return 0
	if(!pillow.reagents)
		return PILLOW_FLUID_CAPACITY
	return pillow.reagents.maximum_volume - pillow.reagents.total_volume

/// Body fluid in a pillow: it dries slowly, smells, and shows on examine.
/datum/component/damp_pillow
	dupe_mode = COMPONENT_DUPE_UNIQUE
	COOLDOWN_DECLARE(scent_cooldown)

/datum/component/damp_pillow/Initialize()
	if(!is_pillow(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/pillow = parent
	if(!pillow.reagents)
		pillow.create_reagents(PILLOW_FLUID_CAPACITY, NO_REACT)
	START_PROCESSING(SSobj, src)

/datum/component/damp_pillow/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/damp_pillow/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/component/damp_pillow/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_COMPONENT_CLEAN_ACT))

/datum/component/damp_pillow/process(seconds_per_tick)
	var/atom/pillow = parent
	if(!pillow.reagents?.total_volume)
		qdel(src)
		return
	pillow.reagents.remove_all(PILLOW_DRY_PER_SECOND * seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, scent_cooldown))
		return
	COOLDOWN_START(src, scent_cooldown, PILLOW_SCENT_INTERVAL)
	var/datum/reagent/main = pillow.reagents.get_master_reagent()
	var/turf/where = get_turf(pillow)
	if(main && where)
		where.pollute_turf(get_fluid_scent(main.type), PILLOW_SCENT_AMOUNT, PILLOW_SCENT_CAP)

/datum/component/damp_pillow/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/atom/pillow = parent
	var/volume = pillow.reagents?.total_volume
	if(!volume)
		return
	var/kind = get_fluid_scent_kind(pillow.reagents.get_master_reagent())
	var/smell = kind ? " [pillow.p_they(TRUE)] smell of [kind]." : ""
	if(volume >= pillow.reagents.maximum_volume * PILLOW_SOAKED_RATIO)
		examine_list += span_notice("[pillow.p_theyre(TRUE)] soaked through.[smell]")
	else
		examine_list += span_notice("There is a damp spot on [pillow.p_them()].[smell]")

/datum/component/damp_pillow/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!(clean_types & CLEAN_TYPE_BLOOD))
		return
	var/atom/pillow = parent
	pillow.reagents?.clear_reagents()
	qdel(src)

#undef PILLOW_FLUID_CAPACITY
#undef PILLOW_SOAKED_RATIO
#undef PILLOW_DRY_PER_SECOND
#undef PILLOW_SCENT_INTERVAL
#undef PILLOW_SCENT_AMOUNT
#undef PILLOW_SCENT_CAP
#undef PILLOW_GATHER_TIME
