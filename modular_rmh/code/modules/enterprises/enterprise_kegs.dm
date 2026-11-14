/datum/enterprise
	var/list/keg_caps = list(1, 3, 5, 10)
	var/list/drink_caps = list(200, 500, 1000, 2000, 5000)
	var/list/drink_slot_caps = list(0, 2, 4, 8, 16)

/datum/enterprise/proc/get_level_entry(list/table, level)
	return table[clamp(level + 1, 1, length(table))]

/datum/enterprise/proc/is_kept(obj/thing)
	for(var/datum/enterprise_room/room as anything in rooms)
		var/datum/enterprise_keg_store/store = room.stock?.kegs
		if(store && (thing in store.kegs))
			return TRUE
	return FALSE

/proc/enterprise_mark_reagent(datum/reagent/drink)
	if(isnull(drink.data))
		drink.data = list()
	if(islist(drink.data))
		drink.data[ENTERPRISE_STOCK_DATA] = TRUE

/proc/enterprise_is_house_reagent(datum/reagent/drink)
	return islist(drink?.data) && drink.data[ENTERPRISE_STOCK_DATA]

/proc/enterprise_mark_house_reagents(datum/reagents/holder, list/drink_types)
	for(var/datum/reagent/drink as anything in holder?.reagent_list)
		if(drink.type in drink_types)
			enterprise_mark_reagent(drink)

/datum/reagent/consumable/ethanol/age_beer()
	var/datum/reagents/aging_in = holder
	var/aged_type = age_path
	var/house = enterprise_is_house_reagent(src)
	. = ..()
	if(house && aging_in && aged_type)
		enterprise_mark_house_reagents(aging_in, list(aged_type))

/obj/structure/fermentation_keg/proc/get_house_brew_types()
	if(!selected_recipe)
		return null
	if(!enterprise_is_house_reagent(reagents.get_reagent(selected_recipe.reagent_to_brew)))
		return null
	return list(selected_recipe.reagent_to_brew) + selected_recipe.age_times

/obj/structure/fermentation_keg/try_filling(mob/user, obj/item/reagent_containers/container)
	var/list/house_types = get_house_brew_types()
	. = ..()
	if(length(house_types))
		enterprise_mark_house_reagents(container?.reagents, house_types)

/obj/structure/fermentation_keg/MouseDrop_T(atom/over, mob/living/user)
	var/obj/structure/fermentation_keg/origin = over
	var/list/house_types = istype(origin) ? origin.get_house_brew_types() : null
	. = ..()
	if(length(house_types))
		enterprise_mark_house_reagents(reagents, house_types)

/datum/enterprise/proc/mark_house_drink(obj/thing)
	if(!thing.reagents || istype(thing, /obj/item/reagent_containers/food))
		return
	for(var/datum/reagent/drink as anything in thing.reagents.reagent_list)
		enterprise_mark_reagent(drink)

/datum/enterprise/proc/stock_house_water(owner_level)
	if(owner_level < ENTERPRISE_HOUSE_WATER_LEVEL)
		return FALSE
	var/stocked = FALSE
	for(var/datum/enterprise_room/room as anything in rooms)
		var/datum/enterprise_keg_store/store = room.stock?.kegs
		if(!store)
			continue
		store.water.add_reagent(/datum/reagent/water, store.water.maximum_volume - store.water.total_volume)
		SStgui.update_uis(store.stock.post)
		stocked = TRUE
	return stocked

/datum/enterprise/proc/describe_keg_store(level, russian)
	var/keg_cap = get_level_value(keg_caps, level) || 0
	var/volume = get_level_entry(drink_caps, level)
	var/slots = get_level_entry(drink_slot_caps, level)
	if(russian)
		return "Алкоголь, слитый сюда, оплачивает город, а выкупает его только персонал, за [ENTERPRISE_BUYOUT_PERCENT]% цены из книги таверны. Хранилище держит до [volume] ед.: пиво и вино[slots ? ", а ещё до [slots] других напитков" : ""]; воды — до [ENTERPRISE_WATER_CAP] ед., она бесплатна. [keg_cap ? "Пустых бочек на складе: до [keg_cap]." : "Пустые бочки здесь пока не хранят."]"
	return "Alcohol poured in here is paid for by the town, and only the staff buy it out, at [ENTERPRISE_BUYOUT_PERCENT]% of the price, from the house's book. The store holds up to [volume] units: beer and wine[slots ? ", and up to [slots] other drinks" : ""]; water up to [ENTERPRISE_WATER_CAP] units, free. [keg_cap ? "It keeps up to [keg_cap] empty kegs." : "It keeps no empty kegs yet."]"

/datum/enterprise_stock
	var/datum/enterprise_keg_store/kegs

/datum/enterprise_keg_store
	var/datum/enterprise_stock/stock
	var/datum/reagents/drinks
	var/datum/reagents/water
	var/list/obj/structure/fermentation_keg/kegs = list()
	var/list/standard_drinks = list(
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/ale,
		/datum/reagent/consumable/ethanol/wine,
		/datum/reagent/consumable/ethanol/redwine,
		/datum/reagent/consumable/ethanol/whitewine,
	)
	var/list/standard_recipes = list(
		/datum/brewing_recipe/beer,
		/datum/brewing_recipe/wine,
	)
	var/list/standard_types

/datum/enterprise_keg_store/New(datum/enterprise_stock/stock)
	src.stock = stock
	drinks = new(get_drink_cap(), NO_REACT)
	water = new(ENTERPRISE_WATER_CAP, NO_REACT)

/datum/enterprise_keg_store/Destroy()
	drop_kegs(stock?.post ? get_turf(stock.post) : null)
	kegs = null
	QDEL_NULL(drinks)
	QDEL_NULL(water)
	stock = null
	return ..()

/datum/enterprise_keg_store/proc/drop_kegs(turf/drop)
	for(var/obj/structure/fermentation_keg/keg as anything in kegs)
		if(QDELETED(keg))
			continue
		if(drop)
			keg.forceMove(drop)
		else
			qdel(keg)
	kegs.Cut()

/datum/enterprise_keg_store/proc/get_level()
	return stock.storage ? stock.storage.level : ENTERPRISE_LEVEL_BARE

/datum/enterprise_keg_store/proc/get_keg_cap()
	return stock.enterprise.get_level_value(stock.enterprise.keg_caps, get_level()) || 0

/datum/enterprise_keg_store/proc/get_drink_cap()
	return stock.enterprise.get_level_entry(stock.enterprise.drink_caps, get_level())

/datum/enterprise_keg_store/proc/get_slot_cap()
	return stock.enterprise.get_level_entry(stock.enterprise.drink_slot_caps, get_level())

/datum/enterprise_keg_store/proc/get_standard_types()
	if(standard_types)
		return standard_types
	standard_types = list()
	var/list/found = standard_drinks.Copy()
	for(var/family in standard_recipes)
		for(var/datum/brewing_recipe/recipe_type as anything in typesof(family))
			if(IS_ABSTRACT(recipe_type))
				continue
			var/datum/brewing_recipe/recipe = new recipe_type
			found += recipe.reagent_to_brew
			for(var/aged in recipe.age_times)
				found += aged
			qdel(recipe)
	while(length(found))
		var/datum/reagent/consumable/ethanol/drink = found[length(found)]
		found.len--
		if(!drink || standard_types[drink])
			continue
		standard_types[drink] = TRUE
		if(ispath(drink, /datum/reagent/consumable/ethanol))
			found += initial(drink.age_path)
	return standard_types

/proc/enterprise_drink_entries()
	var/static/list/entries
	if(entries)
		return entries
	entries = list()
	for(var/pack_type in SSmerchant.supply_packs)
		var/datum/supply_pack/pack = SSmerchant.supply_packs[pack_type]
		var/bottle_type = pack.contains
		if(islist(bottle_type))
			var/list/contents = bottle_type
			bottle_type = length(contents) == 1 ? contents[1] : null
		if(pack.cost <= 0 || !ispath(bottle_type, /obj/item/reagent_containers))
			continue
		var/obj/item/reagent_containers/bottle = new bottle_type
		var/list/bottled = bottle.reagents?.reagent_list
		if(length(bottled) == 1)
			var/datum/reagent/drink = bottled[1]
			if(drink.volume > 0)
				entries += list(list(drink.type, pack.cost / drink.volume, list(drink.type)))
		qdel(bottle)
	for(var/datum/brewing_recipe/recipe_type as anything in subtypesof(/datum/brewing_recipe))
		if(IS_ABSTRACT(recipe_type))
			continue
		var/datum/brewing_recipe/recipe = new recipe_type
		var/units = recipe.brewed_amount * recipe.per_brew_amount
		if(!recipe.brewed_item)
			var/price = (recipe.sell_value > 0 && units > 0) ? recipe.sell_value / units : 0
			var/list/products = list(recipe.reagent_to_brew) + recipe.age_times
			for(var/index in 1 to length(products))
				entries += list(list(products[index], price, products.Copy(index)))
		qdel(recipe)
	return entries

/proc/enterprise_drink_unit_price(drink_type)
	var/static/list/unit_prices
	if(!ispath(drink_type, /datum/reagent/consumable/ethanol))
		return 0
	if(!unit_prices)
		unit_prices = list()
		for(var/list/entry as anything in enterprise_drink_entries())
			if(entry[2] > 0 && isnull(unit_prices[entry[1]]))
				unit_prices[entry[1]] = entry[2]
	if(!isnull(unit_prices[drink_type]))
		return unit_prices[drink_type]
	var/datum/reagent/drink = GLOB.chemical_reagents_list[drink_type]
	return drink ? max(drink.price_per_unit, 0) : 0

/datum/enterprise_keg_store/proc/get_unit_price(drink_type)
	return enterprise_drink_unit_price(drink_type)

/datum/enterprise_keg_store/proc/get_draw_cost(drink_type, amount)
	var/price = get_unit_price(drink_type)
	if(price <= 0 || amount <= 0)
		return 0
	return max(-round(-(amount * price * ENTERPRISE_BUYOUT_PERCENT / 100 - 0.01)), 0)

/datum/enterprise_keg_store/proc/can_afford(mob/user, cost)
	var/datum/enterprise/enterprise = stock.enterprise
	if(cost <= 0)
		return TRUE
	return enterprise.can_pay(user, cost)

/datum/enterprise_keg_store/proc/charge(mob/user, cost)
	var/datum/enterprise/enterprise = stock.enterprise
	if(cost <= 0)
		return TRUE
	return enterprise.pay(user, cost, "[enterprise.name] drinks", FALSE)

/datum/enterprise_keg_store/proc/refresh(money_moved)
	if(money_moved)
		stock.enterprise.funds_changed()
	else
		SStgui.update_uis(stock.post)

/datum/enterprise_keg_store/proc/pay_out(mob/user, value)
	if(value <= 0)
		return
	if(!SStreasury.give_money_account(value, user, "[stock.enterprise.name] drinks"))
		stock.post?.budget2change(value, user)

/datum/enterprise_keg_store/proc/is_standard(drink_type)
	var/list/standard = get_standard_types()
	return standard[drink_type] ? TRUE : FALSE

/datum/enterprise_keg_store/proc/get_reagent_in(datum/reagents/holder, drink_type)
	for(var/datum/reagent/drink as anything in holder.reagent_list)
		if(drink.type == drink_type)
			return drink
	return null

/datum/enterprise_keg_store/proc/get_drink(drink_type)
	return get_reagent_in(drink_type == /datum/reagent/water ? water : drinks, drink_type)

/datum/enterprise_keg_store/proc/count_custom()
	var/count = 0
	for(var/datum/reagent/drink as anything in drinks.reagent_list)
		if(!is_standard(drink.type))
			count++
	return count

/datum/enterprise_keg_store/proc/can_hold(drink_type)
	if(is_standard(drink_type) || get_reagent_in(drinks, drink_type))
		return TRUE
	return count_custom() < get_slot_cap()

/datum/enterprise_keg_store/proc/copy_drink_data(data)
	if(!islist(data))
		return data
	var/list/copied = data
	return copied.Copy()

/datum/enterprise_keg_store/proc/is_at_post(obj/structure/fermentation_keg/keg)
	var/obj/structure/fake_machine/enterprise_stock/post = stock.post
	return istype(keg) && !QDELETED(keg) && isturf(keg.loc) && post && keg.Adjacent(post)

/datum/enterprise_keg_store/proc/is_busy(obj/structure/fermentation_keg/keg)
	if(keg.anchored || keg.brewing)
		return TRUE
	return keg.selected_recipe && (!keg.ready_to_bottle || keg.selected_recipe.brewed_item)

/datum/enterprise_keg_store/proc/get_brought_keg(mob/living/user)
	var/obj/structure/fermentation_keg/keg = user.pulling
	return is_at_post(keg) ? keg : null

/datum/enterprise_keg_store/proc/pick_keg()
	for(var/index in length(kegs) to 1 step -1)
		var/obj/structure/fermentation_keg/keg = kegs[index]
		if(QDELETED(keg))
			kegs.Cut(index, index + 1)
			continue
		if(!stock.enterprise.is_bound(keg))
			return keg
	return length(kegs) ? kegs[length(kegs)] : null

/datum/enterprise_keg_store/proc/prune()
	for(var/index in length(kegs) to 1 step -1)
		if(QDELETED(kegs[index]))
			kegs.Cut(index, index + 1)

/datum/enterprise_keg_store/proc/get_aged_type(obj/structure/fermentation_keg/keg)
	var/datum/brewing_recipe/recipe = keg.selected_recipe
	var/aged = recipe.reagent_to_brew
	var/time = world.time - keg.age_start_time
	var/oldest = 0
	for(var/path in recipe.age_times)
		if(time > recipe.age_times[path] && recipe.age_times[path] >= oldest)
			aged = path
			oldest = recipe.age_times[path]
	return aged

/datum/enterprise_keg_store/proc/pour(datum/reagents/source, list/stayed, list/refused, drain_water, brewed_type, aged_type)
	drinks.maximum_volume = get_drink_cap()
	var/value = 0
	for(var/datum/reagent/drink as anything in source.reagent_list)
		var/drink_type = drink.type
		var/drink_name = drink.name
		var/volume = drink.volume
		var/list/data = drink.data
		if(enterprise_is_house_reagent(drink))
			refused |= drink_name
			continue
		if(drink_type == /datum/reagent/water)
			var/kept_water = max(min(volume, water.maximum_volume - water.total_volume), 0)
			if(kept_water > 0)
				water.add_reagent(drink_type, kept_water)
			var/removed = drain_water ? volume : kept_water
			if(removed > 0)
				source.remove_reagent(drink_type, removed)
			if(removed < volume)
				stayed |= drink_name
			continue
		var/stored_type = drink_type == brewed_type ? aged_type : drink_type
		var/amount = can_hold(stored_type) ? min(volume, drinks.maximum_volume - drinks.total_volume) : 0
		if(amount > 0)
			drinks.add_reagent(stored_type, amount, copy_drink_data(data))
			source.remove_reagent(drink_type, amount)
			value += amount * get_unit_price(stored_type)
		if(amount < volume)
			stayed |= drink_name
	return round(value)

/datum/enterprise_keg_store/proc/report_pour(mob/user, value, list/stayed, list/refused, obj/structure/fermentation_keg/keg)
	var/russian = get_preferred_ui_language(user) == "ru"
	var/list/lines = list()
	if(value > 0)
		lines += russian ? "Город заплатил за напиток [value]." : "The town has paid [value] for the drink."
	if(length(refused))
		lines += russian ? "Не принято, это запасы самого заведения: [jointext(refused, ", ")]." : "Not taken, it is the house's own stock: [jointext(refused, ", ")]."
	if(length(stayed))
		lines += russian ? "Не поместилось в хранилище: [jointext(stayed, ", ")]." : "No room in the store for: [jointext(stayed, ", ")]."
	if(keg && !keg.loc)
		lines += russian ? "Пустая бочка убрана на склад." : "The empty keg is put away."
	else if(keg && !keg.reagents.total_volume)
		if(get_keg_cap())
			lines += russian ? "Для пустой бочки места на складе нет." : "There is no room left for the empty keg."
		else
			lines += russian ? "Пустые бочки здесь хранят с первого уровня склада." : "Empty kegs are kept here from the store's first level."
	if(!length(lines))
		lines += russian ? "Напиток слит в хранилище." : "The drink is poured into the store."
	to_chat(user, span_notice(jointext(lines, " ")))

/datum/enterprise_keg_store/proc/store(obj/structure/fermentation_keg/keg, mob/living/user)
	var/russian = get_preferred_ui_language(user) == "ru"
	if(!is_at_post(keg))
		to_chat(user, span_warning(russian ? "Подтащите бочку к посту: она должна стоять рядом с ним." : "Bring a keg up to the post: it has to stand right by it."))
		return FALSE
	if(is_busy(keg))
		to_chat(user, span_warning(russian ? "В этой бочке что-то бродит, ждёт заготовка или лежит готовый продукт: такую не сдать." : "Something is brewing, waiting to brew or ready to be taken out of this keg: it cannot be handed in."))
		return FALSE
	if(!do_after(user, ENTERPRISE_KEG_POUR_TIME, keg))
		return FALSE
	if(QDELETED(src) || !stock || !is_at_post(keg) || is_busy(keg))
		return FALSE
	var/brewed_type = (keg.ready_to_bottle && keg.selected_recipe) ? keg.selected_recipe.reagent_to_brew : null
	var/list/stayed = list()
	var/list/refused = list()
	var/volume_before = keg.reagents.total_volume
	var/value = pour(keg.reagents, stayed, refused, TRUE, brewed_type, brewed_type ? get_aged_type(keg) : null)
	pay_out(user, value)
	if(keg.selected_recipe && keg.reagents.total_volume < volume_before)
		keg.sellprice = initial(keg.sellprice)
	if(keg.reagents.total_volume > 0)
		keg.update_appearance(UPDATE_OVERLAYS)
	else
		keg.recipe_crop_stocks?.Cut()
		keg.reset_keg()
		if(length(kegs) < get_keg_cap())
			keg.pulledby?.stop_pulling()
			keg.moveToNullspace()
			kegs += keg
	report_pour(user, value, stayed, refused, keg)
	log_game("[key_name(user)] handed a keg in to the [stock.enterprise.name] drinks store and was paid [value]")
	refresh(value > 0)
	return TRUE

/datum/enterprise_keg_store/proc/pour_item(obj/item/reagent_containers/tool, mob/living/user)
	var/russian = get_preferred_ui_language(user) == "ru"
	if(!tool.reagents?.total_volume)
		to_chat(user, span_warning(russian ? "Здесь пусто: сливать нечего." : "It is empty: there is nothing to pour."))
		return FALSE
	var/before = tool.reagents.total_volume
	var/list/stayed = list()
	var/list/refused = list()
	var/value = pour(tool.reagents, stayed, refused, FALSE)
	pay_out(user, value)
	report_pour(user, value, stayed, refused)
	if(tool.reagents.total_volume >= before)
		return FALSE
	log_game("[key_name(user)] poured [tool] into the [stock.enterprise.name] drinks store and was paid [value]")
	refresh(value > 0)
	return TRUE

/datum/enterprise_keg_store/proc/take_empty(mob/living/user)
	var/russian = get_preferred_ui_language(user) == "ru"
	var/obj/structure/fermentation_keg/keg = pick_keg()
	if(!keg)
		to_chat(user, span_warning(russian ? "На складе нет пустых бочек." : "There are no empty kegs in the store."))
		return FALSE
	kegs -= keg
	keg.forceMove(get_turf(user))
	to_chat(user, span_notice(russian ? "Пустая бочка выкачена со склада." : "An empty keg is rolled out of the store."))
	log_game("[key_name(user)] took an empty keg from the [stock.enterprise.name] drinks store")
	refresh(FALSE)
	return TRUE

/datum/enterprise_keg_store/proc/fill(mob/living/user, drink_type, amount)
	var/russian = get_preferred_ui_language(user) == "ru"
	var/datum/enterprise/enterprise = stock.enterprise
	var/datum/reagents/source = drink_type == /datum/reagent/water ? water : drinks
	var/datum/reagent/drink = get_reagent_in(source, drink_type)
	if(!drink || !isnum(amount) || amount <= 0)
		return FALSE
	if(source == drinks && !enterprise.is_staff(user))
		to_chat(user, span_warning(russian ? "Выкупать напитки может только персонал таверны; воду берёт кто угодно." : "Only the tavern staff may buy drink out; anyone may draw water."))
		return FALSE
	var/obj/structure/fermentation_keg/target = get_brought_keg(user)
	if(target && (target.selected_recipe || is_busy(target)))
		to_chat(user, span_warning(russian ? "В эту бочку не налить: в ней варится или уже готов свой напиток." : "This keg cannot be filled: it has a brew of its own."))
		return FALSE
	if(!target && !pick_keg())
		to_chat(user, span_warning(russian ? "Нет бочки: подтащите свою к посту или сдайте пустую на склад." : "There is no keg: bring one up to the post or put an empty one into the store."))
		return FALSE
	var/cost = get_draw_cost(drink_type, min(amount, drink.volume))
	if(!can_afford(user, cost))
		to_chat(user, span_warning(russian ? "Не хватает денег: нужно [cost]." : "There is not enough money: it takes [cost]."))
		return FALSE
	if(!do_after(user, ENTERPRISE_KEG_POUR_TIME, target || stock.post))
		return FALSE
	if(QDELETED(src) || !stock)
		return FALSE
	var/from_store = !target
	if(target)
		if(get_brought_keg(user) != target || target.selected_recipe || is_busy(target))
			return FALSE
	else
		target = pick_keg()
		if(!target)
			return FALSE
	drink = get_reagent_in(source, drink_type)
	if(!drink)
		return FALSE
	var/poured = min(amount, drink.volume, target.reagents.maximum_volume - target.reagents.total_volume)
	if(poured <= 0)
		to_chat(user, span_warning(russian ? "В этой бочке нет места." : "There is no room left in this keg."))
		return FALSE
	var/price = get_unit_price(drink_type)
	cost = get_draw_cost(drink_type, poured)
	if(!charge(user, cost))
		to_chat(user, span_warning(russian ? "Не хватает денег: нужно [cost]." : "There is not enough money: it takes [cost]."))
		return FALSE
	var/drink_name = drink.name
	var/list/data = copy_drink_data(drink.data)
	if(price > 0)
		if(isnull(data))
			data = list()
		if(islist(data))
			data[ENTERPRISE_STOCK_DATA] = TRUE
	target.reagents.add_reagent(drink_type, poured, data)
	source.remove_reagent(drink_type, poured)
	if(from_store)
		kegs -= target
		target.forceMove(get_turf(user))
	target.update_appearance(UPDATE_OVERLAYS)
	var/town_paid = round(poured * price)
	if(cost && town_paid > cost)
		SStreasury.log_to_steward("-[town_paid - cost] from treasury ([enterprise.name] drinks)")
	var/shown = round(poured, 0.1)
	if(russian)
		to_chat(user, span_notice("В бочку налито [shown] ед. «[drink_name]»[cost ? ", заплачено [cost]" : ""]."))
	else
		to_chat(user, span_notice("[UNIT_FORM_STRING(shown)] of [drink_name] poured into the keg[cost ? " for [cost]" : ""]."))
	log_game("[key_name(user)] drew [shown] of [drink_type] from the [enterprise.name] drinks store for [cost]")
	refresh(cost > 0)
	return TRUE

/datum/enterprise_keg_store/proc/get_data(mob/user)
	prune()
	var/datum/enterprise/enterprise = stock.enterprise
	var/list/drink_rows = list()
	for(var/datum/reagent/drink as anything in drinks.reagent_list)
		drink_rows += list(list(
			"id" = "[drink.type]",
			"name" = drink.name,
			"amount" = round(drink.volume, 0.1),
			"custom" = !is_standard(drink.type),
			"price" = get_unit_price(drink.type),
		))
	return list(
		"stored" = length(kegs),
		"keg_cap" = get_keg_cap(),
		"volume" = round(drinks.total_volume, 0.1),
		"volume_cap" = get_drink_cap(),
		"custom" = count_custom(),
		"custom_cap" = get_slot_cap(),
		"water" = round(water.total_volume, 0.1),
		"water_cap" = water.maximum_volume,
		"water_id" = "[/datum/reagent/water]",
		"keg_volume" = ENTERPRISE_KEG_VOLUME,
		"share" = ENTERPRISE_BUYOUT_PERCENT,
		"staff" = enterprise.is_staff(user),
		"funds" = enterprise.is_staff(user) ? enterprise.book_balance + enterprise.get_bank_balance(user) : enterprise.get_bank_balance(user),
		"drinks" = drink_rows,
	)

/datum/enterprise_keg_store/proc/act(action, list/params, mob/living/user)
	if(!(action in list("store_keg", "take_keg", "fill_keg")))
		return FALSE
	if(!stock.enterprise.press(user, action))
		return FALSE
	switch(action)
		if("store_keg")
			store(get_brought_keg(user), user)
			return FALSE
		if("take_keg")
			take_empty(user)
			return FALSE
	var/drink_type = text2path("[params["id"]]")
	var/amount = params["amount"]
	if(istext(amount))
		amount = text2num(amount)
	if(!ispath(drink_type, /datum/reagent) || !isnum(amount))
		return FALSE
	fill(user, drink_type, round(amount, 0.1))
	return FALSE

/obj/structure/fake_machine/enterprise_stock/MouseDrop_T(atom/dropping, mob/living/user)
	if(!stock?.kegs || !istype(dropping, /obj/structure/fermentation_keg) || !istype(user))
		return ..()
	if(stock.enterprise.press(user, "store_keg"))
		stock.kegs.store(dropping, user)
