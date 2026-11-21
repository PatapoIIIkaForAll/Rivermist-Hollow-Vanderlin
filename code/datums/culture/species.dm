/datum/culture/species/underdark
	name = "Underdark"
	pre_append = "the "
	description = "The vast caverns beneath Faerun, home to drow cities, duergar holds, deep gnomes, kobolds and far worse. \
	On the surface, \"Underdarker\" can mean a deserter from a Lolth-sworn city, a hermit from some lightless cave, or a dwarf whose clan dug too deep. \
	Whatever the case, few up here trust them."
	species = list(
		SPEC_ID_DROW,
		SPEC_ID_HALF_DROW,
		SPEC_ID_DWARF,
		SPEC_ID_KOBOLD,
	)

/datum/culture/species/elven
	name = "Elven Realms"
	pre_append = "the "
	description = "Elves come from many old realms: Evermeet far out in the Trackless Sea, the deep woods of the High Forest, the hidden vale of Evereska and the ruins of Myth Drannor. \
	Each folk keeps its own songs, grudges and opinions of the others, and humans seldom learn to tell them apart. \
	To an elf, a human lifetime is a short visit."
	species = list(
		SPEC_ID_ELF,
		SPEC_ID_HALF_ELF,
	)

/datum/culture/species/half_orc
	abstract_type = /datum/culture/species/half_orc
	species = list(
		SPEC_ID_HALF_ORC,
	)

// /datum/culture/species/half_orc/shellcrest
// 	name = "Shellcrest"

// /datum/culture/species/half_orc/blood_axe
// 	name = "Blood Axe"

// /datum/culture/species/half_orc/splitjaw
// 	name = "Splitjaw"

// /datum/culture/species/half_orc/blackhammer
// 	name = "Blackhammer"

// /datum/culture/species/half_orc/skullseeker
// 	name = "Skullseeker"

// /datum/culture/species/half_orc/crescent_fang
// 	name = "Crescent Fang"

// /datum/culture/species/half_orc/murkwater
// 	name = "Murkwater"

// /datum/culture/species/half_orc/shatterhorn
// 	name = "Shatterhorn"

// /datum/culture/species/half_orc/spiritcrusher
// 	name = "Spiritcrusher"
