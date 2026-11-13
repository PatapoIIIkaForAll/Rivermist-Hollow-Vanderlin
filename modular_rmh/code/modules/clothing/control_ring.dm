#define CONTROL_RING_VIEW_RANGE 9
#define CONTROL_RING_RADIAL_LIFETIME 4 SECONDS
#define CONTROL_RING_RADIAL_RADIUS 48

/obj/item/clothing/ring/slave_control
	name = "Slave control ring"
	desc = "An ominous-looking ring with arcane engravings. \n Click with the middle mouse button to invoke a command."
	icon_state = "g_ring_ruby"
	sellprice = 1000

	var/list/phrases_list = list()
	var/ring_bound = FALSE
	var/obj/item/clothing/neck/slave_collar/bound_collar
	/// Arcane chastity device this ring commands.
	var/obj/item/clothing/undies/chastity/arcane/bound_chastity
	var/datum/weakref/worn_owner_ref
	var/list/radial_viewers = list()

/obj/item/clothing/ring/slave_control/Destroy()
	clear_worn_owner()
	clear_bound_collar()
	bound_chastity?.clear_bound_ring()
	radial_viewers = null
	return ..()

/obj/item/clothing/ring/slave_control/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_RING)
		set_worn_owner(user)
	else
		clear_worn_owner()

/obj/item/clothing/ring/slave_control/dropped(mob/user, silent)
	. = ..()
	clear_worn_owner()

/obj/item/clothing/ring/slave_control/proc/set_worn_owner(mob/user)
	clear_worn_owner()
	if(!isliving(user))
		return
	worn_owner_ref = WEAKREF(user)
	RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_worn_owner_unequipped))
	RegisterSignal(user, COMSIG_KB_LIVING_VIEW_PET_COMMANDS, PROC_REF(on_view_command_key_down))
	RegisterSignal(user, DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS), PROC_REF(on_view_command_key_up))

/obj/item/clothing/ring/slave_control/proc/clear_worn_owner()
	var/mob/living/worn_owner = worn_owner_ref?.resolve()
	if(worn_owner)
		UnregisterSignal(worn_owner, list(
			COMSIG_MOB_UNEQUIPPED_ITEM,
			COMSIG_KB_LIVING_VIEW_PET_COMMANDS,
			DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS),
			COMSIG_USER_MOUSE_ENTERED,
		))
		radial_viewers -= REF(worn_owner)
	worn_owner_ref = null

/obj/item/clothing/ring/slave_control/proc/on_worn_owner_unequipped(mob/living/wearer, obj/item/removed_item)
	SIGNAL_HANDLER
	if(removed_item != src)
		return
	clear_worn_owner()

/obj/item/clothing/ring/slave_control/proc/on_view_command_key_down(mob/living/wearer)
	SIGNAL_HANDLER
	if(!is_worn_by(wearer))
		return
	// Held keys auto-repeat key-down, so this can run again before key-up unregisters it.
	RegisterSignal(wearer, COMSIG_USER_MOUSE_ENTERED, PROC_REF(on_worn_owner_mouse_hover), override = TRUE)

/obj/item/clothing/ring/slave_control/proc/on_view_command_key_up(mob/living/wearer)
	SIGNAL_HANDLER
	UnregisterSignal(wearer, COMSIG_USER_MOUSE_ENTERED)
	radial_viewers -= REF(wearer)

/obj/item/clothing/ring/slave_control/proc/on_worn_owner_mouse_hover(mob/living/wearer, atom/mouse_hovered)
	SIGNAL_HANDLER
	if(!isliving(mouse_hovered))
		return
	if(mouse_hovered in get_commanded_bearers())
		display_linked_menu(wearer, mouse_hovered)
		return
	radial_viewers -= REF(wearer)

/obj/item/clothing/ring/slave_control/proc/can_use_control_ring(mob/user, show_feedback = FALSE)
	if(!ismob(user))
		return FALSE
	if(user.is_holding(src))
		return TRUE
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.get_item_by_slot(ITEM_SLOT_RING) == src)
			return TRUE
	if(show_feedback)
		to_chat(user, span_warning("You need to hold or wear the ring to use it."))
	return FALSE

/obj/item/clothing/ring/slave_control/proc/is_worn_by(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	return human_user.get_item_by_slot(ITEM_SLOT_RING) == src

/obj/item/clothing/ring/slave_control/proc/get_bound_collar_bearer()
	if(!bound_collar || QDELETED(bound_collar) || bound_collar.bound_ring != src)
		return null
	return bound_collar.get_worn_bearer()

/obj/item/clothing/ring/slave_control/proc/get_bound_chastity_wearer()
	if(!bound_chastity || QDELETED(bound_chastity) || bound_chastity.bound_ring != src)
		return null
	return bound_chastity.wearer

/// Everyone wearing something this ring commands.
/obj/item/clothing/ring/slave_control/proc/get_commanded_bearers()
	. = list()
	var/mob/living/collar_bearer = get_bound_collar_bearer()
	if(collar_bearer)
		. += collar_bearer
	var/mob/living/chastity_wearer = get_bound_chastity_wearer()
	if(chastity_wearer)
		. |= chastity_wearer

/obj/item/clothing/ring/slave_control/proc/clear_bound_collar(clear_collar = TRUE)
	var/obj/item/clothing/neck/slave_collar/old_collar = bound_collar
	bound_collar = null
	ring_bound = FALSE
	phrases_list = list()
	if(clear_collar && old_collar?.bound_ring == src)
		old_collar.bound_ring = null
		old_collar.collar_bound = FALSE

/obj/item/clothing/ring/slave_control/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if(!can_use_control_ring(user, TRUE))
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/I = H.wear_neck
		if(istype(I, /obj/item/clothing/neck/slave_collar))
			var/obj/item/clothing/neck/slave_collar/sc = I
			sc.bind_collar(src, user, istype(src, /obj/item/clothing/ring/slave_control/master))
		var/obj/item/clothing/undies/chastity/arcane/device = H.underwear
		if(istype(device) && device.bound_ring != src)
			device.bind_ring(src, user)

/obj/item/clothing/ring/slave_control/attackby(obj/item/I, mob/living/user)
	if(!ismob(user))
		return
	if(istype(I, /obj/item/clothing/neck/slave_collar))
		var/obj/item/clothing/neck/slave_collar/sc = I
		sc.bind_collar(src, user, istype(src, /obj/item/clothing/ring/slave_control/master))
		return
	if(istype(I, /obj/item/clothing/undies/chastity/arcane))
		var/obj/item/clothing/undies/chastity/arcane/device = I
		device.bind_ring(src, user)
		return
	return ..()

/// Opens a radial menu of commands for whatever the ring commands when middle-clicked.
/obj/item/clothing/ring/slave_control/MiddleClick(mob/user, params)
	if(!can_use_control_ring(user, TRUE))
		return
	if(!bound_collar && !bound_chastity)
		to_chat(user, span_warning("The ring has nothing bound."))
		return ..()
	invoke_ring_command_radial(user)
	return

/// Picks the collar or the chastity device when both answer, then opens that item's radial.
/obj/item/clothing/ring/slave_control/proc/invoke_ring_command_radial(mob/user, mob/living/bearer = null, atom/menu_anchor = null, datum/callback/custom_check = null, radius = null, button_animation_flags = BUTTON_SLIDE_IN, display_close_button = TRUE)
	var/list/targets = list()
	if(bound_collar && !QDELETED(bound_collar) && (!bearer || get_bound_collar_bearer() == bearer))
		targets["Collar"] = bound_collar
	if(bound_chastity && !QDELETED(bound_chastity) && (!bearer || get_bound_chastity_wearer() == bearer))
		targets["Chastity device"] = bound_chastity
	if(!length(targets))
		to_chat(user, span_warning("The ring has nothing bound."))
		return
	var/chosen_name = targets[1]
	if(length(targets) > 1)
		var/list/choices = list()
		for(var/target_name in targets)
			var/obj/item/target_item = targets[target_name]
			choices[target_name] = image(icon = target_item.icon, icon_state = target_item.icon_state)
		chosen_name = show_radial_menu(user, menu_anchor || src, choices, radius = radius, custom_check = custom_check, tooltips = TRUE, require_near = FALSE, button_animation_flags = button_animation_flags, display_close_button = display_close_button)
		if(!chosen_name)
			return
	if(chosen_name == "Collar")
		invoke_collar_command_radial(user, bound_collar, menu_anchor, custom_check, radius, button_animation_flags, display_close_button)
		return
	invoke_chastity_command_radial(user, bound_chastity, menu_anchor, custom_check, radius, button_animation_flags, display_close_button)

/// Radial of arcane chastity commands for the bound device.
/obj/item/clothing/ring/slave_control/proc/invoke_chastity_command_radial(mob/user, obj/item/clothing/undies/chastity/arcane/device, atom/menu_anchor = null, datum/callback/custom_check = null, radius = null, button_animation_flags = BUTTON_SLIDE_IN, display_close_button = TRUE)
	if(!can_use_control_ring(user, TRUE))
		return
	if(!device || QDELETED(device) || device.bound_ring != src)
		to_chat(user, span_warning("The ring has no chastity device bound."))
		return
	var/list/command_options = device.get_ring_command_options()
	var/list/choices = list()
	for(var/display_name in command_options)
		choices[display_name] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_slice")
	var/chosen = show_radial_menu(user, menu_anchor || src, choices, radius = radius, custom_check = custom_check, tooltips = TRUE, require_near = FALSE, button_animation_flags = button_animation_flags, display_close_button = display_close_button)
	if(!chosen || QDELETED(device) || device.bound_ring != src || !can_use_control_ring(user))
		return
	var/command = command_options[chosen]
	if(command && device.perform_ring_command(command, user))
		to_chat(user, "<font size='1' color='grey'>The ring vibrates imperceptibly — the command was a success.</font>")
	else
		to_chat(user, "<font size='1' color='red'>The ring lies still — command failed to perform.</font>")

/// Shared radial menu for invoking commands on a slave collar.
/// Used by direct ring interaction and the shift-hover linked slave menu.
/obj/item/clothing/ring/slave_control/proc/invoke_collar_command_radial(mob/user, obj/item/clothing/neck/slave_collar/collar, atom/menu_anchor = null, datum/callback/custom_check = null, radius = null, button_animation_flags = BUTTON_SLIDE_IN, display_close_button = TRUE)
	if(!can_use_control_ring(user, TRUE))
		return
	if(!collar || QDELETED(collar) || !collar.phrases_list)
		to_chat(user, span_warning("The ring has no collar bound."))
		return
	var/list/command_options = collar.get_radial_command_options()
	var/list/choices = list()
	for(var/display_name in command_options)
		choices[display_name] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_slice")
	var/chosen = show_radial_menu(user, menu_anchor || src, choices, radius = radius, custom_check = custom_check, tooltips = TRUE, require_near = FALSE, button_animation_flags = button_animation_flags, display_close_button = display_close_button)
	if(!chosen)
		return
	var/internal_key = command_options[chosen]
	if(!internal_key)
		return
	if(collar.perform_command(internal_key, user, src, "ring"))
		to_chat(user, "<font size='1' color='grey'>The ring vibrates imperceptibly — the command was a success.</font>")
	else
		to_chat(user, "<font size='1' color='red'>The ring lies still — command failed to perform.</font>")

/obj/item/clothing/ring/slave_control/proc/display_linked_menu(mob/living/wearer, mob/living/bearer)
	if(!is_worn_by(wearer) || wearer.stat != CONSCIOUS)
		return
	if(radial_viewers[REF(wearer)])
		return
	if(!bearer || !can_see(wearer, bearer, CONTROL_RING_VIEW_RANGE))
		return
	INVOKE_ASYNC(src, PROC_REF(display_linked_radial), wearer, bearer)

/obj/item/clothing/ring/slave_control/proc/display_linked_radial(mob/living/wearer, mob/living/bearer)
	if(QDELETED(bearer) || !(bearer in get_commanded_bearers()))
		return
	radial_viewers[REF(wearer)] = world.time + CONTROL_RING_RADIAL_LIFETIME
	invoke_ring_command_radial(
		wearer,
		bearer,
		menu_anchor = bearer,
		custom_check = CALLBACK(src, PROC_REF(check_radial_viewer), wearer, bearer),
		radius = CONTROL_RING_RADIAL_RADIUS,
		button_animation_flags = BUTTON_FADE_IN | BUTTON_FADE_OUT,
		display_close_button = FALSE,
	)
	radial_viewers -= REF(wearer)

/obj/item/clothing/ring/slave_control/proc/check_radial_viewer(mob/living/wearer, mob/living/bearer)
	if(QDELETED(wearer) || !radial_viewers[REF(wearer)])
		return FALSE
	if(world.time > radial_viewers[REF(wearer)])
		return FALSE
	if(!is_worn_by(wearer) || wearer.stat != CONSCIOUS)
		return FALSE
	if(QDELETED(bearer) || !(bearer in get_commanded_bearers()) || !can_see(wearer, bearer, CONTROL_RING_VIEW_RANGE))
		return FALSE
	return TRUE

/obj/item/clothing/ring/slave_control/examine(mob/user)
	. = ..()
	if(bound_collar && !QDELETED(bound_collar))
		. += span_notice("It is bound to [bound_collar.get_control_display_name()].")
	else
		. += span_warning("It is not bound to a collar.")
	var/mob/living/chastity_wearer = get_bound_chastity_wearer()
	if(chastity_wearer)
		. += span_notice("It commands the [bound_chastity.name] worn by [chastity_wearer].")
	else if(bound_chastity)
		. += span_notice("It commands \a [bound_chastity], worn by no one.")
	if(!length(phrases_list))
		return
	. += span_userdanger("You notice engraved phrases on the ring:")
	for(var/el in phrases_list)
		. += "<br><b>[GLOB.slave_phrases_translations[el]]:</b> \"[phrases_list[el]]\""

/datum/anvil_recipe/slave_control
	name = "Slave control ring"
	recipe_name = "a slave control ring"
	req_bar = /obj/item/ingot/gold
	additional_items = list(/obj/item/gem/red)
	created_item = /obj/item/clothing/ring/slave_control
	craftdiff = 3
	i_type = "Valuables"

/obj/item/clothing/ring/slave_control/master
	name = "Master Slaver ring"
	desc = "One Ring to Rule Them All. \n Click with the middle mouse button to invoke a command, activate in-hand to select a victim."
	icon_state = "ring_g"

/obj/item/clothing/ring/slave_control/master/attack_self(mob/user, params)
	. = ..()
	if(!can_use_control_ring(user, TRUE))
		return
	var/list/collar_choices = get_slave_collar_choices()
	if(!length(collar_choices))
		to_chat(user, span_warning("No active collars answer the ring."))
		return
	var/command_input = browser_input_list(user, "CHOOSE YOUR SERVANT", "SERVANTS", collar_choices, null)
	if(command_input)
		var/datum/weakref/collar_ref = collar_choices[command_input]
		var/obj/item/clothing/neck/slave_collar/collar = collar_ref?.resolve()
		if(istype(collar) && collar.bind_collar(src, user, TRUE))
			to_chat(user, "<font size='1' color='grey'>The ring vibrates imperceptably - the linking was a success.</font>")
		else
			to_chat(user, "<font size='1' color='red'>The ring lies still - the linking failed to perform.</font>")

/proc/get_master_slave_control_ring(mob/living/user)
	if(!ishuman(user))
		return null
	var/mob/living/carbon/human/human_user = user
	var/obj/item/clothing/ring/slave_control/master/worn_ring = human_user.get_item_by_slot(ITEM_SLOT_RING)
	if(istype(worn_ring))
		return worn_ring
	for(var/obj/item/held_item as anything in human_user.held_items)
		if(istype(held_item, /obj/item/clothing/ring/slave_control/master))
			return held_item
	return null

/mob/living/carbon/human/AltClick(mob/user, list/modifiers)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	var/obj/item/clothing/neck/slave_collar/collar = wear_neck
	var/obj/item/clothing/undies/chastity/arcane/device = underwear
	if(!istype(collar) && !istype(device))
		return
	var/obj/item/clothing/ring/slave_control/master/ring = get_master_slave_control_ring(living_user)
	if(!ring)
		return
	if(!can_see(living_user, src, CONTROL_RING_VIEW_RANGE))
		to_chat(living_user, span_warning("[src] is too far away for the ring to bind."))
		return
	if(!ring.can_use_control_ring(living_user, TRUE))
		return
	if(istype(collar))
		collar.bind_collar(ring, living_user, TRUE)
	if(istype(device) && device.bound_ring != ring)
		device.bind_ring(ring, living_user)

/datum/anvil_recipe/slave_control_master
	name = "Master Slaver ring"
	recipe_name = "One Ring to Rule Them All"
	req_bar = /obj/item/ingot/gold
	additional_items = list(/obj/item/phylactery)
	created_item = /obj/item/clothing/ring/slave_control/master
	craftdiff = 6
	i_type = "Valuables"

#undef CONTROL_RING_VIEW_RANGE
#undef CONTROL_RING_RADIAL_LIFETIME
#undef CONTROL_RING_RADIAL_RADIUS
