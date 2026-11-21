/obj/item/clothing/gloves/leather/otavan/psygloves
	name = "Aonic leather gloves"
	desc = "Thick leather mittens, stitched and cuffed to guard His children's palms from perforation."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "psydongloves"
	item_state = "psydongloves"
	armor_type = /datum/armor/ported/leather
	salvage_result = /obj/item/natural/hide/cured
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/knuckles/psydon
	name = "Aonic knuckles"
	desc = "A simple piece of harm molded in a holy mixture of steel and silver, finished with three stumps - Ao's crown - to crush the heretics' garments and armor into smithereens."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "psyknuckle"
	smeltresult = /obj/item/ingot/silverblessed

/obj/item/clothing/gloves/knuckles/psydon/old
	name = "enduring knuckles"
	desc = "A simple piece of harm molded in a holy mixture of steel and silver, its holy blessing long since faded. You are HIS weapon, you needn't fear Aeon."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "opsyknuckle"
	smeltresult = /obj/item/ingot/steel
	misc_flags = CRAFTING_TEST_EXCLUDE

// silver-blessed knuckles burn vampires and werewolves like other RMH silver gear
/obj/item/clothing/gloves/knuckles/psydon/Initialize(mapload)
	. = ..()
	enchant(/datum/enchantment/silver)
