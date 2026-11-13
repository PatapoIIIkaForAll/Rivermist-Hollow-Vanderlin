/mob/living/carbon/human
	var/received_resident_key = FALSE

/obj/structure/door/town
	name = "homestead door"

	var/grant_resident_key = TRUE
	var/resident_key_type = /obj/item/key/town
	var/resident_key_amount = 1
	var/house_id
	max_integrity = 4000
	integrity_failure = 0.5
	armor_type = /datum/armor/rmh/structure/town_door
	damage_deflection = 20

/obj/item/key/town
	name = "homestead's key"
	icon_state = "rustkey"
	var/house_id

/obj/structure/door/town/Initialize()
	. = ..()

	if(!house_id)
		house_id = generate_town_lockid(src)

	if(!lock_check(TRUE))
		return

	var/datum/lock/key/KL = lock
	KL.lockid_list = list(house_id)
	KL.locked = TRUE

/proc/generate_town_lockid(obj/structure/door/D)
	var/time_part = world.time % 1000000
	var/random_part = rand(1,1000)
	return "town_[time_part][D.x][D.y][D.z][random_part]"


/obj/structure/door/town/proc/try_award_resident_key(mob/user)

	if(!grant_resident_key)
		return FALSE

	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/H = user

	if(!H.has_quirk(/datum/quirk/positive/resident))
		return FALSE

	if(H.received_resident_key)
		return FALSE

	if(!house_id)
		return FALSE

	var/answer = alert(H, "Is this your home?", "Home", "Yes", "No")
	if(answer != "Yes")
		return FALSE

	for(var/i in 1 to resident_key_amount)
		var/obj/item/key/town/K = new resident_key_type(get_turf(H))
		K.lockids = list(house_id)
		H.put_in_hands(K)

	H.received_resident_key = TRUE
	grant_resident_key = FALSE

	to_chat(H, span_notice("You find the key to your home."))

	name = "[H.real_name]'s house"

	return TRUE

/obj/structure/door/town/attack_hand(mob/user)

	if(try_award_resident_key(user))
		return

	return ..()


/obj/structure/door/town/proc/can_open(mob/living/user)
	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/H = user

	if(!H.has_quirk(/datum/quirk/positive/resident))
		to_chat(H, span_warning("This is not your home."))
		return FALSE

	return TRUE

/obj/structure/door/town/TryToSwitchState(atom/user)

	if(grant_resident_key)
		return FALSE

	if(isliving(user))
		var/mob/living/L = user

		if(ishuman(L))
			var/mob/living/carbon/human/H = L

			if(!H.has_quirk(/datum/quirk/positive/resident))
				to_chat(H, span_warning("This is not your home."))
				return FALSE

	return ..()

