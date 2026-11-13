/obj/item/clothing/neck/bevor/blacksteel
	name = "ancient blacksteel neckguard"
	desc = "An antiquated bevor of blacksteel, unfettered in both pristineness and protection. What good comes from creation, if you never stop to savor it? </br>‎ </br>A lyfe with labor has meaning; a lyfe dedicated to labor, none."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "bsneckguardclassic"
	smeltresult = /obj/item/ingot/blacksteel
	armor_type = /datum/armor/ported/plate_bsteel
	max_integrity = ARMOR_INT_SIDE_BLACKSTEEL
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	ported_clothing = TRUE
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/neck/bevor/blacksteel/modern
	name = "blacksteel neckguard"
	desc = "A magnificent gorget of blacksteel, unfettered in both pristineness and protection. The alloyed plates covering the jawline are beheld to an ornate mechanism, allowing them to be easily retracted back into the gorget without issue."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "bsneckguard"
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/neck/bevor/zizo
	name = "avantyne bevor"
	desc = "An avantyne neckguard cut for the medium rite, still protective without becoming impossible to remove."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "zizobevor"
	item_state = "zizobevor"
	armor_class = AC_MEDIUM
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/neck/gorget/aventail
	name = "aventail"
	desc = "A thick garment of steel maille and padding, traditionally attached to bascinets. It's burdensome on the shoulders of those who aren't properly trained to wear knightly garments."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "aventailbase"
	body_parts_covered = NECK|MOUTH
	slot_flags = ITEM_SLOT_NECK
	max_integrity = ARMOR_INT_SIDE_STEEL + 50
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	armor_class = AC_MEDIUM
	armor_type = /datum/armor/maille
	blocksound = CHAINHIT
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE

/obj/item/clothing/neck/gorget/gold
	name = "golden gorget"
	desc = "A series of resplendant golden plates designed to protect the neck, traditionally worn atop a jacket or cuirass. The holy sigil between its buckled halves promises to carry the flame of its wearer, no matter what strike's poised its way."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "goldgorget"
	armor_class = AC_HEAVY
	armor_type = /datum/armor/blackbag
	max_integrity = 5
	anvilrepair = null
	smeltresult = /obj/item/ingot/gold
	grid_height = 96
	grid_width = 96
	ported_clothing = TRUE
