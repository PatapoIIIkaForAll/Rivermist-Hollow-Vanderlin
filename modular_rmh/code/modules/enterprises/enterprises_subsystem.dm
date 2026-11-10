SUBSYSTEM_DEF(enterprises)
	name = "Enterprises"
	// The floors are pictured as they look, so walls must be smoothed and overlays compiled first.
	init_order = INIT_ORDER_OVERLAY - 1
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 2 SECONDS
	var/list/datum/enterprise/enterprises = list()
	var/list/datum/enterprise/currentrun = list()

// By now every mapped ledger has registered with its enterprise.
/datum/controller/subsystem/enterprises/Initialize()
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in enterprise.ledgers)
			enterprise.claim_premises(ledger)
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
		if(!QDELETED(enterprise) && enterprise.shift_active)
			enterprise.process_shift(delta_time)
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
