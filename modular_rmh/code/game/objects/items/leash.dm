// Status effect helpers for leashes
#define STATUS_EFFECT_LEASH_PET /datum/status_effect/leash_pet
#define STATUS_EFFECT_LEASH_OWNER /datum/status_effect/leash_owner
#define MOVESPEED_ID_LEASH_HEEL "LEASH_HEEL"

/// Chain leash ambient step sounds.
#define SFX_LEASH_CHAIN_STEP pick(\
	'sound/foley/footsteps/armor/chain (1).ogg',\
	'sound/foley/footsteps/armor/chain (2).ogg',\
	'sound/foley/footsteps/armor/chain (3).ogg',\
)

///// STATUS EFFECTS /////
// Simple flag effects that display alerts to the leash holder and pet.

/datum/status_effect/leash_owner
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/leash_owner

/atom/movable/screen/alert/status_effect/leash_owner
	name = "Leash Master"
	desc = "You've got a leash, and a cute pet on the other end!"

/datum/status_effect/leash_pet
	id = "leashed"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/leash_pet

/atom/movable/screen/alert/status_effect/leash_pet
	name = "Leashed Pet"
	desc = "You're on the leash now! Be good for your master now.."

/datum/status_effect/leash_pet/on_apply()
	if(!owner.stat)
		to_chat(owner, span_userdanger("You have been leashed!"))
	return ..()

/// Pull a mob towards another mob one step at a time.
/proc/apply_tug_mob_to_mob(mob/living/target, mob/living/source, pull_distance = 1)
	if(QDELETED(target) || QDELETED(source))
		return
	var/current_dist = get_dist(target, source)
	if(!current_dist || current_dist <= pull_distance)
		return
	for(var/i in pull_distance to current_dist)
		if(QDELETED(target))
			return
		step_towards(target, source)

///// LEASH OBJECT /////

/obj/item/leash
	name = "rope leash"
	desc = "A simple rope with a knot at the end for easy attachment onto bindings."
	icon = 'modular_rmh/icons/obj/leashes_collars.dmi'
	icon_state = "leash"
	item_state = "leash"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	equip_sound = 'sound/foley/equip/rummaging-01.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	throw_range = 4
	slot_flags = ITEM_SLOT_HIP // Do NOT use ITEM_SLOT_BELT — it only works with inventory storage items.
	force = 1
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	max_integrity = INTEGRITY_WORST

	/// The mob holding the leash (the master). Null if nobody is holding it.
	var/mob/living/leash_master
	/// The mob attached to the leash (the pet). Null when unattached.
	var/mob/living/leash_pet
	/// The leash component instance on the pet.
	var/datum/component/leash/leash_component
	/// Visual style passed to the leash component beam.
	var/leash_type = "rope"
	/// Max tile distance between master and pet before the leash blocks movement.
	var/leash_distance = 3
	/// Time the pet must struggle to break free.
	var/struggle_time = 3 SECONDS
	/// Cooldown tracker for yanking.
	var/last_yank
	/// Cooldown tracker for choking (feature 5). Separate from yank so you can't accidentally chain chokes.
	var/last_choke
	/// Timer ID for the deferred master-state update so rapid slot swaps don't race.
	var/master_update_timer
	/// Sound played when the leash clips onto a collar.
	var/attach_sound = 'sound/foley/latch.ogg'
	/// Sound played when the leash is yanked.
	var/yank_sound = 'sound/foley/equip/rummaging-01.ogg'
	/// Sound played when the leash snaps or is removed.
	var/snap_sound = 'sound/foley/cloth_rip.ogg'
	/// How much integrity the leash loses per yank or struggle tick. Also used as stamina drain in heel mode.
	var/strain_damage = 5
	/// Whether the pet is in heel (force-follow) mode.
	var/heel_mode = FALSE
	/// How much oxyloss a cmode yank at close range applies (capped at 45 total).
	var/choke_strength = 5

/obj/item/leash/leather
	name = "leather leash"
	desc = "A strip of treated leather with a metal clasp on the end for easy clipping onto bindings."
	icon_state = "leatherleash"
	item_state = "leatherleash"
	leash_type = "leather"
	leash_distance = 2
	struggle_time = 5 SECONDS
	max_integrity = INTEGRITY_STANDARD
	strain_damage = 3
	attach_sound = 'sound/foley/latch.ogg'
	choke_strength = 10

/obj/item/leash/chain
	name = "chain leash"
	desc = "A durable metal chain with a metal clasp on the end for easy clipping onto bindings."
	icon_state = "chainleash"
	item_state = "chainleash"
	resistance_flags = FIRE_PROOF
	equip_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	leash_type = "chain"
	leash_distance = 2
	struggle_time = 8 SECONDS
	max_integrity = INTEGRITY_STRONG
	strain_damage = 1
	attach_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	yank_sound = 'sound/foley/equip/equip_armor_chain.ogg'
	snap_sound = 'sound/foley/dropsound/chain_drop.ogg'
	choke_strength = 15

// ---- Examine (feature 7: tension indicator) ----

/obj/item/leash/examine(mob/user)
	. = ..()
	if(leash_pet)
		. += span_notice("It's connected to [leash_pet]'s neck.")
		// Tension indicator.
		var/dist = leash_master ? get_dist(leash_pet, leash_master) : 0
		if(dist >= leash_distance)
			. += span_danger("The leash is straining!")
		else if(dist >= leash_distance - 1 && dist > 1)
			. += span_warning("The leash is taut.")
		else
			. += span_info("The leash hangs slack.")
		// Durability indicator.
		if(get_integrity() < max_integrity * 0.5)
			. += span_warning("It looks like it's about to snap!")
		else if(get_integrity() < max_integrity * 0.75)
			. += span_warning("It's showing signs of wear.")
		// Heel mode indicator.
		if(heel_mode)
			. += span_notice("[leash_pet] is heeling obediently.")
	else
		. += "It's not connected to anything."

/obj/item/leash/Destroy()
	detach_pet()
	return ..()

// ---- Attach / Detach helpers ----
// All state changes for connecting and disconnecting go through these two procs
// so cleanup is never missed.

/// Attach this leash to [target], with [holder] as master. Accepts any mob/living — works for
/// both carbon players and simple animals. Assumes validation already passed.
/obj/item/leash/proc/attach_pet(mob/living/target, mob/living/holder)
	leash_pet = target
	target.apply_status_effect(/datum/status_effect/leash_pet)
	w_class = WEIGHT_CLASS_BULKY // Prevent storing in backpacks while attached.

	// Only set a master if someone else is leashing the pet.
	if(holder != target)
		leash_master = holder
		holder.apply_status_effect(/datum/status_effect/leash_owner)

	// Create the visual / distance-enforcement component on the pet.
	leash_component = target.AddComponent( \
		/datum/component/leash, \
		src, \
		leash_distance, \
		null, \
		null, \
		leash_type, \
		'modular_rmh/icons/effect/beam.dmi', \
		FALSE, \
		CALLBACK(src, PROC_REF(detach_pet)), \
	)

	// Listen for collar removal instead of polling every tick.
	RegisterSignal(target, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_pet_unequipped))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_pet_examined))
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(on_pet_deleted))

	// Feature 9: Chain leash walking sounds.
	if(leash_type == "chain")
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_pet_step))

	playsound(target, attach_sound, 50, TRUE)

/// Fully disconnect the pet, clean up all signals and status effects.
/// Safe to call multiple times or when already detached.
/obj/item/leash/proc/detach_pet(silent = FALSE)
	if(!leash_pet)
		return

	var/mob/living/old_pet = leash_pet
	var/mob/living/old_master = leash_master

	// Disable heel mode first so signals get cleaned up.
	if(heel_mode)
		disable_heel(silent = TRUE)

	// Unregister everything from the pet. Build the signal list dynamically.
	var/list/pet_signals = list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_PARENT_EXAMINE, COMSIG_PARENT_QDELETING)
	if(leash_type == "chain")
		pet_signals += COMSIG_MOVABLE_MOVED
	UnregisterSignal(old_pet, pet_signals)
	old_pet.remove_status_effect(/datum/status_effect/leash_pet)

	if(leash_component)
		QDEL_NULL(leash_component)

	if(old_master)
		old_master.remove_status_effect(/datum/status_effect/leash_owner)

	leash_master = null
	leash_pet = null
	w_class = initial(w_class)

	// Cancel any pending master-state timer.
	if(master_update_timer)
		deltimer(master_update_timer)
		master_update_timer = null

	if(!silent && !QDELETED(src))
		playsound(old_pet, snap_sound, 40, TRUE)

/// Called when the pet is deleted — clean up without trying to message them.
/obj/item/leash/proc/on_pet_deleted()
	SIGNAL_HANDLER
	detach_pet(silent = TRUE)

// ---- Durability ----

/// Apply strain to the leash. If it breaks, detach with a message.
/obj/item/leash/proc/apply_strain(amount)
	if(!amount || QDELETED(src))
		return
	take_damage(amount, BRUTE, NONE, FALSE)

/obj/item/leash/atom_destruction(damage_flag)
	if(leash_pet)
		var/mob/living/old_pet = leash_pet
		detach_pet(silent = TRUE)
		playsound(old_pet, snap_sound, 60, TRUE)
		old_pet.visible_message( \
			span_warning("The [src.name] snaps apart!"), \
			span_warning("Your leash snaps apart!"), \
		)
	return ..()

// ---- Signal-driven collar check (replaces SSfastprocess polling) ----

/// Fired when the pet unequips any item. If they lost their collar, they slip free.
/// Simple mobs are leashed without collars, so this check doesn't apply to them.
/obj/item/leash/proc/on_pet_unequipped(mob/living/source, obj/item/item, force, newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER
	if(!leash_pet)
		return
	// Simple mobs don't use collars — they can't slip free this way.
	if(!iscarbon(leash_pet))
		return
	// Only care if they lost their neck item.
	if(leash_pet.get_item_by_slot(ITEM_SLOT_NECK))
		return // Still wearing something on the neck — no problem.
	// Also check chain handcuffs as a valid anchor.
	if(istype(leash_pet.get_item_by_slot(ITEM_SLOT_HANDCUFFED), /obj/item/rope/chain))
		return
	// The pet has slipped their collar.
	var/mob/living/escaped_pet = leash_pet
	detach_pet()
	escaped_pet.visible_message( \
		span_notice("[escaped_pet] has slipped out of [escaped_pet.p_their()] collar!"), \
		span_notice("You have slipped free of your collar!"), \
	)

// ---- Interaction procs ----

/// Called when someone clicks a mob with the leash.
/// Accepts mob/living so it works on both carbon and simple_animal.
/obj/item/leash/attack(mob/living/target, mob/living/user)
	// Already leashed to this target — toggle off.
	if(leash_pet == target)
		user.visible_message(span_danger("[user] unleashes [target]."), span_danger("You unleash [target]."))
		if(!do_after(user, 1 SECONDS, src))
			return
		detach_pet()
		return

	// Target has a leash component from another leash.
	if(target.GetComponent(/datum/component/leash))
		to_chat(user, span_notice("[target] has already been leashed."))
		return

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		if(carbon_target.cmode && carbon_target.mobility_flags & MOBILITY_STAND)
			to_chat(user, span_warning("I can't leash [target], [target.p_they()] [target.p_are()] too tense!"))
			return

	if(leash_pet)
		to_chat(user, span_warning("This leash is already attached to [leash_pet]!"))
		return

	// Simple mobs (animals) can be leashed directly — they can't wear collars.
	// Humans require a collar or chain binding.
	var/skip_collar_check = !iscarbon(target)

	if(!skip_collar_check)
		// Check for a valid collar or chain binding.
		var/obj/item/collar = target.get_item_by_slot(ITEM_SLOT_NECK)
		var/has_collar = collar?.leashable
		var/has_chain = istype(target.get_item_by_slot(ITEM_SLOT_HANDCUFFED), /obj/item/rope/chain)
		if(!has_collar && !has_chain)
			to_chat(user, span_notice("[target] needs a collar before you can attach a leash to it."))
			return

	// Begin the leash attempt with a visible do_after.
	target.visible_message( \
		span_warning("[user] raises \the [src] to [target]'s neck!"), \
		span_warning("[user] begins raising \the [src] to my neck!"), \
		ignored_mobs = user, \
	)
	to_chat(user, span_warning("I begin raising \the [src] to [target]'s neck!"))

	var/leash_time = target.handcuffed ? 5 : 50
	if(!do_after(user, leash_time, target, IGNORE_HELD_ITEM))
		return

	log_combat(user, target, "leashed", addition="playfully")
	attach_pet(target, user)

	user.visible_message( \
		span_warning("[target] has been leashed by [user]!"), \
		span_warning("You have hooked a leash onto [target]!"), \
	)

/// Right-click in hand to unleash.
/obj/item/leash/attack_hand_secondary(mob/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!leash_pet)
		return
	user.visible_message(span_danger("[user] unleashes [leash_pet]."), span_danger("You unleash [leash_pet]."))
	if(!do_after(user, 1 SECONDS, src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	detach_pet()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Use in hand: cmode = yank/choke, no cmode = toggle heel.
/obj/item/leash/attack_self(mob/living/user)
	if(!leash_pet || !leash_master)
		return
	if(user != leash_master)
		return

	if(user.cmode)
		// Feature 5: If adjacent, choke instead of yank.
		if(get_dist(leash_pet, leash_master) <= 1)
			choke_pet(user)
			return
		// Normal yank.
		if(world.time < last_yank + 15)
			return
		apply_tug_mob_to_mob(leash_pet, leash_master, 1)
		log_combat(leash_master, leash_pet, "leash-yanked")
		playsound(src, yank_sound, 50, TRUE)
		apply_strain(strain_damage)
		leash_pet.Knockdown(2 SECONDS)
		leash_pet.visible_message(span_warning("[leash_master] harshly yanks [leash_pet] down with \the [src], knocking them over."))
		apply_arousal_effects(10, 15) // Feature 8: higher arousal for violent yank.
		last_yank = world.time
	else
		// Feature 2: Toggle heel mode.
		if(heel_mode)
			disable_heel()
		else
			enable_heel(user)

// ---- Feature 5: Choke on adjacent hard yank ----

/// Choke the pet when yanked in cmode at close range. Separate 3-second cooldown.
/// Oxyloss is capped at 45 total so the pet can never die from choking alone.
/obj/item/leash/proc/choke_pet(mob/living/user)
	if(world.time < last_choke + 50) // 3 second cooldown
		to_chat(user, span_warning("You just choked them, give it a moment."))
		return
	if(!leash_pet || QDELETED(leash_pet))
		return

	// Cap oxyloss so it never kills.
	var/oxy_to_apply = min(choke_strength, max(0, 45 - leash_pet.getOxyLoss()))
	if(oxy_to_apply > 0)
		leash_pet.adjustOxyLoss(oxy_to_apply)

	leash_pet.Stun(1 SECONDS)
	INVOKE_ASYNC(leash_pet, TYPE_PROC_REF(/mob, emote), "choke")
	playsound(src, yank_sound, 50, TRUE)
	apply_strain(strain_damage)
	log_combat(leash_master, leash_pet, "leash-choked")

	leash_pet.visible_message( \
		span_danger("[leash_master] yanks \the [src] tight around [leash_pet]'s neck, choking them!"), \
		span_userdanger("[leash_master] yanks your leash tight, choking you!"), \
	)

	apply_arousal_effects(10, 15) // Feature 8: high arousal for choke.
	last_choke = world.time

// ---- Feature 6: Kneel yank via AltClick ----

/obj/item/leash/AltClick(mob/user)
	. = ..()
	if(!leash_pet || !leash_master)
		return
	if(user != leash_master)
		return
	if(world.time < last_yank + 15)
		return

	playsound(src, yank_sound, 40, TRUE)
	leash_pet.set_resting(TRUE, silent = FALSE)
	leash_pet.visible_message( \
		span_warning("[leash_master] yanks [leash_pet] to their knees with \the [src]!"), \
		span_warning("[leash_master] yanks you to your knees!"), \
	)
	apply_arousal_effects(3, 5) // Feature 8: small arousal for kneel.
	last_yank = world.time

// ---- Feature 2+3: Heel mode (force-follow) + stamina drag ----

/// Enable heel mode — the pet follows the master's movement.
/obj/item/leash/proc/enable_heel(mob/living/user)
	if(!leash_pet || !leash_master || heel_mode)
		return
	heel_mode = TRUE
	RegisterSignal(leash_master, COMSIG_MOVABLE_MOVED, PROC_REF(on_master_move))
	leash_pet.add_movespeed_modifier(MOVESPEED_ID_LEASH_HEEL, multiplicative_slowdown = 1)
	to_chat(leash_master, span_notice("You tug the leash short. [leash_pet] will heel now."))
	to_chat(leash_pet, span_warning("[leash_master] tugs the leash short. You must heel."))
	playsound(src, yank_sound, 40, TRUE)

/// Disable heel mode and clean up signals/movespeed.
/obj/item/leash/proc/disable_heel(silent = FALSE)
	if(!heel_mode)
		return
	heel_mode = FALSE
	if(leash_master)
		UnregisterSignal(leash_master, COMSIG_MOVABLE_MOVED)
	if(leash_pet)
		leash_pet.remove_movespeed_modifier(MOVESPEED_ID_LEASH_HEEL)
	if(!silent)
		if(leash_master)
			to_chat(leash_master, span_notice("You loosen the leash. [leash_pet] is free to roam."))
		if(leash_pet)
			to_chat(leash_pet, span_notice("The leash loosens. You no longer have to heel."))

/// Signal handler: master moved while heel mode is active.
/obj/item/leash/proc/on_master_move()
	SIGNAL_HANDLER
	if(!heel_mode || !leash_pet || !leash_master)
		return
	if(get_dist(leash_pet, leash_master) > 1)
		addtimer(CALLBACK(src, PROC_REF(heel_step)), 2, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Deferred heel step: move the pet one tile toward the master.
/obj/item/leash/proc/heel_step()
	if(!heel_mode || !leash_pet || !leash_master)
		return
	if(get_dist(leash_pet, leash_master) <= 1)
		return

	// Feature 3: If pet is in cmode, drain master stamina. Exhaustion breaks heel.
	if(iscarbon(leash_pet))
		var/mob/living/carbon/carbon_pet = leash_pet
		if(carbon_pet.cmode)
			if(!leash_master.adjust_stamina(strain_damage))
				// Master exhausted — pet breaks free of heel.
				leash_master.visible_message( \
					span_warning("[leash_pet] resists the leash, exhausting [leash_master]!"), \
					span_warning("[leash_pet] is too strong! You can't hold the leash taut!"), \
				)
				disable_heel()
				return

	step_towards(leash_pet, leash_master)

// ---- Feature 9: Chain walking sounds ----

/// Signal handler: pet moved while leashed with a chain. Plays a subtle chain rattle.
/obj/item/leash/proc/on_pet_step()
	SIGNAL_HANDLER
	if(!leash_pet || QDELETED(leash_pet))
		return
	playsound(leash_pet, SFX_LEASH_CHAIN_STEP, 15, TRUE)

// ---- Feature 8: Arousal integration (sadist/masochist gated) ----

/// Apply arousal effects to master (if sadist) and pet (if masochist).
/// Only triggers when the relevant vice quirk is present.
/obj/item/leash/proc/apply_arousal_effects(master_amount, pet_amount)
	if(!leash_master || !leash_pet)
		return
	// Master: sadist gets aroused and sated from dominating.
	if(ishuman(leash_master))
		var/mob/living/carbon/human/master_human = leash_master
		if(master_human.has_quirk(/datum/quirk/negative/addiction/sadist))
			SEND_SIGNAL(leash_master, COMSIG_SEX_ADJUST_AROUSAL, master_amount)
			master_human.sate_addiction(/datum/quirk/negative/addiction/sadist)
	// Pet: masochist gets aroused and sated from being dominated.
	if(ishuman(leash_pet))
		var/mob/living/carbon/human/pet_human = leash_pet
		if(pet_human.has_quirk(/datum/quirk/negative/addiction/masochist))
			SEND_SIGNAL(leash_pet, COMSIG_SEX_ADJUST_AROUSAL, pet_amount)
			pet_human.sate_addiction(/datum/quirk/negative/addiction/masochist)

// ---- Feature 4: Slave collar command radial menu via middle-click ----

/obj/item/leash/MiddleClick(mob/user, params)
	if(!leash_pet || !leash_master)
		return ..()
	if(user != leash_master)
		return ..()
	// Check if the pet is wearing a slave collar.
	var/obj/item/clothing/neck/slave_collar/collar = leash_pet.get_item_by_slot(ITEM_SLOT_NECK)
	if(!istype(collar))
		return ..()
	var/list/command_options = collar.get_radial_command_options()
	var/list/choices = list()
	for(var/display_name in command_options)
		choices[display_name] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_slice")
	var/chosen = show_radial_menu(user, src, choices, tooltips = TRUE, require_near = TRUE)
	if(!chosen || !leash_pet || !leash_master)
		return
	var/internal_key = command_options[chosen]
	if(!internal_key)
		return
	if(collar.perform_command(internal_key, user, src, "leash"))
		to_chat(user, span_notice("You tug the leash with authority — the command takes hold."))
	else
		to_chat(user, span_warning("The collar doesn't respond."))
	return

/// Clicking on a structure with the leash ties the pet to it.
/obj/item/leash/afterattack(atom/target, mob/living/user, proximity_flag, list/modifiers)
	. = ..()
	if(!proximity_flag)
		return
	if(!leash_pet)
		return
	if(!isstructure(target))
		return
	// Already tied to something — the master IS the structure.
	if(!ismob(leash_master))
		to_chat(user, span_warning("The leash is already tied to something!"))
		return
	user.visible_message( \
		span_notice("[user] ties \the [src] to [target]."), \
		span_notice("You tie \the [src] to [target]."), \
	)
	playsound(target, attach_sound, 50, TRUE)
	// Swap master from user to the structure.
	if(leash_master)
		leash_master.remove_status_effect(/datum/status_effect/leash_owner)
	leash_master = null
	// Drop the leash from hand so it's on the ground at the tie-off point.
	user.dropItemToGround(src, silent = TRUE)
	forceMove(target.loc)

/// The pet can struggle free via the examine link. Tension is shown to all viewers.
/obj/item/leash/proc/on_pet_examined(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	// Tension indicator visible to everyone.
	var/dist = leash_master ? get_dist(leash_pet, leash_master) : 0
	if(dist >= leash_distance)
		examine_list += span_danger("The leash is straining against [leash_pet.p_their()] collar!")
	else if(dist >= leash_distance - 1 && dist > 1)
		examine_list += span_warning("The leash between [leash_pet] and [leash_pet.p_their()] master is taut.")
	// Only the pet sees the struggle link.
	if(user == leash_pet)
		examine_list += "<a href='byond://?src=[REF(src)];pull_harpoon=1'>You are leashed!</a>"

/obj/item/leash/Topic(href, href_list)
	. = ..()
	if(!href_list["pull_harpoon"])
		return
	if(usr != leash_pet)
		return
	leash_pet.visible_message( \
		span_danger("[leash_pet] starts to struggle against their leash!"), \
		span_danger("You start to struggle against your leash!"), \
	)
	if(!do_after(leash_pet, struggle_time, src))
		return
	apply_strain(strain_damage * 3) // Big burst of damage from a successful struggle.
	// If the leash didn't snap from the strain, force-detach anyway.
	if(!QDELETED(src) && leash_pet)
		detach_pet()

// ---- Drop / Equip (consolidated master-state update) ----

/// Deferred check that sets or clears `leash_master` based on who is currently holding us.
/// Called via timer from both dropped() and equipped() so rapid slot swaps don't race.
/obj/item/leash/proc/update_master_state()
	master_update_timer = null
	if(!leash_pet)
		return

	// Figure out who, if anyone, is holding us right now.
	var/mob/living/holder = null
	if(ismob(loc))
		var/mob/living/mob_loc = loc
		if(mob_loc.is_holding(src) || mob_loc.get_item_by_slot(ITEM_SLOT_HIP) == src)
			holder = mob_loc

	// Pet picked up their own leash — no master.
	if(holder == leash_pet)
		holder = null

	// No change needed.
	if(holder == leash_master)
		return

	// Clear old master.
	if(leash_master)
		leash_master.remove_status_effect(/datum/status_effect/leash_owner)
		leash_master = null

	// Set new master.
	if(holder)
		leash_master = holder
		leash_master.apply_status_effect(/datum/status_effect/leash_owner)

/obj/item/leash/proc/schedule_master_update()
	if(master_update_timer)
		deltimer(master_update_timer)
	master_update_timer = addtimer(CALLBACK(src, PROC_REF(update_master_state)), 2, TIMER_STOPPABLE)

/obj/item/leash/dropped(mob/user, silent)
	. = ..()
	if(!leash_pet)
		return
	schedule_master_update()

/obj/item/leash/equipped(mob/user, slot, initial = FALSE, silent = FALSE)
	. = ..()
	if(!leash_pet)
		return
	schedule_master_update()

// ---- Utility procs for travel tiles and other systems ----

/// Returns TRUE if [L] is leashed by someone else (not self-leashed).
/proc/leashed_by_other(mob/living/L)
	if(!L.has_status_effect(/datum/status_effect/leash_pet))
		return FALSE
	// Check if L is holding their own leash (hand or hip).
	for(var/obj/item/leash/held_leash in L.contents)
		if(held_leash.leash_pet == L)
			if(L.is_holding(held_leash) || L.get_item_by_slot(ITEM_SLOT_HIP) == held_leash)
				return FALSE
	return TRUE

/// Returns a list of leashed mobs controlled by master [L].
/proc/get_master_leashed_mobs(mob/living/L, do_not_remove = TRUE)
	var/list/result = list()
	if(!L.has_status_effect(/datum/status_effect/leash_owner))
		return result
	for(var/obj/item/leash/leash in L.contents)
		if(leash.leash_master != L || !leash.leash_pet)
			continue
		var/mob/living/pet = leash.leash_pet
		if(pet in view(5, L))
			result += pet
		else if(!do_not_remove)
			// Pet is out of view; detach so we don't teleport them across z-levels.
			leash.detach_pet()
	return result

///// CATBELL /////

/obj/item/catbell
	name = "catbell"
	desc = "A small jingly catbell."
	icon = 'modular_rmh/icons/obj/leashes_collars.dmi'
	icon_state = "catbell"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	throw_range = 4
	force = 1
	throwforce = 1
	resistance_flags = FIRE_PROOF
	w_class = WEIGHT_CLASS_TINY
	var/last_ring

/obj/item/catbell/cow
	name = "cowbell"
	desc = "A small jingly cowbell"
	icon_state = "cowbell"
	dropshrink = 0.75

/obj/item/catbell/attack_self(mob/living/user)
	if(world.time < last_ring + 15)
		return
	user.visible_message(span_info("[user] starts ringing the [src]."))
	playsound(src, 'sound/items/jinglebell (1).ogg', 100, extrarange = 8, ignore_walls = TRUE)
	flick("bell_commonpressed", src)
	last_ring = world.time

/obj/item/catbell/attack(mob/living/carbon/target, mob/living/user)
	var/obj/item/clothing/neck/leathercollar/collar = target.get_item_by_slot(ITEM_SLOT_NECK)
	if(!istype(collar))
		to_chat(user, "[target] needs a collar to attach the bell!")
		return
	if(collar.bell)
		to_chat(user, "[target]'s collar already has a bell!")
		return
	target.visible_message( \
		span_warning("[user] raises \the [src] to [target]'s neck!"), \
		span_warning("[user] begins raising \the [src] to my neck!"), \
		span_hear("I hear \a [src] jingling."), \
		ignored_mobs = user, \
	)
	to_chat(user, span_warning("I begin raising \the [src] to [target]'s neck!"))
	if(!do_after(user, target.handcuffed ? 0.5 SECONDS : 5 SECONDS, target, IGNORE_HELD_ITEM))
		return
	log_combat(user, target, "put a bell on")
	user.visible_message( \
		span_warning("[target] has had \a [src] clipped onto [target.p_their()] [collar.name] by [user]!"), \
		span_warning("I clip \a [src] onto [target]'s [collar.name]!"), \
	)
	collar.bell = TRUE
	collar.bellsound = TRUE
	collar.AddComponent(/datum/component/squeak, list(SFX_COLLARJINGLE), 50, 100, 1)
	if(istype(src, /obj/item/catbell/cow))
		collar.icon_state = "cowbellcollar"
		collar.desc = "A leather collar with a jingly cowbell attached."
		collar.name = "cowbell collar"
	else
		collar.icon_state = "catbellcollar"
		collar.desc = "A leather collar with a jingling catbell attached."
		collar.name = "catbell collar"
	target.update_inv_neck()
	forceMove(collar) // Move bell inside collar so salvaging returns it.

///// CRAFTING RECIPES /////

/datum/repeatable_crafting_recipe/leather/leash
	name = "leather leash"
	requirements = list(
		/obj/item/natural/hide/cured = 1
	)
	tool_usage = list(
		/obj/item/needle = list("starts to sew", "start to sew")
	)
	starting_atom = /obj/item/needle
	attacked_atom = /obj/item/natural/hide/cured
	output = /obj/item/leash/leather
	craft_time = 10 SECONDS
	crafting_message = "starts sewing a leather leash"
	craftdiff = 0

/datum/repeatable_crafting_recipe/survival/rope_leash
	name = "rope leash"
	requirements = list(
		/obj/item/rope = 1
	)
	tool_usage = list(
		/obj/item/needle = list("starts to sew", "start to sew")
	)
	starting_atom = /obj/item/needle
	attacked_atom = /obj/item/rope
	output = /obj/item/leash
	craft_time = 3 SECONDS
	crafting_message = "starts to sew a rope leash"

/datum/repeatable_crafting_recipe/survival/chain_leash
	name = "chain leash"
	requirements = list(
		/obj/item/rope/chain = 1
	)
	starting_atom = /obj/item/rope/chain
	attacked_atom = /obj/item/rope/chain
	output = /obj/item/leash/chain
	craft_time = 2 SECONDS
	crafting_message = "starts linking a chain leash"
