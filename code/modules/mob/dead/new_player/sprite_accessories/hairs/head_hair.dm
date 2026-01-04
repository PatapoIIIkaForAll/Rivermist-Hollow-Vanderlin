
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
	specuse = list(SPEC_ID_DWARF, SPEC_ID_DUERGAR)
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
	specuse = list(SPEC_ID_ELF, SPEC_ID_ELF_W)

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
	specuse = list(SPEC_ID_DWARF, SPEC_ID_DUERGAR)

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
	specuse = list(SPEC_ID_ELF, SPEC_ID_ELF_W)

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
	specuse = list(SPEC_ID_ELF, SPEC_ID_ELF_W)

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
	specuse = list(SPEC_ID_ELF, SPEC_ID_ELF_W)

/datum/sprite_accessory/hair/head/felfhair_fatherless
	name = "Fatherless"
	icon_state = "fatherless_elf_f"
	gender = FEMALE
	specuse = list(SPEC_ID_ELF, SPEC_ID_ELF_W)

/datum/sprite_accessory/hair/head/grumpy_f
	name = "Grumpy"
	icon_state = "grumpy_f"
	gender = FEMALE
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/gnomish_f
	name = "Gnomish"
	icon_state = "gnomish_f" // original name bun_grandma
	gender = FEMALE
	specuse = list(SPEC_ID_DWARF, SPEC_ID_DUERGAR)

/datum/sprite_accessory/hair/head/hearth_f
	name = "Hearth"
	icon_state = "hearth_f" // original name ponytail_fox
	gender = FEMALE
	specuse = list(SPEC_ID_DWARF, SPEC_ID_DUERGAR)

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
	specuse = list(SPEC_ID_DWARF, SPEC_ID_DUERGAR)

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
	specuse = list(SPEC_ID_ELF, SPEC_ID_ELF_W)

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
	specuse = list(SPEC_ID_ELF, SPEC_ID_ELF_W)

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

//////////////////////////
//     RHV MODULS       //
//////////////////////////




/datum/sprite_accessory/hair/head/azur/cowlick
	name = "Cowlick"
	icon_state = "hollyH"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/cowbangs
	name = "Cow Bangs"
	icon_state = "cowBangs"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shorthaireighties
	name = "80s-style Hair"
	icon_state = "80s"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shorthaireighties_alt
	name = "80s-style Hair (Alt)"
	icon_state = "80s_alt"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/afro
	name = "Afro"
	icon_state = "afro"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/afro2
	name = "Afro 2"
	icon_state = "afro2"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/afro_large
	name = "Afro (Large)"
	icon_state = "afro-big"
	gender = NEUTER
	specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/antenna
    name = "Ahoge"
    icon_state = "antenna"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/balding
    name = "Balding Hair"
    icon_state = "balding"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bedhead
    name = "Bedhead"
    icon_state = "bedhead"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bedhead2
    name = "Bedhead 2"
    icon_state = "bedhead2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bedhead3
    name = "Bedhead 3"
    icon_state = "bedhead3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bedheadlong
    name = "Bedhead (Long)"
    icon_state = "bedhead-long"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/badlycut
    name = "Shorter Long Bedhead"
    icon_state = "hair_verybadlycut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/beehive
    name = "Beehive"
    icon_state = "beehive"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/beehive2
    name = "Beehive 2"
    icon_state = "beehive2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bob2
    name = "Bobcut 2"
    icon_state = "bob2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bob3
    name = "Bobcut 3"
    icon_state = "bob3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bob4
    name = "Bobcut 4"
    icon_state = "bob4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bobcurl
    name = "Bobcurl"
    icon_state = "bobcurl"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/boddicker
    name = "Boddicker"
    icon_state = "boddicker"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bowlcut2
    name = "Bowlcut 2"
    icon_state = "bowlcut2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/braid
    name = "Braid (Floorlength)"
    icon_state = "braid"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/front_braid
    name = "Braided Front"
    icon_state = "braid-front"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/not_floorlength_braid
    name = "Braid (High)"
    icon_state = "braid-high"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/lowbraid
    name = "Braid (Low)"
    icon_state = "braid-low"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shortbraid
    name = "Braid (Short)"
    icon_state = "braid-short"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/braided
    name = "Braided"
    icon_state = "braided"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/braidtail
    name = "Braided Tail"
    icon_state = "braided-tail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bun
    name = "Bun Head"
    icon_state = "bun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bun2
    name = "Bun Head 2"
    icon_state = "bun2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bun3
    name = "Bun Head 3"
    icon_state = "bun3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/largebun
    name = "Bun (Large)"
    icon_state = "bun-large"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/manbun
    name = "Bun (Manbun)"
    icon_state = "bun-manbun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/tightbun
    name = "Bun (Tight)"
    icon_state = "bun-tight"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/business
    name = "Business Hair"
    icon_state = "business"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/business2
    name = "Business Hair 2"
    icon_state = "business2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/business3
    name = "Business Hair 3"
    icon_state = "business3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/business4
    name = "Business Hair 4"
    icon_state = "business4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/buzz
    name = "Buzzcut"
    icon_state = "buzzcut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/cia
    name = "CIA"
    icon_state = "cia"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/coffeehouse
    name = "Coffee House"
    icon_state = "coffeehouse"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/combover
    name = "Combover"
    icon_state = "combover"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/comet
    name = "Comet"
    icon_state = "comet"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/cornrows1
    name = "Cornrows"
    icon_state = "cornrows"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/cornrows2
    name = "Cornrows 2"
    icon_state = "cornrows2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/cornrowbraid
    name = "Cornrow Braid"
    icon_state = "cornrow-braid"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/cornrowbun
    name = "Cornrow Bun"
    icon_state = "cornrow-bun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/cornrowdualtail
    name = "Cornrow Tail"
    icon_state = "cornrow-tail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/crew
    name = "Crewcut"
    icon_state = "crewcut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/cut
    name = "Cut Hair"
    icon_state = "cut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/dandpompadour
    name = "Dandy Pompadour"
    icon_state = "dandypompadour"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/devillock
    name = "Devil Lock"
    icon_state = "devillock"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/doublebun
    name = "Double Bun"
    icon_state = "doublebun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/dreadlocks
    name = "Dreadlocks"
    icon_state = "dreads"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/drillhair
    name = "Drillruru"
    icon_state = "drillruru"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/drillhairextended
    name = "Drill Hair (Extended)"
    icon_state = "drillhairextended"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/emo
    name = "Emo"
    icon_state = "emo"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/emo2
    name = "Emo 2"
    icon_state = "emo2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/emofringe
    name = "Emo Fringe"
    icon_state = "emofringe"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longemo
    name = "Emo Long"
    icon_state = "emolong"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/nofade
    name = "Fade (None)"
    icon_state = "fade-none"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/lowfade
    name = "Fade (Low)"
    icon_state = "fade-low"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/medfade
    name = "Fade (Medium)"
    icon_state = "fade-medium"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/highfade
    name = "Fade (High)"
    icon_state = "fade-high"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/baldfade
    name = "Fade (Bald)"
    icon_state = "fade-bald"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/father
    name = "Father"
    icon_state = "father"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/feather
    name = "Feather"
    icon_state = "feather"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/flair
    name = "Flair"
    icon_state = "flair"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/flattop
    name = "Flat Top / Sergeant"
    icon_state = "flattop"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/flattop_big
    name = "Flat Top (Big)"
    icon_state = "flattop-big"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/flow_hair
    name = "Flow Hair"
    icon_state = "flow"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/gelled
    name = "Gelled Back"
    icon_state = "gelled"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/gentle
    name = "Gentle"
    icon_state = "gentle"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/halfbang
    name = "Half-banged Hair"
    icon_state = "halfbang"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/halfbang2
    name = "Half-banged Hair 2"
    icon_state = "halfbang2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/halfshaved
    name = "Half-shaved"
    icon_state = "halfshaved"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/hedgehog
    name = "Hedgehog Hair"
    icon_state = "hedgehog"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/himecut
    name = "Hime Cut"
    icon_state = "himecut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/himecut2
    name = "Hime Cut 2"
    icon_state = "himecut2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/himeup
    name = "Hime Updo"
    icon_state = "himeup"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/hitop
    name = "Hitop"
    icon_state = "hitop"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/jade
    name = "Jade"
    icon_state = "jade"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/jensen
    name = "Jensen Hair"
    icon_state = "jensen"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/joestar
    name = "Joestar"
    icon_state = "joestar"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/keanu
    name = "Keanu Hair"
    icon_state = "keanu"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/kusangi
    name = "Kusanagi Hair"
    icon_state = "kusanagi"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/long
    name = "Long Hair 1"
    icon_state = "long"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/long2
    name = "Long Hair 2"
    icon_state = "long2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/long3
    name = "Long Hair 3"
    icon_state = "long3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/long_over_eye
    name = "Long Over Eye"
    icon_state = "longovereye"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longbangs
    name = "Long Bangs"
    icon_state = "lbangs"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longfringe
    name = "Long Fringe"
    icon_state = "longfringe"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/sidepartlongalt
    name = "Long Side Part"
    icon_state = "longsidepart"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/megaeyebrows
    name = "Mega Eyebrows"
    icon_state = "megaeyebrows"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/modern
    name = "Modern"
    icon_state = "modern"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/modern2
    name = "Modern (New)"
    icon_state = "modern2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/mohawk
    name = "Mohawk"
    icon_state = "mohawk"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/reversemohawk
    name = "Mohawk (Reverse)"
    icon_state = "mohawk-reverse"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shavedmohawk
    name = "Mohawk (Shaved)"
    icon_state = "mohawk-shaved"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/unshavenmohawk
    name = "Mohawk (Big)"
    icon_state = "mohawk-unshaven"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/mulder
    name = "Mulder"
    icon_state = "mulder"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/nitori
    name = "Nitori"
    icon_state = "nitori"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/newyou
    name = "New You"
    icon_state = "newyou"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/odango
    name = "Odango"
    icon_state = "odango"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ombre
    name = "Ombre"
    icon_state = "ombre"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/oneshoulder
    name = "One Shoulder"
    icon_state = "oneshoulder"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/over_eye
    name = "Over Eye"
    icon_state = "shortovereye"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/oxton
    name = "Oxton"
    icon_state = "oxton"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/parted
    name = "Parted"
    icon_state = "parted"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/partedside
    name = "Parted (Side)"
    icon_state = "part"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/pigtails
    name = "Pigtails"
    icon_state = "pigtails"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/pigtails2
    name = "Pigtails 2"
    icon_state = "pigtails2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/pigtails3
    name = "Pigtails 3"
    icon_state = "pigtails3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/kagami
    name = "Pigtails (Kagami)"
    icon_state = "pigtails-kagami"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/pixie
    name = "Pixie Cut"
    icon_state = "pixie"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/pompadour
    name = "Pompadour"
    icon_state = "pompadour"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bigpompadour
    name = "Pompadour (Big)"
    icon_state = "pompadour-big"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ponytail1
    name = "Ponytail"
    icon_state = "ponytail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ponytail2
    name = "Ponytail 2"
    icon_state = "ponytail2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ponytail3
    name = "Ponytail 3"
    icon_state = "ponytail3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ponytail4
    name = "Ponytail 4"
    icon_state = "ponytail4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ponytail5
    name = "Ponytail 5"
    icon_state = "ponytail5"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ponytail6
    name = "Ponytail 6"
    icon_state = "ponytail6"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ponytail7
    name = "Ponytail 7"
    icon_state = "ponytail7"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/highponytail
    name = "Ponytail (High)"
    icon_state = "ponytail-high"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longponytail
    name = "Ponytail (Long)"
    icon_state = "ponytail-longstraight"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/stail
    name = "Ponytail (Short)"
    icon_state = "ponytail-short"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/countryponytail
    name = "Ponytail (Country)"
    icon_state = "ponytail-country"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/fringetail
    name = "Ponytail (Fringe)"
    icon_state = "fringetail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/sidetail
    name = "Ponytail (Side)"
    icon_state = "sidetail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/sidetail2
    name = "Ponytail (Side) 2"
    icon_state = "sidetail2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/sidetail3
    name = "Ponytail (Side) 3"
    icon_state = "sidetail3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/sidetail4
    name = "Ponytail (Side) 4"
    icon_state = "sidetail4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/spikyponytail
    name = "Ponytail (Spiky)"
    icon_state = "spikyponytail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/poofy
    name = "Poofy"
    icon_state = "poofy"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/quiff
    name = "Quiff"
    icon_state = "quiff"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/ronin
    name = "Ronin"
    icon_state = "ronin"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shavedpart
    name = "Shaved Part"
    icon_state = "shavedpart"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shortbangs
    name = "Short Bangs"
    icon_state = "shortbangs"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/short
    name = "Short Hair"
    icon_state = "short"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shorthair2
    name = "Short Hair 2"
    icon_state = "shorthair2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shorthair3
    name = "Short Hair 3"
    icon_state = "shorthair3"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shorthair7
    name = "Short Hair 7"
    icon_state = "shorthairg"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/rosa
    name = "Short Hair Rosa"
    icon_state = "rosa"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shoulderlength
    name = "Shoulder-length Hair"
    icon_state = "shoulder"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/sidecut
    name = "Sidecut"
    icon_state = "sidecut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/skinhead
    name = "Skinhead"
    icon_state = "skinhead"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/protagonist
    name = "Slightly Long Hair"
    icon_state = "protagonist"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/spiky
    name = "Spiky"
    icon_state = "spikey"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/spiky2
    name = "Spiky 2"
    icon_state = "spiky"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/spiky3
    name = "Spiky 3"
    icon_state = "spiky2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/swept
    name = "Swept Back Hair"
    icon_state = "swept"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/swept2
    name = "Swept Back Hair 2"
    icon_state = "swept2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/thinning
    name = "Thinning"
    icon_state = "thinning"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/thinningfront
    name = "Thinning (Front)"
    icon_state = "thinningfront"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/thinningrear
    name = "Thinning (Rear)"
    icon_state = "thinningrear"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/topknot
    name = "Topknot"
    icon_state = "topknot"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/tressshoulder
    name = "Tress Shoulder"
    icon_state = "tressshoulder"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/trimmed
    name = "Trimmed"
    icon_state = "trimmed"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/trimflat
    name = "Trim Flat"
    icon_state = "trimflat"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/twintails
    name = "Twintails"
    icon_state = "twintail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/undercut
    name = "Undercut"
    icon_state = "undercut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/undercutleft
    name = "Undercut Left"
    icon_state = "undercutleft"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/undercutright
    name = "Undercut Right"
    icon_state = "undercutright"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/unkept
    name = "Unkept"
    icon_state = "unkept"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longer
    name = "Very Long Hair"
    icon_state = "vlong"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longest
    name = "Very Long Hair 2"
    icon_state = "longest"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longest2
    name = "Very Long Over Eye"
    icon_state = "longest2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/veryshortovereye
    name = "Very Short Over Eye"
    icon_state = "veryshortovereyealternate"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longestalt
    name = "Very Long with Fringe"
    icon_state = "vlongfringe"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/volaju
    name = "Volaju"
    icon_state = "volaju"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/hyenamane
    name = "Hyena Mane"
    icon_state = "hyenamane"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/forelock
    name = "Forelock"
    icon_state = "forelock"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/scout
    name = "Scout"
    icon_state = "scout"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/son2
    name = "Son (Alt)"
    icon_state = "son2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/long4
    name = "Long (Fourth)"
    icon_state = "long4"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longstraightponytail
    name = "Long Ponytail"
    icon_state = "longstraightponytail"
    gender = NEUTER
    specuse = ALL_RACES_LIST


/datum/sprite_accessory/hair/head/azur/barmaid
    name = "Barmaid"
    icon_state = "barmaid"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bob_rt
    name = "Bob (Rogue)"
    icon_state = "bob_rt"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/messy_rt
    name = "Messy (Rogue)"
    icon_state = "messy_rt"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/longtails
    name = "Longtails"
    icon_state = "longtails"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/hime
    name = "Hime"
    icon_state = "hime"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/fatherless
    name = "Fatherless"
    icon_state = "fatherless"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/fatherless2
    name = "Fatherless (Alt)"
    icon_state = "fatherless2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/kepthair
    name = "Kepthair"
    icon_state = "kepthair"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/zone
    name = "Zone"
    icon_state = "zone"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/diagonalbangs
    name = "Diagonal Bangs"
    icon_state = "diagonalbangs"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/sabitsuki_ponytail
    name = "Sabitsuki (Ponytail)"
    icon_state = "sabitsuki_ponytail"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/damsel
    name = "Damsel"
    icon_state = "damsel"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/wavyovereye
    name = "Wavy Over Eye"
    icon_state = "wavyovereye"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/straightovereye
    name = "Straight Over Eye"
    icon_state = "straightovereye"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/straightside
    name = "Straight Side"
    icon_state = "straightside"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/straightshort
    name = "Straight Short"
    icon_state = "straightshort"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/thicklong_alt
    name = "Thick Long (Alt)"
    icon_state = "thicklong_alt"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/mcsqueeb
    name = "Ye Old McSqueeb"
    icon_state = "mcsqueeb"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bubblebraids
    name = "Bubble Braids"
    icon_state = "bubblebraid"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bubblebraids_v2
    name = "Bubble Braids Alt"
    icon_state = "bubblebraid_v2"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/heiress
    name = "Heiress"
    icon_state = "heiress"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/playful
    name = "Playful"
    icon_state = "playful"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/adventurer
    name = "Adventurer"
    icon_state = "adventurer"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/amazon_f
    name = "Amazon (F)"
    icon_state = "amazon_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/barbarian_f
    name = "Barbarian (F)"
    icon_state = "barbarian_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/beartails_f
    name = "Beartails (F)"
    icon_state = "beartails_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/berserker
    name = "Berserker"
    icon_state = "berserker"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bob_f
    name = "Bob (F)"
    icon_state = "bob_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/boss
    name = "Boss"
    icon_state = "boss"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/buns_f
    name = "Buns (F)"
    icon_state = "buns_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/curly_f
    name = "Curly (F)"
    icon_state = "curly_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/darkknight
    name = "Darkknight"
    icon_state = "darkknight"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/empress_f
    name = "Empress (F)"
    icon_state = "empress_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/fancy_elf_f
    name = "Fancy Elf (F)"
    icon_state = "fancy_elf_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/foreigner
    name = "Foreigner"
    icon_state = "foreigner"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/forsaken
    name = "Forsaken"
    icon_state = "forsaken"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/homely_f
    name = "Homely (F)"
    icon_state = "homely_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/junia_tief_f
    name = "Junia Tief (F)"
    icon_state = "junia_tief_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/lady_f
    name = "Lady (F)"
    icon_state = "lady_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/loosebraid_f
    name = "Loosebraid (F)"
    icon_state = "loosebraid_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/lover_tief_m
    name = "Lover Tief (M)"
    icon_state = "lover_tief_m"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/maid_f
    name = "Maid (F)"
    icon_state = "maid_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/maiden_f
    name = "Maiden (F)"
    icon_state = "maiden_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/majestic
    name = "Majestic"
    icon_state = "majestic"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/majestic_dwarf
    name = "Majestic Dwarf"
    icon_state = "majestic_dwarf"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/messy_f
    name = "Messy (F)"
    icon_state = "messy_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/miner
    name = "Miner"
    icon_state = "miner"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/mystery_f
    name = "Mystery (F)"
    icon_state = "mystery_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/nobility
    name = "Nobility"
    icon_state = "nobility"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/noblesse_f
    name = "Noblesse (F)"
    icon_state = "noblesse_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/nomadic
    name = "Nomadic"
    icon_state = "nomadic"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/orc_f
    name = "Orc (F)"
    icon_state = "orc_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/performer_tief_f
    name = "Performer Tief (F)"
    icon_state = "performer_tief_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/plain_f
    name = "Plain (F)"
    icon_state = "plain_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/pixie_f
    name = "Pixie (F)"
    icon_state = "pixie_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/soilbride_f
    name = "Soilbride (F)"
    icon_state = "soilbride_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/shrine_f
    name = "Shrine (F)"
    icon_state = "shrine_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/southern
    name = "Southern"
    icon_state = "southern"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/tails_f
    name = "Tails (F)"
    icon_state = "tails_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/tsidecut
    name = "Tsidecut"
    icon_state = "tsidecut"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/updo_f
    name = "Updo (F)"
    icon_state = "updo_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/wisp_f
    name = "Wisp (F)"
    icon_state = "wisp_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/queenly_f
    name = "Queenly (F)"
    icon_state = "queenly_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/zybantu
    name = "Zybantu"
    icon_state = "zybantu"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/chair_ponytail6
    name = "Chair Ponytail 6"
    icon_state = "chair_ponytail6"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/chair_manbun
    name = "Chair Manbun"
    icon_state = "chair_manbun"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/fatherless_elf_f
    name = "Fatherless Elf (F)"
    icon_state = "fatherless_elf_f"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/samurai
    name = "Samurai"
    icon_state = "samurai"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/yakuza
    name = "Yakuza"
    icon_state = "yakuza"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/novice
    name = "Novice"
    icon_state = "novice"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/steppeman
    name = "Steppeman"
    icon_state = "steppeman"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/bishonen
    name = "Bishonen"
    icon_state = "bishonen"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/emperor
    name = "Emperor"
    icon_state = "emperor"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/female
    name = "Female"
    icon_state = "female"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/warlady
    name = "Warlady"
    icon_state = "warlady"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/waterfield
    name = "Waterfield"
    icon_state = "waterfield"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/homewaifu
    name = "Homewaifu"
    icon_state = "homewaifu"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/casual
    name = "Casual"
    icon_state = "casual"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/martyr
    name = "Martyr"
    icon_state = "martyr"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/neuter
    name = "Neuter"
    icon_state = "neuter"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/hprotagonist
    name = "Hprotagonist"
    icon_state = "hprotagonist"
    gender = NEUTER
    specuse = ALL_RACES_LIST

/datum/sprite_accessory/hair/head/azur/alsoprotagonist
    name = "Alsoprotagonist"
    icon_state = "alsoprotagonist"
    gender = NEUTER
    specuse = ALL_RACES_LIST
