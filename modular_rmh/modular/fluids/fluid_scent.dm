// Scent trails: leaks, climaxes on the floor and heat musk leave marks that a keen nose can follow.

/// How long a mark stays fresh enough to follow.
#define FLUID_SCENT_LIFETIME (10 MINUTES)
/// Most marks kept at once; the oldest go first.
#define FLUID_SCENT_CAP 400
/// A source leaves at most one mark per tile in this time.
#define FLUID_SCENT_SPACING (30 SECONDS)
/// How far a sniff picks up marks, and how long it shows them.
#define FLUID_SCENT_RANGE 12
#define FLUID_SCENT_SHOW_TIME (20 SECONDS)

GLOBAL_LIST_EMPTY(fluid_scent_marks)

/datum/fluid_scent_mark
	var/turf/turf
	var/datum/weakref/source_ref
	/// "seed", "nectar", "milk", "musk" or a fluid name.
	var/kind
	var/time

/// Short scent name for a fluid.
/proc/get_fluid_scent_kind(datum/reagent/fluid)
	if(istype(fluid, /datum/reagent/consumable/cum))
		return "seed"
	if(istype(fluid, /datum/reagent/consumable/femcum))
		return "nectar"
	if(istype(fluid, /datum/reagent/consumable/milk))
		return "milk"
	return fluid ? LOWER_TEXT(fluid.name) : null

/proc/get_fluid_scent_color(kind)
	var/static/list/colors = list("seed" = "#eceaf4", "nectar" = "#f2a6c8", "milk" = "#f5ecd0", "musk" = "#d9a05b")
	return colors[kind] || "#cfcfcf"

/// Marks a tile with a source's scent, unless it marked the same tile a moment ago.
/proc/leave_fluid_scent(turf/where, mob/living/source, kind)
	if(!isturf(where) || !isliving(source) || !kind)
		return
	prune_fluid_scent_marks()
	for(var/i in length(GLOB.fluid_scent_marks) to 1 step -1)
		var/datum/fluid_scent_mark/recent = GLOB.fluid_scent_marks[i]
		if(world.time - recent.time > FLUID_SCENT_SPACING)
			break
		if(recent.turf == where && recent.kind == kind && recent.source_ref?.resolve() == source)
			return
	var/datum/fluid_scent_mark/mark = new
	mark.turf = where
	mark.source_ref = WEAKREF(source)
	mark.kind = kind
	mark.time = world.time
	GLOB.fluid_scent_marks += mark
	if(length(GLOB.fluid_scent_marks) > FLUID_SCENT_CAP)
		GLOB.fluid_scent_marks.Cut(1, 2)

/// Drops marks too old to follow; the list is capped, so a full scan stays cheap.
/proc/prune_fluid_scent_marks()
	var/cutoff = world.time - FLUID_SCENT_LIFETIME
	for(var/i in length(GLOB.fluid_scent_marks) to 1 step -1)
		var/datum/fluid_scent_mark/mark = GLOB.fluid_scent_marks[i]
		if(mark.time < cutoff)
			GLOB.fluid_scent_marks.Cut(i, i + 1)

/// Extra detail a keen nose picks up on someone: heat, fresh seed, arousal.
/proc/get_fluid_scent_note(mob/living/target)
	var/list/notes = list()
	if(target.has_fluid_modifier(/datum/fluid_modifier/in_heat))
		notes += "in heat"
	if(target.carries_fresh_seed())
		notes += "smelling of fresh seed"
	var/list/arousal_data = list()
	SEND_SIGNAL(target, COMSIG_SEX_GET_AROUSAL, arousal_data)
	if(arousal_data["arousal"] >= AROUSAL_EDGING_THRESHOLD)
		notes += "thick with arousal"
	var/marker_name = target.get_scent_mark_name()
	if(marker_name)
		notes += "marked with [marker_name]'s scent"
	if(!length(notes))
		return ""
	return ", [english_list(notes)],"

/// Seed inside them, or wet on their skin.
/mob/living/proc/carries_fresh_seed()
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		var/obj/item/organ/genitals/filling_organ/opening = getorganslot(slot)
		if(opening?.reagents?.has_reagent(/datum/reagent/consumable/cum))
			return TRUE
	var/datum/component/fluid_coated/coated = GetComponent(/datum/component/fluid_coated)
	for(var/zone in coated?.coats)
		var/datum/fluid_coat/coat = coated.coats[zone]
		if(coat.is_wet() && coat.get_kind() == "semen")
			return TRUE
	return FALSE

/// Shows the sniffer fresh marks nearby for a little while, and where the freshest trail leads.
/mob/living/proc/reveal_fluid_scent_trails()
	var/turf/here = get_turf(src)
	if(!client || !here)
		return
	prune_fluid_scent_marks()
	var/list/images = list()
	var/datum/fluid_scent_mark/freshest
	for(var/datum/fluid_scent_mark/mark as anything in GLOB.fluid_scent_marks)
		if(mark.turf.z != here.z || get_dist(mark.turf, here) > FLUID_SCENT_RANGE)
			continue
		if(mark.source_ref?.resolve() == src)
			continue
		var/image/wisp = image('modular_rmh/icons/effect/fluid_scent.dmi', mark.turf, "scent", ABOVE_ALL_MOB_LAYER)
		wisp.plane = GAME_PLANE_UPPER
		wisp.appearance_flags = RESET_COLOR | RESET_ALPHA | KEEP_APART
		wisp.color = get_fluid_scent_color(mark.kind)
		// Fresher marks show stronger.
		wisp.alpha = clamp(255 * (1 - (world.time - mark.time) / FLUID_SCENT_LIFETIME), 60, 255)
		images += wisp
		if(!freshest || mark.time > freshest.time)
			freshest = mark
	if(!length(images))
		return
	client.images += images
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(hide_fluid_scent_trails), WEAKREF(src), images), FLUID_SCENT_SHOW_TIME)
	var/where = freshest.turf == here ? "right here" : "to the [dir2text(get_dir(here, freshest.turf))]"
	to_chat(src, span_notice("A fresh trail of [freshest.kind] is strongest [where]."))

/proc/hide_fluid_scent_trails(datum/weakref/sniffer_ref, list/images)
	var/mob/sniffer = sniffer_ref?.resolve()
	sniffer?.client?.images -= images

#undef FLUID_SCENT_LIFETIME
#undef FLUID_SCENT_CAP
#undef FLUID_SCENT_SPACING
#undef FLUID_SCENT_RANGE
#undef FLUID_SCENT_SHOW_TIME
