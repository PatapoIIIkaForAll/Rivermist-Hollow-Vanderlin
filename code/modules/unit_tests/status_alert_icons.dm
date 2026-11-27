#ifdef UNIT_TESTS

/// Every alert a status effect throws needs its icon_state in its icon file, or the alert shows blank.
/datum/unit_test/status_effect_alert_icons

/datum/unit_test/status_effect_alert_icons/Run()
	var/list/states_by_icon = list()
	var/list/alert_users = list()
	for(var/datum/status_effect/effect_type as anything in subtypesof(/datum/status_effect))
		var/alert_type = initial(effect_type.alert_type)
		if(!alert_type)
			continue
		if(alert_type == /atom/movable/screen/alert/status_effect)
			Fail("[effect_type] throws the nameless default alert; give it an alert or set alert_type = null.", __FILE__, __LINE__)
			continue
		if(!alert_users[alert_type])
			alert_users[alert_type] = effect_type
	// Alerts picked at runtime instead of through the alert_type default.
	alert_users[/atom/movable/screen/alert/status_effect/breast_size] = /datum/status_effect/breast_size
	alert_users[/atom/movable/screen/alert/status_effect/breast_size/full] = /datum/status_effect/breast_size

	for(var/atom/movable/screen/alert/alert_type as anything in alert_users)
		var/icon_file = initial(alert_type.icon)
		var/state = initial(alert_type.icon_state)
		var/list/states = states_by_icon[icon_file]
		if(!states)
			states = icon_states(icon_file)
			states_by_icon[icon_file] = states
		if(!(state in states))
			Fail("[alert_type] (thrown by [alert_users[alert_type]]) uses icon_state \"[state]\", which [icon_file] lacks.", __FILE__, __LINE__)

	var/atom/movable/screen/alert/void_alert = /atom/movable/screen/alert/status_effect/void_chill
	var/void_icon = initial(void_alert.icon)
	if(!("void_chill_oh_fuck" in icon_states(void_icon)))
		Fail("Void chill switches to icon_state \"void_chill_oh_fuck\" at five stacks, which [void_icon] lacks.", __FILE__, __LINE__)

/// The drawer button follows a gender change that does not swap any organ.
/datum/unit_test/smallclothes_toggle_follows_gender

/datum/unit_test/smallclothes_toggle_follows_gender/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/organ/breasts = human.getorganslot(ORGAN_SLOT_BREASTS)
	if(breasts)
		breasts.Remove(human)
		qdel(breasts)
	human.gender = FEMALE
	var/atom/movable/screen/smallclothes_toggle/toggle = allocate(/atom/movable/screen/smallclothes_toggle)
	toggle.watch_body(human)
	if(toggle.icon_state != "smallclothes_f")
		Fail("A female body without a breasts organ shows \"[toggle.icon_state]\" instead of \"smallclothes_f\".", __FILE__, __LINE__)

	human.gender = MALE
	human.dna.species.on_gender_update(human, FEMALE)
	if(toggle.icon_state != "smallclothes")
		Fail("After a change to male the button shows \"[toggle.icon_state]\" instead of \"smallclothes\".", __FILE__, __LINE__)

	human.gender = FEMALE
	human.dna.species.on_gender_update(human, MALE)
	if(toggle.icon_state != "smallclothes_f")
		Fail("After a change back to female the button shows \"[toggle.icon_state]\" instead of \"smallclothes_f\".", __FILE__, __LINE__)

#endif
