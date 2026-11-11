/datum/enterprise
	COOLDOWN_DECLARE(upkeep_cooldown)
	var/list/mob/living/simple_animal/enterprise_patron/patrons = list()
	var/list/exit_doors

/datum/enterprise/proc/get_key_room(obj/item/key/key)
	for(var/lock_id in key.get_access())
		var/datum/enterprise_room/room = guest_rooms[lock_id]
		if(room)
			return room
	return null

/datum/enterprise/proc/track_key(obj/item/key/key)
	var/list/access = key.get_access()
	if(!length(access) || !length(own_lock_ids) || !length((access & own_lock_ids) - staff_lock_ids))
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

/datum/enterprise/proc/get_eviction_time()
	return eviction_times[clamp(owner_level + 1, 1, length(eviction_times))]

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
		if(QDELETED(room.tenant_key?.resolve()))
			room.end_tenancy()
		else if(limit && world.time - room.tenant_seen > limit)
			evict(room)

/datum/enterprise/proc/evict(datum/enterprise_room/room)
	var/mob/living/guest = room.get_tenant()
	var/obj/item/key/key = room.tenant_key?.resolve()
	if(!QDELETED(key))
		qdel(key)
	var/turf/hallway = room.get_door_step()
	if(hallway)
		for(var/obj/item/left_behind as anything in room.get_loose_items())
			left_behind.forceMove(hallway)
	if(guest)
		var/russian = get_preferred_ui_language(guest) == "ru"
		to_chat(guest, span_warning(russian \
			? "Меня слишком долго не было: комнату «[room.name]» освободили, а вещи вынесли в коридор." \
			: "I have been away too long: [room.name] has been cleared, and my things were put out in the hallway."))
	room.end_tenancy()

/datum/enterprise/proc/check_patrons()
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		if(patron.leaves_at && world.time >= patron.leaves_at)
			patron.depart()

/datum/enterprise/proc/collect_patron_rent()
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		patron.pay_rent()

/datum/enterprise_room/proc/get_tenant()
	var/mob/living/found = tenant?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_room/proc/get_patron()
	var/mob/living/simple_animal/enterprise_patron/found = patron?.resolve()
	return QDELETED(found) ? null : found

/datum/enterprise_room/proc/get_occupant_name()
	var/mob/living/lodger = get_patron()
	return lodger ? lodger.name : tenant_name

/datum/enterprise_room/proc/let_to(mob/living/guest, obj/item/key/key)
	if(get_patron())
		var/russian = get_preferred_ui_language(guest) == "ru"
		to_chat(guest, span_warning(russian ? "Комната «[name]» занята постояльцем." : "[name] is taken by a lodger."))
		return FALSE
	var/datum/weakref/guest_ref = WEAKREF(guest)
	if(tenant != guest_ref)
		tenant = guest_ref
		tenant_name = guest.real_name
		tenant_since = world.time
		tenant_seen = world.time
	tenant_key = WEAKREF(key)
	enterprise.update_static_data_for_all_viewers()
	SStgui.update_uis(src)
	return TRUE

/datum/enterprise_room/proc/end_tenancy()
	tenant = null
	tenant_name = null
	tenant_key = null
	tenant_since = 0
	tenant_seen = 0
	enterprise.update_static_data_for_all_viewers()
	SStgui.update_uis(src)

/datum/enterprise_room/proc/note_visit(mob/living/visitor)
	if(tenant && tenant.resolve() == visitor)
		tenant_seen = world.time

/datum/enterprise_room/proc/get_tenant_data()
	var/mob/living/simple_animal/enterprise_patron/lodger = get_patron()
	var/rent = enterprise.get_rest_price(src)
	if(lodger)
		return list(
			"name" = lodger.name,
			"patron" = TRUE,
			"time_left" = max(patron_until - world.time, 0),
			"rent" = round(rent / ENTERPRISE_PATRON_RENT_DIVISOR),
			"needs" = lodger.requests,
		)
	if(!tenant_name)
		return null
	var/limit = enterprise.get_eviction_time()
	return list(
		"name" = tenant_name,
		"patron" = FALSE,
		"time_left" = limit ? max(tenant_seen + limit - world.time, 0) : null,
		"rent" = rent,
		"needs" = list(),
	)
