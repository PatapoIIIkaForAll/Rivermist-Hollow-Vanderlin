/mob/living/proc/get_highest_grab_state_on(mob/living/victim)
	var/grabstate = null
	if(r_grab && r_grab.grabbed == victim)
		if(grabstate == null || r_grab.grab_state > grabstate)
			grabstate = r_grab.grab_state
	if(l_grab && l_grab.grabbed == victim)
		if(grabstate == null || l_grab.grab_state > grabstate)
			grabstate = l_grab.grab_state
	return grabstate

/mob/living/proc/get_effective_grab_state_on(mob/living/victim)
	var/grabstate = get_highest_grab_state_on(victim)
	if(pulling != victim && victim?.pulledby != src)
		return grabstate
	if(isnull(grabstate))
		return grab_state
	return max(grabstate, grab_state)

// pixels and time are ignored; force sets the reach and speed the pumps (modular_rmh/code/modules/mob/sex_motion.dm).
/datum/sex_action/proc/do_thrust_animate(atom/movable/user, atom/movable/target, pixels = 4, time = 2.7)
	if(!user || !target || user == target)
		return
	var/reach = get_thrust_reach()
	var/list/step = get_sex_motion_step(user, target)
	if(motion_vertical)
		step = list(0, 1)
	else if(isliving(target) && isliving(user) && user.loc == target.loc)
		var/mob/living/living_target = target
		var/mob/living/living_user = user
		// A partner lying on the user's tile is pressed down.
		if(living_target.body_position == LYING_DOWN && living_user.body_position != LYING_DOWN)
			step = list(0, -1)
	var/pumps = get_motion_pumps()
	var/list/timing = get_motion_steps(pumps)
	sex_motion_nudge(user, step[1] * reach, step[2] * reach, timing[1], timing[2], timing[3], pumps)
	// Hard thrusts push the partner along; riding does not.
	var/recoil = GLOB.sex_motion_recoil[get_motion_force_index()]
	if(recoil && !motion_vertical)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sex_motion_nudge), target, step[1] * recoil, step[2] * recoil, 0.08 SECONDS, timing[2]), timing[1])

/mob/living/proc/open_sex_scene(mob/living/target, show_ui = TRUE)
	if(!target)
		return
	if(QDELETED(src) || QDELETED(target))
		return
	if(stat == DEAD || target.stat == DEAD)
		return
	if(src != target && !target.allows_player_erp_while_disconnected())
		return
	if(!GetComponent(/datum/component/arousal))
		AddComponent(/datum/component/arousal)
	if(!target.GetComponent(/datum/component/arousal))
		target.AddComponent(/datum/component/arousal)
	var/datum/sex_scene/shared_scene = get_or_create_sex_scene(src, target)
	if(!shared_scene)
		return
	var/datum/sex_scene_controller/existing_controller = shared_scene.get_controller(src)
	if(existing_controller && !QDELETED(existing_controller))
		existing_controller.set_target(target)
		if(show_ui)
			existing_controller.show_ui()
		return existing_controller

	var/datum/sex_scene_controller/controller = new(src, target)
	if(!controller.scene)
		qdel(controller)
		return
	if(target.client && client && show_ui)
		controller.show_ui()
	return controller

/// Player-facing reason open_sex_scene() refused this pair. Mirrors its checks in the same order.
/mob/living/proc/get_sex_scene_refusal(mob/living/target)
	if(!target || QDELETED(target) || target.stat == DEAD)
		return "[target || "They"] can't take part right now."
	if(src != target && !target.allows_player_erp_while_disconnected())
		return "[target] is away and does not allow this while disconnected."
	var/list/combined_participants = list(src, target)
	if(sex_scene && !QDELETED(sex_scene))
		combined_participants |= sex_scene.participants
	if(target.sex_scene && !QDELETED(target.sex_scene))
		combined_participants |= target.sex_scene.participants
	if(length(combined_participants) > SEX_SCENE_MAX_PARTICIPANTS)
		return "That would put more than [SEX_SCENE_MAX_PARTICIPANTS] people in one scene."
	return "I can't start a scene with [target]."

/// The plain suck; the act-specific mouths live in make_mouth_noise().
/mob/living/proc/make_sucking_noise()
	make_mouth_noise("suck")

/mob/living/proc/can_do_sex()
	return TRUE

/mob/living/MiddleMouseDrop_T(atom/movable/dragged, mob/living/user)
	var/mob/living/target = src

	if(user.mmb_intent)
		return ..()
	if(!istype(dragged))
		return
	// Hiding under a table (or sitting in a closet) puts you inside it, so your own sprite isn't on
	// screen to drag - the container is. Dragging what you are inside counts as dragging yourself.
	if(dragged != user && dragged == user.loc)
		dragged = user
	// Need to drag yourself to the target.
	if(dragged != user)
		return
	if(!user.can_do_sex())
		to_chat(user, "<span class='warning'>I can't do this.</span>")
		return

	if(!user.open_sex_scene(target))
		to_chat(user, span_warning(user.get_sex_scene_refusal(target)))
		return

/mob/living/proc/has_hands()
	return TRUE

/mob/living/proc/has_free_sex_hands()
	return has_hands() && !HAS_TRAIT(src, TRAIT_HANDS_BLOCKED)

/mob/living/proc/has_mouth()
	return TRUE

/mob/living/proc/has_penis()
	return getorganslot(ORGAN_SLOT_PENIS) || gender == MALE

/// Like has_penis(), but a worn strapon does not count.
/mob/living/proc/has_real_penis()
	var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
	if(penis?.is_false_organ())
		return FALSE
	return has_penis()

/mob/living/proc/has_testicles()
	return getorganslot(ORGAN_SLOT_TESTICLES) || gender == MALE

/mob/living/proc/has_vagina()
	return getorganslot(ORGAN_SLOT_VAGINA) || gender == FEMALE

/mob/living/proc/has_breasts()
	return getorganslot(ORGAN_SLOT_BREASTS) || gender == FEMALE

/mob/living/proc/has_belly()
	RETURN_TYPE(/obj/item/organ/genitals/belly)
	return getorganslot(ORGAN_SLOT_BELLY)

/mob/living/proc/has_butt()
	RETURN_TYPE(/obj/item/organ/genitals/butt)
	return getorganslot(ORGAN_SLOT_BUTT)

/mob/living/proc/is_fertile()
	var/obj/item/organ/genitals/filling_organ/womb/womb = get_womb()
	return womb?.fertility

/mob/living/proc/is_virile()
	var/obj/item/organ/genitals/filling_organ/testicles/testicles = getorganslot(ORGAN_SLOT_TESTICLES)
	return testicles?.virility

/mob/living/carbon/human/has_penis()
	return getorganslot(ORGAN_SLOT_PENIS)

/mob/living/carbon/human/has_testicles()
	return getorganslot(ORGAN_SLOT_TESTICLES)

/mob/living/carbon/human/has_vagina()
	return getorganslot(ORGAN_SLOT_VAGINA)

/mob/living/carbon/human/has_breasts()
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ/breasts)
	return getorganslot(ORGAN_SLOT_BREASTS)

/// Gags over the mouth, grabs and mouth items stop it; cloth only with cloth_blocks; armor unless [actor] may reach under.
/mob/living/proc/mouth_is_free(mob/living/actor, cloth_blocks = FALSE, ignore_armor = FALSE)
	if(!has_mouth() || mouth_blocked)
		return FALSE
	if(iscarbon(src))
		var/mob/living/carbon/carbon_self = src
		if(carbon_self.mouth?.muteinmouth)
			return FALSE
	for(var/obj/item/clothing/worn in get_equipped_items())
		// A gag that leaves the mouth open, like a ring gag, only muffles speech.
		if((worn.clothing_flags & BLOCKS_SPEECH) && (cloth_blocks || (worn.flags_cover & (HEADCOVERSMOUTH|MASKCOVERSMOUTH))))
			return FALSE
	var/obj/item/clothing/cover = is_mouth_covered()
	if(!cover)
		return TRUE
	if(cloth_blocks || !istype(cover))
		return FALSE
	var/list/covers = list(cover)
	for(var/obj/item/clothing/worn in get_equipped_items())
		if(worn.flags_cover & (HEADCOVERSMOUTH|MASKCOVERSMOUTH))
			covers |= worn
	for(var/obj/item/clothing/worn as anything in covers)
		if(worn.blocks_sex_reach())
			return ignore_armor || allows_reach_under_armor(actor)
	return TRUE

/mob/living/proc/get_worn_choker()
	return null

/mob/living/carbon/get_worn_choker()
	if(istype(choker, /obj/item/clothing/choker))
		return choker
	if(istype(wear_neck, /obj/item/clothing/choker))
		return wear_neck
	return null

/mob/living/proc/snap_worn_choker(mob/living/puller)
	var/obj/item/clothing/choker/worn_choker = get_worn_choker()
	if(!worn_choker)
		return FALSE

	if(worn_choker.loc == src)
		dropItemToGround(worn_choker, TRUE, TRUE)

	if(worn_choker.break_sound)
		playsound(src, 'modular_rmh/sound/effects/snap.ogg', 30, TRUE, -1)

	visible_message(
		span_warning("[puller ? "[puller] thrusts hard enough to snap [src]'s [worn_choker.name]!" : "[src]'s [worn_choker.name] snaps!"]"),
		span_warning("[puller ? "[puller] thrusts hard enough to snap my [worn_choker.name]!" : "My [worn_choker.name] snaps!"]")
	)

	worn_choker.atom_break()

	return TRUE

/mob/living/proc/foot_is_free()
	return is_barefoot()

/mob/living/proc/is_barefoot()
	for(var/item_slot in DEFAULT_SLOT_PRIORITY)
		var/obj/item/clothing = get_item_by_slot(item_slot)
		if(!clothing) // Don't have this slot or not wearing anything in it
			continue
		if(clothing.body_parts_covered & FEET)
			return FALSE
	// If didn't stop before, then we're barefoot
	return TRUE

/mob/living/carbon/human/has_mouth()
	return get_bodypart(BODY_ZONE_HEAD) || get_detached_dullahan_head(src)

/mob/living/carbon/human/has_hands() // technically should be an and but i'll replicate original behavior
	return get_bodypart(BODY_ZONE_L_ARM) || get_bodypart(BODY_ZONE_R_ARM)

/mob/living/proc/get_character_information_line(summary_text)
	if(!length("[summary_text]"))
		return null
	summary_text = "[summary_text]"
	var/last_character = copytext(summary_text, length(summary_text), length(summary_text) + 1)
	if(!(last_character in list(".", "!", "?")))
		summary_text += "."
	// Plain text: the scene window renders these as its own list rows.
	return summary_text

/mob/living/proc/get_general_sex_state_summary()
	var/datum/component/arousal/arousal_component = GetComponent(/datum/component/arousal)
	if(!arousal_component)
		return null

	var/list/arousal_data = list()
	SEND_SIGNAL(src, COMSIG_SEX_GET_AROUSAL, arousal_data)

	var/current_arousal = arousal_data["arousal"] || 0
	var/current_orgasm_progress = arousal_data["orgasm_progress"] || 0
	var/state_summary = "feel calm"

	switch(current_arousal)
		if(1 to 19)
			state_summary = "feel a little worked up"
		if(20 to 49)
			state_summary = "feel lightly aroused"
		if(50 to 79)
			state_summary = "feel hot and needy"
		if(80 to INFINITY)
			state_summary = "feel desperately aroused"

	if(arousal_component.is_spent())
		state_summary += ", but spent from recent release"

	if(current_orgasm_progress >= PASSIVE_EJAC_THRESHOLD)
		state_summary += " and right on the brink"
	else if(current_orgasm_progress >= PASSIVE_EJAC_THRESHOLD * 0.7)
		state_summary += " and close to climax"

	return "[state_summary]."

/// Status lines for the panel; examine_rule FALSE uses the older coverage and underwear rule.
/mob/living/proc/return_character_information(examine_rule = TRUE)
	var/list/data = list()
	if(has_hands())
		data += get_character_information_line("have hands, which are [has_free_sex_hands() ? "free" : "blocked"]")
	if(has_mouth())
		data += get_character_information_line("have a mouth, which is [mouth_is_free(cloth_blocks = TRUE) ? "uncovered" : "covered"]")
	var/general_state_summary = get_general_sex_state_summary()
	if(general_state_summary)
		data += get_character_information_line(general_state_summary)
	return data

/// A groin line by examine's rule, or by body coverage and underwear when examine_rule is FALSE.
/mob/living/carbon/human/proc/get_visible_groin_summary_description(descriptor_type, examine_rule = TRUE)
	var/datum/mob_descriptor/descriptor = new descriptor_type()
	if(examine_rule ? !descriptor.can_describe(src) : !get_location_accessible(src, BODY_ZONE_PRECISE_GROIN, skipundies = FALSE))
		return null
	return descriptor.get_description(src)

/// A chest line by examine's rule, or by body coverage and breast-covering underwear when examine_rule is FALSE.
/mob/living/carbon/human/proc/get_visible_chest_summary_description(descriptor_type, examine_rule = TRUE)
	var/datum/mob_descriptor/descriptor = new descriptor_type()
	if(examine_rule ? !descriptor.can_describe(src) : (!get_location_accessible(src, BODY_ZONE_CHEST) || underwear?.covers_breasts))
		return null
	return descriptor.get_description(src)

/mob/living/carbon/human/proc/get_visible_anus_summary(examine_rule = TRUE)
	var/obj/item/organ/genitals/filling_organ/anus/anus = getorganslot(ORGAN_SLOT_ANUS)
	if(!anus)
		return null
	// Examine's rule takes the butt and crotch hide flags together.
	if(examine_rule ? !is_genital_exposed(anus, HIDEBUTT|HIDEUNDIESBOT|HIDECROTCH) : !get_location_accessible(src, BODY_ZONE_PRECISE_GROIN, skipundies = FALSE))
		return null
	var/list/adjectives = anus.orifice?.get_examine_adjectives()
	if(length(adjectives))
		return "have an exposed anus, [jointext(adjectives, ", ")]."
	return "have an exposed anus."

/mob/living/carbon/human/return_character_information(examine_rule = TRUE)
	var/list/data = ..()
	if(!data)
		data = list()

	var/breasts_summary = get_visible_chest_summary_description(/datum/mob_descriptor/breasts, examine_rule)
	if(breasts_summary)
		data += get_character_information_line("have [breasts_summary]")

	var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
	var/penis_summary = get_visible_groin_summary_description(/datum/mob_descriptor/penis, examine_rule)
	if(penis_summary)
		data += get_character_information_line("have [penis_summary]")

	var/testicles_summary = null
	if(!penis || penis.sheath_type != SHEATH_TYPE_SLIT)
		testicles_summary = get_visible_groin_summary_description(/datum/mob_descriptor/testicles, examine_rule)
	if(testicles_summary)
		data += get_character_information_line("have [testicles_summary]")

	var/vagina_summary = get_visible_groin_summary_description(/datum/mob_descriptor/vagina, examine_rule)
	if(vagina_summary)
		data += get_character_information_line("have [vagina_summary]")

	var/butt_summary = get_visible_groin_summary_description(/datum/mob_descriptor/butt, examine_rule)
	if(butt_summary)
		data += get_character_information_line("have [butt_summary]")

	var/anus_summary = get_visible_anus_summary(examine_rule)
	if(anus_summary)
		data += get_character_information_line(anus_summary)

	data += get_orifice_status_lines()

	return data

/mob/living/proc/get_active_precise_hand()
	var/active_hand = BODY_ZONE_PRECISE_L_HAND
	if(active_hand_index != 1)
		active_hand = BODY_ZONE_PRECISE_R_HAND
	return active_hand

/mob/living/proc/get_inactive_precise_hand()
	if(get_active_precise_hand() == BODY_ZONE_PRECISE_L_HAND)
		return BODY_ZONE_PRECISE_R_HAND
	return BODY_ZONE_PRECISE_L_HAND

/mob/proc/check_handholding()
	return

/mob/living/carbon/human/check_handholding()
	if(pulledby && pulledby != src)
		var/obj/item/bodypart/LH
		var/obj/item/bodypart/RH
		LH = get_bodypart(BODY_ZONE_PRECISE_L_HAND)
		RH = get_bodypart(BODY_ZONE_PRECISE_R_HAND)
		if(LH || RH)
			for(var/obj/item/grabbing/G in src.grabbedby)
				if(G.limb_grabbed == LH || G.limb_grabbed == RH)
					return TRUE

/// TRUE when a worn device, such as a fluid pump, covers the organ in this slot.
/mob/living/proc/is_organ_slot_blocked(slot)
	var/obj/item/organ/organ = getorganslot(slot)
	if(!organ)
		return FALSE
	for(var/obj/item/device in organ.contents)
		if(device.blocks_organ_use(slot))
			return TRUE
	return FALSE

/// Worn underwear, such as a chastity device, can also cover organs.
/mob/living/carbon/is_organ_slot_blocked(slot)
	if(..())
		return TRUE
	if(!underwear || !getorganslot(slot))
		return FALSE
	return underwear.blocks_organ_use(slot)

/// TRUE for worn stand-ins, such as a strapon cock or a plug's false tail.
/obj/item/organ/proc/is_false_organ()
	return FALSE

/obj/item/organ/genitals/penis/is_false_organ()
	return strapon

/// The organ in [slot] on [owner], or null when missing or only a worn stand-in.
/proc/get_real_organ(mob/living/owner, slot)
	var/obj/item/organ/organ = owner?.getorganslot(slot)
	return organ?.is_false_organ() ? null : organ

/mob/proc/get_erp_pref(pref_type)
	if(!ispath(pref_type, /datum/erp_preference))
		return FALSE

	if(isliving(src))
		var/mob/living/living_mob = src
		return living_mob.get_cached_erp_pref(pref_type)

	if(!client?.prefs)
		return FALSE

	var/datum/erp_preference/pref = new pref_type()
	return pref.get_value(client.prefs)

/mob/proc/set_erp_pref(pref_type, value)
	if(!client?.prefs)
		return FALSE

	if(!ispath(pref_type, /datum/erp_preference))
		return FALSE

	var/datum/erp_preference/pref = new pref_type()
	pref.set_value(client.prefs, value)
	client.prefs.save_preferences()
	return TRUE

/mob/proc/has_erp_pref(pref_type)
	return get_erp_pref(pref_type) == TRUE

/proc/should_apply_mob_erp_target_pref(mob/living/actor, mob/living/target)
	if(!isliving(actor) || !isliving(target))
		return FALSE
	if(actor.client)
		return FALSE
	if(target.client || target.mind?.key || target.mind?.cached_erp_preferences || target.cached_erp_preferences)
		return TRUE
	return FALSE

/proc/target_allows_mob_erp_action(mob/living/actor, mob/living/target, pref_type)
	if(!ispath(pref_type, /datum/erp_preference))
		return TRUE
	if(!should_apply_mob_erp_target_pref(actor, target))
		return TRUE
	return target.get_cached_erp_pref(pref_type)

/mob/proc/get_all_erp_prefs()
	if(!client?.prefs)
		return list()

	var/list/prefs_by_category = list()

	for(var/pref_type in subtypesof(/datum/erp_preference))
		var/datum/erp_preference/pref = new pref_type()
		var/category = pref.category
		var/value = pref.get_value(client.prefs)

		if(!prefs_by_category[category])
			prefs_by_category[category] = list()

		prefs_by_category[category][pref_type] = list(
			"name" = pref.name,
			"description" = pref.description,
			"value" = value,
			"pref_object" = pref
		)

	return prefs_by_category

/proc/any_has_erp_pref(list/mobs, pref_type)
	for(var/mob/M in mobs)
		if(M.has_erp_pref(pref_type))
			return TRUE
	return FALSE

/proc/all_have_erp_pref(list/mobs, pref_type)
	for(var/mob/M in mobs)
		if(!M.has_erp_pref(pref_type))
			return FALSE
	return TRUE

/mob/living/proc/has_kink(kink_name)
	refresh_erp_preference_cache()
	var/list/kink_prefs = cached_erp_preferences?["kinks"]
	if(!kink_prefs || !kink_prefs[kink_name])
		return FALSE
	return kink_prefs[kink_name]["enabled"]

/mob/living/proc/is_disconnected_player_erp_body()
	if(client)
		return FALSE
	if(!mind)
		return FALSE
	return !!(mind.key || mind.cached_erp_preferences || cached_erp_preferences)

/mob/living/proc/allows_player_erp_while_disconnected()
	if(!is_disconnected_player_erp_body())
		return TRUE
	return get_cached_erp_pref(/datum/erp_preference/boolean/allow_player_erp_when_disconnected) == TRUE

/datum/mind
	var/tmp/list/cached_erp_preferences
	var/tmp/cached_erp_preferences_revision = -1

/datum/mind/proc/cache_erp_preferences_from_prefs(datum/preferences/prefs)
	if(!prefs)
		return FALSE
	var/list/erp_preferences = prefs.read_preference(/datum/preference/list_type/erp_preferences)
	if(!length(erp_preferences))
		return FALSE
	set_cached_erp_preferences(erp_preferences, prefs.erp_preferences_revision)
	return TRUE

/datum/mind/proc/set_cached_erp_preferences(list/preferences, revision = -1)
	cached_erp_preferences = islist(preferences) ? deep_copy_list_alt(preferences) : null
	cached_erp_preferences_revision = revision
	if(isliving(current))
		var/mob/living/current_living = current
		current_living.set_cached_erp_preferences(cached_erp_preferences, cached_erp_preferences_revision)

/mob/living
	var/list/attached_sex_toys = list()
	var/tmp/list/cached_erp_preferences
	var/tmp/erp_preferences_revision_seen = -1
	var/tmp/cached_horny_mob_pref_flags = NONE
	var/tmp/cached_horny_mob_family_flags = NONE
	var/tmp/cached_allow_belly_inflation = null
	var/tmp/cached_nonmatching_horny_mobs_are_nonlethal = null

	///npc organs to use
	var/ball_organ = /obj/item/organ/genitals/filling_organ/testicles
	var/ball_min = MIN_TESTICLES_SIZE
	var/ball_max = MAX_TESTICLES_SIZE
	var/breast_organ = /obj/item/organ/genitals/filling_organ/breasts
	var/breast_min = MIN_BREASTS_SIZE
	var/breast_max = MAX_BREASTS_SIZE
	var/ass_organ = /obj/item/organ/genitals/butt
	var/ass_min = MIN_BUTT_SIZE
	var/ass_max = MAX_BUTT_SIZE
	var/penis_organ = /obj/item/organ/genitals/penis
	var/penis_min = MIN_PENIS_SIZE
	var/penis_max = MAX_PENIS_SIZE
	var/butt_organ = /obj/item/organ/genitals/butt
	var/butt_min = MIN_BUTT_SIZE
	var/butt_max = MAX_BUTT_SIZE
	var/vagina_organ = /obj/item/organ/genitals/filling_organ/vagina
	var/show_genitals = FALSE
	var/mouth_blocked = FALSE

	COOLDOWN_DECLARE(npc_sneak_detect_cd)

/datum/component/gender_potion_genital_backup
	var/original_gender
	var/list/stored_organs = list()
	var/list/stored_zones = list()

/datum/component/gender_potion_genital_backup/Initialize(original_gender)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.original_gender = original_gender

/datum/component/gender_potion_genital_backup/Destroy(force = FALSE)
	QDEL_LIST(stored_organs)
	stored_zones = null
	return ..()

/datum/component/gender_potion_genital_backup/proc/store_current_genitals(mob/living/owner)
	if(!owner)
		return FALSE
	for(var/organ_slot in owner.get_gender_potion_genital_slots())
		for(var/obj/item/organ/genitals/organ as anything in owner.getorganslotlist(organ_slot))
			if(QDELETED(organ))
				continue
			stored_organs += organ
			stored_zones[organ] = organ.current_zone
			owner.remove_gender_potion_genital_organ(organ, TRUE)
	return TRUE

/datum/component/gender_potion_genital_backup/proc/restore_genitals(mob/living/owner)
	if(!owner)
		return FALSE
	owner.clear_gender_potion_genitals()
	for(var/obj/item/organ/genitals/organ as anything in stored_organs)
		if(QDELETED(organ))
			continue
		var/saved_zone = null
		if(stored_zones)
			saved_zone = stored_zones[organ]
		DISABLE_BITFIELD(organ.organ_flags, ORGAN_CUT_AWAY)
		organ.Insert(owner, special = TRUE, drop_if_replaced = FALSE, new_zone = saved_zone)
	stored_organs = null
	stored_zones = null
	qdel(src)
	return TRUE

/mob/living/proc/get_gender_potion_genital_slots()
	// The womb restores before the vagina, so the vagina's pairing hook finds it instead of making another.
	var/static/list/gender_potion_genital_slots = list(
		ORGAN_SLOT_PENIS,
		ORGAN_SLOT_TESTICLES,
		ORGAN_SLOT_BREASTS,
		ORGAN_SLOT_WOMB,
		ORGAN_SLOT_VAGINA
	)
	return gender_potion_genital_slots

/mob/living/proc/remove_gender_potion_genital_organ(obj/item/organ/genitals/organ, preserve = FALSE)
	if(!organ || organ.owner != src)
		return FALSE
	organ.Remove(src, special = TRUE)
	if(preserve)
		organ.moveToNullspace()
		DISABLE_BITFIELD(organ.organ_flags, ORGAN_CUT_AWAY)
		STOP_PROCESSING(SSobj, organ)
	else
		qdel(organ)
	return TRUE

/mob/living/proc/clear_gender_potion_genitals()
	for(var/organ_slot in get_gender_potion_genital_slots())
		for(var/obj/item/organ/genitals/organ as anything in getorganslotlist(organ_slot))
			remove_gender_potion_genital_organ(organ)

/mob/living/proc/give_gender_potion_genitals_for_gender(target_gender)
	if(target_gender == MALE)
		var/obj/item/organ/genitals/filling_organ/testicles/testicles = getorganslot(ORGAN_SLOT_TESTICLES)
		if(!testicles)
			if(!show_genitals)
				testicles = new /obj/item/organ/genitals/filling_organ/testicles/invisible
			else
				testicles = new ball_organ
			testicles.organ_size = rand(ball_min, ball_max)
			testicles.Insert(src, TRUE)

		var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
		if(!penis)
			// The penis type shapes the body, so a hidden one keeps it; show_genitals only changes looks.
			penis = new penis_organ
			penis.length_cm = get_random_penis_length()
			penis.organ_size = get_penis_visual_size(penis.length_cm)
			penis.Insert(src, TRUE)

	else if(target_gender == FEMALE)
		var/obj/item/organ/genitals/filling_organ/breasts/breasts = getorganslot(ORGAN_SLOT_BREASTS)
		if(!breasts)
			if(!show_genitals)
				breasts = new /obj/item/organ/genitals/filling_organ/breasts
			else
				breasts = new breast_organ
			breasts.organ_size = rand(breast_min, breast_max)
			breasts.Insert(src, TRUE)

		var/obj/item/organ/genitals/filling_organ/vagina/vagina = getorganslot(ORGAN_SLOT_VAGINA)
		if(!vagina)
			if(!show_genitals)
				vagina = new /obj/item/organ/genitals/filling_organ/vagina
			else
				vagina = new vagina_organ
			vagina.Insert(src, TRUE)

	if(iscarbon(src))
		var/mob/living/carbon/carbon_owner = src
		carbon_owner.update_body_parts(TRUE)
	return TRUE

/mob/living/proc/apply_gender_potion_genital_change(old_gender)
	if(gender != MALE && gender != FEMALE)
		return FALSE
	var/datum/component/gender_potion_genital_backup/backup = GetComponent(/datum/component/gender_potion_genital_backup)
	if(backup && gender == backup.original_gender)
		return backup.restore_genitals(src)

	if(!backup)
		backup = AddComponent(/datum/component/gender_potion_genital_backup, old_gender)
		if(!backup)
			return FALSE
		backup.store_current_genitals(src)
	else
		clear_gender_potion_genitals()

	give_gender_potion_genitals_for_gender(gender)
	return TRUE

/// Forces the gendered genital slots to match the current gender.
/// NPCs that randomize gender in after_creation (after organs were already built)
/// otherwise keep the wrong set, or gain both once arousal adds the matching one.
/mob/living/proc/resync_genitals_to_gender()
	if(!iscarbon(src))
		return FALSE
	if(gender != MALE && gender != FEMALE)
		return FALSE
	clear_gender_potion_genitals()
	return give_gender_potion_genitals_for_gender(gender)

/mob/living/Initialize()
	. = ..()
	refresh_erp_preference_cache()
	if(ai_controller)
		var/datum/ai_planning_subtree/horny/hornybehavior = locate() in ai_controller.planning_subtrees
		if(hornybehavior && !GetComponent(/datum/component/arousal))
			AddComponent(/datum/component/arousal)

/mob/living/proc/invalidate_erp_preference_cache()
	erp_preferences_revision_seen = -1
	cached_erp_preferences = null
	refresh_erp_preference_cache()

/mob/living/proc/rebuild_cached_erp_preference_shortcuts()
	cached_horny_mob_pref_flags = NONE
	cached_horny_mob_family_flags = NONE
	cached_allow_belly_inflation = null
	cached_nonmatching_horny_mobs_are_nonlethal = null
	if(!cached_erp_preferences)
		return
	var/datum/erp_preference/boolean/allow_belly_inflation/belly_pref = new
	cached_allow_belly_inflation = belly_pref.get_value_from_list(cached_erp_preferences)
	var/datum/erp_preference/boolean/nonmatching_horny_mobs_are_nonlethal/nonlethal_pref = new
	cached_nonmatching_horny_mobs_are_nonlethal = nonlethal_pref.get_value_from_list(cached_erp_preferences)
	cached_horny_mob_pref_flags = cached_erp_preferences[/datum/erp_preference/bitflag/horny_mobs] || NONE
	var/allowed_families = cached_erp_preferences[/datum/erp_preference/bitflag/horny_mob_types]
	if(isnull(allowed_families))
		allowed_families = HORNY_MOB_TYPE_ALL
	cached_horny_mob_family_flags = allowed_families

/mob/living/proc/set_cached_erp_preferences(list/preferences, revision = -1)
	cached_erp_preferences = islist(preferences) ? deep_copy_list_alt(preferences) : null
	erp_preferences_revision_seen = revision
	rebuild_cached_erp_preference_shortcuts()

/mob/living/proc/cache_erp_preferences_from_prefs(datum/preferences/prefs)
	if(!prefs)
		return FALSE
	var/list/erp_preferences = prefs.read_preference(/datum/preference/list_type/erp_preferences)
	if(!length(erp_preferences))
		return FALSE
	if(mind?.current == src)
		return mind.cache_erp_preferences_from_prefs(prefs)
	set_cached_erp_preferences(erp_preferences, prefs.erp_preferences_revision)
	return TRUE

/mob/living/proc/refresh_erp_preference_cache()
	var/datum/preferences/prefs = client?.prefs
	var/list/erp_preferences = prefs?.read_preference(/datum/preference/list_type/erp_preferences)
	if(length(erp_preferences))
		var/current_revision = prefs.erp_preferences_revision
		if(erp_preferences_revision_seen == current_revision && cached_erp_preferences)
			return
		cache_erp_preferences_from_prefs(prefs)
		return

	if(mind?.cached_erp_preferences)
		if(erp_preferences_revision_seen == mind.cached_erp_preferences_revision && cached_erp_preferences)
			return
		set_cached_erp_preferences(mind.cached_erp_preferences, mind.cached_erp_preferences_revision)
		return

	if(!cached_erp_preferences)
		rebuild_cached_erp_preference_shortcuts()

/mob/living/proc/get_cached_erp_pref(pref_type)
	if(!ispath(pref_type, /datum/erp_preference))
		return FALSE
	refresh_erp_preference_cache()
	if(!cached_erp_preferences)
		return FALSE
	var/datum/erp_preference/pref = new pref_type()
	return pref.get_value_from_list(cached_erp_preferences)

/mob/living/proc/get_cached_allow_belly_inflation()
	refresh_erp_preference_cache()
	return cached_allow_belly_inflation == TRUE

/mob/living/proc/get_cached_nonmatching_horny_mobs_are_nonlethal()
	refresh_erp_preference_cache()
	return cached_nonmatching_horny_mobs_are_nonlethal == TRUE

/mob/living/proc/get_cached_horny_mob_pref_flags()
	refresh_erp_preference_cache()
	return cached_horny_mob_pref_flags

/mob/living/proc/get_cached_horny_mob_family_flags()
	refresh_erp_preference_cache()
	return cached_horny_mob_family_flags

/// Shown when this mob climaxes with nothing to release.
/mob/living/proc/get_dry_climax_message()
	return "[src] climaxes, yet nothing is released!"

/// TRUE when a climax releases nothing: no testicles, and a penis or no vagina.
/mob/living/proc/climaxes_dry()
	if(getorganslot(ORGAN_SLOT_TESTICLES))
		return FALSE
	if(!getorganslot(ORGAN_SLOT_VAGINA))
		return TRUE
	// An ovipositor lays eggs on the climax signal and a strapon spills nothing, so the vagina still climaxes.
	var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
	return penis && !istype(penis, /obj/item/organ/genitals/penis/ovipositor) && !penis.is_false_organ()

/// TRUE when [action] works this mob's strapon with no testicles behind it, so only the vagina climaxes.
/mob/living/proc/climaxes_behind_strapon(datum/sex_action/action)
	if(!action || getorganslot(ORGAN_SLOT_TESTICLES) || !getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	var/obj/item/organ/genitals/penis/penis = getorganslot(ORGAN_SLOT_PENIS)
	return penis?.is_false_organ() && action.uses_penis_of(src)

/// Whether this act works [holder]'s penis slot: penetrating with it, its scene slot, or its organ-use lists.
/datum/sex_action/proc/uses_penis_of(mob/living/holder)
	if(!holder)
		return FALSE
	if(ispath(stored_item_type, /obj/item/organ/genitals/penis) && get_storage_insertor(action_user, action_target) == holder)
		return TRUE
	if(holder == action_user && (get_scene_user_slot() == ORGAN_SLOT_PENIS || (ORGAN_SLOT_PENIS in uses_user_organs)))
		return TRUE
	return holder == action_target && (get_scene_target_slot() == ORGAN_SLOT_PENIS || (ORGAN_SLOT_PENIS in uses_target_organs))

/mob/living/proc/give_genitals()
	var/mob/living/user = src
	var/obj/item/organ/genitals/filling_organ/anus/anus = user.getorganslot(ORGAN_SLOT_ANUS)
	if(!anus)
		anus = new /obj/item/organ/genitals/filling_organ/anus
		anus.Insert(user, TRUE)
	if(gender == MALE)
		var/obj/item/organ/genitals/filling_organ/testicles/testicles = user.getorganslot(ORGAN_SLOT_TESTICLES)
		if(!testicles)
			if(!show_genitals)
				testicles = new /obj/item/organ/genitals/filling_organ/testicles/invisible
			else
				testicles = new ball_organ
			testicles.organ_size = rand(ball_min, ball_max)
			testicles.Insert(user, TRUE)
		var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
		if(!penis)
			// The penis type shapes the body, so a hidden one keeps it; show_genitals only changes looks.
			penis = new penis_organ
			penis.length_cm = get_random_penis_length()
			penis.organ_size = get_penis_visual_size(penis.length_cm)
			penis.Insert(user, TRUE)
	if(gender == FEMALE)
		var/obj/item/organ/genitals/butt/buttie = user.getorganslot(ORGAN_SLOT_BUTT)
		if(!buttie)
			if(!show_genitals)
				buttie = new /obj/item/organ/genitals/butt/invisible
			else
				buttie = new butt_organ
			buttie.organ_size = rand(butt_min, butt_max)
			buttie.Insert(user, TRUE)
		var/obj/item/organ/genitals/filling_organ/breasts/breasts = user.getorganslot(ORGAN_SLOT_BREASTS)
		if(!breasts)
			if(!show_genitals)
				breasts = new /obj/item/organ/genitals/filling_organ/breasts
			else
				breasts = new breast_organ
			breasts.organ_size = rand(breast_min,breast_max)
			breasts.Insert(user, TRUE)
		var/obj/item/organ/genitals/filling_organ/vagina/vagina = user.getorganslot(ORGAN_SLOT_VAGINA)
		if(!vagina)
			if(!show_genitals)
				vagina = new /obj/item/organ/genitals/filling_organ/vagina
			else
				vagina = new vagina_organ
			vagina.Insert(user, TRUE)
		if(prob(5)) //5 chance to be dickgirl.
			var/obj/item/organ/genitals/filling_organ/testicles/testicles = user.getorganslot(ORGAN_SLOT_TESTICLES)
			if(!testicles)
				if(!show_genitals)
					testicles = new /obj/item/organ/genitals/filling_organ/testicles/invisible
				else
					testicles = new ball_organ
				testicles.organ_size = rand(ball_min, ball_max)
				testicles.Insert(user, TRUE)
			var/obj/item/organ/genitals/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
			if(!penis)
				// The penis type shapes the body, so a hidden one keeps it; show_genitals only changes looks.
				penis = new penis_organ
				penis.length_cm = get_random_penis_length()
				penis.organ_size = get_penis_visual_size(penis.length_cm)
				penis.Insert(user, TRUE)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.update_body_parts()
	return TRUE

/mob/living/proc/lose_virginity()
	return

/mob/living/carbon/human/lose_virginity()
	REMOVE_TRAIT(src, TRAIT_VIRGIN, null)

/mob/living/proc/adjacent_or_closet(atom/neighbor)
	if(!neighbor)
		return FALSE
	if(loc == neighbor.loc) // same tile, or tucked inside the same thing
		return TRUE
	if(Adjacent(neighbor))
		return TRUE
	// Adjacent() gives up outright once either loc is not a turf, which locks out anyone inside a
	// closet, a handcart, or a hiding spot under a table. Reach from the container's own tile.
	if(isturf(loc) && isturf(neighbor.loc))
		return FALSE
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return FALSE
	return our_turf.Adjacent(neighbor, target = neighbor, mover = src)

/// TRUE when both of us are tucked inside the same thing, which counts as sharing a tile.
/mob/living/proc/check_closet(atom/neighbor)
	return neighbor && !isturf(loc) && (loc == neighbor.loc)

/mob/living/proc/in_sex_interaction_range(atom/other)
	if(!other)
		return FALSE
	if(other in view(1, src))
		return TRUE
	return adjacent_or_closet(other)

/// Someone hidden in furniture can be picked only by a partner already in their scene.
/mob/living/proc/can_reach_hidden_sex_partner(mob/living/hider)
	if(hider == src)
		return TRUE
	if(hider.stat == DEAD || !sex_scene || QDELETED(sex_scene) || !(hider in sex_scene.participants))
		return FALSE
	return in_sex_interaction_range(hider)

/// Partners the ERP panel offers: closet mates, or everyone in reach plus scene partners hidden nearby.
/mob/living/proc/get_sex_panel_candidates()
	. = list()
	if(istype(loc, /obj/structure/closet))
		for(var/mob/living/occupant in loc)
			if(occupant.stat != DEAD)
				. += occupant
		return
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	for(var/turf/nearby in range(1, our_turf))
		for(var/atom/movable/thing as anything in nearby)
			if(isliving(thing))
				var/mob/living/candidate = thing
				if(candidate.stat != DEAD && candidate.invisibility <= see_invisible && in_sex_interaction_range(candidate))
					. += candidate
			else if(isstructure(thing))
				var/obj/structure/spot = thing
				if(!spot.hidingspot)
					continue
				for(var/mob/living/hider in spot)
					if(can_reach_hidden_sex_partner(hider))
						. += hider

/// Dragging yourself onto a hiding spot reaches a scene partner tucked inside it.
/obj/structure/MiddleMouseDrop_T(atom/movable/dragged, mob/living/user)
	if(hidingspot && isliving(user) && !user.mmb_intent)
		for(var/mob/living/hider in src)
			if(hider != user && user.can_reach_hidden_sex_partner(hider))
				return hider.MiddleMouseDrop_T(dragged, user)
	return ..()
