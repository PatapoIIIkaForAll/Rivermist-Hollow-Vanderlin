/obj/item/clothing/armor/leather/cuirass
	name = "leather cuirass"
	desc = "A leather cuirass."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leather"
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	color = "#7D6653"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/leather/heavy/aristocratavar
	name = "noble's vest"
	desc = "A light, custom-tailored flimsy leather and silken vest worn by nobility in the forested peaks of The Hordelands."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "freijacket"
	item_state = "freijacket"
	max_integrity = ARMOR_INT_CHEST_LIGHT_BASE - 25
	color = "#292626"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/coat
	name = "hardened leather coat"
	desc = "A heavy steerhide jerkin that reaches past the hips and better protects the vitals."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "roguearmor_coat"
	item_state = "roguearmor_coat"
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS ))
	armor_type = /datum/armor/ported/leather
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	color = "#7D6653"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/leather/heavy/freifechter
	name = "fencing jacket"
	desc = "A light, flexible button-up leather jacket that will keep your vitals out of harm's way."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "freijacket"
	item_state = "freijacket"
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 30
	detail_tag = "_detail"
	color = "#5E4440"
	detail_color = "#c08955"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/leather/heavy/shadowvest
	name = "drowcraft vest"
	desc = "Traditional Drow armour, made from the hide of one of the Underdark's many beasts. Durable yet still flexible, perfect for skirmishers."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "shadowvest"
	item_state = "shadowvest"
	allowed_race = SPECIES_BASE_BODY
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/shepherd
	name = "shepherd's vest"
	desc = "A light, flexible leather vest worn by shepherds in the forested peaks of The Hordelands."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "freijacket"
	item_state = "freijacket"
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	color = "#313131"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/studded/warden
	name = "forester's armor"
	desc = "A hardened leather harness with a large pauldron worn over a maille coat, associated with the Duskmarian wardens."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "forestleather"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/coat/gravecoat
	name = "gravetender's coat"
	desc = "A padded coat bearing the same hues one would find on a Jergalite. Small steel braces adorn the wrists, a symbol of Jergal's grasp on those who serve him."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gravecoat"
	item_state = "gravecoat"
	max_integrity = ARMOR_INT_CHEST_LIGHT_BASE
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/coat/lamplighter
	name = "lampwicker's overcoat"
	desc = "A Lamplighters overcoat is made to protect them both from the elements and from their own tools, treated to be resistant to flames, these hardy overcoats often still aren’t enough, evidenced by the many burns lamplighters seem to carry regardless."
	icon = 'modular_azurepeak/icons/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/lamplighter.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lampcoat1"
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/coat/raneshen
	name = "megarmach scale coat"
	desc = "A set of lightweight armor fashioned from the scales of the Calishite \\\"megarmach\\\", an armored reptilian creacher that ambushes prey by the riverside, and drags them deep into Umberlee's domain."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "pangolin"
	item_state = "pangolin"
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/coat/steppe
	name = "fur-woven chargah coat"
	desc = "A finely woven chargah coat, replacing much of its scaled armor with fine furs and reinforced padding for lighter rides."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "chargahfur"
	item_state = "chargahfur"
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/freifechter/loadout
	name = "aesthetic fencing jacket"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "freijacket"
	item_state = "freijacket"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/shadowvest/drowraider
	name = "custom-fit drowcraft vest"
	desc = "Traditional Drow armour, made from the hide of one of the Underdark's many beasts. Durable yet still flexible, perfect for skirmishers. Custom-fit for its (now deceased) wearer."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "shadowvest"
	item_state = "shadowvest"
	allowed_race = list(SPEC_ID_DROW)
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/studded/warden/upgraded
	name = "forester's brigandine"
	desc = "A hardened leather harness with a large pauldron worn over a tasseted brigandine, imbued with Silvanus's essence."
	icon = 'modular_azurepeak/icons/clothing/special/warden.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/warden.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "forestbrig"
	armor_type = /datum/armor/brigandine
	max_integrity = 300
	equip_delay_self = 50
	smeltresult = /obj/item/ingot/iron

/obj/item/clothing/armor/leather/heavy/coat/lamplighter/warden
	name = "lampwarden's overcoat"
	desc = "A heavier leather overcoat favored by Lampwardens, when combined with the usual collar stand covering the neck, these overcoats protect Lampwardens from the fire and oil of their own staves as they escort travellers. The burns covering their grim owners are evidence that these often still aren’t ."
	icon = 'modular_azurepeak/icons/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/lamplighter.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lampcoat2"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/coat/steppe/loadout
	name = "aesthetic fur-woven hatanga coat"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "chargahfur"
	item_state = "chargahfur"
	misc_flags = CRAFTING_TEST_EXCLUDE
