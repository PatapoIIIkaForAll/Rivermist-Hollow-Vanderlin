/datum/action/cooldown/mothbug
	name = "Mothbug Ability"
	check_flags = AB_CHECK_CONSCIOUS
	/// Silk spent on each use.
	var/silk_cost = 0

/datum/action/cooldown/mothbug/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/mothbug/moth = owner
	if(!istype(moth))
		return FALSE
	var/cost = get_silk_cost()
	if(cost && !moth.has_silk_charge(cost))
		if(feedback)
			moth.balloon_alert(moth, "need [cost] silk")
		return FALSE
	return TRUE

/datum/action/cooldown/mothbug/proc/get_silk_cost()
	return silk_cost

/datum/action/cooldown/mothbug/hide
	name = "Hide"
	desc = "Press into the shadows, or under a table or bed. Leaving cover or being hurt reveals me."
	button_icon_state = "invisibility"
	cooldown_time = 2 SECONDS

/datum/action/cooldown/mothbug/hide/is_action_active(atom/movable/screen/movable/action_button/current_button)
	var/mob/living/simple_animal/mothbug/moth = owner
	return istype(moth) && moth.hidden

/datum/action/cooldown/mothbug/hide/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/moth = owner
	if(moth.hidden)
		moth.set_mothbug_hidden(FALSE)
		StartCooldown()
		return TRUE
	if(!moth.can_hide_here() || moth.is_exposed_by_light())
		moth.balloon_alert(moth, "too exposed!")
		return FALSE
	moth.set_mothbug_hidden(TRUE)
	StartCooldown()
	return TRUE

/mob/living/simple_animal/mothbug/proc/can_hide_here(turf/place = loc)
	if(!isturf(place) || flying)
		return FALSE
	if(locate(/obj/structure/table) in place)
		return TRUE
	if(locate(/obj/structure/bed) in place)
		return TRUE
	return place.get_lumcount() < MOTHBUG_HIDE_MAX_LIGHT

/mob/living/simple_animal/mothbug/proc/set_mothbug_hidden(new_hidden)
	if(hidden == new_hidden)
		return
	hidden = new_hidden
	if(hidden)
		alpha = MOTHBUG_HIDDEN_ALPHA
		layer = TABLE_LAYER - 0.1
		plane = GAME_PLANE_LOWER
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_hidden_moved))
		RegisterSignal(src, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_hidden_damaged))
		hide_light_timer = addtimer(CALLBACK(src, PROC_REF(check_hide_light)), 2 SECONDS, TIMER_STOPPABLE|TIMER_LOOP)
		to_chat(src, span_notice("I press myself into cover."))
	else
		alpha = initial(alpha)
		layer = initial(layer)
		plane = initial(plane)
		UnregisterSignal(src, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_APPLY_DAMAGE))
		if(hide_light_timer)
			deltimer(hide_light_timer)
			hide_light_timer = null
		to_chat(src, span_notice("I leave my cover."))
	for(var/datum/action/cooldown/mothbug/hide/hide_action in innate_actions)
		hide_action.build_all_button_icons(UPDATE_BUTTON_BACKGROUND)

/mob/living/simple_animal/mothbug/proc/on_hidden_moved(datum/source)
	SIGNAL_HANDLER
	if(!can_hide_here())
		set_mothbug_hidden(FALSE)

/mob/living/simple_animal/mothbug/proc/on_hidden_damaged(datum/source, damage, damagetype)
	SIGNAL_HANDLER
	if(damage > 0)
		set_mothbug_hidden(FALSE)

/datum/action/cooldown/mothbug/spin_web
	name = "Spin Web"
	desc = "Spin a tangle of moth silk on my tile. Others get stuck in it; mothbugs slip through."
	button_icon_state = "entangle"
	silk_cost = MOTHBUG_COST_WEB
	cooldown_time = 2 SECONDS

/datum/action/cooldown/mothbug/spin_web/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/moth = owner
	var/turf/place = get_turf(moth)
	if(!isopenturf(place) || (locate(/obj/structure/spider/stickyweb) in place))
		moth.balloon_alert(moth, "can't spin here!")
		return FALSE
	if(!do_after(moth, MOTHBUG_WEB_TIME, place) || !moth.spend_silk_charge(silk_cost))
		return FALSE
	new /obj/structure/spider/stickyweb/mothbug(place)
	moth.visible_message(span_notice("[moth] spins a dusty tangle of silk."), span_notice("I spin a tangle of silk."), vision_distance = 3)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mothbug/silk_snare
	name = "Silk Snare"
	desc = "Stretch a nearly invisible silk loop across my tile. The first person to walk through gets their legs bound."
	button_icon_state = "ensnare"
	silk_cost = MOTHBUG_COST_SNARE
	cooldown_time = 5 SECONDS

/datum/action/cooldown/mothbug/silk_snare/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/moth = owner
	var/turf/place = get_turf(moth)
	if(!isopenturf(place) || (locate(/obj/structure/mothbug_snare) in place))
		moth.balloon_alert(moth, "can't set it here!")
		return FALSE
	if(length(moth.snares) >= MOTHBUG_MAX_SNARES)
		moth.balloon_alert(moth, "too many snares!")
		return FALSE
	if(!do_after(moth, MOTHBUG_SNARE_TIME, place) || !moth.spend_silk_charge(silk_cost))
		return FALSE
	new /obj/structure/mothbug_snare(place, moth)
	to_chat(moth, span_notice("I stretch a fine silk loop across the floor. ([length(moth.snares)]/[MOTHBUG_MAX_SNARES] snares)"))
	StartCooldown()
	return TRUE

/// Targeted moth abilities; middle-click the target once the button is armed.
/datum/action/cooldown/mothbug/targeted
	click_to_activate = TRUE
	cooldown_time = 2 SECONDS

/datum/action/cooldown/mothbug/targeted/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/moth = owner
	var/mob/living/carbon/victim = target
	if(!iscarbon(victim))
		victim = locate(/mob/living/carbon) in get_turf(target)
	if(!victim || !moth.Adjacent(victim))
		moth.balloon_alert(moth, "nobody next to me!")
		return FALSE
	if(!can_target(moth, victim, TRUE))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(perform), moth, victim)
	return TRUE

/datum/action/cooldown/mothbug/targeted/proc/can_target(mob/living/simple_animal/mothbug/moth, mob/living/carbon/victim, feedback)
	return TRUE

/datum/action/cooldown/mothbug/targeted/proc/can_continue(mob/living/simple_animal/mothbug/moth, mob/living/carbon/victim)
	return !QDELETED(victim) && moth.Adjacent(victim) && can_target(moth, victim, FALSE)

/datum/action/cooldown/mothbug/targeted/proc/perform(mob/living/simple_animal/mothbug/moth, mob/living/carbon/victim)
	return

/datum/action/cooldown/mothbug/targeted/silk_bind
	name = "Silk Bind"
	desc = "Middle-click a helpless person beside me to bind their wrists with silk, or their legs once their wrists are bound."
	button_icon_state = "unholy_grab"
	silk_cost = MOTHBUG_COST_BIND

/datum/action/cooldown/mothbug/targeted/silk_bind/can_target(mob/living/simple_animal/mothbug/moth, mob/living/carbon/victim, feedback)
	if(!is_mothbug_helpless(victim))
		if(feedback)
			moth.balloon_alert(moth, "they can fight me off!")
		return FALSE
	if(victim.handcuffed && victim.legcuffed)
		if(feedback)
			moth.balloon_alert(moth, "already bound!")
		return FALSE
	return TRUE

/datum/action/cooldown/mothbug/targeted/silk_bind/perform(mob/living/simple_animal/mothbug/moth, mob/living/carbon/victim)
	var/legs = !!victim.handcuffed
	var/part = legs ? "legs" : "wrists"
	moth.visible_message(span_warning("[moth] starts winding silk around [victim]'s [part]!"), span_notice("I wind silk around [victim]'s [part]."))
	if(!do_after(moth, MOTHBUG_BIND_TIME, victim, extra_checks = CALLBACK(src, PROC_REF(can_continue), moth, victim)))
		return
	if(!moth.spend_silk_charge(silk_cost))
		return
	var/obj/item/rope/spider_silk/moth/cuffs = new(get_turf(victim))
	cuffs.apply_cuffs(victim, null, leg = legs)
	if((legs ? victim.legcuffed : victim.handcuffed) != cuffs)
		qdel(cuffs)
		return
	victim.visible_message(span_warning("[moth] binds [victim]'s [part] in pale silk!"), span_userdanger("Silk binds my [part] tight!"))
	log_combat(moth, victim, legs ? "legcuffed" : "handcuffed", cuffs)
	StartCooldown()

/datum/action/cooldown/mothbug/targeted/cocoon
	name = "Cocoon"
	desc = "Middle-click a person beside me whose wrists are bound, or who is unconscious, to wrap them in a cocoon. It slowly eats their clothes and feeds me."
	button_icon_state = "great_shelter"
	silk_cost = MOTHBUG_COST_COCOON
	cooldown_time = 5 SECONDS

/datum/action/cooldown/mothbug/targeted/cocoon/can_target(mob/living/simple_animal/mothbug/moth, mob/living/carbon/victim, feedback)
	if(!victim.handcuffed && victim.stat == CONSCIOUS && !victim.IsSleeping())
		if(feedback)
			moth.balloon_alert(moth, "bind their wrists first!")
		return FALSE
	if(!isturf(victim.loc) || victim.buckled)
		if(feedback)
			moth.balloon_alert(moth, "can't wrap them there!")
		return FALSE
	return TRUE

/datum/action/cooldown/mothbug/targeted/cocoon/perform(mob/living/simple_animal/mothbug/moth, mob/living/carbon/victim)
	moth.visible_message(span_warning("[moth] starts spinning silk around [victim]!"), span_notice("I spin a cocoon around [victim]."))
	if(!do_after(moth, MOTHBUG_COCOON_TIME, victim, extra_checks = CALLBACK(src, PROC_REF(can_continue), moth, victim)))
		return
	if(!moth.spend_silk_charge(silk_cost))
		return
	var/obj/structure/mothbug_cocoon/cocoon = new(get_turf(victim), moth)
	cocoon.enclose(victim)
	log_combat(moth, victim, "cocooned")
	StartCooldown()

/datum/action/cooldown/mothbug/wing_dust
	name = "Wing Dust"
	desc = "Beat my wings to throw a cloud of scales. Everyone beside me is blinded and sneezing for a moment."
	button_icon_state = "aerosolize"
	silk_cost = MOTHBUG_COST_DUST
	cooldown_time = 20 SECONDS

/datum/action/cooldown/mothbug/wing_dust/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/moth = owner
	if(!moth.spend_silk_charge(silk_cost))
		return FALSE
	moth.set_mothbug_hidden(FALSE)
	moth.visible_message(span_warning("[moth] beats its wings, throwing up a choking cloud of scales!"), span_notice("I beat my wings and throw up a cloud of scales."))
	playsound(moth, 'sound/mobs/wingflap.ogg', 60, TRUE)
	for(var/turf/dusted in range(1, moth))
		new /obj/effect/temp_visual/small_smoke/mothbug_dust(dusted)
	for(var/mob/living/carbon/victim in range(1, moth))
		victim.set_eye_blur_if_lower(MOTHBUG_DUST_BLUR)
		victim.emote("sneeze", forced = TRUE)
		to_chat(victim, span_warning("Dusty scales fill my eyes and nose!"))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mothbug/squeeze
	name = "Squeeze Through"
	desc = "Middle-click a closed door beside me to flatten myself and squeeze under it, locked or not. Windows I slip through freely."
	button_icon_state = "jaunt"
	click_to_activate = TRUE
	silk_cost = MOTHBUG_COST_SQUEEZE
	cooldown_time = 5 SECONDS

/datum/action/cooldown/mothbug/squeeze/Activate(atom/target)
	var/mob/living/simple_animal/mothbug/moth = owner
	var/obj/structure/door/door = istype(target, /obj/structure/door) ? target : (locate(/obj/structure/door) in get_turf(target))
	if(!door || !moth.Adjacent(door) || !isturf(moth.loc))
		moth.balloon_alert(moth, "no door beside me!")
		return FALSE
	if(door.door_opened)
		moth.balloon_alert(moth, "it's open!")
		return FALSE
	var/direction = get_dir(moth, door)
	if(!(direction in GLOB.cardinals))
		moth.balloon_alert(moth, "line up with the door!")
		return FALSE
	var/turf/beyond = get_step(door, direction)
	if(!beyond || beyond.is_blocked_turf(TRUE))
		moth.balloon_alert(moth, "no room beyond!")
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(squeeze), moth, door, beyond)
	return TRUE

/datum/action/cooldown/mothbug/squeeze/proc/squeeze(mob/living/simple_animal/mothbug/moth, obj/structure/door/door, turf/beyond)
	moth.visible_message(span_notice("[moth] flattens itself against [door] and starts to wriggle under it."), span_notice("I flatten myself and wriggle under [door]."), vision_distance = 4)
	if(!do_after(moth, MOTHBUG_SQUEEZE_TIME, door) || QDELETED(door) || !moth.Adjacent(door))
		return
	if(beyond.is_blocked_turf(TRUE) || !moth.spend_silk_charge(silk_cost))
		return
	moth.forceMove(beyond)
	moth.visible_message(span_notice("[moth] wriggles out from under [door]."), span_notice("I squeeze through to the other side."), vision_distance = 4)
	StartCooldown()
