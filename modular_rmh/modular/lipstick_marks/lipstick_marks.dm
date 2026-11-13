// Washable lipstick marks that kisses and mouth acts leave on a partner; they fade over an hour.

/// Spots in head-to-feet order: holding limb, clothing zone, art kind, optional organ and descriptor ties.
GLOBAL_LIST_INIT(lipstick_mark_spots, list(
	LIPSTICK_SPOT_LIPS = list("name" = "lips", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_PRECISE_MOUTH, "face" = TRUE, "art" = LIPSTICK_ART_FACE),
	LIPSTICK_SPOT_CHEEK = list("name" = "cheek", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_HEAD, "face" = TRUE, "art" = LIPSTICK_ART_FACE),
	LIPSTICK_SPOT_FOREHEAD = list("name" = "forehead", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_HEAD, "face" = TRUE, "art" = LIPSTICK_ART_FACE),
	LIPSTICK_SPOT_NOSE = list("name" = "nose", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_PRECISE_NOSE, "face" = TRUE, "art" = LIPSTICK_ART_FACE),
	LIPSTICK_SPOT_EAR = list("name" = "ear", "limb" = BODY_ZONE_HEAD, "cover" = BODY_ZONE_PRECISE_EARS, "face" = TRUE, "art" = LIPSTICK_ART_TOP),
	LIPSTICK_SPOT_NECK = list("name" = "neck", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_NECK, "art" = LIPSTICK_ART_TOP),
	LIPSTICK_SPOT_CHEST = list("name" = "chest", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_CHEST, "art" = LIPSTICK_ART_TOP),
	LIPSTICK_SPOT_NIPPLES = list("name" = "nipples", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_CHEST, "art" = LIPSTICK_ART_LOW,
		"art_organ" = ORGAN_SLOT_BREASTS, "organ_art" = "nipples", "hide" = HIDEBOOB|HIDEJUMPSUIT, "descriptors" = list(/datum/mob_descriptor/breasts)),
	LIPSTICK_SPOT_ARMPIT = list("name" = "armpit", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_CHEST, "art" = LIPSTICK_ART_LOW),
	LIPSTICK_SPOT_BELLY = list("name" = "belly", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_STOMACH, "art" = LIPSTICK_ART_TOP),
	LIPSTICK_SPOT_CROTCH = list("name" = "crotch", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "art" = LIPSTICK_ART_LOW),
	LIPSTICK_SPOT_COCK = list("name" = "cock", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "organ" = ORGAN_SLOT_PENIS,
		"art_organ" = ORGAN_SLOT_PENIS, "organ_art" = "penis", "hide" = HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH, "descriptors" = list(/datum/mob_descriptor/penis)),
	LIPSTICK_SPOT_BALLS = list("name" = "balls", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "organ" = ORGAN_SLOT_TESTICLES,
		"art_organ" = ORGAN_SLOT_TESTICLES, "organ_art" = "balls", "hide" = HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH, "descriptors" = list(/datum/mob_descriptor/testicles)),
	LIPSTICK_SPOT_VULVA = list("name" = "pussy", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "organ" = ORGAN_SLOT_VAGINA,
		"art_organ" = ORGAN_SLOT_VAGINA, "organ_art" = "vulva", "hide" = HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH, "descriptors" = list(/datum/mob_descriptor/vagina)),
	LIPSTICK_SPOT_BUTT = list("name" = "butt", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "art" = LIPSTICK_ART_TOP,
		"descriptors" = list(/datum/mob_descriptor/butt)),
	LIPSTICK_SPOT_ANUS = list("name" = "rim", "limb" = BODY_ZONE_CHEST, "cover" = BODY_ZONE_PRECISE_GROIN, "organ" = ORGAN_SLOT_ANUS, "art" = LIPSTICK_ART_LOW,
		"art_organ" = ORGAN_SLOT_BUTT, "organ_art" = "anus", "hide" = HIDEBUTT|HIDEUNDIESBOT, "descriptors" = list(/datum/mob_descriptor/butt, /datum/mob_descriptor/vagina)),
	LIPSTICK_SPOT_L_ARM = list("name" = "left arm", "limb" = BODY_ZONE_L_ARM, "cover" = BODY_ZONE_L_ARM, "art" = LIPSTICK_ART_LOW, "aux_layer" = HANDS_PART_LAYER,
		"pair" = LIPSTICK_SPOT_R_ARM, "pair_name" = "arms"),
	LIPSTICK_SPOT_R_ARM = list("name" = "right arm", "limb" = BODY_ZONE_R_ARM, "cover" = BODY_ZONE_R_ARM, "art" = LIPSTICK_ART_LOW, "aux_layer" = HANDS_PART_LAYER),
	LIPSTICK_SPOT_L_HAND = list("name" = "left hand", "limb" = BODY_ZONE_L_ARM, "cover" = BODY_ZONE_PRECISE_L_HAND, "art" = LIPSTICK_ART_LOW, "aux_layer" = HANDS_PART_LAYER,
		"pair" = LIPSTICK_SPOT_R_HAND, "pair_name" = "hands"),
	LIPSTICK_SPOT_R_HAND = list("name" = "right hand", "limb" = BODY_ZONE_R_ARM, "cover" = BODY_ZONE_PRECISE_R_HAND, "art" = LIPSTICK_ART_LOW, "aux_layer" = HANDS_PART_LAYER),
	LIPSTICK_SPOT_L_THIGH = list("name" = "left thigh", "limb" = BODY_ZONE_L_LEG, "cover" = BODY_ZONE_L_LEG, "art" = LIPSTICK_ART_LOW, "aux_layer" = LEG_PART_LAYER,
		"pair" = LIPSTICK_SPOT_R_THIGH, "pair_name" = "thighs"),
	LIPSTICK_SPOT_R_THIGH = list("name" = "right thigh", "limb" = BODY_ZONE_R_LEG, "cover" = BODY_ZONE_R_LEG, "art" = LIPSTICK_ART_LOW, "aux_layer" = LEG_PART_LAYER),
	LIPSTICK_SPOT_L_FOOT = list("name" = "left foot", "limb" = BODY_ZONE_L_LEG, "cover" = BODY_ZONE_PRECISE_L_FOOT, "art" = LIPSTICK_ART_LOW, "aux_layer" = LEG_PART_LAYER,
		"pair" = LIPSTICK_SPOT_R_FOOT, "pair_name" = "feet"),
	LIPSTICK_SPOT_R_FOOT = list("name" = "right foot", "limb" = BODY_ZONE_R_LEG, "cover" = BODY_ZONE_PRECISE_R_FOOT, "art" = LIPSTICK_ART_LOW, "aux_layer" = LEG_PART_LAYER),
))

/// Lipstick spots a targeting-doll zone covers, the main one first.
/proc/get_lipstick_spots_for_zone(zone)
	var/static/list/zone_spots = list(
		BODY_ZONE_PRECISE_MOUTH = list(LIPSTICK_SPOT_LIPS),
		BODY_ZONE_HEAD = list(LIPSTICK_SPOT_CHEEK),
		BODY_ZONE_PRECISE_SKULL = list(LIPSTICK_SPOT_FOREHEAD),
		BODY_ZONE_PRECISE_R_EYE = list(LIPSTICK_SPOT_FOREHEAD),
		BODY_ZONE_PRECISE_L_EYE = list(LIPSTICK_SPOT_FOREHEAD),
		BODY_ZONE_PRECISE_NOSE = list(LIPSTICK_SPOT_NOSE),
		BODY_ZONE_PRECISE_EARS = list(LIPSTICK_SPOT_EAR),
		BODY_ZONE_PRECISE_NECK = list(LIPSTICK_SPOT_NECK),
		BODY_ZONE_CHEST = list(LIPSTICK_SPOT_CHEST, LIPSTICK_SPOT_NIPPLES, LIPSTICK_SPOT_ARMPIT),
		BODY_ZONE_PRECISE_STOMACH = list(LIPSTICK_SPOT_BELLY),
		BODY_ZONE_PRECISE_GROIN = list(LIPSTICK_SPOT_CROTCH, LIPSTICK_SPOT_COCK, LIPSTICK_SPOT_BALLS, LIPSTICK_SPOT_VULVA, LIPSTICK_SPOT_BUTT, LIPSTICK_SPOT_ANUS),
		BODY_ZONE_L_ARM = list(LIPSTICK_SPOT_L_ARM),
		BODY_ZONE_R_ARM = list(LIPSTICK_SPOT_R_ARM),
		BODY_ZONE_PRECISE_L_HAND = list(LIPSTICK_SPOT_L_HAND),
		BODY_ZONE_PRECISE_R_HAND = list(LIPSTICK_SPOT_R_HAND),
		BODY_ZONE_L_LEG = list(LIPSTICK_SPOT_L_THIGH),
		BODY_ZONE_R_LEG = list(LIPSTICK_SPOT_R_THIGH),
		BODY_ZONE_PRECISE_L_FOOT = list(LIPSTICK_SPOT_L_FOOT),
		BODY_ZONE_PRECISE_R_FOOT = list(LIPSTICK_SPOT_R_FOOT),
	)
	return zone_spots[zone]

/// The shade name of a lipstick colour, or null for a colour without one.
/proc/get_lipstick_shade(mark_color)
	return GLOB.lipstick_shades[LOWER_TEXT(mark_color)]

/// The notice phrase for a fresh mark, such as "a red lipstick kiss on her cheek".
/proc/describe_lipstick_mark(list/mark, their, spot_name)
	var/shade = get_lipstick_shade(mark[LIPSTICK_MARK_COLOR])
	var/lipstick = shade ? "[shade] lipstick" : "lipstick"
	switch(mark[LIPSTICK_MARK_KIND])
		if(LIPSTICK_KIND_SMEAR)
			return "[lipstick] smeared over [their] [spot_name]"
		if(LIPSTICK_KIND_RING)
			return "a [lipstick] ring around [their] [spot_name]"
		if(LIPSTICK_KIND_DEEP)
			return "a [lipstick] ring at the root of [their] [spot_name]"
		if(LIPSTICK_KIND_BITE)
			return "a [lipstick]-ringed bite on [their] [spot_name]"
	switch(mark[LIPSTICK_MARK_COUNT])
		if(1)
			return "a [lipstick] kiss on [their] [spot_name]"
		if(2)
			return "two [lipstick] kisses on [their] [spot_name]"
	return "several [lipstick] kisses on [their] [spot_name]"

/mob/living/carbon/human
	/// Lipstick left on this body: spot -> list(colour, alpha, count, kind, time), one entry per spot.
	var/list/lipstick_marks

/// Leaves this mob's lipstick on a partner's spot; TRUE when a mark lands.
/mob/living/proc/leave_lipstick_mark(mob/living/receiver, spot, kind = LIPSTICK_KIND_KISS)
	return FALSE

/mob/living/carbon/human/leave_lipstick_mark(mob/living/receiver, spot, kind = LIPSTICK_KIND_KISS)
	if(!ishuman(receiver) || !can_leave_lipstick())
		return FALSE
	var/mob/living/carbon/human/marked = receiver
	if(!marked.can_take_lipstick_mark(spot, src))
		return FALSE
	return marked.add_lipstick_mark(spot, lip_color, lip_alpha, kind, src)

/// A kiss on a targeting-doll zone; lips meeting lips mark both mouths.
/mob/living/proc/leave_lipstick_kiss(mob/living/receiver, zone)
	var/list/spots = get_lipstick_spots_for_zone(zone)
	if(!length(spots))
		return FALSE
	. = leave_lipstick_mark(receiver, spots[1], LIPSTICK_KIND_KISS)
	if(spots[1] == LIPSTICK_SPOT_LIPS && receiver.leave_lipstick_mark(src, LIPSTICK_SPOT_LIPS, LIPSTICK_KIND_KISS))
		. = TRUE

/// A bite on a targeting-doll zone.
/mob/living/proc/leave_lipstick_bite(mob/living/receiver, zone)
	var/list/spots = get_lipstick_spots_for_zone(zone)
	if(!length(spots))
		return FALSE
	return leave_lipstick_mark(receiver, spots[1], LIPSTICK_KIND_BITE)

/// Lipstick only rubs off a bare mouth; masks, muzzles and anything held in the teeth but a bite keep it.
/mob/living/carbon/human/proc/can_leave_lipstick()
	if(!lip_style)
		return FALSE
	if(is_mouth_covered() || is_muzzled())
		return FALSE
	if(mouth && !istype(mouth, /obj/item/grabbing/bite))
		return FALSE
	return TRUE

/// The real organ in a slot, or null for a missing or worn false one.
/mob/living/carbon/human/proc/get_lipstick_organ(slot)
	if(!slot)
		return null
	var/obj/item/organ/organ = getorganslot(slot)
	if(!organ || organ.is_false_organ())
		return null
	return organ

/// Whether the body still has the limb and organ a spot lives on.
/mob/living/carbon/human/proc/has_lipstick_spot(spot)
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	if(!spot_data)
		return FALSE
	var/obj/item/bodypart/limb = get_bodypart(spot_data["limb"])
	if(!limb || limb.skeletonized)
		return FALSE
	if(spot_data["organ"] && !get_lipstick_organ(spot_data["organ"]))
		return FALSE
	return TRUE

/// How a spot is drawn on this body: nipples move onto the breasts sprite when there are breasts.
/mob/living/carbon/human/proc/get_lipstick_art(spot)
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	if(!spot_data)
		return null
	var/obj/item/organ/genitals/art_organ = get_lipstick_organ(spot_data["art_organ"])
	if(!spot_data["organ_art"] || !art_organ)
		return spot_data["art"]
	// A flat butt draws no sprite, so the anus mark goes on the body instead.
	if(istype(art_organ, /obj/item/organ/genitals/butt) && art_organ.organ_size <= 0)
		return spot_data["art"]
	return LIPSTICK_ART_ORGAN

/// Lips reach a spot through what the sex panel lets through; heavy armour and worn devices stop them.
/mob/living/carbon/human/proc/can_take_lipstick_mark(spot, mob/living/actor)
	if(!has_lipstick_spot(spot))
		return FALSE
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	if(get_sex_covering_garment(spot_data["cover"], actor))
		return FALSE
	var/organ_slot = spot_data["organ"]
	if(organ_slot && is_organ_slot_blocked(organ_slot))
		return FALSE
	if(spot == LIPSTICK_SPOT_LIPS && is_mouth_covered())
		return FALSE
	return TRUE

/// Bare skin at a spot: organ spots use the genital descriptor rule, the rest the tattoo clothing check.
/mob/living/carbon/human/proc/is_lipstick_spot_visible(spot)
	if(!has_lipstick_spot(spot))
		return FALSE
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	var/organ_slot = spot_data["organ"]
	if(organ_slot && is_organ_slot_blocked(organ_slot))
		return FALSE
	if(spot == LIPSTICK_SPOT_LIPS && is_mouth_covered())
		return FALSE
	var/obj/item/organ/genitals/shown_organ = get_lipstick_organ(spot_data["art_organ"])
	if(shown_organ && spot_data["hide"])
		return is_lipstick_organ_exposed(shown_organ, spot_data["hide"])
	return get_location_accessible(src, spot_data["cover"], grabs = FALSE, skipundies = FALSE)

/// The genital descriptors' exposure rule, with breasts also hidden by a bra unless shown above clothes.
/mob/living/carbon/human/proc/is_lipstick_organ_exposed(obj/item/organ/genitals/organ, hide_flags)
	if(istype(organ, /obj/item/organ/genitals/filling_organ/breasts) && organ.visible_through_clothes != DRAW_ABOVE && underwear?.covers_breasts)
		return FALSE
	// Balls tucked away with a slit cock are neither drawn nor described.
	if(istype(organ, /obj/item/organ/genitals/filling_organ/testicles))
		var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
		if(penis?.sheath_type == SHEATH_TYPE_SLIT)
			return FALSE
	return is_genital_exposed(organ, hide_flags)

/// The fade step a mark has reached, from 0 (fresh) to LIPSTICK_FADE_STEPS (gone).
/proc/get_lipstick_fade_level(list/mark)
	return clamp(round((world.time - mark[LIPSTICK_MARK_TIME]) / LIPSTICK_FADE_STEP_TIME), 0, LIPSTICK_FADE_STEPS)

/// The alpha a mark shows at now, after fading.
/proc/get_lipstick_shown_alpha(list/mark)
	var/steps_left = LIPSTICK_FADE_STEPS - get_lipstick_fade_level(mark)
	return round(mark[LIPSTICK_MARK_ALPHA] * steps_left / LIPSTICK_FADE_STEPS)

/// Records a mark; the spot keeps the newest colour, alpha and kind, a capped count and a fresh fade clock.
/mob/living/carbon/human/proc/add_lipstick_mark(spot, mark_color, mark_alpha, kind, mob/living/giver)
	var/list/spot_data = GLOB.lipstick_mark_spots[spot]
	if(!spot_data || !mark_color)
		return FALSE
	LAZYINITLIST(lipstick_marks)
	var/list/mark = lipstick_marks[spot]
	var/announce = FALSE
	var/old_look
	if(!mark)
		mark = list(mark_color, mark_alpha, 0, kind, world.time)
		lipstick_marks[spot] = mark
		announce = TRUE
	else
		old_look = get_lipstick_mark_look(mark)
		if(mark[LIPSTICK_MARK_COLOR] != mark_color || mark[LIPSTICK_MARK_ALPHA] != mark_alpha || mark[LIPSTICK_MARK_KIND] != kind)
			announce = TRUE
		// The count tallies marks of one kind; rings after kisses start again from one.
		if(mark[LIPSTICK_MARK_KIND] != kind)
			mark[LIPSTICK_MARK_COUNT] = 0
		mark[LIPSTICK_MARK_COLOR] = mark_color
		mark[LIPSTICK_MARK_ALPHA] = mark_alpha
		mark[LIPSTICK_MARK_KIND] = kind
		mark[LIPSTICK_MARK_TIME] = world.time
	mark[LIPSTICK_MARK_COUNT] = min(mark[LIPSTICK_MARK_COUNT] + 1, LIPSTICK_MARK_MAX_COUNT)
	if(get_lipstick_mark_look(mark) != old_look)
		update_lipstick_mark_art(spot)
	schedule_lipstick_fade()
	if(!announce)
		return TRUE
	if(giver && giver != src)
		to_chat(giver, span_notice("I leave [describe_lipstick_mark(mark, "[src]'s", spot_data["name"])]."))
		to_chat(src, span_notice("[giver] leaves [describe_lipstick_mark(mark, "my", spot_data["name"])]."))
	else if(giver)
		to_chat(src, span_notice("I leave [describe_lipstick_mark(mark, "my", spot_data["name"])]."))
	return TRUE

/// Everything the drawn mark depends on, so unchanged art skips a redraw.
/proc/get_lipstick_mark_look(list/mark)
	return "[mark[LIPSTICK_MARK_KIND]][mark[LIPSTICK_MARK_COUNT]]-[mark[LIPSTICK_MARK_COLOR]]-[get_lipstick_shown_alpha(mark)]"

/// Redraws whatever shows a spot's mark: the organ in the cached limbs, or the body layer.
/mob/living/carbon/human/proc/update_lipstick_mark_art(spot)
	redraw_lipstick_marks(list(spot))

/mob/living/carbon/human/proc/clear_lipstick_mark(spot)
	if(!lipstick_marks?[spot])
		return FALSE
	lipstick_marks -= spot
	UNSETEMPTY(lipstick_marks)
	update_lipstick_mark_art(spot)
	return TRUE

/// Clears every mark on a targeting-doll zone.
/mob/living/carbon/human/proc/clear_lipstick_marks_on_zone(zone)
	. = FALSE
	for(var/spot in get_lipstick_spots_for_zone(zone))
		if(clear_lipstick_mark(spot))
			. = TRUE

/// Water and soap take marks off bare skin, and marks whose limb is gone.
/mob/living/carbon/human/proc/wash_lipstick_marks()
	if(!length(lipstick_marks))
		return FALSE
	. = FALSE
	var/list/washed = list()
	for(var/spot in lipstick_marks.Copy())
		if(has_lipstick_spot(spot) && !is_lipstick_spot_visible(spot))
			continue
		lipstick_marks -= spot
		washed += spot
	UNSETEMPTY(lipstick_marks)
	if(length(washed))
		redraw_lipstick_marks(washed)
		. = TRUE

/// Arms one timer for the next fade step of any mark; marks refreshed later push it back.
/mob/living/carbon/human/proc/schedule_lipstick_fade()
	if(!length(lipstick_marks))
		return
	var/next_step
	for(var/spot in lipstick_marks)
		var/list/mark = lipstick_marks[spot]
		var/step_at = mark[LIPSTICK_MARK_TIME] + (get_lipstick_fade_level(mark) + 1) * LIPSTICK_FADE_STEP_TIME
		if(isnull(next_step) || step_at < next_step)
			next_step = step_at
	addtimer(CALLBACK(src, PROC_REF(process_lipstick_fade)), max(next_step - world.time, 1), TIMER_UNIQUE | TIMER_OVERRIDE)

/// Lowers faded marks a step and drops the ones that are gone.
/mob/living/carbon/human/proc/process_lipstick_fade()
	if(QDELETED(src) || !length(lipstick_marks))
		return
	var/list/spots = list()
	for(var/spot in lipstick_marks.Copy())
		spots += spot
		if(get_lipstick_fade_level(lipstick_marks[spot]) >= LIPSTICK_FADE_STEPS)
			lipstick_marks -= spot
	UNSETEMPTY(lipstick_marks)
	redraw_lipstick_marks(spots)
	schedule_lipstick_fade()

/// One redraw for several spots: the body layer, the cached limbs and the breasts child as needed.
/mob/living/carbon/human/proc/redraw_lipstick_marks(list/spots)
	var/redraw_body = FALSE
	var/redraw_organs = FALSE
	for(var/spot in spots)
		if(get_lipstick_art(spot) == LIPSTICK_ART_ORGAN)
			redraw_organs = TRUE
		else
			redraw_body = TRUE
	if(redraw_body)
		update_body()
	if(!redraw_organs)
		return
	update_body_parts()
	if(LIPSTICK_SPOT_NIPPLES in spots)
		var/datum/component/breast_animation/animation = GetComponent(/datum/component/breast_animation)
		animation?.update_lipstick_child()

/// Wipes the marks on the wiper's targeted zone off this body; NONE when there is nothing to wipe.
/mob/living/carbon/human/proc/try_wipe_lipstick_mark(obj/item/wiper, mob/living/user)
	var/list/wiped_spots = list()
	for(var/spot in get_lipstick_spots_for_zone(user.zone_selected))
		if(lipstick_marks?[spot] && is_lipstick_spot_visible(spot))
			wiped_spots += spot
	if(!length(wiped_spots))
		return NONE
	var/spot_name = GLOB.lipstick_mark_spots[wiped_spots[1]]["name"]
	if(user == src)
		to_chat(user, span_notice("I wipe the lipstick off my [spot_name] with [wiper]."))
	else
		user.visible_message(span_warning("[user] begins to wipe the lipstick off [src]'s [spot_name] with [wiper]."), \
			span_notice("I begin to wipe the lipstick off [src]'s [spot_name]..."))
		if(!do_after(user, 1 SECONDS, src))
			return ITEM_INTERACT_BLOCKING
		user.visible_message(span_notice("[user] wipes the lipstick off [src]'s [spot_name]."), \
			span_notice("I wipe the lipstick off [src]'s [spot_name]."))
	for(var/spot in wiped_spots)
		clear_lipstick_mark(spot)
	return ITEM_INTERACT_SUCCESS
