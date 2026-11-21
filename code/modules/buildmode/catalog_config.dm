/**
 * Spawn catalogue customization (port of Ratwood 2.0 PR 123, regrouped for this codebase).
 *
 * These tables are shared and read-only during a round.
 * Keep ids stable: personal saves store ids, while labels may be renamed freely.
 * Subgroups use the first matching root, so put specific types before broader ones.
 * Roots are real typepaths on purpose: a removed or misspelled root fails at compile time.
 */

/// Sidebar categories, in display order.
/proc/buildmode_catalog_categories()
	var/static/list/categories = list(
		"all" = "Everything",
		"favorites" = "Favourites",
		"recent" = "Recent",
		"turfs" = "Turfs",
		"objects" = "Objects",
		"mobs" = "Mobs",
		"items" = "Items",
		"weapons" = "Weapons",
		"clothing" = "Clothing & Armor",
		"food" = "Food",
		"reagents" = "Liquid Vessels",
		"effects" = "Helpers & Effects",
	)
	return categories

/// Which category a type belongs to. Order matters and is separate from the sidebar order.
/proc/buildmode_catalog_category(target_type)
	if(ispath(target_type, /turf))
		return "turfs"
	if(ispath(target_type, /mob))
		return "mobs"
	if(ispath(target_type, /obj/item/clothing))
		return "clothing"
	if(ispath(target_type, /obj/item/weapon) || ispath(target_type, /obj/item/gun) || ispath(target_type, /obj/item/ammo_casing) || ispath(target_type, /obj/item/ammo_holder) || ispath(target_type, /obj/item/ammo_box))
		return "weapons"
	if(ispath(target_type, /obj/item/reagent_containers/food))
		return "food"
	if(ispath(target_type, /obj/item/reagent_containers))
		return "reagents"
	if(ispath(target_type, /obj/item))
		return "items"
	if(ispath(target_type, /obj/effect))
		return "effects"
	return "objects"

/proc/buildmode_catalog_armor_classes()
	var/static/list/classes = list(
		"all" = "Any armor class",
		"[ARMOR_CLASS_NONE]" = "No class",
		"[AC_LIGHT]" = "Light",
		"[AC_MEDIUM]" = "Medium",
		"[AC_HEAVY]" = "Heavy",
	)
	return classes

/proc/buildmode_catalog_coverage_zones()
	var/static/list/zones = list(
		"all" = list("name" = "Any coverage", "mask" = 0),
		"head" = list("name" = "Head", "mask" = HEAD),
		"face" = list("name" = "Face", "mask" = (MOUTH | NOSE | EYES)),
		"neck" = list("name" = "Neck", "mask" = NECK),
		"chest" = list("name" = "Chest", "mask" = CHEST),
		"arms" = list("name" = "Arms", "mask" = ARMS),
		"hands" = list("name" = "Hands", "mask" = HANDS),
		"groin" = list("name" = "Groin", "mask" = GROIN),
		"legs" = list("name" = "Legs", "mask" = LEGS),
		"feet" = list("name" = "Feet", "mask" = FEET),
	)
	return zones

/// category id -> list(group id -> list("name", "roots")). A group without roots catches the rest.
/proc/buildmode_catalog_groups()
	var/static/list/groups
	if(groups)
		return groups
	groups = list()
	groups["weapons"] = list(
		"swords" = list("name" = "Swords", "roots" = list(/obj/item/weapon/sword)),
		"knives" = list("name" = "Knives & daggers", "roots" = list(/obj/item/weapon/knife, /obj/item/weapon/katar)),
		"axes" = list("name" = "Axes", "roots" = list(/obj/item/weapon/axe, /obj/item/weapon/greataxe)),
		"maces" = list("name" = "Maces & hammers", "roots" = list(/obj/item/weapon/mace, /obj/item/weapon/hammer)),
		"flails" = list("name" = "Flails & whips", "roots" = list(/obj/item/weapon/flail, /obj/item/weapon/whip)),
		"polearms" = list("name" = "Polearms", "roots" = list(/obj/item/weapon/polearm, /obj/item/weapon/pitchfork)),
		"shields" = list("name" = "Shields", "roots" = list(/obj/item/weapon/shield)),
		"ranged" = list("name" = "Ranged & ammunition", "roots" = list(/obj/item/gun, /obj/item/ammo_casing, /obj/item/ammo_holder, /obj/item/ammo_box)),
		"tools" = list(
			"name" = "Tools",
			"roots" = list(
				/obj/item/weapon/pick,
				/obj/item/weapon/sickle,
				/obj/item/weapon/hoe,
				/obj/item/weapon/chisel,
				/obj/item/weapon/shovel,
				/obj/item/weapon/tongs,
				/obj/item/weapon/thresher,
				/obj/item/weapon/surgery,
			),
		),
		"scabbards" = list("name" = "Scabbards", "roots" = list(/obj/item/weapon/scabbard)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	groups["clothing"] = list(
		"head" = list("name" = "Headwear", "roots" = list(/obj/item/clothing/head)),
		"face" = list("name" = "Face & masks", "roots" = list(/obj/item/clothing/face)),
		"neck" = list("name" = "Neck", "roots" = list(/obj/item/clothing/neck)),
		"armor" = list("name" = "Body armor", "roots" = list(/obj/item/clothing/armor)),
		"shirt" = list("name" = "Shirts", "roots" = list(/obj/item/clothing/shirt)),
		"cloak" = list("name" = "Cloaks", "roots" = list(/obj/item/clothing/cloak)),
		"gloves" = list("name" = "Gloves & wrists", "roots" = list(/obj/item/clothing/gloves, /obj/item/clothing/wrists)),
		"pants" = list("name" = "Pants & legwear", "roots" = list(/obj/item/clothing/pants, /obj/item/clothing/legwears)),
		"shoes" = list("name" = "Shoes", "roots" = list(/obj/item/clothing/shoes)),
		"rings" = list("name" = "Rings", "roots" = list(/obj/item/clothing/ring)),
		"underwear" = list("name" = "Underwear", "roots" = list(/obj/item/clothing/undies, /obj/item/clothing/undershirt, /obj/item/clothing/bra)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	groups["items"] = list(
		"storage" = list("name" = "Bags & containers", "roots" = list(/obj/item/storage)),
		"keys" = list("name" = "Keys & coins", "roots" = list(/obj/item/key, /obj/item/coin)),
		"materials" = list("name" = "Materials", "roots" = list(/obj/item/natural, /obj/item/ore, /obj/item/ingot)),
		"gems" = list("name" = "Gems", "roots" = list(/obj/item/gem, /obj/item/carvedgem)),
		"books" = list("name" = "Books & paper", "roots" = list(/obj/item/book, /obj/item/textbook, /obj/item/paper, /obj/item/recipe_book)),
		"bodyparts" = list("name" = "Organs & limbs", "roots" = list(/obj/item/organ, /obj/item/bodypart)),
		"farming" = list("name" = "Farming & fishing", "roots" = list(/obj/item/neuFarm, /obj/item/fertilizer, /obj/item/fishing, /obj/item/fishingrod)),
		"magic" = list("name" = "Magic & alchemy", "roots" = list(/obj/item/alch, /obj/item/rune, /obj/item/mana_battery)),
		"lighting" = list("name" = "Light sources", "roots" = list(/obj/item/candle, /obj/item/flashlight)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	groups["food"] = list(
		"produce" = list("name" = "Produce", "roots" = list(/obj/item/reagent_containers/food/snacks/produce)),
		"meat" = list("name" = "Meat & fish", "roots" = list(/obj/item/reagent_containers/food/snacks/meat, /obj/item/reagent_containers/food/snacks/fish, /obj/item/reagent_containers/food/snacks/fryfish)),
		"baked" = list(
			"name" = "Bread & pastry",
			"roots" = list(
				/obj/item/reagent_containers/food/snacks/bread,
				/obj/item/reagent_containers/food/snacks/breadslice,
				/obj/item/reagent_containers/food/snacks/pie,
				/obj/item/reagent_containers/food/snacks/pieslice,
				/obj/item/reagent_containers/food/snacks/tart,
				/obj/item/reagent_containers/food/snacks/biscuit,
			),
		),
		"cooked" = list("name" = "Cooked dishes", "roots" = list(/obj/item/reagent_containers/food/snacks/cooked, /obj/item/reagent_containers/food/snacks/foodbase)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	groups["reagents"] = list(
		"bottles" = list("name" = "Bottles", "roots" = list(/obj/item/reagent_containers/glass/bottle)),
		"drinking" = list("name" = "Cups, carafes & bowls", "roots" = list(/obj/item/reagent_containers/glass/cup, /obj/item/reagent_containers/glass/carafe, /obj/item/reagent_containers/glass/bowl)),
		"buckets" = list("name" = "Buckets", "roots" = list(/obj/item/reagent_containers/glass/bucket)),
		"powders" = list("name" = "Powders & pills", "roots" = list(/obj/item/reagent_containers/powder, /obj/item/reagent_containers/pill)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	groups["objects"] = list(
		"doors" = list(
			"name" = "Doors & barriers",
			"roots" = list(
				/obj/structure/door,
				/obj/structure/tentdoor,
				/obj/structure/floordoor,
				/obj/structure/gate,
				/obj/structure/window,
				/obj/structure/bars,
				/obj/structure/curtain,
				/obj/structure/barricade,
			),
		),
		"storage" = list("name" = "Storage", "roots" = list(/obj/structure/closet, /obj/structure/lootable_structure, /obj/structure/rack, /obj/structure/bookcase)),
		"furniture" = list("name" = "Furniture", "roots" = list(/obj/structure/table, /obj/structure/chair, /obj/structure/bed, /obj/structure/mannequin, /obj/structure/mirror, /obj/structure/throne)),
		"lighting" = list("name" = "Lighting & fire", "roots" = list(/obj/machinery/light)),
		"machines" = list("name" = "Machines & mechanisms", "roots" = list(/obj/structure/fake_machine, /obj/structure/lever, /obj/structure/redstone, /obj/structure/rotation_piece, /obj/structure/waterwheel, /obj/machinery)),
		"nature" = list("name" = "Nature & farming", "roots" = list(/obj/structure/flora, /obj/structure/wild_plant, /obj/structure/soil, /obj/structure/well, /obj/structure/hotspring)),
		"travel" = list(
			"name" = "Stairs & passages",
			"roots" = list(
				/obj/structure/stairs,
				/obj/structure/ladder,
				/obj/structure/dungeon_entrance,
				/obj/structure/dungeon_entry,
				/obj/structure/dungeon_exit,
				/obj/structure/industrial_lift,
				/obj/structure/minecart_rail,
			),
		),
		"traps" = list("name" = "Traps", "roots" = list(/obj/structure/trap)),
		"decoration" = list("name" = "Decoration", "roots" = list(/obj/structure/fluff, /obj/structure/statue, /obj/structure/carpet, /obj/structure/sign)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	groups["mobs"] = list(
		"humans" = list("name" = "Humanoids", "roots" = list(/mob/living/carbon/human)),
		"hostile" = list("name" = "Hostile creatures", "roots" = list(/mob/living/simple_animal/hostile)),
		"animals" = list("name" = "Animals", "roots" = list(/mob/living/simple_animal)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	groups["turfs"] = list(
		"walls" = list("name" = "Walls", "roots" = list(/turf/closed/wall)),
		"mineral" = list("name" = "Rock & mineral", "roots" = list(/turf/closed/mineral)),
		"floors" = list("name" = "Floors", "roots" = list(/turf/open/floor)),
		"water" = list("name" = "Water & lava", "roots" = list(/turf/open/water, /turf/open/lava)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	groups["effects"] = list(
		"landmarks" = list("name" = "Landmarks", "roots" = list(/obj/effect/landmark)),
		"decals" = list("name" = "Decals", "roots" = list(/obj/effect/decal, /obj/effect/turf_decal)),
		"spawners" = list("name" = "Spawners", "roots" = list(/obj/effect/spawner, /obj/effect/mob_spawn)),
		"mapping" = list("name" = "Mapping helpers", "roots" = list(/obj/effect/mapping_helpers)),
		"visuals" = list("name" = "Visual effects", "roots" = list(/obj/effect/temp_visual, /obj/effect/particle_effect, /obj/effect/overlay)),
		"other" = list("name" = "Other", "roots" = list()),
	)
	return groups
