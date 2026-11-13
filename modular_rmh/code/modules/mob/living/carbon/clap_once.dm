/// A single sharp clap, for calling attention or ending a song. Ported from Ratwood.
/datum/emote/living/carbon/clap/once
	key = "clap1"
	key_third_person = ""
	message = "claps their hands together once."
	sound = 'modular_rmh/sound/emotes/claponce.ogg'

/mob/living/carbon/human/verb/emote_clap_once()
	set name = "Clap Once"
	set category = "Emotes.Noises"
	emote("clap1", intentional = TRUE)
