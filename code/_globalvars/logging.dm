GLOBAL_VAR(round_id)
GLOBAL_PROTECT(round_id)
GLOBAL_VAR(log_directory)
GLOBAL_PROTECT(log_directory)
/// log_runtime() text from before SetupLogs; replayed into runtime.log once it exists.
GLOBAL_LIST(early_runtime_logs)
GLOBAL_PROTECT(early_runtime_logs)

#define DECLARE_LOG_NAMED(log_var_name, log_file_name, start)\
GLOBAL_VAR(##log_var_name);\
GLOBAL_PROTECT(##log_var_name);\
/world/_initialize_log_files(temp_log_override = null){\
	..();\
	GLOB.##log_var_name = temp_log_override || "[GLOB.log_directory]/[##log_file_name].log";\
	if(!temp_log_override && ##start){\
		start_log(GLOB.##log_var_name);\
	}\
}

#define DECLARE_LOG(log_name, start) DECLARE_LOG_NAMED(##log_name, "[copytext(#log_name, 1, length(#log_name) - 4)]", start)
#define START_LOG TRUE
#define DONT_START_LOG FALSE

/// Populated by log declaration macros to set log file names and start messages
/world/proc/_initialize_log_files(temp_log_override = null)
	// Needs to be here to avoid compiler warnings
	SHOULD_CALL_PARENT(TRUE)
	return

DECLARE_LOG_NAMED(character_list_log, "character_list", START_LOG)
DECLARE_LOG_NAMED(config_error_log, "config_error", DONT_START_LOG)
DECLARE_LOG_NAMED(hunted_log, "hunted", START_LOG)
DECLARE_LOG_NAMED(query_debug_log, "query_debug", DONT_START_LOG)
DECLARE_LOG_NAMED(sql_error_log, "sql", DONT_START_LOG)
DECLARE_LOG_NAMED(tgui_log, "tgui", START_LOG)
DECLARE_LOG_NAMED(world_asset_log, "asset", DONT_START_LOG)
DECLARE_LOG_NAMED(world_attack_log, "attack", START_LOG)
DECLARE_LOG_NAMED(world_cloning_log, "cloning", DONT_START_LOG)
DECLARE_LOG_NAMED(world_game_log, "game", START_LOG)
DECLARE_LOG_NAMED(world_href_log, "hrefs", START_LOG)
DECLARE_LOG_NAMED(world_job_debug_log, "job_debug", START_LOG)
DECLARE_LOG_NAMED(world_manifest_log, "manifest", START_LOG)
DECLARE_LOG_NAMED(world_map_error_log, "map_errors", DONT_START_LOG)
DECLARE_LOG_NAMED(world_mecha_log, "mecha", DONT_START_LOG)
DECLARE_LOG_NAMED(world_paper_log, "paper", DONT_START_LOG)
DECLARE_LOG_NAMED(world_pda_log, "pda", START_LOG)
DECLARE_LOG_NAMED(world_qdel_log, "qdel", START_LOG)
DECLARE_LOG_NAMED(world_runtime_log, "runtime", START_LOG)
DECLARE_LOG_NAMED(world_telecomms_log, "telecomms", START_LOG)
DECLARE_LOG_NAMED(world_virus_log, "virus", DONT_START_LOG)
DECLARE_LOG(perf_log, DONT_START_LOG)
#ifdef REFERENCE_TRACKING_LOG_APART
DECLARE_LOG_NAMED(harddel_log, "harddels", START_LOG)
#endif
#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
DECLARE_LOG_NAMED(test_log, "tests", START_LOG)
#endif

#undef DECLARE_LOG_NAMED
#undef DECLARE_LOG
#undef START_LOG
#undef DONT_START_LOG

GLOBAL_LIST_EMPTY(character_list)
GLOBAL_LIST_EMPTY(character_ckey_list)
GLOBAL_LIST_EMPTY(actors_list)
GLOBAL_VAR(rogue_round_id)

GLOBAL_LIST_EMPTY(bombers)
GLOBAL_PROTECT(bombers)
GLOBAL_LIST_EMPTY(admin_log)
GLOBAL_PROTECT(admin_log)
GLOBAL_LIST_EMPTY(lastsignalers)	//keeps last 100 signals here in format: "[src] used [REF(src)] @ location [src.loc]: [freq]/[code]"
GLOBAL_PROTECT(lastsignalers)
GLOBAL_LIST_EMPTY(lawchanges) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
GLOBAL_PROTECT(lawchanges)

GLOBAL_LIST_EMPTY(combatlog)
GLOBAL_PROTECT(combatlog)
GLOBAL_LIST_EMPTY(IClog)
GLOBAL_PROTECT(IClog)
GLOBAL_LIST_EMPTY(OOClog)
GLOBAL_PROTECT(OOClog)
GLOBAL_LIST_EMPTY(adminlog)
GLOBAL_PROTECT(adminlog)

GLOBAL_LIST_EMPTY(active_turfs_startlist)

/////Picture logging
GLOBAL_VAR(picture_log_directory)
GLOBAL_PROTECT(picture_log_directory)

GLOBAL_VAR_INIT(picture_logging_id, 1)
GLOBAL_PROTECT(picture_logging_id)
GLOBAL_VAR(picture_logging_prefix)
GLOBAL_PROTECT(picture_logging_prefix)
/////
