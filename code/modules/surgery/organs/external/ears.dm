/obj/item/organ/ears
	name = "ears"
	icon_state = "ear"
	desc = ""
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_EARS
	slot = ORGAN_SLOT_EARS
	organ_efficiency = list(ORGAN_SLOT_EARS = 100)
	gender = PLURAL
	side = RIGHT_SIDE

	healing_factor = STANDARD_ORGAN_HEALING
	pain_multiplier = 0.35 / 2

	organ_volume = 0.25
	max_blood_storage = 2.5
	current_blood = 2.5
	blood_req = 0.5
	oxygen_req = 0.5
	nutriment_req = 0.02
	hydration_req = 0.02

	low_threshold_passed = "<span class='info'>My ears begin to resonate with an internal ring sometimes.</span>"
	now_failing = "<span class='warning'>I am unable to hear at all!</span>"
	now_fixed = "<span class='info'>Noise slowly begins filling my ears once more.</span>"
	low_threshold_cleared = "<span class='info'>The ringing in my ears has died down.</span>"

	/// Temporary deafness, measured in seconds. While above zero, the owner cannot hear.
	var/temporary_deafness = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	//Resistance against loud noises
	var/bang_protect = EAR_PROTECTION_NONE
	// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1
	/// Currently mid ear-flick animation. Swaps the accessory to its `_flick` state while TRUE.
	var/is_flicking = FALSE
	/// Pointed or animal ears that react strongly to touch. See has_sensitive_ears().
	var/sensitive = FALSE
	var/static/sound/ringing = sound('sound/flash_ring.ogg', FALSE, 0, CHANNEL_EAR_RING, 75)

/obj/item/organ/ears/Insert(mob/living/carbon/M, special, drop_if_replaced, new_zone = null)
	. = ..()
	for(var/datum/wound/facial/ears/ear_wound in M.get_wounds())
		qdel(ear_wound)
	if(temporary_deafness)
		on_deafened()

/obj/item/organ/ears/Remove(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(temporary_deafness)
		on_undeafened(M)

/obj/item/organ/ears/on_life(delta_time, times_fired)
	. = ..()
	// Non-damage deafness is owned by its own source and should not make this timer tick down.
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE) || is_failing())
		return
	if(temporary_deafness)
		adjust_temporary_deafness(-delta_time SECONDS)

/obj/item/organ/ears/consider_processing(in_bleedout = FALSE)
	if(..())
		return TRUE
	// Deafness counts down in on_life, so healthy ears must keep ticking until it ends.
	needs_processing = temporary_deafness > 0
	return needs_processing

/// Adjusts temporary deafness without interfering with deafness from other sources.
/obj/item/organ/ears/proc/adjust_temporary_deafness(amount)
	if(amount > 0 && owner && (owner.status_flags & GODMODE))
		return
	temporary_deafness = max(temporary_deafness + (amount * damage_multiplier), 0)
	consider_processing()
	if(!owner)
		return
	if(temporary_deafness && !HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		on_deafened()
	else if(!temporary_deafness && HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		on_undeafened()

/obj/item/organ/ears/proc/on_deafened()
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(adjust_speech))
	ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
	SEND_SOUND(owner, ringing)

/obj/item/organ/ears/proc/on_undeafened(mob/living/organ_owner = owner)
	REMOVE_TRAIT(organ_owner, TRAIT_DEAF, EAR_DAMAGE)
	UnregisterSignal(organ_owner, COMSIG_MOB_SAY)

/// Loud-noise deafness makes the owner involuntarily shout.
/obj/item/organ/ears/proc/adjust_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		return
	var/message = speech_args[SPEECH_MESSAGE]
	message = replacetext(message, ". ", "! ")
	message = replacetext(message, "? ", "?! ")
	switch(copytext_char(message, -1))
		if(".")
			if(copytext_char(message, -2) != "..")
				message = copytext_char(message, 1, -1) + "!"
		if("?")
			message = copytext_char(message, 1, -1) + "?!"
		if("!")
			pass()
		else
			message += "!"
	speech_args[SPEECH_MESSAGE] = message
	return COMPONENT_UPPERCASE_SPEECH

/obj/item/organ/ears/invincible
	damage_multiplier = 0

/// Plays an ear flick if this mob has flickable ears and isn't already mid-flick. Safe no-op otherwise.
/mob/living/proc/try_ear_flick()
	return

/mob/living/carbon/human/try_ear_flick()
	if(dna?.species?.can_flick_ears(src))
		dna.species.perform_flick_ears(src)

/// TRUE when touching this mob's ears is strongly arousing: sensitive ear organs or the Sensitive Ears quirk.
/mob/living/proc/has_sensitive_ears()
	if(HAS_TRAIT(src, TRAIT_SENSITIVE_EARS))
		return TRUE
	var/obj/item/organ/ears/ears = getorganslot(ORGAN_SLOT_EARS)
	return ears?.sensitive

/obj/item/organ/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "kitty"
	damage_multiplier = 2
	sensitive = TRUE

/obj/item/organ/ears/elf
	name = "elf ears"
	icon_state = "ear_pointed"
	use_mob_sprite_as_obj_sprite = FALSE
	accessory_type = /datum/sprite_accessory/ears/elf
	sensitive = TRUE

/obj/item/organ/ears/elfw
	name = "wood elf ears"
	icon_state = "ear_pointed"
	use_mob_sprite_as_obj_sprite = FALSE
	accessory_type = /datum/sprite_accessory/ears/elfw
	sensitive = TRUE

/obj/item/organ/ears/halforc
	name = "halforc ears"
	icon_state = "ear_pointed"
	use_mob_sprite_as_obj_sprite = FALSE
	accessory_type = /datum/sprite_accessory/ears/elf
	sensitive = TRUE

/obj/item/organ/ears/tiefling
	name = "tiefling ears"
	icon_state = "ear_pointed"
	use_mob_sprite_as_obj_sprite = FALSE
	accessory_type = /datum/sprite_accessory/ears/elfw
	sensitive = TRUE

/obj/item/organ/ears/anthro
	name = "wild-kin ears"
	sensitive = TRUE

/obj/item/organ/ears/anthro/hood
	name = "hood"
	sensitive = FALSE

/obj/item/organ/ears/hollowkin
	name = "hollow-kin ears"
	sensitive = TRUE

/obj/item/organ/ears/rakshari
	name = "rakshari ears"
	sensitive = TRUE

/obj/item/organ/ears/triton
	name = "triton ears"



/obj/item/organ/ears/rakshari/Insert(mob/living/carbon/M, special, drop_if_replaced, new_zone = null)
	. = ..()
	ADD_TRAIT(M, TRAIT_KEENEARS, "[type]")

/obj/item/organ/ears/rakshari/Remove(mob/living/carbon/human/H,  special = 0)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_KEENEARS, "[type]")
