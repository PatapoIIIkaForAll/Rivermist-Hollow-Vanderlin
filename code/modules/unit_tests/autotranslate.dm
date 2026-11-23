/// text2ascii() must read whole characters, or Cyrillic text is never detected.
/datum/unit_test/autotranslate_detection

/datum/unit_test/autotranslate_detection/Run()
	TEST_ASSERT_EQUAL(autotranslate_count_scripts("Привет, как дела?"), "ru", "Russian text was not detected.")
	TEST_ASSERT_EQUAL(autotranslate_count_scripts("Hello there, friend."), "en", "English text was not detected.")
	TEST_ASSERT_EQUAL(autotranslate_count_scripts("Привет, John"), "ru", "A Latin name changed the language of a Russian line.")
	TEST_ASSERT_EQUAL(autotranslate_count_scripts("Café crème — déjà vu"), "en", "Accented Latin letters and a dash were counted as Cyrillic.")
	TEST_ASSERT_EQUAL(autotranslate_count_scripts("It&#39;s &quot;fine&quot;"), "en", "HTML entities broke the letter count.")
	TEST_ASSERT_NULL(autotranslate_count_scripts("&quot;?!&quot; 123"), "Text with no letters got a language.")
	TEST_ASSERT_NULL(autotranslate_count_scripts("да ok"), "Evenly mixed text got a language.")

/// The mark goes around the spoken words only, inside the span that styles them.
/datum/unit_test/autotranslate_say_quote

/datum/unit_test/autotranslate_say_quote/Run()
	var/obj/speaker = allocate(/obj)
	var/plain_quote = speaker.say_quote("Hello")
	var/datum/translated_line/line = new("tester", "Hello", "Say")
	SSautotranslate.current_line = line
	var/marked_quote = speaker.say_quote("Hello")
	SSautotranslate.current_line = null
	var/mark = "<span class='tsl tsl-pending' data-tsl-id='[line.id]'>Hello</span>"
	TEST_ASSERT_NOTNULL(line.id, "The line got no id.")
	TEST_ASSERT_EQUAL(marked_quote, replacetext(plain_quote, ">Hello<", ">[mark]<"), "The mark is not directly around the spoken words.")
