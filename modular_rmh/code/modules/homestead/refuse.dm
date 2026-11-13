/datum/action/cooldown/spell/undirected/list_target/revoke_resident
	name = "Revoke Residency"
	desc = "Strip someone of their residency."
	button_icon_state = "recruit_bog"


/datum/action/cooldown/spell/undirected/list_target/revoke_resident/get_list_targets(atom/center, conversion_radius = 7)
	var/list/things = list()

	if(conversion_radius)
		for(var/mob/living/carbon/human/nearby in get_hearers_in_LOS(conversion_radius, center) - center)
			if(!can_revoke(nearby))
				continue
			things += nearby

	return things


/datum/action/cooldown/spell/undirected/list_target/revoke_resident/proc/can_revoke(mob/living/carbon/human/target)

	if(QDELETED(target))
		return FALSE

	if(!target.mind)
		return FALSE

	if(!target.has_quirk(/datum/quirk/positive/resident))
		return FALSE

	var/face_name = target.get_face_name("")
	if(!length(face_name))
		return FALSE

	return TRUE


/datum/action/cooldown/spell/undirected/list_target/revoke_resident/cast(mob/living/carbon/human/target)

	if(QDELETED(target))
		return

	if(!target.has_quirk(/datum/quirk/positive/resident))
		to_chat(owner, span_warning("[target] is not a resident."))
		return

	var/face_name = target.get_face_name("")
	if(!length(face_name))
		to_chat(owner, span_warning("You must see their face to revoke residency."))
		return

	. = ..()

	target.remove_quirk(/datum/quirk/positive/resident)

	if(owner && target)
		owner.say("By my authority, I revoke your right to dwell in Rivermist Hollow, [face_name]!")

/datum/job/burgmeister/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()

	if(!spawned || QDELETED(spawned))
		return

	spawned.add_spell(/datum/action/cooldown/spell/undirected/list_target/revoke_resident, source = src)


/datum/job/councilor/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()

	if(!spawned || QDELETED(spawned))
		return

	spawned.add_spell(/datum/action/cooldown/spell/undirected/list_target/revoke_resident, source = src)
