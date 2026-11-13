/datum/augment/stats
	var/list/stat_changes = list() // List of stat changes: list(STAT_STRENGTH = 1, STAT_SPEED = -1)

/datum/augment/stats/on_install(mob/living/carbon/human/H)
	for(var/stat in stat_changes)
		H.change_stat(stat, stat_changes[stat])

/datum/augment/stats/on_remove(mob/living/carbon/human/H)
	for(var/stat in stat_changes)
		H.change_stat(stat, -stat_changes[stat])

/datum/augment/stats/get_examine_info()
	var/list/info = list()
	info += span_info("Stat changes:")
	for(var/stat in stat_changes)
		var/change = stat_changes[stat]
		info += span_info("  [stat]: [change > 0 ? "+" : ""][change]")
	return info

/datum/augment/stats/strength_servo
	name = "brass sinew piston"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -2
	desc = "More strength."
	stability_cost = -15
	stat_changes = list(STAT_STRENGTH = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/stats/perception_lens
	name = "hawk's-eye loupe"
	socket_kinds = list(PROSTHETIC_KIND_EYE)
	point_value = -2
	desc = "More perception."
	stability_cost = -10
	stat_changes = list(STAT_PERCEPTION = 2)
	engineering_difficulty = SKILL_RANK_APPRENTICE
	installation_time = 12 SECONDS

/datum/augment/stats/processing_core
	name = "thinking-gear engine"
	socket_kinds = list()
	point_value = -3
	desc = "More intelligence. Lowers core stability a lot."
	stability_cost = -20
	stat_changes = list(STAT_INTELLIGENCE = 3)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 20 SECONDS

/datum/augment/stats/reinforced_frame
	name = "riveted heart cage"
	socket_kinds = list(PROSTHETIC_KIND_HEART)
	point_value = -2
	desc = "More constitution."
	stability_cost = -15
	stat_changes = list(STAT_CONSTITUTION = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/stats/endurance_battery
	name = "deep-draw valve"
	socket_kinds = list(PROSTHETIC_KIND_LUNGS)
	point_value = -2
	desc = "More endurance."
	stability_cost = -10
	stat_changes = list(STAT_ENDURANCE = 2)
	engineering_difficulty = SKILL_RANK_APPRENTICE
	installation_time = 12 SECONDS

/datum/augment/stats/mobility_actuator
	name = "spring-heel actuator"
	socket_kinds = list(PROSTHETIC_KIND_LEG)
	point_value = -2
	desc = "More speed."
	stability_cost = -12
	stat_changes = list(STAT_SPEED = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/stats/power_limiter
	name = "strength governor"
	socket_kinds = list()
	point_value = 0
	desc = "Limits power output to improve core stability."
	stability_cost = 10
	stat_changes = list(STAT_STRENGTH = -1)
	engineering_difficulty = SKILL_RANK_NOVICE
	installation_time = 8 SECONDS

/datum/augment/stats/sensor_dampener
	name = "smoked lens"
	socket_kinds = list()
	point_value = 0
	desc = "Reduces sensor sensitivity to decrease processing load."
	stability_cost = 8
	stat_changes = list(STAT_PERCEPTION = -1)
	engineering_difficulty = SKILL_RANK_NOVICE
	installation_time = 8 SECONDS

/datum/augment/stats/logic_limiter
	name = "simple gear train"
	socket_kinds = list()
	point_value = 0
	desc = "Reduces processing complexity for improved stability."
	stability_cost = 15
	stat_changes = list(STAT_INTELLIGENCE = -2)
	engineering_difficulty = SKILL_RANK_NOVICE
	installation_time = 10 SECONDS

/datum/augment/stats/lightweight_frame
	name = "hollow frame"
	socket_kinds = list()
	point_value = 0
	desc = "Reduces structural integrity for better energy efficiency."
	stability_cost = 10
	stat_changes = list(STAT_CONSTITUTION = -1)
	engineering_difficulty = SKILL_RANK_NOVICE
	installation_time = 8 SECONDS

/datum/augment/stats/efficiency_mode
	name = "banked furnace"
	socket_kinds = list()
	point_value = 0
	desc = "Reduces operational capacity to improve stability."
	stability_cost = 8
	stat_changes = list(STAT_ENDURANCE = -1)
	engineering_difficulty = SKILL_RANK_NOVICE
	installation_time = 8 SECONDS

/datum/augment/stats/servo_governor
	name = "stride governor"
	socket_kinds = list()
	point_value = 0
	desc = "Restricts movement speed to reduce mechanical stress."
	stability_cost = 10
	stat_changes = list(STAT_SPEED = -1)
	engineering_difficulty = SKILL_RANK_NOVICE
	installation_time = 8 SECONDS

/datum/augment/stats/balanced_matrix
	name = "balanced counterweights"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -2
	desc = "A little more strength and constitution."
	stability_cost = -5
	stat_changes = list(STAT_STRENGTH = 1, STAT_CONSTITUTION = 1)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 20 SECONDS

/datum/augment/stats/core_stabilizer
	name = "soul-core stabiliser"
	socket_kinds = list()
	point_value = 0
	desc = "Dramatically improves core stability without affecting performance."
	stability_cost = 25
	stat_changes = list()
	engineering_difficulty = SKILL_RANK_MASTER
	installation_time = 25 SECONDS
