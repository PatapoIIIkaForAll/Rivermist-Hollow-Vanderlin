// Pushing eggs out and giving birth: a staged event that feels as good or as bad as the fit allows.

#define LABOUR_PHASE_CONTRACTING 1
#define LABOUR_PHASE_PUSHING 2
/// Contractions before the push; each recent birth and each size step past comfort add one.
#define LABOUR_BASE_CONTRACTIONS 3
/// Births inside this window make the next labour longer and harder.
#define LABOUR_FATIGUE_WINDOW (1 HOURS)
#define LABOUR_CONTRACTION_GAP (20 SECONDS)
#define LABOUR_CONTRACTION_GAP_MIN (10 SECONDS)
/// Time between dropping down to push and the passage itself.
#define LABOUR_PUSH_DELAY (6 SECONDS)
/// Stamina each contraction costs, plus this much more per recent birth.
#define LABOUR_CONTRACTION_STAMINA 15
#define LABOUR_FATIGUE_STAMINA 10
/// Soreness a hard birth leaves on the opening, on top of the passage itself.
#define LABOUR_SORENESS 10
/// Share of the fluid inside that gushes out with a birth.
#define LABOUR_GUSH_SHARE 0.5
/// How long the worn debuff lasts per birth in the window.
#define BIRTH_WORN_TIME (5 MINUTES)
/// One push when pushing an egg out by hand, what it costs, and how many a tight fit may take.
#define EGG_PUSH_TIME (6 SECONDS)
#define EGG_PUSH_STAMINA 20
#define EGG_PUSH_MAX_PUSHES 4
/// Chance per push that an egg past comfort slips back, per unit of strain over one.
#define EGG_PUSH_SLIP_CHANCE 25
/// What a heave costs when a stomach passenger is brought up by the mouth.
#define RETCH_TIME (4 SECONDS)
#define RETCH_STAMINA 20
#define RETCH_NUTRITION 15
#define RETCH_STUN (2 SECONDS)
/// Strain past which a passage is all pain; within comfort it is all pleasure, between it is mixed.
#define BIRTH_PAIN_STRAIN 1.3
/// Pleasure and climax progress one contraction gives at full pleasure, and what the passage itself gives.
#define BIRTH_CONTRACTION_PLEASURE 6
#define BIRTH_CONTRACTION_CLIMAX 5
#define BIRTH_DELIVERY_PLEASURE 15
#define BIRTH_DELIVERY_CLIMAX 20
/// A birth within comfort keeps this share of the stamina, soreness and knockdown costs.
#define BIRTH_PLEASURE_COST_SHARE 0.25
/// Masochists keep at least this much pleasure however hard the passage.
#define BIRTH_MASOCHIST_FLOOR 0.5
/// Cost multiplier for an ease share: everything at zero ease, the kept share at full ease.
#define BIRTH_COST_MULT(ease) (1 - (ease) * (1 - BIRTH_PLEASURE_COST_SHARE))
#define BIRTH_FEELS_GOOD(share) ((share) >= 0.66)
#define BIRTH_FEELS_MIXED(share) ((share) > 0.33 && (share) < 0.66)

/mob/living/carbon
	/// world.time of each recent birth; the count inside the window makes the next one harder.
	var/list/recent_labours

/obj/item/mob_holder/internal_womb
	/// Width the hatchling passes the opening with; set from its egg when it hatches inside.
	var/birth_girth

/// The storage hook passes inner-layer removals with this, so a hatchling is born at its own width.
/obj/item/mob_holder/internal_womb/get_pass_through_girth()
	return birth_girth || ..()

/// The host may push a hatchling out only when its kind lets go; the rest keeps the storage's own rule.
/obj/item/mob_holder/internal_womb/can_remove_from_body_storage(removal_reason = BODYSTORAGE_REMOVE_MANUAL)
	if(removal_reason != BODYSTORAGE_REMOVE_MANUAL)
		return ..()
	var/datum/component/internal_womb_hatchling/hatchling = GetComponent(/datum/component/internal_womb_hatchling)
	return hatchling?.can_be_pushed_out() || FALSE

/mob/living/carbon/proc/get_birth_fatigue()
	var/cutoff = world.time - LABOUR_FATIGUE_WINDOW
	while(length(recent_labours) && recent_labours[1] <= cutoff)
		recent_labours.Cut(1, 2)
	return length(recent_labours)

/mob/living/carbon/proc/record_labour()
	LAZYADD(recent_labours, world.time)

/// TRUE while the egg or hatchling holder still sits in this organ's storage.
/proc/is_passenger_inside(obj/item/passenger, obj/item/organ/container)
	if(!passenger || QDELETED(passenger) || !container || QDELETED(container))
		return FALSE
	if(istype(passenger, /obj/item/oviposition_egg))
		return container.is_oviposition_egg(passenger)
	return !!SEND_SIGNAL(container, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, passenger)

/// The organ that holds this egg or hatchling for its owner, or null.
/mob/living/carbon/proc/get_passenger_container(obj/item/passenger)
	var/obj/item/organ/container = passenger?.loc
	if(istype(container) && container.owner == src && is_passenger_inside(passenger, container))
		return container
	// A holder with a live mob hangs off the body itself; find the organ whose storage lists it.
	for(var/obj/item/organ/organ as anything in internal_organs)
		if(is_passenger_inside(passenger, organ))
			return organ
	return null

/// Width a passenger passes the opening with: eggs and hatchlings carry their own, anything else its insert girth.
/proc/get_passenger_birth_girth(obj/item/passenger)
	if(istype(passenger, /obj/item/oviposition_egg))
		var/obj/item/oviposition_egg/egg = passenger
		return egg.get_birth_girth()
	if(istype(passenger, /obj/item/mob_holder/internal_womb))
		var/obj/item/mob_holder/internal_womb/holder = passenger
		if(holder.birth_girth)
			return holder.birth_girth
	return passenger.get_insert_girth()

// ---- How a passage feels ----

/// How much of a passage of [girth] is pleasure: all of it within comfort, none past the pain strain.
/mob/living/carbon/proc/get_birth_pleasure_share(datum/orifice/opening, girth, include_kinks = TRUE)
	if(!opening)
		return 0
	var/share = clamp((BIRTH_PAIN_STRAIN - opening.get_strain(girth)) / (BIRTH_PAIN_STRAIN - 1), 0, 1)
	if(include_kinks && has_quirk(/datum/quirk/negative/addiction/masochist))
		share = max(share, BIRTH_MASOCHIST_FLOOR)
	return share

/// The passage itself as it feels at [share]: pleasure, the opening's wear-aware pass and gush, and the voice.
/mob/living/carbon/proc/feel_birth_passage(share, datum/orifice/opening)
	if(share > 0)
		SEND_SIGNAL(src, COMSIG_SEX_GENERIC_ACTION, src, BIRTH_DELIVERY_PLEASURE * share, 0, BIRTH_DELIVERY_CLIMAX * share, src)
	if(opening)
		opening.play_passage_sound("pass", 50, src)
		addtimer(CALLBACK(opening, TYPE_PROC_REF(/datum/orifice, play_passage_sound), "gush", 40, src), 3)
	else
		playsound(src, 'sound/effects/wounds/splatter.ogg', 40, TRUE)
	toy_voice(BIRTH_FEELS_GOOD(share) ? "sexmoanhvy" : (BIRTH_FEELS_MIXED(share) ? "groan" : "painmoan"), opening)
	hole_shake_hook("birth", 2)

/// A birth leaves what the egg carried in the canal: slime counts as lube, venom stings, the rest soaks in.
/// [share] scales it: a birth leaves all of it, an egg on the way in only its coat.
/obj/item/organ/genitals/filling_organ/proc/take_birth_residue(obj/item/oviposition_egg/egg, share = 1)
	if(!egg || !reagents || share <= 0)
		return
	var/list/residue = egg.get_birth_residue()
	if(!length(residue))
		return
	var/datum/orifice/opening = get_orifice(FALSE)
	var/lube_before = opening?.get_lube_level() || 0
	var/stings = FALSE
	for(var/reagent_type in residue)
		var/amount = min(residue[reagent_type] * share, max(0, reagents.maximum_volume - reagents.total_volume))
		if(amount <= 0)
			continue
		reagents.add_reagent(reagent_type, amount)
		if(ispath(reagent_type, /datum/reagent/toxin))
			stings = TRUE
	if(stings)
		opening?.add_soreness(OVI_EGG_RESIDUE_VENOM_SORENESS)
	if(!owner)
		return
	if(stings)
		to_chat(owner, span_warning("It leaves a stinging wetness behind."))
	else if((opening?.get_lube_level() || 0) > lube_before)
		to_chat(owner, span_love("It leaves me slick and dripping."))

/// The glow after an easy birth.
/datum/stress_event/birth_afterglow
	timer = 5 MINUTES
	stress_change = -2
	desc = span_green("My body gave, and it felt good.")

/// Starts labour for a ripe egg or a hatchling; TRUE while labour runs for it.
/mob/living/carbon/proc/start_labour(obj/item/passenger, obj/item/organ/container, voluntary = FALSE)
	if(stat == DEAD || !passenger || !container)
		return FALSE
	var/datum/status_effect/labour/labour = has_status_effect(/datum/status_effect/labour)
	if(labour)
		return labour.passenger_ref?.resolve() == passenger
	labour = apply_status_effect(/datum/status_effect/labour)
	if(!labour)
		return FALSE
	labour.begin(passenger, container, voluntary)
	return TRUE

/// The passenger leaves right now, through the opening in front of its host; a hatchling is born the same way.
/mob/living/carbon/proc/expel_passenger_now(obj/item/passenger, obj/item/organ/container)
	if(istype(passenger, /obj/item/mob_holder/internal_womb))
		var/datum/component/internal_womb_hatchling/hatchling = passenger.GetComponent(/datum/component/internal_womb_hatchling)
		return hatchling?.birth_hatchling() || FALSE
	var/obj/item/oviposition_egg/egg = passenger
	if(!istype(egg))
		return FALSE
	if(!SEND_SIGNAL(container, COMSIG_BODYSTORAGE_TRY_REMOVE, egg, null, BODYSTORAGE_REMOVE_MANUAL))
		return FALSE
	var/obj/item/organ/genitals/filling_organ/canal = container.get_birth_canal()
	var/datum/orifice/opening
	var/share = 0
	var/feel = ""
	if(istype(canal) && canal.orifice_type)
		opening = canal.get_orifice()
		var/girth = get_passenger_birth_girth(egg)
		// Judge the fit and the feel before the passage widens the opening to the egg.
		share = get_birth_pleasure_share(opening, girth)
		feel = canal.get_hole_feel("pass")
		opening.pass_through(girth, SEX_FORCE_MID, src)
		canal.take_birth_residue(egg)
	egg.forceMove(get_turf(src))
	var/location = container.get_oviposition_location_name()
	if(BIRTH_FEELS_GOOD(share))
		visible_message(span_notice("[src] [container.get_oviposition_lay_verb()] [egg] with a last, shuddering push."), span_love("With a last push, the [egg.name] slides out of my [location] in a hot rush that is all pleasure[feel]."))
	else
		visible_message(span_notice("[src] [container.get_oviposition_lay_verb()] [egg] with a last hard push."), span_love("With a last push, the [egg.name] slides out of my [location][feel]."))
	feel_birth_passage(share, opening)
	return TRUE

// ---- Pushing an egg out by hand ----

/// Why an egg or hatchling cannot be pushed out right now, or null when it can.
/mob/living/carbon/human/proc/get_push_out_block_reason(obj/item/passenger, obj/item/organ/container)
	if(stat != CONSCIOUS)
		return "I am in no state to push."
	if(incapacitated())
		return "I can't brace myself like this."
	if(has_status_effect(/datum/status_effect/labour))
		return "My body is already pushing."
	if(!passenger.can_remove_from_body_storage(BODYSTORAGE_REMOVE_MANUAL))
		if(istype(passenger, /obj/item/mob_holder/internal_womb))
			return "It clings to me too tightly to push out yet."
		return "That one is too deep, or too much a part of me, to push out."
	return get_passage_block_reason(passenger, container, src)

/// What the body puts in the way out for [actor], or null: armor, a worn device, a plug, a penetration, size.
/mob/living/carbon/human/proc/get_passage_block_reason(obj/item/passenger, obj/item/organ/container, mob/living/actor)
	var/obj/item/organ/genitals/filling_organ/canal = container.get_birth_canal()
	if(!istype(canal) || !canal.orifice_type)
		return null
	// The panel's rules: only armor above light keeps hands off, and a worn device seals its slot.
	if(get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, actor))
		return "My armor is in the way."
	if(is_organ_slot_blocked(canal.slot))
		return "Something worn seals the way out."
	var/datum/component/body_storage/passage = canal.GetComponent(/datum/component/body_storage)
	if(passage?.has_layer_insertion_blocker(passenger, STORAGE_LAYER_DEEP))
		return "Something plugs the way out."
	var/datum/orifice/opening = canal.get_orifice()
	if(length(opening.get_live_penetrations()))
		return "Not with that inside me."
	if(get_passenger_birth_girth(passenger) > opening.get_max_girth())
		return "It is too big to pass. I would need more stretching, or something slick."
	return null

/// Pushes one egg or hatchling out by hand over a few timed pushes; a ripe egg starts a labour instead.
/mob/living/carbon/human/proc/try_push_out_passenger(obj/item/passenger)
	var/obj/item/organ/container = get_passenger_container(passenger)
	if(!container)
		return FALSE
	var/reason = get_push_out_block_reason(passenger, container)
	if(reason)
		to_chat(src, span_warning(reason))
		return FALSE
	if(istype(passenger, /obj/item/oviposition_egg))
		var/obj/item/oviposition_egg/egg = passenger
		var/datum/component/pregnancy/pregnancy = egg.get_pregnancy_component()
		if(pregnancy && pregnancy.stage >= pregnancy.max_stage)
			return start_labour(egg, container, TRUE)
	INVOKE_ASYNC(src, PROC_REF(push_out_passenger), passenger, container)
	return TRUE

/// One egg after another; stops at the first that will not come.
/mob/living/carbon/human/proc/push_out_all_eggs(obj/item/organ/organ)
	for(var/obj/item/oviposition_egg/egg as anything in organ.get_oviposition_eggs())
		if(QDELETED(egg) || !is_passenger_inside(egg, organ))
			continue
		var/reason = get_push_out_block_reason(egg, organ)
		if(reason)
			to_chat(src, span_warning(reason))
			return
		var/datum/component/pregnancy/pregnancy = egg.get_pregnancy_component()
		if(pregnancy && pregnancy.stage >= pregnancy.max_stage)
			start_labour(egg, organ, TRUE)
			return
		if(!push_out_passenger(egg, organ))
			return

/// Timed pushes that feel by fit; a passenger wider than comfort costs more, hurts, and may slip back.
/mob/living/carbon/human/proc/push_out_passenger(obj/item/passenger, obj/item/organ/container)
	var/obj/item/organ/genitals/filling_organ/canal = container.get_birth_canal()
	var/datum/orifice/opening = (istype(canal) && canal.orifice_type) ? canal.get_orifice() : null
	var/girth = get_passenger_birth_girth(passenger)
	var/is_hatchling = istype(passenger, /obj/item/mob_holder/internal_womb)
	var/slip_bonus = get_passenger_slip_chance(passenger)
	var/strain_over = opening ? max(0, opening.get_strain(girth) - 1) : 0
	var/share = get_birth_pleasure_share(opening, girth)
	var/ease = get_birth_pleasure_share(opening, girth, FALSE)
	var/pushes = clamp(1 + round(strain_over * 2), 1, EGG_PUSH_MAX_PUSHES)
	if(BIRTH_FEELS_GOOD(share))
		visible_message(span_notice("[src] squats down, breathing slow, and bears down."), span_love("I squat down and bear down on the [passenger.name] inside me, and the pressure of it feels good..."))
	else
		visible_message(span_warning("[src] squats down and strains, bearing down."), span_warning("I squat down and bear down on the [passenger.name] inside me..."))
	var/done = 0
	var/attempts = 0
	while(done < pushes)
		if(attempts++ >= EGG_PUSH_MAX_PUSHES * 2)
			to_chat(src, span_warning("I can't get the [passenger.name] past the opening. Not like this."))
			return FALSE
		if(!do_after(src, EGG_PUSH_TIME, src, extra_checks = CALLBACK(src, PROC_REF(can_keep_pushing), passenger, container)))
			to_chat(src, span_warning("I lose the rhythm, and the [passenger.name] settles back inside."))
			return FALSE
		adjust_stamina(EGG_PUSH_STAMINA * BIRTH_COST_MULT(ease))
		done++
		opening?.apply_passage_pain(girth * done / pushes, src)
		if(share > 0)
			SEND_SIGNAL(src, COMSIG_SEX_GENERIC_ACTION, src, BIRTH_CONTRACTION_PLEASURE * share * 0.5, 0, BIRTH_CONTRACTION_CLIMAX * share * 0.5, src)
		hole_shake_hook("push", 1)
		opening?.play_passage_sound("contraction", 25, src)
		if(done >= pushes)
			break
		var/slip_chance = EGG_PUSH_SLIP_CHANCE * strain_over + slip_bonus
		if(slip_chance > 0 && prob(slip_chance))
			done = max(0, done - 1)
			to_chat(src, span_warning(is_hatchling ? "It squirms back up and clings. I have to start that push over." : "It slips back deeper. I have to start that push over."))
			continue
		if(BIRTH_FEELS_GOOD(share))
			to_chat(src, span_love(pick("It moves, and the slide of it makes me gasp.", "I feel it shift lower, pressing against the opening, and heat follows it.", "Almost... I bear down, and it feels so good.")))
		else if(BIRTH_FEELS_MIXED(share))
			to_chat(src, span_love(pick("It moves, barely. The stretch aches and tingles at once.", "I feel it shift lower, and the ache carries a strange warmth.")))
		else
			to_chat(src, span_warning(pick("It moves, barely. I push again.", "I feel it shift lower, pressing against the opening.", "Almost... I bear down harder.")))
	return expel_passenger_now(passenger, container)

/mob/living/carbon/human/proc/can_keep_pushing(obj/item/passenger, obj/item/organ/container)
	return stat == CONSCIOUS && !incapacitated() && is_passenger_inside(passenger, container)

/// Extra chance per push that a hatchling squirms back up, from its kind; eggs have none.
/proc/get_passenger_slip_chance(obj/item/passenger)
	if(!istype(passenger, /obj/item/mob_holder/internal_womb))
		return 0
	var/datum/component/internal_womb_hatchling/hatchling = passenger.GetComponent(/datum/component/internal_womb_hatchling)
	return hatchling?.get_push_slip_chance() || 0

// ---- Bringing a stomach passenger up ----

/// Why [passenger] cannot be brought up from the stomach, or null: only stomach passengers narrow enough for the throat.
/mob/living/carbon/human/proc/get_retch_block_reason(obj/item/passenger, obj/item/organ/container)
	if(container?.slot != ORGAN_SLOT_GUTS)
		return "That is not in my stomach."
	if(stat != CONSCIOUS)
		return "I am in no state for that."
	if(incapacitated())
		return "I can't brace myself like this."
	if(has_status_effect(/datum/status_effect/labour))
		return "My body is busy with something else."
	if(!passenger.can_remove_from_body_storage(BODYSTORAGE_REMOVE_MANUAL))
		return istype(passenger, /obj/item/mob_holder/internal_womb) ? "It clings too tightly to bring up." : "That one is too much a part of me to bring up."
	if(get_passenger_birth_girth(passenger) > OVI_RETCH_MAX_GIRTH)
		return "It is too big to bring up. It will have to go the other way."
	if(!mouth_is_free(src, cloth_blocks = TRUE))
		return "My mouth is not free."
	return null

/// Heaves a stomach passenger up by hand: a short, costly retch with no pleasure in it.
/mob/living/carbon/human/proc/try_retch_up(obj/item/passenger)
	var/obj/item/organ/container = get_passenger_container(passenger)
	if(!container)
		return FALSE
	var/reason = get_retch_block_reason(passenger, container)
	if(reason)
		to_chat(src, span_warning(reason))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(retch_up), passenger, container)
	return TRUE

/mob/living/carbon/human/proc/retch_up(obj/item/passenger, obj/item/organ/container)
	visible_message(span_warning("[src] bends double, heaving."), span_warning("I bend double and heave, forcing the [passenger.name] up..."))
	if(!do_after(src, RETCH_TIME, src, extra_checks = CALLBACK(src, PROC_REF(can_keep_pushing), passenger, container)))
		to_chat(src, span_warning("The heave passes, and the [passenger.name] settles back down."))
		return FALSE
	adjust_stamina(RETCH_STAMINA)
	adjust_nutrition(-RETCH_NUTRITION)
	Stun(RETCH_STUN, TRUE, TRUE)
	playsound(src, pick('sound/vo/vomit.ogg', 'sound/vo/vomit_2.ogg'), 60, TRUE)
	return bring_up_now(passenger, container)

/// The passenger comes up and out of the mouth; a hatchling is freed the same way.
/mob/living/carbon/proc/bring_up_now(obj/item/passenger, obj/item/organ/container)
	if(istype(passenger, /obj/item/mob_holder/internal_womb))
		var/datum/component/internal_womb_hatchling/hatchling = passenger.GetComponent(/datum/component/internal_womb_hatchling)
		var/freed_name = passenger.name
		if(!hatchling?.release_hatchling(TRUE, 1))
			return FALSE
		visible_message(span_warning("[src] retches, and [freed_name] crawls out of [p_their()] mouth!"), span_warning("I retch, and the [freed_name] crawls out of my mouth."))
		return TRUE
	if(!SEND_SIGNAL(container, COMSIG_BODYSTORAGE_TRY_REMOVE, passenger, null, BODYSTORAGE_REMOVE_MANUAL))
		return FALSE
	passenger.forceMove(get_turf(src))
	visible_message(span_warning("[src] retches, and [passenger] comes up with a wet cough."), span_warning("I retch, and the [passenger.name] comes up with a wet cough."))
	return TRUE

// ---- Labour ----

/// Contractions, then a push, then the aftermath; another ripe passenger in the same organ follows on.
/datum/status_effect/labour
	id = "labour"
	duration = -1
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/labour
	var/datum/weakref/passenger_ref
	var/datum/weakref/container_ref
	var/phase = LABOUR_PHASE_CONTRACTING
	var/contractions_done = 0
	var/contractions_needed = LABOUR_BASE_CONTRACTIONS
	var/next_event = 0
	var/births = 0

/datum/status_effect/labour/on_remove()
	passenger_ref = null
	container_ref = null
	return ..()

/datum/status_effect/labour/proc/is_pushing()
	return phase == LABOUR_PHASE_PUSHING

/// Pleasure share of this passenger's passage, or without kinks the ease that scales the costs.
/datum/status_effect/labour/proc/get_feel(obj/item/passenger, obj/item/organ/container, include_kinks = TRUE)
	var/obj/item/organ/genitals/filling_organ/canal = container.get_birth_canal()
	if(!istype(canal) || !canal.orifice_type)
		return 0
	var/mob/living/carbon/carrier = owner
	return carrier.get_birth_pleasure_share(canal.get_orifice(), get_passenger_birth_girth(passenger), include_kinks)

/datum/status_effect/labour/proc/begin(obj/item/passenger, obj/item/organ/container, voluntary = FALSE)
	passenger_ref = WEAKREF(passenger)
	container_ref = WEAKREF(container)
	var/mob/living/carbon/carrier = owner
	var/fatigue = carrier.get_birth_fatigue()
	contractions_needed = LABOUR_BASE_CONTRACTIONS + fatigue + get_size_contractions(passenger, container) + container.get_birth_extra_contractions()
	// Bearing down on purpose skips the long wait but not the work.
	if(voluntary)
		contractions_needed = max(1, round(contractions_needed / 2))
	contractions_done = 0
	phase = LABOUR_PHASE_CONTRACTING
	next_event = world.time + (voluntary ? 2 SECONDS : LABOUR_CONTRACTION_GAP / 2)
	var/location = container.get_oviposition_location_name()
	if(BIRTH_FEELS_GOOD(get_feel(passenger, container)))
		carrier.visible_message(span_notice("[carrier] goes still and presses a hand low on [carrier.p_their()] belly, lips parting."), span_love("My [location] clenches around the [passenger.name], and a hot shiver follows. It is coming."))
	else
		carrier.visible_message(span_warning("[carrier] goes still and presses a hand to [carrier.p_their()] belly."), span_userdanger("My [location] clenches hard around the [passenger.name]. It is coming."))
	if(fatigue)
		to_chat(carrier, span_warning("My body remembers the last birth too well. This will be harder."))
	if(container.get_birth_extra_contractions())
		to_chat(carrier, span_warning("It has a long way down."))

/// A passenger wider than the opening is comfortable with adds contractions.
/datum/status_effect/labour/proc/get_size_contractions(obj/item/passenger, obj/item/organ/container)
	var/obj/item/organ/genitals/filling_organ/canal = container.get_birth_canal()
	if(!istype(canal) || !canal.orifice_type)
		return 0
	return round(max(0, canal.get_orifice().get_strain(get_passenger_birth_girth(passenger)) - 1) * 2)

/datum/status_effect/labour/tick()
	var/mob/living/carbon/carrier = owner
	if(!istype(carrier) || carrier.stat == DEAD)
		qdel(src)
		return
	var/obj/item/passenger = passenger_ref?.resolve()
	var/obj/item/organ/container = container_ref?.resolve()
	if(!container || QDELETED(container) || container.owner != carrier)
		qdel(src)
		return
	if(!is_passenger_inside(passenger, container))
		// It left some other way; carry on with the next one, or rest.
		if(!queue_next(container))
			finish()
		return
	if(world.time < next_event)
		return
	switch(phase)
		if(LABOUR_PHASE_CONTRACTING)
			contract(passenger, container)
		if(LABOUR_PHASE_PUSHING)
			deliver(passenger, container)

/// One contraction: words, pleasure or pain by fit, the cost, and the drop into pushing when enough have come.
/datum/status_effect/labour/proc/contract(obj/item/passenger, obj/item/organ/container)
	var/mob/living/carbon/carrier = owner
	contractions_done++
	var/location = container.get_oviposition_location_name()
	var/share = get_feel(passenger, container)
	var/ease = get_feel(passenger, container, FALSE)
	var/self_text
	if(BIRTH_FEELS_GOOD(share))
		switch(contractions_done)
			if(1)
				self_text = "A deep, rolling clench moves through my belly and my [location] tightens. It has begun, and it feels good."
			if(2)
				self_text = "Another wave, stronger, squeezing the [passenger.name] lower. Heat follows it."
			else
				self_text = pick("The waves come close now, each one a hot pulse that leaves me gasping.", "My whole body bears down on its own, and every clench sends pleasure through me.")
		carrier.visible_message(span_notice("[carrier] shudders, a hand pressed low on [carrier.p_their()] belly, breath catching."), span_love(self_text))
	else if(BIRTH_FEELS_MIXED(share))
		switch(contractions_done)
			if(1)
				self_text = "A deep cramp rolls through my belly and my [location] tightens. It hurts, and under the hurt something else stirs."
			if(2)
				self_text = "Another contraction, stronger, squeezing the [passenger.name] lower. Ache and want tangle together."
			else
				self_text = pick("The contractions come hard and close. Each one aches, and each one leaves a warm throb behind.", "My body bears down on its own, and I can't tell the ache from the want.")
		carrier.visible_message(span_warning("[carrier] doubles over with a shaky groan, clutching [carrier.p_their()] belly."), span_love(self_text))
	else
		switch(contractions_done)
			if(1)
				self_text = "A deep cramp rolls through my belly and my [location] tightens. It has begun."
			if(2)
				self_text = "Another contraction, stronger, squeezing the [passenger.name] lower."
			else
				self_text = pick("The contractions come hard and close now. I can hardly breathe between them.", "My whole body bears down on its own. There is no stopping this.")
		carrier.visible_message(span_warning("[carrier] doubles over with a groan, clutching [carrier.p_their()] belly."), span_warning(self_text))
	if(share > 0)
		SEND_SIGNAL(carrier, COMSIG_SEX_GENERIC_ACTION, carrier, BIRTH_CONTRACTION_PLEASURE * share, 0, BIRTH_CONTRACTION_CLIMAX * share, carrier)
	apply_pain(passenger, container, 0.5 * (1 - share))
	carrier.adjust_stamina(LABOUR_CONTRACTION_STAMINA * BIRTH_COST_MULT(ease) + LABOUR_FATIGUE_STAMINA * carrier.get_birth_fatigue())
	carrier.toy_voice(BIRTH_FEELS_GOOD(share) ? "sexmoanmed" : (BIRTH_FEELS_MIXED(share) ? "groan" : "painmoan"))
	carrier.hole_shake_hook("contraction", 1)
	play_canal_sound(container, "contraction", 25)
	if(contractions_done >= contractions_needed)
		phase = LABOUR_PHASE_PUSHING
		next_event = world.time + LABOUR_PUSH_DELAY
		if(BIRTH_FEELS_GOOD(share))
			carrier.visible_message(span_notice("[carrier] sinks down, thighs trembling, and bears down with a low moan."), span_love("I can't hold it back any longer. I have to push, and I want to."))
		else
			carrier.visible_message(span_warning("[carrier] drops down, straining, bearing down hard!"), span_userdanger("I can't hold it back any longer. I have to push!"))
		carrier.Knockdown(LABOUR_PUSH_DELAY + 2 SECONDS, TRUE, TRUE)
		return
	next_event = world.time + max(LABOUR_CONTRACTION_GAP_MIN, LABOUR_CONTRACTION_GAP - contractions_done * (3 SECONDS))

/// The canal's wear-aware clip for [kind], when the container births through an opening.
/datum/status_effect/labour/proc/play_canal_sound(obj/item/organ/container, kind, vol)
	var/obj/item/organ/genitals/filling_organ/canal = container.get_birth_canal()
	if(istype(canal) && canal.orifice_type)
		canal.get_orifice().play_passage_sound(kind, vol, owner)

/// Pain through the opening in front of the host, scaled by how much of the passenger presses on it.
/datum/status_effect/labour/proc/apply_pain(obj/item/passenger, obj/item/organ/container, share)
	if(share <= 0)
		return
	var/obj/item/organ/genitals/filling_organ/canal = container.get_birth_canal()
	if(!istype(canal) || !canal.orifice_type)
		return
	canal.get_orifice().apply_passage_pain(get_passenger_birth_girth(passenger) * share, owner)

/// The push: the passage itself happens in the lay, expel or hatchling birth, which also feel it.
/datum/status_effect/labour/proc/deliver(obj/item/passenger, obj/item/organ/container)
	var/mob/living/carbon/carrier = owner
	// Judge the fit before the passage widens the opening to the passenger.
	var/share = get_feel(passenger, container)
	var/ease = get_feel(passenger, container, FALSE)
	var/delivered = FALSE
	if(istype(passenger, /obj/item/mob_holder/internal_womb))
		var/datum/component/internal_womb_hatchling/hatchling = passenger.GetComponent(/datum/component/internal_womb_hatchling)
		delivered = hatchling?.birth_hatchling()
	else if(istype(passenger, /obj/item/oviposition_egg))
		var/obj/item/oviposition_egg/egg = passenger
		var/datum/component/pregnancy/pregnancy = egg.get_pregnancy_component()
		if(pregnancy && pregnancy.stage >= pregnancy.max_stage)
			delivered = pregnancy.lay_egg(get_turf(carrier), TRUE)
		else
			delivered = carrier.expel_passenger_now(egg, container)
	if(!delivered)
		to_chat(carrier, span_warning("I push, but it will not come. My body slackens for a moment."))
		phase = LABOUR_PHASE_CONTRACTING
		contractions_done = max(0, contractions_needed - 1)
		next_event = world.time + LABOUR_CONTRACTION_GAP
		return
	births++
	aftermath(container, share, ease)
	if(!queue_next(container))
		finish()

/// Every birth leaves the carrier wet and the next within the hour harder; a hard one leaves her sore and spent.
/datum/status_effect/labour/proc/aftermath(obj/item/organ/container, share, ease)
	var/mob/living/carbon/carrier = owner
	carrier.record_labour()
	var/obj/item/organ/genitals/filling_organ/canal = container.get_birth_canal()
	if(istype(canal) && canal.orifice_type && ease < 1)
		canal.get_orifice().add_soreness(LABOUR_SORENESS * (1 - ease))
	var/turf/floor = get_turf(carrier)
	var/list/sources = list(container)
	if(canal != container)
		sources += canal
	for(var/obj/item/organ/genitals/filling_organ/organ in sources)
		if(floor && organ.reagents?.total_volume)
			spill_fluid_to_turf(floor, organ.reagents, organ.reagents.total_volume * LABOUR_GUSH_SHARE, FALSE)
	carrier.adjust_stamina(LABOUR_CONTRACTION_STAMINA * 2 * BIRTH_COST_MULT(ease))
	if(ease < 0.5)
		carrier.apply_status_effect(/datum/status_effect/birth_worn, BIRTH_WORN_TIME * carrier.get_birth_fatigue())
	else
		carrier.add_stress(/datum/stress_event/birth_afterglow)
	if(BIRTH_FEELS_GOOD(share))
		to_chat(carrier, span_love(pick("It is out, and the last of it rolls through me as a long, shivering wave with nothing of pain in it.", "The pressure leaves me in one hot rush. I lie back, wet, loose and glowing.")))
	else if(BIRTH_FEELS_MIXED(share))
		to_chat(carrier, span_love(pick("It is out. The ache fades fast, and what it leaves behind is warm.", "The pressure is gone all at once. I lie there trembling, sore and strangely satisfied.")))
	else
		to_chat(carrier, span_love(pick("It is out. Warm wetness runs down my thighs and the ache ebbs, slowly.", "The pressure is gone all at once. I lie there, spent and trembling.")))

/// Another ripe egg or a waiting hatchling in the same organ follows on with less work.
/datum/status_effect/labour/proc/queue_next(obj/item/organ/container)
	if(!container || QDELETED(container))
		return FALSE
	var/obj/item/next
	for(var/obj/item/oviposition_egg/egg as anything in container.get_oviposition_eggs(TRUE))
		var/datum/component/pregnancy/pregnancy = egg.get_pregnancy_component()
		if(pregnancy && !egg.hatch_inside_host && pregnancy.stage >= pregnancy.max_stage)
			next = egg
			break
	if(!next)
		var/list/layers = SEND_SIGNAL(container, COMSIG_BODYSTORAGE_GET_LISTS)
		for(var/layer in layers)
			for(var/obj/item/mob_holder/internal_womb/holder in layers[layer])
				var/datum/component/internal_womb_hatchling/hatchling = holder.GetComponent(/datum/component/internal_womb_hatchling)
				if(hatchling?.leaves_on_its_own())
					next = holder
					break
			if(next)
				break
	if(!next)
		return FALSE
	passenger_ref = WEAKREF(next)
	phase = LABOUR_PHASE_CONTRACTING
	contractions_done = 0
	contractions_needed = max(1, LABOUR_BASE_CONTRACTIONS - 1)
	next_event = world.time + LABOUR_CONTRACTION_GAP_MIN
	to_chat(owner, span_warning("There is another. My [container.get_oviposition_location_name()] tightens again."))
	return TRUE

/datum/status_effect/labour/proc/finish()
	if(births)
		owner.visible_message(span_notice("[owner] goes limp, breathing hard."), span_love("It is over. I am empty, and so tired."))
	qdel(src)

/atom/movable/screen/alert/status_effect/labour
	name = "In labour"
	desc = "My body is pushing something out. How it feels depends on the fit."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "impregnation"

/// Slow and sore after a hard birth; each birth inside the hour adds to it.
/datum/status_effect/birth_worn
	id = "birth_worn"
	duration = BIRTH_WORN_TIME
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/birth_worn
	effectedstats = list("speed" = -1)

/atom/movable/screen/alert/status_effect/birth_worn
	name = "Worn from birth"
	desc = "My body is spent from giving birth. I move slowly, and another so soon would be hard."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "spent_loins"

#undef LABOUR_PHASE_CONTRACTING
#undef LABOUR_PHASE_PUSHING
#undef LABOUR_BASE_CONTRACTIONS
#undef LABOUR_FATIGUE_WINDOW
#undef LABOUR_CONTRACTION_GAP
#undef LABOUR_CONTRACTION_GAP_MIN
#undef LABOUR_PUSH_DELAY
#undef LABOUR_CONTRACTION_STAMINA
#undef LABOUR_FATIGUE_STAMINA
#undef LABOUR_SORENESS
#undef LABOUR_GUSH_SHARE
#undef BIRTH_WORN_TIME
#undef EGG_PUSH_TIME
#undef EGG_PUSH_STAMINA
#undef EGG_PUSH_MAX_PUSHES
#undef EGG_PUSH_SLIP_CHANCE
#undef RETCH_TIME
#undef RETCH_STAMINA
#undef RETCH_NUTRITION
#undef RETCH_STUN
#undef BIRTH_PAIN_STRAIN
#undef BIRTH_CONTRACTION_PLEASURE
#undef BIRTH_CONTRACTION_CLIMAX
#undef BIRTH_DELIVERY_PLEASURE
#undef BIRTH_DELIVERY_CLIMAX
#undef BIRTH_PLEASURE_COST_SHARE
#undef BIRTH_MASOCHIST_FLOOR
#undef BIRTH_COST_MULT
#undef BIRTH_FEELS_GOOD
#undef BIRTH_FEELS_MIXED
