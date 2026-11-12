/datum/enterprise
	COOLDOWN_DECLARE(upkeep_cooldown)
	var/list/mob/living/simple_animal/enterprise_patron/patrons = list()
	var/list/exit_doors
	var/list/datum/weakref/key_vendors

/datum/enterprise/proc/get_key_room(obj/item/key/key)
	for(var/lock_id in key.get_access())
		var/datum/enterprise_room/room = guest_rooms[lock_id]
		if(room)
			return room
	return null

/datum/enterprise/proc/track_key(obj/item/key/key)
	var/list/access = key.get_access()
	if(!length(access))
		return FALSE
	var/list/own = get_own_lock_ids()
	if(!length((access & own) - staff_lock_ids))
		return FALSE
	RegisterSignal(key, COMSIG_ITEM_EQUIPPED, PROC_REF(on_key_equipped), override = TRUE)
	return TRUE

/datum/enterprise/proc/on_key_equipped(obj/item/key/key, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!ishuman(equipper))
		return
	var/datum/enterprise_room/room = get_key_room(key)
	if(!room)
		return
	if(is_staff(equipper))
		if(room.tenant_key?.resolve() == key)
			room.end_tenancy()
		return
	room.let_to(equipper, key)

/datum/enterprise/proc/get_key_vendors()
	var/list/obj/structure/fake_machine/vendor/found = list()
	for(var/datum/weakref/vendor_ref as anything in key_vendors)
		var/obj/structure/fake_machine/vendor/vendor = vendor_ref.resolve()
		if(!QDELETED(vendor))
			found += vendor
	if(length(found))
		return found
	key_vendors = list()
	for(var/datum/enterprise_floor/floor as anything in floors)
		for(var/turf/member as anything in floor?.turfs)
			for(var/obj/structure/fake_machine/vendor/vendor in member)
				found += vendor
				key_vendors += WEAKREF(vendor)
	return found

/datum/enterprise/proc/take_room_key(datum/enterprise_room/room, mob/living/simple_animal/enterprise_patron/holder)
	if(!room.lock_id)
		return null
	for(var/obj/structure/fake_machine/vendor/vendor as anything in get_key_vendors())
		for(var/obj/item/key/key in vendor.held_items)
			if(!(room.lock_id in key.get_access()))
				continue
			holder.key_entry = vendor.held_items[key]
			vendor.held_items -= key
			vendor.update_appearance(UPDATE_OVERLAYS)
			key.forceMove(holder)
			holder.room_key = key
			holder.key_vendor = WEAKREF(vendor)
			return key
	return null

/datum/enterprise/proc/get_time_away(mob/living/who)
	if(!who)
		return INFINITY
	if(who.client)
		return 0
	return world.time - who.last_client_interact

/datum/enterprise/proc/get_eviction_time()
	return eviction_times[clamp(owner_level + 1, 1, length(eviction_times))]

/datum/enterprise/proc/get_patron_rent(datum/enterprise_room/room)
	var/percent = patron_rent_percents[clamp(owner_level + 1, 1, length(patron_rent_percents))]
	return round(get_rest_price(room) * percent / 100)

/datum/enterprise/proc/upkeep()
	check_tenants()
	check_patrons()
	welcome_morning_guest()
	if(journal_pending)
		write_journal()

/datum/enterprise/proc/check_tenants()
	var/limit = get_eviction_time()
	for(var/lock_id in guest_rooms)
		var/datum/enterprise_room/room = guest_rooms[lock_id]
		if(!room.tenant_name)
			continue
		var/obj/item/key/room_key = room.tenant_key?.resolve()
		if(QDELETED(room_key))
			room.end_tenancy()
			continue
		if(limit && world.time - room.tenant_seen > limit)
			evict(room)

/datum/enterprise/proc/evict(datum/enterprise_room/room, unpaid = FALSE)
	var/mob/living/guest = room.get_tenant()
	var/obj/item/key/key = room.tenant_key?.resolve()
	if(!QDELETED(key))
		qdel(key)
	var/turf/hallway = room.get_door_step()
	if(hallway)
		for(var/obj/item/left_behind as anything in room.get_loose_items())
			left_behind.forceMove(hallway)
		if(guest && get_time_away(guest) && get_room(guest) == room)
			guest.buckled?.unbuckle_mob(guest, TRUE)
			guest.forceMove(hallway)
	if(guest)
		var/russian = get_preferred_ui_language(guest) == "ru"
		if(unpaid)
			to_chat(guest, span_warning(russian \
				? "Пока меня не было, платить за комнату «[room.name]» было нечем: её освободили, а меня и мои вещи вынесли в коридор." \
				: "While I was away there was nothing to pay for [room.name] with: it has been cleared, and I and my things were put out in the hallway."))
		else
			to_chat(guest, span_warning(russian \
				? "Меня слишком долго не было: комнату «[room.name]» освободили, а вещи вынесли в коридор." \
				: "I have been away too long: [room.name] has been cleared, and my things were put out in the hallway."))
	log_game("[name]: [guest ? key_name(guest) : room.tenant_name] was put out of [room.name][unpaid ? " for not paying while away" : ""]")
	room.end_tenancy()

/datum/enterprise/proc/check_patrons()
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		if(patron.leaves_at && world.time >= patron.leaves_at)
			patron.depart()

/datum/enterprise/proc/collect_rent()
	var/total = 0
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		total += patron.get_rent_due()
	for(var/lock_id in guest_rooms)
		var/datum/enterprise_room/room = guest_rooms[lock_id]
		if(!room.tenant_name)
			continue
		var/due = room.get_away_rent()
		if(!due)
			continue
		var/mob/living/lodger = room.get_tenant()
		if(lodger && take_from_account(lodger, due))
			total += due
		else
			evict(room, TRUE)
	return earn(total)

/datum/enterprise_room/proc/get_tenant()
	var/mob/living/found = tenant?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_room/proc/get_patron()
	var/mob/living/simple_animal/enterprise_patron/found = patron?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_room/proc/get_occupant_name()
	var/mob/living/lodger = get_patron()
	return lodger ? lodger.name : tenant_name

/datum/enterprise_room/proc/get_away_rent()
	if(enterprise.get_time_away(get_tenant()) < ENTERPRISE_TENANT_AWAY_TIME)
		return 0
	return round(enterprise.get_rest_price(src) * ENTERPRISE_TENANT_AWAY_SHARE / 100)

/datum/enterprise_room/proc/let_to(mob/living/guest, obj/item/key/key)
	if(get_patron())
		var/russian = get_preferred_ui_language(guest) == "ru"
		to_chat(guest, span_warning(russian ? "Комната «[name]» занята постояльцем." : "[name] is taken by a lodger."))
		return FALSE
	var/datum/weakref/guest_ref = WEAKREF(guest)
	if(tenant == guest_ref && tenant_key?.resolve() == key)
		return TRUE
	if(tenant != guest_ref)
		tenant = guest_ref
		tenant_name = guest.real_name
		tenant_since = world.time
		tenant_seen = world.time
	tenant_key = WEAKREF(key)
	enterprise.guests_changed()
	SStgui.update_uis(src)
	return TRUE

/datum/enterprise_room/proc/end_tenancy()
	tenant = null
	tenant_name = null
	tenant_key = null
	tenant_since = 0
	tenant_seen = 0
	enterprise.guests_changed()
	SStgui.update_uis(src)

/datum/enterprise_room/proc/note_visit(mob/living/visitor)
	if(tenant && tenant.resolve() == visitor && !enterprise.get_time_away(visitor))
		tenant_seen = world.time

/datum/enterprise_room/proc/get_tenant_data()
	var/mob/living/simple_animal/enterprise_patron/lodger = get_patron()
	if(lodger)
		return list(
			"name" = lodger.name,
			"patron" = TRUE,
			"time_left" = max(patron_until - world.time, 0),
			"rent" = enterprise.get_patron_rent(src),
			"away" = null,
			"half" = FALSE,
			"needs" = lodger.requests,
		)
	if(!tenant_name)
		return null
	var/limit = enterprise.get_eviction_time()
	var/away = enterprise.get_time_away(get_tenant())
	var/half = away >= ENTERPRISE_TENANT_AWAY_TIME
	return list(
		"name" = tenant_name,
		"patron" = FALSE,
		"time_left" = limit ? max(tenant_seen + limit - world.time, 0) : null,
		"rent" = half ? get_away_rent() : enterprise.get_rest_price(src),
		"away" = (away && away != INFINITY) ? away : null,
		"half" = half,
		"needs" = list(),
	)
