/obj/structure/fake_machine/technician_workshop
	name = "technician's workbench"
	desc = "A compact workshop where a dedicated technician produces practical goods for the faction."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "streetvendor0"
	density = TRUE
	anchored = TRUE
	blade_dulling = DULLING_BASH

	/// Each workstation instance owns an independent resource stock and mammon depot.
	var/list/resource_stock = list()
	/// Resource units indexed by the exact deposited item type for lossless withdrawals.
	/// resource_source_stock[resource_id]["/obj/item/path"] = resource units represented.
	var/list/resource_source_stock = list()
	var/budget = 0

	/// One unattended crafting operation at a time.
	var/is_crafting = FALSE
	var/active_recipe_type
	var/active_recipe_name
	var/craft_finish_time = 0
	var/craft_total_time = 0
	var/craft_timer_id

	/// DMI supplied by the project. Required states: "idle" and "busy".
	var/technician_portrait_icon = "modular_rmh/icons/machines/technician.dmi"

/obj/structure/fake_machine/technician_workshop/Initialize(mapload)
	. = ..()
	// Always allocate a fresh list: each spawned workstation must own its stock.
	resource_stock = list()
	resource_source_stock = list()

	// Initialize every registered resource to zero on this station only.
	for(var/datum/technician_resource/resource_type as anything in subtypesof(/datum/technician_resource))
		if(IS_ABSTRACT(resource_type))
			continue
		var/datum/technician_resource/R = new resource_type()
		resource_stock[R.id] = 0
		resource_source_stock[R.id] = list()
		qdel(R)

/obj/structure/fake_machine/technician_workshop/Destroy()
	if(craft_timer_id)
		deltimer(craft_timer_id)
		craft_timer_id = null
	return ..()

/obj/structure/fake_machine/technician_workshop/proc/get_resource_amount(resource_id)
	var/current_amount = resource_stock[resource_id]
	if(!isnum(current_amount) || current_amount < 0)
		return 0
	return current_amount

/obj/structure/fake_machine/technician_workshop/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!tool || !user || user.cmode)
		return NONE

	// Mammons are physically deposited into this workstation, like a peddler.
	// This codebase uses /obj/item/coin (not the legacy /obj/item/roguecoin).
	if(istype(tool, /obj/item/coin))
		var/obj/item/coin/deposited_coin = tool
		var/money = deposited_coin.get_real_price()
		if(!isnum(money) || money <= 0)
			return ITEM_INTERACT_BLOCKING

		budget += money
		qdel(tool)
		to_chat(user, span_info("I deposit [money] amnas into [src]."))
		playsound(src, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		SStgui.update_uis(src)
		attack_hand(user)
		return ITEM_INTERACT_SUCCESS

	// Resolve resource input from explicit resource definitions. Natural bundles
	// contribute their actual bundle amount, not one unit per bundle object.
	var/list/deposit = get_technician_resource_deposit(tool)
	if(!deposit)
		return NONE

	var/resource_id = deposit["id"]
	var/deposit_amount = deposit["amount"]
	if(!istext(resource_id) || !isnum(deposit_amount) || deposit_amount <= 0)
		return ITEM_INTERACT_BLOCKING

	var/datum/technician_resource/resource_definition = get_technician_resource_definition(resource_id)
	if(!resource_definition)
		return ITEM_INTERACT_BLOCKING

	resource_stock[resource_id] = get_resource_amount(resource_id) + deposit_amount
	var/list/source_stock = resource_source_stock[resource_id]
	if(!islist(source_stock))
		source_stock = list()
	var/source_type_key = "[tool.type]"
	source_stock[source_type_key] = (source_stock[source_type_key] || 0) + deposit_amount
	resource_source_stock[resource_id] = source_stock
	var/resource_name = resource_definition.name
	qdel(resource_definition)

	qdel(tool)
	to_chat(user, span_info("I deposit [deposit_amount] [resource_name] into [src]."))
	playsound(src, 'sound/misc/machinevomit.ogg', 75, TRUE, -1)
	SStgui.update_uis(src)
	attack_hand(user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/fake_machine/technician_workshop/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, 'sound/misc/beep.ogg', 75, FALSE, -1)
	ui_interact(user)

/obj/structure/fake_machine/technician_workshop/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/fake_machine/technician_workshop/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TechnicianWorkshop", name, 850, 800)
		ui.open()

/obj/structure/fake_machine/technician_workshop/ui_data(mob/user)
	var/list/data = list()
	data["title"] = name
	data["budget"] = budget
	data["is_crafting"] = is_crafting ? TRUE : FALSE
	data["active_recipe_name"] = active_recipe_name ? active_recipe_name : ""
	data["active_recipe_ref"] = active_recipe_type ? "[active_recipe_type]" : ""
	data["craft_time_remaining"] = is_crafting ? max(0, round((craft_finish_time - world.time) / 10)) : 0
	data["craft_total_time"] = is_crafting ? max(1, round(craft_total_time / 10)) : 0
	// Frontend uses this snapshot marker to keep the countdown moving between server UI updates.
	data["craft_time_snapshot"] = world.time
	data["technician_icon"] = technician_portrait_icon
	data["technician_state"] = is_crafting ? "busy" : "idle"

	var/list/resources = list()
	for(var/datum/technician_resource/resource_type as anything in subtypesof(/datum/technician_resource))
		if(IS_ABSTRACT(resource_type))
			continue
		var/datum/technician_resource/R = new resource_type()
		var/obj/item/icon_item = R.icon_item_type
		resources += list(list(
			"id" = R.id,
			"name" = R.name,
			"amount" = get_resource_amount(R.id),
			"icon" = icon_item ? "[initial(icon_item.icon)]" : "",
			"icon_state" = R.icon_state_override ? R.icon_state_override : (icon_item ? initial(icon_item.icon_state) : ""),
			"can_withdraw" = get_resource_amount(R.id) > 0 ? TRUE : FALSE,
		))
		qdel(R)
	data["mammon_icon"] = "icons/roguetown/items/valuable.dmi"
	data["mammon_icon_state"] = "c1"
	data["can_withdraw_mammons"] = budget > 0 ? TRUE : FALSE
	data["resources"] = resources

	var/list/categories = list()
	var/list/recipes = list()
	for(var/datum/technician_recipe/recipe_type as anything in subtypesof(/datum/technician_recipe))
		if(IS_ABSTRACT(recipe_type))
			continue

		var/datum/technician_recipe/R = new recipe_type()
		if(!R.name || !R.created_item || !ispath(R.created_item, /obj/item))
			qdel(R)
			continue

		var/category_name = R.category ? R.category : "Miscellaneous"
		var/fee_is_valid = isnum(R.service_fee) && R.service_fee >= 0 && round(R.service_fee) == R.service_fee
		var/time_is_valid = isnum(R.craft_time) && R.craft_time > 0 && round(R.craft_time) == R.craft_time
		if(!(category_name in categories))
			categories += category_name

		var/list/requirements = list()
		var/resource_costs_valid = islist(R.resource_costs)
		var/resources_sufficient = resource_costs_valid
		for(var/resource_id in R.resource_costs)
			var/required_amount = R.resource_costs[resource_id]
			if(!isnum(required_amount) || required_amount <= 0 || round(required_amount) != required_amount)
				resources_sufficient = FALSE
				continue

			var/datum/technician_resource/required_resource = get_technician_resource_definition(resource_id)
			var/resource_name = required_resource ? required_resource.name : resource_id
			var/available_amount = get_resource_amount(resource_id)
			var/missing_amount = max(0, required_amount - available_amount)
			if(missing_amount > 0 || !required_resource)
				resources_sufficient = FALSE

			requirements += list(list(
				"id" = resource_id,
				"name" = resource_name,
				"required" = required_amount,
				"available" = available_amount,
				"missing" = missing_amount,
			))
			if(required_resource)
				qdel(required_resource)

		var/obj/item/output_type = R.created_item
		var/output_count = (isnum(R.output_amount) && round(R.output_amount) == R.output_amount) ? clamp(R.output_amount, 1, 20) : 1
		var/output_is_valid = isnum(R.output_amount) && round(R.output_amount) == R.output_amount && R.output_amount >= 1 && R.output_amount <= 20
		var/list/recipe_data = list(
			"ref" = "[R.type]",
			"name" = R.name,
			"category" = category_name,
			"desc" = R.desc,
			"output_name" = initial(output_type.name),
			"output_icon" = "[initial(output_type.icon)]",
			"output_state" = initial(output_type.icon_state),
			"output_amount" = output_count,
			"requirements" = requirements,
			"service_fee" = fee_is_valid ? R.service_fee : 0,
			"craft_time" = time_is_valid ? round(R.craft_time / 10) : 0,
			"resources_sufficient" = resources_sufficient ? TRUE : FALSE,
			"can_craft" = (!is_crafting && resource_costs_valid && resources_sufficient && fee_is_valid && time_is_valid && output_is_valid && budget >= R.service_fee) ? TRUE : FALSE,
		)
		recipes += list(recipe_data)
		qdel(R)

	data["categories"] = categories
	data["recipes"] = recipes
	return data

/obj/structure/fake_machine/technician_workshop/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return
	if(!usr.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return

	switch(action)
		if("start_craft")
			var/recipe_ref = params["recipe"]
			start_craft(recipe_ref, usr)
			return TRUE
		if("withdraw_resource")
			withdraw_resource(params["resource_id"], usr)
			return TRUE
		if("withdraw_mammons")
			withdraw_mammons(usr)
			return TRUE

/obj/structure/fake_machine/technician_workshop/proc/consume_resource_source_stock(resource_id, amount)
	var/list/source_stock = resource_source_stock[resource_id]
	if(!islist(source_stock) || amount <= 0)
		return

	var/remaining = amount
	var/list/source_keys = source_stock.Copy()
	for(var/source_key as anything in source_keys)
		if(remaining <= 0)
			break
		var/available = source_stock[source_key]
		var/taken = min(available, remaining)
		available -= taken
		remaining -= taken
		if(available <= 0)
			source_stock -= source_key
		else
			source_stock[source_key] = available
	resource_source_stock[resource_id] = source_stock

/obj/structure/fake_machine/technician_workshop/proc/withdraw_resource(resource_id, mob/living/user)
	if(!user || QDELETED(user) || !user.Adjacent(src) || !istext(resource_id))
		return FALSE

	var/amount = get_resource_amount(resource_id)
	if(amount <= 0)
		return FALSE

	var/datum/technician_resource/R = get_technician_resource_definition(resource_id)
	if(!R)
		return FALSE

	var/list/source_stock = resource_source_stock[resource_id]
	if(!islist(source_stock) || !length(source_stock))
		log_game("Technician workshop [REF(src)] has [amount] [resource_id] but no source-stock record; refusing withdrawal to prevent material creation.")
		qdel(R)
		return FALSE

	// Validate all output representations before spawning any of them.
	for(var/source_key as anything in source_stock)
		var/source_type = text2path(source_key)
		if(!R.can_withdraw_source_type(source_type, source_stock[source_key]))
			log_game("Technician workshop [REF(src)] has invalid withdrawal source [source_key] for resource [resource_id].")
			qdel(R)
			return FALSE

	var/turf/drop_turf = get_turf(src)
	if(!drop_turf)
		qdel(R)
		return FALSE

	for(var/source_key as anything in source_stock.Copy())
		var/source_type = text2path(source_key)
		if(!R.create_withdrawal(drop_turf, source_type, source_stock[source_key]))
			// The source type was validated above; this is a defensive fallback.
			log_game("Technician workshop [REF(src)] failed to recreate [source_key] while withdrawing [resource_id].")
			qdel(R)
			return FALSE

	resource_stock[resource_id] = 0
	source_stock.Cut()
	resource_source_stock[resource_id] = source_stock
	to_chat(user, span_notice("I withdraw [amount] [R.name] from [src]."))
	playsound(src, 'sound/misc/machinevomit.ogg', 75, TRUE, -1)
	qdel(R)
	SStgui.update_uis(src)
	return TRUE

/obj/structure/fake_machine/technician_workshop/proc/dispense_mammon_change(amount, mob/living/user)
	// Mirrors the peddler's budget2change() payout pattern, using the current
	// /obj/item/coin denominations from Coin.dm and the 20-coin stack limit.
	// Change is dispensed beside the player; the final stack of each denomination
	// is offered to their hands, matching the peddler behavior.
	if(!isnum(amount) || amount <= 0 || round(amount) != amount)
		return FALSE

	var/turf/drop_turf = user ? get_turf(user) : get_turf(src)
	if(!drop_turf)
		return FALSE

	var/remaining = amount
	var/list/coin_denominations = list(
		/obj/item/coin/platinum = 1000,
		/obj/item/coin/gold = 100,
		/obj/item/coin/electrum = 50,
		/obj/item/coin/silver = 10,
		/obj/item/coin/copper = 1,
	)

	for(var/coin_type as anything in coin_denominations)
		var/coin_value = coin_denominations[coin_type]
		var/coin_count = floor(remaining / coin_value)
		if(coin_count <= 0)
			continue
		remaining -= coin_count * coin_value
		while(coin_count > 0)
			var/stack_size = min(coin_count, 20)
			var/obj/item/coin/coin_stack = new coin_type(drop_turf, stack_size)
			if(user && coin_count == stack_size)
				user.put_in_hands(coin_stack)
			coin_count -= stack_size

	playsound(drop_turf, 'sound/misc/coindispense.ogg', 100, FALSE, -1)
	return TRUE

/obj/structure/fake_machine/technician_workshop/proc/withdraw_mammons(mob/living/user)
	if(!user || QDELETED(user) || !user.Adjacent(src) || budget <= 0)
		return FALSE

	var/withdrawal_amount = budget
	if(!dispense_mammon_change(withdrawal_amount, user))
		return FALSE

	budget = 0
	to_chat(user, span_notice("The workshop dispenses [withdrawal_amount] amnas in change."))
	SStgui.update_uis(src)
	return TRUE

/obj/structure/fake_machine/technician_workshop/proc/start_craft(recipe_ref, mob/living/user)
	if(!user || QDELETED(user))
		return FALSE
	if(is_crafting)
		to_chat(user, span_warning("The technician is already working on an item."))
		return FALSE

	if(!istext(recipe_ref))
		return FALSE

	var/datum/technician_recipe/recipe_type = text2path(recipe_ref)
	if(!ispath(recipe_type, /datum/technician_recipe) || IS_ABSTRACT(recipe_type))
		log_admin("Invalid technician recipe request from [key_name(user)]: [recipe_ref]")
		return FALSE

	var/datum/technician_recipe/R = new recipe_type()
	if(!ispath(R.created_item, /obj/item) || !islist(R.resource_costs) || !isnum(R.service_fee) || R.service_fee < 0 || round(R.service_fee) != R.service_fee || !isnum(R.craft_time) || R.craft_time <= 0 || round(R.craft_time) != R.craft_time || !isnum(R.output_amount) || round(R.output_amount) != R.output_amount || R.output_amount < 1 || R.output_amount > 20)
		qdel(R)
		return FALSE

	// Validate every requirement before modifying any stock or budget.
	for(var/resource_id in R.resource_costs)
		var/required_amount = R.resource_costs[resource_id]
		if(!istext(resource_id) || !length(resource_id) || !isnum(required_amount) || required_amount <= 0 || round(required_amount) != required_amount)
			qdel(R)
			return FALSE
		var/datum/technician_resource/required_resource = get_technician_resource_definition(resource_id)
		if(!required_resource)
			log_game("Technician recipe [recipe_type] references unknown resource ID [resource_id].")
			qdel(R)
			return FALSE
		qdel(required_resource)
		if(get_resource_amount(resource_id) < required_amount)
			to_chat(user, span_warning("The workshop does not have enough [resource_id]."))
			qdel(R)
			return FALSE

	if(budget < R.service_fee)
		to_chat(user, span_warning("The workshop does not have enough amnas in its depot to pay the service fee."))
		qdel(R)
		return FALSE

	// Commit the transaction only after all checks pass. No player reference is
	// retained after this point; the workshop owns the operation and its timer.
	for(var/resource_id in R.resource_costs)
		var/required_amount = R.resource_costs[resource_id]
		resource_stock[resource_id] = get_resource_amount(resource_id) - required_amount
		consume_resource_source_stock(resource_id, required_amount)
	budget -= R.service_fee

	is_crafting = TRUE
	active_recipe_type = recipe_type
	active_recipe_name = R.name
	craft_total_time = R.craft_time
	craft_finish_time = world.time + craft_total_time
	craft_timer_id = addtimer(CALLBACK(src, PROC_REF(complete_craft)), craft_total_time, TIMER_STOPPABLE)

	visible_message(span_notice("[src] begins working. The technician disappears into the workshop."))
	playsound(src, 'sound/misc/beep.ogg', 75, FALSE, -1)
	SStgui.update_uis(src)
	qdel(R)
	return TRUE

/obj/structure/fake_machine/technician_workshop/proc/complete_craft()
	craft_timer_id = null
	if(!is_crafting || !active_recipe_type)
		return

	var/turf/output_turf = get_turf(src)
	var/datum/technician_recipe/R
	var/datum/technician_recipe/completion_recipe_type = active_recipe_type
	if(ispath(completion_recipe_type, /datum/technician_recipe) && !IS_ABSTRACT(completion_recipe_type))
		R = new completion_recipe_type()

	if(output_turf && R && ispath(R.created_item, /obj/item))
		var/output_count = R.output_amount
		for(var/i in 1 to output_count)
			new R.created_item(output_turf)
		visible_message(span_notice("[src] finishes crafting [R.name]. The finished goods are left on the workbench."))
		playsound(src, 'sound/items/bsmith3.ogg', 75, TRUE)
	else
		log_game("Technician workshop at [AREACOORD(src)] could not finish recipe [active_recipe_type]. Check the recipe's output type.")

	if(R)
		qdel(R)

	is_crafting = FALSE
	active_recipe_type = null
	active_recipe_name = null
	craft_finish_time = 0
	craft_total_time = 0
	SStgui.update_uis(src)
