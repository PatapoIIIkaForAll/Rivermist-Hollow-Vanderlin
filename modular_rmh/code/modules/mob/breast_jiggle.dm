#define BREAST_JIGGLE_CYCLE (0.8 SECONDS)
#define BREAST_JIGGLE_MIN_DURATION 8
#define BREAST_JIGGLE_MAX_DURATION 100
#define BREAST_JIGGLE_FREE_DURATION 50
#define BREAST_JIGGLE_STAMINA_PER_SECOND 0.83
#define BREAST_JIGGLE_ENDLESS_STAMINA_MULT 3
#define BREAST_JIGGLE_HOP_HEIGHT 4
#define BREAST_JIGGLE_ENDLESS 0
#define BREAST_JIGGLE_PROMPT_STEP (BREAST_JIGGLE_CYCLE * 2)
#define MIN_JIGGLE_BREASTS_SIZE 1

/datum/emote/living/carbon/human/bjiggle
	key = "bjiggle"
	key_third_person = "jiggles"
	message = "shakes their chest and bounces on the spot!"
	emote_type = EMOTE_VISIBLE
	show_runechat = TRUE

/proc/jiggle_duration_label(duration)
	if(duration > BREAST_JIGGLE_FREE_DURATION)
		return "[duration / 10] seconds (tiring)"
	return "[duration / 10] seconds"

/// Prompt label to jiggle duration in deciseconds, or BREAST_JIGGLE_ENDLESS.
/proc/jiggle_duration_choices()
	var/static/list/choices
	if(choices)
		return choices
	choices = list()
	for(var/duration = BREAST_JIGGLE_MIN_DURATION; duration < BREAST_JIGGLE_MAX_DURATION; duration += BREAST_JIGGLE_PROMPT_STEP)
		choices[jiggle_duration_label(duration)] = duration
	choices[jiggle_duration_label(BREAST_JIGGLE_MAX_DURATION)] = BREAST_JIGGLE_MAX_DURATION
	choices["Until I stop myself (very tiring)"] = BREAST_JIGGLE_ENDLESS
	return choices

/datum/emote/living/carbon/human/bjiggle/run_emote(mob/user, params, type_override, intentional, targetted)
	var/mob/living/carbon/human/human = user
	if(!can_jiggle_breasts(human))
		return FALSE
	var/duration = BREAST_JIGGLE_MIN_DURATION
	var/endless = FALSE
	if(intentional && human.client)
		var/list/choices = jiggle_duration_choices()
		var/picked = tgui_input_list(human, "How long should I keep it up?", "Jiggle", choices)
		if(isnull(picked))
			return FALSE
		if(QDELETED(human) || !can_jiggle_breasts(human))
			return FALSE
		var/chosen = choices[picked]
		if(chosen == BREAST_JIGGLE_ENDLESS)
			endless = TRUE
		else
			duration = chosen
	. = ..()
	if(!.)
		return
	var/datum/component/breast_animation/animation = human.GetComponent(/datum/component/breast_animation)
	if(!animation)
		return
	var/costs_stamina = endless || (duration > BREAST_JIGGLE_FREE_DURATION)
	if(costs_stamina && !human.jiggle_stamina_is_free() && human.stamina >= human.maximum_stamina)
		to_chat(human, span_warning("I am far too weary to keep this up."))
		duration = BREAST_JIGGLE_MIN_DURATION
		endless = FALSE
		costs_stamina = FALSE
	animation.start_jiggle(duration, endless, costs_stamina)

/datum/emote/living/carbon/human/bjiggle/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	. = ..()
	if(!.)
		return
	return can_jiggle_breasts(user)

/mob/living/carbon/human/verb/emote_bjiggle()
	set name = "Jiggle"
	set category = "Emotes.Silent"

	var/datum/component/breast_animation/animation = GetComponent(/datum/component/breast_animation)
	if(animation?.jiggling)
		animation.stop_jiggle()
		return
	emote("bjiggle", intentional = TRUE)

/// Whether a human may start a jiggle: out of combat, not jiggling, breasts of a jiggling type.
/proc/can_jiggle_breasts(mob/living/carbon/human/human)
	if(!ishuman(human) || human.cmode)
		return FALSE
	var/datum/component/breast_animation/animation = human.GetComponent(/datum/component/breast_animation)
	if(!animation || animation.jiggling)
		return FALSE
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = human.getorganslot(ORGAN_SLOT_BREASTS)
	if(!istype(breasts) || breasts.get_visible_size() < MIN_JIGGLE_BREASTS_SIZE)
		return FALSE
	var/static/list/jiggle_accessories
	jiggle_accessories ||= typecacheof(list(
		/datum/sprite_accessory/genitals/breasts/pair,
		/datum/sprite_accessory/genitals/breasts/quad,
		/datum/sprite_accessory/genitals/breasts/sextuple,
	))
	return !!jiggle_accessories[breasts.accessory_type]

/mob/living/carbon/human/proc/jiggle_stamina_is_free()
	if(!HAS_TRAIT(src, TRAIT_BATHHOUSE_DANCER))
		return FALSE
	var/area/here = get_area(src)
	return istype(here, /area/indoors/town/bath) || istype(here, /area/indoors/town/rmh/bath) || istype(here, /area/outdoors/exposed/rmh/bath)

/// Two relative hops on the human per cycle, parallel to any other animation.
/mob/living/carbon/human/proc/do_jiggle_hop()
	animate(src, pixel_z = BREAST_JIGGLE_HOP_HEIGHT, time = BREAST_JIGGLE_CYCLE * 0.25, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_z = -BREAST_JIGGLE_HOP_HEIGHT, time = BREAST_JIGGLE_CYCLE * 0.25, easing = SINE_EASING|EASE_IN, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_z = BREAST_JIGGLE_HOP_HEIGHT, time = BREAST_JIGGLE_CYCLE * 0.25, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_z = -BREAST_JIGGLE_HOP_HEIGHT, time = BREAST_JIGGLE_CYCLE * 0.25, easing = SINE_EASING|EASE_IN, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)

/datum/component/breast_animation
	/// Whether the jiggle runs until stopped instead of for a cycle count.
	var/jiggle_endless = FALSE
	/// Whether each jiggle cycle costs stamina.
	var/jiggle_costs_stamina = FALSE
	/// Cycles a timed jiggle still plays.
	var/jiggle_cycles_left = 0
	/// Timer of the next jiggle cycle.
	var/jiggle_timerid
	/// Whether the body hops with each cycle.
	var/jiggle_hop = TRUE
	/// Keeps jiggling through combat mode and busy actions (ERP-driven jiggles).
	var/jiggle_busy_ok = FALSE

/datum/component/breast_animation/proc/start_jiggle(duration, endless = FALSE, costs_stamina = FALSE, hop = TRUE, busy_ok = FALSE)
	var/mob/living/carbon/human/human = parent
	if(jiggling || QDELETED(human))
		return FALSE
	jiggle_endless = endless
	jiggle_costs_stamina = costs_stamina
	jiggle_hop = hop
	jiggle_busy_ok = busy_ok
	jiggle_cycles_left = endless ? 0 : max(1, round(duration / BREAST_JIGGLE_CYCLE, 1))
	RegisterSignals(human, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_MOB_ATTACK_HAND), PROC_REF(on_jiggle_attacking))
	set_jiggling(TRUE)
	jiggle_cycle()
	return TRUE

/datum/component/breast_animation/proc/jiggle_cycle()
	jiggle_timerid = null
	if(QDELETED(src) || !jiggling)
		return
	var/mob/living/carbon/human/human = parent
	if(QDELETED(human) || human.stat != CONSCIOUS || !human.getorganslot(ORGAN_SLOT_BREASTS))
		stop_jiggle()
		return
	if(!jiggle_busy_ok && (human.cmode || human.doing() || !(human.mobility_flags & MOBILITY_STAND)))
		stop_jiggle()
		return
	// Counted before the hop, so a timed jiggle shows the loop for every cycle it pays for.
	if(!jiggle_endless)
		if(jiggle_cycles_left <= 0)
			stop_jiggle()
			return
		jiggle_cycles_left--
	if(jiggle_costs_stamina && !human.jiggle_stamina_is_free())
		var/cycle_cost = BREAST_JIGGLE_STAMINA_PER_SECOND * (BREAST_JIGGLE_CYCLE / (1 SECONDS))
		if(jiggle_endless)
			cycle_cost *= BREAST_JIGGLE_ENDLESS_STAMINA_MULT
		if(!human.adjust_stamina(cycle_cost))
			stop_jiggle()
			return
	if(jiggle_hop)
		human.do_jiggle_hop()
	jiggle_timerid = addtimer(CALLBACK(src, PROC_REF(jiggle_cycle)), BREAST_JIGGLE_CYCLE, TIMER_STOPPABLE)

/datum/component/breast_animation/proc/stop_jiggle()
	if(jiggle_timerid)
		deltimer(jiggle_timerid)
		jiggle_timerid = null
	if(!jiggling)
		return
	jiggle_endless = FALSE
	jiggle_costs_stamina = FALSE
	jiggle_cycles_left = 0
	jiggle_hop = TRUE
	jiggle_busy_ok = FALSE
	if(parent)
		UnregisterSignal(parent, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_MOB_ATTACK_HAND))
	set_jiggling(FALSE)

/// Shots rough enough to shake breasts that have no drawn frames.
GLOBAL_LIST_INIT(breast_rough_shots, list("bounce", "pump2", "pump3", "hit", "slap_b", "fall", "land", "jump"))

/// One jiggle cycle stands in for a one-shot the viewer cannot see from the side or behind.
/datum/component/breast_animation/proc/play_side_shot()
	if(jiggling || !visual || ((visual.vis_flags & VIS_HIDE) && !LAZYLEN(garment_visuals)))
		return
	start_jiggle(BREAST_JIGGLE_CYCLE, FALSE, FALSE, hop = FALSE, busy_ok = TRUE)

/// Without a breasts child, a rough shot plays one generated jiggle cycle instead (sizes 1-4, quad, sextuple).
/datum/component/breast_animation/proc/play_small_shot(shot)
	if(jiggling || !(shot in GLOB.breast_rough_shots))
		return
	var/mob/living/carbon/human/human = parent
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = human.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts || breasts.get_visible_size() < MIN_JIGGLE_BREASTS_SIZE)
		return
	start_jiggle(BREAST_JIGGLE_CYCLE, FALSE, FALSE, hop = FALSE, busy_ok = TRUE)

/// The jiggler's own attack ends the jiggle unless made on help intent.
/datum/component/breast_animation/proc/on_jiggle_attacking(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human = parent
	if(human?.used_intent?.type == INTENT_HELP)
		return
	stop_jiggle()

#undef BREAST_JIGGLE_CYCLE
#undef BREAST_JIGGLE_MIN_DURATION
#undef BREAST_JIGGLE_MAX_DURATION
#undef BREAST_JIGGLE_FREE_DURATION
#undef BREAST_JIGGLE_STAMINA_PER_SECOND
#undef BREAST_JIGGLE_ENDLESS_STAMINA_MULT
#undef BREAST_JIGGLE_HOP_HEIGHT
#undef BREAST_JIGGLE_ENDLESS
#undef BREAST_JIGGLE_PROMPT_STEP
#undef MIN_JIGGLE_BREASTS_SIZE
