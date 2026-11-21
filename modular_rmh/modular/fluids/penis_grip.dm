// A hand on a cock: a grab-like pseudo-item that aims the climax, slaps, edges, and strokes it.

/obj/item/organ/genitals/penis
	/// The hand pseudo-item holding this cock, if any.
	var/obj/item/penis_grip/grip

/// What a hand holds: a worn strapon, or the real thing.
/obj/item/organ/genitals/penis/proc/get_hold_word()
	return strapon ? "strapon" : "cock"

/datum/intent/penis_grip
	unarmed = TRUE
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	canparry = FALSE
	no_attack = TRUE
	misscost = 0
	releasedrain = 0

/datum/intent/penis_grip/aim
	name = "aim"
	desc = "Point it where the climax should land."
	icon_state = "inaim"
	hud_icon = 'modular_rmh/icons/hud/intents.dmi'

/datum/intent/penis_grip/slap
	name = "slap"
	desc = "Slap someone with it."
	icon_state = "inslap"
	hud_icon = 'modular_rmh/icons/hud/intents.dmi'

/datum/intent/penis_grip/edge
	name = "edge"
	desc = "Squeeze the base to hold back a climax that is close, or choke it off mid-spurt. Click anywhere or use it in hand."
	icon_state = "inedge"
	hud_icon = 'modular_rmh/icons/hud/intents.dmi'

/obj/item/penis_grip
	name = "cock"
	desc = "A firm hold on a cock. Aim it, slap with it, or use it in hand to stroke it. Right-click it in hand to squeeze the base."
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "groin"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = EVERYTHING_PROOF
	possible_item_intents = list(/datum/intent/penis_grip/aim, /datum/intent/penis_grip/slap, /datum/intent/penis_grip/edge)
	no_effect = TRUE
	force = 0
	throwforce = 0
	experimental_inhand = FALSE
	/// Whose cock this is.
	var/mob/living/carbon/owner
	/// Who holds it.
	var/mob/living/carbon/holder
	var/obj/item/organ/genitals/penis/penis
	/// The stroking action the holder runs on this cock, if any.
	var/datum/sex_action/stroke_action
	/// TRUE when a stroking action made this grip, so the hand lets go when the stroking stops.
	var/made_by_action = FALSE
	/// TRUE once the hand felt the cock throb near climax; resets when it calms down.
	var/close_cued = FALSE
	COOLDOWN_DECLARE(slap_cooldown)
	COOLDOWN_DECLARE(squeeze_cooldown)
	COOLDOWN_DECLARE(aim_message_cooldown)

/obj/item/penis_grip/Initialize(mapload, mob/living/carbon/new_holder, mob/living/carbon/new_owner, obj/item/organ/genitals/penis/new_penis)
	. = ..()
	if(!new_holder || !new_owner || !new_penis)
		return INITIALIZE_HINT_QDEL
	holder = new_holder
	owner = new_owner
	penis = new_penis
	penis.grip = src
	var/word = penis.get_hold_word()
	name = holder == owner ? word : "[owner.name]'s [word]"
	RegisterSignal(penis, COMSIG_PARENT_QDELETING, PROC_REF(on_part_deleted))
	var/list/parties = list(holder)
	parties |= owner
	for(var/mob/living/party as anything in parties)
		RegisterSignal(party, COMSIG_PARENT_QDELETING, PROC_REF(on_part_deleted))
		RegisterSignals(party, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_STATCHANGE), PROC_REF(on_party_changed))
	START_PROCESSING(SSobj, src)

/obj/item/penis_grip/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	drop_aim()
	if(penis?.grip == src)
		penis.grip = null
	var/datum/sex_action/stroking = stroke_action
	stroke_action = null
	if(stroking && !QDELETED(stroking))
		stroking.stroke_grip = null
		stroking.scene?.stop_action(stroking)
	owner = null
	holder = null
	penis = null
	return ..()

/obj/item/penis_grip/dropped(mob/user, silent)
	if(!QDELETED(src) && holder && !silent)
		holder.visible_message(span_warning("[holder] lets go of [get_cock_phrase(holder)]."))
	return ..()

/obj/item/penis_grip/process(seconds_per_tick)
	if(!is_hold_valid())
		lose_hold()
		return
	cue_close_climax()

/// The hold slips for a reason the holder did not choose, so they are told.
/obj/item/penis_grip/proc/lose_hold()
	if(!QDELETED(holder) && !QDELETED(owner) && !QDELETED(penis))
		to_chat(holder, span_warning("I lose my hold on [get_cock_phrase(holder)]."))
	qdel(src)

/// The hand feels the cock throb as a climax nears, the moment to squeeze.
/obj/item/penis_grip/proc/cue_close_climax()
	var/datum/component/arousal/arousal = owner.GetComponent(/datum/component/arousal)
	if(!arousal || penis.strapon)
		return
	if(arousal.orgasm_progress < EDGE_SQUEEZE_MIN_PROGRESS)
		close_cued = FALSE
		return
	if(close_cued || arousal.orgasm_progress < EDGE_SQUEEZE_CUE_PROGRESS)
		return
	close_cued = TRUE
	var/who = holder == owner ? "My cock throbs in my hand. I'm close" : "[owner]'s cock throbs in my hand. [owner.p_theyre(TRUE)] close"
	to_chat(holder, span_love("[who]! <i>(Right-click it in hand to squeeze.)</i>"))

/obj/item/penis_grip/proc/on_part_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/item/penis_grip/proc/on_party_changed(datum/source)
	SIGNAL_HANDLER
	if(!is_hold_valid())
		lose_hold()

/// TRUE while the holder can keep a hand on the cock.
/obj/item/penis_grip/proc/is_hold_valid()
	if(QDELETED(owner) || QDELETED(holder) || QDELETED(penis))
		return FALSE
	if(penis.owner != owner || loc != holder)
		return FALSE
	if(holder.stat >= UNCONSCIOUS || owner.stat == DEAD)
		return FALSE
	if(holder != owner && !holder.adjacent_or_closet(owner))
		return FALSE
	// A player who logs off without allowing it is let go; a holder who logs off lets go.
	if(holder != owner && !owner.allows_player_erp_while_disconnected())
		return FALSE
	if(holder.is_disconnected_player_erp_body())
		return FALSE
	return owner.is_penis_grippable(holder)

/obj/item/penis_grip/melee_attack_chain(mob/user, atom/target, list/modifiers)
	if(user != holder || !is_hold_valid())
		return TRUE
	if(istype(user.used_intent, /datum/intent/penis_grip/slap))
		if(isliving(target))
			slap(target, user)
		return TRUE
	if(istype(user.used_intent, /datum/intent/penis_grip/edge))
		squeeze(user)
		return TRUE
	aim_at(target, user)
	return TRUE

/// Clicks out of reach only squeeze; the cock itself reaches no further than its owner.
/obj/item/penis_grip/afterattack(atom/target, mob/living/user, proximity_flag, list/modifiers)
	. = ..()
	if(proximity_flag || user != holder || !is_hold_valid())
		return
	if(istype(user.used_intent, /datum/intent/penis_grip/edge))
		squeeze(user)
		return
	to_chat(user, span_warning("It won't reach that far."))

/// Right-click in hand squeezes, whatever the intent.
/obj/item/penis_grip/attack_self_secondary(mob/user, list/modifiers)
	if(user == holder && is_hold_valid())
		squeeze(user)
	return TRUE

/// Using the grip in hand squeezes on the edge intent, and otherwise starts or stops stroking.
/obj/item/penis_grip/attack_self(mob/user, list/modifiers)
	if(user != holder)
		return
	if(istype(user.used_intent, /datum/intent/penis_grip/edge))
		if(is_hold_valid())
			squeeze(user)
		return
	if(stroke_action)
		// Stopping by hand keeps the hold.
		made_by_action = FALSE
		stroke_action.scene?.stop_action(stroke_action)
		return
	start_stroking()

/// A hand that takes hold mid-stroke joins that stroking, so using it in hand stops it.
/obj/item/penis_grip/proc/adopt_running_stroke()
	for(var/datum/sex_action/action as anything in holder.sex_scene?.active_actions)
		if(action.action_user != holder || action.stroke_grip)
			continue
		if(action.get_grip_owner(action.action_user, action.action_target) != owner)
			continue
		action.stroke_grip = src
		stroke_action = action
		return

/obj/item/penis_grip/proc/start_stroking()
	var/datum/sex_scene_controller/controller = holder.open_sex_scene(owner, FALSE)
	var/action_type = holder == owner ? /datum/sex_action/masturbate/penis : /datum/sex_action/masturbate/other/penis
	if(!controller?.try_start_action(action_type))
		to_chat(holder, span_warning("I can't stroke it right now."))
		return FALSE
	return TRUE

/// The cock can only reach what is next to its owner.
/obj/item/penis_grip/proc/can_reach(atom/target)
	return penis.get_climax_aim().can_reach(target)

/obj/item/penis_grip/proc/get_cock_phrase(mob/living/subject, mob/living/victim)
	var/word = penis.get_hold_word()
	if(owner == subject)
		return "[subject.p_their()] [word]"
	if(owner == victim)
		return "[victim.p_their()] own [word]"
	return "[owner]'s [word]"

// --- Aim ---

/// Points the cock at a mob zone, a container, a garment or the floor; the aim lives on the cock.
/obj/item/penis_grip/proc/aim_at(atom/target, mob/living/user)
	if(penis.strapon)
		to_chat(user, span_warning("A strapon has nothing to aim."))
		return FALSE
	var/datum/climax_aim/aim = penis.get_climax_aim()
	if(!aim.can_reach(target))
		to_chat(user, span_warning("It won't reach that far."))
		return FALSE
	var/atom/new_aim
	var/new_zone
	if(isliving(target))
		var/mob/living/aimed = target
		if(aimed.stat == DEAD)
			return FALSE
		if(aimed != user && aimed != owner && !aimed.allows_player_erp_while_disconnected())
			return FALSE
		new_aim = aimed
		new_zone = user.zone_selected == BODY_ZONE_PRECISE_MOUTH ? PENIS_AIM_MOUTH : body_zone_to_coat_zone(user.zone_selected)
	else if(is_aim_container(target) || is_aim_garment(target))
		new_aim = target
	else
		new_aim = get_turf(target)
	if(!new_aim)
		return FALSE
	aim.set_target(new_aim, new_zone, user)
	var/aim_text = aim.get_text(user)
	if(COOLDOWN_FINISHED(src, aim_message_cooldown))
		COOLDOWN_START(src, aim_message_cooldown, PENIS_AIM_MESSAGE_COOLDOWN)
		user.visible_message(span_love("[user] points [get_cock_phrase(user)] at [aim_text]."), span_love("I point [owner == user ? "my cock" : "[owner]'s cock"] at [aim_text]."))
	else
		to_chat(user, span_notice("I aim at [aim_text]."))
	return TRUE

/// Letting go ends an aim this hand made.
/obj/item/penis_grip/proc/drop_aim()
	var/datum/climax_aim/aim = penis?.climax_aim
	if(holder && aim?.aimer == holder)
		aim.clear()

// --- Edge ---

/// Squeezing the base holds back a close climax; mid-spurt it chokes the rest off.
/obj/item/penis_grip/proc/squeeze(mob/living/user)
	if(!COOLDOWN_FINISHED(src, squeeze_cooldown))
		return FALSE
	if(penis.strapon)
		to_chat(user, span_warning("A strapon has nothing to hold back."))
		return FALSE
	var/datum/component/arousal/arousal = owner.GetComponent(/datum/component/arousal)
	if(!arousal?.active_spurts && (arousal?.orgasm_progress || 0) < EDGE_SQUEEZE_MIN_PROGRESS)
		to_chat(user, span_notice(owner == user ? "I'm not close enough to hold anything back." : "[owner] isn't close enough to hold anything back."))
		return FALSE
	COOLDOWN_START(src, squeeze_cooldown, EDGE_SQUEEZE_COOLDOWN)
	user.changeNext_move(CLICK_CD_MELEE)
	var/whose = owner == user ? "[user.p_their()] own" : "[owner]'s"
	if(arousal.active_spurts)
		arousal.active_spurts.choke()
		user.visible_message(span_love("[user] squeezes hard, choking off [whose] climax!"))
		to_chat(owner, span_warning("It stops short, and leaves me aching for more."))
		// A ruined release brings none of a real one's relief.
		owner.remove_stress(list(/datum/stress_event/cumok, /datum/stress_event/pent_up_release))
		owner.add_stress(/datum/stress_event/ruined_orgasm)
		SEND_SIGNAL(owner, COMSIG_SEX_SET_AROUSAL, RUINED_ORGASM_AROUSAL)
		return TRUE
	SEND_SIGNAL(owner, COMSIG_SEX_ADJUST_ORGASM_PROG, -EDGE_SQUEEZE_DRAIN)
	SEND_SIGNAL(owner, COMSIG_SEX_ADJUST_EDGING, EDGE_SQUEEZE_EDGING)
	user.visible_message(span_love("[user] squeezes the base of [get_cock_phrase(user)], holding it back."), span_love("I squeeze the base of [owner == user ? "my cock" : "[owner]'s cock"], holding it back."))
	if(owner != user)
		to_chat(owner, span_love("The squeeze pulls me back from the edge."))
	return TRUE

/datum/stress_event/ruined_orgasm
	stress_change = 2
	desc = span_red("My climax was choked off. So close...")
	timer = 5 MINUTES

// --- Slap ---

/obj/item/penis_grip/proc/slap(mob/living/victim, mob/living/user)
	if(!COOLDOWN_FINISHED(src, slap_cooldown))
		return FALSE
	if(user.cmode)
		to_chat(user, span_warning("Not in the middle of a fight."))
		return FALSE
	if(victim.stat == DEAD || !can_reach(victim))
		return FALSE
	if(victim != user && victim != owner && !victim.allows_player_erp_while_disconnected())
		return FALSE
	// Nobody is endowed enough to reach their own face or chest.
	if(victim == owner && !(user.zone_selected in get_self_slap_zones()))
		to_chat(user, span_warning("It won't reach that far up."))
		return FALSE
	COOLDOWN_START(src, slap_cooldown, PENIS_SLAP_COOLDOWN)
	user.changeNext_move(CLICK_CD_MELEE)
	var/force_mult = get_slap_force_multiplier(user)
	// Weighed before the arousal change below can shift the erection.
	var/heavy = victim != owner && victim != user && get_slap_heft(victim, force_mult) >= PENIS_SLAP_KNOCKBACK_HEFT
	var/spot = "[victim == user ? "[user.p_their()] own" : "[victim]'s"] [get_slap_spot(victim, user.zone_selected)]"
	var/cock = get_cock_phrase(user, victim)
	if(get_stiffness() < 1)
		user.visible_message(span_love("[user] flops [cock] against [spot]."))
	else
		var/slap_verb = force_mult < 1 ? "taps" : (force_mult > 1 ? "smacks" : "slaps")
		user.visible_message(span_love("[user] [slap_verb] [spot] with [cock]!"))
	playsound(victim, pick('sound/foley/slap.ogg', 'sound/foley/smackspecial.ogg'), force_mult < 1 ? 30 : 45, TRUE, -2, ignore_walls = FALSE)
	user.do_attack_animation(victim, used_item = FALSE, atom_bounce = TRUE)
	// A strapon feels nothing for its wearer.
	if(!penis.strapon)
		SEND_SIGNAL(owner, COMSIG_SEX_ADJUST_AROUSAL, PENIS_SLAP_AROUSAL * force_mult)
	log_combat(user, victim, "slapped with [owner == user ? "their own" : "[owner]'s"] [penis.get_hold_word()]")
	if(heavy)
		knock_back(victim, user)
	return TRUE

/// Where a cock can slap its own owner: belly, crotch, legs and hands.
/obj/item/penis_grip/proc/get_self_slap_zones()
	var/static/list/zones = list(
		BODY_ZONE_PRECISE_STOMACH,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
	)
	return zones

/// The weak and strong right-click stances soften or harden a slap.
/obj/item/penis_grip/proc/get_slap_force_multiplier(mob/living/user)
	if(istype(user.rmb_intent, /datum/rmb_intent/weak))
		return 0.5
	if(istype(user.rmb_intent, /datum/rmb_intent/strong))
		return 1.5
	return 1

/obj/item/penis_grip/proc/get_stiffness()
	if(penis.always_hard)
		return 1
	switch(penis.erect_state)
		if(ERECT_STATE_NONE)
			return 0.5
		if(ERECT_STATE_PARTIAL)
			return 0.75
	return 1

/// Size against average, times the body-height mismatch, force and stiffness.
/obj/item/penis_grip/proc/get_slap_heft(mob/living/victim, force_mult = 1)
	var/mismatch = 1
	var/owner_weight = owner.get_mob_weight()
	var/victim_weight = victim.get_mob_weight()
	if(owner_weight > 0 && victim_weight > 0)
		mismatch = (owner_weight / victim_weight) ** (1 / 3)
	return (penis.organ_size / DEFAULT_PENIS_SIZE) * mismatch * force_mult * get_stiffness()

/obj/item/penis_grip/proc/get_slap_spot(mob/living/victim, zone)
	switch(zone)
		if(BODY_ZONE_PRECISE_MOUTH)
			return "lips"
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL, BODY_ZONE_PRECISE_EARS, BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE, BODY_ZONE_PRECISE_NOSE)
			return "cheek"
		if(BODY_ZONE_PRECISE_NECK)
			return "neck"
		if(BODY_ZONE_CHEST)
			return victim.getorganslot(ORGAN_SLOT_BREASTS) ? "tits" : "chest"
		if(BODY_ZONE_PRECISE_STOMACH)
			return "belly"
		if(BODY_ZONE_PRECISE_GROIN)
			return penis.get_climax_aim().is_from_behind(victim) ? "ass" : "crotch"
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return "thigh"
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return "foot"
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return "hand"
	return "body"

/// Pushes the victim one tile away, or only jolts them when that would be unsafe.
/obj/item/penis_grip/proc/knock_back(mob/living/victim, mob/living/user)
	var/push_dir = get_dir(user, victim) || user.dir
	var/turf/landing = get_step(victim, push_dir)
	shake_camera(victim, 2, 1)
	if(victim.body_position == LYING_DOWN || victim.buckled || victim.anchored || !is_safe_landing(landing) || !victim.Move(landing, push_dir))
		victim.visible_message(span_warning("[victim] reels from the heft of it!"))
		return FALSE
	victim.visible_message(span_warning("[victim] is knocked back by the sheer heft of it!"))
	return TRUE

/// No pushing anyone into walls, other people, drops, lava or deep water.
/obj/item/penis_grip/proc/is_safe_landing(turf/landing)
	if(!isopenturf(landing) || landing.is_blocked_turf())
		return FALSE
	if(istype(landing, /turf/open/openspace) || istype(landing, /turf/open/lava))
		return FALSE
	if(istype(landing, /turf/open/water))
		var/turf/open/water/water = landing
		if(water.water_height >= WATER_HEIGHT_DEEP)
			return FALSE
	return TRUE

// --- Taking hold ---

/// TRUE while an action in this mob's scene has their cock inside someone.
/mob/living/proc/is_penis_inside_someone()
	for(var/datum/sex_action/action as anything in sex_scene?.active_actions)
		if(action.get_inserted_penis_owner(action.action_user, action.action_target) == src)
			return TRUE
	return FALSE

/// TRUE when the cock is there, free of devices, not inside someone, and no armor keeps [actor] off it.
/mob/living/carbon/proc/is_penis_grippable(mob/living/actor)
	if(!getorganslot(ORGAN_SLOT_PENIS) || is_organ_slot_blocked(ORGAN_SLOT_PENIS) || is_penis_inside_someone())
		return FALSE
	return !get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, actor)

/// Puts a grip on the owner's cock into a free hand, preferring the given hand zone; returns it or null.
/mob/living/carbon/proc/take_penis_grip(mob/living/carbon/grip_owner, made_by_action = FALSE, hand_zone)
	var/obj/item/organ/genitals/penis/penis = grip_owner?.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis || penis.grip || !grip_owner.is_penis_grippable(src))
		return null
	var/obj/item/penis_grip/grip = new(null, src, grip_owner, penis)
	grip.made_by_action = made_by_action
	var/placed = FALSE
	if(hand_zone && hand_zone == get_inactive_precise_hand())
		placed = put_in_inactive_hand(grip)
	if(!placed)
		placed = put_in_active_hand(grip) || put_in_inactive_hand(grip)
	if(!placed)
		qdel(grip)
		return null
	return grip

/// An empty help-intent hand on the groin takes hold of the cock there; TRUE when it did.
/mob/living/carbon/human/proc/try_grip_penis(mob/living/carbon/human/target)
	if(cmode || zone_selected != BODY_ZONE_PRECISE_GROIN || get_active_held_item())
		return FALSE
	if(!istype(target) || target.stat == DEAD || target.on_fire)
		return FALSE
	// Rescuing someone from defeat stays on the help click.
	if(target.has_status_effect(/datum/status_effect/defeat_knockout))
		return FALSE
	var/obj/item/organ/genitals/penis/penis = target.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis)
		return FALSE
	var/word = penis.get_hold_word()
	if(target.is_penis_inside_someone())
		to_chat(src, span_warning(target == src ? "My [word] is busy inside someone." : "[target]'s [word] is busy inside someone."))
		return TRUE
	if(!target.is_penis_grippable(src))
		return FALSE
	if(target != src && !target.allows_player_erp_while_disconnected())
		return FALSE
	if(penis.grip)
		to_chat(src, span_warning(penis.grip.holder == src ? "I already hold it." : "[penis.grip.holder] already holds it."))
		return TRUE
	var/obj/item/penis_grip/grip = take_penis_grip(target)
	if(!grip)
		return FALSE
	grip.adopt_running_stroke()
	var/whose = target == src ? "[p_their()] [word]" : "[target]'s [word]"
	visible_message(span_warning("[src] takes hold of [whose]."), span_warning("I take hold of [target == src ? "my [word]" : "[target]'s [word]"]."))
	// Each player sees how to use the hold once per round.
	var/static/list/hinted_ckeys = list()
	if(ckey && !hinted_ckeys[ckey])
		hinted_ckeys[ckey] = TRUE
		to_chat(src, span_notice("Click a spot to aim it. Slap intent slaps. Use it in hand to stroke, right-click it in hand to squeeze the base. Drop it to let go."))
	return TRUE

// --- Sex action links ---

/datum/sex_action
	/// The grip this stroking action is linked to.
	var/obj/item/penis_grip/stroke_grip

/// Whose cock this action strokes by hand, so a grip can steer its climax; null for most actions.
/datum/sex_action/proc/get_grip_owner(mob/living/user, mob/living/target)
	return null

/datum/sex_action/masturbate/penis/get_grip_owner(mob/living/user, mob/living/target)
	return user

/datum/sex_action/masturbate/penis_over/get_grip_owner(mob/living/user, mob/living/target)
	return user

/datum/sex_action/masturbate/other/penis/get_grip_owner(mob/living/user, mob/living/target)
	return target

/// Whose cock this action puts inside someone, or null.
/datum/sex_action/proc/get_inserted_penis_owner(mob/living/user, mob/living/target)
	// A cock still pressing at the opening is not inside yet.
	if(orifice_pressing || !ispath(stored_item_type, /obj/item/organ/genitals/penis))
		return null
	return get_storage_insertor(user, target)

// NPC penetration skips hole storage, so each names its cock directly.
// A warming NPC has not gone in yet.
/datum/sex_action/npc/npc_vaginal_sex/get_inserted_penis_owner(mob/living/user, mob/living/target)
	return warmup_cycles_left > 0 ? null : user

/datum/sex_action/npc/npc_anal_sex/get_inserted_penis_owner(mob/living/user, mob/living/target)
	return warmup_cycles_left > 0 ? null : user

/datum/sex_action/npc/npc_throat_sex/get_inserted_penis_owner(mob/living/user, mob/living/target)
	return user

/datum/sex_action/npc/npc_vaginal_ride_sex/get_inserted_penis_owner(mob/living/user, mob/living/target)
	return warmup_cycles_left > 0 ? null : target

/datum/sex_action/npc/npc_anal_ride_sex/get_inserted_penis_owner(mob/living/user, mob/living/target)
	return warmup_cycles_left > 0 ? null : target

/// On start: a stroking action links to a grip, or makes one; a cock going into something is let go.
/datum/sex_action/proc/sync_penis_grip(mob/living/user, mob/living/target)
	var/mob/living/carbon/grip_owner = get_grip_owner(user, target)
	if(!grip_owner)
		var/mob/living/insertor = get_inserted_penis_owner(user, target)
		var/obj/item/organ/genitals/penis/inserted = insertor?.getorganslot(ORGAN_SLOT_PENIS)
		if(inserted?.grip)
			qdel(inserted.grip)
		return
	if(!iscarbon(user) || !iscarbon(grip_owner) || user.ai_controller || can_mage_hand_reach(user, target))
		return
	var/obj/item/organ/genitals/penis/penis = grip_owner.getorganslot(ORGAN_SLOT_PENIS)
	var/obj/item/penis_grip/grip = penis?.grip
	if(!grip)
		var/mob/living/carbon/carbon_user = user
		grip = carbon_user.take_penis_grip(grip_owner, TRUE, selected_hand)
	if(grip?.holder != user || grip.stroke_action)
		return
	grip.stroke_action = src
	stroke_grip = grip

/// On finish: unlinks the grip; a grip the stroking made lets go with it.
/datum/sex_action/proc/unlink_penis_grip()
	var/obj/item/penis_grip/grip = stroke_grip
	stroke_grip = null
	if(QDELETED(grip) || grip.stroke_action != src)
		return
	grip.stroke_action = null
	if(grip.made_by_action)
		qdel(grip)
