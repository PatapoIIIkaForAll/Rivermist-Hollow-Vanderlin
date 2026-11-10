/datum/status_effect/debuff/sleepytime/on_remove()
	. = ..()
	if(ishuman(owner) && owner.IsSleeping())
		SSenterprises.note_rest(owner)

/mob/living/carbon/human/finish_night_rest()
	. = ..()
	SSenterprises.note_night(src)

/obj/item/reagent_containers/food/snacks/on_consume(mob/living/eater)
	. = ..()
	if(eater?.buckled)
		SSenterprises.note_meal(eater)

/obj/item/key/Initialize(mapload)
	. = ..()
	SSenterprises.note_key(src)
