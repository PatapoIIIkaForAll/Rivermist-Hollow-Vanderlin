/proc/ring_slot_screen_loc(index)
	var/static/list/screen_locs = list(rogueui_ring1, rogueui_ring2, rogueui_ring3, rogueui_ring4)
	return screen_locs[index]

/// Bonus of the stack_rank-th worn ring of one type: halved for each earlier ring, rounded up, at least 1.
/proc/ring_stack_bonus(amount, stack_rank)
	if(amount <= 0 || stack_rank <= 1)
		return amount
	return max(1, CEILING(amount / (2 ** (stack_rank - 1)), 1))

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
	if(!isnum(index) || !ISINRANGE(index, 1, RING_SLOTS))
		return null
	return wear_rings[index]

/mob/living/carbon/human/proc/get_worn_rings()
	. = list()
	for(var/obj/item/ring in wear_rings)
		. += ring

/mob/living/carbon/human/proc/get_free_ring_index()
	return wear_rings.Find(null)

/// Puts an item on the finger at index. Returns TRUE if it was put on.
/mob/living/carbon/human/proc/equip_ring_to_index(obj/item/ring, index)
	if(!equip_to_slot_if_possible(ring, ITEM_SLOT_RING, FALSE, FALSE, FALSE))
		return FALSE
	// Equipping takes the first free finger; move the ring to the chosen one if it is still free.
	var/current_index = wear_rings.Find(ring)
	if(current_index && current_index != index && ISINRANGE(index, 1, RING_SLOTS) && !wear_rings[index])
		wear_rings.Swap(current_index, index)
		update_inv_ring()
		refresh_ring_bonuses()
	return TRUE

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

/atom/movable/screen/inventory/ring/get_slot_item()
	var/mob/owner = hud?.mymob
	return owner?.get_ring(ring_index)

/atom/movable/screen/inventory/ring/Click(location, control, params)
	var/mob/living/carbon/human/owner = hud?.mymob
	if(!istype(owner) || usr != owner || get_slot_item())
		return ..()
	if(world.time <= owner.next_move || owner.incapacitated(IGNORE_GRAB))
		return TRUE
	if(!owner.has_hand_for_held_index(owner.active_hand_index))
		return TRUE
	var/obj/item/held = owner.get_active_held_item()
	if(held && owner.equip_ring_to_index(held, ring_index))
		owner.update_inv_hands()
	return TRUE

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
	/// Status effect while worn on a finger. Only the first worn ring of a type applies it.
	var/datum/status_effect/worn_effect_type
	var/datum/weakref/worn_effect_ref
	/// Stat bonuses while worn on a finger, stat = amount. Each further worn ring of the same type gives half as much as the one before it, at least 1.
	var/list/worn_stats

/obj/item/clothing/ring/Destroy()
	clear_worn_effect()
	return ..()

/obj/item/clothing/ring/proc/apply_worn_bonus(mob/living/wearer, stack_rank)
	if(length(worn_stats))
		var/list/stats = list()
		for(var/stat in worn_stats)
			stats[stat] = ring_stack_bonus(worn_stats[stat], stack_rank)
		wearer.set_stat_modifier(worn_stat_source(), stats)
	if(worn_effect_type && stack_rank == 1 && !worn_effect_ref?.resolve())
		worn_effect_ref = WEAKREF(wearer.apply_status_effect(worn_effect_type))

/obj/item/clothing/ring/proc/remove_worn_bonus(mob/living/wearer)
	wearer.remove_stat_modifier(worn_stat_source())
	clear_worn_effect()

/obj/item/clothing/ring/proc/worn_stat_source()
	return "worn_ring_[REF(src)]"

/obj/item/clothing/ring/proc/clear_worn_effect()
	var/datum/status_effect/worn_effect = worn_effect_ref?.resolve()
	worn_effect_ref = null
	if(worn_effect && !QDELETED(worn_effect))
		qdel(worn_effect)

/// Re-applies the bonuses of all worn rings. Rings of one type are ranked in finger order.
/mob/living/carbon/human/proc/refresh_ring_bonuses()
	var/list/ring_ranks = list()
	var/list/worn_counts = list()
	for(var/obj/item/clothing/ring/ring in wear_rings)
		worn_counts[ring.type] += 1
		ring_ranks[ring] = worn_counts[ring.type]
	// Demoted rings drop their effect first, so the new first ring of the type can apply its own.
	for(var/obj/item/clothing/ring/ring as anything in ring_ranks)
		if(ring_ranks[ring] > 1)
			ring.clear_worn_effect()
	for(var/obj/item/clothing/ring/ring as anything in ring_ranks)
		ring.apply_worn_bonus(src, ring_ranks[ring])

/mob/living/carbon/human/proc/on_ring_removed(obj/item/ring)
	if(istype(ring, /obj/item/clothing/ring))
		var/obj/item/clothing/ring/clothing_ring = ring
		clothing_ring.remove_worn_bonus(src)
	if(!QDELETED(src))
		refresh_ring_bonuses()

// Ring effects carry no stats: the ring applies its own worn_stats.

/datum/status_effect/buff/ravox/ring
	id = "ravoxbuff_ring"
	duration = -1
	effectedstats = null

/datum/status_effect/buff/noc/ring
	id = "nocbuff_ring"
	duration = -1
	effectedstats = null

/datum/status_effect/buff/calm/ring
	id = "calm_ring"
	duration = -1
	effectedstats = null

/datum/status_effect/buff/calm/ring/on_remove()
	. = ..()
	if(!iscarbon(owner) || !(locate(/datum/status_effect/buff/calm) in owner.status_effects))
		return
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.add_stress(/datum/stress_event/calm)
