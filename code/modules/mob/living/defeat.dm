/mob/living
	/// Player-facing defeat routing preference cached from character preferences.
	var/defeat_mode = DEFEAT_MODE_DEFAULT
	/// Pooled brute, burn, toxin, and clone damage threshold that can enter the defeat system.
	var/defeat_damage_threshold = DEFEAT_DAMAGE_THRESHOLD_DEFAULT
	/// Explicit opt-in gate for AI bodies. Player-controlled bodies are evaluated separately.
	var/defeat_system_ai_opt_in = FALSE
	/// Most recent defeat snapshot captured before stabilization/rune routing.
	var/datum/defeat_snapshot/last_defeat_snapshot
	/// Multiplier on the KO Only struggle-up timers (content hooks may shorten
	/// them - e.g. a dungeon boon). 1 = the standard delays.
	var/defeat_struggle_delay_mult = 1
	/// Set by the resurrection rune around its own ADMIN_HEAL_ALL revive so that heal does NOT auto-wipe
	/// the defeat KO/traumas - the rune runs its own defeat teardown (manual KO removal + trauma
	/// escalation). Every other HEAL_ADMIN heal (the admin verb) still resets defeat state. Transient.
	var/tmp/defeat_suppress_heal_cleanup = FALSE
	/// The one recovery action currently being performed on this victim.
	var/datum/defeat_recovery_channel/defeat_recovery_channel
	/// Scoped bypass for explicit death choices and administrative destruction.
	var/tmp/defeat_lethal_bypass = FALSE
	/// Blocks automatic rune rescue after an explicitly final death.
	var/defeat_final_death = FALSE

/mob/living/proc/defeat_intercept_lethal(reason = DEFEAT_REASON_DEATH)
	if(defeat_lethal_bypass || suiciding || stat == DEAD || !defeat_system_is_eligible())
		return FALSE
	if(has_status_effect(/datum/status_effect/defeat_knockout))
		return TRUE
	return enter_defeat(reason, DEFEAT_SEVERITY_SEVERE)

/mob/living/proc/defeat_explicit_death(gibbed = FALSE)
	defeat_final_death = TRUE
	var/previous_bypass = defeat_lethal_bypass
	defeat_lethal_bypass = TRUE
	var/result = death(gibbed)
	defeat_lethal_bypass = previous_bypass
	return result

/mob/living/proc/defeat_rescue_from_hazard()
	if(!defeat_intercept_lethal(DEFEAT_REASON_HAZARD))
		return FALSE
	var/turf/destination
	for(var/turf/candidate in range(DEFEAT_HAZARD_RESCUE_RADIUS, src))
		if(!defeat_safe_recovery_turf(candidate))
			continue
		if(!destination || get_dist(src, candidate) < get_dist(src, destination))
			destination = candidate
	if(!destination)
		for(var/obj/effect/landmark/start/start as anything in GLOB.start_landmarks_list)
			var/turf/candidate = get_turf(start)
			if(defeat_safe_recovery_turf(candidate))
				destination = candidate
				break
	if(!destination)
		log_game("Defeat hazard rescue could not find safe ground for [key_name(src)] at [AREACOORD(src)].")
		return TRUE
	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)
	stop_pulling()
	if(pulledby)
		pulledby.stop_pulling()
	ExtinguishMob()
	forceMove(destination)
	to_chat(src, span_notice("A last thread of mercy carries you onto safe ground. You are defeated, but alive."))
	return TRUE

/proc/defeat_safe_recovery_turf(turf/candidate)
	if(!isopenturf(candidate) || candidate.density || islava(candidate) || istype(candidate, /turf/open/openspace) || istype(candidate, /turf/open/water) || istype(candidate, /turf/open/dungeon_trap))
		return FALSE
	for(var/atom/movable/obstacle in candidate)
		if(obstacle.density)
			return FALSE
	return TRUE

/mob/living/proc/cache_defeat_preferences_from_prefs(datum/preferences/prefs)
	if(!prefs)
		return
	defeat_mode = prefs.get_defeat_mode()
	defeat_damage_threshold = prefs.get_defeat_damage_threshold()
	defeat_enforce_ko_only_rune_optout()
	ensure_defeat_monitor()

/// Knockout Only means no rune: sever any bond that roundstart auto-linking (a separate path from
/// prefs, so ordering between the two is unreliable) may have forged, so the player never gets the
/// rune's Call offer layered over their chosen self-rescue. Enforced whenever prefs land on a body;
/// walking up to a rune and linking by hand afterwards still works - that choice is theirs.
/mob/living/proc/defeat_enforce_ko_only_rune_optout()
	if(defeat_mode != DEFEAT_MODE_KO_ONLY)
		return FALSE
	if(!ishuman(src))
		return FALSE
	// Strip the mind from every rune controller (clears linked body, rescue offers, ghost return).
	if(mind)
		unlink_mind_from_other_resurrection_runes(mind, null)
	// And clear a dangling tag left by any tag-only or mindless edge, so the controller lookup
	// (which resolves through rune_linked) can never surface a rescue for this body.
	var/mob/living/carbon/human/human_owner = src
	if(human_owner.rune_linked != RUNE_LINK_NONE)
		human_owner.rune_linked = RUNE_LINK_NONE
	return TRUE

/mob/living/proc/ensure_defeat_monitor()
	// Clientless mobs opted into horny-KO get the monitor regardless of carbon defeat eligibility.
	if(mob_horny_defeat_enabled && !client)
		AddComponent(/datum/component/defeat_monitor)
		return
	if(defeat_mode == DEFEAT_MODE_NO_RETURN)
		return
	if(!defeat_system_is_eligible())
		return
	AddComponent(/datum/component/defeat_monitor)

/mob/living/proc/defeat_system_is_eligible()
	if(defeat_lethal_bypass || defeat_final_death || suiciding)
		return FALSE
	if(defeat_mode == DEFEAT_MODE_NO_RETURN)
		return FALSE
	if(!iscarbon(src))
		return FALSE
	if((mob_biotypes & MOB_UNDEAD) && (!mind?.key || IS_DEADITE(src)))
		return FALSE
	// A lair's captive NPC is scenery for its denizens: no defeat, no kidnap of its own.
	if(GetComponent(/datum/component/npc_in_distress))
		return FALSE
	if(defeat_system_ai_opt_in)
		return TRUE
	// NPCs like orc warlords carry a keyless mind; only a player's keyed mind earns the regular KO.
	if(client || mind?.key)
		return TRUE
	return FALSE

/// Eligibility for the horny-defeat mechanic specifically. Clientless mobs flagged for mob-KO qualify on
/// their own; everyone else falls back to the full carbon defeat eligibility. Kept separate so the mob
/// path never drags a mob into the player damage/pain/hazard defeat flow.
/mob/living/proc/horny_defeat_is_eligible()
	if(mob_horny_defeat_enabled && !client)
		return TRUE
	return defeat_system_is_eligible()

/// TRUE when a client-controlled mob can currently see this mob. Used to decide whether a horny-KO'd mob
/// lingers (someone is watching) or is quietly cleaned up (no one around).
/mob/living/proc/mob_horny_ko_players_nearby()
	for(var/mob/living/nearby in viewers(DEFEAT_MOB_HORNY_CLEANUP_VIEW, src))
		if(nearby == src)
			continue
		if(nearby.client)
			return TRUE
	return FALSE

/mob/living/proc/enter_defeat(reason = DEFEAT_REASON_DAMAGE, severity = DEFEAT_SEVERITY_NORMAL, mob/living/source)
	if(!defeat_system_is_eligible())
		return FALSE
	if(stat == DEAD)
		return FALSE
	if(has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE

	var/mob/living/carbon/carbon_target = src
	if(!istype(carbon_target))
		return FALSE

	var/datum/defeat_snapshot/snapshot = new
	if(!snapshot.capture_from(carbon_target, reason, severity, source))
		qdel(snapshot)
		return FALSE

	last_defeat_snapshot = snapshot
	apply_status_effect(/datum/status_effect/defeat_knockout)
	defeat_ensure_emergency_rune_link()
	defeat_maybe_arm_struggle_up()
	defeat_stabilize_from_snapshot(snapshot)
	return TRUE

/// The clientless-mob counterpart of enter_defeat's horny branch. No snapshot, no trauma, no carbon
/// injury stabilization - just the long mob KO. Guarded so it only ever touches an enabled clientless mob.
/mob/living/proc/enter_mob_horny_defeat(mob/living/source)
	if(!mob_horny_defeat_enabled || client)
		return FALSE
	if(stat == DEAD)
		return FALSE
	if(has_status_effect(/datum/status_effect/mob_horny_knockout))
		return FALSE
	apply_status_effect(/datum/status_effect/mob_horny_knockout)
	return TRUE

/// Lets go of everything this mob holds, so a spent mob never keeps its prey pinned.
/mob/living/proc/drop_all_grabs()
	stop_pulling()
	for(var/obj/item/grabbing/grab in held_items)
		dropItemToGround(grab, silent = TRUE)

/// Arms tied counts as bound: legs alone still leave it free to strike.
/mob/living/proc/mob_horny_ko_arms_bound()
	return HAS_TRAIT(src, TRAIT_RESTRAINED)

/// Weakrefs to the bonds this mob woke up in. Only those exact items go unfought.
/mob/living/var/list/docile_restraints

/mob/living/proc/remember_docile_restraints()
	return

/mob/living/carbon/remember_docile_restraints()
	LAZYNULL(docile_restraints)
	if(handcuffed)
		LAZYADD(docile_restraints, WEAKREF(handcuffed))
	if(legcuffed)
		LAZYADD(docile_restraints, WEAKREF(legcuffed))

/mob/living/proc/is_docile_restraint(obj/item/restraint)
	if(!restraint || client || !LAZYLEN(docile_restraints))
		return FALSE
	for(var/datum/weakref/ref as anything in docile_restraints)
		if(ref.resolve() == restraint)
			return TRUE
	return FALSE

/// TRUE when every bond on this clientless mob is one it accepted while spent.
/mob/living/carbon/proc/restraints_all_docile()
	if(!handcuffed && !legcuffed)
		return FALSE
	if(handcuffed && !is_docile_restraint(handcuffed))
		return FALSE
	if(legcuffed && !is_docile_restraint(legcuffed))
		return FALSE
	return TRUE

/// Help-intent rescue for a spent mob. Returns TRUE when the click was used for it.
/mob/living/proc/try_mob_horny_ko_help_up(mob/living/helper)
	if(!has_status_effect(/datum/status_effect/mob_horny_knockout))
		return FALSE
	if(!istype(helper) || helper == src || helper.stat != CONSCIOUS)
		return FALSE
	helper.visible_message(span_notice("[helper] kneels and starts bringing [src] back to [p_their()] senses..."), span_notice("I start bringing [src] back to [p_their()] senses..."))
	if(!do_after(helper, DEFEAT_MOB_HORNY_HELP_UP_TIME, src))
		to_chat(helper, span_warning("I stop tending to [src]."))
		return TRUE
	if(!has_status_effect(/datum/status_effect/mob_horny_knockout))
		return TRUE
	remove_status_effect(/datum/status_effect/mob_horny_knockout)
	helper.visible_message(span_notice("[helper] helps [src] back up."), span_notice("I help [src] back up."))
	return TRUE

/// Warns before lifting an unbound spent mob. Returns TRUE when the lift may go ahead.
/mob/living/proc/confirm_mob_horny_ko_lift(mob/living/lifter)
	if(!has_status_effect(/datum/status_effect/mob_horny_knockout) || mob_horny_ko_arms_bound())
		return TRUE
	if(!lifter?.client)
		return TRUE
	var/choice = tgui_alert(lifter, "[src] is not bound. [capitalize(p_they())] might come to while lifted and attack you. Lift [p_them()] anyway?", "Lift [src]?", list("Lift", "Leave"))
	return choice == "Lift"

/// After a lift, an unbound spent mob may wake, throw off its carrier and turn on them.
/mob/living/proc/roll_mob_horny_ko_lash_out(mob/living/carrier)
	if(!has_status_effect(/datum/status_effect/mob_horny_knockout) || mob_horny_ko_arms_bound())
		return FALSE
	if(!prob(DEFEAT_MOB_HORNY_LIFT_LASH_CHANCE))
		return FALSE
	remove_status_effect(/datum/status_effect/mob_horny_knockout)
	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)
	carrier.visible_message(span_danger("[src] comes to on [carrier]'s shoulder and lashes out!"), span_userdanger("[src] comes to and lashes out at me!"))
	carrier.Knockdown(DEFEAT_MOB_HORNY_LASH_KNOCKDOWN)
	if(ai_controller)
		ai_controller.add_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, carrier, world.time)
		ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, carrier)
	return TRUE

/// Arms the KO Only self-rescue (§8 anti-softlock) when nothing else can save the victim - i.e. a
/// non-horny defeat with no rune that can answer (KO Only always; a KO+Rune player whose rune is
/// depleted / uncallable, checked *after* the emergency-link attempt). Horny defeats self-recover light.
/mob/living/proc/defeat_maybe_arm_struggle_up()
	var/datum/status_effect/defeat_knockout/knockout = has_status_effect(/datum/status_effect/defeat_knockout)
	if(!knockout)
		return
	if(last_defeat_snapshot?.reason == DEFEAT_REASON_HORNY)
		return
	if(defeat_has_rune_safety_net())
		return
	knockout.arm_struggle_up()

/// TRUE when a linked rune can actually pull this KO+Rune victim back right now (a spendable charge).
/// A depleted or uncallable rune returns FALSE, so the victim is treated like KO Only for self-rescue.
/mob/living/proc/defeat_has_rune_safety_net()
	if(defeat_mode != DEFEAT_MODE_KO_RUNE)
		return FALSE
	var/datum/resurrection_rune_controller/controller = get_resurrection_rune_controller_for_user(src)
	if(controller && (src in controller.resurrecting) && !controller.resurrections_disabled())
		return TRUE
	return controller?.can_offer_defeat_rune_return(src)

/// Safeguard for KO+Rune players who fall with no working rune link (never linked, or their rune was
/// destroyed): forge an emergency bond to the public city rune on the spot, so the rune-return path
/// can still reach them instead of leaving them stranded as if they were KO Only. No-op for other modes.
/mob/living/proc/defeat_ensure_emergency_rune_link()
	if(defeat_mode != DEFEAT_MODE_KO_RUNE)
		return FALSE
	if(!ishuman(src) || !mind)
		return FALSE
	// Already tied to a live rune - nothing to do.
	if(get_resurrection_rune_controller_for_user(src))
		return FALSE
	var/obj/structure/resurrection_rune/emergency_rune = get_emergency_resurrection_rune()
	if(!emergency_rune?.resrunecontroler)
		return FALSE
	if(!emergency_rune.resrunecontroler.add_user(src))
		return FALSE
	to_chat(src, span_blue("As you fall, a distant rune flickers alight and seizes your fading thread - an emergency bond, forged in the nick of time."))
	return TRUE

/mob/living/proc/defeat_rescue(mob/living/helper, rescue_source = "help")
	if(!has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(!defeat_can_be_rescued_by(helper))
		return FALSE
	return begin_defeat_recovery(/datum/defeat_recovery_profile/manual, helper, rescue_source)

/// Rescue with no helper, for environmental sources (a healing spring, a holy site...) that the
/// design allows as an exception to the "another player / non-hostile mob" source rule.
/mob/living/proc/defeat_environmental_rescue(rescue_source = "spring")
	if(!has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	return perform_defeat_rescue(null, rescue_source, /datum/defeat_recovery_profile/environmental)

/// Compatibility entrypoint for sources which already completed their own interaction. New sources
/// should name a profile explicitly; only this finalizer removes the knockout and emits recovery.
/mob/living/proc/perform_defeat_rescue(mob/living/helper, rescue_source, profile_spec = /datum/defeat_recovery_profile/environmental, datum/source)
	var/datum/defeat_recovery_profile/profile
	if(ispath(profile_spec, /datum/defeat_recovery_profile))
		profile = new profile_spec
	else if(istype(profile_spec, /datum/defeat_recovery_profile))
		profile = profile_spec
	else
		return FALSE
	var/datum/defeat_recovery_channel/channel = new(profile, src, helper, rescue_source, source)
	if(!profile.can_recover(channel))
		qdel(channel)
		return FALSE
	if(!profile.reserve_resources(channel))
		qdel(channel)
		return FALSE
	channel.resources_reserved = TRUE
	// Completed one-shot recovery has priority over an unfinished channel. Its own reservation is
	// secured first; only then is the old reservation rolled back and its channel replaced.
	if(defeat_recovery_channel)
		defeat_recovery_channel.cancel()
		QDEL_NULL(defeat_recovery_channel)
	channel.active = TRUE
	defeat_recovery_channel = channel
	var/succeeded = complete_defeat_recovery(channel)
	qdel(channel)
	return succeeded

/// Starts a profile-owned interruptible recovery. Zero-duration profiles complete immediately; the
/// manual profile runs its long medicine-scaled do_after inside the channel.
/mob/living/proc/begin_defeat_recovery(datum/defeat_recovery_profile/profile_type, mob/living/helper, rescue_source = "recovery", datum/source)
	if(!ispath(profile_type, /datum/defeat_recovery_profile))
		return FALSE
	if(defeat_recovery_channel)
		return FALSE
	var/datum/defeat_recovery_profile/profile = new profile_type
	var/datum/defeat_recovery_channel/channel = new(profile, src, helper, rescue_source, source)
	defeat_recovery_channel = channel
	var/succeeded = channel.execute()
	if(succeeded && channel.profile?.uses_passive_timer && channel.active)
		return TRUE
	qdel(channel)
	return succeeded

/mob/living/proc/cancel_defeat_recovery()
	return defeat_recovery_channel?.cancel()

/// The only wake-up finalizer. It revalidates after any channel, applies the bounded safety pass,
/// consumes the profile's reserved resources, removes KO, applies one aftermath, and signals once.
/mob/living/proc/complete_defeat_recovery(datum/defeat_recovery_channel/channel)
	if(!channel || channel != defeat_recovery_channel || !channel.is_valid())
		return FALSE
	if(!channel.resources_reserved || !channel.profile.consume_resources(channel))
		return FALSE
	channel.resources_consumed = TRUE
	channel.resources_reserved = FALSE
	var/mob/living/helper = channel.resolve_helper()
	defeat_recovery_safety_pass()
	if(!has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	remove_status_effect(/datum/status_effect/defeat_knockout)
	channel.profile.apply_aftermath(channel)
	channel.profile.apply_helper_cost(channel)
	channel.active = FALSE
	SEND_SIGNAL(src, COMSIG_LIVING_DEFEAT_RESCUED, helper, channel.rescue_source)
	return TRUE

/mob/living/proc/defeat_recovery_safety_pass()
	defeat_stabilize_live_damage(FALSE)
	defeat_clear_lethal_conditions()
	return !defeat_is_near_death()

/// Healing which only stabilizes a downed victim, such as a bandage, must never wake them.
/mob/living/proc/defeat_stabilize_from_healing(mob/living/helper, rescue_source = "healing")
	if(!has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(helper && helper != src && !defeat_can_be_rescued_by(helper))
		return FALSE
	return defeat_recovery_safety_pass()

/// Prepared sources have already completed and paid for their own tool, spell, surgery, or feeding
/// interaction. They explicitly select the safer prepared profile instead of relying on heal amount.
/mob/living/proc/defeat_try_prepared_recovery(mob/living/helper, rescue_source = "prepared care", datum/source)
	if(!has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	return perform_defeat_rescue(helper, rescue_source, /datum/defeat_recovery_profile/prepared, source)

/mob/living/proc/defeat_begin_campfire_recovery(obj/machinery/light/fueled/campfire/campfire, mob/living/helper)
	if(!campfire)
		return FALSE
	var/profile_type = helper ? /datum/defeat_recovery_profile/campfire/tended : /datum/defeat_recovery_profile/campfire
	return begin_defeat_recovery(profile_type, helper, helper ? "campfire tending" : "campfire rest", campfire)

/// A non-rune rescue (potion, hands, spring, pet, horny self-recovery, struggle-up) lifts the knockout
/// but never runs a full heal - so the two lethal conditions defeat stabilization leaves untouched,
/// heavy blood loss and brain-death organ damage, would drop the victim straight back into a near-death
/// defeat the instant they stand up (or kill them outright if they have gone defeat-ineligible). Clear
/// exactly those here - the mirror of defeat_is_near_death's non-pool checks (the health floor is already
/// handled by the damage-pool stabilization). The lingering harm is carried by the aftermath trauma, not
/// by leaving the victim one tick from collapse. The rune path skips this: it runs a full ADMIN_HEAL_ALL.
/mob/living/proc/defeat_clear_lethal_conditions()
	if(blood_volume < DEFEAT_BLOOD_VOLUME_MINIMUM && !HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE))
		blood_volume = DEFEAT_BLOOD_VOLUME_MINIMUM
	if(iscarbon(src))
		var/mob/living/carbon/carbon_src = src
		if(carbon_src.getOrganLoss(ORGAN_SLOT_BRAIN) > DEFEAT_BRAIN_DAMAGE_MAX)
			carbon_src.setOrganLoss(ORGAN_SLOT_BRAIN, DEFEAT_BRAIN_DAMAGE_MAX)
	updatehealth()

/// A horny knockout is the light case: after DEFEAT_HORNY_SELF_RECOVER_TIME the victim picks themselves
/// back up unaided (still keeping the Lewd Exhaustion aftermath). Suppressed once kidnapped - captivity
/// runs on its own KO-release clock, so a captive can't wriggle free just by waiting out this timer.
/mob/living/proc/defeat_horny_self_recover()
	if(!has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(GetComponent(/datum/component/kidnap_captivity))
		return FALSE
	if(!perform_defeat_rescue(null, "self-recovery", /datum/defeat_recovery_profile/self_recovery))
		return FALSE
	to_chat(src, span_notice("The haze of exhaustion lifts - your strength trickles back, and you pull yourself together."))
	return TRUE

/// KO Only anti-softlock: with no rune and no rescuer, a downed victim can drag themselves up on their
/// own (the "Struggle to Your Feet" action, or the auto safety-net). The price is Convalescence, on
/// top of the usual injury - so being rescued by another stays strictly better. Suppressed once kidnapped.
/mob/living/proc/defeat_ko_only_self_recover()
	if(!has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(GetComponent(/datum/component/kidnap_captivity))
		return FALSE
	if(!perform_defeat_rescue(null, "struggle", /datum/defeat_recovery_profile/self_recovery/ko_only))
		return FALSE
	to_chat(src, span_userdanger("Gritting your teeth, you drag yourself up from defeat. You need [DisplayTimeText(DEFEAT_GRIEVOUS_RECOVERY_TIME)] to regain your fighting strength, or skilled medical trauma treatment to recover sooner."))
	return TRUE

/// Empty-handed revive channel length, scaled by the reviver's medicine skill: no skill takes the
/// longest (DEFEAT_REVIVE_TIME_MAX), legendary the shortest (DEFEAT_REVIVE_TIME_MIN).
/mob/living/proc/defeat_revive_time()
	var/rank = clamp(get_skill_level(/datum/skill/misc/medicine), SKILL_RANK_NONE, SKILL_RANK_LEGENDARY)
	return round(DEFEAT_REVIVE_TIME_MAX - (rank / SKILL_RANK_LEGENDARY) * (DEFEAT_REVIVE_TIME_MAX - DEFEAT_REVIVE_TIME_MIN))

/// A loyal pet/ally beside a downed friend frees them - the rescuer is a valid non-hostile mob, so
/// this is the testable core of the pet-rescue behaviour (and a reusable primitive for other helpers).
/mob/living/proc/try_rescue_downed_ally(mob/living/fallen)
	if(!istype(fallen) || fallen == src)
		return FALSE
	if(!fallen.has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(!Adjacent(fallen))
		return FALSE
	return fallen.defeat_rescue(src, "loyal companion")

/mob/living/proc/defeat_can_be_rescued_by(mob/living/helper)
	if(!helper || helper == src)
		return FALSE
	if(stat == DEAD || helper.stat == DEAD)
		return FALSE
	if(!helper.Adjacent(src))
		return FALSE
	if(defeat_is_active_harm_from(helper))
		return FALSE
	return TRUE

/mob/living/proc/defeat_is_active_harm_from(mob/living/helper)
	if(!helper)
		return FALSE
	if(pulledby == helper && helper.grab_state >= GRAB_AGGRESSIVE)
		return TRUE
	if(helper.pulling == src && helper.grab_state >= GRAB_AGGRESSIVE)
		return TRUE
	if(defeat_recent_source_is(helper) && recent_damage_source_time && world.time - recent_damage_source_time <= DEFEAT_ACTIVE_HARM_WINDOW)
		return TRUE
	if(helper.ai_controller?.current_movement_target == src)
		return TRUE
	return FALSE

/// A helper feeding a downed victim a drink holding enough curative reagent rescues them from
/// knockout (design section 3.1: "a potion can revive you - but only another's, never your own").
/// Self-administered drinks never reach here (the feed path requires feeder != target).
/obj/item/reagent_containers/proc/defeat_try_potion_rescue(mob/living/target, mob/living/feeder, medicine_transferred)
	if(!isliving(target) || !isliving(feeder) || target == feeder)
		return FALSE
	if(!target.has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(medicine_transferred < DEFEAT_PREPARED_MEDICINE_MINIMUM)
		return FALSE
	return target.defeat_try_prepared_recovery(feeder, "potion", src)

/mob/living/proc/defeat_recent_source_is(mob/living/helper)
	if(!helper)
		return FALSE
	var/mob/living/snapshot_source = last_defeat_snapshot?.source_weakref?.resolve()
	if(snapshot_source == helper)
		return TRUE
	var/mob/living/recent_damage_source = recent_damage_source_attacker_weakref?.resolve()
	if(recent_damage_source == helper)
		return TRUE
	return FALSE

/mob/living/proc/defeat_is_immediate_rune_hazard()
	if(!defeat_is_immediate_hazard())
		return FALSE
	if(!ishuman(src))
		return FALSE

	var/mob/living/carbon/human/human_target = src
	if(!human_target.rune_linked)
		return FALSE

	var/datum/resurrection_rune_controller/rune_controller = get_resurrection_rune_controller_for_user(human_target)
	return rune_controller?.can_queue_rescue_for(human_target)

/mob/living/proc/defeat_is_immediate_hazard()
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return FALSE
	// Open space can be occupied while climbing. Being able to fall is not itself lethal;
	// fall damage and groundless impacts handle defeat through their own paths.
	// Lava/acid only counts when the mob is exposed, rather than passing safely over it.
	if(islava(current_turf))
		return !current_turf.can_traverse_safely(src)
	return FALSE

/// This fork's actual lethal conditions, so the defeat net catches every death path - not just the
/// health floor (tox/oxy/face-burn), but also bleed-out and brain death (how brute/burn really kill).
/mob/living/proc/defeat_is_near_death()
	if(health <= HEALTH_THRESHOLD_DEAD)
		return TRUE
	if(blood_volume <= BLOOD_VOLUME_SURVIVE && !HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE) && !is_bloodless())
		return TRUE
	if(iscarbon(src))
		var/mob/living/carbon/carbon_src = src
		if(carbon_src.getOrganLoss(ORGAN_SLOT_BRAIN) >= BRAIN_DAMAGE_DEATH)
			return TRUE
	return FALSE

/// Damage threshold for defeat after fragility quirks (e.g. Frail, Atrophy) are applied.
/mob/living/proc/get_effective_defeat_threshold()
	var/threshold = defeat_damage_threshold || DEFEAT_DAMAGE_THRESHOLD_DEFAULT
	if(!ishuman(src))
		return threshold
	var/mob/living/carbon/human/human_src = src
	var/mult = 1
	for(var/datum/quirk/quirk as anything in human_src.quirks)
		mult *= quirk.defeat_threshold_mult
	return max(1, round(threshold * mult))

/// Damage measured against the defeat threshold: brute, weighted burn, toxin and clone, without oxygen.
/mob/living/proc/get_defeat_damage_pool()
	return getBruteLoss() + (getFireLoss() * DEFEAT_BURN_DAMAGE_WEIGHT) + getToxLoss() + getCloneLoss()

/// Prosthetic limbs are left out: beating a wooden arm wears the device, not the wearer.
/mob/living/carbon/get_defeat_damage_pool()
	var/brute = 0
	var/burn = 0
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(bodypart.is_prosthetic())
			continue
		brute += bodypart.brute_dam
		burn += bodypart.burn_dam
	return brute + (burn * DEFEAT_BURN_DAMAGE_WEIGHT) + getToxLoss() + getCloneLoss()

/// Draws a blood tax from this mob to power the resurrection rune.
/// Stub: currently just removes the blood. TODO: deposit the drawn blood into the
/// vampire blood bank once it exists, so the rune is literally sustained by it.
/mob/living/proc/collect_blood_tax(amount)
	if(amount <= 0)
		return 0
	var/drawn = min(blood_volume, amount)
	blood_volume = max(0, blood_volume - drawn)
	return drawn

/mob/living/proc/apply_defeat_snapshot_debuffs(severity_override, escalate_existing = TRUE)
	var/datum/defeat_snapshot/snapshot = last_defeat_snapshot
	if(!snapshot)
		return FALSE
	var/debuff_type = snapshot.defeat_debuff_type()
	if(!debuff_type)
		return FALSE
	var/datum/status_effect/debuff/defeat/aftermath = apply_defeat_trauma_status(debuff_type, severity_override || snapshot.severity, escalate_existing)
	if(aftermath)
		to_chat(src, span_notice("Aftermath: [aftermath.trauma_label] ([defeat_severity_label(aftermath.severity)]). Click its status alert for effects, recovery time, and treatment."))
	return TRUE

/mob/living/proc/apply_defeat_trauma_status(datum/status_effect/debuff/defeat/debuff_type, severity = DEFEAT_SEVERITY_NORMAL, escalate_existing = TRUE)
	var/new_rank = defeat_severity_rank(severity)
	var/status_id = initial(debuff_type.id)
	for(var/datum/status_effect/debuff/defeat/existing_trauma as anything in status_effects)
		if(existing_trauma.id != status_id)
			continue
		// Prepared rescue preserves existing trauma and its remaining recovery time.
		if(!escalate_existing && defeat_severity_rank(existing_trauma.severity) >= new_rank)
			return existing_trauma
		// Already carrying this trauma untreated -> it festers and escalates one stage past the worse
		// of the two, capped at severe. Keep getting defeated without treatment and it only worsens.
		var/escalated_rank = min(max(defeat_severity_rank(existing_trauma.severity), new_rank) + (escalate_existing ? 1 : 0), defeat_severity_rank(DEFEAT_SEVERITY_SEVERE))
		severity = defeat_severity_from_rank(escalated_rank)
		qdel(existing_trauma)
		break
	return apply_status_effect(debuff_type, null, severity)

/// Hands back every point of stacked trauma Endurance loss past DEFEAT_TRAUMA_ENDURANCE_PENALTY_CAP.
/// Physical traumas each carry their own id, so without this their penalties add up without limit.
/mob/living/proc/refresh_defeat_trauma_endurance_cap()
	var/total_penalty = 0
	for(var/datum/status_effect/debuff/defeat/trauma as anything in status_effects)
		if(!istype(trauma))
			continue
		total_penalty += nulltozero(trauma.effectedstats[STAT_ENDURANCE])
	// Penalties are negative, so the carried loss is the negation of the sum.
	var/excess = max(0, -total_penalty - DEFEAT_TRAUMA_ENDURANCE_PENALTY_CAP)
	if(excess)
		set_stat_modifier(DEFEAT_TRAUMA_ENDURANCE_CAP_SOURCE, list(STAT_ENDURANCE = excess))
	else
		remove_stat_modifier(DEFEAT_TRAUMA_ENDURANCE_CAP_SOURCE)
	return excess

/mob/living/proc/defeat_treat_trauma(mob/living/helper, treatment_type = DEFEAT_TREATMENT_MEDICAL, datum/status_effect/debuff/defeat/exact_target)
	if(!helper || helper.stat == DEAD)
		return FALSE

	var/provider_type
	switch(treatment_type)
		if(DEFEAT_TREATMENT_MEDICAL)
			provider_type = /datum/defeat_trauma_provider/medical/compatibility
		if(DEFEAT_TREATMENT_SPIRITUAL)
			provider_type = /datum/defeat_trauma_provider/shrine/compatibility
		if(DEFEAT_TREATMENT_UNIVERSAL)
			provider_type = /datum/defeat_trauma_provider/universal
	if(!provider_type)
		return FALSE
	var/datum/defeat_trauma_provider/provider = new provider_type
	var/treated = provider.treat(src, helper, exact_target, interactive = FALSE, skip_delay = TRUE)
	qdel(provider)
	return treated

/// Compatibility wrapper retained for older callers. Provider selection deliberately clears one exact
/// trauma at a time; callers must invoke another treatment to address another injury.
/mob/living/proc/defeat_clear_trauma_class(mob/living/helper, treatment_type)
	return defeat_treat_trauma(helper, treatment_type)

/mob/living/proc/defeat_clear_matching_trauma(mob/living/helper, list/trauma_types, treatment_type = DEFEAT_TREATMENT_MEDICAL)
	var/provider_type = treatment_type == DEFEAT_TREATMENT_SPIRITUAL \
		? /datum/defeat_trauma_provider/shrine/compatibility \
		: /datum/defeat_trauma_provider/medical/tool
	var/datum/defeat_trauma_provider/provider = new provider_type
	provider.allowed_trauma_types = trauma_types?.Copy()
	var/treated = provider.treat(src, helper, interactive = FALSE, skip_delay = TRUE)
	qdel(provider)
	return treated

/mob/living/proc/defeat_treat_tool_physical_trauma(mob/living/helper, list/trauma_types)
	if(!helper || helper.stat == DEAD)
		return FALSE
	return defeat_clear_matching_trauma(helper, trauma_types, DEFEAT_TREATMENT_MEDICAL)

/mob/living/proc/defeat_attempt_adjacent_treatment(mob/living/helper, treatment_type = DEFEAT_TREATMENT_MEDICAL)
	if(!helper || QDELETED(helper) || helper == src || QDELETED(src))
		return FALSE
	if(stat == DEAD || helper.stat == DEAD)
		return FALSE
	var/obj/item/offering = helper.get_active_held_item()
	if(QDELETED(offering))
		return FALSE
	var/list/provider_options = list()
	var/list/provider_label_counts = list()
	if(treatment_type == DEFEAT_TREATMENT_SPIRITUAL)
		for(var/obj/structure/defeat_trauma_shrine/shrine in view(1, src))
			var/datum/defeat_trauma_provider/shrine/structure/provider = shrine.treatment_provider
			if(QDELETED(provider) || !length(provider.usable_diagnoses(src, helper, offering)))
				continue
			var/base_label = provider.provider_location_text()
			provider_label_counts[base_label] = (provider_label_counts[base_label] || 0) + 1
			var/option_label = provider_label_counts[base_label] == 1 ? base_label : "[base_label] ([provider_label_counts[base_label]])"
			provider_options[option_label] = provider
	else
		for(var/obj/machinery/defeat_medical_machine/machine in view(1, src))
			var/datum/defeat_trauma_provider/medical/machine/provider = machine.treatment_provider
			if(QDELETED(provider) || !length(provider.usable_diagnoses(src, helper, offering)))
				continue
			var/base_label = provider.provider_location_text()
			provider_label_counts[base_label] = (provider_label_counts[base_label] || 0) + 1
			var/option_label = provider_label_counts[base_label] == 1 ? base_label : "[base_label] ([provider_label_counts[base_label]])"
			provider_options[option_label] = provider
	if(!length(provider_options))
		var/provider_name = treatment_type == DEFEAT_TREATMENT_SPIRITUAL ? "shrine of solace" : "trauma treatment apparatus"
		to_chat(helper, span_warning("No adjacent [provider_name] can treat this patient with my current training and held offering."))
		return FALSE
	var/datum/defeat_trauma_provider/provider
	if(length(provider_options) == 1)
		provider = provider_options[provider_options[1]]
	else
		var/provider_choice = input(helper, "Choose a treatment provider.", "Defeat trauma treatment") as null|anything in provider_options
		if(QDELETED(src) || QDELETED(helper) || QDELETED(offering))
			return FALSE
		provider = provider_options[provider_choice]
	if(QDELETED(provider) || !length(provider.usable_diagnoses(src, helper, offering)))
		to_chat(helper, span_warning("That provider is no longer able to begin treatment."))
		return FALSE
	var/treated = provider.treat(src, helper, interactive = TRUE, reserved_resource = offering)
	if(!treated)
		to_chat(helper, span_warning("I cannot complete that trauma treatment. I must keep the required offering in my active hand."))
		return FALSE
	helper.visible_message(span_notice("[helper] treats the lingering defeat trauma in [src]."), span_notice("I treat the lingering defeat trauma in [src]."))
	return TRUE

/mob/living/proc/defeat_treatment_time(mob/living/helper, treatment_type = DEFEAT_TREATMENT_MEDICAL)
	var/skill_value = 0
	if(treatment_type == DEFEAT_TREATMENT_SPIRITUAL)
		skill_value = GET_MOB_SKILL_VALUE_OLD(helper, /datum/attribute/skill/magic/holy)
	else
		skill_value = GET_MOB_SKILL_VALUE_OLD(helper, /datum/attribute/skill/misc/medicine)
	return max(8 SECONDS, 12 SECONDS - (skill_value * 0.5 SECONDS))

/mob/living/verb/treat_defeat_trauma_medical()
	set name = "Treat Defeat Trauma"
	set category = "IC"
	set src in oview(1)

	var/mob/living/helper = usr
	defeat_attempt_adjacent_treatment(helper, DEFEAT_TREATMENT_MEDICAL)

/mob/living/verb/treat_defeat_trauma_spiritual()
	set name = "Soothe Defeat Trauma"
	set category = "IC"
	set src in oview(1)

	var/mob/living/helper = usr
	defeat_attempt_adjacent_treatment(helper, DEFEAT_TREATMENT_SPIRITUAL)

/mob/living/proc/defeat_can_do_medical_treatment()
	return get_skill_level(/datum/skill/misc/medicine) >= SKILL_RANK_APPRENTICE

/mob/living/proc/defeat_can_do_spiritual_treatment()
	return HAS_TRAIT(src, TRAIT_HOLY) || (get_skill_level(/datum/skill/magic/holy) >= SKILL_RANK_NOVICE)

/// Legacy area query. Actual station treatment checks proximity to the apparatus or shrine;
/// field remedies need neither a station nor a special area.
/mob/living/proc/defeat_treatment_zone_ok(treatment_type)
	switch(treatment_type)
		if(DEFEAT_TREATMENT_MEDICAL)
			return istype(get_area(src), /area/indoors/town/clinic_large)
		if(DEFEAT_TREATMENT_SPIRITUAL)
			return istype(get_area(src), /area/indoors/town/church)
	return TRUE

/mob/living/proc/defeat_clear_one_trauma(mob/living/helper = src, datum/status_effect/debuff/defeat/exact_target)
	return defeat_treat_trauma(helper, DEFEAT_TREATMENT_UNIVERSAL, exact_target)

/mob/living/proc/has_any_defeat_trauma()
	for(var/datum/status_effect/debuff/defeat/trauma as anything in status_effects)
		if(istype(trauma))
			return TRUE
	return FALSE

/mob/living/proc/has_any_defeat_physical_trauma()
	return has_status_effect(/datum/status_effect/debuff/defeat/physical) \
		|| has_status_effect(/datum/status_effect/debuff/defeat/physical/wound) \
		|| has_status_effect(/datum/status_effect/debuff/defeat/physical/burn) \
		|| has_status_effect(/datum/status_effect/debuff/defeat/physical/body) \
		|| has_status_effect(/datum/status_effect/debuff/defeat/physical/concussion) \
		|| has_status_effect(/datum/status_effect/debuff/defeat/physical/leg) \
		|| has_status_effect(/datum/status_effect/debuff/defeat/physical/arm)

/mob/living/proc/defeat_stabilize_from_snapshot(datum/defeat_snapshot/snapshot)
	defeat_stabilize_live_damage()
	if(iscarbon(src))
		var/mob/living/carbon/carbon_target = src
		carbon_target.defeat_stabilize_active_injuries()


/// Returns the aggregate major-damage ceiling used by bounded defeat stabilization. It is always
/// below both the user's selected defeat threshold and the ordinary lethal health boundary.
/mob/living/proc/defeat_damage_safety_cap()
	// A flat margin left victims one hit from falling again, carrying brute enough to keep shock climbing.
	var/threshold_cap = get_effective_defeat_threshold() * DEFEAT_WAKE_DAMAGE_FRACTION
	var/death_cap = maxHealth - HEALTH_THRESHOLD_DEAD - DEFEAT_DAMAGE_SAFETY_MARGIN
	return max(0, round(min(threshold_cap, death_cap)))

/// Reduce ordinary carbon injuries without deleting their datums. Keeping the injury records means
/// the victim wakes with meaningful, treatable wounds instead of a hidden full heal.
/mob/living/carbon/proc/defeat_cap_injury_damage(target_damage)
	var/current_damage = getBruteLoss() + getFireLoss()
	if(current_damage <= target_damage)
		return FALSE

	var/reduction_remaining = current_damage - target_damage
	var/reduced_anything = FALSE
	var/list/injuries_to_cap = all_injuries?.Copy()
	for(var/datum/injury/injury as anything in injuries_to_cap)
		if(!injury || QDELETED(injury) || injury.damage <= 0 || reduction_remaining <= 0)
			continue
		// Leave a small positive remainder so bounded stabilization cannot silently qdel the injury.
		var/minimum_damage = min(injury.damage, 0.1)
		var/reduction = min(reduction_remaining, max(0, injury.damage - minimum_damage))
		if(!reduction)
			continue
		injury.damage -= reduction
		injury.init_stage(injury.damage)
		injury.bleed_timer = 0
		injury.bandage_injury()
		reduction_remaining -= reduction
		reduced_anything = TRUE

	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		bodypart.update_damages()
		bodypart.update_bodypart_damage_state()
	return reduced_anything

/mob/living/proc/defeat_stabilize_live_damage(run_update = TRUE)
	// These are entry invariants, not wake-up bonuses. A defeated victim must already be safe from
	// passive bleed-out and brain death while waiting for rescue.
	if(blood_volume < DEFEAT_BLOOD_VOLUME_MINIMUM && !HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE))
		blood_volume = DEFEAT_BLOOD_VOLUME_MINIMUM
	var/major_damage_cap = defeat_damage_safety_cap()
	if(iscarbon(src))
		var/mob/living/carbon/carbon_target = src
		if(carbon_target.getOrganLoss(ORGAN_SLOT_BRAIN) > DEFEAT_BRAIN_DAMAGE_MAX)
			carbon_target.setOrganLoss(ORGAN_SLOT_BRAIN, DEFEAT_BRAIN_DAMAGE_MAX)
		carbon_target.defeat_stabilize_active_injuries(FALSE)
		// Toxin and clone loss are scalar pools; preserve a bounded amount before reducing ordinary
		// bodypart injuries to fit the aggregate ceiling.
		carbon_target.setToxLoss(min(carbon_target.getToxLoss(), major_damage_cap * DEFEAT_DAMAGE_POOL_CAP_FRACTION), FALSE, TRUE)
		carbon_target.setCloneLoss(min(carbon_target.getCloneLoss(), major_damage_cap * DEFEAT_DAMAGE_POOL_CAP_FRACTION), FALSE, TRUE)
		var/injury_damage_cap = max(0, major_damage_cap - carbon_target.getToxLoss() - carbon_target.getCloneLoss())
		carbon_target.defeat_cap_injury_damage(injury_damage_cap)
		carbon_target.setOxyLoss(min(carbon_target.getOxyLoss(), DEFEAT_OXY_DAMAGE_CAP), FALSE, TRUE)
	else
		setBruteLoss(min(getBruteLoss(), major_damage_cap * DEFEAT_DAMAGE_POOL_CAP_FRACTION), FALSE, TRUE)
		setFireLoss(min(getFireLoss(), major_damage_cap * DEFEAT_DAMAGE_POOL_CAP_FRACTION), FALSE, TRUE)
		setToxLoss(min(getToxLoss(), major_damage_cap * DEFEAT_DAMAGE_POOL_CAP_FRACTION), FALSE, TRUE)
		setCloneLoss(min(getCloneLoss(), major_damage_cap * DEFEAT_DAMAGE_POOL_CAP_FRACTION), FALSE, TRUE)
		setOxyLoss(min(getOxyLoss(), DEFEAT_OXY_DAMAGE_CAP), FALSE, TRUE)
	setPainLoss(0, FALSE, TRUE)
	setShockStage(0, FALSE, TRUE)
	if(run_update)
		updatehealth()

/mob/living/carbon/proc/defeat_stabilize_active_injuries(run_update = TRUE)
	var/changed_anything = FALSE

	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(!bodypart)
			continue
		for(var/obj/item/organ/artery/artery as anything in bodypart.getorganslotlist(ORGAN_SLOT_ARTERY))
			if(artery.damage > 0)
				artery.heal_bleeding()
				changed_anything = TRUE
		for(var/datum/wound/wound as anything in bodypart.wounds)
			if(wound?.bleed_rate)
				// Keep the wound datum and its damage, but suppress active blood loss until proper care.
				wound.bleed_rate = 0
				changed_anything = TRUE
		if(length(bodypart.embedded_objects))
			var/list/embedded_to_clear = bodypart.embedded_objects.Copy()
			for(var/obj/item/embedded_item as anything in embedded_to_clear)
				if(bodypart.remove_embedded_object(embedded_item))
					changed_anything = TRUE

	if(length(simple_embedded_objects))
		var/list/simple_embedded_to_clear = simple_embedded_objects.Copy()
		for(var/obj/item/embedded_item as anything in simple_embedded_to_clear)
			if(simple_remove_embedded_object(embedded_item))
				changed_anything = TRUE

	for(var/datum/injury/injury as anything in all_injuries)
		if(!injury || QDELETED(injury) || !injury.is_bleeding())
			continue
		injury.bleed_timer = 0
		injury.bandage_injury()
		changed_anything = TRUE

	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		bodypart.update_damages()
		bodypart.update_bodypart_damage_state()

	if(run_update)
		update_damage_overlays()
		updatehealth()
	return changed_anything

//////////////////////////////////////////////////
// KIDNAPPING LANDMARKS
// Existing wolf/orc/bandit markers remain as migration-era map content while those factions use
// profile-owned pockets. Dedicated mapped-lair content may opt into explicitly named subtypes, as the
// tentacle family does, without changing the default pocket lifecycle.
//////////////////////////////////////////////////

/// lair_tag -> list of /obj/effect/landmark/kidnap/entrance
GLOBAL_LIST_EMPTY(kidnap_entrance_markers)
/// lair_tag -> list of /obj/effect/landmark/kidnap/escape
GLOBAL_LIST_EMPTY(kidnap_escape_markers)

/obj/effect/landmark/kidnap
	name = "kidnap marker"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	/// Entrance + escape markers sharing this tag form one lair.
	var/lair_tag = "default"

/// Drop point a kidnapped victim is teleported to inside the lair.
/obj/effect/landmark/kidnap/entrance
	name = "kidnap lair entrance"
	/// Area type whose turfs count as inside this lair. Null takes the entrance's own area.
	var/lair_area_type

/obj/effect/landmark/kidnap/entrance/Initialize(mapload)
	. = ..()
	if(!lair_area_type)
		var/area/entrance_area = get_area(src)
		lair_area_type = entrance_area?.type
	LAZYADDASSOCLIST(GLOB.kidnap_entrance_markers, lair_tag, src)

/obj/effect/landmark/kidnap/entrance/Destroy()
	LAZYREMOVEASSOC(GLOB.kidnap_entrance_markers, lair_tag, src)
	return ..()

/// Escape tile inside the lair. A captive stepping onto it is flung back out into the wilds.
/obj/effect/landmark/kidnap/escape
	name = "kidnap lair escape"

/obj/effect/landmark/kidnap/escape/Initialize(mapload)
	. = ..()
	LAZYADDASSOCLIST(GLOB.kidnap_escape_markers, lair_tag, src)

/obj/effect/landmark/kidnap/escape/Destroy()
	LAZYREMOVEASSOC(GLOB.kidnap_escape_markers, lair_tag, src)
	return ..()

/obj/effect/landmark/kidnap/escape/Crossed(atom/movable/crosser, oldloc)
	. = ..()
	if(!isliving(crosser))
		return
	var/mob/living/victim = crosser
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	if(!captivity)
		return
	victim.kidnap_escape_to_wilds(captivity)

/// Surfaces the captive's rune-return option, reusing the rune's own eligibility (KO+Rune, charged,
/// still knocked out). Returns TRUE if the option was actually offered.
/mob/living/proc/kidnap_surface_rune_return()
	if(!ishuman(src))
		return FALSE
	var/mob/living/carbon/human/human_src = src
	if(!human_src.rune_linked)
		return FALSE
	var/datum/resurrection_rune_controller/controller = get_resurrection_rune_controller_for_user(human_src)
	if(!controller || !controller.can_offer_defeat_rune_return(human_src))
		return FALSE
	controller.update_linked_user_rescue_state(human_src)
	return TRUE

/// A scattering of wilderness spawn points to fling escapees toward.
/proc/get_random_kidnap_wilds_turf()
	var/list/spots = list()
	for(var/obj/effect/landmark/start/adventurerlate/late_spawn in GLOB.start_landmarks_list)
		var/turf/spot = get_turf(late_spawn)
		if(spot)
			spots += spot
	if(!length(spots))
		for(var/obj/effect/landmark/start/any_spawn in GLOB.start_landmarks_list)
			var/turf/spot = get_turf(any_spawn)
			if(spot)
				spots += spot
	return length(spots) ? pick(spots) : null

/// Toggle handed to a released captive: steel yourself and horny mobs leave you be. Granted on
/// release, torn down when captivity ends (escape / rune / surrender), so it never follows the player
/// out of the lair. Its name shows the current state.
/datum/action/innate/defeat_refuse_advances
	name = "Open to Advances"
	desc = "The lair's denizens may keep at you. Toggle to steel yourself and make them leave you be."
	button_icon_state = "shieldsparkles"

/datum/action/innate/defeat_refuse_advances/Grant(mob/grant_to)
	. = ..()
	update_state()

/datum/action/innate/defeat_refuse_advances/Activate()
	if(!isliving(owner))
		return
	if(HAS_TRAIT(owner, TRAIT_DEFEAT_REFUSE_ADVANCES))
		REMOVE_TRAIT(owner, TRAIT_DEFEAT_REFUSE_ADVANCES, KIDNAP_TRAIT)
		to_chat(owner, span_notice("You relent, lowering your guard to the lair's attentions once more."))
	else
		ADD_TRAIT(owner, TRAIT_DEFEAT_REFUSE_ADVANCES, KIDNAP_TRAIT)
		to_chat(owner, span_notice("You steel yourself and rebuff the lair - its denizens will leave you be."))
	update_state()

/// The button reads as the current state, so a captive can see whether the lair ignores them.
/datum/action/innate/defeat_refuse_advances/proc/update_state()
	if(!owner)
		return
	if(HAS_TRAIT(owner, TRAIT_DEFEAT_REFUSE_ADVANCES))
		name = "Refusing Advances"
		desc = "You have steeled yourself: the lair's denizens leave you be. Toggle to relent."
	else
		name = "Open to Advances"
		desc = "The lair's denizens may keep at you. Toggle to steel yourself and make them leave you be."
	build_all_button_icons(UPDATE_BUTTON_NAME)

/// The one captivity button. The rune's own call button stays hidden while this exists.
/datum/action/innate/defeat_captivity_choices
	name = "Captivity"
	desc = "Your ways forward: call the rune if it can answer, wake inside the lair, wait, or give this character up for good."
	button_icon_state = "shieldsparkles"

/datum/action/innate/defeat_captivity_choices/Activate()
	if(!isliving(owner))
		return
	var/mob/living/victim = owner
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	captivity?.offer_release_choice()

// --- Captor side: faction mobs dragging defeated prey to their lair ---

/// Which lair this mob hauls defeated prey to. Null = this mob cannot kidnap.
/mob/living
	var/kidnap_lair_tag
	/// Explicit pocket profile. Null keeps the lair-tag compatibility resolver for old content.
	var/kidnap_captivity_profile
	/// Admission failures are event-local and rare; a per-captor timestamp avoids any global polling.
	var/tmp/kidnap_retry_after = 0
	/// Weak reservation held while one captor performs its interruptible hauling action.
	var/tmp/datum/weakref/kidnap_reservation
	/// Successful release grants a short window in which no captor may immediately haul us away again.
	var/tmp/kidnap_protected_until = 0

/mob/living/proc/get_kidnap_reserver()
	var/mob/living/captor = kidnap_reservation?.resolve()
	if(istype(captor) && !QDELETED(captor))
		return captor
	kidnap_reservation = null
	return null

/mob/living/proc/try_reserve_kidnap(mob/living/captor)
	if(!istype(captor) || QDELETED(captor) || get_kidnap_reserver())
		return FALSE
	kidnap_reservation = WEAKREF(captor)
	return TRUE

/mob/living/proc/clear_kidnap_reservation(mob/living/captor)
	if(get_kidnap_reserver() != captor)
		return FALSE
	kidnap_reservation = null
	return TRUE

/mob/living/proc/grant_kidnap_release_grace()
	kidnap_protected_until = max(kidnap_protected_until, world.time + KIDNAP_RECAPTURE_GRACE)

/// Can this mob drag the given victim back to its lair right now?
/// Everything that makes a victim claimable EXCEPT proximity/outnumbering, so the AI can spot
/// a candidate across the room and path toward it. can_kidnap_defeated_prey adds the here-and-now gates.
/mob/living/proc/is_kidnap_candidate(mob/living/victim, allow_own_reservation = FALSE)
	if(!kidnap_lair_tag && !kidnap_captivity_profile)
		return FALSE
	if(world.time < kidnap_retry_after)
		return FALSE
	if(!istype(victim) || victim == src)
		return FALSE
	if(world.time < victim.kidnap_protected_until)
		return FALSE
	var/mob/living/reserving_captor = victim.get_kidnap_reserver()
	if(reserving_captor && (!allow_own_reservation || reserving_captor != src))
		return FALSE
	if(victim.GetComponent(/datum/component/kidnap_captivity) || victim.GetComponent(/datum/component/npc_in_distress))
		return FALSE
	return is_defeated_kidnap_prey(victim) || is_restrained_kidnap_prey(victim)

/// Kept lighthearted: only a horny defeat gets someone hauled off, and only by the pack that did it.
/mob/living/proc/is_defeated_kidnap_prey(mob/living/victim, require_pack = TRUE)
	if(!victim.has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	if(victim.last_defeat_snapshot?.reason != DEFEAT_REASON_HORNY)
		return FALSE
	return !require_pack || victim.defeat_recent_source_is_packmate_of(src)

/// Bound, prone prey this mob has played with, left unstruggling long enough, with no witness about.
/mob/living/proc/is_restrained_kidnap_prey(mob/living/victim)
	if(!victim.restrained_since || !HAS_TRAIT(victim, TRAIT_RESTRAINED))
		return FALSE
	if(victim.stat == DEAD || victim.body_position != LYING_DOWN)
		return FALSE
	if(world.time - victim.restrained_since < KIDNAP_RESTRAINED_DELAY)
		return FALSE
	if(victim.is_struggling_against_restraints())
		return FALSE
	if(!victim.had_horny_scene_with(src))
		return FALSE
	return !kidnap_has_witness(victim)

/// A captive is taken knocked out, or bound and awake. Anyone else keeps their feet.
/mob/living/proc/kidnap_can_be_taken()
	return has_status_effect(/datum/status_effect/defeat_knockout) || HAS_TRAIT(src, TRAIT_RESTRAINED)

/// TRUE while a cuff break runs, and for KIDNAP_STRUGGLE_WINDOW after any resist against bonds.
/mob/living/proc/is_struggling_against_restraints()
	if(last_restraint_struggle && world.time - last_restraint_struggle < KIDNAP_STRUGGLE_WINDOW)
		return TRUE
	if(iscarbon(src))
		var/mob/living/carbon/carbon_src = src
		if(carbon_src.handcuffed?.item_flags & BEING_REMOVED)
			return TRUE
	return FALSE

/// Remembers a scene action by this captor without holding a reference to it.
/mob/living/proc/note_horny_scene_captor(mob/living/captor)
	if(!istype(captor) || captor == src)
		return
	LAZYINITLIST(horny_scene_captors)
	horny_scene_captors[REF(captor)] = world.time

/mob/living/proc/had_horny_scene_with(mob/living/captor)
	if(!istype(captor) || !LAZYLEN(horny_scene_captors))
		return FALSE
	var/captor_key = REF(captor)
	var/last_scene = horny_scene_captors[captor_key]
	if(!last_scene)
		return FALSE
	if(world.time - last_scene > KIDNAP_SCENE_MEMORY)
		LAZYREMOVE(horny_scene_captors, captor_key)
		return FALSE
	return TRUE

/// Same real faction or a shared ally entry. Neutral is a placeholder every mob carries, not a bond.
/mob/living/proc/kidnap_is_packmate(mob/living/other)
	if(!istype(other) || other == src)
		return FALSE
	var/list/shared_factions = faction & other.faction
	shared_factions -= FACTION_NEUTRAL
	if(length(shared_factions))
		return TRUE
	if(LAZYLEN(allies) && LAZYLEN(other.allies) && length(allies & other.allies))
		return TRUE
	return FALSE

/// The mob that put us down, or one of its pack: a hunting party shares the prize.
/mob/living/proc/defeat_recent_source_is_packmate_of(mob/living/captor)
	if(defeat_recent_source_is(captor))
		return TRUE
	var/mob/living/snapshot_source = last_defeat_snapshot?.source_weakref?.resolve()
	if(istype(snapshot_source) && captor.kidnap_is_packmate(snapshot_source))
		return TRUE
	var/mob/living/recent_damage_source = recent_damage_source_attacker_weakref?.resolve()
	return istype(recent_damage_source) && captor.kidnap_is_packmate(recent_damage_source)

/// TRUE when a conscious player, or a player-owned body, outside this pack can see the prey.
/mob/living/proc/kidnap_has_witness(mob/living/victim)
	for(var/mob/living/nearby in view(KIDNAP_GUARD_VIEW, src))
		if(nearby == src || nearby == victim)
			continue
		if(nearby.stat != CONSCIOUS)
			continue
		if(!nearby.client && !nearby.mind)
			continue
		if(nearby.has_status_effect(/datum/status_effect/defeat_knockout))
			continue
		if(kidnap_is_packmate(nearby))
			continue
		return TRUE
	return FALSE

/mob/living/proc/can_kidnap_defeated_prey(mob/living/victim, allow_own_reservation = FALSE)
	if(!is_kidnap_candidate(victim, allow_own_reservation))
		return FALSE
	if(!Adjacent(victim))
		return FALSE
	// Won't risk hauling prey off with rescuers about - hold the body instead.
	if(kidnap_is_outnumbered(victim))
		return FALSE
	return TRUE

/// TRUE when conscious would-be rescuers near the captor outnumber its own faction allies.
/// Keeps a lone wolf from yoinking someone out of the middle of a teamfight.
/mob/living/proc/kidnap_is_outnumbered(mob/living/victim)
	var/allies = 1 // the captor itself
	var/rescuers = 0
	for(var/mob/living/nearby in view(KIDNAP_GUARD_VIEW, src))
		if(nearby == src || nearby == victim)
			continue
		if(nearby.stat != CONSCIOUS)
			continue
		if(nearby.has_status_effect(/datum/status_effect/defeat_knockout))
			continue
		if(faction_check_atom(nearby))
			allies++
			continue
		// Only real people (players / humanoids) count as rescuers, not wandering critters.
		if(nearby.ckey || iscarbon(nearby))
			rescuers++
	return rescuers > allies

/// Revalidated by do_after throughout the hauling window. Recent damage means a companion landed a
/// meaningful interruption; adjacency, KO, reservation, and outnumbering are checked continuously too.
/mob/living/proc/can_continue_kidnap(mob/living/victim, started_at)
	if(recent_damage_source_time >= started_at)
		return FALSE
	return can_kidnap_defeated_prey(victim, allow_own_reservation = TRUE)

/// Destination hook for captors with a physical, mapped lair. The default remains the existing
/// profile-owned pocket; content which overrides this must preserve the captivity consent gates.
/mob/living/proc/complete_kidnap_defeated_prey(mob/living/victim)
	var/profile_spec = kidnap_captivity_profile || get_defeat_captivity_profile_for_lair(kidnap_lair_tag)
	return victim.kidnap_to_pocket(profile_spec, src, faction, kidnap_lair_tag)

/// Hauls a defeated victim off to this mob's lair after a short, visible, interruptible struggle.
/mob/living/proc/try_kidnap_defeated_prey(mob/living/victim)
	if(!can_kidnap_defeated_prey(victim))
		return FALSE
	if(!victim.try_reserve_kidnap(src))
		return FALSE

	var/started_at = world.time
	ai_controller?.PauseAi(KIDNAP_HAUL_TIME)
	visible_message(
		span_userdanger("[src] grabs [victim] and starts hauling [victim.p_them()] away!"),
		span_danger("I seize [victim] and start hauling [victim.p_them()] away..."),
	)
	to_chat(victim, span_userdanger("[src] has seized me and is trying to drag me away! My companions have only moments to intervene!"))
	victim.emote("scream")

	// can_continue_kidnap is the authoritative interruption test (adjacency, KO, reservation, being
	// outnumbered, damage to the captor) and is revalidated every tick. Left at default flags, do_after
	// piles on much stricter cancels that have nothing to do with a rescue: a third party nudging the
	// body one tile, the captor turning to face something, its held item changing, or the captor merely
	// being busy with another interaction - all common while other mobs paw at the same victim, and all
	// of which read to players as a phantom "the attempt is broken!". Adjacency still covers a victim
	// actually being dragged out of reach.
	var/haul_completed = do_after(
		src,
		KIDNAP_HAUL_TIME,
		victim,
		timed_action_flags = IGNORE_TARGET_LOC_CHANGE | IGNORE_USER_DIR_CHANGE | IGNORE_HELD_ITEM | IGNORE_USER_DOING,
		extra_checks = CALLBACK(src, PROC_REF(can_continue_kidnap), victim, started_at),
		interaction_key = "defeat_kidnap",
	)
	if(QDELETED(victim))
		return FALSE
	if(!haul_completed || !can_continue_kidnap(victim, started_at))
		victim.clear_kidnap_reservation(src)
		visible_message(
			span_warning("[src]'s attempt to haul [victim] away is interrupted!"),
			span_warning("My attempt to haul [victim] away is interrupted!"),
		)
		to_chat(victim, span_notice("The attempt to drag me away is broken!"))
		return FALSE

	if(!complete_kidnap_defeated_prey(victim))
		victim.clear_kidnap_reservation(src)
		kidnap_retry_after = world.time + KIDNAP_RETRY_COOLDOWN
		return FALSE
	victim.clear_kidnap_reservation(src)
	kidnap_retry_after = 0
	// Admission is committed before announcing it, so a full/broken profile cannot produce a fake
	// seizure every planning cycle. Nearby allies hear this from the captor's original location.
	visible_message(
		span_userdanger("[victim] screams as [src] seizes [victim.p_them()] and hauls [victim.p_them()] into a lair!"),
		span_danger("I haul [victim] into the lair..."),
	)
	return TRUE

// --- AI wiring ---------------------------------------------------------------------------------
// Simple hostile mobs claim prey straight from AttackingTarget (hostile.dm). Carbon NPCs (goblins,
// bandits) attack through the human_npc committed-swing flow instead, which never calls that hook -
// so they need this planning subtree to notice a horny-defeated victim and go haul it off.

/datum/ai_planning_subtree/kidnap_defeated_prey

/datum/ai_planning_subtree/kidnap_defeated_prey/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || (!living_pawn.kidnap_lair_tag && !living_pawn.kidnap_captivity_profile))
		return
	var/mob/living/target = controller.blackboard[BB_KIDNAP_TARGET]
	if(target && (QDELETED(target) || !living_pawn.is_kidnap_candidate(target)))
		controller.clear_blackboard_key(BB_KIDNAP_TARGET)
		target = null
	if(!target)
		for(var/mob/living/candidate in view(KIDNAP_GUARD_VIEW, living_pawn))
			if(!living_pawn.is_kidnap_candidate(candidate))
				continue
			target = candidate
			controller.set_blackboard_key(BB_KIDNAP_TARGET, candidate)
			break
	if(!target)
		return
	controller.queue_behavior(/datum/ai_behavior/kidnap_defeated_prey, BB_KIDNAP_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/kidnap_defeated_prey
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1

// A movement behaviour with no target is cancelled before its first perform; set it here.
/datum/ai_behavior/kidnap_defeated_prey/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/victim = controller.blackboard[target_key]
	if(QDELETED(victim))
		return FALSE
	set_movement_target(controller, victim)
	return TRUE

/datum/ai_behavior/kidnap_defeated_prey/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/mob/living/victim = controller.blackboard[target_key]
	if(!isliving(pawn) || !isturf(pawn.loc) || QDELETED(victim) || !pawn.is_kidnap_candidate(victim))
		finish_action(controller, FALSE, target_key)
		return
	set_movement_target(controller, victim)
	if(pawn.Adjacent(victim))
		var/succeeded = pawn.try_kidnap_defeated_prey(victim)
		finish_action(controller, succeeded, target_key)

/datum/ai_behavior/kidnap_defeated_prey/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

// Faction mobs that drag defeated prey to their lairs. Mappers place entrance + escape markers
// tagged with the matching lair_tag ("greenskin_lair" for orcs/goblins, "wolfden_lair" for canines).
/mob/living/simple_animal/hostile/orc
	kidnap_lair_tag = "greenskin_lair"
	kidnap_captivity_profile = /datum/defeat_captivity_profile/shared/greenskin

/mob/living/simple_animal/hostile/retaliate/wolf
	kidnap_lair_tag = "wolfden_lair"

/mob/living/carbon/human/species/human/northern/highwayman
	kidnap_lair_tag = "bandit_lair"

/mob/living/carbon/human/species/human/northern/thief
	kidnap_lair_tag = "bandit_lair"

/mob/living/carbon/human/species/human/northern/searaider
	kidnap_lair_tag = "bandit_lair"

// Friendly summoned/tamed wolves never kidnap.
/mob/living/simple_animal/hostile/retaliate/wolf/companion
	kidnap_lair_tag = null

/mob/living/simple_animal/hostile/retaliate/wolf/familiar
	kidnap_lair_tag = null

/mob/living/simple_animal/hostile/werewolf
	kidnap_lair_tag = "wolfden_lair"

//////////////////////////////////////////////////
// NPC-IN-DISTRESS (rescue NPCs)
// Wretched captives players can free for a coin reward. Two origins, one behavior:
//  - Ambient: mapper-placed / spawned random-race captives that persist until rescued.
//  - Player-turned: a surrendered captive, keeps their look + worn clothes, decays if left.
//////////////////////////////////////////////////

GLOBAL_LIST_INIT(npc_distress_pleas, list(
	"Save me, please!",
	"Someone - anyone - help me!",
	"Please, don't leave me here!",
	"Get me out of this place, I beg you!",
	"Mercy! Set me free!",
	"Help... I can't last much longer...",
))

GLOBAL_LIST_INIT(npc_distress_thanks, list(
	"Bless you, friend! Bless you!",
	"Thank you - thank you, a thousand times!",
	"I am saved... I cannot thank you enough!",
	"May the gods watch over you always!",
	"You came... you actually came for me!",
))

/datum/component/npc_in_distress
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Player-turned captives decay if not rescued; ambient ones persist.
	var/decays = FALSE
	var/rescued = FALSE
	var/next_plea = 0
	var/decay_timer
	/// The one lair denizen running a scene with this captive. The set piece never crowds them.
	var/datum/weakref/scene_partner_ref

/// A denizen of the captive's own pack may take up with them, one at a time.
/datum/component/npc_in_distress/proc/can_be_claimed_by(mob/living/suitor)
	var/mob/living/poor_soul = parent
	if(rescued || !istype(suitor) || !poor_soul || poor_soul.stat == DEAD)
		return FALSE
	if(!suitor.kidnap_is_packmate(poor_soul))
		return FALSE
	var/mob/living/partner = scene_partner_ref?.resolve()
	return !partner || QDELETED(partner) || partner == suitor

/datum/component/npc_in_distress/proc/claim_scene(mob/living/suitor)
	if(!can_be_claimed_by(suitor))
		return FALSE
	scene_partner_ref = WEAKREF(suitor)
	return TRUE

/datum/component/npc_in_distress/proc/release_scene(mob/living/suitor)
	if(scene_partner_ref?.resolve() == suitor)
		scene_partner_ref = null

/datum/component/npc_in_distress/Initialize(decays = FALSE)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	src.decays = decays

/datum/component/npc_in_distress/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	START_PROCESSING(SSobj, src)
	if(decays)
		decay_timer = addtimer(CALLBACK(src, PROC_REF(decay_away)), KIDNAP_NPC_DECAY, TIMER_STOPPABLE)

/datum/component/npc_in_distress/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	STOP_PROCESSING(SSobj, src)
	deltimer(decay_timer)

/datum/component/npc_in_distress/process(seconds_per_tick)
	var/mob/living/poor_soul = parent
	if(!poor_soul || rescued)
		return
	if(world.time < next_plea)
		return
	if(!npc_distress_player_nearby(poor_soul))
		return
	next_plea = world.time + rand(8 SECONDS, 16 SECONDS)
	poor_soul.say(pick(GLOB.npc_distress_pleas))

/datum/component/npc_in_distress/proc/npc_distress_player_nearby(mob/living/poor_soul)
	for(var/mob/nearby in view(NPC_DISTRESS_PLEA_VIEW, poor_soul))
		if(nearby == poor_soul)
			continue
		if(nearby.client)
			return TRUE
	return FALSE

/datum/component/npc_in_distress/proc/on_attack_hand(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER
	if(rescued || !isliving(user) || user == parent)
		return
	INVOKE_ASYNC(src, PROC_REF(try_rescue), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/npc_in_distress/proc/try_rescue(mob/living/rescuer)
	var/mob/living/poor_soul = parent
	if(!poor_soul || rescued)
		return
	to_chat(rescuer, span_notice("I begin working [poor_soul] free of their bonds..."))
	if(!do_after(rescuer, NPC_DISTRESS_RESCUE_TIME, target = poor_soul))
		return
	if(rescued || QDELETED(poor_soul))
		return
	rescued = TRUE
	complete_rescue(rescuer)

/datum/component/npc_in_distress/proc/complete_rescue(mob/living/rescuer)
	var/mob/living/poor_soul = parent
	if(!poor_soul)
		return
	poor_soul.say(pick(GLOB.npc_distress_thanks))
	var/turf/spot = get_turf(poor_soul)
	if(spot)
		var/reward = rand(NPC_DISTRESS_REWARD_MIN, NPC_DISTRESS_REWARD_MAX)
		for(var/i in 1 to reward)
			new /obj/item/coin/silver(spot)
	poor_soul.visible_message(span_blue("The power of the Rune takes [poor_soul] away for treatment, leaving only a scattering of coin behind."))
	qdel(poor_soul)

/datum/component/npc_in_distress/proc/decay_away()
	var/mob/living/poor_soul = parent
	if(!poor_soul || rescued)
		return
	poor_soul.visible_message(span_warning("[poor_soul] is hauled away into the dark, lost for good."))
	qdel(poor_soul)

/// Ambient captive: a random downtrodden race, no gear, crying for rescue.
/mob/living/carbon/human/npc_in_distress
	/// Distress component this mob binds on spawn (subtypes may pay extra bounties)
	var/distress_component_type = /datum/component/npc_in_distress

/mob/living/carbon/human/npc_in_distress/Initialize(mapload)
	. = ..()
	var/species_type = pick(
		/datum/species/human,
		/datum/species/elf/wood,
		/datum/species/elf/dark,
		/datum/species/human/halfelf,
		/datum/species/human/halfdrow,
	)
	set_species(species_type)
	// Randomize the look (gender, age, skin, eyes...) but keep the rolled species and our own naming.
	randomize_human_appearance(ALL & ~RANDOMIZE_SPECIES & ~RANDOMIZE_NAME)
	var/datum/species/our_species = dna?.species
	var/new_name = our_species ? our_species.random_name(gender) : random_unique_name(gender)
	fully_replace_character_name(real_name, new_name)
	AddComponent(distress_component_type, FALSE)

/// Mapper landmark that spawns one ambient captive where placed.
/obj/effect/landmark/distress_spawner
	name = "distress captive spawner"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	/// Faction given to the spawned captive so the lair's own monsters won't maul their prize.
	var/list/captive_faction

/obj/effect/landmark/distress_spawner/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/distress_spawner/LateInitialize()
	. = ..()
	var/turf/spot = get_turf(src)
	if(spot)
		var/mob/living/carbon/human/npc_in_distress/poor_soul = new(spot)
		if(captive_faction)
			poor_soul.set_faction(captive_faction.Copy())
	return INITIALIZE_HINT_QDEL

// Faction-matched spawners so captives share their captors' faction (place in the matching lair).
/obj/effect/landmark/distress_spawner/greenskin
	name = "greenskin distress captive spawner"
	captive_faction = list(FACTION_ORCS)

/obj/effect/landmark/distress_spawner/wolfden
	name = "wolfden distress captive spawner"
	captive_faction = list(FACTION_WOLVES)

/// Releases everything a given-up character still holds: job slot, rune bonds, roundstart list, name.
/mob/living/carbon/proc/prepare_abandon_character()
	var/datum/job/assigned_job = SSjob.GetJob(job)
	if(assigned_job?.parent_job)
		assigned_job.parent_job.adjust_current_positions(-1)
		assigned_job.adjust_current_positions(-1)
	else
		assigned_job?.adjust_current_positions(-1)

	for(var/obj/structure/resurrection_rune/rune as anything in GLOB.global_resurrunes)
		var/datum/resurrection_rune_controller/rune_controller = rune.resrunecontroler
		if(rune_controller && (src in rune_controller.linked_users))
			rune_controller.remove_user(src)
	// A mind can stay linked without its body; sever those too, or the rune remakes the body later.
	if(mind)
		unlink_mind_from_other_resurrection_runes(mind, null)
		mind.defeat_character_abandoned = TRUE
	GLOB.rune_roundstart_mobs -= src
	release_reserved_name()

/mob/living/carbon/human/proc/become_npc_in_distress(decays = TRUE, list/captor_faction = null)
	npc_in_distress_drop_carried()
	if(captor_faction)
		set_faction(captor_faction) // share the captors' faction so they won't attack the new captive
	visible_message(span_warning("[src]'s eyes go vacant - just another wretch lost to the dark."))
	var/mob/dead/observer/ghost = ghostize(FALSE)
	AddComponent(/datum/component/npc_in_distress, decays)
	return ghost

/// Drops held items and carried containers (back/belt/pouch); leaves worn clothing on.
/mob/living/carbon/human/proc/npc_in_distress_drop_carried()
	for(var/obj/item/held in held_items)
		if(held)
			dropItemToGround(held)
	for(var/obj/item/carried in list(backr, backl, belt, beltl, beltr, wear_neck))
		if(carried)
			dropItemToGround(carried)

/datum/defeat_snapshot
	var/reason
	var/severity = DEFEAT_SEVERITY_NORMAL
	var/brute_loss = 0
	var/burn_loss = 0
	var/tox_loss = 0
	var/oxy_loss = 0
	var/clone_loss = 0
	var/pain_loss = 0
	var/traumatic_shock = 0
	var/shock_stage = 0
	var/worst_body_zone
	var/worst_bodypart_name
	var/worst_injury_type
	var/worst_injury_stage = 0
	var/worst_injury_damage = 0
	var/source_name
	var/source_type
	var/source_ckey
	var/datum/weakref/source_weakref
	var/created_at = 0
	var/lethal_cause
	var/blood_loss_defeat = FALSE
	var/brain_damage_defeat = FALSE
	var/oxygen_loss_defeat = FALSE

/datum/defeat_snapshot/proc/capture_from(mob/living/carbon/target, new_reason, new_severity = DEFEAT_SEVERITY_NORMAL, mob/living/source)
	if(!target)
		return FALSE

	reason = new_reason
	severity = new_severity
	brute_loss = target.getBruteLoss()
	burn_loss = target.getFireLoss()
	tox_loss = target.getToxLoss()
	oxy_loss = target.getOxyLoss()
	clone_loss = target.getCloneLoss()
	pain_loss = target.getPainLoss()
	traumatic_shock = target.getShock()
	shock_stage = target.shock_stage
	created_at = world.time
	blood_loss_defeat = target.blood_volume <= BLOOD_VOLUME_SURVIVE && !HAS_TRAIT(target, TRAIT_BLOODLOSS_IMMUNE)
	brain_damage_defeat = target.getOrganLoss(ORGAN_SLOT_BRAIN) >= BRAIN_DAMAGE_DEATH
	oxygen_loss_defeat = oxy_loss >= DEFEAT_OXY_THRESHOLD
	if(reason == DEFEAT_REASON_DEATH)
		if(blood_loss_defeat)
			lethal_cause = "critical blood loss"
		else if(brain_damage_defeat)
			lethal_cause = "critical brain damage"
		else if(oxygen_loss_defeat)
			lethal_cause = "critical oxygen loss"
		else
			lethal_cause = "lethal accumulated damage"

	if(source)
		source_name = source.name
		source_type = source.type
		source_ckey = source.ckey
		source_weakref = WEAKREF(source)
	else
		source_name = target.recent_damage_source_name
		source_type = target.recent_damage_source_mob_type
		source_weakref = target.recent_damage_source_attacker_weakref

	capture_worst_injury(target)
	return TRUE

/datum/defeat_snapshot/proc/defeat_debuff_type()
	// Lethal physiology takes precedence over an unrelated older limb injury.
	if(reason == DEFEAT_REASON_DEATH)
		if(blood_loss_defeat)
			return /datum/status_effect/debuff/defeat/blood_loss
		if(brain_damage_defeat)
			return /datum/status_effect/debuff/defeat/physical/concussion
		if(oxygen_loss_defeat)
			return /datum/status_effect/debuff/defeat/breathless
	if(reason == DEFEAT_REASON_DAMAGE || reason == DEFEAT_REASON_DEATH)
		var/physical_damage = brute_loss + burn_loss * DEFEAT_BURN_DAMAGE_WEIGHT
		if(tox_loss > 0 && tox_loss > physical_damage && tox_loss >= clone_loss)
			return /datum/status_effect/debuff/defeat/poisoned
		if(clone_loss > 0 && clone_loss > physical_damage && clone_loss > tox_loss)
			return /datum/status_effect/debuff/defeat/body_strain
	switch(reason)
		if(DEFEAT_REASON_DAMAGE, DEFEAT_REASON_DEATH, DEFEAT_REASON_HAZARD)
			// Burns always read as burn trauma regardless of where they land.
			if(worst_injury_type == WOUND_BURN)
				return /datum/status_effect/debuff/defeat/physical/burn
			// Limb injuries are zone-driven: sprained leg, dislocated arm.
			switch(worst_body_zone)
				if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
					return /datum/status_effect/debuff/defeat/physical/arm
				if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
					return /datum/status_effect/debuff/defeat/physical/leg
			switch(worst_injury_type)
				if(WOUND_BLUNT, WOUND_INTERNAL_BRUISE)
					if(worst_body_zone == BODY_ZONE_HEAD)
						return /datum/status_effect/debuff/defeat/physical/concussion
					return /datum/status_effect/debuff/defeat/physical/body
				if(WOUND_SLASH, WOUND_PIERCE, WOUND_BITE, WOUND_LASH, WOUND_SCRATCH, WOUND_ARTERY, WOUND_TENDON, WOUND_NERVE)
					return /datum/status_effect/debuff/defeat/physical/wound
			return /datum/status_effect/debuff/defeat/physical
		if(DEFEAT_REASON_PAIN)
			return /datum/status_effect/debuff/defeat/pain
		if(DEFEAT_REASON_HORNY)
			return /datum/status_effect/debuff/defeat/horny
	return /datum/status_effect/debuff/defeat/physical

/datum/defeat_snapshot/proc/cause_description()
	switch(reason)
		if(DEFEAT_REASON_DAMAGE)
			return "accumulated injury damage"
		if(DEFEAT_REASON_PAIN)
			return shock_stage >= DEFEAT_SHOCK_HARD_STAGE ? "extreme pain shock" : "sustained pain shock"
		if(DEFEAT_REASON_DEATH)
			return lethal_cause || "a lethal condition"
		if(DEFEAT_REASON_HAZARD)
			return "deadly terrain"
		if(DEFEAT_REASON_HORNY)
			return "intimate exhaustion"
	return "defeat"

/proc/defeat_severity_rank(severity)
	switch(severity)
		if(DEFEAT_SEVERITY_LIGHT)
			return 1
		if(DEFEAT_SEVERITY_SEVERE)
			return 3
	return 2

/proc/defeat_severity_from_rank(rank)
	switch(rank)
		if(1)
			return DEFEAT_SEVERITY_LIGHT
		if(3)
			return DEFEAT_SEVERITY_SEVERE
	return DEFEAT_SEVERITY_NORMAL

/// Player-facing severity word for alerts/UI.
/proc/defeat_severity_label(severity)
	switch(severity)
		if(DEFEAT_SEVERITY_LIGHT)
			return "Light"
		if(DEFEAT_SEVERITY_SEVERE)
			return "Severe"
	return "Moderate"

/datum/defeat_snapshot/proc/capture_worst_injury(mob/living/carbon/target)
	worst_body_zone = null
	worst_bodypart_name = null
	worst_injury_type = null
	worst_injury_stage = 0
	worst_injury_damage = 0
	for(var/datum/injury/injury as anything in target.all_injuries)
		if(!injury || injury.damage < worst_injury_damage)
			continue
		worst_injury_damage = injury.damage
		worst_injury_stage = injury.current_stage
		worst_injury_type = injury.damage_type
		var/obj/item/bodypart/bodypart = injury.parent_bodypart
		if(bodypart)
			worst_body_zone = bodypart.body_zone
			worst_bodypart_name = bodypart.name

/obj/effect/landmark/kidnap/escape/bandit
	lair_tag = "bandit_lair"

/obj/effect/landmark/kidnap/entrance/bandit
	lair_tag = "bandit_lair"

/obj/effect/landmark/kidnap/escape/greenskin
	lair_tag = "greenskin_lair"

/obj/effect/landmark/kidnap/entrance/greenskin
	lair_tag = "greenskin_lair"

/obj/effect/landmark/kidnap/escape/wolfden
	lair_tag = "wolfden_lair"

/obj/effect/landmark/kidnap/entrance/wolfden
	lair_tag = "wolfden_lair"

/obj/effect/landmark/kidnap/escape/bandit
	lair_tag = "bandit_lair"

/obj/effect/landmark/kidnap/entrance/bandit
	lair_tag = "bandit_lair"
