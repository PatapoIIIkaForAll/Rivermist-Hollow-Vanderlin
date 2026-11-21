// Moon calendar: phases from the dae of the week, full moon effects and the Read the Moon viewer.

/// Tonight's moon phase; the night of the seventh dae is full, and the uncounted first daes read as waxing.
/proc/get_moon_phase()
	switch(GLOB.dayspassed)
		if(1)
			return WW_MOON_WANING
		if(2 to 3)
			return WW_MOON_DARK
		if(6)
			return WW_MOON_GIBBOUS
		if(WW_MOON_CYCLE_NIGHTS)
			return WW_MOON_FULL
	return WW_MOON_WAXING

/// Nights until the full moon; zero when tonight's moon is full.
/proc/nights_until_full_moon()
	return WW_MOON_CYCLE_NIGHTS - clamp(GLOB.dayspassed, 0, WW_MOON_CYCLE_NIGHTS)

/proc/is_full_moon_night()
	return GLOB.tod == "night" && get_moon_phase() == WW_MOON_FULL

/// Multiplier for werewolf rage gain; the full moon overhead doubles it.
/proc/get_moon_rage_multiplier()
	return is_full_moon_night() ? WW_FULL_MOON_RAGE_MULTIPLIER : 1

/proc/get_moon_phase_name(phase = get_moon_phase())
	switch(phase)
		if(WW_MOON_WANING)
			return "waning moon"
		if(WW_MOON_DARK)
			return "dark moon"
		if(WW_MOON_GIBBOUS)
			return "gibbous moon"
		if(WW_MOON_FULL)
			return "full moon"
	return "waxing moon"

/proc/get_moon_phase_omen(phase = get_moon_phase())
	switch(phase)
		if(WW_MOON_WANING)
			return "Noc's eye closes, sated by the hunt."
		if(WW_MOON_DARK)
			return "Noc's eye is shut dark, and the beast sleeps light."
		if(WW_MOON_GIBBOUS)
			return "The moon hangs fat and nearly whole. My blood stirs."
		if(WW_MOON_FULL)
			return "The moon is whole, and the beast will not be denied."
	return "The moon swells a little more each night."

/// Name of the given dae of the week, or null before the first dawn.
/proc/get_week_dae_name(day = GLOB.dayspassed)
	var/static/list/dae_names = list("Moon's dae", "Tiw's dae", "Wedding's dae", "Thule's dae", "Freyja's dae", "Saturn's dae", "Sun's dae")
	if(!isnum(day) || day < 1 || day > length(dae_names))
		return null
	return dae_names[day]

/datum/antagonist/werewolf
	/// Read the Moon viewer, bound to the mind so it follows every body change.
	var/datum/action/innate/werewolf_read_moon/moon_reading_action

/datum/antagonist/werewolf/proc/grant_moon_reading()
	var/mob/living/current_body = owner?.current
	if(!current_body)
		return
	if(!moon_reading_action)
		moon_reading_action = new(owner)
	moon_reading_action.Grant(current_body)

/datum/antagonist/werewolf/proc/remove_moon_reading()
	QDEL_NULL(moon_reading_action)

/// The full moon waives the change's cooldown and drags a human-skinned werewolf out at once.
/datum/antagonist/werewolf/proc/handle_full_moonrise(mob/living/carbon/human/current_body)
	var/datum/action/cooldown/spell/undirected/werewolf_form/transformation_action = get_transformation_action()
	transformation_action?.StartCooldown(0)
	if(transformed)
		to_chat(current_body, span_userdanger("The full moon rises! My rage burns twice as hot beneath it."))
		return
	forced_transformation_pending = TRUE
	to_chat(current_body, span_userdanger("The full moon rises, and the beast will not be denied!"))
	process_pending_forced_transformation()

/// Nightfall line for an ordinary night; restless_nights above zero means the beast was denied.
/datum/antagonist/werewolf/proc/announce_moonrise(mob/living/carbon/human/current_body, restless_nights = 0)
	var/nights_left = nights_until_full_moon()
	var/countdown = "The full moon rises in [nights_left] night[werewolf_plural_suffix(nights_left)]."
	switch(restless_nights)
		if(0)
			to_chat(current_body, span_notice("The [get_moon_phase_name()] rises. [countdown]"))
		if(1)
			to_chat(current_body, span_warning("A night passes without letting the beast out. It grows restless. [countdown]"))
		if(2)
			to_chat(current_body, span_userdanger("Two nights denied. The beast claws at my mind. [countdown]"))
		else
			to_chat(current_body, span_userdanger("Night after night denied, the beast is furious. [countdown] It will not be denied then."))

/datum/antagonist/werewolf/proc/get_moon_reading()
	var/list/lines = list()
	var/dae_name = get_week_dae_name()
	lines += dae_name ? "It is [dae_name]." : "The daes have not yet turned; I have lost count of them."
	var/phase = get_moon_phase()
	lines += "Tonight's moon is the [get_moon_phase_name(phase)]. [get_moon_phase_omen(phase)]"
	var/nights_left = nights_until_full_moon()
	if(is_full_moon_night())
		lines += "The full moon is overhead. My change costs nothing tonight."
	else if(!nights_left)
		lines += "The full moon rises tonight."
	else
		lines += "The full moon rises in [nights_left] night[werewolf_plural_suffix(nights_left)]."
	var/form_line = get_moon_reading_form_line()
	if(form_line)
		lines += form_line
	return examine_block(span_notice(jointext(lines, "\n")))

/datum/antagonist/werewolf/proc/get_moon_reading_form_line()
	var/cooldown_remaining = get_transformation_cooldown_remaining()
	if(cooldown_remaining > 0)
		return "My form is still settling. I can change again in [DisplayTimeText(cooldown_remaining)]."
	return "The beast is ready to change."

/datum/action/innate/werewolf_read_moon
	name = "Read the Moon"
	desc = "Look to the sky and feel where the moon stands in its cycle."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "noc_sight"

/datum/action/innate/werewolf_read_moon/Activate()
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(owner)
	if(!wolf)
		return
	to_chat(owner, wolf.get_moon_reading())
