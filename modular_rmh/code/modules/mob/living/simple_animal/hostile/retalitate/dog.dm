// Domestic dogs: bought from beast traders and bred at home, never spawned in the wild.
/mob/living/simple_animal/hostile/retaliate/dog
	living_flags = MOVES_ON_ITS_OWN|CAN_BE_FIREMANNED
	icon = 'icons/roguetown/mob/monster/vol.dmi'
	name = "dog"
	desc = "A hound bred for hearth and hunt. Smaller than its wild cousin, but loyal and hard to put down."
	icon_state = "volf_white"
	icon_living = "volf_white"
	icon_dead = "volf_white_dead"
	gender = PLURAL
	faction = list("dogs")
	penis_organ = /obj/item/organ/genitals/penis/knotted
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	emote_hear = null
	emote_see = null
	see_in_dark = 7
	move_to_delay = 2
	vision_range = 9
	aggro_vision_range = 9
	footstep_type = FOOTSTEP_MOB_CLAW

	botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 1,
						/obj/item/alch/bone = 1)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 2,
						/obj/item/natural/hide = 1,
						/obj/item/alch/sinew = 1,
						/obj/item/alch/bone = 1)
	perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 2,
						/obj/item/natural/hide = 2,
						/obj/item/alch/sinew = 2,
						/obj/item/alch/bone = 2)
	remains_type = /obj/effect/decal/remains/wolf

	health = 150
	maxHealth = 150
	food_type = list(/obj/item/reagent_containers/food/snacks/meat,
					/obj/item/alch/bone)

	base_intents = list(/datum/intent/simple/bite)
	attack_sound = list('sound/vo/mobs/vw/attack (1).ogg','sound/vo/mobs/vw/attack (2).ogg','sound/vo/mobs/vw/attack (3).ogg','sound/vo/mobs/vw/attack (4).ogg')
	melee_damage_lower = 10
	melee_damage_upper = 16

	base_constitution = 7
	base_strength = 5
	base_speed = 10

	retreat_distance = 0
	minimum_distance = 0
	deaggroprob = 30
	defprob = 25
	defdrain = 5
	dodgetime = 17
	retreat_health = 0.25

	start_tamed = TRUE
	tame_chance = 40
	bonus_tame_chance = 15
	dendor_taming_chance = DENDOR_TAME_PROB_NONE
	response_help_continuous = "pets"
	response_help_simple = "pet"

	genetics = /datum/animal_genetics/dog
	generate_genetics = TRUE

	ai_controller = /datum/ai_controller/dog

	/// Size relative to the wolf sprite.
	var/sprite_scale = 0.85
	/// Adults get the breed component; puppies do not.
	var/can_breed = TRUE
	COOLDOWN_DECLARE(pet_reaction_cooldown)

/mob/living/simple_animal/hostile/retaliate/dog/Initialize()
	AddComponent(/datum/component/obeys_commands, get_pet_commands()) // before parent: pet commands override signals
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured, 0.75, retreat_health)
	if(can_breed)
		AddComponent(\
			/datum/component/breed,\
			list(/mob/living/simple_animal/hostile/retaliate/dog),\
			3 MINUTES,\
			list(/mob/living/simple_animal/hostile/retaliate/dog/puppy = 100),\
			CALLBACK(src, PROC_REF(after_birth)),\
		)
	// Litter and fertility genes hook the breed component, so apply genes again now it exists.
	if(istype(genetics))
		genetics.refresh()
	var/matrix/scaled = matrix()
	scaled.Scale(sprite_scale)
	scaled.Translate(0, -round(16 * (1 - sprite_scale)))
	transform = scaled

/mob/living/simple_animal/hostile/retaliate/dog/proc/get_pet_commands()
	var/static/list/adult_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/good_boy,
		/datum/pet_command/follow,
		/datum/pet_command/attack,
		/datum/pet_command/fetch,
		/datum/pet_command/play_dead,
		/datum/pet_command/protect_owner,
		/datum/pet_command/aggressive,
		/datum/pet_command/calm,
		/datum/pet_command/pet_breed_other/owner_only,
	)
	return adult_commands

/mob/living/simple_animal/hostile/retaliate/dog/after_birth(mob/living/simple_animal/baby, mob/living/partner)
	. = ..()
	if(istype(baby) && owner && !QDELETED(owner))
		baby.tamed(owner)

// A masterless dog takes the first hand that feeds it; strangers can only earn its friendship.
/mob/living/simple_animal/hostile/retaliate/dog/try_tame(mob/user, additional_tame_chance = 0)
	if(QDELETED(user) || stat >= UNCONSCIOUS)
		return FALSE
	if(!owner || QDELETED(owner))
		tamed(user)
		return TRUE
	if(user == owner || has_ally(user))
		return FALSE
	if(!prob(tame_chance + additional_tame_chance))
		tame_chance += bonus_tame_chance
		return FALSE
	tame_chance = initial(tame_chance)
	befriend(user)
	SEND_SIGNAL(src, COMSIG_FRIENDSHIP_CHANGE, user, 25)
	return TRUE

/mob/living/simple_animal/hostile/retaliate/dog/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(stat != CONSCIOUS || !istype(M) || M.used_intent?.type != INTENT_HELP)
		return
	if(!COOLDOWN_FINISHED(src, pet_reaction_cooldown))
		return
	COOLDOWN_START(src, pet_reaction_cooldown, 5 SECONDS)
	new /obj/effect/temp_visual/heart(loc)
	visible_message(span_notice("[src] wags [p_their()] tail."))
	M.add_stress(/datum/stress_event/pet_animal)

/mob/living/simple_animal/hostile/retaliate/dog/get_sound(input)
	switch(input)
		if("aggro", "cidle")
			return pick('sound/vo/mobs/vw/bark (1).ogg','sound/vo/mobs/vw/bark (2).ogg','sound/vo/mobs/vw/bark (3).ogg','sound/vo/mobs/vw/bark (4).ogg','sound/vo/mobs/vw/bark (5).ogg','sound/vo/mobs/vw/bark (6).ogg','sound/vo/mobs/vw/bark (7).ogg')
		if("pain")
			return pick('sound/vo/mobs/vw/pain (1).ogg','sound/vo/mobs/vw/pain (2).ogg','sound/vo/mobs/vw/pain (3).ogg')
		if("death")
			return pick('sound/vo/mobs/vw/death (1).ogg','sound/vo/mobs/vw/death (2).ogg','sound/vo/mobs/vw/death (3).ogg','sound/vo/mobs/vw/death (4).ogg','sound/vo/mobs/vw/death (5).ogg')
		if("idle")
			if(prob(50))
				return pick('sound/vo/mobs/vw/bark (1).ogg','sound/vo/mobs/vw/bark (2).ogg','sound/vo/mobs/vw/bark (3).ogg')
			return pick('sound/vo/mobs/vw/idle (1).ogg','sound/vo/mobs/vw/idle (2).ogg','sound/vo/mobs/vw/idle (3).ogg','sound/vo/mobs/vw/idle (4).ogg')

/mob/living/simple_animal/hostile/retaliate/dog/taunted(mob/user)
	emote("aggro")

/mob/living/simple_animal/hostile/retaliate/dog/male
	gender = MALE

/mob/living/simple_animal/hostile/retaliate/dog/female
	gender = FEMALE

/mob/living/simple_animal/hostile/retaliate/dog/puppy
	name = "puppy"
	desc = "A clumsy pup, all paws and ears. It will grow into a fine hound."
	health = 40
	maxHealth = 40
	melee_damage_lower = 2
	melee_damage_upper = 4
	base_constitution = 3
	base_strength = 2
	base_speed = 8
	defprob = 10
	retreat_health = 0.5
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	sprite_scale = 0.55
	can_breed = FALSE
	generate_genetics = FALSE
	adult_growth = /mob/living/simple_animal/hostile/retaliate/dog
	botched_butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 1)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 1)
	perfect_butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/steak = 1,
						/obj/item/alch/bone = 1)
	ai_controller = /datum/ai_controller/dog/puppy

/mob/living/simple_animal/hostile/retaliate/dog/puppy/Initialize()
	. = ..()
	adult_growth = gender == FEMALE ? /mob/living/simple_animal/hostile/retaliate/dog/female : /mob/living/simple_animal/hostile/retaliate/dog/male

/mob/living/simple_animal/hostile/retaliate/dog/puppy/get_pet_commands()
	var/static/list/puppy_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/good_boy,
		/datum/pet_command/follow,
		/datum/pet_command/fetch,
		/datum/pet_command/play_dead,
		/datum/pet_command/calm,
	)
	return puppy_commands

/datum/animal_genetics/dog
	guaranteed_genes = list(/datum/animal_gene/dog_coat)

// Dog coats tint the white wolf sprite; kept apart from coat_color so horses never roll them.
/datum/animal_gene/dog_coat
	name = "Coat"
	exclusion_group = GENE_GROUP_COAT_COLOR
	dominant = TRUE
	rarity = 2
	abstract_type = /datum/animal_gene/dog_coat
	gene_flags = GENE_FLAG_INTRINSIC
	type_whitelist = list(/mob/living/simple_animal/hostile/retaliate/dog)
	var/coat_color = COLOR_WHITE

/datum/animal_gene/dog_coat/breed_with(datum/animal_gene/other)
	if(!other || prob(50))
		return new type()
	return new other.type()

/datum/animal_gene/dog_coat/apply_to(mob/living/simple_animal/target)
	. = ..()
	target.color = coat_color

/datum/animal_gene/dog_coat/remove_from(mob/living/simple_animal/target)
	. = ..()
	target.color = null

/datum/animal_gene/dog_coat/cream
	name = "Cream Coat"
	coat_color = "#F2E2C0"

/datum/animal_gene/dog_coat/tan
	name = "Tan Coat"
	coat_color = "#D9A86C"

/datum/animal_gene/dog_coat/red
	name = "Red Coat"
	coat_color = "#C9774A"

/datum/animal_gene/dog_coat/chocolate
	name = "Chocolate Coat"
	coat_color = "#8A5A3C"

/datum/animal_gene/dog_coat/gray
	name = "Gray Coat"
	coat_color = "#9A9A9A"

/datum/animal_gene/dog_coat/black
	name = "Black Coat"
	coat_color = "#4A4440"

/datum/animal_gene/dog_coat/silver
	name = "Silver Coat"
	rarity = 1
	coat_color = "#B8C8DC"
	gene_flags = GENE_FLAG_INTRINSIC | GENE_FLAG_EMERGENCE
	required_parent_genes = list(
		/datum/animal_gene/dog_coat/black,
		/datum/animal_gene/dog_coat/gray,
	)

// Dogs give no milk, wool or eggs, so this gene would only waste a slot.
/datum/animal_gene/productive/allowed_for(mob/living/simple_animal/hostile/target)
	if(istype(target, /mob/living/simple_animal/hostile/retaliate/dog))
		return FALSE
	return ..()
