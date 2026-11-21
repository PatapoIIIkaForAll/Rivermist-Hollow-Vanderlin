/// A victim ambushed moments ago must still be snatched, even with plain grass rustling first.
/datum/unit_test/maneater_snatches_recently_ambushed

/datum/unit_test/maneater_snatches_recently_ambushed/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/target = get_step(start, EAST)
	allocate(/obj/structure/flora/grass, target)
	var/obj/structure/flora/grass/maneater/real/maneater = allocate(/obj/structure/flora/grass/maneater/real, target)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, start)
	victim.mind_initialize()
	victim.m_intent = MOVE_INTENT_WALK
	MOBTIMER_SET(victim, MT_AMBUSHLAST)

	var/walk_started = world.time
	victim.Move(target, get_dir(victim, target))
	var/walk_time = world.time - walk_started
	var/snatched = victim.buckled == maneater

	// Pulling the victim off the tile fails the chew do_after, ending the loop before teardown.
	if(victim.buckled)
		maneater.unbuckle_mob(victim, TRUE)
	victim.forceMove(start)
	sleep(2)

	TEST_ASSERT(snatched, "The maneater ignored a victim who had just been ambushed.")
	TEST_ASSERT_EQUAL(walk_time, 0, "The maneater's meal slept inside the victim's Move().")

/// Chews must leave lasting injuries, because bodypart brute is rebuilt from the injury list.
/datum/unit_test/maneater_chew_injures_carbon

/datum/unit_test/maneater_chew_injures_carbon/Run()
	var/obj/structure/flora/grass/maneater/real/maneater = allocate(/obj/structure/flora/grass/maneater/real)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)

	TEST_ASSERT_EQUAL(maneater.chew_victim(victim, 0), maneater.chew_damage, "An unarmored chew reported the wrong damage.")
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), maneater.chew_damage, "A chew left no lasting brute on the victim.")

	maneater.chew_victim(victim, 100)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), maneater.chew_damage + maneater.bite_damage, "A big bite left no lasting brute on the victim.")
	TEST_ASSERT_EQUAL(maneater.seednutrition, 25, "A big bite did not feed the maneater.")

/// Limb armor must stop an ordinary chew, while a big bite still goes through it.
/datum/unit_test/maneater_armor_stops_chew_not_bite

/datum/unit_test/maneater_armor_stops_chew_not_bite/Run()
	var/obj/structure/flora/grass/maneater/real/maneater = allocate(/obj/structure/flora/grass/maneater/real)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/armor/chainmail/hauberk/hauberk = allocate(/obj/item/clothing/armor/chainmail/hauberk)
	TEST_ASSERT(victim.equip_to_slot_if_possible(hauberk, ITEM_SLOT_ARMOR, disable_warning = TRUE, bypass_equip_delay_self = TRUE), "Setup failed: the hauberk must go on.")
	for(var/zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		TEST_ASSERT(victim.get_armor_protection_tier(zone, BCLASS_CUT) > ARMOR_TIER_NONE, "Setup failed: the hauberk must cover [zone].")

	TEST_ASSERT_EQUAL(maneater.chew_victim(victim, 0), 0, "Armor failed to stop an ordinary chew.")
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "An armored limb took brute from an ordinary chew.")

	maneater.chew_victim(victim, 100)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), maneater.bite_damage, "A big bite should ignore armor.")

/// A victim missing every limb must still be chewed, on the torso, without a runtime.
/datum/unit_test/maneater_chews_torso_without_limbs

/datum/unit_test/maneater_chews_torso_without_limbs/Run()
	var/obj/structure/flora/grass/maneater/real/maneater = allocate(/obj/structure/flora/grass/maneater/real)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	for(var/zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/obj/item/bodypart/limb = victim.get_bodypart(zone)
		limb.drop_limb()
		qdel(limb)

	var/caught = FALSE
	try
		maneater.chew_victim(victim, 0)
	catch
		caught = TRUE
	TEST_ASSERT(!caught, "Chewing a victim with no limbs runtimed.")
	var/obj/item/bodypart/chest = victim.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(chest.brute_dam, maneater.chew_damage, "A victim with no limbs was not chewed on the torso.")

/// A meal counts only damage the plant dealt, so old wounds must not end it before a chew lands.
/datum/unit_test/maneater_meal_ignores_old_wounds

/datum/unit_test/maneater_meal_ignores_old_wounds/Run()
	var/obj/structure/flora/grass/maneater/real/maneater = allocate(/obj/structure/flora/grass/maneater/real)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/chest = victim.get_bodypart(BODY_ZONE_CHEST)
	chest.create_injury(WOUND_SLASH, 30)
	chest.update_damages()
	var/old_brute = victim.getBruteLoss()
	TEST_ASSERT(old_brute > maneater.spit_threshold, "Setup failed: the victim must start above the spit threshold.")

	maneater.chew_interval = 1
	TEST_ASSERT(maneater.buckle_mob(victim, TRUE, check_loc = FALSE), "Setup failed: the victim must be buckled.")
	INVOKE_ASYNC(maneater, TYPE_PROC_REF(/obj/structure/flora/grass/maneater/real, begin_eat), victim)
	for(var/i in 1 to 50)
		if(victim.buckled != maneater)
			break
		sleep(1)

	var/meal_damage = victim.getBruteLoss() - old_brute
	TEST_ASSERT(victim.buckled != maneater, "The maneater never finished its meal.")
	TEST_ASSERT(meal_damage > maneater.spit_threshold, "The maneater spat out its victim after only [meal_damage] meal damage.")
	TEST_ASSERT(meal_damage <= maneater.spit_threshold + maneater.bite_damage, "The maneater kept chewing after the meal ended: [meal_damage] meal damage.")

/// Mapgen maneaters must spawn showing their dormant sprite, not a random state their icon lacks.
/datum/unit_test/maneater_spawns_dormant_sprite

/datum/unit_test/maneater_spawns_dormant_sprite/Run()
	for(var/maneater_type in list(/obj/structure/flora/grass/maneater, /obj/structure/flora/grass/maneater/real))
		var/obj/structure/flora/grass/maneater/maneater = allocate(maneater_type)
		TEST_ASSERT_EQUAL(maneater.icon_state, "maneater-hidden", "[maneater_type] spawned with a random grass icon state.")

/// The vines take gear first, then clothes by slot, tear stockings in place, keep jewellery, and swallow only once done.
/datum/unit_test/maneater_strips_swallowed_victim
	needs_pocket_space = TRUE

/datum/unit_test/maneater_strips_swallowed_victim/Run()
	var/obj/structure/flora/grass/maneater/real/maneater = allocate(/obj/structure/flora/grass/maneater/real)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	for(var/obj/item/default_wear in list(victim.underwear, victim.bra, victim.undershirt, victim.legwear_socks))
		qdel(default_wear)
	var/obj/item/clothing/cloak/raincloak/cloak = allocate(/obj/item/clothing/cloak/raincloak)
	var/obj/item/clothing/pants/trou/trousers = allocate(/obj/item/clothing/pants/trou)
	var/obj/item/storage/belt/leather/belt = allocate(/obj/item/storage/belt/leather)
	var/obj/item/clothing/wrists/bracers/bracers = allocate(/obj/item/clothing/wrists/bracers)
	var/obj/item/clothing/legwears/white/stockings = allocate(/obj/item/clothing/legwears/white)
	var/obj/item/clothing/face/spectacles/spectacles = allocate(/obj/item/clothing/face/spectacles)
	var/obj/item/clothing/ring/silver/ring = allocate(/obj/item/clothing/ring/silver)
	var/obj/item/clothing/neck/goldamulet/amulet = allocate(/obj/item/clothing/neck/goldamulet)
	var/obj/item/clothing/garter/garter = allocate(/obj/item/clothing/garter)
	var/list/outfit = list()
	outfit[stockings] = ITEM_SLOT_SOCKS
	outfit[trousers] = ITEM_SLOT_PANTS
	outfit[belt] = ITEM_SLOT_BELT
	outfit[cloak] = ITEM_SLOT_CLOAK
	outfit[bracers] = ITEM_SLOT_WRISTS
	outfit[spectacles] = ITEM_SLOT_MASK
	outfit[ring] = ITEM_SLOT_RING
	outfit[amulet] = ITEM_SLOT_NECK
	outfit[garter] = ITEM_SLOT_GARTER
	for(var/obj/item/piece as anything in outfit)
		TEST_ASSERT(victim.equip_to_slot_if_possible(piece, outfit[piece], disable_warning = TRUE, bypass_equip_delay_self = TRUE), "Setup failed: [piece.type] must go on.")
	TEST_ASSERT(maneater.buckle_mob(victim, TRUE, check_loc = FALSE), "Setup failed: the victim must be buckled.")
	maneater.horny_victim_ref = WEAKREF(victim)
	var/bracers_integrity = bracers.get_integrity()

	var/list/expected = list(belt, cloak, bracers, trousers, stockings)
	for(var/obj/item/piece as anything in expected)
		TEST_ASSERT_EQUAL(maneater.strip_next_garment(), piece, "The vines took the wrong piece.")
		TEST_ASSERT(maneater.strip_timer, "Stripping stopped while clothes remained.")
		maneater.stop_stripping()
	TEST_ASSERT(!maneater.strip_next_garment(), "The vines found something to take on a stripped victim.")
	TEST_ASSERT_NULL(maneater.strip_timer, "Stripping kept ticking with nothing left to strip.")
	TEST_ASSERT_EQUAL(victim.buckled, maneater, "The plant swallowed before swallow_time was up.")

	for(var/obj/item/piece as anything in list(belt, cloak, bracers, trousers))
		TEST_ASSERT(piece.loc != victim, "[piece.type] is still worn after the strip.")
	for(var/obj/item/piece as anything in list(spectacles, ring, amulet, garter, stockings))
		TEST_ASSERT_EQUAL(piece.loc, victim, "[piece.type] should stay on the victim.")
	TEST_ASSERT(stockings.obj_broken, "The stockings were not torn.")
	TEST_ASSERT(cloak.get_integrity() < cloak.max_integrity, "The cloth cloak came off untorn.")
	TEST_ASSERT(!cloak.obj_broken, "The tear broke the cloak.")
	TEST_ASSERT_EQUAL(bracers.get_integrity(), bracers_integrity, "Metal bracers should come off undamaged.")

	// A late garment holds the swallow until it is off.
	var/obj/item/clothing/cloak/raincloak/late_cloak = allocate(/obj/item/clothing/cloak/raincloak)
	TEST_ASSERT(victim.equip_to_slot_if_possible(late_cloak, ITEM_SLOT_CLOAK, disable_warning = TRUE, bypass_equip_delay_self = TRUE), "Setup failed: the second cloak must go on.")
	maneater.strip_interval = 1
	maneater.swallow_time_up()
	TEST_ASSERT(late_cloak.loc != victim, "The due swallow did not strip the last garment first.")
	TEST_ASSERT_EQUAL(victim.buckled, maneater, "The plant swallowed a victim who still had clothes on.")
	for(var/i in 1 to 50)
		if(victim.buckled != maneater)
			break
		sleep(1)
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/maneater/stomach = captivity?.resolve_instance()
	if(stomach)
		victim.remove_status_effect(/datum/status_effect/defeat_knockout)
		captivity.release_to_context()
		SSpocket_dimensions.delete_instance(stomach)
	TEST_ASSERT_NOTNULL(stomach, "The plant did not swallow once the strip was done and the time was up.")

/// A swallow fills the stomach: the plant shows its full sprite, and the greater vines root in a grassless stomach.
/datum/unit_test/maneater_full_while_occupied
	needs_pocket_space = TRUE

/datum/unit_test/maneater_full_while_occupied/Run()
	var/obj/structure/flora/grass/maneater/real/maneater = allocate(/obj/structure/flora/grass/maneater/real)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	TEST_ASSERT(maneater.buckle_mob(victim, TRUE, check_loc = FALSE), "Setup failed: the victim must be buckled.")
	maneater.horny_victim_ref = WEAKREF(victim)
	TEST_ASSERT(maneater.complete_horny_swallow(), "The maneater failed to swallow its victim.")
	var/datum/component/kidnap_captivity/captivity = victim.GetComponent(/datum/component/kidnap_captivity)
	var/datum/pocket_dimension/defeat_captivity/maneater/stomach = captivity?.resolve_instance()
	TEST_ASSERT_NOTNULL(stomach, "The victim did not land in a maneater stomach.")
	TEST_ASSERT_EQUAL(maneater.icon_state, "maneater-full", "A plant with someone inside must show its full sprite.")

	var/greater_vines = 0
	for(var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/big/vine in stomach.get_occupants())
		if(vine.stat != DEAD)
			greater_vines++
	TEST_ASSERT_EQUAL(greater_vines, 2, "The stomach should grow one greater vine at each mapped root.")
	for(var/turf/stomach_turf as anything in stomach.affected_turfs)
		TEST_ASSERT(!(locate(/obj/structure/flora/grass) in stomach_turf), "The stomach map must not contain grass.")

	var/list/stomach_vines = list()
	for(var/mob/living/simple_animal/hostile/retaliate/tentacle/ambusher/maneater/vine in stomach.get_occupants())
		stomach_vines += vine
	TEST_ASSERT(length(stomach_vines) > greater_vines, "Setup failed: the stomach should also hold lesser vines.")

	victim.remove_status_effect(/datum/status_effect/defeat_knockout)
	TEST_ASSERT(captivity.release_to_context(), "Setup failed: the captive must be released.")
	TEST_ASSERT_NOTEQUAL(maneater.icon_state, "maneater-full", "An empty stomach must drop the full sprite.")
	SSpocket_dimensions.delete_instance(stomach)
	for(var/mob/living/vine as anything in stomach_vines)
		TEST_ASSERT(QDELETED(vine), "[vine.type] outlived its stomach at [vine.x],[vine.y],[vine.z].")
