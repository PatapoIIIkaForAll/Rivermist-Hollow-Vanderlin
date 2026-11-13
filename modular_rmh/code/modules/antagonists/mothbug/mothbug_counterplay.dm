/// Lavender keeps mothbugs off fabric: a sprig beside it, or lavender scent hanging in the air.
/proc/is_mothbug_repelled(atom/target)
	if(!isturf(target) && target.loc && (locate(/obj/item/alch/herb/lavender) in target.loc))
		return TRUE
	var/turf/open/place = get_turf(target)
	if(!istype(place) || !place.pollution)
		return FALSE
	return place.pollution.pollutants[/datum/pollutant/fragrance/lavender] > 0

/mob/living/simple_animal/mothbug
	var/hide_light_timer

/// Bright light exposes a mothbug in the open; a light carried nearby finds it anywhere.
/mob/living/simple_animal/mothbug/proc/is_exposed_by_light()
	var/turf/place = get_turf(src)
	var/under_cover = (locate(/obj/structure/table) in place) || (locate(/obj/structure/bed) in place)
	if(!under_cover && place.get_lumcount() >= MOTHBUG_REVEAL_LIGHT)
		return TRUE
	for(var/mob/living/carbon/human/seeker in view(MOTHBUG_LIGHT_REVEAL_RANGE, src))
		if(seeker.stat == CONSCIOUS && LAZYLEN(seeker.light_sources))
			return TRUE
	return FALSE

/mob/living/simple_animal/mothbug/proc/check_hide_light()
	if(!hidden || !is_exposed_by_light())
		return
	to_chat(src, span_warning("Light falls across me. I am seen!"))
	set_mothbug_hidden(FALSE)
