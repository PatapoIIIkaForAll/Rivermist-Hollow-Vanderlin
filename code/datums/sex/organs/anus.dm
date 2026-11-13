/obj/item/organ/genitals/filling_organ/anus
	//absorbs faster than womb, less capacity.
	name = "anus"
	icon_state = "anus"
	dropshrink = 0.5
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_ANUS
	accessory_type = /datum/sprite_accessory/none
	max_reagents = 30 //less size than vagene in turn for more effective absorbtion
	reagent_to_make = null
	absorbing = TRUE
	absorbmult = 1.5 //more effective absorb than others i guess.
	// Slow drains sized for a few-unit load: it stays about four minutes, or about twelve when held in.
	absorbrate = 0.1
	driprate = 0.2
	// A slow tick keeps each drop big enough to wet cloth while the hole drains at a quarter pace.
	processspeed = 20 SECONDS
	can_hold_in = TRUE
	allows_oviposition_pregnancy = TRUE
	oviposition_storage_component_type = /datum/component/body_storage/anus
	oviposition_location_name = "anus"
	altnames = list("ass", "asshole", "butt", "butthole", "guts") //used in thought messages.
	spiller = TRUE
	blocker = ITEM_SLOT_PANTS
	bloatable = TRUE
	additional_blocker = "underwear"
	drips_as_drops = TRUE

/obj/item/organ/genitals/filling_organ/anus/Insert(mob/living/M, special, drop_if_replaced, new_zone = null)
	. = ..()
	if(!.)
		return FALSE
	add_bodystorage(M, null, /datum/component/body_storage/anus)

/obj/item/organ/genitals/filling_organ/anus/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	var/datum/component/body_storage/anus/comp = GetComponent(/datum/component/body_storage/anus)
	comp?.RemoveComponent()
