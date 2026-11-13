/// Repair value per unit: list(damage mended, biggest injury it can mend or 0 for any). First match wins.
GLOBAL_LIST_INIT(robotic_repair_materials, list(
	/obj/item/ingot/blacksteel = list(35, 0),
	/obj/item/ingot/thaumic = list(35, 0),
	/obj/item/ingot/steel = list(28, 0),
	/obj/item/gear/metal = list(25, 0),
	/obj/item/ingot/gold = list(24, 0),
	/obj/item/ingot/silver = list(24, 0),
	/obj/item/ingot/bronze = list(22, 0),
	/obj/item/ingot/iron = list(20, 0),
	/obj/item/ingot/copper = list(16, 50),
	/obj/item/ingot/tin = list(14, 50),
	/obj/item/grown/log/tree/small = list(12, 35),
	/obj/item/natural/wood/plank = list(10, 35),
	/obj/item/natural/stone = list(10, 35),
	/obj/item/natural/silk = list(8, 25),
	/obj/item/natural/glass = list(8, 25),
	/obj/item/natural/clay = list(6, 25),
	/obj/item/natural/cloth = list(6, 25),
	/obj/item/natural/fibers = list(4, 15),
	/obj/item/grown/log/tree/stick = list(4, 15),
))

/// Robotic limbs mend with a hammer and material in the other hand; better material mends more and deeper.
/datum/component/easy_repair
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/easy_repair/Initialize(mapload)
	. = ..()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/easy_repair/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attacked))

/datum/component/easy_repair/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)

/datum/component/easy_repair/proc/on_attacked(datum/source, obj/item/held, mob/living/carbon/attacker, modifiers)
	SIGNAL_HANDLER

	if(!istype(held, /obj/item/weapon/hammer) || !istype(attacker) || attacker.cmode)
		return NONE

	var/mob/living/carbon/carbon_parent = parent
	var/obj/item/bodypart/targeted_part = carbon_parent.get_bodypart(check_zone(attacker.zone_selected))
	if(!targeted_part || targeted_part.status != BODYPART_ROBOTIC)
		return NONE

	if(!get_material_stats(attacker.get_inactive_held_item()))
		to_chat(attacker, span_warning("I need repair material in my other hand: fibers, cloth, clay, wood, stone, ingots or gears."))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!needs_repair(targeted_part))
		to_chat(attacker, span_notice("\The [targeted_part] needs no repair."))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(repair_loop), held, attacker, targeted_part)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/easy_repair/proc/needs_repair(obj/item/bodypart/part)
	return part.get_damage() > 0 || length(part.wounds)

/// Returns the repair stats for a held material, reading a bundle as its single item.
/datum/component/easy_repair/proc/get_material_stats(obj/item/material)
	if(!istype(material))
		return
	var/material_type = material.type
	if(istype(material, /obj/item/natural/bundle))
		var/obj/item/natural/bundle/bundle = material
		material_type = bundle.stacktype
	for(var/repair_type in GLOB.robotic_repair_materials)
		if(ispath(material_type, repair_type))
			return GLOB.robotic_repair_materials[repair_type]

/datum/component/easy_repair/proc/consume_material(obj/item/material)
	if(istype(material, /obj/item/natural/bundle))
		var/obj/item/natural/bundle/bundle = material
		bundle.amount--
		if(bundle.amount > 0)
			bundle.update_bundle()
			return
	qdel(material)

/datum/component/easy_repair/proc/repair_loop(obj/item/hammer, mob/living/carbon/attacker, obj/item/bodypart/part)
	var/mob/living/carbon/carbon_parent = parent
	var/self_repair = (attacker == carbon_parent)
	while(needs_repair(part) && part.owner == carbon_parent)
		var/obj/item/material = attacker.get_inactive_held_item()
		var/list/stats = get_material_stats(material)
		if(!stats)
			to_chat(attacker, span_warning("I have no repair material left in my other hand."))
			return
		if(!do_after(attacker, self_repair ? 4.5 SECONDS : 3 SECONDS, carbon_parent))
			return
		if(QDELETED(material) || attacker.get_inactive_held_item() != material || attacker.get_active_held_item() != hammer)
			return
		var/budget = stats[1] * max(1, 0.5 * GET_MOB_SKILL_VALUE_OLD(attacker, /datum/attribute/skill/craft/engineering))
		if(self_repair)
			budget *= 0.5
		var/material_name = material.name
		if(istype(material, /obj/item/natural/bundle))
			var/obj/item/natural/bundle/bundle = material
			material_name = bundle.stackname
		if(!mend_part(part, budget, stats[2]))
			to_chat(attacker, span_warning("The [material_name] is too flimsy for the damage left on \the [part]. I need sturdier material."))
			return
		consume_material(material)
		hammer.play_tool_sound(carbon_parent)
		attacker.visible_message(
			span_notice("[attacker] works [material_name] into [self_repair ? attacker.p_their() : "[carbon_parent]'s"] [part.name] with [hammer]."),
			span_notice("I work [material_name] into [self_repair ? "my" : "[carbon_parent]'s"] [part.name], mending the damage.")
		)
		attacker.adjust_experience(/datum/attribute/skill/craft/engineering, 10)

/// Spends the budget on injuries, then on wounds for materials with no size limit. Returns the amount mended.
/datum/component/easy_repair/proc/mend_part(obj/item/bodypart/part, budget, size_cutoff)
	var/start_budget = budget
	for(var/datum/injury/injury as anything in part.injuries.Copy())
		if(budget <= 0)
			break
		if(!injury.can_heal() || (size_cutoff && injury.damage_per_injury() > size_cutoff))
			continue
		budget = injury.heal_damage(budget)
	if(!size_cutoff)
		for(var/datum/wound/wound as anything in part.wounds?.Copy())
			if(budget <= 0)
				break
			budget -= wound.heal_wound(budget)
	if(budget >= start_budget)
		return 0
	if(part.post_damage_change())
		part.owner?.update_damage_overlays()
	return start_budget - budget
