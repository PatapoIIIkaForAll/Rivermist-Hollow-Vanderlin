// Bare-chest emote: the upper-body counterpart of hem hiking.

#define BARE_GARMENT_SIGNALS list(COMSIG_MOVABLE_MOVED, COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETING)
#define BARE_ORGAN_SIGNALS list(COMSIG_ORGAN_REMOVED, COMSIG_PARENT_QDELETING)
// The flags the breasts descriptor checks before calling them exposed.
#define BARE_HIDE_FLAGS (HIDEBOOB|HIDEJUMPSUIT)

/// Whether this worn garment covers the chest or hides the breasts from a look.
/obj/item/clothing/proc/is_chest_cover()
	return (body_parts_covered & CHEST) || (flags_inv & BARE_HIDE_FLAGS)

/mob/living/carbon/proc/has_bared_chest()
	return !!GetComponent(/datum/component/bared_chest)

/mob/living/carbon/human/proc/get_chest_covers()
	. = list()
	for(var/obj/item/clothing/garment in get_equipped_items())
		if(garment.is_chest_cover())
			. += garment

/// Opens every chest cover when the sex panel could reach the breasts; an intentional caller hears why not.
/mob/living/carbon/human/proc/bare_chest(intentional = FALSE)
	if(has_bared_chest())
		return TRUE
	if(!getorganslot(ORGAN_SLOT_BREASTS))
		if(intentional)
			to_chat(src, span_warning("I have no breasts to bare."))
		return FALSE
	var/list/covers = get_chest_covers()
	if(!length(covers))
		if(intentional)
			to_chat(src, span_warning("My breasts are already bare."))
		return FALSE
	var/obj/item/sturdy = get_sex_covering_garment(BODY_ZONE_CHEST)
	if(sturdy)
		if(intentional)
			to_chat(src, span_warning("\The [sturdy] is too sturdy to pull open."))
		return FALSE
	if(is_organ_slot_blocked(ORGAN_SLOT_BREASTS))
		if(intentional)
			to_chat(src, span_warning("Something is fitted over my breasts."))
		return FALSE
	AddComponent(/datum/component/bared_chest, covers)
	return has_bared_chest()

/mob/living/carbon/human/proc/cover_bared_chest()
	var/datum/component/bared_chest/bared = GetComponent(/datum/component/bared_chest)
	if(bared)
		qdel(bared)

/// Opened chest garments and breasts shown above clothes; deleting it puts back exactly what changed.
/datum/component/bared_chest
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Opened garment to whether it covered the chest before.
	var/list/garments
	/// Breasts organ to its visible_through_clothes before baring.
	var/list/organ_visibility

/datum/component/bared_chest/Initialize(list/covers)
	if(!ishuman(parent) || !length(covers))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/human/wearer = parent
	garments = list()
	for(var/obj/item/clothing/garment as anything in covers)
		garments[garment] = !!(garment.body_parts_covered & CHEST)
		garment.body_parts_covered &= ~CHEST
		RegisterSignals(garment, BARE_GARMENT_SIGNALS, PROC_REF(on_release))
	organ_visibility = list()
	for(var/obj/item/organ/genitals/breasts in wearer.getorganslotlist(ORGAN_SLOT_BREASTS))
		organ_visibility[breasts] = breasts.visible_through_clothes
		breasts.visible_through_clothes = DRAW_ABOVE
		RegisterSignals(breasts, BARE_ORGAN_SIGNALS, PROC_REF(on_release))
	RegisterSignal(wearer, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	RegisterSignal(wearer, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped))
	wearer.regenerate_icons()

/datum/component/bared_chest/Destroy(force)
	restore()
	return ..()

/datum/component/bared_chest/proc/restore()
	for(var/obj/item/clothing/garment as anything in garments)
		if(garments[garment])
			garment.body_parts_covered |= CHEST
	for(var/obj/item/organ/genitals/breasts as anything in organ_visibility)
		breasts.visible_through_clothes = organ_visibility[breasts]
	garments = null
	organ_visibility = null
	var/mob/living/carbon/human/wearer = parent
	if(istype(wearer) && !QDELETED(wearer))
		// A torn top keeps the breasts shown after the emote lets go.
		wearer.refresh_torn_top_exposure()
		wearer.regenerate_icons()

/datum/component/bared_chest/proc/on_release(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/bared_chest/proc/on_stat_change(datum/source, new_stat)
	SIGNAL_HANDLER
	if(new_stat >= UNCONSCIOUS)
		qdel(src)

/// A new layer over the chest closes the opening.
/datum/component/bared_chest/proc/on_equipped(datum/source, obj/item/equipped, slot)
	SIGNAL_HANDLER
	if((slot & ITEM_SLOT_HANDS) || (equipped in garments))
		return
	var/obj/item/clothing/garment = equipped
	if(istype(garment) && garment.is_chest_cover())
		qdel(src)

/datum/emote/living/carbon/human/bare
	key = "bare"
	key_third_person = "bares"
	message = "pulls open their top, baring their breasts."
	emote_type = EMOTE_VISIBLE
	restraint_check = TRUE
	hands_use_check = TRUE
	var/message_covered = "covers their breasts again."

// Runechat then shows the picked text instead of always the baring line.
/datum/emote/living/carbon/human/bare/New()
	. = ..()
	runechat_msg = null

/datum/emote/living/carbon/human/bare/can_run_emote(mob/user, status_check = TRUE, intentional)
	if(!..())
		return FALSE
	return !!user.getorganslot(ORGAN_SLOT_BREASTS)

/datum/emote/living/carbon/human/bare/run_emote(mob/user, params, type_override, intentional, targetted)
	var/mob/living/carbon/human/barer = user
	if(!istype(barer))
		return FALSE
	if(!barer.getorganslot(ORGAN_SLOT_BREASTS))
		if(intentional)
			to_chat(barer, span_warning("I have no breasts to bare."))
		return FALSE
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	if(barer.has_bared_chest())
		barer.cover_bared_chest()
	else if(!barer.bare_chest(intentional))
		return FALSE
	return ..()

/// Runs after the change, so the text follows what actually happened.
/datum/emote/living/carbon/human/bare/select_message_type(mob/user, intentional)
	. = ..()
	var/mob/living/carbon/human/barer = user
	if(!istype(barer))
		return
	var/datum/component/bared_chest/bared = barer.GetComponent(/datum/component/bared_chest)
	var/list/covers = bared ? bared.garments : barer.get_chest_covers()
	var/obj/item/bra_only = (length(covers) == 1 && covers[1] == barer.bra) ? barer.bra : null
	if(bared)
		return bra_only ? "tugs their [bra_only.name] aside, baring their breasts." : .
	return bra_only ? "tugs their [bra_only.name] back into place." : message_covered

/mob/living/carbon/human/verb/emote_bare_chest()
	set name = "Bare Breasts"
	set category = "Emotes.Silent"

	emote("bare", intentional = TRUE)

#undef BARE_GARMENT_SIGNALS
#undef BARE_ORGAN_SIGNALS
#undef BARE_HIDE_FLAGS
