//COMMON BELL

/obj/structure/bell_common
	name = "bell"
	desc = "A good way to get someone's attention... or piss them off."
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"
	density = FALSE
	max_integrity = 0
	anchored = TRUE
	var/last_ring

/obj/structure/bell_common/attack_hand(mob/user)
	if(world.time < last_ring + 15)
		return
	user.visible_message(span_info("[user] starts ringing the bell."))
	playsound(src, 'modular_rmh/sound/misc/bell_common.ogg', 100, extrarange = 8, ignore_walls = TRUE)
	flick("bell_commonpressed", src)
	last_ring = world.time

//BOAT BELL

/obj/structure/boatbell
	name = "bell"
	desc = "This is the doomspeller of Rivermist Hollow."
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell"
	density = FALSE
	max_integrity = 0
	anchored = TRUE
	var/last_ring
	var/datum/looping_sound/boatloop/soundloop

/obj/structure/boatbell/Initialize()
	soundloop = new(src, FALSE)
	soundloop.start()
	. = ..()

/obj/structure/boatbell/attack_hand(mob/user)
	if(world.time < last_ring + 50)
		return
	user.visible_message(span_info("[user] rings the bell."))
	playsound(src, 'modular_rmh/sound/misc/boatbell.ogg', 100, extrarange = 5)
	last_ring = world.time

/obj/structure/boatbell/fluff/attack_hand(mob/user)
	if(world.time < last_ring + 50)
		return
	user.visible_message(span_info("[user] rings the bell."))
	playsound(src, 'modular_rmh/sound/misc/boatbell.ogg', 100, extrarange = 5)
	last_ring = world.time

// CALL BELLS
// Rings a bell that notifies specific job titles across the town.

/obj/structure/call_bell
	name = "call bell"
	desc = "A small mana-infused bell that carries its chime across the town to specific ears."
	icon = 'modular_rmh/icons/obj/tallstructure.dmi'
	icon_state = "standingbell"
	density = FALSE
	max_integrity = 0
	anchored = TRUE

	var/cooldown = 5 MINUTES
	var/on_cooldown = FALSE

	/// Job titles that will hear this bell
	var/list/notify_titles = list()
	var/specific_location

/obj/structure/call_bell/attack_hand(mob/living/user)
	if(src.on_cooldown)
		to_chat(user, span_warning("The bell has already been rung recently."))
		return

	user.changeNext_move(6)
	user.visible_message(span_warning("[user] begins ringing [src]."))

	if(!do_after(user, 3 SECONDS))
		return

	src.on_cooldown = TRUE
	user.visible_message(span_info("[user] rings [src]!"))
	playsound(src, 'modular_rmh/sound/misc/bell_small.ogg', 100, extrarange = 5)
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), src.cooldown)

	var/message
	if(src.specific_location)
		message = span_blue("I hear the distant ringing of a bell. I'm being called to the <b>[src.specific_location]</b>.")
	else
		message = span_blue("I hear the distant ringing of a bell. Someone is calling for service.")

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.mind && H.mind.assigned_role)
			for(var/path in src.notify_titles)
				if(istype(H.mind.assigned_role, path))
					to_chat(H, message)
					break

/obj/structure/call_bell/proc/reset_cooldown()
	src.visible_message(span_notice("[src] is ready for use again."))
	src.on_cooldown = FALSE

// SMALL CALL BELL - USE THIS ICON STATE IF YOU WANT TO PLACE THE BELL ON THE TABLE
/obj/structure/call_bell/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

//TOWNHALL BELLS

/obj/structure/call_bell/townhall_rulers
	name = "town hall officials bell"
	notify_titles = list(
		/datum/job/burgmeister,
		/datum/job/advclass/burgmeister/marshall,
		/datum/job/advclass/burgmeister/elected,
		/datum/job/advclass/burgmeister/patrician,
		/datum/job/advclass/burgmeister/scholar,
		/datum/job/councilor,
		/datum/job/advclass/councilor/adjutant,
		/datum/job/advclass/councilor/clerk,
		/datum/job/advclass/councilor/advisor,
		/datum/job/advclass/councilor/spymaster
	)
	specific_location = "Town Hall"

/obj/structure/call_bell/townhall_servant
	name = "town hall servants bell"
	notify_titles = list(
		/datum/job/servant,
		/datum/job/advclass/servant/butler,
		/datum/job/advclass/servant/maid,
		/datum/job/advclass/servant/concubine
	)
	specific_location = "Town Hall's quarters"

//TOWN WATCH BELLS

/obj/structure/call_bell/townwatch
	name = "town watch bell"
	notify_titles = list(
		/datum/job/watch_captain,
		/datum/job/watch_sergeant,
		/datum/job/watch_veteran,
		/datum/job/watch_warden,
		/datum/job/watch_guard,
		/datum/job/advclass/watch_guard/bulwark,
		/datum/job/advclass/watch_guard/halberdier,
		/datum/job/advclass/watch_guard/sentinel
	)
	specific_location = "Watch"

//TOWNMOUTH BELLS

/obj/structure/call_bell/loudmouth
	name = "townmouth's bell"
	notify_titles = list(
		/datum/job/advclass/towner/town_mouth
	)
	specific_location = "Tavern's second floor"

//CHAPEL BELLS

/obj/structure/call_bell/chapel
	name = "chapel bell"
	notify_titles = list(
		/datum/job/moon_priest,
		/datum/job/heart_priest,
		/datum/job/acolyte,
		/datum/job/advclass/acolyte/base,
		/datum/job/advclass/acolyte/selune,
		/datum/job/advclass/acolyte/nun,
		/datum/job/advclass/acolyte/nun_regal,
		/datum/job/advclass/acolyte/warrior_priest,
		/datum/job/advclass/acolyte/love
	)
	specific_location = "Temple"

//SCHOLARS BELLS

/obj/structure/call_bell/wizards
	name = "wizard's bell"
	notify_titles = list(
		/datum/job/guild_master_wizard,
		/datum/job/guild_wizard,
		/datum/job/advclass/guild_wizard/expert,
		/datum/job/advclass/guild_wizard/adept,
		/datum/job/guild_wizard_apprentice
	)
	specific_location = "Academy"

/obj/structure/call_bell/archive
	name = "archive bell"
	notify_titles = list(
		/datum/job/advclass/town_scholar/archivist,
		/datum/job/advclass/town_scholar_apprentice/librarian
	)
	specific_location = "Archives"

/obj/structure/call_bell/artificer
	name = "artificer's bell"
	notify_titles = list(
		/datum/job/advclass/town_scholar/artificer,
		/datum/job/advclass/town_scholar_apprentice/artificer
	)
	specific_location = "Workshop"

/obj/structure/call_bell/physician
	name = "physician's bell"
	notify_titles = list(
		/datum/job/advclass/town_scholar/town_physician,
		/datum/job/advclass/town_scholar_apprentice/physician_apprentice
	)
	specific_location = "Clinic"

//WATERDEEP GUILD BELLS

/obj/structure/call_bell/guild_guard
	name = "guild guard bell"
	notify_titles = list(
		/datum/job/waterdeep_guild_guard
	)
	specific_location = "Guild Guard"

/obj/structure/call_bell/bank
	name = "bank bell"
	notify_titles = list(
		/datum/job/waterdeep_banker,
		/datum/job/advclass/waterdeep_guild_assistant/banker_assistant
	)
	specific_location = "Bank"

/obj/structure/call_bell/merchant
	name = "merchant bell"
	notify_titles = list(
		/datum/job/waterdeep_merchant,
		/datum/job/advclass/waterdeep_guild_assistant/shophand
	)
	specific_location = "Shop Front"

//TAVERN BELLS

/obj/structure/call_bell/adventurers_guild
	name = "adventurers guild bell"
	notify_titles = list(
		/datum/job/adventurers_guildmaster,
		/datum/job/advclass/adventurers_guildmaster/ranger,
		/datum/job/advclass/adventurers_guildmaster/eldritch_knight,
		/datum/job/adventurers_assistant
	)
	specific_location = "Guild Desk"

/obj/structure/call_bell/tavern
	name = "tavern bell"
	notify_titles = list(
		/datum/job/innkeep,
		/datum/job/cook,
		/datum/job/matron,
		/datum/job/tavern_wench,
		/datum/job/advclass/tavern_wench/waitress,
		/datum/job/advclass/tavern_wench/courtesan,
		/datum/job/advclass/tavern_wench/bath_wench
	)
	specific_location = "Tavern Front"

/obj/structure/call_bell/baths
	name = "baths bell"
	notify_titles = list(
		/datum/job/matron,
		/datum/job/tavern_wench,
		/datum/job/advclass/tavern_wench/waitress,
		/datum/job/advclass/tavern_wench/courtesan,
		/datum/job/advclass/tavern_wench/bath_wench
	)
	specific_location = "Baths"

//ARTISANS BELLS
/obj/structure/call_bell/blacksmith
	name = "blacksmith bell"
	notify_titles = list(
		/datum/job/advclass/artisan/blacksmith,
		/datum/job/advclass/artisan_apprentice/blacksmith
	)
	specific_location = "Smithy"

/obj/structure/call_bell/tailor
	name = "tailor bell"
	notify_titles = list(
		/datum/job/advclass/artisan/tailor,
		/datum/job/advclass/artisan_apprentice/tailor
	)
	specific_location = "Tailor's Shop"

/obj/structure/call_bell/mason
	name = "mason bell"
	notify_titles = list(
		/datum/job/advclass/artisan/mason,
		/datum/job/advclass/artisan_apprentice/mason
	)
	specific_location = "Mason's Shop"

/obj/structure/call_bell/carpenter
	name = "carpenter bell"
	notify_titles = list(
		/datum/job/advclass/artisan/carpenter,
		/datum/job/advclass/artisan_apprentice/carpenter
	)
	specific_location = "Carpenter's Shop"

// OUTSIDERS BELLS
/obj/structure/call_bell/forest_ranger
	name = "forest rangers bell"
	notify_titles = list(
		/datum/job/forest_warden,
		/datum/job/forest_ranger,
		/datum/job/advclass/forest_ranger/pathfinder,
		/datum/job/advclass/forest_ranger/scout,
		/datum/job/advclass/forest_ranger/vanguard
	)
	specific_location = "Rangers' Post"

/obj/structure/call_bell/grove_druid
	name = "grove druid bell"
	notify_titles = list(
		/datum/job/grove_druid
	)
	specific_location = "Grove"

/obj/structure/call_bell/swamp_witch
	name = "swamp witch bell"
	notify_titles = list(
		/datum/job/swamp_witch,
		/datum/job/advclass/swamp_witch/alchemist,
		/datum/job/advclass/swamp_witch/cinder,
		/datum/job/advclass/swamp_witch/hex,
		/datum/job/advclass/swamp_witch/wild
	)
	specific_location = "my home"

// SMALL VARIANTS

/obj/structure/call_bell/townhall_rulers/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/townhall_servant/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/townwatch/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/loudmouth/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/chapel/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/wizards/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/archive/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/artificer/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/physician/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/guild_guard/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/bank/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/merchant/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/adventurers_guild/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/tavern/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/baths/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/blacksmith/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/tailor/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/mason/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/carpenter/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/forest_ranger/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/grove_druid/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"

/obj/structure/call_bell/swamp_witch/small
	icon = 'modular_rmh/icons/obj/structures/call_bells.dmi'
	icon_state = "bell_common"
