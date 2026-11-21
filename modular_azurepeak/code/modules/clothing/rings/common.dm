/obj/item/clothing/ring/aalloy
	name = "decrepit ring"
	desc = "A coil of rotted metal."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "ring_a"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/band
	name = "silver weddingband"
	desc = "A glimmering weddingband of silver, ornately decorated with the engravings of a lover's name."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "s_ring_wedding"
	var/choicename = FALSE
	var/choicedesc = FALSE
	ported_clothing = TRUE

/obj/item/clothing/ring/band/attack_hand_secondary(mob/user, list/modifiers)
	if(choicename || choicedesc)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/namechoice = browser_input_text(user, "Input a new name", "Rename Object", max_length = MAX_NAME_LEN)
	var/descchoice = browser_input_text(user, "Input a new description", "Describe Object", max_length = 256)
	if(QDELETED(src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(namechoice)
		name = namechoice
		choicename = TRUE
	if(descchoice)
		desc = descchoice
		choicedesc = TRUE
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/ring/band/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to add a custom name and description to the weddingband.")

/obj/item/clothing/ring/blacksteel
	name = "blacksteel ring"
	desc = "A ring of mythical blacksteel."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "ring_bs"
	ported_clothing = TRUE

/obj/item/clothing/ring/bronze
	name = "bronze ring"
	desc = "A ring of bronzen resiliance."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "ring_b"
	ported_clothing = TRUE

/obj/item/clothing/ring/diamond
	name = "dorpel ring"
	desc = "A beautiful golden ring with a polished dorpel set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_ring_diamond"
	smeltresult = /obj/item/gem/diamond
	ported_clothing = TRUE

/obj/item/clothing/ring/diamondbs
	name = "dorpel ring of blacksteel"
	desc = "A mythical blacksteel ring with a polished Dorpel set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "bs_ring_diamond"
	sellprice = 370
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/diamonds
	name = "silver dorpel ring"
	desc = "A glimmering silver ring with a polished dorpel set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "s_ring_diamond"
	smeltresult = /obj/item/gem/diamond
	ported_clothing = TRUE

/obj/item/clothing/ring/dragon_ring_ap
	name = "dragonstone ring"
	desc = "A gilded blacksteel ring with a drake's head, sculpted from silver. Perched within its sockets is a blortz and saffira - each, crackling with the reflection of a raging fire."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "dragonring"
	sellprice = 666
	var/active_item = null
	ported_clothing = TRUE

/obj/item/clothing/ring/dragon_ring_ap/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	else if((slot & ITEM_SLOT_RING))
		active_item = TRUE
		to_chat(user, span_suicide("Draconic fire courses through my veins! I feel powerful!"))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_STR) = 2, (STATKEY_CON) = 2, (STATKEY_END) = 2))
		update_appearance()
	return

/obj/item/clothing/ring/dragon_ring_ap/dropped(mob/living/user, silent = FALSE)
	..()
	if(active_item)
		to_chat(user, span_suicide("A chilling sensation courses through my body, and the ring's heat remains oh-so-alluring.. </br>..yet, one must wonder.. could such fiery strength withstand a forge's heat?"))
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		active_item = FALSE
		update_appearance()
	return

/obj/item/clothing/ring/dragon_ring_ap/update_icon_state()
	. = ..()
	icon_state = active_item ? "factive" : "dragonring"

/obj/item/clothing/ring/duelist
	name = "duelist's ring"
	desc = "Born out of duelists desire for theatrics, this ring denotes a proposal — an honorable duel, with stakes set ahigh.\nIf both duelists wear this ring, successful baits will off balance them, and clashing disarms will never be unlikely.\n<i>'You shall know his name. You shall know his purpose. You shall die.'</i>"
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "ring_duel"
	ported_clothing = TRUE

/obj/item/clothing/ring/emerald
	name = "gemerald ring"
	desc = "A beautiful golden ring with a polished gemerald set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_ring_emerald"
	smeltresult = /obj/item/gem/green
	ported_clothing = TRUE

/obj/item/clothing/ring/emeraldbs
	name = "gemerald ring of blacksteel"
	desc = "A mythical blacksteel ring with a polished Gemerald set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "bs_ring_emerald"
	sellprice = 295
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/emeralds
	name = "silver gemerald ring"
	desc = "A glimmering silver ring with a polished gemerald set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "s_ring_emerald"
	smeltresult = /obj/item/gem/green
	ported_clothing = TRUE

/obj/item/clothing/ring/lief_ring
	name = "Blortz Blacksteel Engagement Ring"
	desc = "A promise bound in blacksteel and a memory to stand the tests of time. The glimmering gem winks back at you to remind you of a time unchanged. Delicately engraved on the inside of the band, Always there for you. -Lief."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "blacksteel_blortz"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/porcelain
	name = "porcelain ring"
	desc = "A ring of shining porcelain."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "ring_porcelain"
	toggle_icon_state = FALSE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/quartz
	name = "blortz ring"
	desc = "A beautiful golden ring with a polished blortz set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_ring_quartz"
	smeltresult = /obj/item/gem/blue
	ported_clothing = TRUE

/obj/item/clothing/ring/quartzbs
	name = "blortz ring of blacksteel"
	desc = "A mythical blacksteel ring with a polished Blortz set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "bs_ring_quartz"
	sellprice = 345
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/quartzs
	name = "silver blortz ring"
	desc = "A glimmering silver ring with a polished blortz set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "s_ring_quartz"
	smeltresult = /obj/item/gem/blue
	ported_clothing = TRUE

/obj/item/clothing/ring/ruby
	name = "rontz ring"
	desc = "A beautiful golden ring with a polished rontz set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_ring_ruby"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/rubybs
	name = "rontz ring of blacksteel"
	desc = "A mythical blacksteel ring with a polished Rontz set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "bs_ring_ruby"
	sellprice = 355
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/rubys
	name = "silver rontz ring"
	desc = "A glimmering silver ring with a polished rontz set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "s_ring_ruby"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/sapphire
	name = "saffira ring"
	desc = "A beautiful golden ring with a polished saffira set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_ring_sapphire"
	smeltresult = /obj/item/gem/violet
	ported_clothing = TRUE

/obj/item/clothing/ring/sapphirebs
	name = "saffira ring of blacksteel"
	desc = "A mythical blacksteel ring with a polished Saffira set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "bs_ring_sapphire"
	sellprice = 300
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/sapphires
	name = "silver saffira ring"
	desc = "A glimmering silver ring with a polished saffira set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "s_ring_sapphire"
	smeltresult = /obj/item/gem/violet
	ported_clothing = TRUE

/obj/item/clothing/ring/statdorpel
	name = "ring of omnipotence"
	desc = "A dorpel ring, glowing with resplendent beauty. The closer your hand drifts to it, the more that your fears melt away."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "newmulticolor"
	smeltresult = /obj/item/riddleofsteel
	sellprice = 777
	var/active_item = null
	ported_clothing = TRUE

/obj/item/clothing/ring/statdorpel/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	else if((slot & ITEM_SLOT_RING))
		active_item = TRUE
		to_chat(user, span_blue("'..the way of hope, unbreakable and unifying..'"))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_SPD) = 1, (STATKEY_LCK) = 1, (STATKEY_INT) = 1, (STATKEY_PER) = 1, (STATKEY_CON) = 1, (STATKEY_END) = 1, (STATKEY_STR) = 1))
	return

/obj/item/clothing/ring/statdorpel/dropped(mob/living/user, silent = FALSE)
	..()
	if(active_item)
		to_chat(user, span_blue("'..I know that kindness exists, for I am kind..' </br>'..I know hope exists, for I have hope..' </br>'..and I know love exists, for I love.'"))
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		active_item = FALSE
	return

/obj/item/clothing/ring/statgemerald
	name = "ring of swiftness"
	desc = "A gemerald ring, glimmering with verdant brilliance. The closer your hand drifts to it, the stronger that the wind howls."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_newring_emerald"
	sellprice = 222
	var/active_item = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/statgemerald/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	else if((slot & ITEM_SLOT_RING))
		active_item = TRUE
		to_chat(user, span_green("'..the way of lyfe, bountiful but fleeting..'"))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_SPD) = 1, (STATKEY_LCK) = 1))
	return

/obj/item/clothing/ring/statgemerald/dropped(mob/living/user, silent = FALSE)
	..()
	if(active_item)
		to_chat(user, span_green("'..but without an end to the journey, what would become of lyfe's meaning?'"))
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		active_item = FALSE
	return

/obj/item/clothing/ring/statonyx
	name = "ring of vitality"
	desc = "An onyx ring, shining with violet determination. The closer your hand drifts to it, the faster your heart pounds."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_newring_quartz"
	sellprice = 222
	var/active_item = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/statonyx/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	else if((slot & ITEM_SLOT_RING))
		active_item = TRUE
		to_chat(user, span_purple("'..the way of blood, shed from you in vain..'"))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_CON) = 1, (STATKEY_END) = 1))
	return

/obj/item/clothing/ring/statonyx/dropped(mob/living/user, silent = FALSE)
	..()
	if(active_item)
		to_chat(user, span_purple("'..but if you don't stand for those who cannot, who will?'"))
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		active_item = FALSE
	return

/obj/item/clothing/ring/statrontz
	name = "ring of courage"
	desc = "A rontz ring, radiating with crimson authority. The closer your hand drifts to it, the tighter your knuckles curl."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_newring_ruby"
	sellprice = 222
	var/active_item = null
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/statrontz/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(active_item)
		return
	else if((slot & ITEM_SLOT_RING))
		active_item = TRUE
		to_chat(user, span_warning("'..the way of death, indiscriminate and total..'"))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_STR) = 1))
	return

/obj/item/clothing/ring/statrontz/dropped(mob/living/user, silent = FALSE)
	..()
	if(active_item)
		to_chat(user, span_warning("'..but without violence, what would stop evil from triumphing?'"))
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		active_item = FALSE
	return

/obj/item/clothing/ring/topaz
	name = "toper ring"
	desc = "A beautiful golden ring with a polished toper set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_ring_topaz"
	smeltresult = /obj/item/gem/yellow
	ported_clothing = TRUE

/obj/item/clothing/ring/topazbs
	name = "toper ring of blacksteel"
	desc = "A mythical blacksteel ring with a polished Toper set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "bs_ring_topaz"
	sellprice = 380
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/topazs
	name = "silver toper ring"
	desc = "A glimmering silver ring with a polished toper set into it."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "s_ring_topaz"
	smeltresult = /obj/item/gem/yellow
	ported_clothing = TRUE

/obj/item/clothing/ring/band/aalloy
	name = "decrepit weddingband"
	desc = "A decaying weddingband of rotted metal, ornately decorated with the engravings of a lover's name."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "a_ring_wedding"
	color = "#bb9696"
	anvilrepair = null
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/band/bronze
	name = "bronze weddingband"
	desc = "A resilient weddingband of bronze, ornately decorated with the engravings of a lover's name."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "b_ring_wedding"

/obj/item/clothing/ring/band/gold
	name = "gold weddingband"
	desc = "A beautiful weddingband of gold, ornately decorated with the engravings of a lover's name."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_ring_wedding"

/obj/item/clothing/ring/band/paalloy
	name = "ancient weddingband"
	desc = "An enchanting weddingband of polished gilbranze, ornately decorated with the engravings of a lover's name."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "a_ring_wedding"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/statgemerald/antiquarian
	desc = "A gemerald ring, glimmering with verdant brilliance. The closer your hand drifts to it, the stronger that the wind howls. The precious stone has chipped with long use, and is quite worthless except in its magick."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_newring_emerald"
	sellprice = 30
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/ring/statonyx/antiquarian
	desc = "An onyx ring, shining with violet determination. The closer your hand drifts to it, the faster your heart pounds. The precious stone has chipped with long use, and is quite worthless except in its magick."
	icon = 'modular_azurepeak/icons/clothing/rings.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/rings.dmi'
	icon_state = "g_newring_quartz"
	sellprice = 30
	misc_flags = CRAFTING_TEST_EXCLUDE
