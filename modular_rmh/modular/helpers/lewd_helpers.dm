//this would go to surgery helpers normally.
/proc/get_organ_blocker(mob/user, location = BODY_ZONE_CHEST)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		for(var/obj/item/clothing/equipped_item in carbon_user.get_equipped_items(include_pockets = FALSE))
			if(zone2covered(location, equipped_item.body_parts_covered))
				//skips bra items if the location we are looking at is groin
				if(equipped_item.is_bra && location == BODY_ZONE_PRECISE_GROIN)
					continue
				return equipped_item

/// TRUE for armor heavier than light that keeps hands off what it covers; clothes never do.
/obj/item/clothing/proc/blocks_sex_reach()
	return armor_class > AC_LIGHT && !allow_erp_equipped && !genital_access

/// The worn armor keeping [actor] off [location], or null. A null actor means the strict answer: armor blocks.
/mob/living/proc/get_sex_covering_garment(location = BODY_ZONE_CHEST, mob/living/actor)
	for(var/obj/item/clothing/garment in get_equipped_items())
		if(!garment.blocks_sex_reach())
			continue
		if(location in cover_flags2body_zones(garment.body_parts_covered))
			return allows_reach_under_armor(actor) ? null : garment
	return null

/// TRUE when this mob lets player [actor], itself included, reach under its armor; mobs always strip it first.
/mob/living/proc/allows_reach_under_armor(mob/living/actor)
	if(!actor?.is_player_sex_actor())
		return FALSE
	return get_cached_erp_pref(/datum/erp_preference/boolean/allow_reach_under_armor) == TRUE

/// TRUE when a player drives this mob; AI-run mobs have no client.
/mob/living/proc/is_player_sex_actor()
	return !!client

/obj/item/clothing/armor
	flags_inv = HIDEBOOB|HIDEBELLY|HIDEUNDIESTOP|HIDEUNDIESBOT|HIDECLOSEBODY

/obj/item/clothing/pants
	flags_inv = HIDEBUTT|HIDECROTCH|HIDEUNDIESBOT|HIDECLOSELEGS

/obj/item/clothing/shirt
	flags_inv = HIDEBUTT|HIDEBOOB|HIDEBELLY|HIDEUNDIESTOP|HIDECLOSEBODY

/obj/item
	var/genital_access = FALSE
	///for bra only body armors that allow groin interactions.
	var/is_bra = FALSE

/obj/item/organ/genitals
	var/visible_through_clothes = FALSE

/mob/living/carbon/verb/toggle_genitals()
	set category = "IC"
	set name = "Expose/Hide genitals"
	set desc = "Allows you to toggle which genitals should show through clothes or not."

	if(stat != CONSCIOUS)
		to_chat(usr, span_warning("You can toggle genitals visibility right now..."))
		return

	var/list/genital_list = list()
	for(var/obj/item/organ/G in internal_organs)
		if(G.visible_organ \
			&& !istype(G, /obj/item/organ/eyes) \
			&& !istype(G, /obj/item/organ/ears) \
			&& !istype(G, /obj/item/organ/genitals/filling_organ/anus))
			genital_list += G

	if(!genital_list.len)
		return

	//Full list of exposable genitals created
	var/obj/item/organ/picked_organ
	picked_organ = input(src, "Choose which genitalia to expose/hide", "Expose/Hide genitals") \
		as null|anything in genital_list

	if(!picked_organ \
		|| QDELETED(picked_organ) \
		|| stat != CONSCIOUS \
		|| picked_organ.owner != src \
		|| !(picked_organ in internal_organs))
		return

	var/vis_type = input(src, "How will it be shown?", "Expose/Hide genitals") \
		in list("Hidden", "Show Under clothes", "Show Above clothes")

	// Re-validate again after yield
	if(!picked_organ \
		|| QDELETED(picked_organ) \
		|| stat != CONSCIOUS \
		|| picked_organ.owner != src \
		|| !(picked_organ in internal_organs))
		return

	picked_organ.toggle_visibility(vis_type)

/obj/item/organ/genitals/toggle_visibility(vis_type)
	switch(vis_type)
		if("Show Under clothes")
			visible_through_clothes = TRUE
		if("Show Above clothes")
			visible_through_clothes = DRAW_ABOVE
		else
			visible_through_clothes = FALSE
	if(owner)
		owner.regenerate_icons()
