// Grinding a crotch against a partner's body or against a thing; the hips item and the panel start the same actions.

/// Pleasure scale with bare skin on bare skin, and with soft clothes between.
#define GRIND_BARE_MULT 1.25
#define GRIND_CLOTHED_MULT 0.5
/// A strapon presses only its base against the wearer.
#define GRIND_STRAPON_MULT 0.5
/// Orgasm progress share left when every genital is locked away.
#define GRIND_DENIED_ORGASM_MULT 0.15
/// Units of wetness a pussy leaves per cycle.
#define GRIND_WET_UNITS 0.3
/// Cushioned things feel better; bark and stone feel worse and scrape when bare and rough.
#define GRIND_SOFT_MULT 1.15
#define GRIND_ROUGH_MULT 0.8
#define GRIND_SCRAPE_PAIN 2
#define GRIND_SCRAPE_PAIN_EXTREME 4
/// A pillow takes a climax only with this much room left.
#define GRIND_PILLOW_MIN_ROOM 2

/datum/sex_action/grind
	abstract_type = /datum/sex_action/grind
	name = "Grind"
	do_time = 3 SECONDS
	stamina_cost = 0.3
	user_menu_zone_mask = SEX_UI_ZONE_GENITALS
	target_menu_zone_mask = SEX_UI_ZONE_GENITALS
	check_same_tile = FALSE
	/// The hips item that started this grind; letting go of them ends it.
	var/obj/item/grind_hips/hips
	/// Set once on_start has run, so a failed start says nothing on finish.
	var/started = FALSE
	/// The thing ground against, for grinds that are not on a partner.
	var/atom/grind_thing

/datum/sex_action/grind/Destroy()
	unlink_hips()
	set_grind_thing(null)
	return ..()

/datum/sex_action/grind/proc/set_grind_thing(atom/new_thing)
	if(grind_thing)
		UnregisterSignal(grind_thing, COMSIG_PARENT_QDELETING)
	grind_thing = new_thing
	if(grind_thing)
		RegisterSignal(grind_thing, COMSIG_PARENT_QDELETING, PROC_REF(on_thing_deleted))

/datum/sex_action/grind/proc/on_thing_deleted(datum/source)
	SIGNAL_HANDLER
	set_grind_thing(null)

/// The hips hand over the clicked thing before the action starts.
/datum/sex_action/grind/prepare_proposal(datum/sex_scene_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/grinder = controller.user
	if(istype(grinder) && grinder.grind_hips?.pending_thing)
		set_grind_thing(grinder.grind_hips.pending_thing)
	return TRUE

/datum/sex_action/grind/proc/unlink_hips()
	if(hips?.grind_action == src)
		hips.grind_action = null
	hips = null

/datum/sex_action/grind/on_finish(mob/living/user, mob/living/target)
	unlink_hips()
	return ..()

/datum/sex_action/grind/lock_sex_object(mob/living/user, mob/living/target)
	if(user.getorganslot(ORGAN_SLOT_PENIS))
		add_sex_lock(user, ORGAN_SLOT_PENIS)
	if(user.getorganslot(ORGAN_SLOT_VAGINA))
		add_sex_lock(user, ORGAN_SLOT_VAGINA)

/// TRUE when another action holds the grinder's cock or pussy.
/datum/sex_action/grind/proc/is_crotch_claimed(mob/living/user)
	return check_sex_lock(user, ORGAN_SLOT_PENIS) || check_sex_lock(user, ORGAN_SLOT_VAGINA)

/// The organ the grinder presses with: a free cock first, then a free pussy; null when none is free.
/datum/sex_action/grind/proc/get_grind_organ(mob/living/grinder)
	return get_free_organ(grinder, ORGAN_SLOT_PENIS) || get_free_organ(grinder, ORGAN_SLOT_VAGINA)

/// TRUE when the grinder has genitals and devices lock all of them away.
/datum/sex_action/grind/proc/is_denied(mob/living/grinder)
	if(!grinder.getorganslot(ORGAN_SLOT_PENIS) && !grinder.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	return !get_grind_organ(grinder)

/// The device that locks the grinder's genitals away, or null.
/datum/sex_action/grind/proc/get_denial_device(mob/living/grinder)
	for(var/slot in list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA))
		var/obj/item/organ/organ = grinder.getorganslot(slot)
		if(!organ)
			continue
		for(var/obj/item/device in organ.contents)
			if(device.blocks_organ_use(slot))
				return device
		if(iscarbon(grinder))
			var/mob/living/carbon/carbon_grinder = grinder
			if(carbon_grinder.underwear?.blocks_organ_use(slot))
				return carbon_grinder.underwear
	return null

/// TRUE when the grinder presses with a strapon.
/datum/sex_action/grind/proc/is_strapon_grind(mob/living/grinder)
	var/obj/item/organ/genitals/penis/penis = get_grind_organ(grinder)
	return istype(penis) && penis.strapon

/// TRUE when the grinder presses with a hard, real cock.
/datum/sex_action/grind/proc/is_hard_cock_grind(mob/living/grinder)
	var/obj/item/organ/genitals/penis/penis = get_grind_organ(grinder)
	if(!istype(penis) || penis.strapon)
		return FALSE
	return penis.always_hard || penis.erect_state == ERECT_STATE_HARD

/// The free pussy the grinder presses with, when it is their grinding organ.
/datum/sex_action/grind/proc/get_grind_pussy(mob/living/grinder)
	RETURN_TYPE(/obj/item/organ/genitals/filling_organ/vagina)
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = get_grind_organ(grinder)
	return istype(vagina) ? vagina : null

/// Pleasure scale for the grinder: contact, a strapon's dull base, and chastity.
/datum/sex_action/grind/proc/scale_grinder_pleasure(mob/living/user, contact_mult, list/amounts)
	var/mult = contact_mult
	if(is_strapon_grind(user))
		mult *= user.get_strapon_feel(GRIND_STRAPON_MULT)
	amounts[1] *= mult
	amounts[2] *= mult
	if(is_denied(user))
		amounts[2] *= GRIND_DENIED_ORGASM_MULT
	return amounts

/// Leaves a little wetness: in the grinder's own smallclothes, else on what they grind against.
/datum/sex_action/grind/proc/leave_wetness(mob/living/user, mob/living/partner, coat_zone, atom/thing)
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = get_grind_pussy(user)
	if(!vagina?.reagents?.total_volume)
		return FALSE
	var/obj/item/clothing/inner = get_grind_crotch_cover(user, TRUE)
	if(inner)
		return inner.soak_fluid(vagina.reagents, GRIND_WET_UNITS) > 0
	if(ishuman(partner))
		var/mob/living/carbon/human/human_partner = partner
		return human_partner.coat_with_fluid(coat_zone, vagina.reagents, GRIND_WET_UNITS) < GRIND_WET_UNITS
	if(is_pillow(thing))
		return soak_pillow(thing, vagina.reagents, GRIND_WET_UNITS, user) > 0
	var/obj/item/clothing/garment = thing
	if(istype(garment))
		return garment.soak_fluid(vagina.reagents, GRIND_WET_UNITS) > 0
	return FALSE

/// Each cycle rubs a little of the grinder's scent into what they grind against, and marks the tile.
/datum/sex_action/grind/proc/leave_grind_scent(mob/living/user, atom/rubbed)
	if(!rubbed)
		return
	scent_mark(rubbed, user)
	leave_fluid_scent(get_turf(rubbed), user, get_grind_pussy(user)?.reagents?.total_volume ? "nectar" : "musk")

/// A grinding sway towards what is ground against.
/datum/sex_action/grind/proc/play_grind_motion(mob/living/user, atom/towards)
	var/list/step = get_sex_motion_step(user, towards)
	var/pixels = force >= SEX_FORCE_HIGH ? 2 : 1
	var/list/timing = get_motion_steps(1)
	if(get_turf(user) == get_turf(towards))
		sex_motion_nudge(user, 0, -pixels, timing[1], timing[2])
		return
	sex_motion_nudge(user, step[1] * pixels, step[2] * pixels, timing[1], timing[2])

/// A covered crotch keeps the climax in the grinder's own clothes.
/datum/sex_action/grind/get_climax_container(mob/living/user, mob/living/target, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	var/obj/item/clothing/inner = get_grind_crotch_cover(user, TRUE)
	if(inner?.can_soak_fluid())
		inner.prepare_fluid_holder()
		return inner
	return null

/// The soft garment over [grinder]'s crotch, outermost or innermost; chastity devices and open garments do not count.
/proc/get_grind_crotch_cover(mob/living/grinder, innermost = FALSE)
	if(!iscarbon(grinder))
		return null
	var/mob/living/carbon/carbon_grinder = grinder
	var/list/candidates = list()
	if(ishuman(grinder))
		var/mob/living/carbon/human/human_grinder = grinder
		candidates += list(human_grinder.cloak, human_grinder.wear_armor, human_grinder.wear_shirt, human_grinder.wear_pants)
	candidates += list(carbon_grinder.undershirt, carbon_grinder.underwear)
	if(innermost)
		reverseRange(candidates)
	for(var/obj/item/clothing/garment in candidates)
		if(!(garment.body_parts_covered & GROIN))
			continue
		if(garment.armor_class > AC_LIGHT || garment.genital_access || garment.allow_erp_equipped)
			continue
		if(garment.blocks_organ_use(ORGAN_SLOT_PENIS) || garment.blocks_organ_use(ORGAN_SLOT_VAGINA))
			continue
		return garment
	return null

// ---- Against a partner ----

/datum/sex_action/grind/partner
	name = "Grind against"
	description = "Grind your crotch against the part of them you aim at. Height and posture decide what you reach."
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH | SEX_UI_ZONE_GENITALS | SEX_UI_ZONE_ARMS | SEX_UI_ZONE_LEGS | SEX_UI_ZONE_BODY
	/// The targeting-doll zone the grinder aims at.
	var/asked_zone
	var/spot
	var/from_behind = FALSE

/datum/sex_action/grind/partner/prepare_proposal(datum/sex_scene_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	asked_zone = controller.user.zone_selected
	update_menu_name(controller.user, controller.target)
	return TRUE

/// The panel names the spot the targeting doll will land on: "Grind thigh".
/datum/sex_action/grind/partner/proc/update_menu_name(mob/living/user, mob/living/target)
	if(!user || !target || user == target || user.get_grind_refusal(target, asked_zone))
		return
	var/new_spot = user.resolve_grind_spot(target, asked_zone)
	name = get_spot_menu_name(new_spot, target, user.is_grinding_from_behind(target))

/datum/sex_action/grind/partner/proc/get_spot_menu_name(spot, mob/living/target, behind)
	return "Grind [replacetext(get_grind_spot_name(spot, target, behind), " ", "-")]"

/datum/sex_action/grind/partner/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && ishuman(target)

/datum/sex_action/grind/partner/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(user.get_grind_refusal(target, asked_zone || user.zone_selected))
		return FALSE
	return !is_crotch_claimed(user)

/datum/sex_action/grind/partner/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !user.get_grind_refusal(target, asked_zone)

/// Re-reads the spot from the asked zone and both postures; TRUE when it changed.
/datum/sex_action/grind/partner/proc/refresh_spot(mob/living/user, mob/living/target)
	var/new_spot = user.resolve_grind_spot(target, asked_zone)
	var/new_behind = !!user.is_grinding_from_behind(target)
	. = new_spot != spot || new_behind != from_behind
	spot = new_spot
	from_behind = new_behind
	if(spot)
		name = get_spot_menu_name(spot, target, from_behind)

/datum/sex_action/grind/partner/on_start(mob/living/user, mob/living/target)
	refresh_spot(user, target)
	if(!spot)
		return FALSE
	var/pose = user.get_grind_pose(target, spot)
	// Straddling a lap or a lying body puts the grinder on their tile.
	if(pose == "straddle" && get_turf(user) != get_turf(target))
		if(!user.Adjacent(target))
			return FALSE
		user.forceMove(get_turf(target))
	. = ..()
	if(!.)
		return FALSE
	if(get_turf(user) != get_turf(target))
		user.setDir(get_dir(user, target))
	announce_start(user, target, pose)
	note_fallback(user, target)
	started = TRUE

/datum/sex_action/grind/partner/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(refresh_spot(user, target) && spot)
		announce_shift(user, target, null)
	var/obj/item/clothing/own_cover = get_grind_crotch_cover(user)
	var/obj/item/clothing/their_cover = target.get_grind_spot_cover(spot, from_behind)
	var/contact_mult = (own_cover || their_cover) ? GRIND_CLOTHED_MULT : GRIND_BARE_MULT
	var/coat_zone = get_grind_spot_coat_zone(spot, from_behind)
	var/wet = leave_wetness(user, target, coat_zone)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(get_cycle_line(user, target, own_cover, their_cover, wet)))
	show_feel_lines(user, target, own_cover)
	play_rub_sound("grind", target, sex_volume * 0.5)
	play_grind_motion(user, target)
	var/list/own = scale_grinder_pleasure(user, contact_mult, list(1.4, 1.2))
	perform_sex_action(user, target, own[1], 0, own[2])
	var/list/theirs = get_partner_pleasure()
	if(theirs[1] > 0)
		var/their_orgasm = theirs[2] * contact_mult
		if(is_denied(target))
			their_orgasm *= GRIND_DENIED_ORGASM_MULT
		perform_sex_action(target, user, theirs[1] * contact_mult, 0, their_orgasm)
	leave_grind_scent(user, target)
	handle_passive_ejaculation()

/// Arousal and orgasm progress the partner gets per cycle at this spot.
/datum/sex_action/grind/partner/proc/get_partner_pleasure()
	switch(spot)
		if(GRIND_SPOT_CROTCH)
			return from_behind ? list(0.6, 0.3) : list(1, 0.8)
		if(GRIND_SPOT_LAP)
			return list(1, 0.8)
		if(GRIND_SPOT_THIGH, GRIND_SPOT_FACE)
			return list(0.4, 0)
		if(GRIND_SPOT_BELLY, GRIND_SPOT_CHEST)
			return list(0.2, 0)
	return list(0.1, 0)

/datum/sex_action/grind/partner/get_stamina_cost_multiplier()
	. = ..()
	if(spot == GRIND_SPOT_THIGH && force >= SEX_FORCE_EXTREME)
		return . * 1.5

/datum/sex_action/grind/partner/on_finish(mob/living/user, mob/living/target)
	if(started)
		user.visible_message(span_love("[user] eases off [target], flushed."), span_love("I ease off [target], breathing hard."))
	return ..()

/// Moves the grind to another zone on the same partner without stopping.
/datum/sex_action/grind/partner/proc/shift_to(zone)
	var/old_spot = spot
	asked_zone = zone
	refresh_spot(action_user, action_target)
	if(!spot)
		scene?.stop_action(src)
		return
	if(spot != old_spot)
		announce_shift(action_user, action_target, old_spot)
		note_fallback(action_user, action_target)

/datum/sex_action/grind/partner/get_climax_coat_zone(mob/living/climaxer)
	if(climaxer == action_user)
		return get_grind_spot_coat_zone(spot, from_behind)
	return FLUID_COAT_GROIN

/datum/sex_action/grind/partner/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	var/obj/item/clothing/cover = get_grind_crotch_cover(user)
	if(cover)
		user.visible_message(span_love(get_covered_climax_line(user, cover)))
		return ORGASM_LOCATION_CONTAINER
	if(user != action_user)
		// The one ground against climaxes; only a crotch pressed to theirs catches it.
		if((spot == GRIND_SPOT_CROTCH && !from_behind) || spot == GRIND_SPOT_LAP)
			user.visible_message(span_love("[user] shudders against [target]'s grinding hips!"))
			return ORGASM_LOCATION_ONTO
		user.visible_message(span_love("[user] climaxes under [target]'s grinding!"))
		return ORGASM_LOCATION_SELF
	if(is_denied(user))
		return null
	var/spot_name = get_grind_spot_name(spot, target, from_behind)
	if(get_real_organ(user, ORGAN_SLOT_PENIS) && !user.is_organ_slot_blocked(ORGAN_SLOT_PENIS))
		user.visible_message(span_love("[user] shudders and spurts over [target]'s [spot_name]!"))
	else
		user.visible_message(span_love("[user] quivers against [target]'s [spot_name] and soaks it!"))
	return ORGASM_LOCATION_ONTO

/// Horny NPCs grind on their target; the spot is picked among those in reach, mostly the crotch.
/datum/sex_action/grind/partner/npc
	name = "NPC grind"
	check_incapacitated = FALSE
	stamina_cost = 0.1

/datum/sex_action/grind/partner/npc/shows_on_menu(mob/living/user, mob/living/target)
	return FALSE

/datum/sex_action/grind/partner/npc/prepare_proposal(datum/sex_scene_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	asked_zone = pick_npc_zone(controller.user, controller.target)
	return TRUE

/datum/sex_action/grind/partner/npc/proc/pick_npc_zone(mob/living/user, mob/living/target)
	var/static/list/spot_weights = list(
		GRIND_SPOT_CROTCH = 4,
		GRIND_SPOT_LAP = 4,
		GRIND_SPOT_THIGH = 2,
		GRIND_SPOT_FACE = 2,
		GRIND_SPOT_BELLY = 1,
		GRIND_SPOT_CHEST = 1,
	)
	var/list/weights = list()
	for(var/spot in user.get_grind_reach(target))
		if(spot_weights[spot])
			weights[spot] = spot_weights[spot]
	if(!length(weights))
		return BODY_ZONE_PRECISE_GROIN
	return get_grind_spot_body_zone(pickweight(weights))

// ---- Against a thing ----

/datum/sex_action/grind/thing
	name = "Grind object"
	description = "Grind your crotch against a thing next to you; the panel picks what you face first."

/// Without the hips, the panel picks the nearest thing worth grinding on and names it.
/datum/sex_action/grind/thing/prepare_proposal(datum/sex_scene_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	if(!grind_thing && controller.user == controller.target)
		set_grind_thing(controller.user.find_grind_thing())
	if(grind_thing)
		name = get_thing_menu_name(grind_thing)
	return TRUE

/datum/sex_action/grind/thing/proc/get_thing_menu_name(atom/thing)
	var/kind = get_grind_kind(thing)
	switch(kind)
		if("soft")
			kind = "cloth"
		if("thing")
			kind = "object"
	return "Grind [kind]"

/datum/sex_action/grind/thing/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && !!grind_thing

/datum/sex_action/grind/thing/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || !grind_thing)
		return FALSE
	if(user.get_grind_thing_refusal(grind_thing))
		return FALSE
	return !is_crotch_claimed(user)

/datum/sex_action/grind/thing/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!. || !grind_thing)
		return FALSE
	return !user.get_grind_thing_refusal(grind_thing)

/datum/sex_action/grind/thing/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!. || !grind_thing)
		return FALSE
	if(get_turf(grind_thing) != get_turf(user))
		user.setDir(get_dir(user, grind_thing))
	announce_thing_start(user)
	started = TRUE

/datum/sex_action/grind/thing/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!grind_thing)
		return
	var/obj/item/clothing/own_cover = get_grind_crotch_cover(user)
	var/wet = leave_wetness(user, null, null, grind_thing) || (!own_cover && get_grind_pussy(user)?.reagents?.total_volume)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(get_thing_cycle_line(user, own_cover, wet)))
	if(prob(25))
		to_chat(user, span_love(is_denied(user) ? "The device keeps every touch just out of reach." : pick("The friction sends a shiver up my spine.", "Every roll of my hips drags a moan out of me.")))
	play_rub_sound("grind", user, sex_volume * 0.5)
	play_grind_motion(user, grind_thing)
	var/mult = own_cover ? GRIND_CLOTHED_MULT : 1
	var/pain = 0
	switch(get_grind_surface_feel(grind_thing))
		if("soft")
			mult *= GRIND_SOFT_MULT
		if("rough")
			mult *= GRIND_ROUGH_MULT
			if(!own_cover && force >= SEX_FORCE_HIGH)
				pain = force >= SEX_FORCE_EXTREME ? GRIND_SCRAPE_PAIN_EXTREME : GRIND_SCRAPE_PAIN
				if(prob(33))
					to_chat(user, span_warning(get_scrape_line(user)))
	var/list/own = scale_grinder_pleasure(user, mult, list(1.5, 1))
	perform_sex_action(user, user, own[1], pain, own[2])
	leave_grind_scent(user, grind_thing)
	handle_passive_ejaculation()

/datum/sex_action/grind/thing/on_finish(mob/living/user, mob/living/target)
	if(started)
		var/spot = grind_thing ? user.get_grind_thing_spot(grind_thing) : "it"
		user.visible_message(span_love("[user] pulls away from [spot], flushed."), span_love("I pull away from [spot], breathing hard."))
	return ..()

/// Cloth and containers catch a bare climax; anything else leaves it on the floor.
/datum/sex_action/grind/thing/get_climax_container(mob/living/user, mob/living/target, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	if(get_grind_crotch_cover(user))
		return ..()
	if(is_aim_garment(grind_thing))
		var/obj/item/clothing/garment = grind_thing
		garment.prepare_fluid_holder()
		return garment
	if(is_aim_container(grind_thing))
		return grind_thing
	return null

/datum/sex_action/grind/thing/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	var/obj/item/clothing/cover = get_grind_crotch_cover(user)
	if(cover)
		user.visible_message(span_love(get_covered_climax_line(user, cover)))
		return ORGASM_LOCATION_CONTAINER
	if(is_denied(user) || !grind_thing)
		return null
	var/spot = user.get_grind_thing_spot(grind_thing)
	if(get_real_organ(user, ORGAN_SLOT_PENIS) && !user.is_organ_slot_blocked(ORGAN_SLOT_PENIS))
		user.visible_message(span_love("[user] shudders and makes a mess of [spot]!"))
	else
		user.visible_message(span_love("[user] shudders against [spot] and soaks it!"))
	return (is_aim_garment(grind_thing) || is_aim_container(grind_thing)) ? ORGASM_LOCATION_CONTAINER : ORGASM_LOCATION_SELF

// ---- Pillows ----

/datum/sex_action/grind/pillow
	name = "Hump pillow"
	description = "Straddle the pillows on your tile, or clamp them between your thighs lying down."

/datum/sex_action/grind/pillow/prepare_proposal(datum/sex_scene_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	if(!is_pillow(grind_thing))
		set_grind_thing(controller.user.get_humpable_pillow())
	return TRUE

/datum/sex_action/grind/pillow/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && !!user.get_humpable_pillow()

/datum/sex_action/grind/pillow/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || !can_hump_pillow(user))
		return FALSE
	if(user.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, user))
		return FALSE
	return !is_crotch_claimed(user)

/datum/sex_action/grind/pillow/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return can_hump_pillow(user)

/// TRUE while the pillows are held or on the grinder's tile, and the grinder is not seated.
/datum/sex_action/grind/pillow/proc/can_hump_pillow(mob/living/user)
	if(!is_pillow(grind_thing) || user.get_grind_seat())
		return FALSE
	return (grind_thing in user.held_items) || get_turf(grind_thing) == get_turf(user)

/datum/sex_action/grind/pillow/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!. || !grind_thing)
		return FALSE
	announce_pillow_start(user)
	started = TRUE

/datum/sex_action/grind/pillow/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!grind_thing)
		return
	var/obj/item/clothing/own_cover = get_grind_crotch_cover(user)
	var/wet = leave_wetness(user, null, null, grind_thing)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(get_pillow_cycle_line(user, own_cover, wet)))
	if(prob(25))
		to_chat(user, span_love(is_denied(user) ? "The device keeps every touch just out of reach." : pick("The plush gives under every roll of my hips.", "I rub myself into the soft fabric.")))
	play_rub_sound("grind", user, sex_volume * 0.4)
	play_grind_motion(user, grind_thing)
	var/list/own = scale_grinder_pleasure(user, own_cover ? GRIND_CLOTHED_MULT : 1, list(1.6, 1.1))
	perform_sex_action(user, user, own[1], 0, own[2])
	leave_grind_scent(user, grind_thing)
	handle_passive_ejaculation()

/datum/sex_action/grind/pillow/on_finish(mob/living/user, mob/living/target)
	if(started && grind_thing)
		user.visible_message(span_love("[user] rolls off \the [grind_thing], leaving them rumpled and warm."), span_love("I roll off \the [grind_thing], leaving them rumpled and warm."))
	return ..()

/datum/sex_action/grind/pillow/get_climax_container(mob/living/user, mob/living/target, mob/living/action_initiator, mob/living/action_target, mob/living/action_performer)
	if(get_grind_crotch_cover(user))
		return ..()
	if(get_pillow_room(grind_thing) >= GRIND_PILLOW_MIN_ROOM)
		grind_thing.LoadComponent(/datum/component/damp_pillow)
		return grind_thing
	return null

/datum/sex_action/grind/pillow/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	var/obj/item/clothing/cover = get_grind_crotch_cover(user)
	if(cover)
		user.visible_message(span_love(get_covered_climax_line(user, cover)))
		return ORGASM_LOCATION_CONTAINER
	if(is_denied(user) || !grind_thing)
		return null
	if(get_pillow_room(grind_thing) >= GRIND_PILLOW_MIN_ROOM)
		if(user.body_position == LYING_DOWN)
			user.visible_message(span_love("[user] squeezes \the [grind_thing] tight between [user.p_their()] thighs and shudders through [user.p_their()] climax!"))
		else
			user.visible_message(span_love("[user] grinds down hard into \the [grind_thing] and shudders through [user.p_their()] climax!"))
		return ORGASM_LOCATION_CONTAINER
	user.visible_message(span_love("[user] shudders against \the [grind_thing], already soaked through!"))
	return ORGASM_LOCATION_SELF

/// Pillows held in hand, else pillows on this mob's tile; null when there are none.
/mob/living/proc/get_humpable_pillow()
	for(var/obj/item/pillow/held in held_items)
		return held
	for(var/atom/movable/thing in get_turf(src))
		if(is_pillow(thing))
			return thing
	return null

// ---- The seat under you ----

/datum/sex_action/grind/seat
	name = "Grind seated"
	description = "Rock your hips against the seat you sit on, as quietly as you can."
	do_time = 3.6 SECONDS
	stamina_cost = 0.2

/datum/sex_action/grind/seat/prepare_proposal(datum/sex_scene_controller/controller)
	. = ..()
	if(!.)
		return FALSE
	set_grind_thing(controller.user.get_grind_seat())
	return TRUE

/datum/sex_action/grind/seat/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && !!user.get_grind_seat()

/datum/sex_action/grind/seat/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || !grind_thing || grind_thing != user.get_grind_seat())
		return FALSE
	if(user.get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, user))
		return FALSE
	return !is_crotch_claimed(user)

/datum/sex_action/grind/seat/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return grind_thing && grind_thing == user.get_grind_seat()

/datum/sex_action/grind/seat/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(!. || !grind_thing)
		return FALSE
	to_chat(user, span_love("I shift on \the [grind_thing] and press my [get_crotch_word(user)] down against the seat."))
	started = TRUE

/// Quiet: the room sees only squirming now and then, more often the rougher it gets.
/datum/sex_action/grind/seat/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!grind_thing)
		return
	var/obj/item/clothing/own_cover = get_grind_crotch_cover(user)
	leave_wetness(user, null, null, null)
	var/rough = force >= SEX_FORCE_HIGH
	if(prob(rough ? 50 : 20))
		user.visible_message(span_love(get_seat_room_line(user, rough)), span_love(get_seat_own_line(user, rough)))
	else if(prob(40))
		to_chat(user, span_love(get_seat_own_line(user, rough)))
	if(rough)
		play_rub_sound("grind", user, sex_volume * 0.25)
	sex_motion_nudge(user, 0, -1, 0.3 SECONDS, 0.4 SECONDS)
	var/list/own = scale_grinder_pleasure(user, own_cover ? GRIND_CLOTHED_MULT : 1, list(1.2, 0.9))
	perform_sex_action(user, user, own[1], 0, own[2])
	leave_grind_scent(user, grind_thing)
	handle_passive_ejaculation()

/datum/sex_action/grind/seat/on_finish(mob/living/user, mob/living/target)
	if(started && grind_thing)
		to_chat(user, span_love("I settle back on \the [grind_thing], flushed."))
	return ..()

/datum/sex_action/grind/seat/handle_climax_message(mob/living/user, mob/living/target, must_flip)
	var/obj/item/clothing/cover = get_grind_crotch_cover(user)
	if(cover)
		user.visible_message(span_love(get_covered_climax_line(user, cover)))
		return ORGASM_LOCATION_CONTAINER
	if(is_denied(user))
		return null
	user.visible_message(span_love("[user] shudders in [user.p_their()] seat, biting back a moan!"))
	return ORGASM_LOCATION_SELF

#undef GRIND_BARE_MULT
#undef GRIND_CLOTHED_MULT
#undef GRIND_STRAPON_MULT
#undef GRIND_DENIED_ORGASM_MULT
#undef GRIND_WET_UNITS
#undef GRIND_SOFT_MULT
#undef GRIND_ROUGH_MULT
#undef GRIND_SCRAPE_PAIN
#undef GRIND_SCRAPE_PAIN_EXTREME
#undef GRIND_PILLOW_MIN_ROOM
