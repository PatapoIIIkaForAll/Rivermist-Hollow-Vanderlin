/// Pinning, reading and taking down notes on the paper notice board.
/datum/unit_test/notice_board_paper

/datum/unit_test/notice_board_paper/Run()
	var/obj/structure/noticeboard/board = allocate(/obj/structure/noticeboard)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/paper/scroll/scroll = allocate(/obj/item/paper/scroll)
	TEST_ASSERT(!scroll.open, "A new scroll should start rolled up.")
	TEST_ASSERT(user.put_in_hands(scroll), "The user could not hold the scroll.")
	scroll.melee_attack_chain(user, board)
	TEST_ASSERT_EQUAL(scroll.loc, board, "Using a scroll on the board should pin it.")
	TEST_ASSERT(scroll.open, "A pinned scroll must be unrolled, or nobody can read or write on it.")
	TEST_ASSERT_EQUAL(board.icon_state, "nboard01", "The board sprite should show one note.")

	usr = user
	board.Topic("", list("read" = REF(scroll)))
	TEST_ASSERT_EQUAL(scroll.loc, board, "Reading a note must leave it pinned.")

	var/turf/far_turf = get_ranged_target_turf(run_loc_floor_bottom_left, EAST, 4)
	user.forceMove(far_turf)
	board.Topic("", list("remove" = REF(scroll)))
	TEST_ASSERT_EQUAL(scroll.loc, board, "A user four tiles away must not take a note down.")

	user.forceMove(get_step(run_loc_floor_bottom_left, EAST))
	board.Topic("", list("remove" = REF(scroll)))
	TEST_ASSERT(user.is_holding(scroll), "An adjacent user should take the note down into their hands.")
	TEST_ASSERT_EQUAL(board.icon_state, "nboard00", "The board sprite should show no notes.")

	for(var/i in 1 to 5)
		var/obj/item/paper/sheet = allocate(/obj/item/paper)
		board.attackby(sheet, user)
		TEST_ASSERT_EQUAL(sheet.loc, board, "Note [i] of 5 should fit on the board.")
	var/obj/item/paper/extra = allocate(/obj/item/paper)
	user.dropItemToGround(scroll)
	TEST_ASSERT(user.put_in_hands(extra), "The user could not hold the sixth sheet.")
	board.attackby(extra, user)
	TEST_ASSERT(user.is_holding(extra), "A sixth note must not fit on a full board.")
	usr = null

/// Board with a fixed author key, since test mobs have no ckey.
/obj/structure/fake_machine/rosewall/test_board
	var/list/test_keys = list()

/obj/structure/fake_machine/rosewall/test_board/author_key(mob/user)
	return test_keys[REF(user)]

/// Rosewall tests run on a scratch store and file, then restore the real store.
/datum/unit_test/rosewall
	abstract_type = /datum/unit_test/rosewall
	var/datum/rosewall_store/real_store
	var/datum/rosewall_store/store
	var/save_path = "data/rosewall_unit_test.json"

/datum/unit_test/rosewall/New()
	. = ..()
	real_store = GLOB.rosewall
	fdel(save_path)
	store = new(save_path)
	store.ensure_loaded()
	GLOB.rosewall = store

/datum/unit_test/rosewall/Destroy()
	GLOB.rosewall = real_store
	fdel(save_path)
	store = null
	real_store = null
	return ..()

/datum/unit_test/rosewall/proc/make_user(key, turf/where)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, where || get_step(run_loc_floor_bottom_left, EAST))
	user.real_name = "Tester [key]"
	return user

/// Posting a note through the board and reading it back.
/datum/unit_test/rosewall/post_and_read

/datum/unit_test/rosewall/post_and_read/Run()
	var/obj/structure/fake_machine/rosewall/test_board/board = allocate(/obj/structure/fake_machine/rosewall/test_board)
	var/mob/living/carbon/human/user = make_user("alpha")
	board.test_keys[REF(user)] = "alpha"
	board.next_action_at.Cut()
	usr = user
	board.ui_act("save_post", list("seeking" = "A quiet evening", "text" = "I sing at the tavern."))
	usr = null
	TEST_ASSERT_EQUAL(length(store.posts), 1, "Saving a note should pin one note.")
	var/datum/rosewall_post/post = store.posts[1]
	TEST_ASSERT_EQUAL(post.author_ckey, "alpha", "The note should belong to the poster's key.")
	TEST_ASSERT_EQUAL(post.character_name, user.real_name, "The note should carry the character name.")
	TEST_ASSERT_EQUAL(post.seeking, "A quiet evening", "The note should keep who the poster looks for.")
	TEST_ASSERT_EQUAL(post.text, "I sing at the tavern.", "The note should keep its text.")
	TEST_ASSERT_EQUAL(board.icon_state, "noticeboardbh1", "The board sprite should show notes.")

	var/list/data = board.ui_data(user)
	var/list/shown = data["posts"]
	TEST_ASSERT_EQUAL(length(shown), 1, "The board should show the note.")
	var/list/entry = shown[1]
	TEST_ASSERT_NOTNULL(entry, "The shown note is missing.")
	TEST_ASSERT_EQUAL(entry["text"], "I sing at the tavern.", "The shown note should carry its text.")
	TEST_ASSERT(entry["is_own"], "The poster should see the note as their own.")
	TEST_ASSERT_NOTNULL(data["own_post"], "The poster should get their note back for editing.")
	TEST_ASSERT(isnull(entry["ckey"]), "The board must not send player keys to the window.")

	var/mob/living/carbon/human/reader = make_user("beta")
	board.test_keys[REF(reader)] = "beta"
	var/list/reader_data = board.ui_data(reader)
	var/list/reader_entry = reader_data["posts"][1]
	TEST_ASSERT_NOTNULL(reader_entry, "Another player should see the note.")
	TEST_ASSERT(!reader_entry["is_own"], "Another player's note must not show as their own.")
	TEST_ASSERT(!reader_entry["can_remove"], "Another player must not be offered to take the note down.")

	board.next_action_at.Cut()
	usr = user
	board.ui_act("save_post", list("seeking" = "", "text" = "Edited text."))
	usr = null
	TEST_ASSERT_EQUAL(length(store.posts), 1, "Saving again should edit the note, not add a second one.")
	TEST_ASSERT_EQUAL(post.text, "Edited text.", "Saving again should replace the text.")

/// Only the writer or a moderator takes a note down.
/datum/unit_test/rosewall/remove_rules

/datum/unit_test/rosewall/remove_rules/Run()
	var/obj/structure/fake_machine/rosewall/test_board/board = allocate(/obj/structure/fake_machine/rosewall/test_board)
	var/mob/living/carbon/human/author = make_user("alpha")
	var/mob/living/carbon/human/other = make_user("beta", get_step(run_loc_floor_bottom_left, NORTH))
	board.test_keys[REF(author)] = "alpha"
	board.test_keys[REF(other)] = "beta"
	var/datum/rosewall_post/post = store.set_post("alpha", author.real_name, "", "My note.")
	TEST_ASSERT_NOTNULL(post, "The note was not pinned.")

	board.next_action_at.Cut()
	usr = other
	board.ui_act("remove_post", list("id" = post.id))
	usr = null
	TEST_ASSERT(post in store.posts, "Another player must not take down someone else's note.")

	board.next_action_at.Cut()
	usr = author
	board.ui_act("remove_post", list("id" = post.id))
	usr = null
	TEST_ASSERT(!(post in store.posts), "The writer should take their own note down.")
	TEST_ASSERT_EQUAL(board.icon_state, "noticeboardbh0", "The board sprite should show no notes.")

/// Text is cleaned and capped, and so is the number of notes.
/datum/unit_test/rosewall/caps

/datum/unit_test/rosewall/caps/Run()
	var/long_text = ""
	for(var/i in 1 to 150)
		long_text += "0123456789"
	var/datum/rosewall_post/post = store.set_post("alpha", "Alpha", "<b>Someone</b> kind", long_text)
	TEST_ASSERT_NOTNULL(post, "A long note should still be pinned.")
	TEST_ASSERT_EQUAL(length_char(post.text), 1000, "Note text should be capped at 1000 characters.")
	TEST_ASSERT_EQUAL(post.seeking, "Someone kind", "HTML tags should be stripped from player text.")

	TEST_ASSERT_NULL(store.set_post("alpha", "Alpha", "", "   "), "An empty note must be refused.")
	TEST_ASSERT_NOTNULL(store.set_post("alpha", "Bravo", "", "Second character."), "A second character should get a note.")
	TEST_ASSERT_NOTNULL(store.set_post("alpha", "Charlie", "", "Third character."), "A third character should get a note.")
	TEST_ASSERT_NULL(store.set_post("alpha", "Delta", "", "Fourth character."), "A fourth note from one player must be refused.")

	for(var/i in 1 to 100)
		store.set_post("filler[i]", "Filler [i]", "", "Filler note [i].")
	TEST_ASSERT_EQUAL(length(store.posts), 100, "The board should hold at most 100 notes.")
	TEST_ASSERT_NULL(store.find_own_post("alpha", "Alpha"), "The oldest note should drop off a full board.")
	TEST_ASSERT_NOTNULL(store.find_own_post("filler100", "Filler 100"), "The newest note should stay on a full board.")

/// Notes survive a save and load; expired and unsafe entries do not.
/datum/unit_test/rosewall/save_load

/datum/unit_test/rosewall/save_load/Run()
	store.set_post("alpha", "Alpha", "Company", "Line one.\nLine two.")
	store.set_post("beta", "Beta", "", "Beta note.")
	TEST_ASSERT(fexists(save_path), "Changing the board should write the save file.")

	var/datum/rosewall_store/reloaded = new(save_path)
	reloaded.load()
	TEST_ASSERT_EQUAL(length(reloaded.posts), 2, "Both notes should load back.")
	var/datum/rosewall_post/alpha = reloaded.find_own_post("alpha", "Alpha")
	TEST_ASSERT_NOTNULL(alpha, "The first note should load back.")
	TEST_ASSERT_EQUAL(alpha.text, "Line one.\nLine two.", "Note text and line breaks should load back.")
	TEST_ASSERT_EQUAL(alpha.seeking, "Company", "Who the poster looks for should load back.")

	var/today = store.current_day()
	var/list/entries = list(
		list("ckey" = "old", "name" = "Old", "text" = "Too old.", "day" = today - 31),
		list("ckey" = "fresh", "name" = "<script>x</script>Fresh", "text" = "<img src=x>Hello", "day" = today),
	)
	fdel(save_path)
	text2file(json_encode(list("version" = 1, "posts" = entries)), save_path)
	reloaded = new(save_path)
	reloaded.load()
	TEST_ASSERT_EQUAL(length(reloaded.posts), 1, "An expired note must not load.")
	var/datum/rosewall_post/fresh = reloaded.posts[1]
	TEST_ASSERT_EQUAL(fresh.character_name, "xFresh", "HTML tags in a loaded name should be stripped.")
	TEST_ASSERT_EQUAL(fresh.text, "Hello", "HTML tags in loaded text should be stripped.")

/// A missing or broken save file gives an empty board without a runtime.
/datum/unit_test/rosewall/broken_file

/datum/unit_test/rosewall/broken_file/Run()
	fdel(save_path)
	var/datum/rosewall_store/reloaded = new(save_path)
	reloaded.load()
	TEST_ASSERT_EQUAL(length(reloaded.posts), 0, "A missing file should give an empty board.")

	text2file("{not json", save_path)
	reloaded = new(save_path)
	reloaded.load()
	TEST_ASSERT_EQUAL(length(reloaded.posts), 0, "Broken JSON should give an empty board.")

	fdel(save_path)
	text2file("\[1, 2, 3\]", save_path)
	reloaded = new(save_path)
	reloaded.load()
	TEST_ASSERT_EQUAL(length(reloaded.posts), 0, "A JSON array should give an empty board.")

	fdel(save_path)
	text2file(json_encode(list("posts" = list(5, "text", list("name" = "No key"), list("ckey" = "a", "name" = "A", "text" = "Ok", "day" = "soon")))), save_path)
	reloaded = new(save_path)
	reloaded.load()
	TEST_ASSERT_EQUAL(length(reloaded.posts), 0, "Malformed entries should be skipped.")
