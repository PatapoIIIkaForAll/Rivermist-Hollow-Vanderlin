/obj/item/augment_kit
	item_weight = 372 GRAMS
	name = "augmentation kit"
	desc = "Holds one implant for an automaton or a prosthetic part. Examine it for details."
	icon = 'icons/roguetown/items/new_gears.dmi'
	icon_state = "steel_gear"
	w_class = WEIGHT_CLASS_SMALL
	grid_width = 32
	grid_height = 32
	var/datum/augment/contained_augment

/obj/item/augment_kit/Initialize()
	. = ..()
	if(contained_augment)
		contained_augment = new contained_augment()
		update_augment()

/obj/item/augment_kit/examine(mob/user)
	. = ..()
	if(contained_augment)
		. += span_info("This kit contains: [contained_augment.name]")
		. += span_info("Installation requires Engineering skill level [contained_augment.engineering_difficulty]")
		. += contained_augment.get_examine_info()

/obj/item/augment_kit/strength_servo
	contained_augment = /datum/augment/stats/strength_servo

/obj/item/augment_kit/perception_lens
	contained_augment = /datum/augment/stats/perception_lens

/obj/item/augment_kit/processing_core
	contained_augment = /datum/augment/stats/processing_core

/obj/item/augment_kit/reinforced_frame
	contained_augment = /datum/augment/stats/reinforced_frame

/obj/item/augment_kit/power_limiter
	contained_augment = /datum/augment/stats/power_limiter

/obj/item/augment_kit/core_stabilizer
	contained_augment = /datum/augment/stats/core_stabilizer

/obj/item/augment_kit/combat_matrix
	contained_augment = /datum/augment/skill/combat_matrix

/obj/item/augment_kit/smithing_optimizer
	contained_augment = /datum/augment/skill/smithing_optimizer

/obj/item/augment_kit/weaponcraft_matrix
	contained_augment = /datum/augment/skill/weaponcraft_matrix

/obj/item/augment_kit/engineering_core
	contained_augment = /datum/augment/skill/engineering_core

/obj/item/augment_kit/mining_efficiency
	contained_augment = /datum/augment/skill/mining_efficiency

/obj/item/augment_kit/farming_analyzer
	contained_augment = /datum/augment/skill/farming_analyzer

/obj/item/augment_kit/medicine_database
	contained_augment = /datum/augment/skill/medicine_database

/obj/item/augment_kit/lockpick_analyzer
	contained_augment = /datum/augment/skill/lockpick_analyzer

/obj/item/augment_kit/stealth_dampener
	contained_augment = /datum/augment/skill/stealth_dampener

/obj/item/augment_kit/dualwield
	contained_augment = /datum/augment/special/dualwield

/obj/item/augment_kit/dualwield_refurbished
	contained_augment = /datum/augment/special/dualwield/refurbished

/obj/item/augment_kit/sandevistan
	contained_augment = /datum/augment/special/sandevistan

/obj/item/augment_kit/sandevistan_refurbished
	contained_augment = /datum/augment/special/sandevistan/refurbished

/obj/item/augment_kit/proc/update_augment()
	if(contained_augment)
		name = "[contained_augment.name] kit"
		desc = "[contained_augment.desc]\n\nStability Cost: [contained_augment.stability_cost]\nRequired Skill: Engineering [contained_augment.engineering_difficulty]"
	else
		color = initial(color)
		name = initial(name)
		desc = initial(desc)
	update_appearance(UPDATE_ICON)

/obj/item/augment_kit/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE

	if(!contained_augment)
		to_chat(user, span_warning("[src] is empty!"))
		return ITEM_INTERACT_BLOCKING

	var/mob/living/augmented = interacting_with

	if(!augmented.GetComponent(/datum/component/augmentable))
		to_chat(user, span_warning("[augmented] cannot be augmented!"))
		return ITEM_INTERACT_BLOCKING

	if(!istype(augmented.buckled, /obj/machinery/artificer_table))
		to_chat(user, span_warning("[augmented] must be on an artificer's table!"))
		return ITEM_INTERACT_BLOCKING

	var/skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/craft/engineering)
	if(skill < contained_augment.engineering_difficulty)
		to_chat(user, span_warning("You lack the engineering skill to install this augment!"))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You begin installing [contained_augment.name]..."))

	if(!do_after(user, contained_augment.installation_time, target = augmented))
		return ITEM_INTERACT_BLOCKING

	var/result = SEND_SIGNAL(augmented, COMSIG_AUGMENT_INSTALL, contained_augment, user)
	if(result & COMPONENT_AUGMENT_SUCCESS)
		contained_augment = null
		update_augment()
		playsound(src, 'sound/effects/sparks1.ogg', 75, TRUE)

	return ITEM_INTERACT_SUCCESS

/obj/item/augment_kit/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE

	var/mob/living/augmented = interacting_with

	if(!augmented.GetComponent(/datum/component/augmentable))
		to_chat(user, span_warning("[augmented] cannot be augmented!"))
		return ITEM_INTERACT_BLOCKING

	if(!istype(augmented.buckled, /obj/machinery/artificer_table))
		to_chat(user, span_warning("[augmented] must be on an artificer's table!"))
		return ITEM_INTERACT_BLOCKING

	if(contained_augment)
		to_chat(user, span_warning("[src] has an augment in it!"))
		return ITEM_INTERACT_BLOCKING

	var/list/augments = list()
	SEND_SIGNAL(augmented, COMSIG_AUGMENT_GET_INSTALLED, augments)
	if(!length(augments))
		to_chat(user, span_warning("[augmented] has no augments."))
		return ITEM_INTERACT_BLOCKING

	var/list/names = list()
	var/i = 0
	for(var/datum/augment/A in augments)
		i++
		names["[i]. [A.name]"] = A

	var/chosen = tgui_input_list(user, "Collect which augment?", "Artificer", names, timeout = 20 SECONDS)
	var/datum/augment/to_remove = names[chosen]
	if(!chosen || QDELETED(to_remove) || QDELETED(augmented))
		return ITEM_INTERACT_BLOCKING

	var/skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/craft/engineering)
	if(skill < to_remove.engineering_difficulty)
		to_chat(user, span_warning("You lack the engineering skill to uninstall this augment!"))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You begin uninstalling the [to_remove.name]..."))
	if(!do_after(user, to_remove.installation_time, target = augmented))
		return ITEM_INTERACT_BLOCKING

	var/result = SEND_SIGNAL(augmented, COMSIG_AUGMENT_REMOVE, to_remove, user)
	if(result & COMPONENT_AUGMENT_SUCCESS)
		contained_augment = to_remove
		update_augment()
		playsound(src, 'sound/effects/sparks1.ogg', 75, TRUE)

	return ITEM_INTERACT_SUCCESS
