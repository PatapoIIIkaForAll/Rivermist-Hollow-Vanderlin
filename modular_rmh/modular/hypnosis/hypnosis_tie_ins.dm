// Other ways to hypnotize: the pendulum item and the vampire Presence coven.

/obj/item/hypnosis_pendulum
	name = "hypnotist's pendulum"
	desc = "A brass disc with a violet spiral, hung on a fine chain. Hold it to swing it before someone's eyes and put them in a trance; they must have Hypnosis enabled."
	icon = 'modular_rmh/icons/obj/hypnosis_pendulum.dmi'
	icon_state = "pendulum"
	w_class = WEIGHT_CLASS_TINY
	sellprice = 40
	/// The mob the spell was given to while held.
	var/datum/weakref/holder_ref

/obj/item/hypnosis_pendulum/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		grant_swing(user)
	else
		revoke_swing()

/obj/item/hypnosis_pendulum/dropped(mob/user, silent = FALSE)
	. = ..()
	revoke_swing()

/obj/item/hypnosis_pendulum/Destroy()
	revoke_swing()
	return ..()

/obj/item/hypnosis_pendulum/proc/grant_swing(mob/user)
	if(!isliving(user))
		return
	var/mob/living/holder = user
	if(holder_ref?.resolve() == holder)
		return
	revoke_swing()
	holder_ref = WEAKREF(holder)
	holder.add_spell(/datum/action/cooldown/spell/hypnosis/pendulum)

/obj/item/hypnosis_pendulum/proc/revoke_swing()
	var/mob/living/holder = holder_ref?.resolve()
	holder_ref = null
	if(QDELETED(holder))
		return
	for(var/obj/item/hypnosis_pendulum/other in holder.held_items)
		if(other != src)
			return
	holder.remove_spell(/datum/action/cooldown/spell/hypnosis/pendulum)

/datum/supply_pack/luxury/intimate/hypnosis_pendulum
	name = "Hypnotist's Pendulum"
	cost = 120
	contains = /obj/item/hypnosis_pendulum

/datum/coven/presence/post_gain()
	. = ..()
	owner?.add_spell(/datum/action/cooldown/spell/hypnosis/vampire)
