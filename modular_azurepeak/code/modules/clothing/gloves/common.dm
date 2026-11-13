/obj/item/clothing/gloves/cloth/donator_thistle
	name = "underdwelling artificer's gloves"
	desc = "Leather gloves, skikuldic cuffs, and silk padding. That last part's probably not ideal <i>(considering the fact that artificers work quite a lot with incendiary materials)</i>, but the ensuing lack of callouses makes it absolutely worth it."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "thistlegrippers"
	item_state = "thistlegrippers"
	color = null
	allowed_sex = list(FEMALE)
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/knuckles/donator_elegant
	name = "elegant knuckles"
	desc = "An elegant pair of knuckledusters for an elegant wielder."
	icon = 'modular_azurepeak/icons/clothing/donor_weapons.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "donator_knuckle"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/angle/freifechter
	name = "fencing gloves"
	desc = "A pair of hardened leather gloves used by fencers who aren't exactly convinced of losing a finger to a particularly strong feder cut. The inside is padded for extra durability."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "freigloves"
	item_state = "freigloves"
	max_integrity = ARMOR_INT_SIDE_HARDLEATHER + 30
	color = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/angle/freifechter/loadout
	name = "aesthetic fencing gloves"
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "freigloves"
	item_state = "freigloves"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/fingerless_leather
	name = "fingerless leather gloves"
	desc = "A pair of protective gloves favored by lockshimmers, laborers, and smokers for maintaining manual dexterity over regular gloves."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "roguegloves"
	armor_type = /datum/armor/ported/leather
	resistance_flags = FIRE_PROOF
	blocksound = SOFTHIT
	max_integrity = ARMOR_INT_SIDE_CLOTH
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	anvilrepair = null
	sewrepair = TRUE
	salvage_result = /obj/item/natural/hide/cured
	ported_clothing = TRUE

/obj/item/clothing/gloves/rosa
	name = "ivory gloves"
	desc = "Finely crafted gloves of silk and leather."
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosagloves1"
	salvage_result = /obj/item/natural/hide/cured
	ported_clothing = TRUE

/obj/item/clothing/gloves/rosa/eight
	name = "courtly gloves"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosagloves8"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/rosa/five
	name = "sable gloves"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosagloves5"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/rosa/four
	name = "obsidian gloves"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosagloves4"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/rosa/six
	name = "maroon gloves"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosagloves6"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/rosa/ten
	name = "stately gloves"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosagloves10"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/rosa/three
	name = "silvered gloves"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosagloves3"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/rosa/two
	name = "scarlet gloves"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosagloves2"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/fingerless/shadowgloves/spymaster
	name = "hand's gloves"
	desc = "Supple silk, cut at the fingertips to ensure absolute precision."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "handgloves"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	allowed_race = SPECIES_BASE_BODY

/obj/item/clothing/gloves/knuckles
	name = "steel knuckles"
	desc = "A mean looking pair of steel knuckles."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "steelknuckle"
	w_class = WEIGHT_CLASS_SMALL
	armor_type = /datum/armor/robe/mage
	max_integrity = ARMOR_INT_SIDE_LEATHER
	anvilrepair = /datum/attribute/skill/craft/weapon_repair
	smeltresult = /obj/item/ingot/steel
	unarmed_bonus = 8
	ported_clothing = TRUE
	var/wielded = FALSE

/obj/item/clothing/gloves/knuckles/get_mechanics_examine(mob/user)
	. = ..()
	. += span_warning("While worn, I cannot wield weapons or hold a shield.")
	//. += span_notice("Activate - while held in your current hand - to turn these into knuckledusters, which can be wielded as a dedicated weapon for unarmed combat.")

/obj/item/clothing/gloves/knuckles/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if((slot & ITEM_SLOT_GLOVES) && (locate(/obj/item/rogueweapon/shield) in M.held_items))
		if(!disable_warning)
			to_chat(M, span_warning("I can't wear [src] while holding a shield."))
		return FALSE
	return ..()

/obj/item/clothing/gloves/knuckles/ancient
	name = "ancient knuckles"
	desc = "A set of knuckles made of ancient metals, Aeon's grasp has been lifted from their form."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "aknuckle"
	unarmed_bonus = 6
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/knuckles/bronze
	name = "bronze knuckles"
	desc = "A mean looking pair of bronze knuckles. Mildly heavier than its steel counterpart, making it a solid defensive option, if less wieldy."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "bronzeknuckle"
	smeltresult = /obj/item/ingot/bronze

/obj/item/clothing/gloves/knuckles/decrepit
	name = "decrepit knuckles"
	desc = "A set of knuckles made of ancient metals, Aeon's grasp withers their form."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "aknuckle"
	max_integrity = 50
	unarmed_bonus = 4
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/knuckles/eora
	name = "close caress"
	desc = "Some times call for a more intimate approach."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "eoraknuckle"
	max_integrity = 150
	unarmed_bonus = 10
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/knuckles/iron
	name = "iron knuckles"
	desc = "A mean looking pair of iron knuckles, not that good in quality but they do the job."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "ironknuckle"
	w_class = WEIGHT_CLASS_SMALL
	armor_type = /datum/armor/robe/mage
	max_integrity = ARMOR_INT_SIDE_LEATHER -50
	anvilrepair = /datum/attribute/skill/craft/weapon_repair
	smeltresult = /obj/item/ingot/iron
	unarmed_bonus = 7

/obj/item/clothing/gloves/knuckles/silver
	name = "silver knuckles"
	desc = "A simple piece of harm that has been molded from pure silver, and further studded to stop errant strikes dead in their tracks. Though ostensibly holy, these heftsome knuckleweights are more strongly associated with underground pugilistic tournaments; a solid right hook could drive more-than-enough force to blow a yeoman's jaw clean off."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "silverknuckle"
	smeltresult = /obj/item/ingot/silver
	misc_flags = CRAFTING_TEST_EXCLUDE

// silver-blessed knuckles burn vampires and werewolves like other RMH silver gear
/obj/item/clothing/gloves/knuckles/silver/Initialize(mapload)
	. = ..()
	enchant(/datum/enchantment/silver)
