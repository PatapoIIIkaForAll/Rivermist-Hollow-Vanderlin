/// Captured during proc-static initialization, before world/New runs.
/proc/startup_global_state()
	var/static/controllers_ready = !!(Master && GLOB && Debugger && Tracy)
	return controllers_ready

/datum/unit_test/startup
#ifdef FOCUS_STARTUP_TESTS
	focus = TRUE
#endif

/datum/unit_test/startup/proc/early_state()
	var/static/list/snapshot = list(
		"controllers" = !!(Master && GLOB && Debugger && Tracy),
		"species" = length(GLOB.species_list),
		"patrons" = length(GLOB.patron_list),
		"blueprints" = length(GLOB.blueprint_recipes),
		"config_log" = GLOB.config_error_log,
		"game_log" = GLOB.world_game_log,
		"asset_log" = GLOB.world_asset_log,
	)
	return snapshot

/datum/unit_test/startup/Run()
	TEST_ASSERT(startup_global_state(), "Genesis must also precede other global-proc statics.")
	var/list/snapshot = early_state()
	TEST_ASSERT(snapshot["controllers"], "Genesis must create controllers before other proc statics run: [json_encode(snapshot)]")
	TEST_ASSERT(snapshot["species"] && snapshot["patrons"] && snapshot["blueprints"], "RMH registries must exist before proc statics run.")
	TEST_ASSERT(snapshot["config_log"], "Genesis must initialize temporary logging.")
	TEST_ASSERT_EQUAL(snapshot["game_log"], snapshot["config_log"], "Early game logs must use the temporary log.")
	TEST_ASSERT_EQUAL(snapshot["asset_log"], snapshot["config_log"], "Even non-game logs must be usable during startup.")
	TEST_ASSERT_EQUAL(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log", "SetupLogs must replace the temporary config path.")
	TEST_ASSERT_EQUAL(GLOB.character_list_log, "[GLOB.log_directory]/character_list.log", "Keep RMH log filenames.")
	TEST_ASSERT_NULL(GLOB.early_runtime_logs, "SetupLogs must replay startup runtimes into runtime.log.")
	TEST_ASSERT(global.config.loaded, "Configuration must be marked loaded before the round starts.")

/datum/unit_test/native_profiler
#ifdef FOCUS_STARTUP_TESTS
	focus = TRUE
#endif

/datum/unit_test/native_profiler/Run()
	var/old_auto_profile = CONFIG_GET(flag/auto_profile)
	var/old_forbid = CONFIG_GET(flag/forbid_all_profiling)
	CONFIG_SET(flag/auto_profile, TRUE)
	CONFIG_SET(flag/forbid_all_profiling, FALSE)
	SSprofiler.OnConfigLoad()
	var/profiling_enabled = SSprofiler.can_fire
	SSprofiler.DumpFile(allow_yield = FALSE)
	// Avoid sampling time dilation twice in the same tick.
	while(world.time <= SStime_track.last_tick_byond_time)
		sleep(world.tick_lag)
	SStime_track.fire()
	SSprofiler.Shutdown()
	var/profile_path = "[GLOB.log_directory]/profiler/profiler-[round(world.time * 0.1, 10)].json"
	var/sendmaps_path = "[GLOB.log_directory]/profiler/sendmaps-[round(world.time * 0.1, 10)].json"
	var/list/profile_data = json_decode(file2text(profile_path))
	var/list/sendmaps_data = json_decode(file2text(sendmaps_path))

	CONFIG_SET(flag/forbid_all_profiling, TRUE)
	SSprofiler.OnConfigLoad()
	var/profiling_forbidden = !SSprofiler.can_fire
	CONFIG_SET(flag/auto_profile, old_auto_profile)
	CONFIG_SET(flag/forbid_all_profiling, old_forbid)
	SSprofiler.OnConfigLoad()

	// Flush native buffers before validating the actual CSV written by time tracking.
	shutdown_logging()
	var/list/perf_lines = splittext(trim(file2text(GLOB.perf_log)), "\n")
	TEST_ASSERT(profiling_enabled, "Auto profiling must enable scheduled dumps.")
	TEST_ASSERT(islist(profile_data) && islist(sendmaps_data), "Native profiling and shutdown must write valid JSON dumps.")
	TEST_ASSERT(profiling_forbidden, "Forbidding profiling must stop scheduled dumps.")
	TEST_ASSERT(length(perf_lines) >= 2, "The CSV header and sample must be separate lines.")
	var/expected_columns = 8 + 2 * length(SStime_track.sendmaps_names_map)
	for(var/perf_line in perf_lines)
		TEST_ASSERT_EQUAL(length(splittext(perf_line, ",")), expected_columns, "Every CSV row must match the header's column count.")
