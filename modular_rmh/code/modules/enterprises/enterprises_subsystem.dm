SUBSYSTEM_DEF(enterprises)
	name = "Enterprises"
	flags = SS_BACKGROUND | SS_NO_INIT
	runlevels = RUNLEVEL_GAME
	wait = 2 SECONDS
	var/list/datum/enterprise/enterprises = list()
	var/list/datum/enterprise/currentrun = list()

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
