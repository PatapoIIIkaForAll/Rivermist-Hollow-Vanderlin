// ============================================================================
// BARDING / БАРДИНГИ
// ============================================================================

// --- Базовые параметры конских спрайтов ---
/obj/item/clothing/barding
	var/horse_barding_icon = 'modular_rmh/icons/mob/monster/horse_iron (1).dmi'
	var/horse_barding_state = "horse_iron_onmob"

// --- Кольчужный бардинг ---
/obj/item/clothing/barding/chain
	horse_barding_icon = 'modular_rmh/icons/mob/monster/hor_a (2).dmi'
	horse_barding_state = "h_a_i"

// --- Золотой бардинг ---
/obj/item/clothing/barding/gold
	item_weight = 8 KILOGRAMS
	name = "golden barding"
	desc = "A set of golden body armor fitted for a horse."
	icon_state = "armorkit"
	armor_type = /datum/armor/maille
	max_integrity = ARMOR_INT_CHEST_MEDIUM_STEEL
	anvilrepair = /datum/attribute/skill/craft/armor_repair
	smeltresult = /obj/item/ingot/gold
	melting_material = /datum/material/gold
	melt_amount = 100
	sewrepair = null
	salvage_result = null
	salvage_amount = 0
	fiber_salvage = FALSE
	horse_barding_icon = 'modular_rmh/icons/mob/monster/hor_a (2).dmi'
	horse_barding_state = "h_a_g"
	valid_animal_types = list(/mob/living/simple_animal/hostile/retaliate/saiga/horse)

// ============================================================================
// HORSE / ЛОШАДИ
// ============================================================================

/mob/living/simple_animal/hostile/retaliate/saiga/horse
	icon = 'modular_rmh/icons/mob/monster/horse.dmi'
	name = "horse"
	desc = "Proud beasts of burden, war mounts, and symbols of luxury alike."
	icon_state = "horsewhite"
	icon_living = "horsewhite"
	icon_dead = "horsewhite_dead"
	gender = FEMALE
	// horse.dmi ships a unisex saddle rather than saiga's split male/female pair.
	// У Horse единый спрайт седла для обоих полов.
	saddle_overlay_state = "saddle"
	SET_BASE_PIXEL(-8, 0)

/mob/living/simple_animal/hostile/retaliate/saiga/horse/random/Initialize()
	. = ..()
	var/horsecolor = pick("horsewhite","horseblack","horsebrown")
	icon_state = "[horsecolor]"
	icon_living = "[horsecolor]"
	icon_dead = "[horsecolor]_dead"
	gender = pick(MALE, FEMALE)

// --- Приручение и размножение ---
/mob/living/simple_animal/hostile/retaliate/saiga/horse/tamed(mob/user)
	. = ..()
	if(.)
		return
	deaggroprob = 30
	if(can_breed)
		AddComponent(\
			/datum/component/breed,\
			list(/mob/living/simple_animal/hostile/retaliate/saiga/horse, /mob/living/simple_animal/hostile/retaliate/saiga/horse/male),\
			3 MINUTES, \
			list(/mob/living/simple_animal/hostile/retaliate/saiga/horse/kid = 90, /mob/living/simple_animal/hostile/retaliate/saiga/horse/kid/boy = 10),\
			CALLBACK(src, PROC_REF(after_birth)),\
		)

/mob/living/simple_animal/hostile/retaliate/saiga/horse/kid
	icon = 'modular_rmh/icons/mob/monster/horse.dmi'
	name = "foal"
	icon_state = "foalwhite"
	icon_living = "foalwhite"
	icon_dead = "foalwhite_dead"
	icon_gib = "skele"
	gender = FEMALE
	health = CALF_HEALTH
	maxHealth = CALF_HEALTH
	// Matches saigakid: foals are too small to ride, and horse.dmi has no foal mounted overlay.
	// Жеребята слишком малы для езды; отдельного слоя с наездником для них нет.
	can_buckle = FALSE

	adult_growth = /mob/living/simple_animal/hostile/retaliate/saiga/horse

/mob/living/simple_animal/hostile/retaliate/saiga/horse/kid/raondom/Initialize()
	. = ..()
	var/foalcolor = pick("foalwhite","foalblack","foalbrown")
	icon_state = "[foalcolor]"
	icon_living = "[foalcolor]"
	icon_dead = "[foalcolor]_dead"
	gender = pick(MALE, FEMALE)


/mob/living/simple_animal/hostile/retaliate/saiga/horse/male // Делим на два пола, чтобы работал horse/tamed(mob/user)
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/kid/boy // Делим на два пола, чтобы ничего не сломалось, на всякий случай.
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/tame
	tame = TRUE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/male/tame
	tame = TRUE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/tame/saddled/Initialize()
	. = ..()
	var/obj/item/natural/saddle/S = new(src)
	ssaddle = S
	update_appearance(UPDATE_OVERLAYS)

/mob/living/simple_animal/hostile/retaliate/saiga/horse/male/tame/saddled/Initialize()
	. = ..()
	var/obj/item/natural/saddle/S = new(src)
	ssaddle = S
	update_appearance(UPDATE_OVERLAYS)

/mob/living/simple_animal/hostile/retaliate/saiga/horse/black
	icon_state = "horseblack"
	icon_living = "horseblack"
	icon_dead = "horseblack_dead"

/mob/living/simple_animal/hostile/retaliate/saiga/horse/black/male
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/brown
	icon_state = "horsebrown"
	icon_living = "horsebrown"
	icon_dead = "horsebrown_dead"

/mob/living/simple_animal/hostile/retaliate/saiga/horse/brown/male
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/kid/black
	icon_state = "foalblack"
	icon_living = "foalblack"
	icon_dead = "foalblack_dead"

/mob/living/simple_animal/hostile/retaliate/saiga/horse/kid/black/male
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/kid/brown
	icon_state = "foalbrown"
	icon_living = "foalbrown"
	icon_dead = "foalbrown_dead"

/mob/living/simple_animal/hostile/retaliate/saiga/horse/kid/brown/male
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/black/tame
	tame = TRUE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/black/male/tame
	tame = TRUE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/brown/tame
	tame = TRUE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/brown/male/tame
	tame = TRUE

/mob/living/simple_animal/hostile/retaliate/saiga/horse/black/tame/saddled/Initialize()
	. = ..()
	var/obj/item/natural/saddle/S = new(src)
	ssaddle = S
	update_appearance(UPDATE_OVERLAYS)

/mob/living/simple_animal/hostile/retaliate/saiga/horse/black/male/tame/saddled/Initialize()
	. = ..()
	var/obj/item/natural/saddle/S = new(src)
	ssaddle = S
	update_appearance(UPDATE_OVERLAYS)

/mob/living/simple_animal/hostile/retaliate/saiga/horse/brown/tame/saddled/Initialize()
	. = ..()
	var/obj/item/natural/saddle/S = new(src)
	ssaddle = S
	update_appearance(UPDATE_OVERLAYS)

/mob/living/simple_animal/hostile/retaliate/saiga/horse/brown/male/tame/saddled/Initialize()
	. = ..()
	var/obj/item/natural/saddle/S = new(src)
	ssaddle = S
	update_appearance(UPDATE_OVERLAYS)

// --- Обработка смерти ---
/mob/living/simple_animal/hostile/retaliate/saiga/horse/death(gibbed)
	unbuckle_all_mobs(force = TRUE)
	. = ..()
	update_appearance(UPDATE_ICON)

// --- Отрисовка слоёв ---
/mob/living/simple_animal/hostile/retaliate/saiga/horse/update_overlays()
	var/obj/item/clothing/barding/armor = bbarding
	if(!armor)
		return ..()

	var/previous_icon = armor.barding_icon
	var/previous_state = armor.barding_state
	var/previous_female_state = armor.female_barding_state
	armor.barding_icon = armor.horse_barding_icon
	armor.barding_state = armor.horse_barding_state
	armor.female_barding_state = null
	. = ..()
	armor.barding_icon = previous_icon
	armor.barding_state = previous_state
	armor.female_barding_state = previous_female_state
