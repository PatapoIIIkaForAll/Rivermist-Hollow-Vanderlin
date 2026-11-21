/datum/status_effect/defeat_knockout
	id = "defeat_knockout"
	tick_interval = DEFEAT_FALLBACK_CHECK_INTERVAL
	duration = STATUS_EFFECT_PERMANENT
	alert_type = /atom/movable/screen/alert/status_effect/defeat_knockout
	remove_on_fullheal = FALSE
	/// Timer that lets a horny knockout wear off on its own (the light case); null for other defeats.
	var/self_recover_timer
	/// KO Only anti-softlock: timer that offers the "Struggle to Your Feet" action, the auto safety-net
	/// timer, and the granted action itself. All null unless this is a KO Only (no-rune) knockout.
	var/struggle_offer_timer
	var/struggle_auto_timer
	var/self_recover_at = 0
	var/struggle_offer_at = 0
	var/struggle_auto_at = 0
	var/datum/action/innate/defeat_struggle_up/struggle_action
	var/obj/effect/yield_indicator/yield_indicator

/datum/status_effect/defeat_knockout/tick()
	if(owner && !QDELETED(owner) && !owner.GetComponent(/datum/component/kidnap_captivity))
		if(owner.defeat_is_immediate_hazard())
			owner.defeat_rescue_from_hazard()
		owner.defeat_maybe_arm_struggle_up()

/datum/status_effect/defeat_knockout/on_apply()
	. = ..()
	if(!.)
		return
	yield_indicator = new
	owner.vis_contents += yield_indicator
	ADD_TRAIT(owner, TRAIT_NODEATH, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_NOHARDCRIT, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))
	owner.cmode = FALSE
	// Severity is required: overlay_fullscreen builds the icon_state as "[base][severity]", and only the
	// numbered "oxydamageoverlay[4-10]" states exist. 8 = heavy tunnel vision, see only right around you.
	owner.overlay_fullscreen("defeat", /atom/movable/screen/fullscreen/defeat, 8)
	var/reason = owner.last_defeat_snapshot?.reason
	var/horny_defeat = reason == DEFEAT_REASON_HORNY
	// Every defeat track reads differently at the moment of collapse - players kept mistaking a
	// bleed-out or a pain shock for "the damage threshold acting up", because all four doors
	// printed the same line. The texts are picked before stabilization, so live blood/brain state
	// can still tell the near-death sub-causes apart.
	var/list/collapse_texts = defeat_collapse_texts(reason)
	if(horny_defeat)
		// A horny defeat reads differently: the dark vignette stays, but the pink arousal wash (the
		// existing "lovehud" overlay) floods over it, so it never looks like a plain beatdown.
		owner.overlay_fullscreen("defeat_horny", /atom/movable/screen/fullscreen/love, 10)
		// The light case: a horny knockout wears off on its own after a short while (unless kidnapped).
		self_recover_at = world.time + DEFEAT_HORNY_SELF_RECOVER_TIME
		self_recover_timer = addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, defeat_horny_self_recover)), DEFEAT_HORNY_SELF_RECOVER_TIME, TIMER_STOPPABLE)
	else
		// The self-rescue (Struggle to Your Feet) is armed later, from enter_defeat, once the rune logic
		// has settled - so it only fires when no rune can answer (KO Only, or a depleted KO+Rune).
		collapse_texts["self"] += " You can still speak, emote, and call for help - but darkness crowds in at the edges of your sight."
	to_chat(owner, span_userdanger(collapse_texts["self"]))
	to_chat(owner, span_notice("Companions, prepared care, or a player-built campfire can help you recover. Rune and self-recovery options depend on your situation. Click the Defeated alert or use OOC > Defeat & Recovery for help."))
	SEND_SIGNAL(owner, COMSIG_LIVING_DEFEATED)
	owner.visible_message(span_userdanger(collapse_texts["visible"]))
	owner.balloon_alert_to_viewers(collapse_texts["balloon"])

/// The moment-of-collapse feedback per defeat track (self line / visible line / balloon), so a pain
/// shock, a bleed-out or a hazard never masquerades as an ordinary beatdown. The near-death track
/// splits further by what is actually killing the victim - blood, head, or the health floor - read
/// from the body's live state (stabilization runs after these messages fire).
/datum/status_effect/defeat_knockout/proc/defeat_collapse_texts(reason)
	switch(reason)
		if(DEFEAT_REASON_HORNY)
			return list(
				"self" = "Your body finally gives out, overwhelmed - you sink down, flushed and spent, too weak to resist.",
				"visible" = "[owner] sinks down, overwhelmed and spent!",
				"balloon" = "overwhelmed!",
			)
		if(DEFEAT_REASON_PAIN)
			return list(
				"self" = "The pain whites out everything else - your body simply refuses to go on, and you sink down where you stand.",
				"visible" = "[owner] goes rigid with agony and folds up, felled by sheer pain!",
				"balloon" = "felled by pain!",
			)
		if(DEFEAT_REASON_HAZARD)
			return list(
				"self" = "The deadly ground swallows you whole - your body gives out in an instant, your thread pulled taut.",
				"visible" = "[owner] is swallowed by the deadly ground, instantly overcome!",
				"balloon" = "swallowed!",
			)
		if(DEFEAT_REASON_DEATH)
			if(owner.blood_volume <= BLOOD_VOLUME_SURVIVE && !HAS_TRAIT(owner, TRAIT_BLOODLOSS_IMMUNE))
				return list(
					"self" = "Cold creeps in from your fingertips - too much of your blood is outside of you to keep standing.",
					"visible" = "[owner] sways, white as chalk, and collapses into a spreading red pool!",
					"balloon" = "bled white!",
				)
			var/mob/living/carbon/carbon_owner = owner
			if(istype(carbon_owner) && carbon_owner.getOrganLoss(ORGAN_SLOT_BRAIN) >= BRAIN_DAMAGE_DEATH)
				return list(
					"self" = "The world rings, doubles, and slides sideways - something in your head has given out.",
					"visible" = "[owner]'s eyes roll back - [owner] drops, struck senseless!",
					"balloon" = "struck senseless!",
				)
			return list(
				"self" = "Your strength runs out all at once - the world dims as you slip down, barely clinging on.",
				"visible" = "[owner] slips to the ground, at death's very door!",
				"balloon" = "at death's door!",
			)
	// DEFEAT_REASON_DAMAGE and any future/unknown reason: the ordinary beatdown.
	return list(
		"self" = "Battered past your body's limit, you crumple - too broken to fight on.",
		"visible" = "[owner] crumples under the punishment, defeated!",
		"balloon" = "beaten down!",
	)

/// Arms the KO Only anti-softlock self-rescue: the "Struggle to Your Feet" action shortly, and an auto
/// safety-net a little later. Called from enter_defeat only when no rune can answer, so a rune-saved
/// player never gets it. Idempotent.
/datum/status_effect/defeat_knockout/proc/arm_struggle_up()
	if(struggle_offer_timer || struggle_auto_timer || struggle_action)
		return
	struggle_offer_at = world.time + DEFEAT_KO_ONLY_STRUGGLE_DELAY * owner.defeat_struggle_delay_mult
	struggle_auto_at = world.time + DEFEAT_KO_ONLY_AUTO_RECOVER * owner.defeat_struggle_delay_mult
	to_chat(owner, span_notice("No rune can answer right now. Struggle to Your Feet becomes available in [DisplayTimeText(DEFEAT_KO_ONLY_STRUGGLE_DELAY * owner.defeat_struggle_delay_mult)]; unaided recovery follows in [DisplayTimeText(DEFEAT_KO_ONLY_AUTO_RECOVER * owner.defeat_struggle_delay_mult)] if you remain outside captivity."))
	struggle_offer_timer = addtimer(CALLBACK(src, PROC_REF(offer_struggle_up)), DEFEAT_KO_ONLY_STRUGGLE_DELAY * owner.defeat_struggle_delay_mult, TIMER_STOPPABLE)
	struggle_auto_timer = addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, defeat_ko_only_self_recover)), DEFEAT_KO_ONLY_AUTO_RECOVER * owner.defeat_struggle_delay_mult, TIMER_STOPPABLE)

/datum/status_effect/defeat_knockout/proc/offer_struggle_up()
	struggle_offer_timer = null
	if(!owner || QDELETED(owner) || struggle_action)
		return
	struggle_action = new(owner)
	struggle_action.Grant(owner)
	to_chat(owner, span_warning("No one is coming. You could yet drag yourself up - but your body will pay dearly for it. Use <b>Struggle to Your Feet</b> when you are ready to try."))

/datum/status_effect/defeat_knockout/on_remove()
	if(owner)
		owner.vis_contents -= yield_indicator
	QDEL_NULL(yield_indicator)
	if(self_recover_timer)
		deltimer(self_recover_timer)
		self_recover_timer = null
	if(struggle_offer_timer)
		deltimer(struggle_offer_timer)
		struggle_offer_timer = null
	if(struggle_auto_timer)
		deltimer(struggle_auto_timer)
		struggle_auto_timer = null
	if(struggle_action)
		if(owner)
			struggle_action.Remove(owner)
		QDEL_NULL(struggle_action)
	if(!owner || QDELETED(owner))
		return
	owner.reset_horny_defeat_progress()
	owner.clear_fullscreen("defeat", FALSE)
	owner.clear_fullscreen("defeat_horny")
	to_chat(owner, span_notice("You can move again, but the defeat still clings to you."))
	REMOVE_TRAIT(owner, TRAIT_NODEATH, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_NOHARDCRIT, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))
	var/datum/component/kidnap_captivity/captivity = owner.GetComponent(/datum/component/kidnap_captivity)
	captivity?.on_knockout_removed()
	return ..()

/datum/status_effect/defeat_knockout/remove_effect_on_heal(datum/source, heal_flags)
	if((heal_flags & HEAL_ADMIN) && !owner.defeat_suppress_heal_cleanup)
		qdel(src)
		return
	return ..()

/atom/movable/screen/alert/status_effect/defeat_knockout
	name = "Defeated"
	desc = "You are defeated. You can speak, emote, call for help, or call the rune if available."
	icon_state = "debuff"
	overlay_icon = 'modular_rmh/icons/hud/defeat_alerts.dmi'
	overlay_state = "defeated"

/atom/movable/screen/alert/status_effect/defeat_knockout/Click(location, control, params)
	if(usr == mob_viewer)
		mob_viewer.show_defeat_recovery_guide()

/// Long KO for a clientless mob brought down by horny defeat. Immobilizes and pauses the AI, then after
/// DEFEAT_MOB_HORNY_KO_DURATION deletes the mob if no player is watching, or holds the KO and re-checks
/// while players remain. Deliberately does NOT add TRAIT_NODEATH: a downed mob can still be finished off.
/datum/status_effect/mob_horny_knockout
	id = "mob_horny_knockout"
	duration = STATUS_EFFECT_PERMANENT
	remove_on_fullheal = FALSE
	var/cleanup_timer

/datum/status_effect/mob_horny_knockout/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	// A bare status change is undone by the next z-level or pause update; the trait holds it off.
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, TRAIT_STATUS_EFFECT(id))
	owner.ai_controller?.set_ai_status(AI_STATUS_OFF)
	owner.drop_all_grabs()
	LAZYNULL(owner.docile_restraints)
	SEND_SIGNAL(owner, COMSIG_LIVING_DEFEATED)
	owner.visible_message(span_userdanger("[owner] sinks down, overwhelmed and spent!"))
	cleanup_timer = addtimer(CALLBACK(src, PROC_REF(mob_horny_ko_cleanup_check)), DEFEAT_MOB_HORNY_KO_DURATION, TIMER_STOPPABLE)

/// End of the KO window: delete the mob if it is alone, else keep it down and look again shortly.
/datum/status_effect/mob_horny_knockout/proc/mob_horny_ko_cleanup_check()
	cleanup_timer = null
	if(!owner || QDELETED(owner))
		return
	if(owner.mob_horny_ko_players_nearby())
		cleanup_timer = addtimer(CALLBACK(src, PROC_REF(mob_horny_ko_cleanup_check)), DEFEAT_MOB_HORNY_KO_RECHECK, TIMER_STOPPABLE)
		return
	qdel(owner)

/datum/status_effect/mob_horny_knockout/on_remove()
	if(cleanup_timer)
		deltimer(cleanup_timer)
		cleanup_timer = null
	if(!owner || QDELETED(owner))
		return
	owner.reset_horny_defeat_progress()
	// Bonds put on while spent are accepted; the mob wakes without fighting them.
	owner.remember_docile_restraints()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, TRAIT_STATUS_EFFECT(id))
	owner.ai_controller?.set_ai_status(owner.ai_controller.get_expected_ai_status())
	return ..()

/atom/movable/screen/alert/status_effect/debuff/defeat_trauma
	name = "Defeat Trauma"
	desc = "Lingering harm from a recent defeat. A trauma treatment apparatus, a shrine of solace, or a field cure can mend it - and it festers worse each time you are defeated untreated."
	icon_state = "debuff"
	overlay_icon = 'modular_rmh/icons/hud/defeat_alerts.dmi'
	overlay_state = "physical"

/atom/movable/screen/alert/status_effect/debuff/defeat_trauma/Click(location, control, params)
	if(usr == mob_viewer)
		mob_viewer.show_defeat_recovery_guide()

/// Distinct icons per trauma family. The name and description are overwritten per trauma by
/// refresh_trauma_alert(); these defaults only show if a subtype somehow never stamps itself.
/atom/movable/screen/alert/status_effect/debuff/defeat_trauma/horny
	name = "Lewd Trauma"
	desc = "A wrung-out afterglow. Spiritual care, time, or a potent remedy restores you."
	overlay_state = "exhaustion"

/atom/movable/screen/alert/status_effect/debuff/defeat_trauma/rune
	name = "Rune Backlash"
	desc = "Cold rune-weariness from being wrenched back. A shrine of solace soothes it best; a trauma apparatus or a field cure also works."
	overlay_state = "backlash"

/datum/status_effect/debuff/defeat
	id = "defeat_trauma"
	duration = 30 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/debuff/defeat_trauma
	/// Player-facing label shown on the status alert; subtypes override per injury.
	var/trauma_label = "Defeat Trauma"
	/// Category word prefixed onto the alert name, so an ordinary injury, a lewd trauma, a rune
	/// backlash and convalescence are told apart at a glance instead of all reading "Defeat Trauma".
	var/trauma_category_label = "Injury"
	/// Unique alert description per injury, so no two defeat traumas read alike. Subtypes override.
	var/trauma_desc = "Lingering harm from a recent defeat. A trauma treatment apparatus, a shrine of solace, or a field cure can mend it - and it festers worse each time you are defeated untreated."
	/// Legacy treatment classification; provider eligibility uses the category and accepted tags below.
	var/treatment_class = DEFEAT_TREATMENT_MEDICAL
	/// Provider-driven treatment metadata. Providers diagnose by category/tag, select this exact
	/// status datum, then revalidate it after the interruptible treatment before paying the cost.
	/// Both treatment stations accept every ordinary trauma; the category only decides which station
	/// treats it as its specialty. The narrower compatibility providers still filter by category.
	var/trauma_category = DEFEAT_TRAUMA_CATEGORY_PHYSICAL
	var/list/accepted_provider_tags = list(DEFEAT_TRAUMA_PROVIDER_MEDICAL, DEFEAT_TRAUMA_PROVIDER_SHRINE, DEFEAT_TRAUMA_PROVIDER_UNIVERSAL)
	var/treatment_duration = 12 SECONDS
	var/treatment_skill = /datum/attribute/skill/misc/medicine
	var/treatment_skill_requirement = SKILL_RANK_APPRENTICE
	var/treatment_resource_cost = 1
	var/treatment_description = "Treat the lingering physical harm left by defeat."
	var/severity = DEFEAT_SEVERITY_NORMAL
	var/next_feedback_at = 0

/datum/status_effect/debuff/defeat/on_creation(mob/living/new_owner, duration_override, severity_override)
	if(severity_override)
		severity = severity_override
	if(!duration_override)
		duration_override = defeat_duration_for_severity(severity)
	. = ..()
	if(!.)
		return
	// The parent only builds linked_alert *after* on_apply() has already run, so stamping the label
	// there silently did nothing and every trauma kept the alert type's generic name. Do it here.
	refresh_trauma_alert()

/// Writes this trauma's category, label and severity onto its status alert. Safe to call repeatedly.
/datum/status_effect/debuff/defeat/proc/refresh_trauma_alert()
	if(!linked_alert)
		return FALSE
	linked_alert.name = "[trauma_category_label]: [trauma_label] ([defeat_severity_label(severity)])"
	linked_alert.desc = "[trauma_desc]<br>[mechanics_description()]<br>Click for remaining recovery time and the Defeat & Recovery guide."
	return TRUE

/datum/status_effect/debuff/defeat/proc/mechanics_description()
	var/list/penalties = list()
	for(var/stat in effectedstats)
		penalties += "[stat]: [effectedstats[stat]]"
	var/treatment = "Treatment: [defeat_station_treatment_text(src)]"
	if(DEFEAT_TRAUMA_PROVIDER_UNIVERSAL in accepted_provider_tags)
		treatment += " Field cures also work: swallow [DEFEAT_MERCY_DRAUGHT_DOSE] measures of Mercy Draught or receive Bear Their Burden."
	else
		treatment += " Field cures cannot lift it."
	var/recovery = defeat_duration_for_severity(severity)
	var/recovery_text = recovery == STATUS_EFFECT_PERMANENT ? "Requires treatment." : "Natural recovery: [DisplayTimeText(recovery)] when newly applied."
	return "Effects: [penalties.Join(", ")]. [recovery_text] [treatment]"

/datum/status_effect/debuff/defeat/remove_effect_on_heal(datum/source, heal_flags)
	if((heal_flags & HEAL_ADMIN) && !owner.defeat_suppress_heal_cleanup)
		qdel(src)
		return
	return ..()

/datum/status_effect/debuff/defeat/on_apply()
	var/penalty = defeat_penalty_for_severity(severity)
	if(penalty)
		effectedstats = defeat_stat_penalties(penalty)
	. = ..()
	if(.)
		// on_creation lists us before on_apply runs, so this sum already counts our own penalty.
		owner.refresh_defeat_trauma_endurance_cap()

/datum/status_effect/debuff/defeat/on_remove()
	. = ..()
	// Destroy unlists us before on_remove, so the recount correctly drops our penalty.
	owner?.refresh_defeat_trauma_endurance_cap()

/datum/status_effect/debuff/defeat/tick()
	if(!owner || world.time < next_feedback_at)
		return
	if(!prob(defeat_feedback_chance()))
		return
	next_feedback_at = world.time + rand(35 SECONDS, 70 SECONDS)
	defeat_apply_feedback()

/datum/status_effect/debuff/defeat/proc/defeat_duration_for_severity(defeat_severity)
	switch(defeat_severity)
		if(DEFEAT_SEVERITY_LIGHT)
			return 10 MINUTES
		if(DEFEAT_SEVERITY_SEVERE)
			return 60 MINUTES
	return 30 MINUTES

/datum/status_effect/debuff/defeat/proc/defeat_penalty_for_severity(defeat_severity)
	switch(defeat_severity)
		if(DEFEAT_SEVERITY_LIGHT)
			return 1
		if(DEFEAT_SEVERITY_SEVERE)
			return 3
	return 2

/// The normal-severity attribute profile for this trauma. Subtypes override with their own fixed
/// profile (see DEFEAT_SYSTEM_SPEC_ADDENDUM.md section 4). Stamina% from the design is folded into
/// STAT_ENDURANCE (about -1 per 10%). Mana% is handled separately where it matters (see rune trauma).
/datum/status_effect/debuff/defeat/proc/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_SPEED = -2)

/datum/status_effect/debuff/defeat/proc/defeat_stat_penalties(penalty)
	var/list/base = defeat_base_profile()
	var/list/scaled = list()
	for(var/stat in base)
		scaled[stat] = defeat_scaled_stat(base[stat], penalty)
	return scaled

/// Scales a normal-severity stat value by the severity penalty (1 light / 2 normal / 3 severe),
/// i.e. x0.5 / x1.0 / x1.5, never letting a non-zero value round away to nothing.
/proc/defeat_scaled_stat(base, penalty)
	if(!base)
		return 0
	var/magnitude = max(1, round(abs(base) * penalty / 2 + 0.5))
	return (base < 0) ? -magnitude : magnitude

/datum/status_effect/debuff/defeat/proc/defeat_feedback_chance()
	switch(severity)
		if(DEFEAT_SEVERITY_LIGHT)
			return 8
		if(DEFEAT_SEVERITY_SEVERE)
			return 18
	return 12

/datum/status_effect/debuff/defeat/proc/defeat_apply_feedback()
	if(!owner)
		return
	to_chat(owner, span_warning("The defeat still weighs on me."))

/datum/status_effect/debuff/defeat/physical
	id = "defeat_physical_trauma"
	trauma_label = "Battered Body"
	trauma_desc = "A whole-body beating - deep bruises and strained muscles that protest every hard motion. A town healer or a potent remedy will mend it."

/datum/status_effect/debuff/defeat/physical/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_STRENGTH = -2, STAT_SPEED = -1)

/datum/status_effect/debuff/defeat/physical/defeat_apply_feedback()
	to_chat(owner, span_warning("My body protests every hard motion."))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustPainLoss(severity == DEFEAT_SEVERITY_SEVERE ? 3 : 1)

/datum/status_effect/debuff/defeat/physical/wound
	id = "defeat_wound_trauma"
	trauma_label = "Open Wounds"
	trauma_desc = "Gashes and cuts that reopen with exertion, flaring old pain and slowing you down. A town healer or a potent remedy will close them."

/datum/status_effect/debuff/defeat/physical/wound/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_SPEED = -2, STAT_STRENGTH = -1)

/datum/status_effect/debuff/defeat/physical/wound/defeat_apply_feedback()
	to_chat(owner, span_warning("Old wound pain flares through my body."))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustPainLoss(severity == DEFEAT_SEVERITY_SEVERE ? 4 : 2)

/datum/status_effect/debuff/defeat/physical/burn
	id = "defeat_burn_trauma"
	trauma_label = "Searing Burns"
	trauma_desc = "Raw, blistered skin that prickles with heat at every move, sapping your endurance and toughness. A town healer or a potent remedy will soothe it."

/datum/status_effect/debuff/defeat/physical/burn/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_CONSTITUTION = -2)

/datum/status_effect/debuff/defeat/physical/burn/defeat_apply_feedback()
	to_chat(owner, span_warning("My burned skin prickles with raw heat."))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustPainLoss(severity == DEFEAT_SEVERITY_SEVERE ? 4 : 2)

/datum/status_effect/debuff/defeat/physical/body
	id = "defeat_body_trauma"
	trauma_label = "Internal Bruising"
	trauma_desc = "Battered ribs and bruised innards - your chest strains under any effort, draining strength and vigor. A town healer or a potent remedy will ease it."

// Internal Bruising (Chest Injury) - section 4 of the spec.
/datum/status_effect/debuff/defeat/physical/body/defeat_base_profile()
	return list(STAT_ENDURANCE = -3, STAT_STRENGTH = -2, STAT_SPEED = -2, STAT_CONSTITUTION = -3)

/datum/status_effect/debuff/defeat/physical/body/defeat_apply_feedback()
	to_chat(owner, span_warning("My bruised chest strains under the effort."))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustPainLoss(severity == DEFEAT_SEVERITY_SEVERE ? 3 : 1)

/datum/status_effect/debuff/defeat/physical/concussion
	id = "defeat_concussion_trauma"
	trauma_label = "Concussion"
	trauma_desc = "A rattled skull - thoughts swim, the world tilts, and your wits and aim are dulled. A town healer or a potent remedy will clear your head."

// Concussion (Head Trauma) - section 4 of the spec.
/datum/status_effect/debuff/defeat/physical/concussion/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_PERCEPTION = -3, STAT_INTELLIGENCE = -2, STAT_CONSTITUTION = -2, STAT_SPEED = -1, STAT_FORTUNE = -2)

/datum/status_effect/debuff/defeat/physical/concussion/defeat_apply_feedback()
	to_chat(owner, span_warning("My thoughts swim and the world tilts."))
	owner.adjust_dizzy(severity == DEFEAT_SEVERITY_SEVERE ? 6 SECONDS : 3 SECONDS)
	if(severity != DEFEAT_SEVERITY_LIGHT)
		owner.adjust_confusion(2 SECONDS)

// Sprained/Torn Knee or Ankle (Leg Injury) - random falls, can't jump. Section 4.
/datum/status_effect/debuff/defeat/physical/leg
	id = "defeat_leg_trauma"
	trauma_label = "Wrenched Leg"
	trauma_desc = "A wrenched knee or ankle that buckles without warning and cannot bear a jump. A town healer or a potent remedy will set it right."

/datum/status_effect/debuff/defeat/physical/leg/defeat_base_profile()
	return list(STAT_ENDURANCE = -3, STAT_STRENGTH = -2, STAT_SPEED = -4, STAT_FORTUNE = -1)

/datum/status_effect/debuff/defeat/physical/leg/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DEFEAT_NO_JUMP, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/debuff/defeat/physical/leg/on_remove()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_DEFEAT_NO_JUMP, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/debuff/defeat/physical/leg/defeat_apply_feedback()
	to_chat(owner, span_warning("My injured leg buckles under me."))
	if(prob(severity == DEFEAT_SEVERITY_SEVERE ? 60 : 35))
		owner.Knockdown(severity == DEFEAT_SEVERITY_SEVERE ? 3 SECONDS : 1.5 SECONDS)

// Dislocated Shoulder or Fractured Arm (Arm Injury) - random item drops. Section 4.
/datum/status_effect/debuff/defeat/physical/arm
	id = "defeat_arm_trauma"
	trauma_label = "Wrenched Arm"
	trauma_desc = "A dislocated shoulder or fractured arm - your grip fails and things slip from your hand. A town healer or a potent remedy will mend it."

/datum/status_effect/debuff/defeat/physical/arm/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_STRENGTH = -4, STAT_PERCEPTION = -1, STAT_SPEED = -2)

/datum/status_effect/debuff/defeat/physical/arm/defeat_apply_feedback()
	to_chat(owner, span_warning("My arm spasms and my grip fails."))
	if(prob(severity == DEFEAT_SEVERITY_SEVERE ? 55 : 30))
		var/obj/item/dropped = owner.get_active_held_item()
		if(dropped)
			owner.dropItemToGround(dropped)
			to_chat(owner, span_warning("[dropped] slips from my hand!"))

/datum/status_effect/debuff/defeat/pain
	id = "defeat_pain_trauma"
	trauma_label = "Lingering Pain"
	trauma_desc = "Phantom aches roll back through you in waves, fraying nerve and focus. A town healer or a potent remedy will quiet them."

/datum/status_effect/debuff/defeat/blood_loss
	id = "defeat_blood_loss_trauma"
	trauma_label = "Blood-Loss Weakness"
	trauma_desc = "Your bleeding has been stabilized, but the ordeal has left you weak and slow. This aftermath does not cause additional bleeding."
	treatment_description = "Treat weakness left by critical blood loss."

/datum/status_effect/debuff/defeat/blood_loss/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_STRENGTH = -1, STAT_SPEED = -1)

/datum/status_effect/debuff/defeat/blood_loss/defeat_apply_feedback()
	to_chat(owner, span_warning("I still feel weak after losing so much blood."))

/datum/status_effect/debuff/defeat/breathless
	id = "defeat_breathless_trauma"
	trauma_label = "Breathless Exhaustion"
	trauma_desc = "Oxygen deprivation has left you exhausted and unfocused. This aftermath does not inflict further oxygen damage."
	treatment_description = "Restore strength after oxygen deprivation."

/datum/status_effect/debuff/defeat/breathless/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_PERCEPTION = -1)

/datum/status_effect/debuff/defeat/breathless/defeat_apply_feedback()
	to_chat(owner, span_warning("I pause to catch my breath."))

/datum/status_effect/debuff/defeat/poisoned
	id = "defeat_poisoned_trauma"
	trauma_label = "Poisoning Aftereffects"
	trauma_desc = "Poisoning has left your body weak and your thoughts sluggish. This aftermath does not add toxin damage; any poison still in your body needs separate treatment."
	treatment_description = "Treat the lingering weakness left by poisoning."

/datum/status_effect/debuff/defeat/poisoned/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_CONSTITUTION = -1, STAT_INTELLIGENCE = -1)

/datum/status_effect/debuff/defeat/poisoned/defeat_apply_feedback()
	to_chat(owner, span_warning("My body still feels drained by the poisoning."))

/datum/status_effect/debuff/defeat/body_strain
	id = "defeat_body_strain_trauma"
	trauma_label = "Systemic Strain"
	trauma_desc = "Damage throughout your body has left you weakened. This aftermath does not inflict further bodily damage."
	treatment_description = "Treat systemic weakness after bodily deterioration."

/datum/status_effect/debuff/defeat/body_strain/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_CONSTITUTION = -2)

/datum/status_effect/debuff/defeat/body_strain/defeat_apply_feedback()
	to_chat(owner, span_warning("My body needs time to regain its strength."))

/datum/status_effect/debuff/defeat/pain/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_PERCEPTION = -2)

/datum/status_effect/debuff/defeat/pain/defeat_apply_feedback()
	to_chat(owner, span_warning("A memory of pain rolls back through me."))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustPainLoss(severity == DEFEAT_SEVERITY_SEVERE ? 5 : 2)

/datum/status_effect/debuff/defeat/rune
	id = "defeat_rune_trauma"
	trauma_label = "Mana Backlash"
	trauma_category_label = "Backlash"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/defeat_trauma/rune
	trauma_desc = "Cold rune-weariness from being wrenched back - your mind and will are dulled and your mana slow to return. A shrine of solace soothes it best; a trauma apparatus or a field cure also works."
	treatment_class = DEFEAT_TREATMENT_SPIRITUAL
	trauma_category = DEFEAT_TRAUMA_CATEGORY_SPIRITUAL
	accepted_provider_tags = list(DEFEAT_TRAUMA_PROVIDER_SHRINE, DEFEAT_TRAUMA_PROVIDER_MEDICAL, DEFEAT_TRAUMA_PROVIDER_UNIVERSAL)
	treatment_skill = /datum/attribute/skill/magic/holy
	treatment_skill_requirement = SKILL_RANK_NOVICE
	treatment_description = "Soothe the spiritual and magical backlash left by the resurrection rune."

// Mana-Backlash Exhaustion - the toll of being yanked back by the rune. Section 4.
/datum/status_effect/debuff/defeat/rune/defeat_base_profile()
	return list(STAT_INTELLIGENCE = -4, STAT_CONSTITUTION = -3, STAT_FORTUNE = -2)

/datum/status_effect/debuff/defeat/rune/on_apply()
	. = ..()
	if(!.)
		return
	// One-time mana backlash - drains half of whatever mana the caster had left.
	if(owner.mana_pool)
		owner.mana_pool.adjust_mana(-round(owner.mana_pool.amount * 0.5))

/datum/status_effect/debuff/defeat/rune/defeat_apply_feedback()
	to_chat(owner, span_warning("A cold rune-weariness passes through my soul."))
	owner.flash_fullscreen("curse1")

/datum/status_effect/debuff/defeat/horny
	id = "defeat_horny_trauma"
	trauma_label = "Lewd Exhaustion"
	trauma_category_label = "Lewd"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/defeat_trauma/horny
	trauma_desc = "A wrung-out, trembling afterglow lets focus and luck slip through your fingers. Spiritual care, time, or a potent remedy restores you."
	treatment_class = DEFEAT_TREATMENT_SPIRITUAL
	// Intimate defeat is spiritual trauma for routing purposes. Its own subtype and descriptive
	// metadata still let shrines present it distinctly from rune backlash.
	trauma_category = DEFEAT_TRAUMA_CATEGORY_SPIRITUAL
	accepted_provider_tags = list(DEFEAT_TRAUMA_PROVIDER_SHRINE, DEFEAT_TRAUMA_PROVIDER_MEDICAL, DEFEAT_TRAUMA_PROVIDER_UNIVERSAL)
	treatment_skill = /datum/attribute/skill/magic/holy
	treatment_skill_requirement = SKILL_RANK_NOVICE
	treatment_description = "Restore composure and spirit after an overwhelming intimate defeat."

/datum/status_effect/debuff/defeat/horny/defeat_base_profile()
	return list(STAT_PERCEPTION = -2, STAT_FORTUNE = -2)

/datum/status_effect/debuff/defeat/horny/defeat_apply_feedback()
	to_chat(owner, span_warning("A humiliating memory cuts through my focus."))
	if(severity == DEFEAT_SEVERITY_SEVERE)
		owner.adjust_confusion(2 SECONDS)

// 4.1 Horny debuffs - six flavors. They all inherit the "defeat_horny_trauma" id so any of them is
// cleared the same way (lifting/time/priest); they differ only in stat profile and special effects.

// Post-Climax Brain-Fog ("Can't Think Straight")
/datum/status_effect/debuff/defeat/horny/brainfog
	trauma_label = "Afterglow Haze"
	trauma_desc = "Your head swims in a thick, pleasured fog - thought comes slow and scattered. Spiritual care, time, or a potent remedy will clear it."

/datum/status_effect/debuff/defeat/horny/brainfog/defeat_base_profile()
	return list(STAT_PERCEPTION = -3, STAT_INTELLIGENCE = -4, STAT_CONSTITUTION = -3)

/datum/status_effect/debuff/defeat/horny/brainfog/defeat_apply_feedback()
	to_chat(owner, span_warning("I can't think straight - my head swims with afterglow."))
	if(severity != DEFEAT_SEVERITY_LIGHT)
		owner.adjust_confusion(2 SECONDS)

// Over-Sensitive Skin & Throbbing Heat ("Body on Fire")
/datum/status_effect/debuff/defeat/horny/oversensitive
	trauma_label = "Oversensitive Skin"
	trauma_desc = "Raw, over-sensitive skin where every brush of cloth is far too much, sapping your strength and vigor. Spiritual care, time, or a potent remedy will settle it."

/datum/status_effect/debuff/defeat/horny/oversensitive/defeat_base_profile()
	return list(STAT_ENDURANCE = -3, STAT_STRENGTH = -2, STAT_CONSTITUTION = -4, STAT_SPEED = -2)

/datum/status_effect/debuff/defeat/horny/oversensitive/defeat_apply_feedback()
	to_chat(owner, span_warning("My skin burns - every brush of cloth is far too much."))

// Rubbery Legs / Aroused Wobble ("Can't Walk Straight") - random falls, can't jump.
/datum/status_effect/debuff/defeat/horny/wobble
	trauma_label = "Rubbery Legs"
	trauma_desc = "Aroused, trembling legs that wobble and give out without warning - and cannot manage a jump. Spiritual care, time, or a potent remedy will steady them."

/datum/status_effect/debuff/defeat/horny/wobble/defeat_base_profile()
	return list(STAT_ENDURANCE = -3, STAT_STRENGTH = -3, STAT_SPEED = -4, STAT_FORTUNE = -2)

/datum/status_effect/debuff/defeat/horny/wobble/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DEFEAT_NO_JUMP, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/debuff/defeat/horny/wobble/on_remove()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_DEFEAT_NO_JUMP, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/debuff/defeat/horny/wobble/defeat_apply_feedback()
	to_chat(owner, span_warning("My legs wobble, weak and trembling beneath me."))
	if(prob(severity == DEFEAT_SEVERITY_SEVERE ? 55 : 30))
		owner.Knockdown(severity == DEFEAT_SEVERITY_SEVERE ? 3 SECONDS : 1.5 SECONDS)

// Trembling Hands & Weak Grip ("Can't Hold On") - random item drops.
/datum/status_effect/debuff/defeat/horny/trembling
	trauma_label = "Trembling Hands"
	trauma_desc = "Weak, shaking hands with a failing grip - things slip from your fingers. Spiritual care, time, or a potent remedy will still them."

/datum/status_effect/debuff/defeat/horny/trembling/defeat_base_profile()
	return list(STAT_ENDURANCE = -2, STAT_STRENGTH = -4, STAT_PERCEPTION = -1, STAT_SPEED = -2)

/datum/status_effect/debuff/defeat/horny/trembling/defeat_apply_feedback()
	to_chat(owner, span_warning("My hands tremble - I can barely keep my grip."))
	if(prob(severity == DEFEAT_SEVERITY_SEVERE ? 50 : 28))
		var/obj/item/dropped = owner.get_active_held_item()
		if(dropped)
			owner.dropItemToGround(dropped)
			to_chat(owner, span_warning("[dropped] slips from my trembling fingers!"))

// Panting & Breathless Craving ("Can't Breathe Right")
/datum/status_effect/debuff/defeat/horny/breathless
	trauma_label = "Breathless Craving"
	trauma_desc = "Chest heaving, unable to catch your breath - your stamina drains fast. Spiritual care, time, or a potent remedy will calm it."

/datum/status_effect/debuff/defeat/horny/breathless/defeat_base_profile()
	return list(STAT_ENDURANCE = -5, STAT_SPEED = -2, STAT_CONSTITUTION = -3)

/datum/status_effect/debuff/defeat/horny/breathless/defeat_apply_feedback()
	to_chat(owner, span_warning("I can't catch my breath, chest heaving uselessly."))

// Lust-Mana Overcharge ("Horny Magic Burn") - one-time mana burn like the rune backlash.
/datum/status_effect/debuff/defeat/horny/overcharge
	trauma_label = "Lust-Burned Mana"
	trauma_desc = "Lust-scorched magic crackles uselessly through you - your wits are dulled and your mana half-spent. Spiritual care, time, or a potent remedy will mend it."

/datum/status_effect/debuff/defeat/horny/overcharge/defeat_base_profile()
	return list(STAT_INTELLIGENCE = -4, STAT_CONSTITUTION = -3, STAT_FORTUNE = -2)

/datum/status_effect/debuff/defeat/horny/overcharge/on_apply()
	. = ..()
	if(!.)
		return
	if(owner.mana_pool)
		owner.mana_pool.adjust_mana(-round(owner.mana_pool.amount * 0.5))

/datum/status_effect/debuff/defeat/horny/overcharge/defeat_apply_feedback()
	to_chat(owner, span_warning("Lust-burned magic crackles uselessly through me."))

// --- KO Only anti-softlock: struggle up unaided, at the price of Convalescence ---

/datum/action/innate/defeat_struggle_up
	name = "Struggle to Your Feet"
	desc = "Drag yourself up from defeat. Convalescence prevents fighting and slows movement for fifteen minutes; a trauma treatment apparatus or shrine of solace can end it sooner. Field cures cannot."
	button_icon_state = "shieldsparkles"

/datum/action/innate/defeat_struggle_up/Activate()
	if(!isliving(owner))
		return
	var/mob/living/living_owner = owner
	living_owner.defeat_ko_only_self_recover()

// Unaided physical recovery adds convalescence. Both stations treat it; field cures do not.
/atom/movable/screen/alert/status_effect/debuff/defeat_trauma/grievous
	name = "Convalescence"
	overlay_state = "convalescence"

/datum/status_effect/debuff/defeat/grievous
	id = "defeat_grievous_trauma"
	trauma_label = "Convalescence"
	trauma_category_label = "Recovery"
	trauma_desc = "Recovering unaided has left you unable to fight and slowed to a limp. This fades after fifteen minutes; either trauma station can end it sooner. Field cures cannot."
	remove_on_fullheal = FALSE
	// Deliberately narrower than the base list: dropping the universal tag keeps field healing out.
	accepted_provider_tags = list(DEFEAT_TRAUMA_PROVIDER_MEDICAL, DEFEAT_TRAUMA_PROVIDER_SHRINE)
	alert_type = /atom/movable/screen/alert/status_effect/debuff/defeat_trauma/grievous

/datum/status_effect/debuff/defeat/grievous/defeat_duration_for_severity(defeat_severity)
	return DEFEAT_GRIEVOUS_RECOVERY_TIME

/datum/status_effect/debuff/defeat/grievous/defeat_base_profile()
	return list(STAT_ENDURANCE = -4, STAT_STRENGTH = -3, STAT_SPEED = -4, STAT_CONSTITUTION = -3, STAT_PERCEPTION = -2)

/datum/status_effect/debuff/defeat/grievous/on_apply()
	. = ..()
	if(!.)
		return
	// Too broken to fight, and slowed to a limp until treated.
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	owner.cmode = FALSE
	owner.add_movespeed_modifier(MOVESPEED_ID_STATUS_EFFECT(id), multiplicative_slowdown = (severity == DEFEAT_SEVERITY_SEVERE ? 2.5 : 1.8))

/datum/status_effect/debuff/defeat/grievous/on_remove()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
		owner.remove_movespeed_modifier(MOVESPEED_ID_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/debuff/defeat/grievous/defeat_apply_feedback()
	to_chat(owner, span_warning("Your wounds scream - you can barely keep your feet under you."))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustPainLoss(severity == DEFEAT_SEVERITY_SEVERE ? 4 : 2)

/// The price of a successful sacrifice cannot be cured by its own spell, a draught, or ordinary healing.
/datum/status_effect/sacrificial_exhaustion
	id = "sacrificial_exhaustion"
	duration = DEFEAT_BURDEN_EXHAUSTION_TIME
	tick_interval = STATUS_EFFECT_NO_TICK
	remove_on_fullheal = FALSE
	alert_type = /atom/movable/screen/alert/status_effect/sacrificial_exhaustion

/atom/movable/screen/alert/status_effect/sacrificial_exhaustion
	name = "Sacrificial Exhaustion"
	desc = "You have borne another's suffering. Bear Their Burden cannot be cast again until two minutes have passed; healing and trauma treatments cannot shorten this recovery."
	icon_state = "debuff"
	overlay_icon = 'modular_rmh/icons/hud/defeat_alerts.dmi'
	overlay_state = "exhaustion"
