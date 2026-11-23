/datum/reagent/consumable/sweat
	name = "Sweat"
	description = "Salty, musky, and still warm from the skin."
	color = "#d9cf9a"
	taste_description = "salt and musk"
	nutriment_factor = 0
	hydration_factor = 1
	can_synth = FALSE

/datum/reagent/consumable/sweat/get_fluid_donor()
	if(!islist(data) || data[FLUID_DATA_MIXED])
		return null
	var/datum/weakref/donor_ref = data[FLUID_DATA_DONOR]
	return donor_ref?.resolve()

/datum/reagent/consumable/sweat/on_merge(list/incoming_data, other_volume)
	var/datum/weakref/current_donor = islist(data) ? data[FLUID_DATA_DONOR] : null
	. = ..()
	if(!islist(incoming_data) || !islist(data))
		return
	var/datum/weakref/incoming_donor = incoming_data[FLUID_DATA_DONOR]
	if(current_donor && incoming_donor && current_donor != incoming_donor)
		data[FLUID_DATA_MIXED] = TRUE
		data -= FLUID_DATA_DONOR

/datum/reagent/consumable/sweat/note_fluid_taste(mob/living/drinker)
	if(!ishuman(drinker))
		return
	var/mob/living/carbon/human/taster = drinker
	if(taster.is_musk_susceptible())
		return ..()

/datum/reagent/note_fluid_taste(mob/living/drinker)
	. = ..()
	if(!ishuman(drinker))
		return
	var/mob/living/carbon/human/taster = drinker
	taster.savor_fluid_of(get_fluid_donor())

/mob/living/carbon/human/proc/is_drawn_to_fluid_of(mob/living/donor)
	return ishuman(donor) && donor != src && donor.get_musk() && get_scent_bond_limit()

/mob/living/carbon/human/proc/savor_fluid_of(mob/living/donor)
	if(!is_drawn_to_fluid_of(donor))
		return
	touch_musk(donor, MUSK_GAIN_DRINK)
	tell_once_per_contact(MUSK_LINE_TASTE, musk_drink_text(src, donor))

/mob/living/carbon/human/proc/sniff_fluid_of(mob/living/donor)
	if(!can_smell_musk() || !is_drawn_to_fluid_of(donor))
		return null
	touch_musk(donor, MUSK_GAIN_SNIFF)
	return span_love(musk_sniff_text(src, donor))

/obj/item/reagent_containers/examine(mob/user)
	. = ..()
	if(!ishuman(user) || user.zone_selected != BODY_ZONE_PRECISE_NOSE || get_dist(src, user) > 1 || !is_open_container())
		return
	var/mob/living/carbon/human/sniffer = user
	for(var/datum/reagent/fluid as anything in reagents.reagent_list)
		var/line = sniffer.sniff_fluid_of(fluid.get_fluid_donor())
		if(line)
			. += line

/mob/living/carbon/human/proc/slip_fluids_into_drink()
	set name = "Slip Fluids Into Drink"
	set category = "IC"
	set desc = "Let a little of myself into the vessel in my hand."

	try_slip_fluids()

/mob/living/carbon/human/proc/try_slip_fluids()
	var/obj/item/reagent_containers/drink = get_relief_container()
	if(!drink || stat != CONSCIOUS)
		to_chat(src, span_warning(musk_localized(src, "I need an open vessel with some room in it in my hand.", "Мне нужен в руке открытый сосуд, в котором ещё есть место.")))
		return FALSE
	var/list/fluids = get_slippable_fluids()
	if(!length(fluids))
		to_chat(src, span_warning(musk_localized(src, "I have nothing to give, or nothing within reach of my hand.", "Мне нечего отдать, или до этого не добраться рукой.")))
		return FALSE
	var/choice = tgui_input_list(src, musk_localized(src, "What do I let into [drink]?", "Что подлить? Сосуд в руке: [drink]."), musk_localized(src, "Slip Fluids", "Подлить себя"), fluids)
	if(!choice || drink != get_relief_container() || stat != CONSCIOUS)
		return FALSE
	if(!do_after(src, MUSK_SLIP_TIME, drink, hidden = TRUE) || drink != get_relief_container())
		return FALSE
	if(!slip_fluid(fluids[choice], drink))
		return FALSE
	log_game("SCENT BOND: [key_name(src)] slipped [fluids[choice]] into [drink] at [AREACOORD(src)].")
	to_chat(src, span_love(musk_localized(src, "A little of me goes into [drink].", "Частица меня остаётся в сосуде: [drink].")))
	if(m_intent != MOVE_INTENT_SNEAK && !rogue_sneaking)
		visible_message(span_notice("[src] lets something drip into [drink]."), ignored_mobs = list(src), vision_distance = MUSK_SLIP_SIGHT_RANGE)
	return TRUE

/mob/living/carbon/human/proc/get_slippable_fluids()
	. = list()
	if(get_musk_sweat()?.get_ripest_zone(get_bare_sweat_zones()))
		.[musk_localized(src, "Sweat", "Пот")] = MUSK_FLUID_SWEAT
	if(get_slippable_volume(ORGAN_SLOT_TESTICLES, BODY_ZONE_PRECISE_GROIN) >= MUSK_SLIP_MIN_AMOUNT)
		.[musk_localized(src, "Seed", "Семя")] = ORGAN_SLOT_TESTICLES
	if(get_slippable_volume(ORGAN_SLOT_VAGINA, BODY_ZONE_PRECISE_GROIN) >= MUSK_SLIP_MIN_AMOUNT)
		.[musk_localized(src, "Nectar", "Нектар")] = ORGAN_SLOT_VAGINA
	if(get_slippable_volume(ORGAN_SLOT_BREASTS, BODY_ZONE_CHEST) >= MUSK_SLIP_MIN_AMOUNT)
		.[musk_localized(src, "Milk", "Молоко")] = ORGAN_SLOT_BREASTS

/mob/living/carbon/human/proc/get_bare_sweat_zones()
	. = list()
	if(!get_sex_covering_garment(BODY_ZONE_CHEST, src))
		. += MUSK_ZONE_ARMPITS
	if(!get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, src))
		. += list(MUSK_ZONE_GROIN, MUSK_ZONE_BUTT)
	if(!shoes)
		. += MUSK_ZONE_FEET

/mob/living/carbon/human/proc/get_slippable_volume(organ_slot, body_zone)
	. = 0
	if(is_organ_slot_blocked(organ_slot) || get_sex_covering_garment(body_zone, src))
		return
	var/obj/item/organ/genitals/filling_organ/organ = getorganslot(organ_slot)
	for(var/fluid_type in organ?.get_main_fluid_types())
		. += organ.reagents?.get_reagent_amount(fluid_type)

/mob/living/carbon/human/proc/slip_fluid(fluid, obj/item/reagent_containers/drink)
	return fluid == MUSK_FLUID_SWEAT ? slip_sweat(drink) : slip_organ_fluid(fluid, drink)

/mob/living/carbon/human/proc/slip_sweat(obj/item/reagent_containers/drink)
	var/datum/musk_sweat/sweat = get_musk_sweat()
	if(!sweat?.spend(sweat.get_ripest_zone(get_bare_sweat_zones())))
		return FALSE
	return drink.reagents.add_reagent(/datum/reagent/consumable/sweat, MUSK_SLIP_AMOUNT, list(FLUID_DATA_DONOR = WEAKREF(src)))

/mob/living/carbon/human/proc/slip_organ_fluid(organ_slot, obj/item/reagent_containers/drink)
	. = 0
	var/obj/item/organ/genitals/filling_organ/organ = getorganslot(organ_slot)
	for(var/fluid_type in organ?.get_main_fluid_types())
		. += organ.reagents?.trans_id_to(drink, fluid_type, MUSK_SLIP_AMOUNT - .)
