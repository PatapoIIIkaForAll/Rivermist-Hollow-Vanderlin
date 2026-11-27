/// Percent of an item's value charged as its premium. The banker sets it at an insurance machine.
GLOBAL_VAR_INIT(rune_insurance_rate, RUNE_INSURANCE_DEFAULT_RATE)

/datum/mind
	/// This character's rune insurance: policies, vaulted items and the open claim. Made on first use.
	var/datum/rune_insurance_record/rune_insurance

/// The mind's insurance record, made if it has none yet.
/proc/get_rune_insurance_record(datum/mind/owner)
	if(!owner)
		return null
	return owner.rune_insurance || new /datum/rune_insurance_record(owner)

/// Sets the premium rate in whole percent, kept within the allowed bounds. Returns the rate now in force.
/proc/set_rune_insurance_rate(percent)
	if(!isnum(percent))
		return GLOB.rune_insurance_rate
	GLOB.rune_insurance_rate = clamp(round(percent, 1), RUNE_INSURANCE_MIN_RATE, RUNE_INSURANCE_MAX_RATE)
	return GLOB.rune_insurance_rate

/// Whether the item pays the armor and weapon minimum premium.
/proc/rune_insurance_is_arms(obj/item/item)
	if(istype(item, /obj/item/weapon) || istype(item, /obj/item/gun))
		return TRUE
	if(!istype(item, /obj/item/clothing))
		return FALSE
	var/obj/item/clothing/clothing = item
	if(clothing.armor_class)
		return TRUE
	var/datum/armor/item_armor = clothing.get_armor()
	return item_armor.has_any_armor()

/// Premium for insuring the item at the current rate.
/proc/rune_insurance_premium(obj/item/item)
	var/minimum = rune_insurance_is_arms(item) ? RUNE_INSURANCE_MIN_PREMIUM_ARMS : RUNE_INSURANCE_MIN_PREMIUM
	return max(CEILING(item.get_real_price() * GLOB.rune_insurance_rate / 100, 1), minimum)

/// Why the bank refuses the item, or null if it takes it.
/proc/rune_insurance_refusal(obj/item/item)
	if(item.item_flags & (ABSTRACT|DROPDEL))
		return "It cannot be insured."
	if(HAS_TRAIT(item, TRAIT_NODROP))
		return "It cannot leave its bearer."
	if(istype(item, /obj/item/coin))
		return "The bank does not insure coin."
	if(istype(item, /obj/item/resurrection_compass))
		return "It will not last long enough to insure."
	if(item.GetComponent(/datum/component/quest_object))
		return "Contract goods cannot be insured."
	return null

/// Worn and held items of the mob that it could ask the bank to insure.
/proc/rune_insurance_candidates(mob/living/carbon/human/holder)
	var/list/candidates = holder.get_equipped_items(TRUE)
	for(var/obj/item/held in holder.held_items)
		candidates += held
	candidates -= holder.handcuffed
	candidates -= holder.legcuffed
	return candidates

/// The payer's bank balance, or null if they have no account.
/proc/rune_insurance_balance(mob/living/carbon/human/payer)
	var/account_key = SStreasury.resolve_bank_account_key(payer)
	if(!account_key || !(account_key in SStreasury.bank_accounts))
		return null
	return SStreasury.bank_accounts[account_key]

/// Moves the whole amount from the payer's account to the treasury, or nothing if they cannot cover it.
/proc/rune_insurance_charge(mob/living/carbon/human/payer, amount, reason)
	var/balance = rune_insurance_balance(payer)
	if(isnull(balance) || balance < amount)
		return FALSE
	if(!SStreasury.give_money_account(-amount, payer, reason, notify = FALSE))
		return FALSE
	// Taking from the account already wrote the steward's log line.
	SStreasury.give_money_treasury(amount, reason, silent = TRUE)
	return TRUE

/// Wait for a claim of the given speed.
/proc/rune_insurance_tier_wait(tier)
	switch(tier)
		if(RUNE_INSURANCE_TIER_STANDARD)
			return RUNE_INSURANCE_WAIT_STANDARD
		if(RUNE_INSURANCE_TIER_EXPRESS)
			return RUNE_INSURANCE_WAIT_EXPRESS
	return 0


/// One character's rune insurance for the round.
/datum/rune_insurance_record
	var/datum/mind/owner
	/// One policy per insured item. A policy removes itself when its item is deleted or the policy is voided.
	var/list/datum/component/rune_insured/policies = list()
	/// Claims filed this round. The first is free at standard speed.
	var/claims_filed = 0
	/// Speed of the open claim, null when there is none.
	var/claim_tier
	var/claim_filed_at = 0
	var/claim_ready_at = 0
	/// What the open claim cost before any speed fee.
	var/claim_base_fee = 0
	var/claim_fee_paid = 0
	var/claim_timer

/datum/rune_insurance_record/New(datum/mind/owner)
	src.owner = owner
	owner.rune_insurance = src
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_deleted))

/datum/rune_insurance_record/Destroy()
	deltimer(claim_timer)
	claim_timer = null
	for(var/datum/component/rune_insured/policy as anything in policies)
		if(policy.vaulted)
			// Nobody else can reach a vaulted item, so it goes with the record.
			qdel(policy.parent)
		else
			qdel(policy)
	policies.Cut()
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		owner.rune_insurance = null
		owner = null
	return ..()

/datum/rune_insurance_record/proc/on_owner_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// Sells a policy on an item the payer wears or holds. Replaces another character's policy on it.
/datum/rune_insurance_record/proc/insure(obj/item/item, mob/living/carbon/human/payer)
	if(QDELETED(item) || !istype(payer) || payer.mind != owner)
		return FALSE
	if(!(item in rune_insurance_candidates(payer)) || rune_insurance_refusal(item))
		return FALSE
	var/datum/component/rune_insured/old_policy = item.GetComponent(/datum/component/rune_insured)
	if(old_policy?.record == src)
		return FALSE
	if(!rune_insurance_charge(payer, rune_insurance_premium(item), "rune insurance premium"))
		return FALSE
	if(old_policy)
		qdel(old_policy)
	item.AddComponent(/datum/component/rune_insured, src, item.get_real_price())
	return TRUE

/// Sends the owner's insured items around the body to the vault as the rune takes them.
/// With include_body, items still on the body go too, for a body that is being destroyed.
/// Returns how many items were vaulted.
/datum/rune_insurance_record/proc/pull_to_vault(turf/center, mob/living/body, include_body = FALSE)
	if(!center)
		return 0
	var/vaulted_count = 0
	for(var/datum/component/rune_insured/policy as anything in policies)
		if(QDELETED(policy) || policy.vaulted)
			continue
		if(!can_pull(policy.parent, center, body, include_body))
			continue
		if(vault_item(policy))
			vaulted_count++
	if(vaulted_count)
		to_chat(owner, span_notice("The rune sends [vaulted_count] of your insured belongings to the Guild's vault. Claim them at an insurance machine."))
	return vaulted_count

/// Whether the rune takes this item: it lies loose near the body, sits in a loose container,
/// or is carried by a creature with no mind. Items in other characters' hands and in furniture stay.
/datum/rune_insurance_record/proc/can_pull(obj/item/item, turf/center, mob/living/body, include_body)
	var/turf/item_turf = get_turf(item)
	if(!item_turf || item_turf.z != center.z || get_dist(item_turf, center) > RUNE_INSURANCE_PULL_RADIUS)
		return FALSE
	var/atom/holder = item.loc
	while(holder && !isturf(holder))
		if(ismob(holder))
			var/mob/holder_mob = holder
			if(holder_mob == body || holder_mob.mind == owner)
				return include_body
			return !holder_mob.mind
		if(!isitem(holder))
			return FALSE
		var/datum/component/rune_insured/container_policy = holder.GetComponent(/datum/component/rune_insured)
		if(container_policy?.record == src)
			// It travels inside its own insured container.
			return FALSE
		holder = holder.loc
	return TRUE

/datum/rune_insurance_record/proc/vault_item(datum/component/rune_insured/policy)
	var/obj/item/item = policy.parent
	if(ismob(item.loc))
		var/mob/holder_mob = item.loc
		holder_mob.transferItemToLoc(item, null, force = TRUE)
	else
		item.moveToNullspace()
	if(QDELETED(policy) || item.loc)
		return FALSE
	policy.vaulted = TRUE
	return TRUE

/// Insured value of everything waiting in the vault.
/datum/rune_insurance_record/proc/get_vault_value()
	var/total = 0
	for(var/datum/component/rune_insured/policy as anything in policies)
		if(policy.vaulted)
			total += policy.insured_value
	return total

/datum/rune_insurance_record/proc/has_vaulted_items()
	for(var/datum/component/rune_insured/policy as anything in policies)
		if(policy.vaulted)
			return TRUE
	return FALSE

/datum/rune_insurance_record/proc/get_speed_fee(tier)
	var/vault_value = get_vault_value()
	switch(tier)
		if(RUNE_INSURANCE_TIER_EXPRESS)
			return max(CEILING(vault_value * RUNE_INSURANCE_EXPRESS_PERCENT / 100, 1), RUNE_INSURANCE_EXPRESS_MIN_FEE)
		if(RUNE_INSURANCE_TIER_INSTANT)
			return max(CEILING(vault_value * RUNE_INSURANCE_INSTANT_PERCENT / 100, 1), RUNE_INSURANCE_INSTANT_MIN_FEE)
	return 0

/// What the owner pays now to file a claim at this speed, or to move the open claim up to it.
/datum/rune_insurance_record/proc/get_claim_fee(tier)
	if(claim_tier)
		return max(claim_base_fee + get_speed_fee(tier) - claim_fee_paid, 0)
	var/base_fee = 0
	if(claims_filed)
		base_fee = max(CEILING(get_vault_value() * RUNE_INSURANCE_REPEAT_PERCENT / 100, 1), RUNE_INSURANCE_REPEAT_MIN_FEE)
	return base_fee + get_speed_fee(tier)

/// Files a claim for the vault at the given speed, or speeds up the open claim. The payer is charged now.
/datum/rune_insurance_record/proc/request_claim(tier, mob/living/carbon/human/payer)
	if(tier != RUNE_INSURANCE_TIER_STANDARD && tier != RUNE_INSURANCE_TIER_EXPRESS && tier != RUNE_INSURANCE_TIER_INSTANT)
		return FALSE
	if(!istype(payer) || payer.mind != owner || !has_vaulted_items())
		return FALSE
	if(claim_tier && (tier <= claim_tier || is_claim_ready()))
		return FALSE
	var/fee = get_claim_fee(tier)
	if(fee && !rune_insurance_charge(payer, fee, "rune insurance claim"))
		return FALSE
	if(!claim_tier)
		claim_base_fee = fee - get_speed_fee(tier)
		claim_filed_at = world.time
		claims_filed++
	claim_tier = tier
	claim_fee_paid += fee
	// Time already waited counts toward the faster speed.
	claim_ready_at = claim_filed_at + rune_insurance_tier_wait(tier)
	deltimer(claim_timer)
	claim_timer = null
	if(claim_ready_at > world.time)
		claim_timer = addtimer(CALLBACK(src, PROC_REF(announce_claim_ready)), claim_ready_at - world.time, TIMER_STOPPABLE)
	return TRUE

/datum/rune_insurance_record/proc/announce_claim_ready()
	claim_timer = null
	to_chat(owner, span_notice("The Guild has your insured belongings ready. Collect them at an insurance machine."))

/datum/rune_insurance_record/proc/is_claim_ready()
	return claim_tier && world.time >= claim_ready_at

/// Hands the vault to the receiver once the claim is ready. Items vaulted after filing come along.
/// Returns how many items were handed over.
/datum/rune_insurance_record/proc/collect_claim(mob/living/receiver)
	if(!is_claim_ready() || !istype(receiver) || receiver.mind != owner)
		return 0
	var/collected = 0
	for(var/datum/component/rune_insured/policy as anything in policies)
		if(QDELETED(policy) || !policy.vaulted)
			continue
		policy.vaulted = FALSE
		// Falls at their feet when their hands are full.
		receiver.put_in_hands(policy.parent)
		collected++
	deltimer(claim_timer)
	claim_timer = null
	claim_tier = null
	claim_filed_at = 0
	claim_ready_at = 0
	claim_base_fee = 0
	claim_fee_paid = 0
	return collected


/// Marks an item as insured for one character.
/datum/component/rune_insured
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/rune_insurance_record/record
	/// The item's value when the policy was written. Claim fees are worked out from it.
	var/insured_value = 0
	/// Held in the bank's vault, outside the world, until its owner collects a claim.
	var/vaulted = FALSE

/datum/component/rune_insured/Initialize(datum/rune_insurance_record/record, insured_value)
	if(!isitem(parent) || !record)
		return COMPONENT_INCOMPATIBLE
	src.record = record
	src.insured_value = insured_value
	record.policies += src

/datum/component/rune_insured/Destroy(force = FALSE)
	if(record)
		record.policies -= src
		record = null
	return ..()

/datum/component/rune_insured/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))

/datum/component/rune_insured/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_EQUIPPED))

/datum/component/rune_insured/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(user.mind && user.mind == record.owner)
		examine_list += span_info("It bears a Guild insurance seal in your name.")
	else
		examine_list += span_info("It bears a Guild insurance seal in someone else's name.")

/// Another character wearing the item makes it theirs: the policy ends. Picking it up does not.
/datum/component/rune_insured/proc/on_equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot == ITEM_SLOT_HANDS)
		return
	if(!equipper.mind || equipper.mind == record.owner)
		return
	qdel(src)
