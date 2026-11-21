/**
 * Scenes: saved, reusable admin events.
 *
 * A scene is a list of steps run in order from an anchor tile (point A):
 *   spawn     - a group of objects and mobs, each at its own offset, all at once
 *   narrate   - text in chat and/or straight on the screen (pixel or normal font),
 *               to everyone in view, in the area, in the trigger, or to the whole world
 *   sound     - a sound file at the anchor
 *   doors     - open, close, lock or unlock every door within a range of the anchor
 *   teleport  - move one player, everyone in the area, or everyone near A to point B
 *   effect    - shake, ringing, darkness, blackout, flash, stun, knockdown, sleep, heal, damage
 *               (brute, burn, toxin, suffocation), buff / debuff (any status effect), private
 *               message: to the same kinds of targets
 *   explosion - an explosion at point A (with an offset) or on each target, sizes clamped below
 *   wait      - pause before the next step (timers inside a scene)
 *   cleanup   - delete everything this run has spawned so far
 *
 * Spawn groups are built from a searchable object list, or captured from the map: build the
 * scene with build mode, then "Capture" turns everything around the admin into one spawn step.
 *
 * A scene runs right away at the admin's position, after a delay, or from a trigger: an invisible
 * marker (admins and ghosts see it) that fires when someone comes within its radius. Teleport steps
 * of a triggered scene draw a line from the trigger to their point B.
 *
 * Scenes are personal: each admin sees their own, plus the ones other admins marked as shared.
 * Shared scenes of others can be run, triggered and duplicated, but only their owner edits them.
 * Scenes saved before owners existed have no owner: they count as shared and anyone may edit them.
 * Everything is saved to data/admin_scenes.json, so it survives restarts. Triggers and running
 * scenes only last for the round.
 */

#define SCENES_FILE "data/admin_scenes.json"
#define SCENE_MAX_STEPS 60
#define SCENE_MAX_SCENES 200
#define SCENE_MAX_ITEMS 100
/// An explosion step "on each target" blows up at most this many of them.
#define SCENE_MAX_EXPLOSIONS 10

/// id -> scene: list("id", "name", "steps" = list(step lists)).
GLOBAL_LIST_EMPTY(admin_scenes)
GLOBAL_VAR_INIT(admin_scenes_loaded, FALSE)
/// Live /obj/effect/scene_trigger markers.
GLOBAL_LIST_EMPTY(scene_triggers)
/// Running /datum/admin_scene_run.
GLOBAL_LIST_EMPTY(scene_runs)

/// Storage --------------------------------------------------------------------------------------

/proc/load_admin_scenes()
	if(GLOB.admin_scenes_loaded)
		return GLOB.admin_scenes
	GLOB.admin_scenes_loaded = TRUE
	GLOB.admin_scenes = list()
	if(!fexists(SCENES_FILE))
		return GLOB.admin_scenes
	var/list/saved = safe_json_decode(file2text(SCENES_FILE))
	if(!islist(saved))
		return GLOB.admin_scenes
	for(var/list/scene in saved)
		if(!islist(scene) || !istext(scene["id"]))
			continue
		var/list/clean_steps = list()
		for(var/list/step in scene["steps"])
			var/list/clean = sanitize_scene_step(step)
			if(clean)
				clean_steps += list(clean)
		var/owner = istext(scene["owner"]) && length(scene["owner"]) ? ckey(scene["owner"]) : null
		GLOB.admin_scenes[scene["id"]] = list(
			"id" = scene["id"],
			"name" = copytext_char("[scene["name"]]", 1, 61),
			"owner" = owner,
			"shared" = owner ? !!scene["shared"] : TRUE,
			"steps" = clean_steps,
		)
	return GLOB.admin_scenes

/// Can this admin see (run, trigger, duplicate) the scene?
/proc/scene_visible_to(list/scene, ckey)
	return scene && (scene["shared"] || !scene["owner"] || scene["owner"] == ckey)

/// Can this admin change the scene? Only its owner; scenes without an owner are open to all.
/proc/scene_editable_by(list/scene, ckey)
	return scene && (!scene["owner"] || scene["owner"] == ckey)

/// Writes every scene to disk and redraws the trigger lines of scene_id.
/proc/save_admin_scenes(scene_id)
	var/list/out = list()
	for(var/id in GLOB.admin_scenes)
		out += list(GLOB.admin_scenes[id])
	if(fexists(SCENES_FILE))
		fdel(SCENES_FILE)
	text2file(json_encode(out), SCENES_FILE)
	if(scene_id)
		for(var/obj/effect/scene_trigger/trigger as anything in GLOB.scene_triggers)
			if(trigger.scene_id == scene_id)
				trigger.refresh_links()

/// Steps ----------------------------------------------------------------------------------------

/proc/new_scene_step(step_type)
	switch(step_type)
		if("spawn")
			return list("type" = "spawn", "items" = list())
		if("narrate")
			return list(
				"type" = "narrate", "text" = "", "scope" = "view", "range" = 7, "style" = "plain",
				"display" = "chat", "font" = "pixel", "size" = 16, "color" = "#eee69c",
				"position" = "top", "duration" = 5, "animation" = "fade",
			)
		if("sound")
			return list("type" = "sound", "path" = "", "volume" = 80, "range" = 0)
		if("doors")
			return list("type" = "doors", "action" = "open", "range" = 3)
		if("teleport")
			return list(
				"type" = "teleport", "who" = "near", "range" = 3, "player" = "", "include" = "players",
				"dest" = "offset", "dx" = 0, "dy" = 5, "x" = 1, "y" = 1, "z" = 1, "scatter" = 1, "message" = "",
			)
		if("effect")
			return list(
				"type" = "effect", "effect" = "shake", "who" = "near", "range" = 5, "player" = "",
				"include" = "players", "seconds" = 3, "strength" = 1, "status" = "", "text" = "", "style" = "plain",
				"damage" = 20, "damage_type" = BRUTE,
			)
		if("explosion")
			// Ranges as explosion() takes them: a tile counts when its distance is below the range,
			// so 0 is none and 1 is the centre tile only.
			return list(
				"type" = "explosion", "where" = "a", "dx" = 0, "dy" = 0,
				"who" = "near", "range" = 5, "player" = "", "include" = "players",
				"devastation" = 0, "heavy" = 1, "light" = 3, "flash" = 4, "flame" = 0,
			)
		if("wait")
			return list("type" = "wait", "seconds" = 5)
		if("cleanup")
			return list("type" = "cleanup")
	return null

/// Effect id -> label, in menu order.
/proc/admin_scene_effects()
	var/static/list/effects = list(
		"shake" = "Screen shake",
		"ring" = "Ear ringing",
		"darken" = "Darkness",
		"blackout" = "Blackout",
		"flash" = "Flash",
		"stun" = "Stun",
		"knockdown" = "Knockdown",
		"sleep" = "Sleep",
		"heal" = "Full heal",
		"damage" = "Damage",
		"buff" = "Apply buff / debuff",
		"unbuff" = "Remove buff / debuff",
		"message" = "Private message",
	)
	return effects

/// Accepts only known step types and fields, with every value clamped to a sane range.
/proc/sanitize_scene_step(list/raw)
	if(!islist(raw))
		return null
	var/list/step = new_scene_step(raw["type"])
	if(!step)
		return null
	if(step["type"] == "spawn")
		var/list/raw_items = raw["items"]
		if(!islist(raw_items) && raw["path"]) // scenes saved before spawn groups: one object per step
			raw_items = list(list("path" = raw["path"], "dx" = raw["dx"], "dy" = raw["dy"], "dir" = raw["dir"], "amount" = raw["amount"]))
		var/list/items = step["items"]
		for(var/list/raw_item in raw_items)
			var/list/item = sanitize_spawn_item(raw_item)
			if(item && length(items) < SCENE_MAX_ITEMS)
				items += list(item)
		return step
	for(var/field in step)
		if(field == "type" || isnull(raw[field]))
			continue
		step[field] = sanitize_scene_value(step["type"], field, raw[field])
	return step

/proc/sanitize_spawn_item(list/raw)
	if(!islist(raw) || !scene_spawn_type(raw["path"]))
		return null
	return list(
		"path" = "[scene_spawn_type(raw["path"])]",
		"dx" = sanitize_scene_value("spawn", "dx", raw["dx"]),
		"dy" = sanitize_scene_value("spawn", "dy", raw["dy"]),
		"dir" = sanitize_scene_value("spawn", "dir", raw["dir"]),
		"amount" = sanitize_scene_value("spawn", "amount", raw["amount"]),
	)

/proc/sanitize_scene_value(step_type, field, value)
	switch(field)
		if("path")
			return copytext_char(trim("[value]"), 1, 201)
		if("text", "message")
			return copytext_char("[value]", 1, 2001)
		if("player")
			return ckey("[value]")
		if("amount")
			return clamp(round(text2num("[value]") || 1), 1, 50)
		if("dx", "dy")
			return clamp(round(text2num("[value]") || 0), -30, 30)
		if("x")
			return clamp(round(text2num("[value]") || 1), 1, world.maxx)
		if("y")
			return clamp(round(text2num("[value]") || 1), 1, world.maxy)
		if("z")
			return clamp(round(text2num("[value]") || 1), 1, world.maxz)
		if("dir")
			var/new_dir = text2num("[value]")
			return (new_dir in GLOB.alldirs) ? new_dir : SOUTH
		if("range")
			return clamp(round(text2num("[value]") || 0), 0, step_type == "narrate" ? 30 : 15)
		if("scatter")
			return clamp(round(text2num("[value]") || 0), 0, 5)
		if("strength")
			return clamp(round(text2num("[value]") || 1), 1, 5)
		if("volume")
			return clamp(round(text2num("[value]") || 80), 1, 100)
		if("seconds")
			if(step_type == "wait")
				return clamp(text2num("[value]") || 1, 0.5, 900)
			return clamp(text2num("[value]") || 0, 0, 600)
		if("scope")
			return (value in list("view", "area", "trigger", "world")) ? value : "view"
		if("display")
			return (value in list("chat", "screen", "both")) ? value : "chat"
		if("font")
			return (value in list("pixel", "normal")) ? value : "pixel" // older scenes may still say "retrogression"
		if("size")
			return clamp(round(text2num("[value]") || 16), 8, 48)
		if("color")
			var/static/regex/hex_color = regex(@"^#[0-9a-fA-F]{6}$")
			return hex_color.Find("[value]") ? LOWER_TEXT("[value]") : "#eee69c"
		if("position")
			return (value in list("top", "center", "bottom")) ? value : "top"
		if("duration")
			return clamp(text2num("[value]") || 5, 1, 60)
		if("animation")
			return value == "type" ? "type" : "fade"
		if("style")
			return (value in list("plain", "notice", "warning", "big")) ? value : "plain"
		if("action")
			return (value in list("open", "close", "lock", "unlock")) ? value : "open"
		if("who")
			return (value in list("near", "trigger", "area", "player", "everyone")) ? value : "near"
		if("include")
			return value == "living" ? "living" : "players"
		if("dest")
			return value == "fixed" ? "fixed" : "offset"
		if("effect")
			return admin_scene_effects()[value] ? value : "shake"
		if("status")
			var/status_type = text2path("[value]")
			return admin_scene_status_effects_by_type()[status_type] ? "[status_type]" : ""
		if("damage")
			return clamp(round(text2num("[value]") || 0), 1, 200)
		if("damage_type")
			return (value in list(BRUTE, BURN, TOX, OXY)) ? value : BRUTE
		if("where")
			return value == "targets" ? "targets" : "a"
		// Explosion sizes stay in the range of a scene, not a station-wide bomb.
		if("devastation")
			return clamp(round(text2num("[value]") || 0), 0, 3)
		if("heavy")
			return clamp(round(text2num("[value]") || 0), 0, 5)
		if("light")
			return clamp(round(text2num("[value]") || 0), 0, 7)
		if("flash")
			return clamp(round(text2num("[value]") || 0), 0, 10)
		if("flame")
			return clamp(round(text2num("[value]") || 0), 0, 7)
	return value

/// What a spawn may create: real objects and living mobs, nothing abstract.
/proc/scene_spawn_type(path_text)
	var/datum/target_type = text2path("[path_text]")
	if(!ispath(target_type, /obj) && !ispath(target_type, /mob/living))
		return null
	if(IS_ABSTRACT(target_type) || ispath(target_type, /obj/abstract) || ispath(target_type, /atom/movable/screen))
		return null
	return target_type

/// Buffs and debuffs: list of list("type", "name", "desc", "kind", "duration"), built once.
/proc/admin_scene_status_effects()
	var/static/list/effects
	if(effects)
		return effects
	effects = list()
	for(var/datum/status_effect/effect_type as anything in subtypesof(/datum/status_effect/buff) + subtypesof(/datum/status_effect/debuff))
		if(IS_ABSTRACT(effect_type))
			continue
		var/atom/movable/screen/alert/status_effect/alert_type = initial(effect_type.alert_type)
		var/name = alert_type ? "[initial(alert_type.name)]" : ""
		if(!length(name))
			name = "[initial(effect_type.id)]"
		var/duration = initial(effect_type.duration)
		effects += list(list(
			"type" = "[effect_type]",
			"name" = name,
			"desc" = alert_type ? "[initial(alert_type.desc)]" : "",
			"kind" = ispath(effect_type, /datum/status_effect/buff) ? "buff" : "debuff",
			"duration" = duration > 0 ? duration / 10 : -1,
		))
	sortTim(effects, GLOBAL_PROC_REF(cmp_scene_status_effects))
	return effects

/proc/cmp_scene_status_effects(list/a, list/b)
	return sorttext(b["name"], a["name"])

/// type -> TRUE, for validation.
/proc/admin_scene_status_effects_by_type()
	var/static/list/by_type
	if(by_type)
		return by_type
	by_type = list()
	for(var/list/entry as anything in admin_scene_status_effects())
		by_type[text2path(entry["type"])] = TRUE
	return by_type

/// Who a teleport or effect step reaches. "trigger" means everyone within the radius of the
/// trigger that started this run (the step's own range when the scene was started by hand).
/proc/scene_targets(list/step, turf/anchor, datum/admin_scene_run/run)
	var/list/found = list()
	switch(step["who"])
		if("near")
			for(var/mob/living/candidate in range(step["range"], anchor))
				found += candidate
		if("trigger")
			if(run?.focus_ref) // set off by one player of an "each player" trigger: only them
				var/mob/living/focus = run.focus_ref.resolve()
				if(istype(focus) && !QDELETED(focus))
					found += focus
			else
				var/radius = isnull(run?.trigger_radius) ? step["range"] : run.trigger_radius
				for(var/mob/living/candidate in range(radius, anchor))
					found += candidate
		if("area")
			// Walk the mob lists, not the area: an outdoor area spans most of the map, and its
			// contents are every turf and every object on it.
			var/area/place = get_area(anchor)
			for(var/mob/living/candidate in (step["include"] == "players" ? GLOB.player_list : GLOB.mob_living_list))
				if(get_area(candidate) == place)
					found += candidate
		if("player")
			var/mob/living/candidate = get_mob_by_ckey(step["player"])
			if(istype(candidate))
				found += candidate
		if("everyone")
			for(var/mob/living/candidate in GLOB.player_list)
				found += candidate
	var/list/targets = list()
	for(var/mob/living/candidate as anything in found)
		if(candidate.stat == DEAD)
			continue
		if(step["include"] == "players" && !candidate.client)
			continue
		targets += candidate
	return targets

/// Point B of a teleport step, seen from anchor (point A).
/proc/scene_teleport_destination(list/step, turf/anchor)
	if(step["dest"] == "fixed")
		return locate(step["x"], step["y"], step["z"])
	if(!anchor)
		return null
	return locate(anchor.x + step["dx"], anchor.y + step["dy"], anchor.z)

/// Runner ---------------------------------------------------------------------------------------

/datum/admin_scene_run
	var/scene_name
	var/list/steps
	var/turf/anchor
	var/started_by
	/// What this run spawned and is still in the world, for the cleanup step. Watched with
	/// COMSIG_PARENT_QDELETING, not weakrefs: a big spawn group would mint a REF() text per object
	/// in creation order, the pattern that makes BYOND stop and re-sort its whole string table.
	var/list/spawned = list()
	var/stopped = FALSE
	var/current_step = 0
	/// Radius of the trigger that started this run; null when an admin started it.
	var/trigger_radius
	/// The one player this run is for, when an "each player" trigger started it. Steps aimed at
	/// "In trigger" (targets, narration) reach only them; every other target works as usual.
	var/datum/weakref/focus_ref

/datum/admin_scene_run/New(list/scene, turf/anchor, started_by, trigger_radius, mob/living/focus)
	scene_name = scene["name"]
	steps = deepCopyList(scene["steps"])
	src.anchor = anchor
	src.started_by = started_by
	src.trigger_radius = trigger_radius
	if(focus)
		focus_ref = WEAKREF(focus)
	GLOB.scene_runs += src

/datum/admin_scene_run/Destroy()
	GLOB.scene_runs -= src
	anchor = null
	spawned = null // the parent unregisters the deletion watch on what is left
	return ..()

/datum/admin_scene_run/proc/forget_spawned(atom/movable/source)
	SIGNAL_HANDLER
	spawned -= source

/datum/admin_scene_run/proc/start(delay = 0)
	set waitfor = FALSE
	if(delay > 0)
		sleep(delay)
	log_admin("Scene \"[scene_name]\" started by [started_by] at [AREACOORD(anchor)].")
	for(var/index in 1 to length(steps))
		if(stopped || QDELETED(src) || !anchor)
			break
		current_step = index
		var/list/step = steps[index]
		if(step["type"] == "wait")
			sleep(step["seconds"] SECONDS)
			continue
		try
			run_step(step)
		catch(var/exception/error)
			log_runtime("Scene \"[scene_name]\" step [index] ([step["type"]]): [error] at [error.file]:[error.line]")
			message_admins(span_adminnotice("Scene \"[scene_name]\": step [index] ([step["type"]]) failed, see the runtime log."))
	if(!QDELETED(src))
		qdel(src)

/datum/admin_scene_run/proc/run_step(list/step)
	switch(step["type"])
		if("spawn")
			for(var/list/item as anything in step["items"])
				var/target_type = scene_spawn_type(item["path"])
				var/turf/where = locate(anchor.x + item["dx"], anchor.y + item["dy"], anchor.z)
				if(!target_type || !where)
					continue
				for(var/i in 1 to item["amount"])
					var/atom/movable/made = new target_type(where)
					if(!QDELETED(made))
						made.flags_1 |= ADMIN_SPAWNED_1
						made.setDir(item["dir"])
						spawned += made
						RegisterSignal(made, COMSIG_PARENT_QDELETING, PROC_REF(forget_spawned), override = TRUE)
					// A step can make up to SCENE_MAX_ITEMS x 50 objects: spread them over ticks.
					CHECK_TICK
					if(stopped || QDELETED(src))
						return
		if("narrate")
			if(!length(step["text"]))
				return
			var/list/listeners = list()
			switch(step["scope"])
				if("world")
					listeners = GLOB.player_list.Copy()
				if("area")
					var/area/place = get_area(anchor)
					for(var/mob/listener in GLOB.player_list)
						if(get_area(listener) == place)
							listeners += listener
				if("trigger")
					if(focus_ref) // an "each player" trigger: only the player who set it off
						var/mob/focus = focus_ref.resolve()
						if(focus?.client)
							listeners += focus
					else
						var/radius = isnull(trigger_radius) ? step["range"] : trigger_radius
						for(var/mob/living/listener in range(radius, anchor))
							if(listener.client)
								listeners += listener
				else
					for(var/mob/listener in view(step["range"], anchor))
						listeners += listener
			if(step["display"] != "screen")
				var/text = scene_styled_text(step["text"], step["style"])
				for(var/mob/listener as anything in listeners)
					to_chat(listener, text)
			if(step["display"] != "chat")
				for(var/mob/listener as anything in listeners)
					if(listener.client)
						scene_screen_text(listener.client, step)
		if("sound")
			var/sound_path = step["path"]
			if(!length(sound_path) || !fexists(sound_path))
				return
			playsound(anchor, file(sound_path), step["volume"], FALSE, step["range"])
		if("doors")
			for(var/obj/structure/door/door in range(step["range"], anchor))
				switch(step["action"])
					if("open")
						if(!door.door_opened)
							door.force_open()
					if("close")
						if(door.door_opened)
							door.force_closed()
					if("lock")
						door.lock()
					if("unlock")
						door.unlock()
		if("teleport")
			var/turf/destination = scene_teleport_destination(step, anchor)
			if(!destination)
				return
			var/list/landing = list(destination)
			if(step["scatter"])
				for(var/turf/spot in range(step["scatter"], destination))
					if(!spot.density && !spot.is_blocked_turf(TRUE))
						landing += spot
			for(var/mob/living/target as anything in scene_targets(step, anchor, src))
				target.stop_pulling()
				target.forceMove(pick(landing))
				if(length(step["message"]))
					to_chat(target, span_notice(step["message"]))
				log_admin("Scene \"[scene_name]\" teleported [key_name(target)] to [AREACOORD(destination)].")
		if("effect")
			var/list/targets = scene_targets(step, anchor, src)
			for(var/mob/living/target as anything in targets)
				scene_apply_effect(target, step)
			if(step["effect"] == "damage" && length(targets))
				log_admin("Scene \"[scene_name]\" dealt [step["damage"]] [step["damage_type"]] damage to [length(targets)] targets near [AREACOORD(anchor)].")
		if("explosion")
			var/list/centers = list()
			if(step["where"] == "targets")
				for(var/mob/living/target as anything in scene_targets(step, anchor, src))
					var/turf/spot = get_turf(target)
					if(spot)
						centers |= spot
					if(length(centers) >= SCENE_MAX_EXPLOSIONS)
						break
			else
				var/turf/center = locate(anchor.x + step["dx"], anchor.y + step["dy"], anchor.z)
				if(center)
					centers += center
			for(var/turf/center as anything in centers)
				// explosion() tells the admins and the game log itself; flame_range 0 means no fire, not "as light".
				explosion(center, step["devastation"], step["heavy"], step["light"], step["flash"], adminlog = TRUE, flame_range = step["flame"])
			if(length(centers))
				log_admin("Scene \"[scene_name]\" made [length(centers)] explosion(s) ([step["devastation"]], [step["heavy"]], [step["light"]], flash [step["flash"]], flame [step["flame"]]) from [AREACOORD(anchor)].")
		if("cleanup")
			var/list/made_list = spawned
			spawned = list()
			for(var/atom/movable/made as anything in made_list)
				UnregisterSignal(made, COMSIG_PARENT_QDELETING) // or every qdel below rescans the list
				if(!QDELETED(made))
					qdel(made)
				CHECK_TICK

/proc/scene_styled_text(text, style)
	if(!length(text))
		return null
	switch(style)
		if("notice")
			return span_notice(text)
		if("warning")
			return span_warning(text)
		if("big")
			return "<span class='big bold'>[text]</span>"
	return text

/proc/scene_apply_effect(mob/living/target, list/step)
	var/seconds = step["seconds"]
	switch(step["effect"])
		if("shake")
			shake_camera(target, max(seconds, 0.5) * 10, step["strength"])
		if("ring")
			var/sound/ringing = sound('sound/flash_ring.ogg')
			ringing.volume = 70
			target << ringing
		if("darken")
			scene_screen_overlay(target, "scene_darken", /atom/movable/screen/fullscreen/blind, seconds)
		if("blackout")
			scene_screen_overlay(target, "scene_blackout", /atom/movable/screen/fullscreen/blind/sleeper, seconds)
		if("flash")
			scene_screen_overlay(target, "scene_flash", /atom/movable/screen/fullscreen/flash, max(seconds, 0.5))
		if("stun")
			target.Paralyze(seconds SECONDS)
		if("knockdown")
			target.Knockdown(seconds SECONDS)
		if("sleep")
			target.Sleeping(seconds SECONDS)
		if("heal")
			target.fully_heal()
		if("damage")
			// Spread over the body and without critical wounds: an event hurts, it does not dismember.
			target.apply_damage(step["damage"], step["damage_type"], spread_damage = TRUE, can_crit = FALSE)
		if("buff")
			var/status_type = text2path(step["status"])
			if(status_type)
				target.apply_status_effect(status_type, seconds ? seconds SECONDS : null)
		if("unbuff")
			var/status_type = text2path(step["status"])
			if(status_type)
				target.remove_status_effect(status_type)
		if("message")
			var/text = scene_styled_text(step["text"], step["style"])
			if(text)
				to_chat(target, text)

/// Puts a full-screen overlay on target for some seconds.
/proc/scene_screen_overlay(mob/living/target, category, overlay_type, seconds)
	target.overlay_fullscreen(category, overlay_type)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, clear_fullscreen), category), max(seconds, 1) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Run a scene id at anchor. Returns the run, or null when the scene is unknown.
/// focus: the one player the run is for (an "each player" trigger), see /datum/admin_scene_run.
/proc/run_admin_scene(id, turf/anchor, started_by, delay = 0, trigger_radius, mob/living/focus)
	var/list/scene = load_admin_scenes()[id]
	if(!scene || !anchor)
		return null
	var/datum/admin_scene_run/run = new(scene, anchor, started_by, trigger_radius, focus)
	run.start(delay)
	return run

/// Screen text ----------------------------------------------------------------------------------

/client
	/// Scene texts on this client's screen: position -> /atom/movable/screen/scene_text.
	var/list/scene_screen_texts

/// Text shown in the middle of the screen by a narrate step.
/atom/movable/screen/scene_text
	icon = null
	maptext_width = 480
	maptext_height = 96
	alpha = 0
	plane = ABOVE_HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/client/viewer
	var/position

/atom/movable/screen/scene_text/Destroy()
	if(viewer)
		viewer.screen -= src
		if(viewer.scene_screen_texts?[position] == src)
			viewer.scene_screen_texts -= position
	viewer = null
	return ..()

/// The maptext of a screen text step, with its font, size and colour.
/// "pixel" is Pixelify Sans (SIL Open Font License), "normal" is the game's usual font.
/proc/scene_screen_maptext(list/step, text)
	var/family = step["font"] == "pixel" ? "'Pixelify Sans', 'Pterra', sans-serif" : "'Pterra', sans-serif"
	var/valign = step["position"] == "bottom" ? "bottom" : (step["position"] == "center" ? "middle" : "top")
	return {"<span style="font-family: [family]; font-size: [step["size"]]px; color: [step["color"]]; text-align: center; vertical-align: [valign]; -dm-text-outline: 2px black">[text]</span>"}

/// Shows the step's text on one client's screen. A newer text in the same position replaces the old one.
/proc/scene_screen_text(client/viewer, list/step)
	var/position = step["position"]
	LAZYINITLIST(viewer.scene_screen_texts)
	qdel(viewer.scene_screen_texts[position])
	var/atom/movable/screen/scene_text/shown = new()
	shown.viewer = viewer
	shown.position = position
	switch(position)
		if("center")
			shown.screen_loc = "CENTER-7,CENTER-1"
		if("bottom")
			shown.screen_loc = "CENTER-7,BOTTOM+2"
		else
			shown.screen_loc = "CENTER-7,TOP-3"
	viewer.scene_screen_texts[position] = shown
	viewer.screen += shown
	INVOKE_ASYNC(shown, TYPE_PROC_REF(/atom/movable/screen/scene_text, play), step)

/// Fades (or types) the text in, holds it, then fades it out and deletes it.
/atom/movable/screen/scene_text/proc/play(list/step)
	var/text = html_encode(step["text"])
	if(step["animation"] == "type")
		alpha = 255
		var/length = length_char(text)
		var/step_size = max(1, round(length / 40)) // long texts type faster, about four seconds at most
		for(var/shown_chars in 1 to length step step_size)
			if(QDELETED(src))
				return
			maptext = MAPTEXT(scene_screen_maptext(step, copytext_char(text, 1, shown_chars + 1)))
			sleep(1)
		maptext = MAPTEXT(scene_screen_maptext(step, text))
	else
		maptext = MAPTEXT(scene_screen_maptext(step, text))
		animate(src, alpha = 255, time = 0.5 SECONDS)
	if(QDELETED(src))
		return
	addtimer(CALLBACK(src, PROC_REF(fade_out)), step["duration"] SECONDS)

/atom/movable/screen/scene_text/proc/fade_out()
	animate(src, alpha = 0, time = 1 SECONDS)
	QDEL_IN(src, 1 SECONDS)

/// Trigger and its lines --------------------------------------------------------------------------

/obj/effect/scene_trigger
	name = "scene trigger"
	desc = "Admin scene trigger. Only admins and ghosts can see it."
	icon = 'icons/turf/overlays.dmi'
	icon_state = "greenOverlay"
	alpha = 110
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/scene_id
	var/radius = 1
	/// "once" fires one time then deletes itself; "repeat" fires again after the cooldown;
	/// "each" fires separately for every player who comes in range, the scene's "In trigger"
	/// steps reaching only that player, and again for the same player after the cooldown (0: never).
	var/mode = "once"
	/// Seconds. In "each" mode it counts per player.
	var/cooldown = 60
	/// "each" mode: ckey -> world.time the trigger last fired for that player, this round.
	var/list/fired_for
	/// Seconds between being set off and the scene starting.
	var/delay = 0
	/// "players" (mobs with a connected player) or "living" (any living mob).
	var/who = "players"
	var/armed = TRUE
	var/next_fire = 0
	var/placed_by
	var/fired = 0
	/// Watches the tiles within radius. Event driven: nothing runs until something moves in range.
	var/datum/proximity_monitor/watcher
	/// Lines and point B markers of the scene's teleports.
	var/list/links = list()

/obj/effect/scene_trigger/Initialize(mapload)
	. = ..()
	GLOB.scene_triggers += src

/obj/effect/scene_trigger/Destroy()
	GLOB.scene_triggers -= src
	QDEL_NULL(watcher)
	QDEL_LIST(links)
	return ..()

/obj/effect/scene_trigger/proc/scene_name()
	var/list/scene = load_admin_scenes()[scene_id]
	return scene ? scene["name"] : "(deleted scene)"

/// Starts (or resizes) the watch. Called once the radius is set.
/obj/effect/scene_trigger/proc/watch(new_radius)
	radius = new_radius
	if(watcher)
		watcher.set_range(radius)
	else
		watcher = new(src, radius)
	refresh_links()
	// Someone may already be standing in range when the trigger is placed. Each of them, in "each" mode.
	for(var/mob/living/candidate in range(radius, get_turf(src)))
		if(try_fire(candidate) && mode != "each")
			return

/// Redraws a line from this trigger (A) to the point B of every teleport in its scene.
/obj/effect/scene_trigger/proc/refresh_links()
	QDEL_LIST(links)
	var/list/scene = load_admin_scenes()[scene_id]
	var/turf/here = get_turf(src)
	if(!scene || !here)
		return
	for(var/list/step as anything in scene["steps"])
		if(step["type"] != "teleport")
			continue
		var/turf/destination = scene_teleport_destination(step, here)
		if(!destination)
			continue
		links += new /obj/effect/scene_marker(destination, scene["name"])
		if(destination.z == here.z && destination != here)
			links += new /obj/effect/scene_link(here, here, destination)

/obj/effect/scene_trigger/HasProximity(atom/movable/arrived)
	if(isliving(arrived))
		try_fire(arrived)

/// Fires when the mob qualifies and the trigger is ready. Returns TRUE when it fired.
/obj/effect/scene_trigger/proc/try_fire(mob/living/candidate)
	if(!armed || QDELETED(src) || candidate.stat == DEAD)
		return FALSE
	if(mode == "each")
		// Every player on their own: no shared cooldown, only this player's last time.
		if(!candidate.ckey || !candidate.client)
			return FALSE
		var/last = fired_for?[candidate.ckey]
		if(!isnull(last) && (!cooldown || world.time < last + cooldown SECONDS))
			return FALSE
		LAZYSET(fired_for, candidate.ckey, world.time)
		INVOKE_ASYNC(src, PROC_REF(fire), candidate)
		return TRUE
	if(world.time < next_fire || (who == "players" && !candidate.client))
		return FALSE
	next_fire = world.time + cooldown SECONDS // blocks repeats while the scene starts
	INVOKE_ASYNC(src, PROC_REF(fire), candidate)
	return TRUE

/obj/effect/scene_trigger/proc/fire(mob/living/cause)
	fired++
	log_admin("Scene trigger \"[scene_name()]\" at [AREACOORD(src)] set off by [cause ? key_name(cause) : "an admin"].")
	if(cause)
		message_admins(span_adminnotice("Scene \"[scene_name()]\" was triggered by [key_name_admin(cause)] at [ADMIN_VERBOSEJMP(src)][mode == "each" ? " (for this player only)" : ""]."))
	// An "each player" trigger set off by a player runs the scene for that player alone.
	var/mob/living/focus = (mode == "each") ? cause : null
	run_admin_scene(scene_id, get_turf(src), "trigger placed by [placed_by]", delay SECONDS, radius, focus)
	if(mode == "once")
		qdel(src)
		return
	if(mode == "repeat")
		next_fire = world.time + cooldown SECONDS

/// Line from a trigger to a teleport's point B. Seen only by admins and ghosts.
/obj/effect/scene_link
	name = "teleport line"
	icon = 'icons/misc/mark.dmi'
	icon_state = "line"
	color = "#e6c35c"
	alpha = 200
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/scene_link/Initialize(mapload, atom/from, atom/to_atom)
	. = ..()
	if(!from || !to_atom)
		return INITIALIZE_HINT_QDEL
	var/x_offset = (to_atom.x - from.x) * world.icon_size
	var/y_offset = (to_atom.y - from.y) * world.icon_size
	var/matrix/line = matrix()
	line.Translate(0, 16)
	line.Scale(1, sqrt((x_offset * x_offset) + (y_offset * y_offset)) / world.icon_size)
	line.Turn(90 - ATAN2(x_offset, y_offset))
	transform = line

/// Point B of a teleport. Seen only by admins and ghosts.
/obj/effect/scene_marker
	name = "teleport destination"
	icon = 'icons/turf/overlays.dmi'
	icon_state = "redOverlay"
	alpha = 130
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/scene_marker/Initialize(mapload, scene_name)
	. = ..()
	name = "teleport destination: [scene_name]"

/// Editor window --------------------------------------------------------------------------------

/datum/admin_scene_editor
	var/owner_ckey
	var/selected_id
	/// Last object search: query and results for the spawn picker.
	var/search_query = ""
	var/list/search_results = list()
	/// Feedback line shown in the window.
	var/status
	/// Images of the current preview, shown only to this admin.
	var/list/preview_images
	var/client/preview_client

/datum/admin_scene_editor/New(client/owner)
	owner_ckey = owner?.ckey

/datum/admin_scene_editor/Destroy()
	clear_preview()
	return ..()

/datum/admin_scene_editor/ui_state(mob/user)
	return GLOB.always_state

/datum/admin_scene_editor/ui_status(mob/user, datum/ui_state/state)
	if(user?.ckey != owner_ckey || !check_rights_for(user.client, R_FUN))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/admin_scene_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminScenes", "Scenes")
		ui.set_autoupdate(FALSE) // actions refresh it fully; live_pulse() sends triggers and running scenes every 5 seconds
		ui.open()
		addtimer(CALLBACK(src, PROC_REF(live_pulse)), 5 SECONDS, TIMER_UNIQUE)

/**
 * Every 5 seconds: only what changes without the admin doing anything (triggers, running scenes,
 * players, where the admin stands). The scenes themselves, up to SCENE_MAX_STEPS steps of
 * SCENE_MAX_ITEMS objects each, only change through actions, and those send everything.
 * The window keeps the keys this update leaves out.
 */
/datum/admin_scene_editor/proc/live_pulse()
	if(!LAZYLEN(open_uis))
		return
	for(var/datum/tgui/ui as anything in open_uis)
		ui.send_update(live_data(ui.user))
	addtimer(CALLBACK(src, PROC_REF(live_pulse)), 5 SECONDS, TIMER_UNIQUE)

/datum/admin_scene_editor/proc/live_data(mob/user)
	var/list/trigger_list = list()
	for(var/obj/effect/scene_trigger/trigger as anything in GLOB.scene_triggers)
		trigger_list += list(list(
			"ref" = REF(trigger),
			"scene" = trigger.scene_name(),
			"where" = "[get_area_name(trigger, TRUE)] ([trigger.x], [trigger.y], [trigger.z])",
			"radius" = trigger.radius,
			"mode" = trigger.mode,
			"cooldown" = trigger.cooldown,
			"players" = LAZYLEN(trigger.fired_for),
			"armed" = trigger.armed,
			"fired" = trigger.fired,
		))
	var/list/run_list = list()
	for(var/datum/admin_scene_run/run as anything in GLOB.scene_runs)
		run_list += list(list("ref" = REF(run), "scene" = run.scene_name, "step" = run.current_step, "steps" = length(run.steps)))
	var/list/players = list()
	for(var/mob/living/player in GLOB.player_list)
		players += list(list("ckey" = player.ckey, "name" = "[player.real_name || player.name]"))
	var/turf/here = get_turf(user)
	var/datum/buildmode/build_mode = user?.client?.click_intercept
	return list(
		"triggers" = trigger_list,
		"runs" = run_list,
		"players" = players,
		"build_selection" = istype(build_mode) && build_mode.selected_item ? "[build_mode.selected_item]" : null,
		"here" = here ? list(here.x, here.y, here.z) : null,
	)

/datum/admin_scene_editor/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/admin_scene_editor/ui_static_data(mob/user)
	var/list/effect_options = list()
	var/list/labels = admin_scene_effects()
	for(var/id in labels)
		effect_options += list(list("id" = id, "name" = labels[id]))
	return list(
		"effects" = effect_options,
		"status_effects" = admin_scene_status_effects(),
		"max_steps" = SCENE_MAX_STEPS,
		"max_items" = SCENE_MAX_ITEMS,
	)

/datum/admin_scene_editor/ui_data(mob/user)
	var/list/scenes = load_admin_scenes()
	var/list/scene_list = list()
	for(var/id in scenes)
		var/list/scene = scenes[id]
		if(!scene_visible_to(scene, user.ckey))
			continue
		scene_list += list(list(
			"id" = id,
			"name" = scene["name"],
			"steps" = length(scene["steps"]),
			"owner" = scene["owner"],
			"shared" = !!scene["shared"],
			"mine" = scene["owner"] == user.ckey,
		))
	if(selected_id && !scene_visible_to(scenes[selected_id], user.ckey))
		selected_id = null
	// Icons of the objects in the selected scene's spawn groups, for the editor.
	var/list/icons = list()
	if(selected_id)
		for(var/list/step as anything in scenes[selected_id]["steps"])
			if(step["type"] != "spawn")
				continue
			for(var/list/item as anything in step["items"])
				if(icons[item["path"]])
					continue
				var/atom/item_type = text2path(item["path"])
				if(item_type)
					icons[item["path"]] = list("[initial(item_type.icon)]", "[initial(item_type.icon_state)]", "[initial(item_type.name)]")
	var/list/data = live_data(user)
	data["icons"] = icons
	data["scenes"] = scene_list
	data["selected"] = selected_id ? scenes[selected_id] : null
	data["can_edit"] = selected_id ? scene_editable_by(scenes[selected_id], user.ckey) : FALSE
	data["search_query"] = search_query
	data["search_results"] = search_results
	data["status"] = status
	return data

/// Searches the spawn catalogue (the same list build mode uses) for the object picker.
/datum/admin_scene_editor/proc/search_objects(query)
	search_query = copytext_char(trim("[query]"), 1, 61)
	search_results = list()
	var/list/terms = splittext(LOWER_TEXT(search_query), " ")
	terms -= ""
	if(!length(terms))
		return
	if(!buildmode_catalog_ready()) // building it here in one go would freeze the server
		status = "The object list is still loading. Search again in a few seconds."
		return
	var/list/entries = buildmode_catalog_entries()
	var/list/search_text = buildmode_catalog_index()["search_text"]
	for(var/path in entries)
		var/haystack = search_text[path]
		var/found = TRUE
		for(var/term in terms)
			if(!findtextEx(haystack, term))
				found = FALSE
				break
		if(!found || !scene_spawn_type(path))
			continue
		var/list/entry = entries[path]
		search_results += list(list("path" = entry["path"], "name" = entry["name"], "icon" = entry["icon"], "icon_state" = entry["icon_state"]))
		if(length(search_results) >= 40)
			break

/// Turns everything around center into spawn items with offsets from center.
/datum/admin_scene_editor/proc/capture_area(turf/center, radius, mob/user)
	var/list/counts = list()
	var/list/order = list()
	for(var/atom/movable/thing in range(radius, center))
		if(thing == user || !scene_spawn_type(thing.type))
			continue
		if(isobj(thing))
			if(istype(thing, /obj/effect) || thing.invisibility >= INVISIBILITY_ABSTRACT)
				continue
		else if(isliving(thing))
			var/mob/living/creature = thing
			if(creature.ckey || creature.client)
				continue
		else
			continue
		var/key = "[thing.type]|[thing.x - center.x]|[thing.y - center.y]|[thing.dir]"
		if(!counts[key])
			order += key
			counts[key] = list("path" = "[thing.type]", "dx" = thing.x - center.x, "dy" = thing.y - center.y, "dir" = thing.dir, "amount" = 0)
		var/list/item = counts[key]
		item["amount"] = min(item["amount"] + 1, 50)
	var/list/items = list()
	for(var/key in order)
		if(length(items) >= SCENE_MAX_ITEMS)
			break
		var/list/item = sanitize_spawn_item(counts[key])
		if(item)
			items += list(item)
	return items

/// Shows where the scene would put things, around the admin, for a few seconds.
/datum/admin_scene_editor/proc/show_preview(list/scene, mob/user)
	clear_preview()
	var/turf/anchor = get_turf(user)
	if(!anchor || !user.client)
		return 0
	preview_client = user.client
	preview_images = list()
	for(var/list/step as anything in scene["steps"])
		if(step["type"] == "spawn")
			for(var/list/item as anything in step["items"])
				var/atom/target_type = scene_spawn_type(item["path"])
				var/turf/where = locate(anchor.x + item["dx"], anchor.y + item["dy"], anchor.z)
				if(!target_type || !where)
					continue
				var/image/ghost = image(initial(target_type.icon), where, initial(target_type.icon_state), dir = item["dir"])
				ghost.alpha = 150
				ghost.color = "#7de6d5"
				ghost.plane = ABOVE_LIGHTING_PLANE
				preview_images += ghost
		else if(step["type"] == "teleport")
			var/turf/destination = scene_teleport_destination(step, anchor)
			if(destination)
				var/image/marker = image('icons/turf/overlays.dmi', destination, "redOverlay")
				marker.plane = ABOVE_LIGHTING_PLANE
				preview_images += marker
		else if(step["type"] == "explosion" && step["where"] != "targets")
			var/turf/center = locate(anchor.x + step["dx"], anchor.y + step["dy"], anchor.z)
			if(!center)
				continue
			var/image/core = image('icons/turf/overlays.dmi', center, "redOverlay")
			core.plane = ABOVE_LIGHTING_PLANE
			preview_images += core
			// The ring of the farthest tiles it damages: explosion() measures a round distance and
			// hits a tile while that distance is below the range.
			var/reach = max(step["devastation"], step["heavy"], step["light"])
			if(reach > 1)
				for(var/turf/spot as anything in RANGE_TURFS(reach, center))
					var/distance = cheap_hypotenuse(spot.x, spot.y, center.x, center.y)
					if(distance < reach - 1 || distance >= reach)
						continue
					var/image/edge = image('icons/turf/overlays.dmi', spot, "redOverlay")
					edge.alpha = 90
					edge.plane = ABOVE_LIGHTING_PLANE
					preview_images += edge
	preview_client.images += preview_images
	addtimer(CALLBACK(src, PROC_REF(clear_preview)), 10 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	return length(preview_images)

/datum/admin_scene_editor/proc/clear_preview()
	if(preview_client && length(preview_images))
		preview_client.images -= preview_images
	preview_images = null
	preview_client = null

/datum/admin_scene_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	var/list/scenes = load_admin_scenes()
	var/list/scene = scenes[params["id"] || selected_id]
	if(!scene_visible_to(scene, user.ckey))
		scene = null
	status = null
	// Changing a scene needs ownership; seeing a shared one is not enough.
	var/static/list/edit_actions = list(
		"delete_scene", "rename", "toggle_shared", "add_step", "capture",
		"edit_step", "move_step", "remove_step", "add_item", "edit_item", "remove_item", "set_dest_here",
	)
	if(scene && (action in edit_actions) && !scene_editable_by(scene, user.ckey))
		status = "This scene belongs to [scene["owner"]]. Duplicate it to make your own copy."
		return TRUE
	switch(action)
		if("select")
			if(scene_visible_to(scenes[params["id"]], user.ckey))
				selected_id = params["id"]
			return TRUE
		if("toggle_shared")
			if(!scene)
				return FALSE
			scene["owner"] = scene["owner"] || user.ckey // claiming an old ownerless scene makes it yours
			scene["shared"] = !scene["shared"]
			log_admin("[key_name(user)] made the scene \"[scene["name"]]\" [scene["shared"] ? "shared with all admins" : "private"].")
			save_admin_scenes(scene["id"])
			return TRUE
		if("new_scene", "duplicate")
			if(length(scenes) >= SCENE_MAX_SCENES)
				return TRUE
			var/id = "scene_[world.realtime]_[rand(1000, 9999)]"
			var/list/made = list("id" = id, "name" = "New scene", "owner" = user.ckey, "shared" = FALSE, "steps" = list())
			if(action == "duplicate" && scene)
				made["name"] = copytext_char("[scene["name"]] (copy)", 1, 61)
				made["steps"] = deepCopyList(scene["steps"])
			scenes[id] = made
			selected_id = id
			save_admin_scenes()
			return TRUE
		if("delete_scene")
			if(!scene)
				return FALSE
			scenes -= scene["id"]
			log_admin("[key_name(user)] deleted the scene \"[scene["name"]]\".")
			save_admin_scenes(scene["id"])
			return TRUE
		if("rename")
			if(!scene || !istext(params["name"]))
				return FALSE
			scene["name"] = copytext_char(trim(params["name"]), 1, 61) || "Unnamed scene"
			save_admin_scenes(scene["id"])
			return TRUE
		if("add_step")
			if(!scene || length(scene["steps"]) >= SCENE_MAX_STEPS)
				return FALSE
			var/list/step = new_scene_step(params["type"])
			if(!step)
				return FALSE
			scene["steps"] += list(step)
			save_admin_scenes(scene["id"])
			return TRUE
		if("catalog_search")
			search_objects(params["query"])
			return TRUE
		if("capture")
			if(!scene || length(scene["steps"]) >= SCENE_MAX_STEPS)
				return FALSE
			var/list/items = capture_area(get_turf(user), clamp(round(text2num("[params["radius"]]") || 0), 0, 7), user)
			if(!length(items))
				status = "Nothing to capture around you."
				return TRUE
			var/list/step = new_scene_step("spawn")
			step["items"] = items
			scene["steps"] += list(step)
			save_admin_scenes(scene["id"])
			status = "Captured [length(items)] objects into a new spawn step. Offsets are from where you stood."
			return TRUE
		if("preview")
			if(!scene)
				return FALSE
			var/shown = show_preview(scene, user)
			status = shown ? "Preview around you for 10 seconds ([shown] markers)." : "Nothing to preview."
			return TRUE

	// Everything below edits one step of the selected scene.
	if(action in list("edit_step", "move_step", "remove_step", "add_item", "edit_item", "remove_item", "set_dest_here"))
		if(!scene)
			return FALSE
		var/list/steps = scene["steps"]
		var/index = text2num("[params["index"]]")
		if(!isnum(index) || index < 1 || index > length(steps))
			return FALSE
		var/list/step = steps[index]
		switch(action)
			if("remove_step")
				steps.Cut(index, index + 1)
			if("move_step")
				var/other = index + (params["direction"] == "up" ? -1 : 1)
				if(other < 1 || other > length(steps))
					return FALSE
				steps.Swap(index, other)
			if("edit_step")
				var/field = params["field"]
				if(field == "type" || field == "items" || !(field in step))
					return FALSE
				step[field] = sanitize_scene_value(step["type"], field, params["value"])
			if("set_dest_here")
				var/turf/here = get_turf(user)
				if(step["type"] != "teleport" || !here)
					return FALSE
				step["dest"] = "fixed"
				step["x"] = here.x
				step["y"] = here.y
				step["z"] = here.z
				status = "Point B set to [here.x], [here.y], [here.z]."
			if("add_item")
				if(step["type"] != "spawn" || length(step["items"]) >= SCENE_MAX_ITEMS)
					return FALSE
				var/list/item = sanitize_spawn_item(list("path" = params["path"], "dx" = 0, "dy" = 0, "dir" = SOUTH, "amount" = 1))
				if(!item)
					status = "That type cannot be spawned by a scene."
					return TRUE
				step["items"] += list(item)
			if("edit_item", "remove_item")
				if(step["type"] != "spawn")
					return FALSE
				var/list/items = step["items"]
				var/item_index = text2num("[params["item"]]")
				if(!isnum(item_index) || item_index < 1 || item_index > length(items))
					return FALSE
				if(action == "remove_item")
					items.Cut(item_index, item_index + 1)
				else
					var/list/item = items[item_index]
					var/field = params["field"]
					if(!(field in list("dx", "dy", "dir", "amount")))
						return FALSE
					item[field] = sanitize_scene_value("spawn", field, params["value"])
		save_admin_scenes(scene["id"])
		return TRUE

	switch(action)
		if("run_here")
			if(!scene)
				return FALSE
			var/delay = clamp(text2num("[params["delay"]]") || 0, 0, 3600)
			run_admin_scene(scene["id"], get_turf(user), key_name(user), delay SECONDS)
			message_admins(span_adminnotice("[key_name_admin(user)] started the scene \"[scene["name"]]\"[delay ? " in [delay] s" : ""] at [ADMIN_VERBOSEJMP(user)]."))
			return TRUE
		if("place_trigger")
			if(!scene)
				return FALSE
			var/turf/here = get_turf(user)
			if(!here)
				return FALSE
			var/obj/effect/scene_trigger/trigger = new(here)
			trigger.scene_id = scene["id"]
			trigger.placed_by = key_name(user)
			trigger.mode = (params["mode"] in list("repeat", "each")) ? params["mode"] : "once"
			// Per player, 0 means once for each player; a shared repeat needs a real pause.
			var/cooldown = text2num("[params["cooldown"]]")
			if(trigger.mode == "each")
				trigger.cooldown = clamp(isnum(cooldown) ? cooldown : 0, 0, 3600)
			else
				trigger.cooldown = clamp(cooldown || 60, 5, 3600)
			trigger.delay = clamp(text2num("[params["delay"]]") || 0, 0, 3600)
			trigger.who = params["who"] == "living" ? "living" : "players"
			trigger.name = "scene trigger: [scene["name"]]"
			trigger.watch(clamp(round(text2num("[params["radius"]]") || 0), 0, 10))
			log_admin("[key_name(user)] placed a trigger for the scene \"[scene["name"]]\" at [AREACOORD(here)] (radius [trigger.radius], [trigger.mode]).")
			status = "Trigger placed. Teleport lines are drawn from it to every point B."
			return TRUE
		if("trigger_action")
			var/obj/effect/scene_trigger/trigger = locate(params["ref"]) in GLOB.scene_triggers
			if(!trigger)
				return FALSE
			switch(params["do"])
				if("fire")
					trigger.fire(null)
				if("toggle")
					trigger.armed = !trigger.armed
				if("jump")
					user.forceMove(get_turf(trigger))
				if("remove")
					log_admin("[key_name(user)] removed the scene trigger \"[trigger.scene_name()]\" at [AREACOORD(trigger)].")
					qdel(trigger)
			return TRUE
		if("stop_run")
			var/datum/admin_scene_run/run = locate(params["ref"]) in GLOB.scene_runs
			if(run)
				run.stopped = TRUE
				log_admin("[key_name(user)] stopped the scene \"[run.scene_name]\".")
			return TRUE
	return FALSE

/client/proc/open_scene_editor()
	set name = "Scenes"
	set category = "GameMaster"
	set desc = "Build, run and trigger saved events: spawn groups, narration, sounds, doors, teleports, effects and timers."
	if(!check_rights(R_FUN))
		return
	var/datum/admin_scene_editor/editor = new(src)
	editor.ui_interact(mob)

#undef SCENES_FILE
#undef SCENE_MAX_STEPS
#undef SCENE_MAX_SCENES
#undef SCENE_MAX_ITEMS
#undef SCENE_MAX_EXPLOSIONS
