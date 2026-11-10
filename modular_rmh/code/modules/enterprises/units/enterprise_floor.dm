/datum/enterprise_floor
	var/z
	var/basement = FALSE
	var/list/turf/turfs = list()
	var/min_x = 0
	var/min_y = 0
	var/width = 0
	var/height = 0
	// One cell per turf of the bounding box, row by row; TRUE where the turf belongs to the floor.
	var/list/mask

/datum/enterprise_floor/New(z)
	src.z = z

/datum/enterprise_floor/Destroy()
	turfs = null
	mask = null
	return ..()

/datum/enterprise_floor/proc/add_turfs(list/turf/added)
	turfs += added
	var/turf/first = turfs[1]
	min_x = first.x
	min_y = first.y
	var/max_x = first.x
	var/max_y = first.y
	for(var/turf/member as anything in turfs)
		min_x = min(min_x, member.x)
		min_y = min(min_y, member.y)
		max_x = max(max_x, member.x)
		max_y = max(max_y, member.y)
	width = max_x - min_x + 1
	height = max_y - min_y + 1
	mask = new /list(width * height)
	for(var/turf/member as anything in turfs)
		mask[(member.y - min_y) * width + (member.x - min_x) + 1] = TRUE

/datum/enterprise_floor/proc/contains(turf/checked)
	if(!checked || checked.z != z)
		return FALSE
	var/column = checked.x - min_x
	var/row = checked.y - min_y
	if(column < 0 || row < 0 || column >= width || row >= height)
		return FALSE
	return !!mask[row * width + column + 1]

/datum/enterprise_floor/proc/get_atoms(atom_type)
	var/list/found = list()
	for(var/turf/member as anything in turfs)
		for(var/atom/movable/thing as anything in member)
			if(istype(thing, atom_type))
				found += thing
	return found
