/datum/quirk/neutral/smell_and_musk
	name = "Smell & Musk"
	desc = "My body runs hot. Hard toil soaks me through, and what it leaves on my skin is no common sweat but a heavy, heady musk that clings to my armpits, my groin, my hair and, most of all, my feet, and turns the heads of those with a nose for such things."
	desc_hint = "The harder I labour, the stronger I smell, in four degrees; every quarter-hour of rest softens it by one, and water washes it all away. Those who answer to it, with Musk Susceptibility in their ERP preferences, grow dizzy and dull-witted near me and cannot cool their wanting; a pleasant scent lifts their spirits, and a foul one sours them. My sweat gathers in my armpits, my crotch, between my cheeks and, thickest of all, on my feet, twice as fast where hair grows or shoes close over it, ready to be pressed into a face, wiped on it or licked away. Dressed from chest to soles, I can keep my scent under my clothes. Those with Scent Submission are bound to it ever deeper, a step for every night they sleep, until they do as I bid; the most devoted always conceive from me, and I from them should I wish it. They may find a little of me in their cup. The bloodless never sweat."
	preview_render = FALSE
	extra_customization_fields = list(
		list("key" = "scent", "label" = "Scent", "type" = QUIRK_SELECT, "default" = MUSK_SCENT_NEUTRAL, "options" = MUSK_SCENT_QUALITIES),
		list("key" = "first_note", "label" = "First Note", "type" = QUIRK_SELECT, "default" = MUSK_NOTE_NONE, "options" = MUSK_NOTES),
		list("key" = "second_note", "label" = "Second Note", "type" = QUIRK_SELECT, "default" = MUSK_NOTE_NONE, "options" = MUSK_NOTES),
		list("key" = "third_note", "label" = "Third Note", "type" = QUIRK_SELECT, "default" = MUSK_NOTE_NONE, "options" = MUSK_NOTES),
		list("key" = "hidden", "label" = "Hide Under Clothes", "type" = QUIRK_SELECT, "default" = "No", "options" = list("No", "Yes")),
		list("key" = "conceives", "label" = "Conceive From Devoted", "type" = QUIRK_SELECT, "default" = "No", "options" = list("No", "Yes")),
	)

/datum/quirk/neutral/smell_and_musk/on_spawn()
	. = ..()
	var/datum/component/musk/musk = owner?.LoadComponent(/datum/component/musk)
	musk?.set_scent(get_extra_value("scent"), get_chosen_notes(), get_extra_value("hidden") == "Yes", get_extra_value("conceives") == "Yes")

/datum/quirk/neutral/smell_and_musk/on_remove()
	if(!QDELETED(owner))
		owner.remove_status_effect(/datum/status_effect/musk)
		qdel(owner.get_musk())
	return ..()

/datum/quirk/neutral/smell_and_musk/proc/get_chosen_notes()
	. = list()
	for(var/field in list("first_note", "second_note", "third_note"))
		var/note = get_extra_value(field)
		if(note != MUSK_NOTE_NONE)
			. |= note

/datum/erp_preference/boolean/musk_susceptibility
	name = "Musk Susceptibility"
	description = "The rank, heady musk of a body worked to a sweat. Near someone with the Smell & Musk quirk it goes to your head, dulls your wits and keeps you wanting, and their sweat-soaked armpits, crotch, cheeks and feet can be pressed into your face or licked clean, while a foot wiped on your face leaves its smell on you. A press also makes you climax, up to twice in a row."
	default_value = FALSE
	category = "General"

/datum/component/musk
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/musk_sweat/sweat
	var/energy_spent = 0
	var/next_level_cost = 0
	var/scent_quality = MUSK_SCENT_NEUTRAL
	var/list/scent_notes
	var/hidden_under_clothes = FALSE
	var/conceives_from_devoted = FALSE
	var/list/datum/musk_bond/bonds_in_reach

/datum/component/musk/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	sweat = new(parent)

/datum/component/musk/Destroy(force)
	for(var/datum/musk_bond/bond as anything in bonds_in_reach)
		bond.end_contact()
	QDEL_NULL(sweat)
	return ..()

/datum/component/musk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ENERGY_SPENT, PROC_REF(on_energy_spent))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_wash))
	RegisterSignal(parent, COMSIG_SEX_ACTION_TICK, PROC_REF(on_sex_beat))
	var/mob/living/carbon/human/owner = parent
	add_verb(owner, get_holder_verbs())
	owner.learn_to_review_scent_bonds()

/datum/component/musk/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_ENERGY_SPENT, COMSIG_COMPONENT_CLEAN_ACT, COMSIG_SEX_ACTION_TICK))
	remove_verb(parent, get_holder_verbs())

/datum/component/musk/proc/get_holder_verbs()
	var/static/list/holder_verbs = list(
		/mob/living/carbon/human/proc/toggle_hidden_scent,
		/mob/living/carbon/human/proc/slip_fluids_into_drink,
	)
	return holder_verbs

/datum/component/musk/proc/can_sweat()
	var/mob/living/carbon/human/owner = parent
	if(owner.stat == DEAD)
		return FALSE
	if(NOBLOOD in owner.dna?.species?.species_traits)
		return FALSE
	return owner.blood_volume > 0

/datum/component/musk/proc/roll_level_cost()
	var/mob/living/carbon/human/owner = parent
	return max(owner.max_energy, 1) * rand(MUSK_LEVEL_COST_MIN_PERCENT, MUSK_LEVEL_COST_MAX_PERCENT) / 100

/datum/component/musk/proc/on_energy_spent(datum/source, amount)
	SIGNAL_HANDLER
	if(amount <= 0 || !can_sweat())
		return
	if(!next_level_cost)
		next_level_cost = roll_level_cost()
	energy_spent += amount
	var/levels_gained = 0
	while(energy_spent >= next_level_cost && levels_gained < MUSK_LEVEL_MAX)
		energy_spent -= next_level_cost
		next_level_cost = roll_level_cost()
		levels_gained++
		work_up_musk()

/datum/component/musk/proc/work_up_musk()
	var/mob/living/carbon/human/owner = parent
	sweat.add_layer()
	var/datum/status_effect/musk/musk = owner.has_status_effect(/datum/status_effect/musk)
	if(musk)
		musk.strengthen()
		return
	owner.apply_status_effect(/datum/status_effect/musk, 1)

/datum/component/musk/proc/on_wash(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!(clean_types & (CLEAN_WASH | CLEAN_SCRUB | CLEAN_ALL)))
		return
	var/mob/living/carbon/human/owner = parent
	energy_spent = 0
	var/washed = sweat.wash()
	if(owner.remove_status_effect(/datum/status_effect/musk))
		washed = TRUE
	if(washed)
		to_chat(owner, span_notice(musk_wash_text(owner)))

/datum/component/musk/proc/on_sex_beat(datum/source, datum/sex_action/action, mob/living/user, mob/living/target)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/partner = user == parent ? target : user
	if(partner == parent || !ishuman(partner) || !is_smelling() || !partner.can_smell_musk())
		return
	partner.touch_musk(parent, MUSK_GAIN_TOUCH)

/datum/musk_sweat
	var/mob/living/carbon/human/owner
	var/list/stacks

/datum/musk_sweat/New(mob/living/carbon/human/new_owner)
	owner = new_owner
	stacks = list(
		MUSK_ZONE_ARMPITS = 0,
		MUSK_ZONE_GROIN = 0,
		MUSK_ZONE_BUTT = 0,
		MUSK_ZONE_FEET = 0,
	)

/datum/musk_sweat/Destroy(force)
	owner = null
	return ..()

/datum/musk_sweat/proc/get_stacks(zone)
	return stacks[zone] || 0

/datum/musk_sweat/proc/get_max_stacks(zone)
	return zone == MUSK_ZONE_FEET ? MUSK_SWEAT_FEET_MAX_STACKS : MUSK_SWEAT_MAX_STACKS

/datum/musk_sweat/proc/get_ripest_zone(list/zones)
	var/most = 0
	for(var/zone in zones)
		if(stacks[zone] > most)
			most = stacks[zone]
			. = zone

/datum/musk_sweat/proc/get_hair_level(zone)
	var/feature_slot
	switch(zone)
		if(MUSK_ZONE_ARMPITS)
			feature_slot = BODYPART_FEATURE_ARMPIT_HAIR
		if(MUSK_ZONE_GROIN)
			feature_slot = BODYPART_FEATURE_PUBIC_HAIR
	if(!feature_slot || QDELETED(owner))
		return HAIRINESS_SHAVED
	var/datum/bodypart_feature/hair/body_hair/hair = owner.get_bodypart_feature_of_slot(feature_slot)
	return hair ? hair.current_level : HAIRINESS_SHAVED

/datum/musk_sweat/proc/get_quality(zone)
	var/hair_level = get_hair_level(zone)
	if(hair_level >= HAIRINESS_HAIRY)
		return MUSK_QUALITY_VERY_HAIRY
	if(hair_level >= HAIRINESS_SOME_HAIR)
		return MUSK_QUALITY_HAIRY
	return MUSK_QUALITY_BARE

/datum/musk_sweat/proc/get_tier(zone)
	var/tier = get_stacks(zone)
	if(get_quality(zone) == MUSK_QUALITY_VERY_HAIRY)
		tier += 1
	return clamp(tier, 1, MUSK_TIER_MAX)

/datum/musk_sweat/proc/get_gain(zone)
	if(zone != MUSK_ZONE_FEET)
		return get_quality(zone) >= MUSK_QUALITY_HAIRY ? MUSK_SWEAT_HAIRY_GAIN : MUSK_SWEAT_BARE_GAIN
	if(!owner.has_a_foot())
		return 0
	return owner.shoes ? MUSK_SWEAT_SHOD_GAIN : MUSK_SWEAT_BARE_GAIN

/datum/musk_sweat/proc/add_layer()
	for(var/zone in stacks)
		stacks[zone] = min(stacks[zone] + get_gain(zone), get_max_stacks(zone))

/datum/musk_sweat/proc/spend(zone)
	if(!get_stacks(zone))
		return FALSE
	stacks[zone]--
	return TRUE

/datum/musk_sweat/proc/wipe(zone)
	if(!(zone in stacks))
		return 0
	. = stacks[zone]
	stacks[zone] = 0

/datum/musk_sweat/proc/wash()
	. = FALSE
	for(var/zone in stacks)
		if(stacks[zone])
			. = TRUE
			stacks[zone] = 0

/mob/living/proc/get_musk()
	RETURN_TYPE(/datum/component/musk)
	return GetComponent(/datum/component/musk)

/mob/living/proc/get_musk_sweat()
	RETURN_TYPE(/datum/musk_sweat)
	return get_musk()?.sweat

/mob/living/carbon/human/proc/has_a_foot()
	return get_bodypart(BODY_ZONE_PRECISE_L_FOOT) || get_bodypart(BODY_ZONE_PRECISE_R_FOOT)

/mob/living/carbon/human/proc/is_musk_susceptible()
	return get_erp_pref(/datum/erp_preference/boolean/musk_susceptibility) == TRUE

/mob/living/carbon/human/proc/can_smell_musk()
	return stat == CONSCIOUS && can_smell() && !HAS_TRAIT(src, TRAIT_NOBREATH) && !HAS_TRAIT(src, TRAIT_DEADNOSE)

/mob/living/carbon/human/proc/smell_musk(level, mob/living/source)
	if(!can_smell_musk())
		return FALSE
	touch_musk(source, MUSK_GAIN_WHIFF)
	return take_musk_hit(level, source)

/mob/living/carbon/human/proc/take_musk_hit(level, mob/living/source, silent = FALSE)
	var/datum/status_effect/debuff/musk_haze/haze = has_status_effect(/datum/status_effect/debuff/musk_haze)
	if(haze && haze.level >= level)
		if(haze.level == level && is_musk_susceptible())
			haze.refresh()
		return FALSE
	if(!is_musk_susceptible())
		return FALSE
	if(haze)
		return haze.intensify(level, silent, source)
	return !!apply_status_effect(/datum/status_effect/debuff/musk_haze, level, silent, source)
