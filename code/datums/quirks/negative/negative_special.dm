
/datum/quirk/negative/wanted
	name = "Wanted"
	desc = "Something in my past has made me a target. I am marked as an outlaw in these lands. I'm always looking over my shoulder. And protecting my loins..."
	desc_hint = "THIS IS A DIFFICULT FLAW - play at your own risk. \
	<br>You will be hunted and have non-con and rape attempts made against you by town guards. \
	This does not give you a license to grief or perform criminal acts with impunity, \
	this is a roleplay flaw to make you a 'target'"
	point_value = 3
	customization_type = QUIRK_TEXT
	customization_label = "Why are you being hunted?"
	customization_placeholder = "Fleeing prison."
	var/logged = FALSE

/datum/quirk/negative/wanted/get_desc(datum/preferences/prefs)
	var/reason = prefs?.quirk_customizations[type]
	if(!reason)
		reason = customization_value
	if(reason && reason != "")
		return "[desc]<br><br><b>Reason:</b> [reason]"
	return "[desc]<br><br><b>Reason:</b> Unknown - a mystery from your past."

/datum/quirk/negative/wanted/after_job_spawn(datum/job/job)
	var/mob/living/carbon/human/H = owner
	if(!logged && H.name)
		log_hunted("[H.ckey] playing as [H.name] has the hunted quirk.")
		logged = TRUE
		GLOB.outlawed_players += H.real_name

/datum/quirk/negative/wanted/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("A wanted person..."))

/* THIS QUIRK ISN'T LIABLE FOR RIVERMIST HOLLOW BUILD
/datum/quirk/negative/luxless
	name = "Lux-less"
	desc = "Through some grand misfortune, or heroic sacrifice - you have given up your link to Psydon, and with it - your soul. A putrid, horrid thing, you consign yourself to an eternity of nil after death. EXPECT A DIFFICULT, MECHANICALLY UNFAIR EXPERIENCE. (Rakshari, Hollowkin and Kobolds cannot take this - they already have no lux.)"
	point_value = 5
	random_exempt = TRUE
	blocked_species = list(
		/datum/species/kobold,
		/datum/species/demihuman,
		/datum/species/rakshari,
		/datum/species/rousman,
		/datum/species/goblin,
		/datum/species/orc,
	)

/datum/quirk/negative/luxless/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Luxless..."))

/datum/quirk/negative/luxless/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.apply_status_effect(/datum/status_effect/debuff/flaw_lux_taken)
*/

/datum/quirk/negative/pacifist
	name = "Pacifist"
	desc = "I don't want to harm other living beings!"
	point_value = 8

/datum/quirk/negative/pacifist/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner

	// Check if player is an antagonist
	if(H.mind && ((H.mind in GLOB.pre_setup_antags) || H.mind.has_antag_datum(/datum/antagonist)))
		to_chat(H, span_warning("As an antagonist, you cannot be a pacifist. This quirk has been removed."))
		return

	ADD_TRAIT(owner, TRAIT_PACIFISM, "[type]")

/datum/quirk/negative/pacifist/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Pacifist..."))

/datum/quirk/negative/pacifist/on_remove()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_PACIFISM, "[type]")

/datum/quirk/negative/chronic_migraine
	name = "Chronic Migraines"
	desc = "You suffer from frequent, debilitating headaches that can strike without warning."
	point_value = 3

/datum/quirk/negative/chronic_migraine/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/obj/item/bodypart/BP = H.get_bodypart(BODY_ZONE_HEAD)
	BP?.add_pain(rand(17.5, 27.5))
	BP?.limb_flags |= BODYPART_CHRONIC_MIGRAINE
	BP?.update_chronic()
	to_chat(H, span_warning("You feel the familiar pressure building behind your eyes."))

/datum/quirk/negative/skill_issue
	name = "Skill Issue"
	desc = "You were never the best at anything, and it shows. Lose 1 point to all starting skills."
	point_value = 5

/datum/quirk/negative/skill_issue/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	for(var/datum/attribute/skill/skill in SSskills.all_skills)
		H.adjust_skill_level(skill, -10)

/datum/quirk/negative/deaf
	name = "Hard of Hearing"
	desc = "You can barely hear. Words said outside of a 2 tile radius become jumbled or unreadable unless screamed."
	point_value = 3

/datum/quirk/negative/deaf/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_PARTIAL_DEAF, "[type]")

/datum/quirk/negative/deaf/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_PARTIAL_DEAF, "[type]")

/datum/quirk/negative/traumatized
	name = "Traumatized"
	desc = "You were an adventurer once, till you took something to the knee. Choose something to be afraid of."
	point_value = 3
	customization_label = "Choose Fear"
	customization_options = list(
		/datum/species/goblin,
		/datum/species/werewolf,
		/datum/species/orc,
		/datum/species/halforc,
		/datum/species/halfling,
		/datum/species/demihuman,
		/datum/species/dwarf,
		/datum/species/elf,
		/datum/species/triton,
		/datum/species/rakshari,
		/datum/species/kobold,
		///datum/oratorium,
		"Nobles",
	)

	var/fear_type
	var/next_scream_time = 0

/datum/quirk/negative/traumatized/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Traumatized..."))

/datum/quirk/negative/traumatized/on_spawn()
	if(!ishuman(owner))
		return
	if(!customization_value)
		customization_value = /datum/species/goblin
	fear_type = customization_value

/datum/quirk/negative/traumatized/on_life(mob/living/user)
	if(world.time < next_scream_time)
		return
	if(ispath(fear_type, /datum/species))
		for(var/mob/living/carbon/human/human in view(5, user))
			if(human == user)
				continue
			if(is_species(human, fear_type))
				var/mob/living/carbon/human/H = user
				H.emote("scream")
				H.Immobilize(1.5 SECONDS)
				H.add_stress(/datum/stress_event/traumatized)
				to_chat(H, span_userdanger("You see [human] and freeze in terror!"))
				next_scream_time = world.time + 25 SECONDS
				return
	else if(fear_type == "Nobles")
		for(var/mob/living/carbon/human/human in view(5, user))
			if(human == user)
				continue
			if(human.is_noble())
				var/mob/living/carbon/human/H = user
				H.emote("scream")
				H.Immobilize(1.5 SECONDS)
				H.add_stress(/datum/stress_event/traumatized)
				to_chat(H, span_userdanger("You see [human] and freeze in terror!"))
				next_scream_time = world.time + 25 SECONDS
				return
	else
		for(var/mob/living/carbon/human/human in view(5, user))
			if(human == user)
				continue
			if(HAS_TRAIT(human, TRAIT_INQUISITION))
				var/mob/living/carbon/human/H = user
				H.emote("scream")
				H.Immobilize(1.5 SECONDS)
				H.add_stress(/datum/stress_event/traumatized)
				to_chat(H, span_userdanger("You see [human] and freeze in terror!"))
				next_scream_time = world.time + 25 SECONDS
				return


/datum/stress_event/traumatized
	desc = "<span class='danger'>I saw one of THOSE things again!</span>\n"
	stress_change = 5
	timer = 5 MINUTES

/datum/quirk/negative/tortured
	name = "Tortured"
	desc = "You were once tortured by bandits, Drow raiders, or your own kingdom. You fear it happening again and always answer truthfully when tortured."
	point_value = 2

/datum/quirk/negative/tortured/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Tortured..."))

/datum/quirk/negative/tortured/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_TORTURED, "[type]")

/datum/quirk/negative/tortured/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_TORTURED, "[type]")

/datum/quirk/negative/weak_heart
	name = "Weak Heart"
	desc = "You were born with a weak heart. You can't handle stressful situations for fear of your heart giving out."
	desc_hint = "Half threshold for heart attacks, and you collapse for a minute when overly stressed"
	point_value = 4
	incompatible_quirks = list(
		/datum/quirk/positive/iron_will
	)

/datum/quirk/negative/weak_heart/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Weak-Hearted..."))

/datum/quirk/negative/weak_heart/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_WEAK_HEART, "[type]")

/datum/quirk/negative/weak_heart/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_WEAK_HEART, "[type]")

/datum/quirk/negative/tremors
	name = "Tremors"
	desc = "Your body tremors periodically, causing you to drop what's in your hands and lose your grip for a short time. High stress makes the tremors worse."
	point_value = 4
	var/next_tremor_time = 0
	var/base_tremor_interval = 5 MINUTES
	var/stress_tremor_interval = 2 MINUTES

/datum/quirk/negative/tremors/on_spawn()
	if(!owner)
		return
	schedule_next_tremor()

/datum/quirk/negative/tremors/on_life()
	if(!owner)
		return

	if(world.time >= next_tremor_time)
		trigger_tremor()
		schedule_next_tremor()

/datum/quirk/negative/tremors/proc/schedule_next_tremor()
	if(!owner)
		return

	var/mob/living/carbon/human/H = owner
	var/tremor_interval = base_tremor_interval

	if(H.stress >= 6)
		tremor_interval = stress_tremor_interval
	else if(H.stress >= 4) // Medium stress
		tremor_interval = (base_tremor_interval + stress_tremor_interval) / 2

	// Add some randomness so it's not perfectly predictable
	tremor_interval = tremor_interval + rand(-30 SECONDS, 30 SECONDS)
	next_tremor_time = world.time + tremor_interval

/datum/quirk/negative/tremors/proc/trigger_tremor()
	if(!owner)
		return

	var/mob/living/carbon/human/H = owner

	// Visual and audio feedback
	to_chat(H, span_warning("Your hands begin to shake uncontrollably!"))
	H.visible_message(span_warning("[H]'s hands begin trembling!"))

	// Drop everything in hands
	for(var/obj/item/I in H.held_items)
		if(I)
			H.dropItemToGround(I)
			to_chat(H, span_warning("You drop [I] as your hands shake!"))

	// Apply temporary inability to grip
	H.apply_status_effect(/datum/status_effect/tremor_grip_loss)

	// Shake the screen slightly for immersion
	if(H.client)
		animate(H.client, pixel_x = rand(-2, 2), pixel_y = rand(-2, 2), time = 2)
		addtimer(CALLBACK(src, PROC_REF(reset_screen_shake), H), 2)

/datum/quirk/negative/tremors/proc/reset_screen_shake(mob/living/carbon/human/H)
	if(H?.client)
		animate(H.client, pixel_x = 0, pixel_y = 0, time = 2)

/datum/status_effect/tremor_grip_loss
	id = "tremor_grip_loss"
	duration = 6 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/tremor_grip_loss

/datum/status_effect/tremor_grip_loss/on_apply()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/H = owner
	to_chat(H, span_warning("Your hands are shaking too much to grip anything!"))

	// Periodic shaking during the effect
	addtimer(CALLBACK(src, PROC_REF(shake_hands)), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(shake_hands)), 4 SECONDS)

	return TRUE

/datum/status_effect/tremor_grip_loss/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	to_chat(H, span_notice("Your hands steady themselves."))

/datum/status_effect/tremor_grip_loss/proc/shake_hands()
	if(!owner)
		return
	var/mob/living/carbon/human/H = owner
	H.visible_message(span_warning("[H]'s hands continue to tremble."), \
					span_warning("Your hands continue to shake..."))

/atom/movable/screen/alert/status_effect/tremor_grip_loss
	name = "Trembling Hands"
	desc = "My hands are shaking uncontrollably! I can't grip anything!"
/*
/datum/quirk/negative/heretic_outlaw
	name = "Heretic or Outlaw"
	desc = "You begin your journey marked as either a heretic or an outlaw, despised by society."
	point_value = 2
	customization_type = QUIRK_SELECT
	customization_label = "Choose your mark"
	customization_options = list("Heretic", "Outlaw")
	preview_render = FALSE

/datum/quirk/negative/heretic_outlaw/on_spawn()
	if(!owner || !ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner

	if(!customization_value)
		customization_value = pick(customization_options)

	if(customization_value == "Heretic")
		GLOB.excommunicated_players += H.real_name
		to_chat(H, span_boldwarning("I've been denounced by the church for either reasons legitimate or not!"))
	else // Outlaw
		GLOB.outlawed_players |= H.real_name
		to_chat(H, span_boldwarning("Whether for crimes I did or was accused of, I have been declared an outlaw!"))*/

