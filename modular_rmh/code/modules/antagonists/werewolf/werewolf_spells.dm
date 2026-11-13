/datum/action/cooldown/spell/undirected/howl
	name = "Howl"
	desc = "Howl to the hidden moon to communicate with fellow wolves. Those versed in Beast Tongue may also understand you."
	button_icon_state = "howl"

	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK

	charge_required = FALSE
	cooldown_time = 1 MINUTES

	var/message
	var/use_language = TRUE
	var/howl_distance_limit = 500

	var/list/howl_sounds = list(
		'sound/vo/mobs/wwolf/howl (1).ogg',
		'sound/vo/mobs/wwolf/howl (2).ogg',
	)

	var/list/howl_sounds_far = list(
		'sound/vo/mobs/wwolf/howldist (1).ogg',
		'sound/vo/mobs/wwolf/howldist (2).ogg',
	)


/datum/action/cooldown/spell/undirected/howl/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	message = browser_input_text(
		owner,
		"Howl at the hidden moon...",
		"MOONCURSED",
		multiline = TRUE,
	)

	if(QDELETED(src) || QDELETED(owner) || !can_cast_spell())
		return . | SPELL_CANCEL_CAST
	if(!message)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST


/datum/action/cooldown/spell/undirected/howl/cast(atom/cast_on)
	. = ..()

	if(!owner || !message)
		return

	// Normal/close howl for the caster.
	playsound(
		owner,
		pick(howl_sounds),
		75,
		TRUE,
	)

	var/datum/antagonist/werewolf/werewolf_antag
	if(owner.mind)
		werewolf_antag = owner.mind.has_antag_datum(/datum/antagonist/werewolf)

	var/howler_name = owner.real_name
	if(werewolf_antag)
		howler_name = werewolf_antag.get_howl_name()

	// The caster sees their own howl.
	to_chat(
		owner,
		span_boldannounce("I howl to the hidden moon: \"[message]\""),
	)

	for(var/mob/player as anything in (GLOB.player_list - owner))
		if(!player.mind)
			continue

		if(player.stat == DEAD)
			continue

		if(isbrain(player))
			continue

		// Werewolf understand it too
		var/can_understand_howl = FALSE

		if(player.mind.has_antag_datum(/datum/antagonist/werewolf))
			can_understand_howl = TRUE

		else if(use_language && player.has_language(/datum/language/beast))
			can_understand_howl = TRUE

		if(can_understand_howl)
			to_chat(
				player,
				span_boldannounce("[howler_name] howls to the hidden moon: \"[message]\""),
			)

		// Distant physical sound should not travel between Z-levels.
		if(player.z != owner.z)
			continue

		var/player_distance = get_dist(player, owner)

		if(player_distance > 7 && player_distance <= howl_distance_limit)
			player.playsound_local(
				get_turf(player),
				pick(howl_sounds_far),
				50,
				FALSE,
				pressure_affected = FALSE,
			)

	owner.log_message(
		"howls: [message] (WEREWOLF)",
		LOG_GAME,
	)

	// Avoid keeping the previous text around between casts.
	message = null

/// Name other wolves hear on a howl; pups add their elder.
/datum/antagonist/werewolf/proc/get_howl_name()
	return wolfname

/datum/action/cooldown/spell/undirected/claws
	name = "Lupine Claws"
	desc = "!"
	button_icon_state = "claws"
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null

	charge_required = FALSE
	cooldown_time = 5 SECONDS

	var/extended = FALSE
	var/datum/weakref/left_claw_ref
	var/datum/weakref/right_claw_ref

/datum/action/cooldown/spell/undirected/claws/proc/get_lupine_claw(datum/weakref/claw_ref)
	if(!claw_ref)
		return null

	var/obj/item/weapon/werewolf_claw/claw = claw_ref.resolve()
	if(claw)
		return claw

	return null

/datum/action/cooldown/spell/undirected/claws/proc/clear_lupine_claw_refs()
	left_claw_ref = null
	right_claw_ref = null

/datum/action/cooldown/spell/undirected/claws/proc/remove_lupine_claw(obj/item/weapon/werewolf_claw/claw_item)
	if(!istype(claw_item))
		return

	if(claw_item.loc == owner)
		owner.dropItemToGround(claw_item, TRUE)

	qdel(claw_item)

/datum/action/cooldown/spell/undirected/claws/proc/retract_lupine_claws()
	remove_lupine_claw(get_lupine_claw(left_claw_ref))
	remove_lupine_claw(get_lupine_claw(right_claw_ref))
	clear_lupine_claw_refs()
	extended = FALSE

/datum/action/cooldown/spell/undirected/claws/cast(atom/cast_on)
	. = ..()
	var/obj/item/weapon/werewolf_claw/left/left_claw
	var/obj/item/weapon/werewolf_claw/right/right_claw

	if(extended)
		retract_lupine_claws()
		return

	left_claw = new(owner, 1)
	right_claw = new(owner, 2)
	left_claw_ref = WEAKREF(left_claw)
	right_claw_ref = WEAKREF(right_claw)
	owner.put_in_hands(left_claw, TRUE, FALSE, TRUE)
	owner.put_in_hands(right_claw, TRUE, FALSE, TRUE)
	//owner.visible_message("Your claws extend.", "You feel your claws extending.", "You hear a sound of claws extending.")
	extended = TRUE

/datum/action/cooldown/spell/woundlick
	name = "Lick the wounds"
	desc = "Heal the wounds of somebody"
	button_icon_state = "diagnose"

	cast_range = 1

	spell_cost = 5
	cooldown_time = 5 SECONDS
	charge_required = FALSE
	associated_skill = null
	has_visual_effects = FALSE

/datum/action/cooldown/spell/woundlick/is_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return ismob(target_atom)

/datum/action/cooldown/spell/woundlick/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!istype(cast_on))
		return

	if(do_after(owner, 7 SECONDS, cast_on))
		var/ramount = 5
		var/rid = /datum/reagent/medicine/healthpot
		cast_on.reagents.add_reagent(rid, ramount)

		if(cast_on.mind?.has_antag_datum(/datum/antagonist/werewolf))
			cast_on.visible_message(span_green("[owner] is licking [cast_on]'s wounds with its tongue!"), span_notice("My kin has covered my wounds..."), vision_distance = COMBAT_MESSAGE_RANGE)
		else
			cast_on.visible_message(span_green("[owner] is licking [cast_on]'s wounds with its tongue!"), span_notice("That thing... Did it lick my wounds?"), vision_distance = COMBAT_MESSAGE_RANGE)
