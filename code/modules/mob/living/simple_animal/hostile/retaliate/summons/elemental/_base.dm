/mob/living/simple_animal/hostile/retaliate/elemental
	dendor_taming_chance = DENDOR_TAME_PROB_NONE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_ELEMENTAL
	/// Time between knockback slams on landed hits; 0 means this elemental never slams.
	var/slam_cooldown_time = 0
	COOLDOWN_DECLARE(slam_cooldown)

/mob/living/simple_animal/hostile/retaliate/elemental/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_TOXIMMUNE, TRAIT_GENERIC)

/mob/living/simple_animal/hostile/retaliate/elemental/AttackingTarget(mob/living/passed_target)
	. = ..()
	// Runs after the swing windup, so missed, parried or armor-stopped hits never slam.
	if(.)
		try_slam(passed_target || target)

/// Throws a struck victim away with extra blunt damage; AI-driven only, once per cooldown.
/mob/living/simple_animal/hostile/retaliate/elemental/proc/try_slam(mob/living/victim)
	if(!slam_cooldown_time || client || !COOLDOWN_FINISHED(src, slam_cooldown))
		return FALSE
	if(!isliving(victim) || QDELETED(victim) || victim.stat == DEAD)
		return FALSE
	COOLDOWN_START(src, slam_cooldown, slam_cooldown_time)
	var/throw_dir = get_dir(src, victim) || pick(GLOB.cardinals)
	victim.throw_at(get_edge_target_turf(src, throw_dir), 7, 4)
	victim.adjustBruteLoss(20, damage_type = BCLASS_BLUNT)
	return TRUE

/mob/living/simple_animal/hostile/retaliate/elemental/simple_limb_hit(zone)
	return ..()

/mob/living/simple_animal/hostile/retaliate/elemental/simple_add_wound(datum/wound/wound, silent = FALSE, crit_message = FALSE)	//no wounding the elementals
	return

/datum/intent/simple/elemental_unarmed
	name = "elemental unarmed"
	icon_state = "instrike"
	attack_verb = list("punches", "strikes", "rolls on", "crushes")
	animname = "blank22"
	blade_class = BCLASS_BLUNT
	hitsound = null
	chargetime = 0
	penfactor = 10
	swingdelay = 3
	candodge = TRUE
	canparry = TRUE
