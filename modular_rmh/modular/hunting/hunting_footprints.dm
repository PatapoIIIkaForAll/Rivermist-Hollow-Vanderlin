// Hunting & Tracking pack - footprints left by people.
//
// Built on the core /obj/effect/skill_tracker + SStrackables framework, whose base class already
// carries the track fields (track_type, facing, depth, overwrites and friends).
//
// The movement hook hangs off /mob/living/carbon/human/Moved(), NOT /mob/living/Moved(). Core
// already defines the latter (code/modules/mob/living/living_movement.dm), and a second definition
// of the same proc on the same type from this layer would silently win over it - see
// ai_navigation/modular_guide.md - dropping stop_looking(), update_turf_movespeed() and
// consider_ambush(). Subtyping one level down is ordinary DM inheritance and chains through ..().
//
// Visibility model: the object itself is invisible to everyone. A mob that
// finds a track gets their own /image of it, so two people standing on the same tile can disagree
// about whether there is anything there. Examining goes through the turf (see /turf/open/examine
// below), the same way core routes thieves' cant examines through /turf/closed.

// Analysis levels, mirroring the ones _base.dm defines and undefs for itself.
#define ANALYSIS_TERRIBLE 1
#define ANALYSIS_BAD 2
#define ANALYSIS_DECENT 3
#define ANALYSIS_GOOD 4
#define ANALYSIS_PERFECT 5

/// Tracking skill level (0-6 scale) needed before tracks can be used to Mark their owner.
#define TRACK_MARK_SKILL_REQ 4
/// How long a footprint lingers before it is cleaned up.
#define TRACK_LIFETIME (15 MINUTES)
#define TRACK_REVEAL_DURATION (3 MINUTES)
#define TRACK_AGE_DIFFICULTY_STEP (1 MINUTES)
/// How far a look-around sweep reaches for tracks. Matches the 7-tile sweep look_around() uses.
#define TRACK_SEARCH_RANGE 7
/// Sneaking skill (0-6 scale) needed per +1 tracking difficulty on tracks left while sneaking.
/// At 1 a legendary sneak adds +6 to a base DC of 11 plus 0-5 entropy.
#define TRACK_CONCEALMENT_PER_SKILL 1

/mob/living/carbon/human
	/// Weakref to the mob this human has Marked off their tracks.
	var/datum/weakref/tracked_mark

/turf/open
	/// The footprint sitting on this turf, if any. Examining the turf reads it, mirroring how
	/// /turf/closed/examine() forwards to its thieves_marking - an invisible tracker cannot be
	/// clicked directly, so the turf under it is what the player actually examines.
	var/obj/effect/skill_tracker/footprint/footprint_marking

/turf/open/examine(mob/user)
	. = ..()
	if(!footprint_marking)
		return
	. += footprint_marking.knowledge_readout(user)

/obj/effect/skill_tracker/footprint
	name = "\improper track"
	desc = null
	icon = 'modular_rmh/icons/obj/hunting/track.dmi'
	icon_state = "tracks"
	real_icon_state = "tracks"
	// The object stays invisible to everyone. What a finder sees and
	// clicks is their own /image of it, and BYOND routes a mouse event on an image to the atom in
	// that image's loc - so the image must be anchored to src, not to the turf. Anchoring it to
	// loc was what made tracks read as part of the ground.
	invisibility = INVISIBILITY_MAXIMUM
	// The object stays invisible, but BYOND routes mouse events on an image to the atom in its
	// loc - so a knower holding a personal image can click and examine the track itself, while
	// someone who has not found it clicks straight through to the ground. The /turf/open handlers
	// further down stay as a fallback for the case where the click lands on the turf instead.
	mouse_opacity = MOUSE_OPACITY_ICON
	reveal_skill = /datum/attribute/skill/misc/tracking
	always_revealed_trait = TRAIT_PERFECT_TRACKER
	adds_xp_on_reveal = TRUE
	// track_type, ambiguous_track_type, facing, depth, special_movement and overwrites are all
	// already declared on /obj/effect/skill_tracker in _base.dm - only defaults are set here.
	track_type = "footwear tracks"
	ambiguous_track_type = "footwear tracks"
	/// Whether this print is distinct enough to Mark its owner from.
	var/markable = TRUE
	/// The way the maker was facing, kept so per-knower images can be built facing the right way.
	var/original_dir
	/// mob -> the personal image that mob sees. One each, so a Marked highlight shown to the
	/// hunter who owns the Mark does not change what everyone else is looking at.
	var/list/knower_images = list()
	var/list/knower_timers = list()

/obj/effect/skill_tracker/footprint/Initialize(mapload, atom/parent)
	. = ..()
	creation_time = world.time
	deletion_timer = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), TRACK_LIFETIME, TIMER_STOPPABLE)
	RegisterSignal(SSdcs, COMSIG_MOB_ACTIVE_PERCEPTION, PROC_REF(on_active_perception))
	var/turf/open/parent_turf = parent
	if(istype(parent_turf))
		parent_turf.footprint_marking = src

/obj/effect/skill_tracker/footprint/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_MOB_ACTIVE_PERCEPTION)
	var/turf/open/parent_turf = loc
	if(istype(parent_turf) && parent_turf.footprint_marking == src)
		parent_turf.footprint_marking = null
	// knower_images is deliberately left intact: ..() walks known_by and calls remove_knower(),
	// which needs it to pull each personal image back off its client.
	return ..()

/// Deliberately does nothing. The base version reveals a trait holder to a trackable the moment it
/// is created, with no distance check at all - fine for a handful of thieves' cant markings, wrong
/// for footprints, where it would show a Master Tracker every print anyone leaves anywhere in the
/// world, including their own, every step. The trait still guarantees a find, but only when the
/// character actually looks around: check_reveal() short-circuits on HAS_TRAIT for that.
/obj/effect/skill_tracker/footprint/check_for_users()
	return

/// The other door into the same shortcut. SStrackables.grant_trait() walks every existing
/// trackable on login and calls this, so blocking check_for_users() alone still handed a Master
/// Tracker every footprint on the map the moment they reconnected - no distance, no line of
/// sight, no looking around. The trait's guarantee belongs in check_reveal(), which only runs
/// when the character actually searches.
/obj/effect/skill_tracker/footprint/reveal_to_trait_holder(mob/living/user)
	return

/// Tracks are found by actively looking around (right-click the eye on the HUD), which is what
/// look_around() fires this global signal for - the same hook /obj/structure/trap uses.
/obj/effect/skill_tracker/footprint/proc/on_active_perception(datum/source, mob/living/percepter)
	SIGNAL_HANDLER
	if(QDELETED(percepter))
		return
	if(get_dist(percepter, src) > TRACK_SEARCH_RANGE)
		return
	if(!can_see(percepter, src, TRACK_SEARCH_RANGE + 3))
		return
	// Login wipes client.images but leaves known_by intact, so someone who reconnects is still a
	// knower with nothing to look at. Searching again has to hand the image back rather than
	// skip them for already knowing. The cached reference survives that wipe, so what actually
	// decides is whether the current client is still carrying the image.
	if(percepter in known_by)
		var/image/personal = knower_images?[percepter]
		if(!personal || !percepter.client || !(personal in percepter.client.images))
			restore_image_for(percepter)
		return
	if(!check_reveal(percepter))
		return
	found_ping(get_turf(src), percepter.client, "hidden")
	handle_revealing(percepter)

/// Which sprite this mob should see. A track belonging to someone they have Marked stands out.
/obj/effect/skill_tracker/footprint/proc/get_state_for(mob/living/tracker)
	if(!creator || !ishuman(tracker))
		return real_icon_state
	var/mob/living/carbon/human/human_tracker = tracker
	if(human_tracker.tracked_mark?.resolve() == creator)
		return "tracks_marked"
	return real_icon_state

/obj/effect/skill_tracker/footprint/add_knower(mob/living/tracker, competence = 1)
	known_by[tracker] = competence
	if(tracker.client)
		var/image/personal = image(icon, src, get_state_for(tracker), BULLET_HOLE_LAYER, original_dir || dir)
		personal.mouse_opacity = MOUSE_OPACITY_ICON
		knower_images[tracker] = personal
		tracker.client.images += personal
	RegisterSignal(tracker, COMSIG_PARENT_QDELETING, PROC_REF(remove_knower), override = TRUE)
	var/old_timer = knower_timers[tracker]
	if(old_timer)
		deltimer(old_timer)
	knower_timers[tracker] = addtimer(CALLBACK(src, PROC_REF(reveal_expired), tracker), TRACK_REVEAL_DURATION, TIMER_STOPPABLE)
	if(deletion_timer && timeleft(deletion_timer) < TRACK_REVEAL_DURATION)
		deltimer(deletion_timer)
		deletion_timer = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), TRACK_REVEAL_DURATION, TIMER_STOPPABLE)

// No SIGNAL_HANDLER here: the base declares it on its own definition, and SpacemanDMM rejects
// re-declaring the sleep contract on an override.
/obj/effect/skill_tracker/footprint/remove_knower(mob/living/tracker)
	UnregisterSignal(tracker, COMSIG_PARENT_QDELETING)
	var/reveal_timer = knower_timers?[tracker]
	if(reveal_timer)
		deltimer(reveal_timer)
		knower_timers -= tracker
	var/image/personal = knower_images?[tracker]
	if(personal)
		if(tracker.client)
			tracker.client.images -= personal
		knower_images -= tracker
	known_by -= tracker
	if(creator == tracker)
		creator = null

/obj/effect/skill_tracker/footprint/proc/reveal_expired(mob/living/tracker)
	knower_timers -= tracker
	if(!(tracker in known_by))
		return
	var/was_creator = (creator == tracker)
	remove_knower(tracker)
	if(was_creator && !QDELETED(tracker))
		creator = tracker
		RegisterSignal(tracker, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/obj/effect/skill_tracker, clear_creator_reference))

/obj/effect/skill_tracker/footprint/proc/can_see_track(mob/user)
	if(!(user in known_by) || !user.client)
		return FALSE
	var/image/personal = knower_images?[user]
	return personal && (personal in user.client.images)

/obj/effect/skill_tracker/footprint/proc/get_age_penalty()
	return round((world.time - creation_time) / TRACK_AGE_DIFFICULTY_STEP)

/obj/effect/skill_tracker/footprint/check_reveal(mob/living/user)
	var/age_penalty = get_age_penalty()
	tracking_modifier += age_penalty
	. = ..()
	tracking_modifier -= age_penalty

/obj/effect/skill_tracker/footprint/handle_revealing(mob/living/user)
	var/age_penalty = get_age_penalty()
	tracking_modifier += age_penalty
	. = ..()
	tracking_modifier -= age_penalty

/// Rebuilds a knower's image from scratch - used when they had one and lost it, as happens on
/// reconnect.
/obj/effect/skill_tracker/footprint/proc/restore_image_for(mob/living/tracker)
	if(!tracker?.client)
		return
	// Drop whatever was cached first, or a client that still holds the old image
	// (a rebuild that was not caused by a reconnect) ends up with two.
	var/image/stale = knower_images?[tracker]
	if(stale)
		tracker.client.images -= stale
	var/image/personal = image(icon, src, get_state_for(tracker), BULLET_HOLE_LAYER, original_dir || dir)
	personal.mouse_opacity = MOUSE_OPACITY_ICON
	knower_images[tracker] = personal
	tracker.client.images += personal

/// Swaps this mob's image over to the Marked sprite, once they realize whose track this is.
/obj/effect/skill_tracker/footprint/proc/refresh_image_for(mob/living/tracker)
	if(!(tracker in known_by) || !tracker.client)
		return
	var/image/old_image = knower_images?[tracker]
	var/wanted_state = get_state_for(tracker)
	if(old_image?.icon_state == wanted_state)
		return
	if(old_image)
		tracker.client.images -= old_image
	var/image/personal = image(icon, src, wanted_state, BULLET_HOLE_LAYER, original_dir || dir)
	personal.mouse_opacity = MOUSE_OPACITY_ICON
	knower_images[tracker] = personal
	tracker.client.images += personal

/obj/effect/skill_tracker/footprint/examine(mob/user)
	. = ..()
	. += knowledge_readout(user)

/obj/effect/skill_tracker/footprint/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!isliving(user) || !can_see_track(user))
		return
	return try_conceal(user)

/obj/effect/skill_tracker/footprint/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!ishuman(user))
		return
	return try_mark(user)

/obj/effect/skill_tracker/footprint/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Tracks are found by looking around - right-click the eye on your HUD. What you find scales with Perception and the Tracking skill.")
	. += span_info("Once found, examine a track to read it. With enough skill, right-clicking it lets you Mark whoever left it.")
	. += span_info("Clicking a track lets you scuff it out, so nobody else can follow it.")

/// The readout the turf under this track prints. Empty for anyone who has not found it yet.
/obj/effect/skill_tracker/footprint/proc/knowledge_readout(mob/user)
	var/knowledge = known_by?[user]
	if(!knowledge)
		return list()

	. = list()
	. += span_notice("You crouch to inspect the tracks...")
	if(knowledge >= ANALYSIS_DECENT)
		. += span_info("Looks like some [track_type].")
	else
		. += span_info("Looks like some [ambiguous_track_type].")
	if(facing != "nowhere")
		. += span_info("This track leads [facing].")

	if(knowledge > ANALYSIS_DECENT)
		var/minutes_old = round((world.time - creation_time) / (1 MINUTES))
		. += span_info("These tracks are about [minutes_old] minute[minutes_old == 1 ? "" : "s"] old.")
		if(depth)
			. += span_warning("These tracks are [depth]!")
	if(knowledge > ANALYSIS_GOOD && special_movement)
		. += span_danger(special_movement)
	if(knowledge > ANALYSIS_TERRIBLE && creator == user)
		. += span_nicegreen("These are your own tracks!")

	if(knowledge >= ANALYSIS_GOOD)
		if(overwrites > 10)
			. += span_warning("There are traces of many older tracks here, too.")
		else if(overwrites >= 2)
			. += span_warning("There are traces of around [overwrites] older tracks here, too.")

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(creator && human_user.tracked_mark?.resolve() == creator)
			. += span_nicegreen("This track belongs to your mark.")
			refresh_image_for(human_user)
		else if(knowledge >= ANALYSIS_GOOD && markable && creator && GET_MOB_SKILL_VALUE_OLD(human_user, /datum/attribute/skill/misc/tracking) >= TRACK_MARK_SKILL_REQ)
			. += span_nicegreen("<i>Right-click this track to Mark its owner.</i>")

/// Right-clicking the ground Marks the owner of the track on it. Routed through the turf for the
/// same reason examine is: the track object itself is invisible and cannot be clicked.
/turf/open/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!footprint_marking || !ishuman(user))
		return
	return footprint_marking.try_mark(user)

/obj/effect/skill_tracker/footprint/proc/try_mark(mob/living/carbon/human/human_user)
	if(!can_see_track(human_user))
		return
	if(GET_MOB_SKILL_VALUE_OLD(human_user, /datum/attribute/skill/misc/tracking) < TRACK_MARK_SKILL_REQ)
		to_chat(human_user, span_info("I am not skilled enough to tell one man's gait from another's."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!markable || !creator)
		to_chat(human_user, span_warning("There is not enough here to Mark anyone by."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	to_chat(human_user, span_info("You start taking note of the gait, the weight, the way the toes turn..."))
	if(!do_after(human_user, 5 SECONDS, target = src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!creator)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	human_user.tracked_mark = WEAKREF(creator)
	to_chat(human_user, span_warning("You've marked this one. You'll know their tracks when you next cross them."))
	refresh_image_for(human_user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Scuffing a track out. Also routed through the turf.
/turf/open/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!footprint_marking || !isliving(user))
		return
	if(!footprint_marking.can_see_track(user))
		return
	return footprint_marking.try_conceal(user)

/obj/effect/skill_tracker/footprint/proc/try_conceal(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, span_info("You start scuffing out the tracks..."))
	if(!do_after(user, 4 SECONDS, target = src))
		return
	if(QDELETED(src) || !can_see_track(user))
		return
	to_chat(user, span_warning("Nobody should be able to follow these anymore."))
	qdel(src)
	return TRUE

/// Fills in what this specific mob's tracks look like. Override on a mob type with odd tracks.
/mob/living/proc/get_track_info(obj/effect/skill_tracker/footprint/new_track)
	var/mob/living/prototype = type
	new_track.track_type = "[initial(prototype.name)] tracks"
	new_track.ambiguous_track_type = "beast tracks"

/mob/living/carbon/human/get_track_info(obj/effect/skill_tracker/footprint/new_track)
	if(!(mobility_flags & MOBILITY_STAND))
		new_track.track_type = "drag marks"
		new_track.ambiguous_track_type = "drag marks"
		new_track.markable = FALSE
	else if(shoes && (shoes.body_parts_covered & FEET))
		new_track.track_type = "[shoes.name] tracks"
		new_track.ambiguous_track_type = "footwear tracks"
	else
		new_track.track_type = "[dna?.species?.name] footprints"
		new_track.ambiguous_track_type = "bare footprints"

	switch(check_armor_class())
		if(AC_HEAVY)
			new_track.depth = "very deep"
		if(AC_MEDIUM)
			new_track.depth = "deep"

	if(m_intent == MOVE_INTENT_RUN)
		new_track.special_movement = "These were made in a hurry - whoever left them was running."
	else if(m_intent == MOVE_INTENT_SNEAK)
		new_track.special_movement = "Whoever left these was placing their feet with care."

/mob/living/carbon/human/Moved()
	. = ..()
	check_track_creation(loc)

/// Leaves a track on the turf just stepped onto, stamping over any older one there.
/mob/living/proc/check_track_creation(turf/new_turf)
	if(!mind) // No player behind the wheel: skip before touching the turf at all.
		return
	if(!isopenturf(new_turf))
		return
	if(movement_type & (FLOATING|FLYING))
		return

	var/probability = track_creation_prob(new_turf)
	var/ordinary = probability && prob(probability)
	var/datum/enterprise_theft/theft = enterprise_theft?.roll_track(src, new_turf)
	if(!ordinary && !theft)
		return

	var/obj/effect/skill_tracker/footprint/old_track = locate() in new_turf
	var/obj/effect/skill_tracker/footprint/new_track = theft ? theft.make_track(new_turf, ordinary) : new(new_turf, new_turf)
	if(old_track)
		new_track.overwrites = old_track.overwrites + 1
		qdel(old_track)

	new_track.creator = src
	// _base.dm registers remove_knower on this same signal/target pair for anyone in known_by, so
	// registering again would override that handler and leave known_by holding a dangling ref.
	// remove_knower already nulls creator when the knower is the creator, so one covers both.
	if(!(src in new_track.known_by))
		new_track.RegisterSignal(src, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/obj/effect/skill_tracker, clear_creator_reference))
	new_track.facing = dir2text(dir)
	new_track.original_dir = dir
	new_track.setDir(dir)
	get_track_info(new_track)
	new_track.tracking_modifier += get_track_concealment()

/// Extra difficulty this mob's tracks carry from careful footwork, added to the base tracking DC.
/// Only counts while actually sneaking: skill alone does not hide a mob who is not trying to.
/// _base.dm feeds tracking_modifier into both check_reveal() and handle_revealing(), so a
/// concealed track is harder both to spot at all and to read once spotted.
/mob/living/proc/get_track_concealment()
	if(m_intent != MOVE_INTENT_SNEAK)
		return 0
	return round(GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/misc/sneaking) / TRACK_CONCEALMENT_PER_SKILL)

/// This mob's chance (0-100) of leaving a track on the given turf.
/mob/living/proc/track_creation_prob(turf/new_turf)
	. = new_turf.track_prob
	if(!.)
		return 0
	if(m_intent == MOVE_INTENT_SNEAK)
		var/sneak_mod = 0.7 - (0.1 * GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/misc/sneaking))
		. *= max(sneak_mod, 0)
	else if(m_intent == MOVE_INTENT_RUN)
		. *= 3

/mob/living/carbon/human/track_creation_prob(turf/new_turf)
	. = ..()
	if(!.)
		return
	switch(check_armor_class())
		if(AC_HEAVY)
			. *= 1.5
		if(AC_MEDIUM)
			. *= 1.25

#undef ANALYSIS_TERRIBLE
#undef ANALYSIS_BAD
#undef ANALYSIS_DECENT
#undef ANALYSIS_GOOD
#undef ANALYSIS_PERFECT
#undef TRACK_MARK_SKILL_REQ
#undef TRACK_LIFETIME
#undef TRACK_REVEAL_DURATION
#undef TRACK_AGE_DIFFICULTY_STEP
#undef TRACK_SEARCH_RANGE
#undef TRACK_CONCEALMENT_PER_SKILL
