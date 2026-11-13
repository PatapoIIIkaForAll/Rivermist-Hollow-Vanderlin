GLOBAL_LIST_EMPTY(preferences_datums)

GLOBAL_LIST_EMPTY(chosen_names)

GLOBAL_LIST_INIT(name_adjustments, list())

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 20

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	/// the ghost icon this admin ghost will get when becoming an aghost.
	var/admin_ghost_icon = null
	var/triumphs = 0

	//Antag preferences
	var/list/be_special = list()		//Special role selection

	// Custom Keybindings
	var/list/key_bindings = list()

	var/db_flags

	//character preferences
	/// Keeps track of round-to-round randomization of the character slot, prevents overwriting.
	var/slot_randomized

	COOLDOWN_DECLARE(voice_previewing)
	COOLDOWN_DECLARE(moan_previewing)

	/// The species this character is.
	var/datum/species/pref_species = new /datum/species/human/northern() //Mutant race
	var/list/features = MANDATORY_FEATURE_LIST
	var/list/randomise = list(
		(RANDOM_BODY) = FALSE,
		(RANDOM_BODY_ANTAG) = FALSE,
		//(RANDOM_UNDERWEAR) = FALSE,
		//(RANDOM_UNDERWEAR_COLOR) = FALSE,
		//(RANDOM_UNDERSHIRT) = FALSE,
		(RANDOM_SKIN_TONE) = FALSE,
		(RANDOM_EYE_COLOR) = FALSE
	)

	var/list/custom_names = list()

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()
	/// job.title -> list("title" = chosen title, "honorary" = chosen prefix)
	var/list/alt_job_selections = list()

	var/list/ignoring = list()

	var/combat_music_helptext_shown = FALSE

	var/lastclass

	var/list/exp = list()
	var/list/menuoptions

	var/datum/migrant_pref/migrant
	var/next_special_trait = null

	var/action_buttons_screen_locs = list()

	var/list/quirks = list()
	var/list/quirk_customizations = list() // Maps quirk_type -> customization_value
	var/list/quirk_extra_customizations = list() // Maps quirk_type -> list(key = value, ...)

	var/list/customizer_entries = list()
	var/list/list/body_markings = list()
	var/update_mutant_colors = TRUE

	var/list/descriptor_entries = list()
	var/list/custom_descriptors = list()

	var/datum/loadout_item/loadout1
	var/datum/loadout_item/loadout2
	var/datum/loadout_item/loadout3
	var/datum/loadout_item/loadout4
	var/datum/loadout_item/loadout5
	var/datum/loadout_item/loadout6
	var/datum/loadout_item/loadout7
	var/datum/loadout_item/loadout8
	var/datum/loadout_item/loadout9
	var/datum/loadout_item/loadout10

	var/loadout_1_hex
	var/loadout_2_hex
	var/loadout_3_hex
	var/loadout_4_hex
	var/loadout_5_hex
	var/loadout_6_hex
	var/loadout_7_hex
	var/loadout_8_hex
	var/loadout_9_hex
	var/loadout_10_hex

	// Custom names for loadout items
	var/loadout_1_name
	var/loadout_2_name
	var/loadout_3_name
	var/loadout_4_name
	var/loadout_5_name
	var/loadout_6_name
	var/loadout_7_name
	var/loadout_8_name
	var/loadout_9_name
	var/loadout_10_name

	// Custom descriptions for loadout items
	var/loadout_1_desc
	var/loadout_2_desc
	var/loadout_3_desc
	var/loadout_4_desc
	var/loadout_5_desc
	var/loadout_6_desc
	var/loadout_7_desc
	var/loadout_8_desc
	var/loadout_9_desc
	var/loadout_10_desc

	// Loadout preset storage - 3 slots for saving/loading character customization
	var/list/loadout_preset_1
	var/list/loadout_preset_2
	var/list/loadout_preset_3

	var/list/preference_message_list = list()

	/// Tracker to whether the person has ever spawned into the round, for purposes of applying the respawn ban
	var/has_spawned = FALSE
	/// If our owner is from a race that has more than one accent
	var/change_accent = FALSE
	/// Current character setup tab; UI-only and never persisted.
	var/current_tab = 0

	var/datum/job/advclass/preview_subclass
	var/tmp/preview_image_revision = 0
	var/tmp/preview_update_generation = 0
	var/tmp/preview_resource_token
	var/tmp/preview_render_in_progress = FALSE
	var/tmp/preview_render_pending = FALSE
	var/tmp/preview_pending_force_push = FALSE
	var/tmp/preview_pending_fingerprint
	var/tmp/preview_active_fingerprint
	var/tmp/preview_browser_fingerprint
	var/tmp/preview_rate_limit_release_time = 0
	var/tmp/preview_rate_limit_callback_pending = FALSE
	var/tmp/list/preview_update_request_times = list()
	var/tmp/list/preview_sheet_cache = list()
	var/tmp/list/preview_sheet_cache_order = list()
	///this is our character slot
	var/tmp/current_slot = 1
	/// Incremented whenever ERP preference data changes so runtime caches can cheaply detect stale values.
	var/tmp/erp_preferences_revision = 0
	/// List of character slot indices selected for multi-ready (in priority order)
	var/list/multi_ready_slots = list()

	var/datum/multi_ready_ui/multi_ready_panel

	/// Cached values keyed by /datum/preference type. This is the sole storage for datumized preferences.
	var/list/preference_cache = list()


/datum/preferences/New(client/C)
	parent = C

	migrant  = new /datum/migrant_pref(src)

	for(var/custom_name_id in GLOB.preferences_custom_names)
		custom_names[custom_name_id] = get_default_name(custom_name_id)

	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			max_save_slots += 35
	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			if(check_nameban(C.ckey))
				write_preference(/datum/preference/text/real_name, pref_species.random_name(read_preference(/datum/preference/choiced/gender), TRUE))
			return
	//we couldn't load character data so just randomize the character appearance + name
	randomise_appearance_prefs()
	customizer_entries = list()
	validate_customizer_entries()
	reset_all_customizer_accessory_colors()
	randomize_all_customizer_accessories()
	genderize_customizer_entries()		//let's create a random character then - rather than a fat, bald and naked man.
	key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key) // give them default keybinds and update their movement keys
	if(isclient(C))
		C.update_movement_keys()
	write_preference(/datum/preference/text/real_name, pref_species.random_name(read_preference(/datum/preference/choiced/gender), TRUE))
	setup_default_erp_preferences()
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.
	menuoptions = list()

/datum/preferences/Destroy()
	character_setup_teardown_view(null)
	character_setup_ui_heavy_cache = null
	parent = null
	preview_subclass = null

	QDEL_NULL(migrant)
	QDEL_NULL(pref_species)
	QDEL_NULL(multi_ready_panel)
	QDEL_LIST(customizer_entries)
	QDEL_LIST(descriptor_entries)
	QDEL_LIST(custom_descriptors)

	for(var/i in 1 to 10)
		QDEL_NULL(vars["loadout[i]"])

	return ..()

/datum/preferences/Topic(href, href_list, hsrc)			//yeah, gotta do this I guess..
	. = ..()
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()

#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='14%'>"
#define MAX_MUTANT_ROWS 4
#define PREFERENCE_BODY_COLOR_MIN_LIGHTNESS 0
#define PREFERENCE_BODY_COLOR_MAX_LIGHTNESS 1
#define PREFERENCE_BODY_COLOR_MAX_SATURATION 1

/datum/preferences/proc/show_choices(mob/user, tabchoice)
	if(!user || !user.client)
		return
	if(isnewplayer(user) && !ensure_defeat_introduction(user))
		return
	if(slot_randomized)
		load_character(default_slot)
		slot_randomized = FALSE

	character_setup_preferences_initial_tab = (tabchoice == 1) ? "game" : "identity"
	character_setup_preferences_open_sequence++
	build_and_show_menu(user)

/datum/preferences/proc/build_and_show_menu(mob/user)
	if(!user?.client)
		return
	user.client.acquire_dpi()
	winshow(user, "stonekeep_prefwin", FALSE)
	user.client.clear_character_previews()
	user << browse(null, "window=preferences_browser")
	validate_customizer_entries()
	character_setup_static_sig = "[pref_species?.type]-[read_preference(/datum/preference/choiced/gender)]-[read_preference(/datum/preference/choiced/pronouns)]"
	ui_interact(user)


/datum/preferences/proc/update_menu_data(mob/user, list/fields_to_update)
	character_setup_ui_heavy_sig = null
	var/new_static_sig = "[pref_species?.type]-[read_preference(/datum/preference/choiced/gender)]-[read_preference(/datum/preference/choiced/pronouns)]"
	if(new_static_sig != character_setup_static_sig)
		character_setup_static_sig = new_static_sig
		update_static_data(user)
	character_setup_update_view()
	character_setup_queue_push()

/// Pushes ui_data on the next tick unless it is rebuilt before then. A ui_act that returns TRUE
/// pushes right after its handler, so an immediate push here built and sent ui_data twice per click.
/datum/preferences/proc/character_setup_queue_push()
	character_setup_push_serial = character_setup_data_serial
	addtimer(CALLBACK(src, PROC_REF(character_setup_flush_push)), 1, TIMER_UNIQUE)

/datum/preferences/proc/character_setup_flush_push()
	if(character_setup_data_serial != character_setup_push_serial)
		return
	SStgui.update_uis(src)


/datum/preferences/proc/set_ui_theme(new_theme)
	if(new_theme == "grimshart")
		return write_preference(/datum/preference/choiced/char_theme, new_theme)
	return FALSE

#undef APPEARANCE_CATEGORY_COLUMN
#undef MAX_MUTANT_ROWS

/datum/preferences/proc/set_choices(mob/user, limit = 15, list/splitJobs = list("Captain", "Priest", "Merchant", "Butler", "Village Elder"), widthPerColumn = 400, height = 620)
	if(!SSjob)
		return

	var/HTML = "<center>"
	if(!length(SSjob.joinable_occupations))
		HTML += "<center><a href='byond://?_src_=prefs;preference=job;task=close'>Done</a></center><br>"
	else
		HTML += "<center><a href='byond://?_src_=prefs;preference=job;task=close'>Done</a></center><br>"
		var/joblessrole = read_preference(/datum/preference/choiced/joblessrole)
		if(joblessrole != RETURNTOLOBBY && joblessrole != BERANDOMJOB)
			joblessrole = RETURNTOLOBBY
			write_preference(/datum/preference/choiced/joblessrole, joblessrole)

		HTML += "<b>If Role Unavailable:</b><font color='purple'><a href='byond://?_src_=prefs;preference=job;task=nojob'>[joblessrole]</a></font><BR>"

		var/datum/job/highest_pref
		for(var/job in job_preferences)
			if(job_preferences[job] > highest_pref)
				highest_pref = SSjob.GetJob(job)
		if(isnull(highest_pref))
			preview_subclass = null
		HTML += "<div style='text-align: center'><br><b>Subclass Preview:</b><br> <a href='byond://?_src_=prefs;preference=subclassoutfit;task=input'>[preview_subclass ? "[preview_subclass.title]" : "Change"]</a></div>"

		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='byond://?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		HTML += {"
			<script type='text/javascript'>
				function update_job_preference() {
					var data = {};
					for(var i = 0; i < arguments.length; i++) {
						var arg = arguments\[i\];
						if(typeof arg === 'string' && arg.indexOf('=') !== -1) {
							var parts = arg.split('=');
							var key = parts\[0\];
							var value = decodeURIComponent(parts.slice(1).join('='));
							data\[key\] = value;
						}
					}

					if(!data.jobTitle || data.prefLevel === undefined) return;

					var jobId = data.jobTitle.replace(/ /g, '_');
					var prefLink = document.getElementById('job-pref-' + jobId);

					if(prefLink) {
						var level = parseInt(data.prefLevel);
						// level values: 1=High, 2=Medium, 3=Low, 4=NEVER
						var config = {
							1: { label: 'High', color: 'slateblue', upper: 4, lower: 2 },
							2: { label: 'Medium', color: 'green', upper: 1, lower: 3 },
							3: { label: 'Low', color: 'orange', upper: 2, lower: 4 },
							4: { label: 'NEVER', color: 'red', upper: 3, lower: 1 }
						};

						if(config\[level\]) {
							var cfg = config\[level\];
							var jobTitle = data.jobTitle;

							prefLink.innerHTML = '<font color=' + cfg.color + '>' + cfg.label + '</font>';
							prefLink.href = 'byond://?_src_=prefs;preference=job;task=setJobLevel;level=' + cfg.upper + ';text=' + jobTitle;
							prefLink.setAttribute('oncontextmenu', 'javascript:return setJobPrefRedirect(' + cfg.lower + ', "' + jobTitle + '");');
						}
					}
				}


				function toggleCategory(categoryName) {
					var fieldset = document.getElementById('fieldset-' + categoryName);
					var content = document.getElementById('content-' + categoryName);
					if(content.style.display === 'none') {
						content.style.display = 'block';
						fieldset.setAttribute('data-collapsed', 'false');
					} else {
						content.style.display = 'none';
						fieldset.setAttribute('data-collapsed', 'true');
					}
				}
			</script>
			<style>
				.two-column-container {
					display: flex;
					justify-content: center;
					gap: 20px;
					max-width: 1000px;
					margin: 0 auto;
				}

				.column {
					display: flex;
					flex-direction: column;
					gap: 10px;
					width: 450px;
				}

				.job-category-box {
					width: 100%;
					border: 2px solid;
					margin: 0;
					box-sizing: border-box;
				}

				.job-category-box table {
					width: 100%;
				}

				fieldset\[data-collapsed="true"\] legend::after {
					content: " (Expand)";
				}
				fieldset\[data-collapsed="false"\] legend::after {
					content: " (Collapse)";
				}

				.tutorialhover {
					position: relative;
					display: inline-block;
				}
				.tutorialhover .tutorial {
					visibility: hidden;
					width: 280px;
					background-color: black;
					color: #e3c06f;
					text-align: center;
					border-radius: 6px;
					padding: 5px;
					position: absolute;
					z-index: 1000;
					left: 50%;
					transform: translateX(-50%);
					bottom: 100%;
					margin-bottom: 5px;
				}
				.tutorialhover:hover .tutorial {
					visibility: visible;
				}
			</style>
		"}

		var/race_ban = FALSE
		if(is_race_banned(user.ckey, user.client.prefs.pref_species.id))
			HTML += "<div style='color: red; text-align: center; padding: 10px;'>YOU ARE BANNED FROM PLAYING THE SPECIES: [user.client.prefs.pref_species.id]</div>"
			race_ban = TRUE

		if(!race_ban)
			var/left_column_html = ""
			var/right_column_html = ""

			var/list/omegalist = list(
				GLOB.lords_positions,
				GLOB.townhall_positions,
				GLOB.townwatch_positions,
				GLOB.chapel_positions,
				GLOB.scholars_positions,
				GLOB.traders_positions,
				GLOB.tavern_positions,
				GLOB.town_positions,
				GLOB.outsiders_positions,
				GLOB.adventurers_positions,
				GLOB.villains_positions,
			)
			var/category_index = 0
			for(var/list/category in omegalist)
				if(!SSjob.name_occupations[category[1]])
					continue

				var/list/available_jobs = list()
				for(var/job in category)
					var/datum/job/job_datum = SSjob.name_occupations[job]
					if(!job_datum)
						continue
					if(!job_datum.total_positions && !job_datum.spawn_positions)
						continue
					if(!job_datum.enabled)
						continue
					if(job_datum.spawn_positions <= 0)
						continue
					available_jobs += job_datum

				if(!length(available_jobs))
					continue

				var/datum/job/first_job = SSjob.name_occupations[category[1]]
				var/cat_color = first_job.selection_color
				var/cat_name = ""
				switch(first_job.department_flag)
					if(LORDS)
						cat_name = "Lords"
					if(KEEP)
						cat_name = "The Keep"
					if(TOWNHALL)
						cat_name = "Town Hall"
					if(TOWNWATCH)
						cat_name = "Town Watch"
					if(CHAPEL)
						cat_name = "Chapel"
					if(SCHOLARS)
						cat_name = "Scholars"
					if(TRADERS)
						cat_name = "Traders"
					if(TAVERN)
						cat_name = "Tavern"
					if(TOWN)
						cat_name = "Towners"
					if(ADVENTURERS)
						cat_name = "Adventurers"
					if(VILLAINS)
						cat_name = "Villains"
					if(OUTSIDERS)
						cat_name = "Outsiders"

				var/category_html = ""
				category_html += "<fieldset class='job-category-box' style='border-color: [cat_color];' id='fieldset-[cat_name]' data-collapsed='true'>"
				category_html += "<legend align='center' style='font-weight: bold; color: [cat_color]; cursor: pointer;' onclick='toggleCategory(\"[cat_name]\")'>[cat_name]</legend>"
				category_html += "<div id='content-[cat_name]' style='display: none;'>"
				category_html += "<table cellpadding='1' cellspacing='0'>"

				for(var/datum/job/job in available_jobs)
					var/rank = job.title
					var/used_name = job.get_gendered_title(
						read_preference(/datum/preference/choiced/gender),
						read_preference(/datum/preference/choiced/pronouns),
					)
					var/job_id = replacetext(rank, " ", "_")

					category_html += "<tr bgcolor='#000000'><td width='60%' align='right'>"

					if(is_role_banned(user.ckey, job.title))
						category_html += "[used_name]</td><td><a href='byond://?_src_=prefs;bancheck=[rank]'> BANNED</a></td></tr>"
						continue
					if(!job.player_old_enough(user.client))
						var/available_in_days = job.available_in_days(user.client)
						category_html += "[used_name]</td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
						continue
					if(CONFIG_GET(flag/usewhitelist))
						if(job.whitelist_req && (!user.client.whitelisted()))
							category_html += "<font color=#6183a5>[used_name]</font></td><td> </td></tr>"
							continue
					var/lock_html = get_job_lock_html(job, user, used_name)
					if(lock_html)
						category_html += lock_html
						continue
					var/job_display = used_name


					category_html += "<div class='tutorialhover'> [job.class_setup_examine ? "<a href='byond://?src=[REF(job)];explainjob=1'><font>[job_display]</font></a>" : "<font>[job_display]</font>"]</span>\
						<span class='tutorial'>[job.tutorial]<br>\
						Slots: [job.get_total_positions()]</span>\
						</div>"


					category_html += "</td><td width='40%'>"

					var/prefLevelLabel = "ERROR"
					var/prefLevelColor = "pink"
					var/prefUpperLevel = -1 // level to assign on left click
					var/prefLowerLevel = -1 // level to assign on right click

					switch(job_preferences[job.title])
						if(JP_HIGH)
							prefLevelLabel = "High"
							prefLevelColor = "slateblue"
							prefUpperLevel = 4
							prefLowerLevel = 2
						if(JP_MEDIUM)
							prefLevelLabel = "Medium"
							prefLevelColor = "green"
							prefUpperLevel = 1
							prefLowerLevel = 3
						if(JP_LOW)
							prefLevelLabel = "Low"
							prefLevelColor = "orange"
							prefUpperLevel = 2
							prefLowerLevel = 4
						else
							prefLevelLabel = "NEVER"
							prefLevelColor = "red"
							prefUpperLevel = 3
							prefLowerLevel = 1

					category_html += "<a class='white' id='job-pref-[job_id]' href='byond://?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"
					category_html += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
					category_html += "</a></td></tr>"

				category_html += "</table></div></fieldset>"

				if(category_index % 2 == 0)
					left_column_html += category_html
				else
					right_column_html += category_html
				category_index++

			HTML += "<div class='two-column-container'>"
			HTML += "<div class='column'>[left_column_html]</div>"
			HTML += "<div class='column'>[right_column_html]</div>"
			HTML += "</div>"

		if(user.client.prefs.lastclass)
			HTML += "<center><br><a href='byond://?_src_=prefs;preference=job;task=triumphthing'>PLAY AS [user.client.prefs.lastclass] AGAIN</a></center>"
		else
			HTML += "<br>"
		HTML += "<center><a href='byond://?_src_=prefs;preference=job;task=reset'>Reset</a></center>"
		HTML += "<br><center><a href='byond://?_src_=prefs;preference=role_settings'>Role Specific Preferences</a></center>"
		HTML += "<br><center><a href='byond://?_src_=prefs;preference=family'>Family & Bonds</a></center>"
		HTML += "<br><center><a href='byond://?_src_=prefs;preference=relations_gossip'>Rivals, Gossip & Rumors</a></center>"

	HTML += "</center>"

	var/datum/browser/noclose/popup = new(user, "mob_occupation", "<div align='center'>Class Selection</div>", 1000, 700)
	popup.set_content(HTML)
	popup.open(FALSE)

/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if(!job)
		return FALSE
	if(level == JP_HIGH)
		for(var/j in job_preferences)
			if(job_preferences[j] == JP_HIGH)
				job_preferences[j] = JP_MEDIUM
	job_preferences[job.title] = level
	return TRUE


/datum/preferences/proc/update_job_preference(mob/user, role, desiredLvl)
	if(!SSjob || !length(SSjob.joinable_occupations))
		return
	var/datum/job/job = SSjob.GetJob(role)
	if(!job || !(job.job_flags & JOB_NEW_PLAYER_JOINABLE))
		user << browse(null, "window=mob_occupation")
		update_menu_data(user, list("job"))
		return
	if(CONFIG_GET(flag/usewhitelist))
		if(job.whitelist_req && (!user.client.whitelisted()))
			to_chat(user, span_warning("You are not on the server whitelist for [job.title]."))
			update_menu_data(user, list("job"))
			return
	if(!job.player_has_job_whitelist(user.client))
		to_chat(user, span_warning("You are not whitelisted for [job.title]."))
		update_menu_data(user, list("job"))
		return
	if(!isnum(desiredLvl))
		to_chat(user, "<span class='danger'>update_job_preference - desired level was not a number. Please notify coders!</span>")
		CRASH("update_job_preference called with desiredLvl value of [isnull(desiredLvl) ? "null" : desiredLvl]")

	var/jpval = null
	// desiredLvl comes from the links: 1=High, 2=Medium, 3=Low, 4=NEVER
	// JP constants: JP_LOW=1, JP_MEDIUM=2, JP_HIGH=3
	switch(desiredLvl)
		if(1)
			jpval = JP_HIGH  // 3
		if(2)
			jpval = JP_MEDIUM  // 2
		if(3)
			jpval = JP_LOW  // 1
		if(4)
			jpval = null  // NEVER

	var/was_high = (jpval == JP_HIGH)
	var/previous_high_job = null

	if(was_high)
		for(var/job_title in job_preferences)
			if(job_preferences[job_title] == JP_HIGH)
				previous_high_job = job_title
				break

	set_job_preference_level(job, jpval)

	// Send back the desiredLvl value directly since that's what JavaScript expects
	update_job_display(user, role, desiredLvl)

	if(was_high && previous_high_job && previous_high_job != role)
		update_job_display(user, previous_high_job, 2)  // Medium

	update_menu_data(user, list("job"))
	return 1

/datum/preferences/proc/reset_jobs(mob/user, silent = FALSE)
	job_preferences = list()
	preview_subclass = null
	if(!silent)
		to_chat(user, "<font color='red'>Classes reset.</font>")
	if(user?.client && winget(user, "mob_occupation", "is-visible"))
		set_choices(user)


/datum/preferences/proc/update_job_display(mob/user, job_title, pref_level)
	if(!winexists(user, "mob_occupation"))
		return

	var/list/params = list()
	params["jobTitle"] = job_title
	params["prefLevel"] = pref_level

	user << output(list2params(params), "mob_occupation.browser:update_job_preference")

/datum/preferences/proc/capture_keybinding(mob/user, datum/keybinding/kb, old_key)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var url = 'byond://?_src_=prefs;preference=keybinds;task=keybindings_set;keybinding=[kb.name];old_key=[old_key];clear_key='+escPressed+';key='+e.key+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/noclose/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)

/datum/preferences/proc/reset_patron(mob/user, silent = FALSE)
	write_preference(/datum/preference/choiced/patron, read_default_preference(/datum/preference/choiced/patron))
	if(!silent)
		to_chat(user, "<font color='red'>Patron reset.</font>")

/datum/preferences/proc/reset_culture(mob/user, silent = FALSE)
	var/datum/culture/selected = GLOB.culture_singletons[read_preference(/datum/preference/choiced/culture)]
	if(selected.is_selectable(src))
		return
	write_preference(/datum/preference/choiced/culture, read_default_preference(/datum/preference/choiced/culture))
	if(!silent)
		to_chat(user, "<font color='red'>Culture reset.</font>")

/datum/preferences/proc/reset_last_class(mob/user)
	if(user.client?.prefs)
		if(!user.client.prefs.lastclass)
			return
	if(browser_alert(user, "Use 2 TRIUMPHS to play as this class again?", "OUROBOROS", DEFAULT_INPUT_CONFIRMATIONS) != CHOICE_CONFIRM)
		return
	if(user.client?.prefs)
		if(user.client.prefs.lastclass)
			if(user.get_triumphs() < 2)
				to_chat(user, "<span class='warning'>I haven't TRIUMPHED enough.</span>")
				return
			user.adjust_triumphs(-2)
			user.client.prefs.lastclass = null
			user.client.prefs.save_preferences()

/datum/preferences/proc/set_keybinds(mob/user)
	var/list/dat = list()
	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for (var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)

	var/list/kb_categories = list()
	// Group keybinds by category
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		kb_categories[kb.category] += list(kb)

	dat += "<style>label { display: inline-block; width: 200px; }</style><body>"

	dat += "<center><a href='byond://?_src_=prefs;preference=keybinds;task=close'>Done</a></center><br>"
	for (var/category in kb_categories)
		for (var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			if(!length(user_binds[kb.name]))
				dat += "<label>[kb.full_name]</label> <a href ='byond://?_src_=prefs;preference=keybinds;task=keybindings_capture;keybinding=[kb.name];old_key=["Unbound"]'>Unbound</a>"
			//	var/list/default_keys = hotkeys ? kb.hotkey_keys : kb.classic_keys
			//	if(LAZYLEN(default_keys))
			//		dat += "| Default: [default_keys.Join(", ")]"
				dat += "<br>"
			else
				var/bound_key = user_binds[kb.name][1]
				dat += "<label>[kb.full_name]</label> <a href ='byond://?_src_=prefs;preference=keybinds;task=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
				for(var/bound_key_index in 2 to length(user_binds[kb.name]))
					bound_key = user_binds[kb.name][bound_key_index]
					dat += " | <a href ='byond://?_src_=prefs;preference=keybinds;task=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
				if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
					dat += "| <a href ='byond://?_src_=prefs;preference=keybinds;task=keybindings_capture;keybinding=[kb.name]'>Add Secondary</a>"
				dat += "<br>"

	dat += "<br><br>"
	dat += "<a href ='byond://?_src_=prefs;preference=keybinds;task=keybindings_reset'>\[Reset to default\]</a>"
	dat += "</body>"

	var/datum/browser/noclose/popup = new(user, "keybind_setup", "<div align='center'>Keybinds</div>", 600, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/set_antag(mob/user)
	var/list/dat = list()
	dat += "<style>label { display: inline-block; width: 200px; }</style><body>"
	dat += "<center><a href='byond://?_src_=prefs;preference=antag;task=close' style='display:block;margin-bottom:2px'>Done</a></center>"
	dat += "<h2 style='margin:5;padding:5;line-height:1.2'>Villains</h2>"
	if(is_total_antag_banned(user.ckey))
		dat += "<font color=red><b>I am banned from antagonist roles.</b></font><br>"
		src.be_special = list()
	for (var/i in GLOB.special_roles_rogue)
		if(is_antag_banned(user.ckey, i))
			dat += "<b>[capitalize(i)]:</b> <a href='byond://?_src_=prefs;bancheck=[i]'>BANNED</a><br>"
		else
			var/days_remaining = null
			if(ispath(GLOB.special_roles_rogue[i]) && CONFIG_GET(flag/use_age_restriction_for_jobs))
				days_remaining = get_remaining_days(user.client)
			if(days_remaining)
				dat += "<b>[capitalize(i)]:</b> <font color=red> \[IN [days_remaining] DAYS__~~\]~~__</font><br>"
			else
				dat += "<b>[capitalize(i)]:</b> <a href='byond://?_src_=prefs;preference=antag;task=be_special;be_special_type=[i]'>[(i in be_special) ? "Enabled" : "Disabled"]</a><br>"

	var/list/vessel_ids = GLOB.vessel_ids
	var/list/available_vessel_ids = list()
	for(var/id in vessel_ids)
		if(user.client.is_whitelisted(id))
			available_vessel_ids += id

	if(length(available_vessel_ids))
		dat += "<h2 style='margin:5;padding:5;line-height:1.2'>Vessels</h2>"
		for(var/id in available_vessel_ids)
			var/enabled = (id in be_special)
			dat += "<b>[id]:</b> <a href='byond://?_src_=prefs;preference=antag;task=be_special;be_special_type=[id]'>[enabled ? "Enabled" : "Disabled"]</a><br>"

	dat += "</body>"
	var/datum/browser/noclose/popup = new(user, "antag_setup", "<div align='center'>Special Roles</div>", 265, 340)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/lore_popup(mob/user)
	if(!user || !user.client)
		return
	var/list/dat = list()
	var/datum/browser/noclose/popup  = new(user, "lore_primer", "<div align='center'>Lore Primer</div>", 650, 900)
	dat += GLOB.roleplay_readme
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/process_link(mob/user, list/href_list)

	if(href_list["bancheck"])
		var/list/ban_details = is_banned_from_with_details(user.ckey, user.client.address, user.client.computer_id, href_list["bancheck"])
		var/admin = FALSE
		if(GLOB.admin_datums[user.ckey] || GLOB.deadmins[user.ckey])
			admin = TRUE
		for(var/i in ban_details)
			if(admin && !text2num(i["applies_to_admins"]))
				continue
			ban_details = i
			break //we only want to get the most recent ban's details
		if(ban_details && ban_details.len)
			var/expires = "This is a permanent ban."
			if(ban_details["expiration_time"])
				expires = " The ban is for [DisplayTimeText(text2num(ban_details["duration"]) MINUTES)] and expires on [ban_details["expiration_time"]] (server time)."
			to_chat(user, "<span class='danger'>You, or another user of this computer or connection ([ban_details["key"]]) is banned from playing [href_list["bancheck"]].<br>The ban reason is: [ban_details["reason"]]<br>This ban (BanID #[ban_details["id"]]) was applied by [ban_details["admin_key"]] on [ban_details["bantime"]] during round ID [ban_details["round_id"]].<br>[expires]</span>")
			return
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				update_menu_data(user)
			if("reset")
				reset_jobs(user, TRUE)

			if("triumphthing")
				reset_last_class(user)
			if("nojob")
				switch(read_preference(/datum/preference/choiced/joblessrole))
					if(RETURNTOLOBBY)
						write_preference(/datum/preference/choiced/joblessrole, BERANDOMJOB)
					if(BERANDOMJOB)
						write_preference(/datum/preference/choiced/joblessrole, RETURNTOLOBBY)
				set_choices(user)
			if("tutorial")
				if(href_list["tut"])
					to_chat(user, "<span class='info'>* ----------------------- *</span>")
					to_chat(user, href_list["tut"])
					to_chat(user, "<span class='info'>* ----------------------- *</span>")
			if("random")
				write_preference(/datum/preference/choiced/joblessrole, BERANDOMJOB)
				set_choices(user)
			if("setJobLevel")
				if(SSticker.job_change_locked)
					return 1
				var/datum/job/highest_pref
				for(var/job in job_preferences)
					if(job_preferences[job] > highest_pref)
						highest_pref = SSjob.GetJob(job)
				if(isnull(highest_pref))
					preview_subclass = null
				update_job_preference(user, href_list["text"], text2num(href_list["level"]))
			else
				set_choices(user)
		return 1
	else if(href_list["preference"] == "multi")
		if(isnewplayer(user))
			var/mob/dead/new_player/player = user
			player.cache_multi_ready_characters()
		open_multi_ready()
		return 1


	else if(href_list["preference"] == "antag")
		to_chat(user, span_info("Antags are disabled for now."))
		return
		/*switch(href_list["task"])
			if("close")
				user << browse(null, "window=antag_setup")
				update_menu_data(user)
			if("be_special")
				var/be_special_type = href_list["be_special_type"]
				if(be_special_type in be_special)
					be_special -= be_special_type
				else
					be_special += be_special_type
				set_antag(user)
			if("update")
				set_antag(user)
			else
				SetAntag(user)*/

	else if(href_list["preference"] == "misc")
		show_misc_pref_ui(user)
		return

	else if(href_list["preference"] == "body_customize")
		show_body_customize_ui(user)
		return

	else if(href_list["preference"] == "gallery")
		var/gallery_tab = href_list["tab"] == "nsfw" ? "nsfw" : "regular"
		switch(href_list["task"])
			if("add")
				add_gallery_image(user, gallery_tab == "nsfw")
			if("remove")
				remove_gallery_image(user, gallery_tab == "nsfw", text2num(href_list["index"]))
			if("clear")
				clear_gallery_images(user, gallery_tab == "nsfw")
		show_gallery_ui(user, gallery_tab)
		return

	else if(href_list["preference"] == "triumphs")
		user.show_triumphs_list()
		return TRUE

	else if(href_list["preference"] == "role_settings")
		var/datum/role_settings_menu/menu = new(src)
		menu.ui_interact(user)
		return TRUE

	else if(href_list["preference"] == "family")
		var/datum/family_middleware/family_menu = new(src, user)
		family_menu.ui_interact(user)
		return TRUE

	else if(href_list["preference"] == "relations_gossip")
		open_gossip(user)
		return TRUE

	else if(href_list["preference"] == "playerquality")
		check_pq_menu(user.ckey)
		return TRUE

	else if(href_list["preference"] == "culinary")
		show_culinary_ui(user)
		return

	else if(href_list["preference"] == "markings")
		ShowMarkings(user)
		return
	// RMH EDITED START - custom self-written tattoos, separate from GLOB.body_markings
	else if(href_list["preference"] == "tattoos")
		ShowTattoos(user)
		return
	// RMH EDITED END
	else if(href_list["preference"] == "underwear")
		show_smallclothes_ui(user)
		return
	else if(href_list["preference"] == "descriptors")
		show_descriptors_ui(user)
		return

	else if(href_list["preference"] == "customizers")
		ShowCustomizers(user)
		return

	else if(href_list["preference"] == "erp")
		show_erp_preferences(user)
		return

	else if(href_list["preference"] == "triumph_buy_menu")
		SStriumphs.startup_triumphs_menu(user.client)
		return TRUE

	else if(href_list["preference"] == "keybinds")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=keybind_setup")
				update_menu_data(user)
			if("update")
				set_keybinds(user)
			if("keybindings_capture")
				var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
				var/old_key = href_list["old_key"]
				capture_keybinding(user, kb, old_key)
				return

			if("keybindings_set")
				var/kb_name = href_list["keybinding"]
				if(!kb_name)
					user << browse(null, "window=capturekeypress")
					set_keybinds(user)
					return

				var/clear_key = text2num(href_list["clear_key"])
				var/old_key = href_list["old_key"]
				if(clear_key)
					if(key_bindings[old_key])
						key_bindings[old_key] -= kb_name
						if(!length(key_bindings[old_key]))
							key_bindings -= old_key
					user << browse(null, "window=capturekeypress")
					save_preferences()
					set_keybinds(user)
					return

				var/new_key = uppertext(href_list["key"])
				var/AltMod = text2num(href_list["alt"]) ? "Alt" : ""
				var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
				var/ShiftMod = text2num(href_list["shift"]) ? "Shift" : ""
				var/numpad = text2num(href_list["numpad"]) ? "Numpad" : ""
				// var/key_code = text2num(href_list["key_code"])

				if(GLOB._kbMap[new_key])
					new_key = GLOB._kbMap[new_key]

				var/full_key
				switch(new_key)
					if("Alt")
						full_key = "[new_key][CtrlMod][ShiftMod]"
					if("Ctrl")
						full_key = "[AltMod][new_key][ShiftMod]"
					if("Shift")
						full_key = "[AltMod][CtrlMod][new_key]"
					else
						full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
				if(key_bindings[old_key])
					key_bindings[old_key] -= kb_name
					if(!length(key_bindings[old_key]))
						key_bindings -= old_key
				key_bindings[full_key] += list(kb_name)
				key_bindings[full_key] = sortList(key_bindings[full_key])
				var/datum/keybinding/client/say/kb = GLOB.keybindings_by_name[kb_name]
				if(istype(kb))
					user.client.set_macros()
				DIRECT_OUTPUT(user, browse(null, "window=capturekeypress"))
				user.client.update_movement_keys()
				save_preferences()
				set_keybinds(user)

			if("keybindings_reset")
				var/choice = browser_alert(user, "Do you really want to reset your keybindings?", "Setup keybindings", DEFAULT_INPUT_CONFIRMATIONS)
				if(choice != CHOICE_CONFIRM)
					return
				write_preference(/datum/preference/toggle/hotkeys, TRUE)
				key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key)
				user.client.update_movement_keys()
				set_keybinds(user)
			else
				set_keybinds(user)
		return TRUE

	// TGUI character setup menu actions (see character_menu_tgui.dm / character_menu_preview.dm)
	else if(href_list["preference"] == "character_setup_select_species")
		return character_setup_apply_species(user, href_list["species_id"])
	else if(href_list["preference"] == "character_setup_select_faith")
		return character_setup_apply_faith(user, href_list["faith_id"])
	else if(href_list["preference"] == "character_setup_select_patron")
		return character_setup_apply_patron(user, href_list["patron_id"])
	else if(href_list["preference"] == "character_setup_select_ancestry")
		return character_setup_apply_ancestry(user, href_list["ancestry"])
	else if(href_list["preference"] == "character_setup_select_body_build")
		return character_setup_apply_body_build(user, href_list["body_build"])
	else if(href_list["preference"] == "character_setup_round_action")
		return character_setup_round_action(user)
	else if(href_list["preference"] == "character_setup_preferences_fullscreen")
		character_setup_preferences_fullscreen = !character_setup_preferences_fullscreen
		SStgui.update_uis(src)
		return TRUE
	else if(href_list["preference"] == "character_setup_preferences_scale")
		character_setup_preferences_scale = character_setup_sanitize_preferences_scale(href_list["scale"])
		save_preferences()
		return TRUE
	else if(href_list["preference"] == "character_setup_report_geometry")
		character_setup_apply_reported_zoom(user, text2num(href_list["zoom_main"]), text2num(href_list["zoom_mini"]))
		return TRUE
	else if(href_list["preference"] == "character_setup_customizer")
		validate_customizer_entries()
		if(!character_setup_handle_color_task(user, href_list))
			handle_customizer_topic(user, href_list)
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_set_choice")
		var/setup_customizer_type = text2path(href_list["key"])
		var/setup_choice_type = text2path(href_list["choice_type"])
		if(!setup_customizer_type || !setup_choice_type)
			return TRUE
		var/datum/customizer_entry/setup_entry = get_customizer_entry_for_customizer_type(setup_customizer_type)
		var/datum/customizer/setup_customizer = CUSTOMIZER(setup_customizer_type)
		if(!setup_entry || !setup_customizer)
			return TRUE
		if(!(setup_choice_type in setup_customizer.customizer_choices) || setup_choice_type == setup_entry.customizer_choice_type)
			return TRUE
		// A new penis shape keeps the length and function the player already set.
		var/kept_penis_length = 0
		var/kept_penis_functional = TRUE
		var/datum/customizer_entry/organ/genitals/penis/old_penis_entry = setup_entry
		if(istype(old_penis_entry))
			kept_penis_length = old_penis_entry.penis_length_cm
			kept_penis_functional = old_penis_entry.functional
		customizer_entries -= setup_entry
		qdel(setup_entry)
		var/datum/customizer_entry/new_entry = setup_customizer.create_customizer_entry(src, setup_choice_type)
		var/datum/customizer_entry/organ/genitals/penis/new_penis_entry = new_entry
		if(istype(new_penis_entry) && kept_penis_length)
			new_penis_entry.penis_length_cm = kept_penis_length
			new_penis_entry.functional = kept_penis_functional
			new_penis_entry.penis_size = get_penis_visual_size(kept_penis_length)
		customizer_entries += new_entry
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_preview_layer")
		switch(href_list["layer"])
			if("underwear")
				character_setup_preview_underwear = !character_setup_preview_underwear
			if("clothes")
				character_setup_preview_clothes = !character_setup_preview_clothes
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_preview_rotate")
		var/list/dir_cycle = list(SOUTH, WEST, NORTH, EAST)
		var/idx = dir_cycle.Find(character_setup_preview_dir) || 1
		if(href_list["rotate"] == "left")
			idx = (idx <= 1) ? length(dir_cycle) : (idx - 1)
		else
			idx = (idx >= length(dir_cycle)) ? 1 : (idx + 1)
		character_setup_preview_dir = dir_cycle[idx]
		// Through update_view, so turning never measures a dummy that a yielded render is still dressing.
		character_setup_redraw_dir = TRUE
		character_setup_update_view(base_changed = FALSE)
		return TRUE
	else if(href_list["preference"] == "character_setup_preview_background")
		var/bg_choice = href_list["bg"]
		character_setup_preview_background = (bg_choice == "none") ? null : bg_choice
		character_setup_apply_map_background(user)
		save_character()
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_toggle_genital_set")
		toggle_genital_set()
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_mutant_color")
		var/mutant_slot = clamp(text2num(href_list["slot"]) || 1, 1, 3)
		pick_mutant_color(user, mutant_slot)
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_body_marking")
		var/list/marking_link = href_list.Copy()
		switch(href_list["marking_action"])
			if("use_preset")
				marking_link["preference"] = "use_preset"
			if("reset_all_colors")
				marking_link["preference"] = "reset_all_colors"
			if("reset_color")
				marking_link["preference"] = "reset_color"
			if("change_color")
				marking_link["preference"] = "change_color"
			if("move_up")
				marking_link["preference"] = "marking_move_up"
			if("move_down")
				marking_link["preference"] = "marking_move_down"
			if("add")
				marking_link["preference"] = "add_marking"
			if("remove")
				marking_link["preference"] = "remove_marking"
			if("replace")
				marking_link["preference"] = "change_marking"
		marking_link["key"] = href_list["zone"]
		marking_link["task"] = "change_marking"
		handle_body_markings_topic(user, marking_link)
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_smallclothes_set")
		var/list/smallclothes_category = character_setup_smallclothes_category(href_list["category"])
		if(!smallclothes_category)
			return TRUE
		var/new_smallclothes_type = href_list["value"] ? text2path(href_list["value"]) : null
		if(new_smallclothes_type && (!ispath(new_smallclothes_type, smallclothes_category["base"]) || !(new_smallclothes_type in smallclothes_category["options"])))
			return TRUE
		var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
		smallclothes_preferences[smallclothes_category["pref"]] = new_smallclothes_type
		write_preference(/datum/preference/list_type/smallclothes_preferences, smallclothes_preferences)
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_smallclothes_color")
		var/list/smallclothes_category = character_setup_smallclothes_category(href_list["category"])
		if(!smallclothes_category)
			return TRUE
		var/color_pref_key = smallclothes_category["color_pref"]
		var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
		var/color_choice = input(user, "Choose a color.", "[smallclothes_category["name"]] Colour") as null|anything in GLOB.colorlist
		if(color_choice)
			if(GLOB.colorlist[color_choice] == "CUSTOM_RGB")
				var/current_color = smallclothes_preferences[color_pref_key] || "#FFFFFF"
				var/new_color = tgui_color_picker(user, "Select color:", "Custom Color", sanitize_hexcolor(current_color, 6, TRUE, "#ffffff"))
				if(new_color)
					smallclothes_preferences[color_pref_key] = sanitize_hexcolor(new_color, include_crunch = 1)
			else
				smallclothes_preferences[color_pref_key] = GLOB.colorlist[color_choice]
		else
			smallclothes_preferences[color_pref_key] = null
		write_preference(/datum/preference/list_type/smallclothes_preferences, smallclothes_preferences)
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_smallclothes_random")
		var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
		smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES] = !smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES]
		write_preference(/datum/preference/list_type/smallclothes_preferences, smallclothes_preferences)
		validate_smallclothes_preferences()
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_loadout")
		return character_setup_handle_loadout_link(user, href_list)
	else if(href_list["preference"] == "character_setup_taur_body")
		if(!pref_species?.forced_taur || !LAZYLEN(pref_species.allowed_taur_types))
			return TRUE
		var/list/taur_choices = list()
		for(var/obj/item/bodypart/taur/taur_type_path as anything in pref_species.allowed_taur_types)
			taur_choices[taur_type_path::name] = taur_type_path
		var/obj/item/bodypart/taur/current_taur = read_preference(/datum/preference/choiced/taur_type)
		var/taur_choice = tgui_input_list(user, "Choose your taur body:", "Taur Body", taur_choices, ispath(current_taur) ? current_taur::name : null)
		if(taur_choice)
			write_preference(/datum/preference/choiced/taur_type, taur_choices[taur_choice])
			save_character()
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_taur_color")
		var/which_taur_color = href_list["which"]
		var/current_taur_color = read_preference(/datum/preference/color/taur_color)
		switch(which_taur_color)
			if("markings")
				current_taur_color = read_preference(/datum/preference/color/taur_markings)
			if("tertiary")
				current_taur_color = read_preference(/datum/preference/color/taur_tertiary)
		var/new_taur_color = tgui_color_picker(user, "Choose your character's taur [which_taur_color == "base" ? "" : "[which_taur_color] "]color:", "Character Preference", "#[current_taur_color]")
		if(new_taur_color && is_body_color_picker_choice_valid(user, new_taur_color))
			switch(which_taur_color)
				if("markings")
					write_preference(/datum/preference/color/taur_markings, sanitize_hexcolor(new_taur_color))
				if("tertiary")
					write_preference(/datum/preference/color/taur_tertiary, sanitize_hexcolor(new_taur_color))
				else
					write_preference(/datum/preference/color/taur_color, sanitize_hexcolor(new_taur_color))
			save_character()
		update_menu_data(user)
		return TRUE
	else if(href_list["preference"] == "character_setup_hover")
		var/new_acc = href_list["acc"]
		var/new_customizer = href_list["customizer"]
		if(!new_acc || !new_customizer)
			if(!character_setup_hover_acc)
				return TRUE
			character_setup_hover_acc = null
			character_setup_hover_color = null
			character_setup_hover_customizer = null
			character_setup_render_main_only = TRUE
			character_setup_update_view(base_changed = FALSE)
			return TRUE
		if(new_acc == character_setup_hover_acc && href_list["color"] == character_setup_hover_color && new_customizer == character_setup_hover_customizer)
			return TRUE
		if(!text2path(new_acc) || !text2path(new_customizer))
			return TRUE
		character_setup_hover_acc = new_acc
		character_setup_hover_color = href_list["color"]
		character_setup_hover_customizer = new_customizer
		character_setup_render_main_only = TRUE
		character_setup_update_view(base_changed = FALSE)
		return TRUE

	if(process_native_preference_link(user, href_list))
		update_menu_data(user)
		return TRUE

	switch(href_list["task"])
		if("erp_pref")
			handle_erp_pref_topic(user, href_list)
			update_menu_data(user)
			if(!href_list["native"])
				show_erp_preferences(user)
			return
		if("change_customizer")
			handle_customizer_topic(user, href_list)
			update_menu_data(user)
			ShowCustomizers(user)
			return
		if("change_marking")
			handle_body_markings_topic(user, href_list)
			update_menu_data(user)
			ShowMarkings(user)
			return
		if("change_smallclothes_preferences")
			handle_undies_topic(user, href_list)
			show_smallclothes_ui(user)
			return
		if("change_descriptor")
			handle_descriptors_topic(user, href_list)
			show_descriptors_ui(user)
			return
		if("change_culinary_preferences")
			handle_culinary_topic(user, href_list)
			show_culinary_ui(user)
			return
		if("random")
			switch(href_list["preference"])
				if("name")
					write_preference(/datum/preference/text/real_name, pref_species.random_name(read_preference(/datum/preference/choiced/gender), TRUE))
				if("age")
					write_preference(/datum/preference/choiced/age, pick(pref_species.possible_ages))
				if("s_tone")
					var/list/skins = pref_species.get_skin_list()
					write_preference(/datum/preference/choiced/skin_tone, skins[pick(skins)])
				if("species")
					user << browse(null, "window=misc_customization")
					random_species()
				if("all")
					apply_character_randomization_prefs()


	update_menu_data(user)
	return 1


/// Handles the TGUI preference actions that used to mutate fields directly on this datum.
/datum/preferences/proc/process_native_preference_link(mob/user, list/href_list)
	var/action = href_list["preference"]

	var/static/list/native_link_types = list(
		"name" = /datum/preference/text/real_name,
		"s_tone" = /datum/preference/choiced/skin_tone,
		"gender" = /datum/preference/choiced/gender,
		"pronouns" = /datum/preference/choiced/pronouns,
		"domhand" = /datum/preference/choiced/domhand,
		"voicetype" = /datum/preference/choiced/voice_type,
		"selected_accent" = /datum/preference/choiced/selected_accent,
		"voice" = /datum/preference/color/voice_color,
		"flavortext" = /datum/preference/text/flavortext,
		"culture" = /datum/preference/choiced/culture,
		"ooc_notes" = /datum/preference/text/ooc_notes,
		"headshot" = /datum/preference/text/headshot_link,
		"pixel_size" = /datum/preference/numeric/pixel_size,
		"scaling_method" = /datum/preference/choiced/scaling_method,
	)
	var/native_link_type = native_link_types[action]
	if(native_link_type)
		var/datum/preference/preference = GLOB.preference_entries[native_link_type]
		preference.handle_link(src, user)
		// Account settings save at once; character fields wait for the Save button.
		if(preference.savefile_identifier == PREF_PLAYER)
			save_preferences()
		return TRUE

	var/static/list/toggle_link_types = list(
		"hotkeys" = /datum/preference/toggle/hotkeys,
		"see_chat_non_mob" = /datum/preference/toggle/see_chat_non_mob,
		"action_buttons" = /datum/preference/toggle/buttons_locked,
		"tgui_fancy" = /datum/preference/toggle/tgui_fancy,
		"tgui_lock" = /datum/preference/toggle/tgui_lock,
		"winflash" = /datum/preference/toggle/windowflashing,
		"ambientocclusion" = /datum/preference/toggle/ambientocclusion,
		"auto_fit_viewport" = /datum/preference/toggle/auto_fit_viewport,
		"descriptor_color" = /datum/preference/toggle/descriptor_color,
		"hear_speech_barks" = /datum/preference/toggle/hear_speech_barks,
	)
	var/toggle_link_type = toggle_link_types[action]
	if(toggle_link_type)
		if(action == "hotkeys")
			var/datum/preference/preference = GLOB.preference_entries[toggle_link_type]
			preference.handle_link(src, user)
		else
			toggle_preference(toggle_link_type)
		save_preferences()
		switch(action)
			if("ambientocclusion")
				update_occlusion(parent)
			if("auto_fit_viewport")
				if(read_preference(/datum/preference/toggle/auto_fit_viewport))
					parent?.fit_viewport()
				else
					parent?.reset_viewport_split()
		return TRUE

	var/static/list/bitwise_toggle_values = list(
		"lobby_music" = list(/datum/preference/bitwise/toggles, SOUND_LOBBY),
		"hear_midis" = list(/datum/preference/bitwise/toggles, SOUND_MIDI),
		"allow_midround_antag" = list(/datum/preference/bitwise/toggles, MIDROUND_ANTAG),
		"ambience" = list(/datum/preference/bitwise/toggles, SOUND_AMBIENCE),
		"background_music" = list(/datum/preference/bitwise/toggles, SOUND_SHIP_AMBIENCE),
		"be_voice" = list(/datum/preference/bitwise/toggles, SCHIZO_VOICE),
		"balloon_alerts" = list(/datum/preference/bitwise/toggles_maptext, DISABLE_BALLOON_ALERTS),
		"runechat" = list(/datum/preference/bitwise/toggles_maptext, DISABLE_RUNECHAT),
	)
	var/list/bitwise_toggle = bitwise_toggle_values[action]
	if(bitwise_toggle)
		var/bitwise_type = bitwise_toggle[1]
		var/flag = bitwise_toggle[2]
		preference_toggle_flag(bitwise_type, flag)
		save_preferences()
		var/flag_set = preference_has_flag(bitwise_type, flag)
		switch(action)
			if("lobby_music")
				if(flag_set)
					user.client?.playtitlemusic()
				else
					user.stop_sound_channel(CHANNEL_LOBBYMUSIC)
			if("ambience")
				user.client?.update_ambience_pref()
			if("background_music")
				if(flag_set && !isnewplayer(user))
					user.refresh_looping_ambience()
				else
					user.cancel_looping_ambience()
		return TRUE

	switch(action)
		if("triumphs")
			user.show_triumphs_list()
			return TRUE
		if("triumph_buy_menu")
			SStriumphs.startup_triumphs_menu(user.client)
			return TRUE
		if("markings")
			ShowMarkings(user)
			return TRUE
		if("descriptors")
			show_descriptors_ui(user)
			return TRUE
		if("culinary")
			show_culinary_ui(user)
			return TRUE
		if("select_quirks")
			open_quirk_menu(user)
			return TRUE
		if("gallery")
			show_gallery_ui(user, href_list["tab"] == "nsfw" ? "nsfw" : "regular")
			return TRUE
		if("img_gallery")
			add_gallery_image(user, FALSE)
			show_gallery_ui(user, "regular")
			return TRUE
		if("nsfw_img_gallery")
			add_gallery_image(user, TRUE)
			show_gallery_ui(user, "nsfw")
			return TRUE
		if("clear_gallery")
			clear_gallery_images(user, FALSE)
			show_gallery_ui(user, "regular")
			return TRUE
		if("clear_nsfw_gallery")
			clear_gallery_images(user, TRUE)
			show_gallery_ui(user, "nsfw")
			return TRUE
		if("speech_bark")
			if(user.client?.prefs != src)
				return FALSE
			user.client.set_speech_bark()
			return TRUE
		if("speech_moans")
			if(user.client?.prefs != src)
				return FALSE
			user.client.toggle_speech_moans()
			return TRUE
		if("voicepack")
			var/current_voice_pack = read_preference(/datum/preference/choiced/voice_pack)
			var/voicepack_input = tgui_input_list(user, "CHOOSE YOUR HERO'S EMOTE VOICE PACK", "VOICE PACK", GLOB.voice_packs_list, current_voice_pack)
			if(voicepack_input)
				write_preference(/datum/preference/choiced/voice_pack, voicepack_input)
			return TRUE
		if("voicepreview")
			if(SSticker.current_state == GAME_STATE_STARTUP || !COOLDOWN_FINISHED(src, voice_previewing) || !parent?.mob)
				return TRUE
			COOLDOWN_START(src, voice_previewing, 3 SECONDS)
			var/voice_pack = read_preference(/datum/preference/choiced/voice_pack)
			var/voice_type = read_preference(/datum/preference/choiced/voice_type)
			var/datum/voicepack/preview_pack
			if(voice_pack == VOICE_PACK_DEFAULT)
				var/default_voicepack_type = voice_type == VOICE_TYPE_MASC ? (pref_species.soundpack_m || /datum/voicepack/male) : (pref_species.soundpack_f || pref_species.soundpack_m || /datum/voicepack/female)
				preview_pack = new default_voicepack_type()
			else
				var/voicepack_type = GLOB.voice_packs_list[voice_pack]
				if(voicepack_type)
					preview_pack = new voicepack_type()
			if(!preview_pack)
				to_chat(user, span_warning("No voicepack selected."))
				return TRUE
			var/list/preview_keys = list("laugh", "chuckle", "sigh", "gasp", "hmm", "huh")
			var/soundin
			while(length(preview_keys) && !soundin)
				var/possible_sounds = preview_pack.get_sound(pick_n_take(preview_keys), null)
				if(islist(possible_sounds))
					if(length(possible_sounds))
						soundin = pick(possible_sounds)
				else
					soundin = possible_sounds
			if(soundin)
				var/sound/preview_sound = sound(get_sfx(soundin))
				preview_sound.frequency = voice_type == VOICE_TYPE_ANDRO ? 0.92 : 1
				parent.mob.playsound_local(get_turf(parent.mob), null, 70, FALSE, pressure_affected = FALSE, S = preview_sound)
			else
				to_chat(user, span_warning("This voicepack does not have preview sounds."))
			qdel(preview_pack)
			return TRUE
		if("moanselection")
			generate_selectable_moanpacks()
			var/voice_type = read_preference(/datum/preference/choiced/voice_type)
			var/list/available_moanpacks = GLOB.selectable_moanpacks
			if(voice_type == VOICE_TYPE_MASC)
				available_moanpacks = GLOB.selectable_moanpacks_male
			else if(voice_type == VOICE_TYPE_FEM)
				available_moanpacks = GLOB.selectable_moanpacks_female
			var/moanpack_input = tgui_input_list(user, "Choose your character's moanpack", "Moanpack", available_moanpacks, read_preference(/datum/preference/choiced/moan_selection))
			write_preference(/datum/preference/choiced/moan_selection, moanpack_input || MOANPACK_TYPE_DEF)
			return TRUE
		if("moanpreview")
			if(SSticker.current_state == GAME_STATE_STARTUP || !COOLDOWN_FINISHED(src, moan_previewing) || !parent?.mob)
				return TRUE
			COOLDOWN_START(src, moan_previewing, 3 SECONDS)
			generate_selectable_moanpacks()
			var/moan_selection = read_preference(/datum/preference/choiced/moan_selection)
			var/voice_type = read_preference(/datum/preference/choiced/voice_type)
			var/datum/moan_pack/preview_pack
			if(moan_selection == MOANPACK_TYPE_DEF)
				preview_pack = voice_type == VOICE_TYPE_MASC ? new /datum/moan_pack/male : new /datum/moan_pack/female
			else
				var/moanpack_type = GLOB.selectable_moanpacks[moan_selection]
				if(moanpack_type)
					preview_pack = new moanpack_type
			if(!preview_pack)
				to_chat(user, span_warning("No moanpack selected."))
				return TRUE
			var/static/list/moan_preview_keys = list("sexmoanlight", "sexmoanmed", "sexmoanhvy")
			var/soundin = preview_pack.get_moans(pick(moan_preview_keys))
			if(soundin)
				parent.mob.playsound_local(get_turf(parent.mob), soundin, 70, FALSE, pressure_affected = FALSE)
			else
				to_chat(user, span_warning("This moanpack does not have preview sounds."))
			qdel(preview_pack)
			return TRUE
		if("combat_music")
			if(!combat_music_helptext_shown)
				to_chat(user, span_notice("Non-default tracks override dynamically selected combat music."))
				combat_music_helptext_shown = TRUE
			var/combat_music_type = read_preference(/datum/preference/choiced/combat_music)
			var/datum/combat_music/current_track = GLOB.cmode_tracks_by_type[combat_music_type]
			var/track_select = tgui_input_list(user, "Set a track to be your combat music.", "Combat Music", GLOB.cmode_tracks_by_name, current_track?.name)
			if(track_select)
				var/datum/combat_music/selected_track = GLOB.cmode_tracks_by_name[track_select]
				write_preference(/datum/preference/choiced/combat_music, selected_track.type)
			return TRUE
		if("defeat_mode")
			choose_defeat_mode(user)
			return TRUE
		if("defeat_guide")
			user.show_defeat_recovery_guide()
			return TRUE
		if("defeat_threshold")
			var/list/threshold_choices = defeat_threshold_choice_map()
			var/current_threshold = read_preference(/datum/preference/numeric/defeat_damage_threshold)
			var/selected_threshold = tgui_input_list(user, defeat_threshold_help_text(), "Defeat Threshold", threshold_choices, defeat_threshold_display_label(current_threshold))
			if(selected_threshold)
				write_preference(/datum/preference/numeric/defeat_damage_threshold, threshold_choices[selected_threshold])
			return TRUE
		if("race_title")
			var/list/title_choices = list("None", "Custom") + pref_species.race_titles
			var/new_title = tgui_input_list(user, "What do they call your kind?", "RACE TITLE", title_choices, read_preference(/datum/preference/text/selected_title))
			if(new_title == "Custom")
				new_title = tgui_input_text(user, "Name of your people:", "RACE TITLE", "None", encode = FALSE)
			if(new_title)
				write_preference(/datum/preference/text/selected_title, new_title)
			return TRUE
		if("nsfw_headshot")
			var/new_nsfw_headshot = tgui_input_text(user, "Input the NSFW headshot link (https, hosts: [get_image_host_names(TRUE)]):", "NSFW Headshot", read_preference(/datum/preference/text/nsfw_headshot_link), encode = FALSE)
			if(!isnull(new_nsfw_headshot))
				new_nsfw_headshot = trim(new_nsfw_headshot)
				if(!length(new_nsfw_headshot) || is_valid_nsfw_headshot_link(user, new_nsfw_headshot, FALSE))
					write_preference(/datum/preference/text/nsfw_headshot_link, new_nsfw_headshot)
			return TRUE
		if("ooc_extra", "nsfwflavortext", "change_title", "change_artist", "player_language")
			var/static/list/text_link_types = list(
				"ooc_extra" = /datum/preference/text/erpprefs_flavor,
				"nsfwflavortext" = /datum/preference/text/nsfwflavortext,
				"change_title" = /datum/preference/text/song_title,
				"change_artist" = /datum/preference/text/song_artist,
				"player_language" = /datum/preference/text/player_language,
			)
			var/text_link_type = text_link_types[action]
			var/is_long_text = (action in list("ooc_extra", "nsfwflavortext"))
			var/new_text = tgui_input_text(user, "Enter a new value. Leave blank to clear.", "Character Preference", read_preference(text_link_type), max_length = is_long_text ? MAX_FLAVOR_TEXT_LENGTH : null, multiline = is_long_text, encode = FALSE)
			if(!isnull(new_text))
				write_preference(text_link_type, new_text)
			return TRUE
		if("song_link")
			var/new_song_link = tgui_input_text(user, "Input a direct MP3 link (https, hosts: [get_media_host_names()]). Leave blank to clear.", "Song URL", read_preference(/datum/preference/text/song_link), encode = FALSE)
			if(!isnull(new_song_link))
				new_song_link = trim(new_song_link)
				var/static/list/mp3_extension = list("mp3")
				if(!length(new_song_link) || is_valid_media_link(user, new_song_link, FALSE, mp3_extension))
					write_preference(/datum/preference/text/song_link, new_song_link)
			return TRUE
		if("ooc_preview")
			var/datum/examine_panel/preview_examine_panel = new(user)
			preview_examine_panel.pref = src
			preview_examine_panel.holder = user
			preview_examine_panel.viewing = user
			preview_examine_panel.ui_interact(user)
			return TRUE
		if("skin_color_ref_list")
			var/list/content = list("<center><h2>Skin color codes reference list</h2></center><br>")
			var/list/skin_list = pref_species.get_skin_list()
			for(var/tone in skin_list)
				var/hex_color = "#[skin_list[tone]]"
				content += "- <b>[tone]</b> | <span style='border: 1px solid #161616; background-color: [hex_color];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><br>"
			var/datum/browser/popup = new(user, "skin_color_ref", "<div align='center'>Skin colors</div>", width = 400, height = 450)
			popup.set_content(content.Join())
			popup.open(FALSE)
			return TRUE
		if("finished")
			user.client?.clear_character_previews()
			SStriumphs.remove_triumph_buy_menu(user.client)
			winshow(user, "stonekeep_prefwin", FALSE)
			return TRUE
		if("save")
			save_preferences()
			save_character()
			if(isnewplayer(user))
				var/mob/dead/new_player/player = user
				player.cache_multi_ready_characters()
			return TRUE
		if("load")
			load_preferences()
			load_character()
			if(isnewplayer(user))
				var/mob/dead/new_player/player = user
				player.cache_multi_ready_characters()
			return TRUE
		if("changeslot")
			write_preference(/datum/preference/choiced/selected_accent, ACCENT_NONE)
			var/list/slot_choices = list()
			if(path)
				var/savefile/save = new /savefile(path)
				for(var/slot in 1 to max_save_slots)
					var/slot_name
					save.cd = "/character[slot]"
					save["real_name"] >> slot_name
					slot_choices[slot_name || "Slot[slot]"] = slot
			if(!length(slot_choices))
				to_chat(user, span_warning("No character slots available. Guest accounts cannot save characters."))
				return TRUE
			var/slot_choice = tgui_input_list(user, "WHO IS YOUR HERO?", "NECRA AWAITS", slot_choices, read_preference(/datum/preference/text/real_name))
			if(slot_choice)
				var/chosen_slot = slot_choices[slot_choice]
				if(!load_character(chosen_slot))
					randomise_appearance_prefs()
					save_character()
			return TRUE
		if("randomiseappearanceprefs")
			randomise_appearance_prefs()
			customizer_entries = list()
			validate_customizer_entries()
			reset_all_customizer_accessory_colors()
			randomize_all_customizer_accessories()
			reset_jobs(user)
			genderize_customizer_entries()
			clear_flavor()
			return TRUE

	return FALSE


/datum/preferences/proc/get_gallery_images(nsfw_gallery = FALSE)
	var/gallery_type = nsfw_gallery ? /datum/preference/list_type/profile_gallery/nsfw_images : /datum/preference/list_type/profile_gallery/images
	var/list/gallery = read_preference(gallery_type)
	if(!islist(gallery))
		gallery = list()
		write_preference(gallery_type, gallery)
	return gallery

/datum/preferences/proc/add_gallery_image(mob/user, nsfw_gallery = FALSE)
	var/list/gallery = get_gallery_images(nsfw_gallery)
	var/gallery_name = nsfw_gallery ? "NSFW gallery" : "gallery"

	if(length(gallery) >= 3)
		to_chat(user, "You already have three images in your [gallery_name]!")
		return FALSE

	to_chat(user, "<span class='notice'>Please use an image ["<span class='bold'>of your character</span>"] to maintain immersion level. Lastly, ["<span class='bold'>do not use a real life photo or use any image that is less than serious.</span>"]</span>")
	to_chat(user, "<span class='notice'>If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser.</span>")
	to_chat(user, "<span class='notice'>Keep in mind that all three images are displayed next to eachother and justified to fill a horizontal rectangle. As such, vertical images work best.</span>")
	to_chat(user, "<span class='notice'>You can only have a maximum of ["<span class='bold'>THREE IMAGES</span>"] in each gallery at a time.</span>")

	var/title = nsfw_gallery ? "NSFW Gallery Image" : "Gallery Image"
	var/host_list = get_image_host_names(nsfw_gallery)
	var/new_galleryimg = tgui_input_text(user, "Input the image link (https, hosts: [host_list]):", title, max_length = MAX_MESSAGE_LEN, encode = FALSE)
	if(isnull(new_galleryimg))
		return FALSE
	new_galleryimg = trim(new_galleryimg, MAX_MESSAGE_LEN)
	if(new_galleryimg == "")
		return FALSE
	var/is_valid_link = nsfw_gallery ? is_valid_nsfw_headshot_link(user, new_galleryimg) : is_valid_headshot_link(user, new_galleryimg)
	if(!is_valid_link)
		to_chat(user, "<span class='notice'>Invalid image link. Make sure it's a direct link from a valid host ([host_list]).</span>")
		return FALSE

	gallery += new_galleryimg
	var/gallery_type = nsfw_gallery ? /datum/preference/list_type/profile_gallery/nsfw_images : /datum/preference/list_type/profile_gallery/images
	write_preference(gallery_type, gallery)
	to_chat(user, "<span class='notice'>Successfully added image to [gallery_name].</span>")
	log_game("[user] has added an image to their [gallery_name]: '[new_galleryimg]'.")
	return TRUE

/datum/preferences/proc/remove_gallery_image(mob/user, nsfw_gallery = FALSE, image_index)
	var/list/gallery = get_gallery_images(nsfw_gallery)
	var/gallery_name = nsfw_gallery ? "NSFW gallery" : "gallery"

	if(!image_index || image_index < 1 || image_index > length(gallery))
		to_chat(user, "<span class='warning'>That gallery image no longer exists.</span>")
		return FALSE

	var/image_link = gallery[image_index]
	var/choice = tgui_alert(user, "Remove image #[image_index] from your [gallery_name]?", "Remove Gallery Image", list("Remove", "Cancel"))
	if(choice != "Remove")
		return FALSE

	gallery.Cut(image_index, image_index + 1)
	var/gallery_type = nsfw_gallery ? /datum/preference/list_type/profile_gallery/nsfw_images : /datum/preference/list_type/profile_gallery/images
	write_preference(gallery_type, gallery)
	to_chat(user, "<span class='notice'>Successfully removed image from [gallery_name].</span>")
	log_game("[user] has removed an image from their [gallery_name]: '[image_link]'.")
	return TRUE

/datum/preferences/proc/clear_gallery_images(mob/user, nsfw_gallery = FALSE)
	var/list/gallery = get_gallery_images(nsfw_gallery)
	var/gallery_name = nsfw_gallery ? "NSFW gallery" : "gallery"

	if(!length(gallery))
		to_chat(user, "You don't have any images in your [gallery_name] to clear!")
		return FALSE

	var/choice = tgui_alert(user, "Do you really want to clear your [gallery_name]?", "Clear Gallery", list("Clear", "Cancel"))
	if(choice != "Clear")
		return FALSE

	var/gallery_type = nsfw_gallery ? /datum/preference/list_type/profile_gallery/nsfw_images : /datum/preference/list_type/profile_gallery/images
	write_preference(gallery_type, list())
	to_chat(user, "<span class='notice'>Successfully cleared [gallery_name].</span>")
	log_game("[user] has cleared their [gallery_name].")
	return TRUE

/datum/preferences/proc/show_gallery_ui(mob/user, selected_tab = "regular")
	selected_tab = selected_tab == "nsfw" ? "nsfw" : "regular"
	var/nsfw_gallery = selected_tab == "nsfw"
	var/list/gallery = get_gallery_images(nsfw_gallery)
	var/gallery_title = nsfw_gallery ? "NSFW Gallery" : "Image Gallery"
	var/regular_tab_class = nsfw_gallery ? "tab" : "tab active"
	var/nsfw_tab_class = nsfw_gallery ? "tab active" : "tab"
	var/list/dat = list()

	dat += {"
	<html lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<style>
			body {
				margin: 0;
				background: #1a1a1a;
				color: #d8cf9f;
				font-family: Verdana, Geneva, sans-serif;
				font-size: 12px;
			}
			.wrap {
				padding: 12px;
			}
			.panel {
				background: #2a2723;
				border: 2px solid #5b4b40;
				box-shadow: inset 0 0 0 1px #141211;
				padding: 12px;
			}
			h2 {
				margin: 0 0 10px;
				color: #eee69c;
				font-size: 16px;
				text-transform: uppercase;
				letter-spacing: 0;
			}
			.tabs {
				margin-bottom: 10px;
				border-bottom: 1px solid #5b4b40;
			}
			.tab {
				display: inline-block;
				padding: 7px 12px;
				color: #d8cf9f;
				text-decoration: none;
				font-weight: bold;
				text-transform: uppercase;
				border: 1px solid #5b4b40;
				border-bottom: 0;
				background: #1f1e1b;
				margin-right: 4px;
			}
			.tab.active {
				background: #705d4f;
				color: #161418;
			}
			.toolbar {
				margin: 10px 0 12px;
			}
			.button {
				display: inline-block;
				padding: 6px 9px;
				margin-right: 6px;
				background: #705d4f;
				border: 1px solid #171515;
				color: #161418;
				font-weight: bold;
				text-decoration: none;
			}
			.button:hover {
				background: #8b735f;
			}
			.button.danger {
				color: #d8cf9f;
				background: #3a1f1f;
				border-color: #6f3a33;
			}
			.button.disabled {
				color: #8f846c;
				background: #1f1e1b;
				border-color: #3a332d;
			}
			.note {
				color: #bcae82;
				margin-bottom: 10px;
			}
			.card {
				display: inline-block;
				vertical-align: top;
				width: 176px;
				margin: 0 8px 10px 0;
				background: #1f1e1b;
				border: 1px solid #5b4b40;
			}
			.preview {
				height: 150px;
				line-height: 150px;
				text-align: center;
				background: #080808;
				overflow: hidden;
			}
			.preview img {
				max-width: 100%;
				max-height: 150px;
				vertical-align: middle;
			}
			.card-body {
				padding: 7px;
			}
			.url {
				color: #bcae82;
				font-size: 10px;
				overflow: hidden;
				white-space: nowrap;
				text-overflow: ellipsis;
				margin-bottom: 7px;
			}
			.remove {
				color: #eee69c;
				font-weight: bold;
				text-decoration: none;
			}
			.empty {
				padding: 24px;
				text-align: center;
				color: #8f846c;
				border: 1px dashed #5b4b40;
				background: #1f1e1b;
			}
		</style>
	</head>
	<body>
		<div class="wrap">
			<div class="panel">
				<h2>[gallery_title]</h2>
				<div class="tabs">
					<a class="[regular_tab_class]" href='byond://?_src_=prefs;preference=gallery;task=menu;tab=regular'>Regular</a>
					<a class="[nsfw_tab_class]" href='byond://?_src_=prefs;preference=gallery;task=menu;tab=nsfw'>NSFW</a>
				</div>
				<div class="note">Direct image links (https) from approved hosts are stored here. Hosts: [get_image_host_names(nsfw_gallery)]. Each tab holds up to three images.</div>
				<div class="toolbar">
	"}

	if(length(gallery) < 3)
		dat += "<a class='button' href='byond://?_src_=prefs;preference=gallery;task=add;tab=[selected_tab]'>Add Image</a>"
	else
		dat += "<span class='button disabled'>Gallery Full</span>"
	if(length(gallery))
		dat += "<a class='button danger' href='byond://?_src_=prefs;preference=gallery;task=clear;tab=[selected_tab]'>Clear Tab</a>"
	dat += "<span>[length(gallery)]/3 images</span></div>"

	if(length(gallery))
		for(var/i in 1 to length(gallery))
			var/image_link = gallery[i]
			if(!length(image_link))
				continue
			var/safe_link = html_encode(image_link)
			dat += {"
				<div class="card">
					<div class="preview"><img src="[safe_link]" alt="Gallery image #[i]"></div>
					<div class="card-body">
						<div class="url">[safe_link]</div>
						<a class="remove" href='byond://?_src_=prefs;preference=gallery;task=remove;tab=[selected_tab];index=[i]'>Remove</a>
					</div>
				</div>
			"}
	else
		dat += "<div class='empty'>No images in this tab yet.</div>"

	dat += {"
			</div>
		</div>
	</body>
	</html>
	"}

	var/datum/browser/popup = new(user, "image_gallery", "<div align='center'>Image Gallery</div>", 640, 560)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/show_body_customize_or_misc_ui(mob/user, return_to_body_customize)
	if(return_to_body_customize)
		show_body_customize_ui(user)
	else
		show_misc_pref_ui(user)

/datum/preferences/proc/show_body_customize_ui(mob/user)
	var/list/dat = list()
	dat += {"
	<html lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<style>
			body {
				margin: 0;
				background: #1a1a1a;
				color: #d8cf9f;
				font-family: Verdana, Geneva, sans-serif;
				font-size: 12px;
			}
			.wrap {
				padding: 14px;
			}
			.panel {
				background: #2a2723;
				border: 2px solid #5b4b40;
				box-shadow: inset 0 0 0 1px #141211;
				padding: 12px;
			}
			h2 {
				margin: 0 0 10px;
				color: #eee69c;
				font-size: 16px;
				text-transform: uppercase;
				letter-spacing: 0;
			}
			.section-title {
				margin: 14px 0 6px;
				color: #bcae82;
				font-weight: bold;
				text-transform: uppercase;
				border-bottom: 1px solid #5b4b40;
				padding-bottom: 3px;
			}
			.option-row {
				display: block;
				background: #705d4f;
				border: 1px solid #171515;
				color: #161418;
				font-weight: bold;
				text-decoration: none;
				margin: 5px 0;
				padding: 7px 8px;
				min-height: 18px;
			}
			.option-row:hover {
				background: #8b735f;
				color: #161418;
			}
			.option-row small {
				display: block;
				color: #262020;
				font-weight: normal;
				margin-top: 2px;
			}
			.swatch {
				display: inline-block;
				width: 28px;
				height: 14px;
				border: 1px solid #161616;
				margin-right: 8px;
				vertical-align: middle;
			}
			.muted {
				color: #8f846c;
				margin: 5px 0;
			}
			.footer {
				margin-top: 12px;
				text-align: right;
			}
			.footer a {
				color: #eee69c;
				font-weight: bold;
				text-decoration: none;
			}
		</style>
	</head>
	<body>
		<div class="wrap">
			<div class="panel">
				<h2>Customize Appearance</h2>
	"}

	dat += "<div class='section-title'>Body Details</div>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=markings;task=menu'>Markings<small>Edit scars, tattoos, body markings, and their colors.</small></a>"
	// RMH EDITED START - custom self-written tattoos, separate from GLOB.body_markings
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=tattoos;task=menu'>Tattoos<small>Write in custom tattoos - lettering or a described design, in natural pigments.</small></a>"
	// RMH EDITED END
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=underwear;task=menu'>Smallclothes<small>Choose underlayers and smallclothes preferences.</small></a>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=customizers;task=menu'>Features<small>Adjust available body accessories and feature colors.</small></a>"

	if(pref_species?.use_skintones && !has_mutant_color_preferences())
		var/skin_color_value = pref_species.normalize_body_color(read_preference(/datum/preference/choiced/skin_tone)) || "000000"
		dat += "<div class='section-title'>Skin</div>"
		dat += "<a class='option-row' href='byond://?_src_=prefs;preference=s_tone;task=input;return=body_customize'><span class='swatch' style='background-color: #[skin_color_value];'></span>[pref_species.skin_tone_wording]<small>Pick a predefined skin or scale color.</small></a>"
		dat += "<a class='option-row' href='byond://?_src_=prefs;preference=skin_color_ref_list;task=input'>Color Reference<small>Open the available skin color reference list.</small></a>"

	if(has_mutant_color_preferences())
		dat += "<div class='section-title'>Mutant Colors</div>"
		for(var/color_slot in 1 to 3)
			var/feature_key = get_mutant_color_feature_key(color_slot)
			if(!feature_key)
				continue
			var/color_value = pref_species.normalize_body_color(features[feature_key]) || "000000"
			dat += "<a class='option-row' href='byond://?_src_=prefs;preference=character_setup_mutant_color;slot=[color_slot];return=body_customize'><span class='swatch' style='background-color: #[color_value];'></span>Mutant Color #[color_slot]<small>Change this character color slot.</small></a>"
	else
		dat += "<div class='section-title'>Mutant Colors</div>"
		dat += "<div class='muted'>This species has no mutant color slots.</div>"

	if(LAZYLEN(pref_species.allowed_taur_types))
		var/obj/item/bodypart/taur/T = read_preference(/datum/preference/choiced/taur_type)
		var/taur_name = ispath(T) ? T::name : "None"
		var/taur_color = read_preference(/datum/preference/color/taur_color)
		var/taur_markings = read_preference(/datum/preference/color/taur_markings)
		var/taur_tertiary = read_preference(/datum/preference/color/taur_tertiary)
		dat += "<div class='section-title'>Taur Body</div>"
		dat += "<a class='option-row' href='byond://?_src_=prefs;preference=taur_type;task=input;return=body_customize'>Body Type<small>[taur_name]</small></a>"
		dat += "<a class='option-row' href='byond://?_src_=prefs;preference=taur_color;task=input;return=body_customize'><span class='swatch' style='background-color: #[taur_color];'></span>Taur Color</a>"
		dat += "<a class='option-row' href='byond://?_src_=prefs;preference=taur_markings;task=input;return=body_customize'><span class='swatch' style='background-color: #[taur_markings];'></span>Taur Markings</a>"
		dat += "<a class='option-row' href='byond://?_src_=prefs;preference=taur_tertiary;task=input;return=body_customize'><span class='swatch' style='background-color: #[taur_tertiary];'></span>Taur Tertiary</a>"

	if(pref_species?.use_titles)
		var/display_title = read_preference(/datum/preference/text/selected_title) || "None"
		dat += "<div class='section-title'>Race Title</div>"
		dat += "<a class='option-row' href='byond://?_src_=prefs;preference=race_title;task=input;return=body_customize'>Race Title<small>[display_title]</small></a>"

	dat += {"
				<div class="footer"><a href='byond://?_src_=prefs;preference=misc;task=menu'>Extra Prefs</a></div>
			</div>
		</div>
	</body>
	</html>
	"}

	var/datum/browser/popup = new(user, "body_customization", "<div align='center'>Customize Appearance</div>", 460, 560)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/show_misc_pref_ui(mob/user)
	var/list/dat = list()
	dat += {"
	<html lang="en">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<style>
			body {
				margin: 0;
				background: #1a1a1a;
				color: #d8cf9f;
				font-family: Verdana, Geneva, sans-serif;
				font-size: 12px;
				image-rendering: pixelated;
			}
			.wrap {
				padding: 14px;
			}
			.panel {
				background: #2a2723;
				border: 2px solid #5b4b40;
				box-shadow: inset 0 0 0 1px #141211;
				padding: 12px;
			}
			h2 {
				margin: 0 0 10px;
				color: #eee69c;
				font-size: 16px;
				text-transform: uppercase;
				letter-spacing: 0;
			}
			.section-title {
				margin: 14px 0 6px;
				color: #bcae82;
				font-weight: bold;
				text-transform: uppercase;
				border-bottom: 1px solid #5b4b40;
				padding-bottom: 3px;
			}
			.option-row {
				display: block;
				background: #705d4f;
				border: 1px solid #171515;
				color: #161418;
				font-weight: bold;
				text-decoration: none;
				margin: 5px 0;
				padding: 7px 8px;
				min-height: 18px;
			}
			.option-row:hover {
				background: #8b735f;
				color: #161418;
			}
			.option-row small {
				display: block;
				color: #262020;
				font-weight: normal;
				margin-top: 2px;
			}
			.inline-actions {
				margin-top: 5px;
			}
			.inline-actions a {
				display: inline-block;
				background: #171515;
				border: 1px solid #5b4b40;
				color: #eee69c;
				font-weight: bold;
				text-decoration: none;
				margin: 0 4px 5px 0;
				padding: 5px 8px;
			}
			.inline-actions a:hover {
				background: #2f2924;
			}
			.preview-image {
				display: block;
				width: 125px;
				height: 175px;
				object-fit: cover;
				border: 2px solid #171515;
				margin-top: 6px;
			}
			.footer {
				margin-top: 12px;
				text-align: right;
			}
			.footer a {
				color: #eee69c;
				font-weight: bold;
				text-decoration: none;
			}
		</style>
	</head>
	<body>
		<div class="wrap">
			<div class="panel">
				<h2>Extra Preferences</h2>
	"}

	var/combat_music_type = read_preference(/datum/preference/choiced/combat_music)
	var/datum/combat_music/combat_music = GLOB.cmode_tracks_by_type[combat_music_type]
	var/musicname = combat_music?.shortname ? combat_music.shortname : combat_music?.name
	if(!musicname)
		musicname = "Default"
	musicname = html_encode(musicname)

	var/song_link = read_preference(/datum/preference/text/song_link)
	var/song_title = read_preference(/datum/preference/text/song_title)
	var/song_artist = read_preference(/datum/preference/text/song_artist)
	var/song_status = song_link ? "URL set" : "No URL set"
	var/song_title_display = song_title ? html_encode(song_title) : "No title set"
	var/song_artist_display = song_artist ? html_encode(song_artist) : "No artist set"

	dat += "<div class='section-title'>Personal</div>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=culinary;task=menu'>Food Preferences<small>Change favored foods and culinary preferences.</small></a>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=combat_music;task=input'>Combat Music<small>[musicname]</small></a>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=defeat_mode;task=input'>Defeat Mode<small>[defeat_mode_display_name(get_defeat_mode())] - bounded recovery, injuries and aftermath remain</small></a>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=defeat_threshold;task=input'>Defeat Damage Threshold<small>[get_defeat_damage_threshold()] pooled brute, burn, toxin and clone damage</small></a>"

	dat += "<div class='section-title'>Expression</div>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=relations_gossip'>Rivals, Rumours & Gossip<small>Author stories and configure roundstart rivals.</small></a>"

	dat += "<div class='section-title'>NSFW</div>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=nsfwflavortext;task=input'>NSFW Flavortext<small>Edit the private flavortext field.</small></a>"
	dat += "<div class='inline-actions'><a href='byond://?_src_=prefs;preference=formathelp;task=input'>Formatting Help</a></div>"

	dat += "<div class='section-title'>Examine Song</div>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=song_link;task=input'>Song URL<small>[song_status]</small></a>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=change_title;task=input'>Song Title<small>[song_title_display]</small></a>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=change_artist;task=input'>Song Artist<small>[song_artist_display]</small></a>"

	dat += "<div class='section-title'>OOC</div>"
	dat += "<a class='option-row' href='byond://?_src_=prefs;preference=player_language;task=input'>Player's Language<small>Set the language you understand oocly and prefer to speak in if possible, this will be shown in your examine to other players.</small></a>"

	dat += {"
				<div class="footer"><a href='byond://?_src_=prefs;preference=body_customize;task=menu'>Customize Appearance</a></div>
			</div>
		</div>
	</body>
	</html>
	"}

	var/datum/browser/popup = new(user, "misc_customization", "<div align='center'>Extra Preferences</div>", 460, 560)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/// Sanitization checks to be performed before using these preferences.
/datum/preferences/proc/sanitize_chosen_prefs()
	/*if(!pref_species || !pref_species.preference_accessible(src))
		pref_species = new /datum/species/human/northern
		customizer_entries = list()
		validate_customizer_entries()
		save_character()*/

	sanitize_species_mutant_colors()

	var/name_value = read_preference(/datum/preference/text/real_name)
	if(CONFIG_GET(flag/humans_need_surnames) && (pref_species.id == SPEC_ID_HUMEN))
		var/firstspace = findtext(name_value, " ")
		var/name_length = length(name_value)
		if(!firstspace)	//we need a surname
			name_value += " [pick(GLOB.last_names)]"
		else if(firstspace == name_length)
			name_value += "[pick(GLOB.last_names)]"
	if(name_value != read_preference(/datum/preference/text/real_name))
		update_preference(/datum/preference/text/real_name, name_value)

/// Applies the randomization prefs, sanitizes the result and then applies the preference to the human mob.
/// This is good if you are applying prefs to a mob as if they were joining the round.
/datum/preferences/proc/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	apply_character_randomization_prefs(is_antag)
	sanitize_chosen_prefs()
	apply_prefs_to(character, icon_updates)

/// Applies the given preferences to a human mob. Calling this directly will skip sanitisation.
/// This is good if you are applying prefs to a mob as if you were cloning them.
/datum/preferences/proc/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, character_setup = FALSE)
	if(QDELETED(character) || !ishuman(character))
		return
	character.clear_quirks()
	character.transform = matrix()

	for(var/datum/preference/preference as anything in GLOB.preferences_in_priority_order)
		if(preference.savefile_identifier != PREF_CHARACTER || !preference.should_apply)
			continue
		preference.apply_to_human(character, read_preference(preference.type), src)

	if(character.real_name in GLOB.chosen_names)
		character.real_name = pref_species.random_name(character.gender)
		character.name = character.real_name

	character.dna.features = features.Copy()
	character.dna.real_name = character.real_name
	character.dna.body_markings = deepCopyList(body_markings)
	character.cache_erp_preferences_from_prefs(src)
	character.cache_defeat_preferences_from_prefs(src)

	var/taur_type = read_preference(/datum/preference/choiced/taur_type)
	if(taur_type)
		var/taur_color = read_preference(/datum/preference/color/taur_color)
		var/taur_markings = read_preference(/datum/preference/color/taur_markings)
		var/taur_tertiary = read_preference(/datum/preference/color/taur_tertiary)
		character.Taurize(taur_type, "#[taur_color]", "#[taur_markings]", "#[taur_tertiary]")
	else if(character_setup)
		// Preview bodies are reused, so remove any taur state from the previous update.
		character.ensure_not_taur()

	var/selected_title = read_preference(/datum/preference/text/selected_title)
	if(selected_title != "None" && pref_species.use_titles && !isnull(selected_title))
		character.dna.species.name = selected_title

	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(length(smallclothes_preferences))
		apply_smallclothes_preferences(character)

	if(!character_setup)
		generate_selectable_moanpacks()
		var/moan_selection = read_preference(/datum/preference/choiced/moan_selection)
		var/voice_type = read_preference(/datum/preference/choiced/voice_type)
		if(moan_selection == MOANPACK_TYPE_DEF)
			if(voice_type == VOICE_TYPE_MASC)
				character.moan_selection = GLOB.selectable_moanpacks["MALE DEFAULT"]
			else
				character.moan_selection = GLOB.selectable_moanpacks["FEMALE DEFAULT"]
		else
			character.moan_selection = GLOB.selectable_moanpacks[moan_selection]

		var/combat_music_type = read_preference(/datum/preference/choiced/combat_music)
		var/datum/combat_music/combat_music = GLOB.cmode_tracks_by_type[combat_music_type]
		if(combat_music)
			character.cmode_music_override = combat_music.musicpath
			character.cmode_music_override_name = combat_music.name

		if(length(quirks))
			apply_quirks_to_character(character)

		if(parent)
			var/datum/role_bans/bans = get_role_bans_for_ckey(parent.ckey)
			for(var/datum/role_ban_instance/ban as anything in bans.bans)
				if(!ban.curses)
					continue
				for(var/curse_name in ban.curses)
					var/datum/curse/curse = GLOB.curse_names[curse_name]
					character.add_curse(curse.type)

			apply_trait_bans(character, parent.ckey)

			if(is_misc_banned(parent.ckey, BAN_MISC_PUNISHMENT_CURSE))
				ADD_TRAIT(character, TRAIT_PUNISHMENT_CURSE, TRAIT_BAN_PUNISHMENT)

		change_accent = length(pref_species.multiple_accents) > 0
		character.accent = read_preference(/datum/preference/choiced/selected_accent)
		apply_character_kinks(character)

	// RMH EDITED START - self-written tattoos, applied after species/bodyparts are set up
	apply_prosthetics_to_human(character, character_setup)
	apply_tattoos_to_human(character)
	// RMH EDITED END

	if(icon_updates)
		character.update_body()
		character.update_body_parts(redraw = TRUE)

/datum/preferences/proc/get_default_name(name_id)
	// you can use name_id to add more here
	return random_unique_name()

/datum/preferences/proc/ask_for_custom_name(mob/user,name_id)
	var/namedata = GLOB.preferences_custom_names[name_id]
	if(!namedata)
		return

	var/raw_name = tgui_input_text(user, "Choose your character's [namedata["qdesc"]]:", "Character Preference", max_length = MAX_NAME_LEN, encode = FALSE)
	if(!raw_name)
		if(namedata["allow_null"])
			custom_names[name_id] = get_default_name(name_id)
		else
			return
	else
		var/sanitized_name = reject_bad_name(raw_name,namedata["allow_numbers"])
		if(!sanitized_name)
			to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z,[namedata["allow_numbers"] ? ",0-9," : ""] -, ' and .</font>")
			return
		else
			custom_names[name_id] = sanitized_name

/datum/preferences/proc/try_update_mutant_colors()
	if(update_mutant_colors)
		reset_body_marking_colors()
		reset_all_customizer_accessory_colors()

/datum/preferences/proc/has_mutant_color_preferences()
	return pref_species && ((MUTCOLORS in pref_species.species_traits) || (MUTCOLORS_PARTSONLY in pref_species.species_traits))

/datum/preferences/proc/get_mutant_color_feature_key(color_slot)
	switch(color_slot)
		if(1)
			return "mcolor"
		if(2)
			return "mcolor2"
		if(3)
			return "mcolor3"
	return null

/datum/preferences/proc/get_body_color_picker_hsl(color_value)
	var/sanitized_color = sanitize_hexcolor(color_value)
	var/red = hex2num(copytext(sanitized_color, 1, 3))
	var/green = hex2num(copytext(sanitized_color, 3, 5))
	var/blue = hex2num(copytext(sanitized_color, 5, 7))

	return rgb2hsl(red, green, blue)

/datum/preferences/proc/is_body_color_picker_choice_valid(mob/user, color_value)
	var/list/hsl = get_body_color_picker_hsl(color_value)
	var/saturation = hsl[2]
	var/lightness = hsl[3]
	if(lightness < PREFERENCE_BODY_COLOR_MIN_LIGHTNESS)
		to_chat(user, span_warning("That color is too dark. Pick something a little brighter."))
		return FALSE
	if(lightness > PREFERENCE_BODY_COLOR_MAX_LIGHTNESS)
		to_chat(user, span_warning("That color is too bright. Pick something a little darker."))
		return FALSE
	if(saturation > PREFERENCE_BODY_COLOR_MAX_SATURATION)
		to_chat(user, span_warning("That color is too saturated. Pick something a little more muted."))
		return FALSE
	return TRUE

/datum/preferences/proc/sanitize_species_mutant_colors()
	if(!has_mutant_color_preferences())
		return

	var/default_color = pref_species.normalize_body_color(pref_species.default_color) || "FFFFFF"
	for(var/color_slot in 1 to 3)
		var/feature_key = get_mutant_color_feature_key(color_slot)
		features[feature_key] = pref_species.normalize_body_color(features[feature_key]) || default_color

/datum/preferences/proc/pick_mutant_color(mob/user, color_slot, prompt)
	if(!has_mutant_color_preferences())
		return

	var/feature_key = get_mutant_color_feature_key(color_slot)
	if(!feature_key)
		return

	if(!prompt)
		prompt = "Choose your character's mutant #[color_slot] color:"

	var/datum/species/picked_species = pref_species
	var/new_mutant_color = tgui_color_picker(user, prompt, "Character Preference", "#[features[feature_key]]")
	if(!new_mutant_color || QDELETED(src) || QDELETED(user) || pref_species != picked_species)
		return

	if(!is_body_color_picker_choice_valid(user, new_mutant_color))
		return

	features[feature_key] = sanitize_hexcolor(new_mutant_color)

	try_update_mutant_colors()

/datum/preferences/proc/is_active_migrant()
	if(!migrant)
		return FALSE
	if(!migrant.active)
		return FALSE
	return TRUE

/datum/preferences/proc/allowed_respawn()
	if(!has_spawned)
		return TRUE
	if(is_misc_banned(parent.ckey, BAN_MISC_RESPAWN))
		return FALSE
	return TRUE

/datum/preferences/proc/get_ui_theme_stylesheet()
	switch(read_preference(/datum/preference/choiced/ui_theme))

		if(UI_PREFERENCE_LIGHT_MODE)

			. = {"
			<html>
			<head>
			<style>
				body {
				background-color: #ffffff;
				color: #000000;
				}

				a {
				color: #1a0dab;
				}

				a:visited {
				color: #660099;
				}

				hr {
				border-top: 1px solid #ccc;
				}
			</style>
			</head>
			</html>
			"}

		if(UI_PREFERENCE_DARK_MODE)

			. = {"
			<html>
			<head>
			<style>
				body {
				background-color: #121212;
				color: #e0e0e0;
				}
				a {
				color: #90caf9;
				}
				a:visited {
				color: #ce93d8;
				}
				hr {
				border-top: 1px solid #444;
				}
			</style>
			</head>
			</html>
			"}

/// Host names shown in image link prompts; keep in sync with the two allowed_hosts lists below.
/datum/preferences/proc/get_image_host_names(nsfw = FALSE)
	if(nsfw)
		return "gyazo, lensdump, imgbox, catbox, imagechest, pixhost, file garden, imgbb"
	return "gyazo, lensdump, imgbox, catbox, postimages, freeimage, imagechest, pixhost, file garden, imgbb"

/datum/preferences/proc/is_valid_headshot_link(mob/user, value, silent = FALSE, list/valid_extensions = list("jpg", "png", "jpeg", "gif"))
	var/static/list/allowed_hosts = list(
		"i.gyazo.com",
		"a.l3n.co",
		"b.l3n.co",
		"c.l3n.co",
		"lensdump.com",
		"i.lensdump.com",
		"images2.imgbox.com",
		"thumbs2.imgbox.com",
		"thumbs4.imgbox.com",
		"files.catbox.moe",
		"i.postimg.cc",
		"iili.io",
		"cdn.imgchest.com",
		"file.garden",
		"i.ibb.co",
	)
	var/static/list/allowed_host_suffixes = list(".pixhost.to", ".pixhost.cc", ".pixho.st")

	return is_valid_external_asset_link(user, value, silent, valid_extensions, allowed_hosts, allowed_host_suffixes, "image")

/datum/preferences/proc/is_valid_nsfw_headshot_link(mob/user, value, silent = FALSE)
	var/static/list/valid_extensions = list("jpg", "png", "jpeg", "gif")
	var/static/list/allowed_hosts = list(
		"i.gyazo.com",
		"a.l3n.co",
		"b.l3n.co",
		"c.l3n.co",
		"lensdump.com",
		"i.lensdump.com",
		"images2.imgbox.com",
		"thumbs2.imgbox.com",
		"files.catbox.moe",
		"cdn.imgchest.com",
		"file.garden",
		"i.ibb.co",
	)
	var/static/list/allowed_host_suffixes = list(".pixhost.to", ".pixhost.cc", ".pixho.st")

	return is_valid_external_asset_link(user, value, silent, valid_extensions, allowed_hosts, allowed_host_suffixes, "image")

/// Hosts shown in the song prompt; gyazo, lensdump and imgbox pass is_valid_media_link() but host no audio.
/datum/preferences/proc/get_media_host_names()
	return "catbox, file garden"

/datum/preferences/proc/is_valid_media_link(mob/user, value, silent = FALSE, list/valid_extensions)
	var/static/list/allowed_hosts = list(
		"i.gyazo.com",
		"a.l3n.co",
		"b.l3n.co",
		"c.l3n.co",
		"images2.imgbox.com",
		"thumbs2.imgbox.com",
		"files.catbox.moe",
		"file.garden",
	)
	var/static/list/allowed_host_suffixes = list()

	return is_valid_external_asset_link(user, value, silent, valid_extensions, allowed_hosts, allowed_host_suffixes, "file")

/datum/preferences/proc/is_valid_external_asset_link(mob/user, value, silent, list/valid_extensions, list/allowed_hosts, list/allowed_host_suffixes, asset_name)
	var/static/list/unsafe_url_characters = list("'", "\"", "<", ">", "\[", "]", "\\")
	var/static/list/authority_delimiters = list("/", "?", "#")

	if(!istext(value) || !length(value))
		return FALSE

	if(findtext(value, "https://") != 1)
		if(!silent)
			to_chat(user, "<span class='warning'>Your link must be https!</span>")
		return FALSE

	for(var/character_index in 1 to length(value))
		if(text2ascii(value, character_index) <= 32)
			if(!silent)
				to_chat(user, "<span class='warning'>Invalid [asset_name] link!</span>")
			return FALSE

	for(var/unsafe_character in unsafe_url_characters)
		if(findtext(value, unsafe_character))
			if(!silent)
				to_chat(user, "<span class='warning'>Invalid [asset_name] link!</span>")
			return FALSE

	var/authority_start = length("https://") + 1
	var/authority_end = length(value) + 1
	for(var/delimiter in authority_delimiters)
		var/delimiter_index = findtext(value, delimiter, authority_start)
		if(delimiter_index && delimiter_index < authority_end)
			authority_end = delimiter_index

	var/path_start = findtext(value, "/", authority_start)
	if(!path_start || path_start != authority_end)
		if(!silent)
			to_chat(user, "<span class='warning'>The [asset_name] link must include a direct file path.</span>")
		return FALSE

	var/hostname = LOWER_TEXT(copytext(value, authority_start, authority_end))
	if(!length(hostname) || findtext(hostname, "@") || findtext(hostname, ":"))
		if(!silent)
			to_chat(user, "<span class='warning'>Invalid [asset_name] link!</span>")
		return FALSE

	var/is_allowed_host = (hostname in allowed_hosts)
	if(!is_allowed_host)
		for(var/allowed_suffix in allowed_host_suffixes)
			if(length(hostname) > length(allowed_suffix) && copytext(hostname, length(hostname) - length(allowed_suffix) + 1) == allowed_suffix)
				is_allowed_host = TRUE
				break

	if(!is_allowed_host)
		if(!silent)
			to_chat(user, "<span class='warning'>The [asset_name] must be hosted on an approved site.</span>")
		return FALSE

	var/path_end = length(value) + 1
	var/query_start = findtext(value, "?", path_start)
	if(query_start)
		path_end = query_start
	var/fragment_start = findtext(value, "#", path_start)
	if(fragment_start && fragment_start < path_end)
		path_end = fragment_start

	var/path = copytext(value, path_start, path_end)
	var/list/path_parts = splittext(path, "/")
	var/filename = path_parts[length(path_parts)]
	var/list/file_parts = splittext(filename, ".")
	if(length(file_parts) < 2)
		if(!silent)
			to_chat(user, "<span class='warning'>The [asset_name] link must include a file extension.</span>")
		return FALSE

	var/extension = LOWER_TEXT(file_parts[length(file_parts)])
	if(!(extension in valid_extensions))
		if(!silent)
			to_chat(user, "<span class='warning'>The [asset_name] must be one of the following extensions: '[english_list(valid_extensions)]'</span>")
		return FALSE

	return TRUE


/datum/preferences/proc/resolve_loadout_to_color(item_path)
	if (loadout1 && (item_path == loadout1.item_path) && loadout_1_hex)
		return loadout_1_hex
	if (loadout2 && (item_path == loadout2.item_path) && loadout_2_hex)
		return loadout_2_hex
	if (loadout3 && (item_path == loadout3.item_path) && loadout_3_hex)
		return loadout_3_hex
	if (loadout4 && (item_path == loadout4.item_path) && loadout_4_hex)
		return loadout_4_hex
	if (loadout5 && (item_path == loadout5.item_path) && loadout_5_hex)
		return loadout_5_hex
	if (loadout6 && (item_path == loadout6.item_path) && loadout_6_hex)
		return loadout_6_hex
	if (loadout7 && (item_path == loadout7.item_path) && loadout_7_hex)
		return loadout_7_hex
	if (loadout8 && (item_path == loadout8.item_path) && loadout_8_hex)
		return loadout_8_hex
	if (loadout9 && (item_path == loadout9.item_path) && loadout_9_hex)
		return loadout_9_hex
	if (loadout10 && (item_path == loadout10.item_path) && loadout_10_hex)
		return loadout_10_hex

	return FALSE

/datum/preferences/proc/get_job_lock_html(datum/job/job, mob/user, used_name)
	var/player_species = user.client.prefs.pref_species.id_override || user.client.prefs.pref_species.id
	var/fails_allowed = length(job.allowed_races) && !(player_species in job.allowed_races)
	var/fails_blacklist = length(job.blacklisted_species) && (player_species in job.blacklisted_species)
	if(job.required_playtime_remaining(user.client))
		var/list/lines = list()
		for(var/t in job.exp_requirements)
			var/needed = job.exp_requirements[t]
			var/have = user.client.calc_exp_type(t)
			lines += "[t]: [get_exp_format(have)] / [get_exp_format(needed)]"
		var/text = jointext(lines, "<br>")

		return make_lock_row(
			used_name,
			"\[TIME LOCK\]",
			"<b>Requirements:</b><br>[text]"
		)
	if(fails_allowed || fails_blacklist)
		if(!user.client.has_triumph_buy(TRIUMPH_BUY_RACE_ALL))
			var/list/allowed_races = job.allowed_races.Copy()
			for(var/blacklist in job.blacklisted_species)
				allowed_races -= blacklist
			var/races_text = jointext(allowed_races, ", ")
			return make_lock_row(
				used_name,
				"\[SPECIES LOCK\]",
				"<b>Species Needed:</b><br>[races_text]"
			)
	if(length(job.allowed_ages) && !(user.client.prefs.read_preference(/datum/preference/choiced/age) in job.allowed_ages))
		var/ages_text = jointext(job.allowed_ages, ", ")
		return make_lock_row(
			used_name,
			"\[AGE LOCK\]",
			"<b>Ages Needed:</b><br>[ages_text]"
		)
	if(length(job.allowed_sexes) && !(user.client.prefs.read_preference(/datum/preference/choiced/gender) in job.allowed_sexes))
		var/sexes_text = jointext(job.allowed_sexes, ", ")
		return make_lock_row(
			used_name,
			"\[SEX LOCK\]",
			"<b>Sexes Needed:</b><br>[sexes_text]"
		)
	var/datum/patron/selected_patron = user.client.prefs.read_preference(/datum/preference/choiced/patron)
	if(length(job.allowed_patrons) && !(selected_patron?.type in job.allowed_patrons))
		var/list/patron_list = list()
		for(var/mult_patron in job.allowed_patrons)
			var/datum/patron/P = new mult_patron
			patron_list += (P.display_name ? P.display_name : P.name)
			qdel(P)
		var/patron_text = jointext(patron_list, ", ")

		return make_lock_row(
			used_name,
			"\[PATRON LOCK\]",
			"<b>Patron Needed:</b><br>[patron_text]"
		)
	if(job.requires_job_whitelist() && !job.player_has_job_whitelist(user.client))
		return make_lock_row(
			used_name,
			"\[WHITELIST\]",
			"This role requires you to be whitelisted for it."
		)
	// No lock
	return FALSE

/datum/preferences/proc/make_lock_row(used_name, lock_text, body_text)
	return {"
		[used_name]
	</td>
	<td>
		<div class='tutorialhover'>
			<font color=#a36c63>[lock_text]</font>
			<span class='tutorial'>[body_text]</span>
		</div>
	</td>
	</tr>
	"}

/// Re-applies the ambient occlusion filters on the planes that carry them.
/proc/update_occlusion(client/parent_cl)
	var/mob/viewer = parent_cl?.mob
	var/datum/hud/viewer_hud = viewer?.hud_used
	if(!viewer_hud)
		return
	var/static/list/occlusion_planes = list(GAME_PLANE, GAME_PLANE_FOV_HIDDEN, GAME_PLANE_UPPER, GAME_PLANE_LOWER, MASSIVE_OBJ_PLANE, WALL_PLANE)
	for(var/plane in occlusion_planes)
		var/atom/movable/screen/plane_master/plane_master = viewer_hud.plane_masters["[plane]"]
		plane_master?.backdrop(viewer)

/datum/preferences/proc/resolve_loadout_to_name(item_path)
	if (loadout1 && (item_path == loadout1.item_path) && loadout_1_name)
		return loadout_1_name
	if (loadout2 && (item_path == loadout2.item_path) && loadout_2_name)
		return loadout_2_name
	if (loadout3 && (item_path == loadout3.item_path) && loadout_3_name)
		return loadout_3_name
	if (loadout4 && (item_path == loadout4.item_path) && loadout_4_name)
		return loadout_4_name
	if (loadout5 && (item_path == loadout5.item_path) && loadout_5_name)
		return loadout_5_name
	if (loadout6 && (item_path == loadout6.item_path) && loadout_6_name)
		return loadout_6_name
	if (loadout7 && (item_path == loadout7.item_path) && loadout_7_name)
		return loadout_7_name
	if (loadout8 && (item_path == loadout8.item_path) && loadout_8_name)
		return loadout_8_name
	if (loadout9 && (item_path == loadout9.item_path) && loadout_9_name)
		return loadout_9_name
	if (loadout10 && (item_path == loadout10.item_path) && loadout_10_name)
		return loadout_10_name

	return FALSE

/datum/preferences/proc/resolve_loadout_to_desc(item_path)
	if (loadout1 && (item_path == loadout1.item_path) && loadout_1_desc)
		return loadout_1_desc
	if (loadout2 && (item_path == loadout2.item_path) && loadout_2_desc)
		return loadout_2_desc
	if (loadout3 && (item_path == loadout3.item_path) && loadout_3_desc)
		return loadout_3_desc
	if (loadout4 && (item_path == loadout4.item_path) && loadout_4_desc)
		return loadout_4_desc
	if (loadout5 && (item_path == loadout5.item_path) && loadout_5_desc)
		return loadout_5_desc
	if (loadout6 && (item_path == loadout6.item_path) && loadout_6_desc)
		return loadout_6_desc
	if (loadout7 && (item_path == loadout7.item_path) && loadout_7_desc)
		return loadout_7_desc
	if (loadout8 && (item_path == loadout8.item_path) && loadout_8_desc)
		return loadout_8_desc
	if (loadout9 && (item_path == loadout9.item_path) && loadout_9_desc)
		return loadout_9_desc
	if (loadout10 && (item_path == loadout10.item_path) && loadout_10_desc)
		return loadout_10_desc

	return FALSE
