	/*==============*
	*				*
	*	Dullahan	*
	*				*
	*===============*/

/mob/living/carbon/human/species/dullahan
	race = /datum/species/dullahan

/datum/species/dullahan
	name = "Dullahan"
	id = SPEC_ID_DULLAHAN
	desc = "Dullahans are the cursed dead who did not stay down. Something in them refused the grave, \
	and the price was a body that no longer needs its head to keep walking. \
	\n\n\
	They look like any other folk until the head comes off. It can be lifted away by their own hands (the Lift Head action), \
	or wrenched off by an enemy with a firm grip, and they keep seeing, hearing and speaking through it \
	wherever it is carried. Only their own head fits back on. \
	\n\n\
	Losing the head is not fatal. Losing the fight still is: blows to a severed head rattle the brain \
	behind it, and a dullahan beaten down falls like anyone else. \
	\n\n\
	(Immune to the zombie rot. Neutral stats.) \
	\n\n\
	THIS IS A DISCRIMINATED SPECIES. PLAY AT YOUR OWN RISK."

	species_traits = list(EYECOLOR, HAIR, FACEHAIR, LIPS, STUBBLE, OLDGREY)
	inherent_traits = list(TRAIT_ZOMBIE_IMMUNE)
	use_skintones = TRUE

	possible_ages = NORMAL_AGES_LIST

	changesource_flags = WABBAJACK

	order_num = 36

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mm.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'
	allowed_body_builds = HUMANOID_BODY_BUILDS
	default_body_build_m = BODY_BUILD_AVERAGE
	default_body_build_f = BODY_BUILD_SLIM

	offset_features_m = list(
		OFFSET_RING = list(0,0),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK = list(0,0),\
		OFFSET_FACEMASK = list(0,0),\
		OFFSET_HEAD = list(0,0),\
		OFFSET_FACE = list(0,0),\
		OFFSET_BELT = list(0,0),\
		OFFSET_BACK = list(0,0),\
		OFFSET_NECK = list(0,0),\
		OFFSET_MOUTH = list(0,0),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,0),\
	)

	offset_features_f = list(
		OFFSET_RING = list(0,-1),\
		OFFSET_GLOVES = list(0,0),\
		OFFSET_WRISTS = list(0,0),\
		OFFSET_HANDS = list(0,0),\
		OFFSET_CLOAK_ = list(0,0),\
		OFFSET_FACEMASK = list(0,-1),\
		OFFSET_HEAD = list(0,-1),\
		OFFSET_FACE = list(0,-1),\
		OFFSET_BELT = list(0,-1),\
		OFFSET_BACK = list(0,-1),\
		OFFSET_NECK = list(0,-1),\
		OFFSET_MOUTH = list(0,-1),\
		OFFSET_PANTS = list(0,0),\
		OFFSET_SHIRT = list(0,0),\
		OFFSET_ARMOR = list(0,0),\
		OFFSET_UNDIES = list(0,-1),\
	)

	offset_genitals_m = list(
		OFFSET_PENIS = list(0,0),\
		OFFSET_BREASTS = list(0,0),\
		OFFSET_TESTICLES = list(0,0),\
		OFFSET_VAGINA = list(0,-3),\
	)

	offset_genitals_f = list(
		OFFSET_PENIS = list(0,0),\
		OFFSET_BREASTS = list(0,-1),\
		OFFSET_TESTICLES = list(0,0),\
		OFFSET_VAGINA = list(0,-4),\
	)

	enflamed_icon = "widefire"

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_SPLEEN = /obj/item/organ/spleen,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		ORGAN_SLOT_PUBIC = /obj/item/organ/genitals/pubes,
		ORGAN_SLOT_ANUS = /obj/item/organ/genitals/filling_organ/anus,
	)

	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
	)

	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/piercing,
		/datum/customizer/organ/genitals/penis/anthro,
		/datum/customizer/organ/genitals/vagina/anthro,
		/datum/customizer/organ/genitals/womb,
		/datum/customizer/organ/genitals/breasts/animal,
		/datum/customizer/organ/genitals/belly/animal,
		/datum/customizer/organ/genitals/butt/animal,
		/datum/customizer/organ/genitals/testicles/anthro,
		/datum/customizer/bodypart_feature/body_hair/optional,
		/datum/customizer/bodypart_feature/pubic_hair,
		/datum/customizer/bodypart_feature/armpit_hair,
	)

	/// TRUE while the head is off the body.
	var/headless = FALSE
	/// TRUE while the player looks through the detached head instead of the blind body.
	var/viewing_head = FALSE
	/// The one head that fits this body. Set on species gain, cleared on loss or destruction.
	var/obj/item/bodypart/head/dullahan/my_head
	/// The body this species datum belongs to.
	var/datum/weakref/owner_ref
	/// Glow at the neck stump while headless.
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj
	/// Player action that swaps the view between body and head.
	var/datum/action/innate/dullahan_shift_senses/view_action
	/// Player action that lifts the head off.
	var/datum/action/innate/dullahan_lift_head/lift_action
	/// Last scene action the body reported to a far-away head, so each one is told once.
	var/datum/weakref/last_felt_action_ref

/datum/species/dullahan/Destroy()
	my_head = null
	owner_ref = null
	QDEL_NULL(mob_light_obj)
	QDEL_NULL(view_action)
	QDEL_NULL(lift_action)
	return ..()

/datum/species/dullahan/check_roundstart_eligible()
	return TRUE

/datum/species/dullahan/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/dullahan/proc/get_owner()
	RETURN_TYPE(/mob/living/carbon/human)
	return owner_ref?.resolve()

/datum/species/dullahan/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	if(ishuman(C))
		owner_ref = WEAKREF(C)
		fit_dullahan_head(C)
	. = ..()
	if(!ishuman(C))
		return
	RegisterSignal(C, COMSIG_LIVING_REVIVE, PROC_REF(on_owner_revived))
	RegisterSignal(C, COMSIG_LIVING_DEFEAT_RESCUED, PROC_REF(on_owner_rescued))
	RegisterSignal(C, COMSIG_LIVING_DEATH, PROC_REF(on_owner_death))
	RegisterSignal(C, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_deleting))
	RegisterSignal(C, COMSIG_CARBON_REGENERATE_LIMBS, PROC_REF(on_owner_regenerate_limbs))
	RegisterSignal(C, COMSIG_SEX_RECEIVE_ACTION, PROC_REF(on_owner_feels_action))
	if(!view_action)
		view_action = new(C)
	view_action.Grant(C)
	if(!lift_action)
		lift_action = new(C)
	lift_action.Grant(C)

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	UnregisterSignal(C, list(COMSIG_LIVING_REVIVE, COMSIG_LIVING_DEFEAT_RESCUED, COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING, COMSIG_CARBON_REGENERATE_LIMBS, COMSIG_SEX_RECEIVE_ACTION))
	if(headless)
		recall_head(C)
	if(view_action)
		view_action.Remove(C)
	if(lift_action)
		lift_action.Remove(C)
	stop_light()
	GLOB.sense_relay_mobs -= C
	C.cure_blind(DULLAHAN_BODY_BLIND)
	C.cure_blind(DULLAHAN_HEAD_STORED_BLIND)
	// A dullahan head only answers to a dullahan body; any other species gets a plain one.
	if(my_head && !QDELETED(my_head) && my_head.owner == C && !istype(new_species, /datum/species/dullahan))
		var/obj/item/bodypart/head/old_head = my_head
		my_head = null
		var/obj/item/bodypart/head/plain_head = new()
		plain_head.replace_limb(C, TRUE)
		qdel(old_head)
	my_head = null
	headless = FALSE
	viewing_head = FALSE
	return ..()

/// Swaps whatever head the body has for a dullahan head. Runs before features so hair lands on the new head.
/datum/species/dullahan/proc/fit_dullahan_head(mob/living/carbon/human/C)
	var/obj/item/bodypart/head/old_head = C.get_bodypart(BODY_ZONE_HEAD)
	if(istype(old_head, /obj/item/bodypart/head/dullahan))
		my_head = old_head
		return
	var/obj/item/bodypart/head/dullahan/new_head = new()
	my_head = new_head
	if(old_head)
		new_head.replace_limb(C, TRUE)
		qdel(old_head)
	else
		new_head.attach_limb(C, TRUE)

/datum/species/dullahan/get_default_perspective(mob/living/carbon/human/H)
	if(!headless || !viewing_head || !my_head || QDELETED(my_head))
		return null
	// An item inside a mob does not render as an eye; look from the holder instead.
	if(ismob(my_head.loc))
		return my_head.loc
	return my_head

// Perception relays: the body senses from wherever the head is.
/mob/living/carbon/human/get_sense_anchor()
	var/datum/species/dullahan/dullahan_species = dna?.species
	if(istype(dullahan_species) && dullahan_species.headless && dullahan_species.my_head && !QDELETED(dullahan_species.my_head))
		return dullahan_species.my_head
	return ..()

/mob/living/carbon/human/get_voice_anchor(soundin)
	var/datum/species/dullahan/dullahan_species = dna?.species
	if(!istype(dullahan_species) || !dullahan_species.headless)
		return ..()
	var/sound_path = "[soundin]"
	if(istype(soundin, /sound))
		var/sound/sound_datum = soundin
		sound_path = "[sound_datum.file]"
	if(!findtext(sound_path, "sound/vo"))
		return ..()
	return get_sense_anchor()

/// Whoever can see the head also sees what the headless body does.
/mob/living/carbon/human/get_portal_visible_message_recipients()
	. = ..()
	var/obj/item/bodypart/head/dullahan/head = get_detached_dullahan_head(src)
	if(!head)
		return
	var/turf/head_turf = get_turf(head)
	if(!head_turf)
		return
	var/list/recipients = . || list()
	for(var/mob/viewer in viewers(world.view, head_turf))
		if(viewer != src)
			recipients |= viewer
	return recipients

/// The mask rides on the detached head, so the mouth cover check has to look there.
/mob/living/carbon/human/is_mouth_covered(check_flags = ALL)
	var/obj/item/bodypart/head/dullahan/head = get_detached_dullahan_head(src)
	if(!head)
		return ..()
	if((check_flags & ITEM_SLOT_HEAD) && head.stored_hat && (head.stored_hat.flags_cover & HEADCOVERSMOUTH))
		return head.stored_hat
	if((check_flags & ITEM_SLOT_MASK) && head.stored_mask && (head.stored_mask.flags_cover & MASKCOVERSMOUTH))
		return head.stored_mask
	return FALSE

/// Feeding a headless dullahan happens at the head: the feeder stands on its tile or holds it.
/mob/living/carbon/human/is_facing_feeder(mob/user)
	var/obj/item/bodypart/head/dullahan/head = get_detached_dullahan_head(src)
	if(!head)
		return ..()
	return user.is_holding(head) || get_turf(head) == get_turf(user)

/// A headless dullahan bites whoever holds the head or stands on its tile.
/mob/living/carbon/human/bite_reach(atom/target)
	var/obj/item/bodypart/head/dullahan/head = get_detached_dullahan_head(src)
	if(!head)
		return ..()
	if(!target)
		return FALSE
	if(ismob(target))
		var/mob/target_mob = target
		if(target_mob.is_holding(head))
			return TRUE
	return isturf(head.loc) && get_turf(head) == get_turf(target)

/// The curse burns at the neck stump while the head is off.
/datum/species/dullahan/handle_body(mob/living/carbon/human/H)
	. = ..()
	if(!headless || H.stat == DEAD)
		return
	var/mutable_appearance/flame = mutable_appearance('icons/mob/sprite_accessory/souls.dmi', "neckfire", -BODY_LAYER)
	var/list/offsets = H.get_offset_features()
	if(LAZYACCESS(offsets, OFFSET_FACE))
		flame.pixel_x += offsets[OFFSET_FACE][1]
		flame.pixel_y += offsets[OFFSET_FACE][2]
	var/list/standing = H.overlays_standing[BODY_LAYER]
	H.remove_overlay(BODY_LAYER)
	standing = islist(standing) ? standing : list()
	standing += flame
	H.overlays_standing[BODY_LAYER] = standing
	H.apply_overlay(BODY_LAYER)

// Head lifecycle, called by the head bodypart.

/datum/species/dullahan/proc/on_head_detached(obj/item/bodypart/head/dullahan/head)
	var/mob/living/carbon/human/H = get_owner()
	if(!H || head != my_head)
		return
	headless = TRUE
	viewing_head = TRUE
	GLOB.sense_relay_mobs |= H
	head.become_hearing_sensitive(DULLAHAN_HEAD_TRAIT)
	RegisterSignal(head, COMSIG_MOVABLE_MOVED, PROC_REF(on_head_moved))
	start_light(H)
	refresh_senses(H)
	// The base limb code redrew the body before headless was set; draw the flame now.
	H.update_body()
	view_action?.build_all_button_icons()
	lift_action?.build_all_button_icons()

/datum/species/dullahan/proc/on_head_attached(obj/item/bodypart/head/dullahan/head)
	var/mob/living/carbon/human/H = get_owner()
	clear_dullahan_head_contexts(head)
	if(!my_head)
		my_head = head
	if(head != my_head)
		return
	headless = FALSE
	viewing_head = FALSE
	head.lose_hearing_sensitivity(DULLAHAN_HEAD_TRAIT)
	UnregisterSignal(head, COMSIG_MOVABLE_MOVED)
	stop_light()
	if(!H)
		return
	GLOB.sense_relay_mobs -= H
	refresh_senses(H)
	H.update_body()
	view_action?.build_all_button_icons()
	lift_action?.build_all_button_icons()

/datum/species/dullahan/proc/on_head_moved(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = get_owner()
	if(H)
		refresh_senses(H)
		if(H.sex_scene)
			ensure_dullahan_head_contexts(H.sex_scene)

/// Called from the head's Destroy. Losing the head outright is lethal unless the defeat system catches it.
/datum/species/dullahan/proc/on_head_destroyed(obj/item/bodypart/head/dullahan/head)
	if(head != my_head)
		return
	my_head = null
	var/mob/living/carbon/human/H = get_owner()
	if(!H || QDELETED(H))
		return
	headless = TRUE
	viewing_head = FALSE
	stop_light()
	GLOB.sense_relay_mobs -= H
	refresh_senses(H)
	if(H.stat == DEAD || (H.status_flags & GODMODE))
		return
	if(H.defeat_intercept_lethal())
		to_chat(H, span_userdanger("My head is gone. The curse holds my body together, barely."))
		return
	H.death()

/// Blindness and perspective follow where the head is and which end the player looks through.
/datum/species/dullahan/proc/refresh_senses(mob/living/carbon/human/H)
	if(!headless)
		H.cure_blind(DULLAHAN_BODY_BLIND)
		H.cure_blind(DULLAHAN_HEAD_STORED_BLIND)
		H.reset_perspective()
		return
	if(!my_head || QDELETED(my_head))
		H.become_blind(DULLAHAN_BODY_BLIND)
		H.cure_blind(DULLAHAN_HEAD_STORED_BLIND)
		H.reset_perspective()
		return
	if(isturf(my_head.loc) || ismob(my_head.loc))
		H.cure_blind(DULLAHAN_HEAD_STORED_BLIND)
	else
		H.become_blind(DULLAHAN_HEAD_STORED_BLIND)
	if(viewing_head)
		H.cure_blind(DULLAHAN_BODY_BLIND)
	else
		H.become_blind(DULLAHAN_BODY_BLIND)
	H.reset_perspective()

/datum/species/dullahan/proc/toggle_view(mob/living/carbon/human/H)
	if(!headless || !my_head || QDELETED(my_head))
		return FALSE
	viewing_head = !viewing_head
	refresh_senses(H)
	to_chat(H, span_notice(viewing_head ? "I look out through my head." : "I sink back into my body. The dark is total."))
	return TRUE

/datum/species/dullahan/proc/start_light(mob/living/carbon/human/H)
	if(mob_light_obj || H.stat == DEAD)
		return
	mob_light_obj = H.mob_light("#ffb347", 2, 2)

/datum/species/dullahan/proc/stop_light()
	QDEL_NULL(mob_light_obj)

/// Recovery brings the head back: pulled to the body and reattached, or grown fresh if it is gone.
/datum/species/dullahan/proc/recall_head(mob/living/carbon/human/H)
	if(!H || QDELETED(H))
		return FALSE
	if(my_head && !QDELETED(my_head))
		if(my_head.owner == H)
			return TRUE
		if(ismob(my_head.loc))
			var/mob/holder = my_head.loc
			holder.dropItemToGround(my_head, force = TRUE, silent = TRUE)
		my_head.forceMove(get_turf(H))
		H.visible_message(span_notice("[H]'s head drags itself back to [H.p_their()] neck."), span_notice("My head finds its way home."))
		my_head.attach_limb(H)
		return TRUE
	var/obj/item/bodypart/head/dullahan/new_head = new()
	my_head = new_head
	new_head.attach_limb(H, TRUE)
	H.visible_message(span_warning("Flesh knits over [H]'s neck and a new head takes shape."), span_warning("The curse builds me a new head."))
	return TRUE

/datum/species/dullahan/proc/on_owner_revived(datum/source, full_heal_flags)
	SIGNAL_HANDLER
	if(headless)
		recall_head(source)

/// Full heals regrow limbs before the revive signal fires; bring the real head back first.
/datum/species/dullahan/proc/on_owner_regenerate_limbs(datum/source, list/excluded_zones)
	SIGNAL_HANDLER
	if(headless)
		recall_head(source)

/datum/species/dullahan/proc/on_owner_rescued(datum/source, mob/living/helper, rescue_source)
	SIGNAL_HANDLER
	if(headless)
		recall_head(source)

/// Looking out of a far-away head, the body still reports what is being done to it.
/datum/species/dullahan/proc/on_owner_feels_action(datum/source, datum/sex_action/action, mob/living/receiver, mob/living/partner)
	SIGNAL_HANDLER
	if(!action || !headless || !viewing_head || !my_head || QDELETED(my_head))
		return
	var/mob/living/carbon/human/H = source
	if(my_head.z == H.z && get_dist(my_head, H) <= world.view)
		return
	if(last_felt_action_ref?.resolve() == action)
		return
	last_felt_action_ref = WEAKREF(action)
	var/who = (partner && partner != H) ? "[partner]" : "someone"
	to_chat(H, span_notice("Far from where my eyes are, my body feels [who] at work: [LOWER_TEXT(action.name)]."))

/datum/species/dullahan/proc/on_owner_death(datum/source)
	SIGNAL_HANDLER
	stop_light()
	var/mob/living/carbon/human/H = source
	if(istype(H))
		H.update_body()

/datum/species/dullahan/proc/on_owner_deleting(datum/source)
	SIGNAL_HANDLER
	GLOB.sense_relay_mobs -= source
	stop_light()

// Taking the head off and putting it back.

/// A worn NODROP item on the head, neck or face keeps the head bound to the neck.
/datum/species/dullahan/proc/get_nodrop_head(mob/living/carbon/human/H)
	for(var/obj/item/equipped_item in H.get_equipped_items(include_pockets = FALSE))
		if(!HAS_TRAIT(equipped_item, TRAIT_NODROP))
			continue
		if(equipped_item.slot_flags & (ITEM_SLOT_MOUTH | ITEM_SLOT_HEAD | ITEM_SLOT_NECK | ITEM_SLOT_MASK))
			return equipped_item
	return null

/// Drops the head and hands it to `taker`, or lets it fall if no one takes it.
/datum/species/dullahan/proc/detach_head(mob/living/carbon/human/H, mob/living/taker)
	if(headless || !my_head || my_head.owner != H)
		return FALSE
	var/obj/item/bodypart/head/dullahan/head = my_head
	if(!head.drop_limb())
		return FALSE
	if(taker && !QDELETED(taker))
		taker.put_in_hands(head)
	return TRUE

/datum/species/dullahan/proc/try_detach_self(mob/living/carbon/human/H)
	if(headless || !my_head || my_head.owner != H)
		return FALSE
	var/obj/item/equipped_nodrop = get_nodrop_head(H)
	if(equipped_nodrop)
		to_chat(H, span_warning("[equipped_nodrop] keeps my head bound to my neck!"))
		return FALSE
	H.visible_message(span_notice("[H] begins lifting [H.p_their()] own head off..."), span_notice("I begin lifting my head off..."))
	if(!do_after(H, 3 SECONDS, H))
		return FALSE
	if(headless || !my_head || my_head.owner != H)
		return FALSE
	return detach_head(H, H)

/// An aggressive grab on the head, twisted: the head comes off into the grabber's hand.
/datum/species/dullahan/proc/try_twist_off_head(mob/living/user, obj/item/grabbing/grab)
	var/mob/living/carbon/human/H = get_owner()
	if(!H || headless || !my_head || my_head.owner != H || !user || QDELETED(grab))
		return FALSE
	var/obj/item/equipped_nodrop = get_nodrop_head(H)
	if(equipped_nodrop)
		H.visible_message(span_danger("[H]'s head fails to come off!"), span_danger("[user] tries to twist my head off, but [equipped_nodrop] keeps it bound to my neck!"))
		to_chat(user, span_warning("[H]'s head stays bound to [H.p_their()] neck by [equipped_nodrop]!"))
		return FALSE
	H.visible_message(span_danger("[user] wrenches at [H]'s head!"), span_userdanger("[user] is twisting my head off!"))
	to_chat(user, span_warning("I twist at [H]'s head..."))
	if(!do_after(user, 3 SECONDS, H))
		return FALSE
	if(headless || !my_head || my_head.owner != H)
		return FALSE
	var/hand_index = QDELETED(grab) ? null : user.get_held_index_of_item(grab)
	if(!QDELETED(grab))
		qdel(grab)
	var/obj/item/bodypart/head/dullahan/head = my_head
	if(!detach_head(H, null))
		return FALSE
	if(hand_index)
		user.put_in_hand(head, hand_index)
	else
		user.put_in_hands(head)
	H.visible_message(span_danger("<B>[user] twists [H]'s head clean off!</B>"), span_userdanger("[user] twists my head off!"))
	log_combat(user, H, "twisted the head off")
	return TRUE

/datum/action/innate/dullahan_lift_head
	name = "Lift Head"
	desc = "Lift your own head off your shoulders. Takes a few seconds."
	button_icon_state = "shieldsparkles"

/datum/action/innate/dullahan_lift_head/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/H = owner
	var/datum/species/dullahan/dullahan_species = H.dna?.species
	return istype(dullahan_species) && !dullahan_species.headless

/datum/action/innate/dullahan_lift_head/Activate()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/dullahan/dullahan_species = H.dna?.species
	if(!istype(dullahan_species) || H.incapacitated())
		return
	INVOKE_ASYNC(dullahan_species, TYPE_PROC_REF(/datum/species/dullahan, try_detach_self), H)

/datum/action/innate/dullahan_shift_senses
	name = "Shift Senses"
	desc = "Look through your severed head, or sink back into the dark of your body."
	button_icon_state = "shieldsparkles"

/datum/action/innate/dullahan_shift_senses/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/H = owner
	var/datum/species/dullahan/dullahan_species = H.dna?.species
	return istype(dullahan_species) && dullahan_species.headless

/datum/action/innate/dullahan_shift_senses/Activate()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/dullahan/dullahan_species = H.dna?.species
	if(!istype(dullahan_species))
		return
	dullahan_species.toggle_view(H)
