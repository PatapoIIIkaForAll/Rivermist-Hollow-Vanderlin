/obj/structure/closet/crate/crafted_closet
	name = "closet"
	desc = ""
	icon = 'icons/roguetown/misc/structure.dmi'
	base_icon_state = "closet"
	icon_state = "closet"
	drag_slowdown = 4
	horizontal = FALSE
	allow_dense = FALSE
	open_sound = 'sound/foley/doors/creak.ogg'
	close_sound = 'sound/foley/latch.ogg'
	max_integrity = 200
	blade_dulling = DULLING_BASHCHOP
	dense_when_open = FALSE
	mob_storage_capacity = 2

/obj/structure/closet/crate/crafted_closet/inn/south
	base_icon_state = "closet3"
	icon_state = "closet3"
	dir = SOUTH
	SET_BASE_PIXEL(0, 16)

/obj/structure/closet/crate/crafted_closet/inn
	base_icon_state = "closet3"
	icon_state = "closet3"

/obj/structure/closet/crate/crafted_closet/inn/chest
	base_icon_state = "woodchest"
	icon_state = "woodchest"

/obj/structure/closet/crate/crafted_closet/dark
	base_icon_state = "closetdark"
	icon_state = "closetdark"

/obj/structure/closet/crate/crafted_closet/lord
	lock = /datum/lock/key/lord
	base_icon_state = "closetlord"
	icon_state = "closetlord"

/obj/structure/closet/crate/crafted_closet/atarms
	lock = /datum/lock/key/atarms
	base_icon_state = "closetdark"
	icon_state = "closetdark"

/obj/structure/closet/crate/crafted_closet/steward
	lock = /datum/lock/key/steward
	base_icon_state = "closetdark"
	icon_state = "closetdark"

/obj/structure/closet/crate/crafted_closet/magic
	name = "magic wardrobe"
	desc = "A wardrobe lined with impossible depth. Closing it feels like asking the room to swallow a secret."
	base_icon_state = "closet3"
	icon_state = "closet3"
	anchored = TRUE
	var/pocket_template = /datum/map_template/pocket/magic_closet
	var/pocket_lifecycle_policy = POCKET_LIFECYCLE_HIBERNATE
	var/pocket_idle_timeout = 2 MINUTES
	var/pocket_destroy_message = "The magic wardrobe folds flat, and its hidden room throws everything back out!"

/obj/structure/closet/crate/crafted_closet/magic/proc/get_pocket_instance_key()
	return "magic_closet::[REF(src)]"

/obj/structure/closet/crate/crafted_closet/magic/proc/get_pocket_instance()
	return SSpocket_dimensions?.get_instance(get_pocket_instance_key())

/obj/structure/closet/crate/crafted_closet/magic/proc/get_or_create_pocket_instance()
	return SSpocket_dimensions?.get_or_create_instance(get_pocket_instance_key(), pocket_template, pocket_lifecycle_policy, pocket_idle_timeout)

/obj/structure/closet/crate/crafted_closet/magic/proc/transport_closet_contents()
	var/datum/pocket_dimension/instance = get_or_create_pocket_instance()
	if(!instance)
		return FALSE

	var/turf/origin_turf = get_turf(src)
	var/list/staged_contents = contents.Copy()
	for(var/atom/movable/stored_movable as anything in staged_contents)
		if(QDELETED(stored_movable))
			continue

		if(ismob(stored_movable))
			var/mob/stored_mob = stored_movable
			if(!instance.enter_mob(stored_mob, origin_turf, src))
				return FALSE
			continue

		if(!instance.send_movable_inside(stored_movable, origin_turf, null, src))
			return FALSE

	return TRUE

/obj/structure/closet/crate/crafted_closet/magic/close(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(!length(contents))
		return TRUE

	if(transport_closet_contents())
		visible_message(span_notice("[src] snaps shut, and folded space swallows its contents."))
		return TRUE

	open()
	if(user)
		to_chat(user, span_warning("[src] refuses to settle into folded space right now."))
	return FALSE

/obj/structure/closet/crate/crafted_closet/magic/Destroy()
	if(SSpocket_dimensions)
		SSpocket_dimensions.delete_instance(get_pocket_instance_key(), pocket_destroy_message)
	return ..()

/obj/structure/closet/crate/crafted_closet/magic/dungeon
	name = "suspicious wardrobe"
	desc = "A wardrobe lined with impossible depth. You feel drawn to it."
	base_icon_state = "closetdark"
	icon_state = "closetdark"
	anchored = TRUE
	pocket_template = /datum/map_template/pocket/magic_closet/dungeon
	pocket_lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	pocket_destroy_message = "The wardrobe folds flat, and its hidden room throws everything back out!"
