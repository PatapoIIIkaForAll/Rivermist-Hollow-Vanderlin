//PUNISH INTENT

/datum/intent/whip/punish
	name = "punish"
	blade_class = BCLASS_BLUNT
	attack_verb = list("lashes", "whips")
	hitsound = list('modular_rmh/sound/effects/slap1.ogg', 'modular_rmh/sound/effects/slap2.ogg')
	swingdelay = 2
	clickcd = 14
	reach = 2
	canparry = FALSE //Has reach and can't be parried, but needs to be charged and punishes misses.
	icon_state = "inpunish"
	penfactor = 0
	damfactor = 0.001 // idealy this should do one point of brute.

/datum/intent/whip/punish/cane
	attack_verb = list("lashes", "canes")
	reach = 1
	canparry = TRUE

/obj/item/weapon/whip/attack(mob/living/target, mob/living/user)

	. = ..()

	var/mob/living/carbon/human/victim = target

	if(istype(user.used_intent, /datum/intent/whip/punish))
		apply_whip_punish_effect(user, victim)

/obj/item/weapon/proc/apply_whip_punish_effect(mob/living/user, mob/living/carbon/human/victim)

	var/arousal = rand(1, 4)
	var/pain = rand(8, 16)
	var/climax = rand(0,1)

	SEND_SIGNAL(victim, COMSIG_SEX_GENERIC_ACTION, user, arousal, pain, climax, src)
	playsound(src, pick('modular_rmh/sound/effects/slap1.ogg', 'modular_rmh/sound/effects/slap2.ogg'), 100)
	if(istype(victim))
		victim.take_impact_mark(user, user.zone_selected, get_punish_mark_force(user), src)

	var/zone = user.zone_selected
	var/bodypart = "body"

	switch(zone)
		if(BODY_ZONE_HEAD)				bodypart = "head"
		if(BODY_ZONE_PRECISE_EARS)		bodypart = "ears"
		if(BODY_ZONE_PRECISE_NECK)		bodypart = "neck"
		if(BODY_ZONE_CHEST)				bodypart = "body"
		if(BODY_ZONE_PRECISE_GROIN)		bodypart = "bottom"
		if(BODY_ZONE_L_ARM)				bodypart = "left arm"
		if(BODY_ZONE_R_ARM)				bodypart = "right arm"
		if(BODY_ZONE_L_LEG)				bodypart = "left leg"
		if(BODY_ZONE_R_LEG)				bodypart = "right leg"
		if(BODY_ZONE_PRECISE_L_HAND)	bodypart = "left hand"
		if(BODY_ZONE_PRECISE_R_HAND)	bodypart = "right hand"
		if(BODY_ZONE_PRECISE_L_FOOT)	bodypart = "left foot"
		if(BODY_ZONE_PRECISE_R_FOOT)	bodypart = "right foot"

	if(pain >= 16 && prob(70))
		victim.visible_message(
			span_danger("[user] lashes [victim]'s [bodypart] with [src]!"),
			span_danger("A sharp burning pain spreads across your [bodypart]!"))

	else if(pain >= 12 && prob(50))
		victim.visible_message(
			span_danger("[user] strikes [victim]'s [bodypart] with [src]."),
			span_danger("The [src] stings against your [bodypart]."))

	else if(pain >= 8 && prob(30))
		victim.visible_message(
			span_danger("[victim] squirms after the strike to the [bodypart]."),
			span_danger("Your body reacts involuntarily to the strike."))

	if(arousal >= 3 && prob(40))
		victim.visible_message(
			("<span class='aphrodisiac'>[victim] shudders slightly from the whip's impact.</span>"),
			("<span class='aphrodisiac'>A tingling sensation spreads through your body.</span>"))

/// A punish strike marks as a rough act, or a brutal one with the strong stance.
/proc/get_punish_mark_force(mob/living/user)
	return istype(user?.rmb_intent, /datum/rmb_intent/strong) ? SEX_FORCE_EXTREME : SEX_FORCE_HIGH

/obj/item/storage/belt
	possible_item_intents = list(BELT_PUNISH, INTENT_USE)

/datum/intent/belt/punish
	name = "punish"
	blade_class = BCLASS_BLUNT
	attack_verb = list("lashes", "whips")
	swingdelay = 2
	clickcd = 14
	canparry = TRUE
	icon_state = "inpunish"

/obj/item/storage/belt/attack(mob/living/target, mob/living/user)

	. = ..()

	var/mob/living/carbon/human/victim = target

	if(istype(user.used_intent, /datum/intent/belt/punish))
		apply_belt_punish_effect(user, victim)

/obj/item/storage/belt/proc/apply_belt_punish_effect(mob/living/user, mob/living/carbon/human/victim)

	var/arousal = rand(0, 2)
	var/pain = rand(3, 7)
	var/climax = rand(0,1)

	SEND_SIGNAL(victim, COMSIG_SEX_GENERIC_ACTION, user, arousal, pain, climax, src)
	playsound(src, pick('modular_rmh/sound/effects/slap1.ogg', 'modular_rmh/sound/effects/slap2.ogg'), 100)
	if(istype(victim))
		victim.take_impact_mark(user, user.zone_selected, get_punish_mark_force(user), src)

	var/zone = user.zone_selected
	var/bodypart = "body"

	switch(zone)
		if(BODY_ZONE_HEAD)				bodypart = "head"
		if(BODY_ZONE_PRECISE_EARS)		bodypart = "ears"
		if(BODY_ZONE_PRECISE_NECK)		bodypart = "neck"
		if(BODY_ZONE_CHEST)				bodypart = "body"
		if(BODY_ZONE_PRECISE_GROIN)		bodypart = "bottom"
		if(BODY_ZONE_L_ARM)				bodypart = "left arm"
		if(BODY_ZONE_R_ARM)				bodypart = "right arm"
		if(BODY_ZONE_L_LEG)				bodypart = "left leg"
		if(BODY_ZONE_R_LEG)				bodypart = "right leg"
		if(BODY_ZONE_PRECISE_L_HAND)	bodypart = "left hand"
		if(BODY_ZONE_PRECISE_R_HAND)	bodypart = "right hand"
		if(BODY_ZONE_PRECISE_L_FOOT)	bodypart = "left foot"
		if(BODY_ZONE_PRECISE_R_FOOT)	bodypart = "right foot"

	if(pain >= 6 && prob(70))
		victim.visible_message(
			span_danger("[user] snaps [src] against [victim]'s [bodypart]!"),
			span_danger("The [src] stings sharply against your [bodypart]."))

	else if(pain >= 4 && prob(50))
		victim.visible_message(
			span_danger("[user] smacks [victim]'s [bodypart] with [src]."),
			span_danger("The [src] smacks against your [bodypart]."))

	if(arousal >= 2 && prob(40))
		victim.visible_message(
			("<span class='aphrodisiac'>[victim] shifts uncomfortably after the strike.</span>"),
			("<span class='aphrodisiac'>Your body reacts slightly to the sensation.</span>"))
