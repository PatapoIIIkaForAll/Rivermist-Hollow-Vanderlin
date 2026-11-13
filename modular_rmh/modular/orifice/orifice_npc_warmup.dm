// Horny NPCs warm a tight or dry hole up before they push in.

/// Warm-up cycles at most before the NPC pushes in anyway.
#define NPC_WARMUP_CYCLES 6
/// Spit worked into the hole per warm-up cycle; six cycles reach the slick level.
#define NPC_WARMUP_SALIVA_UNITS 0.7
/// Warm-up spit stops once the hole holds this much of it.
#define NPC_WARMUP_SALIVA_CAP 4
/// Share of the gap to the insertion closed per warm-up cycle.
#define NPC_WARMUP_STRETCH_SHARE 0.08

/datum/sex_action/npc
	/// Readies a tight or dry hole before going in; its on_start and on_perform call the warm-up procs.
	var/warms_up_orifice = FALSE
	/// Warm-up cycles left; above zero while warming.
	var/warmup_cycles_left = 0
	/// The warm-up finished and the penetration went in.
	var/warmup_done = FALSE

/// The act's own entry line and sound; each warming NPC penetration overrides it.
/datum/sex_action/npc/proc/show_penetration_start(mob/living/user, mob/living/target)
	return

/// The hole takes this girth within comfort and is slick enough to skip the dryness warning.
/datum/sex_action/npc/proc/is_orifice_ready_for(datum/orifice/orifice, girth)
	return orifice.get_strain(girth) <= 1 && orifice.get_dryness_multiplier() < ORIFICE_DRY_WARNING_MULT

/// TRUE while a warm-up is due or running: the hole is too tight or too dry for this girth.
/datum/sex_action/npc/proc/needs_orifice_warmup(mob/living/user, mob/living/target)
	if(!warms_up_orifice || warmup_done)
		return FALSE
	if(warmup_cycles_left > 0)
		return TRUE
	var/girth = get_penetration_girth(user, target)
	if(!girth)
		return FALSE
	var/datum/orifice/orifice = get_penetrated_orifice(user, target, TRUE)
	if(!orifice)
		return FALSE
	return !is_orifice_ready_for(orifice, girth)

/// Registering now would hold the hole open at full girth, so a due warm-up defers the entry.
/datum/sex_action/npc/begin_orifice_penetration(mob/living/user, mob/living/target)
	if(!needs_orifice_warmup(user, target))
		return ..()
	warmup_cycles_left = NPC_WARMUP_CYCLES

/// Stays out of the hole so the warm-up does not count as inside, and announces it.
/datum/sex_action/npc/proc/start_orifice_warmup(mob/living/user, mob/living/target)
	warmup_cycles_left = NPC_WARMUP_CYCLES
	end_orifice_penetration()
	var/datum/orifice/orifice = get_penetrated_orifice(user, target, TRUE)
	var/opening = orifice ? orifice.opening_name : "hole"
	var/mob/living/receiver = get_orifice_receiver(user, target)
	if(receiver == user)
		var/mob/living/giver = get_orifice_penetrator(user, target)
		user.visible_message(span_warning("[user] settles over [giver], readying [user.p_their()] own [opening] first."))
	else if(ishuman(user))
		user.visible_message(span_warning("[user] holds off, working spit and fingers into [receiver]'s [opening] first."))
	else
		user.visible_message(span_warning("[user] holds off, lapping at [receiver]'s [opening] first."))

/// One warm-up line; a riding NPC readies its own hole, and hands add finger lines.
/datum/sex_action/npc/proc/get_orifice_warmup_line(mob/living/user, mob/living/receiver, mob/living/giver, opening)
	var/has_hands = ishuman(user)
	var/list/lines
	if(receiver == user)
		lines = list(
			"[user] grinds [user.p_their()] [opening] along [giver]'s cock until both are slick.",
			"[user] rocks over [giver], working [user.p_their()] [opening] looser.",
		)
		if(has_hands)
			lines += "[user] spits into [user.p_their()] palm and works it into [user.p_their()] [opening]."
			lines += "[user] eases a wet finger into [user.p_their()] own [opening]."
		return pick(lines)
	lines = list(
		"[user] laps at [receiver]'s [opening], slicking it with spit.",
		"[user] slathers [receiver]'s [opening] until it glistens.",
	)
	if(has_hands)
		lines += "[user] works a spit-wet finger into [receiver]'s [opening]."
		lines += "[user] spreads [receiver]'s [opening] with two slick fingers."
	return pick(lines)

/// One warm-up cycle in place of a thrust; TRUE while still warming, so on_perform stops there.
/datum/sex_action/npc/proc/run_orifice_warmup_cycle(mob/living/user, mob/living/target)
	if(warmup_cycles_left <= 0)
		return FALSE
	var/girth = get_penetration_girth(user, target)
	var/datum/orifice/orifice = get_penetrated_orifice(user, target, TRUE)
	if(!girth || !orifice)
		finish_orifice_warmup(user, target)
		return FALSE
	var/mob/living/receiver = get_orifice_receiver(user, target)
	var/mob/living/giver = get_orifice_penetrator(user, target)
	if(can_show_action_message(user, target))
		user.visible_message(span_love(get_orifice_warmup_line(user, receiver, giver, orifice.opening_name)))
	playsound(receiver, 'sound/misc/mat/fingering.ogg', sex_volume, TRUE, -2, ignore_walls = FALSE)
	var/datum/reagents/holder = orifice.organ?.reagents
	var/spit = min(NPC_WARMUP_SALIVA_UNITS, NPC_WARMUP_SALIVA_CAP - (holder?.get_reagent_amount(/datum/reagent/consumable/saliva) || 0))
	if(spit > 0)
		orifice.add_lube(/datum/reagent/consumable/saliva, spit, user)
	orifice.stretch_toward(girth, SEX_FORCE_MID, NPC_WARMUP_STRETCH_SHARE)
	perform_sex_action(receiver, giver, 1.5, 0, 1)
	warmup_cycles_left--
	if(warmup_cycles_left > 0 && !is_orifice_ready_for(orifice, girth))
		return TRUE
	finish_orifice_warmup(user, target)
	return FALSE

/// Ends the warm-up: registers the penetration and plays the act's own entry.
/datum/sex_action/npc/proc/finish_orifice_warmup(mob/living/user, mob/living/target)
	warmup_cycles_left = 0
	warmup_done = TRUE
	begin_orifice_penetration(user, target)
	show_penetration_start(user, target)

/// TRUE when the penis fits the hole at its widest; npc_rides puts the target's penis in the NPC's hole.
/proc/npc_penetration_can_fit(mob/living/npc, mob/living/target, hole_slot, npc_rides = FALSE)
	var/mob/living/penetrator = npc_rides ? target : npc
	var/mob/living/receiver = npc_rides ? npc : target
	var/obj/item/organ/genitals/penis/penis = penetrator.getorganslot(ORGAN_SLOT_PENIS)
	var/obj/item/organ/genitals/filling_organ/hole = receiver.getorganslot(hole_slot)
	if(!penis || !istype(hole) || !hole.orifice_type)
		return TRUE
	var/datum/orifice/orifice = hole.get_orifice(TRUE)
	return !orifice || penis.get_insert_girth() <= orifice.get_max_girth()

#undef NPC_WARMUP_CYCLES
#undef NPC_WARMUP_SALIVA_UNITS
#undef NPC_WARMUP_SALIVA_CAP
#undef NPC_WARMUP_STRETCH_SHARE
