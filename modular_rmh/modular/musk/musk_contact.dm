/datum/status_effect/musk_contact
	id = "musk_contact"
	duration = MUSK_CONTACT_DURATION
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	var/list/open_lines = list()

/datum/status_effect/musk_contact/proc/allows_line(line)
	if(isnull(open_lines[line]))
		open_lines[line] = prob(MUSK_CONTACT_LINE_CHANCE)
	return open_lines[line]

/datum/status_effect/musk_contact/proc/claim_line(line)
	. = allows_line(line)
	open_lines[line] = FALSE

/mob/living/carbon/human/proc/get_musk_contact()
	RETURN_TYPE(/datum/status_effect/musk_contact)
	apply_status_effect(/datum/status_effect/musk_contact)
	return has_status_effect(/datum/status_effect/musk_contact)

/mob/living/carbon/human/proc/tell_once_per_contact(line, message)
	if(message && get_musk_contact()?.claim_line(line))
		to_chat(src, span_love(message))

/mob/living/carbon/human/proc/touch_musk(mob/living/carbon/human/source, gain_kind)
	if(!is_musk_susceptible())
		return
	get_musk_contact()
	if(!source)
		return
	deepen_scent_bond(source, gain_kind)
	if(can_smell_musk())
		feel_scent_of(source)
