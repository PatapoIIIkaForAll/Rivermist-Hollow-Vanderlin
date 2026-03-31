/obj/item/storage/backpack/bag_of_many_items
	name = "bag of many items"
	desc = "A small magical bag with a face painted on its front, holding a lot more that might seem possible. Don't mix it up with a Bag of Holding!"
	icon_state = "bag_of_holding"
	item_state = "bag_of_holding"
	icon = 'modular_rmh/icons/obj/bag_of_holding.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = NONE
	max_integrity = 1500
	sewrepair = FALSE
	equip_sound = 'sound/blank.ogg'
	bloody_icon_state = "bodyblood"
	component_type = /datum/component/storage/concrete/grid/bag_of_holding

/obj/item/storage/backpack/bag_of_holding
	name = "bag of holding"
	desc = "A small magical bag with a face painted on its front, holding far more than it appears, thanks to a hidden extradimensional space inside."
	icon_state = "bag_of_holding"
	item_state = "bag_of_holding"
	icon = 'modular_rmh/icons/obj/bag_of_holding.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = NONE
	max_integrity = 1500
	equip_sound = 'sound/blank.ogg'
	bloody_icon_state = "bodyblood"
	alternate_worn_layer = UNDER_CLOAK_LAYER
	component_type = null
	var/climb_inside_delay = 2 SECONDS
	var/stuff_mob_delay = 3 SECONDS

/obj/item/storage/backpack/bag_of_holding/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pocket_access, /datum/map_template/pocket/bag_of_holding, POCKET_ACCESS_INSTANCE_OWNER, null, null, null, FALSE, FALSE, TRUE, "Bag of Holding", "The bag's mouth yawns wider than it should. Step through the fold?", null, "The impossible seams of the bag snap shut and folded space throws you back out!")

/obj/item/storage/backpack/bag_of_holding/examine(mob/user)
	. = ..()
	. += span_notice("Use it to climb inside its folded space.")
	. += span_notice("Hit it with an item to stuff that item inside.")
	. += span_notice("Use a firm grab on it to start stuffing someone into the bag.")

/obj/item/storage/backpack/bag_of_holding/proc/get_pocket_access()
	return GetComponent(/datum/component/pocket_access)

/obj/item/storage/backpack/bag_of_holding/proc/prepare_bag_for_folded_space(mob/user, action_text)
	if(QDELETED(src) || QDELETED(user))
		return FALSE

	if(loc == user && !user.dropItemToGround(src, TRUE, TRUE))
		to_chat(user, span_warning("I need to put [src] down before [action_text]."))
		return FALSE
	if(!Adjacent(user))
		to_chat(user, span_warning("I need to stay close to [src] to [action_text]."))
		return FALSE

	return TRUE

/obj/item/storage/backpack/bag_of_holding/proc/try_climb_inside(mob/user)
	var/datum/component/pocket_access/access = get_pocket_access()
	if(!access)
		return FALSE

	var/datum/pocket_dimension/instance = access.get_instance_for_user(user)
	if(instance?.contains_turf(get_turf(user)))
		return access.leave_user(user)

	user.visible_message(span_notice("[user] starts climbing into [src]."), span_notice("I start climbing into [src]."))
	if(!do_after(user, climb_inside_delay, src))
		return TRUE
	if(QDELETED(src) || QDELETED(user))
		return TRUE

	access = get_pocket_access()
	if(!access)
		return TRUE
	var/datum/pocket_dimension/current_instance = access.get_instance_for_user(user)
	if(current_instance?.contains_turf(get_turf(user)))
		return TRUE

	if(!prepare_bag_for_folded_space(user, "climbing inside it"))
		return TRUE

	return access.enter_user(user)

/obj/item/storage/backpack/bag_of_holding/attack_self(mob/user, list/modifiers)
	if(get_pocket_access())
		return try_climb_inside(user)
	return ..()

/obj/item/storage/backpack/bag_of_holding/MouseDrop_T(atom/dropping, mob/user)
	if(dropping == user && ismob(dropping))
		try_climb_inside(user)
		return
	return ..()

/obj/item/storage/backpack/bag_of_holding/proc/store_item_in_pocket(obj/item/item_to_store, mob/user)
	if(!item_to_store || item_to_store == src)
		return FALSE

	if(item_to_store.GetComponent(/datum/component/pocket_access))
		to_chat(user, span_warning("The folded space inside [src] recoils from trying to swallow another pocket space."))
		return TRUE

	var/datum/component/pocket_access/access = get_pocket_access()
	if(!access)
		return FALSE

	if(!access.store_movable_for_user(user, item_to_store, get_turf(src)))
		to_chat(user, span_warning("[src] refuses to take [item_to_store]."))
		return TRUE

	user.visible_message(
		span_notice("[user] stuffs [item_to_store] into [src]."),
		span_notice("I stuff [item_to_store] into [src]."),
	)
	return TRUE

/obj/item/storage/backpack/bag_of_holding/proc/stuff_grabbed_mob(obj/item/grabbing/grab, mob/user)
	if(!grab || QDELETED(grab))
		return FALSE

	if(!ismob(grab.grabbed))
		to_chat(user, span_warning("I can stuff someone into [src] only if I'm holding onto them."))
		return TRUE

	var/mob/grabbed_mob = grab.grabbed
	if(grab.grab_state < GRAB_AGGRESSIVE)
		to_chat(user, span_warning("I need a firmer hold before I can stuff [grabbed_mob] into [src]."))
		return TRUE
	if(grabbed_mob == user)
		to_chat(user, span_warning("I think better of climbing headfirst into [src] that way."))
		return TRUE
	if(!prepare_bag_for_folded_space(user, "stuffing [grabbed_mob] into it"))
		return TRUE

	user.visible_message(
		span_warning("[user] starts stuffing [grabbed_mob] into [src]."),
		span_warning("I start stuffing [grabbed_mob] into [src]."),
	)
	if(!do_after(user, stuff_mob_delay, src))
		return TRUE
	if(QDELETED(src) || QDELETED(user) || QDELETED(grab) || QDELETED(grabbed_mob))
		return TRUE
	if(!grab.valid_check() || grab.grabbed != grabbed_mob || grab.grab_state < GRAB_AGGRESSIVE)
		to_chat(user, span_warning("[grabbed_mob] slips free before I can finish stuffing them into [src]."))
		return TRUE
	if(!Adjacent(user))
		to_chat(user, span_warning("I need to stay close to [src] to finish stuffing [grabbed_mob] inside."))
		return TRUE

	var/datum/component/pocket_access/access = get_pocket_access()
	if(!access)
		return FALSE

	if(!access.store_movable_for_user(user, grabbed_mob, get_turf(src)))
		to_chat(user, span_warning("[src] bucks and refuses to swallow [grabbed_mob]."))
		return TRUE

	user.visible_message(
		span_warning("[user] stuffs [grabbed_mob] into [src]!"),
		span_warning("I stuff [grabbed_mob] into [src]!"),
	)
	qdel(grab)
	return TRUE

/obj/item/storage/backpack/bag_of_holding/attackby(obj/item/I, mob/user, list/modifiers)
	if(istype(I, /obj/item/grabbing))
		return stuff_grabbed_mob(I, user)
	return store_item_in_pocket(I, user) || ..()
