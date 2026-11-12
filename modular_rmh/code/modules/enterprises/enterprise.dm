/datum/enterprise
	abstract_type = /datum/enterprise
	var/name = "enterprise"
	var/list/owner_jobs = list()
	var/list/manager_jobs = list()
	var/list/staff_jobs = list()
	var/list/ledger_pages = list("overview")
	var/list/owner_pages = list("premises")
	var/list/obj/structure/fake_machine/enterprise_ledger/ledgers = list()
	var/ledger_type
	var/shift_active = FALSE
	var/list/datum/enterprise_floor/floors = list()
	var/premises_hint = "Place the ledger on an area that belongs to the enterprise."

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
	fixture_refs = null
	QDEL_LIST(room_templates)
	QDEL_LIST(furnishings)
	QDEL_LIST(patrons)
	furnishing_by_type = null
	rested_today = null
	night_fees = null
	staff_shares = null
	order_log = null
	owner_ref = null
	QDEL_NULL(map_catcher)
	QDEL_LIST(map_plane_masters)
	shown_plane_masters = null
	anchors = null
	claimed_by_z = null
	SSenterprises.enterprises -= type
	return ..()

/datum/enterprise/proc/find_ledger_spot()
	return null

/datum/enterprise/proc/place_ledger()
	if(length(ledgers) || !ledger_type)
		return FALSE
	var/turf/spot = find_ledger_spot()
	if(!spot)
		return FALSE
	new ledger_type(spot)
	log_game("[name]: the ledger was set up at [AREACOORD(spot)]")
	return TRUE

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
		"frame" = list(frame_width, frame_height),
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
		"damaged" = get_damaged_data(),
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
			return press(ui.user, action) && start_shift(ui.user)
		if("end_shift")
			return press(ui.user, action) && end_shift(ui.user)
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
		if("map_fit")
			set_map_fit(ui.user, params["fit"])
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
			if(press(ui.user, action))
				survey_again(ui.user)
			return FALSE
		if("call_guest")
			return press(ui.user, action) && call_guest(ui.user)
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
			return FALSE
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
				changed = room.get_members()
			for(var/datum/enterprise_room/target as anything in changed)
				target.set_level(level)
			redraw()
			return FALSE
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
			return FALSE
		if("debug_new_day")
			new_day()
			if(!morning_guest_kind)
				admit_morning_guest()
			return FALSE
		if("debug_evening")
			collect_rent()
			return FALSE
		if("debug_orders")
			call_lodgers_to_order(100)
			return FALSE
		if("debug_tired")
			var/mob/living/carbon/human/sleeper = user
			if(!istype(sleeper))
				return FALSE
			sleeper.apply_status_effect(/datum/status_effect/debuff/sleepytime)
			return FALSE
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
	staff_lock_ids = list(ACCESS_INN)
	owner_keyring = /obj/item/storage/keyring/tavern_keeper
	ledger_type = /obj/structure/fake_machine/enterprise_ledger/tavern

/datum/enterprise/tavern/is_premises_area(area/place)
	return place?.tavern_area

/datum/enterprise/tavern/find_ledger_spot()
	for(var/area/place as anything in GLOB.areas)
		if(!is_premises_area(place))
			continue
		for(var/turf/member as anything in place.get_turfs_from_all_zlevels())
			if(!(locate(/obj/structure/fake_machine/vendor/inn_rmh) in member))
				continue
			for(var/direction in GLOB.cardinals)
				var/turf/spot = get_step(member, direction)
				if(spot && !isclosedturf(spot) && is_premises_turf(spot) && !spot.is_blocked_turf(TRUE))
					return spot
	return null

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
	enterprise_drink_entries()
	for(var/enterprise_type in subtypesof(/datum/enterprise))
		get_enterprise(enterprise_type)
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		enterprise.mark_round_start_stock()
		for(var/obj/structure/fake_machine/enterprise_ledger/ledger as anything in enterprise.ledgers)
			enterprise.claim_premises(ledger)
		if(!length(enterprise.ledgers))
			enterprise.record_round_start()
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
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		switch(new_tod)
			if("dawn")
				INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, new_day))
			if("dusk")
				INVOKE_ASYNC(enterprise, TYPE_PROC_REF(/datum/enterprise, collect_rent))

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

/datum/controller/subsystem/enterprises/proc/note_meal(mob/living/eater, first_bite)
	var/datum/enterprise/enterprise = get_enterprise_at(eater)
	if(enterprise)
		enterprise.handle_meal(eater, first_bite)

/datum/controller/subsystem/enterprises/proc/note_door_lock(obj/structure/door/door)
	for(var/enterprise_type in enterprises)
		var/datum/enterprise/enterprise = enterprises[enterprise_type]
		if(enterprise.is_exit_door(door))
			enterprise.guests_changed()

/datum/status_effect/debuff/sleepytime/on_remove()
	. = ..()
	if(ishuman(owner) && !QDELETED(owner) && owner.IsSleeping())
		SSenterprises.note_rest(owner)

/mob/living/carbon/human/finish_night_rest()
	. = ..()
	SSenterprises.note_night(src)

/obj/item/reagent_containers/food/snacks/on_consume(mob/living/eater)
	. = ..()
	if(eater?.buckled)
		SSenterprises.note_meal(eater, bitecount <= 1)

/obj/item/key/Initialize(mapload)
	. = ..()
	SSenterprises.note_key(src)

/obj/structure/door/on_lock(mob/living/user, obj/item, silent = FALSE)
	. = ..()
	SSenterprises.note_door_lock(src)

/obj/structure/door/on_unlock(mob/living/user, obj/item, silent = FALSE)
	. = ..()
	SSenterprises.note_door_lock(src)
