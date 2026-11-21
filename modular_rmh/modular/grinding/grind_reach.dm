// Body height, posture and reach: which spot on a partner a grinding crotch can press against.

/// Head offset pixels per unit of body height; a dwarf's -4 gives 0.8.
#define GRIND_HEAD_OFFSET_SCALE 20
/// Lowest and highest a standing crotch reaches, as shares of its own body height.
#define GRIND_REACH_LOW 0.25
#define GRIND_REACH_HIGH 0.62
/// Below this share the grinder kneels; above the other one they rise on their toes.
#define GRIND_KNEEL_BELOW 0.33
#define GRIND_TOES_ABOVE 0.53

/// Standing height against a standing human (1.0).
/mob/living/proc/get_grind_body_height()
	return get_grind_sprite_scale()

/// The species head offset says how tall the body is; the sprite scale covers seelies and potions.
/mob/living/carbon/get_grind_body_height()
	var/list/offsets = get_offset_features()
	var/list/head = offsets ? offsets[OFFSET_HEAD] : null
	var/head_y = length(head) >= 2 ? head[2] : 0
	return (1 + head_y / GRIND_HEAD_OFFSET_SCALE) * get_grind_sprite_scale()

/// Uniform scale of the sprite; the lying turn leaves it unchanged.
/mob/living/proc/get_grind_sprite_scale()
	var/matrix/current = transform
	return sqrt(current.a ** 2 + current.d ** 2) || 1

/// The chair, stool, bench or throne this mob sits on, or null.
/mob/living/proc/get_grind_seat()
	if(body_position == LYING_DOWN)
		return null
	if(istype(buckled, /obj/structure/chair) || istype(buckled, /obj/structure/throne))
		return buckled
	return null

/// Every partner spot, lowest first.
/proc/get_grind_spots()
	var/static/list/spots = list(
		GRIND_SPOT_FEET,
		GRIND_SPOT_THIGH,
		GRIND_SPOT_HAND,
		GRIND_SPOT_CROTCH,
		GRIND_SPOT_BELLY,
		GRIND_SPOT_ARM,
		GRIND_SPOT_CHEST,
		GRIND_SPOT_FACE,
	)
	return spots

/// Height of a spot as a share of body height, standing or seated.
/proc/get_grind_spot_height(spot, seated = FALSE)
	var/static/list/standing = list(
		GRIND_SPOT_FEET = 0.05,
		GRIND_SPOT_THIGH = 0.38,
		GRIND_SPOT_HAND = 0.45,
		GRIND_SPOT_CROTCH = 0.5,
		GRIND_SPOT_LAP = 0.3,
		GRIND_SPOT_BELLY = 0.6,
		GRIND_SPOT_ARM = 0.65,
		GRIND_SPOT_CHEST = 0.72,
		GRIND_SPOT_FACE = 0.88,
	)
	var/static/list/sitting = list(
		GRIND_SPOT_FEET = 0.05,
		GRIND_SPOT_THIGH = 0.3,
		GRIND_SPOT_HAND = 0.3,
		GRIND_SPOT_CROTCH = 0.3,
		GRIND_SPOT_LAP = 0.3,
		GRIND_SPOT_BELLY = 0.42,
		GRIND_SPOT_ARM = 0.48,
		GRIND_SPOT_CHEST = 0.55,
		GRIND_SPOT_FACE = 0.7,
	)
	return seated ? sitting[spot] : standing[spot]

/// The spot a targeting-doll zone asks for; every head zone asks for the face.
/proc/body_zone_to_grind_spot(zone)
	switch(zone)
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return GRIND_SPOT_FEET
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return GRIND_SPOT_THIGH
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return GRIND_SPOT_HAND
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			return GRIND_SPOT_ARM
		if(BODY_ZONE_PRECISE_GROIN)
			return GRIND_SPOT_CROTCH
		if(BODY_ZONE_PRECISE_STOMACH)
			return GRIND_SPOT_BELLY
		if(BODY_ZONE_CHEST)
			return GRIND_SPOT_CHEST
	return GRIND_SPOT_FACE

/// Spots on [partner] this mob's crotch reaches in both postures, lowest first.
/mob/living/proc/get_grind_reach(mob/living/partner)
	. = list()
	if(!partner || get_grind_seat())
		return
	if(partner.body_position == LYING_DOWN)
		. += get_grind_spots()
		if(body_position == LYING_DOWN)
			. -= GRIND_SPOT_FACE
		return
	if(body_position == LYING_DOWN)
		return list(GRIND_SPOT_FEET)
	var/seated = !!partner.get_grind_seat()
	var/own_height = get_grind_body_height()
	var/partner_height = partner.get_grind_body_height()
	for(var/spot in get_grind_spots())
		// A seated partner's thighs and crotch are the lap, which is always in reach.
		if(seated && (spot == GRIND_SPOT_THIGH || spot == GRIND_SPOT_CROTCH))
			continue
		var/height = get_grind_spot_height(spot, seated) * partner_height
		if(height >= own_height * GRIND_REACH_LOW && height <= own_height * GRIND_REACH_HIGH)
			. += spot
	if(seated)
		. += GRIND_SPOT_LAP

/// The spot a grind at [zone] lands on: the asked one when in reach, else the nearest by height.
/mob/living/proc/resolve_grind_spot(mob/living/partner, zone)
	var/list/reach = get_grind_reach(partner)
	if(!length(reach))
		return null
	var/seated = !!partner.get_grind_seat()
	var/asked = body_zone_to_grind_spot(zone)
	if(seated && (asked == GRIND_SPOT_THIGH || asked == GRIND_SPOT_CROTCH))
		asked = GRIND_SPOT_LAP
	if(asked in reach)
		return asked
	var/asked_height = get_grind_spot_height(asked, seated)
	var/best
	var/best_gap
	for(var/spot in reach)
		// Hands and arms hang beside the body; only an explicit aim lands there.
		if(spot == GRIND_SPOT_HAND || spot == GRIND_SPOT_ARM)
			continue
		var/gap = abs(get_grind_spot_height(spot, seated) - asked_height)
		if(isnull(best_gap) || gap < best_gap)
			best = spot
			best_gap = gap
	return best || reach[1]

/// How the grinder gets to the spot: "straddle", "kneel", "toes", or null for a plain press.
/mob/living/proc/get_grind_pose(mob/living/partner, spot)
	if(spot == GRIND_SPOT_LAP)
		return "straddle"
	if(partner.body_position == LYING_DOWN)
		return body_position == LYING_DOWN ? null : "straddle"
	if(body_position == LYING_DOWN)
		return null
	var/share = get_grind_spot_height(spot, !!partner.get_grind_seat()) * partner.get_grind_body_height() / get_grind_body_height()
	if(share < GRIND_KNEEL_BELOW)
		return "kneel"
	if(share > GRIND_TOES_ABOVE)
		return "toes"
	return null

/// TRUE when [partner] has their back to this mob; lying and seated bodies show their front.
/mob/living/proc/is_grinding_from_behind(mob/living/partner)
	if(partner.body_position == LYING_DOWN || partner.get_grind_seat())
		return FALSE
	var/towards = get_dir(src, partner)
	return towards && (partner.dir & towards)

/// What a grind presses against: "thigh", "ass", "tits", "lower back".
/proc/get_grind_spot_name(spot, mob/living/partner, from_behind = FALSE)
	switch(spot)
		if(GRIND_SPOT_FEET)
			return "foot"
		if(GRIND_SPOT_THIGH)
			return "thigh"
		if(GRIND_SPOT_HAND)
			return "hand"
		if(GRIND_SPOT_CROTCH)
			return from_behind ? "ass" : "crotch"
		if(GRIND_SPOT_LAP)
			return "lap"
		if(GRIND_SPOT_BELLY)
			return from_behind ? "lower back" : "belly"
		if(GRIND_SPOT_ARM)
			return "arm"
		if(GRIND_SPOT_CHEST)
			if(from_behind)
				return "back"
			return partner?.getorganslot(ORGAN_SLOT_BREASTS) ? "tits" : "chest"
	return "face"

/// Where fluid from a grind at this spot lands.
/proc/get_grind_spot_coat_zone(spot, from_behind = FALSE)
	switch(spot)
		if(GRIND_SPOT_FEET)
			return FLUID_COAT_FEET
		if(GRIND_SPOT_THIGH, GRIND_SPOT_HAND)
			return FLUID_COAT_THIGHS
		if(GRIND_SPOT_CROTCH, GRIND_SPOT_LAP)
			return FLUID_COAT_GROIN
		if(GRIND_SPOT_BELLY)
			return from_behind ? FLUID_COAT_BACK : FLUID_COAT_BELLY
		if(GRIND_SPOT_ARM, GRIND_SPOT_CHEST)
			return from_behind ? FLUID_COAT_BACK : FLUID_COAT_CHEST
	return FLUID_COAT_FACE

/// Body zone whose armour blocks a grind at this spot.
/proc/get_grind_spot_body_zone(spot)
	switch(spot)
		if(GRIND_SPOT_FEET)
			return BODY_ZONE_PRECISE_R_FOOT
		if(GRIND_SPOT_THIGH)
			return BODY_ZONE_R_LEG
		if(GRIND_SPOT_HAND)
			return BODY_ZONE_PRECISE_R_HAND
		if(GRIND_SPOT_CROTCH, GRIND_SPOT_LAP)
			return BODY_ZONE_PRECISE_GROIN
		if(GRIND_SPOT_BELLY)
			return BODY_ZONE_PRECISE_STOMACH
		if(GRIND_SPOT_ARM)
			return BODY_ZONE_R_ARM
		if(GRIND_SPOT_CHEST)
			return BODY_ZONE_CHEST
	return BODY_ZONE_HEAD

/// The soft garment between a grind and the skin at this spot, or null; arms and hands never count.
/mob/living/proc/get_grind_spot_cover(spot, from_behind = FALSE)
	return null

/mob/living/carbon/human/get_grind_spot_cover(spot, from_behind = FALSE)
	if(spot == GRIND_SPOT_HAND || spot == GRIND_SPOT_ARM)
		return null
	var/obj/item/clothing/cover = get_coat_zone_cover(get_grind_spot_coat_zone(spot, from_behind))
	if(!cover || cover.armor_class > AC_LIGHT)
		return null
	return cover

/// Why this mob cannot grind against [partner] at [zone] now, or null when it can.
/mob/living/proc/get_grind_refusal(mob/living/partner, zone)
	if(partner == src)
		return "I can't grind against myself."
	if(!ishuman(partner) || partner.stat == DEAD)
		return "I can't grind against that."
	if(partner.on_fire)
		return "Too hot for that."
	if(!partner.allows_player_erp_while_disconnected())
		return "[partner] is away and does not allow this."
	if(!adjacent_or_closet(partner))
		return "[partner.p_theyre(TRUE)] too far away."
	if(get_sex_covering_garment(BODY_ZONE_PRECISE_GROIN, src))
		return "My armor is in the way."
	var/spot = resolve_grind_spot(partner, zone)
	if(!spot)
		return get_grind_seat() ? "I can't grind against anyone sitting down." : "I can't reach [partner] from here."
	if(partner.get_sex_covering_garment(get_grind_spot_body_zone(spot), src))
		return "[partner.p_their(TRUE)] armor is in the way."
	return null

#undef GRIND_HEAD_OFFSET_SCALE
#undef GRIND_REACH_LOW
#undef GRIND_REACH_HIGH
#undef GRIND_KNEEL_BELOW
#undef GRIND_TOES_ABOVE
