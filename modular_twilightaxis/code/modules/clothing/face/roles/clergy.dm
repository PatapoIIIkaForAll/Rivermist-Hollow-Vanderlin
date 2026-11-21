/obj/item/clothing/face/ragmask/newmoon
	name = "Veiled Star mask"
	desc = "A mask woven from a silky, breathable fabric."
	icon = 'modular_twilightaxis/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/masks_2.dmi'
	sleeved = null
	icon_state = "ragmask"
	color = "#78a3c9"
	armor_type = /datum/armor/weak
	body_parts_covered = FACE
	alternate_worn_layer = NECK_LAYER
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/overarmor = TRUE

/obj/item/clothing/face/ragmask/newmoon/MiddleClick(mob/user, list/modifiers)
	overarmor = !overarmor
	to_chat(user, span_info("I [overarmor ? "wear \the [src] under my hair" : "wear \the [src] over my hair"]."))
	if(overarmor)
		alternate_worn_layer = NECK_LAYER //Below Hair Layer
	else
		alternate_worn_layer = BACK_LAYER //Above Hair Layer
	user.update_inv_wear_mask()

/obj/item/clothing/face/facemask/xylixmask
	name = "Tymoran mask"
	desc = "A ceramic mask, forever stuck with the joyful smile its patron god favors. While it will shatter easily from blows, its smug countenance shall taunt its foes."
	icon = 'modular_twilightaxis/icons/clothing/masks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "xylixmask"
	item_state = "xylixmask"
	max_integrity = 50
	armor_type = /datum/armor/none
	detail_tag = "_l"
	altdetail_tag = "_r"
	color = "#FFFFFF"
	detail_color = "#4756d8"
	altdetail_color = "#b8252c"
	smeltresult = null
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/steel/psythorns
	name = "mask of Aonic thorns"
	desc = "An expressionless steel mask, decorated with a set of blacksteel thorns. Never forget why the Overgod turned His face away from the gods."
	icon = 'modular_twilightaxis/icons/clothing/masks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "psybarbsmask"
	item_state = "psybarbsmask"
	smeltresult = /obj/item/ingot/blacksteel
	armor_type = /datum/armor/ported/plate_bsteel
	blocksound = PLATEHIT
	resistance_flags = FIRE_PROOF
	max_integrity = ARMOR_INT_SIDE_BLACKSTEEL
	body_parts_covered = FACE|HAIR|HEAD
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/blindfold_ap/psydon
	name = "blessed blindfold"
	desc = "You will not conquer. You will endure. In pain, you affirm the Architect's design."
	icon = 'modular_twilightaxis/icons/clothing/masks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "psyblindfold"
	item_state = "psyblindfold"
	tint = 1
	misc_flags = CRAFTING_TEST_EXCLUDE
