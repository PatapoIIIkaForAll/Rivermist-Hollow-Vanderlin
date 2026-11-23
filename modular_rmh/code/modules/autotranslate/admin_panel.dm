#define AUTOTRANSLATE_TEST_IDLE "idle"
#define AUTOTRANSLATE_TEST_RUNNING "running"
#define AUTOTRANSLATE_TEST_DONE "done"
#define AUTOTRANSLATE_TEST_FAILED "failed"
#define AUTOTRANSLATE_TEST_MAX_CHARS 300
#define AUTOTRANSLATE_MS_PER_MINUTE 60000

/// One translation sent from the admin panel, so admins can check the backend without a second player.
/datum/autotranslate_test
	var/status = AUTOTRANSLATE_TEST_IDLE
	/// Plain text, as typed.
	var/source_text
	var/direction
	/// Plain text result, or the reason of a failure.
	var/result
	var/latency_ms

/datum/autotranslate_test/proc/start(text, direction)
	var/list/languages = splittext(direction, "_")
	source_text = copytext_char(text, 1, AUTOTRANSLATE_TEST_MAX_CHARS + 1)
	src.direction = direction
	result = null
	latency_ms = null
	status = AUTOTRANSLATE_TEST_RUNNING
	var/encoded = html_encode(source_text)
	var/cached = SSautotranslate.get_cached(encoded, languages[1], languages[2])
	if(cached)
		on_result(cached, TRUE)
		latency_ms = 0
		return
	if(!SSautotranslate.request_translation(encoded, languages[1], languages[2], CALLBACK(src, PROC_REF(on_result)), AUTOTRANSLATE_CHANNEL_TEST))
		status = AUTOTRANSLATE_TEST_FAILED
		result = "Not sent. The backend is not ready, the queue is full, or the text is too long."

/datum/autotranslate_test/proc/on_result(text, success)
	if(success)
		status = AUTOTRANSLATE_TEST_DONE
		result = html_decode(text)
		latency_ms = SSautotranslate.latency_last_ms
		return
	status = AUTOTRANSLATE_TEST_FAILED
	var/list/last_error = length(SSautotranslate.errors) ? SSautotranslate.errors[1] : null
	result = last_error?["text"] || "The request failed."

/datum/controller/subsystem/autotranslate/ui_status(mob/user, datum/ui_state/state)
	if(!user.client?.holder?.check_for_rights(R_ADMIN))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/controller/subsystem/autotranslate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new /datum/tgui(user, src, "TranslationControl", "Translation Control")
		ui.open()

/datum/controller/subsystem/autotranslate/ui_data(mob/user)
	var/list/data = list()
	data["running"] = running
	data["stopped_by"] = stopped_by
	data["provider"] = provider.name
	data["provider_mode"] = provider_mode
	data["backend_state"] = provider.state
	data["backend_note"] = provider.note
	data["endpoint"] = provider.endpoint_text()
	data["can_debug"] = check_rights_for(user.client, R_DEBUG)

	var/cost_total = hook_cost_ms + fire_cost_ms
	data["load"] = list(
		"world_cpu" = world.cpu,
		"map_cpu" = world.map_cpu,
		"time_dilation" = SStime_track.time_dilation_current,
		"ss_cost_ms" = cost,
		"ss_tick_usage" = tick_usage,
		"ss_tick_overrun" = tick_overrun,
		"cpu_ms_last_min" = cost_last_minute_ms,
		"cpu_ms_total" = cost_total,
		"share_percent" = cost_last_minute_ms / AUTOTRANSLATE_MS_PER_MINUTE * 100,
	)
	data["traffic"] = list(
		"in_flight" = length(active_requests),
		"queue_limit" = max_requests,
		"dispatched" = dispatched,
		"deduplicated" = deduplicated,
		"cache_hits" = cache_hits,
		"cache_misses" = cache_misses,
		"failed" = failed,
		"timed_out" = timed_out,
		"rejected" = rejected,
		"chars_sent" = chars_sent,
		"latency_last_ms" = latency_last_ms,
		"latency_avg_ms" = average_latency_ms(),
		"latency_max_ms" = latency_max_ms,
	)
	data["memory"] = list(
		"cache_entries" = cache_size(),
		"cache_limit" = cache_limit,
		"cache_chars" = cache_chars,
		"live_lines" = live_lines,
	)

	var/to_english = 0
	var/to_russian = 0
	for(var/client/player as anything in GLOB.clients)
		switch(player.autotranslate_target || player.read_autotranslate_target())
			if(AUTOTRANSLATE_LANG_EN)
				to_english++
			if(AUTOTRANSLATE_LANG_RU)
				to_russian++
	data["players"] = list(
		"total" = length(GLOB.clients),
		"to_english" = to_english,
		"to_russian" = to_russian,
	)

	var/list/channels = list()
	for(var/channel in channel_counts)
		channels += list(list("name" = channel, "count" = channel_counts[channel]))
	data["channels"] = channels
	data["errors"] = errors
	data["test"] = list(
		"status" = test.status,
		"source_text" = test.source_text,
		"direction" = test.direction,
		"result" = test.result,
		"latency_ms" = test.latency_ms,
	)
	return data

/datum/controller/subsystem/autotranslate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return TRUE
	var/mob/admin = ui.user
	switch(action)
		if("emergency_stop")
			emergency_stop(key_name(admin))
			return TRUE
		if("resume")
			resume(key_name(admin))
			return TRUE
		if("clear_cache")
			log_admin("[key_name(admin)] cleared the translation cache ([clear_cache()] entries).")
			return TRUE
		if("probe")
			provider.begin_probe()
			return TRUE
		if("set_provider")
			if(!check_rights_for(admin.client, R_DEBUG))
				return
			var/datum/translation_provider/new_provider
			var/mode = params["provider"]
			switch(mode)
				if("configured")
					new_provider = configured_provider()
				if("fake")
					new_provider = new /datum/translation_provider/fake
				if("none")
					new_provider = new /datum/translation_provider
				else
					return
			set_provider(new_provider)
			provider_mode = mode
			log_admin("[key_name(admin)] set the translation provider to [new_provider.name].")
			message_admins("[key_name_admin(admin)] set the translation provider to [new_provider.name].")
			return TRUE
		if("test")
			var/text = params["text"]
			var/direction = params["direction"]
			if(!running || !istext(text) || !length(text) || !(direction in list("ru_en", "en_ru")))
				return
			test.start(text, direction)
			return TRUE

/client/proc/translation_control()
	set name = "Translation Control"
	set desc = "Load, backend state and the emergency stop of chat translation."
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return
	if(!SSautotranslate.initialized)
		to_chat(src, span_warning("The translation subsystem has not started yet."))
		return
	SSautotranslate.ui_interact(usr)

/client/proc/translation_emergency_stop()
	set name = "Translation Emergency Stop"
	set desc = "Stops all chat translation at once. Resume it in Translation Control."
	set category = "Admin"

	if(!check_rights(R_ADMIN))
		return
	if(!SSautotranslate.running)
		to_chat(src, span_notice("Chat translation is already stopped. Resume it in Translation Control."))
		return
	SSautotranslate.emergency_stop(key_name(src))

/world/AVerbsAdmin()
	. = ..()
	. += list(
		/client/proc/translation_control,
		/client/proc/translation_emergency_stop,
	)

#undef AUTOTRANSLATE_TEST_IDLE
#undef AUTOTRANSLATE_TEST_RUNNING
#undef AUTOTRANSLATE_TEST_DONE
#undef AUTOTRANSLATE_TEST_FAILED
#undef AUTOTRANSLATE_TEST_MAX_CHARS
#undef AUTOTRANSLATE_MS_PER_MINUTE
