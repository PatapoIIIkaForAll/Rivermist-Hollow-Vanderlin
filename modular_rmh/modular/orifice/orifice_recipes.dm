// Recipes, vials and trade packs for slick balm, the tightness draughts and rosewater salve.

/// Twenty measures of water give ten of draught, like the other hedge-witch brews.
#define ORIFICE_BREW_CONVERSION 0.5
/// Ten measures of rose water give fifteen of salve.
#define ROSEWATER_SALVE_CONVERSION 1.5
/// Measures one cauldron batch of a permanent or prank draught yields.
#define RARE_DRAUGHT_UNITS 8

/datum/chemical_reaction/slick_balm
	name = "Slick Balm"
	id = "slick_balm"
	required_reagents = list(
		/datum/reagent/consumable/herbal/rosa_oil = 10,
		/datum/reagent/consumable/honey = 5,
		/datum/reagent/water = 5,
	)
	results = list(/datum/reagent/lubricant = 15)
	mix_message = "The oil and honey thicken into a clear, slippery balm."

/datum/chemical_reaction/warming_balm
	name = "Warming Balm"
	id = "warming_balm"
	required_reagents = list(
		/datum/reagent/medicine/herbal/mentha_oil = 10,
		/datum/reagent/consumable/honey = 5,
		/datum/reagent/water = 5,
	)
	results = list(/datum/reagent/lubricant/warming = 15)
	mix_message = "The mint oil and honey thicken into a pale balm that warms the fingers."

/obj/item/reagent_containers/glass/bottle/vial/slick_balm
	desc = "A vial of clear, slippery balm. The label shows two clasped hands."
	list_reagents = list(/datum/reagent/lubricant = 15)

/// Herbal pot brews for the everyday tightness draughts and the rosewater salve.
/datum/container_craft/cooking/herbal_tea/orifice_brew
	abstract_type = /datum/container_craft/cooking/herbal_tea/orifice_brew
	category = "Intimate Remedies"
	water_conversion = ORIFICE_BREW_CONVERSION
	crafting_time = 12 SECONDS
	finished_smell = /datum/pollutant/food/herb

/// Valerian and chamomile, both old relaxants.
/datum/container_craft/cooking/herbal_tea/orifice_brew/yielding
	name = "Yielding Draught"
	created_reagent = /datum/reagent/orifice_potion/yielding
	requirements = list(
		/obj/item/alch/herb/valeriana = 1,
		/obj/item/alch/herb/matricaria = 1,
	)
	finished_smell = /datum/pollutant/food/flower
	complete_message = "The draught turns honey-pink and smells of chamomile."

/// Knitbone and astringent sage draw flesh tight.
/datum/container_craft/cooking/herbal_tea/orifice_brew/maidens_knot
	name = "Maiden's Knot"
	created_reagent = /datum/reagent/orifice_potion/maidens_knot
	requirements = list(
		/obj/item/alch/herb/symphitum = 1,
		/obj/item/alch/herb/salvia = 1,
	)
	finished_smell = /datum/pollutant/food/bitter
	complete_message = "The draught turns sage-green and puckers the tongue at a sniff."

/// Spurge sap stretches like latex; mint eases the strain.
/datum/container_craft/cooking/herbal_tea/orifice_brew/limber_draught
	name = "Limber Draught"
	created_reagent = /datum/reagent/orifice_potion/limber_draught
	requirements = list(
		/obj/item/alch/herb/euphorbia = 1,
		/obj/item/alch/herb/mentha = 1,
	)
	finished_smell = /datum/pollutant/food/mint
	complete_message = "The draught turns milky and stretches in strings from the spoon."

/// Rose water from the herbal pot, thickened with marigold and lavender.
/datum/container_craft/cooking/herbal_tea/orifice_brew/rosewater_salve
	name = "Rosewater Salve"
	created_reagent = /datum/reagent/lubricant/rosewater
	reagent_requirements = list(
		/datum/reagent/medicine/herbal/simple_rosa = 10,
	)
	water_conversion = ROSEWATER_SALVE_CONVERSION
	requirements = list(
		/obj/item/alch/herb/calendula = 1,
		/obj/item/alch/herb/lavender = 1,
	)
	finished_smell = /datum/pollutant/fragrance/rose
	complete_message = "The rose water thickens into a soft, fragrant salve."

/// The rare draughts cost magic essence and an expert hand.
/datum/alch_cauldron_recipe/wanton_draught
	recipe_name = "Draught of the Wanton"
	smells_like = "spiced wine and musk"
	output_reagents = list(/datum/reagent/orifice_potion/wanton = RARE_DRAUGHT_UNITS)
	required_essences = list(
		/datum/thaumaturgical_essence/chaos = 12,
		/datum/thaumaturgical_essence/motion = 9,
		/datum/thaumaturgical_essence/life = 9,
		/datum/thaumaturgical_essence/magic = 12,
	)
	skill_required = SKILL_RANK_EXPERT

/datum/alch_cauldron_recipe/maiden_draught
	recipe_name = "Draught of the Maiden"
	smells_like = "cold spring water and white petals"
	output_reagents = list(/datum/reagent/orifice_potion/maiden = RARE_DRAUGHT_UNITS)
	required_essences = list(
		/datum/thaumaturgical_essence/order = 12,
		/datum/thaumaturgical_essence/crystal = 9,
		/datum/thaumaturgical_essence/life = 9,
		/datum/thaumaturgical_essence/magic = 12,
	)
	skill_required = SKILL_RANK_EXPERT

/datum/alch_cauldron_recipe/gapers_gall
	recipe_name = "Gaper's Gall"
	smells_like = "bitter bile"
	output_reagents = list(/datum/reagent/orifice_potion/gapers_gall = RARE_DRAUGHT_UNITS)
	required_essences = list(
		/datum/thaumaturgical_essence/void = 12,
		/datum/thaumaturgical_essence/chaos = 9,
		/datum/thaumaturgical_essence/poison = 5,
		/datum/thaumaturgical_essence/magic = 9,
	)
	skill_required = SKILL_RANK_EXPERT

/obj/item/reagent_containers/glass/bottle/vial/yielding_draught
	desc = "A vial of honey-pink draught. The label shows an opening rosebud."
	list_reagents = list(/datum/reagent/orifice_potion/yielding = 8)

/obj/item/reagent_containers/glass/bottle/vial/maidens_knot
	desc = "A vial of sage-green draught. The label shows a cord tied in a tight knot."
	list_reagents = list(/datum/reagent/orifice_potion/maidens_knot = 8)

/obj/item/reagent_containers/glass/bottle/vial/limber_draught
	desc = "A vial of milky blue draught. The label shows a reed bending in the wind."
	list_reagents = list(/datum/reagent/orifice_potion/limber_draught = 8)

/obj/item/reagent_containers/glass/bottle/vial/rosewater_salve
	desc = "A vial of soft pink salve that smells of roses. The label shows a hand cupping a rose."
	list_reagents = list(/datum/reagent/lubricant/rosewater = 15)

/obj/item/reagent_containers/glass/bottle/vial/wanton_draught
	desc = "A vial of deep crimson draught. The label shows a rose in full, open bloom."
	list_reagents = list(/datum/reagent/orifice_potion/wanton = 8)

/obj/item/reagent_containers/glass/bottle/vial/maiden_draught
	desc = "A vial of clear, cold draught. The label shows a closed white bud."
	list_reagents = list(/datum/reagent/orifice_potion/maiden = 8)

/obj/item/reagent_containers/glass/bottle/vial/gapers_gall
	desc = "A vial of murky olive draught. There is no label, only a crude drawing of an open mouth."
	list_reagents = list(/datum/reagent/orifice_potion/gapers_gall = 8)

// Everyday vials trade as Narcotics goods; the three rare draughts stay alchemist-made.
/datum/supply_pack/narcotics/slick_balm
	name = "Slick Balm"
	cost = 10
	contains = /obj/item/reagent_containers/glass/bottle/vial/slick_balm

/datum/supply_pack/narcotics/rosewater_salve
	name = "Rosewater Salve"
	cost = 15
	contains = /obj/item/reagent_containers/glass/bottle/vial/rosewater_salve

/datum/supply_pack/narcotics/yielding_draught
	name = "Yielding Draught"
	cost = 20
	contains = /obj/item/reagent_containers/glass/bottle/vial/yielding_draught

/datum/supply_pack/narcotics/maidens_knot
	name = "Maiden's Knot"
	cost = 20
	contains = /obj/item/reagent_containers/glass/bottle/vial/maidens_knot

/datum/supply_pack/narcotics/limber_draught
	name = "Limber Draught"
	cost = 20
	contains = /obj/item/reagent_containers/glass/bottle/vial/limber_draught

#undef ORIFICE_BREW_CONVERSION
#undef ROSEWATER_SALVE_CONVERSION
#undef RARE_DRAUGHT_UNITS
