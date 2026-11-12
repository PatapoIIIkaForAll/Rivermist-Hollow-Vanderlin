// Spider silk wound onto a victim: a gag, a blindfold and a hobble. Spider-made only, no recipes, no price.

/// The pale tint all three pieces share.
#define SPIDER_SILK_COLOUR "#dfe3ea"
/// Trait source for silk held fast in its slot.
#define SPIDER_SILK_TRAIT "spider_silk"
/// Bare hands tear this long past strip_delay; a blade needs strip_delay alone.
#define SPIDER_SILK_TEAR_EXTRA (3 SECONDS)
/// How often honeyed silk seeps into the wearer's mouth.
#define SPIDER_SILK_HONEY_INTERVAL (1 MINUTES)

/// TRUE for silk a spider bound onto its prey; the spider's own strip step leaves it alone.
/proc/is_spider_silk_item(obj/item/item)
	var/static/list/silk_types = typecacheof(list(
		/obj/item/clothing/face/bdsm_gag/silk,
		/obj/item/clothing/face/blindfold/silk,
		/obj/item/clothing/legwears/silk_hobble,
		/obj/item/rope/spider_silk,
	))
	return is_type_in_typecache(item, silk_types)

/// TRUE while the silk sits stuck in its slot on a wearer.
/proc/spider_silk_is_bound(obj/item/silk)
	return HAS_TRAIT_FROM(silk, TRAIT_NODROP, SPIDER_SILK_TRAIT)

/// Beespiders spin honeyed silk; the clockwork one does not.
/proc/spider_spins_honeyed_silk(mob/living/spinner)
	var/mob/living/simple_animal/hostile/retaliate/spider/beespider = spinner
	return istype(beespider) && beespider.makes_honey

/// The body part a piece of silk binds: mouth, eyes, thighs or wrists.
/proc/spider_silk_body_part(obj/item/silk)
	if(istype(silk, /obj/item/clothing/face/bdsm_gag/silk))
		return "mouth"
	if(istype(silk, /obj/item/clothing/face/blindfold/silk))
		return "eyes"
	if(istype(silk, /obj/item/clothing/legwears/silk_hobble))
		return "thighs"
	return "wrists"

/// Bound silk that comes away falls apart into two strands of plain silk.
/proc/spider_silk_shred(obj/item/silk)
	var/turf/drop_turf = get_turf(silk)
	qdel(silk)
	if(!drop_turf)
		return
	for(var/i in 1 to 2)
		new /obj/item/natural/silk(drop_turf)
	playsound(drop_turf, 'sound/foley/cloth_rip.ogg', 40, TRUE)

/// The wearer works the silk off over slipouttime. TRUE when it came apart.
/proc/spider_silk_struggle(obj/item/silk, mob/living/wearer)
	if(silk.item_flags & BEING_REMOVED)
		to_chat(wearer, span_warning("I'm already working at [silk]!"))
		return FALSE
	silk.item_flags |= BEING_REMOVED
	wearer.last_special = world.time + CLICK_CD_BREAKOUT
	var/part = spider_silk_body_part(silk)
	to_chat(wearer, span_notice("I pull at the silk on my [part]. (This will take about [DisplayTimeText(silk.slipouttime)].)"))
	var/freed = do_after(wearer, silk.slipouttime, timed_action_flags = IGNORE_HELD_ITEM)
	silk.item_flags &= ~BEING_REMOVED
	if(QDELETED(silk) || silk.loc != wearer || !spider_silk_is_bound(silk))
		return FALSE
	if(!freed)
		to_chat(wearer, span_danger("The silk on my [part] holds!"))
		return FALSE
	wearer.felt_visible_message(span_warning("[wearer] pulls the silk off [wearer.p_their()] [part]!"), span_notice("I pull the silk off my [part]."))
	spider_silk_shred(silk)
	return TRUE

/// Others strip bound silk: a blade has cut it already, bare hands tear on. FALSE, as nothing survives.
/proc/spider_silk_strip(obj/item/silk, mob/living/stripper, mob/living/wearer)
	var/obj/item/held = stripper.get_active_held_item()
	var/cutting = held?.get_sharpness()
	var/part = spider_silk_body_part(silk)
	if(!cutting)
		to_chat(stripper, span_notice("The silk on [wearer]'s [part] holds. I keep tearing at it."))
		if(!do_after(stripper, SPIDER_SILK_TEAR_EXTRA, wearer))
			return FALSE
		if(QDELETED(silk) || silk.loc != wearer)
			return FALSE
	var/how = cutting ? "cuts" : "tears"
	wearer.felt_visible_message(span_warning("[stripper] [how] the silk off [wearer]'s [part]."), span_warning("[stripper] [how] the silk off my [part]."))
	spider_silk_shred(silk)
	return FALSE

/// A blade parts worn silk in strip_delay. TRUE when it was cut away.
/proc/spider_silk_cut(obj/item/silk, mob/living/user, mob/living/wearer)
	var/part = spider_silk_body_part(silk)
	to_chat(user, span_notice("I start to cut the silk off [user == wearer ? "my" : "[wearer]'s"] [part]."))
	if(!do_after(user, silk.strip_delay, wearer))
		return FALSE
	if(QDELETED(silk) || silk.loc != wearer)
		return FALSE
	if(user == wearer)
		wearer.felt_visible_message(span_notice("[user] cuts the silk off [user.p_their()] [part]."), span_notice("I cut the silk off my [part]."))
	else
		wearer.felt_visible_message(span_notice("[user] cuts the silk off [wearer]'s [part]."), span_notice("[user] cuts the silk off my [part]."))
	spider_silk_shred(silk)
	return TRUE

/// Holds worn silk in one slot: Resist struggles it off, a blade cuts it, bare hands tear it.
/datum/component/spider_silk_bond
	/// The slot the silk binds in; anywhere else it is loose.
	var/bound_slot

/datum/component/spider_silk_bond/Initialize(bound_slot)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.bound_slot = bound_slot

/datum/component/spider_silk_bond/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/component/spider_silk_bond/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ATOM_ATTACKBY))

/datum/component/spider_silk_bond/proc/on_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot != bound_slot)
		unbind(equipper)
		return
	ADD_TRAIT(source, TRAIT_NODROP, SPIDER_SILK_TRAIT)
	RegisterSignal(equipper, COMSIG_LIVING_RESIST, PROC_REF(on_wearer_resist), override = TRUE)

/datum/component/spider_silk_bond/proc/on_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	unbind(user)

/datum/component/spider_silk_bond/proc/unbind(mob/user)
	REMOVE_TRAIT(parent, TRAIT_NODROP, SPIDER_SILK_TRAIT)
	if(user)
		UnregisterSignal(user, COMSIG_LIVING_RESIST)

/datum/component/spider_silk_bond/proc/on_wearer_resist(mob/living/carbon/source)
	SIGNAL_HANDLER
	var/obj/item/silk = parent
	if(!iscarbon(source) || silk.loc != source || source.doing() || source.last_special > world.time)
		return
	// Resist goes to cuffs, a hold, a buckle, a container or flames before silk.
	if(source.handcuffed || source.legcuffed || source.pulledby || source.buckled || !isturf(source.loc) || source.on_fire)
		return
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spider_silk_struggle), silk, source)

/datum/component/spider_silk_bond/proc/on_attackby(obj/item/source, obj/item/attacking_item, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!spider_silk_is_bound(source) || !isliving(source.loc) || !attacking_item.get_sharpness())
		return NONE
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spider_silk_cut), source, user, source.loc)
	return COMPONENT_NO_AFTERATTACK

// --- Silk gag -------------------------------------------------------------------------------------

/obj/item/clothing/face/bdsm_gag/silk
	name = "silk gag"
	desc = "Spider silk packed into the mouth and wound around the jaw."
	icon = 'icons/roguetown/items/natural.dmi'
	// Raw silk in hand; the worn sheet repeats this state name with the gag's suffixes.
	icon_state = "fibers"
	mob_overlay_icon = 'modular_rmh/icons/clothing/onmob/spider_silk_onmob.dmi'
	color = SPIDER_SILK_COLOUR
	can_lower = FALSE
	strip_delay = 3 SECONDS
	slipouttime = 20 SECONDS
	sellprice = 0
	grid_width = 32
	grid_height = 32
	salvage_result = /obj/item/natural/silk
	salvage_amount = 2
	misc_flags = CRAFTING_TEST_EXCLUDE
	/// Beespider silk: honey and a little aphrodisiac seep into the wearer's mouth.
	var/honeyed = FALSE
	/// The looping seep while honeyed silk is worn.
	var/honey_timer

/obj/item/clothing/face/bdsm_gag/silk/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/spider_silk_bond, ITEM_SLOT_MASK)

/obj/item/clothing/face/bdsm_gag/silk/update_overlays()
	. = ..()
	// The base gag's leather and buckles have no place on silk.
	for(var/mutable_appearance/detail in .)
		if(detail.icon == 'modular_rmh/icons/clothing/bdsm_gag_fixed_items.dmi')
			. -= detail

/obj/item/clothing/face/bdsm_gag/silk/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, dummy_block = FALSE)
	. = ..()
	for(var/mutable_appearance/detail in .)
		if(detail.icon == 'modular_rmh/icons/clothing/onmob/bdsm_gag_fixed_onmob.dmi')
			. -= detail

/obj/item/clothing/face/bdsm_gag/silk/equipped(mob/user, slot)
	. = ..()
	if(!honeyed || slot != ITEM_SLOT_MASK)
		stop_honey()
		return
	if(!honey_timer)
		honey_timer = addtimer(CALLBACK(src, PROC_REF(seep_honey)), SPIDER_SILK_HONEY_INTERVAL, TIMER_STOPPABLE | TIMER_LOOP | TIMER_DELETE_ME)

/obj/item/clothing/face/bdsm_gag/silk/dropped(mob/user)
	. = ..()
	stop_honey()

/obj/item/clothing/face/bdsm_gag/silk/examine(mob/user)
	. = ..()
	if(honeyed)
		. += span_notice("It glistens with honey.")

/obj/item/clothing/face/bdsm_gag/silk/canStrip(mob/stripper, mob/owner)
	return spider_silk_is_bound(src) ? stripper != owner : ..()

/obj/item/clothing/face/bdsm_gag/silk/doStrip(mob/stripper, mob/owner)
	return spider_silk_is_bound(src) ? spider_silk_strip(src, stripper, owner) : ..()

/obj/item/clothing/face/bdsm_gag/silk/allow_attack_hand_drop(mob/user)
	if(!spider_silk_is_bound(src))
		return ..()
	spider_silk_struggle(src, user)
	return FALSE

/obj/item/clothing/face/bdsm_gag/silk/proc/stop_honey()
	if(!honey_timer)
		return
	deltimer(honey_timer)
	honey_timer = null

/// One minute's seep of honey and a little aphrodisiac into the wearer's mouth.
/obj/item/clothing/face/bdsm_gag/silk/proc/seep_honey()
	var/mob/living/carbon/wearer = loc
	if(!istype(wearer) || wearer.wear_mask != src || !wearer.reagents)
		return
	wearer.reagents.add_reagent(/datum/reagent/consumable/honey, 0.5)
	wearer.reagents.add_reagent(/datum/reagent/consumable/aphrodisiac, 0.2)
	to_chat(wearer, span_love("Honey from the silk in my mouth runs onto my tongue."))

// --- Silk blindfold -------------------------------------------------------------------------------

/obj/item/clothing/face/blindfold/silk
	name = "silk blindfold"
	desc = "Spider silk wound over the eyes. The wearer cannot see."
	icon_state = "blindfoldwhite"
	item_state = "blindfoldwhite"
	color = SPIDER_SILK_COLOUR
	// Worn on the head so the mask slot stays free for a gag.
	slot_flags = ITEM_SLOT_HEAD
	strip_delay = 3 SECONDS
	slipouttime = 20 SECONDS
	sellprice = 0
	salvage_result = /obj/item/natural/silk
	salvage_amount = 2
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/face/blindfold/silk/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/spider_silk_bond, ITEM_SLOT_HEAD)

/obj/item/clothing/face/blindfold/silk/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/wearer = user
	if(slot != ITEM_SLOT_HEAD)
		UnregisterSignal(wearer, COMSIG_PARENT_EXAMINE)
		return
	wearer.become_blind("blindfold_[REF(src)]")
	RegisterSignal(wearer, COMSIG_PARENT_EXAMINE, PROC_REF(on_wearer_examine), override = TRUE)

/obj/item/clothing/face/blindfold/silk/dropped(mob/user, silent = FALSE)
	. = ..()
	UnregisterSignal(user, COMSIG_PARENT_EXAMINE)

/obj/item/clothing/face/blindfold/silk/canStrip(mob/stripper, mob/owner)
	return spider_silk_is_bound(src) ? stripper != owner : ..()

/obj/item/clothing/face/blindfold/silk/doStrip(mob/stripper, mob/owner)
	return spider_silk_is_bound(src) ? spider_silk_strip(src, stripper, owner) : ..()

/obj/item/clothing/face/blindfold/silk/allow_attack_hand_drop(mob/user)
	if(!spider_silk_is_bound(src))
		return ..()
	spider_silk_struggle(src, user)
	return FALSE

/obj/item/clothing/face/blindfold/silk/proc/on_wearer_examine(mob/living/source, mob/user, list/examine_sections, list/pronouns)
	SIGNAL_HANDLER
	if(!islist(pronouns))
		return
	LAZYADDASSOCLIST(examine_sections, EXAMINE_SECT_WARNING, span_warning("[pronouns[THEY]] cannot see who is doing what to [pronouns[THEM]]."))

// --- Silk hobble ----------------------------------------------------------------------------------

/obj/item/clothing/legwears/silk_hobble
	name = "silk hobble"
	desc = "Spider silk wound around the thighs to hold the legs apart. The wearer cannot stand."
	icon_state = "fishnet_thighs"
	item_state = "fishnet_thighs"
	color = SPIDER_SILK_COLOUR
	slot_flags = ITEM_SLOT_SOCKS
	body_parts_covered = NONE
	genital_access = TRUE
	damaged_icon = null
	damaged_overlay_icon = null
	strip_delay = 3 SECONDS
	slipouttime = 30 SECONDS
	sellprice = 0
	salvage_result = /obj/item/natural/silk
	salvage_amount = 2
	misc_flags = CRAFTING_TEST_EXCLUDE

/obj/item/clothing/legwears/silk_hobble/Initialize(mapload, ...)
	. = ..()
	AddComponent(/datum/component/spider_silk_bond, ITEM_SLOT_SOCKS)

/obj/item/clothing/legwears/silk_hobble/equipped(mob/living/carbon/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_SOCKS)
		ADD_TRAIT(user, TRAIT_FLOORED, REF(src))
	else
		REMOVE_TRAIT(user, TRAIT_FLOORED, REF(src))

/obj/item/clothing/legwears/silk_hobble/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_FLOORED, REF(src))

/obj/item/clothing/legwears/silk_hobble/canStrip(mob/stripper, mob/owner)
	return spider_silk_is_bound(src) ? stripper != owner : ..()

/obj/item/clothing/legwears/silk_hobble/doStrip(mob/stripper, mob/owner)
	return spider_silk_is_bound(src) ? spider_silk_strip(src, stripper, owner) : ..()

/obj/item/clothing/legwears/silk_hobble/allow_attack_hand_drop(mob/user)
	if(!spider_silk_is_bound(src))
		return ..()
	spider_silk_struggle(src, user)
	return FALSE

// Silk gives to a blade or a struggle, never to a ladder.
/obj/item/clothing/legwears/silk_hobble/snag(amount, damage_flag = SLASH)
	return 0

/obj/item/clothing/legwears/silk_hobble/tear_open(damage_flag = SLASH)
	return FALSE
