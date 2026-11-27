#define PIERCING_ANIM_ICON 'modular_rmh/icons/mob/sprite_accessory/piercings/piercings_anim.dmi'
/// Above the breasts child and its lipstick marks, below the garment children.
#define PIERCING_CHILD_LAYER_STEP 0.002
/// Clamps bite over the piercing, still below the garment children.
#define CLAMPS_CHILD_LAYER_STEP 0.003

/// Nipple jewellery over the animated breasts; plays the breasts child's gait states and one-shots.
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
	/// Nipple clamps drawn over the piercing child, another sibling.
	var/atom/movable/piercing_breast_visual/clamps_visual

/// Matches the jewellery children to the breasts child: one per worn piercing and clamps, or none.
/datum/component/breast_animation/proc/update_piercing_child()
	var/mob/living/carbon/human/human = parent
	var/datum/sprite_accessory/piercing/piercing
	var/datum/sprite_accessory/nipple_clamps/clamps
	if(visual && !QDELETED(human))
		piercing = human.get_worn_piercing_accessory()
		clamps = human.get_worn_nipple_clamps_accessory()
	if(piercing)
		piercing_visual = place_jewelry_child(piercing_visual, PIERCING_ANIM_ICON, piercing.anim_shape, piercing.get_anim_color_matrix(), PIERCING_CHILD_LAYER_STEP)
	else
		piercing_visual = remove_jewelry_child(piercing_visual)
	if(clamps)
		clamps_visual = place_jewelry_child(clamps_visual, clamps.icon, clamps.anim_shape, null, CLAMPS_CHILD_LAYER_STEP)
	else
		clamps_visual = remove_jewelry_child(clamps_visual)

/// Creates the child when missing and sets its look, gait, offset and hidden flag; returns it.
/datum/component/breast_animation/proc/place_jewelry_child(atom/movable/piercing_breast_visual/child, child_icon, child_shape, child_color, layer_step)
	if(!child)
		child = new
		var/atom/movable/movable_parent = parent
		movable_parent.vis_contents += child
	child.icon = child_icon
	child.shape = child_shape
	var/gait = jiggling ? "jiggle_" : (running ? "run_" : "")
	var/new_state = "[child_shape]-[size]_[gait]front"
	if(child.icon_state != new_state)
		child.icon_state = new_state
	child.color = child_color
	child.layer = visual.layer + layer_step
	child.pixel_x = visual.pixel_x
	child.pixel_y = visual.pixel_y
	if(visual.vis_flags & VIS_HIDE)
		child.vis_flags |= VIS_HIDE
	else
		child.vis_flags &= ~VIS_HIDE
	return child

/// Takes a jewellery child out of the parent's vis_contents and deletes it; returns null for the caller's var.
/datum/component/breast_animation/proc/remove_jewelry_child(atom/movable/piercing_breast_visual/child)
	if(!child)
		return null
	var/atom/movable/movable_parent = parent
	movable_parent?.vis_contents -= child
	qdel(child)
	return null

/datum/component/breast_animation/proc/remove_piercing_child()
	piercing_visual = remove_jewelry_child(piercing_visual)
	clamps_visual = remove_jewelry_child(clamps_visual)

/// Plays the jewellery copies of a breasts one-shot, so each follows the breasts frame by frame.
/datum/component/breast_animation/proc/flick_piercing_child(shot)
	for(var/atom/movable/piercing_breast_visual/child as anything in list(piercing_visual, clamps_visual))
		if(!child || (child.vis_flags & VIS_HIDE))
			continue
		var/shot_state = "[child.shape]-[size]_[shot]_front"
		if(icon_exists(child.icon, shot_state))
			flick(shot_state, child)

/// Sprite accessory of the first [feature_type] feature on this mob's chest, or null when none can be drawn.
/mob/living/carbon/human/proc/get_worn_chest_feature_accessory(feature_type)
	if(dna?.species && (NO_BODYPART_FEATURES in dna.species.species_traits))
		return null
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest || chest.skeletonized)
		return null
	for(var/datum/bodypart_feature/feature as anything in chest.bodypart_features)
		if(istype(feature, feature_type) && feature.accessory_type)
			return SPRITE_ACCESSORY(feature.accessory_type)
	return null

/// Sprite accessory of the piercing on this mob's chest, or null when none can be drawn.
/mob/living/carbon/human/proc/get_worn_piercing_accessory()
	var/datum/sprite_accessory/piercing/accessory = get_worn_chest_feature_accessory(/datum/bodypart_feature/piercing)
	return istype(accessory) ? accessory : null

/// Sprite accessory of the nipple clamps on this mob's chest, or null when none can be drawn.
/mob/living/carbon/human/proc/get_worn_nipple_clamps_accessory()
	var/datum/sprite_accessory/nipple_clamps/accessory = get_worn_chest_feature_accessory(/datum/bodypart_feature/nipple_clamps)
	return istype(accessory) ? accessory : null

#undef PIERCING_ANIM_ICON
#undef PIERCING_CHILD_LAYER_STEP
#undef CLAMPS_CHILD_LAYER_STEP
