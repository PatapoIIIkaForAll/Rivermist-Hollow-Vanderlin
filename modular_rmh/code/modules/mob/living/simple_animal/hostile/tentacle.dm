/datum/targetting_datum/basic/tentacle

/datum/targetting_datum/basic/tentacle/can_quickly_engage_target(mob/living/living_mob, atom/target)
	return can_attack(living_mob, target)

/datum/targetting_datum/basic/tentacle/can_engage_target(mob/living/living_mob, atom/target)
	return can_attack(living_mob, target)

/datum/targetting_datum/basic/tentacle/should_disarm(mob/living/living_mob, atom/target)
	return FALSE

/datum/ai_controller/tentacle
	movement_delay = 0.4 SECONDS
	ai_movement = /datum/ai_movement/hybrid_pathing
	horny_pref_family_flag = HORNY_MOB_TYPE_TENTACLES

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/tentacle(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/kidnap_defeated_prey,

		/datum/ai_planning_subtree/simple_find_horny,
		/datum/ai_planning_subtree/horny,

		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/agile,
	)

	idle_behavior = /datum/idle_behavior/idle_random_walk

/mob/living/simple_animal/hostile/retaliate/tentacle
	name = "writhing tentacle mass"
	desc = "A restless knot of slick, searching tentacles moving with unsettling purpose."
	icon = 'modular_rmh/icons/mob/monster/tentacles_grey.dmi'
	icon_state = "roamer"
	icon_living = "roamer"
	icon_dead = "roamer_dead"

	faction = list("tentacles")
	gender = MALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	move_to_delay = 2
	vision_range = 7
	aggro_vision_range = 7

	health = 120
	maxHealth = 120
	base_constitution = 8
	base_strength = 9
	base_speed = 12

	base_intents = list(/datum/intent/simple/slam)
	attack_verb_continuous = "lashes"
	attack_verb_simple = "lash"
	attack_sound = 'sound/combat/hits/blunt/woodblunt (1).ogg'
	melee_damage_lower = 10
	melee_damage_upper = 16
	defprob = 20
	defdrain = 8
	candodge = FALSE

	aggressive = FALSE
	stat_attack = UNCONSCIOUS
	retreat_distance = 0
	minimum_distance = 0
	deaggroprob = 0
	food_type = list()
	pooptype = null
	ai_controller = /datum/ai_controller/tentacle
	kidnap_lair_tag = "tentacle_lair"
	kidnap_captivity_profile = /datum/defeat_captivity_profile/shared/tentacle
	botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 1, /obj/item/alch/viscera = 5)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 2,
						/obj/item/natural/hide = 1,
						/obj/item/alch/sinew = 2,
						/obj/item/alch/viscera = 3)
	perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 3,
						/obj/item/natural/hide = 2,
						/obj/item/alch/sinew = 2,
						/obj/item/alch/viscera = 2)

	emote_see = list("slowly coils in on itself", "tastes the air with a questing tip", "ripples across the ground")

	/// Palette that never changes. Null takes the palette of the ground.
	var/fixed_palette = null
	/// FALSE for full-colour sprites that take no palette.
	var/uses_palette = TRUE
	/// Whether a step onto other ground changes the palette.
	var/retint_on_move = TRUE
	/// Name of the palette applied now.
	var/tmp/current_palette

/mob/living/simple_animal/hostile/retaliate/tentacle/Initialize(mapload)
	. = ..()
	refresh_tentacle_palette()
	AddElement(/datum/element/ai_retaliate)
	// A tentacle that takes a kind gets its organs from the kind instead.
	if(will_take_tentacle_kind())
		return
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = ensure_tentacle_ovipositor(src)
	if(ovipositor)
		ovipositor.name = "egg-bearing tentacle"
		ovipositor.desc = "A sensitive, prehensile tentacle adapted to carry and lay soft eggs."

/// Applies the fixed palette or the palette of the ground below. Does nothing when the palette is unchanged.
/mob/living/simple_animal/hostile/retaliate/tentacle/proc/refresh_tentacle_palette(fade = 0)
	if(!uses_palette)
		return
	var/palette = fixed_palette || tentacle_palette_for_turf(get_turf(src))
	if(palette == current_palette)
		return
	current_palette = palette
	apply_tentacle_palette(palette, fade)

/mob/living/simple_animal/hostile/retaliate/tentacle/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(!retint_on_move || stat == DEAD || !isturf(loc) || loc == OldLoc)
		return
	refresh_tentacle_palette(1 SECONDS)

/mob/living/simple_animal/hostile/retaliate/tentacle/simple_limb_hit(zone)
	if(!zone)
		return ""
	return pick("central mass", "thick coil", "questing tendril", "soft underside")

/// Tentacles use the ordinary defeat-captivity flow, but their configured lair is a real map
/// location instead of a pocket instance.
/mob/living/simple_animal/hostile/retaliate/tentacle/complete_kidnap_defeated_prey(mob/living/victim)
	var/obj/effect/landmark/kidnap/entrance/tentacle/entrance = get_tentacle_lair_entrance(src)
	if(!entrance)
		return FALSE
	return victim.kidnap_to_mapped_lair(kidnap_captivity_profile, src, faction, kidnap_lair_tag, entrance)

/datum/defeat_captivity_profile/shared/tentacle
	stable_key = "tentacle_lair"
	display_name = "tentacle lair"
	capacity = 12

/// Mapper destination for independent and unbound tentacles. At least one must exist on the same
/// z-level as the captor; the nearest valid marker is selected.
/obj/effect/landmark/kidnap/entrance/tentacle
	name = "tentacle lair kidnap entrance"
	lair_tag = "tentacle_lair"

/// Crossing this mapper marker ends mapped tentacle captivity in place. Put it on the physical way
/// out of the lair rather than beside the entrance marker.
/obj/effect/landmark/kidnap/escape/tentacle
	name = "tentacle lair captivity boundary"
	lair_tag = "tentacle_lair"

/proc/get_tentacle_lair_entrance(atom/reference)
	var/turf/reference_turf = get_turf(reference)
	if(!reference_turf)
		return null
	var/list/entrances = GLOB.kidnap_entrance_markers["tentacle_lair"]
	var/obj/effect/landmark/kidnap/entrance/tentacle/nearest_entrance
	var/nearest_distance = INFINITY
	for(var/obj/effect/landmark/kidnap/entrance/tentacle/candidate as anything in entrances)
		var/turf/candidate_turf = get_turf(candidate)
		if(!candidate_turf || candidate_turf.z != reference_turf.z)
			continue
		var/candidate_distance = get_dist(reference_turf, candidate_turf)
		if(candidate_distance >= nearest_distance)
			continue
		nearest_entrance = candidate
		nearest_distance = candidate_distance
	return nearest_entrance

/obj/item/rope/spider_silk/tentacle_resin
	name = "tentacle resin"
	desc = "A warm coil of sticky resin, fibrous enough to bind wrists."
	breakouttime = 10 SECONDS
	slipouttime = 30 SECONDS
	color = "#804b70"

/datum/sex_action/npc/npc_vaginal_sex/tentacle
	name = "Tentacle vagina"
	description = "Work a slick tentacle into their vagina."

/datum/sex_action/npc/npc_vaginal_sex/tentacle/shows_on_menu(mob/living/user, mob/living/target)
	return istype(user, /mob/living/simple_animal/hostile/retaliate/tentacle) && !is_maneater_tendril(user) && user != target

/datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater
	name = "Part petals"
	description = "Work a seed-bearing plant tendril into their vagina."

/datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater/shows_on_menu(mob/living/user, mob/living/target)
	return is_maneater_tendril(user) && user != target

/datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater/compose_start_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] eases a flowering vine into [target]'s cunt!",
		"[user] eases a flowering vine into my cunt!",
		"I hear leaves rustling and a sharp gasp."
	)

/datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/hear = "I hear leaves rustling and a wet slide."
	switch(stage)
		if("opening")
			return act_lines("[user] roots its flowering vine in [target]'s pussy.", "[user] roots its flowering vine in my pussy.", hear)
		if("late")
			return act_lines("[user] roots its flowering vine in [target]'s pussy, faster and deeper.", "[user] roots its flowering vine in my pussy, faster and deeper.", hear)
	return act_lines("[user] [get_generic_force_adjective()] roots its flowering vine in [target]'s pussy.", "[user] roots its flowering vine in my pussy.", hear)

/datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater/compose_finish_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] draws its sap-slick vine out of [target]'s pussy.",
		"[user] draws its sap-slick vine out of my pussy.",
		"I hear leaves rustling."
	)

/datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] shudders and clenches around [partner]'s flowering vine!",
			"I shudder and clench around [partner]'s flowering vine!",
			"I hear leaves rustling and a shaky moan."
		)
	return act_lines(
		"[climaxer] pulses warm sap and seed into [partner]'s pussy!",
		"[climaxer] pulses warm sap and seed into my pussy!",
		"I hear leaves rustling and a wet pulse."
	)

/datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_ONTO
	user.lose_virginity()
	target.lose_virginity()
	return ORGASM_LOCATION_INTO

/datum/sex_action/npc/npc_anal_sex/tentacle
	name = "Tentacle anus"
	description = "Work a slick tentacle into their anus."

/datum/sex_action/npc/npc_anal_sex/tentacle/shows_on_menu(mob/living/user, mob/living/target)
	return istype(user, /mob/living/simple_animal/hostile/retaliate/tentacle) && !is_maneater_tendril(user) && user != target

/datum/sex_action/npc/npc_anal_sex/tentacle/maneater
	name = "Root vine"
	description = "Ease a seed-bearing plant tendril into their anus."

/datum/sex_action/npc/npc_anal_sex/tentacle/maneater/shows_on_menu(mob/living/user, mob/living/target)
	return is_maneater_tendril(user) && user != target

/datum/sex_action/npc/npc_anal_sex/tentacle/maneater/compose_start_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] works a tapering green vine into [target]'s ass!",
		"[user] works a tapering green vine into my ass!",
		"I hear leaves rustling and a strangled grunt."
	)

/datum/sex_action/npc/npc_anal_sex/tentacle/maneater/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/hear = "I hear leaves rustling and a wet slide."
	switch(stage)
		if("opening")
			return act_lines("[user] drives its rooting vine into [target]'s ass.", "[user] drives its rooting vine into my ass.", hear)
		if("late")
			return act_lines("[user] drives its rooting vine into [target]'s ass, faster and deeper.", "[user] drives its rooting vine into my ass, faster and deeper.", hear)
	return act_lines("[user] [get_generic_force_adjective()] drives its rooting vine into [target]'s ass.", "[user] drives its rooting vine into my ass.", hear)

/datum/sex_action/npc/npc_anal_sex/tentacle/maneater/compose_finish_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] slowly unroots its slick vine from [target]'s butt.",
		"[user] slowly unroots its slick vine from my butt.",
		"I hear leaves rustling."
	)

/datum/sex_action/npc/npc_anal_sex/tentacle/maneater/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] trembles and wrings [partner]'s vine tight!",
			"I tremble and wring [partner]'s vine tight!",
			"I hear leaves rustling and a shaky moan."
		)
	return act_lines(
		"[climaxer] swells and spills warm seed into [partner]'s butt!",
		"[climaxer] swells and spills warm seed into my butt!",
		"I hear leaves rustling and a wet pulse."
	)

/datum/sex_action/npc/npc_anal_sex/tentacle/maneater/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_SELF
	user.lose_virginity()
	target.lose_virginity()
	return ORGASM_LOCATION_INTO

/datum/sex_action/npc/npc_throat_sex/tentacle
	name = "Tentacle throat"
	description = "Ease a slick tentacle into their mouth."

/datum/sex_action/npc/npc_throat_sex/tentacle/shows_on_menu(mob/living/user, mob/living/target)
	return istype(user, /mob/living/simple_animal/hostile/retaliate/tentacle) && !is_maneater_tendril(user) && user != target

/datum/sex_action/npc/npc_throat_sex/tentacle/maneater
	name = "Feed vine"
	description = "Ease a seed-bearing plant tendril into their mouth."

/datum/sex_action/npc/npc_throat_sex/tentacle/maneater/shows_on_menu(mob/living/user, mob/living/target)
	return is_maneater_tendril(user) && user != target

/datum/sex_action/npc/npc_throat_sex/tentacle/maneater/compose_start_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] feeds a flowering vine past [target]'s lips and down [target.p_their()] throat!",
		"[user] feeds a flowering vine past my lips and down my throat!",
		"I hear leaves rustling and choking."
	)

/datum/sex_action/npc/npc_throat_sex/tentacle/maneater/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/hear = "I hear leaves rustling and choking."
	switch(stage)
		if("opening")
			return act_lines("[user] feeds its flowering vine down [target]'s throat.", "[user] feeds its flowering vine down my throat.", hear)
		if("late")
			return act_lines("[user] feeds its flowering vine down [target]'s throat, faster and deeper.", "[user] feeds its flowering vine down my throat, faster and deeper.", hear)
	return act_lines("[user] [get_generic_force_adjective()] feeds its flowering vine down [target]'s throat.", "[user] feeds its flowering vine down my throat.", hear)

/datum/sex_action/npc/npc_throat_sex/tentacle/maneater/compose_finish_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] lets its flowering vine slip free of [target]'s throat.",
		"[user] lets its flowering vine slip free of my throat.",
		"I hear leaves rustling and a gasp."
	)

/datum/sex_action/npc/npc_throat_sex/tentacle/maneater/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] quivers around [partner]'s flowering vine!",
			"I quiver around [partner]'s flowering vine!",
			"I hear leaves rustling and a muffled moan."
		)
	return act_lines(
		"[climaxer] pulses a mouthful of sweet sap and seed into [partner]'s throat!",
		"[climaxer] pulses a mouthful of sweet sap and seed into my throat!",
		"I hear leaves rustling and gulping."
	)

/datum/sex_action/npc/npc_throat_sex/tentacle/maneater/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		return ORGASM_LOCATION_SELF
	user.lose_virginity()
	return ORGASM_LOCATION_ORAL

/datum/sex_action/tentacle_jerk
	name = "Tentacle jerk"
	description = "Coil a smaller tentacle around their penis."
	check_same_tile = FALSE
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS

/datum/sex_action/tentacle_jerk/shows_on_menu(mob/living/user, mob/living/target)
	if(!istype(user, /mob/living/simple_animal/hostile/retaliate/tentacle) || is_maneater_tendril(user) || user == target)
		return FALSE
	return !!target.getorganslot(ORGAN_SLOT_PENIS)

/datum/sex_action/tentacle_jerk/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || !shows_on_menu(user, target))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	return !check_sex_lock(target, ORGAN_SLOT_PENIS)

/datum/sex_action/tentacle_jerk/on_start(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(compose_start_lines(user, target), user, target, "warning")

/// The hunter's kind lines for a beat, or null for the default ones.
/datum/sex_action/tentacle_jerk/proc/get_kind_jerk_lines(beat, mob/living/hunter, mob/living/victim)
	var/datum/tentacle_kind/kind = get_tentacle_kind_of(hunter)
	return kind?.get_jerk_lines(src, beat, hunter, victim)

/datum/sex_action/tentacle_jerk/compose_start_lines(mob/living/user, mob/living/target)
	var/list/kind_lines = get_kind_jerk_lines("start", user, target)
	if(kind_lines)
		return kind_lines
	return act_lines(
		"[user] coils a slick tentacle around [target]'s cock.",
		"[user] coils a slick tentacle around my cock.",
		"I hear wet writhing and slick strokes."
	)

/datum/sex_action/tentacle_jerk/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		show_act_lines(compose_perform_lines(user, target, "middle", rand(1, 3)), user, target, "force")
	playsound(target, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 2, 0, 2)
	handle_passive_ejaculation(target)

/datum/sex_action/tentacle_jerk/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/list/kind_lines = get_kind_jerk_lines("middle", user, target)
	if(kind_lines)
		return kind_lines
	return act_lines(
		"[user] [get_generic_force_adjective()] milks [target]'s cock with a rippling tentacle.",
		"[user] milks my cock with a rippling tentacle.",
		"I hear wet writhing and slick strokes."
	)

/datum/sex_action/tentacle_jerk/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	var/list/kind_lines = flipped ? get_kind_jerk_lines("victim climax", partner, climaxer) : get_kind_jerk_lines("climax", climaxer, partner)
	if(kind_lines)
		return kind_lines
	if(flipped)
		return act_lines(
			"[climaxer] bucks and spills into [partner]'s coiling tentacle!",
			"I buck and spill into [partner]'s coiling tentacle!",
			"I hear wet writhing and a sharp gasp."
		)
	return act_lines(
		"[climaxer] shudders, its tentacle squeezing [partner]'s cock!",
		"[climaxer] shudders, its tentacle squeezing my cock!",
		"I hear wet writhing."
	)

/datum/sex_action/tentacle_jerk/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	return null

/datum/sex_action/tentacle_jerk/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(compose_finish_lines(user, target), user, target, "warning")

/datum/sex_action/tentacle_jerk/compose_finish_lines(mob/living/user, mob/living/target)
	var/list/kind_lines = get_kind_jerk_lines("finish", user, target)
	if(kind_lines)
		return kind_lines
	return act_lines(
		"[user] unwinds its tentacle from [target]'s cock.",
		"[user] unwinds its tentacle from my cock.",
		"I hear wet writhing."
	)

/datum/sex_action/tentacle_jerk/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, ORGAN_SLOT_PENIS, null, FALSE)

/datum/sex_action/tentacle_jerk/maneater
	name = "Wind vines"
	description = "Coil a flowering tendril around their penis."

/datum/sex_action/tentacle_jerk/maneater/shows_on_menu(mob/living/user, mob/living/target)
	if(!is_maneater_tendril(user) || user == target)
		return FALSE
	return !!target.getorganslot(ORGAN_SLOT_PENIS)

/datum/sex_action/tentacle_jerk/maneater/compose_start_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] winds a pair of flowering vines around [target]'s cock.",
		"[user] winds a pair of flowering vines around my cock.",
		"I hear leaves rustling and slick strokes."
	)

/datum/sex_action/tentacle_jerk/maneater/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	return act_lines(
		"[user] [get_generic_force_adjective()] milks [target]'s cock between pulsing, sap-slick vines.",
		"[user] milks my cock between pulsing, sap-slick vines.",
		"I hear leaves rustling and slick strokes."
	)

/datum/sex_action/tentacle_jerk/maneater/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] bucks and spills between [partner]'s sap-slick vines!",
			"I buck and spill between [partner]'s sap-slick vines!",
			"I hear leaves rustling and a sharp gasp."
		)
	return act_lines(
		"[climaxer] shudders, its vines squeezing [partner]'s cock!",
		"[climaxer] shudders, its vines squeezing my cock!",
		"I hear leaves rustling."
	)

/datum/sex_action/tentacle_jerk/maneater/compose_finish_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] lets its flowering vines uncurl from [target]'s cock.",
		"[user] lets its flowering vines uncurl from my cock.",
		"I hear leaves rustling."
	)

/datum/sex_action/maneater_vine_caress
	name = "Vine embrace"
	description = "Stroke and squeeze their body with warm, sap-slick tendrils."
	check_same_tile = FALSE
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	target_menu_zone_mask = SEX_UI_ZONE_BODY

/datum/sex_action/maneater_vine_caress/shows_on_menu(mob/living/user, mob/living/target)
	return is_maneater_tendril(user) && user != target

/datum/sex_action/maneater_vine_caress/can_perform(mob/living/user, mob/living/target)
	. = ..()
	return . && shows_on_menu(user, target)

/datum/sex_action/maneater_vine_caress/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	show_act_lines(act_lines(
		"Flowering vines from [user] curl around [target]'s body and draw tight.",
		"Flowering vines from [user] curl around my body and draw tight.",
		"I hear leaves rustling."
	), user, target, "warning")
	return TRUE

/datum/sex_action/maneater_vine_caress/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		show_act_lines(act_lines(
			"The vines of [user] [get_generic_force_adjective()] stroke and squeeze [target].",
			"The vines of [user] stroke and squeeze me.",
			"I hear leaves rustling and skin sliding on sap."
		), user, target, "force")
	playsound(target, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 2, 0, 2)
	perform_sex_action(user, target, 0.5, 0, 0.5)

/datum/sex_action/maneater_vine_caress/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("The flowering vines of [user] loosen their hold on [target]."))

/proc/is_maneater_tendril(mob/living/tendril)
	return istype(tendril, /mob/living/simple_animal/hostile/retaliate/maneater_tendrils) \
		|| istype(tendril, /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater)
