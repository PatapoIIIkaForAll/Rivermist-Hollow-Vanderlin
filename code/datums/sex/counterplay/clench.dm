#define CLENCH_COOLDOWN (2 SECONDS)
#define CLENCH_STAMINA_FRACTION 0.1
#define CLENCH_AROUSAL_BONUS 3

/// Fatigue one clench costs, sized so roughly ten of them exhaust the clencher.
/proc/get_clench_stamina_cost(mob/living/clencher)
	if(!clencher)
		return 0
	return max(1, (clencher.maximum_stamina || 100) * CLENCH_STAMINA_FRACTION)

/// Verb pair used in clench messages, picked from the action's targeted hole.
/proc/get_clench_verbs(hole_id)
	switch(hole_id)
		if(ORGAN_SLOT_ANUS, ORGAN_SLOT_VAGINA)
			return list("clench" = "clench", "clenches" = "clenches")
	return list("clench" = "squirm", "clenches" = "squirms")

/// Whether this mob may clench this action right now.
/datum/sex_action/proc/can_clench(mob/living/clencher)
	if(!clencher || QDELETED(clencher) || QDELETED(src))
		return FALSE
	if(clencher != action_target || clencher == action_user)
		return FALSE
	if(!is_runtime_active())
		return FALSE
	if(clencher.stat != CONSCIOUS)
		return FALSE
	if(world.time < next_clench_time)
		return FALSE
	if(clencher.stamina >= clencher.maximum_stamina)
		return FALSE
	return TRUE

/// Rolls a clench and applies whatever came out of it.
/datum/sex_action/proc/try_clench(mob/living/clencher)
	if(!can_clench(clencher))
		return CLENCH_RESULT_FAIL
	return apply_clench_result(clencher, roll_clench(clencher, action_user))

/// Applies a clench outcome. Always charges stamina and sets the cooldown.
/datum/sex_action/proc/apply_clench_result(mob/living/clencher, result)
	if(!clencher || QDELETED(clencher) || QDELETED(src))
		return CLENCH_RESULT_FAIL

	next_clench_time = world.time + CLENCH_COOLDOWN
	clencher.adjust_stamina(get_clench_stamina_cost(clencher))

	var/list/verbs = get_clench_verbs(hole_id)
	switch(result)
		if(CLENCH_RESULT_STOP)
			stop_requested = TRUE
			clencher.visible_message( \
				span_warning("[clencher] [verbs["clenches"]] hard, and [action_user] loses their rhythm entirely!"), \
				span_notice("I [verbs["clench"]] down and force [action_user] off me!"))
			to_chat(action_user, span_warning("[clencher] [verbs["clenches"]] and I lose it completely!"))
		if(CLENCH_RESULT_INTERRUPT)
			cycle_interrupted = TRUE
			clencher.visible_message( \
				span_warning("[clencher] [verbs["clenches"]] against [action_user]."), \
				span_notice("I [verbs["clench"]] and throw [action_user] off their stride."))
			to_chat(action_user, span_warning("[clencher] [verbs["clenches"]] and knocks me out of rhythm!"))
		else
			to_chat(clencher, span_warning("I [verbs["clench"]], but [action_user] does not falter."))

	if(result != CLENCH_RESULT_FAIL)
		perform_sex_action(action_user, clencher, CLENCH_AROUSAL_BONUS, 0, 0)
	// A clench that throws a hunting mob off feeds its temper and its lust.
	if(result == CLENCH_RESULT_STOP)
		action_user.ai_controller?.horny_react(HORNY_REACT_CLENCH, clencher, 1)

	return result

/// Whether this mob wants clenches fired automatically. Session override beats the saved preference.
/mob/living/proc/wants_auto_clench()
	if(!isnull(auto_clench_override))
		return !!auto_clench_override
	return get_cached_erp_pref(/datum/erp_preference/boolean/auto_clench) == TRUE

/// Whether the target has auto-clench armed and can act on it this cycle.
/datum/sex_action/proc/should_auto_clench()
	if(!action_target || action_target == action_user)
		return FALSE
	if(!action_target.cmode)
		return FALSE
	if(!action_target.wants_auto_clench())
		return FALSE
	return can_clench(action_target)

#undef CLENCH_COOLDOWN
#undef CLENCH_STAMINA_FRACTION
#undef CLENCH_AROUSAL_BONUS
