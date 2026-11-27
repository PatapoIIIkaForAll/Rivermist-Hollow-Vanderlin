
/datum/element/turf_z_transparency
	element_flags = ELEMENT_DETACH
	var/is_openspace = FALSE

///This proc sets up the signals to handle updating viscontents when turfs above/below update. Handle plane and layer here too so that they don't cover other obs/turfs in Dream Maker
/datum/element/turf_z_transparency/Attach(datum/target, is_openspace = FALSE)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	var/turf/our_turf = target

	our_turf.layer = OPENSPACE_LAYER
	if(is_openspace) // openspace and windows have different visual effects but both share this component.
		our_turf.plane = OPENSPACE_PLANE
	else
		our_turf.plane = TRANSPARENT_FLOOR_PLANE

	RegisterSignal(target, COMSIG_TURF_MULTIZ_DEL, PROC_REF(on_multiz_turf_del))
	RegisterSignal(target, COMSIG_TURF_MULTIZ_NEW, PROC_REF(on_multiz_turf_new))

	ADD_TRAIT(our_turf, TRAIT_Z_TRANSPARENT, ELEMENT_TRAIT(type))

	var/turf/below_turf = GET_TURF_BELOW(our_turf)
	if(below_turf)
		our_turf.vis_contents += below_turf
	update_multi_z(our_turf)

/datum/element/turf_z_transparency/Detach(datum/source)
	. = ..()
	var/turf/our_turf = source
	hide_lower_turf(our_turf)
	UnregisterSignal(our_turf, list(COMSIG_TURF_MULTIZ_NEW, COMSIG_TURF_MULTIZ_DEL))
	REMOVE_TRAIT(our_turf, TRAIT_Z_TRANSPARENT, ELEMENT_TRAIT(type))

///Updates the viscontents or underlays below this tile.
/datum/element/turf_z_transparency/proc/update_multi_z(turf/our_turf)
	var/turf/below_turf = GET_TURF_BELOW(our_turf)
	if(below_turf) // If we actually have somethign below us, display it.
		our_turf.vis_contents += below_turf
	else
		hide_lower_turf(our_turf)
		add_baseturf_underlay(our_turf)

	return TRUE

/// Takes the turfs out of our_turf's vis_contents and leaves the other entries, such as its lighting look.
/datum/element/turf_z_transparency/proc/hide_lower_turf(turf/our_turf)
	for(var/turf/shown_turf in our_turf.vis_contents)
		our_turf.vis_contents -= shown_turf

/datum/element/turf_z_transparency/proc/on_multiz_turf_del(turf/our_turf, turf/below_turf, dir)
	SIGNAL_HANDLER

	if(dir != DOWN)
		return

	update_multi_z(our_turf)

/datum/element/turf_z_transparency/proc/on_multiz_turf_new(turf/our_turf, turf/below_turf, dir)
	SIGNAL_HANDLER

	if(dir != DOWN)
		return

	update_multi_z(our_turf)

///Called when there is no real turf below this turf
/datum/element/turf_z_transparency/proc/add_baseturf_underlay(turf/our_turf)
	var/turf/path = SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF) || /turf/open/floor/naturalstone
	if(!ispath(path))
		path = text2path(path)
		if(!ispath(path))
			warning("Z-level [our_turf.z] has invalid baseturf '[SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF)]'")
			path = /turf/open/floor/naturalstone
	var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER-0.02, plane = SPACE_PLANE)
	underlay_appearance.appearance_flags = RESET_ALPHA | RESET_COLOR
	our_turf.underlays += underlay_appearance
