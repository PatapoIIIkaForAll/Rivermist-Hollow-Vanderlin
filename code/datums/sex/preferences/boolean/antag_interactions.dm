// Antag-interaction preferences: whether lewd-antagonist mechanics may target
// this character. Opted-out characters read as "warded souls" in-game — they
// are hard targets, not excluded players. (spec §8)

/datum/erp_preference/boolean/lust_magic_targetable
	name = "Lust Magic Targetable"
	description = "Whether lust magic (succubus and similar lewd antagonists) can target you"
	default_value = TRUE
	category = "Antagonists"

/datum/erp_preference/boolean/enthrallable
	name = "Can Be Enthralled"
	description = "Whether lewd antagonists can bind your will to theirs"
	default_value = TRUE
	category = "Antagonists"

/datum/erp_preference/boolean/antag_pregnancy
	name = "Antagonist Pregnancy"
	description = "Whether antagonists, such as a gnoll pack holding you captive, can impregnate you through their rites"
	default_value = TRUE
	category = "Antagonists"

/datum/erp_preference/boolean/fatal_drain_ok
	name = "Draining May Kill Me"
	description = "Whether lewd antagonist draining effects are allowed to be lethal (fatal outcomes are always explicit opt-in)"
	default_value = FALSE
	category = "Antagonists"
