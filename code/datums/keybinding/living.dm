/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/swap_left
	hotkey_keys = list("Q")
	name = "swap_left"
	full_name = "Swap to left hand"
	description = ""

/datum/keybinding/living/swap_left/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/M = user.mob
	if(!isliving(M))
		return
	if(M.atkswinging)
		M.stop_attack()
	if(M.active_hand_index == 1)
		var/obj/item/I = M.get_active_held_item()
		if(I)
			I.Click()
	else
		M.swap_hand(1)
	return TRUE

/datum/keybinding/living/swap_right
	hotkey_keys = list("E")
	name = "swap_right"
	full_name = "Swap to right hand"
	description = ""

/datum/keybinding/living/swap_right/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/M = user.mob
	if(!isliving(M))
		return
	if(M.atkswinging)
		M.stop_attack()
	if(M.active_hand_index == 2)
		var/obj/item/I = M.get_active_held_item()
		if(I)
			I.Click()
	else
		M.swap_hand(2)
	return TRUE

/datum/keybinding/living/swap_hands
	hotkey_keys = list()
	classic_keys = list()
	name = "swap_hands"
	full_name = "Swap hands"
	description = ""

/datum/keybinding/living/swap_hands/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/M = user.mob
	if(!isliving(M))
		return
	if(M.atkswinging)
		M.stop_attack()
	M.swap_hand()
	return TRUE

/datum/keybinding/living/activate_inhand
	hotkey_keys = list()
	classic_keys = list()
	name = "activate_inhand"
	full_name = "Activate in-hand"
	description = "Uses whatever item you have in-hand"

/datum/keybinding/living/activate_inhand/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/M = user.mob
	if(!isliving(M))
		return
	M.mode()
	return TRUE



/datum/keybinding/living/drop_item
	hotkey_keys = list("Z")
	classic_keys = list("Z")
	name = "drop_item"
	full_name = "Drop Item"
	description = ""

/datum/keybinding/living/drop_item/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/M = user.mob
	if(!isliving(M))
		return
	if(M.atkswinging)
		M.stop_attack()
	var/obj/item/I = M.get_active_held_item()
	if(I)
		user.mob.dropItemToGround(I, silent = FALSE)
	return TRUE

/datum/keybinding/living/sprint
	hotkey_keys = list()
	name = "sprint"
	full_name = "Sprint"
	description = "Sprinting can be dangerous to your health if you aren't careful."

/datum/keybinding/living/sprint/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/M = user.mob
	if(!isliving(M))
		return
	if(M.m_intent == MOVE_INTENT_RUN)
		M.toggle_rogmove_intent(MOVE_INTENT_WALK)
	else
		M.toggle_rogmove_intent(MOVE_INTENT_RUN)
	return TRUE

/datum/keybinding/living/sneak
	hotkey_keys = list()
	name = "sneak"
	full_name = "Sneak"
	description = "Press this hotkey to sneak around, which has many uses."

/datum/keybinding/living/sneak/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/M = user.mob
	var/mob/living/carbon/humie = user.mob
	if(!isliving(M))
		return
	if(humie.has_status_effect(/datum/status_effect/debuff/stealthcd))
		to_chat(user, span_danger("I need to wait a bit longer to enter stealth again!"))
		return
	if(M.m_intent == MOVE_INTENT_SNEAK)
		M.toggle_rogmove_intent(MOVE_INTENT_WALK)
	else
		M.toggle_rogmove_intent(MOVE_INTENT_SNEAK)
	return TRUE


/datum/keybinding/living/submit
	hotkey_keys = list("ShiftX")
	name = "yield"
	full_name = "Yield"
	description = "Yield to your enemy, which may save your life or end it quicker."

/datum/keybinding/living/submit/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/L = user.mob
	L.stop_all_doing()
	L.toggle_submit()
	return TRUE


/datum/keybinding/living/resist
	hotkey_keys = list("X")
	name = "cancelresist"
	full_name = "Cancel/Resist"
	description = "Stop an action such as a charged attack or spam this to resist against a grab."

/datum/keybinding/living/resist/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/L = user.mob
	if(!istype(L))
		return FALSE
	L.stop_all_doing()
	L.resist()
	return TRUE

/datum/keybinding/living/defendtoggle
	hotkey_keys = list("C")
	name = "defendtoggle"
	full_name = "Combat Mode"
	description = "Initiates combat mode. Enables certain RMB intents. Allows to dodge and parry."

/datum/keybinding/living/defendtoggle/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/L = user.mob
	if(!isliving(L))
		return
	L.toggle_cmode()

/datum/keybinding/living/pause_parry
	hotkey_keys = list("Y")
	name = "pause_parry"
	full_name = "Hold to Pause Parry"
	description = "Hold this key to stop automatically parrying while combat mode is active. Dodging remains available."

/datum/keybinding/living/pause_parry/down(client/user)
	. = ..()
	var/mob/living/living_mob = user.mob
	if(!istype(living_mob))
		return FALSE
	if(living_mob.parry_suppressed)
		return TRUE
	living_mob.parry_suppressed = TRUE
	living_mob.balloon_alert(living_mob, "parry paused")
	return TRUE

/datum/keybinding/living/pause_parry/up(client/user)
	. = ..()
	var/mob/living/living_mob = user.mob
	if(!istype(living_mob))
		return FALSE
	if(!living_mob.parry_suppressed)
		return TRUE
	living_mob.parry_suppressed = FALSE
	living_mob.balloon_alert(living_mob, "parry resumed")
	return TRUE

/datum/keybinding/living/combat_dodge
	hotkey_keys = list("Space")
	name = "combat_dodge"
	full_name = "Contextual Dodge"
	description = "Hold a movement key to dodge in that cardinal direction. With fixed-eye enabled, movement keys dodge relative to your facing."

/datum/keybinding/living/combat_dodge/down(client/user)
	. = ..()
	var/mob/living/living_mob = user.mob
	if(!istype(living_mob))
		return FALSE

	// Use the most recently pressed held movement key so diagonal input still produces a cardinal dodge.
	var/held_movement = NONE
	for(var/held_key in user.keys_held)
		var/key_movement = user.movement_keys[held_key]
		if(key_movement)
			held_movement = key_movement

	if(!held_movement)
		return living_mob.try_manual_dodge()
	if(!living_mob.fixedeye)
		return living_mob.try_manual_dodge(held_movement)

	var/facing = angle2dir_cardinal(dir2angle(living_mob.dir))
	switch(held_movement)
		if(NORTH)
			return living_mob.try_manual_dodge(facing)
		if(WEST)
			return living_mob.try_manual_dodge(turn(facing, 90))
		if(SOUTH)
			return living_mob.try_manual_dodge(REVERSE_DIR(facing))
		if(EAST)
			return living_mob.try_manual_dodge(turn(facing, -90))
	return living_mob.try_manual_dodge()

/datum/keybinding/living/combat_dodge_left
	hotkey_keys = list()
	name = "combat_dodge_left"
	full_name = "Dodge Left"
	description = "Dodge to the left of the direction you are facing."

/datum/keybinding/living/combat_dodge_left/down(client/user)
	. = ..()
	var/mob/living/living_mob = user.mob
	if(!istype(living_mob))
		return FALSE
	var/facing = angle2dir_cardinal(dir2angle(living_mob.dir))
	return living_mob.try_manual_dodge(turn(facing, 90))

/datum/keybinding/living/combat_dodge_right
	hotkey_keys = list()
	name = "combat_dodge_right"
	full_name = "Dodge Right"
	description = "Dodge to the right of the direction you are facing."

/datum/keybinding/living/combat_dodge_right/down(client/user)
	. = ..()
	var/mob/living/living_mob = user.mob
	if(!istype(living_mob))
		return FALSE
	var/facing = angle2dir_cardinal(dir2angle(living_mob.dir))
	return living_mob.try_manual_dodge(turn(facing, -90))

// Retain the old binding name so saved Shift+C preferences become a backwards dodge instead of a dead binding.
/datum/keybinding/living/dodgeparry
	hotkey_keys = list()
	name = "dodgeparry"
	full_name = "Legacy Dodge Back"
	description = "Compatibility binding for the former Dodge/Parry toggle."

/datum/keybinding/living/dodgeparry/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/living_mob = user.mob
	if(!istype(living_mob))
		return FALSE
	return living_mob.try_manual_dodge()

/datum/keybinding/living/restd
	hotkey_keys = list("V")
	name = "standrest"
	full_name = "Toggle Stand/Rest"
	description = "Toggle between standing and laying on the floor."
	var/lastrest = 0

/datum/keybinding/living/restd/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/L = user.mob
	if(!istype(L))
		return FALSE
	if(!lastrest || world.time > lastrest + 15)
		L.toggle_rest()
		lastrest = world.time
		return TRUE
	else
		return FALSE

/datum/keybinding/living/standu
	hotkey_keys = list()
	name = "stand"
	full_name = "Stand Up"
	description = "Stand up from a prone position."
	var/lastrest = 0

/datum/keybinding/living/standu/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/L = user.mob
	if(!istype(L))
		return FALSE
	if(!lastrest || world.time > lastrest + 15)
		L.stand_up()
		lastrest = world.time
		return TRUE
	else
		return FALSE

/datum/keybinding/living/rest
	hotkey_keys = list()
	name = "rest"
	full_name = "Lay Down"
	description = "Lay down on the floor."
	var/lastrest = 0

/datum/keybinding/living/rest/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/L = user.mob
	if(!istype(L))
		return FALSE
	if(!lastrest || world.time > lastrest + 15)
		L.lay_down()
		lastrest = world.time
		return TRUE
	else
		return FALSE

/datum/keybinding/living/lookup
	hotkey_keys = list("ShiftF")
	name = "lookup"
	full_name = "Look up"
	description = "Look at what's above you, if you are under an open space."
	var/lastrest = 0

/datum/keybinding/living/lookup/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	var/mob/living/L = user.mob
	var/turf/open/water/current_water = get_turf(L)
	if(istype(current_water) && HAS_TRAIT(L, TRAIT_MOVE_SWIMMING))
		current_water.try_z_swim(L, going_up = TRUE)
		return FALSE
	if(!lastrest || world.time > lastrest + 15)
		L.look_up()
		lastrest = world.time
		return TRUE
	else
		return FALSE

/datum/keybinding/living/pixelshift
	hotkey_keys = list("B")
	name = "pixel_shift"
	full_name = "Pixel-Shift"
	description = "Hold: movement keys shift and Q/E rotate. Use your empty hand with a grab in the other hand to pose the grabbed person."

/datum/keybinding/living/pixelshift/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	user.mob.AddComponent(/datum/component/pixel_shift)
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN)


/datum/keybinding/living/pixelshift/up(client/user, turf/target)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP)

/datum/keybinding/living/view_pet_data
	hotkey_keys = list("Shift")
	name = "view_pet_commands"
	full_name = "View Pet Commands"
	description = "Hold down to see all the commands you can give your pets!"
	keybind_signal = COMSIG_KB_LIVING_VIEW_PET_COMMANDS

/datum/keybinding/living/swim_up
	hotkey_keys = list("ShiftR")
	name = "swim_up"
	full_name = "Swim Up"
	description = "Attempt to swim upwards"

/datum/keybinding/living/swim_up/down(client/user)
	. = ..()
	var/mob/living/L = user.mob
	var/turf/open/water/current_water = get_turf(L)
	if(istype(current_water))
		current_water.try_z_swim(L, going_up = TRUE)

/datum/keybinding/living/swim_down
	hotkey_keys = list("ShiftV")
	name = "swim_down"
	full_name = "Swim Down"
	description = "Attempt to swim downwards"

/datum/keybinding/living/swim_down/down(client/user)
	. = ..()
	var/mob/living/L = user.mob
	var/turf/open/water/current_water = get_turf(L)
	if(istype(current_water))
		current_water.try_z_swim(L, going_up = FALSE)
