// Examine text for lipstick marks: grouped lines for skin, and sentences inside the genital descriptions.

/// "faint red lipstick"; without the noun ("faint red") when an earlier phrase already named the lipstick.
/proc/get_lipstick_words(list/mark, with_noun = TRUE)
	var/list/words = list()
	if(get_lipstick_shown_alpha(mark) <= LIPSTICK_FAINT_ALPHA)
		words += "faint"
	var/shade = get_lipstick_shade(mark[LIPSTICK_MARK_COLOR])
	if(shade)
		words += shade
	if(with_noun || !shade)
		words += "lipstick"
	return jointext(words, " ")

/// One phrase for same-looking marks on skin spots, such as "red lipstick kisses on her cheek and nose".
/proc/describe_lipstick_group(list/mark, count, list/spot_names, their, first)
	var/words = get_lipstick_words(mark, first)
	var/places = "[their] [english_list(spot_names)]"
	var/single = length(spot_names) == 1
	switch(mark[LIPSTICK_MARK_KIND])
		if(LIPSTICK_KIND_SMEAR)
			if(first)
				return (count >= LIPSTICK_MARK_MAX_COUNT) ? "[words] smudged all over [places]" : "[words] smeared over [places]"
			return "[words] smears across [places]"
		if(LIPSTICK_KIND_RING, LIPSTICK_KIND_DEEP)
			return single && count == 1 ? "a [words] ring around [places]" : "[words] rings around [places]"
		if(LIPSTICK_KIND_BITE)
			if(!single)
				return "[words]-ringed bites on [places]"
			switch(count)
				if(1)
					return "a [words]-ringed bite on [places]"
				if(2)
					return "two [words]-ringed bites on [places]"
			return "several [words]-ringed bites on [places]"
	if(!single)
		return "[words] kisses on [places]"
	switch(count)
		if(1)
			return "a [words] kiss on [places]"
		if(2)
			return "two [words] kisses on [places]"
	return "a scatter of [words] kisses across [places]"

/// Descriptor type to the organ it describes; marks tied to a present organ join that organ's sentence.
/proc/get_lipstick_descriptor_slot(descriptor_type)
	var/static/list/slots = list(
		/datum/mob_descriptor/penis = ORGAN_SLOT_PENIS,
		/datum/mob_descriptor/testicles = ORGAN_SLOT_TESTICLES,
		/datum/mob_descriptor/vagina = ORGAN_SLOT_VAGINA,
		/datum/mob_descriptor/breasts = ORGAN_SLOT_BREASTS,
		/datum/mob_descriptor/butt = ORGAN_SLOT_BUTT,
	)
	return slots[descriptor_type]

/// Whether a spot's marks belong to a genital description on this body rather than the skin line.
/mob/living/carbon/human/proc/is_lipstick_spot_in_descriptors(spot)
	for(var/descriptor_type in GLOB.lipstick_mark_spots[spot]["descriptors"])
		if(get_lipstick_organ(get_lipstick_descriptor_slot(descriptor_type)))
			return TRUE
	return FALSE

/// One examine line for the visible skin marks on the face, or on the body.
/mob/living/carbon/human/proc/get_lipstick_mark_line(mob/user, list/P, face)
	if(!length(lipstick_marks))
		return null
	var/see_all = isobserver(user)
	var/list/groups = list()
	var/list/merged = list()
	for(var/spot in GLOB.lipstick_mark_spots)
		var/list/mark = lipstick_marks[spot]
		var/list/spot_data = GLOB.lipstick_mark_spots[spot]
		if(!mark || (spot in merged) || !!spot_data["face"] != !!face)
			continue
		if(is_lipstick_spot_in_descriptors(spot))
			continue
		if(!has_lipstick_spot(spot) || (!see_all && !is_lipstick_spot_visible(spot)))
			continue
		var/spot_name = spot_data["name"]
		var/count = mark[LIPSTICK_MARK_COUNT]
		var/pair = spot_data["pair"]
		var/list/pair_mark = pair ? lipstick_marks[pair] : null
		if(pair_mark && get_lipstick_words(pair_mark) == get_lipstick_words(mark) && pair_mark[LIPSTICK_MARK_KIND] == mark[LIPSTICK_MARK_KIND] \
			&& has_lipstick_spot(pair) && (see_all || is_lipstick_spot_visible(pair)))
			merged += pair
			spot_name = spot_data["pair_name"]
			count = min(count + pair_mark[LIPSTICK_MARK_COUNT], LIPSTICK_MARK_MAX_COUNT)
		// Spots that show the same lipstick the same way share one phrase.
		var/group_key = "[mark[LIPSTICK_MARK_KIND]]|[get_lipstick_words(mark)]"
		var/list/group = groups[group_key]
		if(!group)
			group = list("mark" = mark, "count" = 0, "spots" = list())
			groups[group_key] = group
		group["count"] = max(group["count"], count)
		group["spots"] += spot_name
	if(!length(groups))
		return null
	var/list/phrases = list()
	var/first = TRUE
	for(var/group_key in groups)
		var/list/group = groups[group_key]
		phrases += describe_lipstick_group(group["mark"], group["count"], group["spots"], P[THEIR], first)
		first = FALSE
	return "[capitalize(P[THEYVE])] [english_list(phrases)]."

/mob/living/carbon/human/proc/get_face_lipstick_mark_lines(mob/user, list/P)
	var/line = get_lipstick_mark_line(user, P, TRUE)
	return line ? list(span_info(line)) : list()

/mob/living/carbon/human/proc/get_body_lipstick_mark_lines(mob/user, list/P)
	. = list()
	var/line = get_lipstick_mark_line(user, P, FALSE)
	if(line)
		. += line
	var/impact_line = get_impact_mark_line(user, P)
	if(impact_line)
		. += impact_line

/// Sentences a body adds after the descriptors it shows; used holds described spots and spent wordings.
/mob/living/proc/get_descriptor_marks(list/shown_descriptors, mob/watcher, list/used, trust_shown = FALSE)
	return null

/mob/living/carbon/human/get_descriptor_marks(list/shown_descriptors, mob/watcher, list/used, trust_shown = FALSE)
	if(!length(lipstick_marks) || !length(shown_descriptors))
		return null
	var/see_all = trust_shown || isobserver(watcher)
	var/list/sentences = list()
	for(var/spot in GLOB.lipstick_mark_spots)
		var/list/mark = lipstick_marks[spot]
		var/list/descriptors = GLOB.lipstick_mark_spots[spot]["descriptors"]
		if(!mark || !length(descriptors) || (spot in used))
			continue
		if(!length(descriptors & shown_descriptors))
			continue
		if(!has_lipstick_spot(spot) || (!see_all && !is_lipstick_spot_visible(spot)))
			continue
		used += spot
		sentences += get_lipstick_organ_sentence(spot, mark, used)
	return length(sentences) ? jointext(sentences, " ") : null

/// One sentence about a genital mark, worded for the organ and the act; no wording repeats in one examine.
/mob/living/carbon/human/proc/get_lipstick_organ_sentence(spot, list/mark, list/used)
	var/first = !("lipstick named" in used)
	used |= "lipstick named"
	var/count = mark[LIPSTICK_MARK_COUNT]
	var/list/candidates = get_lipstick_sentence_templates(spot, mark[LIPSTICK_MARK_KIND], count)
	var/list/chosen = candidates[1]
	for(var/list/candidate as anything in candidates)
		if(!("wording [candidate[1]]" in used))
			chosen = candidate
			break
	used |= "wording [chosen[1]]"
	var/text = chosen[2]
	for(var/token in list("%TIP%", "%SHAFT%", "%MEMBER%", "%ROOT%", "%SACK%", "%BALLS%", "%MOUND%", "%LIPS%", "%PUSSY%", "%NIPPLES%", "%RIM%", "%PUCKER%", "%ASS%"))
		if(findtext(text, token))
			text = replacetext(text, token, get_lipstick_organ_words(token))
	text = replacetext(text, "%THEIR%", p_their())
	text = replacetext(text, "%LIPN%", get_lipstick_words(mark, TRUE))
	text = replacetext(text, "%LIP%", get_lipstick_words(mark, first))
	return capitalize(text)

/// The body-part words for this body, matched to the organ's type, sheath and arousal.
/mob/living/carbon/human/proc/get_lipstick_organ_words(token)
	switch(token)
		if("%TIP%", "%SHAFT%", "%MEMBER%", "%ROOT%")
			var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
			if(penis && penis.sheath_type != SHEATH_TYPE_NONE && penis.erect_state != ERECT_STATE_HARD)
				return (penis.sheath_type == SHEATH_TYPE_SLIT) ? "%THEIR% slit" : "%THEIR% sheath"
			var/datum/sprite_accessory/accessory = penis ? SPRITE_ACCESSORY(penis.accessory_type) : null
			var/style = accessory?.icon_state
			switch(token)
				if("%TIP%")
					switch(style)
						if("flared")
							return "the flare of %THEIR% cock"
						if("hemi", "hemiknot")
							return "both heads of %THEIR% cock"
						if("tapered")
							return "the tapered tip of %THEIR% cock"
						if("tentacle")
							return "the tip of %THEIR% tentacle"
					return "the tip of %THEIR% cock"
				if("%SHAFT%")
					return (style == "hemi" || style == "hemiknot") ? "%THEIR% twin shafts" : "%THEIR% shaft"
				if("%MEMBER%")
					return "%THEIR% member"
				if("%ROOT%")
					return (style in list("knotted", "knotted2", "barbknot", "hemiknot")) ? "the base of %THEIR% knot" : "the root of %THEIR% shaft"
		if("%SACK%")
			return "%THEIR% sack"
		if("%BALLS%")
			return "%THEIR% balls"
		if("%MOUND%", "%LIPS%", "%PUSSY%")
			var/obj/item/organ/genitals/vagina = getorganslot(ORGAN_SLOT_VAGINA)
			switch(vagina?.accessory_type)
				if(/datum/sprite_accessory/genitals/vagina/cloaca)
					return (token == "%LIPS%") ? "the rim of %THEIR% cloaca" : "%THEIR% cloaca"
				if(/datum/sprite_accessory/genitals/vagina/spade)
					switch(token)
						if("%LIPS%")
							return "the lips of %THEIR% spade"
						if("%PUSSY%")
							return "%THEIR% spade"
			switch(token)
				if("%MOUND%")
					return "%THEIR% mound"
				if("%LIPS%")
					return "%THEIR% pussy lips"
			return "%THEIR% pussy"
		if("%NIPPLES%")
			return "%THEIR% nipples"
		if("%RIM%")
			return "%THEIR% rim"
		if("%PUCKER%")
			return "%THEIR% pucker"
		if("%ASS%")
			return "%THEIR% ass"
	return token

/// Wordings for a mark, the first unused one wins: list(list(wording key, template), ...).
/proc/get_lipstick_sentence_templates(spot, kind, count)
	switch(spot)
		if(LIPSTICK_SPOT_COCK)
			switch(kind)
				if(LIPSTICK_KIND_RING)
					switch(count)
						if(1)
							return list(list("circle", "A ring of %LIPN% circles %SHAFT%."), list("marks", "A %LIP% ring marks %SHAFT%."))
						if(2)
							return list(list("circle", "Two %LIP% rings circle %SHAFT%."), list("marked", "%MEMBER% is marked with two %LIP% rings."))
					return list(list("marked", "%MEMBER% is marked with %LIP% rings."), list("circle", "%LIP% rings circle %SHAFT% from root to tip."))
				if(LIPSTICK_KIND_DEEP)
					return list(list("marks", "A ring of %LIPN% marks %ROOT%."), list("circle", "A ring of %LIPN% circles %ROOT%."))
				if(LIPSTICK_KIND_SMEAR)
					if(count >= LIPSTICK_MARK_MAX_COUNT)
						return list(list("smeared", "%MEMBER% is smeared with %LIPN% from root to tip."), list("smudged", "%MEMBER% is smudged all over with %LIPN%."))
					return list(list("smeared", "%LIPN% is smeared along %SHAFT%."), list("smudged", "%MEMBER% is smudged with %LIPN%."))
				if(LIPSTICK_KIND_BITE)
					if(count > 1)
						return list(list("bears", "%MEMBER% bears %LIP%-ringed bites."))
					return list(list("bears", "%MEMBER% bears a %LIP%-ringed bite."), list("marks", "A %LIP%-ringed bite marks %SHAFT%."))
			switch(count)
				if(1)
					return list(list("marks", "A %LIP% kiss marks %TIP%."), list("rests", "A %LIP% kiss rests on %TIP%."))
				if(2)
					return list(list("dot", "Two %LIP% kisses dot %TIP%."), list("marks", "A pair of %LIP% kisses marks %TIP%."))
			return list(list("dot", "%LIP% kisses dot %TIP%."), list("cover", "%LIP% kisses cover %TIP%."))
		if(LIPSTICK_SPOT_BALLS)
			switch(kind)
				if(LIPSTICK_KIND_SMEAR)
					return list(list("smudged", "%BALLS% are smudged with %LIPN%."), list("smeared", "%LIPN% is smeared over %SACK%."))
				if(LIPSTICK_KIND_RING, LIPSTICK_KIND_DEEP)
					return list(list("circle", "A ring of %LIPN% circles the base of %SACK%."), list("marks", "A ring of %LIPN% marks %SACK%."))
				if(LIPSTICK_KIND_BITE)
					return list(list("bears", "%SACK% bears a %LIP%-ringed bite."), list("marks", "A %LIP%-ringed bite marks %SACK%."))
			switch(count)
				if(1)
					return list(list("marks", "A %LIP% kiss marks %SACK%."), list("rests", "A %LIP% kiss rests on %BALLS%."))
				if(2)
					return list(list("dot", "Two %LIP% kisses dot %BALLS%."), list("marks", "A pair of %LIP% kisses marks %SACK%."))
			return list(list("scattered", "%LIP% kisses are scattered over %BALLS%."), list("dot", "%LIP% kisses dot %SACK%."))
		if(LIPSTICK_SPOT_VULVA)
			switch(kind)
				if(LIPSTICK_KIND_SMEAR)
					if(count >= LIPSTICK_MARK_MAX_COUNT)
						return list(list("smeared", "%LIPN% is smeared all over %PUSSY%."), list("smudged", "%PUSSY% is smudged all over with %LIPN%."))
					return list(list("smeared", "%LIPN% is smeared over %LIPS%."), list("smudged", "%PUSSY% is smudged with %LIPN%."))
				if(LIPSTICK_KIND_RING, LIPSTICK_KIND_DEEP)
					return list(list("outlines", "A ring of %LIPN% outlines %LIPS%."), list("marks", "A ring of %LIPN% marks %PUSSY%."))
				if(LIPSTICK_KIND_BITE)
					return list(list("bears", "%MOUND% bears a %LIP%-ringed bite."), list("marks", "A %LIP%-ringed bite marks %MOUND%."))
			switch(count)
				if(1)
					return list(list("marks", "A %LIP% kiss marks %MOUND%."), list("rests", "A %LIP% kiss rests on %MOUND%."))
				if(2)
					return list(list("dot", "Two %LIP% kisses dot %MOUND%."), list("marks", "A pair of %LIP% kisses marks %MOUND%."))
			return list(list("cover", "%LIP% kisses cover %MOUND%."), list("dot", "%LIP% kisses dot %MOUND%."))
		if(LIPSTICK_SPOT_NIPPLES)
			switch(kind)
				if(LIPSTICK_KIND_SMEAR)
					return list(list("smudged", "%NIPPLES% are smudged with %LIPN%."), list("smeared", "%LIPN% is smeared over %NIPPLES%."))
				if(LIPSTICK_KIND_RING, LIPSTICK_KIND_DEEP)
					return list(list("circle", "Rings of %LIPN% circle %NIPPLES%."), list("marks", "A ring of %LIPN% marks each of %NIPPLES%."))
				if(LIPSTICK_KIND_BITE)
					if(count > 1)
						return list(list("bear", "%NIPPLES% bear %LIP%-ringed bites."))
					return list(list("bears", "One of %NIPPLES% bears a %LIP%-ringed bite."))
			if(count == 1)
				return list(list("marks", "A %LIP% kiss marks one of %NIPPLES%."), list("rests", "A %LIP% kiss rests on one of %NIPPLES%."))
			return list(list("dot", "%LIP% kisses dot %NIPPLES%."), list("mark", "%LIP% kisses mark %NIPPLES%."))
		if(LIPSTICK_SPOT_ANUS)
			switch(kind)
				if(LIPSTICK_KIND_SMEAR)
					return list(list("smeared", "%LIPN% is smeared around %RIM%."), list("smudged", "%PUCKER% is smudged with %LIPN%."))
				if(LIPSTICK_KIND_RING, LIPSTICK_KIND_DEEP)
					return list(list("rings", "%LIPN% rings %RIM%."), list("marks", "A ring of %LIPN% marks %RIM%."))
				if(LIPSTICK_KIND_BITE)
					return list(list("bears", "%RIM% bears a %LIP%-ringed bite."))
			if(count == 1)
				return list(list("marks", "A %LIP% kiss marks %PUCKER%."), list("rests", "A %LIP% kiss rests on %PUCKER%."))
			return list(list("dot", "%LIP% kisses dot %PUCKER%."), list("ring", "%LIP% kisses ring %RIM%."))
		if(LIPSTICK_SPOT_BUTT)
			switch(kind)
				if(LIPSTICK_KIND_SMEAR)
					return list(list("smeared", "%ASS% is smeared with %LIPN%."), list("smudged", "%ASS% is smudged with %LIPN%."))
				if(LIPSTICK_KIND_RING, LIPSTICK_KIND_DEEP)
					return list(list("marks", "A ring of %LIPN% marks %ASS%."))
				if(LIPSTICK_KIND_BITE)
					if(count > 1)
						return list(list("bears", "%ASS% bears %LIP%-ringed bites."))
					return list(list("marks", "A %LIP%-ringed bite marks one cheek of %ASS%."), list("bears", "%ASS% bears a %LIP%-ringed bite."))
			switch(count)
				if(1)
					return list(list("marks", "A %LIP% kiss marks one cheek of %ASS%."), list("rests", "A %LIP% kiss rests on %ASS%."))
				if(2)
					return list(list("dot", "Two %LIP% kisses dot %ASS%."), list("marks", "A pair of %LIP% kisses marks %ASS%."))
			return list(list("scattered", "%LIP% kisses are scattered across %ASS%."), list("dot", "%LIP% kisses dot %ASS%."))
	return list(list("marks", "A %LIP% mark shows on %THEIR% skin."))
