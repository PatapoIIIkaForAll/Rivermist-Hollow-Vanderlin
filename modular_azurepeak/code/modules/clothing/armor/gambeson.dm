/obj/item/clothing/armor/gambeson/baotha
	name = "saccharine vestments"
	desc = "Padded vestments embroidered in pink and gold. The faithful of Blissara teach that pain is merely a desire not yet satisfied - and that their goddess satisfies all."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "baothagamb"
	armor_class = AC_LIGHT
	armor_type = /datum/armor/ported/padded
	color = null
	max_integrity = 360
	resistance_flags = FIRE_PROOF
	body_parts_covered = CHEST | GROIN | ARMS
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/baotha/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/armor/gambeson/baotha/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/armor/gambeson/lord
	name = "arming jacket"
	desc = "A collared jacket, purpose-woven for warfare. The flared collar and sleeves keep the wearer's dexterity from being mitigated, while its tighter presentation helps to ward off killing blows from afar."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "dgamb"
	body_parts_covered = (( CHEST | GROIN | VITALS | ARMS))
	color = null
	allowed_sex = list(MALE, FEMALE)
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER
	ported_clothing = TRUE

/obj/item/clothing/armor/gambeson/raneshen
	name = "thin desert coat"
	desc = "A slim-fitting sherwani, a Calishite-styled coat meant to endure in the desert's climate. This one isn't padded, meant for a noble to wear."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "sherwani"
	color = "#eec39a"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/grenzelhoft
	name = "Darkholdian hip-shirt"
	desc = "Padded shirt for extra comfort and protection, adorned in vibrant colors."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "grenzelshirt"
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	body_parts_covered = (( CHEST | GROIN | VITALS | ARMS))
	boobed = FALSE
	detail_tag = "_detail"
	detail_color = "#FFFFFF"
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	color = "#1d1d22"
	var/picked = FALSE
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/gambeson/heavy/grenzelhoft/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choice = browser_input_list(user, "Choose a color.", "Darkhold colors", GLOB.ported_color_map)
		if(!choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		var/playerchoice = GLOB.ported_color_map[choice]
		picked = TRUE
		detail_color = playerchoice
		detail_tag = "_detail"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/armor/gambeson/heavy/hand
	name = "hand's gambeson"
	desc = "Sturdy leather, fine silks and ornaments of gold. Opulent and imperial, for any one who must say <i>\"I am in charge.\"</i> holds no power at all."
	icon = 'modular_azurepeak/icons/clothing/special/hand.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/hand.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/hand.dmi'
	icon_state = "handgambeson"
	color = null
	detail_tag = "_detail"
	detail_color = "#6e423a"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/hatanga
	name = "beast-hide coat"
	desc = "Layered robes reinforced with quilted padding and stitched hides from formidable beasts."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "hatanga"
	color = "#ffffff"
	boobed = TRUE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/hierophant
	name = "hierophant's shawl"
	desc = "A thick robe intervowen with spell-laced fabrics. Thick and protective while remaining light and breezy; the perfect gear for protecting one from the threats of the sun, the desert and the daemons, yet still allowing one to cast spells aptly."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "desertrobe"
	item_state = "desertrobe"
	color = null
	ported_clothing = TRUE

/obj/item/clothing/armor/gambeson/heavy/otavan_ap
	name = "fencing gambeson"
	desc = "A large shirt with heavy padding meant to be used below armor. Will probably stop an arrow, unlikely to stop a bolt."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "fancygamb"
	allowed_race = SPECIES_BASE_BODY
	color = "#5058c1"
	detail_color = "#e98738"
	detail_tag = "_detail"
	var/picked = FALSE
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/gambeson/heavy/otavan_ap/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choice = browser_input_list(user, "Choose a color.", "Amnian colors", GLOB.ported_color_map)
		if(!choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		var/playerchoice = GLOB.ported_color_map[choice]
		picked = TRUE
		detail_color = playerchoice
		detail_tag = "_detail"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_shirt()
			H.update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/armor/gambeson/heavy/pontifex
	name = "pontifex's kaftan"
	desc = "Tight boiled leathers that stretch and fit to one's frame perfectly."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "monkleather"
	item_state = "monkleather"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/gambeson/heavy/raneshen
	name = "padded desert coat"
	desc = "A slim-fitting sherwani, a Calishite-styled coat meant to endure in the desert's climate. This one is heavily padded, meant for a warrior to wear."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "sherwani"
	color = "#eec39a"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/lord/heavy
	name = "padded arming jacket"
	desc = "A collared jacket, intended to be worn underneath plate armor. The thicker padding ensures that any gaps left within its alloyed shell are thoroughly protected - lest an unforseen bowstrike, landing true, ruptures the vulnerable flesh beneath."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "dgamb"
	body_parts_covered = (( CHEST | GROIN | VITALS | ARMS))
	max_integrity = 300

/obj/item/clothing/armor/gambeson/lord/light
	name = "light arming jacket"
	desc = "A lightweight collared jacket, purpose-woven for skirmishes and battle. The modest weight and streamlined form make it ideal for wearing under a cuirass or elegant halfplate."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "dgamb"
	body_parts_covered = (( CHEST | GROIN | VITALS | ARMS))
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM

/obj/item/clothing/armor/gambeson/heavy/grenzelhoft/loadout
	name = "aesthetic Darkholdian hip-shirt"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "grenzelshirt"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/hand/advisor
	icon = 'modular_azurepeak/icons/clothing/special/hand.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/hand.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/hand.dmi'
	icon_state = "handgambeson"
	detail_color = "#6678c9"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/hand/spymaster
	icon = 'modular_azurepeak/icons/clothing/special/hand.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/hand.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/hand.dmi'
	icon_state = "handgambeson"
	detail_color = "#742277"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/hierophant/loadout
	name = "aesthetic hierophant's shawl"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "desertrobe"
	item_state = "desertrobe"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/pontifex/loadout
	name = "aesthetic pontifex's kaftan"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "monkleather"
	item_state = "monkleather"
	armor_type = /datum/armor/tree
	max_integrity = ARMOR_INT_CHEST_CIVILIAN
	armor_class = ARMOR_CLASS_NONE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/grenzelhoft/loadout/astrocrat
	name = "thin Darkholdian hip-shirt"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/stonekeep_merc.dmi'
	icon_state = "grenzelshirt"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
