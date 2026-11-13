/obj/item/clothing/head/helmet/heavy/commandant
	name = "commandant's helmet"
	desc = "An old, battered helmet once worn by an officer of the Black Empire's Freikorps. Its scars bear witness to many campaigns."
	icon = 'modular_twilightaxis/icons/clothing/commandant_set.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/commandant_helmet.dmi'
	sleeved = null
	icon_state = "helmet"
	item_state = "helmet"
	worn_y_dimension = 32
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/visored/royalknight/nightmare
	name = "nightmare tears helmet"
	desc = ""
	icon = 'modular_twilightaxis/icons/clothing/nightmare_set.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/nightmare_set.dmi'
	sleeved = null
	icon_state = "nightmare_armet"
	item_state = "nightmare_armet"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	ported_adjust = TRUE
	adj_open_coverage = (HEAD|EARS|HAIR)
	adj_open_inv = (HIDEEARS|HIDEHAIR)
	adj_sound = 'sound/items/visor.ogg'
