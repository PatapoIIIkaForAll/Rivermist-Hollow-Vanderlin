/// Version used by werewolf antag
/datum/action/cooldown/spell/undirected/werewolf_form
	name = "Toggle Transformation"
	desc = "Switch between your human skin and beast form."
	button_icon_state = "tamebeast"

	spell_type = SPELL_RAGE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	has_visual_effects = FALSE

	invocation = null
	invocation_type = INVOCATION_NONE
	ignore_can_speak = TRUE

	charge_required = FALSE
	cooldown_time = WW_TRANSFORMATION_COOLDOWN
	retrigger_after_cooldown = FALSE
	spell_cost = 0

	sound = 'sound/vo/mobs/wwolf/roar.ogg'

/datum/action/cooldown/spell/undirected/werewolf_form/Grant(mob/grant_to)
	if(!IS_WEREWOLF(grant_to))
		return
	return ..()

/datum/action/cooldown/spell/undirected/werewolf_form/proc/set_external_cooldown(override_cooldown_time)
	var/real_time = cooldown_time
	if(isnum(override_cooldown_time))
		real_time = override_cooldown_time

	next_use_time = world.time + real_time
	addtimer(CALLBACK(src, PROC_REF(CooldownEnded)), real_time)
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/undirected/werewolf_form/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(owner))
		return FALSE

	var/time_left = max(next_use_time - world.time, 0)
	if(time_left > 0)
		if(feedback)
			to_chat(owner, span_warning("My form is still settling. I can transform again in [DisplayTimeText(time_left)]."))
		return FALSE

	var/datum/antagonist/werewolf/werewolf_antag = IS_WEREWOLF(owner)
	if(!werewolf_antag)
		return FALSE

	if(werewolf_antag.transformed)
		return werewolf_antag.can_untransform(feedback)

	return werewolf_antag.can_transform(feedback)

/datum/action/cooldown/spell/undirected/werewolf_form/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return .
	return . | SPELL_NO_IMMEDIATE_COOLDOWN | SPELL_NO_FEEDBACK

/datum/action/cooldown/spell/undirected/werewolf_form/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/werewolf/werewolf_antag = IS_WEREWOLF(owner)
	if(!werewolf_antag)
		return
	if(werewolf_antag.transformed)
		werewolf_antag.try_untransform(feedback = TRUE)
		return
	werewolf_antag.try_transform(feedback = TRUE)
