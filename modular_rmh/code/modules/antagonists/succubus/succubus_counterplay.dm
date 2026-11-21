// Event-driven Church counterplay for Succubus evidence, cleansing, and enthrallment.

GLOBAL_LIST_EMPTY(active_succubus_consecrations)

/proc/get_active_succubus_consecration(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return null
	var/area/target_area = get_area(target_turf)
	for(var/obj/structure/succubus_consecration/ward as anything in GLOB.active_succubus_consecrations)
		if(QDELETED(ward))
			continue
		var/turf/ward_turf = get_turf(ward)
		if(!ward_turf || ward_turf.z != target_turf.z || get_area(ward_turf) != target_area)
			continue
		return ward
	return null

/proc/is_succubus_consecrated(atom/target)
	return !isnull(get_active_succubus_consecration(target))

/obj/structure/succubus_consecration
	name = "consecration ward"
	desc = "A broad white-gold seal worked into the floor. Its light makes infernal hungers recoil."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "warded"
	color = "#FFF2B3"
	alpha = 190
	anchored = TRUE
	density = FALSE
	layer = BELOW_MOB_LAYER
	max_integrity = SUCCUBUS_CONSECRATION_INTEGRITY
	light_system = MOVABLE_LIGHT
	light_outer_range = 2
	light_color = "#FFF2B3"
	SET_BASE_PIXEL(-64, -64)
	var/tmp/expiry_timer = TIMER_ID_NULL

/obj/structure/succubus_consecration/Initialize(mapload)
	. = ..()
	GLOB.active_succubus_consecrations += src
	expiry_timer = addtimer(CALLBACK(src, PROC_REF(expire)), SUCCUBUS_CONSECRATION_DURATION, TIMER_STOPPABLE)

/obj/structure/succubus_consecration/proc/expire()
	expiry_timer = TIMER_ID_NULL
	visible_message(span_notice("[src]'s white-gold lines dim and fade from the floor."))
	qdel(src)

/obj/structure/succubus_consecration/proc/reveal_present_succubi()
	for(var/mob/living/carbon/human/candidate in GLOB.player_list)
		if(get_active_succubus_consecration(candidate) != src)
			continue
		var/datum/antagonist/succubus/succubus_antag = IS_SUCCUBUS(candidate)
		if(!succubus_antag || isnull(succubus_antag.current_form_key))
			continue
		to_chat(candidate, span_userdanger("White fire catches in my borrowed flesh!"))
		succubus_antag.revert_form(forced = TRUE)

/obj/structure/succubus_consecration/atom_destruction(damage_flag)
	visible_message(span_boldwarning("[src]'s sacred geometry cracks apart and gutters out!"))
	return ..()

/obj/structure/succubus_consecration/Destroy()
	if(expiry_timer != TIMER_ID_NULL)
		deltimer(expiry_timer)
		expiry_timer = TIMER_ID_NULL
	GLOB.active_succubus_consecrations -= src
	return ..()

/proc/can_place_succubus_consecration(mob/living/user, silent = FALSE)
	if(!istype(user) || QDELETED(user) || user.stat != CONSCIOUS)
		return FALSE
	var/turf/placement_turf = get_turf(user)
	if(!isfloorturf(placement_turf))
		if(!silent)
			to_chat(user, span_warning("I need a solid floor on which to draw the ward."))
		return FALSE
	if(!istype(get_area(placement_turf), /area/indoors))
		if(!silent)
			to_chat(user, span_warning("The ward needs the sheltering bounds of an indoor refuge."))
		return FALSE
	if(get_active_succubus_consecration(placement_turf))
		if(!silent)
			to_chat(user, span_warning("This refuge is already consecrated against infernal hunger."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/undirected/succubus_consecrate_refuge
	name = "Consecrate Refuge"
	desc = "Raise a temporary ward across this indoor refuge, denying infernal feeding and lust magic."
	button_icon_state = "lesserheal"
	sound = 'sound/magic/heal.ogg'
	charge_sound = 'sound/magic/holycharging.ogg'
	charge_message = "I begin tracing a ward of refuge..."
	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/attribute/skill/magic/holy
	spell_requirements = SPELL_REQUIRES_NO_MOVE
	charge_required = TRUE
	charge_time = SUCCUBUS_CONSECRATION_CHANNEL
	cooldown_time = SUCCUBUS_CONSECRATION_COOLDOWN
	spell_cost = SUCCUBUS_CONSECRATION_DEVOTION_COST

/datum/action/cooldown/spell/undirected/succubus_consecrate_refuge/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return .
	if(!can_place_succubus_consecration(owner))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/undirected/succubus_consecrate_refuge/cast(mob/living/cast_on)
	. = ..()
	if(!can_place_succubus_consecration(owner))
		return
	var/obj/structure/succubus_consecration/ward = new(get_turf(owner))
	owner.visible_message(
		span_boldnotice("White-gold lines race from [owner]'s hands, sealing [get_area_name(owner)] against infernal hunger!"),
		span_boldnotice("I seal this refuge against infernal hunger."),
	)
	ward.reveal_present_succubi()

/datum/action/cooldown/spell/succubus_seal_rift
	name = "Rite of Sealing"
	desc = "Drive holy will into an adjacent open infernal Rift, contributing two measures toward its closure."
	button_icon_state = "lesserheal"
	sound = 'sound/magic/heal.ogg'
	charge_sound = 'sound/magic/holycharging.ogg'
	charge_message = "I begin binding the Rift's edges in holy light..."
	cast_range = 1
	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/attribute/skill/magic/holy
	spell_requirements = SPELL_REQUIRES_NO_MOVE
	charge_required = TRUE
	charge_time = SUCCUBUS_RIFT_SEAL_RITE_CHANNEL
	cooldown_time = SUCCUBUS_RIFT_SEAL_RITE_COOLDOWN
	spell_cost = SUCCUBUS_RIFT_SEAL_RITE_DEVOTION_COST
	self_cast_possible = FALSE

/datum/action/cooldown/spell/succubus_seal_rift/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return istype(cast_on, /obj/structure/succubus_rift)

/datum/action/cooldown/spell/succubus_seal_rift/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return .
	var/obj/structure/succubus_rift/rift = cast_on
	if(!istype(rift) || !rift.can_seal_rift(owner))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/succubus_seal_rift/cast(obj/structure/succubus_rift/cast_on)
	. = ..()
	if(!istype(cast_on) || !cast_on.can_seal_rift(owner))
		return
	cast_on.add_seal_progress(SUCCUBUS_RIFT_SEAL_RITE_PROGRESS, owner)

/mob/living/carbon/human/proc/can_receive_succubus_deliverance()
	if(mind?.has_antag_datum(/datum/antagonist/succubus_thrall))
		return TRUE

	var/datum/status_effect/succubus_brand/brand = has_status_effect(/datum/status_effect/succubus_brand)
	return brand?.revealed || FALSE

/mob/living/carbon/human/proc/receive_succubus_deliverance(mob/living/cleric)
	if(!can_receive_succubus_deliverance())
		return FALSE

	var/exorcised = FALSE
	var/datum/antagonist/succubus_thrall/thrall_datum = mind?.has_antag_datum(/datum/antagonist/succubus_thrall)
	if(thrall_datum)
		var/datum/antagonist/succubus/mistress = thrall_datum.mistress_mind?.has_antag_datum(/datum/antagonist/succubus)
		if(mistress)
			var/mob/living/mistress_body = mistress.owner?.current
			exorcised = mistress.unenthrall(mind, keep_memories = TRUE)
			if(exorcised && mistress_body)
				to_chat(mistress_body, span_userdanger("A bond snaps inside me — [real_name] was torn from me!"))

	var/cleansed = cleanse_succubus_afflictions()
	if(!exorcised && !cleansed)
		return FALSE

	if(cleric)
		if(exorcised)
			cleric.visible_message(
				span_boldwarning("[cleric] tears a rose-violet shadow free from [src], where it burns away in holy light!"),
				span_notice("I tear the infernal bond from [src] and burn its last traces away."),
			)
		else
			cleric.visible_message(
				span_notice("Holy light gathers around [src] as [cleric] washes an infernal stain away."),
				span_notice("I wash the infernal stain from [src]."),
			)
	to_chat(src, span_boldnotice("Clean warmth floods through me as the infernal stain is scoured away."))
	return TRUE

/datum/antagonist/succubus/proc/react_to_blessed_water(reac_volume, ingested = FALSE)
	var/mob/living/body = owner?.current
	if(!body)
		return FALSE

	if(ingested)
		body.visible_message(
			span_boldwarning("[body] chokes as rose-colored steam spills from [body.p_their()] mouth!"),
			span_userdanger("The blessed water burns down my throat and through my infernal nature!"),
		)
	else
		body.visible_message(
			span_boldwarning("Blessed water erupts into rose-colored steam against [body]'s skin!"),
			span_userdanger("The blessed water sears my infernal nature!"),
		)
	if(!is_in_true_form())
		revert_form(forced = TRUE)
	var/burn_amount = min(max(reac_volume, 1), SUCCUBUS_BLESSED_WATER_MAX_BURN)
	body.adjustFireLoss(burn_amount, 0)
	body.emote("scream")
	return TRUE

/datum/action/cooldown/spell/succubus_deliverance
	name = "Rite of Deliverance"
	desc = "Cleanse a revealed infernal brand, arcane sigils and all soul depletion. If the subject is enthralled, tear away the bond without taking their memories."
	button_icon_state = "lesserheal"
	sound = 'sound/magic/heal.ogg'
	charge_sound = 'sound/magic/holycharging.ogg'
	charge_message = "I begin the rite of deliverance..."
	cast_range = 1
	spell_type = SPELL_MIRACLE
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	associated_skill = /datum/attribute/skill/magic/holy
	spell_requirements = SPELL_REQUIRES_NO_MOVE
	charge_required = TRUE
	charge_time = SUCCUBUS_DELIVERANCE_CHANNEL
	cooldown_time = SUCCUBUS_DELIVERANCE_COOLDOWN
	spell_cost = SUCCUBUS_DELIVERANCE_DEVOTION_COST
	self_cast_possible = TRUE

/datum/action/cooldown/spell/succubus_deliverance/is_valid_target(atom/cast_on)
	. = ..()
	if(!. || !ishuman(cast_on))
		return FALSE
	if(get_dist(owner, cast_on) > cast_range)
		return FALSE
	var/mob/living/carbon/human/target = cast_on
	return target.can_receive_succubus_deliverance() || target.has_arcane_brand()

/datum/action/cooldown/spell/succubus_deliverance/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!istype(cast_on) || !is_valid_target(cast_on))
		return
	cast_on.remove_arcane_brands()
	cast_on.receive_succubus_deliverance(owner)
