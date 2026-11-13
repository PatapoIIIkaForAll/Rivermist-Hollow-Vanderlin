// Kept in Chastity: start the round locked in a chosen device.

#define CHASTITY_KEY_CARRIED "Carried"
#define CHASTITY_KEY_LOST "Lost"

/datum/quirk/neutral/kept_in_chastity
	name = "Kept in Chastity"
	desc = "You arrive already locked in a chastity device."
	desc_hint = "Choose the device. It starts locked. Its key is in your pack, or lost if you choose so."
	preview_render = FALSE
	customization_label = "Device"
	customization_options = list(
		/obj/item/clothing/undies/chastity/belt,
		/obj/item/clothing/undies/chastity/cage,
		/obj/item/clothing/undies/chastity/cage/shield,
		/obj/item/clothing/undies/chastity/cage/flat,
		/obj/item/clothing/undies/chastity/cage/flat/shield,
		/obj/item/clothing/undies/chastity/insertable,
		/obj/item/clothing/undies/chastity/insertable/shield,
		/obj/item/clothing/undies/chastity/intersex,
	)
	extra_customization_fields = list(
		list(
			"key" = "key",
			"label" = "Key",
			"type" = QUIRK_SELECT,
			"default" = CHASTITY_KEY_CARRIED,
			"options" = list(CHASTITY_KEY_CARRIED, CHASTITY_KEY_LOST),
		),
	)

/datum/quirk/neutral/kept_in_chastity/is_available(datum/preferences/prefs)
	if(!..())
		return FALSE
	if(!prefs)
		return TRUE
	var/datum/erp_preference/boolean/allow_chastity_play/pref = new
	return pref.get_value(prefs)

/datum/quirk/neutral/kept_in_chastity/after_job_spawn(datum/job/job)
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return
	var/device_type = get_device_type()
	var/obj/item/clothing/undies/chastity/device = new device_type(null)
	var/turf/spawn_turf = get_turf(human_owner)
	if(!device.can_fit_on(human_owner, null, FALSE))
		device.forceMove(spawn_turf)
		stow_item(human_owner, device)
		to_chat(human_owner, span_warning("\The [device] doesn't fit my body, so I carry it instead."))
		return
	var/obj/item/old_underwear = human_owner.underwear
	if(old_underwear)
		human_owner.dropItemToGround(old_underwear, force = TRUE)
		stow_item(human_owner, old_underwear)
	device.forceMove(spawn_turf)
	if(!human_owner.equip_to_slot_if_possible(device, ITEM_SLOT_UNDER_BOTTOM, disable_warning = TRUE))
		stow_item(human_owner, device)
		return
	device.lock?.lock()
	if(get_extra_value("key") == CHASTITY_KEY_LOST)
		to_chat(human_owner, span_notice("I am locked in \the [device], and its key is long gone."))
		return
	stow_item(human_owner, device.make_key(spawn_turf))
	to_chat(human_owner, span_notice("I am locked in \the [device]. The key is on me."))

/// The chosen device type, or the plain belt when the saved choice is missing or invalid.
/datum/quirk/neutral/kept_in_chastity/proc/get_device_type()
	var/chosen = customization_value
	if(istext(chosen))
		chosen = text2path(chosen)
	if(chosen in customization_options)
		return chosen
	return /obj/item/clothing/undies/chastity/belt

/// Puts [item] in a worn bag, else in hand, else leaves it at the owner's feet.
/datum/quirk/neutral/kept_in_chastity/proc/stow_item(mob/living/carbon/human/human_owner, obj/item/item)
	if(!item)
		return
	for(var/obj/item/storage/storage in human_owner.contents)
		if(SEND_SIGNAL(storage, COMSIG_TRY_STORAGE_INSERT, item, null, TRUE))
			return
	human_owner.put_in_hands(item)

#undef CHASTITY_KEY_CARRIED
#undef CHASTITY_KEY_LOST
