#define HUNT_GHOST_GIVE_UP_RANGE 14
#define HUNT_GHOST_CHASE_LIMIT (45 SECONDS)
#define HUNT_GHOST_IGNORE_TIME (20 SECONDS)
#define HUNT_GHOST_VANISH_TIME (15 SECONDS)
#define HUNT_GHOST_ROAM_TIMEOUT (20 SECONDS)
#define HUNT_GHOST_LONELY_TIME (30 SECONDS)
#define HUNT_GHOST_SNACK_TIME (8 SECONDS)

/// A candy-hungry ghost; phases through walls with forceMove steps, so doors and traps never see it.
/obj/effect/hunt_ghost
	name = "spooky ghost"
	desc = "A wailing wisp of mist with a sweet tooth. It hungers for candy."
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost1"
	alpha = 200
	layer = ABOVE_MOB_LAYER
	movement_type = FLYING
	light_system = MOVABLE_LIGHT
	light_outer_range = 2
	light_power = 0.6
	light_color = "#b8d4ff"
	/// Deciseconds per tile; players walk at 3 and run at 2.
	var/move_delay = 2.6
	var/aggro_range = 8
	/// Share of a basket that bursts out on a catch.
	var/scatter_ratio = 0.3
	var/datum/weakref/target_ref
	var/chase_started = 0
	/// REF(mob) -> world.time until which that mob is left alone.
	var/list/ignored = list()
	var/datum/weakref/snack_ref
	var/snack_until = 0
	var/idle_until = 0
	var/turf/roam_goal
	var/roam_until = 0
	var/lonely_since = 0
	var/vanished = FALSE
	/// What the move loop currently drifts toward.
	var/atom/current_goal

/obj/effect/hunt_ghost/Initialize(mapload, rare = FALSE)
	. = ..()
	if(rare)
		name = "hooded haunt"
		desc = "A tall, cloaked spirit. It is quicker and greedier than its little cousins."
		icon_state = "ghostwithcape"
		alpha = 225
		move_delay = 2.3
		aggro_range = 10
		scatter_ratio = 0.4
		// The black cloak vanishes in the dark without a violet glow and rim.
		set_light_range_power_color(3, 1, "#a77bff")
		add_filter("haunt_outline", 1, outline_filter(1, "#9b7be0"))
	else
		icon_state = pick("ghost1", "ghost2")
	animate(src, pixel_y = 3, time = 1.5 SECONDS, loop = -1, easing = SINE_EASING)
	animate(pixel_y = -1, time = 1.5 SECONDS, easing = SINE_EASING)
	START_PROCESSING(SSprocessing, src)

/obj/effect/hunt_ghost/Destroy()
	GLOB.halloween_hunt?.ghosts -= src
	STOP_PROCESSING(SSprocessing, src)
	SSmove_manager.stop_looping(src)
	target_ref = null
	snack_ref = null
	roam_goal = null
	current_goal = null
	ignored = null
	return ..()

/obj/effect/hunt_ghost/examine(mob/user)
	. = ..()
	. += span_info("Ghosts cannot cross consecrated ground, and they cannot resist thrown candy.")

/obj/effect/hunt_ghost/attack_hand(mob/user, list/modifiers)
	to_chat(user, span_warning("My hand passes right through [src]. So cold!"))
	return TRUE

/obj/effect/hunt_ghost/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	user.visible_message(span_warning("[attacking_item] passes right through [src]!"), span_warning("[attacking_item] passes right through [src]!"))
	return TRUE

/obj/effect/hunt_ghost/can_zFall(turf/source, levels = 1, turf/target, direction)
	return FALSE

/obj/effect/hunt_ghost/process(seconds_per_tick)
	var/datum/halloween_hunt/hunt = GLOB.halloween_hunt
	if(!hunt)
		qdel(src)
		return PROCESS_KILL
	if(vanished || world.time < idle_until)
		return
	if(handle_snack())
		return
	var/mob/living/carbon/human/victim = target_ref?.resolve()
	if(victim && !keep_chasing(victim))
		drop_target(victim, TRUE)
		victim = null
	if(!victim)
		victim = find_target()
		if(victim)
			start_chase(victim)
	if(victim)
		if(get_dist(src, victim) <= 1)
			catch_victim(victim)
		else if(prob(4))
			spooky_noise()
		return
	roam(hunt)

/// Called by the move loop after each step, so fast targets are caught on contact.
/obj/effect/hunt_ghost/proc/after_step()
	if(vanished)
		return
	var/mob/living/carbon/human/victim = target_ref?.resolve()
	if(victim && get_dist(src, victim) <= 1 && can_hunt(victim))
		catch_victim(victim)

/obj/effect/hunt_ghost/proc/move_toward(atom/goal)
	if(goal == current_goal)
		return
	SSmove_manager.stop_looping(src)
	current_goal = goal
	if(goal)
		SSmove_manager.add_to_loop(src, SSmovement, /datum/move_loop/has_target/hunt_ghost_drift, MOVEMENT_DEFAULT_PRIORITY, NONE, null, move_delay, INFINITY, goal)

/obj/effect/hunt_ghost/proc/can_hunt(mob/living/carbon/human/victim)
	if(!ishuman(victim) || QDELETED(victim) || victim.stat != CONSCIOUS || !victim.client || victim.z != z)
		return FALSE
	if(victim.has_status_effect(/datum/status_effect/hunt_spooked))
		return FALSE
	if(ignored[REF(victim)] > world.time)
		return FALSE
	var/area/victim_area = get_area(victim)
	if(victim_area?.holy_area)
		return FALSE
	var/obj/item/hunt_basket/basket = find_carried_hunt_basket(victim)
	return basket?.candy > 0

/obj/effect/hunt_ghost/proc/keep_chasing(mob/living/carbon/human/victim)
	if(!can_hunt(victim))
		return FALSE
	if(get_dist(src, victim) > HUNT_GHOST_GIVE_UP_RANGE)
		return FALSE
	return world.time - chase_started < HUNT_GHOST_CHASE_LIMIT

/// Picks the richest nearby candy carrier.
/obj/effect/hunt_ghost/proc/find_target()
	var/mob/living/carbon/human/best
	var/best_score = 0
	for(var/obj/item/hunt_basket/basket as anything in GLOB.halloween_hunt_baskets)
		if(basket.candy <= 0)
			continue
		var/mob/living/carbon/human/holder = get(basket, /mob/living/carbon/human)
		if(!holder || holder.z != z)
			continue
		var/distance = get_dist(src, holder)
		if(distance > aggro_range || !can_hunt(holder))
			continue
		var/score = (basket.candy + 5) / (distance + 2)
		if(score > best_score)
			best_score = score
			best = holder
	return best

/obj/effect/hunt_ghost/proc/start_chase(mob/living/carbon/human/victim)
	target_ref = WEAKREF(victim)
	chase_started = world.time
	roam_goal = null
	move_toward(victim)
	to_chat(victim, span_userdanger("An icy giggle echoes nearby... something wants my candy!"))
	playsound(src, pick('sound/vo/mobs/ghost/laugh (1).ogg', 'sound/vo/mobs/ghost/laugh (2).ogg', 'sound/vo/mobs/ghost/laugh (3).ogg'), 50, TRUE)

/obj/effect/hunt_ghost/proc/drop_target(mob/living/victim, ignore = FALSE)
	target_ref = null
	if(ignore && victim)
		ignored[REF(victim)] = world.time + HUNT_GHOST_IGNORE_TIME
	move_toward(null)

/obj/effect/hunt_ghost/proc/catch_victim(mob/living/carbon/human/victim)
	var/obj/item/hunt_basket/basket = find_carried_hunt_basket(victim)
	if(!basket || basket.candy <= 0)
		drop_target(victim)
		return
	var/lost = basket.scatter(clamp(round(basket.candy * scatter_ratio), 3, 20))
	victim.Immobilize(2 SECONDS)
	victim.apply_status_effect(/datum/status_effect/hunt_spooked)
	victim.visible_message(span_warning("[src] swoops right through [victim]! Candy bursts out of [victim.p_their()] basket!"), span_userdanger("[src] swoops right through me! My candy bursts out of the basket!"))
	playsound(victim, pick('sound/vo/mobs/ghost/laugh (4).ogg', 'sound/vo/mobs/ghost/laugh (5).ogg', 'sound/vo/mobs/ghost/laugh (6).ogg'), 60, TRUE)
	if(victim.has_erp_pref(/datum/erp_preference/boolean/lust_magic_targetable))
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(hunt_ghost_climax), victim)
	GLOB.halloween_hunt?.on_ghost_catch(src, victim, lost)
	drop_target(victim)
	vanish()

/// The icy touch climaxes the victim; respects the Lust Magic Targetable preference at the caller.
/proc/hunt_ghost_climax(mob/living/carbon/human/victim)
	if(QDELETED(victim))
		return
	to_chat(victim, span_love("An icy, ticklish rush floods my whole body..."))
	SEND_SIGNAL(victim, COMSIG_SEX_ORGASM)

/obj/effect/hunt_ghost/proc/vanish()
	vanished = TRUE
	move_toward(null)
	set_light_on(FALSE)
	animate(src, alpha = 0, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(reappear)), HUNT_GHOST_VANISH_TIME, TIMER_DELETE_ME)

/obj/effect/hunt_ghost/proc/reappear(turf/destination)
	var/datum/halloween_hunt/hunt = GLOB.halloween_hunt
	if(QDELETED(src) || !hunt)
		return
	destination = destination || hunt.pick_ghost_turf(src)
	if(destination)
		forceMove(destination)
	roam_goal = null
	lonely_since = 0
	vanished = FALSE
	set_light_on(TRUE)
	animate(src, alpha = initial(alpha), time = 1 SECONDS, flags = ANIMATION_PARALLEL)

/// Fades out and comes back on another floor that has candy carriers.
/obj/effect/hunt_ghost/proc/drift_to(turf/destination)
	vanished = TRUE
	move_toward(null)
	set_light_on(FALSE)
	animate(src, alpha = 0, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(reappear), destination), 3 SECONDS, TIMER_DELETE_ME)

/obj/effect/hunt_ghost/proc/roam(datum/halloween_hunt/hunt)
	if(roam_goal && (get_turf(src) == roam_goal || world.time > roam_until))
		roam_goal = null
	if(roam_goal)
		return
	if(!hunt.has_carriers_on_z(z))
		if(!lonely_since)
			lonely_since = world.time
		else if(world.time - lonely_since > HUNT_GHOST_LONELY_TIME)
			var/turf/elsewhere = hunt.pick_busy_turf()
			if(elsewhere)
				drift_to(elsewhere)
				return
	else
		lonely_since = 0
	roam_goal = hunt.pick_roam_goal(src)
	roam_until = world.time + HUNT_GHOST_ROAM_TIMEOUT
	move_toward(roam_goal)

/obj/effect/hunt_ghost/proc/distract(obj/item/treat, mob/thrower)
	snack_ref = WEAKREF(treat)
	snack_until = world.time + HUNT_GHOST_SNACK_TIME
	if(thrower)
		ignored[REF(thrower)] = world.time + 10 SECONDS
	var/mob/living/victim = target_ref?.resolve()
	if(victim)
		drop_target(victim)
	move_toward(treat)
	visible_message(span_notice("[src] whirls around, distracted by the candy!"))

/// Returns TRUE while the ghost is busy with a thrown candy.
/obj/effect/hunt_ghost/proc/handle_snack()
	if(!snack_ref)
		return FALSE
	var/obj/item/treat = snack_ref.resolve()
	if(QDELETED(treat) || world.time > snack_until || !isturf(treat.loc) || treat.z != z)
		snack_ref = null
		move_toward(null)
		return FALSE
	if(get_turf(src) != treat.loc)
		move_toward(treat)
		return TRUE
	visible_message(span_notice("[src] gobbles up [treat] with a happy wail!"))
	playsound(src, 'sound/vo/mobs/ghost/moan (1).ogg', 40, TRUE)
	qdel(treat)
	snack_ref = null
	move_toward(null)
	idle_until = world.time + 3 SECONDS
	return TRUE

/obj/effect/hunt_ghost/proc/spooky_noise()
	playsound(src, pick('sound/vo/mobs/ghost/whisper (1).ogg', 'sound/vo/mobs/ghost/whisper (2).ogg', 'sound/vo/mobs/ghost/moan (2).ogg'), 45, TRUE)
	visible_message(span_warning(pick("[src] wails, \"Boooo!\"", "[src] giggles hungrily.", "[src] moans, \"Caaandy...\"")))

/// Finds the hunt basket a person carries anywhere on them, fullest first.
/proc/find_carried_hunt_basket(mob/living/carbon/human/person)
	var/obj/item/hunt_basket/best
	for(var/obj/item/hunt_basket/basket as anything in GLOB.halloween_hunt_baskets)
		if(get(basket, /mob/living/carbon/human) != person)
			continue
		if(!best || basket.candy > best.candy)
			best = basket
	return best

/datum/move_loop/has_target/hunt_ghost_drift

/datum/move_loop/has_target/hunt_ghost_drift/move()
	var/turf/here = get_turf(moving)
	var/turf/goal = get_turf(target)
	if(!here || !goal || here == goal || here.z != goal.z)
		return FALSE
	var/direction = get_dir(here, goal)
	var/turf/next
	// Consecrated ground is a wall to ghosts; slide around it diagonally.
	for(var/try_dir in list(direction, turn(direction, 45), turn(direction, -45)))
		var/turf/candidate = get_step(here, try_dir)
		var/area/candidate_area = get_area(candidate)
		if(candidate && !candidate_area?.holy_area)
			next = candidate
			break
	if(!next)
		return FALSE
	moving.forceMove(next)
	var/obj/effect/hunt_ghost/ghost = moving
	ghost.after_step()
	return TRUE

/datum/status_effect/hunt_spooked
	id = "hunt_spooked"
	duration = 20 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/hunt_spooked

/atom/movable/screen/alert/status_effect/hunt_spooked
	name = "Spooked"
	desc = "A ghost just swooped through me. The ghosts will leave me be for a little while."
	icon_state = "debuff"

#undef HUNT_GHOST_GIVE_UP_RANGE
#undef HUNT_GHOST_CHASE_LIMIT
#undef HUNT_GHOST_IGNORE_TIME
#undef HUNT_GHOST_VANISH_TIME
#undef HUNT_GHOST_ROAM_TIMEOUT
#undef HUNT_GHOST_LONELY_TIME
#undef HUNT_GHOST_SNACK_TIME
