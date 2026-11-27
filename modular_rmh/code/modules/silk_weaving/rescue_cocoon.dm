/// Woven by silk weavers to hold and stabilise a patient. Unrelated to the spider egg cocoon.
/obj/structure/spider/rescue_cocoon
	name = "silk cocoon"
	desc = "Closely layered silk forms a snug enclosure around an injured occupant. Snipping it opens a slit; enough damage tears it apart."
	icon = 'modular_rmh/icons/obj/rescue_cocoon.dmi'
	icon_state = "intact"
	max_integrity = 40
	resistance_flags = FLAMMABLE
	static_debris = list(/obj/item/natural/silk = 1)
	var/mob/living/occupant
	var/opened = FALSE
	var/struggling = FALSE
	var/next_treatment = 0
	var/next_sensation = 0
	var/was_conscious = FALSE
	/// Brute and burn healed per treatment, every two seconds.
	var/healing_amount = 0.2
	/// Blood restored per treatment; about a tenth of normal volume per minute.
	var/blood_recovery = 4
	var/oxygen_recovery = 4

/obj/structure/spider/rescue_cocoon/proc/enclose(mob/living/patient)
	if(opened || occupant || QDELETED(patient) || patient.stat == DEAD || !isturf(patient.loc) || patient.buckled || length(patient.buckled_mobs))
		return FALSE
	occupant = patient
	if(!patient.forceMove(src) || patient.loc != src)
		occupant = null
		return FALSE
	if(patient.on_fire && !smother_flames())
		return FALSE
	was_conscious = patient.stat == CONSCIOUS
	RegisterSignal(patient, COMSIG_LIVING_DEATH, PROC_REF(on_patient_death))
	RegisterSignal(patient, COMSIG_PARENT_QDELETING, PROC_REF(on_patient_deleted))
	RegisterSignal(patient, COMSIG_LIVING_IGNITED, PROC_REF(on_patient_ignited))
	ADD_TRAIT(patient, TRAIT_SILK_COMPRESSION, REF(src))
	if(patient.get_bleed_rate())
		to_chat(patient, span_notice("The silk presses firmly around my wounds, stemming the flow of blood without closing them."))
	next_treatment = world.time + 2 SECONDS
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/structure/spider/rescue_cocoon/proc/on_patient_ignited(datum/source)
	SIGNAL_HANDLER
	// Let IgniteMob() finish before putting the fire out.
	addtimer(CALLBACK(src, PROC_REF(smother_flames)), 0, TIMER_UNIQUE)

/obj/structure/spider/rescue_cocoon/proc/smother_flames()
	if(QDELETED(src) || opened || QDELETED(occupant) || occupant.loc != src || !occupant.on_fire)
		return FALSE
	occupant.ExtinguishMob()
	if(occupant.on_fire)
		to_chat(occupant, span_warning("The flames resist the enclosing silk, tearing the cocoon open."))
		open_cocoon("smashed")
		return FALSE
	to_chat(occupant, span_notice("The silk wrapped around me snuffs out the flames."))
	return TRUE

/obj/structure/spider/rescue_cocoon/proc/on_patient_death(datum/source)
	SIGNAL_HANDLER
	REMOVE_TRAIT(occupant, TRAIT_SILK_COMPRESSION, REF(src))
	STOP_PROCESSING(SSobj, src)

/obj/structure/spider/rescue_cocoon/proc/on_patient_deleted(datum/source)
	SIGNAL_HANDLER
	clear_patient()
	opened = TRUE
	icon_state = "snipped"
	name = "opened silk cocoon"
	desc = "An empty cocoon, its layers hanging loosely around an opening."

/obj/structure/spider/rescue_cocoon/proc/clear_patient()
	STOP_PROCESSING(SSobj, src)
	if(occupant)
		UnregisterSignal(occupant, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING, COMSIG_LIVING_IGNITED))
		REMOVE_TRAIT(occupant, TRAIT_SILK_COMPRESSION, REF(src))
	occupant = null

/obj/structure/spider/rescue_cocoon/Exit(atom/movable/leaving, atom/newLoc)
	if(leaving == occupant && !opened)
		return FALSE
	return ..()

/obj/structure/spider/rescue_cocoon/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != occupant)
		return
	clear_patient()
	if(!opened)
		open_cocoon("snipped")

/obj/structure/spider/rescue_cocoon/process()
	if(QDELETED(occupant) || occupant.loc != src || opened)
		clear_patient()
		return
	if(occupant.stat == DEAD)
		on_patient_death()
		return
	if(world.time < next_treatment)
		return
	next_treatment = world.time + 2 SECONDS
	if(occupant.stat == CONSCIOUS && !was_conscious)
		to_chat(occupant, span_notice("Awareness returns in the close embrace of silk. The woven layers hold my body, shifting slightly with each breath."))
	was_conscious = occupant.stat == CONSCIOUS
	if(occupant.mob_biotypes & MOB_ROBOTIC)
		return
	var/brute_before = occupant.getBruteLoss()
	var/burn_before = occupant.getFireLoss()
	occupant.adjustBruteLoss(-healing_amount)
	occupant.adjustFireLoss(-healing_amount)
	occupant.adjustOxyLoss(-oxygen_recovery)
	if(iscarbon(occupant) && !occupant.is_bloodless() && occupant.blood_volume < BLOOD_VOLUME_NORMAL)
		occupant.blood_volume = min(BLOOD_VOLUME_NORMAL, occupant.blood_volume + blood_recovery)
	if(world.time < next_sensation)
		return
	var/list/sensations = list()
	if(occupant.getBruteLoss() < brute_before)
		sensations += "My aches ease a little beneath the silk's steady pressure."
	if(occupant.getFireLoss() < burn_before)
		sensations += "A faint coolness settles over my burns beneath the silk, soothing their raw sting."
	if(length(sensations))
		to_chat(occupant, span_notice(pick(sensations)))
		next_sensation = world.time + 45 SECONDS

/// Half of rope escape time, shortened by Strength above 10.
/obj/structure/spider/rescue_cocoon/proc/escape_time(mob/living/patient)
	return max(0, 30 SECONDS * (1 - max(0, GET_MOB_ATTRIBUTE_VALUE(patient, STAT_STRENGTH) - 10) * 0.1))

/obj/structure/spider/rescue_cocoon/container_resist(mob/living/user)
	if(user != occupant || opened || struggling || user.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
		return
	if(HAS_TRAIT(user, TRAIT_SILK_WEAVER) || HAS_TRAIT(user, TRAIT_WEBWALK))
		visible_message(span_notice("[user] parts the woven layers with practiced ease and slips free of [src]."), ignored_mobs = list(user))
		to_chat(user, span_notice("I find the give in the weave and part the silk with practiced ease."))
		open_cocoon("snipped")
		return
	struggling = TRUE
	var/delay = escape_time(user)
	to_chat(user, span_notice("I brace against the silk and begin working its layers apart. This will take about [DisplayTimeText(delay)]."))
	visible_message(span_notice("[src] shifts as its occupant struggles against the woven layers."), ignored_mobs = list(user))
	var/finished = do_after(user, delay, src, IGNORE_HELD_ITEM)
	if(QDELETED(src))
		return
	struggling = FALSE
	if(user != occupant || opened || QDELETED(user))
		return
	if(!finished || user.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB))
		to_chat(user, span_notice("I stop struggling. The woven layers settle around me again."))
		return
	to_chat(user, span_notice("The layers finally part under my efforts, leaving an opening in the silk."))
	open_cocoon("snipped")

/// Releases the occupant and leaves a spent shell that can be snipped or broken for silk.
/obj/structure/spider/rescue_cocoon/proc/open_cocoon(open_state)
	if(opened)
		return FALSE
	opened = TRUE
	icon_state = open_state
	name = "opened silk cocoon"
	desc = open_state == "smashed" ? "A collapsed cocoon, its supports torn apart and its silk crumpled into a ragged shell." : "An opened cocoon with a deliberate slit through its layers. The parted silk hangs loosely around the opening."
	var/mob/living/patient = occupant
	clear_patient()
	if(!QDELETED(patient))
		patient.forceMove(get_turf(src))
		if(patient.stat != DEAD)
			if(open_state == "smashed")
				to_chat(patient, span_warning("The silk tears and gives way around me. Its pressure abruptly vanishes."))
			else
				to_chat(patient, span_notice("The silk parts along an opening. The pressure around my body releases."))
	repair_damage(max_integrity)
	return TRUE

/obj/structure/spider/rescue_cocoon/attacked_by(obj/item/I, mob/living/user)
	if(user.used_intent?.type != /datum/intent/snip)
		return ..()
	var/was_open = opened
	var/snip_time = max(1 SECONDS, 5 SECONDS - GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/sewing) * 1 SECONDS)
	user.visible_message(span_notice("[user] begins cutting through [src]'s silken layers."))
	if(occupant && occupant.stat != DEAD)
		to_chat(occupant, span_notice("I feel small tugs against the silk as someone begins cutting an opening."))
	if(!do_after(user, snip_time, src) || QDELETED(src) || opened != was_open)
		return TRUE
	if(!opened)
		visible_message(span_notice("[user] parts the cut layers of [src], opening a slit through the silk."))
		open_cocoon("snipped")
	else
		for(var/i in 1 to rand(1, 2))
			new /obj/item/natural/silk(get_turf(src))
		user.mind?.add_sleep_experience(/datum/attribute/skill/misc/sewing, GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) / 2)
		qdel(src)
	playsound(user, 'sound/items/flint.ogg', 100, TRUE)
	return TRUE

/// The first destruction only splits the cocoon open; fire and a spent shell are destroyed outright.
/obj/structure/spider/rescue_cocoon/deconstruct(disassembled = TRUE)
	if(opened || (resistance_flags & ON_FIRE))
		return ..()
	visible_message(span_warning("[src] splits apart, its supporting layers collapsing."))
	open_cocoon("smashed")

/obj/structure/spider/rescue_cocoon/Destroy()
	var/turf/release_turf = get_turf(src)
	clear_patient()
	for(var/atom/movable/contained as anything in contents)
		contained.forceMove(release_turf)
	return ..()
