/obj/item/clothing/armor/chainmail/besilked
	name = "besilked haubergeon"
	desc = "A maille shirt fashioned from hundreds of interlinked steel rings; lighter than its compatriots, yet reinforced with the presence of a besilked underjacket. Though fragile, it is a coveted article of nobility. When worn beneath a silk blouse, it can thwart an unsuspecting assassin's blow."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "haubergeon"
	armor_class = AC_LIGHT
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/bronze
	name = "bronze haubergeon"
	desc = "A maille shirt fashioned from hundreds of interlinked bronze rings. The value of flexible protection, especially in the centuries before plate, made any form of chainmail a rather valuable commodity; enough-so that it was worth its own weight in gold."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "bhaubergeon"
	max_integrity = 250
	smeltresult = /obj/item/ingot/bronze
	ported_clothing = TRUE

/obj/item/clothing/armor/chainmail/light
	name = "haubyrnie"
	desc = "A sleeveless maille shirt, fashioned from dozens of interlinked steel rings. It's light enough to comfortably tuck underneath a blouse, yet tough enough to thwart the razor-sharp edges of unwelcomed company. For the discerning nobleman."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "haubyrnie"
	max_integrity = ARMOR_INT_CHEST_LIGHT_STEEL
	armor_class = AC_LIGHT
	body_parts_covered = CHEST | VITALS
	flags_inv = HIDEBOOB
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE
	ported_adjust = TRUE
	adj_open_coverage = CHEST
	adj_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	ported_clothing = TRUE

/obj/item/clothing/armor/chainmail/light/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("RMB to adjust the haubyrnie's coverage; it can either cover the entire torso, or be tightened up to just cover the chest.")

/obj/item/clothing/armor/chainmail/besilked/fencer
	name = "besilked haubergeon"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "haubergeon"
	max_integrity = ARMOR_INT_CHEST_LIGHT_STEEL
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/bronze
	name = "bronze hauberk"
	desc = "A maille-aketon of bronze, sleeved to cover both the arms and legs. In antiquity, such an armored garment was seen as second-to-none in every facet; light enough to leave a well-trained warrior unfettered, yet still capable of turning away both arrow-and-blade."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "bhauberk"
	item_state = "bhauberk"
	smeltresult = /obj/item/ingot/bronze
	max_integrity = 250
	armor_type = /datum/armor/ported/bronze
	ported_clothing = TRUE

/obj/item/clothing/armor/chainmail/hauberk/graggar
	name = "vicious hauberk"
	desc = "The blessing of a martyr is nothing when put before the rage of Gruumsh."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "graggarhauberk"
	item_state = "graggarhauberk"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/heavy
	name = "plate-and-maille"
	desc = "A maille-aketon of steel, comfortably fitted beneath a matching cuirass. Best paired with a padded arming jacket and a lovely goblet of wine, sourced straight from the Duke's private reserves."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "cuirasshauberk"
	item_state = "cuirasshauberk"
	slot_flags = ITEM_SLOT_ARMOR
	armor_class = AC_HEAVY
	max_integrity = 450
	ported_clothing = TRUE

/obj/item/clothing/armor/chainmail/hauberk/matthios
	name = "gilded hauberk"
	desc = "All that glimmers is gold; yet only shining stars shalt break the mold.."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "matthioshauberk"
	item_state = "matthioshauberk"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/zizo
	name = "avantyne hauberk"
	desc = "The rings crackle softly with avantynic power, yet this lighter weave can still be taken off without being lost to the rite."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "zizohauberk"
	item_state = "zizohauberk"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/light/bronze
	name = "bronze haubyrnie"
	desc = "A sleeveless maille shirt, fashioned from dozens of interlinked bronze rings. It's light enough to comfortably tuck underneath a blouse, yet tough enough to thwart the razor-sharp edges of unwelcomed company. For the discerning traveler - ideally, from an antique land."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "bhaubyrnie"
	max_integrity = 180
	smeltresult = /obj/item/ingot/bronze
	armor_type = /datum/armor/ported/bronze

/obj/item/clothing/armor/chainmail/light/iron
	name = "iron haubyrnie"
	desc = "A sleeveless maille shirt, fashioned from dozens of interlinked iron rings. It's light enough to comfortably tuck underneath a blouse, yet tough enough to thwart the razor-sharp edges of unwelcomed company. For the discerning peasant."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ihaubyrnie"
	max_integrity = 150
	smeltresult = /obj/item/ingot/iron

/obj/item/clothing/armor/chainmail/hauberk/ancient/heavy
	name = "decrepit plate-and-maille"
	desc = "Rotted metal rings and rotting leather, woven together to form a sleeved maille-atekon; one that's been uncomfortably tucked beneath a matching cuirass. Such are the last remains of those who've dared to march against the undying legions, be it yils or centuries prior."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ancientcuirasshauberk"
	item_state = "ancientcuirasshauberk"
	slot_flags = ITEM_SLOT_ARMOR
	armor_class = AC_HEAVY
	max_integrity = 200
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/heavy/decorated
	name = "decorated plate-and-maille"
	desc = "A maille-aketon of steel, comfortably fitted beneath a decorated cuirass. Best paired with a gilded dress shirt and a tankard of Valmora Blue, chilled atop the rocks of a conquered fief."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gildedhauberk"
	item_state = "gildedhauberk"
	slot_flags = ITEM_SLOT_ARMOR
	armor_class = AC_HEAVY
	max_integrity = 450
	smeltresult = /obj/item/ingot/gold

/obj/item/clothing/armor/chainmail/hauberk/iron/heavy
	name = "iron plate-and-maille"
	desc = "A maille-aketon of iron, snuggly fitted beneath a matching cuirass. Best paired with a gambeson and a mug of chilled ale, or - as is the case with most levymen and adventurers - last nite's rags."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "icuirasshauberk"
	item_state = "icuirasshauberk"
	slot_flags = ITEM_SLOT_ARMOR
	armor_class = AC_HEAVY
	max_integrity = 325
	ported_clothing = TRUE

/obj/item/clothing/armor/chainmail/hauberk/ancient/heavy_ap
	name = "ancient plate-and-maille"
	desc = "Polished gilbranze rings and silk, woven together to form a sleeved maille-atekon; one that's been uncomfortably tucked beneath a matching cuirass. It eminates an unfamiliar sensation, rarely seen amongst rot-and-undeath - elegance. In the worlds to come, do you suppose Her death knights would bear such a mantle?"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ancientcuirasshauberk"
	item_state = "ancientcuirasshauberk"
	slot_flags = ITEM_SLOT_ARMOR
	armor_class = AC_HEAVY
	max_integrity = 450
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
