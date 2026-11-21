


GLOBAL_LIST_INIT(lipstick_shades, list(
	"#5a151f" = "red",
	"#821d2c" = "red",
	"#3f1462" = "purple",
	"#0f5335" = "jade",
	"#010517" = "black",
	"#27853c" = "green",
	"#241e80" = "blue",
	"#efeff7" = "white",
))

/obj/item/lipstick
	item_weight = 20 GRAMS
	gender = PLURAL
	name = "red lipstick"
	desc = ""
	icon = 'icons/roguetown/items/perfume.dmi'
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	var/colour = "#5a151f"
	var/open = FALSE

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "#3f1462"

/obj/item/lipstick/jade
	name = "jade lipstick"
	colour = "#0f5335"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "#010517"

/obj/item/lipstick/green
	name = "green lipstick"
	colour = "#27853c"

/obj/item/lipstick/blue
	name = "blue lipstick"
	colour = "#241e80"

/obj/item/lipstick/white
	name = "white lipstick"
	colour = "#efeff7"

/obj/item/lipstick/random
	name = "lipstick"
	icon_state = MAP_SWITCH("lipstick", "random_lipstick")

/obj/item/lipstick/random/Initialize()
	. = ..()
	colour = pick("#821d2c","#3f1462","#0f5335","#010517","#27853c","#241e80","#efeff7")
	name = "lipstick"

/obj/item/lipstick/update_icon_state()
	. = ..()
	icon_state = "lipstick[open ? "_uncap" : ""]"

/obj/item/lipstick/update_overlays()
	. = ..()
	if(open)
		var/mutable_appearance/colored_overlay = mutable_appearance(icon, "lipstick_uncap_color")
		colored_overlay.color = colour
		. += colored_overlay

/obj/item/lipstick/attack_self(mob/user, list/modifiers)
	to_chat(user, "<span class='notice'>I twist \the [src] [open ? "closed" : "open"].</span>")
	open = !open
	update_appearance(UPDATE_ICON)

/obj/item/lipstick/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with))
		return NONE

	if(!open)
		return ITEM_INTERACT_BLOCKING

	//RMH EDITED START - away from the mouth, lipstick writes on the skin
	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return write_on_skin(interacting_with, user)
	//RMH EDITED END

	var/mob/living/carbon/human/H = interacting_with

	if(!can_apply_to(H, user))
		return ITEM_INTERACT_BLOCKING

	var/lip_alpha = tgui_input_number(user, "How heavy a coat? 0 is barely there, 255 is the full colour.", "Lipstick", 255, 255, 0)
	if(isnull(lip_alpha) || QDELETED(src) || !can_apply_to(H, user))
		return ITEM_INTERACT_BLOCKING

	if(H == user)
		user.visible_message(
			"<span class='notice'>[user] does [user.p_their()] lips with \the [src].</span>",
			"<span class='notice'>I take a moment to apply \the [src]. Perfect!</span>",
		)
	else
		user.visible_message(
			"<span class='warning'>[user] begins to do [H]'s lips with \the [src].</span>",
			"<span class='notice'>I begin to apply \the [src] on [H]'s lips...</span>",
		)
		if(!do_after(user, 2 SECONDS, H) || !can_apply_to(H, user))
			return ITEM_INTERACT_BLOCKING
		user.visible_message(
			"<span class='notice'>[user] does [H]'s lips with \the [src].</span>",
			"<span class='notice'>I apply \the [src] on [H]'s lips.</span>",
		)

	H.lip_style = "lipstick"
	H.lip_color = colour
	H.lip_alpha = lip_alpha
	H.update_body()

	return ITEM_INTERACT_SUCCESS

/obj/item/lipstick/proc/can_apply_to(mob/living/carbon/human/target, mob/living/user)
	if(!open || !user.is_holding(src) || !user.Adjacent(target))
		return FALSE

	if(target.is_mouth_covered())
		to_chat(user, "<span class='warning'>Remove [ target == user ? "your" : "[target.p_their()]" ] mask!</span>")
		return FALSE

	if(target.lip_style)	//if they already have lipstick on
		to_chat(user, "<span class='warning'>I need to wipe off the old lipstick first!</span>")
		return FALSE

	return TRUE

//you can wipe off lipstick with paper!
/obj/item/paper/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with))
		return NONE

	var/mob/living/carbon/human/H = interacting_with

	if(user.zone_selected != BODY_ZONE_PRECISE_MOUTH || !H.lip_style)
		return H.try_wipe_lipstick_mark(src, user)

	if(H == user)
		to_chat(user, "<span class='notice'>I wipe off the lipstick with [src].</span>")
	else
		user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
							"<span class='notice'>I begin to wipe off [H]'s lipstick...</span>")
		if(!do_after(user, 1 SECONDS, H))
			return ITEM_INTERACT_BLOCKING
		user.visible_message("<span class='notice'>[user] wipes [H]'s lipstick off with \the [src].</span>", \
							"<span class='notice'>I wipe off [H]'s lipstick.</span>")

	H.clean_lips()
	H.clear_lipstick_marks_on_zone(BODY_ZONE_PRECISE_MOUTH)

	return ITEM_INTERACT_SUCCESS
