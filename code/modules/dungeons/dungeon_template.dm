/area/pocket_dimension/dungeon
	name = "Dungeon"

// NOTE: area datums are shared between simultaneous instances of the same
// template, so /area/pocket_dimension.linked_pocket is unreliable for dungeons.
// Nothing in the dungeon system may rely on linked_pocket.

/datum/map_template/pocket/dungeon
	name = "_dungeon_base"
	id = "_dungeon_base"
	lifecycle_policy = POCKET_LIFECYCLE_COLLAPSE
	idle_timeout = DUNGEON_DEFAULT_IDLE_TIMEOUT
	instance_type = /datum/pocket_dimension/dungeon
	/// DUNGEON_THEME_* tag used for entrance/gate filtering
	var/theme
	/// Pick weight inside a filtered template pool
	var/dungeon_weight = 10
	/// Base danger tier (1-5); combined with run depth for selection
	var/difficulty_tier = 1
	/// DUNGEON_ROOM_* kind
	var/room_kind = DUNGEON_ROOM_ONESHOT
	/// FALSE for harness fixtures that must never enter a production roll
	var/production_eligible = TRUE
	/// /datum/loot_table path used by reward caches in this dungeon
	var/loot_table_type
	/// Examine hint shown on gates leading to a room of this template
	var/gate_hint = "Something stirs in the dark beyond."

/// Returns the cache table for this template at the given run floor. Most
/// templates pin one table; themes spanning several floor bands may override.
/datum/map_template/pocket/dungeon/proc/get_loot_table_type(dungeon_floor = 1)
	return loot_table_type

/// A failed generated layout may substitute an authored room of the same kind and theme.
/datum/map_template/pocket/dungeon/proc/get_fallback_template()
	return null

/// Returns an assoc list of template datum -> weight for all dungeon templates
/// matching the given filters. Templates are the cached datums registered in
/// SSpocket_dimensions.templates_by_id (built from SSmapping.map_templates).
/proc/get_dungeon_template_pool(room_kind, theme = null, min_tier = 0, max_tier = INFINITY, list/exclude_ids)
	var/list/pool = list()
	for(var/template_id in SSpocket_dimensions.templates_by_id)
		var/datum/map_template/pocket/dungeon/template = SSpocket_dimensions.templates_by_id[template_id]
		if(!istype(template))
			continue
		if(!template.production_eligible)
#ifdef UNIT_TESTS
			// Focused test-theme requests may use fixtures. Broad pools still
			// exercise exactly the production-eligible set.
			if(theme != DUNGEON_THEME_TEST)
				continue
#else
			continue
#endif
		if(template.room_kind != room_kind)
			continue
		if(theme && template.theme != theme)
			continue
		if(template.difficulty_tier < min_tier || template.difficulty_tier > max_tier)
			continue
		if(exclude_ids && (template.id in exclude_ids))
			continue
		pool[template] = max(1, template.dungeon_weight)
	return pool

/// Weighted-picks a dungeon template. Soft excludes (the anti-repeat memory)
/// relax first, then tier, then theme - but hard_exclude_id (the template of
/// the room the party is standing in) survives every stage except the absolute
/// last resort, so the same room never chains twice in a row unless it is
/// literally the only template of its kind.
/proc/pick_dungeon_template(room_kind, theme = null, min_tier = 0, max_tier = INFINITY, list/exclude_ids, hard_exclude_id)
	var/list/full_exclude = exclude_ids ? exclude_ids.Copy() : list()
	if(hard_exclude_id)
		full_exclude |= hard_exclude_id
	var/list/hard_only = hard_exclude_id ? list(hard_exclude_id) : null
	var/list/pool = get_dungeon_template_pool(room_kind, theme, min_tier, max_tier, full_exclude)
	if(!length(pool))
		pool = get_dungeon_template_pool(room_kind, theme, min_tier, max_tier, hard_only)
	if(!length(pool))
		pool = get_dungeon_template_pool(room_kind, theme, exclude_ids = hard_only)
	if(!length(pool))
		pool = get_dungeon_template_pool(room_kind, exclude_ids = hard_only)
	if(!length(pool))
		pool = get_dungeon_template_pool(room_kind)
	if(!length(pool))
		return null
	return pickweight(pool)

// -- Test templates (used by unit tests; theme TEST keeps them out of real pools) --

/datum/map_template/pocket/dungeon/test_onebite
	name = "Test One-Bite Dungeon"
	id = "dungeon_test_onebite"
	mappath = "_maps/templates/dungeons/_test/dungeon_test_onebite.dmm"
	theme = DUNGEON_THEME_TEST
	room_kind = DUNGEON_ROOM_ONESHOT
	production_eligible = FALSE
	loot_table_type = /datum/loot_table/debug
	gate_hint = "It smells of sawdust and unit tests."

/datum/map_template/pocket/dungeon/test_break
	name = "Test Break Room"
	id = "dungeon_test_break"
	mappath = "_maps/templates/dungeons/_test/dungeon_test_break.dmm"
	theme = DUNGEON_THEME_TEST
	room_kind = DUNGEON_ROOM_BREAK
	production_eligible = FALSE

/datum/map_template/pocket/dungeon/test_combat
	name = "Test Combat Room"
	id = "dungeon_test_combat"
	mappath = "_maps/templates/dungeons/_test/dungeon_test_combat.dmm"
	theme = DUNGEON_THEME_TEST
	room_kind = DUNGEON_ROOM_COMBAT
	production_eligible = FALSE
	loot_table_type = /datum/loot_table/debug

/datum/map_template/pocket/dungeon/test_descent
	name = "Test Descent Room"
	id = "dungeon_test_descent"
	mappath = "_maps/templates/dungeons/_test/dungeon_test_break.dmm" // reuse break layout (entry+exit+gates)
	theme = DUNGEON_THEME_TEST
	room_kind = DUNGEON_ROOM_DESCENT
	production_eligible = FALSE

/datum/map_template/pocket/dungeon/test_boss
	name = "Test Boss Room"
	id = "dungeon_test_boss"
	mappath = "_maps/templates/dungeons/_test/dungeon_test_boss.dmm"
	theme = DUNGEON_THEME_TEST
	room_kind = DUNGEON_ROOM_BOSS
	production_eligible = FALSE
	loot_table_type = /datum/loot_table/debug
	gate_hint = "Something vast breathes in the dark ahead."

/datum/map_template/pocket/dungeon/test_scatter
	name = "Test Scatter Room"
	id = "dungeon_test_scatter"
	mappath = "_maps/templates/dungeons/_test/dungeon_test_scatter.dmm"
	theme = DUNGEON_THEME_TEST
	room_kind = DUNGEON_ROOM_COMBAT
	production_eligible = FALSE
	loot_table_type = /datum/loot_table/debug

// -- Standalone singlets: self-contained lairs reached from themed entrances --

/datum/map_template/pocket/dungeon/singlet
	name = "_singlet_base"
	id = "_singlet_base"
	room_kind = DUNGEON_ROOM_ONESHOT
	dungeon_weight = 10

/datum/map_template/pocket/dungeon/singlet/bandit_hideout
	name = "The Soot-Stained Hideout"
	id = "singlet_bandit_hideout"
	mappath = "_maps/templates/rmh/randomlocs/small/small_bandit_1.dmm"
	theme = DUNGEON_THEME_BANDIT
	difficulty_tier = 2
	loot_table_type = /datum/loot_table/dungeon/tier2
	gate_hint = "Woodsmoke, whetstone grit, and low voices leak from the dark."

/datum/map_template/pocket/dungeon/singlet/bear_den
	name = "The Bloodmoss Den"
	id = "singlet_bear_den"
	mappath = "_maps/templates/rmh/randomlocs/small/small_bear_1.dmm"
	theme = DUNGEON_THEME_BEAR
	difficulty_tier = 3
	loot_table_type = /datum/loot_table/dungeon/tier2
	gate_hint = "Wet fur, old blood, and the musk of something enormous hang beyond."

/datum/map_template/pocket/dungeon/singlet/ratfolk_camp
	name = "The Gnawcamp"
	id = "singlet_ratfolk_camp"
	mappath = "_maps/templates/rmh/randomlocs/small/small_ratfolk_1.dmm"
	theme = DUNGEON_THEME_RATFOLK
	difficulty_tier = 2
	loot_table_type = /datum/loot_table/dungeon/tier2
	gate_hint = "Grease smoke and the skitter of clawed feet drift through."

/datum/map_template/pocket/dungeon/singlet/spider_nursery
	name = "The Silk-Choked Nursery"
	id = "singlet_spider_nursery"
	mappath = "_maps/templates/rmh/randomlocs/small/small_spider_1.dmm"
	theme = DUNGEON_THEME_SPIDER
	difficulty_tier = 1
	loot_table_type = /datum/loot_table/dungeon/tier1
	gate_hint = "Sticky silk trembles in a breeze that carries no sound."

/datum/map_template/pocket/dungeon/singlet/werewolf_shrine
	name = "The Moon-Riven Shrine"
	id = "singlet_werewolf_shrine"
	mappath = "_maps/templates/rmh/randomlocs/small/small_werewolf_1.dmm"
	theme = DUNGEON_THEME_WEREWOLF
	difficulty_tier = 3
	loot_table_type = /datum/loot_table/dungeon/tier2
	gate_hint = "Cold crystal-light glints over claw marks and matted fur."

/datum/map_template/pocket/dungeon/singlet/wolf_den
	name = "The Bone-Littered Den"
	id = "singlet_wolf_den"
	mappath = "_maps/templates/rmh/randomlocs/small/small_wolf_1.dmm"
	theme = DUNGEON_THEME_WOLF
	difficulty_tier = 1
	loot_table_type = /datum/loot_table/dungeon/tier1
	gate_hint = "A pack's breath and the copper stink of old kills linger ahead."

// -- The Sunken Warrens: underground swamp goblin starter set --

/datum/map_template/pocket/dungeon/swampgob
	name = "_swampgob_base"
	id = "_swampgob_base"
	theme = DUNGEON_THEME_SWAMPGOB
	loot_table_type = /datum/loot_table/dungeon/swampgob

/datum/map_template/pocket/dungeon/swampgob/break_hollow
	name = "Root-Choked Hollow"
	id = "swampgob_break_hollow"
	mappath = "_maps/templates/dungeons/swampgob/break_hollow.dmm"
	room_kind = DUNGEON_ROOM_BREAK

/datum/map_template/pocket/dungeon/swampgob/descent_sinkhole
	name = "Sinkhole Landing"
	id = "swampgob_descent_sinkhole"
	mappath = "_maps/templates/dungeons/swampgob/descent_sinkhole.dmm"
	room_kind = DUNGEON_ROOM_DESCENT

/datum/map_template/pocket/dungeon/swampgob/combat_mireway
	name = "The Mireway"
	id = "swampgob_combat_mireway"
	mappath = "_maps/templates/dungeons/swampgob/combat_mireway.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 1
	gate_hint = "Marsh-stink and goblin chatter drift through."

/datum/map_template/pocket/dungeon/swampgob/combat_shroomcave
	name = "Shroom-Lit Cave"
	id = "swampgob_combat_shroomcave"
	mappath = "_maps/templates/dungeons/swampgob/combat_shroomcave.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 1
	gate_hint = "A pale fungal glow seeps around the frame."

/datum/map_template/pocket/dungeon/swampgob/combat_leechpools
	name = "The Leech Pools"
	id = "swampgob_combat_leechpools"
	mappath = "_maps/templates/dungeons/swampgob/combat_leechpools.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 2
	loot_table_type = /datum/loot_table/dungeon/tier2
	gate_hint = "Still black water laps at something beyond."

/datum/map_template/pocket/dungeon/swampgob/combat_gobwarren
	name = "Goblin Warren"
	id = "swampgob_combat_gobwarren"
	mappath = "_maps/templates/dungeons/swampgob/combat_gobwarren.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 2
	loot_table_type = /datum/loot_table/dungeon/tier2
	gate_hint = "Skull-totems and squabbling voices. A warren."

/datum/map_template/pocket/dungeon/swampgob/boss_kingshall
	name = "The Bog-King's Hall"
	id = "swampgob_boss_kingshall"
	mappath = "_maps/templates/dungeons/swampgob/boss_kingshall.dmm"
	room_kind = DUNGEON_ROOM_BOSS
	difficulty_tier = 2
	loot_table_type = /datum/loot_table/dungeon/tier2
	gate_hint = "Drums. Torchlight. Something vast squats on a throne of mud."

// -- Drow Dungeon: occupied undercity beyond the Sunken Warrens --

/datum/map_template/pocket/dungeon/drow
	name = "_drow_base"
	id = "_drow_base"
	theme = DUNGEON_THEME_DROW
	loot_table_type = /datum/loot_table/dungeon/drow/tier1

/datum/map_template/pocket/dungeon/drow/get_loot_table_type(dungeon_floor = 1)
	return get_drow_loot_table_type_for_floor(dungeon_floor)

/datum/map_template/pocket/dungeon/drow/break_veiled_refuge
	name = "The Veiled Refuge"
	id = "drow_break_veiled_refuge"
	mappath = "_maps/templates/dungeons/drow/break_veiled_refuge.dmm"
	room_kind = DUNGEON_ROOM_BREAK
	difficulty_tier = 2
	gate_hint = "Blue fire glows beyond a curtain of still, clean silk."

/datum/map_template/pocket/dungeon/drow/descent_umbra_gate
	name = "The Umbra Gatehouse"
	id = "drow_descent_umbra_gate"
	mappath = "_maps/templates/dungeons/drow/descent_umbra_gate.dmm"
	room_kind = DUNGEON_ROOM_DESCENT
	difficulty_tier = 2
	gate_hint = "Measured footsteps echo beneath a black-stone arch."

/datum/map_template/pocket/dungeon/drow/combat_silk_antechamber
	name = "The Silk Antechamber"
	id = "drow_combat_silk_antechamber"
	mappath = "_maps/templates/dungeons/drow/combat_silk_antechamber.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 2
	gate_hint = "Drawn silk whispers over polished stone."

/datum/map_template/pocket/dungeon/drow/combat_slave_pens
	name = "The Slave Pens"
	id = "drow_combat_slave_pens"
	mappath = "_maps/templates/dungeons/drow/combat_slave_pens.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 2
	gate_hint = "Iron scrapes stone, followed by the snap of a lash."

/datum/map_template/pocket/dungeon/drow/combat_webbed_gallery
	name = "The Webbed Gallery"
	id = "drow_combat_webbed_gallery"
	mappath = "_maps/templates/dungeons/drow/combat_webbed_gallery.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 3
	gate_hint = "Something many-legged crosses the webbing overhead."

/datum/map_template/pocket/dungeon/drow/combat_fungal_reservoir
	name = "The Fungal Reservoir"
	id = "drow_combat_fungal_reservoir"
	mappath = "_maps/templates/dungeons/drow/combat_fungal_reservoir.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 3
	gate_hint = "Cold water drips among beds of luminous fungus."

/datum/map_template/pocket/dungeon/drow/combat_blade_chapel
	name = "The Chapel of Blades"
	id = "drow_combat_blade_chapel"
	mappath = "_maps/templates/dungeons/drow/combat_blade_chapel.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 4
	gate_hint = "Steel chimes softly where no wind should reach."

/datum/map_template/pocket/dungeon/drow/combat_matron_gauntlet
	name = "The Matron's Gauntlet"
	id = "drow_combat_matron_gauntlet"
	mappath = "_maps/templates/dungeons/drow/combat_matron_gauntlet.dmm"
	room_kind = DUNGEON_ROOM_COMBAT
	difficulty_tier = 4
	gate_hint = "A disciplined war-chant answers the gate's pulse."

/datum/map_template/pocket/dungeon/drow/boss_widows_court
	name = "The Widow's Court"
	id = "drow_boss_widows_court"
	mappath = "_maps/templates/dungeons/drow/boss_widows_court.dmm"
	room_kind = DUNGEON_ROOM_BOSS
	difficulty_tier = 4
	gate_hint = "A vast shadow waits beneath a crown of blue flame."
