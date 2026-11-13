// Lockable chastity devices worn as underwear; while fitted they block and hide the genitals they cover.

/// Seconds per hammer blow when chiselling a lock open.
#define CHASTITY_CHISEL_STRIKE_TIME (6 SECONDS)
/// Base percent chance per blow to break the lock, before luck.
#define CHASTITY_CHISEL_BASE_CHANCE 25

GLOBAL_VAR_INIT(chastity_lock_serial, 0)

/obj/item/clothing/undies/chastity
	abstract_type = /obj/item/clothing/undies/chastity
	name = "chastity device"
	desc = "A locking iron device worn over the loins."
	icon = 'modular_rmh/icons/obj/lewd/chastity.dmi'
	mob_overlay_icon = 'modular_rmh/icons/obj/lewd/chastity_onmob.dmi'
	icon_state = "cage_belt"
	item_state = "cage_belt"
	slot_flags = ITEM_SLOT_UNDER_BOTTOM
	resistance_flags = INDESTRUCTIBLE
	muteinmouth = FALSE
	gendered = TRUE
	loadout_blacklisted = TRUE
	fluid_capacity = 0
	// Metal never gets wet; wetable clothing would also claim the wearer's moved signal from the jingle.
	wetable = FALSE
	sewrepair = null
	salvage_result = null
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	equip_delay_other = 5 SECONDS
	strip_delay = 5 SECONDS
	sellprice = 15
	lock = /datum/lock/key/chastity
	lock_sound = 'sound/foley/lockmetal.ogg'
	unlock_sound = 'sound/foley/lockmetal.ogg'
	rattle_sound = 'sound/foley/lockrattlemetal.ogg'
	/// Organ slots the fitted device blocks from every sex action.
	var/list/blocked_organ_slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
	/// Organ slots whose sprites the fitted device hides, even genitals drawn over clothes.
	var/list/hidden_organ_slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_TESTICLES, ORGAN_SLOT_VAGINA)
	/// Every organ slot the wearer needs for the device to fit.
	var/list/required_organ_slots
	/// Body hiding flags; parent undies reset flags_inv on every equip.
	var/worn_flags_inv = HIDECROTCH
	/// Flat cages press everything flat.
	var/flat_cage = FALSE
	/// Key made alongside the device.
	var/key_type = /obj/item/key/chastity
	/// Whether Initialize leaves a matching key beside the device.
	var/spawn_with_key = TRUE
	/// The one key made for this device; hard mode accepts nothing else.
	var/datum/weakref/generated_key_ref
	/// Who wears the device right now.
	var/mob/living/carbon/human/wearer
	/// Whether an inward plug sits inside the device, for "Work insert".
	var/has_insert = FALSE

/obj/item/clothing/undies/chastity/Initialize(mapload, ...)
	lockids = list("chastity_[++GLOB.chastity_lock_serial]")
	. = ..()
	flags_inv = worn_flags_inv
	RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_pre_unequip))
	if(spawn_with_key && loc)
		make_key(drop_location())

/obj/item/clothing/undies/chastity/Destroy()
	set_wearer(null)
	generated_key_ref = null
	return ..()

/obj/item/clothing/undies/chastity/OnCrafted(dirin, mob/user)
	// The lock is built in and matches the key; hide it so the parent cannot strip it.
	var/datum/lock/own_lock = lock
	lock = null
	. = ..()
	lock = own_lock

/obj/item/clothing/undies/chastity/equipped(mob/living/carbon/user, slot)
	. = ..()
	flags_inv = worn_flags_inv
	set_wearer(slot == ITEM_SLOT_UNDER_BOTTOM ? user : null)

/obj/item/clothing/undies/chastity/dropped(mob/user)
	. = ..()
	flags_inv = worn_flags_inv
	set_wearer(null)

/// TRUE if the wearer's [slot] holds a strapon, which rides outside the device.
/obj/item/clothing/undies/chastity/proc/holds_strapon(slot)
	return wearer?.getorganslot(slot) && !get_real_organ(wearer, slot)

/obj/item/clothing/undies/chastity/blocks_organ_use(slot)
	return (slot in blocked_organ_slots) && !holds_strapon(slot)

/obj/item/clothing/undies/chastity/hides_organ_slot(slot)
	return (slot in hidden_organ_slots) && !holds_strapon(slot)

/obj/item/clothing/undies/chastity/examine(mob/user)
	. = ..()
	var/datum/lock/key/chastity/key_lock = lock
	if(key_lock?.lock_broken)
		. += span_warning("Its lock has been chiselled apart.")
	else
		. += span_notice("It is [locked() ? "locked" : "unlocked"].")
	var/list/sealed = list()
	if(ORGAN_SLOT_PENIS in blocked_organ_slots)
		sealed += "a cock"
	if(ORGAN_SLOT_VAGINA in blocked_organ_slots)
		sealed += "a pussy"
	if(ORGAN_SLOT_ANUS in blocked_organ_slots)
		sealed += "the rear"
	if(length(sealed))
		. += span_notice("Fitted, it seals away [english_list(sealed)].")

/obj/item/clothing/undies/chastity/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(ishuman(interacting_with) && !can_fit_on(interacting_with, user, TRUE))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/clothing/undies/chastity/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(slot == ITEM_SLOT_UNDER_BOTTOM && !can_fit_on(M, equipper, !disable_warning || (equipper && equipper != M)))
		return FALSE
	return ..()

/// TRUE if the device may go on [target]; [fitter] is whoever puts it there.
/obj/item/clothing/undies/chastity/proc/can_fit_on(mob/living/target, mob/living/fitter, feedback = FALSE)
	var/mob/living/carbon/human/human_target = target
	if(!istype(human_target))
		return FALSE
	var/mob/living/told = fitter || target
	var/whose = (told == target) ? "my" : "[target]'s"
	if(locked())
		if(feedback)
			to_chat(told, span_warning("\The [src] is locked shut."))
		return FALSE
	if(!target.allows_chastity_play())
		if(feedback)
			to_chat(told, span_warning(told == target ? "I want nothing to do with chastity play." : "[target] wants nothing to do with chastity play."))
		return FALSE
	if(fitter && fitter != target && !fitter.allows_chastity_play())
		if(feedback)
			to_chat(fitter, span_warning("I want nothing to do with chastity play."))
		return FALSE
	for(var/slot in required_organ_slots)
		if(!get_real_organ(human_target, slot))
			if(feedback)
				to_chat(told, span_warning("\The [src] doesn't fit [whose] body."))
			return FALSE
	return TRUE

/obj/item/clothing/undies/chastity/proc/set_wearer(mob/living/carbon/human/new_wearer)
	if(wearer == new_wearer)
		return
	if(wearer)
		UnregisterSignal(wearer, list(COMSIG_ATOM_ITEM_INTERACTION, COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED))
		clear_moods(wearer)
	wearer = new_wearer
	jingle_steps = 0
	if(!wearer)
		return
	RegisterSignal(wearer, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_wearer_item_interaction))
	RegisterSignal(wearer, COMSIG_PARENT_QDELETING, PROC_REF(on_wearer_deleted))
	RegisterSignal(wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_wearer_moved))
	refresh_moods()
	var/obj/item/key/chastity/key = get_generated_key()
	if(key)
		key.name = "[wearer.real_name]'s chastity key"

/obj/item/clothing/undies/chastity/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	set_wearer(null)

/// Keys, lockpicks and chisels used on the wearer's groin reach the worn lock.
/obj/item/clothing/undies/chastity/proc/on_wearer_item_interaction(datum/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(user.cmode || user.zone_selected != BODY_ZONE_PRECISE_GROIN)
		return NONE
	if(!can_be_forced() && (istype(tool, /obj/item/weapon/chisel) || istype(tool, /obj/item/lockpick) || tool.can_lock_interact()))
		to_chat(user, span_warning(pick_chastity_string("chastity_lock_messages.json", "arcane_denial")))
		return ITEM_INTERACT_BLOCKING
	if(istype(tool, /obj/item/weapon/chisel))
		INVOKE_ASYNC(src, PROC_REF(try_chisel_off), user, tool)
		return ITEM_INTERACT_SUCCESS
	var/datum/lock/key/chastity/key_lock = lock
	if(!istype(key_lock))
		return NONE
	if(!tool.can_lock_interact() && !is_type_in_list(tool, key_lock.lockpicks))
		return NONE
	return key_lock.interact_wrap(src, user, tool, modifiers) || ITEM_INTERACT_BLOCKING

/obj/item/clothing/undies/chastity/proc/on_pre_unequip(datum/source, force, atom/newloc, no_move, invdrop, silent)
	SIGNAL_HANDLER
	if(force || !wearer || !locked())
		return NONE
	if(!silent)
		to_chat(wearer, span_warning("\The [src] is locked on."))
	return COMPONENT_ITEM_BLOCK_UNEQUIP

/obj/item/clothing/undies/chastity/canStrip(mob/stripper, mob/owner)
	if(wearer && locked())
		return FALSE
	return ..()

/obj/item/clothing/undies/chastity/pre_lock_interact(mob/living/user)
	if(!wearer)
		return TRUE
	if(wearer.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, user))
		to_chat(user, span_warning("[user == wearer ? "My" : "[wearer]'s"] armor is in the way."))
		return FALSE
	return TRUE

/obj/item/clothing/undies/chastity/on_lock(mob/living/user, obj/item, silent = FALSE)
	announce_lock_change(user, TRUE, silent)

/obj/item/clothing/undies/chastity/on_unlock(mob/living/user, obj/item, silent = FALSE)
	announce_lock_change(user, FALSE, silent)

/obj/item/clothing/undies/chastity/proc/announce_lock_change(mob/living/user, now_locked, silent)
	var/verb_text = now_locked ? "locks" : "unlocks"
	if(!silent)
		playsound(src, now_locked ? lock_sound : unlock_sound, 50)
	if(wearer)
		to_chat(wearer, now_locked ? span_warning(pick_chastity_string("chastity_lock_messages.json", "lock_click")) : span_notice(pick_chastity_string("chastity_lock_messages.json", "unlock_click")))
	if(!wearer)
		user.visible_message(span_notice("[user] [verb_text] \the [src]."), span_notice("I [now_locked ? "lock" : "unlock"] \the [src]."))
		return
	if(user == wearer)
		user.visible_message(span_notice("[user] [verb_text] [user.p_their()] [name]."), span_notice("I [now_locked ? "lock" : "unlock"] my [name]."))
		return
	user.visible_message(span_notice("[user] [verb_text] [wearer]'s [name]."), span_notice("I [now_locked ? "lock" : "unlock"] [wearer]'s [name]."))

/obj/item/clothing/undies/chastity/lock_failed(mob/living/user, silent = FALSE, message)
	if(!message && is_hardmode_active())
		message = pick_chastity_string("chastity_lock_messages.json", "hardmode_denial")
	return ..(user, silent, message)

/obj/item/clothing/undies/chastity/can_be_picked()
	if(is_hardmode_active())
		return FALSE
	var/datum/lock/key/chastity/key_lock = lock
	if(key_lock?.lock_broken)
		return FALSE
	return ..()

/obj/item/clothing/undies/chastity/picked(mob/living/user, obj/lockpick_used, skill_level, difficulty)
	. = ..()
	if(wearer && wearer != user)
		to_chat(wearer, span_notice("Something clicks inside \the [src]. It is unlocked."))

/// FALSE for devices that ignore keys, lockpicks and chisels.
/obj/item/clothing/undies/chastity/proc/can_be_forced()
	return TRUE

/// Hard mode is the wearer's own choice, read fresh every time.
/obj/item/clothing/undies/chastity/proc/is_hardmode_active()
	return !!wearer?.get_chastity_pref(/datum/erp_preference/boolean/chastity_hardmode)

/obj/item/clothing/undies/chastity/proc/get_generated_key()
	RETURN_TYPE(/obj/item/key/chastity)
	return generated_key_ref?.resolve()

/// TRUE for the device's own key, or a keyring holding it.
/obj/item/clothing/undies/chastity/proc/is_generated_key(obj/item/tool)
	var/obj/item/key/chastity/key = get_generated_key()
	if(!key || !tool)
		return FALSE
	if(tool == key)
		return TRUE
	return istype(tool, /obj/item/storage/keyring) && (key in tool.contents)

/// Makes the device's one key at [where]; returns it.
/obj/item/clothing/undies/chastity/proc/make_key(atom/where)
	var/obj/item/key/chastity/key = new key_type(where)
	var/datum/lock/key/chastity/key_lock = lock
	key.lockids = key_lock?.lockid_list?.Copy()
	key.device_ref = WEAKREF(src)
	generated_key_ref = WEAKREF(key)
	return key

/obj/item/clothing/undies/chastity/proc/try_chisel_off(mob/living/user, obj/item/weapon/chisel/chisel)
	var/mob/living/carbon/human/target = wearer
	if(!target || !locked())
		to_chat(user, span_notice("\The [src] is not locked."))
		return
	if(!can_chisel(user, chisel))
		return
	user.visible_message(span_warning("[user] sets a chisel against the lock of [target]'s [name] and starts hammering."), span_warning("I set the chisel against the lock of [target == user ? "my" : "[target]'s"] [name] and start hammering."))
	while(TRUE)
		if(!do_after(user, CHASTITY_CHISEL_STRIKE_TIME, target))
			return
		if(QDELETED(src) || wearer != target || !locked() || !can_chisel(user, chisel))
			return
		playsound(target, pick('sound/combat/hits/onmetal/grille (1).ogg', 'sound/combat/hits/onmetal/grille (2).ogg', 'sound/combat/hits/onmetal/grille (3).ogg'), 50, TRUE)
		if(prob(get_chisel_chance(user)))
			break_lock(user)
			return
		to_chat(user, span_warning("The lock holds. Another blow, then."))

/obj/item/clothing/undies/chastity/proc/can_chisel(mob/living/user, obj/item/weapon/chisel/chisel)
	if(user.get_active_held_item() != chisel || !(locate(/obj/item/weapon/hammer) in user.held_items))
		to_chat(user, span_warning("I need the chisel in one hand and a hammer in the other."))
		return FALSE
	if(is_hardmode_active())
		lock_failed(user, FALSE, "The lock shrugs off the chisel. Only its own key will open it.")
		return FALSE
	return pre_lock_interact(user)

/obj/item/clothing/undies/chastity/proc/get_chisel_chance(mob/living/user)
	return clamp(CHASTITY_CHISEL_BASE_CHANCE + (GET_MOB_ATTRIBUTE_VALUE(user, STAT_FORTUNE) - 10) * 4, 5, 80)

/// Breaks the lock for good and pulls the device off into [user]'s hands.
/obj/item/clothing/undies/chastity/proc/break_lock(mob/living/user)
	var/datum/lock/key/chastity/key_lock = lock
	if(key_lock)
		key_lock.lock_broken = TRUE
		key_lock.locked = FALSE
	var/mob/living/carbon/human/old_wearer = wearer
	if(old_wearer)
		old_wearer.dropItemToGround(src, force = TRUE)
		old_wearer.visible_message(span_notice("The lock of [old_wearer]'s [name] snaps apart, and the device comes free."))
	user?.put_in_hands(src)

/obj/item/clothing/undies/chastity/belt
	name = "chastity belt"
	desc = "A locking iron belt that seals the whole groin, front and back, behind a sturdy plate. For the devout."

/obj/item/clothing/undies/chastity/cage
	name = "chastity cage"
	desc = "A small locking cage that keeps a cock soft and out of reach."
	icon_state = "cage_standard"
	item_state = "cage_standard"
	blocked_organ_slots = list(ORGAN_SLOT_PENIS)
	hidden_organ_slots = list(ORGAN_SLOT_PENIS)
	required_organ_slots = list(ORGAN_SLOT_PENIS)
	worn_flags_inv = NONE
	covers_rear = FALSE

/obj/item/clothing/undies/chastity/cage/shield
	name = "chastity cage with anal shield"
	desc = "A locking cage for a cock, strapped round the hips with a plate that also seals the rear."
	icon_state = "cage_standard_shield"
	item_state = "cage_standard_shield"
	blocked_organ_slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_ANUS)
	covers_rear = TRUE

/obj/item/clothing/undies/chastity/cage/flat
	name = "flat chastity cage"
	desc = "A flat locking cage that presses a cock close and small against the body."
	icon_state = "cage_flat"
	item_state = "cage_flat"
	flat_cage = TRUE

/obj/item/clothing/undies/chastity/cage/flat/shield
	name = "flat chastity cage with anal shield"
	desc = "A flat locking cage, strapped round the hips with a plate that also seals the rear."
	icon_state = "cage_flat_shield"
	item_state = "cage_flat_shield"
	blocked_organ_slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_ANUS)
	covers_rear = TRUE

/obj/item/clothing/undies/chastity/insertable
	name = "insertable chastity belt"
	desc = "A locking belt with an inward plug shaped to fill and seal a pussy."
	icon_state = "cage_insert"
	item_state = "cage_insert"
	blocked_organ_slots = list(ORGAN_SLOT_VAGINA)
	hidden_organ_slots = list(ORGAN_SLOT_VAGINA)
	required_organ_slots = list(ORGAN_SLOT_VAGINA)
	has_insert = TRUE
	covers_rear = FALSE

/obj/item/clothing/undies/chastity/insertable/shield
	name = "insertable chastity belt with anal shield"
	desc = "A locking insertable belt with an extra plate that also seals the rear."
	icon_state = "cage_insert_shield"
	item_state = "cage_insert_shield"
	blocked_organ_slots = list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
	covers_rear = TRUE

/obj/item/clothing/undies/chastity/intersex
	name = "intersex chastity device"
	desc = "A broad locking frame that cages a cock and seals a pussy and rear in one device."
	icon_state = "cage_intersex"
	item_state = "cage_intersex"
	required_organ_slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA)

#undef CHASTITY_CHISEL_STRIKE_TIME
#undef CHASTITY_CHISEL_BASE_CHANCE
