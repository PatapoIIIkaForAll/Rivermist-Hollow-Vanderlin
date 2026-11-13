// The engine allows at most 2^24 images and mutable appearances alive at once; this finds what holds them.

/client/proc/cmd_image_census()
	set category = "Debug.Debug"
	set name = "Image Census"
	set desc = "Count image and mutable appearance references by holder. Slow on a long round."

	if(!check_rights(R_DEBUG))
		return
	if(tgui_alert(usr, "Walk every datum and count image references? This can take minutes on a long round.", "Image Census", list("Yes", "No")) != "Yes")
		return
	message_admins("[key_name_admin(usr)] started an image census.")
	log_admin("[key_name(usr)] started an image census.")

	var/list/counts = list()
	var/list/seen_lists = list()
	for(var/varname in GLOB.vars)
		if(varname != "vars")
			image_census_value(GLOB.vars[varname], "GLOB.[varname]", counts, seen_lists, 0)
	for(var/datum/thing in world)
		image_census_holder(thing, counts, seen_lists)
		CHECK_TICK
	for(var/datum/thing)
		image_census_holder(thing, counts, seen_lists)
		CHECK_TICK
	for(var/client/thing)
		image_census_holder(thing, counts, seen_lists)

	var/total = 0
	for(var/key in counts)
		total += counts[key]
	var/list/sorted = sortTim(counts, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	var/list/lines = list("Image census at [ROUND_TIME()]: [total] image/mutable appearance references in [length(sorted)] holders.")
	var/shown = 0
	for(var/key in sorted)
		lines += "[sorted[key]] [key]"
		if(++shown >= 60)
			break
	var/report = lines.Join("\n")
	text2file("[report]\n\n", "[GLOB.log_directory]/image_census.log")
	usr << browse("<pre>[html_encode(report)]</pre>", "window=image_census;size=700x600")
	message_admins("Image census finished: [total] references. Full list in image_census.log.")

/// Counts the images and mutable appearances one datum holds in its vars, including lists.
/proc/image_census_holder(datum/holder, list/counts, list/seen_lists)
	for(var/varname in holder.vars)
		// These hold appearances or atoms, not image objects, or are huge and walked elsewhere.
		if(varname == "vars" || varname == "contents" || varname == "overlays" || varname == "underlays" || varname == "vis_contents" || varname == "vis_locs" || varname == "screen")
			continue
		image_census_value(holder.vars[varname], "[holder.type].[varname]", counts, seen_lists, 0)

/proc/image_census_value(value, holder_key, list/counts, list/seen_lists, depth)
	if(isnull(value) || isnum(value) || istext(value) || ispath(value))
		return
	if(istype(value, /mutable_appearance))
		counts["[holder_key] (mutable appearance)"] += 1
		return
	if(istype(value, /image))
		counts["[holder_key] (image)"] += 1
		return
	if(!islist(value) || depth >= 4)
		return
	var/list/walked = value
	var/list_ref = REF(walked)
	if(seen_lists[list_ref])
		return
	seen_lists[list_ref] = TRUE
	for(var/i in 1 to length(walked))
		var/element = walked[i]
		image_census_value(element, "[holder_key]\[]", counts, seen_lists, depth + 1)
		if(isnull(element) || isnum(element))
			continue
		var/assoc
		try
			assoc = walked[element]
		catch
			continue
		image_census_value(assoc, "[holder_key]\[assoc]", counts, seen_lists, depth + 1)
