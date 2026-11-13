//MAIN MAP AREAS//

/area/indoors/succubus_lair
	name = "lair (Succubus)"
	first_time_text = "THE INFERNAL BOUDOIR"
	ceiling_protected = TRUE


/area/outdoors/exposed/rmh
	icon_state = "exposed"
	background_track = 'modular_rmh/sound/music/area/field_day.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/field_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/field_night.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/field_dawn.ogg'

// - - - - - -
//FORESTS
// - - - - - -
/area/outdoors/rmh_field
	name = "Rivermist Hollow Outskirts"
	icon_state = "rtfield"
	soundenv = 19
//	ambush_mobs = null
	first_time_text = "RIVERMIST HOLLOW OUTSKIRTS"
	background_track = 'modular_rmh/sound/music/area/field_day.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/field_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/field_night.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/field_dawn.ogg'
	ambient_index = AMBIENCE_BIRDS
	converted_type = /area/indoors/shelter/rmh_field
	//deathsight_message = "somewhere nar the town"

/area/indoors/shelter/rmh_field
	icon_state = "rtfield"
	background_track = 'modular_rmh/sound/music/area/field_day.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/field_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/field_night.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/field_dawn.ogg'
	droning_index = DRONING_INDOORS
	ambient_index = AMBIENCE_BIRDS

/area/outdoors/rmh_field/oldmill
	name = "Ruined windmill"
	first_time_text = "RUINED WINDMILL"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	background_track = 'modular_rmh/sound/music/area/windmill.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/windmill.ogg'
	background_track_night = 'modular_rmh/sound/music/area/windmill.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/windmill.ogg'
	icon_state = "woods_n"

/area/outdoors/rmh_field/north
	name = "North Forest"
	first_time_text = "NORTH FOREST"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "woods_n"
	soundenv = 19
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/grass,
				/turf/open/floor/dirt)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/wolf = 60,
				/mob/living/simple_animal/hostile/retaliate/fox = 50,
				/mob/living/simple_animal/hostile/retaliate/bobcat = 50,
				/mob/living/simple_animal/hostile/retaliate/bigrat = 30,
				/mob/living/simple_animal/hostile/retaliate/fae/sprite = 20)
	threat_region = THREAT_REGION_RMH_NORTH_DANGER

/area/outdoors/rmh_field/west
	name = "West Forest"
	first_time_text = "WEST FOREST"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "woods_w"

/area/outdoors/rmh_field/east
	name = "East Forest"
	first_time_text = "EAST FOREST"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "woods_e"

/area/outdoors/rmh_field/camp
	name = "Encampment On The Hill"
	first_time_text = "ENCAMPMENT ON THE HILL"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "camp"

/area/outdoors/rmh_field/druid
	name = "Druid Grove"
	first_time_text = "DRUID GROVE"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "druid"

/area/outdoors/rmh_river
	name = "river"
	icon_state = "river"
	droning_index = DRONING_RIVER_DAY
	droning_index_night = DRONING_RIVER_NIGHT
	ambient_index = AMBIENCE_FROG
	ambient_index_night = AMBIENCE_FOREST
	background_track = 'sound/music/area/forest.ogg'
	background_track_dusk = 'sound/music/area/septimus.ogg'
	background_track_night = 'sound/music/area/forestnight.ogg'
	converted_type = /area/indoors/shelter/rmh_field

/area/outdoors/rmh_magelake
	name = "lake"
	icon_state = "lake"
	droning_index = DRONING_RIVER_DAY
	droning_index_night = DRONING_RIVER_NIGHT
	ambient_index = AMBIENCE_FROG
	ambient_index_night = AMBIENCE_FOREST
	background_track = 'sound/music/area/forest.ogg'
	background_track_dusk = 'sound/music/area/septimus.ogg'
	background_track_night = 'sound/music/area/forestnight.ogg'
	converted_type = /area/indoors/shelter/rmh_field

/area/outdoors/rmh_eilistraee
	name = "eilistraee glade"
	icon_state = "woods"
	droning_index = DRONING_FOREST_DAY
	droning_index_night = DRONING_FOREST_NIGHT
	ambient_index = AMBIENCE_BIRDS
	ambient_index_night = AMBIENCE_FOREST
	background_track = 'sound/music/area/forest.ogg'
	background_track_dusk = 'sound/music/area/septimus.ogg'
	background_track_night = 'sound/music/area/forestnight.ogg'
	soundenv = 15
	converted_type = /area/indoors/shelter/rmh_field

/area/under/rmh_eilistraeelake
	name = "eilistraee lake"
	icon_state = "lake"
	droning_index = DRONING_LAKE
	ambient_index = AMBIENCE_CAVE
	ambient_index_night = AMBIENCE_GENERIC

/area/outdoors/rmh_field/basinruin
	name = "Ruined Fort"
	first_time_text = "RUINED FORT"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	background_track_dusk = 'modular_rmh/sound/music/area/basinruins.ogg'
	background_track_night = 'modular_rmh/sound/music/area/basinruins.ogg'
	icon_state = "rfort"
	soundenv = 19
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/grass,
				/turf/open/floor/grass/healthy,
				/turf/open/floor/dirt/road,
				/turf/open/floor/dirt,
				/turf/open/floor/cobble/alt,
				/turf/open/floor/cobble,
				/turf/open/floor/cobblerock)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/wolf = 60,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 50,
				/mob/living/carbon/human/species/goblin/npc/ambush = 50,
				/mob/living/simple_animal/hostile/retaliate/direbear = 20)
	converted_type = /area/indoors/shelter/rmh_field
	threat_region = THREAT_REGION_RMH_BASIN_RUINS
// - - - - - -
//MOUNTAINS
// - - - - - -
/area/outdoors/mountains/rmh_mountains
	name = "Dusk Spire Mountains Pass"
	icon_state = "decap"
	background_track = 'sound/music/area/decap.ogg'
	background_track_dusk = 'sound/music/area/decap.ogg'
	background_track_night = 'sound/music/area/decap.ogg'
	first_time_text = "DUSK SPIRE PASS"
	ambush_times = null
	converted_type = /area/indoors/shelter/mountains/rmh_mountains
	//deathsight_message = "a spire pass"

/area/outdoors/rmh_field/north_mountain
	name = "Northern Mountains Basin"
	first_time_text = "NORTHERN MOUNTAINS BASIN"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "n_basin"
	soundenv = 19
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/grass,
				/turf/open/floor/grass/healthy,
				/turf/open/floor/dirt/road,
				/turf/open/floor/dirt,
				/turf/open/floor/cobble/alt,
				/turf/open/floor/cobble,
				/turf/open/floor/cobblerock)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/wolf = 60,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 50,
				/mob/living/carbon/human/species/goblin/npc/ambush = 50,
				/mob/living/simple_animal/hostile/retaliate/direbear = 20)
	converted_type = /area/indoors/shelter/rmh_field
	threat_region = THREAT_REGION_RMH_NORTH_DANGER

/area/indoors/shelter/mountains/rmh_mountains
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'sound/music/area/decap.ogg'
	background_track_dusk = 'sound/music/area/decap.ogg'
	background_track_night = 'sound/music/area/decap.ogg'

// - - - - - -
//TRANSITIONS
// - - - - - -
/area/outdoors/rmh_field/tavel
	name = "Travel"
	first_time_text = "TRAVEL"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "travel"

/area/outdoors/rmh_field/tavel/desert
	name = "To Coastal Desert"
	first_time_text = "TO COASTAL DESERT"

/area/outdoors/rmh_field/tavel/swamps
	name = "To Green Swamps"
	first_time_text = "TO GREEN SWAMPS"

/area/outdoors/rmh_field/tavel/forest
	name = "To Dark Forest"
	first_time_text = "TO DARK FOREST"

/area/outdoors/rmh_field/tavel/mountain
	name = "To Mountain Pass"
	first_time_text = "TO MOUNTAIN PASS"

/area/outdoors/rmh_field/tavel/vampires
	name = "To Dusk Spire"
	first_time_text = "TO DUSK SPIRE"

// - - - - - -
//ANTAGS
// - - - - - -
/area/indoors/cave/rmh_cave/minotaur
	name = "Abandoned Hall"
	first_time_text = "ABANDONED HALL"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "minotaur"
	//deathsight_message = "a minotaur camp"
	ceiling_protected = TRUE


/area/indoors/cave/rmh_cave/greenskins
	name = "Greenskins Encampment"
	first_time_text = "GREENSKINS ENCAMPMENT"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "orc"
	//deathsight_message = "a greenskins camp"

/area/indoors/cave/rmh_cave/gnolls
	name = "Gnoll Warren"
	first_time_text = "GNOLL WARREN"
	icon_state = "cave"
	droning_index = DRONING_CAVE_GENERIC
	ambient_index = AMBIENCE_CAVE
	background_track = 'sound/music/area/caves.ogg'
	background_track_dusk = 'sound/music/area/caves.ogg'
	background_track_night = 'sound/music/area/caves.ogg'
	background_track_dawn = 'sound/music/area/caves.ogg'
	soundenv = 8
	ambush_times = null
	ambush_types = null
	ambush_mobs = null
	ceiling_protected = TRUE
	//deathsight_message = "a gnoll warren"

/area/indoors/cave/rmh_cave/gnolls/den
	name = "Pack Leader's Den"
	first_time_text = "PACK LEADER'S DEN"

/area/indoors/cave/rmh_cave/gnolls/tunnels
	name = "Gnoll Tunnels"
	first_time_text = "GNOLL TUNNELS"

/area/indoors/cave/rmh_cave/drider
	name = "Webbed Hollow"
	first_time_text = "WEBBED HOLLOW"
	icon_state = "underworld"
	droning_index = DRONING_CAVE_WET
	ambient_index = AMBIENCE_CAVE
	background_track = 'sound/music/area/dungeon2.ogg'
	background_track_dusk = 'sound/music/area/dungeon2.ogg'
	background_track_night = 'sound/music/area/dungeon2.ogg'
	background_track_dawn = 'sound/music/area/dungeon2.ogg'
	soundenv = 8
	ambush_times = null
	ambush_types = null
	ambush_mobs = null
	ceiling_protected = TRUE
	//deathsight_message = "a webbed hollow"

/area/indoors/cave/rmh_cave/drider/nest
	name = "Drider Nest"
	first_time_text = "DRIDER NEST"

/area/indoors/cave/rmh_cave/drider/tunnels
	name = "Silk Tunnels"
	first_time_text = "SILK TUNNELS"

// - - - - - -
//TOWN
// - - - - - -
/area/outdoors/town/rmh
	name = "Rivermist Hollow outdoors"
	icon_state = "town"
	first_time_text = "RIVERMIST HOLLOW"
	background_track = 'modular_rmh/sound/music/area/town_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/town_dawn.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/town_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/town_night.ogg'
	ambient_index = AMBIENCE_BIRDS
	converted_type = /area/indoors/shelter/town/rmh

/area/outdoors/town/rmh/ruinedzone
	name = "Town's Ruin"
	icon_state = "town"
	first_time_text = "RUINS"
	background_track = 'modular_rmh/sound/music/area/ruintown.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/town_dawn.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/town_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/town_night.ogg'
	ambient_index = AMBIENCE_BIRDS
	converted_type = /area/indoors/shelter/town/rmh

/area/outdoors/town/rmh/roofs
	name = "Rivermist Hollow Rooftops"
	icon_state = "roofs"
	droning_index = DRONING_MOUNTAIN
	ambient_index = AMBIENCE_BIRDS
	//spookysounds = SPOOKY_GEN
	//spookynight = SPOOKY_GEN
	background_track = 'modular_rmh/sound/music/area/town_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/town_dawn.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/town_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/town_night.ogg'
	soundenv = 17
	converted_type = /area/indoors/shelter/town/rmh/roofs

/area/outdoors/town/rmh/livingquart
	name = "Living Outskirts"
	icon_state = "camp"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	soundenv = 19
//	ambush_mobs = null
	first_time_text = "LIVING OUTSKIRTS"
	background_track = 'modular_rmh/sound/music/area/field_day.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/field_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/field_night.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/field_dawn.ogg'
	ambient_index = AMBIENCE_BIRDS
	converted_type = /area/indoors/shelter/town/rmh

/area/outdoors/rmh_platz
	name = "platz"
	icon_state = "garrison"
	background_track = 'modular_rmh/sound/music/area/town_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/town_dawn.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/town_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/town_night.ogg'
	converted_type = /area/indoors/shelter/town/rmh/roofs

/area/indoors/town/rmh
	name = "indoors"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/town_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/town_dawn.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/town_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/town_night.ogg'
	droning_index = DRONING_INDOORS
	ambient_index = AMBIENCE_BIRDS
	converted_type = /area/outdoors/exposed/town/rmh
	//deathsight_message = "the town of Rivermist Hollow and all its bustling souls"

/area/indoors/shelter/town/rmh
	name = "Rivermist Hollow Shelter Indoors"
	icon_state = "town"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/shelter/town/rmh/roofs
	name = "Rivermist Hollow Shelter Rooftops"
	icon_state = "roofs"

/area/under/town/rmh/treasury
	name = "treasury"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "treasury"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5
	converted_type = /area/outdoors/exposed/rmh/under/basement
	ceiling_protected = TRUE

/area/under/town/rmh/bank
	name = "bank vault"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "bank_vault"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5
	converted_type = /area/outdoors/exposed/rmh/under/basement
	ceiling_protected = TRUE

/area/indoors/town/rmh/garrison
	name = "Town Guardhouse"
	first_time_text = "TOWN GUARDHOUSE"
	icon_state = "garrison"
	background_track = 'sound/music/area/manorgarri.ogg'
	background_track_dusk = 'sound/music/area/manorgarri.ogg'
	background_track_night = 'sound/music/area/manorgarri.ogg'
	converted_type = /area/outdoors/exposed/town/rmh

/area/indoors/town/rmh/garrison/wall
	name = "Town Wall"
	icon_state = "wall"
	first_time_text = "TOWN WALL"

/area/indoors/town/rmh/cell
	name = "Town Dungeon"
	first_time_text = "TOWN DUNGEON"
	icon_state = "cell"
	//spookysounds = SPOOKY_DUNGEON
	//spookynight = SPOOKY_DUNGEON
	background_track = 'sound/music/area/manorgarri.ogg'
	background_track_dusk = 'sound/music/area/manorgarri.ogg'
	background_track_night = 'sound/music/area/manorgarri.ogg'
	converted_type = /area/outdoors/exposed/town/rmh
	cell_area = TRUE

/area/indoors/town/rmh/windmill
	name = "Old Windmill"
	first_time_text = "WINDMILL"
	icon_state = "cell"
	//spookysounds = SPOOKY_DUNGEON
	//spookynight = SPOOKY_DUNGEON
	background_track = 'modular_rmh/sound/music/area/windmill.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/windmill.ogg'
	background_track_night = 'modular_rmh/sound/music/area/windmill.ogg'
	converted_type = /area/outdoors/exposed/town/rmh
	cell_area = TRUE

/area/under/town/rmh/sewer
	name = "Rivermist Hollow Sewers"
	first_time_text = "RIVERMIST HOLLOW SEWERS"
	icon_state = "sewer"
	droning_index = DRONING_RAIN_SEWER
	ambient_index = AMBIENCE_CAVE
	//spookysounds = SPOOKY_RATS
	//spookynight = SPOOKY_RATS
	background_track = 'modular_rmh/sound/music/area/sewers1.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/sewers2.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/sewers3.ogg'
	background_track_night = 'modular_rmh/sound/music/area/sewers4.ogg'
	//ambientrain = RAIN_SEWER
	soundenv = 21
	converted_type = /area/outdoors/exposed/under/rmh/sewer

/area/under/town/rmh/sewer
	name = "Rivermist Hollow Sewers"
	first_time_text = "RIVERMIST HOLLOW SEWERS"
	icon_state = "sewer"
	droning_index = DRONING_CAVE_WET
	ambient_index = AMBIENCE_CAVE
	//spookysounds = SPOOKY_RATS
	//spookynight = SPOOKY_RATS
	background_track = 'sound/music/area/sewers.ogg'
	background_track_dusk = 'sound/music/area/sewers.ogg'
	background_track_night = 'sound/music/area/sewers.ogg'
	//ambientrain = RAIN_SEWER
	soundenv = 21
	converted_type = /area/outdoors/exposed/under/rmh/sewer

/area/outdoors/exposed/under/rmh/sewer
	name = "Rivermist Hollow Sewers"
	first_time_text = "RIVERMIST HOLLOW SEWERS"
	icon_state = "sewer"
	background_track = 'sound/music/area/sewers.ogg'
	background_track_dusk = 'sound/music/area/sewers.ogg'
	background_track_night = 'sound/music/area/sewers.ogg'

/area/outdoors/exposed/magiciantower
	name = "Wizard's Tower"
	first_time_text = "WIZARD'S TOWER"
	icon_state = "living"
	background_track = 'sound/music/area/magiciantower.ogg'
	background_track_dusk = 'sound/music/area/magiciantower.ogg'
	background_track_night = 'sound/music/area/magiciantower.ogg'

/area/indoors/town/rmh/magician/pass
	name = "Secret Pass"
	first_time_text = "SECRET PASS"
	icon_state = "living"
	background_track = 'sound/music/area/magiciantower.ogg'
	background_track_dusk = 'sound/music/area/magiciantower.ogg'
	background_track_night = 'sound/music/area/magiciantower.ogg'
	ceiling_protected = TRUE

/area/indoors/town/rmh/barber
	name = "Town Barber"
	first_time_text = "TOWN BARBER"

/area/indoors/town/rmh/farm
	name = "Town Farm"
	first_time_text = "TOWN FARM"

/area/outdoors/exposed/town/rmh/farm
	name = "Town Farm"
	first_time_text = "TOWN FARM"
	icon_state = "outdoors"

/area/indoors/town/rmh/bank
	name = "Town Bank"
	first_time_text = "TOWN BANK"

/area/indoors/town/rmh/sawmill
	name = "Town Sawmill"
	first_time_text = "TOWN SAWMILL"

/area/indoors/town/rmh/library
	name = "Town Library"
	first_time_text = "TOWN LIBRARY"

/area/indoors/town/rmh/bath
	name = "Town Baths"
	first_time_text = "TOWN BATHS"
	icon_state = "bath"
	background_track = 'modular_rmh/sound/music/area/baths.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/baths_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/baths_night.ogg'
	converted_type = /area/outdoors/exposed/rmh/bath

/area/outdoors/exposed/rmh/bath
	name = "Town Baths"
	background_track = 'modular_rmh/sound/music/area/baths.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/baths_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/baths_night.ogg'

/area/indoors/town/rmh/crafters_guild
	name = "Crafters Guild"
	first_time_text = "CRAFTERS GUILD"

/area/indoors/town/rmh/crafters_guild/under
	name = "Crafters Guild"
	first_time_text = "CRAFTERS GUILD"
	icon_state = "dwarfin"
	background_track = 'sound/music/area/dwarf.ogg'
	background_track_dusk = 'sound/music/area/dwarf.ogg'
	background_track_night = 'sound/music/area/dwarf.ogg'
	converted_type = /area/outdoors/exposed/rmh/crafters

/area/outdoors/exposed/rmh/crafters
	name = "Crafters Guild"
	first_time_text = "CRAFTERS GUILD"
	icon_state = "dwarf"
	background_track = 'sound/music/area/dwarf.ogg'
	background_track_dusk = 'sound/music/area/dwarf.ogg'
	background_track_night = 'sound/music/area/dwarf.ogg'

/area/indoors/town/rmh/merchant
	name = "Merchants Guild"
	first_time_text = "MERCHANTS GUILD"
	icon_state = "shop"
	background_track = 'sound/music/area/shop.ogg'
	background_track_dusk = 'sound/music/area/shop.ogg'
	background_track_night = 'sound/music/area/shop.ogg'
	converted_type = /area/outdoors/exposed/rmh/merchant

/area/outdoors/exposed/rmh/merchant
	name = "Merchants Guild"
	first_time_text = "MERCHANTS GUILD"
	icon_state = "shop"
	background_track = 'sound/music/area/shop.ogg'

/area/indoors/town/rmh/tavern
	name = "Drunk Dwarf Tavern"
	first_time_text = "DRUNK DWARF TAVERN"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "tavern"
	droning_index = DRONING_INDOORS
	ambient_index = DRONING_INDOORS
	ambient_index_night = DRONING_INDOORS
	background_track = 'modular_rmh/sound/music/area/genericcalm.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/genericchill.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/genericflutey.ogg'
	background_track_night = 'modular_rmh/sound/music/area/genericrevelry.ogg'
	converted_type = /area/outdoors/exposed/rmh/tavern
	tavern_area = TRUE

/area/outdoors/exposed/rmh/tavern
	name = "Drunk Dwarf Tavern"
	first_time_text = "DRUNK DWARF TAVERN"
	background_track = 'sound/silence.ogg'
	background_track_dusk = 'sound/silence.ogg'
	background_track_night = 'sound/silence.ogg'
	tavern_area = TRUE

/area/indoors/town/rmh/town_hall
	name = "Town Hall"
	first_time_text = "TOWN HALL"

/area/indoors/town/rmh/chapel
	name = "The Town Chapel"
	first_time_text = "THE TOWN CHAPEL"
	icon_state = "church"
	background_track = 'sound/music/area/church.ogg'
	background_track_dusk = 'sound/music/area/church.ogg'
	background_track_night = 'sound/music/area/churchdawn.ogg'
	holy_area = TRUE
	background_track_dawn = 'sound/music/area/churchdawn.ogg'
	converted_type = /area/outdoors/exposed/church
	//deathsight_message = "a chapel"

/area/outdoors/exposed/rmh/chapel
	name = "The Town Chapel"
	first_time_text = "THE TOWN CHAPEL"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "outdoors"
	background_track = 'sound/music/area/church.ogg'
	background_track_dusk = 'sound/music/area/church.ogg'
	background_track_night = 'sound/music/area/churchdawn.ogg'
	background_track_dawn = 'sound/music/area/churchdawn.ogg'
	//deathsight_message = "a chapel"

/area/indoors/town/rmh/craft
	name = "craft's indoors"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'
	droning_index = DRONING_INDOORS
	ambient_index = DRONING_INDOORS

/area/indoors/town/rmh/craft/artificer
	name = "artificer's indoors"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'


/area/indoors/town/rmh/craft/blacksmith
	name = "blacksmith's indoors"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'


/area/indoors/town/rmh/craft/tailor
	name = "tailor's indoors"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/craft/clinic
	name = "clinic's indoors"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/craft/apothecary
	name = "apothecary's indoors"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/greenhouse
	name = "greenhouse"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'


/area/indoors/town/rmh/loudmouth
	name = "loudmouth's house"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'


/area/indoors/town/rmh/farm
	name = "farm's zones"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'
	droning_index = DRONING_INDOORS
	ambient_index = DRONING_INDOORS

/area/indoors/town/rmh/farm
	name = "farm's zones"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/farm/house
	name = "farm's house"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/farm/ambar
	name = "ambar"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/farm/henhouse
	name = "henhouse"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/farm/stall
	name = "stall"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/farm/goat_rue
	name = "goat's rue"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'

/area/indoors/town/rmh/magician
	name = "Mage's Guild"
	icon_state = "living"
	ambient_index = AMBIENCE_MYSTICAL
	converted_type = /area/outdoors/rmh_field/rmh_mageporch

/area/outdoors/rmh_field/rmh_mageporch
	name = "Mage's porch"
	icon_state = "entrance"
	droning_index = DRONING_RIVER_DAY
	droning_index_night = DRONING_RIVER_NIGHT
	ambient_index = AMBIENCE_MYSTICAL
	ambient_index_night = AMBIENCE_FOREST
	converted_type = /area/indoors/shelter/rmh_field

/area/indoors/town/rmh/living
	name = "living zones"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/townindoor_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/townindoor_dawn.ogg'
	background_track_night = 'modular_rmh/sound/music/area/ruintown.ogg'
	droning_index = DRONING_INDOORS
	ambient_index = DRONING_INDOORS

/area/outdoors/exposed/town/rmh
	name = "Rivermist Hollow"
	first_time_text = "RIVERMIST HOLLOW"
	icon_state = "town"
	background_track = 'modular_rmh/sound/music/area/town_day.ogg'
	background_track_dawn = 'modular_rmh/sound/music/area/town_dawn.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/town_dusk.ogg'
	background_track_night = 'modular_rmh/sound/music/area/town_night.ogg'


// - - - - - -
//HERMITS
// - - - - - -
/area/indoors/town/rmh/miner
	name = "Miner's Hut"
	first_time_text = "MINER'S HUT"

/area/indoors/town/rmh/witch
	name = "Witch's Hut"
	first_time_text = "WITCH'S HUT"

/area/indoors/town/rmh/herbalist
	name = "HERBALIST's Hut"
	first_time_text = "HERBALIST'S HUT"

/area/indoors/town/rmh/druid
	name = "Druid's Den"
	first_time_text = "DRUID'S DEN"

// - - - - - -
//BEDROCK AND BORDERS
// - - - - - -
/area/under/rmh_bedrock
	name = "Bedrock Border"
	first_time_text = "BEDROCK BORDER"
	icon_state = "unknown"
	//deathsight_message = "out of bounds"

/area/outdoors/rmh_air
	name = "In Air"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "air"
	//deathsight_message = "open air"
	droning_index = DRONING_MOUNTAIN
	ambient_index = AMBIENCE_GENERIC

// - - - - - -
// DUNGEONS
// - - - - - -
/area/under/rmh_dungeon
	name = "dungeons"
	icon_state = "under"
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	background_track_dawn = 'sound/music/area/catacombs.ogg'
	soundenv = 8
	plane = INDOOR_PLANE
	converted_type = /area/outdoors/exposed/rmh

/area/under/rmh_dungeon/arena
	name = "ruined arena"
	icon_state = "under"
	first_time_text = "FORGOTTEN ARENA"
	background_track = 'sound/music/area/dungeon2.ogg'
	background_track_dusk = 'sound/music/area/dungeon2.ogg'
	background_track_night = 'sound/music/area/dungeon2.ogg'
	ceiling_protected = TRUE

/area/under/rmh_dungeon/catacombs
	name = "catacombs"
	icon_state = "under"
	first_time_text = "CATACOMBS"
	background_track = 'sound/music/area/dungeon2.ogg'
	background_track_dusk = 'sound/music/area/dungeon2.ogg'
	background_track_night = 'sound/music/area/dungeon2.ogg'

/area/under/rmh_dungeon/jergal
	name = "jergal dungeon"
	icon_state = "under"
	first_time_text = "DEATH'S HALLS"
	background_track = 'sound/music/area/dungeon2.ogg'
	background_track_dusk = 'sound/music/area/dungeon2.ogg'
	background_track_night = 'sound/music/area/dungeon2.ogg'
	ceiling_protected = TRUE

/area/under/rmh_dungeon/underdarkmaze
	name = "underdark maze"
	icon_state = "under"
	first_time_text = "FORTRESS FROM UNDER THE DARKNESS"
	background_track = 'sound/music/area/dungeon2.ogg'
	background_track_dusk = 'sound/music/area/dungeon2.ogg'
	background_track_night = 'sound/music/area/dungeon2.ogg'
	ceiling_protected = TRUE

/area/under/rmh_dungeon/catacombs_church
	name = "church's catacombs"
	icon_state = "under"
	first_time_text = "CHURCH'S CATACOMBS"
	background_track = 'sound/music/area/dungeon2.ogg'
	background_track_dusk = 'sound/music/area/dungeon2.ogg'
	background_track_night = 'sound/music/area/dungeon2.ogg'

/area/under/rmh_dungeon/catacombs_town
	name = "town's catacombs"
	icon_state = "under"
	first_time_text = "TOWN'S CATACOMBS"
	background_track = 'sound/music/area/dungeon2.ogg'
	background_track_dusk = 'sound/music/area/dungeon2.ogg'
	background_track_night = 'sound/music/area/dungeon2.ogg'

// - - - - - -
//CAVES
// - - - - - -
/area/indoors/cave/rmh_cave
	name = "Caves"
	first_time_text = "CAVES"
	icon_state = "cave"
	droning_index = DRONING_CAVE_GENERIC
	ambient_index = AMBIENCE_CAVE
	ambush_times = list("night","dusk")
	ambush_types = list(
				/turf/open/floor/cobblerock,
				/turf/open/floor/dirt,
				/turf/open/floor/naturalstone)
	ambush_mobs = list(
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 50,
				/mob/living/carbon/human/species/goblin/npc/ambush = 50)
	soundenv = 8
	//deathsight_message = "a dark cave"
	converted_type = /area/outdoors/caves

/area/indoors/cave/rmh_cave/mine
	name = "Abandoned Mines"
	first_time_text = "ABANDONED MINES"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "mine"

/area/indoors/cave/rmh_cave/to_underdark
	name = "UNDERDARK DESCENT"
	first_time_text = "UNDERDARK DESCENT"
	icon_state = "underworld"

/area/indoors/cave/rmh_cave/safezone
	name = "Safe zone - Mine"
	first_time_text = "CALM PLACE"
	background_track_dawn = 'modular_rmh/sound/music/area/safe_zone_mines.ogg'
	background_track = 'modular_rmh/sound/music/area/safe_zone_mines.ogg'
	background_track_dusk = 'modular_rmh/sound/music/area/safe_zone_mines.ogg'
	background_track_night = 'modular_rmh/sound/music/area/safe_zone_mines.ogg'
	ambush_times = null
	ambush_types = null
	ambush_mobs = null

/area/outdoors/beach/rmh_beach
	name = "Misty Lake"
	icon_state = "beach"
	first_time_text = "MISTY LAKE"
	ambush_mobs = null

/area/indoors/cave/rmh_cave/wet
	name = "Southern Caves"
	icon_state = "cavewet"
	first_time_text = "SOUTHERN CAVES"
	droning_index = DRONING_CAVE_WET
	ambient_index = AMBIENCE_CAVE
	background_track = 'sound/music/area/caves.ogg'
	background_track_dusk = 'sound/music/area/caves.ogg'
	background_track_night = 'sound/music/area/caves.ogg'
	ambush_times = null
	ambush_types = null
	ambush_mobs = null
	//deathsight_message = "wet caverns"

/area/indoors/cave/rmh_cave/wet/lake
	name = "Hidden Lake"
	icon_state = "lake"
	first_time_text = "HIDDEN LAKE"

/area/indoors/cave/rmh_cave/west
	name = "Western Caves"
	first_time_text = "Western Caves"

/area/indoors/cave/rmh_cave/east
	name = "Eastern Caves"
	first_time_text = "Eastern Caves"

/area/indoors/cave/rmh_cave/central
	name = "Central Caves"
	first_time_text = "Central Caves"

/area/indoors/cave/rmh_cave/northern
	name = "Northern Caves"
	first_time_text = "Northern Caves"

/area/indoors/cave/rmh_cave/southern
	name = "Southern Caves"
	first_time_text = "Southern Caves"

/area/indoors/cave/rmh_cave/west/wild
	map_generator = /datum/map_generator/caves/mixed
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/naturalstone,
				/turf/open/floor/dirt,
				/turf/open/floor/cobblerock)
	ambush_mobs = list(
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 45,
				/mob/living/carbon/human/species/goblin/npc/ambush = 25,
				/datum/ambush_config/goblin_ambush_party = 15,
				/mob/living/simple_animal/hostile/retaliate/bigrat = 15)

/area/indoors/cave/rmh_cave/west/wild/warren
	map_generator = /datum/map_generator/caves/warren

/area/indoors/cave/rmh_cave/west/wild/cavern
	map_generator = /datum/map_generator/caves/cavern

/area/indoors/cave/rmh_cave/west/wild/deep
	map_generator = /datum/map_generator/caves/deep

/area/indoors/cave/rmh_cave/east/wild
	map_generator = /datum/map_generator/caves/mixed
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/naturalstone,
				/turf/open/floor/dirt,
				/turf/open/floor/cobblerock)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/bigrat = 40,
				/mob/living/simple_animal/hostile/retaliate/mole = 25,
				/datum/ambush_config/mole_pack = 15,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 20)

/area/indoors/cave/rmh_cave/east/wild/warren
	map_generator = /datum/map_generator/caves/warren

/area/indoors/cave/rmh_cave/east/wild/cavern
	map_generator = /datum/map_generator/caves/cavern

/area/indoors/cave/rmh_cave/east/wild/deep
	map_generator = /datum/map_generator/caves/deep

/area/indoors/cave/rmh_cave/central/wild
	map_generator = /datum/map_generator/caves/mixed
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/naturalstone,
				/turf/open/floor/dirt,
				/turf/open/floor/cobblerock)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/spider = 35,
				/mob/living/simple_animal/hostile/retaliate/spider/mutated = 20,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 30,
				/mob/living/simple_animal/hostile/retaliate/bigrat = 15)

/area/indoors/cave/rmh_cave/central/wild/warren
	map_generator = /datum/map_generator/caves/warren

/area/indoors/cave/rmh_cave/central/wild/cavern
	map_generator = /datum/map_generator/caves/cavern

/area/indoors/cave/rmh_cave/central/wild/deep
	map_generator = /datum/map_generator/caves/deep

/area/indoors/cave/rmh_cave/northern/wild
	map_generator = /datum/map_generator/caves/mixed
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/naturalstone,
				/turf/open/floor/dirt,
				/turf/open/floor/cobblerock)
	ambush_mobs = list(
				/mob/living/carbon/human/species/skeleton/npc/ambush = 40,
				/datum/ambush_config/medium_skeleton_party = 15,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 25,
				/mob/living/simple_animal/hostile/retaliate/bigrat = 20)

/area/indoors/cave/rmh_cave/northern/wild/warren
	map_generator = /datum/map_generator/caves/warren

/area/indoors/cave/rmh_cave/northern/wild/cavern
	map_generator = /datum/map_generator/caves/cavern

/area/indoors/cave/rmh_cave/northern/wild/deep
	map_generator = /datum/map_generator/caves/deep

/area/indoors/cave/rmh_cave/southern/wild
	map_generator = /datum/map_generator/caves/mixed
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/naturalstone,
				/turf/open/floor/dirt,
				/turf/open/floor/cobblerock)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/troll/cave = 25,
				/mob/living/simple_animal/hostile/retaliate/elemental/crawler = 25,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 30,
				/mob/living/simple_animal/hostile/retaliate/bigrat = 20)

/area/indoors/cave/rmh_cave/southern/wild/warren
	map_generator = /datum/map_generator/caves/warren

/area/indoors/cave/rmh_cave/southern/wild/cavern
	map_generator = /datum/map_generator/caves/cavern

/area/indoors/cave/rmh_cave/southern/wild/deep
	map_generator = /datum/map_generator/caves/deep

/area/indoors/cave/rmh_cave/cave_druid
	name = "Druid's Caves"
	first_time_text = "Druid's Caves"
	ambush_times = null
	ambush_types = null
	ambush_mobs = null

/area/indoors/cave/rmh_cave/cave_leshiy
	name = "Warrior's Caves"
	first_time_text = "Hidden Cave"
	ambush_times = null
	ambush_types = null
	ambush_mobs = null

// - - - - - -
//BASEMENTS
// - - - - - -
/area/under/town/rmh/basement
	name = "basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	//spookysounds = SPOOKY_DUNGEON
	//spookynight = SPOOKY_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5
	converted_type = /area/outdoors/exposed/rmh/under/basement

/area/under/town/rmh/basement/mages
	name = "mage's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/tavern
	name = "tavern's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/merchant
	name = "shop's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/bank
	name = "banks's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/church
	name = "church's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/townhall
	name = "townhall's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/artificer
	name = "artificer's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/blacksmith
	name = "blacksmith's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/farm
	name = "farm's basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/bdsm
	name = "bdsm's dungeon"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/basement
	name = "basement"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/pump
	name = "water pump"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/under/town/rmh/basement/lab
	name = "clinic's lab"
	icon_state = "basement"
	droning_index = DRONING_BASEMENT
	droning_index_night = DRONING_BASEMENT
	ambient_index = AMBIENCE_DUNGEON
	ambient_index_night = AMBIENCE_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5

/area/indoors/town/rmh/chapel/basement
	name = "The Ancient Crypt"
	icon_state = "church"
	first_time_text = "THE ANCIENT CRYPT"
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	first_time_text = "THE ANCIENT CRYPT"

/area/outdoors/exposed/rmh/under/basement
	icon_state = "basement"
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'

// - - - - - -
