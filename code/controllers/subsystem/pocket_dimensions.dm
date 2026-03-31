SUBSYSTEM_DEF(pocket_dimensions)
	name = "Pocket Dimensions"
	init_order = INIT_ORDER_POCKETS
	wait = 10 SECONDS
	lazy_load = FALSE

	var/list/templates_by_id = list()
	var/list/templates_by_type = list()
	var/list/instances_by_key = list()
	var/list/instances_by_id = list()
	var/list/currentrun = list()
	var/next_instance_id = 1

/datum/controller/subsystem/pocket_dimensions/Initialize(timeofday)
	if(initialized)
		return
	rebuild_template_cache()
	return ..()

/datum/controller/subsystem/pocket_dimensions/proc/rebuild_template_cache()
	templates_by_id.Cut()
	templates_by_type.Cut()

	for(var/template_id in SSmapping.map_templates)
		var/datum/map_template/pocket/template = SSmapping.map_templates[template_id]
		if(!istype(template) || !template.mappath)
			continue

		templates_by_id[template.id] = template
		templates_by_type[template.type] = template

/datum/controller/subsystem/pocket_dimensions/proc/resolve_template(template_ref)
	if(istype(template_ref, /datum/map_template/pocket))
		return template_ref
	if(istext(template_ref))
		return templates_by_id[template_ref]
	if(ispath(template_ref, /datum/map_template/pocket))
		return templates_by_type[template_ref]
	return null

/datum/controller/subsystem/pocket_dimensions/proc/get_instance(instance_key)
	instance_key = "[instance_key]"
	var/datum/pocket_dimension/instance = instances_by_key[instance_key]
	if(QDELETED(instance))
		instances_by_key -= instance_key
		if(instance)
			instances_by_id -= "[instance.instance_id]"
		return null
	return instance

/datum/controller/subsystem/pocket_dimensions/proc/get_or_create_instance(instance_key, template_ref, lifecycle_policy = null, idle_timeout = null)
	instance_key = "[instance_key]"
	var/datum/pocket_dimension/instance = get_instance(instance_key)
	if(instance)
		instance.apply_lifecycle_settings(lifecycle_policy, idle_timeout)
		return instance

	var/datum/map_template/pocket/template = resolve_template(template_ref)
	if(!template)
		return null

	instance = new(template, instance_key, next_instance_id++, lifecycle_policy, idle_timeout)
	if(!instance.activate())
		qdel(instance)
		return null

	register_instance(instance)
	return instance

/datum/controller/subsystem/pocket_dimensions/proc/register_instance(datum/pocket_dimension/instance)
	if(!instance)
		return

	instances_by_key[instance.instance_key] = instance
	instances_by_id["[instance.instance_id]"] = instance

/datum/controller/subsystem/pocket_dimensions/proc/unregister_instance(datum/pocket_dimension/instance)
	if(!instance)
		return

	if(instances_by_key[instance.instance_key] == instance)
		instances_by_key -= instance.instance_key
	if(instances_by_id["[instance.instance_id]"] == instance)
		instances_by_id -= "[instance.instance_id]"

/datum/controller/subsystem/pocket_dimensions/proc/delete_instance(instance_or_key, eject_message = null)
	var/datum/pocket_dimension/instance
	if(istype(instance_or_key, /datum/pocket_dimension))
		instance = instance_or_key
	else
		instance = get_instance(instance_or_key)

	if(!instance)
		return FALSE

	instance.eject_teardown_contents(eject_message)

	unregister_instance(instance)
	qdel(instance)
	return TRUE

/datum/controller/subsystem/pocket_dimensions/proc/get_debug_instances()
	var/list/instances = list()

	for(var/instance_id = 1 to next_instance_id - 1)
		var/datum/pocket_dimension/instance = instances_by_id["[instance_id]"]
		if(!instance || QDELETED(instance))
			continue
		instances += instance

	return instances

/datum/controller/subsystem/pocket_dimensions/proc/build_debug_instance_choices()
	var/list/choices = list()

	for(var/datum/pocket_dimension/instance as anything in get_debug_instances())
		choices[instance.get_debug_label()] = instance

	return choices

/datum/controller/subsystem/pocket_dimensions/stat_entry(msg)
	var/active_instances = 0
	var/hibernating_instances = 0

	for(var/instance_id in instances_by_id)
		var/datum/pocket_dimension/instance = instances_by_id[instance_id]
		if(QDELETED(instance))
			continue
		if(instance.is_hibernating())
			hibernating_instances++
		else
			active_instances++

	msg = "I:[length(instances_by_id)] A:[active_instances] H:[hibernating_instances] CR:[length(currentrun)]"
	return ..()

/datum/controller/subsystem/pocket_dimensions/fire(resumed)
	if(!resumed)
		currentrun = list()
		for(var/instance_id in instances_by_id)
			var/datum/pocket_dimension/instance = instances_by_id[instance_id]
			if(QDELETED(instance))
				continue
			currentrun += instance

	while(length(currentrun))
		var/datum/pocket_dimension/instance = currentrun[length(currentrun)]
		currentrun.len--

		if(QDELETED(instance))
			continue

		instance.process_idle_lifecycle()

		if(MC_TICK_CHECK)
			return
