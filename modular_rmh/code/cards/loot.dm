// Arlette cards in the generic loot tables. Weights keep cards at roughly 2-4% of each table;
// dungeon caches absorb the medium and rare tables as donors, so the cards reach them too.

/datum/loot_table/common/New()
	. = ..()
	loot_table += list(list(
		/obj/item/ccg_card_generator/common = 1,
		/obj/item/ccg_card_booster = 1,
	))

/datum/loot_table/medium/New()
	. = ..()
	loot_table += list(list(
		/obj/item/ccg_card_generator/rare = 1,
		/obj/item/ccg_card_booster = 1,
	))

/datum/loot_table/rare/New()
	. = ..()
	loot_table += list(list(
		/obj/item/ccg_card_generator/rare = 1,
		/obj/item/ccg_card_generator/unique = 1,
		/obj/item/ccg_card_booster/premium = 1,
	))
