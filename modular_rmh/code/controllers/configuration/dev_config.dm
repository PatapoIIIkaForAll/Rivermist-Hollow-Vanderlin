/datum/config_entry/flag/autostart

/datum/config_entry/number/minimum_flavor_text
	config_entry_value = 0
	integer = TRUE
	min_val = 0

/datum/config_entry/number/minimum_ooc_notes
	config_entry_value = 0
	integer = TRUE
	min_val = 0

/datum/controller/subsystem/ticker/Initialize(timeofday)
	if(CONFIG_GET(flag/autostart))
		start_immediately = TRUE
	return ..()
