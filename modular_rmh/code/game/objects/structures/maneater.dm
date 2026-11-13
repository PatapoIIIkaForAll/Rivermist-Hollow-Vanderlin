/// Every adult maneater owns one folded stomach through this otherwise invisible living proxy.
/// Keeping the carrier as a mob lets the existing sex and captivity systems work without teaching
/// either system how to treat an anchored structure as an actor.
/mob/living/simple_animal/hostile/retaliate/maneater_tendrils
	name = "flowering maneater vines"
	desc = "The unseen feeding vines of a maneater."
	icon = 'modular_rmh/icons/mob/monster/tentacles_grey.dmi'
	icon_state = "vine_medium"
	icon_living = "vine_medium"
	icon_dead = "vine_medium_dead"
	faction = list("maneater")
	gender = PLURAL
	ai_controller = null
	move_resist = INFINITY
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT
	health = 100
	maxHealth = 100
	var/tmp/datum/weakref/maneater_ref

/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/Initialize(mapload)
	. = ..()
	apply_tentacle_palette(TENTACLE_PALETTE_VINE)
	var/obj/item/organ/genitals/penis/ovipositor/ovipositor = ensure_maneater_ovipositor(src)
	if(ovipositor)
		ovipositor.name = "seed-bearing vine"
		ovipositor.desc = "A flowering tendril adapted to implant soft, root-filled seeds."

/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/proc/set_maneater_owner(obj/structure/flora/grass/maneater/real/maneater)
	maneater_ref = maneater ? WEAKREF(maneater) : null

/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/proc/get_maneater_owner()
	var/obj/structure/flora/grass/maneater/real/maneater = maneater_ref?.resolve()
	if(maneater && !QDELETED(maneater))
		return maneater
	maneater_ref = null
	return null

/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, runechat_message = null, log_seen = NONE, log_seen_msg = null)
	var/obj/structure/flora/grass/maneater/real/maneater = get_maneater_owner()
	if(!maneater)
		return ..()
	// The proxy is abstract-invisible, which would suppress ordinary sex-action announcements.
	// Announce through the visible plant while retaining the vines' name in the prepared message.
	return maneater.visible_message(message, null, blind_message, vision_distance, ignored_mobs, runechat_message, log_seen, log_seen_msg)

/datum/map_template/pocket/defeat_captivity/maneater
	name = "Maneater Stomach"
	id = "pocket_defeat_captivity_maneater"
	mappath = "_maps/templates/pockets/kidnap_lairs/maneater_stomach.dmm"
	instance_type = /datum/pocket_dimension/defeat_captivity/maneater

/obj/structure/pocket_dimension_exit/maneater
	name = "living vine passage"
	desc = "A narrow opening between thick, slowly writhing vines. Push through it to escape the maneater."
	icon = 'modular_rmh/icons/obj/structures/maneater_stomach.dmi'
	icon_state = "vine_exit"

/obj/effect/landmark/pocket_dimension/exit/maneater
	name = "maneater stomach exit marker"
	exit_structure_type = /obj/structure/pocket_dimension_exit/maneater

/datum/defeat_captivity_profile/carrier/maneater
	stable_key = "maneater_stomach"
	display_name = "maneater stomach"
	template_type = /datum/map_template/pocket/defeat_captivity/maneater
	// The defeat knockout blocks this exit at first. Once it wears off, a captive who reaches the
	// opening through the guardian vines may climb back out at the parent plant.
	access_rule = DEFEAT_CAPTIVITY_ACCESS_RELEASED

/datum/defeat_captivity_profile/carrier/maneater/get_ejection_destination(datum/component/kidnap_captivity/captivity, datum/pocket_dimension/defeat_captivity/instance)
	var/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/vines = captivity?.resolve_captor()
	var/obj/structure/flora/grass/maneater/real/maneater = vines?.get_maneater_owner()
	if(!maneater)
		return ..()

	var/mob/living/victim = captivity.parent
	var/list/valid_destinations = list()
	for(var/turf/open/candidate in orange(1, maneater))
		if(candidate.is_blocked_turf(TRUE, victim))
			continue
		if(locate(/obj/structure/flora/grass/maneater/real) in candidate)
			continue
		if(is_valid_ejection_turf(candidate, instance))
			valid_destinations += candidate
	if(length(valid_destinations))
		return pick(valid_destinations)
	return null

/datum/pocket_dimension/defeat_captivity/maneater

/datum/pocket_dimension/defeat_captivity/maneater/Destroy(force)
	var/obj/structure/flora/grass/maneater/real/maneater = get_owner_plant()
	. = ..()
	maneater?.update_icon()

// Teardown ejects every living mob, and an ejected vine's leash drops it outside the stomach; delete flora first.
/datum/pocket_dimension/defeat_captivity/maneater/eject_teardown_contents(message = null, atom/override_destination = null)
	for(var/mob/occupant as anything in get_occupants())
		if(istype(occupant, /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater))
			qdel(occupant)
	return ..()

/datum/pocket_dimension/defeat_captivity/maneater/register_captive(datum/component/kidnap_captivity/captivity)
	. = ..()
	var/obj/structure/flora/grass/maneater/real/maneater = get_owner_plant()
	maneater?.update_icon()

/datum/pocket_dimension/defeat_captivity/maneater/unregister_captive(datum/component/kidnap_captivity/captivity, delete_when_empty = TRUE)
	. = ..()
	var/obj/structure/flora/grass/maneater/real/maneater = get_owner_plant()
	maneater?.update_icon()

/datum/pocket_dimension/defeat_captivity/maneater/proc/get_owner_plant()
	RETURN_TYPE(/obj/structure/flora/grass/maneater/real)
	var/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/vines = carrier_ref?.resolve()
	return vines?.get_maneater_owner()

/datum/pocket_dimension/defeat_captivity/maneater/proc/ensure_stomach_guardians(atom/reference)
	var/list/root_turfs = list()
	for(var/turf/stomach_turf as anything in affected_turfs)
		var/obj/effect/maneater_vine_root/root = locate() in stomach_turf
		if(root)
			root.regrow_vine()
			root_turfs[stomach_turf] = TRUE

	var/guardian_count = 0
	for(var/mob/occupant as anything in get_occupants())
		if(istype(occupant, /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/big))
			continue
		if(istype(occupant, /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater))
			guardian_count++

	var/guardians_needed = 3 - guardian_count
	if(guardians_needed <= 0)
		return

	var/list/valid_turfs = list()
	for(var/turf/open/candidate as anything in RANGE_TURFS(3, reference))
		if(!contains_turf(candidate) || root_turfs[candidate] || candidate.is_blocked_turf(TRUE))
			continue
		valid_turfs += candidate
	if(length(valid_turfs) < guardians_needed)
		for(var/turf/open/candidate as anything in affected_turfs)
			if((candidate in valid_turfs) || root_turfs[candidate] || candidate.is_blocked_turf(TRUE))
				continue
			valid_turfs += candidate

	while(guardians_needed > 0 && length(valid_turfs))
		var/turf/spawn_turf = pick_n_take(valid_turfs)
		var/guardian_type = pickweight(list(
			/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/small = 3,
			/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater = 1,
		))
		new guardian_type(spawn_turf)
		guardians_needed--

/// Mapped spot where a greater stomach vine takes root; each swallow regrows a missing or dead one.
/obj/effect/maneater_vine_root
	name = "stomach vine root"
	icon = 'modular_rmh/icons/mob/monster/maneater_big_vine.dmi'
	icon_state = "vine_big_hide_on"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	var/datum/weakref/vine_ref

/obj/effect/maneater_vine_root/proc/regrow_vine()
	var/mob/living/vine = vine_ref?.resolve()
	if(vine && !QDELETED(vine))
		if(vine.stat != DEAD)
			return vine
		qdel(vine)
	vine = new /mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/big(get_turf(src))
	vine_ref = WEAKREF(vine)
	return vine

//safer maneater
/obj/structure/flora/grass/maneater
	name = "grass"
	desc = "Green and vivid. Was that a tendril?"
	icon = 'icons/roguetown/mob/monster/maneater.dmi'
	icon_state = "maneater-hidden"
	num_random_icons = 0
	max_integrity = 5

/obj/structure/flora/grass/maneater/update_icon()
	. = ..()
	return

/obj/structure/flora/grass/maneater/real
	var/aggroed = 0
	max_integrity = 100
	integrity_failure = 0.15
	attacked_sound = list('sound/vo/mobs/plant/pain (1).ogg','sound/vo/mobs/plant/pain (2).ogg','sound/vo/mobs/plant/pain (3).ogg','sound/vo/mobs/plant/pain (4).ogg')
	var/list/eatablez = list(/obj/item/bodypart, /obj/item/organ, /obj/item/reagent_containers/food/snacks/meat)
	var/last_eat
	buckle_lying = FALSE
	buckle_prevents_pull = TRUE
	var/seednutrition = 0
	var/max_seednutrition = 100
	var/mob/planter = null
	/// Victim currently being prepared for swallowing.
	var/datum/weakref/horny_victim_ref
	/// Invisible living actor used for sex actions and as this plant's stomach carrier.
	var/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/sex_proxy
	var/swallow_timer
	var/swallow_time = 30 SECONDS
	/// Damage of an ordinary chew, which armor on the chewed limb can stop.
	var/chew_damage = 10
	/// Damage of a big bite, which ignores armor and feeds the plant.
	var/bite_damage = 15
	/// The plant spits its victim out once one meal has dealt more than this.
	var/spit_threshold = 20
	var/chew_interval = 2 SECONDS
	/// How often the vines peel one garment off a victim being swallowed.
	var/strip_interval = 3 SECONDS
	var/strip_timer
	/// TRUE once swallow_time has passed; the plant then swallows as soon as nothing is left to strip.
	var/swallow_due = FALSE
	/// Share of max_integrity a removed cloth or leather garment loses to the vines.
	var/strip_tear_ratio = 0.15
	/// This plant's stomach pocket, held weakly so a torn-down pocket is simply forgotten.
	var/datum/weakref/stomach_ref

/obj/structure/flora/grass/maneater/real/process()
	if(seednutrition >= max_seednutrition)
		produce_seed()
		seednutrition = 0
	if(world.time > aggroed + 30 SECONDS && !has_buckled_mobs())
		aggroed = 0
		update_icon()
		STOP_PROCESSING(SSobj, src)
		return TRUE

/obj/structure/flora/grass/maneater/real/atom_break(damage_flag)
	. = ..()
	reset_horny_capture(TRUE)
	unbuckle_all_mobs()
	if(contents.len)
		for(var/obj/item/eaten in contents)
			var/turf/target = get_ranged_target_turf(src, pick(GLOB.alldirs), 1)
			playsound(src,'sound/misc/maneaterspit.ogg', 100)
			eaten.forceMove(target)
			contents.Remove(eaten)
	STOP_PROCESSING(SSobj, src)

/obj/structure/flora/grass/maneater/real/Destroy()
	reset_horny_capture(TRUE)
	unbuckle_all_mobs()
	if(contents.len)
		for(var/obj/item/eaten in contents)
			var/turf/target = get_ranged_target_turf(src, pick(GLOB.alldirs), 1)
			playsound(src,'sound/misc/maneaterspit.ogg', 100)
			eaten.forceMove(target)
			contents.Remove(eaten)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/flora/grass/maneater/real/Crossed(atom/movable/AM)
	. = ..()
	if(world.time <= last_eat + 5 SECONDS)
		return
	if(has_buckled_mobs())
		return

	if(!aggroed)
		START_PROCESSING(SSobj, src)
	aggroed = world.time
	update_icon()

	if(!isliving(AM))
		if(is_type_in_list(AM, eatablez))
			last_eat = world.time
			playsound(src,'sound/misc/eat.ogg', rand(30,60), TRUE)
			AM.forceMove(src)
			seednutrition += 10
		return

	var/mob/living/victim = AM
	if(victim == planter)
		return
	if(!can_snatch(victim))
		return
	if(victim.m_intent == MOVE_INTENT_SNEAK)
		return

	if(!buckle_mob(victim, TRUE, check_loc = FALSE))
		return
	if(victim_allows_horny_capture(victim))
		begin_horny_swallow(victim)
	else
		// The meal sleeps between chews, so it must not run inside the victim's Move().
		INVOKE_ASYNC(src, PROC_REF(begin_eat), victim)

// Crossed() owns snatching; the core adjacency grab skipped consent, pacifism and juvenile checks.
/obj/structure/flora/grass/maneater/real/HasProximity(atom/movable/AM)
	return

/// Mirrors ambushable() minus its five-minute post-ambush grace, so a recent ambush cannot shield the victim.
/obj/structure/flora/grass/maneater/real/proc/can_snatch(mob/living/victim)
	if(!victim.mind || victim.stat || (victim.status_flags & GODMODE))
		return FALSE
	if(!victim.ambushable || HAS_TRAIT(victim, TRAIT_NOAMBUSH))
		return FALSE
	// Pacifists face only a capture they opted into; defeated victims stay exempt.
	if(HAS_TRAIT(victim, TRAIT_PACIFISM))
		return !victim.has_status_effect(/datum/status_effect/defeat_knockout) && victim_allows_horny_capture(victim)
	return TRUE

/obj/structure/flora/grass/maneater/real/proc/victim_allows_horny_capture(mob/living/victim)
	if(!ishuman(victim) || victim.stat == DEAD || victim.status_flags & GODMODE)
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_DEFEAT_REFUSE_ADVANCES))
		return FALSE
	if(!(victim.get_cached_horny_mob_family_flags() & HORNY_MOB_TYPE_MANEATERS))
		return FALSE
	// Maneaters are sexless plants, so opting into either ordinary horny-mob target sex enables them.
	return !!victim.get_cached_horny_mob_pref_flags()

/obj/structure/flora/grass/maneater/real/proc/get_sex_proxy()
	if(sex_proxy && !QDELETED(sex_proxy))
		sex_proxy.forceMove(get_turf(src))
		sex_proxy.set_maneater_owner(src)
		return sex_proxy
	sex_proxy = new(get_turf(src))
	sex_proxy.set_maneater_owner(src)
	return sex_proxy

/obj/structure/flora/grass/maneater/real/proc/begin_horny_swallow(mob/living/victim)
	if(!victim || QDELETED(victim) || victim.buckled != src)
		return FALSE
	reset_horny_capture()
	horny_victim_ref = WEAKREF(victim)

	var/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/vines = get_sex_proxy()
	var/datum/sex_scene_controller/scene_controller = vines?.open_sex_scene(victim, FALSE)
	if(scene_controller)
		var/list/action_choices = list(
			/datum/sex_action/npc/npc_anal_sex/tentacle/maneater,
			/datum/sex_action/npc/npc_throat_sex/tentacle/maneater,
			/datum/sex_action/maneater_vine_caress,
		)
		if(victim.getorganslot(ORGAN_SLOT_VAGINA))
			action_choices += /datum/sex_action/npc/npc_vaginal_sex/tentacle/maneater
		if(victim.getorganslot(ORGAN_SLOT_PENIS))
			action_choices += /datum/sex_action/tentacle_jerk/maneater
		while(length(action_choices))
			var/action_type = pick_n_take(action_choices)
			if(scene_controller.try_start_action(action_type, "ai"))
				break
		scene_controller.set_current_force(rand(SEX_FORCE_MID, SEX_FORCE_EXTREME))
		scene_controller.set_current_speed(rand(SEX_SPEED_MID, SEX_SPEED_EXTREME))

	visible_message(span_warningbig("[src]'s flowering vines close around [victim] and begin drawing them toward its maw!"))
	to_chat(victim, span_userdanger("The maneater's vines hold you and start to take your clothes off, one piece at a time. Its throat opens below you. It will not swallow you while you still have clothes on, and not before [DisplayTimeText(swallow_time)] have passed. Get free!"))
	swallow_timer = addtimer(CALLBACK(src, PROC_REF(swallow_time_up)), swallow_time, TIMER_STOPPABLE | TIMER_DELETE_ME)
	strip_timer = addtimer(CALLBACK(src, PROC_REF(strip_next_garment)), strip_interval, TIMER_STOPPABLE | TIMER_DELETE_ME)
	return TRUE

/// Ends swallow_time; the plant swallows now if nothing is left to take, else right after the last garment.
/obj/structure/flora/grass/maneater/real/proc/swallow_time_up()
	swallow_timer = null
	swallow_due = TRUE
	if(!strip_timer)
		strip_next_garment()

/// Takes one piece off the victim being swallowed and returns it; swallows once nothing is left and time is up.
/obj/structure/flora/grass/maneater/real/proc/strip_next_garment()
	strip_timer = null
	var/mob/living/carbon/human/victim = horny_victim_ref?.resolve()
	if(!istype(victim) || QDELETED(victim) || victim.buckled != src)
		reset_horny_capture()
		return FALSE
	var/list/gear = list(victim.beltl, victim.beltr, victim.belt, victim.backl, victim.backr)
	for(var/obj/item/garment as anything in get_strip_order(victim))
		if(!garment || garment.loc != victim || !garment.canStrip(sex_proxy, victim))
			continue
		// Stockings are torn where they sit and never removed; torn or untearable ones stay.
		if(garment == victim.legwear_socks)
			var/obj/item/clothing/legwears/stockings = garment
			if(!istype(stockings) || stockings.obj_broken)
				continue
			var/stockings_name = stockings.name
			if(!stockings.tear_open())
				continue
			visible_message(span_danger("[src]'s vines rake [victim]'s [stockings_name] into ragged ladders!"))
		else
			var/garment_name = garment.name
			var/is_gear = (garment in gear)
			if(!victim.dropItemToGround(garment))
				continue
			if(is_gear)
				visible_message(span_danger("[src]'s vines unhook [victim]'s [garment_name] and throw it aside!"))
			else if(tear_stripped_garment(garment))
				visible_message(span_danger("[src]'s vines tear [victim]'s [garment_name] at the seam, pull it off and throw it aside!"))
			else
				visible_message(span_danger("[src]'s vines pry [victim]'s [garment_name] loose, pull it off and throw it aside!"))
			// Some items delete themselves when they come off; there is nothing to throw then.
			if(!QDELETED(garment))
				throw_stripped_garment(garment)
		strip_timer = addtimer(CALLBACK(src, PROC_REF(strip_next_garment)), strip_interval, TIMER_STOPPABLE | TIMER_DELETE_ME)
		return garment
	if(swallow_due)
		complete_horny_swallow()
	return FALSE

/// Worn items the vines go for, in order: gear, outer layers, stockings, then underwear.
/obj/structure/flora/grass/maneater/real/proc/get_strip_order(mob/living/carbon/human/victim)
	. = list(victim.beltl, victim.beltr, victim.belt, victim.backl, victim.backr, victim.cloak, victim.wear_armor)
	if(is_strippable_armour(victim.wear_neck))
		. += victim.wear_neck
	. += victim.head
	if(!istype(victim.wear_mask, /obj/item/clothing/face/spectacles))
		. += victim.wear_mask
	. += victim.gloves
	if(is_strippable_armour(victim.wear_wrists))
		. += victim.wear_wrists
	. += list(victim.armsleeves, victim.shoes, victim.wear_shirt, victim.wear_pants, victim.legwear_socks, victim.undershirt, victim.bra, victim.underwear)

/// Neck and wrist pieces come off only when they have an armour class; jewellery and collars stay.
/obj/structure/flora/grass/maneater/real/proc/is_strippable_armour(obj/item/clothing/piece)
	return istype(piece) && piece.armor_class > ARMOR_CLASS_NONE

/// Tears a removed sewn garment by strip_tear_ratio, never down to breaking; smithed and storage items are spared.
/obj/structure/flora/grass/maneater/real/proc/tear_stripped_garment(obj/item/garment)
	if(QDELETED(garment) || garment.obj_broken || istype(garment, /obj/item/storage))
		return FALSE
	if(garment.anvilrepair && !garment.sewrepair)
		return FALSE
	var/break_point = garment.integrity_failure * garment.max_integrity
	var/damage = min(garment.max_integrity * strip_tear_ratio, garment.get_integrity() - break_point - 1)
	if(damage < DAMAGE_PRECISION)
		return FALSE
	return garment.take_damage(damage, BRUTE, "", FALSE) > 0

/// Throws a stripped item to a free turf near the plant.
/obj/structure/flora/grass/maneater/real/proc/throw_stripped_garment(obj/item/garment)
	var/list/landing_turfs = list()
	for(var/turf/open/candidate in orange(2, src))
		if(!candidate.is_blocked_turf(TRUE))
			landing_turfs += candidate
	if(length(landing_turfs))
		garment.throw_at(pick(landing_turfs), 2, 1)

/obj/structure/flora/grass/maneater/real/proc/stop_stripping()
	if(strip_timer)
		deltimer(strip_timer)
		strip_timer = null

/obj/structure/flora/grass/maneater/real/proc/stop_horny_actions()
	if(!sex_proxy || QDELETED(sex_proxy))
		return
	sex_proxy.sex_scene?.stop_action()

/obj/structure/flora/grass/maneater/real/proc/reset_horny_capture(delete_proxy = FALSE)
	if(swallow_timer)
		deltimer(swallow_timer)
		swallow_timer = null
	swallow_due = FALSE
	stop_stripping()
	horny_victim_ref = null
	stop_horny_actions()
	if(delete_proxy)
		QDEL_NULL(sex_proxy)

/obj/structure/flora/grass/maneater/real/proc/complete_horny_swallow()
	if(swallow_timer)
		deltimer(swallow_timer)
		swallow_timer = null
	swallow_due = FALSE
	stop_stripping()
	var/mob/living/victim = horny_victim_ref?.resolve()
	horny_victim_ref = null
	if(!victim || QDELETED(victim) || victim.buckled != src || victim.loc != loc || obj_broken)
		stop_horny_actions()
		return FALSE

	stop_horny_actions()
	visible_message(span_userdanger("[src]'s maw yawns open and swallows [victim] whole!"))
	unbuckle_mob(victim, TRUE)

	var/mob/living/simple_animal/hostile/retaliate/maneater_tendrils/vines = get_sex_proxy()
	var/added_knockout = !victim.has_status_effect(/datum/status_effect/defeat_knockout)
	// The swallow is a horny defeat, so the knockout must carry a horny snapshot, not a stale one.
	if(added_knockout && !victim.enter_defeat(DEFEAT_REASON_HORNY, DEFEAT_SEVERITY_NORMAL, vines))
		var/datum/defeat_snapshot/snapshot = new
		if(iscarbon(victim) && snapshot.capture_from(victim, DEFEAT_REASON_HORNY, DEFEAT_SEVERITY_NORMAL, vines))
			victim.last_defeat_snapshot = snapshot
		else
			qdel(snapshot)
		victim.apply_status_effect(/datum/status_effect/defeat_knockout)
	if(!victim.kidnap_to_pocket(/datum/defeat_captivity_profile/carrier/maneater, vines, list("maneater"), "maneater_stomach"))
		if(added_knockout)
			victim.remove_status_effect(/datum/status_effect/defeat_knockout)
		maneater_spit_out(victim)
		return FALSE

	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/maneater/stomach = captivity?.resolve_instance()
	stomach?.ensure_stomach_guardians(victim)
	stomach_ref = stomach ? WEAKREF(stomach) : null
	update_icon()
	last_eat = world.time
	to_chat(victim, span_userdanger("Warm, yielding walls close around you. Hungry green vines stir nearby."))
	return TRUE

/obj/structure/flora/grass/maneater/real/post_buckle_mob(mob/living/buckled_mob)
	. = ..()
	update_icon()

/obj/structure/flora/grass/maneater/real/post_unbuckle_mob(mob/living/unbuckled_mob)
	. = ..()
	if(unbuckled_mob == horny_victim_ref?.resolve())
		reset_horny_capture()
	update_icon()

/obj/structure/flora/grass/maneater/real/proc/begin_eat(mob/living/victim)
	var/meal_damage = 0
	var/bite_chance = 15
	while(victim.buckled == src)
		visible_message(span_warningbig("[src] begins to gnaw on [victim]!"))
		if(!do_after(victim, chew_interval, progress = FALSE) || victim.buckled != src)
			visible_message(span_warning("[src] stops chewing on [victim]!"))
			return
		if(meal_damage > spit_threshold)
			maneater_spit_out(victim)
			return

		playsound(src,'sound/misc/eat.ogg', rand(30,60), TRUE)
		meal_damage += chew_victim(victim, bite_chance)
		bite_chance *= 2

		if(victim.stat == DEAD)
			var/mob/living/carbon/carbon_victim = iscarbon(victim) ? victim : null
			if(victim.mind || carbon_victim?.last_mind)
				victim.gib()
				seednutrition += 50
			else
				maneater_spit_out(victim)
			return

/// Chews a random limb, or the torso if none remain; returns the damage dealt after armor.
/obj/structure/flora/grass/maneater/real/proc/chew_victim(mob/living/victim, bite_chance)
	if(!iscarbon(victim))
		victim.adjustBruteLoss(chew_damage)
		return chew_damage

	var/mob/living/carbon/carbon_victim = victim
	var/obj/item/bodypart/limb = carbon_victim.get_bodypart_complex(list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)) || carbon_victim.get_bodypart(BODY_ZONE_CHEST)
	victim.flash_fullscreen("redflash3")
	playsound(src.loc, list('sound/vo/mobs/plant/attack (1).ogg','sound/vo/mobs/plant/attack (2).ogg','sound/vo/mobs/plant/attack (3).ogg','sound/vo/mobs/plant/attack (4).ogg'), 100, FALSE, -1)

	var/big_bite = prob(bite_chance)
	var/damage = big_bite ? bite_damage : max(0, chew_damage - victim.run_armor_check(limb, BCLASS_CUT, damage = chew_damage))
	if(!damage)
		return 0
	// Bodypart brute is rebuilt from the injury list, so receive_damage() would not last.
	if(limb.create_injury(WOUND_BITE, damage) && big_bite)
		seednutrition += 25
	limb.update_damages()
	victim.updatehealth()
	return damage

/obj/structure/flora/grass/maneater/real/proc/maneater_spit_out(mob/living/C)
	if(!C)
		return
	if(!isliving(C))
		return
	if(C == horny_victim_ref?.resolve())
		reset_horny_capture()
	visible_message(span_danger("[src] spits out [C]!"))
	if(C.buckled == src)
		unbuckle_mob(C, TRUE)
	var/turf/target = get_ranged_target_turf(src, pick(GLOB.alldirs), 3)
	C.throw_at(target, 3, 2)
	playsound(src,'sound/misc/maneaterspit.ogg', 100)
	return TRUE

/obj/structure/flora/grass/maneater/real/proc/is_full()
	var/datum/pocket_dimension/defeat_captivity/maneater/stomach = stomach_ref?.resolve()
	if(!stomach || QDELETED(stomach) || stomach.teardown_started)
		return FALSE
	return stomach.captive_count() > 0

/obj/structure/flora/grass/maneater/real/update_icon()
	. = ..()
	icon = initial(icon)
	desc = initial(desc)
	if(obj_broken)
		name = "MANEATER"
		desc = "This cunning creature is thankfully defeated."
		icon_state = "maneater-dead"
		return
	if(is_full() && !has_buckled_mobs())
		name = "MANEATER"
		desc = "Its swollen pod heaves and bulges. Something inside is still moving."
		icon = 'modular_rmh/icons/mob/monster/maneater_full.dmi'
		icon_state = "maneater-full"
		return
	if(aggroed)
		name = "MANEATER"
		icon_state = "maneater"
	else
		name = "grass"
		icon_state = "maneater-hidden"

/obj/structure/flora/grass/maneater/real/user_unbuckle_mob(mob/living/M, mob/user, break_factor = 1)
	if(obj_broken)
		. = ..()
		return
	if(!isliving(user))
		return

	var/mob/living/L = user
	var/time2mount = CLAMP((L.STASTR * 2 * break_factor), 1, 99)
	if(istype(src, /obj/structure/flora/grass/maneater/real/juvenile))
		time2mount *= 2
	user.changeNext_move(CLICK_CD_FAST, override = TRUE)
	if(user != M)
		user.visible_message(span_warning("[user] tries to pull [M] free of [src]!"))
	else
		user.visible_message(span_warning("[user] tries to break free of [src]!"))

	if(!do_after(user, 1.5 SECONDS))
		user.visible_message(span_warning("[M] stops struggling!"))
		return
	if(!prob(time2mount))
		user_unbuckle_mob(M, user, break_factor * 1.5)
	. = ..()

/obj/structure/flora/grass/maneater/real/user_buckle_mob(mob/living/M, mob/living/user, check_loc = TRUE) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/flora/grass/maneater/real/attackby(obj/item/W, mob/user, params)
	. = ..()
	aggroed = world.time
	update_icon()


//JUVENILE MANEATER

/obj/structure/flora/grass/maneater/real/juvenile
	name = "juvenile maneater"
	desc = "A bud the size of a fist on a mat of dry roots. Its lips part now and then."
	icon = 'modular_rmh/icons/mob/monster/maneater_juvenile.dmi'
	icon_state = "juvenile_1"
	max_integrity = 50
	seednutrition = 0
	max_seednutrition = 50
	var/growth_stage = 1
	var/max_growth_stage = 3
	var/growth_time = 20 MINUTES


/obj/structure/flora/grass/maneater/real/juvenile/Initialize()
	. = ..()
	update_icon()
	addtimer(CALLBACK(src, .proc/try_grow), growth_time)

// Juveniles still eat loose food in the parent Crossed(), but never seize a living victim.
/obj/structure/flora/grass/maneater/real/juvenile/can_snatch(mob/living/victim)
	return FALSE

/obj/structure/flora/grass/maneater/real/juvenile/proc/try_grow()
	if(growth_stage < max_growth_stage)
		growth_stage++
		update_icon()
		visible_message(span_warning("[src] grows bigger!"))
		playsound(loc, list('sound/vo/mobs/plant/attack (1).ogg','sound/vo/mobs/plant/attack (2).ogg','sound/vo/mobs/plant/attack (3).ogg','sound/vo/mobs/plant/attack (4).ogg'), 100, FALSE, -1)
		addtimer(CALLBACK(src, .proc/try_grow), growth_time)
		return

	// Replace with adult form
	visible_message(span_danger("[src] reaches full maturity!"))
	var/turf/T = get_turf(src)
	var/obj/structure/flora/grass/maneater/real/myboy = new(T)
	myboy.planter = planter
	qdel(src)

// Overrides the adult's grass and maw states; only a broken bud falls back to the adult's dead sprite.
/obj/structure/flora/grass/maneater/real/juvenile/update_icon()
	. = ..()
	name = "juvenile maneater"
	if(obj_broken)
		icon = 'icons/roguetown/mob/monster/maneater.dmi'
		return
	icon_state = "juvenile_[growth_stage]"
	switch(growth_stage)
		if(1)
			desc = "A bud the size of a fist on a mat of dry roots. Its lips part now and then."
		if(2)
			desc = "A plump green bud with a seam of small teeth. It turns slowly toward movement."
		else
			desc = "A heavy bud, almost grown. A red tongue tests the air between its teeth."


//MANEATER SEEDS

/obj/item/maneaterseed
	name = "maneater seed"
	desc = "A seed from a maneater. It looks like it could grow into something dangerous if planted in green grass or dirt."
	icon = 'icons/roguetown/mob/monster/maneater.dmi'
	icon_state = "maneater-seed"
	max_integrity = 5
	sellprice = 30

/obj/item/maneaterseed/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	var/turf/T = get_turf(target)
	if(can_grow_at(T, user))
		if(!proximity_flag)
			return
		user.visible_message(span_notice("[user] begins planting a maneater seed."), \
				span_notice("I begin planting the maneater seed."))
		if(do_after(user, 10 SECONDS))
			var/obj/structure/flora/grass/maneater/real/juvenile/myboy = new(T)
			myboy.planter = user
			user.visible_message(span_notice("[user] plants a maneater seed."), \
				span_notice("I plant the maneater seed."))
			qdel(src)
			message_admins("[user]/([user.ckey]) plants a maneater seed at [ADMIN_VERBOSEJMP(T)]")
			return
	. = ..()

/obj/item/maneaterseed/proc/can_grow_at(turf/target, mob/user)
	if(!istype(target, /turf/open/floor/dirt) && !istype(target, /turf/open/floor/grass))
		return FALSE
	for(var/obj/structure/flora/grass/maneater/maneater in target)
		if(user)
			to_chat(user, span_warning("The maneater plants need more space between them to grow."))
		return FALSE
	for(var/turf/adjacent in orange(2, target))
		for(var/obj/structure/flora/grass/maneater/maneater in adjacent)
			if(user)
				to_chat(user, span_warning("The maneater plants need more space between them to grow."))
			return FALSE
	for(var/obj/effect/decal/uneven_ground in target) // Prevent planting on mapped cobble decals, etc.
		if(user)
			to_chat(user, span_warning("The ground is too uneven to plant a maneater seed here."))
		return FALSE
	return TRUE

/// Eggs laid by stomach vines hatch as damp seedlings. On natural soil they take root by themselves;
/// elsewhere they remain portable and can be planted exactly like an ordinary maneater seed.
/obj/item/maneaterseed/seedling
	name = "maneater seedling"
	desc = "A newly hatched tangle of hungry roots. It will take root on green grass or dirt."

/obj/item/maneaterseed/seedling/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(try_take_root)), 2 SECONDS, TIMER_DELETE_ME)

/obj/item/maneaterseed/seedling/proc/try_take_root()
	var/turf/rooting_turf = get_turf(src)
	if(loc != rooting_turf || !can_grow_at(rooting_turf))
		return
	visible_message(span_warning("[src] splits open and drives pale roots into [rooting_turf]!"))
	new /obj/structure/flora/grass/maneater/real/juvenile(rooting_turf)
	qdel(src)

/obj/structure/flora/grass/maneater/real/proc/produce_seed()
	visible_message(span_warning("[src] spits out a seed!"))
	var/turf/target = get_ranged_target_turf(src, pick(GLOB.alldirs), rand(1,3))
	var/obj/item/maneaterseed/S = new(get_turf(src))
	S.throw_at(target,3,2)
	playsound(src,'sound/misc/maneaterspit.ogg', 100)
