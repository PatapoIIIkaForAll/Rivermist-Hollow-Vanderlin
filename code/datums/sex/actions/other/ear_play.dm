// Ear play: rubbing, licking and nibbling a partner's ears.
// Sensitive ears (pointed or animal ears, or the Sensitive Ears quirk) take far more from it and may flick.

/datum/sex_action/ear_play
	abstract_type = /datum/sex_action/ear_play
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	check_same_tile = FALSE
	/// Arousal per cycle on ordinary ears.
	var/arousal_amt = 1
	/// Arousal per cycle on sensitive ears.
	var/sensitive_arousal_amt = 3.5
	/// Orgasm progress per cycle on sensitive ears. Ordinary ears give none.
	var/sensitive_orgasm_amt = 1
	/// Pain per cycle before force scaling.
	var/pain_amt = 0
	/// Per-cycle verb, as in "[user] gently licks [target]'s ear".
	var/act_verb
	/// "ear" or "ears", whichever the act touches.
	var/ear_word = "ear"
	/// Earliest world.time the target's ears may flick again from this action.
	var/next_flick_time = 0

/datum/sex_action/ear_play/shows_on_menu(mob/living/user, mob/living/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/ear_play/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_EARS, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/ear_play/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/sensitive = target.has_sensitive_ears()
	if(can_show_action_message(user, target))
		var/tail = sensitive ? "... [target.p_their()] weakness..." : "..."
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] [act_verb] [target]'s [ear_word][tail]"))
	play_ear_sound(user, target)

	if(sensitive)
		perform_sex_action(target, user, sensitive_arousal_amt, pain_amt, sensitive_orgasm_amt)
		if(world.time >= next_flick_time && prob(25))
			next_flick_time = world.time + 5 SECONDS
			target.try_ear_flick()
	else
		perform_sex_action(target, user, arousal_amt, pain_amt, 0)
	handle_passive_ejaculation(target)

/datum/sex_action/ear_play/proc/play_ear_sound(mob/living/user, mob/living/target)
	return

// --- Mouth on the ear ---
/datum/sex_action/ear_play/mouth
	abstract_type = /datum/sex_action/ear_play/mouth
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH

/datum/sex_action/ear_play/mouth/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	return TRUE

/datum/sex_action/ear_play/mouth/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/ear_play/mouth/lick
	name = "Lick ears"
	remote_phrase = "Lick their ears"
	act_verb = "licks"

/datum/sex_action/ear_play/mouth/lick/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] presses [user.p_their()] tongue against [target]'s ear..."))

/datum/sex_action/ear_play/mouth/lick/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops licking [target]'s ear."))

/datum/sex_action/ear_play/mouth/lick/play_ear_sound(mob/living/user, mob/living/target)
	user.make_mouth_noise("lick")

/// Teeth instead of tongue: a little less arousal, and a sting that grows with force.
/datum/sex_action/ear_play/mouth/nibble
	name = "Nibble ears"
	remote_phrase = "Nibble their ears"
	act_verb = "nibbles"
	sensitive_arousal_amt = 3
	pain_amt = 1

/datum/sex_action/ear_play/mouth/nibble/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] catches [target]'s ear between [user.p_their()] teeth..."))

/datum/sex_action/ear_play/mouth/nibble/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets go of [target]'s ear."))

/datum/sex_action/ear_play/mouth/nibble/play_ear_sound(mob/living/user, mob/living/target)
	user.make_mouth_noise("kiss")

// --- Hands on the ears ---
/datum/sex_action/ear_play/rub
	name = "Rub ears"
	remote_phrase = "Rub their ears"
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	requires_free_hands = TRUE
	act_verb = "rubs"
	ear_word = "ears"
	arousal_amt = 0.5
	sensitive_arousal_amt = 2.5
	sensitive_orgasm_amt = 0.5

/datum/sex_action/ear_play/rub/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!find_available_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/ear_play/rub/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] places [user.p_their()] hands on [target]'s ears..."))

/datum/sex_action/ear_play/rub/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops rubbing [target]'s ears."))

/datum/sex_action/ear_play/rub/lock_sex_object(mob/living/user, mob/living/target)
	var/locked = get_hand_lock_slot(user)
	if(locked)
		add_sex_lock(user, locked)

/datum/sex_action/ear_play/rub/play_ear_sound(mob/living/user, mob/living/target)
	play_rub_sound("skin", target, 25)
