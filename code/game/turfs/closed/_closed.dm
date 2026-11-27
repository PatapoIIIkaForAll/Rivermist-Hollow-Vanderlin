/turf/closed
	name = ""
	icon_state = "black"
	layer = CLOSED_TURF_LAYER
	opacity = 1
	density = TRUE
	blocks_air = TRUE
	baseturfs = /turf/open/floor/naturalstone
	smoothing_groups = SMOOTH_GROUP_CLOSED
	pass_flags_self = PASSCLOSEDTURF
	plane = WALL_PLANE

	var/above_floor
	var/wallpress = TRUE
	var/wallclimb = FALSE
	var/climbdiff = 0

	var/obj/effect/skill_tracker/thieves_cant/thieves_marking

/turf/closed/basic
	baseturfs = /turf/closed/basic

/turf/closed/basic/New()//Do not convert to Initialize
	SHOULD_CALL_PARENT(FALSE)
	//This is used to optimize the map loader
	return

/turf/closed/examine(mob/user)
	. = ..()
	if(thieves_marking)
		if(thieves_marking.can_see(user))
			thieves_marking.examine(user)

/turf/closed/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!wallpress)
		return
	if(user == O && isliving(O))
		var/mob/living/L = O
		if(isanimal(L))
			var/mob/living/simple_animal/A = L
			if (!A.dextrous)
				return
		if(!HAS_TRAIT(L, TRAIT_IMMOBILIZED))
			wallpress(L)
			return

/turf/closed/get_explosion_resistance()
	return 1000000

/turf/closed/proc/feel_turf(mob/living/user)
	to_chat(user, span_notice("I start feeling around [src]"))
	if(!do_after(user, 1.5 SECONDS, src))
		return

	for(var/obj/structure/lever/hidden/lever in contents)
		lever.feel_button(user)

/turf/closed/proc/wallpress(mob/living/user)
	if(user.wallpressed)
		return
	if(user.body_position == LYING_DOWN)
		return
	var/dir2wall = get_dir(user,src)
	if(!(dir2wall in GLOB.cardinals))
		return
	user.wallpressed = dir2wall
	user.update_wallpress_slowdown()
	if(user.m_intent == MOVE_INTENT_SNEAK)
		to_chat(user, span_info("You press yourself against [src]."))
	else
		user.visible_message(span_info("[user] leans against [src]."))
	switch(dir2wall)
		if(NORTH)
			user.setDir(SOUTH)
			user.set_mob_offsets("wall_press", _x = 0, _y = 20)
		if(SOUTH)
			user.setDir(NORTH)
			user.set_mob_offsets("wall_press", _x = 0, _y = -10)
		if(EAST)
			user.setDir(WEST)
			user.set_mob_offsets("wall_press", _x = 12, _y = 0)
		if(WEST)
			user.setDir(EAST)
			user.set_mob_offsets("wall_press", _x = -12, _y = 0)

/turf/closed/proc/wallshove(mob/living/user)
	if(user.wallpressed)
		return
	if(user.body_position == LYING_DOWN)
		return
	var/dir2wall = get_dir(user,src)
	if(!(dir2wall in GLOB.cardinals))
		return
	user.wallpressed = dir2wall
	user.update_wallpress_slowdown()
	switch(dir2wall)
		if(NORTH)
			user.setDir(NORTH)
			user.set_mob_offsets("wall_press", _x = 0, _y = 20)
		if(SOUTH)
			user.setDir(SOUTH)
			user.set_mob_offsets("wall_press", _x = 0, _y = -10)
		if(EAST)
			user.setDir(EAST)
			user.set_mob_offsets("wall_press", _x = 12, _y = 0)
		if(WEST)
			user.setDir(WEST)
			user.set_mob_offsets("wall_press", _x = -12, _y = 0)

/mob/living/proc/update_wallpress_slowdown()
	if(wallpressed)
		add_movespeed_modifier("wallpress", TRUE, 100, override = TRUE, multiplicative_slowdown = 3)
		if(m_intent == MOVE_INTENT_SNEAK)
			ADD_TRAIT(src, TRAIT_SPELLBLOCK, TRAIT_GENERIC) // spell restrictions don't seem to be working well so I'm doing it this way for now
			var/lean_alpha = get_wallpress_alpha()
			if(src.alpha != 0 && lean_alpha < src.alpha)
				var/used_time = 50
				used_time = max(used_time - (GET_MOB_SKILL_VALUE_OLD(src, /datum/attribute/skill/misc/sneaking) * 8), 10)
				animate(src, alpha = lean_alpha, time = used_time)
	else
		remove_movespeed_modifier("wallpress")
		animate(src, alpha = 255, time = 10)
		REMOVE_TRAIT(src, TRAIT_SPELLBLOCK, TRAIT_GENERIC)

/turf/closed/Bumped(atom/movable/AM)
	..()
	if(density)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.dir == get_dir(H,src) && (H.m_intent == MOVE_INTENT_RUN || HAS_TRAIT(H, TRAIT_STUMBLE)) && H.body_position != LYING_DOWN)
				H.Immobilize(10)
				H.apply_damage(15, BRUTE, BODY_ZONE_HEAD, H.run_armor_check("head", "blunt", damage = 15), damage_type = BCLASS_BLUNT)
				H.toggle_rogmove_intent(MOVE_INTENT_WALK, TRUE)
				playsound(src, "genblunt", 100, TRUE)
				H.visible_message("<span class='warning'>[H] runs into [src]!</span>", "<span class='warning'>I run into [src]!</span>")
				addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, Knockdown), 10), 10)

/turf/closed/Initialize()
	. = ..()
	// One shared list for each wall type, in place of one copy for each wall.
	if(islist(attacked_sound))
		attacked_sound = typelist("attacked_sound", attacked_sound)
	if(above_floor)
		var/turf/open/openspace/target = GET_TURF_ABOVE(src)
		if(istype(target))
			target.ChangeTurf(above_floor)

/turf/closed/Destroy()
	if(above_floor)
		var/turf/above = GET_TURF_ABOVE(src)
		if(above)
			if(istype(above, above_floor))
				var/count
				for(var/D in GLOB.cardinals)
					var/turf/T = get_step(above, D)
					if(T)
						var/turf/closed/C = GET_TURF_BELOW(T)
						if(istype(C))
							count++
					if(count >= 2)
						break
				if(count < 2)
					above.ScrapeAway()
	. = ..()

/turf/closed/attack_paw(mob/user)
	return attack_hand(user)

/turf/closed/attack_hand(mob/user)
	if(!wallclimb)
		return ..()
	if(isliving(user))
		try_wallclimb(user)

/// Whether walking into this wall may start a climb.
/turf/closed/proc/can_bump_climb(mob/living/climber)
	return wallclimb

/// Climbs this wall up a z-level; feedback FALSE hides the failure messages.
/turf/closed/proc/try_wallclimb(mob/living/climber, feedback = TRUE)
	var/turf/user_turf = get_turf(climber)
	var/climbsound = 'sound/foley/climb.ogg'
	if(climber.stat != CONSCIOUS)
		return
	var/turf/target = GET_TURF_ABOVE(user_turf)
	if(!istype(target, /turf/open/openspace))
		if(feedback)
			to_chat(climber, "<span class='warning'>I can't climb here.</span>")
		return
	if(!climber.can_z_move(UP, user_turf, target, feedback ? (Z_MOVE_CLIMBING_FLAGS | ZMOVE_FEEDBACK) : Z_MOVE_CLIMBING_FLAGS))
		if(feedback)
			to_chat(climber, "<span class='warning'>I can't climb there.</span>")
		return
	target = GET_TURF_ABOVE(src)
	if(!target || istype(target, /turf/closed) || istype(target, /turf/open/openspace))
		target = GET_TURF_ABOVE(user_turf)
		if(!target || !istype(target, /turf/open/openspace))
			if(feedback)
				to_chat(climber, "<span class='warning'>I can't climb here.</span>")
			return
	for(var/obj/structure/F in target)
		if(F && (F.density && !F.climbable))
			if(feedback)
				to_chat(climber, "<span class='warning'>I can't climb here.</span>")
			return
	var/used_time = 0
	var/amt2raise = 0
	var/boon = 0
	if(climber.mind)
		var/myskill = GET_MOB_SKILL_VALUE_OLD(climber, /datum/attribute/skill/misc/climbing)
		amt2raise = floor(GET_MOB_ATTRIBUTE_VALUE(climber, STAT_INTELLIGENCE)/2)
		boon = climber.get_learning_boon(/datum/attribute/skill/misc/climbing)
		var/obj/structure/table/TA = locate() in climber.loc
		if(TA)
			myskill += 1
		else
			var/obj/structure/chair/CH = locate() in climber.loc
			if(CH)
				myskill += 1
			var/obj/structure/wallladder/WL = locate() in climber.loc
			if(WL)
				if(get_dir(WL.loc,src) == WL.dir)
					myskill += 8
					climbsound = 'sound/foley/ladder.ogg'

		if(myskill < climbdiff)
			if(feedback)
				to_chat(climber, "<span class='warning'>I'm not capable of climbing this.</span>")
			return
		used_time = max(70 - (myskill * 10) - (GET_MOB_ATTRIBUTE_VALUE(climber, STAT_SPEED) * 3), 30)
	if(climber.m_intent != MOVE_INTENT_SNEAK)
		playsound(climber, climbsound, 100, TRUE)
	climber.visible_message("<span class='warning'>[climber] starts to climb [src].</span>", "<span class='warning'>I start to climb [src]...</span>")
	if(do_after(climber, used_time, src))
		// The passage is above the climber; target is the landing turf above the wall.
		var/turf/current_turf = get_turf(climber)
		if(!climber.can_z_move(UP, current_turf, GET_TURF_ABOVE(current_turf), Z_MOVE_CLIMBING_FLAGS | ZMOVE_FEEDBACK))
			return
		climber.set_currently_z_moving(CURRENTLY_Z_ASCENDING)
		if(!climber.zMove(UP, target, Z_MOVE_CLIMBING_FLAGS))
			return
		if(climber.m_intent != MOVE_INTENT_SNEAK)
			playsound(climber, 'sound/foley/climb.ogg', 100, TRUE)
		if(climber.mind)
			climber.adjust_experience(/datum/attribute/skill/misc/climbing, floor(amt2raise * boon), FALSE)

/turf/closed/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	feel_turf(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/turf/closed/attack_ghost(mob/dead/observer/user)
	if(!user.Adjacent(src))
		return
	var/turf/target = GET_TURF_ABOVE(get_turf(user))
	if(!target)
		to_chat(user, "<span class='warning'>I can't go there.</span>")
		return
	if(!istype(target, /turf/open/openspace))
		to_chat(user, "<span class='warning'>I can't go there.</span>")
		return
	if(user.can_z_move(UP, get_turf(user), target, ZMOVE_IGNORE_OBSTACLES | ZMOVE_FEEDBACK))
		user.zMove(UP, target, ZMOVE_IGNORE_OBSTACLES)
		to_chat(user, "<span class='warning'>I crawl up the wall.</span>")
	. = ..()

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/closed/indestructible
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	explosion_block = 50

/turf/closed/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/closed/indestructible/acid_act(acidpwr, acid_volume, acid_id)
	return 0

/turf/closed/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

// Dakkatown Turfs
/turf/closed/indestructible/wooddark
	name = "wall"
	desc = ""
	icon = 'icons/turf/walls.dmi'
	icon_state = "corner"

/turf/closed/indestructible/roguewindow
	name = "window"
	desc = ""
	opacity = 0
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "window-solid"

// Boat
/turf/closed/indestructible/wooddark/hull
	name = "hull"
	color = "#d6d5a8"

/turf/closed/indestructible/wooddark/mast
	name = "mast"
	color = "#a6a68b"
