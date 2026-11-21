#define PIERCING_ANIM_ICON 'modular_rmh/icons/mob/sprite_accessory/piercings/piercings_anim.dmi'
/// Above the breasts child and its lipstick marks, below the garment children.
#define PIERCING_CHILD_LAYER_STEP 0.002

/// Nipple piercing over the animated breasts; plays the breasts child's gait states and one-shots.
/atom/movable/piercing_breast_visual
	icon = PIERCING_ANIM_ICON
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_DIR
	appearance_flags = PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	/// Shape in the animated sheet, the prefix of every state this child plays.
	var/shape

/datum/component/breast_animation
	/// Piercing drawn over the breasts child, a sibling in the parent's vis_contents.
	var/atom/movable/piercing_breast_visual/piercing_visual

/// Matches the piercing child to the breasts child: shape, colours, gait, offset and hidden flag.
/datum/component/breast_animation/proc/update_piercing_child()
	var/mob/living/carbon/human/human = parent
	var/datum/sprite_accessory/piercing/accessory
	if(visual && !QDELETED(human))
		accessory = human.get_worn_piercing_accessory()
	if(!accessory)
		remove_piercing_child()
		return
	if(!piercing_visual)
		piercing_visual = new
		human.vis_contents += piercing_visual
	piercing_visual.shape = accessory.anim_shape
	var/gait = jiggling ? "jiggle_" : (running ? "run_" : "")
	var/new_state = "[accessory.anim_shape]-[size]_[gait]front"
	if(piercing_visual.icon_state != new_state)
		piercing_visual.icon_state = new_state
	piercing_visual.color = accessory.get_anim_color_matrix()
	piercing_visual.layer = visual.layer + PIERCING_CHILD_LAYER_STEP
	piercing_visual.pixel_x = visual.pixel_x
	piercing_visual.pixel_y = visual.pixel_y
	if(visual.vis_flags & VIS_HIDE)
		piercing_visual.vis_flags |= VIS_HIDE
	else
		piercing_visual.vis_flags &= ~VIS_HIDE

/datum/component/breast_animation/proc/remove_piercing_child()
	if(!piercing_visual)
		return
	var/atom/movable/movable_parent = parent
	movable_parent?.vis_contents -= piercing_visual
	QDEL_NULL(piercing_visual)

/// Plays the piercing copy of a breasts one-shot, so the piercing follows the breasts frame by frame.
/datum/component/breast_animation/proc/flick_piercing_child(shot)
	if(!piercing_visual || (piercing_visual.vis_flags & VIS_HIDE))
		return
	var/shot_state = "[piercing_visual.shape]-[size]_[shot]_front"
	if(icon_exists(PIERCING_ANIM_ICON, shot_state))
		flick(shot_state, piercing_visual)

/// Sprite accessory of the piercing on this mob's chest, or null when none can be drawn.
/mob/living/carbon/human/proc/get_worn_piercing_accessory()
	if(dna?.species && (NO_BODYPART_FEATURES in dna.species.species_traits))
		return null
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest || chest.skeletonized)
		return null
	for(var/datum/bodypart_feature/piercing/feature in chest.bodypart_features)
		var/datum/sprite_accessory/piercing/accessory = SPRITE_ACCESSORY(feature.accessory_type)
		if(istype(accessory))
			return accessory
	return null

#undef PIERCING_ANIM_ICON
#undef PIERCING_CHILD_LAYER_STEP
