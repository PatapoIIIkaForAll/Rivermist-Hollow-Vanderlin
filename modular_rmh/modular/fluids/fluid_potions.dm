// Potions that boost, reduce, stop or swap what genital organs produce.

/// Sex and potion reagents a swap never copies: they carry parent data or spread their own effects.
GLOBAL_LIST_INIT(fluid_swap_blacklist, list(
	/datum/reagent/consumable/cum,
	/datum/reagent/consumable/femcum,
	/datum/reagent/consumable/lactation_inducer,
	/datum/reagent/consumable/aphrodisiac,
))

/// Swaps may copy food, drink and water; unbound swaps copy anything except fluid potions.
/proc/is_fluid_swap_target(datum/reagent/reagent_type, unbound = FALSE)
	if(ispath(reagent_type, /datum/reagent/fluid_potion))
		return FALSE
	if(unbound)
		return TRUE
	if(!ispath(reagent_type, /datum/reagent/consumable) && reagent_type != /datum/reagent/water)
		return FALSE
	if(is_path_in_list(reagent_type, GLOB.fluid_swap_blacklist))
		return FALSE
	var/datum/reagent/template = GLOB.chemical_reagents_list[reagent_type]
	return template?.can_synth

/// The eligible reagent with the most volume across the drinker's stomach and blood, or null.
/proc/find_fluid_swap_pair(mob/living/carbon/drinker, unbound = FALSE)
	var/list/volumes = list()
	var/list/holders = list(drinker.reagents)
	for(var/obj/item/organ/stomach/stomach in drinker.getorganslotlist(ORGAN_SLOT_STOMACH))
		holders += stomach.reagents
	for(var/datum/reagents/holder in holders)
		for(var/datum/reagent/reagent as anything in holder.reagent_list)
			if(is_fluid_swap_target(reagent.type, unbound))
				volumes[reagent.type] += reagent.volume
	for(var/reagent_type in volumes)
		if(volumes[reagent_type] < FLUID_SWAP_MIN_PAIR_VOLUME)
			continue
		if(!. || volumes[reagent_type] > volumes[.])
			. = reagent_type

/// Takes effect once a dose is in the blood, then the rest of it is used up.
/datum/reagent/fluid_potion
	abstract_type = /datum/reagent/fluid_potion
	name = "Fluid Potion"
	description = "A draught that meddles with the body's fluids."
	reagent_state = LIQUID
	metabolization_rate = REAGENTS_METABOLISM
	/// Status effect applied when the dose takes effect.
	var/datum/status_effect/applied_effect
	/// Set when the dose is spent, so the fizzle message stays quiet.
	var/used_up = FALSE

/datum/reagent/fluid_potion/on_mob_life(mob/living/carbon/M, efficiency)
	if(!used_up && M.has_reagent(type, FLUID_POTION_DOSE) && try_take_effect(M))
		used_up = TRUE
		purge_from_body(M)
	return ..()

/// Removes the potion from stomach and blood, so leftovers cannot trigger it again.
/datum/reagent/fluid_potion/proc/purge_from_body(mob/living/carbon/drinker)
	if(iscarbon(drinker))
		for(var/obj/item/organ/stomach/stomach in drinker.getorganslotlist(ORGAN_SLOT_STOMACH))
			stomach.reagents?.del_reagent(type)
	drinker.reagents.del_reagent(type)

/// Returns TRUE when the dose is spent, whether or not the body accepted it.
/datum/reagent/fluid_potion/proc/try_take_effect(mob/living/carbon/drinker)
	if(!drinker.get_erp_pref(/datum/erp_preference/boolean/allow_fluid_potions))
		to_chat(drinker, span_warning("My body shrugs off the draught."))
		return TRUE
	return take_effect(drinker)

/datum/reagent/fluid_potion/proc/take_effect(mob/living/carbon/drinker)
	drinker.apply_status_effect(applied_effect)
	return TRUE

/datum/reagent/fluid_potion/surge
	name = "Brimming Draught"
	description = "Makes every gland in the body work twice as hard for a while."
	color = "#f2b8c6"
	taste_description = "warm cream and honey"
	scent_description = "warm milk"
	applied_effect = /datum/status_effect/buff/fluid_potion/surge

/datum/reagent/fluid_potion/ebb
	name = "Ebbing Draught"
	description = "Slows the body's fluids to a trickle for a while."
	color = "#9fb6c9"
	taste_description = "cold river water"
	scent_description = "wet stone"
	applied_effect = /datum/status_effect/buff/fluid_potion/ebb

/datum/reagent/fluid_potion/drought
	name = "Drying Draught"
	description = "Stops the body making any fluids for a while."
	color = "#c9b48a"
	taste_description = "dust and chalk"
	scent_description = "dry straw"
	applied_effect = /datum/status_effect/buff/fluid_potion/drought

/// Binds to the largest eligible reagent drunk with it; waits in the blood until one arrives.
/datum/reagent/fluid_potion/swap
	abstract_type = /datum/reagent/fluid_potion/swap
	name = "Swap Draught"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	/// Pairs with any reagent, including medicine, poison and potions. Admin-spawn only.
	var/unbound = FALSE

/datum/reagent/fluid_potion/swap/take_effect(mob/living/carbon/drinker)
	if(!iscarbon(drinker))
		return TRUE
	var/datum/reagent/pair = find_fluid_swap_pair(drinker, unbound)
	if(!pair)
		return FALSE
	drinker.apply_status_effect(applied_effect, null, pair)
	return TRUE

/datum/reagent/fluid_potion/swap/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(!used_up)
		to_chat(L, span_warning("The draught fades without finding anything to take after."))

/datum/reagent/fluid_potion/swap/milk
	name = "Milk Swap Draught"
	description = "Makes the breasts yield whatever drink it was taken with."
	color = "#e8e0f0"
	taste_description = "sweet milk turning sour"
	scent_description = "curdled cream"
	applied_effect = /datum/status_effect/buff/fluid_swap/breasts

/datum/reagent/fluid_potion/swap/seed
	name = "Seed Swap Draught"
	description = "Makes the testicles yield whatever drink it was taken with."
	color = "#d8d0c0"
	taste_description = "salt and musk"
	scent_description = "musk"
	applied_effect = /datum/status_effect/buff/fluid_swap/testicles

/datum/reagent/fluid_potion/swap/nectar
	name = "Nectar Swap Draught"
	description = "Makes the womb yield whatever drink it was taken with."
	color = "#f0c8e0"
	taste_description = "flower nectar"
	scent_description = "blossoms"
	applied_effect = /datum/status_effect/buff/fluid_swap/vagina

// Unbound swaps have no recipe or pack; admins spawn their vials.
/datum/reagent/fluid_potion/swap/milk/unbound
	name = "Unbound Milk Swap Draught"
	description = "A forbidden draught that makes the breasts yield anything taken with it, even medicine or poison."
	color = "#5a2a6e"
	can_synth = FALSE
	unbound = TRUE

/datum/reagent/fluid_potion/swap/seed/unbound
	name = "Unbound Seed Swap Draught"
	description = "A forbidden draught that makes the testicles yield anything taken with it, even medicine or poison."
	color = "#4e3a2a"
	can_synth = FALSE
	unbound = TRUE

/datum/reagent/fluid_potion/swap/nectar/unbound
	name = "Unbound Nectar Swap Draught"
	description = "A forbidden draught that makes the womb yield anything taken with it, even medicine or poison."
	color = "#6e2a4a"
	can_synth = FALSE
	unbound = TRUE

/// Adds a fluid modifier for the duration, sourced by its own id.
/datum/status_effect/buff/fluid_potion
	id = "fluid_potion"
	alert_type = null
	duration = 20 MINUTES
	tick_interval = STATUS_EFFECT_NO_TICK
	var/datum/fluid_modifier/modifier_type

/datum/status_effect/buff/fluid_potion/on_apply()
	. = ..()
	owner.add_fluid_modifier(modifier_type, id)

/datum/status_effect/buff/fluid_potion/on_remove()
	owner.remove_fluid_modifier(modifier_type, id)
	return ..()

/datum/status_effect/buff/fluid_potion/surge
	id = "fluid_surge"
	modifier_type = /datum/fluid_modifier/fluid_surge
	alert_type = /atom/movable/screen/alert/status_effect/buff/fluid_surge

/datum/status_effect/buff/fluid_potion/ebb
	id = "fluid_ebb"
	modifier_type = /datum/fluid_modifier/fluid_ebb
	alert_type = /atom/movable/screen/alert/status_effect/debuff/fluid_ebb

/datum/status_effect/buff/fluid_potion/drought
	id = "fluid_drought"
	modifier_type = /datum/fluid_modifier/fluid_drought
	alert_type = /atom/movable/screen/alert/status_effect/debuff/fluid_drought

/atom/movable/screen/alert/status_effect/buff/fluid_surge
	name = "Brimming"
	desc = "My body makes its fluids twice as fast, and I release more of them."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "virility"

/atom/movable/screen/alert/status_effect/debuff/fluid_ebb
	name = "Ebbing"
	desc = "My body makes its fluids slowly, and I release less of them."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "fluid_ebb"

/atom/movable/screen/alert/status_effect/debuff/fluid_drought
	name = "Dried Up"
	desc = "My body makes no fluids at all."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "fluid_drought"

/// Makes one organ produce the paired reagent; a new swap on the same organ replaces it.
/datum/status_effect/buff/fluid_swap
	id = "fluid_swap"
	duration = 20 MINUTES
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/buff/fluid_swap
	/// Organ slot whose output is swapped.
	var/target_slot
	/// How the organ is named in messages.
	var/organ_word
	/// Reagent the organ makes while this lasts.
	var/datum/reagent/swap_reagent

/datum/status_effect/buff/fluid_swap/on_creation(mob/living/new_owner, duration_override, datum/reagent/reagent_type)
	swap_reagent = reagent_type
	. = ..()
	if(linked_alert)
		linked_alert.desc = "My [organ_word] make [initial(swap_reagent.name)] instead of their usual fluid."

/datum/status_effect/buff/fluid_swap/on_apply()
	. = ..()
	if(!swap_reagent)
		return FALSE
	owner.set_fluid_reagent_override(target_slot, swap_reagent)
	to_chat(owner, span_love("My [organ_word] tingle. They will make [initial(swap_reagent.name)] for a while."))

/datum/status_effect/buff/fluid_swap/on_remove()
	owner.clear_fluid_reagent_override(target_slot, swap_reagent)
	return ..()

/datum/status_effect/buff/fluid_swap/breasts
	id = "milk_swap"
	target_slot = ORGAN_SLOT_BREASTS
	organ_word = "breasts"

/datum/status_effect/buff/fluid_swap/testicles
	id = "seed_swap"
	target_slot = ORGAN_SLOT_TESTICLES
	organ_word = "balls"

/datum/status_effect/buff/fluid_swap/vagina
	id = "nectar_swap"
	target_slot = ORGAN_SLOT_VAGINA
	organ_word = "loins"

/atom/movable/screen/alert/status_effect/buff/fluid_swap
	name = "Swapped Fluid"
	desc = "One of my organs makes a different fluid for a while."
	icon = 'modular_rmh/icons/mob/screen_alert.dmi'
	icon_state = "fluid_swap"

/obj/item/reagent_containers/glass/bottle/vial/fluid_surge
	desc = "A vial of thick, rosy liquid. The label promises a bountiful yield."
	list_reagents = list(/datum/reagent/fluid_potion/surge = 25)

/obj/item/reagent_containers/glass/bottle/vial/fluid_ebb
	desc = "A vial of pale blue liquid. The label promises a lighter load."
	list_reagents = list(/datum/reagent/fluid_potion/ebb = 25)

/obj/item/reagent_containers/glass/bottle/vial/fluid_drought
	desc = "A vial of dusty yellow liquid. The label promises a dry spell."
	list_reagents = list(/datum/reagent/fluid_potion/drought = 25)

/obj/item/reagent_containers/glass/bottle/vial/milk_swap
	desc = "A vial of pearly liquid. The label says to drink it with something else."
	list_reagents = list(/datum/reagent/fluid_potion/swap/milk = 25)

/obj/item/reagent_containers/glass/bottle/vial/seed_swap
	desc = "A vial of cloudy liquid. The label says to drink it with something else."
	list_reagents = list(/datum/reagent/fluid_potion/swap/seed = 25)

/obj/item/reagent_containers/glass/bottle/vial/nectar_swap
	desc = "A vial of pink liquid. The label says to drink it with something else."
	list_reagents = list(/datum/reagent/fluid_potion/swap/nectar = 25)

/obj/item/reagent_containers/glass/bottle/vial/milk_swap/unbound
	desc = "A vial of dark, shimmering liquid. There is no label."
	list_reagents = list(/datum/reagent/fluid_potion/swap/milk/unbound = 25)

/obj/item/reagent_containers/glass/bottle/vial/seed_swap/unbound
	desc = "A vial of dark, shimmering liquid. There is no label."
	list_reagents = list(/datum/reagent/fluid_potion/swap/seed/unbound = 25)

/obj/item/reagent_containers/glass/bottle/vial/nectar_swap/unbound
	desc = "A vial of dark, shimmering liquid. There is no label."
	list_reagents = list(/datum/reagent/fluid_potion/swap/nectar/unbound = 25)

/obj/item/reagent_containers/glass/bottle/vial/lactation_inducer
	desc = "A vial of creamy liquid. The label promises milk."
	list_reagents = list(/datum/reagent/consumable/lactation_inducer = 25)

/datum/alch_cauldron_recipe/fluid_surge
	recipe_name = "Brimming Draught"
	smells_like = "warm milk"
	output_reagents = list(/datum/reagent/fluid_potion/surge = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/life = 3,
		/datum/thaumaturgical_essence/water = 3,
		/datum/thaumaturgical_essence/energia = 2,
	)

/datum/alch_cauldron_recipe/fluid_ebb
	recipe_name = "Ebbing Draught"
	smells_like = "wet stone"
	output_reagents = list(/datum/reagent/fluid_potion/ebb = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/water = 3,
		/datum/thaumaturgical_essence/frost = 2,
		/datum/thaumaturgical_essence/order = 2,
	)

/datum/alch_cauldron_recipe/fluid_drought
	recipe_name = "Drying Draught"
	smells_like = "dry straw"
	output_reagents = list(/datum/reagent/fluid_potion/drought = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/water = 2,
		/datum/thaumaturgical_essence/order = 3,
		/datum/thaumaturgical_essence/void = 2,
	)

/datum/alch_cauldron_recipe/lactation_inducer
	recipe_name = "Lactation Inducer"
	smells_like = "fresh cream"
	output_reagents = list(/datum/reagent/consumable/lactation_inducer = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/life = 3,
		/datum/thaumaturgical_essence/water = 2,
		/datum/thaumaturgical_essence/light = 2,
	)

/datum/alch_cauldron_recipe/milk_swap
	recipe_name = "Milk Swap Draught"
	smells_like = "curdled cream"
	output_reagents = list(/datum/reagent/fluid_potion/swap/milk = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/chaos = 3,
		/datum/thaumaturgical_essence/cycle = 3,
		/datum/thaumaturgical_essence/life = 2,
	)

/datum/alch_cauldron_recipe/seed_swap
	recipe_name = "Seed Swap Draught"
	smells_like = "musk"
	output_reagents = list(/datum/reagent/fluid_potion/swap/seed = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/chaos = 3,
		/datum/thaumaturgical_essence/cycle = 3,
		/datum/thaumaturgical_essence/fire = 2,
	)

/datum/alch_cauldron_recipe/nectar_swap
	recipe_name = "Nectar Swap Draught"
	smells_like = "blossoms"
	output_reagents = list(/datum/reagent/fluid_potion/swap/nectar = 25)
	required_essences = list(
		/datum/thaumaturgical_essence/chaos = 3,
		/datum/thaumaturgical_essence/cycle = 3,
		/datum/thaumaturgical_essence/energia = 2,
	)

/datum/supply_pack/narcotics/fluid_surge
	name = "Brimming Draught"
	cost = 30
	contains = /obj/item/reagent_containers/glass/bottle/vial/fluid_surge

/datum/supply_pack/narcotics/fluid_ebb
	name = "Ebbing Draught"
	cost = 20
	contains = /obj/item/reagent_containers/glass/bottle/vial/fluid_ebb

/datum/supply_pack/narcotics/fluid_drought
	name = "Drying Draught"
	cost = 20
	contains = /obj/item/reagent_containers/glass/bottle/vial/fluid_drought

/datum/supply_pack/narcotics/lactation_inducer
	name = "Lactation Inducer"
	cost = 25
	contains = /obj/item/reagent_containers/glass/bottle/vial/lactation_inducer

/datum/supply_pack/narcotics/milk_swap
	name = "Milk Swap Draught"
	cost = 80
	contains = /obj/item/reagent_containers/glass/bottle/vial/milk_swap

/datum/supply_pack/narcotics/seed_swap
	name = "Seed Swap Draught"
	cost = 80
	contains = /obj/item/reagent_containers/glass/bottle/vial/seed_swap

/datum/supply_pack/narcotics/nectar_swap
	name = "Nectar Swap Draught"
	cost = 80
	contains = /obj/item/reagent_containers/glass/bottle/vial/nectar_swap
