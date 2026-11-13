/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

//skull
/atom/movable/screen/ghost/orbit/rogue
	name = "AFTER LIFE"
	icon = 'icons/mob/afterlife.dmi'
	icon_state = "skull"
	screen_loc = "WEST-4,SOUTH+6"
	no_over_text = FALSE

/atom/movable/screen/ghost/orbit/rogue/Click(location, control, params)
	var/mob/dead/observer/ghost = usr
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, RIGHT_CLICK)) // screen objects don't do the normal Click() stuff so we'll cheat
		if(ghost.client?.holder)
			ghost.follow()
	else
		if(istype(ghost, /mob/dead/observer/rogue/arcaneeye))
			return
		if(alert("Travel with the boatman?", "", "Yes", "No") == "Yes")
			if(ghost.mind)
				var/datum/job/target_job = SSjob.GetJob(ghost.mind.assigned_role)
				if(target_job)
					if(target_job.job_reopens_slots_on_death)
						target_job.current_positions = max(0, target_job.current_positions - 1)
			// Spectators have no mind, but must still be able to leave.
			ghost.returntolobby(0)

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using

	if(!GLOB.admin_datums[owner.ckey]) // If you are adminned, you will not get the dead hud obstruction.
		using =  new /atom/movable/screen/backhudl/ghost(null, src)
		static_inventory += using

	scannies = new /atom/movable/screen/scannies(null, src)
	static_inventory += scannies
	if(owner.client?.prefs?.read_preference(/datum/preference/toggle/crt))
		scannies.alpha = 70

	using = new /atom/movable/screen/ghost/orbit/rogue(null, src)
	static_inventory += using

	//speshial hud for aghost
	if(GLOB.admin_datums[owner.ckey])
		//all of this a button in hud
		//Return to body
		using = new /atom/movable/screen/ghost/reenter(null, src)
		using.screen_loc = ui_ghost_reenter_corpse
		static_inventory += using

		//Orbit
		using = new /atom/movable/screen/ghost/orbit(null, src)
		using.screen_loc = ui_ghost_orbit
		static_inventory += using

		//Jump to mob
		using = new /atom/movable/screen/ghost/jumptomob(null, src)
		using.screen_loc = ui_ghost_jumptomob
		static_inventory += using

		//Teleport to zone
		using = new /atom/movable/screen/ghost/teleport_area(null, src) //create new logic for this!!!
		using.screen_loc = ui_ghost_teleport
		static_inventory += using

		//Move on z-level up and down
		using = new /atom/movable/screen/ghost/z_up(null, src)
		using.screen_loc = "SOUTH:6,CENTER-3:24"
		static_inventory += using

		using = new /atom/movable/screen/ghost/z_down(null, src)
		using.screen_loc = "SOUTH:6,CENTER-4:24"
		static_inventory += using

/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client.prefs.read_preference(/datum/preference/toggle/ghost_hud))
		screenmob.client.screen -= static_inventory
	else
		screenmob.client.screen += static_inventory

/datum/hud/eye/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using =  new /atom/movable/screen/backhudl/ghost(null, src)
	static_inventory += using

	scannies = new /atom/movable/screen/scannies(null, src)
	static_inventory += scannies
	if(owner.client?.prefs?.read_preference(/datum/preference/toggle/crt))
		scannies.alpha = 70

/datum/hud/eye/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client.prefs.read_preference(/datum/preference/toggle/ghost_hud))
		screenmob.client.screen -= static_inventory
	else
		screenmob.client.screen += static_inventory

/datum/hud/obs/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using =  new /atom/movable/screen/backhudl/obs(null, src)
	static_inventory += using

	scannies = new /atom/movable/screen/scannies(null, src)
	static_inventory += scannies
	if(owner.client?.prefs?.read_preference(/datum/preference/toggle/crt))
		scannies.alpha = 70


//button for hud

//animation for butten
/atom/movable/screen/ghost/button_base
	icon = 'modular_rmh/icons/hud/ghost_hud.dmi'
	var/tmp/button_animation = FALSE


//return to body
/atom/movable/screen/ghost/reenter
	parent_type = /atom/movable/screen/ghost/button_base
	name = "Re-enter body"
	icon_state = "reenter"

/atom/movable/screen/ghost/reenter/Click(location, control, params)
	var/mob/dead/observer/G = usr
	if(istype(G))
		G.reenter_corpse()

//Orbit
/atom/movable/screen/ghost/orbit
	parent_type = /atom/movable/screen/ghost/button_base
	name = "Orbit mod"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click(location, control, params)
	var/mob/dead/observer/G = usr
	if(istype(G))
		G.follow()

//Jump to mob
/atom/movable/screen/ghost/jumptomob
	parent_type = /atom/movable/screen/ghost/button_base
	name = "Jump to mob"
	icon_state = "jumptomob"

/atom/movable/screen/ghost/jumptomob/Click(location, control, params)
	var/mob/dead/observer/G = usr
	if(istype(G))
		G.jumptomob()

//Teleport to area
/atom/movable/screen/ghost/teleport_area
	parent_type = /atom/movable/screen/ghost/button_base
	name = "Teleport to area"
	icon_state = "teleport_area"

/atom/movable/screen/ghost/teleport_area/Click(location, control, params)
	var/mob/dead/observer/G = usr
	if(!istype(G) || !G.client)
		return

	var/list/area_names = list()
	for(var/area/A in GLOB.areas)
		if(is_station_level(A.z))
			area_names[A.name] = A
	if(!length(area_names))
		to_chat(G, span_warning("No areas found!"))
		return
	var/area_name = input(G, "Choose area to teleport:", "Area Teleport") as null|anything in sortList(area_names)
	if(isnull(area_name) || !area_name)
		return

	var/area/target_area = area_names[area_name]
	if(target_area)
		var/list/turfs = get_area_turfs(target_area)
		G.forceMove(pick(turfs))
		to_chat(G, span_notice("Teleported to [area_name]."))

//move ghost on z-levels
/atom/movable/screen/ghost/z_up
	parent_type = /atom/movable/screen/ghost/button_base
	name = "Move Up"
	icon_state = "z_up"

/atom/movable/screen/ghost/z_up/Click(location, control, params)
	var/mob/dead/observer/G = usr
	if(istype(G))
		G.ghost_upward()

/atom/movable/screen/ghost/z_down
	parent_type = /atom/movable/screen/ghost/button_base
	name = "Move Down"
	icon_state = "z_down"

/atom/movable/screen/ghost/z_down/Click(location, control, params)
	var/mob/dead/observer/G = usr
	if(istype(G))
		G.ghost_downward()
