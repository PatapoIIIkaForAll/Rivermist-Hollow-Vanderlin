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

/datum/enterprise_furnishing/mirror
	tiers = list(
		/obj/structure/mirror,
		/obj/structure/mirror,
		/obj/structure/mirror/fancy,
		/obj/structure/mirror/fancy,
	)
