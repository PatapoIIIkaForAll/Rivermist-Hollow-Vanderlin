/obj/item/organ/genitals/penis
	name = "penis"
	icon_state = "penis"
	visible_organ = TRUE
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_PENIS

	var/sheath_type = SHEATH_TYPE_NONE
	var/erect_state = ERECT_STATE_NONE
	var/penis_type = PENIS_TYPE_PLAIN
	organ_size = DEFAULT_PENIS_SIZE
	var/functional = TRUE
	var/always_hard = FALSE
	var/strapon = FALSE
	var/ovi_egg_type = null
	var/egg_clutch_size = 0

/obj/item/organ/genitals/penis/Initialize()
	. = ..()

/obj/item/organ/genitals/penis/get_render_key_state()
	return "[organ_size]-[erect_state]-[sheath_type]"

/obj/item/organ/genitals/penis/Insert(mob/living/M, special, drop_if_replaced, new_zone = null)
	. = ..()
	if(!.)
		return FALSE
	RegisterSignal(M, COMSIG_SEX_AROUSAL_CHANGED, PROC_REF(on_arousal_changed), TRUE)
	RegisterSignal(M, COMSIG_SET_ERECT_STATE, PROC_REF(set_hard), TRUE)
	if(penis_type in list(PENIS_TYPE_KNOTTED, PENIS_TYPE_TAPERED_DOUBLE_KNOTTED, PENIS_TYPE_BARBED_KNOTTED))
		M.AddComponent(/datum/component/knotting)
	add_bodystorage(M, null, /datum/component/body_storage/penis)

/obj/item/organ/genitals/penis/Remove(mob/living/M, special, drop_if_replaced)
	. = ..()
	UnregisterSignal(M, COMSIG_SEX_AROUSAL_CHANGED)
	UnregisterSignal(M, COMSIG_SET_ERECT_STATE)
	if(penis_type in list(PENIS_TYPE_KNOTTED, PENIS_TYPE_TAPERED_DOUBLE_KNOTTED, PENIS_TYPE_BARBED_KNOTTED))
		qdel(M.GetComponent(/datum/component/knotting))
	var/datum/component/body_storage/penis/comp = GetComponent(/datum/component/body_storage/penis)
	comp?.RemoveComponent()
	qdel(comp)

/obj/item/organ/genitals/penis/get_availability(datum/species/owner_species, mob/living/C, datum/preferences/pref_load)
	if(issimple(C))
		return C.gender == MALE
	else
		if(pref_load)
			return pref_load.has_enabled_customizer_entry(/datum/customizer_entry/organ/genitals/penis)
		else
			return C.gender == MALE

/obj/item/organ/genitals/penis/proc/on_arousal_changed()
	if(!owner)
		return
	var/list/arousal_data = list()
	SEND_SIGNAL(owner, COMSIG_SEX_GET_AROUSAL, arousal_data)
	var/max_arousal = ACTIVE_EJAC_THRESHOLD || 120
	var/current_arousal = arousal_data["arousal"] || 0
	var/arousal_percent = min(100, (current_arousal / max_arousal) * 100)

	var/new_state = ERECT_STATE_NONE
	switch(arousal_percent)
		if(0 to 10)
			new_state = ERECT_STATE_NONE
		if(11 to 35)
			new_state = ERECT_STATE_PARTIAL
		if(36 to 100)
			new_state = ERECT_STATE_HARD
	update_erect_state(new_state)

/obj/item/organ/genitals/penis/proc/set_hard(datum/source, incoming)
	always_hard = incoming
	on_arousal_changed()

/obj/item/organ/genitals/penis/proc/update_erect_state(new_state = ERECT_STATE_NONE)
	if(!owner)
		return
	var/oldstate = erect_state
	if(owner.mind)
		var/datum/antagonist/werewolf/W = owner.mind.has_antag_datum(/datum/antagonist/werewolf/)
		if(W && W.transformed == TRUE)
			owner.regenerate_icons()
	if(!length(owner.sex_scene?.controllers))
		always_hard = FALSE
	if(always_hard)
		erect_state = ERECT_STATE_HARD
	else
		erect_state = new_state
	if(oldstate != erect_state && owner)
		if(iscarbon(owner))
			var/mob/living/carbon/carbon_owner = owner
			carbon_owner.update_body_parts(TRUE)


/obj/item/organ/genitals/penis/proc/create_fake_variant(mob/living/user)
	var/obj/item/penis_fake/fake = new()
	fake.copy_properties_from(src)
	fake.set_original_owner(user)
	return fake

/obj/item/penis_fake
	name = "penis"
	icon_state = "severedtail" //placeholder
	var/sheath_type = SHEATH_TYPE_NONE
	var/erect_state = ERECT_STATE_NONE
	var/penis_type = PENIS_TYPE_PLAIN
	var/penis_size = DEFAULT_PENIS_SIZE
	// Tracking vars
	var/original_owner_ckey = null
	var/original_owner_name = null
	var/insertion_timestamp = null
	w_class = WEIGHT_CLASS_SMALL

/obj/item/penis_fake/Initialize()
	. = ..()
	insertion_timestamp = world.time

/obj/item/penis_fake/proc/copy_properties_from(obj/item/organ/genitals/penis/source)
	if(!source)
		return
	sheath_type = source.sheath_type
	erect_state = source.erect_state
	penis_type = source.penis_type
	penis_size = source.organ_size
	penis_girth = source.get_insert_girth()
	body_storage_bulk = max(1, round(penis_girth / ORIFICE_BULK_PER_CM))
	name = "[source.name]"

/obj/item/penis_fake/proc/set_original_owner(mob/living/owner)
	if(owner?.ckey)
		original_owner_ckey = owner.ckey
		original_owner_name = owner.real_name || owner.name

/obj/item/penis_fake/proc/is_owned_by(mob/living/user)
	if(!user?.ckey)
		return FALSE
	return user.ckey == original_owner_ckey

/obj/item/penis_fake/can_random_body_storage_layer_swap()
	return FALSE


/obj/item/organ/genitals/penis/knotted
	name = "knotted penis"
	penis_type = PENIS_TYPE_KNOTTED
	sheath_type = SHEATH_TYPE_NORMAL

/obj/item/organ/genitals/penis/knotted/big
	organ_size = 3

/obj/item/organ/genitals/penis/equine
	name = "equine penis"
	penis_type = PENIS_TYPE_EQUINE
	sheath_type = SHEATH_TYPE_NORMAL

/obj/item/organ/genitals/penis/tapered_mammal
	name = "tapered penis"
	penis_type = PENIS_TYPE_TAPERED
	sheath_type = SHEATH_TYPE_NORMAL

/obj/item/organ/genitals/penis/tapered
	name = "tapered penis"
	penis_type = PENIS_TYPE_TAPERED
	sheath_type = SHEATH_TYPE_SLIT

/obj/item/organ/genitals/penis/tapered_double
	name = "hemi tapered penis"
	penis_type = PENIS_TYPE_TAPERED_DOUBLE
	sheath_type = SHEATH_TYPE_SLIT

/obj/item/organ/genitals/penis/tapered_double_knotted
	name = "hemi knotted tapered penis"
	penis_type = PENIS_TYPE_TAPERED_DOUBLE_KNOTTED
	sheath_type = SHEATH_TYPE_SLIT

/obj/item/organ/genitals/penis/barbed
	name = "barbed penis"
	penis_type = PENIS_TYPE_BARBED
	sheath_type = SHEATH_TYPE_NORMAL

/obj/item/organ/genitals/penis/barbed_knotted
	name = "barbed knotted penis"
	penis_type = PENIS_TYPE_BARBED_KNOTTED
	sheath_type = SHEATH_TYPE_NORMAL

/obj/item/organ/genitals/penis/tentacle
	name = "tentacle penis"
	penis_type = PENIS_TYPE_TENTACLE
	sheath_type = SHEATH_TYPE_NONE
