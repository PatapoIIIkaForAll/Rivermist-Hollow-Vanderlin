/datum/voicepack/male/goblin/get_sound(soundin, modifiers)
	// Old and silenced voices use the general masculine handling.
	if(modifiers)
		return ..()
	var/used
	switch(soundin)
		if("chuckle")
			used = list('sound/vo/male/goblin/chuckle (1).ogg', 'sound/vo/male/goblin/chuckle (3).ogg')
		if("giggle")
			used = list('sound/vo/male/goblin/giggle (2).ogg', 'sound/vo/male/goblin/giggle (3).ogg')
		if("laugh")
			used = list('sound/vo/male/goblin/laugh (1).ogg', 'sound/vo/male/goblin/laugh (2).ogg')

	if(!used)
		used = ..(soundin, modifiers)
	return used
