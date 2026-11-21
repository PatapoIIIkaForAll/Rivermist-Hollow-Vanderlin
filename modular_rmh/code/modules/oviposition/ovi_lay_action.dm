// Laying eggs as an act: the ovipositor seats itself, then an egg comes every few cycles up to a cap.

#define LAY_EGG_DO_TIME (6 SECONDS)
#define LAY_EGG_STAMINA 0.6
/// The layer's pleasure per egg: with the wait trickle, a capped act climaxes around its last egg.
#define LAY_EGG_LAYER_AROUSAL 3.5
#define LAY_EGG_LAYER_CLIMAX 7
/// The layer's pleasure on a cycle between eggs.
#define LAY_EGG_WAIT_AROUSAL 1
#define LAY_EGG_WAIT_CLIMAX 1
/// The host's pleasure per egg at full share; the fit decides the share.
#define LAY_EGG_HOST_AROUSAL 6
#define LAY_EGG_HOST_CLIMAX 4
/// The first cycle's swell, before any egg comes.
#define LAY_EGG_SWELL_AROUSAL 1
#define LAY_EGG_SWELL_CLIMAX 1
#define LAY_FEELS_GOOD(share) ((share) >= 0.66)
#define LAY_FEELS_MIXED(share) ((share) > 0.33 && (share) < 0.66)

/// The working ovipositor component on [user], or null.
/proc/get_working_ovipositor(mob/living/user)
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = user?.getorganslot(ORGAN_SLOT_PENIS)
	if(!istype(ovipositor))
		return null
	return ovipositor.GetComponent(/datum/component/ovipositor)

/// TRUE when [user] has a working ovipositor with an egg stored.
/proc/has_egg_to_lay(mob/living/user)
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(user)
	return ovipositor && ovipositor.eggs_stored > 0

/// The ripe womb egg [user] could bear down on now, or null.
/proc/get_ripe_womb_egg(mob/living/user)
	var/obj/item/organ/genitals/filling_organ/womb/womb = user?.get_womb()
	if(!womb)
		return null
	for(var/obj/item/oviposition_egg/egg as anything in womb.get_oviposition_eggs(TRUE))
		var/datum/component/pregnancy/pregnancy = egg.get_pregnancy_component()
		if(pregnancy && !egg.hatch_inside_host && pregnancy.stage >= pregnancy.max_stage)
			return egg
	return null

// ---- The shared beat ----

/datum/sex_action
	/// Eggs this act has laid, and whether its first swell has shown.
	var/eggs_laid_this_act = 0
	var/lay_egg_swelled = FALSE
	/// Cycles since the swell or the last egg, and wait lines shown this act.
	var/lay_wait_cycles = 0
	var/lay_wait_lines = 0
	/// The act laid its last egg for now; later cycles only wait for it to end.
	var/lay_egg_spent = FALSE

/// The organ eggs go into for this act's hole on [target].
/datum/sex_action/proc/get_lay_receiver(mob/living/user, mob/living/target)
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(user)
	return ovipositor?.get_receiver_for_hole(target, hole_id)

/// The layer's part by name.
/datum/sex_action/proc/get_lay_part(mob/living/user)
	var/obj/item/organ/genitals/penis/penis = user?.getorganslot(ORGAN_SLOT_PENIS)
	return penis?.name || "ovipositor"

/// The word for what the layer lays.
/datum/sex_action/proc/get_lay_egg_word(mob/living/user)
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(user)
	return ovipositor?.get_egg_kind_is_seed() ? "seed" : "egg"

/// One of what the layer lays, with its article: "an egg" or "a seed".
/datum/sex_action/proc/get_lay_egg_phrase(mob/living/user)
	var/word = get_lay_egg_word(user)
	return word == "egg" ? "an egg" : "a [word]"

/// How the last egg felt to the host, as a tail for the host's line.
/datum/sex_action/proc/get_lay_feel_tail(share)
	if(LAY_FEELS_GOOD(share))
		return ", and it feels good"
	if(LAY_FEELS_MIXED(share))
		return ", and it aches but feels good"
	if(share > 0)
		return ", and it burns"
	return ""

/// One lay beat into [target]: the swell, then an egg every few cycles. FALSE once the act must stop.
/datum/sex_action/proc/run_lay_egg_beat(mob/living/user, mob/living/target)
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(user)
	if(!ovipositor)
		stop_runtime()
		return FALSE
	// Spent: the finale's spurts still run, then the act stops.
	if(lay_egg_spent)
		return FALSE
	if(!lay_egg_swelled)
		lay_egg_swelled = TRUE
		show_lay_lines(user, target, "swell", 0)
		perform_sex_action(user, target, LAY_EGG_SWELL_AROUSAL, 0, LAY_EGG_SWELL_CLIMAX)
		return TRUE
	lay_wait_cycles++
	if(lay_wait_cycles < LAY_EGG_CYCLES_PER_EGG)
		run_lay_wait_beat(user, target)
		return TRUE
	lay_wait_cycles = 0
	var/obj/item/oviposition_egg/egg = ovipositor.lay_one_egg(get_lay_receiver(user, target), force >= SEX_FORCE_HIGH)
	if(!egg)
		if(ovipositor.last_lay_reason)
			to_chat(user, span_warning(ovipositor.last_lay_reason))
		if(eggs_laid_this_act)
			end_lay_act(user, target)
		else
			stop_runtime()
		return FALSE
	eggs_laid_this_act++
	var/share = ovipositor.last_lay_share
	show_lay_lines(user, target, "egg", share)
	perform_sex_action(user, target, LAY_EGG_LAYER_AROUSAL, 0, LAY_EGG_LAYER_CLIMAX)
	if(share > 0)
		perform_sex_action(target, user, LAY_EGG_HOST_AROUSAL * share, 0, LAY_EGG_HOST_CLIMAX * share)
	if(ovipositor.eggs_stored <= 0)
		show_lay_lines(user, target, "spent", 0)
		end_lay_act(user, target)
		return FALSE
	if(eggs_laid_this_act >= LAY_EGG_ACT_CAP)
		show_lay_lines(user, target, "capped", 0)
		end_lay_act(user, target)
		return FALSE
	return TRUE

/// The wait line due this cycle: "settle" right after an egg, "twitch" mid-wait, else null.
/datum/sex_action/proc/get_lay_wait_beat()
	if(lay_wait_cycles == 1 && eggs_laid_this_act)
		return "settle"
	if(lay_wait_cycles == round(LAY_EGG_CYCLES_PER_EGG / 2))
		return "twitch"
	return null

/// A cycle between eggs: a small trickle for the layer and now and then a line for the host.
/datum/sex_action/proc/run_lay_wait_beat(mob/living/user, mob/living/target)
	var/beat = get_lay_wait_beat()
	if(beat)
		lay_wait_lines++
		show_lay_lines(user, target, beat, 0)
	perform_sex_action(user, target, LAY_EGG_WAIT_AROUSAL, 0, LAY_EGG_WAIT_CLIMAX)

/// Ends a lay act that laid its last egg for now; an AI layer climaxes as the finale.
/datum/sex_action/proc/end_lay_act(mob/living/user, mob/living/target)
	lay_egg_spent = TRUE
	if(climaxes_at_lay_end() && !just_climaxed && !stop_after_spurts)
		var/datum/component/arousal/arousal = user.GetComponent(/datum/component/arousal)
		if(arousal?.can_climax())
			arousal.ejaculate(src, user, target, TRUE, user)
	// A climax that stops the act ends it after its spurts; anything else ends it now.
	if(!just_climaxed && !stop_after_spurts)
		stop_runtime()

/// TRUE when the layer climaxes once the act is spent, so an AI hunt ends sated.
/datum/sex_action/proc/climaxes_at_lay_end()
	return FALSE

/// One beat of laying onto the floor. FALSE once the act must stop.
/datum/sex_action/proc/run_lay_floor_beat(mob/living/user)
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(user)
	if(!ovipositor)
		stop_runtime()
		return FALSE
	var/part = get_lay_part(user)
	var/word = get_lay_egg_word(user)
	var/one = get_lay_egg_phrase(user)
	if(!lay_egg_swelled)
		lay_egg_swelled = TRUE
		user.visible_message(span_warning("[user]'s [part] swells at the base."), span_love("[capitalize(one)] starts down my [part]."))
		perform_sex_action(user, user, LAY_EGG_SWELL_AROUSAL, 0, LAY_EGG_SWELL_CLIMAX)
		return TRUE
	var/obj/item/oviposition_egg/egg = ovipositor.lay_one_egg_on_floor()
	if(!egg)
		if(ovipositor.last_lay_reason)
			to_chat(user, span_warning(ovipositor.last_lay_reason))
		stop_runtime()
		return FALSE
	eggs_laid_this_act++
	user.visible_message(span_love("[user] lays [one] on the ground."), span_love("[capitalize(one)] slides out of me onto the ground. [eggs_laid_this_act]."))
	playsound(user, 'sound/effects/wounds/splatter.ogg', 30, TRUE)
	perform_sex_action(user, user, LAY_EGG_LAYER_AROUSAL, 0, LAY_EGG_LAYER_CLIMAX)
	if(ovipositor.eggs_stored <= 0)
		user.visible_message(span_warning("[user]'s [part] goes slack."), span_love_flash("That was the last [word]."))
		stop_runtime()
		return FALSE
	return TRUE

/// Words for a beat of laying into [target]: "seat", "swell", "settle", "twitch", "egg", "spent", "capped", "withdraw".
/datum/sex_action/proc/show_lay_lines(mob/living/user, mob/living/target, beat, share)
	var/part = get_lay_part(user)
	var/word = get_lay_egg_word(user)
	var/one = get_lay_egg_phrase(user)
	var/hole = get_lay_hole_word(user, target)
	switch(beat)
		if("settle")
			to_chat(target, span_love("The [word] settles deep in my [get_lay_rest_word(hole)]."))
		if("twitch")
			to_chat(target, span_love("Something twitches inside me."))
		if("capped")
			user.visible_message(span_warning("[user]'s [part] stills in [target]'s [hole]."), span_love("My [part] is spent for now."))
			to_chat(target, span_love("[user]'s [part] stills in my [hole]."))
		if("seat")
			user.visible_message(span_warning("[user] pushes [user.p_their()] [part] into [target]'s [hole]."), span_love("I push my [part] into [target]'s [hole]."))
			to_chat(target, span_love("[user]'s [part] pushes into my [hole]."))
		if("swell")
			user.visible_message(span_warning("[user]'s [part] swells inside [target]'s [hole]."), span_love("[capitalize(one)] starts down my [part]."))
			to_chat(target, span_love("[user]'s [part] swells inside my [hole]."))
		if("egg")
			user.visible_message(span_love("[user] pushes [one] into [target]'s [hole]."), span_love("I push [one] into [target]'s [hole]. [eggs_laid_this_act]."))
			if(LAY_FEELS_GOOD(share))
				to_chat(target, span_love("[capitalize(one)] pushes into my [hole][get_lay_feel_tail(share)]."))
			else
				to_chat(target, span_love("[capitalize(one)] forces my [hole] open[get_lay_feel_tail(share)]."))
		if("spent")
			user.visible_message(span_warning("[user]'s [part] goes slack in [target]'s [hole]."), span_love_flash("That was the last [word]."))
			to_chat(target, span_love("[user]'s [part] goes slack in my [hole]."))
		if("withdraw")
			user.visible_message(span_warning("[user] pulls [user.p_their()] [part] out of [target]'s [hole]."))

/// The hole word for the lay lines.
/datum/sex_action/proc/get_lay_hole_word(mob/living/user, mob/living/target)
	var/datum/orifice/orifice = get_penetrated_orifice(user, target, FALSE)
	if(orifice?.opening_name)
		return orifice.opening_name
	switch(hole_id)
		if(ORGAN_SLOT_VAGINA)
			return "pussy"
		if(ORGAN_SLOT_ANUS)
			return "ass"
	return "throat"

/// Where a laid egg rests, for the settle line: the throat's eggs go down to the belly.
/datum/sex_action/proc/get_lay_rest_word(hole)
	return hole_id == BODY_ZONE_PRECISE_MOUTH ? "belly" : hole

// ---- The panel acts ----

/datum/sex_action/sex/lay_eggs
	abstract_type = /datum/sex_action/sex/lay_eggs
	name = "Lay eggs"
	description = "Seat your ovipositor and lay up to three eggs into them, one every few thrusts."
	do_time = LAY_EGG_DO_TIME
	stamina_cost = LAY_EGG_STAMINA
	knot_on_finish = FALSE
	can_knot = FALSE

/datum/sex_action/sex/lay_eggs/proc/target_has_hole(mob/living/target)
	return TRUE

/datum/sex_action/sex/lay_eggs/proc/get_target_zone()
	return BODY_ZONE_PRECISE_GROIN

/datum/sex_action/sex/lay_eggs/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && has_egg_to_lay(user) && target_has_hole(target)

/datum/sex_action/sex/lay_eggs/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target || !has_egg_to_lay(user) || !target_has_hole(target))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, get_target_zone(), TRUE))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(user)
	if(ovipositor.get_lay_block_reason(get_lay_receiver(user, target)))
		return FALSE
	return TRUE

/datum/sex_action/sex/lay_eggs/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	eggs_laid_this_act = 0
	lay_egg_swelled = FALSE
	lay_wait_cycles = 0
	lay_wait_lines = 0
	lay_egg_spent = FALSE
	// Still pressing at the opening: nothing went in yet.
	if(orifice_pressing)
		return .
	show_lay_lines(user, target, "seat", 0)
	playsound(target, list('sound/misc/mat/insert (1).ogg', 'sound/misc/mat/insert (2).ogg'), sex_volume, TRUE, ignore_walls = FALSE)

/datum/sex_action/sex/lay_eggs/on_perform(mob/living/user, mob/living/target)
	. = ..()
	do_thrust_animate(user, target, 2, 4)
	run_lay_egg_beat(user, target)

/datum/sex_action/sex/lay_eggs/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	if(must_flip)
		user.visible_message(span_love("[user]'s [get_lay_hole_word(target, user)] clenches around [target]'s [get_lay_part(target)]!"))
		return ORGASM_LOCATION_ONTO
	// The clutch itself rushes on the climax signal, right after this.
	user.visible_message(span_love("[user] goes rigid and pumps [user.p_their()] [get_lay_egg_word(user)]s into [target]'s [get_lay_hole_word(user, target)]!"))
	return ORGASM_LOCATION_INTO

/datum/sex_action/sex/lay_eggs/on_finish(mob/living/user, mob/living/target)
	var/was_pressing = orifice_pressing
	. = ..()
	if(was_pressing)
		user.visible_message(span_warning("[user] gives up pressing [user.p_their()] [get_lay_part(user)] against [target]."))
		return
	show_lay_lines(user, target, "withdraw", 0)

/datum/sex_action/sex/lay_eggs/vaginal
	name = "Lay in pussy"
	hole_id = ORGAN_SLOT_VAGINA

/datum/sex_action/sex/lay_eggs/vaginal/target_has_hole(mob/living/target)
	return !!target.getorganslot(ORGAN_SLOT_VAGINA)

/datum/sex_action/sex/lay_eggs/anal
	name = "Lay in ass"
	hole_id = ORGAN_SLOT_ANUS

/datum/sex_action/sex/lay_eggs/anal/target_has_hole(mob/living/target)
	return !!target.getorganslot(ORGAN_SLOT_ANUS)

/datum/sex_action/sex/lay_eggs/throat
	name = "Lay in throat"
	hole_id = BODY_ZONE_PRECISE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_target = TRUE
	requires_hole_storage = FALSE

/datum/sex_action/sex/lay_eggs/throat/get_target_zone()
	return BODY_ZONE_PRECISE_MOUTH

/datum/sex_action/sex/lay_eggs/throat/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(.)
		play_throat_entry(target, sex_volume)

/datum/sex_action/sex/lay_eggs/throat/on_perform(mob/living/user, mob/living/target)
	. = ..()
	play_throat_thrust(target, 40)

// ---- On the floor ----

/datum/sex_action/lay_eggs_floor
	name = "Lay on ground"
	description = "Squat and lay your clutch on the ground, one egg at a time."
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	do_time = LAY_EGG_DO_TIME
	stamina_cost = LAY_EGG_STAMINA
	uses_user_organs = list(ORGAN_SLOT_PENIS)

/datum/sex_action/lay_eggs_floor/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && has_egg_to_lay(user)

/datum/sex_action/lay_eggs_floor/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || !has_egg_to_lay(user))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/lay_eggs_floor/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_PENIS)

/datum/sex_action/lay_eggs_floor/on_start(mob/living/user, mob/living/target)
	. = ..()
	eggs_laid_this_act = 0
	lay_egg_swelled = FALSE
	var/part = get_lay_part(user)
	user.visible_message(span_warning("[user] squats low, [user.p_their()] [part] pressed to the ground."), span_love("I squat and let my [part] find the ground."))

/datum/sex_action/lay_eggs_floor/on_perform(mob/living/user, mob/living/target)
	. = ..()
	run_lay_floor_beat(user)

/datum/sex_action/lay_eggs_floor/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] straightens up."))

// ---- Bearing down on a ripe womb egg ----

/datum/sex_action/lay_womb_eggs
	name = "Birth egg"
	description = "Bear down and bring a ripe egg out of your womb."
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	continous = FALSE
	do_time = 3 SECONDS
	uses_user_organs = list(ORGAN_SLOT_VAGINA)

/datum/sex_action/lay_womb_eggs/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && iscarbon(user) && !!get_ripe_womb_egg(user)

/datum/sex_action/lay_womb_eggs/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || !iscarbon(user) || !get_ripe_womb_egg(user))
		return FALSE
	if(user.has_status_effect(/datum/status_effect/labour))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/lay_womb_eggs/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/carrier = user
	var/obj/item/oviposition_egg/egg = get_ripe_womb_egg(carrier)
	if(!egg)
		return
	// Bearing down on purpose starts the same labour the roll would.
	carrier.start_labour(egg, carrier.get_womb(), TRUE)

// ---- The AI's acts ----

/// The hunt cannot tick through an act's do_after, so the act itself ends when the hunter is ready to lay.
/datum/sex_action/npc/is_finished(mob/living/user, mob/living/target)
	. = ..()
	if(!. && !is_lay_egg_act(src) && horny_should_pull_out_to_lay(user, target))
		return TRUE

/// Shared pieces of the NPC lay acts; the vaginal, anal and throat types inherit their fuck's gates and warmup.
/datum/sex_action/npc/proc/lay_can_perform(mob/living/user, mob/living/target)
	if(!has_egg_to_lay(user))
		return FALSE
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(user)
	var/obj/item/organ/receiver = get_lay_receiver(user, target)
	if(ovipositor.get_lay_block_reason(receiver))
		return FALSE
	// A full hole refuses the act, so the hunt picks an ordinary one instead.
	return ovipositor.has_room_for_egg(receiver, force >= SEX_FORCE_HIGH)

/datum/sex_action/npc/proc/lay_start_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	var/hole = get_act_hole(user, target)
	var/part = get_lay_part(user)
	var/into = get_lay_direction()
	return act_lines(
		"[user] [words["mount"]] its [part] [into] [target]'s [hole]!",
		"[user] [words["mount"]] its [part] [into] my [hole]!",
		"I hear [words["hear"]]."
	)

/// "down" for the throat, "into" for a hole below.
/datum/sex_action/npc/proc/get_lay_direction()
	return hole_id == BODY_ZONE_PRECISE_MOUTH ? "down" : "into"

/datum/sex_action/npc/proc/lay_finish_lines(mob/living/user, mob/living/target)
	var/hole = get_act_hole(user, target)
	var/part = get_lay_part(user)
	return act_lines("[user] pulls its [part] out of [target]'s [hole].", "[user] pulls its [part] out of my [hole].", "I hear a wet pop.")

/datum/sex_action/npc/proc/lay_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		var/part = get_lay_part(partner)
		var/victim_hole = get_act_hole(partner, climaxer)
		return act_lines("[climaxer]'s [victim_hole] clenches around [partner]'s [part]!", "I shake as my [victim_hole] clenches around [partner]'s [part]!", "I hear a shaky moan.")
	var/hole = get_act_hole(climaxer, partner)
	var/into = get_lay_direction()
	// The finale of an emptied store has nothing left to pump.
	if(!has_egg_to_lay(climaxer))
		return act_lines("[climaxer] goes rigid deep in [partner]'s [hole]!", "[climaxer] goes rigid deep in my [hole]!", "I hear a wet pulse.")
	var/word = get_lay_egg_word(climaxer)
	return act_lines("[climaxer] goes rigid and pumps its [word]s [into] [partner]'s [hole]!", "[climaxer] goes rigid and pumps its [word]s [into] my [hole]!", "I hear a wet pulse.")

/// The AI's lay act climaxes when spent, so the hunt ends sated with the rush as the finale.
/datum/sex_action/npc/climaxes_at_lay_end()
	return TRUE

/// The NPC beat: an egg every few cycles, and each egg feeds the hunter's lust.
/datum/sex_action/npc/proc/run_npc_lay_beat(mob/living/user, mob/living/target)
	act_cycles++
	var/before = eggs_laid_this_act
	. = run_lay_egg_beat(user, target)
	if(eggs_laid_this_act > before)
		user.ai_controller?.add_horny_lust(HORNY_LUST_PER_CLENCH)

/// The NPC's lines for a lay beat: "swell", "settle", "twitch", "egg", "spent" or "capped"; null for any other.
/datum/sex_action/npc/proc/get_npc_lay_lines(mob/living/user, mob/living/target, beat, share)
	var/part = get_lay_part(user)
	var/hole = get_act_hole(user, target)
	switch(beat)
		if("swell")
			return act_lines("[user]'s [part] swells inside [target]'s [hole].", "[user]'s [part] swells inside my [hole].", "I hear a wet shift.")
		if("settle")
			return act_lines("[user] holds still in [target]'s [hole].", "The [get_lay_egg_word(user)] settles deep in my [get_lay_rest_word(hole)].", null)
		if("twitch")
			return act_lines("[user]'s [part] throbs in [target]'s [hole].", "Something twitches inside me.", null)
		if("capped")
			return act_lines("[user]'s [part] stills in [target]'s [hole].", "[user]'s [part] stills in my [hole].", "I hear a wet shift.")
		if("egg")
			var/one = get_lay_egg_phrase(user)
			var/into = get_lay_direction()
			return act_lines("[user] pushes [one] [into] [target]'s [hole].", "[capitalize(one)] pushes [into] my [hole][get_lay_feel_tail(share)].", "I hear a wet pulse.")
		if("spent")
			return act_lines("[user]'s [part] goes slack in [target]'s [hole].", "[user]'s [part] goes slack in my [hole].", "I hear a wet shift.")
	return null

/datum/sex_action/npc/proc/show_npc_lay_lines(mob/living/user, mob/living/target, beat, share)
	show_act_lines(get_npc_lay_lines(user, target, beat, share), user, target, "love")

/datum/sex_action/npc/npc_vaginal_sex/lay_eggs
	name = "Lay eggs"
	do_time = LAY_EGG_DO_TIME
	stamina_cost = LAY_EGG_STAMINA
	knot_on_finish = FALSE
	can_knot = FALSE

/datum/sex_action/npc/npc_vaginal_sex/lay_eggs/can_perform(mob/living/user, mob/living/target)
	return ..() && lay_can_perform(user, target)

/datum/sex_action/npc/npc_vaginal_sex/lay_eggs/compose_start_lines(mob/living/user, mob/living/target)
	return lay_start_lines(user, target)

/datum/sex_action/npc/npc_vaginal_sex/lay_eggs/compose_finish_lines(mob/living/user, mob/living/target)
	return lay_finish_lines(user, target)

/datum/sex_action/npc/npc_vaginal_sex/lay_eggs/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	return lay_climax_lines(climaxer, partner, flipped)

/datum/sex_action/npc/npc_vaginal_sex/lay_eggs/show_lay_lines(mob/living/user, mob/living/target, beat, share)
	show_npc_lay_lines(user, target, beat, share)

/datum/sex_action/npc/npc_vaginal_sex/lay_eggs/on_perform(mob/living/user, mob/living/target)
	if(run_orifice_warmup_cycle(user, target))
		return
	do_thrust_animate(user, target, 2, 4)
	run_npc_lay_beat(user, target)

/datum/sex_action/npc/npc_anal_sex/lay_eggs
	name = "Lay eggs"
	do_time = LAY_EGG_DO_TIME
	stamina_cost = LAY_EGG_STAMINA
	knot_on_finish = FALSE
	can_knot = FALSE

/datum/sex_action/npc/npc_anal_sex/lay_eggs/can_perform(mob/living/user, mob/living/target)
	return ..() && lay_can_perform(user, target)

/datum/sex_action/npc/npc_anal_sex/lay_eggs/compose_start_lines(mob/living/user, mob/living/target)
	return lay_start_lines(user, target)

/datum/sex_action/npc/npc_anal_sex/lay_eggs/compose_finish_lines(mob/living/user, mob/living/target)
	return lay_finish_lines(user, target)

/datum/sex_action/npc/npc_anal_sex/lay_eggs/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	return lay_climax_lines(climaxer, partner, flipped)

/datum/sex_action/npc/npc_anal_sex/lay_eggs/show_lay_lines(mob/living/user, mob/living/target, beat, share)
	show_npc_lay_lines(user, target, beat, share)

/datum/sex_action/npc/npc_anal_sex/lay_eggs/on_perform(mob/living/user, mob/living/target)
	if(run_orifice_warmup_cycle(user, target))
		return
	do_thrust_animate(user, target, 2, 4)
	run_npc_lay_beat(user, target)

/datum/sex_action/npc/npc_throat_sex/lay_eggs
	name = "Lay eggs"
	do_time = LAY_EGG_DO_TIME
	stamina_cost = LAY_EGG_STAMINA

/datum/sex_action/npc/npc_throat_sex/lay_eggs/can_perform(mob/living/user, mob/living/target)
	return ..() && lay_can_perform(user, target)

/datum/sex_action/npc/npc_throat_sex/lay_eggs/compose_start_lines(mob/living/user, mob/living/target)
	return lay_start_lines(user, target)

/datum/sex_action/npc/npc_throat_sex/lay_eggs/compose_finish_lines(mob/living/user, mob/living/target)
	return lay_finish_lines(user, target)

/datum/sex_action/npc/npc_throat_sex/lay_eggs/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	return lay_climax_lines(climaxer, partner, flipped)

/datum/sex_action/npc/npc_throat_sex/lay_eggs/show_lay_lines(mob/living/user, mob/living/target, beat, share)
	show_npc_lay_lines(user, target, beat, share)

/datum/sex_action/npc/npc_throat_sex/lay_eggs/on_perform(mob/living/user, mob/living/target)
	play_throat_thrust(target, 40)
	do_thrust_animate(user, target, 2, 4)
	run_npc_lay_beat(user, target)

#undef LAY_EGG_DO_TIME
#undef LAY_EGG_STAMINA
#undef LAY_EGG_LAYER_AROUSAL
#undef LAY_EGG_LAYER_CLIMAX
#undef LAY_EGG_WAIT_AROUSAL
#undef LAY_EGG_WAIT_CLIMAX
#undef LAY_EGG_HOST_AROUSAL
#undef LAY_EGG_HOST_CLIMAX
#undef LAY_EGG_SWELL_AROUSAL
#undef LAY_EGG_SWELL_CLIMAX
#undef LAY_FEELS_GOOD
#undef LAY_FEELS_MIXED
