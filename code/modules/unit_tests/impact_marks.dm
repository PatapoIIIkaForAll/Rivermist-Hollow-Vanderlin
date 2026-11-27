// The lipstick spot defines live in a module the unit tests are compiled before,
// so name the spots here instead. Values follow modular_rmh/modular/lipstick_marks/_lipstick_defines.dm.
#define SPOT_BUTT "butt"
#define SPOT_CHEST "chest"
#define SPOT_L_THIGH "l_thigh"
#define SPOT_BACK "back"
#define SPOT_BELLY "belly"
#define SPOT_L_ARM "l_arm"
#define SPOT_R_ARM "r_arm"
#define SPOT_L_HAND "l_hand"
#define SPOT_R_HAND "r_hand"
#define SPOT_R_THIGH "r_thigh"
#define SPOT_L_FOOT "l_foot"
#define SPOT_R_FOOT "r_foot"
#define SPOT_CHEEK "cheek"
#define SPOT_FOREHEAD "forehead"
#define SPOT_NOSE "nose"
#define SPOT_LIPS "lips"
#define SPOT_EAR "ear"
#define SPOT_NECK "neck"

/// Mark level rises with the act's force, the striker's strength and the tool tier.
/datum/unit_test/impact_mark_level_scales/Run()
	var/base = IMPACT_MARK_STRENGTH_BASE
	TEST_ASSERT_EQUAL(get_impact_mark_level(1, base, IMPACT_TOOL_HAND), IMPACT_MARK_NONE, "A light bare slap should leave no mark")
	TEST_ASSERT_EQUAL(get_impact_mark_level(2, base, IMPACT_TOOL_HAND), IMPACT_MARK_FAINT, "A firm bare slap should leave a faint mark")
	TEST_ASSERT_EQUAL(get_impact_mark_level(4, base, IMPACT_TOOL_HAND), IMPACT_MARK_RED, "A brutal bare slap should leave a red mark")
	TEST_ASSERT_EQUAL(get_impact_mark_level(5, base, IMPACT_TOOL_WHIP), IMPACT_MARK_BRUISED, "An unrelenting whip strike should bruise")

	// One tool tier and one strength step are each worth one score point.
	TEST_ASSERT(get_impact_mark_level(3, base, IMPACT_TOOL_WHIP) > get_impact_mark_level(3, base, IMPACT_TOOL_HAND), "A whip should mark harder than a bare hand")
	TEST_ASSERT(get_impact_mark_level(3, base, IMPACT_TOOL_STRAP) >= get_impact_mark_level(3, base, IMPACT_TOOL_HAND), "A strap should mark at least as hard as a bare hand")
	var/strong = base + (IMPACT_MARK_STRENGTH_STEP * 2)
	var/weak = base - (IMPACT_MARK_STRENGTH_STEP * 2)
	TEST_ASSERT(get_impact_mark_level(3, strong, IMPACT_TOOL_HAND) > get_impact_mark_level(3, weak, IMPACT_TOOL_HAND), "A stronger striker should leave a heavier mark")
	TEST_ASSERT(get_impact_mark_level(5, strong, IMPACT_TOOL_WHIP) <= IMPACT_MARK_MAX, "No strike should pass the heaviest mark")

/// Tool tier reads the item: a bare hand, a toy's own tier, a whip, else a strap.
/datum/unit_test/impact_mark_tool_tiers/Run()
	TEST_ASSERT_EQUAL(get_impact_tool_tier(null), IMPACT_TOOL_HAND, "No tool should count as a bare hand")
	var/obj/item/weapon/whip/whip = allocate(/obj/item/weapon/whip)
	TEST_ASSERT_EQUAL(get_impact_tool_tier(whip), IMPACT_TOOL_WHIP, "A whip should use the whip tier")
	var/obj/item/storage/belt/leather/belt = allocate(/obj/item/storage/belt/leather)
	TEST_ASSERT_EQUAL(get_impact_tool_tier(belt), IMPACT_TOOL_STRAP, "Any other held tool should use the strap tier")
	for(var/toy_type in subtypesof(/obj/item/impact_toy))
		var/obj/item/impact_toy/toy = allocate(toy_type)
		TEST_ASSERT_EQUAL(get_impact_tool_tier(toy), toy.impact_mark_tier, "[toy_type] should use its own tier")

/// A strike lands on the spot its targeting-doll zone covers; the groin marks the butt.
/datum/unit_test/impact_mark_spots/Run()
	TEST_ASSERT_EQUAL(get_impact_mark_spot(BODY_ZONE_PRECISE_GROIN), SPOT_BUTT, "A strike to the groin should land on the butt")
	TEST_ASSERT_EQUAL(get_impact_mark_spot(BODY_ZONE_CHEST), SPOT_CHEST, "A strike to the chest should land on the chest")
	TEST_ASSERT_EQUAL(get_impact_mark_spot(BODY_ZONE_L_LEG), SPOT_L_THIGH, "A strike to the left leg should land on the left thigh")
	TEST_ASSERT_NULL(get_impact_mark_spot("not a zone"), "An unknown zone should land nowhere")

/// A spot keeps one entry at the heavier level, and any later strike restarts its fade.
/datum/unit_test/impact_mark_records_strikes/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	var/mob/living/carbon/human/striker = allocate(/mob/living/carbon/human/species/human/northern)

	TEST_ASSERT_EQUAL(body.take_impact_mark(striker, BODY_ZONE_PRECISE_GROIN, 1, null), IMPACT_MARK_NONE, "A light bare slap should leave nothing")
	TEST_ASSERT(!length(body.impact_marks), "A strike that marks nothing should record nothing")

	var/heavy = body.take_impact_mark(striker, BODY_ZONE_PRECISE_GROIN, 4, null)
	TEST_ASSERT(heavy > IMPACT_MARK_NONE, "A brutal slap should leave a mark")
	var/list/mark = body.impact_marks[SPOT_BUTT]
	TEST_ASSERT_NOTNULL(mark, "The mark should be recorded on the butt")
	TEST_ASSERT_EQUAL(mark[IMPACT_MARK_LEVEL], heavy, "The entry should hold the level the strike left")
	TEST_ASSERT(!mark[IMPACT_MARK_BY_TOOL], "A bare slap should not read as a tool mark")

	// A lighter strike keeps the heavier level but still restarts the fade.
	mark[IMPACT_MARK_TIME] = world.time - 1
	body.take_impact_mark(striker, BODY_ZONE_PRECISE_GROIN, 2, null)
	TEST_ASSERT_EQUAL(length(body.impact_marks), 1, "A second strike on one spot should keep one entry")
	mark = body.impact_marks[SPOT_BUTT]
	TEST_ASSERT_EQUAL(mark[IMPACT_MARK_LEVEL], heavy, "A lighter strike should not lower the mark")
	TEST_ASSERT_EQUAL(mark[IMPACT_MARK_TIME], world.time, "Any strike should restart the fade")

	var/obj/item/weapon/whip/whip = allocate(/obj/item/weapon/whip)
	body.take_impact_mark(striker, BODY_ZONE_CHEST, 4, whip)
	TEST_ASSERT_EQUAL(length(body.impact_marks), 2, "A strike on another spot should add its own entry")
	TEST_ASSERT(body.impact_marks[SPOT_CHEST][IMPACT_MARK_BY_TOOL], "A whip strike should read as a tool mark")

/// Marks step down one level at a time and clear once the lightest has faded.
/datum/unit_test/impact_mark_fades_away/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	body.add_impact_mark(SPOT_BUTT, IMPACT_MARK_RED, FALSE)
	var/list/mark = body.impact_marks[SPOT_BUTT]
	TEST_ASSERT_EQUAL(mark[IMPACT_MARK_LEVEL], IMPACT_MARK_RED, "Test setup: the mark should start red")

	// Not due yet, so nothing moves.
	body.process_impact_mark_fade()
	TEST_ASSERT_EQUAL(body.impact_marks[SPOT_BUTT][IMPACT_MARK_LEVEL], IMPACT_MARK_RED, "A mark should not fade before its time")

	mark[IMPACT_MARK_TIME] = world.time - get_impact_mark_fade_time(IMPACT_MARK_RED)
	body.process_impact_mark_fade()
	TEST_ASSERT_EQUAL(body.impact_marks[SPOT_BUTT][IMPACT_MARK_LEVEL], IMPACT_MARK_FAINT, "A due red mark should step down to faint")

	mark = body.impact_marks[SPOT_BUTT]
	mark[IMPACT_MARK_TIME] = world.time - get_impact_mark_fade_time(IMPACT_MARK_FAINT)
	body.process_impact_mark_fade()
	TEST_ASSERT(!length(body.impact_marks), "A due faint mark should clear the spot")

/// Only bare spots are described; clothes hide the mark and observers see every one.
/datum/unit_test/impact_mark_visibility/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	body.add_impact_mark(SPOT_BUTT, IMPACT_MARK_RED, FALSE)
	TEST_ASSERT(SPOT_BUTT in body.get_visible_impact_mark_spots(body), "A bare butt should show its mark")

	var/obj/item/clothing/pants/trou = allocate(/obj/item/clothing/pants/trou)
	body.equip_to_slot_or_del(trou, ITEM_SLOT_PANTS)
	TEST_ASSERT_EQUAL(body.wear_pants, trou, "Test setup: the trousers should be worn")
	TEST_ASSERT(!(SPOT_BUTT in body.get_visible_impact_mark_spots(body)), "Trousers should hide the mark")

	var/list/pronouns = list(THEIR = body.p_their(), THEYVE = "[body.p_they(TRUE)] [body.p_have()]")
	TEST_ASSERT_NULL(body.get_impact_mark_line(body, pronouns), "A hidden mark should add no examine line")

	body.dropItemToGround(trou, force = TRUE)
	TEST_ASSERT(SPOT_BUTT in body.get_visible_impact_mark_spots(body), "Taking the trousers off should show the mark again")
	var/line = body.get_impact_mark_line(body, pronouns)
	TEST_ASSERT_NOTNULL(line, "A bare mark should add an examine line")
	TEST_ASSERT(findtext(line, "red"), "A red mark should be called red: [line]")

/// Marks sate a masochist who takes them and a sadist who leaves them, no sooner than the cooldown.
/datum/unit_test/impact_mark_sates_vices/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	var/mob/living/carbon/human/striker = allocate(/mob/living/carbon/human/species/human/northern)
	body.add_quirk(/datum/quirk/negative/addiction/masochist)
	striker.add_quirk(/datum/quirk/negative/addiction/sadist)
	var/datum/quirk/negative/addiction/masochist/masochist = body.get_quirk(/datum/quirk/negative/addiction/masochist)
	var/datum/quirk/negative/addiction/sadist = striker.get_quirk(/datum/quirk/negative/addiction/sadist)
	TEST_ASSERT_NOTNULL(masochist, "Test setup: the struck body needs the masochist vice")
	TEST_ASSERT_NOTNULL(sadist, "Test setup: the striker needs the sadist vice")
	// The masochist vice overrides sate() and pushes its pain craving out instead of setting the shared flag.
	masochist.next_paincrave = world.time - 1
	sadist.sated = FALSE

	var/level = body.take_impact_mark(striker, BODY_ZONE_PRECISE_GROIN, 4, null)
	TEST_ASSERT(level > IMPACT_MARK_NONE, "Test setup: the strike should leave a mark")
	TEST_ASSERT(masochist.next_paincrave > world.time, "Taking a mark should sate a masochist")
	TEST_ASSERT(sadist.sated, "Leaving a mark should sate the striking sadist")
	var/masochist_until = masochist.next_mark_sate
	TEST_ASSERT(masochist_until > world.time, "Sating should arm the mark cooldown")
	TEST_ASSERT_EQUAL(masochist_until - world.time, get_impact_mark_sate_cooldown(level), "The cooldown should follow the mark level")

	// A second strike inside the cooldown must not sate again, so marks cannot be farmed.
	masochist.next_paincrave = world.time - 1
	sadist.sated = FALSE
	body.take_impact_mark(striker, BODY_ZONE_CHEST, 4, null)
	TEST_ASSERT(masochist.next_paincrave <= world.time, "A masochist should not sate twice inside the cooldown")
	TEST_ASSERT(!sadist.sated, "A sadist should not sate twice inside the cooldown")
	TEST_ASSERT_EQUAL(masochist.next_mark_sate, masochist_until, "A refused sate should not push the cooldown out")

	masochist.next_mark_sate = world.time - 1
	body.take_impact_mark(striker, BODY_ZONE_L_LEG, 4, null)
	TEST_ASSERT(masochist.next_paincrave > world.time, "Once the cooldown is over a mark should sate again")

/// Examining marks sates on its own cooldown: the wearer as a masochist, a watcher as a sadist.
/datum/unit_test/impact_mark_examine_sates_vices/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	var/mob/living/carbon/human/watcher = allocate(/mob/living/carbon/human/species/human/northern)
	body.add_quirk(/datum/quirk/negative/addiction/masochist)
	watcher.add_quirk(/datum/quirk/negative/addiction/sadist)
	var/datum/quirk/negative/addiction/masochist/masochist = body.get_quirk(/datum/quirk/negative/addiction/masochist)
	var/datum/quirk/negative/addiction/sadist = watcher.get_quirk(/datum/quirk/negative/addiction/sadist)
	TEST_ASSERT_NOTNULL(masochist, "Test setup: the marked body needs the masochist vice")
	TEST_ASSERT_NOTNULL(sadist, "Test setup: the watcher needs the sadist vice")
	body.add_impact_mark(SPOT_BUTT, IMPACT_MARK_RED, FALSE)
	var/list/pronouns = list(THEIR = body.p_their(), THEYVE = "[body.p_they(TRUE)] [body.p_have()]")

	masochist.next_paincrave = world.time - 1
	TEST_ASSERT_NOTNULL(body.get_impact_mark_line(body, pronouns), "Test setup: the mark should be described")
	TEST_ASSERT(masochist.next_paincrave > world.time, "Seeing their own marks should sate a masochist")
	TEST_ASSERT_EQUAL(masochist.next_mark_examine_sate - world.time, IMPACT_MARK_EXAMINE_SATE_COOLDOWN, "The examine cooldown should be armed")
	masochist.next_paincrave = world.time - 1
	body.get_impact_mark_line(body, pronouns)
	TEST_ASSERT(masochist.next_paincrave <= world.time, "A masochist should not sate twice inside the examine cooldown")

	sadist.sated = FALSE
	TEST_ASSERT_NOTNULL(body.get_impact_mark_line(watcher, pronouns), "Test setup: the watcher should see the mark")
	TEST_ASSERT(sadist.sated, "Seeing marks on someone else should sate a sadist")
	sadist.sated = FALSE
	body.get_impact_mark_line(watcher, pronouns)
	TEST_ASSERT(!sadist.sated, "A sadist should not sate twice inside the examine cooldown")

/// Every zone marks its spot, the chest from behind marks the back, unknown zones mark nothing.
/datum/unit_test/impact_mark_zone_table/Run()
	var/list/expected = list(
		BODY_ZONE_CHEST = SPOT_CHEST,
		BODY_ZONE_PRECISE_STOMACH = SPOT_BELLY,
		BODY_ZONE_PRECISE_GROIN = SPOT_BUTT,
		BODY_ZONE_L_ARM = SPOT_L_ARM,
		BODY_ZONE_R_ARM = SPOT_R_ARM,
		BODY_ZONE_PRECISE_L_HAND = SPOT_L_HAND,
		BODY_ZONE_PRECISE_R_HAND = SPOT_R_HAND,
		BODY_ZONE_L_LEG = SPOT_L_THIGH,
		BODY_ZONE_R_LEG = SPOT_R_THIGH,
		BODY_ZONE_PRECISE_L_FOOT = SPOT_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT = SPOT_R_FOOT,
		BODY_ZONE_HEAD = SPOT_CHEEK,
		BODY_ZONE_PRECISE_SKULL = SPOT_FOREHEAD,
		BODY_ZONE_PRECISE_R_EYE = SPOT_FOREHEAD,
		BODY_ZONE_PRECISE_L_EYE = SPOT_FOREHEAD,
		BODY_ZONE_PRECISE_NOSE = SPOT_NOSE,
		BODY_ZONE_PRECISE_MOUTH = SPOT_LIPS,
		BODY_ZONE_PRECISE_EARS = SPOT_EAR,
		BODY_ZONE_PRECISE_NECK = SPOT_NECK,
	)
	for(var/zone in expected)
		TEST_ASSERT_EQUAL(get_impact_mark_spot(zone), expected[zone], "A strike to [zone] should mark [expected[zone]]")
	TEST_ASSERT_EQUAL(get_impact_mark_spot(BODY_ZONE_CHEST, TRUE), SPOT_BACK, "A chest strike from behind should mark the back")
	TEST_ASSERT_EQUAL(get_impact_mark_spot(BODY_ZONE_PRECISE_GROIN, TRUE), SPOT_BUTT, "A groin strike from behind should still mark the butt")
	for(var/zone in list(BODY_ZONE_TAUR, "not a zone", null))
		TEST_ASSERT_NULL(get_impact_mark_spot(zone), "A strike to [zone || "null"] should mark nothing")

	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	var/mob/living/carbon/human/striker = allocate(/mob/living/carbon/human/species/human/northern)
	var/obj/item/weapon/whip/whip = allocate(/obj/item/weapon/whip)
	for(var/zone in list(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK))
		TEST_ASSERT(body.take_impact_mark(striker, zone, SEX_FORCE_EXTREME, whip) > IMPACT_MARK_NONE, "A whip strike to [zone] should leave a mark")
		TEST_ASSERT_NOTNULL(LAZYACCESS(body.impact_marks, expected[zone]), "A whip strike to [zone] should be recorded on [expected[zone]]")
	TEST_ASSERT_EQUAL(body.take_impact_mark(striker, "not a zone", SEX_FORCE_UNRELENTING, whip), IMPACT_MARK_NONE, "A strike to an unknown zone should leave no mark")
	TEST_ASSERT_EQUAL(length(body.impact_marks), 5, "A strike to an unknown zone should record nothing")

/// A strike from the three tiles behind the body marks the back; from the front it marks the chest.
/datum/unit_test/impact_mark_back_from_behind/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human/species/human/northern)
	var/mob/living/carbon/human/striker = allocate(/mob/living/carbon/human/species/human/northern)
	var/obj/item/weapon/whip/whip = allocate(/obj/item/weapon/whip)
	TEST_ASSERT(!is_struck_from_behind(body, striker), "A striker on the same tile is not behind")
	striker.forceMove(get_step(body, NORTH))
	body.setDir(SOUTH)
	TEST_ASSERT(is_struck_from_behind(body, striker), "A striker north of a body facing south is behind it")
	body.take_impact_mark(striker, BODY_ZONE_CHEST, SEX_FORCE_EXTREME, whip)
	TEST_ASSERT_NOTNULL(LAZYACCESS(body.impact_marks, SPOT_BACK), "A chest strike from behind should mark the back")
	TEST_ASSERT_NULL(LAZYACCESS(body.impact_marks, SPOT_CHEST), "A chest strike from behind should not mark the chest")
	var/list/pronouns = list(THEIR = body.p_their(), THEYVE = "[body.p_they(TRUE)] [body.p_have()]")
	var/line = body.get_impact_mark_line(body, pronouns)
	TEST_ASSERT_NOTNULL(line, "A bare back mark should add an examine line")
	TEST_ASSERT(findtext(line, "back"), "The examine line should name the back: [line]")

	body.setDir(NORTH)
	TEST_ASSERT(!is_struck_from_behind(body, striker), "A striker the body faces is not behind it")
	body.take_impact_mark(striker, BODY_ZONE_CHEST, SEX_FORCE_EXTREME, whip)
	TEST_ASSERT_NOTNULL(LAZYACCESS(body.impact_marks, SPOT_CHEST), "A chest strike from the front should mark the chest")

/// A spank uses a held impact tool, from either hand, and never an ordinary item.
/datum/unit_test/impact_mark_spank_uses_held_tool/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/species/human/northern)
	var/mob/living/carbon/human/bare_body = allocate(/mob/living/carbon/human/species/human/northern)
	var/mob/living/carbon/human/tool_body = allocate(/mob/living/carbon/human/species/human/northern)
	var/datum/sex_action/spanking/spank = allocate(/datum/sex_action/spanking)
	spank.force = SEX_FORCE_HIGH

	TEST_ASSERT(is_impact_tool(allocate(/obj/item/weapon/whip)), "A whip is an impact tool")
	TEST_ASSERT(is_impact_tool(allocate(/obj/item/weapon/whip/cane)), "A cane is an impact tool")
	TEST_ASSERT(is_impact_tool(allocate(/obj/item/storage/belt/leather)), "A belt is an impact tool")
	for(var/toy_type in subtypesof(/obj/item/impact_toy))
		TEST_ASSERT(is_impact_tool(allocate(toy_type)), "[toy_type] is an impact tool")

	TEST_ASSERT_NULL(spank.get_spank_tool(user, bare_body), "Empty hands spank bare")
	var/obj/item/weapon/knife/hunting/knife = allocate(/obj/item/weapon/knife/hunting)
	TEST_ASSERT(!is_impact_tool(knife), "A knife is no impact tool")
	TEST_ASSERT(user.put_in_active_hand(knife), "Test setup: the knife should be held")
	TEST_ASSERT_NULL(spank.get_spank_tool(user, bare_body), "A held knife should not count as a spanking tool")
	spank.on_perform(user, bare_body)
	var/list/bare_mark = LAZYACCESS(bare_body.impact_marks, SPOT_BUTT)
	TEST_ASSERT_NOTNULL(bare_mark, "A rough bare spank should mark the butt")
	TEST_ASSERT(!bare_mark[IMPACT_MARK_BY_TOOL], "A spank with a knife in hand is a bare-hand mark")

	var/obj/item/impact_toy/riding_crop/crop = allocate(/obj/item/impact_toy/riding_crop)
	TEST_ASSERT(user.put_in_inactive_hand(crop), "Test setup: the crop should be held")
	TEST_ASSERT_EQUAL(spank.find_spank_hand(user), user.get_inactive_precise_hand(), "The hand holding the crop should spank")
	TEST_ASSERT_EQUAL(spank.get_spank_tool(user, tool_body), crop, "The held crop should be the spanking tool")
	spank.on_perform(user, tool_body)
	var/list/tool_mark = LAZYACCESS(tool_body.impact_marks, SPOT_BUTT)
	TEST_ASSERT_NOTNULL(tool_mark, "A spank with the crop should mark the butt")
	TEST_ASSERT(tool_mark[IMPACT_MARK_BY_TOOL], "A spank with the crop should read as a tool mark")
	TEST_ASSERT(tool_mark[IMPACT_MARK_LEVEL] > bare_mark[IMPACT_MARK_LEVEL], "A spank with the crop should mark harder than a bare spank")

#undef SPOT_BUTT
#undef SPOT_CHEST
#undef SPOT_L_THIGH
#undef SPOT_BACK
#undef SPOT_BELLY
#undef SPOT_L_ARM
#undef SPOT_R_ARM
#undef SPOT_L_HAND
#undef SPOT_R_HAND
#undef SPOT_R_THIGH
#undef SPOT_L_FOOT
#undef SPOT_R_FOOT
#undef SPOT_CHEEK
#undef SPOT_FOREHEAD
#undef SPOT_NOSE
#undef SPOT_LIPS
#undef SPOT_EAR
#undef SPOT_NECK
