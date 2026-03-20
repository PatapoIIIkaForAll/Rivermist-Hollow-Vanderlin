/datum/quirk/boon/drunken_brawler
	name = "Drunken Brawler"
	desc = "I fight best with a drink in hand and fire in my belly! Entering a tavern gives me access to a Drunken Rage."
	point_value = -3
	gain_text = span_notice("I fight best with a drink in hand and fire in my belly!")

/datum/quirk/boon/drunken_brawler/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_DRUNKEN_BRAWLER, "[type]")
	RegisterSignal(owner, COMSIG_ENTER_AREA, PROC_REF(on_enter_area))
	RegisterSignal(owner, COMSIG_EXIT_AREA, PROC_REF(on_exit_area))

/datum/quirk/boon/drunken_brawler/on_remove()
	if(!owner)
		return
	owner.remove_status_effect(/datum/status_effect/buff/drunken_rage)
	for(var/datum/action/cooldown/drunken_rage/rage_action in owner.actions)
		qdel(rage_action)
	UnregisterSignal(owner, list(COMSIG_ENTER_AREA, COMSIG_EXIT_AREA))
	REMOVE_TRAIT(owner, TRAIT_DRUNKEN_BRAWLER, "[type]")

/datum/quirk/boon/drunken_brawler/after_job_spawn(datum/job/job)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.clamped_adjust_skillrank(/datum/skill/combat/wrestling, 2, 3, TRUE)
	H.clamped_adjust_skillrank(/datum/skill/combat/unarmed, 2, 3, TRUE)
	H.change_stat(STATKEY_STR, 1)
	H.change_stat(STATKEY_END, 1)

/datum/quirk/boon/drunken_brawler/proc/on_enter_area(mob/living/carbon/human/source, area/entered_area)
	SIGNAL_HANDLER
	if(!is_tavern_area(entered_area))
		return
	if(!HAS_TRAIT(source, TRAIT_DRUNKEN_BRAWLER))
		return
	for(var/datum/action/cooldown/drunken_rage/existing in source.actions)
		return
	var/datum/action/cooldown/drunken_rage/rage_action = new(source)
	rage_action.Grant(source)
	to_chat(source, span_notice("The familiar warmth of the tavern stirs something inside me... I feel my fists itch for a fight!"))

/datum/quirk/boon/drunken_brawler/proc/on_exit_area(mob/living/carbon/human/source, area/exited_area)
	SIGNAL_HANDLER
	if(!is_tavern_area(exited_area))
		return
	var/area/new_area = get_area(source)
	if(is_tavern_area(new_area))
		return
	var/had_rage = source.has_status_effect(/datum/status_effect/buff/drunken_rage)
	source.remove_status_effect(/datum/status_effect/buff/drunken_rage)
	for(var/datum/action/cooldown/drunken_rage/rage_action in source.actions)
		qdel(rage_action)
	if(had_rage)
		to_chat(source, span_boldwarning("The drunken power fades as I leave the tavern... Exhaustion washes over me..."))
		addtimer(CALLBACK(source, TYPE_PROC_REF(/mob/living, Sleeping), 600), rand(30, 60) SECONDS)
