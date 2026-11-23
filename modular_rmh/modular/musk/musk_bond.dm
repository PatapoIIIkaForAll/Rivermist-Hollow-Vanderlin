/datum/erp_preference/list_choice/scent_submission
	name = "Scent Submission"
	description = "How deep the scent of someone with the Smell & Musk quirk may sink into you. Needs Musk Susceptibility. Their nearness, their sweat and their fluids bind you, one step a day at most, and only once you have slept. I: near that scent you are never calm. II: near it you ache. III: they see hearts over you and may order you to touch yourself. IV: they may order you to please them with mouth, hands or body. V: their seed always takes in you if your body allows it, and yours in them if they wish it; they bring you nothing but good thoughts."
	choices = MUSK_BOND_LIMITS
	default_choice = "Off"
	category = "General"

/mob/living/carbon/human/proc/get_scent_bond_limit()
	if(!is_musk_susceptible())
		return 0
	var/static/list/limits = MUSK_BOND_LIMITS
	return max(limits.Find(get_erp_pref(/datum/erp_preference/list_choice/scent_submission)) - 1, 0)

/mob/living/proc/get_scent_bond_level(mob/living/source)
	if(!mind || !source?.mind)
		return 0
	var/datum/musk_bond/bond = mind.get_scent_bond(source.mind)
	return bond ? bond.get_level() : 0

/mob/living/carbon/human/proc/deepen_scent_bond(mob/living/carbon/human/source, gain_kind)
	if(!mind || !source.mind || source == src || !source.get_musk() || !get_scent_bond_limit())
		return FALSE
	return mind.open_scent_bond(source.mind).gain(gain_kind)

/mob/living/carbon/human/finish_night_rest()
	. = ..()
	for(var/datum/musk_bond/bond as anything in mind?.scent_bonds)
		bond.settle()

/datum/mind
	var/list/datum/musk_bond/scent_bonds
	var/list/datum/musk_bond/scent_followers

/datum/mind/proc/get_scent_bond(datum/mind/source)
	RETURN_TYPE(/datum/musk_bond)
	if(!source)
		return null
	for(var/datum/musk_bond/bond as anything in scent_bonds)
		if(bond.source == source)
			return bond
	return null

/datum/mind/proc/open_scent_bond(datum/mind/source)
	RETURN_TYPE(/datum/musk_bond)
	return get_scent_bond(source) || new /datum/musk_bond(src, source)

/datum/musk_bond
	var/datum/mind/thrall
	var/datum/mind/source
	var/thrall_name
	var/source_name
	var/level = 0
	var/points = 0
	var/rested = TRUE
	var/last_rise_day = -1
	var/told_to_sleep = FALSE
	var/fated = FALSE
	var/recalled = FALSE
	var/greeting
	var/list/next_gain_times = list()
	var/datum/component/musk/reaching_musk
	COOLDOWN_DECLARE(order_cooldown)

/datum/musk_bond/New(datum/mind/new_thrall, datum/mind/new_source)
	. = ..()
	thrall = new_thrall
	source = new_source
	thrall_name = thrall.current?.real_name || thrall.name
	source_name = source.current?.real_name || source.name
	LAZYADD(thrall.scent_bonds, src)
	LAZYADD(source.scent_followers, src)
	RegisterSignal(thrall, COMSIG_PARENT_QDELETING, PROC_REF(on_mind_deleted))
	RegisterSignal(source, COMSIG_PARENT_QDELETING, PROC_REF(on_mind_deleted))
	RegisterSignal(thrall, COMSIG_MIND_TRANSFERRED, PROC_REF(on_thrall_transferred))
	RegisterSignal(SSdcs, COMSIG_GLOB_TIME_OF_DAY_CHANGED, PROC_REF(on_time_of_day_changed))
	recall()

/datum/musk_bond/Destroy(force)
	end_contact()
	LAZYREMOVE(thrall.scent_bonds, src)
	LAZYREMOVE(source.scent_followers, src)
	thrall = null
	source = null
	return ..()

/datum/musk_bond/proc/on_mind_deleted(datum/deleted)
	SIGNAL_HANDLER
	qdel(src)

/datum/musk_bond/proc/on_thrall_transferred(datum/transferred, mob/previous_body)
	SIGNAL_HANDLER
	if(level)
		get_thrall_body()?.learn_to_review_scent_bonds()

/datum/musk_bond/proc/on_time_of_day_changed(datum/signal_source, new_tod, old_tod)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/body = get_thrall_body()
	if(new_tod != "dawn" || !body || body.stat == DEAD)
		return
	if(!body.can_sleep_the_night())
		rested = TRUE
	try_rise(TRUE)

/datum/musk_bond/proc/get_thrall_body()
	RETURN_TYPE(/mob/living/carbon/human)
	return ishuman(thrall?.current) ? thrall.current : null

/datum/musk_bond/proc/get_limit()
	return get_thrall_body()?.get_scent_bond_limit() || 0

/datum/musk_bond/proc/get_level()
	return min(level, get_limit())

/datum/musk_bond/proc/is_unmet()
	return greeting == MUSK_GREETING_FATED

/datum/musk_bond/proc/get_source_label()
	if(!is_unmet() && thrall.do_i_know(source, source_name))
		return source_name
	return musk_localized(thrall.current, "a stranger", "кто-то незнакомый")

/datum/musk_bond/proc/get_thrall_label()
	if(source.do_i_know(thrall, thrall_name))
		return thrall_name
	return musk_localized(source.current, "a stranger", "кто-то незнакомый")

/datum/musk_bond/proc/gain(kind)
	if(world.time < next_gain_times[kind])
		return FALSE
	var/static/list/gain_points = MUSK_GAIN_POINTS
	var/static/list/long_cooldowns = MUSK_GAIN_LONG_COOLDOWNS
	next_gain_times[kind] = world.time + (long_cooldowns[kind] || MUSK_GAIN_COOLDOWN)
	recall()
	if(level >= get_limit())
		return FALSE
	points = min(points + gain_points[kind], MUSK_BOND_POINTS_PER_LEVEL)
	try_rise()
	return TRUE

/datum/musk_bond/proc/settle()
	rested = TRUE
	try_rise(TRUE)

/datum/musk_bond/proc/try_rise(quiet = FALSE)
	if(points < MUSK_BOND_POINTS_PER_LEVEL || level >= get_limit())
		return FALSE
	if(!rested || last_rise_day == GLOB.payroll_day_number)
		if(!quiet)
			urge_to_sleep()
		return FALSE
	rested = FALSE
	last_rise_day = GLOB.payroll_day_number
	set_level(level + 1)
	return TRUE

/datum/musk_bond/proc/urge_to_sleep()
	var/mob/living/carbon/human/body = get_thrall_body()
	if(told_to_sleep || !body)
		return
	told_to_sleep = TRUE
	to_chat(body, span_love(musk_bond_wait_text(body, body.can_sleep_the_night())))

/datum/musk_bond/proc/set_level(new_level)
	level = clamp(new_level, 0, MUSK_BOND_LEVEL_MAX)
	points = 0
	told_to_sleep = FALSE
	remember()
	reaching_musk?.refresh_orders()
	var/mob/living/carbon/human/body = get_thrall_body()
	if(!body)
		return
	body.learn_to_review_scent_bonds()
	if(level == MUSK_BOND_OBEDIENCE)
		body.remove_stress(/datum/stress_event/musk_foul)
	to_chat(body, span_love(musk_bond_level_text(body, level, get_source_label())))

/datum/musk_bond/proc/reach(datum/component/musk/musk)
	var/mob/living/carbon/human/body = get_thrall_body()
	var/turf/thrall_turf = get_turf(body)
	var/turf/source_turf = get_turf(musk?.parent)
	if(!thrall_turf || thrall_turf.z != source_turf?.z || !can_see(source_turf, thrall_turf, MUSK_BOND_RANGE))
		return FALSE
	if(!get_level() || !body.can_smell_musk())
		return FALSE
	body.feel_scent_bond(src, musk)
	return TRUE

/datum/musk_bond/proc/begin_contact(datum/component/musk/musk)
	if(reaching_musk == musk)
		return FALSE
	end_contact()
	reaching_musk = musk
	LAZYADD(musk.bonds_in_reach, src)
	greet()
	musk.refresh_orders()
	return TRUE

/datum/musk_bond/proc/end_contact()
	var/datum/component/musk/musk = reaching_musk
	if(!musk)
		return
	reaching_musk = null
	LAZYREMOVE(musk.bonds_in_reach, src)
	musk.refresh_orders()

/datum/musk_bond/proc/greet()
	if(!greeting)
		return
	to_chat(thrall.current, span_love(musk_bond_greeting_text(thrall.current, greeting)))
	greeting = null

/datum/musk_bond/proc/sever()
	var/mob/living/carbon/human/body = get_thrall_body()
	if(body)
		to_chat(body, span_notice(musk_bond_severed_text(body)))
	forget()
	qdel(src)

/datum/mind/proc/get_scent_follower_labels()
	. = list()
	for(var/datum/musk_bond/bond as anything in scent_followers)
		var/bond_level = bond.get_level()
		if(bond_level >= MUSK_BOND_OBEDIENCE && !bond.is_unmet())
			. += "[bond.get_thrall_label()] (\Roman[bond_level])"

/datum/mind/proc/get_scent_bond_choices()
	. = list()
	var/list/used_labels = list()
	for(var/datum/musk_bond/bond as anything in scent_bonds)
		if(bond.level)
			.[avoid_assoc_duplicate_keys("[bond.get_source_label()] (\Roman[bond.level])", used_labels)] = bond

/mob/living/carbon/human/proc/can_sleep_the_night()
	return !HAS_TRAIT(src, TRAIT_NOSLEEP) || HAS_TRAIT(src, TRAIT_REVERIE)

/mob/living/carbon/human/proc/learn_to_review_scent_bonds()
	if(!(/mob/living/carbon/human/proc/review_scent_bonds in verbs))
		add_verb(src, /mob/living/carbon/human/proc/review_scent_bonds)

/mob/living/carbon/human/proc/review_scent_bonds()
	set name = "Scent Bonds"
	set category = "IC"
	set desc = "Think of the scents that hold me, and of those my own scent holds."

	if(!mind)
		return
	var/list/followers = mind.get_scent_follower_labels()
	if(length(followers))
		to_chat(src, span_love(musk_bond_followers_text(src, followers)))
	var/list/choices = mind.get_scent_bond_choices()
	if(!length(choices))
		if(!length(followers))
			to_chat(src, span_notice(musk_bond_none_text(src)))
		return
	var/choice = tgui_input_list(src, musk_localized(src, "These scents hold me. Which one do I put out of my mind for good?", "Эти запахи держат меня. Какой из них я навсегда выброшу из головы?"), musk_bond_title(src), choices)
	if(!choice)
		return
	var/datum/musk_bond/bond = choices[choice]
	if(!QDELETED(bond) && bond.thrall == mind)
		bond.sever()
