/obj/item/clothing/wrists/bracers/brigandine/black
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "splintarms"
	item_state = "splintarms"
	color = CLOTHING_BLACK
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/blacksteel
	name = "ancient blacksteel bracers"
	desc = "Antiquated wristguards of blacksteel, forgotten-yet-enduring after all this time. Who are you to know what awaits after lyfe, so fleeting yet fascinating? </br> </br>Only the first tyme around is free; make the most of it, however you see fit."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "bsbracersclassic"
	smeltresult = /obj/item/ingot/blacksteel
	armor_type = /datum/armor/ported/plate_bsteel
	max_integrity = ARMOR_INT_SIDE_BLACKSTEEL
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	ported_clothing = TRUE

/obj/item/clothing/wrists/bracers/blacksteel/modern
	name = "blacksteel bracers"
	desc = "Alloyed plate bracers, meticulously assembled from blacksteel. Besilked straps peek out from both ends; soft enough to barely impede finer movements, while still strong enough to lock a pair of accompying gauntlets-and-couters into place."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "bsbracers"

/obj/item/clothing/wrists/bracers/brigandine
	name = "brigandine rerebraces"
	desc = "Brigandine bracers, pauldrons and a set of metal couters, designed to protect the arms while still providing almost complete free range of movement."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "splintarms"
	item_state = "splintarms"
	body_parts_covered = ARMS
	armor_type = /datum/armor/brigandine
	blocksound = SOFTHIT
	max_integrity = ARMOR_INT_SIDE_STEEL
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/steel
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	sewrepair = FALSE
	ported_clothing = TRUE

/obj/item/clothing/wrists/bracers/chain
	name = "chain sleeves"
	desc = "Coverings of steel maille, fashioned from hundreds of interlinked rings. An aura of inexplicable harlotry eminates from these sleeves. </br>I can adjust these sleeves to hang further down, rather than simply hugging my wrists."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "chainsleevesalt"
	item_state = "chainsleevesalt"
	blocksound = CHAINHIT
	armor_type = /datum/armor/maille
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	var/wrapped = FALSE
	ported_clothing = TRUE

/obj/item/clothing/wrists/bracers/chain/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!wrapped)
		icon_state = "chainsleeves"
		item_state = "chainsleeves"
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = TRUE
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = FALSE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/wrists/bracers/gold
	name = "golden bracers"
	desc = "A resplendant pair of golden vambraces, further padded with besilked sleeves. Each halve is marked with a holy sigil, sloped upwards to help catch-and-reflect sunlight into the eyes of unsuspecting assailants."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "goldbracers"
	item_state = "goldbracers"
	body_parts_covered = ARMS | HANDS
	armor_class = AC_HEAVY
	armor_type = /datum/armor/blackbag
	max_integrity = 5
	anvilrepair = null
	smeltresult = /obj/item/ingot/gold
	grid_height = 96
	grid_width = 96
	ported_clothing = TRUE

/obj/item/clothing/wrists/bracers/splint
	name = "splint bracers"
	desc = "A pair of leather sleeves backed with iron splints, couters, and shoulderpieces that protect your arms and remain decently light."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "ironsplintarms"
	item_state = "ironsplintarms"
	body_parts_covered = ARMS
	armor_type = /datum/armor/brigandine
	blocksound = SOFTHIT
	max_integrity = ARMOR_INT_SIDE_IRON
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/iron
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	sewrepair = FALSE
	ported_clothing = TRUE

/obj/item/clothing/wrists/bracers/zizo
	name = "avantyne bracers"
	desc = "Clasped yet practical, these avantyne wristguards are reinforced for the rite without binding themselves to the wearer forever."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "zizobracers"
	item_state = "zizobracers"
	max_integrity = ARMOR_INT_SIDE_STEEL
	armor_class = AC_MEDIUM
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/ancient/chain
	name = "decrepit chain sleeves"
	desc = "Coverings of rotted metal maille, fashioned from hundreds of interlinked rings. An aura of decaying harlotry eminates from these sleeves. </br>I can adjust these sleeves to hang further down, rather than simply hugging my wrists."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "ancientchainsleevesalt"
	item_state = "ancientchainsleevesalt"
	blocksound = CHAINHIT
	armor_type = /datum/armor/maille
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	var/wrapped = FALSE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/wrists/bracers/ancient/chain/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!wrapped)
		icon_state = "ancientchainsleeves"
		item_state = "ancientchainsleeves"
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = TRUE
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = FALSE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/wrists/bracers/bronze/chain
	name = "bronze chain sleeves"
	desc = "Coverings of bronze maille, fashioned from hundreds of interlinked rings. An aura of antiqual harlotry eminates from these sleeves. </br>I can adjust these sleeves to hang further down, rather than simply hugging my wrists."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "bchainsleevesalt"
	item_state = "bchainsleevesalt"
	blocksound = CHAINHIT
	armor_type = /datum/armor/ported/bronze
	body_parts_covered = ARMS
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	var/wrapped = FALSE

/obj/item/clothing/wrists/bracers/bronze/chain/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!wrapped)
		icon_state = "bchainsleeves"
		item_state = "bchainsleeves"
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = TRUE
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = FALSE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/wrists/bracers/iron/chain
	name = "iron chain sleeves"
	desc = "Coverings of iron maille, fashioned from hundreds of interlinked rings. An aura of traditional harlotry eminates from these sleeves. </br>I can adjust these sleeves to hang further down, rather than simply hugging my wrists."
	icon = 'modular_azurepeak/icons/clothing/wrists.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	icon_state = "ichainsleevesalt"
	item_state = "ichainsleevesalt"
	blocksound = CHAINHIT
	armor_type = /datum/armor/maille
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	pickup_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	var/wrapped = FALSE
	ported_clothing = TRUE

/obj/item/clothing/wrists/bracers/iron/chain/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!wrapped)
		icon_state = "ichainsleeves"
		item_state = "ichainsleeves"
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = TRUE
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		user.update_inv_wrists()
		user.update_inv_gloves()
		user.update_inv_armor()
		user.update_inv_shirt()
		playsound(user, 'modular_azurepeak/sound/foley/equip/chain_equip.ogg', 50, TRUE)
		wrapped = FALSE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
