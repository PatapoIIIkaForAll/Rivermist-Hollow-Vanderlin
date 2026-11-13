// The dullahan head: a bodypart item that is where the dullahan's senses are while detached.
// Brain, eyes, ears and tongue stay in the body; the head only carries the hat and the mask.
/obj/item/bodypart/head/dullahan
	attach_wound = null
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	// A whole head is a lot to fit anywhere; needs real stretching, not just a snug fit.
	body_storage_bulk = 6
	/// The body this head belongs to. Only that body can wear it again.
	var/datum/weakref/owner_ref
	/// Hat carried off with the head.
	var/obj/item/stored_hat
	/// Mask carried off with the head.
	var/obj/item/stored_mask

/obj/item/bodypart/head/dullahan/Destroy()
	var/datum/species/dullahan/dullahan_species = get_dullahan_species()
	var/turf/drop_turf = get_turf(src)
	if(drop_turf)
		stored_hat?.forceMove(drop_turf)
		stored_mask?.forceMove(drop_turf)
	stored_hat = null
	stored_mask = null
	dullahan_species?.on_head_destroyed(src)
	owner_ref = null
	return ..()

/obj/item/bodypart/head/dullahan/handle_atom_del(atom/A)
	if(A == stored_hat)
		stored_hat = null
		update_icon_dropped()
	if(A == stored_mask)
		stored_mask = null
		update_icon_dropped()
	return ..()

/obj/item/bodypart/head/dullahan/proc/get_dullahan_owner()
	RETURN_TYPE(/mob/living/carbon/human)
	if(owner)
		return owner
	return owner_ref?.resolve()

/// The owning dullahan species, or null when the body is gone or no longer a dullahan.
/obj/item/bodypart/head/dullahan/proc/get_dullahan_species()
	RETURN_TYPE(/datum/species/dullahan)
	var/mob/living/carbon/human/H = get_dullahan_owner()
	if(!H || QDELETED(H))
		return null
	var/datum/species/dullahan/dullahan_species = H.dna?.species
	if(!istype(dullahan_species))
		return null
	return dullahan_species

/// TRUE while this head is the live, detached head of a dullahan body.
/obj/item/bodypart/head/dullahan/proc/is_live_detached_head()
	if(owner)
		return FALSE
	var/datum/species/dullahan/dullahan_species = get_dullahan_species()
	return dullahan_species?.my_head == src

// Coming off and going back on.

/obj/item/bodypart/head/dullahan/drop_limb(special)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return FALSE
	var/datum/species/dullahan/dullahan_species = H.dna?.species
	if(!istype(dullahan_species) || dullahan_species.my_head != src)
		return ..(special)
	if(!special)
		stash_worn_items(H)
	owner_ref = WEAKREF(H)
	// Always a "special" drop for the base: nothing lethal, and the organs stay in the body.
	. = ..(TRUE)
	if(!.)
		return
	if(!special)
		dullahan_species.on_head_detached(src)

/obj/item/bodypart/head/dullahan/attach_limb(mob/living/carbon/C, special)
	var/mob/living/carbon/human/original = owner_ref?.resolve()
	if(!special && original && C != original)
		return FALSE
	if(!ishuman(C))
		return ..()
	owner_ref = WEAKREF(C)
	. = ..()
	restore_worn_items(C)
	var/datum/species/dullahan/dullahan_species = C.dna?.species
	if(istype(dullahan_species))
		dullahan_species.on_head_attached(src)
	return TRUE

/// Hat and mask travel with the head. NODROP items stay on the body; hoods belong to their cloak.
/obj/item/bodypart/head/dullahan/proc/stash_worn_items(mob/living/carbon/human/H)
	for(var/slot in list(ITEM_SLOT_HEAD, ITEM_SLOT_MASK))
		var/obj/item/worn = H.get_item_by_slot(slot)
		if(!worn || HAS_TRAIT(worn, TRAIT_NODROP))
			continue
		H.dropItemToGround(worn, force = TRUE, silent = TRUE)
		if(QDELETED(worn) || istype(worn, /obj/item/clothing/head/hooded))
			continue
		worn.forceMove(src)
		if(slot == ITEM_SLOT_HEAD)
			stored_hat = worn
		else
			stored_mask = worn

/obj/item/bodypart/head/dullahan/proc/restore_worn_items(mob/living/carbon/human/H)
	var/obj/item/hat = stored_hat
	var/obj/item/mask = stored_mask
	stored_hat = null
	stored_mask = null
	if(hat && !H.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		hat.forceMove(H.drop_location())
	if(mask && !H.equip_to_slot_if_possible(mask, ITEM_SLOT_MASK, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
		mask.forceMove(H.drop_location())

/// Hitting the headless owner with their own head, aimed at the head zone, puts it back on.
/obj/item/bodypart/head/dullahan/attack(mob/living/M, mob/living/user, list/modifiers)
	if(!ishuman(M) || user.cmode || user.zone_selected != BODY_ZONE_HEAD || !isdullahan(M))
		return ..()
	var/mob/living/carbon/human/target = M
	var/mob/living/carbon/human/original = owner_ref?.resolve()
	if(original != target)
		to_chat(user, span_notice(user == target ? "This is not my head!" : "That is not [target]'s head!"))
		return TRUE
	var/datum/species/dullahan/dullahan_species = target.dna?.species
	if(!istype(dullahan_species) || !dullahan_species.headless || dullahan_species.my_head != src)
		return ..()
	if(user == target)
		user.visible_message(span_notice("[user] begins setting [user.p_their()] head back on..."), span_notice("I begin setting my head back on..."))
	else
		target.visible_message(span_notice("[user] begins setting [target]'s head back on for [target.p_them()]..."), span_notice("[user] is setting my head back on for me..."))
	if(!do_after(user, 3 SECONDS, target))
		return TRUE
	if(QDELETED(src) || !dullahan_species.headless || dullahan_species.my_head != src || !user.is_holding(src))
		return TRUE
	user.dropItemToGround(src, force = TRUE, silent = TRUE)
	attach_limb(target)
	return TRUE

// Decapitation is not lethal and happens only on a neck hit. A grabber catches the head.
/obj/item/bodypart/head/dullahan/dismember(dam_type = BRUTE, bclass = BCLASS_CUT, mob/living/user, zone_precise = src.body_zone)
	var/mob/living/carbon/human/H = owner
	if(!H)
		return FALSE
	var/datum/species/dullahan/dullahan_species = H.dna?.species
	if(!istype(dullahan_species) || dullahan_species.my_head != src)
		return ..()
	if(zone_precise != BODY_ZONE_PRECISE_NECK)
		return FALSE
	if(H.status_flags & GODMODE)
		return FALSE
	if(HAS_TRAIT(H, TRAIT_NODISMEMBER))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MOB_DISMEMBER, src) & COMPONENT_CANCEL_DISMEMBER)
		return FALSE
	var/obj/item/clothing/checked_armor = H.check_crit_armor(zone_precise, bclass)
	if(checked_armor)
		var/int_percent = round(((checked_armor.get_integrity() / checked_armor.max_integrity) * 100), 1)
		if(int_percent > 30 && !HAS_TRAIT(H, TRAIT_CRITICAL_WEAKNESS) && !HAS_TRAIT(H, TRAIT_EASYDISMEMBER))
			to_chat(H, span_green("My [checked_armor.name] just saved me from losing my [src.name]!"))
			checked_armor.take_damage(checked_armor.max_integrity / 2, damage_flag = bclass)
			return FALSE

	var/mob/living/catcher
	var/catch_index
	grabbedby = SANITIZE_LIST(grabbedby)
	for(var/obj/item/grabbing/grab in grabbedby)
		if(grab.grab_state < GRAB_AGGRESSIVE || !grab.grabbee)
			continue
		catcher = grab.grabbee
		catch_index = catcher.get_held_index_of_item(grab)
		break
	if(length(grabbedby))
		QDEL_LIST(grabbedby)

	playsound(H, pick(dismemsound), 50, FALSE, -1)
	H.visible_message(span_danger("<B>[H]'s head comes clean off!</B>"), span_userdanger("My head comes off!"))
	if(!drop_limb())
		return FALSE
	add_abstract_elastic_data(ELASCAT_COMBAT, ELASDATA_DECAPITATIONS, 1)

	if(catcher && !QDELETED(catcher))
		if(catch_index)
			catcher.put_in_hand(src, catch_index)
		else
			catcher.put_in_hands(src)
		return TRUE

	var/turf/location = get_turf(src)
	if(istype(location))
		H.add_splatter_floor(location)
	var/direction = pick(GLOB.cardinals)
	var/t_range = rand(2, max(throw_range / 2, 2))
	var/turf/target_turf = location
	for(var/i in 1 to t_range - 1)
		var/turf/new_turf = get_step(target_turf, direction)
		if(!new_turf)
			break
		target_turf = new_turf
		if(new_turf.density)
			break
	throw_at(target_turf, throw_range, throw_speed)
	return TRUE

// What the detached head can and cannot suffer.

/obj/item/bodypart/head/dullahan/burn()
	if(is_live_detached_head())
		return
	return ..()

/obj/item/bodypart/head/dullahan/drop_organs(mob/user, violent_removal)
	if(get_dullahan_species())
		return
	return ..()

/obj/item/bodypart/head/dullahan/onbite(mob/living/user)
	if(is_live_detached_head())
		to_chat(user, span_warning("[src] glares at me. I think better of it."))
		return FALSE
	return ..()

/obj/item/bodypart/head/dullahan/attackby(obj/item/I, mob/user, list/modifiers)
	// Food and drink offered to the head feed the body it belongs to.
	if(is_live_detached_head() && istype(I, /obj/item/reagent_containers) && isliving(user) && !user.cmode)
		var/mob/living/feeder = user
		if(istype(feeder.used_intent, INTENT_FEED) && I.interact_with_atom(get_dullahan_owner(), feeder, modifiers))
			return TRUE
	if(is_live_detached_head() && I.get_sharpness() && !user.cmode)
		to_chat(user, span_warning("[src] will not open. Something holds it shut."))
		return TRUE
	return ..()

/// Striking the severed head rattles the brain behind it: organ damage that feeds the defeat tracks.
/obj/item/bodypart/head/dullahan/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!is_live_detached_head() || !attacking_item.force)
		return ..()
	var/mob/living/carbon/human/H = get_dullahan_owner()
	user.do_attack_animation(src)
	playsound(src, "genblunt", 60, TRUE, -1)
	visible_message(span_danger("[user] strikes [src] with [attacking_item]!"), null, null, COMBAT_MESSAGE_RANGE)
	to_chat(H, span_userdanger("My head is struck! The world swims."))
	var/obj/item/organ/brain/brain = H.getorganslot(ORGAN_SLOT_BRAIN)
	brain?.applyOrganDamage(attacking_item.force)
	H.updatehealth()
	log_combat(user, H, "struck the severed head of", attacking_item)
	return TRUE

// Senses relayed from the head to its body.

/obj/item/bodypart/head/dullahan/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), original_message)
	. = ..()
	if(!is_live_detached_head())
		return
	var/mob/living/carbon/human/H = get_dullahan_owner()
	H.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mods, original_message)

/// The body draws eyes and lips with the owner's face offset; the dropped head must match.
/obj/item/bodypart/head/dullahan/update_icon_dropped()
	var/list/standing = get_limb_icon(1)
	if(!length(standing))
		icon_state = initial(icon_state)
		return
	var/face_x = 0
	var/face_y = 0
	var/mob/living/carbon/human/H = get_dullahan_owner()
	if(H && !QDELETED(H))
		var/list/offsets = H.get_offset_features()
		if(LAZYACCESS(offsets, OFFSET_FACE))
			face_x = offsets[OFFSET_FACE][1]
			face_y = offsets[OFFSET_FACE][2]
	for(var/image/overlay in standing)
		overlay.pixel_x = px_x
		overlay.pixel_y = px_y
		if(overlay.icon == 'icons/mob/human_face.dmi')
			overlay.pixel_x += face_x
			overlay.pixel_y += face_y
	add_overlay(standing)

/obj/item/bodypart/head/dullahan/get_limb_icon(dropped, hideaux = FALSE)
	var/mob/living/carbon/human/H = dropped ? get_dullahan_owner() : null
	if(H && !QDELETED(H))
		// The eyes live in the body; borrow them for the dropped face.
		for(var/obj/item/organ/eyes/eye as anything in H.eye_organs)
			if(eye.side == LEFT_SIDE)
				eyes_left = eye
			else
				eyes_right = eye
	. = ..()
	eyes_left = null
	eyes_right = null
	if(!dropped)
		return
	if(H)
		// The brain is in the body, so the empty-skull overlay is a lie here.
		for(var/image/overlay in .)
			if(overlay.icon_state == "debrained")
				. -= overlay
	var/hidden_slots = NONE
	if(stored_hat)
		hidden_slots |= stored_hat.flags_inv
		. += stored_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/head.dmi', coom = FALSE)
	if(stored_mask && !(hidden_slots & HIDEMASK))
		. += stored_mask.build_worn_icon(default_layer = MASK_LAYER, default_icon_file = 'icons/roguetown/clothing/onmob/masks.dmi')

// The head's own little wardrobe: hat and mask, for whoever holds it or stands over it.

/obj/item/bodypart/head/dullahan/proc/user_can_reach(mob/user)
	if(!user || QDELETED(user) || QDELETED(src))
		return FALSE
	return user.is_holding(src) || (isturf(loc) && get_turf(src) == get_turf(user))

/obj/item/bodypart/head/dullahan/proc/get_stored_item(slot)
	return (slot == "head") ? stored_hat : stored_mask

/obj/item/bodypart/head/dullahan/proc/set_stored_item(slot, obj/item/item)
	if(slot == "head")
		stored_hat = item
	else
		stored_mask = item

/obj/item/bodypart/head/dullahan/proc/show_inv(mob/user)
	if(!user_can_reach(user))
		return
	var/list/dat = list("<table>")
	dat += "<tr><td><a href='byond://?src=[REF(src)];slot=head'>[stored_hat ? stored_hat : "<font color=grey>Head</font>"]</a></td></tr>"
	if(stored_hat?.flags_inv & HIDEMASK)
		dat += "<tr><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><a href='byond://?src=[REF(src)];slot=mask'>[stored_mask ? stored_mask : "<font color=grey>Mask</font>"]</a></td></tr>"
	dat += "</table>"
	var/datum/browser/popup = new(user, "dullahan_head_[REF(src)]", "[src]", 220, 120)
	popup.set_content(dat.Join())
	popup.open()

/obj/item/bodypart/head/dullahan/Topic(href, list/href_list)
	. = ..()
	var/slot = href_list["slot"]
	if(!slot || !isliving(usr))
		return
	var/mob/living/user = usr
	if(!is_live_detached_head() || !user_can_reach(user) || user.incapacitated())
		return
	if(get_stored_item(slot))
		INVOKE_ASYNC(src, PROC_REF(strip_stored_item), user, slot)
	else
		INVOKE_ASYNC(src, PROC_REF(dress_stored_item), user, slot)

/obj/item/bodypart/head/dullahan/proc/strip_stored_item(mob/living/user, slot)
	var/obj/item/stored = get_stored_item(slot)
	if(!stored)
		return FALSE
	visible_message(span_warning("[user] tries to remove [stored] from [src]."), null, null, COMBAT_MESSAGE_RANGE)
	to_chat(user, span_danger("I try to remove [stored] from [src]..."))
	if(!do_after(user, stored.strip_delay, src))
		return FALSE
	if(QDELETED(stored) || get_stored_item(slot) != stored || !user_can_reach(user))
		return FALSE
	set_stored_item(slot, null)
	user.put_in_hands(stored)
	update_icon_dropped()
	show_inv(user)
	return TRUE

/obj/item/bodypart/head/dullahan/proc/dress_stored_item(mob/living/user, slot)
	var/obj/item/held = user.get_active_held_item()
	if(!held || held == src)
		return FALSE
	if(HAS_TRAIT(held, TRAIT_NODROP))
		to_chat(user, span_warning("[held] is stuck to my hand!"))
		return FALSE
	if(istype(held, /obj/item/clothing/head/hooded))
		return FALSE
	var/needed_slot = (slot == "head") ? ITEM_SLOT_HEAD : ITEM_SLOT_MASK
	if(!(held.slot_flags & needed_slot))
		to_chat(user, span_warning("[held] does not go there."))
		return FALSE
	if(get_stored_item(slot))
		return FALSE
	visible_message(span_notice("[user] tries to put [held] on [src]."), null, null, COMBAT_MESSAGE_RANGE)
	to_chat(user, span_notice("I try to put [held] on [src]..."))
	if(!do_after(user, held.equip_delay_other, src))
		return FALSE
	if(QDELETED(held) || get_stored_item(slot) || !user_can_reach(user) || user.get_active_held_item() != held)
		return FALSE
	user.dropItemToGround(held, force = TRUE, silent = TRUE)
	if(QDELETED(held))
		return FALSE
	held.forceMove(src)
	set_stored_item(slot, held)
	update_icon_dropped()
	show_inv(user)
	return TRUE

/// Dragging the detached head onto yourself opens its wardrobe.
/obj/item/bodypart/head/dullahan/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(over == usr && isliving(usr) && is_live_detached_head() && user_can_reach(usr))
		show_inv(usr)
		return
	return ..()
