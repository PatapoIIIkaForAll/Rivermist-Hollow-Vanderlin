/obj/item/clothing/wrists/bracers/armharness
	name = "plate arm harness"
	desc = "A pair of interlocked steel plate arm harnesses, composed of pauldrons, rerebraces, couters, and vambraces - all snugly latched around the limb and secured to one another thanks to a series of leather straps, metal aglets, and sliding rivets. The engineering is so meticulous that flexibility of the limb is hardly impeded."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "armharness"
	item_state = "armharness"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/donator_steelpauldron
	name = "steel pauldrons"
	desc = "Oversized steel pauldrons that protect the forearms and upper-arms. Surprisingly protective and durable, but heavy...!"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "steelpauldron"
	item_state = "steelpauldron"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/ancient/armharness
	name = "decrepit plate arm harness"
	desc = "A frayed pair of interlocked bronze plate arm harnesses, composed of pauldrons, rerebraces, couters, and vambraces - all snugly latched around the limb and secured to one another thanks to a series of leather straps, metal aglets, and sliding rivets. The engineering is so meticulous that flexibility of the limb is hardly impeded."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "aarmharness"
	item_state = "aarmharness"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/bronze/armharness
	name = "bronze plate arm harness"
	desc = "A pair of interlocked bronze plate arm harnesses, composed of pauldrons, rerebraces, couters, and vambraces - all snugly latched around the limb and secured to one another thanks to a series of leather straps, metal aglets, and sliding rivets. The engineering is so meticulous that flexibility of the limb is hardly impeded."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "barmharness"
	item_state = "barmharness"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/iron/armharness
	name = "iron plate arm harness"
	desc = "A pair of interlocked iron plate arm harnesses, composed of pauldrons, rerebraces, couters, and vambraces - all snugly latched around the limb and secured to one another thanks to a series of leather straps, metal aglets, and sliding rivets. The engineering is so meticulous that flexibility of the limb is hardly impeded."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "iarmharness"
	item_state = "iarmharness"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/ancient/armharness_ap
	name = "ancient plate arm harness"
	desc = "A polished pair of interlocked gilbranze plate arm harnesses, composed of pauldrons, rerebraces, couters, and vambraces - all snugly latched around the limb and secured to one another thanks to a series of leather straps, metal aglets, and sliding rivets. The engineering is so meticulous that flexibility of the limb is hardly impeded."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "aarmharness"
	item_state = "aarmharness"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/allwrappings
	name = "wrappings"
	desc = "Strips of cloth, snuggly winding around your arms."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "nocwrappings"
	item_state = "nocwrappings"
	slot_flags = ITEM_SLOT_WRISTS
	sewrepair = TRUE
	ported_clothing = TRUE

/obj/item/clothing/wrists/allwrappings/scarlet
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "nocwrappings"
	item_state = "nocwrappings"
	color = CLOTHING_SCARLET
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/bronze
	name = "bronze wristguards"
	desc = "Padded with hide and cuffed to comfort the joints, these bronze plates fit perfectly around both forearms. Your fingers tingle with an unspoken purpose, as the bracers clasp into place; primordial, yet everclear."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "bronzebracers"
	body_parts_covered = ARMS | HANDS
	smeltresult = /obj/item/ingot/bronze
	armor_type = /datum/armor/ported/bronze
	max_integrity = 250
	ported_clothing = TRUE

/obj/item/clothing/wrists/bracers/cloth
	name = "cloth bracers"
	desc = "This shouldn't be used in code."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "nocwrappings"
	item_state = "nocwrappings"
	smeltresult = null
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_SIDE_STEEL
	blocksound = SOFTHIT
	anvilrepair = null
	sewrepair = TRUE
	pickup_sound = 'sound/foley/equip/equip_armor.ogg'
	equip_sound = 'sound/foley/equip/equip_armor.ogg'
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	armor_class = ARMOR_CLASS_NONE

/obj/item/clothing/wrists/bracers/hand
	name = "hand's bracers"
	desc = "Discretion had always been the better part of valour, and nobody understands that better than the one holding an ace up their sleeve."
	icon = 'modular_azurepeak/icons/clothing/special/hand.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "bracersheath"
	color = null
	armor_type = /datum/armor/maille
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/lirvas
	name = "lirvasi pauldrons"
	desc = "Oversized gold pauldrons that protect the forearms and upper-arms. Surprisingly protective and flashy, but heavy...!"
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "goldpauldron"
	sellprice = 20
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/cloth/gladiator
	name = "padded wrappings"
	desc = "Sheared burlap and cloth, meticulously fashioned around the forearms. Taut fibers turn weeping gashes into mere tears along the cloth. </br>"
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "nocwrappings"
	item_state = "nocwrappings"
	color = "#BFB8A9"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/leather/heavy
	name = "hardened leather bracers"
	desc = "A pair of heavy leather wristguards, deliciously darkened for deterring dangers."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "albracers"
	armor_type = /datum/armor/ported/leather
	max_integrity = ARMOR_INT_SIDE_STEEL
	salvage_amount = 1
	salvage_result = /obj/item/natural/hide/cured
	color = "#7f829d"
	dyeable = TRUE
	ported_clothing = TRUE
