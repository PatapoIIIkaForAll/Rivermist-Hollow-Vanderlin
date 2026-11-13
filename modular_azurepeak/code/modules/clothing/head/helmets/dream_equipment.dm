/obj/item/clothing/head/helmet/heavy/abyssor_painter
	name = "sylveric helmet"
	desc = "Much like the accompanying robes, this sylveric creation serves to obscure the wearer - whether to hide a horrifically sea-changed visage, as rumours about the Bitch Queen's oracles insist, or to hide a less than imposing dark elf who would rather not undermine their own mystique. It is hardly as sturdy as true armour; the thin, flaky metal lets the wearer see clearly but protects little."
	icon = 'modular_azurepeak/icons/clothing/special/abyssor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/abyssor.dmi'
	sleeved = null
	icon_state = "leaderhelm"
	flags_inv = HIDEFACE|HIDEEARS|HIDEHAIR
	body_parts_covered = FULL_HEAD
	adjustable = CANT_CADJUST
	smeltresult = null
	item_flags = (1<<13)
	armor_class = AC_LIGHT
	max_integrity = ARMOR_INT_HELMET_HARDLEATHER
	armor_type = /datum/armor/ported/padded
	block2add = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/helmet/heavy/abyssor_painter/attack_self(mob/user, list/modifiers)
	..()
	if(icon_state == "leaderhelm")
		icon_state = "leaderhelm_f"
		to_chat(user, span_notice("You adjust [src] into a sleek configuration."))
	else
		icon_state = "leaderhelm"
		to_chat(user, span_notice("You adjust [src] back to its standard configuration."))

	update_appearance()
	if(loc == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()
