/obj/item/clothing/shirt/robe/spellcasterrobe/soundbreakerrobe
	name = "soundbreaker robes"
	desc = "A set of reinforced, leather-padded robes worn by soundbreakers."
	icon = 'modular_twilightaxis/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/armor.dmi'
	sleeved = null
	icon_state = "soundbreaker"
	slot_flags = ITEM_SLOT_ARMOR
	color = CLOTHING_RED
	body_parts_covered = CHEST | GROIN | LEGS | ARMS
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/robe/bishop
	name = "bishop robe"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/shirts.dmi'
	icon_state = "bishop_robe"
	item_state = "bishop_robe"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = CHEST|GROIN|VITALS
	flags_inv = HIDEBOOB|HIDECROTCH
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/ported/padded
	color = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/bishop/equipped(mob/user, slot, initial = FALSE)
	..()
	if(!(slot & (ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT)))
		return
	to_chat(user, span_notice("With my vows to poverty and my vestments, I feel vigorous - empowered by my God!"))

/obj/item/clothing/shirt/robe/bishop/dropped(mob/user, silent = FALSE)
	..()
	to_chat(user, span_notice("I must lay down my robes and rest; even God's chosen must rest.."))
