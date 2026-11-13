// Fertility: pregnancy stays hidden until its signs show, a seed sachet tells early, and contraceptive draughts.

/obj/item/organ/genitals/filling_organ
	/// world.time of conception for the current conventional pregnancy.
	var/conception_time = 0
	/// Timer that starts morning sickness.
	var/morning_sickness_timer

/// Called on conception instead of an announcement.
/obj/item/organ/genitals/filling_organ/proc/start_hidden_pregnancy()
	conception_time = world.time
	hint_conception()
	morning_sickness_timer = addtimer(CALLBACK(src, PROC_REF(start_morning_sickness)), rand(PREGNANCY_SICKNESS_MIN_DELAY, PREGNANCY_SICKNESS_MAX_DELAY), TIMER_STOPPABLE)

/// A small, vague hint; owners with self-aware genitals feel it more clearly.
/obj/item/organ/genitals/filling_organ/proc/hint_conception()
	if(!owner)
		return
	if(owner.has_quirk(/datum/quirk/neutral/selfawaregeni))
		to_chat(owner, span_love("Something feels different, deep inside my [get_oviposition_location_name()]..."))
		return
	to_chat(owner, span_small(span_love("A faint warmth settles low in my belly.")))

/obj/item/organ/genitals/filling_organ/proc/start_morning_sickness()
	morning_sickness_timer = null
	if(!pregnant || !owner || conventional_pregnancy_stage >= 1)
		return
	owner.apply_status_effect(/datum/status_effect/morning_sickness)

/obj/item/organ/genitals/filling_organ/proc/stop_pregnancy_signs()
	if(morning_sickness_timer)
		deltimer(morning_sickness_timer)
		morning_sickness_timer = null
	owner?.remove_status_effect(/datum/status_effect/morning_sickness)

/// The belly grows a stage; the first one also brings the milk in and ends morning sickness.
/obj/item/organ/genitals/filling_organ/proc/advance_pregnancy_stage()
	conventional_pregnancy_stage = min(conventional_pregnancy_stage + 1, PREGNANCY_MAX_STAGE)
	to_chat(owner, span_love("I notice my belly has grown due to pregnancy..."))
	if(conventional_pregnancy_stage == 1)
		stop_pregnancy_signs()
		var/obj/item/organ/genitals/filling_organ/breasts/breasts = owner.getorganslot(ORGAN_SLOT_BREASTS)
		if(breasts && !breasts.is_producing())
			to_chat(owner, span_love("My nipples feel damp and warm. I'm leaking milk..."))
		start_pregnancy_lactation()
	update_reagent_capacity()
	SEND_SIGNAL(src, COMSIG_BODYSTORAGE_CHANGED)

/// A pregnancy far enough along for a seed sachet to notice.
/obj/item/organ/genitals/filling_organ/proc/is_detectably_pregnant()
	if(pregnant)
		return world.time - conception_time >= PREGNANCY_TEST_MIN_AGE
	return has_oviposition_pregnancy()

/mob/living/proc/is_detectably_pregnant()
	return FALSE

/mob/living/carbon/is_detectably_pregnant()
	for(var/obj/item/organ/genitals/filling_organ/organ in internal_organs)
		if(organ.is_detectably_pregnant())
			return TRUE
	return FALSE

/datum/status_effect/morning_sickness
	id = "morning_sickness"
	duration = PREGNANCY_SICKNESS_DURATION
	tick_interval = 1 MINUTES
	alert_type = null
	/// world.time of the next bout.
	var/next_bout = 0

/datum/status_effect/morning_sickness/tick()
	if(world.time < next_bout)
		return
	next_bout = world.time + rand(PREGNANCY_SICKNESS_MIN_GAP, PREGNANCY_SICKNESS_MAX_GAP)
	sickness_bout()

/datum/status_effect/morning_sickness/proc/sickness_bout()
	var/mob/living/carbon/sick = owner
	if(!istype(sick) || sick.stat != CONSCIOUS)
		return
	to_chat(sick, span_warning(pick(
		"My stomach turns over for no reason.",
		"A wave of queasiness washes over me.",
		"The smell of food suddenly turns my stomach.",
		"I feel faint, and a little sick.",
	)))
	// A strong bout pushes nausea over the vomiting threshold.
	sick.add_nausea(prob(PREGNANCY_RETCH_CHANCE) ? 100 : 40)

// --- Seed sachet ---

#define SACHET_DRY "dry"
#define SACHET_WET "wet"
#define SACHET_SPROUTED "sprouted"
#define SACHET_SPENT "spent"

/// The old grain test: wet the seeds, and they sprout within minutes if a child is on the way.
/obj/item/pregnancy_test
	name = "seed sachet"
	desc = "A little linen pouch of wheat and oat seeds. Wet the seeds the old way; if they sprout within a few minutes, a child is on the way."
	icon = 'modular_rmh/icons/obj/pregnancy_test.dmi'
	icon_state = "sachet"
	w_class = WEIGHT_CLASS_TINY
	var/state = SACHET_DRY
	/// What the sample showed when it was taken.
	var/result = FALSE

/obj/item/pregnancy_test/update_icon_state()
	. = ..()
	icon_state = state == SACHET_DRY ? "sachet" : "sachet_[state]"

/obj/item/pregnancy_test/attack_self(mob/user, list/modifiers)
	if(state != SACHET_DRY)
		to_chat(user, span_warning("The seeds in \the [src] have already been used."))
		return
	if(!isliving(user))
		return
	user.visible_message(span_notice("[user] turns aside for a moment with a small pouch."), span_notice("I wet the seeds in \the [src], the old way..."), vision_distance = 2)
	if(!do_after(user, PREGNANCY_TEST_WET_TIME, src) || state != SACHET_DRY)
		return
	take_sample(user)
	to_chat(user, span_notice("Now I wait a few minutes to see whether they sprout."))

/obj/item/pregnancy_test/proc/take_sample(mob/living/tested)
	result = tested.is_detectably_pregnant()
	state = SACHET_WET
	name = "damp seed sachet"
	desc = "A little linen pouch of wheat and oat seeds, still damp. Give them a few minutes."
	update_appearance(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(show_result)), PREGNANCY_TEST_READ_TIME)

/obj/item/pregnancy_test/proc/show_result()
	state = result ? SACHET_SPROUTED : SACHET_SPENT
	if(result)
		name = "sprouted seed sachet"
		desc = "Green shoots have burst from the seeds in this little linen pouch. A child is on the way."
	else
		name = "spent seed sachet"
		desc = "The seeds in this little linen pouch lie wet and still. No child, or not yet."
	update_appearance(UPDATE_ICON_STATE)
	var/mob/holder = get(loc, /mob)
	if(holder)
		to_chat(holder, span_notice(result ? "Green shoots burst from the seeds in \the [src]!" : "The seeds in \the [src] lie wet and still."))

#undef SACHET_DRY
#undef SACHET_WET
#undef SACHET_SPROUTED
#undef SACHET_SPENT

// Use wheat seed on cloth, like sweet bait.
/datum/repeatable_crafting_recipe/crafting/seed_sachet
	name = "seed sachet"
	output = /obj/item/pregnancy_test
	requirements = list(/obj/item/natural/cloth = 1, /obj/item/neuFarm/seed/wheat = 1, /obj/item/neuFarm/seed/oat = 1)
	starting_atom = /obj/item/neuFarm/seed/wheat
	attacked_atom = /obj/item/natural/cloth
	category = "Lewd"

/datum/supply_pack/medicine/seed_sachets
	name = "Seed Sachets"
	cost = 10
	contains = list(/obj/item/pregnancy_test, /obj/item/pregnancy_test, /obj/item/pregnancy_test)

// --- Contraceptives ---

/// Protective draughts always work, whatever the fluid potion preference says.
/datum/reagent/fluid_potion/contraceptive
	abstract_type = /datum/reagent/fluid_potion/contraceptive

/datum/reagent/fluid_potion/contraceptive/try_take_effect(mob/living/carbon/drinker)
	return take_effect(drinker)

/datum/reagent/fluid_potion/contraceptive/moon_tea
	name = "Moon Tea"
	description = "A bitter herbal tea that keeps seed from taking root for an hour."
	color = "#b8c4a2"
	taste_description = "bitter herbs and pennyroyal"
	scent_description = "mint and wet leaves"
	applied_effect = /datum/status_effect/buff/fluid_potion/moon_tea

/datum/reagent/fluid_potion/contraceptive/cold_seed
	name = "Cold Seed Draught"
	description = "A chilling draught that leaves a man's seed weak for an hour."
	color = "#aebfd1"
	taste_description = "cold ash"
	scent_description = "frost and ash"
	applied_effect = /datum/status_effect/buff/fluid_potion/cold_seed

/datum/status_effect/buff/fluid_potion/moon_tea
	id = "moon_tea"
	duration = CONTRACEPTIVE_DURATION
	modifier_type = /datum/fluid_modifier/barren_womb
	alert_type = /atom/movable/screen/alert/status_effect/buff/moon_tea

/datum/status_effect/buff/fluid_potion/cold_seed
	id = "cold_seed"
	duration = CONTRACEPTIVE_DURATION
	modifier_type = /datum/fluid_modifier/cold_seed
	alert_type = /atom/movable/screen/alert/status_effect/buff/cold_seed

/atom/movable/screen/alert/status_effect/buff/moon_tea
	name = "Moon Tea"
	desc = "Seed will hardly take root in me for a while."

/atom/movable/screen/alert/status_effect/buff/cold_seed
	name = "Cold Seed"
	desc = "My seed is weak for a while."

/obj/item/reagent_containers/glass/bottle/vial/moon_tea
	desc = "A vial of cloudy green tea. The label shows a crescent moon."
	list_reagents = list(/datum/reagent/fluid_potion/contraceptive/moon_tea = 25)

/obj/item/reagent_containers/glass/bottle/vial/cold_seed
	desc = "A vial of pale, chilly liquid. The label shows a frosted acorn."
	list_reagents = list(/datum/reagent/fluid_potion/contraceptive/cold_seed = 25)

/datum/alch_cauldron_recipe/moon_tea
	recipe_name = "Moon Tea"
	smells_like = "mint and wet leaves"
	output_reagents = list(/datum/reagent/fluid_potion/contraceptive/moon_tea = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/cycle = 3,
		/datum/thaumaturgical_essence/water = 2,
		/datum/thaumaturgical_essence/frost = 2,
	)

/datum/alch_cauldron_recipe/cold_seed
	recipe_name = "Cold Seed Draught"
	smells_like = "frost and ash"
	output_reagents = list(/datum/reagent/fluid_potion/contraceptive/cold_seed = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/frost = 3,
		/datum/thaumaturgical_essence/void = 2,
		/datum/thaumaturgical_essence/order = 2,
	)

/datum/supply_pack/medicine/moon_tea
	name = "Moon Tea"
	cost = 25
	contains = /obj/item/reagent_containers/glass/bottle/vial/moon_tea

/datum/supply_pack/medicine/cold_seed
	name = "Cold Seed Draught"
	cost = 25
	contains = /obj/item/reagent_containers/glass/bottle/vial/cold_seed
