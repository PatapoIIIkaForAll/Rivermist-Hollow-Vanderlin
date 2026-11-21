/datum/erp_preference/boolean/allow_gender_bender
	name = "Allow Gender Bender"
	description = "Whether you're allowing others to change your sex using magic and other means"
	default_value = FALSE
	category = "General"

/datum/erp_preference/boolean/allow_horny_leeches
	name = "Horny Leeches"
	description = "Enables the horny leeches interactions"
	default_value = FALSE
	category = "General"

/datum/erp_preference/boolean/allow_forced_lactation
	name = "Forced Lactation"
	description = "If your breasts can be forced to lactate through potions or other means"
	default_value = TRUE
	category = "General"

/datum/erp_preference/boolean/allow_fluid_potions
	name = "Fluid Potions"
	description = "If potions can boost, reduce, stop or swap the fluids your body makes"
	default_value = TRUE
	category = "General"

/datum/erp_preference/boolean/allow_heat_cycles
	name = "Heat Cycles"
	description = "If your species or a curse can put you into heat or rut. The Heat Cycles quirk works either way"
	default_value = TRUE
	category = "General"

/datum/erp_preference/boolean/allow_belly_inflation
	name = "Belly Inflation"
	description = "If fluids in your vagina or anus can visibly inflate your belly"
	default_value = TRUE
	category = "General"

/datum/erp_preference/boolean/always_show_nsfw_flavor
	name = "Always show nsfw flavor"
	description = "If you want your nsfw flavor to be shown even when clothed"
	default_value = FALSE
	category = "General"

/datum/erp_preference/boolean/allow_player_erp_when_disconnected
	name = "Allow ERP While Disconnected"
	description = "If other players can start and continue sex interactions with your character while you are disconnected"
	default_value = FALSE
	category = "General"

/datum/erp_preference/boolean/allow_mob_oviposition
	name = "Allow mob oviposition"
	description = "If you want mobs to perform oviposition when possible"
	default_value = TRUE
	category = "Mobs"

/datum/erp_preference/boolean/allow_inside_hatching
	name = "Hatchlings may hatch inside me"
	description = "If eggs whose kind can hatch inside their host may do so in you; otherwise they are laid first"
	default_value = TRUE
	category = "Mobs"

/datum/erp_preference/boolean/allow_mob_breeding
	name = "Allow mob breeding"
	description = "If you want mobs to breed you when possible"
	default_value = FALSE
	category = "Mobs"

/datum/erp_preference/boolean/nonmatching_horny_mobs_are_nonlethal
	name = "Out-of-scope horny mobs disarm"
	description = "If enabled, horny mobs outside your enabled mob prefs will try to disarm or subdue you instead of damaging you."
	default_value = TRUE
	category = "Mobs"

/datum/erp_preference/boolean/allow_reach_under_armor
	name = "Reach Under My Armor"
	description = "If players, you included, can touch and use what your armor covers. Mobs always strip armor first"
	default_value = FALSE
	category = "General"

// Withdrawing or giving this consent must work mid-round, so the spawn lock never applies.
/datum/erp_preference/boolean/allow_reach_under_armor/get_edit_lock_reason(mob/user, datum/preferences/prefs)
	return null

/datum/erp_preference/boolean/panel_status_follows_examine
	name = "Status Follows Examine"
	description = "On: the panel's status lines list what examine shows. Off: they use the older rule, which only reads body coverage and underwear"
	default_value = TRUE
	category = "General"

// A display choice for the viewer, so it can change at any time.
/datum/erp_preference/boolean/panel_status_follows_examine/get_edit_lock_reason(mob/user, datum/preferences/prefs)
	return null

/datum/erp_preference/boolean/auto_clench
	name = "Auto-Clench In Combat Mode"
	description = "Automatically resist sex actions performed on you while combat mode is on. Costs stamina each attempt."
	default_value = FALSE
	category = "General"
