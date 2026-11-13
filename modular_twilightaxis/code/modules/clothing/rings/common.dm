/obj/item/clothing/ring/event_ring
	name = "event ring"
	desc = "A customizable ring for events; editable via VV (stat_mods, traits)."
	icon = 'modular_twilightaxis/icons/clothing/rings_2.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/rings_2.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/rings_2.dmi'
	icon_state = "g_newring_emerald"
	sellprice = 0
	var/list/stat_mods = list( list(STATKEY_STR, 1), list("willpower", 1), list(STATKEY_CON, 1), list(STATKEY_PER, 1), list(STATKEY_INT, 1), list(STATKEY_LCK, 1), list(STATKEY_SPD, 1) )
	var/list/traits = list(TRAIT_NOBLE)
	var/equip_message = "You feel the ring's power settle upon you."
	var/active_item = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/event_ring/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	else if((slot & ITEM_SLOT_RING))
		active_item = TRUE
		if(stat_mods && stat_mods.len)
			for(var/mod in stat_mods)
				if(islist(mod) && length(mod) >= 2)
					user.adjust_stat_modifier("ported_equip_[REF(src)]", mod[1], mod[2])
		if(traits && traits.len)
			for(var/t in traits)
				ADD_TRAIT(user, t, REF(src))
		if(equip_message)
			to_chat(user, span_green(equip_message))
	return

/obj/item/clothing/ring/event_ring/dropped(mob/living/user, silent = FALSE)
	..()
	if(active_item)
		if(stat_mods && stat_mods.len)
			for(var/mod in stat_mods)
				if(islist(mod) && length(mod) >= 2)
					user.remove_stat_modifier("ported_equip_[REF(src)]")
		if(traits && traits.len)
			for(var/t in traits)
				REMOVE_TRAIT(user, t, REF(src))
		active_item = FALSE
	return

/obj/item/clothing/ring/event_ring/proc/clear_stat_mods()
	stat_mods = list()

/obj/item/clothing/ring/event_ring/proc/clear_traits()
	traits = list()
