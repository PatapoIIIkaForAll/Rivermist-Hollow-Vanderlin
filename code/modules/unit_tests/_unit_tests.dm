//include unit test files in this module in this ifdef

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// A trait source when adding traits through unit tests
#define TRAIT_SOURCE_UNIT_TESTS "unit_tests"

/// For advanced cases, fail unconditionally but don't return (so a test can return multiple results)
#define TEST_FAIL(reason) (Fail(reason || "No reason", __FILE__, __LINE__))

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is not null
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that a parameter is null
#define TEST_ASSERT_NULL(a, reason) if (!isnull(a)) { return Fail("Expected null value but received [a]: [reason || "No reason"]", __FILE__, __LINE__) }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) \
	do { \
		var/lhs = ##a; \
		var/rhs = ##b; \
		if (lhs != rhs) { \
			return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
		} \
	} while (FALSE)

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) \
	do { \
		var/lhs = ##a; \
		var/rhs = ##b; \
		if (lhs == rhs) { \
			return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
		} \
	} while (FALSE)

/// *Only* run the test provided within the parentheses
/// This is useful for debugging when you want to reduce noise, but should never be pushed
/// Intended to be used in the manner of `TEST_FOCUS(/datum/unit_test/math)`
#define TEST_FOCUS(test_path) ##test_path { focus = TRUE; }

/// Logs a noticable message on GitHub, but will not mark as an error.
/// Use this when something shouldn't happen and is of note, but shouldn't block CI.
/// Does not mark the test as failed.
#define TEST_NOTICE(source, message) source.log_for_test((##message), "notice", __FILE__, __LINE__)

/// Constants indicating unit test completion status
#define UNIT_TEST_PASSED 0
#define UNIT_TEST_FAILED 1
#define UNIT_TEST_SKIPPED 2

/// Priority defines
#define TEST_PRE 0
#define TEST_DEFAULT 1
/// After most test steps, used for tests that run long so shorter issues can be noticed faster
#define TEST_LONGER 10
/// This must be the one of last tests to run due to the inherent nature of the test iterating every single tangible atom in the game and qdeleting all of them (while taking long sleeps to make sure the garbage collector fires properly) taking a large amount of time.
#define TEST_CREATE_AND_DESTROY 9001
//Keep this sorted alphabetically

// BEGIN_INCLUDE
#include "ai_combat_flow.dm"
#include "ai_detection_fields.dm"
#include "ai_hazard_avoidance.dm"
#include "ai_horny_hunt.dm"
#include "ai_horny_interruptions.dm"
#include "ai_idle_detection.dm"
#include "ai_npc_reactions.dm"
#include "ai_planning_freezes.dm"
#include "ai_targeting_allegiances.dm"
#include "anchored_mobs.dm"
#include "breast_sized_clothing.dm"
#include "character_creator.dm"
#include "chat_macros.dm"
#include "clothing_tearing.dm"
#include "component_tests.dm"
#include "connect_loc.dm"
#include "container_collision.dm"
#include "craftable_clothes.dm"
#include "craftable_turfs.dm"
#include "create_and_destroy.dm"
#include "defeat_captivity.dm"
#include "defeat_horny_thresholds.dm"
#include "defeat_system.dm"
#include "emote_presentation.dm"
#include "faction_supply_packs.dm"
#include "fire_deaths.dm"
#include "focus_only_tests.dm"
#include "heeled_shoes.dm"
#include "hostile_ai_grab.dm"
#include "impact_marks.dm"
#include "infinite_dungeons.dm"
#include "library_shelves.dm"
#include "live_runtime_regressions.dm"
#include "load_map_security.dm"
#include "lootpanel.dm"
#include "mana_capacity_enchantment.dm"
#include "maneater.dm"
#include "map_landmarks.dm"
#include "mapping.dm"
#include "mindbound_actions.dm"
#include "muffled_speech.dm"
#include "notice_boards.dm"
#include "npc_act_families.dm"
#include "npc_act_text.dm"
#include "npc_knotting.dm"
#include "party_friendly_fire.dm"
#include "piercing_display.dm"
#include "pocket_access.dm"
#include "pocket_dimensions.dm"
#include "preferences_erp.dm"
#include "preferences_preview_construct_cleanup.dm"
#include "preferences_preview_taur_cleanup.dm"
#include "projectiles.dm"
#include "quirk_refusals_and_gore_wounds.dm"
#include "reagent_id_typos.dm"
#include "reagent_names.dm"
#include "reagent_recipe_collisions.dm"
#include "recipe_book_db.dm"
#include "required_map_items.dm"
#include "resist.dm"
#include "rogue_inhands.dm"
#include "roguetown_clothing.dm"
#include "runtime_gc_regressions.dm"
#include "sex_armor_reach.dm"
#include "sex_scene.dm"
#include "spawn_humans.dm"
#include "spawn_mobs.dm"
#include "species_whitelists.dm"
#include "spell_invocations.dm"
#include "spell_names.dm"
#include "spell_shapeshift.dm"
#include "startup.dm"
#include "subsystem_init.dm"
#include "surgeries.dm"
#include "timer_sanity.dm"
#include "unit_test.dm"
#include "voice_sounds.dm"
#include "weapon_icons.dm"
#include "womb_pairing.dm"
// END_INCLUDE

#ifdef REFERENCE_TRACKING_DEBUG //Don't try and parse this file if ref tracking isn't turned on. IE: don't parse ref tracking please mr linter
#include "find_reference_sanity.dm"
#endif

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
#endif
