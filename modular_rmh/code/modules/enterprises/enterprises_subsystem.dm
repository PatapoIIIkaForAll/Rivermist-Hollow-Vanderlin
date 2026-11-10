SUBSYSTEM_DEF(enterprises)
	name = "Enterprises"
	init_order = INIT_ORDER_OVERLAY - 1
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 2 SECONDS
	var/list/datum/enterprise/enterprises = list()
	var/list/datum/enterprise/currentrun = list()
	var/list/datum/weakref/pending_keys = list()
	var/keys_ready = FALSE

/datum/controller/subsystem/enterprises/Initialize()
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in enterprise.ledgers)
			enterprise.claim_premises(ledger)
		enterprise.recover_journal()
	keys_ready = TRUE
	for(var/datum/weakref/key_ref as anything in pending_keys)
		var/obj/item/key/key = key_ref.resolve()
		if(!QDELETED(key))
			note_key(key)
	pending_keys = null
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_spawn))
	RegisterSignal(SSdcs, COMSIG_GLOB_TIME_OF_DAY_CHANGED, PROC_REF(on_time_of_day))
	LAZYADD(SSticker.round_end_events, CALLBACK(src, PROC_REF(on_round_end)))
	return ..()

/datum/controller/subsystem/enterprises/fire(resumed)
	if(!resumed)
		currentrun = list()
		for(var/enterprise_type in enterprises)
			currentrun += enterprises[enterprise_type]
	var/list/datum/enterprise/current_run = currentrun
	var/delta_time = wait * 0.1

	while(length(current_run))
		var/datum/enterprise/enterprise = current_run[length(current_run)]
		current_run.len--
		if(!QDELETED(enterprise))
			if(enterprise.shift_active)
				enterprise.process_shift(delta_time)
			if(COOLDOWN_FINISHED(enterprise, upkeep_cooldown))
				COOLDOWN_START(enterprise, upkeep_cooldown, ENTERPRISE_UPKEEP_INTERVAL)
				enterprise.upkeep()
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/enterprises/proc/get_enterprise(enterprise_type)
	if(!ispath(enterprise_type, /datum/enterprise))
		return null
	var/datum/enterprise/enterprise = enterprises[enterprise_type]
	if(enterprise)
		return enterprise
	var/datum/enterprise/prototype = enterprise_type
	if(enterprise_type == initial(prototype.abstract_type))
		return null
	enterprise = new enterprise_type
	enterprises[enterprise_type] = enterprise
	return enterprise

/datum/controller/subsystem/enterprises/proc/get_enterprise_at(atom/place)
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		if(enterprise.contains(place))
			return enterprise
	return null

/datum/controller/subsystem/enterprises/proc/on_job_spawn(datum/source, datum/job/job, mob/living/carbon/human/spawned, client/player_client)
	SIGNAL_HANDLER
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		if(is_type_in_list(job, enterprise.owner_jobs))
			INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, welcome_owner), spawned, player_client?.ckey || spawned.ckey)

/datum/controller/subsystem/enterprises/proc/on_time_of_day(datum/source, new_tod, old_tod)
	SIGNAL_HANDLER
	if(new_tod != "dawn")
		return
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		enterprise.new_day()

/datum/controller/subsystem/enterprises/proc/on_round_end()
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		enterprise.bank_experience()

/datum/controller/subsystem/enterprises/proc/note_key(obj/item/key/key)
	if(!keys_ready)
		pending_keys += WEAKREF(key)
		return
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		enterprise.track_key(key)

/datum/controller/subsystem/enterprises/proc/note_rest(mob/living/carbon/human/sleeper)
	var/datum/enterprise/enterprise = get_enterprise_at(sleeper)
	if(enterprise)
		enterprise.handle_rest(sleeper)

/datum/controller/subsystem/enterprises/proc/note_night(mob/living/carbon/human/sleeper)
	var/datum/enterprise/enterprise = get_enterprise_at(sleeper)
	if(enterprise)
		enterprise.handle_night(sleeper)

/datum/controller/subsystem/enterprises/proc/note_meal(mob/living/eater)
	var/datum/enterprise/enterprise = get_enterprise_at(eater)
	if(enterprise)
		enterprise.handle_meal(eater)
