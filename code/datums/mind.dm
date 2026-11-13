GLOBAL_LIST_EMPTY(personal_objective_minds)

/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transferring the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mind for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/**
 * The mind datum.
 *		Minds now represent IC characters rather than following a client around constantly.
 * Guidelines for using minds properly:
 ** Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
	ghost.mind is however used as a reference to the ghost's corpse

 ** When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
	the existing mind of the old mob should be transfered to the new mob like so:
 *** mind.transfer_to(new_mob)

 ** You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
	By setting key or ckey explicitly after transferring the mind with transfer_to you will cause bugs like DCing
	the player.

 ** IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

 ** When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
	a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.
 *** new_mob.key = key

 ** The Login proc will handle making a new mind for that mobtype (including setting up stuff like mind.name). Simple!
	However if you want that mind to have any special properties like being a traitor etc you will have to do that
	yourself.
*/
/datum/mind
	/// ckey of the mind
	var/key
	/// original name of their mob
	var/name
	/// The GLOB.chosen_names entry of this character's body; a body remade for this mind keeps it.
	var/reserved_name
	/// replaced name for observers name if set
	var/ghostname
	/// the current mob this mind is residing in
	var/mob/living/current
	///the ghost we currently have
	var/mob/dead/observer/current_ghost
	/// is this mind datum currently linked to a client?
	var/active = FALSE
	/// the memory of this mind
	var/memory
	/// Job datum indicating the mind's role. This should always exist after initialization, as a reference to a singleton.
	var/datum/job/assigned_role
	/// special role of this mind
	var/special_role
	/// list of roles this mind cannot roll
	var/list/restricted_roles = list()

	var/linglink
	var/datum/martial_art/martial_art
	var/static/default_martial_art = new/datum/martial_art
	var/miming = 0 // Mime's vow of silence
	/// all antag datumsa applied to this mind
	var/list/antag_datums
	/// the icon_state of the antag_hud
	var/antag_hud_icon_state = null
	/// this mind's antag hud
	var/datum/atom_hud/antag/antag_hud = null
	var/damnation_type = 0
	/// who owns the soul.  Under normal circumstances, this will point to src
	var/datum/mind/soulOwner
	/// If false, renders the character unable to sell their soul.
	var/hasSoul = TRUE
	/// is this person a chaplain or admin role allowed to use bibles
	var/isholy = FALSE
	/// If this mind's master is another mob (i.e. adamantine golems)
	var/mob/living/enslaved_to
	/// language holder datum
	var/datum/language_holder/language_holder
	/// boolean, is this mind unconvertable by conversion antags?
	var/unconvertable = FALSE
	/// did this mind use the late join button?
	var/late_joiner = FALSE
	/// time of the last death of the mob this mind controlled
	var/last_death = 0
	/// Cached at death and consumed on the next rune revival.
	var/pending_resurrection_trauma_type = null
	var/pending_resurrection_trauma_name = null

	var/force_escaped = FALSE  // Set by Into The Sunset command of the shuttle manipulator

	///List of learned recipe TYPES.
	var/list/learned_recipes
	var/list/special_items = list()

	var/list/areas_entered = list()

	/// Social relationships and remembered identities for this character.
	var/list/relations = list()

	var/list/notes = list() //RTD add notes button

	//assoc list of frumentarii you know of to a BOOL of if they are still frumentarii
	var/list/cached_frumentarii = list()

	var/datum/sleep_adv/sleep_adv = null

	/// List of personal objectives not tied to the antag roles
	var/list/personal_objectives = list()

	var/has_studied = FALSE
	/// Variable that lets the event picker see if someones getting chosen or not
	var/picking = FALSE

/datum/mind/New(key)
	src.key = key
	soulOwner = src
	martial_art = default_martial_art
	set_assigned_role(SSjob.GetJobType(/datum/job/unassigned))
	sleep_adv = new /datum/sleep_adv(src)

/datum/mind/Destroy()
	SSticker.minds -= src
	forget_and_be_forgotten()
	if(current)
		UnregisterSignal(current, COMSIG_MOB_DEATH)
		if(current.mind == src)
			current.mind = null
		if(iscarbon(current))
			var/mob/living/carbon/body = current
			if(body.last_mind == src)
				body.last_mind = null
	remove_all_uis()
	QDEL_LIST_ASSOC_VAL(active_uis)
	active_uis = null
	QDEL_NULL(sleep_adv)
	if(islist(antag_datums))
		QDEL_LIST(antag_datums)
	current = null
	current_ghost = null
	assigned_role = null
	soulOwner = null
	enslaved_to = null
	language_holder = null
	return ..()

/proc/get_minds(role)
	. = list()
	for(var/datum/mind/M in SSticker.minds)
		var/is_role = TRUE
		if(role)
			is_role = FALSE
			if(M.special_role == role)
				is_role = TRUE
			else
				if(M.assigned_role.title == role)
					is_role = TRUE
		if(is_role)
			. += M

/// Returns this mind's relation of the requested type toward target.
/datum/mind/proc/get_relation(datum/mind/target, relation_type = /datum/relation)
	for(var/datum/relation/relation in relations)
		if(relation.other == target && istype(relation, relation_type))
			return relation
	return null

/// Returns TRUE when this mind remembers target through any relationship.
/datum/mind/proc/knows(datum/mind/target)
	for(var/datum/relation/relation in relations)
		if(relation.other == target)
			return TRUE
	return FALSE

/datum/mind/proc/knows_as(datum/mind/target, relation_type)
	return !isnull(get_relation(target, relation_type))

/// Returns gossip this character has actually learned about target.
/datum/mind/proc/get_gossip_about(datum/mind/target)
	. = list()
	if(!target)
		return
	for(var/datum/relation/relation in relations)
		if(relation.other != target)
			continue
		for(var/datum/history/gossip/gossip in relation.relation_history)
			. += gossip

/// Establishes a relationship. Symmetric types receive a linked mirror entry.
/datum/mind/proc/add_relation(datum/mind/target, relation_type)
	if(!target || target == src || !ispath(relation_type, /datum/relation))
		return null

	var/datum/relation/template = new relation_type()
	var/datum/relation/existing = get_relation(target, relation_type)
	if(existing && existing.type == relation_type)
		qdel(template)
		return existing

	var/list/source_to_dissolve = list()
	var/list/target_to_dissolve = list()
	var/list/source_history
	var/list/target_history
	var/list/source_snapshot
	var/list/target_snapshot
	for(var/datum/relation/relation in relations)
		if(relation.other != target || !template.upgrades_relation(relation))
			continue
		if(length(relation.relation_history))
			LAZYINITLIST(source_history)
			source_history += relation.relation_history
			relation.relation_history = null
		if(relation.snapshot && !source_snapshot)
			source_snapshot = relation.snapshot.Copy()
		source_to_dissolve += relation
	if(template.symmetric)
		for(var/datum/relation/relation in target.relations)
			if(relation.other != src || !template.upgrades_relation(relation))
				continue
			if(length(relation.relation_history))
				LAZYINITLIST(target_history)
				target_history += relation.relation_history
				relation.relation_history = null
			if(relation.snapshot && !target_snapshot)
				target_snapshot = relation.snapshot.Copy()
			target_to_dissolve += relation
	for(var/datum/relation/relation in source_to_dissolve)
		if(!QDELETED(relation))
			relation.dissolve(FALSE)
	for(var/datum/relation/relation in target_to_dissolve)
		if(!QDELETED(relation))
			relation.dissolve(FALSE)

	for(var/datum/relation/relation in relations)
		if(relation.other == target && (template.conflicts_with(relation) || relation.conflicts_with(template)))
			qdel(template)
			return null
	for(var/datum/relation/relation in target.relations)
		if(relation.other == src && (template.conflicts_with(relation) || relation.conflicts_with(template)))
			qdel(template)
			return null

	template.holder = src
	template.other = target
	template.snapshot = source_snapshot
	if(source_history)
		template.relation_history = source_history
	template.refresh_snapshot()
	relations += template

	if(template.symmetric)
		var/datum/relation/mirror = new relation_type()
		mirror.holder = target
		mirror.other = src
		mirror.snapshot = target_snapshot
		if(target_history)
			mirror.relation_history = target_history
		mirror.refresh_snapshot()
		target.relations += mirror
		template.counterpart = mirror
		mirror.counterpart = template
		template.on_created()
		mirror.on_created()
	else
		template.on_created()

	return template

/datum/mind/proc/remove_relations_with(datum/mind/target, record_history = FALSE)
	var/list/to_remove = list()
	for(var/datum/relation/relation in relations)
		if(relation.other == target)
			to_remove += relation
	for(var/datum/relation/relation in to_remove)
		relation.dissolve(record_history)

/datum/mind/proc/clear_all_relations()
	while(length(relations))
		var/datum/relation/relation = relations[1]
		relation.dissolve(FALSE)
	relations = list()

/// Refreshes every remembered snapshot of this character.
/datum/mind/proc/broadcast_identity_update()
	for(var/datum/mind/observer in SSticker.minds)
		for(var/datum/relation/relation in observer.relations)
			if(relation.other == src)
				relation.refresh_snapshot()

/datum/mind/proc/display_relations(mob/user)
	if(!user)
		return
	if(!length(relations))
		to_chat(user, span_notice("[name] doesn't know anyone yet."))
		return
	var/datum/tgui_relations/menu = new(src)
	menu.ui_interact(user)

/// Gives our identity to a target mind, and gives theirs to us.
/datum/mind/proc/share_identities(datum/mind/target_mind)
	if(!target_mind || target_mind == src)
		return
	learn_target_identity(target_mind)
	give_source_identity(target_mind)

/datum/mind/proc/learn_target_identity(datum/mind/target_mind)
	if(!target_mind || target_mind == src)
		return
	var/found = FALSE
	for(var/datum/relation/relation in relations)
		if(relation.other == target_mind)
			relation.refresh_snapshot()
			found = TRUE
	if(!found)
		_ensure_acquaintance(target_mind)

/datum/mind/proc/give_source_identity(datum/mind/target_mind)
	if(!target_mind || target_mind == src)
		return
	var/found = FALSE
	for(var/datum/relation/relation in target_mind.relations)
		if(relation.other == src)
			relation.refresh_snapshot()
			found = TRUE
	if(!found)
		target_mind._ensure_acquaintance(src)

/datum/mind/proc/_ensure_acquaintance(datum/mind/target_mind)
	if(!target_mind || target_mind == src || knows(target_mind))
		return
	var/datum/relation/acquaintance/acquaintance = new()
	acquaintance.holder = src
	acquaintance.other = target_mind
	acquaintance.refresh_snapshot()
	relations += acquaintance
	acquaintance.on_created()
	return acquaintance

/datum/mind/proc/do_i_know(datum/mind/person, name)
	if(person)
		return knows(person)
	if(name)
		for(var/datum/relation/relation in relations)
			if(relation.snapshot && names_match(relation.snapshot["name"], name))
				return TRUE
	return FALSE

/proc/names_match(name_a, name_b)
	if(!name_a || !name_b)
		return FALSE
	return LOWER_TEXT(trim(html_decode("[name_a]"))) == LOWER_TEXT(trim(html_decode("[name_b]")))

/datum/mind/proc/forget_source_identity(datum/mind/person)
	if(!person || person == src)
		return
	var/list/to_remove = list()
	for(var/datum/relation/relation in person.relations)
		if(relation.other == src)
			to_remove += relation
	for(var/datum/relation/relation in to_remove)
		relation.dissolve(FALSE)

/datum/mind/proc/forget_and_be_forgotten()
	if(SSticker)
		for(var/datum/mind/observer in SSticker.minds)
			if(observer != src)
				forget_source_identity(observer)
	clear_all_relations()

/// returns the language holder of this mind
/datum/mind/proc/get_language_holder()
	if(!language_holder)
		var/datum/language_holder/L = current.get_language_holder(shadow=FALSE)
		language_holder = L.copy(src)

	return language_holder

/// transfers this mind's control to a new mob
/datum/mind/proc/transfer_to(mob/new_character, force_key_move = 0)
	if(current)	// remove ourself from our old body's mind variable
		current.mind = null
		UnregisterSignal(current, COMSIG_MOB_DEATH)
		SStgui.on_transfer(current, new_character)

	if(!language_holder)
		var/datum/language_holder/mob_holder = new_character.get_language_holder(shadow = FALSE)
		language_holder = mob_holder.copy(src)

	if(key)
		if(new_character.key != key)					//if we're transferring into a body with a key associated which is not ours
			if(new_character.key)
				new_character.ghostize(1)						//we'll need to ghostize so that key isn't mobless.
	else
		key = new_character.key

	if(new_character.mind)								//disassociate any mind currently in our new body's mind variable
		new_character.mind.current = null

	var/datum/atom_hud/antag/hud_to_transfer = antag_hud//we need this because leave_hud() will clear this list
	var/mob/living/old_current = current
	if(current)
		current.transfer_observers_to(new_character)	//transfer anyone observing the old character to the new one
	current = new_character								//associate ourself with our new body
	new_character.mind = src							//and associate our new body with ourself
	for(var/datum/antagonist/antag_datum_ref in antag_datums)	//Makes sure all antag datums effects are applied in the new body
		antag_datum_ref.on_body_transfer(old_current, current)
	if(iscarbon(current))
		var/mob/living/carbon/C = current
		C.last_mind = src
	transfer_antag_huds(hud_to_transfer)				//inherit the antag HUD
	transfer_martial_arts(current)

	RegisterSignal(current, COMSIG_MOB_DEATH, PROC_REF(set_death_time))
	if(active || force_key_move)
		current.key = key		//now transfer the key to link the client to our new body
	current.refresh_erp_preference_cache()
	current.update_fov_angles()

	SEND_SIGNAL(src, COMSIG_MIND_TRANSFERRED, old_current)
	SEND_SIGNAL(current, COMSIG_MOB_MIND_TRANSFERRED_INTO, old_current)
	if(!isnull(old_current))
		SEND_SIGNAL(old_current, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF, current)

/// set the last_death time of a mind to the current world time
/datum/mind/proc/set_death_time()
	last_death = world.time

/**
 * add a new memory to a mind
 * Vars:
 ** new_text - text to add
*/
/datum/mind/proc/store_memory(new_text)
	var/newlength = length(memory) + length(new_text)
	if (newlength > MAX_MESSAGE_LEN * 100)
		memory = copytext(memory, -newlength-MAX_MESSAGE_LEN * 100)
	memory += "[new_text]<BR>"

/// wipes the memory of a mind
/datum/mind/proc/wipe_memory()
	memory = null

// Datum antag mind procs

/**
 * adds an antag datum to a mind
 * Vars:
 ** datum_type_or_instance - antag datum type to add
 ** team - which team this antag datum is linked to
*/
/datum/mind/proc/add_antag_datum(datum_type_or_instance, team)
	if(!datum_type_or_instance)
		CRASH("add_antag_datum was called without an antag datum type!")
	var/datum/antagonist/antag_datum_ref
	if(!ispath(datum_type_or_instance))
		antag_datum_ref = datum_type_or_instance
		if(!istype(antag_datum_ref))
			CRASH("add_antag_datum was passed an invalid antag datum!")
	else
		antag_datum_ref = new datum_type_or_instance()
	//Choose snowflake variation if antagonist handles it
	var/datum/antagonist/antag_datum = antag_datum_ref.specialization(src)
	if(antag_datum && antag_datum != antag_datum_ref)
		qdel(antag_datum_ref)
		antag_datum_ref = antag_datum
	if(!antag_datum_ref.can_be_owned(src))
		qdel(antag_datum_ref)
		return
	antag_datum_ref.owner = src
	LAZYADD(antag_datums, antag_datum_ref)
	antag_datum_ref.create_team(team)
	var/datum/team/antag_team = antag_datum_ref.get_team()
	if(antag_team)
		antag_team.add_member(src)
	INVOKE_ASYNC(antag_datum_ref, TYPE_PROC_REF(/datum/antagonist, on_gain))
	log_game("[key_name(src)] has gained antag datum [antag_datum_ref.name]([antag_datum_ref.type])")
	var/client/picked_client = src.current?.client
	picked_client?.mob?.mind.picking = FALSE
	return antag_datum_ref

/**
 * remove an antag datum from a mind
 * Vars:
 ** datum_type - the type of antag datum to remove
*/
/datum/mind/proc/remove_antag_datum(datum_type)
	if(!datum_type)
		return
	var/datum/antagonist/antag_datum_ref = has_antag_datum(datum_type)
	if(antag_datum_ref)
		antag_datum_ref.on_removal()
		return TRUE

/// removes all antag datums from a mind
/datum/mind/proc/remove_all_antag_datums() //For the Lazy amongst us.
	for(var/datum/antagonist/antag_datum_ref as anything in antag_datums)
		antag_datum_ref.on_removal()

/**
 * remove an antag datum from a mind
 * Vars:
 ** datum_type - the type of antag datum to remove
 ** check_subtypes - boolean, check if we count subtypes of the antag datum as TRUE
*/
/datum/mind/proc/has_antag_datum(datum_type, check_subtypes = TRUE)
	if(!datum_type)
		CRASH("has_antag_datum was called without an antag datum specified!")
	for(var/datum/antagonist/antag_datum_ref as anything in antag_datums)
		if(check_subtypes && istype(antag_datum_ref, datum_type))
			return antag_datum_ref
		else
			if(istype(antag_datum_ref))
				if(antag_datum_ref.type == datum_type)
					return antag_datum_ref

/// Boolean. Returns true if all antag datums are actually "good", false otherwise.
/datum/mind/proc/isactuallygood()
	var/is_good_guy = TRUE
	for(var/datum/antagonist/GG in antag_datums)
		is_good_guy &&= GG.isgoodguy
	return is_good_guy

/**
 * Link a new mobs mind to the creator of said mob. They will join any team they are currently on, and will only switch teams when their creator does.
 * Vars:
 ** creator - who to enslave to
*/
/datum/mind/proc/enslave_mind_to_creator(mob/living/creator)
	enslaved_to = creator

	APPLY_FACTION_AND_ALLIES_FROM(current, creator)
	APPLY_FACTION_AND_ALLIES_FROM(creator, current)

	if(creator.mind.special_role)
		message_admins("[ADMIN_LOOKUPFLW(current)] has been created by [ADMIN_LOOKUPFLW(creator)], an antagonist.")
		to_chat(current, span_danger("Despite my creators current allegiances, my true master remains [creator.real_name]. If their loyalties change, so do yours. This will never change unless my creator's body is destroyed."))

/// Output all memories of a mind
/datum/mind/proc/show_memory(mob/recipient, window = TRUE)
	if(!recipient)
		recipient = current
	var/name_display = "My"
	if(current?.real_name)
		name_display = "[current.real_name]'s"

	var/output = memory

	if(ishuman(current))
		var/mob/living/carbon/human/human_current = current
		if(length(human_current.culinary_preferences))
			var/favourite_food = human_current.culinary_preferences[CULINARY_FAVOURITE_FOOD]
			var/favourite_drink = human_current.culinary_preferences[CULINARY_FAVOURITE_DRINK]
			var/hated_food = human_current.culinary_preferences[CULINARY_HATED_FOOD]
			var/hated_drink = human_current.culinary_preferences[CULINARY_HATED_DRINK]

			if(favourite_food)
				var/obj/item/food_instance = favourite_food
				output += "<br><b>Favourite Food:</b> [capitalize(initial(food_instance.name))]<br>"
			if(favourite_drink)
				var/datum/reagent/consumable/drink_instance = favourite_drink
				output += "<b>Favourite Drink:</b> [capitalize(initial(drink_instance.name))]<br>"
			if(hated_food)
				var/obj/item/hated_food_instance = hated_food
				output += "<b>Hated Food:</b> [capitalize(initial(hated_food_instance.name))]<br>"
			if(hated_drink)
				var/datum/reagent/consumable/hated_drink_instance = hated_drink
				output += "<b>Hated Drink:</b> [capitalize(initial(hated_drink_instance.name))]<br>"

	var/has_personal_objectives = FALSE
	var/personal_output = ""
	if(length(personal_objectives))
		var/personal_count = 1
		for(var/datum/objective/personal/objective in personal_objectives)
			if(objective.hidden)
				continue
			if(!has_personal_objectives)
				has_personal_objectives = TRUE
				personal_output += "<br><B>Personal Objectives:</B>"
			personal_output += "<br><B>Personal Goal #[personal_count]</B>: [objective.explanation_text][objective.completed ? " (COMPLETED)" : ""]"
			personal_count++
		if(has_personal_objectives)
			personal_output += "<br>"

	output += personal_output

	var/list/all_objectives = list()
	var/has_antag_objectives = FALSE
	var/antag_output = ""

	for(var/datum/antagonist/antag_datum_ref in antag_datums)
		output += antag_datum_ref.antag_memory
		all_objectives |= antag_datum_ref.objectives

	if(length(all_objectives))
		var/antag_obj_count = 1
		for(var/datum/objective/objective in all_objectives)
			if(objective.hidden)
				continue
			if(!has_antag_objectives)
				has_antag_objectives = TRUE
				antag_output += "<br><B>Objectives:</B>"
			antag_output += "<br><B>[objective.flavor] #[antag_obj_count]</B>: [objective.explanation_text][objective.completed ? " (COMPLETED)" : ""]"
			antag_obj_count++

	output += antag_output
	var/list/contract_lines = get_contract_demand_lines()
	if(length(contract_lines))
		output += "<br><B>Patron Contracts:</B><br>[contract_lines.Join("<br>")]"

	if(window)
		var/datum/browser/memory_browser = new(recipient, "memory", "<div align='center'>[name_display] Memory</div>", 425, 475)
		memory_browser.set_content(output)
		memory_browser.open()
	else if(length(all_objectives) || length(personal_objectives) || memory)
		to_chat(recipient, "<i>[output]</i>")

/// Output current targets to the player
/datum/mind/proc/recall_targets(mob/recipient, window=1)
	var/output = "<B>[recipient.real_name]'s Hitlist:</B><br>"
	for (var/mob/living/carbon in GLOB.mob_living_list)
		if (HAS_TRAIT(carbon, TRAIT_ZIZOID_HUNTED) && (!istype(carbon, /mob/living/carbon/human/dummy)))
			output += "<br><b>[carbon.real_name]</b>"
			if (carbon.job)
				output += " - [carbon.job]"

			// Get the hunted quirk and display the reason
			var/datum/quirk/negative/wanted/hunted_quirk = carbon.get_quirk(/datum/quirk/negative/wanted)
			if(hunted_quirk && hunted_quirk.customization_value && hunted_quirk.customization_value != "")
				output += "<br><i>Wanted for: [hunted_quirk.customization_value]</i>"
			else
				output += "<br><i>Wanted for: Unknown reasons</i>"

	output += "<br><br>Your creed is blood, your faith is steel. You will not rest until these souls are yours. Use the profane dagger to trap their souls for Graggar."
	if(window)
		recipient << browse(output,"window=memory")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))
		return

	var/self_antagging = usr == current

	if(href_list["add_antag"])
		add_antag_wrapper(text2path(href_list["add_antag"]),usr)
	if(href_list["remove_antag"])
		var/datum/antagonist/antag_datum_ref = locate(href_list["remove_antag"]) in antag_datums
		if(!istype(antag_datum_ref))
			to_chat(usr, span_warning("Invalid antagonist ref to be removed."))
			return
		antag_datum_ref.admin_remove(usr)

	else if(href_list["vv_antag"])
		var/datum/antagonist/antag_datum_ref = locate(href_list["vv_antag"]) in antag_datums
		if(!istype(antag_datum_ref))
			to_chat(usr, span_warning("Invalid antagonist ref to view variables."))
			return
		usr.client.debug_variables(antag_datum_ref)

	else if (href_list["memory_edit"])
		var/new_memo = copytext(sanitize(input("Write new memory", "Memory", memory) as null|message),1,MAX_MESSAGE_LEN)
		if (isnull(new_memo))
			return
		memory = new_memo

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/objective_pos //Edited objectives need to keep same order in antag objective list
		var/def_value
		var/datum/antagonist/target_antag
		var/datum/objective/old_objective //The old objective we're replacing/editing
		var/datum/objective/new_objective //New objective we're be adding

		if(href_list["obj_edit"])
			for(var/datum/antagonist/antag_datum_ref in antag_datums)
				old_objective = locate(href_list["obj_edit"]) in antag_datum_ref.objectives
				if(old_objective)
					target_antag = antag_datum_ref
					objective_pos = antag_datum_ref.objectives.Find(old_objective)
					break
			if(!old_objective)
				to_chat(usr,"Invalid objective.")
				return
		else
			if(href_list["target_antag"])
				var/datum/antagonist/X = locate(href_list["target_antag"]) in antag_datums
				if(X)
					target_antag = X
			if(!target_antag)
				switch(antag_datums.len)
					if(0)
						target_antag = add_antag_datum(/datum/antagonist/custom)
					if(1)
						target_antag = antag_datums[1]
					else
						var/datum/antagonist/target = input("Which antagonist gets the objective:", "Antagonist", "(new custom antag)") as null|anything in sortList(antag_datums) + "(new custom antag)"
						if (QDELETED(target))
							return
						else if(target == "(new custom antag)")
							target_antag = add_antag_datum(/datum/antagonist/custom)
						else
							target_antag = target

		if(!GLOB.admin_objective_list)
			generate_admin_objective_list()

		if(old_objective)
			if(old_objective.name in GLOB.admin_objective_list)
				def_value = old_objective.name

		var/selected_type = input("Select objective type:", "Objective type", def_value) as null|anything in GLOB.admin_objective_list
		selected_type = GLOB.admin_objective_list[selected_type]
		if (!selected_type)
			return

		if(!old_objective)
			//Add new one
			new_objective = new selected_type
			new_objective.owner = src
			new_objective.admin_edit(usr)
			target_antag.objectives += new_objective
			message_admins("[key_name_admin(usr)] added a new objective for [current]: [new_objective.explanation_text]")
			log_admin("[key_name(usr)] added a new objective for [current]: [new_objective.explanation_text]")
		else
			if(old_objective.type == selected_type)
				//Edit the old
				old_objective.admin_edit(usr)
				new_objective = old_objective
			else
				//Replace the old
				new_objective = new selected_type
				new_objective.owner = src
				new_objective.admin_edit(usr)
				target_antag.objectives -= old_objective
				target_antag.objectives.Insert(objective_pos, new_objective)
			message_admins("[key_name_admin(usr)] edited [current]'s objective to [new_objective.explanation_text]")
			log_admin("[key_name(usr)] edited [current]'s objective to [new_objective.explanation_text]")

	else if (href_list["obj_delete"])
		var/datum/objective/objective
		for(var/datum/antagonist/antag_datum_ref in antag_datums)
			objective = locate(href_list["obj_delete"]) in antag_datum_ref.objectives
			if(istype(objective))
				antag_datum_ref.objectives -= objective
				break
		if(!objective)
			to_chat(usr,"Invalid objective.")
			return
		//qdel(objective) Needs cleaning objective destroys
		message_admins("[key_name_admin(usr)] removed an objective for [current]: [objective.explanation_text]")
		log_admin("[key_name(usr)] removed an objective for [current]: [objective.explanation_text]")

	else if(href_list["obj_completed"])
		var/datum/objective/objective
		for(var/datum/antagonist/antag_datum_ref in antag_datums)
			objective = locate(href_list["obj_completed"]) in antag_datum_ref.objectives
			if(istype(objective))
				objective = objective
				break
		if(!objective)
			to_chat(usr,"Invalid objective.")
			return
		objective.completed = !objective.completed
		log_admin("[key_name(usr)] toggled the win state for [current]'s objective: [objective.explanation_text]")
	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/W in current)
					current.dropItemToGround(W, TRUE) //The 1 forces all items to drop, since this is an admin undress.
	else if (href_list["obj_announce"])
		announce_objectives()

	//Something in here might have changed my mob
	if(self_antagging && (!usr || !usr.client) && current.client)
		usr = current
	traitor_panel()

/// Gets only antagonist objectives
/datum/mind/proc/get_antag_objectives()
	var/list/antag_objectives = list()
	for(var/datum/antagonist/antag_datum_ref in antag_datums)
		antag_objectives |= antag_datum_ref.objectives
	return antag_objectives

/// Gets only personal objectives
/datum/mind/proc/get_personal_objectives()
	return personal_objectives?.Copy() || list()

/// Gets all objectives (both types)
/datum/mind/proc/get_all_objectives()
	return get_personal_objectives() + get_antag_objectives()

/// Announces only antagonist objectives
/datum/mind/proc/announce_antagonist_objectives()
	for(var/datum/antagonist/antag_datum_ref in antag_datums)
		if(length(antag_datum_ref.objectives))
			var/obj_count = 1
			var/has_visible_objectives = FALSE
			var/objective_output = ""

			for(var/datum/objective/O in antag_datum_ref.objectives)
				if(!O.hidden)
					if(!has_visible_objectives)
						has_visible_objectives = TRUE
					O.update_explanation_text()
					objective_output += "<B>[O.flavor] #[obj_count]</B>: [O.explanation_text]<br>"
					obj_count++

			if(has_visible_objectives)
				to_chat(current, span_notice("Your [antag_datum_ref.name] objectives:"))
				to_chat(current, objective_output)

/// Announces only personal objectives
/datum/mind/proc/announce_personal_objectives()
	if(length(personal_objectives))
		var/personal_count = 1
		var/has_visible_objectives = FALSE
		var/objective_output = ""

		for(var/datum/objective/personal/O in personal_objectives)
			if(!O.hidden)
				if(!has_visible_objectives)
					has_visible_objectives = TRUE
				O.update_explanation_text()
				objective_output += "<B>Personal Goal #[personal_count]</B>: [O.explanation_text]<br>"
				personal_count++

		if(has_visible_objectives)
			to_chat(current, objective_output)

/// Announce all objectives (both types)
/datum/mind/proc/announce_objectives()
	announce_personal_objectives()
	announce_antagonist_objectives()

/datum/mind/proc/transfer_martial_arts(mob/living/new_character)
	if(!ishuman(new_character))
		return
	if(martial_art)
		if(martial_art.base) //Is the martial art temporary?
			martial_art.remove(new_character)
		else
			martial_art.teach(new_character)

/datum/mind/proc/get_ghost(even_if_they_cant_reenter, ghosts_with_clients)
	for(var/mob/dead/observer/G in (ghosts_with_clients ? GLOB.player_list : GLOB.dead_mob_list))
		if(G.mind == src)
			if(G.can_reenter_corpse || even_if_they_cant_reenter)
				return G
			break

/datum/mind/proc/grab_ghost(force)
	var/mob/dead/observer/G = get_ghost(even_if_they_cant_reenter = force)
	. = G
	if(G)
		G.reenter_corpse(force)


/datum/mind/proc/has_objective(objective_type)
	for(var/datum/antagonist/antag_datum_ref in antag_datums)
		for(var/O in antag_datum_ref.objectives)
			if(istype(O,objective_type))
				return TRUE

/// Setter for the assigned_role job datum.
/datum/mind/proc/set_assigned_role(datum/job/new_role)
	if(!istype(new_role))
		var/requested_role = new_role
		new_role = ispath(new_role) ? SSjob.GetJobType(new_role) : SSjob.GetJob(new_role)
		if(!new_role && !isnull(requested_role))
			stack_trace("set_assigned_role could not resolve [requested_role]; assigned_role becomes null.")
	if(assigned_role == new_role)
		return assigned_role
	. = assigned_role
	assigned_role = new_role
	if(isliving(current))
		var/mob/living/living_mob = current
		if(new_role)
			new_role.apply_alt_title_preferences(living_mob, living_mob.client?.prefs)
			if(iscarbon(living_mob))
				var/mob/living/carbon/carbon_mob = living_mob
				new_role.assign_honorary_titles(carbon_mob)
		else
			living_mob.job_title_override = null
			living_mob.job_honorary_override = null
	broadcast_identity_update()

/mob/proc/sync_mind()
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = TRUE	//indicates that the mind is currently synced with a client

/mob/dead/new_player/sync_mind()
	return

/mob/dead/observer/sync_mind()
	return

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key

	else
		mind = new /datum/mind(key)
		SSticker.minds += mind
	if(!mind.name)
		mind.name = real_name
	mind.current = src

/mob/living/carbon/mind_initialize()
	..()
	last_mind = mind

/**
 * Gives experience to a skill during sleep
 * Vars:
 ** skill - associated skill
 ** amt - amount of experience to give
 ** silent - is the player notified of their skill change?
 ** check_apprentice - do apprentices receive skill experience too?
*/
/datum/mind/proc/add_sleep_experience(skill, amt, silent = FALSE, check_apprentice = TRUE)
	if(HAS_TRAIT(current, TRAIT_NO_EXPERIENCE))
		return FALSE
	amt *= GLOB.sleep_experience_modifier

	if(current.has_quirk(/datum/quirk/positive/quick_learner))
		amt *= 1.2

	amt *= current.get_skill_exp_multiplier(skill)

	if(check_apprentice)
		current.attributes.adjust_apprentice_exp(skill, amt, silent)
	if(sleep_adv.adjust_sleep_xp(skill, amt, silent))
		return TRUE

/datum/mind/proc/add_personal_objective(datum/objective/O)
	if(!istype(O))
		return FALSE
	if(current)
		current.apply_status_effect(/datum/status_effect/purpose)
	personal_objectives += O
	O.owner = src
	return TRUE

/datum/mind/proc/remove_personal_objective(datum/objective/O)
	personal_objectives -= O
	qdel(O)

/datum/mind/proc/clear_personal_objectives()
	for(var/O in personal_objectives)
		qdel(O)
	personal_objectives.Cut()

/obj/structure/proc/handle_special_items_retrieval(mob/user, atom/host_object)
	// Attempts to retrieve an item from a player's stash, and applies any base colors, custom names, and descriptions.
	if(user.mind && isliving(user))
		if(user.mind.special_items && user.mind.special_items.len)
			var/item = input(user, "What will I take?", "STASH") as null|anything in user.mind.special_items
			if(item)
				if(user.Adjacent(host_object))
					if(user.mind.special_items[item])
						var/path2item = user.mind.special_items[item]
						user.mind.special_items -= item
						var/obj/item/I = new path2item(user.loc)

						// Check if this is a loadout item (no stat modification applied)
						if(user.client?.prefs)
							var/list/loadout_slots = list(
								"loadout1", "loadout2", "loadout3", "loadout4", "loadout5",
								"loadout6", "loadout7", "loadout8", "loadout9", "loadout10"
							)
							for(var/slot in loadout_slots)
								var/datum/loadout_item/loadout_datum = user.client.prefs.vars[slot]
								if(loadout_datum && loadout_datum.item_path == path2item)
									break

						// Apply custom color if set (for clothing and weapons) - BEFORE putting in hands
						var/dye = user.client?.prefs.resolve_loadout_to_color(path2item)
						if(dye)
							I.add_atom_colour(dye, FIXED_COLOUR_PRIORITY)
							I.update_icon()

						// Apply custom name if set
						var/custom_name = user.client?.prefs.resolve_loadout_to_name(path2item)
						if(custom_name)
							I.original_name = I.name
							I.name = custom_name
							log_game("[key_name(user)] retrieved loadout item with custom name: '[custom_name]' (original: '[I.original_name]')")

						// Apply custom description if set
						var/custom_desc = user.client?.prefs.resolve_loadout_to_desc(path2item)
						if(custom_desc)
							I.desc = custom_desc

						user.put_in_hands(I)

						// Force update mob appearance to show colored item in hands
						if(isliving(user))
							var/mob/living/L = user
							L.update_inv_hands()
							L.update_icons()
