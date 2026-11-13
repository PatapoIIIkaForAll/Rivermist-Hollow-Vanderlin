/obj/item/clothing/head/octopus
	name = "octopus hat"
	desc = "A deep red, slimy cephalopod that clings to your scalp. Its tentacles can be adjusted."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "octopus"
	adjustable = CAN_CADJUST
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	body_parts_covered = HEAD|EARS|HAIR
	armor_type = /datum/armor/none
	resistance_flags = FIRE_PROOF
	sellprice = 30
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEFACE|HIDEHAIR)

/obj/item/clothing/head/octopus/MiddleClick(mob/user, list/modifiers)
	if(!ishuman(user))
		return
	if(flags_inv & HIDEHAIR)
		flags_inv &= ~HIDEHAIR
		to_chat(user, span_info("You pull your hair out from under the [src]."))
	else
		flags_inv |= HIDEHAIR
		to_chat(user, span_info("You tuck your hair under the [src]."))
	user.update_inv_head()

/obj/item/clothing/head/duelhat/pretzel
	name = "rethrifted gravedigger's hat"
	desc = "A gravetender's dark leather slouch, refitted with a golden dragon-sigil. Who needs a steel skullcap when you have dumb luck? <br> \"You ever feel like nothin' good was ever gonna happen to you?\" <br> \"Yeah, and nothin' did. So what?\""
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "pretzel_stolenhat"
	item_state = "pretzel_stolenhat"
	color = null
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/archercap
	name = "archer's cap"
	desc = "For the merry men."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = null
	icon_state = "archercap"
	ported_clothing = TRUE

/obj/item/clothing/head/cap
	name = "cap"
	desc = "A light cap made of cloth, usually worn under a helmet."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "armingcap"
	item_state = "armingcap"
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HEAD
	flags_inv = HIDEEARS
	sewrepair = TRUE
	ported_clothing = TRUE

/obj/item/clothing/head/duelhat
	name = "duelist's hat"
	desc = "A feathered leather hat, to show them all your superiority."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = null
	icon_state = "duelhat"
	sewrepair = TRUE
	color = COLOR_ALMOST_BLACK
	detail_tag = "_detail"
	detail_color = COLOR_SILVER
	ported_clothing = TRUE

/obj/item/clothing/head/fedora
	name = "archeologist's hat"
	desc = "A strangely-shaped hat with dust caked onto its aged leather."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = null
	icon_state = "curator"
	item_state = "curator"
	sewrepair = TRUE
	salvage_result = /obj/item/natural/hide/cured
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/flamboyant
	name = "flamboyant hat"
	desc = "A luxurious purple feathered hat with wide brim."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "flamboyant"
	item_state = "flamboyant"
	sewrepair = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/flathat
	name = "flat hat"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = null
	icon_state = "flathat"
	item_state = "flathat"
	sewrepair = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/smokingcap
	name = "smoking cap"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = null
	sleeved = null
	icon_state = "smokingc"
	sewrepair = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/rosa/five
	name = "sable hat"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = null
	icon_state = "rosahat5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/rosa/four
	name = "obsidian hat"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = null
	icon_state = "rosahat4"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/rosa/six
	name = "maroon cap"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = null
	icon_state = "rosahat6"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/rosa/three
	name = "velvet hat"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = null
	icon_state = "rosahat3"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/armingcap_ap
	name = "arming cap"
	desc = "A modest arming cap. It will stop a light blow."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "armingcap"
	item_state = "armingcap"
	sleevetype = null
	body_parts_covered = HEAD|HAIR|EARS
	slot_flags = ITEM_SLOT_MASK|ITEM_SLOT_HEAD
	armor_type = /datum/armor/robe/mage
	blocksound = SOFTHIT
	max_integrity = ARMOR_INT_HELMET_CLOTH
	color = "#463C2B"
	sewrepair = TRUE
	salvage_result = /obj/item/natural/fibers
	salvage_amount = 2
	ported_clothing = TRUE

/obj/item/clothing/head/armingcap_ap/padded
	name = "padded arming cap"
	desc = "A padded up arming cap. It might even stop a mace!"
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "paddedarmingcap"
	item_state = "paddedarmingcap"
	armor_type = /datum/armor/ported/padded
	max_integrity = ARMOR_INT_HELMET_CLOTH + 60
	dyeable = TRUE
