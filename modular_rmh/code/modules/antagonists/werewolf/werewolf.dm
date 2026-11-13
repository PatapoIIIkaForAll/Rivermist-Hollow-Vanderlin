// Hungry Beasts

/datum/antagonist/werewolf
	name = "Werewolf"
	roundend_category = "Werewolves"
	antagpanel_category = "Werewolf"
	job_rank = ROLE_WEREWOLF
	antag_hud_type = ANTAG_HUD_WEREWOLF
	antag_hud_name = "werewolf"
	confess_lines = list(
		"THE BEAST INSIDE ME!",
		"BEWARE THE BEAST!",
		"MY LUPINE MARK!",
	)
	var/special_role = ROLE_WEREWOLF
	/// Are we currently out of our human form? Redundancy to easily check for transformation.
	var/transformed
	/// How much rage decays by while transformed.
	// With the base -0.5 this drains 1 per life tick: a full bar lasts five idle minutes.
	var/transformed_rage_decay = 0.5
	/// TRUE while the werewolf is stuck in the transformation animation.
	var/transformation_in_progress = FALSE
	/// Consecutive nightfalls spent without letting the beast out.
	var/nights_without_transformation = 0
	/// TRUE once either form change has happened since the previous nightfall.
	var/transformed_since_last_nightfall = FALSE
	/// Cached time-of-day value used to detect nightfall without touching the night subsystem.
	var/last_seen_tod = null
	/// TRUE once the werewolf has denied a full moon and must transform as soon as possible.
	var/forced_transformation_pending = FALSE
	/// TRUE while the beast-form rage decay penalty is applied to the rage datum.
	var/transform_rage_decay_active = FALSE
	/// Whether skipping nights builds transformation pressure. Lesser kin carry too shallow a curse for it.
	var/subject_to_moon_pressure = TRUE

	var/wolfname = "Werewolf"
	/// Id of the /datum/werewolf_form_look the beast body draws from.
	var/form_look_id = WEREWOLF_LOOK_LEAN
	var/list/datum/action/werewolf_form_powers = list(
		/datum/action/cooldown/spell/undirected/howl, \
		/datum/action/cooldown/spell/undirected/claws, \
		/datum/action/cooldown/spell/aoe/repulse/howl, \
		/datum/action/cooldown/spell/woundlick, \
		/datum/action/cooldown/spell/lunge, \
		/datum/action/cooldown/spell/throw_target, \
		/datum/action/cooldown/keen_nose, \
		/datum/action/cooldown/spell/werewolf_voluntary_bite
	)
	COOLDOWN_DECLARE(message_cooldown)

	innate_traits = list(
		TRAIT_STRONGBITE,
		TRAIT_BESTIALSENSE,
		TRAIT_BRUSHWALK,
		TRAIT_WEREWOLFDEN
	)

/datum/antagonist/werewolf/lesser
	name = "Lesser Werewolf"
	antag_hud_type = ANTAG_HUD_WEREWOLF
	antag_hud_name = "werewolf_lesser"
	increase_votepwr = FALSE
	subject_to_moon_pressure = FALSE

/datum/antagonist/werewolf/lesser/roundend_report()
	return

/// Runs on the examined wolf's datum; only a werewolf examiner recognises its kin.
/datum/antagonist/werewolf/examine_friendorfoe(datum/antagonist/examined_datum, mob/examiner, mob/examined)
	if(!IS_WEREWOLF(examiner))
		return null
	var/lineage_line = get_lineage_examine_line(examiner)
	if(lineage_line)
		return lineage_line
	if(istype(examined_datum, /datum/antagonist/werewolf/lesser))
		return span_boldnotice("A young lupine kin.")
	return span_boldnotice("An elder lupine kin.")

/// Runs on the examiner's datum; the beast smells vampires up close.
/datum/antagonist/werewolf/examine_target(mob/examiner, mob/examined, list/P, list/examine_contents)
	. = ..()
	var/vampire_line = get_vampire_examine_line(examiner, examined)
	if(vampire_line)
		LAZYADDASSOCLIST(examine_contents, EXAMINE_SECT_PREGEAR, vampire_line)

/// Warning a beast-form examiner gets beside a vampire, or null.
/datum/antagonist/werewolf/proc/get_vampire_examine_line(mob/examiner, mob/examined)
	if(!transformed || examiner == examined || !examiner.Adjacent(examined))
		return null
	if(examined.mind?.has_antag_datum(/datum/antagonist/vampire/lord))
		return span_boldwarning("An Ancient Vampire. I must be careful!")
	if(examined.mind?.has_antag_datum(/datum/antagonist/vampire))
		return span_boldwarning("A vampire.")
	return null

/datum/antagonist/werewolf/on_gain()
	SSmapping.retainer.werewolves |= owner
	owner.special_role = name
	forge_werewolf_objectives()

	owner.current.grant_language(/datum/language/beast)
	owner.current.add_faction(FACTION_WOLVES)

	wolfname = random_werewolf_name()
	load_beast_profile()
	last_seen_tod = GLOB.tod
	grant_werewolf_powers()
	return ..()

/proc/random_werewolf_name()
	return "[pick(strings("werewolf_names.json", "wolf_prefixes"))] [pick(strings("werewolf_names.json", "wolf_suffixes"))]"

/datum/antagonist/werewolf/proc/get_form_look()
	RETURN_TYPE(/datum/werewolf_form_look)
	return get_werewolf_form_look(form_look_id)

/// The curse's full kit - beast form, lair, contracts, rage. Lesser kin override this with their shallow gift.
/datum/antagonist/werewolf/proc/grant_werewolf_powers()
	owner.current.add_spell(/datum/action/cooldown/spell/undirected/werewolf_form, source = owner)
	initialize_werewolf_lair_ability()
	initialize_werewolf_contract_interface()
	grant_moon_reading()

	var/datum/rage/werewolf/new_rage = new
	new_rage.grant_to_holder(owner.current)

/// Mirror of grant_werewolf_powers, called on antag removal.
/datum/antagonist/werewolf/proc/remove_werewolf_powers()
	remove_werewolf(forced = TRUE)
	clear_transformation_pressure()
	cleanup_werewolf_lair()
	cleanup_werewolf_contract_interface()
	remove_moon_reading()

	if(owner.current)
		owner.current.remove_spell(/datum/action/cooldown/spell/undirected/werewolf_form)

	if(ishuman(owner.current))
		var/mob/living/carbon/human/current_human = owner.current
		QDEL_NULL(current_human.rage_datum)

/datum/antagonist/werewolf/on_removal()
	remove_werewolf_powers()

	// owner.current should now be the original human mob, if not something is terribly wrong
	if(!silent && owner.current)
		to_chat(owner.current, span_danger("I am no longer a [special_role]!"))
	owner.special_role = null

	if(owner.current)
		owner.current.remove_language(/datum/language/beast)
		owner.current.remove_faction(FACTION_WOLVES)

	return ..()

/datum/antagonist/werewolf/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/werewolf/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/werewolf/proc/forge_werewolf_objectives()
	if(!increase_votepwr)
		return
	var/list/new_objectives = list(
		new /datum/objective/werewolf_counter/hunt(),
		new /datum/objective/werewolf_counter/slay(),
		new /datum/objective/werewolf_counter/convert(),
		new /datum/objective/werewolf_counter/trap(),
		new /datum/objective/werewolf_counter/contracts(),
		new /datum/objective/werewolf/pack_keeper(),
		new /datum/objective/werewolf/survive(),
	)
	if(owner.current?.getorganslot(ORGAN_SLOT_TESTICLES))
		new_objectives.Insert(1, new /datum/objective/werewolf_counter/breed())
	for(var/datum/objective/objective as anything in new_objectives)
		objective.owner = owner
		objectives += objective

/datum/antagonist/werewolf/greet()
	to_chat(owner.current, span_userdanger("Ever since that bite, I have been a [name]."))
	owner.announce_objectives()
	return ..()

/mob/living/carbon/human/proc/can_werewolf()
	if(!mind)
		return FALSE
	if(is_antag_banned(ckey, ROLE_WEREWOLF))
		return FALSE
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		return FALSE
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		return FALSE
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		return FALSE
	if(mind.has_antag_datum(/datum/antagonist/skeleton))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SILVER_BLESSED))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/werewolf_check(werewolf_type = /datum/antagonist/werewolf/lesser)
	if(!mind)
		return
	var/already_wolfy = mind.has_antag_datum(/datum/antagonist/werewolf)
	if(already_wolfy)
		return already_wolfy
	if(!can_werewolf())
		return
	return mind.add_antag_datum(werewolf_type)

/mob/living/carbon/human/proc/werewolf_infect_attempt()
	var/datum/antagonist/werewolf/wolfy = werewolf_check()
	var/mob/living/carbon/human/H = src
	if(istype(H.wear_neck, /obj/item/clothing/neck/psycross/silver) || istype(H.wear_wrists, /obj/item/clothing/neck/psycross/silver))
		if(prob(50))
			return
	if(!wolfy)
		return
	if(stat >= DEAD) //do shit the natural way i guess
		return
	to_chat(src, span_danger("I feel horrible... REALLY horrible..."))
	MOBTIMER_SET(src, MT_PUKE)
	vomit(1, blood = TRUE, stun = FALSE)
	return wolfy

/mob/living/carbon/human/proc/werewolf_feed(mob/living/carbon/human/target, healing_amount = 10)
	if(!istype(target))
		return
	if(src.has_status_effect(/datum/status_effect/debuff/silver_bane))
		to_chat(src, span_notice("My power is weakened, I cannot heal!"))
		return
	if(target.mind)
		if(target.mind.has_antag_datum(/datum/antagonist/zombie))
			to_chat(src, span_warning("I should not feed on rotten flesh."))
			return
		if(target.mind.has_antag_datum(/datum/antagonist/vampire))
			to_chat(src, span_warning("I should not feed on corrupted flesh."))
			return
		if(target.mind.has_antag_datum(/datum/antagonist/werewolf))
			to_chat(src, span_warning("I should not feed on my kin's flesh."))
			return

	to_chat(src, span_warning("I feed on succulent flesh. I feel reinvigorated."))
	return src.reagents.add_reagent(/datum/reagent/medicine/healthpot, healing_amount)

/obj/item/clothing/armor/regenerating/skin/werewolf_skin
	slot_flags = null
	name = "werewolf's skin"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/brigandine
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = null
	max_integrity = INTEGRITY_STRONG
	item_flags = DROPDEL
	repair_time = 15 SECONDS

/obj/item/clothing/armor/regenerating/skin/werewolf_skin/Destroy()
	var/mob/living/carbon/human/werewolf_owner = loc
	if(istype(werewolf_owner) && werewolf_owner.skin_armor == src)
		werewolf_owner.skin_armor = null
	return ..()

/datum/intent/simple/werewolf
	name = "claw"
	icon_state = "inclaw"
	blade_class = BCLASS_CHOP
	attack_verb = list("claws", "mauls", "eviscerates")
	animname = "claw"
	hitsound = "genslash"
	penfactor = 45
	candodge = TRUE
	canparry = TRUE
	miss_text = "slashes the air!"
	miss_sound = "bluntwooshlarge"
	item_damage_type = "slash"

/obj/item/weapon/werewolf_claw
	name = "verewolf claw"
	desc = ""
	icon = 'icons/roguetown/weapons/32/special.dmi'
	item_state = null
	lefthand_file = null
	righthand_file = null
	max_blade_int = 900
	max_integrity = 900
	force = 15
	block_chance = 0
	wdefense = AVERAGE_PARRY
	associated_skill = /datum/attribute/skill/combat/unarmed
	wlength = WLENGTH_NORMAL
	wbalance = EASY_TO_DODGE
	w_class = WEIGHT_CLASS_BULKY
	can_parry = TRUE
	sharpness = IS_SHARP
	swingsound = BLADEWOOSH_MED
	possible_item_intents = list(/datum/intent/simple/werewolf)
	parrysound = list('sound/combat/hits/punch/punch (1).ogg', 'sound/combat/hits/punch/punch (2).ogg', 'sound/combat/hits/punch/punch (3).ogg')
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 0, "embedded_fall_chance" = 0)
	item_flags = DROPDEL

/obj/item/weapon/werewolf_claw/Initialize()
	. = ..()
	AddElement(/datum/element/walking_stick)
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOEMBED, TRAIT_GENERIC)

/obj/item/weapon/werewolf_claw/right
	icon_state = "claw_r"

/obj/item/weapon/werewolf_claw/left
	icon_state = "claw_l"

