/datum/enterprise
	var/list/rested_today = list()
	var/list/rest_stats = list(
		"Endurance +1, Constitution +1",
		"Strength +1, Endurance +1",
		"Strength, Constitution, Endurance, Speed and Intelligence +1",
		"Strength +1, Constitution +2, Endurance +2, Speed +1, Intelligence +2",
	)
	var/list/rest_stats_ru = list(
		"Воля +1, Стойкость +1",
		"Сила +1, Воля +1",
		"Сила, Стойкость, Воля, Скорость и Интеллект +1",
		"Сила +1, Стойкость +2, Воля +2, Скорость +1, Интеллект +2",
	)

/datum/status_effect/buff/enterprise_rest
	tick_interval = STATUS_EFFECT_NO_TICK
	id = "enterprise_rest"
	alert_type = /atom/movable/screen/alert/status_effect/buff/enterprise_rest
	effectedstats = list(STAT_ENDURANCE = 1, STAT_CONSTITUTION = 1)
	duration = ENTERPRISE_REST_BUFF_TIME

/datum/status_effect/buff/enterprise_rest/iron
	effectedstats = list(STAT_STRENGTH = 1, STAT_ENDURANCE = 1)

/datum/status_effect/buff/enterprise_rest/silver
	effectedstats = list(STAT_STRENGTH = 1, STAT_CONSTITUTION = 1, STAT_ENDURANCE = 1, STAT_SPEED = 1, STAT_INTELLIGENCE = 1)

/datum/status_effect/buff/enterprise_rest/gold
	effectedstats = list(STAT_STRENGTH = 1, STAT_CONSTITUTION = 2, STAT_ENDURANCE = 2, STAT_SPEED = 1, STAT_INTELLIGENCE = 2)

/atom/movable/screen/alert/status_effect/buff/enterprise_rest
	name = "Well Rested"
	desc = span_nicegreen("A night in a proper room has done me good.")
	icon_state = "foodbuff"

/datum/stress_event/enterprise_meal
	timer = 30 MINUTES
	stress_change = -1
	desc = span_green("I ate at a decent table.")

/datum/stress_event/enterprise_meal/iron
	timer = 45 MINUTES
	stress_change = -2
	desc = span_green("I ate at a good table.")

/datum/stress_event/enterprise_meal/silver
	timer = 60 MINUTES
	stress_change = -3
	desc = span_green("I dined at a fine table.")

/datum/stress_event/enterprise_meal/gold
	timer = 90 MINUTES
	stress_change = -4
	desc = span_green("I dined like a lord.")

/datum/enterprise/proc/give_rest_buff(mob/living/sleeper, level)
	var/buff_type = get_level_value(rest_buffs, level)
	if(!buff_type)
		return FALSE
	sleeper.apply_status_effect(buff_type)
	return TRUE

/datum/enterprise/proc/get_staff_bonus()
	return clamp(round(earned_today * ENTERPRISE_STAFF_BONUS_SHARE), ENTERPRISE_STAFF_BONUS_MIN, ENTERPRISE_STAFF_BONUS_MAX)

/datum/enterprise/proc/handle_rest(mob/living/carbon/human/sleeper)
	var/datum/enterprise_room/room = get_room(sleeper)
	if(!room)
		return FALSE
	room.note_visit(sleeper)
	if(room.level < ENTERPRISE_LEVEL_WOOD)
		return FALSE
	var/datum/weakref/who = WEAKREF(sleeper)
	if(rested_today[who])
		return FALSE
	var/russian = get_preferred_ui_language(sleeper) == "ru"
	var/purpose = room.get_purpose()
	if(purpose == ENTERPRISE_PURPOSE_STAFF_QUARTERS && is_staff(sleeper))
		rested_today[who] = TRUE
		give_rest_buff(sleeper, room.level)
		var/bonus = get_staff_bonus()
		if(SStreasury.give_money_account(bonus, sleeper, "[name] wages"))
			to_chat(sleeper, span_notice(russian ? "За день работы на счёт пришло [bonus]." : "The day's work has brought [bonus] to my account."))
		return TRUE
	if(purpose != ENTERPRISE_PURPOSE_GUEST_ROOM)
		return FALSE
	var/price = get_rest_price(room)
	if(!take_from_account(sleeper, price))
		to_chat(sleeper, span_warning(russian ? "На счёте нет [price] за ночлег: отдых будет обычным." : "My account cannot cover the [price] for the night: this will be an ordinary rest."))
		return FALSE
	rested_today[who] = TRUE
	earn(price)
	give_rest_buff(sleeper, room.level)
	to_chat(sleeper, span_notice(russian ? "За ночлег со счёта списано [price]." : "The night has cost me [price] from my account."))
	return TRUE

/datum/enterprise/proc/handle_night(mob/living/carbon/human/sleeper)
	var/datum/enterprise_room/room = get_room(sleeper)
	if(room)
		room.note_visit(sleeper)

/datum/enterprise/proc/handle_meal(mob/living/eater)
	var/obj/structure/chair/seat = eater.buckled
	if(!istype(seat))
		return FALSE
	var/datum/enterprise_room/room = get_room(eater)
	var/datum/enterprise_seating/seating = room?.get_seating(seat)
	if(!seating)
		return FALSE
	var/mob/living/simple_animal/enterprise_patron/patron = seating.get_patron()
	if(patron && patron != eater)
		patron.take_offence(eater)
		return FALSE
	var/mood_type = get_level_value(meal_moods, seating.get_level())
	if(!mood_type)
		return FALSE
	eater.add_stress(mood_type)
	return TRUE
