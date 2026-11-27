/obj/item/clothing/ring/gold/protection/antileechy
	name = "ring of swamp protection"
	desc = "Old ring, inscribed with arcyne words. Protects against swamp."
	clothing_traits = list(TRAIT_LEECHIMMUNE)
	sellprice = 100

/obj/item/clothing/ring/gold/protection/antishocky
	name = "ring of lightning protection"
	desc = "Old ring, inscribed with arcyne words. Enhances protection against lightning strikes."
	clothing_traits = list(TRAIT_SHOCKIMMUNE)
	sellprice = 750

/obj/item/clothing/ring/gold/protection/antimagika
	name = "ring of magic protection"
	desc = "Old ring, inscribed with arcyne words. Enhances protection against magic."
	clothing_traits = list(TRAIT_ANTIMAGIC)
	sellprice = 2000

/obj/item/clothing/ring/gold/protection/health
	name = "ring of health protection"
	desc = "Old ring, inscribed with arcyne words. Enhances protection against wounds."
	clothing_traits = list(TRAIT_TRUE_GRIT)
	sellprice = 750

/obj/item/clothing/ring/gold/protection/fall
	name = "ring of falling protection"
	desc = "Old ring, inscribed with arcyne words. Enhances protection against falling."
	clothing_traits = list(TRAIT_NOFALLDAMAGE1)
	sellprice = 100

/obj/item/clothing/ring/gold/protection/army
	name = "ring of army"
	desc = "Old ring, inscribed with arcyne words. Enhanced protection against many enemies."
	clothing_traits = list(TRAIT_TEMPO)
	sellprice = 2500

// Sell prices stay at half the pack cost, so buying a ring and exporting it never pays.

/datum/supply_pack/jewelry/swamp_protection_ring
	name = "Ring of Swamp Protection"
	desc = "An old ring inscribed with arcyne words. Protects against swamp."
	cost = 200
	contains = /obj/item/clothing/ring/gold/protection/antileechy

/datum/supply_pack/jewelry/lightning_protection_ring
	name = "Ring of Lightning Protection"
	desc = "An old ring inscribed with arcyne words. Enhances protection against lightning strikes."
	cost = 1500
	contains = /obj/item/clothing/ring/gold/protection/antishocky

/datum/supply_pack/jewelry/health_protection_ring
	name = "Ring of Health Protection"
	desc = "An old ring inscribed with arcyne words. Enhances protection against wounds."
	cost = 1500
	contains = /obj/item/clothing/ring/gold/protection/health

/datum/supply_pack/jewelry/falling_protection_ring
	name = "Ring of Falling Protection"
	desc = "An old ring inscribed with arcyne words. Enhances protection against falling."
	cost = 200
	contains = /obj/item/clothing/ring/gold/protection/fall

/datum/supply_pack/jewelry/army_ring
	name = "Ring of Army"
	desc = "An old ring inscribed with arcyne words. Enhanced protection against many enemies."
	cost = 5000
	contains = /obj/item/clothing/ring/gold/protection/army

/datum/world_faction/coastal_merchants/New()
	rare_pool += list(
		/datum/supply_pack/jewelry/swamp_protection_ring,
		/datum/supply_pack/jewelry/falling_protection_ring,
		/datum/supply_pack/jewelry/lightning_protection_ring,
		/datum/supply_pack/jewelry/health_protection_ring,
	)
	exotic_pool += list(
		/datum/supply_pack/jewelry/army_ring,
	)
	return ..()
