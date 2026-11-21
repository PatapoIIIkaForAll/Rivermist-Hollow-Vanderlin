// The horny AI's acts for a skeleton with a funny bone; same mechanics as the flesh versions, bonier words.

/datum/sex_action/npc/npc_throat_sex/funny_bone
	name = "Rattle throat"

/datum/sex_action/npc/npc_throat_sex/funny_bone/compose_start_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] grabs [target]'s head and rattles [their] funny bone down [target.p_their()] throat!",
		"[user] grabs my head and rattles [their] funny bone down my throat!",
		"I hear a hollow clack and choking."
	)

/datum/sex_action/npc/npc_throat_sex/funny_bone/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/their = user.p_their()
	var/hear = "I hear a hollow clack and choking."
	switch(stage)
		if("opening")
			return act_lines("[user] rattles [their] funny bone down [target]'s throat.", "[user] rattles [their] funny bone down my throat.", hear)
		if("late")
			return act_lines("[user] rattles [their] funny bone down [target]'s throat, faster and faster.", "[user] rattles [their] funny bone down my throat, faster and faster.", hear)
	return act_lines("[user] [get_generic_force_adjective()] rattles [their] funny bone down [target]'s throat.", "[user] rattles [their] funny bone down my throat.", hear)

/datum/sex_action/npc/npc_throat_sex/funny_bone/compose_finish_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] pulls [their] funny bone out of [target]'s throat with a hollow clack.",
		"[user] pulls [their] funny bone out of my throat with a hollow clack.",
		"I hear a hollow clack."
	)

/datum/sex_action/npc/npc_throat_sex/funny_bone/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] shudders in orgasm with a funny bone rattling in [climaxer.p_their()] throat!",
			"I shudder in orgasm with a funny bone rattling in my throat!",
			"I hear a hollow clack and a muffled moan."
		)
	return act_lines(
		"[climaxer]'s funny bone clatters in [partner]'s throat, but nothing comes of it!",
		"[climaxer]'s funny bone clatters in my throat, but nothing comes of it!",
		"I hear a hollow clatter."
	)

/datum/sex_action/npc/npc_throat_sex/funny_bone/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		return ORGASM_LOCATION_SELF
	return ORGASM_LOCATION_SELF

/datum/sex_action/npc/npc_anal_sex/funny_bone
	name = "Rattle ass"

/datum/sex_action/npc/npc_anal_sex/funny_bone/compose_start_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] wedges [their] funny bone into [target]'s ass with a creak!",
		"[user] wedges [their] funny bone into my ass with a creak!",
		"I hear a creak and a strangled grunt."
	)

/datum/sex_action/npc/npc_anal_sex/funny_bone/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/their = user.p_their()
	var/hear = "I hear a hollow clack and a strangled grunt."
	switch(stage)
		if("opening")
			return act_lines("[user] rattles [their] funny bone in [target]'s ass.", "[user] rattles [their] funny bone in my ass.", hear)
		if("late")
			return act_lines("[user] rattles [their] funny bone in [target]'s ass, faster and faster.", "[user] rattles [their] funny bone in my ass, faster and faster.", hear)
	return act_lines("[user] [get_generic_force_adjective()] rattles [their] funny bone in [target]'s ass.", "[user] rattles [their] funny bone in my ass.", hear)

/datum/sex_action/npc/npc_anal_sex/funny_bone/compose_finish_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] pops [their] funny bone out of [target]'s butt.",
		"[user] pops [their] funny bone out of my butt.",
		"I hear a hollow pop."
	)

/datum/sex_action/npc/npc_anal_sex/funny_bone/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] cums with [climaxer.p_their()] butt from [partner]'s rattling funny bone!",
			"I cum with my butt from [partner]'s rattling funny bone!",
			"I hear a hollow clack and a shaky moan."
		)
	return act_lines(
		"[climaxer]'s funny bone clatters in [partner]'s butt, but nothing comes of it!",
		"[climaxer]'s funny bone clatters in my butt, but nothing comes of it!",
		"I hear a hollow clatter."
	)

/datum/sex_action/npc/npc_anal_sex/funny_bone/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_SELF
	return ORGASM_LOCATION_SELF

/datum/sex_action/npc/npc_vaginal_sex/funny_bone
	name = "Rattle cunt"

/datum/sex_action/npc/npc_vaginal_sex/funny_bone/compose_start_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] slides [their] funny bone into [target]'s cunt with a creak!",
		"[user] slides [their] funny bone into my cunt with a creak!",
		"I hear a creak and a sharp gasp."
	)

/datum/sex_action/npc/npc_vaginal_sex/funny_bone/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/their = user.p_their()
	var/hear = "I hear a hollow clack and a gasp."
	switch(stage)
		if("opening")
			return act_lines("[user] rattles [their] funny bone in [target]'s pussy.", "[user] rattles [their] funny bone in my pussy.", hear)
		if("late")
			return act_lines("[user] rattles [their] funny bone in [target]'s pussy, faster and faster.", "[user] rattles [their] funny bone in my pussy, faster and faster.", hear)
	return act_lines("[user] [get_generic_force_adjective()] rattles [their] funny bone in [target]'s pussy.", "[user] rattles [their] funny bone in my pussy.", hear)

/datum/sex_action/npc/npc_vaginal_sex/funny_bone/compose_finish_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] pulls [their] funny bone out of [target]'s pussy with a hollow clack.",
		"[user] pulls [their] funny bone out of my pussy with a hollow clack.",
		"I hear a hollow clack."
	)

/datum/sex_action/npc/npc_vaginal_sex/funny_bone/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] creams [climaxer.p_them()]self around [partner]'s funny bone!",
			"I cream myself around [partner]'s funny bone!",
			"I hear a hollow clack and a shaky moan."
		)
	return act_lines(
		"[climaxer]'s funny bone clatters in [partner]'s pussy, but nothing comes of it!",
		"[climaxer]'s funny bone clatters in my pussy, but nothing comes of it!",
		"I hear a hollow clatter."
	)

/datum/sex_action/npc/npc_vaginal_sex/funny_bone/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	if(must_flip)
		user.lose_virginity()
		target.lose_virginity()
		return ORGASM_LOCATION_ONTO
	return ORGASM_LOCATION_SELF

/datum/sex_action/npc/npc_jerk_over/funny_bone
	name = "Polish bone"

/datum/sex_action/npc/npc_jerk_over/funny_bone/compose_start_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] grips [their] funny bone and points it at [target].",
		"[user] grips [their] funny bone and points it at me.",
		"I hear a hollow clack."
	)

/datum/sex_action/npc/npc_jerk_over/funny_bone/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/their = user.p_their()
	var/hear = "I hear bone rubbing on bone."
	switch(stage)
		if("opening")
			return act_lines("[user] polishes [their] funny bone over [target].", "[user] polishes [their] funny bone over me.", hear)
		if("late")
			return act_lines("[user] polishes [their] funny bone over [target], faster and faster.", "[user] polishes [their] funny bone over me, faster and faster.", hear)
	return act_lines("[user] [get_generic_force_adjective()] polishes [their] funny bone over [target].", "[user] polishes [their] funny bone over me.", hear)

/datum/sex_action/npc/npc_jerk_over/funny_bone/compose_finish_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] stops polishing [their] funny bone.",
		"[user] stops polishing [their] funny bone over me.",
		"I hear a hollow clack."
	)

/datum/sex_action/npc/npc_jerk_over/funny_bone/get_climax_lines(mob/living/climaxer, mob/living/partner, flipped)
	if(flipped)
		return act_lines(
			"[climaxer] shudders through a climax under [partner]'s rattling funny bone!",
			"I shudder through a climax under [partner]'s rattling funny bone!",
			"I hear a hollow clack and a shaky moan."
		)
	return act_lines(
		"[climaxer]'s funny bone rattles over [partner], but nothing comes of it!",
		"[climaxer]'s funny bone rattles over me, but nothing comes of it!",
		"I hear a hollow rattle."
	)

/datum/sex_action/npc/npc_jerk_over/funny_bone/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	show_climax_lines(user, target, must_flip)
	return ORGASM_LOCATION_SELF

/// What a skeleton with nothing below the belt does instead: cold, rattling pets.
/datum/sex_action/npc/npc_bony_petting
	name = "Bony petting"

/datum/sex_action/npc/npc_bony_petting/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/npc/npc_bony_petting/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target)
		return FALSE
	return !!target.get_bodypart(BODY_ZONE_HEAD)

/datum/sex_action/npc/npc_bony_petting/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return
	show_act_lines(get_start_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_bony_petting/compose_start_lines(mob/living/user, mob/living/target)
	return act_lines(
		"[user] reaches for [target] with cold, clicking finger bones.",
		"[user] reaches for me with cold, clicking finger bones.",
		"I hear finger bones clicking softly."
	)

/datum/sex_action/npc/npc_bony_petting/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		show_act_lines(get_perform_lines(user, target, "middle", rand(1, 4)), user, target, "love")
	perform_sex_action(target, user, 0.4, 0, 0.2)
	// The skeleton enjoys it most; its climax is what ends the scene.
	perform_sex_action(user, target, 1.5, 0, 1.5)

/datum/sex_action/npc/npc_bony_petting/compose_perform_lines(mob/living/user, mob/living/target, stage, variant)
	var/hear = "I hear finger bones clicking softly."
	switch(variant)
		if(1)
			return act_lines("[user] pats [target]'s head with cold, bony fingers.", "[user] pats my head with cold, bony fingers.", hear)
		if(2)
			return act_lines("[user] strokes [target]'s hair, finger bones clicking softly.", "[user] strokes my hair, finger bones clicking softly.", hear)
		if(3)
			return act_lines("[user] scratches behind [target]'s ear with a bony fingertip.", "[user] scratches behind my ear with a bony fingertip.", hear)
	return act_lines("[user] gives [target] an awkward, rattling pet.", "[user] gives me an awkward, rattling pet.", hear)

/datum/sex_action/npc/npc_bony_petting/on_finish(mob/living/user, mob/living/target)
	. = ..()
	show_act_lines(get_finish_lines(user, target), user, target, "warning")

/datum/sex_action/npc/npc_bony_petting/compose_finish_lines(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return act_lines(
		"[user] draws [their] bony hand back from [target].",
		"[user] draws [their] bony hand back from me.",
		"I hear finger bones clicking softly."
	)
