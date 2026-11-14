#define ENTERPRISE_BED_OUTLINE "enterprise_bed_outline"

/datum/enterprise
	var/alist/bare_floors = alist()

/obj/structure/bed
	var/enterprise_drapes
	var/enterprise_drapes_drawn = FALSE

/obj/structure/bed/update_overlays()
	. = ..()
	if(enterprise_drapes)
		. += mutable_appearance('icons/obj/watercloset.dmi', "[enterprise_drapes]-[enterprise_drapes_drawn ? "closed" : "open"]", ABOVE_MOB_LAYER, GAME_PLANE_UPPER)

/obj/structure/bed/attack_hand(mob/living/user)
	if(!enterprise_drapes || user.m_intent == MOVE_INTENT_SNEAK)
		return ..()
	user.changeNext_move(CLICK_CD_FAST)
	enterprise_drapes_drawn = !enterprise_drapes_drawn
	playsound(src, 'sound/foley/rustle2.ogg', 40, TRUE, -3)
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/structure/bed/examine(mob/user)
	. = ..()
	if(enterprise_drapes)
		. += span_info(get_preferred_ui_language(user) == "ru" ? "Шторы задёргиваются и раздвигаются кликом по кровати пустой рукой." : "Click the bed with an empty hand to draw or part the drapes.")

/datum/enterprise_room/proc/show_level()
	dress_beds()
	update_bare_floor()

/datum/enterprise_room/proc/dress_beds()
	for(var/group_type in inventory)
		if(!ispath(group_type, /obj/structure/bed))
			continue
		var/datum/enterprise_fixture_group/group = inventory[group_type]
		for(var/datum/enterprise_fixture/item as anything in group.items)
			var/obj/structure/bed/bed = item.get_thing()
			if(bed)
				enterprise.dress_bed(bed, level)

/datum/enterprise_room/proc/update_bare_floor()
	var/static/list/laid = list(
		FOOTSTEP_WOOD = TRUE,
		FOOTSTEP_FLOOR = TRUE,
		FOOTSTEP_STONE = TRUE,
		FOOTSTEP_CARPET = TRUE,
		FOOTSTEP_PLATING = TRUE,
	)
	var/bare = level < ENTERPRISE_LEVEL_WOOD
	for(var/turf/open/floor/member in turfs)
		var/covered = terrace ? member.footstep == FOOTSTEP_WOOD : laid[member.footstep]
		enterprise.set_bare_floor(member, bare && covered)

/datum/enterprise/proc/dress_bed(obj/structure/bed/bed, level)
	var/drapes
	bed.remove_filter(ENTERPRISE_BED_OUTLINE)
	switch(level)
		if(ENTERPRISE_LEVEL_SILVER)
			bed.add_filter(ENTERPRISE_BED_OUTLINE, 1, outline_filter(1, "#3c1f5a59"))
		if(ENTERPRISE_LEVEL_GOLD to INFINITY)
			drapes = "curtain_red"
			bed.add_filter(ENTERPRISE_BED_OUTLINE, 1, outline_filter(1, "#d4af3759"))
	if(bed.enterprise_drapes == drapes)
		return
	bed.enterprise_drapes = drapes
	bed.enterprise_drapes_drawn = FALSE
	bed.update_appearance(UPDATE_OVERLAYS)

/datum/enterprise/proc/set_bare_floor(turf/open/floor/member, bare)
	var/static/mutable_appearance/rough
	if(!rough)
		rough = mutable_appearance('icons/turf/constructed/wood.dmi', "twig")
	if(!bare == !bare_floors[member])
		return
	if(bare)
		bare_floors[member] = TRUE
		member.add_overlay(rough)
	else
		bare_floors -= member
		member.cut_overlay(rough)

/datum/enterprise/proc/refresh_decor()
	var/list/turf/open/floor/stale = list()
	for(var/turf/open/floor/member as anything in bare_floors)
		var/datum/enterprise_room/room = get_room(member)
		if(!room || room.level >= ENTERPRISE_LEVEL_WOOD)
			stale += member
	for(var/turf/open/floor/member as anything in stale)
		set_bare_floor(member, FALSE)
	for(var/datum/enterprise_room/room as anything in rooms)
		room.show_level()

#undef ENTERPRISE_BED_OUTLINE
