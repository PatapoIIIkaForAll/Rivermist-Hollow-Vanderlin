/datum/enterprise/tavern
	name = "tavern"
	owner_jobs = list(
		/datum/job/innkeep,
	)
	manager_jobs = list(
		/datum/job/innkeep,
		/datum/job/matron,
	)
	staff_jobs = list(
		/datum/job/cook,
		/datum/job/tavern_wench,
		/datum/job/advclass/tavern_wench,
	)
	ledger_pages = list("overview", "premises", "prestige", "menu", "staff", "commissions")
	owner_pages = list("premises", "prestige")
	premises_hint = "Place the ledger on an area with tavern_area set."
	staff_lock_ids = list(ACCESS_INN)
	owner_keyring = /obj/item/storage/keyring/tavern_keeper

/datum/enterprise/tavern/is_premises_turf(turf/checked)
	var/area/checked_area = checked.loc
	return checked_area.tavern_area

/area/under/town/rmh/basement/tavern
	tavern_area = TRUE
