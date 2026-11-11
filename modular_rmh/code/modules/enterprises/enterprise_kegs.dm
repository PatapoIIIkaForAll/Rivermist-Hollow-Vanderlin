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

/datum/enterprise/proc/describe_keg_store(level, russian)
	var/keg_cap = get_level_value(keg_caps, level) || 0
	var/volume = get_level_entry(drink_caps, level)
	var/slots = get_level_entry(drink_slot_caps, level)
	if(russian)
		return "[keg_cap ? "Пустых бочек на складе: до [keg_cap]." : "Пустые бочки здесь пока не хранят."] Напитки из сданных бочек сливаются в общее хранилище до [volume] ед.: пиво и вино[slots ? ", а ещё до [slots] других напитков" : ""]."
	return "[keg_cap ? "It keeps up to [keg_cap] empty kegs." : "It keeps no empty kegs yet."] Drink from the kegs handed in goes into one store of up to [volume] units: beer and wine[slots ? ", and up to [slots] other drinks" : ""]."

/datum/enterprise_stock
	var/datum/enterprise_keg_store/kegs

/datum/enterprise_keg_store
	var/datum/enterprise_stock/stock
	var/datum/reagents/drinks
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

/datum/enterprise_keg_store/Destroy()
	var/turf/drop = stock?.post ? get_turf(stock.post) : null
	for(var/obj/structure/fermentation_keg/keg as anything in kegs)
		if(QDELETED(keg))
			continue
		if(drop)
			keg.forceMove(drop)
		else
			qdel(keg)
	kegs = null
	QDEL_NULL(drinks)
	stock = null
	return ..()

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

/datum/enterprise_keg_store/proc/is_standard(drink_type)
	var/list/standard = get_standard_types()
	return standard[drink_type] ? TRUE : FALSE

/datum/enterprise_keg_store/proc/get_drink(drink_type)
	for(var/datum/reagent/drink as anything in drinks.reagent_list)
		if(drink.type == drink_type)
			return drink
	return null

/datum/enterprise_keg_store/proc/count_custom()
	var/count = 0
	for(var/datum/reagent/drink as anything in drinks.reagent_list)
		if(!is_standard(drink.type))
			count++
	return count

/datum/enterprise_keg_store/proc/can_hold(drink_type)
	if(is_standard(drink_type) || get_drink(drink_type))
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

/datum/enterprise_keg_store/proc/pour(obj/structure/fermentation_keg/keg)
	var/datum/reagents/source = keg.reagents
	var/brewed_type = (keg.ready_to_bottle && keg.selected_recipe) ? keg.selected_recipe.reagent_to_brew : null
	var/aged_type = brewed_type ? get_aged_type(keg) : null
	drinks.maximum_volume = get_drink_cap()
	var/list/stayed = list()
	for(var/datum/reagent/drink as anything in source.reagent_list)
		var/drink_type = drink.type
		var/drink_name = drink.name
		var/volume = drink.volume
		if(ispath(drink_type, /datum/reagent/water))
			source.remove_reagent(drink_type, volume)
			continue
		var/stored_type = drink_type == brewed_type ? aged_type : drink_type
		var/amount = can_hold(stored_type) ? min(volume, drinks.maximum_volume - drinks.total_volume) : 0
		if(amount > 0)
			drinks.add_reagent(stored_type, amount, copy_drink_data(drink.data))
			source.remove_reagent(drink_type, amount)
		if(amount < volume)
			stayed |= drink_name
	return stayed

/datum/enterprise_keg_store/proc/store(obj/structure/fermentation_keg/keg, mob/living/user)
	var/russian = get_preferred_ui_language(user) == "ru"
	var/datum/enterprise/enterprise = stock.enterprise
	if(!enterprise.is_staff(user))
		to_chat(user, span_warning(russian ? "Сдавать бочки на склад может только персонал." : "Only the staff may hand kegs in to the store."))
		return FALSE
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
	var/list/stayed = pour(keg)
	if(keg.reagents.total_volume > 0)
		keg.update_appearance(UPDATE_OVERLAYS)
		to_chat(user, span_warning(russian ? "В хранилище поместилось не всё, в бочке осталось: [jointext(stayed, ", ")]." : "Not everything fitted into the store; still in the keg: [jointext(stayed, ", ")]."))
	else
		keg.recipe_crop_stocks?.Cut()
		keg.reset_keg()
		if(length(kegs) < get_keg_cap())
			keg.pulledby?.stop_pulling()
			keg.moveToNullspace()
			kegs += keg
			to_chat(user, span_notice(russian ? "Напиток слит в хранилище, пустая бочка убрана на склад." : "The drink is poured into the store, and the empty keg is put away."))
		else if(get_keg_cap())
			to_chat(user, span_notice(russian ? "Напиток слит в хранилище, но для пустой бочки места на складе нет." : "The drink is poured into the store, but there is no room left for the empty keg."))
		else
			to_chat(user, span_notice(russian ? "Напиток слит в хранилище. Пустые бочки здесь хранят с первого уровня склада." : "The drink is poured into the store. Empty kegs are kept here from the store's first level."))
	log_game("[key_name(user)] handed a keg in to the [enterprise.name] drinks store")
	SStgui.update_uis(stock.post)
	return TRUE

/datum/enterprise_keg_store/proc/take_empty(mob/living/user)
	var/russian = get_preferred_ui_language(user) == "ru"
	var/datum/enterprise/enterprise = stock.enterprise
	if(!enterprise.is_staff(user))
		to_chat(user, span_warning(russian ? "Брать бочки со склада может только персонал." : "Only the staff may take kegs from the store."))
		return FALSE
	var/obj/structure/fermentation_keg/keg = pick_keg()
	if(!keg)
		to_chat(user, span_warning(russian ? "На складе нет пустых бочек." : "There are no empty kegs in the store."))
		return FALSE
	kegs -= keg
	keg.forceMove(get_turf(user))
	to_chat(user, span_notice(russian ? "Пустая бочка выкачена со склада." : "An empty keg is rolled out of the store."))
	log_game("[key_name(user)] took an empty keg from the [enterprise.name] drinks store")
	SStgui.update_uis(stock.post)
	return TRUE

/datum/enterprise_keg_store/proc/fill(mob/living/user, drink_type, amount)
	var/russian = get_preferred_ui_language(user) == "ru"
	var/datum/enterprise/enterprise = stock.enterprise
	if(!enterprise.is_staff(user))
		to_chat(user, span_warning(russian ? "Наливать из хранилища может только персонал." : "Only the staff may draw from the store."))
		return FALSE
	if(!get_drink(drink_type) || !isnum(amount) || amount <= 0)
		return FALSE
	var/obj/structure/fermentation_keg/target = get_brought_keg(user)
	if(target && (target.selected_recipe || is_busy(target)))
		to_chat(user, span_warning(russian ? "В эту бочку не налить: в ней варится или уже готов свой напиток." : "This keg cannot be filled: it has a brew of its own."))
		return FALSE
	if(!target && !pick_keg())
		to_chat(user, span_warning(russian ? "Нет бочки: подтащите свою к посту или сдайте пустую на склад." : "There is no keg: bring one up to the post or put an empty one into the store."))
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
	var/datum/reagent/drink = get_drink(drink_type)
	if(!drink)
		return FALSE
	var/poured = min(amount, drink.volume, target.reagents.maximum_volume - target.reagents.total_volume)
	if(poured <= 0)
		to_chat(user, span_warning(russian ? "В этой бочке нет места." : "There is no room left in this keg."))
		return FALSE
	var/drink_name = drink.name
	target.reagents.add_reagent(drink_type, poured, copy_drink_data(drink.data))
	drinks.remove_reagent(drink_type, poured)
	if(from_store)
		kegs -= target
		target.forceMove(get_turf(user))
	target.update_appearance(UPDATE_OVERLAYS)
	var/shown = round(poured, 0.1)
	to_chat(user, span_notice(russian ? "В бочку налито [shown] ед. «[drink_name]»." : "[UNIT_FORM_STRING(shown)] of [drink_name] poured into the keg."))
	log_game("[key_name(user)] drew [shown] of [drink_type] from the [enterprise.name] drinks store")
	SStgui.update_uis(stock.post)
	return TRUE

/datum/enterprise_keg_store/proc/get_data(mob/user)
	prune()
	var/list/drink_rows = list()
	for(var/datum/reagent/drink as anything in drinks.reagent_list)
		drink_rows += list(list(
			"id" = "[drink.type]",
			"name" = drink.name,
			"amount" = round(drink.volume, 0.1),
			"custom" = !is_standard(drink.type),
		))
	return list(
		"stored" = length(kegs),
		"keg_cap" = get_keg_cap(),
		"volume" = round(drinks.total_volume, 0.1),
		"volume_cap" = get_drink_cap(),
		"custom" = count_custom(),
		"custom_cap" = get_slot_cap(),
		"keg_volume" = ENTERPRISE_KEG_VOLUME,
		"can_use" = stock.enterprise.is_staff(user),
		"drinks" = drink_rows,
	)

/datum/enterprise_keg_store/proc/act(action, list/params, mob/living/user)
	if(!(action in list("store_keg", "take_keg", "fill_keg")))
		return FALSE
	if(!stock.enterprise.press(user, action))
		return FALSE
	switch(action)
		if("store_keg")
			return store(get_brought_keg(user), user)
		if("take_keg")
			return take_empty(user)
	var/drink_type = text2path("[params["id"]]")
	var/amount = params["amount"]
	if(istext(amount))
		amount = text2num(amount)
	if(!ispath(drink_type, /datum/reagent) || !isnum(amount))
		return FALSE
	return fill(user, drink_type, round(amount, 0.1))

/obj/structure/fake_machine/enterprise_stock/MouseDrop_T(atom/dropping, mob/living/user)
	if(!stock?.kegs || !istype(dropping, /obj/structure/fermentation_keg) || !istype(user))
		return ..()
	if(stock.enterprise.press(user, "store_keg"))
		stock.kegs.store(dropping, user)
