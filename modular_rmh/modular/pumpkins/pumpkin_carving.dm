// Emptied pumpkin shell, carved into a lantern through the PumpkinCarving window.

/obj/item/pumpkinshell
	name = "pumpkin shell"
	desc = "The emptied shell of a pumpkin, without its flesh and seeds."
	icon = 'modular_rmh/modular/pumpkins/icons/pumpkin_items.dmi'
	icon_state = "pumpkinshell"
	item_weight = 1 KILOGRAMS
	grid_width = 64
	grid_height = 32
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	sellprice = 1
	/// Set while a carve is in progress, so two carves cannot start at once.
	var/carving = FALSE

/obj/item/pumpkinshell/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use a small blade on it to carve a lantern.")

/obj/item/pumpkinshell/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.cmode || !can_carve_with(tool))
		return NONE
	ui_interact(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/pumpkinshell/proc/can_carve_with(obj/item/tool)
	return tool?.get_sharpness() && tool.wlength == WLENGTH_SHORT

/obj/item/pumpkinshell/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PumpkinCarving", "Carve [name]")
		ui.open()

/obj/item/pumpkinshell/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/pumpkin_carvings))

/obj/item/pumpkinshell/ui_static_data(mob/user)
	var/list/data = list()
	var/list/carvings = list()
	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/pumpkin_carvings)
	for(var/obj/item/flashlight/flare/torch/lantern/pumpkin/design as anything in pumpkin_carving_designs())
		carvings += list(list(
			"name" = initial(design.name),
			"path" = "[design]",
			"icon" = sheet.icon_class_name(pumpkin_carving_sprite(design)),
		))
	data["carvings"] = carvings
	return data

/obj/item/pumpkinshell/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || action != "choose_carving")
		return
	// The client sends text; only a real lantern design may be built from it.
	var/design = text2path(params["path"])
	if(!(design in pumpkin_carving_designs()))
		return TRUE
	var/mob/living/carver = ui.user
	if(!istype(carver))
		return TRUE
	ui.close()
	INVOKE_ASYNC(src, PROC_REF(carve), carver, design)
	return TRUE

/obj/item/pumpkinshell/proc/carve(mob/living/user, design)
	if(carving)
		return
	if(!can_carve_with(user.get_active_held_item()))
		to_chat(user, span_warning("I need a small blade in my hand to carve [src]."))
		return
	var/obj/item/design_path = design
	carving = TRUE
	user.visible_message(span_notice("[user] begins to carve [src]."), span_notice("I begin carving \a [initial(design_path.name)]."))
	var/success = do_after(user, 2 SECONDS, src)
	carving = FALSE
	if(!success || QDELETED(src) || !can_carve_with(user.get_active_held_item()))
		return
	playsound(src, 'sound/foley/slicing.ogg', 60, TRUE, -1)
	var/held = (loc == user)
	var/obj/item/lantern = new design(get_turf(src))
	qdel(src)
	if(held)
		user.put_in_hands(lantern)
	user.visible_message(span_notice("[user] carves [lantern]."), span_notice("I carve [lantern]."))

/proc/pumpkin_carving_sprite(design)
	return sanitize_css_class_name("carving[design]")

/proc/pumpkin_carving_designs()
	var/static/list/designs
	if(!designs)
		designs = list()
		for(var/obj/item/flashlight/flare/torch/lantern/pumpkin/design as anything in typesof(/obj/item/flashlight/flare/torch/lantern/pumpkin))
			if(!initial(design.start_lit))
				designs += design
	return designs

/datum/asset/spritesheet/pumpkin_carvings
	name = "pumpkin_carvings"
	load_immediately = TRUE

/datum/asset/spritesheet/pumpkin_carvings/create_spritesheets()
	for(var/obj/item/flashlight/flare/torch/lantern/pumpkin/design as anything in pumpkin_carving_designs())
		Insert(pumpkin_carving_sprite(design), initial(design.icon), initial(design.icon_state))
