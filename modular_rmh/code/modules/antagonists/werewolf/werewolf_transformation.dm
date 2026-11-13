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

	if(subject_to_moon_pressure)
		handle_time_of_day(current_body)
		process_pending_forced_transformation()

	if(transformed && !HAS_TRAIT(current_body, TRAIT_PARALYSIS))
		handle_beast_rage_life(current_body)

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
		if(WW_RESTLESS_NIGHT_CAP to INFINITY)
			human_holder.add_stress(/datum/stress_event/werewolf_restless_3)

/datum/antagonist/werewolf/proc/mark_transformation_complete()
	transformed_since_last_nightfall = TRUE
	reset_transformation_pressure()
	// Under the full moon the body never needs to settle between forms.
	if(is_full_moon_night())
		return
	var/datum/action/cooldown/spell/undirected/werewolf_form/transformation_action = get_transformation_action()
	transformation_action?.StartCooldown(WW_TRANSFORMATION_COOLDOWN)

/datum/antagonist/werewolf/proc/get_transformation_action()
	RETURN_TYPE(/datum/action/cooldown/spell/undirected/werewolf_form)
	var/mob/living/current_body = owner?.current
	if(!istype(current_body))
		return null
	return current_body.get_spell(/datum/action/cooldown/spell/undirected/werewolf_form, TRUE)

/// Remaining time before another form change is allowed. The toggle action's own cooldown is the single source of truth.
/datum/antagonist/werewolf/proc/get_transformation_cooldown_remaining()
	if(is_full_moon_night())
		return 0
	var/datum/action/cooldown/transformation_action = get_transformation_action()
	if(!transformation_action)
		return 0
	return max(transformation_action.next_use_time - world.time, 0)

/datum/antagonist/werewolf/proc/apply_transformed_rage_decay(datum/rage/rage_datum)
	if(transform_rage_decay_active || !rage_datum)
		return
	rage_datum.rage_change_on_life -= transformed_rage_decay
	transform_rage_decay_active = TRUE

/datum/antagonist/werewolf/proc/remove_transformed_rage_decay(datum/rage/rage_datum)
	if(!transform_rage_decay_active || !rage_datum)
		return
	rage_datum.rage_change_on_life += transformed_rage_decay
	transform_rage_decay_active = FALSE

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

/// Ordinary skipped nights only add restless stress; the full moon alone forces the change.
/datum/antagonist/werewolf/proc/handle_nightfall(mob/living/carbon/human/current_body)
	var/full_moon = is_full_moon_night()
	var/restless_nights = 0
	if(transformed || transformed_since_last_nightfall)
		reset_transformation_pressure()
	else
		nights_without_transformation = min(nights_without_transformation + 1, WW_RESTLESS_NIGHT_CAP)
		update_transformation_pressure()
		restless_nights = nights_without_transformation
	transformed_since_last_nightfall = FALSE

	if(full_moon)
		handle_full_moonrise(current_body)
		return
	announce_moonrise(current_body, restless_nights)

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

	if(!ignore_cooldown)
		var/cooldown_remaining = get_transformation_cooldown_remaining()
		if(cooldown_remaining > 0)
			if(feedback)
				to_chat(current_body, span_warning("My form is still settling. I can transform again in [DisplayTimeText(cooldown_remaining)]."))
			return FALSE

	return TRUE

/datum/antagonist/werewolf/proc/can_transform(feedback = FALSE, ignore_cooldown = FALSE, allow_in_progress = FALSE)
	if(!can_change_forms(feedback, ignore_cooldown, allow_in_progress))
		return FALSE

	var/mob/living/carbon/human/current_body = owner.current
	if(HAS_TRAIT(current_body, TRAIT_WEREWOLF_TRANSFORMATION_SUPPRESSED))
		if(feedback)
			to_chat(current_body, span_warning("Silver bindings keep the beast from taking hold."))
		return FALSE
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
	human_user.emote("scream", forced = TRUE)
	if(force_due_to_missed_nights)
		to_chat(human_user, span_userdanger("The full moon drags the beast out of me!"))
	else
		to_chat(human_user, span_userdanger("The Moon calls!"))
	human_user.Stun(WW_TRANSFORMATION_LOCKDOWN, ignore_canstun = TRUE)
	sleep(WW_TRANSFORMATION_AGONY_INTERVAL)
	human_user.flash_fullscreen("redflash3")
	human_user.emote("scream", forced = TRUE)
	sleep(WW_TRANSFORMATION_AGONY_INTERVAL)
	if(!QDELETED(human_user))
		REMOVE_TRAIT(human_user, TRAIT_NO_TRANSFORM, REF(src))

	if(!can_transform(TRUE, FALSE, TRUE))
		transformation_in_progress = FALSE
		if(!QDELETED(human_user))
			human_user.SetStun(0, ignore_canstun = TRUE)
			to_chat(human_user, span_warning("The change collapses and the beast recoils beneath my skin."))
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
	new_werewolf.apply_status_effect(/datum/status_effect/shapechange_mob/die_with_form, human_user)
	transfer_skill_state_to_werewolf(human_user, new_werewolf)
	apply_werewolf_transformation_bonuses(new_werewolf)
	new_werewolf.dna?.species.after_creation(new_werewolf) // funny accented werewolf
	new_werewolf.set_patron(human_user.patron)
	human_user.rage_datum.grant_to_secondary(new_werewolf)
	apply_transformed_rage_decay(human_user.rage_datum)

	new_werewolf.blood_volume = human_user.blood_volume
	human_user.fully_heal(HEAL_DAMAGE|HEAL_BLOOD|HEAL_WOUNDS|HEAL_RESTRAINTS)

	apply_beast_anatomy(human_user, new_werewolf)
	apply_beast_profile(human_user, new_werewolf)

	transformed = TRUE
	transformation_in_progress = FALSE

	var/datum/mind/werewolf_mind = human_user.mind
	if(werewolf_mind?.current == human_user)
		// Keep the werewolf player in control of the beast, along with any mind-bound actions.
		werewolf_mind.transfer_to(new_werewolf, TRUE)

	// Feedback comes after the mind transfer so the player's client is in the new body to receive it.
	playsound(new_werewolf, pick('sound/combat/gib (1).ogg', 'sound/combat/gib (2).ogg'), 200, FALSE, 3)
	new_werewolf.playsound_local(get_turf(new_werewolf), 'sound/music/wolfintro.ogg', 80, FALSE, pressure_affected = FALSE)
	if(force_due_to_missed_nights)
		to_chat(new_werewolf, span_userdanger("The beast will not be denied any longer!"))
	else
		to_chat(new_werewolf, span_userdanger("I transform into a horrible beast!"))
	new_werewolf.emote("rage")

	var/datum/rage/werewolf/beast_rage = new_werewolf.rage_datum
	if(istype(beast_rage))
		beast_rage.raise_rage_to(WW_TRANSFORM_RAGE_FLOOR)

	mark_transformation_complete()
	RegisterSignal(new_werewolf, COMSIG_LIVING_COMBAT_KILL, PROC_REF(on_werewolf_kill))
	RegisterSignal(new_werewolf, COMSIG_LIVING_UNSHAPESHIFTED, PROC_REF(werewolf_untransform))
	RegisterSignal(new_werewolf, COMSIG_PARENT_QDELETING, PROC_REF(on_werewolf_body_deleted))
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
	var/beast_name = get_beast_name()
	new_werewolf.real_name = beast_name
	new_werewolf.name = beast_name
	new_werewolf.skin_armor = new /obj/item/clothing/armor/regenerating/skin/werewolf_skin(new_werewolf)
	// The mind arrives later, so the species cannot read our look yet.
	var/datum/species/werewolf/beast_species = new_werewolf.dna?.species
	if(istype(beast_species))
		beast_species.apply_form_look(new_werewolf, get_form_look())

	for(var/werewolf_power_type in werewolf_form_powers)
		var/datum/action/werewolf_power = new werewolf_power_type(new_werewolf)
		werewolf_power.Grant(new_werewolf)

	return new_werewolf

/// Builds the beast's genitals from the human's; the penis is knotted and never shorter than the floor.
/datum/antagonist/werewolf/proc/apply_beast_anatomy(mob/living/carbon/human/human_user, mob/living/carbon/human/species/werewolf/new_werewolf)
	var/obj/item/organ/genitals/penis/human_penis = get_real_organ(human_user, ORGAN_SLOT_PENIS)
	if(human_penis)
		var/obj/item/organ/genitals/penis/knotted/beast_penis = new
		beast_penis.length_cm = max(human_penis.get_length_cm(), WW_BEAST_MIN_PENIS_LENGTH)
		beast_penis.organ_size = max(human_penis.organ_size, get_penis_visual_size(beast_penis.length_cm))
		beast_penis.Insert(new_werewolf, TRUE, FALSE)
	var/obj/item/organ/genitals/filling_organ/testicles/human_testicles = human_user.getorganslot(ORGAN_SLOT_TESTICLES)
	if(human_testicles)
		var/obj/item/organ/genitals/filling_organ/testicles/internal/beast_testicles = new
		beast_testicles.organ_size = human_testicles.organ_size
		beast_testicles.Insert(new_werewolf, TRUE, FALSE)
	var/obj/item/organ/genitals/filling_organ/breasts/human_breasts = human_user.getorganslot(ORGAN_SLOT_BREASTS)
	if(human_breasts)
		var/obj/item/organ/genitals/filling_organ/breasts/beast_breasts = new
		beast_breasts.organ_size = human_breasts.organ_size
		beast_breasts.Insert(new_werewolf, TRUE, FALSE)
	var/obj/item/organ/genitals/filling_organ/vagina/human_vagina = human_user.getorganslot(ORGAN_SLOT_VAGINA)
	if(human_vagina)
		var/obj/item/organ/genitals/filling_organ/vagina/beast_vagina = new
		beast_vagina.organ_size = human_vagina.organ_size
		beast_vagina.Insert(new_werewolf, TRUE, FALSE)

/datum/antagonist/werewolf/proc/transfer_skill_state_to_werewolf(mob/living/carbon/human/human_user, mob/living/carbon/human/species/werewolf/new_werewolf)
	if(!human_user?.attributes || !new_werewolf?.attributes)
		return

	new_werewolf.attributes.copy_skill_state(human_user.attributes)

/datum/antagonist/werewolf/proc/apply_werewolf_transformation_bonuses(mob/living/carbon/human/species/werewolf/new_werewolf)
	// The beast body keeps the statline it was created with (base stats + species sheets applied on
	// species gain) - the human's stats do not carry over, only skills do. Enforce minimum ferocity here.
	apply_werewolf_skill_floor(new_werewolf, /datum/attribute/skill/combat/wrestling, 50)
	apply_werewolf_skill_floor(new_werewolf, /datum/attribute/skill/combat/unarmed, 50)
	apply_werewolf_skill_floor(new_werewolf, /datum/attribute/skill/misc/climbing, 60)

/datum/antagonist/werewolf/proc/apply_werewolf_skill_floor(mob/living/carbon/human/species/werewolf/new_werewolf, skill_type, minimum_level)
	var/datum/attribute_holder/werewolf_attributes = new_werewolf?.attributes
	if(!werewolf_attributes)
		return
	if(nulltozero(werewolf_attributes.raw_attribute_list[skill_type]) >= minimum_level)
		return
	werewolf_attributes.set_skill_level(skill_type, minimum_level, TRUE)

/// Helper to remove werewolf transformation effect from owner.current.
/datum/antagonist/werewolf/proc/remove_werewolf(forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/werewolf_user = owner?.current
	if(!transformed)
		return
	if(!istype(werewolf_user))
		transformed = FALSE
		transformation_in_progress = FALSE
		return
	if(!forced && HAS_TRAIT(werewolf_user, TRAIT_NO_TRANSFORM))
		return
	werewolf_user.remove_status_effect(/datum/status_effect/shapechange_mob/die_with_form)

/// Called with COMSIG_LIVING_UNSHAPESHIFTED signal.
/datum/antagonist/werewolf/proc/werewolf_untransform(mob/living/status_owner, mob/living/status_caster_mob)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/werewolf_user = status_owner
	var/mob/living/carbon/human/caster_mob = status_caster_mob

	transformed = FALSE
	transformation_in_progress = FALSE

	// Recover the rage datum from whichever body still holds a reference to it.
	var/datum/rage/rage_datum
	if(istype(caster_mob))
		rage_datum = caster_mob.rage_datum
	if(!rage_datum && istype(werewolf_user))
		rage_datum = werewolf_user.rage_datum
	remove_transformed_rage_decay(rage_datum)
	rage_datum?.remove_secondary()

	if(istype(werewolf_user))
		QDEL_NULL(werewolf_user.skin_armor)
		UnregisterSignal(werewolf_user, list(COMSIG_LIVING_COMBAT_KILL, COMSIG_LIVING_UNSHAPESHIFTED, COMSIG_PARENT_QDELETING))
		// Shed only what the beast held or wore - organs and bodyparts are mob contents too and must stay put.
		for(var/obj/item/held_item as anything in werewolf_user.held_items)
			if(held_item)
				werewolf_user.dropItemToGround(held_item, silent = TRUE)
		for(var/obj/item/equipped_item as anything in werewolf_user.get_equipped_items(TRUE))
			werewolf_user.dropItemToGround(equipped_item, silent = TRUE)

	if(!istype(caster_mob))
		return

	if(istype(werewolf_user))
		INVOKE_ASYNC(werewolf_user, TYPE_PROC_REF(/mob, emote), "scream")

		var/datum/mind/werewolf_mind = werewolf_user.mind
		if(werewolf_mind?.current == werewolf_user)
			// Restore control to the hidden human before the beast body is cleaned up.
			werewolf_mind.transfer_to(caster_mob, TRUE)

		caster_mob.adjustBruteLoss(werewolf_user.getBruteLoss() / 2)
		caster_mob.adjustFireLoss(werewolf_user.getFireLoss() / 2)
		caster_mob.adjustToxLoss(werewolf_user.getToxLoss() / 2)
		caster_mob.adjustOxyLoss(werewolf_user.getOxyLoss() / 2)
		caster_mob.adjustCloneLoss(werewolf_user.getCloneLoss() / 2)

	to_chat(caster_mob, span_userdanger("The beast within returns to slumber."))
	playsound(caster_mob, pick('sound/combat/gib (1).ogg', 'sound/combat/gib (2).ogg'), 200, FALSE, 3)
	caster_mob.Knockdown(30)
	caster_mob.Stun(30)

	// Async because we are a signal handler and StartCooldown's call tree can theoretically sleep.
	INVOKE_ASYNC(src, PROC_REF(mark_transformation_complete))

/// The beast body was hard-deleted (gibbed, admin-removed) without unshapeshifting; clear the stale state.
/datum/antagonist/werewolf/proc/on_werewolf_body_deleted(datum/source)
	SIGNAL_HANDLER

	transformed = FALSE
	transformation_in_progress = FALSE

	var/datum/rage/rage_datum
	var/mob/living/carbon/human/deleted_body = source
	if(istype(deleted_body))
		rage_datum = deleted_body.rage_datum
	if(!rage_datum)
		var/mob/living/carbon/human/current_body = owner?.current
		if(istype(current_body) && !QDELETED(current_body))
			rage_datum = current_body.rage_datum
	remove_transformed_rage_decay(rage_datum)
