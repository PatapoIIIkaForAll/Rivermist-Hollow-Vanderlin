/obj/item/clothing/gloves/plate/aasimar
	name = "aasimari plated gauntlets"
	desc = "Gauntlets of polished gilbranze, grooved to ensure bloodied grips don't slip. It has been meticulously sculpted to only fit the physique of its wearer; one of Lathander's divine legionnaires."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "chiv_agauntlets"
	allowed_sex = list(FEMALE)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/dreamwalker
	name = "otherworldly gauntlets"
	desc = "Strange iridescent plated gauntlets. It reflects light as if covered in shiny oil."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "dreamgauntlets"
	max_integrity = ARMOR_INT_SIDE_BLACKSTEEL
	item_flags = (1<<13)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/blkknight/death
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "bkgloves"
	color = CLOTHING_BLACK
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/chain/gronn
	name = "Uthgardt byrine gloves"
	desc = "A pair of leather gloves with chain to protects the wrists and back of the hand."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/gronn.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "gronnchaingloves"
	item_state = "gronnchaingloves"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/iron/gronn
	name = "Uthgardt norsii iron gauntlets"
	desc = "Tough iron gauntlets, simple and protective in design. A single punch is said to leave a dozen bruises."
	icon = 'modular_azurepeak/icons/clothing/special/gronn.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/gronn.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "gronnplategloves"
	item_state = "gronnplategloves"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/blkknight
	name = "darkened plate gauntlets"
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "bkgloves"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/blacksteel
	name = "ancient blacksteel plate gauntlets"
	desc = "Wide-cuffed plate gauntlets, alloyed from a singular sheet of blacksteel. How would it feel, to see your greatest works slip away from your grasp; to see it twisted, violated, and alchemized into the very thing you swore to detest? To fall into Hell, with a head crooked up to forever-leer at the Paradise that was meant for you to reign? </br> </br>Don't spare a breath; we both know the answer."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "bkgloves"
	item_state = "bkgloves"
	armor_type = /datum/armor/ported/plate_bsteel
	max_integrity = ARMOR_INT_SIDE_BLACKSTEEL
	smeltresult = /obj/item/ingot/blacksteel
	ported_clothing = TRUE

/obj/item/clothing/gloves/chain/bronze
	name = "bronze maille gauntlets"
	desc = "Armored mittens, woven together from a series of interlinked bronze rings. It can comfortably accomadate the needs of a warrior in almost any action, be it stringing a longbow or wielding a sword."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "bcgloves"
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/bronze
	max_integrity = 250
	armor_type = /datum/armor/ported/bronze
	ported_clothing = TRUE

/obj/item/clothing/gloves/plate/avantyne
	name = "avantyne-threaded sleevegloves"
	desc = "Incongruent silks from a tymeline-most-doomed, woven by Man to cradle the palms of God's successor. Softer than silk, yet unfettered by the blows from those who know no better."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "zizoplategauntlets_med"
	armor_type = /datum/armor/ported/plate_bsteel
	body_parts_covered = HANDS|ARMS
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/baotha
	name = "saccharine gauntlets"
	desc = "Plated gauntlets lacquered in sickly pink. Blissara's devoted say the Veiled Desire slips into the minds of those who wear Her gifts, numbing every pain until only longing remains."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "baothagloves"
	item_state = "baothagloves"
	max_integrity = ARMOR_INT_SIDE_ANTAG - 250
	armor_class = AC_LIGHT
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/baotha/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/gloves/plate/baotha/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/gloves/plate/kote
	name = "jjajeungna gauntlets"
	desc = "A set of reinforced Kozakuran gauntlets. Difficult to do much other than fight in, but not entirely arresting."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "kazengungauntlets"
	item_state = "kazengungauntlets"
	body_parts_covered = HANDS|ARMS
	detail_tag = "_detail"
	color = "#FFFFFF"
	detail_color = "#FFFFFF"
	var/picked = FALSE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/kote/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choice = browser_input_list(user, "Choose a color.", "Uniform colors", GLOB.ported_color_map)
		if(!choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		var/playerchoice = GLOB.ported_color_map[choice]
		picked = TRUE
		detail_color = playerchoice
		detail_tag = "_detail"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_armor()
			H.update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/gloves/plate/graggar/heavy
	name = "vicious plated gauntlets"
	desc = "Steel plated gauntlets overlaid by an ornamental imagery of fractured bone and entrails. The violet smears; a tether to the lyfe that once was - and now, a stinging reminder of what could've been."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "graggarplategloves_heavy"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/graggar/heavy/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/gloves/plate/graggar/heavy/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/gloves/plate/iron/banded
	name = "banded iron gauntlets"
	desc = "A pair of leather gloves layered under a fur wrap with an iron plate hastily tightened together on both ends. It's primarily worn in the cold north, where armor has to sometimes be cobbled together due to logistical shortages."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "bandedgloves"
	item_state = "bandedgloves"
	ported_clothing = TRUE

/obj/item/clothing/gloves/plate/zizo/heavy
	name = "avantyne plate gauntlets"
	desc = "Unknowing truths, veiling the hands that prayed. Called forth from the edge of what should be known, in Her name."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "zizogauntlets"
	max_integrity = ARMOR_INT_SIDE_ANTAG
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/plate/zizo/heavy/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/gloves/plate/zizo/heavy/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/gloves/knuckles/blacksteel
	name = "blacksteel knuckles"
	desc = "Take that, taste the pain!"
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "bsknuckle"
	max_integrity = 200
	unarmed_bonus = 12
	smeltresult = /obj/item/ingot/blacksteel

/obj/item/clothing/gloves/plate/dwarven
	name = "grudgebearer dwarven gauntlets"
	desc = "Forged to fit the stubbiest of fingers."
	icon = 'modular_azurepeak/icons/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/race_armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "dwarfhand"
	item_state = "dwarfhand"
	allowed_race = list(SPEC_ID_DWARF)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/chain/vampire
	name = "ancient ceremonial gauntlets"
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "vgloves"
	item_state = "vgloves"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor_type = /datum/armor/blackbag
	max_integrity = ARMOR_INT_SIDE_ANTAG
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/chain/vampire/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#8B0000", "alpha" = 180, "size" = 1)) //Enchanted look.
