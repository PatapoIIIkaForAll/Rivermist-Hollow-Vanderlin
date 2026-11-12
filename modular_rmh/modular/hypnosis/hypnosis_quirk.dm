// Hypnosis quirks: each grants a hypnosis spell and a custom examine line.

/datum/quirk/positive/hypnotic
	abstract_type = /datum/quirk/positive/hypnotic
	preview_render = FALSE
	incompatible_quirks = list(/datum/quirk/positive/hypnotic/gaze, /datum/quirk/positive/hypnotic/presence)
	var/spell_type = /datum/action/cooldown/spell/hypnosis
	var/examine_section = EXAMINE_SECT_FACE
	var/default_examine_text = "Their eyes are enticing to gaze into."

/datum/quirk/positive/hypnotic/gaze
	name = "Hypnotic Gaze"
	desc = "My eyes can hold a mind still. After ten seconds of eye contact, the next words someone hears from me settle in as a suggestion or a trigger phrase."
	desc_hint = "Needs Hypnosis enabled in ERP preferences, for both of you. Range two tiles; both must stand still with eyes uncovered. A trance lasts up to an hour and a half. Strong-willed people can refuse it."
	point_value = -5
	extra_customization_fields = list(
		list("key" = "examine_text", "label" = "Examine Text", "type" = QUIRK_TEXT, "default" = "Their eyes are enticing to gaze into.", "placeholder" = "Shown when others can see your eyes", "max_length" = HYPNOSIS_EXAMINE_MAX_LENGTH),
		list("key" = "examine_style", "label" = "Examine Style", "type" = QUIRK_SELECT, "default" = "Hypnotic", "options" = list("Hypnotic", "Violet", "Rose", "Velvet", "Gold", "Moss", "Crimson")),
	)

/datum/quirk/positive/hypnotic/presence
	name = "Hypnotic Presence"
	desc = "Something about me draws minds in. After ten seconds of my full attention, no eye contact needed, the next words someone hears from me settle in as a suggestion or a trigger phrase."
	desc_hint = "Needs Hypnosis enabled in ERP preferences, for both of you. Range two tiles; both must stand still. A trance lasts up to an hour and a half. Strong-willed people can refuse it."
	point_value = -6
	spell_type = /datum/action/cooldown/spell/hypnosis/presence
	examine_section = EXAMINE_SECT_BODY
	default_examine_text = "There is something strangely compelling about their presence."
	extra_customization_fields = list(
		list("key" = "examine_text", "label" = "Examine Text", "type" = QUIRK_TEXT, "default" = "There is something strangely compelling about their presence.", "placeholder" = "Shown when others examine you", "max_length" = HYPNOSIS_EXAMINE_MAX_LENGTH),
		list("key" = "examine_style", "label" = "Examine Style", "type" = QUIRK_SELECT, "default" = "Hypnotic", "options" = list("Hypnotic", "Violet", "Rose", "Velvet", "Gold", "Moss", "Crimson")),
	)

/datum/quirk/positive/hypnotic/on_spawn()
	. = ..()
	owner?.add_spell(spell_type)

/datum/quirk/positive/hypnotic/on_remove()
	owner?.remove_spell(spell_type)
	return ..()

/datum/quirk/positive/hypnotic/proc/get_examine_line()
	var/text = hypnosis_plaintext(get_extra_value("examine_text", default_examine_text), HYPNOSIS_EXAMINE_MAX_LENGTH)
	if(!length(text))
		text = default_examine_text
	var/style = get_extra_value("examine_style", "Hypnotic")
	if(!(style in hypnosis_styles()))
		style = "Hypnotic"
	return hypnosis_format(text, style)

/datum/quirk/positive/hypnotic/on_examined(mob/user, list/P, list/examine_contents)
	if(user == owner || !isliving(user) || !user.allows_hypnosis())
		return
	if(!can_show_examine(user))
		return
	LAZYADDASSOCLIST(examine_contents, examine_section, get_examine_line())

/datum/quirk/positive/hypnotic/proc/can_show_examine(mob/living/viewer)
	return TRUE

/datum/quirk/positive/hypnotic/gaze/can_show_examine(mob/living/viewer)
	return owner?.hypnosis_eyes_visible() && viewer.hypnosis_can_see()
