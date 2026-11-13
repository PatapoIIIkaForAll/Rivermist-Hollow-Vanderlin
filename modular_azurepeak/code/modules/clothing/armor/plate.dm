/obj/item/clothing/armor/heartfelt
	name = "coat of armor"
	desc = "A lordly coat of armor."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "heartfelt"
	item_state = "heartfelt"
	slot_flags = ITEM_SLOT_ARMOR
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	armor_type = /datum/armor/plate
	allowed_sex = list(MALE, FEMALE)
	nodismemsleeves = TRUE
	blocking_behavior = null
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/steel
	armor_class = AC_HEAVY
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/heartfelt/hand
	name = "coat of armor"
	desc = "A lordly coat of armor."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "heartfelt_hand"
	item_state = "heartfelt_hand"
	slot_flags = ITEM_SLOT_ARMOR
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/bronze
	name = "bronze cuirass"
	desc = "A chiseled breastplate of bronze, further padded with hide to comfort its championing bod. The plates have been carefully forged to mimic the statuesque physiques of Faerun's ancient heroes. Wearing it bolsters you with determination."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "bronzecuirass"
	body_parts_covered = CHEST | VITALS | LEGS
	armor_type = /datum/armor/ported/bronze
	smeltresult = /obj/item/ingot/bronze
	max_integrity = 250
	armor_class = AC_MEDIUM
	boobed = FALSE
	ported_clothing = TRUE

/obj/item/clothing/armor/plate/silver
	name = "templar's half-plate"
	desc = "Holy silver, one fifth. Steel, three fifths. Chosen material, one fifth. The armour of the templar, protector and warrior of the gods' faithful."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "silverhalfplate"
	item_state = "silverhalfplate"
	slot_flags = ITEM_SLOT_ARMOR
	body_parts_covered = COVERAGE_TORSO
	armor_type = /datum/armor/plate
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	allowed_sex = list(MALE, FEMALE)
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/steel
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/brigandine/heavy/decorated
	name = "decorated coat of plates"
	desc = "An ornate coat-of-plates, adorned with a pair of steel vambraces and decorated with golden fluting. For when 'commanding by saigaback' is both a tactically unsound yet tempting option."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gildedcoatofplates"
	item_state = "gildedcoatofplates"
	color = null
	detail_color = CLOTHING_WHITE
	detail_tag = "_detail"
	nodismemsleeves = FALSE
	dyeable = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/bronze/light
	name = "bronze cardiophylax"
	desc = "A thick bronze plate, meticulously sculpted to fit its wearer's physique and guard their heart from all that'd seek to strike it. Unfortunately, it does little to riposte more emotional blows."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "bronzeprotector"
	item_state = "bronzeprotector"
	body_parts_covered = CHEST | VITALS
	max_integrity = 250
	armor_class = AC_LIGHT
	armor_type = /datum/armor/ported/bronze

/obj/item/clothing/armor/cuirass/copper
	name = "copper heartplate"
	desc = "Shingled copper disks, strapped together to ward the heart from harm. As discovered by its antiquital wearers, it is deceptively protective; yet, its straps can only sustain so much stress before snapping.."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "copperchest"
	max_integrity = ARMOR_INT_CHEST_MEDIUM_DECREPIT
	armor_type = /datum/armor/ported/bronze
	smeltresult = /obj/item/ingot/copper
	body_parts_covered = CHEST
	armor_class = AC_LIGHT
	ported_clothing = TRUE

/obj/item/clothing/armor/plate/fluted/avantyne
	name = "avantyne-threaded maille"
	desc = "Pauldrons lyke that of fire, crested atop a veil of otherworldly maille - impossibly tough, warm to the touch, and crackling with insidious energies."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "zizoplatechest_med"
	armor_class = AC_MEDIUM
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	armor_type = /datum/armor/ported/plate_bsteel
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/fluted/baotha
	name = "saccharine plate armor"
	desc = "Fluted plate lacquered in sickly pink. The champions of Blissara claim their goddess saw the cruelty of every other god's judgement - and chose, instead, to forgive mortals everything they crave."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "baothaplate"
	item_state = "baothaplate"
	max_integrity = ARMOR_INT_CHEST_PLATE_ANTAG - 350
	armor_class = AC_LIGHT
	color = null
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/fluted/baotha/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/armor/plate/fluted/baotha/dropped(mob/user, silent = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/armor/plate/fluted/decorated
	name = "decorated half-plate"
	desc = "An ornate set of steel armor, decorated with golden fluting. For when you need to remind those of lesser stations about whose authority reigns supreme, in lieu of a King's command."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gildedhalfplate"
	smeltresult = /obj/item/ingot/gold
	color = null
	detail_color = CLOTHING_WHITE
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/plate/fluted/zizo
	name = "avantyne half-plate"
	desc = "Pauldrons lyke that of fire. The metal curves and curdles with insidious energies, attempting to reform into angularities not meant for the layman's eyes to withstand."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "zizoplatechest_med"
	armor_class = AC_MEDIUM
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	armor_type = /datum/armor/plate
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/bronze
	name = "bronze panoplic armor"
	desc = "What can only be described as an 'armored robe'; thick bronze plates, layered atop one-another and interlinked with strappings to form an assembly of segmented plate armor. While overwhelmingly heavy and cumbersome, it is certain to weather any storm poised its way. </br>Scholars oft-describe this suit as a 'panoply', purpose-made for the physiques of Faerun's earliest Aasimari."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "bronzeplate"
	item_state = "bronzeplate"
	armor_type = /datum/armor/ported/bronze
	max_integrity = 300 + 100
	armor_class = AC_HEAVY
	smeltresult = /obj/item/ingot/bronze
	var/bronzeplatecumbersome = FALSE
	ported_clothing = TRUE

/obj/item/clothing/armor/plate/full/bronze/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if((slot & ITEM_SLOT_ARMOR))
		to_chat(user, span_suicide("The panoply clatters into place, and I feel my shoulders slouch beneath its weight - yet even now, I feel sturdier than ever before.."))
		user.set_stat_modifier("ported_equip_[REF(src)]", list((STATKEY_CON) = 1, (STATKEY_SPD) = -1))
		bronzeplatecumbersome = TRUE
	return

/obj/item/clothing/armor/plate/full/bronze/dropped(mob/living/user, silent = FALSE)
	. = ..()
	if(bronzeplatecumbersome == TRUE)
		to_chat(user, span_hypnophrase("..and with a sigh of relief, the panoply's weight no longer burdens my shoulders."))
		user.remove_stat_modifier("ported_equip_[REF(src)]")
		bronzeplatecumbersome = FALSE
	return

/obj/item/clothing/armor/plate/full/bronze/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Even with the necessary training, this suit of armor is difficult to maneuver in. Wearing the armor will slightly fortify your Constitution, at the cost of further reducing your Speed.")

/obj/item/clothing/armor/plate/full/fluted
	name = "fluted plate armor"
	desc = "A suit of ornate plate armor, noble in both presentation and protection. Such resplendent maille is traditionally reserved for the higher echelons of nobility; seasoned knights, venerated kings, and pot-bellied councilmen that wish to flaunt their opulence towards the unwashed masses."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ornateplate"
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	ported_clothing = TRUE

/obj/item/clothing/armor/plate/full/samsibsa
	name = "samsibsa scaleplate"
	desc = "A heavy set of armour worn by the kouken of distant Kozakura. As opposed to the plate armour utilized by most of Faerun and the West, samsiba-cheolpan is made of thirty-four rows of composite scales, each an ultra-thin sheet of blacksteel gilded over steel. </br> It is an extremely common practice to engrave characters onto individual plates - such as LUCK, HONOR, or HEAVEN."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "kazengunheavy"
	item_state = "kazengunheavy"
	detail_tag = "_detail"
	color = null
	detail_color = CLOTHING_WHITE
	body_parts_covered = (( CHEST | GROIN | VITALS | ARMS))
	max_integrity = ARMOR_INT_CHEST_PLATE_STEEL
	var/picked = FALSE
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/samsibsa/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!picked)
		var/choice = browser_input_list(user, "Choose a color.", "Uniform colors", GLOB.ported_color_map)
		if(!choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		var/playerchoice = GLOB.ported_color_map[choice]
		picked = TRUE
		detail_color = playerchoice
		detail_tag = "_detail"
		update_appearance()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_armor()
			H.update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/armor/plate/iron/banded
	name = "banded iron armor"
	desc = "An iron chestplate, pauldrons and tassets worn over a fur vest and padded with heavy leathers. It's primarily worn in the cold north, where armor has to sometimes be cobbled together due to logistical shortages. It leaves the stomach exposed for maneuverability."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ibandedarmor"
	item_state = "ibandedarmor"
	max_integrity = ARMOR_INT_CHEST_PLATE_IRON + 25
	armor_class = AC_HEAVY
	body_parts_covered = CHEST | ARMS | LEGS | GROIN
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/ancient/artificer
	name = "artificed half-plate"
	desc = "Forbidden knowledge, resurrected into a weightless vessel of gilbranze. Whatever arcyne meld once powered it has long gone dark."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "artificerplate"
	item_state = "artificerplate"
	armor_class = AC_LIGHT
	max_integrity = 300
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/medium/scale/bronze
	name = "bronze lamellar"
	desc = "A coat of small bronze plates, segmented together in a manner not unlike chainmail. Divorced from the romanticized images of bare-chested legionnaires of ancient Jhaamdath, but venerable nevertheless."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "blamellar"
	max_integrity = 250
	smeltresult = /obj/item/ingot/bronze
	armor_class = AC_MEDIUM
	armor_type = /datum/armor/ported/bronze
	ported_clothing = TRUE

/obj/item/clothing/armor/medium/scale/copper
	name = "copper lamellar"
	desc = "A coat of small copper plates, segmented together in a manner not unlike chainmail. Rarely seen since the dawn of civilization, copper garbs like these were the undersung heroes of humenity's earliest daes; a story of vintage proportions, still fresh in the minds of only a few blessed Aasimarites."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "clamellar"
	max_integrity = ARMOR_INT_CHEST_MEDIUM_SCALE
	smeltresult = /obj/item/ingot/copper
	armor_class = AC_MEDIUM
	armor_type = /datum/armor/ported/leather
	ported_clothing = TRUE

/obj/item/clothing/armor/medium/scale/inqcoat_ap
	name = "inquisitorial duster"
	desc = "A heavy longcoat with layers of maille hidden beneath the leather, donned by the Holy Aonic Inquisition's finest."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "inqcoat"
	item_state = "inqcoat"
	slot_flags = ITEM_SLOT_ARMOR
	sewrepair = TRUE
	body_parts_covered = (( CHEST | GROIN | VITALS | LEGS | ARMS))
	allowed_sex = list(MALE, FEMALE)
	sleevetype = "shirt"
	max_integrity = 300
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	equip_delay_self = 4 SECONDS
	armor_class = AC_LIGHT
	armor_type = /datum/armor/ported/leather
	smeltresult = /obj/item/ingot/iron
	blocksound = SOFTHIT
	ported_clothing = TRUE
	abstract_type = /obj/item/clothing/armor/medium/scale/inqcoat_ap

/obj/item/clothing/armor/medium/scale/iron
	name = "lamellar"
	desc = "A coat of small iron plates, segmented together in a manner not unlike chainmail. This curious combination provides the best of both worlds; protection on par with more rigid sets of plate armor, but without all the weight."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ilamellar"
	max_integrity = ARMOR_INT_CHEST_MEDIUM_IRON
	smeltresult = /obj/item/ingot/iron
	armor_class = AC_MEDIUM
	ported_clothing = TRUE

/obj/item/clothing/armor/medium/scale/marshal
	name = "coat of the commander"
	desc = "A coat of plates concealed beneath a heavy leather surcoat. Only the most battle-hardened of Duskmar's commanders can hope to bear its burden, both metaphorically and quite literally."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "leathercoat"
	item_state = "leathercoat"
	boobed = FALSE
	uses_lord_coloring = LORD_PRIMARY
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/fencer/decorated
	name = "decorated chestplate"
	desc = "An ornate steel chestplate, decorated with golden fluting. For when you need to bring a little bit of regal style to that upcoming duel with your lyfe's greatest adversary."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gildedchestplate"
	smeltresult = /obj/item/ingot/gold
	color = null
	detail_color = CLOTHING_WHITE
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/fencer/donator
	name = "steel heartplate"
	desc = "A curious - and particularly revealing - variant of a common cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "heartplates"
	item_state = "heartplates"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/fencer/donator_girdle
	name = "steel plackart"
	desc = "A curious - and particularly revealing - variant of a common cuirass. It's said that the intentionally provocative design excels at diverting strikes that'd otherwise pierce the wearer's unprotected regions."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "plackarts"
	item_state = "plackarts"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/fencer/donator_gothic
	name = "gothic fencing cuirass"
	desc = "A magnificent steel cuirass, assembled by an Duskmarian mastersmith. The intricate fluting and interlocked plates are clear signs of its Darkholdian heritage; expensive, but second-to-none when it comes to what truly matters in life."
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gcuirass"
	item_state = "gcuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/fencer/legacy
	name = "Luskanian fencer's cuirass"
	desc = "A steel cuirass. Do you still remember the first time you tasted blood; that sanguine succor, dribbling from a busted lip?"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "legacycuirass"
	item_state = "legacycuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/decorated
	name = "decorated cuirass"
	desc = "An ornate steel cuirass, decorated with golden fluting. For when you need to ensure that you look dapper, during your mustering for the latest crusade into some gods-forsaken land."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gildedcuirass"
	smeltresult = /obj/item/ingot/gold
	color = null
	detail_color = CLOTHING_WHITE
	detail_tag = "_detail"
	dyeable = TRUE
	ported_clothing = TRUE

/obj/item/clothing/armor/cuirass/ornate/gold
	name = "golden cuirass"
	desc = "A resplendant cuirass of pure gold, fitted with tassets for additional coverage. It is dressed atop a besilked arming jacket to ensure the absolute comfort of its wearer, and the holy sigil has been meticulously formed from its slanted plates."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "goldcuirass"
	armor_type = /datum/armor/blackbag
	max_integrity = 5
	armor_class = AC_HEAVY
	anvilrepair = null
	smeltresult = /obj/item/ingot/gold
	grid_height = 96
	grid_width = 96
	ported_clothing = TRUE

/obj/item/clothing/armor/cuirass/ornate/grinning
	name = "grinning cuirass"
	desc = "The steel of this chestpiece is deformed into sharp fangs crowning under the breast, equal parts to catch blades and mock your opponent, while gilt tooth-inlays line the waist. Stay hungry, hustler. Get your laughs in while you can."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "grinningcuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/holysee
	name = "holy see cuirass"
	desc = "A blessed steel cuirass, fitted with tassets for additional coverage. Mystra's holy silver, and Lathanderite gold are woven into the fluting. When the world was ending, and hunger of the nite ravenous, Templars one and all remember the radiance of the blessed metals, and the warmth of home. Then and forever, the gods have not forgotten their faithful."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "seecuirass"
	item_state = "seecuirass"
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/plate/full/bronze/alt
	name = "bronze panoplic assembly"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "bronzeplatealt"
	item_state = "bronzeplatealt"
	body_parts_covered = CHEST | VITALS | LEGS
	max_integrity = 300

/obj/item/clothing/armor/plate/full/fluted/decorated
	name = "decorated plate armor"
	desc = "An ornate set of steel plate armor, decorated with golden fluting. For when you need to do something with all of that precious, precious wealth gathering dust in a fief's ducal treasury."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "gildedplate"
	smeltresult = /obj/item/ingot/gold
	color = null
	detail_color = CLOTHING_WHITE
	detail_tag = "_detail"
	dyeable = TRUE

/obj/item/clothing/armor/plate/full/fluted/ornate
	name = "Aonic plate armor"
	desc = "A suit of beautiful plate armour, meticulously fluted with blessed silver. Its design is credited to a legendary armoursmith who sought to mimic the heavenly maille worn by the solars of Mount Celestia."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "ornateplate"
	smeltresult = /obj/item/ingot/silverblessed
	max_integrity = ARMOR_INT_CHEST_PLATE_PSYDON
	var/traited = FALSE

/obj/item/clothing/armor/plate/full/fluted/ornate/get_mechanics_examine(mob/user)
	. = ..()
	. += span_hypnophrase("'..the refusal of despair, and the resolve to defend Faerun in its darkest hour..'")

/obj/item/clothing/armor/plate/full/iron/bikini
	name = "iron full-plate corset"
	desc = "Breastplate, pauldrons, couters, cuisses.. did you forget something?"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "iplatekini"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	equip_delay_self = 8 SECONDS
	unequip_delay_self = 8 SECONDS
	equip_delay_other = 3 SECONDS
	strip_delay = ((6 SECONDS))
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/cuirass/ornate/gold/heroic
	name = "golden heroic cuirass"
	desc = "A resplendant cuirass of pure gold, fitted with tassets for additional coverage. It has been meticulously waxed-and-assembled from dozens of smaller golden plates, in order to replicate the statuesque physique of Faerun's legendary heroes."
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "heroiccuirass"

/obj/item/clothing/armor/cuirass/ornate/gold/king
	name = "golden heroic cuirass"
	icon = 'modular_azurepeak/icons/clothing/armor.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/armor.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/helpers/sleeves_armor.dmi'
	icon_state = "goldcuirass"
	item_state = "cuirass"
	max_integrity = 10
	sellprice = 400
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/armor/medium/scale/inqcoat/armored/heavy
	name = "plated inquisitorial duster"
	desc = "A heavy longcoat that's fitted atop a set of blessed plate armor, donned by the Holy Aonic Inquisition's finest. As expected from such a doursome country, this style is quite popular in Amn - where the skies are always overcast, and where sanctioned Ordinators often have to roam in the downpour. </br>At least, that's what the Holy See would probably say. What would <i>they</i> know about fashion, however?"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'
	icon_state = "ordinatorplatecoat"
	item_state = "ordinatorplatecoat"
	equip_delay_self = 8 SECONDS
	armor_class = AC_HEAVY
	armor_type = /datum/armor/plate
	max_integrity = ARMOR_INT_CHEST_PLATE_PSYDON
	ported_clothing = TRUE
	misc_flags = CRAFTING_TEST_EXCLUDE

// silver-plated duster burn vampires and werewolves like other RMH silver gear
/obj/item/clothing/armor/medium/scale/inqcoat/armored/heavy/Initialize(mapload)
	. = ..()
	enchant(/datum/enchantment/silver)
