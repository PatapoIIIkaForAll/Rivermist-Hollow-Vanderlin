/datum/action/cooldown/spell/undirected/list_target/grant_resident
	name = "Grant Residency"
	desc = "Offer someone residency."
	button_icon_state = "recruit_bog"
	var/quirk_path = /datum/quirk/positive/resident

/datum/action/cooldown/spell/undirected/list_target/grant_resident/get_list_targets(atom/center, conversion_radius = 7)
	var/list/things = list()

	if(conversion_radius)
		for(var/mob/living/carbon/human/nearby in view(conversion_radius, center) - center)
			if(!can_grant(nearby))
				continue
			things += nearby

	return things

/datum/action/cooldown/spell/undirected/list_target/grant_resident/proc/can_grant(mob/living/carbon/human/target)

	if(QDELETED(target))
		return FALSE

	if(!target.mind)
		return FALSE

	if(target.has_quirk(quirk_path))
		return FALSE

	return TRUE


/datum/action/cooldown/spell/undirected/list_target/grant_resident/cast(mob/living/carbon/human/target)

	if(QDELETED(target))
		return

	if(!target.mind)
		to_chat(owner, span_warning("They are not a valid person."))
		return

	var/face_name = target.get_face_name("")
	if(!length(face_name))
		to_chat(owner, span_warning("You must see their face to grant residency."))
		return

	. = ..()

	on_grant(target)

	if(owner && target)
		owner.say("By my authority, I grant you the right to dwell in Rivermist Hollow, [face_name]!")

/datum/action/cooldown/spell/undirected/list_target/grant_resident/proc/on_grant(mob/living/carbon/human/target)

	SHOULD_CALL_PARENT(TRUE)

	if(quirk_path && !target.has_quirk(quirk_path))
		target.add_quirk(quirk_path)

/datum/job/burgmeister/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()

	if(!spawned || QDELETED(spawned))
		return

	spawned.add_spell(/datum/action/cooldown/spell/undirected/list_target/grant_resident, source = src)


/datum/job/councilor/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()

	if(!spawned || QDELETED(spawned))
		return

	spawned.add_spell(/datum/action/cooldown/spell/undirected/list_target/grant_resident, source = src)

