GLOBAL_LIST_EMPTY(claimed_quest_compass_users)
GLOBAL_LIST_EMPTY(contract_ledgers)
GLOBAL_LIST_EMPTY(quest_preview_icon_states_cache)
GLOBAL_LIST_EMPTY(quest_preview_state_cache)
GLOBAL_VAR_INIT(quest_preview_preload_bootstrapped, FALSE)

/obj/effect/abstract/contract_preview_proxy
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/obj/structure/fake_machine/contractledger
	name = "Grand Contract Ledger"
	desc = "A massive ledger book with gilded edges, sitting atop a pedestal with the Mercenary's Guild banner. Its myriad enchanted pages are filled with various contracts and bounties issued by Mercenary's Guild, with arcane scripts that appears and fades as contracts are issued and completed."
	icon = 'icons/obj/questing.dmi'
	icon_state = "contractledger"
	density = TRUE
	anchored = TRUE
	max_integrity = 0
	obj_flags = CAN_BE_HIT | USES_TGUI
	layer = GAME_PLANE_UPPER
	var/input_point
	var/contract_ledger_id = "guild_contracts"
	var/list/ui_sessions
	var/list/ui_opening_lock
	var/taxable = TRUE

/obj/structure/fake_machine/contractledger/Initialize()
	. = ..()
	GLOB.contract_ledgers += src
	input_point = locate(x, y - 1, z)
	var/obj/effect/decal/marker_export/marker = new(get_turf(input_point))
	marker.desc = "Place completed contract scrolls here to turn them in."
	marker.layer = ABOVE_OBJ_LAYER
	return INITIALIZE_HINT_LATELOAD

/obj/structure/fake_machine/contractledger/Destroy()
	GLOB.contract_ledgers -= src
	return ..()

/obj/structure/fake_machine/contractledger/LateInitialize()
	if(GLOB.quest_preview_preload_bootstrapped)
		return
	GLOB.quest_preview_preload_bootstrapped = TRUE
	INVOKE_ASYNC(src, PROC_REF(ensure_global_preview_preload_state), null)
	var/datum/asset/spritesheet/quest_previews/spritesheet = get_asset_datum(/datum/asset/spritesheet/quest_previews)
	spritesheet.generate_quest_sprites()

/obj/structure/fake_machine/contractledger/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user))
		return
	if(!can_user_access_ledger(user, TRUE))
		return
	ui_interact(user)

/obj/structure/fake_machine/contractledger/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(istype(P, /obj/item/paper/scroll/quest/pledge))
		var/obj/item/paper/scroll/quest/pledge/pledge = P
		if(!supports_quest_postings())
			to_chat(user, span_warning("This ledger does not accept public commissions."))
			return
		if(!is_quest_handler(user))
			to_chat(user, span_warning("Only a quest handler can post a sealed pledge."))
			return
		pledge.post_to_ledger(user, src)
		return
	. = ..()
	if(istype(P, /obj/item/paper/scroll/quest))
		if(!can_user_access_ledger(user, TRUE))
			return
		turn_in_contract(user, P)
	return

/obj/structure/fake_machine/contractledger/Topic(href, href_list)
	. = ..()
	if(!ishuman(usr))
		return
	var/action_id = href_list["ledger_action"]
	if(action_id)
		handle_ledger_action(usr, action_id)

/obj/structure/fake_machine/contractledger/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/fake_machine/contractledger/ui_interact(mob/user, datum/tgui/ui)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	if(!can_user_access_ledger(human_user, TRUE))
		return FALSE
	var/datum/asset/spritesheet/quest_previews/spritesheet = get_asset_datum(/datum/asset/spritesheet/quest_previews)
	if(!spritesheet.sprites_generated)
		to_chat(user, span_notice("Loading quest assets..."))
	spritesheet.send(user)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(LAZYACCESS(ui_opening_lock, REF(user)))
			return TRUE
		LAZYSET(ui_opening_lock, REF(user), TRUE)
		ui = new(user, src, get_ledger_interface_name(user), get_ledger_window_title(user), 1040, 700)
		ui.open()
		LAZYREMOVE(ui_opening_lock, REF(user))
	return TRUE

/obj/structure/fake_machine/contractledger/ui_close(mob/user)
	. = ..()
	clear_ui_session(user)

/obj/structure/fake_machine/contractledger/proc/can_user_access_ledger(mob/living/carbon/human/user, show_feedback = FALSE)
	if(!ishuman(user))
		return FALSE
	return TRUE

/obj/structure/fake_machine/contractledger/proc/get_access_denial_message(mob/living/carbon/human/user)
	return "The ledger refuses me."

/obj/structure/fake_machine/contractledger/ui_data(mob/living/carbon/human/user)
	var/list/session = get_ui_session_raw(user)
	var/consult_block_reason = get_consult_block_reason(user)
	var/can_consult_contracts = can_user_access_ledger(user) && !consult_block_reason

	var/selected_group = session["selected_group"]
	var/selected_type = session["selected_type"]
	var/selected_tier = session["selected_tier"] || 0

	var/list/preview_state
	if(can_consult_contracts)
		preview_state = get_contract_preview_state(user, selected_type, selected_tier)
	else
		preview_state = list(
			"title_key" = "preview.possible_targets",
			"entries" = list(),
			"message_key" = "preview.choose_type",
			"hidden_count" = 0,
		)

	var/list/notice_state = get_session_notice_state_raw(session)

	var/datum/asset/spritesheet/quest_previews/spritesheet = get_asset_datum(/datum/asset/spritesheet/quest_previews)
	var/spritesheet_css_url = spritesheet.css_filename()

	return list(
		"title" = "Grand Contract Ledger",
		"spritesheet_css" = spritesheet_css_url,
		"role_label" = get_role_label(user),
		"is_handler" = is_quest_handler(user),
		"supports_postings" = supports_quest_postings(),
		"has_bank_account" = has_bank_account(user),
		"active_contract_count" = get_active_contract_count(user),
		"contract_limit" = get_contract_limit(user),
		"consult_block_reason_key" = consult_block_reason,
		"can_consult_contracts" = can_consult_contracts,
		"can_take_contract" = can_take_selected_contract(user, selected_type, selected_tier),
		"can_claim_compass" = can_issue_quest_compass(user),
		"has_claimed_compass" = has_claimed_quest_compass(user),
		"has_quest_compass" = has_user_quest_compass(user),
		"can_turn_in_contract" = can_turn_in_any_contract(user),
		"can_abandon_contract" = can_abandon_any_contract(user),
		"can_print_contracts" = is_quest_handler(user),
		"compass_action_key" = get_compass_action_key(user),
		"selected_group" = selected_group,
		"selected_type" = selected_type,
		"selected_tier" = selected_tier,
		"group_options" = get_group_option_data(user, selected_group),
		"type_options" = get_type_option_data(user, selected_group, selected_type),
		"tier_options" = get_tier_option_data(selected_type, selected_tier),
		"draft_summary" = get_contract_draft_summary(selected_type, selected_tier),
		"preview_title_key" = preview_state["title_key"],
		"preview_entries" = preview_state["entries"],
		"preview_message_key" = preview_state["message_key"],
		"preview_hidden_count" = preview_state["hidden_count"],
		"posted_contracts" = get_posted_contract_data(user),
		"managed_commissions" = get_managed_commission_data(user),
		"notice" = notice_state,
	)

/obj/structure/fake_machine/contractledger/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/user = usr
	if(!ishuman(user))
		return FALSE
	if(!can_user_access_ledger(user, TRUE))
		return FALSE

	switch(action)
		if("consultcontracts")
			prepare_contract_draft(user)
			return TRUE
		if("select_group")
			set_selected_group(user, params["group"])
			return TRUE
		if("select_type")
			set_selected_type(user, params["contract_type"])
			return TRUE
		if("select_tier")
			set_selected_tier(user, text2num(params["tier"]))
			return TRUE
		if("takecontract")
			return create_selected_contract(user)
		if("claim_posted_contract")
			return claim_posted_contract(user, params["quest_ref"])
		if("validate_commission")
			return validate_commission(user, params["quest_ref"])
		if("getcompass")
			return issue_quest_compass(user)
		if("turnincontract")
			turn_in_contract(user)
			return TRUE
		if("abandoncontract")
			abandon_contract(user)
			return TRUE
		if("printcontracts")
			print_contracts(user)
			return TRUE
	return FALSE

/obj/structure/fake_machine/contractledger/proc/handle_ledger_action(mob/living/carbon/human/user, action_id)
	if(!ishuman(user))
		return FALSE
	if(!can_user_access_ledger(user, TRUE))
		return FALSE

	switch(action_id)
		if("consultcontracts")
			prepare_contract_draft(user)
		if("getcompass")
			issue_quest_compass(user)
		if("turnincontract")
			turn_in_contract(user)
		if("abandoncontract")
			abandon_contract(user)
		if("printcontracts")
			print_contracts(user)
		else
			return FALSE
	return TRUE

/obj/structure/fake_machine/contractledger/proc/get_ui_session_key(mob/user)
	if(!user)
		return null
	return REF(user)

/obj/structure/fake_machine/contractledger/proc/clear_ui_session(mob/user)
	var/session_key = get_ui_session_key(user)
	if(!session_key || !ui_sessions)
		return
	ui_sessions -= session_key
	if(!length(ui_sessions))
		ui_sessions = null

/obj/structure/fake_machine/contractledger/proc/get_ui_session_raw(mob/living/carbon/human/user)
	var/session_key = get_ui_session_key(user)
	if(!session_key)
		return list()

	LAZYINITLIST(ui_sessions)
	var/list/session = ui_sessions[session_key]
	if(!islist(session))
		session = list()
		ui_sessions[session_key] = session
	return session

/obj/structure/fake_machine/contractledger/proc/sanitize_ui_session(mob/living/carbon/human/user, list/session)
	var/list/group_values = get_available_contract_group_values_cached(user, session)
	var/selected_group = session["selected_group"]
	if(!length(group_values))
		selected_group = null
	else if(!(selected_group in group_values))
		selected_group = group_values[1]
	session["selected_group"] = selected_group

	var/list/type_values = get_available_contract_type_values_cached(user, selected_group, session)
	var/selected_type = session["selected_type"]
	if(!length(type_values))
		selected_type = null
	else if(!(selected_type in type_values))
		selected_type = type_values[1]
	session["selected_type"] = selected_type

	var/list/tier_values = get_tier_values_for_contract(selected_type)
	var/selected_tier = session["selected_tier"] || 0
	if(!length(tier_values))
		selected_tier = 0
	else if(!(selected_tier in tier_values))
		selected_tier = tier_values[1]
	session["selected_tier"] = selected_tier

	if(session["cached_group"] != selected_group)
		session["cached_group"] = selected_group
		session["cached_type_values"] = null

/obj/structure/fake_machine/contractledger/proc/get_session_notice_state_raw(list/session)
	var/notice_key = session["notice_key"]
	if(!notice_key)
		return null
	return list(
		"key" = notice_key,
		"type" = session["notice_type"] || "notice",
		"args" = session["notice_args"] || list(),
	)

/obj/structure/fake_machine/contractledger/proc/set_session_notice(mob/living/carbon/human/user, notice_key, notice_type = "notice", list/notice_args = null)
	if(!user)
		return
	var/list/session = get_ui_session_raw(user)
	session["notice_key"] = notice_key
	session["notice_type"] = notice_type
	session["notice_args"] = notice_args || list()

/obj/structure/fake_machine/contractledger/proc/get_available_contract_group_values_cached(mob/user, list/session)
	if(islist(session["cached_group_values"]))
		return session["cached_group_values"]
	var/list/group_values = get_available_contract_group_values(user)
	session["cached_group_values"] = group_values
	return group_values

/obj/structure/fake_machine/contractledger/proc/get_available_contract_type_values_cached(mob/user, contract_group, list/session)
	if(session["cached_group"] == contract_group && islist(session["cached_type_values"]))
		return session["cached_type_values"]
	var/list/type_values = get_available_contract_type_values(user, contract_group)
	session["cached_group"] = contract_group
	session["cached_type_values"] = type_values
	return type_values

/obj/structure/fake_machine/contractledger/proc/invalidate_session_type_cache(list/session)
	session["cached_group_values"] = null
	session["cached_group"] = null
	session["cached_type_values"] = null

/// Populates GLOB.quest_preview_state_cache with metadata for all quest types/tiers.
/obj/structure/fake_machine/contractledger/proc/ensure_global_preview_preload_state(mob/living/carbon/human/user)
	if(length(GLOB.quest_preview_state_cache))
		return

	var/list/seen_types = list()

	for(var/contract_group in GLOB.global_quest_contract_groups)
		var/list/group_contract_types = GLOB.global_quest_contract_groups[contract_group] || list()
		for(var/contract_type in group_contract_types)
			if(contract_type in seen_types)
				continue
			seen_types += contract_type
			if(!quest_contract_targets_creatures(contract_type))
				continue

			var/datum/quest/quest_template = create_quest_for_type(contract_type)
			if(!istype(quest_template, /datum/quest/kill))
				if(quest_template)
					qdel(quest_template)
				continue

			var/datum/quest/kill/kill_template = quest_template
			var/list/tier_choices = kill_template.get_tier_choices()
			for(var/tier_label in tier_choices)
				var/tier_value = tier_choices[tier_label]
				kill_template.requested_tier = tier_value
				var/preview_key = get_preview_cache_key(contract_type, tier_value)
				var/list/cache_entry = list(
					"targets" = list(),
					"message_key" = "preview.no_valid",
				)
				GLOB.quest_preview_state_cache[preview_key] = cache_entry

				var/list/candidate_pool = kill_template.get_candidate_target_pool()
				if(!length(candidate_pool))
					continue

				cache_entry["message_key"] = null
				for(var/mob_type in candidate_pool)
					cache_entry["targets"] += list(list(
						"mob_type" = mob_type,
						"risk" = kill_template.get_mob_risk_value(mob_type),
						"spawn_weight" = kill_template.get_mob_spawn_weight(mob_type),
						"group_min" = kill_template.get_mob_group_min(mob_type),
						"group_max" = kill_template.get_mob_group_max(mob_type),
					))

			qdel(kill_template)

/obj/structure/fake_machine/contractledger/proc/get_compass_claimant(mob/living/carbon/human/user)
	if(!user)
		return null
	return user.mind ? user.mind : user

/obj/structure/fake_machine/contractledger/proc/has_claimed_quest_compass(mob/living/carbon/human/user)
	var/datum/claimant = get_compass_claimant(user)
	if(!claimant)
		return FALSE

	for(var/datum/weakref/claim_ref in GLOB.claimed_quest_compass_users.Copy())
		var/datum/resolved_claimant = claim_ref.resolve()
		if(!resolved_claimant)
			GLOB.claimed_quest_compass_users -= claim_ref
			qdel(claim_ref)
			continue
		if(resolved_claimant == claimant)
			return TRUE

	return FALSE

/obj/structure/fake_machine/contractledger/proc/mark_quest_compass_claimed(mob/living/carbon/human/user)
	var/datum/claimant = get_compass_claimant(user)
	if(!claimant || has_claimed_quest_compass(user))
		return FALSE
	GLOB.claimed_quest_compass_users += WEAKREF(claimant)
	return TRUE

/obj/structure/fake_machine/contractledger/proc/has_user_quest_compass(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	for(var/obj/item/quest_compass/quest_compass in user.GetAllContents(/obj/item/quest_compass))
		return TRUE
	return FALSE

/obj/structure/fake_machine/contractledger/proc/can_issue_quest_compass(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(!can_user_access_ledger(user))
		return FALSE
	if(has_claimed_quest_compass(user))
		return FALSE
	if(has_user_quest_compass(user))
		return FALSE
	return TRUE

/obj/structure/fake_machine/contractledger/proc/get_compass_action_key(mob/living/carbon/human/user)
	if(has_user_quest_compass(user))
		return "compass.action.carried"
	if(has_claimed_quest_compass(user))
		return "compass.action.claimed"
	return "compass.action.get"

/obj/structure/fake_machine/contractledger/proc/get_active_contract_count(mob/user)
	if(!user)
		return 0
	// Guild roles hand their contracts out as givers, so their limit counts those too.
	var/count_issued = is_boss_raid_issuer(user)
	var/quest_count = 0
	for(var/obj/item/paper/scroll/quest/quest_scroll in GLOB.quest_scrolls)
		var/datum/quest/quest = quest_scroll.assigned_quest
		if(!quest || quest.complete || !can_accept_contract_quest(quest))
			continue
		if(quest.quest_receiver_reference?.resolve() == user)
			quest_count++
		else if(count_issued && !quest.player_commission && quest.quest_giver_reference?.resolve() == user)
			quest_count++
	return quest_count

/obj/structure/fake_machine/contractledger/proc/get_contract_limit(mob/user)
	if(is_boss_raid_issuer(user))
		return 6
	return 2

/obj/structure/fake_machine/contractledger/proc/get_contract_ledger_id()
	return contract_ledger_id

/obj/structure/fake_machine/contractledger/proc/get_default_contract_issuer_name(mob/living/carbon/human/user)
	return "The Mercenary's Guild"

/obj/structure/fake_machine/contractledger/proc/should_show_handler_contract_advice()
	return TRUE

/obj/structure/fake_machine/contractledger/proc/can_accept_contract_quest(datum/quest/quest)
	if(!istype(quest))
		return FALSE
	return quest.can_turn_in_at_ledger(src)

/obj/structure/fake_machine/contractledger/proc/supports_quest_postings()
	return type == /obj/structure/fake_machine/contractledger && get_contract_ledger_id() == "guild_contracts"

/obj/structure/fake_machine/contractledger/proc/get_posted_contract_data(mob/living/carbon/human/user)
	var/list/entries = list()
	if(!supports_quest_postings() || !SSquestboard)
		return entries
	for(var/datum/quest/posted_quest as anything in SSquestboard.get_all_posted_quests())
		if(!can_accept_contract_quest(posted_quest) || !posted_quest.is_visible_to(user))
			continue
		entries += list(list(
			"ref" = REF(posted_quest),
			"title" = posted_quest.get_title(),
			"objective" = posted_quest.get_objective_text(),
			"location" = posted_quest.get_location_text(),
			"group" = posted_quest.contract_group,
			"type" = posted_quest.player_commission ? posted_quest.commission_type : posted_quest.quest_type,
			"tier" = posted_quest.threat_tier,
			"reward" = posted_quest.reward_amount,
			"deposit" = posted_quest.deposit_amount,
			"issuer" = posted_quest.quest_giver_name,
			"player_commission" = posted_quest.player_commission,
			"expires_in" = posted_quest.expiry_time ? max(0, round((posted_quest.expiry_time - world.time) / 10)) : 0,
			"can_claim" = can_claim_posted_contract(user, posted_quest),
		))
	return entries

/obj/structure/fake_machine/contractledger/proc/get_managed_commission_data(mob/living/carbon/human/user)
	var/list/entries = list()
	if(!supports_quest_postings() || !is_quest_handler(user))
		return entries
	for(var/obj/item/paper/scroll/quest/quest_scroll as anything in GLOB.quest_scrolls)
		var/datum/quest/custom/commission = quest_scroll.assigned_quest
		if(!istype(commission) || commission.complete || !can_accept_contract_quest(commission))
			continue
		entries += list(list(
			"ref" = REF(commission),
			"title" = commission.get_title(),
			"objective" = commission.get_objective_text(),
			"assignee" = commission.quest_receiver_name,
			"type" = commission.commission_type,
			"tier" = commission.threat_tier,
			"can_validate" = commission.requires_steward_validation,
		))
	return entries

/obj/structure/fake_machine/contractledger/proc/can_claim_posted_contract(mob/living/carbon/human/user, datum/quest/posted_quest)
	if(!supports_quest_postings() || !posted_quest || posted_quest.complete || !SSquestboard.is_posted(posted_quest))
		return FALSE
	if(get_consult_block_reason(user) || !can_accept_contract_quest(posted_quest))
		return FALSE
	return posted_quest.can_claim(user)

/obj/structure/fake_machine/contractledger/proc/find_active_commission(commission_ref)
	if(!commission_ref)
		return null
	for(var/obj/item/paper/scroll/quest/quest_scroll as anything in GLOB.quest_scrolls)
		var/datum/quest/custom/commission = quest_scroll.assigned_quest
		if(istype(commission) && REF(commission) == commission_ref)
			return commission
	return null

/obj/structure/fake_machine/contractledger/proc/validate_commission(mob/living/carbon/human/user, commission_ref)
	if(!supports_quest_postings() || !is_quest_handler(user))
		return FALSE
	var/datum/quest/custom/commission = find_active_commission(commission_ref)
	if(!commission || !can_accept_contract_quest(commission) || commission.complete)
		return FALSE
	if(!commission.requires_steward_validation)
		commission.on_validate_fail(user)
		return FALSE
	if(!commission.validate(user, input_point, src))
		commission.on_validate_fail(user)
		return FALSE
	set_session_notice(user, "notice.commission_validated", "success")
	return TRUE

/obj/structure/fake_machine/contractledger/proc/requires_bank_account_for_contracts(mob/user)
	return TRUE

/obj/structure/fake_machine/contractledger/proc/has_bank_account(mob/user)
	if(!user)
		return FALSE
	return (user in SStreasury.bank_accounts)

/obj/structure/fake_machine/contractledger/proc/get_role_label(mob/user)
	if(!user)
		return "Unknown"
	if(user.job)
		return user.job
	return "Contractor"

/obj/structure/fake_machine/contractledger/proc/get_ui_language(mob/user)
	var/client/user_client = user?.client
	var/stored_language = null
	if(user_client && islist(user_client.vars) && ("preferred_ui_language" in user_client.vars))
		stored_language = user_client.vars["preferred_ui_language"]
	if(!stored_language)
		stored_language = "en"
	var/selected_language = LOWER_TEXT("[stored_language]")
	if(!(selected_language in list("en", "ru")))
		return "en"
	return selected_language

/obj/structure/fake_machine/contractledger/proc/get_ledger_interface_name(mob/user)
	return get_ui_language(user) == "ru" ? "ContractLedgerRu" : "ContractLedger"

/obj/structure/fake_machine/contractledger/proc/get_ledger_window_title(mob/user)
	return get_ui_language(user) == "ru" ? "Книга Контрактов" : "Grand Contract Ledger"

/obj/structure/fake_machine/contractledger/proc/is_quest_handler(mob/user)
	if(!user)
		return FALSE
	var/datum/job/mob_job = user.job ? SSjob.GetJob(user.job) : null
	if(!mob_job)
		return FALSE
	if(mob_job.is_quest_giver)
		return TRUE
	return istype(mob_job, /datum/job/waterdeep_merchant) || istype(mob_job, /datum/job/waterdeep_banker) || istype(mob_job, /datum/job/innkeep)

/// Brokers issue contracts as the giver, so another person can claim the scroll and work it.
/obj/structure/fake_machine/contractledger/proc/is_contract_broker(mob/user)
	return is_quest_handler(user) || is_boss_raid_issuer(user)

/obj/structure/fake_machine/contractledger/proc/get_assigned_job(mob/user)
	var/datum/job/assigned_job = user?.mind?.assigned_role
	if(istype(assigned_job, /datum/job))
		return assigned_job
	return null

/obj/structure/fake_machine/contractledger/proc/get_visible_job(mob/user)
	if(!user?.job)
		return null
	var/datum/job/visible_job = SSjob.GetJob(user.job)
	if(istype(visible_job, /datum/job))
		return visible_job
	return null

/obj/structure/fake_machine/contractledger/proc/is_adventurers_guild_role(datum/job/job_type)
	return istype(job_type, /datum/job/adventurers_guildmaster) || \
		istype(job_type, /datum/job/advclass/adventurers_guildmaster) || \
		istype(job_type, /datum/job/adventurers_assistant)

/obj/structure/fake_machine/contractledger/proc/is_townhall_contract_role(datum/job/job_type)
	return istype(job_type, /datum/job/burgmeister) || \
		istype(job_type, /datum/job/councilor)

/obj/structure/fake_machine/contractledger/proc/is_banker_contract_role(datum/job/job_type)
	return is_banker_job(job_type)

/obj/structure/fake_machine/contractledger/proc/is_boss_raid_issuer(mob/user)
	if(!user)
		return FALSE
	var/datum/job/assigned_job = get_assigned_job(user)
	if(is_adventurers_guild_role(assigned_job) || is_townhall_contract_role(assigned_job) || is_banker_contract_role(assigned_job))
		return TRUE
	var/datum/job/visible_job = get_visible_job(user)
	if(is_adventurers_guild_role(visible_job) || is_townhall_contract_role(visible_job) || is_banker_contract_role(visible_job))
		return TRUE
	return FALSE

/obj/structure/fake_machine/contractledger/proc/get_consult_block_reason(mob/living/carbon/human/user)
	if(!user)
		return "consult.no_user"
	if(requires_bank_account_for_contracts(user) && !has_bank_account(user))
		return "consult.no_account"
	var/quest_number = get_active_contract_count(user)
	var/max_quests_for_job = get_contract_limit(user)
	if(quest_number >= max_quests_for_job)
		return "consult.limit_reached"
	return null

/obj/structure/fake_machine/contractledger/proc/get_contract_group_catalog(mob/user)
	return GLOB.global_quest_contract_groups

/obj/structure/fake_machine/contractledger/proc/get_available_contract_group_values(mob/user)
	var/list/group_values = list()
	var/list/contract_groups = get_contract_group_catalog(user)
	for(var/contract_group in contract_groups)
		if(length(get_available_contract_type_values(user, contract_group)))
			group_values += contract_group
	return group_values

/obj/structure/fake_machine/contractledger/proc/get_available_contract_type_values(mob/user, contract_group)
	var/list/type_values = list()
	if(!contract_group)
		return type_values

	var/list/contract_groups = get_contract_group_catalog(user)
	var/list/group_types = contract_groups[contract_group] || list()
	for(var/contract_type in group_types)
		if(!is_contract_type_allowed_for_user(user, contract_type))
			continue
		var/datum/quest/template = create_quest_for_type(contract_type)
		if(!template)
			continue
		if(!template.can_generate_for_world())
			qdel(template)
			continue
		type_values += contract_type
		qdel(template)

	return type_values

/obj/structure/fake_machine/contractledger/proc/is_contract_type_allowed_for_user(mob/user, contract_type)
	if((contract_type in list(QUEST_RAID, QUEST_BOSS)) && !is_boss_raid_issuer(user))
		return FALSE
	if(quest_contract_uses_taker_pool(contract_type) && !carnal_contract_type_allowed_for(contract_type, user))
		return FALSE
	return TRUE

/obj/structure/fake_machine/contractledger/proc/get_tier_values_for_contract(contract_type)
	var/list/tier_values = list()
	if(!contract_type)
		return tier_values
	var/datum/quest/template = create_quest_for_type(contract_type)
	if(!template)
		return tier_values
	var/list/tier_choices = template.get_tier_choices()
	for(var/tier_label in tier_choices)
		tier_values += tier_choices[tier_label]
	qdel(template)
	return tier_values

/obj/structure/fake_machine/contractledger/proc/create_quest_for_type(contract_type)
	var/quest_path = GLOB.global_quest_registry[contract_type]
	if(!quest_path)
		return null
	return new quest_path

/obj/structure/fake_machine/contractledger/proc/prepare_contract_draft(mob/living/carbon/human/user)
	var/list/session = get_ui_session_raw(user)
	invalidate_session_type_cache(session)
	sanitize_ui_session(user, session)
	set_session_notice(user, "notice.choose_contract", "notice")

/obj/structure/fake_machine/contractledger/proc/set_selected_group(mob/living/carbon/human/user, selected_group)
	var/list/session = get_ui_session_raw(user)
	session["selected_group"] = selected_group
	session["selected_type"] = null
	session["selected_tier"] = 0
	invalidate_session_type_cache(session)
	sanitize_ui_session(user, session)

/obj/structure/fake_machine/contractledger/proc/set_selected_type(mob/living/carbon/human/user, selected_type)
	var/list/session = get_ui_session_raw(user)
	session["selected_type"] = selected_type
	session["selected_tier"] = 0
	sanitize_ui_session(user, session)

/obj/structure/fake_machine/contractledger/proc/set_selected_tier(mob/living/carbon/human/user, selected_tier)
	var/list/session = get_ui_session_raw(user)
	session["selected_tier"] = selected_tier
	sanitize_ui_session(user, session)

/obj/structure/fake_machine/contractledger/proc/get_group_option_data(mob/living/carbon/human/user, selected_group)
	var/list/entries = list()
	var/list/session = get_ui_session_raw(user)
	for(var/contract_group in get_available_contract_group_values_cached(user, session))
		entries += list(list(
			"id" = contract_group,
			"selected" = contract_group == selected_group,
		))
	return entries

/obj/structure/fake_machine/contractledger/proc/get_type_option_data(mob/living/carbon/human/user, selected_group, selected_type)
	var/list/entries = list()
	var/list/session = get_ui_session_raw(user)
	for(var/contract_type in get_available_contract_type_values_cached(user, selected_group, session))
		var/datum/quest/template = create_quest_for_type(contract_type)
		if(!template)
			continue
		entries += list(list(
			"id" = contract_type,
			"minimum_tier" = template.minimum_tier,
			"maximum_tier" = template.maximum_tier,
			"selected" = contract_type == selected_type,
		))
		qdel(template)
	return entries

/obj/structure/fake_machine/contractledger/proc/get_tier_option_data(contract_type, selected_tier)
	var/list/entries = list()
	if(!contract_type)
		return entries
	var/datum/quest/template = create_quest_for_type(contract_type)
	if(!template)
		return entries
	var/list/tier_choices = template.get_tier_choices()
	for(var/tier_label in tier_choices)
		var/tier_value = tier_choices[tier_label]
		entries += list(list(
			"id" = tier_value,
			"selected" = tier_value == selected_tier,
		))
	qdel(template)
	return entries

/obj/structure/fake_machine/contractledger/proc/get_contract_draft_summary(contract_type, selected_tier)
	if(!contract_type)
		return list(
			"title" = "No contract selected",
			"description" = "Choose a contract group and contract type to preview it.",
			"tier_label" = null,
		)
	var/datum/quest/template = create_quest_for_type(contract_type)
	if(!template)
		return list(
			"title" = "Invalid contract",
			"description" = "The selected contract type could not be prepared.",
			"tier_label" = null,
		)
	var/list/summary = list(
		"title" = "[template.quest_type] Contract",
		"description" = get_contract_type_description(contract_type),
		"tier_label" = selected_tier ? template.get_tier_label(selected_tier) : null,
		"group_label" = template.contract_group,
		"type_id" = contract_type,
		"group_id" = template.contract_group,
		"tier_value" = selected_tier,
	)
	qdel(template)
	return summary

/obj/structure/fake_machine/contractledger/proc/get_contract_type_description(contract_type)
	switch(contract_type)
		if(QUEST_RETRIEVAL)
			return "Recover lost or planted items and return them to the guild."
		if(QUEST_COURIER)
			return "Deliver a marked parcel from the pickup site to its destination."
		if(QUEST_HUNT)
			return "Track down a routine hostile target or a small pack."
		if(QUEST_CLEAR_OUT)
			return "Purge a hostile cluster from a known region."
		if(QUEST_RAID)
			return "Take on a heavy hostile force in organized numbers."
		if(QUEST_BOSS)
			return "Hunt a singular elite threat with a much higher payout."
		if(QUEST_FLUID_HARVEST)
			return "Bring back a creature's own seed or nectar, collected by any means."
		if(QUEST_EGG_HARVEST)
			return "Bring back unhatched eggs from an egg-laying creature."
		if(QUEST_SATE_MARK)
			return "Wear creatures down to a lustful collapse, then tie a guild ribbon on each."
	return "Unknown contract."

/obj/structure/fake_machine/contractledger/proc/can_take_selected_contract(mob/living/carbon/human/user, contract_type, selected_tier)
	if(!can_user_access_ledger(user))
		return FALSE
	if(get_consult_block_reason(user))
		return FALSE
	if(!contract_type || !selected_tier)
		return FALSE
	var/list/session = get_ui_session_raw(user)
	if(!(contract_type in get_available_contract_type_values_cached(user, session["selected_group"], session)))
		return FALSE
	return TRUE

/obj/structure/fake_machine/contractledger/proc/get_preview_cache_key(contract_type, selected_tier)
	return "[contract_type]#[selected_tier]"

/obj/structure/fake_machine/contractledger/proc/get_contract_preview_state(mob/living/carbon/human/user, contract_type, selected_tier)
	var/list/preview_state = list(
		"title_key" = "preview.possible_targets",
		"entries" = list(),
		"message_key" = "preview.choose_type",
		"hidden_count" = 0,
	)

	if(!contract_type)
		return preview_state

	if(!quest_contract_targets_creatures(contract_type))
		preview_state["title_key"] = "preview.contract"
		preview_state["message_key"] = "preview.non_hunt"
		return preview_state

	if(!selected_tier)
		preview_state["message_key"] = "preview.choose_tier"
		return preview_state

	var/uses_taker_pool = quest_contract_uses_taker_pool(contract_type)
	var/preview_cache_key = get_preview_cache_key(contract_type, selected_tier)
	var/list/cached_entry = uses_taker_pool ? null : GLOB.quest_preview_state_cache[preview_cache_key]
	if(islist(cached_entry))
		var/list/cached_targets = cached_entry["targets"]
		if(!length(cached_targets))
			preview_state["message_key"] = cached_entry["message_key"] || "preview.no_valid"
			return preview_state
		var/list/entries = build_cached_preview_entries(cached_targets)
		var/hidden_count = max(length(entries) - 8, 0)
		if(hidden_count)
			entries.Cut(9)
		preview_state["entries"] = entries
		preview_state["message_key"] = null
		preview_state["hidden_count"] = hidden_count
		return preview_state

	var/list/entries = get_target_preview_entries(contract_type, selected_tier, uses_taker_pool ? user : null)
	if(!length(entries))
		preview_state["message_key"] = "preview.no_valid"
		return preview_state

	var/hidden_count = max(length(entries) - 8, 0)
	if(hidden_count)
		entries.Cut(9)
	preview_state["entries"] = entries
	preview_state["message_key"] = null
	preview_state["hidden_count"] = hidden_count
	return preview_state

/obj/structure/fake_machine/contractledger/proc/build_cached_preview_entries(list/cached_targets)
	var/list/entries = list()
	if(!islist(cached_targets))
		return entries
	for(var/target_index = 1, target_index <= length(cached_targets), target_index++)
		var/list/target_data = cached_targets[target_index]
		if(!islist(target_data))
			continue
		var/mob_type = target_data["mob_type"]
		var/list/entry = list(
			"id" = "[mob_type]",
			"name" = get_target_preview_name(mob_type),
			"risk" = target_data["risk"],
			"spawn_weight" = target_data["spawn_weight"],
			"group_min" = target_data["group_min"],
			"group_max" = target_data["group_max"],
			"icon_class" = get_preview_sprite_class(mob_type),
		)
		insert_preview_entry(entries, entry)
	return entries

/obj/structure/fake_machine/contractledger/proc/get_target_preview_entries(contract_type, selected_tier, mob/living/carbon/human/taker)
	var/list/entries = list()
	var/datum/quest/quest_template = create_quest_for_type(contract_type)
	if(!istype(quest_template, /datum/quest/kill))
		if(quest_template)
			qdel(quest_template)
		return entries

	var/datum/quest/kill/kill_template = quest_template
	kill_template.requested_tier = selected_tier
	if(taker)
		kill_template.prepare_for_issuer(taker)
	var/list/candidate_pool = kill_template.get_candidate_target_pool()

	for(var/mob_type in candidate_pool)
		var/list/entry = list(
			"id" = "[mob_type]",
			"name" = get_target_preview_name(mob_type),
			"risk" = kill_template.get_mob_risk_value(mob_type),
			"spawn_weight" = kill_template.get_mob_spawn_weight(mob_type),
			"group_min" = kill_template.get_mob_group_min(mob_type),
			"group_max" = kill_template.get_mob_group_max(mob_type),
			"icon_class" = get_preview_sprite_class(mob_type),
		)
		insert_preview_entry(entries, entry)

	qdel(kill_template)
	return entries

/obj/structure/fake_machine/contractledger/proc/insert_preview_entry(list/entries, list/new_entry)
	var/insert_at = length(entries) + 1
	var/new_name = new_entry["name"] || ""
	for(var/index = 1, index <= length(entries), index++)
		var/list/existing_entry = entries[index]
		if(!islist(existing_entry))
			continue
		var/existing_name = existing_entry["name"] || ""
		if(new_entry["spawn_weight"] > existing_entry["spawn_weight"])
			insert_at = index
			break
		if(new_entry["spawn_weight"] == existing_entry["spawn_weight"] && new_entry["risk"] > existing_entry["risk"])
			insert_at = index
			break
		if(new_entry["spawn_weight"] == existing_entry["spawn_weight"] && new_entry["risk"] == existing_entry["risk"] && sorttext(new_name, existing_name) < 0)
			insert_at = index
			break
	entries.len++
	for(var/index = entries.len, index > insert_at, index--)
		entries[index] = entries[index - 1]
	entries[insert_at] = new_entry

/obj/structure/fake_machine/contractledger/proc/get_target_preview_name(atom/mob_type)
	if(ispath(mob_type))
		if(ispath(mob_type, /mob/living/carbon/human/species/orc))
			return "Orc"
		if(ispath(mob_type, /mob/living/carbon/human/species/zizombie))
			return "Zombie"
		if(ispath(mob_type, /mob/living/carbon/human/species/goblin))
			return "Goblin"
		if(ispath(mob_type, /mob/living/carbon/human/species/skeleton))
			return "Skeleton"
		if(uses_outlaw_preview(mob_type))
			return "OUTLAW"
		return initial(mob_type.name) || "Unknown target"
	return "Unknown target"

/obj/structure/fake_machine/contractledger/proc/uses_monster_model_preview(atom/mob_type)
	return ispath(mob_type, /mob/living/carbon/human/species/goblin) || \
		ispath(mob_type, /mob/living/carbon/human/species/kobold) || \
		ispath(mob_type, /mob/living/carbon/human/species/zizombie) || \
		ispath(mob_type, /mob/living/carbon/human/species/skeleton) || \
		ispath(mob_type, /mob/living/carbon/human/species/orc)

/obj/structure/fake_machine/contractledger/proc/uses_outlaw_preview(atom/mob_type)
	if(!ispath(mob_type, /mob/living/carbon/human))
		return FALSE
	return !uses_monster_model_preview(mob_type)

/obj/structure/fake_machine/contractledger/proc/get_preview_icon_source_mob_type(atom/mob_type)
	return mob_type

/obj/structure/fake_machine/contractledger/proc/get_preview_sprite_class(mob_type)
	var/source = get_preview_icon_source_mob_type(mob_type)
	var/sprite_name = quest_preview_sprite_name(source)
	if(!sprite_name)
		return null
	var/datum/asset/spritesheet/quest_previews/spritesheet = get_asset_datum(/datum/asset/spritesheet/quest_previews)
	return spritesheet.icon_class_name(sprite_name)

/obj/structure/fake_machine/contractledger/proc/get_target_preview_icon_file(atom/mob_type)
	if(!ispath(mob_type))
		return null
	return initial(mob_type.icon)

/obj/structure/fake_machine/contractledger/proc/get_target_preview_icon_state(atom/mob_type)
	if(!ispath(mob_type))
		return null
	if(ispath(mob_type, /mob/living/simple_animal))
		return get_simple_animal_preview_icon_state(mob_type)
	return initial(mob_type.icon_state)

/obj/structure/fake_machine/contractledger/proc/get_simple_animal_preview_icon_state(mob/living/simple_animal/mob_type)
	if(ispath(mob_type, /mob/living/simple_animal/hostile/retaliate/wolf))
		// Wolf sets icon_state in Initialize() — initial "vv" doesn't exist in DMI
		return "volf_brown"
	return initial(mob_type.icon_living) || initial(mob_type.icon_state)

/obj/structure/fake_machine/contractledger/proc/get_preview_icon_states(icon_file)
	if(!icon_file)
		return null
	var/cache_key = "[icon_file]"
	var/list/cached_states = GLOB.quest_preview_icon_states_cache[cache_key]
	if(cached_states)
		return cached_states
	cached_states = icon_states(icon_file)
	GLOB.quest_preview_icon_states_cache[cache_key] = cached_states
	return cached_states

/obj/structure/fake_machine/contractledger/proc/is_valid_preview_icon_state(icon_file, icon_state)
	if(!icon_file || !icon_state)
		return FALSE
	var/list/available_states = get_preview_icon_states(icon_file)
	return islist(available_states) && (icon_state in available_states)

/obj/structure/fake_machine/contractledger/proc/build_target_preview_icon(atom/mob_type, icon_file, icon_state)
	if(!ispath(mob_type) || !icon_file || !icon_state)
		return null
	if(!is_valid_preview_icon_state(icon_file, icon_state))
		return null
	var/icon/preview_icon = icon(icon_file, icon_state, SOUTH, 1)
	if(!preview_icon)
		return null
	if(ispath(mob_type, /mob/living/carbon/human))
		var/icon/human_preview_icon = icon()
		human_preview_icon.Insert(preview_icon, dir = SOUTH)
		preview_icon = human_preview_icon
	return preview_icon

/obj/structure/fake_machine/contractledger/proc/fit_preview_icon_to_square(icon/preview_icon, canvas_size = 64)
	if(!preview_icon)
		return null
	var/icon/fitted_icon = icon(preview_icon)
	var/icon_width = max(fitted_icon.Width(), 1)
	var/icon_height = max(fitted_icon.Height(), 1)
	var/scale_ratio = min(canvas_size / icon_width, canvas_size / icon_height)
	var/scaled_width = max(round(icon_width * scale_ratio), 1)
	var/scaled_height = max(round(icon_height * scale_ratio), 1)
	if(scaled_width != icon_width || scaled_height != icon_height)
		fitted_icon.Scale(scaled_width, scaled_height)
	var/icon/canvas_icon = icon(fitted_icon)
	canvas_icon.Scale(canvas_size, canvas_size)
	canvas_icon.ChangeOpacity(0)
	var/x_offset = round((canvas_size - scaled_width) / 2) + 1
	var/y_offset = round((canvas_size - scaled_height) / 2) + 1
	canvas_icon.Blend(fitted_icon, ICON_OVERLAY, x_offset, y_offset)
	return canvas_icon

/obj/structure/fake_machine/contractledger/proc/crop_outlaw_preview_icon(icon/preview_icon)
	if(!preview_icon)
		return null
	var/icon/outlaw_icon = icon(preview_icon)
	var/icon_width = max(outlaw_icon.Width(), 1)
	var/icon_height = max(outlaw_icon.Height(), 1)
	var/crop_bottom = max(round(icon_height * 0.45), 1)
	outlaw_icon.Crop(1, crop_bottom, icon_width, icon_height)
	return fit_preview_icon_to_square(outlaw_icon, 64)

/obj/structure/fake_machine/contractledger/proc/build_outlaw_preview_icon(icon_file, icon_state)
	if(!icon_file || !icon_state)
		return null
	if(!is_valid_preview_icon_state(icon_file, icon_state))
		return null
	var/icon/preview_icon = icon(icon_file, icon_state, SOUTH, 1)
	if(!preview_icon)
		return null
	return crop_outlaw_preview_icon(preview_icon)

/obj/structure/fake_machine/contractledger/proc/finalize_preview_mob(mob/temp_mob)
	if(!temp_mob)
		return
	temp_mob.after_creation()
	if(istype(temp_mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/temp_human = temp_mob
		temp_human.regenerate_icons()

/obj/structure/fake_machine/contractledger/proc/finalize_outlaw_preview_mob(mob/living/carbon/human/temp_human)
	if(!temp_human || QDELETED(temp_human))
		return
	temp_human.after_creation()
	temp_human.update_body()
	temp_human.regenerate_icons()

/obj/structure/fake_machine/contractledger/proc/build_outlaw_runtime_preview_icon(mob/living/carbon/human/temp_human)
	if(!temp_human)
		return null
	temp_human.update_inv_hands(hide_experimental = TRUE)
	temp_human.update_inv_belt(hide_experimental = TRUE)
	temp_human.update_inv_back(hide_experimental = TRUE)
	temp_human.update_inv_head(hide_nonstandard = TRUE)
	var/was_typing = temp_human.typing
	if(was_typing)
		temp_human.set_typing_indicator(FALSE)
	var/image/dummy = image(temp_human.icon, temp_human, temp_human.icon_state, temp_human.layer, temp_human.dir)
	dummy.appearance = temp_human.appearance
	dummy.dir = SOUTH
	temp_human.update_inv_hands()
	temp_human.update_inv_belt()
	temp_human.update_inv_back()
	temp_human.update_inv_head()
	if(was_typing)
		temp_human.set_typing_indicator(TRUE)
	var/icon/preview_icon = getFlatIcon(dummy, SOUTH, no_anim = TRUE)
	if(!preview_icon)
		return null
	return crop_outlaw_preview_icon(preview_icon)

/obj/structure/fake_machine/contractledger/proc/build_preview_proxy_icon(mob/temp_mob)
	var/turf/preview_turf = get_turf(temp_mob)
	if(!preview_turf)
		return null
	var/obj/effect/abstract/contract_preview_proxy/render_proxy = new(preview_turf)
	render_proxy.icon = temp_mob.icon
	render_proxy.icon_state = temp_mob.icon_state
	render_proxy.dir = SOUTH
	render_proxy.color = temp_mob.color
	render_proxy.alpha = temp_mob.alpha
	render_proxy.pixel_x = temp_mob.pixel_x
	render_proxy.pixel_y = temp_mob.pixel_y
	if(length(temp_mob.overlays))
		render_proxy.overlays = temp_mob.overlays.Copy()
	if(length(temp_mob.underlays))
		render_proxy.underlays = temp_mob.underlays.Copy()
	render_proxy.transform = temp_mob.transform
	var/icon/flattened_icon = getFlatIcon(render_proxy, SOUTH, no_anim = TRUE)
	qdel(render_proxy)
	if(!flattened_icon)
		return null
	return icon(flattened_icon, frame = 1)

/obj/structure/fake_machine/contractledger/proc/get_runtime_target_preview_icon_data(atom/mob_type)
	if(!ispath(mob_type, /mob))
		return null
	var/turf/preview_turf = locate(1, 1, 1)
	if(!preview_turf)
		preview_turf = get_turf(src)
	if(!preview_turf)
		return null

	var/mob/temp_mob = new mob_type(preview_turf)
	if(!temp_mob)
		return null
	temp_mob.setDir(SOUTH)

	var/icon/preview_icon
	if(istype(temp_mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/temp_human = temp_mob
		if(uses_outlaw_preview(mob_type))
			finalize_outlaw_preview_mob(temp_human)
			preview_icon = build_outlaw_runtime_preview_icon(temp_human)
		else
			finalize_preview_mob(temp_human)
			preview_icon = build_preview_proxy_icon(temp_human)
			if(!preview_icon)
				var/icon/flattened_icon = getFlatIcon(temp_human, SOUTH, no_anim = TRUE)
				preview_icon = flattened_icon ? icon(flattened_icon, frame = 1) : null
	else
		finalize_preview_mob(temp_mob)
		var/icon/flattened_icon = getFlatIcon(temp_mob, SOUTH, no_anim = TRUE)
		preview_icon = flattened_icon ? icon(flattened_icon, frame = 1) : null

	var/icon_file = temp_mob.icon
	var/icon_state = temp_mob.icon_state
	var/preview_name = temp_mob.name || initial(mob_type.name) || "Unknown target"
	qdel(temp_mob)

	if(icon_state && !is_valid_preview_icon_state(icon_file, icon_state))
		icon_state = null

	return list(
		"name" = preview_name,
		"icon" = icon_file,
		"icon_state" = icon_state,
		"preview_icon" = preview_icon,
	)

/obj/structure/fake_machine/contractledger/proc/issue_quest_compass(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(has_user_quest_compass(user))
		set_session_notice(user, "notice.compass_carried", "warning")
		to_chat(user, span_notice("You already carry a quest compass."))
		return FALSE
	if(has_claimed_quest_compass(user))
		set_session_notice(user, "notice.compass_already_claimed", "warning")
		to_chat(user, span_warning("The ledger will not attune another quest compass to you."))
		return FALSE
	var/obj/item/quest_compass/new_compass = new(get_turf(user))
	mark_quest_compass_claimed(user)
	user.put_in_hands(new_compass)
	set_session_notice(user, "notice.compass_attuned", "success")
	to_chat(user, span_notice("The ledger attunes a quest compass to you. Use it on a contract scroll to link it."))
	return TRUE

/obj/structure/fake_machine/contractledger/proc/can_turn_in_any_contract(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(!can_user_access_ledger(user))
		return FALSE
	for(var/obj/item/paper/scroll/quest/held_scroll in user.GetAllContents(/obj/item/paper/scroll/quest))
		if(can_offer_turn_in(user, held_scroll))
			return TRUE
	for(var/obj/item/paper/scroll/quest/floor_scroll in input_point)
		if(can_offer_turn_in(user, floor_scroll))
			return TRUE
	return FALSE

/// Turn-in is offered for a ready contract, and for an unfinished goods contract so the ledger can say what is missing.
/obj/structure/fake_machine/contractledger/proc/can_offer_turn_in(mob/user, obj/item/paper/scroll/quest/scroll)
	var/datum/quest/quest = scroll.assigned_quest
	if(!quest || !(user in scroll.get_quest_assignees(user, TRUE)) || !can_accept_contract_quest(quest))
		return FALSE
	return is_quest_ready_to_turn_in(quest, user) || quest.uses_turn_in_goods()

/obj/structure/fake_machine/contractledger/proc/is_quest_ready_to_turn_in(datum/quest/quest, mob/user)
	if(!quest)
		return FALSE
	return quest.complete || quest.has_turn_in_goods(input_point, user)

/obj/structure/fake_machine/contractledger/proc/can_abandon_any_contract(mob/living/carbon/human/user)
	if(!user)
		return FALSE
	if(!can_user_access_ledger(user))
		return FALSE
	return !!get_abandonable_scroll(user)

/// The user's own unfinished scroll on the marked area, else one in their hands.
/obj/structure/fake_machine/contractledger/proc/get_abandonable_scroll(mob/user)
	var/list/obj/item/paper/scroll/quest/candidates = list()
	for(var/obj/item/paper/scroll/quest/floor_scroll in input_point)
		candidates += floor_scroll
	var/obj/item/paper/scroll/quest/active_scroll = user.get_active_held_item()
	if(istype(active_scroll))
		candidates += active_scroll
	for(var/obj/item/paper/scroll/quest/held_scroll in user.held_items)
		candidates |= held_scroll
	for(var/obj/item/paper/scroll/quest/candidate as anything in candidates)
		var/datum/quest/quest = candidate.assigned_quest
		if(quest && !quest.complete && (user in candidate.get_quest_assignees(user, TRUE)) && can_accept_contract_quest(quest))
			return candidate
	return null

/obj/structure/fake_machine/contractledger/proc/get_contract_deposit_amount(mob/living/carbon/human/user, datum/quest/attached_quest)
	if(!attached_quest)
		return 0
	return attached_quest.calculate_deposit(attached_quest.reward_amount)

/obj/structure/fake_machine/contractledger/proc/charge_contract_deposit(mob/living/carbon/human/user, datum/quest/attached_quest)
	if(!attached_quest)
		return FALSE
	if(attached_quest.deposit_amount <= 0)
		return TRUE
	if(SStreasury.bank_accounts[user] < attached_quest.deposit_amount)
		set_session_notice(user, "notice.insufficient_funds", "warning", list("amount" = attached_quest.deposit_amount))
		to_chat(user, span_warning("Insufficient balance funds. You need [attached_quest.deposit_amount] amna in your meister."))
		return FALSE

	var/deposit_charged = attached_quest.deposit_amount
	SStreasury.bank_accounts[user] -= deposit_charged
	SStreasury.treasury_value += deposit_charged
	SStreasury.log_entries += "+[deposit_charged] to treasury (quest deposit)"
	return TRUE

/obj/structure/fake_machine/contractledger/proc/get_contract_objective_score(datum/quest/quest)
	return 0

/obj/structure/fake_machine/contractledger/proc/on_contract_completed(mob/living/carbon/human/user, datum/quest/completed_quest, reward, original_reward, tax_amt)
	return

/obj/structure/fake_machine/contractledger/proc/show_wrong_ledger_notice(mob/living/carbon/human/user, datum/quest/quest)
	var/target_ledger_name = quest?.get_turn_in_ledger_name() || "its proper ledger"
	to_chat(user, span_warning("This contract belongs to [target_ledger_name], not [src.name]."))

/obj/structure/fake_machine/contractledger/proc/create_selected_contract(mob/living/carbon/human/user)
	if(!can_user_access_ledger(user, TRUE))
		return FALSE
	var/block_reason = get_consult_block_reason(user)
	if(block_reason)
		set_session_notice(user, block_reason, "warning")
		to_chat(user, span_warning("The ledger refuses to issue a contract right now."))
		return FALSE

	var/list/session = get_ui_session_raw(user)
	var/selected_group = session["selected_group"]
	var/type_selection = session["selected_type"]
	var/selected_tier = session["selected_tier"] || 0

	if(!selected_group || !type_selection || !selected_tier)
		set_session_notice(user, "notice.choose_all_fields", "warning")
		return FALSE

	if(!(selected_group in get_available_contract_group_values(user)))
		set_session_notice(user, "notice.group_unavailable", "warning")
		return FALSE

	if(!(type_selection in get_available_contract_type_values(user, selected_group)))
		set_session_notice(user, "notice.type_unavailable", "warning")
		return FALSE

	var/datum/quest/attached_quest = create_quest_for_type(type_selection)
	if(!attached_quest)
		set_session_notice(user, "notice.invalid_contract", "warning")
		to_chat(user, span_warning("Invalid quest type selected!"))
		return FALSE

	attached_quest.requested_tier = selected_tier
	attached_quest.prepare_for_issuer(user)

	if(is_contract_broker(user))
		attached_quest.quest_giver_name = user.real_name
		attached_quest.quest_giver_reference = WEAKREF(user)
	else
		attached_quest.quest_receiver_reference = WEAKREF(user)
		attached_quest.quest_receiver_name = user.real_name

	var/obj/effect/landmark/quest_spawner/chosen_landmark = find_quest_landmark(attached_quest.requested_tier, type_selection)
	if(!chosen_landmark)
		set_session_notice(user, "notice.no_location", "warning")
		to_chat(user, span_warning("No suitable location found for this contract!"))
		qdel(attached_quest)
		return FALSE

	if(!attached_quest.generate(chosen_landmark))
		set_session_notice(user, "notice.generate_failed", "warning")
		to_chat(user, span_warning("Failed to generate quest content!"))
		qdel(attached_quest)
		return FALSE

	// Calculate distance bonus: distance from this ledger to the quest spawn point
	var/turf/ledger_turf = get_turf(src)
	var/turf/landmark_turf = get_turf(chosen_landmark)
	if(ledger_turf && landmark_turf)
		attached_quest.calculate_distance_bonus(ledger_turf, landmark_turf)

	// Try to set up a quest ambush on one of the spawned mobs (no extra reward)
	attached_quest.try_setup_quest_ambush(chosen_landmark)

	var/obj/item/paper/scroll/quest/spawned_scroll = create_contract_token(user, attached_quest)
	if(!spawned_scroll)
		set_session_notice(user, "notice.invalid_contract", "warning")
		to_chat(user, span_warning("The ledger fails to bind this contract to a quest token."))
		qdel(attached_quest)
		return FALSE

	attached_quest.reward_amount = attached_quest.calculate_reward(get_turf(chosen_landmark))
	attached_quest.deposit_amount = get_contract_deposit_amount(user, attached_quest)
	attached_quest.on_issued_from_ledger(src, user)
	spawned_scroll.base_icon_state = attached_quest.get_scroll_icon()

	if(!charge_contract_deposit(user, attached_quest))
		attached_quest.quest_scroll = null
		attached_quest.quest_scroll_ref = null
		attached_quest.deposit_amount = 0
		spawned_scroll.assigned_quest = null
		qdel(spawned_scroll)
		qdel(attached_quest)
		return FALSE

	on_contract_token_issued(user, attached_quest, spawned_scroll)
	log_quest(user.ckey, user.mind, user, "Take [attached_quest.quest_type]")

	set_session_notice(user, "notice.issued_contract", "success", list(
		"contract_type" = attached_quest.quest_type,
		"tier" = attached_quest.requested_tier,
		"deposit" = attached_quest.deposit_amount,
	))
	return TRUE

/obj/structure/fake_machine/contractledger/proc/claim_posted_contract(mob/living/carbon/human/user, quest_ref)
	var/datum/quest/posted_quest = SSquestboard?.find_posted_quest(quest_ref)
	if(!can_claim_posted_contract(user, posted_quest))
		set_session_notice(user, "notice.posting_unavailable", "warning")
		return FALSE

	posted_quest.deposit_amount = get_contract_deposit_amount(user, posted_quest)
	var/obj/item/paper/scroll/quest/spawned_scroll = create_contract_token(user, posted_quest)
	if(!spawned_scroll)
		set_session_notice(user, "notice.invalid_contract", "warning")
		return FALSE
	spawned_scroll.base_icon_state = posted_quest.get_scroll_icon()

	if(!charge_contract_deposit(user, posted_quest))
		posted_quest.quest_scroll = null
		posted_quest.quest_scroll_ref = null
		spawned_scroll.assigned_quest = null
		qdel(spawned_scroll)
		return FALSE

	if(!SSquestboard.remove_quest(posted_quest))
		if(posted_quest.deposit_amount > 0)
			SStreasury.bank_accounts[user] += posted_quest.deposit_amount
			SStreasury.treasury_value -= posted_quest.deposit_amount
		posted_quest.quest_scroll = null
		posted_quest.quest_scroll_ref = null
		spawned_scroll.assigned_quest = null
		qdel(spawned_scroll)
		return FALSE

	SSquestboard.on_posting_claimed(posted_quest)
	posted_quest.on_claim(user)
	posted_quest.on_issued_from_ledger(src, user)
	on_contract_token_issued(user, posted_quest, spawned_scroll)
	log_quest(user.ckey, user.mind, user, "Claim posted [posted_quest.quest_type]")
	set_session_notice(user, "notice.claimed_posting", "success", list(
		"contract_type" = posted_quest.player_commission ? posted_quest.commission_type : posted_quest.quest_type,
		"deposit" = posted_quest.deposit_amount,
	))
	return TRUE

/obj/structure/fake_machine/contractledger/proc/create_contract_token(mob/living/carbon/human/user, datum/quest/attached_quest)
	if(!attached_quest)
		return null

	var/obj/item/paper/scroll/quest/spawned_scroll = new(get_turf(src))
	spawned_scroll.assigned_quest = attached_quest
	attached_quest.quest_scroll = spawned_scroll
	attached_quest.quest_scroll_ref = WEAKREF(spawned_scroll)
	return spawned_scroll

/obj/structure/fake_machine/contractledger/proc/on_contract_token_issued(mob/living/carbon/human/user, datum/quest/attached_quest, obj/item/paper/scroll/quest/spawned_scroll)
	if(!user || !attached_quest || !spawned_scroll)
		return

	user.put_in_hands(spawned_scroll)
	spawned_scroll.update_quest_text()
	attached_quest.issue_contract_kit(user)

/obj/structure/fake_machine/contractledger/proc/find_quest_landmark(contract_tier, contract_type)
	var/list/exact_landmarks = list()
	var/list/exact_clean_landmarks = list()
	var/list/closest_landmarks = list()
	var/list/closest_clean_landmarks = list()
	var/best_gap = INFINITY
	var/prefer_clean_landmarks = contract_type == QUEST_BOSS
	var/datum/quest/template = create_quest_for_type(contract_type)
	var/landmark_types = template ? template.get_landmark_contract_types() : contract_type
	var/check_supported_map = template && (contract_type in list(QUEST_RETRIEVAL, QUEST_COURIER))

	GLOB.quest_landmarks_list = shuffle(GLOB.quest_landmarks_list)
	for(var/obj/effect/landmark/quest_spawner/landmark in GLOB.quest_landmarks_list)
		if(!landmark.supports_contract_type(landmark_types))
			continue
		if(check_supported_map && !template.is_supported_map_turf(get_turf(landmark)))
			continue

		var/has_clients_around = FALSE
		for(var/mob/M in get_hearers_in_view(world.view, landmark))
			if(!M.client)
				continue
			has_clients_around = TRUE

		if(has_clients_around)
			continue

		// Apply map-based quest weight: starter maps get more easy quests, fewer hard ones
		var/datum/quest_map_config/landmark_config = get_quest_map_config_for_turf(get_turf(landmark))
		var/landmark_weight = 1.0
		if(landmark_config)
			if(contract_tier <= QUEST_TIER_RISKY)
				landmark_weight = landmark_config.easy_quest_weight
			else if(contract_tier <= QUEST_TIER_DEADLY)
				landmark_weight = landmark_config.medium_quest_weight
			else
				landmark_weight = landmark_config.hard_quest_weight
		var/is_clean_landmark = !prefer_clean_landmarks || !landmark_has_nearby_ambient_mobs(landmark)
		// pickweight rolls whole numbers, so map weights such as 0.5 and 1.6 become 5 and 16.
		var/pick_weight = max(1, round(landmark_weight * 10, 1))

		if(landmark.supports_contract_tier(contract_tier))
			exact_landmarks[landmark] = pick_weight
			if(is_clean_landmark)
				exact_clean_landmarks[landmark] = pick_weight
			continue

		var/tier_gap = landmark.get_tier_gap(contract_tier)
		if(tier_gap < best_gap)
			best_gap = tier_gap
			closest_landmarks = list()
			closest_clean_landmarks = list()
		if(tier_gap == best_gap)
			closest_landmarks[landmark] = pick_weight
			if(is_clean_landmark)
				closest_clean_landmarks[landmark] = pick_weight

	if(template)
		qdel(template)

	if(length(exact_clean_landmarks))
		return pickweight(exact_clean_landmarks)
	if(length(exact_landmarks))
		return pickweight(exact_landmarks)
	if(length(closest_clean_landmarks))
		return pickweight(closest_clean_landmarks)
	if(length(closest_landmarks))
		return pickweight(closest_landmarks)
	return null

/obj/structure/fake_machine/contractledger/proc/landmark_has_nearby_ambient_mobs(obj/effect/landmark/quest_spawner/landmark)
	if(!landmark)
		return FALSE
	for(var/mob/living/nearby_mob in view(7, landmark))
		if(QDELETED(nearby_mob) || nearby_mob.stat == DEAD || nearby_mob.client)
			continue
		if(nearby_mob.has_faction("quest"))
			continue
		return TRUE
	return FALSE

/obj/structure/fake_machine/contractledger/proc/turn_in_contract(mob/user, obj/item/paper/scroll/quest/scroll_in_hand)
	if(!can_user_access_ledger(user, TRUE))
		return
	if(scroll_in_hand)
		var/list/mob/quest_assignees = scroll_in_hand.get_quest_assignees(user, TRUE)
		if(!(user in quest_assignees))
			set_session_notice(user, "notice.not_assigned", "warning")
			to_chat(user, span_warning("You are not the assigned quest receiver for this contract!"))
			return
		if(!can_accept_contract_quest(scroll_in_hand.assigned_quest))
			show_wrong_ledger_notice(user, scroll_in_hand.assigned_quest)
			return
		turn_in_scroll(user, scroll_in_hand)
	else
		for(var/obj/item/paper/scroll/quest/held_scroll in user.GetAllContents(/obj/item/paper/scroll/quest))
			var/list/mob/held_assignees = held_scroll.get_quest_assignees(user, TRUE)
			if(!(user in held_assignees) || !is_quest_ready_to_turn_in(held_scroll.assigned_quest, user) || !can_accept_contract_quest(held_scroll.assigned_quest))
				continue
			turn_in_scroll(user, held_scroll)
			return

		for(var/obj/item/paper/scroll/quest/floor_scroll in input_point)
			var/list/mob/quest_assignees = floor_scroll.get_quest_assignees(user, TRUE)
			if(!(user in quest_assignees) || !can_accept_contract_quest(floor_scroll.assigned_quest))
				continue
			turn_in_scroll(user, floor_scroll)
			return

		// Nothing is ready, so a carried goods contract reports what the ledger still lacks.
		for(var/obj/item/paper/scroll/quest/held_scroll in user.GetAllContents(/obj/item/paper/scroll/quest))
			if(held_scroll.assigned_quest?.uses_turn_in_goods() && can_offer_turn_in(user, held_scroll))
				turn_in_scroll(user, held_scroll)
				return

	set_session_notice(user, "notice.no_completed_contract", "warning")

/obj/structure/fake_machine/contractledger/proc/turn_in_scroll(mob/user, obj/item/paper/scroll/quest/scroll)
	var/reward = 0
	var/original_reward = 0
	var/tax_rate = SStreasury.tax_value
	var/tax_amt = 0
	var/datum/quest/completed_quest = scroll?.assigned_quest

	if(!completed_quest)
		set_session_notice(user, "notice.scroll_no_contract", "warning")
		to_chat(user, span_warning("This scroll doesn't have an assigned contract!"))
		return

	if(!can_accept_contract_quest(completed_quest))
		show_wrong_ledger_notice(user, completed_quest)
		return

	if(!completed_quest.complete)
		completed_quest.try_collect_turn_in_goods(input_point, user)
		if(!completed_quest.complete && completed_quest.uses_turn_in_goods())
			to_chat(user, span_warning(completed_quest.get_turn_in_goods_report(input_point, user)))

	if(completed_quest?.complete)
		var/base_reward = completed_quest.reward_amount
		original_reward += base_reward

		// 5% chance to drop a stat ring for Deadly-tier kill quests
		if(completed_quest.threat_tier == QUEST_TIER_DEADLY && prob(5))
			var/obj/item/clothing/ring/gold/quest_deadly_prize/deadly_ring = new(get_turf(user))
			user.put_in_hands(deadly_ring)
			to_chat(user, span_boldnotice("Among the contract spoils, you find [deadly_ring]!"))

		var/brokered = !completed_quest.player_commission && is_brokered_turn_in(user, completed_quest)
		if(brokered && is_boss_raid_issuer(user))
			reward += ROUND_UP(base_reward * QUEST_HANDLER_REWARD_MULTIPLIER)
		else if(brokered && is_quest_handler(user))
			reward += ROUND_UP(base_reward * QUEST_MINOR_HANDLER_REWARD_MULTIPLIER)
		else
			reward += base_reward
		reward = min(reward, completed_quest.get_reward_cap())

		// Only the earned reward is taxed; the deposit was the contractor's own coin.
		if(taxable)
			tax_amt = round(tax_rate * reward)
			if(tax_amt > 0)
				reward -= tax_amt
				SStreasury.give_money_treasury(tax_amt, "quest completion tax - [src.name]")
				record_featured_stat(FEATURED_STATS_TAX_PAYERS, user, tax_amt)
				record_round_statistic(STATS_TAXES_COLLECTED, tax_amt)

		var/deposit_return = return_completed_deposit(user, completed_quest)
		reward += deposit_return
		original_reward += deposit_return

		on_contract_completed(user, completed_quest, reward, original_reward, tax_amt)
		qdel(completed_quest)
		qdel(scroll)

	if(reward > 0)
		set_session_notice(user, "notice.turn_in_success", "success", list("reward" = round(reward)))
	else
		set_session_notice(user, "notice.turn_in_not_ready", "warning")
	cash_in(user, round(reward), original_reward, tax_amt)

/// TRUE when the giver turns in a contract that someone else claimed and worked.
/obj/structure/fake_machine/contractledger/proc/is_brokered_turn_in(mob/user, datum/quest/completed_quest)
	var/mob/receiver = completed_quest.quest_receiver_reference?.resolve()
	if(!receiver || receiver == user)
		return FALSE
	return completed_quest.quest_giver_reference?.resolve() == user

/// Pays a completed contract's deposit back out of the treasury that holds it; returns the coin owed to the user.
/obj/structure/fake_machine/contractledger/proc/return_completed_deposit(mob/user, datum/quest/completed_quest)
	var/deposit = completed_quest.deposit_amount
	if(deposit <= 0)
		return 0
	completed_quest.deposit_amount = 0
	SStreasury.treasury_value -= deposit
	var/mob/giver = completed_quest.quest_giver_reference?.resolve()
	if(giver && giver != user && (giver in SStreasury.bank_accounts))
		SStreasury.bank_accounts[giver] += deposit
		SStreasury.log_entries += "-[deposit] from treasury (completed contract deposit to handler)"
		return 0
	SStreasury.log_entries += "-[deposit] from treasury (completed contract deposit)"
	return deposit

/obj/structure/fake_machine/contractledger/proc/cash_in(mob/user, reward, original_reward, tax_amt)
	add_mammons_to_atom(user, reward)
	if(reward > 0)
		if(tax_amt)
			say(reward > original_reward ? \
				"Your handler assistance-increased reward of [reward] amna has been dispensed! The difference is [reward - original_reward] amna. ([tax_amt] amna taxed.)" : \
				"Your reward of [reward] amna has been dispensed. ([tax_amt] amna taxed.)")
		else
			say(reward > original_reward ? \
				"Your handler assistance-increased reward of [reward] amna has been dispensed! The difference is [reward - original_reward] amna." : \
				"Your reward of [reward] amna has been dispensed.")

/obj/structure/fake_machine/contractledger/proc/abandon_scroll(mob/user, obj/item/paper/scroll/quest/abandoned_scroll)
	if(!abandoned_scroll)
		set_session_notice(user, "notice.no_scroll_input", "warning")
		to_chat(user, span_warning("No contract scroll found in the input area!"))
		return

	var/datum/quest/quest = abandoned_scroll.assigned_quest
	if(!quest)
		set_session_notice(user, "notice.scroll_no_contract", "warning")
		to_chat(user, span_warning("This scroll doesn't have an assigned contract!"))
		return
	if(!can_accept_contract_quest(quest))
		show_wrong_ledger_notice(user, quest)
		return

	if(quest.complete)
		turn_in_contract(user)
		return

	if(quest.player_commission)
		var/datum/quest/custom/commission = quest
		commission.on_return_to_board()
		commission.quest_receiver_reference = null
		commission.quest_receiver_name = ""
		commission.accepted_time = 0
		commission.quest_scroll = null
		commission.quest_scroll_ref = null
		abandoned_scroll.assigned_quest = null
		SSquestboard.add_quest(commission)
		qdel(abandoned_scroll)
		log_quest(user.ckey, user.mind, user, "Return player commission to board: [commission.title]")
		set_session_notice(user, "notice.commission_returned", "success")
		to_chat(user, span_notice("The commission returns to the shared board for another contractor."))
		return

	var/quest_type_label = quest.quest_type
	// Only a charged deposit comes back; uncharged contracts must not draw on the treasury.
	var/refund = quest.deposit_amount
	quest.deposit_amount = 0

	var/mob/giver = quest.quest_giver_reference?.resolve()
	if(refund > 0 && giver && (giver in SStreasury.bank_accounts))
		SStreasury.bank_accounts[giver] += refund
		SStreasury.treasury_value -= refund
		SStreasury.log_entries += "-[refund] from treasury (contract refund to handler)"
		set_session_notice(user, "notice.abandoned_issuer_return", "success")
		to_chat(user, span_notice("The deposit has been returned to the contract giver."))
	else if(refund > 0 && quest.quest_receiver_reference)
		var/mob/receiver = quest.quest_receiver_reference.resolve()
		if(receiver && (receiver in SStreasury.bank_accounts))
			SStreasury.bank_accounts[receiver] += refund
			SStreasury.treasury_value -= refund
			SStreasury.log_entries += "-[refund] from treasury (contract refund to volunteer)"
			set_session_notice(user, "notice.abandoned_refund", "success", list("refund" = refund))
			to_chat(user, span_notice("You receive a [refund] amna refund for abandoning the contract."))
		else
			cash_in(user, refund, refund, 0)
			SStreasury.treasury_value -= refund
			SStreasury.log_entries += "-[refund] from treasury (contract refund)"
			set_session_notice(user, "notice.abandoned_refund", "success", list("refund" = refund))
			to_chat(user, span_notice("Your refund of [refund] amna has been dispensed."))

	log_quest(user.ckey, user.mind, user, "Abandon [quest_type_label]")
	to_chat(user, span_notice("You abandon the contract \"[quest.get_title()]\"."))
	abandoned_scroll.assigned_quest = null
	qdel(quest)
	qdel(abandoned_scroll)

/obj/structure/fake_machine/contractledger/proc/abandon_contract(mob/user)
	var/obj/item/paper/scroll/quest/abandoned_scroll = get_abandonable_scroll(user)
	if(!abandoned_scroll)
		set_session_notice(user, "notice.no_scroll_input", "warning")
		to_chat(user, span_warning("Hold your unfinished contract scroll, or place it on the marked area, to abandon it."))
		return

	abandon_scroll(user, abandoned_scroll)

/obj/structure/fake_machine/contractledger/proc/print_contracts(mob/user)
	var/list/active_quests = list()
	for(var/obj/item/paper/scroll/quest/quest_scroll in GLOB.quest_scrolls)
		if(quest_scroll.assigned_quest && !quest_scroll.assigned_quest.complete)
			active_quests += quest_scroll

	if(!length(active_quests))
		say("No active contracts found.")
		return

	var/obj/item/paper/scroll/report = new(get_turf(src))
	report.name = "Guild Contract Report"
	report.desc = "A list of currently active contracts issued by the Mercenary's Guild."

	var/report_text = "<center><b>MERCENARY'S GUILD - ACTIVE CONTRACTS</b></center><br><br>"
	report_text += "<i>Generated on [station_time_timestamp()]</i><br><br>"

	for(var/obj/item/paper/scroll/quest/quest_scroll in active_quests)
		var/datum/quest/quest = quest_scroll.assigned_quest
		var/area/quest_area = get_area(quest_scroll)
		report_text += "<b>Title:</b> [quest.title].<br>"
		report_text += "<b>Issuer:</b> [quest.quest_giver_name ? quest.quest_giver_name : "Mercenary's Guild"].<br>"
		report_text += "<b>Recipient:</b> [quest.quest_receiver_name ? quest.quest_receiver_name : "Unclaimed"].<br>"
		report_text += "<b>Group:</b> [quest.contract_group].<br>"
		report_text += "<b>Type:</b> [quest.quest_type].<br>"
		report_text += "<b>Threat:</b> [quest.get_tier_label()].<br>"
		report_text += "<b>Last Known Location:</b> [quest_area ? quest_area.name : "Unknown Location"].<br>"
		report_text += "<b>Reward:</b> [quest.reward_amount] amna.<br><br>"

	report.info = report_text
	say("Contract report printed.")
