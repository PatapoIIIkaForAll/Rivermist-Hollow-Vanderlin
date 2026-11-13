// Creature seed and nectar: each wild kind makes its own named fluid, so contracts can tell it from anyone else's.

/datum/reagent/consumable/cum/creature
	abstract_type = /datum/reagent/consumable/cum/creature

/datum/reagent/consumable/femcum/creature
	abstract_type = /datum/reagent/consumable/femcum/creature

/datum/reagent/consumable/cum/creature/rat
	name = "Rat Seed"
	description = "Thin, greyish seed from a giant rat."
	color = "#b9b4ad"
	taste_description = "sewer musk"

/datum/reagent/consumable/femcum/creature/rat
	name = "Rat Nectar"
	description = "Sharp-smelling slick from a giant rat."
	taste_description = "sour musk"

/datum/reagent/consumable/cum/creature/wolf
	name = "Wolf Seed"
	description = "Thick, hot seed from a wolf."
	taste_description = "raw meat and musk"

/datum/reagent/consumable/femcum/creature/wolf
	name = "Wolf Nectar"
	description = "Heavy-scented slick from a she-wolf."
	taste_description = "wild musk"

/datum/reagent/consumable/cum/creature/bobcat
	name = "Bobcat Seed"
	description = "Pungent seed from a bobcat."
	taste_description = "fish and fur"

/datum/reagent/consumable/femcum/creature/bobcat
	name = "Bobcat Nectar"
	description = "Pungent slick from a bobcat."
	taste_description = "sharp feline musk"

/datum/reagent/consumable/cum/creature/spider
	name = "Spider Seed"
	description = "Stringy, faintly glowing seed from a cave spider."
	color = "#c9d6c4"
	taste_description = "bitter silk"

/datum/reagent/consumable/femcum/creature/spider
	name = "Spider Nectar"
	description = "Tacky, web-sweet slick from a cave spider."
	color = "#d4dccd"
	taste_description = "sticky bitterness"

/datum/reagent/consumable/cum/creature/spider/honeyed
	name = "Honeyed Seed"
	description = "Stringy seed from a beespider, golden and sweet with honey."
	color = "#e2c770"
	taste_description = "honeyed silk"

/datum/reagent/consumable/femcum/creature/spider/honeyed
	name = "Honeyed Nectar"
	description = "Tacky slick from a beespider that smells of warm honey."
	color = "#e8d28a"
	taste_description = "sticky honey"

/datum/reagent/consumable/cum/creature/bog_bug
	name = "Bog Bug Seed"
	description = "Swamp-green, gelatinous seed from a bog bug."
	color = "#8fa37a"
	taste_description = "stagnant water"

/datum/reagent/consumable/femcum/creature/bog_bug
	name = "Bog Bug Nectar"
	description = "Murky, slippery slick from a bog bug."
	color = "#a3b08f"
	taste_description = "mud and rot"

/datum/reagent/consumable/cum/creature/gator
	name = "Gator Seed"
	description = "Cold, briny seed from a gator."
	taste_description = "river silt"

/datum/reagent/consumable/femcum/creature/gator
	name = "Gator Nectar"
	description = "Cool, briny slick from a gator."
	taste_description = "brine"

/datum/reagent/consumable/cum/creature/troll
	name = "Troll Seed"
	description = "Copious, clotted seed from a troll."
	color = "#b0b7a4"
	taste_description = "moss and stone"

/datum/reagent/consumable/femcum/creature/troll
	name = "Troll Nectar"
	description = "Thick, earthy slick from a troll."
	taste_description = "wet moss"

/datum/reagent/consumable/cum/creature/minotaur
	name = "Minotaur Seed"
	description = "Heavy, scalding seed from a minotaur."
	taste_description = "hay and iron"

/datum/reagent/consumable/femcum/creature/minotaur
	name = "Minotaur Nectar"
	description = "Rich, scalding slick from a minotaur."
	taste_description = "hay and salt"

// Creature kinds that make the fluids above. Subtypes share their parent's fluids.

/mob/living/simple_animal/hostile/retaliate/bigrat
	cum = /datum/reagent/consumable/cum/creature/rat
	femcum = /datum/reagent/consumable/femcum/creature/rat

/mob/living/simple_animal/hostile/retaliate/wolf
	cum = /datum/reagent/consumable/cum/creature/wolf
	femcum = /datum/reagent/consumable/femcum/creature/wolf

/mob/living/simple_animal/hostile/retaliate/bobcat
	cum = /datum/reagent/consumable/cum/creature/bobcat
	femcum = /datum/reagent/consumable/femcum/creature/bobcat

// Beespider glands make real honey with their seed and nectar, two parts in five.
/mob/living/simple_animal/hostile/retaliate/spider
	cum = list(/datum/reagent/consumable/cum/creature/spider/honeyed = 0.6, /datum/reagent/consumable/honey = 0.4)
	femcum = list(/datum/reagent/consumable/femcum/creature/spider/honeyed = 0.6, /datum/reagent/consumable/honey = 0.4)

// Beespiders that make no honey keep the plain spider fluids.
/mob/living/simple_animal/hostile/retaliate/spider/robotic
	cum = /datum/reagent/consumable/cum/creature/spider
	femcum = /datum/reagent/consumable/femcum/creature/spider

/mob/living/simple_animal/hostile/retaliate/spider/companion
	cum = /datum/reagent/consumable/cum/creature/spider
	femcum = /datum/reagent/consumable/femcum/creature/spider

/mob/living/simple_animal/hostile/retaliate/bogbug
	cum = /datum/reagent/consumable/cum/creature/bog_bug
	femcum = /datum/reagent/consumable/femcum/creature/bog_bug

/mob/living/simple_animal/hostile/retaliate/gator
	cum = /datum/reagent/consumable/cum/creature/gator
	femcum = /datum/reagent/consumable/femcum/creature/gator

/mob/living/simple_animal/hostile/retaliate/troll
	cum = /datum/reagent/consumable/cum/creature/troll
	femcum = /datum/reagent/consumable/femcum/creature/troll

/mob/living/simple_animal/hostile/retaliate/minotaur
	cum = /datum/reagent/consumable/cum/creature/minotaur
	femcum = /datum/reagent/consumable/femcum/creature/minotaur
