// Implants: augments sitting in the one socket of a prosthetic limb or organ, for every species.
// The implant belongs to the part: it works while the part is fitted and travels with it.

/datum/augment
	/// Prosthetic part kinds whose socket takes this implant. Empty keeps it automaton-only.
	var/list/socket_kinds = list()
	/// Quirk point value when picked in the character creator; same sign as quirks.
	var/point_value = -1
	/// Mob this implant works on through a prosthetic socket.
	var/mob/living/carbon/socket_owner

/datum/augment/Destroy()
	deactivate_socket()
	return ..()

/// Stable id for saves: the type path below /datum/augment.
/datum/augment/proc/get_implant_id()
	return replacetext("[type]", "/datum/augment/", "")

/datum/augment/proc/activate_socket(mob/living/carbon/human/new_owner)
	if(socket_owner || !ishuman(new_owner) || istype(new_owner, /mob/living/carbon/human/dummy))
		return
	socket_owner = new_owner
	parent = new_owner
	on_install(new_owner)

/datum/augment/proc/deactivate_socket()
	if(!socket_owner)
		return
	var/mob/living/carbon/human/old_owner = socket_owner
	socket_owner = null
	on_remove(old_owner)
	parent = null

/// Short summary of what an implant changes, for the creator and examine.
/datum/augment/proc/get_effect_summary()
	return ""

/datum/augment/stats/get_effect_summary()
	var/list/parts = list()
	for(var/stat in stat_changes)
		var/change = stat_changes[stat]
		parts += "[change > 0 ? "+" : ""][change] [stat]"
	return jointext(parts, ", ")

/datum/augment/skill/get_effect_summary()
	var/list/parts = list()
	for(var/datum/attribute/skill/skill_type as anything in skill_changes)
		var/change = skill_changes[skill_type]
		parts += "[change > 0 ? "+" : ""][change] [initial(skill_type.name)]"
	return jointext(parts, ", ")

/datum/augment/special/get_effect_summary()
	return desc

/// Implant id = prototype datum, only implants that fit some socket.
GLOBAL_LIST_INIT(implant_catalog, build_implant_catalog())

/proc/build_implant_catalog()
	. = list()
	for(var/datum/augment/augment_type as anything in subtypesof(/datum/augment))
		var/datum/augment/prototype = new augment_type()
		if(!length(prototype.socket_kinds))
			qdel(prototype)
			continue
		.[prototype.get_implant_id()] = prototype

/proc/implant_fits_kind(implant_id, kind)
	var/datum/augment/prototype = GLOB.implant_catalog[implant_id]
	return prototype && (kind in prototype.socket_kinds)

/*
 * SOCKETS ON PARTS
 */

/obj/item
	/// Prosthetic part kind of this item's implant socket, or null when it has none.
	var/implant_socket_kind
	/// Implant sitting in the socket.
	var/datum/augment/socket_implant

/obj/item/bodypart/l_arm/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_ARM
/obj/item/bodypart/r_arm/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_ARM
/obj/item/bodypart/l_leg/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_LEG
/obj/item/bodypart/r_leg/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_LEG
/obj/item/organ/eyes/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_EYE
/obj/item/organ/eyes/left/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_EYE
/obj/item/organ/heart/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_HEART
/obj/item/organ/lungs/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_LUNGS
/obj/item/organ/tongue/prosthetic
	implant_socket_kind = PROSTHETIC_KIND_TONGUE

/// The mob this part currently works for, if fitted.
/obj/item/proc/get_socket_owner()
	return null

/obj/item/bodypart/get_socket_owner()
	return owner

/obj/item/organ/get_socket_owner()
	return owner

/// Puts an implant into the empty socket. It starts working at once if the part is fitted.
/obj/item/proc/set_socket_implant(datum/augment/implant)
	if(socket_implant || !implant || !(implant_socket_kind in implant.socket_kinds))
		return FALSE
	socket_implant = implant
	var/mob/living/carbon/human/fitted_to = get_socket_owner()
	if(fitted_to)
		implant.activate_socket(fitted_to)
	return TRUE

/// Takes the implant out of the socket and returns it.
/obj/item/proc/take_socket_implant()
	var/datum/augment/implant = socket_implant
	if(!implant)
		return null
	implant.deactivate_socket()
	socket_implant = null
	return implant

/obj/item/examine(mob/user)
	. = ..()
	if(socket_implant)
		. += span_notice("A [socket_implant.name] sits in its socket.")
	else if(implant_socket_kind)
		. += span_info("It has an empty implant socket.")

/obj/item/bodypart/attach_limb(mob/living/carbon/C, special)
	. = ..()
	if(socket_implant && owner == C)
		socket_implant.activate_socket(C)

/obj/item/bodypart/drop_limb(special)
	socket_implant?.deactivate_socket()
	return ..()

/obj/item/bodypart/Destroy()
	QDEL_NULL(socket_implant)
	return ..()

/obj/item/organ/Insert(mob/living/M, special = 0, drop_if_replaced = TRUE, new_zone = null)
	. = ..()
	if(socket_implant && owner == M)
		socket_implant.activate_socket(M)

/obj/item/organ/Remove(mob/living/M, special = FALSE, drop_if_replaced = TRUE)
	socket_implant?.deactivate_socket()
	return ..()

/obj/item/organ/Destroy()
	QDEL_NULL(socket_implant)
	return ..()

/*
 * KITS IN ROUND
 *
 * A kit fits its implant into a loose prosthetic part; an empty kit pries one out.
 * Automatons keep the old body-wide install on an artificer's table.
 */

/obj/item/augment_kit/pre_attack(atom/target, mob/living/user, list/modifiers)
	if(!istype(target, /obj/item) || ismob(target.loc))
		return ..()
	var/obj/item/part = target
	if(!part.implant_socket_kind)
		return ..()
	if(part.get_socket_owner())
		to_chat(user, span_warning("[part] must be taken off first."))
		return TRUE
	var/skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/craft/engineering)
	if(contained_augment)
		if(part.socket_implant)
			to_chat(user, span_warning("[part] already has an implant."))
			return TRUE
		if(!(part.implant_socket_kind in contained_augment.socket_kinds))
			to_chat(user, span_warning("[contained_augment.name] does not fit [part]."))
			return TRUE
		if(skill < contained_augment.engineering_difficulty)
			to_chat(user, span_warning("I lack the engineering skill to fit this implant."))
			return TRUE
		to_chat(user, span_notice("I begin fitting [contained_augment.name] into [part]..."))
		if(!do_after(user, contained_augment.installation_time, part) || !contained_augment || part.socket_implant || part.get_socket_owner())
			return TRUE
		if(part.set_socket_implant(contained_augment))
			to_chat(user, span_notice("[contained_augment.name] clicks into place."))
			contained_augment = null
			update_augment()
			playsound(part, 'sound/effects/sparks1.ogg', 50, TRUE)
		return TRUE
	if(!part.socket_implant)
		to_chat(user, span_warning("[src] is empty and [part] has no implant to take."))
		return TRUE
	if(skill < part.socket_implant.engineering_difficulty)
		to_chat(user, span_warning("I lack the engineering skill to remove this implant."))
		return TRUE
	to_chat(user, span_notice("I begin prying [part.socket_implant.name] out of [part]..."))
	if(!do_after(user, part.socket_implant.installation_time, part) || contained_augment || !part.socket_implant || part.get_socket_owner())
		return TRUE
	contained_augment = part.take_socket_implant()
	update_augment()
	playsound(part, 'sound/effects/sparks1.ogg', 50, TRUE)
	return TRUE

/// A blank kit: the artificer chooses what to build into it, up to their engineering skill.
/obj/item/augment_kit/blank
	name = "blank implant kit"
	desc = "Parts for one implant. Use it in hand to choose which implant to build."

/obj/item/augment_kit/blank/attack_self(mob/user, list/modifiers)
	if(contained_augment)
		return ..()
	var/skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/craft/engineering)
	var/list/choices = list()
	for(var/implant_id in GLOB.implant_catalog)
		var/datum/augment/prototype = GLOB.implant_catalog[implant_id]
		if(skill >= prototype.engineering_difficulty)
			choices["[prototype.name] ([english_list(prototype.socket_kinds)])"] = prototype.type
	if(!length(choices))
		to_chat(user, span_warning("I don't know how to build any implant yet."))
		return TRUE
	var/choice = tgui_input_list(user, "Which implant should I build?", "Blank implant kit", choices)
	if(!choice || QDELETED(src) || contained_augment || !user.is_holding(src))
		return TRUE
	var/implant_type = choices[choice]
	contained_augment = new implant_type()
	update_augment()
	to_chat(user, span_notice("I shape the kit into [contained_augment.name]."))
	return TRUE

/datum/artificer_recipe/prosthetics/implant_kit
	name = "Blank Implant Kit (+2 Cogs)"
	required_item = /obj/item/ingot/bronze
	created_item = /obj/item/augment_kit/blank
	additional_items = list(/obj/item/gear/metal = 2)
	hammers_per_item = 8
	craftdiff = 3
