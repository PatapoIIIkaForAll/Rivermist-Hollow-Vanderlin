/proc/musk_localized(mob/reader, english_text, russian_text)
	return get_preferred_ui_language(reader) == "ru" ? russian_text : english_text

/proc/musk_level_text(mob/reader, level)
	var/static/list/english = list(
		"Sweat beads on my skin. I catch my own scent: salt, warmth and the first faint thread of musk.",
		"My clothes cling to me. The musk is unmistakable now, warm and heavy under my arms and between my legs.",
		"Sweat runs down me in rivulets. Every move stirs a thick, heady musk, and anyone close can taste it in the air.",
		"I reek. The musk rolls off me in waves, rank and animal with a sweetness underneath, and it settles in the throat of everyone around me.",
	)
	var/static/list/russian = list(
		"На коже выступает пот. Я чую собственный запах: соль, тепло и первую тонкую ниточку мускуса.",
		"Одежда липнет к телу. Мускус уже ни с чем не спутать: тёплый, тяжёлый, он копится под мышками и между ног.",
		"Пот стекает по мне ручьями. Каждое движение поднимает густой, пьянящий мускус, и тот, кто рядом, ощутит его вкус прямо в воздухе.",
		"От меня разит. Мускус расходится волнами — терпкий, звериный, со сладостью в глубине, — и оседает в горле у каждого вокруг.",
	)
	return musk_localized(reader, english[level], russian[level])

/proc/musk_alert_text(mob/reader, level)
	var/static/list/english = list(
		"Sweat beads at my temples and in the hollows of my arms. A faint musk follows me like a shadow; a quick wash would rinse it away.",
		"My clothes cling damply to me, and my musk reaches anyone who comes close enough to share a breath. I could use a bath.",
		"I am drenched. My musk hangs heavy about me, and heads turn a few steps away. I need a bath.",
		"I reek of labour and heat. The musk rolls off me like smoke from a censer, and only water will rid me of it.",
	)
	var/static/list/russian = list(
		"Пот бисером выступает на висках и во впадинах подмышек. За мной тенью тянется лёгкий мускус; хватит наскоро умыться, чтобы его смыть.",
		"Одежда влажно липнет к телу, и мой мускус достаётся каждому, кто подойдёт на расстояние вдоха. Не помешало бы искупаться.",
		"Пот льёт ручьями. Мой мускус тяжело висит вокруг, и на него оборачиваются за несколько шагов. Мне нужно искупаться.",
		"От меня разит трудом и жаром. Мускус стелется от меня, как дым от кадила, и избавит от него только вода.",
	)
	return musk_localized(reader, english[level], russian[level])

/proc/musk_weaker_text(mob/reader)
	return musk_localized(reader, "The sweat on my skin cools, and my scent grows softer.", "Пот на коже остывает, и мой запах становится мягче.")

/proc/musk_faded_text(mob/reader)
	return musk_localized(reader, "My musk has faded to almost nothing.", "Мой мускус почти выветрился.")

/proc/musk_wash_text(mob/reader)
	return musk_localized(reader, "The water carries the sweat away, and the musk with it.", "Вода уносит пот, а вместе с ним и мускус.")

/proc/musk_haze_text(mob/reader, level)
	var/static/list/english = list(
		"A warm, salty musk drifts past me. I taste it on the tip of my tongue, like skin after a long day's work, and my head swims for a moment.",
		"The scent settles on my tongue: salt and heat and something deeper, musky and alive. I swallow, and the taste only grows in my mouth.",
		"It coats my tongue like a heavy wine: bitter salt, warm musk, the taste of a body worked to its limit. My thoughts slow and thicken like honey, and my knees go weak.",
		"The musk floods my mouth. I taste it on my tongue, my gums, the back of my throat: rank salt, hot skin, an old animal sweetness like incense burned on a forbidden altar. The world tilts, and nothing is left in my head but that taste.",
	)
	var/static/list/russian = list(
		"Мимо проплывает тёплый солоноватый мускус. Я ощущаю его на кончике языка — вкус кожи после долгого рабочего дня, — и голова на миг плывёт.",
		"Запах оседает на языке: соль, жар и что-то глубже — живое, мускусное. Я сглатываю, но вкус во рту только крепнет.",
		"Он обволакивает язык, как тяжёлое вино: горькая соль, тёплый мускус, вкус тела, выжатого работой до предела. Мысли густеют и тянутся, как мёд, а колени слабеют.",
		"Мускус заливает рот. Я чувствую его на языке, на дёснах, в самой глубине горла: едкая соль, горячая кожа, древняя звериная сладость, словно ладан, сожжённый на запретном алтаре. Мир кренится, и в голове не остаётся ничего, кроме этого вкуса.",
	)
	return musk_localized(reader, english[level], russian[level])

/proc/musk_source_text(mob/reader, mob/living/source)
	return musk_localized(reader, "It comes from [source].", "Источник запаха — [source].")

/proc/musk_lick_text(mob/reader, zone, tier, quality)
	var/static/list/english = list(
		MUSK_ZONE_ARMPITS = list(
			"I drag my tongue through the sweat in the hollow of the armpit. Salt and warm skin, a faint thread of musk: pleasant, and gone almost as soon as I taste it.",
			"The sweat is thick and warm on my tongue, sharp salt over a deep, heady musk. I lap at it again before I can stop myself, breathing it in, and heat pools low in my belly.",
			"The taste strikes like a curse spoken in the old tongue. Salt, iron, a rank sweet musk, the heat of a body that toiled until it broke: it pours over my tongue and down my throat, and I drink it like a starving pilgrim at a profaned well. My sight darkens at the edges. Something ancient in me kneels.",
		),
		MUSK_ZONE_GROIN = list(
			"I lick the sweat from the crease of the groin. It tastes of salt and warm skin, with a soft, private musk beneath.",
			"The musk here is heavier, thick with the body's heat. It clings to my tongue and fills my nose, and I press closer without meaning to, licking slow and deep until my own breath turns ragged.",
			"It tastes of rut and offering. Dark, thick musk floods my mouth, salt and heat and something feral that waited between those thighs like a beast in its den. My thoughts burn out one by one, like candles in a desecrated chapel, until only the hunger is left, and I worship it with my tongue.",
		),
		MUSK_ZONE_BUTT = list(
			"I lick the sweat from between the cheeks. Salt, warmth, a faint musk, far more intimate than I expected.",
			"The sweat here is hot and the musk is dense; it sinks into my tongue with every slow lick. My face burns, my pulse pounds in my ears, and I cannot make myself pull away.",
			"This is the deepest, most forbidden musk of all, and it takes me like a fever-dream of the abyss. Salt and heat and a dark, heavy sweetness seep across my tongue; the world beyond goes grey and silent, and I lap at it like a heretic tasting the one sin worth burning for.",
		),
	)
	var/static/list/russian = list(
		MUSK_ZONE_ARMPITS = list(
			"Я провожу языком по влажной впадинке подмышки. Соль, тёплая кожа, тонкая нотка мускуса — приятно, и вкус тает почти сразу.",
			"Пот густой и тёплый на языке: острая соль поверх глубокого, дурманящего мускуса. Я слизываю его снова, не в силах остановиться, вдыхаю — и жар собирается внизу живота.",
			"Вкус бьёт, как проклятие на древнем наречии. Соль, железо, терпкий сладкий мускус, жар тела, трудившегося до изнеможения, — он заливает язык и стекает в горло, и я пью его, как оголодавший паломник у осквернённого колодца. Края зрения темнеют. Что-то древнее во мне преклоняет колени.",
		),
		MUSK_ZONE_GROIN = list(
			"Я слизываю пот со складки паха. На вкус — соль и тёплая кожа, а под ними мягкий, сокровенный мускус.",
			"Мускус здесь тяжелее, густой от телесного жара. Он липнет к языку и заполняет нос, и я невольно прижимаюсь ближе, вылизывая медленно и глубоко, пока моё собственное дыхание не сбивается.",
			"Он отдаёт гоном и подношением. Густой тёмный мускус заливает рот: соль, жар и что-то дикое, что поджидало между бёдер, как зверь в логове. Мысли гаснут одна за другой, как свечи в осквернённой часовне, пока не остаётся один лишь голод, и я служу ему языком.",
		),
		MUSK_ZONE_BUTT = list(
			"Я слизываю пот между ягодиц. Соль, тепло, лёгкий мускус — куда интимнее, чем казалось.",
			"Пот здесь горячий, а мускус плотный — с каждым медленным движением он въедается в язык. Лицо горит, пульс стучит в ушах, и заставить себя отстраниться не выходит.",
			"Это самый глубокий, самый запретный мускус, и он забирает меня, как горячечный сон о бездне. Соль, жар и тёмная, тяжёлая сладость растекаются по языку; мир вокруг сереет и смолкает, а я вылизываю, как еретик, вкусивший единственный грех, ради которого стоит взойти на костёр.",
		),
	)
	var/list/english_tiers = english[zone]
	var/list/russian_tiers = russian[zone]
	if(!english_tiers)
		return ""
	tier = clamp(tier, 1, MUSK_TIER_MAX)
	. = musk_localized(reader, english_tiers[tier], russian_tiers[tier])
	if(quality < MUSK_QUALITY_HAIRY)
		return
	var/hair_text = musk_hair_text(reader, zone)
	if(hair_text)
		. += " [hair_text]"

/proc/musk_hair_text(mob/reader, zone)
	switch(zone)
		if(MUSK_ZONE_ARMPITS)
			return musk_localized(reader, "The hair there holds the sweat like moss holds rain, and every pass of my tongue wrings more musk from it.", "Волоски там держат пот, как мох держит дождевую воду, и каждое движение языка выжимает из них ещё больше мускуса.")
		if(MUSK_ZONE_GROIN)
			return musk_localized(reader, "The curls there are soaked through; the musk lives in them, and I comb it out with my tongue.", "Завитки там пропитаны насквозь: мускус живёт в них, и я вычёсываю его языком.")
	return null

/proc/musk_plain_lick_text(mob/reader)
	return musk_localized(reader, "Salty sweat and the sharp smell of skin. Nothing more.", "Солёный пот и резкий запах кожи. Ничего больше.")

/proc/musk_press_text(mob/reader, zone, tier)
	var/static/list/english_places = list(
		MUSK_ZONE_ARMPITS = "My face is crushed into a hot, slick armpit. There is nothing to breathe but musk: it fills my nose, slides over my lips and salts my tongue.",
		MUSK_ZONE_GROIN = "My face is pressed hard into the sweaty heat of the crotch. Every breath I fight for is thick, dark musk, and it coats my tongue when I gasp.",
		MUSK_ZONE_BUTT = "My face is smothered between sweaty cheeks. The heat closes over me, and the musk, dense and heavy, is all the air I am allowed.",
	)
	var/static/list/russian_places = list(
		MUSK_ZONE_ARMPITS = "Моё лицо вжимают в горячую влажную подмышку. Дышать нечем, кроме мускуса: он забивает нос, скользит по губам и солит язык.",
		MUSK_ZONE_GROIN = "Моё лицо крепко вжимают в потный жар паха. Каждый вдох, который удаётся урвать, — густой тёмный мускус, и он ложится на язык, когда я хватаю ртом воздух.",
		MUSK_ZONE_BUTT = "Моё лицо утопает между потных ягодиц. Жар смыкается надо мной, и мускус — плотный, тяжёлый — единственный воздух, который мне позволен.",
	)
	var/static/list/english_tiers = list(
		"My head spins.",
		"The taste sinks into me, and my body answers before I can think.",
		"The dark behind my eyes blooms red: the musk is a liturgy, the taste is a sacrament, and I come apart beneath it.",
	)
	var/static/list/russian_tiers = list(
		"Голова идёт кругом.",
		"Вкус впитывается в меня, и тело откликается раньше, чем я успеваю подумать.",
		"Тьма за веками расцветает алым: мускус — литургия, вкус — причастие, и я распадаюсь под ними на части.",
	)
	if(!english_places[zone])
		return ""
	tier = clamp(tier, 1, MUSK_TIER_MAX)
	return musk_localized(reader, "[english_places[zone]] [english_tiers[tier]]", "[russian_places[zone]] [russian_tiers[tier]]")

/proc/musk_burst_text(mob/reader)
	return musk_localized(reader, "Wave after wave crashes through me, and I can't stop shaking.", "Волна за волной прокатывается сквозь меня, и я не могу унять дрожь.")
