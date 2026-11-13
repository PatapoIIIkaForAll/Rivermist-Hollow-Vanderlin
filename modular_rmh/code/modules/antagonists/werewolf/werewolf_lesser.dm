// Moonkissed - the lesser werewolf. Carries a shallow strain of the mooncurse:
// no beast form, no lair, no contracts, no rage. Just the moon's kiss and the pack.

/datum/antagonist/werewolf/lesser
	/// How many times the moonkissed form has been embraced, for the pack objectives.
	var/times_shifted = 0
	/// Mind of the elder whose curse made this pup.
	var/datum/weakref/elder_mind_ref
	/// Set by a shift beside the elder; the cast's after-hook then clears the cooldown.
	var/waive_next_shift_cooldown = FALSE

/datum/antagonist/werewolf/lesser/grant_werewolf_powers()
	owner.current.add_spell(/datum/action/cooldown/spell/undirected/partial_transformation/moonkissed, source = owner)
	grant_moon_reading()
	RegisterSignal(owner.current, COMSIG_MOB_PARTIAL_SHIFTED, PROC_REF(on_moonkissed_shift))
	RegisterSignal(owner.current, COMSIG_MOB_AFTER_SPELL_CAST, PROC_REF(on_spell_cast))

/datum/antagonist/werewolf/lesser/remove_werewolf_powers()
	remove_moon_reading()
	var/mob/living/current_mob = owner?.current
	if(!current_mob)
		return
	UnregisterSignal(current_mob, list(COMSIG_MOB_PARTIAL_SHIFTED, COMSIG_MOB_AFTER_SPELL_CAST))
	// Removing the status effect restores the original ears/tail/genitals.
	current_mob.remove_status_effect(/datum/status_effect/partial_transformation)
	current_mob.remove_spell(/datum/action/cooldown/spell/undirected/partial_transformation/moonkissed)

/datum/antagonist/werewolf/lesser/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(old_body)
		UnregisterSignal(old_body, list(COMSIG_MOB_PARTIAL_SHIFTED, COMSIG_MOB_AFTER_SPELL_CAST))
	if(new_body)
		RegisterSignal(new_body, COMSIG_MOB_PARTIAL_SHIFTED, PROC_REF(on_moonkissed_shift), override = TRUE)
		RegisterSignal(new_body, COMSIG_MOB_AFTER_SPELL_CAST, PROC_REF(on_spell_cast), override = TRUE)

/datum/antagonist/werewolf/lesser/proc/on_moonkissed_shift(datum/source, datum/partial_transformation_kit/kit)
	SIGNAL_HANDLER

	times_shifted++
	refresh_werewolf_objectives()
	waive_next_shift_cooldown = is_near_living_elder(WW_PUP_ELDER_RANGE)

/// The shift spell starts its cooldown after the shifted signal, so the waiver waits for the cast to finish.
/datum/antagonist/werewolf/lesser/proc/on_spell_cast(mob/living/source, datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER

	if(!waive_next_shift_cooldown || !istype(spell, /datum/action/cooldown/spell/undirected/partial_transformation/moonkissed))
		return
	waive_next_shift_cooldown = FALSE
	INVOKE_ASYNC(spell, TYPE_PROC_REF(/datum/action/cooldown, StartCooldown), 0)
	to_chat(source, span_notice("My elder is near; the moon's kiss comes and goes freely."))

/datum/antagonist/werewolf/lesser/on_life(mob/user)
	. = ..()
	if(is_full_moon_night())
		check_elder_under_full_moon(user)

/datum/antagonist/werewolf/lesser/proc/check_elder_under_full_moon(mob/living/user)
	if(!isliving(user) || user.stat == DEAD)
		return
	for(var/datum/objective/werewolf/find_elder/elder_objective in objectives)
		if(elder_objective.completed)
			continue
		if(!is_near_living_elder(1))
			return
		elder_objective.completed = TRUE
		to_chat(user, span_greentext("I stand beside my elder beneath the full moon. The pack is whole."))

/datum/antagonist/werewolf/lesser/proc/get_elder_mind()
	RETURN_TYPE(/datum/mind)
	return elder_mind_ref?.resolve()

/// The elder's werewolf datum, or null once the elder is gone or cured.
/datum/antagonist/werewolf/lesser/proc/get_elder_antag()
	RETURN_TYPE(/datum/antagonist/werewolf)
	var/datum/mind/elder_mind = get_elder_mind()
	return elder_mind?.has_antag_datum(/datum/antagonist/werewolf)

/// Binds this pup to the elder whose curse made it; the first elder sticks.
/datum/antagonist/werewolf/lesser/proc/set_elder(datum/antagonist/werewolf/elder)
	if(!elder?.owner || elder == src || get_elder_mind())
		return FALSE
	elder_mind_ref = WEAKREF(elder.owner)
	var/datum/objective/werewolf/find_elder/elder_objective = new
	elder_objective.owner = owner
	add_objective(elder_objective)
	to_chat(owner.current, span_notice("[elder.wolfname] made me. Under the full moon I must stand beside my elder."))
	return TRUE

/datum/antagonist/werewolf/lesser/proc/is_near_living_elder(range)
	var/datum/antagonist/werewolf/elder = get_elder_antag()
	if(!elder || !considered_alive(elder.owner))
		return FALSE
	var/turf/pup_turf = get_turf(owner?.current)
	var/turf/elder_turf = get_turf(elder.owner.current)
	if(!pup_turf || !elder_turf || pup_turf.z != elder_turf.z)
		return FALSE
	return get_dist(pup_turf, elder_turf) <= range

/datum/antagonist/werewolf/lesser/get_howl_name()
	var/datum/antagonist/werewolf/elder = get_elder_antag()
	if(!elder)
		return ..()
	return "[wolfname], pup of [elder.wolfname]"

/datum/antagonist/werewolf/lesser/get_moon_reading_form_line()
	var/datum/antagonist/werewolf/elder = get_elder_antag()
	if(!elder)
		return "No elder answers my howl."
	if(!considered_alive(elder.owner))
		return "My elder, [elder.wolfname], has fallen."
	if(is_near_living_elder(WW_PUP_ELDER_RANGE))
		return "My elder, [elder.wolfname], is near. The moon's kiss comes freely."
	return "My elder, [elder.wolfname], still runs."

/// Lineage line for an examiner this wolf made, or null.
/datum/antagonist/werewolf/proc/get_lineage_examine_line(mob/examiner)
	var/datum/antagonist/werewolf/lesser/examiner_pup = examiner?.mind?.has_antag_datum(/datum/antagonist/werewolf/lesser)
	if(examiner_pup && examiner_pup.get_elder_mind() == owner)
		return span_boldnotice("The one who made me.")
	return null

/datum/antagonist/werewolf/lesser/get_lineage_examine_line(mob/examiner)
	. = ..()
	if(!. && examiner?.mind && get_elder_mind() == examiner.mind)
		return span_boldnotice("My pup.")

/// Minds of the living pups this elder made.
/datum/antagonist/werewolf/proc/get_living_pup_minds()
	var/list/living_pups = list()
	for(var/datum/mind/pup_mind as anything in converted_player_minds)
		var/datum/antagonist/werewolf/lesser/pup = pup_mind?.has_antag_datum(/datum/antagonist/werewolf/lesser)
		if(pup?.get_elder_mind() != owner)
			continue
		if(considered_alive(pup_mind))
			living_pups += pup_mind
	return living_pups

/// Rage decay per life tick that living pups shave off the beast form's decay.
/datum/antagonist/werewolf/proc/get_pup_rage_decay_bonus()
	return length(get_living_pup_minds())

/datum/antagonist/werewolf/lesser/forge_werewolf_objectives()
	var/list/new_objectives = list(
		new /datum/objective/werewolf/survive(),
		new /datum/objective/werewolf/pack_elder(),
		new /datum/objective/werewolf_counter/embrace_gift(),
	)
	for(var/datum/objective/objective as anything in new_objectives)
		objective.owner = owner
		objectives += objective

// Deliberately not chaining into the full werewolf greet - it announces the wrong curse.
/datum/antagonist/werewolf/lesser/greet()
	to_chat(owner.current, span_userdanger("The mooncurse runs shallow in my veins. I am moonkissed, not moonbound - I must follow the pack that made me."))
	owner.announce_objectives()
