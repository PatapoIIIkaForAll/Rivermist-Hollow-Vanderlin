/obj/item/clothing/neck/collar
	name = "collar"
	desc = "A band of leather which signifies bondage to another."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "collar"
	item_state = "collar"
	resistance_flags = FIRE_PROOF
	dropshrink = 0.5
	salvage_result = null
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/neck/collar

/obj/item/clothing/neck/collar/forlorn
	name = "light forlorn collar"
	desc = "A old reminder. A lighter version often used more as a status symbol for slaves. Then and now."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "iwolfcollaralt"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/collar/fur
	name = "fur collar"
	desc = "A thick ruff of trapped fur, worn about the shoulders."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "furscarf"
	item_state = "furscarf"
	salvage_result = /obj/item/natural/fur
	salvage_amount = 1
	sewrepair = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/collar/prisoner
	name = "castifico collar"
	desc = "A metal collar that seals around the neck, making it impossible to remove. It seems to be enchanted with some kind of vile magic..."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "castifico_collar"
	item_state = "castifico_collar"
	var/active_item = null
	var/bounty_amount = null
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK
	body_parts_covered = NONE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/collar/prisoner/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("This cursed collar enforces pacifism.")
	. += span_info("It releases on its own after a period of penance: five minutes, plus more for a higher bounty, up to twenty.")

/obj/item/clothing/neck/collar/prisoner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/neck/collar/prisoner/dropped(mob/user, silent = FALSE)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_PACIFISM, "castificocollar")
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/neck/collar/prisoner/proc/timerup(mob/living/carbon/human/user)
	REMOVE_TRAIT(user, TRAIT_PACIFISM, "castificocollar")
	visible_message(span_warning("The castifico collar opens with a click, falling off of [user]'s neck and clambering apart on the ground, their penance complete."))
	say("YOUR PENANCE IS COMPLETE.")
	for(var/name in GLOB.outlawed_players)
		if(user.real_name == name)
			GLOB.outlawed_players -= user.real_name
			priority_announce("[user.real_name] has completed their penance. Justice has been served in the eyes of Tempus.", "PENANCE", 'sound/misc/bell.ogg')
	playsound(src.loc, pick('sound/items/pickgood1.ogg','sound/items/pickgood2.ogg'), 5, TRUE)
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/neck/collar/prisoner/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	else if((slot & ITEM_SLOT_NECK))
		active_item = TRUE
		to_chat(user, span_warning("This accursed collar pacifies me!"))
		ADD_TRAIT(user, TRAIT_PACIFISM, "castificocollar")
		var/timer = 5 MINUTES //Base timer is 5 minutes, additional time added per bounty amount

		if(bounty_amount >= 10)
			var/additional_time = bounty_amount * 0.1 // 10 mammon = 1 minute
			additional_time = round(additional_time)
			timer += additional_time MINUTES
			timer = clamp(timer, 0 MINUTES, 20 MINUTES)

		var/timer_minutes = timer / 600

		addtimer(CALLBACK(src, PROC_REF(timerup), user), timer)
		say("YOUR PENANCE WILL BE COMPLETE IN [timer_minutes] MINUTES.")
	return

/obj/item/clothing/neck/collar/woolen
	name = "woolen collar"
	desc = "A comfortable and thick collar made of wools and cloth, not protective but it sure keeps your neck warm."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "woolencollar"
	item_state = "woolencollar"
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_MOUTH
	salvage_result = /obj/item/natural/cloth
	salvage_amount = 1
	color = CLOTHING_BLACK
	muteinmouth = FALSE
	spitoutmouth = FALSE
	sewrepair = TRUE

/obj/item/clothing/neck/gorget/cursed_collar
	name = "cursed collar"
	desc = "A metal collar that seems to radiate an ominous aura."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "cursed_collar"
	item_state = "cursed_collar"
	armor_type = /datum/armor/tree
	smeltresult = /obj/item/ingot/iron
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	max_integrity = ARMOR_INT_SIDE_DECREPIT
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK
	body_parts_covered = NECK
	blocksound = PLATEHIT
	ported_clothing = TRUE

/obj/item/clothing/neck/gorget/forlorncollar
	name = "forlorn collar"
	desc = "A old reminder."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "iwolfcollaralt"
	max_integrity = ARMOR_INT_SIDE_STEEL + 50
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
