/datum/ai_controller/dog
	movement_delay = 0.3 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	horny_pref_family_flag = HORNY_MOB_TYPE_BEASTS

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items/dog(),
		BB_PET_TARGETING_DATUM = new /datum/targetting_datum/basic/not_friends(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/horny/commanded,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/make_babies,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_controller/dog/puppy
	movement_delay = 0.4 SECONDS
	horny_pref_family_flag = NONE

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items(),
		BB_PET_TARGETING_DATUM = new /datum/targetting_datum/basic/not_friends(),
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_FIND_MOM_TYPES = list(/mob/living/simple_animal/hostile/retaliate/dog),
		BB_IGNORE_MOM_TYPES = list(/mob/living/simple_animal/hostile/retaliate/dog/puppy),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)

// Horny planning that never picks its own partner; only a commanded target starts it.
/datum/ai_planning_subtree/horny/commanded

/datum/ai_planning_subtree/horny/commanded/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		if(target)
			controller.clear_blackboard_key(target_key)
		return
	return ..()

// Normal combat targeting until the owner gives the breed order.
/datum/targetting_datum/basic/allow_items/dog

/datum/targetting_datum/basic/allow_items/dog/should_prioritize_horny_targets(mob/living/living_mob)
	var/datum/ai_controller/controller = living_mob?.ai_controller
	if(!controller)
		return FALSE
	if(controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET])
		return TRUE
	return istype(controller.blackboard[BB_ACTIVE_PET_COMMAND], /datum/pet_command/pet_breed_other)

// The breed order, accepted only from the pet's owner.
/datum/pet_command/pet_breed_other/owner_only

/datum/pet_command/pet_breed_other/owner_only/proc/is_owner(mob/living/commander)
	var/mob/living/simple_animal/pet = weak_parent?.resolve()
	return istype(pet) && !isnull(commander) && pet.owner == commander

/datum/pet_command/pet_breed_other/owner_only/try_activate_command(mob/living/commander, radial_command)
	if(!is_owner(commander))
		if(radial_command)
			var/mob/living/pet = weak_parent?.resolve()
			to_chat(commander, span_warning("[pet] only takes that order from [pet.p_their()] master."))
		return FALSE
	return ..()

/datum/pet_command/pet_breed_other/owner_only/on_target_set(mob/living/friend, atom/potential_target)
	if(!is_owner(friend))
		return
	return ..()
