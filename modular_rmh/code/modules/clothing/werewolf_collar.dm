/obj/item/clothing/neck/moonshackle_collar
	name = "moonshackle collar"
	desc = "A heavy silver collar set with costly gemstones. The inner band is engraved to keep the beast bound in mortal flesh."
	icon_state = "collar_of_servitude"
	item_state = "collar_of_servitude"
	blocksound = PLATEHIT
	equip_sound = 'sound/foley/equip/equip_armor.ogg'
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	break_sound = 'sound/foley/breaksound.ogg'
	smeltresult = /obj/item/ingot/silver
	melting_material = /datum/material/silver
	melt_amount = 100
	anvilrepair = /datum/attribute/skill/craft/blacksmithing
	clothing_flags = CANT_SLEEP_IN
	armor_type = /datum/armor/rmh/neck/moonshackle
	max_integrity = INTEGRITY_STRONG
	prevent_crits = CUT_AND_MINOR_CRITS
	sellprice = 180
	/// Time the collar takes to force a beast back into human skin.
	var/reversion_time = WW_COLLAR_REVERSION_TIME
	/// Beast being forced back; set only while a reversion runs.
	var/datum/weakref/reverting_beast_ref
	/// world.time at which the running reversion completes.
	var/reversion_end_time = 0
	/// Timer for the next countdown step of the reversion.
	var/reversion_timer
	/// TRUE while worn on a neck, so dropping it from hands stays quiet.
	var/worn_on_neck = FALSE
	/// TRUE while the collar itself sheds the beast body, to quiet the drop.
	var/finishing_reversion = FALSE

/obj/item/clothing/neck/moonshackle_collar/Initialize(mapload)
	. = ..()
	// A dedicated werewolf-only trait keeps the collar local to that mechanic.
	attach_clothing_traits(TRAIT_WEREWOLF_TRANSFORMATION_SUPPRESSED)
	// Clothing refuses the beast species by default; this collar is made for its throat.
	allowed_race = ALL_RACES_LIST + /datum/species/werewolf::id

/obj/item/clothing/neck/moonshackle_collar/Destroy()
	stop_reversion()
	return ..()

/obj/item/clothing/neck/moonshackle_collar/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_NECK)
		return
	worn_on_neck = TRUE
	RegisterSignal(user, COMSIG_PARENT_EXAMINE, PROC_REF(on_wearer_examine), override = TRUE)
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(user)
	if(!wolf)
		return
	if(wolf.transformed && wolf.owner.current == user)
		start_reversion(user)
		return

	to_chat(user, span_warning("The silver collar tightens, forcing the beast back under my skin."))

/obj/item/clothing/neck/moonshackle_collar/dropped(mob/user)
	. = ..()
	if(!worn_on_neck)
		return
	worn_on_neck = FALSE
	UnregisterSignal(user, COMSIG_PARENT_EXAMINE)
	if(finishing_reversion)
		return
	var/was_reverting = stop_reversion()
	if(!IS_WEREWOLF(user))
		return
	if(was_reverting)
		user.visible_message(span_warning("The moonshackle collar comes loose from [user]'s throat!"), span_notice("The collar comes loose before it can finish. The beast keeps its skin."))
		return

	to_chat(user, span_notice("The moonshackle's grip slackens, and the beast stirs once more."))

/obj/item/clothing/neck/moonshackle_collar/proc/is_reverting()
	return !!reverting_beast_ref

/// Starts the channelled reversion that ends with the beast forced back into its human skin.
/obj/item/clothing/neck/moonshackle_collar/proc/start_reversion(mob/living/carbon/human/beast)
	stop_reversion()
	reverting_beast_ref = WEAKREF(beast)
	reversion_end_time = world.time + reversion_time
	beast.visible_message(
		span_danger("The moonshackle collar snaps shut around [beast]'s throat, and the silver begins to burn!"),
		span_userdanger("The silver bites into my throat. It is forcing the beast back under my skin!"),
	)
	announce_reversion_countdown(beast, reversion_time)
	schedule_reversion_step()

/// Clears a running reversion. Returns TRUE if one was running.
/obj/item/clothing/neck/moonshackle_collar/proc/stop_reversion()
	if(reversion_timer)
		deltimer(reversion_timer)
		reversion_timer = null
	if(!reverting_beast_ref)
		return FALSE
	reverting_beast_ref = null
	reversion_end_time = 0
	return TRUE

/// Times the next step to land on the 15 and 5 second countdown marks, then on the end.
/obj/item/clothing/neck/moonshackle_collar/proc/schedule_reversion_step()
	var/time_left = max(reversion_end_time - world.time, 0)
	var/next_mark = 0
	for(var/countdown_mark in list(15 SECONDS, 5 SECONDS))
		if(countdown_mark < time_left)
			next_mark = countdown_mark
			break
	reversion_timer = addtimer(CALLBACK(src, PROC_REF(reversion_step)), time_left - next_mark, TIMER_STOPPABLE)

/obj/item/clothing/neck/moonshackle_collar/proc/announce_reversion_countdown(mob/living/beast, time_left)
	to_chat(beast, span_warning("The beast tears at the collar. [DisplayTimeText(CEILING(time_left, 1 SECONDS), 1)] until it is forced back under my skin."))

/obj/item/clothing/neck/moonshackle_collar/proc/reversion_step()
	reversion_timer = null
	var/mob/living/carbon/human/beast = reverting_beast_ref?.resolve()
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(beast)
	if(!wolf?.transformed || wolf.owner.current != beast || beast.wear_neck != src)
		stop_reversion()
		return
	var/time_left = reversion_end_time - world.time
	if(time_left > 0)
		announce_reversion_countdown(beast, time_left)
		schedule_reversion_step()
		return
	finish_reversion(beast, wolf)

/obj/item/clothing/neck/moonshackle_collar/proc/finish_reversion(mob/living/carbon/human/beast, datum/antagonist/werewolf/wolf)
	stop_reversion()
	beast.visible_message(
		span_danger("The moonshackle collar flares white! [beast] convulses and shrinks back into mortal flesh!"),
		span_userdanger("The silver wins. The beast is dragged back beneath my skin!"),
	)
	finishing_reversion = TRUE
	wolf.remove_werewolf(TRUE)
	finishing_reversion = FALSE
	// The beast body sheds the collar; clamp it back onto the human throat.
	var/mob/living/carbon/human/human_body = wolf.owner?.current
	if(QDELETED(src) || !istype(human_body) || wolf.transformed || loc == human_body)
		return
	if(human_body.wear_neck)
		human_body.dropItemToGround(human_body.wear_neck)
	human_body.equip_to_slot_if_possible(src, ITEM_SLOT_NECK, disable_warning = TRUE, bypass_equip_delay_self = TRUE)

/obj/item/clothing/neck/moonshackle_collar/proc/on_wearer_examine(mob/living/source, mob/user, list/examine_sections, list/pronouns)
	SIGNAL_HANDLER
	if(!islist(pronouns))
		return
	var/datum/antagonist/werewolf/wolf = IS_WEREWOLF(source)
	if(!wolf)
		return
	if(wolf.transformed)
		LAZYADDASSOCLIST(examine_sections, EXAMINE_SECT_WARNING, span_warning("Leashed: a moonshackle collar burns at [pronouns[THEIR]] throat, forcing the beast back into mortal flesh."))
		return
	LAZYADDASSOCLIST(examine_sections, EXAMINE_SECT_WARNING, span_warning("Leashed: a moonshackle collar binds the beast within [pronouns[THEM]]."))

/datum/anvil_recipe/valuables/silver/moonshackle_collar
	name = "Moonshackle collar"
	recipe_name = "a moonshackle collar"
	additional_items = list(
		/obj/item/ingot/silver,
		/obj/item/gem/diamond,
		/obj/item/gem/red,
		/obj/item/gem/blue,
	)
	created_item = /obj/item/clothing/neck/moonshackle_collar
	craftdiff = SKILL_RANK_LEGENDARY

/datum/anvil_recipe/valuables/silver/moonshackle_collar/advance(mob/user, breakthrough = FALSE, quality_score = 0)
	if(GET_MOB_SKILL_VALUE_OLD(user, appro_skill) < SKILL_RANK_LEGENDARY)
		to_chat(user, span_warning("This silverwork is beyond me. Only a legendary smith could finish it."))
		return FALSE

	return ..()
