/datum/voicepack/female/goblin/get_sound(soundin, modifiers)
	// Old and silenced voices use the general feminine handling.
	if(modifiers)
		return ..()
	var/used
	switch(soundin)
		if("chuckle")
			used = list('sound/vo/female/goblin/chuckle (1).ogg', 'sound/vo/female/goblin/chuckle (3).ogg', 'sound/vo/female/goblin/chuckle (4).ogg')
		if("giggle")
			used = list('sound/vo/female/goblin/giggle (1).ogg', 'sound/vo/female/goblin/giggle (4).ogg', 'sound/vo/female/goblin/giggle (6).ogg')
		if("laugh")
			used = list('sound/vo/female/goblin/laugh (1).ogg', 'sound/vo/female/goblin/laugh (2).ogg', 'sound/vo/female/goblin/laugh (4).ogg')

	if(!used)
		used = ..(soundin, modifiers)
	return used
