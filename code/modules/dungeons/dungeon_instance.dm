/datum/pocket_dimension/dungeon
	/// TRUE once every guardian is dead or defeated
	var/cleared = FALSE
	/// Number of rooms cleared before this one in an infinite run; 0 for one-bite dungeons
	var/depth = 0
	/// How many combat rooms into the current stretch this room sits; 0 for break rooms
	var/stretch_position = 0
	/// DUNGEON_PATH_* of the gate that leads into this room; drives elite spawns
	var/incoming_path_type = DUNGEON_PATH_COMBAT
	/// DUNGEON_REWARD_* promised by the gate that led here; delivered on clear
	var/promised_reward = DUNGEON_REWARD_MOTES
	/// Key id for a VAULT room's keyholder + locked cache pair
	var/vault_key_id
	/// Set by a room trait before scatter: restrict scattered mobs to this style
	var/scatter_style_override = null
	/// Set by a room trait before scatter: add this many mobs to the scatter count
	var/scatter_count_bonus = 0
	/// The room's rolled trait, if any (Slice 4)
	var/datum/dungeon_room_trait/current_trait
	/// When TRUE (infinite-run rooms), collapse deletes loose foreign items and
	/// decals instead of ejecting them - didn't pick it up, don't get to keep it.
	var/delete_foreign_on_collapse = FALSE
	/// REF text -> weakref of living guardians that must die for the room to clear
	var/list/guardian_refs = list()
	/// REF text -> TRUE for mobs that belong to the dungeon; qdel'd on collapse instead of ejected
	var/list/native_mob_refs = list()
	/// REF text -> TRUE for guardians flagged elite (bigger mote drop)
	var/list/elite_guardian_refs = list()
	/// REF text -> mote bounty for promoted bosses in this room
	var/list/boss_bounties = list()
	/// REF text -> key_id for guardians that drop a key on death
	var/list/keyholder_drops = list()
	/// Owning infinite-dungeon run, if any
	var/datum/dungeon_run/owning_run
	/// Reward caches to unlock on clear
	var/list/obj/structure/dungeon_loot_cache/loot_caches = list()
	/// Gates created in this room by the run controller
	var/list/obj/structure/dungeon_gate/gates = list()
	/// list(list("turf" = T, "role" = DUNGEON_GATE_*)) collected from gate landmarks
	var/list/gate_landmark_info = list()
	/// Turfs where shrines should be built (break rooms)
	var/list/shrine_turfs = list()
	var/contents_setup_done = FALSE
	/// DUNGEON_POP_* - what populates this room (set before activate())
	var/population_mode = DUNGEON_POP_COMBAT
	/// Wave-challenge rooms: waves left after the current one
	var/pending_waves = 0
	/// Current wave number (1-based)
	var/wave_number = 0
	/// Baseline scatter count, reused for wave escalation
	var/wave_count_base = 0
	/// Style filter carried across waves
	var/wave_style

/datum/pocket_dimension/dungeon/Destroy(force)
	var/obj/structure/dungeon_entrance/entrance = get_pocket_holder()
	owning_run = null
	guardian_refs = null
	native_mob_refs = null
	elite_guardian_refs = null
	boss_bounties = null
	keyholder_drops = null
	current_trait = null // shared singleton - never qdel
	loot_caches = null
	for(var/atom/movable/native as anything in native_movables)
		if(QDELETED(native) || ismob(native))
			continue
		qdel(native)
	QDEL_LIST(gates)
	gate_landmark_info = null
	shrine_turfs = null
	. = ..()
	if(istype(entrance))
		entrance.on_dungeon_collapsed(src)

/datum/pocket_dimension/dungeon/proc/get_dungeon_template()
	var/datum/map_template/pocket/dungeon/dungeon_template = template
	return istype(dungeon_template) ? dungeon_template : null

/// Ordinary authored rooms have no generation state.
/datum/pocket_dimension/dungeon/proc/set_generation_seed(room_seed)
	return

/datum/pocket_dimension/dungeon/activate()
	. = ..()
	if(. && !contents_setup_done)
		contents_setup_done = TRUE
		setup_dungeon_contents()

// Combat rooms in a run must not get an exit seam at all - not the automatic
// fallback, and not a mapped one either (a seam that only answers "the
// dungeon's grip is too strong" is a trap for the player). The only way out
// of a stretch is forward or back through gates. Standalone one-bite dungeons
// keep their mapped exits.
/datum/pocket_dimension/dungeon/create_exit_object(obj/effect/landmark/pocket_dimension/exit/exit_marker, turf/current_turf)
	var/datum/map_template/pocket/dungeon/dungeon_template = get_dungeon_template()
	// Run-owned rooms only ever exit through a break room - a seam anywhere
	// else (combat, boss, descent) just teases and refuses.
	if(owning_run && dungeon_template && dungeon_template.room_kind != DUNGEON_ROOM_BREAK)
		return null
	if(!exit_marker && dungeon_template?.room_kind == DUNGEON_ROOM_COMBAT)
		return null
	return ..()

/// Rolls a room trait (50%) and lets it reshape the plan before scatter.
/datum/pocket_dimension/dungeon/proc/roll_room_trait()
	if(population_mode != DUNGEON_POP_COMBAT)
		return // special rooms carry no traits (and pay no curse debt)
	var/datum/map_template/pocket/dungeon/dungeon_template = get_dungeon_template()
	if(!dungeon_template)
		return
	// Dark-bargain debt: owed curses pre-empt the normal roll on combat rooms.
	if(owning_run?.cursed_rooms_owed > 0 && dungeon_template.room_kind == DUNGEON_ROOM_COMBAT)
		var/datum/dungeon_room_trait/cursed = get_dungeon_room_trait_singleton(/datum/dungeon_room_trait/cursed)
		if(cursed)
			owning_run.cursed_rooms_owed--
			current_trait = cursed
			current_trait.modify_plan(src)
			return
	var/trait_chance = owning_run ? owning_run.get_trait_chance() : DUNGEON_ROOM_TRAIT_CHANCE
	if(!prob(trait_chance))
		return
	var/list/pool = get_dungeon_room_traits(src, dungeon_template.room_kind)
	if(!length(pool))
		return
	// Traits are shared singletons - pick one, never qdel any.
	current_trait = pickweight(pool)
	current_trait.modify_plan(src)

/// Applies the rolled trait's post-spawn effects and announces it.
/datum/pocket_dimension/dungeon/proc/apply_room_trait_effects()
	if(!current_trait)
		return
	current_trait.apply_to_room(src)
	for(var/mob/occupant as anything in get_occupants())
		if(occupant.client && current_trait.announce)
			to_chat(occupant, span_warning(current_trait.announce))

/// Spawns count floor-pool guardians on random open turfs; returns them unregistered.
/datum/pocket_dimension/dungeon/proc/scatter_guardians(count, style, list/turf/spawn_turfs)
	var/list/mob/living/spawned = list()
	if(!owning_run?.floor_config)
		return spawned
	var/datum/dungeon_floor_config/cfg = owning_run.floor_config
	var/list/turf/open = spawn_turfs ? spawn_turfs.Copy() : get_guardian_spawn_turfs()
	for(var/i in 1 to count)
		if(!length(open))
			break
		var/turf/spot = pick_guardian_spawn_turf(open)
		open -= spot
		var/datum/dungeon_spawn_entry/entry = pick_floor_spawn_entry(cfg, style, owning_run.get_target_tier())
		if(entry && ispath(entry.mob_type, /mob/living))
			spawned += new entry.mob_type(spot)
	return spawned

/// Spawns floor-pool escorts around a boss: two, plus one per extra party member, up to five.
/datum/pocket_dimension/dungeon/proc/spawn_boss_escorts(mob/living/boss)
	var/party_size = owning_run ? max(1, length(owning_run.present_ckeys)) : 1
	var/count = min(DUNGEON_BOSS_ESCORT_BASE + party_size - 1, DUNGEON_BOSS_ESCORT_MAX)
	var/turf/boss_turf = get_turf(boss)
	var/list/turf/near_boss = list()
	for(var/turf/spot as anything in get_guardian_spawn_turfs())
		if(spot != boss_turf && get_dist(spot, boss_turf) <= 4)
			near_boss += spot
	return scatter_guardians(count, null, length(near_boss) >= count ? near_boss : null)

/// Procedural rooms can reserve tactical positions without replacing the encounter director.
/datum/pocket_dimension/dungeon/proc/get_guardian_spawn_turfs()
	return get_open_dungeon_turfs()

/datum/pocket_dimension/dungeon/proc/pick_guardian_spawn_turf(list/turf/available)
	return pick(available)

/datum/pocket_dimension/dungeon/proc/setup_dungeon_contents()
	var/list/mobs_to_register = list()
	var/list/forced_elites = list()
	var/list/shrine_landmark_turfs = list()
	var/list/larder_turfs = list()
	var/want_scatter = FALSE
	var/scatter_density_override = 0
	var/scatter_marker_style = null
	var/mob/living/escorted_boss

	for(var/turf/current_turf as anything in affected_turfs)
		for(var/obj/effect/landmark/dungeon/guardian/guardian_marker in current_turf)
			if(population_mode == DUNGEON_POP_TRADER || population_mode == DUNGEON_POP_MYSTERY)
				qdel(guardian_marker) // peaceful rooms spawn no guardians
				continue
			var/mob/living/spawned
			if(istype(guardian_marker, /obj/effect/landmark/dungeon/guardian/boss))
				var/obj/effect/landmark/dungeon/guardian/boss/boss_marker = guardian_marker
				spawned = spawn_floor_boss(boss_marker, current_turf)
				if(spawned && boss_marker.brings_escorts)
					escorted_boss = spawned
			else
				spawned = spawn_guardian_from_marker(guardian_marker, current_turf)
			if(spawned)
				mobs_to_register += spawned
				if(guardian_marker.force_elite)
					forced_elites[spawned] = TRUE
				if(istype(guardian_marker, /obj/effect/landmark/dungeon/guardian/keyholder))
					var/obj/effect/landmark/dungeon/guardian/keyholder/kh = guardian_marker
					keyholder_drops["[REF(spawned)]"] = kh.key_id
			qdel(guardian_marker)

		for(var/obj/effect/landmark/dungeon/loot/loot_marker in current_turf)
			var/obj/structure/dungeon_loot_cache/cache = loot_marker.create_cache(current_turf, src)
			if(cache)
				loot_caches += cache
				// Created after layout caching, so mark it native by hand or it
				// would be ejected outside as a "foreign movable" on collapse.
				native_movables[cache] = TRUE
			qdel(loot_marker)

		for(var/obj/effect/landmark/dungeon/gate/gate_marker in current_turf)
			gate_landmark_info += list(list("turf" = current_turf, "role" = gate_marker.gate_role, "path" = gate_marker.path_type, "requires_key" = gate_marker.requires_key, "key_id" = gate_marker.key_id))
			qdel(gate_marker)

		for(var/obj/effect/landmark/dungeon/shrine/shrine_marker in current_turf)
			shrine_landmark_turfs += current_turf
			qdel(shrine_marker)

		for(var/obj/effect/landmark/dungeon/encounter/encounter_marker in current_turf)
			want_scatter = TRUE
			scatter_density_override = max(scatter_density_override, encounter_marker.density_override)
			if(encounter_marker.style_filter)
				scatter_marker_style = encounter_marker.style_filter
			qdel(encounter_marker)

		for(var/obj/effect/landmark/dungeon/larder/larder_marker in current_turf)
			larder_turfs += current_turf
			qdel(larder_marker)

		// Hostile mobs mapped directly into the .dmm count as guardians too.
		for(var/mob/living/simple_animal/hostile/mapped_mob in current_turf)
			if(population_mode == DUNGEON_POP_TRADER || population_mode == DUNGEON_POP_MYSTERY)
				qdel(mapped_mob)
				continue
			mobs_to_register |= mapped_mob

	shrine_turfs = shrine_landmark_turfs

	if(escorted_boss)
		mobs_to_register += spawn_boss_escorts(escorted_boss)

	// Build the larder before guardians register, so natives can be tagged to it.
	if(length(larder_turfs) && owning_run)
		for(var/turf/larder_turf as anything in larder_turfs)
			build_larder(larder_turf)

	// Let a room trait reshape the plan (sets scatter_style_override / scatter_count_bonus).
	roll_room_trait()

	// Wave rooms always run the scatter director, encounter marker or not -
	// any combat template can host a wave challenge.
	if(population_mode == DUNGEON_POP_WAVES)
		want_scatter = TRUE

	// Scatter random mobs from the floor pool, if this room requested an encounter.
	if(want_scatter && owning_run?.floor_config && population_mode != DUNGEON_POP_TRADER && population_mode != DUNGEON_POP_MYSTERY)
		var/datum/dungeon_floor_config/cfg = owning_run.floor_config
		var/count = scatter_density_override > 0 ? scatter_density_override : rand(cfg.density_min, cfg.density_max)
		var/party_size = max(1, length(owning_run.present_ckeys))
		count = min(count + (party_size - 1) + scatter_count_bonus, cfg.density_max + scatter_count_bonus + 4)
		wave_style = scatter_style_override || scatter_marker_style
		wave_count_base = count
		mobs_to_register += scatter_guardians(count, wave_style)
		if(population_mode == DUNGEON_POP_WAVES)
			pending_waves = DUNGEON_WAVE_COUNT - 1
			wave_number = 1

	var/datum/dungeon_floor_config/reg_cfg = owning_run?.floor_config
	var/elite_chance = reg_cfg ? (reg_cfg.elite_chance + owning_run.get_heat_elite_bonus()) : 0
	var/enhance_chance = reg_cfg ? reg_cfg.enhance_chance : 0
	for(var/mob/living/guardian as anything in mobs_to_register)
		var/is_elite = forced_elites[guardian] || (incoming_path_type == DUNGEON_PATH_ELITE) || prob(elite_chance)
		var/force_enhance = prob(enhance_chance)
		register_guardian(guardian, is_elite, force_enhance)

	// A VAULT-promised room hides its treasure behind a key: one guardian
	// becomes the keyholder, and the clear reward is a matching locked cache.
	if(promised_reward == DUNGEON_REWARD_VAULT && length(guardian_refs))
		vault_key_id = "vault_[REF(src)]"
		var/keyholder_ref = pick(guardian_refs)
		keyholder_drops[keyholder_ref] = vault_key_id

	if(population_mode == DUNGEON_POP_TRADER)
		spawn_trader_den()
	else if(population_mode == DUNGEON_POP_MYSTERY)
		spawn_mystery_event()

	apply_room_trait_effects()

	if(!length(guardian_refs))
		on_cleared(silent = TRUE)

/// Spawns a bonus loot cache on a drop turf. Used by door rewards and the
/// Treasure-laden trait. Returns the cache, or null without a valid turf.
/datum/pocket_dimension/dungeon/proc/spawn_bonus_loot_cache(sealed = FALSE, bonus_delve = 0, cache_key_id = null)
	var/turf/spot = get_drop_turf(null)
	if(!spot)
		return null
	var/obj/structure/dungeon_loot_cache/cache = new(spot)
	var/datum/map_template/pocket/dungeon/dungeon_template = get_dungeon_template()
	var/table_type = dungeon_template?.get_loot_table_type(owning_run?.floor || 1)
	if(table_type)
		cache.loot = new table_type
	// Floor-relative, matching guardian scaling - cumulative depth inflated
	// cache quantity by 1.1^depth and rare weights by 1.3^depth.
	cache.delve_level = max(1, (owning_run ? owning_run.get_encounter_delve() : depth) + bonus_delve)
	if(owning_run?.run_unlocks?["extra_cache"])
		cache.claims_left += 1
	if(cache_key_id)
		cache.key_id = cache_key_id
		cache.icon_state = "chestweird1" // vault caches look the part
	if(!sealed)
		cache.unseal()
	loot_caches += cache
	native_movables[cache] = TRUE
	return cache

/// Resolves the run that owns a larder tag (see /datum/dungeon_run/get_larder_tag).
/// Captivity runs in its own pocket, so the captive's location can't identify
/// the run - the tag is the only thread back.
/proc/get_dungeon_run_by_larder_tag(larder_tag)
	if(!larder_tag)
		return null
	for(var/datum/dungeon_run/run as anything in get_active_dungeon_runs())
		if(run.ending)
			continue
		if(run.get_larder_tag() == larder_tag)
			return run
	return null

/// Captivity taken inside a dungeon run. Everything else about a lair stays
/// stock; only the way out changes - a delver hauled off mid-run is released
/// into their party's place of respite, never spat into the overworld wilds
/// halfway across the map.
/datum/defeat_captivity_profile/dungeon_larder
	display_name = "dungeon larder"

/datum/defeat_captivity_profile/dungeon_larder/get_ejection_destination(datum/component/kidnap_captivity/captivity, datum/pocket_dimension/defeat_captivity/instance)
	var/datum/dungeon_run/run = get_dungeon_run_by_larder_tag(captivity?.lair_tag)
	if(run && !QDELETED(run.current_break_room))
		var/turf/respite = run.current_break_room.get_entry_turf()
		if(respite)
			return respite
	// Run is gone (collapsed, wiped): fall back to the stock wilds/origin chain.
	return ..()

/datum/pocket_dimension/dungeon/proc/build_larder(turf/larder_turf)
	if(QDELETED(larder_turf) || !owning_run)
		return
	var/run_tag = owning_run.get_larder_tag()
	var/obj/effect/landmark/kidnap/entrance/lair_entrance = new(larder_turf)
	lair_entrance.lair_tag = run_tag
	LAZYADDASSOCLIST(GLOB.kidnap_entrance_markers, run_tag, lair_entrance)
	LAZYREMOVEASSOC(GLOB.kidnap_entrance_markers, "default", lair_entrance)
	native_movables[lair_entrance] = TRUE
	// Escape tile beside it, so a released captive can crawl out.
	for(var/turf/adjacent as anything in RANGE_TURFS(1, larder_turf))
		if(adjacent == larder_turf || !is_valid_drop_turf(adjacent, null))
			continue
		var/obj/effect/landmark/kidnap/escape/lair_escape = new(adjacent)
		lair_escape.lair_tag = run_tag
		LAZYADDASSOCLIST(GLOB.kidnap_escape_markers, run_tag, lair_escape)
		LAZYREMOVEASSOC(GLOB.kidnap_escape_markers, "default", lair_escape)
		native_movables[lair_escape] = TRUE
		break

/datum/pocket_dimension/dungeon/proc/get_open_dungeon_turfs()
	var/list/turf/open = list()
	for(var/turf/current_turf as anything in affected_turfs)
		if(is_valid_drop_turf(current_turf, null))
			open += current_turf
	return open

/// Spawns a guardian from a marker's own pool, or — if empty, or the marker is
/// the /random subtype — from the run's floor combat pool.
/datum/pocket_dimension/dungeon/proc/spawn_guardian_from_marker(obj/effect/landmark/dungeon/guardian/marker, turf/spawn_turf)
	if(length(marker.mob_pool))
		return marker.spawn_guardian(spawn_turf)
	if(!owning_run?.floor_config)
		return null
	var/style_filter = null
	if(istype(marker, /obj/effect/landmark/dungeon/guardian/random))
		var/obj/effect/landmark/dungeon/guardian/random/random_marker = marker
		style_filter = random_marker.style_filter
	var/datum/dungeon_spawn_entry/entry = pick_floor_spawn_entry(owning_run.floor_config, style_filter, owning_run.get_target_tier())
	if(!entry || !ispath(entry.mob_type, /mob/living))
		return null
	return new entry.mob_type(spawn_turf)

/datum/pocket_dimension/dungeon/proc/spawn_floor_boss(obj/effect/landmark/dungeon/guardian/boss/boss_marker, turf/spawn_turf)
	var/boss_type
	if(boss_marker.use_floor_boss_pool && owning_run?.floor_config && length(owning_run.floor_config.boss_pool))
		boss_type = pickweight(owning_run.floor_config.boss_pool.Copy())
	else if(length(boss_marker.mob_pool))
		boss_type = pickweight(boss_marker.mob_pool.Copy())
	if(!ispath(boss_type, /mob/living))
		return null
	var/mob/living/boss = new boss_type(spawn_turf)
	var/run_floor = owning_run ? owning_run.floor : 1
	var/run_tier = owning_run ? owning_run.get_target_tier() : 1
	var/party_size = owning_run ? max(1, length(owning_run.present_ckeys)) : 1
	var/bounty = make_dungeon_boss(boss, run_floor, run_tier, party_size)
	boss_bounties["[REF(boss)]"] = bounty
	return boss

/datum/pocket_dimension/dungeon/proc/register_guardian(mob/living/guardian, elite = FALSE, force_enhance = FALSE)
	if(QDELETED(guardian) || guardian.stat == DEAD || guardian.mind || guardian.client)
		return
	native_mob_refs["[REF(guardian)]"] = TRUE
	guardian_refs["[REF(guardian)]"] = WEAKREF(guardian)
	if(depth > 0 || elite || force_enhance)
		// enhance_mob_elite subtracts one, so +1 keeps the run's delve intact.
		var/encounter_delve = owning_run ? owning_run.get_encounter_delve() + 1 : 1
		SSmobs.enhance_mob_elite(guardian, encounter_delve, elite ? 2 : 0)
	if(elite)
		elite_guardian_refs["[REF(guardian)]"] = TRUE
		guardian.add_atom_colour("#ffcc33", TEMPORARY_COLOUR_PRIORITY)
		guardian.name = "Champion [guardian.name]"
	// Party scaling: a bigger present party makes guardians tougher.
	var/party_size = owning_run ? max(1, length(owning_run.present_ckeys)) : 1
	if(party_size > 1 && istype(guardian, /mob/living/simple_animal))
		guardian.maxHealth = round(guardian.maxHealth * get_dungeon_party_hp_factor(party_size))
		guardian.health = guardian.maxHealth
	// Heat: Hardened Foes inflates every guardian's health.
	var/heat_hp_mult = owning_run ? owning_run.get_heat_hp_mult() : 1
	if(heat_hp_mult > 1)
		guardian.maxHealth = round(guardian.maxHealth * heat_hp_mult)
		guardian.health = guardian.maxHealth
	// One shared faction so goblins, bogbugs and wolves never brawl each other.
	guardian.set_faction(list(FACTION_DUNGEON))
	// Some carbon NPCs (goblins et al) finish their setup on a delayed
	// after_creation timer that stomps faction back to their overworld one.
	// Re-assert ours after any such timer has fired.
	addtimer(CALLBACK(src, PROC_REF(assert_guardian_faction), WEAKREF(guardian)), 2 SECONDS)
	RegisterSignals(guardian, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(on_guardian_death))
	RegisterSignal(guardian, COMSIG_LIVING_DEFEATED, PROC_REF(on_guardian_defeated))
	// Dungeon natives haul defeated prey to a larder keyed to this run, and the
	// dungeon profile releases them back into the party's break room - never to
	// an overworld lair, which would strand them outside the run.
	guardian.kidnap_lair_tag = owning_run?.get_live_larder_tag()
	guardian.kidnap_captivity_profile = guardian.kidnap_lair_tag ? /datum/defeat_captivity_profile/dungeon_larder : null
	if(iscarbon(guardian))
		// Carbons never reach "dead" cleanly in a brawl - pain/shock thresholds drop
		// them into crit long before health runs out, and their AI flees in pain.
		// Dungeon guardians fight to the fall: no fleeing, and a downed carbon
		// counts as defeated so the room clears.
		if("flee_in_pain" in guardian.vars)
			guardian.vars["flee_in_pain"] = FALSE
		RegisterSignal(guardian, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_carbon_guardian_health))

/// Late faction re-assert: beats deferred NPC setup (goblin after_creation and
/// kin) that would otherwise return a registered guardian to its overworld
/// faction and start dungeon infighting.
/datum/pocket_dimension/dungeon/proc/assert_guardian_faction(datum/weakref/guardian_ref)
	var/mob/living/guardian = guardian_ref?.resolve()
	if(QDELETED(guardian) || !guardian_refs || !guardian_refs["[REF(guardian)]"])
		return
	guardian.set_faction(list(FACTION_DUNGEON))
	guardian.kidnap_lair_tag = owning_run?.get_live_larder_tag()

/// A carbon guardian knocked into crit counts as defeated (see register_guardian).
/datum/pocket_dimension/dungeon/proc/on_carbon_guardian_health(mob/living/source)
	SIGNAL_HANDLER
	if(boss_bounties["[REF(source)]"])
		// Bosses get up from knockouts; only brain failure, death or a spent defeat pool fells them.
		if(source.stat >= HARD_CRIT || source.get_defeat_damage_pool() >= source.get_effective_defeat_threshold())
			on_guardian_death(source)
			if(source.stat != DEAD)
				INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living, death))
		return
	if(source.stat < UNCONSCIOUS)
		return
	on_guardian_death(source)

/// Health multiplier for creature guardians, and toughness multiplier for humanoid bosses.
/proc/get_dungeon_party_hp_factor(party_size = 1)
	return 1 + clamp(party_size - 1, 0, DUNGEON_PARTY_HP_MAX_EXTRA) * DUNGEON_PARTY_HP_PER_MEMBER

/// A knockout only clears a guardian when one of the defeat statuses is actually present.
/datum/pocket_dimension/dungeon/proc/on_guardian_defeated(mob/living/source)
	SIGNAL_HANDLER
	if(!source.has_status_effect(/datum/status_effect/defeat_knockout) && !source.has_status_effect(/datum/status_effect/mob_horny_knockout))
		return
	on_guardian_death(source)

/datum/pocket_dimension/dungeon/proc/on_guardian_death(mob/living/source)
	SIGNAL_HANDLER
	var/source_ref = "[REF(source)]"
	if(!guardian_refs || !guardian_refs[source_ref])
		return // already counted (e.g. downed into crit, then killed)
	UnregisterSignal(source, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING, COMSIG_LIVING_HEALTH_UPDATE, COMSIG_LIVING_DEFEATED))
	if(keyholder_drops[source_ref])
		var/turf/drop_turf = get_turf(source)
		if(drop_turf)
			var/obj/item/dungeon_key/key = new(drop_turf)
			key.key_id = keyholder_drops[source_ref]
			native_movables[key] = TRUE
		keyholder_drops -= source_ref
	if(owning_run)
		var/floor_for_drops = owning_run.floor
		var/drop = DUNGEON_MOTE_GUARDIAN_BASE + (floor_for_drops - 1) * DUNGEON_MOTE_FLOOR_BONUS
		if(boss_bounties[source_ref])
			drop = boss_bounties[source_ref] + (floor_for_drops - 1) * DUNGEON_MOTE_FLOOR_BONUS * 5
		else if(elite_guardian_refs[source_ref])
			drop *= DUNGEON_MOTE_ELITE_MULT
		owning_run.award_motes(drop, source)
	boss_bounties -= source_ref
	elite_guardian_refs -= source_ref
	guardian_refs -= source_ref
	if(!cleared && !length(guardian_refs))
		if(pending_waves > 0)
			spawn_next_wave()
		else
			on_cleared()

/// Wave rooms hold their clear until every wave has fallen; each wave is one
/// mob bigger than the last. Spawns synchronously so tests stay deterministic.
/datum/pocket_dimension/dungeon/proc/spawn_next_wave()
	if(cleared || pending_waves <= 0)
		return
	pending_waves--
	wave_number++
	var/list/mob/living/spawned = scatter_guardians(wave_count_base + (wave_number - 1), wave_style)
	if(!length(spawned))
		// Nowhere left to spawn (or an empty pool): never softlock the room.
		pending_waves = 0
		on_cleared()
		return
	var/datum/dungeon_floor_config/reg_cfg = owning_run?.floor_config
	var/elite_chance = reg_cfg ? (reg_cfg.elite_chance + owning_run.get_heat_elite_bonus()) : 0
	var/enhance_chance = reg_cfg ? reg_cfg.enhance_chance : 0
	for(var/mob/living/guardian as anything in spawned)
		register_guardian(guardian, prob(elite_chance), prob(enhance_chance))
	for(var/mob/occupant as anything in get_occupants())
		if(occupant.client)
			to_chat(occupant, span_userdanger("The dark disgorges another wave!"))

/datum/pocket_dimension/dungeon/proc/on_cleared(silent = FALSE)
	if(cleared)
		return
	cleared = TRUE
	idle_timeout = DUNGEON_CLEARED_IDLE_TIMEOUT
	for(var/obj/structure/dungeon_loot_cache/cache as anything in loot_caches)
		if(!QDELETED(cache))
			cache.unseal()
	if(!silent)
		for(var/mob/occupant as anything in get_occupants())
			to_chat(occupant, span_notice("The hostile presence fades. The walls give a long, grinding groan - this place will not hold its shape forever."))
	owning_run?.on_room_cleared(src)

/datum/pocket_dimension/dungeon/proc/is_native_dungeon_mob(mob/subject)
	if(subject.mind || subject.client)
		return FALSE
	return !!native_mob_refs?["[REF(subject)]"]

// Infinite-run rooms swallow whatever was left on the floor; standalone
// one-shot dungeons keep the base behavior (dropped items eject to the entrance).
/datum/pocket_dimension/dungeon/eject_foreign_movables(items_only = FALSE, atom/override_destination = null)
	if(!delete_foreign_on_collapse)
		return ..()
	for(var/atom/movable/movable as anything in get_preservable_foreign_movables(items_only))
		qdel(movable)
	QDEL_LIST_ASSOC_VAL(hibernated_foreign_movables)
	if(storage && !length(storage.contents))
		QDEL_NULL(storage)

// Native dungeon mobs die with the dungeon instead of being dumped outside.
// Captives held in this room's larder are released before the eject moves them.
/datum/pocket_dimension/dungeon/eject_occupants(message = null, atom/override_destination = null)
	var/run_tag = owning_run?.get_larder_tag()
	for(var/mob/occupant as anything in get_occupants())
		if(QDELETED(occupant))
			continue
		if(current_trait && isliving(occupant))
			current_trait.on_mob_exited(src, occupant)
		if(is_native_dungeon_mob(occupant))
			qdel(occupant)
			continue
		if(run_tag)
			var/datum/component/kidnap_captivity/captivity = occupant.GetComponent(/datum/component/kidnap_captivity)
			if(captivity?.lair_tag == run_tag)
				captivity.end_captivity()
	return ..()

// Only break rooms (and standalone one-bite dungeons) allow stepping back out.
/datum/pocket_dimension/dungeon/can_exit_mob(mob/user, obj/structure/pocket_dimension_exit/exit_object, show_feedback = TRUE)
	var/datum/map_template/pocket/dungeon/dungeon_template = get_dungeon_template()
	if(owning_run && dungeon_template?.room_kind != DUNGEON_ROOM_BREAK)
		if(show_feedback)
			to_chat(user, span_warning("The dungeon's grip is too strong here. I can only leave from a place of respite."))
		return FALSE
	return TRUE

/datum/pocket_dimension/dungeon/enter_mob(mob/user, turf/new_return_turf, atom/new_return_anchor = null)
	. = ..()
	if(. && !contains_turf(get_turf(user)))
		return FALSE
	if(!. || !current_trait || !ismob(user))
		return
	var/mob/entrant = user
	if(entrant.client && current_trait.announce)
		to_chat(entrant, span_warning(current_trait.announce))
	if(isliving(entrant))
		current_trait.on_mob_entered(src, entrant)

/datum/pocket_dimension/dungeon/exit_mob(mob/user)
	var/datum/dungeon_run/run = owning_run
	. = ..()
	if(!. || contains_turf(get_turf(user)))
		return FALSE
	if(!run || !isliving(user))
		return
	var/mob/living/exiter = user
	current_trait?.on_mob_exited(src, exiter)
	run.strip_boons_from(exiter)
	run.mark_absent(exiter)
	run.complete_safe_exit(exiter)
	run.note_possible_run_end()

/// Run rooms are retired only by their owning run. Standalone rooms ignore
/// native guardians, corpses, and spectators when deciding whether abandoned
/// space may collapse.
/datum/pocket_dimension/dungeon/process_idle_lifecycle()
	if(owning_run)
		return FALSE
	if(!idle_timeout || world.time < last_touched + idle_timeout)
		return FALSE
	for(var/mob/living/occupant as anything in get_occupants())
		if(QDELETED(occupant) || occupant.stat == DEAD || is_native_dungeon_mob(occupant))
			continue
		if(occupant.mind || occupant.client)
			return FALSE
	if(lifecycle_policy == POCKET_LIFECYCLE_COLLAPSE && SSpocket_dimensions)
		return SSpocket_dimensions.delete_instance(src)
	return FALSE

/datum/pocket_dimension/dungeon/process_pocket()
	owning_run?.check_abandonment()
	return ..()
