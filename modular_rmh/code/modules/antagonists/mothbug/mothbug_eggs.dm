/obj/item/mothbug_egg
	name = "pale egg"
	desc = "A soft, downy egg the size of a plum, wrapped in a wisp of silk."
	icon = 'modular_rmh/icons/obj/mothbug_silk.dmi'
	icon_state = "egg"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	max_integrity = 15
	var/ripe = FALSE
	/// Eggs carried inside a host hatch with extra silk.
	var/well_fed = FALSE
	var/incubation_time = MOTHBUG_EGG_INCUBATION
	var/polling = FALSE
	var/hatch_timer
	var/datum/team/mothbug_colony/colony

/obj/item/mothbug_egg/Initialize(mapload, well_fed_egg = FALSE)
	. = ..()
	if(well_fed_egg)
		well_fed = TRUE
	colony = find_mothbug_colony(TRUE)
	colony.eggs += src
	colony.eggs_laid++
	hatch_timer = addtimer(CALLBACK(src, PROC_REF(ripen)), incubation_time, TIMER_STOPPABLE)

/obj/item/mothbug_egg/well_fed
	desc = "A soft, downy egg the size of a plum, still warm and slick from the body that carried it."
	well_fed = TRUE
	incubation_time = MOTHBUG_WELL_FED_INCUBATION

/obj/item/mothbug_egg/Destroy()
	if(hatch_timer)
		deltimer(hatch_timer)
	colony?.eggs -= src
	colony = null
	return ..()

/obj/item/mothbug_egg/examine(mob/user)
	. = ..()
	if(ripe)
		. += span_warning("It twitches. Something inside is ready to come out.")

/obj/item/mothbug_egg/attack_self(mob/user, list/modifiers)
	user.visible_message(span_warning("[user] starts to squeeze [src]."), span_notice("I start to squash [src]."))
	if(!do_after(user, 1 SECONDS, src))
		return
	user.visible_message(span_warning("[user] squashes [src]!"), span_notice("I squash [src]."))
	playsound(user, 'sound/effects/wounds/splatter.ogg', 40, TRUE)
	qdel(src)

/obj/item/mothbug_egg/proc/ripen()
	hatch_timer = null
	ripe = TRUE
	icon_state = "egg_ripe"
	start_hatch_poll()

/obj/item/mothbug_egg/proc/start_hatch_poll()
	hatch_timer = null
	INVOKE_ASYNC(src, PROC_REF(poll_for_hatchling))

/obj/item/mothbug_egg/proc/poll_for_hatchling()
	if(polling || QDELETED(src))
		return
	polling = TRUE
	var/list/candidates = pollGhostCandidates("A mothbug egg is ready to hatch. Play as a mothling, a fabric-eating grub of the colony?", ROLE_MOTHBUG, null, FALSE, MOTHBUG_EGG_POLL_TIME, POLL_IGNORE_MOTHBUG)
	polling = FALSE
	if(QDELETED(src))
		return
	for(var/mob/candidate as anything in shuffle(candidates))
		if(!candidate.client || is_total_antag_banned(candidate.ckey) || is_antag_banned(candidate.ckey, ROLE_MOTHBUG))
			continue
		if(hatch_for(candidate))
			return
	hatch_timer = addtimer(CALLBACK(src, PROC_REF(start_hatch_poll)), MOTHBUG_EGG_REPOLL, TIMER_STOPPABLE)

/// Hatches a mothling for a lobby player or spectator, giving them a fresh mind.
/obj/item/mothbug_egg/proc/hatch_for(mob/candidate)
	var/turf/hatch_turf = get_turf(src)
	var/player_ckey = candidate.ckey
	if(!hatch_turf || !player_ckey)
		return FALSE
	var/mob/living/simple_animal/mothbug/hatchling/grub = new(hatch_turf)
	if(well_fed)
		grub.silk_charge = MOTHBUG_WELL_FED_CHARGE
	candidate.leave_lobby_for_role()
	grub.PossessByPlayer(player_ckey)
	grub.sync_mind()
	if(!grub.client || !grub.mind)
		qdel(grub)
		return FALSE
	grub.ensure_mothbug_antag()
	grub.update_silk_display()
	grub.visible_message(span_notice("[src] splits open and a fuzzy grub wriggles out."), span_notice("I chew my way out of the egg."))
	playsound(hatch_turf, 'sound/effects/wounds/splatter.ogg', 30, TRUE)
	log_game("[key_name(grub)] hatched as a mothling at [AREACOORD(hatch_turf)].")
	qdel(src)
	return TRUE

/obj/structure/mothbug_pupa
	name = "silk pupa"
	desc = "A tight, papery husk of pale silk hanging from a few threads. Something inside shifts now and then."
	icon = 'modular_rmh/icons/obj/mothbug_silk.dmi'
	icon_state = "pupa"
	anchored = TRUE
	density = FALSE
	max_integrity = 40
	resistance_flags = FLAMMABLE
	var/emerge_timer
	/// Set when the grub leaves on purpose, so destroying the husk does not kill it.
	var/released = FALSE

/obj/structure/mothbug_pupa/Initialize(mapload)
	. = ..()
	emerge_timer = addtimer(CALLBACK(src, PROC_REF(emerge)), MOTHBUG_PUPA_TIME, TIMER_STOPPABLE)

/obj/structure/mothbug_pupa/Destroy()
	if(emerge_timer)
		deltimer(emerge_timer)
	var/turf/drop_turf = get_turf(src)
	for(var/mob/living/simple_animal/mothbug/hatchling/grub in contents)
		grub.forceMove(drop_turf)
		if(!released)
			grub.visible_message(span_danger("[grub] spills out of the torn husk, unfinished and dying."))
			grub.death()
	for(var/atom/movable/inside as anything in contents)
		inside.forceMove(drop_turf)
	return ..()

/obj/structure/mothbug_pupa/container_resist(mob/living/user)
	to_chat(user, span_notice("I start tearing my way out of the husk early."))
	if(!do_after(user, 5 SECONDS, src, IGNORE_USER_LOC_CHANGE) || QDELETED(src) || user.loc != src)
		return
	released = TRUE
	visible_message(span_notice("[user] tears out of [src] before it is finished."))
	qdel(src)

/obj/structure/mothbug_pupa/proc/emerge()
	emerge_timer = null
	var/mob/living/simple_animal/mothbug/hatchling/grub = locate() in src
	if(!grub || grub.stat == DEAD)
		qdel(src)
		return
	var/turf/emerge_turf = get_turf(src)
	var/mob/living/simple_animal/mothbug/adult = new(emerge_turf)
	adult.silk_charge = MOTHBUG_PUPATE_CHARGE
	adult.fabric_eaten = grub.fabric_eaten
	var/datum/mind/grub_mind = grub.mind
	if(grub_mind)
		grub_mind.transfer_to(adult)
		grub_mind.remove_antag_datum(/datum/antagonist/mothbug/hatchling)
		adult.ensure_mothbug_antag()
	adult.update_silk_display()
	adult.visible_message(span_notice("[src] splits down the middle and a damp mothbug crawls out, unfolding its wings."), span_notice("I split my husk and unfold new wings!"))
	released = TRUE
	qdel(grub)
	qdel(src)

/datum/action/cooldown/mothbug/lay_egg
	name = "Lay Egg"
	desc = "Lay a soft egg on my tile. After a few minutes a new mothling hatches from it, if a spirit answers."
	button_icon_state = "bread"
	silk_cost = MOTHBUG_COST_EGG
	cooldown_time = 10 SECONDS

/datum/action/cooldown/mothbug/lay_egg/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/moth = owner
	var/turf/place = get_turf(moth)
	if(!isopenturf(place) || !isturf(moth.loc))
		moth.balloon_alert(moth, "can't lay here!")
		return FALSE
	var/datum/team/mothbug_colony/colony = moth.get_mothbug_colony() || find_mothbug_colony(TRUE)
	if(!colony.has_room())
		to_chat(moth, span_warning("The colony is as large as this town can feed. ([colony.get_colony_size()]/[colony.get_colony_cap()])"))
		return FALSE
	moth.visible_message(span_notice("[moth] curls its abdomen and strains."), span_notice("I begin to lay an egg."), vision_distance = 3)
	if(!do_after(moth, MOTHBUG_EGG_LAY_TIME, place))
		return FALSE
	if(!colony.has_room() || !moth.spend_silk_charge(silk_cost))
		return FALSE
	new /obj/item/mothbug_egg(place)
	to_chat(moth, span_notice("I lay a soft egg. It will hatch in a few minutes if a spirit answers. ([colony.get_colony_size()]/[colony.get_colony_cap()])"))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mothbug/pupate
	name = "Pupate"
	desc = "Spin a husk and change into an adult. Needs enough fabric eaten and some time alive. The husk is fragile; if it is destroyed, I die."
	button_icon_state = "regression"
	cooldown_time = 5 SECONDS

/datum/action/cooldown/mothbug/pupate/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/hatchling/grub = owner
	if(!istype(grub))
		return FALSE
	if(grub.fabric_eaten < MOTHBUG_PUPATE_FABRIC)
		to_chat(grub, span_warning("I am not fat enough to change yet. ([round(grub.fabric_eaten)]/[MOTHBUG_PUPATE_FABRIC] eaten)"))
		return FALSE
	var/age = world.time - grub.hatched_at
	if(age < MOTHBUG_PUPATE_MIN_AGE)
		to_chat(grub, span_warning("I am too young to change. ([DisplayTimeText(MOTHBUG_PUPATE_MIN_AGE - age)] left)"))
		return FALSE
	var/turf/place = get_turf(grub)
	if(!isopenturf(place) || !isturf(grub.loc))
		grub.balloon_alert(grub, "can't spin here!")
		return FALSE
	grub.visible_message(span_notice("[grub] starts spinning silk around itself."), span_notice("I start spinning my husk."))
	if(!do_after(grub, MOTHBUG_PUPATE_SPIN_TIME, place))
		return FALSE
	grub.set_mothbug_hidden(FALSE)
	var/obj/structure/mothbug_pupa/pupa = new(place)
	grub.forceMove(pupa)
	to_chat(grub, span_notice("I seal myself in. In [DisplayTimeText(MOTHBUG_PUPA_TIME)] I will emerge with wings."))
	StartCooldown()
	return TRUE
