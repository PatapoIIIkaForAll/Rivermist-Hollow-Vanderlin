/obj/item/clothing/shoes/boots/tabi/otavan/inqboots
	name = "inquisitorial tabis"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "river_otavatabi"
	item_state = "river_otavatabi"
	color = null
	armor_type = /datum/armor/plate
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/otavan/inqboots/heels
	name = "inquisitorial heels"
	desc = "Elegantly crafted heeled boots inlaid with silver clasps and blacksteel. They clack rhythmically with every stride, made to stomp out darkness."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "inqheels"
	item_state = "inqheels"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	heeled = TRUE

/obj/item/clothing/shoes/otavan/inqboots/heels/apply_components()
	. = ..()
	AddComponent(/datum/component/storage/concrete/boots)
