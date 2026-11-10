/obj/structure/fake_machine/enterprise_ledger
	name = "enterprise ledger"
	desc = "A heavy ledger on a pedestal, kept for the running of a business."
	icon = 'icons/obj/questing.dmi'
	icon_state = "contractledger"
	density = TRUE
	max_integrity = 0
	obj_flags = CAN_BE_HIT | USES_TGUI
	var/enterprise_type
	var/datum/enterprise/enterprise

/obj/structure/fake_machine/enterprise_ledger/Initialize(mapload)
	. = ..()
	enterprise = SSenterprises.get_enterprise(enterprise_type)
	if(!enterprise)
		return
	enterprise.ledgers += src
	if(SSenterprises.initialized)
		enterprise.claim_premises(src)

/obj/structure/fake_machine/enterprise_ledger/Destroy()
	if(enterprise)
		enterprise.ledgers -= src
		enterprise = null
	return ..()

/obj/structure/fake_machine/enterprise_ledger/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user) || !enterprise)
		return
	if(!enterprise.is_staff(user))
		to_chat(user, span_warning("The ledger's columns mean nothing to me."))
		return
	enterprise.ui_interact(user)

/obj/structure/fake_machine/enterprise_ledger/tavern
	name = "tavern ledger"
	desc = "The tavern's book of accounts: its menu, its staff and its rooms."
	enterprise_type = /datum/enterprise/tavern
