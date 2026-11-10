#define PLAN_CELL_OUTSIDE " "
#define PLAN_CELL_FLOOR "."
#define PLAN_CELL_WALL "#"
#define PLAN_CELL_OPEN_SPACE "o"
#define PLAN_CELL_DOOR "D"
#define PLAN_CELL_STAIRS "S"
#define PLAN_CELL_LEDGER "L"
#define PLAN_REFRESH_COOLDOWN (5 SECONDS)

/datum/enterprise
	// The plan as last sent to the ledger; null until asked for and after every change of premises.
	var/list/premises_plan
	COOLDOWN_DECLARE(plan_refresh_cooldown)

/datum/enterprise/proc/get_premises_plan()
	if(premises_plan)
		return premises_plan
	premises_plan = list()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			premises_plan += list(floor.get_plan())
	return premises_plan

/datum/enterprise/proc/invalidate_premises_plan()
	premises_plan = null
	update_static_data_for_all_viewers()

/datum/enterprise/proc/refresh_premises_plan(mob/user)
	if(!is_staff(user) || !COOLDOWN_FINISHED(src, plan_refresh_cooldown))
		return
	COOLDOWN_START(src, plan_refresh_cooldown, PLAN_REFRESH_COOLDOWN)
	invalidate_premises_plan()

// One string per row, south row first, one character per turf of the bounding box.
/datum/enterprise_floor/proc/get_plan()
	var/list/cells = new /list(width * height)
	for(var/index in 1 to length(cells))
		cells[index] = PLAN_CELL_OUTSIDE
	var/list/objects = list()

	for(var/turf/member as anything in turfs)
		var/column = member.x - min_x
		var/row = member.y - min_y
		var/cell = PLAN_CELL_FLOOR
		if(isclosedturf(member))
			cell = PLAN_CELL_WALL
		else if(isopenspace(member))
			cell = PLAN_CELL_OPEN_SPACE
		for(var/obj/thing in member)
			if(thing.invisibility || (!istype(thing, /obj/structure) && !istype(thing, /obj/machinery)))
				continue
			objects += list(list("x" = column, "y" = row, "name" = thing.name))
			if(istype(thing, /obj/structure/fake_machine/enterprise_ledger))
				cell = PLAN_CELL_LEDGER
			else if(istype(thing, /obj/structure/door))
				if(cell != PLAN_CELL_LEDGER)
					cell = PLAN_CELL_DOOR
			else if(istype(thing, /obj/structure/stairs))
				if(cell == PLAN_CELL_FLOOR || cell == PLAN_CELL_OPEN_SPACE)
					cell = PLAN_CELL_STAIRS
		cells[row * width + column + 1] = cell

	var/list/rows = list()
	for(var/row in 0 to height - 1)
		rows += jointext(cells.Copy(row * width + 1, (row + 1) * width + 1), "")
	return list(
		"z" = z,
		"basement" = basement,
		"width" = width,
		"height" = height,
		"tiles" = length(turfs),
		"rows" = rows,
		"objects" = objects,
	)

#undef PLAN_CELL_OUTSIDE
#undef PLAN_CELL_FLOOR
#undef PLAN_CELL_WALL
#undef PLAN_CELL_OPEN_SPACE
#undef PLAN_CELL_DOOR
#undef PLAN_CELL_STAIRS
#undef PLAN_CELL_LEDGER
#undef PLAN_REFRESH_COOLDOWN
