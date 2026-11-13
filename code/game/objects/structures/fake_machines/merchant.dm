//RMH EDITED START
// Ported & adapted from Azure (Twilight-Axis) "navigator" into Vanderlin's
// /obj/item/fake_machine/merchant beacon. Simplified: no market-saturation
// mechanics (Vanderlin has none). Every cycle the beacon airlifts goods dropped
// on the 8 surrounding pads, splits the value into a 50% merchant-guild levy
// (paid into the merchant's GOLDFACE budget) and the Lord's export tax (paid
// into the realm treasury), then drops the remainder to the seller as coins.

/// Max number of recent sales kept for the beacon's history panel.
#define SALE_HISTORY_MAX 15

/// Tracks every GOLDFACE/SILVERFACE vendor so the beacon can locate the
/// merchant's own till to deposit the guild levy into.
GLOBAL_LIST_EMPTY(goldface_vendors)

GLOBAL_VAR_INIT(sky_handler_levy, 0.5)

#define SKY_HANDLER_MIN_SELLER_SHARE 0.1

/obj/item/fake_machine/merchant
	name = "SKY HANDLER"
	desc = "A machine that attracts the attention of trading balloons."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "ballooner"
	density = TRUE
	blade_dulling = DULLING_BASH
	var/next_airlift
	anchored = TRUE
	w_class = WEIGHT_CLASS_GIGANTIC
	/// Tagline shown at the top of the TGUI window.
	var/motto = "MERCHANT'S GUILD - Your goods, airborne."
	/// Recent sales, oldest first: list of list("name", "value").
	var/list/sale_history = list()

/obj/structure/fake_machine/balloon_pad
	name = ""
	desc = ""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = ""
	density = FALSE
	layer = BELOW_OBJ_LAYER
	anchored = TRUE

/obj/item/fake_machine/merchant/Initialize()
	. = ..()
	if(anchored)
		START_PROCESSING(SSroguemachine, src)
	set_light(2, 2, 2, l_color = "#1b7bf1")
	for(var/X in GLOB.alldirs)
		var/T = get_step(src, X)
		if(!T)
			continue
		new /obj/structure/fake_machine/balloon_pad(T)

/obj/item/fake_machine/merchant/Destroy()
	STOP_PROCESSING(SSroguemachine, src)
	set_light(0)
	return ..()

/obj/item/fake_machine/merchant/attack_hand(mob/living/user)
	if(!anchored)
		return ..()
	if(!ishuman(user))
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
	ui_interact(user)

/obj/item/fake_machine/merchant/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/fake_machine/merchant/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Navigator", name, 460, 600)
		ui.open()

/obj/item/fake_machine/merchant/ui_data(mob/user)
	var/list/data = list()
	data["motto"] = motto
	data["can_read"] = user.can_read(src, TRUE) ? TRUE : FALSE
	data["next_airlift_seconds"] = max(0, round((next_airlift - world.time) / 10))
	var/levy = GLOB.sky_handler_levy
	var/lord_tax = get_lord_tax(levy)
	data["guild_tax_percent"] = round(levy * 100)
	data["lord_tax_percent"] = round(lord_tax * 100)
	data["total_tax_percent"] = round((levy + lord_tax) * 100)
	// TRUE if the viewer themselves is a guild member exempt from the guild levy.
	data["viewer_exempt"] = is_guild_member(user) ? TRUE : FALSE
	// Build the history newest-first for display.
	var/list/hist = list()
	for(var/i = length(sale_history) to 1 step -1)
		hist += list(sale_history[i])
	data["history"] = hist
	return data

/obj/item/fake_machine/merchant/proc/get_lord_tax(levy_rate)
	return clamp(SStreasury.tax_value, 0, max(0, 1 - SKY_HANDLER_MIN_SELLER_SHARE - levy_rate))

/// Finds the merchant's own (non-public) GOLDFACE till to receive the guild levy.
/obj/item/fake_machine/merchant/proc/get_merchant_goldface()
	for(var/obj/structure/fake_machine/merchantvend/G in GLOB.goldface_vendors)
		if(!G.is_public)
			return G
	return null

/// Records one sold item into the rolling history buffer (drops the oldest).
/obj/item/fake_machine/merchant/proc/add_sale_history(item_name, value)
	sale_history += list(list("name" = item_name, "value" = value))
	if(length(sale_history) > SALE_HISTORY_MAX)
		sale_history.Cut(1, 2)

/// TRUE if this human holds a Waterdeep Guild role that is exempt from the
/// guild levy (Merchant, Banker, Guild Assistant). They still pay the Lord's tax.
/obj/item/fake_machine/merchant/proc/is_guild_member(mob/living/carbon/human/H)
	if(!istype(H) || !H.job)
		return FALSE
	var/datum/job/J = SSjob.GetJob(H.job)
	if(!J)
		return FALSE
	return istype(J, /datum/job/waterdeep_merchant) || istype(J, /datum/job/waterdeep_banker) || istype(J, /datum/job/waterdeep_guild_assistant)

/// TRUE if such a guild member is standing on or next to the beacon (within the
/// pad ring) at airlift time, which waives the guild levy for that cycle.
/obj/item/fake_machine/merchant/proc/guild_exempt_present()
	for(var/mob/living/carbon/human/H in range(1, src))
		if(H.stat == DEAD)
			continue
		if(is_guild_member(H))
			return TRUE
	return FALSE

/// Splits a tile's gross sale value into guild levy, Lord's tax and seller payout.
/// When guild_exempt is set the merchant/banker/assistant pays no guild levy.
/obj/item/fake_machine/merchant/proc/settle_export(gross, obj/structure/fake_machine/balloon_pad/pad, guild_exempt = FALSE)
	var/levy_rate = guild_exempt ? 0 : GLOB.sky_handler_levy
	var/guild_levy = round(gross * levy_rate)
	var/lord_tax = round(gross * get_lord_tax(levy_rate))
	var/producer_net = gross - guild_levy - lord_tax
	if(producer_net < 0)
		producer_net = 0
	// Guild levy -> the merchant's GOLDFACE till (fallback to treasury if none exists).
	if(guild_levy > 0)
		var/obj/structure/fake_machine/merchantvend/till = get_merchant_goldface()
		if(till)
			till.budget += guild_levy
		else
			SStreasury.give_money_treasury(guild_levy, "Waterdeep's levy")
	// Lord's export tax -> realm treasury.
	if(lord_tax > 0)
		SStreasury.give_money_treasury(lord_tax, "sky handler export tax")
		record_round_statistic(STATS_TAXES_COLLECTED, lord_tax)
	record_round_statistic(STATS_TRADE_VALUE_EXPORTED, gross)
	// Remainder paid to the seller as coins on the pad tile.
	if(producer_net > 0)
		pad.budget2change(producer_net)
	visible_message(span_info("[src] chimes: \"[gross] gross, [guild_levy] guild, [lord_tax] lords, [producer_net] to the seller.\""))

/obj/item/fake_machine/merchant/process()
	if(world.time <= next_airlift)
		return
	next_airlift = world.time + rand(2 MINUTES, 3 MINUTES)
#ifdef TESTSERVER
	next_airlift = world.time + 5 SECONDS
#endif
	var/play_sound = FALSE
	var/sold_any = FALSE
	// Spare the guild levy if a Merchant/Banker/Guild Assistant is working the beacon.
	var/guild_exempt = guild_exempt_present()
	for(var/D in GLOB.alldirs)
		var/turf/T = get_step(src, D)
		if(!T)
			continue
		var/obj/structure/fake_machine/balloon_pad/E = locate() in T
		if(!E)
			continue
		var/gross = 0
		for(var/obj/I in T)
			if(I.anchored)
				continue
			if(!isturf(I.loc))
				continue
			// Never airlift currency. This is the coin-resale fix: a naive Azure
			// port excludes /obj/item/roguecoin (which does not exist in Vanderlin),
			// so the beacon would keep selling coins - including its own change.
			if(istype(I, /obj/item/coin))
				continue
			var/datum/world_faction/faction = SSmerchant.active_faction
			var/market_modifier = faction?.return_sell_modifier(I.type) || 1
			var/bounty_currency_before = SSmerchant.extra_currency
			var/bounty_status = faction?.handle_selling(I)
			var/bounty_reward = max(0, SSmerchant.extra_currency - bounty_currency_before)
			if(bounty_reward)
				// Bounty compensation is paid in full; it is not an export sale and is not taxed.
				SSmerchant.extra_currency -= bounty_reward
				E.budget2change(bounty_reward)
				add_sale_history("[I.name] bounty", bounty_reward)
				visible_message(span_boldnotice("[src] dispenses [bounty_reward] amna in bounty compensation."))
				sold_any = TRUE
			if(bounty_status == TRUE)
				I.visible_message(span_warning("[I] is sucked into the air!"))
				qdel(I)
				play_sound = TRUE
				sold_any = TRUE
				continue
			if(bounty_status == FALSE_BUT_HANDLED)
				continue
			var/prize = I.get_real_price()
			if(faction)
				prize *= market_modifier
				var/list/reagent_values = faction.get_reagent_sell_values(I)
				for(var/reagent_name in reagent_values)
					var/list/reagent_data = reagent_values[reagent_name]
					prize += reagent_data[2]
			prize = FLOOR(prize, 1)
			if(prize >= 1)
				gross += prize
				add_sale_history(I.name, round(prize))
				I.visible_message(span_warning("[I] is sucked into the air!"))
				qdel(I)
				play_sound = TRUE
		gross = round(gross)
		if(gross > 0)
			settle_export(gross, E, guild_exempt)
			sold_any = TRUE
	if(play_sound)
		playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	if(sold_any)
		SStgui.update_uis(src)
		SSmerchant.refresh_ledger_uis()

/proc/is_sky_levy_setter(mob/living/carbon/human/user)
	if(!istype(user) || !user.job)
		return FALSE
	return istype(SSjob.GetJob(user.job), /datum/job/waterdeep_merchant)

/proc/get_sky_levy_max_percent()
	return max(0, 100 - round(SKY_HANDLER_MIN_SELLER_SHARE * 100) - round(SStreasury.tax_value * 100))

/obj/structure/fake_machine/atm/MiddleClick(mob/user, list/modifiers)
	. = ..()
	if(!ishuman(user) || user.get_active_held_item() || !is_sky_levy_setter(user))
		return
	for(var/datum/tgui/open_ui as anything in user.tgui_open_uis)
		if(istype(open_ui.src_object, /datum/sky_levy_panel))
			return
	var/datum/sky_levy_panel/panel = new(src)
	panel.ui_interact(user)

/datum/sky_levy_panel
	var/obj/structure/fake_machine/atm/meister

/datum/sky_levy_panel/New(obj/structure/fake_machine/atm/meister)
	. = ..()
	src.meister = meister

/datum/sky_levy_panel/Destroy()
	meister = null
	return ..()

/datum/sky_levy_panel/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(meister) || !is_sky_levy_setter(user))
		return UI_CLOSE
	return GLOB.physical_state.can_use_topic(meister, user)

/datum/sky_levy_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SkyLevy", "SKY HANDLER LEVY", 320, 230)
		ui.open()

/datum/sky_levy_panel/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/sky_levy_panel/ui_data(mob/user)
	var/list/data = list()
	data["current_levy"] = round(GLOB.sky_handler_levy * 100)
	data["lord_tax"] = round(SStreasury.tax_value * 100)
	data["min_seller_share"] = round(SKY_HANDLER_MIN_SELLER_SHARE * 100)
	data["max_levy"] = get_sky_levy_max_percent()
	return data

/datum/sky_levy_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("set")
			if(!is_sky_levy_setter(user))
				return TRUE
			var/new_levy = text2num("[params["value"]]")
			if(!isnum(new_levy))
				return TRUE
			new_levy = clamp(round(new_levy), 0, get_sky_levy_max_percent())
			var/old_levy = round(GLOB.sky_handler_levy * 100)
			GLOB.sky_handler_levy = new_levy / 100
			to_chat(user, span_notice("The merchant guild levy on the SKY HANDLER is now [new_levy]%."))
			log_game("[key_name(user)] changed the SKY HANDLER guild levy from [old_levy]% to [new_levy]%.")
			ui.close()
			return TRUE
		if("cancel")
			ui.close()
			return TRUE

#undef SKY_HANDLER_MIN_SELLER_SHARE
#undef SALE_HISTORY_MAX
//RMH EDITED END


/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

#define UPGRADE_NOTAX		(1<<0)
/// Catch-all tab for supply packs that declare no group of their own.
#define MERCHANT_CAT_MISC	"Misc"

/obj/structure/fake_machine/merchantvend
	name = "GOLDFACE"
	desc = "Gilded tombs do worms enfold."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "goldvendor"
	density = TRUE
	blade_dulling = DULLING_BASH
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	rattle_sound = 'sound/misc/machineno.ogg'
	unlock_sound = 'sound/misc/beep.ogg'
	lock_sound = 'sound/misc/beep.ogg'
	lock = /datum/lock/key/goldface
	var/list/held_items = list()
	var/budget = 200
	var/upgrade_flags
	var/current_cat
	var/base_price = 0
	var/final_price = 0
	var/taxes = 0
	//RMH EDITED START
	/// Flat percentage markup added on top of the base pack cost (0.5 = +50%).
	/// Used by the public SILVERFACE tier; GOLDFACE keeps it at 0.
	var/extra_fee = 0
	/// Which round statistic to log spending under. Lets SILVERFACE track separately.
	var/value_record_key = STATS_GOLDFACE_VALUE_SPENT
	/// Tagline shown at the top of the TGUI window.
	var/motto = "GOLDFACE - In the name of greed."
	/// TRUE on the public SILVERFACE tier (anyone may buy; cannot be locked).
	var/is_public = FALSE
	/// Active text search across all categories (empty = browse by category).
	var/search = ""
	/// Cap on search results sent to the UI.
	var/result_cap = 60
	/// Running tally of import tax paid / dodged through this machine.
	var/tariff_paid = 0
	var/tariff_evaded = 0
	//RMH EDITED END
	// this is the list of supply groups that you can purchase with this machine
	var/list/unlocked_cats = list("Hats", "Masks", "Neckwear", "Cloaks", "Coats & Vests", "Shirts & Dresses", "Trousers", "Stockings", "Footwear", "Gloves", "Belts", "Dyes","Storage","Armor(Light)","Armor(Iron)","Armor(Steel)","Food","Drinks","Jewelry","Luxury","Intimate Toys","Bondage Gear","Tools","Seeds","Shields","Medicine","Raw Materials",
								"Weapons (Iron)","Weapons (Steel)","Weapons (Ranged)","Ammunition",MERCHANT_CAT_MISC)

/obj/structure/fake_machine/merchantvend/Initialize()
	. = ..()
	GLOB.goldface_vendors += src //RMH EDITED
	set_light(1, 1, 1, l_color =  "#1b7bf1")

/obj/structure/fake_machine/merchantvend/atom_break(damage_flag)
	. = ..()
	budget2change(budget)
	set_light(0)

/obj/structure/fake_machine/merchantvend/atom_fix()
	. = ..()
	set_light(1, 1, 1, l_color =  "#1b7bf1")

/obj/structure/fake_machine/merchantvend/Destroy()
	. = ..()
	GLOB.goldface_vendors -= src //RMH EDITED
	budget2change(budget)
	set_light(0)

//RMH EDITED START
/// The effective service-fee multiplier for this machine (0 on GOLDFACE).
/obj/structure/fake_machine/merchantvend/proc/get_effective_fee()
	return extra_fee

/// TRUE only if this machine is allowed to stock that pack's category.
/// Single source of truth for browsing, searching AND buying, so the search
/// can never surface (or sell) goods outside the machine's own trade.
/obj/structure/fake_machine/merchantvend/proc/pack_in_stock(datum/supply_pack/P)
	if(!P)
		return FALSE
	if(P.hidden || P.contraband || !P.unlocked || (P.special && !P.special_enabled))
		return FALSE
	var/pack_cat = length(P.group) ? P.group : MERCHANT_CAT_MISC
	return (pack_cat in unlocked_cats)

/// Resolve a base pack path to the active faction's independently priced market datum.
/obj/structure/fake_machine/merchantvend/proc/get_market_pack(pack_type)
	var/datum/world_faction/faction = SSmerchant.active_faction
	if(!faction)
		return null
	if(istype(pack_type, /datum/supply_pack))
		var/datum/supply_pack/pack = pack_type
		pack_type = pack.type
	return faction.faction_supply_packs[pack_type]

/// Shared price calc so the display and the buy path can never disagree.
/// The service fee is a markup on the good; import tax is charged on the
/// raw pack cost only (mirrors the original GOLDFACE tax behaviour).
/obj/structure/fake_machine/merchantvend/proc/get_pack_price(datum/supply_pack/PA, include_tax = TRUE)
	PA = get_market_pack(PA)
	if(!pack_in_stock(PA))
		return 0
	var/cost = PA.cost + (PA.cost * get_effective_fee())
	if(include_tax && !(upgrade_flags & UPGRADE_NOTAX))
		cost += round(SStreasury.tax_value * PA.cost)
	return round(cost)
//RMH EDITED END

/obj/structure/fake_machine/merchantvend/attackby(obj/item/I, mob/user, list/modifiers)
	if(istype(I, /obj/item/coin))
		var/money = I.get_real_price()
		budget += money
		qdel(I)
		to_chat(user, span_info("I put [money] amna in [src]."))
		playsound(src, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		SStgui.update_uis(src) //RMH EDITED
		return attack_hand(user)
	return ..()

//RMH EDITED START
/obj/structure/fake_machine/merchantvend/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	if(locked() && !is_public)
		to_chat(user, span_warning("It's locked. Of course."))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
	ui_interact(user)

/obj/structure/fake_machine/merchantvend/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/fake_machine/merchantvend/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Goldface", name, 880, 800)
		ui.open()

/obj/structure/fake_machine/merchantvend/proc/is_proprietor(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	return H.job == "Merchant"

/obj/structure/fake_machine/merchantvend/ui_data(mob/user)
	var/list/data = list()
	var/dodging = (upgrade_flags & UPGRADE_NOTAX) ? TRUE : FALSE
	data["motto"] = motto
	data["budget"] = budget
	data["can_read"] = user.can_read(src, TRUE) ? TRUE : FALSE
	data["locked"] = locked() ? TRUE : FALSE
	data["is_public"] = is_public
	data["is_proprietor"] = is_proprietor(user)
	data["is_agent"] = FALSE
	data["is_command_center"] = FALSE
	data["tariff_rate_pct"] = round(SStreasury.tax_value * 100)
	data["tariff_paid"] = tariff_paid
	data["tariff_evaded"] = tariff_evaded
	data["dodging"] = dodging
	if(get_effective_fee() > 0)
		data["public_margin_pct"] = round(get_effective_fee() * 100)
		data["public_margin_label"] = "Waterdeep's Margin"
	data["categories"] = unlocked_cats
	data["current_category"] = current_cat
	data["search"] = search
	data["search_mode"] = (length(search) > 0) ? TRUE : FALSE
	data["result_cap"] = result_cap

	var/list/packs = list()
	var/total_matches = 0
	var/searching = (length(search) > 0)
	var/browsing_misc = (current_cat == MERCHANT_CAT_MISC)
	if(searching || (current_cat && (current_cat in unlocked_cats)))
		var/list/matched = list()
		var/datum/world_faction/faction = SSmerchant.active_faction
		for(var/pack in faction?.faction_supply_packs)
			var/datum/supply_pack/P = faction.faction_supply_packs[pack]
			// Never leave this machine's own catalogue, search included.
			if(!pack_in_stock(P))
				continue
			if(searching)
				if(!findtext(P.name, search))
					continue
			else if(browsing_misc)
				if(length(P.group))
					continue
			else if(P.group != current_cat)
				continue
			matched += P
		total_matches = length(matched)
		var/count = 0
		for(var/datum/supply_pack/P in sortList(matched))
			count++
			if(searching && count > result_cap)
				break
			var/price_base = round(P.cost + (P.cost * get_effective_fee()))
			var/price_tariff = dodging ? 0 : round(SStreasury.tax_value * P.cost)
			packs += list(list(
				"ref" = "[P.type]",
				"name" = P.name,
				"category" = length(P.group) ? P.group : MERCHANT_CAT_MISC,
				"qty" = (islist(P.contains) ? length(P.contains) : 1),
				"price" = price_base + price_tariff,
				"price_base" = price_base,
				"price_tariff" = price_tariff,
			))
	data["total_matches"] = total_matches
	data["packs"] = packs
	return data

/obj/structure/fake_machine/merchantvend/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return
	if(!usr.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH) || (locked() && !is_public))
		return
	var/mob/living/carbon/human/human_mob = usr
	switch(action)
		if("changecat")
			var/selected_category = params["category"]
			if(selected_category && (selected_category in unlocked_cats))
				current_cat = selected_category
			else
				current_cat = null
			return TRUE
		if("set_search")
			search = trim(params["search"])
			return TRUE
		if("clear_search")
			search = ""
			return TRUE
		if("change")
			if(budget > 0)
				budget2change(budget, human_mob)
				budget = 0
				playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
			return TRUE
		if("secrets")
			if(!is_proprietor(human_mob) || is_public)
				return TRUE
			if(upgrade_flags & UPGRADE_NOTAX)
				upgrade_flags &= ~UPGRADE_NOTAX
			else
				upgrade_flags |= UPGRADE_NOTAX
			playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
			return TRUE
		if("buy")
			var/path = text2path(params["ref"])
			if(!ispath(path, /datum/supply_pack))
				message_admins("MERCHANT [usr.key] IS TRYING TO BUY A [path] WITH THE GOLDFACE. THIS IS AN EXPLOIT.")
				return TRUE
			var/datum/supply_pack/picked_pack = get_market_pack(path)
			if(!picked_pack)
				return TRUE
			// Server-side stock check: a stale UI or a spoofed ref cannot buy
			// goods this machine does not trade in.
			if(!pack_in_stock(picked_pack))
				say("We don't deal in that here!")
				return TRUE
			base_price = round(picked_pack.cost + (picked_pack.cost * get_effective_fee()))
			taxes = round(SStreasury.tax_value * picked_pack.cost)
			final_price = round(base_price + taxes)
			if(upgrade_flags & UPGRADE_NOTAX)
				final_price = base_price
			if(budget < final_price)
				say("Not enough!")
				return TRUE
			budget -= final_price
			record_round_statistic(value_record_key, final_price)
			if(!(upgrade_flags & UPGRADE_NOTAX))
				SStreasury.give_money_treasury(taxes, "goldface import tax")
				record_featured_stat(FEATURED_STATS_TAX_PAYERS, human_mob, taxes)
				record_round_statistic(STATS_TAXES_COLLECTED, taxes)
				tariff_paid += taxes
			else
				record_round_statistic(STATS_TAXES_EVADED, taxes)
				tariff_evaded += taxes
			for(var/spawn_type in picked_pack.contains)
				var/atom/movable/purchased_item = new spawn_type(get_turf(human_mob))
				if(picked_pack.admin_spawned)
					purchased_item.flags_1 |= ADMIN_SPAWNED_1
				if(isitem(purchased_item))
					var/list/quality_result = SSmerchant.active_faction?.get_faction_quality_calculator(purchased_item)
					if(quality_result)
						create_quality_item(purchased_item, quality_result[1], quality_override = quality_result[2])
			SSmerchant.active_faction?.apply_purchase_demand_pressure(picked_pack, 1)
			SSmerchant.active_faction?.handle_supply_purchase(picked_pack)
			SSmerchant.refresh_ledger_uis()
			// NOTE: do NOT qdel(picked_pack) here. Supply packs are shared
			// singletons owned by SSmerchant; deleting one hard-deletes a datum
			// that stays referenced in SSmerchant.supply_packs and the faction
			// pools, and would corrupt the catalogue for every other vendor.
			playsound(src, 'sound/misc/beep.ogg', 100, FALSE, -1)
			return TRUE
//RMH EDITED END

#undef UPGRADE_NOTAX

//RMH EDITED START
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
// SILVERFACE
// Public-access tier of the GOLDFACE, ported from Azure Peak.
// Anyone may buy from it; in exchange the Company tacks on a flat
// service fee (extra_fee). It cannot be locked. Themed variants
// simply expose a different slice of the supply catalogue.
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/obj/structure/fake_machine/merchantvend/public
	name = "SILVERFACE"
	desc = "A public cousin of the GOLDFACE. The Company charges a hefty fee for the privilege of using it. By agreement, it cannot be locked by anyone."
	icon_state = "streetvendor1"
	lock = null				// public: always usable, can never be locked
	is_public = TRUE
	budget = 0				// no starting float; load it with coins
	extra_fee = 0.5			// +50% Company service margin
	value_record_key = STATS_SILVERFACE_VALUE_SPENT
	motto = "SILVERFACE - Commerce for all."
	unlocked_cats = list(
		"Storage",
		"Drinks",
		"Food",
		"Jewelry",
		"Instruments",
		"Luxury",
		"Intimate Toys",
		"Bondage Gear",
		"Livestock",
		"Seeds",
		"Tools",
		"Medicine",
		MERCHANT_CAT_MISC,
	)

/obj/structure/fake_machine/merchantvend/public/examine(mob/user)
	. = ..()
	. += span_info("A public version of the GOLDFACE. The Company charges a hefty fee for its usage. Per agreement, it cannot be locked by anyone.")

/obj/structure/fake_machine/merchantvend/public/smith
	name = "Smithy's SILVERFACE"
	desc = "A public SILVERFACE stocked with the wares of the smithing trade."
	// Metalwork only: every piece here needs a bar on the anvil, even the ones
	// that also use leather or cloth (splint, chain, etc).
	unlocked_cats = list(
		"Armor(Iron)",
		"Armor(Steel)",
		"Shields",
		"Weapons (Iron)",
		"Weapons (Steel)",
		"Weapons (Ranged)",
		"Ammunition",
	)

/obj/structure/fake_machine/merchantvend/public/tailor
	name = "Tailor's SILVERFACE"
	desc = "A public SILVERFACE stocked with garments and light protection."
	// Cloth and leather only: nothing here carries a scrap of metal.
	unlocked_cats = list(
		"Hats",
		"Masks",
		"Neckwear",
		"Cloaks",
		"Coats & Vests",
		"Shirts & Dresses",
		"Trousers",
		"Stockings",
		"Footwear",
		"Gloves",
		"Belts",
		"Dyes",
		"Armor(Light)",
		"Storage",
	)

/obj/structure/fake_machine/merchantvend/public/apothecary
	name = "Apothecary's SILVERFACE"
	desc = "A public SILVERFACE stocked with tinctures and remedies."
	unlocked_cats = list(
		"Medicine",
	)

#undef MERCHANT_CAT_MISC
//RMH EDITED END
