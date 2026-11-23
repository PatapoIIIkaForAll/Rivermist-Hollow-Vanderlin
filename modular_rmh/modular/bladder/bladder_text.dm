/proc/bladder_localized(mob/reader, english_text, russian_text)
	return get_preferred_ui_language(reader) == "ru" ? russian_text : english_text

/proc/bladder_alert_name(mob/reader, level)
	var/static/list/english = list("Need to Go", "Desperate", "Bursting")
	var/static/list/russian = list("Хочется в туалет", "Невтерпёж", "Пузырь лопается")
	return bladder_localized(reader, english[level], russian[level])

/proc/bladder_alert_desc(mob/reader, level)
	var/static/list/english = list(
		"A familiar weight sits low in my belly. I should find a privy before long.",
		"Every step jostles my full bladder. I need somewhere private, and soon.",
		"My bladder is stretched tight and aching. Holding it in is all I can think about.",
	)
	var/static/list/russian = list(
		"Внизу живота знакомая тяжесть. Скоро стоит найти уборную.",
		"Каждый шаг отдаётся в полном пузыре. Нужно укромное место, и поскорее.",
		"Пузырь натянут и ноет. Я только и думаю о том, как бы удержаться.",
	)
	return bladder_localized(reader, english[level], russian[level])

/proc/bladder_urge_text(mob/reader, level)
	var/static/list/english = list(
		"A familiar heaviness settles low in my belly. I'll need to relieve myself before long.",
		"My bladder is full and insistent. I need to find somewhere to go, and soon.",
		"My bladder throbs, stretched past full. Every movement makes me clench.",
	)
	var/static/list/russian = list(
		"Внизу живота поселяется знакомая тяжесть. Скоро придётся справить нужду.",
		"Пузырь полон и настойчиво напоминает о себе. Нужно найти, куда сходить, и поскорее.",
		"Переполненный пузырь пульсирует. От каждого движения я невольно сжимаюсь.",
	)
	return bladder_localized(reader, english[level], russian[level])

/proc/bladder_reminder_text(mob/reader, level)
	var/static/list/english = list(
		list(
			"I could do with a trip to the privy.",
			"The thought of a privy keeps drifting back to me.",
		),
		list(
			"I cross my legs and wait for the wave of urgency to pass. It barely does.",
			"I really, really need to go.",
		),
		list(
			"A hot ache pulses in my bladder. I can't hold this much longer.",
			"I squeeze my thighs together, trembling. It hurts to hold it.",
		),
	)
	var/static/list/russian = list(
		list(
			"Не помешало бы заглянуть в уборную.",
			"Мысли то и дело возвращаются к уборной.",
		),
		list(
			"Я скрещиваю ноги и жду, пока схлынет волна. Она почти не отступает.",
			"Мне очень, очень надо.",
		),
		list(
			"В пузыре пульсирует горячая боль. Долго я так не продержусь.",
			"Я дрожа сжимаю бёдра. Терпеть уже больно.",
		),
	)
	return bladder_localized(reader, pick(english[level]), pick(russian[level]))

/proc/bladder_stress_text(mob/reader, level)
	var/static/list/english = list(
		"I need to relieve myself.",
		"I really have to go. Where is a privy?",
		"My bladder is bursting. It hurts to hold it in!",
	)
	var/static/list/russian = list(
		"Мне нужно справить нужду.",
		"Мне очень надо. Где тут уборная?",
		"Пузырь вот-вот лопнет. Терпеть больно!",
	)
	return bladder_localized(reader, english[level], russian[level])

/proc/bladder_relief_text(mob/reader, was_urgent)
	if(was_urgent)
		return bladder_localized(reader, "Ahh... The ache melts away, and I sag with relief.", "Ах... Боль тает, и меня накрывает облегчение.")
	return bladder_localized(reader, "That's better.", "Так-то лучше.")

/proc/bladder_press_text(mob/reader, urge)
	var/static/list/english = list(
		"The hand on my belly makes me aware of how much I've been drinking.",
		"The pressure on my belly sends a sharp, needy pang straight to my bladder.",
		"My bladder strains under the hand. I bite my lip and clench with everything I have.",
		"Pressed like this, my bursting bladder screams. I can't hold it much longer.",
	)
	var/static/list/russian = list(
		"От ладони на животе я вспоминаю, сколько было выпито.",
		"Давление на живот отзывается острым нетерпеливым уколом в пузыре.",
		"Пузырь напрягается под ладонью. Я закусываю губу и сжимаюсь изо всех сил.",
		"Под таким нажимом переполненный пузырь просто кричит. Я долго не выдержу.",
	)
	var/index = clamp(urge + 1, 1, length(english))
	return bladder_localized(reader, english[index], russian[index])

/proc/bladder_leak_text(mob/reader)
	return bladder_localized(reader, "A hot spurt escapes me before I can clench it back.", "Горячая струйка вырывается прежде, чем я успеваю сжаться.")

/proc/bladder_flood_text(mob/reader)
	return bladder_localized(reader, "I can't hold it. Everything gives way at once, and hot piss floods out of me, soaking my crotch and running down my legs.", "Я не выдерживаю. Всё сдаётся разом: горячая моча хлещет из меня, заливая пах и стекая по ногам.")

/proc/bladder_drink_text(mob/reader)
	var/static/list/english = list(
		"Hot piss fills my mouth, salty and bitter. I swallow.",
		"I gulp down the warm stream, the sharp salt of it lingering on my tongue.",
		"It floods my mouth faster than I can swallow, hot and heavy with salt.",
	)
	var/static/list/russian = list(
		"Рот наполняет горячая моча, солёная и горькая. Я глотаю.",
		"Я жадно глотаю тёплую струю, на языке остаётся резкая соль.",
		"Она льётся в рот быстрее, чем я успеваю глотать, горячая и солёная.",
	)
	return bladder_localized(reader, pick(english), pick(russian))

/proc/bladder_inside_text(mob/reader, hole_slot)
	switch(hole_slot)
		if(ORGAN_SLOT_VAGINA)
			return bladder_localized(reader, "Hot liquid floods deep into my pussy, filling me with heat.", "Горячая жидкость заливает моё лоно, наполняя меня жаром.")
		if(ORGAN_SLOT_ANUS)
			return bladder_localized(reader, "Hot liquid pumps deep into my ass, swelling me with heat.", "Горячая жидкость вливается глубоко мне в зад, распирая жаром.")
		if(DOCKING_KIND_URETHRA)
			return bladder_localized(reader, "Hot piss forces its way down my cock and floods my bladder.", "Горячая моча пробивается по моему члену внутрь и заливает мой пузырь.")
	return bladder_localized(reader, "Hot piss pours straight down my throat.", "Горячая моча льётся мне прямо в горло.")

/proc/bladder_urethra_backflow_text(mob/reader)
	return bladder_localized(reader, "Hot piss forces into my cock and spurts right back out.", "Горячая моча врывается в мой член и тут же брызжет обратно.")

/proc/bladder_stream_source(mob/living/user)
	if(user.getorganslot(ORGAN_SLOT_PENIS))
		return "cock"
	if(user.getorganslot(ORGAN_SLOT_VAGINA))
		return "pussy"
	return "crotch"

/proc/bladder_hole_name(hole_slot)
	switch(hole_slot)
		if(ORGAN_SLOT_VAGINA)
			return "pussy"
		if(ORGAN_SLOT_ANUS)
			return "ass"
		if(DOCKING_KIND_URETHRA)
			return "urethra"
	return "throat"
