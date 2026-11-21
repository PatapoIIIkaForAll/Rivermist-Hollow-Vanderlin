// The lap act every spider uses on a wet partner; a beespider turns what it laps into honey.

/// Units of fluid one lap takes.
#define SPIDER_LAP_UNITS 2
/// Nest production a honey-making spider gains per unit lapped.
#define SPIDER_LAP_PRODUCTION 10

/datum/sex_action/npc/npc_spider_lap
	name = "Lap"
	// One lap every 4 s at the middle speed.
	do_time = 6 SECONDS
	scene_interaction = SEX_SCENE_INTERACTION_ORAL
	scene_user_role = SEX_SCENE_ROLE_GIVER
	scene_user_slot = BODY_ZONE_PRECISE_MOUTH
	scene_target_role = SEX_SCENE_ROLE_RECEIVER
	scene_target_slot = ORGAN_SLOT_VAGINA
	/// The genital the spider laps: the vagina, or a cock with full balls behind it.
	var/lap_slot

/datum/sex_action/npc/npc_spider_lap/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_spider_lap/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target)
		return FALSE
	if(!user.adjacent_or_closet(target))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	// Only something wet is worth lapping.
	lap_slot = pick_lap_slot(target)
	return !!lap_slot

/datum/sex_action/npc/npc_spider_lap/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!. || !get_free_organ(target, lap_slot))
		return FALSE
	var/datum/reagents/fluid = get_lap_reagents(target, lap_slot)
	return fluid?.total_volume > 0

/datum/sex_action/npc/npc_spider_lap/get_scene_target_slot()
	return lap_slot || scene_target_slot

/// The target's wettest free genital, or null when none holds any fluid.
/datum/sex_action/npc/npc_spider_lap/proc/pick_lap_slot(mob/living/target)
	var/best_volume = 0
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_PENIS))
		if(!get_free_organ(target, slot) || check_sex_lock(target, slot))
			continue
		var/datum/reagents/fluid = get_lap_reagents(target, slot)
		if(fluid?.total_volume > best_volume)
			best_volume = fluid.total_volume
			. = slot

/// Where the fluid of a genital sits: the vagina itself, or the balls behind a cock.
/datum/sex_action/npc/npc_spider_lap/proc/get_lap_reagents(mob/living/target, slot)
	if(!slot)
		return null
	var/obj/item/organ/genitals/filling_organ/organ = target?.getorganslot(slot == ORGAN_SLOT_PENIS ? ORGAN_SLOT_TESTICLES : slot)
	return istype(organ) ? organ.reagents : null

/// The word for what the spider laps: the cock word, or the vagina's own opening name.
/datum/sex_action/npc/npc_spider_lap/proc/get_lap_part(mob/living/target)
	if(lap_slot == ORGAN_SLOT_PENIS)
		return get_penis_word(target)
	var/obj/item/organ/genitals/filling_organ/vagina = target?.getorganslot(ORGAN_SLOT_VAGINA)
	var/datum/orifice/orifice = (istype(vagina) && vagina.orifice_type) ? vagina.get_orifice(FALSE) : null
	return orifice?.opening_name || "pussy"

/datum/sex_action/npc/npc_spider_lap/on_start(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_start_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_spider_lap/compose_start_lines(mob/living/user, mob/living/target)
	var/part = get_lap_part(target)
	return act_lines(
		"[user] puts its mouth to [target]'s [part] and starts to lap.",
		"[user] puts its mouth to my [part] and starts to lap.",
		get_lap_hear(user, target)
	)

/datum/sex_action/npc/npc_spider_lap/on_perform(mob/living/user, mob/living/target)
	. = ..()
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	user.make_mouth_noise("lick")
	lap_fluid(user, target)
	perform_sex_action(target, user, 1.5, 0, 1)
	perform_sex_action(user, target, 0.5, 0, 0.5)
	handle_passive_ejaculation()

/// Takes one lap of fluid; a honey-making spider turns it into nest production. Returns the units taken.
/datum/sex_action/npc/npc_spider_lap/proc/lap_fluid(mob/living/user, mob/living/target)
	var/datum/reagents/fluid = get_lap_reagents(target, lap_slot)
	if(!fluid?.total_volume)
		return 0
	var/taken = min(SPIDER_LAP_UNITS, fluid.total_volume)
	fluid.remove_all(taken)
	var/mob/living/simple_animal/hostile/retaliate/spider/bee = user
	if(istype(bee) && bee.makes_honey)
		bee.production += taken * SPIDER_LAP_PRODUCTION
	return taken

/datum/sex_action/npc/npc_spider_lap/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/part = get_lap_part(target)
	var/hear = get_lap_hear(user, target)
	switch(stage)
		if("opening")
			return act_lines("[user] laps slowly at [target]'s [part].", "[user] laps slowly at my [part].", hear)
		if("late")
			return act_lines("[user] laps faster at [target]'s [part].", "[user] laps faster at my [part].", hear)
	var/adverb = get_generic_force_adjective()
	var/datum/reagents/fluid = get_lap_reagents(target, lap_slot)
	switch(variant)
		if(1)
			if(fluid?.has_reagent(/datum/reagent/consumable/honey))
				return act_lines("[user] licks honey from [target]'s [part].", "[user] licks honey from my [part].", hear)
			return act_lines("[user] [adverb] laps the wetness from [target]'s [part].", "[user] laps the wetness from my [part].", hear)
		if(2)
			return act_lines("[user] flicks its tongue over [target]'s [part].", "[user] flicks its tongue over my [part].", hear)
	return act_lines("[user] slurps at [target]'s [part].", "[user] slurps at my [part].", hear)

/datum/sex_action/npc/npc_spider_lap/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		var/victim_part = get_lap_part(climaxer)
		return act_lines("[climaxer]'s [victim_part] gushes over [partner]'s tongue!", "I shake as my [victim_part] gushes over [partner]'s tongue!", get_lap_hear(partner, climaxer))
	var/part = get_lap_part(partner)
	return act_lines("[climaxer] spills on the floor with its mouth on [partner]'s [part].", "[climaxer] spills on the floor with its mouth on my [part].", get_lap_hear(climaxer, partner))

/datum/sex_action/npc/npc_spider_lap/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	return null

/datum/sex_action/npc/npc_spider_lap/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_spider_lap/compose_finish_lines(mob/living/user, mob/living/target)
	var/part = get_lap_part(target)
	return act_lines("[user] lifts its mouth from [target]'s [part].", "[user] lifts its mouth from my [part].", get_lap_hear(user, target))

/// "I hear ..." for lapping, with the family's own sound.
/datum/sex_action/npc/npc_spider_lap/proc/get_lap_hear(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	return "I hear wet lapping and [words["hear"]]."

/datum/sex_action/npc/npc_spider_lap/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH, null, FALSE)
	if(lap_slot)
		add_sex_lock(target, lap_slot, null, FALSE)

#undef SPIDER_LAP_UNITS
#undef SPIDER_LAP_PRODUCTION
