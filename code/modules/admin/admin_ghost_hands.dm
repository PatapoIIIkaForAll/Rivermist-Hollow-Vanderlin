/**
 * Admin ghost hands and inventory. Only ghosts controlled by an admin get them; player ghosts never do.
 * Off by default: each admin turns them on with Toggle Admin Ghost Hands (a saved preference).
 *
 * Ctrl + click an object        : take it into the active hand (the other hand if that one is full)
 * Ctrl + click with a held one  : give it to a mob, or put it on the clicked tile
 * Click a hand slot / Q / E / X : switch hands; click the active hand again to drop its object here
 * Bag button on the HUD         : the inventory window: two hands plus a bag of BM_GHOST_BAG_SIZE slots
 *
 * Nearly any object can be taken: items, structures, machines, even if anchored or worn by a mob.
 * Effects (decals, landmarks, helpers), turfs and containers with a mob inside cannot.
 *
 * What the admin carries belongs to their account for the round: it follows them from one ghost
 * to the next (aghost, re-enter body, aghost again, reconnect) and is lost when the round ends.
 * Carried objects wait in nullspace, so lights, processing and sounds never follow the invisible
 * ghost around, and nothing is "equipped": no equip hooks run that assume a living holder.
 */

#define BM_GHOST_BAG_SIZE 40

/// ckey -> /datum/admin_ghost_inventory, for the current round only.
GLOBAL_LIST_EMPTY(admin_ghost_inventories)

/datum/admin_ghost_inventory
	var/owner_ckey
	/// list(left, right). The admin ghost's held_items is this very list.
	var/list/hands = list(null, null)
	/// Objects stored in the bag, oldest first.
	var/list/bag = list()
	/// The ghost currently using this inventory, if any.
	var/mob/dead/observer/ghost

/datum/admin_ghost_inventory/New(ckey)
	owner_ckey = ckey

/proc/get_admin_ghost_inventory(ckey)
	var/datum/admin_ghost_inventory/inventory = GLOB.admin_ghost_inventories[ckey]
	if(!inventory)
		inventory = new(ckey)
		GLOB.admin_ghost_inventories[ckey] = inventory
	return inventory

/datum/admin_ghost_inventory/proc/carries(obj/thing)
	return (thing in hands) || (thing in bag)

/// Moves thing out of the world into this inventory: hand index, or the bag when index is null.
/datum/admin_ghost_inventory/proc/carry(obj/thing, index)
	if(index)
		if(index < 1 || index > 2 || hands[index])
			return FALSE
	else if(length(bag) >= BM_GHOST_BAG_SIZE)
		return FALSE
	if(isliving(thing.loc))
		var/mob/living/wearer = thing.loc
		if(isitem(thing))
			wearer.temporarilyRemoveItemFromInventory(thing, force = TRUE)
	if(ismovable(thing) && length(thing.buckled_mobs))
		thing.unbuckle_all_mobs(force = TRUE)
	thing.moveToNullspace()
	if(index)
		hands[index] = thing
	else
		bag += thing
	RegisterSignal(thing, COMSIG_PARENT_QDELETING, PROC_REF(on_carried_deleted), override = TRUE)
	refresh()
	return TRUE

/// Puts a carried object back in the world on destination. Returns the object.
/datum/admin_ghost_inventory/proc/release(obj/thing, turf/destination)
	if(!carries(thing))
		return null
	forget(thing)
	unshow(thing)
	thing.forceMove(destination)
	refresh()
	return thing

/datum/admin_ghost_inventory/proc/forget(obj/thing)
	var/index = hands.Find(thing)
	if(index)
		hands[index] = null
	bag -= thing
	UnregisterSignal(thing, COMSIG_PARENT_QDELETING)

/datum/admin_ghost_inventory/proc/on_carried_deleted(obj/source)
	SIGNAL_HANDLER
	forget(source)
	unshow(source)
	refresh()

/datum/admin_ghost_inventory/proc/unshow(obj/thing)
	ghost?.client?.screen -= thing
	thing.screen_loc = null
	thing.plane = initial(thing.plane)
	thing.layer = initial(thing.layer)

/// Redraws the hands on the ghost's HUD and the inventory window.
/datum/admin_ghost_inventory/proc/refresh()
	ghost?.update_inv_hands()
	SStgui.update_uis(src)

/// Ghost side --------------------------------------------------------------------------------

/mob/dead/observer
	/// The admin inventory this ghost carries; null for player ghosts.
	var/datum/admin_ghost_inventory/admin_inventory

/// Gives this admin ghost its hands, when the admin has them turned on (Toggle Admin Ghost Hands).
/mob/dead/observer/proc/setup_admin_hands()
	if(!client?.holder || admin_inventory)
		return
	if(!client.prefs?.read_preference(/datum/preference/toggle/admin_ghost_hands))
		return
	admin_inventory = get_admin_ghost_inventory(ckey)
	admin_inventory.ghost?.drop_admin_hands() // only one ghost uses an inventory at a time
	admin_inventory.ghost = src
	held_items = admin_inventory.hands
	active_hand_index = 2
	if(hud_used)
		hud_used.build_hand_slots()
		hud_used.add_admin_ghost_buttons()
	update_inv_hands()

/// Detaches the inventory from this ghost. What it carries stays with the account.
/mob/dead/observer/proc/drop_admin_hands()
	if(!admin_inventory)
		return
	for(var/obj/thing in admin_inventory.hands)
		admin_inventory.unshow(thing)
	SStgui.close_uis(admin_inventory)
	if(admin_inventory.ghost == src)
		admin_inventory.ghost = null
	admin_inventory = null
	held_items = list()
	hud_used?.build_hand_slots()
	hud_used?.remove_admin_ghost_buttons()

/mob/dead/observer/Login()
	. = ..()
	if(client?.holder)
		setup_admin_hands()

/mob/dead/observer/Logout()
	drop_admin_hands()
	return ..()

/mob/dead/observer/Destroy()
	drop_admin_hands()
	return ..()

/mob/dead/observer/update_inv_hands()
	if(!admin_inventory)
		return
	for(var/index in 1 to length(held_items))
		var/obj/held = held_items[index]
		if(!held)
			continue
		held.screen_loc = ui_hand_position(index)
		held.plane = ABOVE_HUD_PLANE
		held.layer = BACKHUD_LAYER + 1
		client?.screen |= held
	if(hud_used)
		for(var/hand_key in hud_used.hand_slots)
			var/atom/movable/screen/inventory/hand/hand_slot = hud_used.hand_slots[hand_key]
			hand_slot?.update_appearance(UPDATE_OVERLAYS)

/mob/dead/observer/swap_hand(held_index)
	if(!admin_inventory)
		return
	if(!held_index)
		held_index = get_inactive_hand_index()
	if(held_index < 1 || held_index > length(held_items))
		return
	active_hand_index = held_index
	update_inv_hands()
	SStgui.update_uis(admin_inventory)

/// What the admin may take: objects other than effects, never turfs, mobs or HUD elements.
/proc/admin_ghost_can_take(atom/target)
	if(!isobj(target) || QDELETED(target))
		return FALSE
	if(istype(target, /obj/effect) || istype(target, /atom/movable/screen) || istype(target, /obj/abstract))
		return FALSE
	var/obj/thing = target
	if(thing.invisibility >= INVISIBILITY_ABSTRACT)
		return FALSE
	if(isitem(thing))
		var/obj/item/item = thing
		if(item.item_flags & ABSTRACT)
			return FALSE
	return TRUE

/// Ctrl + click handling. Returns TRUE when the hands used the click.
/mob/dead/observer/proc/admin_hands_ctrl_click(atom/target)
	if(!admin_inventory || !client?.holder) // deadminned while ghosted: the hands stop working
		return FALSE
	var/obj/held = get_active_held_item()
	if(!held)
		return admin_hands_take(target)
	return admin_hands_put(held, target)

/mob/dead/observer/proc/admin_hands_take(atom/target)
	if(!admin_ghost_can_take(target))
		return FALSE
	var/obj/thing = target
	// Carried objects wait in nullspace: anyone inside would go there with it.
	if(locate(/mob) in thing.get_all_contents())
		to_chat(src, span_warning("Someone is inside [thing]. Get them out first."))
		return TRUE
	var/index = held_items[active_hand_index] ? get_inactive_hand_index() : active_hand_index
	if(!index || held_items[index])
		to_chat(src, span_warning("Both hands are full. Put something in the bag first."))
		return TRUE
	var/from = isliving(thing.loc) ? key_name(thing.loc) : AREACOORD(thing)
	if(admin_inventory.carry(thing, index))
		log_admin("[key_name(src)] took [thing] ([thing.type]) from [from] as an admin ghost.")
	return TRUE

/mob/dead/observer/proc/admin_hands_put(obj/held, atom/target)
	var/turf/destination = get_turf(target)
	if(!destination)
		return FALSE
	admin_inventory.release(held, destination)
	if(isliving(target) && isitem(held))
		var/mob/living/receiver = target
		if(receiver.put_in_hands(held))
			to_chat(src, span_notice("You give [held] to [receiver]."))
			log_admin("[key_name(src)] gave [held] ([held.type]) to [key_name(receiver)] as an admin ghost.")
			return TRUE
	log_admin("[key_name(src)] put [held] ([held.type]) at [AREACOORD(destination)] as an admin ghost.")
	return TRUE

/// Plain click on the object in the active hand (through its hand slot): drop it where the ghost is.
/mob/dead/observer/proc/admin_hands_drop_active()
	var/obj/held = get_active_held_item()
	var/turf/here = get_turf(src)
	if(!held || !here)
		return FALSE
	return admin_hands_put(held, here)

/// HUD buttons -------------------------------------------------------------------------------

/datum/hud
	var/list/admin_ghost_buttons

/datum/hud/proc/add_admin_ghost_buttons()
	if(length(admin_ghost_buttons))
		return
	admin_ghost_buttons = list(
		new /atom/movable/screen/admin_ghost_bag(null, src),
	)
	static_inventory += admin_ghost_buttons
	if(mymob?.hud_used == src)
		show_hud(hud_version)

/datum/hud/proc/remove_admin_ghost_buttons()
	if(!length(admin_ghost_buttons))
		return
	static_inventory -= admin_ghost_buttons
	mymob?.client?.screen -= admin_ghost_buttons
	QDEL_LIST(admin_ghost_buttons)

/atom/movable/screen/admin_ghost_bag
	name = "Inventory"
	icon = 'icons/mob/roguehud.dmi'
	icon_state = "back"
	screen_loc = "WEST-2:-16,SOUTH+8"

/atom/movable/screen/admin_ghost_bag/Click()
	var/mob/dead/observer/ghost = usr
	if(istype(ghost) && ghost == hud?.mymob && ghost.admin_inventory)
		ghost.admin_inventory.ui_interact(ghost)
	return TRUE

/// Hand keys for admin ghosts: Q left, E right, X swap. Living mobs keep their own handling.
/datum/keybinding/living/swap_left/can_use(client/user)
	return ..() || admin_ghost_has_hands(user?.mob)

/datum/keybinding/living/swap_right/can_use(client/user)
	return ..() || admin_ghost_has_hands(user?.mob)

/datum/keybinding/living/swap_hands/can_use(client/user)
	return ..() || admin_ghost_has_hands(user?.mob)

/datum/keybinding/living/swap_left/down(client/user, turf/target, mousepos_x, mousepos_y)
	if(admin_ghost_has_hands(user.mob))
		user.mob.swap_hand(1)
		return TRUE
	return ..()

/datum/keybinding/living/swap_right/down(client/user, turf/target, mousepos_x, mousepos_y)
	if(admin_ghost_has_hands(user.mob))
		user.mob.swap_hand(2)
		return TRUE
	return ..()

/datum/keybinding/living/swap_hands/down(client/user, turf/target, mousepos_x, mousepos_y)
	if(admin_ghost_has_hands(user.mob))
		user.mob.swap_hand()
		return TRUE
	return ..()

/proc/admin_ghost_has_hands(mob/user)
	var/mob/dead/observer/ghost = user
	return istype(ghost) && !!ghost.admin_inventory

/// Toggle ------------------------------------------------------------------------------------

/// Persistent, per-admin choice: an admin ghost with hands and inventory, or a plain ghost.
/datum/preference/toggle/admin_ghost_hands
	savefile_key = "admin_ghost_hands"
	savefile_identifier = PREF_PLAYER
	category = "ghost"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE

/datum/preference/toggle/admin_ghost_hands/is_accessible(datum/preferences/prefs)
	. = ..()
	if(!.)
		return
	return !!prefs?.parent?.holder

/client/proc/toggle_admin_ghost_hands()
	set name = "Toggle Admin Ghost Hands"
	set category = "Preferences.Admin"
	set desc = "Turn the hands and inventory of your admin ghost on or off."

	if(!holder || !prefs)
		return
	var/enable = !prefs.read_preference(/datum/preference/toggle/admin_ghost_hands)
	prefs.write_preference(/datum/preference/toggle/admin_ghost_hands, enable)
	prefs.save_preferences()
	var/mob/dead/observer/ghost = mob
	if(istype(ghost))
		if(enable)
			ghost.setup_admin_hands()
		else
			ghost.drop_admin_hands()
	if(enable)
		to_chat(src, span_notice("Admin ghost hands are ON. Ctrl + click an object to take it, Ctrl + click with it to give it or put it down. Click with an item uses it at once; Alt + click the active hand uses it in hand. Q / E or the hand slots switch hands; the bag button opens your inventory."))
	else
		to_chat(src, span_notice("Admin ghost hands are OFF. What you carry stays in your admin inventory until you turn them on again."))
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Admin Ghost Hands", "[enable ? "Enabled" : "Disabled"]"))

/// Inventory window --------------------------------------------------------------------------

/datum/admin_ghost_inventory/ui_state(mob/user)
	return GLOB.always_state

/datum/admin_ghost_inventory/ui_status(mob/user, datum/ui_state/state)
	if(user != ghost || !user.client?.holder || user.ckey != owner_ckey)
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/admin_ghost_inventory/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminGhostInventory", "Admin Inventory")
		ui.set_autoupdate(FALSE) // refresh() pushes every change
		ui.open()

/datum/admin_ghost_inventory/proc/thing_data(obj/thing)
	if(!thing)
		return null
	return list(
		"ref" = REF(thing),
		"name" = "[thing.name]",
		"path" = "[thing.type]",
		"icon" = "[thing.icon]",
		"icon_state" = "[thing.icon_state]",
		"is_item" = isitem(thing),
	)

/datum/admin_ghost_inventory/ui_data(mob/user)
	var/list/hand_data = list()
	for(var/index in 1 to 2)
		hand_data += list(thing_data(hands[index]))
	var/list/bag_data = list()
	for(var/obj/thing as anything in bag)
		bag_data += list(thing_data(thing))
	return list(
		"hands" = hand_data,
		"active_hand" = ghost?.active_hand_index || 2,
		"bag" = bag_data,
		"bag_size" = BM_GHOST_BAG_SIZE,
	)

/datum/admin_ghost_inventory/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !ghost || usr != ghost)
		return
	var/obj/thing = locate(params["ref"])
	if(thing && !carries(thing))
		thing = null
	var/turf/here = get_turf(ghost)
	switch(action)
		if("swap")
			ghost.swap_hand(text2num("[params["hand"]]"))
			return TRUE
		if("to_bag")
			if(!thing || !hands.Find(thing))
				return FALSE
			if(length(bag) >= BM_GHOST_BAG_SIZE)
				to_chat(ghost, span_warning("The bag is full."))
				return TRUE
			forget(thing)
			unshow(thing)
			carry(thing, null)
			return TRUE
		if("to_hand")
			if(!thing || !(thing in bag))
				return FALSE
			var/index = hands[ghost.active_hand_index] ? ghost.get_inactive_hand_index() : ghost.active_hand_index
			if(!index || hands[index])
				to_chat(ghost, span_warning("Both hands are full."))
				return TRUE
			forget(thing)
			carry(thing, index)
			return TRUE
		if("drop")
			if(!thing || !here)
				return FALSE
			release(thing, here)
			log_admin("[key_name(ghost)] put [thing] ([thing.type]) at [AREACOORD(here)] from the admin inventory.")
			return TRUE
		if("delete")
			if(!thing)
				return FALSE
			log_admin("[key_name(ghost)] deleted [thing] ([thing.type]) from the admin inventory.")
			forget(thing)
			unshow(thing)
			// In nullspace a container would dump its contents into nullspace, where they would stay.
			for(var/atom/movable/content as anything in thing.contents)
				qdel(content)
			qdel(thing)
			refresh()
			return TRUE
		if("drop_all")
			if(!here)
				return FALSE
			var/dropped = 0
			for(var/obj/carried in bag.Copy())
				release(carried, here)
				dropped++
			log_admin("[key_name(ghost)] put [dropped] objects from the admin inventory at [AREACOORD(here)].")
			return TRUE
	return FALSE

#undef BM_GHOST_BAG_SIZE

/// Using held items -------------------------------------------------------------------------
/*
 * With an item in the active hand, a plain left or right click on the map uses it on the target
 * through the normal item interaction chain (keys in locks, tools on structures, items into
 * containers...). Timed actions finish at once: do_after() returns immediately for admin ghosts.
 * Alt + click on the active hand slot uses the item in hand.
 *
 * Hitting mobs is not supported: combat code needs a living attacker. Give items with Ctrl + click.
 */

/// TRUE when user is an admin ghost whose timed actions are instant.
/proc/is_instant_admin_ghost(mob/user)
	var/mob/dead/observer/ghost = user
	return istype(ghost) && ghost.admin_inventory && ghost.client?.holder

/mob/dead/observer/proc/admin_use_item(obj/item/held, atom/target, list/modifiers)
	if(!client?.holder)
		return FALSE
	if(ismob(target))
		to_chat(src, span_warning("Admin ghosts cannot hit mobs. Ctrl + click gives [held] to [target]."))
		return TRUE
	run_admin_item_action(held, CALLBACK(held, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, target, modifiers), "used [held] ([held.type]) on [target] ([target.type]) at [AREACOORD(target)]")
	return TRUE

/mob/dead/observer/proc/admin_use_item_in_hand(obj/item/held, list/modifiers)
	if(!client?.holder)
		return FALSE
	run_admin_item_action(held, CALLBACK(held, TYPE_PROC_REF(/obj/item, attack_self), src, modifiers), "used [held] ([held.type]) in hand")
	return TRUE

/// Runs one item action with a "use" intent, then tidies up whatever the action did to the hands.
/mob/dead/observer/proc/run_admin_item_action(obj/item/held, datum/callback/action, log_text)
	var/list/before = held_items.Copy()
	var/datum/intent/previous_intent = used_intent
	used_intent = new /datum/intent/use(src, held)
	var/failed = FALSE
	try
		action.Invoke()
	catch(var/exception/error)
		failed = TRUE
		log_runtime("Admin ghost item use: [error] at [error.file]:[error.line]")
	used_intent = previous_intent
	log_admin("[key_name(src)] [log_text] as an admin ghost.")
	if(failed)
		to_chat(src, span_warning("[held] could not finish that: this action expects a living user. Details are in the runtime log."))
	// The action may have moved a held item into the world (a key into a lock, a log into a fire).
	for(var/obj/thing in before)
		if(QDELETED(thing) || !admin_inventory)
			continue
		if(!(thing in held_items) || thing.loc)
			admin_inventory.forget(thing)
			admin_inventory.unshow(thing)
	admin_inventory?.refresh()
