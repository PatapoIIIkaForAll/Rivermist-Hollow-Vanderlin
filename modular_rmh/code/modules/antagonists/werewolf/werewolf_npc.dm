
/mob/living/simple_animal/hostile/werewolf
	name = "WEREWOLF"
	desc = ""
	// Keep in step with the lean look; revive() resets to this icon.
	icon = 'modular_rmh/icons/mob/monster/werewolf.dmi'
	icon_state = "wwolf_m"
	icon_living = "wwolf_m"
	icon_dead = "wwolf_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speak_chance = 80
	maxHealth = 220
	health = 220
	melee_damage_lower = 15
	melee_damage_upper = 18
	base_strength = 15
	base_endurance = 15
	base_speed = 15
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = BLADEWOOSH_LARGE
	dextrous = TRUE
	held_items = list(null, null)
//	base_intents = list(INTENT_HELP, INTENT_GRAB, /datum/intent/simple/claw/wwolf)
	faction = list(FACTION_WOLVES)
	food_type = list(
		/obj/item/bodypart,
		/obj/item/organ,
	)
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	footstep_type = FOOTSTEP_MOB_HEAVY
	ai_controller = /datum/ai_controller/troll
	penis_organ = /obj/item/organ/genitals/penis/knotted/big
	/// Shares the player beast's art set.
	var/form_look_id = WEREWOLF_LOOK_LEAN

/mob/living/simple_animal/hostile/werewolf/Initialize()
	. = ..()
	var/datum/werewolf_form_look/look = get_werewolf_form_look(form_look_id)
	set_base_pixel_x(look.pixel_x)
	set_base_pixel_y(look.pixel_y)
	regenerate_icons()
	ADD_TRAIT(src, TRAIT_SIMPLE_WOUNDS, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_CRITICAL_WEAKNESS, TRAIT_GENERIC)
	RegisterSignal(src, COMSIG_SEX_CLIMAX, PROC_REF(on_beast_climax))

/// The bred human when this beast climaxed inside a vagina or anus, else null.
/mob/living/simple_animal/hostile/werewolf/proc/get_seeded_human(datum/sex_action/action, intimate)
	if(!intimate || !action || !ispath(action.stored_item_type, /obj/item/organ/genitals/penis))
		return null
	if(action.hole_id != ORGAN_SLOT_VAGINA && action.hole_id != ORGAN_SLOT_ANUS)
		return null
	if(action.get_storage_insertor(action.action_user, action.action_target) != src)
		return null
	var/mob/living/carbon/human/receiver = action.get_storage_receiver(action.action_user, action.action_target)
	return ishuman(receiver) ? receiver : null

/mob/living/simple_animal/hostile/werewolf/proc/on_beast_climax(mob/living/source, datum/sex_action/action, mob/living/initiator, mob/living/target, atom/performer, intimate)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/receiver = get_seeded_human(action, intimate)
	if(!receiver?.can_receive_werewolf_conversion_offer())
		return
	// The climax knot ties after this signal, so the roll waits a tick to see it.
	addtimer(CALLBACK(src, PROC_REF(roll_mooncurse_seed), WEAKREF(receiver)), 1)

/// Rolls the curse for a human this beast bred; a pup made this way has no elder.
/mob/living/simple_animal/hostile/werewolf/proc/roll_mooncurse_seed(datum/weakref/receiver_ref)
	var/mob/living/carbon/human/receiver = receiver_ref?.resolve()
	if(QDELETED(receiver) || stat == DEAD)
		return FALSE
	var/datum/component/knotting/knot = GetComponent(/datum/component/knotting)
	if(!prob(get_werewolf_seed_conversion_chance(knot?.knotted_recipient == receiver, receiver, src)))
		return FALSE
	return receiver.request_werewolf_conversion(
		null,
		src,
		"Mooncursed Seed",
		"[src]'s seed carries the mooncurse. Do I accept the beast within?",
	)

/mob/living/simple_animal/hostile/werewolf/regenerate_icons()
	var/datum/werewolf_form_look/look = get_werewolf_form_look(form_look_id)
	icon = look.icon
	icon_living = look.get_body_state(gender)
	icon_dead = look.dead_state
	icon_state = stat == DEAD ? icon_dead : icon_living
	update_inv_hands()
	update_damage_overlays()

/mob/living/simple_animal/hostile/werewolf/update_damage_overlays()
	remove_overlay(DAMAGE_LAYER)
	var/datum/werewolf_form_look/look = get_werewolf_form_look(form_look_id)
	var/damage_state = stat == DEAD ? look.dead_damage_state : look.get_damage_state(gender)
	var/damage_alpha = clamp(255 - 255 * (health / maxHealth), 0, 255)
	if(!damage_alpha || !look.has_state(damage_state))
		return
	var/mutable_appearance/damage_overlay = mutable_appearance(look.icon, damage_state, -DAMAGE_LAYER)
	damage_overlay.alpha = damage_alpha
	overlays_standing[DAMAGE_LAYER] = damage_overlay
	apply_overlay(DAMAGE_LAYER)
