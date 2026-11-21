/obj/item/clothing/ring/statamythortz
	name = "ring of wisdom"
	desc = "A saffira ring, crackling with Duskmarian fascination. The closer your hand drifts to it, the clearer your mind becomes."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_newring_sapphire"
	sellprice = 222
	var/active_item = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/statamythortz/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	else if((slot & ITEM_SLOT_RING))
		active_item = TRUE
		to_chat(user, span_rose("'..the way of knowledge, cursing its pursuers with inzanity..'"))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_INT) = 1, (STATKEY_PER) = 1))
	return

/obj/item/clothing/ring/statamythortz/dropped(mob/living/user, silent = FALSE)
	..()
	if(active_item)
		to_chat(user, span_rose("'..but if we root ourselves in the thoughtless, how else will we progress?'"))
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		active_item = FALSE
	return

/obj/item/clothing/ring/statamythortz/antiquarian
	desc = "A saffira ring, crackling with Duskmarian fascination. The closer your hand drifts to it, the clearer your mind becomes. The precious stone has chipped with long use, and is quite worthless except in its magick."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_newring_sapphire"
	sellprice = 30
	misc_flags = CRAFTING_TEST_EXCLUDE
