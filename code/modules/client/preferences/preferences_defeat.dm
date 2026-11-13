/proc/sanitize_defeat_mode(defeat_mode)
	switch(defeat_mode)
		if(DEFEAT_MODE_KO_RUNE, DEFEAT_MODE_KO_ONLY, DEFEAT_MODE_NO_RETURN)
			return defeat_mode
	return DEFEAT_MODE_DEFAULT

/proc/sanitize_defeat_damage_threshold(threshold)
	threshold = text2num("[threshold]")
	switch(threshold)
		if(100, 150, 200, 250, 300)
			return threshold
	return DEFEAT_DAMAGE_THRESHOLD_DEFAULT

/// Labelled threshold choices so the numbers mean something to the player in the pref menu.
/// The number is pooled brute, burn, toxin, and clone damage endured before you tap out into defeat.
/// Oxygen, blood loss, brain danger, shock, and immediate rune hazards use their own safety checks.
/// Lower = fall sooner (safer); higher = soak more punishment first.
/proc/defeat_threshold_choice_map()
	return list(
		"Fragile (100 - fall early)" = 100,
		"Frail (150)" = 150,
		"Standard (200)" = 200,
		"Hardy (250)" = 250,
		"Unyielding (300 - endure the most)" = 300,
	)

/proc/defeat_threshold_display_label(threshold)
	threshold = sanitize_defeat_damage_threshold(threshold)
	var/list/choices = defeat_threshold_choice_map()
	for(var/label in choices)
		if(choices[label] == threshold)
			return label
	return "Standard (200)"

/proc/defeat_mode_display_name(defeat_mode)
	switch(sanitize_defeat_mode(defeat_mode))
		if(DEFEAT_MODE_KO_RUNE)
			return "Knockout + Rune"
		if(DEFEAT_MODE_KO_ONLY)
			return "Knockout Only"
		if(DEFEAT_MODE_NO_RETURN)
			return "No Return"
	return "Knockout + Rune"

/proc/defeat_mode_choice_map()
	return list(
		"Knockout + Rune" = DEFEAT_MODE_KO_RUNE,
		"Knockout Only" = DEFEAT_MODE_KO_ONLY,
		"No Return" = DEFEAT_MODE_NO_RETURN,
	)

/proc/defeat_mode_help_text()
	return "Rivermist Hollow favours rescue and recovery after a lost fight. Choose for this character:\n\nKnockout + Rune (recommended): defeat protection, in-world recovery, and rune return when available. Rune returns have costs and aftermath.\n\nKnockout Only: defeat protection with companions, supplies, campfires, or slower unaided recovery. No automatic rune bond.\n\nNo Return (lethal play): ordinary lethal rules; no defeat protection or automatic rune rescue.\n\nBoth Knockout modes turn ordinary lethal attacks and body destruction into defeat. Explicit character-ending choices and administrative destruction remain exceptions. Changes apply on your next spawn; review them under Gameplay > Combat & Defeat."

/proc/defeat_threshold_help_text()
	return "Your injury total is brute + [DEFEAT_BURN_DAMAGE_WEIGHT * 100]% of burn + toxin + clone damage. Lower thresholds make you fall sooner. Frail and Atrophy each reduce the selected threshold. Oxygen loss, lethal blood loss, brain damage, and hazards have separate checks: raising this setting does not raise those limits. Pain shock does not trigger Defeat, but ordinary pain blackouts and knockdowns still apply. Intimate defeat uses separate stat-based resistance, with private progress messages."

/datum/preferences/proc/get_defeat_mode()
	return sanitize_defeat_mode(read_preference(/datum/preference/choiced/defeat_mode))

/datum/preferences/proc/set_defeat_mode(new_defeat_mode)
	write_preference(/datum/preference/choiced/defeat_mode, sanitize_defeat_mode(new_defeat_mode))

/datum/preferences/proc/get_defeat_damage_threshold()
	return sanitize_defeat_damage_threshold(read_preference(/datum/preference/numeric/defeat_damage_threshold))

/datum/preferences/proc/set_defeat_damage_threshold(new_threshold)
	write_preference(/datum/preference/numeric/defeat_damage_threshold, sanitize_defeat_damage_threshold(new_threshold))

/datum/preferences
	/// Account-wide introduction; the chosen mode remains a character preference.
	var/defeat_introduction_complete = FALSE
	var/tmp/defeat_choice_open = FALSE

/datum/preferences/proc/choose_defeat_mode(mob/user, introduction = FALSE)
	if(!user?.client || user.client != parent || defeat_choice_open)
		return FALSE
	if(introduction && defeat_introduction_complete)
		return TRUE
	var/selected_slot = default_slot
	defeat_choice_open = TRUE
	var/list/choices = defeat_mode_choice_map()
	var/choice = tgui_input_list(user, defeat_mode_help_text(), "Choose Your Defeat Experience", choices, defeat_mode_display_name(get_defeat_mode()))
	if(QDELETED(src))
		return FALSE
	defeat_choice_open = FALSE
	var/user_present = !QDELETED(user) && user.client && user.client == parent
	var/answered = user_present && default_slot == selected_slot && (choice in choices)
	if(answered)
		set_defeat_mode(choices[choice])
		save_character()
	if(introduction)
		// The introduction asks once. A closed or cancelled prompt keeps the default and never asks again.
		defeat_introduction_complete = TRUE
		save_preferences()
		if(!answered && user_present)
			to_chat(user, span_notice("Defeat mode stays [defeat_mode_display_name(get_defeat_mode())]. Change it any time under Gameplay > Combat & Defeat."))
		SStgui.update_uis(src)
		return TRUE
	if(!answered)
		return FALSE
	SStgui.update_uis(src)
	return TRUE

/datum/preferences/proc/ensure_defeat_introduction(mob/user)
	if(defeat_introduction_complete)
		return TRUE
	return choose_defeat_mode(user, introduction = TRUE)

/mob/verb/defeat_recovery_guide()
	set name = "Defeat & Recovery"
	set category = "OOC"
	show_defeat_recovery_guide()

/mob/proc/show_defeat_recovery_guide()
	if(!client)
		return
	var/list/text = list("<h2>Defeat & Recovery</h2>")
	text += "<p>Current readings at opening time. Reopen this guide to refresh them.</p>"
	if(isliving(src))
		var/mob/living/player = src
		text += "<p><b>Current body:</b> [defeat_mode_display_name(player.defeat_mode)]. Injury threshold: [player.get_effective_defeat_threshold()] (selected: [player.defeat_damage_threshold]).</p>"
		if(player.has_status_effect(/datum/status_effect/defeat_knockout))
			if(player.defeat_mode == DEFEAT_MODE_KO_RUNE)
				var/datum/resurrection_rune_controller/controller = get_resurrection_rune_controller_for_user(player)
				var/rune_status = "No working rune bond."
				if(controller)
					if(controller.resurrections_disabled())
						rune_status = "The linked rune is disabled."
					else if(player in controller.resurrecting)
						rune_status = "Return is already in progress."
					else if(!player.mind?.can_spend_defeat_rune_charge())
						rune_status = "No return charges available."
					else if(controller.can_offer_defeat_rune_return(player))
						rune_status = "Available: use Call the Rune."
					else
						rune_status = "Unavailable in your current state; captivity may delay the offer."
				text += "<p><b>Rune status:</b> [rune_status]</p>"
		var/injury_total = player.getBruteLoss() + player.getFireLoss() * DEFEAT_BURN_DAMAGE_WEIGHT + player.getToxLoss() + player.getCloneLoss()
		text += "<p><b>Current injury total:</b> [round(injury_total, 0.1)] / [player.get_effective_defeat_threshold()]. Brute [round(player.getBruteLoss(), 0.1)], weighted burns [round(player.getFireLoss() * DEFEAT_BURN_DAMAGE_WEIGHT, 0.1)], toxin [round(player.getToxLoss(), 0.1)], bodily deterioration [round(player.getCloneLoss(), 0.1)]. Stabilization reduces these values after defeat.</p>"
		if(ishuman(player))
			var/mob/living/carbon/human/human_player = player
			for(var/datum/quirk/quirk as anything in human_player.quirks)
				if(quirk.defeat_threshold_mult != 1)
					text += "<p><b>Threshold modifier:</b> [html_encode(quirk.name)] x[quirk.defeat_threshold_mult]. Modifiers multiply together.</p>"
		var/datum/status_effect/defeat_knockout/knockout = player.has_status_effect(/datum/status_effect/defeat_knockout)
		if(knockout)
			if(player.GetComponent(/datum/component/kidnap_captivity))
				text += "<p><b>Self-recovery suspended:</b> use the Captivity button for the lair's release options.</p>"
			else if(knockout.self_recover_at)
				text += "<p><b>Intimate self-recovery:</b> [DisplayTimeText(max(0, knockout.self_recover_at - world.time))] remaining.</p>"
			else if(knockout.struggle_auto_at)
				text += "<p><b>Struggle to Your Feet:</b> [knockout.struggle_action ? "available now" : DisplayTimeText(max(0, knockout.struggle_offer_at - world.time))]. <b>Automatic recovery:</b> [DisplayTimeText(max(0, knockout.struggle_auto_at - world.time))] remaining.</p>"
			else
				text += "<p><b>Self-recovery:</b> waiting on rune availability. A lost rune starts the fallback countdown at the next check.</p>"
		var/datum/defeat_recovery_channel/channel = player.defeat_recovery_channel
		if(channel?.active)
			text += "<p><b>Rescue in progress:</b> [html_encode(channel.rescue_source)]. Estimated time remaining: [DisplayTimeText(max(0, channel.completes_at - world.time))]. Movement or attacks may interrupt it.</p>"
		if(player.last_defeat_snapshot)
			text += "<p><b>Last defeat:</b> [player.last_defeat_snapshot.cause_description()].</p>"
			if(player.has_status_effect(/datum/status_effect/defeat_knockout))
				var/datum/status_effect/debuff/defeat/aftermath_type = player.last_defeat_snapshot.defeat_debuff_type()
				text += "<p><b>Expected aftermath:</b> [initial(aftermath_type.trauma_label)]. Severity depends on rescue method and existing untreated trauma. Rune return and unaided physical recovery add their own consequences.</p>"
		if(player.mind && player.defeat_mode == DEFEAT_MODE_KO_RUNE)
			text += "<p><b>Rune charges:</b> [player.mind.get_defeat_rune_charges()]/[DEFEAT_RUNE_MAX_CHARGES]. First free return: [player.mind.defeat_rune_first_free_used ? "used" : "unused"]. A working bond and an available rescue route are also required.</p>"
		for(var/datum/status_effect/debuff/defeat/trauma as anything in player.status_effects)
			if(!istype(trauma))
				continue
			var/remaining = trauma.duration == STATUS_EFFECT_PERMANENT ? "Requires treatment" : DisplayTimeText(max(0, trauma.duration - world.time))
			text += "<p><b>[trauma.trauma_label] ([defeat_severity_label(trauma.severity)]):</b> [remaining].<br>[trauma.trauma_desc]<br>[trauma.mechanics_description()]</p>"
	else if(client.prefs)
		text += "<p><b>Selected character:</b> [defeat_mode_display_name(client.prefs.get_defeat_mode())]. Changes apply on your next spawn.</p>"
	text += "<h3>Why did I fall?</h3><p>[defeat_threshold_help_text()]</p>"
	text += "<p><b>Aftermath follows the cause:</b> critical blood loss leaves Blood-Loss Weakness, oxygen deprivation leaves Breathless Exhaustion, and critical brain damage leaves Concussion. Predominant toxin damage leaves Poisoning Aftereffects; bodily deterioration leaves Systemic Strain. Physical injuries retain location-based aftermath. Intimate defeat consistently leaves Lewd Exhaustion rather than a random movement, grip, or mana penalty.</p>"
	text += "<p>Defeat leaves you alive, floored, and unable to move or fight. It is different from sleep, a brief blackout, or death. Defeat itself allows speech and emotes; other conditions may still prevent them. Call for help.</p>"
	text += "<h3>Helping someone recover</h3><ul><li><b>Empty hands:</b> use a help interaction on the defeated person. Stay beside them for [DisplayTimeText(DEFEAT_REVIVE_TIME_MIN)] to [DisplayTimeText(DEFEAT_REVIVE_TIME_MAX)], depending on medicine skill. Costs the helper stamina and leaves moderate aftermath.</li>"
	text += "<li><b>Prepared care:</b> qualifying healing tools, spells, or a curative drink fed by another person can wake them with light aftermath. Existing trauma is not cured, but prepared rescue does not escalate it.</li>"
	text += "<li><b>Campfire:</b> a lit, fuelled, player-built campfire can recover an adjacent victim in [DisplayTimeText(DEFEAT_CAMPFIRE_PASSIVE_RECOVERY_TIME)], or [DisplayTimeText(DEFEAT_CAMPFIRE_TENDED_RECOVERY_TIME)] with tending. Leaves moderate aftermath.</li></ul>"
	text += "<p>Ordinary healing and bandaging may stabilize someone without waking them. Moving or being attacked can interrupt a rescue.</p>"
	text += "<h3>Recovering alone</h3><p>Outside captivity, intimate defeat normally wears off after [DisplayTimeText(DEFEAT_HORNY_SELF_RECOVER_TIME)]. Physical defeat without an available rune offers <b>Struggle to Your Feet</b> after [DisplayTimeText(DEFEAT_KO_ONLY_STRUGGLE_DELAY)] and automatic recovery after [DisplayTimeText(DEFEAT_KO_ONLY_AUTO_RECOVER)]. Struggling adds Convalescence for [DisplayTimeText(DEFEAT_GRIEVOUS_RECOVERY_TIME)]: you cannot fight and walk slowly. Either trauma station can end this sooner; field cures cannot.</p>"
	text += "<h3>Rune and captivity</h3><p>Knockout + Rune offers return when the rune can answer. The first defeat return is free; later calls use charges and increasing coin and blood costs. Charges recover one per [DisplayTimeText(DEFEAT_RUNE_RECHARGE_TIME)]. Rune return adds backlash. In captivity, use the <b>Captivity</b> button: wake up, call the rune, stay, or give the character up. Ordinary self-recovery is suspended and release follows the lair's rules. Defeat mode does not replace your intimate-interaction preferences.</p>"
	text += "<h3>After waking</h3><p>Waking, healing ordinary wounds, and treating aftermath are different. Light, moderate, and severe ordinary aftermath last 10, 30, and 60 minutes. Repeated untreated trauma normally worsens. <b>Both trauma stations treat both physical and spiritual aftermath, including Convalescence.</b> Click a station to diagnose yourself or a patient beside it. The diagnosis shows each condition, time, price, training and any missing requirement. Hold the supplies in your active hand; payment happens only after successful treatment.</p>"
	text += "<p><b>Trauma apparatus:</b> without Apprentice Medicine, treatment takes twice as long. Physical treatment costs 1/2/3 bandages by severity; spiritual treatment costs 2/3/4 and takes twice as long. <b>Shrine of solace:</b> without Novice Miracles or holy devotion, treatment takes twice as long. Spiritual treatment costs 1/2/3 silver coins; physical treatment costs 2/4/6 and takes twice as long. Both time penalties stack. Each treatment removes one selected condition.</p>"
	text += "<p><b>Surgery:</b> a successful Tend Wounds operation can also clear one physical defeat trauma when the surgeon has Apprentice Medicine. It does not treat spiritual aftermath or Convalescence.</p>"
	text += "<p><b>Mercy Draught:</b> drink five measures per ordinary trauma, most severe first. A full vial holds five doses. Splashing does not cure trauma. Brew it from symphitum, hypericum, rosa and silver dust, or buy it from a Healer trader. <b>Bear Their Burden:</b> learned from the rare Prayer of the Shared Burden found in treasure chests. A devoted caster can lift one selected ordinary trauma from another person, paying devotion, 10/20/30 bodily damage by severity, and two minutes of Sacrificial Exhaustion. Neither field cure treats Convalescence.</p>"
	text += "<p><b>Protection:</b> both Knockout modes intercept ordinary death, gibbing, dusting, decapitation, and vital-organ extraction before the body is destroyed. Lava, acid, and bottomless fall impacts move protected victims onto safe ground when available. Explicit character-ending choices and administrative destruction remain lethal.</p>"
	text += "<p><b>Rune failure:</b> while defeated outside captivity, rune availability is rechecked every [DisplayTimeText(DEFEAT_FALLBACK_CHECK_INTERVAL)]. If the rune stops answering, the normal unaided-recovery countdown begins. A pending working rune return does not count as rune failure. No Return disables defeat protection and automatic rune rescue.</p>"
	var/datum/browser/popup = new(src, "defeat_recovery_guide", "Defeat & Recovery", 650, 650)
	popup.set_content(text.Join())
	popup.open()
