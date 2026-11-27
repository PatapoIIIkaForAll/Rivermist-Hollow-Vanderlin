/datum/quirk/neutral/bladder
	name = "Bladder"
	desc = "Whatever I drink does not stay with me for long. It gathers low in my belly, and sooner or later my bladder makes its wishes known."
	desc_hint = "Drink fills my bladder. Half full, I start to think of the privy; nearly full, I squirm; past full, it aches until I relieve myself, from the IC tab or my holes window. A toilet takes it all without a drop astray, and while I sleep or drift away my bladder leaves me be. Those who enjoy it, with Watersports in their ERP preferences, can share it with me."
	preview_render = FALSE

/datum/quirk/neutral/bladder/on_spawn()
	. = ..()
	owner?.AddComponent(/datum/component/bladder)

/datum/quirk/neutral/bladder/on_remove()
	if(!QDELETED(owner))
		qdel(owner.GetComponent(/datum/component/bladder))
	return ..()

/datum/erp_preference/boolean/watersports
	name = "Watersports"
	description = "Piss play: being pissed on or into, drinking it, pressing on a full bladder until it gives, and squirting at the peak. Both partners need it on. Piss takes the Bladder quirk; squirting takes only a pussy, though a full bladder makes it likelier and wetter."
	default_value = FALSE
	category = "General"

/mob/living/carbon/human/adjust_hydration(change)
	var/hydration_before = hydration
	. = ..()
	var/gained = hydration - hydration_before
	if(gained > 0 && !HAS_TRAIT(src, TRAIT_NOHUNGER))
		SEND_SIGNAL(src, COMSIG_HUMAN_HYDRATION_GAINED, gained)

/mob/living/proc/watersports_allowed()
	return sees_watersports() && get_erp_pref(/datum/erp_preference/boolean/watersports) == TRUE

/mob/living/proc/get_bladder()
	RETURN_TYPE(/datum/component/bladder)
	return GetComponent(/datum/component/bladder)

/mob/living/proc/is_bladder_at_rest()
	if(stat != CONSCIOUS || has_status_effect(/datum/status_effect/reverie))
		return TRUE
	return !client || client.manual_afk || client.is_afk()

/datum/component/bladder
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/reagents/contents
	var/urge = BLADDER_URGE_NONE
	/// Units already drunk that have yet to reach the bladder.
	var/pending = 0
	var/flow_timer

/datum/component/bladder/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	contents = new /datum/reagents(BLADDER_OVERFILL_LIMIT, NO_REACT)

/datum/component/bladder/Destroy(force)
	var/mob/living/carbon/human/owner = parent
	if(!QDELETED(owner))
		owner.remove_status_effect(/datum/status_effect/bladder_urge)
	deltimer(flow_timer)
	QDEL_NULL(contents)
	return ..()

/datum/component/bladder/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HUMAN_HYDRATION_GAINED, PROC_REF(on_hydration_gained))
	add_verb(parent, /mob/living/carbon/human/proc/relieve_bladder)

/datum/component/bladder/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HUMAN_HYDRATION_GAINED)
	remove_verb(parent, /mob/living/carbon/human/proc/relieve_bladder)

/datum/component/bladder/proc/on_hydration_gained(datum/source, amount)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/owner = parent
	if(owner.is_bladder_at_rest())
		return
	pending = min(pending + amount * CONFIG_GET(number/bladder_fill_rate), max(BLADDER_MAX_FILL - contents.total_volume, 0))
	if(pending > 0 && !flow_timer)
		flow_timer = addtimer(CALLBACK(src, PROC_REF(flow)), BLADDER_FLOW_INTERVAL, TIMER_STOPPABLE)

/// Moves a little of what was drunk into the bladder, paused while the owner rests.
/datum/component/bladder/proc/flow()
	flow_timer = null
	var/mob/living/carbon/human/owner = parent
	if(!owner.is_bladder_at_rest())
		var/amount = min(pending, BLADDER_FLOW_UNITS)
		pending -= amount
		fill(amount)
	if(pending > 0)
		flow_timer = addtimer(CALLBACK(src, PROC_REF(flow)), BLADDER_FLOW_INTERVAL, TIMER_STOPPABLE)

/datum/component/bladder/proc/fill(amount)
	amount = min(amount, BLADDER_MAX_FILL - contents.total_volume)
	if(amount <= 0)
		return
	contents.add_reagent(get_urine_type(), amount)
	update_urge()

/datum/component/bladder/proc/get_urine_type()
	return HAS_TRAIT(parent, TRAIT_HOLY_URINE) ? /datum/reagent/consumable/urine/holy : /datum/reagent/consumable/urine

/datum/component/bladder/proc/receive_from(datum/reagents/source, amount, mob/living/transfered_by)
	amount = min(amount, BLADDER_OVERFILL_LIMIT - contents.total_volume)
	if(amount <= 0 || !source)
		return 0
	. = source.trans_to(contents, amount, transfered_by = transfered_by, show_message = FALSE) || 0
	update_urge()

/datum/component/bladder/proc/get_volume()
	return contents.total_volume

/datum/component/bladder/proc/get_urge_for_volume(volume)
	var/ratio = volume / BLADDER_CAPACITY
	if(ratio >= BLADDER_BURSTING_RATIO)
		return BLADDER_URGE_BURSTING
	if(ratio >= BLADDER_URGENT_RATIO)
		return BLADDER_URGE_URGENT
	if(ratio >= BLADDER_NEED_RATIO)
		return BLADDER_URGE_NEED
	return BLADDER_URGE_NONE

/datum/component/bladder/proc/update_urge()
	var/new_urge = get_urge_for_volume(contents.total_volume)
	if(new_urge == urge)
		return
	var/rising = new_urge > urge
	urge = new_urge
	var/mob/living/carbon/human/owner = parent
	if(urge == BLADDER_URGE_NONE)
		owner.remove_status_effect(/datum/status_effect/bladder_urge)
		return
	var/datum/status_effect/bladder_urge/effect = owner.has_status_effect(/datum/status_effect/bladder_urge)
	if(effect)
		effect.set_level(urge, rising)
		return
	owner.apply_status_effect(/datum/status_effect/bladder_urge, urge)

/datum/component/bladder/proc/release_into(datum/target, amount, method, mob/living/transfered_by)
	amount = min(amount, contents.total_volume)
	if(amount <= 0 || !target)
		return 0
	. = contents.trans_to(target, amount, transfered_by = transfered_by, method = method, show_message = FALSE) || 0
	update_urge()

/datum/component/bladder/proc/release_onto_turf(turf/target_turf, amount, as_drops = FALSE)
	amount = min(amount, contents.total_volume)
	if(amount <= 0 || !target_turf)
		return 0
	spill_relief(target_turf, contents, amount, as_drops)
	update_urge()
	return amount

/datum/component/bladder/proc/release_onto_body(mob/living/carbon/human/target, coat_zone, amount)
	amount = min(amount, contents.total_volume)
	if(amount <= 0 || !target)
		return 0
	var/left = target.coat_with_fluid(coat_zone, contents, amount)
	if(left > 0)
		spill_relief(get_turf(target), contents, left, TRUE)
	update_urge()
	return amount

/datum/component/bladder/proc/empty_out()
	. = contents.total_volume
	contents.clear_reagents()
	update_urge()

/turf/proc/drains_relief()
	return !!(locate(/obj/structure/toilet) in src)

/turf/open/water/drains_relief()
	return water_volume >= 10 || ..()

/proc/spill_relief(turf/target_turf, datum/reagents/source, amount, as_drops)
	if(target_turf?.drains_relief())
		source.remove_all(amount)
	else
		spill_fluid_to_turf(target_turf, source, amount, as_drops)

/datum/status_effect/bladder_urge
	id = "bladder_urge"
	duration = -1
	tick_interval = BLADDER_URGE_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/debuff/bladder_urge
	var/level = BLADDER_URGE_NEED
	COOLDOWN_DECLARE(next_reminder)

/datum/status_effect/bladder_urge/on_creation(mob/living/new_owner, new_level = BLADDER_URGE_NEED)
	level = clamp(new_level, BLADDER_URGE_NEED, BLADDER_URGE_BURSTING)
	. = ..(new_owner)
	if(QDELETED(src))
		return
	announce()

/datum/status_effect/bladder_urge/on_apply()
	. = ..()
	refresh_stress()

/datum/status_effect/bladder_urge/on_remove()
	clear_stress()
	return ..()

/datum/status_effect/bladder_urge/tick()
	refresh_stress()
	if(COOLDOWN_FINISHED(src, next_reminder))
		remind()

/datum/status_effect/bladder_urge/get_examine_text(mob/user, list/P)
	if(owner.is_bladder_at_rest() || !user?.sees_watersports())
		return null
	switch(level)
		if(BLADDER_URGE_URGENT)
			return span_notice("SUBJECTPRONOUN is shifting from foot to foot.")
		if(BLADDER_URGE_BURSTING)
			return span_warning("SUBJECTPRONOUN is squirming with thighs pressed tight, a hand straying to the belly.")
	return null

/datum/status_effect/bladder_urge/proc/set_level(new_level, rising)
	level = clamp(new_level, BLADDER_URGE_NEED, BLADDER_URGE_BURSTING)
	refresh_stress()
	update_alert()
	if(rising)
		announce()

/datum/status_effect/bladder_urge/proc/announce()
	update_alert()
	if(owner.is_bladder_at_rest())
		return
	COOLDOWN_START(src, next_reminder, rand(BLADDER_REMINDER_MIN, BLADDER_REMINDER_MAX))
	to_chat(owner, span_warning(bladder_urge_text(owner, level)))

/datum/status_effect/bladder_urge/proc/remind()
	if(owner.is_bladder_at_rest())
		return
	COOLDOWN_START(src, next_reminder, rand(BLADDER_REMINDER_MIN, BLADDER_REMINDER_MAX))
	to_chat(owner, span_warning(bladder_reminder_text(owner, level)))
	if(level < BLADDER_URGE_URGENT)
		return
	var/static/list/fidgets = list(
		"%NAME shifts from foot to foot.",
		"%NAME presses %THEIR thighs together.",
		"%NAME fidgets, glancing about for somewhere private.",
	)
	var/fidget = replacetext(replacetext(pick(fidgets), "%NAME", "[owner]"), "%THEIR", owner.p_their())
	owner.watersports_message(span_notice(fidget), vision_distance = 3, ignored_mobs = list(owner))

/datum/status_effect/bladder_urge/proc/get_stresses()
	var/static/list/stresses = list(/datum/stress_event/bladder_need, /datum/stress_event/bladder_urgent, /datum/stress_event/bladder_bursting)
	return stresses

/datum/status_effect/bladder_urge/proc/clear_stress()
	owner.remove_stress(get_stresses())

/datum/status_effect/bladder_urge/proc/refresh_stress()
	if(owner.is_bladder_at_rest())
		clear_stress()
		return
	var/list/stresses = get_stresses()
	for(var/index in 1 to length(stresses))
		if(index == level)
			owner.add_stress(stresses[index])
		else
			owner.remove_stress(stresses[index])

/datum/status_effect/bladder_urge/proc/update_alert()
	if(!linked_alert)
		return
	linked_alert.name = bladder_alert_name(owner, level)
	linked_alert.desc = bladder_alert_desc(owner, level)

/atom/movable/screen/alert/status_effect/debuff/bladder_urge
	name = "Need to Go"
	desc = "A familiar weight sits low in my belly."
	icon_state = "debuff"

/datum/stress_event/bladder_need/get_desc(mob/living/user)
	return span_red(bladder_stress_text(user, BLADDER_URGE_NEED))

/datum/stress_event/bladder_urgent/get_desc(mob/living/user)
	return span_red(bladder_stress_text(user, BLADDER_URGE_URGENT))

/datum/stress_event/bladder_bursting/get_desc(mob/living/user)
	return span_red(bladder_stress_text(user, BLADDER_URGE_BURSTING))

/datum/stress_event/bladder_relief/get_desc(mob/living/user)
	return span_green(bladder_localized(user, "Sweet relief at last.", "Наконец-то облегчение."))

/datum/stress_event/bladder_need
	stress_change = 1
	desc = span_red("I need to relieve myself.")
	timer = 1 MINUTES

/datum/stress_event/bladder_urgent
	stress_change = 2
	desc = span_red("I really have to go. Where is a privy?")
	timer = 1 MINUTES

/datum/stress_event/bladder_bursting
	stress_change = 4
	desc = span_red("My bladder is bursting. It hurts to hold it in!")
	timer = 1 MINUTES

/datum/stress_event/bladder_relief
	stress_change = -2
	desc = span_green("Sweet relief at last.")
	timer = 5 MINUTES

/datum/reagent/consumable/urine
	name = "Urine"
	description = "Warm, salty and unmistakable."
	color = "#e6c84f"
	taste_description = "salt and warm bitterness"
	nutriment_factor = 0
	hydration_factor = 2

/mob/living/carbon/human/proc/relieve_bladder()
	set name = "Relieve Myself"
	set category = "IC"
	set desc = "Empty my bladder, into a privy if there is one."

	try_relieve_bladder()

/mob/living/carbon/human/proc/try_relieve_bladder()
	var/datum/component/bladder/bladder = get_bladder()
	if(!bladder || stat != CONSCIOUS)
		return FALSE
	if(bladder.get_volume() < BLADDER_RELIEVE_MIN_UNITS)
		to_chat(src, span_notice(bladder_localized(src, "I don't need to go right now.", "Мне пока не нужно.")))
		return FALSE
	var/obj/item/clothing/garment = get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, src)
	if(garment)
		to_chat(src, span_warning(bladder_localized(src, "[garment] is in the way.", "Мешает [garment].")))
		return FALSE
	if(doing())
		to_chat(src, span_warning(bladder_localized(src, "I'm busy with something else.", "Сейчас мне не до этого.")))
		return FALSE
	var/obj/target = get_relief_target()
	watersports_message(span_notice("[src] starts to relieve [p_them()]self[target ? " into [target]" : ""]."), span_notice(bladder_localized(src, "I start to relieve myself.", "Я начинаю справлять нужду.")), vision_distance = 3)
	var/amount = bladder.get_volume()
	if(!do_after(src, BLADDER_RELIEVE_BASE_TIME + amount * BLADDER_RELIEVE_TIME_PER_UNIT, src))
		return FALSE
	bladder = get_bladder()
	if(!bladder || stat != CONSCIOUS)
		return FALSE
	var/was_urgent = bladder.urge >= BLADDER_URGE_URGENT
	target = get_relief_target()
	if(istype(target, /obj/item/reagent_containers))
		bladder.release_into(target, bladder.get_volume(), null, src)
	else if(istype(target, /obj/structure/toilet))
		bladder.empty_out()
	bladder.release_onto_turf(get_turf(src), bladder.get_volume())
	playsound(src, pick(BLADDER_STREAM_SOUNDS), 25, TRUE, -2, ignore_walls = FALSE)
	to_chat(src, span_notice(bladder_relief_text(src, was_urgent)))
	if(was_urgent)
		add_stress(/datum/stress_event/bladder_relief)
	return TRUE

/datum/hole_status_menu/proc/build_bladder()
	var/datum/component/bladder/bladder = owner.get_bladder()
	if(!bladder)
		return null
	var/volume = bladder.get_volume()
	return list(
		"volume" = round(volume, 0.1),
		"capacity" = BLADDER_CAPACITY,
		"max" = BLADDER_MAX_FILL,
		"urge" = bladder.urge,
		"can_relieve" = volume >= BLADDER_RELIEVE_MIN_UNITS,
	)

/mob/living/carbon/human/proc/get_relief_target()
	RETURN_TYPE(/obj)
	var/obj/structure/toilet/toilet = locate() in get_turf(src)
	return toilet || get_relief_container() || get_toilet_in_reach()

/mob/living/carbon/human/proc/get_toilet_in_reach()
	for(var/obj/structure/toilet/toilet in range(1, src))
		if(Adjacent(toilet))
			return toilet
	return null

/mob/living/carbon/human/proc/get_relief_container()
	var/obj/item/reagent_containers/container = get_active_held_item()
	if(!istype(container) || !container.reagents || !container.is_refillable() || container.reagents.holder_full())
		return null
	return container
