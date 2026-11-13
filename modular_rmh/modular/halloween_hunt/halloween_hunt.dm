#define HUNT_TITLE_ID "title_pumpkin_monarch"
#define HUNT_TOPUP_INTERVAL (2 MINUTES)
#define HUNT_SCOREBOARD_INTERVAL (5 MINUTES)
#define HUNT_LEADER_INTERVAL (20 SECONDS)
#define HUNT_TOPUP_MAX 100
#define HUNT_OUTSKIRTS_RANGE 30
#define HUNT_OUTSKIRTS_SHARE 30
#define HUNT_TOFFEE_CHANCE 4
#define HUNT_DISTRACT_RANGE 6

GLOBAL_DATUM(halloween_hunt, /datum/halloween_hunt)

/datum/dungeon_cosmetic/title_pumpkin_monarch
	id = HUNT_TITLE_ID
	name = "Title: Pumpkin Monarch"
	desc = "Won a Hollow's Eve Candy Hunt with the fullest pumpkin basket."
	echo_cost = 0
	event_only = TRUE
	title_text = "Pumpkin Monarch"

// Admin-only: max_occurrences 0 keeps the storyteller from rolling it.
/datum/round_event_control/halloween_hunt
	name = "Halloween: Candy Hunt"
	track = EVENT_TRACK_MUNDANE
	typepath = /datum/round_event/halloween_hunt
	weight = 0
	max_occurrences = 0
	earliest_start = 0
	tags = list(
		TAG_HAUNTED,
		TAG_BOON,
	)
	/// Admin settings handed to the next hunt.
	var/list/pending_settings
	var/tmp/configuring = FALSE

/datum/round_event_control/halloween_hunt/get_href_actions()
	if(GLOB.halloween_hunt)
		return "<a href='byond://?src=[REF(src)];action=hunt_scores'>Scores</a> <a href='byond://?src=[REF(src)];action=hunt_end'>End now</a>"
	if(SSticker.HasRoundStarted())
		return "<a href='byond://?src=[REF(src)];action=hunt_fire'>Fire</a>"
	return "<a class='linkOff'>Fire</a>"

/datum/round_event_control/halloween_hunt/Topic(href, href_list)
	. = ..()
	if(!href_list["action"] || !findtext(href_list["action"], "hunt_"))
		return
	if(!check_rights(R_FUN))
		return
	switch(href_list["action"])
		if("hunt_fire")
			INVOKE_ASYNC(src, PROC_REF(admin_start), usr)
		if("hunt_end")
			INVOKE_ASYNC(src, PROC_REF(admin_end), usr)
		if("hunt_scores")
			GLOB.halloween_hunt?.show_scores(usr)

/datum/round_event_control/halloween_hunt/proc/admin_start(mob/user)
	if(GLOB.halloween_hunt || configuring)
		to_chat(user, span_warning("A Candy Hunt is already running or being set up."))
		return
	configuring = TRUE
	var/minutes = tgui_input_number(user, "How long should the hunt last, in minutes?", "Candy Hunt", 20, 120, 5)
	var/candy = minutes && tgui_input_number(user, "How much candy should lie on the ground at once? It refills every 2 minutes.", "Candy Hunt", 250, 1000, 20)
	var/players = 0
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.stat != DEAD)
			players++
	var/ghosts = candy && tgui_input_number(user, "How many ghosts? One of them is the rare hooded haunt.", "Candy Hunt", clamp(round(players / 5), 3, 12), 30, 1)
	var/zone = ghosts && tgui_alert(user, "Where should candy appear?", "Candy Hunt", list("Town + Outskirts", "Town only"))
	configuring = FALSE
	if(!zone || GLOB.halloween_hunt)
		return
	pending_settings = list("minutes" = minutes, "candy" = candy, "ghosts" = ghosts, "outskirts" = (zone == "Town + Outskirts"))
	message_admins("[key_name_admin(user)] started the Halloween Candy Hunt: [minutes] min, [candy] candy, [ghosts] ghosts, [zone].")
	log_admin("[key_name(user)] started the Halloween Candy Hunt: [minutes] min, [candy] candy, [ghosts] ghosts, [zone].")
	runEvent(random = FALSE, admin_forced = TRUE)

/datum/round_event_control/halloween_hunt/proc/admin_end(mob/user)
	if(!GLOB.halloween_hunt)
		return
	if(tgui_alert(user, "End the Candy Hunt now and hand out the prizes?", "Candy Hunt", list("End it", "Cancel")) != "End it")
		return
	if(!GLOB.halloween_hunt)
		return
	message_admins("[key_name_admin(user)] ended the Halloween Candy Hunt early.")
	log_admin("[key_name(user)] ended the Halloween Candy Hunt early.")
	GLOB.halloween_hunt.finish()

/// Launcher only: the hunt datum runs on its own timers.
/datum/round_event/halloween_hunt

/datum/round_event/halloween_hunt/start()
	var/datum/round_event_control/halloween_hunt/hunt_control = control
	var/list/settings = hunt_control?.pending_settings
	if(hunt_control)
		hunt_control.pending_settings = null
	if(GLOB.halloween_hunt)
		return
	GLOB.halloween_hunt = new /datum/halloween_hunt(settings)
	INVOKE_ASYNC(GLOB.halloween_hunt, TYPE_PROC_REF(/datum/halloween_hunt, begin))

/datum/halloween_hunt
	var/duration = 20 MINUTES
	var/candy_target = 250
	var/ghost_count = 3
	var/include_outskirts = TRUE
	var/started = FALSE
	var/finished = FALSE
	var/end_time = 0
	var/next_topup = 0
	var/next_scoreboard = 0
	var/next_leader_check = 0
	var/warned_final_minute = FALSE
	var/list/town_turfs = list()
	var/list/outskirt_turfs = list()
	var/list/ghosts = list()
	/// The fullest basket; it glows.
	var/obj/item/hunt_basket/leader

/datum/halloween_hunt/New(list/settings)
	. = ..()
	if(settings)
		duration = settings["minutes"] MINUTES
		candy_target = settings["candy"]
		ghost_count = settings["ghosts"]
		include_outskirts = settings["outskirts"]

/datum/halloween_hunt/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN)
	QDEL_LIST(ghosts)
	town_turfs = null
	outskirt_turfs = null
	leader = null
	if(GLOB.halloween_hunt == src)
		GLOB.halloween_hunt = null
	return ..()

/datum/halloween_hunt/proc/begin()
	collect_turfs()
	if(QDELETED(src))
		return
	if(!length(town_turfs))
		message_admins("Halloween Candy Hunt: this map has no town areas, so the hunt was cancelled.")
		qdel(src)
		return
	end_time = world.time + duration
	next_topup = world.time + HUNT_TOPUP_INTERVAL
	next_scoreboard = world.time + HUNT_SCOREBOARD_INTERVAL
	priority_announce("Hollow's Eve is here! Pumpkin baskets appear in every hand, and candy lies all through the town. The fullest basket in [duration / (1 MINUTES)] minutes crowns the Pumpkin Monarch. Beware the ghosts: they crave your candy!", "The Candy Hunt", 'sound/misc/evilevent.ogg')
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		give_basket(player)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_spawn))
	spawn_ghosts()
	started = TRUE
	START_PROCESSING(SSprocessing, src)
	spawn_candy(candy_target)

/// Town = town areas minus private, holy, cell and roof areas. Outskirts = other outdoor tiles near the town.
/datum/halloween_hunt/proc/collect_turfs()
	var/list/bounds = list()
	for(var/area/zone as anything in GLOB.areas)
		if(!is_hunt_town_area(zone))
			continue
		var/outdoor = istype(zone, /area/outdoors)
		for(var/list/zlevel_turfs as anything in zone.get_zlevel_turf_lists())
			for(var/turf/spot as anything in zlevel_turfs)
				if(!is_hunt_spawn_turf(spot))
					continue
				town_turfs += spot
				if(!outdoor)
					continue
				var/z_key = "[spot.z]"
				var/list/box = bounds[z_key]
				if(!box)
					bounds[z_key] = list(spot.x, spot.y, spot.x, spot.y)
				else
					box[1] = min(box[1], spot.x)
					box[2] = min(box[2], spot.y)
					box[3] = max(box[3], spot.x)
					box[4] = max(box[4], spot.y)
			CHECK_TICK
			if(QDELETED(src))
				return
	if(!include_outskirts)
		return
	// The town spans several floors; each floor with streets gets its own surrounding fields.
	for(var/z_key in bounds)
		var/z_level = text2num(z_key)
		var/list/box = bounds[z_key]
		for(var/area/zone as anything in GLOB.areas)
			if(!is_hunt_outskirt_area(zone))
				continue
			for(var/turf/spot as anything in zone.get_turfs_by_zlevel(z_level))
				if(spot.x < box[1] - HUNT_OUTSKIRTS_RANGE || spot.x > box[3] + HUNT_OUTSKIRTS_RANGE)
					continue
				if(spot.y < box[2] - HUNT_OUTSKIRTS_RANGE || spot.y > box[4] + HUNT_OUTSKIRTS_RANGE)
					continue
				if(is_hunt_spawn_turf(spot))
					outskirt_turfs += spot
			CHECK_TICK
			if(QDELETED(src))
				return

/proc/is_hunt_town_area(area/zone)
	if(zone.holy_area || zone.cell_area || zone.keep_area || zone.warden_area)
		return FALSE
	if(!istype(zone, /area/outdoors/town) && !istype(zone, /area/outdoors/exposed/town) && !istype(zone, /area/indoors/town))
		return FALSE
	var/path = "[zone.type]"
	for(var/word in list("roof", "living", "garrison", "bank", "vault"))
		if(findtext(path, word))
			return FALSE
	return TRUE

/// Outdoor land that is not part of the town at all, not holy, not sky.
/proc/is_hunt_outskirt_area(area/zone)
	if(!istype(zone, /area/outdoors) || zone.holy_area)
		return FALSE
	if(istype(zone, /area/outdoors/town) || istype(zone, /area/outdoors/exposed/town))
		return FALSE
	var/path = "[zone.type]"
	for(var/word in list("air", "chapel", "roof"))
		if(findtext(path, word))
			return FALSE
	return TRUE

/proc/is_hunt_spawn_turf(turf/spot)
	if(!isopenturf(spot) || isopenspace(spot) || spot.density)
		return FALSE
	return !istype(spot, /turf/open/water) && !istype(spot, /turf/open/lava)

/datum/halloween_hunt/proc/pick_spawn_turf(list/pool)
	if(!length(pool))
		return null
	for(var/i in 1 to 8)
		var/turf/spot = pick(pool)
		if(!spot.is_blocked_turf(TRUE))
			return spot
	return null

/datum/halloween_hunt/proc/spawn_candy(amount)
	for(var/i in 1 to amount)
		if(QDELETED(src) || finished)
			return
		var/use_outskirts = include_outskirts && length(outskirt_turfs) && prob(HUNT_OUTSKIRTS_SHARE)
		var/turf/spot = pick_spawn_turf(use_outskirts ? outskirt_turfs : town_turfs)
		if(spot)
			if(prob(HUNT_TOFFEE_CHANCE))
				new /obj/item/reagent_containers/food/snacks/hunt_candy/toffee(spot)
			else
				new /obj/item/reagent_containers/food/snacks/hunt_candy(spot)
		CHECK_TICK

/datum/halloween_hunt/proc/top_up_candy()
	var/on_ground = 0
	for(var/obj/item/treat as anything in GLOB.halloween_hunt_candies)
		if(isturf(treat.loc))
			on_ground++
	if(on_ground < candy_target)
		spawn_candy(min(candy_target - on_ground, HUNT_TOPUP_MAX))

/datum/halloween_hunt/proc/spawn_ghosts()
	var/list/player_floors = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.stat != DEAD)
			player_floors += player.z
	for(var/i in 1 to ghost_count)
		var/turf/spot
		// Ghosts start on floors where people are, so they do not idle on empty upper floors.
		if(length(player_floors))
			spot = pick_town_turf_on_z(pick(player_floors))
		if(!spot || spot.is_blocked_turf(TRUE))
			spot = pick_spawn_turf(town_turfs)
		if(spot)
			ghosts += new /obj/effect/hunt_ghost(spot, i == 1 && ghost_count >= 2)

/datum/halloween_hunt/process(seconds_per_tick)
	if(!started || finished)
		return
	if(world.time >= end_time)
		INVOKE_ASYNC(src, PROC_REF(finish))
		return
	if(!warned_final_minute && end_time - world.time <= 1 MINUTES)
		warned_final_minute = TRUE
		tell_hunters(span_boldannounce("One minute left in the Candy Hunt!"))
	if(world.time >= next_leader_check)
		next_leader_check = world.time + HUNT_LEADER_INTERVAL
		update_leader()
	if(world.time >= next_topup)
		next_topup = world.time + HUNT_TOPUP_INTERVAL
		INVOKE_ASYNC(src, PROC_REF(top_up_candy))
	if(world.time >= next_scoreboard)
		next_scoreboard = world.time + HUNT_SCOREBOARD_INTERVAL
		announce_standings()

/datum/halloween_hunt/proc/tell_hunters(message)
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		to_chat(player, message)

/datum/halloween_hunt/proc/has_basket(datum/mind/owner)
	for(var/obj/item/hunt_basket/basket as anything in GLOB.halloween_hunt_baskets)
		if(basket.get_owner_mind() == owner)
			return TRUE
	return FALSE

/datum/halloween_hunt/proc/give_basket(mob/living/carbon/human/player)
	if(finished || !ishuman(player) || QDELETED(player) || player.stat == DEAD || !player.client || !player.mind)
		return
	if(has_basket(player.mind))
		return
	var/obj/item/hunt_basket/basket = new(get_turf(player))
	basket.bind_to(player)
	if(!player.put_in_hands(basket) && !player.equip_to_slot_if_possible(basket, ITEM_SLOT_BELT_R, disable_warning = TRUE) && !player.equip_to_slot_if_possible(basket, ITEM_SLOT_BELT_L, disable_warning = TRUE))
		to_chat(player, span_notice("A pumpkin basket appears at my feet."))
	to_chat(player, span_notice("<b>Candy Hunt:</b> pick up candy and put it into my pumpkin basket, or click candy with the basket to scoop it. Only my own basket counts."))
	to_chat(player, span_notice("Ghosts scatter my candy if they catch me. I can outrun them, rest on consecrated ground, or throw them a candy."))

/datum/halloween_hunt/proc/on_job_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(give_basket), spawned), 3 SECONDS, TIMER_DELETE_ME)

/datum/halloween_hunt/proc/on_basket_changed(obj/item/hunt_basket/basket)
	if(!started || finished)
		return
	if(!leader || basket == leader || basket.candy > leader.candy)
		update_leader()

/datum/halloween_hunt/proc/on_basket_destroyed(obj/item/hunt_basket/basket)
	if(basket == leader)
		leader = null

/datum/halloween_hunt/proc/update_leader()
	var/obj/item/hunt_basket/best
	for(var/obj/item/hunt_basket/basket as anything in GLOB.halloween_hunt_baskets)
		if(basket.candy <= 0 || !basket.get_owner_mind())
			continue
		if(!best || basket.candy > best.candy)
			best = basket
	if(best == leader)
		return
	leader?.set_lit(FALSE)
	leader = best
	if(!leader)
		return
	leader.set_lit(TRUE)
	var/mob/holder = get(leader, /mob)
	if(holder)
		to_chat(holder, span_love("My pumpkin basket grins with candle light: I lead the Candy Hunt!"))

/datum/halloween_hunt/proc/on_ghost_catch(obj/effect/hunt_ghost/ghost, mob/living/victim, lost)
	log_game("Candy Hunt: [ghost] caught [key_name(victim)], who lost [lost] candy.")

/datum/halloween_hunt/proc/on_candy_landed(obj/item/treat, mob/thrower)
	if(!isliving(thrower) || !started || finished)
		return
	var/obj/effect/hunt_ghost/closest
	var/closest_distance = HUNT_DISTRACT_RANGE + 1
	for(var/obj/effect/hunt_ghost/ghost as anything in ghosts)
		if(QDELETED(ghost) || ghost.vanished || ghost.snack_ref || ghost.z != treat.z)
			continue
		var/distance = get_dist(ghost, treat)
		if(distance < closest_distance)
			closest = ghost
			closest_distance = distance
	closest?.distract(treat, thrower)

/datum/halloween_hunt/proc/carriers_on_z(z_level)
	. = list()
	for(var/obj/item/hunt_basket/basket as anything in GLOB.halloween_hunt_baskets)
		if(basket.candy <= 0)
			continue
		var/mob/living/carbon/human/holder = get(basket, /mob/living/carbon/human)
		if(!holder?.client || holder.stat != CONSCIOUS || (z_level && holder.z != z_level))
			continue
		var/area/holder_area = get_area(holder)
		if(!holder_area?.holy_area)
			. |= holder

/datum/halloween_hunt/proc/has_carriers_on_z(z_level)
	return length(carriers_on_z(z_level)) > 0

/datum/halloween_hunt/proc/pick_town_turf_on_z(z_level, atom/far_from, min_distance = 0)
	if(!length(town_turfs))
		return null
	for(var/i in 1 to 20)
		var/turf/spot = pick(town_turfs)
		if(spot.z != z_level)
			continue
		if(far_from && get_dist(spot, far_from) < min_distance)
			continue
		return spot
	return null

/datum/halloween_hunt/proc/pick_roam_goal(obj/effect/hunt_ghost/ghost)
	var/list/carriers = carriers_on_z(ghost.z)
	if(length(carriers) && prob(70))
		return get_turf(pick(carriers))
	return pick_town_turf_on_z(ghost.z)

/datum/halloween_hunt/proc/pick_ghost_turf(obj/effect/hunt_ghost/ghost)
	return pick_town_turf_on_z(ghost.z, ghost, 12) || pick_town_turf_on_z(ghost.z) || pick_spawn_turf(town_turfs)

/// A town tile on a floor where someone carries candy.
/datum/halloween_hunt/proc/pick_busy_turf()
	var/list/carriers = shuffle(carriers_on_z(null))
	for(var/mob/living/carrier as anything in carriers)
		var/turf/spot = pick_town_turf_on_z(carrier.z, carrier, 8)
		if(spot)
			return spot
	return null

/datum/halloween_hunt/proc/get_scores()
	var/list/scores = list()
	for(var/obj/item/hunt_basket/basket as anything in GLOB.halloween_hunt_baskets)
		var/datum/mind/owner = basket.get_owner_mind()
		if(!owner)
			continue
		scores += list(list("basket" = basket, "mind" = owner, "name" = basket.owner_name, "ckey" = basket.owner_ckey, "candy" = basket.candy))
	return sortTim(scores, GLOBAL_PROC_REF(cmp_hunt_scores))

/proc/cmp_hunt_scores(list/a, list/b)
	return b["candy"] - a["candy"]

/datum/halloween_hunt/proc/announce_standings()
	var/list/scores = get_scores()
	var/list/lines = list()
	for(var/i in 1 to min(3, length(scores)))
		var/list/entry = scores[i]
		if(entry["candy"] <= 0)
			break
		lines += "[i]. [html_encode(entry["name"])]: [entry["candy"]]"
	if(!length(lines))
		return
	var/minutes_left = max(1, round((end_time - world.time) / (1 MINUTES)))
	tell_hunters(span_notice("<b>Candy Hunt standings</b> ([minutes_left] min left): [lines.Join(", ")]"))

/datum/halloween_hunt/proc/show_scores(mob/user)
	var/list/rows = list()
	for(var/list/entry as anything in get_scores())
		rows += "<tr><td>[html_encode(entry["name"])]</td><td>[entry["ckey"]]</td><td>[entry["candy"]]</td></tr>"
	var/minutes_left = max(0, round((end_time - world.time) / (1 MINUTES)))
	var/html = "<b>Candy Hunt</b>: [minutes_left] min left, [length(ghosts)] ghosts, [length(GLOB.halloween_hunt_candies)] candy items.<hr><table width='100%'><tr><th>Owner</th><th>Ckey</th><th>Candy</th></tr>[rows.Join()]</table>"
	user << browse(html, "window=halloween_hunt_scores;size=420x520")

/datum/halloween_hunt/proc/finish()
	if(finished)
		return
	finished = TRUE
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN)
	var/list/scores = get_scores()
	var/top = length(scores) ? scores[1]["candy"] : 0
	var/list/lines = list()
	if(top <= 0)
		lines += "Nobody gathered any candy. The ghosts keep it all!"
	else
		var/runners_up = 0
		for(var/list/entry as anything in scores)
			if(entry["candy"] == top)
				award_winner(entry)
				lines += "Pumpkin Monarch: [html_encode(entry["name"])] with [entry["candy"]] candy!"
			else if(runners_up < 2 && entry["candy"] > 0)
				runners_up++
				award_runner_up(entry)
				lines += "Runner-up: [html_encode(entry["name"])] with [entry["candy"]] candy."
			else
				break
	priority_announce(lines.Join("<br>"), "The Candy Hunt is over", 'sound/misc/bell.ogg', encode_text = FALSE)
	log_game("Candy Hunt ended. Top score: [top].")
	leader?.set_lit(FALSE)
	for(var/obj/effect/hunt_ghost/ghost as anything in ghosts)
		ghost.visible_message(span_notice("[ghost] fades away with one last giggle."))
	for(var/obj/item/treat as anything in GLOB.halloween_hunt_candies.Copy())
		if(isturf(treat.loc))
			qdel(treat)
	qdel(src)

/datum/halloween_hunt/proc/hand_prize(mob/living/body, obj/item/prize)
	if(isliving(body))
		body.put_in_hands(prize)

/datum/halloween_hunt/proc/award_winner(list/entry)
	var/datum/mind/owner = entry["mind"]
	var/mob/living/body = owner.current
	var/turf/drop = get_turf(body) || get_turf(entry["basket"])
	hand_prize(body, new /obj/item/clothing/head/hunt_pumpkin_crown(drop))
	var/datum/dungeon_progress/progress = get_dungeon_progress(entry["ckey"])
	if(progress)
		progress.grant_cosmetic(HUNT_TITLE_ID)
		progress.selected_title = HUNT_TITLE_ID
		progress.save_progress()
	if(!body)
		return
	if(ishuman(body))
		var/mob/living/carbon/human/winner = body
		winner.update_dungeon_title()
	to_chat(body, span_love("I am the Pumpkin Monarch! The crown is mine, and the title now follows my name."))
	to_chat(body, span_notice("To hide the title or wear another, use the abyssal delve gate, open the Delver's Ledger tab, and pick None under Titles."))

/datum/halloween_hunt/proc/award_runner_up(list/entry)
	var/datum/mind/owner = entry["mind"]
	var/mob/living/body = owner.current
	var/turf/drop = get_turf(body) || get_turf(entry["basket"])
	hand_prize(body, make_hunt_prize_lantern(drop))
	hand_prize(body, new /obj/item/coin/gold(drop, 5))
	if(body)
		to_chat(body, span_nicegreen("A runner-up of the Candy Hunt! A pumpkin lamptern and five gold coins are mine."))

#undef HUNT_TITLE_ID
#undef HUNT_TOPUP_INTERVAL
#undef HUNT_SCOREBOARD_INTERVAL
#undef HUNT_LEADER_INTERVAL
#undef HUNT_TOPUP_MAX
#undef HUNT_OUTSKIRTS_RANGE
#undef HUNT_OUTSKIRTS_SHARE
#undef HUNT_TOFFEE_CHANCE
#undef HUNT_DISTRACT_RANGE
