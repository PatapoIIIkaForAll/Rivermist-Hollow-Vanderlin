// Brass oil-can fluid pumps: fitted over breasts, a cock or a pussy, they fill a glass reservoir and block the organ.

/// Units the glass reservoir holds.
#define FLUID_PUMP_VOLUME 60
/// Time between the wearer's pump reminders, picked at random between these.
#define FLUID_PUMP_MESSAGE_MIN (40 SECONDS)
#define FLUID_PUMP_MESSAGE_MAX (80 SECONDS)
/// Reservoir shares drawn as the half and full gauge states.
#define FLUID_PUMP_HALF_RATIO 0.4
#define FLUID_PUMP_FULL_RATIO 0.9

/obj/item/reagent_containers/glass/fluid_pump
	abstract_type = /obj/item/reagent_containers/glass/fluid_pump
	name = "fluid pump"
	icon = 'modular_rmh/icons/obj/lewd/fluid_pumps.dmi'
	w_class = WEIGHT_CLASS_SMALL
	volume = FLUID_PUMP_VOLUME
	spillable = TRUE
	reagent_flags = TRANSPARENT
	possible_transfer_amounts = list(5, 10, 20, 30, 60)
	sellprice = 20
	has_body_storage_overlay = TRUE
	bstorage_visible_layer = STORAGE_LAYER_OUTER
	storage_overlay_icon = 'modular_rmh/icons/obj/lewd/fluid_pumps_overlay.dmi'
	body_storage_random_removal = FALSE
	body_storage_blocks_insertions = TRUE
	body_storage_additional_blocked_layers = list(STORAGE_LAYER_INNER, STORAGE_LAYER_DEEP)
	/// Organ slot the pump fits over.
	var/pump_slot
	/// Body zone that must be reachable to fit or remove it.
	var/pump_zone = BODY_ZONE_PRECISE_GROIN
	/// How the organ is named in messages.
	var/organ_word
	/// Units drawn from the source organ per second; zero only catches what comes out.
	var/draw_rate = 0
	/// Arousal added per second of pumping.
	var/arousal_per_second = 0.5
	/// Orgasm progress added per second of pumping.
	var/orgasm_per_second = 0
	/// Reminders shown to the wearer now and then.
	var/list/pump_messages
	/// The organ the pump sits over, while fitted.
	var/obj/item/organ/genitals/attached_organ
	/// TRUE once the wearer was told the reservoir is full.
	var/closed = TRUE
	/// Do not change desc when opened or closed
	var/fancy = FALSE
	/// Name to slap on a label, replaces current name
	var/announced_full = FALSE
	COOLDOWN_DECLARE(next_message)

/obj/item/reagent_containers/glass/fluid_pump/Destroy()
	STOP_PROCESSING(SSobj, src)
	attached_organ = null
	return ..()

/obj/item/reagent_containers/glass/fluid_pump/blocks_organ_use(slot)
	return TRUE

/// Pumps only fit over an opening, never inside it.
/obj/item/reagent_containers/glass/fluid_pump/can_enter_body_storage_layer(target_layer)
	return target_layer == STORAGE_LAYER_OUTER

/obj/item/reagent_containers/glass/fluid_pump/can_random_body_storage_layer_swap()
	return FALSE

/obj/item/reagent_containers/glass/fluid_pump/on_body_storage_entered(obj/item/organ/storage_organ, target_layer)
	. = ..()
	if(target_layer != STORAGE_LAYER_OUTER || storage_organ.slot != pump_slot)
		return
	attached_organ = storage_organ
	announced_full = FALSE
	COOLDOWN_START(src, next_message, rand(FLUID_PUMP_MESSAGE_MIN, FLUID_PUMP_MESSAGE_MAX))
	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/glass/fluid_pump/on_body_storage_exited(obj/item/organ/storage_organ)
	. = ..()
	attached_organ = null
	STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/glass/fluid_pump/proc/get_wearer()
	return attached_organ?.owner

/// The filling organ this pump draws from and catches the climax of.
/obj/item/reagent_containers/glass/fluid_pump/proc/get_source_organ()
	return attached_organ

/// Fits the pump over the wearer's matching organ; returns an INSERT_FEEDBACK_* result, or FALSE without one.
/obj/item/reagent_containers/glass/fluid_pump/proc/attach_to(mob/living/wearer)
	var/obj/item/organ/organ = wearer?.getorganslot(pump_slot)
	if(!organ)
		return FALSE
	return SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_INSERT, src, STORAGE_LAYER_OUTER, FALSE)

/// Takes the pump off into the receiver's hands, or drops it by the wearer; returns TRUE on success.
/obj/item/reagent_containers/glass/fluid_pump/proc/detach(mob/living/receiver)
	var/obj/item/organ/organ = attached_organ
	if(!organ || !SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_REMOVE, src, STORAGE_LAYER_OUTER, BODYSTORAGE_REMOVE_MANUAL))
		return FALSE
	if(!receiver?.put_in_hands(src))
		forceMove(receiver?.drop_location() || get_turf(src))
	return TRUE

/obj/item/reagent_containers/glass/fluid_pump/process(seconds_per_tick)
	var/mob/living/wearer = get_wearer()
	if(!wearer)
		return PROCESS_KILL
	if(wearer.stat == DEAD)
		return
	if(reagents.holder_full())
		if(!announced_full)
			announced_full = TRUE
			to_chat(wearer, span_notice("\The [src] is full and stops pumping."))
		return
	announced_full = FALSE
	var/obj/item/organ/source_organ = get_source_organ()
	var/datum/reagents/source = source_organ?.reagents
	if(draw_rate && source?.total_volume)
		source.trans_to(src, min(draw_rate * seconds_per_tick, reagents.maximum_volume - reagents.total_volume), transfered_by = wearer)
	SEND_SIGNAL(wearer, COMSIG_SEX_GENERIC_ACTION, wearer, arousal_per_second * seconds_per_tick, 0, orgasm_per_second * seconds_per_tick, src)
	if(length(pump_messages) && COOLDOWN_FINISHED(src, next_message))
		COOLDOWN_START(src, next_message, rand(FLUID_PUMP_MESSAGE_MIN, FLUID_PUMP_MESSAGE_MAX))
		to_chat(wearer, span_love(pick(pump_messages)))

/obj/item/reagent_containers/glass/fluid_pump/update_overlays()
	. = ..()
	if(!reagents?.total_volume)
		return
	var/level = 1
	if(reagents.total_volume >= volume * FLUID_PUMP_FULL_RATIO)
		level = 3
	else if(reagents.total_volume >= volume * FLUID_PUMP_HALF_RATIO)
		level = 2
	var/mutable_appearance/fill = mutable_appearance(icon, "pump_fill[level]")
	fill.color = mix_color_from_reagents(reagents.reagent_list)
	. += fill

/obj/item/reagent_containers/glass/fluid_pump/examine(mob/user)
	. = ..()
	. += span_notice("It fits over a [organ_word == "breasts" ? "pair of breasts" : organ_word] and covers it completely while fitted.")

/obj/item/reagent_containers/glass/fluid_pump/get_sex_action_effects(datum/sex_action_effect_context/context)
	if(!get_wearer())
		return null
	return list(new /datum/sex_action_effect/fluid_pump(src))

/// Takes the wearer's own climax from its source organ into the reservoir; returns the units caught.
/obj/item/reagent_containers/glass/fluid_pump/proc/catch_climax(datum/sex_action_effect_context/context, datum/reagents/source_reagents, amount)
	var/mob/living/wearer = get_wearer()
	var/obj/item/organ/source_organ = get_source_organ()
	if(!wearer || context?.climaxer != wearer || source_reagents != source_organ?.reagents)
		return 0
	var/room = reagents.maximum_volume - reagents.total_volume
	if(room <= 0 || amount <= 0)
		return 0
	. = source_reagents.trans_to(src, min(amount, room), transfered_by = wearer) || 0
	if(. && !context?.climax_follow_up)
		to_chat(wearer, span_love("\The [src] drinks down my release."))

/datum/sex_action_effect/fluid_pump

/datum/sex_action_effect/fluid_pump/intercept_climax(datum/sex_action_effect_context/context, datum/reagents/source_reagents, amount)
	var/obj/item/reagent_containers/glass/fluid_pump/pump = source_item
	return pump?.catch_climax(context, source_reagents, amount) || 0

/obj/item/reagent_containers/glass/fluid_pump/attack_self_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	toggle_cork(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/reagent_containers/glass/fluid_pump/proc/toggle_cork(mob/user, modify_nextmove = TRUE)
	closed = !closed
	if(modify_nextmove)
		user.changeNext_move(CLICK_CD_RAPID)
	if(closed)
		reagent_flags &= ~TRANSFERABLE
		reagents.flags = reagent_flags
		balloon_alert(user, "i close the lid.")
		spillable = FALSE
		GLOB.weather_act_upon_list -= src
		if(!fancy)
			desc = "A pump with closed lid."
	else
		reagent_flags |= TRANSFERABLE
		reagents.flags = reagent_flags
		playsound(user,'sound/items/uncork.ogg', 100, TRUE)
		balloon_alert(user, "i open the lid.")
		spillable = TRUE
		GLOB.weather_act_upon_list |= src
		if(!fancy)
			desc = "An open pump,the lid is kept open."
	update_appearance(UPDATE_OVERLAYS)

/obj/item/reagent_containers/glass/fluid_pump/breast
	name = "brass breast pump"
	desc = "A squat brass oil can with a glass reservoir and a glass breast shield on its spout. It draws milk steadily."
	icon_state = "breast_pump"
	pump_slot = ORGAN_SLOT_BREASTS
	pump_zone = BODY_ZONE_CHEST
	organ_word = "breasts"
	draw_rate = 1
	pump_messages = list(
		"The pump tugs rhythmically at my nipples.",
		"Warm milk spurts into the pump's glass.",
		"The glass cups pull at my breasts in a steady rhythm.",
	)

/obj/item/reagent_containers/glass/fluid_pump/cock
	name = "brass milker"
	desc = "A squat brass oil can with a glass reservoir and a long glass sleeve on its spout. It milks a cock by itself."
	icon_state = "cock_milker"
	pump_slot = ORGAN_SLOT_PENIS
	organ_word = "cock"
	arousal_per_second = 1
	orgasm_per_second = 0.5
	pump_messages = list(
		"The glass sleeve pulls and squeezes my cock.",
		"The milker sucks at me in a steady, patient rhythm.",
		"The brass pump wheezes, and the sleeve tightens around me.",
	)

/// The milker sits on the penis but draws the seed the testicles hold.
/obj/item/reagent_containers/glass/fluid_pump/cock/get_source_organ()
	var/mob/living/wearer = get_wearer()
	return wearer?.getorganslot(ORGAN_SLOT_TESTICLES)

/obj/item/reagent_containers/glass/fluid_pump/vagina
	name = "brass nectar pump"
	desc = "A squat brass oil can with a glass reservoir and a glass suction cup on its spout. It draws out whatever the pussy holds."
	icon_state = "vaginal_pump"
	pump_slot = ORGAN_SLOT_VAGINA
	organ_word = "pussy"
	draw_rate = 0.5
	arousal_per_second = 1
	orgasm_per_second = 0.5
	pump_messages = list(
		"The suction cup pulls hard at my pussy.",
		"The pump sucks rhythmically at my folds.",
		"The brass pump wheezes, and the cup tugs at me again.",
	)

// Use a bronze ingot on a bottle.
/datum/repeatable_crafting_recipe/crafting/fluid_pump
	abstract_type = /datum/repeatable_crafting_recipe/crafting/fluid_pump
	requirements = list(/obj/item/ingot/bronze = 1, /obj/item/reagent_containers/glass/bottle = 1, /obj/item/natural/hide/cured = 1)
	starting_atom = /obj/item/ingot/bronze
	attacked_atom = /obj/item/reagent_containers/glass/bottle
	allow_inverse_start = FALSE
	category = "Lewd"

/datum/repeatable_crafting_recipe/crafting/fluid_pump/breast_pump
	name = "brass breast pump"
	output = /obj/item/reagent_containers/glass/fluid_pump/breast

/datum/repeatable_crafting_recipe/crafting/fluid_pump/cock_milker
	name = "brass milker"
	output = /obj/item/reagent_containers/glass/fluid_pump/cock

/datum/repeatable_crafting_recipe/crafting/fluid_pump/nectar_pump
	name = "brass nectar pump"
	output = /obj/item/reagent_containers/glass/fluid_pump/vagina

#undef FLUID_PUMP_VOLUME
#undef FLUID_PUMP_MESSAGE_MIN
#undef FLUID_PUMP_MESSAGE_MAX
#undef FLUID_PUMP_HALF_RATIO
#undef FLUID_PUMP_FULL_RATIO
