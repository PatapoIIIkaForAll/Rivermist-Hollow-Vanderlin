// Quest marker, ported from Ochre Valley.
// Puts a marker over your head so adventurers know you have work for them. Use the emote again to take it down.

/mob/living
	/// The marker over our head while we are offering a quest.
	var/mutable_appearance/quest_marker

/datum/emote/living/quest
	key = "quest"
	message = "has a quest to offer!"
	emote_type = EMOTE_AUDIBLE
	sound = 'modular_rmh/sound/emotes/quest.ogg'

/datum/emote/living/quest/run_emote(mob/living/user, params, type_override, intentional, targetted)
	if(user.quest_marker)
		user.hide_quest_marker()
		to_chat(user, span_notice("I am no longer offering a quest."))
		return TRUE
	. = ..()
	if(!.)
		return
	user.show_quest_marker()
	to_chat(user, span_notice("I am offering a quest. I can use the emote again to stop."))

/mob/living/proc/show_quest_marker()
	quest_marker = mutable_appearance('modular_rmh/icons/mob/quest_marker.dmi', "quest", ABOVE_ALL_MOB_LAYER, appearance_flags = RESET_COLOR)
	quest_marker.pixel_y = world.icon_size
	if(iscarbon(src))
		var/mob/living/carbon/carbon_self = src
		carbon_self.apply_offset(quest_marker, OFFSET_HEAD)
	add_overlay(quest_marker)

/mob/living/proc/hide_quest_marker()
	cut_overlay(quest_marker)
	quest_marker = null

/mob/living/carbon/human/verb/emote_quest()
	set name = "Offer Quest"
	set category = "Emotes.Silent"
	emote("quest", intentional = TRUE)
