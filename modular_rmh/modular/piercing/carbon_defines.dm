/mob/living/carbon
	var/obj/item/piercings/piercings_item = null	//legwear item

/mob/living/carbon/proc/get_piercing_inscriptions(mob/user)
	if(!piercings_item)
		return list()

	var/datum/component/inscription_holder/inscriptions = piercings_item.GetComponent(
		/datum/component/inscription_holder
	)

	if(!inscriptions)
		return list()

	var/list/return_list = list(
		"On [p_their()] [piercings_item.name] is written:"
	)

	return return_list + inscriptions.get_examine_list(user)
