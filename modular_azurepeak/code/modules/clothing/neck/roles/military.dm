/obj/item/clothing/neck/mercmedal/condottiero
	name = "condottiero's hilt"
	desc = "A beautiful silver necklace with pea-sized rontz inlays. Each is a work of art in itself; handcrafted by a master jeweler of Sembia. This is the blade to which the condottiero has sworn their lyfe."
	icon = 'modular_azurepeak/icons/clothing/mercmedals.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/mercmedals.dmi'
	sleeved = null
	icon_state = "condo_blade"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/mercmedal/forlorn
	name = "laughing volf medal"
	desc = "A trinket bearing the snarling visage of a volf and bolt, a mark of distinction among the Forlorn Hope. Often taken from the dead and issued anew to the living, each bearing lyfetymes of nicks and scratches."
	icon = 'modular_azurepeak/icons/clothing/mercmedals.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/mercmedals.dmi'
	sleeved = null
	icon_state = "forlorn_dogmedal"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/mercmedal/freifechter
	name = "freifechter's obol"
	desc = "A descendant of the oft-forgotten psilen, with a hole through one end for hanging on a string. With the advent of mammon as the Western Continent's currency of choice, they find new lyfe worn as marks of skill by freifechters."
	icon = 'modular_azurepeak/icons/clothing/mercmedals.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/mercmedals.dmi'
	sleeved = null
	icon_state = "freif_obol"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/mercmedal/grudgebearer
	name = "grudgebearer's keepsake"
	desc = "\"Fergive? FERGET? PFAH! GO T'HEL!\""
	icon = 'modular_azurepeak/icons/clothing/mercmedals.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/mercmedals.dmi'
	sleeved = null
	icon_state = "grudge_keepsake"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/mercmedal/steppesman_ap
	name = "steppesman's ungent"
	desc = "A tightly sealed vial of dirt. These are taken from the town of a steppesman's birth and given to them as they leave. When they return- if they return- they can be dumped out, and the vial crushed; the end, it says."
	icon = 'modular_azurepeak/icons/clothing/mercmedals.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/mercmedals.dmi'
	sleeved = null
	icon_state = "steppe_ungent"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/mercmedal/underdweller_ap
	name = "underdweller's broken compass"
	desc = "The underdwellers claim this will always point you exactly where you need to go. If it doesn't work, that's just an issue of skill and mindset."
	icon = 'modular_azurepeak/icons/clothing/mercmedals.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/mercmedals.dmi'
	sleeved = null
	icon_state = "under_compass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/mercmedal/vaquero
	name = "vaquero's ring"
	desc = "A beautiful gold-and-rontz ring, a masterwork of Sembian jeweling. This does more than prove you a true vaquero; it shows you are as beautiful as you are dangerous, a crimson stone set against gold. Lyve dangerously, but lyve all the same."
	icon = 'modular_azurepeak/icons/clothing/mercmedals.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/mercmedals.dmi'
	sleeved = null
	icon_state = "vaquero_ring"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/bevor/bronze
	name = "bronze gorgette"
	desc = "A jutting slab of bronze, traditionally mounted atop a panoplic assembly to veil the neck from precise strikes. </br>To tip the chin up while grounded is an ancient gesture; one which willingly beckons for the 'gift of mercy'."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "bbevor"
	armor_type = /datum/armor/ported/bronze
	max_integrity = 250
	smeltresult = /obj/item/ingot/bronze
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	ported_clothing = TRUE
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = NECK
	adj_sound = 'sound/items/visor.ogg'

/obj/item/clothing/neck/gorget/aventail/iron
	name = "iron aventail"
	desc = "A thick garment of iron maille and padding, traditionally attached to bascinets. It's burdensome on the shoulders of those who aren't properly trained to wear knightly garments."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "iaventailbase"
	max_integrity = ARMOR_INT_SIDE_IRON + 50
	smeltresult = /obj/item/ingot/iron
