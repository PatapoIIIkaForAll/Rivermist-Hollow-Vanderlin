// Hunting & Tracking pack - the animal trail chain.
//
// Trail respawns run on per-spawner timers rather than a dedicated subsystem: "Never add a new
// SS* subsystem in RMH" - ai_navigation/modular_guide.md. Each spawner schedules its own. That
// also means no global spawner list to leak references into.
//


/// How long before a used-up trail head reappears where it started.
#define HUNTING_RESPAWN_MIN (4 MINUTES)
#define HUNTING_RESPAWN_MAX (8 MINUTES)
/// Hunting skill (0-6) needed before a trail reveals which category of game it belongs to.
#define HUNT_IDENTIFY_SKILL_REQ 4
/// How far apart consecutive signs sit, before per-skill scatter.
#define HUNT_STEP_DISTANCE 9
/// How long an uncovered sign sits at full opacity before it starts fading.
#define HUNT_SIGN_LINGER (5 SECONDS)
/// Extra linger per point of Hunting skill.
#define HUNT_SIGN_PER_SKILL (2 SECONDS)
/// How long the fade-out itself takes. The sign is still readable throughout.
#define HUNT_SIGN_FADE (20 SECONDS)
/// How far from the first sign someone can be standing and still join the hunt.
#define HUNT_PARTY_GATHER_RANGE 5
/// How far a hunter may drift from the current sign before dropping out of the party.
#define HUNT_PARTY_KEEP_RANGE 9
/// How far away a fresh trail head can be highlighted by active perception.
#define HUNT_TRACK_SEARCH_RANGE 7
/// How long an unread personal link waits for its party before giving up. Only links
/// handed to a party get this - a fresh trail head is meant to sit there until worked.
#define HUNT_LINK_ABANDON_TIMEOUT (15 MINUTES)
/// Share of the leader's experience everyone else earns.
#define HUNT_PARTY_FOLLOWER_EXP 0.7
/// Experience for reading one sign.
#define HUNT_STEP_EXP 6
/// Experience for running the quarry down.
#define HUNT_QUARRY_EXP 35
/// Extra experience per animal the group flushed out on top of the quarry.
#define HUNT_BONUS_EXP 15

/// Groups of areas a single trail is allowed to wander between.
GLOBAL_LIST_INIT(hunting_area_groups, list(
	list(/area/outdoors/woods_safe),
	list(/area/outdoors/bog),
	list(/area/outdoors/mountains, /area/outdoors/mountains/decap),
))

/// Lazily built area type -> its group, so a trail does not walk out of its biome.
GLOBAL_LIST_EMPTY(hunting_area_lookup)

/proc/get_hunting_linked_areas(area_type)
	if(!length(GLOB.hunting_area_lookup))
		for(var/list/group as anything in GLOB.hunting_area_groups)
			for(var/grouped_area in group)
				GLOB.hunting_area_lookup[grouped_area] = group
	return GLOB.hunting_area_lookup[area_type] || list(area_type)

/obj/effect/hunting_track
	name = "disturbed earth"
	desc = "A mound of dirt and broken twigs. Something passed through here recently."
	icon = 'modular_rmh/icons/obj/hunting/animaltracks.dmi'
	icon_state = "hidden"
	anchored = TRUE
	// A fresh trail head is visible to everyone - that is how a hunt gets started at all. Only the
	// links a hunter uncovers afterwards go invisible and become personal to them, in
	// setup_hunter_visibility(). Getting this backwards makes the whole mechanic unreachable.
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_ICON
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// How many signs of this chain have been read so far.
	var/trail_depth = 0
	/// How many turfs to try before giving up on a direction.
	var/max_search_attempts = 9
	/// Area types this chain may continue into.
	var/list/linked_areas = list()
	var/static/list/track_types = list("cervine", "small", "ursine", "canine", "suidae")
	/// Icon state locked in for the whole chain, so the trail looks consistent.
	var/locked_track_icon
	var/track_revealed = FALSE
	/// Weakref to whoever is currently leading this chain - the most skilled hunter present.
	var/datum/weakref/hunter_ref
	/// Weakrefs to everyone hunting this chain. Set once, at the first sign, from who was standing
	/// nearby; pruned each step as people die or fall behind.
	var/list/party_refs = list()
	/// mob -> the image of this link that mob is being shown.
	var/list/party_images = list()
	/// Stoppable timer that removes this link if its party never comes to read it.
	var/abandon_timer
	/// What waits at the end.
	var/target_animal_type
	var/datum/hunting_category/hunt_category
	/// Category a hunter's map argued for, honoured when the chain picks its quarry.
	var/datum/hunting_category/secret_map_influence
	/// One map per trail, win or lose - otherwise a stack of maps could be rerolled on one mound.
	var/influence_attempted = FALSE
	/// Signs to read before the quarry shows itself.
	var/max_trail_depth = 6
	var/min_trail_depth = 4
	var/track_dir

/obj/effect/hunting_track/Initialize(mapload)
	. = ..()
	layer = HIGH_LANDMARK_LAYER
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)
	RegisterSignal(SSdcs, COMSIG_MOB_ACTIVE_PERCEPTION, PROC_REF(on_active_perception))

/obj/effect/hunting_track/Destroy()
	UnregisterSignal(SSdcs, COMSIG_MOB_ACTIVE_PERCEPTION)
	if(abandon_timer)
		deltimer(abandon_timer)
		abandon_timer = null
	clear_party_images()
	party_refs.Cut()
	hunter_ref = null
	hunt_category = null
	return ..()

/obj/effect/hunting_track/proc/on_active_perception(datum/source, mob/living/percepter)
	SIGNAL_HANDLER
	if(QDELETED(percepter))
		return
	if(length(party_refs) && !(WEAKREF(percepter) in party_refs))
		return
	if(get_dist(percepter, src) > HUNT_TRACK_SEARCH_RANGE || !can_see(percepter, src, HUNT_TRACK_SEARCH_RANGE + 3))
		return

	var/difficulty = 11 + rand(0, 5)
	var/competence = GET_MOB_ATTRIBUTE_VALUE(percepter, STAT_PERCEPTION)
	if(percepter.mind)
		competence += 2 * GET_MOB_SKILL_VALUE_OLD(percepter, /datum/attribute/skill/misc/tracking)
	if(competence < difficulty && (difficulty - competence >= 5 || !prob(100 - ((difficulty - competence) * 20))))
		return

	found_ping(get_turf(src), percepter.client, "hidden")

/obj/effect/hunting_track/proc/clear_party_images()
	for(var/mob/living/member as anything in party_images)
		if(!member)
			continue
		UnregisterSignal(member, list(COMSIG_MOB_LOGIN, COMSIG_PARENT_QDELETING))
		if(member.client)
			member.client.images -= party_images[member]
	party_images.Cut()

/**
 * Drops one hunter from this link entirely - image, signals and party entry.
 *
 * party_images is keyed by the mob itself, so a hunter who is deleted while the
 * link is still waiting would be held here indefinitely. Called from the
 * deletion handler, where WEAKREF() already refuses to hand a reference back,
 * so the mob's own cached weakref is what the party list is matched against.
 */
/obj/effect/hunting_track/proc/release_member(mob/living/member)
	UnregisterSignal(member, list(COMSIG_MOB_LOGIN, COMSIG_PARENT_QDELETING))
	var/image/personal = party_images[member]
	if(personal)
		if(member.client)
			member.client.images -= personal
		party_images -= member
	if(member.weak_reference)
		party_refs -= member.weak_reference

/// Signal handler for a party member being deleted mid-trail.
/obj/effect/hunting_track/proc/on_member_deleted(mob/living/member)
	SIGNAL_HANDLER
	release_member(member)

/// Hides this link from the world and shows it to the hunting party only - everyone following,
/// not just the leader, or a group hunt would have everyone but one person walking blind.
/obj/effect/hunting_track/proc/setup_hunter_visibility()
	invisibility = INVISIBILITY_MAXIMUM
	for(var/datum/weakref/member_ref as anything in party_refs)
		var/mob/living/member = member_ref.resolve()
		if(!member?.client)
			continue
		var/image/personal = image(icon, src, icon_state, layer)
		personal.color = color
		personal.pixel_x = pixel_x
		personal.pixel_y = pixel_y
		member.client.images += personal
		party_images[member] = personal
		// Login wipes client.images, and a hunter who reconnects mid-trail would otherwise be
		// left following a chain they can no longer see, with no way to get it back - the same
		// defect the footprints had.
		RegisterSignal(member, COMSIG_MOB_LOGIN, PROC_REF(on_member_login), override = TRUE)
		// party_images keys on the mob, so a hunter deleted before this link is read has to be
		// let go of explicitly.
		RegisterSignal(member, COMSIG_PARENT_QDELETING, PROC_REF(on_member_deleted), override = TRUE)

	// A party that wanders off would otherwise leave this link on the map forever while the
	// trail head it grew from respawns, so an unread link eventually gives up.
	if(abandon_timer)
		deltimer(abandon_timer)
	abandon_timer = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), HUNT_LINK_ABANDON_TIMEOUT, TIMER_STOPPABLE)

/// Hands a reconnecting hunter their view of this link back.
/obj/effect/hunting_track/proc/on_member_login(mob/living/member)
	SIGNAL_HANDLER
	if(invisibility != INVISIBILITY_MAXIMUM || !member?.client)
		return
	if(!(WEAKREF(member) in party_refs))
		return
	var/image/personal = image(icon, src, icon_state, layer)
	personal.color = color
	personal.pixel_x = pixel_x
	personal.pixel_y = pixel_y
	member.client.images += personal
	party_images[member] = personal

/obj/effect/hunting_track/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("A fresh mound starts a hunt - click it to read the signs. Stand back a tile first.")
	. += span_info("Looking around can highlight nearby disturbed earth and tracks. Your Tracking skill and Perception affect your chances.")
	. += span_info("Each sign points at the next one, which only you can see. Follow enough of them to run down the quarry.")
	. += span_info("Higher Hunting skill reads signs faster, wanders less, needs fewer of them, and turns up rarer game.")
	. += span_info("Trail heads come back on their own after a while, where they first appeared.")

/obj/effect/hunting_track/examine(mob/user)
	. = ..()
	if(user?.client)
		found_ping(get_turf(src), user.client, "hidden")
	if(trail_depth > 0)
		. += span_notice("You are working this trail.")
	if(track_dir)
		. += span_notice("The tracks seem to be heading <b>[dir2text(track_dir)]</b>.")
	if(hunt_category && GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/hunting) >= HUNT_IDENTIFY_SKILL_REQ)
		. += span_notice("You know these signs: <b>[hunt_category.name]</b>.")

/obj/effect/hunting_track/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!isliving(user))
		return
	if(track_revealed)
		return
	// Anyone in the party may work the trail, not just the leader. A chain with a party already
	// set is invisible to outsiders anyway; this is the safety net.
	if(length(party_refs) && !(WEAKREF(user) in party_refs))
		return

	if(trail_depth == 0)
		var/datum/component/hunting_blocker/blocker = user.GetComponent(/datum/component/hunting_blocker)
		if(!blocker)
			blocker = user.AddComponent(/datum/component/hunting_blocker)
		if(!blocker.can_start_hunt())
			return

	if(get_dist(user, src) < 1)
		to_chat(user, span_warning("You are standing on top of it. Step back to see where the trail leads."))
		return

	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, span_info("You begin reading the signs..."))

	var/skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/hunting)
	if(!do_after(user, max(1 SECONDS, 4 SECONDS - (skill * 4)), target = src))
		return
	if(track_revealed) // Re-check: do_after sleeps, someone else may have taken it.
		return

	if(!uncover_trail(user))
		to_chat(user, span_warning("The trail goes cold in the brush here."))
		return

	to_chat(user, span_nicegreen("The trail continues further ahead!"))
	track_revealed = TRUE
	distribute_party_exp(HUNT_STEP_EXP)
	if(trail_depth == 0)
		var/datum/component/hunting_blocker/blocker = user.GetComponent(/datum/component/hunting_blocker)
		blocker?.register_hunt()
	fade_and_die(skill)

/// Everyone with a mind standing near the first sign joins the hunt. The best tracker among them
/// leads, which is whose skill the trail is read against.
/obj/effect/hunting_track/proc/initialize_hunt_group(mob/living/revealer)
	var/list/potential_party = list(revealer)
	for(var/mob/living/nearby in range(HUNT_PARTY_GATHER_RANGE, src))
		if(nearby.stat == DEAD || !nearby.mind)
			continue
		potential_party |= nearby

	var/mob/living/best_hunter
	var/highest_skill = -1
	for(var/mob/living/candidate as anything in potential_party)
		var/candidate_skill = GET_MOB_SKILL_VALUE_OLD(candidate, /datum/attribute/skill/misc/hunting)
		if(candidate_skill > highest_skill)
			highest_skill = candidate_skill
			best_hunter = candidate
		party_refs |= WEAKREF(candidate)

	hunter_ref = WEAKREF(best_hunter)
	if(length(potential_party) > 1)
		to_chat(potential_party, span_notice("<b>Group hunt started!</b> [best_hunter] is leading the tracks. [length(party_refs)] hunters are following."))

/// Drops anyone who died or fell behind, re-elects the leader from who is still here, and reports
/// the skill the trail should be read against.
/obj/effect/hunting_track/proc/process_party_and_get_skill()
	var/highest_skill = 0
	var/mob/living/current_leader
	var/list/valid_party = list()

	for(var/datum/weakref/member_ref as anything in party_refs)
		var/mob/living/member = member_ref.resolve()
		if(QDELETED(member) || member.stat == DEAD || get_dist(src, member) > HUNT_PARTY_KEEP_RANGE)
			continue
		valid_party |= member_ref
		var/member_skill = GET_MOB_SKILL_VALUE_OLD(member, /datum/attribute/skill/misc/hunting)
		if(member_skill >= highest_skill)
			highest_skill = member_skill
			current_leader = member

	party_refs = valid_party
	if(current_leader)
		hunter_ref = WEAKREF(current_leader)
	return highest_skill

/// The leader learns the most; everyone else still learns from walking the trail.
/obj/effect/hunting_track/proc/distribute_party_exp(base_amount)
	var/mob/living/leader = hunter_ref?.resolve()
	for(var/datum/weakref/member_ref as anything in party_refs)
		var/mob/living/member = member_ref.resolve()
		if(QDELETED(member) || member.stat == DEAD || !member.mind)
			continue
		var/exp_modifier = max(1 + ((GET_MOB_ATTRIBUTE_VALUE(member, STAT_INTELLIGENCE) - 10) / 10), 0.1)
		var/final_amount = base_amount * ((member == leader) ? 1 : HUNT_PARTY_FOLLOWER_EXP)
		member.mind.add_sleep_experience(/datum/attribute/skill/misc/hunting, final_amount * exp_modifier)

/// A larger party flushes out more than one animal. Nobody but the leader rolls for their own.
/obj/effect/hunting_track/proc/spawn_group_bonus_animals(turf/origin)
	if(!hunt_category || !target_animal_type || !hunt_category.bonus_animal_amount)
		return 0

	var/mob/living/leader = hunter_ref?.resolve()
	var/list/valid_hunters = list()
	for(var/datum/weakref/member_ref as anything in party_refs)
		var/mob/living/member = member_ref.resolve()
		if(QDELETED(member) || member.stat == DEAD || member == leader)
			continue
		valid_hunters += member
	if(!length(valid_hunters))
		return 0

	var/group_bonus = length(valid_hunters) * 10
	var/list/nearby_turfs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/neighbour = get_step(origin, direction)
		if(validate_turf(neighbour))
			nearby_turfs += neighbour

	var/spawned_count = 0
	for(var/mob/living/hunter as anything in valid_hunters)
		if(spawned_count >= hunt_category.bonus_animal_amount)
			break
		var/skill = GET_MOB_SKILL_VALUE_OLD(hunter, /datum/attribute/skill/misc/hunting)
		if(!prob(clamp(((skill + 1) * 20) + group_bonus, 0, 100)))
			continue
		var/turf/spawn_turf = length(nearby_turfs) ? pick(nearby_turfs) : origin
		new /obj/effect/temp_visual/hunting_phantom(spawn_turf, pickweight(hunt_category.animals))
		spawned_count++
	return spawned_count

/obj/effect/hunting_track/proc/uncover_trail(mob/living/user)
	var/skill = process_party_and_get_skill()

	var/base_dx = clamp(x - user.x, -1, 1)
	var/base_dy = clamp(y - user.y, -1, 1)
	if(!base_dx && !base_dy)
		base_dy = 1

	// Straight on first, then break left, then right.
	var/list/search_patterns = list(
		list(base_dx, base_dy),
		list(-base_dy, base_dx),
		list(base_dy, -base_dx),
	)

	var/deviation = clamp(5 - max(skill - 2, 0), 1, 5)

	for(var/list/pattern as anything in search_patterns)
		for(var/attempt in 1 to max_search_attempts)
			var/target_dist = HUNT_STEP_DISTANCE + rand(0, 2)
			var/turf/target_turf = locate(
				x + (pattern[1] * target_dist) + rand(-deviation, deviation),
				y + (pattern[2] * target_dist) + rand(-deviation, deviation),
				z,
			)
			if(!validate_turf(target_turf))
				continue

			if(trail_depth == 0)
				// Leave something behind that will regrow this trail head later.
				new /obj/effect/landmark/hunting_spawner(get_turf(src))
				initialize_hunt_group(user)
				if(!target_animal_type)
					// The leader's skill decides the quarry and the trail length, not whoever
					// happened to click first - otherwise a novice standing next to an expert
					// would set the odds for the whole party.
					var/mob/living/leader = hunter_ref?.resolve()
					initialize_hunt_chain(leader || user)

			reveal_track(target_turf)

			if(trail_depth >= max_trail_depth)
				to_chat(user, span_boldwarning("You catch sight of your quarry in the distance!"))
				new /obj/effect/temp_visual/hunting_phantom(target_turf, target_animal_type)
				var/bonus_spawned = spawn_group_bonus_animals(target_turf)
				distribute_party_exp(HUNT_QUARRY_EXP + (HUNT_BONUS_EXP * bonus_spawned))
				return TRUE

			var/obj/effect/hunting_track/next_trail = new(target_turf)
			next_trail.hunter_ref = hunter_ref
			next_trail.party_refs = party_refs.Copy()
			next_trail.trail_depth = trail_depth + 1
			next_trail.max_trail_depth = max_trail_depth
			next_trail.target_animal_type = target_animal_type
			next_trail.hunt_category = hunt_category
			next_trail.locked_track_icon = locked_track_icon
			next_trail.linked_areas = linked_areas
			next_trail.color = "#ff9100"
			next_trail.setup_hunter_visibility()
			return TRUE
	return FALSE

/// Turns this link from a hidden mound into a visible print pointing at the next one.
/obj/effect/hunting_track/proc/reveal_track(turf/target_turf)
	if(!locked_track_icon)
		locked_track_icon = pick(track_types)
	// It has been read, so fade_and_die() owns its lifetime from here.
	if(abandon_timer)
		deltimer(abandon_timer)
		abandon_timer = null
	clear_party_images()

	invisibility = 0
	icon_state = locked_track_icon
	name = "[icon_state] tracks"
	desc = "Fresh prints leading away into the wilderness."
	color = null
	track_dir = get_dir(src, target_turf)

/obj/effect/hunting_track/proc/validate_turf(turf/target_turf)
	if(!target_turf || target_turf.density)
		return FALSE
	if(target_turf.is_blocked_turf())
		return FALSE
	var/area/here = get_area(src)
	var/area/there = get_area(target_turf)
	if(!there)
		return FALSE
	return (there == here) || (there.type in linked_areas)

/// An uncovered sign stays put for a while, then fades out slowly. The fade is the grace period:
/// it runs a full 20 seconds on top of the wait, so a novice still gets 25 seconds to walk the
/// trail. An earlier version faded over 2 seconds instead of 20 and deleted after 2 instead of
/// 20, which left low-skill hunters about 7 seconds.
/obj/effect/hunting_track/proc/fade_and_die(skill = 0)
	addtimer(CALLBACK(src, PROC_REF(start_fade_animation)), HUNT_SIGN_LINGER + (skill * HUNT_SIGN_PER_SKILL))

/obj/effect/hunting_track/proc/start_fade_animation()
	animate(src, alpha = 0, time = HUNT_SIGN_FADE, easing = EASE_OUT)
	QDEL_IN(src, HUNT_SIGN_FADE)

/// Picks what this chain is a trail of, and how long it runs.
/obj/effect/hunting_track/proc/initialize_hunt_chain(mob/living/user)
	var/skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/hunting)
	var/area/here = get_area(src)
	linked_areas = get_hunting_linked_areas(here?.type)

	// Skilled hunters need fewer signs.
	max_trail_depth = clamp(max_trail_depth - max(skill - 3, 0), min_trail_depth, max_trail_depth)

	// A map that named a category gets first refusal, provided the terrain agrees with it.
	if(secret_map_influence)
		var/datum/hunting_category/mapped = new secret_map_influence()
		if(mapped.can_spawn_in_area(here))
			hunt_category = mapped
		else
			secret_map_influence = null

	var/list/cat_weights = list()
	for(var/cat_type in subtypesof(/datum/hunting_category))
		var/datum/hunting_category/category = new cat_type()
		if(!category.can_spawn_in_area(here))
			continue
		var/weight = category.skill_weights[clamp(skill + 1, 1, length(category.skill_weights))]
		var/area_bonus = category.get_area_bonus(here)
		if(area_bonus)
			weight *= (1 + (area_bonus / 100))
		if(weight > 0)
			cat_weights[category] = weight

	if(!hunt_category)
		hunt_category = length(cat_weights) ? pickweight(cat_weights) : new /datum/hunting_category/low_tier()
	target_animal_type = pickweight(hunt_category.animals)
	locked_track_icon = hunt_category.preferred_tracks[target_animal_type] || pick(track_types)

/// Regrows a trail head where one was used up. Not for mapping - trails plant these themselves.
/obj/effect/landmark/hunting_spawner
	name = "hunting trail spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x4"
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE

/obj/effect/landmark/hunting_spawner/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn_trail)), rand(HUNTING_RESPAWN_MIN, HUNTING_RESPAWN_MAX))

/obj/effect/landmark/hunting_spawner/proc/respawn_trail()
	new /obj/effect/hunting_track(loc)
	qdel(src)

/// Keeps one hunter from carpeting the woods in fresh trail heads.
/datum/component/hunting_blocker
	var/last_hunt_start = 0
	var/hunt_cooldown = 90 SECONDS

/datum/component/hunting_blocker/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/hunting_blocker/proc/can_start_hunt()
	if(world.time < last_hunt_start + hunt_cooldown)
		to_chat(parent, span_warning("You've only just disturbed a fresh trail. Give it [DisplayTimeText(last_hunt_start + hunt_cooldown - world.time)] before scouting another."))
		return FALSE
	return TRUE

/datum/component/hunting_blocker/proc/register_hunt()
	last_hunt_start = world.time

#undef HUNTING_RESPAWN_MIN
#undef HUNTING_RESPAWN_MAX
#undef HUNT_IDENTIFY_SKILL_REQ
#undef HUNT_STEP_DISTANCE
#undef HUNT_SIGN_LINGER
#undef HUNT_SIGN_PER_SKILL
#undef HUNT_SIGN_FADE
#undef HUNT_PARTY_GATHER_RANGE
#undef HUNT_PARTY_KEEP_RANGE
#undef HUNT_TRACK_SEARCH_RANGE
#undef HUNT_LINK_ABANDON_TIMEOUT
#undef HUNT_PARTY_FOLLOWER_EXP
#undef HUNT_STEP_EXP
#undef HUNT_QUARRY_EXP
#undef HUNT_BONUS_EXP
