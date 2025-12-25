/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()
//skull
/atom/movable/screen/ghost/orbit/rogue
	name = "AFTER LIFE"
	icon = 'icons/mob/afterlife.dmi'
	icon_state = "skull"
	screen_loc = "WEST-4,SOUTH+6"
	no_over_text = FALSE

/atom/movable/screen/ghost/orbit/rogue/Click(location, control, params)
	var/mob/dead/observer/G = usr
	var/paramslist = params2list(params)
	if(paramslist["right"]) // screen objects don't do the normal Click() stuff so we'll cheat
		if(G.client?.holder)
			G.follow()
	else
		if(istype(G, /mob/dead/observer/rogue/arcaneeye))
			return
		if(alert("Travel with the boatman?", "", "Yes", "No") == "Yes")
			if(G.mind)
				var/datum/job/target_job = SSjob.GetJob(G.mind.assigned_role)
				if(target_job)
					if(target_job.job_reopens_slots_on_death)
						target_job.current_positions = max(0, target_job.current_positions - 1)
					//if(target_job.same_job_respawn_delay)
						// Store the current time for the player
						//GLOB.job_respawn_delays[G.ckey] = world.time + target_job.same_job_respawn_delay

				G.returntolobby(0)
		/*if(G.isinhell)
			return
		if(G.client)
			if(G.client.holder)
				if(istype(G, /mob/dead/observer/rogue/arcaneeye))
					return
				if(istype(G, /mob/dead/observer/profane)) // Souls trapped by a dagger can return to lobby if they want
					if(alert("Return to the lobby?", "", "Yes", "No") == "Yes")
						G.returntolobby()
				G.client.descend()
				return

		if(has_world_trait(/datum/world_trait/skeleton_siege) || has_world_trait(/datum/world_trait/rousman_siege) || has_world_trait(/datum/world_trait/goblin_siege))
			G.returntolobby()
		G.client.descend()*/
/*		if(world.time < G.ghostize_time + RESPAWNTIME)
			var/ttime = round((G.ghostize_time + RESPAWNTIME - world.time) / 10)
			var/list/thingsz = list("My connection to the world is still too strong.",\
			"I'm not ready to leave...", "I'm not ready to travel with Charon.",\
			"Don't make me leave!", "No... Not yet!", "Please, don't make me go yet...",\
			"The shores are calling me but I cannot go...","My soul isn't ready yet...")
			to_chat(G, "<span class='warning'>[pick(thingsz)] ([ttime])</span>")
			return */ //Disabling this since the underworld will exist

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using

	if(!GLOB.admin_datums[owner.ckey]) // If you are adminned, you will not get the dead hud obstruction.
		using =  new /atom/movable/screen/backhudl/ghost(null, src)
		static_inventory += using

	scannies = new /atom/movable/screen/scannies(null, src)
	static_inventory += scannies
	if(owner.client?.prefs?.crt == TRUE)
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
	if(!screenmob.client.prefs.ghost_hud)
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
	if(owner.client?.prefs?.crt == TRUE)
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
	if(!screenmob.client.prefs.ghost_hud)
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
	if(owner.client?.prefs?.crt == TRUE)
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
