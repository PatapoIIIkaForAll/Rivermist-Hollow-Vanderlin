#define BREAST_ANIM_ON_USER "user"
#define BREAST_ANIM_ON_TARGET "target"

#define BREAST_ANIM_THRUST "thrust"
#define BREAST_ANIM_BOOBJOB "boobjob"
#define BREAST_ANIM_TOUCH "touch"
#define BREAST_ANIM_SLAP "slap"
#define BREAST_ANIM_SQUEEZE "squeeze"
#define BREAST_ANIM_HEFT "heft"
#define BREAST_ANIM_PAIZURI "paizuri"
#define BREAST_ANIM_RUN "run"
#define BREAST_ANIM_JOLT "jolt"
#define BREAST_ANIM_LOOP "loop"

/datum/sex_action
	/// Whose breasts play a shot each cycle: BREAST_ANIM_ON_USER, BREAST_ANIM_ON_TARGET, or null for none.
	var/breast_anim_on
	/// BREAST_ANIM_* kind picking the shot.
	var/breast_anim_kind
	/// Both participants' breasts play the shot (breast to breast).
	var/breast_anim_both = FALSE
	/// Slaps alternate the two halves of the run cycle; flips once per cycle.
	var/breast_slap_phase = FALSE

/// Shot name for BREAST_ANIM_LOOP actions.
/datum/sex_action/proc/get_breast_loop_shot()
	return null

/// Shot for rough motion: pumps per cycle first, then force and speed pick bounce, half walk or walk.
/datum/sex_action/proc/get_intensity_breast_shot()
	switch(get_motion_pumps())
		if(2)
			return "pump2"
		if(3)
			return "pump3"
	if(force >= SEX_FORCE_HIGH && speed >= SEX_SPEED_HIGH)
		return "bounce"
	if(force <= SEX_FORCE_LOW && speed <= SEX_SPEED_LOW)
		return "walk_half"
	return "walk"

/// Once per cycle, after on_perform(): plays the action's breast shot on the receiver, and the partner if both.
/datum/sex_action/proc/play_perform_breast_anim()
	if(!breast_anim_on || !breast_anim_kind)
		return
	if(breast_anim_kind == BREAST_ANIM_SLAP)
		breast_slap_phase = !breast_slap_phase
	var/mob/living/carbon/human/receiver = breast_anim_on == BREAST_ANIM_ON_USER ? action_user : action_target
	// Breast interactions feed the Breast Enthusiast vice; penetration only shakes them.
	if(breast_anim_kind != BREAST_ANIM_THRUST)
		var/list/owners = list(receiver)
		if(breast_anim_both)
			owners |= receiver == action_user ? action_target : action_user
		notify_breast_interaction(owners)
	if(breast_anim_both)
		var/mob/living/carbon/human/other = receiver == action_user ? action_target : action_user
		if(ishuman(other) && other != receiver)
			play_breast_anim_on(other)
	if(!ishuman(receiver))
		return
	play_breast_anim_on(receiver)

/datum/sex_action/proc/play_breast_anim_on(mob/living/carbon/human/receiver)
	var/shot
	switch(breast_anim_kind)
		if(BREAST_ANIM_THRUST, BREAST_ANIM_BOOBJOB)
			shot = get_intensity_breast_shot()
		if(BREAST_ANIM_TOUCH)
			shot = "walk_half"
		if(BREAST_ANIM_SQUEEZE)
			shot = "squeeze"
		if(BREAST_ANIM_PAIZURI)
			shot = "paizuri"
		if(BREAST_ANIM_HEFT)
			shot = "heft"
		if(BREAST_ANIM_RUN)
			shot = "bounce"
		if(BREAST_ANIM_JOLT)
			shot = "hit"
		if(BREAST_ANIM_SLAP)
			shot = breast_slap_phase ? "hit" : "slap_b"
		if(BREAST_ANIM_LOOP)
			shot = get_breast_loop_shot()
	if(shot)
		receiver.play_breast_shot(shot)

// Penetration and riding: the penetrated side.
/datum/sex_action/sex/vaginal
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_THRUST

/datum/sex_action/sex/anal
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_THRUST

/datum/sex_action/scissoring
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_THRUST

/datum/sex_action/sex/other/vagina
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_THRUST

/datum/sex_action/sex/other/anal
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_THRUST

// Boob jobs: the breasts' owner; given with her own breasts, press and ease back without the bounces.
/datum/sex_action/sex/boobjob
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_BOOBJOB

/datum/sex_action/sex/other/boobjob
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_PAIZURI

// Caresses: the breasts' owner.
/datum/sex_action/masturbate/breasts
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_TOUCH

/datum/sex_action/masturbate/nipples
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_TOUCH

/datum/sex_action/masturbate/other/breasts
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_TOUCH

/datum/sex_action/masturbate/other/nipples
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_TOUCH

/datum/sex_action/suck_nipples
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_TOUCH

// Slaps: the breasts' owner.
/datum/sex_action/masturbate/slap_breasts
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_SLAP

/datum/sex_action/masturbate/other/slap_breasts
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_SLAP

// Breast interactions.
/datum/sex_action/masturbate/other/squeeze_breasts
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_TOUCH

/datum/sex_action/bury_face
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_TOUCH

/datum/sex_action/cleavage_smother
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_TOUCH

/datum/sex_action/breast_press
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_TOUCH
	breast_anim_both = TRUE

/datum/sex_action/milk_breasts
	breast_anim_on = BREAST_ANIM_ON_TARGET
	breast_anim_kind = BREAST_ANIM_TOUCH

/datum/sex_action/spray_milk
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_JOLT

/datum/sex_action/masturbate/heft_breasts
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_HEFT

/datum/sex_action/suck_own_nipple
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_LOOP

/datum/sex_action/bounce_breasts
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_RUN

/datum/sex_action/masturbate/squeeze_together
	breast_anim_on = BREAST_ANIM_ON_USER
	breast_anim_kind = BREAST_ANIM_SQUEEZE

#undef BREAST_ANIM_ON_USER
#undef BREAST_ANIM_ON_TARGET
#undef BREAST_ANIM_THRUST
#undef BREAST_ANIM_BOOBJOB
#undef BREAST_ANIM_TOUCH
#undef BREAST_ANIM_SLAP
#undef BREAST_ANIM_SQUEEZE
#undef BREAST_ANIM_HEFT
#undef BREAST_ANIM_PAIZURI
#undef BREAST_ANIM_RUN
#undef BREAST_ANIM_JOLT
#undef BREAST_ANIM_LOOP
