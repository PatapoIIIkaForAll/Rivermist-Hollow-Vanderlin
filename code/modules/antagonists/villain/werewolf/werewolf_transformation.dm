/datum/stress_event/werewolf_restless_1
	desc = "The beast is growing restless beneath my skin."
	stress_change = WW_RESTLESS_STRESS_LIGHT

/datum/stress_event/werewolf_restless_2
	desc = "Denying the beast is becoming unbearable."
	stress_change = WW_RESTLESS_STRESS_MEDIUM

/datum/stress_event/werewolf_restless_3
	desc = "The beast is furious at being denied."
	stress_change = WW_RESTLESS_STRESS_HEAVY

/datum/antagonist/werewolf/on_life(mob/user)
	if(!user)
		return

	var/mob/living/carbon/human/current_body = user
	if(current_body.stat == DEAD)
		return
	if(current_body.advsetup)
		return

	handle_time_of_day(current_body)
	process_pending_forced_transformation()

	if(transformed && !HAS_TRAIT(current_body, TRAIT_PARALYSIS))
		if(current_body.rage_datum?.check_rage(text2num(WW_RAGE_MEDIUM)))
			if(current_body.blood_volume > BLOOD_VOLUME_SURVIVE)
				for(var/datum/wound/wound as anything in current_body.get_wounds())
					wound.heal_wound(1.2)

/datum/antagonist/werewolf/proc/get_human_holder()
	var/mob/living/carbon/human/current_body = owner?.current
	if(!istype(current_body))
		return null
	return current_body.rage_datum?.holder_mob || current_body

/datum/antagonist/werewolf/proc/clear_transformation_pressure()
	var/mob/living/carbon/human/human_holder = get_human_holder()
	if(!human_holder)
		return

	human_holder.remove_stress(list(
		/datum/stress_event/werewolf_restless_1,
		/datum/stress_event/werewolf_restless_2,
		/datum/stress_event/werewolf_restless_3,
	))

/datum/antagonist/werewolf/proc/reset_transformation_pressure()
	nights_without_transformation = 0
	forced_transformation_pending = FALSE
	clear_transformation_pressure()

/datum/antagonist/werewolf/proc/update_transformation_pressure()
	clear_transformation_pressure()

	var/mob/living/carbon/human/human_holder = get_human_holder()
	if(!human_holder || human_holder.stat >= DEAD)
		return

	switch(nights_without_transformation)
		if(1)
			human_holder.add_stress(/datum/stress_event/werewolf_restless_1)
		if(2)
			human_holder.add_stress(/datum/stress_event/werewolf_restless_2)
		if(WW_FORCED_TRANSFORM_NIGHT_COUNT to INFINITY)
			human_holder.add_stress(/datum/stress_event/werewolf_restless_3)

/datum/antagonist/werewolf/proc/mark_transformation_complete()
	transformed_since_last_nightfall = TRUE
	reset_transformation_pressure()
	COOLDOWN_START(src, transformation_cooldown, WW_TRANSFORMATION_COOLDOWN)
	sync_transformation_action_cooldown(WW_TRANSFORMATION_COOLDOWN)

/datum/antagonist/werewolf/proc/sync_transformation_action_cooldown(cooldown_duration)
	var/mob/living/current_body = owner?.current
	if(!istype(current_body))
		return

	var/datum/action/cooldown/spell/undirected/werewolf_form/transformation_action = current_body.get_spell(/datum/action/cooldown/spell/undirected/werewolf_form, TRUE)
	if(!transformation_action)
		return

	transformation_action.set_external_cooldown(cooldown_duration)

/datum/antagonist/werewolf/proc/handle_time_of_day(mob/living/carbon/human/current_body)
	if(last_seen_tod == GLOB.tod)
		return

	var/previous_tod = last_seen_tod
	last_seen_tod = GLOB.tod

	if(isnull(previous_tod))
		return
	if(GLOB.tod != "night")
		return

	handle_nightfall(current_body)

/datum/antagonist/werewolf/proc/handle_nightfall(mob/living/carbon/human/current_body)
	if(transformed || transformed_since_last_nightfall)
		reset_transformation_pressure()
		transformed_since_last_nightfall = FALSE
		return

	nights_without_transformation = min(nights_without_transformation + 1, WW_FORCED_TRANSFORM_NIGHT_COUNT)
	update_transformation_pressure()

	switch(nights_without_transformation)
		if(1)
			to_chat(current_body, span_warning("One night passes without letting the beast out. It grows restless. Two nights left."))
		if(2)
			to_chat(current_body, span_userdanger("Two nights have passed without transforming. The beast claws at my mind. On next night it will claw itself out."))
		if(WW_FORCED_TRANSFORM_NIGHT_COUNT)
			forced_transformation_pending = TRUE
			to_chat(current_body, span_userdanger("Three nights have passed - IT cannot wait any longer!"))
			process_pending_forced_transformation()

	transformed_since_last_nightfall = FALSE

/datum/antagonist/werewolf/proc/process_pending_forced_transformation()
	if(!forced_transformation_pending)
		return
	if(transformed)
		reset_transformation_pressure()
		return
	if(transformation_in_progress)
		return
	if(can_transform())
		begin_transform(force_due_to_missed_nights = TRUE)
		return

	var/mob/living/carbon/human/current_body = owner?.current
	if(!istype(current_body))
		return
	if(!COOLDOWN_FINISHED(src, message_cooldown))
		return

	to_chat(current_body, span_userdanger("The beast strains against my skin, waiting for the moment it can force itself free."))
	COOLDOWN_START(src, message_cooldown, WW_PENDING_TRANSFORM_REMINDER)

/datum/antagonist/werewolf/proc/can_change_forms(feedback = FALSE, ignore_cooldown = FALSE, allow_in_progress = FALSE)
	if(QDELETED(src))
		return FALSE

	var/mob/living/carbon/human/current_body = owner?.current
	if(QDELETED(current_body) || !current_body.mind)
		return FALSE

	if(current_body.stat >= UNCONSCIOUS)
		if(feedback)
			to_chat(current_body, span_warning("I am in no condition to command the beast."))
		return FALSE

	if(!allow_in_progress && transformation_in_progress)
		if(feedback)
			to_chat(current_body, span_warning("My body is already in the middle of changing."))
		return FALSE

	if(!ignore_cooldown && !COOLDOWN_FINISHED(src, transformation_cooldown))
		if(feedback)
			to_chat(current_body, span_warning("My form is still settling. I can transform again in [DisplayTimeText(COOLDOWN_TIMELEFT(src, transformation_cooldown))]."))
		return FALSE

	return TRUE

/datum/antagonist/werewolf/proc/can_transform(feedback = FALSE, ignore_cooldown = FALSE, allow_in_progress = FALSE)
	if(!can_change_forms(feedback, ignore_cooldown, allow_in_progress))
		return FALSE

	var/mob/living/carbon/human/current_body = owner.current
	if(HAS_TRAIT(current_body, TRAIT_NO_TRANSFORM))
		if(feedback)
			to_chat(current_body, span_warning("Something prevents my body from changing right now."))
		return FALSE
	if(HAS_TRAIT(current_body, TRAIT_SILVER_BLESSED))
		if(feedback)
			to_chat(current_body, span_warning("A holy blessing keeps the beast caged."))
		return FALSE
	if(transformed)
		if(feedback)
			to_chat(current_body, span_warning("I am already in my beast form."))
		return FALSE

	return TRUE

/datum/antagonist/werewolf/proc/can_untransform(feedback = FALSE, ignore_cooldown = FALSE)
	if(!can_change_forms(feedback, ignore_cooldown))
		return FALSE
	if(!transformed)
		if(feedback)
			to_chat(owner.current, span_warning("I am already wearing my human skin."))
		return FALSE
	return TRUE

/datum/antagonist/werewolf/proc/toggle_transformation(mob/living/carbon/human/requester)
	if(!istype(requester))
		return FALSE
	if(owner.current != requester)
		return FALSE
	if(transformed)
		return try_untransform(feedback = TRUE)
	return try_transform(feedback = TRUE)

/datum/antagonist/werewolf/proc/try_transform(feedback = FALSE, force_due_to_missed_nights = FALSE)
	if(!can_transform(feedback))
		return FALSE
	begin_transform(force_due_to_missed_nights)
	return TRUE

/datum/antagonist/werewolf/proc/try_untransform(feedback = FALSE)
	if(!can_untransform(feedback))
		return FALSE
	remove_werewolf(FALSE)
	return TRUE

/datum/antagonist/werewolf/proc/begin_transform(force_due_to_missed_nights = FALSE)
	set waitfor = FALSE

	if(!can_transform())
		return FALSE

	var/mob/living/carbon/human/human_user = owner.current
	transformation_in_progress = TRUE
	ADD_TRAIT(human_user, TRAIT_NO_TRANSFORM, REF(src))
	human_user.flash_fullscreen("redflash3")
	human_user.emote("agony", forced = TRUE)
	if(force_due_to_missed_nights)
		to_chat(human_user, span_userdanger("Three nights denied. The beast tears free!"))
	else
		to_chat(human_user, span_userdanger("UNIMAGINABLE PAIN!"))
	human_user.Stun(WW_TRANSFORMATION_LOCKDOWN, ignore_canstun = TRUE)
	//human_user.Knockdown(WW_TRANSFORMATION_LOCKDOWN, ignore_canstun = TRUE)
	sleep(WW_TRANSFORMATION_AGONY_INTERVAL)
	//if(!QDELETED(human_user))
	//	human_user.emote("agony", forced = TRUE)
	sleep(WW_TRANSFORMATION_AGONY_INTERVAL)
	if(!QDELETED(human_user))
		REMOVE_TRAIT(human_user, TRAIT_NO_TRANSFORM, REF(src))

	if(!can_transform(FALSE, FALSE, TRUE))
		transformation_in_progress = FALSE
		return FALSE

	return werewolf_transform(force_due_to_missed_nights)

/datum/antagonist/werewolf/proc/werewolf_transform(force_due_to_missed_nights = FALSE)
	if(!can_transform(FALSE, FALSE, TRUE))
		transformation_in_progress = FALSE
		return FALSE

	var/mob/living/carbon/human/human_user = owner.current

	if(human_user.cmode)
		human_user.toggle_cmode()

	pre_transformation()

	var/mob/living/carbon/human/species/werewolf/new_werewolf = generate_werewolf(human_user)
	new_werewolf.apply_status_effect(/datum/status_effect/shapechange_mob/die_with_form, human_user, FALSE)
	new_werewolf.dna?.species.after_creation(new_werewolf) // funny accented werewolf
	new_werewolf.set_patron(human_user.patron)
	human_user.rage_datum.grant_to_secondary(new_werewolf)
	human_user.rage_datum.rage_change_on_life -= transformed_rage_decay

	new_werewolf.blood_volume = human_user.blood_volume
	human_user.fully_heal(HEAL_DAMAGE|HEAL_BLOOD|HEAL_WOUNDS|HEAL_RESTRAINTS)

	if(human_user.getorganslot(ORGAN_SLOT_PENIS))
		var/obj/item/organ/genitals/penis/penis = new_werewolf.getorganslot(ORGAN_SLOT_PENIS)
		penis = new /obj/item/organ/genitals/penis/knotted/big
		penis.Insert(new_werewolf, TRUE)
	if(human_user.getorganslot(ORGAN_SLOT_TESTICLES))
		var/obj/item/organ/genitals/filling_organ/testicles/testicles = new_werewolf.getorganslot(ORGAN_SLOT_TESTICLES)
		testicles = new /obj/item/organ/genitals/filling_organ/testicles/internal
		testicles.Insert(new_werewolf, TRUE)
	if(human_user.getorganslot(ORGAN_SLOT_BREASTS))
		var/obj/item/organ/genitals/filling_organ/breasts/breasts = new_werewolf.getorganslot(ORGAN_SLOT_BREASTS)
		breasts = new /obj/item/organ/genitals/filling_organ/breasts
		breasts.Insert(new_werewolf, TRUE)
	if(human_user.getorganslot(ORGAN_SLOT_VAGINA))
		var/obj/item/organ/genitals/filling_organ/vagina/vagina = new_werewolf.getorganslot(ORGAN_SLOT_VAGINA)
		vagina = new /obj/item/organ/genitals/filling_organ/vagina
		vagina.Insert(new_werewolf, TRUE)

	playsound(new_werewolf, pick('sound/combat/gib (1).ogg', 'sound/combat/gib (2).ogg'), 200, FALSE, 3)
	new_werewolf.playsound_local(get_turf(new_werewolf), 'sound/music/wolfintro.ogg', 80, FALSE, pressure_affected = FALSE)
	if(force_due_to_missed_nights)
		to_chat(new_werewolf, span_userdanger("The beast will not be denied any longer!"))
	else
		to_chat(new_werewolf, span_userdanger("I transform into a horrible beast!"))
	new_werewolf.emote("rage")

	transformed = TRUE
	transformation_in_progress = FALSE
	mark_transformation_complete()
	RegisterSignal(new_werewolf, COMSIG_LIVING_UNSHAPESHIFTED, PROC_REF(werewolf_untransform))
	return TRUE

/datum/antagonist/werewolf/proc/pre_transformation()
	var/mob/living/carbon/human/human_user = owner.current
	for(var/obj/item/item as anything in human_user.get_equipped_items(FALSE))
		if(istype(item, /obj/item/clothing) || istype(item, /obj/item/storage/belt))
			item.take_damage(damage_amount = item.max_integrity * 0.15, sound_effect = FALSE)
		else
			human_user.dropItemToGround(item, silent = TRUE)

/datum/antagonist/werewolf/proc/generate_werewolf(mob/living/carbon/human/user)
	var/mob/living/carbon/human/species/werewolf/new_werewolf = new (get_turf(user))
	new_werewolf.age = user.age
	new_werewolf.real_name = wolfname
	new_werewolf.name = wolfname
	new_werewolf.skin_armor = new /obj/item/clothing/armor/regenerating/skin/werewolf_skin(new_werewolf)

	new_werewolf.adjust_skillrank(/datum/skill/combat/wrestling, 5, TRUE)
	new_werewolf.adjust_skillrank(/datum/skill/combat/unarmed, 5, TRUE)
	new_werewolf.adjust_skillrank(/datum/skill/misc/climbing, 6, TRUE)

	for(var/datum/action/werewolf_power as anything in werewolf_form_powers)
		new_werewolf.add_spell(werewolf_power)

	return new_werewolf

/// Helper to remove werewolf transformation effect from owner.current.
/datum/antagonist/werewolf/proc/remove_werewolf(forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/werewolf_user = owner.current
	if(!transformed)
		return
	if(!forced && HAS_TRAIT(werewolf_user, TRAIT_NO_TRANSFORM))
		return
	werewolf_user.remove_status_effect(/datum/status_effect/shapechange_mob/die_with_form)

/// Called with COMSIG_LIVING_UNSHAPESHIFTED signal.
/datum/antagonist/werewolf/proc/werewolf_untransform(mob/living/status_owner, mob/living/status_caster_mob)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/werewolf_user = status_owner
	var/mob/living/carbon/human/caster_mob = status_caster_mob
	if(!istype(werewolf_user) || !istype(caster_mob))
		transformed = FALSE
		transformation_in_progress = FALSE
		return

	for(var/obj/item/dropped_item in werewolf_user)
		werewolf_user.dropItemToGround(dropped_item, silent = TRUE)

	INVOKE_ASYNC(werewolf_user, TYPE_PROC_REF(/mob, emote), "scream")

	to_chat(caster_mob, span_userdanger("The beast within returns to slumber."))
	playsound(caster_mob, pick('sound/combat/gib (1).ogg', 'sound/combat/gib (2).ogg'), 200, FALSE, 3)
	caster_mob.Knockdown(30)
	caster_mob.Stun(30)
	caster_mob.rage_datum.remove_secondary()
	caster_mob.rage_datum.rage_change_on_life += transformed_rage_decay

	caster_mob.adjustBruteLoss(werewolf_user.getBruteLoss() / 2)
	caster_mob.adjustFireLoss(werewolf_user.getFireLoss() / 2)
	caster_mob.adjustToxLoss(werewolf_user.getToxLoss() / 2)
	caster_mob.adjustOxyLoss(werewolf_user.getOxyLoss() / 2)
	caster_mob.adjustCloneLoss(werewolf_user.getCloneLoss() / 2)

	UnregisterSignal(werewolf_user, COMSIG_LIVING_UNSHAPESHIFTED)
	transformed = FALSE
	transformation_in_progress = FALSE
	mark_transformation_complete()
