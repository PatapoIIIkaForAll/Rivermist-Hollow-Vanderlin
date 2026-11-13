/datum/buildmode_mode/boom
	name = "Boom"
	key = "boom"

	var/devastation = -1
	var/heavy = -1
	var/light = -1
	var/flash = -1
	var/flames = -1
	var/hotspots = -1

/datum/buildmode_mode/boom/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>Mouse Button on obj  = Kaboom</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/boom/change_settings(client/c)
	devastation = input(c, "Range of total devastation. -1 to none", text("Input")) as num|null
	if(devastation == null)
		devastation = -1
	heavy = input(c, "Range of heavy impact. -1 to none", text("Input")) as num|null
	if(heavy == null)
		heavy = -1
	light = input(c, "Range of light impact. -1 to none", text("Input")) as num|null
	if(light == null)
		light = -1
	flash = input(c, "Range of flash. -1 to none", text("Input")) as num|null
	if(flash == null)
		flash = -1
	flames = input(c, "Range of flames. -1 to none", text("Input")) as num|null
	if(flames == null)
		flames = -1
	hotspots = input(c, "Range of burning hotspots. -1 to none", text("Input")) as num|null
	if(hotspots == null)
		hotspots = -1

/datum/buildmode_mode/boom/handle_click(client/c, list/modifiers, atom/object)
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		explosion(object, devastation, heavy, light, flash, FALSE, TRUE, flames, hotspots)
		log_admin("Build Mode: [key_name(c)] caused an explosion(dev=[devastation], hvy=[heavy], lgt=[light], hotspots=[hotspots], flash=[flash], flames=[flames]) at [AREACOORD(object)]")
