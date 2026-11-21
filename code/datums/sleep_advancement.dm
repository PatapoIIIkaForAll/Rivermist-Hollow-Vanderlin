


/datum/sleep_adv
	var/sleep_adv_cycle = 0
	var/sleep_adv_points = 0
	var/stress_amount = 0
	var/stress_cycles = 0
	var/rolled_specials = 0
	var/retained_dust = 0
	var/list/sleep_exp = list()
	var/datum/mind/mind = null

	//dream watcher stuff

	var/list/available_modes = list("one_truth", "one_lie", "two_truths", "two_lies", "truth_lie")
	var/list/remaining_modes = list()
	var/list/daily_skill_xp = list()
/datum/sleep_adv/New(datum/mind/passed_mind)
	. = ..()
	mind = passed_mind

/datum/sleep_adv/Destroy(force)
	mind = null
	. = ..()

/datum/sleep_adv/proc/add_stress_cycle(add_amount)
	add_amount = clamp(add_amount, -15, 15) // Only -15 to 15, clamping things like Ozmium
	stress_amount += add_amount
	stress_cycles++
	process_sleep()//This could get hooked somewhere else

/datum/sleep_adv/proc/get_sleep_xp(skill)
	if(!sleep_exp[skill])
		sleep_exp[skill] = 0
	return sleep_exp[skill]

/datum/sleep_adv/proc/adjust_sleep_xp(skill, adjust)
	var/current_xp = get_sleep_xp(skill)
	var/target_xp = current_xp + adjust
	var/cap_exp = get_requried_sleep_xp_for_skill(skill, 2)
	target_xp = clamp(target_xp, 0, cap_exp)
	sleep_exp[skill] = target_xp

/datum/sleep_adv/proc/get_skill_raw_level(skill_type)
	if(!mind.current)
		return 0
	var/translated_skill = canonical_skill_type(skill_type)
	if(!translated_skill)
		return 0
	return nulltozero(mind.current.attributes?.raw_attribute_list[translated_skill])

/datum/sleep_adv/proc/get_skill_tier_from_raw_level(raw_level)
	if(raw_level >= SKILL_LEVEL_LEGENDARY)
		return SKILL_RANK_LEGENDARY
	return max(SKILL_RANK_NONE, floor(raw_level / 10))

/datum/sleep_adv/proc/get_skill_tier(skill_type)
	return get_skill_tier_from_raw_level(get_skill_raw_level(skill_type))

/datum/sleep_adv/proc/get_raw_level_for_skill_tier(skill_tier)
	skill_tier = clamp(skill_tier, SKILL_RANK_NONE, SKILL_RANK_LEGENDARY)
	return skill_tier * 10

/datum/sleep_adv/proc/get_skill_tier_name(skill_type, skill_tier)
	var/datum/skill/skill = GetSkillRef(skill_type)
	if(!skill)
		return "Unknown"
	return capitalize(skill.description_from_level(get_raw_level_for_skill_tier(skill_tier)))

/datum/sleep_adv/proc/needed_xp_for_level(skill_level)
	switch(skill_level)
		if(SKILL_RANK_NOVICE)
			return SLEEP_EXP_NOVICE
		if(SKILL_RANK_APPRENTICE)
			return SLEEP_EXP_APPRENTICE
		if(SKILL_RANK_JOURNEYMAN)
			return SLEEP_EXP_JOURNEYMAN
		if(SKILL_RANK_EXPERT)
			return SLEEP_EXP_EXPERT
		if(SKILL_RANK_MASTER)
			return SLEEP_EXP_MASTER
		if(SKILL_RANK_LEGENDARY)
			return SLEEP_EXP_LEGENDARY

/datum/sleep_adv/proc/enough_sleep_xp_to_advance(skill_type, level_amount)
	if(level_amount <= 0)
		return FALSE
	if(get_skill_tier(skill_type) >= SKILL_RANK_LEGENDARY)
		return FALSE
	var/needed_xp = get_requried_sleep_xp_for_skill(skill_type, level_amount)
	if(get_sleep_xp(skill_type) < needed_xp)
		return FALSE
	return TRUE

/datum/sleep_adv/proc/get_requried_sleep_xp_for_skill(skill_type, level_amount)
	if(level_amount <= 0)
		return 0
	var/current_tier = get_skill_tier(skill_type)
	var/tiers_to_advance = CEILING(level_amount, 1)
	var/max_tiers_to_advance = max(SKILL_RANK_NONE, SKILL_RANK_LEGENDARY - current_tier)
	tiers_to_advance = min(tiers_to_advance, max_tiers_to_advance)
	if(tiers_to_advance <= 0)
		return 0
	var/needed_xp = 0
	for(var/tier_offset in 1 to tiers_to_advance)
		needed_xp += needed_xp_for_level(current_tier + tier_offset)
	return needed_xp

/datum/sleep_adv/proc/add_sleep_experience(skill, amt, silent = FALSE)
	var/capped_pre = enough_sleep_xp_to_advance(skill, 2)
	var/can_advance_pre = enough_sleep_xp_to_advance(skill, 1)
	adjust_sleep_xp(skill, amt)
	var/can_advance_post = enough_sleep_xp_to_advance(skill, 1)
	var/capped_post = enough_sleep_xp_to_advance(skill, 2)
	var/datum/skill/skillref = GetSkillRef(skill)
	var/return_val = FALSE
	if(!can_advance_pre && can_advance_post && !silent)
		to_chat(mind.current, span_nicegreen(pick(list(
			"I'm getting a better grasp at [LOWER_TEXT(skillref.name)]...",
			"With some rest, I feel like I can get better at [LOWER_TEXT(skillref.name)]...",
			"[skillref.name] starts making more sense to me...",
		))))
		return_val = TRUE
	if(!capped_pre && capped_post && !silent)
		to_chat(mind.current, span_nicegreen(pick(list(
			"My [LOWER_TEXT(skillref.name)] is not gonna get any better without some rest...",
		))))
	return return_val

/datum/sleep_adv/proc/advance_cycle()
	// Stuff
	if(!mind.current)
		return
	if(prob(0))//TODO SLEEP ADV SPECIALS
		rolled_specials++
	var/inspirations = 1
	to_chat(mind.current, span_notice("My consciousness slips and I start dreaming..."))
	var/dreamwatcher = FALSE

	if(HAS_TRAIT(mind.current, TRAIT_DREAM_WATCHER))
		dreamwatcher = TRUE


	if(dreamwatcher)
		to_chat(mind.current, span_notice(pick(
			"You feel the gaze of Mystra before all else..",
			"A silver strand of the Weave drifts through your thoughts..",
			"You step into a dream that feels... familiar.",
			"Mystra whispers, not in words, but in meaning.",
		)))


	var/dream_dust = retained_dust
	dream_dust += BASE_DREAM_DUST
	if(HAS_TRAIT(mind.current, TRAIT_TUTELAGE))
		dream_dust += BASE_DREAM_DUST / 2

	var/int = mind.current.STAINT

	if(dreamwatcher)
		int+= 2

	dream_dust += mind.current.STAINT * DREAM_DUST_PER_INT //25% dream points for each int
	if(dreamwatcher)
		to_chat(mind.current, span_notice("I can feel Mystra's presence... symbols shift, forgotten places stir, and ancient beings whisper through the veil."))
	else if(int < 10)
		to_chat(mind.current, span_boldwarning("My shallow imagination makes them dull..."))
	else if (int > 10)
		to_chat(mind.current, span_notice("My creative thinking enhances them..."))

	var/stress_median = stress_cycles ? stress_amount / stress_cycles : 0

	if(dreamwatcher)
		to_chat(mind.current, span_notice("Mystra opens the dreamworld before me, a realm of impossible beauty and boundless thought."))
		dream_dust += 100
		inspirations++
	else if(stress_median <= 1.0)
		// Unstressed, happy
		to_chat(mind.current, span_notice("With no stresses throughout the day I dream vividly..."))
		dream_dust += 100
		inspirations++
	else if (stress_median >= 5.0)
		// Stressed, unhappy
		to_chat(mind.current, span_boldwarning("Bothered by the stresses of the day my dreams are short..."))
		dream_dust -= 100

	if(dreamwatcher)
		var/list/intro_lines = list(
			span_boldwarning("Mystra stirs beneath the surface of your dreams... the world around you distorts, familiar faces blur, and the stars themselves tremble in disquiet."),
			span_boldwarning("The dreamscape writhes, pulling at the edges of reality... fleeting images dance across your vision, too tangled to grasp, too distant to recall."),
			span_boldwarning("A shadow stretches across the stars, swallowing all that once was... whispers echo, but the words slip from your grasp like smoke."),
			span_boldwarning("Mystra's touch lingers in the space between thoughts... your mind flickers like a dying ember, lost in the endless night."),
			span_boldwarning("The fabric of dreams unravels around you... shapes and voices blur, an eternal puzzle without an answer."),
			span_boldwarning("A ripple of thought trembles through the dreamworld... each shift a new question, each answer a fleeting illusion.")
		)

		to_chat(mind.current, pick(intro_lines))


	//Most Influential God
	var/datum/storyteller/most_influential = SSgamemode.get_most_influential()
	if(dreamwatcher)
		var/list/dreams = SSgamemode.god_dreams[most_influential.name]
		if(!dreams)
			dreams = SSgamemode.god_dreams["Unknown"]
		var/message = pick(dreams)
		//Pick one of the three messages randomly out of the god_dream list.
		to_chat(mind.current, span_notice(message))

		//RNG Stuff for the Antag dream
		to_chat(mind.current, span_notice(generate_symbolic_dream()))


	grant_inspiration_xp(inspirations)

	stress_amount = 0
	stress_cycles = 0

	var/dream_points = FLOOR(dream_dust / 100, 1)
	var/dream_dust_modulo = dream_dust % 100

	retained_dust = dream_dust_modulo

	sleep_adv_points += max(dream_points, 1)
	sleep_adv_cycle++
	if(mind.current.client)
		show_ui(mind.current)
	daily_skill_xp = list()

/datum/sleep_adv/proc/show_ui(mob/living/user)
	var/list/entries = list()
	for(var/skill_type in GLOB.all_skills)
		var/datum/skill/skill = GetSkillRef(skill_type)
		if(!skill || !length(skill.name))
			continue
		if(!enough_sleep_xp_to_advance(skill_type, 1))
			continue
		var/next_level = get_next_level_for_skill(skill_type)
		var/level_name = get_skill_tier_name(skill_type, next_level)
		entries += "<a class='rp-pick[can_buy_skill(skill_type) ? "" : " rp-off"]' href='byond://?src=[REF(src)];task=buy_skill;skill_type=[skill_type]'><span class='rp-pick-name'>[skill.name]<span class='rp-pick-level'>Raise to [level_name]</span></span><span class='rp-pick-cost'>[get_skill_cost(skill_type)]</span></a>"
	if(rolled_specials > 0)
		entries += "<a class='rp-pick rp-special[can_buy_special() ? "" : " rp-off"]' href='byond://?src=[REF(src)];task=buy_special'><span class='rp-pick-name'>Dream something special<span class='rp-pick-level'>Can be good or bad</span></span><span class='rp-pick-cost'>[get_special_cost()]</span></a>"

	var/list/dat = list()
	dat += "<div class='rp'>"
	dat += "<div class='rp-frame rp-head'><div class='rp-title'>Dreams, cycle [sleep_adv_cycle]</div><div class='rp-sub'>Spend dream points to raise skills you practised.</div><div class='rp-points'>Points: [sleep_adv_points]</div></div>"
	dat += "<div class='rp-frame rp-body'><div class='rp-list'>"
	if(length(entries))
		dat += entries
	else
		dat += "<div class='rp-empty'>No skill is ready to raise. Practise skills while awake.</div>"
	dat += "</div></div>"
	dat += "<div class='rp-foot'>"
	dat += "<a class='rp-main' href='byond://?src=[REF(src)];task=continue'>Continue</a>"
	dat += "<div class='rp-hint'>Unspent points are kept for the next dream.</div>"
	dat += "</div>"
	dat += "</div>"
	var/datum/browser/popup = new(user, "dreams", "", 380, 520, src)
	popup.add_stylesheet("role_pick_menu", 'html/browser/role_pick_menu.css')
	popup.set_window_options(can_close = FALSE)
	popup.set_content(dat.Join())
	popup.open(TRUE)

/datum/sleep_adv/proc/close_ui()
	if(!mind.current)
		return
	mind.current << browse(null, "window=dreams")

/datum/sleep_adv/proc/process_sleep()
	if(is_considered_sleeping())
		return
	close_ui()

/datum/sleep_adv/proc/is_considered_sleeping()
	if(!mind.current)
		return FALSE
	var/has_vamp_trait = HAS_TRAIT(mind.current, TRAIT_VAMP_DREAMS)
	if(has_vamp_trait)
		return TRUE
	if(mind.current.has_status_effect(/datum/status_effect/reverie))
		return TRUE
	if(mind.current.IsSleeping())
		return TRUE
	return FALSE

/datum/sleep_adv/proc/can_buy_skill(skill_type)
	return (sleep_adv_points >= get_skill_cost(skill_type))

/datum/sleep_adv/proc/can_buy_special()
	return (sleep_adv_points >= get_special_cost())

/datum/sleep_adv/proc/get_next_level_for_skill(skill_type)
	if(!mind.current)
		return SKILL_RANK_NONE
	var/current_tier = get_skill_tier(skill_type)
	if(current_tier >= SKILL_RANK_LEGENDARY)
		return SKILL_RANK_LEGENDARY
	var/next_level = current_tier + 1
	return next_level

/datum/sleep_adv/proc/get_skill_cost(skill_type)
	var/datum/skill/skill = GetSkillRef(skill_type)
	if(!skill)
		return 0
	var/next_level = get_next_level_for_skill(skill_type)
	return skill.get_dream_cost_for_level(get_raw_level_for_skill_tier(next_level))

/datum/sleep_adv/proc/get_special_cost()
	return 3

/datum/sleep_adv/proc/buy_skill(skill_type)
	if(!can_buy_skill(skill_type))
		return
	if(!enough_sleep_xp_to_advance(skill_type, 1))
		return
	var/datum/skill/skill = GetSkillRef(skill_type)
	var/datum/attribute_holder/attributes = mind.current.attributes
	var/translated_skill = canonical_skill_type(skill_type)
	if(!skill || !translated_skill || !attributes)
		return
	var/current_raw_level = get_skill_raw_level(skill_type)
	var/target_raw_level = min(current_raw_level + 10, SKILL_LEVEL_LEGENDARY)
	if(current_raw_level >= target_raw_level)
		return
	var/dream_text = skill.get_random_dream()
	if(dream_text)
		to_chat(mind.current, span_notice(dream_text))
	sleep_adv_points -= get_skill_cost(skill_type)
	adjust_sleep_xp(skill_type, -get_requried_sleep_xp_for_skill(skill_type, 1))
	attributes.set_skill_level(translated_skill, target_raw_level, FALSE)
	record_round_statistic(STATS_SKILLS_DREAMED)

/datum/sleep_adv/proc/grant_inspiration_xp(skill_amt)
	var/list/viable_skills = list()
	var/list/inspired_skill_names = list()
	var/inspiration_cap_tier = get_skill_tier_from_raw_level(INSPIRATION_MAX_SKILL_LEVEL)
	for(var/skill_type in GLOB.all_skills)
		var/datum/skill/skill = GetSkillRef(skill_type)
		if(!skill || !skill.randomable_dream_xp)
			continue
		if(enough_sleep_xp_to_advance(skill_type, 1))
			continue
		var/current_raw_level = get_skill_raw_level(skill_type)
		if(current_raw_level >= INSPIRATION_MAX_SKILL_LEVEL)
			continue
		var/current_skill_tier = get_skill_tier(skill_type)
		var/tiers_until_cap = inspiration_cap_tier - current_skill_tier
		if(tiers_until_cap <= 0)
			continue
		var/req_exp = get_requried_sleep_xp_for_skill(skill_type, tiers_until_cap)
		if(get_sleep_xp(skill_type) >= req_exp)
			continue
		viable_skills += skill_type
	var/list/reinforcement_candidates = list()
	for(var/skill_type in viable_skills)
		var/daily_xp = nulltozero(daily_skill_xp[skill_type])
		if(daily_xp > 0)
			reinforcement_candidates[skill_type] = daily_xp

	var/reinforcement_slots = min(skill_amt, max(1, FLOOR(skill_amt / 2, 1)))
	for(var/i in 1 to skill_amt)
		if(!length(viable_skills))
			break
		var/skill_type
		if(reinforcement_slots > 0 && length(reinforcement_candidates))
			skill_type = pickweight(reinforcement_candidates)
			reinforcement_candidates -= skill_type
			viable_skills -= skill_type
			reinforcement_slots--
		else
			skill_type = pick_n_take(viable_skills)
		var/req_exp = get_requried_sleep_xp_for_skill(skill_type, 1)
		var/datum/skill/skill = GetSkillRef(skill_type)
		if(req_exp <= 0 || !skill)
			continue
		add_sleep_experience(skill_type, req_exp, TRUE)
		if(length(skill.name))
			inspired_skill_names += skill.name
	if(!length(inspired_skill_names))
		return
	var/skill_string = ""
	for(var/i in 1 to inspired_skill_names.len)
		var/skill_name = inspired_skill_names[i]
		if(i > 1 && i == inspired_skill_names.len)
			skill_string += " and "
		else if(i != 1)
			skill_string += ", "
		skill_string += LOWER_TEXT(skill_name)
	to_chat(mind.current, span_notice("I feel inspired about [skill_string]..."))


/datum/sleep_adv/proc/buy_special()
	if(!can_buy_special())
		return
	// Apply special here
	//TODO SLEEP ADV SPECIALS
	sleep_adv_points -= get_special_cost()

/datum/sleep_adv/proc/finish()
	if(!mind.current)
		return
	if(mind.has_studied)
		mind.has_studied = FALSE
		to_chat(mind.current, span_smallnotice("I feel like I can study my tome again..."))
	SEND_SIGNAL(mind.current, COMSIG_LIVING_DREAM_END)
	to_chat(mind.current, span_notice("...and that's all I dreamt of."))
	close_ui()

/datum/sleep_adv/Topic(href, list/href_list)
	. = ..()
	if(!mind.current)
		close_ui()
		return
	if(!is_considered_sleeping())
		close_ui()
		return
	if(href == "close=1")
		finish()
		return
	switch(href_list["task"])
		if("buy_skill")
			var/skill_type = text2path(href_list["skill_type"])
			if(!skill_type)
				return
			buy_skill(skill_type)
		if("buy_special")
			buy_special()
		if("continue")
			finish()
			return
	show_ui(mind.current)

/proc/can_train_combat_skill(mob/living/user, skill_type, target_skill_level)
	if(!user.mind)
		return FALSE
	var/user_skill_level = user.mind.sleep_adv.get_skill_tier(skill_type)
	var/level_diff = target_skill_level - user_skill_level
	if(level_diff <= 0)
		return FALSE
	if(user.mind.sleep_adv.enough_sleep_xp_to_advance(skill_type, level_diff))
		return FALSE
	return TRUE

/// Dream watcher procs


///Pick the possible dreams, a mix of lies and truths
/datum/sleep_adv/proc/generate_symbolic_dream()
	var/list/truths = get_current_real_antags()
	var/list/lies = get_possible_fake_antags_excluding(truths)

	/// Reset remaining modes if empty
	if(!remaining_modes.len)
		remaining_modes = available_modes.Copy()

	/// Pick a mode and remove it from remaining choices
	var/mode = pick(remaining_modes)
	remaining_modes -= mode

	var/list/picked = list()

	switch(mode)
		if("one_truth")
			picked += pick(truths)
		if("one_lie")
			picked += pick(lies)
		if("two_truths")
			if(truths.len >= 2)
				shuffle(truths)
				picked += truths[1]
				picked += truths[2]
			else
				picked += truths
		if("two_lies")
			if(lies.len >= 2)
				shuffle(lies)
				picked += lies[1]
				picked += lies[2]
			else
				picked += lies
		if("truth_lie")
			picked += pick(truths)
			picked += pick(lies)

	return assemble_symbolic_dream(picked)

///Pick symbols
/datum/sleep_adv/proc/assemble_symbolic_dream(list/antags)
	var/emotion = pick("dread", "anticipation", "sorrow", "awe", "rage", "longing", "confusion", "ecstasy", "emptiness", "yearning")
	var/scene = ""

///Random emotion to give more randomness
	switch(emotion)
		if("dread")           scene += "...the air is thick... shadows coil at the edges of your vision"
		if("anticipation")    scene += "...footsteps echo ahead... something waits, unseen"
		if("sorrow")          scene += "...you stand beneath a dying tree... it weeps silently"
		if("awe")             scene += "...the sky fractures with light... you kneel, unknowingly"
		if("rage")            scene += "...flames lick the ground... a scream builds in your chest"
		if("longing")         scene += "...you reach through mist... fingers graze something lost"
		if("confusion")       scene += "...the world tilts sideways... nothing is where it should be"
		if("ecstasy")         scene += "...a chorus sings behind your eyes... joy too bright to bear"
		if("emptiness")       scene += "...you float above yourself... hollow... watching"
		if("yearning")        scene += "...you reach for something in the dark... it slips through your fingers"

	for(var/antag_type in antags)
		scene += generate_symbol_for_antag(antag_type)

///random suffix
	var/list/suffixes = list(
		"... then, silence...",
		"... you awake with the taste of ash...",
		"... a bell tolls, but no one hears it...",
		"... you are not sure if you were watching... or being watched...",
		"... the feeling lingers, heavy as dusk...",
		"... your hands won’t stop trembling...",
		"... you wake with your mouth full of names...",
		"... the light behind your eyes is gone...",
		"... you try to remember, but something remembers you instead...",
		"... you are not alone in your skin...",
		"... you wake gripping nothing... yet your hands ache...",
		"... your pillow is damp with tears you didn’t cry...",
		"... the shadows no longer flee the dawn...",
		"... you remember less than you did before...",
		"... someone else's name rests on your lips...",
		"... the dream fades... but something remains behind..."
	)

	scene += pick(suffixes)
	return scene


/// Pick the messages for the antags
/datum/sleep_adv/proc/generate_symbol_for_antag(datum/antagonist/antag)

	var/list/antag_dreams = SSgamemode.antag_dreams

	if(antag_dreams[antag.type])
		return pick(antag_dreams[antag.type])
	else
		return pick(antag_dreams["Unknown"])

///Get antags
/datum/sleep_adv/proc/get_current_real_antags()
	var/list/truths = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(A.owner && A.owner.current.client) // Confirm the antag is active and controlled
			truths += A
	return truths

///All antags for the fake list
/datum/sleep_adv/proc/get_possible_fake_antags_excluding(list/truths)
	var/list/all_possible = list(
		/datum/antagonist/vampire/lord,
		/datum/antagonist/vampire,
		/datum/antagonist/vampire/lords_spawn,
		/datum/antagonist/lich,
		/datum/antagonist/werewolf,
		/datum/antagonist/werewolf/lesser,
		/datum/antagonist/zizocultist,
		/datum/antagonist/zizocultist/leader,
		/datum/antagonist/prebel,
		/datum/antagonist/prebel/head,
		/datum/antagonist/aspirant,
		/datum/antagonist/bandit,
		/datum/antagonist/assassin,
		/datum/antagonist/maniac
	)

	/// Remove the true antag types from the possible lies
	for(var/datum/antagonist/T in truths)
		all_possible -= T.type

	/// Instantiate new antag datums for the lies
	var/list/lies = list()
	for(var/antag_type in all_possible)
		lies += new antag_type()

	return lies

