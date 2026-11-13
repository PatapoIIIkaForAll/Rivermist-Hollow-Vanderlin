/mob/living/simple_animal/mothbug
	name = "mothbug"
	desc = "A moth the size of a cat, its dusty wings marked with pale eye-spots. It smells of old wardrobes."
	icon = 'modular_rmh/icons/mob/mothbug.dmi'
	icon_state = "mothbug"
	icon_living = "mothbug"
	icon_dead = "mothbug_dead"
	health = 60
	maxHealth = 60
	speed = MOTHBUG_GROUND_SPEED
	density = FALSE
	pass_flags = PASSTABLE|PASSWINDOW
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	melee_damage_lower = 0
	melee_damage_upper = 0
	harm_intent_damage = 0
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	food_max = 0
	wander = FALSE
	speak_emote = list("chitters")
	response_help_continuous = "strokes"
	response_help_simple = "stroke"
	response_disarm_continuous = "swats"
	response_disarm_simple = "swat"
	friendly_verb_continuous = "flutters its antennae at"
	friendly_verb_simple = "flutter my antennae at"
	faction = list(FACTION_MOTHBUG)
	hud_type = /datum/hud/mothbug
	butcher_results = list()
	/// Silk charge pays for every ability and comes only from eating fabric.
	var/silk_charge = MOTHBUG_ADULT_START_CHARGE
	var/max_silk_charge = MOTHBUG_ADULT_MAX_CHARGE
	/// Lifetime fabric value this body has eaten.
	var/fabric_eaten = 0
	var/eat_time = MOTHBUG_EAT_TIME
	/// Charge multiplier for food; hatchlings digest fabric better.
	var/food_multiplier = 1
	var/antag_datum_type = /datum/antagonist/mothbug
	var/list/innate_action_types = list(
		/datum/action/cooldown/mothbug/hide,
		/datum/action/cooldown/mothbug/spin_web,
		/datum/action/cooldown/mothbug/silk_snare,
		/datum/action/cooldown/mothbug/targeted/silk_bind,
		/datum/action/cooldown/mothbug/targeted/cocoon,
		/datum/action/cooldown/mothbug/wing_dust,
		/datum/action/cooldown/mothbug/take_wing,
		/datum/action/cooldown/mothbug/lay_egg,
		/datum/action/cooldown/mothbug/squeeze,
	)
	var/list/datum/action/innate_actions = list()
	var/hidden = FALSE
	var/list/obj/structure/mothbug_snare/snares = list()
	var/hatched_at = 0
	/// Adults grow a silken ovipositor for laying eggs into partners.
	var/can_lay_eggs = TRUE

/mob/living/simple_animal/mothbug/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_WEBWALK, TRAIT_GENERIC)
	hatched_at = world.time
	if(can_lay_eggs)
		grow_ovipositor()
	for(var/action_type in innate_action_types)
		var/datum/action/action = new action_type(src)
		action.Grant(src)
		innate_actions += action

/mob/living/simple_animal/mothbug/Destroy()
	QDEL_LIST(innate_actions)
	for(var/obj/structure/mothbug_snare/snare as anything in snares)
		snare.spinner_ref = null
	snares = null
	QDEL_NULL(flight_shadow)
	if(hide_light_timer)
		deltimer(hide_light_timer)
	return ..()

/mob/living/simple_animal/mothbug/Login()
	. = ..()
	ensure_mothbug_antag()

/mob/living/simple_animal/mothbug/proc/ensure_mothbug_antag()
	if(!mind || !antag_datum_type || mind.has_antag_datum(/datum/antagonist/mothbug))
		return
	mind.add_antag_datum(antag_datum_type)

// Mothbugs have no walk or run; their speed var is their whole move delay.
/mob/living/simple_animal/mothbug/update_move_intent_slowdown()
	remove_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED)

/mob/living/simple_animal/mothbug/death(gibbed)
	set_mothbug_hidden(FALSE)
	if(flying)
		end_mothbug_flight()
	return ..()

/mob/living/simple_animal/mothbug/examine(mob/user)
	. = ..()
	if(user == src || isobserver(user) || user.mind?.has_antag_datum(/datum/antagonist/mothbug))
		. += span_notice("Silk: [round(silk_charge)]/[max_silk_charge].")

/mob/living/simple_animal/mothbug/proc/get_mothbug_colony()
	var/datum/antagonist/mothbug/moth_datum = mind?.has_antag_datum(/datum/antagonist/mothbug)
	return moth_datum?.colony

/mob/living/simple_animal/mothbug/proc/has_silk_charge(amount)
	return silk_charge >= amount

/mob/living/simple_animal/mothbug/proc/spend_silk_charge(amount, feedback = TRUE)
	if(!has_silk_charge(amount))
		if(feedback)
			to_chat(src, span_warning("I need [amount] silk for that, but I have only [round(silk_charge)]."))
		return FALSE
	adjust_silk_charge(-amount)
	return TRUE

/mob/living/simple_animal/mothbug/proc/adjust_silk_charge(amount)
	silk_charge = clamp(silk_charge + amount, 0, max_silk_charge)
	update_silk_display()
	return silk_charge

/mob/living/simple_animal/mothbug/proc/update_silk_display()
	var/datum/hud/mothbug/moth_hud = hud_used
	if(istype(moth_hud))
		moth_hud.silk_display?.update_silk(silk_charge, max_silk_charge)

/mob/living/simple_animal/mothbug/UnarmedAttack(atom/A, proximity_flag, list/modifiers, atom/source)
	if(stat != CONSCIOUS || !Adjacent(A))
		return
	if(isliving(A))
		if(A != src)
			INVOKE_ASYNC(src, PROC_REF(touch_living), A)
		return
	if(isobj(A) && get_mothbug_fabric_value(A))
		INVOKE_ASYNC(src, PROC_REF(try_eat_fabric), A)
		return
	if(istype(A, /obj/structure/closet))
		INVOKE_ASYNC(src, PROC_REF(use_closet), A)
		return
	if(length(get_mothbug_edible_contents(A)))
		INVOKE_ASYNC(src, PROC_REF(try_eat_from_container), A)
		return
	return ..()

/mob/living/simple_animal/mothbug/hatchling
	name = "mothling"
	desc = "A pale, fuzzy grub with a moth's feathery antennae. It chews at anything woven."
	icon_state = "mothling"
	icon_living = "mothling"
	icon_dead = "mothling_dead"
	health = 25
	maxHealth = 25
	speed = MOTHBUG_HATCHLING_SPEED
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE|PASSMOB|PASSWINDOW
	can_be_held = TRUE
	silk_charge = MOTHBUG_HATCHLING_START_CHARGE
	max_silk_charge = MOTHBUG_HATCHLING_MAX_CHARGE
	eat_time = MOTHBUG_HATCHLING_EAT_TIME
	food_multiplier = 1.25
	antag_datum_type = /datum/antagonist/mothbug/hatchling
	can_lay_eggs = FALSE
	innate_action_types = list(
		/datum/action/cooldown/mothbug/hide,
		/datum/action/cooldown/mothbug/spin_web,
		/datum/action/cooldown/mothbug/pupate,
		/datum/action/cooldown/mothbug/squeeze,
	)
