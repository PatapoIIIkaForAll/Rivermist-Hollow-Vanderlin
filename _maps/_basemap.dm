#ifndef ABSOLUTE_MINIMUM_MODE
#include "map_files\shared\CentCom.dmm" //this MUST be loaded no matter what for SSmapping's multi-z to work correctly
#else
#include "map_files\shared\CentCom_minimal.dmm"
#endif

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS // I cry
		#include "map_files/debug/roguetest.dmm"
		#include "map_files/hsector/underdark.dmm"
		#include "map_files/hsector/hsector.dmm"
		#include "map_files/hsector/frozen_mountains.dmm"
		#include "map_files/hsector/desert.dmm"
		#include "map_files/hsector/bogforest.dmm"
	#endif
	#ifdef ALL_TEMPLATES
		#include "templates.dm"
	#endif
#endif
