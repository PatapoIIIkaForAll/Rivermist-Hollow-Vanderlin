
//////////////////////
// Hair Definitions //
//////////////////////
/datum/sprite_accessory/hair/head
	icon = 'icons/roguetown/mob/hair.dmi'	  // default icon for all hairs
	dynamic_file = 'icons/roguetown/mob/hair_extensions.dmi'
	var/static/list/extensions

	// please make sure they're sorted alphabetically and, where needed, categorized
	// try to capitalize the names please~
	// try to spell
	// you do not need to define _s or _l sub-states, game automatically does this for you

	// each race gets four unique haircuts
	// dwarf - miner, gnomish, boss, hearth
	// elf - son, fancy, mysterious, long
	// human - adventurer, dark knight, graceful, squire, pigtails, noblesse
	// dual - nomadic, shrine
	// aasimar - amazon, topknot, martial, forsaken
	// tiefling - junia, performer, tribal, lover


/// Gets the appearance of the sprite accessory as a mutable appearance for an organ on a bodypart.
/datum/sprite_accessory/hair/head/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/dynamic_hair_suffix = ""

	var/mob/living/carbon/H = bodypart.owner
	if(!H)
		H = bodypart.original_owner

	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(H.wear_neck)
		var/obj/item/I = H.wear_neck
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(!extensions)
		var/icon/hair_extensions = icon('icons/roguetown/mob/hair_extensions.dmi') //hehe
		extensions = list()
		for(var/s in hair_extensions.IconStates(1))
			extensions[s] = TRUE
		qdel(hair_extensions)

	if(extensions[icon_state+dynamic_hair_suffix])
		return "[icon_state][dynamic_hair_suffix]"

	return icon_state


/datum/sprite_accessory/hair/head/get_icon(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/dynamic_hair_suffix = ""

	var/mob/living/carbon/H = bodypart.owner
	if(!H)
		H = bodypart.original_owner

	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(H.wear_neck)
		var/obj/item/I = H.wear_neck
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(!extensions)
		var/icon/hair_extensions = icon('icons/roguetown/mob/hair_extensions.dmi') //hehe
		extensions = list()
		for(var/s in hair_extensions.IconStates(1))
			extensions[s] = TRUE
		qdel(hair_extensions)

	if(extensions[icon_state+dynamic_hair_suffix])
		return dynamic_file

	return icon

/datum/sprite_accessory/hair/head/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	return is_human_part_visible(owner, HIDEHAIR)

/datum/sprite_accessory/hair/head/bald
	name = "Bald"
	icon_state = ""
	specuse = ALL_RACES_LIST
	gender = MALE

/datum/sprite_accessory/hair/head/adventurer_human
	name = "Adventurer"
	icon_state = "adventurer"
	gender = MALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/berserker
	name = "Berserker"
	icon_state = "berserker"
	gender = MALE
	specuse = ALL_RACES_LIST
	under_layer = TRUE

/datum/sprite_accessory/hair/head/bog
	name = "Bog"
	icon_state = "bog"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/boss_dwarf
	name = "Boss"
	icon_state = "boss" // original name bodicker
	gender = MALE
	specuse = list(SPEC_ID_DWARF)
	under_layer = TRUE

/datum/sprite_accessory/hair/head/bowlcut
	name = "Bowlcut"
	icon_state = "bowlcut"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/brother
	name = "Brother"
	icon_state = "brother"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cavehead
	name = "Cavehead"
	icon_state = "cavehead" // original name thinning?
	gender = MALE
	specuse = ALL_RACES_LIST
	under_layer = TRUE

/datum/sprite_accessory/hair/head/conscript
	name = "Conscript"
	icon_state = "conscript"
	gender = MALE
	under_layer = TRUE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/courtier
	name = "Courtier"
	icon_state = "courtier"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/dark_knight
	name = "Dark Knight"
	icon_state = "darkknight"
	gender = MALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/dave
	name = "Dave"
	icon_state = "dave"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/dome
	name = "Dome"
	icon_state = "dome"
	gender = MALE
	specuse = ALL_RACES_LIST
	under_layer = TRUE

/datum/sprite_accessory/hair/head/dunes
	name = "Dunes"
	icon_state = "dunes"
	gender = MALE
	specuse = ALL_RACES_LIST


/datum/sprite_accessory/hair/head/druid
	name = "Druid"
	icon_state = "druid"  // original name elf_scout?
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fancy_elf
	name = "Fancy"
	icon_state = "fancy_elf"
	gender = MALE
	specuse = list(SPEC_ID_ELF)

/datum/sprite_accessory/hair/head/forester
	name = "Forester"
	icon_state = "forester"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/foreigner_tief
	name = "Foreigner"
	icon_state = "foreigner"
	gender = MALE
	specuse = list(SPEC_ID_TIEFLING)

/datum/sprite_accessory/hair/head/forsaken_aas
	name = "Forsaken"
	icon_state = "forsaken"
	gender = MALE
	specuse = list(SPEC_ID_AASIMAR)
	under_layer = TRUE

/datum/sprite_accessory/hair/head/forged
	name = "Forged"
	icon_state = "forged"
	gender = MALE
	specuse = ALL_RACES_LIST
	under_layer = TRUE

/datum/sprite_accessory/hair/head/graceful
	name = "Graceful"
	icon_state = "graceful"
	gender = MALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/heroic
	name = "Heroic"
	icon_state = "heroic"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/hunter
	name = "Hunter"
	icon_state = "hunter"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/landlord
	name = "Landlord"
	icon_state = "landlord"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/lover_tief
	name = "Lover"
	icon_state = "lover_tief_m"
	gender = MALE
	specuse = list(SPEC_ID_TIEFLING)

/datum/sprite_accessory/hair/head/lion
	name = "Lions mane"
	icon_state = "lion"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/monk
	name = "Monk"
	icon_state = "monk"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/majestic_human
	name = "Majesty"
	icon_state = "majestic"
	gender = MALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/merc
	name = "Mercenary"
	icon_state = "mercenary"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/miner_dwarf
	name = "Miner"
	icon_state = "miner"
	gender = MALE
	specuse = list(SPEC_ID_DWARF)

/datum/sprite_accessory/hair/head/nobility_human
	name = "Nobility"
	icon_state = "nobility"
	gender = MALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/nomadic_humtief
	name = "Nomadic"
	icon_state = "nomadic"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/pirate
	name = "Pirate"
	icon_state = "pirate"
	gender = MALE
	under_layer = TRUE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/princely
	name = "Princely"
	icon_state = "princely"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/rogue
	name = "Rogue"
	icon_state = "rogue"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/romantic
	name = "Romantic"
	icon_state = "romantic"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/scribe
	name = "Scribe"
	icon_state = "scribe"
	gender = MALE
	specuse = ALL_RACES_LIST
	under_layer = TRUE

/datum/sprite_accessory/hair/head/southern_human
	name = "Southern"
	icon_state = "southern"
	gender = MALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/son
	name = "Son"
	icon_state = "sun"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/son_elf
	name = "Sonne"
	icon_state = "son_elf"
	gender = MALE
	specuse = list(SPEC_ID_ELF)

/datum/sprite_accessory/hair/head/squire_human
	name = "Squired"
	icon_state = "squire" // original name shaved_european
	gender = MALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/swain
	name = "Swain"
	icon_state = "swain"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/top_aas
	name = "Topknot"
	icon_state = "topknot"
	gender = MALE
	specuse = list(SPEC_ID_AASIMAR)

/datum/sprite_accessory/hair/head/troubadour
	name = "Troubadour"
	icon_state = "troubadour"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tied
	name = "Tied"
	icon_state = "tied"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tied_long
	name = "Tied long"
	icon_state = "tiedlong"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tied_sidecut
	name = "Tied sidecut"
	icon_state = "tsidecut"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/trimmed
	name = "Trimmed"
	icon_state = "trimmed"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/warrior
	name = "Warrior"
	icon_state = "warrior"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/wildside
	name = "Wild Sidecut"
	icon_state = "wildside"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/woodsman_elf
	name = "Woodsman"
	icon_state = "woodsman_elf"
	gender = MALE
	specuse = list(SPEC_ID_ELF)

/datum/sprite_accessory/hair/head/zaladin
	name = "Zaladin"
	icon_state = "zaladin" // orginal name gelled
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/vagabond
	name = "Vagabond"
	icon_state = "vagabond"
	gender = MALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sandcrop
	name = "Sand Crop"
	icon_state = "sandcrop"
	gender = MALE
	specuse = ALL_RACES_LIST


/datum/sprite_accessory/hair/head/steward
	name = "Steward"
	icon_state = "steward"
	gender = MALE
	specuse = ALL_RACES_LIST

/////////////////////////////
// GIRLY Hair Definitions  //
/////////////////////////////

/datum/sprite_accessory/hair/head/amazon
	name = "Amazon"
	icon_state = "amazon_f"
	gender = FEMALE
	specuse = list(SPEC_ID_AASIMAR)

/datum/sprite_accessory/hair/head/archivist
	name = "Archivist"
	icon_state = "archivist_f" // original name bob_scully
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/barbarian
	name = "Barbarian"
	icon_state = "barbarian_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/beartails
	name = "Beartails"
	icon_state = "beartails_f" // modified cotton
	gender = FEMALE
	under_layer = TRUE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/buns
	name = "Buns"
	icon_state = "buns_f" // original name twinbuns
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/lowbun
	name = "Bun (Low)"
	icon_state = "bun-low"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bob
	name = "Bob"
	icon_state = "bob_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/curlyshort
	name = "Curly Short"
	icon_state = "curly_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/conscriptf
	name = "Conscript"
	icon_state = "conscript_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/emma
	name = "Emma"
	icon_state = "emma"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/empress
	name = "Empress"
	icon_state = "empress_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fancy_femelf
	name = "Fancy"
	icon_state = "fancy_elf_f"
	gender = FEMALE
	specuse = list(SPEC_ID_ELF)

/datum/sprite_accessory/hair/head/felfhair_fatherless
	name = "Fatherless"
	icon_state = "fatherless_elf_f"
	gender = FEMALE
	specuse = list(SPEC_ID_ELF)

/datum/sprite_accessory/hair/head/grumpy_f
	name = "Grumpy"
	icon_state = "grumpy_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gnomish_f
	name = "Gnomish"
	icon_state = "gnomish_f" // original name bun_grandma
	gender = FEMALE
	specuse = list(SPEC_ID_DWARF)

/datum/sprite_accessory/hair/head/hearth_f
	name = "Hearth"
	icon_state = "hearth_f" // original name ponytail_fox
	gender = FEMALE
	specuse = list(SPEC_ID_DWARF)

/datum/sprite_accessory/hair/head/homely
	name = "Homely"
	icon_state = "homely_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/junia
	name = "Junia"
	icon_state = "junia_tief_f" // modified hime_updo
	gender = FEMALE
	specuse = list(SPEC_ID_TIEFLING)

/datum/sprite_accessory/hair/head/lady
	name = "Lady"
	icon_state = "lady_f" // original name newyou
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/loosebraid
	name = "Loose Braid"
	icon_state = "loosebraid_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/maiden
	name = "Maiden"
	icon_state = "maiden_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/majestic_dwarf_F
	name = "Majestiq"
	icon_state = "majestic_dwarf"
	gender = FEMALE
	specuse = list(SPEC_ID_DWARF)

/datum/sprite_accessory/hair/head/majestic_f
	name = "Majestic"
	icon_state = "majestic_f"
	gender = FEMALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/messy
	name = "Messy"
	icon_state = "messy_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/mysterious_elf
	name = "Mysterious"
	icon_state = "mysterious_elf" // modified hime_long
	gender = FEMALE
	specuse = list(SPEC_ID_ELF)

/datum/sprite_accessory/hair/head/mystery
	name = "Mystery"
	icon_state = "mystery_f" // modified hime_long
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/noblesse
	name = "Noblesse"
	icon_state = "noblesse_f" // modified sidetail
	gender = FEMALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/orc
	name = "Orc"
	icon_state = "orc_f" // modified african_pigtails
	gender = FEMALE
	specuse = list(SPEC_ID_HALF_ORC)

/datum/sprite_accessory/hair/head/performer
	name = "Performer"
	icon_state = "performer_tief_f" // modified drillruru_long
	gender = FEMALE
	specuse = list(SPEC_ID_TIEFLING)

/datum/sprite_accessory/hair/head/pix
	name = "Pixie"
	icon_state = "pixie_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/pigtails
	name = "Pigtails"
	icon_state = "pigtails"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/plain
	name = "Plain"
	icon_state = "plain_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail
	name = "Ponytail"
	icon_state = "ponytail"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail8
	name = "Ponytail 8"
	icon_state = "ponytail8"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/puffdouble
	name = "Puff Double"
	icon_state = "puffdouble"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/puffleft
	name = "Puff Left"
	icon_state = "puffleft"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/puffright
	name = "Puff Right"
	icon_state = "puffright"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/queen
	name = "Queenly"
	icon_state = "queenly_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sideways_ponytail
	name = "Sideways Ponytail"
	icon_state = "sideways_ponytail"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shrine
	name = "Shrinekeeper"
	icon_state = "shrine_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/soilbride
	name = "Soilbride"
	icon_state = "soilbride_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/squire_f
	name = "Squire"
	icon_state = "squire_f" // original name ponytail_rynn
	gender = FEMALE
	specuse = list(SPEC_ID_HUMEN)

/datum/sprite_accessory/hair/head/tails
	name = "Tails"
	icon_state = "tails_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tied_pony
	name = "Tied Ponytail"
	icon_state = "tied_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tiedup
	name = "Tied Up"
	icon_state = "tiedup_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tiedcutf
	name = "Tied Sidecut"
	icon_state = "tsidecut_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tomboy1
	name = "Tomboy 1"
	icon_state = "tomboy_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tomboy2
	name = "Tomboy 2"
	icon_state = "tomboy2_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tomboy3
	name = "Tomboy 3"
	icon_state = "rogue_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/twintail_floor
	name = "Twintail Floor"
	icon_state = "twintail_floor"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/updo
	name = "Updo"
	icon_state = "updo_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/wildcutf
	name = "Wild Sidecut"
	icon_state = "wildside_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/wisp
	name = "Wisp"
	icon_state = "wisp_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/singlebraid
	name = "Single Braid"
	icon_state = "singlebraid"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shorthime
	name = "Hime Cut (Short)"
	icon_state = "shorthime"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/spicy
	name = "Spicy"
	icon_state = "spicy"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/stacy
	name = "Stacy"
	icon_state = "stacy"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/stacybun
	name = "Stacy (Bun)"
	icon_state = "stacy_bun"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/zoey
	name = "Zoey"
	icon_state = "zoey"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/mediumbraid
	name = "Medium Braid"
	icon_state = "mediumbraid"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/lakkaricut
	name = "Lakkari Cut"
	icon_state = "lakkaricut"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/lakkaribun
	name = "Lakkari Bun"
	icon_state = "lakkaribun"
	gender = FEMALE
	specuse = ALL_RACES_LIST

//////////////////////////////
// UNISEX Hair Definitions  //
//////////////////////////////
/datum/sprite_accessory/hair/head/alchemist
	name = "Alchemist"
	icon_state = "alchemist"
	specuse = ALL_RACES_LIST
	gender = NEUTER
	under_layer = TRUE

/datum/sprite_accessory/hair/head/martial
	name = "Martial"
	icon_state = "martial"
	gender = NEUTER
	specuse = list(SPEC_ID_AASIMAR)

/datum/sprite_accessory/hair/head/shaved
	name = "Shaved"
	icon_state = "shaved"
	specuse = ALL_RACES_LIST
	gender = NEUTER
	under_layer = TRUE

/datum/sprite_accessory/hair/head/runt
	name = "Runt"
	icon_state = "runt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/majestic_elf
	name = "Majestie"
	icon_state = "majestic_elf"
	gender = NEUTER
	specuse = list(SPEC_ID_ELF)

// Hairs below ported from Azure

/datum/sprite_accessory/hair/head/gloomy
	name = "Gloomy"
	icon_state = "gloomy"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gloomylong
	name = "Gloomy (Long)"
	icon_state = "gloomylong"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shortmessy
	name = "Messy (Short)"
	icon_state = "shortmessy"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/mediumessy
	name = "Messy (Medium)"
	icon_state = "mediummessy"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/inari
	name = "Inari"
	icon_state = "inari"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ziegler
	name = "Ziegler"
	icon_state = "ziegler"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gronnbraid
	name = "Gronn Braid"
	icon_state = "zone"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/grenzelcut
	name = "Grenzel Cut"
	icon_state = "grenzelcut"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fluffy
	name = "Fluffy"
	icon_state = "fluffy"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fluffyshort
	name = "Fluffy (Short)"
	icon_state = "fluffyshort"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fluffylong
	name = "Fluffy (Long)"
	icon_state = "fluffylong"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/jay
	name = "Jay"
	icon_state = "jay"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/hairfre
	name = "Hairfre"
	icon_state = "hairfre"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/dawn
	name = "Dawn"
	icon_state = "dawn"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/morning
	name = "Morning"
	icon_state = "morning"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/kobeni_1
	name = "Kobeni"
	icon_state = "kobeni_1"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/kobeni_2
	name = "Kobeni (Alt)"
	icon_state = "kobeni_2"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gloomy_short
	name = "Gloomy (Short)"
	icon_state = "gloomy_short"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gloomy_medium
	name = "Gloomy (Medium)"
	icon_state = "gloomy_medium"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gloomy_long
	name = "Gloomy (Long)"
	icon_state = "gloomy_long"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/emo_long
	name = "Emo Long (New)"
	icon_state = "emo_long"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/dreadlocks_long
	name = "Dreadlocks Long"
	icon_state = "dreadlocks_long"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/rows1
	name = "Row 1"
	icon_state = "rows1"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/rows2
	name = "Row 2"
	icon_state = "rows2"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/rowbraid
	name = "Row Braid"
	icon_state = "rowbraid"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/rowdualtail
	name = "Row Dual Tail"
	icon_state = "rowdualtail"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/rowbun
	name = "Row Bun"
	icon_state = "rowbun"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/long_over_eye_alt
	name = "Long Over Eye (Alt)"
	icon_state = "long_over_eye_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sabitsuki
	name = "Sabitsuki"
	icon_state = "sabitsuki"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cotton
	name = "Cotton"
	icon_state = "cotton"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cottonalt
	name = "Cotton (Alt)"
	icon_state = "cottonalt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bushy
	name = "Bushy"
	icon_state = "bushy"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bushy_alt
	name = "Bushy (Alt)"
	icon_state = "bushy_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/curtains
	name = "Curtains"
	icon_state = "curtains"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/glamourh
	name = "Glamourh"
	icon_state = "glamourh"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/wavylong
	name = "Wavy Long"
	icon_state = "wavylong"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/straightshort
	name = "Straight Short"
	icon_state = "straightshort"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/straightlong
	name = "Straight Long"
	icon_state = "straightlong"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fluffball
	name = "Fluffball"
	icon_state = "fluffball"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshave_long
	name = "Halfshave Long"
	icon_state = "halfshave_long"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshave_long_alt
	name = "Halfshave Long (Alt)"
	icon_state = "halfshave_long_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshave_messy
	name = "Halfshave Messy"
	icon_state = "halfshave_messy"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshave_messylong
	name = "Halfshave Messy Long"
	icon_state = "halfshave_messylong"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshave_messy_alt
	name = "Halfshave Messy (Alt)"
	icon_state = "halfshave_messy_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshave_messylong_alt
	name = "Halfshave Messy Long (Alt)"
	icon_state = "halfshave_messylong_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshave_glamorous
	name = "Halfshave Glamorous"
	icon_state = "halfshave_glamorous"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshave_glamorous_alt
	name = "Halfshave Glamorous (Alt)"
	icon_state = "halfshave_glamorous_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/thicklong
	name = "Thick Long"
	icon_state = "thicklong"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/thickshort
	name = "Thick Short"
	icon_state = "thickshort"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/thickcurly
	name = "Thick Curly"
	icon_state = "thickcurly"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/baum
	name = "Baum"
	icon_state = "baum"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/highlander
	name = "Highlander"
	icon_state = "highlander"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/royalcurls
	name = "Royal Curls"
	icon_state = "royalcurls"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/dreadlocksmessy
	name = "Dreadlocks Messy"
	icon_state = "dreadlong"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/suave
	name = "Suave"
	icon_state = "suave"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytailwitcher
	name = "Ponytail (Witcher)"
	icon_state = "ponytail_witcher"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/countryponytailalt
	name = "Ponytail (Country Alt)"
	icon_state = "countryalt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/kusanagi_alt
	name = "Kusanagi (Alt)"
	icon_state = "kusanagi_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shorthair6
	name = "Short Hair (Alt)"
	icon_state = "shorthair_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/helmet
	name = "Helmet Hair"
	icon_state = "helmet"
	gender = NEUTER
	specuse = ALL_RACES_LIST

//Monke Main Port//

/datum/sprite_accessory/hair/head/phoenix
	name = "Phoenix"
	icon_state = "phoenix"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/phoenixhalfshaven
	name = "Phoenix Half Shaven"
	icon_state = "phoenix_half_shaven"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/royalcurl
	name = "Royal Curl"
	icon_state = "royalcurl"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shorthair4
	name = "Short Hair 4"
	icon_state = "shorthair4"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/slightlymessy
	name = "Slightly Messy"
	icon_state = "slightlymessy"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/veryshortovereye
	name = "Very Short Over Eye"
	icon_state = "veryshortovereye"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/flatpressed
	name = "Flat Pressed"
	icon_state = "flatpressed"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/beachwave
	name = "Beachwave"
	icon_state = "beachwave"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fortuneteller
	name = "Fortune Teller"
	icon_state = "fortuneteller"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/hyenamane
	name = "Hyena Mane"
	icon_state = "hyenamane"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/kajam
	name = "Kajam"
	icon_state = "kajam"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/mermaid
	name = "Mermaid"
	icon_state = "mermaid"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/unkemptcurls
	name = "Unkempt Curls"
	icon_state = "unkempt_curls"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shrinepriestess
	name = "Shrine Priestess"
	icon_state = "shrine_priestess"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/triton
	name = "Base Triton"
	abstract_type = /datum/sprite_accessory/hair/head/triton
	icon = 'icons/mob/sprite_accessory/hair/triton.dmi'
	specuse = list(SPEC_ID_TRITON)

/datum/sprite_accessory/hair/head/triton/fin
	name = "Fin"
	icon_state = "fin"

/datum/sprite_accessory/hair/head/triton/seaking
	name = "Seaking"
	icon_state = "seaking"

/datum/sprite_accessory/hair/head/triton/siren
	name = "Siren"
	icon_state = "siren"

/datum/sprite_accessory/hair/head/triton/jellyfish
	name = "Jellyfish"
	icon_state = "jellyfish"

/datum/sprite_accessory/hair/head/triton/anemonger
	name = "Anemonger"
	icon_state = "anemonger"

/datum/sprite_accessory/hair/head/triton/punkfish
	name = "Punkfish"
	icon_state = "punkfish"

/datum/sprite_accessory/hair/head/triton/weed
	name = "Weeds"
	icon_state = "weed"

/datum/sprite_accessory/hair/head/triton/gorgon
	name = "Gorgon"
	icon_state = "gorgon"

/datum/sprite_accessory/hair/head/triton/lion
	name = "Lion"
	icon_state = "lion"

/datum/sprite_accessory/hair/head/triton/betta
	name = "Betta"
	icon_state = "betta"

/datum/sprite_accessory/hair/head/medicator
	name = "Base Medicator"
	abstract_type = /datum/sprite_accessory/hair/head/medicator
	icon = 'icons/mob/sprite_accessory/hair/medicator.dmi'
	specuse = list(SPEC_ID_MEDICATOR)

/datum/sprite_accessory/hair/head/medicator/windswept
	name = "Windswept"
	icon_state = "windswept"

/datum/sprite_accessory/hair/head/medicator/curl
	name = "Curl"
	icon_state = "curl"

/datum/sprite_accessory/hair/head/medicator/spencer
	name = "Spencer"
	icon_state = "spencer"

/datum/sprite_accessory/hair/head/medicator/dynamic
	name = "Dynamic"
	icon_state = "dynamic"

/datum/sprite_accessory/hair/head/medicator/jockey
	name = "Jockey"
	icon_state = "jockey"

/datum/sprite_accessory/hair/head/medicator/hook
	name = "Hook"
	icon_state = "hook"

/datum/sprite_accessory/hair/head/medicator/crown
	name = "Crown"
	icon_state = "crown"




//////////////////////////
//     RHV MODULS       //
//////////////////////////




/datum/sprite_accessory/hair/head/cowlick
	name = "Cowlick"
	icon_state = "hollyH"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cowbangs
	name = "Cow Bangs"
	icon_state = "cowBangs"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shorthaireighties
	name = "80s-style Hair"
	icon_state = "80s"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shorthaireighties_alt
	name = "80s-style Hair (Alt)"
	icon_state = "80s_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/afro
	name = "Afro"
	icon_state = "afro"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/afro2
	name = "Afro 2"
	icon_state = "afro2"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/afro_large
	name = "Afro (Large)"
	icon_state = "afro-big"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/antenna
    name = "Ahoge"
    icon_state = "antenna"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/balding
    name = "Balding Hair"
    icon_state = "balding"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bedhead
    name = "Bedhead"
    icon_state = "bedhead"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bedhead2
    name = "Bedhead 2"
    icon_state = "bedhead2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bedhead3
    name = "Bedhead 3"
    icon_state = "bedhead3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bedheadlong
    name = "Bedhead (Long)"
    icon_state = "bedhead-long"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/badlycut
    name = "Shorter Long Bedhead"
    icon_state = "hair_verybadlycut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/beehive
    name = "Beehive"
    icon_state = "beehive"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/beehive2
    name = "Beehive 2"
    icon_state = "beehive2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bob2
    name = "Bobcut 2"
    icon_state = "bob2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bob3
    name = "Bobcut 3"
    icon_state = "bob3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bob4
    name = "Bobcut 4"
    icon_state = "bob4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bobcurl
    name = "Bobcurl"
    icon_state = "bobcurl"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/boddicker
    name = "Boddicker"
    icon_state = "boddicker"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bowlcut2
    name = "Bowlcut 2"
    icon_state = "bowlcut2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/braid
    name = "Braid (Floorlength)"
    icon_state = "braid"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/front_braid
    name = "Braided Front"
    icon_state = "braid-front"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/not_floorlength_braid
    name = "Braid (High)"
    icon_state = "braid-high"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/lowbraid
    name = "Braid (Low)"
    icon_state = "braid-low"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shortbraid
    name = "Braid (Short)"
    icon_state = "braid-short"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/braided
    name = "Braided"
    icon_state = "braided"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/braidtail
    name = "Braided Tail"
    icon_state = "braided-tail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bun
    name = "Bun Head"
    icon_state = "bun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bun2
    name = "Bun Head 2"
    icon_state = "bun2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bun3
    name = "Bun Head 3"
    icon_state = "bun3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/largebun
    name = "Bun (Large)"
    icon_state = "bun-large"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/manbun
    name = "Bun (Manbun)"
    icon_state = "bun-manbun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tightbun
    name = "Bun (Tight)"
    icon_state = "bun-tight"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/business
    name = "Business Hair"
    icon_state = "business"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/business2
    name = "Business Hair 2"
    icon_state = "business2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/business3
    name = "Business Hair 3"
    icon_state = "business3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/business4
    name = "Business Hair 4"
    icon_state = "business4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/buzz
    name = "Buzzcut"
    icon_state = "buzzcut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cia
    name = "CIA"
    icon_state = "cia"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/coffeehouse
    name = "Coffee House"
    icon_state = "coffeehouse"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/combover
    name = "Combover"
    icon_state = "combover"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/comet
    name = "Comet"
    icon_state = "comet"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cornrows1
    name = "Cornrows"
    icon_state = "cornrows"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cornrows2
    name = "Cornrows 2"
    icon_state = "cornrows2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cornrowbraid
    name = "Cornrow Braid"
    icon_state = "cornrow-braid"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cornrowbun
    name = "Cornrow Bun"
    icon_state = "cornrow-bun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cornrowdualtail
    name = "Cornrow Tail"
    icon_state = "cornrow-tail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/crew
    name = "Crewcut"
    icon_state = "crewcut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/cut
    name = "Cut Hair"
    icon_state = "cut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/dandpompadour
    name = "Dandy Pompadour"
    icon_state = "dandypompadour"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/devillock
    name = "Devil Lock"
    icon_state = "devillock"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/doublebun
    name = "Double Bun"
    icon_state = "doublebun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/dreadlocks
    name = "Dreadlocks"
    icon_state = "dreads"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/drillhair
    name = "Drillruru"
    icon_state = "drillruru"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/drillhairextended
    name = "Drill Hair (Extended)"
    icon_state = "drillhairextended"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/emo
    name = "Emo"
    icon_state = "emo"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/emo2
    name = "Emo 2"
    icon_state = "emo2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/emofringe
    name = "Emo Fringe"
    icon_state = "emofringe"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longemo
    name = "Emo Long"
    icon_state = "emolong"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/nofade
    name = "Fade (None)"
    icon_state = "fade-none"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/lowfade
    name = "Fade (Low)"
    icon_state = "fade-low"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/medfade
    name = "Fade (Medium)"
    icon_state = "fade-medium"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/highfade
    name = "Fade (High)"
    icon_state = "fade-high"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/baldfade
    name = "Fade (Bald)"
    icon_state = "fade-bald"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/father
    name = "Father"
    icon_state = "father"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/feather
    name = "Feather"
    icon_state = "feather"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/flair
    name = "Flair"
    icon_state = "flair"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/flattop
    name = "Flat Top / Sergeant"
    icon_state = "flattop"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/flattop_big
    name = "Flat Top (Big)"
    icon_state = "flattop-big"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/flow_hair
    name = "Flow Hair"
    icon_state = "flow"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gelled
    name = "Gelled Back"
    icon_state = "gelled"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gentle
    name = "Gentle"
    icon_state = "gentle"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfbang
    name = "Half-banged Hair"
    icon_state = "halfbang"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfbang2
    name = "Half-banged Hair 2"
    icon_state = "halfbang2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/halfshaved
    name = "Half-shaved"
    icon_state = "halfshaved"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/hedgehog
    name = "Hedgehog Hair"
    icon_state = "hedgehog"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/himecut
    name = "Hime Cut"
    icon_state = "himecut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/himecut2
    name = "Hime Cut 2"
    icon_state = "himecut2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/himeup
    name = "Hime Updo"
    icon_state = "himeup"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/hitop
    name = "Hitop"
    icon_state = "hitop"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/jade
    name = "Jade"
    icon_state = "jade"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/jensen
    name = "Jensen Hair"
    icon_state = "jensen"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/joestar
    name = "Joestar"
    icon_state = "joestar"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/keanu
    name = "Keanu Hair"
    icon_state = "keanu"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/kusangi
    name = "Kusanagi Hair"
    icon_state = "kusanagi"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/long
    name = "Long Hair 1"
    icon_state = "long"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/long2
    name = "Long Hair 2"
    icon_state = "long2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/long3
    name = "Long Hair 3"
    icon_state = "long3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/long_over_eye
    name = "Long Over Eye"
    icon_state = "longovereye"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longbangs
    name = "Long Bangs"
    icon_state = "lbangs"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longfringe
    name = "Long Fringe"
    icon_state = "longfringe"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sidepartlongalt
    name = "Long Side Part"
    icon_state = "longsidepart"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/megaeyebrows
    name = "Mega Eyebrows"
    icon_state = "megaeyebrows"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/modern
    name = "Modern"
    icon_state = "modern"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/modern2
    name = "Modern (New)"
    icon_state = "modern2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/mohawk
    name = "Mohawk"
    icon_state = "mohawk"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/reversemohawk
    name = "Mohawk (Reverse)"
    icon_state = "mohawk-reverse"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shavedmohawk
    name = "Mohawk (Shaved)"
    icon_state = "mohawk-shaved"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/unshavenmohawk
    name = "Mohawk (Big)"
    icon_state = "mohawk-unshaven"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/mulder
    name = "Mulder"
    icon_state = "mulder"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/nitori
    name = "Nitori"
    icon_state = "nitori"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/newyou
    name = "New You"
    icon_state = "newyou"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/odango
    name = "Odango"
    icon_state = "odango"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ombre
    name = "Ombre"
    icon_state = "ombre"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/oneshoulder
    name = "One Shoulder"
    icon_state = "oneshoulder"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/over_eye
    name = "Over Eye"
    icon_state = "shortovereye"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/oxton
    name = "Oxton"
    icon_state = "oxton"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/parted
    name = "Parted"
    icon_state = "parted"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/partedside
    name = "Parted (Side)"
    icon_state = "part"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/pigtails
    name = "Pigtails"
    icon_state = "pigtails"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/pigtails2
    name = "Pigtails 2"
    icon_state = "pigtails2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/pigtails3
    name = "Pigtails 3"
    icon_state = "pigtails3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/kagami
    name = "Pigtails (Kagami)"
    icon_state = "pigtails-kagami"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/pixie
    name = "Pixie Cut"
    icon_state = "pixie"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/pompadour
    name = "Pompadour"
    icon_state = "pompadour"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bigpompadour
    name = "Pompadour (Big)"
    icon_state = "pompadour-big"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail1
    name = "Ponytail"
    icon_state = "ponytail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail2
    name = "Ponytail 2"
    icon_state = "ponytail2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail3
    name = "Ponytail 3"
    icon_state = "ponytail3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail4
    name = "Ponytail 4"
    icon_state = "ponytail4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail5
    name = "Ponytail 5"
    icon_state = "ponytail5"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail6
    name = "Ponytail 6"
    icon_state = "ponytail6"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ponytail7
    name = "Ponytail 7"
    icon_state = "ponytail7"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/highponytail
    name = "Ponytail (High)"
    icon_state = "ponytail-high"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longponytail
    name = "Ponytail (Long)"
    icon_state = "ponytail-longstraight"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/stail
    name = "Ponytail (Short)"
    icon_state = "ponytail-short"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/countryponytail
    name = "Ponytail (Country)"
    icon_state = "ponytail-country"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fringetail
    name = "Ponytail (Fringe)"
    icon_state = "fringetail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sidetail
    name = "Ponytail (Side)"
    icon_state = "sidetail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sidetail2
    name = "Ponytail (Side) 2"
    icon_state = "sidetail2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sidetail3
    name = "Ponytail (Side) 3"
    icon_state = "sidetail3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sidetail4
    name = "Ponytail (Side) 4"
    icon_state = "sidetail4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/spikyponytail
    name = "Ponytail (Spiky)"
    icon_state = "spikyponytail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/poofy
    name = "Poofy"
    icon_state = "poofy"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/quiff
    name = "Quiff"
    icon_state = "quiff"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/ronin
    name = "Ronin"
    icon_state = "ronin"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shavedpart
    name = "Shaved Part"
    icon_state = "shavedpart"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shortbangs
    name = "Short Bangs"
    icon_state = "shortbangs"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/short
    name = "Short Hair"
    icon_state = "short"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shorthair2
    name = "Short Hair 2"
    icon_state = "shorthair2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shorthair3
    name = "Short Hair 3"
    icon_state = "shorthair3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shorthair7
    name = "Short Hair 7"
    icon_state = "shorthairg"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/rosa
    name = "Short Hair Rosa"
    icon_state = "rosa"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shoulderlength
    name = "Shoulder-length Hair"
    icon_state = "shoulder"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sidecut
    name = "Sidecut"
    icon_state = "sidecut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/skinhead
    name = "Skinhead"
    icon_state = "skinhead"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/protagonist
    name = "Slightly Long Hair"
    icon_state = "protagonist"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/spiky
    name = "Spiky"
    icon_state = "spikey"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/spiky2
    name = "Spiky 2"
    icon_state = "spiky"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/spiky3
    name = "Spiky 3"
    icon_state = "spiky2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/swept
    name = "Swept Back Hair"
    icon_state = "swept"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/swept2
    name = "Swept Back Hair 2"
    icon_state = "swept2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/thinning
    name = "Thinning"
    icon_state = "thinning"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/thinningfront
    name = "Thinning (Front)"
    icon_state = "thinningfront"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/thinningrear
    name = "Thinning (Rear)"
    icon_state = "thinningrear"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/topknot
    name = "Topknot"
    icon_state = "topknot"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tressshoulder
    name = "Tress Shoulder"
    icon_state = "tressshoulder"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/trimmed
    name = "Trimmed"
    icon_state = "trimmed"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/trimflat
    name = "Trim Flat"
    icon_state = "trimflat"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/twintails
    name = "Twintails"
    icon_state = "twintail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/undercut
    name = "Undercut"
    icon_state = "undercut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/undercutleft
    name = "Undercut Left"
    icon_state = "undercutleft"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/undercutright
    name = "Undercut Right"
    icon_state = "undercutright"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/unkept
    name = "Unkept"
    icon_state = "unkept"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longer
    name = "Very Long Hair"
    icon_state = "vlong"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longest
    name = "Very Long Hair 2"
    icon_state = "longest"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longest2
    name = "Very Long Over Eye"
    icon_state = "longest2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/veryshortovereye
    name = "Very Short Over Eye"
    icon_state = "veryshortovereyealternate"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longestalt
    name = "Very Long with Fringe"
    icon_state = "vlongfringe"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/volaju
    name = "Volaju"
    icon_state = "volaju"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/hyenamane
    name = "Hyena Mane"
    icon_state = "hyenamane"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/forelock
    name = "Forelock"
    icon_state = "forelock"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/scout
    name = "Scout"
    icon_state = "scout"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/son2
    name = "Son (Alt)"
    icon_state = "son2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/long4
    name = "Long (Fourth)"
    icon_state = "long4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longstraightponytail
    name = "Long Ponytail"
    icon_state = "longstraightponytail"
    gender = NEUTER
    specuse = ALL_RACES_LIST


/datum/sprite_accessory/hair/head/barmaid
    name = "Barmaid"
    icon_state = "barmaid"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bob_rt
    name = "Bob (Rogue)"
    icon_state = "bob_rt"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/messy_rt
    name = "Messy (Rogue)"
    icon_state = "messy_rt"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/longtails
    name = "Longtails"
    icon_state = "longtails"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/hime
    name = "Hime"
    icon_state = "hime"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fatherless
    name = "Fatherless"
    icon_state = "fatherless"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fatherless2
    name = "Fatherless (Alt)"
    icon_state = "fatherless2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/kepthair
    name = "Kepthair"
    icon_state = "kepthair"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/zone
    name = "Zone"
    icon_state = "zone"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/diagonalbangs
    name = "Diagonal Bangs"
    icon_state = "diagonalbangs"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/sabitsuki_ponytail
    name = "Sabitsuki (Ponytail)"
    icon_state = "sabitsuki_ponytail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/damsel
    name = "Damsel"
    icon_state = "damsel"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/wavyovereye
    name = "Wavy Over Eye"
    icon_state = "wavyovereye"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/straightovereye
    name = "Straight Over Eye"
    icon_state = "straightovereye"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/straightside
    name = "Straight Side"
    icon_state = "straightside"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/straightshort
    name = "Straight Short"
    icon_state = "straightshort"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/thicklong_alt
    name = "Thick Long (Alt)"
    icon_state = "thicklong_alt"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/mcsqueeb
    name = "Ye Old McSqueeb"
    icon_state = "mcsqueeb"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bubblebraids
    name = "Bubble Braids"
    icon_state = "bubblebraid"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bubblebraids_v2
    name = "Bubble Braids Alt"
    icon_state = "bubblebraid_v2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/heiress
    name = "Heiress"
    icon_state = "heiress"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/playful
    name = "Playful"
    icon_state = "playful"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/adventurer
    name = "Adventurer"
    icon_state = "adventurer"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/amazon_f
    name = "Amazon (F)"
    icon_state = "amazon_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/barbarian_f
    name = "Barbarian (F)"
    icon_state = "barbarian_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/beartails_f
    name = "Beartails (F)"
    icon_state = "beartails_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/berserker
    name = "Berserker"
    icon_state = "berserker"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bob_f
    name = "Bob (F)"
    icon_state = "bob_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/boss
    name = "Boss"
    icon_state = "boss"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/buns_f
    name = "Buns (F)"
    icon_state = "buns_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/curly_f
    name = "Curly (F)"
    icon_state = "curly_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/darkknight
    name = "Darkknight"
    icon_state = "darkknight"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/empress_f
    name = "Empress (F)"
    icon_state = "empress_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fancy_elf_f
    name = "Fancy Elf (F)"
    icon_state = "fancy_elf_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/foreigner
    name = "Foreigner"
    icon_state = "foreigner"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/forsaken
    name = "Forsaken"
    icon_state = "forsaken"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/homely_f
    name = "Homely (F)"
    icon_state = "homely_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/junia_tief_f
    name = "Junia Tief (F)"
    icon_state = "junia_tief_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/lady_f
    name = "Lady (F)"
    icon_state = "lady_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/loosebraid_f
    name = "Loosebraid (F)"
    icon_state = "loosebraid_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/lover_tief_m
    name = "Lover Tief (M)"
    icon_state = "lover_tief_m"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/maid_f
    name = "Maid (F)"
    icon_state = "maid_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/maiden_f
    name = "Maiden (F)"
    icon_state = "maiden_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/majestic
    name = "Majestic"
    icon_state = "majestic"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/majestic_dwarf
    name = "Majestic Dwarf"
    icon_state = "majestic_dwarf"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/messy_f
    name = "Messy (F)"
    icon_state = "messy_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/miner
    name = "Miner"
    icon_state = "miner"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/mystery_f
    name = "Mystery (F)"
    icon_state = "mystery_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/nobility
    name = "Nobility"
    icon_state = "nobility"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/noblesse_f
    name = "Noblesse (F)"
    icon_state = "noblesse_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/nomadic
    name = "Nomadic"
    icon_state = "nomadic"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/orc_f
    name = "Orc (F)"
    icon_state = "orc_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/performer_tief_f
    name = "Performer Tief (F)"
    icon_state = "performer_tief_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/plain_f
    name = "Plain (F)"
    icon_state = "plain_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/pixie_f
    name = "Pixie (F)"
    icon_state = "pixie_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/soilbride_f
    name = "Soilbride (F)"
    icon_state = "soilbride_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/shrine_f
    name = "Shrine (F)"
    icon_state = "shrine_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/southern
    name = "Southern"
    icon_state = "southern"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tails_f
    name = "Tails (F)"
    icon_state = "tails_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/tsidecut
    name = "Tsidecut"
    icon_state = "tsidecut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/updo_f
    name = "Updo (F)"
    icon_state = "updo_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/wisp_f
    name = "Wisp (F)"
    icon_state = "wisp_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/queenly_f
    name = "Queenly (F)"
    icon_state = "queenly_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/zybantu
    name = "Zybantu"
    icon_state = "zybantu"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/chair_ponytail6
    name = "Chair Ponytail 6"
    icon_state = "chair_ponytail6"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/chair_manbun
    name = "Chair Manbun"
    icon_state = "chair_manbun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/fatherless_elf_f
    name = "Fatherless Elf (F)"
    icon_state = "fatherless_elf_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/samurai
    name = "Samurai"
    icon_state = "samurai"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/yakuza
    name = "Yakuza"
    icon_state = "yakuza"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/novice
    name = "Novice"
    icon_state = "novice"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/steppeman
    name = "Steppeman"
    icon_state = "steppeman"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/bishonen
    name = "Bishonen"
    icon_state = "bishonen"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/emperor
    name = "Emperor"
    icon_state = "emperor"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/female
    name = "Female"
    icon_state = "female"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/warlady
    name = "Warlady"
    icon_state = "warlady"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/waterfield
    name = "Waterfield"
    icon_state = "waterfield"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/homewaifu
    name = "Homewaifu"
    icon_state = "homewaifu"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/casual
    name = "Casual"
    icon_state = "casual"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/martyr
    name = "Martyr"
    icon_state = "martyr"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/neuter
    name = "Neuter"
    icon_state = "neuter"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/hprotagonist
    name = "Hprotagonist"
    icon_state = "hprotagonist"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/alsoprotagonist
    name = "Alsoprotagonist"
    icon_state = "alsoprotagonist"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/rakshari
	name = "Base Rakshari"
	abstract_type = /datum/sprite_accessory/hair/head/rakshari
	icon = 'icons/mob/sprite_accessory/hair/rakshari.dmi'
	specuse = list(SPEC_ID_RAKSHARI)

/datum/sprite_accessory/hair/head/rakshari/high_tail
	name = "High Tail"
	icon_state = "high_tail"

/datum/sprite_accessory/hair/head/rakshari/doubleknot
	name = "Double Knot"
	icon_state = "doubleknot"

/datum/sprite_accessory/hair/head/rakshari/fluffy_tail
	name = "Fluffy Tail"
	icon_state = "fluffy_tail"
