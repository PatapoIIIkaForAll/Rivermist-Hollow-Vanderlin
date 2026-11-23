/// One text in one direction. Every listener who needs it subscribes to the same request.
/datum/translation_request
	var/key
	/// HTML-encoded, as the chat pipeline carries it.
	var/source_text
	var/source_language
	var/target_language
	var/channel
	/// HTML-encoded translation, set on success.
	var/result
	var/error_reason
	var/started_at = 0
	/// Reading of the latency clock at dispatch, in ms.
	var/started_ms = 0
	/// Callbacks called with (translated_text, success).
	var/list/datum/callback/subscribers = list()
	/// Provider scratch value: the HTTP request, or a ready time for the fake provider.
	var/provider_state

/datum/translation_request/New(key, source_text, source_language, target_language, channel)
	src.key = key
	src.source_text = source_text
	src.source_language = source_language
	src.target_language = target_language
	src.channel = channel

/**
 * A translation backend. begin() starts the work and poll() reports on it; neither may block,
 * because both run inside the subsystem's fire().
 */
/datum/translation_provider
	var/name = "None"
	var/state = AUTOTRANSLATE_BACKEND_OFF
	/// Last error from a health check.
	var/note

/datum/translation_provider/proc/supports(source_language, target_language)
	return FALSE

/datum/translation_provider/proc/endpoint_text()
	return null

/datum/translation_provider/proc/begin(datum/translation_request/request)
	return

/// TRUE when the request has ended. Sets request.result on success and request.error_reason on failure.
/datum/translation_provider/proc/poll(datum/translation_request/request)
	request.error_reason = "no backend"
	return TRUE

/// Starts a health check. The answer arrives through poll_probe().
/datum/translation_provider/proc/begin_probe()
	return

/// TRUE when no health check is in flight. Updates state and note.
/datum/translation_provider/proc/poll_probe()
	return TRUE

/// Answers after a delay with the source text behind a language tag. Lets admins test the display with no backend.
/datum/translation_provider/fake
	name = "Fake (debug)"
	state = AUTOTRANSLATE_BACKEND_OK
	var/latency = 0.3 SECONDS

/datum/translation_provider/fake/supports(source_language, target_language)
	return TRUE

/datum/translation_provider/fake/begin(datum/translation_request/request)
	request.provider_state = world.time + latency

/datum/translation_provider/fake/poll(datum/translation_request/request)
	if(world.time < request.provider_state)
		return FALSE
	request.result = "\[[request.target_language]\] [request.source_text]"
	return TRUE
