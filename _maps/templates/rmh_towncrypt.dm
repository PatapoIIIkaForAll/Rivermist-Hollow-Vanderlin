//Note: The template DM (like this file) should be included (checkmarked) in DM!
//The map files themselves (.dmms) should NOT be included, just placed anywhere.
//For ease of file management, the dmms can be placed in a subfolder (in this case "lil_bog_shack")


//First, set the landmark so it can be easily placed
//Note: You can place multiple of the same map mark, it will pick and load them multiple times just fine
//Other note: Loading a .dmm will overwrite whatever was on the tiles but will not delete objects, so clear an area of trees etc in the area you want to make.


// КАТАКОМБЫ ЦЕРКВИ ГОРОДА
/obj/effect/landmark/map_load_mark/rmh/towncrypt

	//Name can be anything, it doesn't matter
	name = "Lil Crypt 1"

	//This uses the "IDs" as below -- they should not have spaces in them though since they're strings it won't matter much
	//It needs at least 1 to do anything, no limit in max number of templates
	templates = list( "rmh_towncrypt_1","rmh_towncrypt_2" )

//The template path as directly below should be unique, though doesn't matter what it's actually named since we use the ID for everything.
/datum/map_template/rmh_towncrypt_1
	name = "Lil Crypt Variant 1"
	//Your IDs must be unique! Make sure you don't just copy and paste and forget to change it!
	id = "rmh_towncrypt_1"
	//Mapppath is a direct pointer to the DMM file of your mini map, make sure no typos! The map file can be anywhere as long as this is set properly.
	//Do NOT include (checkmark) the .dmm file! Just stick it in a folder and you're done with it.
	mappath = "_maps/templates/rmh/rmh_towncrypt_1.dmm"

/datum/map_template/rmh_towncrypt_2
	name = "Lil Crypt Variant 2"
	id = "rmh_towncrypt_2"
	mappath = "_maps/templates/rmh/rmh_towncrypt_2.dmm"

/obj/effect/landmark/map_load_mark/rmh/towncrypt2
	name = "Lil Crypt 2"
	templates = list( "rmh_towncrypt_3","rmh_towncrypt_4" )

/datum/map_template/rmh_towncrypt_3
	name = "Lil Crypt Variant 3"
	id = "rmh_towncrypt_3"
	mappath = "_maps/templates/rmh/rmh_towncrypt_3.dmm"

/datum/map_template/rmh_towncrypt_4
	name = "Lil Crypt Variant 4"
	id = "rmh_towncrypt_4"
	mappath = "_maps/templates/rmh/rmh_towncrypt_4.dmm"

/obj/effect/landmark/map_load_mark/rmh/towncrypt3
	name = "Lil Crypt 3"
	templates = list( "rmh_towncrypt_5","rmh_towncrypt_6" )

/datum/map_template/rmh_towncrypt_5
	name = "Lil Crypt Variant 5"
	id = "rmh_towncrypt_5"
	mappath = "_maps/templates/rmh/rmh_towncrypt_5.dmm"

/datum/map_template/rmh_towncrypt_6
	name = "Lil Crypt Variant 6"
	id = "rmh_towncrypt_6"
	mappath = "_maps/templates/rmh/rmh_towncrypt_6.dmm"

// ПУСТЫННЫЙ ЛАБИРИНТ
/obj/effect/landmark/map_load_mark/rmh/desertlabyr
	name = "Labyrinth"
	templates = list( "rmh_labyrinth1","rmh_labyrinth2" )

/datum/map_template/rmh_labyrinth1
	name = "Labyrinth Variant 1"
	id = "rmh_labyrinth1"
	mappath = "_maps/templates/rmh/rmh_labyrinth1.dmm"

/datum/map_template/rmh_labyrinth2
	name = "Labyrinth Variant 2"
	id = "rmh_labyrinth2"
	mappath = "_maps/templates/rmh/rmh_labyrinth2.dmm"

// КРИПТА ПИРАМИДЫ
/obj/effect/landmark/map_load_mark/rmh/desertcrypt
	name = "Desert Crypt"
	templates = list( "rmh_desertcrypt1","rmh_desertcrypt1" )

/datum/map_template/rmh_desertcrypt1
	name = "Desert Crypt Variant 1"
	id = "rmh_desertcrypt1"
	mappath = "_maps/templates/rmh/rmh_desertcrypt1.dmm"

/datum/map_template/rmh_desertcrypt2
	name = "Desert Crypt Variant 2"
	id = "rmh_desertcrypt2"
	mappath = "_maps/templates/rmh/rmh_desertcrypt2.dmm"
