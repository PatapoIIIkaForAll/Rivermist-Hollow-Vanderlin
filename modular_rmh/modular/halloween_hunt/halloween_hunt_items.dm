#define HUNT_ICON 'modular_rmh/modular/halloween_hunt/halloween_hunt.dmi'
#define HUNT_ONMOB_ICON 'modular_rmh/modular/halloween_hunt/halloween_hunt_onmob.dmi'
#define HUNT_BASKET_FULL 20
#define HUNT_POUR_AMOUNT 5
#define HUNT_STEAL_AMOUNT 3
#define HUNT_SCOOP_LIMIT 25

GLOBAL_LIST_EMPTY(halloween_hunt_baskets)
GLOBAL_LIST_EMPTY(halloween_hunt_candies)

// Candy ----------------------------------------------------------------------

/obj/item/reagent_containers/food/snacks/hunt_candy
	name = "wrapped sweet"
	desc = "A twist of spooky candy. Stuff it into a pumpkin basket to count it for the Candy Hunt."
	icon = HUNT_ICON
	icon_state = "hunt_candy_purple"
	w_class = WEIGHT_CLASS_TINY
	item_weight = 10 GRAMS
	bitesize = 1
	nutrition = 1
	vitamin = 0
	list_reagents = list(/datum/reagent/consumable/sugar = 2)
	tastes = list("spooky sugar" = 1)
	foodtype = SUGAR
	eat_effect = /datum/status_effect/buff/hunt_sugar_rush
	/// How much this candy adds to a basket.
	var/points = 1
	/// Picks a random wrapper on spawn.
	var/random_look = TRUE

/obj/item/reagent_containers/food/snacks/hunt_candy/Initialize(mapload)
	. = ..()
	GLOB.halloween_hunt_candies += src
	if(random_look)
		switch(rand(1, 5))
			if(1)
				icon_state = "hunt_candy_purple"
			if(2)
				icon_state = "hunt_candy_orange"
			if(3)
				icon_state = "hunt_candy_green"
			if(4)
				name = "candy corn"
				icon_state = "hunt_candy_corn"
			if(5)
				name = "swirl lollipop"
				icon_state = "hunt_candy_lolly"
	if(isturf(loc))
		pixel_x = rand(-8, 8)
		pixel_y = rand(-6, 6)

/obj/item/reagent_containers/food/snacks/hunt_candy/Destroy()
	GLOB.halloween_hunt_candies -= src
	return ..()

/obj/item/reagent_containers/food/snacks/hunt_candy/examine(mob/user)
	. = ..()
	. += span_notice("It is worth [points] in a pumpkin basket. Eating it gives a sugar rush, but it no longer counts.")

/obj/item/reagent_containers/food/snacks/hunt_candy/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!QDELETED(src) && isturf(loc))
		GLOB.halloween_hunt?.on_candy_landed(src, throwingdatum?.get_thrower())

/obj/item/reagent_containers/food/snacks/hunt_candy/toffee
	name = "golden toffee"
	desc = "A rare toffee in gold foil. It counts five times over in a pumpkin basket."
	icon_state = "hunt_candy_toffee"
	points = 5
	random_look = FALSE

/datum/status_effect/buff/hunt_sugar_rush
	id = "hunt_sugar_rush"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/buff/hunt_sugar_rush
	duration = 10 SECONDS

/atom/movable/screen/alert/status_effect/buff/hunt_sugar_rush
	name = "Sugar Rush"
	desc = span_nicegreen("Sweet, spooky energy! My feet are quick.")
	icon_state = "buff"

/datum/status_effect/buff/hunt_sugar_rush/on_apply()
	. = ..()
	owner.add_movespeed_modifier(MOVESPEED_ID_STATUS_EFFECT(id), multiplicative_slowdown = -0.4)
	owner.add_stress(/datum/stress_event/hunt_spooky_candy)
	to_chat(owner, span_nicegreen("Sugar rush!"))

/datum/status_effect/buff/hunt_sugar_rush/on_remove()
	. = ..()
	owner?.remove_movespeed_modifier(MOVESPEED_ID_STATUS_EFFECT(id))

/datum/stress_event/hunt_spooky_candy
	timer = 10 MINUTES
	stress_change = -2
	desc = span_green("Spooky candy! Sweet and scary.")

// Pumpkin basket ---------------------------------------------------------------

/obj/item/hunt_basket
	name = "pumpkin basket"
	desc = "A carved pumpkin with a handle and a ribbon, made to hold candy."
	icon = HUNT_ICON
	icon_state = "hunt_basket_0"
	w_class = WEIGHT_CLASS_NORMAL
	item_weight = 300 GRAMS
	slot_flags = ITEM_SLOT_HIP
	experimental_onhip = TRUE
	grid_width = 32
	grid_height = 64
	force = 0
	throwforce = 0
	item_flags = NOBLUDGEON
	light_system = MOVABLE_LIGHT
	light_outer_range = 2
	light_power = 1
	light_color = "#ffb060"
	light_on = FALSE
	/// Candy inside; only the number is kept.
	var/candy = 0
	var/datum/weakref/owner_mind
	var/owner_name
	var/owner_ckey
	/// The leader's basket grins with candle light.
	var/lit = FALSE

/obj/item/hunt_basket/Initialize(mapload)
	. = ..()
	GLOB.halloween_hunt_baskets += src

/obj/item/hunt_basket/Destroy()
	GLOB.halloween_hunt_baskets -= src
	GLOB.halloween_hunt?.on_basket_destroyed(src)
	owner_mind = null
	return ..()

/obj/item/hunt_basket/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.65,"sx" = -6,"sy" = -4,"nx" = 6,"ny" = -4,"wx" = -2,"wy" = -4,"ex" = 1,"ey" = -4,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.6,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/hunt_basket/update_icon_state()
	var/fill = 0
	if(candy >= HUNT_BASKET_FULL)
		fill = 2
	else if(candy > 0)
		fill = 1
	icon_state = "hunt_basket_[fill][lit ? "_lit" : ""]"
	return ..()

/obj/item/hunt_basket/examine(mob/user)
	. = ..()
	if(owner_name)
		. += span_notice("It belongs to [owner_name].")
	. += span_notice("It holds <b>[candy]</b> candy.")
	if(lit)
		. += span_love("Its grin glows: this is the fullest basket in the Hollow!")
	. += span_info("Click candy with it to scoop, or put candy into it by hand. Use it in hand to take one candy out.")
	. += span_info("Use it on a person, or on another basket, to pour candy into your own basket a little at a time.")

/obj/item/hunt_basket/proc/bind_to(mob/living/carbon/human/owner)
	owner_mind = WEAKREF(owner.mind)
	owner_name = owner.real_name
	owner_ckey = owner.ckey
	name = "[owner_name]'s pumpkin basket"

/obj/item/hunt_basket/proc/get_owner_mind()
	return owner_mind?.resolve()

/obj/item/hunt_basket/proc/is_owned_by(mob/user)
	return user?.mind && get_owner_mind() == user.mind

/obj/item/hunt_basket/proc/set_candy(amount)
	candy = max(0, round(amount))
	refresh_look()

/obj/item/hunt_basket/proc/set_lit(new_lit)
	if(lit == new_lit)
		return
	lit = new_lit
	set_light_on(lit)
	refresh_look()

/obj/item/hunt_basket/proc/refresh_look()
	update_appearance(UPDATE_ICON_STATE)
	if(ismob(loc))
		var/mob/holder = loc
		holder.update_inv_hands()
		holder.update_inv_belt()

/obj/item/hunt_basket/attack_self(mob/user, list/modifiers)
	if(candy <= 0)
		to_chat(user, span_warning("[src] is empty."))
		return TRUE
	set_candy(candy - 1)
	var/obj/item/reagent_containers/food/snacks/hunt_candy/treat = new(get_turf(user))
	user.put_in_hands(treat)
	to_chat(user, span_notice("I take [treat] out of [src]. It no longer counts. ([candy] left)"))
	return TRUE

/obj/item/hunt_basket/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/reagent_containers/food/snacks/hunt_candy))
		stuff_candy(tool, user)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/hunt_basket))
		var/obj/item/hunt_basket/other = tool
		// Pouring always fills the user's own basket when one of the two is theirs.
		if(other.is_owned_by(user) && !is_owned_by(user))
			INVOKE_ASYNC(src, PROC_REF(pour_into), other, user, HUNT_POUR_AMOUNT)
		else
			INVOKE_ASYNC(other, PROC_REF(pour_into), src, user, HUNT_POUR_AMOUNT)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/hunt_basket/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/reagent_containers/food/snacks/hunt_candy) && isturf(interacting_with.loc))
		return scoop_turf(interacting_with.loc, user) ? ITEM_INTERACT_SUCCESS : NONE
	if(isturf(interacting_with))
		return scoop_turf(interacting_with, user) ? ITEM_INTERACT_SUCCESS : NONE
	if(ishuman(interacting_with) && interacting_with != user && !user.cmode)
		var/obj/item/hunt_basket/their_basket = find_hunt_basket(interacting_with)
		if(their_basket)
			INVOKE_ASYNC(their_basket, PROC_REF(pour_into), src, user, HUNT_STEAL_AMOUNT, interacting_with)
			return ITEM_INTERACT_SUCCESS
	return NONE

/// Moves one candy item into the basket.
/obj/item/hunt_basket/proc/stuff_candy(obj/item/reagent_containers/food/snacks/hunt_candy/treat, mob/user, quiet = FALSE)
	if(QDELETED(treat))
		return 0
	var/gained = treat.points
	if(ismob(treat.loc))
		var/mob/holder = treat.loc
		holder.temporarilyRemoveItemFromInventory(treat, TRUE)
	qdel(treat)
	set_candy(candy + gained)
	if(!quiet)
		playsound(src, 'sound/foley/dropsound/food_drop.ogg', 30, TRUE, -2)
		to_chat(user, span_notice("I stuff the candy into [src]. ([candy] inside)"))
	GLOB.halloween_hunt?.on_basket_changed(src)
	return gained

/obj/item/hunt_basket/proc/scoop_turf(turf/target, mob/user)
	var/scooped = 0
	var/count = 0
	for(var/obj/item/reagent_containers/food/snacks/hunt_candy/treat in target)
		if(count >= HUNT_SCOOP_LIMIT)
			break
		scooped += stuff_candy(treat, user, TRUE)
		count++
	if(!count)
		return FALSE
	playsound(src, 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -2)
	user.visible_message(span_notice("[user] scoops candy into [src]."), span_notice("I scoop [scooped] candy into [src]. ([candy] inside)"))
	return TRUE

/// Pours up to amount candy from src into receiver after a short struggle. Victim is the person wearing src, if any.
/obj/item/hunt_basket/proc/pour_into(obj/item/hunt_basket/receiver, mob/living/user, amount, atom/victim)
	if(receiver == src || QDELETED(receiver))
		return
	if(candy <= 0)
		to_chat(user, span_warning("[src] is empty."))
		return
	var/is_theft = ismob(victim)
	if(is_theft)
		to_chat(victim, span_userdanger("[user] is dipping into my pumpkin basket!"))
		user.visible_message(span_warning("[user] dips [receiver] into [victim]'s pumpkin basket!"), span_notice("I dip into [victim]'s pumpkin basket..."))
	if(!do_after(user, is_theft ? 2.5 SECONDS : 1.5 SECONDS, victim || src))
		return
	if(is_theft && find_hunt_basket(victim) != src)
		return
	var/moved = min(amount, candy)
	if(moved <= 0)
		return
	set_candy(candy - moved)
	receiver.set_candy(receiver.candy + moved)
	playsound(receiver, 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -2)
	to_chat(user, span_notice("I pour [moved] candy into [receiver]. ([receiver.candy] inside)"))
	if(is_theft)
		to_chat(victim, span_warning("[user] made off with [moved] of my candy!"))
	GLOB.halloween_hunt?.on_basket_changed(src)
	GLOB.halloween_hunt?.on_basket_changed(receiver)

/// Throws amount candy out of the basket onto nearby tiles; returns how many flew out.
/obj/item/hunt_basket/proc/scatter(amount)
	amount = min(amount, candy)
	if(amount <= 0)
		return 0
	set_candy(candy - amount)
	var/turf/origin = get_turf(src)
	var/list/landing = list()
	for(var/turf/open/spot in range(2, origin))
		if(!spot.is_blocked_turf(TRUE))
			landing += spot
	for(var/i in 1 to amount)
		var/obj/item/reagent_containers/food/snacks/hunt_candy/treat = new(origin)
		if(length(landing))
			treat.throw_at(pick(landing), 3, 1, spin = TRUE)
	GLOB.halloween_hunt?.on_basket_changed(src)
	return amount

/// Returns the hunt basket a person holds or wears on a hip.
/proc/find_hunt_basket(mob/living/carbon/human/person)
	if(!ishuman(person))
		return null
	for(var/obj/item/hunt_basket/basket in person.held_items)
		return basket
	if(istype(person.beltr, /obj/item/hunt_basket))
		return person.beltr
	if(istype(person.beltl, /obj/item/hunt_basket))
		return person.beltl
	return null

// Prizes -----------------------------------------------------------------------

/obj/item/clothing/head/hunt_pumpkin_crown
	name = "crown of the Pumpkin Monarch"
	desc = "A grinning jack-o'-lantern helm under a little golden crown. Awarded to the best candy hunter of the Hollow."
	icon = HUNT_ICON
	mob_overlay_icon = HUNT_ONMOB_ICON
	icon_state = "hunt_pumpkin_crown"
	item_weight = 900 GRAMS
	// No HIDEFACE: the Monarch stays recognisable and keeps the title on display.
	flags_inv = HIDEEARS|HIDEHAIR|HIDEFACIALHAIR
	body_parts_covered = FULL_HEAD
	dynamic_hair_suffix = ""
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_outer_range = 3
	light_power = 1
	light_color = "#ffb272"
	sellprice = 25
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/head/hunt_pumpkin_crown/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -6,"sy" = -4,"nx" = 6,"ny" = -4,"wx" = -2,"wy" = -4,"ex" = 1,"ey" = -4,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0)

/// Spawns a lit pumpkin lamptern with a random face and a full candle.
/proc/make_hunt_prize_lantern(atom/location)
	var/static/list/faces = list(
		/obj/item/flashlight/flare/torch/lantern/pumpkin,
		/obj/item/flashlight/flare/torch/lantern/pumpkin/grin,
		/obj/item/flashlight/flare/torch/lantern/pumpkin/frown,
		/obj/item/flashlight/flare/torch/lantern/pumpkin/surprise,
		/obj/item/flashlight/flare/torch/lantern/pumpkin/woozy,
	)
	var/path = pick(faces)
	var/obj/item/flashlight/flare/torch/lantern/pumpkin/lamp = new path(location)
	lamp.fuel = 120 MINUTES
	lamp.spark_act()
	return lamp

#undef HUNT_ICON
#undef HUNT_ONMOB_ICON
#undef HUNT_BASKET_FULL
#undef HUNT_POUR_AMOUNT
#undef HUNT_STEAL_AMOUNT
#undef HUNT_SCOOP_LIMIT
