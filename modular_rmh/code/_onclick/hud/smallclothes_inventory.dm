/// Underwear button in the bottom inventory row; opens and closes the smallclothes drawer.
/atom/movable/screen/smallclothes_toggle
	name = "smallclothes"
	desc = "Show or hide the slots for smallclothes and jewelry."
	icon = 'modular_rmh/icons/hud/smallclothes_hud.dmi'
	icon_state = "smallclothes"
	base_icon_state = "smallclothes"
	screen_loc = rogueui_smallclothes
	/// HUD owner whose organ changes redraw the button.
	var/mob/living/body
	/// Breasts organ watched for removal; null when the body has none.
	var/obj/item/organ/watched_breasts
	/// Bodies with breasts get the bra over the panties.
	var/bra_shown = FALSE

/atom/movable/screen/smallclothes_toggle/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/living/owner = hud?.mymob
	if(istype(owner))
		watch_body(owner)

/// Follows one body's breast organ and gender changes to pick the button art.
/atom/movable/screen/smallclothes_toggle/proc/watch_body(mob/living/new_body)
	body = new_body
	RegisterSignal(body, COMSIG_LIVING_ORGAN_CHANGED, PROC_REF(on_organ_changed))
	RegisterSignal(body, COMSIG_HUMAN_GENDER_UPDATED, PROC_REF(on_gender_updated))
	watch_breasts(body.getorganslot(ORGAN_SLOT_BREASTS))
	refresh_body()

/atom/movable/screen/smallclothes_toggle/Destroy(force)
	watch_breasts(null)
	if(body)
		UnregisterSignal(body, list(COMSIG_LIVING_ORGAN_CHANGED, COMSIG_HUMAN_GENDER_UPDATED))
		body = null
	return ..()

/atom/movable/screen/smallclothes_toggle/Click(location, control, params)
	var/mob/user = hud?.mymob
	if(!user || user != usr)
		return
	user.playsound_local(user, 'sound/misc/click.ogg', 100)
	hud.toggle_smallclothes_inventory()
	refresh_body()

/atom/movable/screen/smallclothes_toggle/update_icon_state()
	icon_state = "[base_icon_state][bra_shown ? "_f" : ""][hud?.smallclothes_shown ? "_active" : ""]"
	return ..()

/// Bra art for a breasts organ or a female body; leaving is the organ being removed.
/atom/movable/screen/smallclothes_toggle/proc/refresh_body(obj/item/organ/leaving)
	var/obj/item/organ/breasts = body?.getorganslot(ORGAN_SLOT_BREASTS)
	bra_shown = (breasts && breasts != leaving) || body?.gender == FEMALE
	update_appearance(UPDATE_ICON_STATE)

/// Moves the removal watch to a new breasts organ, or drops it.
/atom/movable/screen/smallclothes_toggle/proc/watch_breasts(obj/item/organ/breasts)
	if(breasts == watched_breasts)
		return
	if(watched_breasts)
		UnregisterSignal(watched_breasts, list(COMSIG_ORGAN_REMOVED, COMSIG_PARENT_QDELETING))
	watched_breasts = breasts
	if(watched_breasts)
		RegisterSignal(watched_breasts, list(COMSIG_ORGAN_REMOVED, COMSIG_PARENT_QDELETING), PROC_REF(on_breasts_lost))

/atom/movable/screen/smallclothes_toggle/proc/on_organ_changed(datum/source, obj/item/organ/organ, organ_slot, inserted)
	SIGNAL_HANDLER
	if(organ_slot != ORGAN_SLOT_BREASTS || !istype(organ))
		return
	watch_breasts(organ)
	refresh_body()

/atom/movable/screen/smallclothes_toggle/proc/on_gender_updated(datum/source, old_gender)
	SIGNAL_HANDLER
	refresh_body()

/atom/movable/screen/smallclothes_toggle/proc/on_breasts_lost(obj/item/organ/source)
	SIGNAL_HANDLER
	watch_breasts(null)
	refresh_body(source)

/// Drawer slot; heavy armor over it veils the worn item and keeps hands off it.
/atom/movable/screen/inventory/smallclothes
	icon = 'modular_rmh/icons/hud/smallclothes_hud.dmi'
	/// Heavy armor covers the slot, so its item is an overlay and clicks land here.
	var/covered = FALSE

/atom/movable/screen/inventory/smallclothes/Click(location, control, params)
	var/mob/living/carbon/human/owner = hud?.mymob
	if(istype(owner) && usr == owner && (owner.get_armor_covered_extra_slots() & slot_id))
		to_chat(owner, span_warning("I can't reach that! Something is covering it."))
		return TRUE
	return ..()

/atom/movable/screen/inventory/smallclothes/add_overlays()
	if(covered) // the held-item preview would cut the veil overlays
		return
	return ..()

/atom/movable/screen/inventory/smallclothes/update_overlays()
	. = ..()
	if(!covered)
		return
	var/obj/item/worn = hud?.mymob?.get_item_by_slot(slot_id)
	if(worn)
		var/mutable_appearance/worn_look = new(worn)
		worn_look.plane = FLOAT_PLANE
		worn_look.layer = FLOAT_LAYER
		. += worn_look
	. += "covered"

/// Creates the drawer slots; they stay off screen until the underwear button opens the drawer.
/datum/hud/proc/build_smallclothes_inventory()
	add_smallclothes_slot("left earring", "earring_l", ITEM_SLOT_EARRING_L, rogueui_earring_l)
	add_smallclothes_slot("right earring", "earring_r", ITEM_SLOT_EARRING_R, rogueui_earring_r)
	add_smallclothes_slot("choker", "choker", ITEM_SLOT_CHOKER, rogueui_choker)
	add_smallclothes_slot("bra", "bra", ITEM_SLOT_UNDER_TOP, rogueui_bra)
	add_smallclothes_slot("undershirt", "undershirt", ITEM_SLOT_UNDERSHIRT, rogueui_undershirt)
	add_smallclothes_slot("armsleeves", "armsleeves", ITEM_SLOT_ARMSLEEVES, rogueui_armsleeves)
	add_smallclothes_slot("underwear", "underwear", ITEM_SLOT_UNDER_BOTTOM, rogueui_underwear)
	add_smallclothes_slot("garter", "garter", ITEM_SLOT_GARTER, rogueui_garter)
	add_smallclothes_slot("socks", "socks", ITEM_SLOT_SOCKS, rogueui_socks)

/datum/hud/proc/add_smallclothes_slot(slot_name, slot_state, slot_id, slot_loc)
	var/atom/movable/screen/inventory/smallclothes/slot = new(null, src)
	slot.name = slot_name
	slot.icon_state = slot_state
	slot.slot_id = slot_id
	slot.screen_loc = slot_loc
	slot.update_appearance(UPDATE_ICON_STATE)
	smallclothes_inventory += slot

/datum/hud/proc/toggle_smallclothes_inventory()
	smallclothes_shown = !smallclothes_shown
	update_smallclothes_viewers()

/// Redraws the drawer for the owner and every observer watching through their eyes.
/datum/hud/proc/update_smallclothes_viewers()
	if(smallclothes_shown)
		refresh_smallclothes_slots()
	smallclothes_inventory_update(mymob)
	for(var/mob/watcher as anything in mymob?.observers)
		if(watcher.client?.eye == mymob)
			smallclothes_inventory_update(watcher)

/// Recomputes armor cover and slot icons; the drawer must be refreshed before it reaches a screen.
/datum/hud/proc/refresh_smallclothes_slots()
	var/mob/living/carbon/human/owner = mymob
	if(!istype(owner))
		return
	var/covered_slots = owner.get_armor_covered_extra_slots()
	for(var/atom/movable/screen/inventory/smallclothes/slot as anything in smallclothes_inventory)
		slot.covered = !!(covered_slots & slot.slot_id)
		slot.update_appearance()

/// Puts the drawer slots and their worn items on one viewer's screen, or takes them off.
/datum/hud/proc/smallclothes_inventory_update(mob/viewer)
	var/mob/living/carbon/human/owner = mymob
	var/client/viewer_client = viewer?.client
	if(!length(smallclothes_inventory) || !istype(owner) || !viewer_client)
		return

	var/show = smallclothes_shown && hud_shown
	for(var/atom/movable/screen/inventory/smallclothes/slot as anything in smallclothes_inventory)
		var/obj/item/worn = owner.get_item_by_slot(slot.slot_id)
		if(!worn)
			continue
		if(show && !slot.covered)
			worn.screen_loc = slot.screen_loc
			viewer_client.screen |= worn
		else
			viewer_client.screen -= worn
	if(show)
		viewer_client.screen |= smallclothes_inventory
	else
		viewer_client.screen -= smallclothes_inventory

/// Extra slots that heavy armor keeps out of reach, without the shared ITEM_SLOT_EXTRA bit.
/mob/living/carbon/human/proc/get_armor_covered_extra_slots()
	var/list/armor_cover = check_armor_obscured_slots(TRUE)
	return armor_cover[SLOT_CHECK_EXTRA] & ~ITEM_SLOT_EXTRA
