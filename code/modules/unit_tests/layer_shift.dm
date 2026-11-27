#ifdef UNIT_TESTS

#define LAYER_NEAR(a, b) (abs((a) - (b)) < 0.001)
/// Local assert: the shared TEST_ASSERT macros are undefined after _unit_tests.dm.
#define LS_ASSERT(assertion, reason) if(!(assertion)) { return Fail("Assertion failed: [reason]", __FILE__, __LINE__) }

/// Layer up/down keybinds: clamping, and reset on lying down, standing up and moving.
/datum/unit_test/layer_shift

/datum/unit_test/layer_shift/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)
	var/standing_layer = initial(dummy.layer)
	LS_ASSERT(LAYER_NEAR(dummy.layer, standing_layer), "Dummy starts at layer [dummy.layer], expected [standing_layer]")

	for(var/i in 1 to 7)
		dummy.shift_layer(1)
	LS_ASSERT(dummy.layer_shift_steps == 5, "Seven presses up should clamp at 5 steps")
	LS_ASSERT(LAYER_NEAR(dummy.layer, standing_layer + 0.05), "Clamped layer is [dummy.layer], expected [standing_layer + 0.05]")

	dummy.set_body_position(LYING_DOWN)
	LS_ASSERT(dummy.layer_shift_steps == 0, "Lying down should clear the layer shift")
	LS_ASSERT(LAYER_NEAR(dummy.layer, LYING_MOB_LAYER), "Lying layer is [dummy.layer], expected [LYING_MOB_LAYER]")

	dummy.shift_layer(-1)
	dummy.shift_layer(-1)
	LS_ASSERT(LAYER_NEAR(dummy.layer, LYING_MOB_LAYER - 0.02), "Lying shifted layer is [dummy.layer], expected [LYING_MOB_LAYER - 0.02]")

	dummy.set_body_position(STANDING_UP)
	LS_ASSERT(dummy.layer_shift_steps == 0, "Standing up should clear the layer shift")
	LS_ASSERT(LAYER_NEAR(dummy.layer, standing_layer), "Standing layer is [dummy.layer], expected [standing_layer]")

	var/turf/next_turf = get_step(dummy, EAST)
	TEST_ASSERT_NOTNULL(next_turf, "No turf east of the dummy")
	dummy.shift_layer(1)
	dummy.forceMove(next_turf)
	LS_ASSERT(dummy.layer_shift_steps == 0, "Moving off the tile should clear the layer shift")
	LS_ASSERT(LAYER_NEAR(dummy.layer, standing_layer), "Layer after moving is [dummy.layer], expected [standing_layer]")

	// A layer set by other code is left alone, and the next press starts from it.
	dummy.shift_layer(1)
	dummy.layer = ABOVE_MOB_LAYER
	dummy.forceMove(run_loc_floor_bottom_left)
	LS_ASSERT(LAYER_NEAR(dummy.layer, ABOVE_MOB_LAYER), "Moving overwrote a layer set by other code: [dummy.layer]")
	dummy.shift_layer(1)
	LS_ASSERT(LAYER_NEAR(dummy.layer, ABOVE_MOB_LAYER + 0.01), "Press after an outside change gave [dummy.layer], expected [ABOVE_MOB_LAYER + 0.01]")
	dummy.forceMove(next_turf)
	LS_ASSERT(LAYER_NEAR(dummy.layer, ABOVE_MOB_LAYER), "Moving should return to the new base layer, got [dummy.layer]")
	TEST_ASSERT_NULL(dummy.layer_shift_base, "Layer shift base should be cleared after a reset")


/// New issue page link built from the repository link.
/datum/unit_test/report_issue_url

/datum/unit_test/report_issue_url/Run()
	var/repo = "https://github.com/example/repo"
	var/body = build_issue_report_body(1234, "Rivermist Hollow", "2026-11-26 17:00:00", "516.1667")
	for(var/expected in list("**Round ID:** 1234", "**Map:** Rivermist Hollow", "**Server time:** 2026-11-26 17:00:00", "**BYOND version:** 516.1667", "### What happened", "### What you expected", "### Steps to reproduce"))
		LS_ASSERT(findtext(body, expected), "Issue body lacks \"[expected]\": [body]")
	var/unknown_body = build_issue_report_body(null, null, null, null)
	LS_ASSERT(findtext(unknown_body, "**Round ID:** unknown"), "Missing round ID should read unknown: [unknown_body]")

	var/with_body = build_issue_report_url(repo, body)
	var/prefix = "[repo]/issues/new?body="
	LS_ASSERT(findtext(with_body, prefix) == 1, "Link with body starts wrong: [with_body]")
	var/encoded = copytext(with_body, length(prefix) + 1)
	LS_ASSERT(!findtext(encoded, " ") && !findtext(encoded, "\n") && !findtext(encoded, "&") && !findtext(encoded, "#"), "Body is not url-encoded: [encoded]")
	LS_ASSERT(findtext(encoded, "%23%23%23+What+happened") && findtext(encoded, "Round+ID%3a"), "Body encoding changed: [encoded]")
	LS_ASSERT(length(with_body) < 2000, "Link is [length(with_body)] characters long")
	LS_ASSERT(!findtext(with_body, "template="), "Link should not name a template: [with_body]")

	var/trailing_slash = build_issue_report_url("[repo]/", null)
	LS_ASSERT(trailing_slash == "[repo]/issues/new", "Trailing slash not dropped: [trailing_slash]")
	TEST_ASSERT_NULL(build_issue_report_url("", body), "Empty repository link should give no link")
	TEST_ASSERT_NULL(build_issue_report_url(null, null), "Unset repository link should give no link")

#undef LAYER_NEAR
#undef LS_ASSERT

#endif
