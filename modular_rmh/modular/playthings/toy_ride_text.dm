// Words for toy riding: verbs by force, surface tails, feel by fit, and the start, finish and climax lines.

/// Feel share bands, cut where births cut them.
#define RIDE_FEELS_GOOD(share) ((share) >= 0.66)
#define RIDE_FEELS_MIXED(share) ((share) > 0.33)
/// Cycles a metal or stone toy still feels cold.
#define RIDE_COLD_CYCLES 3

/// A self ride's motion as list(room words, my words), picked by force.
/datum/sex_action/object_fuck/ride/proc/get_ride_verbs(mob/living/rider)
	var/their = rider.p_their()
	var/them = rider.p_them()
	switch(force)
		if(SEX_FORCE_LOW)
			return pick(
				list("rolls [their] hips in slow circles on", "roll my hips in slow circles on"),
				list("lifts until only the tip is left, then sinks slowly back down on", "lift until only the tip is left, then sink slowly back down on"),
				list("grinds lazily down on", "grind lazily down on"),
				list("rocks gently back and forth on", "rock gently back and forth on"),
			)
		if(SEX_FORCE_MID)
			return pick(
				list("rides", "ride"),
				list("bounces steadily on", "bounce steadily on"),
				list("works [them]self up and down on", "work myself up and down on"),
				list("sinks all the way down to the base of", "sink all the way down to the base of"),
			)
		if(SEX_FORCE_HIGH)
			return pick(
				list("drops [their] full weight onto", "drop my full weight onto"),
				list("bounces hard on", "bounce hard on"),
				list("slams [their] hips down on", "slam my hips down on"),
				list("rides hard and fast on", "ride hard and fast on"),
			)
	return pick(
		list("impales [them]self over and over on", "impale myself over and over on"),
		list("hammers [their] hips down onto", "hammer my hips down onto"),
		list("rides with wild abandon on", "ride with wild abandon on"),
		list("slams down to the very base of", "slam down to the very base of"),
	)

/// A forced ride's motion as list(their words, my words); %T is the rider, %O as object, %P possessive.
/datum/sex_action/object_fuck/ride/proc/get_forced_verbs()
	switch(force)
		if(SEX_FORCE_LOW)
			return pick(
				list("guides %T slowly up and down on", "guide %T slowly up and down on"),
				list("eases %T down onto", "ease %T down onto"),
				list("rocks %T gently on", "rock %T gently on"),
				list("lifts %T by the hips and lets %O sink back down on", "lift %T by the hips and let %O sink back down on"),
			)
		if(SEX_FORCE_MID)
			return pick(
				list("bounces %T on", "bounce %T on"),
				list("works %T up and down on", "work %T up and down on"),
				list("pushes %T down onto", "push %T down onto"),
				list("holds %T by the waist and bounces %O on", "hold %T by the waist and bounce %O on"),
			)
		if(SEX_FORCE_HIGH)
			return pick(
				list("shoves %T down onto", "shove %T down onto"),
				list("bounces %T hard on", "bounce %T hard on"),
				list("drags %P hips down onto", "drag %P hips down onto"),
				list("pushes down on %P shoulders, driving %O onto", "push down on %P shoulders, driving %O onto"),
			)
	return pick(
		list("slams %T down to the base of", "slam %T down to the base of"),
		list("hammers %T down onto", "hammer %T down onto"),
		list("forces %T down hard, again and again, on", "force %T down hard, again and again, on"),
		list("bears down on %P shoulders and impales %O on", "bear down on %P shoulders and impale %O on"),
	)

/// Fills a forced-ride template for the room, or for the rider reading it.
/proc/fill_forced_ride_words(text, mob/living/rider, for_rider)
	text = replacetext(text, "%T", for_rider ? "me" : "[rider]")
	text = replacetext(text, "%O", for_rider ? "me" : rider.p_them())
	return replacetext(text, "%P", for_rider ? "my" : "[rider]'s")

/// A clause for where the ride happens, with its leading comma.
/datum/sex_action/object_fuck/ride/proc/get_surface_tail(mob/living/rider, kind, first_person)
	var/them = first_person ? "me" : rider.p_them()
	var/their = first_person ? "my" : rider.p_their()
	switch(kind)
		if("chair")
			return pick(", the chair creaking beneath [them]", ", gripping the arms of the chair")
		if("stool")
			return ", the stool rocking under [them]"
		if("bench")
			return pick(", straddling the bench", ", the bench groaning under [them]")
		if("bed")
			return pick(", the mattress bouncing under [their] knees", ", the bedframe shaking")
		if("table")
			return pick(", crouched atop the table for anyone to see", ", the table thumping under [them]")
	return pick(", squatting low over the floorboards", ", knees spread wide on the floor")

/// The rider's private sense of the ride, from fit, wetness, wear, shape and material.
/datum/sex_action/object_fuck/ride/proc/get_ride_feel(mob/living/rider, obj/item/dildo/toy, datum/orifice/opening)
	var/list/parts = list()
	var/share = 0.5
	if(opening && iscarbon(rider))
		var/mob/living/carbon/carbon_rider = rider
		share = carbon_rider.get_birth_pleasure_share(opening, toy.get_insert_girth())
	if(RIDE_FEELS_GOOD(share))
		parts += span_love(forced ? pick("My body takes it eagerly, no matter who is pushing.", "I can't help bouncing along.", "Every push fills me just right.") : pick("It fills me just right.", "Every bounce hits that perfect spot.", "It stretches me exactly the way I like."))
	else if(RIDE_FEELS_MIXED(share))
		parts += span_notice(forced ? pick("I gasp at the stretch each time I'm pushed down.", "It's a lot, and I'm not the one setting the pace.") : pick("The stretch burns sweetly.", "I have to slow down to take it all.", "It's a lot. Almost too much."))
	else
		parts += span_warning(forced ? pick("It's too big. Being forced down on it hurts.", "I squirm, but I'm held impaled on it.") : pick("It splits me open every time I sink down.", "Too big; my thighs shake with each drop.", "It hurts, a deep ache with every inch."))
	if(opening)
		if(opening.gives_no_resistance())
			parts += span_love("My [opening.opening_name] is so loose it slides in with no resistance at all.")
		else if(opening.get_soreness_state() >= ORIFICE_STATE_RAW)
			parts += span_warning("My [opening.opening_name] is raw and burning.")
		else if(opening.sounds_dry())
			parts += span_warning("It drags dry and rough.")
		else if(opening.get_lube_id() == "slick" && prob(50))
			parts += span_love("It squelches lewdly every time I move.")
	if(prob(35))
		switch(toy.dildo_type)
			if("knotted")
				parts += span_love(rider.has_status_effect(/datum/status_effect/toy_stuck) ? "The knot tugs at me from inside on every movement." : "The knot presses at my entrance each time I bottom out.")
			if("flared")
				parts += span_love("The flared head drags along my insides on every rise.")
			if("human")
				parts += span_love("I feel every carved ridge of the shaft.")
	var/material_line = get_material_feel(toy)
	if(material_line)
		parts += span_notice(material_line)
	return jointext(parts, " ")

/// How the toy's material feels; cold metal warms up after a few cycles.
/datum/sex_action/object_fuck/ride/proc/get_material_feel(obj/item/dildo/toy)
	var/early = ride_cycles <= RIDE_COLD_CYCLES
	switch(toy.dildo_material)
		if("iron", "steel", "silver", "copper", "stone")
			if(early)
				return "The [toy.dildo_material] is cold inside me."
			if(ride_cycles == RIDE_COLD_CYCLES + 1)
				return "The [toy.dildo_material] has warmed to my heat."
		if("golden")
			if(early || prob(10))
				return "Heavy, smooth gold fills me."
		if("wooden")
			if(early || prob(10))
				return "The polished grain catches, just a little."
		if("glass")
			if(early || prob(10))
				return "Cool, slick glass slides in and out."
	return null

/// A note on what the rider wears over their groin, with its leading space, or "".
/datum/sex_action/object_fuck/ride/proc/get_garment_note(mob/living/rider, obj/item/dildo/toy)
	if(!ishuman(rider))
		return ""
	var/mob/living/carbon/human/human_rider = rider
	var/obj/item/clothing/garment = get_covering_soft_garment(human_rider, BODY_ZONE_PRECISE_GROIN)
	if(!garment)
		return ""
	if(garment == human_rider.underwear)
		return " [rider.p_they(TRUE)] tug[rider.p_s()] [rider.p_their()] [garment.name] aside first."
	if(istype(garment, /obj/item/clothing/pants) && !istype(garment, /obj/item/clothing/pants/skirt))
		return " [rider.p_they(TRUE)] shove[rider.p_s()] [rider.p_their()] [garment.name] down to [rider.p_their()] knees first."
	return " [rider.p_their(TRUE)] [garment.name] pools around [rider.p_their()] hips and hides \the [toy] from view."

/// One riding cycle in words: a short room line, and a fuller one for the rider.
/datum/sex_action/object_fuck/ride/proc/show_ride_cycle_message(mob/living/user, mob/living/rider, obj/item/dildo/toy, datum/orifice/opening, kind)
	var/feel = get_ride_feel(rider, toy, opening)
	if(forced)
		if(edging_other)
			user.visible_message(spanify_force("[user] holds [rider] hovering above \the [toy], letting only the tip in."), spanify_force("I hold [rider] hovering above \the [toy], letting only the tip in."), ignored_mobs = list(rider))
			to_chat(rider, "[spanify_force("[user] holds me hovering above \the [toy], letting only the tip in.")] [span_love("I squirm for more.")]")
			return
		var/list/verbs = get_forced_verbs()
		var/tail = get_surface_tail(rider, kind, FALSE)
		user.visible_message(spanify_force("[user] [fill_forced_ride_words(verbs[1], rider, FALSE)] \the [toy][tail]."), spanify_force("I [fill_forced_ride_words(verbs[2], rider, FALSE)] \the [toy][tail]."), ignored_mobs = list(rider))
		to_chat(rider, "[spanify_force("[user] [fill_forced_ride_words(verbs[1], rider, TRUE)] \the [toy][get_surface_tail(rider, kind, TRUE)].")] [feel]")
		return
	var/list/verbs = get_ride_verbs(rider)
	var/room = "[rider] [verbs[1]] \the [toy][get_surface_tail(rider, kind, FALSE)]."
	var/obj/item/clothing/garment = ishuman(rider) ? get_covering_soft_garment(rider, BODY_ZONE_PRECISE_GROIN) : null
	if(garment && !istype(garment, /obj/item/clothing/pants) && prob(20))
		room = "Beneath [rider]'s [garment.name], only the wet sounds give away what [rider.p_theyre()] doing on \the [toy]."
	rider.visible_message(spanify_force(room), "[spanify_force("I [verbs[2]] \the [toy][get_surface_tail(rider, kind, TRUE)].")] [feel]")

/datum/sex_action/object_fuck/ride/proc/announce_ride_start(mob/living/user, mob/living/rider)
	var/obj/item/dildo/toy = selected_toy
	var/datum/component/toy_mount/mount = toy.get_toy_mount()
	var/kind = mount?.get_surface_kind() || "floor"
	var/obj/structure/surface = mount?.get_surface()
	var/hole_word = hole_id == ORGAN_SLOT_ANUS ? "ass" : "pussy"
	var/note = get_garment_note(rider, toy)
	if(forced)
		user.visible_message(span_warning("[user] seizes [rider] by the hips and forces [rider.p_them()] down onto \the [toy]![note]"), span_warning("I seize [rider] by the hips and force [rider.p_them()] down onto \the [toy]."), ignored_mobs = list(rider))
		to_chat(rider, span_warning("[user] pushes me down onto \the [toy]. It spears into my [hole_word] before I can stop it."))
		return
	var/room
	var/self
	switch(kind)
		if("chair", "stool", "bench")
			room = "[rider] lowers [rider.p_them()]self onto \the [surface], onto \the [toy], taking it inch by inch until [rider.p_their()] thighs meet the seat."
			self = "I lower myself onto \the [toy], taking it inch by inch until my thighs meet the seat."
		if("bed")
			room = "[rider] kneels over \the [toy] on \the [surface] and sinks down onto it, the mattress dipping under [rider.p_them()]."
			self = "I kneel over \the [toy] and sink down onto it, the mattress dipping under me."
		if("table")
			room = "[rider] crouches atop \the [surface] and lowers [rider.p_their()] [hole_word] onto \the [toy], in full view of anyone who looks."
			self = "I crouch atop \the [surface] and lower my [hole_word] onto \the [toy], in full view of anyone who looks."
		else
			if(hole_id == ORGAN_SLOT_ANUS)
				room = "[rider] squats over \the [toy], reaches back to spread [rider.p_their()] cheeks and eases [rider.p_their()] ass down onto it."
				self = "I squat over \the [toy], spread my cheeks and ease my ass down onto it."
			else
				room = "[rider] squats over \the [toy], spreads [rider.p_their()] lips with two fingers and sinks down onto it."
				self = "I squat over \the [toy], spread my lips with two fingers and sink down onto it."
	rider.visible_message(span_love("[room][note]"), span_love(self))

/datum/sex_action/object_fuck/ride/proc/announce_ride_finish(mob/living/user, mob/living/rider, obj/item/dildo/toy, was_pressing, datum/orifice/opening, gaping, dry)
	if(tipped)
		return
	if(was_pressing)
		if(forced)
			user.visible_message(span_warning("[user] gives up trying to force [rider] down onto \the [toy]."))
		else
			rider.visible_message(span_warning("[rider] gives up trying to sink onto \the [toy]."))
		return
	if(rider.has_status_effect(/datum/status_effect/toy_stuck))
		if(forced)
			user.visible_message(span_warning("[user] lets go of [rider], leaving [rider.p_them()] stuck fast on \the [toy]."))
		else
			rider.visible_message(span_love("[rider] stops moving, still stuck fast on \the [toy]."), span_love("I stop moving, still stuck fast on \the [toy]."))
		return
	var/hole_word = opening?.opening_name || (hole_id == ORGAN_SLOT_ANUS ? "ass" : "pussy")
	if(forced)
		user.visible_message(span_warning("[user] hauls [rider] up off \the [toy] with a wet pop."), span_warning("I haul [rider] up off \the [toy]."), ignored_mobs = list(rider))
		to_chat(rider, span_warning("[user] hauls me up off \the [toy], leaving my [hole_word] empty and aching."))
	else if(gaping)
		rider.visible_message(span_love("[rider] climbs off \the [toy], [rider.p_their()] [hole_word] left gaping."), span_love("I climb off \the [toy], my [hole_word] left gaping."))
	else if(dry)
		rider.visible_message(span_warning("[rider] eases off \the [toy] with a wince."), span_warning("I ease off \the [toy] with a wince."))
	else
		rider.visible_message(span_love("[rider] rises off \the [toy] with a wet pop, leaving it glistening."), span_love("I rise off \the [toy] with a wet pop, leaving it glistening."))
	opening?.play_passage_sound("withdraw", 35, rider)

/// The climax line for whoever came; the rider's or the one holding them down.
/datum/sex_action/object_fuck/ride/proc/announce_ride_climax(mob/living/climaxer, mob/living/rider, obj/item/dildo/toy)
	if(climaxer != rider)
		climaxer.visible_message(span_love("[climaxer] shudders and climaxes, watching [rider] bounce on \the [toy]."))
		return
	if(forced)
		rider.visible_message(span_love("[rider] comes helplessly on \the [toy], held down by [action_user]."), span_love("I come helplessly on \the [toy], held down by [action_user]."))
		return
	if(hole_id == ORGAN_SLOT_VAGINA)
		rider.visible_message(span_love("[rider] cries out and comes, grinding down hard on \the [toy] as [rider.p_their()] juices run down the shaft to pool at its base."), span_love("I cry out and come, grinding down hard on \the [toy] as my juices run down the shaft."))
	else if(rider.getorganslot(ORGAN_SLOT_PENIS))
		rider.visible_message(span_love("[rider] shudders and spurts across [rider.p_their()] own belly, clenching tight around \the [toy]."), span_love("I shudder and spurt across my own belly, clenching tight around \the [toy]."))
	else
		rider.visible_message(span_love("[rider] trembles and comes with \the [toy] buried deep in [rider.p_their()] ass."), span_love("I tremble and come with \the [toy] buried deep in my ass."))

#undef RIDE_FEELS_GOOD
#undef RIDE_FEELS_MIXED
#undef RIDE_COLD_CYCLES
