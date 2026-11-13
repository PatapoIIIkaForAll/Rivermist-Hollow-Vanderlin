/obj/item/clothing/armor/brigandine/gronn
	name = "Uthgardt byrine hauberk"
	desc = "A chain shirt of Uthgardt design with a leather coat layered over, offering additional protection and superior movement. It is often used by sea raiders."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/gronn.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gronnchain"
	item_state = "gronnchain"
	smeltresult = /obj/item/ingot/iron
	armor_type = /datum/armor/maille
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/gronn
	name = "Uthgardt ravager mantle"
	desc = "A carefully made mantle of bone and hardened leather, offering superior protection against the threats of the wild while remaining light. Uthgardt warriors often adorn one shoulder with a wolf pelt and skull, so that a great beast is always with them."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/gronn.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gronnleatherarmor"
	item_state = "gronnleatherarmor"
	armor_type = /datum/armor/ported/leather
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/iron/gronn
	name = "Uthgardt norsii iron plate"
	desc = "A suit of solid iron plate, adorned with tassets and roundels. The Northmen of Uthgardt rarely used plate, but when they did, it is said that whole armies would quake and shake in fear of what would ravage them."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/gronn.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gronnplate"
	item_state = "gronnplate"
	boobed = FALSE
	body_parts_covered = (( CHEST | GROIN | VITALS | ARMS))
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	smeltresult = /obj/item/ingot/iron
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
