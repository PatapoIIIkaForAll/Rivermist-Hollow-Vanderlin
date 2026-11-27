/// Washing should clean every unobscured equipped item, not just the original clothing slots.
/datum/unit_test/washing_cleans_all_unobscured_worn_items/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/pants = allocate(/obj/item/clothing)
	var/obj/item/clothing/cloak = allocate(/obj/item/clothing)
	var/obj/item/clothing/back_item = allocate(/obj/item/clothing)
	var/obj/item/clothing/ring = allocate(/obj/item/clothing)
	var/obj/item/clothing/wrists = allocate(/obj/item/clothing)
	var/obj/item/clothing/armor = allocate(/obj/item/clothing)

	body.wear_pants = pants
	body.cloak = cloak
	body.backr = back_item
	body.wear_ring = ring
	body.wear_wrists = wrists
	body.wear_armor = armor

	var/list/worn_items = list(pants, cloak, back_item, ring, wrists, armor)
	for(var/obj/item/worn_item as anything in worn_items)
		worn_item.add_atom_colour("#FF0000", WASHABLE_COLOUR_PRIORITY)

	body.wash(CLEAN_WASH)

	for(var/obj/item/worn_item as anything in worn_items)
		TEST_ASSERT_NULL(worn_item.atom_colours[WASHABLE_COLOUR_PRIORITY], "[worn_item] should be cleaned")

	armor.flags_inv |= HIDEJUMPSUIT
	pants.add_atom_colour("#FF0000", WASHABLE_COLOUR_PRIORITY)
	body.wash(CLEAN_WASH)
	TEST_ASSERT(pants.atom_colours[WASHABLE_COLOUR_PRIORITY], "Clothing hidden by armor should not be washed")
