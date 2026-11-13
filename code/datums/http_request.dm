/datum/http_request
	var/id
	var/in_progress = FALSE

	var/method
	var/body
	var/headers
	var/url
	/// If present response body will be saved to this file.
	var/output_file
	/// If set, rust_g fails the whole request after this many seconds.
	var/timeout_seconds

	var/_raw_response

/datum/http_request/New(...)
	. = ..()
	if(length(args))
		src.prepare(arglist(args))

/datum/http_request/proc/prepare(method, url, body = "", list/headers, output_file, timeout_seconds)
	if (!length(headers))
		headers = ""
	else
		headers = json_encode(headers)

	src.method = method
	src.url = url
	src.body = body
	src.headers = headers
	src.output_file = output_file
	src.timeout_seconds = timeout_seconds

/datum/http_request/proc/execute_blocking()
	_raw_response = rustg_http_request_blocking(method, url, body, headers, build_options())

/datum/http_request/proc/begin_async()
	if (in_progress)
		CRASH("Attempted to re-use a request object.")

	id = rustg_http_request_async(method, url, body, headers, build_options())

	if (isnull(text2num(id)))
		stack_trace("Proc error: [id]")
		_raw_response = "Proc error: [id]"
	else
		in_progress = TRUE

/datum/http_request/proc/build_options()
	var/list/options = list()
	if(output_file)
		options["output_filename"] = output_file
		options["body_filename"] = null
	if(timeout_seconds)
		options["timeout_seconds"] = timeout_seconds
	return length(options) ? json_encode(options) : null

/datum/http_request/proc/is_complete()
	if (isnull(id))
		return TRUE

	if (!in_progress)
		return TRUE

	var/r = rustg_http_check_request(id)

	if (r == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE
	else
		_raw_response = r
		in_progress = FALSE
		return TRUE

/// Sleeps until the request finishes or `timeout` deciseconds pass; null on timeout.
/datum/http_request/proc/wait_for_response(timeout)
	RETURN_TYPE(/datum/http_response)
	var/deadline = world.time + timeout
	UNTIL(is_complete() || world.time >= deadline)
	if(in_progress)
		return null
	return into_response()

/datum/http_request/proc/into_response()
	var/datum/http_response/R = new()

	try
		var/list/L = json_decode(_raw_response)
		R.status_code = L["status_code"]
		R.headers = L["headers"]
		R.body = L["body"]
	catch
		R.errored = TRUE
		R.error = _raw_response

	return R

/datum/http_response
	var/status_code
	var/body
	var/list/headers

	var/errored = FALSE
	var/error

/// Helper for `new /datum/http_request` with a return type,
/// so you can do stuff like `http_request(...).begin_async()`
/proc/http_request(...) as /datum/http_request
	RETURN_TYPE(/datum/http_request)
	return new /datum/http_request(arglist(args))
