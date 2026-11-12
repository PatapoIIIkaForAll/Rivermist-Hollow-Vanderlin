GLOBAL_LIST_EMPTY(horny_family_profiles)

/// The profile for a family flag. Unknown flags and NONE get the base profile.
/proc/horny_profile_for_flag(family_flag)
	if(!length(GLOB.horny_family_profiles))
		for(var/profile_type in typesof(/datum/horny_family_profile))
			var/datum/horny_family_profile/profile = new profile_type
			GLOB.horny_family_profiles["[profile.family_flag]"] = profile
	return GLOB.horny_family_profiles["[family_flag]"] || GLOB.horny_family_profiles["[NONE]"]

/// How one family of horny mobs hunts: tells, pain, break-off, prep steps, acts and lines. Singleton, keeps no mob refs.
/datum/horny_family_profile
	/// HORNY_MOB_TYPE_* flag this profile serves; NONE is the fallback.
	var/family_flag = NONE
	/// Temper gained per point of damage. Zero means pain never moves this family.
	var/pain_factor = 1
	/// Hurt fraction (get_ai_hurt_fraction) at which the hunt breaks off.
	var/hurt_limit = 0.5
	/// Hurt fraction at which the hunter gives the hunt up for good.
	var/flee_limit = 0.7
	/// What furious looks like, HORNY_BREAK_OFF_*.
	var/break_off = HORNY_BREAK_OFF_SUBDUE
	/// Human hunters that switch to the run intent inside sprint_range.
	var/can_sprint = FALSE
	var/sprint_range = HORNY_SPRINT_RANGE
	/// Handless hunters: step delay multiplier while rushing after a ranged hit.
	var/rush_speed_mult = HORNY_RUSH_SPEED_MULT
	/// How long the tell lasts before the hunter moves.
	var/notice_time = HORNY_NOTICE_TIME
	/// Prep step types, run in this order once the target is held or down.
	var/list/prep_step_types = list(
		/datum/horny_prep_step/disarm,
		/datum/horny_prep_step/undress_self,
		/datum/horny_prep_step/strip,
		/datum/horny_prep_step/bind,
	)
	/// Step singletons built from prep_step_types.
	var/list/prep_steps
	/// Strip pacing in deciseconds, and the rough-handling damage roll.
	var/strip_delay_min = 12
	var/strip_delay_max = 20
	var/strip_damage_chance = 35
	var/strip_damage_ratio = 0.15
	/// Chance to strip one more piece even when an act already fits.
	var/extra_strip_chance = 35
	/// Restraint the bind step applies; null means this family cannot bind.
	var/restraint_type = /obj/item/rope
	/// How this family catches: HORNY_MOVE_*.
	var/seize_move = HORNY_MOVE_LADDER
	/// Added to the handless knockdown roll: momentum, weight, or just meanness.
	var/bear_down_bonus = 0
	/// Fatigue a coil costs the target every beat it holds on.
	var/squeeze_fatigue = 0
	/// Leaps the last two or three tiles.
	var/pounces = FALSE
	/// Reaches two tiles with a lash that drags the target closer.
	var/lashes = FALSE
	/// Works round to the target's back before closing.
	var/circles_behind = FALSE
	/// Follows a scent trail after sight is lost, when the target lets scents matter.
	var/follows_scent = FALSE
	/// Calls packmates on the tell, up to pack_cap hunters; 0 means no cap.
	var/pack_call = FALSE
	var/pack_cap = HORNY_PACK_CAP
	/// Spits its ranged web as a trap when angered.
	var/spits_web = FALSE
	/// How long a knotted hunter stays tied before it lets go.
	var/tie_time = 45 SECONDS
	/// Hunters with hands get the hand acts and the hand-held lines.
	var/has_hands = TRUE

/datum/horny_family_profile/New()
	. = ..()
	prep_steps = list()
	for(var/step_type in prep_step_types)
		prep_steps += new step_type

/// The step singleton of a given type, or null when this family lacks it.
/datum/horny_family_profile/proc/get_prep_step(step_type)
	for(var/datum/horny_prep_step/step as anything in prep_steps)
		if(step.type == step_type)
			return step
	return null

/// Called when lust tops out; the hunt already stopped the act and dropped the hold.
/datum/horny_family_profile/proc/on_overwhelmed(datum/ai_controller/controller, mob/living/hunter, mob/living/target)
	return

// --- Lines ---------------------------------------------------------------------------------------

/// The tell when a hunter picks its target.
/datum/horny_family_profile/proc/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s eyes lock onto [target], and a slow grin spreads across [hunter.p_their()] face."

/// A handless hunter settling its hold on the target.
/datum/horny_family_profile/proc/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] clamps onto [target], holding [target.p_them()] in place!"

/// The hunter giving up on its target.
/datum/horny_family_profile/proc/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] stomps on the ground, clearly unsatisfied!"

/// The hunter done with its target; heavy means sated for a long while.
/datum/horny_family_profile/proc/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] lets out a relieved sigh and releases [target] for now." : "[hunter] exhales contently!"

/// A ranged hit landing: the hunter staggers, then comes on faster.
/datum/horny_family_profile/proc/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] staggers, snarls, and comes on faster!"

/// The hunter breaking off.
/datum/horny_family_profile/proc/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] snarls and goes for [target]'s arms instead!"

/// The hunter overwhelmed by its own lust.
/datum/horny_family_profile/proc/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] loses [hunter.p_their()] grip and sags, flushed and trembling, open to [target]."

/// A short spoken line for a bark context, or null for families that do not talk.
/datum/horny_family_profile/proc/get_bark(mob/living/hunter, mob/living/target, context)
	return null

/// Start and finish lines for the bind step, keyed start, start_target, start_hear, done, done_target, done_hear.
/datum/horny_family_profile/proc/get_bind_lines(mob/living/hunter, mob/living/target)
	return list(
		"start" = "[hunter] begins to tie up [target]'s hands!",
		"start_target" = "[hunter] begins to tie my hands!",
		"start_hear" = "I hear rope being pulled tight.",
		"done" = "[hunter] binds [target]'s wrists with rope!",
		"done_target" = "[hunter] binds my wrists with rope!",
		"done_hear" = "I hear rope knotting.",
	)

/// Tie beats while knotted, keyed tug, tug_me, tug_hear, release, release_me, release_hear.
/datum/horny_family_profile/proc/get_tie_lines(mob/living/hunter, mob/living/target)
	return list(
		"tug" = "[hunter] rocks against [target], knot swollen tight inside [target.p_them()].",
		"tug_me" = "[hunter] rocks against me, [hunter.p_their()] knot swollen tight inside me.",
		"tug_hear" = "I hear a low grunt and a wet shift.",
		"release" = "[hunter]'s knot slackens and slips free of [target].",
		"release_me" = "[hunter]'s knot slackens and slips free of me.",
		"release_hear" = "I hear a wet pop.",
	)

/// A pounce family leaving the ground.
/datum/horny_family_profile/proc/get_pounce_message(mob/living/hunter, mob/living/target)
	return "[hunter] springs at [target]!"

/// A handed hunter's grab landing on a limb; to_target gives the victim's own line.
/datum/horny_family_profile/proc/get_grab_message(mob/living/hunter, mob/living/target, zone, to_target = FALSE)
	return to_target ? "[hunter] grabs me by the [zone]!" : "[hunter] grabs [target] by the [zone]!"

/// A handless hunter putting the target on the ground.
/datum/horny_family_profile/proc/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] bears [target] down to the ground!"

/datum/horny_family_profile/proc/get_bear_down_miss_message(mob/living/hunter, mob/living/target)
	return "[hunter] tries to drag [target] down, but [target] keeps [target.p_their()] feet!"

/// A lash dragging the target a step closer, and one that misses.
/datum/horny_family_profile/proc/get_lash_message(mob/living/hunter, mob/living/target)
	return "[hunter] lashes out and drags [target] a step closer!"

/datum/horny_family_profile/proc/get_lash_miss_message(mob/living/hunter, mob/living/target)
	return "[hunter] lashes at [target], who twists clear!"

/// The coil tightening; to_target gives the victim's own line.
/datum/horny_family_profile/proc/get_squeeze_message(mob/living/hunter, mob/living/target, to_target = FALSE)
	if(to_target)
		return "[hunter]'s coils tighten and crush the breath out of me!"
	return "[hunter]'s coils tighten around [target]!"

/// The tell that brings the pack, and what others hear of it.
/datum/horny_family_profile/proc/get_pack_call_message(mob/living/hunter, mob/living/target)
	return "[hunter] shouts for [hunter.p_their()] friends and points at [target]!"

/datum/horny_family_profile/proc/get_pack_call_hear_message(mob/living/hunter)
	return "I hear a shout and an answering whoop."

// --- Acts ----------------------------------------------------------------------------------------

/// Whether [hunter] is ready to lay: eggs stored, a willing host with room, and arousal from ordinary acts first.
/proc/horny_egg_lay_ready(mob/living/hunter, mob/living/target)
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(hunter)
	if(!ovipositor || ovipositor.eggs_stored <= 0)
		return FALSE
	if(!target_allows_mob_erp_action(hunter, target, /datum/erp_preference/boolean/allow_mob_oviposition))
		return FALSE
	// A victim wrapped in a cocoon is held and warmed by the silk; the lay needs no warm-up act.
	if(!istype(target.loc, /obj/structure/spider/cocoon))
		var/list/arousal_data = list()
		SEND_SIGNAL(hunter, COMSIG_SEX_GET_AROUSAL, arousal_data)
		if((arousal_data["arousal"] || 0) < HORNY_EGG_LAY_AROUSAL)
			return FALSE
	// A full host keeps the hunter in its ordinary act.
	for(var/slot in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS, BODY_ZONE_PRECISE_MOUTH))
		if(horny_egg_hole_has_room(hunter, target, slot))
			return TRUE
	return FALSE

/// TRUE when [target]'s [slot] hole can take one of [hunter]'s eggs right now.
/proc/horny_egg_hole_has_room(mob/living/hunter, mob/living/target, slot)
	var/datum/component/ovipositor/ovipositor = get_working_ovipositor(hunter)
	return ovipositor?.has_room_for_egg(ovipositor.get_receiver_for_hole(target, slot))

/// A hole slick enough to take eggs; the ordinary act before this is the lube-up.
/proc/horny_egg_hole_ready(mob/living/target, slot)
	var/obj/item/organ/genitals/filling_organ/hole = target.getorganslot(slot)
	if(!istype(hole) || !hole.orifice_type)
		return TRUE
	return hole.get_orifice().get_dryness_multiplier() < ORIFICE_DRY_WARNING_MULT

/// Egg acts into holes with room; TRUE when it added any, and then nothing else is on the table.
/datum/horny_family_profile/proc/add_egg_act_choices(list/weighted_actions, mob/living/hunter, mob/living/target)
	if(!horny_egg_lay_ready(hunter, target))
		return FALSE
	var/added = FALSE
	if(target.getorganslot(ORGAN_SLOT_VAGINA) && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA) && horny_egg_hole_ready(target, ORGAN_SLOT_VAGINA) && horny_egg_hole_has_room(hunter, target, ORGAN_SLOT_VAGINA))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex/lay_eggs, 4)
		added = TRUE
	if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS) && horny_egg_hole_ready(target, ORGAN_SLOT_ANUS) && horny_egg_hole_has_room(hunter, target, ORGAN_SLOT_ANUS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex/lay_eggs, 3)
		added = TRUE
	if(!added && horny_egg_hole_has_room(hunter, target, BODY_ZONE_PRECISE_MOUTH))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex/lay_eggs, 2)
		added = TRUE
	return added

/// Adds this family's act types to a weighted list, heavier entries more likely.
/datum/horny_family_profile/proc/add_act_choices(list/weighted_actions, mob/living/hunter, mob/living/target)
	var/has_penis = !!hunter.getorganslot(ORGAN_SLOT_PENIS)
	var/has_vagina = !!hunter.getorganslot(ORGAN_SLOT_VAGINA)
	var/target_has_penis = !!target.getorganslot(ORGAN_SLOT_PENIS)
	var/target_has_vagina = !!target.getorganslot(ORGAN_SLOT_VAGINA)
	if(add_egg_act_choices(weighted_actions, hunter, target))
		return

	// Skeletons: a funny bone gets its own acts, and one with nothing below the belt can only pet.
	if(istype(hunter.getorganslot(ORGAN_SLOT_PENIS), /obj/item/organ/genitals/penis/funny_bone))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex/funny_bone, 2)
		if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex/funny_bone)
		if(target_has_vagina && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex/funny_bone, 3)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_jerk_over/funny_bone)
		return
	if(!has_penis && !has_vagina && istype(hunter, /mob/living/carbon/human/species/skeleton))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_bony_petting)
		return

	if(has_penis)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex, 2)
		if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex)
		if(target_has_vagina && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex, 3)
		if(has_hands)
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_handjob)
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_jerk_over)

	if(has_vagina)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_facesitting, 2)
		if(target_has_penis)
			if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA, TRUE))
				add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_ride_sex, 3)
			if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS, TRUE))
				add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_ride_sex)

	if(has_penis || has_vagina)
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_body_rub)
		// Humanoids also dry-hump; the grind's own rules pick a spot by height and posture.
		if(ishuman(hunter))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/grind/partner/npc)

// --- Families ------------------------------------------------------------------------------------

/datum/horny_family_profile/humanoids
	family_flag = HORNY_MOB_TYPE_HUMANOIDS
	can_sprint = TRUE
	pack_call = TRUE
	bear_down_bonus = 10

/// The sweep a humanoid falls back on once the throw keeps failing.
/datum/horny_family_profile/humanoids/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] hooks [target]'s legs out from under [target.p_them()] and brings [target.p_them()] down!"

/datum/horny_family_profile/humanoids/get_bear_down_miss_message(mob/living/hunter, mob/living/target)
	return "[hunter] hooks at [target]'s legs, but [target] keeps [target.p_their()] footing!"

/datum/horny_family_profile/humanoids/get_bark(mob/living/hunter, mob/living/target, context)
	switch(context)
		if(HORNY_BARK_NOTICE)
			return pick("Well, well.", "Hey there.", "Look what wandered in.", "Come here, you.")
		if(HORNY_BARK_SEIZE)
			return pick("Got you!", "Hold still!", "No running now.", "Down you go.")
		if(HORNY_BARK_BREAK_OFF)
			return pick("Feisty one!", "You'll pay for that.", "Oh, you want it rough?")
		if(HORNY_BARK_PRESENT)
			return pick("Ah...!", "W-wait...", "Too... too much.")
		if(HORNY_BARK_SATED)
			return pick("Heh.", "Not bad.", "That'll do.", "Run along now.")
		if(HORNY_BARK_LOST)
			return pick("Bah!", "Get back here!", "Next time...")
		if(HORNY_BARK_ACT_START)
			return pick("Hold still.", "There we go.", "Take it.")
		if(HORNY_BARK_ACT_CLIMAX)
			return pick("Nngh.", "Hah.", "Good.")
	return null

/datum/horny_family_profile/undead
	family_flag = HORNY_MOB_TYPE_UNDEAD
	pain_factor = 0
	hurt_limit = 2
	flee_limit = 2
	break_off = HORNY_BREAK_OFF_NONE
	notice_time = 0
	pack_call = TRUE
	pack_cap = 0

/datum/horny_family_profile/undead/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] turns its hollow gaze on [target] and starts toward [target.p_them()]."

/datum/horny_family_profile/undead/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] rattles and claws at the empty air, denied!"

/datum/horny_family_profile/undead/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] sags, its hunger dulled, and lets [target] be for now." : "[hunter] rattles with a hollow, satisfied sigh."

/datum/horny_family_profile/undead/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] rattles once and sags, hollow and still."

/datum/horny_family_profile/undead/get_pack_call_message(mob/living/hunter, mob/living/target)
	return "[hunter] lets out a long, hollow moan that carries far."

/datum/horny_family_profile/undead/get_pack_call_hear_message(mob/living/hunter)
	return "I hear a long, hollow moan."

/datum/horny_family_profile/lycans
	family_flag = HORNY_MOB_TYPE_LYCANS
	has_hands = FALSE
	hurt_limit = 0.4
	break_off = HORNY_BREAK_OFF_CIRCLE
	can_sprint = TRUE
	restraint_type = null
	seize_move = HORNY_MOVE_POUNCE
	bear_down_bonus = 20
	pounces = TRUE
	circles_behind = TRUE
	follows_scent = TRUE
	pack_call = TRUE
	tie_time = 90 SECONDS

/datum/horny_family_profile/lycans/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s ears prick toward [target] and its lips peel back from its teeth."

/datum/horny_family_profile/lycans/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] slams into [target] and pins [target.p_them()] in place!"

/datum/horny_family_profile/lycans/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] snarls and paws at the ground, clearly unsatisfied!"

/datum/horny_family_profile/lycans/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] huffs, spent, and lets [target] go for now." : "[hunter] pants and shakes itself out, satisfied."

/datum/horny_family_profile/lycans/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] yelps, shakes it off, and charges!"

/datum/horny_family_profile/lycans/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] backs off, hackles up, and begins to circle [target]."

/datum/horny_family_profile/lycans/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] drops onto its back with a whine, belly up and twitching."

/datum/horny_family_profile/lycans/get_pounce_message(mob/living/hunter, mob/living/target)
	return "[hunter] launches itself at [target], jaws wide!"

/datum/horny_family_profile/lycans/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] slams into [target] and bears [target.p_them()] down!"

/datum/horny_family_profile/lycans/get_pack_call_message(mob/living/hunter, mob/living/target)
	return "[hunter] throws its head back and howls!"

/datum/horny_family_profile/lycans/get_pack_call_hear_message(mob/living/hunter)
	return "I hear a howl."

/datum/horny_family_profile/lycans/get_tie_lines(mob/living/hunter, mob/living/target)
	return list(
		"tug" = "[hunter] growls and hauls on [target]'s hips, claws digging in, its knot locked deep inside [target.p_them()].",
		"tug_me" = "[hunter] growls and hauls on my hips, claws digging in, its knot locked deep inside me.",
		"tug_hear" = "I hear a low growl and claws scraping skin.",
		"release" = "[hunter]'s knot softens and it drags itself free of [target], growling.",
		"release_me" = "[hunter]'s knot softens and it drags itself free of me, growling.",
		"release_hear" = "I hear a wet pop and a low growl.",
	)

/datum/horny_family_profile/beasts
	family_flag = HORNY_MOB_TYPE_BEASTS
	has_hands = FALSE
	pain_factor = 1.2
	hurt_limit = 0.4
	break_off = HORNY_BREAK_OFF_CIRCLE
	strip_damage_chance = 60
	strip_damage_ratio = 0.25
	restraint_type = null
	seize_move = HORNY_MOVE_POUNCE
	bear_down_bonus = 20
	pounces = TRUE
	circles_behind = TRUE
	follows_scent = TRUE
	pack_call = TRUE
	tie_time = 60 SECONDS

/datum/horny_family_profile/beasts/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] lifts its head, nostrils flaring toward [target], and a low growl rolls out."

/datum/horny_family_profile/beasts/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] pins [target] in place with snapping jaws and brute weight!"

/datum/horny_family_profile/beasts/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] snarls and paws at the ground, clearly unsatisfied!"

/datum/horny_family_profile/beasts/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] huffs, spent, and lets [target] go for now." : "[hunter] pants and shakes itself out, satisfied."

/datum/horny_family_profile/beasts/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] yelps, shakes it off, and charges!"

/datum/horny_family_profile/beasts/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] backs off, hackles up, and begins to circle [target]."

/datum/horny_family_profile/beasts/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] rolls onto its back with a whine, belly up and twitching."

/datum/horny_family_profile/beasts/get_pounce_message(mob/living/hunter, mob/living/target)
	return "[hunter] launches itself at [target], jaws wide!"

/datum/horny_family_profile/beasts/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] slams into [target] and bears [target.p_them()] down!"

/datum/horny_family_profile/beasts/get_pack_call_message(mob/living/hunter, mob/living/target)
	return "[hunter] throws its head back and howls!"

/datum/horny_family_profile/beasts/get_pack_call_hear_message(mob/living/hunter)
	return "I hear a howl."

/datum/horny_family_profile/beasts/get_tie_lines(mob/living/hunter, mob/living/target)
	return list(
		"tug" = "[hunter] shifts its weight, its knot dragging inside [target].",
		"tug_me" = "[hunter] shifts its weight, its knot dragging inside me.",
		"tug_hear" = "I hear panting and a whine.",
		"release" = "[hunter]'s knot goes slack and it pulls free of [target] with a wet pop.",
		"release_me" = "[hunter]'s knot goes slack and it pulls free of me with a wet pop.",
		"release_hear" = "I hear a wet pop and a satisfied huff.",
	)

/datum/horny_family_profile/spiders
	family_flag = HORNY_MOB_TYPE_SPIDERS
	has_hands = FALSE
	pain_factor = 1.5
	hurt_limit = 0.3
	break_off = HORNY_BREAK_OFF_FLEE
	// Fangs and legs make short work of clothes: spiders keep tearing well past the first piece.
	extra_strip_chance = 60
	restraint_type = /obj/item/rope/spider_silk
	seize_move = HORNY_MOVE_POUNCE
	bear_down_bonus = 15
	pounces = TRUE
	spits_web = TRUE
	// Silk goes on in this order: mouth, eyes, wrists, then the thighs wound open.
	prep_step_types = list(
		/datum/horny_prep_step/disarm,
		/datum/horny_prep_step/strip,
		/datum/horny_prep_step/silk_gag,
		/datum/horny_prep_step/silk_blindfold,
		/datum/horny_prep_step/bind,
		/datum/horny_prep_step/silk_hobble,
	)

/// Spiders also lap at a wet hole; a beespider turns what it laps into honey.
/datum/horny_family_profile/spiders/add_act_choices(list/weighted_actions, mob/living/hunter, mob/living/target)
	..()
	if(target.getorganslot(ORGAN_SLOT_VAGINA) || target.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_spider_lap, 2)

/datum/horny_family_profile/spiders/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] turns all its eyes on [target]."

/datum/horny_family_profile/spiders/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] pins [target] down with its legs!"

/datum/horny_family_profile/spiders/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] clicks its mandibles and skitters in a circle!"

/datum/horny_family_profile/spiders/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] lets go of [target] and goes still." : "[hunter] settles down and chitters."

/datum/horny_family_profile/spiders/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] skitters sideways, then rushes in!"

/datum/horny_family_profile/spiders/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] skitters away from [target]."

/datum/horny_family_profile/spiders/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s legs fold and it lies still, chittering."

/datum/horny_family_profile/spiders/get_pounce_message(mob/living/hunter, mob/living/target)
	return "[hunter] jumps at [target]!"

/datum/horny_family_profile/spiders/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] drags [target] down with its legs!"

/datum/horny_family_profile/spiders/get_bind_lines(mob/living/hunter, mob/living/target)
	return list(
		"start" = "[hunter] starts to wind silk around [target]'s wrists!",
		"start_target" = "[hunter] starts to wind silk around my wrists!",
		"start_hear" = "I hear silk stretching.",
		"done" = "[hunter] binds [target]'s wrists with silk!",
		"done_target" = "[hunter] binds my wrists with silk!",
		"done_hear" = "I hear silk pulling tight.",
	)

/datum/horny_family_profile/bog_bugs
	family_flag = HORNY_MOB_TYPE_BOG_BUGS
	has_hands = FALSE
	pain_factor = 1.5
	hurt_limit = 0.3
	break_off = HORNY_BREAK_OFF_FLEE
	restraint_type = null
	seize_move = HORNY_MOVE_POUNCE
	bear_down_bonus = 10
	pounces = TRUE

/datum/horny_family_profile/bog_bugs/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s antennae swing toward [target] and its mandibles click."

/datum/horny_family_profile/bog_bugs/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] clamps onto [target], locking [target.p_them()] in place!"

/datum/horny_family_profile/bog_bugs/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] clicks its mandibles and skitters in a tight, frustrated circle!"

/datum/horny_family_profile/bog_bugs/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] goes still, sated, and lets [target] be for now." : "[hunter] settles with a satisfied chitter."

/datum/horny_family_profile/bog_bugs/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] skitters sideways, then rushes in!"

/datum/horny_family_profile/bog_bugs/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] scuttles back out of reach, mandibles working."

/datum/horny_family_profile/bog_bugs/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s legs fold under it and it lies there, chittering weakly."

/datum/horny_family_profile/bog_bugs/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] knocks [target] flat and clamps on!"

/datum/horny_family_profile/trolls
	family_flag = HORNY_MOB_TYPE_TROLLS
	pain_factor = 0.5
	hurt_limit = 0.6
	break_off = HORNY_BREAK_OFF_ENRAGE
	strip_damage_chance = 60
	strip_damage_ratio = 0.3
	restraint_type = null
	seize_move = HORNY_MOVE_HOIST
	bear_down_bonus = 20

/datum/horny_family_profile/trolls/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] snorts, sniffs the air, and turns its whole bulk toward [target]."

/datum/horny_family_profile/trolls/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] mauls [target] to the ground and keeps [target.p_them()] there!"

/datum/horny_family_profile/trolls/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] bellows and stamps the ground, clearly unsatisfied!"

/datum/horny_family_profile/trolls/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] grunts, spent, and shoves [target] aside for now." : "[hunter] grunts, content."

/datum/horny_family_profile/trolls/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] roars and barrels forward!"

/datum/horny_family_profile/trolls/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] bellows and comes on harder!"

/datum/horny_family_profile/trolls/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] sits down heavily, chest heaving, too far gone to hold on."

/datum/horny_family_profile/trolls/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] hoists [target] off the ground and slams [target.p_them()] down!"

/datum/horny_family_profile/trolls/get_bear_down_miss_message(mob/living/hunter, mob/living/target)
	return "[hunter] grabs for [target] and comes up with nothing but air!"

/datum/horny_family_profile/minotaurs
	family_flag = HORNY_MOB_TYPE_MINOTAURS
	pain_factor = 0.5
	hurt_limit = 0.6
	break_off = HORNY_BREAK_OFF_ENRAGE
	strip_damage_chance = 60
	strip_damage_ratio = 0.3
	restraint_type = null
	seize_move = HORNY_MOVE_HOIST
	bear_down_bonus = 20

/datum/horny_family_profile/minotaurs/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] stamps once and lowers its horns toward [target], breath steaming."

/datum/horny_family_profile/minotaurs/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] hooks [target] into a crushing hold and keeps [target.p_them()] pinned!"

/datum/horny_family_profile/minotaurs/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] bellows and stamps the ground, clearly unsatisfied!"

/datum/horny_family_profile/minotaurs/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] grunts, spent, and shoves [target] aside for now." : "[hunter] grunts, content."

/datum/horny_family_profile/minotaurs/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] roars and barrels forward!"

/datum/horny_family_profile/minotaurs/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] bellows and comes on harder!"

/datum/horny_family_profile/minotaurs/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] sits down heavily, chest heaving, too far gone to hold on."

/datum/horny_family_profile/minotaurs/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] hooks [target] up by the waist and slams [target.p_them()] into the ground!"

/datum/horny_family_profile/minotaurs/get_bear_down_miss_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s horns sweep past as [target] stumbles clear!"

/datum/horny_family_profile/lamias
	family_flag = HORNY_MOB_TYPE_LAMIAS
	has_hands = FALSE
	break_off = HORNY_BREAK_OFF_FLEE
	restraint_type = null
	seize_move = HORNY_MOVE_COIL
	squeeze_fatigue = 8

/datum/horny_family_profile/lamias/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s eyes catch the light as they settle on [target], tongue flicking."

/datum/horny_family_profile/lamias/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] coils tightly around [target], holding [target.p_them()] fast!"

/datum/horny_family_profile/lamias/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] hisses and lashes its tail, clearly unsatisfied!"

/datum/horny_family_profile/lamias/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] uncoils with a long, lazy hiss and releases [target] for now." : "[hunter] flicks its tongue, satisfied."

/datum/horny_family_profile/lamias/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] hisses and surges forward!"

/datum/horny_family_profile/lamias/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] uncoils and slips back toward the shadows."

/datum/horny_family_profile/lamias/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s coils go slack and it lies there, tongue lolling."

/datum/horny_family_profile/lamias/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s coils drag [target] down to the ground!"

/datum/horny_family_profile/lamias/get_bear_down_miss_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s coils tighten, but [target] stays on [target.p_their()] feet!"

/datum/horny_family_profile/lizards
	family_flag = HORNY_MOB_TYPE_LIZARDS
	has_hands = FALSE
	pain_factor = 0.8
	break_off = HORNY_BREAK_OFF_CIRCLE
	restraint_type = null
	seize_move = HORNY_MOVE_POUNCE
	bear_down_bonus = 20
	pounces = TRUE
	circles_behind = TRUE

/datum/horny_family_profile/lizards/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes very still, then its jaws part toward [target]."

/datum/horny_family_profile/lizards/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] hisses and lashes its tail, clearly unsatisfied!"

/datum/horny_family_profile/lizards/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] uncoils with a long, lazy hiss and releases [target] for now." : "[hunter] flicks its tongue, satisfied."

/datum/horny_family_profile/lizards/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] hisses and surges forward!"

/datum/horny_family_profile/lizards/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] slides back, jaws open, waiting."

/datum/horny_family_profile/lizards/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes limp, jaws slack, tail twitching."

/datum/horny_family_profile/lizards/get_pounce_message(mob/living/hunter, mob/living/target)
	return "[hunter] lunges at [target] with a snap of its jaws!"

/datum/horny_family_profile/lizards/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter] drags [target] down in a thrashing roll!"

/datum/horny_family_profile/tentacles
	family_flag = HORNY_MOB_TYPE_TENTACLES
	pain_factor = 0.3
	hurt_limit = 0.6
	break_off = HORNY_BREAK_OFF_SINK
	extra_strip_chance = 20
	restraint_type = /obj/item/rope/spider_silk/tentacle_resin
	seize_move = HORNY_MOVE_COIL
	squeeze_fatigue = 8
	lashes = TRUE

/datum/horny_family_profile/tentacles/get_notice_message(mob/living/hunter, mob/living/target)
	return "Something beneath the loam shifts and strains toward [target]."

/datum/horny_family_profile/tentacles/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] coils around [target]'s limbs and pins [target.p_them()] beneath its weight!"

/datum/horny_family_profile/tentacles/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] writhes and coils in on itself, thwarted!"

/datum/horny_family_profile/tentacles/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] slackens, its coils going limp as it releases [target] for now." : "[hunter] ripples with a slow, satisfied shudder."

/datum/horny_family_profile/tentacles/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] recoils, then lashes forward!"

/datum/horny_family_profile/tentacles/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] shudders and sinks back toward the earth."

/datum/horny_family_profile/tentacles/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes slack all at once, every tentacle drooping."

/datum/horny_family_profile/tentacles/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s coils drag [target] down to the ground!"

/datum/horny_family_profile/tentacles/get_bear_down_miss_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s coils tighten, but [target] stays on [target.p_their()] feet!"

/datum/horny_family_profile/tentacles/get_bind_lines(mob/living/hunter, mob/living/target)
	return list(
		"start" = "[hunter] starts winding sticky resin around [target]'s wrists!",
		"start_target" = "[hunter] starts winding sticky resin around my wrists!",
		"start_hear" = "I hear wet strands stretching tight.",
		"done" = "[hunter] binds [target]'s wrists in clinging resin!",
		"done_target" = "[hunter] binds my wrists in clinging resin!",
		"done_hear" = "I hear resin tightening around someone's wrists.",
	)

/datum/horny_family_profile/tentacles/add_act_choices(list/weighted_actions, mob/living/hunter, mob/living/target)
	// A burrow tentacle's kind may pick its own acts; only an ovipositor kind reaches the egg acts.
	var/datum/tentacle_kind/kind = get_tentacle_kind_of(hunter)
	if(kind?.add_act_choices(src, weighted_actions, hunter, target))
		return
	if(add_egg_act_choices(weighted_actions, hunter, target))
		return
	if(hunter.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex/tentacle, 2)
		if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex/tentacle, 2)
		if(target.getorganslot(ORGAN_SLOT_VAGINA) && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex/tentacle, 3)
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/tentacle_jerk, 2)

/datum/horny_family_profile/maneaters
	family_flag = HORNY_MOB_TYPE_MANEATERS
	pain_factor = 0.3
	hurt_limit = 0.6
	break_off = HORNY_BREAK_OFF_SINK
	extra_strip_chance = 20
	restraint_type = /obj/item/rope/spider_silk/tentacle_resin
	seize_move = HORNY_MOVE_COIL
	squeeze_fatigue = 8
	lashes = TRUE

/datum/horny_family_profile/maneaters/get_notice_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s vines rustle and lean toward [target], petals parting."

/datum/horny_family_profile/maneaters/get_hold_message(mob/living/hunter, mob/living/target)
	return "[hunter] knots its thorny vines around [target] and pins [target.p_them()] against the loam!"

/datum/horny_family_profile/maneaters/get_unsatisfied_message(mob/living/hunter)
	return "[hunter] writhes and coils in on itself, thwarted!"

/datum/horny_family_profile/maneaters/get_sated_message(mob/living/hunter, mob/living/target, heavy = FALSE)
	return heavy ? "[hunter] slackens, its coils going limp as it releases [target] for now." : "[hunter] ripples with a slow, satisfied shudder."

/datum/horny_family_profile/maneaters/get_flinch_message(mob/living/hunter, atom/source)
	return "[hunter] recoils, then lashes forward!"

/datum/horny_family_profile/maneaters/get_break_off_message(mob/living/hunter, mob/living/target)
	return "[hunter] shudders and sinks back toward the earth."

/datum/horny_family_profile/maneaters/get_present_message(mob/living/hunter, mob/living/target)
	return "[hunter] goes slack all at once, every vine drooping."

/datum/horny_family_profile/maneaters/get_bear_down_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s vines knot around [target] and drag [target.p_them()] down to the loam!"

/datum/horny_family_profile/maneaters/get_bear_down_miss_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s vines snag at [target], who tears free!"

/datum/horny_family_profile/maneaters/get_lash_message(mob/living/hunter, mob/living/target)
	return "[hunter]'s vines whip out and haul [target] a step closer!"

/datum/horny_family_profile/maneaters/get_bind_lines(mob/living/hunter, mob/living/target)
	return list(
		"start" = "[hunter] starts winding sticky resin around [target]'s wrists!",
		"start_target" = "[hunter] starts winding sticky resin around my wrists!",
		"start_hear" = "I hear wet strands stretching tight.",
		"done" = "[hunter] binds [target]'s wrists in clinging resin!",
		"done_target" = "[hunter] binds my wrists in clinging resin!",
		"done_hear" = "I hear resin tightening around someone's wrists.",
	)

/datum/horny_family_profile/maneaters/add_act_choices(list/weighted_actions, mob/living/hunter, mob/living/target)
	if(add_egg_act_choices(weighted_actions, hunter, target))
		return
	if(hunter.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_throat_sex/tentacle/maneater, 2)
		if(npc_penetration_can_fit(hunter, target, ORGAN_SLOT_ANUS))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_anal_sex/tentacle/maneater, 2)
		if(target.getorganslot(ORGAN_SLOT_VAGINA) && npc_penetration_can_fit(hunter, target, ORGAN_SLOT_VAGINA))
			add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater, 3)
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/tentacle_jerk/maneater, 2)

// --- Act words ----------------------------------------------------------------------------------

/datum/horny_family_profile/undead/get_act_words(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return list(
		"part" = "cold cock",
		"article" = their,
		"their" = their,
		"them" = user.p_them(),
		"body" = "hips",
		"mount" = "lurches on top and pushes",
		"thrusts" = list("works", "grinds", "fucks"),
		"tied" = list("room" = "grinds [their] swollen knot deeper into", "me" = "grinds [their] swollen knot deeper into me"),
		"hold" = "locks cold hands on [target]'s hips",
		"body_tails" = list(
			list("id" = "cold_hands", "room" = ", cold hands locked on [target]'s hips", "me" = ", cold hands locked on my hips"),
			list("id" = "no_breath", "room" = ", no breath on [target]'s neck", "me" = ", no breath on my neck"),
		),
		"spill" = "jerks and goes still",
		"spill_room" = "spilling cold seed",
		"spill_me" = "cold seed spills",
		"hear" = "dry rasping",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and a dry rasp",
			"anal" = "a strangled grunt and a dry rasp",
			"throat" = "choking and a dry rasp",
			"ride" = "a low moan and a dry rattle",
			"facesitting" = "muffled sounds and a dry rasp",
			"handjob" = "skin sliding on cold skin",
			"jerk_over" = "quick strokes and a dry rasp",
			"body_rub" = "cold skin dragging on skin",
		),
	)

/datum/horny_family_profile/lycans/get_act_words(mob/living/user, mob/living/target)
	return list(
		"part" = "cock",
		"article" = "its",
		"their" = "its",
		"them" = "it",
		"body" = "haunches",
		"mount" = "rears up and drives",
		"start_vaginal" = list("room" = "[user] mounts [target] from behind and drives its cock into [target.p_their()] %HOLE%!", "me" = "[user] mounts me from behind and drives into my %HOLE%!"),
		"thrusts" = list("drives", "ruts", "hammers"),
		"tied" = list("room" = "growls and hauls back on its swollen knot, buried in", "me" = "growls and hauls back on its swollen knot, buried in me"),
		"hold" = "sinks its claws into [target]'s hips",
		"body_tails" = list(
			list("id" = "claws", "room" = ", claws pricking [target]'s hips", "me" = ", claws pricking my hips"),
			list("id" = "fur", "room" = ", coarse fur scraping [target]'s back", "me" = ", coarse fur scraping my back"),
		),
		"spill" = "buries itself to the root",
		"spill_room" = "flooding",
		"spill_me" = "heat floods",
		"hear" = "a rising growl",
		"hear_acts" = list(
			"vaginal" = "a sharp yelp and a rising growl",
			"anal" = "a strangled grunt and a growl",
			"throat" = "choking and a low growl",
			"ride" = "a low moan and a growl",
			"facesitting" = "muffled sounds and panting",
			"handjob" = "a growl and skin on fur",
			"jerk_over" = "panting and quick, wet strokes",
			"body_rub" = "fur dragging on skin",
		),
	)

/datum/horny_family_profile/beasts/get_act_words(mob/living/user, mob/living/target)
	return list(
		"part" = "cock",
		"article" = "its",
		"their" = "its",
		"them" = "it",
		"body" = "haunches",
		"mount" = "rears up and drives",
		"start_vaginal" = list("room" = "[user] mounts [target] from behind and thrusts its cock into [target.p_their()] %HOLE%!", "me" = "[user] mounts me from behind and thrusts into my %HOLE%!"),
		"thrusts" = list("hammers", "ruts", "humps"),
		"tied" = list("room" = "humps in short jerks, its knot swollen fat inside", "me" = "humps in short jerks, its knot swollen fat inside me"),
		"hold" = "plants its forepaws on [target]'s back",
		"body_tails" = list(
			list("id" = "forepaws", "room" = ", forepaws planted on [target]'s back", "me" = ", forepaws planted on my back"),
			list("id" = "jaws", "room" = ", its jaws closed on [target]'s shoulder", "me" = ", its jaws closed on my shoulder"),
		),
		"spill" = "slams in and locks tight",
		"spill_room" = "pumping",
		"spill_me" = "heat pumps",
		"hear" = "growling and panting",
		"hear_acts" = list(
			"vaginal" = "a sharp yelp and panting",
			"anal" = "a strangled grunt and growling",
			"throat" = "choking and panting",
			"ride" = "a low moan and panting",
			"facesitting" = "muffled sounds and panting",
			"handjob" = "panting and skin on fur",
			"jerk_over" = "panting and quick, wet strokes",
			"body_rub" = "fur dragging on skin",
		),
	)

/datum/horny_family_profile/spiders/get_act_words(mob/living/user, mob/living/target)
	return list(
		"part" = "cock",
		"article" = "its",
		"their" = "its",
		"them" = "it",
		"body" = "abdomen",
		"mount" = "climbs on and pushes",
		"start_vaginal" = list("room" = "[user] climbs onto [target] and pushes its cock into [target.p_their()] %HOLE%!", "me" = "[user] climbs onto me and pushes its cock into my %HOLE%!"),
		"start_anal" = list("room" = "[user] climbs onto [target] from behind and pushes its cock into [target.p_their()] %HOLE%!", "me" = "[user] climbs onto me from behind and pushes its cock into my %HOLE%!"),
		"start_throat" = list("room" = "[user] pins [target]'s head with its legs and pushes its cock down [target.p_their()] %HOLE%!", "me" = "[user] pins my head with its legs and pushes its cock down my %HOLE%!"),
		"thrusts" = list("pumps", "works", "fucks"),
		"tied" = list("room" = "grinds its knot deeper into", "me" = "grinds its knot deeper into me"),
		"hold" = "wraps its legs around [target]",
		"body_tails" = list(
			list("id" = "legs", "room" = ", its legs locked around [target]", "me" = ", its legs locked around me"),
			list("id" = "mandibles", "room" = ", its mandibles clicking at [target]'s ear", "me" = ", its mandibles clicking at my ear"),
		),
		"spill" = "goes rigid",
		"spill_room" = "pumping seed",
		"spill_me" = "seed pumps",
		"hear" = "chittering",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and chittering",
			"anal" = "a strangled grunt and chittering",
			"throat" = "choking and chittering",
			"ride" = "a low moan and chittering",
			"facesitting" = "muffled sounds and chittering",
			"handjob" = "chittering and skin on chitin",
			"jerk_over" = "chittering and quick, wet strokes",
			"body_rub" = "chitin dragging on skin",
		),
	)

/datum/horny_family_profile/bog_bugs/get_act_words(mob/living/user, mob/living/target)
	return list(
		"part" = "cock",
		"article" = "its",
		"their" = "its",
		"them" = "it",
		"body" = "abdomen",
		"mount" = "clamps on and jabs",
		"thrusts" = list("jabs", "pumps", "fucks"),
		"tied" = list("room" = "grinds its swollen knot deeper into", "me" = "grinds its swollen knot deeper into me"),
		"hold" = "clamps its forelegs around [target]'s waist",
		"body_tails" = list(
			list("id" = "forelegs", "room" = ", forelegs clamped around [target]'s waist", "me" = ", forelegs clamped around my waist"),
			list("id" = "antennae", "room" = ", antennae twitching against [target]'s neck", "me" = ", antennae twitching against my neck"),
		),
		"spill" = "clamps tight and shudders",
		"spill_room" = "pulsing seed",
		"spill_me" = "seed pulses",
		"hear" = "clicking",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and clicking",
			"anal" = "a strangled grunt and clicking",
			"throat" = "choking and clicking",
			"ride" = "a low moan and clicking",
			"facesitting" = "muffled sounds and clicking",
			"handjob" = "clicking and skin on chitin",
			"jerk_over" = "clicking and quick, wet strokes",
			"body_rub" = "chitin dragging on skin",
		),
	)

/datum/horny_family_profile/trolls/get_act_words(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return list(
		"part" = "thick cock",
		"article" = their,
		"their" = their,
		"them" = user.p_them(),
		"body" = "hips",
		"mount" = "bears down and forces",
		"thrusts" = list("pumps", "ruts", "pounds"),
		"tied" = list("room" = "grinds [their] swollen knot deeper into", "me" = "grinds [their] swollen knot deeper into me"),
		"hold" = "pins [target] under [their] bulk",
		"body_tails" = list(
			list("id" = "bulk", "room" = ", [their] bulk crushing [target] into the ground", "me" = ", [their] bulk crushing me into the ground"),
			list("id" = "ground", "room" = ", the ground thudding under the weight", "me" = ", the ground thudding under me"),
		),
		"spill" = "roars and slams in deep",
		"spill_room" = "flooding",
		"spill_me" = "heat floods",
		"hear" = "heavy grunts",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and heavy grunts",
			"anal" = "a strangled cry and heavy grunts",
			"throat" = "choking and heavy grunts",
			"ride" = "a low moan and heavy grunts",
			"facesitting" = "muffled sounds and heavy grunts",
			"handjob" = "heavy grunts and skin on skin",
			"jerk_over" = "heavy grunts and wet strokes",
			"body_rub" = "skin dragging on hide",
		),
	)

/datum/horny_family_profile/minotaurs/get_act_words(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return list(
		"part" = "thick cock",
		"article" = their,
		"their" = their,
		"them" = user.p_them(),
		"body" = "hips",
		"mount" = "bears down and rams",
		"thrusts" = list("pumps", "drives", "pounds"),
		"tied" = list("room" = "grinds [their] swollen knot deeper into", "me" = "grinds [their] swollen knot deeper into me"),
		"hold" = "hooks an arm around [target]'s waist",
		"body_tails" = list(
			list("id" = "hooves", "room" = ", hooves scraping the stone", "me" = ", hooves scraping the stone beside me"),
			list("id" = "snort", "room" = ", a hot snort against [target]'s neck", "me" = ", a hot snort against my neck"),
		),
		"spill" = "bellows and slams in deep",
		"spill_room" = "flooding",
		"spill_me" = "heat floods",
		"hear" = "hooves on stone",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and a snort",
			"anal" = "a strangled cry and a snort",
			"throat" = "choking and a snort",
			"ride" = "a low moan and hooves on stone",
			"facesitting" = "muffled sounds and a snort",
			"handjob" = "a snort and skin on skin",
			"jerk_over" = "snorting and quick, wet strokes",
			"body_rub" = "hide dragging on skin",
		),
	)

/datum/horny_family_profile/lamias/get_act_words(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return list(
		"part" = "cock",
		"article" = their,
		"their" = their,
		"them" = user.p_them(),
		"body" = "coils",
		"mount" = "coils close and sinks",
		"start_vaginal" = list("room" = "[user] coils around [target] and sinks [their] cock into [target.p_their()] %HOLE%!", "me" = "[user] coils around me and sinks into my %HOLE%!"),
		"start_throat" = list("room" = "[user] coils around [target] and sinks [their] cock down [target.p_their()] throat!", "me" = "[user] coils around me and sinks [their] cock down my throat!"),
		"thrusts" = list("works", "grinds", "fucks"),
		"tied" = list("room" = "grinds [their] swollen knot deeper into", "me" = "grinds [their] swollen knot deeper into me"),
		"hold" = "draws [their] coils tight around [target]",
		"body_tails" = list(
			list("id" = "coils", "room" = ", coils tightening around [target]", "me" = ", coils tightening around me"),
			list("id" = "scales", "room" = ", cool scales sliding over [target]'s thighs", "me" = ", cool scales sliding over my thighs"),
		),
		"spill" = "locks [their] coils tight",
		"spill_room" = "flooding",
		"spill_me" = "heat floods",
		"hear" = "scales rasping",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and scales rasping",
			"anal" = "a strangled grunt and scales rasping",
			"throat" = "choking and a hiss",
			"ride" = "a low moan and scales rasping",
			"facesitting" = "muffled sounds and a hiss",
			"handjob" = "scales rasping on skin",
			"jerk_over" = "a hiss and quick, wet strokes",
			"body_rub" = "scales dragging on skin",
		),
	)

/datum/horny_family_profile/lizards/get_act_words(mob/living/user, mob/living/target)
	return list(
		"part" = "cock",
		"article" = "its",
		"their" = "its",
		"them" = "it",
		"body" = "haunches",
		"mount" = "crawls on top and pushes",
		"thrusts" = list("pumps", "ruts", "humps"),
		"tied" = list("room" = "grinds its swollen knot deeper into", "me" = "grinds its swollen knot deeper into me"),
		"hold" = "pins [target] under its scaly weight",
		"body_tails" = list(
			list("id" = "tail", "room" = ", its tail lashing behind it", "me" = ", its tail lashing behind me"),
			list("id" = "claws", "room" = ", claws raking the dirt beside [target]", "me" = ", claws raking the dirt beside me"),
		),
		"spill" = "hisses and shoves in deep",
		"spill_room" = "flooding",
		"spill_me" = "heat floods",
		"hear" = "hissing",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and hissing",
			"anal" = "a strangled grunt and hissing",
			"throat" = "choking and hissing",
			"ride" = "a low moan and hissing",
			"facesitting" = "muffled sounds and hissing",
			"handjob" = "hissing and skin on scales",
			"jerk_over" = "hissing and quick, wet strokes",
			"body_rub" = "scales dragging on skin",
		),
	)

/datum/horny_family_profile/tentacles/get_act_words(mob/living/user, mob/living/target)
	var/list/words = list(
		"part" = "slick tentacle",
		"article" = "a",
		"their" = "its",
		"them" = "it",
		"body" = "coils",
		"mount" = "pushes",
		"start_vaginal" = list("room" = "[user] pushes a slick tentacle into [target]'s %HOLE%!", "me" = "[user] pushes a slick tentacle into my %HOLE%!"),
		"thrusts" = list("pumps", "writhes", "fucks"),
		"tied" = list("room" = "grinds its swollen knot deeper into", "me" = "grinds its swollen knot deeper into me"),
		"hold" = "winds more tentacles around [target]'s limbs",
		"body_tails" = list(
			list("id" = "limbs", "room" = ", more tentacles winding [target]'s limbs", "me" = ", more tentacles winding my limbs"),
			list("id" = "slime", "room" = ", slime dripping down [target]'s thighs", "me" = ", slime dripping down my thighs"),
		),
		"spill" = "swells deep inside",
		"spill_room" = "pulsing thick fluid",
		"spill_me" = "thick fluid pulses",
		"hear" = "wet writhing",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and wet writhing",
			"anal" = "a strangled grunt and wet writhing",
			"throat" = "choking and wet writhing",
			"ride" = "a low moan and wet writhing",
			"facesitting" = "muffled sounds and wet writhing",
			"handjob" = "wet writhing and slick strokes",
			"jerk_over" = "wet writhing and slick strokes",
			"body_rub" = "slime dragging on skin",
		),
	)
	// Burrow tentacle kinds swap in words of their own: feelers, beads, a pointed head.
	var/datum/tentacle_kind/kind = get_tentacle_kind_of(user)
	kind?.adjust_act_words(words, user, target)
	return words

/datum/horny_family_profile/maneaters/get_act_words(mob/living/user, mob/living/target)
	return list(
		"part" = "flowering vine",
		"article" = "a",
		"their" = "its",
		"them" = "it",
		"body" = "vines",
		"mount" = "winds close and pushes",
		"thrusts" = list("roots", "works", "fucks"),
		"tied" = list("room" = "grinds its swollen knot deeper into", "me" = "grinds its swollen knot deeper into me"),
		"hold" = "knots its vines around [target]",
		"body_tails" = list(
			list("id" = "vines", "room" = ", vines knotted around [target]", "me" = ", vines knotted around me"),
			list("id" = "sap", "room" = ", warm sap dripping down [target]'s thighs", "me" = ", warm sap dripping down my thighs"),
		),
		"spill" = "swells and pulses",
		"spill_room" = "spilling warm sap and seed",
		"spill_me" = "warm sap and seed spill",
		"hear" = "leaves rustling",
		"hear_acts" = list(
			"vaginal" = "a sharp gasp and leaves rustling",
			"anal" = "a strangled grunt and leaves rustling",
			"throat" = "choking and leaves rustling",
			"ride" = "a low moan and leaves rustling",
			"facesitting" = "muffled sounds and leaves rustling",
			"handjob" = "leaves rustling and slick strokes",
			"jerk_over" = "leaves rustling and slick strokes",
			"body_rub" = "sap-slick vines dragging on skin",
		),
	)
