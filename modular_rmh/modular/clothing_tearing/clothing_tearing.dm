// Cloth garments torn open at the chest or the hem; sewing closes them again.

// Hide flags a torn top or a torn hem stops setting.
#define TORN_TOP_REVEALS (HIDEBOOB|HIDEUNDIESTOP)
#define TORN_HEM_REVEALS (HIDECROTCH|HIDEBUTT|HIDEUNDIESBOT)
// Only garments worn over the body tear; underwear, bras and trousers never do.
#define TEARABLE_SLOTS (ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK)
// Share of max integrity one tear takes; a tear never breaks the garment.
#define CLOTHES_TEAR_DAMAGE_RATIO 0.15
#define CLOTHES_TEAR_TIME (2 SECONDS)
#define TORN_TOP_ORGAN_SIGNALS list(COMSIG_ORGAN_REMOVED, COMSIG_PARENT_QDELETING)

/obj/item/clothing
	var/torn_top = FALSE
	var/torn_hem = FALSE
	/// Hide flags the top tear took away, put back by sewing.
	var/torn_top_flags_restore = NONE
	/// Hide flags the hem tear took away, put back by sewing.
	var/torn_hem_flags_restore = NONE
	/// Worn sheet before a torn hem swapped in the hiked sheet.
	var/torn_hem_overlay_restore
	/// Sleeve helper before a torn hem swapped in the hiked one.
	var/torn_hem_sleeved_restore

/// Cloth with no armour class that a needle can mend; armour never tears.
/obj/item/clothing/proc/is_tearable_cloth()
	return armor_class == ARMOR_CLASS_NONE && sewrepair && (slot_flags & TEARABLE_SLOTS)

/obj/item/clothing/proc/can_tear_top()
	return !torn_top && is_tearable_cloth() && (body_parts_covered & CHEST) && (flags_inv & HIDEBOOB)

/// A hem covers the groin from the shirt, armour or cloak slot, as dresses, robes and skirts do.
/obj/item/clothing/proc/can_tear_hem()
	return !torn_hem && is_tearable_cloth() && (body_parts_covered & GROIN) && (flags_inv & HIDECROTCH)

/obj/item/clothing/proc/can_tear_at(zone)
	switch(zone)
		if(BODY_ZONE_CHEST)
			return can_tear_top()
		if(BODY_ZONE_PRECISE_GROIN)
			return can_tear_hem()
	return FALSE

/obj/item/clothing/proc/has_clothing_tears()
	return torn_top || torn_hem

/// Tears the top (chest) or the hem (groin) open, damages the cloth and redraws the wearer. TRUE when it tore.
/obj/item/clothing/proc/tear_open_at(zone)
	if(!can_tear_at(zone))
		return FALSE
	if(zone == BODY_ZONE_CHEST)
		torn_top = TRUE
		torn_top_flags_restore = flags_inv & TORN_TOP_REVEALS
		flags_inv &= ~TORN_TOP_REVEALS
	else
		torn_hem = TRUE
		torn_hem_flags_restore = flags_inv & TORN_HEM_REVEALS
		flags_inv &= ~TORN_HEM_REVEALS
		apply_torn_hem_sheet()
	take_tear_damage()
	playsound(src, 'sound/foley/cloth_rip.ogg', 50, TRUE)
	refresh_torn_wearer()
	return TRUE

/// Takes a share of integrity but stops short of the broken threshold.
/obj/item/clothing/proc/take_tear_damage()
	if(!uses_integrity)
		return
	var/room = atom_integrity - integrity_failure * max_integrity - 1
	var/amount = min(max_integrity * CLOTHES_TEAR_DAMAGE_RATIO, room)
	if(amount > 0)
		take_damage(amount, BRUTE, "", FALSE)

/// Garments with hiked art show the torn hem with it; hoods and adjustments change states the sheet may lack.
/obj/item/clothing/proc/apply_torn_hem_sheet()
	if(hoodtype || adjustable > 0 || !is_hikeable(FALSE))
		return
	// is_hikeable passes an already-hiked garment without a registry lookup, so check for a sheet first.
	var/hiked_icon = GLOB.hiked_onmob_icons["[mob_overlay_icon]"]
	if(!hiked_icon)
		return
	torn_hem_overlay_restore = mob_overlay_icon
	mob_overlay_icon = hiked_icon
	var/hiked_sleeves = get_hiked_sleeves(FALSE)
	if(hiked_sleeves)
		torn_hem_sleeved_restore = sleeved
		sleeved = hiked_sleeves

/// Closes both tears and puts back every hide flag and sheet they changed.
/obj/item/clothing/proc/mend_tears()
	if(!has_clothing_tears())
		return FALSE
	if(torn_top)
		torn_top = FALSE
		flags_inv |= torn_top_flags_restore
		torn_top_flags_restore = NONE
	if(torn_hem)
		torn_hem = FALSE
		flags_inv |= torn_hem_flags_restore
		torn_hem_flags_restore = NONE
		if(torn_hem_overlay_restore)
			mob_overlay_icon = torn_hem_overlay_restore
			torn_hem_overlay_restore = null
		if(torn_hem_sleeved_restore)
			sleeved = torn_hem_sleeved_restore
			torn_hem_sleeved_restore = null
	refresh_torn_wearer()
	return TRUE

/obj/item/clothing/proc/refresh_torn_wearer()
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || QDELETED(wearer))
		return
	wearer.update_torn_top_state()
	wearer.regenerate_icons()

/obj/item/clothing/proc/get_tear_examine_lines()
	. = list()
	if(torn_top)
		. += span_warning("It is torn open at the chest.")
	if(torn_hem)
		. += span_warning("Its hem is torn.")

/// The garment a tear at [zone] would hit: the outermost one hiding it, skipping layers already torn there.
/mob/living/carbon/human/proc/get_tear_target(zone)
	RETURN_TYPE(/obj/item/clothing)
	var/hide_flag = zone == BODY_ZONE_CHEST ? HIDEBOOB : HIDECROTCH
	for(var/obj/item/clothing/garment in list(cloak, wear_armor, wear_shirt))
		if(zone == BODY_ZONE_CHEST ? garment.torn_top : garment.torn_hem)
			continue
		if(garment.flags_inv & hide_flag)
			return garment
	return null

/// TRUE when [user] holds this mob in an aggressive grab or stronger.
/mob/living/carbon/human/proc/is_tear_grabbed_by(mob/living/user)
	return istype(user) && user != src && user.pulling == src && user.grab_state >= GRAB_AGGRESSIVE

/// The sleeve rule: strength times eight percent.
/proc/clothes_tear_roll(mob/living/user)
	return prob(GET_MOB_ATTRIBUTE_VALUE(user, STAT_STRENGTH) * 8)

/// A grabber tears the top or hem at [zone] after a warned do-after that a broken grab stops.
/mob/living/carbon/human/proc/try_tear_clothes(mob/living/user, zone)
	if(!is_tear_grabbed_by(user))
		return FALSE
	var/obj/item/clothing/garment = get_tear_target(zone)
	if(!garment)
		if(zone == BODY_ZONE_PRECISE_GROIN && istype(wear_pants, /obj/item/clothing))
			to_chat(user, span_warning("[wear_pants] has no hem to tear."))
		else
			to_chat(user, span_warning("There is nothing there to tear."))
		return TRUE
	if(!garment.can_tear_at(zone))
		to_chat(user, span_warning("[garment] is too sturdy to tear."))
		return TRUE
	var/at_chest = zone == BODY_ZONE_CHEST
	user.visible_message(span_warning("[user] grabs [at_chest ? "the front" : "the hem"] of [src]'s [garment.name] and starts to tear it!"))
	if(!do_after(user, CLOTHES_TEAR_TIME, src, extra_checks = CALLBACK(src, PROC_REF(is_tear_grabbed_by), user)))
		return TRUE
	if(QDELETED(garment) || garment.loc != src || !is_tear_grabbed_by(user) || !garment.can_tear_at(zone))
		return TRUE
	if(!clothes_tear_roll(user))
		user.visible_message(span_warning("[user] pulls at [src]'s [garment.name], but the cloth holds."))
		return TRUE
	var/garment_name = garment.name
	if(garment.tear_open_at(zone))
		user.visible_message(span_warning(at_chest ? "[user] tears [src]'s [garment_name] open at the chest." : "[user] tears the hem of [src]'s [garment_name]."))
	return TRUE

/// The wearer or holder tears this garment at the chest or groin, like a sleeve.
/obj/item/clothing/proc/try_self_tear(mob/living/user, zone)
	if(!can_tear_at(zone))
		if(is_tearable_cloth() || torn_top || torn_hem)
			to_chat(user, span_info("There is nothing there to tear."))
		return
	if(!do_after(user, CLOTHES_TEAR_TIME, user))
		return
	if(loc != user || !can_tear_at(zone))
		return
	if(!clothes_tear_roll(user))
		user.visible_message(span_warning("[user] tries to tear [src]."))
		return
	var/at_chest = zone == BODY_ZONE_CHEST
	if(tear_open_at(zone))
		user.visible_message(span_notice(at_chest ? "[user] tears [src] open at the chest." : "[user] tears the hem of [src]."))

/// Lines for the wearer's examine about worn garments torn open.
/mob/living/carbon/human/proc/get_torn_clothes_examine_lines(list/P)
	. = list()
	var/list/unobscured = get_unobscured_items(FALSE)
	for(var/obj/item/clothing/garment in list(cloak, wear_armor, wear_shirt))
		if(!garment.has_clothing_tears() || !(garment in unobscured))
			continue
		if(garment.torn_top)
			. += span_warning("[capitalize(P[THEIR])] [garment.name] is torn open at the chest.")
		if(garment.torn_hem)
			. += span_warning("[capitalize(P[THEIR])] [garment.name] is torn at the hem.")

/// A worn top torn open, or null; [ignore] is an item on its way out of a slot.
/mob/living/carbon/human/proc/get_worn_torn_top(obj/item/ignore)
	RETURN_TYPE(/obj/item/clothing)
	for(var/obj/item/clothing/garment in list(cloak, wear_armor, wear_shirt))
		if(garment != ignore && garment.loc == src && garment.torn_top)
			return garment
	return null

/// TRUE when a torn top is the only thing over the breasts, so the sprite should draw them above clothes.
/mob/living/carbon/human/proc/torn_top_bares_breasts(obj/item/ignore)
	if(!getorganslot(ORGAN_SLOT_BREASTS) || !get_worn_torn_top(ignore))
		return FALSE
	if(underwear && underwear != ignore && (underwear.covers_breasts || underwear.hides_organ_slot(ORGAN_SLOT_BREASTS)))
		return FALSE
	for(var/obj/item/worn as anything in get_equipped_items())
		if(worn == ignore || worn.loc != src)
			continue
		if(worn.flags_inv & (HIDEBOOB|HIDEJUMPSUIT))
			return FALSE
	return TRUE

/// Adds or drops the torn-top watcher to match the worn garments.
/mob/living/carbon/human/proc/update_torn_top_state(obj/item/ignore)
	var/datum/component/torn_top/torn = GetComponent(/datum/component/torn_top)
	if(!get_worn_torn_top(ignore))
		if(torn)
			qdel(torn)
		return
	if(!torn)
		torn = AddComponent(/datum/component/torn_top)
	torn?.refresh(ignore)

/mob/living/carbon/human/proc/refresh_torn_top_exposure()
	var/datum/component/torn_top/torn = GetComponent(/datum/component/torn_top)
	torn?.refresh()

/// Lives while a torn top is worn; shows the breasts above clothes when nothing else covers them.
/datum/component/torn_top
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Breasts organ to the visible_through_clothes it had before this showed it.
	var/list/organ_visibility

/datum/component/torn_top/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_unequip))

/datum/component/torn_top/Destroy(force)
	hide_breasts()
	return ..()

/datum/component/torn_top/proc/on_equip(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	refresh()

/// The leaving item still sits in its slot when this fires, so it is ignored.
/datum/component/torn_top/proc/on_unequip(datum/source, obj/item/item)
	SIGNAL_HANDLER
	refresh(item)

/// Applies or clears the shown breasts; another change to the organ since is taken as its new baseline.
/datum/component/torn_top/proc/refresh(obj/item/ignore)
	var/mob/living/carbon/human/wearer = parent
	if(!wearer.torn_top_bares_breasts(ignore))
		if(length(organ_visibility))
			hide_breasts()
			wearer.regenerate_icons()
		return
	var/changed = FALSE
	for(var/obj/item/organ/genitals/breasts in wearer.getorganslotlist(ORGAN_SLOT_BREASTS))
		if(breasts.visible_through_clothes == DRAW_ABOVE)
			continue
		if(!(breasts in organ_visibility))
			RegisterSignals(breasts, TORN_TOP_ORGAN_SIGNALS, PROC_REF(on_organ_gone))
		LAZYSET(organ_visibility, breasts, breasts.visible_through_clothes)
		breasts.visible_through_clothes = DRAW_ABOVE
		changed = TRUE
	if(changed)
		wearer.regenerate_icons()

/// Puts back what this showed, unless something else changed the organ since.
/datum/component/torn_top/proc/hide_breasts()
	for(var/obj/item/organ/genitals/breasts as anything in organ_visibility)
		UnregisterSignal(breasts, TORN_TOP_ORGAN_SIGNALS)
		if(breasts.visible_through_clothes == DRAW_ABOVE)
			breasts.visible_through_clothes = organ_visibility[breasts]
	organ_visibility = null

/datum/component/torn_top/proc/on_organ_gone(obj/item/organ/genitals/breasts)
	SIGNAL_HANDLER
	UnregisterSignal(breasts, TORN_TOP_ORGAN_SIGNALS)
	if(breasts.visible_through_clothes == DRAW_ABOVE)
		breasts.visible_through_clothes = organ_visibility[breasts]
	LAZYREMOVE(organ_visibility, breasts)

/// Mending a tear takes one stitch pass on a table, whatever the sewing skill.
/obj/item/needle/proc/mend_clothing_tears(obj/item/clothing/garment, mob/living/user)
	playsound(src, 'sound/foley/sewflesh.ogg', 100, TRUE, -2)
	var/sewtime = (6 SECONDS - GET_MOB_SKILL_VALUE(user, garment.sewrepair))
	if(!do_after(user, sewtime, garment))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(garment) || !garment.has_clothing_tears() || !use(1))
		return ITEM_INTERACT_BLOCKING
	garment.mend_tears()
	user.visible_message(span_info("[user] sews up the tears in [garment]."))
	return ITEM_INTERACT_SUCCESS

#undef TORN_TOP_REVEALS
#undef TORN_HEM_REVEALS
#undef TEARABLE_SLOTS
#undef CLOTHES_TEAR_DAMAGE_RATIO
#undef CLOTHES_TEAR_TIME
#undef TORN_TOP_ORGAN_SIGNALS
