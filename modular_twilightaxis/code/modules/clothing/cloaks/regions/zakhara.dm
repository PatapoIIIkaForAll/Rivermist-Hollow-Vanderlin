/obj/item/clothing/cloak/catcloak
	name = "cataphracts cloak"
	desc = "Noble red cloak of a Zakharan Cataphract"
	icon = 'modular_twilightaxis/icons/clothing/desert/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/cloaks.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/desert/onmob/cloaks.dmi'
	icon_state = "catcloak"
	body_parts_covered = CHEST|GROIN|VITALS|ARMS
	sleevetype = "shirt"
	slot_flags = ITEM_SLOT_CLOAK
	sellprice = 50
	nodismemsleeves = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/dunestalker
	name = "dunestalker cloak"
	desc = "A heavy leather cloak held together by a gilded pin, depicting the Grand Sultan's house. The sign of a faithful servant."
	icon = 'modular_twilightaxis/icons/clothing/desert/shadowcloak.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/shadowcloak.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/desert/onmob/shadowcloak.dmi'
	icon_state = "shadowcloak"
	sleevetype = "shirt"
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	boobed = TRUE
	nodismemsleeves = TRUE
	inhand_mod = TRUE
	hoodtype = null
	toggle_icon_state = FALSE
	allowed_sex = list(MALE, FEMALE)
	flags_inv = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/citywatch/janissary
	name = "janissary cape"
	desc = "A light cloak held together by a gilded badge, depicting the Grand Sultan's house. The sign of a faithful servant."
	icon = 'modular_twilightaxis/icons/clothing/desert/shadowcloak.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/shadowcloak.dmi'
	sleeved = null
	icon_state = "jan"
	item_state = "jan"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/raincloak/amir
	name = "amir's cloak"
	desc = "A silky red cloak as light as a feather, embroidered with gold patterns. Fit for a prince of Zakhara."
	icon = 'modular_twilightaxis/icons/clothing/desert/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/cloaks.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/desert/onmob/cloaks.dmi'
	icon_state = "dprince"
	item_state = "dprince"
	sleevetype = "shirt"
	inhand_mod = FALSE
	hoodtype = /obj/item/clothing/head/hooded/rainhood/amirhood
	salvage_result = /obj/item/natural/silk
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/catcloak/jancap
	name = "janissary sergeant's cloak"
	desc = "A most handsome cloak, of royal red, denoting the authority of a leader."
	icon = 'modular_twilightaxis/icons/clothing/desert/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/desert/onmob/cloaks.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/desert/onmob/cloaks.dmi'
	icon_state = "catcloak"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/twilight_desert
	name = "desert cloak"
	desc = "This one will help against the dusty weather."
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	icon_state = "desert_cloak"
	item_state = "desert_cloak"
	color = CLOTHING_PURPLE
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	inhand_mod = TRUE
	hoodtype = /obj/item/clothing/head/hooded/desert_hood
	toggle_icon_state = FALSE
	detail_tag = "_detail"
	detail_color = CLOTHING_YARROW
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
