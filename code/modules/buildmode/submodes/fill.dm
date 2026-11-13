/// Regions larger than this ask for confirmation before filling or deleting.
#define BM_FILL_CONFIRM_TILES 400

/datum/buildmode_mode/fill
	name = "Fill"
	key = "fill"
	uses_selection = TRUE
	use_corner_selection = TRUE

/datum/buildmode_mode/fill/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Left Mouse Button on turf/obj/mob      = Select corner"))
	to_chat(c, span_notice("Left Mouse Button + Alt on turf/obj/mob = Delete region"))
	to_chat(c, span_notice("Right Mouse Button on buildmode button = Select by typepath"))
	to_chat(c, span_notice("Fills with the item browser selection."))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/fill/change_settings(client/c)
	prompt_for_type(c)
	deselect_region()

/datum/buildmode_mode/fill/handle_selected_area(client/c, list/modifiers)
	if(!LAZYACCESS(modifiers, LEFT_CLICK))
		return
	var/turf/corner_a = cornerA
	var/turf/corner_b = cornerB
	var/deleting = LAZYACCESS(modifiers, ALT_CLICKED)
	var/fill_type = BM.selected_item
	if(!deleting && !fill_type)
		to_chat(c, span_warning("Select an object type first."))
		return
	var/list/region = block(corner_a, corner_b)
	if(length(region) > BM_FILL_CONFIRM_TILES)
		if(alert(c, "This affects [length(region)] tiles. Continue?", "Large region", "Yes", "No") != "Yes" || QDELETED(src))
			return

	if(deleting)
		for(var/turf/T as anything in region)
			for(var/atom/movable/AM in T)
				// Never delete player-controlled mobs, including the builder.
				if(ismob(AM))
					var/mob/region_mob = AM
					if(region_mob.ckey)
						continue
				qdel(AM)
			// extreme haircut
			T.ScrapeAway(INFINITY, CHANGETURF_DEFER_CHANGE)
		for(var/turf/T as anything in region)
			T.AfterChange()
		log_admin("Build Mode: [key_name(c)] deleted turfs from [AREACOORD(corner_a)] through [AREACOORD(corner_b)]")
		return

	for(var/turf/T as anything in region)
		if(ispath(fill_type, /turf))
			T.PlaceOnTop(fill_type)
			continue
		var/atom/movable/placed = new fill_type(T)
		if(!QDELETED(placed))
			placed.setDir(BM.build_dir)
	log_admin("Build Mode: [key_name(c)] with path [fill_type], filled the region from [AREACOORD(corner_a)] through [AREACOORD(corner_b)]")

#undef BM_FILL_CONFIRM_TILES
