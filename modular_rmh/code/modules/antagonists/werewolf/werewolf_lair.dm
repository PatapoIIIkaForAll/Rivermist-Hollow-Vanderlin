#define WW_LAIR_SNIFF_ICON_STATE "diagnose"
#define WW_LAIR_DISTANCE_IMMEDIATE 1
#define WW_LAIR_DISTANCE_NEAR 7
#define WW_LAIR_DISTANCE_MID 20
#define WW_LAIR_DISTANCE_FAR 60

/proc/is_werewolf_lair_natural_wall(turf/target_wall)
	if(istype(target_wall, /turf/closed/mineral))
		return TRUE
	if(istype(target_wall, /turf/closed/wall/mineral))
		return target_wall.type == /turf/closed/wall/mineral
	return FALSE

/datum/antagonist/werewolf
	var/lair_created = FALSE
	var/datum/weakref/lair_entrance_ref
	var/datum/action/innate/werewolf_lair_scent/lair_scent_action
	COOLDOWN_DECLARE(nest_rest_cooldown)

/datum/antagonist/werewolf/proc/initialize_werewolf_lair_ability()
	sync_werewolf_lair_creation_spell()
	sync_werewolf_lair_tracking_action()

/datum/antagonist/werewolf/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	remove_werewolf_lair_creation_spell(old_body)
	sync_werewolf_lair_creation_spell()
	sync_werewolf_lair_tracking_action()
	sync_werewolf_contract_assignments()
	sync_werewolf_contract_actions()
	refresh_werewolf_contract_browser_if_open()

/datum/antagonist/werewolf/proc/cleanup_werewolf_lair()
	remove_werewolf_lair_creation_spell()
	QDEL_NULL(lair_scent_action)

	var/obj/structure/werewolf_lair_entrance/lair_entrance = get_werewolf_lair_entrance()
	lair_entrance_ref = null
	if(lair_entrance)
		qdel(lair_entrance)

/datum/antagonist/werewolf/proc/is_current_werewolf_body(mob/living/user = owner?.current)
	if(!istype(user))
		return FALSE
	if(owner != user.mind)
		return FALSE
	if(owner?.current != user)
		return FALSE
	return !!IS_WEREWOLF(user)

/datum/antagonist/werewolf/proc/get_werewolf_lair_entrance()
	var/obj/structure/werewolf_lair_entrance/lair_entrance = lair_entrance_ref?.resolve()
	if(lair_entrance)
		return lair_entrance

	lair_entrance_ref = null

	if(!owner)
		return null

	// Recover the lair if this werewolf datum was recreated and lost its cached ref.
	for(var/obj/structure/werewolf_lair_entrance/existing_lair in world)
		if(existing_lair.get_owner_mind() != owner)
			continue
		lair_entrance_ref = WEAKREF(existing_lair)
		return existing_lair

	return null

/datum/antagonist/werewolf/proc/can_create_werewolf_lair()
	if(lair_created)
		return FALSE
	return !get_werewolf_lair_entrance()

/datum/antagonist/werewolf/proc/register_werewolf_lair(obj/structure/werewolf_lair_entrance/lair_entrance)
	if(!istype(lair_entrance))
		return FALSE

	lair_created = TRUE
	lair_entrance_ref = WEAKREF(lair_entrance)
	sync_werewolf_lair_tracking_action()
	return TRUE

/datum/antagonist/werewolf/proc/remove_werewolf_lair_creation_spell(mob/living/carbon/human/spell_holder = owner?.current)
	if(!istype(spell_holder))
		return

	spell_holder.remove_spell(/datum/action/cooldown/spell/pointed/werewolf_create_lair)

/datum/antagonist/werewolf/proc/sync_werewolf_lair_creation_spell()
	var/mob/living/carbon/human/current_mob = owner?.current
	if(!istype(current_mob))
		return

	if(transformed && can_create_werewolf_lair())
		current_mob.add_spell(/datum/action/cooldown/spell/pointed/werewolf_create_lair, source = src)
		return

	current_mob.remove_spell(/datum/action/cooldown/spell/pointed/werewolf_create_lair)

/datum/antagonist/werewolf/proc/sync_werewolf_lair_tracking_action()
	var/mob/living/current_body = owner?.current
	if(!current_body)
		if(lair_scent_action?.owner)
			lair_scent_action.Remove(lair_scent_action.owner)
		return

	if(get_werewolf_lair_entrance())
		if(!lair_scent_action)
			lair_scent_action = new(src)
		lair_scent_action.Grant(current_body)
	else if(lair_scent_action?.owner)
		lair_scent_action.Remove(lair_scent_action.owner)

/datum/antagonist/werewolf/proc/can_track_werewolf_lair(mob/living/user = owner?.current)
	if(!is_current_werewolf_body(user))
		return FALSE
	return !!get_werewolf_lair_entrance()

/datum/antagonist/werewolf/proc/get_werewolf_lair_distance_text(turf/reference_turf, turf/target_turf)
	if(!reference_turf || !target_turf)
		return "somewhere beyond my nose"

	var/distance = get_dist(reference_turf, target_turf)
	if(distance <= WW_LAIR_DISTANCE_IMMEDIATE)
		return "right on top of me"
	if(distance <= WW_LAIR_DISTANCE_NEAR)
		return "very close"
	if(distance <= WW_LAIR_DISTANCE_MID)
		return "nearby"
	if(distance <= WW_LAIR_DISTANCE_FAR)
		return "far off"
	return "very far away"

/datum/antagonist/werewolf/proc/get_werewolf_lair_map_file(turf/target_turf)
	if(!target_turf)
		return null

	var/map_file = SSmapping.level_trait(target_turf.z, ZTRAIT_MAP_FILE)
	if(!map_file)
		return null

	return LOWER_TEXT("[map_file]")

/datum/antagonist/werewolf/proc/find_werewolf_lair_gate(area/target_area, turf/from_turf)
	if(!target_area || !from_turf)
		return null

	var/obj/structure/fluff/traveltile/best_gate
	var/best_distance = INFINITY
	var/source_map_file = get_werewolf_lair_map_file(from_turf)

	for(var/obj/structure/fluff/traveltile/travel_gate in GLOB.traveltiles)
		var/turf/gate_turf = get_turf(travel_gate)
		if(!gate_turf)
			continue
		if(source_map_file && get_werewolf_lair_map_file(gate_turf) != source_map_file)
			continue
		if(travel_gate.cached_destination_area != target_area)
			continue

		var/distance = get_dist(from_turf, gate_turf)
		if(distance < best_distance)
			best_distance = distance
			best_gate = travel_gate

	return best_gate

/datum/antagonist/werewolf/proc/get_werewolf_lair_signal_data(turf/reference_turf, turf/lair_target_turf)
	var/list/signal_data = list(
		"compass_target" = null,
		"resolved_target" = lair_target_turf,
		"routed_through_exit" = FALSE,
		"routed_through_gate" = FALSE,
		"remote_target" = FALSE,
	)
	if(!reference_turf || !lair_target_turf)
		return signal_data

	signal_data["compass_target"] = lair_target_turf

	var/reference_map_file = get_werewolf_lair_map_file(reference_turf)
	var/target_map_file = get_werewolf_lair_map_file(lair_target_turf)
	if(reference_map_file && target_map_file && reference_map_file == target_map_file)
		return signal_data

	signal_data["remote_target"] = TRUE

	var/area/pocket_dimension/current_pocket_area = get_area(reference_turf)
	var/datum/pocket_dimension/current_pocket = istype(current_pocket_area, /area/pocket_dimension) ? current_pocket_area.linked_pocket : null
	if(current_pocket && length(current_pocket.exit_objects))
		var/obj/structure/pocket_dimension_exit/closest_exit
		var/closest_distance = INFINITY
		for(var/obj/structure/pocket_dimension_exit/exit_object as anything in current_pocket.exit_objects)
			var/turf/exit_turf = get_turf(exit_object)
			if(!exit_turf)
				continue
			var/distance = get_dist(reference_turf, exit_turf)
			if(distance < closest_distance)
				closest_distance = distance
				closest_exit = exit_object

		if(closest_exit)
			signal_data["compass_target"] = get_turf(closest_exit)
			signal_data["routed_through_exit"] = TRUE
			return signal_data

	var/area/target_area = get_area(lair_target_turf)
	var/obj/structure/fluff/traveltile/target_gate = find_werewolf_lair_gate(target_area, reference_turf)
	if(target_gate)
		signal_data["compass_target"] = get_turf(target_gate)
		signal_data["routed_through_gate"] = TRUE
		return signal_data

	signal_data["compass_target"] = null

	return signal_data

/datum/antagonist/werewolf/proc/sniff_werewolf_lair(mob/living/user = owner?.current)
	if(!can_track_werewolf_lair(user))
		return FALSE

	var/obj/structure/werewolf_lair_entrance/lair_entrance = get_werewolf_lair_entrance()
	var/turf/reference_turf = get_turf(user)
	var/turf/lair_turf = get_turf(lair_entrance)
	if(!reference_turf || !lair_turf)
		to_chat(user, span_warning("My den's scent slips out of my grasp."))
		sync_werewolf_lair_tracking_action()
		return FALSE

	var/list/signal_data = get_werewolf_lair_signal_data(reference_turf, lair_turf)
	var/turf/compass_target = signal_data["compass_target"]
	var/direction_text = compass_target ? (get_precise_direction_between(reference_turf, compass_target) || dir2text(get_dir(reference_turf, compass_target))) : null
	var/distance_text = get_werewolf_lair_distance_text(reference_turf, lair_turf)

	if(signal_data["routed_through_exit"])
		if(direction_text)
			to_chat(user, span_notice("The scent of my den-mouth curls to the [direction_text], toward the way back out."))
		else
			to_chat(user, span_notice("The scent of my den-mouth pools around the way back out."))
		return TRUE

	if(signal_data["routed_through_gate"])
		if(direction_text)
			to_chat(user, span_notice("The scent of my den-mouth bends to the [direction_text], toward a path back to it."))
		else
			to_chat(user, span_notice("The scent of my den-mouth points toward a path back to it."))
		return TRUE

	if(signal_data["remote_target"])
		to_chat(user, span_notice("The scent of my den-mouth vanishes off this land. The entrance lies far from here."))
		return TRUE

	if(!direction_text)
		to_chat(user, span_notice("My den-mouth is [distance_text]."))
	else
		to_chat(user, span_notice("My den-mouth is [distance_text] to the [direction_text]."))
	return TRUE

/area/pocket_dimension/werewolf_lair
	name = "Werewolf Lair"

/datum/map_template/pocket/werewolf_lair
	name = "Werewolf Lair"
	id = "pocket_werewolf_lair"
	mappath = "_maps/templates/pockets/pocket_werewolf_lair.dmm"
	exit_structure_type = /obj/structure/pocket_dimension_exit/hole
	lifecycle_policy = POCKET_LIFECYCLE_KEEP_LOADED
	persistence_mode = POCKET_PERSISTENCE_MOVABLES

/// The lair entrance whose pocket holds [thing], or null outside a werewolf lair.
/proc/get_werewolf_lair_entrance_holding(atom/thing)
	var/area/pocket_dimension/pocket_area = get_area(thing)
	if(!istype(pocket_area))
		return null
	var/obj/structure/werewolf_lair_entrance/lair_entrance = pocket_area.linked_pocket?.get_pocket_holder()
	return istype(lair_entrance) ? lair_entrance : null

/// Lying in a lair nest quiets the restless beast; the rage bonus waits out its cooldown.
/datum/antagonist/werewolf/proc/rest_in_nest(mob/living/sleeper)
	clear_transformation_pressure()
	if(!COOLDOWN_FINISHED(src, nest_rest_cooldown))
		return FALSE
	COOLDOWN_START(src, nest_rest_cooldown, WW_NEST_REST_COOLDOWN)
	var/mob/living/carbon/human/human_sleeper = sleeper
	if(istype(human_sleeper))
		human_sleeper.rage_datum?.update_rage(WW_NEST_RAGE_BONUS)
	to_chat(sleeper, span_notice("I curl into the musk of my nest. The restless beast settles, and my blood runs hot."))
	return TRUE

/obj/structure/bed/werewolf_nest
	name = "fur-lined nest"
	desc = "A hollow of trampled earth lined with shed fur and torn hides. It reeks of wolf."
	icon = 'icons/obj/bear.dmi'
	icon_state = "bear"
	sleepy = 1

/obj/structure/bed/werewolf_nest/Initialize(mapload, ...)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	for(var/mob/living/resident in loc)
		watch_resident(resident)

/obj/structure/bed/werewolf_nest/post_buckle_mob(mob/living/M)
	. = ..()
	settle(M)

/obj/structure/bed/werewolf_nest/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(isliving(arrived))
		watch_resident(arrived)

/obj/structure/bed/werewolf_nest/proc/on_exited(datum/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(isliving(gone))
		UnregisterSignal(gone, COMSIG_LIVING_SET_BODY_POSITION)

/// Werewolves on the nest are watched for lying down; everyone else is ignored.
/obj/structure/bed/werewolf_nest/proc/watch_resident(mob/living/resident)
	if(!IS_WEREWOLF(resident))
		return
	RegisterSignal(resident, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(on_resident_position), override = TRUE)
	if(resident.body_position == LYING_DOWN)
		settle(resident)

/obj/structure/bed/werewolf_nest/proc/on_resident_position(mob/living/source, new_position, old_position)
	SIGNAL_HANDLER
	if(new_position == LYING_DOWN)
		settle(source)

/obj/structure/bed/werewolf_nest/proc/settle(mob/living/sleeper)
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(sleeper)
	wolf?.rest_in_nest(sleeper)

/obj/structure/werewolf_bone_pile
	name = "bone pile"
	desc = "Gnawed bones heaped against the stone, every one cracked open for its marrow."
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "bonestack2"
	anchored = TRUE
	density = FALSE

/obj/structure/werewolf_bone_pile/examine(mob/user)
	. = ..()
	var/obj/structure/werewolf_lair_entrance/lair_entrance = get_werewolf_lair_entrance_holding(src)
	var/datum/antagonist/werewolf/owner_werewolf = lair_entrance?.get_owner_werewolf()
	if(!owner_werewolf)
		return
	var/hunted = owner_werewolf.animals_hunted_in_wolf_form
	var/slain = owner_werewolf.foes_slain_in_wolf_form
	. += span_notice("Picked clean here: [hunted] hunted beast[werewolf_plural_suffix(hunted)] and [slain] slain foe[werewolf_plural_suffix(slain)].")

/obj/structure/werewolf_lair_entrance
	name = "clawed-out lair"
	desc = "A clawed burrow mouth hidden against the wall. The air beyond smells of damp earth, wet fur, and the moon."
	icon = 'icons/turf/floors.dmi'
	icon_state = "hole1"
	anchored = TRUE
	density = FALSE
	pixel_y = 5
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/weakref/owner_werewolf_ref
	var/datum/weakref/owner_mind_ref
	var/list/invited_werewolf_ckeys

/obj/structure/werewolf_lair_entrance/Initialize(mapload, datum/antagonist/werewolf/owner_werewolf, turf/dug_wall)
	. = ..()
	invited_werewolf_ckeys = list()

	if(!mapload && !owner_werewolf)
		return INITIALIZE_HINT_QDEL

	if(istype(dug_wall))
		setDir(get_dir(src, dug_wall))
	else
		refresh_wall_visual_offset()

	if(mapload)
		return .

	owner_werewolf_ref = WEAKREF(owner_werewolf)
	if(owner_werewolf.owner)
		owner_mind_ref = WEAKREF(owner_werewolf.owner)

/obj/structure/werewolf_lair_entrance/setDir(newdir)
	..()
	refresh_wall_visual_offset()

/obj/structure/werewolf_lair_entrance/proc/refresh_wall_visual_offset()
	var/pixel_offset_x = 0
	var/pixel_offset_y = 0

	switch(dir)
		if(NORTH)
			pixel_offset_y = ICON_SIZE_Y
		if(SOUTH)
			pixel_offset_y = -ICON_SIZE_Y
		if(EAST)
			pixel_offset_x = ICON_SIZE_X
		if(WEST)
			pixel_offset_x = -ICON_SIZE_X

	set_base_pixel_x(pixel_offset_x)
	set_base_pixel_y(pixel_offset_y)

/obj/structure/werewolf_lair_entrance/Destroy()
	if(SSpocket_dimensions)
		SSpocket_dimensions.delete_instance(get_pocket_instance_key(), "The lair collapses and throws everything back outside!")

	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(owner_werewolf)
		var/obj/structure/werewolf_lair_entrance/current_lair = owner_werewolf.get_werewolf_lair_entrance()
		if(current_lair == src)
			owner_werewolf.lair_entrance_ref = null
		owner_werewolf.sync_werewolf_lair_tracking_action()

	invited_werewolf_ckeys = null
	owner_mind_ref = null
	owner_werewolf_ref = null
	return ..()

/obj/structure/werewolf_lair_entrance/attack_hand(mob/user, list/modifiers)
	. = ..()
	try_enter_user(user)

/obj/structure/werewolf_lair_entrance/attack_hand_secondary(mob/user, list/modifiers)
	if(!can_manage_invites(user, TRUE))
		return ..()

	show_invite_management_menu(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/werewolf_lair_entrance/attackby(obj/item/attacking_item, mob/living/user, list/modifiers)
	if(istype(attacking_item, /obj/item/grabbing))
		var/obj/item/grabbing/grab_item = attacking_item
		if(handle_grabbed_entry(user, grab_item))
			return TRUE

	return ..()

/obj/structure/werewolf_lair_entrance/examine(mob/user)
	. = ..()
	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(!owner_werewolf)
		. += span_warning("The burrow has gone dead and still.")
		return .

	if(is_owner_werewolf(user, owner_werewolf))
		. += span_notice("Right-click to manage invitations for other werewolves.")
		if(length(invited_werewolf_ckeys))
			. += span_notice("Invited werewolves: [english_list(get_invited_display_names())].")
		else
			. += span_notice("No other werewolves have been invited yet.")

/obj/structure/werewolf_lair_entrance/proc/get_owner_mind()
	var/datum/mind/owner_mind = owner_mind_ref?.resolve()
	if(owner_mind)
		return owner_mind

	owner_mind_ref = null
	var/datum/antagonist/werewolf/owner_werewolf = owner_werewolf_ref?.resolve()
	if(!owner_werewolf?.owner)
		return null

	owner_mind_ref = WEAKREF(owner_werewolf.owner)
	return owner_werewolf.owner

/obj/structure/werewolf_lair_entrance/proc/get_owner_werewolf()
	var/datum/mind/owner_mind = get_owner_mind()
	if(!owner_mind)
		owner_werewolf_ref = null
		return null

	var/datum/antagonist/werewolf/owner_werewolf = owner_mind.has_antag_datum(/datum/antagonist/werewolf)
	if(!owner_werewolf)
		owner_werewolf_ref = null
		return null

	owner_werewolf_ref = WEAKREF(owner_werewolf)
	return owner_werewolf

/obj/structure/werewolf_lair_entrance/proc/get_pocket_instance_key()
	return "werewolf_lair::[REF(src)]"

/obj/structure/werewolf_lair_entrance/proc/get_pocket_instance()
	return SSpocket_dimensions?.get_instance(get_pocket_instance_key())

/obj/structure/werewolf_lair_entrance/proc/get_or_create_pocket_instance()
	return SSpocket_dimensions?.get_or_create_instance(get_pocket_instance_key(), /datum/map_template/pocket/werewolf_lair, POCKET_LIFECYCLE_KEEP_LOADED, 0, src)

/obj/structure/werewolf_lair_entrance/proc/try_enter_user(mob/living/user)
	if(!can_user_enter_lair(user, FALSE, TRUE))
		return FALSE

	var/mob/living/knotted_victim = get_knotted_entry_target(user)
	if(knotted_victim)
		return force_movable_inside(user, knotted_victim, TRUE)

	var/datum/pocket_dimension/pocket_instance = get_or_create_pocket_instance()
	if(!pocket_instance)
		to_chat(user, span_warning("The lair refuses to open right now."))
		return FALSE

	to_chat(user, span_notice("I slip into the lair."))
	return pocket_instance.enter_mob(user, get_turf(src), src)

/obj/structure/werewolf_lair_entrance/proc/get_knotted_entry_target(mob/living/user)
	if(!ishuman(user))
		return null

	var/mob/living/carbon/human/human_user = user
	if(!IS_WEREWOLF(human_user))
		return null
	var/datum/component/knotting/knot_component = human_user.GetComponent(/datum/component/knotting)
	if(!knot_component)
		return null

	return knot_component.get_knotted_drag_target()

/obj/structure/werewolf_lair_entrance/proc/handle_grabbed_entry(mob/living/user, obj/item/grabbing/grab_item)
	if(!istype(user) || !istype(grab_item))
		return FALSE
	if(user.used_intent.type != /datum/intent/grab/move && user.used_intent.type != /datum/intent/grab/shove)
		return FALSE
	if(!can_werewolf_use_lair(user, TRUE))
		return FALSE

	var/mob/living/victim = grab_item.grabbed
	if(!istype(victim))
		to_chat(user, span_warning("Only living prey can be forced through the lair mouth."))
		return TRUE

	var/follow_inside = user.used_intent.type == /datum/intent/grab/move
	if(!force_movable_inside(user, victim, follow_inside))
		return TRUE

	user.stop_pulling()
	qdel(grab_item)
	return TRUE

/obj/structure/werewolf_lair_entrance/proc/force_movable_inside(mob/living/user, atom/movable/movable, follow_inside = FALSE)
	if(!movable || QDELETED(movable))
		return FALSE

	var/datum/pocket_dimension/pocket_instance = get_or_create_pocket_instance()
	if(!pocket_instance)
		to_chat(user, span_warning("The lair mouth refuses to open right now."))
		return FALSE

	var/turf/entrance_turf = get_turf(src)
	if(!pocket_instance.send_movable_inside(movable, entrance_turf, null, src))
		to_chat(user, span_warning("[movable] won't fit through the lair mouth."))
		return FALSE

	if(follow_inside && !pocket_instance.enter_mob(user, entrance_turf, src))
		to_chat(user, span_warning("The lair takes [movable], but bars my way."))
		return FALSE

	var/mob/living/victim = movable
	if(istype(victim))
		log_combat(user, victim, follow_inside ? "dragged into a werewolf lair" : "shoved into a werewolf lair")

	user.visible_message(
		span_warning("[user] [follow_inside ? "drags" : "shoves"] [movable] into [src]!"),
		span_notice("I [follow_inside ? "drag" : "shove"] [movable] into [src]."),
	)
	return TRUE

/obj/structure/werewolf_lair_entrance/proc/can_user_enter_lair(mob/living/user, forced = FALSE, show_feedback = FALSE)
	if(!istype(user))
		return FALSE

	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(!owner_werewolf)
		if(show_feedback)
			to_chat(user, span_warning("The lair has gone dead and still."))
		return FALSE

	if(is_owner_werewolf(user, owner_werewolf))
		return TRUE

	if(is_invited_werewolf(user))
		return TRUE

	if(forced)
		return TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(has_moonshackle_access(human_user))
			return TRUE

	if(show_feedback)
		to_chat(user, span_warning(get_access_denial_message(user)))
	return FALSE

/obj/structure/werewolf_lair_entrance/proc/can_werewolf_use_lair(mob/living/user, show_feedback = FALSE)
	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(!owner_werewolf)
		if(show_feedback)
			to_chat(user, span_warning("The lair has gone dead and still."))
		return FALSE

	if(is_owner_werewolf(user, owner_werewolf) || is_invited_werewolf(user))
		return TRUE

	if(show_feedback)
		to_chat(user, span_warning("Only the lair's owner or an invited werewolf can use this entrance that way."))
	return FALSE

/obj/structure/werewolf_lair_entrance/proc/is_owner_werewolf(mob/living/user, datum/antagonist/werewolf/owner_werewolf = null)
	owner_werewolf ||= get_owner_werewolf()
	var/datum/mind/owner_mind = owner_werewolf?.owner
	if(!owner_mind)
		owner_mind = get_owner_mind()
	if(!owner_mind)
		return FALSE
	if(!user?.mind || owner_mind != user.mind)
		return FALSE
	return !!IS_WEREWOLF(user)

/obj/structure/werewolf_lair_entrance/proc/is_invited_werewolf(mob/living/user)
	var/datum/antagonist/werewolf/requesting_werewolf = IS_WEREWOLF(user)
	if(!requesting_werewolf)
		return FALSE
	if(!length(invited_werewolf_ckeys))
		return FALSE
	return user.ckey in invited_werewolf_ckeys

/obj/structure/werewolf_lair_entrance/proc/has_moonshackle_access(mob/living/carbon/human/human_user)
	if(istype(human_user.wear_neck, /obj/item/clothing/neck/moonshackle_collar))
		return TRUE

	for(var/obj/item/held_item as anything in human_user.held_items)
		if(istype(held_item, /obj/item/clothing/neck/moonshackle_collar))
			return TRUE

	return FALSE

/obj/structure/werewolf_lair_entrance/proc/get_access_denial_message(mob/living/user)
	if(IS_WEREWOLF(user))
		return "This lair belongs to another werewolf. I need an invitation to enter."
	return "I need a moonshackle collar, or a werewolf to force me through, before the lair will take me."

/obj/structure/werewolf_lair_entrance/proc/can_manage_invites(mob/living/user, show_feedback = FALSE)
	var/datum/antagonist/werewolf/owner_werewolf = get_owner_werewolf()
	if(!owner_werewolf)
		if(show_feedback)
			to_chat(user, span_warning("The lair has gone dead and still."))
		return FALSE
	if(!istype(user))
		return FALSE
	if(!user.Adjacent(src))
		if(show_feedback)
			to_chat(user, span_warning("I need to stand by my lair entrance first."))
		return FALSE
	if(is_owner_werewolf(user, owner_werewolf))
		return TRUE
	if(show_feedback)
		to_chat(user, span_warning("Only the lair's owner can manage invitations."))
	return FALSE

/obj/structure/werewolf_lair_entrance/proc/show_invite_management_menu(mob/living/user)
	var/choice = tgui_alert(user, "What do I want to do with my lair?", "Moon Lair", list("Invite", "Revoke", "Cancel"))
	if(!choice || choice == "Cancel")
		return FALSE
	if(!can_manage_invites(user))
		return FALSE

	switch(choice)
		if("Invite")
			return invite_werewolf_by_name(user)
		if("Revoke")
			return revoke_werewolf_by_name(user)

	return FALSE

/obj/structure/werewolf_lair_entrance/proc/invite_werewolf_by_name(mob/living/user)
	var/invitee_name = stripped_input(user, "Enter the name of the werewolf to invite.", "Moon Lair", "", MAX_NAME_LEN)
	if(!invitee_name)
		return FALSE
	if(!can_manage_invites(user))
		return FALSE

	var/datum/mind/invitee_mind = find_werewolf_mind_by_name(invitee_name)
	if(!invitee_mind)
		to_chat(user, span_warning("No werewolf by that name answers the moon."))
		return FALSE

	if(invitee_mind == get_owner_mind())
		to_chat(user, span_notice("It is already my lair."))
		return FALSE

	var/mob/living/carbon/human/invitee = invitee_mind.current
	if(!istype(invitee) || !invitee.ckey)
		to_chat(user, span_warning("That werewolf is not in a form I can invite right now."))
		return FALSE

	if(invitee.ckey in invited_werewolf_ckeys)
		to_chat(user, span_notice("[invitee] already knows the way into my lair."))
		return FALSE

	invited_werewolf_ckeys += invitee.ckey
	to_chat(user, span_notice("[invitee] is now welcome in my lair."))
	to_chat(invitee, span_notice("[user] invites me into [user.p_their()] lair."))
	return TRUE

/obj/structure/werewolf_lair_entrance/proc/revoke_werewolf_by_name(mob/living/user)
	if(!length(invited_werewolf_ckeys))
		to_chat(user, span_notice("No werewolves are currently invited into my lair."))
		return FALSE

	var/revoke_name = stripped_input(user, "Enter the name of the werewolf to revoke.", "Moon Lair", "", MAX_NAME_LEN)
	if(!revoke_name)
		return FALSE
	if(!can_manage_invites(user))
		return FALSE

	var/revoked_ckey = find_invited_werewolf_ckey_by_name(revoke_name)
	if(!revoked_ckey)
		to_chat(user, span_warning("No invited werewolf matches that name."))
		return FALSE

	invited_werewolf_ckeys -= revoked_ckey
	to_chat(user, span_notice("That werewolf is no longer welcome in my lair."))

	for(var/datum/mind/werewolf_mind as anything in SSmapping.retainer.werewolves)
		if(!werewolf_mind?.current)
			continue
		if(werewolf_mind.current.ckey != revoked_ckey)
			continue
		to_chat(werewolf_mind.current, span_warning("[user] has revoked your invitation to [user.p_their()] lair."))
		break

	return TRUE

/obj/structure/werewolf_lair_entrance/proc/find_werewolf_mind_by_name(search_name)
	var/needle = LOWER_TEXT(search_name)

	for(var/datum/mind/werewolf_mind as anything in SSmapping.retainer.werewolves)
		if(!werewolf_mind?.has_antag_datum(/datum/antagonist/werewolf))
			continue

		var/mob/living/carbon/human/current_mob = werewolf_mind.current
		if(!istype(current_mob))
			continue
		if(LOWER_TEXT(current_mob.real_name) == needle || LOWER_TEXT(current_mob.name) == needle)
			return werewolf_mind

	return null

/obj/structure/werewolf_lair_entrance/proc/find_invited_werewolf_ckey_by_name(search_name)
	var/search_ckey = ckey(search_name)
	if(search_ckey in invited_werewolf_ckeys)
		return search_ckey

	var/needle = LOWER_TEXT(search_name)
	for(var/datum/mind/werewolf_mind as anything in SSmapping.retainer.werewolves)
		if(!werewolf_mind?.has_antag_datum(/datum/antagonist/werewolf))
			continue

		var/mob/living/carbon/human/current_mob = werewolf_mind.current
		if(!istype(current_mob) || !(current_mob.ckey in invited_werewolf_ckeys))
			continue
		if(LOWER_TEXT(current_mob.real_name) == needle || LOWER_TEXT(current_mob.name) == needle)
			return current_mob.ckey

	return null

/obj/structure/werewolf_lair_entrance/proc/get_invited_display_names()
	var/list/display_names = list()
	if(!length(invited_werewolf_ckeys))
		return display_names

	for(var/invited_ckey in invited_werewolf_ckeys)
		var/display_name = invited_ckey
		for(var/datum/mind/werewolf_mind as anything in SSmapping.retainer.werewolves)
			var/mob/living/carbon/human/current_mob = werewolf_mind?.current
			if(!istype(current_mob) || current_mob.ckey != invited_ckey)
				continue
			display_name = current_mob.real_name
			break
		display_names += display_name

	return display_names

/datum/action/innate/werewolf_lair_scent
	name = "Sniff Den"
	desc = "Taste the wind and follow the pull back to your lair entrance."
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_PHASED
	button_icon_state = WW_LAIR_SNIFF_ICON_STATE

/datum/action/innate/werewolf_lair_scent/IsAvailable()
	. = ..()
	if(!.)
		return FALSE

	var/datum/antagonist/werewolf/owner_werewolf = target
	if(!istype(owner_werewolf))
		return FALSE

	return owner_werewolf.can_track_werewolf_lair(owner)

/datum/action/innate/werewolf_lair_scent/Activate()
	. = ..()
	var/datum/antagonist/werewolf/owner_werewolf = target
	if(!istype(owner_werewolf))
		return

	owner_werewolf.sniff_werewolf_lair(owner)

#undef WW_LAIR_SNIFF_ICON_STATE
#undef WW_LAIR_DISTANCE_IMMEDIATE
#undef WW_LAIR_DISTANCE_NEAR
#undef WW_LAIR_DISTANCE_MID
#undef WW_LAIR_DISTANCE_FAR
