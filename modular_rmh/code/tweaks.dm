#define STEEL_INT 8
#define IRON_INT 6
#define LEATHER_INT 3
#define CLOTH_INT 3

/datum/quirk/positive/goodman
	name = "Good man"
	desc = "I try to live by honor and law. I help those in need, respect the authorities, and avoid needless cruelty. \
	My reputation as a good and honest man precedes me, and people often expect me to act with fairness and restraint. \
	\nYou are expected to behave as a lawful and decent person. \
	Criminal behavior, cruelty, and senseless violence go against your character. \
	Others may seek your help, rely on your judgment, or hold you to higher moral standards. \
	Play responsibly and stay true to your principles."
	point_value = 1
	incompatible_quirks = list(/datum/quirk/negative/wanted)

/obj/item
	var/integrity_scaled = FALSE

/obj/item/Initialize()
	. = ..()

	apply_item_scaling()


/obj/item/proc/apply_item_scaling()

	if(integrity_scaled)
		return

	integrity_scaled = TRUE

	var/mult = get_integrity_multiplier()

	if(mult <= 1)
		return

	// durability scaling
	max_integrity *= mult
	atom_integrity = max_integrity

	// blade scaling
	if(max_blade_int > 0)
		max_blade_int *= mult
		blade_int *= mult
		dismember_blade_int *= mult

/obj/item/proc/get_integrity_multiplier()
	var/mult = 1

	switch(max_integrity)
		if(INTEGRITY_STRONGEST) // steel
			mult = STEEL_INT
		if(INTEGRITY_STRONG) // iron
			mult = IRON_INT
		if(INTEGRITY_STANDARD) // leather
			mult = LEATHER_INT
		if(INTEGRITY_POOR) // cloth
			mult = CLOTH_INT
	if(mult == 1 && max_integrity > INTEGRITY_WORST)
		mult = 3

	return mult

#undef STEEL_INT
#undef IRON_INT
#undef LEATHER_INT
#undef CLOTH_INT
