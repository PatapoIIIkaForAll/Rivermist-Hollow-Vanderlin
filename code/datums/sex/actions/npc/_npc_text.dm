// Act text for horny NPC acts: family words, room/me/hear lines per beat, stages and state tails.

/// Perform cycles from the start that still read as the opening.
#define NPC_ACT_OPENING_CYCLES 2
/// Orgasm progress on either side from which the act reads as late.
#define NPC_ACT_LATE_PROGRESS 70
/// Chance in percent that a perform line carries a state tail.
#define NPC_ACT_TAIL_CHANCE 33

/datum/sex_action/npc
	/// Perform cycles since the act started; the first few read as the opening.
	var/act_cycles = 0
	/// Id of the last state tail used, so two lines in a row never share one.
	var/last_tail
	/// Lines composed by the base room hook; stays null when a subtype replaces the hook.
	var/list/text_lines
	/// Stage the perform room hook composes for.
	var/text_stage
	/// Middle variant the perform room hook composes.
	var/text_variant

/datum/sex_action/npc/on_start(mob/living/user, mob/living/target)
	act_cycles = 0
	last_tail = null
	return ..()

/// Act words for this family as an assoc list; humanoids use these, other families override them.
/datum/horny_family_profile/proc/get_act_words(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return list(
		// The hunter's cock.
		"part" = "cock",
		// Word before the part in start lines: a possessive, or "a" for a body of many.
		"article" = their,
		// The hunter's possessive and object pronouns.
		"their" = their,
		"them" = user.p_them(),
		// What slaps and stutters on each thrust.
		"body" = "hips",
		// Entry phrase before "[their] [part] into [target]'s [hole]".
		"mount" = "lines up and drives",
		// Thrust verbs, used in order: a pump, a rut, a plain fuck.
		"thrusts" = list("pumps", "ruts", "fucks"),
		// Tied by a knot: room phrase before "[target]'s [hole]", and the whole me phrase.
		"tied" = list("room" = "grinds [their] swollen knot deeper into", "me" = "grinds [their] swollen knot deeper into me"),
		// Pinning phrase for the hold perform line, followed by "and fucks them".
		"hold" = "pins [target]'s hips",
		// Tails under an aggressive hold, each an id with a room and a me form.
		"body_tails" = list(
			list("id" = "grip", "room" = ", [their] grip bruising [target]'s wrists", "me" = ", [their] grip bruising my wrists"),
			list("id" = "shoulders", "room" = ", a hand flat between [target]'s shoulders", "me" = ", a hand flat between my shoulders"),
		),
		// Climax motion, before the room or me spill tail.
		"spill" = "shoves in to the hilt and goes rigid",
		// Room spill tail: "[spill], [spill_room] into [target]'s [hole]!".
		"spill_room" = "spilling",
		// Me spill tail: "[spill], and [spill_me] into me!".
		"spill_me" = "warmth floods",
		// Family sound for hear lines of acts without their own sound.
		"hear" = "wet slaps and grunting",
		// Sounds for hear lines by act key.
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and a wet slap",
			"anal" = "a strangled grunt",
			"throat" = "choking",
			"ride" = "a low moan and skin on skin",
			"facesitting" = "muffled sounds",
			"handjob" = "skin sliding on skin",
			"jerk_over" = "quick, wet strokes",
			"body_rub" = "skin dragging on skin",
		),
	)

/// The hunter's family words for this act.
/datum/sex_action/npc/proc/get_act_words(mob/living/user, mob/living/target)
	var/datum/horny_family_profile/profile = user.get_horny_family_profile()
	var/list/words = profile.get_act_words(user, target)
	// A hunter with no seed, like a female spider on her ovipositor, only pulses.
	if(!hunter_has_seed(user))
		words["spill_room"] = "pulsing"
		words["spill_me"] = "[user.p_they()] pulses"
	return words

/// Whether the hunter has testicles, so its climax lines may spill seed.
/datum/sex_action/npc/proc/hunter_has_seed(mob/living/user)
	return !!user.getorganslot(ORGAN_SLOT_TESTICLES)

/// Whether the hunter's family has hands to grab with.
/datum/sex_action/npc/proc/hunter_has_hands(mob/living/user)
	var/datum/horny_family_profile/profile = user.get_horny_family_profile()
	return profile.has_hands

/// A family's whole-line override for a beat, with %HOLE% filled in; null when the family has none.
/datum/sex_action/npc/proc/override_lines(list/words, key, hole, hear)
	var/list/lines = words[key]
	if(!islist(lines))
		return null
	return act_lines(replacetext(lines["room"], "%HOLE%", hole), replacetext(lines["me"], "%HOLE%", hole), hear)

/// The hunter's part: "strapon" for a strapon, else the family word.
/datum/sex_action/npc/proc/get_act_part(mob/living/user, list/words)
	var/obj/item/organ/genitals/penis/penis = get_users_penis(user)
	if(penis?.strapon)
		return "strapon"
	return words["part"]

/// The victim's cock word: "strapon" or "cock".
/datum/sex_action/npc/proc/get_penis_word(mob/living/owner)
	var/obj/item/organ/genitals/penis/penis = owner?.getorganslot(ORGAN_SLOT_PENIS)
	return penis?.strapon ? "strapon" : "cock"

/// The hole this act uses: the orifice's opening name, else a word for the hole slot.
/datum/sex_action/npc/proc/get_act_hole(mob/living/user, mob/living/target)
	var/datum/orifice/orifice = get_penetrated_orifice(user, target, FALSE)
	if(orifice?.opening_name)
		return orifice.opening_name
	switch(hole_id)
		if(ORGAN_SLOT_VAGINA)
			return "pussy"
		if(ORGAN_SLOT_ANUS)
			return "ass"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "throat"
	return "mouth"

/// "I hear ..." for this act, from the act's sound or the family sound.
/datum/sex_action/npc/proc/get_act_hear(list/words, act_key)
	var/list/sounds = words["hear_acts"]
	var/act_sound = (islist(sounds) && sounds[act_key]) || words["hear"]
	return "I hear [act_sound]."

/// Orgasm progress of a mob, zero without arousal data.
/datum/sex_action/npc/proc/get_act_progress(mob/living/body)
	if(QDELETED(body))
		return 0
	var/list/data = list()
	SEND_SIGNAL(body, COMSIG_SEX_GET_AROUSAL, data)
	return data["orgasm_progress"] || 0

/// "tied", "opening", "middle" or "late" for the next perform line.
/datum/sex_action/npc/proc/get_act_stage(mob/living/user, mob/living/target)
	if(horny_knot_between(user, target))
		return "tied"
	if(act_cycles <= NPC_ACT_OPENING_CYCLES)
		return "opening"
	if(get_act_progress(user) >= NPC_ACT_LATE_PROGRESS || get_act_progress(target) >= NPC_ACT_LATE_PROGRESS)
		return "late"
	return "middle"

// ---- Beats ----

/// Start lines as list("room", "me", "hear"), or null.
/datum/sex_action/npc/proc/get_start_lines(mob/living/user, mob/living/target)
	text_lines = null
	return lines_from_room_hook(get_start_message(user, target))

/// Perform lines for a stage; variant picks the middle line, random when unset.
/datum/sex_action/npc/proc/get_perform_lines(mob/living/user, mob/living/target, stage, variant)
	text_lines = null
	text_stage = stage
	text_variant = variant || rand(1, 3)
	var/room = get_perform_message(user, target)
	text_stage = null
	text_variant = null
	return lines_from_room_hook(room)

/// Climax lines with the climaxer as subject; flipped means the victim climaxed.
/datum/sex_action/proc/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	return null

/// Finish lines as list("room", "me", "hear"), or null.
/datum/sex_action/npc/proc/get_finish_lines(mob/living/user, mob/living/target)
	text_lines = null
	return lines_from_room_hook(get_finish_message(user, target))

/// Room line hook for the start; subtypes may replace it with a line of their own.
/datum/sex_action/npc/proc/get_start_message(mob/living/user, mob/living/target)
	text_lines = compose_start_lines(user, target)
	return text_lines ? text_lines["room"] : null

/// Room line hook for a perform cycle.
/datum/sex_action/npc/proc/get_perform_message(mob/living/user, mob/living/target)
	text_lines = compose_perform_lines(user, target, text_stage || get_act_stage(user, target), text_variant || rand(1, 3))
	return text_lines ? text_lines["room"] : null

/// Room line hook for the finish.
/datum/sex_action/npc/proc/get_finish_message(mob/living/user, mob/living/target)
	text_lines = compose_finish_lines(user, target)
	return text_lines ? text_lines["room"] : null

/// The act's own start lines.
/datum/sex_action/proc/compose_start_lines(mob/living/user, mob/living/target)
	return null

/// The act's own perform lines for a stage and middle variant.
/datum/sex_action/proc/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	return null

/// The act's own finish lines.
/datum/sex_action/proc/compose_finish_lines(mob/living/user, mob/living/target)
	return null

/// Pairs the room line with the composed me and hear lines; a replaced hook keeps its room line alone.
/datum/sex_action/npc/proc/lines_from_room_hook(room)
	var/list/lines = text_lines
	text_lines = null
	if(!room)
		return null
	if(!lines)
		return list("room" = room)
	lines["room"] = room
	return lines

/// Builds one beat's lines.
/datum/sex_action/proc/act_lines(room, me, hear)
	return list("room" = room, "me" = me, "hear" = hear)

/// Tied lines for a penetration: the hunter's knot locked in the victim's hole.
/datum/sex_action/npc/proc/tied_penetration_lines(mob/living/user, mob/living/target, list/words, hole, hear)
	var/list/tied = words["tied"]
	return act_lines(
		"[user] [tied["room"]] [target]'s [hole], [target] locked on it.",
		"[user] [tied["me"]], my [hole] locked tight around it.",
		hear
	)

/// Tied lines for a ride: the hunter sits locked on the victim's knot.
/datum/sex_action/npc/proc/tied_ride_lines(mob/living/user, mob/living/target, hear)
	return act_lines("[user] sits locked on [target]'s knot, rocking.", "[user] sits locked on my knot, rocking.", hear)

// ---- State tails ----

/// Every state tail that fits the scene right now, each list("id", "room", "me").
/datum/sex_action/npc/proc/get_state_tails(mob/living/user, mob/living/target)
	var/list/tails = list()
	var/list/words = get_act_words(user, target)
	var/hunter_them = words["them"]
	var/penetrates = get_scene_interaction() == SEX_SCENE_INTERACTION_PENETRATION
	var/datum/orifice/orifice = penetrates ? get_penetrated_orifice(user, target, FALSE) : null
	// Hole tails describe the victim's hole, so a riding hunter's own hole gives none.
	if(orifice && get_orifice_receiver(user, target) == target)
		var/opening = orifice.opening_name
		switch(orifice.get_stretch_id())
			if("tight")
				tails += list(list("id" = "tight", "room" = ", still tight around it", "me" = ", my [opening] still tight around it"))
			if("loosened", "wide")
				tails += list(list("id" = "wide", "room" = ", [target]'s [opening] stretched wide around it", "me" = ", my [opening] stretched wide around it"))
		if(orifice.get_lube_id() == "slick")
			tails += list(list("id" = "slick", "room" = ", each thrust slapping wet", "me" = ", each thrust slapping wet inside me"))
		var/soreness = orifice.get_soreness_id()
		if(soreness == "sore" || soreness == "raw")
			tails += list(list("id" = "sore", "room" = ", [target]'s [opening] raw from it", "me" = ", my [opening] raw from it"))
	if(target.handcuffed)
		tails += list(list("id" = "bound", "room" = ", [target]'s bound hands useless", "me" = ", my bound hands useless"))
	if(target.buckled)
		tails += list(list("id" = "buckled", "room" = ", [target] strapped down under [hunter_them]", "me" = ", with me strapped down under [hunter_them]"))
	if(target.pulledby == user && user.grab_state >= GRAB_AGGRESSIVE)
		var/list/body_tails = words["body_tails"]
		if(length(body_tails))
			tails += body_tails
	if(penetrates && !considered_limp(target))
		tails += list(list("id" = "rising", "room" = ", [target]'s hips rising to meet it", "me" = ", my hips rising to meet it"))
	if(get_act_progress(target) >= NPC_ACT_LATE_PROGRESS)
		tails += list(list("id" = "shaking", "room" = ", [target] shaking under [hunter_them]", "me" = ", my whole body shaking under [hunter_them]"))
	return tails

/// One state tail on about one line in three, never the last one again; chance is a percent.
/datum/sex_action/npc/proc/pick_state_tail(mob/living/user, mob/living/target, chance = NPC_ACT_TAIL_CHANCE)
	if(QDELETED(user) || QDELETED(target) || !prob(chance))
		return null
	var/list/tails = list()
	for(var/list/tail as anything in get_state_tails(user, target))
		if(tail["id"] != last_tail)
			tails += list(tail)
	if(!length(tails))
		return null
	var/list/picked = pick(tails)
	last_tail = picked["id"]
	return picked

// ---- Printing ----

/// Wraps a line in the beat's colour: "warning", "force" or "love".
/datum/sex_action/proc/colour_act_line(line, colour)
	switch(colour)
		if("force")
			return spanify_force(line)
		if("love")
			return span_love(line)
	return span_warning(line)

/// Prints a beat from the victim: room line to onlookers, me line to the victim, hear line to the blind.
/datum/sex_action/proc/show_act_lines(list/lines, mob/living/user, mob/living/target, colour = "warning")
	if(!lines || !lines["room"])
		return
	var/room = colour_act_line(lines["room"], colour)
	// A subtype's own room line goes to everyone, as it always did.
	if(!lines["me"] || QDELETED(target))
		user.visible_message(room)
		return
	var/hear = lines["hear"]
	target.visible_message(room, colour_act_line(lines["me"], colour), hear ? span_hear(hear) : null)

/// This cycle's perform line, with its stage and now and then a state tail.
/datum/sex_action/npc/proc/show_perform_lines(mob/living/user, mob/living/target)
	var/stage = get_act_stage(user, target)
	var/list/lines = get_perform_lines(user, target, stage)
	// A tied line already says what holds the pair together.
	if(lines && lines["me"] && stage != "tied")
		var/list/tail = pick_state_tail(user, target)
		if(tail)
			lines["room"] = insert_before_end_punctuation(lines["room"], tail["room"])
			lines["me"] = insert_before_end_punctuation(lines["me"], tail["me"])
	show_act_lines(lines, user, target, "force")

/// Climax lines from the victim's side; the hunter is the partner when flipped.
/datum/sex_action/proc/show_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	var/mob/living/hunter = flipped ? partner : climaxer
	var/mob/living/victim = flipped ? climaxer : partner
	show_act_lines(get_climax_lines(climaxer, partner, flipped), hunter, victim, "love")

#undef NPC_ACT_OPENING_CYCLES
#undef NPC_ACT_LATE_PROGRESS
#undef NPC_ACT_TAIL_CHANCE
