/// The family profile behind this mob's controller flag; mobs without one get the base profile.
/mob/living/proc/get_horny_family_profile()
	return horny_profile_for_flag(ai_controller?.horny_pref_family_flag)

/// What onlookers see when this mob picks a horny target.
/mob/living/proc/get_horny_seek_message(mob/living/target)
	var/datum/horny_family_profile/profile = get_horny_family_profile()
	return profile.get_notice_message(src, target)

/// What onlookers see when this mob gives up on a horny target.
/mob/living/proc/get_horny_unsatisfied_message()
	var/datum/horny_family_profile/profile = get_horny_family_profile()
	return profile.get_unsatisfied_message(src)

/// What onlookers see when this mob is done with a horny target. heavy = sated for a long while.
/mob/living/proc/get_horny_sated_message(mob/living/target, heavy = FALSE)
	var/datum/horny_family_profile/profile = get_horny_family_profile()
	return profile.get_sated_message(src, target, heavy)

/proc/add_weighted_horny_ai_choice(list/weighted_choices, choice, weight = 1)
	for(var/i in 1 to weight)
		weighted_choices += choice

/// Act choices for a hunter next to its target, by family.
/proc/add_local_horny_ai_actions(list/weighted_actions, mob/living/basic_mob, mob/living/target_living)
	var/datum/horny_family_profile/profile = basic_mob.get_horny_family_profile()
	profile.add_act_choices(weighted_actions, basic_mob, target_living)

/// Act choices through a portal light.
/proc/add_portal_horny_ai_actions(list/weighted_actions, mob/living/basic_mob, mob/living/target_living)
	var/has_penis = !!basic_mob.getorganslot(ORGAN_SLOT_PENIS)
	var/has_vagina = !!basic_mob.getorganslot(ORGAN_SLOT_VAGINA)

	if(has_penis)
		if(target_living.getorganslot(ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/portal_base/portal_penis_vaginal, 3)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/portal_base/portal_penis_anal, 2)

	if(has_vagina)
		if(target_living.getorganslot(ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/portal_base/portal_vagina_vaginal, 3)
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/portal_base/portal_vagina_anal, 2)
