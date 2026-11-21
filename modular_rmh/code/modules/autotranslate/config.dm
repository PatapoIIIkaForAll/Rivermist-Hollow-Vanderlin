/// "mtranserver" or "libretranslate". Empty keeps the feature off.
/datum/config_entry/string/translate_provider

/datum/config_entry/string/translate_http_url

/datum/config_entry/string/translate_http_url/ValidateAndSet(str_val)
	if(!findtext(str_val, GLOB.is_http_protocol))
		return FALSE
	return ..()

/datum/config_entry/string/translate_http_token
	protection = CONFIG_ENTRY_HIDDEN | CONFIG_ENTRY_LOCKED

/datum/config_entry/number/translate_http_timeout_seconds
	config_entry_value = 5
	min_val = 1
	max_val = 30

/// Longer lines stay untranslated.
/datum/config_entry/number/translate_max_chars
	config_entry_value = 2000
	min_val = 1

/// Requests in flight at one time. Each one holds a rust-g thread.
/datum/config_entry/number/translate_max_requests
	config_entry_value = 16
	min_val = 1
	max_val = 64

/datum/config_entry/number/translate_cache_entries
	config_entry_value = 5000
	min_val = 0
