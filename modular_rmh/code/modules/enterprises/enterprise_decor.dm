#define ENTERPRISE_BED_DRAPE_SHIFT 16
#define ENTERPRISE_BED_OUTLINE "enterprise_bed_outline"

/datum/enterprise
	var/alist/bare_floors = alist()

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
	var/bare = level < ENTERPRISE_LEVEL_WOOD
	for(var/turf/open/floor/member in turfs)
		enterprise.set_bare_floor(member, bare && member.footstep == FOOTSTEP_WOOD)

/datum/enterprise/proc/dress_bed(obj/structure/bed/bed, level)
	var/static/mutable_appearance/purple_drape
	var/static/mutable_appearance/red_drape
	if(!purple_drape)
		purple_drape = mutable_appearance('icons/obj/watercloset.dmi', "curtain_purple-open")
		purple_drape.pixel_y = ENTERPRISE_BED_DRAPE_SHIFT
		red_drape = mutable_appearance('icons/obj/watercloset.dmi', "curtain_red-open")
		red_drape.pixel_y = ENTERPRISE_BED_DRAPE_SHIFT
	bed.cut_overlay(purple_drape)
	bed.cut_overlay(red_drape)
	bed.remove_filter(ENTERPRISE_BED_OUTLINE)
	switch(level)
		if(ENTERPRISE_LEVEL_SILVER)
			bed.add_overlay(purple_drape)
			bed.add_filter(ENTERPRISE_BED_OUTLINE, 1, outline_filter(1, "#3c1f5a59"))
		if(ENTERPRISE_LEVEL_GOLD to INFINITY)
			bed.add_overlay(red_drape)
			bed.add_filter(ENTERPRISE_BED_OUTLINE, 1, outline_filter(1, "#d4af3759"))

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

#undef ENTERPRISE_BED_DRAPE_SHIFT
#undef ENTERPRISE_BED_OUTLINE
