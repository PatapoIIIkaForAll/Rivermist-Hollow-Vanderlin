/datum/stress_event/wine_okay
	stress_change = -1
	desc = span_green("That drink was alright.")
	timer = 10 MINUTES

/datum/stress_event/wine_good
	stress_change = -2
	desc = span_green("A decent vintage always goes down easy.")
	timer = 10 MINUTES

/datum/stress_event/wine_great
	stress_change = -3
	desc = span_blue("An absolutely exquisite vintage. Indubitably.")
	timer = 10 MINUTES

/datum/stress_event/noble_lavish_food
	stress_change = -2
	desc = span_green("Truly, a feast befitting my station.")
	timer = 10 MINUTES

/datum/stress_event/favourite_food
	stress_change = -1
	desc = span_green("I ate my favourite food!")
	timer = 5 MINUTES

/datum/stress_event/favourite_food/can_apply(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(user.has_stress_type(/datum/stress_event/favourite_food))
		return FALSE

/datum/stress_event/favourite_drink
	stress_change = -1
	desc = span_green("I had my favourite drink!")
	timer = 5 MINUTES

/datum/stress_event/favourite_drink/can_apply(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(user.has_stress_type(/datum/stress_event/favourite_drink))
		return FALSE

/datum/stress_event/hated_food
	stress_change = 1
	desc = span_red("I had to eat my most hated food!")
	timer = 10 MINUTES

/datum/stress_event/hated_food/can_apply(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(user.has_stress_type(/datum/stress_event/hated_food))
		return FALSE

/datum/stress_event/hated_drink
	stress_change = 1
	desc = span_red("I had to consume my most hated drink!")
	timer = 10 MINUTES

/datum/stress_event/hated_drink/can_apply(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(user.has_stress_type(/datum/stress_event/hated_drink))
		return FALSE
