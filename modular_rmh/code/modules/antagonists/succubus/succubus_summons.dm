// Tier-3 Whispering Imp: a bounded, volunteer-controlled infernal companion.

// --- Ownership ------------------------------------------------------------------------------------

/datum/antagonist/succubus
	/// Minds of living, linked whispering imps. The imp antag datum releases its own entry.
	var/tmp/list/datum/mind/summoned_imp_minds = list()
	/// Prevents repeated casts while the ghost poll is sleeping.
	var/tmp/succubus_imp_offer_pending = FALSE
	/// Living NPC hounds sustained by this succubus.
	var/tmp/list/mob/living/simple_animal/hostile/retaliate/wolf/companion/lustbound/summoned_lusthounds = list()

/datum/antagonist/succubus/proc/count_summoned_imps()
	for(var/datum/mind/imp_mind as anything in summoned_imp_minds.Copy())
		var/datum/antagonist/succubus_imp/imp_datum = imp_mind?.has_antag_datum(/datum/antagonist/succubus_imp)
		if(!imp_datum || imp_datum.mistress_mind != owner)
			summoned_imp_minds -= imp_mind
	return length(summoned_imp_minds)

/datum/antagonist/succubus/proc/count_summoned_lusthounds()
	for(var/mob/living/simple_animal/hostile/retaliate/wolf/companion/lustbound/hound as anything in summoned_lusthounds.Copy())
		if(QDELETED(hound) || hound.mistress_mind_ref?.resolve() != owner)
			summoned_lusthounds -= hound
	return length(summoned_lusthounds)

// --- Secondary antagonist role -------------------------------------------------------------------

/datum/antagonist/succubus_imp
	name = "Whispering Imp"
	roundend_category = "Other Villains"
	antagpanel_category = "Villain"
	show_in_antagpanel = TRUE
	increase_votepwr = FALSE
	replace_banned = FALSE
	// PLACEHOLDER HUD: vampire icons until succubus art exists
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "vamp"
	var/datum/mind/mistress_mind

/datum/antagonist/succubus_imp/on_gain()
	var/datum/objective/serve = new
	serve.owner = owner
	serve.explanation_text = "Collaborate with my summoner, protect their secrets, and further their schemes until my borrowed form expires. I retain my own agency; preferences and server rules still bind every request."
	objectives += serve
	return ..()

/datum/antagonist/succubus_imp/greet()
	to_chat(owner.current, span_userdanger("A whisper from the lower planes binds me to a fragile infernal form for thirty minutes."))
	if(mistress_mind?.current)
		to_chat(owner.current, span_love("My summoner is [mistress_mind.current.real_name]. I should scout, carry messages, protect their secrets, and aid their schemes."))
	to_chat(owner.current, span_boldnotice("This is a collaborative role, not mind control. My agency, ERP preferences, server rules, and right to refuse remain intact."))
	owner.announce_objectives()
	return ..()

/datum/antagonist/succubus_imp/examine_friendorfoe(datum/antagonist/examined_datum, mob/examiner, mob/examined)
	if(examiner.mind == mistress_mind)
		return span_boldnotice("My whispering imp, bound to me for a little while.")

/datum/antagonist/succubus_imp/Destroy()
	if(mistress_mind)
		var/datum/antagonist/succubus/mistress_datum = mistress_mind.has_antag_datum(/datum/antagonist/succubus)
		mistress_datum?.summoned_imp_minds -= owner
	mistress_mind = null
	return ..()

/datum/antagonist/succubus/examine_friendorfoe(datum/antagonist/examined_datum, mob/examiner, mob/examined)
	var/datum/antagonist/succubus_imp/imp_datum = examined_datum
	if(istype(imp_datum) && imp_datum.mistress_mind == examiner.mind)
		return span_boldnotice("My summoner, whose whisper called me into this world.")

// --- Mob and AI -----------------------------------------------------------------------------------

/datum/ai_controller/imp/succubus/set_ai_status(new_ai_status)
	// This body is a player role, never an NPC fallback. Keep every wake-up path inert.
	return ..(AI_STATUS_OFF)

/datum/ai_controller/imp/succubus/on_sentience_lost()
	//SIGNAL_HANDLER
	UnregisterSignal(pawn, COMSIG_MOB_LOGOUT)
	set_ai_status(AI_STATUS_OFF)
	RegisterSignal(pawn, COMSIG_MOB_LOGIN, PROC_REF(on_sentience_gained))

/mob/living/simple_animal/hostile/retaliate/infernal/imp/succubus
	name = "whispering imp"
	health = 60
	maxHealth = 60
	melee_damage_lower = 10
	melee_damage_upper = 12
	ai_controller = /datum/ai_controller/imp/succubus
	del_on_deaggro = 0

/mob/living/simple_animal/hostile/retaliate/infernal/imp/succubus/Initialize()
	. = ..()
	ai_controller?.set_ai_status(AI_STATUS_OFF)
	addtimer(CALLBACK(src, PROC_REF(warn_banishment)), SUCCUBUS_SUMMON_IMP_DURATION - SUCCUBUS_SUMMON_IMP_WARNING_TIME, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(banish)), SUCCUBUS_SUMMON_IMP_DURATION, TIMER_DELETE_ME)

/mob/living/simple_animal/hostile/retaliate/infernal/imp/succubus/proc/warn_banishment()
	to_chat(src, span_warning("My borrowed form frays. In one minute, the lower planes will reclaim me."))

/mob/living/simple_animal/hostile/retaliate/infernal/imp/succubus/proc/banish()
	visible_message(
		span_warning("[src] collapses into a curl of sulphurous smoke!"),
		span_userdanger("The lower planes reclaim my borrowed form!"),
	)
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/infernal/imp/succubus/Destroy()
	mind?.remove_antag_datum(/datum/antagonist/succubus_imp)
	return ..()

// --- Lustbound hound -----------------------------------------------------------------------------

/datum/pet_command/pet_breed_other
	command_name = "Ravage"
	command_desc = "Command the hound to sexually pursue a preference-compatible target."
	radial_icon_state = "breed"
	requires_pointing = TRUE
	speech_commands = list("ravage", "mount", "consummate")
	command_feedback = "snarls eagerly"
	pointed_reaction = "with hungry intent"

/datum/pet_command/pet_breed_other/set_command_active(mob/living/parent, mob/living/commander, radial_command = FALSE)
	. = ..()
	parent.ai_controller?.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
	parent.ai_controller?.clear_blackboard_key(BB_HORNY_DIRECTED_TARGET)

// Friends point all the time; only a point made while this order is active picks a target.
/datum/pet_command/pet_breed_other/on_target_set(mob/living/friend, atom/potential_target)
	var/mob/living/parent = weak_parent?.resolve()
	if(parent?.ai_controller?.blackboard[BB_ACTIVE_PET_COMMAND] != src)
		return
	return ..()

/datum/pet_command/pet_breed_other/set_command_target(mob/living/parent, atom/target)
	if(!isliving(target) || target == parent)
		parent.visible_message(span_notice("[parent] turns away from [target]."))
		return FALSE

	var/datum/ai_controller/controller = parent.ai_controller
	var/datum/targetting_datum/targetting_datum = controller?.blackboard[BB_TARGETTING_DATUM]
	if(!targetting_datum)
		parent.visible_message(span_notice("[parent] sniffs at [target], then refuses the order."))
		return FALSE
	// Mark the order before checking, so an ally passes can_horny; their prefs still decide.
	var/atom/previous_target = controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET]
	controller.set_blackboard_key(BB_HORNY_DIRECTED_TARGET, target)
	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, target)
	if(!targetting_datum.can_horny(parent, target))
		controller.clear_blackboard_key(BB_HORNY_DIRECTED_TARGET)
		if(QDELETED(previous_target))
			controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET)
		else
			controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_HORNY_TARGET, previous_target)
		parent.visible_message(span_notice("[parent] sniffs at [target], then refuses the order."))
		return FALSE

	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	controller.clear_blackboard_key(BB_HORNY_PORTAL_LIGHT)
	controller.clear_blackboard_key(BB_HORNY_SEEK_COOLDOWN)
	controller.recalculate_idle()
	return TRUE

/datum/pet_command/pet_breed_other/execute_action(datum/ai_controller/controller)
	if(!controller.blackboard[BB_BASIC_MOB_CURRENT_HORNY_TARGET])
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/pet_breed_other/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "directs [living_pet]'s lust toward [target]!"

/datum/ai_controller/summon/succubus_lusthound
	horny_pref_family_flag = HORNY_MOB_TYPE_BEASTS
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/horny,
		/datum/ai_planning_subtree/simple_find_priority,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/simple_animal/hostile/retaliate/wolf/companion/lustbound
	name = "lustbound hound"
	desc = "A wolf-shaped infernal appetite, bound to obey its summoner."
	color = "#B84D9B"
	ai_controller = /datum/ai_controller/summon/succubus_lusthound
	var/tmp/datum/weakref/mistress_mind_ref

/mob/living/simple_animal/hostile/retaliate/wolf/companion/lustbound/Initialize()
	. = ..()
	var/static/list/lusthound_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/good_boy,
		/datum/pet_command/follow,
		/datum/pet_command/attack,
		/datum/pet_command/fetch,
		/datum/pet_command/protect_owner,
		/datum/pet_command/rescue_owner,
		/datum/pet_command/aggressive,
		/datum/pet_command/calm,
		/datum/pet_command/pet_breed_other,
	)
	var/datum/component/obeys_commands/default_commands = GetComponent(/datum/component/obeys_commands)
	qdel(default_commands)
	AddComponent(/datum/component/obeys_commands, lusthound_commands)
	gender = MALE
	QDEL_IN(src, SUCCUBUS_SUMMON_LUSTHOUND_DURATION)

/mob/living/simple_animal/hostile/retaliate/wolf/companion/lustbound/Destroy()
	var/datum/mind/mistress_mind = mistress_mind_ref?.resolve()
	var/datum/antagonist/succubus/mistress_datum = mistress_mind?.has_antag_datum(/datum/antagonist/succubus)
	mistress_datum?.summoned_lusthounds -= src
	mistress_mind_ref = null
	return ..()

/mob/living/simple_animal/hostile/retaliate/wolf/companion/lustbound/proc/bind_to(datum/antagonist/succubus/mistress_datum)
	var/mob/living/mistress = mistress_datum?.owner?.current
	if(!istype(mistress) || !ai_controller)
		return FALSE
	mistress_mind_ref = WEAKREF(mistress_datum.owner)
	mistress_datum.summoned_lusthounds += src
	befriend(mistress)
	return TRUE

// --- Summon spell ---------------------------------------------------------------------------------

/datum/action/cooldown/spell/undirected/succubus_summon_imp
	name = "Call Whispering Imp"
	desc = "Offer a wandering spirit temporary form as a lesser infernal accomplice."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	charge_required = FALSE
	cooldown_time = SUCCUBUS_SUMMON_IMP_COOLDOWN

/datum/action/cooldown/spell/undirected/succubus_summon_imp/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || succubus_antag.get_succubus_contract_tier() < SUCCUBUS_RETINUE_UNLOCK_TIER)
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.succubus_imp_offer_pending)
		to_chat(owner, span_warning("My call is already echoing through the lower planes."))
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.count_summoned_imps() >= SUCCUBUS_SUMMON_IMP_CAP)
		to_chat(owner, span_warning("I can bind only one whispering imp at a time."))
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.essence < SUCCUBUS_COST_SUMMON_IMP)
		to_chat(owner, span_warning("I lack the essence to give an imp form."))
		return . | SPELL_CANCEL_CAST
	if(!succubus_antag.get_imp_spawn_turf())
		to_chat(owner, span_warning("I need clear ground beside me for the imp to manifest."))
		return . | SPELL_CANCEL_CAST
	return . | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/undirected/succubus_summon_imp/cast(mob/living/cast_on)
	. = ..()
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag)
		return
	succubus_antag.succubus_imp_offer_pending = TRUE
	to_chat(owner, span_love("I send a tempting whisper into the lower planes..."))
	INVOKE_ASYNC(succubus_antag, TYPE_PROC_REF(/datum/antagonist/succubus, offer_imp_summon), WEAKREF(src))

/datum/antagonist/succubus/proc/get_imp_spawn_turf()
	var/mob/living/caster = owner?.current
	if(!istype(caster) || caster.stat == DEAD)
		return
	for(var/turf/candidate as anything in shuffle(get_adjacent_open_turfs(caster)))
		if(!candidate.is_blocked_turf())
			return candidate

/datum/antagonist/succubus/proc/offer_imp_summon(datum/weakref/spell_weakref)
	var/list/candidates = pollGhostCandidates(
		"Serve temporarily as a demon's whispering imp? This is a 30-minute collaborative antagonist role.",
		ROLE_SUCCUBUS,
		null,
		poll_time = SUCCUBUS_SUMMON_IMP_POLL_TIME,
		ignore_category = POLL_IGNORE_SUCCUBUS_SUMMON,
		new_players = TRUE,
	)
	if(QDELETED(src))
		return
	succubus_imp_offer_pending = FALSE

	var/datum/action/cooldown/spell/undirected/succubus_summon_imp/summon_spell = spell_weakref?.resolve()
	if(!summon_spell)
		return

	var/mob/living/caster = owner?.current
	var/turf/spawn_turf = get_imp_spawn_turf()
	if(summon_spell.owner != caster || !istype(caster) || caster.stat == DEAD || get_succubus_contract_tier() < SUCCUBUS_RETINUE_UNLOCK_TIER || count_summoned_imps() >= SUCCUBUS_SUMMON_IMP_CAP || essence < SUCCUBUS_COST_SUMMON_IMP || !spawn_turf)
		to_chat(caster, span_warning("My summoning circle falters before the spirit can cross."))
		summon_spell.StartCooldown(SUCCUBUS_SUMMON_IMP_RETRY_COOLDOWN)
		return
	if(!length(candidates))
		to_chat(caster, span_warning("No wandering spirit answers my call."))
		summon_spell.StartCooldown(SUCCUBUS_SUMMON_IMP_RETRY_COOLDOWN)
		return

	var/mob/chosen_candidate = pick(candidates)
	var/chosen_ckey = chosen_candidate.ckey
	if(!chosen_ckey || !chosen_candidate.client)
		to_chat(caster, span_warning("The answering spirit slips away before taking form."))
		summon_spell.StartCooldown(SUCCUBUS_SUMMON_IMP_RETRY_COOLDOWN)
		return

	chosen_candidate.leave_lobby_for_role()
	var/mob/living/simple_animal/hostile/retaliate/infernal/imp/succubus/new_imp = new(spawn_turf)
	new_imp.PossessByPlayer(chosen_ckey)
	new_imp.sync_mind()
	if(!new_imp.client || !new_imp.mind)
		qdel(new_imp)
		to_chat(caster, span_warning("The answering spirit slips free before taking form."))
		summon_spell.StartCooldown(SUCCUBUS_SUMMON_IMP_RETRY_COOLDOWN)
		return

	var/datum/antagonist/succubus_imp/imp_datum = new
	imp_datum.mistress_mind = owner
	var/datum/antagonist/succubus_imp/added_imp_datum = new_imp.mind.add_antag_datum(imp_datum)
	if(!added_imp_datum)
		qdel(new_imp)
		to_chat(caster, span_warning("The infernal bond fails to take hold."))
		summon_spell.StartCooldown(SUCCUBUS_SUMMON_IMP_RETRY_COOLDOWN)
		return

	summoned_imp_minds |= new_imp.mind
	adjust_essence(-SUCCUBUS_COST_SUMMON_IMP)
	summon_spell.StartCooldown(SUCCUBUS_SUMMON_IMP_COOLDOWN)
	caster.visible_message(
		span_warning("Sulphurous smoke coils beside [caster], and [new_imp] steps out laughing!"),
		span_love("Sulphurous smoke answers my whisper, giving an imp form."),
	)
	log_game("[key_name(new_imp)] became a whispering imp summoned by [key_name(caster)].")
	message_admins("[key_name_admin(new_imp)] became a whispering imp summoned by [key_name_admin(caster)].")

/datum/action/cooldown/spell/undirected/succubus_summon_lusthound
	name = "Call Lustbound Hound"
	desc = "Give temporary form to an infernal hound that obeys ordinary pet commands and preference-gated Ravage orders."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	charge_required = FALSE
	cooldown_time = SUCCUBUS_SUMMON_LUSTHOUND_COOLDOWN

/datum/action/cooldown/spell/undirected/succubus_summon_lusthound/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	if(!succubus_antag || succubus_antag.get_succubus_contract_tier() < SUCCUBUS_RETINUE_UNLOCK_TIER)
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.count_summoned_lusthounds() >= SUCCUBUS_SUMMON_LUSTHOUND_CAP)
		to_chat(owner, span_warning("I can bind only one lustbound hound at a time."))
		return . | SPELL_CANCEL_CAST
	if(succubus_antag.essence < SUCCUBUS_COST_SUMMON_LUSTHOUND)
		to_chat(owner, span_warning("I lack the essence to give a lustbound hound form."))
		return . | SPELL_CANCEL_CAST
	if(!succubus_antag.get_imp_spawn_turf())
		to_chat(owner, span_warning("I need clear ground beside me for the hound to manifest."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/undirected/succubus_summon_lusthound/cast(mob/living/cast_on)
	. = ..()
	var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(owner)
	var/turf/spawn_turf = succubus_antag?.get_imp_spawn_turf()
	if(!succubus_antag || !spawn_turf)
		return

	var/mob/living/simple_animal/hostile/retaliate/wolf/companion/lustbound/new_hound = new(spawn_turf)
	if(!new_hound.bind_to(succubus_antag))
		qdel(new_hound)
		return

	succubus_antag.adjust_essence(-SUCCUBUS_COST_SUMMON_LUSTHOUND)
	cast_on.visible_message(
		span_warning("Rose-coloured smoke pours across the ground beside [cast_on], shaping itself into [new_hound]!"),
		span_love("I give shape to a loyal appetite from the lower planes."),
	)
