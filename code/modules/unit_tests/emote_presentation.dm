/// The emote name carries the voice colour while the face shows, and drops it behind a mask.
/datum/unit_test/emote_name_voice_color

/datum/unit_test/emote_name_voice_color/Run()
	var/mob/living/carbon/human/emoter = allocate(/mob/living/carbon/human)
	emoter.voice_color = "a1b2c3"
	TEST_ASSERT_EQUAL(emoter.get_emote_name_color(), "a1b2c3", "A visible face lost its voice colour")
	TEST_ASSERT(findtext(emoter.get_emote_name_html(), "color:#a1b2c3"), "The emote name is not tinted")

	emoter.voicecolor_override = "0f0f0f"
	TEST_ASSERT_EQUAL(emoter.get_emote_name_color(), "0f0f0f", "The colour override is ignored")
	emoter.voicecolor_override = null

	var/obj/item/clothing/face/facemask/mask = allocate(/obj/item/clothing/face/facemask)
	emoter.equip_to_slot_if_possible(mask, ITEM_SLOT_MASK)
	TEST_ASSERT_EQUAL(emoter.wear_mask, mask, "The mask was not worn")
	TEST_ASSERT_NULL(emoter.get_emote_name_color(), "A hidden face still shows the voice colour")
	TEST_ASSERT(!findtext(emoter.get_emote_name_html(), "color:"), "A hidden face got a tinted name")
	TEST_ASSERT(findtext(emoter.get_emote_name_html(), "<b>"), "The plain name lost its bold")

	emoter.dropItemToGround(mask, force = TRUE)
	TEST_ASSERT_EQUAL(emoter.get_emote_name_color(), "a1b2c3", "Taking the mask off did not bring the colour back")

/// Every emote verb sits in a known emote sub-group, never the bare tab.
/datum/unit_test/emote_verb_groups

/datum/unit_test/emote_verb_groups/Run()
	var/static/list/known_groups = list("Emotes.Noises", "Emotes.Silent", "Emotes.Rolling", "Emotes.Wildtongue")
	// Hidden typed commands; procpath.hidden reads false at runtime, so they are named here.
	var/static/list/command_only = list(/mob/living/carbon/human/verb/emote_meditate)
	var/mob/living/carbon/human/emoter = allocate(/mob/living/carbon/human)
	TEST_ASSERT(length(emoter.verbs), "The human has no verbs")
	var/emote_verbs = 0
	for(var/procpath/verb_path as anything in emoter.verbs)
		if(verb_path in command_only)
			continue
		var/category = verb_path.category
		var/is_emote_verb = findtext("[verb_path]", "/verb/emote_")
		if(!is_emote_verb && !findtext(category, "Emotes"))
			continue
		emote_verbs++
		TEST_ASSERT(category in known_groups, "[verb_path] ([verb_path.name]) is in emote group '[category]'")
	TEST_ASSERT(emote_verbs > 50, "Only [emote_verbs] emote verbs found")

	var/list/expected = list(
		/mob/living/carbon/human/verb/emote_strength_roll = "Emotes.Rolling",
		/mob/living/carbon/human/verb/emote_charisma_roll = "Emotes.Rolling",
		/mob/living/carbon/human/verb/emote_bjiggle = "Emotes.Silent",
	)
	for(var/procpath/verb_path as anything in emoter.verbs)
		if(verb_path in expected)
			TEST_ASSERT_EQUAL(verb_path.category, expected[verb_path], "[verb_path] is in the wrong group")
			expected -= verb_path
	TEST_ASSERT(!length(expected), "Verbs missing from the human: [jointext(expected, ", ")]")

/// A gesture builds one image over the head and refuses to stack while it still plays.
/datum/unit_test/emote_gesture_overhead

/datum/unit_test/emote_gesture_overhead/Run()
	var/mob/living/carbon/human/gesturer = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)

	TEST_ASSERT_NULL(gesturer.show_gesture(target, "wavefriendly"), "A gesture with no client viewers made an image")
	TEST_ASSERT(COOLDOWN_FINISHED(gesturer, gesture_cooldown), "An unseen gesture started the cooldown")

	var/image/first = gesturer.play_gesture(list(), "wavefriendly")
	TEST_ASSERT_NOTNULL(first, "The gesture made no image")
	TEST_ASSERT_EQUAL(first.icon_state, "wavefriendly", "Wrong gesture state")
	TEST_ASSERT_EQUAL(first.loc, gesturer, "The gesture is not attached to the gesturer")
	TEST_ASSERT_EQUAL(first.plane, ABOVE_LIGHTING_PLANE, "The gesture is not above the lighting")
	TEST_ASSERT(first.pixel_y > 0, "The gesture is not raised over the head")

	TEST_ASSERT_NULL(gesturer.play_gesture(list(), "beckon"), "A second gesture stacked on the first")

	COOLDOWN_RESET(gesturer, gesture_cooldown)
	var/image/second = gesturer.play_gesture(list(), "beckon")
	TEST_ASSERT_NOTNULL(second, "No gesture after the cooldown ended")
	TEST_ASSERT(second != first, "The gesture image was reused")
	TEST_ASSERT_EQUAL(second.icon_state, "beckon", "Wrong second gesture state")

/// Every overhead state the code asks for is in the art, so no gesture plays as a blank square.
/datum/unit_test/emote_gesture_art_states

/datum/unit_test/emote_gesture_art_states/Run()
	var/list/gesture_states = icon_states('modular_rmh/icons/mob/gestures.dmi')
	for(var/state in list("wavefriendly", "beckon", "dismiss", "taunt", "midfinger", "thumbsdown"))
		TEST_ASSERT(state in gesture_states, "gestures.dmi has no \"[state]\" state")
	TEST_ASSERT("yield" in icon_states('modular_rmh/icons/mob/yield.dmi'), "yield.dmi has no \"yield\" state")

/// A knocked-out character carries the yield marker over their head until the knockout ends.
/datum/unit_test/emote_yield_indicator

/datum/unit_test/emote_yield_indicator/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	// Defeat only takes a character with no client when the AI opt-in is set.
	victim.defeat_system_ai_opt_in = TRUE
	TEST_ASSERT(!(locate(/obj/effect/yield_indicator) in victim.vis_contents), "A standing character already carries the yield marker")

	TEST_ASSERT(victim.enter_defeat(DEFEAT_REASON_DAMAGE, DEFEAT_SEVERITY_NORMAL), "Test setup: the character should enter defeat")
	var/datum/status_effect/defeat_knockout/knockout = victim.has_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT_NOTNULL(knockout, "Test setup: defeat should apply the knockout")
	var/obj/effect/yield_indicator/marker = knockout.yield_indicator
	TEST_ASSERT_NOTNULL(marker, "A knockout should make the yield marker")
	TEST_ASSERT(marker in victim.vis_contents, "The yield marker should be shown over the knocked-out character")
	TEST_ASSERT_EQUAL(marker.plane, ABOVE_LIGHTING_PLANE, "The yield marker should sit above the lighting")
	TEST_ASSERT(marker.pixel_y > 0, "The yield marker should be raised over the head")

	victim.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(!(marker in victim.vis_contents), "Waking up should take the yield marker away")
	TEST_ASSERT_NULL(knockout.yield_indicator, "The knockout should drop its yield marker")

/// The surrender procs set and clear the yield with no dialog; a pacifist keeps pacifism afterwards.
/datum/unit_test/yield_surrender_procs

/datum/unit_test/yield_surrender_procs/Run()
	var/mob/living/carbon/human/yielder = allocate(/mob/living/carbon/human)
	TEST_ASSERT(yielder.surrender(), "The surrender proc did not start a yield")
	TEST_ASSERT(yielder.surrendering, "Surrender did not set surrendering")
	TEST_ASSERT(HAS_TRAIT(yielder, TRAIT_PACIFISM), "Surrender did not add pacifism")
	TEST_ASSERT(yielder.IsKnockdown(), "Surrender did not knock the yielder down")
	TEST_ASSERT(!yielder.surrender(), "A second surrender started another yield")

	TEST_ASSERT(yielder.rescind_surrender(), "The rescind proc did not end the yield")
	TEST_ASSERT(!yielder.surrendering, "Rescinding left surrendering set")
	TEST_ASSERT(!HAS_TRAIT(yielder, TRAIT_PACIFISM), "Rescinding left pacifism on")
	TEST_ASSERT(!yielder.rescind_surrender(), "Rescinding with no yield reported success")

	ADD_TRAIT(yielder, TRAIT_PACIFISM, TRAIT_SOURCE_UNIT_TESTS)
	yielder.surrender()
	yielder.rescind_surrender()
	TEST_ASSERT(HAS_TRAIT(yielder, TRAIT_PACIFISM), "Rescinding took pacifism from a pacifist")
	REMOVE_TRAIT(yielder, TRAIT_PACIFISM, TRAIT_SOURCE_UNIT_TESTS)

/// Being told to yield in a fight gives a "Yield?" alert; a click yields, and the alert ends with the prompt.
/datum/unit_test/yield_prompt

/datum/unit_test/yield_prompt/Run()
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/dead = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/yielding = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human)
	speaker.fully_replace_character_name(null, "Yield Asker")

	TEST_ASSERT_NULL(target.prompt_yield_to(speaker, 7), "A mob that is not fighting the speaker got the prompt")
	for(var/mob/living/carbon/human/fighter as anything in list(target, dead, yielding))
		fighter.set_last_attacker(speaker)
	TEST_ASSERT_NULL(target.prompt_yield_to(speaker, 7), "A past hit with nobody in combat mode counted as a fight")
	speaker.cmode = TRUE

	TEST_ASSERT_NULL(speaker.prompt_yield_to(speaker, 7), "The speaker prompted themselves")
	TEST_ASSERT_NULL(stranger.prompt_yield_to(speaker, 7), "A bystander got the prompt")
	dead.set_stat(DEAD)
	TEST_ASSERT_NULL(dead.prompt_yield_to(speaker, 7), "A dead mob got the prompt")
	yielding.surrendering = TRUE
	TEST_ASSERT_NULL(yielding.prompt_yield_to(speaker, 7), "A yielding mob got the prompt")
	yielding.surrendering = FALSE

	speaker.offer_yield_prompts(list(target), 7)
	TEST_ASSERT_NULL(target.has_status_effect(/datum/status_effect/yield_prompt), "A hearer with no client got the prompt")

	var/datum/status_effect/yield_prompt/prompt = target.prompt_yield_to(speaker, 7)
	TEST_ASSERT_NOTNULL(prompt, "The mob fighting the speaker did not get the prompt")
	TEST_ASSERT_EQUAL(prompt.asker_name, "Yield Asker", "The prompt does not name the asker")
	var/atom/movable/screen/alert/status_effect/yield_prompt/alert = target.alerts[prompt.id]
	TEST_ASSERT_NOTNULL(alert, "The prompt threw no alert")
	TEST_ASSERT_EQUAL(alert.attached_effect, prompt, "The alert is not tied to the prompt")
	TEST_ASSERT_EQUAL(alert.desc, "Click to yield to Yield Asker.", "Wrong alert description")

	prompt.duration = world.time + 1
	target.prompt_yield_to(speaker, 7)
	TEST_ASSERT_EQUAL(target.has_status_effect(/datum/status_effect/yield_prompt), prompt, "A second call made a second prompt")
	TEST_ASSERT(prompt.duration > world.time + 10 SECONDS, "A second call did not refresh the timer")

	TEST_ASSERT(prompt.accept(), "Accepting the prompt did not yield")
	TEST_ASSERT(target.surrendering, "Accepting the prompt left the mob fighting")
	TEST_ASSERT(QDELETED(prompt), "Accepting did not end the prompt")
	TEST_ASSERT_NULL(target.alerts["yield_prompt"], "Accepting left the alert up")
	TEST_ASSERT_NULL(target.prompt_yield_to(speaker, 7), "A yielded mob got another prompt")

	stranger.set_last_attacker(speaker)
	prompt = stranger.prompt_yield_to(speaker, 7)
	TEST_ASSERT_NOTNULL(prompt, "Test setup: the stranger should now get the prompt")
	prompt.duration = world.time - 1
	prompt.process()
	TEST_ASSERT(QDELETED(prompt), "The prompt outlived its timer")
	TEST_ASSERT_NULL(stranger.alerts["yield_prompt"], "The timed-out prompt left its alert")

	prompt = stranger.prompt_yield_to(speaker, 7)
	TEST_ASSERT_NOTNULL(prompt, "Test setup: the stranger should get a new prompt")
	stranger.set_stat(UNCONSCIOUS)
	TEST_ASSERT(QDELETED(prompt), "The prompt stayed on an unconscious mob")
	TEST_ASSERT_NULL(stranger.alerts["yield_prompt"], "An unconscious mob kept the alert")
	stranger.set_stat(CONSCIOUS)

	prompt = stranger.prompt_yield_to(speaker, 7)
	TEST_ASSERT_NOTNULL(prompt, "Test setup: the stranger should get a third prompt")
	stranger.surrender()
	TEST_ASSERT(QDELETED(prompt), "Yielding by other means left the prompt up")
	speaker.cmode = FALSE
