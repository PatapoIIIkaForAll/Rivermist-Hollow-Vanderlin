/obj/item/clothing/cloak/citywatch
	mob_overlay_icon = null
	sleeved = null
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/cloak/citywatch

/obj/item/clothing/cloak/commandant
	name = "commandant's cloak"
	desc = "A distinguished military cloak in the austere style of the Black Empire, worn by officers who have earned the right to stand above the rank and file."
	icon = 'modular_twilightaxis/icons/clothing/commandant_set.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/commandant_set.dmi'
	sleeved = null
	icon_state = "raincoat"
	item_state = "raincoat"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/sheriff
	name = "sheriff's cloak"
	desc = "A cape embroidered with the silver heraldry of the Watch."
	icon = 'modular_twilightaxis/icons/clothing/special/citywatch_armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/special/onmob/citywatch_armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/special/onmob/citywatch_armor.dmi'
	icon_state = "sheriffcloak"
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/lepoardcloak
	name = "leopard pelt cloak"
	desc = "This regal cloak is made from the pelt of an Sembian Leopard. It's worn by soldiers of great prestige and renown."
	icon = 'modular_twilightaxis/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/cloaks.dmi'
	sleeved = null
	icon_state = "lepoardcape"
	inhand_mod = FALSE
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	salvage_result = /obj/item/natural/fur
	allowed_race = SPECIES_BASE_BODY
	salvage_amount = 3
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
