/datum/enterprise_fixture
	var/fixture_type
	var/datum/weakref/thing
	var/turf/home
	var/dir
	var/pixel_x
	var/pixel_y
	var/name
	var/list/lock_ids

/datum/enterprise_fixture/New(obj/source)
	fixture_type = source.type
	thing = WEAKREF(source)
	home = get_turf(source)
	if(source.dir != initial(source.dir))
		dir = source.dir
	if(source.pixel_x)
		pixel_x = source.pixel_x
	if(source.pixel_y)
		pixel_y = source.pixel_y
	if(source.name != initial(source.name))
		name = source.name
	var/datum/lock/key/key_lock = source.lock
	if(istype(key_lock) && length(key_lock.lockid_list))
		lock_ids = key_lock.lockid_list.Copy()

/datum/enterprise_fixture/Destroy()
	thing = null
	home = null
	lock_ids = null
	return ..()

/datum/enterprise_fixture/proc/get_thing()
	if(!thing)
		return null
	var/obj/found = thing.resolve()
	if(QDELETED(found))
		thing = null
		return null
	return found

/datum/enterprise_fixture/proc/get_present(datum/enterprise_room/room)
	var/obj/found = get_thing()
	if(!found)
		return null
	var/turf/place = get_turf(found)
	if(place == home || (place && room.enterprise.get_room(place) == room))
		return found
	return null

/datum/enterprise_fixture/proc/restore()
	var/obj/replacement = new fixture_type(home)
	if(name)
		replacement.name = name
	if(dir)
		replacement.dir = dir
	if(pixel_x)
		replacement.pixel_x = pixel_x
	if(pixel_y)
		replacement.pixel_y = pixel_y
	var/datum/lock/key/key_lock = replacement.lock
	if(lock_ids && istype(key_lock))
		key_lock.lockid_list = lock_ids.Copy()
	thing = WEAKREF(replacement)
	return replacement

/datum/enterprise_fixture/proc/mend(obj/found)
	if(found.uses_integrity)
		found.repair_damage(found.max_integrity)
	if(found.obj_broken)
		found.atom_fix()

/datum/enterprise_fixture/proc/change_type(obj/new_type, datum/enterprise_room/room)
	var/obj/found = get_present(room)
	fixture_type = new_type
	if(name)
		name = null
	if(!found || !isturf(found.loc))
		if(thing)
			thing = null
		return
	var/obj/replacement = new new_type(found.loc)
	replacement.dir = found.dir
	replacement.pixel_x = found.pixel_x
	replacement.pixel_y = found.pixel_y
	thing = WEAKREF(replacement)
	qdel(found)

/datum/enterprise_fixture_group
	var/fixture_type
	var/name
	var/value
	var/datum/enterprise_furnishing/family
	var/list/datum/enterprise_fixture/items = list()
	var/missing = 0
	var/broken = 0

/datum/enterprise_fixture_group/New(obj/kind, kind_name, datum/enterprise_furnishing/kind_family)
	set_type(kind, kind_name)
	family = kind_family

/datum/enterprise_fixture_group/proc/set_type(obj/new_type, new_name)
	fixture_type = new_type
	name = new_name || initial(new_type.name)
	value = max(initial(new_type.sellprice), ENTERPRISE_FIXTURE_MIN_VALUE)

/datum/enterprise_fixture_group/proc/get_damaged()
	return missing + broken

/datum/enterprise_fixture_group/proc/check(datum/enterprise_room/room)
	var/now_missing = 0
	var/now_broken = 0
	for(var/datum/enterprise_fixture/item as anything in items)
		var/obj/found = item.get_present(room)
		if(!found)
			now_missing++
		else if(found.obj_broken)
			now_broken++
	if(now_missing == missing && now_broken == broken)
		return FALSE
	missing = now_missing
	broken = now_broken
	return TRUE

/datum/enterprise_room
	var/list/datum/enterprise_fixture_group/inventory
	var/damage = 0
	var/damaged = 0

/datum/enterprise_room/proc/add_fixture(datum/enterprise_fixture/item)
	if(!inventory)
		inventory = list()
	var/datum/enterprise_fixture_group/group = inventory[item.fixture_type]
	if(!group)
		group = new(item.fixture_type, item.name, enterprise.get_furnishing(item.fixture_type))
		inventory[item.fixture_type] = group
	group.items += item

/datum/enterprise_room/proc/check_inventory()
	var/changed = FALSE
	var/new_damage = 0
	var/new_damaged = 0
	for(var/fixture_type in inventory)
		var/datum/enterprise_fixture_group/group = inventory[fixture_type]
		if(group.check(src))
			changed = TRUE
		var/count = group.get_damaged()
		new_damaged += count
		new_damage += count * group.value
	damage = new_damage
	damaged = new_damaged
	return changed

/datum/enterprise_room/proc/get_repair_cost()
	return damage * ENTERPRISE_REPAIR_MULTIPLIER

/datum/enterprise_room/proc/describe_damage()
	var/list/lines = list()
	for(var/fixture_type in inventory)
		var/datum/enterprise_fixture_group/group = inventory[fixture_type]
		var/count = group.get_damaged()
		if(count)
			lines += "[group.name] ×[count]"
	return jointext(lines, ", ")

/datum/enterprise_room/proc/count_fixtures(fixture_type)
	var/found = 0
	for(var/group_type in inventory)
		if(ispath(group_type, fixture_type))
			var/datum/enterprise_fixture_group/group = inventory[group_type]
			found += length(group.items) - group.missing
	return found

/datum/enterprise_room/proc/get_interior(atom_type)
	var/list/obj/found = list()
	for(var/group_type in inventory)
		if(atom_type && !ispath(group_type, atom_type))
			continue
		var/datum/enterprise_fixture_group/group = inventory[group_type]
		for(var/datum/enterprise_fixture/item as anything in group.items)
			var/obj/present = item.get_present(src)
			if(present)
				found += present
	return found

/datum/enterprise_room/proc/repair()
	var/restored = 0
	for(var/fixture_type in inventory)
		var/datum/enterprise_fixture_group/group = inventory[fixture_type]
		for(var/datum/enterprise_fixture/item as anything in group.items)
			var/obj/found = item.get_present(src)
			if(found)
				if(found.obj_broken)
					item.mend(found)
					restored++
				continue
			var/obj/structure/door/door = item.restore()
			restored++
			if(istype(door))
				doors |= WEAKREF(door)
				enterprise.exit_doors = null
	for(var/datum/weakref/door_ref as anything in doors)
		if(QDELETED(door_ref.resolve()))
			doors -= door_ref
	check_inventory()
	return restored

/datum/enterprise_room/proc/apply_inventory_level(new_level)
	var/list/datum/enterprise_fixture_group/groups = list()
	for(var/fixture_type in inventory)
		groups += inventory[fixture_type]
	var/changed = FALSE
	for(var/datum/enterprise_fixture_group/group as anything in groups)
		var/new_type = group.family?.get_tier(new_level)
		if(!new_type || new_type == group.fixture_type)
			continue
		changed = TRUE
		for(var/datum/enterprise_fixture/item as anything in group.items)
			item.change_type(new_type, src)
		inventory -= group.fixture_type
		var/datum/enterprise_fixture_group/same = inventory[new_type]
		if(same)
			same.items += group.items
		else
			group.set_type(new_type)
			inventory[new_type] = group
	if(changed)
		check_inventory()
	return changed

/datum/enterprise_room/proc/get_loose_items()
	var/list/known = list()
	for(var/fixture_type in inventory)
		var/datum/enterprise_fixture_group/group = inventory[fixture_type]
		for(var/datum/enterprise_fixture/item as anything in group.items)
			var/obj/thing = item.get_thing()
			if(thing)
				known[thing] = TRUE
	var/list/obj/item/loose = list()
	for(var/turf/member as anything in turfs)
		for(var/obj/item/thing in member)
			if(!known[thing] && !thing.anchored)
				loose += thing
	for(var/obj/structure/closet/chest in known)
		for(var/obj/item/thing in chest)
			loose += thing
	return loose

/datum/enterprise/proc/check_rooms(list/datum/enterprise_room/checked)
	var/list/datum/enterprise_room/changed = list()
	for(var/datum/enterprise_room/room as anything in checked)
		if(room.check_inventory())
			changed += room
	if(!length(changed))
		return FALSE
	var/list/redrawn = list()
	for(var/datum/enterprise_room/room as anything in changed)
		SStgui.update_uis(room)
		if(room.z in redrawn)
			continue
		redrawn += room.z
		get_floor(room.z)?.take_picture(FALSE)
	refresh_viewers()
	SStgui.update_uis(src)
	return TRUE

/datum/enterprise/proc/check_intact(mob/user, datum/enterprise_room/room)
	check_rooms(list(room))
	if(!room.damaged)
		return TRUE
	var/russian = get_preferred_ui_language(user) == "ru"
	var/lacking = room.describe_damage()
	to_chat(user, span_warning(russian \
		? "Комнату «[room.name]» нельзя улучшить, пока в ней чего-то нет на месте или что-то сломано: [lacking]. Сначала почините её." \
		: "[room.name] cannot be upgraded while anything in it is gone or broken: [lacking]. Repair it first."))
	return FALSE
