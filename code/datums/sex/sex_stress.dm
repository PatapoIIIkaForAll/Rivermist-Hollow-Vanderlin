
/datum/stress_event/cumok
	timer = 10 MINUTES
	stress_change = -2
	desc = "<span class='green'>I came.</span>"

/datum/stress_event/cummid
	timer = 10 MINUTES
	stress_change = -2
	desc = "<span class='green'>I came, and it was great.</span>"

/datum/stress_event/cumgood
	timer = 10 MINUTES
	stress_change = -3
	desc = "<span class='green'>I came, and it was wonderful.</span>"

/datum/stress_event/cummax
	timer = 10 MINUTES
	stress_change = -4
	desc = "<span class='green'>I came, and it was incredible.</span>"

/datum/stress_event/cumlove
	timer = 20 MINUTES
	stress_change = -5
	desc = "<span class='green'>I made love.</span>"

/datum/stress_event/cumpaingood
	timer = 10 MINUTES
	stress_change = -5
	desc = "<span class='green'>Pain makes it better.</span>"

/datum/stress_event/public_thrill
	timer = 1 MINUTES
	stress_change = -2
	desc = "<span class='green'>I was caught.</span>"

/datum/stress_event/sex_scene_airtight
	timer = 10 MINUTES

/datum/stress_event/sex_scene_airtight/focus
	stress_change = -4
	desc = "<span class='green'>I climaxed while completely surrounded and filled.</span>"

/datum/stress_event/sex_scene_airtight/participant
	stress_change = -2
	desc = "<span class='green'>I climaxed as part of an airtight arrangement.</span>"

/datum/stress_event/sex_scene_double_penetration
	timer = 10 MINUTES

/datum/stress_event/sex_scene_double_penetration/focus
	stress_change = -3
	desc = "<span class='green'>I climaxed while being taken by two partners at once.</span>"

/datum/stress_event/sex_scene_double_penetration/participant
	stress_change = -2
	desc = "<span class='green'>I climaxed during a double penetration.</span>"

/datum/stress_event/sex_scene_spitroast
	timer = 10 MINUTES

/datum/stress_event/sex_scene_spitroast/focus
	stress_change = -3
	desc = "<span class='green'>I climaxed in the middle of a spit-roast.</span>"

/datum/stress_event/sex_scene_spitroast/participant
	stress_change = -2
	desc = "<span class='green'>I climaxed while spit-roasting someone.</span>"

/datum/status_effect/knot_tied
	id = "knot_tied"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/knot_tied
	effectedstats = list("strength" = -1, "endurance" = -2, "speed" = -2, "intelligence" = -3)

/atom/movable/screen/alert/status_effect/knot_tied
	name = "Knotted"
	desc = "A knot is swollen tight inside me. Pulling away would tear."

/datum/status_effect/knot_fucked_stupid
	id = "knot_fucked_stupid"
	duration = 2 MINUTES
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/knot_fucked_stupid
	effectedstats = list("intelligence" = -10)

/atom/movable/screen/alert/status_effect/knot_fucked_stupid
	name = "Fucked Stupid"
	desc = "Mmmph I can't think straight..."

/datum/status_effect/knotted
	id = "knotted"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/knotted

/atom/movable/screen/alert/status_effect/knotted
	name = "Knotted"
	desc = "I have to be careful where I step..."
