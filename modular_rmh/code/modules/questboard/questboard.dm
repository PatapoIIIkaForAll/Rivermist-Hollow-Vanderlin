/**
 * Quest board: player-authored notices (title/description/payment), separate
 * from the procedural Grand Contract Ledger. Roles: Guildmaster + Adventurers
 * Guildmaster Assistant (guild board), Innkeeper + Inn Cook (tavern board) -
 * each with its own posting cap. One active job per character. Completion is
 * signed by quill on the taker's scroll copy, not a board button. See
 * PATCH_NOTES.md for full design/integration notes.
 */

#define QUESTBOARD_MAX_TASKS 12
#define QUESTBOARD_TITLE_MAX 35
#define QUESTBOARD_PAYMENT_MAX 35
#define QUESTBOARD_DESC_MAX 500
#define QUESTBOARD_HISTORY_MAX 50

GLOBAL_LIST_EMPTY(questboard_active_takers)

/datum/board_task
	var/title
	var/description
	var/description_raw
	var/payment
	var/datum/weakref/poster_ref
	var/poster_name
	var/datum/weakref/taker_ref
	var/taker_name
	var/taken_at = 0
	var/datum/weakref/copy_ref
	var/datum/weakref/board_ref

/datum/board_task/Destroy()
	var/mob/taker = taker_ref?.resolve()
	if(taker)
		UnregisterSignal(taker, COMSIG_PARENT_QDELETING)
		GLOB.questboard_active_takers -= taker
	poster_ref = null
	taker_ref = null
	copy_ref = null
	board_ref = null
	return ..()

/datum/board_task/proc/register_taker(mob/taker)
	taker_ref = WEAKREF(taker)
	RegisterSignal(taker, COMSIG_PARENT_QDELETING, PROC_REF(on_taker_qdeleting))

/datum/board_task/proc/on_taker_qdeleting(datum/source)
	SIGNAL_HANDLER
	GLOB.questboard_active_takers -= source
	var/obj/structure/questboard/board = board_ref?.resolve()
	if(board)
		board.void_orphaned_task(src)

/obj/item/paper/scroll/quest_board_copy
	desc = "A sealed record of a job taken from a quest board."
	icon_state = "scroll_closed"
	writable = FALSE
	var/datum/weakref/task_ref
	var/quest_title = ""
	var/quest_description = ""
	var/quest_payment = ""
	var/quest_poster_name = ""
	var/completed = FALSE
	var/signed_by_leader = FALSE
	var/signed_by_name = ""

/obj/item/paper/scroll/quest_board_copy/update_name(updates = ALL)
	. = ..()
	if(!open)
		name = "quest parchment"
		return
	name = quest_title ? "quest parchment - [quest_title][completed ? " (completed)" : ""]" : "quest parchment"

/obj/item/paper/scroll/quest_board_copy/read(mob/user)
	if(!open && !isobserver(user))
		to_chat(user, span_notice("Open me."))
		return
	ui_interact(user)

/obj/item/paper/scroll/quest_board_copy/attackby(obj/item/attacking_item, mob/living/carbon/human/user, list/modifiers)
	if(istype(attacking_item, /obj/item/natural/feather))
		if(!open)
			to_chat(user, span_warning("Open me."))
			return TRUE
		if(!user.is_literate())
			to_chat(user, span_warning("I can't read or write."))
			return TRUE
		var/datum/board_task/task = task_ref?.resolve()
		var/obj/structure/questboard/board = task?.board_ref?.resolve()
		if(QDELETED(task) || !board)
			to_chat(user, span_warning("This job has already been settled."))
			return TRUE
		board.complete_task(user, task)
		return TRUE
	return ..()

/obj/item/paper/scroll/quest_board_copy/ui_state(mob/user)
	return GLOB.always_state

/obj/item/paper/scroll/quest_board_copy/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "QuestScroll")
		ui.open()

/obj/item/paper/scroll/quest_board_copy/ui_data(mob/user)
	var/list/data = list()
	data["quest_title"] = quest_title
	data["description"] = quest_description
	data["payment"] = quest_payment
	data["poster_name"] = quest_poster_name
	data["completed"] = completed
	data["signed_by_leader"] = signed_by_leader
	data["signed_by_name"] = signed_by_name
	return data

/obj/structure/questboard
	name = "quest board"
	desc = "A wooden board bristling with pinned parchment notices."
	icon = 'modular_rmh/icons/obj/structures/questboards32.dmi'
	icon_state = "qboard00"
	density = FALSE
	anchored = TRUE
	max_integrity = 150
	obj_flags = CAN_BE_HIT | USES_TGUI
	var/list/board_roles = list()
	var/leader_job_title = ""
	var/list/datum/board_task/tasks = list()
	var/list/history = list()
	var/list/pending_post = list()
	var/board_location_name = ""
	var/leader_label = ""
	var/list/staff_job_titles = list()
	var/staff_label = ""

/obj/structure/questboard/Destroy()
	QDEL_LIST(tasks)
	tasks = null
	pending_post = null
	history = null
	return ..()

/obj/structure/questboard/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/structure/questboard/attackby(obj/item/attacking_item, mob/living/carbon/human/user, params)
	. = ..()
	if(.)
		return
	if(istype(attacking_item, /obj/item/natural/feather))
		to_chat(user, span_notice("Signing off is done on the taken parchment itself, not the board."))
		ui_interact(user)
		return TRUE
	if(istype(attacking_item, /obj/item/paper) && !istype(attacking_item, /obj/item/paper/scroll/quest_board_copy))
		start_composing(user, attacking_item)
		return TRUE

/obj/structure/questboard/proc/start_composing(mob/living/carbon/human/user, obj/item/paper/parchment)
	if(!is_board_role(user))
		to_chat(user, span_warning("You have no authority to post notices here."))
		return
	if(length(tasks) >= QUESTBOARD_MAX_TASKS)
		to_chat(user, span_warning("The board is full - remove a notice before pinning a new one."))
		return
	var/cap = get_own_task_cap(user)
	if(cap && count_own_tasks(user) >= cap)
		to_chat(user, span_warning("You already have [cap] notices of your own up - clear one before pinning another."))
		return
	pending_post[user] = WEAKREF(parchment)
	to_chat(user, span_notice("You ready [parchment] to pin a new notice."))
	ui_interact(user)

/obj/structure/questboard/proc/is_board_role(mob/living/carbon/human/user)
	if(!istype(user) || !user.job)
		return FALSE
	return (user.job in board_roles)

/obj/structure/questboard/proc/is_leader_role(mob/living/carbon/human/user)
	if(!istype(user) || !user.job || !leader_job_title)
		return FALSE
	return (user.job == leader_job_title)

/obj/structure/questboard/proc/get_own_task_cap(mob/living/carbon/human/user)
	if(!istype(user) || !user.job)
		return 0
	return board_roles[user.job] || 0

/obj/structure/questboard/proc/count_own_tasks(mob/living/carbon/human/user)
	var/count = 0
	for(var/datum/board_task/task as anything in tasks)
		if(task.poster_ref?.resolve() == user)
			count++
	return count

/obj/structure/questboard/proc/update_board_sprite()
	var/tier = round((length(tasks) / QUESTBOARD_MAX_TASKS) * 3)
	tier = clamp(tier, 0, 3)
	icon_state = "qboard0[tier]"

/obj/structure/questboard/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/structure/questboard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "QuestBoard")
		ui.open()

/obj/structure/questboard/ui_data(mob/user)
	var/list/data = list()
	var/is_role = is_board_role(user)
	var/datum/board_task/pending_task = GLOB.questboard_active_takers[user]
	var/datum/weakref/pending_parchment = pending_post[user]
	var/own_cap = get_own_task_cap(user)
	data["board_title"] = name
	data["lang"] = get_ui_language(user)
	data["is_role"] = is_role
	data["has_active_task"] = pending_task && !QDELETED(pending_task)
	var/obj/item/paper/parchment_check = pending_parchment?.resolve()
	data["can_compose"] = is_role && pending_parchment && !QDELETED(parchment_check)
	data["board_full"] = length(tasks) >= QUESTBOARD_MAX_TASKS
	data["limits"] = list(
		"title" = QUESTBOARD_TITLE_MAX,
		"description" = QUESTBOARD_DESC_MAX,
		"payment" = QUESTBOARD_PAYMENT_MAX,
	)
	data["own_task_cap"] = own_cap
	data["own_task_count"] = own_cap ? count_own_tasks(user) : 0
	data["location_name"] = board_location_name
	data["leader_label"] = leader_label
	data["leader_name"] = get_online_job_holder_name(leader_job_title)
	data["staff_label"] = staff_label
	data["staff_names"] = get_online_staff_names(staff_job_titles)
	data["tasks"] = build_task_listing(user, is_role)
	data["history"] = is_role ? build_history_listing() : list()
	return data

/obj/structure/questboard/proc/get_online_job_holder_name(job_title)
	if(!job_title)
		return null
	for(var/mob/living/carbon/human/holder as anything in GLOB.human_list)
		if(holder.client && holder.job == job_title)
			return holder.real_name
	return null

/obj/structure/questboard/proc/get_online_staff_names(list/job_titles)
	var/list/names = list()
	if(!length(job_titles))
		return names
	for(var/mob/living/carbon/human/holder as anything in GLOB.human_list)
		if(holder.client && (holder.job in job_titles))
			names += holder.real_name
	return names

/obj/structure/questboard/proc/build_task_listing(mob/user, is_role)
	var/list/listing = list()
	for(var/datum/board_task/task as anything in tasks)
		var/mob/poster = task.poster_ref?.resolve()
		var/is_own_posting = is_role && poster == user
		listing += list(list(
			"ref" = REF(task),
			"title" = task.title,
			"description" = task.description,
			"description_raw" = task.description_raw,
			"payment" = task.payment,
			"poster_name" = task.poster_name,
			"taken" = !!task.taker_ref,
			"taker_name" = task.taker_name,
			"taken_at_text" = task.taken_at ? station_time_timestamp("hh:mm", task.taken_at) : null,
			"is_own_posting" = is_own_posting,
		))
	return listing

/obj/structure/questboard/proc/build_history_listing()
	var/list/listing = list()
	for(var/i = length(history), i >= 1, i--)
		listing += list(history[i])
	return listing

/obj/structure/questboard/proc/get_ui_language(mob/user)
	return get_preferred_ui_language(user)

/obj/structure/questboard/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/user = usr
	if(!istype(user) || !user.Adjacent(src))
		return TRUE
	switch(action)
		if("submit_post")
			submit_post(user, params["title"], params["description"], params["payment"])
			return TRUE
		if("cancel_post")
			pending_post -= user
			return TRUE
		if("update_task")
			update_task(user, params["ref"], params["title"], params["description"], params["payment"])
			return TRUE
		if("remove_task")
			remove_task(user, params["ref"])
			return TRUE
		if("take_task")
			take_task(user, params["ref"])
			return TRUE
		if("cancel_taken")
			cancel_taken(user, params["ref"])
			return TRUE

/obj/structure/questboard/proc/submit_post(mob/living/carbon/human/user, title, description, payment)
	if(!is_board_role(user))
		return
	var/datum/weakref/parchment_ref = pending_post[user]
	var/obj/item/paper/parchment = parchment_ref?.resolve()
	if(!parchment_ref || QDELETED(parchment) || !(parchment in user.GetAllContents()))
		to_chat(user, span_warning("You need a blank parchment in hand to post a notice."))
		pending_post -= user
		return
	if(length(tasks) >= QUESTBOARD_MAX_TASKS)
		to_chat(user, span_warning("The board is full."))
		return
	var/cap = get_own_task_cap(user)
	if(cap && count_own_tasks(user) >= cap)
		to_chat(user, span_warning("You already have [cap] notices of your own up - clear one before pinning another."))
		return
	title = sanitize(trim(title || "", QUESTBOARD_TITLE_MAX))
	var/description_raw = trim(description || "", QUESTBOARD_DESC_MAX)
	description = parsemarkdown(description_raw, user, TRUE) || ""
	payment = sanitize(trim(payment || "", QUESTBOARD_PAYMENT_MAX))
	if(!length(title))
		to_chat(user, span_warning("The notice needs a title."))
		return
	var/datum/board_task/task = new()
	task.title = title
	task.description = description
	task.description_raw = description_raw
	task.payment = payment
	task.poster_ref = WEAKREF(user)
	task.poster_name = user.real_name
	task.board_ref = WEAKREF(src)
	tasks += task
	pending_post -= user
	qdel(parchment)
	user.visible_message(span_notice("[user] pins a new notice to \the [src]."), span_notice("You pin the notice to \the [src]."))
	playsound(src, 'sound/items/inqslip_sealed.ogg', 40, TRUE, -1)
	update_board_sprite()

/obj/structure/questboard/proc/update_task(mob/living/carbon/human/user, ref, title, description, payment)
	var/datum/board_task/task = locate(ref) in tasks
	if(!istype(task) || task.taker_ref)
		to_chat(user, span_warning("That notice was taken or removed before your edit went through."))
		return
	if(!is_board_role(user) || task.poster_ref?.resolve() != user)
		to_chat(user, span_warning("This isn't your notice to change."))
		return
	title = sanitize(trim(title || "", QUESTBOARD_TITLE_MAX))
	var/description_raw = trim(description || "", QUESTBOARD_DESC_MAX)
	description = parsemarkdown(description_raw, user, TRUE) || ""
	payment = sanitize(trim(payment || "", QUESTBOARD_PAYMENT_MAX))
	if(!length(title))
		to_chat(user, span_warning("The notice needs a title."))
		return
	task.title = title
	task.description = description
	task.description_raw = description_raw
	task.payment = payment

/obj/structure/questboard/proc/remove_task(mob/living/carbon/human/user, ref)
	var/datum/board_task/task = locate(ref) in tasks
	if(!istype(task) || task.taker_ref)
		to_chat(user, span_warning("That notice was already taken or removed."))
		return
	if(!is_board_role(user) || task.poster_ref?.resolve() != user)
		to_chat(user, span_warning("This isn't your notice to remove."))
		return
	tasks -= task
	qdel(task)
	var/obj/item/paper/blank = new(get_turf(user))
	user.put_in_hands(blank)
	to_chat(user, span_notice("You unpin the notice and pocket the blank parchment."))
	update_board_sprite()

/obj/structure/questboard/proc/take_task(mob/living/carbon/human/user, ref)
	var/datum/board_task/task = locate(ref) in tasks
	if(!istype(task) || task.taker_ref)
		to_chat(user, span_warning("Someone beat you to that notice."))
		return
	if(GLOB.questboard_active_takers[user])
		to_chat(user, span_warning("You already have a job to attend to."))
		return
	if(is_board_role(user) && task.poster_ref?.resolve() == user)
		to_chat(user, span_warning("You cannot take your own notice."))
		return
	task.register_taker(user)
	task.taker_name = user.real_name
	task.taken_at = world.time
	var/obj/item/paper/scroll/quest_board_copy/copy = new(get_turf(user))
	copy.quest_title = task.title
	copy.quest_description = task.description
	copy.quest_payment = task.payment
	copy.quest_poster_name = task.poster_name
	copy.info = "[task.title] - [task.description] - Payment: [task.payment]"
	copy.task_ref = WEAKREF(task)
	copy.update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)
	task.copy_ref = WEAKREF(copy)
	user.put_in_hands(copy)
	GLOB.questboard_active_takers[user] = task
	to_chat(user, span_notice("You take up the notice: [task.title]."))

/obj/structure/questboard/proc/void_orphaned_task(datum/board_task/task)
	if(!istype(task) || !(task in tasks))
		return
	var/obj/item/paper/scroll/quest_board_copy/copy = task.copy_ref?.resolve()
	if(!QDELETED(copy))
		qdel(copy)
	tasks -= task
	qdel(task)
	update_board_sprite()
	SStgui.update_uis(src)

/obj/structure/questboard/proc/cancel_taken(mob/living/carbon/human/user, ref)
	var/datum/board_task/task = locate(ref) in tasks
	if(!istype(task) || !task.taker_ref)
		return
	if(!is_board_role(user) || task.poster_ref?.resolve() != user)
		to_chat(user, span_warning("This isn't your notice to cancel."))
		return
	var/mob/taker = task.taker_ref.resolve()
	var/obj/item/paper/scroll/quest_board_copy/copy = task.copy_ref?.resolve()
	if(!QDELETED(copy))
		qdel(copy)
	if(taker)
		to_chat(taker, span_warning("Your job, \"[task.title]\", has been cancelled by [user.real_name]."))
	tasks -= task
	qdel(task)
	update_board_sprite()

/obj/structure/questboard/proc/complete_task(mob/living/carbon/human/user, datum/board_task/task)
	if(!istype(task) || !task.taker_ref)
		return
	if(!is_board_role(user))
		to_chat(user, span_warning("You have no authority to sign off on notices here."))
		return
	var/choice = tgui_alert(user, "Sign \"[task.title]\" as complete?", "Sign Notice", list("Sign as complete", "Cancel"))
	if(choice != "Sign as complete")
		return
	if(QDELETED(task) || !(task in tasks))
		return
	if(QDELETED(user) || !is_board_role(user))
		to_chat(user, span_warning("You're no longer authorized to sign this off."))
		return
	var/obj/item/paper/scroll/quest_board_copy/signing_copy = task.copy_ref?.resolve()
	if(QDELETED(signing_copy) || !((signing_copy in user.GetAllContents()) || user.Adjacent(signing_copy)))
		to_chat(user, span_warning("You need the scroll in hand or nearby to sign it."))
		return
	var/leader_signature = is_leader_role(user)
	var/mob/taker = task.taker_ref.resolve()
	if(!QDELETED(signing_copy))
		signing_copy.completed = TRUE
		signing_copy.signed_by_leader = leader_signature
		signing_copy.signed_by_name = user.real_name
		signing_copy.info += " - Signed complete by [user.real_name]."
		signing_copy.update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)
	if(taker)
		to_chat(taker, span_boldnotice("[user.real_name] has signed off on \"[task.title]\" as complete."))
	history += list(list(
		"title" = task.title,
		"poster_name" = task.poster_name,
		"payment" = task.payment,
		"taker_name" = task.taker_name,
		"signed_by_name" = user.real_name,
		"signed_by_leader" = leader_signature,
	))
	if(length(history) > QUESTBOARD_HISTORY_MAX)
		history.Cut(1, length(history) - QUESTBOARD_HISTORY_MAX + 1)
	tasks -= task
	qdel(task)
	update_board_sprite()
	SStgui.update_uis(src)

/obj/structure/questboard/guild
	name = "adventurers' guild quest board"
	desc = "A quest board maintained by the Adventurers' Guild. The Guildmaster and their assistant may pin notices here."
	board_roles = list(
		/datum/job/adventurers_guildmaster::title = QUESTBOARD_MAX_TASKS,
		/datum/job/adventurers_assistant::title = 3,
	)
	board_location_name = "Adventurers' Guild"
	leader_job_title = /datum/job/adventurers_guildmaster::title
	leader_label = "Guildmaster"
	staff_job_titles = list(/datum/job/adventurers_assistant::title)
	staff_label = "Assistant"

/obj/structure/questboard/tavern
	name = "tavern quest board"
	desc = "A quest board kept by the tavern. The Innkeeper and the kitchen staff may pin notices here."
	board_roles = list(
		/datum/job/innkeep::title = QUESTBOARD_MAX_TASKS,
		/datum/job/cook::title = 3,
	)
	board_location_name = "Drunken Dwarf"
	leader_job_title = /datum/job/innkeep::title
	leader_label = "Innkeeper"
	staff_job_titles = list(/datum/job/cook::title)
	staff_label = "Cooks"

#undef QUESTBOARD_MAX_TASKS
#undef QUESTBOARD_TITLE_MAX
#undef QUESTBOARD_PAYMENT_MAX
#undef QUESTBOARD_DESC_MAX
#undef QUESTBOARD_HISTORY_MAX
