/*/datum/customizer/bodypart_feature/underwear
	name = "Underwear"
	customizer_choices = list(/datum/customizer_choice/bodypart_feature/underwear)
	allows_disabling = TRUE
	default_disabled = TRUE

/datum/customizer_choice/bodypart_feature/underwear
	name = "Underwear"
	feature_type = /datum/bodypart_feature/underwear
	default_accessory = /datum/sprite_accessory/underwear/athletic_leotard
	sprite_accessories = list(
		/datum/sprite_accessory/underwear/briefs,
		/datum/sprite_accessory/underwear/panties,
		/datum/sprite_accessory/underwear/bikini,
		/datum/sprite_accessory/underwear/leotard,
		/datum/sprite_accessory/underwear/athletic_leotard,
		/datum/sprite_accessory/underwear/braies
		)

/datum/customizer/bodypart_feature/legwear
	name = "Legwear"
	customizer_choices = list(/datum/customizer_choice/bodypart_feature/legwear)
	allows_disabling = TRUE
	default_disabled = TRUE

/datum/customizer_choice/bodypart_feature/legwear
	name = "Legwear"
	feature_type = /datum/bodypart_feature/legwear
	//default_accessory = /datum/sprite_accessory/legwear/stockings
	sprite_accessories = list(
		/datum/sprite_accessory/legwear/stockings,
		/datum/sprite_accessory/legwear/stockings/silk,
		/datum/sprite_accessory/legwear/stockings/fishnet,
		)

/datum/bodypart_feature/underwear/bodypart_feature_additem(mob/living/carbon/owner, obj/item/bodypart/bp)
	.=..()

	if(owner)
		var/datum/sprite_accessory/underwear/u_s = accessory_type
		var/obj/item/clothing/undies/undie = new u_s.underwear_type
		owner.equip_to_slot_if_possible(undie, ITEM_SLOT_UNDERWEAR)
		bp.remove_bodypart_feature(src)
		return TRUE
	return FALSE

/datum/bodypart_feature/legwear/bodypart_feature_additem(mob/living/carbon/owner, obj/item/bodypart/bp)
	.=..()

	if(owner)
		var/datum/sprite_accessory/legwear/l_s = accessory_type
		var/obj/item/clothing/legwears/sock = new l_s.legwear_type
		owner.equip_to_slot_if_possible(sock, ITEM_SLOT_SOCKS)
		bp.remove_bodypart_feature(src)
		return TRUE
	return FALSE*/
