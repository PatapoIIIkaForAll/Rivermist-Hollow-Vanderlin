/mob/living/simple_animal/hostile/retaliate/fae
	food_max = 0
	dendor_taming_chance = DENDOR_TAME_PROB_NONE
	animal_type = /datum/blood_type/fey
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_FEY

/mob/living/simple_animal/hostile/retaliate/fae/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_KNEESTINGER_IMMUNITY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_TOXIMMUNE, TRAIT_GENERIC)

/mob/living/simple_animal/hostile/retaliate/fae/simple_limb_hit(zone)
	return ..()
