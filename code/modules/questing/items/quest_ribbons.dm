/// Guild ribbons for Sate and Mark contracts; tie one on a creature that lies spent.
/obj/item/quest_ribbons
	name = "guild tally ribbons"
	desc = "Pink silk ribbons stamped with the Mercenary's Guild seal. Tie one on a contract creature while it lies spent from lust to mark it."
	icon = 'icons/roguetown/items/natural.dmi'
	icon_state = "cloth"
	color = "#ff6ec7"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FIRE_PROOF
	var/ribbons_left = 1
	var/datum/weakref/quest_ref

/obj/item/quest_ribbons/proc/bind_to_quest(datum/quest/kill/carnal/sate/quest, count)
	quest_ref = WEAKREF(quest)
	ribbons_left = max(1, count)

/obj/item/quest_ribbons/examine(mob/user)
	. = ..()
	. += span_notice("[ribbons_left] ribbon\s left.")
	var/datum/quest/quest = quest_ref?.resolve()
	if(quest)
		. += span_info("They are bound to the contract \"[quest.get_title()]\".")

/obj/item/quest_ribbons/pre_attack(atom/A, mob/living/user, list/modifiers)
	if(!isliving(A) || A == user)
		return ..()
	INVOKE_ASYNC(src, PROC_REF(try_tie), A, user)
	return TRUE

/obj/item/quest_ribbons/proc/try_tie(mob/living/target, mob/living/user)
	var/datum/quest/kill/carnal/sate/quest = quest_ref?.resolve()
	if(!quest || quest.complete)
		to_chat(user, span_warning("These ribbons belong to no open contract."))
		return FALSE
	var/datum/component/quest_object/kill/carnal/sate/target_tag = target.GetComponent(/datum/component/quest_object/kill/carnal/sate)
	if(!target_tag || target_tag.quest_ref?.resolve() != quest)
		to_chat(user, span_warning("[target] is not a creature named in my contract."))
		return FALSE
	if(target_tag.marked)
		to_chat(user, span_warning("[target] already wears a guild ribbon."))
		return FALSE
	if(!target_tag.can_be_marked())
		to_chat(user, span_warning("[target] is not spent yet. It must collapse from lust before I can mark it."))
		return FALSE
	user.visible_message(span_notice("[user] starts tying a pink ribbon on [target]."), span_notice("I start tying a guild ribbon on [target]."))
	if(!do_after(user, 2 SECONDS, target))
		return FALSE
	return finish_tie(target, user)

/obj/item/quest_ribbons/proc/finish_tie(mob/living/target, mob/living/user)
	var/datum/component/quest_object/kill/carnal/sate/target_tag = target.GetComponent(/datum/component/quest_object/kill/carnal/sate)
	if(!target_tag?.apply_mark(quest_ref?.resolve()))
		return FALSE
	user.visible_message(span_notice("[user] ties a pink guild ribbon on [target]."), span_notice("I tie a guild ribbon on [target]. It counts for my contract."))
	ribbons_left--
	if(ribbons_left <= 0)
		qdel(src)
	return TRUE
