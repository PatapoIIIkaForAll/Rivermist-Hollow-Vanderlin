/*
* The familytree subsystem is supposed to be a way to
* assist RP by setting people up as related roundstart.
* This relation can be based on role (IE king and prince
* being father and son) or random chance.
*
* Updated to work with the new multi-generational heritage system
* Fixed to properly handle string age constants
*/

SUBSYSTEM_DEF(familytree)
	name = "familytree"
	flags = SS_NO_FIRE
	lazy_load = FALSE

	/*
	* The family that kings, queens, and princes
	* are automatically placed into. Has no other
	* real function.
	*/
	var/datum/heritage/ruling_family
	/*
	* The other major houses of Rockhill.
	* Id say think Shrouded Isle families but
	* smaller.
	*/
	var/list/families = list()
	/*
	* Bachalors and Bachalorettes
	*/
	var/list/viable_spouses = list()
	/// Characters whose named family preference could not be satisfied yet.
	var/list/pending_family_members = list()
	var/resolving_pending = FALSE
	var/const/MAX_HOUSE_MEMBERS = 6
	//These jobs are excluded from AddLocal()
	var/excluded_jobs = null
	//This creates 2 families for each race roundstart so that siblings dont fail to be added to a family.
	var/list/preset_family_species = list(
		/datum/species/human/northern,
		/datum/species/elf,
		/datum/species/elf/dark,
		/datum/species/human/halfelf,
		/datum/species/dwarf/mountain,
		/datum/species/tieberian,
		/datum/species/aasimar,
		/datum/species/rakshari,
		/datum/species/halforc
		)

/datum/controller/subsystem/familytree/Initialize()
	ruling_family = new /datum/heritage(null, "Royal", /datum/species/human/northern)
	//Blank starter families that we can customize for players.
	for(var/pioneer_household in preset_family_species)
		for(var/I = 1 to 2)
			families += new /datum/heritage(null, null, pioneer_household)

	return ..()

/datum/controller/subsystem/familytree/proc/GetAgeValue(age_string)
	// Convert age string to numeric value for comparison
	switch(age_string)
		if(AGE_ADULT)
			return 1
		if(AGE_MIDDLEAGED)
			return 2
		if(AGE_OLD)
			return 3
		if(AGE_IMMORTAL)
			return 4
		else
			return 1 // Default to adult

/datum/controller/subsystem/familytree/proc/WouldCreateAgeConflict(datum/heritage/house, mob/living/carbon/human/person)
	if(!house.members.len)
		return FALSE
	// Check against existing family members for age conflicts
	for(var/datum/family_member/member in house.members)
		if(!member.person)
			continue

		// Check if person is too young to be parent of existing children
		for(var/datum/family_member/child in member.children)
			if(child.person && !CanBeParentOf(person.age, child.person.age))
				return TRUE

		// Check if person is too old to be child of existing parents
		for(var/datum/family_member/parent in member.parents)
			if(parent.person && !CanBeParentOf(parent.person.age, person.age))
				return TRUE

	return FALSE

/datum/controller/subsystem/familytree/proc/CanBeParentOf(parent_age, child_age)
	// Parent must be at least one age category higher than child
	if(parent_age == AGE_MIDDLEAGED && child_age == AGE_ADULT)
		return TRUE
	if(parent_age == AGE_OLD && child_age != AGE_OLD && child_age != AGE_IMMORTAL)
		return TRUE
	if(parent_age == AGE_IMMORTAL && child_age != AGE_IMMORTAL)
		return TRUE

	return FALSE

/datum/controller/subsystem/familytree/proc/CanBeSiblings(age1, age2)
	// Siblings can be same age category or adjacent categories
	if(age1 == age2)
		return TRUE

	var/age1_value = GetAgeValue(age1)
	var/age2_value = GetAgeValue(age2)

	// Allow siblings to be within 1 age category of each other
	if(abs(age1_value - age2_value) <= 1)
		return TRUE

	return FALSE

/// Returns an explanation when two players cannot establish this family bond, or null when it is valid.
/datum/controller/subsystem/familytree/proc/GetRememberFamilyError(mob/living/carbon/human/person, mob/living/carbon/human/relative, relation_type)
	if(!ishuman(person) || !ishuman(relative) || person == relative)
		return "That memory cannot describe a real family bond."
	if(!person.mind || !relative.mind)
		return "Both people need an established identity to remember one another."
	if(!(relation_type in list(FAMILY_MEMBER_PARENT, FAMILY_MEMBER_CHILD, FAMILY_MEMBER_SIBLING, FAMILY_MEMBER_SPOUSE)))
		return "That kind of family bond is not supported."

	var/datum/family_member/person_member = person.family_member_datum
	var/datum/family_member/relative_member = relative.family_member_datum
	if((person.family_datum && (!person_member || person_member.family != person.family_datum)) || (!person.family_datum && person_member))
		return "Your family history is inconsistent. Please report this to an administrator."
	if((relative.family_datum && (!relative_member || relative_member.family != relative.family_datum)) || (!relative.family_datum && relative_member))
		return "Their family history is inconsistent. Please report this to an administrator."
	if(person.family_datum && relative.family_datum && person.family_datum != relative.family_datum)
		return "Your established family histories belong to different houses."

	if(person_member && relative_member)
		var/current_relation
		if(relative_member in person_member.parents)
			current_relation = FAMILY_MEMBER_PARENT
		else if(relative_member in person_member.children)
			current_relation = FAMILY_MEMBER_CHILD
		else if(relative_member in person_member.spouses)
			current_relation = FAMILY_MEMBER_SPOUSE
		else if(person_member.AreSiblings(relative_member))
			current_relation = FAMILY_MEMBER_SIBLING

		if(current_relation == relation_type)
			return "You already remember this family bond."
		if(current_relation)
			return "Your family tree already records a different close relation between you."

	switch(relation_type)
		if(FAMILY_MEMBER_PARENT, FAMILY_MEMBER_CHILD)
			var/mob/living/carbon/human/parent = relation_type == FAMILY_MEMBER_PARENT ? relative : person
			var/mob/living/carbon/human/child = relation_type == FAMILY_MEMBER_PARENT ? person : relative
			var/datum/family_member/parent_member = parent.family_member_datum
			var/datum/family_member/child_member = child.family_member_datum
			if(!CanBeParentOf(parent.age, child.age))
				return "Your ages do not support that parent and child relationship."
			if(child_member && length(child_member.parents) >= 2)
				return "The remembered child already has two parents in their family tree."
			if(parent_member && child_member && child_member.IsAncestorOf(parent_member))
				return "That memory would create a circular family tree."

		if(FAMILY_MEMBER_SIBLING)
			if(!CanBeSiblings(person.age, relative.age))
				return "Your ages are too far apart for the family tree to treat you as siblings."
			if(person_member && relative_member && (person_member.IsAncestorOf(relative_member) || relative_member.IsAncestorOf(person_member)))
				return "Ancestors and descendants cannot also be siblings."
			var/person_has_parent = person_member && length(person_member.parents)
			var/relative_has_parent = relative_member && length(relative_member.parents)
			if(person_has_parent && relative_member && length(relative_member.parents) >= 2)
				if(relative_has_parent && person_member && length(person_member.parents) >= 2)
					return "Neither family tree has room for a shared parent."

		if(FAMILY_MEMBER_SPOUSE)
			if(length(person_member?.spouses) || length(relative_member?.spouses) || person.spouse_mob || relative.spouse_mob)
				return "One of you already remembers a current spouse."

	var/datum/heritage/house = person.family_datum || relative.family_datum
	var/additional_members = (person_member ? 0 : 1) + (relative_member ? 0 : 1)
	if(relation_type == FAMILY_MEMBER_SIBLING)
		var/person_has_known_parent = person_member && length(person_member.parents)
		var/relative_has_known_parent = relative_member && length(relative_member.parents)
		if(!person_has_known_parent && !relative_has_known_parent)
			additional_members++ // Siblings need a shared historical parent in the authoritative tree.
	if(length(house?.members) + additional_members > MAX_HOUSE_MEMBERS)
		return "That house has no room for everyone needed by this memory."

	return null

/// Establishes a mutually accepted family bond in both the heritage graph and social relations.
/datum/controller/subsystem/familytree/proc/RememberFamilyRelation(mob/living/carbon/human/person, mob/living/carbon/human/relative, relation_type)
	if(GetRememberFamilyError(person, relative, relation_type))
		return FALSE

	var/datum/heritage/house = person.family_datum || relative.family_datum
	if(!house)
		if(relation_type == FAMILY_MEMBER_SIBLING)
			house = new(null, null, person.dna?.species?.type)
			house.housename = house.SurnameFormatting(person)
			house.dominant_species = person.dna?.species?.type
		else
			var/mob/living/carbon/human/founder = relation_type == FAMILY_MEMBER_PARENT ? relative : person
			house = new(founder)
		families |= house

	var/datum/family_member/person_member = house.GetFamilyMember(person)
	if(!person_member)
		person_member = house.CreateFamilyMember(person)
	var/datum/family_member/relative_member = house.GetFamilyMember(relative)
	if(!relative_member)
		relative_member = house.CreateFamilyMember(relative)
	if(!person_member || !relative_member)
		return FALSE

	switch(relation_type)
		if(FAMILY_MEMBER_PARENT)
			return person_member.AddParent(relative_member)

		if(FAMILY_MEMBER_CHILD)
			return relative_member.AddParent(person_member)

		if(FAMILY_MEMBER_SPOUSE)
			return house.MarryMembers(person_member, relative_member)

		if(FAMILY_MEMBER_SIBLING)
			// Prefer an existing parent so this memory extends the current tree naturally.
			if(length(relative_member.parents) < 2)
				for(var/datum/family_member/person_parent in person_member.parents)
					if(relative_member.AddParent(person_parent))
						return TRUE
			if(length(person_member.parents) < 2)
				for(var/datum/family_member/relative_parent in relative_member.parents)
					if(person_member.AddParent(relative_parent))
						return TRUE

			// The graph derives siblinghood from shared parentage, so give two otherwise
			// rootless siblings a historical parent rather than creating a cosmetic-only bond.
			var/mob/living/carbon/human/dummy/unknown_parent = new()
			unknown_parent.real_name = "Unknown Parent"
			unknown_parent.gender = prob(50) ? MALE : FEMALE
			unknown_parent.age = person.age == AGE_IMMORTAL || relative.age == AGE_IMMORTAL ? AGE_IMMORTAL : AGE_OLD
			unknown_parent.stat = DEAD
			var/species_type = house.dominant_species || person.dna?.species?.type
			if(species_type)
				set_species_type(unknown_parent, species_type)
			var/datum/family_member/shared_parent = house.CreateFamilyMember(unknown_parent)
			if(!shared_parent)
				qdel(unknown_parent)
				return FALSE
			if(!house.founder)
				house.founder = shared_parent
			if(!person_member.AddParent(shared_parent) || !relative_member.AddParent(shared_parent))
				return FALSE
			return TRUE

	return FALSE

/datum/controller/subsystem/familytree/proc/DetermineAppropriateRole(datum/heritage/house, mob/living/carbon/human/person, adopted = FALSE)
	if(person.setparent)
		for(var/datum/family_member/member in house.members)
			if(member.person?.real_name == person.setparent)
				return FAMILY_MEMBER_CHILD
	if(person.setchild)
		for(var/datum/family_member/member in house.members)
			if(member.person?.real_name == person.setchild)
				return FAMILY_MEMBER_PARENT

	// Look for potential parents (older members who could be parents)
	var/list/potential_parents = list()
	for(var/datum/family_member/member in house.members)
		if(member.person && CanBeParentOf(member.person.age, person.age))
			potential_parents += member

	// If we have potential parents, make this person a child
	if(potential_parents.len)
		return FAMILY_MEMBER_CHILD

	// Look for potential siblings (similar age)
	for(var/datum/family_member/member in house.members)
		if(member.person && CanBeSiblings(member.person.age, person.age))
			return FAMILY_MEMBER_SIBLING

	// Default to founder/parent role
	return FAMILY_MEMBER_PARENT

/datum/controller/subsystem/familytree/proc/AddLocal(mob/living/carbon/human/H, status)
	if(!H?.mind || istype(H, /mob/living/carbon/human/dummy))
		return
	//Exclude princes and princesses from having their parentage calculated.
	if(H.mind?.assigned_role && is_type_in_list(H.mind.assigned_role, excluded_jobs))
		return
	var/mode = H.familytree_pref
	if(!mode)
		mode = status
	if(!mode || mode == FAMILY_NONE)
		_MaybeMakeDivorcedStub(H)
		return

	var/assigned = TryAssignLocal(H, mode)
	if(assigned)
		pending_family_members -= H
	else
		pending_family_members |= H
	_MaybeMakeDivorcedStub(H)
	ResolvePendingFamilies()
	return assigned

/datum/controller/subsystem/familytree/proc/TryAssignLocal(mob/living/carbon/human/H, mode)
	if(H.family_datum || H.spouse_mob)
		return TRUE
	switch(mode)
		if(FAMILY_PARTIAL)
			return AssignToHouse(H, H.family_adoption_pref)

		if(FAMILY_NEWLYWED)
			return AssignNewlyWed(H)

		if(FAMILY_FULL)
			if(HAS_TRAIT(H, TRAIT_VIRGIN))
				return AssignToHouse(H, H.family_adoption_pref)
			return AssignToFamily(H)
	return FALSE

/datum/controller/subsystem/familytree/proc/ResolvePendingFamilies()
	if(resolving_pending || !length(pending_family_members))
		return
	resolving_pending = TRUE
	var/list/pending_copy = pending_family_members.Copy()
	for(var/mob/living/carbon/human/pending in pending_copy)
		if(!pending?.mind || QDELETED(pending))
			pending_family_members -= pending
			continue
		if(TryAssignLocal(pending, pending.familytree_pref))
			pending_family_members -= pending
	resolving_pending = FALSE

/datum/controller/subsystem/familytree/proc/AddRoyal(mob/living/carbon/human/H, status)
	// Some callers queue this on a timer, and the royal can be deleted first.
	if(QDELETED(H) || !H.dna)
		return
	if(!ruling_family.housename)
		ruling_family.housename = "Royal"
	var/datum/family_member/member = ruling_family.CreateFamilyMember(H)
	if(!member)
		return

	// If this is the first royal, generate a historical lineage
	if(!ruling_family.founder)
		GenerateRoyalLineage(member, status)
		H.ShowFamilyUI(TRUE)
		return

	// Handle adding new royals to existing family
	switch(status)
		if(FAMILY_FATHER, FAMILY_MOTHER)
			// This should be the monarch - they're the current generation ruler
			member.generation = 12  // Same as founder generation
			// If there's already a monarch, make them spouses
			var/datum/family_member/existing_monarch = GetCurrentMonarch()
			if(existing_monarch)
				ruling_family.MarryMembers(existing_monarch, member)

		if(FAMILY_PROGENY)  // Prince/Princess
			// Children of the current monarch
			var/datum/family_member/monarch = GetCurrentMonarch()
			if(monarch)
				member.generation = monarch.generation + 1
				member.AddParent(monarch)
				// Add other parent if monarch has spouse
				if(monarch.spouses.len)
					member.AddParent(monarch.spouses[1])

		if(FAMILY_OMMER)  // Hand - sibling or cousin of monarch
			CreateBranchFamily(member)

	H.ShowFamilyUI(TRUE)

/datum/controller/subsystem/familytree/proc/GetCurrentMonarch()
	// Find the monarch at generation 12 (current ruling generation)
	for(var/datum/family_member/member in ruling_family.members)
		if(member.generation == 12 && member.person.job == "Monarch")
			return member
	return null

/datum/controller/subsystem/familytree/proc/CreateBranchFamily(datum/family_member/hand_member)
	var/datum/family_member/monarch = GetCurrentMonarch()
	if(!monarch)
		return

	hand_member.generation = monarch.generation

	// Make the hand a sibling of the monarch (so uncle/aunt to any princes/princesses)
	if(monarch.parents.len)
		var/datum/family_member/monarch_parent = monarch.parents[1]
		var/datum/family_member/monarch_parent_second = monarch.parents[2]
		if(monarch_parent)
			hand_member.AddParent(monarch_parent)
		if(monarch_parent_second)
			hand_member.AddParent(monarch_parent_second)

		// Create a spouse for the hand
		var/mob/living/carbon/human/dummy/spouse = new()
		spouse.age = hand_member.person.age
		spouse.gender = hand_member.person.gender == MALE ? FEMALE : MALE
		spouse.real_name = GenerateRoyalName(spouse.gender, hand_member.generation)
		set_species_type(spouse, ruling_family.dominant_species)
		var/datum/family_member/hand_spouse = ruling_family.CreateFamilyMember(spouse)
		hand_spouse.generation = hand_member.generation
		ruling_family.MarryMembers(hand_member, hand_spouse)

/datum/controller/subsystem/familytree/proc/GenerateRoyalLineage(datum/family_member/current_royal, status)
	// Set as current generation
	ruling_family.founder = current_royal
	current_royal.generation = 12  // Start at generation 12 to leave room for ancestors

	// Update ruling family's species based on first member
	ruling_family.dominant_species = current_royal.person.dna.species.type

	// Generate ancestors
	var/datum/family_member/current_ancestor = current_royal
	var/list/age_progression = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_OLD)

	for(var/i = current_royal.generation - 1; i >= 6; i--)  // Generate 6 generations of ancestors
		// Create parent
		var/mob/living/carbon/human/dummy/ancestor = new()
		ancestor.age = age_progression[min(current_royal.generation - i, age_progression.len)]
		ancestor.gender = prob(50) ? MALE : FEMALE
		ancestor.real_name = GenerateRoyalName(ancestor.gender, i)
		set_species_type(ancestor, ruling_family.dominant_species)
		var/datum/family_member/parent = ruling_family.CreateFamilyMember(ancestor)
		parent.generation = i

		// Create spouse for parent
		var/mob/living/carbon/human/dummy/spouse = new()
		spouse.age = ancestor.age
		spouse.gender = ancestor.gender == MALE ? FEMALE : MALE
		spouse.real_name = GenerateRoyalName(spouse.gender, i)
		set_species_type(spouse, ruling_family.dominant_species)
		var/datum/family_member/parent_spouse = ruling_family.CreateFamilyMember(spouse)
		parent_spouse.generation = i

		// Connect family members
		ruling_family.MarryMembers(parent, parent_spouse)
		current_ancestor.AddParent(parent)
		current_ancestor.AddParent(parent_spouse)

		// Add 0-1 siblings with 30% chance (for branch families later)
		if(prob(30))
			var/mob/living/carbon/human/dummy/sibling = new()
			sibling.age = ancestor.age
			sibling.gender = prob(50) ? MALE : FEMALE
			sibling.real_name = GenerateRoyalName(sibling.gender, i + 1)
			set_species_type(sibling, ruling_family.dominant_species)
			var/datum/family_member/sibling_member = ruling_family.CreateFamilyMember(sibling)
			sibling_member.generation = i + 1
			sibling_member.AddParent(parent)
			sibling_member.AddParent(parent_spouse)

		current_ancestor = parent


/datum/controller/subsystem/familytree/proc/set_species_type(mob/living/carbon/human/H, species_type)
	if(!H || !species_type)
		return

	var/datum/species/S = new species_type
	H.set_species(S)
	H.dna.species = S

/datum/controller/subsystem/familytree/proc/GenerateRoyalName(gender, generation)
	var/list/male_names = list(
		"King" = list("Alexander", "William", "Edward", "Henry", "Richard", "George"),
		"Prince" = list("Charles", "Philip", "Arthur", "Frederick", "Edmund")
	)
	var/list/female_names = list(
		"Queen" = list("Victoria", "Elizabeth", "Mary", "Anne", "Catherine"),
		"Princess" = list("Margaret", "Charlotte", "Sophia", "Alexandra")
	)

	var/title
	var/list/names
	if(gender == MALE)
		title = generation > 2 ? "King" : "Prince"
		names = male_names[title]
	else
		title = generation > 2 ? "Queen" : "Princess"
		names = female_names[title]

	var/list/roman_numerals = list("I", "II", "III", "IV", "V")
	return "[title] [pick(names)] [pick(roman_numerals)]"

/datum/controller/subsystem/familytree/proc/AssignToHouse(mob/living/carbon/human/H, force_adopted = FALSE)
	if(!H)
		return FALSE

	var/species = H.dna?.species?.type
	var/adopted = force_adopted
	var/datum/heritage/chosen_house

	// Resolve named parent/child pairs directly so two mutually designated
	// characters do not wait forever for one of them to seed a house first.
	if(H.setparent || H.setchild)
		for(var/datum/mind/candidate_mind in SSticker.minds)
			var/mob/living/carbon/human/candidate = candidate_mind.current
			if(!ishuman(candidate) || candidate == H)
				continue

			if(H.setparent && candidate.real_name == H.setparent)
				if(candidate.familytree_pref == FAMILY_NONE && candidate.setchild != H.real_name)
					continue
				if(!_ChildCompatible(candidate, H))
					continue
				var/datum/heritage/parent_house = candidate.family_datum
				if(!parent_house)
					parent_house = new(candidate)
					families |= parent_house
				if(length(parent_house.members) >= MAX_HOUSE_MEMBERS)
					return FALSE
				return !!parent_house.AddToFamily(H, candidate.family_member_datum, null, adopted)

			if(H.setchild && candidate.real_name == H.setchild)
				if(candidate.familytree_pref == FAMILY_NONE && candidate.setparent != H.real_name)
					continue
				if(!_ChildCompatible(H, candidate))
					continue
				var/datum/heritage/child_house = candidate.family_datum
				if(!child_house)
					child_house = new(H)
					families |= child_house
					return !!child_house.AddToFamily(candidate, H.family_member_datum, null, candidate.family_adoption_pref)
				if(length(child_house.members) >= MAX_HOUSE_MEMBERS || length(candidate.family_member_datum?.parents) >= 2)
					return FALSE
				var/datum/family_member/new_parent = child_house.CreateFamilyMember(H)
				return !!candidate.family_member_datum?.AddParent(new_parent)

	var/list/active_houses = list()
	var/list/seed_houses = list()
	for(var/datum/heritage/house in families)
		if(house.housename && length(house.members) && length(house.members) < MAX_HOUSE_MEMBERS)
			active_houses += house
		else if(!house.housename || !length(house.members))
			seed_houses += house

	var/designated_relative = H.setparent
	if(!designated_relative)
		designated_relative = H.setchild
	if(designated_relative)
		for(var/datum/heritage/house in active_houses + seed_houses)
			if(!HousePassesFilters(H, house))
				continue
			for(var/datum/family_member/member in house.members)
				if(member.person?.real_name == designated_relative)
					chosen_house = house
					break
			if(chosen_house)
				break
		if(!chosen_house)
			return FALSE

	if(!chosen_house)
		for(var/datum/heritage/house in active_houses)
			if(house.dominant_species != species || length(house.members) >= 4)
				continue
			if(HousePassesFilters(H, house) && !WouldCreateAgeConflict(house, H))
				chosen_house = house
				break

	if(!chosen_house && force_adopted)
		for(var/datum/heritage/house in active_houses)
			if(house.dominant_species == species || !HousePassesFilters(H, house) || WouldCreateAgeConflict(house, H))
				continue
			chosen_house = house
			adopted = TRUE
			break

	if(!chosen_house)
		for(var/datum/heritage/house in seed_houses)
			if(house.dominant_species == species && HousePassesFilters(H, house) && !WouldCreateAgeConflict(house, H))
				chosen_house = house
				break

	if(!chosen_house && force_adopted)
		for(var/datum/heritage/house in seed_houses)
			if(HousePassesFilters(H, house) && !WouldCreateAgeConflict(house, H))
				chosen_house = house
				adopted = TRUE
				break

	if(!chosen_house)
		return FALSE
	return AddPersonToHouse(chosen_house, H, adopted)

/datum/controller/subsystem/familytree/proc/AddPersonToHouse(datum/heritage/house, mob/living/carbon/human/person, adopted = FALSE)
	var/role = DetermineAppropriateRole(house, person, adopted)

	switch(role)
		if(FAMILY_MEMBER_CHILD)
			// Find suitable parents
			var/list/potential_parents = list()
			for(var/datum/family_member/member in house.members)
				if(!member.person || !_ChildCompatible(member.person, person))
					continue
				if(member.person.setchild == person.real_name)
					potential_parents.Insert(1, member)
				else
					potential_parents += member

			// Add a second parent only when they are actually married to the first.
			var/datum/family_member/parent1 = potential_parents.len > 0 ? potential_parents[1] : null
			var/datum/family_member/parent2
			if(parent1 && potential_parents.len > 1)
				for(var/datum/family_member/possible_parent in potential_parents)
					if(possible_parent != parent1 && (possible_parent in parent1.spouses))
						parent2 = possible_parent
						break

			return !!house.AddToFamily(person, parent1, parent2, adopted)

		if(FAMILY_MEMBER_SIBLING)
			// Find a sibling and share their parents
			for(var/datum/family_member/member in house.members)
				if(member.person && CanBeSiblings(member.person.age, person.age))
					var/datum/family_member/parent1 = member.parents.len > 0 ? member.parents[1] : null
					var/datum/family_member/parent2 = member.parents.len > 1 ? member.parents[2] : null
					return !!house.AddToFamily(person, parent1, parent2, adopted)

		if(FAMILY_MEMBER_PARENT)
			// Add as founder/parent
			var/datum/family_member/designated_child
			if(person.setchild)
				for(var/datum/family_member/member in house.members)
					if(member.person?.real_name == person.setchild)
						designated_child = member
						break
				if(designated_child && length(designated_child.parents) >= 2)
					return FALSE
			var/datum/family_member/new_member = house.CreateFamilyMember(person)
			if(!new_member)
				return FALSE
			if(designated_child && !designated_child.AddParent(new_member))
				return FALSE
			if(!house.founder)
				house.founder = new_member
				new_member.generation = 0
			if(!house.housename)
				house.housename = house.SurnameFormatting(person)
			return !!new_member
	return FALSE


/// Human Helper proc to check gender choice based on pronouns

/mob/living/carbon/human/proc/pronouns_match(mob/living/carbon/human/H, mob/living/carbon/human/other)
	// ANY_GENDER always passes
	if(H.gender_choice_pref == ANY_GENDER)
		return TRUE

	// Neutral pronouns can only match ANY_GENDER
	var/my_neutral = (H.pronouns == THEY_THEM || H.pronouns == IT_ITS)
	var/other_neutral = (other.pronouns == THEY_THEM || other.pronouns == IT_ITS)

	// If I am neutral:
	if(my_neutral)
		return (other_neutral || other.gender_choice_pref == ANY_GENDER)

	// If they are neutral(ANY_GENDER already checked):
	if(other_neutral)
		return FALSE

	if(H.gender_choice_pref == SAME_GENDER)
		return (H.pronouns == other.pronouns)

	if(H.gender_choice_pref == DIFFERENT_GENDER)
		return (H.pronouns != other.pronouns)

	return FALSE

/datum/controller/subsystem/familytree/proc/AssignToFamily(mob/living/carbon/human/H)
	if(!H)
		return FALSE
	var/our_species = H.dna.species.type

	// Named partners may both be waiting for a family. Match those characters
	// directly instead of deadlocking until one has already founded a house.
	if(H.setspouse)
		for(var/datum/mind/candidate_mind in SSticker.minds)
			var/mob/living/carbon/human/candidate = candidate_mind.current
			if(!ishuman(candidate) || candidate == H || candidate.spouse_mob)
				continue
			if(candidate.familytree_pref == FAMILY_NONE && candidate.setspouse != H.real_name)
				continue
			if(candidate.real_name != H.setspouse || !_SpouseCompatible(H, candidate))
				continue
			H.MarryTo(candidate)
			pending_family_members -= candidate
			return TRUE

	for(var/datum/heritage/house in families)
		if(house.dominant_species != our_species)
			continue
		for(var/datum/family_member/member in house.members)
			if(!member.person || length(member.spouses))
				continue
			if(!_SpouseCompatible(H, member.person))
				continue
			var/datum/family_member/new_member = house.CreateFamilyMember(H)
			if(!new_member)
				return FALSE
			house.MarryMembers(new_member, member)
			return TRUE

		// #6972: a named spouse must never silently degrade into founding a
		// different family while that requested character is absent.
		if(H.setspouse)
			continue
		if(!house.housename)
			var/datum/family_member/new_member = house.CreateFamilyMember(H)
			if(!new_member)
				return FALSE
			house.founder = new_member
			new_member.generation = 0
			house.housename = house.SurnameFormatting(H)
			return TRUE

	if(H.setspouse)
		return FALSE
	if(our_species != /datum/species/aasimar)
		var/datum/heritage/new_house = new(H, null, our_species)
		families += new_house
		return TRUE
	return FALSE

/datum/controller/subsystem/familytree/proc/AssignNewlyWed(mob/living/carbon/human/H)
	viable_spouses |= H
	var/list/potential_matches = list()

	for(var/mob/living/carbon/human/potential_spouse in viable_spouses)
		if(!potential_spouse || potential_spouse == H || potential_spouse.spouse_mob)
			continue
		// Check if they are mutually setspouse
		var/mutual_setspouse = (H.setspouse == potential_spouse.real_name) && (potential_spouse.setspouse == H.real_name)
		if(!mutual_setspouse && !_SpouseCompatible(H, potential_spouse))
			continue
		// Check setspouse compatibility
		var/priority = 0
		if(mutual_setspouse)
			priority = 3 // Perfect match
		else if(H.setspouse == potential_spouse.real_name && !potential_spouse.setspouse)
			priority = 2 // Good match
		else if(potential_spouse.setspouse == H.real_name)
			priority = 1 // Decent match
		else if(!H.setspouse && !potential_spouse.setspouse)
			priority = 0 // Random match
		else
			continue // Incompatible

		potential_matches += list(list(potential_spouse, priority))

	// Sort by priority and pick best match
	if(potential_matches.len)
		var/best_priority = -1
		var/list/best_matches = list()

		for(var/list/match_data in potential_matches)
			var/match_priority = match_data[2]
			if(match_priority > best_priority)
				best_priority = match_priority
				best_matches = list(match_data[1])
			else if(match_priority == best_priority)
				best_matches += match_data[1]

		if(best_matches.len)
			var/mob/living/carbon/human/chosen_spouse = pick(best_matches)
			viable_spouses -= chosen_spouse
			viable_spouses -= H
			H.MarryTo(chosen_spouse)
			return TRUE
	return FALSE

/datum/controller/subsystem/familytree/proc/_SpouseCompatible(mob/living/carbon/human/person, mob/living/carbon/human/other)
	if(!person || !other)
		return FALSE
	if(person.setspouse == other.real_name && other.setspouse == person.real_name)
		return TRUE
	if(person.setspouse && person.setspouse != other.real_name)
		return FALSE
	if(other.setspouse && other.setspouse != person.real_name)
		return FALSE
	return PassesFamilyFilters(person, other) && PassesFamilyFilters(other, person) \
		&& person.pronouns_match(person, other) && other.pronouns_match(other, person)

/datum/controller/subsystem/familytree/proc/PassesFamilyFilters(mob/living/carbon/human/person, mob/living/carbon/human/other)
	if(!person || !other)
		return FALSE
	if(person.same_species_family && person.dna?.species?.type != other.dna?.species?.type)
		return FALSE
	if(!person.same_species_family && length(person.accepted_family_species))
		if(!("[other.dna?.species?.type]" in person.accepted_family_species))
			return FALSE

	if(length(person.accepted_patron_faiths))
		var/other_faith = other.patron?.associated_faith
		if(!other_faith || !("[other_faith]" in person.accepted_patron_faiths))
			return FALSE

	if(length(person.family_job_filter))
		var/job_matches = FALSE
		for(var/group_key in person.family_job_filter)
			if(other.job && (other.job in job_group_list(group_key)))
				job_matches = TRUE
				break
		if(!job_matches)
			return FALSE
	return TRUE

/datum/controller/subsystem/familytree/proc/PassesChildFilters(mob/living/carbon/human/parent, mob/living/carbon/human/child)
	if(!parent || !child)
		return FALSE
	if(parent.setchild && parent.setchild != child.real_name)
		return FALSE
	if(child.setparent && child.setparent != parent.real_name)
		return FALSE
	return PassesFamilyFilters(parent, child) && PassesFamilyFilters(child, parent)

/datum/controller/subsystem/familytree/proc/_ChildCompatible(mob/living/carbon/human/parent, mob/living/carbon/human/child)
	if(!parent || !child)
		return FALSE
	if(parent.setchild && parent.setchild != child.real_name)
		return FALSE
	if(child.setparent && child.setparent != parent.real_name)
		return FALSE
	if(parent.setchild == child.real_name && child.setparent == parent.real_name)
		return TRUE
	if(!PassesChildFilters(parent, child))
		return FALSE
	if(parent.setchild == child.real_name || child.setparent == parent.real_name)
		return TRUE
	return CanBeParentOf(parent.age, child.age)

/datum/controller/subsystem/familytree/proc/HousePassesFilters(mob/living/carbon/human/person, datum/heritage/house)
	if(!length(house.members))
		return TRUE
	for(var/datum/family_member/member in house.members)
		if(member.person && (!PassesFamilyFilters(person, member.person) || !PassesFamilyFilters(member.person, person)))
			return FALSE
	return TRUE

/datum/controller/subsystem/familytree/proc/_MaybeMakeDivorcedStub(mob/living/carbon/human/H)
	if(!H.was_divorced || !H.mind)
		return
	for(var/datum/relation/divorced/existing in H.mind.relations)
		return
	var/datum/relation/divorced/stub = new()
	stub.holder = H.mind
	stub.snapshot = list(
		"name" = "Former Spouse",
		"vcolor" = "ffffff",
		"job" = "Unknown",
		"job_key" = "Unknown",
		"job_category" = "Unknown",
		"honorary" = null,
		"honorary_suffix" = null,
		"species" = "Unknown",
		"gender" = PLURAL,
		"age" = AGE_ADULT,
	)
	H.mind.relations += stub

/datum/controller/subsystem/familytree/proc/AssignAuntUncle(mob/living/carbon/human/H)
	var/species = H.dna.species.type
	var/datum/heritage/chosen_house

	// Find houses with established families that could use an aunt/uncle
	for(var/datum/heritage/house in families)
		if(house.dominant_species != species)
			continue
		if(!house.housename || house.members.len < 2)
			continue

		// Check if there are children who could use an aunt/uncle
		var/has_children = FALSE
		for(var/datum/family_member/member in house.members)
			if(member.children.len > 0)
				has_children = TRUE
				break

		if(has_children && !WouldCreateAgeConflict(house, H))
			chosen_house = house
			break

	if(chosen_house)
		// Add as sibling to one of the parents
		var/datum/family_member/new_member = chosen_house.CreateFamilyMember(H)
		if(new_member)
			// Find a parent to be sibling to
			for(var/datum/family_member/member in chosen_house.members)
				if(member.children.len > 0 && CanBeSiblings(H.age, member.person.age))
					// Share the same parents as this member
					for(var/datum/family_member/grandparent in member.parents)
						new_member.AddParent(grandparent)
					break

/datum/controller/subsystem/familytree/proc/ReturnAllFamilies()
	. = ""
	if(ruling_family && ruling_family.members.len)
		. += ruling_family.FormatFamilyList()
	for(var/datum/heritage/house in families)
		if(!house.housename && !house.members.len)
			continue
		. += house.FormatFamilyList()

/datum/controller/subsystem/familytree/proc/ValidateAllFamilies()
	if(ruling_family && ruling_family.members.len)
		ValidateFamily(ruling_family)
	for(var/datum/heritage/family in families)
		if(family.members.len)
			ValidateFamily(family)

/datum/controller/subsystem/familytree/proc/ValidateFamily(datum/heritage/family)
	// Clean up any broken references
	for(var/datum/family_member/member in family.members)
		if(!member.person)
			family.members -= member
			continue

		// Validate parent relationships
		for(var/datum/family_member/parent in member.parents)
			if(!parent.person || !(member in parent.children))
				member.parents -= parent
				if(parent.person)
					parent.children -= member

		// Validate child relationships
		for(var/datum/family_member/child in member.children)
			if(!child.person || !(member in child.parents))
				member.children -= child
				if(child.person)
					child.parents -= member
