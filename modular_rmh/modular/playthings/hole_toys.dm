// Toys in and out of the holes: one rule set for the holes window and the ERP panel's storage actions.

/// Base time to work a toy in, the extra per bulk step, and the strain past comfort stretches both.
#define TOY_INSERT_TIME_BASE (3 SECONDS)
#define TOY_INSERT_TIME_PER_BULK (0.5 SECONDS)
/// Time to take an item back out by layer; the item's reach difficulty multiplies it.
#define TOY_REMOVE_TIME_OUTER (1 SECONDS)
#define TOY_REMOVE_TIME_INNER (3 SECONDS)
#define TOY_REMOVE_TIME_DEEP (8 SECONDS)
#define TOY_PUSH_DEEPER_TIME (5 SECONDS)
/// Fail chance to fish an item out, by layer, times reach difficulty; full lube halves it.
#define TOY_REMOVE_FAIL_INNER 10
#define TOY_REMOVE_FAIL_DEEP 30
/// A failed grab on an inside item may push it deeper instead.
#define TOY_SLIP_DEEPER_CHANCE 25
/// Fail chance to work a toy in, per unit of strain past comfort, before dryness; forcing skips the roll.
#define TOY_INSERT_FAIL_PER_STRAIN 20
#define TOY_INSERT_FAIL_CAP 75
#define TOY_STAMINA 10
/// Pleasure a stored toy gives per bulk on each flow tick, the deep layer's bonus, and the line chance.
#define TOY_STIR_PLEASURE_PER_BULK 0.4
#define TOY_STIR_DEEP_MULT 1.5
#define TOY_STIR_MESSAGE_CHANCE 8

/obj/item
	/// How hard the item is to grip and draw back out; a flared base or a string lowers it.
	var/body_storage_reach_difficulty = 1
	/// Pleasure per flow tick while stored inside, or null to go by bulk.
	var/body_storage_stir_pleasure

/obj/item/dildo/plug
	body_storage_reach_difficulty = 0.5

/obj/item/anal_beads
	body_storage_reach_difficulty = 0.6

/// Bulk as the storage sees it; items without one go by weight class, like their girth does.
/obj/item/proc/get_effective_storage_bulk()
	return max(body_storage_bulk || w_class, 1)

/// Pleasure this item gives on one flow tick while stored in [layer].
/obj/item/proc/get_body_storage_stir_pleasure(layer)
	var/pleasure = isnull(body_storage_stir_pleasure) ? get_effective_storage_bulk() * TOY_STIR_PLEASURE_PER_BULK : body_storage_stir_pleasure
	if(layer == STORAGE_LAYER_DEEP)
		pleasure *= TOY_STIR_DEEP_MULT
	return pleasure

/// Things stored for other reasons are not toys and never stir.
/obj/item/proc/counts_as_stored_toy()
	return TRUE

/obj/item/oviposition_egg/counts_as_stored_toy()
	return FALSE

/obj/item/mob_holder/internal_womb/counts_as_stored_toy()
	return FALSE

/obj/item/penis_fake/counts_as_stored_toy()
	return FALSE

/obj/item/reagent_containers/glass/fluid_pump/counts_as_stored_toy()
	return FALSE

/obj/item/natural/worms/leech/counts_as_stored_toy()
	return FALSE

// ---- Stirring ----

/// Each flow tick the toys inside stir: pleasure by size and depth, and now and then a line.
/obj/item/organ/genitals/filling_organ/proc/stir_stored_toys()
	if(!owner || owner.stat != CONSCIOUS)
		return
	var/list/layers = SEND_SIGNAL(src, COMSIG_BODYSTORAGE_GET_LISTS)
	if(!islist(layers))
		return
	var/pleasure = 0
	var/obj/item/loudest
	var/loudest_pleasure = 0
	for(var/layer in list(STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP))
		for(var/obj/item/stored as anything in layers[layer])
			if(!stored.counts_as_stored_toy())
				continue
			var/gain = stored.get_body_storage_stir_pleasure(layer)
			pleasure += gain
			if(gain > loudest_pleasure)
				loudest = stored
				loudest_pleasure = gain
	if(pleasure <= 0)
		return
	SEND_SIGNAL(owner, COMSIG_SEX_GENERIC_ACTION, owner, pleasure, 0, pleasure * 0.2, owner)
	owner.hole_shake_hook("stir", 0.5)
	if(prob(TOY_STIR_MESSAGE_CHANCE))
		var/hole_word = orifice?.opening_name || pick(altnames)
		to_chat(owner, span_love(pick(
			"[loudest] shifts inside my [hole_word], and I feel every bit of it.",
			"Every step reminds me of [loudest] filling me.",
			"[loudest] presses somewhere deep and good.",
		)))

// ---- Rules shared by the window and the panel ----

/// How long one try to work [toy] in takes: base plus bulk, stretched by the strain past comfort.
/obj/item/organ/genitals/filling_organ/proc/get_toy_insert_time(obj/item/toy)
	var/datum/orifice/opening = get_orifice()
	var/strain_over = opening ? max(0, opening.get_strain(toy.get_insert_girth()) - 1) : 0
	return (TOY_INSERT_TIME_BASE + TOY_INSERT_TIME_PER_BULK * toy.get_effective_storage_bulk()) * (1 + strain_over)

/// Chance one try to work [toy] in slips: strain past comfort times dryness; forcing never slips.
/obj/item/organ/genitals/filling_organ/proc/get_toy_insert_fail_chance(obj/item/toy, use_force = FALSE)
	var/datum/orifice/opening = get_orifice()
	if(!opening || use_force)
		return 0
	var/strain_over = max(0, opening.get_strain(toy.get_insert_girth()) - 1)
	return clamp(TOY_INSERT_FAIL_PER_STRAIN * strain_over * opening.get_dryness_multiplier(), 0, TOY_INSERT_FAIL_CAP)

/// How long one try to draw [toy] out of [layer] takes; a flared base or a string shortens it.
/obj/item/organ/genitals/filling_organ/proc/get_toy_remove_time(obj/item/toy, layer)
	var/base = TOY_REMOVE_TIME_INNER
	switch(layer)
		if(STORAGE_LAYER_OUTER)
			base = TOY_REMOVE_TIME_OUTER
		if(STORAGE_LAYER_DEEP)
			base = TOY_REMOVE_TIME_DEEP
	return base * max(toy.body_storage_reach_difficulty, 0.1)

/// Chance one try to draw [toy] out of [layer] finds no grip; full lube halves it.
/obj/item/organ/genitals/filling_organ/proc/get_toy_remove_fail_chance(obj/item/toy, layer)
	var/base = 0
	switch(layer)
		if(STORAGE_LAYER_INNER)
			base = TOY_REMOVE_FAIL_INNER
		if(STORAGE_LAYER_DEEP)
			base = TOY_REMOVE_FAIL_DEEP
	var/lube = orifice ? orifice.get_lube_level() : 0
	return clamp(base * toy.body_storage_reach_difficulty * (1 - 0.5 * lube), 0, 90)

/// Rolls one try to work [toy] in; TRUE when it slips from the grip, with the pop and the body's whimper.
/obj/item/organ/genitals/filling_organ/proc/roll_toy_insert_slip(obj/item/toy, use_force = FALSE)
	if(!prob(get_toy_insert_fail_chance(toy, use_force)))
		return FALSE
	if(owner)
		play_hole_sound("slip", 30, 'sound/misc/mat/pop.ogg')
		owner.toy_voice("whimper", get_orifice(FALSE))
	return TRUE

/// One try to draw [toy] out of [layer]: the grip roll, a slip deeper, the storage removal, the deep passage.
/obj/item/organ/genitals/filling_organ/proc/resolve_toy_removal(obj/item/toy, layer, mob/living/performer)
	if(!layer)
		layer = SEND_SIGNAL(src, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, toy)
	if(!layer || !toy.can_remove_from_body_storage(BODYSTORAGE_REMOVE_MANUAL))
		return TOY_REMOVE_STUCK
	if(prob(get_toy_remove_fail_chance(toy, layer)))
		if(owner)
			// A grip lost on something in reach slips audibly; a deep push that moves nothing is quiet.
			if(layer != STORAGE_LAYER_DEEP)
				play_hole_sound("slip", 30, 'sound/misc/mat/pop.ogg')
			owner.toy_voice("whimper", get_orifice(FALSE))
		if(layer == STORAGE_LAYER_INNER && prob(TOY_SLIP_DEEPER_CHANCE) && move_toy_deeper(toy))
			return TOY_REMOVE_SLIPPED_DEEPER
		return TOY_REMOVE_NO_GRIP
	// Pick the clip before the passage widens the opening to the toy.
	var/withdraw_clip = get_orifice(FALSE)?.get_passage_sound("withdraw")
	if(!SEND_SIGNAL(src, COMSIG_BODYSTORAGE_TRY_REMOVE, toy, layer, BODYSTORAGE_REMOVE_MANUAL))
		return TOY_REMOVE_STUCK
	// Inside items pass the opening through the storage hook; deep ones have to be dragged past it here.
	if(layer == STORAGE_LAYER_DEEP && orifice_type)
		get_orifice().pass_through(toy.get_pass_through_girth(), SEX_FORCE_MID, performer)
	if(owner)
		playsound(owner, withdraw_clip || pick('modular_rmh/sound/effects/cork_pop.ogg', 'modular_rmh/sound/effects/cork_pop (2).ogg'), 40, TRUE, -2, ignore_walls = FALSE)
	return TOY_REMOVE_OUT

/// Moves [toy] from the inside layer to the deep one, or puts it back when it does not fit.
/obj/item/organ/genitals/filling_organ/proc/move_toy_deeper(obj/item/toy)
	if(!SEND_SIGNAL(src, COMSIG_BODYSTORAGE_TRY_REMOVE, toy, STORAGE_LAYER_INNER, BODYSTORAGE_REMOVE_INTERNAL))
		return FALSE
	switch(SEND_SIGNAL(src, COMSIG_BODYSTORAGE_TRY_INSERT, toy, STORAGE_LAYER_DEEP, FALSE))
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			return TRUE
	SEND_SIGNAL(src, COMSIG_BODYSTORAGE_FORCE_INSERT, toy, STORAGE_LAYER_INNER)
	return FALSE

/// A voice cue through the moan pack; a raw hole turns it to pain, the whimper stays female, the gagged gag.
/mob/living/proc/toy_voice(key, datum/orifice/opening)
	if(stat != CONSCIOUS)
		return
	if(opening?.get_soreness_state() >= ORIFICE_STATE_RAW)
		key = "painmoan"
	if(!can_speak())
		key = "sexmoangag"
	else if(key == "whimper" && gender != FEMALE)
		key = "groan"
	emote(key, forced = TRUE)

// ---- The panel's storage actions borrow the same rules ----

/// Times the next cycle for working [toy] into [hole].
/datum/sex_action/proc/time_toy_insert_cycle(obj/item/organ/genitals/filling_organ/hole, obj/item/toy)
	if(istype(hole) && toy)
		do_time = hole.get_toy_insert_time(toy)

/// Picks what the next cycle reaches for in [hole]'s [layer] and times the cycle for it; null when empty.
/datum/sex_action/proc/choose_toy_to_reach(obj/item/organ/genitals/filling_organ/hole, layer)
	if(!istype(hole))
		return null
	var/list/items = hole.get_body_storage_items_for_interaction(layer, BODYSTORAGE_REMOVE_MANUAL)
	if(!length(items))
		return null
	var/obj/item/toy = pick(items)
	do_time = hole.get_toy_remove_time(toy, layer)
	return toy

/// TRUE while [toy] still sits in [hole]'s [layer] where a hand can reach it.
/datum/sex_action/proc/toy_still_in_reach(obj/item/organ/genitals/filling_organ/hole, obj/item/toy, layer)
	if(!istype(hole) || QDELETED(toy))
		return FALSE
	return (toy in hole.get_body_storage_items_for_interaction(layer, BODYSTORAGE_REMOVE_MANUAL))

/// The start cue of a storage action: [hole]'s wear-aware insert clip, or the old wet pair without an opening.
/datum/sex_action/proc/play_toy_reach_sound(obj/item/organ/genitals/filling_organ/hole, mob/living/target, vol)
	var/fallback = pick('sound/misc/mat/insert (1).ogg', 'sound/misc/mat/insert (2).ogg')
	if(istype(hole) && hole.owner)
		hole.play_hole_sound("insert", vol, fallback)
		return
	playsound(target, fallback, vol, TRUE, ignore_walls = FALSE)

// ---- The window's self flow ----

/obj/item/organ/genitals/filling_organ/proc/get_toy_hole_word()
	return get_orifice()?.opening_name || pick(altnames)

/obj/item/organ/genitals/filling_organ/breasts/get_toy_hole_word()
	return "cleavage"

/obj/item/organ/genitals/filling_organ/breasts/get_toy_remove_fail_chance(obj/item/toy, layer)
	return 0

/// The vagina, anus or breasts this window id names, or null.
/mob/living/carbon/human/proc/get_toy_hole(hole_id)
	switch(hole_id)
		if("vagina")
			return get_real_organ(src, ORGAN_SLOT_VAGINA)
		if("anus")
			return get_real_organ(src, ORGAN_SLOT_ANUS)
		if("breasts")
			return get_real_organ(src, ORGAN_SLOT_BREASTS)
	return null

/// The hole among vagina, anus and cleavage that stores [toy], or null.
/mob/living/carbon/human/proc/find_toy_hole(obj/item/toy)
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS, ORGAN_SLOT_BREASTS))
		var/obj/item/organ/genitals/filling_organ/hole = get_real_organ(src, slot)
		if(istype(hole) && SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, toy))
			return hole
	return null

/// Why nothing can be worked in or out of [hole] right now, or null when the body is free to.
/mob/living/carbon/human/proc/get_hole_toy_block_reason(obj/item/organ/genitals/filling_organ/hole)
	if(stat != CONSCIOUS)
		return "I am in no state for that."
	if(incapacitated())
		return "I can't reach like this."
	if(has_status_effect(/datum/status_effect/labour))
		return "Not now. My body has other work."
	return get_hole_access_block_reason(hole, src)

/// Why [hole] is out of [actor]'s reach whatever the body's state: armor, a worn device, or something inside it.
/mob/living/carbon/human/proc/get_hole_access_block_reason(obj/item/organ/genitals/filling_organ/hole, mob/living/actor)
	// The panel's rules: only armor above light keeps hands off, and a worn device seals its slot.
	if(get_sex_covering_garment(hole.slot == ORGAN_SLOT_BREASTS ? BODY_ZONE_CHEST : BODY_ZONE_PRECISE_GROIN, actor))
		return "My clothes are in the way."
	if(is_organ_slot_blocked(hole.slot))
		return "Something worn keeps me out of there."
	if(hole.orifice && length(hole.orifice.get_live_penetrations()))
		return "Not with that inside me."
	return null

/// Why [toy] cannot go into [hole] now, or null; the storage's own fit check does the judging.
/mob/living/carbon/human/proc/get_toy_insert_block_reason(obj/item/organ/genitals/filling_organ/hole, obj/item/toy)
	if(istype(toy, /obj/item/anal_beads))
		return "Beads go in one at a time; the bead play actions handle those."
	if(!toy.can_enter_body_storage_layer(STORAGE_LAYER_INNER))
		return "That cannot go in there."
	var/datum/component/body_storage/storage = hole.GetComponent(/datum/component/body_storage)
	if(!storage)
		return "There is nowhere for it to go."
	switch(storage.check_fit(hole, toy, STORAGE_LAYER_INNER, FALSE))
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			return null
		if(INSERT_FEEDBACK_BLOCKED)
			return "Something blocks the way in."
		if(INSERT_FEEDBACK_STUFFED)
			return "There is no room left in there."
		if(INSERT_FEEDBACK_TRY_FORCE)
			return "It might fit with more force or something slick. The panel can force it."
	return "It will not go in."

/mob/living/carbon/human/proc/can_keep_working_toy_in(obj/item/organ/genitals/filling_organ/hole, obj/item/toy)
	return stat == CONSCIOUS && !incapacitated() && toy.loc == src && hole.owner == src

/mob/living/carbon/human/proc/can_keep_working_toy_out(obj/item/organ/genitals/filling_organ/hole, obj/item/toy)
	return stat == CONSCIOUS && !incapacitated() && hole.owner == src && SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, toy)

// ---- Insert ----

/// Works the held item into [hole_id] over a few seconds; TRUE when the attempt starts.
/mob/living/carbon/human/proc/try_insert_toy(hole_id)
	var/obj/item/organ/genitals/filling_organ/hole = get_toy_hole(hole_id)
	if(!istype(hole))
		return FALSE
	var/obj/item/toy = get_active_held_item()
	if(!toy)
		to_chat(src, span_warning("My hand is empty."))
		return FALSE
	var/reason = get_hole_toy_block_reason(hole) || get_toy_insert_block_reason(hole, toy)
	if(reason)
		to_chat(src, span_warning(reason))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(insert_toy), hole, toy)
	return TRUE

/mob/living/carbon/human/proc/insert_toy(obj/item/organ/genitals/filling_organ/hole, obj/item/toy)
	var/hole_word = hole.get_toy_hole_word()
	var/feel = hole.get_hole_feel("insert")
	visible_message(span_warning("[src] starts working [toy] into [p_their()] [hole_word]..."), span_love("I start working [toy] into my [hole_word]..."))
	hole.play_hole_sound("insert", 40, pick('sound/misc/mat/insert (1).ogg', 'sound/misc/mat/insert (2).ogg'))
	SEND_SIGNAL(src, COMSIG_SEX_HOLE_BEFORE_INSERT, toy, hole.slot, src)
	if(!do_after(src, hole.get_toy_insert_time(toy), src, extra_checks = CALLBACK(src, PROC_REF(can_keep_working_toy_in), hole, toy)))
		to_chat(src, span_warning("I stop before [toy] is in."))
		return FALSE
	adjust_stamina(TOY_STAMINA)
	if(hole.roll_toy_insert_slip(toy))
		to_chat(src, span_warning("[toy] slips from my grip and will not go in. It wants a slicker hole, or a gentler angle."))
		return FALSE
	var/fit = SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_TRY_INSERT, toy, STORAGE_LAYER_INNER, FALSE)
	switch(fit)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			update_inv_hands()
			SEND_SIGNAL(src, COMSIG_SEX_HOLE_AFTER_INSERT, toy, hole.slot, src)
			hole_shake_hook("insert", 1)
			var/brim = fit == INSERT_FEEDBACK_ALMOST_FULL ? ", filling me almost to the brim" : ""
			visible_message(span_notice("[src] works [toy] into [p_their()] [hole_word]."), span_love("[toy] slides into my [hole_word][brim][feel]."))
			SEND_SIGNAL(src, COMSIG_SEX_GENERIC_ACTION, src, toy.get_body_storage_stir_pleasure(STORAGE_LAYER_INNER) * 2, 0, 0.5, src)
			return TRUE
	to_chat(src, span_warning("[toy] will not go in after all."))
	return FALSE

// ---- Take out ----

/// Draws [toy] out of whichever hole holds it; TRUE when the attempt starts.
/mob/living/carbon/human/proc/try_remove_toy(obj/item/toy)
	var/obj/item/organ/genitals/filling_organ/hole = find_toy_hole(toy)
	if(!hole)
		return FALSE
	var/reason = get_hole_toy_block_reason(hole)
	if(!reason && !toy.can_remove_from_body_storage(BODYSTORAGE_REMOVE_MANUAL))
		reason = "It will not come out by hand."
	if(!reason && get_active_held_item())
		reason = "I need a free hand for that."
	if(reason)
		to_chat(src, span_warning(reason))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(remove_toy), hole, toy)
	return TRUE

/mob/living/carbon/human/proc/remove_toy(obj/item/organ/genitals/filling_organ/hole, obj/item/toy)
	var/layer = SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, toy)
	if(!layer)
		return FALSE
	var/hole_word = hole.get_toy_hole_word()
	var/feel = hole.get_hole_feel("withdraw")
	visible_message(span_warning("[src] reaches in after [toy]..."), span_love("I reach into my [hole_word] after [toy]..."))
	SEND_SIGNAL(src, COMSIG_SEX_HOLE_BEFORE_REMOVE, toy, hole.slot, src)
	if(!do_after(src, hole.get_toy_remove_time(toy, layer), src, extra_checks = CALLBACK(src, PROC_REF(can_keep_working_toy_out), hole, toy)))
		to_chat(src, span_warning("I give up on [toy] for now."))
		return FALSE
	adjust_stamina(TOY_STAMINA)
	switch(hole.resolve_toy_removal(toy, layer, src))
		if(TOY_REMOVE_SLIPPED_DEEPER)
			to_chat(src, span_warning("[toy] slips from my fingers and deeper inside, past where I can reach."))
			return FALSE
		if(TOY_REMOVE_NO_GRIP)
			to_chat(src, span_warning("I can't get a grip on [toy]."))
			return FALSE
		if(TOY_REMOVE_STUCK)
			to_chat(src, span_warning("[toy] will not come."))
			return FALSE
	SEND_SIGNAL(src, COMSIG_SEX_HOLE_AFTER_REMOVE, toy, hole.slot, src)
	hole_shake_hook("remove", 1)
	if(!put_in_active_hand(toy))
		toy.forceMove(get_turf(src))
	visible_message(span_notice("[src] draws [toy] out of [p_their()] [hole_word]."), span_love("I draw [toy] out of my [hole_word][feel]."))
	SEND_SIGNAL(src, COMSIG_SEX_GENERIC_ACTION, src, toy.get_body_storage_stir_pleasure(layer), 0, 0, src)
	return TRUE

// ---- Push out, blind ----

/// Whether this body can tell its stored items apart by feel.
/mob/living/carbon/human/proc/can_feel_stored_items()
	return has_quirk(/datum/quirk/neutral/selfawaregeni)

/// The items in [hole] a hand could work out; eggs, hatchlings and stand-ins have their own ways.
/mob/living/carbon/human/proc/get_pushable_toys(obj/item/organ/genitals/filling_organ/hole)
	var/list/toys = list()
	if(!istype(hole))
		return toys
	for(var/layer in list(STORAGE_LAYER_OUTER, STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP))
		for(var/obj/item/stored as anything in hole.get_body_storage_items_for_interaction(layer, BODYSTORAGE_REMOVE_MANUAL))
			if(istype(stored, /obj/item/oviposition_egg) || istype(stored, /obj/item/mob_holder/internal_womb) || istype(stored, /obj/item/penis_fake))
				continue
			toys += stored
	return toys

/// Works whatever comes to hand out of [hole]: the same take-out, with the item picked blind.
/mob/living/carbon/human/proc/try_push_out_random_toy(obj/item/organ/genitals/filling_organ/hole)
	var/list/toys = get_pushable_toys(hole)
	if(!length(toys))
		to_chat(src, span_warning("There is nothing in there I could push out."))
		return FALSE
	return try_remove_toy(pick(toys))

// ---- Push deeper ----

/// Whether [toy] can be pushed from the inside layer into the deep one, with the reason when not.
/mob/living/carbon/human/proc/get_toy_push_deeper_block_reason(obj/item/organ/genitals/filling_organ/hole, obj/item/toy)
	if(SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, toy) != STORAGE_LAYER_INNER)
		return "It is not where I could push it from."
	if(!toy.can_enter_body_storage_layer(STORAGE_LAYER_DEEP))
		return "That cannot go deeper."
	switch(SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_CHECK_FIT, toy, STORAGE_LAYER_DEEP, FALSE))
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			return null
	return "There is no room deeper in."

/mob/living/carbon/human/proc/try_push_toy_deeper(obj/item/toy)
	var/obj/item/organ/genitals/filling_organ/hole = find_toy_hole(toy)
	if(!hole)
		return FALSE
	var/reason = get_hole_toy_block_reason(hole) || get_toy_push_deeper_block_reason(hole, toy)
	if(reason)
		to_chat(src, span_warning(reason))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(push_toy_deeper), hole, toy)
	return TRUE

/mob/living/carbon/human/proc/push_toy_deeper(obj/item/organ/genitals/filling_organ/hole, obj/item/toy)
	var/hole_word = hole.get_toy_hole_word()
	visible_message(span_warning("[src] pushes at [toy], working it deeper..."), span_love("I push [toy] deeper into my [hole_word]..."))
	if(!do_after(src, TOY_PUSH_DEEPER_TIME, src, extra_checks = CALLBACK(src, PROC_REF(can_keep_working_toy_out), hole, toy)))
		to_chat(src, span_warning("I stop pushing."))
		return FALSE
	adjust_stamina(TOY_STAMINA)
	if(!hole.move_toy_deeper(toy))
		to_chat(src, span_warning("[toy] will not go any deeper."))
		return FALSE
	hole.play_hole_sound("settle", 40, 'sound/misc/mat/endin.ogg')
	hole_shake_hook("push_deeper", 1)
	toy_voice("groan", hole.get_orifice(FALSE))
	var/feel = hole.get_hole_feel("settle")
	to_chat(src, span_love("[toy] settles deep inside, past where my fingers reach[feel]."))
	SEND_SIGNAL(src, COMSIG_SEX_GENERIC_ACTION, src, toy.get_body_storage_stir_pleasure(STORAGE_LAYER_DEEP), 0, 0.5, src)
	return TRUE

#undef TOY_INSERT_TIME_BASE
#undef TOY_INSERT_TIME_PER_BULK
#undef TOY_REMOVE_TIME_OUTER
#undef TOY_REMOVE_TIME_INNER
#undef TOY_REMOVE_TIME_DEEP
#undef TOY_PUSH_DEEPER_TIME
#undef TOY_REMOVE_FAIL_INNER
#undef TOY_REMOVE_FAIL_DEEP
#undef TOY_SLIP_DEEPER_CHANCE
#undef TOY_INSERT_FAIL_PER_STRAIN
#undef TOY_INSERT_FAIL_CAP
#undef TOY_STAMINA
#undef TOY_STIR_PLEASURE_PER_BULK
#undef TOY_STIR_DEEP_MULT
#undef TOY_STIR_MESSAGE_CHANCE
