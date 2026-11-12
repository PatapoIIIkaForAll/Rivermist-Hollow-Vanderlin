/datum/enterprise_furnishing
	abstract_type = /datum/enterprise_furnishing
	var/list/kinds = list()
	var/list/tiers = list()

/datum/enterprise_furnishing/proc/get_tier(level)
	if(!length(tiers))
		return null
	return tiers[clamp(level, 1, length(tiers))]

/datum/enterprise_furnishing/bed
	kinds = list(
		/obj/structure/bed,
		/obj/structure/bed/shit,
	)
	tiers = list(
		/obj/structure/bed/hay,
		/obj/structure/bed/mediocre,
		/obj/structure/bed/wool,
		/obj/structure/bed/inn,
	)

/datum/enterprise_furnishing/double_bed
	tiers = list(
		/obj/structure/bed/wool/double,
		/obj/structure/bed/wool/double,
		/obj/structure/bed/inn/double,
		/obj/structure/bed/inn/double,
	)

/datum/enterprise_furnishing/chair
	kinds = list(
		/obj/structure/chair/wood,
		/obj/structure/chair/wood/alt,
		/obj/structure/chair/wood/alt/chair_noble/purple,
		/obj/structure/chair/wood/alt/fancy,
		/obj/structure/chair/wood/alt/fancy/chair4,
		/obj/structure/chair/wood/alt/fancy/chair5,
	)
	tiers = list(
		/obj/structure/chair/wood/alt/chair3,
		/obj/structure/chair/wood/alt/uncomfortable,
		/obj/structure/chair/wood/alt/chair_noble,
		/obj/structure/chair/wood/alt/chair_noble/red,
	)

/datum/enterprise_furnishing/table
	kinds = list(
		/obj/structure/table/wood/crafted,
		/obj/structure/table/wood/plain,
		/obj/structure/table/wood/plain/alt,
		/obj/structure/table/wood/plain/alto,
		/obj/structure/table/wood/plain_alt,
		/obj/structure/table/wood/reinforced,
		/obj/structure/table/wood/reinforced_alter,
		/obj/structure/table/wood/nice/decorated,
		/obj/structure/table/wood/nice/decorated_alt,
	)
	tiers = list(
		/obj/structure/table/wood,
		/obj/structure/table/wood/reinforced_alt,
		/obj/structure/table/wood/fine,
		/obj/structure/table/wood/nice,
	)

/datum/enterprise_furnishing/wall_candle
	kinds = list(
		/obj/machinery/light/fueled/wallfire/candle/r,
		/obj/machinery/light/fueled/wallfire/candle/l,
		/obj/machinery/light/fueled/wallfire/candle/weak,
	)
	tiers = list(
		/obj/machinery/light/fueled/wallfire/candle,
		/obj/machinery/light/fueled/wallfire/candle,
		/obj/machinery/light/fueled/wallfire/candle/silver,
		/obj/machinery/light/fueled/wallfire/candle/goldcandle,
	)

/datum/enterprise_furnishing/candle
	kinds = list(
		/obj/item/candle,
		/obj/item/candle/yellow,
	)
	tiers = list(
		/obj/item/candle/tin,
		/obj/item/candle/tin,
		/obj/item/candle/silver,
		/obj/item/candle/gold,
	)

/datum/enterprise_furnishing/lit_candle
	kinds = list(
		/obj/item/candle/lit,
		/obj/item/candle/yellow/lit,
	)
	tiers = list(
		/obj/item/candle/tin/lit,
		/obj/item/candle/tin/lit,
		/obj/item/candle/silver/lit,
		/obj/item/candle/gold/lit,
	)

/datum/enterprise_furnishing/mirror
	tiers = list(
		/obj/structure/mirror,
		/obj/structure/mirror,
		/obj/structure/mirror/fancy,
		/obj/structure/mirror/fancy,
	)

/datum/enterprise_furnishing/stool
	kinds = list(
		/obj/structure/chair/stool,
		/obj/structure/chair/stool/bar,
		/obj/structure/chair/stool/crafted,
	)
	tiers = list(
		/obj/structure/chair/stool,
		/obj/structure/chair/stool/cushioned,
		/obj/structure/chair/stool/cushioned/purple,
		/obj/structure/chair/stool/cushioned/red,
	)

/datum/enterprise_furnishing/bench
	kinds = list(
		/obj/structure/chair/bench/church/smallbench,
	)
	tiers = list(
		/obj/structure/chair/bench/church/smallbench,
		/obj/structure/chair/bench/church/smallbench,
		/obj/structure/chair/bench,
		/obj/structure/chair/bench,
	)

/datum/enterprise_furnishing/large_table
	kinds = list(
		/obj/structure/table/wood/large,
		/obj/structure/table/wood/large_alt,
		/obj/structure/table/wood/large_blue,
		/obj/structure/table/wood/large_new,
	)
	tiers = list(
		/obj/structure/table/wood/large_new,
		/obj/structure/table/wood/large,
		/obj/structure/table/wood/large_blue,
		/obj/structure/table/wood/large_alt,
	)

/datum/enterprise_furnishing/large_table_edge
	kinds = list(
		/obj/structure/table/wood/large/corner,
		/obj/structure/table/wood/large/corner/middle,
		/obj/structure/table/wood/large/corner/middle_east,
		/obj/structure/table/wood/large/corner/middle_west,
		/obj/structure/table/wood/large/corner/north,
		/obj/structure/table/wood/large/corner/north_east,
		/obj/structure/table/wood/large/corner/north_west,
		/obj/structure/table/wood/large/corner/south_east,
		/obj/structure/table/wood/large/corner/south_west,
		/obj/structure/table/wood/large/corner_alt,
		/obj/structure/table/wood/large/corner_blue,
		/obj/structure/table/wood/large/corner_new,
	)
	tiers = list(
		/obj/structure/table/wood/large/corner_new,
		/obj/structure/table/wood/large/corner,
		/obj/structure/table/wood/large/corner_blue,
		/obj/structure/table/wood/large/corner_alt,
	)

/obj/structure/chair/stool/cushioned
	name = "cushioned stool"
	desc = "A stool with a soft cushion on it."
	icon = 'modular_alizeria/icons/roguetown/alizeria/vladegeg_decor.dmi'
	icon_state = "decor_stool3"
	item_chair = /obj/item/chair/stool/cushioned

/obj/structure/chair/stool/cushioned/purple
	icon_state = "decor_stool2"
	item_chair = /obj/item/chair/stool/cushioned/purple

/obj/structure/chair/stool/cushioned/red
	icon_state = "decor_stool1"
	item_chair = /obj/item/chair/stool/cushioned/red

/obj/item/chair/stool/cushioned
	name = "cushioned stool"
	origin_type = /obj/structure/chair/stool/cushioned

/obj/item/chair/stool/cushioned/purple
	origin_type = /obj/structure/chair/stool/cushioned/purple

/obj/item/chair/stool/cushioned/red
	origin_type = /obj/structure/chair/stool/cushioned/red
