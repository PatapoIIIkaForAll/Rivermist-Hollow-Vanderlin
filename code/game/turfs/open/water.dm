///////////// OVERLAY EFFECTS /////////////
/obj/effect/overlay/water
	icon = 'icons/turf/newwater.dmi'
	icon_state = "bottom"
	density = FALSE
	mouse_opacity = FALSE
	layer = MID_TURF_LAYER
	anchored = TRUE

/obj/effect/overlay/water/top
	icon_state = "top"
	layer = MID_TURF_LAYER

/// Safely updates a water overlay after movement has finished settling.
/proc/update_delayed_water_overlay(turf/possible_water, atom/movable/expected_occupant, target_layer, target_plane, require_empty)
	var/turf/open/water/water = possible_water
	if(!istype(water) || !water.water_overlay)
		return
	if(require_empty)
		if(locate(/mob/living) in water)
			return
	else if(QDELETED(expected_occupant) || expected_occupant.loc != water)
		return
	water.water_overlay.layer = target_layer
	water.water_overlay.plane = target_plane

/turf/open/water
	gender = PLURAL
	name = "water"
	desc = "It's... well, water."
	icon = 'icons/turf/newwater.dmi'
	icon_state = "together"
	baseturfs = /turf/open/water
	slowdown = 20
	var/obj/effect/overlay/water/water_overlay
	var/obj/effect/overlay/water/top/water_top_overlay
	/// Appearance used while a dynamic water tile is dry.
	var/mutable_appearance/dry_overlay
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	smoothing_flags = SMOOTH_EDGE
	smoothing_groups = SMOOTH_GROUP_FLOOR_LIQUID
	smoothing_list = SMOOTH_GROUP_OPEN_FLOOR + SMOOTH_GROUP_CLOSED + SMOOTH_GROUP_CLOSED_WALL
	neighborlay_self = "edge"
	heelstep = null
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	landsound = 'sound/foley/jumpland/waterland.ogg'
	shine = SHINE_SHINY
	no_over_text = FALSE
	spread_chance = 0
	burn_power = 0
	/// if we use water_height to pick the overlay
	var/uses_height = TRUE
	/// Determines depth based behavior and which overlays to apply. Heights in order are ANKLE, SHALLOW, DEEP, FULL.
	var/water_height = WATER_HEIGHT_SHALLOW
	var/datum/reagent/water_reagent = /datum/reagent/water
	/// infinite source of water
	var/mapped = TRUE
	/// 100 is 1 bucket. Minimum of 10 to count as a water tile
	var/water_volume = 100
	var/water_maximum = 10000 //this is since water is stored in the originate
	var/wash_in = TRUE
	var/swim_skill = FALSE
	var/swimdir = FALSE
	/// cant pick up with reagent containers
	var/notake = FALSE
	var/set_relationships_on_init = TRUE
	/// if the water tile is open from below
	var/open_bottom = FALSE
	/// for tiles that should always have deep water behavior without an open bottom
	var/fake_bottomless = FALSE
	/// for tiles that should always have a closed bottom
	var/skip_bottom_check = FALSE
	/// Map- or subtype-configured depth, before live multi-z topology is applied.
	var/configured_water_height
	/// Map- or subtype-configured swimming slowdown behavior.
	var/configured_swim_skill
	/// Appearance restored when this turf no longer has an open bottom.
	var/configured_icon_state
	var/configured_layer
	var/configured_plane
	var/configured_shine
	/// Whether LateInitialize has made it safe to attach water-state elements.
	var/water_elements_initialized = FALSE
	/// Configuration of the currently attached water-state elements.
	var/water_elements_active = FALSE
	var/active_element_height
	var/active_element_swimmable = FALSE
	/// Whether this turf currently owns a z-transparency element.
	var/water_transparency_active = FALSE
	// A bitflag of blocked directions. ONLY works because we only allow cardinal flow.
	var/blocked_flow_directions = 0

	var/cached_use = 0

	var/cleanliness_factor = 1 //related to hygiene for washing

	/// Fishing element for this specific water tile
	var/datum/fish_source/fishing_datum = /datum/fish_source/water
	flags_1 = CONDUCT_1

/// Whether this turf currently immerses its contents.
/turf/open/water/proc/is_immersing()
	return water_volume >= 10 && water_height >= WATER_HEIGHT_ANKLE && !HAS_TRAIT(src, TRAIT_IMMERSE_STOPPED)

/// Whether living mobs on this turf should receive the swimming status.
/turf/open/water/proc/is_swimmable()
	return is_immersing() && (water_height >= WATER_HEIGHT_DEEP || open_bottom || fake_bottomless)

/// Recalculate the open bottom from the live turf below instead of initialization order.
/turf/open/water/proc/refresh_water_depth(update_above = TRUE)
	if(isnull(configured_water_height))
		return

	var/was_open_bottom = open_bottom
	var/old_water_height = water_height
	open_bottom = FALSE
	water_height = configured_water_height
	swim_skill = configured_swim_skill

	if(!skip_bottom_check && water_volume >= 10)
		var/turf/open/water/below = GET_TURF_BELOW(src)
		if(istype(below) && below.water_volume >= 10 && below.water_height == WATER_HEIGHT_FULL && below.water_reagent == water_reagent)
			open_bottom = TRUE
			water_height = max(water_height, WATER_HEIGHT_DEEP)
			swim_skill = TRUE

	if(water_elements_initialized && (was_open_bottom != open_bottom || old_water_height != water_height))
		sync_water_elements()
		sync_water_transparency()

	if(update_above)
		var/turf/open/water/above = GET_TURF_ABOVE(src)
		if(istype(above))
			above.refresh_water_depth(update_above = FALSE)

/// Attach exactly one immersion/wetness/swimming configuration for the current water state.
/turf/open/water/proc/sync_water_elements()
	if(!water_elements_initialized)
		return

	var/should_immerse = is_immersing()
	var/should_swim = is_swimmable()
	if(water_elements_active && active_element_height == water_height && active_element_swimmable == should_swim && should_immerse)
		return

	clear_water_elements()
	if(!should_immerse)
		ADD_TRAIT(src, TRAIT_IMMERSE_STOPPED, INNATE_TRAIT)
		return

	REMOVE_TRAIT(src, TRAIT_IMMERSE_STOPPED, INNATE_TRAIT)
	AddElement(/datum/element/immerse, water_height, should_swim)
	AddElement(/datum/element/watery_tile, water_height, cleanliness_factor)
	if(should_swim)
		var/stamina_cost = water_height == WATER_HEIGHT_FULL ? 10 : 5
		AddElement(/datum/element/swimming_tile, stamina_cost, 2, water_height == WATER_HEIGHT_FULL)

	water_elements_active = TRUE
	active_element_height = water_height
	active_element_swimmable = should_swim

/// Detach water-state elements with the exact bespoke arguments used to attach them.
/turf/open/water/proc/clear_water_elements()
	if(!water_elements_active)
		return

	if(active_element_swimmable)
		var/stamina_cost = active_element_height == WATER_HEIGHT_FULL ? 10 : 5
		RemoveElement(/datum/element/swimming_tile, stamina_cost, 2, active_element_height == WATER_HEIGHT_FULL)
	RemoveElement(/datum/element/watery_tile, active_element_height, cleanliness_factor)
	RemoveElement(/datum/element/immerse, active_element_height, active_element_swimmable)
	water_elements_active = FALSE
	active_element_height = null
	active_element_swimmable = FALSE

/// Keep z-transparency paired with the live open-bottom state.
/turf/open/water/proc/sync_water_transparency()
	if(open_bottom == water_transparency_active)
		return

	if(open_bottom)
		icon_state = "openspace"
		AddElement(/datum/element/turf_z_transparency, TRUE)
		water_transparency_active = TRUE
		return

	RemoveElement(/datum/element/turf_z_transparency, TRUE)
	water_transparency_active = FALSE
	icon_state = configured_icon_state
	layer = configured_layer
	plane = configured_plane

/// Restore the normal wet overlay and reflection state after a dry tile refills.
/turf/open/water/proc/restore_wet_appearance()
	if(dry_overlay)
		cut_overlay(dry_overlay)
		dry_overlay = null
	if(configured_shine)
		make_shiny(configured_shine)
	else
		shine = configured_shine

/turf/open/water/proc/set_watervolume(volume)
	water_volume = volume
	if(src in children)
		return
	handle_water()

	for(var/turf/open/water/river/water in children)
		water.set_watervolume(volume - 10)
		water.check_surrounding_water()
	check_surrounding_water()

/turf/open/water/proc/adjust_watervolume(volume)
	water_volume += volume
	handle_water()

	for(var/turf/open/water/river/water in children)
		water.adjust_watervolume(volume)
		water.check_surrounding_water()
	check_surrounding_water()

/turf/open/water/proc/adjust_originate_watervolume(volume)
	var/turf/open/water/adjuster = source_originate
	if(!adjuster)
		adjuster = src
	if(volume < 10 && mapped)
		if(adjuster.water_volume + volume < initial(adjuster.water_volume))
			return
	adjuster.water_volume += volume
	handle_water()
	if(adjuster.mapped) //means no changes downstream
		return
	for(var/turf/open/water/river/water in adjuster.children)
		water.adjust_watervolume(volume)
		water.check_surrounding_water()
	check_surrounding_water()

/turf/open/water/proc/toggle_block_state(dir, value)
	if(value)
		blocked_flow_directions |= dir
	else
		blocked_flow_directions &= ~dir
	if(blocked_flow_directions & dir)
		var/turf/open/water/river/water = get_step(src, dir)
		if(!istype(water))
			return
		if(water.mapped)
			return
		water.set_watervolume(0)
		water.check_surrounding_water()
		for(var/turf/open/water/child in children)
			addtimer(CALLBACK(child, PROC_REF(recursive_clear_icon)), 0.25 SECONDS)
		for(var/turf/open/water/conflict as anything in conflicting_originate_turfs)
			conflict.check_surrounding_water(TRUE)
	else
		check_surrounding_water()

/turf/open/water/proc/dryup(forced = FALSE)
	if(!forced && water_volume >= 10)
		return

	ADD_TRAIT(src, TRAIT_IMMERSE_STOPPED, INNATE_TRAIT)
	clear_water_elements()
	smoothing_flags = NONE
	remove_neighborlays()
	if(water_overlay)
		QDEL_NULL(water_overlay)
	if(water_top_overlay)
		QDEL_NULL(water_top_overlay)
	make_unshiny()
	if(!dry_overlay)
		dry_overlay = mutable_appearance('icons/turf/natural/liquids.dmi', "rock")
		add_overlay(dry_overlay)
	for(var/obj/structure/waterwheel/rotator in contents)
		rotator.set_rotational_direction_and_speed(null, 0)
		rotator.set_stress_generation(0)

/turf/open/water/river/creatable
	mapped = FALSE
	river_processes = FALSE
	icon_state = "together"
	baseturfs = /turf/open/openspace

/turf/open/water/river/handle_water()
	refresh_water_depth()
	if(water_volume < 10)
		dryup()
	else if(water_volume)
		restore_wet_appearance()
		REMOVE_TRAIT(src, TRAIT_IMMERSE_STOPPED, INNATE_TRAIT)
		sync_water_elements()
		if(!water_overlay)
			water_overlay = new(src)
		if(!water_top_overlay)
			water_top_overlay = new(src)
		if(!LAZYLEN(neighborlay_list))
			smoothing_flags = SMOOTH_EDGE
			QUEUE_SMOOTH(src)

	if(!river_processes)
		icon_state = "together"
		if(water_overlay)
			water_overlay.color = water_reagent.color
			water_overlay.icon_state = "bottom[water_height]"
		if(water_top_overlay)
			water_top_overlay.color = water_reagent.color
			if(water_height == WATER_HEIGHT_FULL)
				water_top_overlay.icon_state = null
			else
				water_top_overlay.icon_state = "top[water_height]"
		return
	icon_state = base_icon_state

	if(water_overlay)
		water_overlay.color = water_reagent.color
		if(water_height == WATER_HEIGHT_FULL)
			water_overlay.icon_state = "riverbotdeep"
		else
			water_overlay.icon_state = "riverbot"
		water_overlay.dir = dir
	if(water_top_overlay)
		water_top_overlay.color = water_reagent.color
		if(water_height == WATER_HEIGHT_FULL)
			water_top_overlay.icon_state = null
		else
			water_top_overlay.icon_state = "rivertop"
		water_top_overlay.dir = dir

/turf/open/water/river/creatable/Initialize()
	var/list/viable_directions = list()
	for(var/direction in GLOB.cardinals)
		var/turf/open/water/water = get_step(src, direction)
		if(!istype(water))
			continue
		viable_directions |= direction
	if(length(viable_directions) == 4 || length(viable_directions) == 0)
		return ..()
	river_processes = TRUE
	icon_state = base_icon_state
	var/picked_dir = pick(viable_directions)
	dir = REVERSE_DIR(picked_dir)
	handle_water()
	return ..()

/turf/open/water/river/creatable/attackby(obj/item/C, mob/user, list/modifiers)
	if(istype(C, /obj/item/reagent_containers/glass/bucket/wooden) && user.used_intent.type == /datum/intent/splash)
		try_modify_water(user, C)
		return TRUE
	if(istype(C, /obj/item/weapon/shovel))
		if((user.used_intent.type == /datum/intent/shovelscoop))
			var/obj/item/weapon/shovel/shovel = C
			if(!shovel.heldclod)
				return
			user.visible_message("[user] starts filling in [src].", "I start filling in [src].")
			if(!do_after(user, 10 SECONDS * shovel.time_multiplier, src))
				return
			QDEL_NULL(shovel.heldclod)
			shovel.update_appearance(UPDATE_ICON_STATE)
			ScrapeAway()
			return TRUE
	. = ..()

/turf/open/water/river/creatable/proc/try_modify_water(mob/user, obj/item/reagent_containers/glass/bucket/wooden/bucket)
	if(user.used_intent.type == /datum/intent/splash)
		if(bucket.reagents?.total_volume)
			var/datum/reagent/container_reagent = bucket.reagents.get_master_reagent()
			var/water_count = bucket.reagents.get_reagent_amount(container_reagent.type)
			user.visible_message("[user] starts to fill [src].", "You start to fill [src].")
			if(do_after(user, 3 SECONDS, src))
				if(bucket.reagents.remove_reagent(container_reagent.type, clamp(container_reagent.volume, 1, 100)))
					playsound(src, 'sound/foley/waterenter.ogg', 100, FALSE)
					adjust_originate_watervolume(water_count)

/turf/open/water/Initialize()
	. = ..()
	configured_water_height = water_height
	configured_swim_skill = swim_skill
	configured_icon_state = icon_state
	configured_layer = layer
	configured_plane = plane
	configured_shine = shine
	refresh_water_depth()

	if(!isnull(fishing_datum))
		add_lazy_fishing(fishing_datum)

	if(mapped)
		if(prob(0.1))
			new /obj/item/bottlemessage/ancient(src)
	else
		START_PROCESSING(SSobj, src)

	handle_water()

	return INITIALIZE_HINT_LATELOAD

/turf/open/water/LateInitialize()
	. = ..()
	water_elements_initialized = TRUE
	refresh_water_depth()
	sync_water_elements()
	sync_water_transparency()
	if(set_relationships_on_init)
		check_surrounding_water()

/turf/open/water/examine(mob/user)
	. = ..()
	if(water_volume < 10)
		return
	if(fake_bottomless)
		. += span_notice("I can't see the bottom...")
	else if(water_height >= WATER_HEIGHT_FULL)
		return
	var/depth_message
	switch(water_height)
		if(WATER_HEIGHT_ANKLE)
			depth_message = "ankle deep."
		if(WATER_HEIGHT_SHALLOW)
			depth_message = "about waist high."
		if(WATER_HEIGHT_DEEP)
			depth_message = "rather deep."
	. += span_notice("It looks [depth_message]")

/turf/open/water/process()
	if(cached_use)
		adjust_originate_watervolume(cached_use)
		cached_use = 0

	if(water_overlay && water_volume < 10)
		dryup()

/turf/open/water/proc/handle_water()
	refresh_water_depth()
	if(!water_volume || water_volume < 10)
		dryup()
		return
	restore_wet_appearance()
	REMOVE_TRAIT(src, TRAIT_IMMERSE_STOPPED, INNATE_TRAIT)
	sync_water_elements()
	if(!water_overlay)
		water_overlay = new(src)
	if(!water_top_overlay)
		water_top_overlay = new(src)
	if(!LAZYLEN(neighborlay_list))
		smoothing_flags = SMOOTH_EDGE
		QUEUE_SMOOTH(src)

	if(water_overlay)
		water_overlay.color = water_reagent.color
		if(uses_height)
			water_overlay.icon_state = "bottom[water_height]"
	if(water_top_overlay)
		water_top_overlay.color = water_reagent.color
		if(uses_height)
			if(water_height == WATER_HEIGHT_FULL)
				water_top_overlay.icon_state = null
			else
				water_top_overlay.icon_state = "top[water_height]"

/turf/open/water/add_neighborlay(dir, edgeicon, offset = FALSE)
	var/add
	var/y = 0
	var/x = 0
	switch(dir)
		if(NORTH)
			add = "[edgeicon]-n"
			y = -32
		if(SOUTH)
			add = "[edgeicon]-s"
			y = 32
		if(EAST)
			add = "[edgeicon]-e"
			x = -32
		if(WEST)
			add = "[edgeicon]-w"
			x = 32

	if(!add)
		return

	if(water_overlay)
		var/image/overlay = image(icon, water_overlay, add, ABOVE_MOB_LAYER + 0.01, pixel_x = offset ? x : 0, pixel_y = offset ? y : 0 )
		overlay.color = water_reagent.color
		if("[dir]" in water_overlay.neighborlay_list)
			water_overlay.cut_overlay(water_overlay.neighborlay_list["[dir]"])
			qdel(water_overlay.neighborlay_list["[dir]"])
			LAZYREMOVE(water_overlay.neighborlay_list, "[dir]")
		LAZYADDASSOC(water_overlay.neighborlay_list, "[dir]", overlay)
		water_overlay.add_overlay(overlay)

/turf/open/water/remove_neighborlays()
	var/list/overlays = water_overlay?.neighborlay_list
	if(!LAZYLEN(overlays))
		return
	for(var/key in overlays)
		water_overlay.cut_overlay(overlays[key])
		QDEL_NULL(overlays[key])
		LAZYREMOVE(overlays, key)

/turf/open/water/Exited(atom/movable/gone, atom/new_loc)
	. = ..()
	var/blocked_z_out_down = FALSE
	for(var/obj/structure/S in src)
		if(S.obj_flags & BLOCK_Z_OUT_DOWN)
			blocked_z_out_down = TRUE
			break

	if(isliving(gone) && !gone.throwing)
		if(blocked_z_out_down)
			return
		if(water_overlay)
			if((get_dir(src, new_loc) == SOUTH))
				water_overlay.layer = BELOW_MOB_LAYER
				water_overlay.plane = GAME_PLANE
			else
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(update_delayed_water_overlay), src, null, BELOW_MOB_LAYER, GAME_PLANE, TRUE), 6)

/turf/open/water/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum, damage_type = "blunt")
	. = ..()
	if(water_volume < 10)
		return
	playsound(src, pick('sound/foley/water_land1.ogg','sound/foley/water_land2.ogg','sound/foley/water_land3.ogg'), 100, FALSE)
	if(isobj(AM))
		var/obj/object = AM
		object.extinguish()

/turf/open/water/can_zFall(atom/movable/A, levels = 1, turf/target)
	if(!zPassOut(A, DOWN, target) || !target.zPassIn(A, DOWN, src))
		return FALSE
	if(!open_bottom && !fake_bottomless)
		return FALSE
	return HAS_TRAIT(A, TRAIT_SINKING)

/turf/open/water/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	for(var/obj/structure/S in src)
		if(S.obj_flags & BLOCK_Z_OUT_DOWN)
			return
	if(water_volume < 10)
		return
	if(istype(arrived, /obj/item/reagent_containers/food/snacks/fish))
		var/obj/item/reagent_containers/food/snacks/fish/F = arrived
		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_FISH_RELEASED, F)
		if(!F.status != FISH_DEAD)
			F.visible_message("<span class='warning'>[F] dives into \the [src] and disappears!</span>")
		else
			F.visible_message("<span class='warning'>[F] slowly sinks motionlessly into \the [src] and disappears...</span>")
		qdel(F)
	if(isliving(arrived) && !arrived.throwing)
		if(water_overlay)
			if(water_height > WATER_HEIGHT_ANKLE && !istype(old_loc, type))
				playsound(arrived, 'sound/foley/waterenter.ogg', 100, FALSE)
			else
				playsound(arrived, pick('sound/foley/watermove (1).ogg','sound/foley/watermove (2).ogg'), 100, FALSE)
			if(istype(old_loc, type) && (get_dir(src, old_loc) != SOUTH))
				water_overlay.layer = ABOVE_MOB_LAYER
				water_overlay.plane = GAME_PLANE
			else
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(update_delayed_water_overlay), src, arrived, ABOVE_MOB_LAYER, GAME_PLANE, FALSE), 6)

/turf/open/water/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!tool.reagents)
		return NONE

	if(istype(user.used_intent, /datum/intent/fill))
		if(notake)
			return NONE

		if(tool.reagents.holder_full())
			to_chat(user, "<span class='warning'>[tool] is full.</span>")
			return ITEM_INTERACT_BLOCKING

		if(water_volume < 10)
			return ITEM_INTERACT_BLOCKING

		if(!do_after(user, 8 DECISECONDS, src))
			return ITEM_INTERACT_BLOCKING

		playsound(user, 'sound/foley/drawwater.ogg', 100, FALSE)

		if(!mapped && tool.reagents.add_reagent(water_reagent, 10))
			adjust_originate_watervolume(-10)
		else
			// Infinite water should fill containers of any size, including RMH's larger pots.
			tool.reagents.add_reagent(water_reagent, tool.reagents.maximum_volume - tool.reagents.total_volume)

		to_chat(user, "<span class='notice'>I fill [tool] from [src].</span>")
		user.changeNext_move(CLICK_CD_MELEE)

		return ITEM_INTERACT_SUCCESS

	if(istype(user.used_intent, /datum/intent/food))
		if(mapped)
			return NONE

		if(water_volume >= water_maximum)
			to_chat(user, "<span class='warning'>\The [name] is full.</span>")
			return ITEM_INTERACT_BLOCKING

		if(!do_after(user, 8 DECISECONDS, src))
			return ITEM_INTERACT_BLOCKING

		playsound(user, 'sound/foley/drawwater.ogg', 100, FALSE)

		var/water_count = tool.reagents.get_reagent_amount(water_reagent.type)
		if(tool.reagents.remove_reagent(water_reagent,  tool.reagents.total_volume))
			set_watervolume(clamp(water_volume + water_count, 1, water_maximum))

		to_chat(user, "<span class='notice'>I pour the contents of [tool] into [src].</span>")
		user.changeNext_move(CLICK_CD_MELEE)

		return ITEM_INTERACT_SUCCESS

/turf/open/water/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(user.cmode)
		return NONE

	if(water_volume < 10)
		return ITEM_INTERACT_BLOCKING

	// This should just be reagent interactions :(

	playsound(user, pick(list('sound/foley/waterwash (1).ogg', 'sound/foley/waterwash (2).ogg')), 100, FALSE)

	user.visible_message("<span class='info'>[user] starts to wash [tool] in [src].</span>")

	if(!do_after(user, 3 SECONDS, src))
		return ITEM_INTERACT_BLOCKING

	if(wash_in)
		tool.wash(CLEAN_WASH)

	if(istype(tool, /obj/item/clothing))
		var/obj/item/clothing/item2wash_cloth = tool
		if(item2wash_cloth && item2wash_cloth.wetable)
			if(cleanliness_factor > 0)
				item2wash_cloth.wet.add_water(20, dirty = FALSE, washed_properly = TRUE)
			else
				item2wash_cloth.wet.add_water(20, dirty = TRUE, washed_properly = TRUE)

	user.nobles_seen_servant_work()

	playsound(user, pick(list('sound/foley/waterwash (1).ogg', 'sound/foley/waterwash (2).ogg')), 100, FALSE)

	return ITEM_INTERACT_SUCCESS

/turf/open/water/attack_hand(mob/user)
	if(isliving(user))
		if(get_turf(user) != src)
			return
		if(user.stat != CONSCIOUS)
			return
		try_z_swim(user, going_up = FALSE)

/turf/open/water/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(water_volume < 10)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/list/wash = list('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg')
	if(isliving(user))
		var/mob/living/L = user
		user.visible_message("<span class='info'>[user] starts to wash in [src].</span>")
		if(do_after(L, 3 SECONDS, src))
			if(wash_in)
				user.wash(CLEAN_WASH)
			var/datum/reagents/reagents = new()
			reagents.add_reagent(water_reagent, 4)
			reagents.trans_to(L, reagents.total_volume, transfered_by = user, method = TOUCH)
			if(!mapped)
				adjust_originate_watervolume(-2)
			playsound(user, pick(wash), 100, FALSE)

			L.ExtinguishMob()
			//handle hygiene and clean off alcohol
			var/list/equipped_items = L.get_equipped_items()
			if(length(equipped_items) > 0)
				to_chat(user, span_notice("I could probably clean myself faster if I weren't wearing clothes..."))
				L.adjust_hygiene(HYGIENE_GAIN_CLOTHED * cleanliness_factor)
				L.adjust_fire_stacks(-4)
			else
				L.adjust_hygiene(HYGIENE_GAIN_UNCLOTHED * cleanliness_factor)
				L.adjust_fire_stacks(-2)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/turf/open/water/onbite(mob/living/user)
	. = ..()
	if(.)
		return
	if(water_volume < 10)
		return TRUE
	playsound(user, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 100, FALSE)
	user.visible_message(span_info("[user] starts to drink from [src]."))
	if(!do_after(user, 2.5 SECONDS, src))
		return TRUE
	var/datum/reagents/reagents = new()
	reagents.add_reagent(water_reagent, 2)
	reagents.trans_to(user, reagents.total_volume, transfered_by = user, method = INGEST)
	if(!mapped)
		adjust_originate_watervolume(-2)
	playsound(user,pick('sound/items/drink_gen (1).ogg','sound/items/drink_gen (2).ogg','sound/items/drink_gen (3).ogg'), 100, TRUE)
	return TRUE

/turf/open/water/Destroy()
	STOP_PROCESSING(SSobj, src)
	clear_water_elements()
	if(water_transparency_active)
		RemoveElement(/datum/element/turf_z_transparency, TRUE)
		water_transparency_active = FALSE
	QDEL_NULL(water_overlay)
	QDEL_NULL(water_top_overlay)
	dry_overlay = null
	return ..()

/turf/open/water/get_slowdown(mob/user)
	. = ..()
	if(. <= 0)
		return 0
	if(water_volume < 10 || HAS_TRAIT(user, TRAIT_GOOD_SWIM))
		return 0
	if(swim_skill)
		return max(0, . - (GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/swimming)))

/// Attempt voluntary vertical movement through connected water turfs.
/turf/open/water/proc/try_z_swim(mob/living/swimming_mob, going_up)
	if(QDELETED(swimming_mob) || get_turf(swimming_mob) != src)
		return FALSE
	if(!is_swimmable() || !HAS_TRAIT(swimming_mob, TRAIT_MOVE_SWIMMING))
		return FALSE

	var/direction = going_up ? UP : DOWN
	if(water_height == WATER_HEIGHT_DEEP && direction == UP)
		to_chat(swimming_mob, span_warning("I am already at the surface."))
		return FALSE
	if(water_height != WATER_HEIGHT_DEEP && water_height != WATER_HEIGHT_FULL)
		return FALSE
	if(direction == UP && HAS_TRAIT(swimming_mob, TRAIT_SINKING))
		to_chat(swimming_mob, span_warningbig("I'm sinking and can't swim upwards!"))
		return FALSE

	var/z_move_flags = ZMOVE_SWIM_FLAGS | ZMOVE_FEEDBACK
	if(!swimming_mob.can_z_move(direction, src, z_move_flags = z_move_flags))
		return FALSE

	var/swim_time = 3 SECONDS - ((1 DECISECONDS * GET_MOB_SKILL_VALUE_OLD(swimming_mob, /datum/attribute/skill/misc/swimming)) + (1 SECONDS * HAS_TRAIT(swimming_mob, TRAIT_GOOD_SWIM)))
	if(!COOLDOWN_FINISHED(swimming_mob, cd_zswim))
		return FALSE
	COOLDOWN_START(swimming_mob, cd_zswim, max(swim_time, 1 DECISECONDS))
	if(!do_after(swimming_mob, max(swim_time, 1 DECISECONDS), hidden = TRUE))
		return FALSE
	if(QDELETED(swimming_mob) || get_turf(swimming_mob) != src || !HAS_TRAIT(swimming_mob, TRAIT_MOVE_SWIMMING))
		return FALSE

	if(!swimming_mob.zMove(direction, z_move_flags = z_move_flags))
		return FALSE
	if(QDELETED(swimming_mob))
		return TRUE
	var/datum/status_effect/swimming/swimming_status = swimming_mob.has_status_effect(/datum/status_effect/swimming)
	swimming_status?.spend_swimming_stamina()
	if(swimming_mob.stat == DEAD)
		return TRUE
	if(direction == UP)
		to_chat(swimming_mob, span_notice("I swim upward."))
	else
		to_chat(swimming_mob, span_notice("I swim downward."))
	return TRUE

/turf/open/water/zPassIn(atom/movable/A, direction, turf/source)
	if(direction == DOWN)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_DOWN)
				return FALSE
		return TRUE
	if(direction == UP && (open_bottom || fake_bottomless))
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_IN_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/water/zPassOut(atom/movable/A, direction, turf/destination)
	if(A.anchored && !isprojectile(A))
		return FALSE
	if(direction == DOWN && (open_bottom || fake_bottomless))
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_DOWN)
				return FALSE
		return TRUE
	if(direction == UP)
		for(var/obj/O in contents)
			if(O.obj_flags & BLOCK_Z_OUT_UP)
				return FALSE
		return TRUE
	return FALSE

/turf/open/water/zImpact(atom/movable/falling_atom, levels, turf/prev_turf)
	return FALSE

/*	..................   Bath & Pool   ................... */
/turf/open/water/bath
	name = "water"
	desc = "Faintly yellow colored. Suspicious."
	icon = 'icons/turf/natural/liquids.dmi'
	icon_state = MAP_SWITCH("bathtile", "bathtileW")
	water_height = WATER_HEIGHT_SHALLOW
	slowdown = 15
	cleanliness_factor = 5
	water_reagent = /datum/reagent/water

/turf/open/water/sewer
	name = "sewage"
	desc = "This dark water smells of dead rats."
	icon = 'icons/turf/natural/liquids.dmi'
	icon_state = MAP_SWITCH("paving", "pavingW")
	base_icon_state = "paving"
	water_height = WATER_HEIGHT_ANKLE
	slowdown = 1
	wash_in = FALSE
	water_reagent = /datum/reagent/water/gross/sewer
	heelstep = HEELSTEP_SHALLOW
	footstep = FOOTSTEP_MUD
	barefootstep = FOOTSTEP_MUD
	heavyfootstep = FOOTSTEP_MUD
	cleanliness_factor = -5
	fishing_datum = /datum/fish_source/sewer

/turf/open/water/sewer/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived) && !arrived.throwing)
		var/mob/living/living = arrived
		if(!living.client) // Leeches don't latch onto mobs anymore.
			return
		var/chance = 3
		if(living.m_intent == MOVE_INTENT_RUN)
			chance *= 2
		else if(living.m_intent == MOVE_INTENT_SNEAK)
			chance /= 2
		if(!prob(chance))
			return
		if(iscarbon(arrived))
			var/mob/living/carbon/C = arrived
			if(C.blood_volume <= 0 || C.is_bloodless())
				return
			var/list/zonee = list(BODY_ZONE_R_LEG,BODY_ZONE_L_LEG)
			for(var/i = 1, i <= zonee.len, i++)
				var/obj/item/bodypart/BP = C.get_bodypart(pick_n_take(zonee))
				if(!BP)
					continue
				if(BP.skeletonized)
					continue
				if(!BP.is_organic_limb())
					continue
				var/obj/item/natural/worms/leech/I = spawn_wild_leech(C)
				BP.add_embedded_object(I, silent = TRUE)
				return .

/turf/open/water/sewer/under
	icon_state = MAP_SWITCH("paving", "pavinggwf")
	water_height = WATER_HEIGHT_FULL
	swim_skill = TRUE
	shine = SHINE_MATTE

/datum/reagent/water/gross/sewer
	color = "#705a43"

/datum/reagent/water/gross/marshy
	color = "#60b17b"

/turf/open/water/swamp
	name = "murk"
	desc = "Weeds and algae cover the surface of the water."
	icon = 'icons/turf/natural/liquids.dmi'
	icon_state = MAP_SWITCH("dirt", "dirtW2")
	base_icon_state = "dirt"
	water_height = WATER_HEIGHT_SHALLOW
	slowdown = 20
	wash_in = FALSE
	water_reagent = /datum/reagent/water/gross/sewer
	cleanliness_factor = -5
	fishing_datum = /datum/fish_source/swamp

/turf/open/water/swamp/Initialize()
	dir = pick(GLOB.cardinals)
	. = ..()

/turf/open/water/swamp/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived) && !arrived.throwing)
		var/mob/living/living = arrived
		var/chance = 3
		if(living.m_intent == MOVE_INTENT_RUN)
			chance *= 2
		else if(living.m_intent == MOVE_INTENT_SNEAK)
			chance /= 2
		if(!prob(chance))
			return
		if(iscarbon(arrived))
			var/mob/living/carbon/C = arrived
			if(C.blood_volume <= 0 || C.is_bloodless())
				return
			var/list/zonee = list(BODY_ZONE_R_LEG,BODY_ZONE_L_LEG)
			for(var/i = 1, i <= zonee.len, i++)
				var/obj/item/bodypart/BP = C.get_bodypart(pick_n_take(zonee))
				if(!BP)
					continue
				if(BP.skeletonized)
					continue
				if(!BP.is_organic_limb())
					continue
				var/obj/item/natural/worms/leech/I = spawn_wild_leech(C)
				BP.add_embedded_object(I, silent = TRUE)
				return .

/turf/open/water/swamp/deep
	name = "murk"
	desc = "Deep water with several weeds and algae on the surface."
	icon_state = MAP_SWITCH("dirt", "dirtW")
	water_height = WATER_HEIGHT_DEEP
	slowdown = 20
	swim_skill = TRUE
	fishing_datum = /datum/fish_source/swamp/deep

/turf/open/water/swamp/deep/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived) && !arrived.throwing)
		var/mob/living/living = arrived
		var/chance = 8
		if(living.m_intent == MOVE_INTENT_RUN)
			chance *= 2
		else if(living.m_intent == MOVE_INTENT_SNEAK)
			chance /= 2
		if(!prob(chance))
			return
		if(iscarbon(arrived))
			var/mob/living/carbon/C = arrived
			if(C.blood_volume <= 0 || C.is_bloodless())
				return
			var/list/zonee = list(BODY_ZONE_CHEST,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_R_ARM,BODY_ZONE_L_ARM)
			for(var/i = 1, i <= zonee.len, i++)
				var/obj/item/bodypart/BP = C.get_bodypart(pick_n_take(zonee))
				if(!BP)
					continue
				if(BP.skeletonized)
					continue
				if(!BP.is_organic_limb())
					continue
				var/obj/item/natural/worms/leech/I = spawn_wild_leech(C)
				BP.add_embedded_object(I, silent = TRUE)
				return .

/turf/open/water/marsh
	name = "marshwater"
	desc = "A heavy layer of weeds and algae cover the surface of the water."
	icon = 'icons/turf/natural/liquids.dmi'
	icon_state = MAP_SWITCH("dirt", "dirtW3")
	water_height = WATER_HEIGHT_SHALLOW
	slowdown = 15
	wash_in = FALSE
	water_reagent = /datum/reagent/water/gross/marshy
	cleanliness_factor = -3
	fishing_datum = /datum/fish_source/swamp

/turf/open/water/marsh/Initialize()
	dir = pick(GLOB.cardinals)
	. = ..()

/turf/open/water/marsh/deep
	name = "marshwater"
	desc = "A heavy layer of weeds and algae cover the surface of the deep water."
	icon_state = MAP_SWITCH("dirt", "dirtW4")
	base_icon_state = "dirt"
	water_height = WATER_HEIGHT_DEEP
	slowdown = 20
	swim_skill = TRUE
	fishing_datum = /datum/fish_source/swamp/deep

/turf/open/water/clean
	name = "water"
	desc = "Crystal clear water, what a blessing!"
	icon = 'icons/turf/natural/liquids.dmi'
	icon_state = MAP_SWITCH("rock", "rockw2")
	base_icon_state = "rock"
	water_height = WATER_HEIGHT_SHALLOW
	slowdown = 15
	water_reagent = /datum/reagent/water
	fishing_datum = /datum/fish_source/cleanshallow

/turf/open/water/clean/Initialize()
	dir = pick(GLOB.cardinals)
	. = ..()

/turf/open/water/clean/under
	icon_state = MAP_SWITCH("rock", "rockcwf")
	water_height = WATER_HEIGHT_FULL
	swim_skill = TRUE
	shine = SHINE_MATTE

/turf/open/water/clean/under/handle_water()
	. = ..()
	if(!water_overlay)
		return
	// Full-depth water has no matching bottom4 state. Keep the lower level visible through a full-tile water texture.
	water_overlay.icon_state = "together"
	water_overlay.color = "#4f8199aa"

/turf/open/water/clean/dirt
	name = "water"
	desc = "Fairly clear water, mostly untainted by surrounding soil."
	icon_state = MAP_SWITCH("dirt", "dirtW5")
	cleanliness_factor = -1

/turf/open/water/clean/dirt/under
	icon_state = MAP_SWITCH("dirt", "dirtcwf")
	water_height = WATER_HEIGHT_FULL
	swim_skill = TRUE
	shine = SHINE_MATTE

/turf/open/water/clean/dirt/under/handle_water()
	. = ..()
	if(!water_overlay)
		return
	water_overlay.icon_state = "together"
	water_overlay.color = "#4f8199aa"

/turf/open/water/blood
	name = "blood"
	desc = "A pool of sanguine liquid."
	icon = 'icons/turf/natural/liquids.dmi'
	icon_state = MAP_SWITCH("rock", "rockb")
	base_icon_state = "rock"
	water_height = WATER_HEIGHT_SHALLOW
	slowdown = 15
	cleanliness_factor = -5
	water_reagent = /datum/reagent/blood

/turf/open/water/blood/Initialize()
	dir = pick(GLOB.cardinals)
	. = ..()

/turf/open/water/river
	name = "water"
	desc = "Crystal clear water! Flowing swiftly along the river."
	icon_state = MAP_SWITCH("rock", "rivermove-dir")
	base_icon_state = "rock"
	water_height = WATER_HEIGHT_DEEP
	slowdown = 20
	swim_skill = TRUE
	swimdir = TRUE
	set_relationships_on_init = FALSE
	uses_height = FALSE
	fishing_datum = /datum/fish_source/river
	var/river_processing
	var/river_processes = TRUE
	var/flow_speed = 5 DECISECONDS

/turf/open/water/river/get_heuristic_slowdown(mob/traverser, travel_dir)
	. = ..()
	if(travel_dir & dir) // downriver
		. -= 2 // faster!
	else // upriver
		. += 2 // slower

/turf/open/water/river/LateInitialize()
	. = ..()
	var/turf/open/water/river/water = get_step(src, dir)
	if(!istype(water))
		return
	if(water.parent?.water_volume > water_volume)
		return
	water.try_set_parent(src)

/turf/open/water/river/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(!river_processes)
		return
	if(locate(/obj/structure/stairs) in src)
		return
	if(isliving(AM) || isitem(AM))
		if(!river_processing)
			river_processing = addtimer(CALLBACK(src, PROC_REF(process_river)), flow_speed, TIMER_STOPPABLE)

/turf/open/water/river/proc/process_river()
	river_processing = null
	if(water_volume < 10)
		return
	for(var/atom/movable/A in contents)
		for(var/obj/structure/S in src)
			if(S.obj_flags & BLOCK_Z_OUT_DOWN)
				return
		if((A.loc == src))
			if(!istype(get_step(src, dir), /turf/open/water))
				var/list/viable_cardinals = list()
				var/inverse = REVERSE_DIR(dir)
				for(var/direction in GLOB.cardinals)
					if(direction == inverse)
						continue
					var/turf/open/water/water = get_step(src, direction)
					if(!istype(water))
						continue
					viable_cardinals |= direction
				if(length(viable_cardinals))
					A.ConveyorMove(pick(viable_cardinals))
			else
				A.ConveyorMove(dir)

/turf/open/water/river/under
	icon_state = MAP_SWITCH("rock", "rivermoveF-dir")
	water_height = WATER_HEIGHT_FULL
	uses_height = TRUE
	shine = SHINE_MATTE

/turf/open/water/river/dirt
	desc = "Murky water, flowing swiftly along the river."
	icon_state = MAP_SWITCH("dirt", "rivermovealt-dir")
	base_icon_state = "dirt"
	water_reagent = /datum/reagent/water/gross
	cleanliness_factor = -5
	slowdown = 1
	flow_speed = 1 SECONDS

/turf/open/water/river/dirt/under
	icon_state = MAP_SWITCH("dirt", "rivermovealtF-dir")
	water_height = WATER_HEIGHT_FULL
	uses_height = TRUE
	shine = SHINE_MATTE

/turf/open/water/river/blood
	name = "blood"
	desc = "This river flows a viscous red."
	icon_state = MAP_SWITCH("rock", "rivermovealt2-dir")
	base_icon_state = "rock"
	water_reagent = /datum/reagent/blood
	cleanliness_factor = -5

/turf/open/water/acid // holy SHIT
	name = "acid pool"
	desc = "Well... how did THIS get here?"
	water_reagent = /datum/reagent/rogueacid
	cleanliness_factor = -100

/turf/open/water/acid/mapped
	desc = "You know how this got here. You think."
	notake = TRUE

/turf/open/water/ocean
	name = "salt water"
	desc = "The waves lap at the coast, hungry to swallow the land."
	icon_state = MAP_SWITCH("gravel", "gravelW")
	icon = 'icons/turf/natural/liquids.dmi'
	neighborlay_self = "edgesalt"
	base_icon_state = "gravel"
	water_height = WATER_HEIGHT_SHALLOW
	slowdown = 2
	swim_skill = TRUE
	wash_in = TRUE
	water_reagent = /datum/reagent/water/salty
	fishing_datum = /datum/fish_source/ocean

/turf/open/water/ocean/under
	desc = "Deceptively deep, be careful not to find yourself this far out."
	icon_state = MAP_SWITCH("gravel", "gravelswf")
	water_height = WATER_HEIGHT_FULL
	swim_skill = TRUE
	shine = SHINE_MATTE

/turf/open/water/ocean/abyss
	name = "salt water"
	desc = "Deceptively deep, be careful not to find yourself this far out."
	icon = 'icons/turf/natural/liquids.dmi'
	icon_state = MAP_SWITCH("ash", "ashW")
	water_height = WATER_HEIGHT_DEEP
	slowdown = 4
	swim_skill = TRUE
	wash_in = TRUE
	fake_bottomless = TRUE
	skip_bottom_check = TRUE
	fishing_datum = /datum/fish_source/ocean/deep

/turf/open/water/ocean/abyss/under
	icon_state = MAP_SWITCH("ash", "ashswf")
	water_height = WATER_HEIGHT_FULL
	shine = SHINE_MATTE

/datum/reagent/water/salty
	taste_description = "salt"
	color = "#3e7459"

/datum/reagent/water/salty/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method & INGEST) // Make sure you DRANK the salty water before losing hydration
		..()

/datum/reagent/water/salty/on_mob_life(mob/living/carbon/M, efficiency)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.adjust_hydration(-hydration * efficiency)  //saltwater dehydrates more than it hydrates
		M.adjustToxLoss(0.25 * efficiency) // Slightly toxic
		M.add_nausea(2 * efficiency)
	..()
