// Arcane chastity device: no key fits it; a bound slave control ring locks it and opens or seals each part.

/// Time between two ring commands to the same device.
#define ARCANE_CHASTITY_COMMAND_COOLDOWN (2 SECONDS)

/obj/item/clothing/undies/chastity/arcane
	name = "arcane chastity device"
	desc = "A rune-etched frame of dark steel that shifts like something alive. It locks and opens only at the word of its bound control ring."
	icon_state = "cage_cursed"
	item_state = "cage_cursed"
	lock = /datum/lock
	spawn_with_key = FALSE
	/// Which front openings stay open; see CHASTITY_FRONT_*.
	var/front_mode = CHASTITY_FRONT_SEALED
	/// Whether the rear plate is drawn back.
	var/rear_open = FALSE
	/// The control ring that commands this device.
	var/obj/item/clothing/ring/slave_control/bound_ring
	COOLDOWN_DECLARE(ring_command_cooldown)

/obj/item/clothing/undies/chastity/arcane/Initialize(mapload, ...)
	. = ..()
	update_arcane_state()

/obj/item/clothing/undies/chastity/arcane/Destroy()
	clear_bound_ring()
	return ..()

/obj/item/clothing/undies/chastity/arcane/equipped(mob/living/carbon/user, slot)
	. = ..()
	update_arcane_state()

/obj/item/clothing/undies/chastity/arcane/dropped(mob/user)
	. = ..()
	update_arcane_state()

/obj/item/clothing/undies/chastity/arcane/can_be_forced()
	return FALSE

/obj/item/clothing/undies/chastity/arcane/examine(mob/user)
	. = ..()
	. += span_notice("Its front is [get_front_state_name()], and its rear plate is [rear_open ? "drawn back" : "sealed"].")
	if(tally_marks)
		. += span_notice("[tally_marks] tally mark\s [tally_marks == 1 ? "is" : "are"] etched into its runes.")
	if(bound_ring)
		. += span_notice("It answers to a control ring.")
	else
		. += span_warning("No ring commands it yet. Touch a slave control ring to it to bind them.")

/obj/item/clothing/undies/chastity/arcane/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	if(istype(attacking_item, /obj/item/clothing/ring/slave_control))
		bind_ring(attacking_item, user)
		return TRUE
	return ..()

/// The worn sprite follows the device's modes; the item icon stays the same.
/obj/item/clothing/undies/chastity/arcane/build_worn_icon(age = AGE_ADULT, default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, coom = FALSE, customi = null, sleeveindex, breast_size = 0, icon/clip_mask = null)
	if(!isinhands && !override_state)
		override_state = "[get_worn_state()][coom ? "_f" : ""]"
	return ..(age, default_layer, default_icon_file, isinhands, femaleuniform, override_state, coom, customi, sleeveindex, breast_size, clip_mask)

/// TRUE if the front leaves the organ in [slot] open.
/obj/item/clothing/undies/chastity/arcane/proc/is_front_open(slot)
	if(front_mode == CHASTITY_FRONT_ALL)
		return TRUE
	if(slot == ORGAN_SLOT_PENIS)
		return front_mode == CHASTITY_FRONT_PENIS
	if(slot == ORGAN_SLOT_VAGINA)
		return front_mode == CHASTITY_FRONT_VAGINA
	return FALSE

/// Which sealed look fits the wearer, or "open" once any front opening the wearer has is open.
/obj/item/clothing/undies/chastity/arcane/proc/get_worn_look()
	var/has_penis = !!get_real_organ(wearer, ORGAN_SLOT_PENIS)
	var/has_vagina = !!get_real_organ(wearer, ORGAN_SLOT_VAGINA)
	if((has_penis && is_front_open(ORGAN_SLOT_PENIS)) || (has_vagina && is_front_open(ORGAN_SLOT_VAGINA)))
		return "open"
	if(has_penis && has_vagina)
		return "intersex"
	if(has_penis)
		return flat_cage ? "flat" : "cage"
	return "belt"

/obj/item/clothing/undies/chastity/arcane/leaves_rear_bare()
	return rear_open

/obj/item/clothing/undies/chastity/arcane/proc/get_worn_state()
	return "arcane_[get_worn_look()][rear_open ? "" : "_shield"]"

/// Every worn state this device can draw, without body suffixes.
/obj/item/clothing/undies/chastity/arcane/proc/get_all_worn_states()
	. = list()
	for(var/look in list("cage", "flat", "belt", "intersex", "open"))
		. += "arcane_[look]"
		. += "arcane_[look]_shield"

/// Rebuilds what the device blocks and hides from its modes, and redraws the wearer.
/obj/item/clothing/undies/chastity/arcane/proc/update_arcane_state()
	var/list/blocked = list()
	if(!is_front_open(ORGAN_SLOT_PENIS))
		blocked += ORGAN_SLOT_PENIS
	if(!is_front_open(ORGAN_SLOT_VAGINA))
		blocked += ORGAN_SLOT_VAGINA
	if(!rear_open)
		blocked += ORGAN_SLOT_ANUS
	blocked_organ_slots = blocked
	switch(get_worn_look())
		if("belt", "intersex")
			hidden_organ_slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_TESTICLES, ORGAN_SLOT_VAGINA)
			worn_flags_inv = HIDECROTCH
		if("cage", "flat")
			hidden_organ_slots = list(ORGAN_SLOT_PENIS)
			worn_flags_inv = NONE
		else
			hidden_organ_slots = blocked - ORGAN_SLOT_ANUS
			worn_flags_inv = NONE
	flags_inv = worn_flags_inv
	refresh_moods()
	wearer?.update_inv_undie_bot()

/// Front modes the wearer's body allows.
/obj/item/clothing/undies/chastity/arcane/proc/get_valid_front_modes()
	. = list(CHASTITY_FRONT_SEALED)
	var/has_penis = !!get_real_organ(wearer, ORGAN_SLOT_PENIS)
	var/has_vagina = !!get_real_organ(wearer, ORGAN_SLOT_VAGINA)
	if(has_penis)
		. += CHASTITY_FRONT_PENIS
	if(has_vagina)
		. += CHASTITY_FRONT_VAGINA
	if(has_penis && has_vagina)
		. += CHASTITY_FRONT_ALL

/obj/item/clothing/undies/chastity/arcane/proc/get_front_state_name()
	switch(front_mode)
		if(CHASTITY_FRONT_PENIS)
			return "open over the cock"
		if(CHASTITY_FRONT_VAGINA)
			return "open over the pussy"
		if(CHASTITY_FRONT_ALL)
			return "open all the way"
	return "sealed"

/// Radial entries for the bound ring: display name to command key.
/obj/item/clothing/undies/chastity/arcane/proc/get_ring_command_options()
	. = list()
	if(locked())
		.["Unlock"] = "unlock"
	else
		.["Lock"] = "lock"
	var/static/list/front_command_names = list(
		"[CHASTITY_FRONT_SEALED]" = "Seal front",
		"[CHASTITY_FRONT_PENIS]" = "Open cock",
		"[CHASTITY_FRONT_VAGINA]" = "Open pussy",
		"[CHASTITY_FRONT_ALL]" = "Open all",
	)
	for(var/mode in get_valid_front_modes())
		if(mode != front_mode)
			.[front_command_names["[mode]"]] = "front_[mode]"
	if(rear_open)
		.["Seal rear"] = "rear_seal"
	else
		.["Open rear"] = "rear_open"
	if(get_real_organ(wearer, ORGAN_SLOT_PENIS))
		if(flat_cage)
			.["Release cage"] = "flat_off"
		else
			.["Flatten cage"] = "flat_on"

/// Runs a ring command from get_ring_command_options(); returns TRUE if anything changed.
/obj/item/clothing/undies/chastity/arcane/proc/perform_ring_command(command, mob/living/commander)
	if(!wearer)
		to_chat(commander, span_warning("\The [src] is not being worn."))
		return FALSE
	if(!COOLDOWN_FINISHED(src, ring_command_cooldown))
		to_chat(commander, span_warning("\The [src] is still settling."))
		return FALSE
	. = FALSE
	switch(command)
		if("lock")
			. = set_arcane_locked(TRUE)
		if("unlock")
			. = set_arcane_locked(FALSE)
		if("rear_open")
			. = set_rear_open(TRUE)
		if("rear_seal")
			. = set_rear_open(FALSE)
		if("flat_on")
			. = set_flat(TRUE)
		if("flat_off")
			. = set_flat(FALSE)
		else
			if(findtext(command, "front_") == 1)
				. = set_front_mode(text2num(copytext(command, 7)))
	if(.)
		COOLDOWN_START(src, ring_command_cooldown, ARCANE_CHASTITY_COMMAND_COOLDOWN)

/obj/item/clothing/undies/chastity/arcane/proc/set_arcane_locked(should_lock)
	if(!lock || locked() == !!should_lock)
		return FALSE
	if(should_lock)
		lock.lock()
	else
		lock.unlock()
	if(wearer)
		playsound(wearer, 'sound/foley/lockmetal.ogg', 50, TRUE)
		to_chat(wearer, should_lock ? span_warning(pick_chastity_string("chastity_lock_messages.json", "remote_lock")) : span_notice(pick_chastity_string("chastity_lock_messages.json", "remote_unlock")))
	return TRUE

/obj/item/clothing/undies/chastity/arcane/proc/set_front_mode(new_mode)
	if(new_mode == front_mode || !(new_mode in get_valid_front_modes()))
		return FALSE
	var/penis_was_open = is_front_open(ORGAN_SLOT_PENIS)
	var/vagina_was_open = is_front_open(ORGAN_SLOT_VAGINA)
	front_mode = new_mode
	update_arcane_state()
	var/has_penis = !!get_real_organ(wearer, ORGAN_SLOT_PENIS)
	var/has_vagina = !!get_real_organ(wearer, ORGAN_SLOT_VAGINA)
	var/closed_something = (has_penis && penis_was_open && !is_front_open(ORGAN_SLOT_PENIS)) || (has_vagina && vagina_was_open && !is_front_open(ORGAN_SLOT_VAGINA))
	if(wearer)
		playsound(wearer, closed_something ? 'sound/foley/doors/windowdown.ogg' : 'sound/foley/doors/windowup.ogg', 50, TRUE)
		to_chat(wearer, closed_something ? span_warning(pick_chastity_string("chastity_mode_messages.json", "front_close")) : span_notice(pick_chastity_string("chastity_mode_messages.json", "front_open")))
	return TRUE

/obj/item/clothing/undies/chastity/arcane/proc/set_rear_open(should_open)
	if(rear_open == !!should_open)
		return FALSE
	rear_open = !!should_open
	update_arcane_state()
	if(wearer)
		playsound(wearer, rear_open ? 'sound/items/uncork.ogg' : 'sound/misc/mat/pop.ogg', 50, TRUE)
		to_chat(wearer, rear_open ? span_notice(pick_chastity_string("chastity_mode_messages.json", "rear_open")) : span_warning(pick_chastity_string("chastity_mode_messages.json", "rear_close")))
	return TRUE

/obj/item/clothing/undies/chastity/arcane/proc/set_flat(should_flatten)
	if(flat_cage == !!should_flatten || !get_real_organ(wearer, ORGAN_SLOT_PENIS))
		return FALSE
	flat_cage = !!should_flatten
	update_arcane_state()
	playsound(wearer, flat_cage ? 'sound/items/garrote.ogg' : 'sound/items/garrote2.ogg', 50, TRUE)
	to_chat(wearer, flat_cage ? span_warning(pick_chastity_string("chastity_mode_messages.json", "flat_enable")) : span_notice(pick_chastity_string("chastity_mode_messages.json", "flat_disable")))
	return TRUE

/// Binds [ring] as this device's master; only a master ring may steal it from another ring.
/obj/item/clothing/undies/chastity/arcane/proc/bind_ring(obj/item/clothing/ring/slave_control/ring, mob/living/user)
	if(!istype(ring))
		return FALSE
	if(bound_ring == ring)
		to_chat(user, span_notice("\The [src] already answers to this ring."))
		return FALSE
	if(bound_ring && !istype(ring, /obj/item/clothing/ring/slave_control/master))
		to_chat(user, span_warning("\The [src] already answers to another ring."))
		return FALSE
	clear_bound_ring()
	ring.bound_chastity?.clear_bound_ring()
	bound_ring = ring
	ring.bound_chastity = src
	to_chat(user, span_notice(pick_chastity_string("chastity_mode_messages.json", "bind")))
	if(wearer && wearer != user)
		to_chat(wearer, span_warning("The runes of my [name] tingle as it takes a new master."))
	return TRUE

/obj/item/clothing/undies/chastity/arcane/proc/clear_bound_ring()
	if(bound_ring?.bound_chastity == src)
		bound_ring.bound_chastity = null
	bound_ring = null

/datum/repeatable_crafting_recipe/arcyne/arcane_chastity
	name = "arcane chastity device"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/clothing/undies/chastity/belt = 1,
		/obj/item/gem/red = 1,
		/obj/item/gem/blue = 1,
	)
	output = /obj/item/clothing/undies/chastity/arcane
	starting_atom = /obj/item/gem/blue
	attacked_atom = /obj/item/clothing/undies/chastity/belt
	craftdiff = 3

#undef ARCANE_CHASTITY_COMMAND_COOLDOWN
