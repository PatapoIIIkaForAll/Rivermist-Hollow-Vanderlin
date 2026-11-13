/// Account-wide champion identity, separate from the ordinary Lesser Gnoll character slot.
/datum/preference/list_type/gnoll_customization
	savefile_key = "gnoll_customization"
	savefile_identifier = PREF_PLAYER
	category = "gnoll"
	should_apply = FALSE
	var/static/list/appearance_fields = list(
		"pronouns" = "Pronouns", "gender" = "Body type", "pelt" = "Pelt",
		"height" = "Height", "build" = "Build", "fur" = "Coat", "voice" = "Voice",
		"muzzle" = "Muzzle", "expression" = "Expression",
		"penis" = "Penis", "vagina" = "Vagina", "breasts" = "Breasts",
	)
	// Native field datums supply validation and application, including existing image-host rules.
	var/static/list/profile_fields = list(
		"flavortext" = /datum/preference/text/flavortext,
		"nsfwflavortext" = /datum/preference/text/nsfwflavortext,
		"ooc_notes" = /datum/preference/text/ooc_notes,
		"erpprefs_flavor" = /datum/preference/text/erpprefs_flavor,
		"headshot_link" = /datum/preference/text/headshot_link,
		"nsfw_headshot_link" = /datum/preference/text/nsfw_headshot_link,
		"song_link" = /datum/preference/text/song_link,
		"song_title" = /datum/preference/text/song_title,
		"song_artist" = /datum/preference/text/song_artist,
		"img_gallery" = /datum/preference/list_type/profile_gallery/images,
		"nsfw_img_gallery" = /datum/preference/list_type/profile_gallery/nsfw_images,
	)

/datum/preferences
	var/gnoll_customization_prompt = FALSE

/client/verb/customize_gnoll()
	set name = "Gnoll Customization"
	set category = "Preferences"
	var/datum/preference/list_type/gnoll_customization/customization = GLOB.preference_entries[/datum/preference/list_type/gnoll_customization]
	customization?.handle_link(prefs, mob)

/proc/random_gnoll_champion_name()
	return "[pick("Ash", "Briar", "Bracken", "Cinder", "Dusk", "Flint", "Moss", "Storm")] [pick("Fang", "Mane", "Prowler", "Hunter", "Runner", "Watcher")]"

/datum/preference/list_type/gnoll_customization/create_default_value(datum/preferences/prefs)
	var/list/profile = list(
		"name" = random_gnoll_champion_name(), "pronouns" = HE_HIM, "gender" = MALE,
		"pelt" = "darkpelt", "voice_color" = "a0a0a0",
		"height" = /datum/mob_descriptor/height/moderate,
		"build" = /datum/mob_descriptor/body/muscular,
		"fur" = /datum/mob_descriptor/fur/coarse,
		"voice" = /datum/mob_descriptor/voice/growly,
		"muzzle" = /datum/mob_descriptor/face/gnoll/long_muzzle,
		"expression" = /datum/mob_descriptor/face_exp/gnoll/alert,
		"penis" = "inherit", "vagina" = "inherit", "breasts" = "inherit",
	)
	for(var/field in profile_fields)
		var/datum/preference/entry = GLOB.preference_entries[profile_fields[field]]
		profile[field] = entry.create_default_value(prefs)
	return profile

/datum/preference/list_type/gnoll_customization/proc/get_options(field)
	var/descriptor_root
	switch(field)
		if("pronouns")
			return list(HE_HIM = HE_HIM, SHE_HER = SHE_HER, THEY_THEM = THEY_THEM, IT_ITS = IT_ITS)
		if("gender")
			return list("Male" = MALE, "Female" = FEMALE)
		if("pelt")
			return list("Firepelt" = "firepelt", "Rotpelt" = "rotpelt", "Whitepelt" = "whitepelt", "Bloodpelt" = "bloodpelt", "Nightpelt" = "nightpelt", "Darkpelt" = "darkpelt")
		if("penis", "vagina", "breasts")
			return list("Use character anatomy" = "inherit", "Present" = TRUE, "Absent" = FALSE)
		if("height")
			descriptor_root = /datum/mob_descriptor/height
		if("build")
			descriptor_root = /datum/mob_descriptor/body
		if("fur")
			descriptor_root = /datum/mob_descriptor/fur
		if("voice")
			descriptor_root = /datum/mob_descriptor/voice
		if("muzzle")
			descriptor_root = /datum/mob_descriptor/face/gnoll
		if("expression")
			descriptor_root = /datum/mob_descriptor/face_exp/gnoll
	if(!descriptor_root)
		return null
	var/list/options = list()
	for(var/descriptor_type in subtypesof(descriptor_root))
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(descriptor_type)
		// Gnoll profiles carry no player-written text.
		if(descriptor && !descriptor.custom_index)
			options[descriptor.name] = descriptor_type
	return options

/datum/preference/list_type/gnoll_customization/deserialize(list/input, datum/preferences/prefs)
	var/list/profile = create_default_value(prefs)
	if(!islist(input))
		return profile
	profile["name"] = reject_bad_name(input["name"]) || profile["name"]
	profile["voice_color"] = sanitize_hexcolor(input["voice_color"], include_crunch = FALSE)
	for(var/field in appearance_fields)
		var/list/options = get_options(field)
		for(var/label in options)
			if(options[label] == input[field])
				profile[field] = input[field]
				break
	for(var/field in profile_fields)
		var/datum/preference/entry = GLOB.preference_entries[profile_fields[field]]
		var/value = entry.deserialize(input[field], prefs)
		if(entry.is_valid(value, prefs))
			profile[field] = value
	return profile

/datum/preference/list_type/gnoll_customization/serialize(list/input)
	return deepCopyList(input)

/datum/preference/list_type/gnoll_customization/handle_link(datum/preferences/prefs, mob/user)
	if(!prefs || user?.client?.prefs != prefs)
		return
	var/list/profile = prefs.read_preference(type)
	var/list/page = list("<h2>Gorellik's Gnoll Champions</h2><p>Saved separately from your ordinary character. These choices apply when you spawn or become a champion.</p>")
	var/datum/antagonist/gnoll/champion = get_gnoll_antag(user)
	if(champion && world.time < champion.customization_until)
		page += "<p><b>Changes also reshape your current champion for [DisplayTimeText(champion.customization_until - world.time)].</b></p>"
	page += "<b>Name:</b> [html_encode(profile["name"])] <a href='byond://?src=[REF(src)];field=name'>Change</a> · <a href='byond://?src=[REF(src)];field=random_name'>Randomize</a><br>"
	page += "<b>Voice color:</b> <a href='byond://?src=[REF(src)];field=voice_color'>[html_encode(profile["voice_color"])]</a><br>"
	for(var/field in appearance_fields)
		var/list/options = get_options(field)
		var/current_label
		for(var/label in options)
			if(options[label] == profile[field])
				current_label = label
		page += "<b>[appearance_fields[field]]:</b> <a href='byond://?src=[REF(src)];field=[field]'>[html_encode(current_label)]</a><br>"
	page += "<h3>Pelt previews</h3><table><tr>"
	var/list/pelts = get_options("pelt")
	for(var/label in pelts)
		var/icon/pelt_icon = icon('modular_rmh/icons/mob/monster/gnoll.dmi', pelts[label], SOUTH)
		page += "<td align='center'>[icon2html(pelt_icon, user.client)]<br>[label]</td>"
	page += "</tr></table><h3>Champion profile</h3><p>Gallery fields accept one image link per line. Rumours, gossip and detailed interaction preferences use your ordinary character settings.</p>"
	for(var/field in profile_fields)
		page += "<a href='byond://?src=[REF(src)];field=[field]'>[html_encode(replacetext(field, "_", " "))]</a><br>"
	page += "<p>Your choices save automatically. Open this menu through Preferences → Gnoll Customization.</p>"
	var/datum/browser/popup = new(user, "gnoll_customization", "Gnoll Customization", 620, 760)
	popup.set_content(page.Join())
	popup.open()

/datum/preference/list_type/gnoll_customization/Topic(href, list/href_list)
	var/mob/user = usr
	var/datum/preferences/prefs = user?.client?.prefs
	if(!prefs || prefs.gnoll_customization_prompt)
		return
	var/field = href_list["field"]
	var/list/profile = prefs.read_preference(type)
	var/new_value
	prefs.gnoll_customization_prompt = TRUE
	if(field == "random_name")
		new_value = random_gnoll_champion_name()
		field = "name"
	else if(field == "name")
		new_value = browser_input_text(user, "Choose your champion's name.", "Gnoll Customization", profile[field], MAX_NAME_LEN, encode = FALSE)
		if(!isnull(new_value))
			new_value = reject_bad_name(new_value)
	else if(field == "voice_color")
		new_value = input(user, "Choose your voice color.", "Gnoll Customization", "#[profile[field]]") as color|null
	else if(field in appearance_fields)
		var/list/options = get_options(field)
		var/chosen = browser_input_list(user, "Choose your [appearance_fields[field]].", "Gnoll Customization", options)
		if(chosen in options)
			new_value = options[chosen]
	else if(field in profile_fields)
		var/datum/preference/entry = GLOB.preference_entries[profile_fields[field]]
		var/default_text = islist(profile[field]) ? jointext(profile[field], "\n") : profile[field]
		var/entered = tgui_input_text(user, "Edit your champion's [replacetext(field, "_", " ")].", "Gnoll Customization", default_text, MAX_FLAVOR_TEXT_LENGTH, multiline = TRUE, encode = FALSE)
		if(!isnull(entered))
			if(QDELETED(prefs) || user?.client?.prefs != prefs)
				if(!QDELETED(prefs))
					prefs.gnoll_customization_prompt = FALSE
				return
			if(istype(entry, /datum/preference/list_type))
				entered = length(trim(entered)) ? splittext(entered, "\n") : list()
			new_value = entry.deserialize(entered, prefs)
			if(!entry.is_valid(new_value, prefs))
				to_chat(user, span_warning("That field did not pass the existing profile validation."))
				new_value = null
	if(QDELETED(prefs))
		return
	prefs.gnoll_customization_prompt = FALSE
	if(user?.client?.prefs != prefs)
		return
	if(!isnull(new_value))
		profile = deepCopyList(prefs.read_preference(type))
		profile[field] = new_value
		prefs.write_preference(type, profile)
		prefs.save_preferences()
		var/datum/antagonist/gnoll/champion = get_gnoll_antag(user)
		if(champion && world.time < champion.customization_until && ishuman(user))
			var/mob/living/carbon/human/champion_body = user
			champion_body.apply_gnoll_customization()
	handle_link(prefs, user)

/mob/living/carbon/human/proc/apply_gnoll_customization(list/profile)
	var/datum/species/gnoll_champion/species = dna?.species
	if(!istype(species))
		return
	var/datum/preference/list_type/gnoll_customization/customization = GLOB.preference_entries[/datum/preference/list_type/gnoll_customization]
	if(!profile)
		if(!client?.prefs)
			return
		profile = client.prefs.read_preference(/datum/preference/list_type/gnoll_customization)
	profile = customization.deserialize(profile, client?.prefs)
	fully_replace_character_name(real_name, profile["name"])
	pronouns = profile["pronouns"]
	gender = profile["gender"]
	voice_color = profile["voice_color"]
	species.pelt = profile["pelt"]
	clear_mob_descriptors()
	add_mob_descriptor(/datum/mob_descriptor/stature/gnoll_champion)
	for(var/field in list("height", "build", "fur", "voice", "muzzle", "expression"))
		add_mob_descriptor(profile[field])
	var/list/anatomy_types = list(
		"penis" = /obj/item/organ/genitals/penis,
		"vagina" = /obj/item/organ/genitals/filling_organ/vagina,
		"breasts" = /obj/item/organ/genitals/filling_organ/breasts,
	)
	var/list/anatomy_slots = list("penis" = ORGAN_SLOT_PENIS, "vagina" = ORGAN_SLOT_VAGINA, "breasts" = ORGAN_SLOT_BREASTS)
	for(var/field in anatomy_types)
		if(profile[field] == "inherit")
			continue
		var/obj/item/organ/organ = getorganslot(anatomy_slots[field])
		if(profile[field] && !organ)
			var/organ_type = anatomy_types[field]
			organ = new organ_type()
			organ.Insert(src, TRUE, FALSE)
		else if(!profile[field] && organ)
			// Transformation must preserve pregnancies already underway.
			if(field == "vagina")
				var/obj/item/organ/genitals/filling_organ/vagina/hole = organ
				var/obj/item/organ/genitals/filling_organ/womb/womb = get_womb()
				if(GetComponent(/datum/component/pregnancy) || organ.GetComponent(/datum/component/pregnancy) || (istype(hole) && hole.carries_pregnancy()) || womb?.carries_pregnancy())
					continue
				// The womb goes with its vagina.
				if(womb)
					womb.Remove(src)
					qdel(womb)
			organ.Remove(src)
			qdel(organ)
	if(profile["penis"] != "inherit")
		var/obj/item/organ/testicles = getorganslot(ORGAN_SLOT_TESTICLES)
		if(profile["penis"] && !testicles)
			testicles = new /obj/item/organ/genitals/filling_organ/testicles()
			testicles.Insert(src, TRUE, FALSE)
		else if(!profile["penis"] && testicles)
			testicles.Remove(src)
			qdel(testicles)
	for(var/field in customization.profile_fields)
		var/datum/preference/entry = GLOB.preference_entries[customization.profile_fields[field]]
		entry.apply_to_human(src, profile[field], client?.prefs)
	flavortext_display = replacetext(parsemarkdown_basic(html_encode(flavortext)), "\n", "<br>")
	ooc_notes_display = replacetext(parsemarkdown_basic(html_encode(ooc_notes)), "\n", "<br>")
	regenerate_icons()
