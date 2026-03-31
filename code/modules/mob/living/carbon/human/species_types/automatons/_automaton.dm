/mob/living/carbon/human/species/automaton
	race = /datum/species/automaton
	footstep_type = FOOTSTEP_MOB_METAL

/mob/living/carbon/human/species/automaton/vessel/LateInitialize()
	. = ..()
	AddComponent(/datum/component/ghost_vessel, /obj/item/reagent_containers/lux)

/mob/living/carbon/human/species/automaton/prefilled_vessel/LateInitialize()
	. = ..()
	AddComponent(/datum/component/ghost_vessel)

/mob/living/carbon/human/species/automaton/vessel/LateInitialize()
	. = ..()
	AddComponent(/datum/component/ghost_vessel, /obj/item/reagent_containers/lux)

/mob/living/carbon/human/species/automaton/prefilled_vessel/LateInitialize()
	. = ..()
	AddComponent(/datum/component/ghost_vessel)

/datum/species/automaton
	name = "Automaton"
	id = SPEC_ID_AUTOMATON
	desc = "The Brass Men of Baldur's Gate, engineered servants of the Artificers Guild. \
	These mechanical beings house souls bound to brass and steel, compelled to serve through ancient artifice. \
	\n\n\
	Following the catastrophic events at Baldur's Gate, automatons are forbidden from wielding weapons - only tools may grace their metal hands. \
	They exist in servitude to the Artificers Guild and nobility, bound by a single immutable law: obey the last order given. \
	\n\n\
	Their speech comes not from lips but from pre-recorded proclamations, their thoughts trapped within a prison of brass and binding runes. \
	\n\n\
	WARNING: THIS IS A HEAVILY RESTRICTED WHITELIST-ONLY SPECIES. EXTENSIVE RP STANDARDS APPLY."

	skin_tone_wording = "Brass Finish"
	default_color = "B87333"

	changesource_flags = WABBAJACK
	meat = list()
	no_equip = list(
		ITEM_SLOT_SHIRT,
		ITEM_SLOT_MASK,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_SHOES,
		ITEM_SLOT_PANTS,
		ITEM_SLOT_CLOAK,
		ITEM_SLOT_BELT,
		ITEM_SLOT_BACK_R,
		ITEM_SLOT_BACK_L
	)

	species_traits = list(
		NO_UNDERWEAR,
		NOTRANSSTING,
		NOBLOOD
	)
	inherent_traits = list(
		TRAIT_NOMOOD,
		TRAIT_NOMETABOLISM,
		TRAIT_NOHUNGER,
		TRAIT_EASYLIMBDISABLE,
		TRAIT_NOSTAMINA,
		TRAIT_EASYDISMEMBER,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOFALLDAMAGE1,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
	)

	specstats_m = list(
		STATKEY_STR = 5,
		STATKEY_PER = 0,
		STATKEY_INT = -9,
		STATKEY_CON = 10,
		STATKEY_END = 10,
		STATKEY_SPD = -9,
		STATKEY_LCK = -3
	)
	specstats_f = list(
		STATKEY_STR = 5,
		STATKEY_PER = 0,
		STATKEY_INT = -9,
		STATKEY_CON = 10,
		STATKEY_END = 10,
		STATKEY_SPD = -9,
		STATKEY_LCK = -3
	)

	allowed_pronouns = PRONOUNS_LIST_IT_ONLY

	possible_ages = ALL_AGES_LIST
	use_skintones = TRUE

	order_num = 22

	native_language = "Common"

	limbs_icon_m = 'icons/roguetown/mob/bodies/m/automaton.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/m/automaton.dmi'

	enflamed_icon = "widefire"

	exotic_bloodtype = /datum/blood_type/oil

	custom_id = "automaton"
	custom_clothes = FALSE

	offset_features_m = list()
	offset_features_f = list()

	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/automaton,
		ORGAN_SLOT_HEART = /obj/item/organ/heart/automaton,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/automaton,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
	)

	var/list/actions = list(
		/datum/action/manage_voice_actions
	)
	/// Whether this synthetic form speaks through locked automaton voice lines.
	var/voice_locked = TRUE
	/// Additional multiplicative slowdown applied on top of stat changes.
	var/movespeed_slowdown = 0.9

/datum/species/automaton/proc/add_synthetic_components(mob/living/carbon/C)
	C.AddComponent(/datum/component/abberant_eater, list(/obj/item/ore/coal, /obj/item/grown/log/tree))
	C.AddComponent(/datum/component/steam_life)
	C.AddComponent(/datum/component/command_follower)
	C.AddComponent(/datum/component/augmentable)
	C.AddComponent(/datum/component/easy_repair)
	C.AddComponent(/datum/component/damage_shutdown)

/datum/species/automaton/proc/remove_synthetic_components(mob/living/carbon/C)
	var/datum/component/component

	component = C.GetComponent(/datum/component/abberant_eater)
	component?.RemoveComponent()

	component = C.GetComponent(/datum/component/steam_life)
	component?.RemoveComponent()

	component = C.GetComponent(/datum/component/command_follower)
	component?.RemoveComponent()

	component = C.GetComponent(/datum/component/augmentable)
	component?.RemoveComponent()

	component = C.GetComponent(/datum/component/easy_repair)
	component?.RemoveComponent()

	component = C.GetComponent(/datum/component/damage_shutdown)
	component?.RemoveComponent()

/datum/species/automaton/proc/add_species_actions(mob/living/carbon/C)
	for(var/datum/action/action as anything in actions)
		C.add_spell(action)

/datum/species/automaton/proc/remove_species_actions(mob/living/carbon/C)
	for(var/datum/action/action as anything in actions)
		C.remove_spell(action)

/datum/species/automaton/proc/apply_robotic_bodyparts(mob/living/carbon/C)
	for(var/obj/item/bodypart/part as anything in C.bodyparts)
		part.status = BODYPART_ROBOTIC

/datum/species/automaton/proc/reset_robotic_bodyparts(mob/living/carbon/C)
	for(var/obj/item/bodypart/part as anything in C.bodyparts)
		if(part.status == BODYPART_ROBOTIC)
			part.status = BODYPART_ORGANIC

/datum/species/automaton/on_species_gain(mob/living/carbon/C, datum/species/old_species, datum/preferences/pref_load)
	. = ..()
	add_synthetic_components(C)

	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	C.grant_language(/datum/language/common)

	add_species_actions(C)

	if(movespeed_slowdown)
		C.add_movespeed_modifier("automaton", multiplicative_slowdown = movespeed_slowdown)

	apply_robotic_bodyparts(C)

/datum/species/automaton/on_species_loss(mob/living/carbon/C, datum/species/new_species)
	. = ..()
	if(!istype(new_species, /datum/species/automaton))
		reset_robotic_bodyparts(C)
	remove_synthetic_components(C)
	remove_species_actions(C)
	UnregisterSignal(C, list(COMSIG_MOB_SAY))
	C.remove_language(/datum/language/common)
	C.remove_movespeed_modifier("automaton")

/datum/species/automaton/check_roundstart_eligible()
	return FALSE

/datum/species/automaton/handle_speech(mob/living/carbon/human/speaker, list/speech_args)
	if(voice_locked)
		return COMPONENT_SPEECH_CANCEL
	return ..()

/datum/species/automaton/get_skin_list()
	if((MUTCOLORS in species_traits) || (MUTCOLORS_PARTSONLY in species_traits))
		return get_common_mutant_color_palette()
	return sortList(list(
		"Polished Brass" = "B87333",
		"Tarnished Bronze" = "8C7853",
		"Steel Grey" = "71797E",
		"Copper Shine" = "B87A3D",
		"Iron Dark" = "464646",
		"Golden Alloy" = "D4AF37"
	))

/datum/species/automaton/get_possible_names(gender = MALE)
	var/static/list/automaton_names = list(
		"Breath of Annihilation",
		"Seeker of Truth",
		"Shadow of Intent",
		"Song of Retribution",
		"Herald of Judgment",
		"Whisper of Oblivion",
		"Fist of Conviction",
		"Eye of Eternity",
		"Voice of Silence",
		"Hand of Providence",
		"Keeper of Mysteries",
		"Bearer of Burdens",
		"Walker of Paths",
		"Guardian of Thresholds",
		"Servant of Order"
	)
	return automaton_names

/datum/species/automaton/get_possible_surnames(gender = MALE)
	return list()

/obj/item/organ/brain/automaton
	name = "soul core"
	desc = "A crystalline matrix containing a trapped soul, bound in service through dark artifice."
	icon_state = "soul_core"

/obj/item/organ/heart/automaton
	name = "steam engine"
	desc = "A miniature steam engine that powers the automaton's movements."

/obj/item/organ/eyes/automaton
	name = "optical sensors"
	desc = "Glowing lenses that allow the automaton to perceive the world."

/datum/blood_type/oil
	name = "Lubricating Oil"
	color = "#1C1C1C"
