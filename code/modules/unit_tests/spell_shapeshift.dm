/**
 * Validates that all shapeshift type spells
 * have a valid possible_shapes setup.
 */
/datum/unit_test/shapeshift_spell_validity

/datum/unit_test/shapeshift_spell_validity/Run()

	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell/undirected/shapeshift)

	for(var/spell_type in types_to_test)
		var/datum/action/cooldown/spell/undirected/shapeshift/shift = new spell_type()
		if(!LAZYLEN(shift.possible_shapes))
			TEST_FAIL("Shapeshift spell: [shift] ([spell_type]) did not have any possible shapeshift options.")

		for(var/shift_type in shift.possible_shapes)
			if(!ispath(shift_type, /mob/living))
				TEST_FAIL("Shapeshift spell: [shift] had an invalid / non-living shift type ([shift_type]) in their possible shapes list.")

		qdel(shift)

/**
 * Tests that shapeshift spells transfer a player's mind into the temporary form
 * and return it to the original body when the form ends.
 */
/datum/unit_test/shapeshift_spell_transfers_mind

/datum/unit_test/shapeshift_spell_transfers_mind/Run()
	var/mob/living/carbon/human/caster = allocate(/mob/living/carbon/human)
	caster.mind_initialize()

	var/datum/action/cooldown/spell/undirected/shapeshift/rat/rat_form = new(caster.mind)
	rat_form.Grant(caster)
	rat_form.shapeshift_type = /mob/living/simple_animal/hostile/retaliate/bigrat

	var/datum/mind/caster_mind = caster.mind
	var/mob/living/shifted_form = rat_form.do_shapeshift(caster)
	TEST_ASSERT(istype(shifted_form, /mob/living/simple_animal/hostile/retaliate/bigrat), "Rat Form failed to create the rat body for the test.")
	TEST_ASSERT_EQUAL(caster_mind.current, shifted_form, "Shapeshift failed to transfer the caster's mind into the temporary form.")
	TEST_ASSERT_EQUAL(shifted_form.mind, caster_mind, "The shifted form did not receive the caster's mind.")
	TEST_ASSERT_EQUAL(rat_form.owner, shifted_form, "The shapeshift spell did not follow the caster into the temporary form.")

	var/mob/living/restored_body = rat_form.do_unshapeshift(shifted_form)
	TEST_ASSERT_EQUAL(restored_body, caster, "Shapeshift returned the wrong body when unshifting.")
	TEST_ASSERT_EQUAL(caster_mind.current, caster, "Unshapeshift failed to return the caster's mind to the original body.")
	TEST_ASSERT_EQUAL(caster.mind, caster_mind, "The original body did not regain the caster's mind after unshifting.")
	TEST_ASSERT_EQUAL(rat_form.owner, caster, "The shapeshift spell did not return to the original body after unshifting.")

	qdel(rat_form)

/// Crow Form converts damage: changing back keeps old wounds, adds the shape's damage and stops bleeding.
/datum/unit_test/shapeshift_spell_keeps_wounds

/datum/unit_test/shapeshift_spell_keeps_wounds/Run()
	var/mob/living/carbon/human/caster = allocate(/mob/living/carbon/human)
	caster.mind_initialize()
	var/obj/item/bodypart/chest = caster.get_bodypart(BODY_ZONE_CHEST)
	chest.create_injury(WOUND_SLASH, 40, wound_messages = FALSE)
	chest.update_damages()
	caster.updatehealth()
	var/brute_before = caster.getBruteLoss()
	TEST_ASSERT(brute_before > 0, "The test caster should start wounded")
	var/datum/injury/cut
	for(var/datum/injury/injury as anything in caster.all_injuries)
		if(injury.is_bleeding())
			cut = injury
	TEST_ASSERT_NOTNULL(cut, "The test cut should bleed before the shift")
	var/cut_damage = cut.damage

	var/datum/action/cooldown/spell/undirected/shapeshift/crow/crow_form = new(caster.mind)
	crow_form.Grant(caster)
	crow_form.shapeshift_type = crow_form.possible_shapes[1]
	TEST_ASSERT(crow_form.convert_damage, "Crow Form should convert damage for this test")

	var/mob/living/shifted_form = crow_form.do_shapeshift(caster)
	TEST_ASSERT_NOTNULL(shifted_form, "Crow Form failed to create the crow body")
	shifted_form.adjustBruteLoss(shifted_form.maxHealth * 0.25)
	TEST_ASSERT(shifted_form.stat != DEAD, "The crow must survive the test damage")

	TEST_ASSERT_EQUAL(crow_form.do_unshapeshift(shifted_form), caster, "Crow Form returned the wrong body")
	TEST_ASSERT(!QDELETED(cut) && (cut in caster.all_injuries), "Changing back must keep the old cut")
	TEST_ASSERT_EQUAL(cut.damage, cut_damage, "Changing back must not heal the old cut")
	TEST_ASSERT(caster.getBruteLoss() > brute_before, "The damage the crow took should carry back to the caster")
	for(var/datum/injury/injury as anything in caster.all_injuries)
		TEST_ASSERT(!injury.is_bleeding(), "Changing back should stop the caster's bleeding")

	qdel(crow_form)
