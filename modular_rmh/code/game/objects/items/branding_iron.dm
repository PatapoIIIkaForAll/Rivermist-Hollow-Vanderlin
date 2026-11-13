// RMH - Branding: branding iron and letter kit.
// Ported from Twilight Axis (sprites, letter kit, anvil recipes) and merged with
// our rules: the target must be helpless or restrained, the zone must be bare,
// and each skin spot can only carry one brand.

/obj/item/branding_letters
	name = "branding letter kit"
	desc = "A wooden box with a set of metal letters. Used to change the text on a branding iron."
	icon = 'modular_rmh/icons/obj/brand/brand.dmi'
	icon_state = "brand_letter"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE

/obj/item/branding_iron
	name = "branding iron"
	desc = "A heavy metal tool for searing marks. It is currently cold."
	icon = 'modular_rmh/icons/obj/brand/brand.dmi'
	icon_state = "brand_cold"
	item_state = "mace_greyscale"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 8
	damtype = BRUTE
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_HIP
	hitsound = list('sound/combat/hits/pick/genpick (2).ogg')
	possible_item_intents = list(/datum/intent/hit)

	/// Text the letter kit has set into the plate.
	var/current_text = "X"
	var/heated = FALSE
	var/cool_timer
	/// Minimum get_temperature() of a heat source needed to heat this, in Kelvin.
	var/heat_source_threshold = 100 + T0C
	var/heat_duration = 30 SECONDS
	var/brand_time = 4 SECONDS
	var/brand_damage = 20
	var/max_brand_length = 6

/obj/item/branding_iron/Destroy()
	if(cool_timer)
		deltimer(cool_timer)
		cool_timer = null
	return ..()

/obj/item/branding_iron/examine(mob/user)
	. = ..()
	. += span_notice("The set symbols read: <b style='color: #c48e42'>'[current_text]'</b>.")
	if(heated)
		. += span_danger("IT IS RED-HOT!")

/obj/item/branding_iron/update_icon_state()
	. = ..()
	if(heated)
		icon_state = "brand_hot"
		force = 12
		damtype = BURN
		desc = "A heavy metal tool. It radiates heat!"
		hitsound = list('modular_rmh/sound/items/steamrelease.ogg')
	else
		icon_state = "brand_cold"
		force = initial(force)
		damtype = initial(damtype)
		desc = initial(desc)
		hitsound = list('sound/combat/hits/pick/genpick (2).ogg')

/obj/item/branding_iron/get_temperature()
	if(heated)
		return 150 + T0C
	return ..()

/obj/item/branding_iron/proc/heat_up()
	heated = TRUE
	if(cool_timer)
		deltimer(cool_timer)
	cool_timer = addtimer(CALLBACK(src, PROC_REF(cool_down)), heat_duration, TIMER_STOPPABLE)
	update_appearance(UPDATE_ICON_STATE)
	visible_message(span_danger("[src] glows red-hot!"))
	playsound(src, 'modular_rmh/sound/items/steamrelease.ogg', 50, TRUE)

/obj/item/branding_iron/proc/cool_down()
	heated = FALSE
	cool_timer = null
	update_appearance(UPDATE_ICON_STATE)
	visible_message(span_notice("[src] hisses as it cools down."))

/// Swap the letters. Only possible while the plate is cold.
/obj/item/branding_iron/attackby(obj/item/attacking_item, mob/living/user, list/modifiers)
	if(istype(attacking_item, /obj/item/branding_letters))
		if(heated)
			to_chat(user, span_warning("I cannot change the letters while the branding iron is hot! I must let it cool down first."))
			return TRUE
		// max_length is deliberately not passed: tgui trims with copytext, which cuts
		// by bytes, so Cyrillic text loses half its characters. Clamp by character here.
		var/new_text = tgui_input_text(user, "Enter the brand text. Maximum [max_brand_length] characters.", "Branding Iron Letters (max [max_brand_length])", current_text)
		if(new_text)
			new_text = trimtext(copytext_char(new_text, 1, max_brand_length + 1))
		if(new_text)
			current_text = new_text
			to_chat(user, span_notice("I carefully change the metal letters in the branding iron. It now reads: '[current_text]'."))
			playsound(src, 'sound/items/pickgood1.ogg', 50, TRUE)
		return TRUE
	if(attacking_item.get_temperature() >= heat_source_threshold)
		if(heated)
			to_chat(user, span_warning("[src] is already red-hot!"))
			return TRUE
		user.visible_message(span_info("[user] heats [src] with [attacking_item]."))
		heat_up()
		return TRUE
	return ..()

/// Heat it in any lit fire: forge, campfire, hearth, firebowl.
/obj/item/branding_iron/pre_attack(atom/target, mob/living/user, list/modifiers)
	if(!istype(target, /obj/machinery/light/fueled))
		return ..()
	var/obj/machinery/light/fueled/flame = target
	if(!flame.on)
		return ..()
	if(heated)
		to_chat(user, span_warning("[src] is already red-hot!"))
		return TRUE

	user.visible_message(span_notice("[user] places [src] into the flames of [flame]..."), \
		span_notice("I place [src] into the flames of [flame]..."))
	if(do_after(user, 3 SECONDS, flame))
		if(QDELETED(flame) || !flame.on)
			to_chat(user, span_warning("The fire has gone out!"))
			return TRUE
		if(!heated)
			heat_up()
	return TRUE

/obj/item/branding_iron/attack(mob/living/target, mob/living/user, list/modifiers)
	if(!heated || !ishuman(target))
		return ..()

	var/mob/living/carbon/human/patient = target

	if(!is_held_still(patient, user))
		to_chat(user, span_warning("[patient] would need to be restrained or helpless to hold still for this."))
		return

	var/brand_zone = patient.pick_brand_zone(user, user.zone_selected)
	if(!brand_zone || !heated || QDELETED(patient))
		return
	var/zone_name = tattoo_zone_name(brand_zone)

	user.visible_message(span_warning("[user] starts pressing the red-hot branding iron against [patient]'s [zone_name]..."), \
		span_warning("I take aim to brand [patient]'s [zone_name]..."))

	if(!do_after(user, brand_time, patient))
		return
	// Re-check everything: do_after only watches the user's own position, so the
	// victim can break free, walk off or pull armour on in the meantime.
	if(!heated || QDELETED(patient))
		return
	if(!user.Adjacent(patient) || !is_held_still(patient, user))
		to_chat(user, span_warning("[patient] broke away!"))
		return
	var/problem = patient.brand_zone_problem(brand_zone, user)
	if(problem)
		to_chat(user, span_warning(problem))
		return
	var/brand_text = uppertext(current_text)
	if(!patient.add_skin_brand(brand_zone, brand_text))
		return

	user.do_attack_animation(patient)
	user.visible_message(span_danger("[user] presses the red-hot branding iron against [patient]'s [zone_name] with a loud hiss!"), \
		span_userdanger("I forcefully press the branding iron against [patient]'s [zone_name], searing the mark!"))
	playsound(patient, 'modular_rmh/sound/items/steamrelease.ogg', 60, TRUE)
	patient.emote("scream")

	patient.apply_damage(brand_damage, BURN, tattoo_zone_limb(brand_zone))
	log_combat(user, patient, "branded", src, "text: [brand_text]")
	user.changeNext_move(CLICK_CD_MELEE * 1.5)
	cool_down()

/datum/anvil_recipe/tools/iron/branding_iron
	name = "Branding Iron (+1 Plank)"
	additional_items = list(/obj/item/natural/wood/plank)
	created_item = /obj/item/branding_iron
	craftdiff = 2

/datum/anvil_recipe/tools/tin/branding_letters
	name = "Branding Letter Kit (+1 Plank)"
	additional_items = list(/obj/item/natural/wood/plank)
	created_item = /obj/item/branding_letters
	craftdiff = 2
