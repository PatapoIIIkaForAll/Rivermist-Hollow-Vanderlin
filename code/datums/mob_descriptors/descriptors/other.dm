/datum/mob_descriptor/age
	name = "Age"
	slot = MOB_DESCRIPTOR_SLOT_AGE
	verbage = "%LOOK%"

/datum/mob_descriptor/age/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	return TRUE

/datum/mob_descriptor/age/get_description(mob/living/described)
	var/mob/living/carbon/human/human = described
	switch(human.age)
		if(AGE_OLD)
			return "old"
		if(AGE_MIDDLEAGED)
			return "middle-aged"
	//ADULT and IMMORTAL
	return "fully grown"

/// Whether a casual look sees this organ bare; "show above clothes" counts, chastity and covering clothes hide it.
/mob/living/carbon/human/proc/is_genital_exposed(obj/item/organ/genitals/organ, hide_flags)
	if(!organ)
		return FALSE
	if(underwear?.hides_organ_slot(organ.slot))
		return FALSE
	if(organ.visible_through_clothes == DRAW_ABOVE)
		return TRUE
	return is_human_part_visible(src, hide_flags)

/datum/mob_descriptor/penis
	name = "penis"
	slot = MOB_DESCRIPTOR_SLOT_PENIS
	verbage = "%HAVE%"
	show_obscured = TRUE
	descriptor_color = "#ff66cc"
	aroused_descriptor_color = "#ff5555"

/datum/mob_descriptor/penis/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	return H.is_genital_exposed(H.getorganslot(ORGAN_SLOT_PENIS), HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH)

/datum/mob_descriptor/penis/get_description(mob/living/described)
	return get_description_for_watcher(described, null)

/datum/mob_descriptor/penis/get_description_for_watcher(mob/living/described, mob/watcher)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/genitals/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis)
		return
	var/adjective
	var/arousal_modifier
	switch(penis.organ_size)
		if(1)
			adjective = "a small"
		if(2)
			adjective = "an average"
		if(3)
			adjective = "a large"
	var/list/arousal_data = list()
	SEND_SIGNAL(H, COMSIG_SEX_GET_AROUSAL, arousal_data)
	switch(arousal_data["arousal"])
		if(80 to INFINITY)
			arousal_modifier = ", throbbing violently"
		if(50 to 80)
			arousal_modifier = ", turgid and leaky"
		if(20 to 50)
			arousal_modifier = ", stiffened and twitching"
		else
			arousal_modifier = ", soft and flaccid"
	var/used_name
	if(penis.erect_state != ERECT_STATE_HARD && penis.sheath_type != SHEATH_TYPE_NONE)
		switch(penis.sheath_type)
			if(SHEATH_TYPE_NORMAL)
				if(penis.organ_size == 3)
					used_name = "a fat sheath"
				else
					used_name = "a sheath"
			if(SHEATH_TYPE_SLIT)
				used_name = "a genital slit"
	else
		used_name = "[adjective] [penis.name], about [round(penis.get_length_cm(), 1)] cm long[arousal_modifier]"
	return "[used_name][H.get_pubic_hair_clause(ORGAN_SLOT_PENIS, watcher)]"

/datum/mob_descriptor/testicles
	name = "balls"
	slot = MOB_DESCRIPTOR_SLOT_TESTICLES
	verbage = "%HAVE%"
	show_obscured = TRUE
	descriptor_color = "#ff66cc"
	aroused_descriptor_color = "#ff5555"

/datum/mob_descriptor/testicles/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/genitals/penis/penis = H.getorganslot(ORGAN_SLOT_PENIS)
	if(penis && penis.sheath_type == SHEATH_TYPE_SLIT) //If our penis hides in a slit, dont describe testicles
		return FALSE
	return H.is_genital_exposed(H.getorganslot(ORGAN_SLOT_TESTICLES), HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH)

/datum/mob_descriptor/testicles/get_description(mob/living/described)
	return get_description_for_watcher(described, null)

/datum/mob_descriptor/testicles/get_description_for_watcher(mob/living/described, mob/watcher)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/genitals/filling_organ/testicles/testes = H.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testes)
		return
	var/adjective
	switch(testes.get_visible_size())
		if(1)
			adjective = "a small"
		if(2)
			adjective = "an average"
		if(3)
			adjective = "a large"
		if(4)
			adjective = "a huge"
		if(5)
			adjective = "a massive"
		if(6)
			adjective = "an enormous"
	var/fullness = testes.get_fullness_description()
	return "[adjective] pair of balls[fullness ? ", [fullness]" : ""][H.get_pubic_hair_clause(ORGAN_SLOT_TESTICLES, watcher)]"

/datum/mob_descriptor/butt
	name = "butt"
	slot = MOB_DESCRIPTOR_SLOT_BUTT
	verbage = "%HAVE%"
	show_obscured = TRUE
	descriptor_color = "#ff66cc"
	aroused_descriptor_color = "#ff5555"

/datum/mob_descriptor/butt/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	return H.is_genital_exposed(H.getorganslot(ORGAN_SLOT_BUTT), HIDEBUTT|HIDEUNDIESBOT)

/datum/mob_descriptor/butt/get_description(mob/living/described)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/genitals/butt/buttie = H.getorganslot(ORGAN_SLOT_BUTT)
	if(!buttie)
		return
	var/adjective
	switch(buttie.organ_size)
		if(0)
			adjective = "a flat"
		if(1)
			adjective = "a small"
		if(2)
			adjective = "an average"
		if(3)
			adjective = "a large"
		if(4)
			adjective = "a massive"
		if(5)
			adjective = "a colossal"
	return "[adjective] ass"

/datum/mob_descriptor/vagina
	name = "vagina"
	slot = MOB_DESCRIPTOR_SLOT_VAGINA
	verbage = "%HAVE%"
	show_obscured = TRUE
	descriptor_color = "#ff66cc"
	aroused_descriptor_color = "#ff5555"

/datum/mob_descriptor/vagina/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	return H.is_genital_exposed(H.getorganslot(ORGAN_SLOT_VAGINA), HIDEJUMPSUIT|HIDEUNDIESBOT|HIDECROTCH)

/datum/mob_descriptor/vagina/get_description(mob/living/described)
	return get_description_for_watcher(described, null)

/datum/mob_descriptor/vagina/get_description_for_watcher(mob/living/described, mob/watcher)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/genitals/filling_organ/vagina/vagina = H.getorganslot(ORGAN_SLOT_VAGINA)
	if(!vagina)
		return
	var/vagina_type = "vagina"
	var/arousal_modifier
	switch(vagina.accessory_type)
		if(/datum/sprite_accessory/genitals/vagina/human)
			vagina_type = "plain vagina"
		if(/datum/sprite_accessory/genitals/vagina/spade)
			vagina_type = "spade vagina"
		if(/datum/sprite_accessory/genitals/vagina/gaping)
			vagina_type = "gaping vagina"
		if(/datum/sprite_accessory/genitals/vagina/cloaca)
			vagina_type = "cloaca"
	var/list/arousal_data = list()
	SEND_SIGNAL(H, COMSIG_SEX_GET_AROUSAL, arousal_data)
	switch(arousal_data["arousal"])
		if(80 to INFINITY)
			arousal_modifier = ", gushing with arousal"
		if(50 to 80)
			arousal_modifier = ", slickened with arousal"
		if(20 to 50)
			arousal_modifier = ", wet with arousal"
	var/orifice_clause = ""
	var/list/orifice_adjectives = vagina.orifice?.get_examine_adjectives()
	if(length(orifice_adjectives))
		orifice_clause = ", [jointext(orifice_adjectives, ", ")]"
	return "a [vagina_type][arousal_modifier][orifice_clause][H.get_pubic_hair_clause(ORGAN_SLOT_VAGINA, watcher)]"

/datum/mob_descriptor/breasts
	name = "breasts"
	slot = MOB_DESCRIPTOR_SLOT_BREASTS
	verbage = "%HAVE%"
	show_obscured = TRUE
	descriptor_color = "#ff66cc"
	aroused_descriptor_color = "#ff5555"

/datum/mob_descriptor/breasts/can_describe(mob/living/described)
	if(!ishuman(described))
		return FALSE
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
	if(breasts?.visible_through_clothes != DRAW_ABOVE && H.underwear?.covers_breasts)
		return FALSE
	return H.is_genital_exposed(breasts, HIDEBOOB|HIDEJUMPSUIT)

/datum/mob_descriptor/breasts/get_description(mob/living/described)
	var/mob/living/carbon/human/H = described
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts)
		return
	var/adjective
	switch(breasts.get_visible_size())
		if(0)
			adjective = "a flat"
		if(1)
			adjective = "a very small"
		if(2)
			adjective = "a small"
		if(3)
			adjective = "an average"
		if(4)
			adjective = "a large"
		if(5)
			adjective = "an enormous"
		if(6)
			adjective = "a towering"
		if(7)
			adjective = "a gigantic"
		if(8)
			adjective = "a titanic"
	var/fullness = breasts.get_fullness_description()
	return "[adjective] pair of breasts[fullness ? ", [fullness]" : ""]"
