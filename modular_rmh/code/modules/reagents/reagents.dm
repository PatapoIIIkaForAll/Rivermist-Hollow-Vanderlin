
#define CUM_DATA_PARENT_REF "oviposition_parent_ref"
#define CUM_DATA_PARENT_NAME "oviposition_parent_name"
#define CUM_DATA_PARENT_FEATURES "oviposition_parent_features"
#define CUM_DATA_PARENT_HATCH_RESULT_TYPE "oviposition_parent_hatch_result_type"
#define CUM_DATA_MIXED_PARENTS "oviposition_mixed_parents"

/datum/reagent/consumable/cum
	name = "Semen"
	description = "A pearly white liquid produced by testicles."
	color = "#c6c6c6"
	taste_description = "salty slime"
	glass_icon_state = "glass_white"
	glass_name = "glass of semen"
	glass_desc = ""
	nutriment_factor = 5 * REAGENTS_METABOLISM
	hydration_factor = 2
	var/virile = TRUE
	var/triggers_embryo_pregnancy = FALSE
	var/vitilty_factor = 1
	evaporation_rate = 0.2

/datum/reagent/consumable/cum/proc/sync_parent_data(mob/living/parent)
	if(!parent)
		return FALSE
	if(!data)
		data = list()

	data[CUM_DATA_PARENT_REF] = WEAKREF(parent)
	data[CUM_DATA_PARENT_NAME] = parent.real_name

	var/list/parent_features = get_oviposition_parent_features(parent)
	if(LAZYLEN(parent_features))
		data[CUM_DATA_PARENT_FEATURES] = parent_features.Copy()
	else
		data -= CUM_DATA_PARENT_FEATURES

	var/hatch_result_type = get_oviposition_parent_hatch_result_type(parent)
	if(hatch_result_type)
		data[CUM_DATA_PARENT_HATCH_RESULT_TYPE] = hatch_result_type
	else
		data -= CUM_DATA_PARENT_HATCH_RESULT_TYPE

	data -= CUM_DATA_MIXED_PARENTS
	return TRUE

/datum/reagent/consumable/cum/proc/get_parent_from_transfer()
	var/datum/weakref/father_ref = data?[CUM_DATA_PARENT_REF]
	var/mob/living/father = father_ref?.resolve()
	if(isliving(father))
		return father

	if(istype(holder?.my_atom, /obj/item/organ/genitals/filling_organ/testicles))
		var/obj/item/organ/genitals/filling_organ/testicles/testes = holder.my_atom
		if(isliving(testes.owner))
			return testes.owner
	return null

/datum/reagent/consumable/cum/proc/get_parent_name_from_transfer(mob/living/father = null)
	return father?.real_name || data?[CUM_DATA_PARENT_NAME]

/datum/reagent/consumable/cum/proc/get_parent_features_from_transfer(mob/living/father = null)
	if(father)
		return get_oviposition_parent_features(father)
	var/list/father_features = data?[CUM_DATA_PARENT_FEATURES]
	return father_features?.Copy()

/datum/reagent/consumable/cum/proc/get_parent_hatch_result_type_from_transfer(mob/living/father = null)
	if(father)
		return get_oviposition_parent_hatch_result_type(father)
	return data?[CUM_DATA_PARENT_HATCH_RESULT_TYPE]

/datum/reagent/consumable/cum/proc/reconcile_parent_data(current_parent_ref, current_parent_name, list/current_parent_features, current_hatch_result_type, list/incoming_data)
	if(!incoming_data)
		return
	if(!data)
		data = list()

	var/incoming_parent_ref = incoming_data[CUM_DATA_PARENT_REF]
	var/incoming_parent_name = incoming_data[CUM_DATA_PARENT_NAME]
	var/list/incoming_parent_features = incoming_data[CUM_DATA_PARENT_FEATURES]
	var/incoming_hatch_result_type = incoming_data[CUM_DATA_PARENT_HATCH_RESULT_TYPE]

	var/current_has_parent = !isnull(current_parent_ref) || !isnull(current_parent_name) || LAZYLEN(current_parent_features) || !isnull(current_hatch_result_type)
	var/incoming_has_parent = !isnull(incoming_parent_ref) || !isnull(incoming_parent_name) || LAZYLEN(incoming_parent_features) || !isnull(incoming_hatch_result_type)
	if(!current_has_parent || !incoming_has_parent)
		return

	if(current_parent_ref && incoming_parent_ref && current_parent_ref == incoming_parent_ref)
		data -= CUM_DATA_MIXED_PARENTS
		return

	if(current_parent_name == incoming_parent_name && current_hatch_result_type == incoming_hatch_result_type)
		data -= CUM_DATA_MIXED_PARENTS
		return

	data -= CUM_DATA_PARENT_REF
	data -= CUM_DATA_PARENT_NAME
	data -= CUM_DATA_PARENT_FEATURES
	if(current_hatch_result_type && current_hatch_result_type == incoming_hatch_result_type)
		data[CUM_DATA_PARENT_HATCH_RESULT_TYPE] = current_hatch_result_type
	else
		data -= CUM_DATA_PARENT_HATCH_RESULT_TYPE
	data[CUM_DATA_MIXED_PARENTS] = TRUE

/datum/reagent/consumable/cum/on_merge(list/incoming_data, other_volume)
	var/current_parent_ref = data?[CUM_DATA_PARENT_REF]
	var/current_parent_name = data?[CUM_DATA_PARENT_NAME]
	var/list/current_parent_features = data?[CUM_DATA_PARENT_FEATURES]
	var/current_hatch_result_type = data?[CUM_DATA_PARENT_HATCH_RESULT_TYPE]

	. = ..()
	reconcile_parent_data(current_parent_ref, current_parent_name, current_parent_features, current_hatch_result_type, incoming_data)

/datum/reagent/consumable/cum/proc/get_impregnation_actor_from_transfer(mob/living/father = null, mob/transfered_by = null)
	if(isliving(transfered_by))
		return transfered_by
	if(isliving(holder?.my_atom))
		return holder.my_atom
	if(istype(holder?.my_atom, /obj/item/organ/genitals/filling_organ/testicles))
		var/obj/item/organ/genitals/filling_organ/testicles/testes = holder.my_atom
		if(isliving(testes.owner))
			return testes.owner
	return father

/datum/reagent/consumable/cum/on_transfer(atom/A, method, trans_volume, mob/transfered_by = null)
	. = ..()
	if(istype(A, /obj/item/organ/genitals/filling_organ) && virile)
		var/obj/item/organ/genitals/filling_organ/forgan = A
		var/mob/living/father = get_parent_from_transfer()
		var/mob/living/impregnation_actor = get_impregnation_actor_from_transfer(father, transfered_by)
		if(!target_allows_mob_erp_action(impregnation_actor, forgan.owner, /datum/erp_preference/boolean/allow_mob_breeding))
			return
		var/allow_embryo_pregnancy = triggers_embryo_pregnancy || parent_triggers_oviposition_embryo_pregnancy(father)
		if(forgan.can_attempt_impregnation(allow_embryo_pregnancy))
			if(prob(20 * vitilty_factor))
				var/list/father_features = get_parent_features_from_transfer(father)
				var/father_name = get_parent_name_from_transfer(father)
				var/embryo_hatch_result_type = get_parent_hatch_result_type_from_transfer(father)
				forgan.be_impregnated(father, allow_embryo_pregnancy, embryo_hatch_result_type, father_features, father_name)

/datum/reagent/consumable/cum/on_mob_life(mob/living/carbon/M)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1,0, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NOHUNGER))
			H.adjust_hydration(5)
			H.adjust_nutrition(5)
		if(H.blood_volume < BLOOD_VOLUME_NORMAL)
			H.blood_volume = min(H.blood_volume+10, BLOOD_VOLUME_NORMAL)
	. = 1
	..()

/datum/reagent/consumable/cum/sterile
	virile = FALSE

/datum/reagent/consumable/femcum
	name = "Pussy juice"
	description = "A sticky, slimy, clear liquid, produced by female arousal."
	color = "#c6c6c6"
	taste_description = "tangy slime"
	glass_icon_state = "glass_clear"
	glass_name = "glass of femcum"
	glass_desc = ""
	nutriment_factor = 0.1 * REAGENTS_METABOLISM
	evaporation_rate = 0.2

#undef CUM_DATA_PARENT_REF
#undef CUM_DATA_PARENT_NAME
#undef CUM_DATA_PARENT_FEATURES
#undef CUM_DATA_PARENT_HATCH_RESULT_TYPE
#undef CUM_DATA_MIXED_PARENTS
