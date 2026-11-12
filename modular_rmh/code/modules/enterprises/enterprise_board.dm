/obj/structure/questboard/tavern
	var/enterprise_type = /datum/enterprise/tavern
	var/order_timer

/obj/structure/questboard/tavern/Destroy()
	stop_order_checks()
	return ..()

/obj/structure/questboard/tavern/proc/get_enterprise()
	RETURN_TYPE(/datum/enterprise)
	return SSenterprises.enterprises[enterprise_type]

/obj/structure/questboard/tavern/ui_interact(mob/user, datum/tgui/ui)
	if(!order_timer)
		get_enterprise()?.check_orders()
	. = ..()
	if(!order_timer && length(open_uis))
		order_timer = addtimer(CALLBACK(src, PROC_REF(check_orders)), ENTERPRISE_BOARD_CHECK_INTERVAL, TIMER_STOPPABLE | TIMER_LOOP)

/obj/structure/questboard/tavern/ui_data(mob/user)
	. = ..()
	var/datum/enterprise/enterprise = get_enterprise()
	.["orders"] = enterprise ? enterprise.get_board_orders(get_preferred_ui_language(user) == "ru") : list()
	.["order_log"] = enterprise ? enterprise.order_log : list()

/obj/structure/questboard/tavern/proc/check_orders()
	if(!length(open_uis))
		stop_order_checks()
		return 0
	return get_enterprise()?.check_orders()

/obj/structure/questboard/tavern/proc/stop_order_checks()
	if(order_timer)
		deltimer(order_timer)
		order_timer = null

/datum/enterprise
	var/list/order_log = list()
	var/order_log_seq = 0

/datum/enterprise/proc/check_orders()
	var/served = 0
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		if(patron.meal_order?.check_served())
			served++
	return served

/datum/enterprise/proc/get_board_orders(russian)
	var/list/orders = list()
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		var/datum/enterprise_order/order = patron.meal_order
		if(order && order.state != ENTERPRISE_ORDER_STATE_NOTE && patron.get_goal() == ENTERPRISE_PATRON_GOAL_ORDER)
			orders += list(order.get_board_data(russian))
	return orders

/datum/enterprise/proc/log_order(datum/enterprise_order/order, served, paid)
	order_log.Insert(1, list(list(
		"id" = ++order_log_seq,
		"guest" = capitalize(order.patron.name),
		"dish" = order.dish_name,
		"drink" = order.drink_name,
		"drunk" = order.drunk,
		"served" = served,
		"paid" = paid,
		"time" = station_time_timestamp("hh:mm"),
	)))
	if(length(order_log) > ENTERPRISE_ORDER_LOG_MAX)
		order_log.Cut(ENTERPRISE_ORDER_LOG_MAX + 1)

/datum/enterprise_order/proc/get_board_data(russian)
	return list(
		"id" = REF(src),
		"guest" = capitalize(patron.name),
		"place" = patron.table_set?.room?.get_title(russian),
		"dish" = dish_name,
		"drink" = drink_name,
		"portion" = ENTERPRISE_ORDER_DRINK_PORTION,
		"wish" = wish,
		"state" = state,
		"time_left" = deadline ? max(deadline - world.time, 0) : null,
		"drunk" = drunk,
		"morning" = morning,
	)
