/obj/item/clothing/pants/chainlegs/nightmare
	name = "nightmare tears chausses"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/nightmare_set.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/nightmare_set.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "nightmare_chausses"
	item_state = "nightmare_chausses"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/chainlegs/twilight_drow
	name = "scourge chain chausses"
	desc = "The Dark Elves rarely don chainmail, preferring much more comfortable leathers and spider silk. Still, it is not unheard of, especially among the shock troops embedded with the raiding parties that venture into the surface world."
	icon = 'modular_twilightaxis/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "shadowchains"
	item_state = "shadowchains"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/gambeson
	name = "gamboised cuisses"
	desc = "A heavy fabric trousers, stuffed with padding. Protect the legs from blows and weather. Worn under armor or alone."
	icon = 'modular_twilightaxis/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "gambeson"
	body_parts_covered = GROIN|LEGS|FEET
	slot_flags = ITEM_SLOT_PANTS
	armor_type = /datum/armor/ported/padded
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	color = "#ad977d"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	armor_class = AC_LIGHT
	ported_clothing = TRUE

/obj/item/clothing/pants/gambeson/heavy
	name = "padded gamboised cuisses"
	desc = "A thick, padded cloth trousers, worn beneath armor. A warriors first defense - simple, humble, but vital against bruises and cold."
	icon = 'modular_twilightaxis/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "gambesonp"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	color = "#976E6B"
	dyeable = TRUE
