// Savefile step: the prosthetic, Missing Arm/Leg and Cyclops quirks became Prosthetics window choices.

/datum/preferences/proc/migrate_prosthetic_quirk_save(savefile/S)
	var/quirk_text = S.ExportText("quirks")
	if(!quirk_text)
		return
	var/list/found = list()

	var/static/regex/limb_quirk = regex(@"/datum/quirk/(?:positive|negative)/(iron|steel|gold|bronze|wooden)_(arm|leg)_(left|right)\b", "g")
	while(limb_quirk.Find(quirk_text))
		var/material = limb_quirk.group[1] == "wooden" ? "wood" : limb_quirk.group[1]
		found["[limb_quirk.group[3] == "left" ? "l" : "r"]_[limb_quirk.group[2]]"] = "limb_[material]"

	var/static/regex/missing_limb_quirk = regex(@{"/datum/quirk/negative/crippled_(arm|leg)\b[^)]*?"value"\s*=\s*(?:"([a-z_]+)"|null)"}, "g")
	while(missing_limb_quirk.Find(quirk_text))
		var/limb_zone = missing_limb_quirk.group[2]
		if(prosthetic_slot_kind(limb_zone) != missing_limb_quirk.group[1])
			limb_zone = "l_[missing_limb_quirk.group[1]]"
		found[limb_zone] = "limb_missing"

	var/static/regex/missing_eye_quirk = regex(@"/datum/quirk/negative/cyclops_(left|right)\b", "g")
	while(missing_eye_quirk.Find(quirk_text))
		found[missing_eye_quirk.group[1] == "left" ? PROSTHETIC_SLOT_L_EYE : PROSTHETIC_SLOT_R_EYE] = "eye_missing"

	if(!length(found))
		return

	// Dead paths read back as null, so they are renamed to the base type and then dropped.
	var/static/regex/old_paths = regex(@"/datum/quirk/(?:(?:positive|negative)/(?:iron|steel|gold|bronze|wooden)_(?:arm|leg)_(?:left|right)|negative/crippled_(?:arm|leg)|negative/cyclops_(?:left|right))\b", "g")
	S.ImportText("quirks", old_paths.Replace(quirk_text, "/datum/quirk"))
	var/list/quirk_data
	S["quirks"] >> quirk_data
	if(islist(quirk_data))
		for(var/list/entry in quirk_data.Copy())
			if(islist(entry) && entry["type"] == /datum/quirk)
				quirk_data -= list(entry)
		WRITE_FILE(S["quirks"], quirk_data)

	var/list/saved
	S["prosthetics"] >> saved
	if(!islist(saved))
		saved = list()
	for(var/slot in found)
		if(!saved[slot])
			saved[slot] = found[slot]
	WRITE_FILE(S["prosthetics"], saved)

/datum/special_trait/war_veteran/proc/fit_veteran_wounds(mob/living/carbon/human/character)
	character.fit_prosthetic_option(PROSTHETIC_SLOT_L_ARM, GLOB.prosthetic_options["limb_wood"], FALSE)
	character.fit_prosthetic_option(PROSTHETIC_SLOT_L_EYE, GLOB.prosthetic_options["eye_missing"], FALSE)
