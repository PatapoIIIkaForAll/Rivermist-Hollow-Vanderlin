// RMH - Клеймо: brands are skin mark entries (TATTOO_MEDIUM_BRAND / _ARCANE), one per zone.
// Also the temporary fiery handprint, which is an effect and not an entry.

// A target counts as held still when unconscious, cuffed, buckled, or held in an
// aggressive grab by the person doing the work.
/proc/is_held_still(mob/living/carbon/patient, mob/living/user)
	if(patient.stat >= UNCONSCIOUS || patient.handcuffed || patient.buckled)
		return TRUE
	if(user && user.pulling == patient && user.grab_state >= GRAB_AGGRESSIVE)
		return TRUE
	return FALSE

/obj/item/bodypart
	/// Precise body zone of a temporary fiery handprint.
	var/handprint_zone
	/// world.time the handprint fades at.
	var/handprint_expire = 0

/obj/item/bodypart/proc/get_visible_handprint_zone(mob/user)
	if(!handprint_zone)
		return null
	if(world.time >= handprint_expire)
		handprint_zone = null
		return null
	if(owner && !isobserver(user) && !get_location_accessible(owner, handprint_zone))
		return null
	return handprint_zone

/obj/item/bodypart/proc/set_handprint(zone, duration)
	handprint_zone = zone
	handprint_expire = world.time + duration

/// Fine zones on a targeted doll zone, falling back from precise zones to their limb.
/proc/skin_mark_zones_on_target(targeted_zone)
	return GLOB.tattoo_zones_by_limb[targeted_zone] || GLOB.tattoo_zones_by_limb[deprecise_zone(targeted_zone)]

/// Why a zone cannot take a brand from user now, or null when it can.
/mob/living/carbon/human/proc/brand_zone_problem(zone, mob/living/user)
	if(!has_tattoo_zone(zone))
		return "There is nothing to brand there!"
	var/obj/item/bodypart/part = get_bodypart(tattoo_zone_limb(zone))
	if(part.count_brands_on_zone(zone) >= MAXIMUM_BRANDS_PER_ZONE)
		return "[src] is already branded there."
	if(!is_tattoo_zone_visible(zone))
		return "The clothing is in the way!"
	if(user != src && tattoo_zone_is_intimate(zone) && !get_erp_pref(/datum/erp_preference/boolean/allow_intimate_tattoos))
		return "[src] isn't willing to have that area marked."
	return null

/// Asks which fine zone on the targeted limb to brand. Null when cancelled or none can take one.
/mob/living/carbon/human/proc/pick_brand_zone(mob/living/user, targeted_zone)
	var/list/by_name = list()
	var/first_problem
	for(var/zone in skin_mark_zones_on_target(targeted_zone))
		var/problem = brand_zone_problem(zone, user)
		if(problem)
			first_problem ||= problem
			continue
		by_name[capitalize(tattoo_zone_name(zone))] = zone
	if(!length(by_name))
		to_chat(user, span_warning(first_problem || "There is nothing to brand there!"))
		return null
	if(length(by_name) == 1)
		return by_name[by_name[1]]
	var/choice = input(user, "Where exactly?", "Branding Placement") as null|anything in by_name
	return choice ? by_name[choice] : null

/// Burns a brand onto a zone. TRUE when it landed.
/mob/living/carbon/human/proc/add_skin_brand(zone, text, arcane = FALSE, glow)
	var/obj/item/bodypart/part = get_bodypart(tattoo_zone_limb(zone))
	if(!part)
		return FALSE
	var/medium = arcane ? TATTOO_MEDIUM_ARCANE : TATTOO_MEDIUM_BRAND
	return part.add_tattoo(zone, text, TATTOO_STYLE_LETTERING, sanitize_skin_mark_color(medium, glow), medium)

/mob/living/carbon/human/proc/has_arcane_brand()
	for(var/obj/item/bodypart/part as anything in bodyparts)
		for(var/list/entry in part.tattoos)
			if(entry["medium"] == TATTOO_MEDIUM_ARCANE)
				return TRUE
	return FALSE

/// Cleansing magic lifts every arcane brand. Returns how many faded.
/mob/living/carbon/human/proc/remove_arcane_brands()
	. = 0
	for(var/obj/item/bodypart/part as anything in bodyparts)
		for(var/list/entry in part.tattoos?.Copy())
			if(entry["medium"] == TATTOO_MEDIUM_ARCANE)
				part.tattoos -= list(entry)
				.++
	if(.)
		visible_message(span_notice("The glowing sigils on [src] flicker and fade away."), \
			span_notice("The sigils burned into my skin flicker and fade."))

/*
 * EXAMINE
 *
 * General examine says where a brand sits. Limb inspect and Look at Features
 * show its text. Observers see through clothing.
 */

/// Hover hint on general examine brand lines: the text shows on a second, closer look.
#define BRAND_LOOK_CLOSER_TIP "Examine again to look closer."

/mob/living/carbon/proc/get_brand_body_lines(mob/user, list/P)
	. = list()
	if(ishuman(src))
		var/mob/living/carbon/human/human_self = src
		for(var/zone in GLOB.tattoo_zone_data)
			var/obj/item/bodypart/part = get_bodypart(tattoo_zone_limb(zone))
			if(!part?.count_brands_on_zone(zone))
				continue
			if(!isobserver(user) && !human_self.is_tattoo_zone_visible(zone))
				continue
			for(var/list/entry in part.tattoos)
				if(entry["zone"] != zone)
					continue
				if(entry["medium"] == TATTOO_MEDIUM_BRAND)
					. += span_danger(span_tooltip(BRAND_LOOK_CLOSER_TIP, "[capitalize(P[THEY])] [P[HAVE]] a brand burned onto [P[THEIR]] [tattoo_zone_name(zone)]."))
				else if(entry["medium"] == TATTOO_MEDIUM_ARCANE)
					var/glow = entry["color"]
					. += "<span style='color: [glow]; text-shadow: 0 0 3px [glow];'>[span_tooltip(BRAND_LOOK_CLOSER_TIP, "A glowing sigil marks [P[THEIR]] [tattoo_zone_name(zone)].")]</span>"
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(part.get_visible_handprint_zone(user))
			. += span_danger("There is a fiery handprint seared onto [P[THEM]].")
			break

/obj/item/bodypart/proc/get_brand_examine_lines(mob/user)
	. = list()
	var/mob/living/carbon/human/human_owner = ishuman(owner) ? owner : null
	for(var/list/entry in tattoos)
		var/medium = entry["medium"]
		if(!is_brand_mark(medium))
			continue
		var/zone = entry["zone"]
		if(human_owner && !isobserver(user) && !human_owner.is_tattoo_zone_visible(zone))
			continue
		if(medium == TATTOO_MEDIUM_ARCANE)
			. += "A sigil glows on the [tattoo_zone_name(zone)]: [format_tattoo_entry_text(entry)]"
		else
			. += span_danger("Branded on the [tattoo_zone_name(zone)]: [format_tattoo_entry_text(entry)]")
	var/hand_visible = get_visible_handprint_zone(user)
	if(hand_visible)
		. += span_danger("A fiery handprint is seared across the [parse_zone(hand_visible)].")

/*
 * REMOVAL
 *
 * Only a legendary healer burns a plain brand away. Arcane brands ignore fire;
 * cleansing magic (Rite of Deliverance, essence Cleanse) lifts them.
 */

// Called from the cautery's own interact_with_atom in surgery_tools_rogue.dm: that handler runs before attack()
// and would otherwise answer "no wounds!" first. Returns NONE to fall through.
/obj/item/weapon/surgery/cautery/proc/try_remove_brand(mob/living/carbon/patient, mob/living/user)
	if(!ishuman(patient) || !istype(user.a_intent, INTENT_USE))
		return NONE
	var/mob/living/carbon/human/human_patient = patient
	var/list/by_name = list()
	var/arcane_seen = FALSE
	for(var/zone in skin_mark_zones_on_target(user.zone_selected))
		var/obj/item/bodypart/part = human_patient.get_bodypart(tattoo_zone_limb(zone))
		for(var/list/entry in part?.tattoos)
			if(entry["zone"] != zone)
				continue
			if(entry["medium"] == TATTOO_MEDIUM_BRAND)
				by_name[capitalize(tattoo_zone_name(zone))] = zone
			else if(entry["medium"] == TATTOO_MEDIUM_ARCANE)
				arcane_seen = TRUE
	if(!length(by_name))
		if(!arcane_seen)
			return NONE
		to_chat(user, span_warning("The sigil does not yield to healing. Only cleansing magic can lift it."))
		return ITEM_INTERACT_BLOCKING

	if(user.get_skill_level(/datum/skill/misc/medicine) < SKILL_RANK_LEGENDARY)
		to_chat(user, span_warning("Scarring like this is beyond my craft. Only a legendary healer could cut it away cleanly."))
		return ITEM_INTERACT_BLOCKING

	if(!is_held_still(patient, user))
		to_chat(user, span_warning("[patient] needs to be held still for this."))
		return ITEM_INTERACT_BLOCKING

	var/brand_zone = by_name[by_name[1]]
	if(length(by_name) > 1)
		var/choice = input(user, "Which brand should I heal away?", "Remove Branding") as null|anything in by_name
		if(!choice)
			return ITEM_INTERACT_BLOCKING
		brand_zone = by_name[choice]

	if(!human_patient.is_tattoo_zone_visible(brand_zone))
		to_chat(user, span_warning("The clothing is in the way!"))
		return ITEM_INTERACT_BLOCKING

	var/zone_name = tattoo_zone_name(brand_zone)
	patient.visible_message(span_danger("[user] begins carefully healing the brand from [patient]'s [zone_name]..."), \
		span_userdanger("[user] begins healing the brand from your [zone_name]!"))

	if(!do_after(user, 15 SECONDS, patient))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/bodypart/limb = human_patient.get_bodypart(tattoo_zone_limb(brand_zone))
	if(QDELETED(patient) || QDELETED(limb))
		return ITEM_INTERACT_BLOCKING
	if(!get_temperature() || !is_held_still(patient, user) || !user.Adjacent(patient) || !human_patient.is_tattoo_zone_visible(brand_zone))
		to_chat(user, span_warning("The work is interrupted."))
		return ITEM_INTERACT_BLOCKING
	var/list/brand_entry
	for(var/list/entry in limb.tattoos)
		if(entry["zone"] == brand_zone && entry["medium"] == TATTOO_MEDIUM_BRAND)
			brand_entry = entry
			break
	if(!brand_entry)
		return ITEM_INTERACT_BLOCKING

	limb.tattoos -= list(brand_entry)
	patient.apply_damage(10, BURN, limb.body_zone)
	patient.visible_message(span_notice("[user] heals the brand away, leaving only clean scar tissue."), \
		span_notice("The brand is gone. Only smooth scarring remains."))
	return ITEM_INTERACT_SUCCESS

#undef BRAND_LOOK_CLOSER_TIP
