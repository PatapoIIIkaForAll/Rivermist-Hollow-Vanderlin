// Server switches and settings for kink content, set in config/kinks_content.txt.

/// Off removes watersports: the Bladder quirk, the Watersports ERP preference and its actions, squirting and Holy Urine.
/datum/config_entry/flag/watersports_enabled
	config_entry_value = TRUE

/// Bladder units added per point of hydration a drink gives.
/datum/config_entry/number/bladder_fill_rate
	config_entry_value = 0.03
	integer = FALSE
	min_val = 0
	max_val = 1
