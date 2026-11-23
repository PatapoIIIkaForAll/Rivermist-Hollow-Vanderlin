/mob/living/carbon/human/proc/feel_scent_bond(datum/musk_bond/bond, datum/component/musk/musk)
	var/datum/status_effect/musk_thrall/effect = has_status_effect(/datum/status_effect/musk_thrall) || apply_status_effect(/datum/status_effect/musk_thrall)
	effect?.hold(bond, musk)

/datum/status_effect/musk_thrall
	id = "musk_thrall"
	duration = -1
	tick_interval = MUSK_BOND_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/buff/musk_thrall
	var/level = 0
	var/list/contact_ends = list()

/datum/status_effect/musk_thrall/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_SEX_GET_AROUSAL_FLOOR, PROC_REF(on_get_arousal_floor))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/status_effect/musk_thrall/on_remove()
	UnregisterSignal(owner, list(COMSIG_SEX_GET_AROUSAL_FLOOR, COMSIG_LIVING_DEATH))
	for(var/datum/musk_bond/bond as anything in contact_ends)
		release(bond)
	return ..()

/datum/status_effect/musk_thrall/tick()
	for(var/datum/musk_bond/bond as anything in contact_ends)
		if(is_out_of_reach(bond))
			release(bond)
	if(!length(contact_ends))
		qdel(src)
		return
	update_level()
	pull_arousal_toward(owner, get_floor())
	if(level >= MUSK_BOND_DEVOTION)
		var/mob/living/carbon/human/thrall = owner
		thrall.keep_mood(/datum/stress_event/scent_devotion)
	for(var/datum/musk_bond/bond as anything in contact_ends)
		if(bond.get_level() >= MUSK_BOND_OBEDIENCE && prob(MUSK_HEART_CHANCE))
			bond.show_heart()

/datum/status_effect/musk_thrall/proc/is_out_of_reach(datum/musk_bond/bond)
	return QDELETED(bond) || bond.get_thrall_body() != owner || !bond.get_level() || world.time > contact_ends[bond]

/datum/status_effect/musk_thrall/proc/hold(datum/musk_bond/bond, datum/component/musk/musk)
	contact_ends[bond] = world.time + MUSK_BOND_CONTACT_LINGER
	if(!bond.begin_contact(musk))
		return
	update_level()
	var/mob/living/carbon/human/thrall = owner
	thrall.tell_once_per_contact(MUSK_LINE_BOND, musk_bond_contact_text(thrall, bond.get_level()))

/datum/status_effect/musk_thrall/proc/release(datum/musk_bond/bond)
	contact_ends -= bond
	bond.end_contact()

/datum/status_effect/musk_thrall/proc/update_level()
	var/deepest = 0
	for(var/datum/musk_bond/bond as anything in contact_ends)
		deepest = max(deepest, bond.get_level())
	if(level == deepest)
		return
	level = deepest
	update_alert()
	for(var/datum/musk_bond/bond as anything in contact_ends)
		bond.reaching_musk?.refresh_orders()

/datum/status_effect/musk_thrall/proc/update_alert()
	if(!linked_alert || !level)
		return
	linked_alert.name = musk_localized(owner, "Scent Bond \Roman[level]", "Власть запаха \Roman[level]")
	linked_alert.desc = musk_bond_alert_text(owner, level)

/datum/status_effect/musk_thrall/proc/get_floor()
	return level >= MUSK_BOND_LONGING ? MUSK_BOND_AROUSAL_HIGH : MUSK_BOND_AROUSAL_LOW

/datum/status_effect/musk_thrall/proc/on_get_arousal_floor(datum/source, list/floor_data)
	SIGNAL_HANDLER
	floor_data["floor"] = max(floor_data["floor"], get_floor())

/datum/status_effect/musk_thrall/proc/on_death(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/buff/musk_thrall
	name = "Scent Bond"
	desc = "A scent I belong to is near."
	icon_state = "stinky"

/datum/stress_event/scent_devotion
	stress_change = -3
	desc = span_green("That scent is near, and all is well.")
	timer = 1 MINUTES

/datum/stress_event/scent_devotion/get_desc(mob/living/user)
	return span_green(musk_localized(user, "That scent is near, and all is well.", "Тот самый запах рядом, и всё хорошо."))

/atom/movable/screen/plane_master/scent_hearts
	name = "scent hearts plane master"
	plane = MUSK_HEART_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/scent_hearts/proc/glow()
	if(!get_filter("heart_glow"))
		add_filter("heart_glow", 1, drop_shadow_filter(x = 0, y = 0, size = 4, color = MUSK_HEART_GLOW))
	addtimer(CALLBACK(src, PROC_REF(stop_glowing)), MUSK_HEART_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)

/atom/movable/screen/plane_master/scent_hearts/proc/stop_glowing()
	remove_filter("heart_glow")

/datum/musk_bond/proc/show_heart()
	var/mob/living/carbon/human/body = get_thrall_body()
	var/mob/living/carbon/human/viewer = reaching_musk?.parent
	if(!body || !viewer?.client)
		return
	var/image/heart = image('icons/effects/effects.dmi', body, "heart", FLY_LAYER)
	heart.plane = MUSK_HEART_PLANE
	heart.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
	heart.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	heart.pixel_w = rand(-8, 8)
	heart.pixel_z = 14
	flick_overlay(heart, list(viewer.client), MUSK_HEART_TIME)
	animate(heart, pixel_z = 34, alpha = 0, time = MUSK_HEART_TIME, easing = SINE_EASING)
	var/atom/movable/screen/plane_master/scent_hearts/hearts = viewer.hud_used?.plane_masters["[MUSK_HEART_PLANE]"]
	hearts?.glow()

/mob/living/proc/surely_conceives_from(mob/living/father)
	if(!father || father == src)
		return FALSE
	if(get_scent_bond_level(father) >= MUSK_BOND_DEVOTION)
		return TRUE
	return get_musk()?.conceives_from_devoted && father.get_scent_bond_level(src) >= MUSK_BOND_DEVOTION

/obj/item/organ/genitals/filling_organ/record_seed(datum/reagent/consumable/cum/seed, amount, allow_embryo_pregnancy, quickened)
	return ..(seed, amount, allow_embryo_pregnancy, quickened || owner?.surely_conceives_from(seed.get_parent_from_transfer()))
