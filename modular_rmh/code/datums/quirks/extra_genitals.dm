/// Perception a nearby onlooker needs to spot visible extra genitals on examine.
#define EXTRA_GENITAL_PERCEPTION_MIN 7
/// Arcane skill to sense summoned-but-covered extra genitals.
#define EXTRA_GENITAL_ARCANE_HIDDEN SKILL_RANK_JOURNEYMAN
/// Arcane skill to sense fully-latent (unsummoned) extra genitals.
#define EXTRA_GENITAL_ARCANE_LATENT SKILL_RANK_EXPERT

/proc/extra_genitals_visible_on_examine(mob/living/carbon/human/human, list/checked_zones)
	if(!human)
		return FALSE
	if(!checked_zones)
		checked_zones = list(BODY_ZONE_PRECISE_GROIN)
	for(var/obj/item/clothing/clothes in human.get_equipped_items(include_pockets = FALSE))
		if(clothes.armor_class < AC_MEDIUM)
			continue
		for(var/checked_zone in checked_zones)
			if(zone2covered(checked_zone, clothes.body_parts_covered))
				return FALSE
	return TRUE

/// Whether an examiner physically notices the extra genitals: self always, else adjacent + keen perception + uncovered.
/proc/extra_genitals_noticed_physically(mob/user, mob/living/carbon/human/human, list/checked_zones)
	if(!user || !human)
		return FALSE
	if(user == human)
		return TRUE
	if(get_dist(user, human) > 1)
		return FALSE
	var/mob/living/living_user = user
	if(!istype(living_user) || living_user.get_stat_level(STATKEY_PER) < EXTRA_GENITAL_PERCEPTION_MIN)
		return FALSE
	return extra_genitals_visible_on_examine(human, checked_zones)

/// Whether an examiner arcanely senses the extra genitals at min_rank: self always, else adjacent + arcane skill.
/proc/extra_genitals_sensed_arcanely(mob/user, mob/living/carbon/human/human, min_rank)
	if(!user || !human)
		return FALSE
	if(user == human)
		return TRUE
	if(get_dist(user, human) > 1)
		return FALSE
	return user.get_skill_level(/datum/skill/magic/arcane) >= min_rank

/datum/quirk/neutral/extra_genitals_base
	abstract_type = /datum/quirk/neutral/extra_genitals_base
	point_value = 0
	random_exempt = TRUE
	preview_render = FALSE

	var/datum/customizer_entry/organ/genitals/penis/extra_penis_entry
	var/datum/customizer_entry/organ/genitals/testicles/extra_testicles_entry
	var/obj/item/organ/genitals/penis/extra_penis
	var/obj/item/organ/genitals/filling_organ/testicles/extra_testicles
	var/datum/organ_dna/extra_penis_dna
	var/datum/organ_dna/extra_testicles_dna
	var/extra_genitals_committed = FALSE

/datum/quirk/neutral/extra_genitals_base/Destroy()
	clear_extra_genitals(FALSE)
	QDEL_NULL(extra_penis_entry)
	QDEL_NULL(extra_testicles_entry)
	return ..()

/datum/quirk/neutral/extra_genitals_base/is_available(datum/preferences/prefs)
	. = ..()
	if(!.)
		return FALSE
	if(!prefs?.pref_species)
		return FALSE

	var/datum/customizer_entry/organ/genitals/vagina/vagina_entry = prefs.get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/vagina)
	var/datum/customizer_entry/organ/genitals/penis/penis_entry = prefs.get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/penis)
	var/datum/customizer_entry/organ/genitals/testicles/testicles_entry = prefs.get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/testicles)

	if(!vagina_entry || vagina_entry.disabled)
		return FALSE
	if(!penis_entry || !penis_entry.disabled)
		return FALSE
	if(!testicles_entry || !testicles_entry.disabled)
		return FALSE
	return TRUE

/datum/quirk/neutral/extra_genitals_base/on_remove()
	clear_extra_genitals(TRUE)

/datum/quirk/neutral/extra_genitals_base/on_examined(mob/user, list/P, list/examine_contents)
	if(!ishuman(owner))
		return
	if(!has_active_extra_genitals())
		return
	var/mob/living/carbon/human/human_owner = owner
	if(!extra_genitals_noticed_physically(user, human_owner))
		return
	LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_BODY, span_notice("[human_owner.p_they(TRUE)] [human_owner.p_have()] something extra dangling between [human_owner.p_their()] legs."))

/datum/quirk/neutral/extra_genitals_base/proc/setup_extra_genital_entries()
	if(extra_penis_entry && extra_testicles_entry)
		return TRUE
	if(!ishuman(owner))
		return FALSE
	var/datum/preferences/prefs = owner.client?.prefs
	if(!prefs)
		return FALSE

	prefs.validate_customizer_entries()

	var/datum/customizer_entry/organ/genitals/penis/saved_penis = prefs.get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/penis)
	var/datum/customizer_entry/organ/genitals/testicles/saved_testicles = prefs.get_customizer_entry_for_entry_type(/datum/customizer_entry/organ/genitals/testicles)
	if(!saved_penis || !saved_testicles)
		return FALSE

	if(!extra_penis_entry)
		var/datum/customizer/penis_customizer = CUSTOMIZER(saved_penis.customizer_type)
		extra_penis_entry = penis_customizer.create_customizer_entry(prefs, saved_penis.customizer_choice_type, TRUE)
		copy_penis_entry(saved_penis, extra_penis_entry)

	if(!extra_testicles_entry)
		var/datum/customizer/testicles_customizer = CUSTOMIZER(saved_testicles.customizer_type)
		extra_testicles_entry = testicles_customizer.create_customizer_entry(prefs, saved_testicles.customizer_choice_type, TRUE)
		copy_testicles_entry(saved_testicles, extra_testicles_entry)

	validate_extra_genital_entries()
	return TRUE

/datum/quirk/neutral/extra_genitals_base/proc/copy_accessory_entry(datum/customizer_entry/source, datum/customizer_entry/target)
	if(!source || !target)
		return
	target.customizer_type = source.customizer_type
	target.customizer_choice_type = source.customizer_choice_type
	target.accessory_type = source.accessory_type
	target.accessory_colors = source.accessory_colors
	target.disabled = FALSE
	target.show_dropdown = FALSE

/datum/quirk/neutral/extra_genitals_base/proc/copy_penis_entry(datum/customizer_entry/organ/genitals/penis/source, datum/customizer_entry/organ/genitals/penis/target)
	copy_accessory_entry(source, target)
	target.penis_size = source.penis_size
	target.penis_length_cm = source.penis_length_cm
	target.functional = source.functional

/datum/quirk/neutral/extra_genitals_base/proc/copy_testicles_entry(datum/customizer_entry/organ/genitals/testicles/source, datum/customizer_entry/organ/genitals/testicles/target)
	copy_accessory_entry(source, target)
	target.ball_size = source.ball_size
	target.virility = source.virility

/datum/quirk/neutral/extra_genitals_base/proc/validate_extra_genital_entries()
	var/datum/preferences/prefs = owner?.client?.prefs
	if(!prefs)
		return FALSE
	if(extra_penis_entry)
		var/datum/customizer_choice/penis_choice = CUSTOMIZER_CHOICE(extra_penis_entry.customizer_choice_type)
		penis_choice.validate_entry(prefs, extra_penis_entry)
	if(extra_testicles_entry)
		var/datum/customizer_choice/testicles_choice = CUSTOMIZER_CHOICE(extra_testicles_entry.customizer_choice_type)
		testicles_choice.validate_entry(prefs, extra_testicles_entry)
	return TRUE

/datum/quirk/neutral/extra_genitals_base/proc/has_active_extra_genitals()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	return extra_penis && !QDELETED(extra_penis) && human_owner.getorganslot(ORGAN_SLOT_PENIS) == extra_penis && extra_testicles && !QDELETED(extra_testicles) && human_owner.getorganslot(ORGAN_SLOT_TESTICLES) == extra_testicles

/datum/quirk/neutral/extra_genitals_base/proc/can_receive_extra_genitals(show_feedback = FALSE)
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	if(!human_owner.getorganslot(ORGAN_SLOT_VAGINA))
		if(show_feedback)
			to_chat(human_owner, span_warning("I need a vagina for this quirk to work."))
		return FALSE

	var/obj/item/organ/current_penis = human_owner.getorganslot(ORGAN_SLOT_PENIS)
	if(current_penis && current_penis != extra_penis)
		if(show_feedback)
			to_chat(human_owner, span_warning("I already have a penis."))
		return FALSE

	var/obj/item/organ/current_testicles = human_owner.getorganslot(ORGAN_SLOT_TESTICLES)
	if(current_testicles && current_testicles != extra_testicles)
		if(show_feedback)
			to_chat(human_owner, span_warning("I already have testicles."))
		return FALSE

	return TRUE

/datum/quirk/neutral/extra_genitals_base/proc/create_extra_organ_from_entry(datum/customizer_entry/entry, datum/preferences/prefs)
	if(!ishuman(owner) || !entry || !prefs)
		return null
	var/mob/living/carbon/human/human_owner = owner
	var/datum/customizer_choice/organ/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
	var/datum/organ_dna/organ_dna = choice.create_organ_dna(entry, prefs)
	if(!organ_dna?.can_create_organ())
		return null

	var/obj/item/organ/new_organ = organ_dna.create_organ(species = human_owner.dna?.species)
	if(!new_organ)
		return null

	new_organ.Insert(human_owner, TRUE, FALSE)
	if(human_owner.dna)
		human_owner.dna.organ_dna[choice.get_organ_slot(new_organ, entry)] = organ_dna

	return list(
		"organ" = new_organ,
		"dna" = organ_dna,
	)

/datum/quirk/neutral/extra_genitals_base/proc/apply_extra_genitals(mob/user)
	if(extra_genitals_committed && is_extra_genitals_one_time_choice())
		to_chat(user || owner, span_warning("This extra genital set is already chosen for the round."))
		return FALSE
	if(!setup_extra_genital_entries())
		to_chat(user || owner, span_warning("The extra genital customizer could not be prepared."))
		return FALSE
	if(!can_receive_extra_genitals(TRUE))
		return FALSE

	clear_extra_genitals(FALSE)

	var/datum/preferences/prefs = owner.client?.prefs
	var/list/penis_result = create_extra_organ_from_entry(extra_penis_entry, prefs)
	var/list/testicles_result = create_extra_organ_from_entry(extra_testicles_entry, prefs)

	if(!penis_result || !testicles_result)
		clear_extra_genitals(FALSE)
		to_chat(user || owner, span_warning("The extra genital set could not be created."))
		return FALSE

	extra_penis = penis_result["organ"]
	extra_penis_dna = penis_result["dna"]
	extra_testicles = testicles_result["organ"]
	extra_testicles_dna = testicles_result["dna"]

	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.update_body_parts(TRUE)

	if(is_extra_genitals_one_time_choice())
		extra_genitals_committed = TRUE

	to_chat(user || owner, span_notice("The extra genital set is now present."))
	return TRUE

/datum/quirk/neutral/extra_genitals_base/proc/clear_extra_genitals(show_feedback = FALSE)
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	var/removed_any = FALSE

	if(extra_penis && !QDELETED(extra_penis))
		if(human_owner.getorganslot(ORGAN_SLOT_PENIS) == extra_penis)
			extra_penis.Remove(human_owner, TRUE, FALSE)
		qdel(extra_penis)
		removed_any = TRUE
	extra_penis = null

	if(extra_testicles && !QDELETED(extra_testicles))
		if(human_owner.getorganslot(ORGAN_SLOT_TESTICLES) == extra_testicles)
			extra_testicles.Remove(human_owner, TRUE, FALSE)
		qdel(extra_testicles)
		removed_any = TRUE
	extra_testicles = null

	if(human_owner.dna)
		if(human_owner.dna.organ_dna[ORGAN_SLOT_PENIS] == extra_penis_dna)
			human_owner.dna.organ_dna.Remove(ORGAN_SLOT_PENIS)
		if(human_owner.dna.organ_dna[ORGAN_SLOT_TESTICLES] == extra_testicles_dna)
			human_owner.dna.organ_dna.Remove(ORGAN_SLOT_TESTICLES)

	extra_penis_dna = null
	extra_testicles_dna = null

	if(removed_any)
		human_owner.update_body_parts(TRUE)
		if(show_feedback)
			to_chat(human_owner, span_notice("The extra genital set is gone."))
	return removed_any

/datum/quirk/neutral/extra_genitals_base/proc/get_entry_for_part(part)
	switch(part)
		if("penis")
			return extra_penis_entry
		if("testicles")
			return extra_testicles_entry
	return null

/datum/quirk/neutral/extra_genitals_base/proc/set_entry_for_part(part, datum/customizer_entry/new_entry)
	switch(part)
		if("penis")
			extra_penis_entry = new_entry
		if("testicles")
			extra_testicles_entry = new_entry

/datum/quirk/neutral/extra_genitals_base/proc/change_extra_genital_choice(mob/user, part)
	var/datum/customizer_entry/current_entry = get_entry_for_part(part)
	if(!current_entry)
		return FALSE
	var/datum/preferences/prefs = owner.client?.prefs
	if(!prefs)
		return FALSE

	var/datum/customizer/customizer = CUSTOMIZER(current_entry.customizer_type)
	if(length(customizer.customizer_choices) <= 1)
		return FALSE

	var/list/choice_list = list()
	var/choice_number = 0
	for(var/choice_type in customizer.customizer_choices)
		choice_number++
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(choice_type)
		var/choice_label = choice.name
		if(choice_label in choice_list)
			choice_label = "[choice.name] ([choice_number])"
		choice_list[choice_label] = choice_type

	var/chosen_label = browser_input_list(user, "Choose your [part] type:", "Extra Genitals", choice_list)
	if(!chosen_label)
		return FALSE

	var/chosen_type = choice_list[chosen_label]
	var/datum/customizer_entry/new_entry = customizer.create_customizer_entry(prefs, chosen_type, TRUE)
	if(part == "penis")
		var/datum/customizer_entry/organ/genitals/penis/old_penis = current_entry
		var/datum/customizer_entry/organ/genitals/penis/new_penis = new_entry
		new_penis.penis_size = old_penis.penis_size
		new_penis.penis_length_cm = old_penis.penis_length_cm
		new_penis.functional = old_penis.functional
	else if(part == "testicles")
		var/datum/customizer_entry/organ/genitals/testicles/old_testicles = current_entry
		var/datum/customizer_entry/organ/genitals/testicles/new_testicles = new_entry
		new_testicles.ball_size = old_testicles.ball_size
		new_testicles.virility = old_testicles.virility

	set_entry_for_part(part, new_entry)
	qdel(current_entry)
	validate_extra_genital_entries()
	return TRUE

/datum/quirk/neutral/extra_genitals_base/Topic(href, href_list)
	. = ..()
	if(!owner || usr != owner)
		return TRUE
	var/mob/user = usr
	if(!setup_extra_genital_entries())
		to_chat(user, span_warning("The extra genital customizer could not be prepared."))
		return TRUE

	switch(href_list["extra_genital_action"])
		if("apply")
			var/applied = apply_extra_genitals(user)
			if(applied && should_close_extra_genital_menu_after_apply())
				close_extra_genital_menu(user)
				return TRUE
			open_extra_genital_menu(user)
			return TRUE
		if("remove")
			if(!can_manually_remove_extra_genitals())
				to_chat(user, span_warning("This extra genital set is permanent for the round."))
				close_extra_genital_menu(user)
				return TRUE
			clear_extra_genitals(TRUE)
			open_extra_genital_menu(user)
			return TRUE

	var/part = href_list["extra_genital_part"]
	if(!part)
		return TRUE

	var/datum/customizer_entry/entry = get_entry_for_part(part)
	if(!entry)
		return TRUE

	if(href_list["extra_genital_task"] == "change_choice")
		change_extra_genital_choice(user, part)
	else if(href_list["customizer_task"])
		var/datum/preferences/prefs = owner.client?.prefs
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		choice.handle_topic(user, href_list, prefs, entry, entry.customizer_type)
		validate_extra_genital_entries()

	open_extra_genital_menu(user)
	return TRUE

/datum/quirk/neutral/extra_genitals_base/proc/open_extra_genital_menu(mob/user)
	if(!user)
		user = owner
	if(!user || !user.client)
		return FALSE
	if(!setup_extra_genital_entries())
		to_chat(user, span_warning("The extra genital customizer could not be prepared."))
		return FALSE

	var/datum/browser/popup = new(user, "extra_genital_customizer", "Extra Genitals", 720, 680, src)
	popup.set_content(build_extra_genital_menu())
	popup.open(FALSE)
	return TRUE

/datum/quirk/neutral/extra_genitals_base/proc/close_extra_genital_menu(mob/user)
	if(!user)
		user = owner
	if(user)
		user << browse(null, "window=extra_genital_customizer")

/datum/quirk/neutral/extra_genitals_base/proc/build_extra_genital_menu()
	var/list/dat = list()
	var/active = has_active_extra_genitals()
	var/apply_label = get_apply_action_label()
	var/remove_label = get_remove_action_label()
	var/menu_note = get_extra_genital_menu_note()

	dat += {"
		<style>
			body {
				background: #27241f;
				color: #e8dfbd;
				font-family: Georgia, 'Times New Roman', serif;
				font-size: 14px;
			}
			a {
				color: #efe6b8;
				text-decoration: none;
				font-weight: bold;
			}
			.extra-window {
				background: #2f2b25;
				border: 2px solid #171411;
				padding: 12px;
			}
			.extra-header {
				display: flex;
				justify-content: space-between;
				align-items: center;
				border-bottom: 3px solid #1e1a17;
				margin-bottom: 12px;
				padding-bottom: 8px;
			}
			.extra-title {
				font-size: 25px;
				font-weight: bold;
				color: #efe6b8;
				text-transform: uppercase;
			}
			.extra-status {
				background: #1f1b18;
				border: 1px solid #8a765f;
				padding: 5px 10px;
				text-transform: uppercase;
				color: [active ? "#bed18a" : "#d6caa6"];
			}
			.extra-grid {
				display: grid;
				grid-template-columns: 1fr 1fr;
				gap: 10px;
			}
			.extra-card {
				background: #806c5c;
				border: 2px solid #1d1915;
				color: #211b17;
				padding: 10px;
				min-height: 430px;
			}
			.extra-card h2 {
				margin: 0 0 8px 0;
				border-bottom: 3px solid #211b17;
				font-size: 22px;
				text-transform: uppercase;
			}
			.extra-choice {
				display: block;
				background: #5f4d41;
				color: #efe6b8;
				padding: 7px 9px;
				margin-bottom: 10px;
				border: 1px solid #2a231f;
			}
			.extra-controls {
				line-height: 1.6;
			}
			.extra-controls a {
				background: #2c2721;
				border: 1px solid #6a5b4b;
				color: #efe6b8;
				display: inline-block;
				margin: 2px;
				padding: 2px 7px;
			}
			.accessory-box {
				background: #6f5a4c;
				border: 1px solid #2a231f;
				margin: 8px 0;
				padding: 8px;
			}
			.accessory-frame {
				display: flex;
				align-items: center;
				gap: 8px;
			}
			.accessory-preview {
				background: #050403;
				border: 2px solid #211b17;
				width: 76px;
				height: 76px;
				display: flex;
				align-items: center;
				justify-content: center;
			}
			.accessory-preview img {
				width: 64px;
				height: 64px;
				object-fit: contain;
				image-rendering: pixelated;
			}
			.accessory-controls {
				flex: 1;
			}
			.accessory-arrow {
				min-width: 16px;
				text-align: center;
			}
			.accessory-dropdown {
				display: grid;
				grid-template-columns: repeat(2, 1fr);
				gap: 6px;
				margin-top: 8px;
			}
			.accessory-grid-card {
				background: #5f4d41;
				border: 1px solid #211b17;
				color: #efe6b8;
				padding: 5px;
				text-align: center;
			}
			.accessory-grid-card.selected {
				outline: 2px solid #efe6b8;
			}
			.accessory-grid-card img {
				width: 52px;
				height: 52px;
				object-fit: contain;
				image-rendering: pixelated;
			}
			.accessory-grid-label {
				font-size: 11px;
			}
			.color_holder_box {
				display: inline-block;
				width: 26px;
				height: 12px;
				border: 1px solid #171411;
				vertical-align: middle;
			}
			.extra-actions {
				border-top: 3px solid #1e1a17;
				display: flex;
				gap: 8px;
				justify-content: flex-end;
				margin-top: 12px;
				padding-top: 10px;
			}
			.extra-actions a {
				background: #2c2721;
				border: 2px solid #8a765f;
				color: #efe6b8;
				font-size: 16px;
				padding: 6px 16px;
				text-transform: uppercase;
			}
			.extra-actions a.danger {
				border-color: #a37161;
				color: #f0c5b8;
			}
			.extra-note {
				color: #d6caa6;
				margin: 8px 0 12px 0;
			}
			.extra-note.warning {
				border-left: 3px solid #b69a52;
				color: #efe6b8;
				padding-left: 8px;
			}
		</style>
	"}

	dat += "<div class='extra-window'>"
	dat += "<div class='extra-header'>"
	dat += "<div class='extra-title'>Extra Genitals</div>"
	dat += "<div class='extra-status'>[active ? "Present" : "Not Present"]</div>"
	dat += "</div>"
	dat += "<div class='extra-note [is_extra_genitals_one_time_choice() ? "warning" : ""]'>[menu_note]</div>"
	dat += "<div class='extra-grid'>"
	dat += render_extra_genital_entry("penis", "Penis", extra_penis_entry)
	dat += render_extra_genital_entry("testicles", "Testicles", extra_testicles_entry)
	dat += "</div>"
	dat += "<div class='extra-actions'>"
	if(active)
		if(!extra_genitals_committed || !is_extra_genitals_one_time_choice())
			dat += "<a href='byond://?src=[REF(src)];extra_genital_action=apply'>Update Set</a>"
		if(can_manually_remove_extra_genitals())
			dat += "<a class='danger' href='byond://?src=[REF(src)];extra_genital_action=remove'>[remove_label]</a>"
	else
		dat += "<a href='byond://?src=[REF(src)];extra_genital_action=apply'>[apply_label]</a>"
	dat += "</div>"
	dat += "</div>"

	return dat.Join()

/datum/quirk/neutral/extra_genitals_base/proc/get_apply_action_label()
	return "Receive Set"

/datum/quirk/neutral/extra_genitals_base/proc/get_remove_action_label()
	return "Remove Set"

/datum/quirk/neutral/extra_genitals_base/proc/get_extra_genital_menu_note()
	return "Customize the extra penis and testicles, then apply the set when ready."

/datum/quirk/neutral/extra_genitals_base/proc/is_extra_genitals_one_time_choice()
	return FALSE

/datum/quirk/neutral/extra_genitals_base/proc/should_close_extra_genital_menu_after_apply()
	return FALSE

/datum/quirk/neutral/extra_genitals_base/proc/can_manually_remove_extra_genitals()
	return TRUE

/datum/quirk/neutral/extra_genitals_base/proc/render_extra_genital_entry(part, title, datum/customizer_entry/entry)
	if(!entry)
		return "<div class='extra-card'><h2>[title]</h2><div>Unavailable</div></div>"

	var/datum/preferences/prefs = owner.client?.prefs
	var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
	var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
	var/list/dat = list()

	dat += "<div class='extra-card'>"
	dat += "<h2>[title]</h2>"
	if(length(customizer.customizer_choices) > 1)
		dat += "<a class='extra-choice' href='byond://?src=[REF(src)];extra_genital_part=[part];extra_genital_task=change_choice'>[choice.name]</a>"
	else
		dat += "<div class='extra-choice'>[choice.name]</div>"

	var/list/choice_controls = choice.show_pref_choices(prefs, entry, entry.customizer_type)
	if(choice_controls)
		var/controls = choice_controls.Join()
		controls = replacetext(controls, "?_src_=prefs;task=change_customizer;customizer=[entry.customizer_type];", "?src=[REF(src)];extra_genital_part=[part];")
		dat += "<div class='extra-controls'>[controls]</div>"
	dat += "</div>"

	return dat.Join()

/datum/quirk/neutral/extra_genitals
	name = "Extra Genitals"
	desc = "I can use the full genital customizer list, mixing masculine and feminine features freely."
	incompatible_quirks = list(/datum/quirk/positive/summonable_extra_genitals)

/datum/quirk/neutral/extra_genitals/is_available(datum/preferences/prefs)
	. = ..()
	if(!.)
		return FALSE
	if(!prefs)
		return TRUE
	return prefs.has_both_gendered_genital_sets()

/datum/quirk/neutral/extra_genitals/on_examined(mob/user, list/P, list/examine_contents)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	var/has_masculine_features = human_owner.getorganslot(ORGAN_SLOT_PENIS) || human_owner.getorganslot(ORGAN_SLOT_TESTICLES)
	var/has_feminine_features = human_owner.getorganslot(ORGAN_SLOT_BREASTS) || human_owner.getorganslot(ORGAN_SLOT_VAGINA)

	if(human_owner.gender == FEMALE && has_masculine_features)
		if(extra_genitals_noticed_physically(user, human_owner, list(BODY_ZONE_PRECISE_GROIN)))
			LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_BODY, span_notice("[human_owner.p_they(TRUE)] [human_owner.p_have()] something extra dangling between [human_owner.p_their()] legs."))
		return

	if(human_owner.gender == MALE && has_feminine_features)
		if(extra_genitals_noticed_physically(user, human_owner, list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)))
			LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_BODY, span_notice("[human_owner.p_they(TRUE)] [human_owner.p_have()] a second, womanly set of intimate features."))


/datum/quirk/positive/summonable_extra_genitals
	parent_type = /datum/quirk/neutral/extra_genitals_base
	name = "Summonable Extra Genitals"
	desc = "I can summon, customize, and dismiss an extra penis and testicles. Requires a vagina and no existing penis or testicles."
	incompatible_quirks = list(/datum/quirk/neutral/extra_genitals)
	point_value = -4

/datum/quirk/positive/summonable_extra_genitals/on_spawn()
	. = ..()
	if(!ishuman(owner))
		return
	owner.add_spell(/datum/action/cooldown/spell/undirected/summon_extra_genitals, source = src)

/datum/quirk/positive/summonable_extra_genitals/on_remove()
	if(owner)
		owner.remove_spells(source = src)
	return ..()

/datum/quirk/positive/summonable_extra_genitals/get_apply_action_label()
	return "Summon Set"

/datum/quirk/positive/summonable_extra_genitals/get_remove_action_label()
	return "Dismiss Set"

/datum/quirk/positive/summonable_extra_genitals/on_examined(mob/user, list/P, list/examine_contents)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	if(has_active_extra_genitals())
		if(extra_genitals_noticed_physically(user, human_owner))
			LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_BODY, span_notice("[human_owner.p_they(TRUE)] [human_owner.p_have()] summoned something extra dangling between [human_owner.p_their()] legs."))
		else if(extra_genitals_sensed_arcanely(user, human_owner, EXTRA_GENITAL_ARCANE_HIDDEN))
			LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_BODY, span_notice("[human_owner.p_they(TRUE)] [human_owner.p_have()] the telltale sign of something extra, though it is hidden beneath [human_owner.p_their()] clothing."))
		return

	if(extra_genitals_sensed_arcanely(user, human_owner, EXTRA_GENITAL_ARCANE_LATENT))
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_BODY, span_notice("[human_owner.p_they(TRUE)] [human_owner.p_have()] the faint sign of something extra waiting beneath [human_owner.p_their()] skin."))

/datum/action/cooldown/spell/undirected/summon_extra_genitals
	name = "Extra Genitals"
	desc = "Open the extra genital customization menu."
	button_icon_state = "love"
	has_visual_effects = FALSE
	charge_required = FALSE
	cooldown_time = 5 SECONDS
	spell_cost = 0
	sound = null

/datum/action/cooldown/spell/undirected/summon_extra_genitals/cast(atom/cast_on)
	. = ..()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	var/datum/quirk/neutral/extra_genitals_base/extra_quirk = human_owner.get_quirk(/datum/quirk/positive/summonable_extra_genitals)
	if(!extra_quirk)
		to_chat(human_owner, span_warning("The extra genital quirk is missing."))
		return FALSE
	extra_quirk.open_extra_genital_menu(human_owner)
	return TRUE

#undef EXTRA_GENITAL_PERCEPTION_MIN
#undef EXTRA_GENITAL_ARCANE_HIDDEN
#undef EXTRA_GENITAL_ARCANE_LATENT
