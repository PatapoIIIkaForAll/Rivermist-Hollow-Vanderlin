/obj/item/clothing/head/helmet/heavy/vampire_ap
	name = "ancient ceremonial sayovard"
	desc = "A grand bascinet of enchanted gilbranze. They erased you from history, they destroyed your kingdom, and they plucked at its remains like vultures-to-carrion. Yet now, they cower in fear of your second coming; for they know that even the Pantheon cannot stop what is coming. </br>Send word - the end is nigh."
	icon = 'modular_azurepeak/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/head.dmi'
	sleeved = null
	icon_state = "vhelmet"
	max_integrity = ARMOR_INT_HELMET_ANTAG
	armor_type = /datum/armor/blackbag
	block2add = FOV_BEHIND
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/active_item = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/vampire_ap/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#8B0000", "alpha" = 180, "size" = 1)) //Enchanted look.

/obj/item/clothing/head/helmet/heavy/vampire_ap/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	if((slot & ITEM_SLOT_HEAD))
		active_item = TRUE
		ADD_TRAIT(user, TRAIT_BITERHELM, REF(src))
		to_chat(user, span_warning("The bascinet's visor chitters, and your jaw tightens with symbiotic intent.."))

/obj/item/clothing/head/helmet/heavy/vampire_ap/dropped(mob/user, silent = FALSE)
	..()
	if(!active_item)
		return
	active_item = FALSE
	REMOVE_TRAIT(user, TRAIT_BITERHELM, REF(src))
	to_chat(user, span_warning("..and like that, the bascinet's visor goes dormant once more - a strange pressure, relieved from your jaw."))
