/// Wear creatures down to a horny defeat, then tie a guild ribbon on each while it lies spent.
/datum/quest/kill/carnal/sate
	quest_type = QUEST_SATE_MARK
	mob_types_to_spawn = QUEST_CARNAL_SATE_LIST
	kill_component_type = /datum/component/quest_object/kill/carnal/sate
	count_min = 1
	count_max = 4
	minimum_tier = QUEST_TIER_ROUTINE
	// Lethal would draw only a lone bog troll and pay less than Deadly.
	maximum_tier = QUEST_TIER_DEADLY

/datum/quest/kill/carnal/sate/build_title()
	if(!target_mob_type)
		return "Sate and mark a rutting creature"
	return "Sate and mark [pick("rutting", "restless", "lust-maddened", "insatiable")] [initial(target_mob_type.name)]"

/datum/quest/kill/carnal/sate/get_objective_text()
	var/objective = "Wear down [progress_required] [initial(target_mob_type.name)] [progress_required == 1 ? "target" : "targets"] until they collapse spent, then tie a guild ribbon on each. Climaxes you give them count only in combat mode; killing them does not count."
	if(!complete && count_living_targets() < progress_required - progress_current)
		objective += " Too few of them remain alive. Abandon this contract at the ledger."
	return objective

/datum/quest/kill/carnal/sate/get_reward_multiplier()
	return QUEST_SATE_REWARD_MULTIPLIER

/datum/quest/kill/carnal/sate/on_target_lost(mob/living/lost_target)
	if(!quest_receiver_reference && SSquestboard?.is_posted(src))
		spawned_target_count = max(spawned_target_count - 1, 0)
		on_posted_target_lost(lost_target)
		return
	..()

/datum/quest/kill/carnal/sate/issue_contract_kit(mob/living/carbon/human/user)
	var/obj/item/quest_ribbons/ribbons = new(get_turf(user))
	ribbons.bind_to_quest(src, progress_required - progress_current + QUEST_SATE_SPARE_RIBBONS)
	set_contract_kit(ribbons)
	user.put_in_hands(ribbons)

/datum/quest/kill/carnal/sate/proc/on_target_marked(mob/living/target)
	// A marked creature stays down where it lies until the usual knockout cleanup.
	forget_tracked_atom(target)
	progress_current++
	on_progress_update()

/// Sate and Mark creatures: a horny knockout lets the contract holder tie a ribbon on them.
/datum/component/quest_object/kill/carnal/sate
	var/marked = FALSE

/datum/component/quest_object/kill/carnal/sate/Initialize(datum/quest/target_quest)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	RegisterSignal(parent, COMSIG_LIVING_DEFEATED, PROC_REF(on_defeated))

/datum/component/quest_object/kill/carnal/sate/proc/on_defeated(mob/living/source)
	SIGNAL_HANDLER
	if(!can_be_marked())
		return
	var/datum/quest/quest = quest_ref?.resolve()
	var/mob/receiver = quest?.quest_receiver_reference?.resolve()
	if(receiver && (receiver in viewers(world.view, source)))
		to_chat(receiver, span_notice("[source] lies spent. Now I can tie a guild ribbon on it."))

/datum/component/quest_object/kill/carnal/sate/on_mob_examine(datum/source, mob/user, list/examine_list)
	. = ..()
	if(marked)
		examine_list += span_notice("A pink guild ribbon is tied on it.")
	else if(can_be_marked())
		examine_list += span_notice("It lies spent. A guild ribbon could be tied on it now.")

/datum/component/quest_object/kill/carnal/sate/proc/can_be_marked()
	var/mob/living/target = parent
	if(marked || completion_counted || target.stat == DEAD)
		return FALSE
	return !!target.has_status_effect(/datum/status_effect/mob_horny_knockout)

/datum/component/quest_object/kill/carnal/sate/proc/apply_mark(datum/quest/kill/carnal/sate/expected_quest)
	var/datum/quest/kill/carnal/sate/quest = quest_ref?.resolve()
	if(!quest || quest != expected_quest || quest.complete || quest.being_destroyed || !can_be_marked())
		return FALSE
	marked = TRUE
	completion_counted = TRUE
	var/mob/living/target = parent
	target.remove_filter(outline_filter_id)
	target.add_filter(outline_filter_id, 2, list("type" = "outline", "color" = "#ff6ec7", "size" = 0.5))
	quest.on_target_marked(target)
	return TRUE
