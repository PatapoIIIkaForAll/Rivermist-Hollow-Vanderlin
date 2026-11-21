/obj/item/clothing/face/facemask/goldmask/radiant
	name = "radiant gold mask"
	desc = "A ceremonial mask that mimics Lathander's solar might. Relics like these were once commonplace across the Holy See's plains, as garments to be worn by village-acolytes during the summer solstice's many festivals. Nowadaes, they're a rare sight to see - at least, beyond the hands of wandering zealots and priests."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "radiantgoldmask"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/steel/maille/birdmask
	name = "beaked mask"
	desc = "A plated steel mask made to resemble a bird's beak.<br> While similar to the long masks of Ilmater's faithful, this is designed to protect against far less insidious dangers. Namely, bladed weapons.<br> <font color='3399FF'>'The magpie's song, a fleeting flight, guides the heart through the encroaching night.'</font>"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "birdmask"
	misc_flags = CRAFTING_TEST_EXCLUDE
	adjustable = CANT_CADJUST

/obj/item/clothing/face/facemask/steel/maille/birdmask/Initialize(mapload)
	. = ..()
	pass() // *flips the bird at you* (this isnt meant to be adjustable)

/obj/item/clothing/face/wildguard
	name = "wild guard"
	desc = "A mask shaped after the snarling beasts of Silvanus."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "wildguard"
	blocksound = PLATEHIT
	break_sound = 'sound/foley/breaksound.ogg'
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	max_integrity = 100
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/plate
	flags_inv = HIDEFACE
	body_parts_covered = FACE
	block2add = FOV_BEHIND
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HIP
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/iron
	ported_clothing = TRUE

/obj/item/clothing/face/xylixmask/weathered
	name = "weathered mask"
	desc = "An ancient ceramic face. It looks weathered, the sort molded by Tymoran worshippers of many yils past. Even when cast aside, it feels like the hardened clay has never left your hands. As if it always finds a way back into your palms."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "xylix_weathered"
	item_state = "xylix_weathered"
	max_integrity = 200
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/steel/ancient/rosemask
	name = "rosestone mask"
	desc = "A rosestone mask that both conceals and protects the face. It mimics the guise of a contemplative monk."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "mask_rose"
	ported_clothing = TRUE

/obj/item/clothing/face/facemask/steel/visor/cleric
	name = "clerical helmetless visor"
	desc = "A thin visor of flimsy iron with a silver coating, etched with faint runic wards. It offers barely any protection, but the Mystran cults of Faerun claim that its gaps let the light of the Weave enlighten the mind."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "helmetless_visor"
	misc_flags = CRAFTING_TEST_EXCLUDE
