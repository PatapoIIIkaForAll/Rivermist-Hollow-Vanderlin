#ifdef UNIT_TESTS

// Included after _unit_tests.dm, which undefines the shared assert macros.
#define CTW_ASSERT_EQUAL(a, b, message) \
	do { \
		var/lhs = ##a; \
		var/rhs = ##b; \
		if (lhs != rhs) { \
			return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs]. [message]", __FILE__, __LINE__); \
		} \
	} while (FALSE)

/// The chat span macros and act line colours produce the climax, oviposition and force tier classes.
/datum/unit_test/chat_text_spans/Run()
	CTW_ASSERT_EQUAL(span_love_climax("x"), "<span class='love_climax'>x</span>", "climax lines use the climax class")
	CTW_ASSERT_EQUAL(span_ovi("x"), "<span class='ovi'>x</span>", "oviposition lines use the ovi class")

	var/datum/sex_action/sex/vaginal/action = allocate(/datum/sex_action/sex/vaginal)
	CTW_ASSERT_EQUAL(action.colour_act_line("x", "climax"), "<span class='love_climax'>x</span>", "NPC climax beats use the climax class")
	CTW_ASSERT_EQUAL(action.colour_act_line("x", "ovi"), "<span class='ovi'>x</span>", "NPC egg beats use the ovi class")

	var/list/force_classes = list(
		"[SEX_FORCE_LOW]" = "love_low",
		"[SEX_FORCE_MID]" = "love_mid",
		"[SEX_FORCE_HIGH]" = "love_high",
		"[SEX_FORCE_EXTREME]" = "love_extreme",
		"[SEX_FORCE_UNRELENTING]" = "love_extreme",
	)
	for(var/force_key in force_classes)
		action.force = text2num(force_key)
		CTW_ASSERT_EQUAL(action.spanify_force("x"), "<span class='[force_classes[force_key]]'>x</span>", "force [force_key] picks its tier")

/// Windows with no theme or the house theme get the player's window style; the default is the gradient look.
/datum/unit_test/window_style_theme/Run()
	var/datum/preferences/prefs = allocate(/datum/preferences)
	CTW_ASSERT_EQUAL(get_tgui_window_theme(prefs), "vanderlin", "the default window style is the gradient Vanderlin theme")
	prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/window_style], "Vanderlin classic")
	CTW_ASSERT_EQUAL(get_tgui_window_theme(prefs), "vanderlin-classic", "the classic choice picks the flat theme")
	prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/window_style], "Vanderlin")
	CTW_ASSERT_EQUAL(get_tgui_window_theme(prefs), "vanderlin", "switching back picks the gradient theme")
	CTW_ASSERT_EQUAL(get_tgui_window_theme(null), "vanderlin", "a window without preferences gets the gradient theme")

	var/datum/preference/choiced/window_style/style = GLOB.preference_entries[/datum/preference/choiced/window_style]
	CTW_ASSERT_EQUAL(style.toggles_menu_category, "Interface", "the window style is listed in the Toggles window")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/datum/tgui/ui = allocate(/datum/tgui, user, user, "WindowStyleProbe")
	var/list/payload = ui.get_payload(null, FALSE, FALSE)
	CTW_ASSERT_EQUAL(payload["config"]["window"]["theme"], "vanderlin", "the window config sends the player's style instead of grim")

#undef CTW_ASSERT_EQUAL

#endif
