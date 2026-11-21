// Species body fluids: flavoured milk, seed and nectar, build-based production modifiers and heat cycles.

// Fluid vars take one reagent type or a weighted list; the first list entry is the main fluid.

/mob/living
	var/breast_milk = /datum/reagent/consumable/milk
	var/cum = /datum/reagent/consumable/cum
	var/femcum = /datum/reagent/consumable/femcum

/datum/species
	var/breast_milk = /datum/reagent/consumable/milk
	var/cum = /datum/reagent/consumable/cum
	var/femcum = /datum/reagent/consumable/femcum
	/// Fluid modifier types every member of the species has, such as a small frame.
	var/list/species_fluid_modifiers
	/// Members go into heat or rut on a cycle, if their ERP preferences allow it.
	var/has_heat_cycle = FALSE

/datum/species/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	C.set_milk(breast_milk)
	C.set_cum(cum)
	C.set_girlcum(femcum)
	for(var/modifier_type in species_fluid_modifiers)
		C.add_fluid_modifier(modifier_type, FLUID_SOURCE_SPECIES)
	if(has_heat_cycle)
		C.grant_heat_cycle(HEAT_SOURCE_SPECIES)

/datum/species/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	for(var/modifier_type in species_fluid_modifiers)
		C.remove_fluid_modifier(modifier_type, FLUID_SOURCE_SPECIES)
	if(has_heat_cycle)
		C.revoke_heat_cycle(HEAT_SOURCE_SPECIES)

/mob/living/proc/set_milk(milk)
	breast_milk = milk
	var/obj/item/organ/genitals/filling_organ/breasts/breasties = getorganslot(ORGAN_SLOT_BREASTS)
	breasties?.set_reagent_to_make(breast_milk)

/mob/living/proc/set_cum(cum_in) //haha come in
	cum = cum_in
	var/obj/item/organ/genitals/filling_organ/testicles/testes = getorganslot(ORGAN_SLOT_TESTICLES)
	if(testes)
		testes.set_reagent_to_make(get_cum_mix())
		testes.sync_cum_source_data()

/mob/living/proc/set_girlcum(femcum_in)
	femcum = femcum_in
	var/obj/item/organ/genitals/filling_organ/vagina/vag = getorganslot(ORGAN_SLOT_VAGINA)
	vag?.set_reagent_to_make(get_femcum_mix())

/// The seed this body makes as reagent type = share; the first entry carries the father's data.
/mob/living/proc/get_cum_mix()
	return normalize_fluid_mix(cum)

/// The nectar this body makes as reagent type = share; the first entry carries the maker's data.
/mob/living/proc/get_femcum_mix()
	return normalize_fluid_mix(femcum)

/// A fluid var as reagent type = share, shares summing to 1; a bare entry weighs 1.
/proc/normalize_fluid_mix(fluid)
	if(ispath(fluid, /datum/reagent))
		var/list/single = list()
		single[fluid] = 1
		return single
	if(!islist(fluid))
		return null
	var/list/weights = fluid
	var/total = 0
	for(var/reagent_type in weights)
		total += get_fluid_mix_weight(weights, reagent_type)
	if(total <= 0)
		return null
	var/list/mix = list()
	for(var/reagent_type in weights)
		var/weight = get_fluid_mix_weight(weights, reagent_type)
		if(weight > 0)
			mix[reagent_type] = weight / total
	return mix

/// The weight of one entry in a fluid list; non-reagents weigh nothing.
/proc/get_fluid_mix_weight(list/weights, reagent_type)
	if(!ispath(reagent_type, /datum/reagent))
		return 0
	var/weight = weights[reagent_type]
	return isnum(weight) ? max(weight, 0) : 1

/// Whether two normalised mixes hold the same types at the same shares; null matches null.
/proc/fluid_mixes_match(list/mix_a, list/mix_b)
	if(length(mix_a) != length(mix_b))
		return FALSE
	for(var/reagent_type in mix_a)
		if(mix_a[reagent_type] != mix_b[reagent_type])
			return FALSE
	return TRUE

// Species blocks. Subtypes inherit their parent's fluids unless they set their own.

/datum/species/elf
	breast_milk = /datum/reagent/consumable/milk/elf
	cum = /datum/reagent/consumable/cum/elf
	femcum = /datum/reagent/consumable/femcum/elf

/datum/species/elf/dark
	breast_milk = /datum/reagent/consumable/milk/darkelf
	cum = /datum/reagent/consumable/cum/drow
	femcum = /datum/reagent/consumable/femcum/drow

/datum/species/human/halfelf
	breast_milk = /datum/reagent/consumable/milk/halfelf
	cum = /datum/reagent/consumable/cum/halfelf
	femcum = /datum/reagent/consumable/femcum/halfelf

/datum/species/human/halfdrow
	breast_milk = /datum/reagent/consumable/milk/halfdrow
	cum = /datum/reagent/consumable/cum/halfdrow
	femcum = /datum/reagent/consumable/femcum/halfdrow

/datum/species/tieberian
	breast_milk = /datum/reagent/consumable/milk/tiefling
	cum = /datum/reagent/consumable/cum/tiefling
	femcum = /datum/reagent/consumable/femcum/tiefling

/datum/species/dwarf
	breast_milk = /datum/reagent/consumable/milk/dwarf
	cum = /datum/reagent/consumable/cum/dwarf
	femcum = /datum/reagent/consumable/femcum/dwarf

/datum/species/halforc
	breast_milk = /datum/reagent/consumable/milk/halforc
	cum = /datum/reagent/consumable/cum/halforc
	femcum = /datum/reagent/consumable/femcum/halforc

/datum/species/lizardfolk
	breast_milk = /datum/reagent/consumable/milk/lizardfolk
	cum = /datum/reagent/consumable/cum/lizardfolk
	femcum = /datum/reagent/consumable/femcum/lizardfolk

/datum/species/tabaxi
	breast_milk = /datum/reagent/consumable/milk/tabaxi
	cum = /datum/reagent/consumable/cum/tabaxi
	femcum = /datum/reagent/consumable/femcum/tabaxi

/datum/species/rakshari
	breast_milk = /datum/reagent/consumable/milk/tabaxi
	cum = /datum/reagent/consumable/cum/tabaxi
	femcum = /datum/reagent/consumable/femcum/tabaxi

/datum/species/dragonborn
	breast_milk = /datum/reagent/consumable/milk/dracon
	cum = /datum/reagent/consumable/cum/dracon
	femcum = /datum/reagent/consumable/femcum/dracon

/datum/species/kobold
	breast_milk = /datum/reagent/consumable/milk/kobold
	cum = /datum/reagent/consumable/cum/kobold
	femcum = /datum/reagent/consumable/femcum/kobold
	species_fluid_modifiers = list(/datum/fluid_modifier/small_frame)

/datum/species/goblin
	breast_milk = /datum/reagent/consumable/milk/goblin
	cum = /datum/reagent/consumable/cum/goblinp
	femcum = /datum/reagent/consumable/femcum/goblinp
	species_fluid_modifiers = list(/datum/fluid_modifier/small_frame, /datum/fluid_modifier/prolific_seed)

/datum/species/goblin/player
	cum = /datum/reagent/consumable/cum/goblinp/player

/datum/species/halfling
	breast_milk = /datum/reagent/consumable/milk/halfling
	cum = /datum/reagent/consumable/cum/halfling
	femcum = /datum/reagent/consumable/femcum/halfling
	species_fluid_modifiers = list(/datum/fluid_modifier/small_frame)

/datum/species/gnome
	breast_milk = /datum/reagent/consumable/milk/gnome
	cum = /datum/reagent/consumable/cum/gnome
	femcum = /datum/reagent/consumable/femcum/gnome
	species_fluid_modifiers = list(/datum/fluid_modifier/small_frame)

/datum/species/harpy
	breast_milk = /datum/reagent/consumable/milk/harpy
	cum = /datum/reagent/consumable/cum/harpy
	femcum = /datum/reagent/consumable/femcum/harpy
	has_heat_cycle = TRUE

/datum/species/aasimar
	breast_milk = /datum/reagent/consumable/milk/aasimar
	cum = /datum/reagent/consumable/cum/aasimar
	femcum = /datum/reagent/consumable/femcum/aasimar

/datum/species/yuanti
	breast_milk = /datum/reagent/consumable/milk/yuanti
	cum = /datum/reagent/consumable/cum/yuanti
	femcum = /datum/reagent/consumable/femcum/yuanti

/datum/species/triton
	breast_milk = /datum/reagent/consumable/milk/triton
	cum = /datum/reagent/consumable/cum/triton
	femcum = /datum/reagent/consumable/femcum/triton

/datum/species/medicator
	breast_milk = /datum/reagent/consumable/milk/kenku
	cum = /datum/reagent/consumable/cum/kenku
	femcum = /datum/reagent/consumable/femcum/kenku

/datum/species/automaton/construct
	breast_milk = /datum/reagent/consumable/milk/warforged
	cum = /datum/reagent/consumable/cum/warforged
	femcum = /datum/reagent/consumable/femcum/warforged

/datum/species/fluvian
	breast_milk = /datum/reagent/consumable/milk/fluvian
	cum = /datum/reagent/consumable/cum/fluvian
	femcum = /datum/reagent/consumable/femcum/fluvian

/datum/species/gnoll
	breast_milk = /datum/reagent/consumable/milk/gnoll
	cum = /datum/reagent/consumable/cum/gnoll
	femcum = /datum/reagent/consumable/femcum/gnoll
	has_heat_cycle = TRUE

/datum/species/ogre
	breast_milk = /datum/reagent/consumable/milk/ogre
	cum = /datum/reagent/consumable/cum/ogre
	femcum = /datum/reagent/consumable/femcum/ogre
	species_fluid_modifiers = list(/datum/fluid_modifier/large_frame)

/datum/species/ooze
	breast_milk = /datum/reagent/consumable/milk/ooze
	cum = /datum/reagent/consumable/cum/ooze
	femcum = /datum/reagent/consumable/femcum/ooze

/datum/species/seelie
	breast_milk = /datum/reagent/consumable/milk/seelie
	cum = /datum/reagent/consumable/cum/seelie
	femcum = /datum/reagent/consumable/femcum/seelie

/datum/species/anthromorph
	breast_milk = /datum/reagent/consumable/milk/beastkin
	cum = /datum/reagent/consumable/cum/beastkin
	femcum = /datum/reagent/consumable/femcum/beastkin

/datum/species/demihuman
	breast_milk = /datum/reagent/consumable/milk/half_beastkin
	cum = /datum/reagent/consumable/cum/half_beastkin
	femcum = /datum/reagent/consumable/femcum/half_beastkin

/datum/species/anthromorphsmall
	breast_milk = /datum/reagent/consumable/milk/critterkin
	cum = /datum/reagent/consumable/cum/critterkin
	femcum = /datum/reagent/consumable/femcum/critterkin

/datum/species/half_anthromorphsmall
	breast_milk = /datum/reagent/consumable/milk/half_critterkin
	cum = /datum/reagent/consumable/cum/half_critterkin
	femcum = /datum/reagent/consumable/femcum/half_critterkin

/datum/species/taur_kin
	breast_milk = /datum/reagent/consumable/milk/taurkin
	cum = /datum/reagent/consumable/cum/taurkin
	femcum = /datum/reagent/consumable/femcum/taurkin
	species_fluid_modifiers = list(/datum/fluid_modifier/large_frame)

// Seed.

/datum/reagent/consumable/cum/elf
	taste_description = "mint and apples"

/datum/reagent/consumable/cum/drow
	taste_description = "mushroomy sourness"

/datum/reagent/consumable/cum/halfelf
	taste_description = "faint mint and apples"

/datum/reagent/consumable/cum/halfdrow
	taste_description = "faint mushroomy sourness"

/datum/reagent/consumable/cum/tiefling
	taste_description = "peppery hotness"

/datum/reagent/consumable/cum/dwarf
	taste_description = "metallic hops"

/datum/reagent/consumable/cum/halforc
	taste_description = "meat and musk"

/datum/reagent/consumable/cum/lizardfolk
	taste_description = "meat and bitterness"

/datum/reagent/consumable/cum/tabaxi
	taste_description = "fish and mint"

/datum/reagent/consumable/cum/dracon
	taste_description = "smoked steak"

/datum/reagent/consumable/cum/kobold
	taste_description = "fishy vegetables"

/datum/reagent/consumable/cum/goblinp
	taste_description = "fishy earthiness"
	triggers_embryo_pregnancy = TRUE
	vitilty_factor = 5

/datum/reagent/consumable/cum/goblinp/player
	triggers_embryo_pregnancy = FALSE

/datum/reagent/consumable/cum/halfling
	taste_description = "butter and warm bread"

/datum/reagent/consumable/cum/gnome
	taste_description = "a sharp, fizzy tang"

/datum/reagent/consumable/cum/harpy
	taste_description = "wild berries and rain"

/datum/reagent/consumable/cum/aasimar
	taste_description = "clean honey and incense"

/datum/reagent/consumable/cum/yuanti
	taste_description = "cool, bitter herbs"

/datum/reagent/consumable/cum/triton
	taste_description = "brine and sea salt"

/datum/reagent/consumable/cum/kenku
	taste_description = "peat and bitter herbs"

/datum/reagent/consumable/cum/warforged
	taste_description = "clean oil and brass"

/datum/reagent/consumable/cum/fluvian
	taste_description = "dusty moonflowers"

/datum/reagent/consumable/cum/gnoll
	taste_description = "musk and raw meat"

/datum/reagent/consumable/cum/ogre
	taste_description = "thick, earthy musk"

/datum/reagent/consumable/cum/ooze
	taste_description = "sweet jelly"

/datum/reagent/consumable/cum/seelie
	taste_description = "dewdrops and clover"

/datum/reagent/consumable/cum/beastkin
	taste_description = "wild musk"

/datum/reagent/consumable/cum/half_beastkin
	taste_description = "faint wild musk"

/datum/reagent/consumable/cum/critterkin
	taste_description = "nuts and seeds"

/datum/reagent/consumable/cum/half_critterkin
	taste_description = "faint nuttiness"

/datum/reagent/consumable/cum/taurkin
	taste_description = "grass and musk"

// Nectar.

/datum/reagent/consumable/femcum/elf
	taste_description = "flowery sweetness"

/datum/reagent/consumable/femcum/drow
	taste_description = "mushroomy sweetness"

/datum/reagent/consumable/femcum/halfelf
	taste_description = "faint flowery sweetness"

/datum/reagent/consumable/femcum/halfdrow
	taste_description = "faint mushroomy sweetness"

/datum/reagent/consumable/femcum/tiefling
	taste_description = "hotness and sweetness"

/datum/reagent/consumable/femcum/dwarf
	taste_description = "tangy hops"

/datum/reagent/consumable/femcum/halforc
	taste_description = "salty meat"

/datum/reagent/consumable/femcum/lizardfolk
	taste_description = "salty bitterness"

/datum/reagent/consumable/femcum/tabaxi
	taste_description = "tangy mint"

/datum/reagent/consumable/femcum/dracon
	taste_description = "smoky sweetness"

/datum/reagent/consumable/femcum/kobold
	taste_description = "salty fish"

/datum/reagent/consumable/femcum/goblinp
	taste_description = "sour fish"

/datum/reagent/consumable/femcum/halfling
	taste_description = "honey and warm bread"

/datum/reagent/consumable/femcum/gnome
	taste_description = "fizzy sweetness"

/datum/reagent/consumable/femcum/harpy
	taste_description = "berries and blossom honey"

/datum/reagent/consumable/femcum/aasimar
	taste_description = "sweet nectar and incense"

/datum/reagent/consumable/femcum/yuanti
	taste_description = "cool, bitter sweetness"

/datum/reagent/consumable/femcum/triton
	taste_description = "salty sea spray"

/datum/reagent/consumable/femcum/kenku
	taste_description = "marsh herbs and sweetness"

/datum/reagent/consumable/femcum/warforged
	taste_description = "sweet oil and copper"

/datum/reagent/consumable/femcum/fluvian
	taste_description = "night-blooming flowers"

/datum/reagent/consumable/femcum/gnoll
	taste_description = "heavy musk and salt"

/datum/reagent/consumable/femcum/ogre
	taste_description = "earthy salt"

/datum/reagent/consumable/femcum/ooze
	taste_description = "slick, fruity jelly"

/datum/reagent/consumable/femcum/seelie
	taste_description = "flower nectar"

/datum/reagent/consumable/femcum/beastkin
	taste_description = "musky sweetness"

/datum/reagent/consumable/femcum/half_beastkin
	taste_description = "faint musky sweetness"

/datum/reagent/consumable/femcum/critterkin
	taste_description = "sweet nuttiness"

/datum/reagent/consumable/femcum/half_critterkin
	taste_description = "faint, sweet nuttiness"

/datum/reagent/consumable/femcum/taurkin
	taste_description = "sweet grass and musk"

// Milk. Species milk still salts into cheese, see get_salted_type().

/datum/reagent/consumable/milk/elf
	description = "An opaque white liquid produced by the mammary glands of mammals. It seeems tinted a little green..."
	color = "#d0f3de"
	taste_description = "mint and cream"
	glass_desc = "It smells faintly like mint."

/datum/reagent/consumable/milk/tiefling
	description = "An opaque white liquid produced by the mammary glands of mammals. It seeems tinted a little red..."
	color = "#f1d4c0"
	taste_description = "creamy butterscotch and cinnamon"

/datum/reagent/consumable/milk/darkelf
	description = "An opaque white liquid produced by the mammary glands of mammals. It seeems tinted a little grey..."
	color = "#c2cbec"
	taste_description = "tartness and mushrooms"

/datum/reagent/consumable/milk/dwarf
	description = "An opaque white liquid produced by the mammary glands of mammals. It seeems tinted a little yellow..."
	color = "#ece4bd"
	taste_description = "hops, cream and barley"

/datum/reagent/consumable/milk/halfelf
	description = "Breast milk with a faint green tint."
	color = "#e4f3e8"
	taste_description = "faint mint and cream"

/datum/reagent/consumable/milk/halfdrow
	description = "Breast milk with a faint grey tint."
	color = "#dde1ee"
	taste_description = "faint tartness and cream"

/datum/reagent/consumable/milk/halforc
	description = "Thick breast milk with a faint olive tint."
	color = "#ece8d6"
	taste_description = "rich, salty cream"

/datum/reagent/consumable/milk/lizardfolk
	description = "Thin breast milk with a faint green sheen."
	color = "#e9ece0"
	taste_description = "thin, mineral cream"

/datum/reagent/consumable/milk/tabaxi
	description = "Warm breast milk with a faint golden tint."
	color = "#f3ebdc"
	taste_description = "warm cream and fish"

/datum/reagent/consumable/milk/dracon
	description = "Rich breast milk that smells faintly of smoke."
	color = "#ece0cf"
	taste_description = "smoky, rich cream"

/datum/reagent/consumable/milk/kobold
	description = "Thin breast milk with a faint grey-green tint."
	color = "#e6ecea"
	taste_description = "thin, fishy cream"

/datum/reagent/consumable/milk/goblin
	description = "Breast milk with a sickly yellow-green tint."
	color = "#e8ead2"
	taste_description = "sour, earthy cream"

/datum/reagent/consumable/milk/halfling
	description = "Rich breast milk with a faint golden tint."
	color = "#f3ead0"
	taste_description = "sweet cream and honey"

/datum/reagent/consumable/milk/gnome
	description = "Breast milk that fizzes very faintly."
	color = "#eef0f4"
	taste_description = "sweet cream with a fizzy tingle"

/datum/reagent/consumable/milk/harpy
	description = "Thick, yellowish breast milk, rich like custard."
	color = "#f5ecc9"
	taste_description = "rich, eggy custard"

/datum/reagent/consumable/milk/aasimar
	description = "Pale breast milk with a faint, clean shine."
	color = "#fbf6e6"
	taste_description = "sweet cream and incense"

/datum/reagent/consumable/milk/yuanti
	description = "Cool breast milk with a faint green tint."
	color = "#e4eee2"
	taste_description = "cool, faintly bitter cream"

/datum/reagent/consumable/milk/triton
	description = "Breast milk with a faint blue-green tint. It smells of the sea."
	color = "#e2eef2"
	taste_description = "salty, briny cream"

/datum/reagent/consumable/milk/kenku
	description = "Breast milk with a faint brown tint. It smells of the marsh."
	color = "#e8e2d2"
	taste_description = "earthy, peaty cream"

/datum/reagent/consumable/milk/warforged
	description = "Milky alchemical fluid with an oily sheen."
	color = "#e6e3da"
	taste_description = "oily, metallic cream"

/datum/reagent/consumable/milk/fluvian
	description = "Breast milk with a faint lilac tint and a powdery smell."
	color = "#eeeaf4"
	taste_description = "powdery, floral cream"

/datum/reagent/consumable/milk/gnoll
	description = "Rich breast milk with a strong, gamey smell."
	color = "#efe5d3"
	taste_description = "rich, gamey cream"

/datum/reagent/consumable/milk/ogre
	description = "Very thick, fatty breast milk."
	color = "#f1ead8"
	taste_description = "thick, fatty cream"

/datum/reagent/consumable/milk/ooze
	description = "Jelly-like breast milk that wobbles in the cup."
	color = "#e3f1e4"
	taste_description = "sweet, jellied cream"

/datum/reagent/consumable/milk/seelie
	description = "Delicate breast milk that smells of clover."
	color = "#f4f1e2"
	taste_description = "sweet dew and clover honey"

/datum/reagent/consumable/milk/beastkin
	description = "Rich breast milk with a wild smell."
	color = "#f0e7d8"
	taste_description = "rich, wild cream"

/datum/reagent/consumable/milk/half_beastkin
	description = "Breast milk with a faint wild smell."
	color = "#f0eade"
	taste_description = "faintly wild cream"

/datum/reagent/consumable/milk/critterkin
	description = "Breast milk with a nutty smell."
	color = "#efe6d6"
	taste_description = "nutty cream"

/datum/reagent/consumable/milk/half_critterkin
	description = "Breast milk with a faint nutty smell."
	color = "#f0e9dc"
	taste_description = "faintly nutty cream"

/datum/reagent/consumable/milk/taurkin
	description = "Rich breast milk that smells of fresh grass."
	color = "#eeecd6"
	taste_description = "grassy, rich cream"

/// The reagent this milk turns into when salted for cheese, or null if it cannot be salted.
/datum/reagent/consumable/milk/proc/get_salted_type()
	return /datum/reagent/consumable/milk/salted

/datum/reagent/consumable/milk/gote/get_salted_type()
	return /datum/reagent/consumable/milk/salted_gote

/datum/reagent/consumable/milk/salted/get_salted_type()
	return null

/datum/reagent/consumable/milk/salted_gote/get_salted_type()
	return null
