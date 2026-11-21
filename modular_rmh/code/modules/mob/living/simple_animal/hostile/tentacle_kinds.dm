// Tentacle kinds: the shape and the abilities of a small or medium burrow tentacle.

GLOBAL_LIST_EMPTY(tentacle_kinds)

/// The singleton of a tentacle kind type, built on first use; null for a bad path.
/proc/get_tentacle_kind_singleton(kind_type)
	if(!ispath(kind_type, /datum/tentacle_kind))
		return null
	var/datum/tentacle_kind/kind = GLOB.tentacle_kinds[kind_type]
	if(!kind)
		kind = new kind_type
		GLOB.tentacle_kinds[kind_type] = kind
	return kind

/// The kind of a burrow tentacle, or null for any other mob.
/proc/get_tentacle_kind_of(mob/living/user)
	var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle = user
	if(!istype(tentacle))
		return null
	return tentacle.get_tentacle_kind()

/// The shape and abilities of one burrow tentacle: look, organs, acts and act words. Singleton, keeps no mob refs.
/datum/tentacle_kind
	/// Name while up; null keeps the size's own name.
	var/name
	/// Description while up; null keeps the size's own description.
	var/desc
	/// Sheet state prefix for the living, dead and hide states; null keeps the size's own states.
	var/state_prefix
	/// Penis organ this kind grows; null grows none.
	var/organ_type
	/// Name given to the organ; null keeps the organ's own.
	var/organ_name
	/// Description given to the organ; null keeps the organ's own.
	var/organ_desc
	/// Grows the tentacle ovipositor with tentacle eggs instead of organ_type.
	var/lays_eggs = FALSE
	/// Keeps testicles, so climaxes spill fluid and knots can tie; FALSE removes them.
	var/has_seed = TRUE
	/// Dry climax line with %SRC% for the tentacle; null keeps the default line.
	var/dry_climax_text

/// Sets the look and the organs of [tentacle]; the tentacle has not hidden yet.
/datum/tentacle_kind/proc/apply_to(mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/tentacle)
	if(name)
		tentacle.name = name
		tentacle.real_name = name
	if(desc)
		tentacle.desc = desc
	if(state_prefix)
		tentacle.icon_state = state_prefix
		tentacle.icon_living = state_prefix
		tentacle.icon_dead = "[state_prefix]_dead"
		tentacle.hide_icon_state = "[state_prefix]_hide_on"
		tentacle.emerge_icon_state = "[state_prefix]_hide_off"
	give_organs(tentacle)

/// Gives [owner] this kind's organs; a penis of another type comes out first. Safe to call again.
/datum/tentacle_kind/proc/give_organs(mob/living/owner)
	var/obj/item/organ/genitals/penis/current_penis = owner.getorganslot(ORGAN_SLOT_PENIS)
	if(lays_eggs)
		var/obj/item/organ/genitals/penis/ovipositor/ovipositor = ensure_tentacle_ovipositor(owner)
		if(ovipositor)
			ovipositor.name = organ_name || "egg-bearing tentacle"
			ovipositor.desc = organ_desc || "A sensitive, prehensile tentacle adapted to carry and lay soft eggs."
	else
		if(current_penis && (!organ_type || current_penis.type != organ_type))
			current_penis.Remove(owner, FALSE, FALSE)
			qdel(current_penis)
			current_penis = null
		if(organ_type && !current_penis)
			var/obj/item/organ/genitals/penis/penis = new organ_type
			if(organ_name)
				penis.name = organ_name
			if(organ_desc)
				penis.desc = organ_desc
			penis.Insert(owner, FALSE, FALSE)
	var/obj/item/organ/genitals/filling_organ/testicles/testicles = owner.getorganslot(ORGAN_SLOT_TESTICLES)
	if(has_seed && !testicles)
		testicles = new /obj/item/organ/genitals/filling_organ/testicles/invisible
		testicles.organ_size = rand(owner.ball_min, owner.ball_max)
		testicles.Insert(owner, TRUE)
	else if(!has_seed && testicles)
		testicles.Remove(owner, FALSE, FALSE)
		qdel(testicles)

/// Adds this kind's acts; TRUE when it chose them all, FALSE to use the family's own list.
/datum/tentacle_kind/proc/add_act_choices(datum/horny_family_profile/profile, list/weighted_actions, mob/living/hunter, mob/living/target)
	return FALSE

/// Changes the family's act words in place for this kind.
/datum/tentacle_kind/proc/adjust_act_words(list/words, mob/living/user, mob/living/target)
	return

/// Own lines for a tentacle jerk beat (start, middle, climax, victim climax, finish), or null for the default.
/datum/tentacle_kind/proc/get_jerk_lines(datum/sex_action/action, beat, mob/living/hunter, mob/living/victim)
	return null

/// Today's burrow tentacle without eggs: a plain tentacle cock.
/datum/tentacle_kind/plain
	organ_type = /obj/item/organ/genitals/penis/tentacle
	organ_name = "slick tentacle"
	organ_desc = "A slick, prehensile tentacle that pushes into whatever hole it finds."

/// Rubs the victim all over and strokes a cock; never penetrates and has no cock of its own.
/datum/tentacle_kind/feeler
	name = "feeler tentacle"
	desc = "A cluster of thin feelers that fan out from one hole and reach for bare skin. It rubs and strokes, but never goes inside."
	state_prefix = "tentacle_feeler"
	has_seed = FALSE
	dry_climax_text = "%SRC% shivers along every feeler and drips slime."

/datum/tentacle_kind/feeler/add_act_choices(datum/horny_family_profile/profile, list/weighted_actions, mob/living/hunter, mob/living/target)
	add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/npc/npc_feeler_caress, 3)
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		add_weighted_horny_ai_choice(weighted_actions, /datum/sex_action/tentacle_jerk, 2)
	return TRUE

/datum/tentacle_kind/feeler/adjust_act_words(list/words, mob/living/user, mob/living/target)
	words["part"] = "bundle of feelers"
	words["body"] = "feelers"
	words["hold"] = "winds thin feelers around [target]'s limbs"
	words["hear"] = "slick feelers sliding over skin"
	var/list/sounds = words["hear_acts"]
	sounds["body_rub"] = "slick feelers sliding over skin"
	sounds["caress"] = "slick feelers sliding over skin"
	sounds["handjob"] = "slick feelers stroking skin"

/datum/tentacle_kind/feeler/get_jerk_lines(datum/sex_action/action, beat, mob/living/hunter, mob/living/victim)
	var/hear = "I hear slick feelers stroking skin."
	switch(beat)
		if("start")
			return list("room" = "[hunter] wraps a bundle of thin feelers around [victim]'s cock.", "me" = "[hunter] wraps a bundle of thin feelers around my cock.", "hear" = hear)
		if("middle")
			return list("room" = "[hunter] [action.get_generic_force_adjective()] strokes [victim]'s cock with a ripple of thin feelers.", "me" = "[hunter] strokes my cock with a ripple of thin feelers.", "hear" = hear)
		if("climax")
			return list("room" = "[hunter] shivers, its feelers squeezing [victim]'s cock!", "me" = "[hunter] shivers, its feelers squeezing my cock!", "hear" = hear)
		if("victim climax")
			return list("room" = "[victim] bucks and spills over [hunter]'s feelers!", "me" = "I buck and spill over [hunter]'s feelers!", "hear" = "I hear slick feelers and a sharp gasp.")
		if("finish")
			return list("room" = "[hunter] lets its feelers slide off [victim]'s cock.", "me" = "[hunter] lets its feelers slide off my cock.", "hear" = hear)
	return null

/// Penetrates with a row of swellings and ties on climax through the knot component.
/datum/tentacle_kind/beaded
	name = "beaded tentacle"
	desc = "A thick tentacle with a row of round swellings along its length. The last one swells fat once it is inside."
	state_prefix = "tentacle_beaded"
	organ_type = /obj/item/organ/genitals/penis/knotted/tentacle_beads

/datum/tentacle_kind/beaded/adjust_act_words(list/words, mob/living/user, mob/living/target)
	words["part"] = "beaded tentacle"
	words["start_vaginal"] = list("room" = "[user] pushes a beaded tentacle into [target]'s %HOLE%, one swelling after another!", "me" = "[user] pushes a beaded tentacle into my %HOLE%, one swelling after another!")
	words["thrusts"] = list("pops its beads", "rocks", "fucks")
	words["tied"] = list("room" = "rocks its swollen last bead deeper into", "me" = "rocks its swollen last bead deeper into me")
	words["spill"] = "shoves its beads in deep and swells"
	var/list/sounds = words["hear_acts"]
	sounds["vaginal"] = "a sharp gasp and beads popping wetly"
	sounds["anal"] = "a strangled grunt and beads popping wetly"

/// The only kind that lays: an ovipositor with tentacle eggs, used after its ordinary act warms the victim.
/datum/tentacle_kind/egg_layer
	name = "ovipositor tentacle"
	desc = "A slim tentacle with a swollen, pointed head. Something round moves inside it."
	state_prefix = "tentacle_pointy"
	lays_eggs = TRUE

/datum/tentacle_kind/egg_layer/adjust_act_words(list/words, mob/living/user, mob/living/target)
	words["part"] = "pointed tentacle"
	words["start_vaginal"] = list("room" = "[user] works the pointed head of a tentacle into [target]'s %HOLE%!", "me" = "[user] works the pointed head of a tentacle into my %HOLE%!")
	words["thrusts"] = list("probes", "writhes", "fucks")
	words["spill"] = "swells at its pointed head"
	var/list/sounds = words["hear_acts"]
	sounds["vaginal"] = "a sharp gasp and a wet, swollen push"

/obj/item/organ/genitals/penis/knotted/tentacle_beads
	name = "beaded tentacle"
	desc = "A thick tentacle with round swellings along its length. The last one swells fat and locks it inside."
	sheath_type = SHEATH_TYPE_NONE

// --- The mob -------------------------------------------------------------------------------------

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher
	/// Kind type a mapper can force; it beats the roll.
	var/tentacle_kind_type
	/// Kind types and weights to roll from at spawn; empty means no kind.
	var/list/tentacle_kind_weights
	/// The applied kind singleton, or null.
	var/tmp/datum/tentacle_kind/tentacle_kind

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/medium
	tentacle_kind_weights = list(
		/datum/tentacle_kind/beaded = 35,
		/datum/tentacle_kind/egg_layer = 30,
		/datum/tentacle_kind/plain = 20,
		/datum/tentacle_kind/feeler = 15,
	)

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/small
	tentacle_kind_weights = list(
		/datum/tentacle_kind/feeler = 35,
		/datum/tentacle_kind/plain = 25,
		/datum/tentacle_kind/beaded = 20,
		/datum/tentacle_kind/egg_layer = 20,
	)

/// TRUE when Initialize will hand this tentacle a kind, so the base ovipositor is skipped.
/mob/living/simple_animal/hostile/retaliate/tentacle/proc/will_take_tentacle_kind()
	return FALSE

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/will_take_tentacle_kind()
	return !!(get_tentacle_kind_singleton(tentacle_kind_type) || length(tentacle_kind_weights))

/// Picks and applies this tentacle's kind. Called once from Initialize, before the tentacle hides.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/apply_tentacle_kind()
	var/datum/tentacle_kind/kind = get_tentacle_kind_singleton(tentacle_kind_type)
	if(!kind && length(tentacle_kind_weights))
		kind = get_tentacle_kind_singleton(pickweight(tentacle_kind_weights))
	if(!kind)
		return
	tentacle_kind = kind
	kind.apply_to(src)

/// The kind datum of this tentacle, or null.
/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/proc/get_tentacle_kind()
	return tentacle_kind

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/give_genitals()
	if(!tentacle_kind)
		return ..()
	tentacle_kind.give_organs(src)
	return TRUE

/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/get_dry_climax_message()
	if(tentacle_kind?.dry_climax_text)
		return replacetext(tentacle_kind.dry_climax_text, "%SRC%", "[src]")
	return ..()

// --- Feeler caress -------------------------------------------------------------------------------

/// A feeler tentacle rubbing the victim all over: breasts or chest, thighs and groin. Needs no organ.
/datum/sex_action/npc/npc_feeler_caress
	name = "Feeler caress"
	check_same_tile = FALSE

/datum/sex_action/npc/npc_feeler_caress/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_feeler_caress/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target)
		return FALSE
	if(!istype(user, /mob/living/simple_animal/hostile/retaliate/tentacle) || is_maneater_tendril(user))
		return FALSE
	return check_location_accessible(user, target, BODY_ZONE_CHEST)

/datum/sex_action/npc/npc_feeler_caress/on_start(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_start_lines(user, target), user, target, "warning")

/// The victim's chest word: breasts when they have them.
/datum/sex_action/npc/npc_feeler_caress/proc/get_chest_word(mob/living/target)
	return target.getorganslot(ORGAN_SLOT_BREASTS) ? "breasts" : "chest"

/// The victim's groin word: pussy, then cock, then groin.
/datum/sex_action/npc/npc_feeler_caress/proc/get_groin_word(mob/living/target)
	if(target.getorganslot(ORGAN_SLOT_VAGINA))
		return "pussy"
	if(target.getorganslot(ORGAN_SLOT_PENIS))
		return get_penis_word(target)
	return "groin"

/datum/sex_action/npc/npc_feeler_caress/compose_start_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	return act_lines(
		"[user] fans out its thin feelers and slides them over [target]'s bare skin.",
		"[user] fans out its thin feelers and slides them over my bare skin.",
		get_act_hear(words, "caress")
	)

/datum/sex_action/npc/npc_feeler_caress/on_perform(mob/living/user, mob/living/target)
	. = ..()
	act_cycles++
	if(can_show_action_message(user, target))
		show_perform_lines(user, target)
	playsound(target, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 2, 0, 2)
	perform_sex_action(user, target, 1.5, 0, 1.2)
	handle_passive_ejaculation(target)
	handle_passive_ejaculation()

/datum/sex_action/npc/npc_feeler_caress/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/list/words = get_act_words(user, target)
	var/hear = get_act_hear(words, "caress")
	switch(stage)
		if("opening")
			return act_lines("[user] spreads its feelers across [target]'s body, testing every inch.", "[user] spreads its feelers across my body, testing every inch.", hear)
		if("late")
			return act_lines("[user] rubs [target] all over faster, its feelers slick and quivering.", "[user] rubs me all over faster, its feelers slick and quivering.", hear)
	var/adverb = get_generic_force_adjective()
	switch(variant)
		if(1)
			var/chest = get_chest_word(target)
			return act_lines("[user] [adverb] rubs [target]'s [chest] with its feelers, the tips circling each nipple.", "[user] rubs my [chest] with its feelers, the tips circling each nipple.", hear)
		if(2)
			return act_lines("[user] [adverb] strokes the insides of [target]'s thighs with its feelers.", "[user] strokes the insides of my thighs with its feelers.", hear)
	var/groin = get_groin_word(target)
	return act_lines("[user] [adverb] works its feelers between [target]'s legs and rubs [target.p_their()] [groin].", "[user] works its feelers between my legs and rubs my [groin].", hear)

/datum/sex_action/npc/npc_feeler_caress/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		var/list/hunter_words = get_act_words(partner, climaxer)
		return act_lines("[climaxer] shudders and comes under [partner]'s rubbing feelers!", "I shudder and come under [partner]'s rubbing feelers!", get_act_hear(hunter_words, "caress"))
	var/list/words = get_act_words(climaxer, partner)
	return act_lines("[climaxer] shivers along every feeler and drips slime over [partner]'s skin!", "[climaxer] shivers along every feeler and drips slime over my skin!", get_act_hear(words, "caress"))

/datum/sex_action/npc/npc_feeler_caress/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	return null

/datum/sex_action/npc/npc_feeler_caress/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_feeler_caress/compose_finish_lines(mob/living/user, mob/living/target)
	var/list/words = get_act_words(user, target)
	return act_lines("[user] draws its feelers back from [target].", "[user] draws its feelers back from me.", get_act_hear(words, "caress"))
