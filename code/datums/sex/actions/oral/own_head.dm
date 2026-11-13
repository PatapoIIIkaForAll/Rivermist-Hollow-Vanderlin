// Self-oral for a headless dullahan holding their own head. Each variant unlocks the base
// action's self-use rule and adds flavour that names the head.

/// TRUE when `user` is a headless dullahan with their own head in hand.
/proc/holds_own_dullahan_head(mob/living/user)
	var/obj/item/bodypart/head/dullahan/head = get_detached_dullahan_head(user)
	return head && user.is_holding(head)

/datum/sex_action/blowjob/own_head
	name = "Self-blowjob"
	description = "Bring your own severed head down and suck yourself off."

/datum/sex_action/blowjob/own_head/allows_self_use(mob/living/user)
	return holds_own_dullahan_head(user)

/datum/sex_action/blowjob/own_head/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	return ..()

/datum/sex_action/cunnilingus/own_head
	name = "Self-cunnilingus"
	description = "Bring your own severed head down and eat yourself out."

/datum/sex_action/cunnilingus/own_head/allows_self_use(mob/living/user)
	return holds_own_dullahan_head(user)

/datum/sex_action/cunnilingus/own_head/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	return ..()

/datum/sex_action/rimming/own_head
	name = "Self-rimjob"
	description = "Reach your own severed head around behind you."

/datum/sex_action/rimming/own_head/allows_self_use(mob/living/user)
	return holds_own_dullahan_head(user)

/datum/sex_action/rimming/own_head/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	return ..()

/datum/sex_action/suck_nipples/own_head
	name = "Self-suckle"
	description = "Hold your own severed head to your chest."

/datum/sex_action/suck_nipples/own_head/allows_self_use(mob/living/user)
	return holds_own_dullahan_head(user)

/datum/sex_action/suck_nipples/own_head/shows_on_menu(mob/living/user, mob/living/target)
	if(user != target)
		return FALSE
	return ..()
