// The ooze editor uses the temporary Preferences sandbox from succubus disguises.
// Its commit is limited to physical appearance; the mob's identity and species stay intact.
/mob/living/carbon/human
	var/datum/preferences/ooze_body/active_ooze_editor

/datum/action/cooldown/spell/undirected/ooze_reshape
	name = "Reshape Body"
	desc = "Reform my body without changing who I am."
	has_visual_effects = FALSE
	antimagic_flags = NONE
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	associated_skill = null
	charge_required = FALSE
	cooldown_time = 0

/datum/action/cooldown/spell/undirected/ooze_reshape/cast(mob/living/cast_on)
	. = ..()
	var/mob/living/carbon/human/body = cast_on
	if(!istype(body) || !istype(body.dna?.species, /datum/species/ooze) || body.stat != CONSCIOUS || !body.client)
		return
	if(!body.active_ooze_editor || body.active_ooze_editor.parent != body.client)
		QDEL_NULL(body.active_ooze_editor)
		body.active_ooze_editor = new(body.client, body.mind, 1)
	body.active_ooze_editor.ui_interact(body)

/datum/preferences/ooze_body
	parent_type = /datum/preferences/succubus_disguise
	var/original_slot

/datum/preferences/ooze_body/New(client/editor_client, datum/mind/ooze_mind, slot)
	. = ..(editor_client, ooze_mind, 1)
	original_slot = editor_client?.prefs?.current_slot || default_slot
	var/mob/living/carbon/human/body = ooze_mind?.current
	if(!istype(body) || !istype(body.dna?.species, /datum/species/ooze))
		return
	set_species_preference(/datum/species/ooze)
	write_preference(/datum/preference/choiced/gender, body.gender)
	features = body.dna.features.Copy()
	body_markings = deepCopyList(body.dna.body_markings)
	validate_customizer_entries()
	character_setup_preferences_initial_tab = "appearance"

/datum/preferences/ooze_body/Destroy()
	var/datum/mind/ooze_mind = owner_mind_ref?.resolve()
	var/mob/living/carbon/human/body = ooze_mind?.current
	if(istype(body) && body.active_ooze_editor == src)
		body.active_ooze_editor = null
	return ..()

/datum/preferences/ooze_body/get_editor_body(mob/user)
	var/datum/mind/ooze_mind = owner_mind_ref?.resolve()
	var/mob/living/carbon/human/body = ooze_mind?.current
	if(!istype(body) || !istype(body.dna?.species, /datum/species/ooze) || body.stat != CONSCIOUS || !body.client)
		return null
	if(body.active_ooze_editor != src || body.client != parent || (user && user != body))
		return null
	return body

/datum/preferences/ooze_body/is_allowed_species(species_id)
	return species_id == SPEC_ID_OOZE

/datum/preferences/ooze_body/is_allowed_disguise_action(action, list/params)
	if(action == "ooze_commit" || action == "ooze_cancel" || action == "ooze_reset")
		return TRUE
	if(action == "disguise_commit" || action == "disguise_cancel" || action == "disguise_select_slot" || action == "set_age")
		return FALSE
	if(action == "pref" && (params?["preference"] in list("name", "pronouns", "character_setup_select_species", "character_setup_select_ancestry", "character_setup_taur_body", "character_setup_taur_color", "randomiseappearanceprefs")))
		return FALSE
	return ..()

/datum/preferences/ooze_body/get_commit_block_reason(mob/user)
	var/mob/living/carbon/human/body = get_editor_body(user)
	if(!body)
		return "My body can no longer be reshaped."
	if(pref_species?.id != SPEC_ID_OOZE)
		return "The draft no longer describes an ooze."
	return null

/datum/preferences/ooze_body/commit_disguise(mob/user)
	var/mob/living/carbon/human/body = get_editor_body(user)
	if(!body || get_commit_block_reason(user))
		return FALSE
	var/mob/living/carbon/human/draft = new(null)
	apply_prefs_to(draft, TRUE, TRUE)
	if(!istype(draft.dna?.species, /datum/species/ooze) || !get_editor_body(user))
		qdel(draft)
		return FALSE

	// Copy only outward anatomy. Never replace the live DNA datum, species, name,
	// age, mind, wounds, or vital organs from the temporary preview body.
	body.dna.features = draft.dna.features.Copy()
	body.dna.body_markings = deepCopyList(draft.dna.body_markings)
	body.skin_tone = draft.skin_tone
	var/old_gender = body.gender
	body.gender = draft.gender
	if(body.gender != old_gender)
		body.dna.species.on_gender_update(body, old_gender)
	body.voice_type = draft.voice_type
	body.voice_color = read_preference(/datum/preference/color/voice_color)
	// updateappearance() reads gender from DNA, so keep its block in step with the new body.
	var/gender_block = body.gender == FEMALE ? G_FEMALE : G_MALE
	body.dna.unique_identity = setblock(body.dna.unique_identity, DNA_GENDER_BLOCK, construct_block(gender_block, 3))
	body.set_hair_color(draft.get_hair_color(), FALSE)
	body.set_facial_hair_color(draft.get_facial_hair_color(), FALSE)
	body.set_eye_color(draft.get_eye_color(RIGHT_SIDE), draft.get_eye_color(LEFT_SIDE), FALSE)
	body.remove_all_bodypart_features()
	for(var/feature_type in body.dna.species.bodypart_features)
		var/datum/bodypart_feature/feature = new feature_type()
		body.add_bodypart_feature(feature)
	apply_customizers_to_character(body)
	apply_markings_to_body_parts(body.dna.body_markings, body)

	var/list/draft_organs = get_organ_dna_list()
	var/list/cosmetic_slots = list(ORGAN_SLOT_EYES, ORGAN_SLOT_PENIS, ORGAN_SLOT_TESTICLES, ORGAN_SLOT_BREASTS, ORGAN_SLOT_WOMB, ORGAN_SLOT_VAGINA, ORGAN_SLOT_BELLY, ORGAN_SLOT_BUTT, ORGAN_SLOT_TAIL, ORGAN_SLOT_TAIL_FEATURE, ORGAN_SLOT_SNOUT, ORGAN_SLOT_EARS, ORGAN_SLOT_HORNS, ORGAN_SLOT_FRILLS, ORGAN_SLOT_WINGS, ORGAN_SLOT_NECK_FEATURE)
	for(var/slot in cosmetic_slots)
		var/datum/organ_dna/organ_dna = draft_organs[slot]
		var/list/old_organs = body.getorganslotlist(slot)
		if(slot == ORGAN_SLOT_EYES && !length(old_organs))
			continue
		if(!organ_dna?.can_create_organ())
			for(var/obj/item/organ/old_organ as anything in old_organs)
				var/list/stored_items = old_organ.extract_body_storage_contents_for_regeneration()
				old_organ.Remove(body, TRUE)
				qdel(old_organ)
				release_body_storage_transfer_items(stored_items, body.drop_location())
			QDEL_NULL(body.dna.organ_dna[slot])
			var/datum/organ_dna/disabled_dna = new
			disabled_dna.disabled = TRUE
			body.dna.organ_dna[slot] = disabled_dna
			continue
		if(length(old_organs))
			for(var/obj/item/organ/old_organ as anything in old_organs)
				if(old_organ.type == organ_dna.organ_type)
					organ_dna.imprint_organ(old_organ, body.dna.species)
					continue
				var/list/stored_items = old_organ.extract_body_storage_contents_for_regeneration()
				var/old_damage = old_organ.damage
				var/old_side = old_organ.side
				old_organ.Remove(body, TRUE)
				qdel(old_organ)
				var/obj/item/organ/replacement = organ_dna.create_organ(species = body.dna.species)
				if(replacement.side != old_side)
					replacement.switch_side(old_side)
				replacement.setOrganDamage(old_damage)
				replacement.Insert(body, TRUE, FALSE)
				stored_items = replacement.restore_body_storage_contents_after_regeneration(stored_items)
				release_body_storage_transfer_items(stored_items, body.drop_location())
		else
			var/obj/item/organ/new_organ = organ_dna.create_organ(species = body.dna.species)
			new_organ.Insert(body, TRUE, FALSE)
			if(slot in PAIRED_ORGAN_SLOTS)
				var/obj/item/organ/paired_organ = organ_dna.create_organ(species = body.dna.species)
				paired_organ.switch_side(new_organ.side == RIGHT_SIDE ? LEFT_SIDE : RIGHT_SIDE)
				paired_organ.Insert(body, TRUE, FALSE)
		QDEL_NULL(body.dna.organ_dna[slot])
		body.dna.organ_dna[slot] = organ_dna
		draft_organs -= slot
	for(var/slot in draft_organs)
		qdel(draft_organs[slot])
	qdel(draft)
	body.update_organ_colors()
	body.updateappearance(mutcolor_update = TRUE)
	body.update_body_parts(TRUE)
	body.name = body.get_visible_name()
	to_chat(body, span_notice("My body settles into its new shape."))
	update_menu_data(body)
	return TRUE

/datum/preferences/ooze_body/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action == "ooze_reset")
		var/mob/living/carbon/human/body = get_editor_body(ui?.user || usr)
		if(!body)
			return FALSE
		if(!path || !fexists(path))
			to_chat(body, span_warning("I cannot find a saved body for this character slot."))
			return FALSE
		var/savefile/saved_character = new /savefile(path)
		saved_character.cd = "/character[original_slot]"
		if(!(saved_character["species"] in list(SPEC_ID_OOZE, "slime")))
			to_chat(body, span_warning("I cannot find a saved ooze body for this character slot."))
			return FALSE
		// load_character() writes a changed default slot back to disk; this is only a read.
		default_slot = original_slot
		if(!load_character(original_slot) || pref_species?.id != SPEC_ID_OOZE)
			to_chat(body, span_warning("I cannot find a saved ooze body for this character slot."))
			return FALSE
		return commit_disguise(body)
	if(action == "ooze_cancel")
		if(!get_editor_body(ui?.user || usr))
			return FALSE
		ui?.close(FALSE)
		qdel(src)
		return TRUE
	if(action == "ooze_commit")
		return commit_disguise(ui?.user || usr)
	return ..()

/datum/preferences/ooze_body/ui_static_data(mob/user)
	var/list/data = ..()
	data["ooze_mode"] = TRUE
	return data

/datum/preferences/ooze_body/ui_data(mob/user)
	var/list/data = ..()
	var/mob/living/carbon/human/body = get_editor_body(user)
	data["ooze_mode"] = TRUE
	data["real_name"] = body?.real_name
	data["commit_available"] = !get_commit_block_reason(user)
	data["commit_reason"] = get_commit_block_reason(user) || "Ready to reshape."
	return data

/datum/preferences/ooze_body/ui_interact(mob/user, datum/tgui/ui)
	if(!get_editor_body(user))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CharacterCreator", "Reshape Body", 1180, 800)
		ui.set_autoupdate(FALSE)
		ui.open()
	character_setup_ensure_view(user, ui)

