/mob/living/carbon/human
	var/tmp/werewolf_conversion_prompt_pending = FALSE

/proc/werewolf_is_player_character(mob/living/target)
	if(!istype(target))
		return FALSE
	if(!target.mind)
		return FALSE
	return TRUE

/proc/werewolf_plural_suffix(amount)
	if(amount == 1)
		return ""
	return "s"

/datum/antagonist/werewolf
	var/tmp/list/bred_player_minds = list()
	var/tmp/animals_hunted_in_wolf_form = 0
	var/tmp/foes_slain_in_wolf_form = 0
	var/tmp/list/converted_player_minds = list()
	var/tmp/list/trapped_player_minds = list()
	var/tmp/contract_objective_score = 0

/datum/antagonist/werewolf/proc/refresh_werewolf_objectives()
	for(var/datum/objective/objective as anything in objectives)
		if(!istype(objective, /datum/objective/werewolf_counter))
			continue
		objective.update_explanation_text()

/datum/antagonist/werewolf/proc/add_contract_objective_score(score_amount)
	if(score_amount <= 0)
		return FALSE

	contract_objective_score += score_amount
	record_contract_progress(/datum/contract_goal/werewolf/hunt_score, score_amount)
	refresh_werewolf_objectives()

	if(owner?.current)
		to_chat(owner.current, span_notice("The moon hunt credits me [score_amount] score. Total: [contract_objective_score]/[WW_CONTRACT_OBJECTIVE_TARGET]."))
		if(contract_objective_score >= WW_CONTRACT_OBJECTIVE_TARGET)
			to_chat(owner.current, span_greentext("The moon hunt is satisfied."))
	return TRUE

/datum/antagonist/werewolf/proc/record_breed_target(mob/living/carbon/human/target)
	if(!transformed)
		return FALSE
	if(!istype(target))
		return FALSE
	if(!werewolf_is_player_character(target))
		return FALSE
	if(target == owner?.current)
		return FALSE
	if(target.mind in bred_player_minds)
		return FALSE

	bred_player_minds += target.mind
	record_contract_progress(/datum/contract_goal/werewolf/breed)
	refresh_werewolf_objectives()
	return TRUE

/datum/antagonist/werewolf/proc/record_conversion_target(mob/living/carbon/human/target)
	if(!istype(target))
		return FALSE
	if(!werewolf_is_player_character(target))
		return FALSE
	if(target.mind in converted_player_minds)
		return FALSE

	converted_player_minds += target.mind
	var/datum/antagonist/werewolf/lesser/pup = target.mind.has_antag_datum(/datum/antagonist/werewolf/lesser)
	pup?.set_elder(src)
	record_contract_progress(/datum/contract_goal/werewolf/convert)
	refresh_werewolf_objectives()
	return TRUE

/datum/antagonist/werewolf/proc/record_trapped_target(mob/living/target)
	if(!istype(target))
		return FALSE
	if(!werewolf_is_player_character(target))
		return FALSE
	if(target.mind in trapped_player_minds)
		return FALSE

	trapped_player_minds += target.mind
	record_contract_progress(/datum/contract_goal/werewolf/trap)
	refresh_werewolf_objectives()
	return TRUE

/datum/antagonist/werewolf/proc/on_werewolf_kill(mob/living/source, mob/living/victim)
	SIGNAL_HANDLER

	if(!transformed)
		return
	if(!istype(victim))
		return
	if(victim == source)
		return

	if(isanimal(victim))
		animals_hunted_in_wolf_form += 1
		record_contract_progress(/datum/contract_goal/werewolf/hunt_beasts)
		refresh_werewolf_objectives()
		return

	if(werewolf_is_player_character(victim))
		return

	foes_slain_in_wolf_form += 1
	record_contract_progress(/datum/contract_goal/werewolf/slay_foe)
	refresh_werewolf_objectives()

/mob/living/carbon/human/proc/can_receive_werewolf_conversion_offer()
	if(werewolf_conversion_prompt_pending)
		return FALSE
	if(stat != CONSCIOUS)
		return FALSE
	if(!client)
		return FALSE
	if(!mind)
		return FALSE
	if(!can_werewolf())
		return FALSE
	return TRUE

/// Odds that a beast's seed offers the curse; a knot doubles them and the full moon always offers.
/proc/get_werewolf_seed_conversion_chance(knot_finished = FALSE, mob/living/target = null, mob/living/source = null)
	if(is_full_moon_night())
		return 100
	var/conversion_chance = WW_CREAMPIE_CONVERSION_CHANCE
	if(knot_finished)
		conversion_chance *= WW_CREAMPIE_KNOT_MULTIPLIER
	// A wolf breeding its own scent-marked mate again spreads the curse more surely.
	var/datum/status_effect/werewolf_scent_mark/pack_mark = target?.has_status_effect(/datum/status_effect/werewolf_scent_mark)
	if(pack_mark)
		conversion_chance *= pack_mark.get_werewolf_conversion_multiplier(source)
	return min(conversion_chance, 100)

/// Offers the curse; [source] may be an NPC beast with no antag datum, so only [source_antag] gets credit.
/mob/living/carbon/human/proc/request_werewolf_conversion(datum/antagonist/werewolf/source_antag, mob/living/source, prompt_title, prompt_text)
	if(!can_receive_werewolf_conversion_offer())
		return FALSE

	werewolf_conversion_prompt_pending = TRUE

	var/datum/weakref/source_antag_ref
	var/datum/weakref/source_ref

	if(source_antag)
		source_antag_ref = WEAKREF(source_antag)
	if(source)
		source_ref = WEAKREF(source)

	INVOKE_ASYNC(src, PROC_REF(prompt_werewolf_conversion_offer), source_antag_ref, source_ref, prompt_title, prompt_text)
	return TRUE

/mob/living/carbon/human/proc/prompt_werewolf_conversion_offer(datum/weakref/source_antag_ref, datum/weakref/source_ref, prompt_title, prompt_text)
	var/mob/living/source = source_ref?.resolve()
	var/choice = tgui_alert(src, prompt_text, prompt_title, list("Accept", "Reject"), WW_CONVERSION_PROMPT_TIMEOUT)

	werewolf_conversion_prompt_pending = FALSE

	if(QDELETED(src))
		return FALSE
	if(!client)
		return FALSE
	if(stat != CONSCIOUS)
		return FALSE
	if(!can_werewolf())
		return FALSE

	if(choice != "Accept")
		to_chat(src, span_notice("I refuse the mooncurse."))
		if(source)
			to_chat(source, span_notice("[src] refuses the mooncurse."))
		return FALSE

	var/datum/antagonist/werewolf/new_werewolf = werewolf_check()
	if(!new_werewolf)
		return FALSE

	flash_fullscreen("redflash3")
	to_chat(src, span_userdanger("The mooncurse takes root inside me."))
	emote("agony", forced = TRUE)

	if(source)
		to_chat(source, span_notice("[src] accepts the mooncurse."))

	var/datum/antagonist/werewolf/source_antag = source_antag_ref?.resolve()
	source_antag?.record_conversion_target(src)
	return TRUE

/mob/living/carbon/human/proc/handle_werewolf_creampie_conversion(mob/living/carbon/human/source, knot_finished = FALSE)
	if(!istype(source))
		return FALSE

	var/datum/antagonist/werewolf/source_antag = IS_WEREWOLF(source)
	if(!source_antag)
		return FALSE
	if(!source_antag.transformed)
		return FALSE

	source_antag.record_breed_target(src)

	if(!can_receive_werewolf_conversion_offer())
		return FALSE

	if(!prob(get_werewolf_seed_conversion_chance(knot_finished, src, source)))
		return FALSE

	return request_werewolf_conversion(
		source_antag,
		source,
		"Mooncursed Seed",
		"[source]'s seed carries the mooncurse. Do I accept the beast within?",
	)

/mob/living/carbon/human/proc/offer_voluntary_werewolf_bite(mob/living/carbon/human/source)
	if(!istype(source))
		return FALSE

	var/datum/antagonist/werewolf/source_antag = IS_WEREWOLF(source)
	if(!source_antag)
		return FALSE
	if(!source_antag.transformed)
		return FALSE

	return request_werewolf_conversion(
		source_antag,
		source,
		"Voluntary Bite",
		"[source] offers the mooncurse through a deliberate bite. Do I accept lycanthropy?",
	)

/datum/objective/werewolf_counter
	triumph_count = 5
	var/target_minimum = 1
	var/target_maximum = 1

/datum/objective/werewolf_counter/on_creation()
	target_amount = rand(target_minimum, target_maximum)
	update_explanation_text()

/datum/objective/werewolf_counter/check_completion()
	return get_progress() >= target_amount

/datum/objective/werewolf_counter/proc/get_progress()
	return 0

/datum/objective/werewolf_counter/proc/get_werewolf_antag()
	if(!owner)
		return null
	return owner.has_antag_datum(/datum/antagonist/werewolf)

/datum/objective/werewolf_counter/contracts
	name = "contracts"
	target_minimum = WW_CONTRACT_OBJECTIVE_TARGET
	target_maximum = WW_CONTRACT_OBJECTIVE_TARGET

/datum/objective/werewolf_counter/contracts/get_progress()
	var/datum/antagonist/werewolf/werewolf_antag = get_werewolf_antag()
	if(!werewolf_antag)
		return 0
	return werewolf_antag.contract_objective_score

/datum/objective/werewolf_counter/contracts/update_explanation_text()
	..()
	explanation_text = "Complete moon-hunt contracts until I have [target_amount] hunt score. Progress: [get_progress()]/[target_amount]."

/datum/objective/werewolf_counter/breed
	name = "breed"
	target_minimum = WW_BREED_OBJECTIVE_MIN
	target_maximum = WW_BREED_OBJECTIVE_MAX

/datum/objective/werewolf_counter/breed/get_progress()
	var/datum/antagonist/werewolf/werewolf_antag = get_werewolf_antag()
	if(!werewolf_antag)
		return 0
	return length(werewolf_antag.bred_player_minds)

/datum/objective/werewolf_counter/breed/update_explanation_text()
	..()
	explanation_text = "In beast form, creampie [target_amount] different player[werewolf_plural_suffix(target_amount)]. Progress: [get_progress()]/[target_amount]."

/datum/objective/werewolf_counter/hunt
	name = "hunt"
	target_minimum = WW_HUNT_OBJECTIVE_MIN
	target_maximum = WW_HUNT_OBJECTIVE_MAX

/datum/objective/werewolf_counter/hunt/get_progress()
	var/datum/antagonist/werewolf/werewolf_antag = get_werewolf_antag()
	if(!werewolf_antag)
		return 0
	return werewolf_antag.animals_hunted_in_wolf_form

/datum/objective/werewolf_counter/hunt/update_explanation_text()
	..()
	explanation_text = "In beast form, hunt [target_amount] animal[werewolf_plural_suffix(target_amount)]. Progress: [get_progress()]/[target_amount]."

/datum/objective/werewolf_counter/slay
	name = "slay"
	target_minimum = WW_SLAY_OBJECTIVE_MIN
	target_maximum = WW_SLAY_OBJECTIVE_MAX

/datum/objective/werewolf_counter/slay/get_progress()
	var/datum/antagonist/werewolf/werewolf_antag = get_werewolf_antag()
	if(!werewolf_antag)
		return 0
	return werewolf_antag.foes_slain_in_wolf_form

/datum/objective/werewolf_counter/slay/update_explanation_text()
	..()
	explanation_text = "In beast form, slay [target_amount] non-player foe[werewolf_plural_suffix(target_amount)]. Progress: [get_progress()]/[target_amount]."

/datum/objective/werewolf_counter/convert
	name = "convert"
	target_minimum = WW_CONVERT_OBJECTIVE_MIN
	target_maximum = WW_CONVERT_OBJECTIVE_MAX

/datum/objective/werewolf_counter/convert/get_progress()
	var/datum/antagonist/werewolf/werewolf_antag = get_werewolf_antag()
	if(!werewolf_antag)
		return 0
	return length(werewolf_antag.converted_player_minds)

/datum/objective/werewolf_counter/convert/update_explanation_text()
	..()
	explanation_text = "Convert [target_amount] willing soul[werewolf_plural_suffix(target_amount)] into werewolves. Progress: [get_progress()]/[target_amount]."

/datum/objective/werewolf_counter/trap
	name = "trap"
	target_minimum = WW_TRAP_OBJECTIVE_TARGET
	target_maximum = WW_TRAP_OBJECTIVE_TARGET

/datum/objective/werewolf_counter/trap/get_progress()
	var/datum/antagonist/werewolf/werewolf_antag = get_werewolf_antag()
	if(!werewolf_antag)
		return 0
	return length(werewolf_antag.trapped_player_minds)

/datum/objective/werewolf_counter/trap/update_explanation_text()
	..()
	explanation_text = "Throw [target_amount] different player[werewolf_plural_suffix(target_amount)] into my moon pit. Progress: [get_progress()]/[target_amount]."

// ------------- Moonkissed (lesser werewolf) pack objectives -------------

/datum/objective/werewolf/pack_elder
	name = "pack elder"
	explanation_text = "Follow the pack: at least one elder of my pack must survive."
	triumph_count = 2

/datum/objective/werewolf/pack_elder/check_completion()
	for(var/datum/mind/wolf_mind as anything in SSmapping.retainer.werewolves)
		var/datum/antagonist/werewolf/wolf = wolf_mind?.has_antag_datum(/datum/antagonist/werewolf)
		if(!wolf || istype(wolf, /datum/antagonist/werewolf/lesser))
			continue
		if(considered_alive(wolf_mind))
			return TRUE
	return FALSE

/datum/objective/werewolf/find_elder
	name = "find elder"
	explanation_text = "Stand beside my elder under a full moon."
	triumph_count = 2

/datum/objective/werewolf/pack_keeper
	name = "pack keeper"
	triumph_count = 3

/datum/objective/werewolf/pack_keeper/on_creation()
	explanation_text = "Keep [WW_PACK_KEEPER_PUP_TARGET] pups of my own making alive to the end."

/datum/objective/werewolf/pack_keeper/check_completion()
	var/datum/antagonist/werewolf/elder = owner?.has_antag_datum(/datum/antagonist/werewolf)
	if(!elder)
		return FALSE
	return length(elder.get_living_pup_minds()) >= WW_PACK_KEEPER_PUP_TARGET

/datum/objective/werewolf_counter/embrace_gift
	name = "embrace"
	triumph_count = 2
	target_minimum = 3
	target_maximum = 5

/datum/objective/werewolf_counter/embrace_gift/get_progress()
	var/datum/antagonist/werewolf/lesser/wolfkin = get_werewolf_antag()
	if(!istype(wolfkin))
		return 0
	return wolfkin.times_shifted

/datum/objective/werewolf_counter/embrace_gift/update_explanation_text()
	..()
	explanation_text = "Embrace the moon's gift: take my moonkissed form [target_amount] time[werewolf_plural_suffix(target_amount)]. Progress: [get_progress()]/[target_amount]."
