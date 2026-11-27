/obj/item/storage/backpack/satchel/gnoll
	name = "pack satchel"
	desc = "A weathered hide satchel for supplies gathered along the pack's wild trails."
	mob_overlay_icon = null

// These pouches must accept the normal-sized bottles they start with.
/datum/component/storage/concrete/grid/coin_pouch/gnoll
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/belt/pouch/gnoll
	name = "pack pouch"
	desc = "A sturdy hide pouch for the pack's remedies and small supplies."
	component_type = /datum/component/storage/concrete/grid/coin_pouch/gnoll

/obj/item/storage/belt/pouch/gnoll/healing
	name = "pack healing pouch"
	populate_contents = list(
		/obj/item/reagent_containers/glass/bottle/healthpot,
		/obj/item/reagent_containers/glass/bottle/healthpot,
		/obj/item/needle,
	)

/obj/item/storage/belt/pouch/gnoll/alchemy
	name = "pack alchemy pouch"
	populate_contents = list(
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/needle,
	)

/obj/item/gnoll_ritual_chalk
	parent_type = /obj/item/gnoll_trail_charm
	name = "Gorellik's ritual chalk"
	desc = "Earth-colored chalk for consecrating the pack's wilderness trails. Use it during a trail contract to leave a washable mark."
	icon = 'icons/roguetown/misc/rituals.dmi'
	icon_state = "chalk"
	trail_message = "marks a wild trail with Gorellik's ritual chalk"
	trail_mark_type = /obj/effect/decal/cleanable/gnoll_trail

/obj/effect/decal/cleanable/gnoll_trail
	name = "Gorellik's trail mark"
	desc = "A chalk sigil honoring the wilderness and the living hunt."
	icon = 'icons/roguetown/misc/rituals.dmi'
	icon_state = "dendor_chalky"
	color = "#b58b50"
	layer = SIGIL_LAYER
	rain_washable = FALSE

/datum/intent/gnoll_claw
	name = "claw strike"
	icon_state = "instrike"
	desc = "Strike with the flat of your claws to bring down living quarry."
	blade_class = BCLASS_BLUNT
	item_damage_type = "blunt"
	attack_verb = list("strikes", "buffets")
	miss_text = "swipes at the air!"
	miss_sound = "blunthwoosh"
	misscost = 5

/datum/intent/gnoll_claw/sweep
	name = "claw bash"
	icon_state = "inbash"
	desc = "A quicker, lighter bash with the flat of your claws."
	attack_verb = list("sweeps", "swats")
	damfactor = 0.8
	clickcd = 8

/datum/intent/gnoll_claw/thrash
	name = "claw shove"
	icon_state = "inshove"
	desc = "Wind up a heavy blow that pushes quarry one to five tiles away. Prone quarry travel half as far; each target can only be thrashed once every five seconds."
	attack_verb = list("thrashes", "buffets")
	damfactor = 1.1
	clickcd = 14
	swingdelay = 3
	swingdelay_type = SWINGDELAY_CANCEL
	misscost = 10

/datum/intent/gnoll_claw/heavy
	name = "heavy claw smash"
	icon_state = "insmash"
	desc = "A slower, harder blow to overcome the flat damage absorption of armor."
	damfactor = 1.5
	clickcd = 16
	swingdelay = 3
	swingdelay_type = SWINGDELAY_CANCELSLOW
	misscost = 12

/obj/item/weapon/gnoll_claw
	parent_type = /obj/item/weapon/werewolf_claw
	name = "gnoll claw"
	desc = "A champion's powerful natural claws, turned flat for Gorellik's living hunts."
	force = 30
	wdefense = ULTMATE_PARRY
	wlength = WLENGTH_SHORT
	sharpness = NONE
	damage_type = "blunt"
	experimental_inhand = FALSE
	possible_item_intents = list(/datum/intent/gnoll_claw, /datum/intent/gnoll_claw/sweep, /datum/intent/gnoll_claw/thrash, /datum/intent/gnoll_claw/heavy)

/obj/item/weapon/gnoll_claw/left
	icon_state = "claw_l"

/obj/item/weapon/gnoll_claw/right
	icon_state = "claw_r"

/obj/item/weapon/gnoll_claw/build_worn_icon(age = AGE_ADULT, default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, coom = FALSE, customi = null, sleeveindex, breast_size = 0, icon/clip_mask = null)
	if(isinhands)
		// The complete champion sprite already has claws; keep the item visible only in the hand HUD.
		var/mutable_appearance/natural_claw = mutable_appearance(layer = -default_layer)
		natural_claw.alpha = 0
		return natural_claw
	return ..()

/obj/item/weapon/gnoll_claw/attack(mob/living/target, mob/living/user, list/modifiers)
	if(target.stat == DEAD || target.has_status_effect(/datum/status_effect/defeat_knockout))
		to_chat(user, span_warning("The hunt is over for this quarry. Restore them and let them go."))
		return TRUE
	return ..()

/obj/item/weapon/gnoll_claw/do_special_attack_effect(mob/living/user, obj/item/bodypart/affecting, datum/intent/intent, mob/living/victim, selzone, thrown = FALSE)
	. = ..()
	// Human attacked_by supplies the defender's intent here; use the attacker's current mode.
	if(thrown || !istype(user?.used_intent, /datum/intent/gnoll_claw/thrash) || victim.stat != CONSCIOUS || victim.has_status_effect(/datum/status_effect/defeat_knockout) || victim.has_status_effect(/datum/status_effect/gnoll_thrash_cooldown))
		return
	var/turf/destination = get_edge_target_turf(victim, get_dir(user, victim))
	if(!destination)
		return
	var/distance = CLAMP(GET_MOB_ATTRIBUTE_VALUE(user, STAT_STRENGTH), 1, 5)
	if(victim.body_position == LYING_DOWN)
		distance = max(1, FLOOR(distance / 2, 1))
	victim.apply_status_effect(/datum/status_effect/gnoll_thrash_cooldown)
	victim.safe_throw_at(destination, distance, 1, user, spin = FALSE, force = victim.move_force, callback = CALLBACK(victim, TYPE_PROC_REF(/mob/living, handle_knockback), get_turf(victim)))

// Shared by both claws and other packmates; this has no processing tick.
/datum/status_effect/gnoll_thrash_cooldown
	id = "gnoll_thrash_cooldown"
	duration = 5 SECONDS
	tick_interval = -1
	alert_type = null
