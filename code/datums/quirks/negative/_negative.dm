/datum/quirk/negative
	abstract_type = /datum/quirk/negative
	quirk_category = QUIRK_NEGATIVE

/datum/quirk/negative/addiction
	abstract_type = /datum/quirk/negative/addiction
	var/next_sate = 0
	var/sated = TRUE
	var/time = 5 MINUTES
	var/debuff = null
	var/needsate_text
	var/sated_text = "That's much better..."
	var/unsate_time

/datum/quirk/negative/addiction/on_spawn()
	next_sate = world.time + rand(10 MINUTES, 20 MINUTES)
	return ..()

/datum/quirk/negative/addiction/on_life(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	// Skip for certain antags
	if(H.mind?.antag_datums)
		for(var/datum/antagonist/D in H.mind.antag_datums)
			if(istype(D, /datum/antagonist/vampire) || istype(D, /datum/antagonist/werewolf) || istype(D, /datum/antagonist/skeleton) || istype(D, /datum/antagonist/zombie))
				return
	var/oldsated = sated
	if(oldsated && next_sate && world.time > next_sate)
		sated = FALSE
	if(sated != oldsated)
		unsate_time = world.time
		if(needsate_text)
			to_chat(user, span_boldwarning("[needsate_text]"))
	if(!sated)
		switch(world.time - unsate_time)
			if(0 to 5 MINUTES)
				H.add_stress(/datum/stress_event/vice1)
				H.remove_stress(/datum/stress_event/vice2)
				H.remove_stress(/datum/stress_event/vice3)
			if(5 MINUTES to 15 MINUTES)
				H.add_stress(/datum/stress_event/vice2)
				H.remove_stress(/datum/stress_event/vice1)
				H.remove_stress(/datum/stress_event/vice3)
			if(15 MINUTES to INFINITY)
				H.add_stress(/datum/stress_event/vice3)
				H.remove_stress(/datum/stress_event/vice1)
				H.remove_stress(/datum/stress_event/vice2)
		if(debuff)
			H.apply_status_effect(debuff)

/mob/living/proc/sate_addiction(datum/quirk/negative/addiction/specific_vice)
	return

/mob/living/carbon/human/sate_addiction(datum/quirk/negative/addiction/specific_vice)
	specific_vice = get_quirk(specific_vice)
	if(!specific_vice || !istype(specific_vice))
		return
	specific_vice.sate(src)

/datum/quirk/negative/addiction/proc/sate(mob/living/carbon/human/user)
	user.remove_stress(list(/datum/stress_event/vice1, /datum/stress_event/vice2, /datum/stress_event/vice3))

	if(!sated)
		to_chat(user, span_blue(sated_text))

	sated = TRUE
	next_sate = world.time + time + rand(-1 MINUTES, 1 MINUTES)

	if(debuff)
		user.remove_status_effect(debuff)

/datum/quirk/negative/addiction/alcoholic
	name = "Drunkard"
	desc = "Drinking alcohol is my favorite thing."
	point_value = 2
	time = 30 MINUTES
	debuff = /datum/status_effect/debuff/addiction/alcoholic
	needsate_text = "Time for a drink."


/datum/quirk/negative/addiction/alcoholic/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Drinker..."))


/datum/quirk/negative/addiction/smoker
	name = "Smoker"
	desc = "I need to smoke something to take the edge off."
	point_value = 3
	time = 30 MINUTES
	debuff = /datum/status_effect/debuff/addiction/smoker
	needsate_text = "Time for a flavorful smoke."

/datum/quirk/negative/addiction/smoker/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Smoker..."))

/datum/quirk/negative/addiction/junkie
	name = "Junkie"
	desc = "I need a real high to take the pain of this rotten world away."
	point_value = 3
	debuff = /datum/status_effect/debuff/addiction/junkie
	needsate_text = "Time to reach a new high."

/datum/quirk/negative/addiction/junkie/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Narco..."))

/datum/quirk/negative/addiction/kleptomaniac
	name = "Thief-Borne"
	desc = "As a child I had to rely on theft to survive. Whether that changed or not, I just can't get over it."
	point_value = 4
	time = 30 MINUTES
	debuff = /datum/status_effect/debuff/addiction/kleptomaniac
	needsate_text = "I need to STEAL something! I'll die if I don't!"

/datum/quirk/negative/addiction/kleptomaniac/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Klepto..."))

/datum/quirk/negative/addiction/godfearing
	name = "Devout Follower"
	desc = "I need to pray to my Patron, their blessings are stronger."
	point_value = 1
	time = 40 MINUTES
	debuff = /datum/status_effect/debuff/addiction/godfearing
	needsate_text = "Time to pray."

/datum/quirk/negative/addiction/godfearing/on_spawn()
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_PRAY, PROC_REF(on_owner_pray))

/datum/quirk/negative/addiction/godfearing/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_CARBON_PRAY)

/datum/quirk/negative/addiction/godfearing/proc/on_owner_pray(datum/source, prayer)
	SIGNAL_HANDLER
	var/datum/patron/owner_patron = owner.patron

	if(owner_patron.hear_prayer(owner, prayer))
		owner.sate_addiction(src.type)

/datum/quirk/negative/addiction/sadist
	name = "Sadist"
	desc = "The worms call me the maniac... I just like seeing limbs fly and blood drip, is there something so BAD about that?"
	random_exempt = TRUE
	time = 40 MINUTES
	point_value = 2
	debuff = /datum/status_effect/debuff/addiction/sadist
	needsate_text = "Where's all the blood?"

/datum/quirk/negative/addiction/sadist/on_examined(mob/user, list/P, list/examine_contents)
	if(HAS_TRAIT(user, TRAIT_RECOGNIZE_ADDICTS))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, span_info("Sadist..."))
