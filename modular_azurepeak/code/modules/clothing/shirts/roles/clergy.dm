/obj/item/clothing/shirt/robe/hierophant
	name = "hierophant's kandys"
	desc = "A thin piece of fabric worn under a robe to stop chafing and keep ones dignity if a harsh blow of wind comes through. Despite the light fabric, it offers decent protection."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "desertgown"
	item_state = "desertgown"
	armor_type = /datum/armor/ported/padded
	color = null
	detail_color = null
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/robe/lunar
	name = "moonlit robe"
	desc = "A moon-silver robe that catches the glint of Mystra's light."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	icon_state = "lunarrobe"
	item_state = "lunarrobe"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	color = null
	ported_clothing = TRUE

/obj/item/clothing/shirt/robe/pointfex
	name = "pontifex's qaba"
	desc = "A slimmed down, tighter fitting robe made of fine silks and fabrics. Somehow you feel more mobile in it than in the nude. Despite the light fabric, it offers decent protection."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "monkcloth"
	item_state = "monkcloth"
	armor_type = /datum/armor/ported/padded
	color = null
	detail_color = null
	detail_tag = "_detail"
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/shirt/robe/ravox
	name = "Tempuran robe"
	desc = "None are above justice; none are beneath redemption."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = null
	icon_state = "ravoxrobe"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT|ITEM_SLOT_CLOAK
	body_parts_covered = CHEST|GROIN|LEGS|VITALS
	boobed = TRUE
	color = null
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	ported_clothing = TRUE

/obj/item/clothing/shirt/robe/undividedcleric
	name = "undivided clerical robe"
	desc = "Undivided, we walk - a Pantheon of Many, guiding Faerun's wanderers towards providence."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = null
	icon_state = "tenclericrobe"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT|ITEM_SLOT_CLOAK
	body_parts_covered = CHEST|GROIN|LEGS|VITALS
	boobed = TRUE
	color = null
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	ported_clothing = TRUE

/obj/item/clothing/shirt/robe/hierophant/loadout
	name = "aesthetic hierophant's kandys"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "desertgown"
	item_state = "desertgown"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/undershirt/priest/holy
	name = "holy monk vestments"
	desc = "Holy vestments, worn by those who pursue faith above all else. Hundreds of heavy leather strips have been meticulously sheared-and-stitched onto the cloth, resulting in unparalleled comfort and protection."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "monkvestments"
	item_state = "monkvestments"
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 1
	ported_clothing = TRUE
	adjustable = CAN_CADJUST
	ported_adjust = TRUE
	adj_open_coverage = (CHEST|GROIN|ARMS|VITALS)
	adj_sound = 'sound/foley/cloth_wipe (1).ogg'
	armor_type = /datum/armor/ported/padded

/obj/item/clothing/shirt/undershirt/priest/holy/equipped(mob/user, slot, initial = FALSE)
	..()
	to_chat(user, span_notice("With my vows to poverty and my vestments, I feel vigorous - empowered by my God!"))

/obj/item/clothing/shirt/undershirt/priest/holy/dropped(mob/user, silent = FALSE)
	..()
	to_chat(user, span_notice("I must lay down my robes and rest; even God's chosen must rest.."))

/obj/item/clothing/shirt/robe/pointfex/loadout
	name = "aesthetic pontifex's qaba"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "monkcloth"
	item_state = "monkcloth"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/dress/silkdress/bishop
	name = "bishop's cassock"
	desc = "Thine authority, divine; thine faith, unfettered."
	icon = 'modular_azurepeak/icons/clothing/shirts.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/shirts.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_shirts.dmi'
	icon_state = "bishoprobe"
	item_state = "bishoprobe"
	color = null
	allowed_race = SPECIES_BASE_BODY
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/abyssor_leader
	name = "sylveric robe"
	desc = "A long robe formed of many layers of thin, light fabric, designed not to grow heavy while waterlogged. Worn by exalted Umberlants who follow the path of the storm-painters, dyed in a pattern said to mirror the fury of the Bitch Queen's tempests."
	icon = 'modular_azurepeak/icons/clothing/special/abyssor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/abyssor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leaderrobe"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT|ITEM_SLOT_CLOAK
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
	boobed = TRUE
	color = null
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/abyssor_painter
	name = "rainfall robe"
	desc = "A long robe formed of many layers of thin, light fabric, designed not to grow heavy while waterlogged. Worn by Umberlants who follow the path of the storm-painters, dyed in a pattern that resembles rainfall."
	icon = 'modular_azurepeak/icons/clothing/special/abyssor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/abyssor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "rain"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT|ITEM_SLOT_CLOAK
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
	boobed = TRUE
	color = null
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/shirt/robe/abyssor_painter_sea
	name = "sea robe"
	desc = "A long robe formed of many layers of thin, light fabric, designed not to grow heavy while waterlogged. Worn by Umberlants who follow the path of the storm-painters, dyed in a pattern that resembles the waves of the Trackless Sea."
	icon = 'modular_azurepeak/icons/clothing/special/abyssor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/abyssor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "sea"
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT|ITEM_SLOT_CLOAK
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|VITALS
	boobed = TRUE
	color = null
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
