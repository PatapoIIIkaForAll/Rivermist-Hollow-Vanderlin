/datum/component/musk/proc/refresh_orders()
	var/deepest = 0
	for(var/datum/musk_bond/bond as anything in bonds_in_reach)
		deepest = max(deepest, bond.get_level())
	grant_order(/mob/living/carbon/human/proc/order_scent_touch, deepest >= MUSK_BOND_OBEDIENCE)
	grant_order(/mob/living/carbon/human/proc/order_scent_service, deepest >= MUSK_BOND_SERVICE)

/datum/component/musk/proc/grant_order(order, granted)
	var/mob/living/carbon/human/owner = parent
	if(granted == (order in owner.verbs))
		return
	if(granted)
		add_verb(owner, order)
	else
		remove_verb(owner, order)

/mob/living/carbon/human/proc/order_scent_touch()
	set name = "Order: Touch Yourself"
	set category = MUSK_BOND_ORDER_CATEGORY
	set desc = "Have someone bound to my scent bring themselves pleasure."

	choose_scent_thrall(MUSK_BOND_OBEDIENCE)?.order_touch(src)

/mob/living/carbon/human/proc/order_scent_service()
	set name = "Order: Please Me"
	set category = MUSK_BOND_ORDER_CATEGORY
	set desc = "Have someone bound to my scent bring me pleasure."

	choose_scent_thrall(MUSK_BOND_SERVICE)?.order_service(src)

/mob/living/carbon/human/proc/choose_scent_thrall(needed_level)
	RETURN_TYPE(/datum/musk_bond)
	var/datum/component/musk/musk = get_musk()
	var/list/choices = list()
	var/list/used_names = list()
	for(var/datum/musk_bond/bond as anything in musk?.bonds_in_reach)
		if(bond.get_level() >= needed_level)
			choices[avoid_assoc_duplicate_keys("[bond.thrall.current]", used_names)] = bond
	if(!length(choices))
		musk?.refresh_orders()
		to_chat(src, span_warning(musk_order_out_of_reach_text(src)))
		return null
	if(length(choices) == 1)
		return choices[choices[1]]
	var/choice = tgui_input_list(src, musk_localized(src, "Whom does my scent command?", "Кому велит мой запах?"), musk_bond_title(src), choices)
	return choice ? choices[choice] : null

/mob/living/carbon/human/proc/is_performing(action_type, mob/living/target)
	for(var/datum/sex_action/act as anything in sex_scene?.active_actions)
		if(act.type == action_type && act.action_user == src && act.action_target == target)
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/get_possible_acts(mob/living/target, list/action_types)
	. = list()
	var/datum/sex_scene_controller/controller = sex_scene?.get_controller(src)
	for(var/action_type in action_types)
		var/datum/sex_action/act = new action_type
		act.proposal_controller = controller
		act.action_user = src
		act.action_target = target
		if(is_performing(action_type, target) || (act.shows_on_menu(src, target) && act.can_run()))
			.[act.name] = action_type
		qdel(act)

/datum/musk_bond/proc/get_order_refusal(mob/living/carbon/human/giver, needed_level)
	var/mob/living/carbon/human/body = get_thrall_body()
	if(QDELETED(src) || !body || reaching_musk?.parent != giver || giver.stat != CONSCIOUS || get_level() < needed_level)
		return musk_order_out_of_reach_text(giver)
	if(!COOLDOWN_FINISHED(src, order_cooldown))
		return musk_localized(giver, "My last order has yet to fade. I should wait a little.", "Прошлый приказ ещё не развеялся. Нужно немного подождать.")
	if(body.stat != CONSCIOUS || body.cmode || !body.allows_player_erp_while_disconnected())
		return musk_localized(giver, "[body] is in no state to obey me.", "[body] сейчас не в состоянии мне подчиниться.")
	return null

/datum/musk_bond/proc/can_order(mob/living/carbon/human/giver, needed_level)
	var/refusal = get_order_refusal(giver, needed_level)
	if(refusal)
		to_chat(giver, span_warning(refusal))
	return !refusal

/datum/musk_bond/proc/order_touch(mob/living/carbon/human/giver)
	if(!can_order(giver, MUSK_BOND_OBEDIENCE))
		return FALSE
	var/static/list/touches = list(
		/datum/sex_action/masturbate/penis,
		/datum/sex_action/masturbate/vagina,
		/datum/sex_action/masturbate/anus,
	)
	var/mob/living/carbon/human/body = get_thrall_body()
	var/list/possible = body.get_possible_acts(body, touches)
	if(!length(possible))
		to_chat(giver, span_warning(musk_order_failed_text(giver, body)))
		return FALSE
	return carry_out_order(giver, body, possible[possible[1]], musk_order_touch_text(body, giver))

/datum/musk_bond/proc/order_service(mob/living/carbon/human/giver)
	if(!can_order(giver, MUSK_BOND_SERVICE))
		return FALSE
	var/static/list/services = list(
		/datum/sex_action/blowjob,
		/datum/sex_action/cunnilingus,
		/datum/sex_action/rimming,
		/datum/sex_action/suck_balls,
		/datum/sex_action/crotch_nuzzle,
		/datum/sex_action/armpit_nuzzle,
		/datum/sex_action/foot_lick,
		/datum/sex_action/musk_lick/armpit,
		/datum/sex_action/musk_lick/crotch,
		/datum/sex_action/musk_lick/butt,
		/datum/sex_action/musk_lick/feet,
		/datum/sex_action/masturbate/other/penis,
		/datum/sex_action/masturbate/other/vagina,
		/datum/sex_action/masturbate/other/anus,
		/datum/sex_action/sex/other/boobjob,
		/datum/sex_action/sex/other/thighjob,
		/datum/sex_action/sex/other/footjob,
		/datum/sex_action/sex/other/vagina,
		/datum/sex_action/sex/other/anal,
	)
	var/mob/living/carbon/human/body = get_thrall_body()
	var/list/possible = body.get_possible_acts(giver, services)
	if(!length(possible))
		to_chat(giver, span_warning(musk_order_failed_text(giver, body)))
		return FALSE
	var/choice = tgui_input_list(giver, musk_localized(giver, "How shall [body] please me?", "Чем меня порадует [body]?"), musk_bond_title(giver), possible)
	if(!choice || !can_order(giver, MUSK_BOND_SERVICE) || body != get_thrall_body())
		return FALSE
	return carry_out_order(giver, giver, possible[choice], musk_order_service_text(body, giver))

/datum/musk_bond/proc/carry_out_order(mob/living/carbon/human/giver, mob/living/carbon/human/target, action_type, thrall_text)
	var/mob/living/carbon/human/body = get_thrall_body()
	COOLDOWN_START(src, order_cooldown, MUSK_BOND_ORDER_COOLDOWN)
	var/datum/sex_scene_controller/controller = body.open_sex_scene(target, FALSE)
	if(!controller || (!body.is_performing(action_type, target) && !controller.try_start_action(action_type)))
		to_chat(giver, span_warning(musk_order_failed_text(giver, body)))
		return FALSE
	controller.show_ui()
	log_game("SCENT BOND: [key_name(giver)] ordered [key_name(body)] to perform [action_type].")
	to_chat(body, span_love(thrall_text))
	to_chat(giver, span_love(musk_order_obeyed_text(giver, body)))
	gain(MUSK_GAIN_ORDER)
	return TRUE
