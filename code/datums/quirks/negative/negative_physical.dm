/datum/status_effect/debuff/badvision
	id = "badvision"
	alert_type = null
	effectedstats = list(STAT_PERCEPTION = -10, STAT_SPEED = -2, STAT_FORTUNE = -5)
	duration = 5 SECONDS

/datum/quirk/negative/bad_sight
	name = "Poor Vision"
	desc = "I need spectacles to see normally from my years spent reading books."
	point_value = 2

/datum/quirk/negative/bad_sight/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	owner.adjust_skill_level(/datum/attribute/skill/misc/reading, 10)

	if(H.wear_mask)
		var/type = H.wear_mask.type
		qdel(H.wear_mask)
		H.put_in_hands(new type())
	H.equip_to_slot_or_del(new /obj/item/clothing/face/spectacles(H), ITEM_SLOT_MASK)
	H.become_nearsighted(type)

/datum/quirk/negative/bad_sight/on_remove()
	if(owner)
		owner.cure_nearsighted(type)
		owner.remove_status_effect(/datum/status_effect/debuff/badvision)
	. = ..()

/datum/quirk/negative/bad_sight/on_life(mob/living/user)
	if(!ishuman(user))
		return
	if(user.is_nearsighted_currently())
		user.apply_status_effect(/datum/status_effect/debuff/badvision)

/datum/quirk/negative/tainted_soul
	name = "Tainted Soul"
	desc = "You had an unfortunate run-in with a monster. A goblin saved you, but you've never felt the same since."
	point_value = 2
	blocked_species = list(
		/datum/species/kobold,
		/datum/species/demihuman,
		/datum/species/rakshari,
		/datum/species/rousman,
		/datum/species/goblin,
		/datum/species/orc,
	)

/datum/quirk/negative/tainted_soul/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_TAINTED_LUX, "[type]")

/datum/quirk/negative/tainted_soul/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_TAINTED_LUX, "[type]")

/datum/quirk/negative/rough_start
	name = "Rough Start"
	desc = "You begin your journey drunk, drugged, beaten, with broken legs, and spawn somewhere random in the forest."
	point_value = 4
	apply_order = 10000 ///this should always be first tbh
	incompatible_quirks = list(
		/datum/quirk/negative/lost_keys,
		/datum/quirk/positive/always_prepared,
	)
	preview_render = FALSE

/datum/quirk/negative/rough_start/on_spawn()
	if(!owner || !ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner
	if(H.reagents)
		H.reagents.add_reagent(/datum/reagent/consumable/ethanol, 15)

	if(H.reagents)
		H.reagents.add_reagent(/datum/reagent/drug/space_drugs, 15)

	for(var/i = 1 to 4)
		H.adjustBruteLoss(rand(9, 14), damage_type = BCLASS_BLUNT)
	var/obj/item/bodypart/l_leg/left = H.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/r_leg/right = H.get_bodypart(BODY_ZONE_R_LEG)

	if(left)
		var/datum/wound/fracture/F = left.add_wound(/datum/wound/fracture)
		if(F)
			F.whp = 10
	if(right)
		var/datum/wound/fracture/F = right.add_wound(/datum/wound/fracture)
		if(F)
			F.whp = 10

	var/list/spawn_points = list()
	for(var/obj/effect/landmark/start/adventurerlate/L in GLOB.start_landmarks_list)
		spawn_points += get_turf(L)

	if(length(spawn_points))
		var/turf/spawn_turf = pick(spawn_points)
		H.forceMove(spawn_turf)
	else
		for(var/obj/effect/landmark/start/L in GLOB.start_landmarks_list)
			spawn_points += get_turf(L)
		if(length(spawn_points))
			H.forceMove(pick(spawn_points))

	to_chat(H, span_danger("You awaken battered and broken in an unfamiliar place..."))

/datum/quirk/negative/lost_keys
	name = "Lost Keys"
	desc = "You've lost your keys! They're somewhere nearby, and you spawn at a vagrant location."
	point_value = 1
	incompatible_quirks = list(
		/datum/quirk/negative/rough_start,
	)
	preview_render = FALSE

/datum/quirk/negative/lost_keys/on_spawn()
	if(!owner || !ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner

	// Move owner to vagrant spawn first
	var/list/vagrant_spawns = list()
	for(var/obj/effect/landmark/start/adventurerlate/V in GLOB.start_landmarks_list)
		vagrant_spawns += get_turf(V)

	if(length(vagrant_spawns))
		H.forceMove(pick(vagrant_spawns))

	to_chat(H, span_warning("Where did I leave my keys?"))

/datum/quirk/negative/lost_keys/after_job_spawn(datum/job/job)
	if(!owner || !ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner

	// Find all keys on the player
	var/list/found_keys = list()
	for(var/obj/item/key/K in H.get_all_contents())
		found_keys += K

	if(!length(found_keys))
		return

	// Move keys to random nearby location
	var/list/nearby_turfs = list()
	for(var/turf/T in range(20, H))
		if(T.density)
			continue
		nearby_turfs += T

	if(length(nearby_turfs))
		for(var/obj/item/key/K in found_keys)
			var/turf/key_location = pick(nearby_turfs)
			K.forceMove(key_location)

/datum/quirk/negative/nightmares
	name = "Nitemares"
	desc = "You suffer from terrible nitemares. You scream in your sleep and take longer to rest."
	point_value = 1
	var/next_scream = 0

/datum/quirk/negative/nightmares/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Nitemares..."))

/datum/quirk/negative/nightmares/on_spawn()
	if(!owner)
		return
	START_PROCESSING(SSobj, src)

/datum/quirk/negative/nightmares/process()
	if(!owner)
		return

	if(owner.stat == UNCONSCIOUS && owner.IsSleeping())
		if(world.time >= next_scream)
			next_scream = world.time + rand(30 SECONDS, 60 SECONDS)
			owner.emote("scream")

/datum/quirk/negative/nightmares/on_remove()
	STOP_PROCESSING(SSobj, src)

/datum/stress_event/darkness
	stress_change = 2
	desc = span_red("I can't see! The darkness is terrifying!")
	timer = 1 MINUTES

/datum/quirk/negative/fear_darkness
	name = "Fear of Darkness"
	desc = "The dark terrifies you. Without light, you panic and lose control."
	point_value = 3
	var/in_darkness = FALSE
	var/next_panic = 0

/datum/quirk/negative/fear_darkness/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Scared of the Dark..."))

/datum/quirk/negative/fear_darkness/on_life(mob/living/user)
	if(!owner)
		return

	var/turf/T = get_turf(owner)
	var/light_amount = T?.get_lumcount() || 0

	var/outside = T.can_see_sky()

	var/dark = FALSE
	if(outside)
		if(light_amount < 0.15 && GLOB.tod == "night")
			dark = TRUE
	else if(light_amount < 0.15)
		dark = TRUE

	if(dark)
		if(!in_darkness)
			in_darkness = TRUE
			to_chat(owner, span_userdanger("THE DARKNESS! I CAN'T SEE!"))
			owner.add_stress(/datum/stress_event/darkness)

		if(world.time >= next_panic)
			next_panic = world.time + 8 SECONDS
			owner.emote("scream")
			var/move_dir = pick(GLOB.cardinals)
			step(owner, move_dir)

			owner.add_stress(/datum/stress_event/darkness)
	else
		if(in_darkness)
			in_darkness = FALSE
			to_chat(owner, span_notice("Finally, light! I can breathe again..."))


/datum/quirk/negative/endowed
	name = "Naturally Endowed"
	desc = "I have massive bits... This makes life hard."
	point_value = 2
	revive_reapply = TRUE

/datum/quirk/negative/endowed/on_spawn()
	var/mob/living/carbon/human/H = owner
	H.remove_status_effect(/datum/status_effect/debuff/boobs_quirk)
	H.apply_status_effect(/datum/status_effect/debuff/boobs_quirk)

/datum/quirk/negative/nopouch
	name = "No Pouch"
	desc = "I lost my pouch recently, I'm without an amna.."
	point_value = 1

/datum/quirk/negative/nopouch/after_job_spawn(datum/job/job)
	var/mob/living/carbon/human/H = owner
	var/pouch = find_pouch(H)

	if(!pouch)
		penalize_points(span_warning("No pouch found! Amaunator removed some of your traits to compensate."))
		return

	// Pouch deletion if found
	if(H.wear_neck == pouch)
		H.wear_neck = null
	if(H.beltl == pouch)
		H.beltl = null
	if(H.beltr == pouch)
		H.beltr = null
	qdel(pouch)
	to_chat(H, span_warning("I've lost my pouch... Damn it..."))

/// Proc to find pouch in inventory, including slots and containers like satchels
/datum/quirk/negative/nopouch/proc/find_pouch(mob/living/carbon/human/H)
	var/obj/item/storage/belt/pouch/inventory_pouch
	for(inventory_pouch in H.contents)
		return inventory_pouch
	for(var/obj/item/storage/storages in H.contents)
		for(inventory_pouch in storages.contents)
			return inventory_pouch
	return null

/datum/quirk/negative/wild_night
	name = "Wild Night"
	desc = "I don't remember what I did last night, and now I'm lost!"
	point_value = 1

/datum/quirk/negative/wild_night/on_spawn()
	var/mob/living/carbon/human/character = owner
	var/turf/location = get_spawn_turf_for_job("Pilgrim") || get_turf(character)
	if(location)
		character.forceMove(location)
	character.reagents.add_reagent(pick(/datum/reagent/ozium, /datum/reagent/moondust, /datum/reagent/druqks), 15)
	character.reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, 72)
	character.grant_lit_torch()

/datum/quirk/negative/atrophy
	name = "Atrophy"
	desc = "When growing up I could barely feed myself. This has left my body weak and fragile."
	point_value = 6
	defeat_threshold_mult = 0.6

/datum/quirk/negative/atrophy/on_spawn()
	var/mob/living/carbon/human/H = owner
	H.change_stat("strength", -2)
	H.change_stat("constitution", -2)
	H.change_stat("endurance", -2)

/datum/quirk/negative/monochromatic
	name = "Monochromacy"
	desc = "I see things all gray."
	point_value = 2

/datum/quirk/negative/monochromatic/on_spawn()
	. = ..()
	owner.add_client_colour(/datum/client_colour/monochrome)

/datum/quirk/negative/monochromatic/on_remove()
	. = ..()
	if(owner)
		owner.remove_client_colour(/datum/client_colour/monochrome)

/datum/quirk/negative/no_taste
	name = "Ageusia"
	desc = "I can't taste a thing."
	point_value = 1
	gain_text = span_notice("I can't taste anything!")
	lose_text = span_notice("I can taste again!")

/datum/quirk/negative/no_taste/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_AGEUSIA, "[type]")

/datum/quirk/negative/no_taste/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_AGEUSIA, "[type]")

/datum/quirk/negative/vegetarian
	name = "Vegetarian"
	desc = "I can't eat meat."
	point_value = 1
	gain_text = span_notice("I feel repulsion at the idea of eating meat.")
	lose_text = span_notice("I feel like eating meat isn't that bad.")

/datum/quirk/negative/vegetarian/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = owner
	var/datum/species/species = H.dna.species
	species.liked_food &= ~MEAT
	species.disliked_food |= MEAT

/datum/quirk/negative/vegetarian/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(H)
		var/datum/species/species = H.dna.species
		if(initial(species.liked_food) & MEAT)
			species.liked_food |= MEAT
		if(!(initial(species.disliked_food) & MEAT))
			species.disliked_food &= ~MEAT

/datum/quirk/negative/blooddeficiency
	name = "Blood Deficiency"
	desc = "My blood is not enough for me, I need to keep it in me."
	point_value = 2
	gain_text = span_danger("I feel my vigor slowly fading away.")
	lose_text = span_notice("I feel vigorous again.")

/datum/quirk/negative/blooddeficiency/on_life()
	var/mob/living/carbon/human/H = owner
	if(NOBLOOD in H.dna.species.species_traits) //can't lose blood if my species doesn't have any
		return
	else
		if (H.blood_volume > (BLOOD_VOLUME_NORMAL - 25)) // just barely survivable without treatment
			H.blood_volume -= 0.275

/datum/quirk/negative/frail
	name = "Frail"
	desc = "My bones are like sticks."
	point_value = 4
	defeat_threshold_mult = 0.6
	gain_text = span_danger("I feel frail.")
	lose_text = span_notice("I feel sturdy again.")

/datum/quirk/negative/frail/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_EASYLIMBDISABLE, "[type]")

/datum/quirk/negative/frail/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_EASYLIMBDISABLE, "[type]")

/datum/quirk/negative/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "I sleep like a rock."
	point_value = 1
	gain_text = span_danger("I feel sleepy.")
	lose_text = span_notice("I feel awake again.")

/datum/quirk/negative/heavy_sleeper/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_HEAVY_SLEEPER, "[type]")

/datum/quirk/negative/heavy_sleeper/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_HEAVY_SLEEPER, "[type]")

/datum/quirk/negative/light_drinker
	name = "Light Drinker"
	desc = "Even a drop of alcohol knocks me out."
	point_value = 1
	gain_text = span_notice("Just the thought of drinking alcohol makes my head spin.")
	lose_text = span_danger("You're no longer severely affected by alcohol.")

/datum/quirk/negative/light_drinker/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_LIGHT_DRINKER, "[type]")

/datum/quirk/negative/light_drinker/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_LIGHT_DRINKER, "[type]")

/datum/quirk/negative/poor_aim
	name = "Poor Aim"
	desc = "My aim is poor."
	point_value = 1

/datum/quirk/negative/poor_aim/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_POOR_AIM, "[type]")

/datum/quirk/negative/poor_aim/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	ADD_TRAIT(H, TRAIT_POOR_AIM, "[type]")

/datum/quirk/negative/missing_teeth
	name = "Missing Teeth"
	desc = "Years of brawling, bad luck, or bad hygiene have cost you several teeth. You lisp noticeably."
	point_value = 2
	incompatible_quirks = list(
		/datum/quirk/negative/toothless,
	)

/datum/quirk/negative/missing_teeth/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/obj/item/bodypart/mouth/jaw = H.get_bodypart(BODY_ZONE_PRECISE_MOUTH)
	if(!jaw)
		return
	var/to_remove = rand(6, 8)
	jaw.remove_teeth(to_remove)
	to_chat(H, span_warning("You run your tongue across the gaps where your teeth used to be."))

/datum/quirk/negative/no_dental
	name = "No Dental"
	desc = "My teeth are loose, brittle, or terribly neglected. A hard blow can send them flying."
	point_value = 2
	incompatible_quirks = list(
		/datum/quirk/negative/toothless,
	)

/datum/quirk/negative/no_dental/on_spawn()
	if(!ishuman(owner))
		return
	to_chat(owner, span_warning("My teeth feel worryingly loose."))

/datum/quirk/negative/toothless
	name = "Toothless"
	desc = "I have no teeth left at all. My speech and bite suffer for it."
	point_value = 3
	incompatible_quirks = list(
		/datum/quirk/negative/missing_teeth,
		/datum/quirk/negative/no_dental,
	)

/datum/quirk/negative/toothless/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/obj/item/bodypart/mouth/jaw = H.get_bodypart(BODY_ZONE_PRECISE_MOUTH)
	if(!jaw)
		return
	jaw.remove_teeth(jaw.get_teeth_amount())
	to_chat(H, span_warning("My mouth is completely bare of teeth."))
