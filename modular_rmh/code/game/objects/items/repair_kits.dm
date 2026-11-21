/obj/item/repair_kit
	name = "Armor repair kit"
	desc = "A pile of various plates, chainmail pieces, and other junk that will be critical in those difficult times. This set can repair five serious damages."
	icon = 'modular_rmh/icons/obj/items/repair_kits.dmi'
	icon_state = "armorkit"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 0
	slot_flags = ITEM_SLOT_HIP
	melt_amount = 20
	grid_width = 32
	grid_height  = 64
	melting_material = /datum/material/steel

	//vars
	var/for_clothing = FALSE
	var/for_armor = TRUE
	var/amount_repair = 5
	var/repair_percent = 5


// Runs before storage insertion, so clothing with pockets gets repaired instead of filled.
/obj/item/repair_kit/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	// Worn, held or stored clothing falls through, so the kit can still go into bags.
	if(!isclothing(interacting_with) || !isturf(interacting_with.loc))
		return NONE
	if(!user.mind || user.cmode)
		return NONE
	var/obj/item/clothing/attacked_item = interacting_with

	if(for_armor && attacked_item.sewrepair)
		to_chat(user, span_warning("[src] only for armor!"))
		return ITEM_INTERACT_BLOCKING
	if(for_clothing && attacked_item.anvilrepair)
		to_chat(user, span_warning("[src] only for clothing!"))
		return ITEM_INTERACT_BLOCKING
	if(!attacked_item.max_integrity || (attacked_item.get_integrity() >= attacked_item.max_integrity))
		to_chat(user, span_warning("[attacked_item] cannot be repaired any further."))
		return ITEM_INTERACT_BLOCKING

	var/percent = repair_percent
	if(locate(/obj/machinery/anvil) in attacked_item.loc)
		percent *= 2
	attacked_item.repair_damage(attacked_item.max_integrity * percent)
	attacked_item.obj_broken = FALSE
	user.visible_message(span_info("[user] repairs most important parts [attacked_item]!"))
	amount_repair -= 1
	if(amount_repair <= 0)
		to_chat(user, span_warning("There was nothing left of the repair kit"))
		qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/repair_kit/poor_armorkit
	name = "Poor armor repair kit"
	desc = "A small amount of scrap, metal patches and tapes that will help repair your armor twice."
	icon_state = "poor_armorkit"
	for_clothing = FALSE
	for_armor = TRUE
	amount_repair = 2
	melting_material = /datum/material/iron

/obj/item/repair_kit/sewingkit
	name = "Sewing kit"
	desc = "Thread, fabric, and leather patches—this is a serious tool for a thrifty housewife or seasoned traveler. It can mend your clothes 10 times over."
	icon_state = "sewingkit"
	for_clothing = TRUE
	for_armor = FALSE
	amount_repair = 10
	smeltresult = /obj/item/fertilizer/ash

/obj/item/repair_kit/poor_sewingkit
	name = "Poor sewing kit"
	desc = "A little fabric and thread is all you need to patch a sock or a hole in your underwear. It can mend clothes twice."
	icon_state = "poor_sewingkit"
	for_clothing = TRUE
	for_armor = FALSE
	amount_repair = 5
	smeltresult = /obj/item/fertilizer/ash

// MERCHANT SELL
/datum/supply_pack/tools/poor_armorkit
	name = "Poor armor repair kit"
	cost = 25
	contains = /obj/item/repair_kit/poor_armorkit

/datum/supply_pack/tools/poor_sewingkit
	name = "Poor sewing kit"
	cost = 15
	contains = /obj/item/repair_kit/poor_sewingkit

/datum/supply_pack/tools/repair_kit
	name = "Armor repair kit"
	cost = 50
	contains = /obj/item/repair_kit

/datum/supply_pack/tools/sewingkit
	name = "Sewing kit"
	cost = 35
	contains = /obj/item/repair_kit/sewingkit
