// Anal beads: a string pushed in and drawn out one bead at a time; the rest hangs out with the ring.

/// Steps between chances for worn beads to shift.
#define BEAD_SHIFT_STEPS 10
/// Base vaginal depth in bead lengths, before organ size and stretching.
#define BEAD_VAGINA_BASE_DEPTH 4

/proc/get_bead_bulk(size)
	switch(size)
		if(BEAD_SMALL)
			return 0.5
		if(BEAD_LARGE)
			return 2
		if(BEAD_GIANT)
			return 3.5
	return 1

/// How far one bead reaches, in bead lengths.
/proc/get_bead_depth(size)
	switch(size)
		if(BEAD_SMALL)
			return 1
		if(BEAD_LARGE)
			return 2
		if(BEAD_GIANT)
			return 3
	return 1.5

/proc/get_bead_pleasure(size)
	switch(size)
		if(BEAD_SMALL)
			return 1
		if(BEAD_LARGE)
			return 2.2
		if(BEAD_GIANT)
			return 3
	return 1.6

/proc/get_bead_pain(size)
	switch(size)
		if(BEAD_SMALL)
			return 0.5
		if(BEAD_LARGE)
			return 1.8
		if(BEAD_GIANT)
			return 3
	return 1

/proc/get_bead_word(size)
	switch(size)
		if(BEAD_SMALL)
			return "small bead"
		if(BEAD_LARGE)
			return "large bead"
		if(BEAD_GIANT)
			return "huge bead"
	return "bead"

/// Scales [raw_pain] down so it stays arousal pain and never reaches the body-pain threshold.
/proc/cap_bead_pain(mob/living/receiver, raw_pain, force = SEX_FORCE_MID, speed = SEX_SPEED_MID)
	if(raw_pain <= 0)
		return 0
	var/datum/component/arousal/arousal = receiver?.GetComponent(/datum/component/arousal)
	if(!arousal)
		return raw_pain
	var/scaled = arousal.get_scaled_pain(raw_pain, force, speed)
	var/ceiling = PAIN_MINIMUM_FOR_DAMAGE - 1
	if(scaled <= ceiling)
		return raw_pain
	return raw_pain * ceiling / scaled

/// Depth a toy can reach in this hole, in bead lengths; null means no limit.
/obj/item/organ/proc/get_insertion_depth_limit()
	return null

/obj/item/organ/genitals/filling_organ/vagina/get_insertion_depth_limit()
	return (BEAD_VAGINA_BASE_DEPTH + max(organ_size, 0)) * (orifice ? orifice.get_stretch_ratio() : 1)

// ---- Shapes ----

/datum/bead_shape
	abstract_type = /datum/bead_shape
	var/name
	var/desc
	var/icon_state
	/// Bead sizes from the tip, which goes in first, to the ring.
	var/list/beads
	/// Textured beads give a little more pleasure and pain.
	var/textured = FALSE
	/// A stiff rod: it also works as a dildo.
	var/rigid = FALSE
	/// Only glass strings use this shape, and they use no other.
	var/glass_only = FALSE

/datum/bead_shape/petite
	name = "petite"
	desc = "a long run of small beads"
	icon_state = "small"
	beads = list(BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL)

/datum/bead_shape/standard
	name = "standard"
	desc = "eight even beads"
	icon_state = "medium"
	beads = list(BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM)

/datum/bead_shape/large
	name = "large"
	desc = "seven large beads"
	icon_state = "large"
	beads = list(BEAD_LARGE, BEAD_LARGE, BEAD_LARGE, BEAD_LARGE, BEAD_LARGE, BEAD_LARGE, BEAD_LARGE)

/datum/bead_shape/giant
	name = "giant"
	desc = "six huge beads"
	icon_state = "giant"
	beads = list(BEAD_GIANT, BEAD_GIANT, BEAD_GIANT, BEAD_GIANT, BEAD_GIANT, BEAD_GIANT)

/datum/bead_shape/petite_mixed
	name = "petite mixed"
	desc = "small and medium beads in turn"
	icon_state = "medium_and_small"
	beads = list(BEAD_SMALL, BEAD_MEDIUM, BEAD_SMALL, BEAD_MEDIUM, BEAD_SMALL, BEAD_MEDIUM, BEAD_SMALL, BEAD_MEDIUM, BEAD_SMALL, BEAD_MEDIUM, BEAD_SMALL, BEAD_MEDIUM)

/datum/bead_shape/large_mixed
	name = "large mixed"
	desc = "medium and large beads in turn"
	icon_state = "large_and_medium"
	beads = list(BEAD_MEDIUM, BEAD_LARGE, BEAD_MEDIUM, BEAD_LARGE, BEAD_MEDIUM, BEAD_LARGE, BEAD_MEDIUM, BEAD_LARGE)

/datum/bead_shape/graduated_petite
	name = "graduated petite"
	desc = "three beads that swell toward the ring"
	icon_state = "pyramid_small"
	beads = list(BEAD_SMALL, BEAD_MEDIUM, BEAD_LARGE)

/datum/bead_shape/graduated
	name = "graduated"
	desc = "four beads that swell toward the ring"
	icon_state = "pyramid_medium"
	beads = list(BEAD_SMALL, BEAD_MEDIUM, BEAD_LARGE, BEAD_GIANT)

/datum/bead_shape/graduated_large
	name = "graduated large"
	desc = "seven beads that swell from small to huge"
	icon_state = "pyramid_large"
	beads = list(BEAD_SMALL, BEAD_SMALL, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_LARGE, BEAD_LARGE, BEAD_GIANT)

/datum/bead_shape/rod
	name = "rod"
	desc = "five beads fixed on a stiff rod"
	icon_state = "straight"
	beads = list(BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM)
	rigid = TRUE

/datum/bead_shape/serpent
	name = "serpent"
	desc = "a very long chain of small beads"
	icon_state = "snake"
	beads = list(BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, \
		BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, \
		BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL, BEAD_SMALL)

/datum/bead_shape/knobbled
	name = "knobbled"
	desc = "seven large beads with a bumpy, textured surface"
	icon_state = "spiky"
	beads = list(BEAD_LARGE, BEAD_LARGE, BEAD_LARGE, BEAD_LARGE, BEAD_LARGE, BEAD_LARGE, BEAD_LARGE)
	textured = TRUE

/datum/bead_shape/glass
	name = "glass"
	desc = "seven clear glass beads"
	icon_state = "glass_main"
	beads = list(BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM, BEAD_MEDIUM)
	glass_only = TRUE

GLOBAL_LIST_INIT(bead_shapes, init_bead_shapes())

/proc/init_bead_shapes()
	var/list/shapes = list()
	for(var/datum/bead_shape/shape_type as anything in subtypesof(/datum/bead_shape))
		if(IS_ABSTRACT(shape_type))
			continue
		shapes[shape_type] = new shape_type
	return shapes

// ---- Item ----

/obj/item/anal_beads
	name = "unfinished anal beads"
	desc = "A cord strung with beads and a pull ring. Shape it in hand."
	icon = 'modular_rmh/icons/obj/lewd/beads.dmi'
	icon_state = "medium"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 0
	sellprice = 5
	body_storage_random_removal = FALSE
	/// Material word used in the name.
	var/material_name = "wooden"
	var/datum/bead_shape/shape
	/// Beads inside a hole right now, counted from the tip.
	var/beads_inside = 0
	/// The organ holding the string, while worn.
	var/obj/item/organ/host_organ
	var/mob/living/carbon/host
	var/mutable_appearance/hanging_overlay
	var/steps_since_shift = 0
	/// Bead crossing the ring during a push or pull; zero when none.
	var/passing_bead = 0

/obj/item/anal_beads/Destroy()
	if(host_organ)
		// Deleted, not yanked: no rush of beads.
		beads_inside = 0
		SEND_SIGNAL(host_organ, COMSIG_BODYSTORAGE_FORCE_REMOVE, src, STORAGE_LAYER_INNER)
	detach_from_host()
	shape = null
	return ..()

/obj/item/anal_beads/examine(mob/user)
	. = ..()
	if(!shape)
		return
	. += span_notice("[capitalize(shape.desc)], [get_bead_count()] in all.")
	if(shape.rigid)
		. += span_notice("The rod is stiff enough to use like a dildo.")

/obj/item/anal_beads/attack_self(mob/living/user)
	. = ..()
	if(shape || !istype(user))
		return
	choose_shape(user)

/obj/item/anal_beads/proc/choose_shape(mob/living/user)
	var/list/choices = list()
	var/list/shape_by_name = list()
	for(var/shape_type in GLOB.bead_shapes)
		var/datum/bead_shape/option = GLOB.bead_shapes[shape_type]
		if(option.glass_only)
			continue
		var/image/preview = image(icon = icon, icon_state = option.icon_state)
		preview.color = color
		choices[option.name] = preview
		shape_by_name[option.name] = option
	var/picked = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)
	if(!picked || shape || QDELETED(src) || user.incapacitated())
		return
	set_shape(shape_by_name[picked])

/obj/item/anal_beads/proc/set_shape(datum/bead_shape/new_shape)
	shape = new_shape
	beads_inside = 0
	body_storage_bulk = get_inserted_bulk(1)
	update_appearance()

/obj/item/anal_beads/update_name(updates)
	. = ..()
	name = shape ? "[shape.glass_only ? "" : "[shape.name] "][material_name] anal beads" : "unfinished [material_name] anal beads"

/obj/item/anal_beads/update_icon_state()
	. = ..()
	if(shape)
		icon_state = shape.icon_state

/obj/item/anal_beads/proc/get_bead_count()
	return length(shape?.beads)

/obj/item/anal_beads/proc/get_bead(index)
	if(!shape || index < 1 || index > length(shape.beads))
		return null
	return shape.beads[index]

/// Storage bulk of the first [count] beads.
/obj/item/anal_beads/proc/get_inserted_bulk(count = beads_inside)
	. = 0
	for(var/index in 1 to min(count, get_bead_count()))
		. += get_bead_bulk(shape.beads[index])

/// Depth the first [count] beads reach, in bead lengths.
/obj/item/anal_beads/proc/get_inserted_depth(count = beads_inside)
	. = 0
	for(var/index in 1 to min(count, get_bead_count()))
		. += get_bead_depth(shape.beads[index])

/obj/item/anal_beads/proc/get_bead_pleasure_of(size)
	return get_bead_pleasure(size) * (shape?.textured ? 1.25 : 1)

/obj/item/anal_beads/proc/get_bead_pain_of(size)
	return get_bead_pain(size) * (shape?.textured ? 1.3 : 1)

/obj/item/anal_beads/proc/get_string_color()
	return color

/obj/item/anal_beads/proc/get_hole_word()
	return host_organ?.slot == ORGAN_SLOT_VAGINA ? "pussy" : "ass"

/obj/item/anal_beads/can_enter_body_storage_layer(target_layer)
	return !!shape && target_layer == STORAGE_LAYER_INNER

/obj/item/anal_beads/can_random_body_storage_layer_swap()
	return FALSE

/obj/item/anal_beads/get_fluid_displacement()
	return round(get_inserted_bulk() * 4)

/// Index of the widest bead from [first] to [last]; the outermost wins a tie.
/obj/item/anal_beads/proc/get_widest_bead_index(first, last)
	. = 0
	var/widest = 0
	for(var/index in max(first, 1) to min(last, get_bead_count()))
		var/girth = get_bead_girth(get_bead(index))
		if(girth >= widest)
			widest = girth
			. = index

/// Passes bead [index] through the ring of [hole] once, for strain pain and soreness.
/obj/item/anal_beads/proc/pass_bead(obj/item/organ/hole, index, force = SEX_FORCE_MID, mob/living/performer)
	var/obj/item/organ/genitals/filling_organ/filling_hole = hole
	if(!istype(filling_hole) || !index)
		return
	filling_hole.get_orifice()?.pass_through(get_bead_girth(get_bead(index)), force, performer)

/// Pushes the next bead into [organ]. Returns a body-storage insert feedback or a BEADS_* result.
/obj/item/anal_beads/proc/push_bead(obj/item/organ/organ, use_force = FALSE, mob/living/pusher, force = SEX_FORCE_MID)
	if(!shape || !organ)
		return FALSE
	if(beads_inside >= get_bead_count())
		return BEADS_ALL_IN
	if(host_organ && host_organ != organ)
		return FALSE
	var/depth_limit = organ.get_insertion_depth_limit()
	if(!isnull(depth_limit) && get_inserted_depth(beads_inside + 1) > depth_limit)
		return BEADS_TOO_DEEP
	passing_bead = beads_inside + 1
	var/result
	if(!beads_inside)
		body_storage_bulk = get_inserted_bulk(1)
		// Storage insertion checks the opening and passes the first bead through it.
		result = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_INSERT, src, STORAGE_LAYER_INNER, use_force)
	else
		result = organ.get_body_storage_width_feedback(src, STORAGE_LAYER_INNER, use_force)
		var/forced_wide = result == INSERT_FEEDBACK_OK_FORCE
		if(result == INSERT_FEEDBACK_OK || forced_wide)
			result = SEND_SIGNAL(organ, COMSIG_BODYSTORAGE_TRY_RESIZE, src, get_inserted_bulk(beads_inside + 1), use_force)
			if(result in list(INSERT_FEEDBACK_OK, INSERT_FEEDBACK_OK_FORCE, INSERT_FEEDBACK_ALMOST_FULL))
				// Across the ring before it counts as inside, so the held-open floor does not cushion it.
				pass_bead(organ, passing_bead, force, pusher)
				beads_inside++
				if(forced_wide)
					result = INSERT_FEEDBACK_OK_FORCE
	passing_bead = 0
	update_hanging_overlay()
	return result

/// Draws the outermost inside bead out. Returns its size, or null. The last bead hands the string to [puller].
/obj/item/anal_beads/proc/pull_bead(mob/living/puller, force = SEX_FORCE_MID)
	var/list/sizes = pull_beads(1, puller, force)
	return length(sizes) ? sizes[1] : null

/// Draws the outermost [count] beads out at once, one passage at the widest. Returns their sizes.
/obj/item/anal_beads/proc/pull_beads(count, mob/living/puller, force = SEX_FORCE_MID)
	. = list()
	count = min(count, beads_inside)
	if(!host_organ || count <= 0)
		return
	var/obj/item/organ/hole = host_organ
	var/string_leaves = count >= beads_inside
	passing_bead = get_widest_bead_index(beads_inside - count + 1, beads_inside)
	if(!string_leaves)
		pass_bead(hole, passing_bead, force, puller)
	for(var/pulled in 1 to count)
		. += get_bead(beads_inside)
		beads_inside--
	if(!string_leaves)
		passing_bead = 0
		SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_TRY_RESIZE, src, get_inserted_bulk(beads_inside), FALSE)
		update_hanging_overlay()
		return
	var/turf/drop_turf = get_turf(host) || get_turf(hole)
	// Storage removal passes the marked bead through the ring as the string leaves.
	SEND_SIGNAL(hole, COMSIG_BODYSTORAGE_FORCE_REMOVE, src, STORAGE_LAYER_INNER)
	passing_bead = 0
	forceMove(drop_turf)
	if(puller && !puller.get_active_held_item())
		puller.put_in_active_hand(src)

/obj/item/anal_beads/on_body_storage_entered(obj/item/organ/storage_organ, target_layer)
	. = ..()
	host_organ = storage_organ
	host = storage_organ.owner
	// Generic stuffing pushes in just the first bead.
	if(beads_inside <= 0)
		beads_inside = 1
	if(host)
		RegisterSignal(host, COMSIG_MOVABLE_MOVED, PROC_REF(on_host_moved))
		RegisterSignal(host, COMSIG_SEX_CLIMAX, PROC_REF(on_host_climax))
		RegisterSignal(host, COMSIG_PARENT_EXAMINE, PROC_REF(on_host_examine))
	update_hanging_overlay()

/obj/item/anal_beads/on_body_storage_exited(obj/item/organ/storage_organ)
	. = ..()
	var/mob/living/carbon/old_host = host
	var/left_inside = beads_inside
	detach_from_host()
	// Anything but a bead-by-bead draw takes the whole string at once, which is a yank.
	if(old_host && left_inside > 0)
		yank_feedback(old_host, left_inside)

/obj/item/anal_beads/proc/detach_from_host()
	if(host)
		host.cut_overlay(hanging_overlay)
		UnregisterSignal(host, list(COMSIG_MOVABLE_MOVED, COMSIG_SEX_CLIMAX, COMSIG_PARENT_EXAMINE))
	hanging_overlay = null
	host = null
	host_organ = null
	beads_inside = 0
	steps_since_shift = 0
	if(shape)
		body_storage_bulk = get_inserted_bulk(1)

/// Arousal and pain for [count] beads leaving at once, outside any sex action.
/obj/item/anal_beads/proc/yank_feedback(mob/living/carbon/yanked, count)
	var/pleasure = 0
	var/pain = 0
	for(var/index in 1 to count)
		var/size = get_bead(index)
		pleasure += get_bead_pleasure_of(size)
		pain += get_bead_pain_of(size)
	yanked.visible_message(span_love("[count] bead\s pop out of [yanked] in a rattling rush!"), span_love("[count] bead\s pop out of me in a rattling rush!"))
	playsound(yanked, 'sound/misc/mat/pop.ogg', 40, TRUE, -2, ignore_walls = FALSE)
	SEND_SIGNAL(yanked, COMSIG_SEX_GENERIC_ACTION, yanked, pleasure, cap_bead_pain(yanked, pain), pleasure * 0.6, src)

/obj/item/anal_beads/proc/update_hanging_overlay()
	if(host && hanging_overlay)
		host.cut_overlay(hanging_overlay)
	hanging_overlay = null
	if(!host || beads_inside <= 0)
		return
	var/outside = get_bead_count() - beads_inside
	// Fully inside, nothing shows.
	if(outside <= 0)
		return
	var/hole = host_organ?.slot == ORGAN_SLOT_VAGINA ? "vagina" : "anus"
	hanging_overlay = mutable_appearance('modular_rmh/icons/obj/lewd/beads_onmob.dmi', "beads_[hole]_[min(outside, 3)]", -BODY_LAYER)
	hanging_overlay.color = get_string_color()
	host.add_overlay(hanging_overlay)

/obj/item/anal_beads/proc/on_host_moved(datum/source)
	SIGNAL_HANDLER
	if(++steps_since_shift < BEAD_SHIFT_STEPS)
		return
	steps_since_shift = 0
	if(!host || !prob(30))
		return
	to_chat(host, span_love(pick("The beads shift inside me with every step.", "I feel each bead roll against the next as I walk.", "The beads press and shift deep in my [get_hole_word()].")))
	INVOKE_ASYNC(src, PROC_REF(stimulate_host), 0.3 + 0.1 * min(beads_inside, 5))

/obj/item/anal_beads/proc/stimulate_host(arousal)
	if(host)
		SEND_SIGNAL(host, COMSIG_SEX_GENERIC_ACTION, host, arousal, 0, arousal * 0.3, src)

/obj/item/anal_beads/proc/on_host_climax(datum/source, datum/sex_action/action, mob/living/action_initiator, mob/living/action_target, atom/action_performer)
	SIGNAL_HANDLER
	if(!host || host.is_holding_fluids_in() || host.wants_auto_clench())
		return
	INVOKE_ASYNC(src, PROC_REF(climax_push_out))

/// Climax contractions push a few beads out, unless the wearer is holding in or clenching.
/obj/item/anal_beads/proc/climax_push_out()
	var/mob/living/carbon/pusher = host
	if(!pusher)
		return
	var/count = min(rand(1, 3), beads_inside)
	var/hole = get_hole_word()
	for(var/index in 1 to count)
		pull_bead()
	pusher.visible_message(span_love("[pusher]'s climax pushes [count] bead\s out of [pusher.p_their()] [hole]!"), span_love("My climax pushes [count] bead\s out of my [hole]!"))
	playsound(pusher, 'sound/misc/mat/pop.ogg', 35, TRUE, -2, ignore_walls = FALSE)

/obj/item/anal_beads/proc/on_host_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!host || beads_inside <= 0 || beads_inside >= get_bead_count())
		return
	if(!get_location_accessible(host, BODY_ZONE_PRECISE_GROIN))
		return
	examine_list += span_love("A [material_name] ring dangles from [host.p_their()] [get_hole_word()], a string of beads trailing from it.")

/obj/item/anal_beads/get_sex_action_effects(datum/sex_action_effect_context/context)
	if(!host || beads_inside <= 0 || context.receiver != host)
		return null
	return list(new /datum/sex_action_effect/beads_fullness(src))

/// Beads inside make other stimulation feel fuller.
/datum/sex_action_effect/beads_fullness

/datum/sex_action_effect/beads_fullness/modify_action(datum/sex_action_effect_context/context)
	var/obj/item/anal_beads/beads = source_item
	if(istype(context.action, /datum/sex_action/beads))
		return
	context.arousal_amt *= 1 + min(0.3, beads.get_inserted_bulk() * 0.03)

// ---- Materials ----

/obj/item/anal_beads/wood
	color = "#7D4033"
	material_name = "wooden"
	resistance_flags = FLAMMABLE
	sellprice = 3

/obj/item/anal_beads/stone
	color = "#3f3f3f"
	material_name = "stone"
	sellprice = 4

/obj/item/anal_beads/iron
	color = "#909090"
	material_name = "iron"
	sellprice = 6

/obj/item/anal_beads/copper
	color = "#a86918"
	material_name = "copper"
	sellprice = 8

/obj/item/anal_beads/steel
	color = "#887e99"
	material_name = "steel"
	sellprice = 12

/obj/item/anal_beads/silver
	color = "#ffffff"
	material_name = "silver"
	sellprice = 30

/obj/item/anal_beads/gold
	color = "#b38f1b"
	material_name = "golden"
	sellprice = 50

/obj/item/anal_beads/glass
	icon_state = "glass_main"
	material_name = "glass"
	sellprice = 15
	/// Tint of the glass beads, picked when shaped.
	var/glass_color = "#bfeeff"

/obj/item/anal_beads/glass/choose_shape(mob/living/user)
	var/new_color = input(user, "Choose the colour of the glass.", "Glass Beads", glass_color) as color|null
	if(!new_color || shape || QDELETED(src) || user.incapacitated())
		return
	glass_color = sanitize_hexcolor(new_color, 6, TRUE, glass_color)
	set_shape(GLOB.bead_shapes[/datum/bead_shape/glass])

/obj/item/anal_beads/glass/update_overlays()
	. = ..()
	var/mutable_appearance/shine = mutable_appearance(icon, "glass_overlay")
	shine.color = glass_color
	shine.appearance_flags = RESET_COLOR
	. += shine

/obj/item/anal_beads/glass/get_string_color()
	return glass_color

// ---- Crafting ----

/datum/repeatable_crafting_recipe/crafting/anal_beads_wood
	name = "wooden anal beads"
	output = /obj/item/anal_beads/wood
	requirements = list(/obj/item/grown/log/tree/small = 1, /obj/item/natural/fibers = 1)
	starting_atom = /obj/item/weapon/knife
	attacked_atom = /obj/item/grown/log/tree/small
	category = "Lewd"
	craftdiff = 2

/datum/repeatable_crafting_recipe/crafting/anal_beads_stone
	name = "stone anal beads"
	output = /obj/item/anal_beads/stone
	requirements = list(/obj/item/natural/stone = 1, /obj/item/natural/fibers = 1)
	starting_atom = /obj/item/weapon/knife
	attacked_atom = /obj/item/natural/stone
	category = "Lewd"
	craftdiff = 2

/datum/anvil_recipe/anal_beads_iron
	name = "Anal beads, iron"
	req_bar = /obj/item/ingot/iron
	created_item = /obj/item/anal_beads/iron
	i_type = "Lewd"

/datum/anvil_recipe/anal_beads_copper
	name = "Anal beads, copper"
	req_bar = /obj/item/ingot/copper
	created_item = /obj/item/anal_beads/copper
	i_type = "Lewd"

/datum/anvil_recipe/anal_beads_steel
	name = "Anal beads, steel"
	req_bar = /obj/item/ingot/steel
	created_item = /obj/item/anal_beads/steel
	i_type = "Lewd"

/datum/anvil_recipe/anal_beads_silver
	name = "Anal beads, silver"
	req_bar = /obj/item/ingot/silver
	created_item = /obj/item/anal_beads/silver
	i_type = "Lewd"

/datum/anvil_recipe/anal_beads_gold
	name = "Anal beads, gold"
	req_bar = /obj/item/ingot/gold
	created_item = /obj/item/anal_beads/gold
	i_type = "Lewd"

/datum/anvil_recipe/anal_beads_glass
	name = "Anal beads, glass"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/natural/glass)
	created_item = /obj/item/anal_beads/glass
	i_type = "Lewd"

#undef BEAD_SHIFT_STEPS
#undef BEAD_VAGINA_BASE_DEPTH
