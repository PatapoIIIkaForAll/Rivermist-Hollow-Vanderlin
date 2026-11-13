#define DRYING_RACK_MAX_HERBS 12
#define DRYING_RACK_ENVIRONMENT_CHECK (30 SECONDS)

/obj/machinery/tanningrack
	name = "drying rack"
	desc = "A drying rack for the preparation of food or curing of hides into leather, it can be moved with the help of a wooden stake."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "dryrack"
	var/obj/item/natural/hide/hide
	/// Herbs currently spread across the rack.
	var/list/drying_herbs = list()
	/// World time drying progress was last applied to the herbs.
	var/last_drying_process = 0
	/// Cached environment multiplier, refreshed infrequently while active.
	var/drying_modifier = 1
	var/drying_condition = "slow indoor air"
	var/next_drying_environment_check = 0
	max_integrity = 200
	density = TRUE
	climbable = TRUE
	anchored = TRUE
	blade_dulling = DULLING_BASHCHOP
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	attacked_sound = list('sound/combat/hits/onwood/woodimpact (1).ogg','sound/combat/hits/onwood/woodimpact (2).ogg')

/obj/machinery/tanningrack/examine(mob/user)
	. = ..()
	if(hide)
		. += span_warning("There is a piece of hide ready to be worked. I might need a knife for this.")
	if(length(drying_herbs))
		. += span_notice("[length(drying_herbs)] herb bundle[length(drying_herbs) == 1 ? " is" : "s are"] spread across the rack. The [drying_condition] governs their drying.")
		. += drying_status_text()
	if(!anchored)
		. += span_warning("It is unanchored and able to be moved.")

/obj/machinery/tanningrack/attack_hand(mob/user, list/modifiers)
	if(hide)
		var/obj/item/I = hide
		hide = null
		I.loc = user.loc
		user.put_in_active_hand(I)
		update_appearance(UPDATE_OVERLAYS)
		return
	if(length(drying_herbs))
		var/obj/item/alch/herb/selected_herb = input(user, "Which herb do I take from the rack?", "Drying rack") as null|anything in drying_herbs
		if(!selected_herb || selected_herb.loc != src || !user.CanReach(src))
			return
		// Credit the time since the last tick before the herb leaves.
		update_drying()
		// Exited() removes it from drying_herbs.
		selected_herb.forceMove(get_turf(src))
		user.put_in_active_hand(selected_herb)

/obj/machinery/tanningrack/attackby(obj/item/I, mob/living/user, list/modifiers)
	if(istype(I, /obj/item/alch/herb))
		var/obj/item/alch/herb/herb = I
		if(herb.dried)
			to_chat(user, span_warning("[herb] is already dry."))
			return
		if(length(drying_herbs) >= DRYING_RACK_MAX_HERBS)
			to_chat(user, span_warning("There is no room to spread another herb on [src]."))
			return
		// Settle the herbs already here so the new one starts from now.
		next_drying_environment_check = 0
		update_drying()
		if(!user.transferItemToLoc(herb, src))
			to_chat(user, span_warning("[herb] is stuck to my hand!"))
			return
		drying_herbs += herb
		START_PROCESSING(SSmachines, src)
		to_chat(user, span_notice("I spread [herb] across [src]."))
		update_appearance(UPDATE_OVERLAYS)
		return
	if(istype(I, /obj/item/natural/hide) && !istype(I, /obj/item/natural/hide/cured))
		if(!hide)
			I.forceMove(src)
			hide = I
			update_appearance(UPDATE_OVERLAYS)
			return
		else
			to_chat(user, span_warning("The rack is already occupied!"))
			return
	if((user.used_intent.type == /datum/intent/dagger/cut || user.used_intent.type == /datum/intent/sword/cut || user.used_intent.type == /datum/intent/axe/cut) && hide)
		if(anchored)
			var/skill_level = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/craft/tanning)
			var/work_time = (12 SECONDS - (skill_level * 15))
			var/pieces_to_spawn = rand(1, min(skill_level + 1, 6)) //Random number from 1 to skill level
			var/sound_played = FALSE
			to_chat(user, span_warning("I begin scraping the hide's skin..."))
			if(!do_after(user, work_time))
				return
			playsound(src,pick('sound/items/book_open.ogg','sound/items/book_page.ogg'), 100, FALSE)
			QDEL_NULL(hide)
			user.mind.add_sleep_experience(/datum/attribute/skill/craft/tanning, GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) * 2) //these numbers may need some revision
			update_appearance(UPDATE_OVERLAYS)
			for(var/i = 0; i < pieces_to_spawn; i++)
				if(prob(skill_level + CLAMP((GET_MOB_ATTRIBUTE_VALUE(user, STAT_FORTUNE) - 10)*2,0,100)))
					new /obj/item/natural/cured/essence(get_turf(user))
					if(!sound_played)
						sound_played = TRUE
						to_chat(user, span_warning("Dendor provides..."))
						playsound(src,pick('sound/items/gem.ogg'), 100, FALSE)
				else
					new /obj/item/natural/hide/cured(get_turf(user))
			return
		else
			to_chat(user, span_warning("I need to anchor this down with a wooden stake before I can work this hide."))
			return
	if(istype(I, /obj/item/grown/log/tree/stake))
		if(anchored)
			anchored = FALSE
			to_chat(user, span_warning("The [src] can now be moved."))
		else
			anchored = TRUE
			to_chat(user, span_warning("You anchor [src]."))
		playsound(src,pick('sound/foley/woodclimb.ogg'), 100, TRUE)
		return
	. = ..()

/obj/machinery/tanningrack/process()
	if(!update_drying())
		return PROCESS_KILL

/// Applies drying since the last update; returns TRUE while any herb on the rack is still fresh.
/obj/machinery/tanningrack/proc/update_drying()
	var/elapsed_time = max(world.time - last_drying_process, 0)
	last_drying_process = world.time
	var/has_fresh_herbs = FALSE
	for(var/obj/item/alch/herb/herb as anything in drying_herbs)
		if(herb.dried)
			continue
		herb.drying_progress += elapsed_time * drying_modifier
		if(herb.drying_progress < herb.drying_time)
			has_fresh_herbs = TRUE
			continue
		visible_message(span_notice("[herb] finishes drying on [src]."))
		herb.finish_drying()
	if(world.time >= next_drying_environment_check)
		refresh_drying_environment()
	return has_fresh_herbs

/// Describes how many herbs are dry and how long the rest still need at the current pace.
/obj/machinery/tanningrack/proc/drying_status_text()
	var/dried_count = 0
	var/longest_remaining = 0
	for(var/obj/item/alch/herb/herb as anything in drying_herbs)
		if(herb.dried)
			dried_count++
		else
			longest_remaining = max(longest_remaining, herb.drying_time - herb.drying_progress)
	if(longest_remaining <= 0)
		return span_notice("Every herb on it is dry.")
	var/subject = dried_count ? "[dried_count] [dried_count == 1 ? "is" : "are"] dry; the rest" : "They"
	if(!drying_modifier)
		return span_warning("[subject] are not drying while rain falls on them.")
	var/minutes_left = CEILING(longest_remaining / drying_modifier / (1 MINUTES), 1)
	return span_notice("[subject] need about [minutes_left] more minute[minutes_left == 1 ? "" : "s"].")

/obj/machinery/tanningrack/proc/refresh_drying_environment()
	next_drying_environment_check = world.time + DRYING_RACK_ENVIRONMENT_CHECK
	var/datum/particle_weather/current_weather = SSParticleWeather.runningWeather
	// Same exposure test the weather uses on objects, so a roof keeps the herbs drying.
	if(current_weather?.running && current_weather.target_trait == PARTICLEWEATHER_RAIN && current_weather.can_weather_act_obj(src))
		drying_modifier = 0
		drying_condition = "falling rain"
		return
	var/area/rack_area = get_area(src)
	if(rack_area?.outdoors)
		drying_modifier = 2
		drying_condition = "open air"
		return
	for(var/obj/machinery/light/nearby_fire as anything in GLOB.fires_list)
		if(QDELETED(nearby_fire) || nearby_fire.z != z)
			continue
		if(get_dist(src, nearby_fire) <= 2)
			drying_modifier = 1.67
			drying_condition = "nearby fire"
			return
	drying_modifier = 1
	drying_condition = "slow indoor air"

/obj/machinery/tanningrack/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	// Keeps drying_herbs in sync however a herb leaves, including deletion.
	if(!(AM in drying_herbs))
		return
	drying_herbs -= AM
	if(!QDELETED(src))
		update_appearance(UPDATE_OVERLAYS)

/obj/machinery/tanningrack/Destroy()
	hide = null
	// Machinery Destroy drops the herbs and hide; Exited() empties drying_herbs.
	return ..()

/obj/machinery/tanningrack/update_overlays()
	. = ..()
	if(hide)
		var/mutable_appearance/hide_overlay = new /mutable_appearance(hide)
		hide_overlay.pixel_y = hide.base_pixel_x
		hide_overlay.pixel_x = hide.base_pixel_y
		. += hide_overlay
	var/herb_overlays = 0
	for(var/obj/item/alch/herb/herb as anything in drying_herbs)
		var/mutable_appearance/herb_overlay = new /mutable_appearance(herb)
		herb_overlay.pixel_x += (herb_overlays - 1) * 7
		herb_overlay.pixel_y += 5 + (herb_overlays % 2) * 4
		. += herb_overlay
		herb_overlays++
		if(herb_overlays >= 3)
			break

#undef DRYING_RACK_MAX_HERBS
#undef DRYING_RACK_ENVIRONMENT_CHECK
