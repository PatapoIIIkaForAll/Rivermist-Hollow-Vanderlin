#define ICON_STATE_CHECKED 1 /// this dmi is checked. We don't check this one anymore.
#define ICON_STATE_NULL 2 /// this dmi has null-named icon_state, allowing it to show a sprite on vv editor.

/client/proc/debug_variables(datum/thing in world)
	set category = "Debug.Core"
	set name = "View Variables"
	set popup_menu = FALSE // reached through the Admin.../GM.../Debug... right-click entries
	//set src in world
	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!usr.client || !usr.client.holder) //This is usr because admins can call the proc on other clients, even if they're not admins, to show them VVs.
		to_chat(usr, span_danger("You need to be an administrator to access this."))
		return

	if(!thing)
		return

	var/datum/asset/asset_cache_datum = get_asset_datum(/datum/asset/simple/vv)
	asset_cache_datum.send(usr)

	if(isappearance(thing))
		thing = get_vv_appearance(thing) // this is /mutable_appearance/our_bs_subtype

	var/islist = islist(thing) || (!isdatum(thing) && hascall(thing, "Cut")) // Some special lists don't count as lists, but can be detected by if they have list procs
	if(!islist && !isdatum(thing))
		return

	var/title = ""
	var/refid = REF(thing)
	var/icon/sprite
	var/hash

	var/is_alist = istype(thing, /alist)
	var/type = islist ? (is_alist ? /alist : /list) : thing.type
	var/no_icon = FALSE

	if(isatom(thing))
		sprite = vv_preview_icon(thing)
		if(!sprite)
			no_icon = TRUE

	else if(isimage(thing))
		// icon_state=null shows first image even if dmi has no icon_state for null name.
		// This list remembers which dmi has null icon_state, to determine if icon_state=null should display a sprite
		// (NOTE: icon_state="" is correct, but saying null is obvious)
		var/static/list/dmi_nullstate_checklist = list()
		var/image/image_object = thing
		var/icon_filename_text = "[image_object.icon]" // "icon(null)" type can exist. textifying filters it.
		if(icon_filename_text)
			if(image_object.icon_state)
				sprite = icon(image_object.icon, image_object.icon_state)

			else // it means: icon_state=""
				if(!dmi_nullstate_checklist[icon_filename_text])
					dmi_nullstate_checklist[icon_filename_text] = ICON_STATE_CHECKED
					if(icon_exists(image_object.icon, ""))
						// this dmi has nullstate. We'll allow "icon_state=null" to show image.
						dmi_nullstate_checklist[icon_filename_text] = ICON_STATE_NULL

				if(dmi_nullstate_checklist[icon_filename_text] == ICON_STATE_NULL)
					sprite = icon(image_object.icon, image_object.icon_state)

	var/sprite_text
	if(sprite)
		hash = md5(sprite)
		src << browse_rsc(sprite, "vv[hash].png")
		sprite_text = no_icon ? "\[NO ICON\]" : "<img src='vv[hash].png'></td><td>"

	title = "[thing] ([REF(thing)]) = [type]"
	var/formatted_type = replacetext("[type]", "/", "<wbr>/")

	// Navigation history (Back / Forward / Recent) and quick links to related tools.
	var/history_html = ""
	if(holder)
		// Special lists cannot be found again through their reference, so they are not worth remembering.
		if(!islist || !isnull(locate(refid)))
			holder.vv_history_record(thing, islist ? "[type] ([length(thing)]) [refid]" : "[thing] ([type])", "[type]")
		history_html = holder.vv_history_html()

	var/list/quick_links = list()
	if(!islist)
		quick_links += VV_HREF_TARGETREF(refid, VV_HK_MARK, "Mark")
		quick_links += VV_HREF_TARGETREF(refid, VV_HK_CALLPROC, "Call Proc")
	if(isatom(thing))
		var/atom/atom_thing = thing
		var/turf/thing_turf = get_turf(atom_thing)
		if(thing_turf)
			quick_links += "<a href='byond://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[thing_turf.x];Y=[thing_turf.y];Z=[thing_turf.z]' title='Jump to its location'>Jump</a>"
		if(ismovable(atom_thing) && atom_thing.loc)
			quick_links += "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(atom_thing.loc)]' title='Open what contains it'>Loc</a>"
	if(ismob(thing))
		var/mob/mob_thing = thing
		quick_links += "<a href='byond://?_src_=holder;[HrefToken()];adminplayeropts=[refid]' title='Open the player panel for this mob'>Player Panel</a>"
		quick_links += "<a href='byond://?_src_=holder;[HrefToken()];adminplayerobservefollow=[refid]' title='Follow as a ghost'>Follow</a>"
		if(mob_thing.mind)
			quick_links += "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(mob_thing.mind)]' title='Open its mind'>Mind</a>"
		if(mob_thing.client)
			quick_links += "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(mob_thing.client)]' title='Open its client'>Client</a>"
	var/quick_html = length(quick_links) ? "<div class='vvquick'>[quick_links.Join(" &middot; ")]</div>" : ""

	var/list/header = islist ? list("<b>[is_alist ? "/alist" : "/list"]</b>") : thing.vv_get_header()

	var/ref_line = "@[copytext(refid, 2, -1)]" // get rid of the brackets, add a @ prefix for copy pasting in asay

	var/marked_line
	if(holder && holder.marked_datum && holder.marked_datum == thing)
		marked_line = VV_MSG_MARKED
	var/varedited_line
	if(!islist && (thing.datum_flags & DF_VAR_EDITED))
		varedited_line = VV_MSG_EDITED
	var/deleted_line
	if(!islist && thing.gc_destroyed)
		deleted_line = VV_MSG_DELETED

	var/list/dropdownoptions
	if (islist)
		dropdownoptions = list(
			"---",
			"Add Item" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ADD),
			"Remove Nulls" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_NULLS),
			"Remove Dupes" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_DUPES),
			"Set len" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SET_LENGTH),
			"Shuffle" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SHUFFLE),
			"Show VV To Player" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_EXPOSE),
			"---"
			)
		for(var/i in 1 to length(dropdownoptions))
			var/name = dropdownoptions[i]
			var/link = dropdownoptions[name]
			dropdownoptions[i] = "<option value[link? "='[link]'":""]>[name]</option>"
	else
		dropdownoptions = thing.vv_get_dropdown()

	var/list/names = list()
	if(!islist)
		for(var/varname in thing.vars)
			names += varname

	sleep(1 TICKS)

	var/list/variable_html = list()
	if(is_alist)
		// alists (ported from Azure Peak): walk by key, the row links carry the position
		var/alist/alist_value = thing
		var/alist_position = 0
		for(var/alist_key in alist_value)
			alist_position++
			variable_html += debug_variable(alist_key, alist_value[alist_key], 0, alist_value, alist_index = alist_position)
	else if(islist)
		var/list/list_value = thing
		for(var/i in 1 to list_value.len)
			var/key = list_value[i]
			var/value
			if(IS_NORMAL_LIST(list_value) && IS_VALID_ASSOC_KEY(key))
				value = list_value[key]
			variable_html += debug_variable(i, value, 0, list_value)
	else
		names = sortList(names)
		for(var/varname in names)
			if(thing.can_vv_get(varname))
				var/row_html = thing.vv_get_var(varname)
				// Flag variables that no longer hold the value their type starts with.
				var/current_value = thing.vars[varname]
				if(!islist(current_value) && !isdatum(current_value) && varname != "vars" && current_value != initial(thing.vars[varname]) && findtext(row_html, "<li") == 1)
					row_html = "<li class='vv-changed'[copytext(row_html, 4)]"
				variable_html += row_html

	var/html = {"
<html>
	<head>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		<title>[title]</title>
		<link rel="stylesheet" type="text/css" href="[SSassets.transport.get_asset_url("view_variables.css")]">
	</head>
	<body onload='selectTextField()' onkeydown='return handle_keydown()' onkeyup='handle_keyup()'>
		<script type="text/javascript">
			// onload
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastmode = getCookie("vvsearchmode");
				if (lastmode == 'name' || lastmode == 'value') {
					document.getElementById('search_mode').value = lastmode;
				}
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if (lastsearch) {
					filter_text.value = decodeURIComponent(lastsearch);
				}
				updateSearch();
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i];
					while (c.charAt(0) == ' ') c = c.substring(1,c.length);
					if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
				}
				return "";
			}

			// main search functionality
			// search_mode: "all" = name and value, "name" = variable names only, "value" = values only
			var last_state = null;
			function first_name_text(li) {
				var spans = li.getElementsByTagName('span');
				for (var i = 0; i < spans.length; ++i) {
					if (spans\[i].className == 'vn') return spans\[i].innerText;
				}
				return null;
			}
			function row_matches(li, filter, mode, changed_only) {
				if (changed_only && (' ' + li.className + ' ').indexOf(' vv-changed ') == -1) return false;
				if (!filter) return true;
				var text = li.innerText;
				if (mode != 'all') {
					var name = first_name_text(li);
					if (name !== null) {
						if (mode == 'name') {
							text = name;
						} else {
							var at = text.indexOf(name);
							text = at == -1 ? text : text.substr(at + name.length);
						}
					}
				}
				return text.toLowerCase().indexOf(filter) != -1;
			}
			function updateSearch() {
				var filter = document.getElementById('filter').value.toLowerCase();
				var mode = document.getElementById('search_mode').value;
				var changed_only = document.getElementById('changed_only').checked;
				var state = mode + '|' + (changed_only ? 1 : 0) + '|' + filter;
				if (state === last_state) {
					// An event triggered an update but nothing has changed.
					return;
				}
				var vars_ol = document.getElementById("vars");
				// Remove everything and put back what matches.
				while (vars_ol.hasChildNodes()) {
					vars_ol.removeChild(vars_ol.lastChild);
				}
				var shown = 0;
				for (var i = 0; i < complete_list.length; ++i) {
					try {
						var li = complete_list\[i];
						if (row_matches(li, filter, mode, changed_only)) {
							vars_ol.appendChild(li);
							shown++;
						}
					} catch(err) {}
				}
				document.getElementById('search_count').innerHTML = shown + ' of ' + complete_list.length;
				document.getElementById('search_empty').style.display = (shown || !complete_list.length) ? 'none' : 'block';

				last_state = state;
				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);
				document.cookie="vvsearchmode="+mode;
			}
			function clearSearch() {
				var filter_text = document.getElementById('filter');
				filter_text.value = '';
				updateSearch();
				filter_text.focus();
			}

			// onkeydown
			function handle_keydown() {
				if(event.keyCode == 116) {  //F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false);
					return false;
				}
				return true;
			}

			// onkeyup
			function handle_keyup() {
				updateSearch();
			}

			// onchange
			function handle_dropdown(list) {
				var value = list.options\[list.selectedIndex].value;
				if (value !== "") {
					location.href = value;
				}
				list.selectedIndex = 0;
				document.getElementById('filter').focus();
			}

			// byjax
			function replace_span(what) {
				var idx = what.indexOf(':');
				document.getElementById(what.substr(0, idx)).innerHTML = what.substr(idx + 1);
			}
		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[header.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							<br><b><font size='1'>[ref_line]</font></b>
							<span id='marked'>[marked_line]</span>
							<span id='varedited'>[varedited_line]</span>
							<span id='deleted'>[deleted_line]</span>
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<div class='vvnav'>[history_html]</div>
							<a id='refresh_link' class='vvbtn' href='byond://?_src_=vars;
datumrefresh=[refid];[HrefToken()]' title='Reload this window (F5)'>Refresh</a>
							[quick_html]
							<form>
								<select name="file" size="1"
									onchange="handle_dropdown(this)"
									onmouseclick="this.focus()">
									<option value selected>Select option</option>
									[dropdownoptions.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
			<span class='vt'>type</span> after a name is the kind of value it holds. <span class='vv-changed'><span class='vn'>Highlighted names</span></span> differ from the type's starting value.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='12%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
				<td width='1%' nowrap>
					<select id='search_mode' onchange='updateSearch()' title='What the search looks at'>
						<option value='all' selected>Names &amp; values</option>
						<option value='name'>Names only</option>
						<option value='value'>Values only</option>
					</select>
					<a class='vvbtn' href='#' onclick='clearSearch(); return false;' title='Clear the search'>Clear</a>
				</td>
			</tr>
			<tr>
				<td></td>
				<td colspan='2'>
					<font size='1'>
						<label title='Only variables that differ from the starting value of the type'><input type='checkbox' id='changed_only' onclick='updateSearch()'> Changed only</label>
						&nbsp; Showing <span id='search_count'></span>
					</font>
				</td>
			</tr>
		</table>
		<hr>
		<div id='search_empty' class='vvempty'>Nothing matches the search. Try "Names &amp; values", or clear it.</div>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var complete_list = \[\];
			var lis = document.getElementById("vars").children;
			for(var i = lis.length; i--;) complete_list\[i\] = lis\[i\];
		</script>
	</body>
</html>
"}
	src << browse(html, "window=variables[refid];size=475x650")

/client/proc/vv_update_display(datum/D, span, content)
	src << output("[span]:[content]", "variables[REF(D)].browser:replace_span")

#undef ICON_STATE_CHECKED
#undef ICON_STATE_NULL

/**
 * The small picture at the top of a VV window.
 *
 * getFlatIcon() blends every overlay, and without no_anim it does so for every animation frame:
 * on an animated turf or a dressed mob that alone could stall the server for a long moment.
 * One frame is enough for a preview, and atoms with a pile of overlays only show their base icon.
 */
/proc/vv_preview_icon(atom/thing)
	if(length(thing.overlays) + length(thing.underlays) > 30)
		if(!thing.icon)
			return null
		return icon(thing.icon, thing.icon_state, thing.dir, 1)
	return getFlatIcon(thing, no_anim = TRUE)
