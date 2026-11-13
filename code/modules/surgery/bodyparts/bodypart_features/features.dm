/datum/bodypart_feature/hair
	var/hair_color = "#FFFFFF"
	var/natural_gradient = /datum/hair_gradient/none
	var/natural_color = "#FFFFFF"
	var/hair_dye_gradient = /datum/hair_gradient/none
	var/hair_dye_color = "#FFFFFF"
	var/natural_accessory_type

	var/static/list/extensions

/datum/bodypart_feature/hair/bodypart_overlays(mutable_appearance/standing, obj/item/bodypart/bodypart)
	var/dynamic_hair_suffix = ""

	var/mob/living/carbon/H = bodypart.owner
	if(!H)
		H = bodypart.original_owner

	if(H.head)
		var/obj/item/I = H.head
		if(isclothing(I))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(H.wear_neck)
		var/obj/item/I = H.wear_neck
		if(!dynamic_hair_suffix && isclothing(I)) //head > mask in terms of head hair
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix

	if(!extensions)
		var/icon/hair_extensions = icon('icons/roguetown/mob/hair_extensions.dmi') //hehe
		extensions = list()
		for(var/s in hair_extensions.IconStates(1))
			extensions[s] = TRUE
		qdel(hair_extensions)

	var/dynamic = FALSE
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
	if(extensions[accessory.icon_state+dynamic_hair_suffix])
		dynamic = dynamic_hair_suffix

	add_gradient_overlay(standing, natural_gradient, natural_color, dynamic)
	add_gradient_overlay(standing, hair_dye_gradient, hair_dye_color, dynamic)

/datum/bodypart_feature/hair/proc/add_gradient_overlay(mutable_appearance/standing, gradient_type, gradient_color, dynamic = FALSE)
	if(gradient_type == /datum/hair_gradient/none)
		return
	var/datum/hair_gradient/gradient = HAIR_GRADIENT(gradient_type)
	var/icon/temp = icon(gradient.icon, gradient.icon_state)
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(accessory_type)
	var/icon/temp_hair
	if(dynamic)
		temp_hair = icon(accessory.dynamic_file, "[accessory.icon_state][dynamic]")
	else
		temp_hair = icon(accessory.icon, accessory.icon_state)

	temp.Blend(temp_hair, ICON_ADD)
	var/mutable_appearance/gradient_appearance = mutable_appearance(temp)
	gradient_appearance.color = gradient_color
	standing.overlays += gradient_appearance

/datum/bodypart_feature/hair/head
	name = "Hair"
	feature_slot = BODYPART_FEATURE_HAIR
	body_zone = BODY_ZONE_HEAD

/datum/bodypart_feature/hair/facial
	name = "Facial Hair"
	feature_slot = BODYPART_FEATURE_FACIAL_HAIR
	body_zone = BODY_ZONE_HEAD

/datum/bodypart_feature/face_detail
	name = "Face Detail"
	feature_slot = BODYPART_FEATURE_FACE_DETAIL
	body_zone = BODY_ZONE_HEAD

/datum/bodypart_feature/accessory
	name = "Accessory"
	feature_slot = BODYPART_FEATURE_ACCESSORY
	body_zone = BODY_ZONE_HEAD

/datum/bodypart_feature/vamprire_seal
	name = "Vampiric Seal"
	feature_slot = BODYPART_FEATURE_BRAND
	body_zone = BODY_ZONE_CHEST
	accessory_colors = COLOR_RED
	accessory_type = /datum/sprite_accessory/brand/vampire_seal

#define DRUNK_BLUSH_THRESHOLD 41

/mob/living/carbon/human
	var/tmp/list/visual_emote_overlay_expiries
	var/tmp/list/visual_emote_overlays

/mob/living/carbon/human/proc/show_visual_emote_overlay(datum/bodypart_feature/visual_emote/overlay_typepath, duration)
	if(!ispath(overlay_typepath, /datum/bodypart_feature/visual_emote))
		return
	var/feature_slot = overlay_typepath::feature_slot
	if(duration)
		LAZYINITLIST(visual_emote_overlay_expiries)
		var/expires_at = world.time + duration
		var/current_expiry = LAZYACCESS(visual_emote_overlay_expiries, feature_slot)
		if(!current_expiry || current_expiry < expires_at)
			visual_emote_overlay_expiries[feature_slot] = expires_at
		addtimer(CALLBACK(src, PROC_REF(expire_visual_emote_overlay), overlay_typepath, expires_at), duration)
	return ensure_visual_emote_overlay(overlay_typepath)

/mob/living/carbon/human/proc/ensure_visual_emote_overlay(datum/bodypart_feature/visual_emote/overlay_typepath)
	var/feature_slot = overlay_typepath::feature_slot
	var/mutable_appearance/current_overlay = LAZYACCESS(visual_emote_overlays, feature_slot)
	if(current_overlay)
		return current_overlay
	var/mutable_appearance/new_overlay = build_visual_emote_overlay(overlay_typepath)
	if(!new_overlay)
		return
	LAZYSET(visual_emote_overlays, feature_slot, new_overlay)
	add_overlay(new_overlay)
	return new_overlay

/mob/living/carbon/human/proc/expire_visual_emote_overlay(datum/bodypart_feature/visual_emote/overlay_typepath, expected_expiry)
	var/feature_slot = overlay_typepath::feature_slot
	if(LAZYACCESS(visual_emote_overlay_expiries, feature_slot) > expected_expiry)
		return
	visual_emote_overlay_expiries -= feature_slot
	if(!length(visual_emote_overlay_expiries))
		visual_emote_overlay_expiries = null
	if(feature_slot == BODYPART_FEATURE_BLUSH && should_have_drunk_blush_overlay())
		return
	remove_visual_emote_overlay(feature_slot)

/mob/living/carbon/human/proc/remove_visual_emote_overlay(feature_slot)
	var/mutable_appearance/overlay = LAZYACCESS(visual_emote_overlays, feature_slot)
	if(!overlay)
		return
	cut_overlay(overlay)
	visual_emote_overlays -= feature_slot
	if(!length(visual_emote_overlays))
		visual_emote_overlays = null

/mob/living/carbon/human/proc/has_temporary_visual_emote_overlay(feature_slot)
	var/expires_at = LAZYACCESS(visual_emote_overlay_expiries, feature_slot)
	return expires_at && expires_at > world.time

/mob/living/carbon/human/proc/should_have_drunk_blush_overlay()
	return drunkenness >= DRUNK_BLUSH_THRESHOLD && stat != DEAD

/mob/living/carbon/human/proc/update_drunk_blush_overlay()
	if(should_have_drunk_blush_overlay())
		ensure_visual_emote_overlay(/datum/bodypart_feature/visual_emote/blush)
	else if(!has_temporary_visual_emote_overlay(BODYPART_FEATURE_BLUSH))
		remove_visual_emote_overlay(BODYPART_FEATURE_BLUSH)

/mob/living/carbon/human/proc/show_visual_emote_animation(icon_state, duration)
	var/image/emote_animation = image('icons/mob/human/emote_visuals.dmi', src, icon_state, BODY_FRONT_LAYER)
	flick_overlay(emote_animation, GLOB.clients, duration)

#undef DRUNK_BLUSH_THRESHOLD

/datum/bodypart_feature/visual_emote
	name = "Visual Emote"
	body_zone = BODY_ZONE_HEAD
	var/icon_state
	var/draw_color
	var/draw_alpha = 255

/mob/living/carbon/human/proc/build_visual_emote_overlay(datum/bodypart_feature/visual_emote/overlay_typepath)
	if(!get_bodypart(overlay_typepath::body_zone))
		return
	var/mutable_appearance/emote_overlay = mutable_appearance('icons/mob/human/emote_visuals.dmi', overlay_typepath::icon_state, BODY_FRONT_LAYER)
	emote_overlay.color = overlay_typepath::draw_color
	emote_overlay.alpha = overlay_typepath::draw_alpha

	apply_offset(emote_overlay, OFFSET_FACE)
	return emote_overlay

/datum/bodypart_feature/visual_emote/tongue
	name = "Tongue"
	feature_slot = BODYPART_FEATURE_TONGUE_EMOTE
	icon_state = "tongue"
	draw_color = "#ff6ea0"

/datum/bodypart_feature/visual_emote/blush
	name = "Blush"
	feature_slot = BODYPART_FEATURE_BLUSH
	icon_state = "blush"
	draw_color = "#DE5D83"
	draw_alpha = 200

/datum/bodypart_feature/visual_emote/cry
	name = "Tears"
	feature_slot = BODYPART_FEATURE_CRY_EMOTE
	icon_state = "tears"
	draw_color = "#008B8B"

