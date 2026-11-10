#define ENTERPRISE_SAVE_NAME "enterprises"

/datum/enterprise
	var/owner_ckey
	var/datum/weakref/owner_ref
	var/owner_level = 0
	var/owner_earned = 0
	var/list/owner_grades = list()
	var/list/spent_grades = list()
	var/list/welcomed = list()
	var/journal_age = 20 MINUTES
	var/journal_pending = FALSE

/datum/enterprise/proc/get_prestige_level(earned)
	var/level = 0
	for(var/threshold in prestige_thresholds)
		if(earned < threshold)
			break
		level++
	return level

/datum/enterprise/proc/load_prestige(ckey)
	var/datum/save_manager/manager = get_save_manager(ckey)
	if(!manager)
		return list("earned" = 0, "grades" = list())
	var/list/grades = manager.get_data(ENTERPRISE_SAVE_NAME, "[name]_grades", null)
	return list(
		"earned" = manager.get_data(ENTERPRISE_SAVE_NAME, "[name]_earned", 0),
		"grades" = islist(grades) ? grades.Copy() : list(),
	)

/datum/enterprise/proc/save_prestige(ckey, earned, list/grades)
	var/datum/save_manager/manager = get_save_manager(ckey)
	if(!manager)
		return FALSE
	manager.set_data(ENTERPRISE_SAVE_NAME, "[name]_earned", earned)
	manager.set_data(ENTERPRISE_SAVE_NAME, "[name]_grades", grades.Copy())
	return TRUE

/datum/enterprise/proc/get_journal_path()
	return "data/enterprises/[name]_journal.json"

/datum/enterprise/proc/write_journal()
	if(!owner_ckey || earned_round <= 0)
		return FALSE
	if(world.time < journal_age)
		journal_pending = TRUE
		return FALSE
	journal_pending = FALSE
	var/path = get_journal_path()
	fdel(path)
	text2file(json_encode(list("ckey" = owner_ckey, "earned" = earned_round)), path)
	return TRUE

/datum/enterprise/proc/recover_journal()
	var/path = get_journal_path()
	if(!fexists(path))
		return FALSE
	var/list/journal = safe_json_decode(file2text(path))
	fdel(path)
	if(!islist(journal))
		return FALSE
	var/ckey = journal["ckey"]
	var/earned = journal["earned"]
	if(!istext(ckey) || !isnum(earned) || earned <= 0)
		return FALSE
	var/list/saved = load_prestige(ckey)
	save_prestige(ckey, saved["earned"] + earned, saved["grades"])
	return TRUE

/datum/enterprise/proc/get_owner()
	var/mob/living/found = owner_ref?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise/proc/welcome_owner(mob/living/carbon/human/owner, ckey)
	if(!ckey)
		return FALSE
	if(owner_ckey && owner_ckey != ckey)
		bank_experience()
	owner_ckey = ckey
	owner_ref = WEAKREF(owner)
	var/list/saved = load_prestige(ckey)
	owner_earned = saved["earned"]
	owner_grades = saved["grades"]
	owner_level = get_prestige_level(owner_earned)
	if(!welcomed[ckey])
		welcomed[ckey] = TRUE
		if(grant_owner_rooms(owner_level))
			redraw()
	write_journal()
	SStgui.update_uis(src)
	return TRUE

/datum/enterprise/proc/save_grade(level)
	if(!owner_ckey || level > owner_level || (level in owner_grades))
		return FALSE
	owner_grades += level
	spent_grades += level
	save_prestige(owner_ckey, owner_earned, owner_grades)
	return TRUE

/datum/enterprise/proc/can_spend_grade(level)
	return (level in owner_grades) && !(level in spent_grades)

/datum/enterprise/proc/spend_grade(level)
	if(!can_spend_grade(level))
		return FALSE
	spent_grades += level
	return TRUE

/datum/enterprise/proc/bank_experience()
	if(!owner_ckey || earned_round <= 0 || world.time < journal_age)
		return FALSE
	var/list/saved = load_prestige(owner_ckey)
	owner_earned = saved["earned"] + earned_round
	earned_round = 0
	journal_pending = FALSE
	save_prestige(owner_ckey, owner_earned, owner_grades)
	fdel(get_journal_path())
	return TRUE

/datum/enterprise/proc/get_prestige_data()
	var/list/grades = list()
	for(var/level in 2 to ENTERPRISE_MAX_LEVEL)
		grades += list(list(
			"level" = level,
			"unlocked" = owner_level >= level,
			"saved" = (level in owner_grades),
			"spent" = (level in spent_grades),
		))
	return list(
		"level" = owner_level,
		"max_level" = length(prestige_thresholds),
		"earned" = owner_earned,
		"next" = get_level_value(prestige_thresholds, owner_level + 1),
		"grades" = grades,
	)

#undef ENTERPRISE_SAVE_NAME
