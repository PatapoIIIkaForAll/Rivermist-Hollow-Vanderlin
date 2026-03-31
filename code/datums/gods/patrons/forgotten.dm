/datum/patron/psydon // THESE RENAMES ARE MADE TO REMOVE ALL MENTIONS OF RT'S GODS, ACTUAL GODS ARE IN THE RMH MODULAR FOLDER
	name = "Ao"
	display_name = "Orthodox Aonite"
	domain = "Overgod of Balance, Decree, and Creation"
	desc = "The hidden Overgod, distant and ineffable. To his rare faithful, all lesser gods answer only to Ao's final decree."
	flaws = "Grudge-Holding, Judgemental, Self-Sacrificing"
	worshippers = "Inquisitors, zealots, absolutists"
	sins = "Apostasy, demon worship, defiance of cosmic order"
	boons = "None. Ao does not grant power lightly."

	associated_faith = /datum/faith/psydon
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"THE LESSER GODS BEND TO HIS DECREE!",
		"AO'S WILL IS ETERNAL!",
	)
	profane_words = list()
	//devotion_holder = /datum/devotion/psydon

/datum/patron/psydon/can_pray(mob/living/carbon/human/follower)
	//We just kind of assume the follower is a human here
	if(
		istype(follower.wear_wrists, /obj/item/clothing/neck/psycross) || istype(follower.wear_neck, /obj/item/clothing/neck/psycross) || istype(follower.get_active_held_item(), /obj/item/clothing/neck/psycross)
		)
		return TRUE

	to_chat(follower, span_danger("I cannot speak to Him... I need His holy symbol!"))
	return FALSE

/datum/patron/psydon/extremist
	display_name = "Extremist Aonite"
	desc = "The gods are pretenders, false intercessors, and usurpers of the order that belongs to Ao alone. My actions prove my faith and His decree."
	flaws = "Stubborn, Fanatical, Spiteful"
	worshippers = "Fanatics, Misinformed Fools"
	sins = "Blasphemy, False Prophets, Trickery"
	confess_lines = list(
		"THERE IS ONLY ONE GOD!",
		"YOUR LESSER GODS ARE LIES!",
		"AO IS ABOVE ALL!",
	)


