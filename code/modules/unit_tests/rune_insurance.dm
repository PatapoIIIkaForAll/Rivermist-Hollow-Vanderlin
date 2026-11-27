/// Shared setup: characters with minds and bank accounts. Restores the premium rate and drops test accounts.
/datum/unit_test/rune_insurance
	abstract_type = /datum/unit_test/rune_insurance
	var/list/mob/living/carbon/human/characters = list()
	var/old_rate

/datum/unit_test/rune_insurance/New()
	. = ..()
	old_rate = GLOB.rune_insurance_rate
	GLOB.rune_insurance_rate = RUNE_INSURANCE_DEFAULT_RATE

/datum/unit_test/rune_insurance/Destroy()
	for(var/mob/living/carbon/human/character as anything in characters)
		SStreasury.bank_accounts -= character
		var/datum/mind/mind = character.mind
		if(mind)
			SStreasury.bank_account_owner_by_mind -= mind
			qdel(mind.rune_insurance)
	characters.Cut()
	GLOB.rune_insurance_rate = old_rate
	return ..()

/// A human with a mind; with a bank account when balance is given.
/datum/unit_test/rune_insurance/proc/make_character(turf/spot = run_loc_floor_bottom_left, balance = null)
	var/mob/living/carbon/human/character = allocate(/mob/living/carbon/human/species/human/northern, spot)
	character.mind_initialize()
	characters += character
	if(!isnull(balance))
		SStreasury.create_bank_account(character, balance)
	return character

/datum/unit_test/rune_insurance/proc/balance_of(mob/living/carbon/human/character)
	return SStreasury.bank_accounts[SStreasury.resolve_bank_account_key(character)]

/datum/unit_test/rune_insurance/proc/make_item(item_type, price = 1, turf/spot = run_loc_floor_bottom_left)
	var/obj/item/item = allocate(item_type, spot)
	item.sellprice = price
	return item

/// Writes a policy without charging anyone.
/datum/unit_test/rune_insurance/proc/seal(obj/item/item, mob/living/carbon/human/character)
	return item.AddComponent(/datum/component/rune_insured, get_rune_insurance_record(character.mind), item.get_real_price())

/datum/unit_test/rune_insurance/proc/wear_cloak(mob/living/carbon/human/character, obj/item/item)
	return character.equip_to_slot_if_possible(item, ITEM_SLOT_CLOAK, disable_warning = TRUE, bypass_equip_delay_self = TRUE)

/datum/unit_test/rune_insurance/proc/turf_beyond_pull(turf/center)
	var/offset = RUNE_INSURANCE_PULL_RADIUS + 1
	var/target_x = center.x + offset <= world.maxx ? center.x + offset : center.x - offset
	return locate(target_x, center.y, center.z)

/// Owner with a sealed cape of the given value already in the vault.
/datum/unit_test/rune_insurance/proc/vault_cape(mob/living/carbon/human/owner, value)
	var/obj/item/clothing/cloak/cape/cape = make_item(/obj/item/clothing/cloak/cape, value, get_turf(owner))
	seal(cape, owner)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	record.pull_to_vault(get_turf(owner), owner)
	return cape


/datum/unit_test/rune_insurance/premiums

/datum/unit_test/rune_insurance/premiums/Run()
	GLOB.rune_insurance_rate = 10
	var/obj/item/clothing/cloak/cape/cape = make_item(/obj/item/clothing/cloak/cape)
	var/obj/item/weapon/knife/dagger/dagger = make_item(/obj/item/weapon/knife/dagger)
	var/obj/item/clothing/armor/chainmail/mail = make_item(/obj/item/clothing/armor/chainmail)

	TEST_ASSERT_EQUAL(rune_insurance_premium(cape), RUNE_INSURANCE_MIN_PREMIUM, "Cheap cape premium.")
	TEST_ASSERT_EQUAL(rune_insurance_premium(dagger), RUNE_INSURANCE_MIN_PREMIUM_ARMS, "Cheap dagger premium.")
	TEST_ASSERT_EQUAL(rune_insurance_premium(mail), RUNE_INSURANCE_MIN_PREMIUM_ARMS, "Cheap haubergeon premium.")

	cape.sellprice = 500
	dagger.sellprice = 500
	TEST_ASSERT_EQUAL(rune_insurance_premium(cape), 50, "500-value cape at 10%.")
	TEST_ASSERT_EQUAL(rune_insurance_premium(dagger), 50, "500-value dagger at 10%.")

/datum/unit_test/rune_insurance/plain_clothes_premium

/datum/unit_test/rune_insurance/plain_clothes_premium/Run()
	var/obj/item/clothing/shirt/undershirt/shirt = make_item(/obj/item/clothing/shirt/undershirt)
	var/obj/item/clothing/pants/tights/tights = make_item(/obj/item/clothing/pants/tights)

	TEST_ASSERT_EQUAL(rune_insurance_premium(shirt), RUNE_INSURANCE_MIN_PREMIUM, "A plain shirt paid the arms minimum.")
	TEST_ASSERT_EQUAL(rune_insurance_premium(tights), RUNE_INSURANCE_MIN_PREMIUM, "Plain tights paid the arms minimum.")

/datum/unit_test/rune_insurance/rate_bounds

/datum/unit_test/rune_insurance/rate_bounds/Run()
	TEST_ASSERT_EQUAL(set_rune_insurance_rate(1), RUNE_INSURANCE_MIN_RATE, "Rate below minimum.")
	TEST_ASSERT_EQUAL(GLOB.rune_insurance_rate, RUNE_INSURANCE_MIN_RATE, "Stored rate below minimum.")
	TEST_ASSERT_EQUAL(set_rune_insurance_rate(999), RUNE_INSURANCE_MAX_RATE, "Rate above maximum.")
	TEST_ASSERT_EQUAL(set_rune_insurance_rate(12.6), 13, "Fractional rate rounds to nearest.")
	TEST_ASSERT_EQUAL(set_rune_insurance_rate(12.4), 12, "Fractional rate.")
	TEST_ASSERT_EQUAL(set_rune_insurance_rate("20"), 12, "Text rate changed the rate.")
	TEST_ASSERT_EQUAL(GLOB.rune_insurance_rate, 12, "Stored rate after text input.")


/datum/unit_test/rune_insurance/insure_worn

/datum/unit_test/rune_insurance/insure_worn/Run()
	var/mob/living/carbon/human/owner = make_character(balance = 100)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/cape = make_item(/obj/item/clothing/cloak/cape)
	TEST_ASSERT(wear_cloak(owner, cape), "Could not put the cape on.")
	var/premium = rune_insurance_premium(cape)
	var/treasury_before = SStreasury.treasury_value

	TEST_ASSERT(record.insure(cape, owner), "Worn cape was refused.")
	TEST_ASSERT_EQUAL(balance_of(owner), 100 - premium, "Wrong charge for the premium.")
	TEST_ASSERT_EQUAL(SStreasury.treasury_value, treasury_before + premium, "Premium did not reach the treasury.")
	TEST_ASSERT_EQUAL(length(record.policies), 1, "Policy count after insuring.")
	var/datum/component/rune_insured/policy = cape.GetComponent(/datum/component/rune_insured)
	TEST_ASSERT_NOTNULL(policy, "Cape has no policy.")
	TEST_ASSERT_EQUAL(policy.record, record, "Policy belongs to another record.")

	TEST_ASSERT(!record.insure(cape, owner), "Same character insured the cape twice.")
	TEST_ASSERT_EQUAL(balance_of(owner), 100 - premium, "Refused repeat insurance charged.")
	TEST_ASSERT_EQUAL(length(record.policies), 1, "Repeat insurance added a policy.")

/datum/unit_test/rune_insurance/insure_refusals

/datum/unit_test/rune_insurance/insure_refusals/Run()
	var/mob/living/carbon/human/owner = make_character(balance = 100)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)

	var/obj/item/clothing/cloak/cape/loose = make_item(/obj/item/clothing/cloak/cape)
	TEST_ASSERT(!record.insure(loose, owner), "Insured a cape lying on the floor.")
	TEST_ASSERT_EQUAL(balance_of(owner), 100, "Floor cape refusal charged.")

	var/obj/item/coin/copper/coin = allocate(/obj/item/coin/copper)
	TEST_ASSERT(owner.put_in_hands(coin), "Could not hold the coin.")
	TEST_ASSERT(!record.insure(coin, owner), "Insured a coin.")
	TEST_ASSERT_EQUAL(balance_of(owner), 100, "Coin refusal charged.")
	owner.dropItemToGround(coin)

	var/mob/living/carbon/human/poor = make_character(balance = 1)
	var/datum/rune_insurance_record/poor_record = get_rune_insurance_record(poor.mind)
	var/obj/item/clothing/cloak/cape/poor_cape = make_item(/obj/item/clothing/cloak/cape)
	TEST_ASSERT(wear_cloak(poor, poor_cape), "Could not put the cape on the poor character.")
	TEST_ASSERT(rune_insurance_premium(poor_cape) > 1, "Premium fits a balance of 1.")
	TEST_ASSERT(!poor_record.insure(poor_cape, poor), "Insured without enough money.")
	TEST_ASSERT_EQUAL(balance_of(poor), 1, "Partial charge on a refused premium.")

	var/mob/living/carbon/human/unbanked = make_character()
	var/datum/rune_insurance_record/unbanked_record = get_rune_insurance_record(unbanked.mind)
	var/obj/item/clothing/cloak/cape/unbanked_cape = make_item(/obj/item/clothing/cloak/cape)
	TEST_ASSERT(wear_cloak(unbanked, unbanked_cape), "Could not put the cape on the unbanked character.")
	TEST_ASSERT(!unbanked_record.insure(unbanked_cape, unbanked), "Insured without an account.")

	TEST_ASSERT_EQUAL(length(record.policies) + length(poor_record.policies) + length(unbanked_record.policies), 0, "A refused item got a policy.")

/datum/unit_test/rune_insurance/insure_replaces_other_policy

/datum/unit_test/rune_insurance/insure_replaces_other_policy/Run()
	var/mob/living/carbon/human/first = make_character(balance = 100)
	var/mob/living/carbon/human/second = make_character(balance = 100)
	var/datum/rune_insurance_record/first_record = get_rune_insurance_record(first.mind)
	var/datum/rune_insurance_record/second_record = get_rune_insurance_record(second.mind)
	var/obj/item/clothing/cloak/cape/cape = make_item(/obj/item/clothing/cloak/cape)
	TEST_ASSERT(wear_cloak(first, cape), "Could not put the cape on.")
	TEST_ASSERT(first_record.insure(cape, first), "First character was refused.")

	first.dropItemToGround(cape)
	TEST_ASSERT(second.put_in_hands(cape), "Second character could not hold the cape.")
	TEST_ASSERT(second_record.insure(cape, second), "Second character was refused.")

	TEST_ASSERT_EQUAL(balance_of(second), 100 - rune_insurance_premium(cape), "Second character's charge.")
	TEST_ASSERT_EQUAL(length(first_record.policies), 0, "Old policy stayed on the first record.")
	TEST_ASSERT_EQUAL(length(second_record.policies), 1, "Second record policy count.")
	var/datum/component/rune_insured/policy = cape.GetComponent(/datum/component/rune_insured)
	TEST_ASSERT_EQUAL(policy?.record, second_record, "Cape's policy owner.")


/datum/unit_test/rune_insurance/pull_distance

/datum/unit_test/rune_insurance/pull_distance/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/turf/far_turf = turf_beyond_pull(center)
	TEST_ASSERT_NOTNULL(far_turf, "No turf beyond the pull radius.")
	var/mob/living/carbon/human/owner = make_character(center)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/near = make_item(/obj/item/clothing/cloak/cape, 1, center)
	var/obj/item/clothing/cloak/cape/far = make_item(/obj/item/clothing/cloak/cape, 1, far_turf)
	var/datum/component/rune_insured/near_policy = seal(near, owner)
	var/datum/component/rune_insured/far_policy = seal(far, owner)

	TEST_ASSERT_EQUAL(record.pull_to_vault(center, owner), 1, "Vaulted count.")
	TEST_ASSERT_NULL(near.loc, "Nearby loose cape not vaulted.")
	TEST_ASSERT(near_policy.vaulted, "Nearby policy not marked vaulted.")
	TEST_ASSERT_EQUAL(far.loc, far_turf, "Distant cape moved.")
	TEST_ASSERT(!far_policy.vaulted, "Distant policy marked vaulted.")

/datum/unit_test/rune_insurance/pull_from_body

/datum/unit_test/rune_insurance/pull_from_body/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/mob/living/carbon/human/owner = make_character(center)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/cape = make_item(/obj/item/clothing/cloak/cape, 1, center)
	TEST_ASSERT(wear_cloak(owner, cape), "Could not put the cape on.")
	var/datum/component/rune_insured/policy = seal(cape, owner)

	record.pull_to_vault(center, owner)
	TEST_ASSERT_EQUAL(cape.loc, owner, "Worn cape left the body without include_body.")
	TEST_ASSERT(!policy.vaulted, "Worn cape marked vaulted without include_body.")

	record.pull_to_vault(center, owner, TRUE)
	TEST_ASSERT_NULL(cape.loc, "Worn cape not vaulted with include_body.")
	TEST_ASSERT(policy.vaulted, "Worn cape not marked vaulted with include_body.")
	TEST_ASSERT_NULL(owner.cloak, "Body still lists the vaulted cape.")

/datum/unit_test/rune_insurance/pull_from_carriers

/datum/unit_test/rune_insurance/pull_from_carriers/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/mob/living/carbon/human/owner = make_character(center)
	var/mob/living/carbon/human/stranger = make_character(center)
	var/mob/living/carbon/human/mindless = allocate(/mob/living/carbon/human/species/human/northern, center)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/kept = make_item(/obj/item/clothing/cloak/cape, 1, center)
	var/obj/item/clothing/cloak/cape/taken = make_item(/obj/item/clothing/cloak/cape, 1, center)
	seal(kept, owner)
	seal(taken, owner)
	TEST_ASSERT(stranger.put_in_hands(kept), "Stranger could not hold the cape.")
	TEST_ASSERT(mindless.put_in_hands(taken), "Mindless human could not hold the cape.")

	record.pull_to_vault(center, owner)
	TEST_ASSERT_EQUAL(kept.loc, stranger, "Cape taken from a character's hands.")
	TEST_ASSERT_NULL(taken.loc, "Cape held by a mindless body not vaulted.")
	TEST_ASSERT(!(taken in mindless.held_items), "Mindless body still holds the vaulted cape.")

/datum/unit_test/rune_insurance/pull_from_containers

/datum/unit_test/rune_insurance/pull_from_containers/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/turf/chest_turf = get_step(center, EAST)
	var/mob/living/carbon/human/owner = make_character(center)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)

	var/obj/structure/closet/crate/chest/chest = allocate(/obj/structure/closet/crate/chest, chest_turf)
	var/obj/item/clothing/cloak/cape/chested = make_item(/obj/item/clothing/cloak/cape, 1, center)
	chested.forceMove(chest)

	var/obj/item/storage/backpack/satchel/insured_bag = make_item(/obj/item/storage/backpack/satchel, 1, center)
	var/obj/item/clothing/cloak/cape/bagged = make_item(/obj/item/clothing/cloak/cape, 1, center)
	bagged.forceMove(insured_bag)

	var/obj/item/storage/backpack/satchel/plain_bag = make_item(/obj/item/storage/backpack/satchel, 1, center)
	var/obj/item/clothing/cloak/cape/plain_bagged = make_item(/obj/item/clothing/cloak/cape, 1, center)
	plain_bagged.forceMove(plain_bag)

	seal(chested, owner)
	var/datum/component/rune_insured/insured_bag_policy = seal(insured_bag, owner)
	var/datum/component/rune_insured/bagged_policy = seal(bagged, owner)
	seal(plain_bagged, owner)

	record.pull_to_vault(center, owner)
	TEST_ASSERT_EQUAL(chested.loc, chest, "Cape taken out of a chest.")
	TEST_ASSERT_NULL(insured_bag.loc, "Insured bag not vaulted.")
	TEST_ASSERT(insured_bag_policy.vaulted, "Insured bag not marked vaulted.")
	TEST_ASSERT_EQUAL(bagged.loc, insured_bag, "Cape left its insured bag.")
	TEST_ASSERT(!bagged_policy.vaulted, "Cape in an insured bag vaulted separately.")
	TEST_ASSERT_NULL(plain_bagged.loc, "Cape in an uninsured bag not vaulted.")
	TEST_ASSERT_EQUAL(plain_bag.loc, center, "Uninsured bag moved.")


/datum/unit_test/rune_insurance/claim_standard

/datum/unit_test/rune_insurance/claim_standard/Run()
	var/mob/living/carbon/human/owner = make_character(balance = 1000)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	TEST_ASSERT(!record.request_claim(RUNE_INSURANCE_TIER_STANDARD, owner), "Claim filed on an empty vault.")

	var/obj/item/clothing/cloak/cape/cape = vault_cape(owner, 200)
	TEST_ASSERT_NULL(cape.loc, "Setup: cape not vaulted.")
	TEST_ASSERT(record.request_claim(RUNE_INSURANCE_TIER_STANDARD, owner), "First standard claim refused.")
	TEST_ASSERT_EQUAL(balance_of(owner), 1000, "First standard claim charged.")
	TEST_ASSERT(!record.is_claim_ready(), "Standard claim ready at once.")

	record.claim_ready_at = world.time
	TEST_ASSERT(record.is_claim_ready(), "Claim not ready once its time came.")
	TEST_ASSERT(!record.request_claim(RUNE_INSURANCE_TIER_INSTANT, owner), "Ready claim was sped up.")
	TEST_ASSERT_EQUAL(balance_of(owner), 1000, "Refused speed-up charged.")

/datum/unit_test/rune_insurance/claim_collect_early

/datum/unit_test/rune_insurance/claim_collect_early/Run()
	var/mob/living/carbon/human/owner = make_character(balance = 1000)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/cape = vault_cape(owner, 200)
	var/datum/component/rune_insured/policy = cape.GetComponent(/datum/component/rune_insured)
	TEST_ASSERT(record.request_claim(RUNE_INSURANCE_TIER_STANDARD, owner), "Standard claim refused.")

	TEST_ASSERT_EQUAL(record.collect_claim(owner), 0, "Collected before the claim was ready.")
	TEST_ASSERT_NULL(cape.loc, "Cape left the vault early.")
	TEST_ASSERT(policy.vaulted, "Policy unmarked by an early collection.")
	TEST_ASSERT_EQUAL(record.claim_tier, RUNE_INSURANCE_TIER_STANDARD, "Early collection closed the claim.")

/datum/unit_test/rune_insurance/claim_instant

/datum/unit_test/rune_insurance/claim_instant/Run()
	var/mob/living/carbon/human/owner = make_character(balance = 1000)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/cape = vault_cape(owner, 200)
	var/datum/component/rune_insured/policy = cape.GetComponent(/datum/component/rune_insured)

	var/fee = record.get_claim_fee(RUNE_INSURANCE_TIER_INSTANT)
	TEST_ASSERT_EQUAL(fee, max(CEILING(200 * RUNE_INSURANCE_INSTANT_PERCENT / 100, 1), RUNE_INSURANCE_INSTANT_MIN_FEE), "Instant fee.")
	TEST_ASSERT(record.request_claim(RUNE_INSURANCE_TIER_INSTANT, owner), "Instant claim refused.")
	TEST_ASSERT_EQUAL(balance_of(owner), 1000 - fee, "Instant claim charge.")
	TEST_ASSERT(record.is_claim_ready(), "Instant claim not ready at once.")

	TEST_ASSERT_EQUAL(record.collect_claim(owner), 1, "Collected count.")
	TEST_ASSERT(cape.loc == owner || cape.loc == owner.loc, "Cape not handed to the owner.")
	TEST_ASSERT(!record.has_vaulted_items(), "Vault not empty after collection.")
	TEST_ASSERT_NULL(record.claim_tier, "Claim still open after collection.")
	TEST_ASSERT_EQUAL(length(record.policies), 1, "Policy lost on collection.")
	TEST_ASSERT_EQUAL(cape.GetComponent(/datum/component/rune_insured), policy, "Cape's policy replaced on collection.")
	TEST_ASSERT(!policy.vaulted, "Collected policy still marked vaulted.")

/datum/unit_test/rune_insurance/claim_repeat_fee

/datum/unit_test/rune_insurance/claim_repeat_fee/Run()
	var/mob/living/carbon/human/owner = make_character(balance = 1000)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/cape = vault_cape(owner, 200)
	TEST_ASSERT(record.request_claim(RUNE_INSURANCE_TIER_INSTANT, owner), "First claim refused.")
	TEST_ASSERT_EQUAL(record.collect_claim(owner), 1, "First claim collected count.")

	owner.dropItemToGround(cape)
	TEST_ASSERT_EQUAL(record.pull_to_vault(get_turf(owner), owner), 1, "Cape not vaulted again.")
	var/before = balance_of(owner)
	TEST_ASSERT(record.request_claim(RUNE_INSURANCE_TIER_STANDARD, owner), "Second claim refused.")
	var/repeat_fee = max(CEILING(200 * RUNE_INSURANCE_REPEAT_PERCENT / 100, 1), RUNE_INSURANCE_REPEAT_MIN_FEE)
	TEST_ASSERT_EQUAL(before - balance_of(owner), repeat_fee, "Second standard claim charge.")

/datum/unit_test/rune_insurance/claim_upgrade

/datum/unit_test/rune_insurance/claim_upgrade/Run()
	var/mob/living/carbon/human/owner = make_character(balance = 1000)
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	vault_cape(owner, 200)
	var/express_fee = max(CEILING(200 * RUNE_INSURANCE_EXPRESS_PERCENT / 100, 1), RUNE_INSURANCE_EXPRESS_MIN_FEE)
	var/instant_fee = max(CEILING(200 * RUNE_INSURANCE_INSTANT_PERCENT / 100, 1), RUNE_INSURANCE_INSTANT_MIN_FEE)

	TEST_ASSERT(record.request_claim(RUNE_INSURANCE_TIER_STANDARD, owner), "Standard claim refused.")
	TEST_ASSERT(record.request_claim(RUNE_INSURANCE_TIER_EXPRESS, owner), "Upgrade to express refused.")
	TEST_ASSERT_EQUAL(balance_of(owner), 1000 - express_fee, "Standard to express charge.")
	TEST_ASSERT(!record.is_claim_ready(), "Express claim ready at once.")

	TEST_ASSERT(!record.request_claim(RUNE_INSURANCE_TIER_EXPRESS, owner), "Same tier accepted again.")
	TEST_ASSERT(!record.request_claim(RUNE_INSURANCE_TIER_STANDARD, owner), "Slower tier accepted.")
	TEST_ASSERT_EQUAL(balance_of(owner), 1000 - express_fee, "Refused tier change charged.")
	TEST_ASSERT_EQUAL(record.claim_tier, RUNE_INSURANCE_TIER_EXPRESS, "Refused tier change altered the claim.")

	TEST_ASSERT(record.request_claim(RUNE_INSURANCE_TIER_INSTANT, owner), "Upgrade to instant refused.")
	TEST_ASSERT_EQUAL(balance_of(owner), 1000 - instant_fee, "Express to instant charge.")
	TEST_ASSERT(record.is_claim_ready(), "Instant upgrade not ready at once.")


/datum/unit_test/rune_insurance/policy_ends_on_wear

/datum/unit_test/rune_insurance/policy_ends_on_wear/Run()
	var/mob/living/carbon/human/owner = make_character()
	var/mob/living/carbon/human/other = make_character()
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/cape = make_item(/obj/item/clothing/cloak/cape)
	seal(cape, owner)

	TEST_ASSERT(other.put_in_hands(cape), "Other character could not hold the cape.")
	TEST_ASSERT_NOTNULL(cape.GetComponent(/datum/component/rune_insured), "Holding the cape ended the policy.")
	other.dropItemToGround(cape)

	TEST_ASSERT(wear_cloak(owner, cape), "Owner could not wear the cape.")
	TEST_ASSERT_NOTNULL(cape.GetComponent(/datum/component/rune_insured), "Owner wearing the cape ended the policy.")
	owner.dropItemToGround(cape)

	TEST_ASSERT(wear_cloak(other, cape), "Other character could not wear the cape.")
	TEST_ASSERT_NULL(cape.GetComponent(/datum/component/rune_insured), "Policy survived another character wearing the cape.")
	TEST_ASSERT_EQUAL(length(record.policies), 0, "Ended policy left on the record.")

/datum/unit_test/rune_insurance/policy_ends_on_item_delete

/datum/unit_test/rune_insurance/policy_ends_on_item_delete/Run()
	var/mob/living/carbon/human/owner = make_character()
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/cape = make_item(/obj/item/clothing/cloak/cape)
	seal(cape, owner)
	TEST_ASSERT_EQUAL(length(record.policies), 1, "Setup: policy count.")

	qdel(cape)
	TEST_ASSERT_EQUAL(length(record.policies), 0, "Deleted item's policy left on the record.")

/datum/unit_test/rune_insurance/record_delete

/datum/unit_test/rune_insurance/record_delete/Run()
	var/mob/living/carbon/human/owner = make_character()
	var/datum/rune_insurance_record/record = get_rune_insurance_record(owner.mind)
	var/obj/item/clothing/cloak/cape/vaulted = make_item(/obj/item/clothing/cloak/cape)
	var/obj/item/clothing/cloak/cape/kept = make_item(/obj/item/clothing/cloak/cape)
	var/datum/component/rune_insured/vaulted_policy = seal(vaulted, owner)
	seal(kept, owner)
	TEST_ASSERT(record.vault_item(vaulted_policy), "Setup: cape not vaulted.")

	qdel(record)
	TEST_ASSERT(QDELETED(vaulted), "Vaulted cape survived its record.")
	TEST_ASSERT_NULL(kept.GetComponent(/datum/component/rune_insured), "Loose cape kept its policy.")
	TEST_ASSERT_NULL(owner.mind.rune_insurance, "Mind still points at the deleted record.")
