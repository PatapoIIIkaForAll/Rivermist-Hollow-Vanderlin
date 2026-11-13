/datum/buildmode_mode/area_edit
	name = "Area Edit"
	key = "areaedit"
	var/area/storedarea
	var/image/areaimage

/datum/buildmode_mode/area_edit/New()
	areaimage = image('icons/turf/areas/areas.dmi', null, "yellow")
	return ..()

/datum/buildmode_mode/area_edit/enter_mode(datum/buildmode/BM)
	BM.holder?.images += areaimage

/datum/buildmode_mode/area_edit/exit_mode(datum/buildmode/BM)
	areaimage.loc = null // de-color the area
	BM.holder?.images -= areaimage
	return ..()

/datum/buildmode_mode/area_edit/Destroy()
	areaimage = null
	storedarea = null
	return ..()

/datum/buildmode_mode/area_edit/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Left Mouse Button on obj/turf/mob  = Paint area"))
	to_chat(c, span_notice("Right Mouse Button on obj/turf/mob = Select area to paint"))
	to_chat(c, span_notice("Right Mouse Button on buildmode button = Create new area"))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/area_edit/change_settings(client/c)
	var/target_path = input(c, "Enter typepath:", "Typepath", "/area") as null|text
	var/areatype = text2path(target_path)
	if(!ispath(areatype, /area))
		return
	var/areaname = input(c, "Enter area name:", "Area name", "Area") as null|text
	if(!length(areaname) || QDELETED(src))
		return
	storedarea = new areatype
	storedarea.name = areaname
	areaimage.loc = storedarea // color our area

/datum/buildmode_mode/area_edit/handle_click(client/c, list/modifiers, atom/object)
	var/turf/T = get_turf(object)
	if(!T)
		return
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(!storedarea)
			to_chat(c, span_warning("Configure or select the area you want to paint first!"))
			return
		var/area/old_area = get_area(T)
		if(old_area == storedarea)
			return
		T.change_area(old_area, storedarea)
		log_admin("Build Mode: [key_name(c)] added [AREACOORD(T)] to [storedarea]")
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		storedarea = get_area(T)
		areaimage.loc = storedarea // color our area
