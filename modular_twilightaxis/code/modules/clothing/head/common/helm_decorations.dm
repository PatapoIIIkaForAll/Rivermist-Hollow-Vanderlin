/obj/item/clothing/head/antlers
	name = "old antlers"
	desc = "Old antlers which you can wear on helmet, hood....or straight on your head!"
	icon = 'modular_twilightaxis/icons/clothing/head.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/head_48.dmi'
	sleeved = null
	icon_state = "antlers"
	alternate_worn_layer = 8.9
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK|ITEM_SLOT_NECK
	resistance_flags = FIRE_PROOF
	var/picked = FALSE
	var/rogavid = list("halo", "knighty")
	var/antlers_final_icon = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/antlers/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/chooseA = browser_input_list(user, "What will you choose?", "Where you got it?", rogavid)
		if(!chooseA)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(chooseA == "halo")
			icon_state = "antlers"
			antlers_final_icon = "antlers"
		if(chooseA == "knighty")
			icon_state = "antlers_knighty"
			antlers_final_icon = "antlers_knighty"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()
		if(alert("Are you pleased with your antlers?", "Antlers", "Yes", "No") != "Yes")
			icon_state = "antlers"
			antlers_final_icon = "antlers"
			update_appearance()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/head/antlers/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(antlers_final_icon)
		icon_state = antlers_final_icon
		item_state = antlers_final_icon
		update_appearance()

/obj/item/clothing/head/antlers/dropped(mob/user, silent = FALSE)
	. = ..()
	if(antlers_final_icon)
		icon_state = antlers_final_icon
		item_state = antlers_final_icon
		update_appearance()

/obj/item/clothing/head/onhelm/tw_d_castle_red
	name = "castle helmkleinod"
	desc = "A finely crafted crest shaped like a castle turret. Fastened atop a helm, it symbolizes the wearer's steadfast resolve and unyielding defense."
	icon = 'modular_twilightaxis/icons/clothing/onhelm.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/onhelm.dmi'
	sleeved = null
	icon_state = "d_castle_red"
	item_state = "d_castle_red"
	var/picked = FALSE
	var/towavid = list("red", "white")
	var/towers_final_icon = null

/obj/item/clothing/head/onhelm/tw_d_castle_red/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/chooseA = browser_input_list(user, "What will you choose?", "Which colour?", towavid)
		if(!chooseA)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(chooseA == "red")
			icon_state = "d_castle_red"
			towers_final_icon = "d_castle_red"
		if(chooseA == "white")
			icon_state = "d_castle_white"
			towers_final_icon = "d_castle_white"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()
		if(alert("Are you pleased with your burlet?", "Burlet", "Yes", "No") != "Yes")
			icon_state = "d_castle_red"
			towers_final_icon = "d_castle_red"
			update_appearance()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/head/onhelm/tw_d_castle_red/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(towers_final_icon)
		icon_state = towers_final_icon
		item_state = towers_final_icon
		update_appearance()

/obj/item/clothing/head/onhelm/tw_d_castle_red/dropped(mob/user, silent = FALSE)
	. = ..()
	if(towers_final_icon)
		icon_state = towers_final_icon
		item_state = towers_final_icon
		update_appearance()

/obj/item/clothing/head/onhelm/tw_d_dragon_red
	name = "dragon's dread"
	desc = "A terrifying helm ornament depicting a legendary wyrm. To bear the dragon's dread is to cast a long, draconic shadow over the battlefield, inspiring awe and terror."
	icon = 'modular_twilightaxis/icons/clothing/onhelm.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/onhelm.dmi'
	sleeved = null
	icon_state = "d_dragon_red"
	item_state = "d_dragon_red"
	var/picked = FALSE
	var/drvid = list("red", "green")
	var/dragon_final_icon = null

/obj/item/clothing/head/onhelm/tw_d_dragon_red/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/chooseB = browser_input_list(user, "What will you choose?", "Which colour?", drvid)
		if(!chooseB)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(chooseB == "red")
			icon_state = "d_dragon_red"
			dragon_final_icon = "d_dragon_red"
		if(chooseB == "green")
			icon_state = "d_dragon_green"
			dragon_final_icon = "d_dragon_green"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()
		if(alert("Are you pleased with your burlet?", "Burlet", "Yes", "No") != "Yes")
			icon_state = "d_dragon_red"
			dragon_final_icon = "d_dragon_red"
			update_appearance()
			if(loc == user && ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		picked = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/head/onhelm/tw_d_dragon_red/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(dragon_final_icon)
		icon_state = dragon_final_icon
		item_state = dragon_final_icon
		update_appearance()

/obj/item/clothing/head/onhelm/tw_d_dragon_red/dropped(mob/user, silent = FALSE)
	. = ..()
	if(dragon_final_icon)
		icon_state = dragon_final_icon
		item_state = dragon_final_icon
		update_appearance()

/obj/item/clothing/head/onhelm/tw_d_efreet
	name = "afreet helmkleinod"
	desc = "A fearsome crest forged in the likeness of an afreet. Its menacing visage seems to dance with the fury of a roaring flame, warding off cowardly foes."
	icon = 'modular_twilightaxis/icons/clothing/onhelm.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/onhelm.dmi'
	sleeved = null
	icon_state = "d_efreet"
	item_state = "d_efreet"

/obj/item/clothing/head/onhelm/tw_d_horns
	name = "horns helmkleinod"
	desc = "A pair of imposing iron horns designed to be mounted atop a helmet, giving the wearer a beastly silhouette to strike fear into the hearts of their enemies."
	icon = 'modular_twilightaxis/icons/clothing/onhelm.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/onhelm.dmi'
	sleeved = null
	icon_state = "d_horns"
	item_state = "d_horns"

/obj/item/clothing/head/onhelm/tw_d_skull
	name = "gold skull helmkleinod"
	desc = "A macabre yet opulent golden skull. It is a morbid memento mori, daring death to claim the wealthy and arrogant warrior who wears it."
	icon = 'modular_twilightaxis/icons/clothing/onhelm.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/onhelm.dmi'
	sleeved = null
	icon_state = "d_skull"
	item_state = "d_skull"

/obj/item/clothing/head/onhelm/tw_d_swan
	name = "swan on lake"
	desc = "An intricate crest portraying a graceful swan resting upon gentle waters. It is a symbol of purity, elegance, and unwavering calm amidst the storm of war."
	icon = 'modular_twilightaxis/icons/clothing/onhelm.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/onhelm.dmi'
	sleeved = null
	icon_state = "d_swan"
	item_state = "d_swan"

/obj/item/clothing/head/onhelm/tw_d_windmill
	name = "windmill helmkleinod"
	desc = "A peculiar windmill crest. Though humble in origin, it shows a proud connection to the homeland's sweeping plains and tireless industry."
	icon = 'modular_twilightaxis/icons/clothing/onhelm.dmi'
	mob_overlay_icon = 'modular_twilightaxis/icons/clothing/onmob/32x48/onhelm.dmi'
	sleeved = null
	icon_state = "d_windmill"
	item_state = "d_windmill"
