/obj/item/rope/spider_silk/moth
	name = "moth silk"
	desc = "Pale, downy silk spun into a clinging cord. It smells faintly of cedar and dust."
	color = "#eee4cf"
	breakouttime = 15 SECONDS
	slipouttime = 40 SECONDS

/obj/item/rope/spider_silk/moth/snare
	desc = "A fine loop of pale silk, easy to kick loose."
	breakouttime = 6 SECONDS

/obj/structure/spider/stickyweb/mothbug
	name = "moth silk"
	desc = "Soft, pale threads strung in a dusty tangle."
	color = "#eee4cf"

/obj/structure/mothbug_snare
	name = "silk thread"
	desc = "A nearly invisible loop of pale silk, stretched low across the floor."
	icon = 'modular_rmh/icons/obj/mothbug_silk.dmi'
	icon_state = "snare"
	alpha = 40
	anchored = TRUE
	density = FALSE
	layer = BELOW_OBJ_LAYER
	max_integrity = 10
	resistance_flags = FLAMMABLE
	var/datum/weakref/spinner_ref

/obj/structure/mothbug_snare/Initialize(mapload, mob/living/simple_animal/mothbug/spinner)
	. = ..()
	if(spinner)
		spinner_ref = WEAKREF(spinner)
		spinner.snares += src

/obj/structure/mothbug_snare/Destroy()
	var/mob/living/simple_animal/mothbug/spinner = spinner_ref?.resolve()
	if(spinner?.snares)
		spinner.snares -= src
	spinner_ref = null
	return ..()

/obj/structure/mothbug_snare/Crossed(atom/movable/crosser)
	. = ..()
	if(!iscarbon(crosser) || !isturf(loc))
		return
	var/mob/living/carbon/victim = crosser
	if(victim.throwing || (victim.movement_type & MOVETYPE_NOT_TOUCHING_GROUND) || victim.legcuffed || victim.num_legs < 2)
		return
	var/obj/item/rope/spider_silk/moth/snare/cuffs = new(loc)
	cuffs.apply_cuffs(victim, null, leg = TRUE)
	if(victim.legcuffed != cuffs)
		qdel(cuffs)
		return
	victim.visible_message(span_danger("[victim] stumbles as a loop of silk snaps tight around [victim.p_their()] legs!"), span_userdanger("A loop of silk snaps tight around my legs!"))
	playsound(src, 'sound/combat/hits/nodmg (2).ogg', 50, TRUE)
	var/mob/living/simple_animal/mothbug/spinner = spinner_ref?.resolve()
	if(spinner?.stat == CONSCIOUS)
		to_chat(spinner, span_notice("A distant thread trembles: my snare in [get_area_name(src)] caught someone."))
	qdel(src)

/obj/structure/mothbug_cocoon
	name = "silk cocoon"
	desc = "A thick, person-sized bundle of pale silk, wound tight."
	icon = 'modular_rmh/icons/obj/mothbug_silk.dmi'
	icon_state = "cocoon"
	density = TRUE
	anchored = FALSE
	max_integrity = 60
	resistance_flags = FLAMMABLE
	static_debris = list(/obj/item/natural/silk = 2)
	var/datum/weakref/spinner_ref
	var/digest_timer

/obj/structure/mothbug_cocoon/Initialize(mapload, mob/living/simple_animal/mothbug/spinner)
	. = ..()
	if(spinner)
		spinner_ref = WEAKREF(spinner)

/obj/structure/mothbug_cocoon/Destroy()
	if(digest_timer)
		deltimer(digest_timer)
	var/turf/drop_turf = get_turf(src)
	for(var/atom/movable/inside as anything in contents)
		inside.forceMove(drop_turf)
	spinner_ref = null
	return ..()

/obj/structure/mothbug_cocoon/examine(mob/user)
	. = ..()
	if(locate(/mob/living) in src)
		. += span_warning("Something person-shaped is bound inside. A blade could cut it open.")

/obj/structure/mothbug_cocoon/proc/enclose(mob/living/victim)
	victim.forceMove(src)
	visible_message(span_danger("Silk winds tight around [victim] until only a pale cocoon remains!"))
	to_chat(victim, span_userdanger("Soft silk swallows me whole. I can struggle free, given time."))
	digest_timer = addtimer(CALLBACK(src, PROC_REF(digest)), MOTHBUG_COCOON_DIGEST_INTERVAL, TIMER_STOPPABLE|TIMER_LOOP)

/// The cocoon slowly eats the occupant's outer fabric and feeds the mothbug that spun it.
/obj/structure/mothbug_cocoon/proc/digest()
	var/mob/living/carbon/human/victim = locate() in src
	if(!victim)
		return
	var/static/list/digest_zones = list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK)
	for(var/zone in shuffle(digest_zones.Copy()))
		var/obj/item/garment = get_mothbug_outer_garment(victim, zone)
		if(!garment || !get_mothbug_fabric_value(garment) || is_mothbug_repelled(garment))
			continue
		var/garment_name = garment.name
		var/gained = take_mothbug_bite(garment) * 0.5
		var/mob/living/simple_animal/mothbug/spinner = spinner_ref?.resolve()
		if(spinner && spinner.stat != DEAD)
			spinner.credit_fabric(gained)
		to_chat(victim, span_warning("Something in the silk nibbles at my [garment_name][QDELETED(garment) ? " until it falls away" : ""]."))
		return
	to_chat(victim, span_love("Soft silk shifts and brushes over my bare skin."))
	if(mothbug_target_allows(victim, /datum/erp_preference/boolean/lust_magic_targetable))
		SEND_SIGNAL(victim, COMSIG_SEX_ADJUST_AROUSAL, 0.3)

/obj/structure/mothbug_cocoon/container_resist(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, span_notice("I struggle against the clinging silk... (This will take about [DisplayTimeText(MOTHBUG_COCOON_BREAKOUT)].)"))
	visible_message(span_notice("[src] squirms and bulges."))
	if(!do_after(user, MOTHBUG_COCOON_BREAKOUT, src, IGNORE_USER_LOC_CHANGE))
		return
	if(QDELETED(src) || user.loc != src)
		return
	visible_message(span_warning("[user] tears free of [src]!"))
	qdel(src)

/obj/structure/mothbug_cocoon/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	if(!attacking_item.get_sharpness() || !(locate(/mob/living) in src))
		return ..()
	user.visible_message(span_notice("[user] starts cutting [src] open."), span_notice("I start cutting [src] open."))
	if(!do_after(user, MOTHBUG_COCOON_CUT_TIME, src))
		return TRUE
	user.visible_message(span_notice("[user] slices [src] open."))
	qdel(src)
	return TRUE

/obj/effect/temp_visual/small_smoke/mothbug_dust
	name = "wing dust"
	color = "#e2d4b4"
	alpha = 170
	duration = 1.5 SECONDS
