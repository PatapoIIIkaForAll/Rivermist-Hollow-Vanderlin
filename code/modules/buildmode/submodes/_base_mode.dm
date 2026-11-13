/datum/buildmode_mode
	var/name = "Unknown"
	var/key = "oops"
	var/datum/buildmode/BM
	/// Whether this mode builds the shared selection, which shows the cursor preview.
	var/uses_selection = FALSE
	/// Whether holding Shift shows the pixel catcher for exact placement.
	var/pixel_placement = FALSE

	// Corner selection component
	var/use_corner_selection = FALSE
	var/list/preview = list()
	var/turf/cornerA
	var/turf/cornerB

/datum/buildmode_mode/New(datum/buildmode/BM)
	src.BM = BM
	return ..()

/datum/buildmode_mode/Destroy()
	deselect_region()
	BM = null
	return ..()

/datum/buildmode_mode/proc/enter_mode(datum/buildmode/BM)
	return

/datum/buildmode_mode/proc/exit_mode(datum/buildmode/BM)
	deselect_region()

/datum/buildmode_mode/proc/get_button_iconstate()
	return "buildmode_[key]"

/datum/buildmode_mode/proc/show_help(client/c)
	CRASH("No help defined for [src.type], yell at a coder")

/datum/buildmode_mode/proc/change_settings(client/c)
	to_chat(c, span_warning("There is no configuration available for this mode."))

/// Asks for a typepath and makes it the shared selection.
/datum/buildmode_mode/proc/prompt_for_type(client/c)
	var/target_path = input(c, "Enter typepath:", "Typepath", "/obj/structure/closet") as null|text
	if(!target_path || QDELETED(src))
		return
	var/chosen_type = text2path(target_path)
	if(!ispath(chosen_type))
		chosen_type = pick_closest_path(target_path)
	if(!chosen_type || QDELETED(src))
		return
	if(!BM.select_item(chosen_type))
		to_chat(c, span_warning("That path is not allowed."))

/datum/buildmode_mode/proc/handle_click(client/c, list/modifiers, atom/object)
	if(!use_corner_selection)
		return
	if(!LAZYACCESS(modifiers, LEFT_CLICK))
		to_chat(c, span_boldnotice("Region selection canceled!"))
		deselect_region()
		return
	if(!cornerA)
		cornerA = select_tile(get_turf(object), AREASELECT_CORNERA)
		return
	if(!cornerB)
		cornerB = select_tile(get_turf(object), AREASELECT_CORNERB)
		to_chat(c, span_boldwarning("Region selected, if you're happy with your selection left click again, otherwise right click."))
		return
	handle_selected_area(c, modifiers)
	deselect_region()

/datum/buildmode_mode/proc/select_tile(turf/T, corner_to_select)
	if(!T)
		return null
	var/overlaystate
	switch(corner_to_select)
		if(AREASELECT_CORNERA)
			overlaystate = "greenOverlay"
		if(AREASELECT_CORNERB)
			overlaystate = "blueOverlay"

	var/image/I = image('icons/turf/overlays.dmi', T, overlaystate)
	I.plane = ABOVE_LIGHTING_PLANE
	add_preview_images(list(I))
	return T

/datum/buildmode_mode/proc/highlight_region(region)
	var/list/images = list()
	for(var/turf/T in region)
		var/image/I = image('icons/turf/overlays.dmi', T, "redOverlay")
		I.plane = ABOVE_LIGHTING_PLANE
		images += I
	add_preview_images(images)

/datum/buildmode_mode/proc/add_preview_images(list/images)
	preview += images
	if(BM?.holder)
		BM.holder.images += images

/datum/buildmode_mode/proc/deselect_region()
	if(BM?.holder)
		BM.holder.images -= preview
	preview.Cut()
	cornerA = null
	cornerB = null

/datum/buildmode_mode/proc/handle_selected_area(client/c, list/modifiers)
	return
