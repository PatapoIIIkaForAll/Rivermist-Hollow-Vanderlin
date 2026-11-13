/// Mumbles keep each typed word's length and its trailing punctuation, and drop the words.
/datum/unit_test/muffled_speech_length

/datum/unit_test/muffled_speech_length/Run()
	var/typed = "Hello there my friend"
	var/mumble = muffle_speech(typed)
	TEST_ASSERT_EQUAL(length_char(mumble), length_char(typed), "Mumble [mumble] is not as long as [typed]")
	TEST_ASSERT_EQUAL(mumble, "Mmmph mmmph mm mmmmph", "Unexpected mumble")
	TEST_ASSERT_EQUAL(muffle_speech("where are you?"), "Mmmph mph mph?", "A question lost its question mark")
	TEST_ASSERT_EQUAL(muffle_speech("help!!"), "Mmph!!", "A shout lost its marks")
	// Sanitized text carries entities; the mumble counts letters, not entity characters.
	TEST_ASSERT_EQUAL(muffle_speech(sanitize("don't")), "Mmmph", "An apostrophe entity changed the mumble length")
	var/long_word = muffle_speech("abcdefghijklmnopqrstuvwxyz")
	TEST_ASSERT_EQUAL(length_char(long_word), 12, "A very long word was not capped")

/// Gagged, mouth-blocked and mouth-filled speakers mumble; mute and tongueless ones cannot speak.
/datum/unit_test/muffled_speech_rules
	var/last_spoken

/datum/unit_test/muffled_speech_rules/proc/on_special_say(datum/source, mob/living/speaker, message)
	SIGNAL_HANDLER
	last_spoken = message

/datum/unit_test/muffled_speech_rules/Run()
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!speaker.is_speech_muffled(), "A bare mouth counts as muffled")
	TEST_ASSERT(speaker.can_voice_words(), "A healthy speaker cannot voice words")

	speaker.mouth_blocked = TRUE
	TEST_ASSERT(speaker.is_speech_muffled(), "A blocked mouth does not muffle speech")
	speaker.mouth_blocked = FALSE

	var/obj/item/natural/cloth/rag = allocate(/obj/item/natural/cloth)
	speaker.equip_to_slot_if_possible(rag, ITEM_SLOT_MOUTH)
	TEST_ASSERT_EQUAL(speaker.mouth, rag, "The rag did not go into the mouth")
	TEST_ASSERT(speaker.is_speech_muffled(), "An item in the mouth does not muffle speech")
	speaker.dropItemToGround(rag, force = TRUE)

	var/obj/item/clothing/face/bdsm_gag/ball/black/gag = allocate(/obj/item/clothing/face/bdsm_gag/ball/black)
	gag.drool_chance = 0
	speaker.equip_to_slot_if_possible(gag, ITEM_SLOT_MASK)
	TEST_ASSERT_EQUAL(speaker.wear_mask, gag, "The gag did not go on the face")
	TEST_ASSERT(speaker.is_speech_muffled(), "A fastened gag does not muffle speech")

	RegisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL, PROC_REF(on_special_say))
	speaker.say("Hello there friend", forced = "unit test")
	TEST_ASSERT_NOTNULL(last_spoken, "The gagged speaker said nothing")
	TEST_ASSERT_EQUAL(last_spoken, "Mmmph mmmph mmmmph", "Gagged speech carried other words")

	speaker.dropItemToGround(gag, force = TRUE)
	last_spoken = null
	speaker.say("Hello there friend", forced = "unit test")
	TEST_ASSERT_EQUAL(last_spoken, "Hello there friend", "Clear speech was changed")

	ADD_TRAIT(speaker, TRAIT_MUTE, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!speaker.can_voice_words(), "A mute speaker can voice words")
	last_spoken = null
	speaker.say("Hello there friend", forced = "unit test")
	TEST_ASSERT_NULL(last_spoken, "A mute speaker spoke")
	REMOVE_TRAIT(speaker, TRAIT_MUTE, TRAIT_SOURCE_UNIT_TESTS)

	var/obj/item/organ/tongue/tongue = speaker.getorganslot(ORGAN_SLOT_TONGUE)
	TEST_ASSERT_NOTNULL(tongue, "The speaker has no tongue to remove")
	tongue.Remove(speaker)
	qdel(tongue)
	TEST_ASSERT(!speaker.can_voice_words(), "A tongueless speaker can voice words")
	UnregisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL)

/// A hidden face reads as body words and a mismatched voice as the voice descriptor; acquaintances hear the real name.
/datum/unit_test/hidden_person_names

/datum/unit_test/hidden_person_names/Run()
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human)
	stranger.fully_replace_character_name(null, "Hidden Stranger")
	stranger.gender = FEMALE
	stranger.voice_type = VOICE_TYPE_FEM

	TEST_ASSERT_EQUAL(stranger.get_visible_name(), "Hidden Stranger", "A visible face did not show the real name")
	TEST_ASSERT_NULL(stranger.get_alt_name(), "A visible face still gave a voice alias")

	ADD_TRAIT(stranger, TRAIT_DISFIGURED, TRAIT_SOURCE_UNIT_TESTS)
	stranger.clear_mob_descriptors()
	TEST_ASSERT_EQUAL(stranger.get_visible_name(), "Unknown", "A hidden face without descriptors is not Unknown")
	TEST_ASSERT_EQUAL(stranger.get_alt_name(TRUE), "Unknown Woman", "A voice without a descriptor is not Unknown Woman")

	stranger.add_mob_descriptor(/datum/mob_descriptor/trait/tall)
	stranger.add_mob_descriptor(/datum/mob_descriptor/stature/thug)
	stranger.add_mob_descriptor(/datum/mob_descriptor/voice/deep)
	TEST_ASSERT_EQUAL(stranger.get_visible_name(), "Tall Thug", "A hidden face did not read as its descriptors")
	TEST_ASSERT_EQUAL(stranger.get_visible_name(""), "", "A caller's own blank value was replaced")
	stranger.name = stranger.get_visible_name()
	TEST_ASSERT_EQUAL(stranger.get_alt_name(), "Deep-voiced Woman", "A hidden speaker did not read as the voice descriptor")

	TEST_ASSERT_EQUAL(stranger.get_unseen_speaker_name(stranger), "Deep-voiced Woman", "An unseen speaker did not read as the voice descriptor")
	stranger.mind_initialize()

	// Four listeners in view: only one who knows the speaker and has keen ears hears the real name.
	var/mob/living/carbon/human/plain_stranger = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/acquaintance = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/keen_stranger = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/keen_acquaintance = allocate(/mob/living/carbon/human)
	for(var/mob/living/carbon/human/new_listener as anything in list(plain_stranger, acquaintance, keen_stranger, keen_acquaintance))
		new_listener.mind_initialize()
	acquaintance.mind.learn_target_identity(stranger.mind)
	keen_acquaintance.mind.learn_target_identity(stranger.mind)
	ADD_TRAIT(keen_stranger, TRAIT_KEENEARS, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(keen_acquaintance, TRAIT_KEENEARS, TRAIT_SOURCE_UNIT_TESTS)

	var/list/expected_names = list(
		plain_stranger = "Deep-voiced Woman",
		acquaintance = "Deep-voiced Woman",
		keen_stranger = "Deep-voiced Woman",
		keen_acquaintance = "Hidden Stranger",
	)
	var/list/listeners = list(plain_stranger, acquaintance, keen_stranger, keen_acquaintance)
	for(var/i in 1 to length(listeners))
		var/mob/living/carbon/human/listener = listeners[i]
		var/expected = expected_names[expected_names[i]]
		var/heard = listener.compose_message(stranger, null, "Hello", null, list(), list())
		TEST_ASSERT(findtext(heard, expected), "Listener [expected_names[i]] did not hear [expected]: [heard]")
		if(expected != "Hidden Stranger")
			TEST_ASSERT(!findtext(heard, "Hidden Stranger"), "Listener [expected_names[i]] heard the real name")
	REMOVE_TRAIT(stranger, TRAIT_DISFIGURED, TRAIT_SOURCE_UNIT_TESTS)
