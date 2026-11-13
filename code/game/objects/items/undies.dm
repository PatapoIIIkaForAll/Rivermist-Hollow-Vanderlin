/obj/item/clothing/undies
	name = "briefs"
	desc = "An absolute necessity."
	icon = 'modular_rmh/icons/clothing/underwear/underwear.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/underwear/onmob/underwear.dmi'
	icon_state = "briefs"
	item_state = "briefs"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	break_sound = 'sound/foley/cloth_rip.ogg'
	blade_dulling = DULLING_CUT
	max_integrity = 200
	integrity_failure = 0.1
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	var/covers_breasts = FALSE
	/// FALSE lets a viewer behind the wearer see the genitals between the legs.
	var/covers_rear = TRUE
	var/mob_overlay_icon_base
	boob_sized = FALSE
	sewrepair = /datum/attribute/skill/misc/sewing/mending
	salvage_result = /obj/item/natural/cloth
	slot_flags = ITEM_SLOT_MOUTH | ITEM_SLOT_UNDER_BOTTOM
	muteinmouth = TRUE
	flags_inv = HIDECROTCH

/obj/item/clothing/undies/Initialize(mapload, ...)
	. = ..()
	mob_overlay_icon_base = mob_overlay_icon

/obj/item/clothing/undies/equipped(mob/living/carbon/user, slot)
	. = ..()
	if(user.mouth == src)
		flags_inv = null
		mob_overlay_icon = null
		user.update_body()
		user.update_inv_mouth()
	else
		flags_inv = HIDECROTCH
		mob_overlay_icon = mob_overlay_icon_base

/obj/item/clothing/undies/dropped(mob/user)
	. = ..()
	flags_inv = HIDECROTCH
	mob_overlay_icon = mob_overlay_icon_base

/// TRUE when this worn item hides the organ in [slot], even genitals set to show through clothes.
/obj/item/clothing/undies/proc/hides_organ_slot(slot)
	return FALSE

/// TRUE when a viewer behind the wearer sees past this garment; devices with a moving rear plate override it.
/obj/item/clothing/undies/proc/leaves_rear_bare()
	return !covers_rear

/obj/item/clothing/undies/bikini_bottom
	name = "bikini bottom"
	desc = "A perfect bathing garment."
	icon_state = "bikini_bottom"
	item_state = "bikini_bottom"
	gendered = TRUE

/obj/item/clothing/undies/panties
	name = "panties"
	icon_state = "panties"
	item_state = "panties"
	gendered = FALSE

/obj/item/clothing/undies/braies
	name = "braies"
	desc = "A pair of linen underpants; Faerun's most common." // RMH
	icon_state = "braies"
	item_state = "braies"
	flags_inv = HIDEBUTT|HIDECROTCH

/obj/item/clothing/undies/thong
	name = "thong"
	icon_state = "thong"
	item_state = "thong"
	gendered = TRUE
	covers_rear = FALSE

/obj/item/clothing/undies/loincloth
	name = "small loincloth"
	desc = "A tight loincloth adjusted to fit like underwear, for those who like a breeze."
	icon_state = "loincloth"
	item_state = "loincloth"
	gendered = TRUE
	covers_rear = FALSE

// Craft

/datum/repeatable_crafting_recipe/sewing/undies
	name = "briefs"
	output = /obj/item/clothing/undies
	requirements = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/undies/thong
	name = "thong"
	output = /obj/item/clothing/undies/thong
	requirements = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 2)

/datum/repeatable_crafting_recipe/sewing/undies/loincloth
	name = "small loincloth"
	output = /obj/item/clothing/undies/loincloth
	requirements = list(/obj/item/natural/cloth = 1)
	craftdiff = 0

/datum/repeatable_crafting_recipe/sewing/bikini_bottom
	name = "bikini bottom"
	output = /obj/item/clothing/undies/bikini_bottom
	requirements = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/panties
	name = "panties"
	output = /obj/item/clothing/undies/panties
	requirements = list(/obj/item/natural/cloth = 1)
	craftdiff = 2

/datum/repeatable_crafting_recipe/sewing/braies
	name = "braies"
	output = /obj/item/clothing/undies/braies
	requirements = list(/obj/item/natural/cloth = 1)
	craftdiff = 2
