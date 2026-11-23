/**
 * Translates chat between players who read different real languages.
 *
 * Owns the backend provider, shares one request between all listeners of the same text,
 * caches results for the round, and keeps the numbers the admin panel shows.
 */
SUBSYSTEM_DEF(autotranslate)
	name = "Auto Translate"
	wait = 1
	priority = FIRE_PRIORITY_DEFAULT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/datum/translation_provider/provider
	/// "configured", "fake" or "none": which provider the admin panel last chose.
	var/provider_mode = "configured"
	/// FALSE before Initialize() and after an emergency stop. Every hook reads this first.
	var/running = FALSE
	var/stopped_by

	var/list/datum/translation_request/active_requests = list()
	/// Cache key -> request in flight.
	var/alist/requests_by_key
	/// Cache key -> HTML-encoded translation. Two generations bound the size without tracking use.
	var/alist/cache_recent
	var/alist/cache_previous
	var/cache_chars = 0

	var/max_chars = 2000
	var/max_requests = 16
	var/cache_limit = 5000

	/// The line being rendered for one listener. Set and cleared inside one Hear() or emote send.
	var/datum/translated_line/current_line
	var/datum/autotranslate_emote/current_emote
	var/live_lines = 0

	var/consecutive_failures = 0
	var/next_probe_at = 0

	var/dispatched = 0
	var/deduplicated = 0
	var/cache_hits = 0
	var/cache_misses = 0
	var/failed = 0
	var/timed_out = 0
	var/rejected = 0
	var/chars_sent = 0
	var/latency_last_ms = 0
	var/latency_max_ms = 0
	var/list/latency_samples = list()
	/// Channel name -> translated lines. A small fixed set of names.
	var/list/channel_counts = list()
	/// Newest first: list("time" = text, "text" = text).
	var/list/errors = list()

	/// Server time used by message hooks, which run outside fire().
	var/hook_cost_ms = 0
	var/fire_cost_ms = 0
	var/cost_last_minute_ms = 0
	var/cost_at_last_sample = 0
	var/next_cost_sample = 0

	var/datum/autotranslate_test/test

/datum/controller/subsystem/autotranslate/Initialize(start_timeofday)
	requests_by_key = alist()
	cache_recent = alist()
	cache_previous = alist()
	test = new
	max_chars = CONFIG_GET(number/translate_max_chars)
	max_requests = CONFIG_GET(number/translate_max_requests)
	cache_limit = CONFIG_GET(number/translate_cache_entries)
	set_provider(configured_provider())
	running = TRUE
	return ..()

/datum/controller/subsystem/autotranslate/stat_entry(msg)
	msg = "[provider?.name]:[running ? provider.state : "STOPPED"]|Active:[length(active_requests)]|Cached:[cache_size()]"
	return ..()

/// The provider the config file asks for. Never null.
/datum/controller/subsystem/autotranslate/proc/configured_provider()
	var/endpoint = CONFIG_GET(string/translate_http_url)
	var/token = CONFIG_GET(string/translate_http_token)
	var/timeout_seconds = CONFIG_GET(number/translate_http_timeout_seconds)
	if(!endpoint)
		return new /datum/translation_provider
	switch(LOWER_TEXT(CONFIG_GET(string/translate_provider)))
		if("mtranserver")
			return new /datum/translation_provider/http/mtranserver(endpoint, token, timeout_seconds)
		if("libretranslate")
			return new /datum/translation_provider/http/libretranslate(endpoint, token, timeout_seconds)
	log_world("SSautotranslate: TRANSLATE_PROVIDER '[CONFIG_GET(string/translate_provider)]' is not known. Use mtranserver or libretranslate.")
	return new /datum/translation_provider

/datum/controller/subsystem/autotranslate/proc/set_provider(datum/translation_provider/new_provider)
	fail_all_requests()
	provider = new_provider
	consecutive_failures = 0
	provider.begin_probe()
	log_world("SSautotranslate: provider is [provider.name][provider.endpoint_text() ? " at [provider.endpoint_text()]" : ""]")

/// TRUE if a line in source_language can be translated for a reader of target_language now.
/datum/controller/subsystem/autotranslate/proc/can_translate(source_language, target_language)
	if(!running || provider.state != AUTOTRANSLATE_BACKEND_OK)
		return FALSE
	return provider.supports(source_language, target_language)

/datum/controller/subsystem/autotranslate/proc/cache_size()
	return length(cache_recent) + length(cache_previous)

/// The cached HTML-encoded translation, or null. A hit in the older generation moves to the newer one.
/datum/controller/subsystem/autotranslate/proc/get_cached(text, source_language, target_language)
	var/key = "[source_language]|[target_language]|[text]"
	var/cached = cache_recent[key]
	if(isnull(cached))
		cached = cache_previous[key]
		if(isnull(cached))
			return null
		cache_previous -= key
		cache_recent[key] = cached
	cache_hits++
	return cached

/datum/controller/subsystem/autotranslate/proc/store_in_cache(key, translated)
	if(!cache_limit)
		return
	// Dropping the older half at once keeps eviction O(1) per stored line.
	if(length(cache_recent) >= cache_limit / 2)
		for(var/old_key, old_text in cache_previous)
			cache_chars -= length(old_text)
		cache_previous = cache_recent
		cache_recent = alist()
	cache_recent[key] = translated
	cache_chars += length(translated)

/datum/controller/subsystem/autotranslate/proc/clear_cache()
	. = cache_size()
	cache_recent = alist()
	cache_previous = alist()
	cache_chars = 0

/**
 * Asks for a translation of HTML-encoded text. on_result is called later with (translated_text, success).
 * Returns FALSE when nothing was started; then on_result is never called. Check get_cached() first.
 */
/datum/controller/subsystem/autotranslate/proc/request_translation(text, source_language, target_language, datum/callback/on_result, channel)
	if(!can_translate(source_language, target_language))
		return FALSE
	var/key = "[source_language]|[target_language]|[text]"
	var/datum/translation_request/request = requests_by_key[key]
	if(request)
		deduplicated++
		request.subscribers += on_result
		return TRUE
	if(length_char(text) > max_chars || length(active_requests) >= max_requests)
		rejected++
		return FALSE

	// Restarting the clock while idle keeps its readings small enough to stay exact as floats.
	if(!length(active_requests))
		rustg_time_reset(AUTOTRANSLATE_CLOCK)
	request = new(key, text, source_language, target_language, channel)
	request.subscribers += on_result
	request.started_at = world.time
	request.started_ms = rustg_time_milliseconds(AUTOTRANSLATE_CLOCK)
	requests_by_key[key] = request
	active_requests += request
	cache_misses++
	dispatched++
	chars_sent += length_char(text)
	provider.begin(request)
	return TRUE

/datum/controller/subsystem/autotranslate/fire(resumed)
	var/fire_start = TICK_USAGE_REAL
	if(world.time >= next_cost_sample)
		next_cost_sample = world.time + 1 MINUTES
		var/cost_now = hook_cost_ms + fire_cost_ms
		cost_last_minute_ms = cost_now - cost_at_last_sample
		cost_at_last_sample = cost_now

	provider.poll_probe()
	if(provider.state == AUTOTRANSLATE_BACKEND_DOWN && world.time >= next_probe_at)
		next_probe_at = world.time + AUTOTRANSLATE_PROBE_INTERVAL
		provider.begin_probe()

	if(length(active_requests))
		// active_requests changes while results are delivered, so walk a copy.
		for(var/datum/translation_request/request as anything in active_requests.Copy())
			if(world.time > request.started_at + AUTOTRANSLATE_REQUEST_TIMEOUT)
				request.error_reason = "timed out"
				timed_out++
			else if(!provider.poll(request))
				continue
			finish_request(request)
			if(MC_TICK_CHECK)
				break
	fire_cost_ms += TICK_USAGE_TO_MS(fire_start)

/datum/controller/subsystem/autotranslate/proc/finish_request(datum/translation_request/request)
	active_requests -= request
	requests_by_key -= request.key
	var/success = !request.error_reason && !isnull(request.result)
	if(success)
		consecutive_failures = 0
		latency_last_ms = rustg_time_milliseconds(AUTOTRANSLATE_CLOCK) - request.started_ms
		latency_max_ms = max(latency_max_ms, latency_last_ms)
		latency_samples += latency_last_ms
		if(length(latency_samples) > AUTOTRANSLATE_LATENCY_SAMPLES)
			latency_samples.Cut(1, 2)
		store_in_cache(request.key, request.result)
	else
		failed++
		note_error(request.error_reason)
		consecutive_failures++
		if(consecutive_failures >= AUTOTRANSLATE_FAILURES_TO_TRIP && provider.state == AUTOTRANSLATE_BACKEND_OK)
			provider.state = AUTOTRANSLATE_BACKEND_DOWN
			provider.note = request.error_reason
			consecutive_failures = 0
			next_probe_at = world.time + AUTOTRANSLATE_PROBE_INTERVAL
			log_world("SSautotranslate: backend marked down after [AUTOTRANSLATE_FAILURES_TO_TRIP] failures in a row: [request.error_reason]")
	for(var/datum/callback/subscriber as anything in request.subscribers)
		subscriber.Invoke(request.result, success)

/datum/controller/subsystem/autotranslate/proc/note_error(reason)
	errors.Insert(1, list(list("time" = time_stamp(), "text" = "[reason]")))
	if(length(errors) > AUTOTRANSLATE_ERROR_HISTORY)
		errors.Cut(AUTOTRANSLATE_ERROR_HISTORY + 1)

/// Ends every request in flight as failed, so waiting chat lines keep their original text.
/datum/controller/subsystem/autotranslate/proc/fail_all_requests()
	var/list/datum/translation_request/dropped = active_requests
	active_requests = list()
	requests_by_key = alist()
	for(var/datum/translation_request/request as anything in dropped)
		for(var/datum/callback/subscriber as anything in request.subscribers)
			subscriber.Invoke(null, FALSE)

/datum/controller/subsystem/autotranslate/proc/emergency_stop(stopper)
	if(!running)
		return
	running = FALSE
	stopped_by = "[stopper]"
	current_line = null
	current_emote = null
	fail_all_requests()
	log_admin("[stopper] used the translation emergency stop.")
	message_admins("[stopper] used the translation emergency stop. Chat translation is off until someone resumes it.")

/datum/controller/subsystem/autotranslate/proc/resume(resumer)
	if(running)
		return
	running = TRUE
	stopped_by = null
	consecutive_failures = 0
	provider.begin_probe()
	log_admin("[resumer] resumed chat translation.")
	message_admins("[resumer] resumed chat translation.")

/datum/controller/subsystem/autotranslate/proc/average_latency_ms()
	if(!length(latency_samples))
		return 0
	var/total = 0
	for(var/sample in latency_samples)
		total += sample
	return total / length(latency_samples)
