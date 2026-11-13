// Words for grinding: start, cycle, shift, feel and climax lines.

/// What the grinder presses with: "cock", "strapon", "pussy", or "hips" with no free genitals.
/datum/sex_action/grind/proc/get_crotch_word(mob/living/grinder)
	var/obj/item/organ/organ = get_grind_organ(grinder)
	if(istype(organ, /obj/item/organ/genitals/penis))
		var/obj/item/organ/genitals/penis/penis = organ
		return penis.strapon ? "strapon" : "cock"
	if(organ)
		return "pussy"
	return "hips"

/// " through her linen skirt" for the cloth between, or "" when bare.
/datum/sex_action/grind/proc/get_clothes_suffix(mob/living/user, obj/item/clothing/own_cover, mob/living/partner, obj/item/clothing/their_cover)
	if(own_cover && their_cover)
		return " through their clothes"
	if(own_cover)
		return " through [get_through_clothes_name(user, own_cover)]"
	if(their_cover)
		return " through [get_through_clothes_name(partner, their_cover)]"
	return ""

/// The wet tail of a cycle line, now and then.
/datum/sex_action/grind/proc/get_wet_tail(mob/living/user, wet, covered)
	if(covered || !prob(33))
		return ""
	if(wet)
		return ", leaving a slick trail"
	if(is_hard_cock_grind(user))
		return ", leaking precum"
	return ""

/// Chastity turns every cycle line into denial.
/datum/sex_action/grind/proc/get_denied_line(mob/living/user, spot_text)
	var/obj/item/device = get_denial_device(user)
	return "[user] grinds desperately against [spot_text], [user.p_their()] [device?.name || "device"] denying [user.p_them()] any real touch"

/datum/sex_action/grind/proc/get_covered_climax_line(mob/living/user, obj/item/clothing/cover)
	var/their = user.p_their()
	if(get_real_organ(user, ORGAN_SLOT_PENIS) && !user.is_organ_slot_blocked(ORGAN_SLOT_PENIS))
		return "[user] stiffens and spills into [their] own [cover.name]!"
	if(user.getorganslot(ORGAN_SLOT_VAGINA))
		return "[user] trembles as a wet patch blooms on [their] [cover.name]!"
	return "[user] shudders and climaxes in [their] [cover.name]!"

// ---- Partner ----

/datum/sex_action/grind/partner/proc/announce_start(mob/living/user, mob/living/target, pose)
	var/their = user.p_their()
	var/crotch = get_crotch_word(user)
	var/spot_name = get_grind_spot_name(spot, target, from_behind)
	var/room
	var/own
	switch(spot)
		if(GRIND_SPOT_LAP)
			room = "settles into [target]'s lap, straddling [target.p_their()] thighs"
			own = "settle into [target]'s lap, straddling [target.p_their()] thighs"
		if(GRIND_SPOT_THIGH)
			room = "straddles [target]'s thigh and sinks [their] weight onto it"
			own = "straddle [target]'s thigh and sink my weight onto it"
		if(GRIND_SPOT_HAND)
			room = "presses [their] [crotch] into [target]'s palm"
			own = "press my [crotch] into [target]'s palm"
		if(GRIND_SPOT_FEET)
			room = "curls around [target]'s foot and presses [their] [crotch] against it"
			own = "curl around [target]'s foot and press my [crotch] against it"
		if(GRIND_SPOT_FACE)
			room = "lowers [their] [crotch] against [target]'s face"
			own = "lower my [crotch] against [target]'s face"
		if(GRIND_SPOT_CROTCH)
			if(from_behind)
				room = "presses up behind [target] and settles [their] [crotch] against [target.p_their()] ass"
				own = "press up behind [target] and settle my [crotch] against [target.p_their()] ass"
			else
				room = "presses [their] hips flush against [target]'s crotch"
				own = "press my hips flush against [target]'s crotch"
		if(GRIND_SPOT_BELLY)
			if(from_behind)
				room = "presses [their] [crotch] to the small of [target]'s back"
				own = "press my [crotch] to the small of [target]'s back"
	if(!room)
		room = "presses [their] [crotch] against [target]'s [spot_name]"
		own = "press my [crotch] against [target]'s [spot_name]"
	var/room_lead = ""
	var/own_lead = ""
	switch(pose)
		if("kneel")
			room_lead = "sinks to [their] knees and "
			own_lead = "sink to my knees and "
		if("toes")
			room_lead = "rises onto [their] toes and "
			own_lead = "rise onto my toes and "
		if("straddle")
			if(spot in list(GRIND_SPOT_CROTCH, GRIND_SPOT_BELLY, GRIND_SPOT_CHEST, GRIND_SPOT_ARM))
				room_lead = "kneels over [target] and "
				own_lead = "kneel over [target] and "
	if(!pose && user.body_position == LYING_DOWN && target.body_position == LYING_DOWN)
		room_lead = "lies close against [target] and "
		own_lead = "lie close against [target] and "
	user.visible_message(span_love("[user] [room_lead][room]."), span_love("I [own_lead][own]."))

/// A private note when the asked spot was out of reach.
/datum/sex_action/grind/partner/proc/note_fallback(mob/living/user, mob/living/target)
	var/asked = body_zone_to_grind_spot(asked_zone)
	if(target.get_grind_seat() && (asked == GRIND_SPOT_THIGH || asked == GRIND_SPOT_CROTCH))
		asked = GRIND_SPOT_LAP
	if(asked == spot)
		return
	var/whose = target.p_their()
	to_chat(user, span_notice("I can't reach [whose] [get_grind_spot_name(asked, target, from_behind)], so I settle for [whose] [get_grind_spot_name(spot, target, from_behind)]."))

/datum/sex_action/grind/partner/proc/announce_shift(mob/living/user, mob/living/target, old_spot)
	var/way = "over"
	if(old_spot)
		var/seated = !!target.get_grind_seat()
		var/old_height = get_grind_spot_height(old_spot, seated)
		var/new_height = get_grind_spot_height(spot, seated)
		if(new_height < old_height)
			way = "lower"
		else if(new_height > old_height)
			way = "higher"
	user.visible_message(span_love("[user] shifts [way], grinding against [target]'s [get_grind_spot_name(spot, target, from_behind)] now."))

/datum/sex_action/grind/partner/proc/get_cycle_line(mob/living/user, mob/living/target, obj/item/clothing/own_cover, obj/item/clothing/their_cover, wet)
	var/spot_name = get_grind_spot_name(spot, target, from_behind)
	if(is_denied(user))
		return "[get_denied_line(user, "[target]'s [spot_name]")]."
	var/adverb = get_generic_force_adjective()
	var/their = user.p_their()
	var/crotch = get_crotch_word(user)
	var/line
	if(spot == GRIND_SPOT_THIGH && force >= SEX_FORCE_EXTREME)
		line = "[user] humps [target]'s leg like a rutting hound"
	else
		switch(spot)
			if(GRIND_SPOT_LAP)
				line = "[user] [adverb] rolls [their] hips in [target]'s lap"
			if(GRIND_SPOT_THIGH)
				line = "[user] [adverb] rides [target]'s thigh"
			if(GRIND_SPOT_HAND)
				line = "[user] [adverb] ruts against [target]'s palm"
			if(GRIND_SPOT_FACE)
				line = "[user] [adverb] grinds [their] [crotch] over [target]'s face"
			if(GRIND_SPOT_CROTCH)
				if(from_behind && !own_cover && !their_cover && crotch == "cock")
					line = "[user] [adverb] slides [their] cock between [target]'s cheeks"
	if(!line)
		line = "[user] [adverb] grinds [their] [crotch] against [target]'s [spot_name]"
	var/covered = own_cover || their_cover
	return "[line][get_wet_tail(user, wet, covered)][get_clothes_suffix(user, own_cover, target, their_cover)]."

/// Now and then each side privately feels the grind.
/datum/sex_action/grind/partner/proc/show_feel_lines(mob/living/user, mob/living/target, obj/item/clothing/own_cover)
	if(prob(25))
		to_chat(user, span_love(is_denied(user) ? "The device keeps every touch just out of reach." : pick("The friction sends a shiver up my spine.", "Every roll of my hips drags a moan out of me.")))
	if(!prob(25))
		return
	var/spot_name = get_grind_spot_name(spot, target, from_behind)
	if(own_cover && is_hard_cock_grind(user))
		to_chat(target, span_love("I can feel how hard [user] is, even through the cloth."))
	else if(!own_cover && get_grind_pussy(user)?.reagents?.total_volume)
		to_chat(target, span_love("I can feel how wet [user] is against my [spot_name]."))
	else
		to_chat(target, span_love("[user]'s heat presses against my [spot_name]."))

// ---- Thing ----

/datum/sex_action/grind/thing/proc/announce_thing_start(mob/living/user)
	var/their = user.p_their()
	var/crotch = get_crotch_word(user)
	var/spot = user.get_grind_thing_spot(grind_thing)
	var/room
	var/own
	switch(user.get_grind_thing_pose(grind_thing))
		if("straddle")
			room = "straddles [spot] and sinks [their] weight onto it"
			own = "straddle [spot] and sink my weight onto it"
		if("climb")
			room = "clambers up and straddles [spot]"
			own = "clamber up and straddle [spot]"
		if("thighs")
			if(grind_thing in user.held_items)
				room = "bunches [spot] between [their] thighs"
				own = "bunch [spot] between my thighs"
			else
				room = "straddles [spot] and sinks [their] weight onto it"
				own = "straddle [spot] and sink my weight onto it"
		if("lie")
			if(get_grind_kind(grind_thing) == "floor")
				room = "presses [their] hips down against the floor"
				own = "press my hips down against the floor"
	if(!room && get_grind_kind(grind_thing) == "wall")
		room = "presses flat against [spot] and rolls [their] hips into it"
		own = "press flat against [spot] and roll my hips into it"
	if(!room)
		room = "presses [their] [crotch] against [spot] and starts to grind"
		own = "press my [crotch] against [spot] and start to grind"
	user.visible_message(span_love("[user] [room]."), span_love("I [own]."))

/datum/sex_action/grind/thing/proc/get_scrape_line(mob/living/user)
	var/surface = get_grind_kind(grind_thing) == "tree" ? "The bark" : "The rough stone"
	return "[surface] scrapes at my [get_crotch_word(user)]!"

/datum/sex_action/grind/thing/proc/get_thing_cycle_line(mob/living/user, obj/item/clothing/own_cover, wet)
	var/spot = user.get_grind_thing_spot(grind_thing)
	if(is_denied(user))
		return "[get_denied_line(user, spot)]."
	var/adverb = get_generic_force_adjective()
	var/line
	if(get_grind_kind(grind_thing) == "floor")
		line = "[user] [adverb] ruts against the floor"
	else
		line = pick("[user] [adverb] grinds against [spot]", "[user] [adverb] ruts against [spot]")
	return "[line][get_wet_tail(user, wet, own_cover)][get_clothes_suffix(user, own_cover)]."

// ---- Pillows ----

/datum/sex_action/grind/pillow/proc/announce_pillow_start(mob/living/user)
	var/their = user.p_their()
	if(user.body_position == LYING_DOWN)
		user.visible_message(span_love("[user] clamps \the [grind_thing] between [their] thighs and rocks into them."), span_love("I clamp \the [grind_thing] between my thighs and rock into them."))
		return
	user.visible_message(span_love("[user] kneels astride \the [grind_thing] and sinks [their] hips into them."), span_love("I kneel astride \the [grind_thing] and sink my hips into them."))

/datum/sex_action/grind/pillow/proc/get_pillow_cycle_line(mob/living/user, obj/item/clothing/own_cover, wet)
	if(is_denied(user))
		return "[get_denied_line(user, "\the [grind_thing]")]."
	var/adverb = get_generic_force_adjective()
	var/their = user.p_their()
	var/line
	if(user.body_position == LYING_DOWN)
		line = pick("[user] [adverb] rocks against \the [grind_thing] between [their] thighs", "[user] [adverb] humps \the [grind_thing] clamped between [their] thighs")
	else
		line = pick("[user] [adverb] humps \the [grind_thing]", "[user] [adverb] ruts into the plush, pressing it flat under [their] hips", "[user] [adverb] grinds down into the plush, hips rolling")
	return "[line][get_wet_tail(user, wet, own_cover)][get_clothes_suffix(user, own_cover)]."

// ---- Seat ----

/datum/sex_action/grind/seat/proc/get_seat_room_line(mob/living/user, rough)
	var/their = user.p_their()
	if(rough)
		return pick("[user] rocks [their] hips against [their] seat.", "[user] grinds down into [their] seat, breathing hard.")
	return pick("[user] squirms in [their] seat.", "[user] shifts restlessly in [their] seat.")

/datum/sex_action/grind/seat/proc/get_seat_own_line(mob/living/user, rough)
	if(is_denied(user))
		return "I grind against the seat, but the device keeps every touch out of reach."
	if(rough)
		return "I grind down hard against \the [grind_thing], past caring who sees."
	return "I grind down against \the [grind_thing], careful not to be seen."
