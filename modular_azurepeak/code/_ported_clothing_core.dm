// Shared support for clothing ported from Azure Peak and Twilight Axis.
// Both modular_azurepeak and modular_twilightaxis rely on this file.

/// COLOR_MAP is a macro that builds a new list on every use; ported colour pickers share one copy.
GLOBAL_LIST_INIT(ported_color_map, COLOR_MAP)

/obj/item/clothing
	/// Second colourable overlay layer used by plumes, crests and trims.
	var/altdetail_tag
	var/altdetail_color
	/// Uses the generic visor/coif toggle below instead of a bespoke AdjustClothes().
	var/ported_adjust = FALSE
	/// Body coverage while toggled open.
	var/adj_open_coverage
	/// flags_inv while toggled open.
	var/adj_open_inv
	/// flags_cover while toggled open.
	var/adj_open_cover
	/// block2add while toggled open.
	var/adj_open_fov
	var/adj_sound

/obj/item/clothing/proc/get_altdetail_tag()
	return altdetail_tag

/obj/item/clothing/proc/get_altdetail_color()
	return altdetail_color

/obj/item/clothing/update_overlays()
	. = ..()
	if(!altdetail_tag)
		return
	var/mutable_appearance/pic = mutable_appearance(icon, "[icon_state][altdetail_tag]")
	pic.appearance_flags = RESET_COLOR
	if(altdetail_color)
		pic.color = altdetail_color
	. += pic

/obj/item/clothing/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, dummy_block = FALSE)
	. = ..()
	if(isinhands || !altdetail_tag || !standing)
		return
	var/mutable_appearance/pic = mutable_appearance(standing.icon, "[standing.icon_state][altdetail_tag]")
	pic.appearance_flags = RESET_COLOR
	if(altdetail_color)
		pic.color = altdetail_color
	. += pic

/obj/item/clothing/AdjustClothes(mob/user)
	if(!ported_adjust)
		return ..()
	ported_adjust_toggle(user)

// RMH visors swap to "_raised" sprites; ported visors keep the "_t" toggle.
/obj/item/clothing/head/helmet/visored/AdjustClothes(mob/user)
	if(!ported_adjust)
		return ..()
	ported_adjust_toggle(user)

/// Opens or closes a ported visor, coif or robe using the adj_open_* values.
/obj/item/clothing/proc/ported_adjust_toggle(mob/user)
	if(loc != user)
		to_chat(user, span_warning("I need to wear [src] to adjust it."))
		return
	if(adjustable == CAN_CADJUST)
		adjustable = CADJUSTED
		icon_state = "[initial(icon_state)]_t"
		body_parts_covered = adj_open_coverage
		flags_inv = adj_open_inv
		flags_cover = adj_open_cover
		block2add = adj_open_fov
	else if(adjustable == CADJUSTED)
		ResetAdjust(user)
	if(adj_sound)
		playsound(user, adj_sound, 50, TRUE, -1)
	update_appearance()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_clothing(slot_flags)
		H.update_fov_angles()

/obj/structure/dye_bin/interact(mob/living/user)
	var/obj/item/clothing/C = inserted
	if(!istype(C) || !C.get_altdetail_tag())
		return ..()
	var/list/dat = list("<STYLE> * {text-align: center;} </STYLE>")
	var/ref = REF(src)
	dat += "Item inserted: \the [inserted]<BR>"
	dat += "<A href='byond://?src=[ref];action=eject'>Remove item.</A>"
	dat += "<HR>"
	dat += "Color: <span style='color:[active_color];'>&#9632;</span>"
	dat += "<BR>"
	dat += "<A href='byond://?src=[ref];action=select'>Select new color.</A>"
	dat += "<BR>"
	dat += "<A href='byond://?src=[ref];action=paint;type=base'>Taint with dye.</A>"
	if(C.get_detail_tag())
		dat += " | <A href='byond://?src=[ref];action=paint;type=detail'>Apply dye to accent.</A>"
	dat += " | <A href='byond://?src=[ref];action=paint;type=altdetail'>Apply dye to second accent.</A>"
	var/datum/browser/menu = new(user, "colormate","<CENTER>[src]</CENTER>", 400, 400, src)
	menu.set_content(dat.Join())
	menu.open()

/obj/structure/dye_bin/Topic(href, href_list)
	if(href_list["action"] != "paint" || href_list["type"] != "altdetail")
		return ..()
	var/mob/living/user = usr
	if(!istype(user) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	var/obj/item/clothing/C = inserted
	if(!istype(C) || !active_color)
		return
	playsound(src, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 50, FALSE)
	if(!do_after(user, 1 SECONDS, src))
		return
	// someone may have taken the item out, or swapped it, while we waited
	if(inserted != C || C.loc != src)
		return
	C.altdetail_color = active_color
	C.update_appearance(UPDATE_OVERLAYS)
	user.visible_message(span_notice("[user] dyes [C] in [src]."), span_notice("I dye [C] in [src]."))
	C.forceMove(get_turf(src))
	inserted = null
	icon_state = initial(icon_state)


// ---------------------------------------------------------------------------
// Everything below only applies to clothing ported from Azure Peak and Twilight Axis
// (ported_clothing = TRUE). Existing Rivermist Hollow clothing keeps its own controls.
// ---------------------------------------------------------------------------

/// How many cosmetic pieces one hat or armour can carry.
#define PORTED_COSMETIC_CAPACITY 2

/obj/item/clothing
	/// Set on clothing ported from Azure Peak and Twilight Axis; enables the controls and hints below.
	var/ported_clothing = FALSE
	/// FALSE when a parent already uses middle-click for something else (lenses, robe styles).
	var/layer_toggle = TRUE
	/// Layer toggles (cloaks, wrists, rings, masks, hoods) remember whether they were flipped.
	var/layer_flipped = FALSE
	/// Masks with a "_snout" worn sprite can swap to it.
	var/snouted = FALSE
	/// Shows the hint about fitting feathers or cloth.
	var/hint_decorate = FALSE
	/// Shows the hint about picking a pattern with right-click.
	var/hint_pattern = FALSE
	/// Purely decorative pieces layered over this one. They are kept in contents.
	var/list/cosmetic_pieces
	/// Set on a piece layered over another one while it is toggled hidden.
	var/cosmetic_hidden = FALSE

// ---------------------------------------------------------------------------
// Cosmetic layering: drag a piece onto a worn hat or armour to wear it over it.
// No storage component is involved, so bags and storage checks are unaffected.
// ---------------------------------------------------------------------------

/// Slots a piece must fit to be layered over this one.
/obj/item/clothing/proc/cosmetic_slots()
	if(!ported_clothing)
		return NONE
	if(istype(src, /obj/item/clothing/head))
		return ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	if(istype(src, /obj/item/clothing/armor))
		return ITEM_SLOT_CLOAK|ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	return NONE

/obj/item/clothing/proc/can_layer_cosmetic(obj/item/clothing/piece, mob/user)
	var/allowed = cosmetic_slots()
	if(!allowed || piece == src)
		return FALSE
	if(LAZYLEN(cosmetic_pieces) >= PORTED_COSMETIC_CAPACITY)
		to_chat(user, span_warning("[src] can't carry any more decorations."))
		return FALSE
	// jewellery keeps its value visible; it never hides under other clothing
	if(istype(piece, /obj/item/clothing/ring) || istype(piece, /obj/item/clothing/neck))
		return FALSE
	if(!(piece.slot_flags & allowed))
		to_chat(user, span_warning("[piece] can't be worn over [src]."))
		return FALSE
	if(piece.get_armor_rating(STAB) > 0 || piece.get_armor_rating(BLUNT) > 0)
		to_chat(user, span_warning("[piece] is too sturdy to be a mere decoration."))
		return FALSE
	if(length(piece.contents) || piece.GetComponent(/datum/component/storage))
		to_chat(user, span_warning("[piece] needs to be empty first."))
		return FALSE
	return TRUE

/obj/item/clothing/MouseDrop_T(atom/dropping, mob/user)
	if(!ported_clothing || !isliving(user) || loc != user || !istype(dropping, /obj/item/clothing))
		return ..()
	var/obj/item/clothing/piece = dropping
	if(!user.is_holding(piece) || !can_layer_cosmetic(piece, user))
		return ..()
	if(!user.transferItemToLoc(piece, src))
		return
	LAZYADD(cosmetic_pieces, piece)
	to_chat(user, span_info("I wear [piece] over [src]."))
	refresh_cosmetic_wearer()

/obj/item/clothing/Exited(atom/movable/gone, direction)
	. = ..()
	if(!LAZYLEN(cosmetic_pieces) || !(gone in cosmetic_pieces))
		return
	LAZYREMOVE(cosmetic_pieces, gone)
	var/obj/item/clothing/piece = gone
	piece.cosmetic_hidden = FALSE
	refresh_cosmetic_wearer()

/obj/item/clothing/Destroy()
	if(LAZYLEN(cosmetic_pieces))
		var/atom/drop_to = drop_location()
		for(var/obj/item/clothing/piece as anything in cosmetic_pieces.Copy())
			if(drop_to)
				piece.forceMove(drop_to)
			else
				qdel(piece)
		cosmetic_pieces = null
	return ..()

/obj/item/clothing/proc/refresh_cosmetic_wearer()
	if(ismob(loc))
		var/mob/M = loc
		M.update_clothing(slot_flags)

/// Lets the wearer show, hide or take off a layered piece. Returns TRUE if there was anything to manage.
/obj/item/clothing/proc/manage_cosmetic_pieces(mob/user)
	if(!LAZYLEN(cosmetic_pieces) || loc != user)
		return FALSE
	var/list/stored = list()
	for(var/obj/item/clothing/piece as anything in cosmetic_pieces)
		stored["[piece.name] ([piece.cosmetic_hidden ? "hidden" : "shown"])"] = piece
	var/choice = browser_input_list(user, "Choose a decoration.", "Decorations", stored)
	var/obj/item/clothing/picked = stored[choice]
	if(!picked || picked.loc != src || loc != user)
		return TRUE
	var/action = browser_input_list(user, "What to do with [picked]?", "Decorations", list(picked.cosmetic_hidden ? "Show" : "Hide", "Take off"))
	if(!action || picked.loc != src || loc != user)
		return TRUE
	if(action == "Take off")
		user.put_in_hands(picked)
		return TRUE
	picked.cosmetic_hidden = !picked.cosmetic_hidden
	to_chat(user, span_info("[picked] will be [picked.cosmetic_hidden ? "hidden under" : "shown over"] [src]."))
	refresh_cosmetic_wearer()
	return TRUE

/obj/item/clothing/AltRightClick(mob/user, list/modifiers)
	if(ported_clothing && manage_cosmetic_pieces(user))
		return TRUE
	return ..()

/obj/item/clothing/get_examine_name(mob/user, use_article = TRUE)
	. = ..()
	if(!LAZYLEN(cosmetic_pieces))
		return
	var/list/shown = list()
	for(var/obj/item/clothing/piece as anything in cosmetic_pieces)
		if(!piece.cosmetic_hidden)
			shown += piece.name
	if(length(shown))
		. += " ([shown.Join(", ")])"

/obj/item/clothing/build_worn_icon(age = AGE_ADULT, default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, coom = FALSE, customi = null, sleeveindex, breast_size = 0, icon/clip_mask = null)
	var/mutable_appearance/standing = ..()
	if(isinhands || !standing || !LAZYLEN(cosmetic_pieces))
		return standing
	for(var/obj/item/clothing/piece as anything in cosmetic_pieces)
		if(piece.cosmetic_hidden)
			continue
		var/mutable_appearance/layered = piece.build_worn_icon(age, default_layer, piece.mob_overlay_icon, FALSE, femaleuniform, null, coom, customi, sleeveindex, breast_size, clip_mask)
		if(!layered)
			continue
		layered.appearance_flags |= RESET_COLOR
		layered.pixel_x -= standing.pixel_x
		layered.pixel_y -= standing.pixel_y
		standing.overlays += layered
	return standing

#undef PORTED_COSMETIC_CAPACITY

// ---------------------------------------------------------------------------
// Middle-click layer and visibility toggles
// ---------------------------------------------------------------------------

/// True when the ported middle-click toggle should run instead of the base handling (sleeves, parents' own clicks).
/obj/item/clothing/proc/use_layer_toggle(mob/living/user, list/modifiers)
	if(!ported_clothing || !layer_toggle || !istype(user))
		return FALSE
	if(nodismemsleeves)
		return TRUE
	if(LAZYACCESS(modifiers, ALT_CLICKED))
		return (l_sleeve_status == SLEEVE_NOMOD && r_sleeve_status == SLEEVE_NOMOD)
	if(user.zone_selected == l_sleeve_zone && l_sleeve_status != SLEEVE_NOMOD)
		return FALSE
	if(user.zone_selected == r_sleeve_zone && r_sleeve_status != SLEEVE_NOMOD)
		return FALSE
	return TRUE

/obj/item/clothing/cloak/MiddleClick(mob/living/user, list/modifiers)
	if(!use_layer_toggle(user, modifiers))
		return ..()
	layer_flipped = !layer_flipped
	alternate_worn_layer = layer_flipped ? UNDER_ARMOR_LAYER : initial(alternate_worn_layer)
	to_chat(user, span_info("I wear [src] [layer_flipped ? "under" : "over"] my armor."))
	user.update_inv_cloak()
	user.update_inv_armor()
	user.update_inv_back()

/obj/item/clothing/wrists/MiddleClick(mob/living/user, list/modifiers)
	if(!use_layer_toggle(user, modifiers))
		return ..()
	layer_flipped = !layer_flipped
	alternate_worn_layer = layer_flipped ? (ARMOR_LAYER - 0.5) : initial(alternate_worn_layer)
	to_chat(user, span_info("I wear [src] [layer_flipped ? "over" : "under"] my armor."))
	user.update_inv_wrists()
	user.update_inv_gloves()
	user.update_inv_armor()
	user.update_inv_shirt()

/obj/item/clothing/ring/MiddleClick(mob/living/user, list/modifiers)
	if(!use_layer_toggle(user, modifiers))
		return ..()
	layer_flipped = !layer_flipped
	alternate_worn_layer = layer_flipped ? UNDER_ARMOR_LAYER : initial(alternate_worn_layer)
	to_chat(user, span_info("I wear [src] [layer_flipped ? "under" : "over"] my sleeves."))
	user.update_inv_ring()
	user.update_inv_gloves()

/obj/item/clothing/face/MiddleClick(mob/living/user, list/modifiers)
	if(!use_layer_toggle(user, modifiers))
		return ..()
	layer_flipped = !layer_flipped
	alternate_worn_layer = layer_flipped ? (HAIR_LAYER + 0.5) : initial(alternate_worn_layer)
	to_chat(user, span_info("I wear [src] [layer_flipped ? "under" : "over"] my hair."))
	user.update_inv_wear_mask()

/obj/item/clothing/face/AltRightClick(mob/user, list/modifiers)
	if(!ported_clothing || loc != user || LAZYLEN(cosmetic_pieces))
		return ..()
	var/snout_state = "[initial(icon_state)]_snout"
	if(!snouted && !(mob_overlay_icon && icon_exists(mob_overlay_icon, snout_state)))
		return ..()
	snouted = !snouted
	icon_state = snouted ? snout_state : initial(icon_state)
	to_chat(user, span_info("I adjust [src] to fit [snouted ? "a snout" : "a flat face"]."))
	update_appearance()
	user.update_inv_wear_mask()
	return TRUE

/// Cycles: hair and ears tucked -> ears out -> hair out -> tucked again.
/obj/item/clothing/head/MiddleClick(mob/living/user, list/modifiers)
	if(!use_layer_toggle(user, modifiers) || !ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user
	switch(flags_inv & (HIDEEARS|HIDEHAIR))
		if(HIDEEARS|HIDEHAIR)
			flags_inv &= ~HIDEEARS
			to_chat(user, span_info("I free my ears from under [src]."))
		if(HIDEHAIR)
			flags_inv &= ~HIDEHAIR
			to_chat(user, span_info("I pull my hair out from under [src]."))
		else
			flags_inv |= (HIDEEARS|HIDEHAIR)
			to_chat(user, span_info("I tuck my hair and ears under [src]."))
	if(H.head == src)
		H.head_update(src, TRUE)
		H.update_inv_head()

/obj/item/clothing/head/roguehood/AltRightClick(mob/user, list/modifiers)
	if(!ported_clothing || loc != user)
		return ..()
	if(manage_cosmetic_pieces(user))
		return TRUE
	layer_flipped = !layer_flipped
	alternate_worn_layer = layer_flipped ? (HAIR_LAYER - 0.5) : initial(alternate_worn_layer)
	to_chat(user, span_info("I wear [src] [layer_flipped ? "over" : "under"] my hair."))
	user.update_inv_head()
	return TRUE

// ---------------------------------------------------------------------------
// Ported holy symbols: pray with middle-click, some can be worn around the wrist
// ---------------------------------------------------------------------------

/obj/item/clothing/neck/psycross
	/// Worn-sprite file used while the amulet is wrapped around the wrist. Null if it has no wrist sprites.
	var/wrist_mob_icon
	var/wrist_display = FALSE

/obj/item/clothing/neck/psycross/MiddleClick(mob/living/user, list/modifiers)
	if(!ported_clothing || !ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user
	if(!(/mob/living/carbon/human/proc/clericpray in H.verbs))
		to_chat(user, span_warning("I don't know the proper prayers."))
		return
	H.changeNext_move(CLICK_CD_MELEE)
	H.clericpray()

/obj/item/clothing/neck/psycross/attack_hand_secondary(mob/user, list/modifiers)
	if(!ported_clothing || !wrist_mob_icon || loc != user)
		return ..()
	wrist_display = !wrist_display
	mob_overlay_icon = wrist_display ? wrist_mob_icon : initial(mob_overlay_icon)
	sleeved = wrist_display ? wrist_mob_icon : initial(sleeved)
	to_chat(user, span_info("I adjust [src] to hang [wrist_display ? "from my wrist" : "around my neck"]."))
	user.regenerate_clothes()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// ---------------------------------------------------------------------------
// Mechanics hints (examine -> mechanics), ported clothing only
// ---------------------------------------------------------------------------

/obj/item/clothing/get_mechanics_examine(mob/user)
	. = ..()
	if(!ported_clothing)
		return
	if(hoodtype)
		. += span_info("Right-click it while worn to raise or lower the hood.")
	else if(ported_adjust && adjustable > 0)
		. += span_info("Right-click it while worn to adjust how it is worn - raise a visor, loosen a coif, open a robe.")
	if(!nodismemsleeves && salvage_result && (r_sleeve_status != SLEEVE_NOMOD || l_sleeve_status != SLEEVE_NOMOD))
		. += span_info("Middle-click it while targeting a sleeve or leg to tear that part off for a scrap of material; Alt+middle-click rolls it up or down. Tearing success scales with Strength.")
	if(cosmetic_slots())
		. += span_info("Drag a light piece of clothing from your hand onto [src] while wearing it to layer it over as a decoration. Alt+RMB lets you show, hide or take off those pieces.")
	if(dyeable || sewrepair)
		. += span_info("It can be dyed in a dye bin[get_detail_tag() ? ", accents included" : ""].")
	if(hint_decorate)
		. += span_info("It can be decorated by clicking it with a feather or a piece of cloth.")
	if(hint_pattern)
		. += span_info("Right-click it to pick its pattern and colouring.")
	if(layer_toggle && is_layer_toggle_type())
		. += span_info("Middle-click it to [layer_toggle_hint()].")

/obj/item/clothing/proc/is_layer_toggle_type()
	return istype(src, /obj/item/clothing/cloak) || istype(src, /obj/item/clothing/wrists) || istype(src, /obj/item/clothing/ring) || istype(src, /obj/item/clothing/face) || istype(src, /obj/item/clothing/head)

/obj/item/clothing/proc/layer_toggle_hint()
	if(istype(src, /obj/item/clothing/cloak))
		return "wear it over or under your armor"
	if(istype(src, /obj/item/clothing/wrists))
		return "wear it over or under your armor and gloves"
	if(istype(src, /obj/item/clothing/ring))
		return "wear it over or under your sleeves"
	if(istype(src, /obj/item/clothing/face))
		return "wear it over or under your hair"
	return "cycle whether your ears and hair show from under it"

/obj/item/clothing/head/roguehood/get_mechanics_examine(mob/user)
	. = ..()
	if(ported_clothing)
		. += span_info("Alt+RMB while worn moves the hood under or over your hair.")

/obj/item/clothing/face/get_mechanics_examine(mob/user)
	. = ..()
	if(ported_clothing && mob_overlay_icon && icon_exists(mob_overlay_icon, "[initial(icon_state)]_snout"))
		. += span_info("Alt+RMB while worn swaps between the snouted and the flat-faced fit.")

/obj/item/clothing/neck/psycross/get_mechanics_examine(mob/user)
	. = ..()
	if(!ported_clothing)
		return
	. += span_info("Middle-click it to kneel in prayer, if you know the prayers.")
	if(wrist_mob_icon)
		. += span_info("Right-click it while worn to wear it around your wrist instead of your neck.")

/obj/item/clothing/gloves/get_mechanics_examine(mob/user)
	. = ..()
	if(ported_clothing && unarmed_bonus != 1)
		. += span_notice("Unarmed damage while worn: x[unarmed_bonus].")

/obj/item/clothing/shoes/get_mechanics_examine(mob/user)
	. = ..()
	if(ported_clothing && istype(GetComponent(/datum/component/storage), /datum/component/storage/concrete/boots))
		. += span_info("It can hide a knife, a coin or a key. Click it with one to slip it in; right-click it to draw it back out.")

/// Ported spectacles and goggles: frames and lenses, not a helmet visor.
/datum/armor/ported/spectacles
	blunt = DR_LIGHT
	slash = DBLOCK_LIGHT
	stab = DBLOCK_LIGHT
	piercing = DBLOCK_NONE
	fire = DR_NONE
	acid = DR_NONE

/// Nobility gate shared by ported loadout entries: the Nobility virtue, or a noble, keep or townhall job set to high.
/proc/ported_loadout_noble_check(mob/C)
	var/datum/preferences/P = C?.client?.prefs
	if(!P)
		return FALSE
	if(HAS_TRAIT(P, TRAIT_NOBLE))
		return TRUE
	for(var/job_title in GLOB.lords_positions + GLOB.keep_positions + GLOB.townhall_positions)
		if(P.job_preferences[job_title] == JP_HIGH)
			return TRUE
	return FALSE

/datum/armor/ported/padded
	blunt = DR_SUPER
	slash = DBLOCK_MEDIUM
	stab = DBLOCK_LIGHT
	piercing = DBLOCK_BSTEEL
	fire = DR_LIGHT
	acid = DR_NONE

/datum/armor/ported/leather
	blunt = DR_ULTRA
	slash = DBLOCK_MEDIUM
	stab = DBLOCK_MEDIUM
	piercing = DBLOCK_HEAVY
	fire = DR_MEDIUM
	acid = DR_NONE

/datum/armor/ported/bronze
	blunt = DR_MEDIUM
	slash = DBLOCK_MEDIUM
	stab = DBLOCK_MEDIUM
	piercing = DBLOCK_MEDIUM
	fire = DR_MEDIUM
	acid = DR_NONE

/datum/armor/ported/plate_bsteel
	blunt = DR_MEDIUM
	slash = DBLOCK_BSTEEL
	stab = DBLOCK_BSTEEL
	piercing = DBLOCK_BSTEEL
	fire = DR_LIGHT
	acid = DR_NONE

/datum/armor/ported/newmoon_hood
	blunt = DR_HEAVY
	slash = DBLOCK_BSTEEL
	stab = DBLOCK_BSTEEL
	piercing = DBLOCK_BSTEEL
	fire = DR_NONE
	acid = DR_NONE

/datum/armor/ported/insulated_brigandine
	blunt = DR_HEAVY
	slash = DBLOCK_HEAVY
	stab = DBLOCK_MEDIUM
	piercing = DBLOCK_HEAVY
	fire = DR_ULTRA
	acid = DR_NONE

/datum/armor/ported/newmoon_jacket
	blunt = DR_SUPER
	slash = DBLOCK_BSTEEL
	stab = DBLOCK_BSTEEL
	piercing = DBLOCK_BSTEEL
	fire = DR_NONE
	acid = DR_NONE

/datum/armor/ported/gnoll_standard
	blunt = DR_SUPER
	slash = DBLOCK_HEAVY
	stab = DBLOCK_HEAVY
	piercing = DBLOCK_HEAVY
	fire = DR_MEDIUM
	acid = DR_NONE

/datum/armor/ported/insulated_leather
	blunt = DR_ULTRA
	slash = DBLOCK_MEDIUM
	stab = DBLOCK_MEDIUM
	piercing = DBLOCK_HEAVY
	fire = DR_ULTRA
	acid = DR_NONE

/datum/armor/ported/gnoll_strong
	blunt = DR_MEDIUM
	slash = DBLOCK_BSTEEL
	stab = DBLOCK_BSTEEL
	piercing = DBLOCK_HEAVY
	fire = DR_MEDIUM
	acid = DR_NONE

/datum/armor/ported/gnoll_weak
	blunt = DR_ULTRA
	slash = DBLOCK_HEAVY
	stab = DBLOCK_HEAVY
	piercing = DBLOCK_MEDIUM
	fire = DR_MEDIUM
	acid = DR_NONE

