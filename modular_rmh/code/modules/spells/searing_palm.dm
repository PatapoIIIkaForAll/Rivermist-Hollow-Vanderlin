// RMH - Searing Palm: a fire touch spell granting a hand with two intents.
// Brand intent burns a permanent mark and puts the spell on cooldown.
// Slap intent deals light burn damage and leaves a temporary handprint,
// and never consumes the hand or starts the cooldown.

#define SEARING_BRAND	/datum/intent/searing_palm/brand
#define SEARING_SLAP	/datum/intent/searing_palm/slap

/datum/action/cooldown/spell/undirected/touch/searing_palm
	name = "Searing Palm"
	desc = "Wreathe your hand in clinging flame, able to sear a permanent mark into flesh or leave a burning print with a slap."
	button_icon_state = "fireball_greater"
	sound = 'sound/magic/fireball.ogg'

	point_cost = 3
	school = SCHOOL_EVOCATION
	attunements = list(
		/datum/attunement/fire = 0.8,
	)

	cooldown_time = 10 MINUTES
	spell_cost = 100
	infinite_use = TRUE

	hand_path = /obj/item/melee/touch_attack/searing_palm
	draw_message = span_warning("Flame crawls across my palm and clings there.")
	drop_message = span_notice("The flame on my palm gutters out.")

	invocation = "IGNIS SIGILLUM!"
	invocation_type = INVOCATION_SHOUT

	var/slap_cooldown = 5 SECONDS
	var/next_slap = 0
	var/slap_damage = 5
	var/handprint_duration = 3 MINUTES
	var/max_brand_length = 20
	/// TRUE while a branding prompt or do_after is outstanding. Branding sleeps
	/// twice and spends the spell at the end, so a second attempt started in the
	/// meantime could land after the hand and its cooldown were already used.
	var/branding_in_progress = FALSE

/datum/action/cooldown/spell/undirected/touch/searing_palm/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/undirected/touch/searing_palm/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster, list/modifiers)
	var/mob/living/carbon/patient = victim
	if(!istype(patient))
		return FALSE

	switch(caster.used_intent.type)
		if(SEARING_BRAND)
			return try_brand(hand, patient, caster)
		if(SEARING_SLAP)
			return try_slap(patient, caster)
	return FALSE

/**
 * Is this still the same live flaming hand the branding started from?
 *
 * The text prompt and the do_after both sleep, so the hand can be dropped,
 * swapped out, deleted or re-cast while a branding attempt is outstanding.
 * Anything that lands afterwards has to come from the original hand, still
 * held by the original caster, still owned by this spell.
 */
/datum/action/cooldown/spell/undirected/touch/searing_palm/proc/hand_still_ready(obj/item/melee/touch_attack/hand, mob/living/carbon/caster)
	if(QDELETED(hand) || QDELETED(caster))
		return FALSE
	if(owner != caster || hand != attached_hand)
		return FALSE
	return (hand in caster.held_items)

/// Serializes branding attempts so only one can be outstanding at a time. The
/// flag is owned here, so do_brand() is free to return from anywhere.
/datum/action/cooldown/spell/undirected/touch/searing_palm/proc/try_brand(obj/item/melee/touch_attack/hand, mob/living/carbon/patient, mob/living/carbon/caster)
	if(branding_in_progress)
		to_chat(caster, span_warning("I am already searing a sigil."))
		return FALSE
	if(!hand_still_ready(hand, caster))
		return FALSE

	branding_in_progress = TRUE
	. = do_brand(hand, patient, caster)
	branding_in_progress = FALSE

/datum/action/cooldown/spell/undirected/touch/searing_palm/proc/do_brand(obj/item/melee/touch_attack/hand, mob/living/carbon/patient, mob/living/carbon/caster)
	if(!ishuman(patient))
		to_chat(caster, span_warning("The sigil finds no purchase on [patient]."))
		return FALSE
	var/mob/living/carbon/human/human_patient = patient
	if(!is_held_still(patient, caster))
		to_chat(caster, span_warning("[patient] would need to be restrained or helpless to hold still for this."))
		return FALSE

	var/brand_zone = human_patient.pick_brand_zone(caster, caster.zone_selected)
	if(!brand_zone || !hand_still_ready(hand, caster))
		return FALSE

	var/brand_kind = tgui_alert(caster, "Burn a plain brand, or a glowing arcane sigil?", "Searing Palm", list("Plain brand", "Arcane sigil"))
	if(!brand_kind || !hand_still_ready(hand, caster))
		return FALSE
	var/arcane = brand_kind == "Arcane sigil"

	// max_length is deliberately not passed: stripped_input trims with copytext,
	// which cuts by bytes and halves Cyrillic input. Clamp by character instead.
	var/chosen_text = stripped_input(caster, "Что выжечь на [tattoo_zone_name(brand_zone)]? (максимум [max_brand_length] символов)", "Клеймо", "")
	if(!chosen_text)
		return FALSE
	chosen_text = trimtext(copytext_char(chosen_text, 1, max_brand_length + 1))
	if(!length(chosen_text) || QDELETED(patient) || !hand_still_ready(hand, caster))
		return FALSE

	var/zone_name = tattoo_zone_name(brand_zone)
	patient.visible_message(span_danger("[caster] presses a burning palm against [patient]'s [zone_name]!"), \
		span_userdanger("[caster] presses a burning palm against your [zone_name]!"))
	playsound(patient, 'sound/foley/burning_sacrifice.ogg', 50, TRUE)

	if(!do_after(caster, 4 SECONDS, patient))
		return FALSE
	// Re-check everything: do_after only watches the caster's own position, so the
	// victim can break free, walk off or pull armour on while the prompt is open.
	if(QDELETED(patient))
		return FALSE
	if(!hand_still_ready(hand, caster))
		to_chat(caster, span_warning("The flame is no longer on my palm."))
		return FALSE
	if(!caster.Adjacent(patient) || !is_held_still(patient, caster))
		to_chat(caster, span_warning("The branding is interrupted."))
		return FALSE
	var/problem = human_patient.brand_zone_problem(brand_zone, caster)
	if(problem)
		to_chat(caster, span_warning(problem))
		return FALSE
	if(!human_patient.add_skin_brand(brand_zone, chosen_text, arcane))
		return FALSE

	patient.apply_damage(10, BURN, tattoo_zone_limb(brand_zone))
	if(arcane)
		patient.visible_message(span_danger("An amber sigil flares on [patient]'s [zone_name] and settles into a steady glow!"), \
			span_userdanger("The sigil bites into your [zone_name] and keeps glowing. Only cleansing magic will lift it."))
	else
		patient.visible_message(span_danger("[patient]'s [zone_name] sizzles as the sigil bites in!"), \
			span_userdanger("The sigil bites into your [zone_name]. It will stay with you forever."))

	remove_hand(caster)
	return TRUE

/datum/action/cooldown/spell/undirected/touch/searing_palm/proc/try_slap(mob/living/carbon/patient, mob/living/carbon/caster)
	if(world.time < next_slap)
		to_chat(caster, span_warning("The flame on my palm has not gathered again yet."))
		return FALSE
	next_slap = world.time + slap_cooldown

	var/target_zone = caster.zone_selected
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(target_zone))
	if(!limb)
		return FALSE
	if(!get_location_accessible(patient, target_zone))
		to_chat(caster, span_warning("The clothing is in the way - the flame finds no skin."))
		return FALSE

	patient.visible_message(span_danger("[caster] slaps [patient] across the [parse_zone(target_zone)] with a burning hand!"), \
		span_userdanger("[caster] slaps your [parse_zone(target_zone)] with a burning hand!"))
	playsound(patient, 'sound/foley/slap.ogg', 60, TRUE)
	patient.apply_damage(slap_damage, BURN, limb.body_zone)

	// Only one print at a time; the zone is already known to be bare.
	for(var/obj/item/bodypart/other as anything in patient.bodyparts)
		other.handprint_zone = null
	limb.set_handprint(target_zone, handprint_duration)

	return TRUE

/obj/item/melee/touch_attack/searing_palm
	name = "\improper searing palm"
	desc = "Your hand is wreathed in clinging flame.\n \
	<b>Brand</b>: Sear a permanent mark into a helpless target. Spends the spell.\n \
	<b>Slap</b>: Strike with the open flame, leaving a burning print for a few minutes."
	color = "#FF7B24"
	possible_item_intents = list(SEARING_BRAND, SEARING_SLAP)

/datum/intent/searing_palm
	reach = 1
	noaa = TRUE
	misscost = 0
	releasedrain = 0
	candodge = TRUE
	canparry = TRUE

/datum/intent/searing_palm/brand
	name = "brand"
	icon_state = "inuse"

/datum/intent/searing_palm/slap
	name = "slap"
	icon_state = "intouch"

/datum/spell_node/searing_palm
	name = "Searing Palm"
	desc = "Wreathe your hand in flame to brand flesh or leave a burning print."
	cost = 3
	node_x = RIGHT_X_TIER_1
	node_y = RIGHT_Y_RIGHT + 50
	prerequisites = list(/datum/spell_node/fire_affinity)
	spell_type = /datum/action/cooldown/spell/undirected/touch/searing_palm

#undef SEARING_BRAND
#undef SEARING_SLAP
