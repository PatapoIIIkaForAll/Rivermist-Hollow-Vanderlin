/obj/effect/mob_spawn/enterprise_guest
	name = "tavern guest look"
	abstract_type = /obj/effect/mob_spawn/enterprise_guest
	density = FALSE
	mob_type = /mob/living/carbon/human
	mob_species = /datum/species/human/northern
	randomise_dna = TRUE
	gender = MALE

/obj/effect/mob_spawn/enterprise_guest/special(mob/living/spawned_mob, mob/mob_possessor, apply_prefs, preview_only = FALSE)
	if(ishuman(spawned_mob))
		spawned_mob.gender = gender
	return ..()

/obj/effect/mob_spawn/enterprise_guest/equip(mob/living/spawned_mob)
	var/mob/living/carbon/human/guest = spawned_mob
	if(istype(guest) && outfit)
		guest.equipOutfit(outfit, TRUE)

/obj/effect/mob_spawn/enterprise_guest/commoner
	outfit = /datum/outfit/towner/commoner

/obj/effect/mob_spawn/enterprise_guest/commoner/female
	gender = FEMALE

/obj/effect/mob_spawn/enterprise_guest/commoner/half_orc
	mob_species = /datum/species/halforc

/obj/effect/mob_spawn/enterprise_guest/burgess
	outfit = /datum/outfit/towner/burgess

/obj/effect/mob_spawn/enterprise_guest/burgess/female
	gender = FEMALE
	mob_species = /datum/species/human/halfelf

/obj/effect/mob_spawn/enterprise_guest/passenger
	outfit = /datum/outfit/towner/passenger
	mob_species = /datum/species/human/halfelf

/obj/effect/mob_spawn/enterprise_guest/passenger/female
	gender = FEMALE
	mob_species = /datum/species/elf/snow

/obj/effect/mob_spawn/enterprise_guest/patrician
	outfit = /datum/outfit/towner/patrician

/obj/effect/mob_spawn/enterprise_guest/patrician/female
	gender = FEMALE
	mob_species = /datum/species/elf/snow

/obj/effect/mob_spawn/enterprise_guest/miner
	outfit = /datum/outfit/towner/miner
	mob_species = /datum/species/dwarf/mountain

/obj/effect/mob_spawn/enterprise_guest/lumberjack
	outfit = /datum/outfit/towner/lumberjack
	mob_species = /datum/species/halforc

/obj/effect/mob_spawn/enterprise_guest/farmhand
	outfit = /datum/outfit/towner/farmhand

/obj/effect/mob_spawn/enterprise_guest/farmhand/female
	gender = FEMALE
	mob_species = /datum/species/demihuman

/obj/effect/mob_spawn/enterprise_guest/fisher
	outfit = /datum/outfit/towner/fisher

/obj/effect/mob_spawn/enterprise_guest/fisher/female
	gender = FEMALE

/obj/effect/mob_spawn/enterprise_guest/hunter
	outfit = /datum/outfit/towner/hunter
	mob_species = /datum/species/elf/wood

/obj/effect/mob_spawn/enterprise_guest/hunter/female
	gender = FEMALE

/obj/effect/mob_spawn/enterprise_guest/merchant
	outfit = /datum/outfit/waterdeep_merchant

/obj/effect/mob_spawn/enterprise_guest/merchant/female
	gender = FEMALE
	mob_species = /datum/species/human/halfelf

/obj/effect/mob_spawn/enterprise_guest/tailor
	outfit = /datum/outfit/tailor
	mob_species = /datum/species/rakshari

/obj/effect/mob_spawn/enterprise_guest/tailor/female
	gender = FEMALE

/obj/effect/mob_spawn/enterprise_guest/sellsword
	outfit = /datum/outfit/adventurer_fighter/sellsword_hireling

/obj/effect/mob_spawn/enterprise_guest/sellsword/female
	gender = FEMALE
	mob_species = /datum/species/halforc

/obj/effect/mob_spawn/enterprise_guest/sellsword/dwarf
	mob_species = /datum/species/dwarf/mountain

/obj/effect/mob_spawn/enterprise_guest/bard
	outfit = /datum/outfit/towner/bard
	mob_species = /datum/species/human/halfelf

/obj/effect/mob_spawn/enterprise_guest/bard/female
	gender = FEMALE
	mob_species = /datum/species/tieberian

/obj/effect/mob_spawn/enterprise_guest/jester
	outfit = /datum/outfit/towner/jester

/obj/effect/mob_spawn/enterprise_guest/vagrant
	outfit = /datum/outfit/vagrant

/obj/effect/mob_spawn/enterprise_guest/vagrant/female
	gender = FEMALE

/mob/living/simple_animal/enterprise_patron
	var/guest_kind = "traveller"
	var/list/looks = list(
		/obj/effect/mob_spawn/enterprise_guest/passenger,
		/obj/effect/mob_spawn/enterprise_guest/passenger/female,
		/obj/effect/mob_spawn/enterprise_guest/burgess,
		/obj/effect/mob_spawn/enterprise_guest/burgess/female,
		/obj/effect/mob_spawn/enterprise_guest/commoner,
		/obj/effect/mob_spawn/enterprise_guest/commoner/female,
	)

/mob/living/simple_animal/enterprise_patron/proc/dress()
	if(!length(looks))
		return null
	var/obj/effect/mob_spawn/enterprise_guest/look = pick(looks)
	gender = initial(look.gender)
	apply_dynamic_human_appearance(src, null, initial(look.mob_species), look)
	return look

/mob/living/simple_animal/enterprise_patron/proc/get_guest_data()
	var/datum/enterprise_room/place
	switch(get_goal())
		if(ENTERPRISE_PATRON_GOAL_ROOM)
			place = lodging
		if(ENTERPRISE_PATRON_GOAL_TABLE, ENTERPRISE_PATRON_GOAL_ORDER)
			place = table_set?.room
		if(ENTERPRISE_PATRON_GOAL_BAR)
			var/obj/structure/stool = seat?.resolve()
			place = stool ? enterprise?.get_room(stool) : null
	return list(
		"id" = REF(src),
		"name" = name,
		"kind" = guest_kind,
		"goal" = get_goal(),
		"stage" = goal_stage,
		"place" = place?.name,
		"displeasure" = displeasure,
		"max_displeasure" = max_displeasure,
		"order" = get_order_data(),
	)

/mob/living/simple_animal/enterprise_patron/labourer
	name = "labourer"
	desc = "A local worker come in after a hard day."
	guest_kind = "labourer"
	goals = list(
		ENTERPRISE_PATRON_GOAL_BAR,
		ENTERPRISE_PATRON_GOAL_TABLE,
	)
	looks = list(
		/obj/effect/mob_spawn/enterprise_guest/miner,
		/obj/effect/mob_spawn/enterprise_guest/lumberjack,
		/obj/effect/mob_spawn/enterprise_guest/farmhand,
		/obj/effect/mob_spawn/enterprise_guest/farmhand/female,
		/obj/effect/mob_spawn/enterprise_guest/fisher,
		/obj/effect/mob_spawn/enterprise_guest/fisher/female,
	)

/mob/living/simple_animal/enterprise_patron/merchant
	name = "travelling merchant"
	desc = "A merchant on the road, after a quiet table and a bed for the night."
	guest_kind = "merchant"
	goals = list(
		ENTERPRISE_PATRON_GOAL_ORDER,
		ENTERPRISE_PATRON_GOAL_ROOM,
	)
	looks = list(
		/obj/effect/mob_spawn/enterprise_guest/merchant,
		/obj/effect/mob_spawn/enterprise_guest/merchant/female,
		/obj/effect/mob_spawn/enterprise_guest/tailor,
		/obj/effect/mob_spawn/enterprise_guest/tailor/female,
	)

/mob/living/simple_animal/enterprise_patron/sellsword
	name = "sellsword"
	desc = "A blade for hire, between contracts."
	guest_kind = "sellsword"
	goals = list(
		ENTERPRISE_PATRON_GOAL_BAR,
		ENTERPRISE_PATRON_GOAL_TABLE,
	)
	looks = list(
		/obj/effect/mob_spawn/enterprise_guest/sellsword,
		/obj/effect/mob_spawn/enterprise_guest/sellsword/female,
		/obj/effect/mob_spawn/enterprise_guest/sellsword/dwarf,
		/obj/effect/mob_spawn/enterprise_guest/hunter,
		/obj/effect/mob_spawn/enterprise_guest/hunter/female,
	)

/mob/living/simple_animal/enterprise_patron/minstrel
	name = "minstrel"
	desc = "A wandering player, after an audience and a drink."
	guest_kind = "minstrel"
	goals = list(
		ENTERPRISE_PATRON_GOAL_BAR,
		ENTERPRISE_PATRON_GOAL_TABLE,
	)
	looks = list(
		/obj/effect/mob_spawn/enterprise_guest/bard,
		/obj/effect/mob_spawn/enterprise_guest/bard/female,
		/obj/effect/mob_spawn/enterprise_guest/jester,
	)

/mob/living/simple_animal/enterprise_patron/noble
	name = "noble guest"
	desc = "Someone of good family, who expects the best table and the best room."
	guest_kind = "noble"
	goals = list(
		ENTERPRISE_PATRON_GOAL_ORDER,
		ENTERPRISE_PATRON_GOAL_ROOM,
	)
	looks = list(
		/obj/effect/mob_spawn/enterprise_guest/patrician,
		/obj/effect/mob_spawn/enterprise_guest/patrician/female,
	)

/mob/living/simple_animal/enterprise_patron/vagrant
	name = "wanderer"
	desc = "Someone with nowhere else to be."
	guest_kind = "vagrant"
	goals = list(
		ENTERPRISE_PATRON_GOAL_BAR,
	)
	looks = list(
		/obj/effect/mob_spawn/enterprise_guest/vagrant,
		/obj/effect/mob_spawn/enterprise_guest/vagrant/female,
		/obj/effect/mob_spawn/enterprise_guest/commoner/half_orc,
	)

/datum/enterprise
	var/list/guest_kinds = list()
	var/guest_calls_left = ENTERPRISE_GUEST_CALLS
	var/morning_guest_due = TRUE
	var/morning_guest_kind
	var/morning_guest_locked = FALSE

/datum/enterprise/proc/guests_changed()
	SStgui.update_uis(src)

/datum/enterprise/proc/pick_guest_type()
	return length(guest_kinds) ? pickweight(guest_kinds) : null

/datum/enterprise/proc/can_receive_guests()
	return length(rooms) && length(guest_kinds)

/datum/enterprise/proc/get_entrance_turf(open_only = FALSE)
	if(isnull(exit_doors))
		find_exit_doors()
	var/turf/best
	var/best_rank = INFINITY
	for(var/datum/weakref/door_ref as anything in exit_doors)
		var/obj/structure/door/door = door_ref.resolve()
		if(QDELETED(door))
			continue
		var/locked = door.locked()
		if(locked && open_only)
			continue
		var/turf/outside = get_outside_step(door)
		if(!outside)
			continue
		var/rank = exit_doors[door_ref] + (locked ? ENTERPRISE_GUEST_LOCKED_DOOR_PENALTY : 0)
		if(rank < best_rank)
			best = outside
			best_rank = rank
	return best

/datum/enterprise/proc/start_guest_day(forced)
	guest_calls_left = ENTERPRISE_GUEST_CALLS
	morning_guest_due = TRUE
	morning_guest_kind = null
	morning_guest_locked = FALSE
	welcome_morning_guest(forced)
	send_lodgers_to_order()

/datum/enterprise/proc/welcome_morning_guest(forced)
	if(!morning_guest_due || !SSticker.HasRoundStarted())
		return null
	if(!forced && GLOB.tod != "dawn")
		morning_guest_due = FALSE
		return null
	if(!can_receive_guests())
		return null
	var/turf/entrance = get_entrance_turf(TRUE)
	var/locked_out = isnull(entrance)
	if(locked_out)
		entrance = get_entrance_turf()
	var/mob/living/simple_animal/enterprise_patron/guest = summon_patron(pick_guest_type(), entrance)
	if(!guest)
		return null
	morning_guest_due = FALSE
	morning_guest_kind = guest.guest_kind
	morning_guest_locked = locked_out
	if(locked_out)
		guest.turn_away()
	log_game("[name]: [guest.name] came as the morning guest[locked_out ? " and found every way in locked" : ""].")
	guests_changed()
	return guest

/datum/enterprise/proc/call_guest(mob/user)
	if(!is_manager(user) || !can_receive_guests())
		return FALSE
	var/russian = get_preferred_ui_language(user) == "ru"
	if(guest_calls_left <= 0)
		to_chat(user, span_warning(russian \
			? "Сегодня я уже звал гостей: больше никто не придёт до утра." \
			: "I have sent for guests enough today: nobody else will come before the morning."))
		return FALSE
	var/turf/entrance = get_entrance_turf(TRUE)
	if(!entrance)
		to_chat(user, span_warning(russian \
			? "Все входы заперты: гостю не войти." \
			: "Every way in is locked: no guest could come in."))
		return FALSE
	var/mob/living/simple_animal/enterprise_patron/guest = summon_patron(pick_guest_type(), entrance)
	if(!guest)
		return FALSE
	guest_calls_left--
	log_game("[key_name(user)] sent for a guest to the [name]: [guest.name].")
	to_chat(user, span_notice(russian \
		? "Я послал весть: гость уже на пороге." \
		: "I have sent word out: a guest is at the door."))
	return TRUE

/datum/enterprise/proc/get_guests_data(mob/user)
	var/list/present = list()
	for(var/mob/living/simple_animal/enterprise_patron/patron as anything in patrons)
		present += list(patron.get_guest_data())
	return list(
		"calls_left" = guest_calls_left,
		"calls_max" = ENTERPRISE_GUEST_CALLS,
		"can_call" = is_manager(user),
		"open" = !isnull(get_entrance_turf(TRUE)),
		"morning_due" = morning_guest_due,
		"morning_kind" = morning_guest_kind,
		"morning_locked" = morning_guest_locked,
		"present" = present,
	)
