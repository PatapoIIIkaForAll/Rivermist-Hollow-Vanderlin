/datum/emote/living/carbon/human
	mob_type_allowed_typecache = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_cry()
	set name = "Cry"
	set category = "Emotes.Noises"

	emote("cry", intentional = TRUE)

/datum/emote/living/carbon/human/cry/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(!C.can_speak())
			message = "makes a noise. Tears stream down their face."

/datum/emote/living/carbon/human/cry/run_emote(mob/user, params, type_override, intentional, targetted)
	. = ..()
	if(!.)
		return
	if(user.mind)
		record_featured_stat(FEATURED_STATS_CRYBABIES, user)
	var/mob/living/carbon/human/human_user = user
	human_user.show_visual_emote_overlay(/datum/bodypart_feature/visual_emote/cry, 12.8 SECONDS)

/datum/emote/living/carbon/human/eflick
	key = "eflick"
	key_third_person = "flicks"
	message = "flicks their ears."
	emote_type = EMOTE_VISIBLE
	runechat_msg = FALSE
	soundping = FALSE

/datum/emote/living/carbon/human/eflick/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	return H.dna?.species?.can_flick_ears(H)

/datum/emote/living/carbon/human/eflick/run_emote(mob/user, params, type_override, intentional, targetted)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = user
	H.dna.species.perform_flick_ears(H)

/mob/living/carbon/human/verb/emote_eflick()
	set name = "Ear Flick"
	set category = "Emotes.Silent"

	emote("eflick", intentional = TRUE)

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_eyebrow()
	set name = "Raise Eyebrow"
	set category = "Emotes.Silent"

	emote("eyebrow", intentional = TRUE)

/datum/emote/living/carbon/human/glasses
	key = "glasses"
	key_third_person = "glasses"
	message = "pushes up their spectacles."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_glasses()
	set name = "Push Spectacles"
	set category = "Emotes.Silent"

	emote("glasses", intentional = TRUE)

/datum/emote/living/carbon/human/glasses/can_run_emote(mob/user, status_check = TRUE, intentional, params)
	var/mob/living/carbon/human/human_user = user
	if(istype(human_user?.wear_mask, /obj/item/clothing/face/spectacles))
		return ..()
	return FALSE

/datum/emote/living/carbon/human/glasses/run_emote(mob/user, params, type_override, intentional, targetted)
	. = ..()
	if(.)
		var/mob/living/carbon/human/human_user = user
		human_user.show_visual_emote_animation("glasses", 1.6 SECONDS)

/datum/emote/living/carbon/human/psst
	key = "psst"
	key_third_person = "pssts"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE

/mob/living/carbon/human/verb/emote_psst()
	set name = "Psst"
	set category = "Emotes.Noises"

	emote("psst", intentional = TRUE)

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles."
	message_muffled = "makes a grumbling noise."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_grumble()
	set name = "Grumble"
	set category = "Emotes.Noises"

	emote("grumble", intentional = TRUE)

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	hands_use_check = TRUE
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_mumble()
	set name = "Mumble"
	set category = "Emotes.Noises"

	emote("mumble", intentional = TRUE)

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/mob/living/carbon/human/verb/emote_pale()
	set name = "Go pale"
	set category = "Emotes.Silent"
	emote("pale", intentional = TRUE)

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	hands_use_check = TRUE

/mob/living/carbon/human/verb/emote_raise()
	set name = "Raise hand"
	set category = "Emotes.Silent"
	emote("raise", intentional = TRUE)

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	hands_use_check = TRUE

/mob/living/carbon/human/verb/emote_salute()
	set name = "Salute"
	set category = "Emotes.Silent"
	emote("salute", intentional = TRUE)

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

/mob/living/carbon/human/verb/emote_shrug()
	set name = "Shrug"
	set category = "Emotes.Silent"
	emote("shrug", intentional = TRUE)

/mob/living/carbon/human/verb/emote_wag()
	set name = "Wag"
	set category = "Emotes.Silent"
	emote("wag", intentional = TRUE)

/datum/emote/living/carbon/human/wag
	key = "wag"
	key_third_person = "wags"
	message = "wags their tail."

/datum/emote/living/carbon/human/wag/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.dna || !H.dna.species || !H.dna.species.can_wag_tail(H))
		return
	if(!H.dna.species.is_wagging_tail())
		H.dna.species.start_wagging_tail(H)
	else
		H.dna.species.stop_wagging_tail(H)

/datum/emote/living/carbon/human/wag/can_run_emote(mob/user, status_check = TRUE , intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	return H.dna && H.dna.species && H.dna.species.can_wag_tail(user)

/datum/emote/living/carbon/human/wag/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!H.dna || !H.dna.species)
		return
	if(H.dna.species.is_wagging_tail())
		. = null

/datum/emote/living/carbon/human/rakshari

/datum/emote/living/carbon/human/rakshari/meow
	key = "meow"
	key_third_person = "meows"
	message = "meows!"
	message_muffled = "meows silently."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = SFX_CAT_MEOW

/datum/emote/living/carbon/human/rakshari/purr
	key = "purr"
	key_third_person = "purrs"
	vary = TRUE
	sound = SFX_CAT_PURR
	message = "purrs."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/species/rakshari/verb/emote_purr()
	set name = "Purr"
	set category = "Emotes.Wildtongue"
	emote("purr", intentional = TRUE)

/mob/living/carbon/human/species/rakshari/verb/emote_meow()
	set name = "Meow"
	set category = "Emotes.Wildtongue"
	emote("meow", intentional = TRUE)

/datum/emote/living/carbon/human/rawr
	key = "rawr"
	key_third_person = "rawrs"
	message = "rawrs!"
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_rawr()
	set name = "Rawr"
	set category = "Emotes.Noises"
	emote("rawr", intentional = TRUE)

//Ayy lmao
