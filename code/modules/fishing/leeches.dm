#define MAX_LEECH_EVILNESS 10
#define LEECH_BEHAVIOR_INTERVAL (10 SECONDS)
#define LEECH_FEEDBACK_COOLDOWN (45 SECONDS)
#define LEECH_MIGRATION_TIME (10 SECONDS)
// Dosing has to outpace the reagent's own metabolization_rate over one behavior interval, or the
// host's level only ever falls. It must also stay clear of update_total()'s 0.05 deletion floor.
#define LEECH_APHRO_AMOUNT 0.6
#define LEECH_APHRO_CAP 4
#define LEECH_LACTATION_AMOUNT 0.5
#define LEECH_LACTATION_CAP 2
/// Headroom kept below a reagent's addiction or overdose threshold. Leeches top up, they don't hook.
#define LEECH_REAGENT_SAFETY_MARGIN 1
#define LEECH_EGG_INTERVAL (4 MINUTES)
#define LEECH_SEX_DRAIN_AMOUNT 10
#define LEECH_BLOOD_STOP_THRESHOLD (BLOOD_VOLUME_NORMAL * 0.5)

/proc/leech_body_storage_success(fit_result)
	return fit_result in list(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)

/proc/roll_wild_leech_type(atom/location)
	if(!ishuman(location))
		return /obj/item/natural/worms/leech
	var/mob/living/carbon/human/H = location
	if(!H.get_erp_pref(/datum/erp_preference/boolean/allow_horny_leeches))
		return /obj/item/natural/worms/leech
	return pickweight(list(
		/obj/item/natural/worms/leech/erotic/basic = 45,
		/obj/item/natural/worms/leech/erotic/aphrodisiac = 20,
		/obj/item/natural/worms/leech/erotic/milky = 15,
		/obj/item/natural/worms/leech/erotic/burrowing = 15,
		/obj/item/natural/worms/leech/erotic/condom = 5,
	))

/proc/spawn_wild_leech(atom/location)
	var/leech_type = roll_wild_leech_type(location)
	var/obj/item/natural/worms/leech/leech = new leech_type(location)
	if(ishuman(location))
		var/mob/living/carbon/human/H = location
		leech.prepare_source_attachment(H)
	return leech

/obj/item/natural/worms/leech
	name = "leech"
	desc = "A disgusting, blood-sucking parasite."
	icon = 'icons/roguetown/items/surgery.dmi'
	icon_state = "leech"
	baitpenalty = 0
	isbait = TRUE
	fishloot = list(
		/obj/item/reagent_containers/food/snacks/fish/carp = 5,
		/obj/item/reagent_containers/food/snacks/fish/eel = 5,
		/obj/item/reagent_containers/food/snacks/fish/angler = 1,
	)
	embedding = list(
		"embed_chance" = 100,
		"embedded_unsafe_removal_time" = 0,
		"embedded_unsafe_removal_pain_multiplier" = 0,
		"embedded_pain_chance" = 0,
		"embedded_fall_chance" = 0,
		"embedded_bloodloss" = 0,
		"embedded_ignore_throwspeed_threshold" = TRUE,
	)
	bundletype = null
	/// Consistent leeches skip randomized fishing lore.
	var/consistent = FALSE
	/// Are we giving or receiving blood?
	var/giving = FALSE
	/// How much stored blood and reagent volume wastes away on process().
	var/drainage = 0
	/// How much blood we suck on on_embed_life().
	var/blood_sucking = 2
	/// How much toxin damage we heal on on_embed_life().
	var/toxin_healing = 1.5
	/// Amount of blood we have stored.
	var/blood_storage = 0
	/// Maximum amount of blood we can store.
	var/blood_maximum = BLOOD_VOLUME_SURVIVE
	/// Completely silent, no do_after and no visible_message.
	var/completely_silent = FALSE
	/// Generic reagent capacity, used by erotic variants and by squeezing into reagent containers.
	var/max_storage = 50
	bstorage_visible_layer = STORAGE_LAYER_OUTER
	has_body_storage_overlay = TRUE
	storage_overlay_icon = 'modular_rmh/icons/obj/lewd/leeches_overlay.dmi'

/obj/item/natural/worms/leech/Initialize()
	. = ..()
	apply_leech_lore()
	create_reagents(max_storage)
	if(drainage)
		START_PROCESSING(SSobj, src)

/obj/item/natural/worms/leech/process()
	if(!drainage)
		return PROCESS_KILL
	blood_storage = max(blood_storage - drainage, 0)
	reagents?.remove_any(amount = drainage)

/obj/item/natural/worms/leech/examine(mob/user)
	. = ..()
	if(reagents?.total_volume)
		var/fluid_ratio = reagents.total_volume / max(1, reagents.maximum_volume)
		switch(fluid_ratio)
			if(0.8 to INFINITY)
				. += "<span class='love'><B>[p_theyre(TRUE)] fat and engorged with fluids.</B></span>"
			if(0.5 to 0.8)
				. += "<span class='love'>[p_theyre(TRUE)] well-fed.</span>"
			if(0.1 to 0.5)
				. += "<span class='love'>[p_they(TRUE)] want[p_s()] a meal.</span>"
			if(-INFINITY to 0.1)
				. += "<span class='love'>[p_theyre(TRUE)] starved.</span>"
	else
		switch(blood_storage / max(1, blood_maximum))
			if(0.8 to INFINITY)
				. += "<span class='bloody'><B>[p_theyre(TRUE)] fat and engorged with blood.</B></span>"
			if(0.5 to 0.8)
				. += "<span class='bloody'>[p_theyre(TRUE)] well-fed.</span>"
			if(0.1 to 0.5)
				. += "<span class='warning'>[p_they(TRUE)] want[p_s()] a meal.</span>"
			if(-INFINITY to 0.1)
				. += "<span class='dead'>[p_theyre(TRUE)] starved.</span>"
		if(!giving)
			. += "<span class='warning'>[p_theyre(TRUE)] [pick("slurping", "sucking", "inhaling")].</span>"
		else
			. += "<span class='notice'>[p_theyre(TRUE)] [pick("vomiting", "gorfing", "exhaling")].</span>"

/obj/item/natural/worms/leech/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with))
		return ..()

	var/mob/living/carbon/human/H = interacting_with

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(!affecting)
		return ITEM_INTERACT_BLOCKING

	if(!get_location_accessible(H, check_zone(user.zone_selected)))
		to_chat(user, "<span class='warning'>Something in the way.</span>") //ooooooooooooooo
		return ITEM_INTERACT_BLOCKING

	var/used_time
	if(completely_silent)
		used_time = 0
	else
		used_time = (7 SECONDS - (GET_MOB_SKILL_VALUE_OLD(H, /datum/attribute/skill/misc/medicine) * 1 SECONDS)) / 2

	if(!do_after(user, used_time, H))
		return ITEM_INTERACT_BLOCKING
	if(QDELETED(H) || QDELETED(affecting))
		return ITEM_INTERACT_BLOCKING

	user.dropItemToGround(src)

	forceMove(H)

	affecting.add_embedded_object(src, silent = TRUE, crit_message = FALSE)

	if(!completely_silent)
		if(H == user)
			user.visible_message("<span class='notice'>[user] places [src] on [user.p_their()] [affecting].</span>", "<span class='notice'>I place a leech on my [affecting].</span>")
		else
			user.visible_message("<span class='notice'>[user] places [src] on [H]'s [affecting].</span>", "<span class='notice'>I place a leech on [H]'s [affecting].</span>")

	return ITEM_INTERACT_SUCCESS

/obj/item/natural/worms/leech/on_embed_life(mob/living/user, obj/item/bodypart/bodypart)
	if(!user)
		return FALSE
	if(giving)
		var/blood_given = min(BLOOD_VOLUME_NORMAL - user.blood_volume, blood_storage, blood_sucking)
		user.adjust_bloodvolume(blood_given)
		blood_storage = max(blood_storage - blood_given, 0)
		if((blood_storage <= 0) || (user.blood_volume >= BLOOD_VOLUME_MAXIMUM))
			if(bodypart)
				bodypart.remove_embedded_object(src)
			else
				user.simple_remove_embedded_object(src)
			return TRUE
	else
		if(user.blood_volume <= LEECH_BLOOD_STOP_THRESHOLD || user.is_bloodless())
			if(bodypart)
				bodypart.remove_embedded_object(src)
			else
				user.simple_remove_embedded_object(src)
			return TRUE
		var/modifier = bodypart?.get_incision() ? 1.5 : 1
		user.adjustToxLoss(-1 * toxin_healing * modifier)
		var/blood_extracted = min(blood_maximum - blood_storage, user.blood_volume - LEECH_BLOOD_STOP_THRESHOLD, blood_sucking * modifier)
		if(HAS_TRAIT(user, TRAIT_LEECHIMMUNE))
			blood_extracted *= 0.05
		user.adjust_bloodvolume(-blood_extracted)
		blood_storage += blood_extracted
		if((blood_storage >= blood_maximum) || (user.blood_volume <= LEECH_BLOOD_STOP_THRESHOLD))
			if(bodypart)
				bodypart.remove_embedded_object(src)
			else
				user.simple_remove_embedded_object(src)
			return TRUE
	return FALSE

/obj/item/natural/worms/leech/pre_attack(atom/target, mob/living/user, list/modifiers)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK) && try_squeeze_into_container(target, user))
		return TRUE
	return ..()

/obj/item/natural/worms/leech/proc/try_squeeze_into_container(atom/target, mob/living/user)
	if(!istype(target, /obj/item/reagent_containers))
		return FALSE
	var/obj/item/reagent_containers/container = target
	if(!container.reagents || !container.is_open_container())
		to_chat(user, span_warning("\The [container] needs to be open before I can squeeze anything into it."))
		return TRUE
	if(!reagents?.total_volume)
		to_chat(user, span_warning("\The [src] has no stored fluids to squeeze out."))
		return TRUE
	if(container.reagents.total_volume >= container.reagents.maximum_volume)
		to_chat(user, span_warning("\The [container] is full."))
		return TRUE
	var/transferred = reagents.trans_to(container.reagents, 5, transfered_by = user)
	if(transferred <= 0)
		to_chat(user, span_warning("Nothing will fit into \the [container]."))
		return TRUE
	user.visible_message("<span class='notice'>[user] squeezes some liquid out of [src] into [container].</span>", "<span class='notice'>I squeeze some liquid out of [src] into [container].</span>")
	return TRUE

/obj/item/natural/worms/leech/proc/prepare_source_attachment(mob/living/carbon/human/H)
	return FALSE

/obj/item/natural/worms/leech/proc/horny_leech_unattach(mob/living/user, obj/item/organ/organ, storage_layer, atom/drop_location_override)
	if(istype(src, /obj/item/natural/worms/leech/erotic))
		var/obj/item/natural/worms/leech/erotic/erotic_leech = src
		erotic_leech.erotic_unattach(user, null, drop_location_override)
		return
	var/result = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_REMOVE, src, storage_layer, BODYSTORAGE_REMOVE_INTERNAL)
	if(!result)
		qdel(src)
		return
	var/drop_location = drop_location_override || user?.drop_location() || get_turf(src)
	if(drop_location)
		forceMove(drop_location)
	else
		qdel(src)

/obj/item/natural/worms/leech/proc/get_attached_organ(mob/living/carbon/human/H)
	if(!H)
		return null
	if(istype(loc, /obj/item/organ))
		var/obj/item/organ/current_organ = loc
		if(current_organ.owner == H)
			return current_organ
	for(var/obj/item/organ/organ as anything in H.internal_organs)
		if(src in organ.contents)
			return organ
	return null

/obj/item/natural/worms/leech/proc/pull_off_host(mob/living/remover, mob/living/carbon/human/host, obj/item/bodypart/bodypart, obj/item/organ/known_organ)
	if(!remover || !host)
		return FALSE
	var/location_name
	if(bodypart && (src in bodypart.embedded_objects))
		if(!bodypart.remove_embedded_object(src))
			return FALSE
		location_name = bodypart.name
	else
		var/obj/item/organ/organ = known_organ || get_attached_organ(host)
		if(!organ)
			return FALSE
		var/storage_layer = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, src)
		if(!storage_layer)
			return FALSE
		location_name = organ.name
		horny_leech_unattach(host, organ, storage_layer, remover.drop_location() || host.drop_location() || get_turf(host))
	if(QDELETED(src) || QDELING(src))
		return FALSE
	remover.put_in_hands(src)
	if(remover == host)
		remover.visible_message(span_notice("[remover] pulls [src] off [remover.p_their()] [location_name]."), span_notice("I pull [src] off my [location_name]."))
	else
		remover.visible_message(span_notice("[remover] pulls [src] off [host]'s [location_name]."), span_notice("I pull [src] off [host]'s [location_name]."))
	return TRUE

/mob/living/carbon/human/proc/get_grabbable_leech_for_zone(zone)
	var/list/organ_slots
	switch(zone)
		if(BODY_ZONE_CHEST)
			organ_slots = list(ORGAN_SLOT_LEFT_NIP, ORGAN_SLOT_RIGHT_NIP)
		if(BODY_ZONE_PRECISE_GROIN)
			organ_slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
		else
			return null
	for(var/organ_slot in organ_slots)
		var/obj/item/organ/organ = getorganslot(organ_slot)
		if(!organ)
			continue
		for(var/obj/item/natural/worms/leech/leech in organ.contents)
			if(SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, leech))
				return leech
	return null

/// LEECH LORE... Collect em all!
/obj/item/natural/worms/leech/proc/apply_leech_lore()
	if(consistent)
		return FALSE
	var/static/list/all_colors = list(
		"#8471a7" = 8,
		"#94ad6a" = 4,
		"#af995e" = 2,
		"#83a7b3" = 2,
		"#b88383" = 1,
		"#bc69b1" = 1,
	)
	var/static/list/all_adjectives = list(
		"blood-sucking" = 20,
		"disgusting" = 10,
		"vile" = 8,
		"repugnant" = 4,
		"revolting" = 4,
		"grotesque" = 4,
		"hideous" = 4,
		"stupid" = 2,
		"dumb" = 2,
		"demonic" = 1,
	)
	var/static/list/all_descs = list(
		"What a disgusting creature." = 10,
		"Fucking gross." = 5,
		"Slippery..." = 3,
		"So yummy and full of blood." = 3,
		"I love this leech!" = 2,
		"It is so beautiful." = 2,
		"I wish I was a leech." = 1,
	)
	var/list/possible_adjectives = all_adjectives.Copy()
	var/list/possible_descs = all_descs.Copy()
	var/list/adjectives = list()
	var/list/descs = list()
	var/evilness_rating = rand(1, MAX_LEECH_EVILNESS)
	switch(evilness_rating)
		if(MAX_LEECH_EVILNESS to INFINITY)
			color = "#dc4b4b"
			adjectives += pick("evil", "malevolent", "misanthropic")
			descs += "<span class='danger'>This one is bursting with hatred!</span>"
		if(5)
			if(prob(3))
				adjectives += pick("average", "ordinary", "boring")
				descs += "This one is extremely boring to look at."
		if(1 to 4)
			adjectives += pick("pitiful", "pathetic", "depressing")
			descs += "<span class='dead'>This one yearns for nothing but death.</span>"
		else
			var/adjective_amount = 1
			if(prob(5))
				adjective_amount = 3
			else if(prob(30))
				adjective_amount = 2
			for(var/i in 1 to adjective_amount)
				var/picked_adjective = pickweight(possible_adjectives)
				possible_adjectives -= picked_adjective
				adjectives += picked_adjective
				var/picked_desc = pickweight(possible_descs)
				possible_descs -= picked_desc
				descs += picked_desc
	toxin_healing = min(round((MAX_LEECH_EVILNESS - evilness_rating) / MAX_LEECH_EVILNESS * 2 * initial(toxin_healing), 0.1), 1)
	blood_sucking = max(round(evilness_rating / MAX_LEECH_EVILNESS * 2 * initial(blood_sucking), 0.1), 1)
	if(evilness_rating < MAX_LEECH_EVILNESS)
		color = pickweight(all_colors)
	if(length(adjectives))
		name = "[english_list(adjectives)] [name]"
	if(length(descs))
		desc = "[desc] [jointext(descs, " ")]"
	return TRUE

/obj/item/natural/worms/leech/wild/Initialize()
	. = ..()
	spawn_wild_leech(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/natural/worms/leech/parasite
	name = "the parasite"
	desc = "A foul, wriggling creecher. Known to suck whole villages of their blood, these rare freeks have been domesticated for medical purposes."
	icon_state = "parasite"
	dropshrink = 0.9
	baitpenalty = 0
	isbait = TRUE
	color = null
	consistent = TRUE
	drainage = 0
	blood_sucking = 5
	toxin_healing = 3
	blood_storage = BLOOD_VOLUME_SURVIVE
	blood_maximum = BLOOD_VOLUME_BAD

/obj/item/natural/worms/leech/parasite/attack_self(mob/user, list/modifiers)
	. = ..()
	giving = !giving
	if(giving)
		user.visible_message("<span class='notice'>[user] squeezes [src].</span>", "<span class='notice'>I squeeze [src]. It will now infuse blood.</span>")
	else
		user.visible_message("<span class='notice'>[user] squeezes [src].</span>", "<span class='notice'>I squeeze [src]. It will now extract blood.</span>")

/obj/item/natural/worms/leech/propaganda
	name = "accursed leech"
	desc = "A leech like none other."
	icon_state = "leech"
	drainage = 0
	blood_sucking = 0
	completely_silent = TRUE
	consistent = TRUE
	embedding = list(
		"embed_chance" = 100,
		"embedded_unsafe_removal_time" = 0,
		"embedded_unsafe_removal_pain_multiplier" = 0,
		"embedded_pain_chance" = 0,
		"embedded_fall_chance" = 0,
		"embedded_bloodloss" = 0,
	)

/obj/item/natural/worms/leech/erotic
	name = "love leech"
	desc = "A slick little leech drawn to intimate warmth."
	color = "#b86f86"
	consistent = TRUE
	drainage = 0
	blood_sucking = 2
	toxin_healing = 0
	max_storage = 500
	var/list/valid_organ_slots = list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS, ORGAN_SLOT_LEFT_NIP, ORGAN_SLOT_RIGHT_NIP)
	var/behavior_interval = LEECH_BEHAVIOR_INTERVAL
	var/fluid_sucking = 5
	var/next_behavior_time = 0
	var/next_feedback_time = 0
	var/obj/item/organ/target_organ
	var/trying_to_attach = FALSE
	var/source_migrates_to_erotic = FALSE

/obj/item/natural/worms/leech/erotic/Initialize()
	. = ..()
	if(reagents)
		reagents.maximum_volume = max_storage

/obj/item/natural/worms/leech/erotic/process()
	if(!istype(loc, /obj/item/organ))
		target_organ = null
		return PROCESS_KILL
	if(world.time < next_behavior_time)
		return
	next_behavior_time = world.time + behavior_interval
	target_organ = loc
	var/mob/living/carbon/human/H = target_organ.owner
	if(!can_attach_to_organ(H, target_organ))
		erotic_unattach(H, span_notice("[src] loses its grip and falls away."))
		return PROCESS_KILL
	do_behavior_tick(H, target_organ)

/obj/item/natural/worms/leech/erotic/attack(mob/living/M, mob/user, list/modifiers)
	if(!ishuman(M))
		to_chat(user, span_warning("[src] curls away, unable to find a suitable host."))
		return
	var/mob/living/carbon/human/H = M
	if(!is_erotic_organ_zone(user.zone_selected))
		attach_to_bodypart_for_blood(H, user)
		return
	if(!target_allows_pref(H, /datum/erp_preference/boolean/allow_horny_leeches))
		to_chat(user, span_notice("[src] slips away without latching on."))
		return
	if(!get_location_accessible(H, check_zone(user.zone_selected)))
		to_chat(user, "<span class='warning'>Something in the way.</span>")
		return
	var/obj/item/organ/selected_organ = prompt_for_target_organ(H, user)
	if(!selected_organ)
		return
	if(!can_attach_to_organ(H, selected_organ))
		to_chat(user, span_notice("[src] cannot latch there."))
		return
	if(!do_after(user, 0, H))
		return
	user.dropItemToGround(src)
	if(attach_to_organ(H, selected_organ, STORAGE_LAYER_OUTER, TRUE))
		if(M == user)
			user.visible_message("<span class='notice'>[user] places [src] on [user.p_their()] [selected_organ.name].</span>", "<span class='notice'>I place [src] on my [selected_organ.name].</span>")
		else
			user.visible_message("<span class='notice'>[user] places [src] on [M]'s [selected_organ.name].</span>", "<span class='notice'>I place [src] on [M]'s [selected_organ.name].</span>")
	else
		target_organ = null
		to_chat(user, "<span class='notice'>There's already something in the desired location.</span>")

/obj/item/natural/worms/leech/erotic/on_embed_life(mob/living/user, obj/item/bodypart/bodypart)
	if(!ishuman(user))
		bodypart?.remove_embedded_object(src)
		return TRUE
	if(!should_try_erotic_migration_from_bodypart(bodypart))
		return ..()
	if(trying_to_attach)
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!target_allows_pref(H, /datum/erp_preference/boolean/allow_horny_leeches))
		bodypart?.remove_embedded_object(src)
		feedback(H, span_notice("[src] falls off before it can latch onto anything intimate."), TRUE)
		return TRUE
	var/list/available_organs = get_available_attach_organs(H)
	if(!length(available_organs))
		bodypart?.remove_embedded_object(src)
		feedback(H, span_notice("[src] cannot find a place to latch and drops away."), TRUE)
		return TRUE
	target_organ = pick(available_organs)
	trying_to_attach = TRUE
	feedback(H, span_info("Something slimy on my [bodypart?.name || "skin"] starts crawling toward my [target_organ.name]."), TRUE)
	addtimer(CALLBACK(src, PROC_REF(migrate_to_erotic_slot), target_organ, STORAGE_LAYER_OUTER, bodypart), LEECH_MIGRATION_TIME)
	return TRUE

/obj/item/natural/worms/leech/erotic/prepare_source_attachment(mob/living/carbon/human/H)
	if(!target_allows_pref(H, /datum/erp_preference/boolean/allow_horny_leeches))
		return FALSE
	source_migrates_to_erotic = TRUE
	return TRUE

/obj/item/natural/worms/leech/erotic/proc/is_erotic_organ_zone(zone)
	return zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)

/obj/item/natural/worms/leech/erotic/proc/should_try_erotic_migration_from_bodypart(obj/item/bodypart/bodypart)
	return source_migrates_to_erotic || (bodypart?.body_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN))

/obj/item/natural/worms/leech/erotic/proc/attach_to_bodypart_for_blood(mob/living/carbon/human/H, mob/user)
	if(!H || !user)
		return FALSE
	var/target_zone = check_zone(user.zone_selected)
	var/obj/item/bodypart/affecting = H.get_bodypart(target_zone)
	if(!affecting)
		return FALSE
	if(!get_location_accessible(H, target_zone))
		to_chat(user, span_warning("Something in the way."))
		return FALSE
	if(!do_after(user, 0, H))
		return FALSE

	user.dropItemToGround(src)
	forceMove(H)
	affecting.add_embedded_object(src, silent = TRUE, crit_message = FALSE)
	target_organ = null
	trying_to_attach = FALSE
	source_migrates_to_erotic = FALSE
	if(H == user)
		user.visible_message(span_notice("[user] places [src] on [user.p_their()] [affecting.name]."), span_notice("I place [src] on my [affecting.name]."))
	else
		user.visible_message(span_notice("[user] places [src] on [H]'s [affecting.name]."), span_notice("I place [src] on [H]'s [affecting.name]."))
	return TRUE

/obj/item/natural/worms/leech/erotic/proc/target_allows_pref(mob/living/carbon/human/H, pref_type)
	if(!H || !pref_type)
		return FALSE
	if(!H.client && !H.mind?.key && !H.mind?.cached_erp_preferences && !H.cached_erp_preferences)
		return TRUE
	return H.get_erp_pref(pref_type)

/obj/item/natural/worms/leech/erotic/proc/can_attach_to_organ(mob/living/carbon/human/H, obj/item/organ/organ)
	if(!H || !organ || organ.owner != H)
		return FALSE
	if(!target_allows_pref(H, /datum/erp_preference/boolean/allow_horny_leeches))
		return FALSE
	if(!(organ.slot in valid_organ_slots))
		return FALSE
	if(!organ.GetComponent(/datum/component/body_storage))
		return FALSE
	if(H.is_organ_slot_blocked(organ.slot))
		return FALSE
	return TRUE

/obj/item/natural/worms/leech/erotic/proc/get_available_attach_organs(mob/living/carbon/human/H)
	var/list/available_organs = list()
	for(var/slot in valid_organ_slots)
		var/obj/item/organ/organ = H.getorganslot(slot)
		if(!can_attach_to_organ(H, organ))
			continue
		if(SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_SELECT_RAND_ITEM, STORAGE_LAYER_OUTER))
			continue
		available_organs += organ
	return available_organs

/obj/item/natural/worms/leech/erotic/proc/prompt_for_target_organ(mob/living/carbon/human/H, mob/user)
	var/list/options = list()
	var/list/option_to_organ = list()
	if(user.zone_selected == BODY_ZONE_CHEST)
		add_organ_option(H, options, option_to_organ, ORGAN_SLOT_LEFT_NIP, "Left nipple")
		add_organ_option(H, options, option_to_organ, ORGAN_SLOT_RIGHT_NIP, "Right nipple")
	else if(user.zone_selected == BODY_ZONE_PRECISE_GROIN)
		add_organ_option(H, options, option_to_organ, ORGAN_SLOT_PENIS, "Penis")
		add_organ_option(H, options, option_to_organ, ORGAN_SLOT_VAGINA, "Vagina")
		add_organ_option(H, options, option_to_organ, ORGAN_SLOT_ANUS, "Anus")
	if(!length(options))
		to_chat(user, span_notice("This spot will not offer much to [src]."))
		return null
	var/choice = browser_input_list(user, "Select the organ to which you will attach [src].", "Leech", options)
	return option_to_organ[choice]

/obj/item/natural/worms/leech/erotic/proc/add_organ_option(mob/living/carbon/human/H, list/options, list/option_to_organ, organ_slot, label)
	var/obj/item/organ/organ = H.getorganslot(organ_slot)
	if(!can_attach_to_organ(H, organ))
		return
	options += label
	option_to_organ[label] = organ

/obj/item/natural/worms/leech/erotic/proc/attach_to_organ(mob/living/carbon/human/H, obj/item/organ/organ, storage_layer, silent = FALSE)
	if(!can_attach_to_organ(H, organ))
		return FALSE
	storage_icon_state = organ.slot
	var/fit_result = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_INSERT, src, storage_layer)
	if(!leech_body_storage_success(fit_result))
		return FALSE
	target_organ = organ
	next_behavior_time = world.time + behavior_interval
	START_PROCESSING(SSobj, src)
	if(!silent)
		feedback(H, span_love("[src] latches onto my [organ.name]."), TRUE)
	return TRUE

/obj/item/natural/worms/leech/erotic/proc/migrate_to_erotic_slot(obj/item/organ/organ, storage_layer, obj/item/bodypart/bodypart)
	if(QDELETED(src))
		return
	trying_to_attach = FALSE
	if(loc != bodypart || !organ)
		target_organ = null
		return
	var/mob/living/carbon/human/H = organ.owner
	if(!can_attach_to_organ(H, organ))
		bodypart?.remove_embedded_object(src)
		target_organ = null
		feedback(H, span_notice("[src] loses its way and drops away."), TRUE)
		return
	bodypart?.remove_embedded_object(src)
	if(!attach_to_organ(H, organ, storage_layer))
		feedback(H, span_notice("[src] cannot find purchase and falls off."), TRUE)
		target_organ = null

/obj/item/natural/worms/leech/erotic/proc/erotic_unattach(mob/living/carbon/human/H, message, atom/drop_location_override)
	var/obj/item/organ/organ = target_organ
	if(!organ && istype(loc, /obj/item/organ))
		organ = loc
	var/storage_layer = organ ? SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, src) : null
	if(organ && storage_layer)
		SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_REMOVE, src, storage_layer, BODYSTORAGE_REMOVE_INTERNAL)
	target_organ = null
	if(message && H)
		feedback(H, message, TRUE)
	var/drop_location = drop_location_override || H?.drop_location() || get_turf(src)
	if(drop_location)
		forceMove(drop_location)
	else
		qdel(src)

/obj/item/natural/worms/leech/erotic/proc/current_storage_layer()
	if(!target_organ)
		return null
	return SEND_SIGNAL(target_organ, COMSIG_BODYSTORAGE_FIND_ITEM_LAYER, src)

/// The highest level a leech may push a host to: our own cap, held under whatever addiction or
/// overdose threshold the reagent declares. Zero means the reagent is unsafe to dose at all.
/obj/item/natural/worms/leech/erotic/proc/get_safe_reagent_cap(reagent_type, leech_cap)
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
	if(!reagent)
		return 0

	var/safe_cap = leech_cap
	if(reagent.addiction_threshold > 0)
		safe_cap = min(safe_cap, reagent.addiction_threshold - LEECH_REAGENT_SAFETY_MARGIN)
	if(reagent.overdose_threshold > 0)
		safe_cap = min(safe_cap, reagent.overdose_threshold - LEECH_REAGENT_SAFETY_MARGIN)
	return max(0, safe_cap)

/// Tops the host up toward the safe cap. Reads the total level, so a dose from any other source
/// counts against us rather than stacking on top of it.
/obj/item/natural/worms/leech/erotic/proc/top_up_reagent(mob/living/carbon/human/H, reagent_type, amount, leech_cap)
	if(!H?.reagents)
		return FALSE

	var/safe_cap = get_safe_reagent_cap(reagent_type, leech_cap)
	if(safe_cap <= 0)
		return FALSE

	var/current_amount = H.reagents.get_reagent_amount(reagent_type)
	if(current_amount >= safe_cap)
		return FALSE
	return H.reagents.add_reagent(reagent_type, min(amount, safe_cap - current_amount))

/obj/item/natural/worms/leech/erotic/proc/do_behavior_tick(mob/living/carbon/human/H, obj/item/organ/organ)
	stimulate_owner(H)
	drain_attached_fluids(H, organ)
	if(is_full())
		erotic_unattach(H, span_info("The sated [src] falls off my [organ.name]."))
		return
	if(prob(25))
		H.adjust_jitter(2 SECONDS)
		feedback(H, span_warning(pick(
			"[src] pulses softly against my [organ.name].",
			"I feel [src] drink from my [organ.name].",
			"Something slick tugs gently at my [organ.name].",
		)))

/obj/item/natural/worms/leech/erotic/proc/stimulate_owner(mob/living/carbon/human/H)
	SEND_SIGNAL(H, COMSIG_SEX_GENERIC_ACTION, H, rand(2, 4), 0, rand(1, 3), src)

/obj/item/natural/worms/leech/erotic/proc/drain_attached_fluids(mob/living/carbon/human/H, obj/item/organ/organ)
	var/datum/reagents/source_reagents = get_fluid_source(H, organ)
	return drain_reagents_into_self(source_reagents, fluid_sucking)

/obj/item/natural/worms/leech/erotic/proc/get_fluid_source(mob/living/carbon/human/H, obj/item/organ/organ)
	if(!H || !organ)
		return null
	switch(organ.slot)
		if(ORGAN_SLOT_PENIS)
			var/obj/item/organ/genitals/filling_organ/testicles/testicles = H.getorganslot(ORGAN_SLOT_TESTICLES)
			return testicles?.reagents
		if(ORGAN_SLOT_LEFT_NIP, ORGAN_SLOT_RIGHT_NIP)
			var/obj/item/organ/genitals/filling_organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
			return breasts?.reagents
		if(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
			var/obj/item/organ/genitals/filling_organ/filling_organ = organ
			return filling_organ?.reagents
	return null

/obj/item/natural/worms/leech/erotic/proc/drain_reagents_into_self(datum/reagents/source_reagents, amount)
	if(!source_reagents || !reagents || amount <= 0)
		return 0
	var/space = reagents.maximum_volume - reagents.total_volume
	if(space <= 0)
		return 0
	var/amount_to_take = min(space, source_reagents.total_volume, amount)
	if(amount_to_take <= 0)
		return 0
	source_reagents.trans_to(reagents, amount_to_take)
	return amount_to_take

/obj/item/natural/worms/leech/erotic/proc/is_full()
	return reagents && reagents.total_volume >= reagents.maximum_volume

/obj/item/natural/worms/leech/erotic/proc/feedback(mob/living/carbon/human/H, message, important = FALSE)
	if(!H || !message)
		return FALSE
	if(!important && world.time < next_feedback_time)
		return FALSE
	if(!important)
		next_feedback_time = world.time + LEECH_FEEDBACK_COOLDOWN
	to_chat(H, message)
	return TRUE

/obj/item/natural/worms/leech/erotic/proc/on_hatched_inside_host(obj/item/organ/organ, mob/living/carbon/human/H, storage_layer)
	target_organ = organ
	storage_icon_state = organ?.slot
	next_behavior_time = world.time + behavior_interval
	START_PROCESSING(SSobj, src)
	feedback(H, span_warning("Something tiny and slick hatches inside my [organ?.name || "body"]."), TRUE)

/obj/item/natural/worms/leech/erotic/basic
	name = "rose leech"
	desc = "A muted rose leech that latches onto intimate flesh and drinks what it can."
	color = "#b86f86"

/obj/item/natural/worms/leech/erotic/aphrodisiac
	name = "aphrodisiac leech"
	desc = "A hot magenta leech with a faintly sweet chemical sheen."
	color = "#ff3fb4"

/obj/item/natural/worms/leech/erotic/aphrodisiac/do_behavior_tick(mob/living/carbon/human/H, obj/item/organ/organ)
	top_up_reagent(H, /datum/reagent/consumable/aphrodisiac, LEECH_APHRO_AMOUNT, LEECH_APHRO_CAP)
	return ..()

/obj/item/natural/worms/leech/erotic/milky
	name = "milky leech"
	desc = "A cream-white leech that seeks nipples and coaxes milk to flow."
	color = "#fff0d5"
	valid_organ_slots = list(ORGAN_SLOT_LEFT_NIP, ORGAN_SLOT_RIGHT_NIP)

/obj/item/natural/worms/leech/erotic/milky/can_attach_to_organ(mob/living/carbon/human/H, obj/item/organ/organ)
	if(!..())
		return FALSE
	if(!target_allows_pref(H, /datum/erp_preference/boolean/allow_forced_lactation))
		return FALSE
	return !!H.getorganslot(ORGAN_SLOT_BREASTS)

/obj/item/natural/worms/leech/erotic/milky/do_behavior_tick(mob/living/carbon/human/H, obj/item/organ/organ)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts || !target_allows_pref(H, /datum/erp_preference/boolean/allow_forced_lactation))
		erotic_unattach(H, span_notice("[src] slips off, unable to draw milk."))
		return
	top_up_reagent(H, /datum/reagent/consumable/lactation_inducer, LEECH_LACTATION_AMOUNT, LEECH_LACTATION_CAP)
	stimulate_owner(H)
	drain_reagents_into_self(breasts.reagents, fluid_sucking)
	if(is_full())
		erotic_unattach(H, span_info("The milk-heavy [src] drops away from my [organ.name]."))
		return
	if(prob(25))
		feedback(H, span_warning("[src] kneads softly at my [organ.name], drawing milk into itself."))

/obj/item/natural/worms/leech/erotic/burrowing
	name = "burrowing leech"
	desc = "A dark violet leech that pushes deeper once it finds a soft opening."
	color = "#4b236c"
	valid_organ_slots = list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS)
	var/next_egg_time = 0

/obj/item/natural/worms/leech/erotic/burrowing/do_behavior_tick(mob/living/carbon/human/H, obj/item/organ/organ)
	var/storage_layer = current_storage_layer()
	if(storage_layer == STORAGE_LAYER_OUTER)
		if(prob(65) && try_move_deeper(H, organ, storage_layer))
			feedback(H, span_warning("[src] pushes itself deeper into my [organ.name]."), TRUE)
		else
			feedback(H, span_warning("[src] squirms insistently against my [organ.name]."))
		return
	stimulate_owner(H)
	drain_attached_fluids(H, organ)
	if((storage_layer == STORAGE_LAYER_INNER || storage_layer == STORAGE_LAYER_DEEP) && world.time >= next_egg_time)
		if(try_lay_leech_egg(H, organ))
			next_egg_time = world.time + LEECH_EGG_INTERVAL
		else
			next_egg_time = world.time + 30 SECONDS
	if(is_full())
		feedback(H, span_warning("[src] settles deep inside my [organ.name], too content to come out on its own."))

/obj/item/natural/worms/leech/erotic/burrowing/proc/try_move_deeper(mob/living/carbon/human/H, obj/item/organ/organ, storage_layer)
	var/new_storage_layer
	if(storage_layer == STORAGE_LAYER_OUTER)
		new_storage_layer = STORAGE_LAYER_INNER
	else if(storage_layer == STORAGE_LAYER_INNER)
		new_storage_layer = STORAGE_LAYER_DEEP
	else
		return FALSE
	var/fit_result = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_CHECK_FIT, src, new_storage_layer, TRUE)
	if(!leech_body_storage_success(fit_result))
		return FALSE
	if(!SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_REMOVE, src, storage_layer, BODYSTORAGE_REMOVE_INTERNAL))
		return FALSE
	fit_result = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_INSERT, src, new_storage_layer, TRUE)
	if(!leech_body_storage_success(fit_result))
		SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_INSERT, src, storage_layer, TRUE)
		return FALSE
	return TRUE

/obj/item/natural/worms/leech/erotic/burrowing/proc/can_lay_leech_egg(mob/living/carbon/human/H, obj/item/organ/organ)
	if(!H || !organ || organ.owner != H)
		return FALSE
	if(!target_allows_pref(H, /datum/erp_preference/boolean/allow_mob_breeding))
		return FALSE
	if(!target_allows_pref(H, /datum/erp_preference/boolean/allow_mob_oviposition))
		return FALSE
	if(!organ.supports_oviposition_pregnancy())
		return FALSE
	if(!H.can_receive_oviposition_implant(TRUE))
		return FALSE
	return TRUE

/obj/item/natural/worms/leech/erotic/burrowing/proc/try_lay_leech_egg(mob/living/carbon/human/H, obj/item/organ/organ)
	if(!can_lay_leech_egg(H, organ))
		return FALSE
	var/obj/item/oviposition_egg/egg = new
	egg.set_egg_type(OVI_EGG_LEECH)
	egg.set_oviposition_mother(H)
	var/fit_result = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_INSERT, egg, STORAGE_LAYER_DEEP)
	if(leech_body_storage_success(fit_result) && organ.start_oviposition_egg_growth(egg))
		feedback(H, span_warning("[src] leaves a small egg deep in my [organ.name]."), TRUE)
		return TRUE
	SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_REMOVE, egg, STORAGE_LAYER_DEEP, BODYSTORAGE_REMOVE_INTERNAL)
	qdel(egg)
	feedback(H, span_notice("[src] squirms restlessly; my [organ.name] feels too full for another egg."))
	return FALSE

/obj/item/natural/worms/leech/erotic/condom
	name = "condom leech"
	desc = "A glossy black-blue leech that sheathes a penis and drinks during sex."
	color = "#10182f"
	valid_organ_slots = list(ORGAN_SLOT_PENIS)
	var/last_sex_siphon_time = 0

/obj/item/natural/worms/leech/erotic/condom/do_behavior_tick(mob/living/carbon/human/H, obj/item/organ/organ)
	return

/obj/item/natural/worms/leech/erotic/condom/get_sex_action_effects(datum/sex_action_effect_context/context)
	if(!can_affect_sex_context(context))
		return null
	return list(new /datum/sex_action_effect/condom_leech(src))

/obj/item/natural/worms/leech/erotic/condom/proc/get_wearer()
	var/obj/item/organ/organ = target_organ
	if(!organ && istype(loc, /obj/item/organ))
		organ = loc
	return organ?.owner

/obj/item/natural/worms/leech/erotic/condom/proc/can_affect_sex_context(datum/sex_action_effect_context/context)
	var/mob/living/carbon/human/wearer = get_wearer()
	if(!wearer || !context)
		return FALSE
	if(!target_allows_pref(wearer, /datum/erp_preference/boolean/allow_horny_leeches))
		return FALSE
	if(context.action_initiator != wearer && context.action_target != wearer)
		return FALSE
	return TRUE

/obj/item/natural/worms/leech/erotic/condom/proc/can_affect_receiver(datum/sex_action_effect_context/context)
	var/mob/living/carbon/human/wearer = get_wearer()
	if(!wearer || !context?.receiver)
		return FALSE
	if(context.receiver == wearer)
		return TRUE
	if(ishuman(context.receiver))
		var/mob/living/carbon/human/H = context.receiver
		return target_allows_pref(H, /datum/erp_preference/boolean/allow_horny_leeches)
	return FALSE

/obj/item/natural/worms/leech/erotic/condom/proc/siphon_during_sex(datum/sex_action_effect_context/context)
	if(world.time <= last_sex_siphon_time)
		return
	last_sex_siphon_time = world.time
	var/mob/living/carbon/human/wearer = get_wearer()
	if(!wearer)
		return
	drain_mob_sex_fluids(wearer, context, LEECH_SEX_DRAIN_AMOUNT)
	if(ishuman(context.partner))
		var/mob/living/carbon/human/partner_human = context.partner
		if(target_allows_pref(partner_human, /datum/erp_preference/boolean/allow_horny_leeches))
			drain_mob_sex_fluids(partner_human, context, LEECH_SEX_DRAIN_AMOUNT)
	if(is_full())
		erotic_unattach(wearer, span_info("The swollen [src] slips off, unable to drink any more."))

/obj/item/natural/worms/leech/erotic/condom/proc/drain_mob_sex_fluids(mob/living/carbon/human/H, datum/sex_action_effect_context/context, amount)
	var/remaining = amount
	var/obj/item/organ/genitals/filling_organ/testicles/testicles = H.getorganslot(ORGAN_SLOT_TESTICLES)
	if(testicles?.reagents)
		remaining -= drain_reagents_into_self(testicles.reagents, remaining)
	if(remaining <= 0)
		return amount
	var/obj/item/organ/genitals/filling_organ/target_hole
	if(context?.action?.hole_id in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_ANUS))
		target_hole = H.getorganslot(context.action.hole_id)
	if(!target_hole)
		target_hole = H.getorganslot(ORGAN_SLOT_VAGINA)
	if(target_hole?.reagents)
		remaining -= drain_reagents_into_self(target_hole.reagents, remaining)
	return amount - max(remaining, 0)

/obj/item/natural/worms/leech/erotic/condom/proc/consume_climax_fluids(datum/sex_action_effect_context/context, datum/reagents/source_reagents, amount)
	var/mob/living/carbon/human/wearer = get_wearer()
	if(!wearer || !source_reagents || amount <= 0)
		return 0
	if(context?.climaxer && context.climaxer != wearer)
		if(!ishuman(context.climaxer))
			return 0
		var/mob/living/carbon/human/climaxer_human = context.climaxer
		if(!target_allows_pref(climaxer_human, /datum/erp_preference/boolean/allow_horny_leeches))
			return 0
	var/consumed = drain_reagents_into_self(source_reagents, amount)
	if(consumed && !context?.climax_follow_up)
		feedback(wearer, span_love("[src] tightens and drinks the climax before it can spill."), TRUE)
	if(is_full())
		erotic_unattach(wearer, span_info("The sated [src] slips off."))
	return consumed

/datum/sex_action_effect/condom_leech
	var/obj/item/natural/worms/leech/erotic/condom/leech

/datum/sex_action_effect/condom_leech/New(obj/item/natural/worms/leech/erotic/condom/_leech)
	. = ..(_leech)
	leech = _leech

/datum/sex_action_effect/condom_leech/modify_action(datum/sex_action_effect_context/context)
	if(!leech || QDELETED(leech) || !leech.can_affect_receiver(context))
		return
	context.arousal_amt *= 1.25
	context.orgasm_prog_amt *= 1.25

/datum/sex_action_effect/condom_leech/after_action(datum/sex_action_effect_context/context)
	if(!leech || QDELETED(leech) || !leech.can_affect_sex_context(context))
		return
	leech.siphon_during_sex(context)

/datum/sex_action_effect/condom_leech/intercept_climax(datum/sex_action_effect_context/context, datum/reagents/source_reagents, amount)
	if(!leech || QDELETED(leech) || !leech.can_affect_sex_context(context))
		return 0
	return leech.consume_climax_fluids(context, source_reagents, amount)

#undef LEECH_BLOOD_STOP_THRESHOLD
#undef LEECH_SEX_DRAIN_AMOUNT
#undef LEECH_EGG_INTERVAL
#undef LEECH_LACTATION_CAP
#undef LEECH_LACTATION_AMOUNT
#undef LEECH_REAGENT_SAFETY_MARGIN
#undef LEECH_APHRO_CAP
#undef LEECH_APHRO_AMOUNT
#undef LEECH_MIGRATION_TIME
#undef LEECH_FEEDBACK_COOLDOWN
#undef LEECH_BEHAVIOR_INTERVAL
#undef MAX_LEECH_EVILNESS
