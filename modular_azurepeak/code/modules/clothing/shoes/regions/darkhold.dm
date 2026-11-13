/obj/item/clothing/shoes/rare/grenzelhoft/freifechter
	name = "fencing boots"
	desc = "A pair of lightweight snugly fitting boots. They're reinforced along the toes and ankles and offer a measure of protection against missteps and glancing blows during close exchanges, often favoured by duelists and other itinerant swordsmen."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "freiboots"
	item_state = "freiboots"
	max_integrity = ARMOR_INT_SIDE_HARDLEATHER + 30
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/rare/grenzelhoft/freifechter/apply_components()
	. = ..()
	AddComponent(/datum/component/storage/concrete/boots)

/obj/item/clothing/shoes/rare/grenzelhoft/freifechter/loadout
	name = "aesthetic fencing boots"
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "freiboots"
	item_state = "freiboots"
	misc_flags = CRAFTING_TEST_EXCLUDE
