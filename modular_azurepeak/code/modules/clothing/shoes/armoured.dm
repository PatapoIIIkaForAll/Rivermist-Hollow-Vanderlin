/obj/item/clothing/shoes/boots/armor/aasimar
	name = "aasimari plated boots"
	desc = "Boots of polished gilbranze, kept clean from mud and blood. It has been meticulously sculpted to only fit the physique of its wearer; one of Lathander's divine legionnaires."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "chiv_aboots"
	allowed_sex = list(FEMALE)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/armor/dreamwalker
	name = "otherworldly boots"
	desc = "Strange iridescent plated boots. It reflects light as if covered in shiny oil."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "dreamboots"
	max_integrity = ARMOR_INT_SIDE_BLACKSTEEL
	armor_type = /datum/armor/ported/plate_bsteel
	item_flags = (1<<13)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/armor/iron/gronn
	name = "Uthgardt norsii iron boots"
	desc = "Thick iron boots, tied with a leather cord; protective and sturdy. Uthgardt legend tells of a great warrior who fought for aeons until a hero speared him through the foot. The Northmen have since followed through by protecting their feet heavily."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/gronn.dmi'
	sleeved = null
	icon_state = "gronnplateboots"
	item_state = "gronnplateboots"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/armor/avantyne
	name = "avantyne-threaded sabatons"
	desc = "Marrow, flesh, ash; the bedrock of a new reality, fated to suffer until the final breath. It is this prognosis that commands Her disciples to work towards ascensionism - for no sacrifice is too great, in the pursuit of bringing lyfe back to this dying world."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "zizoboots"
	max_integrity = ARMOR_INT_SIDE_STEEL
	armor_type = /datum/armor/ported/plate_bsteel
	armor_class = AC_MEDIUM
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/armor/baotha
	name = "saccharine heels"
	desc = "Plated heels lacquered in sickly pink. Blissara's cultists walk in them as if every step were a dance, and every dance an offering."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "baothaboots"
	item_state = "baothaboots"
	max_integrity = ARMOR_INT_SIDE_ANTAG - 250
	armor_class = AC_LIGHT
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	heeled = TRUE

/obj/item/clothing/shoes/boots/armor/baotha/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/shoes/boots/armor/baotha/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/shoes/boots/armor/blacksteel
	name = "ancient blacksteel plate boots"
	desc = "Antiquated sabatons, forged from segmented plates of blacksteel. Am I the cancer that is killing this world? Is it my hate, my spite, my lust - that, which poisons the ones around me, and siphons away the hope of Man and God alike? When the last hearth is quenched and Faerun is nothing more than a shriveled husk, will I still blame the corpses for what I had done? </br>\u200e </br>Let go of your hate. Your lyfe is yours, and yours alone to arbitrate."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "bkboots"
	item_state = "bkboots"
	max_integrity = ARMOR_INT_SIDE_BLACKSTEEL
	armor_type = /datum/armor/ported/plate_bsteel
	smeltresult = /obj/item/ingot/blacksteel
	ported_clothing = TRUE

/obj/item/clothing/shoes/boots/armor/bronze
	name = "bronze greaves"
	desc = "Padded sabatons of bronze, tightly strapped together and padded with hide from a fearsome beaste. The sandals clack about, yet they do not feel obstructive; if anything, you've never felt more agile while beplated."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "bronzegreaves"
	body_parts_covered = FEET | LEGS
	smeltresult = /obj/item/ingot/bronze
	armor_type = /datum/armor/ported/bronze
	max_integrity = 250
	ported_clothing = TRUE

/obj/item/clothing/shoes/boots/armor/dwarven
	name = "grudgebearer dwarven boots"
	desc = "Clatters mightily."
	icon = 'modular_azurepeak/icons/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/race_armor.dmi'
	sleeved = null
	icon_state = "dwarfshoe"
	item_state = "dwarfshoe"
	allowed_race = list(SPEC_ID_DWARF)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/armor/gold
	name = "golden greaves"
	desc = "Resplendant sabatons of pure gold, adorned with angled greaves that proudly bear the holy sigil. Its besilked cuffs have remained surprisingly bereft of debris - not even a sprig of lint remains to be criticized."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "goldgreaves"
	item_state = "goldgreaves"
	body_parts_covered = FEET | LEGS
	armor_class = AC_HEAVY
	armor_type = /datum/armor/blackbag
	max_integrity = 5
	anvilrepair = null
	smeltresult = /obj/item/ingot/gold
	grid_height = 96
	grid_width = 96
	ported_clothing = TRUE

/obj/item/clothing/shoes/boots/armor/iron
	name = "iron plated boots"
	desc = "A pair of leather boots, reinforced with smaller steel plates along the feet and ankles. Woven into the top of each boot's cuff is a thick layer of chainmail, which further protects the wearer's lower legs from harm. Commonly worn by well-seasoned adventurers, who happen to put more trust in their skills than their steel."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "iplateboots"
	item_state = "iplateboots"
	body_parts_covered = FEET
	color = null
	blocksound = PLATEHIT
	max_integrity = ARMOR_INT_SIDE_IRON
	armor_type = /datum/armor/plate
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/iron
	ported_clothing = TRUE

/obj/item/clothing/shoes/boots/armor/gold/king
	name = "royal golden greaves"
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "goldgreaves"
	item_state = "goldgreaves"
	max_integrity = 10
	sellprice = 300
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/armor/vampire
	name = "ancient ceremonial sabatons"
	desc = "A set of enchanted gilbranze boots, tightly fastened with strips of niteleather. It was by your command that the families were left broken at your feet; and it was by your sword that even the righteous were forced to yield. Now, their descendants rally against you once more; let them know their place."
	icon = 'modular_azurepeak/icons/clothing/feet.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/feet.dmi'
	sleeved = null
	icon_state = "vboots"
	item_state = "vboots"
	body_parts_covered = FEET
	max_integrity = ARMOR_INT_LEG_ANTAG
	color = null
	blocksound = PLATEHIT
	armor_type = /datum/armor/blackbag
	resistance_flags = FIRE_PROOF | ACID_PROOF
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shoes/boots/armor/vampire/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#8B0000", "alpha" = 180, "size" = 1)) //Enchanted look.
