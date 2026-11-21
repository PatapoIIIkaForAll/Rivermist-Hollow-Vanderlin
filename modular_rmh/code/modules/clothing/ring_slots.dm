/proc/ring_slot_screen_loc(index)
	var/static/list/screen_locs = list(rogueui_ring1, rogueui_ring2, rogueui_ring3, rogueui_ring4)
	return screen_locs[index]

/mob/proc/get_items_by_slot(slot_id)
	var/obj/item/item = get_item_by_slot(slot_id)
	return item ? list(item) : list()

/mob/proc/get_ring(index)
	return null

/mob/living/carbon/human/get_items_by_slot(slot_id)
	if(slot_id == ITEM_SLOT_RING)
		return get_worn_rings()
	return ..()

/mob/living/carbon/human/get_ring(index)
	if(!isnum(index) || index < 1 || index > RING_SLOTS)
		return null
	return wear_rings[index]

/mob/living/carbon/human/proc/get_worn_rings()
	. = list()
	for(var/obj/item/ring in wear_rings)
		. += ring

/mob/living/carbon/human/proc/get_free_ring_index()
	if(ring_slot_target)
		return wear_rings[ring_slot_target] ? 0 : ring_slot_target
	return wear_rings.Find(null)

/obj/item/update_transform()
	. = ..()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/wearer = loc
	if(src in wearer.wear_rings)
		transform = matrix(RING_SLOT_HUD_SCALE, 0, 0, 0, RING_SLOT_HUD_SCALE, 0)

/atom/movable/screen/inventory/ring
	name = "ring"
	icon_state = "ring"
	slot_id = ITEM_SLOT_RING
	transform = matrix(RING_SLOT_HUD_SCALE, 0, 0, 0, RING_SLOT_HUD_SCALE, 0)
	var/ring_index

/atom/movable/screen/inventory/ring/proc/aim_owner()
	var/mob/living/carbon/human/owner = hud?.mymob
	if(!istype(owner))
		return null
	. = owner.ring_slot_target
	owner.ring_slot_target = ring_index

/atom/movable/screen/inventory/ring/proc/release_owner(previous_target)
	var/mob/living/carbon/human/owner = hud?.mymob
	if(istype(owner))
		owner.ring_slot_target = previous_target

/atom/movable/screen/inventory/ring/Click(location, control, params)
	var/previous_target = aim_owner()
	. = ..()
	release_owner(previous_target)

/atom/movable/screen/inventory/ring/update_icon_state()
	var/previous_target = aim_owner()
	. = ..()
	release_owner(previous_target)

/atom/movable/screen/inventory/ring/add_overlays()
	var/previous_target = aim_owner()
	. = ..()
	release_owner(previous_target)

/datum/hud/human/proc/build_ring_slots(ui_style)
	for(var/index in 1 to RING_SLOTS)
		var/atom/movable/screen/inventory/ring/cell = new(null, src)
		cell.icon = ui_style
		cell.screen_loc = ring_slot_screen_loc(index)
		cell.ring_index = index
		static_inventory += cell
		ring_slots += cell

/mob/living/carbon/human/proc/show_rings_on_screen(mob/screenmob, shown)
	for(var/index in 1 to RING_SLOTS)
		var/obj/item/ring = wear_rings[index]
		if(!ring)
			continue
		if(shown)
			ring.screen_loc = ring_slot_screen_loc(index)
			screenmob.client.screen += ring
		else
			screenmob.client.screen -= ring

/obj/item/clothing/ring
	var/datum/status_effect/worn_effect_type
	var/datum/weakref/worn_effect_ref

/obj/item/clothing/ring/equipped(mob/living/user, slot)
	. = ..()
	clear_worn_effect()
	if(worn_effect_type && (slot & ITEM_SLOT_RING) && isliving(user) && user.mind)
		worn_effect_ref = WEAKREF(user.apply_status_effect(worn_effect_type, null, src))

/obj/item/clothing/ring/dropped(mob/user, silent)
	. = ..()
	clear_worn_effect()

/obj/item/clothing/ring/Destroy()
	clear_worn_effect()
	return ..()

/obj/item/clothing/ring/proc/clear_worn_effect()
	var/datum/status_effect/worn_effect = worn_effect_ref?.resolve()
	worn_effect_ref = null
	if(worn_effect && !QDELETED(worn_effect))
		qdel(worn_effect)

/datum/status_effect/buff/ravox/ring
	id = "ravoxbuff_ring"
	status_type = STATUS_EFFECT_MULTIPLE
	duration = -1

/datum/status_effect/buff/ravox/ring/on_creation(mob/living/new_owner, duration_override, obj/item/source)
	id = "[id]_[REF(source)]"
	return ..()

/datum/status_effect/buff/noc/ring
	id = "nocbuff_ring"
	status_type = STATUS_EFFECT_MULTIPLE
	duration = -1

/datum/status_effect/buff/noc/ring/on_creation(mob/living/new_owner, duration_override, obj/item/source)
	id = "[id]_[REF(source)]"
	return ..()

/datum/status_effect/buff/calm/ring
	id = "calm_ring"
	status_type = STATUS_EFFECT_MULTIPLE
	duration = -1

/datum/status_effect/buff/calm/ring/on_creation(mob/living/new_owner, duration_override, obj/item/source)
	id = "[id]_[REF(source)]"
	return ..()

/datum/status_effect/buff/calm/ring/on_remove()
	. = ..()
	if(!iscarbon(owner) || !(locate(/datum/status_effect/buff/calm) in owner.status_effects))
		return
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.add_stress(/datum/stress_event/calm)
