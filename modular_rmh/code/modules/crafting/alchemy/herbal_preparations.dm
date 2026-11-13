#define HERBAL_CANDLE_INTERVAL 10 SECONDS
/// Old-wound bleed_rate that one full dose of clotting assistance may remove, shared across wounds.
#define HERBAL_CLOTTING_RATE 0.1
/// Injury bleed_timer ticks that one full dose of clotting assistance may remove, shared across injuries.
#define HERBAL_CLOTTING_TIMER 5
/// One-time mortar enhancement multiplier for a prepared remedy.
#define HERBAL_ENHANCEMENT_BOOST 1.25
#define HERBAL_ENHANCEMENT_PERCENT 25

// Herb preparation profiles deliberately point at the existing herbal reagents.
// Those reagents remain the authority for effects, dosage, and overdose behavior.
/obj/item/alch/herb
	var/herbal_remedy
	var/herbal_profile
	var/list/herbal_tags
	var/herbal_beneficial = TRUE
	var/dried = FALSE
	var/drying_progress = 0
	var/drying_time = 20 MINUTES
	var/herbal_preparation_quality = 1

/obj/item/alch/herb/examine(mob/user)
	. = ..()
	if(dried)
		. += span_notice("It is fully dried and ready for decoctions or wound pastes.")
	else if(drying_progress > 0)
		. += span_notice("It is partly dried, about [round(100 * drying_progress / drying_time)]% of the way. Finish drying it on a drying rack for stronger decoctions and wound pastes.")
	else
		. += span_notice("It is fresh; dry it on a drying rack for stronger decoctions and wound pastes.")
	if(!isliving(user) || !herbal_remedy)
		return
	var/alchemy_skill = GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/craft/alchemy)
	if(alchemy_skill >= SKILL_RANK_APPRENTICE)
		. += span_info("Its established preparation profile is [herbal_profile].")
		if(!herbal_beneficial)
			. += span_warning("That profile is harmful rather than medicinal.")
	if(alchemy_skill >= SKILL_RANK_JOURNEYMAN && length(herbal_tags))
		. += span_info("Its useful affinities are [english_list(herbal_tags)].")

/obj/item/alch/herb/proc/finish_drying()
	if(dried)
		return
	dried = TRUE
	drying_progress = drying_time
	herbal_preparation_quality = 2
	name = "dried [initial(name)]"
	update_appearance()

/obj/item/alch/herb/artemisia
	herbal_remedy = /datum/reagent/medicine/herbal/decoction/artemisia
	herbal_profile = "a bitter cleansing preparation"
	herbal_tags = list("cleansing")

/obj/item/alch/herb/atropa
	herbal_remedy = /datum/reagent/medicine/herbal/anodyne/atropa
	herbal_profile = "a numbing nightshade preparation"
	herbal_tags = list("pain", "sight")

/obj/item/alch/herb/benedictus
	herbal_remedy = /datum/reagent/medicine/herbal/decoction/benedictus
	herbal_profile = "a cleansing thistle preparation"
	herbal_tags = list("cleansing")

/obj/item/alch/herb/calendula
	herbal_remedy = /datum/reagent/medicine/herbal/calendula_salve
	herbal_profile = "a mending salve"
	herbal_tags = list("healing", "mending")

/obj/item/alch/herb/euphorbia
	herbal_remedy = /datum/reagent/medicine/herbal/decoction/euphorbia
	herbal_profile = "a restorative preparation"
	herbal_tags = list("healing")

/obj/item/alch/herb/euphrasia
	herbal_remedy = /datum/reagent/medicine/herbal/euphrasia_eye_wash
	herbal_profile = "a clarifying oral decoction"
	herbal_tags = list("clarity", "sight")

/obj/item/alch/herb/hypericum
	herbal_remedy = /datum/reagent/medicine/herbal/hypericum_tonic
	herbal_profile = "a restorative clarity tonic"
	herbal_tags = list("clarity", "vitality")

/obj/item/alch/herb/matricaria
	herbal_remedy = /datum/reagent/medicine/herbal/decoction/matricaria
	herbal_profile = "a healing and cleansing preparation"
	herbal_tags = list("healing", "cleansing")

/obj/item/alch/herb/mentha
	herbal_remedy = /datum/reagent/medicine/herbal/mentha_tea
	herbal_profile = "a cleansing clarity tea"
	herbal_tags = list("clarity", "cleansing")

/obj/item/alch/herb/paris
	herbal_remedy = /datum/reagent/poison/herbal/paris_poison
	herbal_profile = "a deadly crow's-eye poison"
	herbal_tags = list("poison")
	herbal_beneficial = FALSE

/obj/item/alch/herb/rosa
	herbal_remedy = /datum/reagent/medicine/herbal/simple_rosa
	herbal_profile = "a soothing restorative"
	herbal_tags = list("healing", "soothing")

/obj/item/alch/herb/salvia
	herbal_remedy = /datum/reagent/buff/herbal/salvia_wisdom
	herbal_profile = "a fortifying wisdom tonic, or a distilled oil that strengthens prepared remedies"
	herbal_tags = list("clarity", "fortitude", "enhancement")

/obj/item/alch/herb/symphitum
	herbal_remedy = /datum/reagent/medicine/herbal/symphitum_tea
	herbal_profile = "a mending tea"
	herbal_tags = list("healing", "mending")

/obj/item/alch/herb/taraxacum
	herbal_remedy = /datum/reagent/medicine/herbal/taraxacum_extract
	herbal_profile = "a cleansing restorative"
	herbal_tags = list("cleansing", "healing")

/obj/item/alch/herb/urtica
	herbal_remedy = /datum/reagent/medicine/herbal/urtica_brew
	herbal_profile = "a blood-restoring brew; one dried bundle strengthens a prepared remedy"
	herbal_tags = list("blood", "vitality", "enhancement")

/obj/item/alch/herb/valeriana
	herbal_remedy = /datum/reagent/medicine/herbal/valeriana_draught
	herbal_profile = "a soothing sleep draught"
	herbal_tags = list("sedation", "soothing")

/obj/item/alch/herb/lavender
	herbal_remedy = /datum/reagent/herbal_enhancer_oil/lavender
	herbal_profile = "a distilled oil that strengthens prepared remedies"
	herbal_tags = list("enhancement", "soothing")

/obj/item/reagent_containers/glass/mortar/examine(mob/user)
	. = ..()
	. += span_notice("Work herbs with measured water and a pestle to prepare wound pastes or crude atropa extract, or strengthen a finished remedy once with an enhancer. Pouring into a mortar adds one selected measure per click; set the amount on the held container. The apothecary's handbook lists the exact mixtures. Brew drinkable remedies in a cooking pot.")

GLOBAL_LIST_INIT(herbal_mortar_recipes, init_subtypes(/datum/herbal_mortar_recipe, list(), allow_abstract = FALSE))

/datum/herbal_mortar_recipe
	abstract_type = /datum/herbal_mortar_recipe
	var/name
	var/category = "Herbal Poultices"
	var/list/herbs = list()
	var/requires_dried = TRUE
	var/water_amount = 10
	var/result_reagent
	var/result_amount = 10
	var/preparation_time = 10 SECONDS

/datum/herbal_mortar_recipe/proc/can_prepare(obj/item/reagent_containers/glass/mortar/mortar)
	if(QDELETED(mortar) || !result_reagent || !length(herbs))
		return FALSE
	if(length(mortar.reagents.reagent_list) != 1 || mortar.reagents.get_reagent_amount(/datum/reagent/water) != water_amount)
		return FALSE
	if(result_amount > mortar.reagents.maximum_volume)
		return FALSE
	var/list/remaining = herbs.Copy()
	for(var/obj/item/ingredient as anything in mortar.to_grind)
		if(QDELETED(ingredient) || ingredient.loc != mortar || !istype(ingredient, /obj/item/alch/herb))
			return FALSE
		var/obj/item/alch/herb/herb = ingredient
		if((requires_dried && !herb.dried) || !remaining[herb.type])
			return FALSE
		remaining[herb.type]--
		if(!remaining[herb.type])
			remaining -= herb.type
	return !length(remaining)

/datum/herbal_mortar_recipe/proc/prepare(obj/item/reagent_containers/glass/mortar/mortar)
	if(!can_prepare(mortar))
		return FALSE
	for(var/obj/item/ingredient as anything in mortar.to_grind.Copy())
		mortar.to_grind -= ingredient
		qdel(ingredient)
	mortar.reagents.remove_reagent(/datum/reagent/water, water_amount)
	mortar.reagents.add_reagent(result_reagent, result_amount)
	return TRUE

/datum/herbal_mortar_recipe/proc/completion_text()
	return "I prepare [result_amount] measures of [name]."

/obj/item/reagent_containers/glass/mortar/proc/try_prepare_herbal_recipe(mob/living/user)
	var/datum/reagent/medicine/herbal/preparation/remedy = locate(/datum/reagent/medicine/herbal/preparation) in reagents.reagent_list
	var/has_herbal_mixture = reagents.has_reagent(/datum/reagent/water) && (locate(/obj/item/alch/herb) in to_grind)
	// Anything else falls through to ordinary dry grinding.
	if(!remedy && !has_herbal_mixture)
		return FALSE
	var/datum/herbal_mortar_recipe/selected
	for(var/datum/herbal_mortar_recipe/recipe as anything in GLOB.herbal_mortar_recipes)
		if(recipe.can_prepare(src))
			selected = recipe
			break
	if(!selected)
		if(remedy?.herbal_enhanced)
			to_chat(user, span_warning("This [remedy.name] has already been enhanced. A batch can only be enhanced once, even after mixing."))
		else
			to_chat(user, span_warning("This is not a known herbal mixture. I need the exact herbs, preparation state, and water, or exactly ten measures of one remedy with a single enhancer, as listed in the apothecary's handbook, with nothing else."))
		return TRUE
	to_chat(user, span_notice("I begin preparing [selected.name]..."))
	playsound(src, 'sound/foley/mortarpestle.ogg', 100, FALSE)
	if(!do_after(user, selected.preparation_time, src) || QDELETED(src) || !user.CanReach(src))
		return TRUE
	// prepare() checks the mortar again, since its contents may have changed during the work.
	if(!selected.prepare(src))
		to_chat(user, span_warning("The ingredients have changed; I cannot finish the preparation."))
		return TRUE
	to_chat(user, span_notice(selected.completion_text()))
	user.adjust_experience(/datum/attribute/skill/craft/alchemy, GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) * user.get_learning_boon(/datum/attribute/skill/craft/alchemy), FALSE)
	return TRUE

/**
 * One-time strengthening of a finished herbal decoction or wound paste.
 * The recipe datum is shared, so it only inspects the mortar it is given and never stores it.
 */
/datum/herbal_mortar_recipe/enhancement
	abstract_type = /datum/herbal_mortar_recipe/enhancement
	category = "Herbal Enhancements"
	water_amount = 0
	/// Finished oil consumed by the enhancement.
	var/datum/reagent/additive_reagent
	var/additive_amount = 5
	/// Fully dried herb bundle consumed instead of an oil.
	var/obj/item/alch/herb/additive_herb

/datum/herbal_mortar_recipe/enhancement/can_prepare(obj/item/reagent_containers/glass/mortar/mortar)
	return !!get_enhanceable_remedy(mortar)

/// Returns the remedy to enhance if the mortar holds exactly this formula, otherwise null.
/datum/herbal_mortar_recipe/enhancement/proc/get_enhanceable_remedy(obj/item/reagent_containers/glass/mortar/mortar)
	if(QDELETED(mortar))
		return
	var/datum/reagent/medicine/herbal/preparation/remedy
	var/found_additive = FALSE
	for(var/datum/reagent/contained as anything in mortar.reagents.reagent_list)
		if(additive_reagent && contained.type == additive_reagent && round(contained.volume, 0.01) == additive_amount)
			found_additive = TRUE
			continue
		if(remedy || !istype(contained, /datum/reagent/medicine/herbal/preparation) || round(contained.volume, 0.01) != result_amount)
			return
		remedy = contained
	if(!remedy || remedy.herbal_enhanced || (additive_reagent && !found_additive))
		return
	if(additive_herb)
		if(length(mortar.to_grind) != 1)
			return
		var/obj/item/alch/herb/herb = mortar.to_grind[1]
		if(QDELETED(herb) || herb.loc != mortar || herb.type != additive_herb || !herb.dried)
			return
	else if(length(mortar.to_grind))
		return
	return remedy

/datum/herbal_mortar_recipe/enhancement/prepare(obj/item/reagent_containers/glass/mortar/mortar)
	var/datum/reagent/medicine/herbal/preparation/remedy = get_enhanceable_remedy(mortar)
	if(!remedy)
		return FALSE
	for(var/obj/item/ingredient as anything in mortar.to_grind.Copy())
		mortar.to_grind -= ingredient
		qdel(ingredient)
	if(additive_reagent)
		mortar.reagents.remove_reagent(additive_reagent, additive_amount)
	remedy.enhance()
	return TRUE

/datum/herbal_mortar_recipe/enhancement/completion_text()
	return "I work the [additive_herb ? "dried [initial(additive_herb.name)]" : initial(additive_reagent.name)] into the remedy. It is noticeably stronger."

/datum/herbal_mortar_recipe/enhancement/return_recipe_data()
	var/list/additive_reagents = list(/datum/reagent/medicine/herbal/preparation = result_amount)
	if(additive_reagent)
		additive_reagents[additive_reagent] = additive_amount
	var/list/additive_herbs = list()
	if(additive_herb)
		additive_herbs[additive_herb] = 1
	var/additive_text = additive_herb ? "one fully dried [initial(additive_herb.name)] bundle" : "exactly [additive_amount] measures of finished [initial(additive_reagent.name)]"
	return list(
		"type" = "container_craft",
		"name" = name,
		"category" = category,
		"craft_verb" = "grinding ",
		"crafting_time" = preparation_time / (1 SECONDS),
		"requirements" = items_list(additive_herbs),
		"reagents" = reagents_list(additive_reagents),
		"container_name" = "mortar and pestle",
		"extra_html" = "Put exactly 10 measures of a single finished herbal decoction or wound paste into the mortar with [additive_text], then use a pestle. No additional ingredients or water may be present.<br>The enhancer is consumed and the same 10 measures become [HERBAL_ENHANCEMENT_PERCENT]% more potent. Volume, quality, and overdose limits do not change.<br>Eligible: remedies from the Herbal Decoctions and Herbal Poultices recipes. Traditional alchemical remedies, poisons, crude extracts, and crude infusions cannot be enhanced.<br>Each batch can be enhanced only once. Mixing an enhanced batch with an unenhanced one loses the bonus, and the mixture still counts as enhanced.",
	)

/datum/herbal_mortar_recipe/enhancement/lavender
	name = "lavender oil enhancement"
	additive_reagent = /datum/reagent/herbal_enhancer_oil/lavender

/datum/herbal_mortar_recipe/enhancement/salvia
	name = "salvia oil enhancement"
	additive_reagent = /datum/reagent/herbal_enhancer_oil/salvia

/datum/herbal_mortar_recipe/enhancement/urtica
	name = "dried urtica enhancement"
	additive_herb = /obj/item/alch/herb/urtica

/datum/herbal_mortar_recipe/calendula
	name = "calendula wound paste"
	herbs = list(/obj/item/alch/herb/calendula = 2)
	result_reagent = /datum/reagent/medicine/herbal/wound_paste/calendula

/datum/herbal_mortar_recipe/mending
	name = "calendula-symphitum wound paste"
	herbs = list(/obj/item/alch/herb/calendula = 1, /obj/item/alch/herb/symphitum = 1)
	result_reagent = /datum/reagent/medicine/herbal/wound_paste/mending

/datum/herbal_mortar_recipe/cooling
	name = "mentha-symphitum wound paste"
	herbs = list(/obj/item/alch/herb/mentha = 1, /obj/item/alch/herb/symphitum = 1)
	result_reagent = /datum/reagent/medicine/herbal/wound_paste/cooling

/datum/herbal_mortar_recipe/anodyne
	name = "atropa wound paste"
	herbs = list(/obj/item/alch/herb/atropa = 1, /obj/item/alch/herb/calendula = 1)
	result_reagent = /datum/reagent/medicine/herbal/wound_paste/anodyne

/datum/herbal_mortar_recipe/matricaria
	name = "matricaria wound paste"
	herbs = list(/obj/item/alch/herb/matricaria = 2)
	result_reagent = /datum/reagent/medicine/herbal/wound_paste/matricaria

/datum/herbal_mortar_recipe/euphrasia
	name = "euphrasia wound paste"
	herbs = list(/obj/item/alch/herb/euphrasia = 2)
	result_reagent = /datum/reagent/medicine/herbal/wound_paste/euphrasia

/datum/herbal_mortar_recipe/calendula_matricaria
	name = "calendula-matricaria wound paste"
	herbs = list(/obj/item/alch/herb/calendula = 1, /obj/item/alch/herb/matricaria = 1)
	result_reagent = /datum/reagent/medicine/herbal/wound_paste/calendula_matricaria

/datum/herbal_mortar_recipe/rosa_valeriana
	name = "rosa-valeriana wound paste"
	herbs = list(/obj/item/alch/herb/rosa = 1, /obj/item/alch/herb/valeriana = 1)
	result_reagent = /datum/reagent/medicine/herbal/wound_paste/rosa_valeriana

/datum/herbal_mortar_recipe/atropa_extract
	name = "crude atropa extract"
	category = "Herbal Precursors"
	herbs = list(/obj/item/alch/herb/atropa = 1)
	requires_dried = FALSE
	result_reagent = /datum/reagent/poison/herbal/weak_atropa

/**
 * Shared parent of prepared decoctions and wound pastes.
 * Strength and one-time enhancement travel in reagent data so pouring keeps them.
 */
/datum/reagent/medicine/herbal/preparation
	name = "prepared herbal decoction or wound paste"
	/// Batch strength from how the herbs were prepared.
	var/herbal_strength = 1
	/// Mortar enhancement multiplier; 1 when plain.
	var/herbal_boost = 1
	/// Whether any part of this batch was ever enhanced. Mixing never clears it.
	var/herbal_enhanced = FALSE

// Missing strength data means this type's default strength; missing boost data means a plain batch.
/datum/reagent/medicine/herbal/preparation/on_new(list/incoming_data)
	. = ..()
	herbal_strength = CLAMP(incoming_data?["herbal_strength"] || initial(herbal_strength), 0.5, 1)
	herbal_boost = CLAMP(incoming_data?["herbal_boost"] || 1, 1, HERBAL_ENHANCEMENT_BOOST)
	herbal_enhanced = !!incoming_data?["herbal_enhanced"]
	write_herbal_data()

/datum/reagent/medicine/herbal/preparation/on_merge(list/incoming_data, other_volume)
	var/merged_strength = min(herbal_strength, CLAMP(incoming_data?["herbal_strength"] || initial(herbal_strength), 0.5, 1))
	var/merged_boost = min(herbal_boost, CLAMP(incoming_data?["herbal_boost"] || 1, 1, HERBAL_ENHANCEMENT_BOOST))
	var/merged_enhanced = herbal_enhanced || incoming_data?["herbal_enhanced"]
	. = ..()
	herbal_strength = merged_strength
	herbal_boost = merged_boost
	herbal_enhanced = !!merged_enhanced
	write_herbal_data()

/datum/reagent/medicine/herbal/preparation/proc/write_herbal_data()
	LAZYSET(data, "herbal_strength", herbal_strength)
	LAZYSET(data, "herbal_boost", herbal_boost)
	LAZYSET(data, "herbal_enhanced", herbal_enhanced)

/// Multiplier for every medicinal effect of this batch.
/datum/reagent/medicine/herbal/preparation/proc/get_herbal_potency()
	return herbal_strength * herbal_boost

/// Applies the one-time mortar enhancement in place.
/datum/reagent/medicine/herbal/preparation/proc/enhance()
	if(herbal_enhanced)
		return FALSE
	herbal_boost = HERBAL_ENHANCEMENT_BOOST
	herbal_enhanced = TRUE
	write_herbal_data()
	return TRUE

/datum/reagent/medicine/herbal/wound_paste
	parent_type = /datum/reagent/medicine/herbal/preparation
	name = "herbal wound paste"
	description = "A paste for soaked dressings. It treats wounds on the bandaged limb, not internal ailments."
	metabolization_rate = 0.2
	var/wound_healing = 1
	var/burn_healing = 1
	var/pain_relief = 0
	/// Whether this paste assists natural clotting on the bandaged limb.
	var/natural_clotting = FALSE

/datum/reagent/medicine/herbal/wound_paste/on_bodypart_absorb(obj/item/bodypart/bodypart, mob/living/carbon/patient, amount_to_transfer)
	var/dose = amount_to_transfer * get_herbal_potency()
	if(natural_clotting)
		assist_natural_clotting(list(bodypart), dose)
	var/remaining_healing = dose
	var/treated_wound = FALSE
	for(var/datum/injury/injury as anything in bodypart.injuries)
		if(injury.damage_type == WOUND_DIVINE || injury.damage <= 0)
			continue
		treated_wound = TRUE
		var/healing_multiplier = injury.damage_type == WOUND_BURN ? burn_healing : wound_healing
		if(healing_multiplier > 0 && remaining_healing > 0)
			var/healing = min(injury.damage, remaining_healing * healing_multiplier)
			injury.heal_damage(healing)
			remaining_healing -= healing / healing_multiplier
	if(treated_wound && pain_relief)
		bodypart.add_pain(-dose * pain_relief)

/datum/reagent/medicine/herbal/wound_paste/calendula
	name = "Calendula Wound Paste"
	color = "#ff8c00"
	wound_healing = 2
	burn_healing = 3

/datum/reagent/medicine/herbal/wound_paste/mending
	name = "Calendula-Symphitum Wound Paste"
	color = "#a4a653"
	wound_healing = 3
	burn_healing = 1

/datum/reagent/medicine/herbal/wound_paste/cooling
	name = "Mentha-Symphitum Wound Paste"
	color = "#90ee90"
	pain_relief = 1

/datum/reagent/medicine/herbal/wound_paste/anodyne
	name = "Atropa Wound Paste"
	color = "#75606f"
	pain_relief = 2

/datum/reagent/medicine/herbal/wound_paste/matricaria
	name = "Matricaria Wound Paste"
	color = "#eedb93"
	wound_healing = 2
	burn_healing = 2

/datum/reagent/medicine/herbal/wound_paste/euphrasia
	name = "Euphrasia Wound Paste"
	color = "#b9c9a3"
	wound_healing = 1.5
	burn_healing = 0.5

/datum/reagent/medicine/herbal/wound_paste/calendula_matricaria
	name = "Calendula-Matricaria Wound Paste"
	color = "#f4b44a"
	wound_healing = 3
	burn_healing = 3

/datum/reagent/medicine/herbal/wound_paste/rosa_valeriana
	name = "Rosa-Valeriana Wound Paste"
	description = "A red paste for soaked dressings. It gently heals and helps ordinary bleeding on the bandaged limb clot naturally. Heavy bleeding still needs stitching or other physical treatment."
	color = "#a64b59"
	wound_healing = 0.5
	burn_healing = 0.5
	natural_clotting = TRUE

/**
 * Helps ordinary bleeding on these bodyparts clot naturally, within a budget scaled by dose.
 * Old wounds only clot toward their own natural floor, and only if they already clot on their own.
 * Injuries only lose bleeding time; injuries above their bleed threshold keep bleeding until treated.
 * Nothing is closed, sutured, or healed here.
 */
/datum/reagent/medicine/herbal/proc/assist_natural_clotting(list/bodyparts, dose)
	var/rate_budget = HERBAL_CLOTTING_RATE * dose
	var/timer_budget = HERBAL_CLOTTING_TIMER * dose
	for(var/obj/item/bodypart/bodypart as anything in bodyparts)
		if(QDELETED(bodypart) || !bodypart.is_organic_limb())
			continue
		for(var/datum/wound/wound as anything in bodypart.wounds)
			if(rate_budget <= 0)
				break
			if(istype(wound, /datum/wound/artery) || isnull(wound.clotting_threshold) || wound.clotting_rate <= 0)
				continue
			var/clotted = min(rate_budget, wound.bleed_rate - wound.clotting_threshold)
			if(clotted <= 0)
				continue
			wound.bleed_rate -= clotted
			rate_budget -= clotted
		for(var/datum/injury/injury as anything in bodypart.injuries)
			if(timer_budget <= 0)
				break
			if(injury.damage_type == WOUND_DIVINE || injury.required_status != BODYPART_ORGANIC || injury.is_surgical() || (injury.injury_flags & INJURY_RETRACTED))
				continue
			// Not is_bleeding(): the dressing carrying this treatment would suppress it.
			if(injury.current_stage > injury.max_bleeding_stage || injury.bleed_rate <= 0)
				continue
			var/clotted = min(timer_budget, injury.bleed_timer)
			if(clotted <= 0)
				continue
			injury.bleed_timer -= clotted
			timer_budget -= clotted

/datum/reagent/medicine/herbal/anodyne/atropa
	parent_type = /datum/reagent/medicine/herbal/decoction
	name = "Atropa Anodyne"
	description = "A numbing nightshade preparation for pain and irritated eyes."
	color = "#75606f"
	metabolization_rate = 0.3
	overdose_threshold = 20
	herbal_effects = list(CE_PAINKILLER = 8)

/datum/reagent/medicine/herbal/anodyne/atropa/on_mob_life(mob/living/carbon/patient, efficiency)
	if(volume > 0.99)
		patient.adjustOrganLoss(ORGAN_SLOT_EYES, -0.1 * REM * get_herbal_potency() * efficiency)
	return ..()

/datum/reagent/poison/herbal/paris_poison
	name = "Paris Poison"
	description = "A deadly crow's-eye poison that causes nausea, confusion, and paralysis."
	color = "#384b2a"
	metabolization_rate = 0.7
	overdose_threshold = 10

/datum/reagent/poison/herbal/paris_poison/on_mob_life(mob/living/carbon/patient, efficiency)
	patient.adjustToxLoss(1.5 * efficiency)
	patient.add_nausea(1)
	patient.set_confusion_if_lower(2 SECONDS * efficiency)
	if(prob(10 * efficiency))
		patient.Unconscious(5)
	return ..()

/datum/reagent/medicine/herbal/compound
	parent_type = /datum/reagent/medicine/herbal/decoction

/datum/reagent/medicine/herbal/compound/purifying
	name = "Artemisia-Taraxacum Purifying Decoction"
	description = "A bitter compound that eases toxins and purges small amounts of harmful reagents."
	color = "#b7a85f"
	toxin_healing = 1.5

/datum/reagent/medicine/herbal/compound/purifying/on_mob_life(mob/living/carbon/patient, efficiency)
	if(volume > 0.99)
		for(var/datum/reagent/other as anything in patient.reagents.reagent_list.Copy())
			if(istype(other, /datum/reagent/poison) || istype(other, /datum/reagent/toxin))
				patient.reagents.remove_reagent(other.type, min(0.5 * get_herbal_potency() * efficiency, other.volume))
	return ..()

/datum/reagent/medicine/herbal/compound/restorative
	name = "Mentha-Hypericum Restorative Decoction"
	description = "A bright herbal compound that steadies the body and lifts the mood."
	color = "#96b878"
	brute_healing = 0.5
	burn_healing = 0.5

/datum/reagent/medicine/herbal/compound/restorative/on_mob_metabolize(mob/living/patient)
	. = ..()
	patient.add_stress(/datum/stress_event/herbal_wellness)

/datum/reagent/medicine/herbal/compound/bloodroot
	name = "Rosa-Valeriana Bloodroot Decoction"
	description = "A red herbal compound that restores blood and helps ordinary bleeding clot naturally. It cannot close torn arteries or heavy bleeding; those still need stitching or other physical treatment."
	color = "#a64b59"
	brute_healing = 0.5

/datum/reagent/medicine/herbal/compound/bloodroot/on_mob_life(mob/living/carbon/patient, efficiency)
	if(volume > 0.99)
		var/potency = get_herbal_potency() * efficiency
		patient.adjust_bloodvolume(5 * potency, BLOOD_VOLUME_NORMAL)
		assist_natural_clotting(patient.bodyparts, potency)
	return ..()

/datum/reagent/medicine/herbal/compound/mending
	name = "Calendula-Matricaria Mending Decoction"
	description = "A golden healing blend for bruises and burns. It does not ease toxin damage."
	color = "#f4b44a"
	brute_healing = 1.5
	burn_healing = 1.5

/datum/herbal_mortar_recipe/return_recipe_data()
	var/datum/reagent/product = result_reagent
	var/instructions = requires_dried ? "All herbs must be fully dried." : "Fresh or dried herbs may be used; this preparation has a fixed concentration."
	instructions += " Put exactly these herbs and water into the mortar, then use a pestle. No other ingredients may be present.<br>Yields [result_amount] measures of [initial(product.name)]."
	if(ispath(result_reagent, /datum/reagent/medicine/herbal/wound_paste))
		var/datum/reagent/medicine/herbal/wound_paste/paste = result_reagent
		instructions += " Soak cloth in the paste and bandage the wounded limb.<br>Per measure: up to [initial(paste.wound_healing)] wound damage or [initial(paste.burn_healing)] burn damage healed across the limb's injuries; [initial(paste.pain_relief)] pain relief on a wounded limb. No internal healing."
		if(initial(paste.natural_clotting))
			instructions += " It also helps ordinary bleeding on that limb clot naturally. It cannot close torn arteries, surgical openings, or heavy bleeding; those still need stitching or other physical treatment. It restores no blood."
	else
		instructions += " This is a poisonous precursor for Blush, Grave Dream, Nightshade Mercy, and Atropa Death Draught. It is not Atropa Anodyne and must not be used as medicine."
	return list(
		"type" = "container_craft",
		"name" = name,
		"category" = category,
		"craft_verb" = "grinding ",
		"crafting_time" = preparation_time / (1 SECONDS),
		"requirements" = items_list(herbs),
		"reagents" = reagents_list(list(/datum/reagent/water = water_amount)),
		"container_name" = "mortar and pestle",
		"extra_html" = instructions,
	)

// Only the repository's two explicitly beneficial oils receive an inhaled delivery form.
/obj/item/candle/herbal
	name = "aromatic candle"
	desc = "A candle infused with a mild, beneficial herbal oil. Its effect remains close to the flame."
	var/aroma_reagent
	var/aroma_pollutant
	var/next_aroma_release

/obj/item/candle/herbal/process()
	. = ..()
	if(QDELETED(src) || !lit || !aroma_reagent || world.time < next_aroma_release)
		return
	next_aroma_release = world.time + HERBAL_CANDLE_INTERVAL
	var/turf/candle_turf = get_turf(src)
	if(aroma_pollutant)
		candle_turf?.pollute_turf(aroma_pollutant, 3)
	for(var/mob/living/carbon/target in view(1, src))
		if(!target.reagents || target.reagents.get_reagent_amount(aroma_reagent) >= 1)
			continue
		target.reagents.add_reagent(aroma_reagent, 0.2, list("quality" = 2))

/obj/item/candle/herbal/mentha
	name = "mentha aromatic candle"
	desc = "A candle infused with mentha cooling oil. Its close fragrance gently eases strain and pain."
	color = "#90ee90"
	light_color = "#b9f6ca"
	aroma_reagent = /datum/reagent/medicine/herbal/mentha_oil
	aroma_pollutant = /datum/pollutant/fragrance/mint

/obj/item/candle/herbal/rosa
	name = "rosa aromatic candle"
	desc = "A candle infused with rosa perfume oil. Its close fragrance gently lifts the spirits."
	color = "#ff9ec4"
	light_color = "#ffb6c9"
	aroma_reagent = /datum/reagent/consumable/herbal/rosa_oil
	aroma_pollutant = /datum/pollutant/fragrance/rose

/datum/repeatable_crafting_recipe/alchemy/herbal_candle
	abstract_type = /datum/repeatable_crafting_recipe/alchemy/herbal_candle
	category = "Alchemy"
	skillcraft = /datum/attribute/skill/craft/alchemy
	allow_inverse_start = TRUE
	subtypes_allowed = TRUE
	starting_atom = /obj/item/candle
	attacked_atom = /obj/item/reagent_containers/glass
	requirements = list(
		/obj/item/candle = 1,
	)
	craft_time = 5 SECONDS
	craftdiff = 1

/datum/repeatable_crafting_recipe/alchemy/herbal_candle/check_start(obj/item/attacked_item, obj/item/attacking_item, mob/user)
	var/obj/item/candle/used_candle
	if(istype(attacked_item, /obj/item/candle))
		used_candle = attacked_item
	else if(istype(attacking_item, /obj/item/candle))
		used_candle = attacking_item
	if(!used_candle || used_candle.infinite || used_candle.lit || istype(used_candle, /obj/item/candle/herbal))
		return FALSE
	return ..()

/datum/repeatable_crafting_recipe/alchemy/herbal_candle/mentha
	name = "mentha aromatic candle"
	output = /obj/item/candle/herbal/mentha
	reagent_requirements = list(
		/datum/reagent/medicine/herbal/mentha_oil = 5,
	)

/datum/repeatable_crafting_recipe/alchemy/herbal_candle/rosa
	name = "rosa aromatic candle"
	output = /obj/item/candle/herbal/rosa
	reagent_requirements = list(
		/datum/reagent/consumable/herbal/rosa_oil = 5,
	)

/datum/reagent/herbal_infusion
	name = "crude aromatic infusion"
	description = "A crude herbal infusion in spirits for distilling aromatic oil. It is not a finished remedy."
	reagent_state = LIQUID
	boiling_point = T0C + 100

/datum/reagent/herbal_infusion/rosa
	name = "Crude Rosa Infusion"
	color = "#d991aa"
	taste_description = "rose petals"

/datum/reagent/herbal_infusion/mentha
	name = "Crude Mentha Infusion"
	color = "#82ad7e"
	taste_description = "mint leaves"

/datum/reagent/herbal_infusion/lavender
	name = "Crude Lavender Infusion"
	color = "#9d86c4"
	taste_description = "lavender"

/datum/reagent/herbal_infusion/salvia
	name = "Crude Salvia Infusion"
	color = "#8a9a78"
	taste_description = "sage"

/// Finished distilled oils used only to enhance prepared remedies in a mortar.
/datum/reagent/herbal_enhancer_oil
	name = "herbal enhancer oil"
	description = "A finished aromatic oil for strengthening a prepared herbal remedy in a mortar. It has no medicinal effect by itself."
	reagent_state = LIQUID
	taste_description = "bitter perfume"

/datum/reagent/herbal_enhancer_oil/lavender
	name = "Lavender Oil"
	color = "#b69ce0"
	taste_description = "bitter lavender"

/datum/reagent/herbal_enhancer_oil/salvia
	name = "Salvia Oil"
	color = "#a7b88e"
	taste_description = "bitter sage"

/datum/container_craft/cooking/herbal_oil/after_craft(atom/created_output, obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents, list/removing_items)
	. = ..()
	var/datum/reagent/infusion = crafter.reagents.get_reagent(created_reagent)
	if(!infusion)
		return
	// Distillation carries reagent data into a different product.
	infusion.data -= "custom_name"
	infusion.data -= "custom_tastes"
	infusion.data -= "metabolization_mult"
	infusion.metabolization_rate = initial(infusion.metabolization_rate)

/datum/container_craft/cooking/herbal_oil/extra_html()
	. = ..()
	. += "Heat the pot on a lit fire to at least [required_chem_temp - T0C]&deg;C. Transfer the infusion to an alembic to distill the finished oil. Fresh or dried herbs may be used; drying improves brewing quality, not oil yield."

/datum/distillation_recipe/herbal_oil
	abstract_type = /datum/distillation_recipe/herbal_oil
	required_temp = T0C + 100
	distill_sound = "bubbles"
	/// Handbook note on what the finished oil is for.
	var/oil_use = "Finished oil can be used in aromatic candles; it has no further herbal refinement recipe."

/datum/distillation_recipe/herbal_oil/rosa
	name = "Distill Rosa Perfume Oil"
	id = "herbal_rosa_oil"
	distilled_reagent = /datum/reagent/herbal_infusion/rosa
	results = list(/datum/reagent/consumable/herbal/rosa_oil = 1 / 3)
	distill_message = "Fragrant rose oil collects from the steaming infusion."

/datum/distillation_recipe/herbal_oil/mentha
	name = "Distill Mentha Cooling Oil"
	id = "herbal_mentha_oil"
	distilled_reagent = /datum/reagent/herbal_infusion/mentha
	results = list(/datum/reagent/medicine/herbal/mentha_oil = 1 / 3)
	distill_message = "Cool mint-scented oil collects from the steaming infusion."

/datum/distillation_recipe/herbal_oil/lavender
	name = "Distill Lavender Oil"
	id = "herbal_lavender_oil"
	distilled_reagent = /datum/reagent/herbal_infusion/lavender
	results = list(/datum/reagent/herbal_enhancer_oil/lavender = 1 / 3)
	distill_message = "Calming lavender oil collects from the steaming infusion."
	oil_use = "Finished oil is an enhancer: 5 measures strengthen one prepared herbal remedy once in a mortar. It is not medicine by itself and is not used in candles."

/datum/distillation_recipe/herbal_oil/salvia
	name = "Distill Salvia Oil"
	id = "herbal_salvia_oil"
	distilled_reagent = /datum/reagent/herbal_infusion/salvia
	results = list(/datum/reagent/herbal_enhancer_oil/salvia = 1 / 3)
	distill_message = "Sharp sage oil collects from the steaming infusion."
	oil_use = "Finished oil is an enhancer: 5 measures strengthen one prepared herbal remedy once in a mortar. It is not medicine by itself and is not used in candles."

/datum/distillation_recipe/herbal_oil/return_recipe_data()
	var/datum/reagent/input_type = distilled_reagent
	var/output_text = ""
	for(var/datum/reagent/result_type as anything in results)
		output_text += "[round(results[result_type] * 30, 0.01)] measures of [initial(result_type.name)]<br>"
	return list(
		"type" = "book_entry",
		"name" = name,
		"category" = "Herbal Distillation",
		"html" = "<h2>[name]</h2><p>Input: 30 measures of [initial(input_type.name)]. Separation temperature: [initial(input_type.boiling_point) - T0C]&deg;C.</p><p>Output:<br>[output_text]</p><p>Insert the infusion vessel into the alembic and load its contents. Replace it with an empty receiving vessel, then start heating. The alembic chooses the fraction automatically. Keep different infusions in separate batches for a pure oil.</p><p>Yield scales with the infusion actually distilled. Extra water does not produce extra oil. [oil_use]</p>",
	)

/datum/reagent/medicine/herbal/decoction
	parent_type = /datum/reagent/medicine/herbal/preparation
	name = "herbal decoction"
	description = "A slow oral herbal remedy. Fresh herbs give half-strength medicine."
	herbal_strength = 0.5
	var/toxin_healing = 0
	var/brute_healing = 0
	var/burn_healing = 0
	/// Persistent effects refreshed from the current batch potency, then removed when metabolism ends.
	var/list/herbal_effects

/datum/reagent/medicine/herbal/decoction/on_mob_metabolize(mob/living/patient)
	. = ..()
	patient.add_stress(/datum/stress_event/herbal_calm)
	update_herbal_effects(patient)

/datum/reagent/medicine/herbal/decoction/on_mob_end_metabolize(mob/living/patient)
	for(var/effect in herbal_effects)
		patient.remove_chem_effect(effect, "[type]")
	return ..()

/datum/reagent/medicine/herbal/decoction/proc/update_herbal_effects(mob/living/patient)
	for(var/effect in herbal_effects)
		if(volume >= 1)
			patient.add_chem_effect(effect, herbal_effects[effect] * get_herbal_potency(), "[type]")
		else
			patient.remove_chem_effect(effect, "[type]")

/datum/reagent/medicine/herbal/decoction/on_mob_life(mob/living/carbon/patient, efficiency)
	update_herbal_effects(patient)
	if(volume >= 1)
		var/potency = get_herbal_potency() * efficiency
		if(toxin_healing)
			patient.adjustToxLoss(-toxin_healing * potency)
		if(brute_healing)
			patient.adjustBruteLoss(-brute_healing * REM * potency, FALSE)
		if(burn_healing)
			patient.adjustFireLoss(-burn_healing * REM * potency, FALSE)
	return ..()

/datum/reagent/medicine/herbal/decoction/on_bodypart_absorb(obj/item/bodypart/bodypart, mob/living/carbon/patient, amount_to_transfer)
	return

/datum/reagent/medicine/herbal/decoction/artemisia
	name = "Artemisia Bitter Decoction"
	description = "A bitter oral remedy that eases toxin damage. It does not purge poisons still in the blood."
	color = "#a0aa80"
	toxin_healing = 1

/datum/reagent/medicine/herbal/decoction/benedictus
	name = "Benedictus Cleansing Decoction"
	description = "A thistle decoction that eases toxin damage."
	color = "#ad925d"
	toxin_healing = 0.75

/datum/reagent/medicine/herbal/decoction/matricaria
	name = "Matricaria Restorative Decoction"
	description = "A chamomile decoction that heals bruises and burns and eases toxin damage."
	color = "#eedb93"
	toxin_healing = 0.5
	brute_healing = 0.75
	burn_healing = 0.75

/datum/reagent/medicine/herbal/decoction/euphorbia
	name = "Euphorbia Restorative Decoction"
	description = "An oral herbal remedy for bruises and burns."
	color = "#83a865"
	brute_healing = 1
	burn_healing = 1

/datum/reagent/medicine/herbal/decoction/calendula
	name = "Calendula Decoction"
	description = "A marigold decoction for bruises and burns."
	color = "#ff8c00"
	brute_healing = 1
	burn_healing = 1

/datum/container_craft/cooking/herbal_decoction
	abstract_type = /datum/container_craft/cooking/herbal_decoction
	category = "Herbal Decoctions"
	used_skill = /datum/attribute/skill/craft/alchemy
	reagent_requirements = list(/datum/reagent/water = 25)
	water_conversion = 0.4
	crafting_time = 10 SECONDS
	required_chem_temp = T0C + 80
	craft_verb = "brewing "
	complete_message = "The herbal decoction is ready."

/datum/container_craft/cooking/herbal_decoction/reagent_data(calculated_quality, list/removing_items)
	. = ..()
	var/strength = 1
	var/herb_count = 0
	for(var/obj/item/alch/herb/herb in removing_items)
		herb_count++
		if(!herb.dried)
			strength = 0.5
	if(!herb_count)
		strength = 0.5
	.["herbal_strength"] = strength

/datum/container_craft/cooking/herbal_decoction/extra_html()
	. = ..()
	var/datum/reagent/medicine/herbal/decoction/remedy_type = created_reagent
	. += "Heat on a lit fire to [required_chem_temp - T0C]&deg;C. Fresh herbs or mixed fresh/dried batches give half strength; every herb must be dried for full strength. Mixing strengths keeps the weaker strength.<br>[initial(remedy_type.description)] Drink the decoction; it does not treat wounds through a bandage."

/datum/container_craft/cooking/herbal_tea/extra_html()
	. = ..()
	. += "Heat the pot on a lit fire to at least [required_chem_temp - T0C]&deg;C. This is a traditional alchemical formula with fixed effects; the half-strength rule for fresh herbal decoctions does not apply."
	if(reagent_requirements[/datum/reagent/poison/herbal/weak_atropa])
		. += " Prepare Crude Atropa Extract in a mortar first; Atropa Anodyne cannot replace it."

/datum/book_entry/apothecary_methods
	name = "Preparing Herbal Medicines"
	category = "Apothecary Methods"

/datum/book_entry/apothecary_methods/inner_book_html(mob/user)
	return {"
		<h2>From herb to remedy</h2>
		<p>Gather herbs from their bushes or cultivate them. Examine an herb to check whether it is fresh or dried; trained alchemists can also recognize its preparation profile.</p>
		<h3>Drying</h3>
		<p>A drying rack holds twelve herb bundles. In steady conditions, drying takes about ten minutes outdoors, twelve beside an indoor fire, or twenty in still indoor air. Rain pauses drying on a rack under open sky; a roof keeps it drying. Examine the rack to see how long its herbs still need. A herb taken off early keeps its progress. Take finished herbs from the rack by hand.</p>
		<h3>Decoctions: drinkable medicine</h3>
		<p>Use the herbs listed in a Herbal Decoctions recipe with 25 measures of water in a cooking pot. Place the pot on a lit fire and heat it to 80&deg;C. Close its storage to begin brewing. Each batch yields 10 measures. All herbs must be dried for full strength; any fresh herb gives half strength. Mixing finished batches preserves the weaker strength, including after pouring them between vessels.</p>
		<p>Drink decoctions for their medicinal effects and mild calming benefit. They do not deliver their effects through soaked bandages. Euphrasia Decoction is taken orally despite the old name 'eye wash'.</p>
		<h3>Wound pastes: soaked dressings</h3>
		<p>Put the exact dried herbs and 10 measures of water from a Herbal Poultices recipe into a mortar, with nothing else. Work them with a pestle to make 10 measures of paste. Soak cloth in it and bandage the injured limb. Paste treats that limb's injuries as it is consumed; drinking it does not heal internal ailments. Ordinary herb grinding does not make finished medicine.</p>
		<p>Measure liquids with the pour intent. Each click on a mortar pours one selected measure from the held vessel; set that amount on the vessel in your hand. A bucket pours 10 measures, so one click from a full bucket adds exactly the water a mortar mixture needs.</p>
		<h3>Enhancing a finished remedy</h3>
		<p>Put exactly 10 measures of a single finished decoction or wound paste into a mortar with one enhancer: 5 measures of finished Lavender Oil, 5 measures of finished Salvia Oil, or one fully dried urtica bundle. Nothing else may be present, not even water. Work it with a pestle. The enhancer is consumed and the same 10 measures become [HERBAL_ENHANCEMENT_PERCENT]% more potent: a fresh decoction goes from half to 0.625 strength, a dried one from full to 1.25, and a paste heals, relieves pain, and clots 25% more per measure. Volume, quality, and overdose limits do not change.</p>
		<p>Each batch can be enhanced only once. Mixing an enhanced batch with an unenhanced one keeps the lower strength and loses the bonus, and the mixture still counts as enhanced, so it cannot be enhanced again. Traditional alchemical remedies, poisons, crude extracts, and crude infusions cannot be enhanced.</p>
		<h3>Natural clotting</h3>
			<p>Rosa-Valeriana Bloodroot Decoction helps ordinary bleeding across the body clot naturally while it also restores blood. Rosa-Valeriana Wound Paste helps only the bandaged limb and restores no blood. Both work only on bleeding that would clot by itself. They cannot close torn arteries, surgical openings, divine wounds, or prosthetic limbs. Deep injuries still bleed until they are stitched, bandaged, or otherwise physically treated.</p>
		<h3>Crude Atropa Extract and refinements</h3>
		<p>One fresh or dried atropa bundle and exactly 10 measures of water in a mortar make 10 measures of Crude Atropa Extract. This poisonous precursor is distinct from the drinkable Atropa Anodyne brewed in a pot. Blush, Grave Dream, Nightshade Mercy, and Atropa Death Draught require the crude extract. Use the separate recipes for their other ingredients, skill requirements, and yields.</p>
		<h3>Aromatic oils</h3>
		<p>Brew a crude infusion from its recipe in a pot at 80&deg;C, then transfer it to an alembic. Distilling 30 measures of infusion yields 10 measures of finished oil. Use a separate receiving vessel. Infusion is not finished oil.</p>
		<p>Rosa and mentha oils may be used directly or crafted into aromatic candles. Lavender and salvia oils, each brewed from 3 of their herbs and 30 measures of spirits, are enhancers for finished remedies. They are not medicine by themselves and are not used in candles.</p>
		<h3>Traditional alchemy</h3>
		<p>Recipes under Traditional Alchemical Remedies retain their individual amounts and effects. Read their formula rather than applying the decoction rules. These include specialized tonics, poisons, and the older alcoholic Calendula Salve. They cannot be enhanced in a mortar.</p>
	"}

#undef HERBAL_CANDLE_INTERVAL
#undef HERBAL_CLOTTING_RATE
#undef HERBAL_CLOTTING_TIMER
#undef HERBAL_ENHANCEMENT_BOOST
#undef HERBAL_ENHANCEMENT_PERCENT
