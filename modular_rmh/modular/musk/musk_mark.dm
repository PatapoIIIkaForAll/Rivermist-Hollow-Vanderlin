GLOBAL_DATUM_INIT(scent_marks, /datum/scent_marks, new)

/datum/erp_preference/boolean/scent_mark
	name = "Scent Mark"
	description = "Somewhere out there is one more marked soul, and fate has already bound the two of you as deep as a scent can bind. It takes one with the Smell & Musk quirk and one with Musk Susceptibility and Scent Submission at V, both marked; chance picks the pair anew each round, and tells neither who the other is."
	default_value = FALSE
	category = "General"

/datum/erp_preference/boolean/scent_mark/set_value(datum/preferences/prefs, value)
	. = ..()
	var/mob/living/carbon/human/body = prefs?.parent?.mob
	if(value && ishuman(body))
		GLOB.scent_marks.expect(body)

/mob/living/carbon/human/proc/is_scent_marked()
	return get_erp_pref(/datum/erp_preference/boolean/scent_mark) == TRUE

/datum/scent_marks
	var/list/datum/weakref/arrivals = list()
	var/list/datum/weakref/waiting = list()
	var/list/datum/weakref/paired = list()

/datum/scent_marks/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_spawn))
	RegisterSignal(SSdcs, COMSIG_GLOB_TIME_OF_DAY_CHANGED, PROC_REF(on_time_of_day_changed))

/datum/scent_marks/proc/on_job_spawn(datum/source, datum/job/job, mob/living/carbon/human/spawned, client/player_client)
	SIGNAL_HANDLER
	if(ishuman(spawned))
		expect(spawned)

/datum/scent_marks/proc/on_time_of_day_changed(datum/source, new_tod, old_tod)
	SIGNAL_HANDLER
	match_pairs()

/datum/scent_marks/proc/expect(mob/living/carbon/human/body)
	arrivals |= WEAKREF(body)
	addtimer(CALLBACK(src, PROC_REF(match_pairs)), MUSK_MARK_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/scent_marks/proc/match_pairs()
	for(var/datum/weakref/body_ref as anything in arrivals)
		enlist(body_ref.resolve())
	arrivals.Cut()
	for(var/datum/weakref/mind_ref as anything in shuffle(waiting))
		var/datum/mind/marked = mind_ref.resolve()
		find_partner(marked?.current)

/datum/scent_marks/proc/enlist(mob/living/carbon/human/body)
	var/datum/weakref/mind_ref = WEAKREF(body?.mind)
	if(mind_ref && !(mind_ref in paired) && body.is_scent_marked())
		waiting |= mind_ref

/datum/scent_marks/proc/find_partner(mob/living/carbon/human/body)
	if(!can_be_paired(body))
		return
	var/list/mob/living/carbon/human/partners = list()
	for(var/datum/weakref/mind_ref as anything in waiting)
		var/datum/mind/marked = mind_ref.resolve()
		if(marked != body.mind && can_be_paired(marked?.current) && get_paired_source(body, marked.current))
			partners += marked.current
	if(length(partners))
		bind_pair(body, pick(partners))

/datum/scent_marks/proc/can_be_paired(mob/living/carbon/human/body)
	return ishuman(body) && body.client && body.stat != DEAD && (WEAKREF(body.mind) in waiting) && body.is_scent_marked()

/datum/scent_marks/proc/get_paired_source(mob/living/carbon/human/first, mob/living/carbon/human/second)
	RETURN_TYPE(/mob/living/carbon/human)
	if(first.get_musk() && second.get_scent_bond_limit() >= MUSK_BOND_DEVOTION)
		return first
	if(second.get_musk() && first.get_scent_bond_limit() >= MUSK_BOND_DEVOTION)
		return second
	return null

/datum/scent_marks/proc/bind_pair(mob/living/carbon/human/first, mob/living/carbon/human/second)
	var/mob/living/carbon/human/source = get_paired_source(first, second)
	var/mob/living/carbon/human/thrall = source == first ? second : first
	for(var/mob/living/carbon/human/body as anything in list(first, second))
		waiting -= WEAKREF(body.mind)
		paired += WEAKREF(body.mind)
	var/have_met = !!thrall.mind.get_scent_bond(source.mind)
	thrall.mind.open_scent_bond(source.mind).seal_by_fate(have_met)
	to_chat(thrall, span_love(musk_mark_thrall_text(thrall)))
	to_chat(source, span_love(musk_mark_source_text(source)))

/datum/musk_bond/proc/seal_by_fate(have_met)
	fated = TRUE
	level = MUSK_BOND_DEVOTION
	greeting = have_met ? null : MUSK_GREETING_FATED
	get_thrall_body()?.learn_to_review_scent_bonds()
	reaching_musk?.refresh_orders()
