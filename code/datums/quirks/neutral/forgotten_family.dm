/datum/quirk/neutral/forgotten_family
	name = "Forgotten Family"
	desc = "Some faces stir half-forgotten family memories. I can mutually remember a nearby person with this peculiarity as close family."
	desc_hint = "Both players must consent. Established characters in different houses cannot join their family trees this way."
	random_exempt = TRUE
	preview_render = FALSE
	var/datum/action/remember_family/family_action
	var/remember_request_pending = FALSE

/datum/quirk/neutral/forgotten_family/on_spawn()
	. = ..()
	if(!ishuman(owner))
		return
	family_action = new(src)
	family_action.Grant(owner)

/datum/quirk/neutral/forgotten_family/on_remove()
	remember_request_pending = FALSE
	QDEL_NULL(family_action)
	return ..()

/datum/action/remember_family
	name = "Remember Family"
	desc = "Ask a nearby person with Forgotten Family to establish a mutual family memory."
	button_icon_state = "love"
	check_flags = AB_CHECK_CONSCIOUS
	var/next_request_at = 0

/datum/action/remember_family/Trigger(trigger_flags)
	if(!..())
		return FALSE

	var/datum/quirk/neutral/forgotten_family/source_quirk = target
	var/mob/living/carbon/human/rememberer = owner
	if(!istype(source_quirk) || !istype(rememberer) || source_quirk.remember_request_pending)
		return FALSE
	if(world.time < next_request_at)
		to_chat(rememberer, span_warning("My thoughts are still settling after the last memory."))
		return FALSE

	source_quirk.remember_request_pending = TRUE
	var/list/candidates = list()
	for(var/mob/living/carbon/human/candidate in view(2, rememberer))
		if(candidate == rememberer || !CanOfferMemory(rememberer, candidate, source_quirk))
			continue
		candidates += candidate

	if(!length(candidates))
		to_chat(rememberer, span_warning("No one nearby can share this family memory with me."))
		ClearPending(source_quirk)
		return TRUE

	var/mob/living/carbon/human/relative = tgui_input_list(rememberer, "Whose face brings back a family memory?", "Remember Family", candidates, timeout = 30 SECONDS)
	if(!relative || !CanOfferMemory(rememberer, relative, source_quirk))
		ClearPending(source_quirk)
		return TRUE

	var/list/relation_choices = list(
		"They are my parent",
		"They are my child",
		"They are my sibling",
		"They are my spouse",
	)
	var/relation_choice = tgui_input_list(rememberer, "How is [relative.real_name] related to me?", "Remember Family", relation_choices, timeout = 30 SECONDS)
	if(!relation_choice || !CanOfferMemory(rememberer, relative, source_quirk))
		ClearPending(source_quirk)
		return TRUE

	var/relation_type
	var/relation_name
	var/inverse_relation_name
	switch(relation_choice)
		if("They are my parent")
			relation_type = FAMILY_MEMBER_PARENT
			relation_name = "parent"
			inverse_relation_name = "child"
		if("They are my child")
			relation_type = FAMILY_MEMBER_CHILD
			relation_name = "child"
			inverse_relation_name = "parent"
		if("They are my sibling")
			relation_type = FAMILY_MEMBER_SIBLING
			relation_name = "sibling"
			inverse_relation_name = "sibling"
		if("They are my spouse")
			relation_type = FAMILY_MEMBER_SPOUSE
			relation_name = "spouse"
			inverse_relation_name = "spouse"
	if(!relation_type)
		ClearPending(source_quirk)
		return TRUE

	var/family_error = SSfamilytree.GetRememberFamilyError(rememberer, relative, relation_type)
	if(family_error)
		to_chat(rememberer, span_warning(family_error))
		ClearPending(source_quirk)
		return TRUE

	var/datum/quirk/neutral/forgotten_family/relative_quirk = relative.get_quirk(/datum/quirk/neutral/forgotten_family)
	if(!relative_quirk || relative_quirk.remember_request_pending)
		to_chat(rememberer, span_warning("[relative.real_name] is already occupied by another memory."))
		ClearPending(source_quirk)
		return TRUE
	relative_quirk.remember_request_pending = TRUE
	next_request_at = world.time + 30 SECONDS

	var/answer = tgui_alert(relative, "I suddenly remember [rememberer.real_name] being my [inverse_relation_name]. Could it be true?", "A Family Memory", list("Yes", "No"), timeout = 30 SECONDS)
	ClearPending(source_quirk, relative_quirk)
	if(answer != "Yes")
		if(CanOfferMemory(rememberer, relative, source_quirk, ignore_pending = TRUE))
			to_chat(rememberer, span_warning("[relative.real_name] does not share that memory."))
			to_chat(relative, span_notice("I dismiss the uncertain memory."))
		return TRUE

	if(!CanOfferMemory(rememberer, relative, source_quirk, ignore_pending = TRUE))
		if(!QDELETED(rememberer))
			to_chat(rememberer, span_warning("Too much changed while the memory surfaced; it slips away."))
		if(!QDELETED(relative))
			to_chat(relative, span_warning("Too much changed while the memory surfaced; it slips away."))
		return TRUE

	family_error = SSfamilytree.GetRememberFamilyError(rememberer, relative, relation_type)
	if(family_error || !SSfamilytree.RememberFamilyRelation(rememberer, relative, relation_type))
		var/failure_text = family_error || "The memory cannot settle into your family histories."
		to_chat(rememberer, span_warning(failure_text))
		to_chat(relative, span_warning(failure_text))
		return TRUE

	rememberer.mind.store_memory("[relative.real_name] is my [relation_name].")
	relative.mind.store_memory("[rememberer.real_name] is my [inverse_relation_name].")
	to_chat(rememberer, span_love("The memory becomes clear: [relative.real_name] is my [relation_name]."))
	to_chat(relative, span_love("The memory becomes clear: [rememberer.real_name] is my [inverse_relation_name]."))
	log_game("[key_name(rememberer)] and [key_name(relative)] mutually established a [relation_type] family memory.")
	return TRUE

/datum/action/remember_family/proc/CanOfferMemory(mob/living/carbon/human/rememberer, mob/living/carbon/human/relative, datum/quirk/neutral/forgotten_family/source_quirk, ignore_pending = FALSE)
	if(QDELETED(rememberer) || QDELETED(relative) || QDELETED(source_quirk))
		return FALSE
	if(owner != rememberer || target != source_quirk || source_quirk.owner != rememberer)
		return FALSE
	if(!rememberer.client || !relative.client || !rememberer.mind || !relative.mind)
		return FALSE
	if(rememberer.stat != CONSCIOUS || relative.stat != CONSCIOUS)
		return FALSE
	if(rememberer.z != relative.z || get_dist(rememberer, relative) > 2)
		return FALSE
	var/datum/quirk/neutral/forgotten_family/relative_quirk = relative.get_quirk(/datum/quirk/neutral/forgotten_family)
	if(!relative_quirk || (!ignore_pending && relative_quirk.remember_request_pending))
		return FALSE
	return TRUE

/datum/action/remember_family/proc/ClearPending(datum/quirk/neutral/forgotten_family/source_quirk, datum/quirk/neutral/forgotten_family/relative_quirk)
	if(!QDELETED(source_quirk))
		source_quirk.remember_request_pending = FALSE
	if(!QDELETED(relative_quirk))
		relative_quirk.remember_request_pending = FALSE
