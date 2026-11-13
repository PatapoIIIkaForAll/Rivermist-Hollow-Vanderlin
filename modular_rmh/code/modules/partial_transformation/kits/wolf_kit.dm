// The moonkissed form - the shallow mooncurse carried by lesser werewolves.
// Wolf ears, a wagging tail, a touch of lupine vigor. Nothing like the full beast.

/obj/item/organ/ears/anthro/moonkissed
	name = "wolfish ears"
	desc = "Soft, alert wolf ears. The moon left its mark here."
	accessory_type = /datum/sprite_accessory/ears/wolf

/obj/item/organ/tail/anthro/moonkissed
	name = "wolfish tail"
	desc = "A bushy wolf tail that betrays its owner's every mood."
	accessory_type = /datum/sprite_accessory/tail/wolf

/datum/partial_transformation_kit/wolf
	id = "moonkissed"
	form_name = "moonkissed form"
	organ_swaps = list(
		ORGAN_SLOT_EARS = /obj/item/organ/ears/anthro/moonkissed,
		ORGAN_SLOT_TAIL = /obj/item/organ/tail/anthro/moonkissed,
		ORGAN_SLOT_PENIS = /obj/item/organ/genitals/penis/knotted,
	)
	swap_only_if_present = list(ORGAN_SLOT_PENIS)
	shift_stats = list(
		STAT_STRENGTH = 1,
		STAT_ENDURANCE = 1,
		STAT_SPEED = 2,
		STAT_PERCEPTION = 2,
	)
	shift_traits = list(TRAIT_KEENEARS)
	shift_spells = list(/datum/action/cooldown/spell/undirected/howl)
	blocking_traits = list(
		TRAIT_WEREWOLF_TRANSFORMATION_SUPPRESSED = "Silver bindings keep the moon's kiss buried beneath my skin.",
		TRAIT_SILVER_BLESSED = "A holy blessing keeps the moon's kiss at bay.",
	)
	shift_sound = 'sound/vo/mobs/wwolf/wolftalk1.ogg'
	unshift_sound = 'sound/vo/mobs/wwolf/wolftalk2.ogg'
	shift_message = "The moon's kiss surges through me - fur, fang and tail awaken!"
	unshift_message = "I smooth my hackles; the moon's kiss recedes beneath my skin."
	examine_line = span_warning("SUBJECTPRONOUN is touched by the moon - wolfish ears perked atop the head, and a swaying tail behind.")

/datum/partial_transformation_kit/wolf/can_swap_slot(slot, obj/item/organ/original, mob/living/carbon/human/target)
	if(slot == ORGAN_SLOT_PENIS)
		// Only a plain penis takes the knot - exotic shapes are left alone.
		var/obj/item/organ/genitals/penis/original_penis = original
		return istype(original_penis) && original_penis.penis_type == PENIS_TYPE_PLAIN
	return TRUE

/datum/partial_transformation_kit/wolf/prepare_replacement(obj/item/organ/replacement, obj/item/organ/original, mob/living/carbon/human/target)
	if(istype(replacement, /obj/item/organ/genitals/penis) && istype(original, /obj/item/organ/genitals/penis))
		var/obj/item/organ/genitals/penis/new_penis = replacement
		var/obj/item/organ/genitals/penis/old_penis = original
		new_penis.organ_size = old_penis.organ_size
		new_penis.length_cm = old_penis.length_cm

/datum/action/cooldown/spell/undirected/partial_transformation/moonkissed
	name = "Embrace the Moon's Kiss"
	desc = "Let the shallow mooncurse surface: wolfish ears, tail and vigor. Cast again to suppress it."
	kit_type = /datum/partial_transformation_kit/wolf
	sound = null
