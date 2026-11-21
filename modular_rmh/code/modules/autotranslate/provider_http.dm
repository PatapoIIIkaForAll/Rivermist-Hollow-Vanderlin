/// Shared rust-g HTTP plumbing. Requests run on rust-g threads, so the game loop only polls them.
/datum/translation_provider/http
	state = AUTOTRANSLATE_BACKEND_CHECKING
	/// Base URL with no trailing slash.
	var/endpoint
	var/token
	var/timeout_seconds = 5
	var/datum/http_request/probe_request
	/// Source language code -> list of target codes, from the last health check.
	var/list/supported_targets

/datum/translation_provider/http/New(endpoint, token, timeout_seconds)
	while(length(endpoint) && endpoint[length(endpoint)] == "/")
		endpoint = copytext(endpoint, 1, length(endpoint))
	src.endpoint = endpoint
	src.token = token
	if(timeout_seconds)
		src.timeout_seconds = timeout_seconds

/datum/translation_provider/http/endpoint_text()
	return endpoint

/datum/translation_provider/http/supports(source_language, target_language)
	return (target_language in supported_targets?[source_language])

/datum/translation_provider/http/proc/headers()
	return list("Content-Type" = "application/json")

/// Reads the decoded language list into supported_targets. TRUE if it holds at least one direction.
/datum/translation_provider/http/proc/read_languages(decoded)
	return FALSE

/datum/translation_provider/http/proc/request_body(datum/translation_request/request, plain_text)
	return list()

/datum/translation_provider/http/proc/read_result(list/decoded)
	return null

/datum/translation_provider/http/begin_probe()
	if(probe_request)
		return
	state = AUTOTRANSLATE_BACKEND_CHECKING
	probe_request = new(RUSTG_HTTP_METHOD_GET, "[endpoint]/languages", "", headers(), null, timeout_seconds)
	probe_request.begin_async()

/datum/translation_provider/http/poll_probe()
	if(!probe_request)
		return TRUE
	if(!probe_request.is_complete())
		return FALSE
	var/datum/http_response/response = probe_request.into_response()
	probe_request = null

	var/failure = response_failure(response)
	var/decoded
	if(!failure)
		try
			decoded = json_decode(response.body)
		catch
			failure = "language list is not JSON"
	supported_targets = list()
	if(!failure && !read_languages(decoded))
		failure = "backend lists no languages"

	state = failure ? AUTOTRANSLATE_BACKEND_DOWN : AUTOTRANSLATE_BACKEND_OK
	note = failure
	return TRUE

/// Error text for a response that cannot be used, or null. rust-g reports most HTTP errors as plain text.
/datum/translation_provider/http/proc/response_failure(datum/http_response/response)
	if(response.errored)
		return "[response.error]"
	if(response.status_code != 200)
		return "HTTP [response.status_code]"
	return null

/datum/translation_provider/http/begin(datum/translation_request/request)
	// Chat text is HTML-encoded. A translator must get the plain characters, or it translates "&#39;" as text.
	var/body = json_encode(request_body(request, html_decode(request.source_text)))
	var/datum/http_request/http = new(RUSTG_HTTP_METHOD_POST, "[endpoint]/translate", body, headers(), null, timeout_seconds)
	http.begin_async()
	request.provider_state = http

/datum/translation_provider/http/poll(datum/translation_request/request)
	var/datum/http_request/http = request.provider_state
	if(!http)
		request.error_reason = "request was not started"
		return TRUE
	if(!http.is_complete())
		return FALSE
	request.provider_state = null

	var/datum/http_response/response = http.into_response()
	request.error_reason = response_failure(response)
	if(request.error_reason)
		return TRUE
	var/translated
	try
		translated = read_result(json_decode(response.body))
	catch
		request.error_reason = "result is not JSON"
		return TRUE
	if(!istext(translated) || !length(translated))
		request.error_reason = "result has no text"
		return TRUE
	request.result = html_encode(translated)
	return TRUE


/// https://github.com/xxnuo/MTranServer
/datum/translation_provider/http/mtranserver
	name = "MTranServer"

/datum/translation_provider/http/mtranserver/headers()
	. = ..()
	if(token)
		.["Authorization"] = "Bearer [token]"

/datum/translation_provider/http/mtranserver/read_languages(decoded)
	if(!islist(decoded))
		return FALSE
	for(var/list/pair in decoded["pairs"])
		var/source = pair["from"]
		var/target = pair["to"]
		if(source && target)
			LAZYADDASSOCLIST(supported_targets, source, target)
	return length(supported_targets) > 0

/datum/translation_provider/http/mtranserver/request_body(datum/translation_request/request, plain_text)
	return list(
		"from" = request.source_language,
		"to" = request.target_language,
		"text" = plain_text,
	)

/datum/translation_provider/http/mtranserver/read_result(list/decoded)
	return decoded["result"]


/// https://github.com/LibreTranslate/LibreTranslate
/datum/translation_provider/http/libretranslate
	name = "LibreTranslate"

/datum/translation_provider/http/libretranslate/read_languages(decoded)
	if(!islist(decoded))
		return FALSE
	for(var/list/language in decoded)
		var/code = language["code"]
		var/list/targets = language["targets"]
		if(code && length(targets))
			supported_targets[code] = targets
	return length(supported_targets) > 0

/datum/translation_provider/http/libretranslate/request_body(datum/translation_request/request, plain_text)
	. = list(
		"q" = plain_text,
		"source" = request.source_language,
		"target" = request.target_language,
		"format" = "text",
	)
	if(token)
		.["api_key"] = token

/datum/translation_provider/http/libretranslate/read_result(list/decoded)
	return decoded["translatedText"]
