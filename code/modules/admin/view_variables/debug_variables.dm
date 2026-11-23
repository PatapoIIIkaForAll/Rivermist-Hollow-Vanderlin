#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/// Get displayed variable in VV variable list
/proc/debug_variable(name, value, level, datum/owner, sanitize = TRUE, display_flags = NONE, alist_index) //if D is a list, name will be index, and value will be assoc value.
	if(owner)
		if(islist(owner))
			var/list/list_owner = owner
			var/index = name
			if(!isnull(alist_index))
				// alist row (ported from Azure Peak): name is the real key and value the real value,
				// the edit links carry the position of the entry instead of a list index
				index = alist_index
			else if (isnull(value))
				value = list_owner[name]
			else
				name = list_owner[name] //name is really the index until this line
			. = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(owner, VV_HK_LIST_EDIT, "E", index)]) ([VV_HREF_TARGET_1V(owner, VV_HK_LIST_CHANGE, "C", index)]) ([VV_HREF_TARGET_1V(owner, VV_HK_LIST_REMOVE, "-", index)]) "
		else
			. = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_EDIT, "E", name)]) ([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_CHANGE, "C", name)]) ([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_MASSEDIT, "M", name)]) "
	else
		. = "<li>"

	var/name_part = VV_HTML_ENCODE(name)
	if(level > 0 || islist(owner)) //handling keys in assoc lists
		if(istype(name,/datum))
			name_part = "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(name)]'>[VV_HTML_ENCODE(name)] [REF(name)]</a>"
		else if(islist(name))
			var/list/list_value = name
			name_part = "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(name)]'> /list ([length(list_value)]) [REF(name)]</a>"

	// vn = variable name (the VV search can look at names only), vt = short type tag of the value
	. = "[.]<span class='vn'>[name_part]</span>[level ? "" : " <span class='vt'>[vv_type_tag(value)]</span>"] = "

	var/item = _debug_variable_value(name, value, level, owner, sanitize, display_flags)

	return "[.][item]</li>"

/// Short, human readable type of a value, shown next to the variable name in VV.
/proc/vv_type_tag(value)
	if(isnull(value))
		return "null"
	if(isnum(value))
		return "num"
	if(istext(value))
		return "text"
	if(ispath(value))
		return "path"
	if(islist(value))
		return "list"
	if(isicon(value))
		return "icon"
	if(isfile(value))
		return "file"
	if(ismob(value))
		return "mob"
	if(isobj(value))
		return "obj"
	if(isturf(value))
		return "turf"
	if(isarea(value))
		return "area"
	if(istype(value, /client))
		return "client"
	if(isdatum(value))
		return "datum"
	return "other"

// This is split into a separate proc mostly to make errors that happen not break things too much
/proc/_debug_variable_value(name, value, level, datum/owner, sanitize, display_flags)
	if(isappearance(value))
		value = get_vv_appearance(value)

	. = "<font color='red'>DISPLAY_ERROR:</font> ([value] [REF(value)])" // Make sure this line can never runtime

	if(isnull(value))
		return "<span class='value'>null</span>"

	if(istext(value))
		return "<span class='value'>\"[VV_HTML_ENCODE(value)]\"</span>"

	if(isicon(value))
		#ifdef VARSICON
		var/icon/icon_value = icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp[REF(icon_value)][rnd].png"
		usr << browse_rsc(icon_value, rname)
		return "(<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
		#else
		return "/icon (<span class='value'>[value]</span>)"
		#endif

	if(isfilter(value))
		var/datum/filter_value = value
		return "/filter (<span class='value'>[filter_value.type] [REF(filter_value)]</span>)"

	if(isfile(value))
		return "<span class='value'>'[value]'</span>"

	if(isdatum(value))
		var/datum/datum_value = value
		return datum_value.debug_variable_value(name, level, owner, sanitize, display_flags)

	if(istype(value, /alist)) // key/value only, cannot be walked by index
		var/alist/alist_value = value
		var/alist_length = length(alist_value)
		var/alist_link = "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(value)]'>/alist ([alist_length])</a>"
		if((display_flags & VV_ALWAYS_CONTRACT_LIST) || !alist_length || alist_length > VV_NORMAL_LIST_NO_EXPAND_THRESHOLD)
			return alist_link
		var/list/alist_items = list()
		for(var/alist_key in alist_value)
			alist_items += debug_variable(alist_key, alist_value[alist_key], level + 1, sanitize = sanitize)
		return "[alist_link]<ul>[alist_items.Join()]</ul>"

	if(islist(value) || (name in GLOB.vv_special_lists)) // Some special lists aren't detectable as a list through istype
		var/list/list_value = value
		var/list/items = list()

		// This is because some lists either don't count as lists or a locate on their ref will return null
		var/link_vars = "Vars=[REF(value)]"
		if(name in GLOB.vv_special_lists)
			link_vars = "Vars=[REF(owner)];special_varname=[name]"

		var/list_length = length(list_value)
		if (!(display_flags & VV_ALWAYS_CONTRACT_LIST) && list_length > 0 && list_length <= (IS_NORMAL_LIST(list_value) ? VV_NORMAL_LIST_NO_EXPAND_THRESHOLD : VV_SPECIAL_LIST_NO_EXPAND_THRESHOLD))
			for (var/i in 1 to list_length)
				var/key = list_value[i]
				var/val
				if (IS_NORMAL_LIST(list_value) && !isnum(key))
					val = list_value[key]
				if (isnull(val)) // we still want to display non-null false values, such as 0 or ""
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			return "<a href='byond://?_src_=vars;[HrefToken()];[link_vars]'>/list ([list_length])</a><ul>[items.Join()]</ul>"
		return "<a href='byond://?_src_=vars;[HrefToken()];[link_vars]'>/list ([list_length])</a>"

	// if it's a number, is it a bitflag?
	var/list/valid_bitflags
	if(!isnum(name))
		valid_bitflags = get_valid_bitflags(name)

	if(!length(valid_bitflags))
		return "<span class='value'>[VV_HTML_ENCODE(value)]</span>"

	var/list/flags = list()
	for (var/bit_name in valid_bitflags)
		if (value & valid_bitflags[bit_name])
			flags += bit_name
	if(length(flags))
		return "[VV_HTML_ENCODE(flags.Join(", "))]"
	return "NONE"

/datum/proc/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	if("[src]" != "[type]") // If we have a name var, let's use it.
		return "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(src)]'>[src] [type] [REF(src)]</a>"
	else
		return "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(src)]'>[type] [REF(src)]</a>"

/datum/weakref/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	. = ..()
	return "[.] <a href='byond://?_src_=vars;[HrefToken()];Vars=[reference]'>(Resolve)</a>"

/matrix/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	return {"<span class='value'>
			<table class='matrixbrak'><tbody><tr><td class='lbrak'>&nbsp;</td><td>
			<table class='matrix'>
			<tbody>
				<tr><td>[a]</td><td>[d]</td><td>0</td></tr>
				<tr><td>[b]</td><td>[e]</td><td>0</td></tr>
				<tr><td>[c]</td><td>[f]</td><td>1</td></tr>
			</tbody>
			</table></td><td class='rbrak'>&nbsp;</td></tr></tbody></table></span>"} //TODO link to modify_transform wrapper for all matrices

#undef VV_HTML_ENCODE
