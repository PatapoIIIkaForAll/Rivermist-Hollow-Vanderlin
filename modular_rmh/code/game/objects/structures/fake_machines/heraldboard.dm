// ==================== HERALD'S BOARD ====================
// Ported & adapted from Azure "/obj/structure/roguemachine/noticeboard"
// into Vanderlin's /obj/structure/fake_machine family, and named "Herald's Board".
//
// ---- Post lifetime ----
// Posts do NOT expire on a timer - rounds run for days of real time, so a
// 30-minute notice was useless. A post lives until its author's BODY leaves the
// map: cryo and return-to-lobby both qdel the mob (see cryo_mob() in
// code/game/objects/structures/train.dm and /mob/proc/returntolobby()), so a
// weakref going null/QDELETED is exactly the "character left" signal we want.
// A mere client disconnect leaves the SSD body in the world, so the post stays.
// Validation is lazy (checked when the board is read or changed),
// so it costs nothing while nobody is looking.
//
// ---- Hierarchy ----
// Removal rights and the star marks on posts come from the modular RMH town
// roles. A person may tear down posts at or BELOW their own rank, never above.
// The Town Mouth (a /datum/job/advclass/towner subrole) outranks everyone, can
// remove anything, is marked with a quill instead of stars, and always sees
// every post's true rank even on posts whose signature wasn't attested.
//
// ---- Server-cost note ----
// Still ZERO background processing: no process(), no SS hook, no per-tick work.
// ui_data() runs only on a TGUI push (open / after a change) and is
// O(live posts + threat regions) - both small by construction (posts are capped
// per author by the limits below, threat regions are a fixed handful, already
// ticked independently by RMH's own SSregionthreat on its own 15-minute timer;
// this file only reads that state, never advances it). Posting and removing are
// rate-limited server-side (HERALDBOARD_POST_COOLDOWN), so the all-boards
// broadcast cannot be spammed.

GLOBAL_LIST_EMPTY(heraldboard_posts)
/// assoc ckey -> world.time at which that person may act again
GLOBAL_LIST_EMPTY(heraldboard_cooldowns)
/// newest-first list of takedown records, capped at HERALDBOARD_PRUNE_LOG_MAX
GLOBAL_LIST_EMPTY(heraldboard_prune_log)

/datum/controller/subsystem/processing/roguemachine
	var/list/heraldboards = list()

#define HERALDBOARD_TITLE_MAX_LENGTH 50
#define HERALDBOARD_BODY_MAX_LENGTH 500
#define HERALDBOARD_NAME_MAX_LENGTH 50
#define HERALDBOARD_ROLE_MAX_LENGTH 50

/// Server-side rate limit. The client also disables the buttons, but that is
/// cosmetic - this is the check that actually holds.
#define HERALDBOARD_POST_COOLDOWN (5 SECONDS)
#define HERALDBOARD_REMOVE_COOLDOWN (2 SECONDS)

#define HERALDBOARD_PRUNE_LOG_MAX 60

/// Rank ladder. Higher outranks lower; a person removes posts at or below their
/// own rank only. HERALD sits above everything.
#define HERALDBOARD_RANK_NONE 0
#define HERALDBOARD_RANK_ONE 1
#define HERALDBOARD_RANK_TWO 2
#define HERALDBOARD_RANK_THREE 3
#define HERALDBOARD_RANK_HERALD 4

/// Per-rank posting limits, as specified. Unlisted folk get one post and no stars.
#define HERALDBOARD_LIMIT_HERALD 5
#define HERALDBOARD_LIMIT_UNLISTED 1

/proc/heraldboard_rank_of(mob/living/carbon/human/H)
	if(!istype(H))
		return HERALDBOARD_RANK_NONE
	var/datum/job/J = H.mind?.assigned_role
	if(!J)
		return HERALDBOARD_RANK_NONE
	// Town Mouth - the herald himself, outranks all.
	if(istype(J, /datum/job/advclass/towner/town_mouth))
		return HERALDBOARD_RANK_HERALD
	// Three stars.
	if(istype(J, /datum/job/burgmeister) || istype(J, /datum/job/advclass/burgmeister))
		return HERALDBOARD_RANK_THREE
	if(istype(J, /datum/job/councilor) || istype(J, /datum/job/advclass/councilor))
		return HERALDBOARD_RANK_THREE
	if(istype(J, /datum/job/heart_priest) || istype(J, /datum/job/moon_priest))
		return HERALDBOARD_RANK_THREE
	// Two stars.
	if(istype(J, /datum/job/watch_captain))
		return HERALDBOARD_RANK_TWO
	if(istype(J, /datum/job/watch_warden))
		return HERALDBOARD_RANK_TWO
	if(istype(J, /datum/job/adventurers_guildmaster) || istype(J, /datum/job/advclass/adventurers_guildmaster))
		return HERALDBOARD_RANK_TWO
	// One star.
	if(istype(J, /datum/job/innkeep))
		return HERALDBOARD_RANK_ONE
	if(istype(J, /datum/job/matron))
		return HERALDBOARD_RANK_ONE
	return HERALDBOARD_RANK_NONE

/proc/heraldboard_limit_of(mob/living/carbon/human/H)
	if(!istype(H))
		return 0
	var/datum/job/J = H.mind?.assigned_role
	if(!J)
		return HERALDBOARD_LIMIT_UNLISTED
	if(istype(J, /datum/job/advclass/towner/town_mouth))
		return HERALDBOARD_LIMIT_HERALD
	if(istype(J, /datum/job/burgmeister) || istype(J, /datum/job/advclass/burgmeister) \
		|| istype(J, /datum/job/councilor) || istype(J, /datum/job/advclass/councilor) \
		|| istype(J, /datum/job/adventurers_guildmaster) || istype(J, /datum/job/advclass/adventurers_guildmaster) \
		|| istype(J, /datum/job/innkeep))
		return 3
	if(istype(J, /datum/job/matron) || istype(J, /datum/job/watch_captain) \
		|| istype(J, /datum/job/watch_warden) \
		|| istype(J, /datum/job/heart_priest) || istype(J, /datum/job/moon_priest))
		return 2
	return HERALDBOARD_LIMIT_UNLISTED

/datum/heraldboard_posting
	var/posting_id
	var/title
	var/body
	var/poster_name
	var/poster_title
	var/truename
	var/poster_job
	var/posted_at
	var/signature_attested
	var/rank = HERALDBOARD_RANK_NONE
	var/datum/weakref/poster_ref

/datum/heraldboard_posting/New(title, body, poster_name, poster_title, mob/living/carbon/human/poster)
	src.title = title
	src.body = body
	src.poster_name = poster_name
	src.poster_title = poster_title
	src.truename = poster.real_name
	src.poster_job = poster.job
	src.posted_at = world.time
	src.posting_id = "[world.time]_[REF(src)]"
	src.signature_attested = (poster_name == poster.real_name) && (poster_title == poster.job)
	src.rank = heraldboard_rank_of(poster)
	src.poster_ref = WEAKREF(poster)

/datum/heraldboard_posting/Destroy()
	poster_ref = null
	return ..()

/datum/heraldboard_posting/proc/author_still_present()
	var/mob/living/carbon/human/H = poster_ref?.resolve()
	if(QDELETED(H))
		return FALSE
	return TRUE

/proc/heraldboard_validate_posts()
	var/list/dead_posts = list()
	for(var/datum/heraldboard_posting/P in GLOB.heraldboard_posts)
		if(!P.author_still_present())
			dead_posts += P
	if(!length(dead_posts))
		return FALSE
	for(var/datum/heraldboard_posting/P in dead_posts)
		GLOB.heraldboard_posts -= P
		qdel(P)
	return TRUE

/proc/heraldboard_find_post_by_id(posting_id)
	for(var/datum/heraldboard_posting/P in GLOB.heraldboard_posts)
		if(P.posting_id == posting_id)
			return P
	return null

/proc/heraldboard_count_posts_by(mob/living/carbon/human/H)
	var/count = 0
	for(var/datum/heraldboard_posting/P in GLOB.heraldboard_posts)
		if(P.truename == H.real_name)
			count++
	return count

/proc/heraldboard_add_posting(title, body, poster_name, poster_title, mob/living/carbon/human/poster)
	if(!poster || !ishuman(poster))
		return null
	var/datum/heraldboard_posting/new_post = new(title, body, poster_name, poster_title, poster)
	GLOB.heraldboard_posts += new_post
	heraldboard_broadcast_post_change(poster)
	return new_post

/proc/heraldboard_remove_posting(datum/heraldboard_posting/post)
	if(!post)
		return
	GLOB.heraldboard_posts -= post
	qdel(post)
	heraldboard_broadcast_post_change()

/proc/heraldboard_log_prune(mob/living/carbon/human/remover, datum/heraldboard_posting/post)
	var/list/entry = list(
		"remover_name" = remover.real_name,
		"remover_title" = remover.job || "",
		"post_title" = post.title,
		"poster_name" = post.poster_name,
		"poster_truename" = post.truename,
		"when" = world.time,
	)
	GLOB.heraldboard_prune_log.Insert(1, list(entry))
	while(length(GLOB.heraldboard_prune_log) > HERALDBOARD_PRUNE_LOG_MAX)
		GLOB.heraldboard_prune_log.Cut(length(GLOB.heraldboard_prune_log))

/proc/heraldboard_broadcast_post_change(mob/excluding)
	var/turf/excluding_turf = excluding ? get_turf(excluding) : null
	for(var/obj/structure/fake_machine/heraldboard/board in SSroguemachine.heraldboards)
		board.update_icon()
		SStgui.update_uis(board)
		if(excluding_turf && get_dist(board, excluding_turf) <= 1)
			continue
		playsound(board, 'sound/ambience/noises/birds (7).ogg', 50, FALSE, -1)
		board.visible_message(span_smallred("A courier bird lands, delivering a new posting!"))

/obj/structure/fake_machine/heraldboard
	name = "herald's board"
	desc = "A large wooden board bearing postings and proclamations from all across the realm."
	icon = 'modular_rmh/icons/obj/structures/herald_board64.dmi'
	icon_state = "heraldboard0"
	density = TRUE
	blade_dulling = DULLING_BASH
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER

/obj/structure/fake_machine/heraldboard/Initialize()
	. = ..()
	SSroguemachine.heraldboards += src
	update_icon()

/obj/structure/fake_machine/heraldboard/Destroy()
	SSroguemachine.heraldboards -= src
	return ..()

/obj/structure/fake_machine/heraldboard/wall
	icon = 'modular_rmh/icons/obj/structures/herald_board32.dmi'
	density = FALSE
	layer = ABOVE_MOB_LAYER
	pixel_y = 32

/obj/structure/fake_machine/heraldboard/wall/OnCrafted(dirin, mob/user)
	pixel_x = 0
	pixel_y = 0
	switch(dirin)
		if(NORTH)
			pixel_y = 32
		if(SOUTH)
			pixel_y = -32
		if(EAST)
			pixel_x = 32
		if(WEST)
			pixel_x = -32
	. = ..()

/obj/structure/fake_machine/heraldboard/update_icon()
	. = ..()
	switch(length(GLOB.heraldboard_posts))
		if(0)
			icon_state = "heraldboard0"
		if(1 to 3)
			icon_state = "heraldboard1"
		if(4 to 6)
			icon_state = "heraldboard2"
		else
			icon_state = "heraldboard3"

/obj/structure/fake_machine/heraldboard/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	ui_interact(user)

/obj/structure/fake_machine/heraldboard/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/structure/fake_machine/heraldboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HeraldBoard", name, 1000, 760)
		ui.open()

/obj/structure/fake_machine/heraldboard/ui_data(mob/user)
	var/list/data = list()
	// Sweep out posts whose authors have cryo'd / gone to lobby before showing.
	if(heraldboard_validate_posts())
		update_icon()
	data["scout_regions"] = build_scout_regions()
	if(!ishuman(user))
		data["posts"] = list()
		data["viewer_rank"] = HERALDBOARD_RANK_NONE
		data["is_herald"] = FALSE
		data["can_see_prune"] = FALSE
		data["prune_log"] = list()
		data["user_default_name"] = ""
		data["user_default_role"] = ""
		data["post_count"] = 0
		data["post_limit"] = 0
		return data
	var/mob/living/carbon/human/H = user
	var/viewer_rank = heraldboard_rank_of(H)
	var/is_herald = (viewer_rank == HERALDBOARD_RANK_HERALD)
	var/list/posts = list()
	for(var/datum/heraldboard_posting/P in GLOB.heraldboard_posts)
		posts += list(serialize_posting(P, H, viewer_rank, is_herald))
	data["posts"] = posts
	data["viewer_rank"] = viewer_rank
	data["is_herald"] = is_herald
	// Prune tab is for the herald and the three-star seats only.
	var/can_see_prune = (is_herald || viewer_rank >= HERALDBOARD_RANK_THREE)
	data["can_see_prune"] = can_see_prune
	data["prune_log"] = can_see_prune ? build_prune_log() : list()
	data["user_default_name"] = H.real_name
	data["user_default_role"] = H.job || ""
	data["post_count"] = heraldboard_count_posts_by(H)
	data["post_limit"] = heraldboard_limit_of(H)
	return data

/obj/structure/fake_machine/heraldboard/proc/build_prune_log()
	var/list/rows = list()
	for(var/list/entry in GLOB.heraldboard_prune_log)
		rows += list(list(
			"remover_name" = entry["remover_name"],
			"remover_title" = entry["remover_title"],
			"post_title" = entry["post_title"],
			"poster_name" = entry["poster_name"],
			"when_label" = format_posted_at_label(entry["when"]),
		))
	return rows

/obj/structure/fake_machine/heraldboard/proc/build_scout_regions()
	var/list/rows = list()
	var/list/seen = list()
	if(!SSregionthreat)
		return rows
	for(var/datum/threat_region_display/TRS in SSregionthreat.get_threat_regions_for_display())
		if(!(TRS.region_name in seen))
			seen += TRS.region_name
			rows += list(list(
				"region_name" = TRS.region_name,
				"danger_level" = TRS.danger_level,
				"danger_color" = TRS.danger_color,
				"region_desc" = heraldboard_region_desc(TRS.region_name),
			))
		qdel(TRS) // transient display copy, only needed for the lines just above
	return rows

/proc/heraldboard_region_desc(region_name)
	switch(region_name)
		if(THREAT_REGION_BASIN)
			return "The lowland bowl the town sits in. Well-travelled roads, but not empty ones."
		if(THREAT_REGION_NORTHERN_GROVE)
			return "Old woods north of the road. Foragers go there; not all of them come back talking."
		if(THREAT_REGION_OUTER_GROVE)
			return "The thinner treeline west of the road. Closer to home, and quieter for it."
		if(THREAT_REGION_MOUNT_DECAP)
			return "The high stone. Steep, cold, and named for what it does to the careless."
		if(THREAT_REGION_TERRORBOG)
			return "Standing water and worse. Even the guides ask to be paid in advance."
		if(THREAT_REGION_COAST)
			return "The shoreline and its landings. Whatever the tide brings, it brings without asking."
		if(THREAT_REGION_RMH_MOUNTAINS)
			return "The Dusk Spire ridges. Thin air, long falls, and something that keeps to the peaks."
		if(THREAT_REGION_RMH_DWARF_FORTRESS)
			return "Stonefast halls under the mountain. The dwarves keep their own law down there."
		if(THREAT_REGION_RMH_BOG)
			return "Sodden ground and sucking mud. Easy to enter, slow to leave."
		if(THREAT_REGION_RMH_ORC_FORT)
			return "The orcish holdfast. Go armed, go in numbers, or do not go."
		if(THREAT_REGION_RMG_DARK_FOREST)
			return "Deep timber where the light gives out early. Trails there are not always ours."
		if(THREAT_REGION_RMH_DESERT)
			return "Sand that remembers old magic. The heat is the lesser danger."
		if(THREAT_REGION_RMH_UNDERDARK)
			return "The deep dark beneath everything. What lives there has never needed the sun."
		if(THREAT_REGION_RMH_BASIN_RUINS)
			return "Broken stonework in the basin. Good pickings, and something picking back."
		if(THREAT_REGION_RMH_NORTH_DANGER)
			return "The far northern march. Beyond the last waystone, past where patrols turn around."
	return "Word from this quarter is thin. Travel as though it were worse than reported."

/obj/structure/fake_machine/heraldboard/proc/serialize_posting(datum/heraldboard_posting/P, mob/living/carbon/human/viewer, viewer_rank, viewer_is_herald)
	var/list/entry = list()
	entry["posting_id"] = P.posting_id
	entry["title"] = P.title
	entry["body"] = P.body
	entry["poster_name"] = P.poster_name
	entry["poster_title"] = P.poster_title
	entry["signature_attested"] = P.signature_attested ? TRUE : FALSE
	entry["posted_at_label"] = format_posted_at_label(P.posted_at)
	entry["is_own"] = (viewer && P.truename == viewer.real_name) ? TRUE : FALSE
	entry["shown_rank"] = (P.signature_attested || viewer_is_herald) ? P.rank : HERALDBOARD_RANK_NONE
	entry["rank_hidden"] = (!P.signature_attested && viewer_is_herald) ? TRUE : FALSE
	entry["can_authority_remove"] = (viewer_rank > HERALDBOARD_RANK_NONE \
		&& P.truename != viewer.real_name \
		&& viewer_rank >= P.rank) ? TRUE : FALSE
	return entry

/obj/structure/fake_machine/heraldboard/proc/format_posted_at_label(posted_at)
	var/elapsed = world.time - posted_at
	if(elapsed < 1 MINUTES)
		return "just now"
	var/minutes = round(elapsed / (1 MINUTES))
	if(minutes < 60)
		return "[minutes]m ago"
	var/hours = round(minutes / 60)
	if(hours < 24)
		return "[hours]h ago"
	var/days = round(hours / 24)
	return "[days]d ago"

/obj/structure/fake_machine/heraldboard/proc/on_cooldown(mob/living/carbon/human/H, cooldown_length)
	var/key = H.ckey
	if(!key)
		return FALSE
	var/ready_at = GLOB.heraldboard_cooldowns[key]
	if(ready_at && world.time < ready_at)
		to_chat(H, span_warning("Give the ink a moment to dry."))
		return TRUE
	GLOB.heraldboard_cooldowns[key] = world.time + cooldown_length
	return FALSE

/obj/structure/fake_machine/heraldboard/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		return TRUE
	if(!H.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return TRUE
	switch(action)
		if("make_post")
			handle_make_post(H, params)
			return TRUE
		if("remove_post")
			handle_remove_post(H, params)
			return TRUE
		if("authority_remove_post")
			handle_authority_remove_post(H, params)
			return TRUE

/obj/structure/fake_machine/heraldboard/proc/handle_make_post(mob/living/carbon/human/H, list/params)
	if(on_cooldown(H, HERALDBOARD_POST_COOLDOWN))
		return
	heraldboard_validate_posts()
	var/limit = heraldboard_limit_of(H)
	if(heraldboard_count_posts_by(H) >= limit)
		to_chat(H, span_warning("You have no room left on the board - you may keep [limit] posting\s pinned."))
		return
	var/title = sanitize_input("[params["title"]]", HERALDBOARD_TITLE_MAX_LENGTH)
	var/body = sanitize_input("[params["body"]]", HERALDBOARD_BODY_MAX_LENGTH, multiline = TRUE)
	var/poster_name = sanitize_input("[params["poster_name"]]", HERALDBOARD_NAME_MAX_LENGTH)
	var/poster_title = sanitize_input("[params["poster_title"]]", HERALDBOARD_ROLE_MAX_LENGTH)
	if(!title || !body || !poster_name)
		to_chat(H, span_warning("The posting must bear a title, a body, and a name."))
		return
	heraldboard_add_posting(title, body, poster_name, poster_title, H)
	message_admins("[ADMIN_LOOKUPFLW(H)] has made a herald's board post. The message was: [html_encode(body)]")

/obj/structure/fake_machine/heraldboard/proc/handle_remove_post(mob/living/carbon/human/H, list/params)
	var/posting_id = "[params["posting_id"]]"
	var/datum/heraldboard_posting/P = heraldboard_find_post_by_id(posting_id)
	if(!P)
		return
	if(P.truename != H.real_name)
		to_chat(H, span_warning("That posting is not yours to take down."))
		return
	if(on_cooldown(H, HERALDBOARD_REMOVE_COOLDOWN))
		return
	playsound(loc, 'sound/foley/dropsound/paper_drop.ogg', 50, FALSE, -1)
	loc.visible_message(span_smallred("[H] tears down a posting!"))
	heraldboard_remove_posting(P)
	message_admins("[ADMIN_LOOKUPFLW(H)] has removed their herald's board post.")

/obj/structure/fake_machine/heraldboard/proc/handle_authority_remove_post(mob/living/carbon/human/H, list/params)
	var/posting_id = "[params["posting_id"]]"
	var/datum/heraldboard_posting/P = heraldboard_find_post_by_id(posting_id)
	if(!P)
		return
	var/remover_rank = heraldboard_rank_of(H)
	if(remover_rank <= HERALDBOARD_RANK_NONE)
		to_chat(H, span_warning("You hold no authority to take down another's posting."))
		return
	if(P.truename == H.real_name)
		to_chat(H, span_warning("Take your own posting down plainly, not by writ."))
		return
	if(remover_rank < P.rank)
		to_chat(H, span_warning("That posting was pinned by a better than you. Leave it be."))
		return
	if(on_cooldown(H, HERALDBOARD_REMOVE_COOLDOWN))
		return
	playsound(loc, 'sound/foley/dropsound/paper_drop.ogg', 50, FALSE, -1)
	loc.visible_message(span_smallred("[H] tears down a posting!"))
	heraldboard_log_prune(H, P)
	heraldboard_remove_posting(P)
	message_admins("[ADMIN_LOOKUPFLW(H)] has authoritatively removed a herald's board post by [P.truename].")

/obj/structure/fake_machine/heraldboard/proc/sanitize_input(text, max_length, multiline = FALSE)
	if(!text || text == "null")
		return null
	text = trim(text)
	if(!length_char(text))
		return null
	if(length_char(text) > max_length)
		text = copytext_char(text, 1, max_length + 1)
	return text

#undef HERALDBOARD_TITLE_MAX_LENGTH
#undef HERALDBOARD_BODY_MAX_LENGTH
#undef HERALDBOARD_NAME_MAX_LENGTH
#undef HERALDBOARD_ROLE_MAX_LENGTH
#undef HERALDBOARD_POST_COOLDOWN
#undef HERALDBOARD_REMOVE_COOLDOWN
#undef HERALDBOARD_PRUNE_LOG_MAX
#undef HERALDBOARD_RANK_NONE
#undef HERALDBOARD_RANK_ONE
#undef HERALDBOARD_RANK_TWO
#undef HERALDBOARD_RANK_THREE
#undef HERALDBOARD_RANK_HERALD
#undef HERALDBOARD_LIMIT_HERALD
#undef HERALDBOARD_LIMIT_UNLISTED
// ==================== END HERALD'S BOARD ====================
