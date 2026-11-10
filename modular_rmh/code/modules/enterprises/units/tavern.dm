/datum/enterprise/tavern
	name = "tavern"
	manager_jobs = list(
		/datum/job/innkeep,
		/datum/job/matron,
	)
	staff_jobs = list(
		/datum/job/cook,
		/datum/job/tavern_wench,
		/datum/job/advclass/tavern_wench,
	)
	ledger_pages = list("overview", "menu", "staff", "zones", "commissions")
	premises_hint = "Place the ledger on an area with tavern_area set."

/datum/enterprise/tavern/is_premises_turf(turf/checked)
	var/area/checked_area = checked.loc
	return checked_area.tavern_area
