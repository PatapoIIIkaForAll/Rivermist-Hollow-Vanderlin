/// Contracts won through a creature's lust instead of its death.
/datum/quest/kill/carnal
	abstract_type = /datum/quest/kill/carnal
	contract_group = QUEST_GROUP_CARNAL
	kill_component_type = /datum/component/quest_object/kill/carnal
	/// Horny-mob families the taker allows; null when no taker shaped the pool, as on the shared board.
	var/allowed_family_flags
	/// HORNY_MOBS_TAG_* genders the taker allows; null when no taker shaped the pool.
	var/allowed_gender_tags
	/// Creatures still standing for the contract; drives the reward instead of progress.
	var/spawned_target_count = 0
	/// Horny-mob family of the spawned creature, matched against viewers' preferences.
	var/target_family_flag = NONE

/datum/quest/kill/carnal/get_landmark_contract_types()
	return list(QUEST_HUNT, QUEST_CLEAR_OUT)

/datum/quest/kill/carnal/prepare_for_issuer(mob/living/carbon/human/issuer)
	if(!istype(issuer))
		return
	allowed_family_flags = issuer.get_cached_horny_mob_family_flags()
	allowed_gender_tags = issuer.get_cached_horny_mob_pref_flags()

/datum/quest/kill/carnal/is_visible_to(mob/living/carbon/human/viewer)
	if(!carnal_contracts_allowed_for(viewer))
		return FALSE
	if(!target_family_flag)
		return TRUE
	return !!(viewer.get_cached_horny_mob_family_flags() & target_family_flag)

/datum/quest/kill/carnal/can_claim(mob/user)
	return is_visible_to(user)

/datum/quest/kill/carnal/get_mob_spawn_weight(mob_type)
	if(!isnull(allowed_family_flags) && !(allowed_family_flags & get_horny_family_for_mob_type(mob_type)))
		return 0
	return ..()

/datum/quest/kill/carnal/proc/has_allowed_targets()
	for(var/mob_type in mob_types_to_spawn)
		if(get_mob_spawn_weight(mob_type) > 0)
			return TRUE
	return FALSE

/datum/quest/kill/carnal/cache_target_spawn_values()
	..()
	target_family_flag = get_horny_family_for_mob_type(target_mob_type)

/datum/quest/kill/carnal/generate(obj/effect/landmark/quest_spawner/landmark)
	..()
	if(!landmark)
		return FALSE
	if(!spawn_kill_mobs(landmark))
		return FALSE
	spawned_target_count = progress_required
	if(!on_targets_spawned())
		return FALSE
	title = build_title()
	return TRUE

/datum/quest/kill/carnal/get_title()
	return title || build_title()

/// Names the contract once its creature is known.
/datum/quest/kill/carnal/proc/build_title()
	return "Carnal contract"

/// Subtype hook after the creatures exist; returns FALSE when the contract cannot be built.
/datum/quest/kill/carnal/proc/on_targets_spawned()
	return TRUE

/datum/quest/kill/carnal/prepare_spawned_target(mob/living/new_mob)
	if(isanimal(new_mob))
		var/wanted_gender = pick_spawn_gender()
		if(wanted_gender)
			new_mob.gender = wanted_gender
		new_mob.give_genitals()
	// Arousal makes a clientless creature horny-KO-able before its AI ever turns horny.
	if(!new_mob.GetComponent(/datum/component/arousal))
		new_mob.AddComponent(/datum/component/arousal)

/// Gender for simple creatures this contract spawns, or null to keep their own.
/datum/quest/kill/carnal/proc/pick_spawn_gender()
	if(isnull(allowed_gender_tags))
		return null
	var/list/genders = list()
	if(allowed_gender_tags & HORNY_MOBS_TAG_MALES)
		genders += MALE
	if(allowed_gender_tags & HORNY_MOBS_TAG_FEMALES)
		genders += FEMALE
	return length(genders) ? pick(genders) : null

/// Carnal contracts are not combat, so a rune rescue keeps them.
/datum/quest/kill/carnal/fails_on_rune_rescue(mob/living/carbon/rescued)
	return FALSE

/datum/quest/kill/carnal/get_risk_score(turf/target_turf)
	return target_risk_value + type_risk_bonus + round(max(spawned_target_count - 1, 0) / 2)

/datum/quest/kill/carnal/calculate_reward(turf/target_turf)
	var/risk_score = max(1, ROUND_UP(get_risk_score(target_turf)))
	threat_tier = get_tier_from_risk_score(risk_score)

	var/base_total = max(1, target_risk_value) * max(1, spawned_target_count) * get_reward_multiplier()
	base_total += get_task_reward_bonus()
	base_total *= map_reward_modifier
	base_total *= (1 + distance_bonus_mult)
	return max(0, ROUND_UP(base_total))

/// Flat reward on top of the creature risk, for the size of the task.
/datum/quest/kill/carnal/proc/get_task_reward_bonus()
	return 0

/// A contract creature died or vanished; it no longer helps the contract.
/datum/quest/kill/carnal/proc/on_target_lost(mob/living/lost_target)
	spawned_target_count = max(spawned_target_count - 1, 0)
	remove_tracked_atom(lost_target)
	if(!spawned_target_count && !quest_receiver_reference && SSquestboard?.is_posted(src))
		expire_posting("its last creature is gone")
		return
	quest_scroll?.update_quest_text()

/datum/quest/kill/carnal/proc/count_living_targets()
	. = 0
	for(var/datum/weakref/target_ref as anything in tracked_atoms)
		var/mob/living/target = target_ref.resolve()
		if(isliving(target) && target.stat != DEAD)
			.++

/datum/quest/kill/carnal/get_location_text()
	return target_spawn_area ? "Reported in heat around the [target_spawn_area] region." : "Location unknown."

/// Horny-mob family of a mob type, read from its AI controller.
/proc/get_horny_family_for_mob_type(mob_type)
	var/mob/living/mob_path = mob_type
	var/datum/ai_controller/controller_path = initial(mob_path.ai_controller)
	if(!ispath(controller_path, /datum/ai_controller))
		return NONE
	return initial(controller_path.horny_pref_family_flag)

/// Carnal contracts are only for players who let horny creatures pick them.
/proc/carnal_contracts_allowed_for(mob/living/user)
	if(!isliving(user))
		return FALSE
	return user.get_cached_horny_mob_pref_flags() && user.get_cached_horny_mob_family_flags()

/// TRUE when the player is opted in and at least one creature of the contract type suits them.
/proc/carnal_contract_type_allowed_for(contract_type, mob/living/carbon/human/user)
	if(!carnal_contracts_allowed_for(user))
		return FALSE
	var/quest_path = GLOB.global_quest_registry[contract_type]
	if(!ispath(quest_path, /datum/quest/kill/carnal))
		return FALSE
	var/datum/quest/kill/carnal/template = new quest_path
	template.prepare_for_issuer(user)
	. = template.has_allowed_targets()
	qdel(template)

/// Creatures for carnal contracts: dying or vanishing never advances the contract.
/datum/component/quest_object/kill/carnal

/datum/component/quest_object/kill/carnal/complete_target(mob/living/target_mob)
	if(completion_counted)
		return FALSE
	var/datum/quest/kill/carnal/Q = quest_ref.resolve()
	if(!Q || Q.complete || Q.being_destroyed)
		return FALSE
	completion_counted = TRUE
	target_mob.remove_filter(outline_filter_id)
	Q.on_target_lost(target_mob)
	qdel(src)
	return FALSE
