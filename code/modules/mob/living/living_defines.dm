/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	sight = SEE_SELF
	see_in_dark = 8
	hud_possible = list(ANTAG_HUD)

	var/resize = 1 //Badminnery resize
	/// Player-selected presentation for the mob's assigned job.
	var/job_title_override
	var/job_honorary_override
	var/lastattacker = null
	var/lastattackerckey = null
	var/datum/weakref/lastattacker_weakref = null
	/// Short-lived combat context used to tag the next bit of real damage with its attacker.
	var/datum/weakref/damage_attack_context_weakref = null
	var/damage_attack_context_expires = 0
	/// The most recent damage source that actually changed our health, used for resurrection trauma.
	var/recent_damage_source_time = 0
	var/recent_damage_source_damagetype = null
	var/datum/weakref/recent_damage_source_attacker_weakref = null
	var/recent_damage_source_mob_type = null
	var/recent_damage_source_name = null
	var/recent_damage_source_is_player_controlled = FALSE
	var/recent_damage_source_is_human = FALSE
	/// The last attacker-caused damage we took, even if the final death came later from bleedout or suffocation.
	var/recent_attacker_damage_time = 0
	var/recent_attacker_damage_mob_type = null
	var/recent_attacker_damage_name = null
	var/recent_attacker_damage_is_player_controlled = FALSE
	var/recent_attacker_damage_is_human = FALSE
	/// When the post-spawn ERP preference grace window ends for this body.
	var/erp_preference_edit_grace_expires_at = 0

	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health

	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0		//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0		//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early. slimes also deal cloneloss damage to victims
	/// when the mob goes from "normal" to crit
	var/crit_threshold = HEALTH_THRESHOLD_CRIT
	///When the mob enters hard critical state and is fully incapacitated.
	var/hardcrit_threshold = HEALTH_THRESHOLD_FULLCRIT

	/// Generic bitflags for boolean conditions at the [/mob/living] level. Keep this for inherent traits of living types, instead of runtime-changeable ones.
	var/living_flags = NONE

	/// Flags that determine the potential of a mob to perform certain actions. Do not change this directly.
	var/mobility_flags = MOBILITY_FLAGS_DEFAULT

	var/resting = FALSE
	var/wallpressed = FALSE

	var/pixelshifted = FALSE
	var/pixelshift_x = 0
	var/pixelshift_y = 0

	///The y amount a mob's sprite should be offset due to the current position they're in (e.g. lying down moves your sprite down)Add commentMore actions
	var/body_position_pixel_x_offset = 0
	///The x amount a mob's sprite should be offset due to the current position they're in
	var/body_position_pixel_y_offset = 0

	/// Variable to track the body position of a mob, regardgless of the actual angle of rotation (usually matching it, but not necessarily).
	var/body_position = STANDING_UP
	/// Number of degrees of rotation of a mob. 0 means no rotation, up-side facing NORTH. 90 means up-side rotated to face EAST, and so on.
	var/lying_angle = 0
	/// Value of lying lying_angle before last change. TODO: Remove the need for this.
	var/lying_prev = 0

	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.
	/// How much threat aggressive AI assigns to whoever grabs it.
	var/hostile_grab_retarget_threat = 30
	/// Chance for aggressive AI to try breaking out of a grab each scheduled check.
	var/hostile_grab_resist_chance = 25
	/// Minimum delay between aggressive AI grab-resist checks.
	var/hostile_grab_resist_min_delay = 2 SECONDS
	/// Maximum delay between aggressive AI grab-resist checks.
	var/hostile_grab_resist_max_delay = 5 SECONDS
	/// Timer id for the current aggressive AI grab-resist check.
	var/hostile_grab_resist_timer
	/// How long a horny-valid grabber can hold aggressive AI before becoming a hostile target.
	var/hostile_grab_horny_hostility_delay = 2 MINUTES
	/// Timer id for the current horny-valid grab hold hostility check.
	var/hostile_grab_horny_hostility_timer
	/// When TRUE on a clientless mob, the horny-defeat mechanic can knock it out (mob-KO path, not the
	/// player defeat flow). Set lazily when a clientless mob gains an arousal component. Players ignore it.
	var/mob_horny_defeat_enabled = FALSE
	/// Optional exact per-type climax threshold for creature content. Zero uses the deterministic
	/// immutable base-stat fallback; player bodies normally leave this unset.
	var/horny_defeat_threshold_override = 0
	/// world.time TRAIT_RESTRAINED was gained, 0 while free. Captors read it before hauling bound prey.
	var/restrained_since = 0
	/// world.time of the last try to break bonds or a buckle. A fresh struggle delays the haul.
	var/last_restraint_struggle = 0
	/// REF(captor) -> world.time of its last scene action on us. Lazy; never holds the captor.
	var/list/horny_scene_captors
	var/timeofdeath = 0

	//Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = FALSE //FALSE is off, INCORPOREAL_MOVE_BASIC is normal, INCORPOREAL_MOVE_SHADOW is for ninjas
								//and INCORPOREAL_MOVE_JAUNT is blocked by holy water/salt

	var/list/surgeries //a list of surgery steps. generally empty, they're added when the player is performing them.

	var/now_pushing = null //used by living/Bump() and living/PushAM() to prevent potential infinite loop.

	var/cameraFollow = null

	var/tod = null // Time of death

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is usually 20
	var/divine_fire_stacks = 0 //Identical to fire stacks but has less properties like spreading. Should never be negative.

	var/bloodcrawl = 0 //0 No blood crawling, BLOODCRAWL for bloodcrawling, BLOODCRAWL_EAT for crawling+mob devour
	var/holder = null //The holder for blood crawling
	var/ventcrawler = 0 //0 No vent crawling, 1 vent crawling in the nude, 2 vent crawling always
	var/limb_destroyer = 0 //1 Sets AI behavior that allows mobs to target and dismember limbs with their basic attack.

	var/mob_size = MOB_SIZE_HUMAN
	var/mob_biotypes = MOB_ORGANIC
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and regulate body temperature..
	var/has_limbs = 0 //does the mob have distinct limbs?(arms,legs, chest,head)

	/// Chem effects
	var/list/chem_effects
	/// Current multiplicative scale produced by chemical effects.
	var/chemical_scale = 1
	///How many legs does this mob have by default. This shouldn't change at runtime.
	var/default_num_legs = 2
	///How many legs does this mob currently have. Should only be changed through set_num_legs()
	var/num_legs = 2
	///How many usable legs this mob currently has. Should only be changed through set_usable_legs()
	var/usable_legs = 2

	///How many hands does this mob have by default. This shouldn't change at runtime.
	var/default_num_hands = 2
	///How many hands hands does this mob currently have. Should only be changed through set_num_hands()
	var/num_hands = 2
	///How many usable hands does this mob currently have. Should only be changed through set_usable_hands()
	var/usable_hands = 2

	var/list/pipes_shown = list()
	var/last_played_vent

	var/smoke_delay = 0 //used to prevent spam with smoke reagent reaction on mob.

	var/bubble_icon = "default" //what icon the mob uses for speechbubbles

	var/last_bumped = 0
	var/unique_name = 0 //if a mob's name should be appended with an id when created e.g. Mob (666)

	var/list/butcher_results = null //these will be yielded from butchering with a probability chance equal to the butcher item's effectiveness
	var/list/guaranteed_butcher_results = null //these will always be yielded from butchering
	var/butcher_difficulty = 0 //effectiveness prob. is modified negatively by this amount; positive numbers make it more difficult, negative ones make it easier

	var/hellbound = 0 //People who've signed infernal contracts are unrevivable.

	var/stun_absorption = null //converted to a list of stun absorption sources this mob has when one is added

	var/blood_volume = BLOOD_VOLUME_NORMAL //how much blood the mob has

	var/see_override = 0 //0 for no override, sets see_invisible = see_override in silicon & carbon life process via update_sight()

	var/list/status_effects //a list of all status effects the mob has
	var/druggy = 0

	var/parrying_penalty = 0
	var/parrying_penalty_timer = null
	/// Whether a client is holding the key that temporarily disables passive parrying.
	var/parry_suppressed = FALSE
	var/dodging_penalty = 0
	var/dodging_penalty_timer = null
	/// Charges available for player-controlled dodges.
	var/dodge_charges = DODGE_CHARGE_MAX
	/// Stoppable timer restoring the next player dodge charge.
	var/dodge_charge_timer = null
	/// The current player dodge can avoid one direct hit until this world time.
	var/dodge_grace_until = 0
	/// Whether the current player dodge grace still has its one-hit protection.
	var/dodge_grace_available = FALSE

	//Speech
	var/stuttering = 0
	var/slurring = 0
	var/aroused_slurring = 0
	var/cultslurring = 0
	var/derpspeech = 0

	var/list/implants = null

	/// May this mob be buckled and unbuckled without forcing it?
	var/can_buckle_to = TRUE

	var/datum/language/selected_default_language

	var/last_words	//used for database logging

	var/can_be_held = FALSE	//whether this can be picked up and held.

	var/ventcrawl_layer = 2
	var/losebreath = 0

	var/slowed_by_drag = TRUE //Whether the mob is slowed down when dragging another prone mob

	var/list/ownedSoullinks //soullinks we are the owner of
	var/list/sharedSoullinks //soullinks we are a/the sharer of

	/// List of fatigue modifiers applying to this mob
	var/list/fatigue_modification //Lazy list, see fatigue_modifier.dm
	/// List of fatigue modifiers ignored by this mob. List -> List (id) -> List (sources)
	var/list/fatigue_mod_immunities //Lazy list, see fatigue_modifier.dm

	/// List of stamina modifiers applying to this mob
	var/list/stamina_modification //Lazy list, see stamina_modifier.dm
	/// List of stamina modifiers ignored by this mob. List -> List (id) -> List (sources)
	var/list/stamina_mod_immunities //Lazy list, see stamina_modifier.dm

	// ~WEIGHT SYSTEM
	/// Maximum weight we can carry, this point and beyond means maximum encumbrance
	var/maximum_carry_weight = 72
	/// Weight we are currently carrying
	var/carry_weight = 0
	/// State of encumbrance we are in, cheaper to store this than keeping calling update_carry_weight()
	var/encumbrance = ENCUMBRANCE_NONE

	var/max_energy = 1000
	var/energy = 1000
	var/base_max_energy = 1000

	var/maximum_stamina = 100
	var/stamina = 0
	var/base_max_stamina = 100
	/// Session auto-clench state. Null means follow the saved ERP preference.
	var/auto_clench_override = null

	var/last_fatigued = 0
	var/last_ps = 0

	var/ambushable = 0

	var/surrendering = 0


	/// Combat bonuses for Simple Mobs
	var/simpmob_attack = 0
	var/simpmob_defend = 0

	var/melee_attack_cooldown = 1.4 SECONDS

	var/defprob = 50 //base chance to defend against this mob's attacks, for simple mob combat
	var/defdrain = 5

	/// If the mob's eyes are closed, blinded
	var/eyesclosed = FALSE
	var/fallingas = 0

	var/bleed_rate = 0 //how much are we bleeding
	var/bleedsuppress = 0 //for stopping bloodloss, eventually this will be limb-based like bleeding

	var/list/next_attack_msg = list()

	var/obj/item/grabbing/r_grab = null
	var/obj/item/grabbing/l_grab = null

	var/slowdown

	var/last_dir_change = 0

	var/list/death_trackers = list()

	var/rot_type = /datum/component/rot/simple

	var/list/mob_descriptors
	var/list/custom_descriptors

	var/rogue_sneaking = FALSE

	var/rogue_sneaking_light_threshold = 0.15

	var/voice_pitch = 1

	var/domhand = 0

	///our blood drain for meathook, the less bloody the more we get
	var/blood_drained = 0
	///are we skinned?
	var/skinned = FALSE

	///half of the reflection gate, flipped directly by things like vampirism. See casts_reflection().
	var/has_reflection = TRUE

	///the stencil backend's flipped copy of us, null whenever we cast no reflection
	var/obj/effect/overlay/reflection/reflective_icon

	var/list/mob_offsets = list()

	var/last_deadlife

	var/datum/worker_mind/controller_mind

	var/tempatarget = null
	var/pegleg = 0			//Handles check & slowdown for peglegs. Fuckin' bootleg, literally, but hey it at least works.
	var/pet_passive = FALSE

	/// amount of spell points this mob currently has
	var/spell_points
	/// amount of spell points this mob has used
	var/used_spell_points

	var/list/affixes = list()
	var/delve_level = 0

	var/cold_res = 0
	var/max_cold_res = 75
	var/fire_res = 0
	var/max_fire_res = 75
	var/lightning_res = 0
	var/max_lightning_res = 75

	var/list/status_modifiers

	var/datum/blood_type/animal_type

	/// Pain (pain not taking other damage types into account) damage, generally a side effect of other types of damage
	var/painloss = 0
	/// Shock (pain taking into account other types of damage) damage
	var/traumatic_shock = 0
	/// Shock stage, as in how much our crit has progressed
	var/shock_stage = 0
	/// Last pain related message we have received - Used to prevent spam
	var/last_pain_message = ""
	/// Next time we are able to trigger custom_pain()
	var/next_pain_time = 0
	/// Next time we are able to send a custom_pain() chat message
	var/next_pain_message_time = 0

	/// cooldown for the next time this person can offer
	COOLDOWN_DECLARE(offer_cooldown)
	/// Direction this mob is currently looking vertically.
	var/looking_vertically = NONE
	/// Movable eye target used while looking up or down so the view can follow movement.
	var/atom/movable/looking_holder/looking_holder
	/// Prevents concurrent vertical swim attempts during the swim action.
	COOLDOWN_DECLARE(cd_zswim)

	var/list/roundstart_quirks

	//all mobs get organs
	var/list/internal_organs		= list()	//List of /obj/item/organ in the mob. They don't go in the contents for some reason I don't want to know.
	var/list/internal_organs_slot= list() //Same as above, but stores "slot ID" - list of organs for easy access.

	//Handcuffs and Legcuffs
	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.
