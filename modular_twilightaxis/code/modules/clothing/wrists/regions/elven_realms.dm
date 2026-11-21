/obj/item/clothing/wrists/bracers/twilight_elven
	name = "elven rider bracers"
	desc = "Elegant steel bracers, meant to protect the wearer's wrists from cutting attacks. Their sleek design marks them as a product of elven craftsmanship."
	icon = 'modular_twilightaxis/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/gloves_2.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/gloves_2.dmi'
	icon_state = "elven_armplates"
	item_state = "elven_armplates"
	allowed_race = SPECIES_BASE_BODY
	alternate_worn_layer = WRISTS_LAYER
	ported_clothing = TRUE

/obj/item/clothing/wrists/bracers/twilight_elven/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	user.update_inv_wrists()
	user.update_inv_gloves()
	user.update_inv_armor()
	user.update_inv_shirt()
