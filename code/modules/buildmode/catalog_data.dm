/// Spawn catalogue data: which types are listed, their card data, and the shared lookup tables.

/// Only concrete world atoms with a sprite are listed. Also used to validate saved favourites.
/proc/buildmode_catalog_allowed(atom/target_type)
	if(!ispath(target_type, /obj) && !ispath(target_type, /turf) && !ispath(target_type, /mob/living))
		return FALSE
	if(IS_ABSTRACT(target_type) || !initial(target_type.icon) || !initial(target_type.name))
		return FALSE
	if(ispath(target_type, /obj/abstract) || ispath(target_type, /turf/template_noop))
		return FALSE
	return TRUE

/proc/cmp_buildmode_catalog(atom/a, atom/b)
	return sorttext("[initial(b.name)]", "[initial(a.name)]") || sorttext("[b]", "[a]")

/proc/buildmode_catalog_subcategory(target_type, category)
	var/list/groups = buildmode_catalog_groups()[category]
	if(!groups)
		return "all"
	for(var/group_id in groups)
		for(var/root_type in groups[group_id]["roots"])
			if(ispath(target_type, root_type))
				return group_id
	return "other"

/// Coverage zone ids an armor piece protects.
/proc/buildmode_catalog_coverage(obj/item/clothing/clothing_type)
	var/list/covered_zones = list()
	if(!ispath(clothing_type, /obj/item/clothing))
		return covered_zones
	var/covered = initial(clothing_type.body_parts_covered)
	var/list/zones = buildmode_catalog_coverage_zones()
	for(var/zone_id in zones)
		var/mask = zones[zone_id]["mask"]
		if(mask && (covered & mask))
			covered_zones += zone_id
	return covered_zones

/**
 * Type -> card data for every listed type, sorted by name then path.
 * Built on first use and shared by all admins. No constructor runs while browsing:
 * many game types have side effects in New/Initialize.
 */
GLOBAL_LIST(buildmode_catalog_entries_cache)
GLOBAL_LIST(buildmode_catalog_index_cache)
/// TRUE while the background warm-up is building the catalogue.
GLOBAL_VAR_INIT(buildmode_catalog_warming, FALSE)

/proc/buildmode_catalog_entries()
	if(!GLOB.buildmode_catalog_entries_cache)
		GLOB.buildmode_catalog_entries_cache = build_buildmode_catalog_entries(FALSE)
	return GLOB.buildmode_catalog_entries_cache

/**
 * Builds the catalogue in the background so the first F7 of the round does not freeze the server.
 * Started when an admin logs in. With can_sleep the work is spread over ticks (CHECK_TICK).
 */
/proc/warm_buildmode_catalog()
	set waitfor = FALSE
	if(GLOB.buildmode_catalog_index_cache || GLOB.buildmode_catalog_warming)
		return
	GLOB.buildmode_catalog_warming = TRUE
	var/list/built = build_buildmode_catalog_entries(TRUE)
	if(!GLOB.buildmode_catalog_entries_cache) // nobody needed it meanwhile
		GLOB.buildmode_catalog_entries_cache = built
	buildmode_catalog_index(TRUE)
	GLOB.buildmode_catalog_warming = FALSE

/// TRUE once the shared catalogue is built. Starts the background build when nobody has started it.
/proc/buildmode_catalog_ready()
	if(GLOB.buildmode_catalog_index_cache)
		return TRUE
	warm_buildmode_catalog()
	return !!GLOB.buildmode_catalog_index_cache

/proc/build_buildmode_catalog_entries(can_sleep)
	var/list/built = list()
	var/list/paths = list()
	for(var/target_type in subtypesof(/obj) + subtypesof(/turf) + subtypesof(/mob/living))
		if(buildmode_catalog_allowed(target_type))
			paths += target_type
		if(can_sleep)
			CHECK_TICK
	sortTim(paths, GLOBAL_PROC_REF(cmp_buildmode_catalog))
	if(can_sleep)
		CHECK_TICK
	for(var/atom/target_type as anything in paths)
		if(can_sleep)
			CHECK_TICK
		var/category = buildmode_catalog_category(target_type)
		var/armor_class = "all"
		if(category == "clothing")
			var/obj/item/clothing/clothing_type = target_type
			armor_class = "[initial(clothing_type.armor_class)]"
		built[target_type] = list(
			"path" = "[target_type]",
			"name" = "[initial(target_type.name)]",
			"icon" = "[initial(target_type.icon)]",
			"icon_state" = "[initial(target_type.icon_state)]",
			"category" = category,
			"subcategory" = buildmode_catalog_subcategory(target_type, category),
			"armor_class" = armor_class,
			"coverage" = buildmode_catalog_coverage(target_type),
		)
	return built

/// Shared, read-only lookup tables. Lists keep the catalogue's name/path order.
/proc/buildmode_catalog_index(can_sleep = FALSE)
	if(GLOB.buildmode_catalog_index_cache)
		return GLOB.buildmode_catalog_index_cache
	var/list/categories = list()
	var/list/subcategories = list()
	var/list/counts = list()
	var/list/search_text = list()
	var/list/entries = buildmode_catalog_entries()
	var/list/paths = list()
	for(var/path in entries)
		if(can_sleep)
			CHECK_TICK
		var/list/entry = entries[path]
		var/category = entry["category"]
		var/subcategory = entry["subcategory"]
		if(!categories[category])
			categories[category] = list()
			subcategories[category] = list()
		categories[category] += path
		var/list/groups = subcategories[category]
		if(!groups[subcategory])
			groups[subcategory] = list()
		groups[subcategory] += path
		counts[category]++
		paths += path
	// The search texts ("name path", lowercase) are made in shuffled order. In catalogue order they
	// would be thousands of new strings in rising order, all kept: BYOND's string tree is not
	// rebalanced on insert, so each would hang one level below the last, and once a lookup passes
	// about a thousand levels the engine stops to re-sort every string in the world. CHECK_TICK
	// cannot split that stall.
	shuffle_inplace(paths)
	for(var/path in paths)
		if(can_sleep)
			CHECK_TICK
		var/list/entry = entries[path]
		search_text[path] = LOWER_TEXT("[entry["name"]] [path]")
	GLOB.buildmode_catalog_index_cache = list("categories" = categories, "subcategories" = subcategories, "counts" = counts, "search_text" = search_text)
	return GLOB.buildmode_catalog_index_cache

/proc/buildmode_catalog_valid_subcategory(category, subcategory)
	var/list/groups = buildmode_catalog_groups()[category]
	return subcategory == "all" || (groups && (subcategory in groups))

/proc/buildmode_catalog_valid_coverage(coverage)
	return coverage in buildmode_catalog_coverage_zones()

/// list(id = label) -> list of list("id", "name") for the window.
/proc/buildmode_catalog_options(list/labels)
	var/list/options = list()
	for(var/id in labels)
		options += list(list("id" = id, "name" = labels[id]))
	return options

/proc/buildmode_catalog_coverage_options()
	var/list/labels = list()
	var/list/zones = buildmode_catalog_coverage_zones()
	for(var/id in zones)
		labels[id] = zones[id]["name"]
	return buildmode_catalog_options(labels)

/// Subgroup options of a category, with how many types each holds. Empty groups are left out.
/proc/buildmode_catalog_subcategory_options(category)
	var/static/list/cache = list()
	if(cache[category])
		return cache[category]
	var/list/options = list()
	var/list/groups = buildmode_catalog_groups()[category]
	if(groups)
		var/list/indexed = buildmode_catalog_index()["subcategories"][category]
		options += list(list("id" = "all", "name" = "All kinds", "count" = length(buildmode_catalog_index()["categories"][category])))
		for(var/group_id in groups)
			var/amount = length(indexed?[group_id])
			if(amount)
				options += list(list("id" = group_id, "name" = groups[group_id]["name"], "count" = amount))
	cache[category] = options
	return options

/// Keeps only valid, listed typepaths (as text), without duplicates, up to limit.
/proc/buildmode_sanitize_paths(list/raw_paths, limit)
	var/list/result = list()
	if(!islist(raw_paths))
		return result
	var/list/entries = buildmode_catalog_entries()
	for(var/path in raw_paths)
		if(length(result) >= limit)
			break
		if(!istext(path))
			continue
		var/target_type = text2path(path)
		if(!target_type || !entries[target_type])
			continue
		result |= "[target_type]"
	return result
