/obj/item/clothing/armor/plate/legion
	name = "Shoonite lorica segmentata"
	desc = "Plate armour assembled from strips of steel fastened to one another. Despite its cost, legionaries and praetorians favour it for its reliability and comfort."
	icon = 'modular_twilightaxis/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor_2.dmi'
	icon_state = "legionplate"
	item_state = "legionplate"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/raneshen_scale
	name = "Calishite scalemail"
	desc = "Armor used by the Empire's vanguard fighters. The plates are connected to each other with cord for mobility. The arms are protected by pauldrons, and the legs by a small chainmail skirt. The armor itself is decorated with bronze."
	icon = 'modular_twilightaxis/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/32x48/sleeves_armor.dmi'
	icon_state = "medium_armour"
	item_state = "medium_armour"
	slot_flags = ITEM_SLOT_ARMOR
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	allowed_sex = list(MALE, FEMALE)
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/steel
	equip_delay_self = 4 SECONDS
	armor_class = AC_MEDIUM
	ported_clothing = TRUE

/obj/item/clothing/armor/cuirass/etrcuirass
	name = "Sembian cuirass"
	desc = "An steel cuirass, fine fitted with tassets for additional coverage. Typically seen on Sembian heavy infantry."
	icon = 'modular_twilightaxis/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor_2.dmi'
	icon_state = "etrcuirass"
	body_parts_covered = CHEST | VITALS | LEGS | NECK
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL
	detail_color = CLOTHING_WHITE
	detail_tag = "_detail"
	boobed = FALSE
	allowed_race = SPECIES_BASE_BODY
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/legion
	name = "Shoonite lorica musculata"
	desc = "A cuirass that shows off a master smith's skill. The crisp relief of an anatomical torso flatters the beauty and courage of its owner. Its high price means it is worn mostly by praetorians and the venerable patricians of Calimshan."
	icon = 'modular_twilightaxis/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor_2.dmi'
	icon_state = "legioncuirass"
	item_state = "legioncuirass"
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	ported_clothing = TRUE

/obj/item/clothing/armor/plate/full/raneshen_plated
	name = "Calishite plate armor"
	desc = "Full-fledged armor with scales, a light chainmail skirt protects the lower legs, has bronze decorations and strong protective shoulder pads."
	icon = 'modular_twilightaxis/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/32x48/sleeves_armor.dmi'
	icon_state = "heavy_armour"
	item_state = "heavy_armour"
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	equip_delay_self = 12 SECONDS
	unequip_delay_self = 12 SECONDS
	equip_delay_other = 3 SECONDS
	strip_delay = 6 SECONDS
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	armor_class = AC_HEAVY
	ported_clothing = TRUE

/obj/item/clothing/armor/medium/scale/townguard
	name = "watchman's armor"
	desc = "Heavy armour issued to the city Watch."
	icon = 'modular_twilightaxis/icons/clothing/special/citywatch_armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/special/onmob/citywatch_armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/special/onmob/helpers/citywatch_sleeves_armor.dmi'
	icon_state = "citywatch"
	item_state = "citywatch"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/fencer/twilight_elven
	name = "elven rider cuirass"
	desc = "An expertly smithed form-fitting steel cuirass that is much lighter and agile, but breaks with much more ease. Its sleek design marks it as a product of elven craftsmanship."
	icon = 'modular_twilightaxis/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor_2.dmi'
	icon_state = "elven_chestplate"
	item_state = "elven_chestplate"
	allowed_race = SPECIES_BASE_BODY
	ported_clothing = TRUE

/obj/item/clothing/armor/plate/fluted/zizo/bloodraider
	name = "raider's cuirass"
	desc = "An elegant cuirass that doesn't restrict movement, intimidates enemies, and is simply beautiful. What more could you need?"
	icon = 'modular_twilightaxis/icons/clothing/bloodraider.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/bloodraider.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/onmob/helpers/sleeves_armor_2.dmi'
	icon_state = "bloodcuirass"
	item_state = "bloodcuirass"
	allowed_race = list(SPEC_ID_ELF, SPEC_ID_ELF_W, SPEC_ID_HALF_ELF, SPEC_ID_DROW)
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	max_integrity = ARMOR_INT_CHEST_PLATE_ANTAG - 400
	armor_class = AC_LIGHT
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/medium/scale/inqcoat_ap/overseer
	name = "confessor coat"
	desc = "A heavy, reinforced coat with an exquisite burgundy finish that leaves no one indifferent."
	icon = 'modular_twilightaxis/icons/clothing/inquisition_overseer/overseer.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/inquisition_overseer/onmob/overseer_onmob.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/inquisition_overseer/onmob/overseer_onmob.dmi'
	icon_state = "viceseercoat"
	item_state = "viceseercoat"
	color = null
	boobed = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/medium/scale/townguard/sheriff
	name = "sheriff's armor"
	desc = "Heavy armour belonging to the Sheriff of the Watch."
	icon = 'modular_twilightaxis/icons/clothing/special/citywatch_armor.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/special/onmob/citywatch_armor.dmi'
	sleeved = 'modular_twilightaxis/icons/clothing/special/onmob/helpers/citywatch_sleeves_armor.dmi'
	icon_state = "sheriffarmor"
	item_state = "sheriffarmor"
	misc_flags = CRAFTING_TEST_EXCLUDE
