/datum/sex_action/hole_storage
	abstract_type = /datum/sex_action/hole_storage
	name = "hole_storage"
	requires_hole_storage = FALSE //ironic
	requires_free_hands = TRUE
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	hole_id = ORGAN_SLOT_VAGINA
	stored_item_type = /obj/item
	continous = TRUE
	var/self = FALSE
	var/obj/item/organ/genitals/target_organ
	/// The stored item the next cycle reaches for, chosen early so the cycle's length fits it.
	var/obj/item/pending_toy

/datum/sex_action/hole_storage/Destroy()
	target_organ = null
	pending_toy = null
	return ..()

/datum/sex_action/hole_storage/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/hand_lock = user.get_active_precise_hand()
	if(check_sex_lock(user, hand_lock))
		return FALSE
	var/obj/item/active_item = user.get_active_held_item()
	if(active_item && check_sex_lock(user, null, active_item))
		return FALSE
	return TRUE

/datum/sex_action/hole_storage/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, user.get_active_precise_hand())
	var/obj/item/active_item = user.get_active_held_item()
	if(active_item)
		add_sex_lock(user, null, active_item)
	if(hole_id)
		add_sex_lock(target, hole_id, null, FALSE)
