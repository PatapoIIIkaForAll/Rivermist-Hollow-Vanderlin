GLOBAL_LIST_INIT(patron_sound_themes, list(
	ASTRATA = 'sound/magic/bless.ogg',
	NOC = 'sound/ambience/noises/mystical (4).ogg',
	EORA = 'sound/vo/female/gen/giggle (1).ogg',
	DENDOR = 'sound/magic/barbroar.ogg',
	MALUM = 'sound/magic/dwarf_chant01.ogg',
	XYLIX = 'sound/misc/gods/xylix_omen.ogg',
	NECRA = 'sound/ambience/noises/genspooky (1).ogg',
	ABYSSOR = 'sound/items/bucket_transfer (2).ogg',
	RAVOX = 'sound/vo/male/knight/rage (6).ogg',
	PESTRA = 'sound/magic/cosmic_expansion.ogg',
	ZIZO = 'sound/misc/gods/zizo_omen.ogg',
	GRAGGAR = 'sound/misc/gods/graggar_omen.ogg',
	BAOTHA = 'sound/misc/gods/baotha_omen.ogg',
	MATTHIOS = 'sound/misc/gods/matthios_omen.ogg'
))

/datum/patron/divine
	abstract_type = /datum/patron/divine
	associated_faith = /datum/faith/divine_pantheon
	profane_words = list("zizo", "cock", "dick", "fuck", "shit", "pussy", "cuck", "cunt", "asshole")
	var/associated_psycross = /obj/item/clothing/neck/psycross

/datum/patron/divine/can_pray(mob/living/carbon/human/follower)
	//you can pray anywhere inside a church
	if(istype(get_area(follower), /area/indoors/town/church))
		return TRUE

	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(!cross.obj_broken)
			return TRUE

	if(istype(follower.wear_wrists, associated_psycross) || istype(follower.wear_neck, associated_psycross) || istype(follower.get_active_held_item(), associated_psycross))
		return TRUE


	to_chat(follower, span_danger("I need an amulet of my patron, or a nearby shrine of the gods, for my prayers to be heard..."))
	return FALSE

/* ----------------- */ // THESE RENAMES ARE MADE TO REMOVE ALL MENTIONS OF RT'S GODS, ACTUAL GODS ARE IN THE RMH MODULAR FOLDER

/datum/patron/divine/astrata
	name = "Lathander"
	domain = "God of Dawn, Renewal, and Radiance"
	desc = "The Morninglord, patron of sunrise, rebirth, and bold new beginnings. His light blesses hopeful hearts across Faerun."
	flaws = "Tyrannical, Ill-Tempered, Uncompromising"
	worshippers = "Nobles, Zealots, Commoners"
	sins = "Betrayal, Sloth, Witchcraft"
	boons = "Your stamina regeneration delay is lowered during daytime."
	added_traits = list(TRAIT_APRICITY)
	devotion_holder = /datum/devotion/divine/astrata
	confess_lines = list(
		"LATHANDER IS MY LIGHT!",
		"DAWN BRINGS RENEWAL!",
		"I SERVE THE GLORY OF THE MORNING!",
	)
	storyteller = /datum/storyteller/astrata
	associated_psycross = /obj/item/clothing/neck/psycross/silver/astrata

/datum/patron/divine/noc
	name = "Mystra"
	domain = "Goddess of Magic, Knowledge, and the Weave"
	desc = "Mistress of the Weave, guardian of magic's balance, and patron of those who seek hidden truths through spellcraft."
	flaws = "Cynical, Isolationist, Unfiltered Honesty"
	worshippers = "Magic Practitioners, Scholars, Scribes"
	sins = "Suppressing Truth, Burning Books, Censorship"
	boons = "You learn, dream, and teach apprentices slightly better. Access to roles with magic."
	added_traits = list(TRAIT_TUTELAGE)
	devotion_holder = /datum/devotion/divine/noc
	confess_lines = list(
		"MYSTRA GUIDES MY HAND!",
		"THE WEAVE REVEALS THE TRUTH!",
		"I SEEK THE MYSTERIES OF MAGIC!",
	)
	storyteller = /datum/storyteller/noc
	associated_psycross = /obj/item/clothing/neck/psycross/silver/noc

/datum/patron/divine/dendor
	name = "Silvanus"
	domain = "God of Nature, Beasts, and the Wild Balance"
	desc = "The Oak Father, ancient and impartial, whose will governs the turning of the seasons and the balance of the wild."
	flaws = "Madness, Rebelliousness, Disorderliness"
	worshippers = "Druids, Beasts, Madmen"
	sins = "Deforestation, Overhunting, Disrespecting Nature"
	boons = "You are immune to kneestingers."
	added_traits = list(TRAIT_KNEESTINGER_IMMUNITY)
	devotion_holder = /datum/devotion/divine/dendor
	confess_lines = list(
		"SILVANUS PROVIDES!",
		"THE TREEFATHER BRINGS BOUNTY!",
		"I ANSWER THE CALL OF THE WILD!",
	)
	storyteller = /datum/storyteller/dendor
	associated_psycross = /obj/item/clothing/neck/psycross/silver/dendor

/datum/patron/divine/abyssor
	name = "Umberlee"
	domain = "Goddess of Seas, Storms, and Wrath"
	desc = "The Bitch Queen, wrathful mistress of the sea, feared by sailors who pay tribute lest her tides drag them to a watery grave."
	flaws= "Reckless, Stubborn, Destructive"
	worshippers = "Sailors of the Sea and Sky, Horrid Sea-Creachers, Fog Islanders"
	sins = "Fear, Hubris, Forgetfulness"
	boons = "Leeches will drain very little of your blood."
	added_traits = list(TRAIT_LEECHIMMUNE)
	devotion_holder = /datum/devotion/divine/abyssor
	confess_lines = list(
		"UMBERLEE COMMANDS THE WAVES!",
		"THE OCEAN'S FURY IS UMBERLEE'S WILL!",
		"I AM DRAWN BY THE PULL OF THE TIDE!",
	)
	storyteller = /datum/storyteller/abyssor
	associated_psycross = /obj/item/clothing/neck/psycross/silver/abyssor

/datum/patron/divine/necra
	name = "Jergal"
	domain = "God of Death, Fate, and Final Record"
	desc = "The Scribe of the Doomed, ancient seneschal of endings, who records every mortal fate with perfect, terrible calm."
	flaws = "Unchanging, Apathetic, Easy to Bore"
	worshippers = "Orderlies, Gravetenders, Mourners"
	sins = "Heretical Magic, Untimely Death, Disturbance of Rest"
	boons = "You may see the presence of a soul in a body."
	added_traits = list(TRAIT_SOUL_EXAMINE)
	devotion_holder = /datum/devotion/divine/necra
	confess_lines = list(
		"ALL SOULS FIND THEIR WAY TO JERGAL!",
		"THE SCRIBE OF THE DOOMED RECORDS US ALL!",
		"I FEAR NOT DEATH, FOR MY END IS WRITTEN!",
	)
	storyteller = /datum/storyteller/necra
	associated_psycross = /obj/item/clothing/neck/psycross/silver/necra

/datum/patron/divine/ravox
	name = "Tempus"
	domain = "God of War, Courage, and Battle"
	desc = "Lord of Battles, patron of courage and honorable warfare, who exalts valor without caring who claims the field."
	flaws = "Carelessness, Aggression, Pride"
	worshippers = "Warriors, Sellswords, Guardsmen"
	sins = "Cowardice, Cruelty, Stagnation"
	boons = "Your used weapons dull slower."
	added_traits = list(TRAIT_SHARPER_BLADES)
	devotion_holder = /datum/devotion/divine/ravox
	confess_lines = list(
		"TEMPUS STEELS MY HEART!",
		"THROUGH BATTLE, HONOR!",
		"THE DRUMS OF WAR BEAT IN MY CHEST!",
	)
	storyteller = /datum/storyteller/ravox
	associated_psycross = /obj/item/clothing/neck/psycross/silver/ravox

/datum/patron/divine/xylix
	name = "Tymora"
	domain = "Goddess of Luck, Fortune, and Daring"
	desc = "Lady Luck, smiling on the bold, the reckless, and the clever who wager everything on a single turn of fate."
	flaws = "Petulance, Deception, Gambling-Prone"
	worshippers = "Cheats, Performers, The Hopeless"
	sins = "Boredom, Predictability, Routine"
	boons = "You can rig different forms of gambling in your favor."
	added_traits = list(TRAIT_BLACKLEG)
	devotion_holder = /datum/devotion/divine/xylix
	confess_lines = list(
		"LATHANDER IS MY LIGHT!",
		"MYSTRA GUIDES THE WEAVE!",
		"SILVANUS PROVIDES!",
		"UMBERLEE COMMANDS THE WAVES!",
		"TEMPUS STEELS THE BOLD!",
		"ALL SOULS FIND THEIR WAY TO JERGAL!",
		"HAHAHAHA! AHAHAHA! HAHAHAHA!", //the only xylix-related confession
		"ILMATER SOOTHES ALL ILLS!",
		"MORADIN IS MY FORGE!",
		"SUNE BRINGS US TOGETHER!",
	)
	storyteller = /datum/storyteller/xylix
	associated_psycross = /obj/item/clothing/neck/psycross/silver/xylix

/datum/patron/divine/pestra
	name = "Ilmater"
	domain = "God of Suffering, Endurance, and Compassion"
	desc = "The Crying God, who bears suffering so others may be spared, and teaches mercy through endurance and relief."
	flaws = "Drunkenness, Crudeness, Irresponsibility"
	worshippers = "The Ill and Infirm, Alchemists, Physicians"
	sins = "´Curing´ Abnormalities, Refusing to Help Unfortunates, Groveling"
	boons = "You may consume rotten food without being sick."
	added_traits = list(TRAIT_ROT_EATER)
	devotion_holder = /datum/devotion/divine/pestra
	confess_lines = list(
		"ILMATER SOOTHES ALL ILLS!",
		"SUFFERING CAN BE ENDURED!",
		"MY PAIN IS NOT MINE ALONE TO BEAR!",
	)
	storyteller = /datum/storyteller/pestra
	associated_psycross = /obj/item/clothing/neck/psycross/silver/pestra

/datum/patron/divine/pestra/preference_accessible(datum/preferences/prefs)
	. = ..()
	if(!.)
		return

/datum/patron/divine/malum
	name = "Moradin"
	domain = "God of Toil, Forge, and Creation"
	desc = "The All-Father, divine smith of the dwarves, whose hammer shapes stone, steel, and worthy souls alike."
	flaws = "Obsessive, Exacting, Overbearing"
	worshippers = "Smiths, Miners, Sculptors"
	sins = "Cheating, Shoddy Work, Suicide"
	boons = "You recover more energy when sleeping."
	added_traits = list(TRAIT_BETTER_SLEEP)
	devotion_holder = /datum/devotion/divine/malum
	confess_lines = list(
		"MORADIN IS MY FORGE!",
		"TRUE VALUE IS IN THE TOIL!",
		"I AM AN INSTRUMENT OF CREATION!",
	)
	storyteller = /datum/storyteller/malum
	associated_psycross = /obj/item/clothing/neck/psycross/silver/malum

/datum/patron/divine/eora
	name = "Sune"
	domain = "Goddess of Love, Beauty, and Art"
	desc = "The Lady of Love, radiant patron of beauty, romance, and the bonds that make mortal life worth cherishing."
	flaws= "Naivete, Impulsiveness, Bigotry"
	worshippers = "Mothers, Artists, Married Couples"
	sins = "Sadism, Abandonment, Ruining Beauty"
	boons = "You can understand others' needs better."
	added_traits = list(TRAIT_EXTEROCEPTION)
	devotion_holder = /datum/devotion/divine/eora
	confess_lines = list(
		"SUNE BRINGS US TOGETHER!",
		"HER BEAUTY IS EVEN IN THIS TORMENT!",
		"I LOVE YOU, EVEN AS YOU TRESPASS AGAINST ME!",
	)
	storyteller = /datum/storyteller/eora
	associated_psycross = /obj/item/clothing/neck/psycross/silver/eora
