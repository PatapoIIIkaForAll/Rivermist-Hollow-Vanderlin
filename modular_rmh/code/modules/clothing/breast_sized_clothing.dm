// Worn sprites that follow the wearer's breast size, packed by tools/breast_sized_clothing/pack_breast_sized.py.

#define BREAST_SIZED_SLOT_BRA "bra"
#define BREAST_SIZED_SLOT_SHIRT "shirt"
#define BREAST_SIZED_SLOT_ARMOR "armor"
#define BREAST_SIZED_SLOT_CLOAK "cloak"

/// Chest slots that can hold a breast-sized garment, bottom to top.
GLOBAL_LIST_INIT(breast_sized_slots, list(
	BREAST_SIZED_SLOT_BRA,
	BREAST_SIZED_SLOT_SHIRT,
	BREAST_SIZED_SLOT_ARMOR,
	BREAST_SIZED_SLOT_CLOAK,
))

/obj/item
	/// Sheet with one worn state per breast size, named after icon_state. Null keeps the plain "_boob" overlay.
	var/breast_sized_icon
	/// Covers the whole chest: the breasts and every sized garment beneath stay hidden.
	var/breast_sized_closed = FALSE

/// Clothing tag of a race drawn with its own clothing art ("dwarf"), as build_worn_icon() gets it; else null.
/mob/living/carbon/human/proc/get_clothing_custom_tag()
	var/datum/species/species = dna?.species
	if(!species?.custom_clothes)
		return null
	return species.custom_id || species.id

/// Wearer's visible breast size when this garment has a sheet state for it, else null.
/obj/item/proc/get_breast_sized_size(mob/living/carbon/human/wearer)
	return text2num(get_breast_sized_size_key(wearer))

/// Size part of this garment's sheet states for wearer: "<N>", or "<N>_<tag>" for a race with its own art; else null.
/obj/item/proc/get_breast_sized_size_key(mob/living/carbon/human/wearer)
	if(!breast_sized_icon || !ishuman(wearer))
		return null
	var/datum/species/species = wearer.dna?.species
	if(!species?.sexes || species.no_boobs || species.swap_female_clothes)
		return null
	if(wearer.gender != FEMALE || wearer.get_body_cut() != BODY_CUT_FEMININE)
		return null
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = wearer.getorganslot(ORGAN_SLOT_BREASTS)
	// Quad and sextuple breasts wear the pair-shaped sheet too; a plain fallback would hide them.
	if(!istype(breasts) || !ispath(breasts.accessory_type, /datum/sprite_accessory/genitals/breasts))
		return null
	var/tag = wearer.get_clothing_custom_tag()
	var/size_key = "[breasts.get_visible_size()][tag ? "_[tag]" : ""]"
	if(!icon_exists(breast_sized_icon, "[icon_state]_f_[size_key]"))
		return null
	if(covered_by_plain_chest_garment(wearer))
		return null
	return size_key

/// A plain garment above this one hides the chest, so a sized base would poke out from under it.
/obj/item/proc/covered_by_plain_chest_garment(mob/living/carbon/human/wearer)
	var/hide_flags = HIDEBOOB | HIDEJUMPSUIT
	if(src == wearer.bra)
		hide_flags |= HIDEUNDIESTOP
	var/above = FALSE
	for(var/slot in GLOB.breast_sized_slots)
		var/obj/item/item = wearer.get_chest_slot_item(slot)
		if(item == src)
			above = TRUE
			continue
		if(!above || !item || !(item.flags_inv & hide_flags))
			continue
		if(!item.uses_breast_sized_layers(wearer))
			return TRUE
	return FALSE

/obj/item/proc/uses_breast_sized_layers(mob/living/carbon/human/wearer)
	return !isnull(get_breast_sized_size(wearer))

/// Size part of the sheet state build_worn_icon() uses, "<N>", "<N>_jiggle" or "<N>_run", else null.
/obj/item/proc/get_breast_sized_worn_suffix(coom, customi, isinhands)
	if(isinhands || coom != FEMALE_BOOB || !boobed || !ishuman(loc))
		return null
	var/mob/living/carbon/human/wearer = loc
	// The size key already carries the wearer's custom clothing tag.
	var/size = get_breast_sized_size_key(wearer)
	if(isnull(size))
		return null
	// Without children the whole garment is one still, so nothing bounces over still breasts.
	if(!wearer.breast_children_allowed() && icon_exists(breast_sized_icon, "[icon_state]_f_[size]_still"))
		return "[size]_still"
	var/datum/component/breast_animation/animation = wearer.GetComponent(/datum/component/breast_animation)
	if(animation?.jiggling && icon_exists(breast_sized_icon, "[icon_state]_f_[size]_jiggle"))
		return "[size]_jiggle"
	if(animation?.running && icon_exists(breast_sized_icon, "[icon_state]_f_[size]_run"))
		return "[size]_run"
	return "[size]"

/// Without a breasts child the worn sprite draws the front cloth itself, so previews and still mobs stay covered.
/obj/item/proc/add_breast_sized_front(mutable_appearance/standing, suffix, layer2use)
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/wearer = loc
	if(wearer.breast_animation_active() || findtext(suffix, "_still"))
		return
	var/front_state = "[icon_state]_f_[suffix]_front"
	if(!icon_exists(breast_sized_icon, front_state))
		return
	standing.overlays.Add(mutable_appearance(breast_sized_icon, front_state, -layer2use))
	var/detail_state = "[icon_state]_f_detail_[suffix]_front"
	if(!get_detail_tag() || !icon_exists(breast_sized_icon, detail_state))
		return
	var/mutable_appearance/detail = mutable_appearance(breast_sized_icon, detail_state, -layer2use)
	detail.appearance_flags = RESET_COLOR
	if(get_detail_color())
		detail.color = get_detail_color()
	standing.overlays.Add(detail)

/// Whether a closed breast-sized garment is worn above this one; garments is get_breast_sized_garments() when known.
/obj/item/proc/is_under_closed_breast_sized(mob/living/carbon/human/wearer, list/garments)
	if(!garments)
		garments = wearer.get_breast_sized_garments()
	var/below = FALSE
	for(var/slot in garments)
		var/obj/item/garment = garments[slot]
		if(below && garment.breast_sized_closed)
			return TRUE
		if(garment == src)
			below = TRUE
	return FALSE

/// Item in a chest slot by name; cloaks count only on the tabard layer.
/mob/living/carbon/human/proc/get_chest_slot_item(slot)
	switch(slot)
		if(BREAST_SIZED_SLOT_BRA)
			return bra
		if(BREAST_SIZED_SLOT_SHIRT)
			return wear_shirt
		if(BREAST_SIZED_SLOT_ARMOR)
			return wear_armor
		if(BREAST_SIZED_SLOT_CLOAK)
			return cloak?.alternate_worn_layer == TABARD_LAYER ? cloak : null
	return null

/// OFFSET_* key the worn overlay of a chest slot is shifted by.
/proc/get_breast_sized_offset_key(slot)
	switch(slot)
		if(BREAST_SIZED_SLOT_BRA)
			return OFFSET_BRA
		if(BREAST_SIZED_SLOT_SHIRT)
			return OFFSET_SHIRT
		if(BREAST_SIZED_SLOT_ARMOR)
			return OFFSET_ARMOR
		if(BREAST_SIZED_SLOT_CLOAK)
			return OFFSET_CLOAK
	return null

/// Slot name to worn sized garment, bottom to top.
/mob/living/carbon/human/proc/get_breast_sized_garments()
	. = list()
	for(var/slot in GLOB.breast_sized_slots)
		var/obj/item/garment = get_chest_slot_item(slot)
		if(garment?.uses_breast_sized_layers(src))
			.[slot] = garment

/mob/living/carbon/human/proc/breasts_covered_by_closed_garment()
	var/list/garments = get_breast_sized_garments()
	for(var/slot in garments)
		var/obj/item/garment = garments[slot]
		if(garment.breast_sized_closed)
			return TRUE
	return FALSE

/// A plain garment over the chest; the children would draw above it, so the body stills show instead.
/mob/living/carbon/human/proc/wears_plain_chest_garment()
	for(var/obj/item/item as anything in list(bra, wear_shirt, wear_armor))
		if(item && !item.uses_breast_sized_layers(src))
			return TRUE
	// Cloaks drawn behind the body leave the south view clear.
	if(cloak && cloak.alternate_worn_layer != CLOAK_BEHIND_LAYER && !cloak.uses_breast_sized_layers(src))
		return TRUE
	return FALSE

/// Whether the breasts and garment children may draw: preference on and no plain garment over the chest.
/mob/living/carbon/human/proc/breast_children_allowed()
	return breast_animation_enabled(src) && !wears_plain_chest_garment()

/// Rebuilds the worn sprites of sized garments; all_sheets also takes ones without a state for the current size.
/mob/living/carbon/human/proc/update_breast_sized_worn(all_sheets = FALSE)
	var/obj/item/worn_bra = get_chest_slot_item(BREAST_SIZED_SLOT_BRA)
	if(worn_bra?.breast_sized_icon && (all_sheets || worn_bra.uses_breast_sized_layers(src)))
		update_inv_undie_top()
	// Cloak, armor and shirt updates cascade downward, so only the outermost one runs.
	for(var/slot in list(BREAST_SIZED_SLOT_CLOAK, BREAST_SIZED_SLOT_ARMOR, BREAST_SIZED_SLOT_SHIRT))
		var/obj/item/garment = get_chest_slot_item(slot)
		if(!garment?.breast_sized_icon || !(all_sheets || garment.uses_breast_sized_layers(src)))
			continue
		switch(slot)
			if(BREAST_SIZED_SLOT_CLOAK)
				update_inv_cloak()
			if(BREAST_SIZED_SLOT_ARMOR)
				update_inv_armor()
			if(BREAST_SIZED_SLOT_SHIRT)
				update_inv_shirt()
		return

/// Whether any chest garment has a breast-sized sheet, whatever the wearer's size.
/mob/living/carbon/human/proc/wears_breast_sized_sheet()
	for(var/slot in GLOB.breast_sized_slots)
		var/obj/item/garment = get_chest_slot_item(slot)
		if(garment?.breast_sized_icon)
			return TRUE
	return FALSE

/// is_human_part_visible(owner, HIDEBOOB|HIDEJUMPSUIT) that lets breast-sized garments through.
/// skip_under_layers ignores layers worn beneath the sized garments, such as a leotard under a gown.
/proc/breasts_visible_under_clothes(mob/living/carbon/owner, skip_under_layers = FALSE)
	if(!istype(owner))
		return TRUE
	var/list/under_layers = skip_under_layers ? list(owner.undershirt, owner.underwear, owner.legwear_socks, owner.garter, owner.armsleeves) : null
	for(var/obj/item/item as anything in get_all_worn_items(owner))
		if(!(item.flags_inv & (HIDEBOOB|HIDEJUMPSUIT)))
			continue
		if(under_layers && (item in under_layers))
			continue
		if(ishuman(owner) && item.uses_breast_sized_layers(owner))
			continue
		return FALSE
	return TRUE

/obj/item/clothing/shirt/dress/gown
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/springgown.dmi'
	breast_sized_closed = TRUE

/obj/item/clothing/shirt/dress/gown/summergown
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/summergown.dmi'
	breast_sized_closed = FALSE

/obj/item/clothing/shirt/dress/gown/wintergown
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/wintergown.dmi'

/obj/item/clothing/shirt/dress/gown/fallgown
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/fallgown.dmi'
	breast_sized_closed = FALSE

// Subtypes with their own art (loudmouth, weddingdress) find no states for their icon_state and fall back.
/obj/item/clothing/shirt/dress/silkdress
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/silkdress.dmi'

// Princess and prince subtypes find no states for their icon_state and fall back.
// The low neckline shows the top of the breasts, so the gown is not closed.
/obj/item/clothing/shirt/dress/royal
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/royaldress.dmi'

/obj/item/clothing/bra
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/bra.dmi'
	boobed = TRUE

/obj/item/clothing/bra/bikini
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/bikini_top.dmi'

/obj/item/clothing/bra/exoticsilkbra
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/exoticsilkbra.dmi'

/obj/item/clothing/bra/shibari
	breast_sized_icon = 'modular_rmh/icons/clothing/onmob/breast_sized/shibari.dmi'

#undef BREAST_SIZED_SLOT_BRA
#undef BREAST_SIZED_SLOT_SHIRT
#undef BREAST_SIZED_SLOT_ARMOR
#undef BREAST_SIZED_SLOT_CLOAK
