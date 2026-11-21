// Strap-on harnesses: a finished toy in the ring stands in for a cock while the harness is worn on the belt.

/// Units the leather bulb behind the ring holds.
#define STRAPON_BULB_VOLUME 20
/// Units one squeeze of the bulb pushes out.
#define STRAPON_SQUEEZE_UNITS 5
#define STRAPON_SQUEEZE_COOLDOWN (2 SECONDS)
/// Share of a strapon act the wearer feels: the base presses on her mound only.
#define STRAPON_FEEL_PLAIN 0.5
/// With a plug on the inner fitting inside her, plus a little per plug size step.
#define STRAPON_FEEL_INNER 1
#define STRAPON_FEEL_INNER_PER_SIZE 0.1
/// The arcyne harness makes the toy feel like her own flesh.
#define STRAPON_FEEL_ARCYNE 1.25
#define STRAPON_SEAT_TIME (1 SECONDS)
/// Percent chance per rough thrust that the leather creaks.
#define STRAPON_CREAK_CHANCE 20
#define STRAPON_FLAVOR_COOLDOWN (40 SECONDS)
#define STRAPON_CHISEL_STRIKE_TIME (5 SECONDS)
#define STRAPON_CHISEL_BASE_CHANCE 35

GLOBAL_VAR_INIT(strapon_lock_serial, 0)

/obj/item/strapon_harness
	name = "strap-on harness"
	desc = "A leather harness with an iron ring. Seat a finished toy in the ring and wear it on the belt to use the toy as a cock. The bulb behind the ring holds a little liquid to spurt through the toy."
	icon = 'modular_rmh/icons/obj/lewd/strapon.dmi'
	icon_state = "strapon"
	base_icon_state = "strapon"
	mob_overlay_icon = 'modular_rmh/icons/obj/lewd/strapon_onmob.dmi'
	lefthand_file = 'modular_rmh/icons/mob/lewd/items_lefthand.dmi'
	righthand_file = 'modular_rmh/icons/mob/lewd/items_righthand.dmi'
	item_state = "strapon"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 0
	sellprice = 10
	equip_delay_other = 3 SECONDS
	strip_delay = 3 SECONDS
	actions_types = list(/datum/action/item_action/squeeze_strapon_bulb)
	action_slots = ITEM_SLOT_BELT
	lock = /datum/lock/key/strapon
	lock_sound = 'sound/foley/lockmetal.ogg'
	unlock_sound = 'sound/foley/lockmetal.ogg'
	rattle_sound = 'sound/foley/lockrattlemetal.ogg'
	/// The toy riding in the ring.
	var/obj/item/dildo/seated_toy
	/// The cock organ the toy stands in as while worn.
	var/obj/item/organ/genitals/penis/strapon/stand_in
	var/mob/living/carbon/human/wearer
	/// Share of strapon acts the wearer feels.
	var/wearer_feel = STRAPON_FEEL_PLAIN
	/// Share of pain aimed at the toy that reaches the wearer; a toy feels no chafe or pinch.
	var/wearer_pain_feel = 0
	/// The one key made with this harness.
	var/datum/weakref/generated_key_ref
	COOLDOWN_DECLARE(squeeze_cooldown)
	COOLDOWN_DECLARE(flavor_cooldown)

/obj/item/strapon_harness/Initialize(mapload, ...)
	lockids = list("strapon_[++GLOB.strapon_lock_serial]")
	. = ..()
	create_reagents(STRAPON_BULB_VOLUME, REFILLABLE | NO_REACT)
	RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_pre_unequip))
	if(loc)
		make_key(drop_location())

/obj/item/strapon_harness/Destroy()
	set_wearer(null)
	var/turf/spill = get_turf(src)
	if(seated_toy && spill)
		seated_toy.forceMove(spill)
	seated_toy = null
	generated_key_ref = null
	return ..()

/obj/item/strapon_harness/OnCrafted(dirin, mob/user)
	// The lock is built in and matches the key; hide it so the parent cannot strip it.
	var/datum/lock/own_lock = lock
	lock = null
	. = ..()
	lock = own_lock

/obj/item/strapon_harness/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != seated_toy)
		return
	seated_toy = null
	refresh_stand_in()
	update_appearance()
	wearer?.update_inv_belt()

/obj/item/strapon_harness/examine(mob/user)
	. = ..()
	. += seated_toy ? span_notice("\A [seated_toy] sits in the ring.") : span_notice("The ring is empty.")
	if(reagents?.total_volume)
		var/list/names = list()
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			names += LOWER_TEXT(reagent.name)
		. += span_notice("The bulb holds [round(reagents.total_volume)] units of [english_list(names)].")
	else
		. += span_notice("The bulb is empty. Pour a liquid in to fill it.")
	var/datum/lock/key/key_lock = lock
	if(key_lock?.lock_broken)
		. += span_warning("Its buckle lock has been chiselled apart.")
	else
		. += span_notice("The buckle is [locked() ? "locked" : "unlocked"].")

// ---- Seating the toy ----

/obj/item/strapon_harness/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/dildo) || user.cmode)
		return ..()
	if(istype(tool, /obj/item/dildo/plug))
		INVOKE_ASYNC(src, PROC_REF(seat_inner_plug), user, tool)
		return ITEM_INTERACT_SUCCESS
	INVOKE_ASYNC(src, PROC_REF(seat_toy), user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/strapon_harness/proc/seat_toy(mob/living/user, obj/item/dildo/toy)
	if(toy.can_custom)
		to_chat(user, span_warning("\The [toy] is not finished yet."))
		return FALSE
	if(seated_toy)
		to_chat(user, span_warning("\The [seated_toy] already sits in the ring."))
		return FALSE
	if(!do_after(user, STRAPON_SEAT_TIME, src))
		return FALSE
	if(seated_toy || QDELETED(toy) || user.get_active_held_item() != toy)
		return FALSE
	if(!user.transferItemToLoc(toy, src))
		return FALSE
	attach_toy(toy)
	user.visible_message(span_notice("[user] pushes \the [toy] through the ring of \the [src] until its base sits snug."), span_notice("I push \the [toy] through the ring until its base sits snug."))
	playsound(src, pick(get_buckle_sounds()), 35, TRUE, -2)
	return TRUE

/// Seats [toy], already moved into the harness, in the ring.
/obj/item/strapon_harness/proc/attach_toy(obj/item/dildo/toy)
	seated_toy = toy
	refresh_stand_in()
	update_appearance()
	wearer?.update_inv_belt()

/obj/item/strapon_harness/proc/seat_inner_plug(mob/living/user, obj/item/dildo/plug/plug)
	to_chat(user, span_warning("This harness has no fitting for a plug; a double-ended harness does."))
	return FALSE

/// In hand: takes the toy out of the ring.
/obj/item/strapon_harness/attack_self(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!seated_toy)
		to_chat(user, span_warning("There is no toy in the ring."))
		return
	var/obj/item/dildo/toy = seated_toy
	if(!user.put_in_hands(toy))
		toy.forceMove(user.drop_location())
	user.visible_message(span_notice("[user] pulls \the [toy] out of \the [src]."), span_notice("I pull \the [toy] out of the ring."))
	return TRUE

// ---- Looks ----

/obj/item/strapon_harness/update_icon_state()
	icon_state = seated_toy ? "[base_icon_state]_loaded" : base_icon_state
	item_state = seated_toy ? "dildo" : base_icon_state
	return ..()

/obj/item/strapon_harness/update_overlays()
	. = ..()
	if(!seated_toy)
		return
	var/mutable_appearance/toy_overlay = mutable_appearance(icon, "strapon_toy")
	toy_overlay.color = seated_toy.color
	toy_overlay.appearance_flags = RESET_COLOR
	. += toy_overlay

// Worn states skip the "_loaded" item state; the toy rides on top as its own tinted overlay.
/obj/item/strapon_harness/build_worn_icon(age = AGE_ADULT, default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, coom = FALSE, customi = null, sleeveindex, breast_size = 0, icon/clip_mask = null)
	if(!isinhands && !override_state)
		override_state = coom ? "[base_icon_state]_f" : base_icon_state
	return ..(age, default_layer, default_icon_file, isinhands, femaleuniform, override_state, coom, customi, sleeveindex, breast_size, clip_mask)

/obj/item/strapon_harness/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, dummy_block = FALSE)
	. = ..()
	if(isinhands || !seated_toy || !standing)
		return
	var/body_suffix = copytext(standing.icon_state, length(base_icon_state) + 1)
	var/mutable_appearance/toy_overlay = mutable_appearance(icon_file, "toy[body_suffix]")
	toy_overlay.color = seated_toy.color
	toy_overlay.appearance_flags = RESET_COLOR
	. += toy_overlay

// ---- Wearing ----

/obj/item/strapon_harness/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	set_wearer(slot == ITEM_SLOT_BELT && ishuman(user) ? user : null, initial)

/obj/item/strapon_harness/dropped(mob/user, silent = FALSE)
	set_wearer(null, silent)
	return ..()

/obj/item/strapon_harness/proc/set_wearer(mob/living/carbon/human/new_wearer, silent = FALSE)
	if(wearer == new_wearer)
		return
	var/mob/living/carbon/human/old_wearer = wearer
	if(old_wearer)
		leave_toy_in_knot(old_wearer)
		drop_stand_in()
		on_unbuckled(old_wearer, silent)
		UnregisterSignal(old_wearer, list(COMSIG_ATOM_ITEM_INTERACTION, COMSIG_PARENT_QDELETING))
	wearer = new_wearer
	if(!silent && (old_wearer || new_wearer))
		playsound(old_wearer || new_wearer, pick(get_buckle_sounds()), 40, TRUE, -2)
	if(!wearer)
		return
	RegisterSignal(wearer, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_wearer_item_interaction))
	RegisterSignal(wearer, COMSIG_PARENT_QDELETING, PROC_REF(on_wearer_deleted))
	refresh_stand_in()
	on_buckled(silent)
	var/obj/item/key/strapon/key = generated_key_ref?.resolve()
	if(key)
		key.name = "[wearer.real_name]'s harness key"

/obj/item/strapon_harness/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	set_wearer(null, TRUE)

/// Hook for the harness being buckled on; the double harness seats its inner plug here.
/obj/item/strapon_harness/proc/on_buckled(silent)
	return

/// Hook for the harness coming off [old_wearer].
/obj/item/strapon_harness/proc/on_unbuckled(mob/living/carbon/human/old_wearer, silent)
	return

/obj/item/strapon_harness/proc/get_buckle_sounds()
	return list('modular_rmh/sound/erp/strap_buckle1.ogg', 'modular_rmh/sound/erp/strap_buckle2.ogg', 'modular_rmh/sound/erp/strap_buckle3.ogg')

/// Rebuilds the stand-in cock from the seated toy; a wearer with a real cock gets none.
/obj/item/strapon_harness/proc/refresh_stand_in()
	drop_stand_in()
	if(!wearer || !seated_toy || wearer.getorganslot(ORGAN_SLOT_PENIS))
		return
	stand_in = new(src)
	stand_in.copy_from_toy(seated_toy, src)
	stand_in.Insert(wearer)

/obj/item/strapon_harness/proc/drop_stand_in()
	if(!stand_in)
		return
	var/obj/item/organ/genitals/penis/strapon/old_stand_in = stand_in
	stand_in = null
	var/mob/living/old_owner = old_stand_in.owner
	if(old_owner)
		var/atom/spill = old_owner.drop_location()
		for(var/obj/item/stored in old_stand_in.contents)
			stored.forceMove(spill)
		old_stand_in.Remove(old_owner)
	qdel(old_stand_in)

/// Unbuckled while the toy's knot is tied inside someone: the toy stays in them and the tie ends.
/obj/item/strapon_harness/proc/leave_toy_in_knot(mob/living/carbon/human/old_wearer)
	var/datum/component/knotting/knot = old_wearer.GetComponent(/datum/component/knotting)
	var/mob/living/carbon/partner = knot?.knotted_recipient
	if(!seated_toy || !stand_in || !istype(partner) || QDELETED(partner))
		return FALSE
	var/obj/item/organ/genitals/filling_organ/hole = knot.knotted_hole_ref?.resolve()
	if(!istype(hole) || hole.owner != partner)
		// With no hole to keep the toy in, the knot is torn out instead.
		knot.knot_remove(forceful_removal = TRUE, remover = old_wearer)
		return FALSE
	var/obj/item/dildo/toy = seated_toy
	var/knot_girth = stand_in.get_knot_girth()
	knot.knot_exit(spill = FALSE)
	toy.forceMove(partner.drop_location())
	SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FORCE_INSERT, toy, STORAGE_LAYER_INNER)
	if(!partner.apply_status_effect(/datum/status_effect/toy_stuck/knot/lodged, null, toy, hole.slot, knot_girth))
		var/layer = SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, toy)
		if(layer)
			SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FORCE_REMOVE, toy, layer)
		toy.forceMove(partner.drop_location())
		return FALSE
	partner.visible_message(span_love("The harness comes away from [old_wearer], but the knot of \the [toy] stays locked inside [partner]!"), span_love("The harness comes away, but the knotted toy stays locked inside me!"))
	return TRUE

// ---- Feel ----

/// Share of a strapon act the wearer feels right now.
/obj/item/strapon_harness/proc/get_wearer_feel()
	return wearer_feel

/// TRUE when [context] is the wearer feeling an act that works her strapon; grinding scales itself.
/obj/item/strapon_harness/proc/works_strapon(datum/sex_action_effect_context/context)
	if(!wearer || !stand_in || context.receiver != wearer || !context.action)
		return FALSE
	if(istype(context.action, /datum/sex_action/grind))
		return FALSE
	return context.action.uses_penis_of(wearer)

/obj/item/strapon_harness/proc/scale_wearer_pleasure(datum/sex_action_effect_context/context)
	if(!works_strapon(context))
		return
	var/feel = get_wearer_feel()
	context.arousal_amt *= feel
	context.orgasm_prog_amt *= feel
	context.pain_amt *= wearer_pain_feel

/obj/item/strapon_harness/proc/after_worn_action(datum/sex_action_effect_context/context)
	if(!works_strapon(context))
		return
	if(context.force >= SEX_FORCE_HIGH && prob(STRAPON_CREAK_CHANCE))
		playsound(wearer, pick('modular_rmh/sound/erp/leather_creak1.ogg', 'modular_rmh/sound/erp/leather_creak2.ogg', 'modular_rmh/sound/erp/leather_creak3.ogg'), 30, TRUE, -3)
	if(!COOLDOWN_FINISHED(src, flavor_cooldown))
		return
	var/line = get_feel_line()
	if(line)
		COOLDOWN_START(src, flavor_cooldown, STRAPON_FLAVOR_COOLDOWN)
		to_chat(wearer, span_love(line))

/// A line for the wearer about what the harness makes her feel, or null.
/obj/item/strapon_harness/proc/get_feel_line()
	return null

// ---- The bulb ----

/obj/item/strapon_harness/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/squeeze_strapon_bulb))
		squeeze_bulb(user)
		return
	return ..()

/obj/item/strapon_harness/proc/squeeze_bulb(mob/living/user)
	if(!wearer || user != wearer)
		return FALSE
	if(!seated_toy)
		to_chat(user, span_warning("There is no toy in the ring to spurt through."))
		return FALSE
	if(!reagents.total_volume)
		to_chat(user, span_warning("The bulb is empty."))
		return FALSE
	if(!COOLDOWN_FINISHED(src, squeeze_cooldown))
		return FALSE
	COOLDOWN_START(src, squeeze_cooldown, STRAPON_SQUEEZE_COOLDOWN)
	var/amount = min(STRAPON_SQUEEZE_UNITS, reagents.total_volume)
	var/datum/sex_action/action = get_strapon_action()
	var/mob/living/partner = get_strapon_partner(action)
	if(!partner)
		var/turf/floor = get_turf(wearer)
		floor?.add_liquid_from_reagents(reagents, amount = amount)
		wearer.visible_message(span_love("[wearer] squeezes the bulb of [wearer.p_their()] harness, and \the [seated_toy] dribbles onto the floor."), span_love("I squeeze the bulb, and \the [seated_toy] dribbles onto the floor."))
		return TRUE
	deliver(reagents, amount, action, partner, TRUE)
	var/obj/item/organ/genitals/filling_organ/hole = get_partner_hole(action, partner)
	var/where = hole ? "[partner]'s [hole.get_toy_hole_word()]" : "[partner]"
	wearer.visible_message(span_love("[wearer] squeezes the bulb of [wearer.p_their()] harness, and \the [seated_toy] spurts into [where]!"), span_love("I squeeze the bulb, and \the [seated_toy] spurts into [where]."))
	to_chat(partner, span_love("Something warm spurts into me from \the [seated_toy]!"))
	return TRUE

/// The wearer's running act that works her strapon, if any.
/obj/item/strapon_harness/proc/get_strapon_action()
	RETURN_TYPE(/datum/sex_action)
	if(!wearer?.sex_scene)
		return null
	for(var/datum/sex_action/action as anything in wearer.sex_scene.active_actions)
		if(action.action_user == action.action_target)
			continue
		if((action.action_user == wearer || action.action_target == wearer) && action.uses_penis_of(wearer))
			return action
	return null

/obj/item/strapon_harness/proc/get_strapon_partner(datum/sex_action/action)
	if(!action)
		return null
	return action.action_user == wearer ? action.action_target : action.action_user

/obj/item/strapon_harness/proc/get_partner_hole(datum/sex_action/action, mob/living/partner)
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ)
	if(!partner)
		return null
	switch(action?.hole_id)
		if(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
			return partner.getorganslot(action.hole_id)
	return null

/// Pushes [amount] of [source] out through the toy into or onto [partner]; returns units moved.
/obj/item/strapon_harness/proc/deliver(datum/reagents/source, amount, datum/sex_action/action, mob/living/partner, follow_up = TRUE)
	var/datum/component/arousal/arousal = wearer?.GetComponent(/datum/component/arousal)
	amount = min(amount, source?.total_volume)
	if(!arousal || !partner || amount <= 0)
		return 0
	var/mob/living/initiator = action?.action_user || wearer
	var/mob/living/target = action?.action_target || partner
	var/obj/item/organ/genitals/filling_organ/hole = get_partner_hole(action, partner)
	if(hole)
		var/room = hole.reagents ? max(0, hole.reagents.maximum_volume - hole.reagents.total_volume) : 0
		var/into = min(room, amount)
		. = 0
		if(into > 0)
			. = arousal.route_climax_reagents(source, into, wearer, partner, action, ORGASM_LOCATION_INTO, hole, INGEST, initiator, target, wearer, FALSE, follow_up)
			arousal.apply_creampie_effect(partner)
		if(amount > into)
			. += arousal.coat_climax_onto(source, amount - into, wearer, partner, action, ORGASM_LOCATION_ONTO, FLUID_COAT_THIGHS, initiator, target, wearer, TRUE)
		return
	if(action?.hole_id == BODY_ZONE_PRECISE_MOUTH)
		return arousal.route_climax_reagents(source, amount, wearer, partner, action, ORGASM_LOCATION_ORAL, partner, INGEST, initiator, target, wearer, FALSE, follow_up)
	var/coat_zone = action ? action.get_climax_coat_zone(wearer) : FLUID_COAT_GROIN
	return arousal.coat_climax_onto(source, amount, wearer, partner, action, ORGASM_LOCATION_ONTO, coat_zone, initiator, target, wearer, follow_up)

/// The wearer climaxed behind the strapon during [action] with [partner]: the bulb empties through the toy.
/obj/item/strapon_harness/proc/on_wearer_climax(datum/sex_action/action, mob/living/partner)
	if(!seated_toy || !partner || !reagents.total_volume)
		return
	if(deliver(reagents, reagents.total_volume, action, partner, TRUE) > 0)
		wearer.visible_message(span_love("The bulb behind [wearer]'s [seated_toy.name] squeezes empty as [wearer.p_they()] buck[wearer.p_s()], spurting into [partner]!"), span_love("My hips buck, the bulb squeezes empty, and the toy spurts into [partner]!"))

/// Called from the strapon climax branch; the worn harness takes it from here.
/mob/living/proc/on_strapon_climax(datum/sex_action/action, mob/living/partner)
	return

/mob/living/carbon/human/on_strapon_climax(datum/sex_action/action, mob/living/partner)
	var/obj/item/strapon_harness/harness = belt
	if(istype(harness) && harness.wearer == src)
		harness.on_wearer_climax(action, partner)

/// How much of a strapon act this mob feels; [default] without a worn harness.
/mob/living/proc/get_strapon_feel(default)
	return default

/mob/living/carbon/human/get_strapon_feel(default)
	var/obj/item/strapon_harness/harness = belt
	if(istype(harness) && harness.wearer == src)
		return harness.get_wearer_feel()
	return default

/// Share of pain on this mob's cock that it feels; a toy in a harness feels none unless the harness says so.
/mob/living/proc/get_strapon_pain_share()
	return 1

/mob/living/carbon/human/get_strapon_pain_share()
	var/obj/item/strapon_harness/harness = belt
	if(istype(harness) && harness.wearer == src && harness.stand_in)
		return harness.wearer_pain_feel
	return 1

/// The toy in the worn harness, if any, so its own lube counts on the way in.
/mob/living/proc/get_strapon_toy()
	RETURN_TYPE(/obj/item/dildo)
	return null

/mob/living/carbon/human/get_strapon_toy()
	var/obj/item/strapon_harness/harness = belt
	if(istype(harness) && harness.wearer == src && harness.stand_in)
		return harness.seated_toy
	return null

/datum/action/item_action/squeeze_strapon_bulb
	name = "Squeeze the bulb"
	desc = "Squeeze the harness bulb to spurt what it holds through the toy."

// ---- The buckle lock ----

/datum/lock/key/strapon
	difficulty = 3
	requires_turning = FALSE

/datum/lock/key/strapon/try_toggle(mob/living/user, obj/item/tool, is_right)
	if(lock_broken)
		to_chat(user, span_warning("The lock is broken and no longer closes."))
		return
	return ..()

/obj/item/key/strapon
	name = "harness key"
	desc = "A small brass key for the buckle lock of one strap-on harness."

/obj/item/strapon_harness/proc/make_key(atom/where)
	var/obj/item/key/strapon/key = new(where)
	var/datum/lock/key/key_lock = lock
	key.lockids = key_lock?.lockid_list?.Copy()
	generated_key_ref = WEAKREF(key)
	return key

/obj/item/strapon_harness/proc/on_pre_unequip(datum/source, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER
	if(force || !wearer || !locked())
		return NONE
	if(!silent)
		to_chat(wearer, span_warning("\The [src] is locked on."))
	return COMPONENT_ITEM_BLOCK_UNEQUIP

/obj/item/strapon_harness/canStrip(mob/stripper, mob/owner)
	if(wearer && locked())
		return FALSE
	return ..()

/obj/item/strapon_harness/pre_lock_interact(mob/living/user)
	if(!wearer || locked() || user == wearer)
		return TRUE
	if(!wearer.allows_chastity_play())
		to_chat(user, span_warning("[wearer] wants nothing to do with being locked into gear."))
		return FALSE
	return TRUE

/obj/item/strapon_harness/on_lock(mob/living/user, obj/item, silent = FALSE)
	announce_lock_change(user, TRUE, silent)

/obj/item/strapon_harness/on_unlock(mob/living/user, obj/item, silent = FALSE)
	announce_lock_change(user, FALSE, silent)

/obj/item/strapon_harness/proc/announce_lock_change(mob/living/user, now_locked, silent)
	if(!silent)
		playsound(src, now_locked ? lock_sound : unlock_sound, 50)
	if(!wearer)
		user.visible_message(span_notice("[user] [now_locked ? "locks" : "unlocks"] \the [src]."), span_notice("I [now_locked ? "lock" : "unlock"] \the [src]."))
		return
	var/whose = user == wearer ? user.p_their() : "[wearer]'s"
	user.visible_message(span_notice("[user] [now_locked ? "locks" : "unlocks"] the buckle of [whose] harness."), span_notice("I [now_locked ? "lock" : "unlock"] the buckle of [user == wearer ? "my" : "[wearer]'s"] harness."))
	if(user != wearer)
		to_chat(wearer, now_locked ? span_warning("The buckle of my harness clicks shut. It will not come off now.") : span_notice("The buckle of my harness clicks open."))

/// Keys, lockpicks and chisels used on the wearer's groin reach the worn buckle.
/obj/item/strapon_harness/proc/on_wearer_item_interaction(datum/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(user.cmode || user.zone_selected != BODY_ZONE_PRECISE_GROIN)
		return NONE
	var/datum/lock/key/key_lock = lock
	if(!istype(key_lock))
		return NONE
	if(istype(tool, /obj/item/weapon/chisel))
		// A locked chastity device under the harness takes the chisel first.
		var/obj/item/clothing/undies/chastity/device = wearer.underwear
		if(!locked() || (istype(device) && device.locked()))
			return NONE
		INVOKE_ASYNC(src, PROC_REF(try_chisel_off), user, tool)
		return ITEM_INTERACT_SUCCESS
	if(tool.can_lock_interact() && key_lock.check_access(tool))
		return key_lock.interact_wrap(src, user, tool, modifiers) || ITEM_INTERACT_BLOCKING
	if(locked() && is_type_in_list(tool, key_lock.lockpicks))
		return key_lock.interact_wrap(src, user, tool, modifiers) || ITEM_INTERACT_BLOCKING
	return NONE

/obj/item/strapon_harness/proc/try_chisel_off(mob/living/user, obj/item/weapon/chisel/chisel)
	var/mob/living/carbon/human/target = wearer
	if(!target || !locked() || !can_chisel(user, chisel))
		return
	user.visible_message(span_warning("[user] sets a chisel against the buckle lock of [target]'s harness and starts hammering."), span_warning("I set the chisel against the buckle lock and start hammering."))
	while(TRUE)
		if(!do_after(user, STRAPON_CHISEL_STRIKE_TIME, target))
			return
		if(QDELETED(src) || wearer != target || !locked() || !can_chisel(user, chisel))
			return
		playsound(target, pick('sound/combat/hits/onmetal/grille (1).ogg', 'sound/combat/hits/onmetal/grille (2).ogg', 'sound/combat/hits/onmetal/grille (3).ogg'), 50, TRUE)
		if(prob(clamp(STRAPON_CHISEL_BASE_CHANCE + (GET_MOB_ATTRIBUTE_VALUE(user, STAT_FORTUNE) - 10) * 4, 5, 85)))
			break_lock(user)
			return
		to_chat(user, span_warning("The lock holds. Another blow, then."))

/obj/item/strapon_harness/proc/can_chisel(mob/living/user, obj/item/weapon/chisel/chisel)
	if(user.get_active_held_item() != chisel || !(locate(/obj/item/weapon/hammer) in user.held_items))
		to_chat(user, span_warning("I need the chisel in one hand and a hammer in the other."))
		return FALSE
	return TRUE

/obj/item/strapon_harness/proc/break_lock(mob/living/user)
	var/datum/lock/key/key_lock = lock
	if(key_lock)
		key_lock.lock_broken = TRUE
		key_lock.locked = FALSE
	var/mob/living/carbon/human/old_wearer = wearer
	if(old_wearer)
		old_wearer.dropItemToGround(src, force = TRUE)
		old_wearer.visible_message(span_notice("The buckle lock of [old_wearer]'s harness snaps apart, and the harness comes free."))
	user?.put_in_hands(src)

// ---- The stand-in cock ----

/obj/item/organ/genitals/penis/strapon
	name = "strapon"
	strapon = TRUE
	always_hard = TRUE
	/// The harness this stand-in belongs to.
	var/datum/weakref/harness_ref

/obj/item/organ/genitals/penis/strapon/Destroy()
	harness_ref = null
	return ..()

/obj/item/organ/genitals/penis/strapon/proc/copy_from_toy(obj/item/dildo/toy, obj/item/strapon_harness/harness)
	name = toy.name
	harness_ref = WEAKREF(harness)
	switch(toy.dildo_type)
		if("knotted")
			penis_type = PENIS_TYPE_KNOTTED
		if("flared")
			penis_type = PENIS_TYPE_EQUINE
		else
			penis_type = PENIS_TYPE_PLAIN
	switch(toy.dildo_size)
		if("small")
			length_cm = 11
		if("medium")
			length_cm = 15
		else
			length_cm = 19
	organ_size = get_penis_visual_size(length_cm)

/obj/item/organ/genitals/penis/strapon/proc/get_harness()
	RETURN_TYPE(/obj/item/strapon_harness)
	return harness_ref?.resolve()

/obj/item/organ/genitals/penis/strapon/get_insert_girth()
	var/obj/item/strapon_harness/harness = get_harness()
	return harness?.seated_toy ? harness.seated_toy.get_insert_girth() : ..()

/obj/item/organ/genitals/penis/strapon/get_sex_action_effects(datum/sex_action_effect_context/context)
	var/obj/item/strapon_harness/harness = get_harness()
	if(!harness?.wearer)
		return null
	return list(new /datum/sex_action_effect/strapon_harness(harness))

/datum/sex_action_effect/strapon_harness

/datum/sex_action_effect/strapon_harness/modify_action(datum/sex_action_effect_context/context)
	var/obj/item/strapon_harness/harness = source_item
	harness?.scale_wearer_pleasure(context)

/datum/sex_action_effect/strapon_harness/after_action(datum/sex_action_effect_context/context)
	var/obj/item/strapon_harness/harness = source_item
	harness?.after_worn_action(context)

// ---- A knotted toy left inside ----

/obj/item/dildo
	/// TRUE while the toy's knot holds it inside someone; hands cannot draw it out.
	var/knot_lodged = FALSE

/obj/item/dildo/can_remove_from_body_storage(removal_reason = BODYSTORAGE_REMOVE_MANUAL)
	if(knot_lodged && removal_reason != BODYSTORAGE_REMOVE_INTERNAL)
		return FALSE
	return ..()

/// The toy stays in the hole; the knot slips free in time, or the owner pulls it out by the riding knot rules.
/datum/status_effect/toy_stuck/knot/lodged
	id = "toy_lodged"
	alert_type = /atom/movable/screen/alert/status_effect/toy_stuck/lodged
	/// Who worked it free, so the toy lands in their hands.
	var/mob/living/freed_by

/datum/status_effect/toy_stuck/knot/lodged/hold_owner()
	var/obj/item/organ/genitals/filling_organ/hole = owner.getorganslot(organ_slot)
	if(!istype(hole) || !SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, toy))
		return FALSE
	toy.knot_lodged = TRUE
	return TRUE

/datum/status_effect/toy_stuck/knot/lodged/release_owner()
	toy.knot_lodged = FALSE
	var/obj/item/organ/genitals/filling_organ/hole = owner.getorganslot(organ_slot)
	var/layer = istype(hole) ? SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, toy) : null
	if(layer)
		SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FORCE_REMOVE, toy, layer)
		if(!freed_by?.put_in_hands(toy))
			var/atom/spot = owner.drop_location()
			if(spot)
				toy.forceMove(spot)
	freed_by = null

/datum/status_effect/toy_stuck/knot/lodged/free(yanked, mob/living/helper)
	freed_by = helper
	return ..()

/datum/status_effect/toy_stuck/knot/lodged/show_squirm_line()
	if(prob(60))
		return
	to_chat(owner, span_love(pick(
		"The knot of \the [toy] tugs at my rim with every step.",
		"\The [toy] shifts inside me; its knot will not let it slip out.",
		"I clench around the knot of \the [toy] and shiver.",
	)))

/datum/status_effect/toy_stuck/knot/lodged/show_free_start(mob/living/helper)
	owner.visible_message(span_notice("[owner] reaches down and tries to work the knot of \the [toy] out of [owner.p_them()]..."), span_notice("I reach down and try to work the knot of \the [toy] out of me..."))

/datum/status_effect/toy_stuck/knot/lodged/show_free_fail(mob/living/helper)
	owner.visible_message(span_warning("The knot of \the [toy] holds fast inside [owner]."), span_warning("I pull, but the knot holds fast and tugs at my rim."))

/atom/movable/screen/alert/status_effect/toy_stuck/lodged
	name = "Knotted toy inside"
	desc = "A toy's knot is locked inside me. Wait for it to slip free, or resist or click here to pull it out."
	overlay_state = "toy_knotted"

// ---- Double-ended ----

/obj/item/strapon_harness/double
	name = "double-ended strap-on harness"
	desc = "A black leather strap-on harness with a second fitting on the inside. A plug on that fitting sits in the wearer's pussy, or her ass if she has none, so she feels every thrust she gives."
	icon_state = "strapon_double"
	base_icon_state = "strapon_double"
	sellprice = 18
	/// The plug on the inner fitting.
	var/obj/item/dildo/plug/inner_plug
	/// The hole the inner plug sits in while worn.
	var/obj/item/organ/genitals/filling_organ/inner_hole
	/// TRUE while the harness itself moves the plug, so its move hook stays quiet.
	var/tmp/moving_inner = FALSE

/obj/item/strapon_harness/double/Destroy()
	release_inner_plug(drop_location())
	return ..()

/obj/item/strapon_harness/double/examine(mob/user)
	. = ..()
	if(!inner_plug)
		. += span_notice("The inner fitting is empty. Click a finished plug onto the harness to fit it.")
	else if(inner_hole)
		. += span_notice("\A [inner_plug] on the inner fitting sits inside the wearer.")
	else
		. += span_notice("\A [inner_plug] sits on the inner fitting.")

/obj/item/strapon_harness/double/seat_inner_plug(mob/living/user, obj/item/dildo/plug/plug)
	if(!plug.can_stand_upright())
		to_chat(user, span_warning("Only a finished plug with a flat base fits the inner fitting."))
		return FALSE
	if(inner_plug)
		to_chat(user, span_warning("\The [inner_plug] already sits on the inner fitting."))
		return FALSE
	if(wearer)
		to_chat(user, span_warning("Take the harness off first."))
		return FALSE
	if(!do_after(user, STRAPON_SEAT_TIME, src))
		return FALSE
	if(inner_plug || wearer || QDELETED(plug) || user.get_active_held_item() != plug)
		return FALSE
	if(!user.transferItemToLoc(plug, src))
		return FALSE
	attach_inner_plug(plug)
	user.visible_message(span_notice("[user] screws \the [plug] onto the inner fitting of \the [src]."), span_notice("I screw \the [plug] onto the inner fitting."))
	return TRUE

/// Puts [plug], already moved into the harness, on the inner fitting.
/obj/item/strapon_harness/double/proc/attach_inner_plug(obj/item/dildo/plug/plug)
	inner_plug = plug
	RegisterSignal(plug, COMSIG_MOVABLE_MOVED, PROC_REF(on_inner_plug_moved))
	RegisterSignal(plug, COMSIG_PARENT_QDELETING, PROC_REF(on_inner_plug_deleted))
	update_appearance()

/// In hand with no toy in the ring: takes the inner plug off instead.
/obj/item/strapon_harness/double/attack_self(mob/user, list/modifiers)
	if(seated_toy || !inner_plug || wearer)
		return ..()
	var/obj/item/dildo/plug/plug = inner_plug
	release_inner_plug(user.drop_location())
	if(!user.put_in_hands(plug))
		plug.forceMove(user.drop_location())
	user.visible_message(span_notice("[user] unscrews \the [plug] from \the [src]."), span_notice("I unscrew \the [plug] from the inner fitting."))
	return TRUE

/obj/item/strapon_harness/double/update_overlays()
	. = ..()
	if(!inner_plug || inner_hole)
		return
	var/mutable_appearance/plug_overlay = mutable_appearance(icon, "strapon_inner")
	plug_overlay.color = inner_plug.color
	plug_overlay.appearance_flags = RESET_COLOR
	. += plug_overlay

/// The wearer's hole the inner plug goes into: her pussy, else her ass.
/obj/item/strapon_harness/double/proc/get_inner_target_hole()
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ)
	if(!wearer)
		return null
	return get_real_organ(wearer, ORGAN_SLOT_VAGINA) || get_real_organ(wearer, ORGAN_SLOT_ANUS)

/obj/item/strapon_harness/double/on_buckled(silent)
	if(!inner_plug || inner_hole)
		return
	var/obj/item/organ/genitals/filling_organ/hole = get_inner_target_hole()
	if(!istype(hole))
		return
	// The holes window's rules decide whether it fits; the harness only does the pushing.
	var/reason = wearer.get_hole_access_block_reason(hole, wearer) || wearer.get_toy_insert_block_reason(hole, inner_plug)
	if(reason)
		to_chat(wearer, span_warning("The inner plug does not go in. [reason]"))
		return
	moving_inner = TRUE
	var/fit = SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_TRY_INSERT, inner_plug, STORAGE_LAYER_INNER, FALSE)
	moving_inner = FALSE
	switch(fit)
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			inner_hole = hole
			update_appearance()
			if(!silent)
				wearer.visible_message(span_love("[wearer] buckles the harness tight, and the inner plug slides up into [wearer.p_their()] [hole.get_toy_hole_word()]."), span_love("I buckle the harness tight, and the inner plug slides up into my [hole.get_toy_hole_word()]."))
			return
	to_chat(wearer, span_warning("The inner plug does not go in."))

/obj/item/strapon_harness/double/on_unbuckled(mob/living/carbon/human/old_wearer, silent)
	if(!inner_plug || !inner_hole)
		return
	var/obj/item/organ/genitals/filling_organ/hole = inner_hole
	inner_hole = null
	moving_inner = TRUE
	SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FORCE_REMOVE, inner_plug, SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, inner_plug))
	inner_plug.forceMove(src)
	moving_inner = FALSE
	update_appearance()
	if(!silent)
		to_chat(old_wearer, span_love("The inner plug slips out of my [hole.get_toy_hole_word()] as the harness comes off."))

/// Something else took the plug: the panel, the holes window, a push-out.
/obj/item/strapon_harness/double/proc/on_inner_plug_moved(datum/source, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	if(moving_inner || inner_plug?.loc == src)
		return
	if(inner_hole && inner_plug.loc == inner_hole)
		return
	release_inner_plug()

/obj/item/strapon_harness/double/proc/on_inner_plug_deleted(datum/source)
	SIGNAL_HANDLER
	release_inner_plug()

/// Forgets the inner plug; with [drop_at], a plug still on the fitting is dropped there.
/obj/item/strapon_harness/double/proc/release_inner_plug(atom/drop_at)
	if(!inner_plug)
		return
	var/obj/item/dildo/plug/plug = inner_plug
	UnregisterSignal(plug, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	inner_plug = null
	inner_hole = null
	if(drop_at && plug.loc == src)
		plug.forceMove(drop_at)
	if(!QDELETED(src))
		update_appearance()

/obj/item/strapon_harness/double/get_wearer_feel()
	if(!inner_plug || !inner_hole)
		return ..()
	var/size_step = max(0, list("small", "medium", "big", "huge").Find(inner_plug.dildo_size) - 1)
	return STRAPON_FEEL_INNER + size_step * STRAPON_FEEL_INNER_PER_SIZE

/obj/item/strapon_harness/double/get_feel_line()
	if(!inner_hole)
		return null
	return pick(
		"The inner plug grinds into my [inner_hole.get_toy_hole_word()] with every thrust I give.",
		"Each thrust pushes the inner plug deeper into me.",
		"I feel the plug inside me shift every time I move my hips.",
	)

// ---- Arcyne ----

/obj/item/strapon_harness/arcyne
	name = "arcyne strap-on harness"
	desc = "A violet strap-on harness with silver runes. The wearer feels the seated toy as her own flesh, and when she climaxes the toy pumps her release into her partner."
	icon_state = "strapon_arcyne"
	base_icon_state = "strapon_arcyne"
	wearer_feel = STRAPON_FEEL_ARCYNE
	wearer_pain_feel = 1
	sellprice = 120

/obj/item/strapon_harness/arcyne/get_feel_line()
	return pick(
		"The runes glow. I feel every squeeze around the toy as if it were my own flesh.",
		"Heat runs from the toy into my hips; it feels like part of me.",
		"I feel the toy throb as if it had blood in it.",
	)

/obj/item/strapon_harness/arcyne/on_wearer_climax(datum/sex_action/action, mob/living/partner)
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = get_real_organ(wearer, ORGAN_SLOT_VAGINA)
	if(seated_toy && partner && vagina?.reagents?.total_volume)
		var/amount = vagina.get_climax_release(ORGASM_LOCATION_INTO)
		if(deliver(vagina.reagents, amount, action, partner, FALSE) > 0)
			wearer.visible_message(span_love("[wearer]'s [seated_toy.name] throbs like living flesh and pumps [wearer.p_their()] release into [partner]!"), span_love("The toy throbs like my own flesh and pumps my release into [partner]!"))
	return ..()

// ---- Crafting ----

/datum/repeatable_crafting_recipe/leather/bdsm_gear/strapon_harness
	name = "strap-on harness"
	output = /obj/item/strapon_harness
	requirements = list(/obj/item/natural/hide/cured = 1, /obj/item/ingot/iron = 1)

/datum/repeatable_crafting_recipe/leather/bdsm_gear/strapon_harness_double
	name = "double-ended strap-on harness"
	output = /obj/item/strapon_harness/double
	requirements = list(/obj/item/natural/hide/cured = 2, /obj/item/ingot/iron = 1)

/datum/repeatable_crafting_recipe/arcyne/strapon_harness
	name = "arcyne strap-on harness"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/strapon_harness = 1,
		/obj/item/natural/melded/t3 = 1,
		/obj/item/gem/amethyst = 1,
		/obj/item/gem/red = 1,
	)
	output = /obj/item/strapon_harness/arcyne
	starting_atom = /obj/item/gem/amethyst
	attacked_atom = /obj/item/strapon_harness
	craftdiff = 4

#undef STRAPON_BULB_VOLUME
#undef STRAPON_SQUEEZE_UNITS
#undef STRAPON_SQUEEZE_COOLDOWN
#undef STRAPON_FEEL_PLAIN
#undef STRAPON_FEEL_INNER
#undef STRAPON_FEEL_INNER_PER_SIZE
#undef STRAPON_FEEL_ARCYNE
#undef STRAPON_SEAT_TIME
#undef STRAPON_CREAK_CHANCE
#undef STRAPON_FLAVOR_COOLDOWN
#undef STRAPON_CHISEL_STRIKE_TIME
#undef STRAPON_CHISEL_BASE_CHANCE
