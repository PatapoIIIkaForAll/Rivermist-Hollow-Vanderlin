/datum/component/newborn_growth
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/mob/living/growing_mob
	var/datum/weakref/protected_parent_ref
	var/start_scale = 0.5
	var/final_scale = 1
	var/current_scale = 1
	var/growth_duration = 10 MINUTES
	var/growth_start_time = 0
	var/temporary_family_faction = null

/datum/component/newborn_growth/Initialize(_start_scale = 0.5, _growth_duration = 10 MINUTES, _final_scale = 1, mob/living/protected_parent = null)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	growing_mob = parent
	start_scale = max(0.1, _start_scale)
	final_scale = max(start_scale, _final_scale)
	growth_duration = max(1, _growth_duration)
	growth_start_time = world.time
	if(protected_parent && protected_parent != growing_mob)
		protected_parent_ref = WEAKREF(protected_parent)
		setup_temporary_family_faction(protected_parent)

	apply_scale(start_scale)
	START_PROCESSING(SSmob_functions, src)
	return ..()

/datum/component/newborn_growth/Destroy(force)
	clear_temporary_family_faction()
	STOP_PROCESSING(SSmob_functions, src)
	protected_parent_ref = null
	growing_mob = null
	return ..()

/datum/component/newborn_growth/process()
	if(!growing_mob)
		qdel(src)
		return

	var/progress = clamp((world.time - growth_start_time) / growth_duration, 0, 1)
	if(growing_mob.stat != DEAD)
		var/target_scale = start_scale + ((final_scale - start_scale) * progress)
		apply_scale(target_scale)

	if(progress >= 1)
		qdel(src)

/datum/component/newborn_growth/proc/apply_scale(target_scale)
	if(!growing_mob)
		return
	if(abs(target_scale - current_scale) < 0.01)
		return

	var/scale_ratio = target_scale / current_scale
	growing_mob.transform = growing_mob.transform.Scale(scale_ratio, scale_ratio)
	current_scale = target_scale

/datum/component/newborn_growth/proc/setup_temporary_family_faction(mob/living/protected_parent)
	if(!growing_mob || !protected_parent)
		return

	temporary_family_faction = "newborn_family_[REF(src)]"
	growing_mob.faction |= temporary_family_faction
	protected_parent.faction |= temporary_family_faction
	growing_mob.ai_controller?.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, protected_parent)
	protected_parent.ai_controller?.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, growing_mob)

/datum/component/newborn_growth/proc/clear_temporary_family_faction()
	if(!temporary_family_faction)
		return

	if(growing_mob)
		growing_mob.faction -= temporary_family_faction

	var/mob/living/protected_parent = protected_parent_ref?.resolve()
	if(protected_parent)
		protected_parent.faction -= temporary_family_faction
		protected_parent.ai_controller?.remove_thing_from_blackboard_key(BB_FRIENDS_LIST, growing_mob)

	if(protected_parent)
		growing_mob?.ai_controller?.remove_thing_from_blackboard_key(BB_FRIENDS_LIST, protected_parent)
	temporary_family_faction = null
