/// Ported from Azure Peak.
/datum/emote/living/carbon/human/crack
	key = "crack"
	key_third_person = "cracks"
	message = "cracks their knuckles."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE
	hands_use_check = TRUE
	sound = 'modular_rmh/sound/emotes/knuckles.ogg'

/mob/living/carbon/human/verb/emote_crack()
	set name = "Knuckles"
	set category = "Emotes.Noises"
	emote("crack", intentional = TRUE)
