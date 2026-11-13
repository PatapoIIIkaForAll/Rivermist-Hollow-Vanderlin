#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

// The central test include undefines its assertions before modular files load.
#define PROCEDURAL_ASSERT(condition, message) if(!(condition)) { return Fail(message, __FILE__, __LINE__); }
#define PROCEDURAL_ASSERT_NOTNULL(value, message) PROCEDURAL_ASSERT(!isnull(value), message)
#define PROCEDURAL_ASSERT_EQUAL(left, right, message) PROCEDURAL_ASSERT((left) == (right), message)

/// Exercise the plan as map data, independently of its own validation walk.
/datum/unit_test/procedural_dungeon_plans/Run()
	var/list/recipes = list("root_ring", "split_hall", "crossing")
	var/list/recipe_shapes = list()

	for(var/recipe in recipes)
		var/list/shapes_for_recipe = list()
		for(var/seed in 1 to 320)
			var/datum/dungeon_room_plan/plan = new(seed, recipe)
			if(!plan.build() || !plan.validate())
				return Fail("[recipe] seed [seed] did not produce a valid room.")
			if(length(plan.cells) != 19 * 19)
				return Fail("[recipe] seed [seed] did not fill a 19x19 room.")
			if(plan.entry_index != 29 || plan.back_gate_index != 48)
				return Fail("[recipe] seed [seed] moved the safe entry or back gate.")
			if(length(plan.forward_gate_indices) != 2 || !(309 in plan.forward_gate_indices) || !(319 in plan.forward_gate_indices))
				return Fail("[recipe] seed [seed] moved a forward gate.")
			if(length(plan.guardian_slots) < 18)
				return Fail("[recipe] seed [seed] offers too few guardian positions.")

			// Use the raw cell data here, not plan.is_walkable() or plan.validate().
			var/list/walkable = list()
			var/walkable_count = 0
			for(var/index in 1 to 19 * 19)
				var/cell = plan.cells[index]
				if((cell == "floor" || cell == "grass" || cell == "cobble") && !(index in plan.light_slots) && !(index in plan.focal_slots))
					walkable["[index]"] = TRUE
					walkable_count++
			if(!walkable["[plan.entry_index]"])
				return Fail("[recipe] seed [seed] has a blocked entry.")
			for(var/index in plan.forward_gate_indices + list(plan.back_gate_index))
				if(plan.cells[index - 1] != "wall" || plan.cells[index + 1] != "wall")
					return Fail("[recipe] seed [seed] left a gate without rock jambs.")
			for(var/index in plan.focal_slots)
				if(plan.cells[index] != "grass")
					return Fail("[recipe] seed [seed] placed a tall mushroom off its dry bank.")
			if(length(plan.light_slots) != 4 || length(plan.glow_slots) != 6)
				return Fail("[recipe] seed [seed] lost its distributed lighting.")

			var/list/seen = list()
			var/list/queue = list(plan.entry_index)
			seen["[plan.entry_index]"] = TRUE
			var/visited_count = 0
			for(var/head = 1; head <= length(queue); head++)
				var/current = queue[head]
				visited_count++
				var/x = ((current - 1) % 19) + 1
				var/y = ((current - 1 - ((current - 1) % 19)) / 19) + 1
				var/list/neighbors = list()
				if(x > 1)
					neighbors += current - 1
				if(x < 19)
					neighbors += current + 1
				if(y > 1)
					neighbors += current - 19
				if(y < 19)
					neighbors += current + 19
				for(var/neighbor in neighbors)
					var/key = "[neighbor]"
					if(!walkable[key] || seen[key])
						continue
					seen[key] = TRUE
					queue += neighbor
			if(visited_count != walkable_count)
				return Fail("[recipe] seed [seed] stranded [walkable_count - visited_count] walkable cells.")

			for(var/slot in plan.guardian_slots)
				if(!seen["[slot]"])
					return Fail("[recipe] seed [seed] has an unreachable guardian slot at [slot].")
				var/slot_x = ((slot - 1) % 19) + 1
				var/slot_y = ((slot - 1 - ((slot - 1) % 19)) / 19) + 1
				for(var/gate_index in list(plan.entry_index, plan.back_gate_index, 309, 319))
					var/gate_x = ((gate_index - 1) % 19) + 1
					var/gate_y = ((gate_index - 1 - ((gate_index - 1) % 19)) / 19) + 1
					if(abs(slot_x - gate_x) + abs(slot_y - gate_y) < 6)
						return Fail("[recipe] seed [seed] puts a guardian slot within six tiles of a gate or entry.")

			var/shape = plan.cells.Join(",")
			shapes_for_recipe[shape] = TRUE
			if(seed == 1)
				recipe_shapes[recipe] = shape
			var/datum/dungeon_room_plan/repeated = new(seed, recipe)
			if(!repeated.build() || repeated.cells.Join(",") != shape || repeated.guardian_slots.Join(",") != plan.guardian_slots.Join(","))
				return Fail("[recipe] seed [seed] did not reproduce the same room and guardian positions.")
			qdel(repeated)
			qdel(plan)
			CHECK_TICK
		if(length(shapes_for_recipe) < 2)
			return Fail("Changing seeds did not vary [recipe].")

	if(recipe_shapes["root_ring"] == recipe_shapes["split_hall"] || recipe_shapes["root_ring"] == recipe_shapes["crossing"] || recipe_shapes["split_hall"] == recipe_shapes["crossing"])
		return Fail("The three recipes made indistinguishable rooms for seed 1.")

/datum/unit_test/procedural_dungeon_plan_rejects_damage/Run()
	var/datum/dungeon_room_plan/plan = allocate(/datum/dungeon_room_plan, 371, "root_ring")
	if(!plan.build() || !plan.validate())
		return Fail("Control plan should start valid.")
	var/entry_cell = plan.cells[plan.entry_index]
	plan.cells[plan.entry_index] = "wall"
	if(plan.validate())
		return Fail("Validation accepted a blocked entry.")
	plan.cells[plan.entry_index] = entry_cell
	if(!plan.validate())
		return Fail("Restoring the entry did not restore validity.")
	if(plan.cells[1] != "wall" || plan.cells[2] != "wall" || plan.cells[20] != "wall")
		return Fail("The room shell should have solid walls at its southwest corner.")
	plan.cells[1] = "floor"
	if(plan.validate())
		return Fail("Validation accepted an isolated walkable corner.")
	plan.cells[1] = "wall"
	plan.guardian_slots += plan.entry_index
	if(plan.validate())
		return Fail("Validation accepted a guardian on the entry tile.")

/datum/unit_test/procedural_dungeon_plans_are_independent/Run()
	var/datum/dungeon_room_plan/first = allocate(/datum/dungeon_room_plan, 71, "root_ring")
	var/datum/dungeon_room_plan/second = allocate(/datum/dungeon_room_plan, 71, "root_ring")
	if(!first.build() || !second.build())
		return Fail("Independent control plans failed to build.")
	var/original_cell = second.cells[second.entry_index]
	first.cells[first.entry_index] = "wall"
	if(second.cells[second.entry_index] != original_cell || !second.validate())
		return Fail("Editing one plan changed another instance.")
	if(first.validate())
		return Fail("The edited plan should reject its blocked entry.")

// The failed recipe must enter the same recovery path as a real failed build.
/datum/map_template/pocket/dungeon/swampgob/procedural/broken_test
	id = "_procedural_broken_test"
	name = "Broken procedural test room"
	procedural_recipe = "no_such_recipe"
	production_eligible = FALSE

/datum/unit_test/procedural_dungeon_integration
	needs_pocket_space = TRUE
	abstract_type = /datum/unit_test/procedural_dungeon_integration
	var/list/datum/pocket_dimension/dungeon/created_rooms = list()

/datum/unit_test/procedural_dungeon_integration/Destroy()
	for(var/datum/pocket_dimension/dungeon/room as anything in created_rooms)
		if(!QDELETED(room))
			SSpocket_dimensions.delete_instance(room, null, run_loc_floor_bottom_left)
	created_rooms = null
	return ..()

/datum/unit_test/procedural_dungeon_integration/layout_and_clear/Run()
	var/list/recipe_templates = list(
		/datum/map_template/pocket/dungeon/swampgob/procedural/root_ring,
		/datum/map_template/pocket/dungeon/swampgob/procedural/split_hall,
		/datum/map_template/pocket/dungeon/swampgob/procedural/crossing,
	)
	var/datum/dungeon_run/run = allocate(/datum/dungeon_run, null, DUNGEON_THEME_SWAMPGOB)
	run.floor = 1
	run.floor_config = get_dungeon_floor_config(1)
	for(var/template_type in recipe_templates)
		var/datum/map_template/pocket/dungeon/swampgob/procedural/template = allocate(template_type)
		var/datum/map_template/pocket/registered_template = SSpocket_dimensions.resolve_template(template.id)
		if(registered_template?.type != template_type)
			return Fail("Procedural room [template_type] did not register in the dungeon template pool.")
		var/datum/pocket_dimension/dungeon/room = run.create_room_instance(template, 1, room_seed = 413)
		if(!room)
			return Fail("Procedural room [template_type] failed to load.")
		created_rooms += room
		if(!istype(room, /datum/pocket_dimension/dungeon/procedural))
			return Fail("Procedural room [template_type] did not use its instance subtype.")
		var/datum/pocket_dimension/dungeon/procedural/generated = room
		var/datum/dungeon_room_plan/plan = generated.procedural_plan
		if(!plan || plan.seed != 413 || plan.recipe != template.procedural_recipe)
			return Fail("Procedural room [template_type] lost its selected seed or recipe.")
		if(length(room.entry_turfs) != 1 || room.get_entry_turf() != plan.get_turf_for_index(room.load_turf, plan.entry_index))
			return Fail("Procedural room [template_type] has an unsafe or misplaced entry.")
		if(length(room.exit_objects))
			return Fail("Procedural combat room [template_type] created a misleading exit seam.")
		if(length(room.affected_turfs) != 361)
			return Fail("Procedural room [template_type] did not own its full 19x19 footprint.")
		for(var/index in 1 to 361)
			var/turf/actual = plan.get_turf_for_index(room.load_turf, index)
			if(!room.contains_turf(actual))
				return Fail("Procedural room [template_type] lost ownership of cell [index].")
			switch(plan.cells[index])
				if("wall")
					if(!actual.density)
						return Fail("Procedural wall [index] in [template_type] is passable.")
				if("water")
					if(!istype(actual, /turf/open/water/swamp))
						return Fail("Procedural water [index] in [template_type] was not built.")
				if("floor", "grass", "cobble")
					if(actual.density)
						return Fail("Procedural floor [index] in [template_type] is blocked.")
			if(plan.cells[index] == "grass" && !istype(actual, /turf/open/floor/grass))
				return Fail("Procedural grass bank [index] was not built.")
			if(plan.cells[index] == "cobble" && !istype(actual, /turf/open/floor/cobblerock/alt))
				return Fail("Procedural stone threshold [index] was not built.")
		for(var/index in plan.focal_slots)
			var/turf/bank = plan.get_turf_for_index(room.load_turf, index)
			var/obj/structure/flora/shroom_tree/tree = locate() in bank
			if(!tree || !istype(bank, /turf/open/floor/grass))
				return Fail("A tall mushroom is missing or rooted in water.")
		for(var/index in plan.light_slots)
			var/turf/spot = plan.get_turf_for_index(room.load_turf, index)
			var/obj/machinery/light/fueled/firebowl/brazier = locate() in spot
			if(!brazier?.on)
				return Fail("A procedural brazier failed to light.")

		if(!length(room.guardian_refs) || room.cleared)
			return Fail("Procedural combat room [template_type] did not start with live guardians.")
		var/list/mob/living/guardians = list()
		for(var/ref_key in room.guardian_refs)
			var/datum/weakref/guardian_ref = room.guardian_refs[ref_key]
			var/mob/living/guardian = guardian_ref.resolve()
			if(!guardian)
				return Fail("Procedural guardian in [template_type] disappeared before combat.")
			var/turf/spot = get_turf(guardian)
			var/slot = (spot.y - room.load_turf.y) * 19 + (spot.x - room.load_turf.x) + 1
			if(!(slot in plan.guardian_slots))
				return Fail("Procedural guardian in [template_type] spawned outside a safe slot.")
			guardians += guardian

		run.build_room_gates(room, null)
		var/forward_count = 0
		var/back_count = 0
		for(var/obj/structure/dungeon_gate/gate as anything in room.gates)
			switch(gate.gate_role)
				if(DUNGEON_GATE_FORWARD)
					forward_count++
					if(!gate.sealed)
						return Fail("A forward gate in [template_type] opened before its guardians fell.")
				if(DUNGEON_GATE_BACK)
					back_count++
					if(gate.sealed)
						return Fail("The back gate in [template_type] began sealed.")
		if(forward_count != 2 || back_count != 1)
			return Fail("Procedural room [template_type] produced [forward_count] forward and [back_count] back gates.")
		for(var/mob/living/guardian as anything in guardians)
			qdel(guardian)
		if(!room.cleared)
			return Fail("Procedural room [template_type] did not clear after its last guardian died.")
		for(var/obj/structure/dungeon_gate/gate as anything in room.gates)
			if(gate.gate_role == DUNGEON_GATE_FORWARD && gate.sealed)
				return Fail("A forward gate in [template_type] stayed sealed after combat.")

/datum/unit_test/procedural_dungeon_integration/population_modes/Run()
	var/datum/map_template/pocket/dungeon/swampgob/procedural/root_ring/template = allocate(/datum/map_template/pocket/dungeon/swampgob/procedural/root_ring)
	var/datum/dungeon_run/run = allocate(/datum/dungeon_run, null, DUNGEON_THEME_SWAMPGOB)
	run.floor = 1
	run.floor_config = get_dungeon_floor_config(1)
	var/datum/pocket_dimension/dungeon/wave_room = run.create_room_instance(template, 1, population_mode = DUNGEON_POP_WAVES, room_seed = 743)
	if(!wave_room)
		return Fail("Wave room failed to load from a procedural template.")
	created_rooms += wave_room
	if(!istype(wave_room, /datum/pocket_dimension/dungeon/procedural))
		return Fail("Wave room fell back instead of generating its layout.")
	if(!length(wave_room.guardian_refs) || wave_room.pending_waves < 1)
		return Fail("Procedural wave room did not start with its first encounter.")
	var/datum/pocket_dimension/dungeon/procedural/wave_generated = wave_room
	for(var/ref_key in wave_room.guardian_refs)
		var/datum/weakref/guardian_ref = wave_room.guardian_refs[ref_key]
		var/mob/living/guardian = guardian_ref.resolve()
		var/turf/spot = get_turf(guardian)
		var/slot = (spot.y - wave_room.load_turf.y) * 19 + (spot.x - wave_room.load_turf.x) + 1
		if(!(slot in wave_generated.procedural_plan.guardian_slots))
			return Fail("A procedural wave guardian spawned outside its reserved slots.")
	var/datum/pocket_dimension/dungeon/peaceful_room = run.create_room_instance(template, 1, population_mode = DUNGEON_POP_TRADER, room_seed = 744)
	if(!peaceful_room)
		return Fail("Trader room failed to load from a procedural template.")
	created_rooms += peaceful_room
	if(!istype(peaceful_room, /datum/pocket_dimension/dungeon/procedural))
		return Fail("Trader room fell back instead of generating its layout.")
	if(length(peaceful_room.guardian_refs) || !peaceful_room.cleared)
		return Fail("Procedural trader room spawned guardians or stayed combat-locked.")
	if(length(peaceful_room.exit_objects))
		return Fail("Procedural trader room created an exit seam inside the run.")
	// Every later wave must also use safe slots and eventually release the room.
	for(var/wave in 1 to DUNGEON_WAVE_COUNT)
		for(var/ref_key in wave_room.guardian_refs.Copy())
			var/datum/weakref/guardian_ref = wave_room.guardian_refs[ref_key]
			var/mob/living/guardian = guardian_ref.resolve()
			if(!guardian)
				return Fail("Wave [wave] lost a registered guardian.")
			var/turf/spot = get_turf(guardian)
			var/slot = (spot.y - wave_room.load_turf.y) * 19 + (spot.x - wave_room.load_turf.x) + 1
			if(!(slot in wave_generated.procedural_plan.guardian_slots))
				return Fail("Wave [wave] spawned outside reserved positions.")
			qdel(guardian)
	if(!wave_room.cleared || wave_room.pending_waves)
		return Fail("Procedural waves did not finish and clear the room.")

/datum/unit_test/procedural_dungeon_integration/fallback/Run()
	var/datum/map_template/pocket/dungeon/swampgob/procedural/broken_test/broken = allocate(/datum/map_template/pocket/dungeon/swampgob/procedural/broken_test)
	var/datum/dungeon_run/run = allocate(/datum/dungeon_run, null, DUNGEON_THEME_SWAMPGOB)
	run.floor = 1
	run.floor_config = get_dungeon_floor_config(1)
	var/datum/pocket_dimension/dungeon/room = run.create_room_instance(broken, 1, room_seed = 51)
	if(!room)
		return Fail("An invalid procedural recipe did not recover with an authored room.")
	created_rooms += room
	var/datum/map_template/pocket/dungeon/selected = room.get_dungeon_template()
	if(istype(room, /datum/pocket_dimension/dungeon/procedural) || !selected || selected.procedural_recipe)
		return Fail("An invalid plan did not switch to an authored dungeon room.")
	if(selected.theme != DUNGEON_THEME_SWAMPGOB || selected.room_kind != DUNGEON_ROOM_COMBAT)
		return Fail("The fallback changed the promised theme or room kind.")
	if(length(room.exit_objects))
		return Fail("The fallback combat room created an exit seam.")
	var/obj/structure/dungeon_gate/gate = allocate(/obj/structure/dungeon_gate, room.get_entry_turf())
	gate.source_room = room
	gate.owning_run = run
	gate.pre_rolled_template = broken
	gate.generation_seed = 51
	var/datum/pocket_dimension/dungeon/destination = run.instantiate_room_for_gate(gate)
	if(!destination)
		return Fail("A forward gate failed to recover with an authored room.")
	created_rooms += destination
	var/datum/map_template/pocket/dungeon/actual_template = destination.get_dungeon_template()
	if(gate.pre_rolled_template != actual_template || !(actual_template.id in run.recent_template_ids))
		return Fail("Fallback gate hints and recent-room history must use the actual destination template.")

/datum/unit_test/procedural_dungeon_traversal
	needs_pocket_space = TRUE

/datum/unit_test/procedural_dungeon_traversal/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	PROCEDURAL_ASSERT(entrance.try_enter(delver), "The test delver should enter the run.")
	var/datum/dungeon_run/run = entrance.active_run
	var/datum/pocket_dimension/dungeon/landing = run.current_break_room
	var/obj/structure/dungeon_gate/forward
	for(var/obj/structure/dungeon_gate/gate as anything in landing.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward = gate
			break
	PROCEDURAL_ASSERT_NOTNULL(forward, "Landing needs a forward gate.")
	forward.pre_rolled_template = SSpocket_dimensions.resolve_template("swampgob_procedural_root_ring")
	forward.generation_seed = 413
	forward.special_kind = null
	PROCEDURAL_ASSERT(forward.use_gate(delver), "The party should traverse into a generated room.")
	var/datum/pocket_dimension/dungeon/procedural/room = forward.destination_room
	PROCEDURAL_ASSERT(istype(room), "The generated template must use its own pocket subtype.")
	PROCEDURAL_ASSERT_EQUAL(room.procedural_plan.seed, 413, "The gate must preserve its layout seed.")
	var/datum/dungeon_room_plan/plan = room.procedural_plan
	var/obj/structure/dungeon_gate/back
	var/obj/structure/dungeon_gate/onward
	for(var/obj/structure/dungeon_gate/gate as anything in room.gates)
		if(gate.gate_role == DUNGEON_GATE_BACK)
			back = gate
		else if(gate.gate_role == DUNGEON_GATE_FORWARD)
			onward = gate
	PROCEDURAL_ASSERT_NOTNULL(back, "Generated room needs a backtracking gate.")
	PROCEDURAL_ASSERT(back.use_gate(delver), "Backtracking should remain available during combat.")
	PROCEDURAL_ASSERT(landing.contains_turf(get_turf(delver)), "Backtracking should return to the landing.")
	PROCEDURAL_ASSERT(forward.use_gate(delver), "The party should be able to re-enter the same room.")
	PROCEDURAL_ASSERT_EQUAL(forward.destination_room, room, "Re-entry must not reroll the room.")
	PROCEDURAL_ASSERT_EQUAL(room.procedural_plan, plan, "Re-entry must reuse the existing plan.")
	for(var/ref_key in room.guardian_refs.Copy())
		var/datum/weakref/guardian_ref = room.guardian_refs[ref_key]
		qdel(guardian_ref.resolve())
	PROCEDURAL_ASSERT(room.cleared, "Clearing the guardians should open onward travel.")
	PROCEDURAL_ASSERT_NOTNULL(onward, "Generated room needs an onward gate.")
	onward.special_kind = null
	onward.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_break")
	PROCEDURAL_ASSERT(onward.use_gate(delver), "The party should reach the next break room.")
	PROCEDURAL_ASSERT(QDELETED(room), "The previous generated room must retire at the break.")
	PROCEDURAL_ASSERT(QDELETED(plan), "Retiring a room must release its generation plan.")
	PROCEDURAL_ASSERT(run.current_break_room.contains_turf(get_turf(delver)), "The delver must survive retirement in the new break room.")
	qdel(run)
	PROCEDURAL_ASSERT_EQUAL(get_turf(delver), get_turf(entrance), "Run teardown should return the delver to the entrance.")

#undef PROCEDURAL_ASSERT
#undef PROCEDURAL_ASSERT_NOTNULL
#undef PROCEDURAL_ASSERT_EQUAL
#endif
