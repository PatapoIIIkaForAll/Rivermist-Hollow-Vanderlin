// (included via vanderlin.dme)
/datum/dungeon_cosmetic
	var/id = "base"
	var/name = "Cosmetic"
	var/desc = ""
	var/echo_cost = 50
	/// "title" cosmetics provide a visible name suffix
	var/cosmetic_kind = "title"
	/// For titles: the suffix text, e.g. "Delver of the Deep"
	var/title_text
	/// Won in events only: hidden from the Ledger until owned and never for sale.
	var/event_only = FALSE

/datum/dungeon_cosmetic/title_delver
	id = "title_delver"
	name = "Title: Delver"
	desc = "Be known as a Delver of the Deep."
	echo_cost = 50
	title_text = "Delver of the Deep"

/datum/dungeon_cosmetic/title_breaker
	id = "title_breaker"
	name = "Title: Breaker of Floors"
	desc = "Be known as a Breaker of Floors."
	echo_cost = 200
	title_text = "Breaker of Floors"

/proc/get_dungeon_cosmetic_catalogue()
	var/list/catalogue = list()
	for(var/cosmetic_type in subtypesof(/datum/dungeon_cosmetic))
		var/datum/dungeon_cosmetic/cosmetic = new cosmetic_type
		if(cosmetic.id == "base")
			qdel(cosmetic)
			continue
		catalogue += cosmetic
	return catalogue

/proc/get_dungeon_cosmetic_by_id(cosmetic_id)
	for(var/cosmetic_type in subtypesof(/datum/dungeon_cosmetic))
		var/datum/dungeon_cosmetic/cosmetic = new cosmetic_type
		if(cosmetic.id == cosmetic_id)
			return cosmetic
		qdel(cosmetic)
	return null

/mob/living/carbon/human
	/// Title shown after the face name by get_face_name(); real_name and records stay untouched.
	var/tmp/applied_dungeon_title

/// Title suffix for get_face_name(); Life rebuilds name every tick, so it cannot live in name itself.
/mob/living/carbon/proc/get_dungeon_title_suffix()
	return null

/mob/living/carbon/human/get_dungeon_title_suffix()
	return applied_dungeon_title ? ", [applied_dungeon_title]" : null

/// Reconciles the visible dungeon title with this body's current owner's persistent selection.
/mob/living/carbon/human/proc/update_dungeon_title()
	applied_dungeon_title = null
	if(ckey)
		var/datum/dungeon_progress/progress = get_dungeon_progress(ckey)
		if(progress?.selected_title)
			var/datum/dungeon_cosmetic/cosmetic = get_dungeon_cosmetic_by_id(progress.selected_title)
			applied_dungeon_title = cosmetic?.title_text
			qdel(cosmetic)
	name = get_visible_name()

/mob/living/carbon/human/Login()
	. = ..()
	update_dungeon_title()

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(!ckey)
		return
	var/datum/dungeon_progress/progress = GLOB.player_dungeon_progress[ckey]
	if(!progress || !progress.selected_title)
		return
	var/datum/dungeon_cosmetic/cosmetic = get_dungeon_cosmetic_by_id(progress.selected_title)
	// Fresh bodies acquire their suffix when they next open the Ledger. Keep
	// the old examine line as a fallback until then, without printing it twice.
	if(cosmetic?.title_text && applied_dungeon_title != cosmetic.title_text)
		. += span_notice("<b>[src.name], [cosmetic.title_text].</b>")
	qdel(cosmetic)
