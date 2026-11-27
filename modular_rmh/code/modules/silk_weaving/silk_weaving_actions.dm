/datum/action/cooldown/silk_weaving
	name = "Silk Weaving"
	button_icon = 'modular_rmh/icons/mob/actions/silk_weaving.dmi'
	background_icon = 'icons/mob/actions/roguespells.dmi'
	background_icon_state = "spell0"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	panel = "Spells"
	/// A timed weave is running; blocks starting another.
	var/weaving = FALSE

/datum/action/cooldown/silk_weaving/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(weaving)
		if(feedback)
			owner.balloon_alert(owner, "already weaving!")
		return FALSE

/// TRUE if user can take stamina_cost more fatigue without exhausting.
/datum/action/cooldown/silk_weaving/proc/has_stamina_for(mob/living/user, stamina_cost)
	return HAS_TRAIT(user, TRAIT_NOSTAMINA) || user.stamina + stamina_cost <= user.maximum_stamina

/datum/action/cooldown/silk_weaving/web
	name = "Weave Web"
	desc = "Spin thin webbing on my tile, then reinforce it into dense silk. Moving or stopping during reinforcement leaves the web thin."
	button_icon_state = "webthin"
	cooldown_time = 30 SECONDS
	var/spin_time = 4 SECONDS
	var/stamina_cost = 30

/datum/action/cooldown/silk_weaving/web/proc/can_place(turf/place)
	if(!isfloorturf(place) || place.density || (locate(/obj/structure/bed/silk) in place))
		return FALSE
	var/web_count = 0
	for(var/obj/structure/spider/stickyweb/web in place)
		if(QDELETED(web))
			continue
		if(!istype(web, /obj/structure/spider/stickyweb/thin))
			return FALSE
		web_count++
	return web_count <= 1

/datum/action/cooldown/silk_weaving/web/Activate(atom/target)
	var/mob/living/user = owner
	var/turf/web_turf = get_turf(user)
	if(user.loc != web_turf || !can_place(web_turf))
		to_chat(user, span_warning("I need bare floor, or thin webbing that I can reinforce."))
		return FALSE
	if(!has_stamina_for(user, stamina_cost))
		to_chat(user, span_warning("I am too tired to weave."))
		return FALSE
	var/obj/structure/spider/stickyweb/existing_web = locate() in web_turf
	var/passes = existing_web ? 1 : 2
	var/completed = 0
	weaving = TRUE
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	user.visible_message(span_notice("[user] begins weaving webbing."), span_notice("I begin weaving webbing."))
	for(var/pass in 1 to passes)
		var/reinforcing = !isnull(existing_web)
		var/finished = do_after(user, spin_time, reinforcing ? existing_web : user)
		if(QDELETED(src))
			return FALSE
		if(!finished || owner != user)
			break
		if((reinforcing && QDELETED(existing_web)) || user.loc != web_turf || (locate(/obj/structure/spider/stickyweb) in web_turf) != existing_web || !can_place(web_turf))
			break
		if(!has_stamina_for(user, stamina_cost))
			to_chat(user, span_warning("I am too tired to keep weaving."))
			break
		user.adjust_stamina(stamina_cost)
		if(reinforcing)
			qdel(existing_web)
			existing_web = new /obj/structure/spider/stickyweb(web_turf)
			to_chat(user, span_notice("I reinforce the thin webbing into dense silk."))
		else
			existing_web = new /obj/structure/spider/stickyweb/thin(web_turf)
			if(pass < passes)
				to_chat(user, span_notice("The thin web is ready. I keep reinforcing it; moving or stopping now leaves it thin."))
		completed++
	weaving = FALSE
	if(!completed)
		build_all_button_icons(UPDATE_BUTTON_STATUS)
		return FALSE
	StartCooldown()
	return TRUE

/datum/action/cooldown/silk_weaving/bed
	name = "Spin Silk Bed"
	desc = "Spread soft silk bedding on clear floor. Weave the same spot again to add a sheltering veil and the comfort of a proper bed."
	button_icon_state = "bed"
	cooldown_time = 30 SECONDS
	var/spin_time = 8 SECONDS
	var/stamina_cost = 60

/datum/action/cooldown/silk_weaving/bed/proc/can_place(turf/place)
	if(!isfloorturf(place) || place.density)
		return FALSE
	var/beds = 0
	for(var/obj/thing in place)
		if(QDELETED(thing))
			continue
		if(istype(thing, /obj/structure/bed/silk))
			var/obj/structure/bed/silk/bed = thing
			if(bed.upgraded || ++beds > 1)
				return FALSE
		else if(istype(thing, /obj/structure) || thing.density)
			return FALSE
	return TRUE

/datum/action/cooldown/silk_weaving/bed/Activate(atom/target)
	var/mob/living/user = owner
	var/turf/bed_turf = get_turf(user)
	if(user.loc != bed_turf || !can_place(bed_turf))
		to_chat(user, span_warning("I need clear floor, or unfinished silk bedding."))
		return FALSE
	if(!has_stamina_for(user, stamina_cost))
		to_chat(user, span_warning("I am too tired to weave a silk bed."))
		return FALSE
	var/obj/structure/bed/silk/existing_bed = locate() in bed_turf
	weaving = TRUE
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	user.visible_message(span_notice("[user] begins weaving silk bedding."), span_notice("I begin weaving silk bedding."))
	var/finished = do_after(user, spin_time, user)
	if(QDELETED(src))
		return FALSE
	weaving = FALSE
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	if(!finished || owner != user)
		return FALSE
	if(user.loc != bed_turf || (locate(/obj/structure/bed/silk) in bed_turf) != existing_bed || !can_place(bed_turf))
		to_chat(user, span_warning("There is no longer room for the silk bed."))
		return FALSE
	if(!has_stamina_for(user, stamina_cost))
		to_chat(user, span_warning("I am too tired to finish weaving."))
		return FALSE
	user.adjust_stamina(stamina_cost)
	if(existing_bed)
		existing_bed.upgrade()
		to_chat(user, span_notice("I add a sheltering veil over the silk bedding."))
	else
		new /obj/structure/bed/silk(bed_turf)
	StartCooldown()
	return TRUE

/datum/action/cooldown/silk_weaving/cocoon
	name = "Weave Cocoon"
	desc = "Wrap an adjacent person, or myself, in supporting silk. Weaving takes five seconds and movement interrupts it. Three uses; each recovers five minutes after it is spent. The occupant can resist free, or others can cut or break it open."
	button_icon = 'modular_rmh/icons/obj/rescue_cocoon.dmi'
	button_icon_state = "intact"
	click_to_activate = TRUE
	var/charges = 3
	var/max_charges = 3
	var/charge_delay = 5 MINUTES
	var/weave_time = 5 SECONDS

/datum/action/cooldown/silk_weaving/cocoon/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(charges <= 0)
		if(feedback)
			owner.balloon_alert(owner, "out of silk!")
		return FALSE

/datum/action/cooldown/silk_weaving/cocoon/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	button.maptext = MAPTEXT_PIXELIFY("[charges]/[max_charges]")

/datum/action/cooldown/silk_weaving/cocoon/set_click_ability(mob/on_who)
	. = ..()
	to_chat(on_who, span_notice("I ready my silk. <b>Middle-click</b> someone next to me, or myself, to weave a cocoon."))

/datum/action/cooldown/silk_weaving/cocoon/proc/valid_weave(mob/living/user, mob/living/patient)
	if(QDELETED(src) || QDELETED(user) || owner != user || !HAS_TRAIT(user, TRAIT_SILK_WEAVER) || user.incapacitated(IGNORE_GRAB) || !isturf(user.loc))
		return FALSE
	if(QDELETED(patient) || patient.stat == DEAD || !isturf(patient.loc) || patient.buckled || length(patient.buckled_mobs))
		return FALSE
	return patient == user || user.Adjacent(patient)

/datum/action/cooldown/silk_weaving/cocoon/Activate(atom/target)
	var/mob/living/user = owner
	var/mob/living/patient = target
	if(!isliving(patient) || !valid_weave(user, patient))
		user.balloon_alert(user, "can't wrap that!")
		return FALSE
	weaving = TRUE
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	user.visible_message(span_notice("[user] begins wrapping [patient == user ? "[user.p_them()]self" : "[patient]"] in silk, weaving quick, precise layers around [patient.p_their()] body."), ignored_mobs = list(patient))
	if(patient == user)
		to_chat(patient, span_notice("I draw silk around myself, weaving a snug, supporting cocoon."))
	else if(patient.stat == CONSCIOUS)
		to_chat(patient, span_notice("[user] begins wrapping me in silk. Each careful pass draws the threads snugly around my body."))
	else
		to_chat(patient, span_notice("Through the haze, I feel something soft drawing close around my body - tight, snug, and oddly comforting."))
	var/finished = do_after(user, weave_time, patient, extra_checks = CALLBACK(src, PROC_REF(valid_weave), user, patient))
	if(QDELETED(src))
		return FALSE
	weaving = FALSE
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	if(!finished || !valid_weave(user, patient))
		if(!QDELETED(user))
			to_chat(user, span_notice("The wrapping comes loose before I can secure it."))
		if(!QDELETED(patient) && patient != user)
			to_chat(patient, span_notice("The forming layers loosen before they can enclose me."))
		return FALSE
	var/obj/structure/spider/rescue_cocoon/cocoon = new(get_turf(patient))
	if(!cocoon.enclose(patient))
		qdel(cocoon)
		return FALSE
	charges--
	addtimer(CALLBACK(src, PROC_REF(restore_charge)), charge_delay)
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	cocoon.visible_message(span_notice("[user] draws the final strands into place, enclosing [patient] in a cocoon of layered silk."), ignored_mobs = list(patient))
	if(patient == user)
		to_chat(patient, span_notice("I settle within my finished cocoon, held by the silk I drew around myself."))
	else if(patient.stat == CONSCIOUS)
		to_chat(patient, span_notice("[user] finishes enclosing me in silk. The cocoon holds my body snugly, yielding slightly as I breathe."))
	else
		to_chat(patient, span_notice("The weaving sensation fades. A steady, enclosing pressure remains around my body."))
	return TRUE

/datum/action/cooldown/silk_weaving/cocoon/proc/restore_charge()
	charges = min(max_charges, charges + 1)
	build_all_button_icons(UPDATE_BUTTON_STATUS)
