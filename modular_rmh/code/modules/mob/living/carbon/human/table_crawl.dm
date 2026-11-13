#define TABLE_CRAWL_MIN_DELAY (2 SECONDS)
#define TABLE_CRAWL_BONK_STUN (5 SECONDS)
#define TABLE_CRAWL_BONK_COOLDOWN (1 SECONDS)
#define TABLE_CRAWL_BONK_VOLUME 50
#define TABLE_CRAWL_LAYER_OFFSET 0.1

/// Resting, lying and small enough to lie under a table.
/mob/living/carbon/human/proc/fits_under_table()
	return resting && body_position == LYING_DOWN && !buckled && mob_size < MOB_SIZE_LARGE

/mob/living/carbon/human/stand_up()
	if(!stat && try_table_crawl_bonk())
		return FALSE
	return ..()

/mob/living/carbon/human/set_resting(new_resting, silent = TRUE, instant = FALSE)
	if(!new_resting && resting && HAS_TRAIT(src, TRAIT_UNDER_TABLE))
		if(!silent)
			try_table_crawl_bonk()
		return
	return ..()

/// Bumps our head when we try to stand under a table. TRUE if we are under one.
/mob/living/carbon/human/proc/try_table_crawl_bonk()
	var/datum/component/table_crawl/crawl = GetComponent(/datum/component/table_crawl)
	if(!crawl)
		return FALSE
	crawl.bonk()
	return TRUE

/obj/structure/table/Bumped(atom/movable/bumper)
	. = ..()
	if(ishuman(bumper) && can_crawl_under(bumper))
		INVOKE_ASYNC(src, PROC_REF(try_crawl_under), bumper)

/obj/structure/table/Destroy()
	var/turf/table_turf = get_turf(src)
	. = ..()
	for(var/mob/living/carbon/human/crawler in table_turf)
		var/datum/component/table_crawl/crawl = crawler.GetComponent(/datum/component/table_crawl)
		crawl?.check_cover()

/obj/structure/table/get_mechanics_examine(mob/user)
	. = ..()
	. += "With sneak on, click it to hide under it."
	. += "Lie down and move into it to crawl under it. Large creatures do not fit."
	. += "Under it, the Hide action tucks you out of sight. Moving while hidden slips you under the next table."

/obj/structure/table/proc/can_crawl_under(mob/living/carbon/human/crawler)
	if(QDELETED(src) || QDELETED(crawler) || !crawler.client || crawler.pulledby)
		return FALSE
	if(!crawler.fits_under_table() || HAS_TRAIT(crawler, TRAIT_UNDER_TABLE))
		return FALSE
	var/turf/crawler_turf = crawler.loc
	if(!isturf(crawler_turf) || !isturf(loc) || (locate(/obj/structure/table) in crawler_turf))
		return FALSE
	return (get_dir(crawler_turf, loc) in GLOB.cardinals) && Adjacent(crawler)

/obj/structure/table/proc/get_crawl_delay(mob/living/carbon/human/crawler)
	var/crawl_delay = climb_time
	if(HAS_TRAIT(crawler, TRAIT_HANDS_BLOCKED))
		crawl_delay *= 2
	crawl_delay -= GET_MOB_ATTRIBUTE_VALUE(crawler, STAT_SPEED) * 2
	return max(crawl_delay, TABLE_CRAWL_MIN_DELAY)

/obj/structure/table/proc/try_crawl_under(mob/living/carbon/human/crawler)
	if(crawler.doing())
		return
	crawler.visible_message(span_warning("[crawler] starts to crawl under [src]."), span_warning("I start to crawl under [src]..."))
	if(!do_after(crawler, get_crawl_delay(crawler), src, timed_action_flags = IGNORE_USER_DIR_CHANGE, extra_checks = CALLBACK(src, PROC_REF(can_crawl_under), crawler), interaction_key = "table_crawl"))
		return
	finish_crawl_under(crawler)

/// Puts the crawler under us. FALSE if something on our tile blocks the way.
/obj/structure/table/proc/finish_crawl_under(mob/living/carbon/human/crawler)
	var/datum/component/table_crawl/crawl = crawler.AddComponent(/datum/component/table_crawl)
	if(crawler.Move(loc, get_dir(crawler, src)))
		return TRUE
	qdel(crawl)
	to_chat(crawler, span_warning("I can't fit under [src]."))
	return FALSE

/// A hidden crawler slips into the next free table instead of coming out. TRUE if they moved.
/obj/structure/table/proc/crawl_hidden_to(mob/living/user, direction)
	if(!HAS_TRAIT(user, TRAIT_UNDER_TABLE) || !(direction in GLOB.cardinals))
		return FALSE
	var/turf/table_turf = get_turf(src)
	var/turf/next_turf = get_step(table_turf, direction)
	var/obj/structure/table/next_table = locate() in next_turf
	if(!next_table || next_table.occupied || next_turf.density || !table_turf.Adjacent(next_turf))
		return FALSE
	for(var/atom/movable/blocker as anything in next_turf)
		if(istype(blocker, /obj/structure/table))
			continue
		if(!blocker.CanPass(user, table_turf))
			return FALSE
	if(user.client)
		user.client.move_delay = world.time + user.cached_multiplicative_slowdown
	user.setDir(direction)
	next_table.take_hider(user)
	return TRUE

/// Exists while a human lies under a table; deleting it puts them back in the open.
/datum/component/table_crawl
	// Plain UNIQUE builds and deletes a throwaway copy, and its removal would strip our trait.
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/datum/action/innate/table_hide/hide_action
	COOLDOWN_DECLARE(bonk_cooldown)

/datum/component/table_crawl/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	hide_action = new(src)

/datum/component/table_crawl/Destroy(force)
	. = ..()
	QDEL_NULL(hide_action)

/datum/component/table_crawl/RegisterWithParent()
	var/mob/living/carbon/human/crawler = parent
	ADD_TRAIT(crawler, TRAIT_UNDER_TABLE, TABLE_CRAWL_TRAIT)
	RegisterSignal(crawler, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(crawler, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_body_position))
	RegisterSignal(crawler, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_buckled))
	crawler.reset_offsets("structure_climb")
	crawler.layer = TABLE_LAYER - TABLE_CRAWL_LAYER_OFFSET
	crawler.plane = GAME_PLANE_LOWER
	hide_action.Grant(crawler)

/datum/component/table_crawl/UnregisterFromParent()
	var/mob/living/carbon/human/crawler = parent
	if(!QDELETED(hide_action))
		hide_action.Remove(crawler)
	UnregisterSignal(crawler, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION, COMSIG_LIVING_SET_BUCKLED))
	REMOVE_TRAIT(crawler, TRAIT_UNDER_TABLE, TABLE_CRAWL_TRAIT)
	crawler.layer = crawler.body_position == LYING_DOWN ? LYING_MOB_LAYER : initial(crawler.layer)
	crawler.plane = initial(crawler.plane)
	// Whoever is left standing on a table tile is on top of it.
	var/obj/structure/table/table_top = locate() in crawler.loc
	if(table_top?.climb_offset)
		crawler.set_mob_offsets("structure_climb", _x = 0, _y = table_top.climb_offset)

/// Ends the crawl once no table covers our tile.
/datum/component/table_crawl/proc/check_cover()
	if(!(locate(/obj/structure/table) in get_turf(parent)))
		qdel(src)
		return FALSE
	return TRUE

/datum/component/table_crawl/proc/on_moved(mob/living/carbon/human/source, atom/old_loc, direction, forced)
	SIGNAL_HANDLER
	if(check_cover())
		hide_action.build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/component/table_crawl/proc/on_body_position(mob/living/carbon/human/source, new_position, old_position)
	SIGNAL_HANDLER
	if(new_position == STANDING_UP)
		qdel(src)

/datum/component/table_crawl/proc/on_buckled(mob/living/carbon/human/source, atom/movable/new_buckled)
	SIGNAL_HANDLER
	if(new_buckled)
		qdel(src)

/datum/component/table_crawl/proc/bonk()
	if(!COOLDOWN_FINISHED(src, bonk_cooldown))
		return
	COOLDOWN_START(src, bonk_cooldown, TABLE_CRAWL_BONK_COOLDOWN)
	var/mob/living/carbon/human/crawler = parent
	var/obj/structure/table/cover = locate() in get_turf(crawler)
	var/table_name = cover ? "[cover]" : "the table"
	crawler.visible_message(span_warning("[crawler] bumps [crawler.p_their()] head on [table_name]!"), span_warning("I bump my head on [table_name]!"))
	var/bonk_sound = cover?.attacked_sound
	if(islist(bonk_sound))
		bonk_sound = pick(bonk_sound)
	playsound(cover || crawler, bonk_sound || "woodimpact", TABLE_CRAWL_BONK_VOLUME, TRUE)
	crawler.Stun(TABLE_CRAWL_BONK_STUN)

/datum/action/innate/table_hide
	name = "Hide under table"
	desc = "Tuck myself out of sight under the table, or come back out. Moving while hidden slips me under the next table."
	button_icon_state = "invisibility"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/table_hide/IsAvailable()
	. = ..()
	if(!. || !HAS_TRAIT(owner, TRAIT_UNDER_TABLE))
		return FALSE
	return !!get_cover()

/datum/action/innate/table_hide/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return istype(owner?.loc, /obj/structure/table)

// hideinside() toggles from where we are, so the button state never decides the direction.
/datum/action/innate/table_hide/Activate()
	var/obj/structure/table/cover = get_cover()
	cover?.hideinside(owner)

/datum/action/innate/table_hide/proc/get_cover()
	return locate(/obj/structure/table) in get_turf(owner)

#undef TABLE_CRAWL_MIN_DELAY
#undef TABLE_CRAWL_BONK_STUN
#undef TABLE_CRAWL_BONK_COOLDOWN
#undef TABLE_CRAWL_BONK_VOLUME
#undef TABLE_CRAWL_LAYER_OFFSET
