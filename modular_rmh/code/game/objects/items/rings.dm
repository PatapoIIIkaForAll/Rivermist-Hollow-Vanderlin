/obj/item/clothing/ring/gold/protection/antileechy
	name = "ring of swamp protection"
	desc = "Old ring, inscribed with arcyne words. Protects against swamp."
	protection_trait = TRAIT_LEECHIMMUNE
	sellprice = 100

/obj/item/clothing/ring/gold/protection/antishocky
	name = "ring of lightning protection"
	desc = "Old ring, inscribed with arcyne words. Enhances protection against lightning strikes."
	protection_trait = TRAIT_SHOCKIMMUNE
	sellprice = 1000

/obj/item/clothing/ring/gold/protection/antimagika
	name = "ring of magic protection"
	desc = "Old ring, inscribed with arcyne words. Enhances protection against magic."
	protection_trait = TRAIT_ANTIMAGIC
	sellprice = 2000

/obj/item/clothing/ring/gold/protection/health
	name = "ring of health protection"
	desc = "Old ring, inscribed with arcyne words. Enhances protection against wounds."
	protection_trait = TRAIT_TRUE_GRIT
	sellprice = 1000

/obj/item/clothing/ring/gold/protection/fall
	name = "ring of falling protection"
	desc = "Old ring, inscribed with arcyne words. Enhances protection against falling."
	protection_trait = TRAIT_NOFALLDAMAGE1
	sellprice = 500

/obj/item/clothing/ring/gold/protection/army
	name = "ring of army"
	desc = "Old ring, inscribed with arcyne words. Enhanced protection against many enemies."
	protection_trait = TRAIT_TEMPO
	sellprice = 2000

/datum/supply_pack/rings
	group = "Rings"
	abstract_type = /datum/supply_pack/rings

/datum/supply_pack/rings/swamp_protection
	name = "Ring of Swamp Protection"
	desc = "An old ring inscribed with arcyne words. Protects against swamp."
	cost = 200
	contains = /obj/item/clothing/ring/gold/protection/antileechy

/datum/supply_pack/rings/lightning_protection
	name = "Ring of Lightning Protection"
	desc = "An old ring inscribed with arcyne words. Enhances protection against lightning strikes."
	cost = 1500
	contains = /obj/item/clothing/ring/gold/protection/antishocky

/datum/supply_pack/rings/magic_protection
	name = "Ring of Magic Protection"
	desc = "An old ring inscribed with arcyne words. Enhances protection against magic."
	cost = 5000
	contains = /obj/item/clothing/ring/gold/protection/antimagika

/datum/supply_pack/rings/health_protection
	name = "Ring of Health Protection"
	desc = "An old ring inscribed with arcyne words. Enhances protection against wounds."
	cost = 1500
	contains = /obj/item/clothing/ring/gold/protection/health

/datum/supply_pack/rings/falling_protection
	name = "Ring of Falling Protection"
	desc = "An old ring inscribed with arcyne words. Enhances protection against falling."
	cost = 200
	contains = /obj/item/clothing/ring/gold/protection/fall

/datum/supply_pack/rings/army_protection
	name = "Ring of Army"
	desc = "An old ring inscribed with arcyne words. Enhanced protection against many enemies."
	cost = 5000
	contains = /obj/item/clothing/ring/gold/protection/army

/datum/world_faction/coastal_merchants/New()
	rare_pool += list(
		/datum/supply_pack/rings/swamp_protection,
		/datum/supply_pack/rings/falling_protection,
		/datum/supply_pack/rings/lightning_protection,
		/datum/supply_pack/rings/health_protection,
	)
	exotic_pool += list(
		/datum/supply_pack/rings/magic_protection,
		/datum/supply_pack/rings/army_protection,
	)
	return ..()
