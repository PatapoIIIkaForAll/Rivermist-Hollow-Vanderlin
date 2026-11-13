/obj/structure/bondage
	name = "restraint"
	desc = "A crude restraint meant to hold someone in place."
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	buckleverb = "strap"
	breakoutextra = 10 MINUTES
	attacked_sound = list("sound/combat/hits/onwood/woodimpact (1).ogg", "sound/combat/hits/onwood/woodimpact (2).ogg")
	destroy_sound = "sound/combat/hits/onwood/destroyfurniture.ogg"
	blade_dulling = DULLING_BASHCHOP
	max_integrity = 200
	resistance_flags = NONE

	var/strap_self_time = 2 SECONDS
	var/strap_other_time = 4 SECONDS

	// Latch support
	var/latched = FALSE

/obj/structure/bondage/Initialize(mapload)
	. = ..()
	LAZYINITLIST(buckled_mobs)

/obj/structure/bondage/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!anchored)
		return FALSE

	if(force)
		return ..()

	var/mob/living/user = usr
	if(!user)
		return ..()

	if(!istype(M, /mob/living/carbon/human))
		to_chat(user, span_warning("It doesn't look like [M.p_they()] can fit into this properly!"))
		return FALSE

	if(M != user)
		var/valid_restraint = FALSE
		var/mob/living/carbon/carbon = M
		if(carbon.handcuffed || HAS_TRAIT(M, TRAIT_RESTRAINED))
			valid_restraint = TRUE

		if(!valid_restraint)
			for(var/obj/item/grabbing/G in M.grabbedby)
				if(G.grab_state >= GRAB_AGGRESSIVE)
					valid_restraint = TRUE
					break

		if(!valid_restraint)
			to_chat(user, span_warning("I must grab them more forcefully or restrain them to put them in [src]."))
			return FALSE

		M.visible_message(span_danger("[user] starts strapping [M] into [src]!"),
			span_userdanger("[user] starts strapping you into [src]!"))

		if(!do_after(user, strap_other_time, src))
			return FALSE
	else
		M.visible_message(span_notice("[user] starts positioning [user.p_them()]self into [src]..."),
			span_notice("I start positioning myself into [src]..."))

		if(!do_after(user, strap_self_time, src))
			return FALSE

	return ..(M, force, FALSE)

/obj/structure/bondage/attack_hand_secondary(mob/living/user, list/modifiers)
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!length(buckled_mobs))
		to_chat(user, span_warning("There's nobody inside to latch!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(user in buckled_mobs)
		to_chat(user, span_warning("I can't reach the latch!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	togglelatch(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/bondage/proc/togglelatch(mob/living/user, silent = FALSE)
	user.changeNext_move(CLICK_CD_MELEE)
	if(latched)
		latched = FALSE
	else
		latched = TRUE

	if(!silent)
		user.visible_message(
			span_warning("[user] [latched ? "latches" : "unlatches"] \the [src]."),
			span_notice("I [latched ? "latch" : "unlatch"] \the [src].")
		)
	playsound(src, "sound/foley/lock.ogg", 100)

/obj/structure/bondage/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(latched)
		if(isliving(user) && user.STASTR >= 18)
			if(do_after(user, 2.5 SECONDS))
				user.visible_message(span_warning("[user] breaks [src] open!"))
				unlock()
				latched = FALSE
				return ..()
		else
			to_chat(usr, span_warning("Unlatch it first!"))
			return FALSE
	else
		return ..()
	return ..()

/obj/structure/bondage/chains
	name = "chains"
	desc = "Heavy chains bolted into place."
	icon = 'modular_rmh/icons/obj/structures/bondage.dmi'
	icon_state = "CHAINS"
	density = FALSE
	layer = BELOW_MOB_LAYER
	attacked_sound = list("sound/combat/hits/onmetal/metalimpact (1).ogg", "sound/combat/hits/onmetal/metalimpact (2).ogg")
	destroy_sound = "sound/combat/hits/onwood/destroyfurniture.ogg"
	buckleverb = "chain"

/obj/structure/bondage/chains/post_buckle_mob(mob/living/M)
	. = ..()
	M.set_mob_offsets("bed_buckle", _x = 0, _y = 2)

/// Lair shackles: unlatched, so a captive works free in time and a rescuer frees them fast.
/obj/structure/bondage/chains/lair
	name = "rusted shackles"
	desc = "Pitted iron shackles bolted into the stone, worn smooth by many wrists. A captive can work free of them, given time."
	breakoutextra = 0
	var/self_escape_time = 45 SECONDS
	var/rescue_time = 5 SECONDS

/obj/structure/bondage/chains/lair/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(latched)
		return ..()
	if(!buckled_mob || buckled_mob.buckled != src || !user || !user.Adjacent(src))
		return FALSE
	var/is_self = buckled_mob == user
	if(is_self)
		buckled_mob.visible_message(
			span_warning("[buckled_mob] strains against [src], working at the worn iron!"),
			span_notice("I begin working free of [src]. I must hold still."),
			span_hear("I hear chains rattle."),
		)
	else
		buckled_mob.visible_message(
			span_notice("[user] starts working [buckled_mob] free of [src]!"),
			span_notice("[user] starts working me free of [src]!"),
			span_hear("I hear chains rattle."),
		)
	if(!do_after(user, is_self ? self_escape_time : rescue_time, src, interaction_key = "lair_shackles_escape"))
		return FALSE
	if(QDELETED(src) || QDELETED(buckled_mob) || buckled_mob.buckled != src || !user.Adjacent(src))
		return FALSE
	unbuckle_mob(buckled_mob, force = TRUE)
	buckled_mob.visible_message(
		span_notice("[buckled_mob] slips free of [src]!"),
		span_notice("I slip free of [src]!"),
		span_hear("I hear chains fall slack."),
	)
	return TRUE

/obj/structure/bondage/x_pillory
	name = "x-pillory"
	desc = "A brutal restraint shaped like a cross."
	icon = 'modular_rmh/icons/obj/structures/bondage.dmi'
	icon_state = "x_pillory"
	layer = BELOW_MOB_LAYER

/obj/structure/bondage/x_pillory/post_buckle_mob(mob/living/M)
	. = ..()
	M.set_mob_offsets("bed_buckle", _x = 0, _y = 2)

/obj/structure/bondage/gloryhole
	name = "gloryhole"
	desc = "A wooden partition with a suspicious hole."
	icon = 'modular_rmh/icons/obj/structures/bondage.dmi'
	icon_state = "gloryhole"
	density = TRUE
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	buckleverb = "position"

/obj/structure/bondage/gloryhole/post_buckle_mob(mob/living/M)
	. = ..()
	M.dir = NORTH
