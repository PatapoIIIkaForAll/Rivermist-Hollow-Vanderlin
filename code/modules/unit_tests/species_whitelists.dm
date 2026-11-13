/datum/unit_test/species_whitelist_check/Run()
	for(var/datum/species/S as anything in subtypesof(/datum/species))
		if(initial(S.changesource_flags) == NONE)
			TEST_FAIL("A species type was detected with no changesource flags: [S]")

/// A species without an id puts a null key into GLOB.species_list and breaks the startup sort.
/datum/unit_test/species_ids/Run()
	for(var/datum/species/S as anything in subtypesof(/datum/species))
		if(!initial(S.id))
			TEST_FAIL("A species type was detected with no id: [S]")
