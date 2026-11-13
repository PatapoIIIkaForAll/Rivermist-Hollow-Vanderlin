#define FOOTSTEP_WOOD "wood"
#define FOOTSTEP_FLOOR "floor"
#define FOOTSTEP_PLATING "plating"
#define FOOTSTEP_CARPET "carpet"
#define FOOTSTEP_SAND "sand"
#define FOOTSTEP_GRASS "grass"
#define FOOTSTEP_WATER "water"
#define FOOTSTEP_LAVA "lava"
#define FOOTSTEP_MUD "mud"
#define FOOTSTEP_STONE "stone"
#define FOOTSTEP_SHALLOW "shallow"

//barefoot sounds
#define FOOTSTEP_WOOD_BAREFOOT "woodbarefoot"
#define FOOTSTEP_WOOD_CLAW "woodclaw"
#define FOOTSTEP_HARD_BAREFOOT "hardbarefoot"
#define FOOTSTEP_SOFT_BAREFOOT "softbarefoot"
#define FOOTSTEP_HARD_CLAW "hardclaw"
#define FOOTSTEP_CARPET_BAREFOOT "carpetbarefoot"
//misc footstep sounds
#define FOOTSTEP_GENERIC_HEAVY "heavy"

//heelsteps

#define HEELSTEP_WOOD "heel_wood"
#define HEELSTEP_FLOOR "heel_floor"
#define HEELSTEP_PLATING "heel_plating"
#define HEELSTEP_CARPET "heel_carpet"
#define HEELSTEP_SAND "heel_sand"
#define HEELSTEP_SNOW "heel_snow"
#define HEELSTEP_GRASS "heel_grass"
#define HEELSTEP_WATER "heel_water"
#define HEELSTEP_MUD "heel_mud"
#define HEELSTEP_STONE "heel_stone"
#define HEELSTEP_SHALLOW "heel_shallow"

//footstep mob defines
#define FOOTSTEP_MOB_CLAW "footstep_claw"
#define FOOTSTEP_MOB_BAREFOOT "footstep_barefoot"
#define FOOTSTEP_MOB_HEAVY "footstep_heavy"
#define FOOTSTEP_MOB_SHOE "footstep_shoe"
#define FOOTSTEP_MOB_HUMAN "footstep_human" //Warning: Only works on /mob/living/carbon/human
#define FOOTSTEP_MOB_SLIME "footstep_slime"
#define FOOTSTEP_MOB_METAL "footstep_metal"
/// Heavy beast padding: the turf's barefoot samples, so steps follow the terrain.
#define FOOTSTEP_MOB_BEAST "footstep_beast"

//heelsteps
#define HEELSTEP_MOB_HEEL "heelstep_heel"

//priority defines for the footstep_override element
#define STEP_SOUND_NO_PRIORITY 0
#define STEP_SOUND_TABLE_PRIORITY 1

///the key to a list of override sounds to replace with. Same format as the global lists.
#define STEP_SOUND_SHOE_OVERRIDE "step_sound_shoe_override"

///the name of the index key for priority
#define STEP_SOUND_PRIORITY "step_sound_priority"

/*

id = list(
list(sounds),
base volume,
extra range addition
)


*/
GLOBAL_LIST_INIT(weatherproof_z_levels, list())
GLOBAL_LIST_INIT(cellar_z, list())

GLOBAL_LIST_INIT(footstep, list(
	FOOTSTEP_WOOD = list(list(
		'sound/foley/footsteps/FTWOO_A1.ogg',
		'sound/foley/footsteps/FTWOO_A2.ogg',
		'sound/foley/footsteps/FTWOO_A3.ogg',
		'sound/foley/footsteps/FTWOO_A4.ogg'), 42, 0),
	FOOTSTEP_FLOOR = list(list(
		'sound/foley/footsteps/FTTIL_A1.ogg',
		'sound/foley/footsteps/FTTIL_A2.ogg',
		'sound/foley/footsteps/FTTIL_A3.ogg',
		'sound/foley/footsteps/FTTIL_A4.ogg'), 50, 0),
	FOOTSTEP_PLATING = list(list(
		'sound/foley/footsteps/FTMET_A1.ogg',
		'sound/foley/footsteps/FTMET_A2.ogg',
		'sound/foley/footsteps/FTMET_A3.ogg',
		'sound/foley/footsteps/FTMET_A4.ogg'), 40, 0),
	FOOTSTEP_CARPET = list(list(
		'sound/foley/footsteps/FTCAR_A1.ogg',
		'sound/foley/footsteps/FTCAR_A2.ogg',
		'sound/foley/footsteps/FTCAR_A3.ogg',
		'sound/foley/footsteps/FTCAR_A4.ogg'), 12, 0),
	FOOTSTEP_SAND = list(list(
		'sound/foley/footsteps/FTDIR_A1.ogg',
		'sound/foley/footsteps/FTDIR_A2.ogg',
		'sound/foley/footsteps/FTDIR_A3.ogg',
		'sound/foley/footsteps/FTDIR_A4.ogg'), 10, 0),
	FOOTSTEP_GRASS = list(list(
		'sound/foley/footsteps/FTGRA_A1.ogg',
		'sound/foley/footsteps/FTGRA_A2.ogg',
		'sound/foley/footsteps/FTGRA_A3.ogg',
		'sound/foley/footsteps/FTGRA_A4.ogg'), 15, 0),
	FOOTSTEP_WATER = list(list(
		'sound/foley/footsteps/FTWAT_1.ogg',
		'sound/foley/footsteps/FTWAT_2.ogg',
		'sound/foley/footsteps/FTWAT_3.ogg',
		'sound/foley/footsteps/FTWAT_4.ogg'), 80, 0),
	FOOTSTEP_SHALLOW = list(list(
		'sound/foley/footsteps/FTSHAL (1).ogg',
		'sound/foley/footsteps/FTSHAL (2).ogg',
		'sound/foley/footsteps/FTSHAL (3).ogg',
		'sound/foley/footsteps/FTSHAL (4).ogg',
		'sound/foley/footsteps/FTSHAL (5).ogg'), 80, 0),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg'), 100, 0),
	FOOTSTEP_STONE = list(list(
		'sound/foley/footsteps/FTROC_A1.ogg',
		'sound/foley/footsteps/FTROC_A2.ogg',
		'sound/foley/footsteps/FTROC_A3.ogg',
		'sound/foley/footsteps/FTROC_A4.ogg'), 40, 0),
	FOOTSTEP_MUD = list(list(
		'sound/foley/footsteps/FTMUD (1).ogg',
		'sound/foley/footsteps/FTMUD (2).ogg',
		'sound/foley/footsteps/FTMUD (3).ogg',
		'sound/foley/footsteps/FTMUD (4).ogg',
		'sound/foley/footsteps/FTMUD (5).ogg'), 80, 0),
))
//bare footsteps lists
GLOBAL_LIST_INIT(barefootstep, list(
	FOOTSTEP_WOOD_BAREFOOT = list(list(
		'sound/foley/footsteps/hardbarefoot (1).ogg',
		'sound/foley/footsteps/hardbarefoot (2).ogg',
		'sound/foley/footsteps/hardbarefoot (3).ogg'), 60, 0),
	FOOTSTEP_HARD_BAREFOOT = list(list(
		'sound/foley/footsteps/hardbarefoot (1).ogg',
		'sound/foley/footsteps/hardbarefoot (2).ogg',
		'sound/foley/footsteps/hardbarefoot (3).ogg'), 60, 0),
	FOOTSTEP_SOFT_BAREFOOT = list(list(
		'sound/foley/footsteps/softbarefoot (1).ogg',
		'sound/foley/footsteps/softbarefoot (2).ogg',
		'sound/foley/footsteps/softbarefoot (3).ogg'), 50, 0),
	FOOTSTEP_WATER = list(list(
		'sound/foley/footsteps/FTWAT_1.ogg',
		'sound/foley/footsteps/FTWAT_2.ogg',
		'sound/foley/footsteps/FTWAT_3.ogg',
		'sound/foley/footsteps/FTWAT_4.ogg'), 100, 0),
	FOOTSTEP_SHALLOW = list(list(
		'sound/foley/footsteps/FTSHAL (1).ogg',
		'sound/foley/footsteps/FTSHAL (2).ogg',
		'sound/foley/footsteps/FTSHAL (3).ogg',
		'sound/foley/footsteps/FTSHAL (4).ogg',
		'sound/foley/footsteps/FTSHAL (5).ogg'), 100, 0),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg',
		'sound/blank.ogg',
		'sound/blank.ogg'), 100, 0),
	FOOTSTEP_MUD = list(list(
		'sound/foley/footsteps/FTMUD (1).ogg',
		'sound/foley/footsteps/FTMUD (2).ogg',
		'sound/foley/footsteps/FTMUD (3).ogg',
		'sound/foley/footsteps/FTMUD (4).ogg',
		'sound/foley/footsteps/FTMUD (5).ogg'), 100, 0),
))

//claw footsteps lists
GLOBAL_LIST_INIT(clawfootstep, list(
	FOOTSTEP_WOOD_CLAW = list(list(
		'sound/blank.ogg'), 90, 1),
	FOOTSTEP_HARD_CLAW = list(list(
		'sound/blank.ogg'), 90, 1),
	FOOTSTEP_CARPET_BAREFOOT = list(list(
		'sound/blank.ogg'), 25, -2),
	FOOTSTEP_SAND = list(list(
		'sound/blank.ogg'), 25, 0),
	FOOTSTEP_GRASS = list(list(
		'sound/blank.ogg'), 25, 0),
	FOOTSTEP_WATER = list(list(
		'sound/blank.ogg'), 50, 1),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg'), 50, 0),
))

//heavy footsteps list
GLOBAL_LIST_INIT(heavyfootstep, list(
	FOOTSTEP_GENERIC_HEAVY = list(list(
		'sound/foley/footsteps/bigwalk (1).ogg',
		'sound/foley/footsteps/bigwalk (2).ogg',
		'sound/foley/footsteps/bigwalk (3).ogg',
		'sound/foley/footsteps/bigwalk (4).ogg'), 100, 0),
	FOOTSTEP_WATER = list(list(
		'sound/foley/footsteps/FTWAT_1.ogg',
		'sound/foley/footsteps/FTWAT_2.ogg',
		'sound/foley/footsteps/FTWAT_3.ogg',
		'sound/foley/footsteps/FTWAT_4.ogg'), 100, 0),
	FOOTSTEP_SHALLOW = list(list(
		'sound/foley/footsteps/FTSHAL (1).ogg',
		'sound/foley/footsteps/FTSHAL (2).ogg',
		'sound/foley/footsteps/FTSHAL (3).ogg',
		'sound/foley/footsteps/FTSHAL (4).ogg',
		'sound/foley/footsteps/FTSHAL (5).ogg'), 100, 0),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg'), 100, 0),
	FOOTSTEP_MUD = list(list(
		'sound/foley/footsteps/FTMUD (1).ogg',
		'sound/foley/footsteps/FTMUD (2).ogg',
		'sound/foley/footsteps/FTMUD (3).ogg',
		'sound/foley/footsteps/FTMUD (4).ogg',
		'sound/foley/footsteps/FTMUD (5).ogg'), 100, 0),
))

//Heelsteps
GLOBAL_LIST_INIT(heelstep, list(
	HEELSTEP_WOOD = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/wood1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/wood2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/wood3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/wood4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/wood5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/wood6.ogg',), 84, 0),
	HEELSTEP_FLOOR = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/tile1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile6.ogg'), 100, 0),
	HEELSTEP_PLATING = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/tile1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile6.ogg'), 100, 0),
	HEELSTEP_CARPET = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/carpet1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/carpet2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/carpet3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/carpet4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/carpet5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/carpet6.ogg'), 24, 0),
	HEELSTEP_SAND = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/sand1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/sand2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/sand3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/sand4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/sand5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/sand6.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/sand7.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/sand8.ogg'), 20, 0),
	HEELSTEP_GRASS = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/grass1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/grass2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/grass3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/grass4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/grass5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/grass6.ogg'), 30, 0),
	HEELSTEP_WATER = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/water1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water6.ogg'), 100, 0),
	HEELSTEP_SHALLOW = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/water1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/water6.ogg'), 100, 0),
	HEELSTEP_STONE = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/tile1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/tile6.ogg'), 100, 0),
	HEELSTEP_MUD = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/dirt1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/dirt2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/dirt3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/dirt4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/dirt5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/dirt6.ogg'), 80, 0),
	HEELSTEP_SNOW = list(list(
		'modular_rmh/sound/foley/footsteps/heelsteps/snow1.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/snow2.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/snow3.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/snow4.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/snow5.ogg',
		'modular_rmh/sound/foley/footsteps/heelsteps/snow6.ogg'), 80, 0),
))
GLOBAL_LIST_INIT(metalfootstep, list(
	FOOTSTEP_GENERIC_HEAVY = list(list(
		'sound/foley/footsteps/armor/powerarmor (1).ogg',
		'sound/foley/footsteps/armor/powerarmor (2).ogg',
		'sound/foley/footsteps/armor/powerarmor (3).ogg',), 100, 0),
	FOOTSTEP_WATER = list(list(
		'sound/foley/footsteps/armor/powerarmor (1).ogg',
		'sound/foley/footsteps/armor/powerarmor (2).ogg',
		'sound/foley/footsteps/armor/powerarmor (3).ogg',), 100, 0),
	FOOTSTEP_SHALLOW = list(list(
		'sound/foley/footsteps/armor/powerarmor (1).ogg',
		'sound/foley/footsteps/armor/powerarmor (2).ogg',
		'sound/foley/footsteps/armor/powerarmor (3).ogg',), 100, 0),
	FOOTSTEP_LAVA = list(list(
		'sound/blank.ogg'), 100, 0),
	FOOTSTEP_MUD = list(list(
		'sound/foley/footsteps/armor/powerarmor (1).ogg',
		'sound/foley/footsteps/armor/powerarmor (2).ogg',
		'sound/foley/footsteps/armor/powerarmor (3).ogg',), 100, 0),
))

