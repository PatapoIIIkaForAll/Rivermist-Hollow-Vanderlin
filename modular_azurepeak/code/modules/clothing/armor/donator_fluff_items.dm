/obj/item/clothing/armor/chainmail/donator
	name = "cropped haubergeon"
	desc = "A curious - and particularly revealing - variant of a common maille-garment. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "cropmailles"
	item_state = "cropmailles"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/donator_elven
	name = "elven haubergeon"
	desc = "An ancestral design, passed down from the oldest of Duskmar's native elven inhabitants. The greenish tint present along the leatherbound steel maille is the byproduct of its links being fashioned through magicks, not a forge's heat."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "elven_chain"
	item_state = "elven_chain"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/ollanius_maille
	name = "shoulderless haubergeon"
	desc = "A maille shirt fashioned from hundreds of interlinked steel rings. This blouse covers all the little nooks-and-crannies that're neglected by a standard cuirass, save for the shoulders and biceps; a curious concession, ostensibly made for agility's sake."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "ollanius_hoeburk"
	item_state = "ollanius_hoeburk"
	flags_inv = HIDEBOOB
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/woodland
	name = "woodland brigandine"
	desc = "A set of fitted brigandine featuring hardened leather reinforced with steel plates beneath, worn over a light maille shirt. Its similarity to the Duskmarian wardens' brigandine is no accident: the elven rangers of the High Forest shared its design with their human fellows, who adapted it for their own needs."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrig"
	item_state = "woodwalkerbrig"
	detail_color = "#697F5C"
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/donator_arming
	name = "jacketed gambeson"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "darming"
	item_state = "darming"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/shifted = FALSE
	var/shiftable = TRUE

/obj/item/clothing/armor/gambeson/donator_arming/attack_hand_secondary(mob/user, list/modifiers)
	if(!shiftable)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(shifted)
		if(alert(user, "Would you like to wear your jacketed gambeson normally? This restores the new greyscaled style.",, "Yes", "No") != "No")
			icon_state = "darming"
			color = "#976E6B"
			update_appearance()
			shifted = FALSE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_shirt()
					H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	else
		if(alert(user, "Would you like to wear your jacketed gambeson traditionally? This restores the original coloration.",, "Yes", "No") != "No")
			icon_state = "darmingold"
			color = null
			update_appearance()
			shifted = TRUE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_shirt()
					H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/armor/gambeson/donator_cropped
	name = "low cut gambeson"
	desc = "An ordinary gambeson, trimmed down at the top and below by design to be more revealing and fitted to the body for more comfort."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "cropgambeson"
	item_state = "cropgambeson"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/donator_jacket
	name = "jacketed gambeson"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "djacket"
	item_state = "djacket"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/shifted = FALSE
	var/shiftable = TRUE

/obj/item/clothing/armor/gambeson/donator_jacket/attack_hand_secondary(mob/user, list/modifiers)
	if(!shiftable)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(shifted)
		if(alert(user, "Would you like to wear your jacketed gambeson normally? This restores the new greyscaled style.",, "Yes", "No") != "No")
			icon_state = "djacket"
			color = "#976E6B"
			update_appearance()
			shifted = FALSE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_shirt()
					H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	else
		if(alert(user, "Would you like to wear your jacketed gambeson traditionally? This restores the original coloration.",, "Yes", "No") != "No")
			icon_state = "djacketold"
			color = null
			update_appearance()
			shifted = TRUE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_shirt()
					H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/armor/leather/donator_cuirass
	name = "heroic leather cuirass"
	desc = "A flexible vest, stitched together from lengths of cured leather. It hugs the wearer's form, gifting them a mimicked form of a sculpted physique - or maybe that's just a byproduct of it being so damn tight."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leathercuirass"
	item_state = "leathercuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/donator_girdle
	name = "leather plackart"
	desc = "A curious - and particularly revealing - variant of a common leather cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackartleather"
	item_state = "plackartleather"
	body_parts_covered = CHEST | VITALS
	flags_inv = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heartplate
	name = "leather heartplate"
	desc = "A curious - and particularly revealing - variant of a leather vest. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "heartplatel"
	item_state = "heartplatel"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/longcoat/donator_squidqueen
	name = "ragged longcoat"
	desc = "A longcoat that has been languishing without proper care for longer than you'd dare to imagine. It's hard to tell whether those brown splotches were born from sullied dyes or disturbed soil. </br>'The pain does not end in death; so get back up and go to work again.'"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "squid_grimecoat"
	item_state = "squid_grimecoat"
	allowed_sex = list(FEMALE)
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/longcoat/donator_squidqueen_alt
	name = "frayed longcoat"
	desc = "A longcoat that has been languishing without proper care for longer than you'd dare to imagine."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "squid_fraycoat"
	item_state = "squid_fraycoat"
	allowed_sex = list(FEMALE)
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/longcoat/eiren
	name = "Darkwood's Embrace"
	desc = "A tough leather coat, taken from one of the few remaining arcyne studies of Lord Darkwood. Ancient, but in remarkably good condition as the weight of memory and sin tries to drag you down."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "eirencoat"
	item_state = "eirencoat"
	sleevetype = "eirencoat"
	detail_tag = "_detail"
	detail_color = CLOTHING_RED
	color = CLOTHING_WHITE
	boobed = FALSE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/longcoat/wyrd_cloak
	name = "Cloak of the Wyrd"
	desc = "Sewn by ways unknown to the land, what may have been garbs fitting for royalty once now lays aged beyond measure. However, it would surely provide much needed warmth for the cold and uncaring bog..."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "wyrd_cloak"
	item_state = "wyrd_cloak"
	armor_type = /datum/armor/tree
	boobed = FALSE
	toggle_icon_state = FALSE
	flags_inv = HIDEBOOB|HIDECROTCH
	color = null
	hoodtype = /obj/item/clothing/head/hooded/rainhood/wyrd_hood
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/donator_girdle
	name = "heavy steel plackart"
	desc = "A curious - and particularly revealing - variant of a half-plated cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackarts"
	item_state = "plackarts"
	body_parts_covered = CHEST | VITALS
	flags_inv = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/donator_gothic
	name = "gothic half-plate"
	desc = "A magnificent steel cuirass, fitted with tassets and assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "ghalfplate"
	item_state = "ghalfplate"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/heartplate
	name = "heavy steel heartplate"
	desc = "A curious - and particularly revealing - variant of a half-plated cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "heartplates"
	item_state = "heartplates"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/brigandine/light/donator_rhynn
	name = "jacketed brigandine"
	desc = "A lightweight jacket of studded brigandine, worn beneath a steel cuirass that's been custom-fitted to someone's bosom. While more expensive than a siege mage's traditional vest, this Darkholdian garbpiece offers much finer protection against one's own incendiary magicks."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "rhynnbrigandine"
	item_state = "rhynnbrigandine"
	allowed_sex = list(FEMALE)
	nodismemsleeves = FALSE
	color = CLOTHING_WHITE
	detail_tag = "_detail"
	detail_color = CLOTHING_RED
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/brigandine/light/tyesca
	name = "fencing brigandine"
	desc = "A lightweight fencing brigandine of Sembian make, popular among the duelling houses of Saerloon. A surcoat bearing its maker's house colours is sewn in as the interior lining."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "fencerbrig"
	item_state = "fencerbrig"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/brigandine/light/woodland
	name = "woodland brigandine"
	desc = "A set of fitted brigandine featuring hardened leather reinforced with steel plates beneath, worn over a light maille shirt. Its similarity to the Duskmarian wardens' brigandine is no accident: the elven rangers of the High Forest shared its design with their human fellows, who adapted it for their own needs."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrig"
	item_state = "woodwalkerbrig"
	detail_color = "#697F5C"
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/bronze/donator
	name = "cropped iron haubergeon"
	desc = "A curious - and particularly revealing - variant of a bronze maille-garment. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "cropmailleb"
	item_state = "cropmailleb"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/donator
	name = "maillekini"
	desc = "A curious - and particularly revealing - variant of a common maille-aketon. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "chainkinis"
	item_state = "chainkinis"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/woodland
	name = "woodland brigandine"
	desc = "A set of fitted brigandine featuring hardened leather reinforced with steel plates beneath, worn over a light maille shirt. Its similarity to the Duskmarian wardens' brigandine is no accident: the elven rangers of the High Forest shared its design with their human fellows, who adapted it for their own needs."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrig"
	item_state = "woodwalkerbrig"
	detail_color = "#697F5C"
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/iron/donator
	name = "cropped iron haubergeon"
	desc = "A curious - and particularly revealing - variant of an iron maille-garment. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "cropmaillei"
	item_state = "cropmaillei"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/iron/donator_elven
	name = "elven haubergeon"
	desc = "An ancestral design, passed down from the oldest of Duskmar's native elven inhabitants. The greenish tint present along the leatherbound iron maille is the byproduct of its links being fashioned through magicks, not a forge's heat."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "elven_chain"
	item_state = "elven_chain"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/woodland/plackart
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrigp"
	item_state = "woodwalkerbrigp"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/donator_arming
	name = "heavy jacketed gambeson"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "darming"
	item_state = "darming"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/shifted = FALSE
	var/shiftable = TRUE

/obj/item/clothing/armor/gambeson/heavy/donator_arming/attack_hand_secondary(mob/user, list/modifiers)
	if(!shiftable)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(shifted)
		if(alert(user, "Would you like to wear your heavy jacketed gambeson normally? This restores the new greyscaled style.",, "Yes", "No") != "No")
			icon_state = "darming"
			color = "#976E6B"
			update_appearance()
			shifted = FALSE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_shirt()
					H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	else
		if(alert(user, "Would you like to wear your heavy jacketed gambeson traditionally? This restores the original coloration.",, "Yes", "No") != "No")
			icon_state = "darmingold"
			color = null
			update_appearance()
			shifted = TRUE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_shirt()
					H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/armor/gambeson/heavy/donator_cropped
	name = "low cut padded gambeson"
	desc = "A gambeson that's padded in the areas that matter, and trimmed down at the top and below by design to be more revealing and fitted to the body for more comfort."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "cropgambeson"
	item_state = "cropgambeson"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/heavy/donator_jacket
	name = "heavy jacketed gambeson"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "djacket"
	item_state = "djacket"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	var/shifted = FALSE
	var/shiftable = TRUE

/obj/item/clothing/armor/gambeson/heavy/donator_jacket/attack_hand_secondary(mob/user, list/modifiers)
	if(!shiftable)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(shifted)
		if(alert(user, "Would you like to wear your heavy jacketed gambeson normally? This restores the new greyscaled style.",, "Yes", "No") != "No")
			icon_state = "djacket"
			color = "#976E6B"
			update_appearance()
			shifted = FALSE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_shirt()
					H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	else
		if(alert(user, "Would you like to wear your heavy jacketed gambeson traditionally? This restores the original coloration.",, "Yes", "No") != "No")
			icon_state = "djacketold"
			color = null
			update_appearance()
			shifted = TRUE
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_shirt()
					H.update_inv_armor()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/armor/gambeson/heavy/strudels
	name = "form-fitting padded gambeson"
	desc = "A normal looking padded gambeson that seems to have been custom fitted to a specific body for more comfort."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "formfit"
	item_state = "formfit"
	color = "#ffffff"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/light/donator_arming
	name = "light jacketed gambeson"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "darming"
	item_state = "darming"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/light/donator_jacket
	name = "light jacketed gambeson"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "djacket"
	item_state = "djacket"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/shadowrobe/donator_sanshoom
	name = "thin prowler robe"
	desc = "Crimson silk, flowing outwards like entrails from a gouged belly. As light as it may be, it'll never unburden those shackles of sin 'pon thine wrists."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "sanshoom_prowlerrobe"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	allowed_race = SPECIES_BASE_BODY

/obj/item/clothing/armor/leather/heavy/donator_cuirass
	name = "heroic leather cuirass"
	desc = "A flexible vest, stitched together from lengths of cured leather. It hugs the wearer's form, gifting them a mimicked form of a sculpted physique - or maybe that's just a byproduct of it being so damn tight."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leathercuirass"
	item_state = "leathercuirass"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/donator_girdle
	name = "heavy leather plackart"
	desc = "A curious - and particularly revealing - variant of a heavy leather cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackartleather"
	item_state = "plackartleather"
	body_parts_covered = CHEST | VITALS
	flags_inv = null
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/heartplate
	name = "heavy leather heartplate"
	desc = "A curious - and particularly revealing - variant of a heavy leather vest. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leathercuirass"
	item_state = "leathercuirass"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/studded/donator_cuirass
	name = "heroic leather cuirass"
	desc = "A flexible vest, stitched together from lengths of cured leather. It hugs the wearer's form, gifting them a mimicked form of a sculpted physique - or maybe that's just a byproduct of it being so damn tight."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leathercuirass"
	item_state = "leathercuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/studded/donator_girdle
	name = "studded leather plackart"
	desc = "A curious - and particularly revealing - variant of a studded leather cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackartleather"
	item_state = "plackartleather"
	body_parts_covered = CHEST | VITALS
	flags_inv = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/studded/heartplate
	name = "studded leather heartplate"
	desc = "A curious - and particularly revealing - variant of a studded leather vest. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leathercuirass"
	item_state = "leathercuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/studded/woodland
	name = "woodland brigandine"
	desc = "A set of fitted brigandine featuring hardened leather reinforced with steel plates beneath, worn over a light maille shirt. Its similarity to the Duskmarian wardens' brigandine is no accident: the elven rangers of the High Forest shared its design with their human fellows, who adapted it for their own needs."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrig"
	item_state = "woodwalkerbrig"
	detail_color = "#697F5C"
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/aasimar
	name = "aasimari cuirass"
	desc = "A cuirass of polished gilbranze, tasseted and pauldroned. It has been meticulously sculpted to only fitthe physique of its wearer; one of Lathander's divine legionnaires."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "chiv_acuirass"
	allowed_sex = list(FEMALE)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/donator_girdle
	name = "steel plackart"
	desc = "A curious - and particularly revealing - variant of a common cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackarts"
	item_state = "plackarts"
	body_parts_covered = CHEST | VITALS
	flags_inv = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/donator_gothic
	name = "gothic cuirass"
	desc = "A magnificent steel cuirass, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gcuirass"
	item_state = "gcuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/heartplate
	name = "steel heartplate"
	desc = "A curious - and particularly revealing - variant of a common cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "heartplates"
	item_state = "heartplates"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/woodland
	name = "woodland brigandine"
	desc = "A set of fitted brigandine featuring hardened leather reinforced with steel plates beneath, worn over a light maille shirt. Its similarity to the Duskmarian wardens' brigandine is no accident: the elven rangers of the High Forest shared its design with their human fellows, who adapted it for their own needs."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrig"
	item_state = "woodwalkerbrig"
	detail_color = "#697F5C"
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/fluted/donator_girdle
	name = "fluted plackart"
	desc = "A curious - and particularly revealing - variant of a fluted cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackarts"
	item_state = "plackarts"
	body_parts_covered = CHEST | VITALS
	flags_inv = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/fluted/donator_gothic
	name = "gothic half-plate"
	desc = "A magnificent set of half-plated steel armor, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "gflutedhalfplate"
	item_state = "gflutedhalfplate"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/fluted/donator_gothic_ornate
	name = "gothic half-plate"
	desc = "A magnificent ornate set of half-plated steel armor, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gpsycuirass"
	item_state = "gpsycuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/apostle
	name = "apostolic plate armor"
	desc = "Let thy blade pass upon mine flesh. </br>Let mine blood be spill't 'pon the ground. </br>Let my cries touch the hearts of those I stand a'fore. </br>Let mine be the last sacrifice."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "apostleplate"
	item_state = "apostleplate"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/donator_gothic
	name = "gothic plate armor"
	desc = "A magnificent set of steel plate armor, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "gplate"
	item_state = "gplate"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/donator_triheartfelt
	name = "Duskmarian plate armor"
	desc = "A complete set of Baldurian-styled plate armor, decorated with a furred coif and a silk robe that's been dyed with dried duskbloom powder. Most intimately associated with Duskmar's diplomats and champions, these suits are traditionally restricted to the battlefields of garish noble courtrooms and balls."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "triheartfelt"
	item_state = "triheartfelt"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/robed
	name = "\improper Knight-Apostle's heavy raiment"
	desc = "Let thy blade pass upon mine flesh. </br>Let mine blood be spill't 'pon the ground. </br>Let my cries touch the hearts of those I stand a'fore. </br>Let mine be the last sacrifice."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "robedplate"
	item_state = "robedplate"
	detail_tag = "_detail"
	color = null
	detail_color = CLOTHING_WHITE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/iron/donator_gothic
	name = "gothic iron half-plate"
	desc = "A magnificent iron cuirass, fitted with tassets and assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ighalfplate"
	item_state = "ighalfplate"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/brigandine/light/woodland/plackart
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrigp"
	item_state = "woodwalkerbrigp"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/bronze/donator
	name = "bronze maillekini"
	desc = "A curious - and particularly revealing - variant of a bronze maille-aketon. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "chainkinib"
	item_state = "chainkinib"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/fluted/robed
	name = "\improper Knight-Apostle's heavy raiment"
	desc = "Let thy blade pass upon mine flesh. </br>Let mine blood be spill't 'pon the ground. </br>Let my cries touch the hearts of those I stand a'fore. </br>Let mine be the last sacrifice."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "robedplate"
	item_state = "robedplate"
	detail_tag = "_detail"
	color = null
	detail_color = CLOTHING_WHITE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/heavy/donator_gothic
	name = "gothic plate-and-maille"
	desc = "A magnificent steel cuirass, fitted atop a hauberk and assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "gcuirasshauberk"
	item_state = "gcuirasshauberk"

/obj/item/clothing/armor/chainmail/hauberk/heavy/rockhill
	name = "jacketed plate-and-maille"
	desc = "A maille-aketon of steel, comfortably fitted beneath a matching cuirass and a thick clothspun jacket. Originating from Waterdeep's armories, this slightly-less-expensive alternative to plate armor was fashioned to ensure every man-at-arms could stand and face the fief's rising perils. The fabric can be dyed in ducal colors, to avert cases of 'friendly fireballing'."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "rockhillmaille"
	item_state = "rockhillmaille"
	detail_tag = "_detail"
	detail_color = COLOR_WHITE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/iron/donator
	name = "iron maillekini"
	desc = "A curious - and particularly revealing - variant of an iron maille-aketon. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "chainkinii"
	item_state = "chainkinii"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/woodland/plackart
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrigp"
	item_state = "woodwalkerbrigp"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/gambeson/shadowrobe/donator_sanshoom_ap
	name = "prowler robe"
	desc = "Crimson silk, flowing outwards like entrails from a gouged belly. It cleans up remarkably well, all things considered."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "sanshoom_prowlerrobe"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
	allowed_race = SPECIES_BASE_BODY

/obj/item/clothing/armor/leather/heavy/coat/donator_squidqueen
	name = "ragged longcoat"
	desc = "A longcoat that has been languishing without proper care for longer than you'd dare to imagine. It's hard to tell whether those brown splotches were born from sullied dyes or disturbed soil."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "squid_grimecoat"
	item_state = "squid_grimecoat"
	allowed_sex = list(FEMALE)
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/heavy/coat/donator_squidqueen_alt
	name = "frayed longcoat"
	desc = "A longcoat that has been languishing without proper care for longer than you'd dare to imagine. </br>'Had I tried to be your friend, would it have made a difference?'"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "squid_fraycoat"
	item_state = "squid_fraycoat"
	allowed_sex = list(FEMALE)
	color = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/studded/psyaltrist/donator_cuirass
	name = "heroic leather cuirass"
	desc = "A flexible vest, stitched together from lengths of cured leather. It hugs the wearer's form, gifting them a mimicked form of a sculpted physique - or maybe that's just a byproduct of it being so damn tight."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leathercuirass"
	item_state = "leathercuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/leather/studded/woodland/plackart
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrigp"
	item_state = "woodwalkerbrigp"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/bronze/donator_girdle
	name = "bronze plackart"
	desc = "A curious - and particularly revealing - variant of a bronze cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackartb"
	item_state = "plackartb"
	body_parts_covered = CHEST | VITALS
	flags_inv = null
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/fencer/tyesca
	name = "fencing brigandine"
	desc = "A lightweight fencing brigandine of Sembian make, popular among the duelling houses of Saerloon. A surcoat bearing its maker's house colours is sewn in as the interior lining."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "fencerbrig"
	item_state = "fencerbrig"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/aasimar
	name = "aasimari cuirass"
	desc = "A cuirass of polished gilbranze, tasseted and pauldroned. It has been meticulously sculpted to only fitthe physique of its wearer; one of Lathander's divine legionnaires."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "chiv_acuirass"
	allowed_sex = list(FEMALE)
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/apostle
	name = "apostolic cuirass"
	desc = "The one whom repents, whom has faith. </br> They whom remain unshaken, by the darkness of the world. </br> They are whom shall know true peace."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "apostlecuirass"
	item_state = "apostlecuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/dasfox
	name = "archaic ceremonial cuirass"
	desc = "A cuirass and tasset set of archaic design, tracing its lineage back to the fall of Netheril. House Timbermere makes sole use of its design within Duskmar, claiming it as their heritage right. This one has been gilded in Lathander's own colours atop a sleeved surcoat that bears heraldic colours."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "archaiccuirass"
	detail_tag = "_det"
	detail_color = CLOTHING_WHITE
	boobed = FALSE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/donator_gothic
	name = "gothic cuirass"
	desc = "A magnificent fluted cuirass, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gflutedcuirass"
	item_state = "gflutedcuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/robed
	name = "\improper Knight-Apostle's raiment"
	desc = "The one whom repents, whom has faith. </br> They whom remain unshaken, by the darkness of the world. </br> They are whom shall know true peace."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "robedcuirass"
	item_state = "robedcuirass"
	detail_tag = "_detail"
	color = null
	detail_color = CLOTHING_WHITE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/woodland
	name = "woodland brigandine"
	desc = "A set of fitted brigandine featuring hardened leather reinforced with steel plates beneath, worn over a light maille shirt. Its similarity to the Duskmarian wardens' brigandine is no accident: the elven rangers of the High Forest shared its design with their human fellows, who adapted it for their own needs."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrig"
	item_state = "woodwalkerbrig"
	detail_color = "#697F5C"
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/iron/donator_girdle
	name = "iron plackart"
	desc = "A curious - and particularly revealing - variant of an iron cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackarti"
	item_state = "plackarti"
	body_parts_covered = CHEST | VITALS
	flags_inv = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/iron/donator_gothic
	name = "gothic iron cuirass"
	desc = "A magnificent iron cuirass, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "igcuirass"
	item_state = "igcuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/iron/heartplate
	name = "iron heartplate"
	desc = "A curious - and particularly revealing - variant of an iron cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "heartplatei"
	item_state = "heartplatei"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/woodland/plackart
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrigp"
	item_state = "woodwalkerbrigp"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/fluted/ornate/donator_gothic
	name = "gothic half-plate"
	desc = "A magnificent set of half-plated ornate armor, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "ghalfplate"
	item_state = "ghalfplate"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/iron/donator_gothic
	name = "gothic iron plate armor"
	desc = "A magnificent set of iron plate armor, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "igplate"
	item_state = "igplate"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/robed/grandmaster
	name = "\improper Knight-Abbot's plated raiment"
	desc = "At the Demon's word, the sky grew crimson from flame. At our Lord's, the sound of ten thousand swords rang from their scabbards.</br> A great hymn rose over the blood-slaked fields, muddy from corpse and rain alike:</br> 'To Endure is to be Holy, as Our Lord is. Be as Him!'"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "dasfox_robedplate"
	item_state = "dasfox_robedplate"
	allowed_sex = list(FEMALE)
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/fluted/robed/grandmaster
	name = "\improper Knight-Abbot's plated raiment"
	desc = "At the Demon's word, the sky grew crimson from flame. At our Lord's, the sound of ten thousand swords rang from their scabbards.</br> A great hymn rose over the blood-slaked fields, muddy from corpse and rain alike:</br> 'To Endure is to be Holy, as Our Lord is. Be as Him!'"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "dasfox_robedplate"
	item_state = "dasfox_robedplate"
	allowed_sex = list(FEMALE)
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/iron/heavy/donator_gothic
	name = "gothic iron plate-and-maille"
	desc = "A magnificent iron cuirass, fitted atop a hauberk and assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "igcuirasshauberk"
	item_state = "igcuirasshauberk"

/obj/item/clothing/armor/chainmail/hauberk/iron/heavy/rockhill
	name = "jacketed iron plate-and-maille"
	desc = "A maille-aketon of iron, comfortably fitted beneath a matching cuirass and a thick clothspun jacket. Originating from Waterdeep's armories, this slightly-less-expensive alternative to plate armor was fashioned to ensure every man-at-arms could stand and face the fief's rising perils. The fabric can be dyed in ducal colors, to avert cases of 'friendly fireballing'."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "irockhillmaille"
	item_state = "irockhillmaille"
	detail_tag = "_detail"
	detail_color = COLOR_WHITE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/chainmail/hauberk/iron/heavy/zycuirass
	name = "iron gardbrace and fauld"
	desc = "An aged piece of damaged mailled cuirass, with only its skirt and a spiked shoulder remaining. It glimmers with a reddish hue."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "zy_cuirass"
	item_state = "zy_cuirass"
	sleevetype = "zy_cuirass"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/psydon/donator_gothic
	name = "gothic chestplate"
	desc = "A magnificent ornate cuirass, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gcuirass"
	item_state = "gcuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/donator_gothic_ap
	name = "gothic cuirass"
	desc = "A magnificent ornate cuirass, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gpsycuirass"
	item_state = "gpsycuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/woodland/plackart
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "woodwalkerbrigp"
	item_state = "woodwalkerbrigp"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/fluted/ornate/donator_gothic
	name = "gothic plate armor"
	desc = "A magnificent set of ornate plate armor, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "gplate"
	item_state = "gplate"
	misc_flags = CRAFTING_TEST_EXCLUDE
