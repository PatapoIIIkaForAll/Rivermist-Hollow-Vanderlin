/// Grants the silk weaving actions and web walking under source.
/mob/living/proc/add_silk_weaving(source)
	var/already_weaver = HAS_TRAIT(src, TRAIT_SILK_WEAVER)
	ADD_TRAIT(src, TRAIT_SILK_WEAVER, source)
	ADD_TRAIT(src, TRAIT_WEBWALK, source)
	if(already_weaver)
		return
	for(var/action_type in SILK_WEAVING_ACTIONS)
		var/datum/action/weaving_action = new action_type(src)
		weaving_action.Grant(src)

/// Removes source; the actions go once no source is left.
/mob/living/proc/remove_silk_weaving(source)
	REMOVE_TRAIT(src, TRAIT_SILK_WEAVER, source)
	REMOVE_TRAIT(src, TRAIT_WEBWALK, source)
	if(HAS_TRAIT(src, TRAIT_SILK_WEAVER))
		return
	for(var/datum/action/cooldown/silk_weaving/weaving_action in actions)
		qdel(weaving_action)

/mob/living/bleed(amt, should_update = TRUE)
	if(HAS_TRAIT(src, TRAIT_SILK_COMPRESSION))
		return FALSE
	return ..()

/// First pass of Weave Web; a second pass replaces it with an ordinary web.
/obj/structure/spider/stickyweb/thin
	name = "thin web"
	desc = "A loose, translucent layer of webbing. Another pass of silk would thicken it."
	max_integrity = 25
	opacity = FALSE

/obj/structure/spider/stickyweb/thin/Initialize(mapload)
	. = ..()
	alpha = rand(45, 65)
