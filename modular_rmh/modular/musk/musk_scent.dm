/datum/component/musk/proc/set_scent(quality, list/notes, hidden, conceives)
	scent_quality = quality
	scent_notes = notes
	hidden_under_clothes = hidden
	conceives_from_devoted = conceives

/datum/component/musk/proc/get_scent_for(mob/living/smeller)
	if(scent_quality != MUSK_SCENT_FOUL)
		return scent_quality
	return smeller.get_scent_bond_level(parent) >= MUSK_BOND_OBEDIENCE ? MUSK_SCENT_PLEASANT : MUSK_SCENT_FOUL

/datum/component/musk/proc/is_hidden()
	var/mob/living/carbon/human/owner = parent
	if(!hidden_under_clothes || !owner.is_clothed_over(CHEST) || !owner.is_clothed_over(GROIN))
		return FALSE
	return !sweat.get_stacks(MUSK_ZONE_FEET) || owner.is_clothed_over(FEET)

/datum/component/musk/proc/is_smelling()
	var/mob/living/carbon/human/owner = parent
	var/datum/status_effect/musk/smell = owner.has_status_effect(/datum/status_effect/musk)
	return smell && !smell.hidden

/mob/living/carbon/human/proc/is_clothed_over(body_flags)
	for(var/obj/item/clothing/worn in get_equipped_items())
		if(worn.body_parts_covered & body_flags)
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/toggle_hidden_scent()
	set name = "Hide My Scent"
	set category = "IC"
	set desc = "Keep my scent under my clothes, or let it out."

	var/datum/component/musk/musk = get_musk()
	if(!musk)
		return
	musk.hidden_under_clothes = !musk.hidden_under_clothes
	var/datum/status_effect/musk/smell = has_status_effect(/datum/status_effect/musk)
	smell?.update_hiding()
	to_chat(src, span_notice(musk_hiding_text(src, musk.hidden_under_clothes, musk.is_hidden())))

/mob/living/carbon/human/proc/feel_scent_of(mob/living/carbon/human/source)
	switch(source.get_musk()?.get_scent_for(src))
		if(MUSK_SCENT_PLEASANT)
			keep_mood(/datum/stress_event/musk_pleasant)
		if(MUSK_SCENT_FOUL)
			keep_mood(/datum/stress_event/musk_foul)

/mob/living/carbon/human/proc/keep_mood(mood_type)
	var/datum/stress_event/mood = has_stress_type(mood_type)
	if(!mood)
		add_stress(mood_type)
		return
	mood.timer = world.time + initial(mood.timer)

/datum/stress_event/musk_pleasant
	stress_change = -2
	desc = span_green("Someone here smells wonderful.")
	timer = 5 MINUTES

/datum/stress_event/musk_pleasant/get_desc(mob/living/user)
	return span_green(musk_localized(user, "Someone here smells wonderful.", "От кого-то здесь чудесно пахнет."))

/datum/stress_event/musk_foul
	stress_change = 2
	desc = span_red("Someone here reeks.")
	timer = 5 MINUTES

/datum/stress_event/musk_foul/get_desc(mob/living/user)
	return span_red(musk_localized(user, "Someone here reeks.", "От кого-то здесь разит."))
