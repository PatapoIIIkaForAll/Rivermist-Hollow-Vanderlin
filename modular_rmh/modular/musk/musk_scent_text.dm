/proc/musk_quality_text(mob/living/reader, datum/component/musk/musk)
	switch(musk?.get_scent_for(reader))
		if(MUSK_SCENT_FOUL)
			return musk_localized(reader, "It is rank enough to sting the eyes, and my thoughts turn muddy with it.", "Он так резок, что щиплет глаза, и мысли от него мутнеют.")
		if(MUSK_SCENT_PLEASANT)
			if(musk.scent_quality == MUSK_SCENT_FOUL)
				return musk_localized(reader, "Others would wrinkle their noses. To me nothing has ever smelled sweeter.", "Другие поморщились бы. Для меня нет запаха слаще.")
			return musk_localized(reader, "It is sweet to breathe, and every breath leaves me lighter.", "Дышать им сладко, и с каждым вдохом становится легче на душе.")
	return null

/proc/musk_notice_text(mob/reader, quality, level)
	var/heavy = level >= MUSK_HEAVY_LEVEL
	switch(quality)
		if(MUSK_SCENT_FOUL)
			if(heavy)
				return musk_localized(reader, "A heavy reek of sweat hits my nose. It stinks.", "В нос бьёт тяжёлый, вонючий запах пота.")
			return musk_localized(reader, "A stinking, sour smell of sweat reaches my nose.", "До меня доносится вонючий, кислый запах пота.")
		if(MUSK_SCENT_PLEASANT)
			if(heavy)
				return musk_localized(reader, "A heavy smell of sweat hangs in the air, rich and oddly pleasant.", "В воздухе висит тяжёлый запах пота, густой и неожиданно приятный.")
			return musk_localized(reader, "I catch a smell of sweat nearby, and it is not unpleasant at all.", "Я улавливаю рядом запах пота, и он совсем не противен.")
	if(heavy)
		return musk_localized(reader, "A heavy smell of sweat hangs in the air.", "В воздухе висит тяжёлый запах пота.")
	return musk_localized(reader, "I catch a plain smell of sweat nearby.", "Я улавливаю рядом обычный запах пота.")

/proc/musk_air_text(mob/reader, level)
	var/static/list/english = list("fresh sweat", "warm sweat and musk", "heavy musk", "rank, heady musk")
	var/static/list/russian = list("свежего пота", "тёплого пота и мускуса", "тяжёлого мускуса", "резкого, дурманящего мускуса")
	var/index = clamp(level, 1, MUSK_LEVEL_MAX)
	return musk_localized(reader, "The odour of [english[index]] fills the air.", "В воздухе стоит запах [russian[index]].")

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
		"Wildflowers" = "полевые цветы",
		"Dried Flowers" = "сухоцветы",
		"Violets" = "фиалки",
		"Lilac" = "сирень",
		"Jasmine" = "жасмин",
		"Lilies" = "лилии",
		"Lily of the Valley" = "ландыши",
		"Peonies" = "пионы",
		"Tulips" = "тюльпаны",
		"Irises" = "ирисы",
		"Hyacinths" = "гиацинты",
		"Cornflowers" = "васильки",
		"Poppies" = "маки",
		"Daisies" = "маргаритки",
		"Dandelions" = "одуванчики",
		"Sunflowers" = "подсолнухи",
		"Marigolds" = "бархатцы",
		"Chamomile" = "ромашка",
		"Clover" = "клевер",
		"Heather" = "вереск",
		"Honeysuckle" = "жимолость",
		"Water Lilies" = "кувшинки",
		"Elderflower" = "цветы бузины",
		"Linden Blossom" = "липовый цвет",
		"Apple Blossom" = "яблоневый цвет",
		"Cherry Blossom" = "вишнёвый цвет",
		"Paper" = "бумага",
		"Parchment" = "пергамент",
		"Ink" = "чернила",
		"Sealing Wax" = "сургуч",
		"Candle Wax" = "свечной воск",
		"Beeswax" = "пчелиный воск",
		"Chalk" = "мел",
		"Dust" = "пыль",
		"Feathers" = "перья",
		"Linen" = "лён",
		"Cotton" = "хлопок",
		"Wool" = "шерсть",
		"Silk" = "шёлк",
		"Fresh Laundry" = "свежее бельё",
		"Soap" = "мыло",
		"Rope" = "верёвка",
		"Lamp Oil" = "ламповое масло",
		"Linseed Oil" = "льняное масло",
		"Paint" = "краска",
		"Varnish" = "лак",
		"Clay" = "глина",
		"Brick" = "кирпич",
		"Wet Stone" = "мокрый камень",
		"Sand" = "песок",
		"Coal" = "уголь",
		"Ash" = "пепел",
		"Copper" = "медь",
		"Silver" = "серебро",
		"Amber" = "янтарь",
		"Sawdust" = "опилки",
		"Cedar" = "кедр",
		"Oak" = "дуб",
		"Birch" = "берёза",
		"Juniper" = "можжевельник",
		"Sandalwood" = "сандал",
		"Willow Bark" = "ивовая кора",
		"Pine Needles" = "хвоя",
		"Dry Leaves" = "сухие листья",
		"Ferns" = "папоротник",
		"Mushrooms" = "грибы",
		"Damp Earth" = "сырая земля",
		"Hay" = "сено",
		"Straw" = "солома",
		"Grain" = "зерно",
		"Flour" = "мука",
		"Hops" = "хмель",
		"Snow" = "снег",
		"Frost" = "мороз",
		"Thunderstorm" = "гроза",
		"Morning Dew" = "утренняя роса",
		"Mist" = "туман",
		"River Water" = "речная вода",
		"Seaweed" = "водоросли",
		"Thyme" = "тимьян",
		"Sage" = "шалфей",
		"Rosemary" = "розмарин",
		"Basil" = "базилик",
		"Dill" = "укроп",
		"Bay Leaf" = "лавровый лист",
		"Wormwood" = "полынь",
		"Tea" = "чай",
		"Pipe Tobacco" = "трубочный табак",
		"Pepper" = "перец",
		"Nutmeg" = "мускатный орех",
		"Ginger" = "имбирь",
		"Anise" = "анис",
		"Caraway" = "тмин",
		"Saffron" = "шафран",
		"Vanilla" = "ваниль",
		"Almonds" = "миндаль",
		"Walnuts" = "грецкие орехи",
		"Chestnuts" = "каштаны",
		"Butter" = "сливочное масло",
		"Pears" = "груши",
		"Plums" = "сливы",
		"Cherries" = "вишня",
		"Grapes" = "виноград",
		"Lemon" = "лимон",
		"Oranges" = "апельсины",
		"Cucumber" = "огурец",
		"Myrrh" = "мирра",
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
