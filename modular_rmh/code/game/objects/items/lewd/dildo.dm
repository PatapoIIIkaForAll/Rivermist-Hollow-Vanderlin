/obj/item/dildo
	name = "unfinished dildo"
	desc = "You have to finish it first."
	icon = 'modular_rmh/icons/obj/lewd/dildo.dmi'
	icon_state = "unfinished"
	item_state = "dildo"
	lefthand_file = 'modular_rmh/icons/mob/lewd/items_lefthand.dmi'
	righthand_file = 'modular_rmh/icons/mob/lewd/items_righthand.dmi'
	force = 1
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CAN_BE_HIT
	sellprice = 1
	// The sprite is drawn large for the inventory; in the world it is a third of that.
	dropshrink = 0.4
	var/dildo_type = "human"
	var/dildo_size = "small"
	var/pleasure = 4
	var/can_custom = TRUE
	var/dildo_material
	var/shape_choice
	var/size_choice
	// Worn only through a strap-on harness, which seats the toy in its ring.
	slot_flags = NONE

/obj/item/dildo/New()
	. = ..()
	name = "unfinished [dildo_material] dildo"

/obj/item/dildo/attack_self(mob/living/user)
	. = ..()
	if(!istype(user))
		return
	if(can_custom)
		customize(user)

/obj/item/dildo/proc/customize(mob/living/user)
	if(!can_custom)
		return FALSE
	if(src && !user.incapacitated() && in_range(user,src))
		var/shape_choice = input(user, "Choose a shape for your dildo.","Dildo Shape") as null|anything in list("knotted", "human", "flared")
		if(src && shape_choice && !user.incapacitated() && in_range(user,src))
			dildo_type = shape_choice
	update_appearance()
	if(src && !user.incapacitated() && in_range(user,src))
		var/size_choice = input(user, "Choose a size for your dildo.","Dildo Size") as null|anything in list("small", "medium", "big")
		if(src && size_choice && !user.incapacitated() && in_range(user,src))
			dildo_size = size_choice
			switch(dildo_size)
				if("small")
					pleasure = 4
				if("medium")
					pleasure = 6
				if("big")
					pleasure = 8
	// Storage bulk follows the girth of the chosen size.
	body_storage_bulk = max(1, round(get_insert_girth() / ORIFICE_BULK_PER_CM))
	update_appearance()
	can_custom = FALSE
	return TRUE

/obj/item/dildo/update_appearance()
	. = ..()
	icon_state = get_toy_icon_state()
	name = "[dildo_size] [dildo_type] [dildo_material] dildo"
	desc = "To quench the woman's thirst."

/obj/item/dildo/wood
	color = "#7D4033"
	resistance_flags = FLAMMABLE
	dildo_material = "wooden"
	sellprice = 1

/obj/item/dildo/iron
	color = "#9EA48E"
	dildo_material = "iron"
	sellprice = 5

/obj/item/dildo/steel
	color = "#9BADB7"
	dildo_material = "steel"
	sellprice = 10

/obj/item/dildo/silver/
	color = "#C6D5E1"
	dildo_material = "silver"
	sellprice = 30

/obj/item/dildo/silver/pickup(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(!ishuman(H) || !H.mind)
		return
	var/datum/antagonist/vampire/V_lord = H.mind.has_antag_datum(/datum/antagonist/vampire/)
	var/datum/antagonist/werewolf/W = H.mind.has_antag_datum(/datum/antagonist/werewolf/)
	if(ishuman(H))
		if(H.mind.has_antag_datum(/datum/antagonist/vampire))
			to_chat(H, span_userdanger("The silver sizzles and burns my hand!"))
			H.adjustFireLoss(35)
		if(V_lord)
			//if(V_lord.vamplevel < 4 && !H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
			to_chat(H, span_userdanger("The silver sizzles in my hand..."))
			H.adjustFireLoss(15)
		if(W && W.transformed == TRUE)
			to_chat(H, span_userdanger("The silver sizzles and burns my hand!"))
			H.adjustFireLoss(25)

/obj/item/dildo/silver/funny_attack_effects(mob/living/target, mob/living/user = usr, nodmg)
	if(world.time < src.last_used + 100)
		to_chat(user, span_notice("The silver needs more time to purify again."))
		return

	. = ..()
	if(ishuman(target) && target.mind)
		//var/mob/living/carbon/human/s_user = user
		var/mob/living/carbon/human/H = target
		var/datum/antagonist/werewolf/W = H.mind.has_antag_datum(/datum/antagonist/werewolf/)
		var/datum/antagonist/vampire/Vp = H.mind.has_antag_datum(/datum/antagonist/vampire)
		//var/datum/antagonist/vampirelord/lesser/V = H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser)
		//var/datum/antagonist/vampirelord/V_lord = H.mind.has_antag_datum(/datum/antagonist/vampirelord/)
		if(Vp)
			H.Stun(20)
			to_chat(H, span_userdanger("The silver burns me!"))
			H.adjustFireLoss(30)
			H.Paralyze(20)
			H.fire_act(1,4)
			H.apply_status_effect(/datum/status_effect/debuff/silver_bane)
			src.last_used = world.time
		/*if(V)
			if(V.disguised)
				H.Stun(20)
				H.visible_message("<font color='white'>The silver weapon manifests the [H] curse!</font>")
				to_chat(H, span_userdanger("The silver burns me!"))
				H.adjustFireLoss(30)
				H.Paralyze(20)
				H.fire_act(1,4)
				//H.apply_status_effect(/datum/status_effect/debuff/silver_bane)
				src.last_used = world.time
			else
				H.Stun(20)
				to_chat(H, span_userdanger("The silver burns me!"))
				H.adjustFireLoss(30)
				H.Paralyze(20)
				H.fire_act(1,4)
				//H.apply_status_effect(/datum/status_effect/debuff/silver_bane)
				src.last_used = world.time
		if(V_lord)
			if(V_lord.vamplevel < 4 && !V)
				if(V_lord.disguised)
					H.visible_message("<font color='white'>The silver weapon manifests the [H] curse!</font>")
				to_chat(H, span_userdanger("The silver burns me!"))
				H.Stun(10)
				H.adjustFireLoss(25)
				H.Paralyze(10)
				H.fire_act(1,4)
				src.last_used = world.time
			if(V_lord.vamplevel == 4 && !V)
				s_user.Stun(10)
				s_user.Paralyze(10)
				to_chat(s_user, "<font color='red'> The silver weapon fails!</font>")
				H.visible_message(H, span_userdanger("This feeble metal can't hurt me, I AM THE ANCIENT!"))*/
		if(W && W.transformed == TRUE)
			H.Stun(40)
			H.Paralyze(40)
			to_chat(H, span_userdanger("The silver burns me!"))
			src.last_used = world.time

/obj/item/dildo/gold
	color = "#b38f1b"
	dildo_material = "golden"
	sellprice = 50
