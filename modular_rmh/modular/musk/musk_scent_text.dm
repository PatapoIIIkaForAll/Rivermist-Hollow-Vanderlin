/proc/musk_quality_text(mob/living/reader, datum/component/musk/musk)
	switch(musk?.get_scent_for(reader))
		if(MUSK_SCENT_FOUL)
			return musk_localized(reader, "It is rank enough to sting the eyes, and my thoughts turn muddy with it.", "Он так резок, что щиплет глаза, и мысли от него мутнеют.")
		if(MUSK_SCENT_PLEASANT)
			if(musk.scent_quality == MUSK_SCENT_FOUL)
				return musk_localized(reader, "Others would wrinkle their noses. To me nothing has ever smelled sweeter.", "Другие поморщились бы. Для меня нет запаха слаще.")
			return musk_localized(reader, "It is sweet to breathe, and every breath leaves me lighter.", "Дышать им сладко, и с каждым вдохом становится легче на душе.")
	return null

/proc/musk_notes_text(mob/reader, list/notes)
	if(!length(notes))
		return null
	var/list/names = list()
	for(var/note in notes)
		names += musk_note_name(reader, note)
	return musk_localized(reader, "There are notes of [english_list(names)] in it.", "В нём угадываются нотки: [names.Join(", ")].")

/proc/musk_note_name(mob/reader, note)
	var/static/list/russian = list(
		"Honey" = "мёд",
		"Milk" = "молоко",
		"Fresh Bread" = "свежий хлеб",
		"Apples" = "яблоки",
		"Berries" = "ягоды",
		"Wine" = "вино",
		"Ale" = "эль",
		"Cinnamon" = "корица",
		"Cloves" = "гвоздика",
		"Mint" = "мята",
		"Roses" = "розы",
		"Lavender" = "лаванда",
		"Meadow Grass" = "луговые травы",
		"Pine Resin" = "сосновая смола",
		"Moss" = "мох",
		"Rain" = "дождь",
		"Sea Salt" = "морская соль",
		"Iron" = "железо",
		"Leather" = "выделанная кожа",
		"Woodsmoke" = "дым костра",
		"Incense" = "ладан",
		"Old Books" = "старые книги",
		"Tar" = "дёготь",
		"Wet Fur" = "мокрая шерсть",
		"Stables" = "конюшня",
		"Ripe Cheese" = "зрелый сыр",
		"Vinegar" = "уксус",
		"Onions" = "лук",
		"Bog Mud" = "болотная тина",
	)
	return musk_localized(reader, LOWER_TEXT(note), russian[note] || LOWER_TEXT(note))

/proc/musk_hiding_text(mob/reader, hiding, hidden)
	if(!hiding)
		return musk_localized(reader, "I stop minding my clothes. Let my scent go where it will.", "Я больше не слежу за одеждой. Пусть мой запах идёт куда хочет.")
	if(hidden)
		return musk_localized(reader, "I draw my clothes close, and my scent stays beneath them.", "Я плотнее запахиваю одежду, и мой запах остаётся под ней.")
	return musk_localized(reader, "I mean to keep my scent under my clothes, but too much of me is bare for that.", "Я хочу удержать запах под одеждой, но слишком многое осталось неприкрытым.")

/proc/musk_hidden_alert_text(mob/reader)
	return musk_localized(reader, "My clothes keep it close to my skin.", "Одежда не выпускает его наружу.")

/proc/musk_smear_text(mob/reader)
	return musk_localized(reader, "A damp sole drags over my lips and nose, and its musk stays behind.", "Влажная ступня проходится по губам и носу, и её мускус остаётся на мне.")

/proc/musk_smear_washed_text(mob/reader)
	return musk_localized(reader, "The smell of somebody's feet washes off my face.", "Запах чужих ног смывается с моего лица.")

/proc/musk_smear_alert_text(mob/reader)
	return musk_localized(reader, "Somebody's sweat is smeared over my face, and I breathe it in with every breath. A wash would take it away.", "Моё лицо вымазано чужим потом, и я дышу им с каждым вдохом. Его унесёт вода.")

/proc/musk_toes_text(mob/reader)
	return musk_localized(reader, "Toes slide over my tongue, warm and salty, and the musk between them fills my mouth.", "Пальцы ног скользят по языку, тёплые и солёные, и мускус между ними заполняет рот.")
