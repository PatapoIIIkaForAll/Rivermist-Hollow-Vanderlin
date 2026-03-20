// ============================================================
// ACTION - Drunken Rage
// ============================================================

/datum/action/cooldown/drunken_rage
	name = "Drunken Rage"
	desc = "Channel your drunken fury! Requires alcohol in your blood."
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "ravox"
	cooldown_time = 30 SECONDS
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/cooldown/drunken_rage/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/C = owner
	if(C.drunkenness < DRUNKEN_BRAWLER_DRINK_THRESHOLD)
		return FALSE
	return TRUE

/datum/action/cooldown/drunken_rage/Trigger(trigger_flags, atom/target)
	if(!IsAvailable())
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			if(C.drunkenness < DRUNKEN_BRAWLER_DRINK_THRESHOLD)
				to_chat(owner, span_warning("I need more alcohol in my blood to fuel my rage!"))
		return FALSE
	var/mob/living/L = owner
	if(L.has_status_effect(/datum/status_effect/buff/drunken_rage))
		to_chat(owner, span_warning("I'm already in a drunken rage!"))
		return FALSE
	L.apply_status_effect(/datum/status_effect/buff/drunken_rage)
	StartCooldown()
	return TRUE

// ============================================================
// STATUS EFFECT - Drunken Rage
// ============================================================

/datum/status_effect/buff/drunken_rage
	id = "drunken_rage"
	alert_type = /atom/movable/screen/alert/status_effect/buff/drunken_rage
	effectedstats = list(STATKEY_CON = 2, STATKEY_END = 2, STATKEY_STR = 1)
	duration = -1
	tick_interval = 2 SECONDS
	var/last_drink_time
	var/sober_warning_given = FALSE
	var/list/highlighted_items = list()
	var/tmp/smashes_tables_original

/atom/movable/screen/alert/status_effect/buff/drunken_rage
	name = "Drunken Rage"
	desc = span_nicegreen("TAVERN BRAWL! My drunken fury empowers me!")
	icon_state = "drunk"

/datum/status_effect/buff/drunken_rage/on_apply()
	. = ..()
	if(!.)
		return FALSE
	last_drink_time = world.time
	ADD_TRAIT(owner, TRAIT_DODGEEXPERT, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_NOSEGRAB, TRAIT_STATUS_EFFECT(id))
	if(owner.mind?.martial_art)
		smashes_tables_original = owner.mind.martial_art.smashes_tables
		owner.mind.martial_art.smashes_tables = TRUE
	apply_blur_overlay()
	RegisterSignal(owner, COMSIG_MOB_THROW, PROC_REF(on_mob_throw))
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_item_attack))
	owner.add_filter(DRUNKEN_RAGE_GLOW_FILTER, 2, outline_filter(2, "#c4a020"))
	owner.visible_message(span_danger("[owner] enters a drunken frenzy!"), span_boldwarning("DRUNKEN RAGE! The alcohol fuels my fury!"))
	playsound(owner, 'sound/magic/barbroar.ogg', 100, TRUE)
	owner.add_stress(/datum/stress_event/drunk)
	return TRUE

/datum/status_effect/buff/drunken_rage/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DODGEEXPERT, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_NOSEGRAB, TRAIT_STATUS_EFFECT(id))
	if(owner.mind?.martial_art)
		owner.mind.martial_art.smashes_tables = smashes_tables_original
	remove_blur_overlay()
	owner.remove_filter(DRUNKEN_RAGE_GLOW_FILTER)
	UnregisterSignal(owner, list(COMSIG_MOB_THROW, COMSIG_MOB_ITEM_ATTACK))
	clear_highlights()
	owner.remove_stress(/datum/stress_event/drunk)
	. = ..()

/datum/status_effect/buff/drunken_rage/tick()
	if(!owner || !iscarbon(owner))
		qdel(src)
		return
	var/mob/living/carbon/C = owner
	if(C.drunkenness >= DRUNKEN_BRAWLER_DRINK_THRESHOLD)
		last_drink_time = world.time
		sober_warning_given = FALSE
	else if(!sober_warning_given)
		to_chat(owner, span_boldwarning("My drunken rage is fading... I need more alcohol!"))
		sober_warning_given = TRUE
	if(world.time - last_drink_time >= DRUNKEN_BRAWLER_SOBER_TIMER)
		to_chat(owner, span_danger("The lack of alcohol catches up to me... I can't stay awake..."))
		C.Sleeping(600)
		qdel(src)
		return
	if(!sober_warning_given && world.time - last_drink_time >= (DRUNKEN_BRAWLER_SOBER_TIMER - 30 SECONDS))
		to_chat(owner, span_warning("I feel drowsy... I should drink something soon or I'll pass out!"))
	highlight_alcohol()

// ============================================================
// VISUAL EFFECTS
// ============================================================

/datum/status_effect/buff/drunken_rage/proc/apply_blur_overlay()
	var/atom/movable/plane_master_controller/pm_controller = owner.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(pm_controller)
		pm_controller.add_filter(DRUNKEN_RAGE_BLUR_FILTER, 1, gauss_blur_filter(0.6))

/datum/status_effect/buff/drunken_rage/proc/remove_blur_overlay()
	var/atom/movable/plane_master_controller/pm_controller = owner.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	if(pm_controller)
		pm_controller.remove_filter(DRUNKEN_RAGE_BLUR_FILTER)

/datum/status_effect/buff/drunken_rage/proc/highlight_alcohol()
	clear_highlights()
	for(var/obj/item/reagent_containers/container in view(7, owner))
		if(!container.reagents)
			continue
		if(container.reagents.has_reagent(/datum/reagent/consumable/ethanol, 1, check_subtypes = TRUE))
			container.add_filter(DRUNKEN_RAGE_HIGHLIGHT_FILTER, 2, outline_filter(1, "#ffcc00"))
			highlighted_items += container

/datum/status_effect/buff/drunken_rage/proc/clear_highlights()
	for(var/obj/item/I in highlighted_items)
		if(!QDELETED(I))
			I.remove_filter(DRUNKEN_RAGE_HIGHLIGHT_FILTER)
	highlighted_items.Cut()

// ============================================================
// COMBAT MECHANICS
// ============================================================

/datum/status_effect/buff/drunken_rage/proc/on_mob_throw(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if(!isliving(source.pulling))
		return
	var/mob/living/thrown_mob = source.pulling
	RegisterSignal(thrown_mob, COMSIG_MOVABLE_IMPACT, PROC_REF(on_thrown_victim_impact))

/datum/status_effect/buff/drunken_rage/proc/on_thrown_victim_impact(mob/living/thrown, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	UnregisterSignal(thrown, COMSIG_MOVABLE_IMPACT)
	if(istype(hit_atom, /obj/structure))
		var/obj/structure/S = hit_atom
		S.visible_message(span_danger("[thrown] crashes through [S] with tremendous drunken force!"))
		S.take_damage(S.max_integrity)
	thrown.Knockdown(rand(100, 150))
	addtimer(CALLBACK(src, PROC_REF(reduce_throw_damage), thrown), 1)

/datum/status_effect/buff/drunken_rage/proc/reduce_throw_damage(mob/living/thrown)
	if(QDELETED(thrown))
		return
	thrown.adjustBruteLoss(-8)

/datum/status_effect/buff/drunken_rage/proc/on_item_attack(mob/living/source, mob/living/target, obj/item/weapon)
	SIGNAL_HANDLER
	if(!istype(weapon))
		return
	if(istype(weapon, /obj/item/weapon))
		return
	target.Knockdown(20)
	target.apply_damage(15, STAMINA)
	target.visible_message(span_danger("[source] smashes [target] with [weapon] in a drunken frenzy!"))
	playsound(target, pick('sound/combat/hits/onwood/woodimpact (1).ogg', 'sound/combat/hits/onwood/woodimpact (2).ogg'), 80, TRUE)
	weapon.take_damage(weapon.max_integrity * 0.3)
