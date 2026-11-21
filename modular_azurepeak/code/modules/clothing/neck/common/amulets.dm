/obj/item/clothing/neck/carved
	name = "carved amulet"
	desc = "You shouldn't be seeing this."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "amulet_jade"
	item_state = "amulet_jade"
	sellprice = 0
	salvage_result = null
	smeltresult = null
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HIP|ITEM_SLOT_WRISTS
	possible_item_intents = list(/datum/intent/use)
	experimental_onhip = TRUE
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	grid_width = 32
	grid_height = 32
	var/wrist_display = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/carved/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	. = ..()
	if(!.)
		return

	if((slot & ITEM_SLOT_WRISTS) || (wrist_display && slot != ITEM_SLOT_NECK))
		mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
		sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	else
		mob_overlay_icon = initial(mob_overlay_icon)
		sleeved = initial(sleeved)

	return TRUE

/obj/item/clothing/neck/carved/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!ismob(loc))
		return .

	wrist_display = !wrist_display
	to_chat(user, span_info("You adjust \the [src] to [wrist_display ? "display on your wrists" : "display around your neck"]."))
	if(wrist_display)
		mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
		sleeved = 'modular_azurepeak/icons/clothing/onmob/wrists.dmi'
	else
		mob_overlay_icon = initial(mob_overlay_icon)
		sleeved = initial(sleeved)

	if(isliving(loc))
		var/mob/living/L = loc
		L.regenerate_clothes()
	return .

/obj/item/clothing/neck/luckcharm
	name = "luck charm"
	desc = "A cabbit's foot necklace. Some say it brings good luck. It only feels more lucky when it's worn around the neck."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "luckcharm"
	possible_item_intents = list(/datum/intent/use)
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HIP|ITEM_SLOT_WRISTS
	grid_width = 32
	grid_height = 32
	var/goodluckactivated = FALSE
	salvage_result = /obj/item/natural/fibers
	salvage_amount = 1
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/luckcharm/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if((slot & ITEM_SLOT_NECK))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_LCK) = 1))
		goodluckactivated = TRUE
	return

/obj/item/clothing/neck/luckcharm/dropped(mob/living/user, silent = FALSE)
	. = ..()
	if(goodluckactivated == TRUE)
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		goodluckactivated = FALSE
	return

/obj/item/clothing/neck/ornateamulet
	name = "ornate amulet"
	desc = "A beautiful amulet made of solid gold."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "ornateamulet"
	resistance_flags = FIRE_PROOF
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	ported_clothing = TRUE

/obj/item/clothing/neck/skullamulet
	name = "skull amulet"
	desc = "Gold shaped into the form of a skull and strung into an amulet."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "skullamulet"
	resistance_flags = FIRE_PROOF
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	ported_clothing = TRUE

/obj/item/clothing/neck/carved/amberamulet
	name = "amber amulet"
	desc = "A beautiful amulet carved from amber, donnable on both the neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "amulet_amber"

/obj/item/clothing/neck/carved/coralamulet
	name = "heartstone amulet"
	desc = "A beautiful amulet carved from heartstone, donnable on both the neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "amulet_coral"

/obj/item/clothing/neck/carved/goldamber
	name = "golden amber amulet"
	desc = "A luxurious golden amulet encrusted with a polished piece of amber, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "gold_amber"

/obj/item/clothing/neck/carved/goldcoral
	name = "golden heartstone amulet"
	desc = "A luxurious golden amulet encrusted with a polished piece of heartstone, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "gold_coral"

/obj/item/clothing/neck/carved/goldjade
	name = "golden jade amulet"
	desc = "A luxurious golden amulet encrusted with a polished piece of jade, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "gold_jade"

/obj/item/clothing/neck/carved/goldonyxa
	name = "golden onyxa amulet"
	desc = "A luxurious golden amulet encrusted with a polished piece of onxya, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "gold_onyxa"

/obj/item/clothing/neck/carved/goldopal
	name = "golden opal amulet"
	desc = "A luxurious golden amulet encrusted with a polished piece of opal, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "gold_opal"

/obj/item/clothing/neck/carved/goldrose
	name = "golden rosestone amulet"
	desc = "A luxurious golden amulet encrusted with a polished piece of rosestone, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "gold_rose"

/obj/item/clothing/neck/carved/goldshell
	name = "golden shell amulet"
	desc = "A luxurious golden amulet encrusted with a polished piece of clam shell, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "gold_shell"

/obj/item/clothing/neck/carved/goldturq
	name = "golden cerulite amulet"
	desc = "A luxurious golden amulet encrusted with a polished piece of cerulite, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "gold_turq"

/obj/item/clothing/neck/carved/jadeamulet
	name = "jade amulet"
	desc = "A beautiful amulet carved from jade, donnable on both the neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "amulet_jade"

/obj/item/clothing/neck/carved/opalamulet
	name = "opal amulet"
	desc = "A beautiful amulet carved from opal, donnable on both the neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "amulet_opal"

/obj/item/clothing/neck/carved/porcelainamulet
	name = "porcelain amulet"
	desc = "A dainty amulet made out of fine porcelain, donnable on both the neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "amulet_porcelain"
	toggle_icon_state = FALSE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/carved/roseamulet
	name = "rosestone amulet"
	desc = "A beautiful amulet carved from rosestone, donnable on both the neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "amulet_rose"

/obj/item/clothing/neck/carved/silveramber
	name = "silver amber amulet"
	desc = "A luxurious silver amulet encrusted with a polished piece of amber, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "silver_amber"

/obj/item/clothing/neck/carved/silvercoral
	name = "silver heartstone amulet"
	desc = "A luxurious silver amulet encrusted with a polished piece of heartstone, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "silver_coral"

/obj/item/clothing/neck/carved/silverjade
	name = "silver jade amulet"
	desc = "A luxurious silver amulet encrusted with a polished piece of jade, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "silver_jade"

/obj/item/clothing/neck/carved/silveronyxa
	name = "silver onyxa amulet"
	desc = "A luxurious silver amulet encrusted with a polished piece of onxya, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "silver_onyxa"

/obj/item/clothing/neck/carved/silveropal
	name = "silver opal amulet"
	desc = "A luxurious silver amulet encrusted with a polished piece of opal, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "silver_opal"

/obj/item/clothing/neck/carved/silverrose
	name = "silver rosestone amulet"
	desc = "A luxurious silver amulet encrusted with a polished piece of rosestone, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "silver_rose"

/obj/item/clothing/neck/carved/silvershell
	name = "silver shell amulet"
	desc = "A luxurious silver amulet encrusted with a polished piece of heartstone, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "silver_shell"

/obj/item/clothing/neck/carved/silverturq
	name = "silver cerulite amulet"
	desc = "A luxurious silver amulet encrusted with a polished piece of cerulite, donnable both on neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "silver_turq"

/obj/item/clothing/neck/carved/turqamulet
	name = "cerulite amulet"
	desc = "A beautiful amulet carved from cerulite, donnable on both the neck and wrist."
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "amulet_turq"

/obj/item/clothing/neck/skullamulet/gemerald
	name = "gemerald skull amulet"
	desc = "A massive gemerald, meticulously chiseled into a skull and affixed to a chain. </br>'You're mocking me, aren't you?'"
	icon = 'modular_azurepeak/icons/clothing/neck_2.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/neck.dmi'
	sleeved = null
	icon_state = "skullamulet"
	slot_flags = ITEM_SLOT_NECK
	color = "#00FF00"
	resistance_flags = FIRE_PROOF
	sellprice = 222
	smeltresult = /obj/item/gem/green
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	var/luckyskull = FALSE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/neck/skullamulet/gemerald/Initialize(mapload)
	. = ..()
	add_filter(FORCE_FILTER, 2, list("type" = "outline", "color" = "#A0E65C", "alpha" = 200, "size" = 1))

/obj/item/clothing/neck/skullamulet/gemerald/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if((slot & ITEM_SLOT_NECK))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_LCK) = 2))
		luckyskull = TRUE
	return

/obj/item/clothing/neck/skullamulet/gemerald/dropped(mob/living/user, silent = FALSE)
	. = ..()
	if(luckyskull == TRUE)
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		luckyskull = FALSE
	return
