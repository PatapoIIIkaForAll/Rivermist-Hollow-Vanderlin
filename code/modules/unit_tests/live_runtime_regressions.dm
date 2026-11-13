// Regression tests for runtimes seen on the live server; a runtime here fails the test through the error handler.

// Save keys are file-local in triumphs.dm.
#define TEST_TRIUMPH_SEASON "triumph_wipe_season"
#define TEST_TRIUMPH_AMOUNT "triumph_count"

/datum/unit_test/live_runtime_find_field_dies_with_possession
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_find_field_dies_with_possession/Run()
	var/mob/living/simple_animal/hostile/pawn = allocate(/mob/living/simple_animal/hostile)
	var/datum/ai_controller/controller = pawn.ai_controller
	if(!controller)
		controller = allocate(/datum/ai_controller, pawn)
	var/datum/ai_behavior/find_and_set/humans/behavior = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/humans)
	TEST_ASSERT_NOTNULL(behavior, "find_and_set/humans behavior singleton is missing.")

	var/datum/proximity_monitor/advanced/ai_find_tracking/field = new(pawn, 3, TRUE, behavior, controller, BB_BASIC_MOB_FLEE_TARGET, /mob/living/carbon/human, 3)
	controller.set_blackboard_key(BB_FIND_TARGETS_FIELD(behavior.type), field)
	controller.UnpossessPawn(FALSE)
	TEST_ASSERT(QDELETED(field), "A detection field outlived the possession of the pawn it is hosted on.")

	// A field whose controller is deleted outright must go with it.
	var/mob/living/simple_animal/hostile/second_pawn = allocate(/mob/living/simple_animal/hostile)
	var/datum/ai_controller/second_controller = second_pawn.ai_controller
	if(!second_controller)
		second_controller = allocate(/datum/ai_controller, second_pawn)
	var/datum/proximity_monitor/advanced/ai_find_tracking/second_field = new(second_pawn, 3, TRUE, behavior, second_controller, BB_BASIC_MOB_FLEE_TARGET, /mob/living/carbon/human, 3)
	qdel(second_controller)
	TEST_ASSERT(QDELETED(second_field), "A detection field outlived its deleted controller.")

/datum/unit_test/live_runtime_bounded_removal_unregisters
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_bounded_removal_unregisters/Run()
	var/obj/item/bound_item = allocate(/obj/item)
	var/obj/item/anchor_item = allocate(/obj/item)
	var/datum/component/bounded/tether = bound_item.AddComponent(/datum/component/bounded, anchor_item, 0, 5, null, null, FALSE, FALSE)
	TEST_ASSERT_NOTNULL(tether, "Bounded component was not created.")

	tether.RemoveComponent()
	TEST_ASSERT(!length(tether.signal_procs), "A removed bounded component still listens to [length(tether.signal_procs)] datum(s).")
	// Moving the former parent must not reach the detached component.
	bound_item.forceMove(run_loc_floor_top_right)
	qdel(tether)

/datum/unit_test/live_runtime_surgery_tool_without_behaviour
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_surgery_tool_without_behaviour/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	patient.set_body_position(LYING_DOWN)
	var/obj/item/blunt_tool = allocate(/obj/item)
	blunt_tool.tool_behaviour = NONE
	blunt_tool.sharpness = IS_BLUNT
	// check_availability reaches tool_check through get_tool_quality before any target checks.
	for(var/operation_type in list(
		/datum/surgery_operation/limb/incise_skin,
		/datum/surgery_operation/limb/saw_bones,
		/datum/surgery_operation/basic/incise_skin,
		/datum/surgery_operation/basic/saw_bone,
	))
		var/datum/surgery_operation/operation = GLOB.operations.operations_by_typepath[operation_type]
		TEST_ASSERT_NOTNULL(operation, "[operation_type] is not registered.")
		var/atom/movable/operate_on = operation.get_operation_target(patient, BODY_ZONE_CHEST) || patient
		TEST_ASSERT(!operation.check_availability(patient, operate_on, surgeon, blunt_tool, BODY_ZONE_CHEST), "[operation_type] accepted a blunt item with no tool behaviour.")

/datum/unit_test/live_runtime_germs_skip_missing_limb
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_germs_skip_missing_limb/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	TEST_ASSERT_NOTNULL(arm, "Test human has no left arm to remove.")
	arm.drop_limb()
	TEST_ASSERT_NULL(patient.get_bodypart(BODY_ZONE_L_ARM), "Left arm was not removed.")
	patient.adjust_germ_level_directed(10, 0, 100, list(BODY_ZONE_L_ARM, BODY_ZONE_CHEST))

/datum/unit_test/live_runtime_triumph_save_recovers
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_triumph_save_recovers/Run()
	var/test_ckey = "zzlivetriumphtest"
	var/save_dir = "data/player_saves/[test_ckey[1]]/[test_ckey]/"
	var/path = SStriumphs.player_save_path(test_ckey)
	fdel(save_dir)

	// An empty save must reset instead of failing every decode.
	text2file("{", path)
	var/list/data = SStriumphs.read_player_data(test_ckey)
	TEST_ASSERT(islist(data), "An unreadable triumph save did not decode to a list.")
	TEST_ASSERT_EQUAL(data[TEST_TRIUMPH_AMOUNT], 0, "A reset triumph save should hold zero triumphs.")
	TEST_ASSERT(fexists("[path].corrupt"), "The unreadable save was not kept for inspection.")

	SStriumphs.write_player_triumphs(test_ckey, 7)
	data = SStriumphs.read_player_data(test_ckey)
	TEST_ASSERT_EQUAL(data[TEST_TRIUMPH_AMOUNT], 7, "write_player_triumphs did not persist the amount.")

	// A write interrupted after deleting the real save leaves only the temp file.
	SStriumphs.write_player_save(test_ckey, list(TEST_TRIUMPH_SEASON = GLOB.triumph_wipe_season, TEST_TRIUMPH_AMOUNT = 5))
	fcopy(path, "[path].tmp")
	fdel(path)
	data = SStriumphs.read_player_data(test_ckey)
	TEST_ASSERT_EQUAL(data[TEST_TRIUMPH_AMOUNT], 5, "The temp file of an interrupted write was not restored.")
	TEST_ASSERT(fexists(path), "Restoring from the temp file did not recreate the save.")

	SStriumphs.triumph_amount_cache -= test_ckey
	fdel(save_dir)

/datum/unit_test/live_runtime_tongs_ignore_non_items
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_tongs_ignore_non_items/Run()
	var/mob/living/carbon/human/smith = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human)
	var/obj/item/weapon/tongs/tongs = allocate(/obj/item/weapon/tongs)
	TEST_ASSERT_EQUAL(tongs.interact_with_atom(bystander, smith), NONE, "Tongs should ignore a mob.")

/datum/unit_test/live_runtime_has_reagent_without_holder
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_has_reagent_without_holder/Run()
	var/mob/living/simple_animal/hostile/creature = allocate(/mob/living/simple_animal/hostile)
	creature.reagents = null
	TEST_ASSERT(!creature.has_reagent(/datum/reagent/water), "A mob without a reagent holder reported a reagent.")

/datum/unit_test/live_runtime_ghost_skill_reads
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_ghost_skill_reads/Run()
	var/mob/dead/observer/ghost = allocate(/mob/dead/observer)
	TEST_ASSERT_NULL(ghost.attributes, "Observers should carry no attribute holder.")
	TEST_ASSERT_EQUAL(ghost.get_skill_level(/datum/skill/combat/axes), 0, "A ghost skill read should be zero.")

/datum/unit_test/live_runtime_storm_lightning_without_targets
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_storm_lightning_without_targets/Run()
	var/datum/particle_weather/rain/rain_storm/storm = new
	var/list/old_turfs = SSParticleWeather.weathered_turfs
	SSParticleWeather.weathered_turfs = list()
	storm.tick()
	SSParticleWeather.weathered_turfs = old_turfs
	TEST_ASSERT(!COOLDOWN_FINISHED(storm, thunder), "A failed lightning search should still start the thunder cooldown.")
	qdel(storm)

/datum/unit_test/live_runtime_deleted_mob_releases_attributes
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_deleted_mob_releases_attributes/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/datum/attribute_holder/holder = victim.attributes
	TEST_ASSERT(istype(holder), "Test human has no attribute holder.")
	qdel(victim)
	TEST_ASSERT(QDELETED(holder), "A deleted mob left its attribute holder alive; the pair is a reference cycle.")
	TEST_ASSERT_NULL(holder.parent, "The attribute holder still points at its deleted mob.")

/datum/unit_test/live_runtime_deleted_creature_deletes_organs
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_deleted_creature_deletes_organs/Run()
	var/mob/living/simple_animal/hostile/retaliate/wolf/creature = allocate(/mob/living/simple_animal/hostile/retaliate/wolf)
	var/list/organs = creature.internal_organs.Copy()
	TEST_ASSERT(length(organs), "Test creature spawned without organs.")
	qdel(creature)
	for(var/obj/item/organ/organ as anything in organs)
		TEST_ASSERT(QDELETED(organ), "[organ.type] outlived its deleted creature and still points at it.")

/datum/unit_test/live_runtime_limb_icon_cache_bounded
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_limb_icon_cache_bounded/Run()
	var/mob/living/carbon/human/model = allocate(/mob/living/carbon/human)
	for(var/i in 1 to 1100)
		model.store_limb_icons("live_runtime_test_[i]", list())
	TEST_ASSERT(length(model.limb_icon_cache) <= 1000, "limb_icon_cache grew to [length(model.limb_icon_cache)] keys.")
	TEST_ASSERT(model.limb_icon_cache["live_runtime_test_1100"], "The newest render key was not cached.")
	for(var/i in 1 to 1100)
		model.limb_icon_cache -= "live_runtime_test_[i]"

/datum/unit_test/live_runtime_failed_hard_deletes_bounded
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_failed_hard_deletes_bounded/Run()
	if(SSgarbage.enable_hard_deletes)
		return
	var/list/old_failures = SSgarbage.failed_hard_deletes.Copy()
	for(var/i in 1 to FAILED_HARD_DELETES_KEPT + 10)
		SSgarbage.HardDelete(new /datum)
	TEST_ASSERT_EQUAL(length(SSgarbage.failed_hard_deletes), FAILED_HARD_DELETES_KEPT, "Skipped hard deletes are kept without a bound.")
	SSgarbage.failed_hard_deletes = old_failures

/datum/unit_test/live_runtime_hud_releases_screens
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_hud_releases_screens/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	var/datum/hud/human/hud = new(wearer)
	wearer.set_hud_used(hud)
	TEST_ASSERT_NOTNULL(hud.stressies, "Test hud built no stress screen.")
	qdel(hud)
	// The GC queue holds the hud for 5 minutes; its screen vars must not pin the screens meanwhile.
	for(var/varname in list("stressies", "rmb_intent", "bloods", "quad_intents", "cmode_button", "give_intent", "hsover", "mana_over", "cdleft", "cdright", "cdmid", "stamina", "energy", "mana", "hand_slots"))
		TEST_ASSERT_NULL(hud.vars[varname], "Deleted hud still holds [varname].")

/datum/unit_test/live_runtime_image_census_counts_holders
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_image_census_counts_holders/Run()
	var/list/counts = list()
	var/list/kept = list(image('icons/effects/effects.dmi', "nothing"), mutable_appearance('icons/effects/effects.dmi', "nothing"))
	image_census_value(kept, "test.kept", counts, list(), 0)
	TEST_ASSERT_EQUAL(counts["test.kept\[] (image)"], 1, "The census missed an image inside a list.")
	TEST_ASSERT_EQUAL(counts["test.kept\[] (mutable appearance)"], 1, "The census missed a mutable appearance inside a list.")

/datum/unit_test/live_runtime_http_request_timeout
#ifdef FOCUS_LIVE_RUNTIME_REGRESSIONS
	focus = TRUE
#endif

/datum/unit_test/live_runtime_http_request_timeout/Run()
	var/datum/http_request/plain = http_request(RUSTG_HTTP_METHOD_GET, "http://127.0.0.1:1/")
	TEST_ASSERT_NULL(plain.build_options(), "A request without options must still pass null to rust_g.")

	var/datum/http_request/request = http_request(RUSTG_HTTP_METHOD_GET, "http://127.0.0.1:1/", "", null, null, 2)
	var/raw_options = request.build_options()
	TEST_ASSERT_NOTNULL(raw_options, "The timeout is not passed to rust_g.")
	var/list/options = json_decode(raw_options)
	TEST_ASSERT_EQUAL(options["timeout_seconds"], 2, "The timeout is not passed to rust_g.")
	// Port 1 refuses the connection, so the wait must return an errored response, not hit its deadline.
	request.begin_async()
	var/datum/http_response/response = request.wait_for_response(10 SECONDS)
	TEST_ASSERT_NOTNULL(response, "A refused request ran into the wait deadline.")
	TEST_ASSERT(response.errored, "A refused request did not report an error.")

#undef TEST_TRIUMPH_SEASON
#undef TEST_TRIUMPH_AMOUNT
