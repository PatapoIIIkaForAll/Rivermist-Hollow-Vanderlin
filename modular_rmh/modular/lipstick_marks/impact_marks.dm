// Fading, unwashable examine marks from spanks, straps and whips; they reuse the lipstick spots and visibility rule.

/mob/living/carbon/human
	/// Impact marks on this body: lipstick spot -> list(level, by tool, time), one entry per spot.
	var/list/impact_marks

/datum/quirk/negative/addiction
	/// world.time from which making or taking a mark may sate this vice again.
	var/next_mark_sate = 0
	/// world.time from which examining marks may sate this vice again.
	var/next_mark_examine_sate = 0

/// Mark level of one strike from its force level, the striker's Strength and the tool tier.
/proc/get_impact_mark_level(force, strength, tool_tier)
	var/score = force + tool_tier + (strength - IMPACT_MARK_STRENGTH_BASE) / IMPACT_MARK_STRENGTH_STEP
	if(score >= IMPACT_MARK_SCORE_BRUISED)
		return IMPACT_MARK_BRUISED
	if(score >= IMPACT_MARK_SCORE_RED)
		return IMPACT_MARK_RED
	if(score >= IMPACT_MARK_SCORE_FAINT)
		return IMPACT_MARK_FAINT
	return IMPACT_MARK_NONE

/// Tool tier: bare hand, an impact toy's own tier, whip or cane, else a strap.
/proc/get_impact_tool_tier(obj/item/tool)
	if(!tool)
		return IMPACT_TOOL_HAND
	if(istype(tool, /obj/item/weapon/whip))
		return IMPACT_TOOL_WHIP
	if(istype(tool, /obj/item/impact_toy))
		var/obj/item/impact_toy/toy = tool
		return toy.impact_mark_tier
	return IMPACT_TOOL_STRAP

/// Strength for mark size; a striker without stats counts as average.
/proc/get_impact_strength(mob/living/striker)
	if(!striker)
		return IMPACT_MARK_STRENGTH_BASE
	var/strength = GET_MOB_ATTRIBUTE_VALUE(striker, STAT_STRENGTH)
	return isnum(strength) ? strength : IMPACT_MARK_STRENGTH_BASE

/// The spot a strike on a targeting-doll zone lands on; a strike to the groin lands on the butt.
/proc/get_impact_mark_spot(zone)
	if(zone == BODY_ZONE_PRECISE_GROIN)
		return LIPSTICK_SPOT_BUTT
	var/list/spots = get_lipstick_spots_for_zone(zone)
	return length(spots) ? spots[1] : null

/proc/get_impact_mark_fade_time(level)
	switch(level)
		if(IMPACT_MARK_BRUISED)
			return IMPACT_MARK_FADE_BRUISED
		if(IMPACT_MARK_RED)
			return IMPACT_MARK_FADE_RED
	return IMPACT_MARK_FADE_FAINT

/proc/get_impact_mark_sate_cooldown(level)
	switch(level)
		if(IMPACT_MARK_BRUISED)
			return IMPACT_MARK_SATE_COOLDOWN_BRUISED
		if(IMPACT_MARK_RED)
			return IMPACT_MARK_SATE_COOLDOWN_RED
	return IMPACT_MARK_SATE_COOLDOWN_FAINT

/// Plain words for a mark, such as "red welts".
/proc/get_impact_mark_words(level, by_tool)
	switch(level)
		if(IMPACT_MARK_BRUISED)
			return by_tool ? "dark bruised welts" : "dark bruised handprints"
		if(IMPACT_MARK_RED)
			return by_tool ? "red welts" : "red handprints"
	return by_tool ? "faint red marks" : "faint red handprints"

/// A strike by striker on zone leaves a mark; returns the mark level, or IMPACT_MARK_NONE when it leaves none.
/mob/living/carbon/human/proc/take_impact_mark(mob/living/striker, zone, force, obj/item/tool)
	var/spot = get_impact_mark_spot(zone)
	if(!spot || !has_lipstick_spot(spot))
		return IMPACT_MARK_NONE
	var/level = get_impact_mark_level(force, get_impact_strength(striker), get_impact_tool_tier(tool))
	if(level <= IMPACT_MARK_NONE)
		return IMPACT_MARK_NONE
	add_impact_mark(spot, level, !!tool)
	sate_from_impact_mark(striker, level)
	return level

/// Records a mark; a spot keeps one entry at the heavier level, and any new strike restarts its fade.
/mob/living/carbon/human/proc/add_impact_mark(spot, level, by_tool)
	level = clamp(level, IMPACT_MARK_FAINT, IMPACT_MARK_MAX)
	LAZYINITLIST(impact_marks)
	var/list/mark = impact_marks[spot]
	if(!mark)
		impact_marks[spot] = list(level, by_tool, world.time)
	else
		if(level >= mark[IMPACT_MARK_LEVEL])
			mark[IMPACT_MARK_LEVEL] = level
			mark[IMPACT_MARK_BY_TOOL] = by_tool
		mark[IMPACT_MARK_TIME] = world.time
	schedule_impact_mark_fade()

/// Arms one timer for the next mark due to fade.
/mob/living/carbon/human/proc/schedule_impact_mark_fade()
	if(!length(impact_marks))
		return
	var/next_step
	for(var/spot in impact_marks)
		var/list/mark = impact_marks[spot]
		var/step_at = mark[IMPACT_MARK_TIME] + get_impact_mark_fade_time(mark[IMPACT_MARK_LEVEL])
		if(isnull(next_step) || step_at < next_step)
			next_step = step_at
	addtimer(CALLBACK(src, PROC_REF(process_impact_mark_fade)), max(next_step - world.time, 1), TIMER_UNIQUE | TIMER_OVERRIDE)

/// Steps every due mark down one level and drops the ones that are gone.
/mob/living/carbon/human/proc/process_impact_mark_fade()
	if(QDELETED(src) || !length(impact_marks))
		return
	for(var/spot in impact_marks.Copy())
		var/list/mark = impact_marks[spot]
		if(world.time < mark[IMPACT_MARK_TIME] + get_impact_mark_fade_time(mark[IMPACT_MARK_LEVEL]))
			continue
		mark[IMPACT_MARK_LEVEL]--
		mark[IMPACT_MARK_TIME] = world.time
		if(mark[IMPACT_MARK_LEVEL] <= IMPACT_MARK_NONE)
			impact_marks -= spot
	UNSETEMPTY(impact_marks)
	schedule_impact_mark_fade()

/// Marked spots the watcher can see: bare skin only, by the lipstick visibility rule; observers see all.
/mob/living/carbon/human/proc/get_visible_impact_mark_spots(mob/user)
	. = list()
	if(!length(impact_marks))
		return
	var/see_all = isobserver(user)
	for(var/spot in GLOB.lipstick_mark_spots)
		if(!impact_marks[spot] || !has_lipstick_spot(spot))
			continue
		if(see_all || is_lipstick_spot_visible(spot))
			. += spot

/// One examine line for the visible impact marks; seeing them may sate a masochist or a sadist.
/mob/living/carbon/human/proc/get_impact_mark_line(mob/user, list/P)
	var/list/spots = get_visible_impact_mark_spots(user)
	if(!length(spots))
		return null
	var/list/groups = list()
	for(var/spot in spots)
		var/list/mark = impact_marks[spot]
		var/words = get_impact_mark_words(mark[IMPACT_MARK_LEVEL], mark[IMPACT_MARK_BY_TOOL])
		LAZYADD(groups[words], GLOB.lipstick_mark_spots[spot]["name"])
	var/list/phrases = list()
	for(var/words in groups)
		phrases += "[words] on [P[THEIR]] [english_list(groups[words])]"
	sate_from_seen_impact_marks(user)
	return "[capitalize(P[THEYVE])] [english_list(phrases)]."

/// Sates a vice from marks once its cooldown is over; TRUE when it sated.
/mob/living/proc/try_impact_mark_sate(vice_type, cooldown, from_examine = FALSE)
	var/datum/quirk/negative/addiction/vice = get_quirk(vice_type)
	if(!istype(vice))
		return FALSE
	if(world.time < (from_examine ? vice.next_mark_examine_sate : vice.next_mark_sate))
		return FALSE
	if(from_examine)
		vice.next_mark_examine_sate = world.time + cooldown
	else
		vice.next_mark_sate = world.time + cooldown
	sate_addiction(vice_type)
	return TRUE

/// A masochist sates on taking a mark; a sadist sates on leaving one on someone else.
/mob/living/carbon/human/proc/sate_from_impact_mark(mob/living/striker, level)
	var/cooldown = get_impact_mark_sate_cooldown(level)
	try_impact_mark_sate(/datum/quirk/negative/addiction/masochist, cooldown)
	if(striker && striker != src)
		striker.try_impact_mark_sate(/datum/quirk/negative/addiction/sadist, cooldown)

/// A masochist sates on seeing their own marks; a sadist sates on seeing marks on someone else.
/mob/living/carbon/human/proc/sate_from_seen_impact_marks(mob/user)
	if(user == src)
		try_impact_mark_sate(/datum/quirk/negative/addiction/masochist, IMPACT_MARK_EXAMINE_SATE_COOLDOWN, TRUE)
		return
	if(!isliving(user))
		return
	var/mob/living/watcher = user
	watcher.try_impact_mark_sate(/datum/quirk/negative/addiction/sadist, IMPACT_MARK_EXAMINE_SATE_COOLDOWN, TRUE)
