/datum/enterprise
	abstract_type = /datum/enterprise
	var/name = "enterprise"
	var/list/manager_jobs = list()
	var/list/staff_jobs = list()
	var/list/ledger_pages = list("overview")
	var/list/obj/structure/fake_machine/enterprise_ledger/ledgers = list()
	var/shift_active = FALSE
	// Indexed by z-level; a level the enterprise does not reach holds null.
	var/list/datum/enterprise_floor/floors = list()
	var/premises_hint = "Place the ledger on an area that belongs to the enterprise."

/datum/enterprise/Destroy()
	for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in ledgers)
		ledger.enterprise = null
	ledgers = null
	QDEL_LIST(floors)
	SSenterprises.enterprises -= type
	return ..()

/datum/enterprise/proc/is_manager(mob/user)
	return is_type_in_list(user?.mind?.assigned_role, manager_jobs)

/datum/enterprise/proc/is_staff(mob/user)
	return is_manager(user) || is_type_in_list(user?.mind?.assigned_role, staff_jobs)

/datum/enterprise/proc/start_shift(mob/user)
	if(shift_active || !is_staff(user))
		return FALSE
	shift_active = TRUE
	return TRUE

/datum/enterprise/proc/end_shift(mob/user)
	if(!shift_active || !is_staff(user))
		return FALSE
	shift_active = FALSE
	return TRUE

/datum/enterprise/proc/process_shift(delta_time)
	return

/datum/enterprise/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, get_preferred_ui_language(user) == "ru" ? "EnterpriseLedgerRu" : "EnterpriseLedger")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/enterprise/ui_state(mob/user)
	return GLOB.physical_state

/datum/enterprise/ui_host(mob/user)
	var/obj/structure/fake_machine/enterprise_ledger/nearest
	for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in ledgers)
		if(!nearest || get_dist(user, ledger) < get_dist(user, nearest))
			nearest = ledger
	return nearest || src

/datum/enterprise/ui_static_data(mob/user)
	return list(
		"name" = name,
		"pages" = ledger_pages,
	)

/datum/enterprise/ui_data(mob/user)
	return list(
		"can_manage" = is_manager(user),
		"is_staff" = is_staff(user),
		"shift_active" = shift_active,
		"premises" = get_premises_data(),
	)

/datum/enterprise/proc/get_premises_data()
	var/list/premises = list()
	for(var/datum/enterprise_floor/floor as anything in floors)
		if(floor)
			premises += list(list("z" = floor.z, "tiles" = length(floor.turfs), "basement" = floor.basement))
	return premises

/datum/enterprise/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("start_shift")
			return start_shift(ui.user)
		if("end_shift")
			return end_shift(ui.user)
	return FALSE
