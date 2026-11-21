/// Smallest visible breast size the vice cares about.
#define ENTHUSIAST_MIN_SIZE 4
/// Time without a qualifying interaction before the hunger starts, and between its stages.
#define ENTHUSIAST_HUNGER_START (30 MINUTES)
#define ENTHUSIAST_HUNGER_STEP (15 MINUTES)
/// Self-admiring thoughts: every 3-6 minutes; each one pushes the hunger back by this much.
#define ENTHUSIAST_ADMIRE_RELIEF (3 MINUTES)
/// Looking around for big breasts: every 1-2 minutes; the same person again only after this.
#define ENTHUSIAST_TARGET_COOLDOWN (10 MINUTES)
/// "Caught staring": chance per glance, and per person cooldown.
#define ENTHUSIAST_CAUGHT_CHANCE 10
#define ENTHUSIAST_CAUGHT_COOLDOWN (5 MINUTES)
/// Critical stare: bare-breast chance multiplier, message range, arousal multiplier and stun.
#define ENTHUSIAST_CRIT_BARE_MULT 1.5
#define ENTHUSIAST_CRIT_MESSAGE_RANGE 2
#define ENTHUSIAST_CRIT_AROUSAL_MULT 4
#define ENTHUSIAST_CRIT_STUN (0.5 SECONDS)

/datum/quirk/negative/breast_enthusiast
	name = "Breast Enthusiast"
	desc = "I can't help it - a generous bosom makes my heart race. Too long without one and I get restless and miserable."
	point_value = 2
	/// Last time breasts of size 4+ were touched (or the hunger was pushed back by admiring my own).
	var/last_satisfied = 0
	var/hunger_stage = 0
	var/next_hunger_thought = 0
	var/next_admire = 0
	var/next_look = 0
	var/next_show_thought = 0
	var/next_admired = 0
	var/next_satisfied_message = 0
	/// REF(person) -> world.time they may catch my eye again / catch me staring again.
	var/list/looked_at = list()
	var/list/caught_by = list()

/datum/quirk/negative/breast_enthusiast/on_spawn()
	last_satisfied = world.time
	next_admire = world.time + rand(3 MINUTES, 6 MINUTES)
	next_look = world.time + rand(1 MINUTES, 2 MINUTES)
	return ..()

/datum/quirk/negative/breast_enthusiast/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Breast-obsessed..."))

/datum/quirk/negative/breast_enthusiast/on_life(mob/living/user)
	if(!ishuman(user) || user.stat == DEAD)
		return
	var/mob/living/carbon/human/holder = user
	update_hunger(holder)
	if(holder.stat != CONSCIOUS)
		return
	if(world.time >= next_admire)
		next_admire = world.time + rand(3 MINUTES, 6 MINUTES)
		admire_self(holder)
	if(world.time >= next_look && !holder.is_blind())
		next_look = world.time + rand(1 MINUTES, 2 MINUTES)
		look_around(holder)

// Hunger.

/datum/quirk/negative/breast_enthusiast/proc/update_hunger(mob/living/carbon/human/holder)
	var/elapsed = world.time - last_satisfied
	var/stage = 0
	if(elapsed >= ENTHUSIAST_HUNGER_START)
		stage = min(3, 1 + round((elapsed - ENTHUSIAST_HUNGER_START) / ENTHUSIAST_HUNGER_STEP))
	if(stage != hunger_stage)
		hunger_stage = stage
		holder.remove_stress(list(/datum/stress_event/enthusiast_hunger1, /datum/stress_event/enthusiast_hunger2, /datum/stress_event/enthusiast_hunger3))
		switch(stage)
			if(1)
				holder.add_stress(/datum/stress_event/enthusiast_hunger1)
			if(2)
				holder.add_stress(/datum/stress_event/enthusiast_hunger2)
			if(3)
				holder.add_stress(/datum/stress_event/enthusiast_hunger3)
		next_hunger_thought = world.time
	if(!stage || world.time < next_hunger_thought || holder.stat != CONSCIOUS)
		return
	next_hunger_thought = world.time + rand(4 MINUTES, 7 MINUTES)
	var/list/lines
	switch(stage)
		if(1)
			lines = list("I could really use a soft bosom to rest my head on.", "My hands feel empty lately.",
				"When did I last get my hands on a good pair?", "I keep glancing at every neckline I pass.")
		if(2)
			lines = list("Breasts. Big ones. I can't think about anything else.", "My fingers twitch, remembering how heavy they felt.",
				"Everything's dull. I need curves in my life.", "I'm getting irritable. I know exactly why.")
		else
			lines = list("I'm aching for big, soft breasts. It's all I can think about.", "If I don't get my face between a pair soon, I'll go mad.", "I need a pair of big [lewd_breast_word()] in my hands. Now.",
				"Every cleavage I see makes my mouth water.", "This hunger gnaws at me. I need to touch someone. Anyone generous.")
	to_chat(holder, span_warning(pick(lines)))

/// A breast interaction involving holder and breasts of the given visible size; own: holder's own breasts.
/datum/quirk/negative/breast_enthusiast/proc/satisfy(mob/living/carbon/human/holder, size, own, mob/living/owner)
	if(size < ENTHUSIAST_MIN_SIZE)
		return
	var/tier = min(size, 7) - 3 // 4 -> 1 ... 7 and 8 -> 4
	var/mirror = own && holder.is_facing_mirror()
	if(own && !mirror)
		tier--
	last_satisfied = world.time
	update_hunger(holder)
	holder.remove_stress(list(/datum/stress_event/enthusiast_sated1, /datum/stress_event/enthusiast_sated2, /datum/stress_event/enthusiast_sated3, /datum/stress_event/enthusiast_sated4))
	switch(tier)
		if(1)
			holder.add_stress(/datum/stress_event/enthusiast_sated1)
		if(2)
			holder.add_stress(/datum/stress_event/enthusiast_sated2)
		if(3)
			holder.add_stress(/datum/stress_event/enthusiast_sated3)
		if(4)
			holder.add_stress(/datum/stress_event/enthusiast_sated4)
	if(world.time < next_satisfied_message)
		return
	next_satisfied_message = world.time + 3 MINUTES
	var/list/lines
	if(mirror)
		lines = list("Watching myself in the mirror... gods, that's better than I expected.", "Me, my curves and my reflection. Perfect company.")
	else if(own)
		lines = list("Not quite the same as someone else's... but still nice.", "My own hands, my own breasts. It'll do for now.")
	else
		switch(size)
			if(4)
				lines = list("Soft and warm. Just what I needed.", "A perfect handful. I feel better already.")
			if(5)
				lines = list("So heavy in my hands... wonderful.", "I could do that all day.")
			if(6)
				lines = list("I lost myself in [owner]'s cleavage for a while there.", "So much to hold. I'm in heaven.")
			else
				lines = list("I nearly drowned in them. Best way to go.", "I'll be dreaming about that for a week.", "Those [huge_breast_word()]... I'm a happy wreck.")
	to_chat(holder, span_love(pick(lines)))

// My own.

/datum/quirk/negative/breast_enthusiast/proc/admire_self(mob/living/carbon/human/holder)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = holder.getorganslot(ORGAN_SLOT_BREASTS)
	var/size = breasts ? breasts.get_visible_size() : 0
	if(size < ENTHUSIAST_MIN_SIZE)
		return
	var/obj/item/strained = holder.get_strained_chest_garment()
	if(strained && size >= 6)
		to_chat(holder, span_warning(pick("My chest is squashed flat in [strained]. Criminal.", "[capitalize(strained.name)] is hiding my best feature.")))
		holder.add_stress(/datum/stress_event/enthusiast_hidden)
		return
	last_satisfied = min(world.time, last_satisfied + ENTHUSIAST_ADMIRE_RELIEF)
	if(holder.is_facing_mirror())
		to_chat(holder, span_love(pick("Look at them in the mirror... stunning.", "I turn a little to the side. Even better from here.", "I could admire this reflection forever.")))
		holder.add_stress(/datum/stress_event/enthusiast_mirror)
		return
	var/list/lines
	if(size >= 5 && holder.m_intent == MOVE_INTENT_RUN)
		lines = list("The way they bounce when I run... I'm not even sorry.", "Running is hard with these. I'm smiling anyway.")
	else
		switch(size)
			if(4)
				lines = list("Mmm, they're a nice size. Perfect, really.", "I have a lovely bust, if I say so myself.", "Just the right weight. Just the right shape.")
			if(5)
				lines = list("I could stare at my own breasts all day.", "Gods, I'm lucky.", "I catch myself looking down at them again. Can you blame me?")
			if(6)
				lines = list("Gods, they're enormous... and they're mine.", "They're heavy, but I wouldn't trade them for anything.", "I can't see my feet. Worth it.")
			else
				lines = list("So heavy, so full... I love every ounce of them.", "They're the biggest I've ever seen. And they're mine.", "Every step they sway, and every sway makes me grin.", "Look at these [huge_breast_word()] of mine. Gods, yes.")
		if(breasts.engorgement_steps && prob(40))
			lines = list("They're even bigger now. Oh, I like that.", "Fuller, heavier... gods, yes.")
	to_chat(holder, span_love(pick(lines)))
	holder.add_stress(/datum/stress_event/enthusiast_admiring)

/// Someone looked me over (examine) or another enthusiast noticed me: nice, when mine are big.
/datum/quirk/negative/breast_enthusiast/proc/admired_by(mob/living/carbon/human/holder, mob/living/watcher)
	if(world.time < next_admired || get_breast_visible_size(holder) < ENTHUSIAST_MIN_SIZE)
		return
	next_admired = world.time + 5 MINUTES
	var/list/lines = list("I can feel someone's eyes on my breasts. Let them look.", "Someone's staring. I stand a little straighter.", "Admire away. I would too.")
	if(get_breast_visible_size(holder) >= 6)
		lines += "Of course they're staring. How could they not?"
	to_chat(holder, span_love(pick(lines)))
	holder.add_stress(/datum/stress_event/enthusiast_admired)

// Others.

/// How visible a person's breasts are: "bare", "clothed" (shaped by breast-sized clothing) or null (hidden).
/proc/get_breast_exposure(mob/living/carbon/human/target)
	if(target.has_bared_chest())
		return "bare"
	if(!breasts_visible_under_clothes(target))
		return null
	if(target.undershirt)
		return null
	return length(target.get_breast_sized_garments()) ? "clothed" : "bare"

/datum/quirk/negative/breast_enthusiast/proc/look_around(mob/living/carbon/human/holder)
	prune_cooldowns(looked_at)
	prune_cooldowns(caught_by)
	var/own_size = get_breast_visible_size(holder)
	var/mob/living/carbon/human/best
	var/best_size = 0
	var/count = 0
	for(var/mob/living/carbon/human/target in view(7, holder))
		if(target == holder || target.stat == DEAD)
			continue
		var/size = get_breast_visible_size(target)
		if(size < ENTHUSIAST_MIN_SIZE || !get_breast_exposure(target))
			continue
		if(!can_eye_each_other(holder, target))
			continue
		count++
		if(looked_at[REF(target)] > world.time)
			continue
		if(size > best_size)
			best = target
			best_size = size
	if(!best)
		return
	looked_at[REF(best)] = world.time + ENTHUSIAST_TARGET_COOLDOWN
	glance(holder, best, best_size, own_size, count)

/// Drops the entries of a REF to world.time list whose time has passed.
/datum/quirk/negative/breast_enthusiast/proc/prune_cooldowns(list/cooldowns)
	for(var/key in cooldowns.Copy())
		if(cooldowns[key] <= world.time)
			cooldowns -= key

/datum/quirk/negative/breast_enthusiast/proc/glance(mob/living/carbon/human/holder, mob/living/carbon/human/target, size, own_size, count)
	var/exposure = get_breast_exposure(target)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = target.getorganslot(ORGAN_SLOT_BREASTS)
	var/running = target.m_intent == MOVE_INTENT_RUN
	var/their = target.p_their()
	var/list/lines
	if(count >= 3 && prob(50))
		lines = list("So many generous bosoms in one place. Am I dreaming?", "I don't know where to look first.")
	else if(running)
		lines = list("Watch those [lewd_breast_word()] bounce... gods.", "Every step [target] takes, they sway. I'm hypnotised.", "[target] really shouldn't run like that. Or should. Definitely should.")
	else if(breasts?.is_full_of_milk() && prob(50))
		lines = list("[capitalize(their)] breasts look heavy and full. Ripe.", "So full... someone should help [target.p_them()] with that.", "Those [milky_breast_word()] are about to burst.")
	else if(exposure == "clothed" && prob(50))
		lines = list("Even dressed, there's no hiding a rack like that.", "I'd love to see what's under those clothes.", "[capitalize(their)] clothes are doing very little to hide those.")
	else
		switch(size)
			if(4)
				lines = list("Nice curves on [target].", "[target] has a lovely bust. Just right.", "I wouldn't mind a closer look at [target].", "A perfect handful, I'd wager.")
			if(5)
				lines = list("Now those are a proper pair.", "[target]'s [lewd_breast_word()] are something else.", "I can't keep my eyes off [target]'s cleavage.", "Heavy, round, perfect... focus.")
			if(6)
				lines = list("How does [target] even walk with those?", "I've never seen anything that big up close. I'd like to.", "[capitalize(their)] bust arrives before [target.p_they()] [target.p_do()].")
			else
				lines = list("I need to get my hands on those [huge_breast_word()]. Now.", "Look at the [huge_breast_word()] on [target]. Gods.", "Gods above... [target]'s breasts are enormous.", "I'd happily drown in those.", "My knees just went weak.")
	var/arousal = LAZYACCESS(GLOB.breast_enthusiast_glance_arousal, "[min(size, 7)]") || 0
	if(exposure == "clothed")
		arousal *= 0.5
	if(running)
		arousal *= 1.5
	// Critical failure: openly gawking, from size 5; likelier the bigger and barer the breasts.
	var/crit_chance = LAZYACCESS(GLOB.breast_enthusiast_crit_chance, "[min(size, 8)]") || 0
	if(exposure == "bare")
		crit_chance *= ENTHUSIAST_CRIT_BARE_MULT
	if(holder.stat == CONSCIOUS && prob(crit_chance))
		critical_stare(holder, target, arousal)
		return
	to_chat(holder, span_love(pick(lines)))
	SEND_SIGNAL(holder, COMSIG_SEX_ADJUST_AROUSAL, arousal)
	holder.add_stress(/datum/stress_event/enthusiast_eyeful)
	if(own_size >= ENTHUSIAST_MIN_SIZE && size > own_size && prob(40))
		to_chat(holder, span_warning(pick("[capitalize(their)] breasts are even bigger than mine...", "How are [their] breasts bigger than mine? Unfair.", "Fine. [target]'s [lewd_breast_word()] win. This time.")))
		holder.add_stress(/datum/stress_event/enthusiast_envious)
	var/datum/quirk/negative/breast_enthusiast/their_vice = target.get_quirk(/datum/quirk/negative/breast_enthusiast)
	their_vice?.admired_by(target, holder)
	if(target.stat == CONSCIOUS && prob(ENTHUSIAST_CAUGHT_CHANCE) && caught_by[REF(target)] <= world.time)
		caught_by[REF(target)] = world.time + ENTHUSIAST_CAUGHT_COOLDOWN
		to_chat(target, span_notice(pick("You catch [holder] staring at your chest.", "[holder] is very obviously looking at your breasts.", "You notice [holder]'s eyes fixed somewhere below your face.")))
		to_chat(holder, span_warning(pick("[target] caught me looking. Oops.", "Our eyes met - well, eventually. After my eyes left [their] cleavage.", "I've been spotted. Act natural.")))
		holder.add_stress(/datum/stress_event/enthusiast_caught)

/// Gawking openly: people nearby notice, the holder blushes and freezes, and arousal quadruples.
/datum/quirk/negative/breast_enthusiast/proc/critical_stare(mob/living/carbon/human/holder, mob/living/carbon/human/target, arousal)
	var/message = pick(
		"[holder] freezes mid-step, staring at [target]'s cleavage with [holder.p_their()] mouth hanging open.",
		"[holder] completely forgets what [holder.p_they()] [holder.p_were()] doing and gawks at [target]'s breasts.",
		"[holder] stares at [target]'s bust so hard [holder.p_they()] nearly walk[holder.p_s()] into something.",
		"[holder]'s eyes lock onto [target]'s chest, spellbound.")
	var/self_message = pick(
		"I can't look away from [target]'s chest. I just... can't.",
		"My brain stops working. All I can see are [target]'s breasts.",
		"Gods. GODS. [capitalize(target.p_their())] [lewd_breast_word()]. I forget how to move.",
		"Those [huge_breast_word()]... I forget my own name.",
		"Everything else fades away. There is only [target]'s cleavage.",
		"I stare. I know I'm staring. I can't stop staring.",
		"My jaw drops. [target]'s rack has my complete, undivided attention.")
	holder.visible_message(span_love(message), "<span class='love_extreme'><span class='big bold'>[self_message]</span></span>", vision_distance = ENTHUSIAST_CRIT_MESSAGE_RANGE)
	holder.emote("blush", forced = TRUE)
	holder.Stun(ENTHUSIAST_CRIT_STUN)
	SEND_SIGNAL(holder, COMSIG_SEX_ADJUST_AROUSAL, arousal * ENTHUSIAST_CRIT_AROUSAL_MULT)
	holder.add_stress(/datum/stress_event/enthusiast_eyeful)
	caught_by[REF(target)] = world.time + ENTHUSIAST_CAUGHT_COOLDOWN
	holder.add_stress(/datum/stress_event/enthusiast_caught)
	var/datum/quirk/negative/breast_enthusiast/their_vice = target.get_quirk(/datum/quirk/negative/breast_enthusiast)
	their_vice?.admired_by(target, holder)
	if(target.stat == CONSCIOUS)
		to_chat(target, span_notice("[holder] is staring at your breasts like [holder.p_theyve()] never seen one before."))

/// A breast show (bounce, squeeze together, heft) in sight.
/datum/quirk/negative/breast_enthusiast/proc/saw_show(mob/living/carbon/human/holder, mob/living/shower, show_kind)
	if(shower == holder || world.time < next_show_thought)
		return
	next_show_thought = world.time + 1 MINUTES
	var/list/lines
	switch(show_kind)
		if("bounce")
			lines = list("[shower]'s doing that on purpose. And it's working.", "I can't look away. I'm not even trying.", "That show was worth the whole trip.")
		if("squeeze")
			lines = list("[shower] pressed them together and my brain stopped working.", "That cleavage just got even deeper.")
		else
			lines = list("Did [shower] just... drop them like that? Gods.")
	to_chat(holder, span_love(pick(lines)))
	holder.add_stress(/datum/stress_event/enthusiast_show)

// Hooks.

/mob/living/carbon/human/saw_breast_show(mob/living/shower, show_kind)
	var/datum/quirk/negative/breast_enthusiast/vice = get_quirk(/datum/quirk/negative/breast_enthusiast)
	vice?.saw_show(src, shower, show_kind)

/mob/living/carbon/human/get_breast_show_arousal_multiplier()
	return get_quirk(/datum/quirk/negative/breast_enthusiast) ? 1.5 : 1

/// Whether watcher has its back turned to thing (thing is behind it, not beside or in front).
/proc/is_back_turned_to(mob/living/watcher, atom/thing)
	var/dir_to = get_dir(watcher, thing)
	if(!dir_to)
		return FALSE
	return (dir_to & REVERSE_DIR(watcher.dir)) && !(dir_to & watcher.dir)

/// Called with second already in first's view: first in second's view, and neither turned away.
/proc/can_eye_each_other(mob/living/first, mob/living/second)
	if(!(first in view(7, second)))
		return FALSE
	return !is_back_turned_to(first, second) && !is_back_turned_to(second, first)

/// Next to an unbroken mirror, facing it or side-on; a pixel-shifted mirror counts where it shows.
/mob/living/proc/is_facing_mirror()
	var/turf/here = get_turf(src)
	if(!here)
		return FALSE
	for(var/obj/structure/mirror/mirror in range(3, here))
		var/turf/shown = locate(mirror.x + round(mirror.pixel_x / world.icon_size), mirror.y + round(mirror.pixel_y / world.icon_size), mirror.z)
		if(!shown || get_dist(here, shown) > 1)
			continue
		if(shown != here && dir == REVERSE_DIR(get_dir(here, shown)))
			continue
		if(mirror.can_reflect(src))
			return TRUE
	return FALSE

/// Every cycle of a breast interaction (see play_perform_breast_anim()): the vice of everyone taking part is fed.
/datum/sex_action/proc/notify_breast_interaction(list/breast_owners)
	for(var/mob/living/carbon/human/participant in list(action_user, action_target))
		var/datum/quirk/negative/breast_enthusiast/vice = participant.get_quirk(/datum/quirk/negative/breast_enthusiast)
		if(!vice)
			continue
		for(var/mob/living/owner as anything in breast_owners)
			vice.satisfy(participant, get_breast_visible_size(owner), owner == participant, owner)
		if(action_user == action_target)
			break

/// Crude words for breasts, for the vice's coarser thoughts.
/proc/lewd_breast_word()
	return pick("tits", "boobs", "jugs", "melons", "knockers", "titties", "hooters")

/// Crude words for big breasts.
/proc/huge_breast_word()
	return pick("melons", "jugs", "knockers", "honkers", "tits")

/// Crude words for breasts full of milk.
/proc/milky_breast_word()
	return pick("udders", "jugs", "milk jugs")

/// Arousal per glance at breasts of size 4, 5, 6, 7+ (halved under clothes, x1.5 while they run).
GLOBAL_LIST_INIT(breast_enthusiast_glance_arousal, list("4" = 2, "5" = 4, "6" = 6, "7" = 8))
/// Chance (%) of a "critical failure" per glance at breasts of size 5, 6, 7, 8 (under clothes; bare: x1.5).
GLOBAL_LIST_INIT(breast_enthusiast_crit_chance, list("5" = 2, "6" = 3, "7" = 4, "8" = 6))

// Mood.

/datum/stress_event/enthusiast_hunger1
	stress_change = 1
	desc = span_red("It's been a while since I've had my hands on a proper pair.")

/datum/stress_event/enthusiast_hunger2
	stress_change = 2
	desc = span_red("I can't stop thinking about soft, heavy breasts.")

/datum/stress_event/enthusiast_hunger3
	stress_change = 3
	desc = span_red("I'd give anything to bury my face in a deep cleavage right now.")

/datum/stress_event/enthusiast_sated1
	stress_change = -1
	desc = span_green("A lovely handful. That took the edge off.")
	timer = 10 MINUTES

/datum/stress_event/enthusiast_sated2
	stress_change = -2
	desc = span_green("More than my hands could hold. Wonderful.")
	timer = 10 MINUTES

/datum/stress_event/enthusiast_sated3
	stress_change = -3
	desc = span_green("I got lost in them for a while. Bliss.")
	timer = 10 MINUTES

/datum/stress_event/enthusiast_sated4
	stress_change = -4
	desc = span_green("I've touched heaven, and heaven was soft.")
	timer = 10 MINUTES

/datum/stress_event/enthusiast_admiring
	stress_change = -1
	desc = span_green("I really do have a magnificent bust.")
	timer = 5 MINUTES

/datum/stress_event/enthusiast_mirror
	stress_change = -2
	desc = span_green("Gods, look at them. I could stay in front of the mirror all day.")
	timer = 5 MINUTES

/datum/stress_event/enthusiast_eyeful
	stress_change = -1
	desc = span_green("I got quite the eyeful earlier.")
	timer = 5 MINUTES

/datum/stress_event/enthusiast_show
	stress_change = -2
	desc = span_green("Someone put on a show just for me. Or so I tell myself.")
	timer = 5 MINUTES

/datum/stress_event/enthusiast_envious
	stress_change = 1
	desc = span_red("Someone's are bigger than mine. Not fair.")
	timer = 5 MINUTES

/datum/stress_event/enthusiast_caught
	stress_change = 1
	desc = span_red("Got caught staring. Mortifying... mostly.")
	timer = 3 MINUTES

/datum/stress_event/enthusiast_admired
	stress_change = -1
	desc = span_green("I felt eyes on my breasts. I liked it.")
	timer = 5 MINUTES

/datum/stress_event/enthusiast_hidden
	stress_change = 1
	desc = span_red("My chest is squashed in this. What a waste.")
	timer = 5 MINUTES

#undef ENTHUSIAST_MIN_SIZE
#undef ENTHUSIAST_HUNGER_START
#undef ENTHUSIAST_HUNGER_STEP
#undef ENTHUSIAST_ADMIRE_RELIEF
#undef ENTHUSIAST_TARGET_COOLDOWN
#undef ENTHUSIAST_CAUGHT_CHANCE
#undef ENTHUSIAST_CAUGHT_COOLDOWN
#undef ENTHUSIAST_CRIT_BARE_MULT
#undef ENTHUSIAST_CRIT_MESSAGE_RANGE
#undef ENTHUSIAST_CRIT_AROUSAL_MULT
#undef ENTHUSIAST_CRIT_STUN
