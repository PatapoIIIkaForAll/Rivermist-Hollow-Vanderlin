// Sewn on cured hide with a needle, like other leatherwork.
/datum/repeatable_crafting_recipe/leather/bdsm_gear
	abstract_type = /datum/repeatable_crafting_recipe/leather/bdsm_gear
	category = "Lewd"
	craftdiff = 2

/datum/repeatable_crafting_recipe/leather/bdsm_gear/black_muzzle
	name = "black leather muzzle"
	output = /obj/item/clothing/face/bdsm_gag/muzzle/black
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/fibers = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/brown_muzzle
	name = "brown leather muzzle"
	output = /obj/item/clothing/face/bdsm_gag/muzzle/brown
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/fibers = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/black_ballgag
	name = "black ball gag"
	output = /obj/item/clothing/face/bdsm_gag/ball/black
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/brown_ballgag
	name = "brown ball gag"
	output = /obj/item/clothing/face/bdsm_gag/ball/brown
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/black_ringgag
	name = "black ring gag"
	output = /obj/item/clothing/face/bdsm_gag/ring/black
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/ingot/iron = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/brown_ringgag
	name = "brown ring gag"
	output = /obj/item/clothing/face/bdsm_gag/ring/brown
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/ingot/iron = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/black_harnessgag
	name = "black harness gag"
	output = /obj/item/clothing/face/bdsm_gag/harness/black
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/bdsm_gear/brown_harnessgag
	name = "brown harness gag"
	output = /obj/item/clothing/face/bdsm_gag/harness/brown
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/bdsm_gear/black_collar
	name = "black leashed collar"
	output = /obj/item/clothing/neck/leathercollar/bdsm/black
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/ingot/iron = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/brown_collar
	name = "brown leashed collar"
	output = /obj/item/clothing/neck/leathercollar/bdsm/brown
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/ingot/iron = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/black_chain_leash
	name = "black collar chain leash"
	output = /obj/item/leash/chain/bdsm/black
	requirements = list(/obj/item/rope/chain = 1, /obj/item/natural/hide/cured = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/brown_chain_leash
	name = "brown collar chain leash"
	output = /obj/item/leash/chain/bdsm/brown
	requirements = list(/obj/item/rope/chain = 1, /obj/item/natural/hide/cured = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/black_shackles
	name = "black leather shackles"
	output = /obj/item/rope/bdsm_shackles/black
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/ingot/iron = 1)
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/bdsm_gear/brown_shackles
	name = "brown leather shackles"
	output = /obj/item/rope/bdsm_shackles/brown
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/ingot/iron = 1)
	craftdiff = 3

// Mostly cloth, so it is sewn on cloth instead of hide.
/datum/repeatable_crafting_recipe/sewing/bdsm_nundorei
	name = "penitent nun outfit"
	output = /obj/item/clothing/shirt/undershirt/bdsm_nundorei
	requirements = list(/obj/item/natural/cloth = 3, /obj/item/natural/hide/cured = 1)
	category = "Lewd"
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/bdsm_gear/leatherhalfsuit
	name = "leather halfsuit"
	output = /obj/item/clothing/shirt/undershirt/bdsm_halfsuit
	requirements = list(/obj/item/natural/hide/cured = 3, /obj/item/natural/fibers = 2)
	craftdiff = 3

/datum/repeatable_crafting_recipe/leather/bdsm_gear/leatherstockings
	name = "leather stockings"
	output = /obj/item/clothing/legwears/bdsm_leather
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/natural/fibers = 2)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/leathergloves
	name = "shiny leather gloves" //shiny cuz clashes with normal glove recipe
	output = /obj/item/clothing/gloves/bdsm_leather
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/natural/fibers = 1)

/datum/anvil_recipe/bdsm_iron_shackles
	name = "Iron Shackles"
	i_type = "Lewd"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/rope/chain)
	created_item = /obj/item/rope/bdsm_shackles/iron

/datum/anvil_recipe/bdsm_serpent_shackles
	name = "Serpent Shackles"
	i_type = "Lewd"
	req_bar = /obj/item/ingot/gold
	additional_items = list(/obj/item/ingot/iron, /obj/item/natural/hide/cured)
	created_item = /obj/item/rope/bdsm_shackles/serpent
