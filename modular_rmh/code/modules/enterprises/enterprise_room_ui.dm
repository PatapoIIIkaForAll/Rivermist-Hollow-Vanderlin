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
