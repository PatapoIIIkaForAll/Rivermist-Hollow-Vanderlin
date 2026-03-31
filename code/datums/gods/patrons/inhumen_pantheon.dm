/datum/patron/inhumen
	abstract_type = /datum/patron/inhumen
	associated_faith = /datum/faith/inhumen_pantheon

	confess_lines = list(
		"AO AND THE GODS ARE LIARS!",
		"THE SO-CALLED GODS ARE WORTHLESS COWARDS!",
		"THE GODS ARE DECEIVERS!"
	)

/datum/patron/inhumen/can_pray(mob/living/follower)
	for(var/obj/structure/fluff/psycross/cross in view(7, get_turf(follower)))
		if(cross.divine && !cross.obj_broken)
			to_chat(follower, span_danger("That accursed holy symbol won't let me commune with the dark powers!"))
			return FALSE

	return TRUE

/* ----------------- */ // THESE RENAMES ARE MADE TO REMOVE ALL MENTIONS OF RT'S GODS, ACTUAL GODS ARE IN THE RMH MODULAR FOLDER

/datum/patron/inhumen/zizo
	name = "Lolth"
	domain = "Goddess of Domination, Treachery, and Dark Elves"
	desc = "The Spider Queen, cruel matron of ambition and domination, whispering promises of power to those willing to betray everything for it."
	flaws = "Hubris, Superiority, Fury"
	worshippers = "Dark Elves, Aspirants, Necromancers, Misandrists"
	sins = "Pearl-clutching, Moralism, Wastefulness"
	boons = "You may perform fleshcrafting. Access to roles with magic."
	//added_traits = list(TRAIT_CABAL)	No need for this. They have fleshcrafting now.
	devotion_holder = /datum/devotion/inhumen/zizo
	confess_lines = list(
		"I FOLLOW THE PATH OF LOLTH!",
		"LONG LIVE THE SPIDER QUEEN!",
		"LOLTH SHOWED ME THE WAY!",
	)
	storyteller = /datum/storyteller/zizo
	added_verbs = list(
		/mob/living/carbon/human/proc/draw_sigil,
		/mob/living/carbon/human/proc/praise,
	)

/datum/patron/inhumen/graggar
	name = "Gruumsh"
	domain = "God of Orcs, Conquest, and Unbridled Hatred"
	desc = "The One-Eyed God, roaring for conquest, blood, and strength without mercy from all who bear his mark."
	flaws = "Rage, Hatred, Bloodthirst"
	worshippers = "Greenskins, The Revenge-Driven, Sadists, Misogynists"
	sins = "Compassion, Frailty, Servility"
	boons = "You are drawn to the flavour of raw flesh and organs, and may consume without worry."
	added_traits = list(TRAIT_ORGAN_EATER)
	devotion_holder = /datum/devotion/inhumen/graggar
	confess_lines = list(
		"GRUUMSH IS THE BEAST I WORSHIP!",
		"GRUUMSH WILL RAVAGE YOU!",
		"GRUUMSH BRINGS HOLY DESTRUCTION!"
	)
	storyteller = /datum/storyteller/graggar

/datum/patron/inhumen/matthios
	name = "Mask"
	domain = "God of Thievery, Shadows, and Ill-Gotten Gains"
	desc = "Lord of Shadows, patron of thieves and hidden hands, whose faithful lift wealth from the proud before it can be defended."
	flaws = "Pride, Greed, Orneriness"
	worshippers = "Outlaws, Noble-Haters, Downtrodden Peasantry"
	sins = "Clumsiness, Stupidity, Humility"
	boons = "You can see the most expensive item someone is carrying."
	added_traits = list(TRAIT_MATTHIOS_EYES)
	devotion_holder = /datum/devotion/inhumen/matthios
	confess_lines = list(
		"MASK STEALS FROM THE WORTHLESS!",
		"MASK HIDES ME FROM THE MIGHTY!",
		"MASK IS MY LORD, I SHALL BE HIS KNIFE!",
	)
	storyteller = /datum/storyteller/matthios

/datum/patron/inhumen/baotha
	name = "Blissara"
	domain = "Goddess of Ecstasy, Psychic Hunger, and Selfish Delight"	//Bright-dyed hair falls within 'remorseless joy.' Joy for one's self at expense of the setting. Same for her music taste.
	desc = "A veiled, forbidden power of euphoric surrender and predatory desire. Her whispers promise belonging, bliss, and release at any cost."
	flaws = "Manipulation, Self-Destruction, Willingness to Sacrifice Others"
	worshippers = "Addicts, Hedonists, Pink-Haired Harlots"
	sins = "Sobriety, Self-Sacrifice, Faltering Willpower"
	boons = "You will never overdose on drugs."
	added_traits = list(TRAIT_CRACKHEAD)
	devotion_holder = /datum/devotion/inhumen/baotha
	confess_lines = list(
		"LIVE, LAUGH, LOVE! IN BLISSARA'S NAME!",
		"JOY AT ALL COSTS! BLISSARA'S TEACHINGS REIGN!",
		"BLISSARA'S WHISPERS CALM MY MIND!",
	)
	storyteller = /datum/storyteller/baotha

/// Maniac Patron - Their mind is broken by secrets of Zizo/Graggar combined. They quite possibly know the reality of what happens outside the planet. They may think this is all a game. They are clearly insane.
/datum/patron/inhumen/graggar_zizo
	name = "The Shattered Idol"
	domain = "Broken divinity of spider-schemes, blood-hunger, and forbidden revelation."
	desc = "A shattered thing formed from truths no mortal mind should hold. Lolth's webs and Gruumsh's hunger have tangled together into a god-shaped wound."
	flaws = "Nothing, Everything, Nothing"
	worshippers = "Broken Minds, Overshared Secrets, Space-Faring Species Like You, Misanthropes"
	sins = "The Unseen, Secrets, Worthless Pigs"
	boons = "You are drawn to the flavour of other followers of Zizo, and may see them when you consume without worry."
	added_traits = list(TRAIT_ORGAN_EATER, TRAIT_CABAL)
	confess_lines = list(
		"WHERE AM I!",
		"NONE OF THIS IS REAL!",
		"WHAT AM I WORSHIPPING?!"
	)

/datum/patron/inhumen/graggar_zizo/preference_accessible(datum/preferences/prefs)
	return FALSE

/datum/patron/inhumen/graggar_zizo/can_pray(mob/living/follower)
	var/datum/antagonist/maniac/dreamer = follower.mind.has_antag_datum(/datum/antagonist/maniac)
	if(dreamer)
		return TRUE
	// if a non-maniac somehow gets this patron,
	// something interesting should happen if they try to pray.
	INVOKE_ASYNC(follower, GLOBAL_PROC_REF(cant_wake_up), follower)  //Something interesting happened.
	message_admins("[ADMIN_LOOKUPFLW(follower)] has been gibbed due to praying as a non-maniac with their patron set to Graggazo. Whoops..")
	return FALSE

/datum/patron/inhumen/graggar_zizo/hear_prayer(mob/living/follower, message)
	var/datum/antagonist/maniac/dreamer = follower.mind.has_antag_datum(/datum/antagonist/maniac)
	if(!dreamer)
		return FALSE
	if(text2num(message) == dreamer.sum_keys)
		INVOKE_ASYNC(dreamer, TYPE_PROC_REF(/datum/antagonist/maniac, wake_up))
		return TRUE
	. = ..()
