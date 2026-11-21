// Body fluids remember who made them and hint at their maker's meals; drinkers learn tastes and recognise them later.

/// Diet points halve over this long, so a meal flavours fluids for roughly half an hour.
#define FLUID_DIET_HALF_LIFE (10 MINUTES)
/// Points a flavour needs before it shows in the taste.
#define FLUID_DIET_MIN_POINTS 2
/// Diet points each unit of alcohol in the blood counts for.
#define FLUID_DIET_POINTS_PER_BOOZE_UNIT 0.5

/// What a taste message calls this reagent; body fluids add a hint of their maker's recent meals.
/datum/reagent/proc/get_taste_description()
	var/hint = islist(data) ? data[FLUID_DATA_DIET] : null
	if(hint)
		return "[taste_description], with a hint of something [hint]"
	return taste_description

/// The mob whose body made this fluid, if a taste can be traced to one maker.
/datum/reagent/proc/get_fluid_donor()
	return null

/// Marks the fluid with its maker; seed and nectar keep their own lineage data instead.
/datum/reagent/proc/stamp_fluid_donor(mob/living/donor)
	return

/datum/reagent/proc/set_diet_hint(hint)
	if(data && !islist(data))
		return
	if(hint)
		LAZYSET(data, FLUID_DATA_DIET, hint)
	else if(data)
		data -= FLUID_DATA_DIET

/// A body fluid reaching someone's mouth lets them remember, or later recognise, its maker.
/datum/reagent/proc/note_fluid_taste(mob/living/drinker)
	var/mob/living/donor = get_fluid_donor()
	if(!istype(donor) || donor == drinker || !drinker?.mind)
		return
	if(drinker.get_taste_sensitivity() > 100)
		return
	drinker.mind.remember_fluid_taste(donor)

/datum/reagent/consumable/on_transfer(atom/A, method = TOUCH, trans_volume, mob/transfered_by = null)
	. = ..()
	if(!(method & INGEST))
		return
	// Swallowed reagents land in the stomach; other organs, like a womb, are not a mouth.
	var/mob/living/drinker = isliving(A) ? A : null
	if(!drinker && istype(A, /obj/item/organ/stomach))
		var/obj/item/organ/stomach/stomach = A
		drinker = stomach.owner
	if(drinker)
		note_fluid_taste(drinker)

/datum/reagent/consumable/milk/stamp_fluid_donor(mob/living/donor)
	if(!donor || (data && !islist(data)))
		return
	LAZYSET(data, FLUID_DATA_DONOR, WEAKREF(donor))
	data -= FLUID_DATA_MIXED

/// Breast milk knows its maker; cow and gote milk carry no stamp.
/datum/reagent/consumable/milk/get_fluid_donor()
	if(!islist(data) || data[FLUID_DATA_MIXED])
		return null
	var/datum/weakref/donor_ref = data[FLUID_DATA_DONOR]
	return donor_ref?.resolve()

/// The base merge copies the newest maker; two different makers leave the milk belonging to neither.
/datum/reagent/consumable/milk/on_merge(list/incoming_data, other_volume)
	var/datum/weakref/current_donor = islist(data) ? data[FLUID_DATA_DONOR] : null
	. = ..()
	if(!islist(incoming_data) || !islist(data))
		return
	var/datum/weakref/incoming_donor = incoming_data[FLUID_DATA_DONOR]
	if(current_donor && incoming_donor && current_donor != incoming_donor)
		data[FLUID_DATA_MIXED] = TRUE
		data -= FLUID_DATA_DONOR

/datum/mind
	/// Weakref to each maker whose fluids this mind tasted, mapped to list("visit" = time, "visits" = count).
	var/list/fluid_taste_memory

/// Records a taste; tasting the same maker after FAMILIAR_TASTE_GAP is a new visit and gets recognised.
/datum/mind/proc/remember_fluid_taste(mob/living/donor)
	var/datum/weakref/donor_ref = WEAKREF(donor)
	var/list/memory = LAZYACCESS(fluid_taste_memory, donor_ref)
	if(!memory)
		LAZYSET(fluid_taste_memory, donor_ref, list("visit" = world.time, "visits" = 1))
		return FALSE
	if(world.time - memory["visit"] < FAMILIAR_TASTE_GAP)
		return FALSE
	memory["visit"] = world.time
	memory["visits"]++
	recognise_fluid_taste(donor, memory["visits"])
	return TRUE

/datum/mind/proc/recognise_fluid_taste(mob/living/donor, visits)
	var/mob/living/drinker = current
	if(!drinker)
		return
	var/known = do_i_know(donor.mind, donor.real_name)
	// Built first: span_love() does not wrap its argument, so a ternary inside it breaks.
	var/message
	if(visits >= FAMILIAR_TASTE_CHERISHED_VISITS)
		drinker.add_stress(/datum/stress_event/cherished_taste)
		message = known ? "The taste of [donor.real_name]. I would know it anywhere." : "A taste I have grown fond of, though I cannot say whose it is."
	else
		drinker.add_stress(/datum/stress_event/familiar_taste)
		message = known ? "I know this taste. It is [donor.real_name]." : "I know this taste from somewhere..."
	to_chat(drinker, span_love(message))

/datum/stress_event/familiar_taste
	stress_change = -1
	desc = span_green("A familiar taste brought back fond memories.")
	timer = 10 MINUTES

/datum/stress_event/cherished_taste
	stress_change = -2
	desc = span_green("I tasted someone I cherish.")
	timer = 15 MINUTES

/obj/item/organ/genitals/filling_organ
	/// Flavour word mapped to fading points from what the owner ate lately.
	var/list/diet_points
	/// When diet_points last faded.
	var/diet_faded_at = 0

/// Food types mapped to the flavour they leave in body fluids, as list(foodtype flag, word) pairs.
/proc/get_fluid_diet_flavours()
	var/static/list/flavours = list(
		list(FRUIT, "fruity"),
		list(SUGAR, "sweet"),
		list(MEAT, "meaty"),
		list(DAIRY, "creamy"),
		list(VEGETABLES, "earthy"),
		list(GRAIN, "bready"),
		list(FRIED, "greasy"),
		list(RAW, "gamey"),
		list(ALCOHOL, "boozy"),
		list(PINEAPPLE, "tangy"),
		list(GROSS, "foul"),
		list(TOXIC, "foul"),
	)
	return flavours

/obj/item/organ/genitals/filling_organ/proc/on_owner_ate(datum/source, obj/item/reagent_containers/food/food)
	SIGNAL_HANDLER
	if(!istype(food))
		return
	fade_diet_points()
	for(var/list/pair as anything in get_fluid_diet_flavours())
		if(food.foodtype & pair[1])
			LAZYINITLIST(diet_points)
			diet_points[pair[2]] += 1

/obj/item/organ/genitals/filling_organ/proc/fade_diet_points()
	var/elapsed = world.time - diet_faded_at
	diet_faded_at = world.time
	if(!diet_points || elapsed <= 0)
		return
	var/factor = 0.5 ** (elapsed / FLUID_DIET_HALF_LIFE)
	for(var/word in diet_points)
		diet_points[word] *= factor
		if(diet_points[word] < FLUID_DIET_MIN_POINTS / 4)
			diet_points -= word
	if(!length(diet_points))
		diet_points = null

/// The strongest recent flavour, or null; strong drink in the blood makes it boozy.
/obj/item/organ/genitals/filling_organ/proc/get_diet_hint()
	fade_diet_points()
	var/best_word
	var/best_points = FLUID_DIET_MIN_POINTS
	for(var/word in diet_points)
		if(diet_points[word] >= best_points)
			best_points = diet_points[word]
			best_word = word
	var/booze_units = owner?.reagents?.get_reagent_amount(/datum/reagent/consumable/ethanol, FALSE)
	if(booze_units * FLUID_DIET_POINTS_PER_BOOZE_UNIT >= best_points)
		best_word = "boozy"
	return best_word

/// Stamps the main own fluid with its maker and meals each tick; mixed-in extras stay plain.
/obj/item/organ/genitals/filling_organ/proc/stamp_own_fluids()
	if(!owner || !reagents?.total_volume)
		return
	var/hint = get_diet_hint()
	for(var/reagent_type in get_main_fluid_types())
		var/datum/reagent/fluid = reagents.get_reagent(reagent_type)
		if(!fluid)
			continue
		fluid.stamp_fluid_donor(owner)
		fluid.set_diet_hint(hint)

#undef FLUID_DIET_HALF_LIFE
#undef FLUID_DIET_MIN_POINTS
#undef FLUID_DIET_POINTS_PER_BOOZE_UNIT
