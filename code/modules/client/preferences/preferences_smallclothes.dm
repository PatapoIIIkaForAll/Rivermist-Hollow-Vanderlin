#define SMALCLOTHES_RANDOM_PREFERENCES "Random Preferences"
#define SMALCLOTHES_UNDIE_PREFERENCES "Undies Preferences"
#define SMALCLOTHES_LEGWEAR_PREFERENCES "Legwear Preferences"
#define SMALCLOTHES_UNDIE_COLOR_PREFERENCES "Undies Color"
#define SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES "Legwear Color"

GLOBAL_LIST_EMPTY(selectable_undies)
GLOBAL_LIST_EMPTY(selectable_legwear)
GLOBAL_LIST_EMPTY(cached_undies_flat_icons)
GLOBAL_LIST_EMPTY(cached_legwear_flat_icons)

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

/datum/preferences/proc/validate_smallclothes_preferences()
	if(!smallclothes_preferences)
		smallclothes_preferences = list()

	if(!length(GLOB.selectable_undies))
		GLOB.selectable_undies = get_global_selectable_undies()

	if(!length(GLOB.selectable_legwear))
		GLOB.selectable_legwear = get_global_selectable_legwear()

	if(!smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES] = FALSE

	if(!smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		if(!(smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] in GLOB.selectable_undies) && !isnull(smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES]))
			smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] = get_random_undie()

		if(!(smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] in GLOB.selectable_legwear) && !isnull(smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES]))
			smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] = get_random_legwear()
	else
		if(!smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES])
			smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] = get_random_undie()
		if(!smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES])
			smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] = get_random_legwear()

/datum/preferences/proc/reset_smallclothes_preferences()
	smallclothes_preferences = list()
	smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES] = FALSE
	smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] = null
	smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] = null

/datum/preferences/proc/get_default_undie()
	return /obj/item/clothing/undies

/datum/preferences/proc/get_default_legwear()
	return /obj/item/clothing/legwears

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

/datum/preferences/proc/handle_undies_topic(mob/user, href_list)
	update_preview_icon()
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
				var/choice = input(user, "Choose a color.", "Underwear Colour") as null|anything in colorlist
				if (choice && colorlist[choice])
					smallclothes_preferences[preference_type] = colorlist[choice]
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
				var/choice = input(user, "Choose a color.", "Legwear Colour") as null|anything in colorlist
				if (choice && colorlist[choice])
					smallclothes_preferences[preference_type] = colorlist[choice]
					to_chat(user, "The colour for your legwear has been set to <b>[choice].</b>.")
				else
					smallclothes_preferences[preference_type] = null
					to_chat(user, "The colour for your legwear loadout item has been cleared.")
				update_preview_icon()
				show_smallclothes_ui(user)


/datum/preferences/proc/print_smallclothes_page(mob/user)
	if(!length(GLOB.selectable_undies))
		GLOB.selectable_undies = get_global_selectable_undies()
	if(!length(GLOB.selectable_legwear))
		GLOB.selectable_legwear = get_global_selectable_legwear()
	var/list/dat = list()

	var/current_undie = smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES]
	var/current_legwear = smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES]
	var/random_preferences = smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES]

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
		dat += "<a href='byond://?_src_=prefs;undie_type=[current_undie];preference=undie_color;preference_type=[SMALCLOTHES_UNDIE_COLOR_PREFERENCES];task=change_smallclothes_preferences'>(C)</a>"
	dat += "</span></div>"

	dat += "<div [random_preferences ? "" : "class='smallclothes-item'"]><b>Legwear: </b> <span class='smallclothes-icon'>[legwear_icon]</span> <span class='smallclothes-text'>"
	if(random_preferences)
		dat += "<font color='orange'>[encode_special_chars(legwear_name)]</font>"
	else
		dat += "<a href='byond://?_src_=prefs;preference=choose_legwear;preference_type=[SMALCLOTHES_LEGWEAR_PREFERENCES];task=change_smallclothes_preferences'>[encode_special_chars(legwear_name)]</a>"
	if (legwear_color)
		dat += "<a href='byond://?_src_=prefs;legwear_type=[current_legwear];preference=legwear_color;preference_type=[SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES];task=change_smallclothes_preferences'> <span style='border: 1px solid #161616; background-color: [legwear_color ? legwear_color : "#FFFFFF"];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></a>"
	else
		dat += "<a href='byond://?_src_=prefs;legwear_type=[current_legwear];preference=legwear_color;preference_type=[SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES];task=change_smallclothes_preferences'>(C)</a>"
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
	if(!smallclothes_preferences)
		return

	character.smallclothes_preferences = smallclothes_preferences.Copy()

	if(character.smallclothes_preferences[SMALCLOTHES_RANDOM_PREFERENCES])
		character.smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES] = get_random_undie()
		character.smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES] = get_random_legwear()

	var/current_undie = character.smallclothes_preferences[SMALCLOTHES_UNDIE_PREFERENCES]
	var/obj/item/clothing/undies/old_u = character.underwear
	if(old_u)
		character.dropItemToGround(old_u)
		qdel(old_u)
	if(current_undie)
		var/obj/item/clothing/undies/U = new current_undie
		U.color = smallclothes_preferences[SMALCLOTHES_UNDIE_COLOR_PREFERENCES]
		character.equip_to_slot_if_possible(U, ITEM_SLOT_UNDERWEAR, TRUE, disable_warning = TRUE)


	var/current_legwear = character.smallclothes_preferences[SMALCLOTHES_LEGWEAR_PREFERENCES]
	var/obj/item/clothing/legwears/old_l = character.legwear_socks
	if(old_l)
		character.dropItemToGround(old_l)
		qdel(old_l)
	if(current_legwear)
		var/obj/item/clothing/legwears/L = new current_legwear
		L.color = smallclothes_preferences[SMALCLOTHES_LEGWEAR_COLOR_PREFERENCES]
		character.equip_to_slot_if_possible(L, ITEM_SLOT_SOCKS, TRUE, disable_warning = TRUE)
	character.update_body()
	character.update_body_parts()


/datum/preferences/proc/show_undie_selection_ui(mob/user, preference_type)
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
	var/list/blacklisted_undies = list()

	var/list/undie_types = typesof(/obj/item/clothing/undies) - blacklisted_undies

	var/list/filtered_undie_types = list()
	var/list/name_to_type = list()

	for(var/undie_type in undie_types)
		var/obj/item/clothing/undies/undie_instance = undie_type
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
		)

	var/list/legwear_types = typesof(/obj/item/clothing/legwears) - blacklisted_legwear

	var/list/filtered_legwear_types = list()
	var/list/name_to_type = list()

	for(var/legwear_type in legwear_types)
		var/obj/item/clothing/legwears/legwear_instance = legwear_type
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

