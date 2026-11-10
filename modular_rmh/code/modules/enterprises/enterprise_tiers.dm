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
