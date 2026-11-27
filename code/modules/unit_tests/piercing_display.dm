/// Female human of a species with breasts of the given shape and size; null when setup fails.
/datum/unit_test/proc/make_pierced_body(species_type, breast_size, breast_accessory = /datum/sprite_accessory/genitals/breasts/pair)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	body.set_species(species_type)
	body.gender = FEMALE
	body.give_genitals()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts)
		return null
	breasts.organ_size = breast_size
	breasts.accessory_type = breast_accessory
	return body

/// Each gait and one-shot state the jewellery child plays over pair sizes 5-8 exists, one per breasts state.
/datum/unit_test/proc/check_jewelry_anim_states(label, shape, list/anim_states, list/breast_states)
	for(var/size in 5 to 8)
		for(var/gait in list("", "run_", "jiggle_"))
			var/gait_state = "[shape]-[size]_[gait]front"
			TEST_ASSERT(gait_state in anim_states, "[label] lacks animated state [gait_state]")
		var/shot_prefix = "pair_[size]_"
		for(var/breast_state in breast_states)
			if(copytext(breast_state, 1, length(shot_prefix) + 1) != shot_prefix || !findtext(breast_state, "_front_ADJ"))
				continue
			var/shot = copytext(breast_state, length(shot_prefix) + 1, findtext(breast_state, "_front_ADJ"))
			if(!shot || shot == "run" || shot == "jiggle")
				continue
			var/shot_state = "[shape]-[size]_[shot]_front"
			TEST_ASSERT(shot_state in anim_states, "[label] lacks one-shot [shot_state]")

/// Every piercing state the body overlay and the animated child ask for exists in its sheet.
/datum/unit_test/piercing_display_states_exist/Run()
	var/anim_icon = 'modular_rmh/icons/mob/sprite_accessory/piercings/piercings_anim.dmi'
	var/breast_icon = 'modular_rmh/icons/mob/sprite_accessory/genitals/breasts_anim.dmi'
	var/list/anim_states = icon_states(anim_icon)
	var/list/breast_states = icon_states(breast_icon)
	var/mob/living/carbon/human/body = make_pierced_body(/datum/species/human/northern, 0)
	TEST_ASSERT_NOTNULL(body, "Test setup: the body needs breasts")
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	for(var/accessory_type in subtypesof(/datum/sprite_accessory/piercing))
		var/datum/sprite_accessory/piercing/accessory = SPRITE_ACCESSORY(accessory_type)
		TEST_ASSERT_NOTNULL(accessory, "[accessory_type] has no accessory singleton")
		var/list/sheet_states = icon_states(accessory.icon)
		for(var/breast_accessory in list(/datum/sprite_accessory/genitals/breasts/pair, /datum/sprite_accessory/genitals/breasts/quad))
			breasts.accessory_type = breast_accessory
			for(var/size in 0 to 8)
				breasts.organ_size = size
				var/state = accessory.get_icon_state(null, null, body)
				TEST_ASSERT(state in sheet_states, "[accessory_type] asks for missing state [state] at [breast_accessory] size [size]")
		check_jewelry_anim_states("[accessory_type]", accessory.anim_shape, anim_states, breast_states)

/// The piercing and the clamps move with the breasts on a short body and on a human body.
/datum/unit_test/piercing_display_offset_follows_breasts/Run()
	var/datum/sprite_accessory/genitals/breasts/pair/pair = SPRITE_ACCESSORY(/datum/sprite_accessory/genitals/breasts/pair)
	for(var/species_type in list(/datum/species/dwarf/mountain, /datum/species/human/northern))
		var/mob/living/carbon/human/body = make_pierced_body(species_type, BREAST_SIZE_NORMAL)
		TEST_ASSERT_NOTNULL(body, "Test setup: [species_type] needs breasts")
		var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
		var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
		var/mutable_appearance/breast_look = mutable_appearance()
		pair.adjust_appearance_list(list(breast_look), breasts, chest, body)
		if(species_type == /datum/species/dwarf/mountain)
			TEST_ASSERT(breast_look.pixel_y < 0, "Test setup: dwarf breasts should sit lower than the human frame")
		for(var/accessory_type in list(/datum/sprite_accessory/piercing/rings, /datum/sprite_accessory/nipple_clamps))
			var/datum/sprite_accessory/jewelry = SPRITE_ACCESSORY(accessory_type)
			var/mutable_appearance/jewelry_look = mutable_appearance()
			jewelry.adjust_appearance_list(list(jewelry_look), null, chest, body)
			TEST_ASSERT_EQUAL(jewelry_look.pixel_x, breast_look.pixel_x, "[species_type]: [accessory_type] should share the breasts' x offset")
			TEST_ASSERT_EQUAL(jewelry_look.pixel_y, breast_look.pixel_y, "[species_type]: [accessory_type] should share the breasts' y offset")

/// A plain shirt hides the piercing and the clamps; breasts shown above clothes bring them out above the breasts.
/datum/unit_test/piercing_display_follows_breast_visibility/Run()
	var/mob/living/carbon/human/body = make_pierced_body(/datum/species/human/northern, BREAST_SIZE_NORMAL)
	TEST_ASSERT_NOTNULL(body, "Test setup: the body needs breasts")
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
	var/datum/sprite_accessory/genitals/breasts/pair = SPRITE_ACCESSORY(breasts.accessory_type)
	var/list/jewelry_types = list(/datum/sprite_accessory/piercing/beads, /datum/sprite_accessory/nipple_clamps)
	for(var/accessory_type in jewelry_types)
		var/datum/sprite_accessory/jewelry = SPRITE_ACCESSORY(accessory_type)
		TEST_ASSERT(jewelry.is_visible(null, chest, body), "A bare chest should show [accessory_type]")
	var/obj/item/clothing/shirt/tribalrag/rag = allocate(/obj/item/clothing/shirt/tribalrag)
	body.equip_to_slot_or_del(rag, ITEM_SLOT_SHIRT)
	TEST_ASSERT_EQUAL(body.wear_shirt, rag, "Test setup: the rag should be worn")
	TEST_ASSERT(!pair.is_visible(breasts, chest, body), "Test setup: a plain shirt should hide the breasts")
	for(var/accessory_type in jewelry_types)
		var/datum/sprite_accessory/jewelry = SPRITE_ACCESSORY(accessory_type)
		TEST_ASSERT(!jewelry.is_visible(null, chest, body), "A plain shirt should hide [accessory_type]")
	breasts.visible_through_clothes = DRAW_ABOVE
	for(var/accessory_type in jewelry_types)
		var/datum/sprite_accessory/jewelry = SPRITE_ACCESSORY(accessory_type)
		TEST_ASSERT(jewelry.is_visible(null, chest, body), "Breasts shown above clothes should show [accessory_type]")
		TEST_ASSERT(jewelry.draw_above_clothes, "[accessory_type] should draw above the clothes with the breasts")
		TEST_ASSERT(jewelry.draw_above_clothes_layer > pair.draw_above_clothes_layer, "[accessory_type] should draw over the breasts above clothes")
	breasts.visible_through_clothes = FALSE
	for(var/accessory_type in jewelry_types)
		var/datum/sprite_accessory/jewelry = SPRITE_ACCESSORY(accessory_type)
		TEST_ASSERT(!jewelry.is_visible(null, chest, body), "Covering the breasts again should hide [accessory_type]")
		TEST_ASSERT(!jewelry.draw_above_clothes, "Hidden [accessory_type] should not keep the above-clothes layer")
	var/datum/sprite_accessory/piercing = SPRITE_ACCESSORY(/datum/sprite_accessory/piercing/beads)
	var/datum/sprite_accessory/clamps = SPRITE_ACCESSORY(/datum/sprite_accessory/nipple_clamps)
	TEST_ASSERT(clamps.draw_above_clothes_layer > piercing.draw_above_clothes_layer, "Above clothes the clamps should draw over the piercing")

/// Animated pair breasts carry a piercing child that plays the breasts' gait and one-shots.
/datum/unit_test/piercing_display_animated_child/Run()
	var/mob/living/carbon/human/body = make_pierced_body(/datum/species/human/northern, 6)
	TEST_ASSERT_NOTNULL(body, "Test setup: the body needs breasts")
	var/datum/bodypart_feature/piercing/feature = new
	feature.set_accessory_type(/datum/sprite_accessory/piercing/rings/gold, null, body)
	var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(chest.add_bodypart_feature(feature), "Test setup: the piercing should go on the chest")
	TEST_ASSERT_EQUAL(body.get_worn_piercing_accessory(), SPRITE_ACCESSORY(/datum/sprite_accessory/piercing/rings/gold), "The worn piercing should be found on the chest")
	var/datum/component/breast_animation/animation = body.LoadComponent(/datum/component/breast_animation)
	animation.refresh()
	TEST_ASSERT_NOTNULL(animation.visual, "Size 6 pair breasts should get the animated child")
	TEST_ASSERT_NOTNULL(animation.piercing_visual, "The piercing should get a child over the animated breasts")
	TEST_ASSERT_EQUAL(animation.piercing_visual.icon_state, "rings-6_front", "The piercing child should rest on the walk state")
	TEST_ASSERT(!(animation.piercing_visual.vis_flags & VIS_HIDE), "The piercing child should show over bare breasts")
	TEST_ASSERT(animation.piercing_visual in body.vis_contents, "The piercing child should be drawn with the body")
	var/datum/sprite_accessory/piercing/gold = SPRITE_ACCESSORY(/datum/sprite_accessory/piercing/rings/gold)
	TEST_ASSERT(!gold.is_visible(null, chest, body), "The body overlay should leave the piercing to the child")
	animation.set_jiggling(TRUE)
	TEST_ASSERT_EQUAL(animation.piercing_visual.icon_state, "rings-6_jiggle_front", "The piercing child should jiggle with the breasts")
	animation.set_jiggling(FALSE)
	chest.remove_bodypart_feature(feature)
	animation.refresh()
	TEST_ASSERT_NULL(animation.piercing_visual, "Removing the piercing should remove its child")

/// Each coloured piercing in character setup spawns its own coloured item.
/datum/unit_test/piercing_display_items_match_accessories/Run()
	for(var/accessory_type in subtypesof(/datum/sprite_accessory/piercing))
		var/datum/sprite_accessory/piercing/accessory = SPRITE_ACCESSORY(accessory_type)
		TEST_ASSERT(ispath(accessory.piercing_type, /obj/item/piercings), "[accessory_type] has no piercing item")
		var/obj/item/piercings/item_type = accessory.piercing_type
		TEST_ASSERT_EQUAL(initial(item_type.sprite_acc), accessory_type, "[accessory_type] spawns [item_type], which wears another look")

/// Every clamp state the body overlay and the animated child ask for exists in the clamps sheet.
/datum/unit_test/piercing_display_clamp_states_exist/Run()
	var/datum/sprite_accessory/nipple_clamps/clamps = SPRITE_ACCESSORY(/datum/sprite_accessory/nipple_clamps)
	TEST_ASSERT_NOTNULL(clamps, "The clamps have no accessory singleton")
	var/list/sheet_states = icon_states(clamps.icon)
	var/list/breast_states = icon_states('modular_rmh/icons/mob/sprite_accessory/genitals/breasts_anim.dmi')
	var/mob/living/carbon/human/body = make_pierced_body(/datum/species/human/northern, 0)
	TEST_ASSERT_NOTNULL(body, "Test setup: the body needs breasts")
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	for(var/breast_accessory in list(/datum/sprite_accessory/genitals/breasts/pair, /datum/sprite_accessory/genitals/breasts/quad))
		breasts.accessory_type = breast_accessory
		for(var/size in 0 to 8)
			breasts.organ_size = size
			TEST_ASSERT_EQUAL(breasts.get_visible_size(), size, "Test setup: the visible size should be [size]")
			var/state = clamps.get_icon_state(null, null, body)
			TEST_ASSERT(state in sheet_states, "The clamps ask for missing state [state] at [breast_accessory] size [size]")
			if(breast_accessory == /datum/sprite_accessory/genitals/breasts/pair && size >= 1)
				TEST_ASSERT_EQUAL(state, "clamps-[size]", "Pair breasts of visible size [size] should get their own clamp art")
	check_jewelry_anim_states("[clamps.type]", clamps.anim_shape, sheet_states, breast_states)

/// A piercing and clamps worn together both draw, the clamps over the ring; taking the clamps off keeps the ring.
/datum/unit_test/piercing_display_clamps_with_piercing/Run()
	var/mob/living/carbon/human/body = make_pierced_body(/datum/species/human/northern, BREAST_SIZE_NORMAL)
	TEST_ASSERT_NOTNULL(body, "Test setup: the body needs breasts")
	var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
	var/datum/bodypart_feature/piercing/ring_feature = new
	ring_feature.set_accessory_type(/datum/sprite_accessory/piercing/rings, null, body)
	TEST_ASSERT(chest.add_bodypart_feature(ring_feature), "Test setup: the piercing should go on the chest")
	var/obj/item/nipple_clamps/clamps_item = allocate(/obj/item/nipple_clamps)
	TEST_ASSERT(clamps_item.clamp_onto(body), "The clamps should fit over a pierced chest")
	TEST_ASSERT(ring_feature in chest.bodypart_features, "Clamping should keep the piercing")
	TEST_ASSERT_NOTNULL(clamps_item.clamps_feature, "The clamps should add their chest feature")
	var/list/ring_looks = ring_feature.get_bodypart_overlay(chest)
	var/list/clamp_looks = clamps_item.clamps_feature.get_bodypart_overlay(chest)
	TEST_ASSERT(length(ring_looks), "The piercing should draw with clamps on")
	TEST_ASSERT(length(clamp_looks), "The clamps should draw with a piercing on")
	var/mutable_appearance/ring_look = ring_looks[1]
	var/mutable_appearance/clamp_look = clamp_looks[1]
	TEST_ASSERT_EQUAL(clamp_look.icon_state, "clamps-[BREAST_SIZE_NORMAL]", "The clamps should draw the breasts' size")
	TEST_ASSERT(clamp_look.layer > ring_look.layer, "The clamps should draw over the ring")
	clamps_item.unclamp(body, null)
	TEST_ASSERT_NULL(body.nipple_clamps, "Unclamping should clear the worn clamps")
	TEST_ASSERT(ring_feature in chest.bodypart_features, "Unclamping should leave the piercing")
	TEST_ASSERT_NULL(body.get_worn_nipple_clamps_accessory(), "Unclamping should remove the clamps feature")

/// Animated pair breasts carry a clamps child over the piercing child; unclamping removes it and keeps the ring.
/datum/unit_test/piercing_display_clamps_animated_child/Run()
	var/mob/living/carbon/human/body = make_pierced_body(/datum/species/human/northern, 6)
	TEST_ASSERT_NOTNULL(body, "Test setup: the body needs breasts")
	var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
	var/datum/bodypart_feature/piercing/ring_feature = new
	ring_feature.set_accessory_type(/datum/sprite_accessory/piercing/rings, null, body)
	TEST_ASSERT(chest.add_bodypart_feature(ring_feature), "Test setup: the piercing should go on the chest")
	var/obj/item/nipple_clamps/clamps_item = allocate(/obj/item/nipple_clamps)
	TEST_ASSERT(clamps_item.clamp_onto(body), "Test setup: the clamps should fit")
	var/datum/component/breast_animation/animation = body.LoadComponent(/datum/component/breast_animation)
	animation.refresh()
	TEST_ASSERT_NOTNULL(animation.visual, "Size 6 pair breasts should get the animated child")
	TEST_ASSERT_NOTNULL(animation.piercing_visual, "The piercing should keep its child with clamps on")
	TEST_ASSERT_NOTNULL(animation.clamps_visual, "The clamps should get a child over the animated breasts")
	TEST_ASSERT_EQUAL(animation.clamps_visual.icon_state, "clamps-6_front", "The clamps child should rest on the walk state")
	TEST_ASSERT(icon_exists(animation.clamps_visual.icon, animation.clamps_visual.icon_state), "The clamps child state should exist in its sheet")
	TEST_ASSERT(animation.clamps_visual.layer > animation.piercing_visual.layer, "The clamps child should draw over the piercing child")
	TEST_ASSERT(animation.clamps_visual in body.vis_contents, "The clamps child should be drawn with the body")
	TEST_ASSERT(!(animation.clamps_visual.vis_flags & VIS_HIDE), "The clamps child should show over bare breasts")
	var/datum/sprite_accessory/nipple_clamps/clamps = SPRITE_ACCESSORY(/datum/sprite_accessory/nipple_clamps)
	TEST_ASSERT(!clamps.is_visible(null, chest, body), "The body overlay should leave the clamps to the child")
	animation.set_jiggling(TRUE)
	TEST_ASSERT_EQUAL(animation.clamps_visual.icon_state, "clamps-6_jiggle_front", "The clamps child should jiggle with the breasts")
	animation.set_jiggling(FALSE)
	var/atom/movable/clamps_child = animation.clamps_visual
	clamps_item.unclamp(body, null)
	animation.refresh()
	TEST_ASSERT_NULL(animation.clamps_visual, "Unclamping should remove the clamps child")
	TEST_ASSERT(!(clamps_child in body.vis_contents), "The removed clamps child should leave the body")
	TEST_ASSERT_NOTNULL(animation.piercing_visual, "Unclamping should keep the piercing child")
