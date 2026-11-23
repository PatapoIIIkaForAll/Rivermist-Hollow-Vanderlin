/**
 * Round Log: what players (and admins) did this round, kept in memory so it can be read in the
 * Admin Menu instead of digging through log files that cover a three-day round.
 *
 * Only player actions are kept: lines whose actor is a mob with a ckey (via /atom/proc/log_message),
 * attacks on players by NPCs (via log_combat), plain log_*() lines caused by a player (usr has a
 * client), and every admin line. NPC fights, NPC speech and background game logs are left out:
 * on a map with thousands of mobs they would flood the log and cost CPU for nothing.
 * The log files on disk are written exactly as before.
 *
 * Cost per line: two list appends. The round time and the lowercase search text are only made
 * when a page is shown or a search needs them.
 */

/// Newest last. Entry: list("id", "t" (world.time), "cat", "ckey", "text", "x", "y", "z").
GLOBAL_LIST_EMPTY(round_log)
GLOBAL_PROTECT(round_log)
/// Lowercase "ckey text" of each entry, same order as round_log; null until a search needs it.
GLOBAL_LIST_EMPTY(round_log_search)
GLOBAL_PROTECT(round_log_search)
/// ckey -> TRUE for every actor seen this round.
GLOBAL_LIST_EMPTY(round_log_actors)
GLOBAL_PROTECT(round_log_actors)
/// category -> entries logged this round (not reduced by trimming).
GLOBAL_LIST_EMPTY(round_log_counts)
GLOBAL_PROTECT(round_log_counts)
/// Id of the newest entry. Ids are consecutive, so an id gives its index directly.
GLOBAL_VAR_INIT(round_log_last_id, 0)
GLOBAL_PROTECT(round_log_last_id)
/// Last text added, so a line logged by log_message() is not added again by the log_*() proc it calls.
GLOBAL_VAR(round_log_last_text)
GLOBAL_PROTECT(round_log_last_text)

#define ROUND_LOG_LIMIT 20000
#define ROUND_LOG_TRIM 1000
#define ROUND_LOG_PAGE 100

/// Categories in display order, id -> label.
/proc/round_log_categories()
	var/static/list/categories = list(
		"attack" = "Combat",
		"say" = "Say",
		"whisper" = "Whisper",
		"emote" = "Emote",
		"ooc" = "OOC",
		"looc" = "LOOC",
		"prayer" = "Prayer",
		"game" = "Game",
		"dsay" = "Dead chat",
		"admin" = "Admin",
		"asay" = "Asay",
		"other" = "Other",
	)
	return categories

/proc/round_log_category_of(message_type)
	switch(message_type)
		if(LOG_ATTACK)
			return "attack"
		if(LOG_SAY)
			return "say"
		if(LOG_WHISPER)
			return "whisper"
		if(LOG_EMOTE)
			return "emote"
		if(LOG_DSAY)
			return "dsay"
		if(LOG_OOC)
			return "ooc"
		if(LOG_LOOC)
			return "looc"
		if(LOG_ADMIN, LOG_ADMIN_PRIVATE)
			return "admin"
		if(LOG_ASAY)
			return "asay"
		if(LOG_GAME, LOG_OWNERSHIP)
			return "game"
	return "other"

/// Adds one line. actor_ckey defaults to usr; where (a turf) lets admins jump to the spot.
/proc/round_log_add(category, text, actor_ckey, turf/where)
	text = "[text]"
	if(text == GLOB.round_log_last_text) // the same line arriving through log_message() and log_*()
		return
	GLOB.round_log_last_text = text
	if(isnull(actor_ckey))
		var/mob/user = usr // usr can be 0 in subsystem code, which ?. does not guard against
		actor_ckey = ismob(user) ? user.ckey : null
	var/id = ++GLOB.round_log_last_id
	GLOB.round_log += list(list(
		"id" = id,
		"t" = world.time,
		"cat" = category,
		"ckey" = actor_ckey,
		"text" = text,
		"x" = where?.x,
		"y" = where?.y,
		"z" = where?.z,
	))
	GLOB.round_log_search += null
	GLOB.round_log_counts[category]++
	if(actor_ckey && !GLOB.round_log_actors[actor_ckey])
		GLOB.round_log_actors[actor_ckey] = TRUE
	if(length(GLOB.round_log) > ROUND_LOG_LIMIT + ROUND_LOG_TRIM)
		GLOB.round_log.Cut(1, ROUND_LOG_TRIM + 1)
		GLOB.round_log_search.Cut(1, ROUND_LOG_TRIM + 1)
	for(var/client/admin as anything in GLOB.admins)
		admin?.holder?.admin_menu?.queue_log_refresh()

/// For the plain log_*() procs: keeps the line only when a player caused it (usr has a client).
/proc/round_log_add_from_player(category, text)
	var/mob/user = usr
	if(!ismob(user) || !user.client)
		return
	round_log_add(category, text)

/// Kept for the admin log hooks written before the Round Log covered players.
/proc/admin_action_feed_add(text, private = FALSE)
	round_log_add("admin", text)

/// Round time of a log entry, in the same format as ROUND_TIME().
/proc/round_log_time(entry_time)
	if(!SSticker)
		return "init"
	var/elapsed = entry_time - SSticker.round_start_time
	var/clock = gameTimestamp("hh:mm:ss", entry_time)
	return elapsed > MIDNIGHT_ROLLOVER ? "[round(elapsed / MIDNIGHT_ROLLOVER)]:[clock]" : clock

/// Lowercase search text of entry index, made the first time a search looks at it.
/proc/round_log_haystack(index)
	var/haystack = GLOB.round_log_search[index]
	if(isnull(haystack))
		var/list/entry = GLOB.round_log[index]
		haystack = LOWER_TEXT("[entry["ckey"]] [entry["text"]]")
		GLOB.round_log_search[index] = haystack
	return haystack

/// Does entry index match the filter? categories: list of ids or null for all.
/proc/round_log_matches(index, list/categories, player, list/terms)
	var/list/entry = GLOB.round_log[index]
	if(categories && !(entry["cat"] in categories))
		return FALSE
	if(!player && !length(terms))
		return TRUE
	var/haystack = round_log_haystack(index)
	if(player && entry["ckey"] != player && !findtextEx(haystack, player))
		return FALSE
	for(var/term in terms)
		if(!findtextEx(haystack, term))
			return FALSE
	return TRUE

/// The entry as the window shows it: the stored list plus its round time.
/proc/round_log_display(list/entry)
	return list(
		"id" = entry["id"],
		"time" = round_log_time(entry["t"]),
		"cat" = entry["cat"],
		"ckey" = entry["ckey"],
		"text" = entry["text"],
		"x" = entry["x"],
		"y" = entry["y"],
		"z" = entry["z"],
	)

/**
 * One page of the log, newest first.
 * cache is a list the caller keeps between calls: it holds the ids that matched so far, so only
 * entries added since the last call are scanned.
 */
/proc/round_log_page(list/categories, player, search, page, list/cache)
	var/list/log = GLOB.round_log
	var/total = length(log)
	var/first_id = total ? log[1]["id"] : GLOB.round_log_last_id + 1
	var/list/terms = splittext(LOWER_TEXT("[search]"), " ")
	terms -= ""
	player = player ? LOWER_TEXT("[player]") : null
	if(!length(categories))
		categories = null
	var/filtered = categories || player || length(terms)
	var/list/ids
	if(filtered)
		var/key = "[jointext(categories || list(), ",")]|[player]|[jointext(terms, " ")]"
		if(cache["key"] != key)
			cache["key"] = key
			cache["ids"] = list()
			cache["last"] = 0
		ids = cache["ids"]
		var/scan_from = max(cache["last"] + 1, first_id)
		for(var/id in scan_from to GLOB.round_log_last_id)
			if(round_log_matches(id - first_id + 1, categories, player, terms))
				ids += id
		cache["last"] = GLOB.round_log_last_id
		// Drop ids that were trimmed away.
		var/stale = 0
		while(stale < length(ids) && ids[stale + 1] < first_id)
			stale++
		if(stale)
			ids.Cut(1, stale + 1)
	var/matches = filtered ? length(ids) : total
	var/pages = max(1, CEILING(matches / ROUND_LOG_PAGE, 1))
	page = clamp(page, 1, pages)
	var/start = (page - 1) * ROUND_LOG_PAGE + 1
	var/list/shown = list()
	for(var/position in start to min(start + ROUND_LOG_PAGE - 1, matches))
		var/index = filtered ? ids[length(ids) - position + 1] - first_id + 1 : total - position + 1
		shown += list(round_log_display(log[index]))
	var/list/category_list = list()
	var/list/labels = round_log_categories()
	for(var/id in labels)
		category_list += list(list("id" = id, "name" = labels[id], "count" = GLOB.round_log_counts[id] || 0))
	return list(
		"entries" = shown,
		"matches" = matches,
		"total" = total,
		"page" = page,
		"pages" = pages,
		"categories" = category_list,
	)

/// Sorted actor ckeys for the player filter. Only rebuilt when a new actor appeared.
/proc/round_log_actor_list()
	var/static/list/cached
	var/static/cached_count = -1
	if(cached_count != length(GLOB.round_log_actors))
		cached_count = length(GLOB.round_log_actors)
		var/list/actors = list()
		for(var/ckey in GLOB.round_log_actors)
			actors += ckey
		cached = sortList(actors)
	return cached

#undef ROUND_LOG_LIMIT
#undef ROUND_LOG_TRIM
#undef ROUND_LOG_PAGE
