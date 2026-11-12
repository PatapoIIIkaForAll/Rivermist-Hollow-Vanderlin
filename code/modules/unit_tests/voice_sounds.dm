/// Every voicepack answers every emote key with nothing, a sound file or a non-empty list of sound files.
/datum/unit_test/voicepack_sounds_valid

/datum/unit_test/voicepack_sounds_valid/Run()
	var/list/keys = list("idle", "aggro", "sexmoangag", "sexmoangag_org")
	for(var/emote_key in GLOB.emote_list)
		keys |= emote_key
	for(var/pack_type in typesof(/datum/voicepack))
		var/datum/voicepack/pack = new pack_type()
		for(var/key in keys)
			for(var/modifier in list(null, "old", "silenced"))
				var/result = pack.get_sound(key, modifier)
				if(isnull(result))
					continue
				if(islist(result))
					var/list/sounds = result
					TEST_ASSERT(length(sounds), "[pack_type] gives an empty list for [key] ([modifier])")
					for(var/entry in sounds)
						TEST_ASSERT(isfile(entry), "[pack_type] gives a non-file entry [entry] for [key] ([modifier])")
				else
					TEST_ASSERT(isfile(result), "[pack_type] gives a non-file [result] for [key] ([modifier])")

/// The added packs and keys return their own sounds.
/datum/unit_test/voicepack_added_keys

/datum/unit_test/voicepack_added_keys/Run()
	var/list/expected = list(
		/datum/voicepack/female/warrior = list("pain", "laugh", "hum"),
		/datum/voicepack/male/stern = list("pain", "chuckle", "snore"),
		/datum/voicepack/female/goblin = list("laugh", "giggle"),
		/datum/voicepack/male/goblin = list("laugh", "chuckle"),
		/datum/voicepack/male = list("giggle", "blink", "salute", "shiver", "sniff", "sneeze", "flutter"),
		/datum/voicepack/female = list("blink", "salute", "shiver", "sniff", "sneeze", "flutter"),
		/datum/voicepack/female/elf = list("giggle"),
		/datum/voicepack/zombie/m = list("groan", "sigh"),
		/datum/voicepack/zombie/f = list("groan", "sigh"),
	)
	for(var/pack_type in expected)
		var/datum/voicepack/pack = new pack_type()
		for(var/key in expected[pack_type])
			TEST_ASSERT_NOTNULL(pack.get_sound(key), "[pack_type] has no sound for [key]")
	// Each new pack must use its own files, not fall through to the general voice.
	var/datum/voicepack/female/warrior/warrior = new()
	var/list/warrior_pain = warrior.get_sound("pain")
	TEST_ASSERT(islist(warrior_pain) && ('sound/vo/female/warrior/pain (1).ogg' in warrior_pain), "The warrior voice does not use its own pain sounds")
	var/datum/voicepack/male/stern/stern = new()
	var/list/stern_pain = stern.get_sound("pain")
	TEST_ASSERT(islist(stern_pain) && ('sound/vo/male/stern/pain (1).ogg' in stern_pain), "The stern voice does not use its own pain sounds")
	TEST_ASSERT(!isnull(GLOB.voice_packs_list[VOICE_PACK_FEM_WARRIOR]), "Warrior (Fem) cannot be picked")
	TEST_ASSERT(!isnull(GLOB.voice_packs_list[VOICE_PACK_MASC_STERN]), "Stern (Masc) cannot be picked")

/// Every moan pack gives sound files for its keys and the voices' moans are in the moan list.
/datum/unit_test/moan_packs_valid

/datum/unit_test/moan_packs_valid/Run()
	var/list/keys = list("sexmoanlight", "sexmoanmed", "sexmoanhvy", "groan", "painmoan", "whimper", "sexmoangag", "sexmoangag_org")
	var/list/pack_types = typesof(/datum/moan_pack/male) + typesof(/datum/moan_pack/female)
	for(var/pack_type in pack_types)
		var/datum/moan_pack/pack = new pack_type()
		for(var/key in keys)
			var/list/sounds = pack.vars["sounds_[key]"]
			if(isnull(sounds))
				continue
			TEST_ASSERT(length(sounds), "[pack_type] has an empty list for [key]")
			for(var/entry in sounds)
				TEST_ASSERT(isfile(entry), "[pack_type] has a non-file entry [entry] for [key]")
			TEST_ASSERT(isfile(pack.get_moans(key)), "[pack_type] gives no file for [key]")
	generate_selectable_moanpacks()
	for(var/voice_moans in list("MALE FOPPISH", "FEMALE DAINTY", "FEMALE HAUGHTY", "MALE DEFAULT", "FEMALE DEFAULT"))
		TEST_ASSERT(GLOB.selectable_moanpacks[voice_moans], "[voice_moans] is missing from the moan pack list")

/// Speech moans are off by default and follow the speaker's toggle.
/datum/unit_test/speech_moan_toggle

/datum/unit_test/speech_moan_toggle/Run()
	var/datum/preferences/prefs = new
	TEST_ASSERT_EQUAL(prefs.read_preference(/datum/preference/toggle/speech_moans), FALSE, "Speech moans default to on")

	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	var/datum/component/arousal/arousal = speaker.GetComponent(/datum/component/arousal) || speaker.AddComponent(/datum/component/arousal)
	TEST_ASSERT_NOTNULL(arousal, "The speaker has no arousal component")
	arousal.arousal = 60
	TEST_ASSERT(!speaker.should_speech_moan(), "A speaker who did not turn speech moans on moans")

	var/datum/preference/toggle/speech_moans/pref = GLOB.preference_entries[/datum/preference/toggle/speech_moans]
	pref.apply_to_human(speaker, TRUE, prefs)
	TEST_ASSERT(speaker.should_speech_moan(), "A speaker with speech moans on and high arousal does not moan")
	arousal.arousal = 10
	TEST_ASSERT(!speaker.should_speech_moan(), "A speaker with low arousal moans")

/// Barks are off by default, play with a bark set and stay silent for whispers and muffled mouths.
/datum/unit_test/speech_bark_gate

/datum/unit_test/speech_bark_gate/Run()
	var/datum/preferences/prefs = new
	TEST_ASSERT_EQUAL(prefs.read_preference(/datum/preference/choiced/speech_bark), SPEECH_BARK_NONE, "Characters bark by default")
	TEST_ASSERT_EQUAL(prefs.read_preference(/datum/preference/toggle/hear_speech_barks), FALSE, "Players hear barks by default")
	TEST_ASSERT(!client_hears_speech_barks(null), "A missing client hears barks")

	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!speaker.can_speech_bark(list()), "A speaker without a bark barks")

	var/datum/preference/choiced/speech_bark/pref = GLOB.preference_entries[/datum/preference/choiced/speech_bark]
	pref.apply_to_human(speaker, "Chirp", prefs)
	TEST_ASSERT_EQUAL(speaker.speech_bark, "Chirp", "The bark choice did not reach the mob")
	TEST_ASSERT(speaker.can_speech_bark(list()), "A speaker with a bark does not bark")
	TEST_ASSERT(!speaker.can_speech_bark(list(WHISPER_MODE = MODE_WHISPER)), "A whisper barks")

	speaker.mouth_blocked = TRUE
	TEST_ASSERT(!speaker.can_speech_bark(list()), "A muffled speaker barks and reveals the voice")
	speaker.mouth_blocked = FALSE

	pref.apply_to_human(speaker, SPEECH_BARK_NONE, prefs)
	TEST_ASSERT(!speaker.can_speech_bark(list()), "Choosing no bark still barks")

	TEST_ASSERT_EQUAL(speech_bark_count(10000, 2), 128, "A long message is not capped")
	TEST_ASSERT_EQUAL(speech_bark_count(8, 4), 3, "Bark count is not one per speed letters plus one")
	for(var/bark_name in GLOB.speech_barks)
		var/datum/speech_bark/bark = GLOB.speech_barks[bark_name]
		TEST_ASSERT(isfile(bark.soundpath), "Bark [bark_name] has no sound file")
