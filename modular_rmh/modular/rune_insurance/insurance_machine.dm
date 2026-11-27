/obj/structure/fake_machine/rune_insurance
	name = "insurance vault"
	desc = "The Guild insures belongings here and returns those the rune has taken."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "atm"
	density = FALSE
	blade_dulling = DULLING_BASH
	SET_BASE_PIXEL(0, 32)

/obj/structure/fake_machine/rune_insurance/attack_hand(mob/user)
	if(!ishuman(user))
		return
	if(user.real_name in GLOB.outlawed_players)
		say("OUTLAW DETECTED! REFUSING SERVICE!")
		return
	ui_interact(user)

/obj/structure/fake_machine/rune_insurance/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/fake_machine/rune_insurance/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RuneInsurance", name, 620, 720)
		ui.open()

/// The human this machine will serve, or null.
/obj/structure/fake_machine/rune_insurance/proc/get_customer(mob/user)
	if(!ishuman(user) || !user.mind)
		return null
	if(user.real_name in GLOB.outlawed_players)
		return null
	return user

/obj/structure/fake_machine/rune_insurance/proc/get_item_status(obj/item/item, datum/rune_insurance_record/record)
	var/datum/component/rune_insured/policy = item.GetComponent(/datum/component/rune_insured)
	if(policy && record && policy.record == record)
		return "insured"
	if(rune_insurance_refusal(item))
		return "refused"
	if(policy)
		return "insured_other"
	return "insurable"

/obj/structure/fake_machine/rune_insurance/proc/get_policy_place(datum/component/rune_insured/policy, mob/user)
	if(policy.vaulted)
		return "vault"
	var/atom/holder = policy.parent
	while(holder && !isturf(holder))
		if(holder == user)
			return "carried"
		holder = holder.loc
	return "elsewhere"

/obj/structure/fake_machine/rune_insurance/ui_data(mob/user)
	var/list/data = list()
	var/datum/rune_insurance_record/record = user.mind?.rune_insurance
	data["rate"] = GLOB.rune_insurance_rate
	data["rate_min"] = RUNE_INSURANCE_MIN_RATE
	data["rate_max"] = RUNE_INSURANCE_MAX_RATE
	data["min_premium"] = RUNE_INSURANCE_MIN_PREMIUM
	data["min_premium_arms"] = RUNE_INSURANCE_MIN_PREMIUM_ARMS
	data["can_set_rate"] = is_banker_job(user.mind?.assigned_role) ? TRUE : FALSE
	data["balance"] = ishuman(user) ? rune_insurance_balance(user) : null

	var/list/items = list()
	var/insure_all_cost = 0
	if(ishuman(user))
		for(var/obj/item/item as anything in rune_insurance_candidates(user))
			var/status = get_item_status(item, record)
			var/premium = rune_insurance_premium(item)
			if(status == "insurable" || status == "insured_other")
				insure_all_cost += premium
			items += list(list(
				"ref" = REF(item),
				"name" = item.name,
				"value" = item.get_real_price(),
				"premium" = premium,
				"status" = status,
				"note" = rune_insurance_refusal(item),
			))
	data["items"] = items
	data["insure_all_cost"] = insure_all_cost

	var/list/policies = list()
	var/vault_count = 0
	if(record)
		for(var/datum/component/rune_insured/policy as anything in record.policies)
			var/obj/item/insured_item = policy.parent
			if(policy.vaulted)
				vault_count++
			policies += list(list(
				"name" = insured_item.name,
				"value" = policy.insured_value,
				"place" = get_policy_place(policy, user),
			))
	data["policies"] = policies
	data["vault_count"] = vault_count
	data["vault_value"] = record ? record.get_vault_value() : 0
	data["claims_filed"] = record ? record.claims_filed : 0

	var/open_tier = record?.claim_tier
	if(open_tier)
		data["claim"] = list(
			"tier" = open_tier,
			"ready" = record.is_claim_ready() ? TRUE : FALSE,
			"seconds_left" = max(CEILING((record.claim_ready_at - world.time) / (1 SECONDS), 1), 0),
		)
	else
		data["claim"] = null

	var/static/list/tier_names = list("Standard", "Express", "Instant")
	var/list/tiers = list()
	for(var/tier in RUNE_INSURANCE_TIER_STANDARD to RUNE_INSURANCE_TIER_INSTANT)
		tiers += list(list(
			"tier" = tier,
			"name" = tier_names[tier],
			"wait_seconds" = rune_insurance_tier_wait(tier) / (1 SECONDS),
			"fee" = record ? record.get_claim_fee(tier) : 0,
			"available" = (vault_count && (!open_tier || tier > open_tier)) ? TRUE : FALSE,
		))
	data["tiers"] = tiers
	return data

/// Insures one item for the customer and tells them why if it fails.
/obj/structure/fake_machine/rune_insurance/proc/try_insure(obj/item/item, mob/living/carbon/human/customer, datum/rune_insurance_record/record)
	var/refusal = rune_insurance_refusal(item)
	if(refusal)
		to_chat(customer, span_warning(refusal))
		return FALSE
	var/datum/component/rune_insured/policy = item.GetComponent(/datum/component/rune_insured)
	if(policy?.record == record)
		to_chat(customer, span_warning("[item] is already insured in my name."))
		return FALSE
	var/balance = rune_insurance_balance(customer)
	if(isnull(balance))
		to_chat(customer, span_warning("I have no bank account to pay the premium from."))
		return FALSE
	if(balance < rune_insurance_premium(item))
		to_chat(customer, span_warning("My account cannot cover the premium for [item]."))
		return FALSE
	if(!record.insure(item, customer))
		to_chat(customer, span_warning("The Guild refuses to insure [item]."))
		return FALSE
	return TRUE

/obj/structure/fake_machine/rune_insurance/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/customer = get_customer(ui.user)
	if(!customer)
		return FALSE

	switch(action)
		if("insure")
			var/obj/item/item = locate(params["ref"]) in rune_insurance_candidates(customer)
			if(!item)
				return FALSE
			if(!try_insure(item, customer, get_rune_insurance_record(customer.mind)))
				playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
				return FALSE
			playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
			return TRUE

		if("insure_all")
			var/datum/rune_insurance_record/record = get_rune_insurance_record(customer.mind)
			var/insured_count = 0
			for(var/obj/item/item as anything in rune_insurance_candidates(customer))
				var/status = get_item_status(item, record)
				if(status != "insurable" && status != "insured_other")
					continue
				if(!try_insure(item, customer, record))
					break
				insured_count++
			if(!insured_count)
				playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
				return FALSE
			to_chat(customer, span_notice("The Guild insures [insured_count] of my belongings."))
			playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
			return TRUE

		if("claim")
			var/tier = params["tier"]
			if(!isnum(tier))
				tier = text2num(tier)
			if(tier != RUNE_INSURANCE_TIER_STANDARD && tier != RUNE_INSURANCE_TIER_EXPRESS && tier != RUNE_INSURANCE_TIER_INSTANT)
				return FALSE
			var/datum/rune_insurance_record/record = customer.mind.rune_insurance
			if(!record)
				return FALSE
			var/fee = record.get_claim_fee(tier)
			if(!record.request_claim(tier, customer))
				var/balance = rune_insurance_balance(customer)
				if(fee && (isnull(balance) || balance < fee))
					to_chat(customer, span_warning("My account cannot cover the claim fee."))
				else
					to_chat(customer, span_warning("The Guild does not accept the claim."))
				playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
				return FALSE
			playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
			return TRUE

		if("collect")
			var/datum/rune_insurance_record/record = customer.mind.rune_insurance
			var/collected = record?.collect_claim(customer)
			if(!collected)
				to_chat(customer, span_warning("There is nothing ready for me to collect."))
				return FALSE
			to_chat(customer, span_notice("The Guild returns [collected] of my belongings."))
			return TRUE

		if("set_rate")
			if(!is_banker_job(customer.mind.assigned_role))
				return FALSE
			var/rate = params["rate"]
			if(!isnum(rate))
				rate = text2num(rate)
			if(!isnum(rate))
				return FALSE
			var/new_rate = set_rune_insurance_rate(rate)
			say("The premium is now [new_rate]% of an item's value.")
			return TRUE
	return FALSE
