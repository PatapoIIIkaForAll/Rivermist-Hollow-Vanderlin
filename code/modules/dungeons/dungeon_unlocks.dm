/// A purchasable, dungeon-sandboxed meta upgrade. Effects are read by the run;
/// they never write to the character sheet.
/datum/dungeon_unlock
	var/id = "base"
	var/name = "Unlock"
	var/desc = ""
	var/echo_cost = 100

/datum/dungeon_unlock/start_boon
	id = "start_boon"
	name = "Pact of Preparation"
	desc = "Begin every run with a random boon already active."
	echo_cost = 150

/datum/dungeon_unlock/starting_motes
	id = "starting_motes"
	name = "Seed of Light"
	desc = "Start each run with 50 motes."
	echo_cost = 100

/datum/dungeon_unlock/extra_cache
	id = "extra_cache"
	name = "Greedy Eye"
	desc = "Reward caches can be opened one extra time."
	echo_cost = 120

/datum/dungeon_unlock/deep_start
	id = "deep_start"
	name = "The Shortcut Down"
	desc = "Begin runs on floor 2 (harder, richer)."
	echo_cost = 250

/datum/dungeon_unlock/grim_covenant
	id = "grim_covenant"
	name = "The Grim Covenant"
	desc = "Unseals the heat dials at assembly: harsher runs, richer echoes."
	echo_cost = DUNGEON_COVENANT_COST

/proc/get_dungeon_unlock_catalogue()
	var/list/catalogue = list()
	for(var/unlock_type in subtypesof(/datum/dungeon_unlock))
		var/datum/dungeon_unlock/unlock = new unlock_type
		if(unlock.id == "base")
			qdel(unlock)
			continue
		catalogue += unlock
	return catalogue
