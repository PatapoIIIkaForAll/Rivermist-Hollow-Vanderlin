/// Base sprint stamina cost per tile in /mob/living/carbon/Move().
#define BREAST_SPRINT_BASE_COST 2
/// Smallest visible size with the weight effects.
#define BREAST_WEIGHT_MIN_SIZE 6
/// Smallest visible size that strains a plain garment over the chest.
#define BREAST_STRAIN_MIN_SIZE 5
/// The seam sound waits for the garment's own equip sound, which would drown it.
#define BREAST_STRAIN_SOUND_DELAY (0.5 SECONDS)
/// Time between discomfort messages while a strained garment is worn.
#define BREAST_STRAIN_MESSAGE_MIN (3 MINUTES)
#define BREAST_STRAIN_MESSAGE_MAX (5 MINUTES)
/// Own milk share from which the breasts count as full.
#define BREAST_FULL_RATIO 0.75
/// Own milk share at which Swelling Glands makes the breasts one size bigger: the middle of the three-step gradation.
#define BREAST_SWELL_RATIO FLUID_ENGORGEMENT_STEP_2
/// Sprinted tiles between two leaks of full breasts.
#define BREAST_SPRINT_LEAK_TILES 6
#define BREAST_SPRAY_COOLDOWN (20 SECONDS)
/// Flavour messages while sprinting, falling or hit.
#define BREAST_FLAVOUR_COOLDOWN (90 SECONDS)
#define BREAST_RELIEVED_DURATION (5 MINUTES)

/// Visible size to stats, keys as in effectedstats. Sizes 0-5 keep the old per-size status numbers.
GLOBAL_LIST_INIT(breast_size_stats, list(
	"0" = list("speed" = 2),
	"1" = list("speed" = 1),
	"2" = list(),
	"3" = list(),
	"4" = list("constitution" = 1, "speed" = -1),
	"5" = list("constitution" = 2, "speed" = -1),
	"6" = list("constitution" = 2, "speed" = -2),
	"7" = list("constitution" = 2, "speed" = -2, "endurance" = -1),
	"8" = list("constitution" = 2, "speed" = -3, "endurance" = -1),
))

/// Fatigue tier to extra sprint stamina per tile, as a share of BREAST_SPRINT_BASE_COST.
GLOBAL_LIST_INIT(breast_size_sprint_cost, list("6" = 0.15, "7" = 0.3, "8" = 0.5))

/// Visible size to arousal multiplier when the breasts are touched; bigger ones take more effort.
GLOBAL_LIST_INIT(breast_touch_sensitivity, list("6" = 0.85, "7" = 0.75, "8" = 0.55))
/// Visible size to extra seconds to stand up.
GLOBAL_LIST_INIT(breast_stand_extra_time, list("6" = 1, "7" = 1.5, "8" = 2))
/// Visible size to seam sound volume when a plain chest garment is put on.
GLOBAL_LIST_INIT(breast_strain_volume, list("5" = 25, "6" = 35, "7" = 50, "8" = 65))
GLOBAL_LIST_INIT(breast_strain_equip_text, list(
	"5" = "ITEM is a touch tight across my chest.",
	"6" = "ITEM fits a little snug across my chest.",
	"7" = "A seam creaks as I squeeze into ITEM.",
	"8" = "Seams groan as I force ITEM over my chest.",
))
GLOBAL_LIST_INIT(breast_strain_examine_text, list(
	"5" = "ITEM hugs THEIR chest closely.",
	"6" = "ITEM sits snugly over THEIR chest.",
	"7" = "ITEM strains against THEIR chest.",
	"8" = "ITEM is stretched to bursting over THEIR chest.",
))
GLOBAL_LIST_INIT(breast_strain_stress, list(
	"6" = /datum/stress_event/tight_clothes,
	"7" = /datum/stress_event/tight_clothes_bad,
	"8" = /datum/stress_event/tight_clothes_bad,
))
GLOBAL_LIST_INIT(breast_strain_flavour_text, list(
	"5" = list(
		"ITEM pulls a little across my chest when I move.",
		"I tug ITEM into a more comfortable spot.",
		"ITEM is a touch snug over my chest.",
	),
	"6" = list(
		"ITEM presses against my chest.",
		"ITEM rubs against my chest with every breath.",
		"I roll my shoulders, trying to ease ITEM's grip on my chest.",
	),
	"7" = list(
		"The seams of ITEM dig into my chest.",
		"I tug at ITEM, but nothing eases the squeeze.",
		"Every breath strains ITEM a little more.",
	),
	"8" = list(
		"ITEM crushes my chest. It's hard to breathe.",
		"The seams of ITEM creak with every breath.",
		"ITEM is cutting into my chest. I need to get out of it.",
	),
))
/// Visible size of the giver's breasts to arousal multiplier for the receiver of a boob job.
GLOBAL_LIST_INIT(breast_paizuri_bonus, list("8" = 1.2))
/// Visible size to milking speed multiplier.
GLOBAL_LIST_INIT(breast_milking_rate, list("7" = 1.25, "8" = 1.5))
/// Own milk share to units leaked while sprinting; the highest share reached counts.
GLOBAL_LIST_INIT(breast_sprint_leak, list("0.95" = 1.5, "0.75" = 1))
/// Own milk share to units sprayed by a fall or chest hit.
GLOBAL_LIST_INIT(breast_spray_amount, list("0.95" = 4, "0.75" = 3))

/obj/item/organ/genitals/filling_organ/breasts/proc/is_full_of_milk()
	return get_own_fullness() >= BREAST_FULL_RATIO

/// Swelling Glands on breasts: one size at BREAST_SWELL_RATIO; balls keep the three steps of filling_organ.dm.
/obj/item/organ/genitals/filling_organ/breasts/get_engorgement_steps_for(fullness)
	return fullness >= BREAST_SWELL_RATIO ? 1 : 0

/// Value of a fill table for the breasts' own milk share now, 0 below its lowest share.
/obj/item/organ/genitals/filling_organ/breasts/proc/get_fill_value(list/table)
	var/fullness = get_own_fullness()
	var/best_ratio = 0
	. = 0
	for(var/ratio_text in table)
		var/ratio = text2num(ratio_text)
		if(fullness >= ratio && ratio > best_ratio)
			best_ratio = ratio
			. = table[ratio_text]

/// Strain table text for the size, one picked from a list, with ITEM and THEIR filled in.
/proc/get_breast_strain_text(list/table, size, obj/item/item, their)
	var/text = LAZYACCESS(table, "[min(size, 8)]")
	if(islist(text))
		text = pick(text)
	if(!text)
		return null
	text = replacetext(text, "ITEM", "[item]")
	text = replacetext(text, "THEIR", their)
	return capitalize(text)

/mob/living/carbon/human
	/// Size, fullness and swelling the breast size effect was last applied for.
	var/breast_size_effect_key
	var/breast_size_effect_size
	var/breast_size_effect_full = FALSE
	var/breast_size_effect_swollen = FALSE
	/// The breasts were full during the current swelling, for the relief buff when it goes down.
	var/breast_swell_was_full = FALSE

/// Re-applies the breast size effect when the visible size, fullness or swelling changed.
/mob/living/carbon/human/proc/update_breast_size_effect()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts)
		if(breast_size_effect_key)
			breast_size_effect_key = null
			breast_size_effect_size = null
			remove_status_effect(/datum/status_effect/breast_size)
		return
	var/size = clamp(breasts.get_visible_size(), 0, 8)
	var/full = breasts.is_full_of_milk()
	var/swollen = breasts.engorgement_steps > 0
	var/key = "[size]|[full]|[swollen]"
	if(key == breast_size_effect_key)
		return
	var/had_effect = !isnull(breast_size_effect_size)
	var/old_size = breast_size_effect_size
	if(swollen && full)
		breast_swell_was_full = TRUE
	var/old_full = breast_swell_was_full
	if(!swollen)
		breast_swell_was_full = FALSE
	var/old_swollen = breast_size_effect_swollen
	breast_size_effect_key = key
	breast_size_effect_size = size
	breast_size_effect_full = full
	breast_size_effect_swollen = swollen
	remove_status_effect(/datum/status_effect/breast_size)
	apply_status_effect(/datum/status_effect/breast_size, null, size, full)
	if(had_effect && swollen != old_swollen)
		breast_size_changed_message(old_size, size, old_full, swollen)

/// Messages when Swelling Glands swells the breasts or the swelling goes down.
/mob/living/carbon/human/proc/breast_size_changed_message(old_size, new_size, old_full, swollen)
	if(swollen)
		switch(new_size)
			if(0 to 5)
				to_chat(src, span_notice("My breasts swell, heavy with milk."))
			if(6)
				to_chat(src, span_warning("My chest swells, heavy and tight."))
			if(7)
				to_chat(src, span_warning("My breasts swell, straining against everything."))
			else
				to_chat(src, span_warning("They swell so full it hurts to move."))
		return
	// Relief, and a short buff when big breasts had been full.
	if(old_full && old_size >= BREAST_WEIGHT_MIN_SIZE)
		to_chat(src, span_notice("Finally... my chest feels light again."))
		apply_status_effect(/datum/status_effect/buff/breast_relieved)
		add_stress(/datum/stress_event/breasts_relieved)
	else
		to_chat(src, span_notice("Some of the pressure in my chest eases."))

/// Fatigue tier for sprinting: visible size, +1 for Naturally Endowed, -1 with a supporting bra.
/mob/living/carbon/human/proc/get_breast_fatigue_tier(size)
	. = size
	if(has_status_effect(/datum/status_effect/debuff/boobs_quirk))
		. = min(. + 1, 8)
	if(bra && (bra.flags_inv & HIDEBOOB))
		. -= 1

/// The outermost plain garment worn over the chest, which big breasts strain.
/mob/living/carbon/human/proc/get_strained_chest_garment()
	for(var/obj/item/item as anything in list(cloak, wear_armor, wear_shirt))
		if(is_strained_chest_garment(item))
			return item
	return null

/// Whether the item is a plain shirt, armor or tabard over the chest, whatever is worn over it.
/mob/living/carbon/human/proc/is_strained_chest_garment(obj/item/item)
	if(!item || item.uses_breast_sized_layers(src))
		return FALSE
	if(item != wear_shirt && item != wear_armor && !(item == cloak && cloak.alternate_worn_layer == TABARD_LAYER))
		return FALSE
	return (item.body_parts_covered & CHEST) || (item.flags_inv & HIDEBOOB)

/// Extra seconds to stand up, added in get_up().
/mob/living/proc/get_extra_stand_time()
	return 0

/mob/living/carbon/human/get_extra_stand_time()
	return LAZYACCESS(GLOB.breast_stand_extra_time, "[breast_size_effect_size]") || 0

/datum/status_effect/breast_size
	id = "breast_size"
	duration = -1
	/// Checks the strained garment for stress and discomfort messages.
	tick_interval = 5 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/size = 0
	var/full = FALSE
	var/sprinted_tiles = 0
	/// Stress event type applied for the strained garment now.
	var/strain_stress
	/// world.time of the next discomfort message; 0 while nothing is strained.
	var/next_strain_message = 0
	COOLDOWN_DECLARE(spray_cooldown)
	COOLDOWN_DECLARE(flavour_cooldown)

/datum/status_effect/breast_size/on_creation(mob/living/new_owner, duration_override, size, full)
	src.size = size
	src.full = full
	var/list/stats = LAZYACCESS(GLOB.breast_size_stats, "[size]")
	effectedstats = stats ? stats.Copy() : list()
	if(size >= BREAST_WEIGHT_MIN_SIZE)
		alert_type = full ? /atom/movable/screen/alert/status_effect/breast_size/full : /atom/movable/screen/alert/status_effect/breast_size
	return ..()

/datum/status_effect/breast_size/on_apply()
	. = ..()
	// Sprint cost needs weight and leaking needs milk; the effect is replaced when either changes.
	if(size >= BREAST_WEIGHT_MIN_SIZE || full)
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(owner, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_knockdown))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage))
	if(size >= BREAST_STRAIN_MIN_SIZE)
		RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped))
		RegisterSignal(owner, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_unequipped))
		update_strain()

/datum/status_effect/breast_size/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_MOB_APPLY_DAMAGE))
	if(strain_stress)
		owner.remove_stress(strain_stress)
	return ..()

/datum/status_effect/breast_size/tick()
	update_strain(TRUE)

/datum/status_effect/breast_size/get_examine_text(mob/user, list/P)
	if(!ishuman(owner))
		return null
	var/mob/living/carbon/human/human_owner = owner
	var/their = P ? LOWER_TEXT(P[THEIR]) : owner.p_their()
	var/list/lines = list()
	if(size >= BREAST_STRAIN_MIN_SIZE)
		var/obj/item/garment = human_owner.get_strained_chest_garment()
		if(garment)
			lines += span_notice(get_breast_strain_text(GLOB.breast_strain_examine_text, size, garment, their))
	// Breast Enthusiast: the one looking, and the one looked at.
	if(size >= 4 && ishuman(user) && get_breast_exposure(human_owner))
		var/mob/living/carbon/human/viewer = user
		if(viewer == owner)
			if(viewer.get_quirk(/datum/quirk/negative/breast_enthusiast))
				lines += span_love("You take a moment to admire your own curves.")
		else
			if(viewer.get_quirk(/datum/quirk/negative/breast_enthusiast))
				if(size >= 7)
					lines += span_love("[capitalize(their)] bust dominates your entire view. You've stopped pretending not to stare.")
				else
					lines += span_love(pick("You can't tear your eyes away from [their] cleavage.", "Your gaze keeps drifting back to [their] chest."))
			var/datum/quirk/negative/breast_enthusiast/owner_vice = human_owner.get_quirk(/datum/quirk/negative/breast_enthusiast)
			owner_vice?.admired_by(human_owner, viewer)
	return length(lines) ? lines.Join("\n") : null

/// Sprinting costs more stamina; full breasts leak and bounce.
/datum/status_effect/breast_size/proc/on_moved(mob/living/carbon/human/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(forced || source.m_intent != MOVE_INTENT_RUN || source.buckled || source.body_position == LYING_DOWN)
		return
	var/share = LAZYACCESS(GLOB.breast_size_sprint_cost, "[source.get_breast_fatigue_tier(size)]")
	if(share)
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living, adjust_stamina), BREAST_SPRINT_BASE_COST * share)
	sprinted_tiles++
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = source.getorganslot(ORGAN_SLOT_BREASTS)
	var/leak = breasts?.get_fill_value(GLOB.breast_sprint_leak)
	if(leak && sprinted_tiles % BREAST_SPRINT_LEAK_TILES == 0)
		if(source.bra && (source.bra.flags_inv & HIDEBOOB))
			leak /= 2
		INVOKE_ASYNC(breasts, TYPE_PROC_REF(/obj/item/organ/genitals/filling_organ, leak_reagents), leak)
	if(size < BREAST_WEIGHT_MIN_SIZE || !COOLDOWN_FINISHED(src, flavour_cooldown) || !prob(15))
		return
	COOLDOWN_START(src, flavour_cooldown, BREAST_FLAVOUR_COOLDOWN)
	if(full)
		source.visible_message(span_notice("[source]'s chest sways heavily as [source.p_they()] run[source.p_s()], and milk dribbles down [source.p_their()] front."), span_notice("Running with these is a chore."))
	else
		source.visible_message(span_notice("[source]'s chest sways heavily as [source.p_they()] run[source.p_s()]."), span_notice("My back aches under the weight."))

/// Squeezing into a plain garment over a big chest: a seam sound after the equip sound.
/datum/status_effect/breast_size/proc/on_equipped(mob/living/carbon/human/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(source.is_strained_chest_garment(item))
		addtimer(CALLBACK(src, PROC_REF(strain_on_equip), item), BREAST_STRAIN_SOUND_DELAY)

/datum/status_effect/breast_size/proc/strain_on_equip(obj/item/item)
	if(QDELETED(src) || QDELETED(item))
		return
	var/mob/living/carbon/human/source = owner
	if(!istype(source) || !source.is_strained_chest_garment(item))
		return
	playsound(source, 'sound/foley/cloth_rip.ogg', LAZYACCESS(GLOB.breast_strain_volume, "[size]") || 25, TRUE, -6)
	strain_message(get_breast_strain_text(GLOB.breast_strain_equip_text, size, item, source.p_their()))
	update_strain()

/datum/status_effect/breast_size/proc/on_unequipped(mob/living/carbon/human/source, obj/item/item)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(update_strain)), 1)

/// Yellow from size 6, grey at 5.
/datum/status_effect/breast_size/proc/strain_message(text)
	if(text)
		to_chat(owner, size >= BREAST_WEIGHT_MIN_SIZE ? span_warning(text) : span_notice(text))

/// Stress while a strained garment is worn; with discomfort_messages, also a discomfort message when one is due.
/datum/status_effect/breast_size/proc/update_strain(discomfort_messages = FALSE)
	if(QDELETED(src))
		return
	var/mob/living/carbon/human/source = owner
	if(!istype(source))
		return
	var/obj/item/garment = size >= BREAST_STRAIN_MIN_SIZE ? source.get_strained_chest_garment() : null
	var/stress_type = garment ? LAZYACCESS(GLOB.breast_strain_stress, "[size]") : null
	if(stress_type != strain_stress)
		if(strain_stress)
			source.remove_stress(strain_stress)
		strain_stress = stress_type
		if(strain_stress)
			source.add_stress(strain_stress)
	if(!garment)
		next_strain_message = 0
		return
	if(!next_strain_message)
		next_strain_message = world.time + rand(BREAST_STRAIN_MESSAGE_MIN, BREAST_STRAIN_MESSAGE_MAX)
		return
	if(!discomfort_messages || world.time < next_strain_message || source.stat != CONSCIOUS)
		return
	next_strain_message = world.time + rand(BREAST_STRAIN_MESSAGE_MIN, BREAST_STRAIN_MESSAGE_MAX)
	strain_message(get_breast_strain_text(GLOB.breast_strain_flavour_text, size, garment, source.p_their()))

/datum/status_effect/breast_size/proc/on_knockdown(mob/living/carbon/human/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	if(amount <= 0)
		return
	if(spray(source, span_warning("Milk sprays from [source]'s chest as [source.p_they()] hit[source.p_s()] the ground!")))
		return
	if(size >= BREAST_WEIGHT_MIN_SIZE && COOLDOWN_FINISHED(src, flavour_cooldown) && prob(30))
		COOLDOWN_START(src, flavour_cooldown, BREAST_FLAVOUR_COOLDOWN)
		source.visible_message(span_notice("[source] lands hard on [source.p_their()] chest and winces."))

/datum/status_effect/breast_size/proc/on_damage(mob/living/carbon/human/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(def_zone != BODY_ZONE_CHEST || damagetype != BRUTE || damage < 5)
		return
	if(spray(source, span_warning("[source] gasps as the blow lands on [source.p_their()] full chest, and milk sprays out!")))
		return
	if(size >= 7 && full && COOLDOWN_FINISHED(src, flavour_cooldown))
		COOLDOWN_START(src, flavour_cooldown, BREAST_FLAVOUR_COOLDOWN)
		source.visible_message(span_warning("[source] gasps as the blow lands on [source.p_their()] swollen chest."))

/// Milk sprays out of breasts at least 75 % full, more the fuller they are. TRUE if it did.
/datum/status_effect/breast_size/proc/spray(mob/living/carbon/human/source, message)
	if(!COOLDOWN_FINISHED(src, spray_cooldown))
		return FALSE
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = source.getorganslot(ORGAN_SLOT_BREASTS)
	var/amount = breasts?.get_fill_value(GLOB.breast_spray_amount)
	if(!amount || !breasts.reagents?.total_volume)
		return FALSE
	COOLDOWN_START(src, spray_cooldown, BREAST_SPRAY_COOLDOWN)
	source.visible_message(message)
	playsound(source, 'sound/effects/splash.ogg', 20, TRUE, -4)
	INVOKE_ASYNC(breasts, TYPE_PROC_REF(/obj/item/organ/genitals/filling_organ, leak_reagents), amount)
	return TRUE

/atom/movable/screen/alert/status_effect/breast_size
	name = "Heavy Chest"
	desc = "Their weight pulls at my back with every step."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "bigboobslite"

/atom/movable/screen/alert/status_effect/breast_size/full
	name = "Swollen Breasts"
	desc = "Heavy, tight and full. Running is a chore, and any jolt might make them spill."
	icon_state = "bigboobs"

/datum/status_effect/buff/breast_relieved
	id = "breast_relieved"
	duration = BREAST_RELIEVED_DURATION
	alert_type = null
	effectedstats = list("speed" = 1)

/datum/stress_event/breasts_relieved
	stress_change = -2
	desc = span_green("My chest finally feels light again.")
	timer = 5 MINUTES

/// While a plain garment strains size 6 breasts; removed when it stops.
/datum/stress_event/tight_clothes
	stress_change = 1
	desc = span_red("My clothes are too tight across my chest.")

/// Sizes 7-8. Not a subtype of tight_clothes, so has_stress_type() keeps them apart.
/datum/stress_event/tight_clothes_bad
	stress_change = 2
	desc = span_red("My clothes are crushing my chest.")

#undef BREAST_SPRINT_BASE_COST
#undef BREAST_WEIGHT_MIN_SIZE
#undef BREAST_STRAIN_MIN_SIZE
#undef BREAST_STRAIN_SOUND_DELAY
#undef BREAST_STRAIN_MESSAGE_MIN
#undef BREAST_STRAIN_MESSAGE_MAX
#undef BREAST_FULL_RATIO
#undef BREAST_SWELL_RATIO
#undef BREAST_SPRINT_LEAK_TILES
#undef BREAST_SPRAY_COOLDOWN
#undef BREAST_FLAVOUR_COOLDOWN
#undef BREAST_RELIEVED_DURATION
