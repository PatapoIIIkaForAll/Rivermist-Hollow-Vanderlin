// Carved pumpkin lanterns, worn on the head and fuelled by a candle.

/obj/item/flashlight/flare/torch/lantern/pumpkin
	name = "pumpkin lamptern"
	desc = "A decorated pumpkin shell. Usually seasonal, a frightful beacon in the night."
	icon = 'modular_rmh/modular/pumpkins/icons/pumpkin_lanterns.dmi'
	mob_overlay_icon = 'modular_rmh/modular/pumpkins/icons/pumpkin_lanterns_onmob.dmi'
	icon_state = "pumpkinlamp"
	item_state = "pumpkinlamp"
	grid_width = 64
	grid_height = 32
	w_class = WEIGHT_CLASS_SMALL
	light_color = "#ffb272ff"
	on = FALSE
	slot_flags = ITEM_SLOT_HEAD
	flags_inv = HIDEFACE|HIDEEARS|HIDEHAIR|HIDEFACIALHAIR
	body_parts_covered = FULL_HEAD
	block2add = FOV_BEHIND
	equip_delay_self = 3 SECONDS
	unequip_delay_self = 3 SECONDS
	force = 1
	on_damage = 3
	wdefense = 1
	fuel = 0 MINUTES
	should_self_destruct = FALSE
	sellprice = 8
	dropshrink = null
	melting_material = null // The base lantern smelts into iron.
	var/start_lit = FALSE

/obj/item/flashlight/flare/torch/lantern/pumpkin/Initialize(mapload)
	. = ..()
	if(start_lit && mapload)
		fuel = 120 MINUTES
		spark_act()

/obj/item/flashlight/flare/torch/lantern/pumpkin/examine(mob/user)
	. = ..()
	if(fuel <= 0)
		. += span_smallnotice("It looks like it could use a new candle.")

/obj/item/flashlight/flare/torch/lantern/pumpkin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Put a candle inside to fuel it; a lit candle lights it at once. Gold, silver and other everburning candles do not fit.")

/obj/item/flashlight/flare/torch/lantern/pumpkin/update_brightness(mob/user)
	. = ..()
	item_state = icon_state
	if(iscarbon(loc))
		var/mob/living/carbon/wearer = loc
		if(src == wearer.head)
			wearer.update_inv_head()

/obj/item/flashlight/flare/torch/lantern/pumpkin/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/candle))
		return ..()
	var/obj/item/candle/candle = tool
	if(candle.infinite)
		to_chat(user, span_warning("[candle] is far too fine to melt away inside a pumpkin."))
		return ITEM_INTERACT_BLOCKING
	if(fuel > 0)
		to_chat(user, span_warning("[src] already holds a candle."))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(span_notice("[user] inserts a candle into [src]."), span_notice("I insert a candle into [src]."))
	if(!do_after(user, 2 SECONDS, src) || QDELETED(candle) || fuel > 0)
		return ITEM_INTERACT_BLOCKING
	playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 60, TRUE, -1)
	fuel = round(120 MINUTES * clamp(candle.wax / initial(candle.wax), 0.1, 1))
	if(candle.lit)
		on = TRUE
		update_brightness(user)
		START_PROCESSING(SSobj, src)
	qdel(candle)
	return ITEM_INTERACT_SUCCESS

/*/obj/item/flashlight/flare/torch/lantern/pumpkin/psy
	name = "psy-do-lamptern"
	desc = "A large and decorated pumpkin shell. Usually seasonal, yet it ENDURES."
	icon_state = "pumpkinlamppsy"
	item_state = "pumpkinlamppsy"*/

/obj/item/flashlight/flare/torch/lantern/pumpkin/ten
	name = "fun pumpkin lamptern"
	desc = "A large and decorated pumpkin shell. It looks like a lot of work to make it stay in one piece."
	icon_state = "pumpkinlampten"
	item_state = "pumpkinlampten"

/obj/item/flashlight/flare/torch/lantern/pumpkin/zizo
	name = "glumpkin lamptern"
	desc = "A large and decorated pumpkin shell. It is strangely gloomy."
	icon_state = "pumpkinlampz"
	item_state = "pumpkinlampz"
	light_color = "#ceff72ff"

/obj/item/flashlight/flare/torch/lantern/pumpkin/grin
	name = "smiling pumpkin lamptern"
	desc = "A large and decorated pumpkin shell. Its smile is not reassuring."
	icon_state = "pumpkinlamp0"
	item_state = "pumpkinlamp0"

/obj/item/flashlight/flare/torch/lantern/pumpkin/frown
	name = "angry pumpkin lamptern"
	desc = "A large and decorated pumpkin shell. It seems quite angry at something, hopefully not you."
	icon_state = "pumpkinlamp1"
	item_state = "pumpkinlamp1"

/obj/item/flashlight/flare/torch/lantern/pumpkin/surprise
	name = "surprised pumpkin lamptern"
	desc = "A large and decorated pumpkin shell. It is quite surprised to see you."
	icon_state = "pumpkinlamp2"
	item_state = "pumpkinlamp2"

/obj/item/flashlight/flare/torch/lantern/pumpkin/woozy
	name = "woozy pumpkin lamptern"
	desc = "A large and decorated pumpkin shell... It seems drunk?!"
	icon_state = "pumpkinlamp3"
	item_state = "pumpkinlamp3"

/obj/item/flashlight/flare/torch/lantern/pumpkin/lit
	start_lit = TRUE

/obj/item/flashlight/flare/torch/lantern/pumpkin/ten/lit
	start_lit = TRUE

/obj/item/flashlight/flare/torch/lantern/pumpkin/zizo/lit
	start_lit = TRUE

/obj/item/flashlight/flare/torch/lantern/pumpkin/grin/lit
	start_lit = TRUE

/obj/item/flashlight/flare/torch/lantern/pumpkin/frown/lit
	start_lit = TRUE

/obj/item/flashlight/flare/torch/lantern/pumpkin/surprise/lit
	start_lit = TRUE

/obj/item/flashlight/flare/torch/lantern/pumpkin/woozy/lit
	start_lit = TRUE
