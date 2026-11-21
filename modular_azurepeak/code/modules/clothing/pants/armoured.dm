/obj/item/clothing/pants/platelegs/blacksteel
	name = "ancient blacksteel plate chausses"
	desc = "An antiquated set of alloyed chausses, guarded with thick blacksteel plates. When everyone else left, were you afraid? Did the empty houses and fields frighten you, because of what might've lurked in the darkness - or was it because you knew you had been left behind, and that you would never-again be able to catch up with the others? </br> </br>Suffer like me, and you will never know how this story might end."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "bklegs"
	item_state = "bklegs"
	armor_type = /datum/armor/ported/plate_bsteel
	max_integrity = ARMOR_INT_LEG_BLACKSTEEL
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/blacksteel
	ported_clothing = TRUE

/obj/item/clothing/pants/platelegs/blacksteel/modern
	name = "blacksteel plate chausses"
	desc = "Tasseted leggings of blacksteel, adorned with hooks to suspend both sabatons-and-faulds alike. Besilken trousers shepherd the maille, leaving the royal flesh unmarred by even the slightest of chafes-or-bruises. May its wearer never kneel again; be it in surrender or death."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "bplatelegs"
	item_state = "bplatelegs"

/obj/item/clothing/pants/platelegs/avantyne
	name = "avantyne-threaded fauldcoat"
	desc = "Tassets of threaded darksteel, worn atop a lesser waistcoat. The weightlessness of the alloy is born from its unholy imbuement; for lux invigorates metal far greater than even the purest ores."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "zizoplatelegs_med"
	max_integrity = ARMOR_INT_LEG_STEEL_PLATE
	armor_class = AC_MEDIUM
	armor_type = /datum/armor/ported/plate_bsteel
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/platelegs/zizo_ap
	name = "avantyne vestments"
	desc = "Vestments of avantyne, a black crystal said to be the frozen memory of a night that never ended. The faithful of Shar claim the Lady of Loss Herself wore such garments when the Netherese empire fell and its ashes still smouldered. </br>..and to think, it was all a war without reason."
	icon = 'modular_azurepeak/icons/clothing/pants.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/pants.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_pants.dmi'
	icon_state = "zizoplatelegs_med"
	max_integrity = ARMOR_INT_LEG_STEEL_PLATE
	armor_type = /datum/armor/ported/plate_bsteel
	armor_class = AC_MEDIUM
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/pants/platelegs/zizo_ap/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/item_equipped_movement_rustle, SFX_PLATE_STEP, 8)
