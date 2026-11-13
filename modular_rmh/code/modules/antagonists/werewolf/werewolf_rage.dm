
/datum/rage/werewolf
	max_rage = 150
	rage_change_on_life = -0.5
	/// Base rage gain multiplier from stress
	var/stress_rage_multiplier = 0.1
	/// Sniff Mark action, bound to the mind once this wolf has marked a partner.
	var/datum/action/innate/werewolf_sniff_mark/sniff_mark_action

/datum/rage/werewolf/New()
	. = ..()
	// Tier abilities go to the beast only; see grant_ability.
	rage_thresholds = list()
	rage_thresholds["[WW_RAGE_LOW]"] = list()
	rage_thresholds["[WW_RAGE_MEDIUM]"] = list()
	rage_thresholds["[WW_RAGE_HIGH]"] = list(/datum/action/cooldown/spell/werewolf_take)
	rage_thresholds["[WW_RAGE_CRITICAL]"] = list(/datum/action/cooldown/spell/werewolf_take)

/datum/rage/werewolf/Destroy(force)
	if(!QDELETED(sniff_mark_action))
		qdel(sniff_mark_action)
	sniff_mark_action = null
	return ..()

/datum/rage/werewolf/grant_to_holder(mob/living/carbon/human/holder)
	. = ..()
	if(!.)
		return

	RegisterSignal(holder_mob, COMSIG_MOB_ADD_STRESS, PROC_REF(on_stress_added))
	holder_mob.AddElement(/datum/element/relay_attackers)
	RegisterSignal(holder_mob, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(upon_attacked))
	RegisterSignal(holder_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	RegisterSignal(holder_mob, COMSIG_SEX_ACTION_TICK, PROC_REF(on_sex_action_tick))

/datum/rage/werewolf/remove_holder()
	// The parent forgets tier abilities, so take them off the beast first.
	clear_beast_effects(secondary_mob)
	holder_mob?.RemoveElement(/datum/element/relay_attackers)
	UnregisterSignal(holder_mob, list(COMSIG_MOB_ADD_STRESS, COMSIG_ATOM_WAS_ATTACKED, COMSIG_MOB_HUD_CREATED, COMSIG_SEX_ACTION_TICK))
	. = ..()

/datum/rage/werewolf/grant_to_secondary(mob/living/carbon/human/secondary)
	. = ..()
	if(!.)
		return

	RegisterSignal(secondary_mob, COMSIG_MOB_ADD_STRESS, PROC_REF(on_stress_added))
	secondary.AddElement(/datum/element/relay_attackers)
	RegisterSignal(secondary_mob, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(upon_attacked))
	RegisterSignal(secondary_mob, COMSIG_SEX_CLIMAX, PROC_REF(on_beast_climax))
	RegisterSignal(secondary_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	RegisterSignal(secondary_mob, COMSIG_SEX_ACTION_TICK, PROC_REF(on_sex_action_tick))
	for(var/ability in active_abilities)
		secondary_mob.add_spell(ability, source = src)
	sync_beast_effects()

/datum/rage/werewolf/remove_secondary()
	clear_beast_effects(secondary_mob)
	secondary_mob?.RemoveElement(/datum/element/relay_attackers)
	UnregisterSignal(secondary_mob, list(COMSIG_MOB_ADD_STRESS, COMSIG_ATOM_WAS_ATTACKED, COMSIG_SEX_CLIMAX, COMSIG_MOB_HUD_CREATED, COMSIG_SEX_ACTION_TICK))
	. = ..()

/// Tier abilities live on the beast; in human form they wait until the next transformation.
/datum/rage/werewolf/grant_ability(datum/action/ability, permanent = FALSE)
	if(permanent)
		return ..()
	if(!ability)
		return
	active_abilities |= ability
	secondary_mob?.add_spell(ability, source = src)

/datum/rage/werewolf/remove_ability(datum/action/ability)
	if(!ability)
		return
	active_abilities -= ability
	secondary_mob?.remove_spell(ability)

/// Frenzy holds rage where it is; living pups shave the beast's decay; otherwise the base tick.
/datum/rage/werewolf/on_life(datum/source)
	if(secondary_mob?.has_status_effect(/datum/status_effect/werewolf_frenzy))
		return
	var/mob/living/carbon/human/beast = get_active_beast()
	var/datum/antagonist/werewolf/wolf = beast ? IS_WEREWOLF(beast) : null
	var/pup_bonus = wolf ? min(wolf.get_pup_rage_decay_bonus(), wolf.transformed_rage_decay) : 0
	if(!pup_bonus)
		return ..()
	if(holder_mob.stat >= DEAD)
		return
	update_rage(rage_change_on_life + pup_bonus)

/// Raw gains skip the moon and silver multipliers.
/datum/rage/werewolf/update_rage(amount, raw = FALSE)
	if(amount > 0 && !raw)
		amount *= get_moon_rage_multiplier()
		var/mob/active_mob = secondary_mob || holder_mob
		if(active_mob?.has_status_effect(/datum/status_effect/debuff/silver_bane))
			amount *= 0.25
	. = ..(amount)

/// Lifts rage to at least minimum, never lowering it.
/datum/rage/werewolf/proc/raise_rage_to(minimum)
	if(rage >= minimum)
		return
	update_rage(minimum - rage, raw = TRUE)

/datum/rage/werewolf/proc/get_tier_name()
	switch(current_tier)
		if(WW_RAGE_CRITICAL)
			return "Frenzy"
		if(WW_RAGE_HIGH)
			return "Rut"
		if(WW_RAGE_MEDIUM)
			return "Hungry"
		if(WW_RAGE_LOW)
			return "Restless"
	return "Calm"

/datum/rage/werewolf/proc/get_status_tab_line()
	return "Rage: [round(rage)] / [max_rage] ([get_tier_name()])"

/// Bodies without a HUD at grant time (roundstart, the beast before its mind) get the meter here.
/datum/rage/werewolf/proc/on_hud_created(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	attach_rage_meter(source)

/datum/rage/werewolf/proc/attach_rage_meter(mob/living/carbon/human/body)
	var/datum/hud/body_hud = body?.hud_used
	if(!body_hud || body_hud.bloodpool)
		return
	body_hud.initialize_bloodpool()
	body_hud.bloodpool.set_fill_color(rage_color)
	update_hud()

/// Every beat of sex feeds rage, giving or receiving; rougher beats feed more.
/datum/rage/werewolf/proc/on_sex_action_tick(mob/living/source, datum/sex_action/action, mob/living/action_user, mob/living/action_target)
	SIGNAL_HANDLER
	var/gain = get_sex_rage_gain(source, action?.force)
	if(gain)
		update_rage(gain)

/// Rage one sex beat feeds this body: full as the beast, a share in human skin, else none.
/datum/rage/werewolf/proc/get_sex_rage_gain(mob/living/body, force)
	var/gain = WW_SEX_RAGE_PER_TICK * get_sex_force_rage_multiplier(force)
	if(body && body == get_active_beast())
		return gain
	if(body && body == holder_mob)
		return gain * WW_SEX_RAGE_HUMAN_MULT
	return 0

/proc/get_sex_force_rage_multiplier(force)
	switch(force)
		if(SEX_FORCE_LOW)
			return WW_SEX_RAGE_FORCE_LOW_MULT
		if(SEX_FORCE_HIGH)
			return WW_SEX_RAGE_FORCE_HIGH_MULT
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			return WW_SEX_RAGE_FORCE_EXTREME_MULT
	return WW_SEX_RAGE_FORCE_MID_MULT

/// Swaps only the abilities that differ between tiers, so one listed in both keeps its cooldown.
/datum/rage/werewolf/upon_tier_change(new_rage_tier, old_rage_tier)
	var/list/old_abilities = get_tier_abilities(old_rage_tier)
	var/list/new_abilities = get_tier_abilities(new_rage_tier)
	for(var/ability in old_abilities - new_abilities)
		remove_ability(ability)
	for(var/ability in new_abilities - old_abilities)
		grant_ability(ability)

	var/active_mob = secondary_mob || holder_mob
	if(new_rage_tier && rage_thresholds["[new_rage_tier]"])
		// Notify player of tier change
		switch(new_rage_tier)
			if(WW_RAGE_LOW)
				to_chat(active_mob, span_notice("My rage begins to build..."))
			if(WW_RAGE_MEDIUM)
				to_chat(active_mob, span_notice("<span class='red'>My rage intensifies!</span>"))
			if(WW_RAGE_HIGH)
				to_chat(active_mob, span_notice("<span class='red'>My rage reaches dangerous levels!</span>"))
			if(WW_RAGE_CRITICAL)
				to_chat(active_mob, span_notice("<span class='red'>I am consumed by RAGE!</span>"))
	else if(old_rage_tier > 0)
		to_chat(active_mob, span_notice("My rage subsides..."))
	sync_beast_effects()

/datum/rage/werewolf/proc/get_tier_abilities(tier)
	if(!tier)
		return list()
	var/list/abilities = rage_thresholds["[tier]"]
	if(isnull(abilities))
		return list()
	return islist(abilities) ? abilities : list(abilities)

/// The beast body while the werewolf is transformed, else null; every tier effect gates on this.
/datum/rage/werewolf/proc/get_active_beast()
	RETURN_TYPE(/mob/living/carbon/human)
	if(QDELETED(secondary_mob))
		return null
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(secondary_mob)
	if(!wolf?.transformed)
		return null
	return secondary_mob

/// Brings the beast's tier effects in line with current rage; cheap enough to run every life tick.
/datum/rage/werewolf/proc/sync_beast_effects()
	var/mob/living/carbon/human/beast = get_active_beast()
	if(!beast)
		return
	toggle_beast_effect(beast, /datum/status_effect/werewolf_restless, check_rage(WW_RAGE_LOW))
	toggle_beast_effect(beast, /datum/status_effect/werewolf_rut, check_rage(WW_RAGE_HIGH))
	if(current_tier >= WW_RAGE_CRITICAL && !beast.has_status_effect(/datum/status_effect/werewolf_frenzy))
		beast.apply_status_effect(/datum/status_effect/werewolf_frenzy)

/datum/rage/werewolf/proc/toggle_beast_effect(mob/living/beast, effect_type, wanted)
	if(!wanted)
		beast.remove_status_effect(effect_type)
	else if(!beast.has_status_effect(effect_type))
		beast.apply_status_effect(effect_type)

/// Strips tier effects and abilities from the beast; a frenzy cut short skips its exhaustion.
/datum/rage/werewolf/proc/clear_beast_effects(mob/living/carbon/human/beast)
	if(!beast)
		return
	var/datum/status_effect/werewolf_frenzy/frenzy = beast.has_status_effect(/datum/status_effect/werewolf_frenzy)
	if(frenzy)
		frenzy.aftermath = FALSE
		beast.remove_status_effect(/datum/status_effect/werewolf_frenzy)
	beast.remove_status_effect(/datum/status_effect/werewolf_restless)
	beast.remove_status_effect(/datum/status_effect/werewolf_rut)
	for(var/ability in active_abilities)
		beast.remove_spell(ability)

/// A beast climaxing inside a partner spends rage, marks them, and refreshes a frenzied lunge.
/datum/rage/werewolf/proc/on_beast_climax(mob/living/source, datum/sex_action/action, mob/living/initiator, mob/living/target, atom/performer, intimate)
	SIGNAL_HANDLER
	if(!intimate || source != get_active_beast())
		return
	var/mob/living/partner = get_climax_inside_partner(source, action)
	if(!partner)
		return
	update_rage(-WW_CLIMAX_RAGE_COST)
	partner.apply_status_effect(/datum/status_effect/werewolf_scent_mark, null, source.mind)
	grant_sniff_mark_action(source)
	var/datum/status_effect/werewolf_frenzy/frenzy = source.has_status_effect(/datum/status_effect/werewolf_frenzy)
	frenzy?.refresh_lunge()

/// The partner whose vagina or rear holds the climaxer's cock, or null.
/proc/get_climax_inside_partner(mob/living/climaxer, datum/sex_action/action)
	var/static/list/inside_holes = list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
	if(!action || action.orifice_pressing || !(action.hole_id in inside_holes))
		return null
	if(!ispath(action.stored_item_type, /obj/item/organ/genitals/penis))
		return null
	if(action.get_storage_insertor(action.action_user, action.action_target) != climaxer)
		return null
	var/mob/living/partner = action.get_storage_receiver(action.action_user, action.action_target)
	if(!isliving(partner) || partner == climaxer)
		return null
	return partner

/datum/rage/werewolf/proc/grant_sniff_mark_action(mob/living/beast)
	var/datum/mind/wolf_mind = beast.mind
	if(!wolf_mind)
		return
	if(QDELETED(sniff_mark_action))
		sniff_mark_action = new(wolf_mind)
	sniff_mark_action.Grant(wolf_mind.current)

// Stress multiplier only affects the untransformed human holder_mob
/datum/rage/werewolf/proc/on_stress_added(datum/source, datum/stress_event/new_stress)
	SIGNAL_HANDLER

	if(!holder_mob || holder_mob.stat >= DEAD)
		return

	var/new_stress_amount = new_stress.stress_change
	// Calculate rage gain based on total stress - global multiplier
	// At 0 stress: 1x multiplier, at 5 stress: 1.33x, at 10 stress: 1.67x, at 15 stress: 2x
	// Negative stress reduces rage gain
	var/total_stress = holder_mob.get_stress_amount()
	var/stress_multiplier = 1 + (total_stress / 15)
	var/rage_gain = new_stress_amount * stress_rage_multiplier * stress_multiplier

	update_rage(rage_gain)

/datum/rage/werewolf/proc/upon_attacked(mob/living/attacked, mob/living/carbon/human/attacker, damage)
	SIGNAL_HANDLER

	var/base_rage = max(1, damage / 2)
	var/rage_multiplier = max(stress_rage_multiplier, 1)

	update_rage(base_rage * rage_multiplier)
