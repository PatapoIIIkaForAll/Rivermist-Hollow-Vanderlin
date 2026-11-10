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
	if(!enterprise.is_manager(user))
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
	if(!user.put_in_hands(bought))
		bought.forceMove(get_turf(user))
	playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	return TRUE
