/datum/unit_test/dungeon_onebite
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_onebite/Run()
	var/mob/living/carbon/human/raider = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/origin = run_loc_floor_bottom_left

	var/datum/pocket_dimension/dungeon/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::onebite", /datum/map_template/pocket/dungeon/test_onebite, POCKET_LIFECYCLE_COLLAPSE, 0)
	TEST_ASSERT_NOTNULL(instance, "One-bite dungeon instance should be created.")
	TEST_ASSERT(istype(instance, /datum/pocket_dimension/dungeon), "Instance should use the dungeon subtype via instance_type.")
	TEST_ASSERT(!instance.cleared, "Dungeon with a guardian should not start cleared.")
	TEST_ASSERT_EQUAL(length(instance.guardian_refs), 1, "Guardian landmark should have produced exactly one tracked guardian.")
	TEST_ASSERT_EQUAL(length(instance.loot_caches), 1, "Loot landmark should have produced exactly one cache.")

	var/obj/structure/dungeon_loot_cache/cache = instance.loot_caches[1]
	TEST_ASSERT(cache.locked, "Reward cache should start sealed.")

	TEST_ASSERT(instance.enter_mob(raider, origin), "Dungeon should accept a mob entry.")
	TEST_ASSERT(instance.contains_turf(get_turf(raider)), "Raider should be inside the dungeon.")

	var/mob/living/guardian
	for(var/guardian_ref in instance.guardian_refs)
		var/datum/weakref/ref = instance.guardian_refs[guardian_ref]
		guardian = ref.resolve()
	TEST_ASSERT_NOTNULL(guardian, "Tracked guardian weakref should resolve.")

	guardian.death()
	TEST_ASSERT(instance.cleared, "Dungeon should clear when its last guardian dies.")
	TEST_ASSERT(!cache.locked, "Reward cache should unlock on clear.")

	TEST_ASSERT(instance.exit_mob(raider), "Raider should be able to leave the cleared one-bite dungeon.")
	TEST_ASSERT_EQUAL(get_turf(raider), origin, "Normal exit should return the raider to the entrance.")
	var/obj/item/weapon/knife/keepsake = allocate(/obj/item/weapon/knife, instance.get_entry_turf())
	instance.last_touched = world.time - instance.idle_timeout - 1
	TEST_ASSERT(instance.process_idle_lifecycle(), "A cleared standalone room should collapse despite its native guardian corpse.")
	TEST_ASSERT(QDELETED(instance), "Idle collapse should delete the spent standalone room.")
	TEST_ASSERT(QDELETED(guardian), "Dead native guardian must be deleted on collapse, not ejected.")
	TEST_ASSERT_EQUAL(get_turf(keepsake), origin, "Foreign items left in a standalone room must be ejected on collapse.")

/datum/unit_test/dungeon_native_mobs_die_on_collapse
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_native_mobs_die_on_collapse/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/datum/pocket_dimension/dungeon/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::collapse", /datum/map_template/pocket/dungeon/test_onebite, POCKET_LIFECYCLE_COLLAPSE, 0)
	TEST_ASSERT_NOTNULL(instance, "Collapse-test dungeon instance should be created.")

	var/mob/living/guardian
	for(var/guardian_ref in instance.guardian_refs)
		var/datum/weakref/ref = instance.guardian_refs[guardian_ref]
		guardian = ref.resolve()
	TEST_ASSERT_NOTNULL(guardian, "Guardian should exist before collapse.")

	// Collapse with the guardian still alive - it must be deleted, never ejected.
	TEST_ASSERT(SSpocket_dimensions.delete_instance(instance, null, origin), "Dungeon should collapse with a live guardian inside.")
	TEST_ASSERT(QDELETED(guardian), "Live native guardian must be deleted on collapse, not ejected.")

/datum/unit_test/dungeon_defeated_guardian_clears_room
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_defeated_guardian_clears_room/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/datum/pocket_dimension/dungeon/instance = SSpocket_dimensions.get_or_create_instance("[REF(src)]::defeated_guardian", /datum/map_template/pocket/dungeon/test_onebite, POCKET_LIFECYCLE_COLLAPSE, 0)
	TEST_ASSERT_NOTNULL(instance, "Defeat-test dungeon instance should be created.")

	var/mob/living/guardian
	for(var/guardian_ref in instance.guardian_refs)
		var/datum/weakref/ref = instance.guardian_refs[guardian_ref]
		guardian = ref.resolve()
	TEST_ASSERT_NOTNULL(guardian, "Defeat-test guardian should resolve.")

	SEND_SIGNAL(guardian, COMSIG_LIVING_DEFEATED)
	TEST_ASSERT(!instance.cleared, "A defeat signal without a defeat status must not clear the room.")
	guardian.apply_status_effect(/datum/status_effect/mob_horny_knockout)
	TEST_ASSERT(instance.cleared, "A guardian with a defeat status should clear the room without dying.")

	SSpocket_dimensions.delete_instance(instance, null, origin)

/datum/unit_test/dungeon_drow_theme_harness
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_drow_theme_harness/Run()
	var/list/expected_rooms = list(
		"drow_break_veiled_refuge" = list("kind" = DUNGEON_ROOM_BREAK),
		"drow_descent_umbra_gate" = list("kind" = DUNGEON_ROOM_DESCENT),
		"drow_combat_silk_antechamber" = list("kind" = DUNGEON_ROOM_COMBAT),
		"drow_combat_slave_pens" = list("kind" = DUNGEON_ROOM_COMBAT),
		"drow_combat_webbed_gallery" = list("kind" = DUNGEON_ROOM_COMBAT),
		"drow_combat_fungal_reservoir" = list("kind" = DUNGEON_ROOM_COMBAT),
		"drow_combat_blade_chapel" = list("kind" = DUNGEON_ROOM_COMBAT),
		"drow_combat_matron_gauntlet" = list("kind" = DUNGEON_ROOM_COMBAT),
		"drow_boss_widows_court" = list("kind" = DUNGEON_ROOM_BOSS),
	)
	var/list/kind_counts = list(
		DUNGEON_ROOM_BREAK = 0,
		DUNGEON_ROOM_DESCENT = 0,
		DUNGEON_ROOM_COMBAT = 0,
		DUNGEON_ROOM_BOSS = 0,
	)
	var/turf/origin = run_loc_floor_bottom_left

	for(var/template_id in expected_rooms)
		var/list/expected = expected_rooms[template_id]
		var/datum/map_template/pocket/dungeon/template = SSpocket_dimensions.resolve_template(template_id)
		TEST_ASSERT_NOTNULL(template, "Drow Dungeon room [template_id] should register.")
		TEST_ASSERT(template.production_eligible, "Drow Dungeon room [template_id] must be production eligible.")
		TEST_ASSERT_EQUAL(template.theme, DUNGEON_THEME_DROW, "Drow Dungeon room [template_id] has the wrong theme.")
		TEST_ASSERT_EQUAL(template.room_kind, expected["kind"], "Drow Dungeon room [template_id] has the wrong room kind.")
		TEST_ASSERT(template.width > 0, "Drow Dungeon room [template_id] should expose its authored width.")
		TEST_ASSERT(template.height > 0, "Drow Dungeon room [template_id] should expose its authored height.")
		kind_counts[template.room_kind]++

		var/datum/pocket_dimension/dungeon/room = SSpocket_dimensions.get_or_create_instance("[REF(src)]::[template_id]", template.type, POCKET_LIFECYCLE_COLLAPSE, 0)
		TEST_ASSERT_NOTNULL(room, "Drow Dungeon room [template_id] should load as a pocket instance.")
		TEST_ASSERT_EQUAL(length(room.entry_turfs), 1, "Drow Dungeon room [template_id] should have one authored entry.")
		var/forward_gate_count = 0
		var/back_gate_count = 0
		for(var/list/gate_info as anything in room.gate_landmark_info)
			switch(gate_info["role"])
				if(DUNGEON_GATE_FORWARD)
					forward_gate_count++
				if(DUNGEON_GATE_BACK)
					back_gate_count++
		TEST_ASSERT(forward_gate_count >= 1, "Drow Dungeon room [template_id] needs a forward route.")
		if(template.room_kind != DUNGEON_ROOM_BREAK && template.room_kind != DUNGEON_ROOM_DESCENT)
			TEST_ASSERT(back_gate_count >= 1, "Drow Dungeon hostile room [template_id] needs a back route.")
		for(var/turf/room_turf as anything in room.affected_turfs)
			TEST_ASSERT(istype(get_area(room_turf), /area/pocket_dimension/dungeon), "Every turf in [template_id] must use the dungeon pocket area.")
		TEST_ASSERT(SSpocket_dimensions.delete_instance(room, null, origin), "Drow Dungeon room [template_id] should collapse cleanly after validation.")

	TEST_ASSERT_EQUAL(kind_counts[DUNGEON_ROOM_BREAK], 1, "Drow Dungeon should ship exactly one mandatory break room.")
	TEST_ASSERT_EQUAL(kind_counts[DUNGEON_ROOM_DESCENT], 1, "Drow Dungeon should ship exactly one mandatory descent room.")
	TEST_ASSERT_EQUAL(kind_counts[DUNGEON_ROOM_COMBAT], 6, "Drow Dungeon should ship six combat rooms.")
	TEST_ASSERT_EQUAL(kind_counts[DUNGEON_ROOM_BOSS], 1, "Drow Dungeon should ship exactly one mandatory boss room.")

	var/datum/dungeon_floor_config/drow_floor = get_dungeon_floor_config(3)
	TEST_ASSERT(DUNGEON_THEME_DROW in drow_floor.themes, "Floor 3 should begin the Drow Dungeon sequence.")
	TEST_ASSERT(length(drow_floor.combat_mob_pool) >= 4, "Drow Dungeon floors need their themed encounter roster.")
	TEST_ASSERT(length(drow_floor.boss_pool) >= 2, "Drow Dungeon floors need a usable boss roster.")
	var/datum/dungeon_floor_config/deep_drow_floor = get_dungeon_floor_config(5)
	TEST_ASSERT(DUNGEON_THEME_DROW in deep_drow_floor.themes, "Floor 5 should remain in the Drow Dungeon theme.")

	var/datum/map_template/pocket/dungeon/drow_loot_template = SSpocket_dimensions.resolve_template("drow_combat_silk_antechamber")
	TEST_ASSERT_EQUAL(drow_loot_template.get_loot_table_type(1), /datum/loot_table/dungeon/drow/tier1, "Shallow Drow rooms should use their tier-1 cache table.")
	TEST_ASSERT_EQUAL(drow_loot_template.get_loot_table_type(3), /datum/loot_table/dungeon/drow/tier2, "Floors 3-4 should use the mid-tier Drow cache table.")
	TEST_ASSERT_EQUAL(drow_loot_template.get_loot_table_type(5), /datum/loot_table/dungeon/drow/tier3, "Floor 5 and beyond should use the deep Drow cache table.")

	var/datum/loot_table/dungeon/tier1/generic_tier1 = new
	var/datum/loot_table/dungeon/drow/tier1/drow_tier1 = new
	TEST_ASSERT(drow_tier1.donor_types[/datum/loot_table/potion_vitals] < generic_tier1.donor_types[/datum/loot_table/potion_vitals], "Shallow Drow caches should make vital potions rarer than generic tier 1.")
	qdel(generic_tier1)
	qdel(drow_tier1)

	var/datum/loot_table/dungeon/tier2/generic_tier2 = new
	var/datum/loot_table/dungeon/drow/tier2/drow_tier2 = new
	TEST_ASSERT(drow_tier2.donor_types[/datum/loot_table/potion_vitals] < generic_tier2.donor_types[/datum/loot_table/potion_vitals], "Mid-tier Drow caches should make vital potions rarer than generic tier 2.")
	TEST_ASSERT(drow_tier2.donor_types[/datum/loot_table/potion_stats] < generic_tier2.donor_types[/datum/loot_table/potion_stats], "Mid-tier Drow caches should make stat potions rarer than generic tier 2.")
	qdel(generic_tier2)
	qdel(drow_tier2)

	var/datum/loot_table/dungeon/tier3/generic_tier3 = new
	var/datum/loot_table/dungeon/drow/tier3/drow_tier3 = new
	TEST_ASSERT(drow_tier3.donor_types[/datum/loot_table/potion_stats] < generic_tier3.donor_types[/datum/loot_table/potion_stats], "Deep Drow caches should make stat potions rarer than generic tier 3.")
	qdel(generic_tier3)
	qdel(drow_tier3)

	// Floor transitions are pre-rolled before advance_floor() commits. Verify the
	// floor-2 break points into the new set and that its landing points onward
	// into Drow combat rather than retaining the Warrens theme.
	var/datum/dungeon_run/transition_run = new(null, DUNGEON_THEME_SWAMPGOB)
	transition_run.floor = 2
	transition_run.floor_config = get_dungeon_floor_config(2)
	transition_run.boss_defeated_this_floor = TRUE
	var/datum/pocket_dimension/dungeon/transition_break = SSpocket_dimensions.get_or_create_instance("[REF(src)]::drow_transition_break", /datum/map_template/pocket/dungeon/swampgob/break_hollow, POCKET_LIFECYCLE_COLLAPSE, 0)
	var/datum/map_template/pocket/dungeon/next_descent = transition_run.roll_next_room_template(transition_break)
	TEST_ASSERT_NOTNULL(next_descent, "The floor-2 break should find a descent template for floor 3.")
	TEST_ASSERT_EQUAL(next_descent.theme, DUNGEON_THEME_DROW, "The floor-2 break should pre-roll a Drow Dungeon descent for floor 3.")
	TEST_ASSERT_EQUAL(next_descent.room_kind, DUNGEON_ROOM_DESCENT, "The Drow floor transition should retain the mandatory descent room kind.")
	TEST_ASSERT(SSpocket_dimensions.delete_instance(transition_break, null, origin), "The transition break fixture should collapse cleanly.")

	var/datum/pocket_dimension/dungeon/transition_descent = SSpocket_dimensions.get_or_create_instance("[REF(src)]::drow_transition_descent", /datum/map_template/pocket/dungeon/drow/descent_umbra_gate, POCKET_LIFECYCLE_COLLAPSE, 0)
	var/datum/map_template/pocket/dungeon/next_combat = transition_run.roll_next_room_template(transition_descent)
	TEST_ASSERT_NOTNULL(next_combat, "The Drow landing should find a combat template for its stretch.")
	TEST_ASSERT_EQUAL(next_combat.theme, DUNGEON_THEME_DROW, "The pre-advance Drow landing should pre-roll Drow combat rooms.")
	TEST_ASSERT_EQUAL(next_combat.room_kind, DUNGEON_ROOM_COMBAT, "The Drow landing should lead into a combat stretch.")
	TEST_ASSERT(SSpocket_dimensions.delete_instance(transition_descent, null, origin), "The transition descent fixture should collapse cleanly.")
	qdel(transition_run)

/datum/unit_test/dungeon_singlet_production_harnesses
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_singlet_production_harnesses/Run()
	var/list/production_pool = get_dungeon_template_pool(DUNGEON_ROOM_ONESHOT)
	TEST_ASSERT(length(production_pool) >= 6, "The production one-shot pool should contain the shipped singlet set.")
	for(var/datum/map_template/pocket/dungeon/pooled_template as anything in production_pool)
		TEST_ASSERT(pooled_template.production_eligible, "Broad one-shot pools must never contain a test-only template ([pooled_template.id]).")

	// Guardian counts mirror each template's .dmm landmarks - update both together.
	var/list/harnesses = list(
		/obj/structure/dungeon_entrance/bandit_hideout = list("template_id" = "singlet_bandit_hideout", "guardians" = 4, "guardian_type" = /mob/living/carbon/human/species/human/northern/bum/ambush),
		/obj/structure/dungeon_entrance/bear_den = list("template_id" = "singlet_bear_den", "guardians" = 1, "guardian_type" = /mob/living/simple_animal/hostile/retaliate/direbear),
		/obj/structure/dungeon_entrance/ratfolk_camp = list("template_id" = "singlet_ratfolk_camp", "guardians" = 5, "guardian_type" = /mob/living/carbon/human/species/rousman/ambush),
		/obj/structure/dungeon_entrance/spider_nursery = list("template_id" = "singlet_spider_nursery", "guardians" = 3, "guardian_type" = /mob/living/simple_animal/hostile/retaliate/spider),
		/obj/structure/dungeon_entrance/werewolf_shrine = list("template_id" = "singlet_werewolf_shrine", "guardians" = 1, "guardian_type" = /mob/living/simple_animal/hostile/werewolf),
		/obj/structure/dungeon_entrance/wolf_den = list("template_id" = "singlet_wolf_den", "guardians" = 3, "guardian_type" = /mob/living/simple_animal/hostile/retaliate/wolf),
	)
	var/turf/origin = run_loc_floor_bottom_left
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, origin)
	for(var/entrance_type in harnesses)
		var/list/harness = harnesses[entrance_type]
		var/datum/map_template/pocket/dungeon/expected_template = SSpocket_dimensions.resolve_template(harness["template_id"])
		TEST_ASSERT_NOTNULL(expected_template, "Shipped singlet template [harness["template_id"]] should register.")
		TEST_ASSERT(expected_template.production_eligible, "Shipped singlet [expected_template.id] must be production eligible.")
		TEST_ASSERT_EQUAL(expected_template.width, 15, "Singlet [expected_template.id] should retain its authored width.")
		TEST_ASSERT_EQUAL(expected_template.height, 15, "Singlet [expected_template.id] should retain its authored height.")

		var/obj/structure/dungeon_entrance/entrance = allocate(entrance_type, origin)
		var/datum/pocket_dimension/dungeon/room = entrance.get_entry_room(delver)
		TEST_ASSERT_NOTNULL(room, "[entrance] should instantiate its themed singlet.")
		TEST_ASSERT_EQUAL(room.get_dungeon_template(), expected_template, "[entrance] should resolve only its matching themed template in the current set.")
		TEST_ASSERT_EQUAL(length(room.entry_turfs), 1, "Singlet [expected_template.id] should have one authored entry.")
		TEST_ASSERT_EQUAL(length(room.exit_objects), 1, "Singlet [expected_template.id] should build one return seam.")
		TEST_ASSERT_EQUAL(length(room.guardian_refs), harness["guardians"], "Singlet [expected_template.id] should spawn its authored guardian count.")
		TEST_ASSERT_EQUAL(length(room.loot_caches), 1, "Singlet [expected_template.id] should build one sealed reward cache.")
		TEST_ASSERT(room.loot_caches[1].locked, "Singlet [expected_template.id]'s reward should begin sealed.")
		for(var/guardian_ref in room.guardian_refs)
			var/datum/weakref/guardian_weakref = room.guardian_refs[guardian_ref]
			var/mob/living/guardian = guardian_weakref.resolve()
			TEST_ASSERT(istype(guardian, harness["guardian_type"]), "Singlet [expected_template.id] spawned the wrong guardian type.")
		for(var/turf/room_turf as anything in room.affected_turfs)
			TEST_ASSERT(istype(get_area(room_turf), /area/pocket_dimension/dungeon), "Every turf in [expected_template.id] must use the dungeon pocket area.")

		TEST_ASSERT(entrance.try_enter(delver), "[entrance] should admit a delver through normal one-shot interaction.")
		TEST_ASSERT(room.contains_turf(get_turf(delver)), "[entrance] should deliver the delver into its room.")
		TEST_ASSERT(room.exit_mob(delver), "The return seam in [expected_template.id] should work.")
		TEST_ASSERT_EQUAL(get_turf(delver), origin, "The return seam in [expected_template.id] should lead back to its entrance.")
		qdel(entrance)

/datum/unit_test/dungeon_singlet_shared_lifecycle_and_cooldown
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_singlet_shared_lifecycle_and_cooldown/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/obj/structure/dungeon_entrance/wolf_den/entrance = allocate(/obj/structure/dungeon_entrance/wolf_den, origin)
	var/mob/living/carbon/human/first_delver = allocate(/mob/living/carbon/human, origin)
	var/mob/living/carbon/human/second_delver = allocate(/mob/living/carbon/human, origin)
	first_delver.mind_initialize()
	second_delver.mind_initialize()

	TEST_ASSERT(entrance.try_enter(first_delver), "The first delver should enter the wolf singlet.")
	var/datum/pocket_dimension/dungeon/room = SSpocket_dimensions.get_instance(entrance.get_instance_key())
	TEST_ASSERT_NOTNULL(room, "The first entry should create a keyed singlet room.")
	TEST_ASSERT(entrance.try_enter(second_delver), "The second delver should enter the existing wolf singlet.")
	TEST_ASSERT_EQUAL(SSpocket_dimensions.get_instance(entrance.get_instance_key()), room, "Both delvers must share the one room keyed to their entrance.")

	for(var/guardian_ref in room.guardian_refs.Copy())
		var/datum/weakref/guardian_weakref = room.guardian_refs[guardian_ref]
		var/mob/living/guardian = guardian_weakref.resolve()
		if(guardian)
			qdel(guardian)
	TEST_ASSERT(room.cleared, "Removing every guardian should clear the shared singlet.")

	TEST_ASSERT(room.exit_mob(first_delver), "The first delver should be able to leave.")
	room.last_touched = world.time - room.idle_timeout - 1
	TEST_ASSERT(!room.process_idle_lifecycle(), "One delver leaving must not collapse the room under the other.")
	TEST_ASSERT(!QDELETED(room), "The shared room must remain while its second delver is inside.")

	var/obj/item/weapon/knife/keepsake = allocate(/obj/item/weapon/knife, room.get_entry_turf())
	TEST_ASSERT(room.exit_mob(second_delver), "The second delver should be able to leave.")
	room.last_touched = world.time - room.idle_timeout - 1
	var/first_instance_id = room.instance_id
	TEST_ASSERT(room.process_idle_lifecycle(), "The cleared room should collapse after its last delver leaves.")
	TEST_ASSERT(QDELETED(room), "The spent shared room should be deleted.")
	TEST_ASSERT_EQUAL(get_turf(keepsake), origin, "A foreign item left in the singlet should return to the entrance.")
	TEST_ASSERT(entrance.is_dormant(), "Lifecycle collapse should arm the entrance cooldown.")
	TEST_ASSERT_NULL(entrance.get_entry_room(first_delver), "A dormant entrance must refuse to reopen early.")

	entrance.dormant_until = world.time
	var/datum/pocket_dimension/dungeon/fresh_room = entrance.get_entry_room(first_delver)
	TEST_ASSERT_NOTNULL(fresh_room, "The entrance should roll a fresh room after its cooldown.")
	TEST_ASSERT_NOTEQUAL(fresh_room.instance_id, first_instance_id, "A reopened entrance must not reuse its spent instance.")
	qdel(entrance)

/datum/unit_test/dungeon_singlet_entrance_deletion_ejects_occupants
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_singlet_entrance_deletion_ejects_occupants/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/obj/structure/dungeon_entrance/spider_nursery/entrance = allocate(/obj/structure/dungeon_entrance/spider_nursery, origin)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, origin)
	TEST_ASSERT(entrance.try_enter(delver), "The delver should enter before the entrance is removed.")
	var/datum/pocket_dimension/dungeon/room = SSpocket_dimensions.get_instance(entrance.get_instance_key())
	TEST_ASSERT_NOTNULL(room, "The entrance should own a live room before deletion.")

	qdel(entrance)
	TEST_ASSERT(QDELETED(room), "Deleting a singlet entrance should tear down its keyed room.")
	TEST_ASSERT_EQUAL(get_turf(delver), origin, "Deleting an occupied entrance should eject its delver safely to the entrance turf.")

/datum/unit_test/dungeon_infinite_run
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_infinite_run/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize() // gates refuse mindless mobs (dungeon natives), so the test delver needs a mind

	TEST_ASSERT(entrance.try_enter(delver), "Infinite entrance should accept a delver.")
	var/datum/dungeon_run/run = entrance.active_run
	TEST_ASSERT_NOTNULL(run, "Entering an infinite entrance should create a run.")
	run.stretch_length = 1 // shorten the stretch so the test reaches a second break room fast

	var/datum/pocket_dimension/dungeon/first_break = run.current_break_room
	TEST_ASSERT_NOTNULL(first_break, "Run should have a starting break room.")
	TEST_ASSERT(first_break.cleared, "A guardian-less break room should be auto-cleared.")
	TEST_ASSERT(first_break.contains_turf(get_turf(delver)), "Delver should be inside the break room.")

	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in first_break.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	TEST_ASSERT_NOTNULL(forward_gate, "Break room should have a forward gate.")
	TEST_ASSERT(!forward_gate.sealed, "Forward gates in a cleared room should be open.")

	// stretch_length was shortened after the break room's gates pre-rolled their
	// templates against the default length, so re-roll them for the test.
	forward_gate.pre_rolled_template = run.roll_next_room_template(first_break)
	TEST_ASSERT_NOTNULL(forward_gate.pre_rolled_template, "Forward gate should have a pre-rolled template.")

	// Drag-through: bring a foreign object along.
	var/obj/item/storage/backpack/cargo = allocate(/obj/item/storage/backpack, get_turf(delver))
	delver.start_pulling(cargo)
	TEST_ASSERT_EQUAL(delver.pulling, cargo, "Delver should be pulling the cargo before the gate.")
	TEST_ASSERT(forward_gate.use_gate(delver), "Open forward gate should transfer the delver.")

	var/datum/pocket_dimension/dungeon/combat_room = forward_gate.destination_room
	TEST_ASSERT_NOTNULL(combat_room, "Forward gate should have instantiated its room.")
	TEST_ASSERT(combat_room.contains_turf(get_turf(delver)), "Delver should be in the combat room.")
	TEST_ASSERT(combat_room.contains_turf(get_turf(cargo)), "Dragged cargo should cross the gate with the delver.")
	TEST_ASSERT_EQUAL(combat_room.depth, 1, "First combat room should be depth 1.")
	TEST_ASSERT(!combat_room.cleared, "Combat room with a guardian should not start cleared.")

	var/mob/living/guardian
	for(var/guardian_ref in combat_room.guardian_refs)
		var/datum/weakref/ref = combat_room.guardian_refs[guardian_ref]
		guardian = ref.resolve()
	TEST_ASSERT_NOTNULL(guardian, "Combat room guardian should resolve.")
	// enhance_mob feeds the affix system depth-1 (matching SSdungeon_generator),
	// so assert on its observable effects rather than the stored delve_level.
	TEST_ASSERT(length(guardian.affixes) >= 1, "Guardian should receive at least one affix from depth enhancement.")
	TEST_ASSERT(guardian.maxHealth > initial(guardian.maxHealth), "Guardian max health should be scaled up by depth enhancement.")

	var/obj/structure/dungeon_gate/next_gate
	for(var/obj/structure/dungeon_gate/gate as anything in combat_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			next_gate = gate
			break
	TEST_ASSERT_NOTNULL(next_gate, "Combat room should have a forward gate.")
	TEST_ASSERT(next_gate.sealed, "Forward gates should be sealed while guardians live.")
	TEST_ASSERT(!next_gate.use_gate(delver), "Sealed gate should refuse passage.")

	// qdel rather than death() so the clear is deterministic regardless of which
	// random affixes depth-enhancement rolled (some can interfere with death()).
	for(var/g_ref in combat_room.guardian_refs.Copy())
		var/datum/weakref/g_wr = combat_room.guardian_refs[g_ref]
		var/mob/living/g_mob = g_wr?.resolve()
		if(g_mob)
			qdel(g_mob)
	TEST_ASSERT(combat_room.cleared, "Combat room should clear when its guardians are gone.")
	TEST_ASSERT(!next_gate.sealed, "Forward gates should unseal on clear.")
	TEST_ASSERT_EQUAL(run.depth, 1, "Run depth should increment per cleared combat room.")
	TEST_ASSERT_NOTNULL(next_gate.pre_rolled_template, "Cleared combat room's forward gate should have a template.")
	// Stretch-end now caps with a boss room (Slice 3); this test exercises the
	// despawn-behind-party mechanic, so force the next room to a plain break room.
	next_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_break")

	TEST_ASSERT(next_gate.use_gate(delver), "Cleared forward gate should transfer the delver onward.")
	var/datum/pocket_dimension/dungeon/second_break = run.current_break_room
	TEST_ASSERT(second_break != first_break, "Reaching a new break room should advance the run.")
	TEST_ASSERT(second_break.contains_turf(get_turf(delver)), "Delver should be in the new break room.")
	TEST_ASSERT(QDELETED(first_break), "The old break room should despawn behind the party.")
	TEST_ASSERT(QDELETED(combat_room), "Cleared stretch rooms should despawn behind the party.")

	// The test mob has no client, so exercise run teardown directly.
	qdel(run)
	TEST_ASSERT_NULL(entrance.active_run, "Ending the run should clear the entrance's active run.")
	TEST_ASSERT(entrance.is_dormant(), "Entrance should go dormant after its run ends.")
	TEST_ASSERT(QDELETED(second_break), "Run teardown should delete remaining rooms.")
	TEST_ASSERT_EQUAL(get_turf(delver), get_turf(entrance), "Run teardown should eject the delver to the entrance.")

/datum/unit_test/dungeon_floor_descent
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_floor_descent/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()

	TEST_ASSERT(entrance.try_enter(delver), "Infinite entrance should accept a delver.")
	var/datum/dungeon_run/run = entrance.active_run
	TEST_ASSERT_NOTNULL(run, "Run should be created.")
	TEST_ASSERT_EQUAL(run.floor, 1, "Run should start on floor 1.")

	var/datum/pocket_dimension/dungeon/first_break = run.current_break_room
	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in first_break.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	TEST_ASSERT_NOTNULL(forward_gate, "Break room should have a forward gate.")

	// Force the next room to be a descent room so we can test the floor advance.
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_descent")
	forward_gate.gate_role = DUNGEON_GATE_DESCENT
	forward_gate.sealed = FALSE

	TEST_ASSERT(forward_gate.use_gate(delver), "Descent gate should transfer the delver.")
	TEST_ASSERT_EQUAL(run.floor, 2, "Crossing a descent room should advance to floor 2.")
	TEST_ASSERT(QDELETED(first_break), "The previous floor's break room should despawn on descent.")

	qdel(run)

/datum/unit_test/dungeon_solo_still_works
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_solo_still_works/Run()
	// Guards the foundation behavior: a lone, partyless delver can still run.
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "A partyless delver should still be able to enter.")
	var/datum/dungeon_run/run = entrance.active_run
	TEST_ASSERT_NOTNULL(run, "Solo entry should create a run.")
	TEST_ASSERT_NULL(run.get_party(), "Solo run should have no bound party.")
	var/mob/living/carbon/human/outsider = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	outsider.mind_initialize()
	TEST_ASSERT(!run.is_party_member(outsider), "A solo run must not fail open to an unrelated delver.")
	TEST_ASSERT_NULL(entrance.get_entry_room(outsider), "An unrelated delver must petition instead of entering a solo run directly.")

	var/datum/pocket_dimension/dungeon/break_room = run.current_break_room
	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "A solo delver should muster trivially and advance.")
	TEST_ASSERT(forward_gate.destination_room.contains_turf(get_turf(delver)), "Solo delver should have moved through.")

	qdel(run)

/datum/unit_test/dungeon_at_rest_state
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_at_rest_state/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Delver should enter.")
	var/datum/dungeon_run/run = entrance.active_run
	TEST_ASSERT(run.is_at_rest(), "A run sitting in its starting break room should report at rest.")

	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "Advance into the combat stretch.")
	TEST_ASSERT(!run.is_at_rest(), "With a live combat stretch room, the run should not be at rest.")

	qdel(run)

/datum/unit_test/dungeon_forced_entrant_lifecycle
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_forced_entrant_lifecycle/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the founding delver.")
	var/datum/dungeon_run/run = entrance.active_run
	var/datum/pocket_dimension/dungeon/room = run.current_break_room

	var/mob/living/carbon/human/captive = allocate(/mob/living/carbon/human, room.get_entry_turf())
	captive.mind_initialize()
	var/base_health = captive.maxHealth
	run.add_boon(new /datum/dungeon_boon/vigor)
	TEST_ASSERT(run.add_forced_entrant(captive), "A non-roster captive should be trackable as a forced entrant.")
	run.on_member_entered_room(room, captive)
	TEST_ASSERT(run.is_run_participant(captive), "A tracked captive should participate in run movement and presence.")
	TEST_ASSERT(!run.is_party_member(captive), "Forced entry must not grant roster membership.")
	TEST_ASSERT(!run.is_run_leader(captive), "Forced entry must never grant leadership.")
	TEST_ASSERT_EQUAL(captive.maxHealth, base_health + 25, "A forced entrant should receive the run's active boon stack.")

	captive.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!run.is_run_participant(captive), "Extraction should end forced-entrant status immediately.")
	TEST_ASSERT_EQUAL(captive.maxHealth, base_health, "Extraction should strip the run's boons immediately.")
	qdel(run)

/datum/unit_test/dungeon_present_set
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_present_set/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Delver should enter.")
	var/datum/dungeon_run/run = entrance.active_run
	// Clientless test mob has no ckey, so present_ckeys stays empty by design;
	// assert the occupant-based present-member query finds the delver instead.
	var/list/present = run.get_present_members()
	TEST_ASSERT(length(present) >= 1, "The delver should be counted among present members of the run.")

	qdel(run)

/datum/unit_test/dungeon_boss_room
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_boss_room/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	run.floor = 2 // so we can assert boss scaling
	run.floor_config = get_dungeon_floor_config(2)

	var/datum/pocket_dimension/dungeon/first_break = run.current_break_room
	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in first_break.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	TEST_ASSERT_NOTNULL(forward_gate, "Break room should have a forward gate.")

	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_boss")
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer into the boss room.")

	var/datum/pocket_dimension/dungeon/boss_room = forward_gate.destination_room
	TEST_ASSERT_NOTNULL(boss_room, "Boss room should instantiate.")
	TEST_ASSERT(!boss_room.cleared, "Boss room should not start cleared.")

	var/mob/living/simple_animal/hostile/boss/dungeon/boss
	for(var/boss_ref in boss_room.guardian_refs)
		var/datum/weakref/ref = boss_room.guardian_refs[boss_ref]
		boss = ref.resolve()
	TEST_ASSERT_NOTNULL(boss, "Boss should be spawned and tracked as a guardian.")
	TEST_ASSERT(boss.maxHealth > initial(boss.maxHealth), "Boss should be scaled up on floor 2.")

	var/obj/structure/dungeon_gate/onward
	for(var/obj/structure/dungeon_gate/gate as anything in boss_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			onward = gate
			break
	TEST_ASSERT_NOTNULL(onward, "Boss room should have a forward gate.")
	TEST_ASSERT(onward.sealed, "Boss room forward gate should be sealed while the boss lives.")
	var/datum/map_template/pocket/dungeon/sealed_onward_template = onward.pre_rolled_template
	TEST_ASSERT_NOTNULL(sealed_onward_template, "The sealed boss exit should pre-roll its destination.")
	TEST_ASSERT_EQUAL(sealed_onward_template.room_kind, DUNGEON_ROOM_BREAK, "The sealed boss exit should already point toward respite, not another fight.")
	var/list/sealed_onward_data = onward.ui_data(delver)
	TEST_ASSERT_EQUAL(sealed_onward_data["destination_text"], "A place of respite waits beyond, sealed until the floor's master falls.", "The sealed boss exit should identify the break room beyond.")
	TEST_ASSERT_NULL(sealed_onward_data["danger_text"], "The sealed boss exit should not advertise another combat encounter.")

	boss.death()
	TEST_ASSERT(boss_room.cleared, "Killing the boss should clear the room.")
	TEST_ASSERT_EQUAL(onward.gate_role, DUNGEON_GATE_FORWARD, "The way onward stays a forward passage - to respite, not straight down.")
	TEST_ASSERT(!onward.sealed, "The onward gate should be open after the boss dies.")
	TEST_ASSERT(run.boss_defeated_this_floor, "The run should remember the floor's boss has fallen.")
	var/datum/map_template/pocket/dungeon/onward_template = onward.pre_rolled_template
	TEST_ASSERT_NOTNULL(onward_template, "The onward gate should have a template after the kill.")
	TEST_ASSERT_EQUAL(onward_template.room_kind, DUNGEON_ROOM_BREAK, "The boss guards the floor's break room.")
	TEST_ASSERT_NULL(onward.reward_type, "The door to respite promises no deck reward.")
	var/list/onward_gate_data = onward.ui_data(delver)
	TEST_ASSERT_EQUAL(onward_gate_data["destination_text"], "The floor's master has fallen. A place of respite waits beyond.", "The boss exit should identify the break room beyond.")
	TEST_ASSERT_NULL(onward_gate_data["danger_text"], "The boss exit should not describe its break room as another combat encounter.")

	// Walk the full post-boss loop: break room (the floor's exit), then the
	// stairway down, which advances the floor.
	TEST_ASSERT(onward.use_gate(delver), "Onward gate should transfer into the break room.")
	// Entering the break room despawns the stretch (and the onward gate with
	// it), so read the new anchor from the run, not the dead gate.
	var/datum/pocket_dimension/dungeon/rest_room = run.current_break_room
	TEST_ASSERT_NOTNULL(rest_room, "Post-boss break room should exist.")
	TEST_ASSERT(rest_room.contains_turf(get_turf(delver)), "Delver should stand in the post-boss break room.")
	var/datum/map_template/pocket/dungeon/rest_template = rest_room.get_dungeon_template()
	TEST_ASSERT_NOTNULL(rest_template, "The rest anchor should have a template.")
	TEST_ASSERT_EQUAL(rest_template.room_kind, DUNGEON_ROOM_BREAK, "The post-boss rest anchor should be a break room.")
	TEST_ASSERT(QDELETED(boss_room), "The boss room should despawn behind the party.")
	var/obj/structure/dungeon_gate/down_gate
	for(var/obj/structure/dungeon_gate/gate as anything in rest_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			down_gate = gate
			break
	TEST_ASSERT_NOTNULL(down_gate, "Post-boss break room should have a forward gate.")
	var/datum/map_template/pocket/dungeon/down_template = down_gate.pre_rolled_template
	TEST_ASSERT_NOTNULL(down_template, "The break room's forward gate should have a template.")
	TEST_ASSERT_EQUAL(down_template.room_kind, DUNGEON_ROOM_DESCENT, "The post-boss break room opens onto the stairway down.")
	var/list/down_gate_data = down_gate.ui_data(delver)
	TEST_ASSERT_EQUAL(down_gate_data["destination_text"], "This passage leads to the entrance of the next floor.", "The break-room exit should identify the next-floor entrance beyond.")
	TEST_ASSERT_NULL(down_gate_data["danger_text"], "The break-room exit should not describe the next-floor entrance as a combat encounter.")
	var/floor_before = run.floor
	var/datum/pocket_dimension/dungeon/stairway_probe = down_gate.resolve_destination()
	TEST_ASSERT_NOTNULL(stairway_probe, "Stairway gate should resolve a destination (template=[down_template.id], sealed=[down_gate.sealed], forsaken=[down_gate.forsaken], run_ending=[run.ending]).")
	TEST_ASSERT(down_gate.use_gate(delver), "The stairway gate should transfer the delver (sealed=[down_gate.sealed], forsaken=[down_gate.forsaken], locked=[down_gate.requires_key && !down_gate.key_unlocked]).")
	TEST_ASSERT_EQUAL(run.floor, floor_before + 1, "Crossing the stairway should advance the floor.")
	TEST_ASSERT(!run.boss_defeated_this_floor, "A fresh floor's boss stands again.")

	qdel(run)

/datum/unit_test/dungeon_elite_path
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_elite_path/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/datum/pocket_dimension/dungeon/first_break = run.current_break_room
	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in first_break.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.path_type = DUNGEON_PATH_ELITE
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "Elite gate should transfer the delver.")

	var/datum/pocket_dimension/dungeon/elite_room = forward_gate.destination_room
	TEST_ASSERT_EQUAL(elite_room.incoming_path_type, DUNGEON_PATH_ELITE, "Room should record the elite path type.")
	var/mob/living/guardian
	for(var/g_ref in elite_room.guardian_refs)
		var/datum/weakref/ref = elite_room.guardian_refs[g_ref]
		guardian = ref.resolve()
	TEST_ASSERT_NOTNULL(guardian, "Elite room should have a guardian.")
	TEST_ASSERT(findtext(guardian.name, "Champion"), "Elite guardian should be named a Champion.")

	qdel(run)

/datum/unit_test/dungeon_motes
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_motes/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	TEST_ASSERT_EQUAL(run.motes, 0, "Run should start with no motes.")

	var/datum/pocket_dimension/dungeon/first_break = run.current_break_room
	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in first_break.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer to combat room.")
	var/datum/pocket_dimension/dungeon/combat_room = forward_gate.destination_room

	var/mob/living/guardian
	for(var/g_ref in combat_room.guardian_refs)
		var/datum/weakref/ref = combat_room.guardian_refs[g_ref]
		guardian = ref.resolve()
	TEST_ASSERT_NOTNULL(guardian, "Combat room should have a guardian.")
	// qdel (deterministic, affix-proof) — fires the same death-tracking path as death().
	qdel(guardian)
	TEST_ASSERT(run.motes > 0, "Removing a guardian should award motes to the run pool.")

	TEST_ASSERT(run.spend_motes(run.motes), "Should be able to spend all motes.")
	TEST_ASSERT_EQUAL(run.motes, 0, "Spending should empty the pool.")
	TEST_ASSERT(!run.spend_motes(1), "Spending more than the pool should fail.")

	qdel(run)

/datum/unit_test/dungeon_boons
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_boons/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/starting_health = delver.maxHealth
	var/datum/dungeon_boon/vigor/vigor = new
	run.add_boon(vigor)
	TEST_ASSERT_EQUAL(delver.maxHealth, starting_health + 25, "Vigor boon should raise max health for roster members in the dungeon.")

	// Greed boon multiplies mote drops.
	var/datum/dungeon_boon/greed/greed = new
	run.add_boon(greed)
	TEST_ASSERT(run.mote_multiplier > 1, "Greed boon should set a mote multiplier.")
	run.strip_boons_from(delver)
	TEST_ASSERT(run.mote_multiplier > 1, "A carrier leaving must not disable a run-global boon.")
	run.apply_boons_to(delver)

	qdel(run)
	TEST_ASSERT_EQUAL(delver.maxHealth, starting_health, "Run teardown should strip boons and restore max health (sandbox guarantee).")

/datum/unit_test/dungeon_shrine
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_shrine/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	run.motes = 100

	var/datum/pocket_dimension/dungeon/break_room = run.current_break_room
	var/obj/structure/dungeon_shrine/shrine
	for(var/turf/room_turf as anything in break_room.affected_turfs)
		for(var/obj/structure/dungeon_shrine/found in room_turf)
			shrine = found
			break
		if(shrine)
			break
	TEST_ASSERT_NOTNULL(shrine, "Break room with a shrine landmark should build a shrine structure.")
	TEST_ASSERT_EQUAL(shrine.owning_run, run, "Shrine should know its run.")

	var/obj/item/clothing/armor/plate/damaged_plate = allocate(/obj/item/clothing/armor/plate)
	TEST_ASSERT(delver.equip_to_slot_if_possible(damaged_plate, ITEM_SLOT_ARMOR, disable_warning = TRUE), "Test setup should equip the shrine buyer's plate.")
	damaged_plate.update_integrity(damaged_plate.max_integrity - 50)
	TEST_ASSERT(shrine.can_buy_offer("repair", delver), "Damaged worn armor should make the repair offer payable.")
	shrine.apply_shrine_offer("repair", delver)
	TEST_ASSERT_EQUAL(damaged_plate.get_integrity(), damaged_plate.max_integrity, "The repair offer should fully restore worn armor.")
	TEST_ASSERT(!shrine.can_buy_offer("repair", delver), "Fully repaired armor should be refused before payment.")

	shrine.apply_shrine_offer("cache", delver)
	TEST_ASSERT(run.spend_motes(40), "Run should still have motes after a free apply (spend path tested separately).")

	qdel(run)

/datum/unit_test/dungeon_key_gate
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_key_gate/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	var/datum/pocket_dimension/dungeon/break_room = run.current_break_room

	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	TEST_ASSERT_NOTNULL(forward_gate, "Break room should have a forward gate.")
	forward_gate.requires_key = TRUE
	forward_gate.key_id = "vault"
	forward_gate.sealed = FALSE

	TEST_ASSERT(!forward_gate.use_gate(delver), "Locked gate should refuse passage without a key.")

	var/obj/item/dungeon_key/wrong = new(get_turf(delver))
	wrong.key_id = "other"
	forward_gate.attackby(wrong, delver)
	TEST_ASSERT(!forward_gate.key_unlocked, "Wrong key should not unlock the gate.")

	var/obj/item/dungeon_key/right = new(get_turf(delver))
	right.key_id = "vault"
	forward_gate.attackby(right, delver)
	TEST_ASSERT(forward_gate.key_unlocked, "Matching key should unlock the gate.")
	TEST_ASSERT(QDELETED(right), "Used key should be consumed.")

	qdel(run)

/datum/unit_test/dungeon_progress_persistence/Run()
	var/test_ckey = "dungeontestckey"
	var/datum/dungeon_progress/progress = get_dungeon_progress(test_ckey)
	TEST_ASSERT_NOTNULL(progress, "Should create a progress datum for a ckey.")
	var/before = progress.echoes
	progress.add_echoes(500)
	TEST_ASSERT_EQUAL(progress.echoes, before + 500, "add_echoes should raise the balance.")

	progress.grant_unlock("start_boon")
	TEST_ASSERT(progress.has_unlock("start_boon"), "Unlock should be recorded.")

	// Force a reload from disk via a fresh datum.
	GLOB.player_dungeon_progress -= ckey(test_ckey)
	var/datum/dungeon_progress/reloaded = get_dungeon_progress(test_ckey)
	TEST_ASSERT_EQUAL(reloaded.echoes, before + 500, "Echoes should persist across a reload.")
	TEST_ASSERT(reloaded.has_unlock("start_boon"), "Unlocks should persist across a reload.")

	// Cleanup the test save so reruns are deterministic.
	reloaded.echoes = before
	reloaded.purchased_unlocks = list()
	reloaded.save_progress()

/datum/unit_test/dungeon_start_unlocks
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_start_unlocks/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()

	var/datum/dungeon_progress/progress = get_dungeon_progress(delver.ckey || "fallbackckey")
	progress.purchased_unlocks = list("starting_motes" = TRUE, "deep_start" = TRUE)

	// Manually seed + start a run to read the unlocks.
	var/datum/dungeon_run/run = new(entrance, null)
	run.seed_from_progress(progress)
	TEST_ASSERT(run.start(), "Run should start.")
	TEST_ASSERT_EQUAL(run.floor, 2, "deep_start unlock should begin the run on floor 2.")
	TEST_ASSERT_EQUAL(run.motes, 50, "starting_motes unlock should grant 50 motes.")

	qdel(run)
	progress.purchased_unlocks = list()
	progress.save_progress()

/datum/unit_test/dungeon_cosmetic_title/Run()
	var/test_ckey = "cosmeticstestckey"
	var/datum/dungeon_progress/progress = get_dungeon_progress(test_ckey)
	progress.grant_cosmetic("title_delver")
	progress.selected_title = "title_delver"
	progress.save_progress()
	TEST_ASSERT(progress.has_cosmetic("title_delver"), "Cosmetic should be recorded.")

	var/datum/dungeon_cosmetic/cosmetic = get_dungeon_cosmetic_by_id("title_delver")
	TEST_ASSERT_NOTNULL(cosmetic, "Should resolve a cosmetic by id.")
	TEST_ASSERT_EQUAL(cosmetic.title_text, "Delver of the Deep", "Title text should match.")
	qdel(cosmetic)

	var/mob/living/carbon/human/titled_delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	titled_delver.real_name = "Test Delver"
	titled_delver.name = "Test Delver, Delver of the Deep"
	titled_delver.applied_dungeon_title = "Delver of the Deep"
	TEST_ASSERT_NULL(titled_delver.get_alt_name(), "A worn dungeon title should not make its recognizable speaker anonymous.")
	titled_delver.name = "Masked Delver, Delver of the Deep"
	TEST_ASSERT_NOTNULL(titled_delver.get_alt_name(), "A genuine disguise should remain anonymous even while a title is tracked.")

	// Cleanup
	progress.purchased_cosmetics = list()
	progress.selected_title = null
	progress.save_progress()

/datum/unit_test/dungeon_achievements/Run()
	// Awards auto-register in SSachievements from /datum/award/achievement subtypes.
	var/datum/award/first_boss = SSachievements.awards[/datum/award/achievement/dungeon/first_boss]
	TEST_ASSERT_NOTNULL(first_boss, "First-boss dungeon award should be registered.")
	TEST_ASSERT(first_boss.name, "Registered award should have a name.")
	var/datum/award/floor_ten = SSachievements.awards[/datum/award/achievement/dungeon/floor_ten]
	TEST_ASSERT_NOTNULL(floor_ten, "Floor-ten dungeon award should be registered.")

	// Granting to a clientless mob must be a safe no-op (the real grant needs a
	// client). The call itself is the test: the harness fails on any runtime.
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/dungeon_run/dummy = new(null, null)
	dummy.grant_dungeon_milestones(delver, 10, TRUE)
	qdel(dummy)

/datum/unit_test/dungeon_spawn_pool/Run()
	var/datum/dungeon_floor_config/config = get_dungeon_floor_config(1)
	TEST_ASSERT_NOTNULL(config, "Floor 1 config should exist.")
	TEST_ASSERT(length(config.combat_mob_pool) >= 2, "Test floor should have a combat pool.")

	var/datum/dungeon_spawn_entry/any_entry = pick_floor_spawn_entry(config, null, 1)
	TEST_ASSERT_NOTNULL(any_entry, "Unfiltered pick should return an entry.")

	var/list/ranged_pool = get_floor_spawn_pool(config, DUNGEON_STYLE_RANGED, 1)
	TEST_ASSERT(length(ranged_pool), "Ranged-filtered pool should be non-empty for the test floor.")
	for(var/datum/dungeon_spawn_entry/entry as anything in ranged_pool)
		TEST_ASSERT_EQUAL(entry.style, DUNGEON_STYLE_RANGED, "Style filter must only return ranged entries.")

	var/datum/dungeon_spawn_entry/gated = new /datum/dungeon_spawn_entry(/mob/living/simple_animal/hostile/retaliate/wolf, 10, DUNGEON_STYLE_MELEE, 99)
	config.combat_mob_pool += gated
	var/list/low_tier = get_floor_spawn_pool(config, null, 1)
	TEST_ASSERT(!(gated in low_tier), "An entry with min_tier 99 must not appear at tier 1.")
	config.combat_mob_pool -= gated
	qdel(gated)

/datum/unit_test/dungeon_boss_maker/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/mob/living/simple_animal/hostile/retaliate/wolf/victim = allocate(/mob/living/simple_animal/hostile/retaliate/wolf, spot)
	var/base_health = victim.maxHealth

	var/bounty = make_dungeon_boss(victim, 3, 2)
	TEST_ASSERT(victim.maxHealth > base_health, "make_dungeon_boss should raise max health on any mob.")
	TEST_ASSERT(bounty > 0, "make_dungeon_boss should return a positive mote bounty.")
	TEST_ASSERT_NOTNULL(victim.GetComponent(/datum/component/dungeon_boss_healthbar), "Promoted boss should get a healthbar component.")
	TEST_ASSERT_NOTNULL(victim.GetComponent(/datum/component/dungeon_boss_abilities), "A non-ATB mob promoted to boss should get the ability kit.")

	var/mob/living/carbon/human/species/goblin/npc/ambush/goblin_boss = allocate(/mob/living/carbon/human/species/goblin/npc/ambush, spot)
	var/mob/living/carbon/human/carbon_target = allocate(/mob/living/carbon/human, get_step(spot, EAST))
	make_dungeon_boss(goblin_boss, 1, 1)
	var/datum/component/dungeon_boss_abilities/carbon_kit = goblin_boss.GetComponent(/datum/component/dungeon_boss_abilities)
	TEST_ASSERT_NOTNULL(carbon_kit, "The shipped carbon boss type should receive an ability kit.")
	TEST_ASSERT_NOTNULL(goblin_boss.ai_controller, "The shipped carbon boss type should have an AI controller.")
	goblin_boss.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, carbon_target)
	var/datum/dungeon_boss_ability/carbon_ability = carbon_kit.abilities[1]
	carbon_ability.next_use = 0
	carbon_kit.process(0.1)
	TEST_ASSERT(carbon_ability.next_use > world.time, "A carbon boss should fire its kit at the AI controller's combat target.")

/datum/unit_test/dungeon_scatter
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_scatter/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_scatter")
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer to the scatter room.")

	var/datum/pocket_dimension/dungeon/scatter_room = forward_gate.destination_room
	TEST_ASSERT_NOTNULL(scatter_room, "Scatter room should instantiate.")
	var/datum/dungeon_floor_config/cfg = run.floor_config
	TEST_ASSERT(length(scatter_room.guardian_refs) >= cfg.density_min, "Scatter should spawn at least density_min guardians.")
	TEST_ASSERT(!scatter_room.cleared, "A scatter room with guardians should not start cleared.")

	qdel(run)

/datum/unit_test/dungeon_room_trait_emboldened
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_room_trait_emboldened/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer to the combat room.")
	var/datum/pocket_dimension/dungeon/room = forward_gate.destination_room

	var/mob/living/guardian
	for(var/g_ref in room.guardian_refs)
		var/datum/weakref/ref = room.guardian_refs[g_ref]
		guardian = ref.resolve()
	TEST_ASSERT_NOTNULL(guardian, "Combat room should have a guardian.")
	var/before = guardian.maxHealth

	// Force the emboldened trait and apply it.
	var/datum/dungeon_room_trait/emboldened/trait = new
	room.current_trait = trait
	trait.apply_to_room(room)
	TEST_ASSERT(guardian.maxHealth > before, "Emboldened trait should raise guardian max health.")

	qdel(run)

/datum/unit_test/dungeon_room_trait_style_filter/Run()
	var/datum/pocket_dimension/dungeon/fake = new
	var/datum/dungeon_room_trait/archers_roost/trait = new
	trait.modify_plan(fake)
	TEST_ASSERT_EQUAL(fake.scatter_style_override, DUNGEON_STYLE_RANGED, "Archers' Roost should force the ranged scatter style.")
	qdel(trait)
	qdel(fake)

/datum/unit_test/dungeon_stretch_deck/Run()
	var/datum/dungeon_run/run = new(null, null)
	run.stretch_length = 5
	run.build_stretch_deck()

	TEST_ASSERT(length(run.stretch_deck) >= 10, "Deck should be sized to the stretch (>= stretch_length * 2).")
	var/boons = 0
	var/treasures = 0
	var/vaults = 0
	for(var/reward in run.stretch_deck)
		if(reward == DUNGEON_REWARD_BOON)
			boons++
		if(reward == DUNGEON_REWARD_LOOT || reward == DUNGEON_REWARD_VAULT)
			treasures++
		if(reward == DUNGEON_REWARD_VAULT)
			vaults++
	TEST_ASSERT(boons >= 1, "Deck must guarantee at least one boon door.")
	TEST_ASSERT(treasures >= 1, "Deck must guarantee at least one loot/vault door.")
	TEST_ASSERT(vaults <= 1, "Deck must cap vault doors at one.")

	// Draws deplete the deck, then fall back to weighted re-rolls.
	var/deck_size = length(run.stretch_deck)
	for(var/i in 1 to deck_size)
		run.draw_door_reward()
	TEST_ASSERT_EQUAL(length(run.stretch_deck), 0, "Draws should deplete the deck.")
	var/fallback = run.draw_door_reward()
	TEST_ASSERT_NOTNULL(fallback, "An exhausted deck should still deal rewards.")
	TEST_ASSERT(fallback != DUNGEON_REWARD_VAULT, "Fallback deals must never be vaults.")

	qdel(run)

/datum/unit_test/dungeon_anti_repeat/Run()
	// Exclusion filters the pool; graceful fallback when it would empty it.
	var/list/excluded = list("dungeon_test_combat", "dungeon_test_scatter")
	var/list/pool = get_dungeon_template_pool(DUNGEON_ROOM_COMBAT, DUNGEON_THEME_TEST, 0, INFINITY, excluded)
	for(var/datum/map_template/pocket/dungeon/template as anything in pool)
		TEST_ASSERT(!(template.id in excluded), "Excluded template ids must not appear in the pool.")
	// pick falls back rather than returning null when exclusion empties everything.
	var/datum/map_template/pocket/dungeon/picked = pick_dungeon_template(DUNGEON_ROOM_COMBAT, DUNGEON_THEME_TEST, 0, INFINITY, excluded)
	TEST_ASSERT_NOTNULL(picked, "pick_dungeon_template should relax the exclusion instead of failing.")

	// remember_template keeps a bounded ring.
	var/datum/dungeon_run/run = new(null, null)
	run.remember_template("a")
	run.remember_template("b")
	run.remember_template("c")
	run.remember_template("d")
	TEST_ASSERT_EQUAL(length(run.recent_template_ids), DUNGEON_RECENT_TEMPLATE_MEMORY, "Template memory should trim to the ring size.")
	TEST_ASSERT(!("a" in run.recent_template_ids), "Oldest remembered template should fall out of the ring.")
	qdel(run)

/datum/unit_test/dungeon_pacing_knob/Run()
	var/datum/dungeon_run/run = new(null, null)
	run.floor_config = get_dungeon_floor_config(1)
	run.floor_config.stretches_per_floor = 2
	run.stretches_completed_this_floor = 0
	TEST_ASSERT(!run.is_final_stretch(), "First stretch of a two-stretch floor should not be final.")
	run.stretches_completed_this_floor = 1
	TEST_ASSERT(run.is_final_stretch(), "Second stretch of a two-stretch floor should be final.")
	run.floor_config.stretches_per_floor = 1 // restore the shared test config
	qdel(run)

/// Kills guardians until the room reports cleared. Wave rooms spawn a fresh
/// wave on each clear, so one pass is not enough.
/datum/unit_test/proc/drain_dungeon_room(datum/pocket_dimension/dungeon/room)
	for(var/pass in 1 to 12)
		if(room.cleared)
			return TRUE
		if(!length(room.guardian_refs))
			return room.cleared
		for(var/g_ref in room.guardian_refs.Copy())
			var/datum/weakref/g_wr = room.guardian_refs[g_ref]
			var/mob/living/g_mob = g_wr?.resolve()
			if(g_mob)
				qdel(g_mob)
	return room.cleared

/datum/unit_test/dungeon_door_rewards
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_door_rewards/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	// -- LOOT door: clearing spawns a bonus cache --
	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	forward_gate.reward_type = DUNGEON_REWARD_LOOT
	forward_gate.sealed = FALSE
	// A special room would roll trader/mystery/waves population and change the clear shape.
	run.special_room_position = 0
	run.special_room_kind = null
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer to the loot-door room.")
	var/datum/pocket_dimension/dungeon/loot_room = forward_gate.destination_room
	TEST_ASSERT_EQUAL(loot_room.promised_reward, DUNGEON_REWARD_LOOT, "Room should inherit the gate's reward promise.")
	var/caches_before = length(loot_room.loot_caches)
	TEST_ASSERT(drain_dungeon_room(loot_room), "Loot-door room should clear.")
	TEST_ASSERT(length(loot_room.loot_caches) > caches_before, "Clearing a LOOT door should spawn a bonus cache.")

	// -- HEAL door: clearing heals present members --
	var/obj/structure/dungeon_gate/next_gate
	for(var/obj/structure/dungeon_gate/gate as anything in loot_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			next_gate = gate
			break
	TEST_ASSERT_NOTNULL(next_gate, "Loot room should have a forward gate.")
	next_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	next_gate.reward_type = DUNGEON_REWARD_HEAL
	next_gate.sealed = FALSE
	run.special_room_position = 0
	run.special_room_kind = null
	TEST_ASSERT(next_gate.use_gate(delver), "Gate should transfer to the heal-door room.")
	var/datum/pocket_dimension/dungeon/heal_room = next_gate.destination_room
	// The payout only fires on the clear, so the damage must land while the room is still held.
	TEST_ASSERT(!heal_room.cleared, "Heal-door room should still be held when the delver is damaged.")
	delver.adjustBruteLoss(50)
	var/damage_before = delver.getBruteLoss()
	TEST_ASSERT(damage_before > 0, "Delver should be damaged before the heal payout.")
	var/datum/map_template/pocket/dungeon/heal_template = heal_room.get_dungeon_template()
	var/cleared_heal_room = drain_dungeon_room(heal_room)
	var/list/lingering = list()
	for(var/g_ref in heal_room.guardian_refs)
		var/datum/weakref/g_wr = heal_room.guardian_refs[g_ref]
		var/mob/living/g_mob = g_wr?.resolve()
		lingering += g_mob ? "[g_mob.type](stat=[g_mob.stat])" : "unresolved:[g_ref]"
	TEST_ASSERT(cleared_heal_room, "Heal-door room should clear (template=[heal_template?.id], pop=[heal_room.population_mode], waves=[heal_room.pending_waves], refs=[length(heal_room.guardian_refs)]: [lingering.Join(", ")]).")
	TEST_ASSERT(delver.getBruteLoss() < damage_before, "Clearing a HEAL door should heal present members (before=[damage_before], after=[delver.getBruteLoss()], members=[length(run.get_members_in_room(heal_room))]).")

	qdel(run)

/datum/unit_test/dungeon_vault_reward
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_vault_reward/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	forward_gate.reward_type = DUNGEON_REWARD_VAULT
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer to the vault room.")
	var/datum/pocket_dimension/dungeon/vault_room = forward_gate.destination_room
	TEST_ASSERT_NOTNULL(vault_room.vault_key_id, "A vault room should mint a key id.")
	TEST_ASSERT(length(vault_room.keyholder_drops), "A vault room should mark a keyholder guardian.")

	// Remove the guardians; the keyholder drops the vault key, the locked cache
	// appears. qdel is affix-proof and QDELETING fires while the mob still has
	// a turf, so the key drop lands correctly.
	for(var/g_ref in vault_room.guardian_refs.Copy())
		var/datum/weakref/g_wr = vault_room.guardian_refs[g_ref]
		var/mob/living/g_mob = g_wr?.resolve()
		if(g_mob)
			qdel(g_mob)
	TEST_ASSERT(vault_room.cleared, "Vault room should clear.")

	var/obj/structure/dungeon_loot_cache/vault_cache
	var/obj/item/dungeon_key/vault_key
	for(var/turf/room_turf as anything in vault_room.affected_turfs)
		for(var/obj/structure/dungeon_loot_cache/found_cache in room_turf)
			if(found_cache.key_id == vault_room.vault_key_id)
				vault_cache = found_cache
		for(var/obj/item/dungeon_key/found_key in room_turf)
			vault_key = found_key
	TEST_ASSERT_NOTNULL(vault_cache, "Vault clear should spawn a key-locked cache.")
	TEST_ASSERT(vault_cache.locked, "Vault cache should stay sealed until keyed open.")
	TEST_ASSERT_NOTNULL(vault_key, "The keyholder should drop the vault key on death.")
	TEST_ASSERT_EQUAL(vault_key.key_id, vault_room.vault_key_id, "Dropped key should match the vault cache.")

	vault_cache.attackby(vault_key, delver)
	TEST_ASSERT(!vault_cache.locked, "The matching key should unseal the vault cache.")
	TEST_ASSERT(QDELETED(vault_key), "The vault key should be consumed.")

	qdel(run)

/datum/unit_test/dungeon_watching_gods/Run()
	var/mob/living/carbon/human/worshipper = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)

	// Without any worshippers: evil gods must not appear; base weights only.
	var/list/base_weights = get_watching_god_weights(list(worshipper))
	for(var/datum/dungeon_god_profile/profile as anything in base_weights)
		TEST_ASSERT(!ispath(profile.patron_type, /datum/patron/faerun/evil_gods), "Evil gods must not watch a party with no worshipper of theirs.")
		TEST_ASSERT_EQUAL(base_weights[profile], 10, "Godless parties should produce base weights only.")

	// A Tempus worshipper boosts Tempus's weight.
	worshipper.patron = GLOB.patron_list[/datum/patron/faerun/neutral_gods/Tempus]
	TEST_ASSERT_NOTNULL(worshipper.patron, "Tempus should exist in the patron list.")
	var/list/tempus_weights = get_watching_god_weights(list(worshipper))
	var/found_tempus_boost = FALSE
	for(var/datum/dungeon_god_profile/profile as anything in tempus_weights)
		if(profile.patron_type == /datum/patron/faerun/neutral_gods/Tempus)
			TEST_ASSERT_EQUAL(tempus_weights[profile], 50, "A worshipper should add +40 weight to their god.")
			found_tempus_boost = TRUE
	TEST_ASSERT(found_tempus_boost, "Tempus should be in the watching pool.")

	// A Lolth worshipper unlocks Lolth's gaze.
	worshipper.patron = GLOB.patron_list[/datum/patron/faerun/evil_gods/Lolth]
	TEST_ASSERT_NOTNULL(worshipper.patron, "Lolth should exist in the patron list.")
	var/list/lolth_weights = get_watching_god_weights(list(worshipper))
	var/found_lolth = FALSE
	for(var/datum/dungeon_god_profile/profile as anything in lolth_weights)
		if(profile.patron_type == /datum/patron/faerun/evil_gods/Lolth)
			found_lolth = TRUE
	TEST_ASSERT(found_lolth, "An evil god should watch when its worshipper descends.")

	// The roll returns three distinct gods.
	var/list/rolled = roll_watching_gods(list(worshipper))
	TEST_ASSERT_EQUAL(length(rolled), 3, "The gaze should settle three gods.")
	worshipper.patron = null

/datum/unit_test/dungeon_boon_offer/Run()
	var/datum/dungeon_run/run = new(null, null)
	run.watching_god_types = list(/datum/patron/faerun/neutral_gods/Tempus)

	// Pity at maximum forces an epic and resets.
	run.epic_pity = 100
	var/rarity = run.roll_boon_rarity()
	TEST_ASSERT_EQUAL(rarity, DUNGEON_BOON_EPIC, "Maxed pity should force an epic rarity.")
	TEST_ASSERT_EQUAL(run.epic_pity, 0, "An epic roll should reset the pity counter.")
	TEST_ASSERT_EQUAL(run.get_rarity_magnitude(DUNGEON_BOON_EPIC), 2.25, "Epic magnitude should be 2.25x.")

	// The offer builds branded, rarity-stamped cards.
	var/list/datum/dungeon_boon/cards = build_boon_offer(run, 3)
	TEST_ASSERT_EQUAL(length(cards), 3, "The offer should hold three cards.")
	for(var/datum/dungeon_boon/card as anything in cards)
		TEST_ASSERT_NOTNULL(card.rarity, "Every card should carry a rarity.")
		TEST_ASSERT(card.magnitude >= 1, "Every card should carry a magnitude.")
		qdel(card)

	// Holding both prerequisites summons the synergy card.
	var/datum/dungeon_boon/edge/edge = new
	var/datum/dungeon_boon/fortune/fortune = new
	run.add_boon(edge)
	run.add_boon(fortune)
	TEST_ASSERT_EQUAL(get_available_synergy(run), /datum/dungeon_boon/battle_luck, "Edge + Fortune should unlock Battle Luck.")
	var/list/datum/dungeon_boon/synergy_cards = build_boon_offer(run, 3)
	var/datum/dungeon_boon/last_card = synergy_cards[length(synergy_cards)]
	TEST_ASSERT(istype(last_card, /datum/dungeon_boon/battle_luck), "The synergy should claim the last card slot.")
	TEST_ASSERT(findtext(last_card.get_display_name(), "Synergy"), "The synergy card should be labeled.")
	for(var/datum/dungeon_boon/card as anything in synergy_cards)
		qdel(card)

	qdel(run)

/datum/unit_test/dungeon_wipe_logic
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_wipe_logic/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	// Clientless members never count toward a wipe (abandonment owns that case).
	TEST_ASSERT(!run.is_party_wiped(), "A run with only clientless members must never read as wiped.")
	run.maybe_arm_wipe()
	TEST_ASSERT_NULL(run.wipe_timer, "The wipe grace must not arm without a wiped client party.")

	// A knocked-out member doesn't gate the muster.
	delver.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(delver.has_status_effect(/datum/status_effect/defeat_knockout), "Knockout should apply to the test delver.")
	TEST_ASSERT_EQUAL(length(run.get_muster_missing(run.current_break_room)), 0, "Defeated members are carried, never counted as scattered.")
	delver.remove_status_effect(/datum/status_effect/defeat_knockout)

	// resolve_wipe with a standing party grants the reprieve, not the end.
	run.resolve_wipe()
	TEST_ASSERT(!run.wiped, "resolve_wipe must not end a run whose party stands.")
	TEST_ASSERT(!QDELETED(run), "A reprieved run keeps going.")

	// A wiped run skips banking (flag check on the teardown path).
	run.motes = 500
	run.run_was_meaningful = TRUE
	run.wiped = TRUE
	qdel(run)
	TEST_ASSERT_NULL(entrance.active_run, "Wipe teardown should clear the entrance's run.")

/datum/unit_test/dungeon_larder
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_larder/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	// No larder yet: natives get no lair tag.
	TEST_ASSERT_NULL(run.get_live_larder_tag(), "A run without a larder must report no live tag.")

	// Build one by hand in the break room and check registration.
	var/datum/pocket_dimension/dungeon/break_room = run.current_break_room
	var/turf/spot = break_room.get_drop_turf(null)
	TEST_ASSERT_NOTNULL(spot, "Break room should offer an open turf.")
	break_room.build_larder(spot)
	var/run_tag = run.get_larder_tag()
	TEST_ASSERT(length(GLOB.kidnap_entrance_markers[run_tag]), "The larder should register a run-tagged kidnap entrance.")
	TEST_ASSERT_EQUAL(run.get_live_larder_tag(), run_tag, "A live larder should surface the run tag for guardians.")

	// A knocked-out victim can be hauled off by the dungeon's own captivity
	// profile, and is released back into the run rather than the overworld.
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	victim.mind_initialize()
	victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(victim.kidnap_to_pocket(/datum/defeat_captivity_profile/dungeon_larder, null, null, run_tag), "A knocked-out victim should be haulable to the run larder.")
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	TEST_ASSERT_NOTNULL(captivity, "Hauling should attach the captivity component.")
	TEST_ASSERT_EQUAL(captivity.lair_tag, run_tag, "The captivity should carry the run's larder tag.")

	// The tag is the only thread back to the run once the captive is pocketed.
	TEST_ASSERT_EQUAL(get_dungeon_run_by_larder_tag(run_tag), run, "The larder tag should resolve back to its run.")
	var/turf/release_turf = captivity.get_contextual_destination()
	TEST_ASSERT_NOTNULL(release_turf, "A dungeon captive should have a release destination.")
	TEST_ASSERT(break_room.contains_turf(release_turf), "A dungeon captive must be released into the run's break room, not the wilds.")

	victim.remove_status_effect(/datum/status_effect/defeat_knockout)
	qdel(run)
	TEST_ASSERT(!length(GLOB.kidnap_entrance_markers[run_tag]), "Run teardown must deregister the larder markers.")
	TEST_ASSERT_NULL(get_dungeon_run_by_larder_tag(run_tag), "A torn-down run should no longer answer to its tag.")

/datum/unit_test/dungeon_captives_and_stubborn_heart
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_captives_and_stubborn_heart/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	var/datum/pocket_dimension/dungeon/break_room = run.current_break_room

	// Captives trait spawns distress NPCs in the room.
	var/datum/dungeon_room_trait/captives/trait = new
	trait.apply_to_room(break_room)
	var/found_captive = FALSE
	for(var/turf/room_turf as anything in break_room.affected_turfs)
		for(var/mob/living/carbon/human/possible in room_turf)
			if(possible.GetComponent(/datum/component/npc_in_distress))
				found_captive = TRUE
				break
		if(found_captive)
			break
	TEST_ASSERT(found_captive, "The Captives trait should spawn a distress NPC in the room.")
	qdel(trait)

	// Stubborn Heart halves the struggle timers and strips clean.
	TEST_ASSERT_EQUAL(delver.defeat_struggle_delay_mult, 1, "Baseline struggle multiplier should be 1.")
	var/datum/dungeon_boon/stubborn_heart/boon = new
	run.add_boon(boon)
	TEST_ASSERT_EQUAL(delver.defeat_struggle_delay_mult, 0.5, "Stubborn Heart at common magnitude should halve the struggle delays.")
	qdel(run)
	TEST_ASSERT_EQUAL(delver.defeat_struggle_delay_mult, 1, "Run teardown should restore the struggle multiplier (sandbox).")

/datum/unit_test/dungeon_boon_no_restack
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_boon_no_restack/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/base_health = delver.maxHealth
	var/datum/dungeon_boon/vigor/vigor = new
	run.add_boon(vigor)
	TEST_ASSERT_EQUAL(delver.maxHealth, base_health + 25, "Vigor should apply once on grant.")

	// Cross a gate: entry-path boon application must not stack the bonus again.
	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	forward_gate.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	forward_gate.sealed = FALSE
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer the delver.")
	TEST_ASSERT_EQUAL(delver.maxHealth, base_health + 25, "Room transitions must not re-apply additive boons.")

	qdel(run)
	TEST_ASSERT_EQUAL(delver.maxHealth, base_health, "Teardown should strip the stack exactly once.")

/datum/unit_test/dungeon_presence_reconciliation
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_presence_reconciliation/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/base_health = delver.maxHealth
	var/datum/dungeon_boon/vigor/vigor = new
	run.add_boon(vigor)
	TEST_ASSERT_EQUAL(delver.maxHealth, base_health + 25, "Vigor should be active inside the run.")

	// Simulate an extraction that bypasses exit_mob (defeat-rune return, kidnap,
	// admin teleport): the presence sweep must strip the leaked boons.
	delver.forceMove(get_turf(entrance))
	run.last_presence_validation = 0
	run.validate_presence()
	TEST_ASSERT_EQUAL(delver.maxHealth, base_health, "Extraction that bypasses exit_mob must not leak boons outside the dungeon.")

	// Walking back in restores the stack through the normal entry path.
	TEST_ASSERT(entrance.try_enter(delver), "Re-entry should be allowed.")
	TEST_ASSERT_EQUAL(delver.maxHealth, base_health + 25, "Re-entering should re-apply the run's boon stack once.")

	// A second outside extraction leaves no legitimate delvers behind. The
	// centralized lifecycle sweep should now collapse the run immediately,
	// without needing the extracting system to know anything about dungeons.
	delver.forceMove(get_turf(entrance))
	run.last_presence_validation = 0
	run.check_abandonment()
	TEST_ASSERT(QDELETED(run), "A run should collapse once every delver has left by an outside teleport.")
	TEST_ASSERT_NULL(entrance.active_run, "External extraction collapse should release the owning entrance.")

/datum/unit_test/dungeon_forsaken_paths
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_forsaken_paths/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	var/datum/pocket_dimension/dungeon/break_room = run.current_break_room

	var/list/forward_gates = list()
	for(var/obj/structure/dungeon_gate/gate as anything in break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gates += gate
	TEST_ASSERT(length(forward_gates) >= 2, "The test break room should offer at least two forward doors.")

	var/obj/structure/dungeon_gate/chosen = forward_gates[1]
	var/obj/structure/dungeon_gate/spurned = forward_gates[2]
	chosen.pre_rolled_template = SSpocket_dimensions.resolve_template("dungeon_test_combat")
	chosen.sealed = FALSE
	TEST_ASSERT(chosen.use_gate(delver), "The chosen door should carry the delver through.")

	TEST_ASSERT(spurned.forsaken, "Choosing one door should fuse its siblings shut.")
	TEST_ASSERT(!chosen.forsaken, "The taken door itself must stay open.")

	// Backtrack and try the spurned door: refused.
	var/datum/pocket_dimension/dungeon/combat_room = chosen.destination_room
	var/obj/structure/dungeon_gate/back_gate
	for(var/obj/structure/dungeon_gate/gate as anything in combat_room.gates)
		if(gate.gate_role == DUNGEON_GATE_BACK)
			back_gate = gate
			break
	TEST_ASSERT_NOTNULL(back_gate, "Combat room should have a back gate.")
	TEST_ASSERT(back_gate.use_gate(delver), "Backtracking should still work.")
	TEST_ASSERT(!spurned.use_gate(delver), "A forsaken door must refuse passage.")
	// Force-advance (the right-click / panel Force path) must also refuse a
	// forsaken door - muster_advance is the anti-branching backstop.
	TEST_ASSERT(!run.muster_advance(spurned, delver, force = TRUE), "Force-advancing a forsaken gate must be refused.")
	// The originally chosen door still re-traverses to its existing room.
	TEST_ASSERT(chosen.use_gate(delver), "The chosen door should remain re-traversable.")

	qdel(run)

/datum/unit_test/dungeon_mote_batching/Run()
	var/datum/dungeon_run/run = new(null, null)
	run.award_motes(10, null)
	run.award_motes(15, null)
	TEST_ASSERT_EQUAL(run.motes, 25, "Both awards should land in the pool immediately.")
	TEST_ASSERT_EQUAL(run.pending_mote_announce, 25, "Announcements should buffer instead of firing per award.")
	TEST_ASSERT(run.mote_announce_scheduled, "A flush should be scheduled after the first award.")
	run.flush_mote_announce()
	TEST_ASSERT_EQUAL(run.pending_mote_announce, 0, "Flush should clear the buffer.")
	qdel(run)

/datum/unit_test/dungeon_boon_offer_session
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_boon_offer_session/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	TEST_ASSERT_NOTNULL(run, "Run should exist.")

	// Sessions are built directly (test mobs are clientless; offer_boon requires a client).
	var/list/datum/dungeon_boon/cards = build_boon_offer(run, 3)
	TEST_ASSERT_EQUAL(length(cards), 3, "Offer should build three cards.")
	var/datum/dungeon_boon/unpicked_a = cards[1]
	var/datum/dungeon_boon/picked = cards[2]
	var/datum/dungeon_boon_offer/offer = new(run, delver, cards)
	run.open_boon_offers += offer

	TEST_ASSERT(!offer.resolve_pick(0), "Out-of-range pick must be rejected.")
	TEST_ASSERT(!offer.resolve_pick(4), "Out-of-range pick must be rejected.")
	TEST_ASSERT(offer.resolve_pick(2), "Valid pick should resolve.")
	TEST_ASSERT_EQUAL(length(run.active_boons), 1, "Exactly one boon should be active after the pick.")
	TEST_ASSERT_EQUAL(run.active_boons[1], picked, "The picked card should be the active boon.")
	TEST_ASSERT(QDELETED(offer), "Resolved session should be deleted.")
	TEST_ASSERT(QDELETED(unpicked_a), "Unpicked cards should be deleted with the session.")
	TEST_ASSERT(!QDELETED(picked), "The applied boon must survive the session.")
	TEST_ASSERT_EQUAL(length(run.open_boon_offers), 0, "Session should deregister from the run.")

	// Concurrent windows must not commit the same boon type twice.
	var/datum/dungeon_boon_offer/first_duplicate = new(run, delver, list(new /datum/dungeon_boon/dark/umbral_edge))
	var/datum/dungeon_boon_offer/stale_duplicate = new(run, delver, list(new /datum/dungeon_boon/dark/umbral_edge))
	run.open_boon_offers += first_duplicate
	run.open_boon_offers += stale_duplicate
	TEST_ASSERT(first_duplicate.resolve_pick(1), "The first concurrent copy should resolve normally.")
	TEST_ASSERT(!stale_duplicate.resolve_pick(1), "A stale concurrent copy must be rejected and redrawn.")
	var/price_count = 0
	for(var/datum/dungeon_boon/active as anything in run.active_boons)
		if(istype(active, /datum/dungeon_boon/dark/umbral_edge))
			price_count++
	TEST_ASSERT_EQUAL(price_count, 1, "Concurrent boon offers must preserve type uniqueness.")

	// An unanswered session dies with the run.
	var/list/datum/dungeon_boon/cards2 = build_boon_offer(run, 3)
	var/datum/dungeon_boon_offer/hanging = new(run, delver, cards2)
	run.open_boon_offers += hanging
	qdel(run)
	TEST_ASSERT(QDELETED(hanging), "Run teardown should delete open offer sessions.")

/datum/unit_test/dungeon_assembly_ui_data/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	var/list/data = entrance.ui_data(delver)
	TEST_ASSERT_NOTNULL(data, "Assembly ui_data should return a list.")
	TEST_ASSERT(!data["has_party"], "Partyless delver should read has_party = FALSE.")
	TEST_ASSERT(islist(data["roster"]), "Roster should always be a list.")
	TEST_ASSERT(isnum(data["echoes"]), "Echoes should always be a number.")
	TEST_ASSERT(!data["run_active"], "No run should be active yet.")

/datum/unit_test/dungeon_heat_dials
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_heat_dials/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	TEST_ASSERT_NOTNULL(run, "Run should exist.")

	// Zero heat: everything reads baseline.
	TEST_ASSERT_EQUAL(run.get_total_heat(), 0, "Fresh run should have zero heat.")
	TEST_ASSERT_EQUAL(run.get_heat_hp_mult(), 1, "Zero heat should not scale guardian health.")
	TEST_ASSERT_EQUAL(run.get_wipe_grace(), DUNGEON_WIPE_GRACE, "Zero heat should keep the base wipe grace.")
	TEST_ASSERT_EQUAL(run.get_echo_conversion(), DUNGEON_ECHO_CONVERSION, "Zero heat should keep the base echo conversion.")

	// Crank every dial and re-read each knob.
	run.heat_ranks = list(
		DUNGEON_HEAT_HARDENED = 2,
		DUNGEON_HEAT_ELITES = 2,
		DUNGEON_HEAT_CRUEL = 2,
		DUNGEON_HEAT_FORCED_MARCH = 2,
		DUNGEON_HEAT_IRON_CONTRACT = 1,
		DUNGEON_HEAT_SEALED_MERCY = 1,
	)
	TEST_ASSERT_EQUAL(run.get_total_heat(), 10, "Max heat should total 10.")
	TEST_ASSERT_EQUAL(run.get_heat_hp_mult(), 1.5, "Hardened Foes 2 should read x1.5 health.")
	TEST_ASSERT_EQUAL(run.get_heat_elite_bonus(), 20, "Elite Presence 2 should add +20 elite chance.")
	TEST_ASSERT_EQUAL(run.get_trait_chance(), 100, "Cruel Architecture 2 should force traits to 100%.")
	TEST_ASSERT_EQUAL(run.get_wipe_grace(), DUNGEON_WIPE_GRACE_IRON, "Iron Contract should shorten the wipe grace.")
	TEST_ASSERT_EQUAL(run.get_echo_conversion(), DUNGEON_ECHO_CONVERSION + 10 * DUNGEON_HEAT_ECHO_BONUS, "Heat should raise echo conversion.")

	// Forced March lengthens future floors' stretches.
	run.advance_floor(run.current_break_room)
	TEST_ASSERT_EQUAL(run.stretch_length, run.floor_config.stretch_length + 2, "Forced March 2 should add two rooms per stretch.")

	// Sealed Mercy strips HEAL from every deck build and fallback draw.
	run.build_stretch_deck()
	TEST_ASSERT(!(DUNGEON_REWARD_HEAL in run.stretch_deck), "Sealed Mercy deck must contain no HEAL doors.")
	for(var/i in 1 to 25)
		TEST_ASSERT(run.draw_door_reward() != DUNGEON_REWARD_HEAL, "Sealed Mercy fallback draws must never yield HEAL.")
	qdel(run)

/datum/unit_test/dungeon_heat_gating
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_heat_gating/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	// Staged heat without the covenant unlock must not survive run creation.
	entrance.pending_heat_ranks = list(DUNGEON_HEAT_HARDENED = 2)
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	TEST_ASSERT_NOTNULL(run, "Run should exist.")
	TEST_ASSERT_EQUAL(run.get_total_heat(), 0, "Heat staged without the covenant must be discarded.")
	TEST_ASSERT_EQUAL(length(entrance.pending_heat_ranks), 0, "Pending heat should be consumed either way.")
	qdel(run)

/datum/unit_test/dungeon_dark_bargain
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_dark_bargain/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	// Dark boons never surface in normal offers.
	for(var/i in 1 to 5)
		var/list/datum/dungeon_boon/choices = get_dungeon_boon_choices(run, 20)
		for(var/datum/dungeon_boon/choice as anything in choices)
			TEST_ASSERT(!choice.dark_bargain_only, "Dark boon [choice.type] must never appear in a normal offer.")
			qdel(choice)

	// The altar builds two priced offers.
	var/obj/structure/dungeon_bargain_altar/altar = run.spawn_bargain_altar(run.current_break_room)
	TEST_ASSERT_NOTNULL(altar, "Bargain altar should spawn on a break-room turf.")
	TEST_ASSERT_EQUAL(length(altar.offers), 2, "Altar should hold two offers.")
	for(var/list/offer as anything in altar.offers)
		TEST_ASSERT((offer["price"] in list("flesh", "curse")), "Offer price must be flesh or curse.")
		var/datum/dungeon_boon/boon = offer["boon"]
		TEST_ASSERT_EQUAL(boon.rarity, DUNGEON_BOON_EPIC, "Bargain boons are always epic.")

	// Price of Flesh: cuts on apply, restores exactly on run teardown.
	var/base_max = delver.maxHealth
	run.add_boon(new /datum/dungeon_boon/dark_price/flesh)
	var/expected_cut = min(max(1, round(base_max * DUNGEON_BARGAIN_FLESH_CUT)), base_max - 1)
	TEST_ASSERT_EQUAL(delver.maxHealth, base_max - expected_cut, "Price of Flesh should cut max health.")
	qdel(run)
	TEST_ASSERT_EQUAL(delver.maxHealth, base_max, "Run teardown must restore the flesh price exactly.")

/datum/unit_test/dungeon_cursed_debt
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_cursed_debt/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	run.stretch_length = 3

	// Owed curses force the trait despite the test config's trait_chance = 0.
	run.cursed_rooms_owed = 2
	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	TEST_ASSERT_NOTNULL(forward_gate, "Break room should have a forward gate.")
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer the delver.")
	var/datum/pocket_dimension/dungeon/combat_room = forward_gate.destination_room
	TEST_ASSERT_NOTNULL(combat_room, "Combat room should exist.")
	TEST_ASSERT(istype(combat_room.current_trait, /datum/dungeon_room_trait/cursed), "Owed curse should force the Cursed trait.")
	TEST_ASSERT_EQUAL(run.cursed_rooms_owed, 1, "Building the cursed room should pay one curse down.")

	// The modifier lifecycle is idempotent both ways.
	var/datum/dungeon_room_trait/cursed = combat_room.current_trait
	cursed.on_mob_entered(combat_room, delver)
	cursed.on_mob_entered(combat_room, delver)
	cursed.on_mob_exited(combat_room, delver)
	cursed.on_mob_exited(combat_room, delver)

	// Clearing a cursed room pays compensation.
	var/motes_before = run.motes
	for(var/g_ref in combat_room.guardian_refs.Copy())
		var/datum/weakref/g_wr = combat_room.guardian_refs[g_ref]
		var/mob/living/g_mob = g_wr?.resolve()
		if(g_mob)
			qdel(g_mob)
	TEST_ASSERT(combat_room.cleared, "Cursed room should still clear normally.")
	TEST_ASSERT(run.motes > motes_before, "Breaking a cursed room should pay bonus motes.")
	qdel(run)

/datum/unit_test/dungeon_special_room_selection
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_special_room_selection/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	// Force the special slot at position 2, then walk one room forward: the
	// combat room's forward gates (leading to position 2) must carry it.
	run.special_room_position = 2
	run.special_room_kind = DUNGEON_POP_TRADER
	var/obj/structure/dungeon_gate/first_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			first_gate = gate
			break
	TEST_ASSERT_NOTNULL(first_gate, "Break room should have a forward gate.")
	TEST_ASSERT_NULL(first_gate.special_kind, "Position-1 doors must not be special (slot is at 2).")
	TEST_ASSERT(first_gate.use_gate(delver), "Gate should transfer the delver.")
	var/datum/pocket_dimension/dungeon/room_one = first_gate.destination_room
	TEST_ASSERT_NOTNULL(room_one, "First combat room should exist.")

	var/special_gates = 0
	var/obj/structure/dungeon_gate/special_gate
	for(var/obj/structure/dungeon_gate/gate as anything in room_one.gates)
		if(gate.gate_role != DUNGEON_GATE_FORWARD)
			continue
		if(gate.special_kind)
			special_gates++
			special_gate = gate
			TEST_ASSERT_NULL(gate.reward_type, "A special door must not carry a deck reward.")
		else
			TEST_ASSERT_NOTNULL(gate.reward_type, "Normal doors must still draw rewards.")
	TEST_ASSERT_EQUAL(special_gates, 1, "Exactly one door to position 2 should be special.")

	// Clear room one, walk the special door: a trader room.
	for(var/g_ref in room_one.guardian_refs.Copy())
		var/datum/weakref/g_wr = room_one.guardian_refs[g_ref]
		var/mob/living/g_mob = g_wr?.resolve()
		if(g_mob)
			qdel(g_mob)
	TEST_ASSERT(room_one.cleared, "Room one should clear.")
	var/depth_before = run.depth
	TEST_ASSERT(special_gate.use_gate(delver), "Special gate should transfer the delver.")
	var/datum/pocket_dimension/dungeon/trader_room = special_gate.destination_room
	TEST_ASSERT_NOTNULL(trader_room, "Trader room should exist.")
	TEST_ASSERT_EQUAL(trader_room.population_mode, DUNGEON_POP_TRADER, "Special room should carry the trader mode.")
	TEST_ASSERT(trader_room.cleared, "A trader room should start cleared.")
	TEST_ASSERT_EQUAL(run.depth, depth_before, "Freebie rooms must not advance depth.")
	TEST_ASSERT_NULL(run.special_room_kind, "The special slot should be consumed on build.")
	var/found_trader = FALSE
	for(var/turf/room_turf as anything in trader_room.affected_turfs)
		if(locate(/obj/structure/dungeon_trader) in room_turf)
			found_trader = TRUE
			break
	TEST_ASSERT(found_trader, "Trader room should contain a peddler stall.")
	qdel(run)

/datum/unit_test/dungeon_wave_room
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_wave_room/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/obj/structure/dungeon_gate/forward_gate
	for(var/obj/structure/dungeon_gate/gate as anything in run.current_break_room.gates)
		if(gate.gate_role == DUNGEON_GATE_FORWARD)
			forward_gate = gate
			break
	TEST_ASSERT_NOTNULL(forward_gate, "Break room should have a forward gate.")
	forward_gate.special_kind = DUNGEON_POP_WAVES
	forward_gate.reward_type = null
	TEST_ASSERT(forward_gate.use_gate(delver), "Gate should transfer the delver.")
	var/datum/pocket_dimension/dungeon/wave_room = forward_gate.destination_room
	TEST_ASSERT_NOTNULL(wave_room, "Wave room should exist.")
	TEST_ASSERT_EQUAL(wave_room.population_mode, DUNGEON_POP_WAVES, "Room should carry the waves mode.")
	TEST_ASSERT(!wave_room.cleared, "Wave room must not start cleared.")
	TEST_ASSERT(length(wave_room.guardian_refs), "Wave one should have spawned guardians.")
	TEST_ASSERT_EQUAL(wave_room.pending_waves, DUNGEON_WAVE_COUNT - 1, "Two waves should wait after wave one.")

	// Kill through every wave; the room must hold its clear until the last.
	var/motes_before = run.motes
	var/caches_before = length(wave_room.loot_caches)
	var/safety = 10
	while(!wave_room.cleared && safety > 0)
		safety--
		var/had_guardians = length(wave_room.guardian_refs)
		TEST_ASSERT(had_guardians, "An uncleared wave room must always have live guardians.")
		for(var/g_ref in wave_room.guardian_refs.Copy())
			var/datum/weakref/g_wr = wave_room.guardian_refs[g_ref]
			var/mob/living/g_mob = g_wr?.resolve()
			if(g_mob)
				qdel(g_mob)
	TEST_ASSERT(wave_room.cleared, "Wave room should clear after the final wave.")
	TEST_ASSERT_EQUAL(wave_room.pending_waves, 0, "No waves should remain after the clear.")
	TEST_ASSERT_EQUAL(run.depth, 1, "A finished wave room counts as one depth.")
	TEST_ASSERT(run.motes > motes_before, "Wave clear should pay a mote bounty.")
	TEST_ASSERT(length(wave_room.loot_caches) > caches_before, "Wave clear should spawn a loot cache.")
	qdel(run)

/datum/unit_test/dungeon_mystery_events
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_mystery_events/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	var/datum/pocket_dimension/dungeon/room = run.current_break_room

	// Every event type places its structure without runtimes.
	room.spawn_mystery_event(/datum/dungeon_mystery_event/fountain)
	room.spawn_mystery_event(/datum/dungeon_mystery_event/gamble)
	room.spawn_mystery_event(/datum/dungeon_mystery_event/trapped_chest)
	room.spawn_mystery_event(/datum/dungeon_mystery_event/riddle)
	var/obj/structure/dungeon_mote_fountain/fountain
	for(var/turf/room_turf as anything in room.affected_turfs)
		if(!fountain)
			fountain = locate(/obj/structure/dungeon_mote_fountain) in room_turf
	TEST_ASSERT_NOTNULL(fountain, "Fountain event should place a fountain.")

	// The fountain pays out once per delver. (The heal is the same adjust call
	// the shrine's proven Mend uses; motes are the deterministic probe here -
	// test-dummy carbons don't take bare adjustBruteLoss damage cleanly.)
	fountain.owning_run = run
	var/motes_before = run.motes
	fountain.attack_hand(delver)
	TEST_ASSERT(run.motes > motes_before, "Fountain should pay motes on the first sip.")
	var/motes_after_first = run.motes
	fountain.attack_hand(delver)
	TEST_ASSERT_EQUAL(run.motes, motes_after_first, "Fountain must refuse a second sip.")
	qdel(run)

/datum/unit_test/dungeon_synergy_gating
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_synergy_gating/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	// Synergies must never surface without their prerequisites. (initial()
	// cannot read list vars, so this guards the live-instance requires check.)
	for(var/i in 1 to 10)
		var/list/datum/dungeon_boon/cards = build_boon_offer(run, 3)
		for(var/datum/dungeon_boon/card as anything in cards)
			TEST_ASSERT(!length(card.requires), "Synergy [card.type] surfaced in an offer without its prerequisites.")
			qdel(card)

	// With prerequisites held, the dedicated last slot must carry the synergy.
	run.add_boon(new /datum/dungeon_boon/edge)
	run.add_boon(new /datum/dungeon_boon/fortune)
	TEST_ASSERT_EQUAL(get_available_synergy(run), /datum/dungeon_boon/battle_luck, "Battle Luck should become available once Edge and Fortune are held.")
	var/found_synergy = FALSE
	var/list/datum/dungeon_boon/offer_cards = build_boon_offer(run, 3)
	for(var/datum/dungeon_boon/card as anything in offer_cards)
		if(card.type == /datum/dungeon_boon/battle_luck)
			found_synergy = TRUE
		qdel(card)
	TEST_ASSERT(found_synergy, "A satisfied synergy should claim a slot in the offer.")
	qdel(run)

/datum/unit_test/dungeon_encounter_delve_curve/Run()
	var/datum/dungeon_run/run = new(null, null)

	// Floor-relative, NOT run-cumulative: piling up cleared rooms must not
	// raise the delve on its own (that was the runaway affix bug).
	run.floor = 1
	run.floor_config = get_dungeon_floor_config(1)
	var/shallow = run.get_encounter_delve()
	run.depth = 40
	TEST_ASSERT_EQUAL(run.get_encounter_delve(), shallow, "Cumulative depth must not raise the encounter delve.")

	// Deeper floors do raise it.
	run.floor = 3
	run.floor_config = get_dungeon_floor_config(3)
	var/deep = run.get_encounter_delve()
	TEST_ASSERT(deep > shallow, "A deeper floor should raise the encounter delve (floor 1 = [shallow], floor 3 = [deep]).")

	// And it is capped, however far the run descends.
	run.floor = 60
	run.floor_config = get_dungeon_floor_config(60)
	TEST_ASSERT(run.get_encounter_delve() <= DUNGEON_DELVE_MAX, "The encounter delve must stay capped at DUNGEON_DELVE_MAX.")
	qdel(run)

/datum/unit_test/dungeon_affix_count_capped/Run()
	var/datum/mob_affix_system/system = new
	TEST_ASSERT_EQUAL(system.get_max_affixes(1, 0), 1, "A shallow delve should still roll few affixes.")
	TEST_ASSERT_EQUAL(system.get_max_affixes(50, 5), MOB_AFFIX_MAX_ROLLED, "Affix count must be capped however deep the delve.")
	qdel(system)

/datum/unit_test/dungeon_loot_donor_budgets/Run()
	// Donors are normalized to a weight budget, so a many-entry table (food:
	// 15 entries) can no longer drown the curated gear list.
	var/datum/loot_table/dungeon/tier1/table = new
	var/list/weights = table.return_list(null, 1, 1.0)
	TEST_ASSERT(length(weights), "The tier-1 table should produce a weighted pool.")

	var/total = 0
	var/food_weight = 0
	for(var/path in weights)
		var/weight = weights[path]
		total += weight
		if(ispath(path, /obj/item/reagent_containers/food))
			food_weight += weight
	TEST_ASSERT(total > 0, "The pool should carry weight.")
	var/food_share = food_weight / total
	TEST_ASSERT(food_share < 0.2, "Food should be a garnish, not the meal (share was [round(food_share * 100, 0.1)]%).")
	qdel(table)

/datum/unit_test/dungeon_caches_roll_no_gold_piles/Run()
	// Gold piles hide in several donors, and every cache coin must arrive at half value.
	var/mob/living/carbon/human/looter = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/list/full_value_coins = list(/obj/item/coin/gold, /obj/item/coin/silver, /obj/item/coin/silver/pile, /obj/item/coin/copper/pile)
	for(var/datum/loot_table/dungeon/table_type as anything in subtypesof(/datum/loot_table/dungeon))
		if(IS_ABSTRACT(table_type))
			continue
		var/datum/loot_table/dungeon/table = new table_type
		var/list/pool = table.return_list(null, 5, 1.0) | table.return_list(looter, 5, 1.0)
		for(var/path in pool)
			TEST_ASSERT(!ispath(path, /obj/item/coin/gold/pile), "[table_type] should not roll gold piles.")
			TEST_ASSERT(!(path in full_value_coins), "[table_type] should pay [path] at half value.")
		qdel(table)

/datum/unit_test/dungeon_cache_opens_once/Run()
	var/mob/living/carbon/human/opener = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/latecomer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/structure/dungeon_loot_cache/cache = allocate(/obj/structure/dungeon_loot_cache, run_loc_floor_bottom_left)
	cache.loot = new /datum/loot_table/dungeon/tier1
	TEST_ASSERT(!cache.try_loot(opener), "A sealed cache should refuse to open.")
	cache.unseal()
	TEST_ASSERT(cache.try_loot(opener), "The first opener should take the spoils.")
	TEST_ASSERT(!cache.try_loot(latecomer), "A cache should open once; the party splits one roll.")
	TEST_ASSERT(!cache.try_loot(opener), "The opener should not roll the cache a second time.")

	// Greedy Eye adds one opening, and anyone may take it, so a solo delver still benefits.
	var/obj/structure/dungeon_loot_cache/greedy_cache = allocate(/obj/structure/dungeon_loot_cache, run_loc_floor_bottom_left)
	greedy_cache.loot = new /datum/loot_table/dungeon/tier1
	greedy_cache.claims_left += 1
	greedy_cache.unseal()
	TEST_ASSERT(greedy_cache.try_loot(opener), "The first opening should succeed.")
	TEST_ASSERT(greedy_cache.try_loot(opener), "The extra opening should not care who takes it.")
	TEST_ASSERT(!greedy_cache.try_loot(latecomer), "No opening should remain after the extra one.")

/datum/unit_test/dungeon_free_offers_payable/Run()
	// Banking is priced at 0 and spend_motes refuses anything <= 0, so every
	// vendor gate must run through try_pay_offer or banking is unreachable.
	var/datum/dungeon_run/run = new(null, null)
	TEST_ASSERT(!run.spend_motes(0), "spend_motes must keep refusing zero (its contract).")
	TEST_ASSERT(run.try_pay_offer(0), "A free offer must always be payable.")
	run.motes = 20
	TEST_ASSERT(!run.try_pay_offer(50), "An unaffordable offer must be refused.")
	TEST_ASSERT_EQUAL(run.motes, 20, "A refused offer must not spend anything.")
	TEST_ASSERT(run.try_pay_offer(20), "An affordable offer must be payable.")
	TEST_ASSERT_EQUAL(run.motes, 0, "A paid offer must deduct its cost.")

	// A pool too small to crystallize must survive instead of vanishing.
	run.motes = 1
	run.bank_motes_now(null) // no ckey: bails before conversion, must not clear
	TEST_ASSERT_EQUAL(run.motes, 1, "Banking without a valid banker must not consume the pool.")
	qdel(run)

/datum/unit_test/dungeon_ghosts_are_not_delvers
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_ghosts_are_not_delvers/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run
	var/datum/pocket_dimension/dungeon/room = run.current_break_room

	// A ghost floating in the room is a spectator, not an occupant. (Observers
	// relocate themselves during Initialize, so place it deliberately.)
	var/mob/dead/observer/watcher = new(room.get_entry_turf())
	watcher.forceMove(room.get_entry_turf())
	TEST_ASSERT(room.contains_turf(get_turf(watcher)), "The ghost should be standing in the room for this test to mean anything.")
	TEST_ASSERT(room.get_occupants()[watcher], "The base occupant sweep should still see the ghost.")
	TEST_ASSERT(!(watcher in run.get_members_in_room(room)), "A ghost must not count as a delver in the room.")

	// With the living delver pulled out, only the ghost remains - the run must
	// read as unoccupied so the abandonment timer can still collapse it.
	delver.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!run.has_client_occupants(), "A watching ghost alone must not keep a run alive.")
	qdel(watcher)
	qdel(run)

/datum/unit_test/dungeon_petition_no_remote_yank
	needs_pocket_space = TRUE

/datum/unit_test/dungeon_petition_no_remote_yank/Run()
	var/obj/structure/dungeon_entrance/infinite/entrance = allocate(/obj/structure/dungeon_entrance/infinite, run_loc_floor_bottom_left)
	entrance.theme_filter = DUNGEON_THEME_TEST
	var/mob/living/carbon/human/delver = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	delver.mind_initialize()
	TEST_ASSERT(entrance.try_enter(delver), "Entrance should accept the delver.")
	var/datum/dungeon_run/run = entrance.active_run

	var/mob/living/carbon/human/latecomer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	latecomer.mind_initialize()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/far_off = locate(origin.x + 5, origin.y, origin.z)
	TEST_ASSERT_NOTNULL(far_off, "The test area should be wide enough to stand clear of the entrance.")
	latecomer.forceMove(far_off)

	// Approving someone who walked away must invite them back, never teleport them.
	run.admit_petitioner(latecomer)
	TEST_ASSERT_EQUAL(get_turf(latecomer), far_off, "An away petitioner must not be yanked into the dungeon.")
	TEST_ASSERT((WEAKREF(latecomer) in run.accepted_petitioners), "The approval should be remembered for when they return.")

	// Back at the mouth they are admitted for real, and the remembered approval
	// is spent. (petition_to_join itself needs a client, which test mobs lack,
	// so drive the admission path the entrance would call.)
	latecomer.forceMove(origin)
	run.admit_petitioner(latecomer)
	TEST_ASSERT(run.current_break_room.contains_turf(get_turf(latecomer)), "A petitioner at the mouth should be admitted.")
	TEST_ASSERT(!(WEAKREF(latecomer) in run.accepted_petitioners), "Descending should consume the remembered approval.")
	qdel(run)

/datum/unit_test/dungeon_shrine_undoes_trauma/Run()
	var/obj/structure/dungeon_shrine/shrine = allocate(/obj/structure/dungeon_shrine, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/dungeon_run/run = new(null, null)
	shrine.owning_run = run

	// Priced above mending mere wounds.
	var/heal_cost = 0
	var/revive_cost = 0
	for(var/list/offer as anything in shrine.build_shrine_offers())
		switch(offer["id"])
			if("heal")
				heal_cost = offer["cost"]
			if("revive")
				revive_cost = offer["cost"]
	TEST_ASSERT(revive_cost > 0, "The shrine should offer to undo a defeat trauma.")
	TEST_ASSERT(revive_cost > heal_cost, "Undoing a trauma should cost more than mending wounds.")

	// Refused (and never charged) when there is nothing to undo.
	TEST_ASSERT(!shrine.can_buy_offer("revive", patient), "An untraumatized buyer must be refused before payment.")

	// With a trauma carried, it clears exactly that one.
	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/physical/leg, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT(patient.has_any_defeat_trauma(), "The test trauma should have applied.")
	TEST_ASSERT(shrine.can_buy_offer("revive", patient), "A traumatized buyer should be allowed to pay.")
	shrine.apply_shrine_offer("revive", patient)
	TEST_ASSERT(!patient.has_any_defeat_trauma(), "Buying the revive should lift the trauma.")

	// Grievous Wounds are town-clinic-only: the shrine must refuse the sale
	// rather than pocket the motes for a hurt it cannot touch.
	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/grievous, DEFEAT_SEVERITY_SEVERE)
	TEST_ASSERT(patient.has_any_defeat_trauma(), "The grievous trauma should have applied.")
	TEST_ASSERT(!shrine.has_treatable_trauma(patient), "Grievous Wounds alone leave nothing this shrine can lift.")
	TEST_ASSERT(!shrine.can_buy_offer("revive", patient), "A buyer carrying only Grievous Wounds must be refused before payment.")

	// A lesser hurt alongside it can still be bought - and the grievous one stays.
	patient.apply_defeat_trauma_status(/datum/status_effect/debuff/defeat/physical/leg, DEFEAT_SEVERITY_NORMAL)
	TEST_ASSERT(shrine.has_treatable_trauma(patient), "A lesser hurt alongside a maiming is still treatable.")
	TEST_ASSERT(shrine.can_buy_offer("revive", patient), "The sale should go through when something is liftable.")
	shrine.apply_shrine_offer("revive", patient)
	TEST_ASSERT_NOTNULL(patient.has_status_effect(/datum/status_effect/debuff/defeat/grievous), "The shrine must not cure Grievous Wounds.")

	// An unliftable purchase refunds rather than eating the motes.
	run.motes = 500
	var/motes_before = run.motes
	shrine.apply_shrine_offer("revive", patient)
	TEST_ASSERT_EQUAL(run.motes, motes_before + DUNGEON_SHRINE_TRAUMA_COST, "A revive that lifts nothing must refund its cost.")
	qdel(run)
