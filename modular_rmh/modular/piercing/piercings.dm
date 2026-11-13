/obj/item/piercings
	name = "piercings"
	desc = "piercings."
	icon = 'modular_rmh/icons/mob/sprite_accessory/piercings/objects.dmi'
	icon_state = "rings"
	obj_flags = CAN_BE_HIT
	blade_dulling = DULLING_CUT
	max_integrity = 20
	integrity_failure = 0.1
	var/datum/bodypart_feature/piercing/piercings_feature
	var/sprite_acc = /datum/sprite_accessory/piercing/rings
	dropshrink = 0.4

/obj/item/piercings/Destroy()
	var/mob/living/carbon/human/wearer = loc
	if(istype(wearer) && wearer.piercings_item == src)
		wearer.piercings_item = null
	if(piercings_feature?.piercings_item == src)
		piercings_feature.piercings_item = null
	piercings_feature = null
	return ..()

/obj/item/piercings/attack(mob/M, mob/user, def_zone)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.piercings_item)
			if(!get_location_accessible(H, BODY_ZONE_CHEST))
				return
			if(!piercings_feature)
				var/datum/bodypart_feature/piercing/piercings_new = new /datum/bodypart_feature/piercing()
				piercings_new.set_accessory_type(sprite_acc, color, null)
				piercings_feature = piercings_new
			user.visible_message(span_notice("[user] tries to put [src] on [H]..."))
			if(do_after(user, 50, target = H))
				var/obj/item/bodypart/chest = H.get_bodypart(BODY_ZONE_CHEST)
				if(!chest.add_bodypart_feature(piercings_feature))
					return
				piercings_feature.set_piercings_item(src, H)
				user.dropItemToGround(src)
				forceMove(H)

/obj/item/piercings/beads
	name = "bead piercings"
	desc = "Same as the ear ones, but for your nipples. These are in a shape of beads."
	icon_state = "beads"
	sprite_acc = /datum/sprite_accessory/piercing/beads

/obj/item/piercings/beads/gold
	name = "golden bead piercings"
	desc = "Same as the ear ones, but for your nipples. These are in a shape of beads, made of gold."
	icon_state = "beads-g"
	sprite_acc = /datum/sprite_accessory/piercing/beads/gold

/obj/item/piercings/beads/silver
	name = "silver bead piercings"
	desc = "Same as the ear ones, but for your nipples. These are in a shape of beads, made of silver."
	icon_state = "beads-s"
	sprite_acc = /datum/sprite_accessory/piercing/beads/silver

/obj/item/piercings/beads/emerald
	name = "emerald bead piercings"
	desc = "Same as the ear ones, but for your nipples. These are in a shape of beads, made of emerald."
	icon_state = "beads-e"
	sprite_acc = /datum/sprite_accessory/piercing/beads/emerald

/obj/item/piercings/beads/tag
	name = "nipple tag"
	desc = "Usually used by slavers and enthusiasts to brand someone without damaging the goods too much."
	icon_state = "beads-tag"
	sprite_acc = /datum/sprite_accessory/piercing/rings/tag

/obj/item/piercings/beads/tag/Initialize()
	. = ..()
	var/list/datum/inscription/initial_inscriptions = list(
		new /datum/inscription("Change me!", /datum/language/common)
	)
	AddComponent(/datum/component/inscription_holder, initial_inscriptions)

/obj/item/piercings/beads/tag/attack_self(mob/user, list/modifiers)
	var/datum/component/inscription_holder/holder = GetComponent(/datum/component/inscription_holder)
	if(!holder)
		return

	var/datum/inscription/inscription = holder.get_inscription(1)
	if(!inscription)
		return

	var/new_text = input(usr, inscription.get_text(), "What do you want to write here?") as message | null

	if(!new_text)
		return

	inscription.set_text(new_text, user.get_default_language())

/obj/item/piercings/rings
	name = "ring piercings"
	desc = "Same as the ear ones, but for your nipples. These are in a shape of a ring."
	icon_state = "rings"
	sprite_acc = /datum/sprite_accessory/piercing/rings

/obj/item/piercings/rings/gold
	name = "golden ring piercings"
	desc = "Same as the ear ones, but for your nipples. These are in a shape of a ring, made of gold."
	icon_state = "rings-g"
	sprite_acc = /datum/sprite_accessory/piercing/rings/gold

/obj/item/piercings/rings/silver
	name = "silver ring piercings"
	desc = "Same as the ear ones, but for your nipples. These are in a shape of a ring, made of silver."
	icon_state = "rings-s"
	sprite_acc = /datum/sprite_accessory/piercing/rings/silver

/obj/item/piercings/rings/emerald
	name = "emerald ring piercings"
	desc = "Same as the ear ones, but for your nipples. These are in a shape of a ring, made of emerald."
	icon_state = "rings-e"
	sprite_acc = /datum/sprite_accessory/piercing/rings/emerald
