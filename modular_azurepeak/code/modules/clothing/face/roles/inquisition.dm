/obj/item/clothing/face/facemask/steel/confessor_ap
	name = "strange mask"
	desc = "It is said that the original version of this mask was used for obscure rituals before the fall of Netheril, and it has since been repurposed as a veil for the cunning hand of the Amnian inquisitors.<br> <br>Others call it heresy, a necessary evil, capable of keeping its wearer safe from left-handed magicks. You can taste copper whenever you draw breath."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "confessormask"
	max_integrity = 200
	equip_sound = 'sound/items/confessormaskon.ogg'
	smeltresult = /obj/item/ingot/steel
	var/worn = FALSE
	slot_flags = ITEM_SLOT_MASK
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/face/facemask/steel/confessor_ap

/obj/item/clothing/face/facemask/steel/confessor_ap/equipped(mob/living/carbon/human/user, slot, initial = FALSE)
	. = ..()
	if(user.wear_mask == src)
		worn = TRUE

/obj/item/clothing/face/facemask/steel/confessor_ap/dropped(mob/user, silent = FALSE)
	. = ..()
	if(worn)
		playsound(user, 'sound/items/confessormaskoff.ogg', 80)
		worn = FALSE

/obj/item/clothing/face/facemask/steel/confessor_ap/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/I = attacking_item
	. = ..()
	if(istype(I, /obj/item/clothing/face/spectacles/inq))
		user.visible_message(span_warning("[user] starts to insert [I]'s lenses into [src]."))
		if(do_after(user, 4 SECONDS))
			var/obj/item/clothing/face/facemask/steel/confessor/lensed/P = new /obj/item/clothing/face/facemask/steel/confessor/lensed(get_turf(src.loc))
			if(user.is_holding(src))
				user.dropItemToGround(src)
				user.put_in_hands(P)
			P.update_integrity(src.get_integrity())
			qdel(src)
			qdel(I)
		else
			user.visible_message(span_warning("[user] stops inserting the lenses into [src]."))
		return

/obj/item/clothing/face/facemask/steel/confessor_ap/pyro
	name = "insulated breath-mask"
	desc = "A product of strange artifice, painstakingly replicated from ancient design. Protects the wearer from noxious fumes and shrapnel to the eyes. You can taste soot whenever you draw breath."
	icon = 'modular_azurepeak/icons/clothing/masks_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/masks.dmi'
	sleeved = null
	icon_state = "pyromask"
	max_integrity = 100
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	armor_type = /datum/armor/ported/insulated_leather
	smeltresult = /obj/item/ingot/bronze
	block2add = FOV_DEFAULT
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/facemask/steel/confessor_ap/pyro/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	var/obj/item/I = attacking_item
	if(istype(I, /obj/item/clothing/face/spectacles/inq))
		to_chat(user, span_info("These lenses won't fit in this mask."))
		return
	return ..()
