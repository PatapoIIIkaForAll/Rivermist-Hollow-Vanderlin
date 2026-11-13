/datum/hud/mothbug
	var/atom/movable/screen/mothbug_silk/silk_display

/datum/hud/mothbug/New(mob/owner)
	..()
	// The body-zone doll picks which garment a nibble goes for.
	zone_select = new /atom/movable/screen/zone_sel(null, src)
	zone_select.icon = 'icons/mob/roguehud64.dmi'
	zone_select.screen_loc = rogueui_targetdoll
	zone_select.update_appearance(UPDATE_OVERLAYS)
	static_inventory += zone_select

	silk_display = new /atom/movable/screen/mothbug_silk(null, src)
	infodisplay += silk_display
	var/mob/living/simple_animal/mothbug/moth = owner
	if(istype(moth))
		silk_display.update_silk(moth.silk_charge, moth.max_silk_charge)

/datum/hud/mothbug/Destroy()
	silk_display = null
	return ..()

/atom/movable/screen/mothbug_silk
	name = "silk"
	desc = "Silk charge. Eat fabric to gain it; abilities spend it."
	screen_loc = "WEST-3:-16,CENTER+2:16"
	maptext_width = 96
	maptext_height = 16

/atom/movable/screen/mothbug_silk/proc/update_silk(current, maximum)
	maptext = MAPTEXT("<span style='color:#e8dcc0'>Silk: [round(current)]/[maximum]</span>")
