/datum/erp_preference/boolean/lasting_scent_bonds
	name = "Lasting Scent Bonds"
	description = "Your scent bonds outlive the round: when you meet the same character again, with yours and theirs both wishing it, the bond is as deep as you left it. Only its depth is kept, and a bond tied by a Scent Mark is never kept. Works for those who smell and those who submit."
	default_value = FALSE
	category = "General"

/datum/mind/proc/wants_lasting_scent_bonds()
	return key && current?.get_erp_pref(/datum/erp_preference/boolean/lasting_scent_bonds) == TRUE

/datum/musk_bond/proc/is_lasting()
	return thrall.wants_lasting_scent_bonds() && source.wants_lasting_scent_bonds()

/datum/musk_bond/proc/get_record_key()
	return "[ckey(source.key)]|[source_name]"

/datum/musk_bond/proc/get_records()
	var/datum/save_manager/saves = get_save_manager(thrall.key)
	var/list/records = saves?.get_data(MUSK_MEMORY_SAVE, thrall_name)
	return islist(records) ? records.Copy() : list()

/datum/musk_bond/proc/save_records(list/records)
	var/datum/save_manager/saves = get_save_manager(thrall.key)
	saves?.set_data(MUSK_MEMORY_SAVE, thrall_name, records)

/datum/musk_bond/proc/recall()
	if(recalled || fated || !is_lasting())
		return
	recalled = TRUE
	var/list/records = get_records()
	var/stored = clamp(records[get_record_key()] || 0, 0, MUSK_BOND_LEVEL_MAX)
	if(stored <= level)
		return
	level = stored
	greeting = MUSK_GREETING_RECALLED
	get_thrall_body()?.learn_to_review_scent_bonds()
	if(reaching_musk)
		greet()
		reaching_musk.refresh_orders()

/datum/musk_bond/proc/remember()
	if(fated || !is_lasting())
		return
	var/list/records = get_records()
	var/record_key = get_record_key()
	var/deepest = max(records[record_key] || 0, level)
	records -= record_key
	records[record_key] = deepest
	if(length(records) > MUSK_MEMORY_MAX)
		records.Cut(1, length(records) - MUSK_MEMORY_MAX + 1)
	save_records(records)

/datum/musk_bond/proc/forget()
	if(!thrall.key)
		return
	var/list/records = get_records()
	var/record_key = get_record_key()
	if(!(record_key in records))
		return
	records -= record_key
	save_records(records)
