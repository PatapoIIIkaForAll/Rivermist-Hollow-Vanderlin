#ifdef UNIT_TESTS

// Included after _unit_tests.dm, which undefines these two at its end.
#ifndef TEST_ASSERT
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TOGGLES_MENU_TEST_ASSERT_LOCAL
#endif
#ifndef TEST_ASSERT_EQUAL
#define TEST_ASSERT_EQUAL(a, b, message) \
	do { \
		var/lhs = ##a; \
		var/rhs = ##b; \
		if (lhs != rhs) { \
			return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
		} \
	} while (FALSE)
#define TOGGLES_MENU_TEST_EQUAL_LOCAL
#endif

/// Preferences that count savefile writes instead of touching disk.
/datum/preferences/toggles_menu_probe
	var/saves = 0

/datum/preferences/toggles_menu_probe/save_preferences()
	saves++
	return TRUE

/// Finds a section by name in Toggles window data.
/proc/find_toggles_menu_category(list/data, name)
	for(var/list/category as anything in data["categories"])
		if(category["name"] == name)
			return category
	return null

/// Finds a checkbox row by id anywhere in Toggles window data.
/proc/find_toggles_menu_entry(list/data, id)
	for(var/list/category as anything in data["categories"])
		for(var/list/entry as anything in category["entries"])
			if(entry["id"] == id)
				return entry
	return null

/// Every listed preference names a known section and carries a label and a tooltip; ui_data groups them in section order.
/datum/unit_test/toggles_menu_lists_categories

/datum/unit_test/toggles_menu_lists_categories/Run()
	for(var/key in GLOB.preference_entries_by_key)
		var/datum/preference/pref = GLOB.preference_entries_by_key[key]
		if(!pref.toggles_menu_category)
			continue
		TEST_ASSERT(pref.toggles_menu_category in GLOB.toggles_menu_categories, "[pref.type] names an unknown Toggles section: [pref.toggles_menu_category]")
		TEST_ASSERT(istype(pref, /datum/preference/toggle) || istype(pref, /datum/preference/choiced), "[pref.type] is listed in the Toggles window but is neither a toggle nor a choice")
		TEST_ASSERT(length(pref.toggles_menu_name), "[pref.type] has no Toggles row label")
		TEST_ASSERT(length(pref.toggles_menu_desc), "[pref.type] has no Toggles row tooltip")

	var/datum/preferences/prefs = new
	var/datum/toggle_options_menu/menu = new(prefs)
	var/list/data = menu.ui_data(null)
	var/last_index = 0
	for(var/list/category as anything in data["categories"])
		var/index = GLOB.toggles_menu_categories.Find(category["name"])
		TEST_ASSERT(index > last_index, "Toggles section [category["name"]] is out of order")
		last_index = index
		TEST_ASSERT(length(category["entries"]) || length(category["selects"]), "Toggles section [category["name"]] is empty")

	var/list/display = find_toggles_menu_category(data, "Display")
	TEST_ASSERT_NOTNULL(display, "The Display section is missing")
	var/list/crt = find_toggles_menu_entry(data, "crt")
	TEST_ASSERT_NOTNULL(crt, "The CRT row is missing")
	TEST_ASSERT(crt in display["entries"], "The CRT row is not in the Display section")
	TEST_ASSERT_EQUAL(crt["enabled"], !!prefs.read_preference(/datum/preference/toggle/crt), "The CRT row does not show the saved value")
	TEST_ASSERT_EQUAL(crt["label"], "CRT effect", "The CRT row has the wrong label")
	TEST_ASSERT_NOTNULL(find_toggles_menu_entry(data, "breast_animation"), "The breast animation row is missing")
	TEST_ASSERT_NOTNULL(find_toggles_menu_entry(data, "emote_favourite_stars"), "The emote stars row is missing")
	TEST_ASSERT_NULL(find_toggles_menu_category(data, "Current character"), "A player without a body sees the current character section")

/// A "toggle" action flips the preference and saves it; unknown ids change nothing.
/datum/unit_test/toggles_menu_toggle_saves

/datum/unit_test/toggles_menu_toggle_saves/Run()
	var/datum/preferences/toggles_menu_probe/prefs = new
	var/datum/toggle_options_menu/menu = new(prefs)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/tgui/window = allocate(/datum/tgui, user, menu, "ToggleOptionsMenu")
	window.status = UI_INTERACTIVE
	usr = user

	prefs.saves = 0 // Making the datum saves once.
	var/before = prefs.read_preference(/datum/preference/toggle/showrolls)
	TEST_ASSERT(menu.ui_act("toggle", list("id" = "showrolls"), window, window.state), "The toggle action was refused")
	TEST_ASSERT_EQUAL(prefs.read_preference(/datum/preference/toggle/showrolls), !before, "The toggle action did not flip Show rolls")
	TEST_ASSERT_EQUAL(prefs.saves, 1, "The toggle action did not save the preferences")
	var/list/row = find_toggles_menu_entry(menu.ui_data(user), "showrolls")
	TEST_ASSERT_EQUAL(row["enabled"], !before, "The window does not show the new value")

	TEST_ASSERT(!menu.ui_act("toggle", list("id" = "real_name"), window, window.state), "A preference outside the window was toggled")
	TEST_ASSERT(!menu.ui_act("toggle", list("id" = 5), window, window.state), "A non-text id was accepted")
	TEST_ASSERT_EQUAL(prefs.saves, 1, "A refused action saved the preferences")
	usr = null

/// Admin-only rows stay out of the window and cannot be toggled by a player who is not an admin.
/datum/unit_test/toggles_menu_admin_rows

/datum/unit_test/toggles_menu_admin_rows/Run()
	var/datum/preferences/toggles_menu_probe/prefs = new
	var/datum/toggle_options_menu/menu = new(prefs)
	var/list/data = menu.ui_data(null)
	TEST_ASSERT_NULL(find_toggles_menu_category(data, "Admin"), "A player who is not an admin sees the Admin section")
	TEST_ASSERT_NULL(find_toggles_menu_entry(data, "admin_new_menu"), "A player who is not an admin sees the New-Adm. menu row")
	TEST_ASSERT_NULL(find_toggles_menu_entry(data, "admin_classic_context_menu"), "A player who is not an admin sees the classic right-click row")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/tgui/window = allocate(/datum/tgui, user, menu, "ToggleOptionsMenu")
	window.status = UI_INTERACTIVE
	usr = user
	prefs.saves = 0
	var/before = prefs.read_preference(/datum/preference/toggle/admin_new_menu)
	TEST_ASSERT(!menu.ui_act("toggle", list("id" = "admin_new_menu"), window, window.state), "A player who is not an admin toggled an admin row")
	TEST_ASSERT_EQUAL(prefs.read_preference(/datum/preference/toggle/admin_new_menu), before, "An admin row changed for a player who is not an admin")
	TEST_ASSERT_EQUAL(prefs.saves, 0, "A refused admin toggle saved the preferences")
	usr = null

/// The emote panel payload carries the star setting, and the Toggles row changes it.
/datum/unit_test/emote_panel_star_setting

/datum/unit_test/emote_panel_star_setting/Run()
	var/datum/preferences/toggles_menu_probe/prefs = new
	var/list/payload = prefs.get_emote_panel_payload()
	TEST_ASSERT_EQUAL(payload["stars"], TRUE, "Emote stars should show by default")
	TEST_ASSERT(islist(payload["favourites"]), "The payload lost the favourites list")

	var/datum/preference/toggle/pref = GLOB.preference_entries[/datum/preference/toggle/emote_favourite_stars]
	prefs.saves = 0
	pref.toggles_menu_toggle(prefs)
	TEST_ASSERT_EQUAL(prefs.get_emote_panel_payload()["stars"], FALSE, "Turning the stars off does not reach the emote panel payload")
	TEST_ASSERT_EQUAL(prefs.saves, 1, "Turning the stars off was not saved")

#ifdef TOGGLES_MENU_TEST_ASSERT_LOCAL
#undef TEST_ASSERT
#undef TOGGLES_MENU_TEST_ASSERT_LOCAL
#endif
#ifdef TOGGLES_MENU_TEST_EQUAL_LOCAL
#undef TEST_ASSERT_EQUAL
#undef TOGGLES_MENU_TEST_EQUAL_LOCAL
#endif

#endif
