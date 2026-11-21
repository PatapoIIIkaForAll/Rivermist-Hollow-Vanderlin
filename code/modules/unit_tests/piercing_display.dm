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
		for(var/size in 5 to 8)
			for(var/gait in list("", "run_", "jiggle_"))
				var/gait_state = "[accessory.anim_shape]-[size]_[gait]front"
				TEST_ASSERT(gait_state in anim_states, "[accessory_type] lacks animated state [gait_state]")
			var/shot_prefix = "pair_[size]_"
			for(var/breast_state in breast_states)
				if(copytext(breast_state, 1, length(shot_prefix) + 1) != shot_prefix || !findtext(breast_state, "_front_ADJ"))
					continue
				var/shot = copytext(breast_state, length(shot_prefix) + 1, findtext(breast_state, "_front_ADJ"))
				if(!shot || shot == "run" || shot == "jiggle")
					continue
				var/shot_state = "[accessory.anim_shape]-[size]_[shot]_front"
				TEST_ASSERT(shot_state in anim_states, "[accessory_type] lacks one-shot [shot_state]")

/// The piercing moves with the breasts on a short body and on a human body.
/datum/unit_test/piercing_display_offset_follows_breasts/Run()
	var/datum/sprite_accessory/piercing/piercing = SPRITE_ACCESSORY(/datum/sprite_accessory/piercing/rings)
	var/datum/sprite_accessory/genitals/breasts/pair/pair = SPRITE_ACCESSORY(/datum/sprite_accessory/genitals/breasts/pair)
	for(var/species_type in list(/datum/species/dwarf/mountain, /datum/species/human/northern))
		var/mob/living/carbon/human/body = make_pierced_body(species_type, BREAST_SIZE_NORMAL)
		TEST_ASSERT_NOTNULL(body, "Test setup: [species_type] needs breasts")
		var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
		var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
		var/mutable_appearance/piercing_look = mutable_appearance()
		var/mutable_appearance/breast_look = mutable_appearance()
		piercing.adjust_appearance_list(list(piercing_look), null, chest, body)
		pair.adjust_appearance_list(list(breast_look), breasts, chest, body)
		TEST_ASSERT_EQUAL(piercing_look.pixel_x, breast_look.pixel_x, "[species_type]: the piercing should share the breasts' x offset")
		TEST_ASSERT_EQUAL(piercing_look.pixel_y, breast_look.pixel_y, "[species_type]: the piercing should share the breasts' y offset")
		if(species_type == /datum/species/dwarf/mountain)
			TEST_ASSERT(breast_look.pixel_y < 0, "Test setup: dwarf breasts should sit lower than the human frame")

/// A plain shirt hides the piercing; breasts shown above clothes bring it out above them.
/datum/unit_test/piercing_display_follows_breast_visibility/Run()
	var/datum/sprite_accessory/piercing/piercing = SPRITE_ACCESSORY(/datum/sprite_accessory/piercing/beads)
	var/mob/living/carbon/human/body = make_pierced_body(/datum/species/human/northern, BREAST_SIZE_NORMAL)
	TEST_ASSERT_NOTNULL(body, "Test setup: the body needs breasts")
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = body.getorganslot(ORGAN_SLOT_BREASTS)
	var/obj/item/bodypart/chest = body.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(piercing.is_visible(null, chest, body), "A bare chest should show the piercing")
	var/obj/item/clothing/shirt/tribalrag/rag = allocate(/obj/item/clothing/shirt/tribalrag)
	body.equip_to_slot_or_del(rag, ITEM_SLOT_SHIRT)
	TEST_ASSERT_EQUAL(body.wear_shirt, rag, "Test setup: the rag should be worn")
	TEST_ASSERT(!piercing.is_visible(null, chest, body), "A plain shirt should hide the piercing")
	breasts.visible_through_clothes = DRAW_ABOVE
	TEST_ASSERT(piercing.is_visible(null, chest, body), "Breasts shown above clothes should show the piercing")
	TEST_ASSERT(piercing.draw_above_clothes, "The piercing should draw above the clothes with the breasts")
	breasts.visible_through_clothes = FALSE
	TEST_ASSERT(!piercing.is_visible(null, chest, body), "Covering the breasts again should hide the piercing")
	TEST_ASSERT(!piercing.draw_above_clothes, "A hidden piercing should not keep the above-clothes layer")

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
