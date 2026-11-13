/// A telegraphed special move for a promoted boss.
/datum/dungeon_boss_ability
	var/name = "ability"
	var/cooldown = 8 SECONDS
	var/telegraph = "winds up!"
	var/next_use = 0
	/// Damage multiplier from the floor the boss guards
	var/power = 1

/datum/dungeon_boss_ability/proc/ready(world_time = world.time)
	return world_time >= next_use

/datum/dungeon_boss_ability/proc/use(mob/living/boss, atom/target)
	next_use = world.time + cooldown
	if(telegraph)
		boss.visible_message(span_warning("[boss] [telegraph]"))
	do_effect(boss, target)

/datum/dungeon_boss_ability/proc/do_effect(mob/living/boss, atom/target)
	return

/datum/dungeon_boss_ability/lunge
	name = "lunge"
	telegraph = "lunges!"
	cooldown = 7 SECONDS

/datum/dungeon_boss_ability/lunge/do_effect(mob/living/boss, atom/target)
	if(target)
		boss.throw_at(get_turf(target), 4, 1)

/datum/dungeon_boss_ability/slam
	name = "slam"
	telegraph = "raises up for a ground slam!"
	cooldown = 12 SECONDS

/datum/dungeon_boss_ability/slam/do_effect(mob/living/boss, atom/target)
	var/damage = round(DUNGEON_BOSS_SLAM_DAMAGE * power)
	for(var/mob/living/victim in range(1, boss))
		if(victim == boss || !victim.mind)
			continue
		victim.Knockdown(2 SECONDS)
		strike(boss, victim, damage)

/// Lands a blunt chest hit through armor; carbons take damage only as injuries, not apply_damage.
/datum/dungeon_boss_ability/slam/proc/strike(mob/living/boss, mob/living/victim, damage)
	if(!iscarbon(victim))
		victim.apply_damage(damage, BRUTE)
		return
	var/mob/living/carbon/carbon_victim = victim
	var/obj/item/bodypart/chest = carbon_victim.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return
	var/blocked = carbon_victim.run_armor_check(chest, "blunt", damage = damage, attacker = boss)
	if(damage - blocked <= 0)
		return
	chest.bodypart_attacked_by(BCLASS_BLUNT, damage - blocked, boss, BODY_ZONE_CHEST)
	carbon_victim.updatehealth()

/datum/dungeon_boss_ability/enrage
	name = "enrage"
	telegraph = "roars with fury!"
	cooldown = 25 SECONDS

/datum/dungeon_boss_ability/enrage/do_effect(mob/living/boss, atom/target)
	if(istype(boss, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/animal = boss
		animal.move_to_delay = max(1, animal.move_to_delay - 1)

/// Attaches a small ability kit to any living mob and fires it at its target.
/datum/component/dungeon_boss_abilities
	var/list/datum/dungeon_boss_ability/abilities = list()

/datum/component/dungeon_boss_abilities/Initialize(list/ability_types, power = 1)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	for(var/ability_type in (ability_types || list(/datum/dungeon_boss_ability/lunge, /datum/dungeon_boss_ability/slam)))
		var/datum/dungeon_boss_ability/ability = new ability_type
		ability.power = power
		abilities += ability
	START_PROCESSING(SSprocessing, src)

/datum/component/dungeon_boss_abilities/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	abilities = null
	return ..()

/datum/component/dungeon_boss_abilities/process(seconds_per_tick)
	var/mob/living/boss = parent
	if(QDELETED(boss) || boss.stat >= UNCONSCIOUS)
		return
	var/atom/target
	if(istype(boss, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/hostile_boss = boss
		target = hostile_boss.target
	else if(boss.ai_controller)
		target = boss.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		return
	for(var/datum/dungeon_boss_ability/ability as anything in abilities)
		if(ability.ready())
			ability.use(boss, target)
			break
