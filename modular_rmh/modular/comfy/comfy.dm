#define COMFY_IDLE_TIME (15 MINUTES)

/mob/living/carbon/human/proc/handle_comfy()
	if(last_move_time < world.time - COMFY_IDLE_TIME)
		apply_status_effect(/datum/status_effect/buff/comfy)
	else
		remove_status_effect(/datum/status_effect/buff/comfy)

/mob/living/carbon/human/proc/comfy_heal()
	var/sleepy_mod = 0.1
	if(!bleed_rate)
		blood_volume = min(blood_volume + (4 * sleepy_mod), BLOOD_VOLUME_NORMAL)
	var/health_changed = FALSE
	for(var/obj/item/bodypart/affecting as anything in bodyparts)
		var/limb_hurt = affecting.status == BODYPART_ORGANIC && (affecting.brute_dam || affecting.burn_dam)
		if(!limb_hurt && !length(affecting.wounds))
			continue
		if(affecting.get_bleed_rate() >= 1)
			continue
		// One health refresh at the end; a refresh per limb recounted pain across the whole body each time.
		if(limb_hurt)
			if(affecting.heal_damage(sleepy_mod, sleepy_mod, required_status = BODYPART_ORGANIC, updating_health = FALSE))
				update_damage_overlays()
			health_changed = TRUE
		for(var/datum/wound/wound as anything in affecting.wounds)
			if(!wound.sleep_healing)
				continue
			wound.heal_wound(wound.sleep_healing * sleepy_mod)
	if(getToxLoss())
		adjustToxLoss(-sleepy_mod, FALSE)
		health_changed = TRUE
	if(health_changed)
		updatehealth()

/datum/status_effect/buff/comfy
	id = "comfy"
	alert_type = /atom/movable/screen/alert/status_effect/buff/comfy
	duration = -1

/atom/movable/screen/alert/status_effect/buff/comfy
	name = "I feel at peace"
	desc = "You are so comfortable that you don't really feel like eating or drinking. Strange."
	icon_state = "stressvgood"


/datum/status_effect/buff/comfy/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_FREEZEHUNGER, "comfy")
	owner.add_stress(/datum/stress_event/comfy)


/datum/status_effect/buff/comfy/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_FREEZEHUNGER, "comfy")
	owner.remove_stress(/datum/stress_event/comfy)


/datum/status_effect/buff/comfy/tick()
	// Life stops far from players, so handle_comfy() never clears a mob that walked off; check here too.
	if(owner.last_move_time >= world.time - COMFY_IDLE_TIME)
		qdel(src)
		return
	var/mob/living/carbon/human/bob = owner
	bob.comfy_heal()

/datum/stress_event/comfy
	timer = INFINITY
	desc = "<span class='nicegreen'>I'm so comfortable and peaceful!</span>\n"
	stress_change = -10

#undef COMFY_IDLE_TIME
