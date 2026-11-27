/obj/structure/bed/silk
	name = "silk bedding"
	desc = "Soft silk spread across the floor."
	icon = 'modular_rmh/icons/obj/silk_bed.dmi'
	icon_state = "basic"
	layer = BELOW_OBJ_LAYER
	sleepy = 0.75
	max_integrity = 60
	integrity_failure = 0
	debris = list(/obj/item/natural/silk = 1)
	metalizer_result = null
	hidingspot = FALSE
	attacked_sound = 'sound/foley/cloth_rip.ogg'
	break_sound = 'sound/foley/cloth_rip.ogg'
	/// A second weave adds the overhead veil and proper-bed comfort.
	var/upgraded = FALSE
	var/mutable_appearance/veil

/obj/structure/bed/silk/proc/upgrade()
	if(upgraded)
		return FALSE
	upgraded = TRUE
	name = "veiled silk bed"
	sleepy = 2
	icon_state = "complete"
	// Like chair armrests: leaves the structure plane so it covers the sleeper.
	veil = mutable_appearance(icon, "complete_front", ABOVE_ALL_MOB_LAYER, GAME_PLANE_UPPER)
	veil.appearance_flags |= KEEP_APART
	add_overlay(veil)
	return TRUE

/obj/structure/bed/silk/examine(mob/user)
	. = ..()
	// The parent appends bedsheet remarks to desc; silk takes no sheet.
	desc = initial(desc)
	if(upgraded)
		. += span_notice("A sheltering silk veil hangs over the bedding. It is as comfortable as a proper bed.")
	else
		. += span_notice("It is about as comfortable as a bedroll. Weaving a silk bed here again would add a veil and make it a proper bed.")

/obj/structure/bed/silk/wrench_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("There are no bolts in silk. Scissors would harvest it."))
	return ITEM_INTERACT_BLOCKING

/obj/structure/bed/silk/attacked_by(obj/item/I, mob/living/user)
	if(user.used_intent?.type != /datum/intent/snip)
		return ..()
	var/snip_time = max(1 SECONDS, 5 SECONDS - GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/sewing) * 1 SECONDS)
	if(!do_after(user, snip_time, src))
		return TRUE
	if(QDELETED(src) || QDELETED(I) || !user.Adjacent(src) || user.get_active_held_item() != I)
		return TRUE
	var/turf/drop_turf = get_turf(src)
	user.visible_message(span_notice("[user] snips [src] up into silk."))
	user.mind?.add_sleep_experience(/datum/attribute/skill/misc/sewing, GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) / 2)
	playsound(src, 'sound/items/flint.ogg', 100, TRUE)
	qdel(src)
	for(var/i in 1 to rand(1, 2))
		new /obj/item/natural/silk(drop_turf)
	return TRUE

/obj/structure/bed/silk/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!. || (mover in buckled_mobs))
		return
	if(isliving(mover))
		if(!HAS_TRAIT(mover, TRAIT_WEBWALK) && prob(50))
			to_chat(mover, span_warning("I get stuck in the silk for a moment."))
			return FALSE
	else if(istype(mover, /obj/projectile))
		return prob(30)

/obj/structure/bed/silk/fire_act(added, maxstacks)
	var/turf/fire_turf = get_turf(src)
	visible_message(span_warning("[src] catches fire!"))
	qdel(src)
	if(fire_turf)
		new /obj/effect/hotspot(fire_turf)
