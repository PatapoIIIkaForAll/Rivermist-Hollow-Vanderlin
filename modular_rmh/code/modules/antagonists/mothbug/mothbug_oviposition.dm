/datum/oviposition_egg_profile/mothbug
	egg_type = OVI_EGG_MOTHBUG
	display_name = "silken egg sac"
	display_desc = "A soft sac of pale silk with a single downy egg curled inside."
	display_icon_state = "egg_mothbug"
	display_marks_state = "egg_mothbug_marks"
	display_color = "#efe7d6"
	egg_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/honey = 1)
	aphrodisiac_chance = 30
	hatch_result_type = /obj/item/mothbug_egg/well_fed
	requires_fertilization = FALSE
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	incubation_stage_duration = MOTHBUG_HOST_EGG_STAGE
	birth_girth = 8
	stage_messages = list(
		"Something soft and feathery settles deep in my %CONTAINER%.",
		"The silken sac in my %CONTAINER% grows warm and downy.",
		"A light, fluttering fullness fills my %CONTAINER%.",
	)
	ready_message = "The silken sac in my %CONTAINER% is ready to be born."
	hatch_message = "%EGG% peels open, leaving a downy pale egg behind."

/obj/item/organ/genitals/penis/ovipositor/mothbug
	name = "silken ovipositor"
	desc = "A slender, downy ovipositor that lays eggs wrapped in silk."
	ovi_egg_type = OVI_EGG_MOTHBUG
	egg_storage_capacity = 1

/obj/item/organ/genitals/penis/ovipositor/mothbug/Insert(mob/living/M, special, drop_if_replaced, new_zone = null)
	if(!GetComponent(/datum/component/ovipositor))
		AddComponent(/datum/component/ovipositor/mothbug)
	return ..()

/// Mothbug eggs are paid for with silk at the moment of laying instead of growing over time.
/datum/component/ovipositor/mothbug

/datum/component/ovipositor/mothbug/Initialize()
	. = ..()
	eggs_stored = 0

/datum/component/ovipositor/mothbug/handle_life(seconds)
	return

/datum/component/ovipositor/mothbug/on_climax(datum/source, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	var/mob/living/simple_animal/mothbug/moth = carrier
	if(!istype(moth))
		return FALSE
	var/list/climax_context = get_climax_context(action)
	if(!climax_context)
		return FALSE
	var/obj/item/organ/receiver = climax_context["receiver"]
	var/mob/living/partner = receiver.owner
	if(partner != moth && !mothbug_target_allows(partner, /datum/erp_preference/boolean/antag_pregnancy))
		to_chat(moth, span_warning("[partner] will not carry my eggs."))
		return FALSE
	var/datum/team/mothbug_colony/colony = moth.get_mothbug_colony() || find_mothbug_colony(TRUE)
	if(!colony.has_room())
		to_chat(moth, span_warning("The colony is as large as this town can feed; no egg forms."))
		return FALSE
	if(!moth.has_silk_charge(MOTHBUG_COST_ERP_EGG))
		to_chat(moth, span_warning("I lack the silk to form an egg. ([round(moth.silk_charge)]/[MOTHBUG_COST_ERP_EGG])"))
		return FALSE
	var/obj/item/oviposition_egg/egg = create_egg()
	if(!try_place_egg_in_host(receiver, egg, climax_context["force"]))
		qdel(egg)
		to_chat(moth, span_warning("There is no room in [partner] for my egg."))
		return FALSE
	moth.spend_silk_charge(MOTHBUG_COST_ERP_EGG, FALSE)
	colony.track_host_egg(egg)
	to_chat(moth, span_notice("My egg takes hold. (-[MOTHBUG_COST_ERP_EGG] silk)"))
	return TRUE

/mob/living/simple_animal/mothbug/proc/grow_ovipositor()
	if(getorganslot(ORGAN_SLOT_PENIS))
		return
	var/obj/item/organ/genitals/penis/ovipositor/mothbug/ovipositor = new
	ovipositor.Insert(src, FALSE, FALSE)
