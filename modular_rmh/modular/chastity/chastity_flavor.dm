// Chastity flavour: wearer-only reactions to sex actions and walking, the caged climax, and arcane tally marks.

/// Steps between two jingle rolls.
#define CHASTITY_JINGLE_STEPS 4
/// Percent chance per roll that the device jingles.
#define CHASTITY_JINGLE_CHANCE 5
/// Connected clients above which jingles are rarer.
#define CHASTITY_JINGLE_HIGH_POP 120
/// Cooldowns between flavour lines of each kind.
#define CHASTITY_RECEIVE_COOLDOWN (8 SECONDS)
#define CHASTITY_AROUSAL_COOLDOWN (10 SECONDS)
#define CHASTITY_MOVEMENT_COOLDOWN (10 SECONDS)
/// Units of seed a sealed pussy must hold for the retention lines.
#define CHASTITY_RETENTION_UNITS 3
/// Orgasm progress for the "on the edge" lines.
#define CHASTITY_EDGE_PROGRESS 70
/// A partner's repeated spurts within this window count as one tally.
#define CHASTITY_TALLY_WINDOW (10 SECONDS)

/obj/item/clothing/undies/chastity
	/// Steps walked since the last jingle roll.
	var/tmp/jingle_steps = 0
	COOLDOWN_DECLARE(receive_flavor_cooldown)
	COOLDOWN_DECLARE(arousal_flavor_cooldown)
	COOLDOWN_DECLARE(movement_flavor_cooldown)

/obj/item/clothing/undies/chastity/get_sex_action_effects(datum/sex_action_effect_context/context)
	if(!wearer)
		return null
	return list(new /datum/sex_action_effect/chastity(src))

/datum/sex_action_effect/chastity

/datum/sex_action_effect/chastity/after_action(datum/sex_action_effect_context/context)
	var/obj/item/clothing/undies/chastity/device = source_item
	device?.on_worn_sex_action(context)

/datum/sex_action_effect/chastity/intercept_climax(datum/sex_action_effect_context/context, datum/reagents/source_reagents, amount)
	var/obj/item/clothing/undies/chastity/device = source_item
	return device?.catch_climax(context, source_reagents, amount) || 0

/// TRUE if the wearer has a cock this device cages.
/obj/item/clothing/undies/chastity/proc/cages_cock()
	return get_real_organ(wearer, ORGAN_SLOT_PENIS) && blocks_organ_use(ORGAN_SLOT_PENIS)

/// TRUE if the wearer has a pussy this device seals.
/obj/item/clothing/undies/chastity/proc/seals_pussy()
	return get_real_organ(wearer, ORGAN_SLOT_VAGINA) && blocks_organ_use(ORGAN_SLOT_VAGINA)

/// "intersex", "cock", "vagina", or null when nothing in front is locked away.
/obj/item/clothing/undies/chastity/proc/get_front_anatomy()
	var/cock = cages_cock()
	var/pussy = seals_pussy()
	if(cock && pussy)
		return "intersex"
	if(cock)
		return "cock"
	if(pussy)
		return "vagina"
	return null

/// Church folk and godfearing followers of an approving god feel the device as devotion.
/obj/item/clothing/undies/chastity/proc/is_devout_wearer()
	if(!wearer)
		return FALSE
	if(wearer.mind?.assigned_role?.department_flag & CHAPEL)
		return TRUE
	return wearer.has_quirk(/datum/quirk/negative/addiction/godfearing) && patron_blesses_chastity(wearer.patron)

/obj/item/clothing/undies/chastity/proc/on_worn_sex_action(datum/sex_action_effect_context/context)
	if(!wearer || context.receiver != wearer || wearer.stat != CONSCIOUS)
		return
	if(!get_front_anatomy())
		return
	try_arousal_flavor(context)
	if(istype(context.action, /datum/sex_action/chastity))
		try_touch_flavor(context)
	else
		try_receive_flavor(context)

/obj/item/clothing/undies/chastity/proc/try_receive_flavor(datum/sex_action_effect_context/context)
	if(context.action_performer == wearer || !COOLDOWN_FINISHED(src, receive_flavor_cooldown))
		return FALSE
	if(!prob(10 + context.force * 5 + context.speed * 5))
		return FALSE
	var/key = "devout"
	if(!is_devout_wearer())
		key = "[get_front_anatomy()]_[is_anal_on_wearer(context.action, context) ? "anal" : "general"]"
	COOLDOWN_START(src, receive_flavor_cooldown, CHASTITY_RECEIVE_COOLDOWN)
	to_chat(wearer, span_love(pick_chastity_string("chastity_receive_flavor.json", key)))
	return TRUE

/// Lines for chastity play itself: the wearer's own hands, or a partner handling the device.
/obj/item/clothing/undies/chastity/proc/try_touch_flavor(datum/sex_action_effect_context/context)
	if(!COOLDOWN_FINISHED(src, receive_flavor_cooldown))
		return FALSE
	if(!prob(15 + context.force * 5 + context.speed * 5))
		return FALSE
	COOLDOWN_START(src, receive_flavor_cooldown, CHASTITY_RECEIVE_COOLDOWN)
	to_chat(wearer, span_love(pick_chastity_string("chastity_receive_flavor.json", get_touch_flavor_key(context.action_performer == wearer))))
	return TRUE

/obj/item/clothing/undies/chastity/proc/get_touch_flavor_key(self_touch)
	if(is_devout_wearer())
		return self_touch ? "self_devout" : "touched_devout"
	return "[get_front_anatomy()]_[self_touch ? "self" : "touched"]"

/obj/item/clothing/undies/chastity/proc/is_anal_on_wearer(datum/sex_action/action, datum/sex_action_effect_context/context)
	if(!action || action.hole_id != ORGAN_SLOT_ANUS)
		return FALSE
	return action.get_storage_receiver(context.action_initiator, context.action_target) == wearer

/obj/item/clothing/undies/chastity/proc/try_arousal_flavor(datum/sex_action_effect_context/context)
	if(context.arousal_amt <= 0 || !COOLDOWN_FINISHED(src, arousal_flavor_cooldown))
		return FALSE
	var/list/arousal_data = list()
	SEND_SIGNAL(wearer, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/key = get_arousal_flavor_key(arousal_data)
	if(!key)
		return FALSE
	var/chance = get_arousal_flavor_chance(arousal_data) + context.arousal_amt * 2 + context.force * 3 + context.speed * 3
	if(!prob(min(round(chance), 75)))
		return FALSE
	COOLDOWN_START(src, arousal_flavor_cooldown, CHASTITY_AROUSAL_COOLDOWN)
	to_chat(wearer, span_love(pick_chastity_string("chastity_arousal_messages.json", key)))
	return TRUE

/obj/item/clothing/undies/chastity/proc/get_arousal_flavor_key(list/arousal_data)
	if(seals_pussy() && holds_retained_seed())
		return "retention"
	var/anatomy = get_front_anatomy()
	if(!anatomy)
		return null
	if(is_devout_wearer())
		return "devout"
	if(anatomy != "cock")
		return anatomy
	var/obj/item/organ/genitals/penis/penis = wearer.getorganslot(ORGAN_SLOT_PENIS)
	if(penis?.organ_size >= MAX_PENIS_SIZE)
		return "large_cock"
	if(arousal_data["orgasm_progress"] >= CHASTITY_EDGE_PROGRESS)
		return "edge"
	if(arousal_data["arousal"] >= AROUSAL_EDGING_THRESHOLD)
		return "teasing"
	if(arousal_data["arousal"] >= VISIBLE_AROUSAL_THRESHOLD * 2)
		return "frustration"
	return "denial"

/obj/item/clothing/undies/chastity/proc/get_arousal_flavor_chance(list/arousal_data)
	if(seals_pussy())
		return holds_retained_seed() ? 28 : 18
	if(arousal_data["orgasm_progress"] >= CHASTITY_EDGE_PROGRESS)
		return 30
	if(arousal_data["arousal"] >= AROUSAL_EDGING_THRESHOLD)
		return 22
	if(arousal_data["arousal"] >= VISIBLE_AROUSAL_THRESHOLD * 2)
		return 16
	return 8

/// TRUE when a sealed pussy still holds someone's seed.
/obj/item/clothing/undies/chastity/proc/holds_retained_seed()
	var/obj/item/organ/genitals/filling_organ/vagina/pussy = get_real_organ(wearer, ORGAN_SLOT_VAGINA)
	if(!pussy?.reagents)
		return FALSE
	var/seed = 0
	for(var/datum/reagent/reagent as anything in pussy.reagents.reagent_list)
		if(istype(reagent, /datum/reagent/consumable/cum))
			seed += reagent.volume
	return seed >= CHASTITY_RETENTION_UNITS

/obj/item/clothing/undies/chastity/proc/on_wearer_moved(datum/source)
	SIGNAL_HANDLER
	if(++jingle_steps < CHASTITY_JINGLE_STEPS)
		return
	jingle_steps = 0
	var/chance = CHASTITY_JINGLE_CHANCE
	if(length(GLOB.clients) >= CHASTITY_JINGLE_HIGH_POP)
		chance = max(1, round(chance * 0.4))
	if(!prob(chance))
		return
	var/cover_tier = get_groin_cover_tier()
	playsound(wearer, SFX_JINGLE_BELLS, cover_tier < ARMOR_CLASS_NONE ? 40 : 20, TRUE, -2)
	if(wearer.stat != CONSCIOUS || !COOLDOWN_FINISHED(src, movement_flavor_cooldown))
		return
	COOLDOWN_START(src, movement_flavor_cooldown, CHASTITY_MOVEMENT_COOLDOWN)
	if(get_front_anatomy() && prob(45))
		wearer.visible_message(span_smallnotice("[wearer] [pick_chastity_string("chastity_movement_messages.json", "struggle")]"), vision_distance = 2)
		return
	wearer.visible_message(span_smallnotice("[wearer][pick_chastity_string("chastity_movement_messages.json", get_jingle_key(cover_tier))]"), vision_distance = 2)

/// Highest armour class worn over the groin besides this device; below ARMOR_CLASS_NONE means bare.
/obj/item/clothing/undies/chastity/proc/get_groin_cover_tier()
	. = ARMOR_CLASS_NONE - 1
	for(var/obj/item/clothing/worn in wearer?.get_equipped_items())
		if(worn == src || !zone2covered(BODY_ZONE_PRECISE_GROIN, worn.body_parts_covered))
			continue
		. = max(., worn.armor_class)

/obj/item/clothing/undies/chastity/proc/get_jingle_key(cover_tier)
	switch(cover_tier)
		if(AC_HEAVY)
			return "jingle_heavy"
		if(AC_MEDIUM)
			return "jingle_medium"
		if(AC_LIGHT)
			return "jingle_light"
		if(ARMOR_CLASS_NONE)
			return "jingle_cloth"
	return "jingle_bare"

/// A caged cock's climax dribbles out through the device onto the thighs; returns the units taken.
/obj/item/clothing/undies/chastity/proc/catch_climax(datum/sex_action_effect_context/context, datum/reagents/source_reagents, amount)
	if(!wearer || amount <= 0)
		return 0
	if(context.climaxer != wearer)
		note_partner_climax(context)
		return 0
	if(!cages_cock())
		return 0
	var/obj/item/organ/testicles = wearer.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testicles || source_reagents != testicles.reagents)
		return 0
	if(!context.climax_follow_up)
		wearer.visible_message(span_love("[wearer]'s release dribbles out through [wearer.p_their()] [name]."), span_love("My release dribbles uselessly out through \the [src]."))
	var/leftover = wearer.coat_with_fluid(FLUID_COAT_THIGHS, source_reagents, amount)
	if(leftover > 0)
		deposit_cum_on_turf(get_turf(wearer), source_reagents, leftover)
	return amount

/// Called when someone else climaxes with the wearer as the target.
/obj/item/clothing/undies/chastity/proc/note_partner_climax(datum/sex_action_effect_context/context)
	return

/obj/item/clothing/undies/chastity/arcane
	/// Partner climaxes the runes have counted on this wearer.
	var/tally_marks = 0
	/// The last partner counted, so one climax's spurts count once.
	var/datum/weakref/last_tally_ref
	var/last_tally_time = 0

/obj/item/clothing/undies/chastity/arcane/note_partner_climax(datum/sex_action_effect_context/context)
	if(context.partner != wearer || !context.climaxer)
		return
	if(last_tally_ref?.resolve() == context.climaxer && world.time < last_tally_time + CHASTITY_TALLY_WINDOW)
		return
	last_tally_ref = WEAKREF(context.climaxer)
	last_tally_time = world.time
	tally_marks++
	wearer.visible_message(span_notice("A faint scratch of metal: a new tally mark appears on [wearer]'s [name]."), span_notice("Something scratches at \the [src]. The runes have counted another."), vision_distance = 1)

#undef CHASTITY_JINGLE_STEPS
#undef CHASTITY_JINGLE_CHANCE
#undef CHASTITY_JINGLE_HIGH_POP
#undef CHASTITY_RECEIVE_COOLDOWN
#undef CHASTITY_AROUSAL_COOLDOWN
#undef CHASTITY_MOVEMENT_COOLDOWN
#undef CHASTITY_RETENTION_UNITS
#undef CHASTITY_EDGE_PROGRESS
#undef CHASTITY_TALLY_WINDOW
