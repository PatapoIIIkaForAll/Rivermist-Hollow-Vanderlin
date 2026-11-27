/// Walking into a climbable wall, onto a foothold or off an open edge starts a climb.
/datum/preference/toggle/auto_climb
	savefile_key = "auto_climb"
	savefile_identifier = PREF_PLAYER
	toggles_menu_category = "Gameplay"
	toggles_menu_name = "Auto-climb"
	toggles_menu_desc = "With an empty hand, walking or sneaking into a climbable wall or onto a foothold climbs it, and walking off an edge climbs down instead of falling. Not while running or in combat mode."
	category = "gameplay"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/// After a fall, a knockdown or a yield, keep trying to stand until up; off leaves you lying.
/datum/preference/toggle/auto_stand
	savefile_key = "auto_stand"
	savefile_identifier = PREF_PLAYER
	toggles_menu_category = "Gameplay"
	toggles_menu_name = "Auto-stand"
	toggles_menu_desc = "Stand up by yourself when a fall, a knockdown or a yield ends, trying again until you are up. Off: you stay lying until you press stand."
	category = "gameplay"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/// Shows the sparkle on gold-quality and better items.
/datum/preference/toggle/quality_glint
	savefile_key = "quality_glint"
	savefile_identifier = PREF_PLAYER
	toggles_menu_category = "Display"
	toggles_menu_name = "Quality glint"
	toggles_menu_desc = "Show the sparkle on gold-quality and better items. Polished shoes, clean plates and dried clothes still sparkle."
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/datum/preference/toggle/quality_glint/apply_to_client_updated(client/player, value)
	. = ..()
	update_quality_glint_plane(player?.mob)

/// Eating or drinking by yourself repeats bite after bite until you are sated, move, act or run out.
/datum/preference/toggle/auto_consume
	savefile_key = "auto_consume"
	savefile_identifier = PREF_PLAYER
	toggles_menu_category = "Gameplay"
	toggles_menu_name = "Non-stop eating and drinking"
	toggles_menu_desc = "Keep drinking or eating by yourself until you are no longer thirsty or hungry, you move or do something else, or it runs out. Feeding someone else stays one gulp."
	category = "gameplay"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE
