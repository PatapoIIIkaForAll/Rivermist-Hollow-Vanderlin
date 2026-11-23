/proc/musk_bond_level_text(mob/reader, level, source_label)
	var/static/list/english = list(
		"That scent has settled somewhere behind my ribs. When it is near, my body stirs before I do.",
		"I look for that scent in every room now, and when I find it, I ache.",
		"That scent has a voice now. Should its owner tell me to put a hand between my legs, I would.",
		"My knees know what to do before my thoughts arrive. I only wait to be told how I may please.",
		"Nothing is left of me that does not belong to that scent. It may take root in my thoughts and in my body alike.",
	)
	var/static/list/russian = list(
		"Этот запах поселился где-то под рёбрами. Стоит ему оказаться рядом, и тело откликается раньше меня.",
		"Теперь я ищу этот запах в каждой комнате, а найдя — томлюсь.",
		"У этого запаха теперь есть голос. Вели мне его владелец опустить руку между ног — и я послушаюсь.",
		"Колени сами знают, что делать, раньше мыслей. Остаётся лишь ждать, когда мне скажут, чем угодить.",
		"Во мне не осталось ничего, что не принадлежало бы этому запаху. Пусть пустит корни и в мыслях, и в теле.",
	)
	return musk_localized(reader, "[english[level]] It is the scent of [source_label].", "[russian[level]] Его источник — [source_label].")

/proc/musk_bond_contact_text(mob/reader, level)
	var/static/list/english = list(
		"That scent is near. Warmth gathers low in my belly.",
		"That scent is near, and my whole body leans toward it.",
		"That scent is near. I catch myself listening for a word.",
		"That scent is near, and my knees go soft.",
		"That scent is near, and a smile comes to me all on its own.",
	)
	var/static/list/russian = list(
		"Тот самый запах рядом. Внизу живота собирается тепло.",
		"Тот самый запах рядом, и всё тело тянется к нему.",
		"Тот самый запах рядом. Я ловлю себя на том, что жду одного лишь слова.",
		"Тот самый запах рядом, и колени слабеют.",
		"Тот самый запах рядом, и улыбка приходит сама собой.",
	)
	return level ? musk_localized(reader, english[level], russian[level]) : null

/proc/musk_bond_alert_text(mob/reader, level)
	var/static/list/english = list(
		"A scent that has a hold on me is near. I cannot quite be calm.",
		"A scent that has a hold on me is near. I ache, and the ache will not pass.",
		"A scent that has a hold on me is near. If I am told to touch myself, I will.",
		"A scent that has a hold on me is near. If I am told to please, I will.",
		"The scent I belong to is near. Should our bodies allow it, coupling will bear fruit, and the thought is sweet.",
	)
	var/static/list/russian = list(
		"Рядом запах, который имеет надо мной власть. Успокоиться до конца не выходит.",
		"Рядом запах, который имеет надо мной власть. Томление не проходит.",
		"Рядом запах, который имеет надо мной власть. Если мне велят ласкать себя, я так и сделаю.",
		"Рядом запах, который имеет надо мной власть. Если мне велят угодить, я так и сделаю.",
		"Рядом запах, которому я принадлежу. Если позволят тела, близость принесёт плод, и от этой мысли сладко.",
	)
	return musk_localized(reader, english[level], russian[level])

/proc/musk_bond_title(mob/reader)
	return musk_localized(reader, "Scent Bonds", "Узы запаха")

/proc/musk_bond_wait_text(mob/reader, can_sleep)
	if(can_sleep)
		return musk_localized(reader, "I am brimming with that scent. It will sink no deeper before I have slept and a new day has dawned.", "Этот запах переполняет меня. Глубже он осядет не раньше, чем придёт сон и займётся новый день.")
	return musk_localized(reader, "I am brimming with that scent. It will sink no deeper before a new day has dawned.", "Этот запах переполняет меня. Глубже он осядет не раньше, чем займётся новый день.")

/proc/musk_bond_greeting_text(mob/reader, greeting)
	if(greeting == MUSK_GREETING_FATED)
		return musk_localized(reader, "This is it: the scent I have carried within me without ever having breathed it.", "Вот он — запах, который всегда жил во мне, хотя я вдыхаю его впервые.")
	return musk_localized(reader, "I know this scent. My body remembers it from days long past.", "Я знаю этот запах. Тело помнит его с давних дней.")

/proc/musk_bond_followers_text(mob/reader, list/names)
	return musk_localized(reader, "My scent holds: [names.Join(", ")].", "Мой запах держит: [names.Join(", ")].")

/proc/musk_bond_none_text(mob/reader)
	return musk_localized(reader, "No scent holds me, and no one does as mine bids.", "Ни один запах не держит меня, и моему никто не подвластен.")

/proc/musk_bond_severed_text(mob/reader)
	return musk_localized(reader, "I breathe out, and let that scent go for good.", "Я выдыхаю и навсегда отпускаю этот запах.")

/proc/musk_mark_thrall_text(mob/reader)
	return musk_localized(reader, "Somewhere out there is a scent my body already kneels to. I do not know whose it is, but I will know it from the first breath.", "Где-то есть запах, перед которым моё тело уже преклонило колени. Чей он, неизвестно, но я узнаю его с первого вдоха.")

/proc/musk_mark_source_text(mob/reader)
	return musk_localized(reader, "Somewhere out there, someone already bears the mark of my scent. I will know them by how their breath catches when I come near.", "Кто-то уже носит метку моего запаха. Я узнаю её по дыханию, что собьётся рядом со мной.")

/proc/musk_order_touch_text(mob/reader, mob/living/giver)
	return musk_localized(reader, "The scent closes over my thoughts, and my hand is already moving. [giver] wants it so.", "Запах смыкается над мыслями, и рука уже движется сама. Так хочет [giver].")

/proc/musk_order_service_text(mob/reader, mob/living/giver)
	return musk_localized(reader, "The scent draws me in, and my body already knows what [giver] wants of it.", "Запах притягивает меня, и тело уже знает, чего от него хочет [giver].")

/proc/musk_order_obeyed_text(mob/reader, mob/living/thrall)
	return musk_localized(reader, "I let my scent speak for me, and [thrall] obeys.", "Я даю своему запаху сказать всё за меня. Подчиняется [thrall].")

/proc/musk_order_out_of_reach_text(mob/reader)
	return musk_localized(reader, "My scent no longer reaches anyone who would obey.", "Мой запах больше не достаёт до того, кто подчинился бы.")

/proc/musk_order_failed_text(mob/reader, mob/living/thrall)
	return musk_localized(reader, "[thrall] shivers, but cannot do it here and now.", "[thrall] вздрагивает, но здесь и сейчас это невозможно.")

/proc/musk_drink_text(mob/living/reader, mob/living/donor)
	return musk_fluid_text(reader, donor, "It goes down warm, and somebody's body is in it: salt, skin, a living musk.", "Глоток идёт тепло, и в нём — чьё-то тело: соль, кожа, живой мускус.")

/proc/musk_sniff_text(mob/living/reader, mob/living/donor)
	return musk_fluid_text(reader, donor, "Beneath it there is something else: salt, skin, somebody's living musk.", "Под этим запахом есть ещё что-то: соль, кожа, чей-то живой мускус.")

/proc/musk_fluid_text(mob/living/reader, mob/living/donor, english, russian)
	var/list/lines = list(musk_localized(reader, english, russian))
	var/notes = musk_notes_text(reader, donor.get_musk()?.scent_notes)
	if(notes)
		lines += notes
	if(reader.get_scent_bond_level(donor))
		lines += musk_localized(reader, "I know it. It is the one that holds me.", "Я узнаю его. Это тот, что держит меня.")
	return lines.Join(" ")
