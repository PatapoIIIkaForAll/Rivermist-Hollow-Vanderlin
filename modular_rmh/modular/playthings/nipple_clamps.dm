// Nipple clamps: worn on the chest like piercings, they bite with arousal pain and never wound.

#define BODYPART_FEATURE_NIPPLE_CLAMPS "nipple_clamps"

/mob/living/carbon
	/// Nipple clamps biting this mob right now.
	var/obj/item/nipple_clamps/nipple_clamps

/datum/sprite_accessory/nipple_clamps
	name = "nipple clamps"
	icon = 'modular_rmh/icons/mob/sprite_accessory/nipple_clamps.dmi'
	icon_state = "clamps"
	color_key_name = "Clamps"
	layer = BODY_ADJ_TOP_TOP_LAYER

/datum/sprite_accessory/nipple_clamps/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = owner?.getorganslot(ORGAN_SLOT_BREASTS)
	return "[icon_state]-[clamp(breasts?.organ_size || 1, 1, 5)]"

/datum/sprite_accessory/nipple_clamps/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	gender_genitals_adjust(appearance_list, organ, bodypart, owner, OFFSET_BREASTS)

/datum/sprite_accessory/nipple_clamps/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = owner.getorganslot(ORGAN_SLOT_BREASTS)
	if(breasts?.visible_through_clothes)
		return TRUE
	var/obj/item/clothing/undies/worn_underwear = owner.underwear
	return is_human_part_visible(owner, HIDEBOOB) && !worn_underwear?.covers_breasts

/datum/bodypart_feature/nipple_clamps
	name = "Nipple clamps"
	feature_slot = BODYPART_FEATURE_NIPPLE_CLAMPS
	body_zone = BODY_ZONE_CHEST

/obj/item/nipple_clamps
	name = "nipple clamps"
	desc = "Two small iron clamps joined by a fine chain. They bite, and the chain begs to be tugged."
	icon = 'modular_rmh/icons/obj/lewd/playthings.dmi'
	icon_state = "nipple_clamps"
	possible_item_intents = list(/datum/intent/use)
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	drop_sound = 'sound/foley/dropsound/chain_drop.ogg'
	sellprice = 6
	/// The chest feature that draws the worn clamps.
	var/datum/bodypart_feature/nipple_clamps/clamps_feature

/obj/item/nipple_clamps/Destroy()
	var/mob/living/carbon/wearer = loc
	if(istype(wearer) && wearer.nipple_clamps == src)
		remove_worn_state(wearer)
	return ..()

/obj/item/nipple_clamps/attack(mob/living/target, mob/living/user, def_zone)
	var/mob/living/carbon/human/wearer = target
	if(!istype(wearer) || user.zone_selected != BODY_ZONE_CHEST)
		return ..()
	if(wearer.nipple_clamps)
		to_chat(user, span_warning("[wearer == user ? "My" : "[wearer]'s"] nipples are already clamped."))
		return
	var/obj/item/clothing/cover = wearer.get_sex_covering_garment(BODY_ZONE_CHEST, user)
	if(cover)
		to_chat(user, span_warning("[cover] is in the way."))
		return
	user.visible_message(span_warning("[user] opens [src] over [wearer == user ? user.p_their() : "[wearer]'s"] nipples..."))
	if(!do_after(user, wearer == user ? 3 SECONDS : 5 SECONDS, target = wearer))
		return
	if(wearer.nipple_clamps || wearer.get_sex_covering_garment(BODY_ZONE_CHEST, user))
		return
	if(!user.temporarilyRemoveItemFromInventory(src))
		return
	if(!clamp_onto(wearer))
		forceMove(user.drop_location())
		return
	user.visible_message(span_warning("[user] lets [src] snap shut on [wearer == user ? user.p_their() : "[wearer]'s"] nipples."))
	SEND_SIGNAL(wearer, COMSIG_SEX_GENERIC_ACTION, user, 1, 8, 0.2, src)

/// Fits the clamps onto [wearer]'s chest. Returns TRUE on success.
/obj/item/nipple_clamps/proc/clamp_onto(mob/living/carbon/human/wearer)
	var/obj/item/bodypart/chest = wearer.get_bodypart(BODY_ZONE_CHEST)
	if(!chest || wearer.nipple_clamps)
		return FALSE
	var/datum/bodypart_feature/nipple_clamps/feature = new
	feature.set_accessory_type(/datum/sprite_accessory/nipple_clamps, "#FFFFFF", wearer)
	if(!chest.add_bodypart_feature(feature))
		qdel(feature)
		return FALSE
	clamps_feature = feature
	forceMove(wearer)
	wearer.nipple_clamps = src
	wearer.apply_status_effect(/datum/status_effect/nipple_clamps)
	return TRUE

/// Takes the clamps off [wearer] into [remover]'s hands; blood rushing back stings.
/obj/item/nipple_clamps/proc/unclamp(mob/living/carbon/human/wearer, mob/living/remover)
	if(wearer.nipple_clamps != src)
		return FALSE
	remove_worn_state(wearer)
	forceMove(wearer.drop_location())
	remover?.put_in_hands(src)
	if(remover && remover != wearer)
		remover.visible_message(span_warning("[remover] pulls [src] off [wearer]'s nipples."))
	else
		wearer.visible_message(span_warning("[wearer] eases [src] off [wearer.p_their()] nipples."))
	to_chat(wearer, span_love("Blood rushes back into my nipples, hot and stinging."))
	SEND_SIGNAL(wearer, COMSIG_SEX_GENERIC_ACTION, remover || wearer, 1.5, 12, 0.5, src)
	return TRUE

/obj/item/nipple_clamps/proc/remove_worn_state(mob/living/carbon/wearer)
	var/obj/item/bodypart/chest = wearer.get_bodypart(BODY_ZONE_CHEST)
	if(clamps_feature)
		chest?.remove_bodypart_feature(clamps_feature)
		clamps_feature = null
	wearer.nipple_clamps = null
	wearer.remove_status_effect(/datum/status_effect/nipple_clamps)

/// Self-removal from the chest; clamps come off before any piercing.
/mob/living/carbon/human/proc/try_remove_own_nipple_clamps()
	if(!nipple_clamps)
		return FALSE
	visible_message(span_notice("[src] reaches for [nipple_clamps]..."))
	if(do_after(src, 2 SECONDS, target = src))
		nipple_clamps?.unclamp(src, src)
	return TRUE

/datum/status_effect/nipple_clamps
	id = "nipple_clamps"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 30 SECONDS
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = null

/datum/status_effect/nipple_clamps/tick()
	var/mob/living/carbon/wearer = owner
	if(!istype(wearer) || !wearer.nipple_clamps)
		qdel(src)
		return
	SEND_SIGNAL(wearer, COMSIG_SEX_GENERIC_ACTION, wearer, 0.6, 3, 0.1, wearer.nipple_clamps)
	if(prob(30))
		to_chat(wearer, span_love(pick("The clamps bite at my nipples.", "A dull throb pulses from my clamped nipples.", "The chain sways and tugs at me.")))

/datum/sex_action/nipple_clamps
	abstract_type = /datum/sex_action/nipple_clamps
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	requires_free_hands = TRUE

/datum/sex_action/nipple_clamps/shows_on_menu(mob/living/user, mob/living/target)
	var/mob/living/carbon/clamped = target
	return user != target && istype(clamped) && clamped.nipple_clamps

/datum/sex_action/nipple_clamps/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || !shows_on_menu(user, target))
		return FALSE
	if(!find_available_hand(user) || check_sex_lock(target, BODY_ZONE_CHEST))
		return FALSE
	return check_location_accessible(user, target, BODY_ZONE_CHEST)

/datum/sex_action/nipple_clamps/lock_sex_object(mob/living/user, mob/living/target)
	var/hand = get_hand_lock_slot(user)
	if(hand)
		add_sex_lock(user, hand)
	add_sex_lock(target, BODY_ZONE_CHEST, null, FALSE)

/datum/sex_action/nipple_clamps/tug
	name = "Tug chain"
	description = "Hook a finger through the chain between their nipple clamps and pull."

/datum/sex_action/nipple_clamps/tug/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] hooks a finger through the chain between [target]'s nipple clamps."))

/datum/sex_action/nipple_clamps/tug/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force("[user] [get_generic_force_adjective()] tugs the chain, drawing [target]'s clamped nipples taut..."))
	playsound(target, SFX_JINGLE_BELLS, 15 + force * 5, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 1.2 + force * 0.2, 2 * force, 0.8)
	handle_passive_ejaculation(target)

/datum/sex_action/nipple_clamps/tug/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets the chain fall slack against [target]'s chest."))

/datum/sex_action/nipple_clamps/take_off
	name = "Remove clamps"
	description = "Release their nipple clamps and let the blood rush back."

/datum/sex_action/nipple_clamps/take_off/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/human/clamped = target
	if(istype(clamped))
		clamped.nipple_clamps?.unclamp(clamped, user)
	stop_runtime()

/datum/anvil_recipe/nipple_clamps
	name = "Nipple clamps 2x"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/nipple_clamps
	createditem_extra = 1
	i_type = "Lewd"

#undef BODYPART_FEATURE_NIPPLE_CLAMPS
