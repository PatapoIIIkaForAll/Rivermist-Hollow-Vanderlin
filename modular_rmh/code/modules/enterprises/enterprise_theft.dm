#define ENTERPRISE_THEFT_TRACK_CHANCE 75
#define ENTERPRISE_THEFT_SNEAK_SKILL SKILL_LEVEL_EXPERT
#define ENTERPRISE_THEFT_TAIL_TIME (5 MINUTES)
#define ENTERPRISE_THEFT_STAFF_EASE 3
#define ENTERPRISE_THEFT_NAME_ANALYSIS 4
#define ENTERPRISE_THEFT_SHOW_RANGE 7
#define ENTERPRISE_THEFT_CARRIED 1
#define ENTERPRISE_THEFT_DRAGGED 2

/datum/enterprise
	var/theft_from = "the premises"
	var/theft_from_ru = "заведения"

/datum/enterprise/tavern
	theft_from = "the tavern"
	theft_from_ru = "таверны"

/mob/living
	var/datum/enterprise_theft/enterprise_theft

/datum/enterprise_theft
	var/list/datum/weakref/carried = list()
	var/list/datum/weakref/outside = list()
	var/tail_until = 0
	var/tail_name
	var/tail_from
	var/thing_name
	var/enterprise_type
	var/after = FALSE
	var/dragged = FALSE

/datum/enterprise_theft/proc/get_hold(atom/movable/thing, mob/living/walker)
	var/atom/movable/current = thing
	while(ismovable(current))
		if(current == walker)
			return ENTERPRISE_THEFT_CARRIED
		if(isliving(current))
			return NONE
		if(current.pulledby)
			return current.pulledby == walker ? ENTERPRISE_THEFT_DRAGGED : NONE
		current = current.loc
	return NONE

/datum/enterprise_theft/proc/get_chance(mob/living/walker)
	if(walker.m_intent != MOVE_INTENT_SNEAK)
		return ENTERPRISE_THEFT_TRACK_CHANCE
	var/skill = max(GET_MOB_SKILL_VALUE(walker, /datum/attribute/skill/misc/sneaking) || 0, 0)
	if(skill >= ENTERPRISE_THEFT_SNEAK_SKILL)
		return 0
	return ENTERPRISE_THEFT_TRACK_CHANCE * (ENTERPRISE_THEFT_SNEAK_SKILL - skill) / ENTERPRISE_THEFT_SNEAK_SKILL

/datum/enterprise_theft/proc/roll_track(mob/living/walker, turf/new_turf)
	var/obj/taken
	var/taken_hold = NONE
	var/datum/enterprise/source
	var/list/datum/weakref/lost
	for(var/datum/weakref/ref as anything in carried)
		var/obj/thing = ref.resolve()
		var/datum/enterprise/owner = SSenterprises.enterprises[carried[ref]]
		var/hold = (QDELETED(thing) || !owner?.is_bound(thing)) ? NONE : get_hold(thing, walker)
		if(!hold)
			LAZYADD(lost, ref)
			continue
		if(owner.contains(thing))
			outside -= ref
			continue
		outside[ref] = thing.name
		if(!taken || hold > taken_hold)
			taken = thing
			taken_hold = hold
			source = owner
	for(var/datum/weakref/ref as anything in lost)
		if(outside[ref])
			tail_until = world.time + ENTERPRISE_THEFT_TAIL_TIME
			tail_name = outside[ref]
			tail_from = carried[ref]
		carried -= ref
		outside -= ref
	if(!taken)
		if(world.time >= tail_until)
			if(!length(carried))
				walker.enterprise_theft = null
			return null
		source = SSenterprises.enterprises[tail_from]
		if(!source || source.contains(new_turf))
			return null
	if(!new_turf.track_prob || !prob(get_chance(walker)))
		return null
	after = !taken
	dragged = taken_hold == ENTERPRISE_THEFT_DRAGGED
	thing_name = taken ? taken.name : tail_name
	enterprise_type = source.type
	return src

/datum/enterprise_theft/proc/make_track(turf/new_turf, ordinary)
	var/obj/effect/skill_tracker/footprint/enterprise_theft/track = new(new_turf, new_turf)
	track.ordinary = ordinary
	track.enterprise_type = enterprise_type
	track.stolen_name = thing_name
	track.after = after
	if(dragged)
		track.real_icon_state = "tracks_structure"
	return track

/atom/movable/proc/get_enterprise_holder()
	var/atom/movable/current = src
	while(ismovable(current))
		if(isliving(current))
			return current
		if(current.pulledby)
			return current.pulledby
		current = current.loc
	return null

/datum/controller/subsystem/enterprises/proc/note_held(atom/movable/thing, mob/living/holder)
	if(!ishuman(holder) || !holder.mind)
		return
	if(thing.weak_reference)
		note_fixture(thing, holder)
	if(!length(thing.contents))
		return
	for(var/atom/movable/inner as anything in thing.get_all_contents())
		if(inner != thing && inner.weak_reference)
			note_fixture(inner, holder)

/datum/controller/subsystem/enterprises/proc/note_fixture(obj/thing, mob/living/holder)
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		if(!enterprise.is_bound(thing))
			continue
		if(!holder.enterprise_theft)
			holder.enterprise_theft = new
		holder.enterprise_theft.carried[thing.weak_reference] = enterprise_type
		return

/obj/item/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(!initial)
		SSenterprises.note_held(src, user)

/obj/item/on_enter_storage(datum/component/storage/concrete/S)
	. = ..()
	SSenterprises.note_held(src, get_enterprise_holder())

/mob/living/start_pulling(atom/movable/AM, state, force = pull_force, suppress_message = FALSE, obj/item/item_override, accurate = FALSE)
	. = ..()
	if(. && pulling == AM && !ismob(AM))
		SSenterprises.note_held(AM, src)

/mob/living/carbon/human/linepoint(atom/pointed_atom)
	if(istype(pointed_atom, /obj/effect/skill_tracker/footprint/enterprise_theft))
		pointed_atom = pointed_atom.loc
	return ..(pointed_atom)

/obj/effect/skill_tracker/footprint/enterprise_theft
	var/ordinary = FALSE
	var/enterprise_type
	var/stolen_name
	var/after = FALSE
	var/list/mob/living/shown_to

/obj/effect/skill_tracker/footprint/enterprise_theft/proc/is_staff(mob/user)
	var/datum/enterprise/enterprise = SSenterprises.enterprises[enterprise_type]
	return enterprise?.is_staff(user)

/obj/effect/skill_tracker/footprint/enterprise_theft/check_reveal(mob/living/user)
	if(!is_staff(user))
		return ordinary && ..()
	tracking_modifier -= ENTERPRISE_THEFT_STAFF_EASE
	. = ..()
	tracking_modifier += ENTERPRISE_THEFT_STAFF_EASE

/obj/effect/skill_tracker/footprint/enterprise_theft/handle_revealing(mob/living/user)
	if(!is_staff(user))
		return ..()
	tracking_modifier -= ENTERPRISE_THEFT_STAFF_EASE
	. = ..()
	tracking_modifier += ENTERPRISE_THEFT_STAFF_EASE

/obj/effect/skill_tracker/footprint/enterprise_theft/add_knower(mob/living/tracker, competence = 1)
	. = ..()
	if(is_staff(tracker))
		RegisterSignal(tracker, COMSIG_MOB_POINTED, PROC_REF(on_pointed), override = TRUE)

/obj/effect/skill_tracker/footprint/enterprise_theft/remove_knower(mob/living/tracker)
	UnregisterSignal(tracker, COMSIG_MOB_POINTED)
	LAZYREMOVE(shown_to, tracker)
	return ..()

/obj/effect/skill_tracker/footprint/enterprise_theft/proc/on_pointed(mob/living/pointer, atom/pointed)
	SIGNAL_HANDLER
	var/knowledge = known_by[pointer]
	if(pointed != loc || !knowledge)
		return
	for(var/mob/living/viewer in viewers(ENTERPRISE_THEFT_SHOW_RANGE, pointer))
		if(viewer == pointer || !viewer.mind || viewer.stat)
			continue
		var/had = known_by[viewer]
		if(!had)
			add_knower(viewer, knowledge)
		else
			known_by[viewer] = max(had, knowledge)
			if(!can_see_track(viewer))
				restore_image_for(viewer)
		LAZYSET(shown_to, viewer, TRUE)
		var/russian = get_preferred_ui_language(viewer) == "ru"
		to_chat(viewer, span_notice(russian ? "[pointer] показывает мне след." : "[pointer] shows me a track."))

/obj/effect/skill_tracker/footprint/enterprise_theft/knowledge_readout(mob/user)
	. = ..()
	var/knowledge = known_by?[user]
	if(!knowledge)
		return
	var/staff = is_staff(user)
	if(!staff && !LAZYACCESS(shown_to, user))
		return
	var/datum/enterprise/enterprise = SSenterprises.enterprises[enterprise_type]
	if(!enterprise)
		return
	var/russian = get_preferred_ui_language(user) == "ru"
	var/what = (stolen_name && knowledge >= ENTERPRISE_THEFT_NAME_ANALYSIS) ? stolen_name : (russian ? "что-то" : "something")
	if(russian)
		. += span_warning(after ? "Тот, кто здесь прошёл, недавно вынес [what] из [enterprise.theft_from_ru]." : "Тот, кто здесь прошёл, нёс [what] из [enterprise.theft_from_ru].")
	else
		. += span_warning(after ? "Whoever passed here had lately carried [what] away from [enterprise.theft_from]." : "Whoever passed here was carrying [what] from [enterprise.theft_from].")
	if(staff)
		. += span_info(russian ? "Можно указать на след (Ctrl+ПКМ), и его увидят все, кто рядом." : "Point at it (Ctrl+right-click) and everyone nearby will see it.")

#undef ENTERPRISE_THEFT_TRACK_CHANCE
#undef ENTERPRISE_THEFT_SNEAK_SKILL
#undef ENTERPRISE_THEFT_TAIL_TIME
#undef ENTERPRISE_THEFT_STAFF_EASE
#undef ENTERPRISE_THEFT_NAME_ANALYSIS
#undef ENTERPRISE_THEFT_SHOW_RANGE
#undef ENTERPRISE_THEFT_CARRIED
#undef ENTERPRISE_THEFT_DRAGGED
