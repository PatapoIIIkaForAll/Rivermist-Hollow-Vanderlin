// A stretchable opening: rest, current, comfort and max girth in centimetres, with lazy recovery.

/obj/item/organ/genitals/filling_organ
	/// Orifice datum type for openings that stretch; null for organs that do not.
	var/orifice_type
	var/datum/orifice/orifice

/obj/item/organ/genitals/filling_organ/vagina
	orifice_type = /datum/orifice/vagina

/obj/item/organ/genitals/filling_organ/anus
	orifice_type = /datum/orifice/anus

/// Returns the orifice, made on first real use so idle bodies carry none.
/obj/item/organ/genitals/filling_organ/proc/get_orifice(create = TRUE)
	RETURN_TYPE(/datum/orifice)
	if(orifice || !orifice_type)
		return orifice
	if(!create)
		return null
	orifice = new orifice_type(src)
	return orifice

/obj/item/organ/genitals/filling_organ/Destroy()
	QDEL_NULL(orifice)
	return ..()

/// Live penetrations are tracked by the action, so the stand-in item is not a passage.
/obj/item/organ/genitals/filling_organ/proc/on_orifice_item_inserted(obj/item/inserted_item, target_layer)
	if(!orifice_type || target_layer != STORAGE_LAYER_INNER || istype(inserted_item, /obj/item/penis_fake))
		return
	// A hatchling appears inside; it passes the opening only when it is born.
	if(istype(inserted_item, /obj/item/mob_holder/internal_womb))
		return
	var/datum/orifice/hole = get_orifice()
	hole.pass_through(inserted_item.get_pass_through_girth(), SEX_FORCE_MID, null)

/obj/item/organ/genitals/filling_organ/proc/on_orifice_item_removed(obj/item/removed_item)
	if(!orifice || istype(removed_item, /obj/item/penis_fake))
		return
	orifice.get_current_girth()
	orifice.pass_through(removed_item.get_pass_through_girth(), SEX_FORCE_MID, null)

/obj/item/organ/genitals/filling_organ/get_body_storage_capacity(layer, base_bulk)
	var/datum/orifice/hole = get_orifice(FALSE)
	if(!hole)
		return base_bulk
	var/current = hole.get_current_girth()
	if(layer == STORAGE_LAYER_INNER)
		// Room for anything the width check lets in, even while the hole is still small.
		return max(base_bulk, current / ORIFICE_BULK_PER_CM * ORIFICE_INNER_CAPACITY_MULT, hole.get_max_girth() / ORIFICE_BULK_PER_CM)
	if(layer == STORAGE_LAYER_DEEP)
		return base_bulk * (current / max(hole.get_rest_girth(), 1))
	return base_bulk

/obj/item/organ/genitals/filling_organ/has_dynamic_body_storage()
	return !isnull(orifice)

/obj/item/organ/genitals/filling_organ/has_body_storage_width_check()
	return !!orifice_type

/obj/item/organ/genitals/filling_organ/get_body_storage_width_feedback(obj/item/incoming_item, target_layer, force)
	if(!orifice_type || target_layer != STORAGE_LAYER_INNER || !incoming_item)
		return INSERT_FEEDBACK_OK
	return get_orifice().check_width(incoming_item.get_pass_through_girth(), force)

// ---- Item girths ----

/// Girth in centimetres this item has when pushed into an opening.
/obj/item/proc/get_insert_girth()
	return max(body_storage_bulk || w_class, 1) * ORIFICE_GENERIC_GIRTH_PER_BULK

/// Girth this item holds an opening at while stored inside; plugs use their neck.
/obj/item/proc/get_held_open_girth()
	return get_insert_girth()

/// Girth that passes the opening on the way in or out; plugs use their head.
/obj/item/proc/get_pass_through_girth()
	return get_insert_girth()

/obj/item/penis_fake
	/// Girth copied from the real penis; zero falls back to the size bucket.
	var/penis_girth = 0

/obj/item/penis_fake/get_insert_girth()
	if(penis_girth > 0)
		return penis_girth
	return get_penis_length_for_size(penis_size) * get_penis_girth_ratio(penis_type)

/obj/item/organ/genitals/penis
	/// Length in centimetres; zero derives one from the visual size bucket.
	var/length_cm = 0

/obj/item/organ/genitals/penis/proc/get_length_cm()
	if(length_cm > 0)
		return length_cm
	return get_penis_length_for_size(organ_size)

/obj/item/organ/genitals/penis/get_insert_girth()
	return get_length_cm() * get_penis_girth_ratio(penis_type)

/// Girth of the swollen knot while tying.
/obj/item/organ/genitals/penis/proc/get_knot_girth()
	return get_insert_girth() * PENIS_KNOT_GIRTH_MULT

/// Default length for a legacy visual size bucket.
/proc/get_penis_length_for_size(size)
	switch(size)
		if(MIN_PENIS_SIZE)
			return 9
		if(MAX_PENIS_SIZE)
			return 22
	return PENIS_LENGTH_DEFAULT

/// Visual size bucket for a length in centimetres.
/proc/get_penis_visual_size(length)
	if(length <= PENIS_VISUAL_SMALL_MAX)
		return MIN_PENIS_SIZE
	if(length >= PENIS_VISUAL_LARGE_MIN)
		return MAX_PENIS_SIZE
	return DEFAULT_PENIS_SIZE

/// Circumference per centimetre of length by shape; the equine flare carries its width.
/proc/get_penis_girth_ratio(penis_type)
	switch(penis_type)
		if(PENIS_TYPE_KNOTTED, PENIS_TYPE_BARBED, PENIS_TYPE_BARBED_KNOTTED)
			return 0.75
		if(PENIS_TYPE_EQUINE)
			return 0.98
		if(PENIS_TYPE_TAPERED)
			return 0.65
		if(PENIS_TYPE_TAPERED_DOUBLE, PENIS_TYPE_TAPERED_DOUBLE_KNOTTED)
			return 0.99
		if(PENIS_TYPE_TENTACLE)
			return 0.5
		if(PENIS_TYPE_OVIPOSITOR)
			return 0.7
	return 0.8

// ---- The datum ----

/datum/orifice_penetration
	var/datum/weakref/action_ref
	var/datum/weakref/penetrator_ref
	var/girth = 0

/datum/orifice_penetration/Destroy(force)
	action_ref = null
	penetrator_ref = null
	return ..()

/datum/orifice
	var/obj/item/organ/genitals/filling_organ/organ
	/// Where the opening settles when left alone.
	var/rest_girth = 10
	/// Girth at last_update; read it through get_current_girth().
	var/current_girth = 10
	var/last_update = 0
	/// Soreness 0-100 at last_soreness_update; read it through get_soreness().
	var/soreness = 0
	var/last_soreness_update = 0
	/// Gape strain 0-100 at last_gape_strain_update; read it through get_gape_strain().
	var/gape_strain = 0
	var/last_gape_strain_update = 0
	/// Highest giving-way line the owner has felt since the strain was last low.
	var/gape_strain_felt = 0
	/// Rest girth added by Lasting stretch this round.
	var/round_training = 0
	var/last_training_time = 0
	var/last_training_drain = 0
	/// Comfort elasticity added by balms; cleared by their status effect.
	var/elasticity_bonus = 0
	var/list/penetrations = list()
	var/gaped = FALSE
	var/soreness_state = ORIFICE_STATE_FINE
	// Per-organ constants, set on the subtype.
	var/elasticity = 1.5
	var/max_ratio = 2.5
	var/gape_ratio = 1.5
	var/half_life = 20 MINUTES
	var/arousal_bonus = 0.3
	var/list/rest_steps
	var/tightness_pref_type
	var/gaping_status_type
	var/sore_status_type
	var/raw_status_type
	var/overused_status_type
	var/opening_name = "opening"

/datum/orifice/vagina
	elasticity = ORIFICE_VAGINA_ELASTICITY
	max_ratio = ORIFICE_VAGINA_MAX_RATIO
	gape_ratio = ORIFICE_VAGINA_GAPE_RATIO
	half_life = ORIFICE_VAGINA_HALF_LIFE
	arousal_bonus = ORIFICE_VAGINA_AROUSAL_BONUS
	rest_steps = ORIFICE_VAGINA_REST_STEPS
	tightness_pref_type = /datum/erp_preference/list_choice/vaginal_tightness
	gaping_status_type = /datum/status_effect/orifice_gaping/vagina
	sore_status_type = /datum/status_effect/orifice_sore/vagina
	raw_status_type = /datum/status_effect/orifice_raw/vagina
	overused_status_type = /datum/status_effect/orifice_overused/vagina
	opening_name = "pussy"

/datum/orifice/anus
	elasticity = ORIFICE_ANUS_ELASTICITY
	max_ratio = ORIFICE_ANUS_MAX_RATIO
	gape_ratio = ORIFICE_ANUS_GAPE_RATIO
	half_life = ORIFICE_ANUS_HALF_LIFE
	arousal_bonus = ORIFICE_ANUS_AROUSAL_BONUS
	rest_steps = ORIFICE_ANUS_REST_STEPS
	tightness_pref_type = /datum/erp_preference/list_choice/anal_tightness
	gaping_status_type = /datum/status_effect/orifice_gaping/anus
	sore_status_type = /datum/status_effect/orifice_sore/anus
	raw_status_type = /datum/status_effect/orifice_raw/anus
	overused_status_type = /datum/status_effect/orifice_overused/anus
	opening_name = "ass"

/datum/orifice/New(obj/item/organ/genitals/filling_organ/new_organ)
	. = ..()
	organ = new_organ
	refresh_rest_girth()
	current_girth = get_rest_girth()
	last_update = world.time
	last_soreness_update = world.time
	last_gape_strain_update = world.time

/datum/orifice/Destroy(force)
	clear_statuses()
	QDEL_LIST(penetrations)
	organ = null
	return ..()

/datum/orifice/proc/get_owner()
	RETURN_TYPE(/mob/living)
	return organ?.owner

/// The organ changed bodies: new baseline, and no statuses left on the old one.
/datum/orifice/proc/on_organ_removed(mob/living/old_owner)
	clear_statuses(old_owner)
	QDEL_LIST(penetrations)
	// Strain settles while the gape still holds it, so decay out of the body starts now.
	get_gape_strain()
	// The flags reset so the next body gets its statuses applied again.
	gaped = FALSE
	soreness_state = ORIFICE_STATE_FINE

/datum/orifice/proc/on_organ_inserted(mob/living/new_owner)
	refresh_rest_girth()
	current_girth = max(current_girth, get_rest_girth())
	last_update = world.time
	update_gape_state()
	update_soreness_state()

// ---- Baseline ----

/// Baseline from the owner's tightness preference, shifted by body frame.
/datum/orifice/proc/refresh_rest_girth()
	var/step = ORIFICE_TIGHTNESS_AVERAGE
	var/mob/living/owner = get_owner()
	if(owner && tightness_pref_type)
		var/list/names = ORIFICE_TIGHTNESS_NAMES
		var/found = names.Find(owner.get_erp_pref(tightness_pref_type))
		if(found)
			step = found
	step += get_frame_step_shift()
	var/list/steps = rest_steps
	rest_girth = steps[clamp(step, 1, length(steps))]

/// Small frames sit one step tighter, large frames one step looser.
/datum/orifice/proc/get_frame_step_shift()
	var/mob/living/owner = get_owner()
	if(!owner)
		return 0
	if(owner.has_fluid_modifier(/datum/fluid_modifier/small_frame))
		return -1
	if(owner.has_fluid_modifier(/datum/fluid_modifier/large_frame))
		return 1
	return 0

/datum/orifice/proc/get_rest_girth()
	drain_training()
	return max(1, rest_girth + round_training + get_modifier_rest_shift())

/// An hour of rest starts the trained looseness draining back toward the chargen baseline.
/datum/orifice/proc/drain_training()
	if(round_training <= 0)
		return
	var/idle_start = last_training_time + ORIFICE_TRAINING_HOLD
	if(world.time <= idle_start)
		return
	var/minutes = (world.time - max(idle_start, last_training_drain)) / (1 MINUTES)
	if(minutes <= 0)
		return
	round_training = max(0, round_training - rest_girth * ORIFICE_TRAINING_DRAIN_PER_MINUTE * minutes)
	last_training_drain = world.time

/datum/orifice/proc/get_max_girth()
	return max(get_rest_girth() * (max_ratio + get_modifier_max_ratio()), ORIFICE_MAX_GIRTH_FLOOR)

/datum/orifice/proc/get_elasticity()
	return elasticity + elasticity_bonus + get_lube_elasticity_bonus() + get_modifier_elasticity()

// ---- Current state ----

/// Girth stored items hold the opening at; a live penetration adapts the hole instead.
/datum/orifice/proc/get_held_open_girth()
	. = 0
	if(!organ)
		return
	var/list/stored = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_GET_2D_ITEM_LIST)
	if(!islist(stored))
		return
	for(var/obj/item/stored_item as anything in stored)
		if(!stored_item || istype(stored_item, /obj/item/penis_fake))
			continue
		if(SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, stored_item) != STORAGE_LAYER_INNER)
			continue
		. = max(., stored_item.get_held_open_girth())

/// Recovery since the last write, never below what is held inside; leaves the gape state alone.
/datum/orifice/proc/recover_girth()
	var/floor_girth = max(get_rest_girth(), get_held_open_girth())
	if(current_girth > floor_girth)
		var/decay_time = world.time - last_update
		var/effective_half_life = half_life / max(get_recovery_multiplier(), 0.01)
		// A gaping ring springs back faster.
		if(gaped)
			effective_half_life /= ORIFICE_GAPE_RECOVERY_MULT
		if(decay_time > 0 && effective_half_life > 0)
			current_girth = floor_girth + (current_girth - floor_girth) * (0.5 ** (decay_time / effective_half_life))
	current_girth = clamp(current_girth, floor_girth, get_max_girth() * ORIFICE_OVERMAX_ALLOWANCE)
	last_update = world.time
	return current_girth

/// Current girth after recovery; reading it may start or end a gape.
/datum/orifice/proc/get_current_girth()
	recover_girth()
	update_gape_state()
	return current_girth

/datum/orifice/proc/get_arousal_fraction()
	var/mob/living/owner = get_owner()
	if(!owner)
		return 0
	var/list/arousal_data = list()
	SEND_SIGNAL(owner, COMSIG_SEX_GET_AROUSAL, arousal_data)
	return clamp((arousal_data["arousal"] || 0) / ACTIVE_EJAC_THRESHOLD, 0, 1)

/// Comfort girth: relaxed tissue plus bonuses, and being open already is comfortable too.
/datum/orifice/proc/get_comfort_girth()
	return max(get_current_girth(), get_relaxed_comfort_girth())

/// What the tissue relaxes to on its own: rest times elasticity, eased further by arousal and lube.
/datum/orifice/proc/get_relaxed_comfort_girth()
	return get_rest_girth() * get_elasticity() * (1 + arousal_bonus * get_arousal_fraction() + ORIFICE_LUBE_BONUS * get_lube_level())

/// How snug an insertion feels right now.
/datum/orifice/proc/get_fit(girth)
	return girth / max(get_current_girth(), 1)

/// How far an insertion goes past comfort.
/datum/orifice/proc/get_strain(girth)
	return girth / max(get_comfort_girth(), 1)

/// Current girth as a share of rest.
/datum/orifice/proc/get_stretch_ratio()
	return get_current_girth() / max(get_rest_girth(), 1)

/// Combined girth of everything penetrating at once; areas add, not circumferences.
/datum/orifice/proc/get_combined_girth()
	var/area_sum = 0
	for(var/datum/orifice_penetration/entry as anything in get_live_penetrations())
		area_sum += entry.girth ** 2
	return sqrt(area_sum)

// ---- Dryness ----

/// Multiplier on receiver pain and soreness from a lack of lube.
/datum/orifice/proc/get_dryness_multiplier()
	return get_dry_multiplier(get_lube_level())

/datum/orifice/proc/get_dry_multiplier(lube)
	return 1

/datum/orifice/vagina/get_dry_multiplier(lube)
	if(lube >= LUBE_DRY_LEVEL || get_arousal_fraction() * ACTIVE_EJAC_THRESHOLD >= ORIFICE_COLD_AROUSAL)
		return 1
	return ORIFICE_DRY_VAGINA_MULT

/datum/orifice/anus/get_dry_multiplier(lube)
	if(lube >= LUBE_SLICK_LEVEL)
		return 1
	var/ratio = get_stretch_ratio()
	if(ratio >= ORIFICE_DRY_FREE_RATIO)
		return 1
	if(ratio >= ORIFICE_DRY_STRETCHED_RATIO)
		return min(ORIFICE_DRY_STRETCHED_MULT, lube >= LUBE_DRY_LEVEL ? 1 : ORIFICE_DRY_STRETCHED_MULT)
	if(lube >= LUBE_DRY_LEVEL)
		return ORIFICE_DAMP_ANUS_MULT
	return ORIFICE_DRY_ANUS_MULT

/// Soreness per cycle from friction alone.
/datum/orifice/proc/get_chafe(lube)
	return 0

/datum/orifice/vagina/get_chafe(lube)
	if(get_arousal_fraction() * ACTIVE_EJAC_THRESHOLD >= ORIFICE_COLD_AROUSAL)
		return 0
	return (1 - lube) * 0.5

/datum/orifice/anus/get_chafe(lube)
	return 1 - lube

// ---- Stretching ----

/datum/orifice/proc/get_force_factor(force)
	switch(force)
		if(SEX_FORCE_LOW)
			return 0.7
		if(SEX_FORCE_HIGH)
			return 1.3
		if(SEX_FORCE_EXTREME)
			return 1.6
		if(SEX_FORCE_UNRELENTING)
			return 1.9
	return 1

/// Speed scaling for gape strain, shared with the pain table.
/datum/orifice/proc/get_speed_factor(speed)
	switch(speed)
		if(SEX_SPEED_LOW)
			return SEX_SPEED_PAIN_MULT_LOW
		if(SEX_SPEED_HIGH)
			return SEX_SPEED_PAIN_MULT_HIGH
		if(SEX_SPEED_EXTREME)
			return SEX_SPEED_PAIN_MULT_EXTREME
		if(SEX_SPEED_UNRELENTING)
			return SEX_SPEED_PAIN_MULT_UNRELENTING
	return SEX_SPEED_PAIN_MULT_MID

/// One adaptation step toward [girth]; returns the new current girth.
/datum/orifice/proc/stretch_toward(girth, force = SEX_FORCE_MID, share = ORIFICE_ADAPT_RATE)
	var/current = get_current_girth()
	var/target = clamp(girth, current, get_max_girth())
	if(target <= current)
		return current
	current_girth = min(target, current + (target - current) * min(1, share * get_force_factor(force)))
	last_update = world.time
	after_girth_change()
	return current_girth

/// A one-shot passage: the opening takes [girth] at once, with pain, soreness and gape strain.
/datum/orifice/proc/pass_through(girth, force = SEX_FORCE_MID, mob/living/performer)
	if(girth <= 0)
		return
	var/strain = get_strain(girth)
	var/dryness = get_dryness_multiplier()
	add_soreness(max(0, strain - 1 - get_strain_slack()) * ORIFICE_SORENESS_PER_STRAIN * dryness)
	apply_passage_pain(girth, performer)
	var/current = get_current_girth()
	var/target = clamp(girth, current, get_max_girth())
	if(target > current)
		current_girth = target
	last_update = world.time
	after_girth_change()
	add_gape_strain(get_passage_gape_gain(girth))

/// Pain for a passage outside a scene action, through the generic sex action path.
/datum/orifice/proc/apply_passage_pain(girth, mob/living/performer)
	var/mob/living/owner = get_owner()
	var/pain = get_cycle_pain(girth)
	if(!owner || pain <= 0)
		return
	var/datum/component/arousal/arousal = owner.GetComponent(/datum/component/arousal)
	if(arousal)
		var/scaled = arousal.get_scaled_pain(pain, SEX_FORCE_MID, SEX_SPEED_MID)
		if(scaled > ORIFICE_PAIN_CAP)
			pain *= ORIFICE_PAIN_CAP / scaled
	SEND_SIGNAL(owner, COMSIG_SEX_GENERIC_ACTION, owner, 0, pain, 0, performer || owner)

/// A knot torn out opens the hole to the knot and gapes it.
/datum/orifice/proc/on_forced_knot_removal(mob/living/knotter, knot_girth)
	var/current = get_current_girth()
	var/target = max(current, min(get_max_girth(), knot_girth * 1.1), get_rest_girth() * gape_ratio)
	current_girth = target
	last_update = world.time
	after_girth_change()
	add_gape_strain(ORIFICE_GAPE_STRAIN_MAX)

/datum/orifice/proc/after_girth_change()
	update_gape_state()
	if(organ)
		SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_UPDATE_SIZE)

// ---- Width check for storage insertions ----

/// Width axis of an insertion; OK when the opening can take [girth].
/datum/orifice/proc/check_width(girth, force = FALSE)
	if(girth <= 0)
		return INSERT_FEEDBACK_OK
	var/mob/living/owner = get_owner()
	if(get_soreness_state() >= ORIFICE_STATE_OVERUSED && !(force && owner?.has_erp_pref(/datum/erp_preference/boolean/rough_stretching)))
		return INSERT_FEEDBACK_STUFFED
	var/lube = get_lube_level()
	if(girth > get_max_girth())
		if(force && lube >= LUBE_FORCE_SUBSTITUTE_LEVEL && owner?.has_erp_pref(/datum/erp_preference/boolean/rough_stretching))
			return INSERT_FEEDBACK_OK_FORCE
		return INSERT_FEEDBACK_STUFFED
	if(girth > get_comfort_girth())
		if(force || lube >= LUBE_FORCE_SUBSTITUTE_LEVEL || get_current_girth() >= girth * ORIFICE_OPEN_ENOUGH_RATIO)
			return INSERT_FEEDBACK_OK_FORCE
		return INSERT_FEEDBACK_TRY_FORCE
	return INSERT_FEEDBACK_OK

// ---- Penetrations ----

/datum/orifice/proc/get_live_penetrations()
	for(var/datum/orifice_penetration/entry as anything in penetrations)
		var/datum/sex_action/action = entry.action_ref?.resolve()
		if(!action || QDELETED(action) || !action.is_runtime_active())
			penetrations -= entry
			qdel(entry)
	return penetrations

/datum/orifice/proc/find_penetration(datum/sex_action/action)
	if(!action)
		return null
	for(var/datum/orifice_penetration/entry as anything in get_live_penetrations())
		if(entry.action_ref?.resolve() == action)
			return entry
	return null

/datum/orifice/proc/get_penetrator(datum/sex_action/action)
	var/datum/orifice_penetration/entry = find_penetration(action)
	return entry?.penetrator_ref?.resolve()

/// Registers a live penetration and opens the hole part way around it.
/datum/orifice/proc/begin_penetration(datum/sex_action/action, mob/living/penetrator, girth)
	if(!action || girth <= 0)
		return
	end_penetration(action)
	var/datum/orifice_penetration/entry = new
	entry.action_ref = WEAKREF(action)
	entry.penetrator_ref = WEAKREF(penetrator)
	entry.girth = girth
	penetrations += entry
	transfer_penetrator_lube(action, penetrator)
	warn_dryness(penetrator, girth)
	stretch_toward(get_combined_girth(), action.force, ORIFICE_ENTRY_SHARE)
	// Forced in past the maximum, the ring gives way at once.
	if(girth > get_max_girth())
		add_gape_strain(ORIFICE_GAPE_STRAIN_MAX)

/// Reads the girth first so the held-open floor does not count as decay time.
/datum/orifice/proc/end_penetration(datum/sex_action/action)
	get_current_girth()
	for(var/datum/orifice_penetration/entry as anything in penetrations)
		var/datum/sex_action/entry_action = entry.action_ref?.resolve()
		if(entry_action && entry_action != action)
			continue
		penetrations -= entry
		qdel(entry)
	last_update = world.time

/// One thrust cycle: adapt toward the insertion, wear the tissue and the ring.
/datum/orifice/proc/on_penetration_cycle(datum/sex_action/action)
	if(!find_penetration(action))
		return
	var/girth = get_combined_girth()
	var/strain = get_strain(girth)
	var/lube = get_lube_level()
	var/dryness = get_dry_multiplier(lube)
	add_soreness(max(0, strain - 1 - get_strain_slack()) * ORIFICE_SORENESS_PER_STRAIN * dryness + get_chafe(lube))
	stretch_toward(girth, action.force)
	add_gape_strain(get_thrust_gape_gain(girth, action.force, action.speed))
	tick_training()

/// Lasting stretch: time spent well open creeps the baseline, capped per round.
/datum/orifice/proc/tick_training()
	var/mob/living/owner = get_owner()
	if(!owner?.has_erp_pref(/datum/erp_preference/boolean/lasting_stretch))
		return
	if(get_stretch_ratio() < 1.3)
		return
	round_training = min(round_training + rest_girth * 0.005 / 18, rest_girth * 0.25)
	last_training_time = world.time

/// Both sides hear once that a dry act will hurt.
/datum/orifice/proc/warn_dryness(mob/living/penetrator, girth)
	var/mob/living/owner = get_owner()
	if(!owner || get_dryness_multiplier() < ORIFICE_DRY_WARNING_MULT || get_strain(girth) <= 1)
		return
	to_chat(owner, span_warning("This will hurt without something slick."))
	if(penetrator && penetrator != owner)
		to_chat(penetrator, span_warning("[owner]'s [opening_name] is dry; this will hurt [owner.p_them()] without something slick."))

// ---- Pain ----

/datum/orifice/proc/get_soreness_pain()
	switch(get_soreness_state())
		if(ORIFICE_STATE_SORE)
			return ORIFICE_SORE_PAIN
		if(ORIFICE_STATE_RAW)
			return ORIFICE_RAW_PAIN
		if(ORIFICE_STATE_OVERUSED)
			return ORIFICE_OVERUSED_PAIN
	return 0

/// Receiver pain this cycle for [girth], before the arousal component's own multipliers.
/datum/orifice/proc/get_cycle_pain(girth)
	var/strain = get_strain(girth)
	var/dryness = get_dryness_multiplier()
	. = max(0, strain - 1 - get_strain_slack()) * ORIFICE_PAIN_PER_STRAIN * dryness
	. += max(0, dryness - 1) * ORIFICE_FRICTION_PAIN
	. += get_soreness_pain()
	. += get_irritant_pain()
	. *= get_numbing_multiplier()
	if(get_owner()?.has_kink(KINK_SIZE_QUEEN))
		. *= 0.5

/// Cycle pain trimmed so the scaled total never passes the cap.
/datum/orifice/proc/get_capped_cycle_pain(girth, base_pain, force, speed)
	var/pain = get_cycle_pain(girth)
	var/datum/component/arousal/arousal = get_owner()?.GetComponent(/datum/component/arousal)
	if(!arousal || pain <= 0)
		return pain
	var/scaled_total = arousal.get_scaled_pain(base_pain + pain, force, speed)
	if(scaled_total <= ORIFICE_PAIN_CAP)
		return pain
	var/scaled_base = arousal.get_scaled_pain(base_pain, force, speed)
	var/room = max(0, ORIFICE_PAIN_CAP - scaled_base)
	return pain * room / max(scaled_total - scaled_base, 0.01)

// ---- Soreness ----

/datum/orifice/proc/get_soreness()
	var/elapsed_minutes = (world.time - last_soreness_update) / (1 MINUTES)
	if(elapsed_minutes > 0 && soreness > 0)
		soreness = max(0, soreness - elapsed_minutes * ORIFICE_SORENESS_DECAY_PER_MINUTE * get_soreness_decay_multiplier())
	last_soreness_update = world.time
	update_soreness_state()
	return soreness

/datum/orifice/proc/add_soreness(amount)
	if(amount <= 0)
		return
	get_soreness()
	soreness = clamp(soreness + amount, 0, 100)
	update_soreness_state()

/datum/orifice/proc/get_soreness_state()
	get_soreness()
	return soreness_state

/// Moves between Fine, Sore, Raw and Overused with hysteresis, swapping the status effect.
/datum/orifice/proc/update_soreness_state()
	var/new_state = soreness_state
	switch(soreness_state)
		if(ORIFICE_STATE_FINE)
			if(soreness >= ORIFICE_SORE_THRESHOLD)
				new_state = ORIFICE_STATE_SORE
		if(ORIFICE_STATE_SORE)
			if(soreness >= ORIFICE_RAW_THRESHOLD)
				new_state = ORIFICE_STATE_RAW
			else if(soreness < ORIFICE_SORE_THRESHOLD - ORIFICE_SORENESS_HYSTERESIS)
				new_state = ORIFICE_STATE_FINE
		if(ORIFICE_STATE_RAW)
			if(soreness >= ORIFICE_OVERUSED_THRESHOLD)
				new_state = ORIFICE_STATE_OVERUSED
			else if(soreness < ORIFICE_RAW_THRESHOLD - ORIFICE_SORENESS_HYSTERESIS)
				new_state = ORIFICE_STATE_SORE
		if(ORIFICE_STATE_OVERUSED)
			if(soreness < ORIFICE_OVERUSED_THRESHOLD - ORIFICE_SORENESS_HYSTERESIS)
				new_state = ORIFICE_STATE_RAW
	if(new_state == soreness_state)
		return
	set_soreness_state(new_state)

/datum/orifice/proc/get_soreness_status_type(state)
	switch(state)
		if(ORIFICE_STATE_SORE)
			return sore_status_type
		if(ORIFICE_STATE_RAW)
			return raw_status_type
		if(ORIFICE_STATE_OVERUSED)
			return overused_status_type
	return null

/datum/orifice/proc/set_soreness_state(new_state)
	var/mob/living/owner = get_owner()
	var/old_type = get_soreness_status_type(soreness_state)
	soreness_state = new_state
	if(!owner)
		return
	if(old_type)
		owner.remove_status_effect(old_type)
	var/new_type = get_soreness_status_type(new_state)
	if(new_type)
		owner.apply_status_effect(new_type)

// ---- Gape ----

/// Full thrusts one thrust of [girth] counts as: none within the relaxed comfort, one at the full strain, capped.
/datum/orifice/proc/get_gape_ratio_scale(girth)
	// Wear is strain past what the tissue relaxes to: a ready hole is worn by less, a stretched one is no softer.
	var/strain = girth / max(get_relaxed_comfort_girth(), 1)
	return clamp((strain - ORIFICE_GAPE_ONSET_STRAIN) / max(ORIFICE_GAPE_FULL_STRAIN - ORIFICE_GAPE_ONSET_STRAIN, 0.01), 0, ORIFICE_GAPE_SCALE_CAP)

/// Gape strain one thrust of [girth] adds at this force and speed.
/datum/orifice/proc/get_thrust_gape_gain(girth, force, speed)
	return get_gape_ratio_scale(girth) * (ORIFICE_GAPE_STRAIN_MAX / ORIFICE_GAPE_THRUSTS) * get_force_factor(force) * get_speed_factor(speed)

/// Gape strain a passage of [girth] adds; a birth within comfort adds none, anything past the maximum fills it at once.
/datum/orifice/proc/get_passage_gape_gain(girth)
	if(girth > get_max_girth())
		return ORIFICE_GAPE_STRAIN_MAX
	return get_gape_ratio_scale(girth) * ORIFICE_GAPE_PASSAGE_STRAIN

/// Gape strain after idle decay; a gape holds it where it is.
/datum/orifice/proc/get_gape_strain()
	if(!gaped && gape_strain > 0)
		var/elapsed_minutes = (world.time - last_gape_strain_update) / (1 MINUTES)
		if(elapsed_minutes > 0)
			gape_strain = max(0, gape_strain - elapsed_minutes * ORIFICE_GAPE_STRAIN_DECAY_PER_MINUTE)
	last_gape_strain_update = world.time
	if(gape_strain < ORIFICE_GAPE_FEEL_RESET_STRAIN)
		gape_strain_felt = 0
	return gape_strain

/// Wears the ring toward a gape; negative amounts ease it.
/datum/orifice/proc/add_gape_strain(amount)
	if(!amount)
		return
	// Fresh girth first, so the gape check below does not read a stale stretch.
	get_current_girth()
	gape_strain = clamp(get_gape_strain() + amount, 0, ORIFICE_GAPE_STRAIN_MAX)
	if(gape_strain >= ORIFICE_GAPE_STRAIN_MAX - ORIFICE_GAPE_STRAIN_SNAP)
		gape_strain = ORIFICE_GAPE_STRAIN_MAX
	update_gape_state()
	warn_gape_strain()

/// The owner feels the ring giving way once past each line, until the strain falls low again.
/datum/orifice/proc/warn_gape_strain()
	var/mob/living/owner = get_owner()
	if(!owner || gaped)
		return
	if(gape_strain >= ORIFICE_GAPE_FEEL_STRONG_STRAIN && gape_strain_felt < ORIFICE_GAPE_FEEL_STRONG_STRAIN)
		gape_strain_felt = ORIFICE_GAPE_FEEL_STRONG_STRAIN
		to_chat(owner, span_boldwarning("My [opening_name] is about to give way!"))
	else if(gape_strain >= ORIFICE_GAPE_FEEL_STRAIN && gape_strain_felt < ORIFICE_GAPE_FEEL_STRAIN)
		gape_strain_felt = ORIFICE_GAPE_FEEL_STRAIN
		to_chat(owner, span_warning("I feel my [opening_name] giving way..."))

/// Full strain gapes a stretched hole; the gape ends once the girth falls below the end line.
/datum/orifice/proc/update_gape_state()
	var/ratio = current_girth / max(get_rest_girth(), 1)
	if(!gaped && ratio >= ORIFICE_GAPE_ONSET_RATIO && get_gape_strain() >= ORIFICE_GAPE_STRAIN_MAX)
		set_gaped(TRUE)
	else if(gaped && ratio < gape_ratio - ORIFICE_GAPE_HYSTERESIS && !has_gape_lock())
		set_gaped(FALSE)

/datum/orifice/proc/set_gaped(new_state)
	if(gaped == new_state)
		return
	// Recovery so far runs at the old state's speed.
	recover_girth()
	gaped = new_state
	// A gape holds the strain full; closing up starts it over.
	gape_strain = gaped ? ORIFICE_GAPE_STRAIN_MAX : 0
	last_gape_strain_update = world.time
	if(gaped)
		give_way()
	var/mob/living/owner = get_owner()
	if(owner && gaping_status_type)
		if(gaped)
			owner.apply_status_effect(gaping_status_type)
		else
			owner.remove_status_effect(gaping_status_type)
	organ?.on_orifice_gape_changed(gaped)

/// The ring gives way: the opening springs to at least the gape ratio, clear of the end line.
/datum/orifice/proc/give_way()
	var/gape_girth = gape_ratio * get_rest_girth()
	if(current_girth >= gape_girth)
		return
	current_girth = gape_girth
	last_update = world.time
	if(organ)
		SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_UPDATE_SIZE)

/// Hook for sprite and render-key updates when the gape state flips.
/obj/item/organ/genitals/filling_organ/proc/on_orifice_gape_changed(now_gaped)
	return

/// A knot torn out opens the hole it was tied in.
/datum/component/knotting/proc/gape_knotted_hole(mob/living/top)
	var/obj/item/organ/genitals/filling_organ/hole = knotted_hole_ref?.resolve()
	if(!istype(hole) || !hole.orifice_type)
		return
	var/datum/orifice/orifice = hole.get_orifice()
	var/obj/item/organ/genitals/penis/penis = top?.getorganslot(ORGAN_SLOT_PENIS)
	orifice.on_forced_knot_removal(top, penis ? penis.get_knot_girth() : orifice.get_rest_girth() * orifice.gape_ratio)

/datum/orifice/proc/clear_statuses(mob/living/target = get_owner())
	if(!target)
		return
	if(gaping_status_type)
		target.remove_status_effect(gaping_status_type)
	for(var/state in list(ORIFICE_STATE_SORE, ORIFICE_STATE_RAW, ORIFICE_STATE_OVERUSED))
		var/status_type = get_soreness_status_type(state)
		if(status_type)
			target.remove_status_effect(status_type)
