/obj/item/clothing/cloak/longest_night
	name = "Longest Night Cloak"
	desc = "A silver lined cloak, capable of quickly being wrapped around the arm for comfort. The Longest Night sect is an underground 'association,' those involved are often those who wish to be the least, and those who wish to be a part will never be. Few know of the sect, fewer of their secrets.\ </br>Inside the cloak, woven words preach,\ </br>‎<font color='c4c9d2'>Are those within the cave to be faulted, when all they know of reality are the shadows it casts on the wall?</br>Fault or not, it falls upon us to lead them out of that wretched cave.</font>"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = null
	icon_state = "night_cloak"
	experimental_inhand = FALSE
	experimental_onback = FALSE
	alternate_worn_layer = 16
	lefthand_file = 'icons/mob/inhands/weapons/rogue_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/rogue_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_BACK_L
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/furcloak/woodland
	name = "woodland mantle"
	desc = "A flowing cloak that can be worn tighter or looser as the wearer deems fit. More than suitable for protection from the elements, the concealment of one's identity or as a warm blanket during those cold nites."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	icon_state = "woodwalkcloak"
	item_state = "woodwalkcloak"
	boobed = FALSE
	nodismemsleeves = TRUE
	inhand_mod = TRUE
	flags_inv = HIDECROTCH|HIDEBOOB
	color = CLOTHING_WHITE
	allowed_sex = list(MALE, FEMALE)
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	sleevetype = "shirt"
	detail_tag = "_detail"
	detail_color = "#365326"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/half/donator_rezathedwarf
	name = "Noah's Glimmering Cloak"
	desc = "Cloak from the infamous Redcloaks, said to have dyed their cloaks in the blood of their first kills. Even now, it pulses and brightens with magical energy of wild color, perhaps of the dead souls that are rumored to be within it. If the old stories are true, anyone who wears this is sure to go insane."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "rezacloak"
	color = CLOTHING_SCARLET
	detail_tag = "_detail"
	detail_color = CLOTHING_GOLD
	allowed_sex = list(MALE)
	allowed_race = SPECIES_BASE_BODY
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/half/donator_rezathedwarf/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/cloak/poncho/donator_thisle
	name = "underdwelling artificer's poncho"
	desc = "A loose garment that is usually draped across ones upper body. It's still smattered with patches of soot and mushroom-drool, though the darker silks fortunately keep those stains unnoticeable to passing eyes."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "thistleponcho"
	item_state = "thistleponcho"
	alternate_worn_layer = TABARD_LAYER
	boobed = FALSE
	flags_inv = HIDECROTCH|HIDEBOOB
	slot_flags = ITEM_SLOT_CLOAK|ITEM_SLOT_ARMOR
	sleevetype = "poncho"
	nodismemsleeves = TRUE
	allowed_sex = list(FEMALE)
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/raincloak/tyesca
	name = "\improper Szöréndnížine banner-cloak"
	desc = "A harsh reality that comes from yils of travel is the lack of protections one might have. This cloak is designed from the repurposed canvas of a Szöréndnížine banner that's often in the belongings of Freelancers so far from home. Both serving as a reminder of what they travel and fight for, and some protection from the elements."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "fencercloak"
	item_state = "fencercloak"
	boobed = FALSE
	sleevetype = "feather_cloak"
	hoodtype = /obj/item/clothing/head/hooded/rainhood/tyesca
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/furcloak/woodland/donator_noire
	name = "collared woodland mantle"
	desc = "A flowing cloak that can be worn tighter or looser as the wearer deems fit. More than suitable for protection from the elements, the concealment of one's identity or as a warm blanket during those cold nites. This one has exchanged the traditional scarf in favor of a broad, padded collar."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	icon_state = "noirecloak"
	item_state = "noirecloak"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/half/vet/donator_naman
	name = "rider's scarfed cloak"
	desc = "'The past is the past. All that matters is the future we make for ourselves.'"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "naman_cloak"
	allowed_sex = list(MALE, FEMALE)
	detail_color = CLOTHING_RED
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/darkcloak
	name = "dark cloak"
	desc = "It'll warm up your flesh, but not your cold, dead heart."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "dark_cloak"
	item_state = "dark_cloak"
	color = null
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	boobed = TRUE
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	inhand_mod = TRUE
	allowed_race = SPECIES_BASE_BODY
	salvage_result = /obj/item/natural/fur
	ported_clothing = TRUE

/obj/item/clothing/cloak/scaledcloak
	name = "scaled cloak"
	desc = "A light cloak covered in shimmering metal scales. Beautiful even if too light to protect it's wearer from more than other travel cloaks."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "scalecloak"
	item_state = "scalecloak"
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	boobed = FALSE
	slot_flags = ITEM_SLOT_CLOAK|ITEM_SLOT_BACK_R|ITEM_SLOT_BACK_L
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	inhand_mod = TRUE
	detail_tag = "_detail"
	detail_color = "#405996"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/scout
	name = "scout cloak"
	desc = "A weathered cape cut short at the flank."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "scout_cloak"
	item_state = "scout_cloak"
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	inhand_mod = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/absolutionistrobe/black
	name = "blessed robe"
	desc = "Weep for what was lost. Pray for those who may yet be saved. Endure, in His name."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "blackabsolutionistrobe"
	item_state = "blackabsolutionistrobe"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/darkcloak/bear
	name = "direbear cloak"
	desc = "Made from the finest, warmest bear pelt. It might be worth more than your life."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "bear_cloak"
	item_state = "bear_cloak"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 3

/obj/item/clothing/cloak/darkcloak/minotaur
	name = "minotaur cloak"
	desc = "Minotaur fur and straw roughly sewn into a long mantle."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "mino"
	item_state = "mino"
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 4
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/rosa/two
	name = "courtly cloak"
	icon = 'modular_azurepeak/icons/clothing/special/rosewood.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/special/onmob/rosewood.dmi'
	icon_state = "rosacloak8"
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/darkcloak/bear/light
	name = "light direbear cloak"
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "bbear_cloak"
	item_state = "bbear_cloak"
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	salvage_result = /obj/item/natural/hide/cured
	salvage_amount = 3

/obj/item/clothing/cloak/half/shadowcloak/spymaster
	name = "hand's cloak"
	desc = "Crafted not for warmth, but to complete an imposing silhouette. It is tailored to shroud both the hilt of a hidden blade and the true intentions of its wearer from prying eyes."
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/cloaks.dmi'
	icon_state = "handcloak"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/cloak/stabard/guardhood/elder
	name = "elder's hood"
	icon = 'modular_azurepeak/icons/clothing/cloaks.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/detailed/tabards.dmi'
	sleeved = null
	icon_state = "guard_hood"
	item_state = "guard_hood"
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE
