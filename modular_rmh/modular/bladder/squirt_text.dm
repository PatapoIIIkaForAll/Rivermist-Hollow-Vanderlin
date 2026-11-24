/proc/squirt_room_text(mob/living/carbon/human/squirter, mob/living/partner, zone, atom/catcher)
	var/bursts = HAS_TRAIT(squirter, TRAIT_HOLY_URINE) ? "hot, golden bursts" : "hard, hot bursts"
	if(catcher)
		return "[squirter] squirts in [bursts] into \the [catcher]!"
	switch(zone)
		if(SQUIRT_ZONE_HAND)
			return "[squirter] squirts in [bursts], drenching [partner]'s hand!"
		if(FLUID_COAT_FACE)
			return "[squirter] gushes over [partner]'s face in [bursts] that run down [partner.p_their()] chin!"
		if(FLUID_COAT_GROIN)
			return "[squirter] squirts in [bursts], drenching [partner]'s crotch!"
	if(zone)
		return "[squirter] squirts in [bursts] all over [partner]'s [zone]!"
	var/obj/item/clothing/cover = squirter.get_coat_zone_cover(FLUID_COAT_GROIN)
	if(cover)
		return "[squirter] squirts, and a hot gush soaks right through [squirter.p_their()] [cover.name]!"
	return "[squirter] squirts in [bursts] that splatter down [squirter.p_their()] thighs!"

/proc/squirt_own_text(mob/reader)
	var/static/list/english = list(
		"It bursts out of me in hot spurts, and there is no holding any of it back.",
		"Something deep inside gives way, and I gush, again and again.",
		"The peak tears through me and spills out in a hot, helpless flood.",
	)
	var/static/list/russian = list(
		"Из меня бьёт горячими толчками, и сдержать их нет никаких сил.",
		"Глубоко внутри что-то поддаётся, и меня прорывает, снова и снова.",
		"Пик прошивает меня насквозь и хлещет наружу горячим, беспомощным потоком.",
	)
	return bladder_localized(reader, pick(english), pick(russian))

/proc/squirt_eased_text(mob/reader)
	return bladder_localized(reader, "The ache in my bladder lets up a little.", "Тяжесть в пузыре немного отступает.")

/proc/squirt_partner_text(mob/reader, zone)
	switch(zone)
		if(SQUIRT_ZONE_HAND)
			return bladder_localized(reader, "Hot spurts run over my fingers and down my wrist.", "Горячие струи бегут по моим пальцам и стекают по запястью.")
		if(FLUID_COAT_FACE)
			return bladder_localized(reader, "Hot spurts splash over my face and into my mouth.", "Горячие струи бьют мне в лицо и заливают рот.")
		if(FLUID_COAT_GROIN)
			return bladder_localized(reader, "A hot gush floods over my crotch and runs down my thighs.", "Горячая влага хлещет мне на пах и стекает по бёдрам.")
		if(FLUID_COAT_FEET)
			return bladder_localized(reader, "Hot spurts splash over my feet and trickle between my toes.", "Горячие струи плещут мне на ступни и затекают между пальцев.")
	return bladder_localized(reader, "Hot spurts splash all over me.", "Горячие струи брызжут прямо на меня.")
