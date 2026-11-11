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
	var/obj/found = thing?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_fixture/proc/is_in(obj/found, datum/enterprise_room/room)
	var/turf/place = get_turf(found)
	if(place == home)
		return TRUE
	if(!place)
		return room.enterprise.is_kept(found)
	var/datum/enterprise_room/found_in = room.enterprise.get_room(place)
	return found_in && found_in.get_leader() == room.get_leader()

/datum/enterprise_fixture/proc/get_present(datum/enterprise_room/room)
	var/obj/found = get_thing()
	return (found && is_in(found, room)) ? found : null

/datum/enterprise_fixture/proc/make_new()
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
	if(istype(replacement, /obj/structure/fermentation_keg))
		replacement.reagents?.clear_reagents()
	return replacement

/datum/enterprise_fixture/proc/mend(obj/found)
	if(found.uses_integrity)
		found.repair_damage(found.max_integrity)
	if(found.obj_broken)
		found.atom_fix()

/datum/enterprise_fixture/proc/swap_to(obj/new_type, datum/enterprise_room/room)
	var/obj/found = get_present(room)
	fixture_type = new_type
	if(name)
		name = null
	if(!found || !isturf(found.loc))
		return null
	var/obj/replacement = new new_type(found.loc)
	replacement.dir = found.dir
	replacement.pixel_x = found.pixel_x
	replacement.pixel_y = found.pixel_y
	qdel(found)
	return replacement

/datum/enterprise_fixture_group
	var/fixture_type
	var/name
	var/value
	var/datum/enterprise_furnishing/family
	var/list/datum/enterprise_fixture/items = list()
	var/missing = 0
	var/misplaced = 0
	var/broken = 0

/datum/enterprise_fixture_group/New(obj/kind, kind_name, datum/enterprise_furnishing/kind_family)
	set_type(kind, kind_name)
	family = kind_family

/datum/enterprise_fixture_group/proc/set_type(obj/new_type, new_name)
	fixture_type = new_type
	name = new_name || initial(new_type.name)
	value = max(initial(new_type.sellprice), ENTERPRISE_FIXTURE_MIN_VALUE)

/datum/enterprise_fixture_group/proc/get_damaged()
	return missing + misplaced + broken

/datum/enterprise_fixture_group/proc/check(datum/enterprise_room/room)
	var/datum/enterprise/enterprise = room.enterprise
	var/now_missing = 0
	var/now_misplaced = 0
	var/now_broken = 0
	for(var/datum/enterprise_fixture/item as anything in items)
		var/obj/found = item.get_thing()
		if(!found || !item.is_in(found, room))
			var/obj/stand_in = room.take_loose(fixture_type)
			if(stand_in)
				enterprise.bind_fixture(item, stand_in)
				found = stand_in
			else if(!found)
				if(item.thing)
					enterprise.bind_fixture(item, null)
				now_missing++
				continue
			else
				if(enterprise.contains(found))
					now_misplaced++
				else
					now_missing++
				continue
		if(found.obj_broken)
			now_broken++
	if(now_missing == missing && now_misplaced == misplaced && now_broken == broken)
		return FALSE
	missing = now_missing
	misplaced = now_misplaced
	broken = now_broken
	return TRUE

/datum/enterprise_room
	var/list/datum/enterprise_fixture_group/inventory
	var/damage = 0
	var/damaged = 0
	var/list/loose_cache

/datum/enterprise_room/proc/add_fixture(datum/enterprise_fixture/item)
	if(!inventory)
		inventory = list()
	var/datum/enterprise_fixture_group/group = inventory[item.fixture_type]
	if(!group)
		group = new(item.fixture_type, item.name, enterprise.get_furnishing(item.fixture_type))
		inventory[item.fixture_type] = group
	group.items += item

/datum/enterprise_room/proc/take_loose(fixture_type)
	if(!loose_cache)
		loose_cache = list()
		for(var/datum/enterprise_room/part as anything in get_members())
			for(var/turf/member as anything in part.turfs)
				for(var/obj/thing in member)
					if(thing.invisibility || enterprise.is_bound(thing) || !enterprise.is_fixture(thing))
						continue
					var/list/same = loose_cache[thing.type]
					if(!same)
						same = list()
						loose_cache[thing.type] = same
					same += thing
	var/list/same = loose_cache[fixture_type]
	if(!length(same))
		return null
	var/obj/found = same[length(same)]
	same.len--
	return found

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
	loose_cache = null
	damage = new_damage
	damaged = new_damaged
	return changed

/datum/enterprise_room/proc/get_team_damage()
	var/total = 0
	for(var/datum/enterprise_room/member as anything in get_members())
		total += member.damage
	return total

/datum/enterprise_room/proc/is_in_order()
	for(var/datum/enterprise_room/member as anything in get_members())
		if(member.damaged)
			return FALSE
	return TRUE

/datum/enterprise_room/proc/get_repair_cost()
	return get_team_damage() * ENTERPRISE_REPAIR_BOOK_MULTIPLIER

/datum/enterprise_room/proc/get_account_repair_cost()
	return get_team_damage() * ENTERPRISE_REPAIR_ACCOUNT_MULTIPLIER

/datum/enterprise_room/proc/describe_damage()
	var/list/totals = list()
	var/list/names = list()
	for(var/datum/enterprise_room/member as anything in get_members())
		for(var/fixture_type in member.inventory)
			var/datum/enterprise_fixture_group/group = member.inventory[fixture_type]
			var/count = group.get_damaged()
			if(count)
				totals[fixture_type] += count
				names[fixture_type] = group.name
	var/list/lines = list()
	for(var/fixture_type in totals)
		lines += "[names[fixture_type]] ×[totals[fixture_type]]"
	return jointext(lines, ", ")

/datum/enterprise_room/proc/count_fixtures(fixture_type)
	var/found = 0
	for(var/group_type in inventory)
		if(ispath(group_type, fixture_type))
			var/datum/enterprise_fixture_group/group = inventory[group_type]
			found += length(group.items) - group.missing - group.misplaced
	return found

/datum/enterprise_room/proc/count_listed(fixture_type)
	var/found = 0
	for(var/group_type in inventory)
		if(ispath(group_type, fixture_type))
			var/datum/enterprise_fixture_group/group = inventory[group_type]
			found += length(group.items)
	return found

/datum/enterprise_room/proc/holds_any(list/types)
	for(var/turf/member as anything in turfs)
		for(var/obj/thing in member)
			if(is_type_in_list(thing, types))
				return TRUE
			if(istype(thing, /obj/structure/closet))
				for(var/obj/inner in thing)
					if(is_type_in_list(inner, types))
						return TRUE
	return FALSE

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
			var/obj/replacement = item.make_new()
			enterprise.bind_fixture(item, replacement)
			restored++
			if(istype(replacement, /obj/structure/door))
				doors |= WEAKREF(replacement)
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
			enterprise.bind_fixture(item, item.swap_to(new_type, src))
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

/datum/enterprise
	var/alist/fixture_refs = alist()
	var/list/pressed = list()

/datum/enterprise/proc/bind_fixture(datum/enterprise_fixture/item, obj/thing)
	if(item.thing)
		fixture_refs -= item.thing
	if(!thing)
		item.thing = null
		return
	item.thing = WEAKREF(thing)
	fixture_refs[item.thing] = item

/datum/enterprise/proc/is_bound(obj/thing)
	var/datum/weakref/ref = thing.weak_reference
	return ref && fixture_refs[ref]

/datum/enterprise/proc/press(mob/user, action)
	var/who = user?.ckey
	if(!who)
		return TRUE
	var/list/times = pressed[who]
	if(!times)
		times = list()
		pressed[who] = times
	if(world.time < times[action])
		return FALSE
	times[action] = world.time + ENTERPRISE_PRESS_COOLDOWN
	return TRUE

/datum/enterprise/proc/check_rooms(list/datum/enterprise_room/checked)
	var/list/datum/enterprise_room/changed = list()
	for(var/datum/enterprise_room/room as anything in checked)
		if(room.check_inventory())
			changed += room
	if(!length(changed))
		return FALSE
	var/list/redrawn = list()
	for(var/datum/enterprise_room/room as anything in changed)
		SStgui.update_uis(room.get_leader())
		if(room.z in redrawn)
			continue
		redrawn += room.z
		get_floor(room.z)?.take_picture(FALSE)
	refresh_viewers()
	SStgui.update_uis(src)
	return TRUE

/datum/enterprise/proc/check_intact(mob/user, datum/enterprise_room/room)
	check_rooms(room.get_members())
	if(room.is_in_order())
		return TRUE
	var/russian = get_preferred_ui_language(user) == "ru"
	var/title = room.get_title(russian)
	var/lacking = room.describe_damage()
	to_chat(user, span_warning(russian \
		? "Комнату «[title]» нельзя улучшить, пока в ней чего-то нет на месте или что-то сломано: [lacking]. Сначала верните вещи или почините её." \
		: "[title] cannot be upgraded while anything in it is gone, out of place or broken: [lacking]. Bring the things back or repair it first."))
	return FALSE
