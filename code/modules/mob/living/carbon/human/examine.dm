/mob/living/carbon/human/get_examine_string(mob/user, thats = FALSE)
	. = ..()
	var/used_title = get_role_title()
	var/original_title
	if(job_title_override && used_title == job_title_override && job)
		var/datum/job/job_datum = SSjob.GetJob(job)
		if(!QDELETED(job_datum))
			original_title = job_datum.get_gendered_title(gender, pronouns)
	if(!used_title)
		return
	if(!IsAdminGhost(user))
		if(!get_face_name("")) // face covered?
			return
		var/is_family_member = FALSE
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			is_family_member = H.family_datum && H.family_datum == family_datum
		if(!is_family_member)
			if(HAS_TRAIT(src, TRAIT_FOREIGNER) && !HAS_ANY_OF_TRAITS(src, list(TRAIT_RECRUITED, TRAIT_RECOGNIZED)))
				return
			if(!user.mind?.do_i_know(mind, real_name))
				return
	var/title_display = conditional_tooltip_alt(used_title, original_title, original_title && original_title != used_title)
	. += ", the [title_display]"

/mob/living/carbon/human/get_examine_list(mob/user, list/P)
	. = ..()
	var/badge_line = build_preference_badges(user)
	if(badge_line)
		LAZYADDASSOCLIST(., EXAMINE_SECT_NAME + 0.5, badge_line)
	for(var/datum/quirk/Q in quirks)
		Q.on_examined(user, P, .)

	var/trait_exam = common_trait_examine()
	if(!isnull(trait_exam))
		LAZYADDASSOCLIST(., EXAMINE_SECT_HEALTH+0.9, trait_exam)

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/hierarchy_text = get_clan_hierarchy_examine(human_user)
		if(hierarchy_text)
			LAZYADDASSOCLIST(., EXAMINE_SECT_BODY, hierarchy_text)


/mob/living/carbon/human/get_examine_face(mob/user, list/P, list/examine_list)
	var/self_inspect = user == src
	var/mob/dead/observer/O = isobserver(user) ? user : null
	var/mob/living/carbon/human/H = ishuman(user) ? user : null

	if(!self_inspect && !HAS_TRAIT(src, TRAIT_FACELESS))
		user.mind?.learn_target_identity(src.mind)

	var/do_i_know = user.mind?.do_i_know(src.mind, real_name)

	/*var/datum/species/species = dna?.species
	if(species?.use_skintones)
		LAZYADDASSOCLIST(examine_list, EXAMINE_SECT_SPECIES+0.6, \
			"[capitalize(P[THEIR])] [LOWER_TEXT(species.skin_tone_wording || "skin tone")] \
			is [find_key_by_value(species.get_skin_list(), skin_tone) || "incomprehensible"].")*/

	. = list()

	if(culture)
		if((do_i_know || O || istype(culture, H?.culture?.type)) && !istype(culture, /datum/culture/universal/ambiguous))
			var/culture_msg = self_inspect ? P[THEYRE] : "I believe [LOWER_TEXT(P[THEYRE])]"
			LAZYADDASSOCLIST(examine_list, EXAMINE_SECT_SPECIES+0.6, "[culture_msg] from [culture.examined_string(src, user)].")
		else if(!self_inspect)
			LAZYADDASSOCLIST(examine_list, EXAMINE_SECT_SPECIES+0.6, "[P[THEY]] could be from anywhere.")

	if(!self_inspect)
		var/is_family = FALSE
		var/parenthood_text = GetParenthoodExamineText(H)
		if(parenthood_text)
			. += parenthood_text
			is_family = TRUE
		else if(family_datum && family_datum == H?.family_datum)
			var/family_text = ReturnRelation(user)
			if(family_text)
				. += family_text
			is_family = TRUE

		if(!is_family && !O)
			if(do_i_know)
				if(user.mind?.knows_as(mind, /datum/relation/rival))
					. += "<span class='tinynotice'>I know [P[THEM]]...</span> <span class='tinywarning'>[P[THEYRE]] my rival!</span>"
				else
					. += span_tinynotice("I know [P[THEM]].")
			else
				. += span_tinywarning("I do not know [P[THEM]].")

	. += ..()

	if(lip_style && !is_mouth_covered())
		var/lip_shade = GLOB.lipstick_shades[LOWER_TEXT(lip_color)]
		. += span_info("[capitalize(P[THEYRE])] wearing [lip_shade ? "[lip_shade] " : ""]lipstick.")
	. += get_face_lipstick_mark_lines(user, P)

	if(!self_inspect)
		if(family_datum == SSfamilytree.ruling_family && length(culinary_preferences) && HAS_CHARACTER_TRAIT(user, TRAIT_ROYALSERVANT))
			var/obj/item/reagent_containers/food/snacks/fav_food = culinary_preferences[CULINARY_FAVOURITE_FOOD]
			var/datum/reagent/consumable/fav_drink = culinary_preferences[CULINARY_FAVOURITE_DRINK]
			if(fav_food)
				if(fav_drink)
					. += span_tinynotice("[capitalize(P[THEIR])] favourites are [fav_food.name] and [fav_drink.name].")
				else
					. += span_tinynotice("[capitalize(P[THEIR])] favourite is [fav_food.name].")
			else if(fav_drink)
				. += span_tinynotice("[capitalize(P[THEIR])] favourite is [fav_drink.name].")

			var/obj/item/reagent_containers/food/snacks/hated_food = culinary_preferences[CULINARY_HATED_FOOD]
			var/datum/reagent/consumable/hated_drink = culinary_preferences[CULINARY_HATED_DRINK]
			if(hated_food)
				if(hated_drink)
					. += span_tinynotice("[P[THEY]] hate [hated_food.name] and [hated_drink.name].")
				else
					. += span_tinynotice("[P[THEY]] hate [hated_food.name].")
			else if(hated_drink)
				. += span_tinynotice("[P[THEY]] hate [hated_drink.name].")

	if(!HAS_TRAIT(src, TRAIT_FACELESS))
		if(headshot_link)
			var/safe_headshot_link = html_encode(headshot_link)
			LAZYADDASSOCLIST(examine_list, EXAMINE_SECT_HEADSHOT, chat_headshot(safe_headshot_link))
		if(flavortext || headshot_link || ooc_extra_link)
			LAZYADDASSOCLIST(examine_list, EXAMINE_SECT_HEADSHOT, "<a href='byond://?src=[REF(src)];task=view_flavor_text;'>Examine Closer</a>")
		var/has_known_gossip = length(user.mind?.get_gossip_about(mind))
		if(O && client?.prefs)
			has_known_gossip ||= length(client.prefs.read_preference(/datum/preference/list_type/rumors))
			has_known_gossip ||= length(client.prefs.read_preference(/datum/preference/list_type/noble_gossip))
		if(has_known_gossip)
			LAZYADDASSOCLIST(examine_list, EXAMINE_SECT_HEADSHOT, "<a href='byond://?src=[REF(src)];task=view_rumours_gossip;'>Recall Rumours & Gossip</a>")

/mob/living/carbon/human/examine_more(mob/user)
	. = ..()
	if(!isobserver(user) && !user.can_perform_action(src, NEED_LIGHT))
		return

	// RMH EDITED START - self-written tattoos, listed head to feet
	var/list/tattoo_lines = get_tattoo_description_lines()
	if(length(tattoo_lines))
		. |= tattoo_lines

	. |= get_piercing_inscriptions(user)
	// RMH EDITED END


//You can include this in any mob's examine() to show the examine texts of status effects!
/mob/living/proc/status_effect_examines(mob/user, pronoun_replacement, list/P)
	var/list/examine_list = list()
	if(!pronoun_replacement)
		pronoun_replacement = p_they(TRUE)

	for(var/datum/status_effect/effect as anything in status_effects)
		var/effect_text = effect.get_examine_text(user, P)
		if(!effect_text)
			continue

		var/new_text = replacetext(effect_text, "SUBJECTPRONOUN", pronoun_replacement)
		new_text = replacetext(new_text, "[pronoun_replacement] is", "[pronoun_replacement] [p_are()]")
		examine_list += new_text

	if(!length(examine_list))
		return

	return examine_list.Join("\n")



/// Descriptor lines for the first examine; a hidden face leaves only what the body and voice show.
/mob/living/carbon/human/proc/get_body_description_lines(mob/user)
	. = list()
	var/face_hidden = FALSE
	if(!isobserver(user))
		face_hidden = HAS_TRAIT(src, TRAIT_FACELESS) || !get_face_name("", include_honoraries = FALSE)
	var/list/descriptors = get_mob_descriptors(face_hidden, user)
	for(var/line in build_cool_description(descriptors, src, face_hidden, user))
		. += span_info(line)
	. += get_rear_view_lines(user, descriptors)

/// Genitals and anus a viewer behind sees past underwear that leaves the rear bare.
/mob/living/carbon/human/proc/get_rear_view_lines(mob/user, list/shown_descriptors)
	. = list()
	if(!underwear?.leaves_rear_bare() || user == src || !isturf(loc))
		return
	var/approach_dir = get_dir(user, src)
	if(!approach_dir || !(approach_dir in list(dir, turn(dir, 45), turn(dir, -45))))
		return
	for(var/obj/item/worn as anything in get_all_worn_items(src))
		if(worn != underwear && (worn.flags_inv & (HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH|HIDEBUTT)))
			return
	var/list/rear_descriptors = list()
	var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
	if(getorganslot(ORGAN_SLOT_TESTICLES) && penis?.sheath_type != SHEATH_TYPE_SLIT && !underwear.hides_organ_slot(ORGAN_SLOT_TESTICLES))
		rear_descriptors += /datum/mob_descriptor/testicles
	if(getorganslot(ORGAN_SLOT_VAGINA) && !underwear.hides_organ_slot(ORGAN_SLOT_VAGINA))
		rear_descriptors += /datum/mob_descriptor/vagina
	rear_descriptors -= shown_descriptors
	var/list/parts = list()
	var/list/used_verbage = list()
	for(var/desc_type in rear_descriptors)
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
		parts += descriptor.get_coalesce_text(src, used_verbage, user)
		used_verbage |= descriptor.verbage
	var/obj/item/organ/genitals/filling_organ/anus/anus = getorganslot(ORGAN_SLOT_ANUS)
	if(anus && !underwear.hides_organ_slot(ORGAN_SLOT_ANUS))
		var/list/adjectives = anus.orifice?.get_examine_adjectives()
		var/anus_text = "an exposed anus[length(adjectives) ? ", [jointext(adjectives, ", ")]" : ""]"
		// The anus has no descriptor, so it borrows the vagina's colour rule.
		var/datum/mob_descriptor/vagina/color_rule = MOB_DESCRIPTOR(/datum/mob_descriptor/vagina)
		var/anus_color = color_rule.get_descriptor_color(src, user)
		parts += anus_color ? "<span style='color:[anus_color]'>[anus_text]</span>" : anus_text
	if(!length(parts))
		return
	. += span_info("[capitalize(p_their())] [underwear.name] doesn't cover [p_them()] from behind.")
	var/rear_line = treat_mob_descriptor_string("%THEY% [length(used_verbage) ? "" : "%HAVE% "][english_list(parts)].", src)
	// Marks on what this view shows; parts the main lines described are left out.
	if(anus && !length(list(/datum/mob_descriptor/butt, /datum/mob_descriptor/vagina) & shown_descriptors))
		rear_descriptors |= /datum/mob_descriptor/butt
	var/rear_marks = get_descriptor_marks(rear_descriptors, user, list(), trust_shown = TRUE)
	. += span_info(rear_marks ? "[rear_line] [rear_marks]" : rear_line)

/mob/living/carbon/human/get_examine_body(mob/user, list/P, list/examine_list)
	. = get_body_description_lines(user)
	. += ..()
	. += get_torn_clothes_examine_lines(P)
	var/list/organ_desc = list()
	var/show_undie_desc = FALSE
	var/list/arousal_data = list()
	SEND_SIGNAL(src, COMSIG_SEX_GET_AROUSAL, arousal_data)
	// Bare arousal is in the genital descriptor lines, so only clothed hints are listed here.
	if(wear_pants)
		var/obj/item/clothing/pantsies = wear_pants
		var/obj/item/clothing/undies = underwear
		if(pantsies.flags_inv & HIDECROTCH)
			if(!pantsies.genital_access)
				if(arousal_data["arousal"] > VISIBLE_AROUSAL_THRESHOLD)
					if(getorganslot(ORGAN_SLOT_PENIS))
						organ_desc += "[capitalize(P[THEYVE])] a visible bulge in [P[THEIR]] [pantsies.name]."
					if(getorganslot(ORGAN_SLOT_VAGINA))
						organ_desc += "[capitalize(P[THEYRE])] shifting [P[THEIR]] legs uncomfortably."
					//show_pant_desc = TRUE
		else if(undies)
			if(arousal_data["arousal"] > VISIBLE_AROUSAL_THRESHOLD)
				if(getorganslot(ORGAN_SLOT_PENIS))
					organ_desc += "[capitalize(P[THEYRE])] pitching a tent in [P[THEIR]] [underwear.name]."
				show_undie_desc = TRUE

	else if(underwear && !show_undie_desc)
		if(arousal_data["arousal"] > VISIBLE_AROUSAL_THRESHOLD)
			if(getorganslot(ORGAN_SLOT_PENIS))
				organ_desc += "[capitalize(P[THEYRE])] pitching a tent in [P[THEIR]] [underwear.name]."
			show_undie_desc = TRUE

	organ_desc += get_fluid_stain_examine(P)
	organ_desc += get_body_lipstick_mark_lines(user, P)

	if(length(organ_desc))
		. += span_love("[organ_desc.Join("\n")]")
