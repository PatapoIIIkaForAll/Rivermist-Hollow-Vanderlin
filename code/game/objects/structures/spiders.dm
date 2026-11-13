// This shit sucks ass

/*	..................   Spider stuff   ................... */
/obj/structure/spider/attacked_by(obj/item/I, mob/living/user) //Snipping action for webs, scissors turning webs into silk fast!
	if(user.used_intent.type != /datum/intent/snip)
		return ..()
	var/sewing_skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/sewing)
	var/snip_time = 5 SECONDS - (sewing_skill * 10)
	var/amount = rand(1, 2)
	if(!do_after(user, snip_time))
		return TRUE
	for(var/i in 1 to amount)
		new /obj/item/natural/silk (get_turf(src))
	user.visible_message(span_notice("[user] snips [src] up into silk."))
	user.mind.add_sleep_experience(/datum/attribute/skill/misc/sewing, (GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) / 2)) //We're getting experience for harvesting silk!
	playsound(src, 'sound/items/flint.ogg', 100, TRUE)
	qdel(src)
	return TRUE

/obj/structure/spider/stickyweb
	name = "web"
	icon = 'icons/roguetown/misc/webbing.dmi'
	icon_state = "stickyweb1"
	resistance_flags = FLAMMABLE
	alpha = 109
	max_integrity = 50
	opacity = TRUE

/obj/structure/spider/stickyweb/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!HAS_TRAIT(mover, TRAIT_WEBWALK) && isliving(mover))
		if(prob(50))
			to_chat(mover, "<span class='danger'>I get stuck in \the [src] for a moment.</span>")
			return FALSE
	else if(istype(mover, /obj/projectile))
		return prob(30)

/obj/structure/spider/stickyweb/fire_act(added, maxstacks)
	visible_message("<span class='warning'>[src] catches fire!</span>")
	var/turf/T = get_turf(src)
	qdel(src)
	new /obj/effect/hotspot(T)

/obj/structure/spider/stickyweb/solo
	icon_state = "stickyweb3"

/obj/structure/spider/stickyweb/Initialize()
	if(icon_state == "stickyweb1")
		if(prob(50))
			icon_state = "stickyweb2"
	dir = pick(GLOB.cardinals)
	alpha = rand(80,109)
	switch(pick(1,2))
		if (1)
			static_debris = FALSE
		if (2)
			static_debris = list(/obj/item/natural/silk = 1)
	. = ..()

#define SPIDER_COCOON_BREAKOUT_BASE (30 SECONDS)
#define SPIDER_COCOON_BREAKOUT_PER_EGG (5 SECONDS)
#define SPIDER_COCOON_BREAKOUT_MAX (2 MINUTES)
/// A victim who gets out is left alone this long, so an escape is an escape.
#define SPIDER_COCOON_ESCAPE_GRACE (10 MINUTES)
#define SPIDER_COCOON_SEALED_INTEGRITY 80

/// Cocoons with someone alive inside; spiders keep their distance from these.
GLOBAL_LIST_EMPTY(occupied_spider_cocoons)

/obj/structure/spider/cocoon
	name = "cocoon"
	desc = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon1"
	max_integrity = 40
	/// Pumped full of eggs and sealed; no spider comes back to it.
	var/brooded = FALSE
	/// Occupants struggling out right now.
	var/list/escapers

/obj/structure/spider/cocoon/Initialize(mapload, ...)
	. = ..()
	switch(pick(1,2,3,4,5))
		if(1)
			static_debris = list(/obj/item/natural/silk = 3)
			icon_state = pick("cocoon1","cocoon2")
		if(2)
			static_debris = list(/obj/item/natural/silk = 2, /obj/effect/decal/remains/bigrat = 1)
			icon_state = pick("cocoon2","cocoon3")
		if(3)
			static_debris = list(/obj/item/natural/silk = 2, /obj/effect/decal/remains/human = 1)
			icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
		if(4)
			static_debris = list(/obj/item/natural/silk = 2, /obj/effect/decal/cleanable/blood/gibs = 1)
			icon_state = pick("cocoon1","cocoon2","cocoon3")
		if(5)
			static_debris = list(/obj/item/natural/silk = 2, /obj/item/natural/stone = 1)
			icon_state = pick("cocoon1","cocoon2")

/obj/structure/spider/cocoon/Destroy()
	// Whoever is inside spills out rather than being deleted with the silk.
	var/turf/drop_turf = get_turf(src)
	for(var/atom/movable/inside as anything in contents)
		inside.forceMove(drop_turf)
	GLOB.occupied_spider_cocoons -= src
	escapers = null
	return ..()

/obj/structure/spider/cocoon/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return
	GLOB.occupied_spider_cocoons |= src
	add_verb(arrived, /mob/living/proc/escape_cocoon)
	to_chat(arrived, span_notice("I can struggle out of the silk: Escape Cocoon in the IC tab, or click the silk alert."))

/obj/structure/spider/cocoon/Exited(atom/movable/gone, atom/newLoc)
	. = ..()
	if(isliving(gone))
		var/mob/living/escaped = gone
		escaped.kidnap_protected_until = max(escaped.kidnap_protected_until, world.time + SPIDER_COCOON_ESCAPE_GRACE)
		if(escaped.stat != DEAD)
			escaped.apply_status_effect(/datum/status_effect/cocoon_grace)
			to_chat(escaped, span_notice("I am out of the silk. For [DisplayTimeText(SPIDER_COCOON_ESCAPE_GRACE)], spiders and other lustful creatures will not try to take me."))
		LAZYREMOVE(escapers, escaped)
		remove_verb(escaped, /mob/living/proc/escape_cocoon)
		if(!(locate(/mob/living) in contents))
			GLOB.occupied_spider_cocoons -= src

/obj/structure/spider/cocoon/deconstruct(disassembled)
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>\The [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()

/obj/structure/spider/cocoon/container_resist(mob/living/user)
	start_escape(user)

/// The one breakout: Resist, the verb and the alert all start it. FALSE when none started.
/obj/structure/spider/cocoon/proc/start_escape(mob/living/user)
	if(!isliving(user) || user.loc != src || LAZYFIND(escapers, user))
		return FALSE
	if(user.stat != CONSCIOUS)
		return FALSE
	if(user.doing())
		to_chat(user, span_warning("I am busy with something else."))
		return FALSE
	LAZYADD(escapers, user)
	if(user.surrendering)
		stop_yielding(user)
	var/breakout_time = get_breakout_time(user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>I struggle against the tight bonds... (This will take about [DisplayTimeText(breakout_time)].)</span>")
	visible_message("<span class='notice'>I see something struggling and writhing in \the [src]!</span>")
	INVOKE_ASYNC(src, PROC_REF(struggle_out), user, breakout_time)
	return TRUE

/// Binds, a knockout or a stun do not stop it; leaving, sleep or death do.
/obj/structure/spider/cocoon/proc/struggle_out(mob/living/user, breakout_time)
	var/freed = do_after(user, breakout_time, src, IGNORE_HELD_ITEM | IGNORE_USER_DIR_CHANGE | IGNORE_INCAPACITATED, extra_checks = CALLBACK(src, PROC_REF(can_keep_struggling), user))
	if(QDELETED(src))
		return
	LAZYREMOVE(escapers, user)
	if(QDELETED(user) || user.loc != src)
		return
	if(!freed || user.stat != CONSCIOUS)
		to_chat(user, span_warning("The silk holds."))
		return
	visible_message(span_warning("[user] tears free of \the [src]!"))
	qdel(src)

/obj/structure/spider/cocoon/proc/can_keep_struggling(mob/living/user)
	return user.loc == src && user.stat == CONSCIOUS

/// Struggling out ends a yield, the same way rescinding it does.
/obj/structure/spider/cocoon/proc/stop_yielding(mob/living/user)
	user.surrendering = FALSE
	if(!user.had_pacifist)
		REMOVE_TRAIT(user, TRAIT_PACIFISM, TRAIT_GENERIC)
	user.had_pacifist = FALSE
	to_chat(user, span_notice("I stop yielding and fight the silk."))

/// Only offered while wound inside a cocoon.
/mob/living/proc/escape_cocoon()
	set name = "Escape Cocoon"
	set category = "IC"

	var/obj/structure/spider/cocoon/cocoon = loc
	if(!istype(cocoon))
		remove_verb(src, /mob/living/proc/escape_cocoon)
		return
	cocoon.start_escape(src)

/obj/structure/spider/cocoon/examine(mob/user)
	. = ..()
	if(brooded)
		. += span_warning("It is sealed shut and swollen.")
	var/mob/living/carbon/victim = get_wrapped_victim()
	if(victim)
		. += span_love(get_silk_glimpse(victim))
		. += span_notice("Whoever is inside can struggle out: Escape Cocoon in the IC tab, or the silk alert.")

/// The living carbon wound up inside, or null.
/obj/structure/spider/cocoon/proc/get_wrapped_victim()
	for(var/mob/living/carbon/victim in contents)
		if(victim.stat != DEAD)
			return victim
	return null

/// Winds [victim] inside; the silk slowly knits their wounds so nobody dies in here.
/obj/structure/spider/cocoon/proc/wrap(mob/living/victim)
	// A fresh wrap looks slim and spills only silk; the swollen look is for sealed ones.
	icon_state = pick("cocoon1", "cocoon2", "cocoon3")
	static_debris = list(/obj/item/natural/silk = 2)
	victim.buckled?.unbuckle_mob(victim, TRUE)
	victim.forceMove(src)
	victim.apply_status_effect(/datum/status_effect/buff/healing/spider_cocoon, 0.25)

/// Pumped full: thicker silk, a swollen look, and no spider returns.
/obj/structure/spider/cocoon/proc/seal()
	if(brooded)
		return FALSE
	brooded = TRUE
	max_integrity = SPIDER_COCOON_SEALED_INTEGRITY
	update_integrity(SPIDER_COCOON_SEALED_INTEGRITY)
	icon_state = pick("cocoon_large1", "cocoon_large2", "cocoon_large3")
	return TRUE

/// One minute, plus a little for every egg the occupant carries, capped.
/obj/structure/spider/cocoon/proc/get_breakout_time(mob/living/user)
	return min(SPIDER_COCOON_BREAKOUT_BASE + SPIDER_COCOON_BREAKOUT_PER_EGG * count_eggs_inside(user), SPIDER_COCOON_BREAKOUT_MAX)

/// Oviposition eggs carried in every organ of [victim] that can hold them.
/obj/structure/spider/cocoon/proc/count_eggs_inside(mob/living/victim)
	if(!iscarbon(victim))
		return 0
	var/mob/living/carbon/carrier = victim
	var/count = 0
	for(var/obj/item/organ/organ as anything in carrier.internal_organs)
		if(organ.supports_oviposition_pregnancy())
			count += length(organ.get_oviposition_eggs())
	return count

/// One line naming what shows through the silk.
/obj/structure/spider/cocoon/proc/get_silk_glimpse(mob/living/carbon/victim)
	var/list/glimpses = list()
	if(victim.getorganslot(ORGAN_SLOT_BREASTS) && !is_zone_clothed(victim, BODY_ZONE_CHEST))
		glimpses += "bare breasts"
	if(victim.handcuffed)
		glimpses += "bound wrists"
	if(count_eggs_inside(victim))
		glimpses += "a belly full of eggs"
	for(var/obj/item/clothing/face/gear in victim.get_equipped_items())
		var/gear_path = "[gear.type]"
		if(!findtext(gear_path, "/silk"))
			continue
		if(findtext(gear_path, "gag"))
			glimpses += "a mouth packed with silk"
		else if(findtext(gear_path, "blindfold"))
			glimpses += "eyes wound with silk"
	if(!length(glimpses))
		return "Something moves inside the silk."
	return "Through the silk I see [english_list(glimpses)]."

/// TRUE when anything [victim] wears covers [zone].
/obj/structure/spider/cocoon/proc/is_zone_clothed(mob/living/carbon/victim, zone)
	for(var/obj/item/clothing/garment in victim.get_equipped_items())
		if(zone2covered(zone, garment.body_parts_covered))
			return TRUE
	return FALSE

/// Shows the grace after leaving a cocoon: lustful creatures leave the mob be until it runs out.
/datum/status_effect/cocoon_grace
	id = "cocoon_grace"
	duration = SPIDER_COCOON_ESCAPE_GRACE
	tick_interval = 10 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/buff/cocoon_grace

/datum/status_effect/cocoon_grace/on_creation(mob/living/new_owner, duration_override, ...)
	. = ..()
	update_grace_text()

/datum/status_effect/cocoon_grace/tick()
	update_grace_text()

/// The alert names the time left, read from the same stamp the targeting checks.
/datum/status_effect/cocoon_grace/proc/update_grace_text()
	if(!linked_alert || !owner)
		return
	var/left = max(0, owner.kidnap_protected_until - world.time)
	linked_alert.desc = "Spiders and other lustful creatures will not try to take me for [DisplayTimeText(left, 10)] more. A spider I fought may still bite."

/atom/movable/screen/alert/status_effect/buff/cocoon_grace
	name = "Free of the silk"
	desc = "Spiders and other lustful creatures will not try to take me for a while."

/atom/movable/screen/alert/status_effect/buff/cocoon_grace/Click(location, control, params)
	if(LAZYACCESS(params2list(params), SHIFT_CLICKED))
		return ..()
	if(usr == mob_viewer)
		to_chat(usr, span_notice(desc))

#undef SPIDER_COCOON_BREAKOUT_BASE
#undef SPIDER_COCOON_BREAKOUT_PER_EGG
#undef SPIDER_COCOON_BREAKOUT_MAX
#undef SPIDER_COCOON_ESCAPE_GRACE
#undef SPIDER_COCOON_SEALED_INTEGRITY
