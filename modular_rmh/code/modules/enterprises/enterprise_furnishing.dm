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
		/obj/item/coin,
	)
	if(is_type_in_list(thing, ignored))
		return FALSE
	if(isitem(thing))
		return thing.sellprice > 0 && !thing.reagents?.total_volume
	return istype(thing, /obj/structure) || istype(thing, /obj/machinery)

/datum/enterprise/proc/take_fixtures(list/turf/fresh)
	var/list/datum/enterprise_fixture/taken = list()
	for(var/turf/member as anything in fresh)
		if(!contains(member))
			continue
		for(var/obj/thing in member)
			if(thing.invisibility || !is_fixture(thing))
				continue
			var/datum/enterprise_fixture/item = new(thing)
			fixture_refs[item.thing] = item
			taken += item
	fixtures += taken
	return taken

/datum/enterprise/proc/mark_start_stock(list/turf/fresh)
	for(var/turf/member as anything in fresh)
		if(!contains(member))
			continue
		for(var/obj/thing in member)
			mark_stock(thing)

/datum/enterprise/proc/mark_round_start_stock()
	for(var/area/place as anything in GLOB.areas)
		if(!is_premises_area(place))
			continue
		for(var/turf/member as anything in place.get_turfs_from_all_zlevels())
			for(var/obj/thing in member)
				mark_stock(thing)

/datum/enterprise/proc/mark_stock(obj/thing)
	if(isitem(thing))
		ADD_TRAIT(thing, TRAIT_ENTERPRISE_START_STOCK, REF(src))
	mark_house_drink(thing)
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
		room.inventory = null
	for(var/datum/enterprise_fixture/item as anything in fixtures)
		var/datum/enterprise_room/room = get_room(item.home) || get_adjoining_room(item.home)
		room?.add_fixture(item)
	var/list/datum/enterprise_room_template/templates = get_room_templates()
	for(var/datum/enterprise_room/room as anything in rooms)
		room.furnish(templates)
		for(var/datum/enterprise_room_template/template as anything in templates)
			if(template.claims_kind && template.claims_kind == room.kind && room.template != template)
				template.report_unmatched(room)
	group_rooms()
	for(var/datum/enterprise_room/room as anything in rooms)
		room.check_inventory()
		room.beds = room.count_fixtures(/obj/structure/bed)

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
	var/list/patron_rent_percents = list(100, 100, 150, 250, 400)
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
	if(room.level < ENTERPRISE_LEVEL_WOOD)
		return ENTERPRISE_BARE_REST_PRICE
	return get_level_value(rest_prices, room.level) || 0

/datum/enterprise/proc/get_grant_order(group)
	var/list/datum/enterprise_room_template/pending = list()
	for(var/datum/enterprise_room_template/template as anything in get_room_templates())
		if(template.grant_group == group)
			pending += template
	var/list/datum/enterprise_room/order = list()
	while(length(pending))
		var/datum/enterprise_room_template/first = pending[1]
		for(var/datum/enterprise_room_template/template as anything in pending)
			if(template.grant_rank < first.grant_rank)
				first = template
		pending -= first
		var/list/datum/enterprise_room/found = list()
		for(var/datum/enterprise_room/room as anything in rooms)
			if(room.template == first)
				found |= room.get_leader()
		order += first.grant_shuffled ? get_random_order(found) : found
	return order

/datum/enterprise/proc/raise_team(datum/enterprise_room/room, level, apply = TRUE)
	for(var/datum/enterprise_room/member as anything in room.get_members())
		member.raise_level(level, apply)

/datum/enterprise/proc/get_random_order(list/pool)
	var/list/order = list()
	var/list/left = pool.Copy()
	while(length(left))
		var/picked = pick(left)
		left -= picked
		order += picked
	return order

/datum/enterprise/proc/raise_rooms(list/datum/enterprise_room/order, amount, level, apply = TRUE)
	for(var/datum/enterprise_room/room as anything in order)
		if(amount <= 0)
			return
		if(room.level >= level)
			continue
		raise_team(room, level, apply)
		amount--

/datum/enterprise/proc/grant_owner_rooms(owner_level, apply = TRUE)
	if(owner_level < 1)
		return FALSE
	var/base = owner_level >= 3 ? ENTERPRISE_LEVEL_IRON : ENTERPRISE_LEVEL_WOOD
	for(var/datum/enterprise_room/room as anything in rooms)
		room.raise_level(base, apply)
	var/list/datum/enterprise_room/living = get_grant_order(ENTERPRISE_GRANT_LIVING)
	var/list/datum/enterprise_room/stores = get_grant_order(ENTERPRISE_GRANT_STORES)
	switch(owner_level)
		if(2)
			raise_rooms(living, 3, ENTERPRISE_LEVEL_IRON, apply)
			raise_rooms(stores, length(stores), ENTERPRISE_LEVEL_IRON, apply)
		if(3)
			raise_rooms(get_random_order(stores), 1, ENTERPRISE_LEVEL_SILVER, apply)
		if(4 to INFINITY)
			raise_rooms(living, 3, ENTERPRISE_LEVEL_SILVER, apply)
			raise_rooms(stores, length(stores), ENTERPRISE_LEVEL_SILVER, apply)
	return TRUE

/datum/enterprise/proc/redraw(datum/enterprise_room/changed)
	if(changed)
		for(var/datum/enterprise_room/member as anything in changed.get_members())
			get_floor(member.z)?.mark_stale()
	else
		for(var/datum/enterprise_floor/floor as anything in floors)
			floor?.mark_stale()
	refresh_viewers()
	update_static_data_for_all_viewers()
	push_room_windows()

/datum/enterprise/proc/upgrade_room(mob/user, datum/enterprise_room/room, with_grade)
	room = room?.get_leader()
	if(QDELETED(room) || room.enterprise != src || !can_run_rooms(user))
		return FALSE
	var/russian = get_preferred_ui_language(user) == "ru"
	var/title = room.get_title(russian)
	if(room.level >= ENTERPRISE_MAX_LEVEL || !check_intact(user, room))
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
			? "Улучшить комнату «[title]» до уровня [target] за [cost]? Деньги спишутся из книги, а чего не хватит — с вашего счёта." \
			: "Upgrade [title] to level [target] for [cost]? The money comes from the ledger, and what it lacks from your account."
		if(tgui_alert(user, question, russian ? "Улучшение" : "Upgrade", list(yes, no)) != yes)
			return FALSE
		if(QDELETED(room) || QDELETED(user) || room.enterprise != src || !can_run_rooms(user) || room.level + 1 != target)
			return FALSE
		if(!check_intact(user, room))
			return FALSE
		if(!pay(user, cost, "[name] room upgrade", FALSE))
			to_chat(user, span_warning(russian ? "Денег не хватает: нужно [cost]." : "There is not enough money: it takes [cost]."))
			return FALSE
		save_grade(target)
	for(var/datum/enterprise_room/member as anything in room.get_members())
		member.set_level(target)
	to_chat(user, span_notice(russian ? "Комната «[title]» теперь уровня [target]." : "[title] is now level [target]."))
	redraw(room)
	return TRUE

/datum/enterprise/proc/can_run_rooms(mob/user)
	return is_owner(user) && ui_status(user, GLOB.physical_state) == UI_INTERACTIVE

/datum/enterprise/proc/room_action(mob/user, datum/enterprise_room/room, action)
	room = room?.get_leader()
	if(QDELETED(room) || room.enterprise != src || !can_run_rooms(user))
		return
	check_rooms(room.get_members())
	switch(action)
		if(ENTERPRISE_ROOM_ACTION_UPGRADE)
			room.show_page(user, ENTERPRISE_ROOM_PAGE_UPGRADE)
		if(ENTERPRISE_ROOM_ACTION_INFO)
			room.show_page(user, ENTERPRISE_ROOM_PAGE_INFO)
		if(ENTERPRISE_ROOM_ACTION_REPAIR)
			INVOKE_ASYNC(src, PROC_REF(repair_room), user, room)

/datum/enterprise/proc/repair_room(mob/user, datum/enterprise_room/room)
	room = room.get_leader()
	var/russian = get_preferred_ui_language(user) == "ru"
	var/title = room.get_title(russian)
	if(!room.get_team_damage())
		to_chat(user, span_notice(russian ? "В комнате «[title]» всё на месте." : "Everything in [title] is in its place."))
		return FALSE
	var/book_cost = room.get_repair_cost()
	if(book_balance >= book_cost)
		book_balance -= book_cost
		return finish_repair(user, room, book_cost)
	var/account_cost = room.get_account_repair_cost()
	if(get_bank_balance(user) < account_cost)
		to_chat(user, span_warning(russian \
			? "Не хватает средств: починка стоит [book_cost] из книги или [account_cost] со счёта." \
			: "There is not enough money: the repairs cost [book_cost] from the ledger or [account_cost] from the account."))
		return FALSE
	var/yes = russian ? "Починить" : "Repair"
	var/no = russian ? "Отмена" : "Cancel"
	var/question = russian \
		? "В книге нет [book_cost]. Починить комнату «[title]» со своего счёта за [account_cost]?" \
		: "The ledger does not hold [book_cost]. Repair [title] from your own account for [account_cost]?"
	if(tgui_alert(user, question, russian ? "Починка" : "Repairs", list(yes, no)) != yes)
		return FALSE
	if(QDELETED(room) || QDELETED(user) || room.enterprise != src || !can_run_rooms(user))
		return FALSE
	check_rooms(room.get_members())
	if(room.get_account_repair_cost() != account_cost)
		to_chat(user, span_warning(russian \
			? "Пока вы решали, в комнате «[title]» что-то изменилось. Попробуйте ещё раз." \
			: "While you were deciding, something changed in [title]. Try again."))
		return FALSE
	if(get_bank_balance(user) < account_cost)
		to_chat(user, span_warning(russian ? "Не хватает средств: нужно [account_cost] на счёте." : "There is not enough money: it takes [account_cost] from the account."))
		return FALSE
	SStreasury.bank_accounts[user] -= account_cost
	SStreasury.log_to_steward("-[account_cost] from [user.real_name] ([name] repairs)")
	return finish_repair(user, room, account_cost)

/datum/enterprise/proc/finish_repair(mob/user, datum/enterprise_room/room, cost)
	for(var/datum/enterprise_room/member as anything in room.get_members())
		member.repair()
	var/russian = get_preferred_ui_language(user) == "ru"
	var/title = room.get_title(russian)
	to_chat(user, span_notice(russian ? "Комната «[title]» приведена в порядок за [cost]." : "[title] has been put back in order for [cost]."))
	redraw(room)
	return TRUE

/datum/enterprise_room/proc/show_page(mob/user, page)
	shown_pages[REF(user)] = page
	page_seq++
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
	for(var/datum/enterprise_room/member as anything in get_members())
		for(var/fixture_type in member.inventory)
			var/datum/enterprise_fixture_group/group = member.inventory[fixture_type]
			var/list/line = lines[fixture_type]
			if(!line)
				line = describe_type(fixture_type)
				line["id"] = "[fixture_type]"
				line["name"] = group.name
				line["count"] = 0
				line["missing"] = 0
				line["misplaced"] = 0
				line["broken"] = 0
				lines[fixture_type] = line
			line["count"] += length(group.items)
			line["missing"] += group.missing
			line["misplaced"] += group.misplaced
			line["broken"] += group.broken
	var/list/contents_data = list()
	for(var/fixture_type in lines)
		contents_data += list(lines[fixture_type])
	return contents_data

/datum/enterprise_room/proc/get_upgrades_data()
	var/list/upgrades_data = list()
	if(level >= ENTERPRISE_MAX_LEVEL)
		return upgrades_data
	var/list/lines = list()
	for(var/datum/enterprise_room/member as anything in get_members())
		for(var/fixture_type in member.inventory)
			var/datum/enterprise_fixture_group/group = member.inventory[fixture_type]
			var/next_type = group.family?.get_tier(level + 1)
			if(!next_type || next_type == fixture_type)
				continue
			var/list/line = lines[fixture_type]
			if(!line)
				line = list(
					"id" = "[fixture_type]",
					"count" = 0,
					"from" = describe_type(fixture_type),
					"to" = describe_type(next_type),
				)
				lines[fixture_type] = line
			line["count"] += length(group.items)
	for(var/fixture_type in lines)
		upgrades_data += list(lines[fixture_type])
	return upgrades_data

/datum/enterprise_room/ui_data(mob/user)
	var/russian = get_preferred_ui_language(user) == "ru"
	var/list/datum/enterprise_room/team = get_members()
	var/tiles = 0
	var/bed_count = 0
	var/seating_count = 0
	var/list/floor_numbers = list()
	var/list/part_names = list()
	for(var/datum/enterprise_room/member as anything in team)
		tiles += length(member.turfs)
		bed_count += member.beds
		seating_count += length(member.seatings)
		var/datum/enterprise_floor/floor = enterprise.get_floor(member.z)
		floor_numbers |= floor?.basement ? 0 : enterprise.get_floor_number(member.z)
		if(length(team) > 1)
			part_names += member.name
	return list(
		"enterprise" = enterprise.name,
		"name" = name,
		"kind" = kind,
		"purpose" = template?.id,
		"grouped" = length(team) > 1,
		"parts" = part_names,
		"floors" = floor_numbers,
		"tiles" = tiles,
		"beds" = bed_count,
		"page" = shown_pages[REF(user)] || ENTERPRISE_ROOM_PAGE_INFO,
		"page_seq" = page_seq,
		"level" = level,
		"max_level" = ENTERPRISE_MAX_LEVEL,
		"effect" = template?.get_effect(src, level, russian),
		"next_effect" = template?.get_effect(src, level + 1, russian),
		"upgrade_cost" = enterprise.get_upgrade_cost(src),
		"can_grade" = enterprise.can_spend_grade(level + 1),
		"funds" = enterprise.book_balance + enterprise.get_bank_balance(user),
		"rent" = enterprise.get_rest_price(src),
		"seatings" = seating_count,
		"contents" = get_contents_data(),
		"upgrades" = get_upgrades_data(),
		"repair_cost" = get_repair_cost(),
		"repair_account_cost" = get_account_repair_cost(),
		"tenant" = get_tenant_data(),
	)

/datum/enterprise_room/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return FALSE
	switch(action)
		if("set_page")
			var/page = params["page"]
			if(page != ENTERPRISE_ROOM_PAGE_INFO && page != ENTERPRISE_ROOM_PAGE_UPGRADE)
				return FALSE
			shown_pages[REF(ui.user)] = page
			return FALSE
		if("repair")
			if(enterprise.press(ui.user, action))
				enterprise.room_action(ui.user, src, ENTERPRISE_ROOM_ACTION_REPAIR)
			return FALSE
		if("upgrade")
			if(enterprise.press(ui.user, action))
				INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, upgrade_room), ui.user, src, FALSE)
			return FALSE
		if("prestige_grade")
			if(enterprise.press(ui.user, action))
				INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, upgrade_room), ui.user, src, TRUE)
			return FALSE
	return FALSE
