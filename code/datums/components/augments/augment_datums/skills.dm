/datum/attribute_modifier/augment
	variable = TRUE

/datum/augment/skill
	var/list/skill_changes = list() // List of skill changes: list(/datum/attribute/skill/combat/swords = 1)
	stability_cost = 0 // Skills are zero-cost by default

/datum/augment/skill/on_install(mob/living/carbon/human/H)
	var/datum/attribute_modifier/existing_modifier = H.attributes.has_attribute_modifier(/datum/attribute_modifier/augment)
	var/list/new_values
	if(existing_modifier)
		new_values = existing_modifier.attribute_list.Copy()
	else
		new_values = list()
	new_values += skill_changes
	H.attributes.add_or_update_variable_attribute_modifier(/datum/attribute_modifier/augment, TRUE, new_values)

/datum/augment/skill/on_remove(mob/living/carbon/human/H)
	var/datum/attribute_modifier/existing_modifier = H.attributes.has_attribute_modifier(/datum/attribute_modifier/augment)
	var/list/new_values
	if(existing_modifier)
		new_values = existing_modifier.attribute_list.Copy()
	else
		new_values = list()
	for(var/value in skill_changes)
		if(value in new_values)
			new_values[value] -= skill_changes[value]
		else
			new_values |= value
			new_values[value] = -skill_changes[value]
	H.attributes.add_or_update_variable_attribute_modifier(/datum/attribute_modifier/augment, TRUE, new_values)

/datum/augment/skill/get_examine_info()
	var/list/info = list()
	info += span_info("Skill changes:")
	for(var/skill_type in skill_changes)
		var/datum/attribute/skill/S = skill_type
		var/change = skill_changes[skill_type]
		info += span_info("  [initial(S.name)]: [change > 0 ? "+" : ""][change]")
	return info

/datum/augment/skill/combat_matrix
	name = "brawler's knuckle-works"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at wrestling and unarmed fighting."
	skill_changes = list(/datum/attribute/skill/combat/wrestling = 1, /datum/attribute/skill/combat/unarmed = 1)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/blade_processor
	name = "swordsman's wrist-gimbal"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better with swords."
	skill_changes = list(/datum/attribute/skill/combat/swords = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 18 SECONDS

/datum/augment/skill/whip_servo
	name = "whipcord reel"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better with whips and flails."
	skill_changes = list(/datum/attribute/skill/combat/whipsflails = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 18 SECONDS

/datum/augment/skill/polearm_stabilizer
	name = "pikeman's brace"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better with polearms."
	skill_changes = list(/datum/attribute/skill/combat/polearms = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 18 SECONDS

/datum/augment/skill/shield_actuator
	name = "buckler spring"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better with shields."
	skill_changes = list(/datum/attribute/skill/combat/shields = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/crossbow_targeting
	name = "arbalest sight"
	socket_kinds = list(PROSTHETIC_KIND_EYE)
	point_value = -1
	desc = "Better with crossbows."
	skill_changes = list(/datum/attribute/skill/combat/crossbows = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 20 SECONDS

/datum/augment/skill/bow_stabilizer
	name = "archer's draw-lens"
	socket_kinds = list(PROSTHETIC_KIND_EYE)
	point_value = -1
	desc = "Better with bows."
	skill_changes = list(/datum/attribute/skill/combat/bows = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 20 SECONDS

/datum/augment/skill/smithing_optimizer
	name = "smith's hammer cam"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at blacksmithing and smelting."
	skill_changes = list(/datum/attribute/skill/craft/blacksmithing = 1, /datum/attribute/skill/craft/smelting = 1)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/weaponcraft_matrix
	name = "bladewright's jig"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at weaponsmithing."
	skill_changes = list(/datum/attribute/skill/craft/weaponsmithing = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 18 SECONDS

/datum/augment/skill/armorcraft_matrix
	name = "armourer's riveter"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at armorsmithing."
	skill_changes = list(/datum/attribute/skill/craft/armorsmithing = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 18 SECONDS

/datum/augment/skill/carpentry_guide
	name = "joiner's plumb"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at carpentry."
	skill_changes = list(/datum/attribute/skill/craft/carpentry = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/masonry_analyzer
	name = "mason's level"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at masonry."
	skill_changes = list(/datum/attribute/skill/craft/masonry = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/engineering_core
	name = "artificer's calipers"
	socket_kinds = list(PROSTHETIC_KIND_EYE)
	point_value = -1
	desc = "Better at engineering."
	skill_changes = list(/datum/attribute/skill/craft/engineering = 2)
	engineering_difficulty = SKILL_RANK_MASTER
	installation_time = 25 SECONDS

/datum/augment/skill/alchemy_database
	name = "alchemist's taste-reed"
	socket_kinds = list(PROSTHETIC_KIND_TONGUE)
	point_value = -1
	desc = "Better at alchemy."
	skill_changes = list(/datum/attribute/skill/craft/alchemy = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 20 SECONDS

// Skill augments - Labor skills
/datum/augment/skill/mining_efficiency
	name = "miner's pick-driver"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at mining."
	skill_changes = list(/datum/attribute/skill/labor/mining = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/farming_analyzer
	name = "furrow gauge"
	socket_kinds = list(PROSTHETIC_KIND_EYE)
	point_value = -1
	desc = "Better at farming."
	skill_changes = list(/datum/attribute/skill/labor/farming = 2)
	engineering_difficulty = SKILL_RANK_APPRENTICE
	installation_time = 12 SECONDS

/datum/augment/skill/butchering_guide
	name = "butcher's cleaver cam"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at butchering."
	skill_changes = list(/datum/attribute/skill/labor/butchering = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/lumberjack_optimizer
	name = "woodsman's axe-swing"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at lumberjacking."
	skill_changes = list(/datum/attribute/skill/labor/lumberjacking = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/medicine_database
	name = "chirurgeon's lens"
	socket_kinds = list(PROSTHETIC_KIND_EYE)
	point_value = -1
	desc = "Better at medicine."
	skill_changes = list(/datum/attribute/skill/misc/medicine = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 20 SECONDS

/datum/augment/skill/lockpick_analyzer
	name = "locksmith's feeler"
	socket_kinds = list(PROSTHETIC_KIND_ARM)
	point_value = -1
	desc = "Better at lockpicking."
	skill_changes = list(/datum/attribute/skill/misc/lockpicking = 2)
	engineering_difficulty = SKILL_RANK_JOURNEYMAN
	installation_time = 15 SECONDS

/datum/augment/skill/climbing_optimizer
	name = "climber's grip-spikes"
	socket_kinds = list(PROSTHETIC_KIND_LEG)
	point_value = -1
	desc = "Better at climbing."
	skill_changes = list(/datum/attribute/skill/misc/climbing = 2)
	engineering_difficulty = SKILL_RANK_APPRENTICE
	installation_time = 12 SECONDS

/datum/augment/skill/stealth_dampener
	name = "muffled joints"
	socket_kinds = list(PROSTHETIC_KIND_LEG)
	point_value = -1
	desc = "Better at sneaking."
	skill_changes = list(/datum/attribute/skill/misc/sneaking = 2)
	engineering_difficulty = SKILL_RANK_EXPERT
	installation_time = 18 SECONDS
