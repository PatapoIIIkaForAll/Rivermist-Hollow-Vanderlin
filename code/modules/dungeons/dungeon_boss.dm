/mob/living/simple_animal/hostile/boss/dungeon
	abstract_type = /mob/living/simple_animal/hostile/boss/dungeon
	name = "dungeon horror"
	desc = "A guardian of the deep places, swollen with the dungeon's malice."
	faction = list("dungeon")
	/// Motes dropped when this boss dies (before floor scaling)
	var/mote_bounty = 200

/mob/living/simple_animal/hostile/boss/dungeon/test
	name = "Test Warden"
	desc = "A practice effigy that hits back."
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	mote_bounty = 100

GLOBAL_LIST_INIT(dungeon_boss_prefixes, list("Dread", "Gorged", "Elder", "Ravening", "Black", "Hollow"))
GLOBAL_LIST_INIT(dungeon_boss_titles, list("the Alpha", "the Devourer", "the Warden", "the Unbroken", "the Maw"))

/// Promotes any living mob into a floor boss: scales stats, dresses it up,
/// gives it a healthbar and (for non-ATB mobs) a telegraphed ability kit.
/// Returns the mote bounty the boss should award on death.
/proc/make_dungeon_boss(mob/living/boss, floor = 1, tier = 1, party_size = 1)
	if(!isliving(boss))
		return 0
	var/factor = 1 + max(0, floor - 1) * 0.35
	boss.maxHealth = round(max(1, boss.maxHealth) * factor)
	boss.health = boss.maxHealth
	// Optional vars — only scale what this mob actually has.
	if("melee_damage_lower" in boss.vars)
		boss.vars["melee_damage_lower"] = round(boss.vars["melee_damage_lower"] * (1 + max(0, floor - 1) * 0.2))
	if("melee_damage_upper" in boss.vars)
		boss.vars["melee_damage_upper"] = round(boss.vars["melee_damage_upper"] * (1 + max(0, floor - 1) * 0.2))
	if("obj_damage" in boss.vars)
		boss.vars["obj_damage"] = round(boss.vars["obj_damage"] * factor)
	if(iscarbon(boss))
		buff_carbon_dungeon_boss(boss, floor, party_size)

	// Presence: name + bigger sprite (no tint - it muddied every boss's palette).
	boss.name = "[pick(GLOB.dungeon_boss_prefixes)] [boss.name] [pick(GLOB.dungeon_boss_titles)]"
	var/matrix/scale = matrix(boss.transform)
	scale.Scale(1.3)
	boss.transform = scale

	// Healthbar for the whole room.
	boss.AddComponent(/datum/component/dungeon_boss_healthbar, boss.name)

	// Abilities: keep ATB for real bosses, else attach the lightweight kit.
	if(istype(boss, /mob/living/simple_animal/hostile/boss))
		if(istype(boss, /mob/living/simple_animal/hostile/boss/dungeon))
			scale_dungeon_boss_atb(boss, floor)
	else
		boss.AddComponent(/datum/component/dungeon_boss_abilities, null, 1 + max(0, floor - 1) * 0.2)

	// Mote bounty: bespoke bosses define their own; others scale by floor.
	var/bounty = 80 + max(0, floor - 1) * 25
	if(istype(boss, /mob/living/simple_animal/hostile/boss/dungeon))
		var/mob/living/simple_animal/hostile/boss/dungeon/dboss = boss
		bounty = max(bounty, dboss.mote_bounty)
	return bounty

/// Defeat-pool damage a humanoid floor boss takes before it falls.
/proc/get_dungeon_carbon_boss_toughness(floor = 1, party_size = 1)
	var/floor_factor = 1 + max(0, floor - 1) * 0.35
	return round(DUNGEON_BOSS_CARBON_TOUGHNESS * floor_factor * get_dungeon_party_hp_factor(party_size))

/// Carbon health ignores brute, so a humanoid boss gets a defeat pool, pain and crit guards, and stats.
/proc/buff_carbon_dungeon_boss(mob/living/carbon/boss, floor = 1, party_size = 1)
	boss.defeat_damage_threshold = get_dungeon_carbon_boss_toughness(floor, party_size)
	ADD_TRAIT(boss, TRAIT_NOPAINSTUN, DUNGEON_BOSS_TRAIT)
	ADD_TRAIT(boss, TRAIT_CRITICAL_RESISTANCE, DUNGEON_BOSS_TRAIT)
	ADD_TRAIT(boss, TRAIT_HARDDISMEMBER, DUNGEON_BOSS_TRAIT)
	boss.set_stat_modifier(DUNGEON_BOSS_TRAIT, list(
		STAT_STRENGTH = min(4 + max(0, floor - 1), 8),
		STAT_CONSTITUTION = 4,
		STAT_ENDURANCE = 4,
		STAT_SPEED = 2,
	))
	var/datum/weakref/boss_ref = WEAKREF(boss)
	finish_carbon_dungeon_boss(boss_ref)
	// NPC setup ends on a one-second timer that re-adds critical weakness and loads skill sheets.
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(finish_carbon_dungeon_boss), boss_ref), 2 SECONDS)

/// Strips critical weakness and lifts melee skills to the boss minimum; safe to repeat.
/proc/finish_carbon_dungeon_boss(datum/weakref/boss_ref)
	var/mob/living/carbon/boss = boss_ref?.resolve()
	if(QDELETED(boss) || boss.stat == DEAD)
		return
	REMOVE_TRAIT(boss, TRAIT_CRITICAL_WEAKNESS, null)
	if(!istype(boss.attributes))
		return
	var/static/list/boss_skills = list(
		/datum/attribute/skill/combat/knives,
		/datum/attribute/skill/combat/swords,
		/datum/attribute/skill/combat/polearms,
		/datum/attribute/skill/combat/axesmaces,
		/datum/attribute/skill/combat/whipsflails,
		/datum/attribute/skill/combat/shields,
		/datum/attribute/skill/combat/unarmed,
		/datum/attribute/skill/combat/wrestling,
	)
	for(var/skill_type in boss_skills)
		if(nulltozero(boss.attributes.raw_attribute_list[skill_type]) < DUNGEON_BOSS_MIN_COMBAT_SKILL)
			boss.attributes.set_skill_level(skill_type, DUNGEON_BOSS_MIN_COMBAT_SKILL)

/// Floor-scaling tweak for the bespoke ATB boss subtype's ability economy.
/proc/scale_dungeon_boss_atb(mob/living/simple_animal/hostile/boss/dungeon/boss, floor)
	if(!istype(boss) || floor <= 1)
		return
	if(boss.atb)
		boss.atb.point_regen_delay = max(1, round(boss.atb.point_regen_delay * max(0.5, 1 - (floor - 1) * 0.08)))
