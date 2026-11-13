/// The ordinary pregnancy profiles and offspring behavior are untouched.
/datum/oviposition_egg_profile/gnoll
	display_name = "pack renewal embryo"
	display_desc = "A magical quickening carrying the promise of a new pack champion."
	display_color = "#b58b50"
	hatch_result_type = /obj/item/gnoll_birth_seed
	incubation_stage_duration = 5 MINUTES
	poll_for_ghost = FALSE
	require_ghost_to_hatch = FALSE
	hatch_mode = OVI_HATCH_INSIDE
	auto_hatch_when_laid = FALSE
	allow_manual_host_removal = FALSE
	newborn_start_scale = 1
	newborn_growth_duration = 0
	stage_messages = list("Gorellik's renewal stirs gently within you.", "The pack's renewal grows brighter and steadier.", "The renewal is ready to become a birth-seed.")
	ready_message = "The pack's birth-seed is ready. Its champion can awaken at the shrine."

/obj/item/oviposition_egg/gnoll
	var/datum/weakref/pack_ref

/obj/item/oviposition_egg/gnoll/get_egg_profile()
	return new /datum/oviposition_egg_profile/gnoll

/datum/component/pregnancy/gnoll/Destroy()
	. = ..()
	QDEL_NULL(egg_profile)
	egg = null
	mother = null
	father = null
	carrier = null
	container = null

/datum/component/pregnancy/gnoll/handle_death(datum/source)
	remove_from_host(BODYSTORAGE_REMOVE_INTERNAL)
	qdel(egg)

/datum/component/pregnancy/gnoll/create_hatch_result()
	var/obj/item/oviposition_egg/gnoll/embryo = egg
	var/datum/team/gnoll/pack = embryo?.pack_ref?.resolve()
	if(!pack || !carrier || !container || stage < max_stage)
		return null
	return new /obj/item/gnoll_birth_seed(get_turf(carrier), pack)

/// Birth yields an inert seed outside the carrier. No baby mob or internal player is created.
/datum/component/pregnancy/gnoll/hatch_item_inside_host(obj/item/gnoll_birth_seed/seed)
	var/mob/living/carbon/birth_carrier = carrier
	if(!seed || !birth_carrier || !remove_from_host(BODYSTORAGE_REMOVE_INTERNAL))
		qdel(seed)
		return FALSE
	seed.forceMove(get_turf(birth_carrier))
	birth_carrier.record_oviposition_birth()
	birth_carrier.visible_message(span_notice("Gorellik's renewal settles into a warm birth-seed beside [birth_carrier]."))
	to_chat(birth_carrier, span_notice("The pregnancy is complete. The pack can take the seed to its shrine; it must now let you go."))
	var/obj/item/oviposition_egg/gnoll/embryo = egg
	var/datum/team/gnoll/pack = embryo.pack_ref?.resolve()
	if(pack)
		if(is_in_gnoll_camp(birth_carrier))
			birth_carrier.apply_status_effect(/datum/status_effect/gnoll_owed_release, pack)
		else
			pack.credit_ritual_release(birth_carrier)
	qdel(egg)
	return TRUE

/proc/get_gnoll_ritual_pregnancy(mob/living/carbon/human/carrier)
	if(!istype(carrier))
		return null
	var/obj/item/organ/womb = carrier.get_womb()
	for(var/obj/item/oviposition_egg/gnoll/embryo in womb?.get_oviposition_eggs())
		var/datum/component/pregnancy/gnoll/pregnancy = embryo.GetComponent(/datum/component/pregnancy/gnoll)
		if(pregnancy)
			return pregnancy
	return null

/proc/start_gnoll_ritual_pregnancy(mob/living/carbon/human/carrier, mob/living/father, datum/team/gnoll/pack, obj/item/organ/genitals/filling_organ/womb/womb)
	var/obj/item/oviposition_egg/gnoll/embryo = new
	embryo.pack_ref = WEAKREF(pack)
	embryo.set_oviposition_mother(carrier)
	switch(SEND_SIGNAL(womb, COMSIG_BODYSTORAGE_TRY_INSERT, embryo, STORAGE_LAYER_DEEP))
		if(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_OK_OVERRIDE, INSERT_FEEDBACK_ALMOST_FULL)
			var/datum/component/pregnancy/gnoll/pregnancy = embryo.AddComponent(/datum/component/pregnancy/gnoll, carrier, father, /obj/item/gnoll_birth_seed, TRUE)
			if(pregnancy)
				if(pack.get_favor() >= GNOLL_FAVOR_RENEWAL)
					pregnancy.stage_duration = round(pregnancy.stage_duration * 0.75)
					COOLDOWN_START(pregnancy, stage_time, pregnancy.stage_duration)
				return TRUE
	SEND_SIGNAL(womb, COMSIG_BODYSTORAGE_TRY_REMOVE, embryo, STORAGE_LAYER_DEEP, BODYSTORAGE_REMOVE_INTERNAL)
	qdel(embryo)
	return FALSE

/// Ordinary pregnancy remedies call this; the ritual has no special protection.
/proc/end_gnoll_ritual_pregnancy(mob/living/carbon/human/carrier)
	var/datum/component/pregnancy/gnoll/pregnancy = get_gnoll_ritual_pregnancy(carrier)
	if(!pregnancy)
		return FALSE
	var/obj/item/oviposition_egg/embryo = pregnancy.egg
	pregnancy.remove_from_host(BODYSTORAGE_REMOVE_INTERNAL)
	qdel(embryo)
	return TRUE

/proc/get_gnoll_ritual_womb(mob/living/carbon/human/carrier)
	if(!istype(carrier) || !carrier.can_start_oviposition_gestation())
		return null
	var/obj/item/organ/genitals/filling_organ/womb/womb = carrier.get_womb()
	if(!istype(womb) || !womb.fertility || !womb.supports_oviposition_pregnancy() || length(womb.get_oviposition_eggs()) || womb.count_internal_womb_hatchlings())
		return null
	return womb

/obj/item/gnoll_birth_seed
	name = "Gorellik's birth-seed"
	desc = "A warm seed of pack magic. A champion can offer it at Gorellik's shrine to call a new, fully mature adult into the pack. If no soul answers, the seed remains available."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "amulet"
	color = "#b58b50"
	w_class = WEIGHT_CLASS_SMALL
	var/datum/weakref/pack_ref
	var/polling = FALSE

/obj/item/gnoll_birth_seed/Initialize(mapload, datum/team/gnoll/pack)
	. = ..()
	if(pack)
		pack_ref = WEAKREF(pack)
		pack.birth_seeds += WEAKREF(src)

/obj/item/gnoll_birth_seed/Destroy()
	var/datum/team/gnoll/pack = pack_ref?.resolve()
	pack?.birth_seeds.Remove(WEAKREF(src))
	pack_ref = null
	return ..()

/obj/structure/gnoll_shrine/proc/awaken_champion(mob/living/carbon/human/user, obj/item/gnoll_birth_seed/seed)
	var/datum/antagonist/gnoll/champion = get_gnoll_antag(user)
	var/datum/team/gnoll/pack = seed.pack_ref?.resolve()
	if(!champion || champion.pack != pack || !pack.has_room() || seed.polling || !Adjacent(user) || !can_join_gnoll_rite(user) || user.get_active_held_item() != seed)
		to_chat(user, span_warning("This seed needs its own pack's shrine rite, an available champion place, and an awake bearer."))
		return
	seed.polling = TRUE
	pack.reserved_places++
	var/list/candidates = pollGhostCandidates("Awaken as a fully mature adult Gnoll Champion of Gorellik? Share the pack's living-hunt and renewal contracts; no killing quarry.", ROLE_GNOLL, null, FALSE, 30 SECONDS)
	for(var/mob/candidate as anything in candidates.Copy())
		if(!candidate.client || is_total_antag_banned(candidate.ckey) || is_antag_banned(candidate.ckey, ROLE_GNOLL))
			candidates -= candidate
	if(QDELETED(src) || QDELETED(seed) || !Adjacent(user) || !can_join_gnoll_rite(user) || get_gnoll_antag(user) != champion || user.get_active_held_item() != seed || !length(candidates) || length(pack.members) >= pack.get_member_limit())
		pack.reserved_places--
		if(!QDELETED(seed))
			seed.polling = FALSE
		to_chat(user, span_notice("The seed waits. Try again when a willing soul and a place in the pack are available."))
		return
	var/mob/candidate = pick(candidates)
	candidate.leave_lobby_for_role()
	// This mob is adult in body and mind before receiving a player or antagonist role.
	var/champion_type = pick(/mob/living/carbon/human/species/gnoll_champion/male, /mob/living/carbon/human/species/gnoll_champion/female)
	var/mob/living/carbon/human/species/gnoll_champion/new_champion = new champion_type(get_turf(user))
	new_champion.real_name = random_unique_name(new_champion.gender)
	new_champion.update_name()
	new_champion.mind_initialize()
	new_champion.key = candidate.key
	new_champion.job = ROLE_GNOLL
	new_champion.mind.set_assigned_role(SSjob.GetJobType(/datum/job/gnoll))
	pack.reserved_places--
	var/datum/antagonist/gnoll/new_antag = new_champion.mind.add_antag_datum(/datum/antagonist/gnoll, pack)
	if(!new_antag)
		new_champion.ghostize(FALSE)
		qdel(new_champion)
		seed.polling = FALSE
		return
	to_chat(new_champion, span_notice("You awaken fully grown, with an adult's judgment and an independent will. Gorellik has called you to the living pack; your oaths and bonds are yours to choose."))
	var/datum/contract_goal/gnoll/awakening/goal = pack.get_goal(/datum/contract_goal/gnoll/awakening)
	goal?.record_once(new_champion.mind)
	new_champion.hugboxify_for_class_selection()
	SSrole_class_handler.setup_class_handler(new_champion)
	message_admins("[key_name_admin(new_champion)] awakened as a mature Gnoll Champion at [ADMIN_VERBOSEJMP(src)].")
	qdel(seed)

