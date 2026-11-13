/obj/item/clothing/shirt/undershirt/artificer/donator_thistle
	name = "underdwelling artificer's shirt"
	desc = "Soft fabrics, interwoven to cradle both the bosom and neck. Colloquially termed as a 'turtleneck', both due to its coverage and the fact that only those of shorter stature can properly wear it. It almost feels like wearing nothing at all.. <i>nothing at all!</i>"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "thistleturtleneck"
	adjustable = CANT_CADJUST
	toggle_icon_state = TRUE
	allowed_sex = list(FEMALE)
	ported_adjust = TRUE
	adj_open_coverage = (CHEST|VITALS)
	adj_sound = 'sound/foley/cloth_wipe (1).ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/freifechter
	name = "fencing shirt"
	desc = "A strong loosely worn quilted shirt that places little weight on the arms, usually worn underneath a flexible leather vest. It won't cover your legs."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "fencingshirt"
	body_parts_covered = (( CHEST | GROIN | VITALS | ARMS))
	color = "#FFFFFF"
	var/shiftable = FALSE
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 30
	blocksound = SOFTUNDERHIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	sewrepair = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/freifechter/loadout
	name = "aesthetic fencing shirt"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "fencingshirt"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
