/datum/enterprise_stock_entry
	var/item_type
	var/name
	var/amount = 0
	var/price = 0

/datum/enterprise_stock
	var/datum/enterprise/enterprise
	var/datum/enterprise_room/storage
	var/obj/structure/fake_machine/enterprise_stock/post
	var/list/datum/enterprise_stock_entry/entries = list()

/datum/enterprise_stock/New(datum/enterprise/enterprise, datum/enterprise_room/storage)
	src.enterprise = enterprise
	src.storage = storage

/datum/enterprise_stock/Destroy()
	QDEL_LIST_ASSOC_VAL(entries)
	if(post)
		post.stock = null
		QDEL_NULL(post)
	enterprise = null
	storage = null
	return ..()

/datum/enterprise_stock/proc/get_cap()
	var/level = max(storage ? storage.level : ENTERPRISE_LEVEL_BARE, ENTERPRISE_LEVEL_WOOD)
	return enterprise.get_level_value(enterprise.stock_caps, level) || 0

/datum/enterprise_stock/proc/get_buyout_price(datum/enterprise_stock_entry/entry)
	return max(round(entry.price * ENTERPRISE_BUYOUT_PERCENT / 100), 1)

/datum/enterprise_stock/proc/can_take(obj/item/offered)
	if(!enterprise.get_stock_price(offered))
		return FALSE
	var/datum/enterprise_stock_entry/entry = entries[offered.type]
	return !entry || entry.amount < get_cap()

/datum/enterprise_stock/proc/take(obj/item/offered)
	var/price = enterprise.get_stock_price(offered)
	if(!price)
		return 0
	var/datum/enterprise_stock_entry/entry = entries[offered.type]
	if(!entry)
		entry = new
		entry.item_type = offered.type
		entry.name = initial(offered.name)
		entries[offered.type] = entry
	if(entry.amount >= get_cap())
		return 0
	entry.amount++
	entry.price = price
	return price

/datum/enterprise_stock/proc/give(item_type)
	var/datum/enterprise_stock_entry/entry = entries[item_type]
	if(!entry || entry.amount < 1)
		return null
	entry.amount--
	return entry

/datum/enterprise_stock/proc/get_entries_data()
	var/list/entries_data = list()
	for(var/item_type in entries)
		var/datum/enterprise_stock_entry/entry = entries[item_type]
		if(entry.amount < 1)
			continue
		var/obj/item/prototype = item_type
		entries_data += list(list(
			"id" = "[item_type]",
			"name" = entry.name,
			"icon" = initial(prototype.icon),
			"icon_state" = initial(prototype.icon_state),
			"amount" = entry.amount,
			"price" = entry.price,
			"buyout" = get_buyout_price(entry),
		))
	return entries_data

/datum/enterprise
	var/list/stock_goods = list()

/datum/enterprise/proc/get_stock_price(obj/item/offered)
	if(!is_type_in_list(offered, stock_goods))
		return 0
	var/own_price = round(offered.get_real_price())
	if(own_price > 0)
		return own_price
	for(var/datum/stock/town_stock as anything in SStreasury.stockpile_datums)
		if(town_stock.item_type == offered.type)
			return town_stock.withdraw_price
	return 0

/datum/enterprise/proc/place_stock_posts()
	for(var/datum/enterprise_room/room as anything in rooms)
		if(room.stock || room.get_purpose() != ENTERPRISE_PURPOSE_STORAGE)
			continue
		var/turf/outside = room.get_door_step()
		if(!outside)
			continue
		room.stock = new(src, room)
		var/obj/structure/fake_machine/enterprise_stock/post = new(outside)
		post.stock = room.stock
		room.stock.post = post
		for(var/direction in GLOB.cardinals)
			if(!isclosedturf(get_step(outside, direction)))
				continue
			if(direction & (NORTH | SOUTH))
				post.pixel_y = direction == NORTH ? ICON_SIZE_Y : -ICON_SIZE_Y
			else
				post.pixel_x = direction == EAST ? ICON_SIZE_X : -ICON_SIZE_X
			break
