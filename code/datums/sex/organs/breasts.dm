/// Breasts refill at full speed until this share of capacity holds milk.
#define BREAST_QUICK_FILL_RATIO 0.3
/// Speed share left when full; it falls to this in a straight line from the quick-fill limit.
#define BREAST_FULL_FILL_MULT 0.15

/obj/item/organ/genitals/filling_organ/breasts
	name = "breasts"
	icon_state = "breasts"
	visible_organ = TRUE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BREASTS
	organ_size = DEFAULT_BREASTS_SIZE
	reagent_to_make = /datum/reagent/consumable/milk
	// Milk costs more than drinking it gives back, so it cannot feed its maker.
	nutrition_per_unit = 2
	// 15 to 90 units by size; 60 at the default size.
	storage_per_size = 15
	// Default-size rate while nearly empty; about 40 minutes from empty to full when well fed.
	production_rate = 0.03
	hungerhelp = TRUE
	absorbing = FALSE //funny liquid tanks
	startsfilled = TRUE
	allows_oviposition_pregnancy = FALSE
	altnames = list("breasts", "tits", "milkers", "tiddies", "badonkas", "boobas") //used in thought messages.
	blocker = ITEM_SLOT_SHIRT
	additional_blocker = "bra"
	organ_sizeable = TRUE
	can_engorge = TRUE
	leaks_when_full = TRUE
	drips_as_drops = TRUE
	stain_zone = FLUID_STAIN_CHEST

/obj/item/organ/genitals/filling_organ/breasts/Insert(mob/living/M, special, drop_if_replaced, new_zone = null)
	if(M?.breast_milk)
		set_reagent_to_make(M.breast_milk)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(M))
		M.LoadComponent(/datum/component/breast_animation)
	add_bodystorage(M, null, /datum/component/body_storage/breasts)
	var/obj/item/organ/genitals/nipple/left/l_nip = new /obj/item/organ/genitals/nipple/left
	var/obj/item/organ/genitals/nipple/right/r_nip = new /obj/item/organ/genitals/nipple/right
	l_nip.Insert(M, FALSE, FALSE)
	r_nip.Insert(M, FALSE, FALSE)


	// One size status follows the visible size, replacing the per-size statuses.
	if(ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.update_breast_size_effect()

/obj/item/organ/genitals/filling_organ/breasts/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	var/datum/component/breast_animation/breast_animation = M?.GetComponent(/datum/component/breast_animation)
	breast_animation?.refresh()
	var/datum/component/body_storage/breasts/comp = GetComponent(/datum/component/body_storage/breasts)
	comp?.RemoveComponent()
	if(ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.update_breast_size_effect()

/obj/item/organ/genitals/filling_organ/breasts/get_availability(datum/species/owner_species, mob/living/C, datum/preferences/pref_load)
	if(issimple(C))
		return C.gender == FEMALE
	else
		if(pref_load)
			return pref_load.has_enabled_customizer_entry(/datum/customizer_entry/organ/genitals/breasts)
		else
			return C.gender == FEMALE

/// Quick refill while nearly empty, slower as milk builds; capacity scales it so every size refills equally fast.
/obj/item/organ/genitals/filling_organ/breasts/get_fill_rate_multiplier()
	var/size_scale = reagents.maximum_volume / (storage_per_size * (1 + DEFAULT_BREASTS_SIZE))
	var/fullness = get_own_fullness()
	if(fullness <= BREAST_QUICK_FILL_RATIO)
		return size_scale
	var/slowdown = (fullness - BREAST_QUICK_FILL_RATIO) / (1 - BREAST_QUICK_FILL_RATIO)
	return size_scale * (1 - slowdown * (1 - BREAST_FULL_FILL_MULT))

#undef BREAST_QUICK_FILL_RATIO
#undef BREAST_FULL_FILL_MULT
