/datum/map_template/pocket/dungeon
	/// Recipe name for a room built from the shared Sunken Warrens shell.
	var/procedural_recipe

/datum/map_template/pocket/dungeon/swampgob/procedural
	name = "_swampgob_procedural_base"
	id = "_swampgob_procedural_base"
	mappath = "_maps/templates/dungeons/swampgob/procedural_shell.dmm"
	instance_type = /datum/pocket_dimension/dungeon/procedural
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 1
	dungeon_weight = 8
	production_eligible = FALSE

/datum/map_template/pocket/dungeon/swampgob/procedural/root_ring
	name = "The Fungal Mere"
	id = "swampgob_procedural_root_ring"
	procedural_recipe = "root_ring"
	production_eligible = TRUE
	gate_hint = "Luminous mushrooms crowd the banks of a black pool."

/datum/map_template/pocket/dungeon/swampgob/procedural/split_hall
	name = "The Split-Stone Warren"
	id = "swampgob_procedural_split_hall"
	procedural_recipe = "split_hall"
	production_eligible = TRUE
	gate_hint = "Stone partitions split the passage, and goblin voices echo from both sides."

/datum/map_template/pocket/dungeon/swampgob/procedural/crossing
	name = "The Flooded Crossing"
	id = "swampgob_procedural_crossing"
	procedural_recipe = "crossing"
	production_eligible = TRUE
	gate_hint = "Several narrow approaches meet around the smell of stagnant water."
