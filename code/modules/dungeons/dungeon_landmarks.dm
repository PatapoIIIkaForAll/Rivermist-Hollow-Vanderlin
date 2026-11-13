/obj/effect/landmark/dungeon
	name = "dungeon marker"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE

// -- Guardian spawn point: replaced by a mob from the pool on dungeon load --

/obj/effect/landmark/dungeon/guardian
	name = "dungeon guardian marker"
	/// Weighted assoc list of mob typepaths; one is spawned on dungeon load
	var/list/mob_pool = list()
	/// Chance this marker spawns anything at all
	var/spawn_chance = 100
	/// Always spawn this guardian as an elite (extra affixes + champion aura)
	var/force_elite = FALSE

/obj/effect/landmark/dungeon/guardian/proc/spawn_guardian(turf/spawn_turf)
	if(!length(mob_pool) || !prob(spawn_chance))
		return null
	var/mob_type = pickweight(mob_pool.Copy())
	if(!ispath(mob_type, /mob/living))
		return null
	return new mob_type(spawn_turf)

/obj/effect/landmark/dungeon/guardian/test
	name = "test dungeon guardian marker"
	mob_pool = list(/mob/living/simple_animal/hostile/retaliate/wolf = 10)

/obj/effect/landmark/dungeon/guardian/random
	name = "random dungeon guardian marker"
	/// Optional style restriction for the floor-pool pick (null = any)
	var/style_filter = null

/obj/effect/landmark/dungeon/encounter
	name = "dungeon encounter marker"
	/// 0 = use the floor config's density_min/max; >0 overrides the count
	var/density_override = 0
	/// Optional style restriction for scattered mobs (null = any)
	var/style_filter = null

/obj/effect/landmark/dungeon/guardian/boss
	name = "dungeon boss marker"
	/// When TRUE, the room pulls its boss from the run's floor config boss_pool
	/// instead of this marker's mob_pool.
	var/use_floor_boss_pool = TRUE
	/// Whether the boss arrives with floor-pool escorts that scale with the party
	var/brings_escorts = TRUE

/obj/effect/landmark/dungeon/guardian/boss/test
	name = "test boss marker"
	use_floor_boss_pool = FALSE
	brings_escorts = FALSE
	mob_pool = list(/mob/living/simple_animal/hostile/boss/dungeon/test = 10)

/obj/effect/landmark/dungeon/guardian/swampgob
	name = "swamp goblin guardian marker"
	mob_pool = list(
		/mob/living/carbon/human/species/goblin/npc/ambush = 12,
		/mob/living/carbon/human/species/goblin/npc = 8,
		/mob/living/simple_animal/hostile/retaliate/bogbug = 5,
		/mob/living/simple_animal/hostile/retaliate/spider = 3,
	)

// -- Standalone singlet encounters -----------------------------------------

/obj/effect/landmark/dungeon/guardian/singlet/bandit
	name = "bandit singlet guardian marker"
	mob_pool = list(/mob/living/carbon/human/species/human/northern/bum/ambush = 10)

/obj/effect/landmark/dungeon/guardian/singlet/bear
	name = "bear singlet guardian marker"
	mob_pool = list(/mob/living/simple_animal/hostile/retaliate/direbear = 10)

/obj/effect/landmark/dungeon/guardian/singlet/ratfolk
	name = "ratfolk singlet guardian marker"
	mob_pool = list(/mob/living/carbon/human/species/rousman/ambush = 10)

/obj/effect/landmark/dungeon/guardian/singlet/spider
	name = "spider singlet guardian marker"
	mob_pool = list(
		/mob/living/simple_animal/hostile/retaliate/spider = 8,
		/mob/living/simple_animal/hostile/retaliate/spider/mutated = 2,
	)

/obj/effect/landmark/dungeon/guardian/singlet/werewolf
	name = "werewolf singlet guardian marker"
	mob_pool = list(/mob/living/simple_animal/hostile/werewolf = 10)

/obj/effect/landmark/dungeon/guardian/singlet/wolf
	name = "wolf singlet guardian marker"
	mob_pool = list(/mob/living/simple_animal/hostile/retaliate/wolf = 10)

/obj/effect/landmark/dungeon/guardian/keyholder
	name = "dungeon keyholder marker"
	/// Key id the dropped key carries; must match a gate in the room
	var/key_id = "default"

/obj/effect/landmark/dungeon/guardian/keyholder/test
	mob_pool = list(/mob/living/simple_animal/hostile/retaliate/wolf = 10)

// -- Loot point: replaced by a sealed reward cache on dungeon load --

/obj/effect/landmark/dungeon/loot
	name = "dungeon loot marker"
	var/cache_type = /obj/structure/dungeon_loot_cache

/obj/effect/landmark/dungeon/loot/proc/create_cache(turf/cache_turf, datum/pocket_dimension/dungeon/owner)
	var/obj/structure/dungeon_loot_cache/cache = new cache_type(cache_turf)
	var/datum/map_template/pocket/dungeon/dungeon_template = owner?.get_dungeon_template()
	var/table_type = dungeon_template?.get_loot_table_type(owner?.owning_run?.floor || 1)
	if(table_type)
		cache.loot = new table_type
	cache.delve_level = max(1, owner?.owning_run ? owner.owning_run.get_encounter_delve() : owner?.depth)
	if(owner?.owning_run?.run_unlocks?["extra_cache"])
		cache.claims_left += 1
	return cache

// -- Gate point: recorded by the instance, built by the run controller --

/obj/effect/landmark/dungeon/gate
	name = "dungeon gate marker"
	var/gate_role = DUNGEON_GATE_FORWARD
	/// DUNGEON_PATH_* — what kind of room this forward gate should lead to
	var/path_type = DUNGEON_PATH_COMBAT
	/// When TRUE, the built gate stays locked until a matching key is delivered
	var/requires_key = FALSE
	/// Key id this gate accepts (matches a keyholder marker's key_id)
	var/key_id = "default"

/obj/effect/landmark/dungeon/gate/back
	name = "dungeon back gate marker"
	gate_role = DUNGEON_GATE_BACK

/obj/effect/landmark/dungeon/shrine
	name = "dungeon shrine marker"
	var/shrine_type = /obj/structure/dungeon_shrine

/// Marks where a run builds its larder: the in-dungeon lair that native captors
/// haul horny-defeated victims to. Becomes a real kidnap entrance (run-tagged)
/// plus an adjacent escape tile at room setup.
/obj/effect/landmark/dungeon/larder
	name = "dungeon larder marker"

/obj/effect/landmark/dungeon/gate/treasure
	name = "dungeon treasure gate marker"
	path_type = DUNGEON_PATH_TREASURE

/obj/effect/landmark/dungeon/gate/elite
	name = "dungeon elite gate marker"
	path_type = DUNGEON_PATH_ELITE

/obj/effect/landmark/dungeon/gate/hazard
	name = "dungeon hazard gate marker"
	path_type = DUNGEON_PATH_HAZARD

// -- Reward cache: sealed until the room is cleared --

/obj/structure/dungeon_loot_cache
	name = "sealed cache"
	desc = "A heavy iron-bound cache, shut tight by some lingering will. Perhaps it opens when the danger passes."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "chestiron_neu"
	density = TRUE
	anchored = TRUE
	var/locked = TRUE
	/// When set, a matching /obj/item/dungeon_key unseals this cache (vault rewards)
	var/key_id
	/// Loot table datum instance; rolled once per opening
	var/datum/loot_table/loot
	/// Delve level passed into the loot table for quantity/rarity scaling
	var/delve_level = 1
	/// Openings left; the party splits what each opening yields
	var/claims_left = 1

/obj/structure/dungeon_loot_cache/Destroy()
	if(loot)
		qdel(loot)
		loot = null
	return ..()

/obj/structure/dungeon_loot_cache/examine(mob/user)
	. = ..()
	if(locked)
		. += span_warning("It is sealed shut by something unseen.")
	else if(claims_left <= 0)
		. += span_notice("It hangs open and empty.")
	else
		. += span_notice("It hangs open, waiting to be claimed.")

/obj/structure/dungeon_loot_cache/proc/unseal()
	if(!locked)
		return
	locked = FALSE
	name = "unsealed cache"
	desc = "A heavy stone cache. Whatever held it shut has let go."
	visible_message(span_notice("[src] clicks and grinds open!"))

/obj/structure/dungeon_loot_cache/attack_hand(mob/user, list/modifiers)
	. = ..()
	try_loot(user)

/obj/structure/dungeon_loot_cache/attackby(obj/item/attacking_item, mob/living/user, list/modifiers)
	if(locked && key_id && istype(attacking_item, /obj/item/dungeon_key))
		var/obj/item/dungeon_key/key = attacking_item
		if(key.key_id != key_id)
			to_chat(user, span_warning("This key does not fit this cache."))
			return TRUE
		qdel(key)
		unseal()
		return TRUE
	return ..()

/obj/structure/dungeon_loot_cache/proc/try_loot(mob/living/user)
	if(!istype(user))
		return FALSE
	if(locked)
		to_chat(user, span_warning("The cache is sealed by some lingering will. Whatever guards this place must fall first."))
		return FALSE
	if(!loot || claims_left <= 0)
		to_chat(user, span_warning("The cache has been picked clean."))
		return FALSE
	claims_left--
	loot.spawn_loot(user, delve_level, user.return_item_rarity())
	if(claims_left > 0)
		user.visible_message(span_notice("[user] hauls spoils out of [src]. Something still glints inside."), span_notice("I haul spoils out of the cache. Something still glints inside."))
		return TRUE
	name = "emptied cache"
	user.visible_message(span_notice("[user] empties [src]."), span_notice("I empty the cache."))
	return TRUE
