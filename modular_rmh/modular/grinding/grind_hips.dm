// The hips: a hand pseudo-item that starts and steers grinding, the way the cock grip aims a climax.

#define GRIND_TEASE_COOLDOWN (4 SECONDS)
#define GRIND_TEASE_AROUSAL 1.5
#define GRIND_TEASE_PARTNER_AROUSAL 1
#define GRIND_MARK_TIME (1.5 SECONDS)
#define GRIND_MARK_COOLDOWN (5 SECONDS)

/mob/living/carbon/human
	/// The hips pseudo-item in this mob's hand, if any.
	var/obj/item/grind_hips/grind_hips

/datum/intent/grind_hips
	unarmed = TRUE
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	canparry = FALSE
	no_attack = TRUE
	misscost = 0
	releasedrain = 0
	hud_icon = 'modular_rmh/icons/hud/intents.dmi'

/datum/intent/grind_hips/grind
	name = "grind"
	desc = "Grind against whatever you click. Click another spot on the same person to shift there."
	icon_state = "ingrind"

/datum/intent/grind_hips/tease
	name = "tease"
	desc = "A single teasing grind against someone, with no scene."
	icon_state = "intease"

/datum/intent/grind_hips/mark
	name = "mark"
	desc = "Rub your scent into someone or something. Keen noses will know it is yours."
	icon_state = "inmark"

/obj/item/grind_hips
	name = "hips"
	desc = "My hips, ready to grind. Click someone or something next to me to grind against it. Use it in hand to stop."
	icon = 'icons/mob/roguehudgrabs.dmi'
	icon_state = "groin"
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = EVERYTHING_PROOF
	possible_item_intents = list(/datum/intent/grind_hips/grind, /datum/intent/grind_hips/tease, /datum/intent/grind_hips/mark)
	no_effect = TRUE
	force = 0
	throwforce = 0
	experimental_inhand = FALSE
	var/mob/living/carbon/human/owner
	/// The grind these hips started; it ends when they go.
	var/datum/sex_action/grind/grind_action
	/// The thing the next object grind starts on, read once by that action.
	var/atom/pending_thing
	COOLDOWN_DECLARE(tease_cooldown)
	COOLDOWN_DECLARE(mark_cooldown)

/obj/item/grind_hips/Initialize(mapload, mob/living/carbon/human/new_owner)
	. = ..()
	if(!istype(new_owner) || new_owner.grind_hips)
		return INITIALIZE_HINT_QDEL
	owner = new_owner
	owner.grind_hips = src
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_deleted))
	RegisterSignals(owner, list(COMSIG_MOB_STATCHANGE, COMSIG_MOVABLE_MOVED), PROC_REF(on_owner_changed))
	START_PROCESSING(SSobj, src)

/obj/item/grind_hips/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	pending_thing = null
	var/datum/sex_action/grind/running = grind_action
	grind_action = null
	if(running && !QDELETED(running))
		running.hips = null
		running.scene?.stop_action(running)
	if(owner?.grind_hips == src)
		owner.grind_hips = null
	owner = null
	return ..()

/obj/item/grind_hips/process(seconds_per_tick)
	if(!is_hold_valid())
		qdel(src)

/obj/item/grind_hips/proc/on_owner_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/item/grind_hips/proc/on_owner_changed(datum/source)
	SIGNAL_HANDLER
	if(!is_hold_valid())
		qdel(src)

/// TRUE while the owner is awake, holds the hips and has not logged off.
/obj/item/grind_hips/proc/is_hold_valid()
	if(QDELETED(owner) || loc != owner)
		return FALSE
	if(owner.stat >= UNCONSCIOUS)
		return FALSE
	return !owner.is_disconnected_player_erp_body()

/obj/item/grind_hips/melee_attack_chain(mob/user, atom/target, list/modifiers)
	if(user != owner || !is_hold_valid())
		return TRUE
	if(istype(user.used_intent, /datum/intent/grind_hips/tease))
		tease(target)
	else if(istype(user.used_intent, /datum/intent/grind_hips/mark))
		mark(target)
	else
		grind_at(target)
	return TRUE

/obj/item/grind_hips/afterattack(atom/target, mob/living/user, proximity_flag, list/modifiers)
	. = ..()
	if(proximity_flag || user != owner)
		return
	to_chat(user, span_warning("It's too far away."))

/// Using the hips in hand stops the grind; they stay ready.
/obj/item/grind_hips/attack_self(mob/user, list/modifiers)
	if(user != owner)
		return
	var/datum/sex_action/grind/running = owner.get_running_grind()
	if(running)
		running.scene?.stop_action(running)
		return
	to_chat(owner, span_notice("Click someone or something next to me to grind against it."))

/obj/item/grind_hips/proc/grind_at(atom/target)
	if(owner.cmode)
		to_chat(owner, span_warning("Not in the middle of a fight."))
		return FALSE
	if(isliving(target) && target != owner)
		return grind_on_partner(target)
	return grind_on_thing(target)

/// Starts a grind on [partner], shifts a running one to the clicked spot, or stops it on the same spot.
/obj/item/grind_hips/proc/grind_on_partner(mob/living/partner)
	var/zone = owner.zone_selected
	var/datum/sex_action/grind/partner/running = owner.get_running_grind()
	if(istype(running) && running.action_target == partner)
		if(owner.resolve_grind_spot(partner, zone) == running.spot)
			running.scene?.stop_action(running)
		else
			running.shift_to(zone)
		return TRUE
	var/refusal = owner.get_grind_refusal(partner, zone)
	if(refusal)
		to_chat(owner, span_warning(refusal))
		return FALSE
	stop_running_grind()
	var/datum/sex_scene_controller/controller = owner.open_sex_scene(partner, FALSE)
	if(!controller)
		to_chat(owner, span_warning(owner.get_sex_scene_refusal(partner) || "I can't grind against [partner] right now."))
		return FALSE
	return link_action(controller.try_start_action(/datum/sex_action/grind/partner), "I can't grind against [partner] right now.")

/// Starts a grind on a thing; standing toys, close pillows and the grinder's own seat have their own grinds.
/obj/item/grind_hips/proc/grind_on_thing(atom/thing)
	var/datum/sex_action/grind/running = owner.get_running_grind()
	if(running && running.grind_thing == thing)
		running.scene?.stop_action(running)
		return TRUE
	var/refusal = owner.get_grind_thing_refusal(thing)
	if(refusal)
		to_chat(owner, span_warning(refusal))
		return FALSE
	stop_running_grind()
	var/datum/sex_scene_controller/controller = owner.open_sex_scene(owner, FALSE)
	if(!controller)
		to_chat(owner, span_warning("I can't grind against that right now."))
		return FALSE
	if(get_grind_kind(thing) == "toy")
		if(!controller.try_start_action(/datum/sex_action/toy_grind))
			to_chat(owner, span_warning("I can't grind on it right now."))
			return FALSE
		return TRUE
	var/action_type = /datum/sex_action/grind/thing
	if(thing == owner.get_grind_seat())
		action_type = /datum/sex_action/grind/seat
	else if(is_pillow(thing) && ((thing in owner.held_items) || get_turf(thing) == get_turf(owner)))
		action_type = /datum/sex_action/grind/pillow
	pending_thing = thing
	var/datum/sex_action/grind/started = controller.try_start_action(action_type)
	pending_thing = null
	return link_action(started, "I can't grind against that right now.")

/obj/item/grind_hips/proc/link_action(datum/sex_action/grind/started, failure)
	if(!istype(started) || QDELETED(started))
		to_chat(owner, span_warning(failure))
		return FALSE
	grind_action = started
	started.hips = src
	return TRUE

/obj/item/grind_hips/proc/stop_running_grind()
	var/datum/sex_action/grind/running = owner.get_running_grind()
	running?.scene?.stop_action(running)

/// One teasing grind against a partner, with no scene and a short cooldown.
/obj/item/grind_hips/proc/tease(atom/target)
	if(!COOLDOWN_FINISHED(src, tease_cooldown))
		return FALSE
	if(owner.cmode)
		to_chat(owner, span_warning("Not in the middle of a fight."))
		return FALSE
	if(!isliving(target) || target == owner)
		to_chat(owner, span_warning(target == owner ? "I can't tease myself." : "Teasing needs someone to tease."))
		return FALSE
	var/mob/living/partner = target
	var/zone = owner.zone_selected
	var/refusal = owner.get_grind_refusal(partner, zone)
	if(refusal)
		to_chat(owner, span_warning(refusal))
		return FALSE
	var/spot = owner.resolve_grind_spot(partner, zone)
	var/spot_name = get_grind_spot_name(spot, partner, owner.is_grinding_from_behind(partner))
	COOLDOWN_START(src, tease_cooldown, GRIND_TEASE_COOLDOWN)
	owner.changeNext_move(CLICK_CD_MELEE)
	owner.visible_message(span_love(get_tease_line(partner, spot, spot_name)), vision_distance = COMBAT_MESSAGE_RANGE)
	nudge_towards(owner, partner, 2)
	playsound(owner, pick('modular_rmh/sound/erp/grind1.ogg', 'modular_rmh/sound/erp/grind2.ogg'), 20, TRUE, -2, ignore_walls = FALSE)
	for(var/mob/living/party as anything in list(owner, partner))
		if(!party.GetComponent(/datum/component/arousal))
			party.AddComponent(/datum/component/arousal)
	SEND_SIGNAL(owner, COMSIG_SEX_ADJUST_AROUSAL, GRIND_TEASE_AROUSAL)
	SEND_SIGNAL(partner, COMSIG_SEX_ADJUST_AROUSAL, GRIND_TEASE_PARTNER_AROUSAL)
	log_combat(owner, partner, "teased with a grind")
	return TRUE

/obj/item/grind_hips/proc/get_tease_line(mob/living/partner, spot, spot_name)
	var/their = owner.p_their()
	switch(spot)
		if(GRIND_SPOT_CROTCH)
			if(spot_name == "ass")
				return "[owner] presses [their] hips against [partner]'s ass in passing."
			return "[owner] rolls [their] hips against [partner]'s crotch, just once."
		if(GRIND_SPOT_LAP)
			return "[owner] sinks into [partner]'s lap for one slow roll of [their] hips."
		if(GRIND_SPOT_THIGH)
			return "[owner] rubs against [partner]'s thigh for one teasing moment."
	return "[owner] grinds against [partner]'s [spot_name] for one teasing moment."

/// A slow rub that leaves the owner's scent on a person or a thing.
/obj/item/grind_hips/proc/mark(atom/target)
	if(!COOLDOWN_FINISHED(src, mark_cooldown))
		return FALSE
	if(owner.cmode)
		to_chat(owner, span_warning("Not in the middle of a fight."))
		return FALSE
	if(target == owner)
		to_chat(owner, span_warning("I already smell of myself."))
		return FALSE
	var/their = owner.p_their()
	var/room
	var/own
	if(isliving(target))
		var/mob/living/partner = target
		var/refusal = owner.get_grind_refusal(partner, owner.zone_selected)
		if(refusal)
			to_chat(owner, span_warning(refusal))
			return FALSE
		var/spot = owner.resolve_grind_spot(partner, owner.zone_selected)
		var/spot_name = get_grind_spot_name(spot, partner, owner.is_grinding_from_behind(partner))
		room = "[owner] rubs [their] hips slowly against [partner]'s [spot_name], marking [partner.p_them()] with [their] scent."
		own = "I rub my hips slowly against [partner]'s [spot_name], marking [partner.p_them()] with my scent."
	else
		var/refusal = owner.get_grind_thing_refusal(target)
		if(refusal)
			to_chat(owner, span_warning(refusal))
			return FALSE
		var/spot = owner.get_grind_thing_spot(target)
		room = "[owner] rubs [their] hips slowly along [spot], marking it with [their] scent."
		own = "I rub my hips slowly along [spot], marking it with my scent."
	COOLDOWN_START(src, mark_cooldown, GRIND_MARK_COOLDOWN)
	owner.visible_message(span_love(room), span_love(own))
	nudge_towards(owner, target, 1, 0.4 SECONDS, 0.5 SECONDS)
	if(!do_after(owner, GRIND_MARK_TIME, target) || QDELETED(target))
		return FALSE
	var/covered = scent_mark(target, owner, TRUE)
	leave_fluid_scent(get_turf(target), owner, "musk")
	if(covered)
		to_chat(owner, span_notice("I cover [covered]'s scent with my own."))
	else
		to_chat(owner, span_notice("My scent clings to [isturf(target) ? "it" : target.p_them()] now."))
	if(isliving(target))
		SEND_SIGNAL(owner, COMSIG_SEX_ADJUST_AROUSAL, GRIND_TEASE_PARTNER_AROUSAL)
		to_chat(target, span_love("[owner] leaves [their] scent on me."))
		log_combat(owner, target, "scent-marked with a grind")
	return TRUE

/// A short push of [mover] towards [target] and back.
/proc/nudge_towards(atom/movable/mover, atom/target, pixels = 1, forward = 0.2 SECONDS, back = 0.3 SECONDS)
	var/towards = get_dir(mover, target) || mover.dir
	var/dx = (towards & EAST) ? pixels : ((towards & WEST) ? -pixels : 0)
	var/dy = (towards & NORTH) ? pixels : ((towards & SOUTH) ? -pixels : 0)
	sex_motion_nudge(mover, dx, dy, forward, back)

/// The grind this mob runs right now, or null.
/mob/living/proc/get_running_grind()
	RETURN_TYPE(/datum/sex_action/grind)
	for(var/datum/sex_action/grind/action in sex_scene?.active_actions)
		if(action.action_user == src && !QDELETED(action))
			return action
	return null

/// Puts the hips in a free hand, or lets them go when held.
/mob/living/carbon/human/proc/toggle_grind_hips()
	if(grind_hips)
		qdel(grind_hips)
		to_chat(src, span_notice("I let my hips rest."))
		return FALSE
	if(cmode)
		to_chat(src, span_warning("Not in the middle of a fight."))
		return FALSE
	if(get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, src))
		to_chat(src, span_warning("My armor is in the way."))
		return FALSE
	var/obj/item/grind_hips/hips = new(null, src)
	if(QDELETED(hips))
		return FALSE
	if(!put_in_active_hand(hips) && !put_in_inactive_hand(hips))
		qdel(hips)
		to_chat(src, span_warning("I need a free hand to steer my hips."))
		return FALSE
	// Each player sees how to use the hips once per round.
	var/static/list/hinted_ckeys = list()
	if(ckey && !hinted_ckeys[ckey])
		hinted_ckeys[ckey] = TRUE
		to_chat(src, span_notice("Click someone or something next to me to grind against it. The doll picks the spot on a person. Tease intent gives one quick grind, mark intent rubs my scent in. Use the hips in hand to stop, drop them to let go."))
	return TRUE

/datum/emote/living/carbon/human/grind
	key = "grind"
	key_third_person = "grinds"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/grind/run_emote(mob/user, params, type_override, intentional, targetted)
	var/mob/living/carbon/human/grinder = user
	if(!istype(grinder) || !can_run_emote(user, TRUE, intentional))
		return FALSE
	grinder.toggle_grind_hips()
	return TRUE

/mob/living/carbon/human/verb/emote_grind()
	set name = "Grind"
	set category = "Emotes.Silent"

	emote("grind", intentional = TRUE)

#undef GRIND_TEASE_COOLDOWN
#undef GRIND_TEASE_AROUSAL
#undef GRIND_TEASE_PARTNER_AROUSAL
#undef GRIND_MARK_TIME
#undef GRIND_MARK_COOLDOWN
