/datum/enterprise_fixture
	var/fixture_type
	var/name
	var/turf/home
	var/dir
	var/pixel_x
	var/pixel_y
	var/value
	var/list/lock_ids
	var/datum/weakref/thing
	var/datum/enterprise_room/room
	var/datum/enterprise_furnishing/family

/datum/enterprise_fixture/New(obj/source)
	fixture_type = source.type
	name = source.name
	home = get_turf(source)
	dir = source.dir
	pixel_x = source.pixel_x
	pixel_y = source.pixel_y
	value = max(source.sellprice, ENTERPRISE_FIXTURE_MIN_VALUE)
	var/datum/lock/key/key_lock = source.lock
	if(istype(key_lock) && length(key_lock.lockid_list))
		lock_ids = key_lock.lockid_list.Copy()
	thing = WEAKREF(source)

/datum/enterprise_fixture/Destroy()
	home = null
	thing = null
	room = null
	family = null
	lock_ids = null
	return ..()

/datum/enterprise_fixture/proc/get_thing()
	var/obj/found = thing?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_fixture/proc/is_present()
	var/obj/found = get_thing()
	if(!found || !room)
		return FALSE
	return room.enterprise.get_room(found) == room || get_turf(found) == home

/datum/enterprise_fixture/proc/is_missing()
	var/obj/found = get_thing()
	if(!found || !room)
		return TRUE
	return !room.enterprise.contains(found)

/datum/enterprise_fixture/proc/is_broken()
	var/obj/found = get_thing()
	return found ? found.obj_broken : FALSE

/datum/enterprise_fixture/proc/needs_repair()
	return is_missing() || is_broken()

/datum/enterprise_fixture/proc/restore()
	var/obj/found = get_thing()
	if(found && !is_missing())
		if(found.uses_integrity)
			found.repair_damage(found.max_integrity)
		return found
	var/obj/replacement = new fixture_type(home)
	replacement.name = name
	replacement.dir = dir
	replacement.pixel_x = pixel_x
	replacement.pixel_y = pixel_y
	var/datum/lock/key/key_lock = replacement.lock
	if(lock_ids && istype(key_lock))
		key_lock.lockid_list = lock_ids.Copy()
	thing = WEAKREF(replacement)
	return replacement

/datum/enterprise_fixture/proc/get_level_type(level)
	return family ? family.get_tier(level) : null

/datum/enterprise_fixture/proc/apply_level(level)
	var/obj/new_type = get_level_type(level)
	if(!new_type || new_type == fixture_type)
		return FALSE
	var/obj/found = get_thing()
	fixture_type = new_type
	name = initial(new_type.name)
	value = max(initial(new_type.sellprice), ENTERPRISE_FIXTURE_MIN_VALUE)
	if(!found || !isturf(found.loc))
		return TRUE
	var/obj/replacement = new new_type(found.loc)
	replacement.dir = found.dir
	replacement.pixel_x = found.pixel_x
	replacement.pixel_y = found.pixel_y
	thing = WEAKREF(replacement)
	qdel(found)
	return TRUE

/datum/enterprise_furnishing
	abstract_type = /datum/enterprise_furnishing
	var/list/kinds = list()
	var/list/tiers = list()

/datum/enterprise_furnishing/proc/get_tier(level)
	if(!length(tiers))
		return null
	return tiers[clamp(level, 1, length(tiers))]

/datum/enterprise_furnishing/bed
	kinds = list(
		/obj/structure/bed,
		/obj/structure/bed/shit,
	)
	tiers = list(
		/obj/structure/bed/hay,
		/obj/structure/bed/mediocre,
		/obj/structure/bed/wool,
		/obj/structure/bed/inn,
	)

/datum/enterprise_furnishing/double_bed
	tiers = list(
		/obj/structure/bed/wool/double,
		/obj/structure/bed/wool/double,
		/obj/structure/bed/inn/double,
		/obj/structure/bed/inn/double,
	)

/datum/enterprise_furnishing/chair
	kinds = list(
		/obj/structure/chair/wood,
		/obj/structure/chair/wood/alt,
		/obj/structure/chair/wood/alt/chair_noble/purple,
		/obj/structure/chair/wood/alt/fancy,
		/obj/structure/chair/wood/alt/fancy/chair4,
		/obj/structure/chair/wood/alt/fancy/chair5,
	)
	tiers = list(
		/obj/structure/chair/wood/alt/chair3,
		/obj/structure/chair/wood/alt/uncomfortable,
		/obj/structure/chair/wood/alt/chair_noble,
		/obj/structure/chair/wood/alt/chair_noble/red,
	)

/datum/enterprise_furnishing/table
	kinds = list(
		/obj/structure/table/wood/crafted,
		/obj/structure/table/wood/plain,
		/obj/structure/table/wood/plain/alt,
		/obj/structure/table/wood/plain/alto,
		/obj/structure/table/wood/plain_alt,
		/obj/structure/table/wood/reinforced,
		/obj/structure/table/wood/reinforced_alter,
		/obj/structure/table/wood/nice/decorated,
		/obj/structure/table/wood/nice/decorated_alt,
	)
	tiers = list(
		/obj/structure/table/wood,
		/obj/structure/table/wood/reinforced_alt,
		/obj/structure/table/wood/fine,
		/obj/structure/table/wood/nice,
	)

/datum/enterprise_furnishing/wall_candle
	kinds = list(
		/obj/machinery/light/fueled/wallfire/candle/r,
		/obj/machinery/light/fueled/wallfire/candle/l,
		/obj/machinery/light/fueled/wallfire/candle/weak,
	)
	tiers = list(
		/obj/machinery/light/fueled/wallfire/candle,
		/obj/machinery/light/fueled/wallfire/candle,
		/obj/machinery/light/fueled/wallfire/candle/silver,
		/obj/machinery/light/fueled/wallfire/candle/goldcandle,
	)

/datum/enterprise_furnishing/mirror
	tiers = list(
		/obj/structure/mirror,
		/obj/structure/mirror,
		/obj/structure/mirror/fancy,
		/obj/structure/mirror/fancy,
	)

/datum/enterprise
	var/list/datum/enterprise_fixture/fixtures = list()
	var/list/datum/enterprise_room_template/room_templates

/datum/enterprise/proc/is_fixture(obj/thing)
	var/static/list/ignored = list(
		/obj/item/reagent_containers/food,
		/obj/structure/flora,
		/obj/structure/flowerpot,
		/obj/structure/fluff/clutter/shrub,
		/obj/structure/fake_machine,
	)
	if(is_type_in_list(thing, ignored))
		return FALSE
	return istype(thing, /obj/structure) || istype(thing, /obj/machinery) || istype(thing, /obj/item)

/datum/enterprise/proc/take_fixtures(list/turf/fresh)
	var/list/datum/enterprise_fixture/taken = list()
	for(var/turf/member as anything in fresh)
		if(!contains(member))
			continue
		for(var/obj/thing in member)
			if(thing.invisibility || !is_fixture(thing))
				continue
			var/datum/enterprise_fixture/fixture = new(thing)
			fixture.family = get_furnishing(thing.type)
			fixtures += fixture
			taken += fixture
	return taken

/datum/enterprise/proc/mark_start_stock(list/turf/fresh)
	for(var/turf/member as anything in fresh)
		if(!contains(member))
			continue
		for(var/obj/thing in member)
			mark_stock(thing)

/datum/enterprise/proc/mark_stock(obj/thing)
	if(isitem(thing))
		ADD_TRAIT(thing, TRAIT_ENTERPRISE_START_STOCK, REF(src))
	for(var/obj/inside in thing)
		mark_stock(inside)

/datum/enterprise/proc/get_adjoining_room(turf/place)
	var/static/list/kind_ranks = list(
		ENTERPRISE_ROOM_GUEST = 1,
		ENTERPRISE_ROOM_SERVICE = 2,
		ENTERPRISE_ROOM_COMMON = 3,
	)
	var/datum/enterprise_room/chosen
	for(var/direction in GLOB.cardinals)
		var/datum/enterprise_room/candidate = get_room(get_step(place, direction))
		if(!candidate || candidate == chosen)
			continue
		if(!chosen)
			chosen = candidate
			continue
		var/rank_gap = kind_ranks[candidate.kind] - kind_ranks[chosen.kind]
		if(rank_gap < 0 || (!rank_gap && length(candidate.turfs) < length(chosen.turfs)))
			chosen = candidate
	return chosen

/datum/enterprise/proc/get_room_templates()
	if(room_templates)
		return room_templates
	room_templates = list()
	for(var/template_type in subtypesof(/datum/enterprise_room_template))
		var/datum/enterprise_room_template/template = new template_type
		var/position = 1
		while(position <= length(room_templates))
			var/datum/enterprise_room_template/other = room_templates[position]
			if(other.priority > template.priority)
				break
			position++
		room_templates.Insert(position, template)
	return room_templates

/datum/enterprise/proc/furnish_rooms()
	for(var/datum/enterprise_room/room as anything in rooms)
		room.fixtures = list()
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		var/datum/enterprise_room/room = get_room(fixture.home) || get_adjoining_room(fixture.home)
		fixture.room = room
		if(room)
			room.fixtures += fixture
	var/list/datum/enterprise_room_template/templates = get_room_templates()
	for(var/datum/enterprise_room/room as anything in rooms)
		room.furnish(templates)

/datum/enterprise
	var/list/upgrade_costs = list(0, 2000, 5000, 10000)
	var/list/rest_prices = list(10, 25, 50, 100)
	var/list/rest_buffs = list(
		/datum/status_effect/buff/enterprise_rest,
		/datum/status_effect/buff/enterprise_rest/iron,
		/datum/status_effect/buff/enterprise_rest/silver,
		/datum/status_effect/buff/enterprise_rest/gold,
	)
	var/list/meal_moods = list(
		/datum/stress_event/enterprise_meal,
		/datum/stress_event/enterprise_meal/iron,
		/datum/stress_event/enterprise_meal/silver,
		/datum/stress_event/enterprise_meal/gold,
	)
	var/list/stock_caps = list(2, 4, 6, 10)
	var/list/eviction_times = list(6 HOURS, 12 HOURS, 24 HOURS, 48 HOURS, 0)
	var/list/prestige_thresholds = list(5000, 15000, 35000, 75000)
	var/list/datum/enterprise_furnishing/furnishings
	var/list/furnishing_by_type

/datum/enterprise/proc/get_level_value(list/table, level)
	if(level < 1 || level > length(table))
		return null
	return table[level]

/datum/enterprise/proc/get_furnishing(thing_type)
	if(!furnishing_by_type)
		furnishings = list()
		furnishing_by_type = list()
		for(var/family_type in subtypesof(/datum/enterprise_furnishing))
			var/datum/enterprise_furnishing/family = new family_type
			furnishings += family
			for(var/member_type in family.kinds | family.tiers)
				furnishing_by_type[member_type] = family
	return furnishing_by_type[thing_type]

/datum/enterprise/proc/get_upgrade_cost(datum/enterprise_room/room)
	return get_level_value(upgrade_costs, room.level + 1) || 0

/datum/enterprise/proc/get_rest_price(datum/enterprise_room/room)
	return get_level_value(rest_prices, room.level) || 0

/datum/enterprise/proc/get_rooms_by_purpose(list/purposes)
	var/list/datum/enterprise_room/found = list()
	for(var/datum/enterprise_room/room as anything in rooms)
		if(room.get_purpose() in purposes)
			found += room
	return found

/datum/enterprise/proc/raise_random_rooms(list/datum/enterprise_room/pool, amount, level)
	var/list/datum/enterprise_room/candidates = list()
	for(var/datum/enterprise_room/room as anything in pool)
		if(room.level < level)
			candidates += room
	for(var/step in 1 to min(amount, length(candidates)))
		var/datum/enterprise_room/chosen = pick(candidates)
		candidates -= chosen
		chosen.set_level(level)

/datum/enterprise/proc/grant_owner_rooms(owner_level)
	if(owner_level < 1)
		return FALSE
	var/base = owner_level >= 3 ? ENTERPRISE_LEVEL_IRON : ENTERPRISE_LEVEL_WOOD
	for(var/datum/enterprise_room/room as anything in rooms)
		room.raise_level(base)
	var/list/datum/enterprise_room/guest_list = get_rooms_by_purpose(list(ENTERPRISE_PURPOSE_GUEST_ROOM))
	var/list/datum/enterprise_room/stores = get_rooms_by_purpose(list(ENTERPRISE_PURPOSE_STORAGE, ENTERPRISE_PURPOSE_DRINK_STORAGE))
	switch(owner_level)
		if(2)
			raise_random_rooms(guest_list, 3, ENTERPRISE_LEVEL_IRON)
			for(var/datum/enterprise_room/store as anything in stores)
				store.raise_level(ENTERPRISE_LEVEL_IRON)
		if(3)
			raise_random_rooms(stores, 1, ENTERPRISE_LEVEL_SILVER)
		if(4 to INFINITY)
			raise_random_rooms(guest_list, 3, ENTERPRISE_LEVEL_SILVER)
			for(var/datum/enterprise_room/store as anything in stores)
				store.raise_level(ENTERPRISE_LEVEL_SILVER)
	return TRUE

/datum/enterprise/proc/redraw()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			floor.take_picture()
	reshow_floors()
	update_static_data_for_all_viewers()
	for(var/datum/enterprise_room/room as anything in rooms)
		SStgui.update_uis(room)

/datum/enterprise/proc/upgrade_room(mob/user, datum/enterprise_room/room, with_grade)
	if(QDELETED(room) || room.enterprise != src || !can_run_rooms(user))
		return FALSE
	var/russian = get_preferred_ui_language(user) == "ru"
	if(room.level >= ENTERPRISE_MAX_LEVEL)
		return FALSE
	var/target = room.level + 1
	if(with_grade)
		if(!spend_grade(target))
			to_chat(user, span_warning(russian ? "Сохранённого улучшения этого уровня нет." : "There is no saved upgrade of that level."))
			return FALSE
	else
		var/cost = get_upgrade_cost(room)
		if(!cost)
			to_chat(user, span_warning(russian ? "Первый уровень не продаётся: он приходит с уровнем владельца." : "The first level is not for sale: it comes with the owner's standing."))
			return FALSE
		var/yes = russian ? "Улучшить" : "Upgrade"
		var/no = russian ? "Отмена" : "Cancel"
		var/question = russian \
			? "Улучшить комнату «[room.name]» до уровня [target] за [cost]? Деньги спишутся из книги, а чего не хватит — с вашего счёта." \
			: "Upgrade [room.name] to level [target] for [cost]? The money comes from the ledger, and what it lacks from your account."
		if(tgui_alert(user, question, russian ? "Улучшение" : "Upgrade", list(yes, no)) != yes)
			return FALSE
		if(QDELETED(room) || QDELETED(user) || room.enterprise != src || !can_run_rooms(user) || room.level + 1 != target)
			return FALSE
		if(!pay(user, cost, "[name] room upgrade"))
			to_chat(user, span_warning(russian ? "Денег не хватает: нужно [cost]." : "There is not enough money: it takes [cost]."))
			return FALSE
		save_grade(target)
	room.set_level(target)
	to_chat(user, span_notice(russian ? "Комната «[room.name]» теперь уровня [target]." : "[room.name] is now level [target]."))
	redraw()
	return TRUE

/datum/enterprise/proc/can_run_rooms(mob/user)
	return is_owner(user) && ui_status(user, GLOB.physical_state) == UI_INTERACTIVE

/datum/enterprise/proc/room_action(mob/user, datum/enterprise_room/room, action)
	if(QDELETED(room) || room.enterprise != src || !can_run_rooms(user))
		return
	switch(action)
		if(ENTERPRISE_ROOM_ACTION_UPGRADE)
			room.show_page(user, ENTERPRISE_ROOM_PAGE_UPGRADE)
		if(ENTERPRISE_ROOM_ACTION_INFO)
			room.show_page(user, ENTERPRISE_ROOM_PAGE_INFO)
		if(ENTERPRISE_ROOM_ACTION_REPAIR)
			INVOKE_ASYNC(src, PROC_REF(repair_room), user, room)

/datum/enterprise/proc/repair_room(mob/user, datum/enterprise_room/room)
	var/cost = room.get_repair_cost()
	if(!cost)
		return FALSE
	var/russian = get_preferred_ui_language(user) == "ru"
	var/yes = russian ? "Починить" : "Repair"
	var/no = russian ? "Отмена" : "Cancel"
	var/question = russian \
		? "Вернуть на место всё, что пропало из комнаты «[room.name]»? Деньги спишутся из книги, а чего не хватит — с вашего счёта. Цена: [cost]." \
		: "Bring back everything that is gone from [room.name]? It costs [cost]: the money comes from the ledger, and what it lacks from your account."
	if(tgui_alert(user, question, russian ? "Починка" : "Repairs", list(yes, no)) != yes)
		return FALSE
	if(QDELETED(room) || QDELETED(user) || room.enterprise != src || !can_run_rooms(user))
		return FALSE
	cost = room.get_repair_cost()
	if(!cost)
		return FALSE
	if(!pay(user, cost, "[name] repairs"))
		to_chat(user, span_warning(russian ? "Денег не хватает: нужно [cost]." : "There is not enough money: it takes [cost]."))
		return FALSE
	room.repair()
	to_chat(user, span_notice(russian ? "Комната «[room.name]» приведена в порядок." : "[room.name] has been put back in order."))
	var/datum/enterprise_floor/floor = get_floor(room.z)
	if(floor)
		floor.take_picture()
		reshow_floors()
	SStgui.update_uis(room)
	return TRUE

/datum/enterprise_room/proc/show_page(mob/user, page)
	shown_pages[REF(user)] = page
	ui_interact(user)

/datum/enterprise_room/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, get_preferred_ui_language(user) == "ru" ? "EnterpriseRoomRu" : "EnterpriseRoom")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/enterprise_room/ui_state(mob/user)
	return GLOB.physical_state

/datum/enterprise_room/ui_host(mob/user)
	return enterprise ? enterprise.ui_host(user) : src

/datum/enterprise_room/ui_status(mob/user, datum/ui_state/state)
	if(!enterprise?.is_owner(user))
		return UI_CLOSE
	return ..()

/datum/enterprise_room/ui_close(mob/user)
	. = ..()
	shown_pages -= REF(user)

/datum/enterprise_room/proc/describe_type(atom/movable/described)
	return list(
		"name" = initial(described.name),
		"icon" = initial(described.icon),
		"icon_state" = initial(described.icon_state),
	)

/datum/enterprise_room/proc/get_contents_data()
	var/list/lines = list()
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		var/list/line = lines[fixture.fixture_type]
		if(!line)
			line = describe_type(fixture.fixture_type)
			line["id"] = "[fixture.fixture_type]"
			line["name"] = fixture.name
			line["value"] = fixture.value
			line["count"] = 0
			line["missing"] = 0
			lines[fixture.fixture_type] = line
		line["count"]++
		if(fixture.needs_repair())
			line["missing"]++
	var/list/contents_data = list()
	for(var/fixture_type in lines)
		contents_data += list(lines[fixture_type])
	return contents_data

/datum/enterprise_room/proc/get_upgrades_data()
	var/list/upgrades_data = list()
	if(level >= ENTERPRISE_MAX_LEVEL)
		return upgrades_data
	var/list/counts = list()
	var/list/becomes = list()
	for(var/datum/enterprise_fixture/fixture as anything in fixtures)
		var/next_type = fixture.get_level_type(level + 1)
		if(!next_type || next_type == fixture.fixture_type || !fixture.is_present())
			continue
		counts[fixture.fixture_type]++
		becomes[fixture.fixture_type] = next_type
	for(var/old_type in counts)
		upgrades_data += list(list(
			"id" = "[old_type]",
			"count" = counts[old_type],
			"from" = describe_type(old_type),
			"to" = describe_type(becomes[old_type]),
		))
	return upgrades_data

/datum/enterprise_room/ui_data(mob/user)
	var/russian = get_preferred_ui_language(user) == "ru"
	var/datum/enterprise_floor/floor = enterprise.get_floor(z)
	return list(
		"enterprise" = enterprise.name,
		"name" = name,
		"kind" = kind,
		"purpose" = template?.id,
		"floor" = floor?.basement ? 0 : enterprise.get_floor_number(z),
		"tiles" = length(turfs),
		"beds" = beds,
		"page" = shown_pages[REF(user)] || ENTERPRISE_ROOM_PAGE_INFO,
		"level" = level,
		"max_level" = ENTERPRISE_MAX_LEVEL,
		"effect" = template?.get_effect(src, level, russian),
		"next_effect" = template?.get_effect(src, level + 1, russian),
		"upgrade_cost" = enterprise.get_upgrade_cost(src),
		"can_grade" = enterprise.can_spend_grade(level + 1),
		"funds" = enterprise.book_balance + enterprise.get_bank_balance(user),
		"rent" = enterprise.get_rest_price(src),
		"seatings" = length(seatings),
		"contents" = get_contents_data(),
		"upgrades" = get_upgrades_data(),
		"repair_cost" = get_repair_cost(),
		"tenant" = get_tenant_data(),
	)

/datum/enterprise_room/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_page")
			var/page = params["page"]
			if(page != ENTERPRISE_ROOM_PAGE_INFO && page != ENTERPRISE_ROOM_PAGE_UPGRADE)
				return FALSE
			shown_pages[REF(ui.user)] = page
			return TRUE
		if("repair")
			enterprise.room_action(ui.user, src, ENTERPRISE_ROOM_ACTION_REPAIR)
			return FALSE
		if("upgrade")
			INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, upgrade_room), ui.user, src, FALSE)
			return FALSE
		if("prestige_grade")
			INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, upgrade_room), ui.user, src, TRUE)
			return FALSE
	return FALSE
