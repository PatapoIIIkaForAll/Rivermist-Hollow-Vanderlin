/obj/structure/table/proc/drunken_flip(mob/living/carbon/human/user)
	if(!user.has_status_effect(/datum/status_effect/buff/drunken_rage))
		return FALSE
	if(!Adjacent(user))
		return FALSE
	user.visible_message(
		span_danger("[user] flips [src] in a drunken rage!"),
		span_warning("I flip [src] with drunken strength!"))
	playsound(src, 'sound/combat/hits/onwood/woodimpact (1).ogg', 100, TRUE)
	anchored = FALSE
	var/throw_dir = get_dir(user, src)
	var/turf/target_turf = get_ranged_target_turf(src, throw_dir, 2)
	src.throw_at(target_turf, 2, 3, user)
	for(var/mob/living/L in get_turf(src))
		if(L == user)
			continue
		L.Knockdown(20)
		L.apply_damage(10, BRUTE)
		L.visible_message(span_danger("[L] is knocked down by the flying table!"))
	return TRUE

/mob/living/carbon/human/proc/drunken_push(mob/living/target)
	if(!has_status_effect(/datum/status_effect/buff/drunken_rage))
		return FALSE
	if(!Adjacent(target))
		return FALSE
	var/throw_dir = get_dir(src, target)
	var/turf/target_turf = get_ranged_target_turf(target, throw_dir, 3)
	target.visible_message(
		span_danger("[src] shoves [target] away with drunken might!"),
		span_danger("[src] shoves me away with tremendous force!"))
	target.throw_at(target_turf, 3, 2, src)
	target.Knockdown(15)
	playsound(target, 'sound/combat/hits/kick/kick.ogg', 80, TRUE)
	return TRUE
