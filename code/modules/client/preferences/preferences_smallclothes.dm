GLOBAL_LIST_EMPTY(selectable_undies)
GLOBAL_LIST_EMPTY(cached_undies_flat_icons)
GLOBAL_LIST_EMPTY(selectable_legwear)
GLOBAL_LIST_EMPTY(cached_legwear_flat_icons)
GLOBAL_LIST_EMPTY(selectable_bras)
GLOBAL_LIST_EMPTY(cached_bras_flat_icons)
GLOBAL_LIST_EMPTY(selectable_garters)
GLOBAL_LIST_EMPTY(cached_garters_flat_icons)
GLOBAL_LIST_EMPTY(selectable_undershirts)
GLOBAL_LIST_EMPTY(cached_undershirts_flat_icons)
GLOBAL_LIST_EMPTY(selectable_armsleeves)
GLOBAL_LIST_EMPTY(cached_armsleeves_flat_icons)

/proc/get_cached_undies_flat_icon(obj/item/clothing/undies/undie_type)
	var/cache_key = "[undie_type]"
	if(!GLOB.cached_undies_flat_icons[cache_key])
		var/image/dummy = image(initial(undie_type.icon), null, initial(undie_type.icon_state), initial(undie_type.layer))
		GLOB.cached_undies_flat_icons[cache_key] = "<img src='data:image/png;base64, [icon2base64(getFlatIcon(dummy))]'>"
	return GLOB.cached_undies_flat_icons[cache_key]

/proc/get_cached_legwear_flat_icon(obj/item/clothing/legwears_type)
	var/cache_key = "[legwears_type]"
	if(!GLOB.cached_legwear_flat_icons[cache_key])
		var/image/dummy = image(initial(legwears_type.icon), null, initial(legwears_type.icon_state), initial(legwears_type.layer))
		GLOB.cached_legwear_flat_icons[cache_key] = "<img src='data:image/png;base64, [icon2base64(getFlatIcon(dummy))]'>"
	return GLOB.cached_legwear_flat_icons[cache_key]

/proc/get_cached_bras_flat_icon(obj/item/clothing/bra/bra_type)
	var/cache_key = "[bra_type]"
	if(!GLOB.cached_bras_flat_icons[cache_key])
		var/image/dummy = image(initial(bra_type.icon), null, initial(bra_type.icon_state), initial(bra_type.layer))
		GLOB.cached_bras_flat_icons[cache_key] = "<img src='data:image/png;base64, [icon2base64(getFlatIcon(dummy))]'>"
	return GLOB.cached_bras_flat_icons[cache_key]

/proc/get_cached_garters_flat_icon(obj/item/clothing/garter/garter_type)
	var/cache_key = "[garter_type]"
	if(!GLOB.cached_garters_flat_icons[cache_key])
		var/image/dummy = image(initial(garter_type.icon), null, initial(garter_type.icon_state), initial(garter_type.layer))
		GLOB.cached_garters_flat_icons[cache_key] = "<img src='data:image/png;base64, [icon2base64(getFlatIcon(dummy))]'>"
	return GLOB.cached_garters_flat_icons[cache_key]

/proc/get_cached_undershirts_flat_icon(obj/item/clothing/undershirt/under_type)
	var/cache_key = "[under_type]"
	if(!GLOB.cached_undershirts_flat_icons[cache_key])
		var/image/dummy = image(initial(under_type.icon), null, initial(under_type.icon_state), initial(under_type.layer))
		GLOB.cached_undershirts_flat_icons[cache_key] = "<img src='data:image/png;base64, [icon2base64(getFlatIcon(dummy))]'>"
	return GLOB.cached_undershirts_flat_icons[cache_key]

/proc/get_cached_armsleeves_flat_icon(obj/item/clothing/armsleeves/armsleeve)
	var/cache_key = "[armsleeve]"
	if(!GLOB.cached_armsleeves_flat_icons[cache_key])
		var/image/dummy = image(initial(armsleeve.icon), null, initial(armsleeve.icon_state), initial(armsleeve.layer))
		GLOB.cached_armsleeves_flat_icons[cache_key] = "<img src='data:image/png;base64, [icon2base64(getFlatIcon(dummy))]'>"
	return GLOB.cached_armsleeves_flat_icons[cache_key]

/datum/preferences/proc/validate_smallclothes_preferences()
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(!smallclothes_preferences)
		smallclothes_preferences = list()

	if(!length(GLOB.selectable_undies))
		GLOB.selectable_undies = get_global_selectable_undies()

	if(!length(GLOB.selectable_legwear))
		GLOB.selectable_legwear = get_global_selectable_legwear()

	if(!length(GLOB.selectable_bras))
		GLOB.selectable_bras = get_global_selectable_bras()

	if(!length(GLOB.selectable_garters))
		GLOB.selectable_garters = get_global_selectable_garters()

	if(!length(GLOB.selectable_undershirts))
		GLOB.selectable_undershirts = get_global_selectable_undershirts()

	if(!length(GLOB.selectable_armsleeves))
		GLOB.selectable_armsleeves = get_global_selectable_armsleeves()

	if(!smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES] = FALSE

	if(!smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		if(!(smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] in GLOB.selectable_undies) && !isnull(smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES]))
			smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] = get_random_undie()

		if(!(smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] in GLOB.selectable_legwear) && !isnull(smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES]))
			smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] = get_random_legwear()

		if(!(smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES] in GLOB.selectable_bras) && !isnull(smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES]))
			smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES] = get_random_bra()

		if(!(smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES] in GLOB.selectable_garters) && !isnull(smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES]))
			smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES] = get_random_garter()

		if(!(smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES] in GLOB.selectable_undershirts) && !isnull(smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES]))
			smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES] = get_random_undershirt()

		if(!(smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES] in GLOB.selectable_armsleeves) && !isnull(smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES]))
			smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES] = get_random_armsleeve()
	else
		if(!smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES])
			smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] = get_random_undie()
		if(!smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES])
			smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] = get_random_legwear()
		if(!smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES])
			smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES] = get_random_bra()
		if(!smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES])
			smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES] = get_random_garter()
		if(!smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES])
			smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES] = get_random_undershirt()
		if(!smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES])
			smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES] = get_random_armsleeve()

	write_preference(/datum/preference/list_type/smallclothes_preferences, smallclothes_preferences)

/datum/preferences/proc/reset_smallclothes_preferences()
	var/list/smallclothes_preferences = list()
	smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES] = FALSE
	smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] = null
	smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] = null
	smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES] = null
	smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES] = null
	smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES] = null
	smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES] = null
	write_preference(/datum/preference/list_type/smallclothes_preferences, smallclothes_preferences)

/datum/preferences/proc/get_default_undie()
	return /obj/item/clothing/undies

/datum/preferences/proc/get_default_legwear()
	return /obj/item/clothing/legwears

/datum/preferences/proc/get_default_bra()
	return /obj/item/clothing/bra

/datum/preferences/proc/get_default_garter()
	return /obj/item/clothing/garter

/datum/preferences/proc/get_default_undershirt()
	return /obj/item/clothing/undershirt

/datum/preferences/proc/get_default_armsleeve()
	return /obj/item/clothing/armsleeves

/datum/preferences/proc/get_random_undie()
	if(!length(GLOB.selectable_undies))
		GLOB.selectable_undies = get_global_selectable_undies()
	var/list/choices = GLOB.selectable_undies
	return pick(choices)

/datum/preferences/proc/get_random_legwear()
	if(!length(GLOB.selectable_legwear))
		GLOB.selectable_legwear = get_global_selectable_legwear()
	var/list/choices = GLOB.selectable_legwear
	return pick(choices)

/datum/preferences/proc/get_random_bra()
	if(!length(GLOB.selectable_bras))
		GLOB.selectable_bras = get_global_selectable_bras()
	var/list/choices = GLOB.selectable_bras
	return pick(choices)

/datum/preferences/proc/get_random_garter()
	if(!length(GLOB.selectable_garters))
		GLOB.selectable_garters = get_global_selectable_garters()
	var/list/choices = GLOB.selectable_garters
	return pick(choices)

/datum/preferences/proc/get_random_undershirt()
	if(!length(GLOB.selectable_undershirts))
		GLOB.selectable_undershirts = get_global_selectable_undershirts()
	var/list/choices = GLOB.selectable_undershirts
	return pick(choices)

/datum/preferences/proc/get_random_armsleeve()
	if(!length(GLOB.selectable_armsleeves))
		GLOB.selectable_armsleeves = get_global_selectable_armsleeves()
	var/list/choices = GLOB.selectable_armsleeves
	return pick(choices)

/datum/preferences/proc/handle_undies_topic(mob/user, href_list)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	//update_preview_icon()
	switch(href_list["preference"])
		if("toggle_random_smallclothes")
			var/current_random = smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES]
			smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES] = !current_random
			if(smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
				to_chat(user, span_notice("Random smallclothes preferences enabled. Your smallclothes preferences will be randomized."))
			else
				to_chat(user, span_notice("Random smallclothes disabled. You can now manually choose your preferences."))
			show_smallclothes_ui(user)
		if("choose_undie")
			show_undie_selection_ui(user, SMALCLOTHES_UNDIE_PREFERENCES)
		if("choose_legwear")
			show_legwear_selection_ui(user, SMALCLOTHES_LEGWEAR_PREFERENCES)
		if("confirm_undie")
			var/undie_type = text2path(href_list["undie_type"])
			var/preference_type = href_list["preference_type"]
			if(ispath(undie_type, /obj/item/clothing/undies) && (undie_type in GLOB.selectable_undies) || isnull(undie_type))
				smallclothes_preferences[preference_type] = undie_type
				user << browse(null, "window=undie_selection")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("confirm_legwear")
			var/legwear_type = text2path(href_list["legwear_type"])
			var/preference_type = href_list["preference_type"]
			if(ispath(legwear_type, /obj/item/clothing/legwears) && (legwear_type in GLOB.selectable_legwear) || isnull(legwear_type))
				smallclothes_preferences[preference_type] = legwear_type
				user << browse(null, "window=legwear_selection")
				update_preview_icon()
				show_smallclothes_ui(user)
		if("undie_color")
			var/undie_type = text2path(href_list["undie_type"])
			var/preference_type = href_list["preference_type"]
			if(!isnull(undie_type))
				var/choice = input(user, "Choose a color.", "Underwear Colour") as null|anything in GLOB.colorlist
				if (choice)
					var/selected_value = GLOB.colorlist[choice]
					if(selected_value == "CUSTOM_RGB")
						var/current_color = smallclothes_preferences[preference_type]||"#FFFFFF"
						var/new_color = tgui_color_picker(user, "Select color:", "Custom Color", sanitize_hexcolor(current_color, 6, TRUE, "#ffffff"))
						if(new_color)
							smallclothes_preferences[preference_type] = sanitize_hexcolor(new_color, include_crunch=1)
					else
						smallclothes_preferences[preference_type] = GLOB.colorlist[choice]
					to_chat(user, "The colour for your underwear has been set to <b>[choice].</b>.")
				else
					smallclothes_preferences[preference_type] = null
					to_chat(user, "The colour for your underwear loadout item has been cleared.")
				update_preview_icon()
				show_smallclothes_ui(user)
		if("legwear_color")
			var/legwear_type = text2path(href_list["legwear_type"])
			var/preference_type = href_list["preference_type"]
			if(!isnull(legwear_type))
				var/choice = input(user, "Choose a color.", "Legwear Colour") as null|anything in GLOB.colorlist
				if (choice)
					var/selected_value = GLOB.colorlist[choice]
					if(selected_value == "CUSTOM_RGB")
						var/current_color = smallclothes_preferences[preference_type]||"#FFFFFF"
						var/new_color = tgui_color_picker(user, "Select color:", "Custom Color", sanitize_hexcolor(current_color, 6, TRUE, "#ffffff"))
						if(new_color)
							smallclothes_preferences[preference_type] = sanitize_hexcolor(new_color, include_crunch=1)
					else
						smallclothes_preferences[preference_type] = GLOB.colorlist[choice]
					to_chat(user, "The colour for your legwear has been set to <b>[choice].</b>.")
				else
					smallclothes_preferences[preference_type] = null
					to_chat(user, "The colour for your legwear loadout item has been cleared.")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("choose_bra")
			show_bra_selection_ui(user, SMALCLOTHES_BRA_PREFERENCES)
		if("choose_garter")
			show_garter_selection_ui(user, SMALCLOTHES_GARTER_PREFERENCES)
		if("choose_undershirt")
			show_undershirt_selection_ui(user, SMALCLOTHES_UNDERSHIRT_PREFERENCES)
		if("choose_armsleeve")
			show_armsleeve_selection_ui(user, SMALCLOTHES_ARMSLEEVE_PREFERENCES)

		if("confirm_bra")
			var/bra_type = text2path(href_list["bra_type"])
			var/preference_type = href_list["preference_type"]
			if(ispath(bra_type, /obj/item/clothing/bra) && (bra_type in GLOB.selectable_bras) || isnull(bra_type))
				smallclothes_preferences[preference_type] = bra_type
				user << browse(null, "window=bra_selection")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("confirm_garter")
			var/garter_type = text2path(href_list["garter_type"])
			var/preference_type = href_list["preference_type"]
			if(ispath(garter_type, /obj/item/clothing/garter) && (garter_type in GLOB.selectable_garters) || isnull(garter_type))
				smallclothes_preferences[preference_type] = garter_type
				user << browse(null, "window=garter_selection")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("confirm_undershirt")
			var/undershirt_type = text2path(href_list["undershirt_type"])
			var/preference_type = href_list["preference_type"]
			if(ispath(undershirt_type, /obj/item/clothing/undershirt) && (undershirt_type in GLOB.selectable_undershirts) || isnull(undershirt_type))
				smallclothes_preferences[preference_type] = undershirt_type
				user << browse(null, "window=undershirt_selection")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("confirm_armsleeve")
			var/armsleeve_type = text2path(href_list["armsleeve_type"])
			var/preference_type = href_list["preference_type"]
			if(ispath(armsleeve_type, /obj/item/clothing/armsleeves) && (armsleeve_type in GLOB.selectable_armsleeves) || isnull(armsleeve_type))
				smallclothes_preferences[preference_type] = armsleeve_type
				user << browse(null, "window=armsleeve_selection")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("bra_color")
			var/bra_type = text2path(href_list["bra_type"])
			var/preference_type = href_list["preference_type"]
			if(!isnull(bra_type))
				var/choice = input(user, "Choose a color.", "Bra Colour") as null|anything in GLOB.colorlist
				if (choice && GLOB.colorlist[choice])
					smallclothes_preferences[preference_type] = GLOB.colorlist[choice]
					to_chat(user, "The colour for your bra has been set to <b>[choice].</b>.")
				else
					smallclothes_preferences[preference_type] = null
					to_chat(user, "The colour for your bra loadout item has been cleared.")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("garter_color")
			var/garter_type = text2path(href_list["garter_type"])
			var/preference_type = href_list["preference_type"]
			if(!isnull(garter_type))
				var/choice = input(user, "Choose a color.", "Garter Colour") as null|anything in GLOB.colorlist
				if (choice && GLOB.colorlist[choice])
					smallclothes_preferences[preference_type] = GLOB.colorlist[choice]
					to_chat(user, "The colour for your garter has been set to <b>[choice].</b>.")
				else
					smallclothes_preferences[preference_type] = null
					to_chat(user, "The colour for your garter loadout item has been cleared.")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("undershirt_color")
			var/undershirt_type = text2path(href_list["undershirt_type"])
			var/preference_type = href_list["preference_type"]
			if(!isnull(undershirt_type))
				var/choice = input(user, "Choose a color.", "Undershirt Colour") as null|anything in GLOB.colorlist
				if (choice && GLOB.colorlist[choice])
					smallclothes_preferences[preference_type] = GLOB.colorlist[choice]
					to_chat(user, "The colour for your undershirt has been set to <b>[choice].</b>.")
				else
					smallclothes_preferences[preference_type] = null
					to_chat(user, "The colour for your undershirt loadout item has been cleared.")
				update_preview_icon()
				show_smallclothes_ui(user)

		if("armsleeve_color")
			var/armsleeve_type = text2path(href_list["armsleeve_type"])
			var/preference_type = href_list["preference_type"]
			if(!isnull(armsleeve_type))
				var/choice = input(user, "Choose a color.", "armsleeve Colour") as null|anything in GLOB.colorlist
				if (choice && GLOB.colorlist[choice])
					smallclothes_preferences[preference_type] = GLOB.colorlist[choice]
					to_chat(user, "The colour for your armsleeve has been set to <b>[choice].</b>.")
				else
					smallclothes_preferences[preference_type] = null
					to_chat(user, "The colour for your armsleeve loadout item has been cleared.")
				update_preview_icon()
				show_smallclothes_ui(user)
	write_preference(/datum/preference/list_type/smallclothes_preferences, smallclothes_preferences)


/datum/preferences/proc/print_smallclothes_page(mob/user)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(!length(GLOB.selectable_undies))
		GLOB.selectable_undies = get_global_selectable_undies()
	if(!length(GLOB.selectable_legwear))
		GLOB.selectable_legwear = get_global_selectable_legwear()
	if(!length(GLOB.selectable_bras))
		GLOB.selectable_bras = get_global_selectable_bras()
	if(!length(GLOB.selectable_garters))
		GLOB.selectable_garters = get_global_selectable_garters()
	if(!length(GLOB.selectable_undershirts))
		GLOB.selectable_undershirts = get_global_selectable_undershirts()
	if(!length(GLOB.selectable_armsleeves))
		GLOB.selectable_armsleeves = get_global_selectable_armsleeves()
	var/list/dat = list()

	var/current_undie = smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES]
	var/current_legwear = smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES]
	var/current_bra = smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES]
	var/current_garter = smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES]
	var/current_undershirt = smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES]
	var/current_armsleeve = smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES]
	var/random_preferences = smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES]

	var/bra_name = "None"
	var/bra_icon = ""
	var/bra_color
	if(current_bra && !random_preferences)
		var/obj/item/clothing/bra/bra_instance = current_bra
		bra_name = capitalize(initial(bra_instance.name))
		bra_icon = get_cached_bras_flat_icon(current_bra)
		bra_color = smallclothes_preferences[SMALCLOTHES_BRA_COLOR_PREFERENCES]
	else if(random_preferences)
		bra_name = "Random"

	var/garter_name = "None"
	var/garter_icon = ""
	var/garter_color
	if(current_garter && !random_preferences)
		var/obj/item/clothing/garter/garter_instance = current_garter
		garter_name = capitalize(initial(garter_instance.name))
		garter_icon = get_cached_garters_flat_icon(current_garter)
		garter_color = smallclothes_preferences[SMALCLOTHES_GARTER_COLOR_PREFERENCES]
	else if(random_preferences)
		garter_name = "Random"

	var/undershirt_name = "None"
	var/undershirt_icon = ""
	var/undershirt_color
	if(current_undershirt && !random_preferences)
		var/obj/item/clothing/undershirt/undershirt_instance = current_undershirt
		undershirt_name = capitalize(initial(undershirt_instance.name))
		undershirt_icon = get_cached_undershirts_flat_icon(current_undershirt)
		undershirt_color = smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_COLOR_PREFERENCES]
	else if(random_preferences)
		undershirt_name = "Random"

	var/armsleeve_name = "None"
	var/armsleeve_icon = ""
	var/armsleeve_color
	if(current_armsleeve && !random_preferences)
		var/obj/item/clothing/armsleeves/armsleeve_instance = current_armsleeve
		armsleeve_name = capitalize(initial(armsleeve_instance.name))
		armsleeve_icon = get_cached_armsleeves_flat_icon(current_armsleeve)
		armsleeve_color = smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_COLOR_PREFERENCES]
	else if(random_preferences)
		armsleeve_name = "Random"

	var/undie_name = "None"
	var/undie_icon = ""
	var/undie_color
	if(current_undie && !random_preferences)
		var/obj/item/clothing/undies/undie_instance = current_undie
		undie_name = capitalize(initial(undie_instance.name))
		undie_icon = get_cached_undies_flat_icon(current_undie)
		undie_color = smallclothes_preferences[SMALCLOTHES_UNDIE_COLOR_PREFERENCES]
	else if(random_preferences)
		undie_name = "Random"

	var/legwear_name = "None"
	var/legwear_icon = ""
	var/legwear_color
	if(current_legwear && !random_preferences)
		var/obj/item/clothing/legwears/legwear_instance = current_legwear
		legwear_name = capitalize(initial(legwear_instance.name))
		legwear_icon = get_cached_legwear_flat_icon(current_legwear)
		legwear_color = smallclothes_preferences[SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES]
	else if(random_preferences)
		legwear_name = "Random"

	dat += "<style>"
	dat += ".smallclothes-item { display: flex; align-items: center; margin-bottom: 5px; }"
	dat += ".smallclothes-icon { vertical-align: middle; }"
	dat += ".smallclothes-text { vertical-align: middle; line-height: 32px; }"
	dat += ".random-toggle { margin-bottom: 10px; padding: 5px; background: #2a2a2a; border-radius: 3px; }"
	dat += "</style>"

	dat += "<div class='random-toggle'>"
	dat += "<b>Random Preferences:</b> <a href='byond://?_src_=prefs;preference=toggle_random_smallclothes;task=change_smallclothes_preferences'>[random_preferences ? "Enabled" : "Disabled"]</a>"
	dat += "<br>When enabled, will give you random underwear."
	dat += "</div>"

	dat += "<div [random_preferences ? "" : "class='smallclothes-item'"]><b>Underwear: </b> <span class='smallclothes-icon'>[undie_icon]</span> <span class='smallclothes-text'>"
	if(random_preferences)
		dat += "<font color='orange'>[encode_special_chars(undie_name)]</font>"
	else
		dat += "<a href='byond://?_src_=prefs;preference=choose_undie;preference_type=[SMALCLOTHES_UNDIE_PREFERENCES];task=change_smallclothes_preferences'>[encode_special_chars(undie_name)]</a>"
	if (undie_color)
		dat += "<a href='byond://?_src_=prefs;undie_type=[current_undie];preference=undie_color;preference_type=[SMALCLOTHES_UNDIE_COLOR_PREFERENCES];task=change_smallclothes_preferences'> <span style='border: 1px solid #161616; background-color: [undie_color ? undie_color : "#FFFFFF"];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a>"
	else
		dat += "<a href='byond://?_src_=prefs;undie_type=[current_undie];preference=undie_color;preference_type=[SMALCLOTHES_UNDIE_COLOR_PREFERENCES];task=change_smallclothes_preferences'>(Select color)</a>"
	dat += "</span></div>"

	dat += "<div [random_preferences ? "" : "class='smallclothes-item'"]><b>Legwear: </b> <span class='smallclothes-icon'>[legwear_icon]</span> <span class='smallclothes-text'>"
	if(random_preferences)
		dat += "<font color='orange'>[encode_special_chars(legwear_name)]</font>"
	else
		dat += "<a href='byond://?_src_=prefs;preference=choose_legwear;preference_type=[SMALCLOTHES_LEGWEAR_PREFERENCES];task=change_smallclothes_preferences'>[encode_special_chars(legwear_name)]</a>"
	if (legwear_color)
		dat += "<a href='byond://?_src_=prefs;legwear_type=[current_legwear];preference=legwear_color;preference_type=[SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES];task=change_smallclothes_preferences'> <span style='border: 1px solid #161616; background-color: [legwear_color ? legwear_color : "#FFFFFF"];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a>"
	else
		dat += "<a href='byond://?_src_=prefs;legwear_type=[current_legwear];preference=legwear_color;preference_type=[SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES];task=change_smallclothes_preferences'>(Select color)</a>"
	dat += "</span></div>"

	dat += "<div [random_preferences ? "" : "class='smallclothes-item'"]><b>Bra: </b> <span class='smallclothes-icon'>[bra_icon]</span> <span class='smallclothes-text'>"
	if(random_preferences)
		dat += "<font color='orange'>[encode_special_chars(bra_name)]</font>"
	else
		dat += "<a href='byond://?_src_=prefs;preference=choose_bra;preference_type=[SMALCLOTHES_BRA_PREFERENCES];task=change_smallclothes_preferences'>[encode_special_chars(bra_name)]</a>"
	if (bra_color)
		dat += "<a href='byond://?_src_=prefs;bra_type=[current_bra];preference=bra_color;preference_type=[SMALCLOTHES_BRA_COLOR_PREFERENCES];task=change_smallclothes_preferences'> <span style='border: 1px solid #161616; background-color: [bra_color ? bra_color : "#FFFFFF"];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a>"
	else
		dat += "<a href='byond://?_src_=prefs;bra_type=[current_bra];preference=bra_color;preference_type=[SMALCLOTHES_BRA_COLOR_PREFERENCES];task=change_smallclothes_preferences'>(Select color)</a>"
	dat += "</span></div>"

	dat += "<div [random_preferences ? "" : "class='smallclothes-item'"]><b>Garter: </b> <span class='smallclothes-icon'>[garter_icon]</span> <span class='smallclothes-text'>"
	if(random_preferences)
		dat += "<font color='orange'>[encode_special_chars(garter_name)]</font>"
	else
		dat += "<a href='byond://?_src_=prefs;preference=choose_garter;preference_type=[SMALCLOTHES_GARTER_PREFERENCES];task=change_smallclothes_preferences'>[encode_special_chars(garter_name)]</a>"
	if (garter_color)
		dat += "<a href='byond://?_src_=prefs;garter_type=[current_garter];preference=garter_color;preference_type=[SMALCLOTHES_GARTER_COLOR_PREFERENCES];task=change_smallclothes_preferences'> <span style='border: 1px solid #161616; background-color: [garter_color ? garter_color : "#FFFFFF"];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a>"
	else
		dat += "<a href='byond://?_src_=prefs;garter_type=[current_garter];preference=garter_color;preference_type=[SMALCLOTHES_GARTER_COLOR_PREFERENCES];task=change_smallclothes_preferences'>(Select color)</a>"
	dat += "</span></div>"

	dat += "<div [random_preferences ? "" : "class='smallclothes-item'"]><b>Undershirt: </b> <span class='smallclothes-icon'>[undershirt_icon]</span> <span class='smallclothes-text'>"
	if(random_preferences)
		dat += "<font color='orange'>[encode_special_chars(undershirt_name)]</font>"
	else
		dat += "<a href='byond://?_src_=prefs;preference=choose_undershirt;preference_type=[SMALCLOTHES_UNDERSHIRT_PREFERENCES];task=change_smallclothes_preferences'>[encode_special_chars(undershirt_name)]</a>"
	if (undershirt_color)
		dat += "<a href='byond://?_src_=prefs;undershirt_type=[current_undershirt];preference=undershirt_color;preference_type=[SMALCLOTHES_UNDERSHIRT_COLOR_PREFERENCES];task=change_smallclothes_preferences'> <span style='border: 1px solid #161616; background-color: [undershirt_color ? undershirt_color : "#FFFFFF"];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a>"
	else
		dat += "<a href='byond://?_src_=prefs;undershirt_type=[current_undershirt];preference=undershirt_color;preference_type=[SMALCLOTHES_UNDERSHIRT_COLOR_PREFERENCES];task=change_smallclothes_preferences'>(Select color)</a>"
	dat += "</span></div>"

	dat += "<div [random_preferences ? "" : "class='smallclothes-item'"]><b>Armsleeves: </b> <span class='smallclothes-icon'>[armsleeve_icon]</span> <span class='smallclothes-text'>"
	if(random_preferences)
		dat += "<font color='orange'>[encode_special_chars(armsleeve_name)]</font>"
	else
		dat += "<a href='byond://?_src_=prefs;preference=choose_armsleeve;preference_type=[SMALCLOTHES_ARMSLEEVE_PREFERENCES];task=change_smallclothes_preferences'>[encode_special_chars(armsleeve_name)]</a>"
	if (armsleeve_color)
		dat += "<a href='byond://?_src_=prefs;armsleeve_type=[current_armsleeve];preference=armsleeve_color;preference_type=[SMALCLOTHES_ARMSLEEVE_COLOR_PREFERENCES];task=change_smallclothes_preferences'> <span style='border: 1px solid #161616; background-color: [armsleeve_color ? armsleeve_color : "#FFFFFF"];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a>"
	else
		dat += "<a href='byond://?_src_=prefs;armsleeve_type=[current_armsleeve];preference=armsleeve_color;preference_type=[SMALCLOTHES_ARMSLEEVE_COLOR_PREFERENCES];task=change_smallclothes_preferences'>(Select color)</a>"
	dat += "</span></div>"
	return dat

/datum/preferences/proc/show_smallclothes_ui(mob/user)
	var/list/dat = list()
	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	dat += print_smallclothes_page(user)
	var/datum/browser/popup = new(user, "smallclothes_customization", "<div align='center'>Smallclothes Preferences</div>", 360, 365)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/apply_smallclothes_preferences(mob/living/carbon/human/character)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(!smallclothes_preferences)
		return

	character.smallclothes_preferences = smallclothes_preferences.Copy()

	if(character.smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		character.smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] = get_random_undie()
		character.smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] = get_random_legwear()
		character.smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES] = get_random_bra()
		character.smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES] = get_random_garter()
		character.smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES] = get_random_undershirt()
		character.smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES] = get_random_armsleeve()

	var/current_undie = character.smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES]
	var/obj/item/clothing/undies/old_u = character.underwear
	if(old_u)
		character.dropItemToGround(old_u)
		qdel(old_u)
	if(current_undie)
		var/obj/item/clothing/undies/U = new current_undie
		U.color = smallclothes_preferences[SMALCLOTHES_UNDIE_COLOR_PREFERENCES]
		character.equip_to_slot_if_possible(U, ITEM_SLOT_UNDER_BOTTOM, TRUE, disable_warning = TRUE)


	var/current_legwear = character.smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES]
	var/obj/item/clothing/legwears/old_l = character.legwear_socks
	if(old_l)
		character.dropItemToGround(old_l)
		qdel(old_l)
	if(current_legwear)
		var/obj/item/clothing/legwears/L = new current_legwear
		L.color = smallclothes_preferences[SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES]
		character.equip_to_slot_if_possible(L, ITEM_SLOT_SOCKS, TRUE, disable_warning = TRUE)

	var/current_bra = character.smallclothes_preferences[SMALCLOTHES_BRA_PREFERENCES]
	var/obj/item/clothing/bra/old_b = character.bra
	if(old_b)
		character.dropItemToGround(old_b)
		qdel(old_b)
	if(current_bra)
		var/obj/item/clothing/bra/B = new current_bra
		B.color = smallclothes_preferences[SMALCLOTHES_BRA_COLOR_PREFERENCES]
		character.equip_to_slot_if_possible(B, ITEM_SLOT_UNDER_TOP, TRUE, disable_warning = TRUE)

	var/current_garter = character.smallclothes_preferences[SMALCLOTHES_GARTER_PREFERENCES]
	var/obj/item/clothing/garter/old_g = character.garter
	if(old_g)
		character.dropItemToGround(old_g)
		qdel(old_g)
	if(current_garter)
		var/obj/item/clothing/garter/G = new current_garter
		G.color = smallclothes_preferences[SMALCLOTHES_GARTER_COLOR_PREFERENCES]
		character.equip_to_slot_if_possible(G, ITEM_SLOT_GARTER, TRUE, disable_warning = TRUE)

	var/current_undershirt = character.smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_PREFERENCES]
	var/obj/item/clothing/undershirt/old_un = character.undershirt
	if(old_un)
		character.dropItemToGround(old_un)
		qdel(old_un)
	if(current_undershirt)
		var/obj/item/clothing/undershirt/U = new current_undershirt
		U.color = smallclothes_preferences[SMALCLOTHES_UNDERSHIRT_COLOR_PREFERENCES]
		character.equip_to_slot_if_possible(U, ITEM_SLOT_UNDERSHIRT, TRUE, disable_warning = TRUE)

	var/current_armsleeve = character.smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_PREFERENCES]
	var/obj/item/clothing/armsleeves/old_ar = character.armsleeves
	if(old_ar)
		character.dropItemToGround(old_ar)
		qdel(old_ar)
	if(current_armsleeve)
		var/obj/item/clothing/armsleeves/ar = new current_armsleeve
		ar.color = smallclothes_preferences[SMALCLOTHES_ARMSLEEVE_COLOR_PREFERENCES]
		character.equip_to_slot_if_possible(ar, ITEM_SLOT_ARMSLEEVES, TRUE, disable_warning = TRUE)

	character.update_body()
	character.update_body_parts()

/datum/preferences/proc/show_bra_selection_ui(mob/user, preference_type)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		to_chat(user, span_warning("You cannot choose smallclothes while random preferences are enabled. Disable random preferences first."))
		return

	var/list/dat = list()
	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	dat += "<style>"
	dat += ".bra-item { display: flex; align-items: center; margin-bottom: 5px; }"
	dat += ".bra-icon { vertical-align: middle; }"
	dat += ".bra-text { vertical-align: middle; line-height: 32px; }"
	dat += "</style>"

	var/list/bra_list = list()
	for(var/bra_type in GLOB.selectable_bras)
		var/obj/item/clothing/bra/bra_instance
		var/bra_name
		if(bra_type)
			bra_instance = bra_type
			bra_name = initial(bra_instance.name)
		else
			bra_name = "None"
		bra_list += list(list("type" = bra_type, "name" = bra_name))

	for(var/list/bra_data in bra_list)
		var/bra_type = bra_data["type"]
		if(bra_type)
			var/bra_name = bra_data["name"]
			var/display_name = capitalize(bra_name)
			var/bra_icon = get_cached_bras_flat_icon(bra_type)
			dat += "<div class='bra-item'><span class='bra-icon'>[bra_icon]</span> <span class='bra-text'><a href='byond://?_src_=prefs;preference=confirm_bra;bra_type=[bra_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"
		else
			var/display_name = "None"
			dat += "<div class='bra-item'></span> <span class='bra-text'><a href='byond://?_src_=prefs;preference=confirm_bra;bra_type=[null];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"


	var/title = "Select Bra"
	var/datum/browser/popup = new(user, "bra_selection", "<div align='center'>[title]</div>", 400, 600)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/show_garter_selection_ui(mob/user, preference_type)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		to_chat(user, span_warning("You cannot choose smallclothes while random preferences are enabled. Disable random preferences first."))
		return

	var/list/dat = list()
	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	dat += "<style>"
	dat += ".garter-item { display: flex; align-items: center; margin-bottom: 5px; }"
	dat += ".garter-icon { vertical-align: middle; }"
	dat += ".garter-text { vertical-align: middle; line-height: 32px; }"
	dat += "</style>"

	var/list/garter_list = list()
	for(var/garter_type in GLOB.selectable_garters)
		var/obj/item/clothing/garter/garter_instance
		var/garter_name
		if(garter_type)
			garter_instance = garter_type
			garter_name = initial(garter_instance.name)
		else
			garter_name = "None"
		garter_list += list(list("type" = garter_type, "name" = garter_name))

	for(var/list/garter_data in garter_list)
		var/garter_type = garter_data["type"]
		if(garter_type)
			var/garter_name = garter_data["name"]
			var/display_name = capitalize(garter_name)
			var/garter_icon = get_cached_garters_flat_icon(garter_type)
			dat += "<div class='garter-item'><span class='garter-icon'>[garter_icon]</span> <span class='garter-text'><a href='byond://?_src_=prefs;preference=confirm_garter;garter_type=[garter_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"
		else
			var/display_name = "None"
			dat += "<div class='garter-item'><span class='garter-text'><a href='byond://?_src_=prefs;preference=confirm_garter;garter_type=[garter_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"

	var/title ="Select Garter"
	var/datum/browser/popup = new(user, "garter_selection", "<div align='center'>[title]</div>", 400, 600)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/show_undershirt_selection_ui(mob/user, preference_type)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		to_chat(user, span_warning("You cannot choose smallclothes while random preferences are enabled. Disable random preferences first."))
		return

	var/list/dat = list()
	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	dat += "<style>"
	dat += ".undershirt-item { display: flex; align-items: center; margin-bottom: 5px; }"
	dat += ".undershirt-icon { vertical-align: middle; }"
	dat += ".undershirt-text { vertical-align: middle; line-height: 32px; }"
	dat += "</style>"

	var/list/undershirt_list = list()
	for(var/undershirt_type in GLOB.selectable_undershirts)
		var/obj/item/clothing/undershirt/undershirt_instance
		var/undershirt_name
		if(undershirt_type)
			undershirt_instance = undershirt_type
			undershirt_name = initial(undershirt_instance.name)
		else
			undershirt_name = "None"
		undershirt_list += list(list("type" = undershirt_type, "name" = undershirt_name))

	for(var/list/undershirt_data in undershirt_list)
		var/undershirt_type = undershirt_data["type"]
		if(undershirt_type)
			var/undershirt_name = undershirt_data["name"]
			var/display_name = capitalize(undershirt_name)
			var/undershirt_icon = get_cached_undershirts_flat_icon(undershirt_type)
			dat += "<div class='undershirt-item'><span class='undershirt-icon'>[undershirt_icon]</span> <span class='undershirt-text'><a href='byond://?_src_=prefs;preference=confirm_undershirt;undershirt_type=[undershirt_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"
		else
			var/display_name = "None"
			dat += "<div class='undershirt-item'><span class='undershirt-text'><a href='byond://?_src_=prefs;preference=confirm_undershirt;undershirt_type=[undershirt_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"

	var/title ="Select Undershirt"
	var/datum/browser/popup = new(user, "undershirt_selection", "<div align='center'>[title]</div>", 400, 600)
	popup.set_content(dat.Join())
	popup.open(FALSE)


/datum/preferences/proc/show_armsleeve_selection_ui(mob/user, preference_type)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		to_chat(user, span_warning("You cannot choose smallclothes while random preferences are enabled. Disable random preferences first."))
		return

	var/list/dat = list()
	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	dat += "<style>"
	dat += ".armsleeve-item { display: flex; align-items: center; margin-bottom: 5px; }"
	dat += ".armsleeve-icon { vertical-align: middle; }"
	dat += ".armsleeve-text { vertical-align: middle; line-height: 32px; }"
	dat += "</style>"

	var/list/armsleeve_list = list()
	for(var/armsleeve_type in GLOB.selectable_armsleeves)
		var/obj/item/clothing/armsleeves/armsleeve_instance
		var/armsleeve_name
		if(armsleeve_type)
			armsleeve_instance = armsleeve_type
			armsleeve_name = initial(armsleeve_instance.name)
		else
			armsleeve_name = "None"
		armsleeve_list += list(list("type" = armsleeve_type, "name" = armsleeve_name))

	for(var/list/armsleeve_data in armsleeve_list)
		var/armsleeve_type = armsleeve_data["type"]
		if(armsleeve_type)
			var/armsleeve_name = armsleeve_data["name"]
			var/display_name = capitalize(armsleeve_name)
			var/armsleeve_icon = get_cached_armsleeves_flat_icon(armsleeve_type)
			dat += "<div class='armsleeve-item'><span class='armsleeve-icon'>[armsleeve_icon]</span> <span class='armsleeve-text'><a href='byond://?_src_=prefs;preference=confirm_armsleeve;armsleeve_type=[armsleeve_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"
		else
			var/display_name = "None"
			dat += "<div class='armsleeve-item'><span class='armsleeve-text'><a href='byond://?_src_=prefs;preference=confirm_armsleeve;armsleeve_type=[armsleeve_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"

	var/title ="Select armsleeve"
	var/datum/browser/popup = new(user, "armsleeve_selection", "<div align='center'>[title]</div>", 400, 600)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/show_undie_selection_ui(mob/user, preference_type)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		to_chat(user, span_warning("You cannot choose smallclothes while random preferences are enabled. Disable random preferences first."))
		return

	var/list/dat = list()
	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	dat += "<style>"
	dat += ".undie-item { display: flex; align-items: center; margin-bottom: 5px; }"
	dat += ".undie-icon { vertical-align: middle; }"
	dat += ".undie-text { vertical-align: middle; line-height: 32px; }"
	dat += "</style>"

	var/list/undie_list = list()
	for(var/undie_type in GLOB.selectable_undies)
		var/obj/item/clothing/undies/undie_instance
		var/undie_name
		if(undie_type)
			undie_instance = undie_type
			undie_name = initial(undie_instance.name)
		else
			undie_name = "None"
		undie_list += list(list("type" = undie_type, "name" = undie_name))

	for(var/list/undie_data in undie_list)
		var/undie_type = undie_data["type"]
		if(undie_type)
			var/undie_name = undie_data["name"]
			var/display_name = capitalize(undie_name)
			var/undie_icon = get_cached_undies_flat_icon(undie_type)
			dat += "<div class='undie-item'><span class='undie-icon'>[undie_icon]</span> <span class='undie-text'><a href='byond://?_src_=prefs;preference=confirm_undie;undie_type=[undie_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"
		else
			var/display_name = "None"
			dat += "<div class='undie-item'></span> <span class='undie-text'><a href='byond://?_src_=prefs;preference=confirm_undie;undie_type=[null];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"


	var/title = "Select Underwear"
	var/datum/browser/popup = new(user, "undie_selection", "<div align='center'>[title]</div>", 400, 600)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/show_legwear_selection_ui(mob/user, preference_type)
	var/list/smallclothes_preferences = read_preference(/datum/preference/list_type/smallclothes_preferences)
	if(smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		to_chat(user, span_warning("You cannot choose smallclothes while random preferences are enabled. Disable random preferences first."))
		return

	var/list/dat = list()
	dat += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
	dat += "<style>"
	dat += ".legwear-item { display: flex; align-items: center; margin-bottom: 5px; }"
	dat += ".legwear-icon { vertical-align: middle; }"
	dat += ".legwear-text { vertical-align: middle; line-height: 32px; }"
	dat += "</style>"

	var/list/legwear_list = list()
	for(var/legwear_type in GLOB.selectable_legwear)
		var/obj/item/clothing/legwears/legwear_instance
		var/legwear_name
		if(legwear_type)
			legwear_instance = legwear_type
			legwear_name = initial(legwear_instance.name)
		else
			legwear_name = "None"
		legwear_list += list(list("type" = legwear_type, "name" = legwear_name))

	for(var/list/legwear_data in legwear_list)
		var/legwear_type = legwear_data["type"]
		if(legwear_type)
			var/legwear_name = legwear_data["name"]
			var/display_name = capitalize(legwear_name)
			var/legwear_icon = get_cached_legwear_flat_icon(legwear_type)
			dat += "<div class='legwear-item'><span class='legwear-icon'>[legwear_icon]</span> <span class='legwear-text'><a href='byond://?_src_=prefs;preference=confirm_legwear;legwear_type=[legwear_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"
		else
			var/display_name = "None"
			dat += "<div class='legwear-item'><span class='legwear-text'><a href='byond://?_src_=prefs;preference=confirm_legwear;legwear_type=[legwear_type];preference_type=[preference_type];task=change_smallclothes_preferences'>[encode_special_chars(display_name)]</a></span></div>"

	var/title ="Select Legwear"
	var/datum/browser/popup = new(user, "legwear_selection", "<div align='center'>[title]</div>", 400, 600)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/proc/get_global_selectable_undies()
	var/list/blacklisted_undies = list(
		/obj/item/clothing/undies/portalpanties,
	)

	var/list/undie_types = typesof(/obj/item/clothing/undies) - blacklisted_undies

	var/list/filtered_undie_types = list()
	var/list/name_to_type = list()

	for(var/undie_type in undie_types)
		var/obj/item/clothing/undies/undie_instance = undie_type
		if(undie_instance.loadout_blacklisted)
			continue
		var/undie_name = initial(undie_instance.name)

		if(!name_to_type[undie_name])
			name_to_type[undie_name] = undie_type
			filtered_undie_types += undie_type
		else
			var/existing_type = name_to_type[undie_name]
			if(ispath(existing_type, undie_type))
				name_to_type[undie_name] = undie_type
				filtered_undie_types -= existing_type
				filtered_undie_types += undie_type
	filtered_undie_types += null

	return filtered_undie_types

/proc/get_global_selectable_legwear()
	var/list/blacklisted_legwear = list(
		/obj/item/clothing/legwears/random,
		/obj/item/clothing/legwears/white,
		/obj/item/clothing/legwears/black,
		/obj/item/clothing/legwears/blue,
		/obj/item/clothing/legwears/red,
		/obj/item/clothing/legwears/purple,
		/obj/item/clothing/legwears/silk/random,
		/obj/item/clothing/legwears/silk/white,
		/obj/item/clothing/legwears/silk/black,
		/obj/item/clothing/legwears/silk/blue,
		/obj/item/clothing/legwears/silk/red,
		/obj/item/clothing/legwears/silk/purple,
		/obj/item/clothing/legwears/fishnet/random,
		/obj/item/clothing/legwears/fishnet/white,
		/obj/item/clothing/legwears/fishnet/black,
		/obj/item/clothing/legwears/fishnet/blue,
		/obj/item/clothing/legwears/fishnet/red,
		/obj/item/clothing/legwears/fishnet/purple,
		/obj/item/clothing/legwears/stockings_wg/white,
		/obj/item/clothing/legwears/stockings_wg/black,
		/obj/item/clothing/legwears/stockings_wg/blue,
		/obj/item/clothing/legwears/stockings_wg/red,
		/obj/item/clothing/legwears/stockings_wg/purple,
		/obj/item/clothing/legwears/foreign_habit_stockings,
		)

	var/list/legwear_types = typesof(/obj/item/clothing/legwears) - blacklisted_legwear

	var/list/filtered_legwear_types = list()
	var/list/name_to_type = list()

	for(var/legwear_type in legwear_types)
		var/obj/item/clothing/legwears/legwear_instance = legwear_type
		if(legwear_instance.loadout_blacklisted)
			continue
		var/legwear_name = initial(legwear_instance.name)

		if(!name_to_type[legwear_name])
			name_to_type[legwear_name] = legwear_type
			filtered_legwear_types += legwear_type
		else
			var/existing_type = name_to_type[legwear_name]
			if(ispath(existing_type, legwear_type))
				name_to_type[legwear_name] = legwear_type
				filtered_legwear_types -= existing_type
				filtered_legwear_types += legwear_type
	filtered_legwear_types += null

	return filtered_legwear_types


/proc/get_global_selectable_bras()
	var/list/blacklisted_bras = list(
	)

	var/list/bra_types = typesof(/obj/item/clothing/bra) - blacklisted_bras

	var/list/filtered_bra_types = list()
	var/list/name_to_type = list()

	for(var/bra_type in bra_types)
		var/obj/item/clothing/bra/bra_instance = bra_type
		if(bra_instance.loadout_blacklisted)
			continue
		var/bra_name = initial(bra_instance.name)

		if(!name_to_type[bra_name])
			name_to_type[bra_name] = bra_type
			filtered_bra_types += bra_type
		else
			var/existing_type = name_to_type[bra_name]
			if(ispath(existing_type, bra_type))
				name_to_type[bra_name] = bra_type
				filtered_bra_types -= existing_type
				filtered_bra_types += bra_type
	filtered_bra_types += null

	return filtered_bra_types

/proc/get_global_selectable_garters()
	var/list/blacklisted_garters = list(
		)

	var/list/garter_types = typesof(/obj/item/clothing/garter) - blacklisted_garters

	var/list/filtered_garter_types = list()
	var/list/name_to_type = list()

	for(var/garter_type in garter_types)
		var/obj/item/clothing/garter/garter_instance = garter_type
		if(garter_instance.loadout_blacklisted)
			continue
		var/garter_name = initial(garter_instance.name)

		if(!name_to_type[garter_name])
			name_to_type[garter_name] = garter_type
			filtered_garter_types += garter_type
		else
			var/existing_type = name_to_type[garter_name]
			if(ispath(existing_type, garter_type))
				name_to_type[garter_name] = garter_type
				filtered_garter_types -= existing_type
				filtered_garter_types += garter_type
	filtered_garter_types += null

	return filtered_garter_types

/proc/get_global_selectable_undershirts()
	var/list/blacklisted_undershirts = list(
		)

	var/list/undershirt_types = typesof(/obj/item/clothing/undershirt) - blacklisted_undershirts

	var/list/filtered_undershirt_types = list()
	var/list/name_to_type = list()

	for(var/undershirt_type in undershirt_types)
		var/obj/item/clothing/undershirt/undershirt_instance = undershirt_type
		if(undershirt_instance.loadout_blacklisted)
			continue
		var/undershirt_name = initial(undershirt_instance.name)

		if(!name_to_type[undershirt_name])
			name_to_type[undershirt_name] = undershirt_type
			filtered_undershirt_types += undershirt_type
		else
			var/existing_type = name_to_type[undershirt_name]
			if(ispath(existing_type, undershirt_type))
				name_to_type[undershirt_name] = undershirt_type
				filtered_undershirt_types -= existing_type
				filtered_undershirt_types += undershirt_type
	filtered_undershirt_types += null

	return filtered_undershirt_types

/proc/get_global_selectable_armsleeves()
	var/list/blacklisted_armsleeves = list(
		)

	var/list/armsleeve_types = typesof(/obj/item/clothing/armsleeves) - blacklisted_armsleeves

	var/list/filtered_armsleeve_types = list()
	var/list/name_to_type = list()

	for(var/armsleeve_type in armsleeve_types)
		var/obj/item/clothing/armsleeves/armsleeve_instance = armsleeve_type
		if(armsleeve_instance.loadout_blacklisted)
			continue
		var/armsleeve_name = initial(armsleeve_instance.name)

		if(!name_to_type[armsleeve_name])
			name_to_type[armsleeve_name] = armsleeve_type
			filtered_armsleeve_types += armsleeve_type
		else
			var/existing_type = name_to_type[armsleeve_name]
			if(ispath(existing_type, armsleeve_type))
				name_to_type[armsleeve_name] = armsleeve_type
				filtered_armsleeve_types -= existing_type
				filtered_armsleeve_types += armsleeve_type
	filtered_armsleeve_types += null

	return filtered_armsleeve_types
