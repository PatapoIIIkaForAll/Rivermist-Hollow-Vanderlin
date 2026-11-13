/datum/ai_controller/volf
	movement_delay = 0.3 SECONDS

	ai_movement = /datum/ai_movement/hybrid_pathing
	horny_pref_family_flag = HORNY_MOB_TYPE_BEASTS

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_PET_TARGETING_DATUM = new /datum/targetting_datum/basic/not_friends(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/kidnap_defeated_prey,

		/datum/ai_planning_subtree/simple_find_horny,
		/datum/ai_planning_subtree/horny,

		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,

		///datum/ai_planning_subtree/find_dead_bodies,
		///datum/ai_planning_subtree/eat_dead_body,
	)

	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_controller/volf/agile
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/kidnap_defeated_prey,

		/datum/ai_planning_subtree/simple_find_horny,
		/datum/ai_planning_subtree/horny,

		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/agile,

		///datum/ai_planning_subtree/find_dead_bodies,
		///datum/ai_planning_subtree/eat_dead_body,
	)
