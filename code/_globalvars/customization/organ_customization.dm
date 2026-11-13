GLOBAL_LIST_INIT(customizer_choices, build_customizer_choices())


/proc/build_customizer_choices()
	. = list()
	for(var/datum/customizer_choice/type as anything in typesof(/datum/customizer_choice))
		if(IS_ABSTRACT(type))
			continue
		.[type] = new type()
	return .

GLOBAL_LIST_INIT(customizers, build_customizers())

/proc/build_customizers()
	. = list()
	for(var/datum/customizer/type as anything in typesof(/datum/customizer))
		if(IS_ABSTRACT(type))
			continue
		.[type] = new type()
	return .

/proc/color_pick_sanitized_lumi(mob/user, description, title, default_value, min_lumi = 0.02, max_lumi = 1.0)
	var/color = tgui_color_picker(user, description, title, sanitize_hexcolor(default_value, 6, TRUE, "#ffffff"))
	var/good = TRUE
	if(!color)
		return
	color = sanitize_hexcolor(color)
	var/list/hsl = rgb2hsl(hex2num(copytext(color,1,3)),hex2num(copytext(color,3,5)),hex2num(copytext(color,5,7)))
	var/lumi = hsl[3]
	if(lumi < min_lumi)
		to_chat(user, "<span class='warning'>The picked color is too dark! Raising Luminosity to minimum.</span>")
		hsl[3] = min_lumi
		good = FALSE
	if(lumi > max_lumi)
		to_chat(user, "<span class='warning'>The picked color is too bright! Lowering Luminosity to maximum.</span>")
		hsl[2] = max_lumi
		good = FALSE
	if(!good)
		var/list/rgb = hsl2rgb(arglist(hsl))
		color = sanitize_hexcolor("[num2hex(rgb[1], 2)][num2hex(rgb[2], 2)][num2hex(rgb[3], 2)]")
	return color
