/**
 * View Variables support for alists (BYOND 516 associative lists).
 *
 * Ported from Azure Peak (https://github.com/Azure-Peak/Azure-Peak, commit 5c720fe6, AGPL-3.0),
 * code/modules/admin/view_variables/modify_variables.dm and topic_list.dm.
 * alists are strictly key/value and cannot be addressed by a numeric index, so the edit links
 * of an alist row carry the position of the entry and it is resolved back to its key here.
 */

/client/proc/vv_do_alist(alist/target, href_list, enum_index)
	if(!check_rights(R_VAREDIT))
		return
	if(enum_index)
		if(href_list[VV_HK_LIST_EDIT])
			mod_alist(target, null, "alist", "contents", enum_index, autodetect_class = TRUE)
		if(href_list[VV_HK_LIST_CHANGE])
			mod_alist(target, null, "alist", "contents", enum_index, autodetect_class = FALSE)
		if(href_list[VV_HK_LIST_REMOVE])
			var/key = index_alist_key(target, enum_index)
			if(isnull(key))
				to_chat(src, "That alist entry no longer exists.")
				return
			var/value = target[key]
			if(alert(src, "Remove entry \[[key]] = [value] from alist?", "Confirm", "Yes", "No") != "Yes")
				return
			target.Remove(key)
			log_world("### alistVarEdit by [src]: /alist contents: REMOVED key=[html_encode("[key]")]")
			log_admin("[key_name(src)] modified alist contents: REMOVED key=[key]")
			message_admins("[key_name_admin(src)] modified alist contents: REMOVED key=[key]")
	if(href_list[VV_HK_LIST_ADD])
		mod_alist_add(target, null, "alist", "contents")
	if(href_list[VV_HK_LIST_ERASE_NULLS])
		var/list/to_remove = list()
		for(var/key in target)
			if(isnull(target[key]))
				to_remove += list(key)
		for(var/key in to_remove)
			target.Remove(key)
		log_world("### alistVarEdit by [src]: /alist contents: CLEAR NULLS ([to_remove.len])")
		log_admin("[key_name(src)] modified alist contents: CLEAR NULLS ([to_remove.len])")
		message_admins("[key_name_admin(src)] modified alist contents: CLEAR NULLS ([to_remove.len])")
	if(href_list[VV_HK_LIST_ERASE_DUPES] || href_list[VV_HK_LIST_SET_LENGTH] || href_list[VV_HK_LIST_SHUFFLE])
		to_chat(src, "That operation isn't supported on alists (keys are unique and unordered).")

/proc/index_alist_key(alist/A, index)
	if(index < 1)
		return null
	var/i = 0
	for(var/key in A)
		i++
		if(i == index)
			return key
	return null

/client/proc/mod_alist(alist/A, datum/O, original_name, objectvar, enum_index, autodetect_class = FALSE)
	if(!check_rights(R_VAREDIT))
		return
	if(!istype(A, /alist))
		to_chat(src, "Not an alist.")
		return
	var/key = index_alist_key(A, enum_index)
	if(isnull(key))
		to_chat(src, "That alist entry no longer exists.")
		return
	var/current_value = A[key]

	var/prompt = alert(src, "Edit the entry's key or its associated value?", "Alist Entry", "Value", "Key", "Cancel")
	if(prompt == "Cancel" || !prompt)
		return

	if(prompt == "Key")
		var/list/KK = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT, VV_NULL), var_name = objectvar)
		if(!KK["class"])
			return
		var/new_key = KK["value"]
		if(isnull(new_key))
			to_chat(src, "Alist keys can't be null.")
			return
		if(new_key == key)
			return
		if(new_key in A)
			if(alert(src, "Key \[[new_key]] already exists and will be overwritten. Continue?", "Confirm", "Yes", "No") != "Yes")
				return
		if(!(key in A)) // the prompts wait for input: the entry may be gone, or changed, by now
			to_chat(src, "That alist entry no longer exists.")
			return
		current_value = A[key]
		A.Remove(key)
		A[new_key] = current_value
		log_world("### alistVarEdit by [src]: [(O ? O.type : "/alist")] [objectvar]: KEY [html_encode("[key]")] => [html_encode("[new_key]")]")
		log_admin("[key_name(src)] modified [original_name]'s [objectvar]: KEY [key] => [new_key]")
		message_admins("[key_name_admin(src)] modified [original_name]'s [objectvar]: KEY [key] => [new_key]")
		return

	var/default = vv_get_class(objectvar, current_value)
	to_chat(src, "Variable appears to be <b>[uppertext(default)]</b>.")
	to_chat(src, "Variable contains: [current_value]")
	var/class
	if(autodetect_class && default != VV_NULL)
		if(default == VV_TEXT)
			default = VV_MESSAGE
		class = default
	var/list/LL = vv_get_value(class, default, current_value, restricted_classes = list(VV_RESTORE_DEFAULT))
	class = LL["class"]
	if(!class)
		return
	var/new_value = LL["value"]
	if(class == VV_MESSAGE)
		class = VV_TEXT
	if(class == VV_TEXT)
		var/list/varsvars = vv_parse_text(O, new_value)
		for(var/V in varsvars)
			new_value = replacetext(new_value, "\[[V]]", "[O.vars[V]]")
	if(!(key in A)) // removed while the prompt waited: do not add it back
		to_chat(src, "That alist entry no longer exists.")
		return
	A[key] = new_value
	log_world("### alistVarEdit by [src]: [(O ? O.type : "/alist")] [objectvar]: \[[html_encode("[key]")]] => [html_encode("[new_value]")]")
	log_admin("[key_name(src)] modified [original_name]'s [objectvar]: [key] => [new_value]")
	message_admins("[key_name_admin(src)] modified [original_name]'s [objectvar]: [key] => [new_value]")

/client/proc/mod_alist_add(alist/A, datum/O, original_name, objectvar)
	if(!check_rights(R_VAREDIT))
		return
	if(!istype(A, /alist))
		to_chat(src, "Not an alist.")
		return
	to_chat(src, "Choose the new entry's KEY:")
	var/list/KK = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT, VV_NULL))
	if(!KK["class"])
		return
	var/new_key = KK["value"]
	if(isnull(new_key))
		to_chat(src, "Alist keys can't be null.")
		return
	if(new_key in A)
		if(alert(src, "Key \[[new_key]] already exists and will be overwritten. Continue?", "Confirm", "Yes", "No") != "Yes")
			return
	to_chat(src, "Choose the new entry's VALUE:")
	var/list/VAL = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
	if(!VAL["class"])
		return
	var/new_value = VAL["value"]
	if(VAL["class"] == VV_TEXT || VAL["class"] == VV_MESSAGE)
		var/list/varsvars = vv_parse_text(O, new_value)
		for(var/V in varsvars)
			new_value = replacetext(new_value, "\[[V]]", "[O.vars[V]]")
	A[new_key] = new_value
	log_world("### alistVarEdit by [src]: [(O ? O.type : "/alist")] [objectvar]: ADDED \[[html_encode("[new_key]")]] = [html_encode("[new_value]")]")
	log_admin("[key_name(src)] modified [original_name]'s [objectvar]: ADDED [new_key]=[new_value]")
	message_admins("[key_name_admin(src)] modified [original_name]'s [objectvar]: ADDED [new_key]=[new_value]")
