/obj/item/clothing/gloves/knuckles/bronze/zizoconstruct
	name = "construct knuckles"
	desc = "A vicous pair of bronze knuckles designed specifically for constructs. There is a terrifying, hollow spike in the center of the grip. There doesn't seem to be a way to wield it without impaling yourself."
	icon = 'modular_azurepeak/icons/clothing/unarmed32.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "bronzeknuckle"
	color = "#5f1414"
	max_integrity = 500
	anvilrepair = /datum/attribute/skill/craft/engineering
	unarmed_bonus = 8
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/knuckles/bronze/zizoconstruct/pickup(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_BLOODLOSS_IMMUNE))
		to_chat(user, "<font color='purple'> You attempt to wield the knuckles. The spike sinks deeply into your hand, piercing it and drinking deep of your vital energies!</font>")
		user.adjustBruteLoss(15)
		user.Stun(40)
		playsound(get_turf(user), 'sound/misc/drink_blood.ogg', 100)
	..()

/obj/item/clothing/gloves/fingerless_leather/muffle_matthios
	name = "gilded fingerless gloves"
	desc = "Those who grasp at Fyre, are bount to be burned."
	icon = 'modular_azurepeak/icons/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/gloves.dmi'
	icon_state = "roguegloves"
	sewrepair = TRUE
	armor_type = /datum/armor/ported/leather
	color = "#fce517"
	var/active_item = FALSE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/gloves/fingerless_leather/muffle_matthios/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(obj_broken || active_item)
		return

/obj/item/clothing/gloves/fingerless_leather/muffle_matthios/dropped(mob/user, silent = FALSE)
	. = ..()
	if(!active_item)
		return
	active_item = FALSE
	to_chat(user, span_info("Once again, these hands are supplicant."))
