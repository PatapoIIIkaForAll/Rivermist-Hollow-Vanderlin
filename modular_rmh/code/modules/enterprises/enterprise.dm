/datum/enterprise
	abstract_type = /datum/enterprise
	var/name = "enterprise"
	var/list/owner_jobs = list()
	var/list/manager_jobs = list()
	var/list/staff_jobs = list()
	var/list/ledger_pages = list("overview")
	var/list/owner_pages = list("premises")
	var/list/obj/structure/fake_machine/enterprise_ledger/ledgers = list()
	var/shift_active = FALSE
	var/list/datum/enterprise_floor/floors = list()
	var/premises_hint = "Place the ledger on an area that belongs to the enterprise."
	var/list/premises_maps = list()
	var/premises_level
	var/premises_loaded = FALSE
	var/loading_premises = FALSE

/datum/enterprise/Destroy()
	SStgui.close_uis(src)
	for(var/viewer_key in viewers.Copy())
		drop_viewer(viewer_key)
	for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in ledgers)
		ledger.enterprise = null
	ledgers = null
	guest_rooms = null
	QDEL_LIST(rooms)
	QDEL_LIST(floors)
	QDEL_LIST(fixtures)
	QDEL_LIST(room_templates)
	QDEL_LIST(furnishings)
	QDEL_LIST(patrons)
	furnishing_by_type = null
	rested_today = null
	owner_ref = null
	QDEL_NULL(map_backdrop)
	QDEL_NULL(map_catcher)
	QDEL_LIST(map_plane_masters)
	anchors = null
	claimed_by_z = null
	SSenterprises.enterprises -= type
	return ..()

/datum/enterprise/proc/get_plot_turfs()
	return list()

/datum/enterprise/proc/reset_premises()
	for(var/viewer_key in viewers.Copy())
		drop_viewer(viewer_key)
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons.Copy())
		patron.leave()
	QDEL_LIST(rooms)
	guest_rooms.Cut()
	QDEL_LIST(fixtures)
	QDEL_LIST(floors)
	anchors = list()
	claimed_by_z = list()

/datum/enterprise/proc/load_premises(level, grant_level)
	if(loading_premises || !length(premises_maps))
		return FALSE
	loading_premises = TRUE
	level = clamp(level, 0, length(premises_maps) - 1)
	var/loaded = place_premises(level)
	loading_premises = FALSE
	if(!loaded)
		return FALSE
	premises_level = level
	grant_on_survey = grant_level
	for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in ledgers)
		claim_premises(ledger)
	grant_on_survey = null
	return TRUE

/datum/enterprise/proc/place_premises(level)
	var/map_path = premises_maps[level + 1]
	var/list/turf/plot = get_plot_turfs()
	if(!length(plot))
		log_mapping("Map issue: the [name] has no plot to load [map_path] onto. [premises_hint]")
		return FALSE
	var/turf/first = plot[1]
	var/min_x = first.x
	var/max_x = first.x
	var/min_y = first.y
	var/max_y = first.y
	var/min_z = first.z
	for(var/turf/member as anything in plot)
		min_x = min(min_x, member.x)
		max_x = max(max_x, member.x)
		min_y = min(min_y, member.y)
		max_y = max(max_y, member.y)
		min_z = min(min_z, member.z)
	var/datum/map_template/template = new(map_path, "[name] premises, owner level [level]", TRUE)
	if(template.width != max_x - min_x + 1 || template.height != max_y - min_y + 1)
		log_mapping("Map issue: [map_path] is [template.width]x[template.height] tiles, but the [name] plot is [max_x - min_x + 1]x[max_y - min_y + 1]. The premises were left as mapped.")
		return FALSE
	reset_premises()
	clear_plot(plot)
	if(!template.load(locate(min_x, min_y, min_z)))
		log_mapping("Map issue: [map_path] could not be loaded for the [name].")
		return FALSE
	log_game("[name] premises loaded from [map_path] at [min_x],[min_y],[min_z]")
	return TRUE

/datum/enterprise/proc/clear_plot(list/turf/plot)
	for(var/turf/member as anything in plot)
		for(var/obj/thing in member)
			if(keeps_on_plot(thing))
				continue
			for(var/obj/inner in thing)
				qdel(inner)
			qdel(thing)
		CHECK_TICK

/datum/enterprise/proc/keeps_on_plot(obj/thing)
	if(istype(thing, /obj/effect/landmark))
		return TRUE
#ifdef TAVERN_TEST
	if(istype(thing, /obj/structure/throne) || istype(thing, /obj/structure/fake_machine/titan))
		return TRUE
#endif
	return FALSE

/datum/enterprise/proc/is_owner(mob/user)
	return is_type_in_list(user?.mind?.assigned_role, owner_jobs)

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
		"map" = map_key,
		"floors" = get_floors_data(),
		"rooms" = get_rooms_data(),
	)

/datum/enterprise/ui_data(mob/user)
	var/owner = is_owner(user)
	var/list/pages = owner ? ledger_pages : ledger_pages - owner_pages
	var/list/debug
#ifdef TAVERN_TEST
	pages = pages + "debug"
	debug = get_debug_data(user)
#endif
	return list(
		"pages" = pages,
		"debug" = debug,
		"can_manage" = is_manager(user),
		"is_staff" = is_staff(user),
		"shift_active" = shift_active,
		"viewed_z" = get_viewer(user)?.z,
		"book_balance" = book_balance,
		"earned_round" = earned_round,
		"earned_today" = earned_today,
		"prestige" = owner ? get_prestige_data() : null,
		"guests" = get_guests_data(user),
		"occupants" = get_occupants_data(),
	)

/datum/enterprise/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return FALSE
#ifdef TAVERN_TEST
	var/debugged = debug_act(action, params, ui.user)
	if(!isnull(debugged))
		return debugged
#endif
	switch(action)
		if("start_shift")
			return start_shift(ui.user)
		if("end_shift")
			return end_shift(ui.user)
		if("open_premises")
			if(open_premises(ui.user))
				ui.send_update()
			return FALSE
		if("view_floor")
			var/z = params["z"]
			if(!isnum(z) || z != round(z))
				return FALSE
			if(show_floor(ui.user, z))
				ui.send_update()
			return FALSE
		if("reset_view")
			reset_view(ui.user)
			return FALSE
		if("hide_floors")
			hide_floors(ui.user)
			return FALSE
		if("hover_room")
			hover_room(ui.user, get_room_by_id(params["room"]))
			return FALSE
		if("open_room")
			var/datum/enterprise_room/room = get_room_by_id(params["room"])
			if(room)
				room_action(ui.user, room, ENTERPRISE_ROOM_ACTION_INFO)
			return FALSE
		if("survey_again")
			survey_again(ui.user)
			return FALSE
		if("call_guest")
			return call_guest(ui.user)
	return FALSE

/datum/enterprise/ui_close(mob/user)
	. = ..()
	hide_floors(user)

#ifdef TAVERN_TEST
/datum/enterprise/proc/get_debug_data(mob/user)
	var/list/kinds = list()
	for(var/mob/living/simple_animal/enterprise_patron/patron_type as anything in typesof(/mob/living/simple_animal/enterprise_patron))
		kinds += initial(patron_type.name)
	return list(
		"bank" = get_bank_balance(user),
		"owner_level" = owner_level,
		"max_owner_level" = length(prestige_thresholds),
		"max_room_level" = ENTERPRISE_MAX_LEVEL,
		"patrons" = length(patrons),
		"patron_kinds" = kinds,
	)

/datum/enterprise/proc/debug_act(action, list/params, mob/user)
	switch(action)
		if("debug_set")
			var/value = params["value"]
			if(!isnum(value))
				return FALSE
			value = max(round(value), 0)
			switch(params["field"])
				if("book")
					book_balance = value
				if("bank")
					SStreasury.bank_accounts[user] = value
				if("earned_today")
					earned_today = value
				if("earned_round")
					earned_round = value
					write_journal()
				if("owner_level")
					owner_level = min(value, length(prestige_thresholds))
				else
					return FALSE
			return TRUE
		if("debug_grant")
			if(grant_owner_rooms(owner_level))
				redraw()
			return TRUE
		if("debug_reload")
			return load_premises(owner_level, owner_level)
		if("debug_room_level")
			var/level = params["level"]
			var/room_id = params["room"]
			if(!isnum(level))
				return FALSE
			var/list/datum/enterprise_room/changed = rooms
			if(room_id)
				var/datum/enterprise_room/room = get_room_by_id(room_id)
				if(!room)
					return FALSE
				changed = list(room)
			for(var/datum/enterprise_room/target as anything in changed)
				target.set_level(level)
			redraw()
			return TRUE
		if("debug_patron")
			var/list/patron_types = typesof(/mob/living/simple_animal/enterprise_patron)
			var/kind = params["kind"]
			if(!isnum(kind) || kind != round(kind) || kind < 1 || kind > length(patron_types))
				return FALSE
			if(!summon_patron(patron_types[kind], get_exit_turf(user) || get_turf(user)))
				return FALSE
			return TRUE
		if("debug_clear_patrons")
			for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons.Copy())
				patron.leave()
			update_static_data_for_all_viewers()
			return TRUE
		if("debug_new_day")
			new_day(TRUE)
			return TRUE
		if("debug_tired")
			var/mob/living/carbon/human/sleeper = user
			if(!istype(sleeper))
				return FALSE
			sleeper.apply_status_effect(/datum/status_effect/debuff/sleepytime)
			return TRUE
	return null
#endif

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
	ledger_pages = list("overview", "guests", "premises", "prestige", "menu", "staff", "commissions")
	owner_pages = list("premises", "prestige")
	guest_kinds = list(
		/mob/living/simple_animal/enterprise_patron = 30,
		/mob/living/simple_animal/enterprise_patron/labourer = 25,
		/mob/living/simple_animal/enterprise_patron/sellsword = 15,
		/mob/living/simple_animal/enterprise_patron/merchant = 12,
		/mob/living/simple_animal/enterprise_patron/minstrel = 8,
		/mob/living/simple_animal/enterprise_patron/vagrant = 6,
		/mob/living/simple_animal/enterprise_patron/noble = 4,
	)
	premises_hint = "Place the ledger on an area with tavern_area set."
	premises_maps = list(
		"_maps/map_files/hsector/tavern/tavern_0.dmm",
		"_maps/map_files/hsector/tavern/tavern_1.dmm",
		"_maps/map_files/hsector/tavern/tavern_2.dmm",
		"_maps/map_files/hsector/tavern/tavern_3.dmm",
		"_maps/map_files/hsector/tavern/tavern_4.dmm",
	)
	staff_lock_ids = list(ACCESS_INN)
	owner_keyring = /obj/item/storage/keyring/tavern_keeper

/datum/enterprise/tavern/is_premises_turf(turf/checked)
	var/area/checked_area = checked.loc
	return checked_area.tavern_area

/datum/enterprise/tavern/get_plot_turfs()
	var/list/turf/plot = list()
	for(var/area/place as anything in GLOB.areas)
		if(place.tavern_area)
			plot += place.get_turfs_from_all_zlevels()
	return plot

/area/under/town/rmh/basement/tavern
	tavern_area = TRUE

/obj/structure/fake_machine/enterprise_ledger
	name = "enterprise ledger"
	desc = "A heavy ledger on a pedestal, kept for the running of a business."
	icon = 'icons/obj/questing.dmi'
	icon_state = "contractledger"
	density = TRUE
	max_integrity = 0
	obj_flags = CAN_BE_HIT | USES_TGUI
	var/enterprise_type
	var/datum/enterprise/enterprise

/obj/structure/fake_machine/enterprise_ledger/Initialize(mapload)
	. = ..()
	enterprise = SSenterprises.get_enterprise(enterprise_type)
	if(!enterprise)
		return
	enterprise.ledgers += src
	if(SSenterprises.initialized)
		enterprise.claim_premises(src)

/obj/structure/fake_machine/enterprise_ledger/Destroy()
	if(enterprise)
		enterprise.ledgers -= src
		enterprise = null
	return ..()

/obj/structure/fake_machine/enterprise_ledger/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user) || !enterprise)
		return
	if(!enterprise.is_staff(user))
		to_chat(user, span_warning("The ledger's columns mean nothing to me."))
		return
	enterprise.ui_interact(user)

/obj/structure/fake_machine/enterprise_ledger/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!enterprise || !istype(tool, /obj/item/coin) || istype(tool, /obj/item/coin/inqcoin))
		return NONE
	var/russian = get_preferred_ui_language(user) == "ru"
	if(!enterprise.is_manager(user))
		to_chat(user, span_warning(russian ? "Вносить деньги в книгу может только управляющий." : "Only those who run the place may pay into the ledger."))
		return ITEM_INTERACT_BLOCKING
	var/value = tool.get_real_price()
	if(value <= 0)
		return ITEM_INTERACT_BLOCKING
	qdel(tool)
	enterprise.earn(value)
	playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
	to_chat(user, span_notice(russian ? "В книгу внесено [value]. Забрать их обратно нельзя." : "[value] has gone into the ledger. It cannot be taken back out."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/fake_machine/enterprise_ledger/tavern
	name = "tavern ledger"
	desc = "The tavern's book of accounts: its menu, its staff and its rooms."
	enterprise_type = /datum/enterprise/tavern

SUBSYSTEM_DEF(enterprises)
	name = "Enterprises"
	init_order = INIT_ORDER_OVERLAY - 1
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 2 SECONDS
	var/list/datum/enterprise/enterprises = list()
	var/list/datum/enterprise/currentrun = list()
	var/list/datum/weakref/pending_keys = list()
	var/keys_ready = FALSE

/datum/controller/subsystem/enterprises/Initialize()
	for(var/enterprise_type in subtypesof(/datum/enterprise))
		get_enterprise(enterprise_type)
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		var/loaded = FALSE
#ifdef TAVERN_TEST
		loaded = enterprise.load_premises(ENTERPRISE_LEVEL_BARE)
#endif
		if(!loaded)
			for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in enterprise.ledgers)
				enterprise.claim_premises(ledger)
		enterprise.recover_journal()
	keys_ready = TRUE
	for(var/datum/weakref/key_ref as anything in pending_keys)
		var/obj/item/key/key = key_ref.resolve()
		if(!QDELETED(key))
			note_key(key)
	pending_keys = null
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_spawn))
	RegisterSignal(SSdcs, COMSIG_GLOB_TIME_OF_DAY_CHANGED, PROC_REF(on_time_of_day))
	LAZYADD(SSticker.round_end_events, CALLBACK(src, PROC_REF(on_round_end)))
	return ..()

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
		if(!QDELETED(enterprise))
			if(enterprise.shift_active)
				enterprise.process_shift(delta_time)
			if(COOLDOWN_FINISHED(enterprise, upkeep_cooldown))
				COOLDOWN_START(enterprise, upkeep_cooldown, ENTERPRISE_UPKEEP_INTERVAL)
				enterprise.upkeep()
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

/datum/controller/subsystem/enterprises/proc/get_enterprise_at(atom/place)
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		if(enterprise.contains(place))
			return enterprise
	return null

/datum/controller/subsystem/enterprises/proc/on_job_spawn(datum/source, datum/job/job, mob/living/carbon/human/spawned, client/player_client)
	SIGNAL_HANDLER
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		if(is_type_in_list(job, enterprise.owner_jobs))
			INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, welcome_owner), spawned, player_client?.ckey || spawned.ckey)

/datum/controller/subsystem/enterprises/proc/on_time_of_day(datum/source, new_tod, old_tod)
	SIGNAL_HANDLER
	if(new_tod != "dawn")
		return
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, new_day))

/datum/controller/subsystem/enterprises/proc/on_round_end()
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		enterprise.bank_experience()

/datum/controller/subsystem/enterprises/proc/note_key(obj/item/key/key)
	if(!keys_ready)
		pending_keys += WEAKREF(key)
		return
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		enterprise.track_key(key)

/datum/controller/subsystem/enterprises/proc/note_rest(mob/living/carbon/human/sleeper)
	var/datum/enterprise/enterprise = get_enterprise_at(sleeper)
	if(enterprise)
		enterprise.handle_rest(sleeper)

/datum/controller/subsystem/enterprises/proc/note_night(mob/living/carbon/human/sleeper)
	var/datum/enterprise/enterprise = get_enterprise_at(sleeper)
	if(enterprise)
		enterprise.handle_night(sleeper)

/datum/controller/subsystem/enterprises/proc/note_meal(mob/living/eater)
	var/datum/enterprise/enterprise = get_enterprise_at(eater)
	if(enterprise)
		enterprise.handle_meal(eater)

/datum/status_effect/debuff/sleepytime/on_remove()
	. = ..()
	if(ishuman(owner) && owner.IsSleeping())
		SSenterprises.note_rest(owner)

/mob/living/carbon/human/finish_night_rest()
	. = ..()
	SSenterprises.note_night(src)

/obj/item/reagent_containers/food/snacks/on_consume(mob/living/eater)
	. = ..()
	if(eater?.buckled)
		SSenterprises.note_meal(eater)

/obj/item/key/Initialize(mapload)
	. = ..()
	SSenterprises.note_key(src)
