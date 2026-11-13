/obj/structure/fake_machine/contractledger/antag
	name = "black contract ledger"
	desc = "A hidden ledger whose ink writhes when ordinary eyes try to follow it. Only those already marked as villains can make sense of its pages."
	contract_ledger_id = "antag_contracts"
	taxable = FALSE

/obj/structure/fake_machine/contractledger/antag/proc/get_access_antag_datum(mob/living/carbon/human/user)
	if(!user)
		return null
	return user.mind?.has_antag_datum(/datum/antagonist)

/obj/structure/fake_machine/contractledger/antag/can_user_access_ledger(mob/living/carbon/human/user, show_feedback = FALSE)
	if(!..())
		return FALSE

	if(get_access_antag_datum(user))
		return TRUE

	if(show_feedback)
		to_chat(user, span_warning(get_access_denial_message(user)))
	return FALSE

/obj/structure/fake_machine/contractledger/antag/get_access_denial_message(mob/living/carbon/human/user)
	return "The hidden script recoils from me. This ledger is for antagonists alone."

/obj/structure/fake_machine/contractledger/antag/get_role_label(mob/user)
	var/datum/antagonist/antag_datum = get_access_antag_datum(user)
	if(antag_datum)
		return antag_datum.name
	return "Antagonist"

/obj/structure/fake_machine/contractledger/antag/get_ledger_window_title(mob/user)
	return "Black Contract Ledger"

/obj/structure/fake_machine/contractledger/antag/get_default_contract_issuer_name(mob/living/carbon/human/user)
	return "The Black Ledger"

/obj/structure/fake_machine/contractledger/antag/should_show_handler_contract_advice()
	return FALSE

/obj/structure/fake_machine/contractledger/antag/requires_bank_account_for_contracts(mob/user)
	return FALSE

/obj/structure/fake_machine/contractledger/antag/get_contract_deposit_amount(mob/living/carbon/human/user, datum/quest/attached_quest)
	return 0

/obj/structure/fake_machine/contractledger/antag/is_quest_handler(mob/user)
	return FALSE

/obj/structure/fake_machine/contractledger/antag/is_contract_broker(mob/user)
	return FALSE

/obj/structure/fake_machine/contractledger/antag/is_contract_type_allowed_for_user(mob/user, contract_type)
	return TRUE

/obj/structure/fake_machine/contractledger/antag/get_contract_group_catalog(mob/user)
	var/static/list/antag_contract_groups = list(
		QUEST_GROUP_BOUNTIES = list(QUEST_HUNT, QUEST_CLEAR_OUT, QUEST_RAID, QUEST_BOSS),
	)
	return antag_contract_groups

/obj/structure/fake_machine/contractledger/antag/werewolf
	name = "moon hunt ledger"
	desc = "A thick ledger bound in scarred hide, its pages inked with claw-marks, spoor, and blood. The script only steadies for a true child of the moon."
	contract_ledger_id = "werewolf_contracts"

/obj/structure/fake_machine/contractledger/antag/werewolf/get_access_antag_datum(mob/living/carbon/human/user)
	if(!user)
		return null
	return user.mind?.has_antag_datum(/datum/antagonist/werewolf)

/obj/structure/fake_machine/contractledger/antag/werewolf/get_access_denial_message(mob/living/carbon/human/user)
	return "The moon hunt ledger will only open its pages to werewolves."

/obj/structure/fake_machine/contractledger/antag/werewolf/get_ledger_window_title(mob/user)
	return "Moon Hunt Ledger"

/obj/structure/fake_machine/contractledger/antag/werewolf/get_default_contract_issuer_name(mob/living/carbon/human/user)
	return "The Moon Hunt"

/obj/structure/fake_machine/contractledger/antag/werewolf/get_contract_group_catalog(mob/user)
	var/static/list/werewolf_contract_groups = list(
		QUEST_GROUP_BOUNTIES = list(QUEST_HUNT, QUEST_CLEAR_OUT, QUEST_RAID),
	)
	return werewolf_contract_groups

/obj/structure/fake_machine/contractledger/antag/werewolf/can_issue_quest_compass(mob/living/carbon/human/user)
	return FALSE

/obj/structure/fake_machine/contractledger/antag/werewolf/issue_quest_compass(mob/living/carbon/human/user)
	set_session_notice(user, "notice.compass_carried", "warning")
	to_chat(user, span_notice("The moon hunt offers no compass. I must use Moon Hunt and Sniff Trail instead."))
	return FALSE

/obj/structure/fake_machine/contractledger/antag/werewolf/create_contract_token(mob/living/carbon/human/user, datum/quest/attached_quest)
	if(!attached_quest)
		return null

	var/datum/antagonist/werewolf/werewolf_antag = get_access_antag_datum(user)
	if(!werewolf_antag)
		return null

	var/obj/item/paper/scroll/quest/werewolf_hidden/hidden_scroll = new(null, werewolf_antag)
	hidden_scroll.assigned_quest = attached_quest
	attached_quest.quest_scroll = hidden_scroll
	attached_quest.quest_scroll_ref = WEAKREF(hidden_scroll)
	hidden_scroll.sync_receiver_to_current_owner(user)
	return hidden_scroll

/obj/structure/fake_machine/contractledger/antag/werewolf/on_contract_token_issued(mob/living/carbon/human/user, datum/quest/attached_quest, obj/item/paper/scroll/quest/spawned_scroll)
	var/datum/antagonist/werewolf/werewolf_antag = get_access_antag_datum(user)
	var/obj/item/paper/scroll/quest/werewolf_hidden/hidden_scroll = spawned_scroll
	if(!werewolf_antag || !istype(hidden_scroll))
		return ..()

	hidden_scroll.update_quest_text()
	werewolf_antag.set_tracked_werewolf_contract_scroll(hidden_scroll)
	to_chat(user, span_notice("The contract sinks into instinct. Use Moon Hunt to review it and Sniff Trail to follow the scent."))

/obj/structure/fake_machine/contractledger/antag/werewolf/can_turn_in_any_contract(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(!can_user_access_ledger(user))
		return FALSE

	var/datum/antagonist/werewolf/werewolf_antag = get_access_antag_datum(user)
	if(!werewolf_antag)
		return FALSE

	werewolf_antag.sync_werewolf_contract_assignments()
	return !!werewolf_antag.get_turn_in_werewolf_contract_scroll()

/obj/structure/fake_machine/contractledger/antag/werewolf/can_abandon_any_contract(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(!can_user_access_ledger(user))
		return FALSE

	var/datum/antagonist/werewolf/werewolf_antag = get_access_antag_datum(user)
	if(!werewolf_antag)
		return FALSE

	werewolf_antag.sync_werewolf_contract_assignments()
	return !!werewolf_antag.get_abandonable_werewolf_contract_scroll()

/obj/structure/fake_machine/contractledger/antag/werewolf/turn_in_contract(mob/user, obj/item/paper/scroll/quest/scroll_in_hand)
	if(scroll_in_hand)
		return ..()
	if(!can_user_access_ledger(user, TRUE))
		return

	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user))
		return

	var/datum/antagonist/werewolf/werewolf_antag = get_access_antag_datum(human_user)
	if(!werewolf_antag)
		return

	werewolf_antag.sync_werewolf_contract_assignments()
	var/obj/item/paper/scroll/quest/werewolf_hidden/turn_in_target = werewolf_antag.get_turn_in_werewolf_contract_scroll()
	if(!turn_in_target)
		set_session_notice(human_user, "notice.no_completed_contract", "warning")
		return

	turn_in_scroll(human_user, turn_in_target)

/obj/structure/fake_machine/contractledger/antag/werewolf/abandon_contract(mob/user)
	if(!can_user_access_ledger(user, TRUE))
		return

	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user))
		return

	var/datum/antagonist/werewolf/werewolf_antag = get_access_antag_datum(human_user)
	if(!werewolf_antag)
		return

	werewolf_antag.sync_werewolf_contract_assignments()
	var/obj/item/paper/scroll/quest/werewolf_hidden/abandon_target = werewolf_antag.get_abandonable_werewolf_contract_scroll()
	if(!abandon_target)
		set_session_notice(human_user, "notice.no_scroll_input", "warning")
		to_chat(human_user, span_warning("No active moon-hunt contract is ready to abandon."))
		return

	abandon_scroll(human_user, abandon_target)

/obj/structure/fake_machine/contractledger/antag/werewolf/get_contract_objective_score(datum/quest/quest)
	var/effective_tier = quest?.threat_tier || quest?.requested_tier || QUEST_TIER_ROUTINE
	effective_tier = clamp(effective_tier, QUEST_TIER_ROUTINE, QUEST_TIER_MYTHIC)
	return WW_CONTRACT_SCORE_BASE + ((effective_tier - QUEST_TIER_ROUTINE) * WW_CONTRACT_SCORE_STEP)

/obj/structure/fake_machine/contractledger/antag/werewolf/on_contract_completed(mob/living/carbon/human/user, datum/quest/completed_quest, reward, original_reward, tax_amt)
	var/objective_score = completed_quest?.objective_score_reward || get_contract_objective_score(completed_quest)
	if(objective_score <= 0)
		return

	var/datum/antagonist/werewolf/werewolf_antag = user?.mind?.has_antag_datum(/datum/antagonist/werewolf)
	if(!werewolf_antag)
		return

	werewolf_antag.add_contract_objective_score(objective_score)
