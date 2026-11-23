/proc/docking_localized(mob/reader, english_text, russian_text)
	return get_preferred_ui_language(reader) == "ru" ? russian_text : english_text

/proc/docking_start_text(mob/living/user, mob/living/target, kind, sleeve_is_user)
	switch(kind)
		if(DOCKING_KIND_FORESKIN)
			if(sleeve_is_user)
				return "[user] presses [user.p_their()] cockhead to [target]'s and rolls [user.p_their()] foreskin forward over it!"
			return "[user] pinches [target]'s foreskin open and slips the head of [user.p_their()] cock inside!"
		if(DOCKING_KIND_SHEATH)
			if(sleeve_is_user)
				return "[user] spreads [user.p_their()] sheath and guides [target]'s cock inside it!"
			return "[user] nudges the tip of [user.p_their()] cock into [target]'s sheath!"
		if(DOCKING_KIND_URETHRA)
			if(sleeve_is_user)
				return "[user] spreads the slit of [user.p_their()] cockhead and guides the tip of [target]'s cock inside!"
			return "[user] presses the tip of [user.p_their()] cock to [target]'s and works it into [target.p_their()] urethra!"
	if(sleeve_is_user)
		return "[user] parts [user.p_their()] genital slit and guides [target]'s cock inside!"
	return "[user] parts [target]'s genital slit with the tip of [user.p_their()] cock and slides inside!"

/proc/docking_perform_text(mob/living/user, mob/living/target, kind, sleeve_is_user, adjective, stretched, hidden)
	switch(kind)
		if(DOCKING_KIND_FORESKIN)
			if(sleeve_is_user)
				if(stretched)
					return "[user] [adjective] stretches [user.p_their()] foreskin around the swollen head of [target]'s cock."
				return "[user] [adjective] works [user.p_their()] foreskin back and forth over the head of [target]'s cock."
			if(stretched)
				return "[user] [adjective] forces [user.p_their()] thick cockhead into [target]'s straining foreskin."
			return "[user] [adjective] pumps [user.p_their()] cockhead inside [target]'s foreskin."
		if(DOCKING_KIND_SHEATH)
			if(sleeve_is_user)
				if(stretched)
					return "[user] [adjective] works [user.p_their()] straining sheath over [target]'s thick cock."
				return "[user] [adjective] squeezes [user.p_their()] sheath around [target]'s cock."
			if(stretched)
				return "[user] [adjective] forces [user.p_their()] thick cock into [target]'s straining sheath."
			if(hidden)
				return "[user] [adjective] thrusts into [target]'s sheath, rubbing against the cock tucked inside."
			return "[user] [adjective] thrusts into [target]'s sheath, grinding along the base of [target.p_their()] shaft."
		if(DOCKING_KIND_URETHRA)
			if(sleeve_is_user)
				if(stretched)
					return "[user] [adjective] forces [target]'s thick tip deeper down [user.p_their()] straining urethra."
				return "[user] [adjective] works the tip of [target]'s cock in and out of [user.p_their()] urethra."
			if(stretched)
				return "[user] [adjective] forces [user.p_their()] thick tip down [target]'s straining urethra."
			return "[user] [adjective] pumps the tip of [user.p_their()] cock in and out of [target]'s urethra."
	if(sleeve_is_user)
		if(stretched)
			return "[user] [adjective] works [user.p_their()] straining slit over [target]'s thick cock."
		return "[user] [adjective] clenches [user.p_their()] slit around [target]'s cock."
	if(stretched)
		return "[user] [adjective] forces [user.p_their()] thick cock into [target]'s straining slit."
	if(hidden)
		return "[user] [adjective] thrusts into [target]'s slit, sliding along the cock hidden within."
	return "[user] [adjective] thrusts into [target]'s slit, sliding alongside [target.p_their()] shaft."

/proc/docking_finish_text(mob/living/user, mob/living/target, kind, sleeve_is_user)
	switch(kind)
		if(DOCKING_KIND_FORESKIN)
			if(sleeve_is_user)
				return "[user] lets [target]'s cockhead slip out of [user.p_their()] foreskin."
			return "[user] draws [user.p_their()] cockhead out of [target]'s foreskin."
		if(DOCKING_KIND_SHEATH)
			if(sleeve_is_user)
				return "[user] lets [target]'s cock slide out of [user.p_their()] sheath."
			return "[user] pulls [user.p_their()] cock out of [target]'s sheath."
		if(DOCKING_KIND_URETHRA)
			if(sleeve_is_user)
				return "[user] eases [target]'s tip out of [user.p_their()] urethra."
			return "[user] draws the tip of [user.p_their()] cock out of [target]'s urethra."
	if(sleeve_is_user)
		return "[user] lets [target]'s cock slip out of [user.p_their()] slit."
	return "[user] slides [user.p_their()] cock out of [target]'s slit."

/proc/docking_climax_text(mob/living/climaxer, mob/living/partner, kind, climaxer_is_sleeve)
	switch(kind)
		if(DOCKING_KIND_FORESKIN)
			if(climaxer_is_sleeve)
				return "[climaxer] cums inside [climaxer.p_their()] own foreskin, bathing [partner]'s cockhead!"
			return "[climaxer] spurts into [partner]'s foreskin until it overflows!"
		if(DOCKING_KIND_SHEATH)
			if(climaxer_is_sleeve)
				return "[climaxer] climaxes, [climaxer.p_their()] sheath clenching around [partner]'s cock!"
			return "[climaxer] floods [partner]'s sheath with seed!"
	if(climaxer_is_sleeve)
		return "[climaxer] climaxes, [climaxer.p_their()] slit clenching around [partner]'s cock!"
	return "[climaxer] pumps [climaxer.p_their()] seed into [partner]'s slit!"

/proc/docking_sleeve_feel_text(mob/reader, kind, stretched)
	switch(kind)
		if(DOCKING_KIND_FORESKIN)
			if(stretched)
				return docking_localized(reader, "My foreskin is stretched tight around a head far too thick for it.", "Моя крайняя плоть туго натянута на слишком толстую для неё головку.")
			return docking_localized(reader, "Another cockhead throbs under my foreskin, hot and slick against my own.", "Чужая головка пульсирует под моей крайней плотью, горячая и скользкая, прямо у моей.")
		if(DOCKING_KIND_SHEATH)
			if(stretched)
				return docking_localized(reader, "My sheath strains wide around the thick shaft inside it.", "Мои ножны растянуты до предела вокруг толстого ствола.")
			return docking_localized(reader, "A hard cock pushes into my sheath, snug against the base of my own.", "Твёрдый член протискивается в мои ножны и плотно прижимается к основанию моего.")
		if(DOCKING_KIND_URETHRA)
			if(stretched)
				return docking_localized(reader, "My urethra burns, stretched wide around a tip far too thick for it.", "Моя уретра горит, растянутая вокруг слишком толстой для неё головки.")
			return docking_localized(reader, "A hot tip pushes down my urethra, filling it from the inside.", "Горячая головка входит в мою уретру и распирает её изнутри.")
	if(stretched)
		return docking_localized(reader, "My slit stretches wide, barely taking the thick shaft.", "Моя щель растягивается, с трудом принимая толстый ствол.")
	return docking_localized(reader, "A hot cock slides into my slit and presses close against my own shaft.", "Горячий член скользит в мою щель и тесно прижимается к моему стволу.")

/proc/docking_inner_feel_text(mob/reader, kind)
	switch(kind)
		if(DOCKING_KIND_FORESKIN)
			return docking_localized(reader, "Warm, soft skin hugs the head of my cock and slides with every movement.", "Тёплая мягкая кожа обнимает мою головку и скользит при каждом движении.")
		if(DOCKING_KIND_SHEATH)
			return docking_localized(reader, "The hot, snug sheath squeezes my cock tight against another.", "Горячие тесные ножны сжимают мой член, прижимая его к чужому.")
		if(DOCKING_KIND_URETHRA)
			return docking_localized(reader, "A tight, slick channel squeezes the very tip of my cock.", "Тугой скользкий канал сжимает самый кончик моего члена.")
	return docking_localized(reader, "The slit clings slick and hot around my cock, pressing it to another.", "Скользкая горячая щель обхватывает мой член и прижимает его к чужому.")

/proc/docking_urethra_climax_text(mob/living/climaxer, mob/living/partner, climaxer_is_sleeve, backflow)
	if(backflow)
		if(climaxer_is_sleeve)
			return "[climaxer] climaxes around [partner]'s tip, and the seed gushes out over both cocks!"
		return "[climaxer] cums into [partner]'s urethra until it gushes back out over [partner.p_their()] cock!"
	if(climaxer_is_sleeve)
		return "[climaxer] climaxes, but [climaxer.p_their()] plugged cock forces the seed back down [partner]'s urethra into [partner.p_their()] balls!"
	return "[climaxer] pumps [climaxer.p_their()] seed down [partner]'s urethra, deep into [partner.p_their()] balls!"

/proc/docking_urethra_dry_text(mob/living/climaxer, mob/living/partner)
	return "[climaxer] shudders through a dry climax, [climaxer.p_their()] cock still joined to [partner]'s!"

/proc/docking_overfill_alert_name(mob/reader)
	return docking_localized(reader, "Overfilled", "Переполнен")

/proc/docking_overfill_alert_desc(mob/reader)
	return docking_localized(reader, "My balls are swollen past full and leak a little with every step.", "Мои яйца переполнены сверх меры и понемногу подтекают при каждом шаге.")

/proc/docking_overfill_start_text(mob/reader)
	return docking_localized(reader, "Seed floods back into my balls, swelling them past full!", "Семя заливается обратно в мои яйца, распирая их сверх меры!")

/proc/docking_overfill_reminder_text(mob/reader)
	return docking_localized(reader, "My overfilled balls hang heavy, aching dully.", "Переполненные яйца налиты тяжестью и тупо ноют.")

/proc/docking_overfill_relief_text(mob/reader)
	return docking_localized(reader, "The swollen ache in my balls finally eases.", "Распирающая боль в яйцах наконец отступает.")
