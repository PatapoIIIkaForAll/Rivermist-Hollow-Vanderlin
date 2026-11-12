// Bead play: feed, draw, yank, tug and work a bead string, or bear down to push beads out.

/datum/sex_action/beads
	abstract_type = /datum/sex_action/beads
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	requires_free_hands = TRUE
	check_same_tile = FALSE
	hole_id = ORGAN_SLOT_ANUS
	do_time = 3 SECONDS
	stamina_cost = 0.15
	/// The hole as named in messages.
	var/hole_word = "ass"

/// The string inside the target's hole, if any.
/datum/sex_action/beads/proc/get_worn_beads(mob/living/target)
	RETURN_TYPE(/obj/item/anal_beads)
	var/obj/item/organ/organ = target?.getorganslot(hole_id)
	return locate(/obj/item/anal_beads) in organ?.contents

/// The string this action works on right now, or null.
/datum/sex_action/beads/proc/find_beads(mob/living/user, mob/living/target)
	RETURN_TYPE(/obj/item/anal_beads)
	return get_worn_beads(target)

/datum/sex_action/beads/proc/whose(mob/living/user, mob/living/target)
	return user == target ? user.p_their() : "[target]'s"

/datum/sex_action/beads/shows_on_menu(mob/living/user, mob/living/target)
	if(!target.getorganslot(hole_id))
		return FALSE
	return !!find_beads(user, target)

/datum/sex_action/beads/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!target.getorganslot(hole_id) || !find_beads(user, target))
		return FALSE
	if(requires_free_hands && !find_available_hand(user))
		return FALSE
	if(check_sex_lock(target, hole_id))
		return FALSE
	return check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE)

/datum/sex_action/beads/lock_sex_object(mob/living/user, mob/living/target)
	if(requires_free_hands)
		var/hand = get_hand_lock_slot(user)
		if(hand)
			add_sex_lock(user, hand)
	add_sex_lock(target, hole_id, null, FALSE)

// ---- Feed ----

/datum/sex_action/beads/feed
	abstract_type = /datum/sex_action/beads/feed
	description = "Push the string in one bead at a time. More force can push two, or into a full hole."

/datum/sex_action/beads/feed/find_beads(mob/living/user, mob/living/target)
	var/obj/item/anal_beads/worn = get_worn_beads(target)
	if(worn)
		return worn.beads_inside < worn.get_bead_count() ? worn : null
	var/obj/item/anal_beads/held = user.get_active_held_item()
	if(istype(held) && held.shape && !held.host_organ)
		return held
	return null

/datum/sex_action/beads/feed/on_start(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/anal_beads/beads = find_beads(user, target)
	user.visible_message(span_warning("[user] presses the tip of [beads] to [whose(user, target)] [hole_word]..."))

/datum/sex_action/beads/feed/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/anal_beads/beads = find_beads(user, target)
	if(!beads)
		stop_runtime()
		return
	var/obj/item/organ/organ = target.getorganslot(hole_id)
	var/use_force = force >= SEX_FORCE_HIGH
	var/pushes = (use_force && prob(force >= SEX_FORCE_EXTREME ? 50 : 25)) ? 2 : 1
	var/static/list/pushed_results = list(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_ALMOST_FULL, INSERT_FEEDBACK_OK_OVERRIDE)
	var/pushed = 0
	var/pleasure = 0
	var/pain = 0
	var/last_size
	var/result
	for(var/push in 1 to pushes)
		var/size = beads.get_bead(beads.beads_inside + 1)
		result = beads.push_bead(organ, use_force, user, force)
		if(!(result in pushed_results))
			break
		pushed++
		last_size = size
		pleasure += beads.get_bead_pleasure_of(size)
		pain += beads.get_bead_pain_of(size) * (result == INSERT_FEEDBACK_OK_FORCE ? 2 : 1)
	if(pushed)
		var/what = pushed > 1 ? "two beads" : "a [get_bead_word(last_size)]"
		var/strain = ""
		if(result == INSERT_FEEDBACK_OK_FORCE)
			strain = ", forcing it past the strain"
		else if(result == INSERT_FEEDBACK_ALMOST_FULL)
			strain = ", and it is getting tight"
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] feeds [what] into [whose(user, target)] [hole_word][strain]..."))
		playsound(target, list('sound/misc/mat/insert (1).ogg', 'sound/misc/mat/insert (2).ogg'), 30, TRUE, -2, ignore_walls = FALSE)
		perform_sex_action(target, user, pleasure, cap_bead_pain(target, pain, force, speed), pleasure * 0.6)
		handle_passive_ejaculation(target)
	if(beads.host_organ && beads.beads_inside >= beads.get_bead_count())
		user.visible_message(span_love("The last bead slips in, and the ring comes to rest against [whose(user, target)] [hole_word]."))
		stop_runtime()
		return
	if(pushed)
		return
	switch(result)
		if(INSERT_FEEDBACK_TRY_FORCE)
			to_chat(user, span_warning("The next bead will not go in without more force, or something slick."))
		if(INSERT_FEEDBACK_STUFFED)
			user.visible_message(span_warning("[capitalize(whose(user, target))] [hole_word] is too full to take another bead."))
			stop_runtime()
		if(BEADS_TOO_DEEP)
			user.visible_message(span_warning("The beads will not go any deeper into [whose(user, target)] [hole_word]."))
			stop_runtime()
		else
			to_chat(user, span_warning("The beads will not go in."))
			stop_runtime()

/datum/sex_action/beads/feed/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops feeding beads into [whose(user, target)] [hole_word]."))

/datum/sex_action/beads/feed/anus
	name = "Feed anal-beads"

/datum/sex_action/beads/feed/vagina
	name = "Feed vaginal-beads"
	hole_id = ORGAN_SLOT_VAGINA
	hole_word = "pussy"

// ---- Draw ----

/datum/sex_action/beads/draw
	abstract_type = /datum/sex_action/beads/draw
	description = "Draw the beads out one pop at a time. More force can pull a few out in a rush."

/datum/sex_action/beads/draw/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] hooks a finger through the ring of the beads in [whose(user, target)] [hole_word]..."))

/datum/sex_action/beads/draw/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/anal_beads/beads = find_beads(user, target)
	if(!beads)
		stop_runtime()
		return
	var/pulls = 1
	if(force >= SEX_FORCE_HIGH && prob(force >= SEX_FORCE_EXTREME ? 40 : 20))
		pulls = rand(2, 3)
	var/popped = 0
	var/pleasure = 0
	var/pain = 0
	var/last_size
	for(var/pull in 1 to pulls)
		var/size = beads.pull_bead(user, force)
		if(!size)
			break
		popped++
		last_size = size
		pleasure += beads.get_bead_pleasure_of(size)
		pain += beads.get_bead_pain_of(size) * 0.5
	if(!popped)
		stop_runtime()
		return
	if(popped > 1)
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] pulls, and [popped] beads rush out of [whose(user, target)] [hole_word] one after another!"))
		pleasure *= 1.2
	else
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] draws a [get_bead_word(last_size)] out of [whose(user, target)] [hole_word] with a soft pop."))
	playsound(target, 'sound/misc/mat/pop.ogg', 35, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, pleasure, cap_bead_pain(target, pain, force, speed), pleasure * 0.8)
	handle_passive_ejaculation(target)
	if(!beads.host_organ)
		user.visible_message(span_love("The last bead pops free of [whose(user, target)] [hole_word]."))
		stop_runtime()

/datum/sex_action/beads/draw/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets go of the ring."))

/datum/sex_action/beads/draw/anus
	name = "Draw anal-beads"

/datum/sex_action/beads/draw/vagina
	name = "Draw vaginal-beads"
	hole_id = ORGAN_SLOT_VAGINA
	hole_word = "pussy"

// ---- Yank ----

/datum/sex_action/beads/yank
	abstract_type = /datum/sex_action/beads/yank
	description = "Rip the whole string out at once. A clench or a held-in hole can catch it."
	continous = FALSE

/datum/sex_action/beads/yank/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] wraps [user.p_their()] fingers tight around the ring of the beads in [whose(user, target)] [hole_word]..."))

/// A partner who holds in or has auto-clench armed catches the string mid-yank.
/datum/sex_action/beads/yank/proc/is_caught(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return target.is_holding_fluids_in() || (target.cmode && target.wants_auto_clench())

/datum/sex_action/beads/yank/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/anal_beads/beads = find_beads(user, target)
	if(!beads)
		stop_runtime()
		return
	var/caught = is_caught(user, target)
	var/count = caught ? min(rand(1, 2), beads.beads_inside) : beads.beads_inside
	var/pleasure = 0
	var/pain = 0
	// Everything torn free crosses the ring together: one passage at the widest bead.
	var/list/sizes = beads.pull_beads(count, user, force)
	var/popped = length(sizes)
	for(var/size in sizes)
		pleasure += beads.get_bead_pleasure_of(size)
		pain += beads.get_bead_pain_of(size)
	if(!popped)
		return
	playsound(target, 'sound/misc/mat/pop.ogg', 50, TRUE, -2, ignore_walls = FALSE)
	if(caught)
		user.visible_message(spanify_force("[user] yanks, but [target] clenches down hard and the string catches; only [popped] bead\s tear free!"))
		pain *= 1.5
	else
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] yanks the whole string out of [whose(user, target)] [hole_word]! [popped] bead\s pop free in one rattling rush!"))
		pleasure = pleasure * 1.2 + popped * 0.3
	pleasure = min(pleasure, 15)
	perform_sex_action(target, user, pleasure, cap_bead_pain(target, pain, force, speed), min(pleasure * 1.2, 15))
	handle_passive_ejaculation(target)

/datum/sex_action/beads/yank/anus
	name = "Yank anal-beads"

/datum/sex_action/beads/yank/vagina
	name = "Yank vaginal-beads"
	hole_id = ORGAN_SLOT_VAGINA
	hole_word = "pussy"

// ---- Tug ----

/datum/sex_action/beads/tug
	abstract_type = /datum/sex_action/beads/tug
	description = "Tug the ring so the beads shift inside. Hard tugs can pop one free."

/datum/sex_action/beads/tug/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] takes hold of the ring at [whose(user, target)] [hole_word]..."))

/datum/sex_action/beads/tug/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/anal_beads/beads = find_beads(user, target)
	if(!beads)
		stop_runtime()
		return
	var/pleasure = 0.6 + 0.25 * force
	if(force >= SEX_FORCE_HIGH && prob(15 + 10 * (force - SEX_FORCE_HIGH)))
		var/size = beads.pull_bead(user, force)
		if(size)
			pleasure += beads.get_bead_pleasure_of(size)
			user.visible_message(spanify_force("[user] tugs too hard, and a [get_bead_word(size)] pops out of [whose(user, target)] [hole_word]!"))
			playsound(target, 'sound/misc/mat/pop.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	else if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] tugs the ring, and the beads shift inside [whose(user, target)] [hole_word]..."))
	perform_sex_action(target, user, pleasure, 0, pleasure * 0.5)
	handle_passive_ejaculation(target)
	if(!beads.host_organ)
		stop_runtime()

/datum/sex_action/beads/tug/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets the ring go."))

/datum/sex_action/beads/tug/anus
	name = "Tug anal-beads"

/datum/sex_action/beads/tug/vagina
	name = "Tug vaginal-beads"
	hole_id = ORGAN_SLOT_VAGINA
	hole_word = "pussy"

// ---- Work ----

/datum/sex_action/beads/work
	abstract_type = /datum/sex_action/beads/work
	description = "Pop the outermost bead out and push it back in, over and over."

/datum/sex_action/beads/work/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] starts working the beads in [whose(user, target)] [hole_word]..."))

/datum/sex_action/beads/work/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/anal_beads/beads = find_beads(user, target)
	if(!beads)
		stop_runtime()
		return
	var/size = beads.get_bead(beads.beads_inside)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] pops a [get_bead_word(size)] out of [whose(user, target)] [hole_word] and pushes it back in..."))
	playsound(target, 'sound/misc/mat/pop.ogg', 25, TRUE, -2, ignore_walls = FALSE)
	// The outer bead pops out and back in: one passage through the ring.
	beads.pass_bead(beads.host_organ, beads.beads_inside, force, user)
	var/pleasure = beads.get_bead_pleasure_of(size) * 1.3
	perform_sex_action(target, user, pleasure, cap_bead_pain(target, beads.get_bead_pain_of(size) * 0.5, force, speed), pleasure * 0.8)
	handle_passive_ejaculation(target)

/datum/sex_action/beads/work/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops working the beads."))

/datum/sex_action/beads/work/anus
	name = "Work anal-beads"

/datum/sex_action/beads/work/vagina
	name = "Work vaginal-beads"
	hole_id = ORGAN_SLOT_VAGINA
	hole_word = "pussy"

// ---- Bear down ----

/datum/sex_action/beads/bear_down
	abstract_type = /datum/sex_action/beads/bear_down
	description = "Push the beads out of yourself, no hands."
	requires_free_hands = FALSE
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS

/datum/sex_action/beads/bear_down/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && ..()

/datum/sex_action/beads/bear_down/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return user == target

/datum/sex_action/beads/bear_down/on_start(mob/living/user, mob/living/target)
	. = ..()
	// Pushing out ends holding in, as expelling fluids does.
	user.remove_status_effect(/datum/status_effect/holding_fluids_in)
	user.visible_message(span_warning("[user] bears down, straining at the beads in [user.p_their()] [hole_word]..."))

/datum/sex_action/beads/bear_down/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/anal_beads/beads = find_beads(user, target)
	if(!beads)
		stop_runtime()
		return
	var/size = beads.pull_bead(null, force)
	if(!size)
		stop_runtime()
		return
	user.visible_message(spanify_force("[user] strains, and a [get_bead_word(size)] pops out of [user.p_their()] [hole_word]."), spanify_force("I bear down and push a [get_bead_word(size)] out of my [hole_word]."))
	playsound(user, 'sound/misc/mat/pop.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	var/pleasure = beads.get_bead_pleasure_of(size)
	perform_sex_action(user, user, pleasure, cap_bead_pain(user, beads.get_bead_pain_of(size) * 0.3, force, speed), pleasure * 0.6)
	handle_passive_ejaculation(user)
	if(!beads.host_organ)
		user.visible_message(span_love("The whole string slides free of [user] and drops to the floor."))
		stop_runtime()

/datum/sex_action/beads/bear_down/anus
	name = "Expel anal-beads"

/datum/sex_action/beads/bear_down/vagina
	name = "Expel vaginal-beads"
	hole_id = ORGAN_SLOT_VAGINA
	hole_word = "pussy"
