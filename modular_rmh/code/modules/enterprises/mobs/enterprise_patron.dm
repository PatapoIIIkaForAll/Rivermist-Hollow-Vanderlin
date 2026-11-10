/mob/living/simple_animal/enterprise_patron
	name = "patron"
	desc = "A traveller after a meal and a bed."
	maxHealth = 100
	health = 100
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	faction = list(FACTION_TOWN)
	var/outfit_type = /datum/outfit/farmer_p
	var/datum/enterprise/enterprise
	var/datum/enterprise_room/lodging
	var/datum/enterprise_seating/table_set
	var/leaves_at = 0
	var/list/requests = list()

/mob/living/simple_animal/enterprise_patron/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, outfit_type)

/mob/living/simple_animal/enterprise_patron/Destroy()
	vacate()
	if(enterprise)
		enterprise.patrons -= src
		enterprise = null
	return ..()

/mob/living/simple_animal/enterprise_patron/proc/visit(datum/enterprise/visited)
	if(enterprise)
		enterprise.patrons -= src
	enterprise = visited
	visited.patrons |= src
	leaves_at = world.time + ENTERPRISE_PATRON_STAY_TIME

/mob/living/simple_animal/enterprise_patron/proc/take_room(datum/enterprise_room/wanted)
	if(wanted.tenant_name || wanted.get_patron() || wanted.kind != ENTERPRISE_ROOM_GUEST)
		return FALSE
	if(lodging)
		lodging.patron = null
	lodging = wanted
	wanted.patron = WEAKREF(src)
	wanted.patron_until = leaves_at
	return TRUE

/mob/living/simple_animal/enterprise_patron/proc/take_seat(datum/enterprise_seating/wanted)
	if(!wanted.is_free())
		return FALSE
	if(table_set)
		table_set.patron = null
	table_set = wanted
	wanted.patron = WEAKREF(src)
	return TRUE

/mob/living/simple_animal/enterprise_patron/proc/vacate()
	if(lodging)
		if(lodging.patron?.resolve() == src)
			lodging.patron = null
			lodging.patron_until = 0
		lodging = null
	if(table_set)
		if(table_set.patron?.resolve() == src)
			table_set.patron = null
		table_set = null

/mob/living/simple_animal/enterprise_patron/proc/pay_rent()
	if(!lodging || !enterprise)
		return 0
	var/rent = round(enterprise.get_rest_price(lodging) / ENTERPRISE_PATRON_RENT_DIVISOR)
	enterprise.earn(rent)
	return rent

/mob/living/simple_animal/enterprise_patron/proc/take_offence(mob/living/offender)
	visible_message(span_warning("[src] glares at [offender], gathers their things and walks out."))
	leave()

/mob/living/simple_animal/enterprise_patron/proc/leave()
	qdel(src)

/mob/living/simple_animal/enterprise_patron/vagrant
	name = "wanderer"
	outfit_type = /datum/outfit/vagrant

/mob/living/simple_animal/enterprise_patron/merchant
	name = "travelling merchant"
	outfit_type = /datum/outfit/waterdeep_merchant

/mob/living/simple_animal/enterprise_patron/sellsword
	name = "sellsword"
	outfit_type = /datum/outfit/adventurer_fighter/sellsword_hireling
