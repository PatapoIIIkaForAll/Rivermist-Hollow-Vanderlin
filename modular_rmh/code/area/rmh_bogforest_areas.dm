//SWAMP MAP AREAS

// - - - - - - - -
//  OUTDOORS AREAS
// - - - - - - - -

/area/outdoors/rmh_bog
	name = "Green Swamps"
	first_time_text = "GREEN SWAMPS"
	icon_state = "bog"
	ambientsounds = DRONING_BOG_DAY
	ambientnight = DRONING_BOG_NIGHT
	background_track = 'sound/music/area/forest.ogg'
	background_track_dusk = 'sound/music/area/forest.ogg'
	background_track_night = 'sound/music/area/forest.ogg'
	ambush_times = list("night","dawn","dusk","day")
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/troll/bog = 20,
				/mob/living/simple_animal/hostile/retaliate/spider = 40,
				/mob/living/carbon/human/species/orc/ambush = 40,
				/mob/living/simple_animal/hostile/retaliate/bogbug = 20,
				/mob/living/simple_animal/hostile/retaliate/gator = 20,
				/mob/living/carbon/human/species/goblin/npc/ambush = 30,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 30)
	converted_type = /area/indoors/shelter/bog/rmh
	threat_region = THREAT_REGION_RMH_BOG
	//deathsight_message = "a swamp"

/area/indoors/shelter/bog/rmh
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'sound/music/area/bog.ogg'
	background_track_dusk = 'sound/music/area/bog.ogg'
	background_track_night = 'sound/music/area/bog.ogg'

/area/outdoors/rmh_bog/north
	name = "Northern Green Swamps"
	first_time_text = "NORTHERN GREEN SWAMPS"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "n_basin"

/area/outdoors/rmh_bog/south
	name = "Southern Green Swamps"
	first_time_text = "SOUTHERN GREEN SWAMPS"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "s_basin"
	threat_region = THREAT_REGION_RMH_ORC_FORT

/area/outdoors/rmh_bog/darfortarea
	name = "Around Darkfort"
	first_time_text = "DARKFORT LANDS"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "s_basin"
	threat_region = THREAT_REGION_RMH_ORC_FORT
	ambush_times = list("night","dawn","dusk","day")
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/orc/orc_marauder/ravager = 50)

//FOREST AREAS
/area/outdoors/rmh_darkforest
	name = "The Dark Forest"
	icon_state = "woods"
	ambientsounds = DRONING_FOREST_DAY
	ambientnight = DRONING_FOREST_NIGHT
	//spookysounds = SPOOKY_CROWS
	//spookynight = SPOOKY_FOREST
	background_track = 'sound/music/area/forest.ogg'
	background_track_dusk = 'sound/music/area/septimus.ogg'
	background_track_night = 'sound/music/area/forestnight.ogg'
	soundenv = 15
	ambush_times = list("night","dawn","dusk","day")
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/wolf = 40,
				/mob/living/simple_animal/hostile/retaliate/bobcat = 35,
				/mob/living/simple_animal/hostile/retaliate/smallrat = 20,
				/mob/living/simple_animal/hostile/retaliate/raccoon = 35,
				/mob/living/simple_animal/hostile/retaliate/direbear = 5,
				/mob/living/simple_animal/hostile/retaliate/fox = 35,
				/mob/living/carbon/human/species/skeleton/npc/peasant = 10,
				/mob/living/carbon/human/species/goblin/npc/ambush = 30)
	first_time_text = "THE DARK FOREST"
	converted_type = /area/indoors/shelter/woods
	threat_region = THREAT_REGION_RMG_DARK_FOREST
	//deathsight_message = "somewhere in the forest"

/area/indoors/shelter/woods/rmh
	name = "Dark Forest"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "indoors"
	background_track = 'sound/music/area/forest.ogg'
	background_track_dusk = 'sound/music/area/septimus.ogg'
	background_track_night = 'sound/music/area/forestnight.ogg'

/area/outdoors/rmh_darkforest/goblincampfire
	name = "Goblin Camp"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "camp"
	first_time_text = "GOBLIN CAMP"
	name = "goblin campfire"
	//deathsight_message = "goblin camp"



// - - - - - -
//DUNGEONS
// - - - - - -

/area/indoors/rmh_darkforestbog
	name = "Forest & Bog Indoors"
	icon_state = "indoors"
	droning_index = DRONING_INDOORS
	ambient_index = AMBIENCE_GENERIC
	background_track = 'sound/music/area/indoor.ogg'
	background_track_dusk = 'sound/music/area/indoor.ogg'
	background_track_night =  'sound/music/area/indoor.ogg'
	converted_type = /area/outdoors/rmh_darkforest // сделать зону пустышку

/area/indoors/rmh_darkforestbog/forest/forestranger
	name = "Ranger Watchpost"
	icon_state = "indoors"

/area/indoors/rmh_darkforestbog/forest/abandonedvillage
	name = "Abandoned village"
	icon_state = "indoors"

/area/indoors/rmh_darkforestbog/forest/hunterpost
	name = "Hunter post"
	icon_state = "indoors"

/area/indoors/rmh_darkforestbog/forest/goblincamp
	name = "Goblin Camp"
	icon_state = "indoors"

/area/indoors/rmh_darkforestbog/forest/treehouse
	name = "Tree House"
	icon_state = "indoors"

/area/indoors/rmh_darkforestbog/bog/swampvillage
	name = "Swamp village"
	icon_state = "indoors"

/area/indoors/rmh_darkforestbog/bog/rangertower
	name = "Ranger Towen"
	icon_state = "indoors"

/area/indoors/rmh_darkforestbog/bog/orcsdarfort
	name = "The Dark Fort"
	first_time_text = "THE DARK FORT"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "village"
	background_track = 'sound/music/area/bog.ogg'
	background_track_dusk = 'sound/music/area/bog.ogg'
	background_track_night = 'sound/music/area/bog.ogg'
	//deathsight_message = "Dark Fort"
	threat_region = THREAT_REGION_RMH_ORC_FORT

/area/indoors/rmh_darkforestbog/bogpass
	name = "Secret Bog Pass"
	first_time_text = "SECRET PASS"
	icon_state = "living"
	background_track = 'sound/music/area/magiciantower.ogg'
	background_track_dusk = 'sound/music/area/magiciantower.ogg'
	background_track_night = 'sound/music/area/magiciantower.ogg'
	ceiling_protected = TRUE

// - - - - - -
//DUNGEONS
// - - - - - -
/area/under/rmh_dungeon/orcpost
	name = "Orc post"
	icon_state = "under"
	background_track = 'sound/music/area/dungeon.ogg'
	background_track_dusk = 'sound/music/area/dungeon.ogg'
	background_track_night = 'sound/music/area/dungeon.ogg'
	background_track_dawn = 'sound/music/area/dungeon.ogg'
	ceiling_protected = TRUE
	threat_region = THREAT_REGION_RMG_DARK_FOREST

/area/under/rmh_dungeon/goblindungeon
	name = "Goblin cave"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "camp"
	first_time_text = "GOBLIN CAVE"
	background_track = 'sound/music/area/dungeon.ogg'
	background_track_dusk = 'sound/music/area/dungeon.ogg'
	background_track_night = 'sound/music/area/dungeon.ogg'
	background_track_dawn = 'sound/music/area/dungeon.ogg'
	ceiling_protected = TRUE
	threat_region = THREAT_REGION_RMG_DARK_FOREST

/area/under/rmh_dungeon/orcsjail
	name = "Orc's Jail"
	icon_state = "under"
	first_time_text = "OLD RUIN"
	background_track = 'sound/music/area/dungeon.ogg'
	background_track_dusk = 'sound/music/area/dungeon.ogg'
	background_track_night = 'sound/music/area/dungeon.ogg'
	background_track_dawn = 'sound/music/area/dungeon.ogg'
	threat_region = THREAT_REGION_RMG_DARK_FOREST
	ceiling_protected = TRUE

// - - - - - -
//CAVES
// - - - - - -
/area/under/rmh_bogforest_caves
	name = "Caves"
	first_time_text = "CAVES"
	icon_state = "cave"
	ambientsounds = DRONING_CAVE_GENERIC
	ambientnight = DRONING_CAVE_GENERIC
	soundenv = 8
	//deathsight_message = "a dark cave"
	ceiling_protected = TRUE
	threat_region = THREAT_REGION_RMH_BOG

/area/under/rmh_bogforest_caves/moistcaves
	name = "Moist Tunnels"
	first_time_text = "MOIST TUNNELS"
	icon_state = "cavewet"
	ambientsounds = DRONING_CAVE_WET
	ambientnight = DRONING_CAVE_WET
	//spookysounds = AMBIENCE_CAVE
	//spookynight = AMBIENCE_CAVE
	background_track = 'sound/music/area/caves.ogg'
	background_track_dusk = 'sound/music/area/caves.ogg'
	background_track_night = 'sound/music/area/caves.ogg'
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
		/turf/open/floor/dirt)
	ambush_mobs = list(
		/mob/living/carbon/human/species/skeleton/npc/easy = 10,
		/mob/living/simple_animal/hostile/retaliate/bigrat = 30,
		/mob/living/carbon/human/species/goblin/npc/sea = 20,
		/mob/living/simple_animal/hostile/retaliate/bogbug = 40,
		/mob/living/carbon/human/species/human/northern/highwayman/ambush = 20,
		/mob/living/simple_animal/hostile/retaliate/troll = 15)
	//deathsight_message = "moist tunnels"

/area/under/rmh_bogforest_caves/moistcaves/northeast
	name = "Northeast moist tunnels"
	first_time_text = "NORTHEAST MOIST TUNNELS"
	icon_state = "cavewet"

/area/under/rmh_bogforest_caves/moistcaves/southeast
	name = "Southeast moist tunnels"
	first_time_text = "SOUTHEAST MOIST TUNNELS"
	icon_state = "cavewet"

/area/under/rmh_bogforest_caves/mindflayer
	name = "Mindflayer Colony"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "living"
	first_time_text = "MINDFLAYER COLONY"
	//deathsight_message = "Mindflayer Colony"

/area/under/rmh_bogforest_caves/forestcaves
	name = "Forest cave"
	icon_state = "cave"
	droning_index = DRONING_CAVE_GENERIC
	ambient_index = AMBIENCE_CAVE
	background_track = 'sound/music/area/caves.ogg'
	background_track_dusk = 'sound/music/area/caves.ogg'
	background_track_night = 'sound/music/area/caves.ogg'
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
		/turf/open/floor/dirt)
	ambush_mobs = list(
		/mob/living/simple_animal/hostile/retaliate/bigrat = 30,
		/mob/living/carbon/human/species/goblin/npc/ambush/cave = 20,
		/mob/living/carbon/human/species/skeleton/npc/ambush = 10)

/area/under/rmh_bogforest_caves/cliffcaves
	name = "Cliff Caves"
	icon_state = "cave"

/area/under/rmh_bogforest_caves/forestcaves/northwest
	name = "Northwest forest tunnels"
	first_time_text = "NORTWEST LUSH CAVES"
	icon_state = "cave"

/area/under/rmh_bogforest_caves/forestcaves/southwest
	name = "Southwest forest tunnels"
	first_time_text = "SOUTHWEST LUSH CAVES"
	icon_state = "cave"

/area/under/rmh_bogforest_caves/wolf
	name = "Wolf Den"
	first_time_text = "WOLF DEN"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "wolf"
	ambush_mobs = list(
		/mob/living/simple_animal/hostile/retaliate/wolf = 50)

/area/under/rmh_bogforest_caves/slime
	name = "Slime pit"
	first_time_text = "SLIME PIT"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "cave"

/area/under/rmh_bogforest_caves/trolls
	name = "Trolls cave"
	first_time_text = "TROLLS CAVE"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "cave"

/area/under/rmh_bogforest_caves/werewolf
	name = "Werewolf Den"
	first_time_text = "WEREWOLF DEN"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "wolf"

/area/under/rmh_bogforest_caves/spiders
	name = "Spider Caves"
	icon_state = "spidercave"
	first_time_text = "SPIDER CAVES"
	ambush_mobs = list(
		/mob/living/simple_animal/hostile/mirespider_lurker/mushroom = 100)
	background_track = 'sound/music/area/spidercave.ogg'
	background_track_dusk = 'sound/music/area/spidercave.ogg'
	background_track_night = 'sound/music/area/spidercave.ogg'

// - - - - - -
//BASEMENTS
// - - - - - -

/area/under/town/rmh/basement/bogforest
	name = "Bog&Forest Basements"
	icon_state = "basement"
	ambientsounds = DRONING_BASEMENT
	ambientnight = DRONING_BASEMENT
	//spookysounds = SPOOKY_DUNGEON
	//spookynight = SPOOKY_DUNGEON
	background_track = 'sound/music/area/catacombs.ogg'
	background_track_dusk = 'sound/music/area/catacombs.ogg'
	background_track_night = 'sound/music/area/catacombs.ogg'
	soundenv = 5
	ceiling_protected = TRUE

/area/under/town/rmh/basement/bogforest/normal
	name = "Dark Forest Basement"
	icon_state = "basement"

/area/under/town/rmh/basement/bogforest/wet
	name = "Dark Forest Basement"
	icon_state = "basement"
	droning_index = DRONING_CAVE_WET
	ambient_index = AMBIENCE_CAVE

// - - - - - -
//TRANSITIONS
// - - - - - -
/area/outdoors/bog/rmh/travel/main
	name = "To Rivermist Hollow"
	first_time_text = "TO RIVERMIST HOLLOW"
	icon = 'modular_rmh/icons/turf/areas.dmi'
	icon_state = "travel"

/area/outdoors/bog/rmh/travel/swamp_to_main
	name = "Green Swamp To Rivermist Hollow"
	first_time_text = "TO RIVERMIST HOLLOW"

/area/outdoors/bog/rmh/travel/forest_to_main
	name = "Dark Forest To Rivermist Hollow"
	first_time_text = "TO RIVERMIST HOLLOW"

/area/outdoors/bog/rmh/travel/underdark
	name = "Swamp Forest Descend To Underdark"
	first_time_text = "DESCEND TO UNDERDARK"
// - - - - - -
