/obj/item/clothing/head/helmet/pony_harness
	name = "pony harness gag"
	desc = "A leather muzzle-harness with a gag piece. Talking becomes a suggestion."
	icon = 'modular_twilightaxis/icons/clothing/erp_cloth.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/erp_cloth.dmi'
	sleeved = null
	icon_state = "hbit"
	item_state = "hbit"
	sewrepair = TRUE
	salvage_amount = 1
	salvage_result = /obj/item/natural/hide/cured
	smeltresult = null
	armor_type = /datum/armor/none
	ported_clothing = TRUE

/obj/item/clothing/head/helmet/pony_harness/Initialize(mapload)
	. = ..()
	flags_inv |= HIDEMASK
