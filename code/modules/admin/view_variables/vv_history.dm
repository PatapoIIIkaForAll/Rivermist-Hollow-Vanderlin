/**
 * View Variables navigation history.
 *
 * Every VV window an admin opens is remembered on their admin datum, so the window can offer
 * Back / Forward links and a "Recent" list, and so a stale link can be answered with a clear
 * message instead of opening nothing (or the wrong object, if BYOND has reused the reference).
 */

#define VV_HISTORY_MAX 25

/datum/admins
	/// View Variables history: list of list("ref", "title", "type"), newest first.
	var/list/vv_history = list()
	/// Index in vv_history of the object the admin is looking at.
	var/vv_history_pos = 1
	/// Set by a Back/Forward link: the next recorded view moves inside the history instead of adding to it.
	var/vv_history_nav

/// Remembers that this admin is now looking at thing. Called by debug_variables().
/datum/admins/proc/vv_history_record(thing, title, type_text)
	var/ref = REF(thing)
	var/nav = vv_history_nav
	vv_history_nav = null
	var/count = length(vv_history)

	// Back / Forward: move the cursor, keep the order.
	if(nav && nav >= 1 && nav <= count)
		var/list/nav_entry = vv_history[nav]
		if(nav_entry["ref"] == ref)
			nav_entry["title"] = title
			vv_history_pos = nav
			return

	// Refresh of the object already shown.
	if(vv_history_pos >= 1 && vv_history_pos <= count)
		var/list/shown_entry = vv_history[vv_history_pos]
		if(shown_entry["ref"] == ref)
			shown_entry["title"] = title
			return
		// Opened from an older entry: that entry becomes the one "Back" returns to.
		if(vv_history_pos > 1)
			vv_history.Cut(vv_history_pos, vv_history_pos + 1)
			vv_history.Insert(1, list(shown_entry))

	for(var/i in length(vv_history) to 1 step -1)
		var/list/old_entry = vv_history[i]
		if(old_entry["ref"] == ref)
			vv_history.Cut(i, i + 1)
	vv_history.Insert(1, list(list("ref" = ref, "title" = title, "type" = type_text)))
	if(length(vv_history) > VV_HISTORY_MAX)
		vv_history.Cut(VV_HISTORY_MAX + 1)
	vv_history_pos = 1

/// Forgets a history entry, used when its object turned out to be gone.
/datum/admins/proc/vv_history_drop(ref)
	for(var/i in length(vv_history) to 1 step -1)
		var/list/entry = vv_history[i]
		if(entry["ref"] == ref)
			vv_history.Cut(i, i + 1)
			if(vv_history_pos > i)
				vv_history_pos--
	vv_history_pos = clamp(vv_history_pos, 1, max(length(vv_history), 1))

/**
 * Checks a Back/Forward/Recent link before it is followed. Looks the entry up by its reference:
 * every new view shifts the positions, so the one in a link drawn earlier may be stale.
 * Returns the entry's index, or 0 when it is gone or its reference now points at something else.
 */
/datum/admins/proc/vv_history_find(ref)
	for(var/index in 1 to length(vv_history))
		var/list/entry = vv_history[index]
		if(entry["ref"] != ref)
			continue
		var/thing = locate(ref)
		if(isnull(thing))
			return 0
		var/type_now
		if(islist(thing))
			type_now = istype(thing, /alist) ? "/alist" : "/list"
		else if(isdatum(thing))
			var/datum/datum_thing = thing
			type_now = "[datum_thing.type]"
		if(type_now && entry["type"] && type_now != entry["type"])
			return 0 // the reference was reused by something else
		return index
	return 0

/datum/admins/proc/vv_history_link(index, label)
	var/list/entry = vv_history[index]
	return "<a class='vvbtn' href='byond://?_src_=vars;[HrefToken()];Vars=[entry["ref"]];vv_nav=[index]' title='[html_encode(entry["title"])]'>[label]</a>"

/// The Back / Forward / Recent controls shown at the top of a VV window.
/datum/admins/proc/vv_history_html()
	var/count = length(vv_history)
	var/list/out = list()
	if(vv_history_pos < count)
		out += vv_history_link(vv_history_pos + 1, "&#9664; Back")
	else
		out += "<span class='vvbtn vvbtn-off' title='Nothing earlier in your VV history'>&#9664; Back</span>"
	if(vv_history_pos > 1 && vv_history_pos <= count)
		out += vv_history_link(vv_history_pos - 1, "Forward &#9654;")
	else
		out += "<span class='vvbtn vvbtn-off' title='Nothing later in your VV history'>Forward &#9654;</span>"
	if(count > 1)
		out += "<select class='vvrecent' onchange='handle_dropdown(this)' title='Objects you opened recently'><option value selected>Recent ([count])</option>"
		for(var/i in 1 to count)
			var/list/entry = vv_history[i]
			out += "<option value='byond://?_src_=vars;[HrefToken()];Vars=[entry["ref"]];vv_nav=[i]'>[i == vv_history_pos ? "&#9679; " : ""][html_encode(copytext("[entry["title"]]", 1, 70))]</option>"
		out += "</select>"
	return out.Join(" ")

/client/proc/vv_history_panel()
	set name = "VV History"
	set category = "Debug.Core"
	set desc = "List the objects you opened in View Variables recently."

	if(!holder)
		return
	var/list/dat = list("<b>View Variables history</b> (newest first)<hr>")
	if(!length(holder.vv_history))
		dat += "<i>You have not opened anything in View Variables yet.</i>"
	for(var/i in 1 to length(holder.vv_history))
		var/list/entry = holder.vv_history[i]
		dat += "[i]. <a href='byond://?_src_=vars;[HrefToken()];Vars=[entry["ref"]];vv_nav=[i]'>[html_encode(entry["title"])]</a> <font size='1'>[html_encode(entry["type"])]</font><br>"
	if(!check_rights_for(src, R_VAREDIT))
		dat += "<hr><i>Following these links needs +VAREDIT.</i>"
	var/datum/browser/popup = new(mob, "vv_history", "VV History", 520, 420)
	popup.set_content(dat.Join())
	popup.open()

#undef VV_HISTORY_MAX
