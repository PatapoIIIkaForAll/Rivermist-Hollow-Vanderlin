#define BREAST_VISUAL_ICON 'modular_rmh/icons/mob/sprite_accessory/genitals/breasts_anim.dmi'
#define BREAST_VISUAL_LAYER (MOB_LAYER + 0.01)
#define BREAST_ANIM_MIN_SIZE 5
#define BREAST_ANIM_MAX_SIZE 8
#define BREAST_RUN_STOP_DELAY (0.35 SECONDS)
#define BREAST_HIT_MIN_DAMAGE 5
/// Slowdown above the configured walk delay from which a step plays the slow cycle instead.
#define BREAST_SLOW_STEP_EXTRA 1
/// Step delay from which the slow cycle shows all eight frames.
#define BREAST_SLOW_FULL_CYCLE (1.2 SECONDS)
#define BREAST_GARMENT_LAYER_STEP 0.01
#define BREAST_GARMENT_DETAIL_LAYER_STEP 0.001
#define BREAST_WORN_UPDATE_DELAY 1

/// Emote key to the one-shot it plays on the breasts.
GLOBAL_LIST_INIT(breast_emote_shots, list(
	"laugh" = "laugh",
	"giggle" = "walk",
	"sigh" = "walk_half",
	"cough" = "cough",
	"clearthroat" = "clearthroat",
	"jump" = "jump",
	"dance" = "dance",
	"shiver" = "shiver",
))

/// Whether a breast size has drawn animation frames.
/proc/is_animated_breast_size(size)
	return isnum(size) && size >= BREAST_ANIM_MIN_SIZE && size <= BREAST_ANIM_MAX_SIZE

/// South view of animated breasts, shown through a human's vis_contents only.
/atom/movable/breast_visual
	icon = BREAST_VISUAL_ICON
	layer = BREAST_VISUAL_LAYER
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_DIR
	appearance_flags = PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	/// Taur clip mask the alpha filter was built from.
	var/icon/clip_mask

/atom/movable/breast_visual/update_overlays()
	. = ..()
	if(icon_state)
		. += emissive_blocker(icon, icon_state)

/// Drives the breasts child of a human: state, colour, offset and one-shots. Children take the mob's rotation from the engine.
/datum/component/breast_animation
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The vis_contents child, null while the breasts are not animated.
	var/atom/movable/breast_visual/visual
	/// Whether the run cycle plays instead of the walk cycle.
	var/running = FALSE
	/// Whether the jiggle loop plays; it outranks the run and walk cycles.
	var/jiggling = FALSE
	/// Visible size the child shows.
	var/size
	/// world.time of the last step taken while running.
	var/last_run_step = 0
	/// Chest slot name to the child drawing that garment's front cloth.
	var/list/garment_visuals
	/// Chest slot name to the child drawing that garment's front detail paint.
	var/list/garment_detail_visuals
	/// Breast size and child state the worn garment sprites were last rebuilt for.
	var/last_worn_key

/datum/component/breast_animation/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/breast_animation/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_APPLY_OVERLAY, PROC_REF(on_apply_overlay))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	RegisterSignal(parent, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_knocked_down))
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(on_landed))
	RegisterSignal(parent, COMSIG_SEX_CLIMAX, PROC_REF(on_climax))
	RegisterSignal(parent, COMSIG_MOB_EMOTE, PROC_REF(on_emote))
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignals(parent, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM), PROC_REF(on_equipment_changed))
	refresh()

/datum/component/breast_animation/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_LIVING_APPLY_OVERLAY,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_MOVABLE_THROW_LANDED,
		COMSIG_SEX_CLIMAX,
		COMSIG_MOB_EMOTE,
		COMSIG_MOB_LOGIN,
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_UNEQUIPPED_ITEM,
	))
	stop_jiggle()
	remove_visual()

/datum/component/breast_animation/Destroy(force)
	stop_jiggle()
	remove_visual()
	return ..()

/// Breasts organ of the parent when it should animate, else null.
/datum/component/breast_animation/proc/get_animated_breasts()
	var/mob/living/carbon/human/human = parent
	if(QDELETED(human) || istype(human, /mob/living/carbon/human/dummy) || !human.dna?.species)
		return null
	if(!human.breast_children_allowed())
		return null
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = human.getorganslot(ORGAN_SLOT_BREASTS)
	if(!istype(breasts) || !ispath(breasts.accessory_type, /datum/sprite_accessory/genitals/breasts/pair))
		return null
	if(!is_animated_breast_size(breasts.get_visible_size()))
		return null
	return breasts

/// Creates, updates or deletes the children to match the parent's breasts and chest garments.
/datum/component/breast_animation/proc/refresh()
	var/mob/living/carbon/human/human = parent
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = get_animated_breasts()
	if(!breasts)
		if(visual)
			remove_visual()
			// The render key holds whether the child exists, so the body redraws its full still.
			if(!QDELETED(human))
				human.update_body_parts()
		check_worn_key()
		if(!QDELETED(human))
			human.update_breast_size_effect()
		return
	var/created = FALSE
	if(!visual)
		visual = add_child(BREAST_VISUAL_LAYER)
		created = TRUE
	size = breasts.get_visible_size()
	set_visual_state()
	var/list/colors = color_string_to_list(breasts.accessory_colors)
	visual.color = length(colors) ? colors[1] : null
	var/list/offsets = human.get_genital_offsets()
	var/list/breast_offset = LAZYACCESS(offsets, OFFSET_BREASTS)
	var/obj/item/bodypart/taur/taur = human.get_bodypart(BODY_ZONE_TAUR)
	visual.pixel_x = length(breast_offset) >= 2 ? breast_offset[1] : 0
	visual.pixel_y = (length(breast_offset) >= 2 ? breast_offset[2] : 0) + (taur ? taur.body_offset_y : 0)
	// "Show above clothes" keeps the breasts out over a closed garment.
	var/draw_above = breasts.visible_through_clothes == DRAW_ABOVE
	if(is_shown(breasts) && (draw_above || !human.breasts_covered_by_closed_garment()))
		visual.vis_flags &= ~VIS_HIDE
	else
		visual.vis_flags |= VIS_HIDE
	refresh_garments(breasts)
	update_lipstick_child()
	update_piercing_child()
	// The body drops its south view once the child exists.
	if(created)
		human.update_body_parts()
	check_worn_key()
	human.update_breast_size_effect()

/// Mirrors the checks that decide whether the body overlay draws the breasts.
/datum/component/breast_animation/proc/is_shown(obj/item/organ/genitals/filling_organ/breasts/breasts)
	var/mob/living/carbon/human/human = parent
	var/obj/item/bodypart/chest = human.get_bodypart(BODY_ZONE_CHEST)
	if(!chest || chest.skeletonized || !breasts.is_visible())
		return FALSE
	if(NO_ORGAN_FEATURES in human.dna.species.species_traits)
		return FALSE
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(breasts.accessory_type)
	return accessory.is_visible(breasts, chest, human)

/// Creates, updates or deletes the garment children to match the parent's worn sized garments.
/datum/component/breast_animation/proc/refresh_garments(obj/item/organ/genitals/filling_organ/breasts/breasts)
	var/mob/living/carbon/human/human = parent
	// A child draws above every overlay, so a plain garment over the chest leaves no garment child.
	// Plain layers beneath the sized garments only hide the breasts; the garments keep their front cloth.
	if(breasts.visible_through_clothes == DRAW_ABOVE || !breasts_visible_under_clothes(human, skip_under_layers = TRUE))
		remove_garment_visuals()
		return
	var/list/garments = human.get_breast_sized_garments()
	var/list/offsets = human.get_offset_features()
	var/obj/item/bodypart/taur/taur_body = human.get_bodypart(BODY_ZONE_TAUR)
	var/body_offset_y = taur_body ? taur_body.body_offset_y : 0
	var/obj/item/bodypart/taur/taur_tail = human.get_taur_tail()
	for(var/index in 1 to length(GLOB.breast_sized_slots))
		var/slot = GLOB.breast_sized_slots[index]
		var/obj/item/garment = garments[slot]
		if(!garment)
			remove_garment_visual(slot)
			continue
		var/list/offset = LAZYACCESS(offsets, get_breast_sized_offset_key(slot))
		var/hidden = garment.is_under_closed_breast_sized(human, garments)
		update_garment_visual(slot, garment, BREAST_VISUAL_LAYER + index * BREAST_GARMENT_LAYER_STEP, hidden, offset, body_offset_y, taur_tail?.clip_mask)

/// Sets the front cloth child, and the detail child when the sheet paints one, of one worn garment.
/datum/component/breast_animation/proc/update_garment_visual(slot, obj/item/garment, garment_layer, hidden, list/offset, body_offset_y, icon/clip_mask)
	if(!icon_exists(garment.breast_sized_icon, "[garment.icon_state]_f_[size]_front"))
		remove_garment_visual(slot)
		return
	var/atom/movable/breast_visual/child = LAZYACCESS(garment_visuals, slot)
	if(!child)
		child = add_child(garment_layer)
		LAZYSET(garment_visuals, slot, child)
	place_garment_child(child, garment.breast_sized_icon, get_garment_state(garment, FALSE), hidden, offset, body_offset_y, clip_mask)
	child.color = garment.color
	child.alpha = garment.alpha
	var/atom/movable/breast_visual/detail = LAZYACCESS(garment_detail_visuals, slot)
	if(!garment.get_detail_tag() || !icon_exists(garment.breast_sized_icon, "[get_garment_state_prefix(garment, TRUE)]_front"))
		if(detail)
			remove_child(detail)
			LAZYREMOVE(garment_detail_visuals, slot)
		return
	if(!detail)
		detail = add_child(garment_layer + BREAST_GARMENT_DETAIL_LAYER_STEP)
		detail.appearance_flags |= RESET_COLOR
		LAZYSET(garment_detail_visuals, slot, detail)
	place_garment_child(detail, garment.breast_sized_icon, get_garment_state(garment, TRUE), hidden, offset, body_offset_y, clip_mask)
	detail.color = garment.get_detail_color()
	detail.alpha = garment.alpha

/// Rest state of a garment child for the current size and gait, the jiggle loop first.
/// "<state>_f[_detail]_<size key>": the size key carries a custom race's clothing tag.
/datum/component/breast_animation/proc/get_garment_state_prefix(obj/item/garment, detail)
	var/mob/living/carbon/human/human = parent
	var/size_key = garment.get_breast_sized_size_key(human) || "[size]"
	return "[garment.icon_state]_f[detail ? "_detail" : ""]_[size_key]"

/datum/component/breast_animation/proc/get_garment_state(obj/item/garment, detail)
	var/prefix = get_garment_state_prefix(garment, detail)
	if(jiggling && icon_exists(garment.breast_sized_icon, "[prefix]_jiggle_front"))
		return "[prefix]_jiggle_front"
	return "[prefix][running ? "_run" : ""]_front"

/// Positions a garment child as the matching worn overlay is placed, with the taur clip.
/datum/component/breast_animation/proc/place_garment_child(atom/movable/breast_visual/child, new_icon, new_state, hidden, list/offset, body_offset_y, icon/clip_mask)
	set_child_look(child, new_icon, new_state)
	child.pixel_x = length(offset) >= 2 ? offset[1] : 0
	child.pixel_y = (length(offset) >= 2 ? offset[2] : 0) + body_offset_y
	if(child.clip_mask != clip_mask)
		child.clip_mask = clip_mask
		child.filters = istype(clip_mask) ? list(filter(type = "alpha", icon = clip_mask)) : list()
	if(hidden)
		child.vis_flags |= VIS_HIDE
	else
		child.vis_flags &= ~VIS_HIDE

/// Sets the rest state of every garment child after a gait change.
/datum/component/breast_animation/proc/update_garment_states()
	var/mob/living/carbon/human/human = parent
	for(var/slot in garment_visuals)
		var/obj/item/garment = human.get_chest_slot_item(slot)
		if(!garment)
			continue
		set_child_look(garment_visuals[slot], garment.breast_sized_icon, get_garment_state(garment, FALSE))
		var/atom/movable/breast_visual/detail = LAZYACCESS(garment_detail_visuals, slot)
		if(detail)
			set_child_look(detail, garment.breast_sized_icon, get_garment_state(garment, TRUE))

/datum/component/breast_animation/proc/add_child(child_layer)
	var/atom/movable/breast_visual/child = new /atom/movable/breast_visual(null)
	child.layer = child_layer
	var/atom/movable/movable_parent = parent
	movable_parent.vis_contents += child
	return child

/datum/component/breast_animation/proc/remove_child(atom/movable/breast_visual/child)
	var/atom/movable/movable_parent = parent
	if(movable_parent)
		movable_parent.vis_contents -= child
	qdel(child)

/datum/component/breast_animation/proc/remove_garment_visual(slot)
	var/atom/movable/breast_visual/child = LAZYACCESS(garment_visuals, slot)
	if(child)
		remove_child(child)
		LAZYREMOVE(garment_visuals, slot)
	var/atom/movable/breast_visual/detail = LAZYACCESS(garment_detail_visuals, slot)
	if(detail)
		remove_child(detail)
		LAZYREMOVE(garment_detail_visuals, slot)

/datum/component/breast_animation/proc/remove_garment_visuals()
	for(var/slot in GLOB.breast_sized_slots)
		remove_garment_visual(slot)

/// Every child currently in the parent's vis_contents.
/datum/component/breast_animation/proc/get_children()
	. = list()
	if(visual)
		. += visual
	for(var/slot in garment_visuals)
		. += garment_visuals[slot]
	for(var/slot in garment_detail_visuals)
		. += garment_detail_visuals[slot]

/// Rebuilds the worn garment sprites once the breast size or the child's existence changes.
/datum/component/breast_animation/proc/check_worn_key()
	var/mob/living/carbon/human/human = parent
	if(QDELETED(human))
		return
	var/obj/item/organ/genitals/filling_organ/breasts/breasts = human.getorganslot(ORGAN_SLOT_BREASTS)
	var/worn_key = istype(breasts) ? "[breasts.accessory_type]|[breasts.get_visible_size()]|[!!visual]" : "none"
	// A cover change (a plain dress over a sized bra) must rebuild the garments below it too.
	for(var/slot in GLOB.breast_sized_slots)
		var/obj/item/garment = human.get_chest_slot_item(slot)
		worn_key += "|[garment?.breast_sized_icon ? garment.uses_breast_sized_layers(human) : "-"]"
	if(worn_key == last_worn_key)
		return
	last_worn_key = worn_key
	// Deferred, since this runs inside the clothing updates it would start again.
	if(human.wears_breast_sized_sheet())
		addtimer(CALLBACK(src, PROC_REF(update_worn_garments)), BREAST_WORN_UPDATE_DELAY, TIMER_UNIQUE)

/datum/component/breast_animation/proc/update_worn_garments()
	if(QDELETED(src))
		return
	var/mob/living/carbon/human/human = parent
	if(QDELETED(human))
		return
	human.update_breast_sized_worn(all_sheets = TRUE)

/// Sets the child's rest state for the current size and gait, the jiggle loop first.
/datum/component/breast_animation/proc/set_visual_state()
	var/gait = jiggling ? "jiggle_" : (running ? "run_" : "")
	set_child_look(visual, BREAST_VISUAL_ICON, "pair_[size]_[gait]front_ADJ")
	update_lipstick_child()
	update_piercing_child()

/// Sets a child's icon and state, and its emissive blocker with them.
/datum/component/breast_animation/proc/set_child_look(atom/movable/breast_visual/child, new_icon, new_state)
	if(child.icon == new_icon && child.icon_state == new_state)
		return
	child.icon = new_icon
	child.icon_state = new_state
	child.update_appearance(UPDATE_OVERLAYS)

/datum/component/breast_animation/proc/remove_visual()
	remove_lipstick_child()
	remove_piercing_child()
	remove_garment_visuals()
	running = FALSE
	size = null
	if(!visual)
		return
	remove_child(visual)
	visual = null

/// Plays a one-shot on every shown child, then each returns to its rest state.
/datum/component/breast_animation/proc/play_shot(shot, side_jiggle = TRUE)
	if(!visual)
		play_small_shot(shot)
		return
	var/mob/living/carbon/human/human = parent
	// One-shots exist for the south view only; facing elsewhere a jiggle cycle shows the motion.
	if(side_jiggle && human.dir != SOUTH)
		play_side_shot()
		return
	if(!(visual.vis_flags & VIS_HIDE))
		flick("pair_[size]_[shot]_front_ADJ", visual)
		flick_lipstick_child(shot)
		flick_piercing_child(shot)
	for(var/slot in garment_visuals)
		var/atom/movable/breast_visual/child = garment_visuals[slot]
		var/obj/item/garment = human.get_chest_slot_item(slot)
		if(!garment || (child.vis_flags & VIS_HIDE))
			continue
		// The prefix carries the race clothing tag, so small races flick their own frames.
		flick("[get_garment_state_prefix(garment, FALSE)]_[shot]_front", child)
		var/atom/movable/breast_visual/detail = LAZYACCESS(garment_detail_visuals, slot)
		if(detail)
			flick("[get_garment_state_prefix(garment, TRUE)]_[shot]_front", detail)

/datum/component/breast_animation/proc/set_running(new_running)
	if(running == new_running || !visual)
		return
	running = new_running
	// The jiggle loop outranks the run cycle, so only the flag changes until it stops.
	if(jiggling)
		return
	set_visual_state()
	update_garment_states()
	var/mob/living/carbon/human/human = parent
	human.update_body_parts()
	human.update_breast_sized_worn()

/// Swaps the children, body overlay and worn sprites to or from the jiggle loop; works without a child.
/datum/component/breast_animation/proc/set_jiggling(new_jiggling)
	if(jiggling == new_jiggling)
		return
	jiggling = new_jiggling
	var/mob/living/carbon/human/human = parent
	if(QDELETED(human))
		return
	if(visual)
		set_visual_state()
		update_garment_states()
	human.update_body_parts()
	human.update_breast_sized_worn()

/datum/component/breast_animation/proc/check_run_stop()
	if(QDELETED(src) || !running)
		return
	if(world.time - last_run_step < BREAST_RUN_STOP_DELAY)
		return
	set_running(FALSE)
	// The jiggle loop never showed the run cycle, so there is nothing to settle.
	if(!jiggling)
		play_shot("stop", side_jiggle = FALSE)

/// A garment change may add or remove a plain cover; the children are re-evaluated once the slot settles.
/datum/component/breast_animation/proc/on_equipment_changed(datum/source)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(refresh_after_equip)), 1, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/component/breast_animation/proc/refresh_after_equip()
	if(QDELETED(src))
		return
	refresh()

/datum/component/breast_animation/proc/on_apply_overlay(datum/source, cache_index, overlay)
	SIGNAL_HANDLER
	if(cache_index == BODYPARTS_LAYER)
		refresh()

/datum/component/breast_animation/proc/on_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	// Hidden breasts still sway under a closed garment, whose child shows.
	if(!visual || ((visual.vis_flags & VIS_HIDE) && !LAZYLEN(garment_visuals)))
		return
	var/mob/living/carbon/human/human = parent
	var/now_running = human.m_intent == MOVE_INTENT_RUN && !human.buckled
	if(now_running)
		last_run_step = world.time
		addtimer(CALLBACK(src, PROC_REF(check_run_stop)), BREAST_RUN_STOP_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)
	set_running(now_running)
	if(now_running || jiggling || human.buckled)
		return
	// Slow steps (sneaking, rough ground, slowdowns) replay the half-speed walk shot on the front instead.
	var/delay = human.cached_multiplicative_slowdown
	if(delay < CONFIG_GET(number/movedelay/walk_delay) + BREAST_SLOW_STEP_EXTRA)
		return
	play_shot(delay >= BREAST_SLOW_FULL_CYCLE ? "walk" : "walk_half", side_jiggle = FALSE)

/datum/component/breast_animation/proc/on_damaged(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	// Damage interrupts a jiggle here, since this signal is already registered for the whole lifetime.
	if(jiggling && damage > 0)
		stop_jiggle()
	if(damagetype == BRUTE && damage >= BREAST_HIT_MIN_DAMAGE)
		play_shot("hit")

/datum/component/breast_animation/proc/on_knocked_down(datum/source, amount, ignore_canstun)
	SIGNAL_HANDLER
	if(amount > 0)
		play_shot("fall")

/datum/component/breast_animation/proc/on_landed(datum/source)
	SIGNAL_HANDLER
	play_shot("land")

/datum/component/breast_animation/proc/on_climax(datum/source)
	SIGNAL_HANDLER
	play_shot("laugh")

/datum/component/breast_animation/proc/on_emote(datum/source, datum/emote/emote)
	SIGNAL_HANDLER
	var/shot = GLOB.breast_emote_shots[emote?.key]
	if(shot)
		play_shot(shot)

/// The owner's animation preference applies once a client is attached.
/datum/component/breast_animation/proc/on_login(datum/source)
	SIGNAL_HANDLER
	refresh()

/// Whether the breasts child is drawn instead of the body's south view.
/mob/living/carbon/human/proc/breast_animation_active()
	var/datum/component/breast_animation/animation = GetComponent(/datum/component/breast_animation)
	return !!animation?.visual

/// Whether the breasts play the jiggle loop, with or without a child.
/mob/living/carbon/human/proc/is_breast_jiggling()
	var/datum/component/breast_animation/animation = GetComponent(/datum/component/breast_animation)
	return !!animation?.jiggling

/obj/item/organ/genitals/filling_organ/breasts/get_render_key_state()
	. = ..()
	var/active = FALSE
	var/running = FALSE
	var/jiggling = FALSE
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		var/datum/component/breast_animation/animation = human_owner.GetComponent(/datum/component/breast_animation)
		jiggling = !!animation?.jiggling
		if(animation?.visual)
			active = TRUE
			running = animation.running
	// Breasts shown above clothes draw on another layer, so they need their own cache slot.
	// Worn clothing hides the breasts and their piercing, so covered and bare bodies keep apart.
	return "[.]_anim[active]_run[running]_jiggle[jiggling]_vis[visible_through_clothes]_bare[breasts_visible_under_clothes(owner)]"

#undef BREAST_VISUAL_ICON
#undef BREAST_VISUAL_LAYER
#undef BREAST_ANIM_MIN_SIZE
#undef BREAST_ANIM_MAX_SIZE
#undef BREAST_RUN_STOP_DELAY
#undef BREAST_HIT_MIN_DAMAGE
#undef BREAST_SLOW_STEP_EXTRA
#undef BREAST_SLOW_FULL_CYCLE
#undef BREAST_GARMENT_LAYER_STEP
#undef BREAST_GARMENT_DETAIL_LAYER_STEP
#undef BREAST_WORN_UPDATE_DELAY
