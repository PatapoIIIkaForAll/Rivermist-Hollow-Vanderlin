/// Units milked per cycle before the size rate (GLOB.breast_milking_rate) and force.
#define BREAST_MILKING_BASE_AMOUNT 3
/// Units sprayed per cycle by "Spray milk".
#define BREAST_SPRAY_ACTION_AMOUNT 3
/// Arousal for onlookers per cycle: bounce times (size - 4), and squeeze together.
#define BREAST_SHOW_BOUNCE_AROUSAL 0.5
#define BREAST_SHOW_SQUEEZE_AROUSAL 0.4

/// Visible breast size of owner, 0 without breasts.
/proc/get_breast_visible_size(mob/living/owner)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = owner?.getorganslot(ORGAN_SLOT_BREASTS)
	return breasts ? breasts.get_visible_size() : 0

/// Arousal multiplier for touching owner's breasts: big ones take more effort.
/proc/get_breast_touch_multiplier(mob/living/owner)
	return LAZYACCESS(GLOB.breast_touch_sensitivity, "[get_breast_visible_size(owner)]") || 1

/// Arousal multiplier for a boob job given with owner's breasts.
/proc/get_breast_paizuri_multiplier(mob/living/owner)
	return LAZYACCESS(GLOB.breast_paizuri_bonus, "[get_breast_visible_size(owner)]") || 1

/// Units of the breasts' own milk, 0 when they hold none.
/proc/get_breast_milk(mob/living/owner)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = owner?.getorganslot(ORGAN_SLOT_BREASTS)
	return breasts?.reagents ? breasts.get_own_fluid_amount() : 0

/// Watchers of a breast show who opted in get a little arousal.
/datum/sex_action/proc/arouse_breast_show_viewers(mob/living/shower, amount, show_kind)
	for(var/mob/living/viewer in viewers(7, shower))
		if(viewer == shower || viewer.stat != CONSCIOUS || viewer.is_blind())
			continue
		// Facing each other: neither with the back turned.
		if(is_back_turned_to(viewer, shower) || is_back_turned_to(shower, viewer))
			continue
		viewer.saw_breast_show(shower, show_kind)
		if(!viewer.client || !viewer.get_cached_erp_pref(/datum/erp_preference/boolean/aroused_by_breast_shows))
			continue
		SEND_SIGNAL(viewer, COMSIG_SEX_ADJUST_AROUSAL, amount * viewer.get_breast_show_arousal_multiplier())

/// Called on everyone who sees a breast show; the Breast Enthusiast vice reacts to it.
/mob/living/proc/saw_breast_show(mob/living/shower, show_kind)
	return

/// Arousal multiplier for watching a breast show (Breast Enthusiast: more).
/mob/living/proc/get_breast_show_arousal_multiplier()
	return 1

/datum/erp_preference/boolean/aroused_by_breast_shows
	name = "Aroused By Breast Shows"
	description = "If watching someone bounce or squeeze their breasts for an audience arouses you a little"
	default_value = TRUE
	category = "General"

// With a partner.

/datum/sex_action/masturbate/other/squeeze_breasts
	name = "Breast squeezing"
	remote_phrase = "Squeeze their breasts"
	description = "Knead their breasts with both hands. Bigger ones take more effort to work up."
	target_menu_zone_mask = SEX_UI_ZONE_BODY

/datum/sex_action/masturbate/other/squeeze_breasts/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && get_breast_visible_size(target) >= 3

/datum/sex_action/masturbate/other/squeeze_breasts/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target || get_breast_visible_size(target) < 3)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/masturbate/other/squeeze_breasts/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] cups [target]'s breasts in both hands..."))

/datum/sex_action/masturbate/other/squeeze_breasts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/pain = 0
	switch(force)
		if(SEX_FORCE_HIGH)
			pain = 1
		if(SEX_FORCE_EXTREME, SEX_FORCE_UNRELENTING)
			pain = 2.5
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user, target)))
	playsound(target, 'sound/misc/mat/fingering.ogg', 20, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 1.2 * get_breast_touch_multiplier(target), pain, 0.1)
	handle_passive_ejaculation(target)

/datum/sex_action/masturbate/other/squeeze_breasts/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets go of [target]'s breasts."))

/datum/sex_action/bury_face
	name = "Bury face"
	description = "Press your face between their breasts. Big enough ones swallow it whole."
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	gags_user = TRUE

/datum/sex_action/bury_face/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && get_breast_visible_size(target) >= 4

/datum/sex_action/bury_face/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target || get_breast_visible_size(target) < 4)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!check_location_accessible(target, user, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH) || check_sex_lock(target, ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/bury_face/on_start(mob/living/user, mob/living/target)
	. = ..()
	if(get_breast_visible_size(target) >= 6)
		user.visible_message(span_warning("[user] buries [user.p_their()] face in [target]'s cleavage, and it disappears entirely!"))
	else
		user.visible_message(span_warning("[user] buries [user.p_their()] face between [target]'s breasts..."))

/datum/sex_action/bury_face/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user, target)))
	playsound(target, 'sound/misc/mat/fingering.ogg', 15, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 0.6 * get_breast_touch_multiplier(target), 0, 0.05)
	perform_sex_action(user, target, 0.6, 0, 0.05)
	handle_passive_ejaculation(target)

/datum/sex_action/bury_face/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] comes up for air from [target]'s cleavage."))

/datum/sex_action/bury_face/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)
	add_sex_lock(target, ORGAN_SLOT_BREASTS, null, FALSE)

/datum/sex_action/cleavage_smother
	name = "Smother them"
	description = "Hold their face between your breasts. They cannot speak; pressed hard, they struggle for air."
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	target_menu_zone_mask = SEX_UI_ZONE_MOUTH
	gags_target = TRUE

/datum/sex_action/cleavage_smother/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && get_breast_visible_size(user) >= 5

/datum/sex_action/cleavage_smother/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target || get_breast_visible_size(user) < 5)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_MOUTH))
		return FALSE
	if(check_sex_lock(target, BODY_ZONE_PRECISE_MOUTH) || check_sex_lock(user, ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/cleavage_smother/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pulls [target]'s face into [user.p_their()] cleavage!"))

/datum/sex_action/cleavage_smother/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user, target)))
		if(prob(20))
			user.visible_message(span_love("[target]'s muffled sounds vibrate against [user]'s chest."))
	playsound(user, 'sound/misc/mat/fingering.ogg', 15, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(user, target, 0.6 * get_breast_touch_multiplier(user), 0, 0.05)
	perform_sex_action(target, user, 0.6, 0, 0.05)
	// Air loss only at high force, capped, with gagging and gasping.
	perform_deepthroat_oxyloss(target, 1.3)
	handle_passive_ejaculation()

/datum/sex_action/cleavage_smother/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] releases [target]'s face from [user.p_their()] cleavage."))
	if(target.getOxyLoss() >= 10)
		target.emote("gasp", forced = TRUE)

/datum/sex_action/cleavage_smother/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(target, BODY_ZONE_PRECISE_MOUTH)
	add_sex_lock(user, ORGAN_SLOT_BREASTS, null, FALSE)

/datum/sex_action/breast_press
	name = "Press breasts"
	description = "Rub your chest against theirs, breast to breast."
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	target_menu_zone_mask = SEX_UI_ZONE_BODY

/datum/sex_action/breast_press/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && get_breast_visible_size(user) >= 3 && get_breast_visible_size(target) >= 3

/datum/sex_action/breast_press/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target || get_breast_visible_size(user) < 3 || get_breast_visible_size(target) < 3)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE) || !check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(check_sex_lock(user, ORGAN_SLOT_BREASTS) || check_sex_lock(target, ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/breast_press/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] presses [user.p_their()] breasts against [target]'s..."))

/datum/sex_action/breast_press/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user, target)))
	playsound(user, 'sound/misc/mat/fingering.ogg', 20, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(user, target, 0.8 * get_breast_touch_multiplier(user), 0, 0.1)
	perform_sex_action(target, user, 0.8 * get_breast_touch_multiplier(target), 0, 0.1)
	handle_passive_ejaculation()
	handle_passive_ejaculation(target)

/datum/sex_action/breast_press/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] pulls [user.p_their()] chest away from [target]'s."))

/datum/sex_action/breast_press/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, ORGAN_SLOT_BREASTS, null, FALSE)
	add_sex_lock(target, ORGAN_SLOT_BREASTS, null, FALSE)

/datum/sex_action/sex/other/boobjob/hands_free
	name = "Hands-free boobjob"

/datum/sex_action/sex/other/boobjob/hands_free/shows_on_menu(mob/living/user, mob/living/target)
	return ..() && get_breast_visible_size(user) >= 6

/datum/sex_action/sex/other/boobjob/hands_free/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || get_breast_visible_size(user) < 6)
		return FALSE
	return TRUE

/datum/sex_action/sex/other/boobjob/hands_free/get_start_message(mob/living/user, mob/living/target)
	return "[user] traps [target]'s cock in [user.p_their()] cleavage without lifting a hand!"

/datum/sex_action/sex/other/boobjob/hands_free/get_finish_message(mob/living/user, mob/living/target)
	return "[user] lets [target]'s cock slip free of [user.p_their()] cleavage."

// Skips the parent, which prints the hand-held line; same sound and stimulation.
/datum/sex_action/sex/other/boobjob/hands_free/on_perform(mob/living/user, mob/living/target)
	sex_volume = initial(sex_volume)
	if(user.rogue_sneaking || user.m_intent == MOVE_INTENT_SNEAK || user.alpha <= 100)
		sex_volume *= 0.5
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user, target)))
	playsound(target, 'sound/misc/mat/fingering.ogg', 20, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 2 * get_breast_paizuri_multiplier(user), 4, 2)

/datum/sex_action/milk_breasts
	abstract_type = /datum/sex_action/milk_breasts
	user_menu_zone_mask = SEX_UI_ZONE_ARMS
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	requires_free_hands = TRUE

/datum/sex_action/milk_breasts/proc/get_container(mob/living/user)
	var/obj/item/reagent_containers/container = user.get_active_held_item()
	if(!istype(container) || !container.is_open_container() || !container.reagents || container.reagents.holder_full())
		container = user.get_inactive_held_item()
	if(!istype(container) || !container.is_open_container() || !container.reagents || container.reagents.holder_full())
		return null
	return container

/datum/sex_action/milk_breasts/proc/cycle_message(mob/living/user, mob/living/target, obj/item/container)
	return null

/datum/sex_action/milk_breasts/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || get_breast_milk(target) <= 0)
		return FALSE
	if(!get_container(user))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(check_sex_lock(target, ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/milk_breasts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/reagent_containers/container = get_container(user)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = target.getorganslot(ORGAN_SLOT_BREASTS)
	if(!container || !breasts?.reagents?.total_volume)
		return
	var/rate = LAZYACCESS(GLOB.breast_milking_rate, "[breasts.get_visible_size()]") || 1
	var/amount = min(BREAST_MILKING_BASE_AMOUNT * rate * (force >= SEX_FORCE_HIGH ? 1.5 : 1), breasts.get_own_fluid_amount())
	breasts.reagents.trans_to(container, amount, transfered_by = user, show_message = FALSE)
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user, target, container)))
	playsound(target, pick('sound/vo/mobs/cow/milking (1).ogg', 'sound/vo/mobs/cow/milking (2).ogg'), 25, TRUE, -2, ignore_walls = FALSE)
	perform_sex_action(target, user, 0.6 * get_breast_touch_multiplier(target), force >= SEX_FORCE_HIGH ? 1 : 0, 0.05)
	handle_passive_ejaculation(target)

/datum/sex_action/milk_breasts/other
	name = "Milk them"
	description = "Milk their breasts into the open container in your hand. Big full ones give more."

/datum/sex_action/milk_breasts/other/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && get_breast_milk(target) > 0

/datum/sex_action/milk_breasts/other/can_perform(mob/living/user, mob/living/target)
	. = ..()
	return . && user != target

/datum/sex_action/milk_breasts/other/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] holds \the [get_container(user)] under [target]'s breasts and takes hold of [target.p_their()] nipples..."))

/datum/sex_action/milk_breasts/other/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops milking [target]."))

/datum/sex_action/milk_breasts/self
	name = "Milk myself"
	description = "Milk your own breasts into the open container in your hand until they run dry."

/datum/sex_action/milk_breasts/self/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && get_breast_milk(user) > 0

/datum/sex_action/milk_breasts/self/can_perform(mob/living/user, mob/living/target)
	. = ..()
	return . && user == target

/datum/sex_action/milk_breasts/self/can_continue(mob/living/user, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	return !!get_container(user)

/datum/sex_action/milk_breasts/self/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] holds \the [get_container(user)] under [user.p_their()] breasts and takes hold of [user.p_their()] nipples..."))

/datum/sex_action/milk_breasts/self/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(get_breast_milk(user) <= 0)
		to_chat(user, span_notice("My breasts are milked dry."))
		stop_runtime()

/datum/sex_action/milk_breasts/self/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] stops milking [user.p_their()] breasts."))

/datum/sex_action/spray_milk
	name = "Spray milk"
	description = "Squeeze a stream of milk from your full breasts over them."
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	target_menu_zone_mask = SEX_UI_ZONE_ANY
	do_time = 2.5 SECONDS

/datum/sex_action/spray_milk/proc/can_spray(mob/living/user)
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = user.getorganslot(ORGAN_SLOT_BREASTS)
	return breasts && breasts.get_visible_size() >= 6 && breasts.is_full_of_milk()

/datum/sex_action/spray_milk/shows_on_menu(mob/living/user, mob/living/target)
	return user != target && can_spray(user)

/datum/sex_action/spray_milk/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user == target || !can_spray(user))
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/spray_milk/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] takes aim at [target] with [user.p_their()] swollen breasts..."))

/datum/sex_action/spray_milk/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets go of [user.p_their()] breasts, milk still dripping from [user.p_their()] nipples."))

/datum/sex_action/spray_milk/on_perform(mob/living/user, mob/living/target)
	. = ..()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = user.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts?.reagents?.total_volume)
		return
	var/aim = user.zone_selected == BODY_ZONE_HEAD || user.zone_selected == BODY_ZONE_PRECISE_MOUTH ? "face" : "body"
	user.visible_message(spanify_force(cycle_message(user, target, aim)))
	playsound(user, 'sound/effects/splash.ogg', 20, TRUE, -4, ignore_walls = FALSE)
	breasts.reagents.trans_to(target, min(BREAST_SPRAY_ACTION_AMOUNT, breasts.reagents.total_volume), transfered_by = user, method = TOUCH, show_message = FALSE)
	perform_sex_action(user, target, 0.5, 0, 0.1)

// With your own breasts.

/datum/sex_action/masturbate/heft_breasts
	name = "Heft breasts"
	description = "Lift your breasts and let them fall with a bounce."
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	do_time = 2.5 SECONDS

/datum/sex_action/masturbate/heft_breasts/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && get_breast_visible_size(user) >= 5

/datum/sex_action/masturbate/heft_breasts/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || get_breast_visible_size(user) < 5)
		return FALSE
	return check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE)

/datum/sex_action/masturbate/heft_breasts/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] cups [user.p_their()] breasts from below..."))

/datum/sex_action/masturbate/heft_breasts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user)))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), user, pick(SEX_SOUNDS_SLOW), 12, TRUE, -4), 0.4 SECONDS)
	perform_sex_action(user, user, 0.4 * get_breast_touch_multiplier(user), 0, 0.05)
	arouse_breast_show_viewers(user, 0.2, "heft")

/datum/sex_action/masturbate/heft_breasts/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets [user.p_their()] breasts rest."))

/datum/sex_action/suck_own_nipple
	name = "Suckle breast"
	description = "Lift a breast to your mouth. Only big, bare breasts reach."
	user_menu_zone_mask = SEX_UI_ZONE_MOUTH
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	/// Suckling shot looped while sucking, picked when it starts: one breast raised.
	var/loop_shot

/datum/sex_action/suck_own_nipple/proc/chest_bare(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.bra)
			return FALSE
	return check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE)

/datum/sex_action/suck_own_nipple/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && get_breast_visible_size(user) >= 5

/datum/sex_action/suck_own_nipple/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || get_breast_visible_size(user) < 5 || !chest_bare(user))
		return FALSE
	if(check_sex_lock(user, BODY_ZONE_PRECISE_MOUTH) || check_sex_lock(user, ORGAN_SLOT_BREASTS))
		return FALSE
	return TRUE

/datum/sex_action/suck_own_nipple/on_start(mob/living/user, mob/living/target)
	. = ..()
	loop_shot = pick("suckle_a", "suckle_b")
	user.visible_message(span_warning("[user] lifts one of [user.p_their()] breasts to [user.p_their()] mouth..."))

/datum/sex_action/suck_own_nipple/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		var/obj/item/organ/genitals/filling_organ/breasts/milky = user.getorganslot(ORGAN_SLOT_BREASTS)
		var/text = cycle_message(user)
		if(milky?.get_own_fluid_amount() > 0 && prob(40))
			text = insert_before_end_punctuation(text, ", milk trickling over [user.p_their()] lips")
		user.visible_message(spanify_force(text))
	user.make_sucking_noise()
	perform_sex_action(user, user, 1 * get_breast_touch_multiplier(user), 0, 0.1)
	handle_passive_ejaculation()
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = user.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts?.reagents?.total_volume || !user.reagents || user.reagents.holder_full())
		return
	var/amount = min(max(breasts.organ_size, 1), breasts.reagents.total_volume, user.reagents.maximum_volume - user.reagents.total_volume)
	breasts.reagents.trans_to(user, amount, transfered_by = user, method = INGEST, show_message = FALSE)
	if(prob(35))
		to_chat(user, span_notice("I can taste my own milk."))

/datum/sex_action/suck_own_nipple/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets [user.p_their()] breast drop from [user.p_their()] mouth."))

/datum/sex_action/suck_own_nipple/lock_sex_object(mob/living/user, mob/living/target)
	add_sex_lock(user, BODY_ZONE_PRECISE_MOUTH)

/datum/sex_action/suck_own_nipple/get_breast_loop_shot()
	return loop_shot

/datum/sex_action/bounce_breasts
	name = "Bounce breasts"
	description = "Make your breasts bounce for everyone watching. Onlookers get a little worked up."
	user_menu_zone_mask = SEX_UI_ZONE_BODY
	target_menu_zone_mask = SEX_UI_ZONE_BODY
	do_time = 2 SECONDS

/datum/sex_action/bounce_breasts/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && get_breast_visible_size(user) >= 5

/datum/sex_action/bounce_breasts/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || get_breast_visible_size(user) < 5)
		return FALSE
	return TRUE

/datum/sex_action/bounce_breasts/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] puffs out [user.p_their()] chest..."))

/datum/sex_action/bounce_breasts/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user)))
	playsound(user, pick(SEX_SOUNDS_SLOW), 12, TRUE, -4, ignore_walls = FALSE)
	perform_sex_action(user, user, 0.2, 0, 0)
	var/size = get_breast_visible_size(user)
	arouse_breast_show_viewers(user, BREAST_SHOW_BOUNCE_AROUSAL * (size - 4), "bounce")

/datum/sex_action/bounce_breasts/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets [user.p_their()] breasts settle."))

/datum/sex_action/masturbate/squeeze_together
	name = "Squeeze breasts"
	description = "Press your breasts together with your hands. Onlookers get a little worked up."
	target_menu_zone_mask = SEX_UI_ZONE_BODY

/datum/sex_action/masturbate/squeeze_together/shows_on_menu(mob/living/user, mob/living/target)
	return user == target && get_breast_visible_size(user) >= 4

/datum/sex_action/masturbate/squeeze_together/can_perform(mob/living/user, mob/living/target)
	. = ..()
	if(!. || user != target || get_breast_visible_size(user) < 4)
		return FALSE
	return check_location_accessible(user, user, BODY_ZONE_CHEST, TRUE)

/datum/sex_action/masturbate/squeeze_together/on_start(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] cups [user.p_their()] breasts from the sides..."))

/datum/sex_action/masturbate/squeeze_together/on_perform(mob/living/user, mob/living/target)
	. = ..()
	if(can_show_action_message(user, target))
		user.visible_message(spanify_force(cycle_message(user)))
	playsound(user, 'sound/misc/mat/fingering.ogg', 20, TRUE, -2, ignore_walls = FALSE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), user, pick(SEX_SOUNDS_SLOW), 12, TRUE, -4), 0.35 SECONDS)
	perform_sex_action(user, user, 0.5 * get_breast_touch_multiplier(user), 0, 0.05)
	arouse_breast_show_viewers(user, BREAST_SHOW_SQUEEZE_AROUSAL, "squeeze")

/datum/sex_action/masturbate/squeeze_together/on_finish(mob/living/user, mob/living/target)
	. = ..()
	user.visible_message(span_warning("[user] lets go of [user.p_their()] breasts."))

// Per-cycle messages, by force.

/// Line for the current force: one of low/mid/high/extreme.
/datum/sex_action/proc/pick_by_force(list/low, list/mid, list/high, list/extreme)
	switch(force)
		if(SEX_FORCE_LOW)
			return pick(low)
		if(SEX_FORCE_MID)
			return pick(mid)
		if(SEX_FORCE_HIGH)
			return pick(high)
		else
			return pick(extreme)

/// "breasts", "heavy breasts" (6-7) or "enormous breasts" (8) for owner.
/proc/get_breast_size_noun(mob/living/owner)
	switch(get_breast_visible_size(owner))
		if(8 to INFINITY)
			return "enormous breasts"
		if(6 to 7)
			return "heavy breasts"
	return "breasts"

/datum/sex_action/masturbate/other/squeeze_breasts/proc/cycle_message(mob/living/user, mob/living/target)
	var/their = user.p_their()
	var/tits = get_breast_size_noun(target)
	return pick_by_force(
		list("[user] gently cups and kneads [target]'s [tits].", "[user] softly fondles [target]'s [tits], fingers sinking in.",
			"[user] tenderly traces slow circles over [target]'s [tits].", "[user] lifts [target]'s [tits] in [their] palms, weighing them gently."),
		list("[user] firmly kneads [target]'s [tits].", "[user] squeezes [target]'s [tits], rolling them in [their] hands.",
			"[user] eagerly massages [target]'s [tits].", "[user] gives [target]'s [tits] a long, firm squeeze."),
		list("[user] roughly gropes [target]'s [tits].", "[user] squeezes [target]'s [tits] hard, fingers digging in.",
			"[user] forcefully kneads [target]'s [tits], leaving red marks.", "[user] grabs [target]'s [tits] by the handful."),
		list("[user] mercilessly mauls [target]'s [tits].", "[user] crushes [target]'s [tits] in [their] fists.",
			"[user] brutally wrings [target]'s [tits].", "[user] squeezes [target]'s [tits] until they bulge between [their] fingers."))

/datum/sex_action/bury_face/proc/cycle_message(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return pick_by_force(
		list("[user] nuzzles softly into [target]'s cleavage.", "[user] rests [their] face between [target]'s breasts, breathing in.",
			"[user] tenderly nestles [their] cheek into [target]'s cleavage."),
		list("[user] presses [their] face deep into [target]'s cleavage.", "[user] rubs [their] face between [target]'s breasts.",
			"[user] eagerly nuzzles from one of [target]'s breasts to the other."),
		list("[user] shoves [their] face hard into [target]'s cleavage.", "[user] eagerly motorboats [target]'s breasts.",
			"[user] buries [their] face roughly between [target]'s breasts."),
		list("[user] buries [their] face so deep in [target]'s cleavage that only the back of [their] head shows.",
			"[user] thrashes [their] face wildly between [target]'s breasts.", "[user] motorboats [target]'s breasts with wild abandon."))

/datum/sex_action/cleavage_smother/proc/cycle_message(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return pick_by_force(
		list("[user] cradles [target]'s face against [their] breasts.", "[user] hugs [target]'s head softly to [their] chest.",
			"[user] gently rocks [target]'s face between [their] breasts."),
		list("[user] presses [target]'s face firmly into [their] cleavage.", "[user] squishes [target]'s face between [their] breasts.",
			"[user] holds [target]'s head snugly in [their] cleavage."),
		list("[user] smothers [target]'s face between [their] breasts.", "[user] crushes [target]'s face into [their] chest, leaving little room to breathe.",
			"[user] forcefully squeezes [their] breasts around [target]'s face."),
		list("[user] pins [target]'s head in [their] cleavage, smothering [target.p_them()] completely.", "[user] buries [target]'s face in [their] breasts and won't let go.",
			"[user] mercilessly smothers [target] in [their] breasts."))

/datum/sex_action/breast_press/proc/cycle_message(mob/living/user, mob/living/target)
	var/their = user.p_their()
	return pick_by_force(
		list("[user] softly brushes [their] breasts against [target]'s.", "[user] presses [their] chest lightly to [target]'s, nipples grazing.",
			"[user] gently sways, [their] breasts sliding over [target]'s."),
		list("[user] rubs [their] breasts against [target]'s.", "[user] grinds [their] chest against [target]'s, breasts squishing together.",
			"[user] eagerly presses [their] breasts to [target]'s."),
		list("[user] mashes [their] breasts against [target]'s.", "[user] presses hard against [target], breasts squeezed flat between them.",
			"[user] roughly grinds [their] breasts into [target]'s."),
		list("[user] grinds [their] breasts relentlessly against [target]'s.", "[user] slams [their] chest against [target]'s, breasts bouncing off each other.",
			"[user] crushes [their] breasts against [target]'s with savage force."))

/datum/sex_action/sex/other/boobjob/hands_free/proc/cycle_message(mob/living/user, mob/living/target)
	var/their = user.p_their()
	var/tits = get_breast_size_noun(user)
	return pick_by_force(
		list("[user] slowly slides [target]'s cock between [their] breasts, no hands needed.", "[target]'s cock rests snugly in [user]'s cleavage as [their] breasts gently sway.",
			"[user] lets [their] [tits] gently hug [target]'s cock."),
		list("[user] works [target]'s cock between [their] [tits].", "[user] bobs [their] chest, [target]'s cock buried in [their] cleavage.",
			"[user]'s breasts squeeze [target]'s cock with every bounce."),
		list("[user] bounces [their] breasts hard around [target]'s cock.", "[user] pumps [target]'s cock with [their] cleavage, breasts slapping together.",
			"[user] roughly jiggles [target]'s cock between [their] breasts."),
		list("[user] pounds [target]'s cock with [their] [tits].", "[user]'s breasts swallow [target]'s cock completely with every bounce.",
			"[user] relentlessly smothers [target]'s cock in [their] cleavage."))

/datum/sex_action/milk_breasts/other/cycle_message(mob/living/user, mob/living/target, obj/item/container)
	return pick_by_force(
		list("[user] gently squeezes milk from [target]'s nipples into \the [container].", "[user] coaxes a thin stream of milk from [target] into \the [container].",
			"[user] tenderly milks [target], drop by drop, into \the [container]."),
		list("[user] milks [target]'s breasts into \the [container] in a steady rhythm.", "[user] squeezes [target]'s nipples, milk splashing into \the [container].",
			"[user] firmly milks [target] into \the [container]."),
		list("[user] milks [target] hard, milk spraying into \the [container].", "[user] tugs at [target]'s nipples, milk streaming into \the [container].",
			"[user] roughly squeezes [target]'s breasts, filling \the [container]."),
		list("[user] wrings [target]'s breasts like udders, milk gushing into \the [container].", "[user] milks [target] mercilessly, squeezing out every drop.",
			"[user] brutally milks [target], milk spraying into \the [container] and everywhere else."))

/datum/sex_action/milk_breasts/self/cycle_message(mob/living/user, mob/living/target, obj/item/container)
	var/their = user.p_their()
	return pick_by_force(
		list("[user] gently squeezes milk from [their] nipples into \the [container].", "[user] coaxes a thin stream of milk from [their] breasts into \the [container].",
			"[user] tenderly milks [their] breasts, drop by drop, into \the [container]."),
		list("[user] milks [their] breasts into \the [container] in a steady rhythm.", "[user] squeezes [their] nipples, milk splashing into \the [container].",
			"[user] firmly milks [their] breasts into \the [container]."),
		list("[user] milks [their] breasts hard, milk spraying into \the [container].", "[user] tugs at [their] nipples, milk streaming into \the [container].",
			"[user] roughly squeezes [their] breasts, filling \the [container]."),
		list("[user] wrings [their] breasts like udders, milk gushing into \the [container].", "[user] milks [their] breasts mercilessly, squeezing out every drop.",
			"[user] brutally milks [their] breasts, milk spraying into \the [container] and everywhere else."))

/datum/sex_action/spray_milk/proc/cycle_message(mob/living/user, mob/living/target, aim)
	var/their = user.p_their()
	return pick_by_force(
		list("[user] squeezes [their] breasts, dribbling milk over [target]'s [aim].", "[user] gently lets milk trickle onto [target]'s [aim]."),
		list("[user] sprays a stream of milk over [target]'s [aim].", "[user] squeezes [their] nipples, milk splashing across [target]'s [aim]."),
		list("[user] squeezes [their] breasts hard, spraying milk all over [target]'s [aim].", "[user] hoses [target]'s [aim] down with [their] milk."),
		list("[user] drenches [target]'s [aim] in milk, squeezing [their] breasts mercilessly.", "[user] blasts [target]'s [aim] with thick streams of milk."))

/datum/sex_action/masturbate/heft_breasts/proc/cycle_message(mob/living/user)
	var/their = user.p_their()
	var/tits = get_breast_size_noun(user)
	return pick_by_force(
		list("[user] lifts [their] [tits] and lets them fall with a soft bounce.", "[user] weighs [their] [tits] in [their] palms.",
			"[user] gently bounces [their] [tits] in [their] hands."),
		list("[user] hefts [their] [tits] and drops them; they bounce heavily.", "[user] lifts [their] [tits] high and lets go.",
			"[user] juggles [their] [tits] from hand to hand."),
		list("[user] heaves [their] [tits] up and lets them slap back down.", "[user] lifts and drops [their] [tits], making them jiggle hard."),
		list("[user] tosses [their] [tits] up and lets them crash down, jiggling wildly.", "[user] hurls [their] [tits] up again and again, letting them slap down hard."))

/datum/sex_action/suck_own_nipple/proc/cycle_message(mob/living/user)
	var/their = user.p_their()
	return pick_by_force(
		list("[user] lifts a breast to [their] lips and gently suckles [their] own nipple.", "[user] lazily laps at [their] own nipple.",
			"[user] tenderly kisses [their] own nipple."),
		list("[user] sucks on [their] own nipple.", "[user] holds [their] breast up and suckles steadily.",
			"[user] swirls [their] tongue around [their] own nipple."),
		list("[user] sucks hard on [their] own nipple.", "[user] crams [their] own nipple into [their] mouth.",
			"[user] eagerly sucks [their] own breast."),
		list("[user] greedily devours [their] own nipple, sucking fiercely.", "[user] sucks [their] own nipple relentlessly, cheeks hollowed."))

/datum/sex_action/bounce_breasts/proc/cycle_message(mob/living/user)
	var/their = user.p_their()
	var/tits = get_breast_size_noun(user)
	return pick_by_force(
		list("[user] lazily sways [their] [tits] from side to side.", "[user] gives [their] [tits] a little jiggle.",
			"[user] rolls [their] shoulders, [their] [tits] wobbling softly."),
		list("[user] bounces [their] [tits] up and down.", "[user] shimmies, [their] [tits] jiggling.",
			"[user] puffs out [their] chest and bounces [their] [tits]."),
		list("[user] bounces [their] [tits] eagerly, letting them slap together.", "[user] jumps, [their] [tits] heaving up and down.",
			"[user] shakes [their] [tits] hard for everyone to see."),
		get_breast_visible_size(user) >= 7 ? list("[user] wildly bounces [their] [tits], making them slap and jiggle everywhere.", "[user] shakes [their] [tits] with wild abandon.",
			"[user] bounces so hard [their] [tits] slap against [their] chin.") : list("[user] wildly bounces [their] [tits], making them slap and jiggle everywhere.", "[user] shakes [their] [tits] with wild abandon."))

/datum/sex_action/masturbate/squeeze_together/proc/cycle_message(mob/living/user)
	var/their = user.p_their()
	var/tits = get_breast_size_noun(user)
	return pick_by_force(
		list("[user] gently presses [their] [tits] together.", "[user] cups [their] [tits] and pushes them together, deepening [their] cleavage.",
			"[user] softly squeezes [their] [tits] together."),
		list("[user] squeezes [their] [tits] together.", "[user] pushes [their] [tits] together, showing off [their] cleavage.",
			"[user] presses [their] [tits] together and lets them go."),
		list("[user] mashes [their] [tits] together hard.", "[user] squeezes [their] [tits] together until they spill over [their] hands."),
		list("[user] crushes [their] [tits] together until they bulge between [their] fingers.", "[user] mercilessly squeezes [their] [tits] together."))

#undef BREAST_MILKING_BASE_AMOUNT
#undef BREAST_SPRAY_ACTION_AMOUNT
#undef BREAST_SHOW_BOUNCE_AROUSAL
#undef BREAST_SHOW_SQUEEZE_AROUSAL
