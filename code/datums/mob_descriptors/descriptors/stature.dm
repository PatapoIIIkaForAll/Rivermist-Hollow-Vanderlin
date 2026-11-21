/datum/mob_descriptor/stature
	abstract_type = /datum/mob_descriptor/stature
	slot = MOB_DESCRIPTOR_SLOT_STATURE
	show_obscured = TRUE

/datum/mob_descriptor/stature/man
	name = "Man/Woman"

/datum/mob_descriptor/stature/man/get_description(mob/living/described)
	if(described.gender == MALE)
		return "man"
	else
		return "woman"

/datum/mob_descriptor/stature/gentleman
	name = "Gentleman/Gentlewoman"

/datum/mob_descriptor/stature/gentleman/get_description(mob/living/described)
	if(described.gender == MALE)
		return "gentleman"
	else
		return "gentlewoman"

/datum/mob_descriptor/stature/thug
	name = "Thug"

/datum/mob_descriptor/stature/snob
	name = "Snob"

/datum/mob_descriptor/stature/slob
	name = "Slob"

/datum/mob_descriptor/stature/brute
	name = "Brute"

/datum/mob_descriptor/stature/highbrow
	name = "Highbrow"

/datum/mob_descriptor/stature/stooge
	name = "Stooge"

/datum/mob_descriptor/stature/fool
	name = "Fool"

/datum/mob_descriptor/stature/bookworm
	name = "Bookworm"

/datum/mob_descriptor/stature/lowlife
	name = "Lowlife"

/datum/mob_descriptor/stature/dignitary
	name = "Dignitary"

/datum/mob_descriptor/stature/trickster
	name = "Trickster"

/datum/mob_descriptor/stature/vagabond
	name = "Orphan"

/datum/mob_descriptor/stature/foreigner
	name = "Foreigner"

/datum/mob_descriptor/stature/scoundrel
	name = "Scoundrel"

/datum/mob_descriptor/stature/scoundrel/get_description(mob/living/described)
	if(described.gender == MALE)
		return "scoundrel"
	else
		return "wench"

/datum/mob_descriptor/stature/commoner
	name = "Commoner"

/datum/mob_descriptor/stature/simpleton
	name = "Simpleton"

/datum/mob_descriptor/stature/cavalier
	name = "Cavalier"

/datum/mob_descriptor/stature/swashbuckler
	name = "Swashbuckler"

/datum/mob_descriptor/stature/patriarch
	name = "Patriarch/Matriarch"

/datum/mob_descriptor/stature/patriarch/get_description(mob/living/described)
	if(described.gender == MALE)
		return "patriarch"
	else
		return "matriarch"

/datum/mob_descriptor/stature/hag
	name = "Hag/Codger"

/datum/mob_descriptor/stature/hag/get_description(mob/living/described)
	if(described.gender == MALE)
		return "codger"
	else
		return "hag"

/datum/mob_descriptor/stature/villain
	name = "Villain/Villainess"

/datum/mob_descriptor/stature/villain/get_description(mob/living/described)
	if(described.gender == MALE)
		return "villain"
	else
		return "villainess"

/datum/mob_descriptor/stature/knave
	name = "Knave"

/datum/mob_descriptor/stature/wench
	name = "Wench"

/datum/mob_descriptor/stature/scholar
	name = "Scholar"

/datum/mob_descriptor/stature/rogue
	name = "Rogue"

/datum/mob_descriptor/stature/hermit
	name = "Hermit"

/datum/mob_descriptor/stature/pushover
	name = "Pushover"

/datum/mob_descriptor/stature/beguiler
	name = "Beguiler"

/datum/mob_descriptor/stature/daredevil
	name = "Daredevil"

/datum/mob_descriptor/stature/valiant
	name = "Valiant"

/datum/mob_descriptor/stature/adventurer
	name = "Adventurer"

/datum/mob_descriptor/stature/fiend
	name = "Fiend"

/datum/mob_descriptor/stature/stoic
	name = "Stoic"

/datum/mob_descriptor/stature/degenerate
	name = "Degenerate"

/datum/mob_descriptor/stature/zealot
	name = "Zealot"

/datum/mob_descriptor/stature/churl
	name = "Churl"

/datum/mob_descriptor/stature/archon
	name = "Archon"

/datum/mob_descriptor/stature/vizier
	name = "Vizier"

/datum/mob_descriptor/stature/blaggard
	name = "Blaggard"

/datum/mob_descriptor/stature/creep
	name = "Creep"

/datum/mob_descriptor/stature/freek
	name = "Freek"

/datum/mob_descriptor/stature/weerdoe
	name = "Weerdoe"

/datum/mob_descriptor/stature/plump
	name = "Plump Figure"

/datum/mob_descriptor/stature/savant
	name = "Savant"

/datum/mob_descriptor/stature/pilgrim
	name = "Pilgrim"

/datum/mob_descriptor/stature/penitent
	name = "Penitent"

/datum/mob_descriptor/stature/gallant
	name = "Gallant"

/datum/mob_descriptor/stature/firebrand
	name = "Firebrand"

/datum/mob_descriptor/stature/mourner
	name = "Mourner"

/datum/mob_descriptor/stature/caretaker
	name = "Caretaker"

/datum/mob_descriptor/stature/meddler
	name = "Meddler"

/datum/mob_descriptor/stature/dreamer
	name = "Dreamer"

/datum/mob_descriptor/stature/ascetic
	name = "Ascetic"

/datum/mob_descriptor/stature/sort
	name = "Sort"

/datum/mob_descriptor/stature/sprite
	name = "Sprite"

/datum/mob_descriptor/stature/debutante
	name = "Debutante"

/datum/mob_descriptor/stature/coquette
	name = "Coquette"

/datum/mob_descriptor/stature/songbird
	name = "Songbird"

/datum/mob_descriptor/stature/lad
	name = "Lad/Lass"

/datum/mob_descriptor/stature/lad/get_description(mob/living/described)
	if(described.gender == MALE)
		return "lad"
	else
		return "lass"

/datum/mob_descriptor/stature/beau
	name = "Beau/Belle"

/datum/mob_descriptor/stature/beau/get_description(mob/living/described)
	if(described.gender == MALE)
		return "beau"
	else
		return "belle"

/datum/mob_descriptor/stature/dandy
	name = "Dandy/Damsel"

/datum/mob_descriptor/stature/dandy/get_description(mob/living/described)
	if(described.gender == MALE)
		return "dandy"
	else
		return "damsel"

/datum/mob_descriptor/stature/hero
	name = "Hero/Heroine"

/datum/mob_descriptor/stature/hero/get_description(mob/living/described)
	if(described.gender == MALE)
		return "hero"
	else
		return "heroine"

/datum/mob_descriptor/stature/host
	name = "Host/Hostess"

/datum/mob_descriptor/stature/host/get_description(mob/living/described)
	if(described.gender == MALE)
		return "host"
	else
		return "hostess"

/datum/mob_descriptor/stature/widower
	name = "Widower/Widow"

/datum/mob_descriptor/stature/widower/get_description(mob/living/described)
	if(described.gender == MALE)
		return "widower"
	else
		return "widow"

/datum/mob_descriptor/stature/hunter
	name = "Hunter/Huntress"

/datum/mob_descriptor/stature/hunter/get_description(mob/living/described)
	if(described.gender == MALE)
		return "hunter"
	else
		return "huntress"

/datum/mob_descriptor/stature/bear
	name = "Bear"

/datum/mob_descriptor/stature/ruffian
	name = "Ruffian/Broad"

/datum/mob_descriptor/stature/ruffian/get_description(mob/living/described)
	if(described.gender == MALE)
		return "ruffian"
	else
		return "broad"

/datum/mob_descriptor/stature/wanderer
	name = "Wanderer"

/datum/mob_descriptor/stature/hustler
	name = "Hustler"

/datum/mob_descriptor/stature/samaritan
	name = "Samaritan"

/datum/mob_descriptor/stature/pupil
	name = "Pupil"

/datum/mob_descriptor/stature/soldier
	name = "Soldier"

/datum/mob_descriptor/stature/recluse
	name = "Recluse"

/datum/mob_descriptor/stature/socialite
	name = "Socialite"

/datum/mob_descriptor/stature/custom
	name = "Custom Stature"
	custom_index = 7
