#define NOTICEBOARD_MAX_NOTICES 5

/obj/structure/noticeboard
	name = "notice board"
	desc = "Use a sheet of paper or a scroll on the board to pin it up. Anyone can read the notes, write on them with a quill, or take them down."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	density = FALSE
	anchored = TRUE
	max_integrity = 150

/obj/structure/noticeboard/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/paper/note in loc)
			if(count_notices() >= NOTICEBOARD_MAX_NOTICES)
				break
			pin_note(note)
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/noticeboard/update_icon_state()
	. = ..()
	icon_state = "nboard0[min(count_notices(), NOTICEBOARD_MAX_NOTICES)]"

/obj/structure/noticeboard/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone, /obj/item/paper))
		update_appearance(UPDATE_ICON_STATE)

/obj/structure/noticeboard/proc/count_notices()
	. = 0
	for(var/obj/item/paper/note in contents)
		.++

/// Moves a note onto the board; rolled scrolls are opened so they can be read and written on.
/obj/structure/noticeboard/proc/pin_note(obj/item/paper/note, mob/user)
	if(user)
		if(!user.transferItemToLoc(note, src))
			return FALSE
	else
		note.forceMove(src)
	if(istype(note, /obj/item/paper/scroll))
		var/obj/item/paper/scroll/scroll = note
		if(!scroll.open)
			scroll.open = TRUE
			scroll.slot_flags &= ~ITEM_SLOT_HIP
			scroll.update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/structure/noticeboard/attackby(obj/item/O, mob/user, list/modifiers)
	if(!istype(O, /obj/item/paper))
		return ..()
	if(count_notices() >= NOTICEBOARD_MAX_NOTICES)
		to_chat(user, span_warning("The notice board is full. Take a note down first."))
		return
	if(!pin_note(O, user))
		return
	to_chat(user, span_notice("I pin [O] to the notice board."))

/obj/structure/noticeboard/interact(mob/user)
	. = ..()
	show_window(user)

/obj/structure/noticeboard/proc/show_window(mob/user)
	var/list/dat = list("<B>[html_encode(name)]</B><BR>")
	dat += "Notes pinned: [count_notices()] of [NOTICEBOARD_MAX_NOTICES]. Use a sheet of paper or a scroll on the board to pin it.<BR><BR>"
	for(var/obj/item/paper/note in contents)
		dat += "[html_encode(note.name)] <A href='byond://?src=[REF(src)];read=[REF(note)]'>Read</A> <A href='byond://?src=[REF(src)];write=[REF(note)]'>Write</A> <A href='byond://?src=[REF(src)];remove=[REF(note)]'>Take down</A><BR>"
	user << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>Notices</TITLE></HEAD><BODY>[dat.Join()]</BODY></HTML>", "window=noticeboard")
	onclose(user, "noticeboard")

/obj/structure/noticeboard/Topic(href, href_list)
	. = ..()
	var/mob/living/user = usr
	if(!istype(user) || !user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		return

	if(href_list["read"])
		var/obj/item/paper/note = locate(href_list["read"]) in contents
		if(istype(note))
			note.read(user)
		return

	if(href_list["write"])
		var/obj/item/paper/note = locate(href_list["write"]) in contents
		if(!istype(note))
			return
		var/obj/item/pen = user.is_holding_item_of_type(/obj/item/natural/feather) || user.is_holding_item_of_type(/obj/item/natural/thorn)
		if(!pen)
			to_chat(user, span_warning("I need a quill in my hand to write."))
			return
		add_fingerprint(user)
		note.attackby(pen, user)
		return

	if(href_list["remove"])
		var/obj/item/paper/note = locate(href_list["remove"]) in contents
		if(!istype(note))
			return
		note.forceMove(user.drop_location())
		user.put_in_hands(note)
		to_chat(user, span_notice("I take [note] down from the notice board."))
		show_window(user)

#undef NOTICEBOARD_MAX_NOTICES
