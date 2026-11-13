GLOBAL_LIST_EMPTY(keys_by_ckey)						//all client ckeys, and their associated keys (keys_by_ckey[ckey] -> key), isn't cleared when the client leaves the game
GLOBAL_LIST_EMPTY(clients)							//all clients
GLOBAL_LIST_EMPTY(sense_relay_mobs)					//mobs that see and hear from another atom, e.g. headless dullahans
GLOBAL_LIST_EMPTY(admins)							//all clients whom are admins
GLOBAL_PROTECT(admins)
GLOBAL_LIST_EMPTY(deadmins)							//all ckeys who have used the de-admin verb.

GLOBAL_LIST_EMPTY(directory)							//all ckeys with associated client
GLOBAL_LIST_EMPTY(stealthminID)						//reference list with IDs that store ckeys, for stealthmins

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_LIST_EMPTY(player_list)				//all mobs **with clients attached**.
GLOBAL_LIST_EMPTY(mob_list)					//all mobs, including clientless
GLOBAL_LIST_EMPTY(mob_directory)			//mob_id -> mob
GLOBAL_LIST_EMPTY(alive_mob_list)			//all alive mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(suicided_mob_list)		//contains a list of all mobs that suicided, including their associated ghosts.
GLOBAL_LIST_EMPTY(drones_list)
GLOBAL_LIST_EMPTY(dead_mob_list)			//all dead mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(joined_player_list)		//all ckeys of client's that have joined the game at round-start or as a latejoin.
GLOBAL_LIST_EMPTY(rune_roundstart_mobs)		//all mobs that are checked for rune resurrection.
GLOBAL_LIST_EMPTY(new_player_list)			//all /mob/dead/new_player, in theory all should have clients and those that don't are in the process of spawning and get deleted when done.
GLOBAL_LIST_EMPTY(pre_setup_antags)			//minds that have been picked as antag by the gamemode. removed as antag datums are set.
GLOBAL_LIST_EMPTY(silicon_mobs)				//all silicon mobs
GLOBAL_LIST_EMPTY(mob_living_list)				//all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(carbon_list)				//all instances of /mob/living/carbon and subtypes, notably does not contain brains or simple animals
GLOBAL_LIST_EMPTY(human_list)				//all instances of /mob/living/carbon/human and subtypes except for /mob/living/carbon/human/dummy
GLOBAL_LIST_EMPTY(spirit_list)				//all instances of /mob/living/carbon/spirit and subtypes (the underworld ghosts)
GLOBAL_LIST_EMPTY(ai_list)
GLOBAL_LIST_EMPTY(pai_list)
GLOBAL_LIST_EMPTY(available_ai_shells)
GLOBAL_LIST_EMPTY(spidermobs)				//all sentient spider mobs
GLOBAL_LIST_EMPTY(bots_list)
GLOBAL_LIST_EMPTY(aiEyes)

GLOBAL_LIST_EMPTY(language_datum_instances)
GLOBAL_LIST_EMPTY(all_languages)

/// Associative list of species id to type
GLOBAL_LIST_EMPTY(species_list)

GLOBAL_LIST_EMPTY(latejoin_ai_cores)

GLOBAL_LIST_EMPTY(mob_config_movespeed_type_lookup)

GLOBAL_LIST_EMPTY(emote_list)
/// Assoc list used for ordering races in displayed menus //not used actually lmao
/*GLOBAL_LIST_INIT(species_order_list, list(
	SPEC_ID_HUMAN_SPACE = 1,
	SPEC_ID_HUMEN = 2,
	SPEC_ID_ELF = 3,
	SPEC_ID_ELF_W = 4,
	SPEC_ID_HALF_ELF = 5,
	SPEC_ID_DROW = 6,
	SPEC_ID_HALF_DROW = 7,
	SPEC_ID_TIEFLING = 8,
	SPEC_ID_HALFLING = 9,
	SPEC_ID_DWARF = 10,
	SPEC_ID_DUERGAR = 11,
	SPEC_ID_GNOME = 12,
	SPEC_ID_GNOME_D = 13,
	SPEC_ID_AASIMAR = 14,
	SPEC_ID_HALF_ORC = 15,
	SPEC_ID_RAKSHARI = 16,
	SPEC_ID_KOBOLD = 17,
	SPEC_ID_HOLLOWKIN = 18,
	SPEC_ID_HARPY = 19,
	SPEC_ID_TRITON = 20,
	SPEC_ID_MEDICATOR = 21,
	SPEC_ID_AUTOMATON = 22,
	SPEC_ID_BEASTKIN = 23,
	SPEC_ID_BEASTKINSMALL = 24,
	SPEC_ID_HALF_BEASTKINSMALL = 25,
	SPEC_ID_GYTH = 26,
	SPEC_ID_DRAGONBORN = 27,
	SPEC_ID_TRUE_ORC = 28,
	SPEC_ID_PLAYER_GOBLIN = 29,
	SPEC_ID_YUANTI = 30,
	SPEC_ID_TAUR_KIN = 31,
	SPEC_ID_MINOTAUR = 32,
	SPEC_ID_DRYDER = 33,
	SPEC_ID_LIZARDFOLK = 34,
	SPEC_ID_TABAXI = 35,
))*/
GLOBAL_LIST_INIT(dangerous_turfs, typecacheof(list(
	/turf/open/lava,
	/turf/open/openspace,
	/turf/open/water/acid,
	)))

/// Hazards that sit on a turf as objects instead of being turf types themselves.
/// GLOB.dangerous_turfs is matched against the turf's own type, so it can never catch these -
/// which is why wandering AI walked straight into bushes and fires and wore itself to death.
GLOBAL_LIST_INIT(dangerous_turf_contents, typecacheof(list(
	/obj/structure/flora/grass/bush,
	/obj/effect/abstract/fire,
	/obj/structure/trap,
	)))

/**
 * TRUE if an AI pawn stepping onto target_turf would hurt itself.
 *
 * destination is the turf the mob is actually trying to reach. Object hazards are ignored there so a
 * mob can still close on prey hiding inside a bush; genuinely lethal turfs (lava, openspace) are
 * refused regardless of where the mob wanted to go.
 */
/proc/ai_turf_is_hazardous(turf/target_turf, turf/destination)
	if(!target_turf)
		return FALSE
	if(is_type_in_typecache(target_turf, GLOB.dangerous_turfs))
		return TRUE
	if(destination && target_turf == destination)
		return FALSE
	for(var/atom/movable/thing as anything in target_turf)
		if(is_type_in_typecache(thing, GLOB.dangerous_turf_contents))
			return TRUE
		if(istype(thing, /obj/machinery/light/fueled))
			var/obj/machinery/light/fueled/fire = thing
			if(fire.burns_crossers())
				return TRUE
	return FALSE

/proc/update_config_movespeed_type_lookup(update_mobs = TRUE)
	var/list/mob_types = list()
	var/list/entry_value = CONFIG_GET(keyed_list/multiplicative_movespeed)
	for(var/path in entry_value)
		var/value = entry_value[path]
		if(!value)
			continue
		for(var/subpath in typesof(path))
			mob_types[subpath] = value
	GLOB.mob_config_movespeed_type_lookup = mob_types
	if(update_mobs)
		update_mob_config_movespeeds()

/proc/update_mob_config_movespeeds()
	for(var/mob/M as anything in GLOB.mob_list)
		M.update_config_movespeed()

/proc/init_emote_list()
	. = list()
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		if(!.[E.key])
			.[E.key] = list(E)
		else
			.[E.key] += E

		if(!.[E.key_third_person])
			.[E.key_third_person] = list(E)
		else
			.[E.key_third_person] |= E

/// Cultures can't be interacted with so we only ever need as many datums as exist
GLOBAL_LIST_INIT(culture_singletons, init_culture_singletons())

/proc/init_culture_singletons()
	var/list/culture_list = list()
	for(var/datum/culture/culture as anything in subtypesof(/datum/culture))
		if(IS_ABSTRACT(culture))
			continue
		culture_list[culture] = new culture()
	return culture_list
