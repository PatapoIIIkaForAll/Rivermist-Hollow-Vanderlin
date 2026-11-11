/datum/enterprise
	var/book_balance = 0
	var/earned_round = 0
	var/earned_today = 0

/datum/enterprise/proc/get_bank_balance(mob/user)
	return (user && (user in SStreasury.bank_accounts)) ? SStreasury.bank_accounts[user] : 0

/datum/enterprise/proc/earn(amount)
	amount = round(amount)
	if(amount <= 0)
		return FALSE
	book_balance += amount
	earned_round += amount
	earned_today += amount
	write_journal()
	funds_changed()
	return TRUE

/datum/enterprise/proc/funds_changed()
	SStgui.update_uis(src)
	for(var/datum/enterprise_room/room as anything in rooms)
		SStgui.update_uis(room)
		if(room.stock?.post)
			SStgui.update_uis(room.stock.post)

/datum/enterprise/proc/can_pay(mob/user, cost)
	return book_balance + get_bank_balance(user) >= cost

/datum/enterprise/proc/pay(mob/user, cost, reason)
	cost = round(cost)
	if(cost <= 0)
		return TRUE
	if(!can_pay(user, cost))
		return FALSE
	var/from_book = min(book_balance, cost)
	var/from_bank = cost - from_book
	book_balance -= from_book
	if(from_bank)
		SStreasury.bank_accounts[user] -= from_bank
		SStreasury.log_to_steward("-[from_bank] from [user.real_name] ([reason])")
	funds_changed()
	return TRUE

/datum/enterprise/proc/take_from_account(mob/payer, cost)
	cost = round(cost)
	if(cost <= 0)
		return TRUE
	if(get_bank_balance(payer) < cost)
		return FALSE
	SStreasury.bank_accounts[payer] -= cost
	return TRUE

/datum/enterprise/proc/new_day(forced)
	earned_today = 0
	rested_today = list()
	start_guest_day(forced)
	SStgui.update_uis(src)

#define ENTERPRISE_SAVE_NAME "enterprises"

/datum/enterprise
	var/owner_ckey
	var/datum/weakref/owner_ref
	var/owner_level = 0
	var/owner_earned = 0
	var/list/owner_grades = list()
	var/list/spent_grades = list()
	var/list/welcomed = list()
	var/journal_age = 20 MINUTES
	var/journal_pending = FALSE

/datum/enterprise/proc/get_prestige_level(earned)
	var/level = 0
	for(var/threshold in prestige_thresholds)
		if(earned < threshold)
			break
		level++
	return level

/datum/enterprise/proc/load_prestige(ckey)
	var/datum/save_manager/manager = get_save_manager(ckey)
	if(!manager)
		return list("earned" = 0, "grades" = list())
	var/list/grades = manager.get_data(ENTERPRISE_SAVE_NAME, "[name]_grades", null)
	return list(
		"earned" = manager.get_data(ENTERPRISE_SAVE_NAME, "[name]_earned", 0),
		"grades" = islist(grades) ? grades.Copy() : list(),
	)

/datum/enterprise/proc/save_prestige(ckey, earned, list/grades)
	var/datum/save_manager/manager = get_save_manager(ckey)
	if(!manager)
		return FALSE
	manager.set_data(ENTERPRISE_SAVE_NAME, "[name]_earned", earned)
	manager.set_data(ENTERPRISE_SAVE_NAME, "[name]_grades", grades.Copy())
	return TRUE

/datum/enterprise/proc/get_journal_path()
	return "data/enterprises/[name]_journal.json"

/datum/enterprise/proc/write_journal()
	if(!owner_ckey || earned_round <= 0)
		return FALSE
	if(world.time < journal_age)
		journal_pending = TRUE
		return FALSE
	journal_pending = FALSE
	var/path = get_journal_path()
	fdel(path)
	text2file(json_encode(list("ckey" = owner_ckey, "earned" = earned_round)), path)
	return TRUE

/datum/enterprise/proc/recover_journal()
	var/path = get_journal_path()
	if(!fexists(path))
		return FALSE
	var/list/journal = safe_json_decode(file2text(path))
	fdel(path)
	if(!islist(journal))
		return FALSE
	var/ckey = journal["ckey"]
	var/earned = journal["earned"]
	if(!istext(ckey) || !isnum(earned) || earned <= 0)
		return FALSE
	var/list/saved = load_prestige(ckey)
	save_prestige(ckey, saved["earned"] + earned, saved["grades"])
	return TRUE

/datum/enterprise/proc/get_owner()
	var/mob/living/found = owner_ref?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise/proc/welcome_owner(mob/living/carbon/human/owner, ckey)
	if(!ckey)
		return FALSE
	if(owner_ckey && owner_ckey != ckey && !bank_experience())
		earned_round = 0
	owner_ckey = ckey
	owner_ref = WEAKREF(owner)
	var/list/saved = load_prestige(ckey)
	owner_earned = saved["earned"]
	owner_grades = saved["grades"]
	owner_level = get_prestige_level(owner_earned)
	place_ledger()
	if(!welcomed[ckey])
		welcomed[ckey] = TRUE
		if(grant_owner_rooms(owner_level))
			redraw()
			var/russian = get_preferred_ui_language(owner) == "ru"
			to_chat(owner, span_notice(russian ? "Заведение обставлено под мой уровень владельца: [owner_level]." : "The house is furnished as my owner level has earned it: [owner_level]."))
	write_journal()
	SStgui.update_uis(src)
	return TRUE

/datum/enterprise/proc/save_grade(level)
	if(!owner_ckey || level > owner_level || (level in owner_grades))
		return FALSE
	owner_grades += level
	spent_grades += level
	save_prestige(owner_ckey, owner_earned, owner_grades)
	return TRUE

/datum/enterprise/proc/can_spend_grade(level)
	return (level in owner_grades) && !(level in spent_grades)

/datum/enterprise/proc/spend_grade(level)
	if(!can_spend_grade(level))
		return FALSE
	spent_grades += level
	return TRUE

/datum/enterprise/proc/bank_experience()
	if(!owner_ckey || earned_round <= 0 || world.time < journal_age)
		return FALSE
	var/list/saved = load_prestige(owner_ckey)
	owner_earned = saved["earned"] + earned_round
	earned_round = 0
	journal_pending = FALSE
	save_prestige(owner_ckey, owner_earned, owner_grades)
	fdel(get_journal_path())
	return TRUE

/datum/enterprise/proc/get_prestige_data()
	var/list/grades = list()
	for(var/level in 2 to ENTERPRISE_MAX_LEVEL)
		grades += list(list(
			"level" = level,
			"unlocked" = owner_level >= level,
			"saved" = (level in owner_grades),
			"spent" = (level in spent_grades),
		))
	return list(
		"level" = owner_level,
		"max_level" = length(prestige_thresholds),
		"earned" = owner_earned,
		"next" = get_level_value(prestige_thresholds, owner_level + 1),
		"grades" = grades,
	)

#undef ENTERPRISE_SAVE_NAME

/datum/enterprise_stock_entry
	var/item_type
	var/name
	var/amount = 0
	var/price = 0

/datum/enterprise_stock
	var/datum/enterprise/enterprise
	var/datum/enterprise_room/storage
	var/obj/structure/fake_machine/enterprise_stock/post
	var/list/goods
	var/list/datum/enterprise_stock_entry/entries = list()

/datum/enterprise_stock/New(datum/enterprise/enterprise, datum/enterprise_room/storage, list/goods)
	src.enterprise = enterprise
	src.storage = storage
	src.goods = goods

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

/datum/enterprise_stock/proc/get_price(obj/item/offered)
	if(HAS_TRAIT(offered, TRAIT_ENTERPRISE_START_STOCK) || !is_type_in_list(offered, goods))
		return 0
	var/own_price = round(offered.get_real_price())
	if(own_price > 0)
		return own_price
	for(var/datum/stock/town_stock as anything in SStreasury.stockpile_datums)
		if(town_stock.item_type == offered.type)
			return town_stock.withdraw_price
	return 0

/datum/enterprise_stock/proc/can_take(obj/item/offered)
	if(!get_price(offered))
		return FALSE
	var/datum/enterprise_stock_entry/entry = entries[offered.type]
	return !entry || entry.amount < get_cap()

/datum/enterprise_stock/proc/take(obj/item/offered)
	var/price = get_price(offered)
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

/obj/structure/fake_machine/enterprise_stock
	name = "buying post"
	desc = "Goods are bought here. What is taken is paid for on the spot."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "submit"
	density = FALSE
	var/datum/enterprise_stock/stock

/obj/structure/fake_machine/enterprise_stock/Destroy()
	if(stock)
		stock.post = null
		stock = null
	return ..()

/obj/structure/fake_machine/enterprise_stock/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!stock || istype(tool, /obj/item/coin))
		return NONE
	var/russian = get_preferred_ui_language(user) == "ru"
	if(HAS_TRAIT(tool, TRAIT_ENTERPRISE_START_STOCK))
		to_chat(user, span_warning(russian ? "Это уже из запасов самого заведения: такое здесь не принимают." : "This already belongs to the house's own stock: it is not taken here."))
		return ITEM_INTERACT_BLOCKING
	if(!stock.get_price(tool))
		to_chat(user, span_warning(russian ? "Такое здесь не покупают." : "They do not buy that here."))
		return ITEM_INTERACT_BLOCKING
	if(!stock.can_take(tool))
		to_chat(user, span_warning(russian ? "Этого здесь уже достаточно." : "They have enough of that here."))
		return ITEM_INTERACT_BLOCKING
	var/price = stock.take(tool)
	if(!price)
		return ITEM_INTERACT_BLOCKING
	qdel(tool)
	if(!SStreasury.give_money_account(price, user, "[stock.enterprise.name] purchase"))
		budget2change(price, user)
	playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	to_chat(user, span_notice(russian ? "Принято. Мне заплатили [price]." : "Taken. I have been paid [price]."))
	SStgui.update_uis(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/fake_machine/enterprise_stock/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user) || !stock)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	ui_interact(user)

/obj/structure/fake_machine/enterprise_stock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, get_preferred_ui_language(user) == "ru" ? "EnterpriseStockRu" : "EnterpriseStock")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/fake_machine/enterprise_stock/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/fake_machine/enterprise_stock/ui_data(mob/user)
	var/datum/enterprise/enterprise = stock.enterprise
	return list(
		"enterprise" = enterprise.name,
		"level" = stock.storage ? stock.storage.level : ENTERPRISE_LEVEL_BARE,
		"cap" = stock.get_cap(),
		"can_buy" = enterprise.is_manager(user),
		"funds" = enterprise.book_balance + enterprise.get_bank_balance(user),
		"entries" = stock.get_entries_data(),
	)

/obj/structure/fake_machine/enterprise_stock/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action != "buy" || !stock)
		return FALSE
	var/mob/user = ui.user
	var/datum/enterprise/enterprise = stock.enterprise
	if(!enterprise.is_manager(user) || !enterprise.press(user, action))
		return FALSE
	var/item_type = text2path(params["id"])
	var/datum/enterprise_stock_entry/entry = item_type ? stock.entries[item_type] : null
	if(!entry || entry.amount < 1)
		return FALSE
	var/russian = get_preferred_ui_language(user) == "ru"
	var/cost = stock.get_buyout_price(entry)
	if(!enterprise.pay(user, cost, "[enterprise.name] stock"))
		to_chat(user, span_warning(russian ? "Денег не хватает: нужно [cost]." : "There is not enough money: it takes [cost]."))
		return FALSE
	stock.give(item_type)
	SStreasury.log_to_steward("-[entry.price - cost] from treasury ([enterprise.name] purchase)")
	var/obj/item/bought = new item_type(get_turf(user))
	ADD_TRAIT(bought, TRAIT_ENTERPRISE_START_STOCK, REF(src))
	if(!user.put_in_hands(bought))
		bought.forceMove(get_turf(user))
	playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	return TRUE
