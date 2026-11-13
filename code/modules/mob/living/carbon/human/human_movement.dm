/mob/living/carbon/human/get_movespeed_modifiers()
	var/list/considering = ..()
	. = considering
	if(HAS_TRAIT(src, TRAIT_IGNORESLOWDOWN))
		for(var/id in .)
			var/list/data = .[id]
			if(data[MOVESPEED_DATA_INDEX_FLAGS] & IGNORE_NOSLOW)
				.[id] = data

/mob/living/carbon/human/slip(knockdown_amount, obj/O, lube, paralyze, forcedrop)
	if(HAS_TRAIT(src, TRAIT_NOSLIPALL))
		return 0
	if (!(lube&GALOSHES_DONT_HELP))
		if(HAS_TRAIT(src, TRAIT_NOSLIPWATER))
			return 0
		if(shoes && istype(shoes, /obj/item/clothing))
			var/obj/item/clothing/CS = shoes
			if (CS.clothing_flags & NOSLIP)
				return 0
	return ..()

/mob/living/carbon/human/Move(NewLoc, direct)
/*	if(fixedeye || tempfixeye)
		switch(dir)
			if(NORTH)
				if(direct == WEST|EAST)
					OffBalance(30)
			if(SOUTH)
				if(direct == WEST|EAST)
					OffBalance(30)
			if(EAST)
				if(direct == NORTH|SOUTH)
					OffBalance(30)
			if(WEST)
				if(direct == NORTH|SOUTH)
					OffBalance(30)*/

	if(buckled && buckled.loc != NewLoc)
		var/datum/component/bellyriding/belly_comp = buckled.GetComponent(/datum/component/bellyriding)
		if(belly_comp?.current_victim == src)
			belly_comp.start_victim_escape(src)
			return FALSE

	. = ..()
	if(loc == NewLoc)
		if(wear_armor)
			if(body_position != LYING_DOWN)
				var/obj/item/clothing/C = wear_armor
				C.step_action()

		if(wear_neck)
			if(body_position != LYING_DOWN && istype(wear_neck, /obj/item/clothing))
				var/obj/item/clothing/N = wear_neck
				N.step_action()

		if(wear_shirt)
			if(body_position != LYING_DOWN)
				var/obj/item/clothing/C = wear_shirt
				C.step_action()

		if(cloak)
			if(body_position != LYING_DOWN)
				var/obj/item/clothing/C = cloak
				C.step_action()

		if(shoes)
			if(body_position != LYING_DOWN)
				var/obj/item/clothing/shoes/S = shoes

				//Bloody footprints
				var/turf/T = get_turf(src)
				if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
					for(var/obj/effect/decal/cleanable/blood/footprints/oldFP in T)
						if (oldFP.blood_state == S.blood_state)
							return
					//No oldFP or they're all a different kind of blood
					S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state] - BLOOD_LOSS_PER_STEP)
					if (S.bloody_shoes[S.blood_state] > BLOOD_LOSS_IN_SPREAD)
						var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
						FP.blood_state = S.blood_state
						FP.entered_dirs |= dir
						FP.bloodiness = S.bloody_shoes[S.blood_state] - BLOOD_LOSS_IN_SPREAD
						FP.add_blood_DNA(GET_ATOM_BLOOD_DNA(S))
					update_inv_shoes()
				//End bloody footprints
				S.step_action()
		if(mouth)
			if(mouth.spitoutmouth && prob(5))
				visible_message("<span class='warning'>[src] spits out [mouth].</span>")
				dropItemToGround(mouth, silent = FALSE)
		if(held_items.len)
			for(var/obj/item/I in held_items)
				if(I.minstr)
					var/effective = I.minstr
					if(HAS_TRAIT(I, TRAIT_WIELDED))
						if(HAS_TRAIT(src, TRAIT_TINY))
							effective *= 0.75
					if(effective > GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH))
						if(prob(effective))
							dropItemToGround(I, silent = FALSE)

// ===== MOUNTING PONIES =====

/mob/living/carbon/human/relaymove(mob/user, direction)
	var/datum/component/bellyriding/belly_comp = GetComponent(/datum/component/bellyriding)
	if(belly_comp?.current_victim == user)
		belly_comp.start_victim_escape(user)
		return FALSE

	if(HAS_TRAIT(src, TRAIT_PONYGIRL_RIDEABLE))
		return relaydrive(user, direction)
	return ..()

/mob/living/carbon/human/Knockdown(amount, updating = TRUE)
	. = ..() // parent Knockdown
	if(HAS_TRAIT(src, TRAIT_PONYGIRL_RIDEABLE) && buckled_mobs)
		for(var/mob/living/carbon/human/rider in buckled_mobs)
			unbuckle_mob(rider, TRUE)
			to_chat(rider, span_warning("You fall off [src] as they collapse!"))
			to_chat(src, span_warning("[rider] tumbles off you as you fall!"))

/mob/living/carbon/human/attackby(obj/item/I, mob/living/user, params)
	var/mob/living/carbon/human/mount = get_pony_mount()
	if(mount)
		visible_message(span_warning("[user]'s attack is redirected to [mount]'s chest!"))
		user.zone_selected = BODY_ZONE_CHEST
		return mount.attackby(I, user, params)
	return ..()

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	var/mob/living/carbon/human/mount = get_pony_mount()
	if(mount)
		visible_message(span_warning("[M]'s attack is redirected to [mount]!"))
		mount.attack_animal(M)
		return TRUE
	return ..()

/mob/living/carbon/human/bullet_act(obj/projectile/P)
	var/mob/living/carbon/human/mount = get_pony_mount()
	if(mount)
		visible_message(span_warning("The [P] is redirected to [mount]!"))
		return mount.bullet_act(P)
	return ..()
