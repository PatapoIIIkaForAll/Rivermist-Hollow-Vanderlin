#ifdef UNIT_TESTS

// Local asserts: the shared TEST_ASSERT macros are undefined after _unit_tests.dm.
#define AD_ASSERT(assertion, reason) if(!(assertion)) { return Fail("Assertion failed: [reason]", __FILE__, __LINE__) }
#define AD_ASSERT_NULL(a, reason) if(!isnull(a)) { return Fail("Expected null value but received [a]: [reason]", __FILE__, __LINE__) }
#define AD_ASSERT_NOTNULL(a, reason) if(isnull(a)) { return Fail("Expected non-null value: [reason]", __FILE__, __LINE__) }
#define AD_ASSERT_EQUAL(a, b, message) if((a) != (b)) { return Fail("Expected [a] to be equal to [b]. [message]", __FILE__, __LINE__) }

/// Counts orgasm progress change signals.
/datum/arousal_display_probe
	var/changes = 0

/datum/arousal_display_probe/proc/on_change(datum/source, new_progress)
	SIGNAL_HANDLER
	changes++

/// The panel bar, the heart and the glow share one display scale.
/datum/unit_test/arousal_display_scale/Run()
	AD_ASSERT_EQUAL(arousal_display_percent(0), 0, "arousal 0 should show an empty bar")
	AD_ASSERT_EQUAL(arousal_display_percent(60), 50, "arousal 60 should show a half bar")
	AD_ASSERT_EQUAL(arousal_display_percent(120), 100, "arousal 120 should show a full bar")
	AD_ASSERT_EQUAL(arousal_display_percent(300), 100, "arousal above the scale should cap at a full bar")

	AD_ASSERT_EQUAL(arousal_heart_step(0), 0, "arousal 0 should show an empty heart")
	AD_ASSERT_EQUAL(arousal_heart_step(60), 5, "arousal 60 should fill half the heart")
	AD_ASSERT_EQUAL(arousal_heart_step(120), AROUSAL_HEART_STEPS, "arousal 120 should fill the heart")
	AD_ASSERT_EQUAL(arousal_heart_step(300), AROUSAL_HEART_STEPS, "arousal above the scale should keep the heart full")

	AD_ASSERT(!is_highly_aroused(120), "arousal 120 is full, not above the scale")
	AD_ASSERT(is_highly_aroused(300), "arousal 300 is above the scale")

/// The heart button follows arousal changes on its owner.
/datum/unit_test/arousal_display_heart_follows_arousal/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/datum/hud/human/hud = new(human)
	AD_ASSERT_NOTNULL(hud.interact_heart, "the human hud should hold its interact heart")

	SEND_SIGNAL(human, COMSIG_SEX_SET_AROUSAL, 60)
	AD_ASSERT_EQUAL(hud.interact_heart.fill_step, 5, "arousal 60 should fill half the heart button")
	AD_ASSERT(!hud.interact_heart.glowing, "arousal 60 should not glow")

	SEND_SIGNAL(human, COMSIG_SEX_SET_AROUSAL, 300)
	AD_ASSERT_EQUAL(hud.interact_heart.fill_step, AROUSAL_HEART_STEPS, "arousal 300 should fill the heart button")
	AD_ASSERT(hud.interact_heart.glowing, "arousal above the scale should make the heart glow")

	qdel(hud)

/// The near-climax edge appears at 70% of the climax threshold and peaks at the threshold.
/datum/unit_test/arousal_display_near_climax_strength/Run()
	var/start = PASSIVE_EJAC_THRESHOLD * NEAR_CLIMAX_EDGE_START
	AD_ASSERT_EQUAL(near_climax_edge_strength(0), 0, "no progress should show no edge")
	AD_ASSERT_EQUAL(near_climax_edge_strength(start - 1), 0, "progress below the start should show no edge")
	AD_ASSERT_EQUAL(near_climax_edge_strength(start), NEAR_CLIMAX_EDGE_START_STRENGTH, "the edge should appear at its start strength")
	var/midpoint = near_climax_edge_strength((start + PASSIVE_EJAC_THRESHOLD) / 2)
	AD_ASSERT(midpoint > NEAR_CLIMAX_EDGE_START_STRENGTH && midpoint < 1, "the edge should grow between the start and the threshold, got [midpoint]")
	AD_ASSERT_EQUAL(near_climax_edge_strength(PASSIVE_EJAC_THRESHOLD), 1, "the edge should peak at the climax threshold")
	AD_ASSERT_EQUAL(near_climax_edge_strength(MAX_ORGASM_PROG), 1, "the edge should stay at its peak past the threshold")

/// The lewd screen effects toggle defaults on and turns the effects off.
/datum/unit_test/arousal_display_pref_toggle/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	AD_ASSERT(lewd_screen_effects_enabled(prefs), "lewd screen effects should default to on")
	prefs.write_preference(/datum/preference/toggle/lewd_screen_effects, FALSE)
	AD_ASSERT(!lewd_screen_effects_enabled(prefs), "turning the toggle off should disable lewd screen effects")
	AD_ASSERT(!lewd_screen_effects_enabled(null), "a mob without preferences has no screen to draw on")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.set_lewd_edge(FULLSCREEN_NEAR_CLIMAX, /atom/movable/screen/fullscreen/lewd/climax_edge, 1)
	human.set_lewd_haze(FULLSCREEN_HAZE_CUMBRAINED, /atom/movable/screen/fullscreen/lewd/haze_cream, TRUE)
	AD_ASSERT_NULL(human.screens[FULLSCREEN_NEAR_CLIMAX], "an edge should not be drawn when effects are off")
	AD_ASSERT_NULL(human.screens[FULLSCREEN_HAZE_CUMBRAINED], "a haze should not be drawn when effects are off")

/// Arousal no longer paints the old pink frame, and orgasm progress reports its changes.
/datum/unit_test/arousal_display_no_love_overlay/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	SEND_SIGNAL(human, COMSIG_SEX_SET_AROUSAL, 200)
	AD_ASSERT_NULL(human.screens["horny"], "arousal should not apply the pink love overlay")

	var/datum/arousal_display_probe/probe = allocate(/datum/arousal_display_probe)
	probe.RegisterSignal(human, COMSIG_SEX_ORGASM_PROG_CHANGED, TYPE_PROC_REF(/datum/arousal_display_probe, on_change))
	SEND_SIGNAL(human, COMSIG_SEX_SET_ORGASM_PROG, 40)
	SEND_SIGNAL(human, COMSIG_SEX_SET_ORGASM_PROG, 40)
	AD_ASSERT_EQUAL(probe.changes, 1, "orgasm progress should signal once per real change")
	probe.UnregisterSignal(human, COMSIG_SEX_ORGASM_PROG_CHANGED)

#undef AD_ASSERT
#undef AD_ASSERT_NULL
#undef AD_ASSERT_NOTNULL
#undef AD_ASSERT_EQUAL

#endif
