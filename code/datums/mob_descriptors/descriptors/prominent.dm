/datum/mob_descriptor/prominent
	abstract_type = /datum/mob_descriptor/prominent
	slot = MOB_DESCRIPTOR_SLOT_PROMINENT

/datum/mob_descriptor/prominent/none
	name = "None"

/datum/mob_descriptor/prominent/none/can_describe(mob/living/described)
	return FALSE

/datum/mob_descriptor/prominent/custom
	abstract_type = /datum/mob_descriptor/prominent/custom
	custom_prefix_mode = CUSTOM_PREFIX_MODE_FULL

/datum/mob_descriptor/prominent/custom/one
	name = "Custom #1"
	custom_index = 1

/datum/mob_descriptor/prominent/custom/two
	name = "Custom #2"
	custom_index = 2

/datum/mob_descriptor/prominent/custom/three
	name = "Custom #3"
	custom_index = 3

/datum/mob_descriptor/prominent/custom/four
	name = "Custom #4"
	custom_index = 4

/datum/mob_descriptor/prominent/hunched_over
	name = "Hunched Over"
	show_obscured = TRUE
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/crooked_nose
	name = "Crooked Nose"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/drooling
	name = "Drooling"
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/lazy_eye
	name = "Lazy Eye"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/bloodshot_eye
	name = "Bloodshot Eyes"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/baggy_eye
	name = "Baggy Eyes"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/deadfish_eye
	name = "Dead Fish Eyes"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/twitchy
	name = "Twitchy"
	show_obscured = TRUE
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/clumsy
	name = "Clumsy"
	show_obscured = TRUE
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/unkempt
	name = "Unkempt"
	show_obscured = TRUE
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/tidy
	name = "Tidy"
	show_obscured = TRUE
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/eloquent
	name = "Eloquent"
	show_obscured = TRUE
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/thick_tail
	name = "Thick Tail"
	verbage = "%HAVE%"
	prefix = "a"
	show_obscured = TRUE

/datum/mob_descriptor/prominent/thick_tail/can_describe(mob/living/described)
	if(!ishuman(described))
		return TRUE
	var/mob/living/carbon/human/human = described
	if(!human.getorganslot(ORGAN_SLOT_TAIL))
		return FALSE
	return TRUE

/datum/mob_descriptor/prominent/cleft_lip
	name = "Cleft Lip"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/physically_deformed
	name = "Physically Deformed"
	show_obscured = TRUE
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/extensive_scars
	name = "Extensive Scarring"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/move_strange
	name = "Moves Strangely"
	show_obscured = TRUE
	verbage = "%MOVE%"
	describe = "strangely"

/datum/mob_descriptor/prominent/ghoulish_appearance
	name = "Ghoulish Appearance"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/prominent_chest
	name = "Prominent Chest"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/prominent_bottom
	name = "Prominent Posterior"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/prominent_potbelly
	name = "Potbelly"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/prominent_thighs
	name = "Fat Thighs"
	show_obscured = TRUE
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/prominent_shoulders
	name = "Broad Shoulders"
	show_obscured = TRUE
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/prominent_jawline
	name = "Jutting Jawline"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/cold_gaze
	name = "Cold Gaze"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/piercing_gaze
	name = "Piercing Gaze"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/innocent_gaze
	name = "Innocent Gaze"
	verbage = "%HAVE%"
	prefix = "an"

/datum/mob_descriptor/prominent/intimidating_presence
	name = "Intimidating Presence"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "an"

/datum/mob_descriptor/prominent/meek_presence
	name = "Meek Presence"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/adorable_presence
	name = "Adorable Presence"
	verbage = "%HAVE%"
	prefix = "an"
	show_obscured = TRUE

/datum/mob_descriptor/prominent/lordly_presence
	name = "Lordly Presence"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/doting_presence
	name = "Doting Presence"
	verbage = "%HAVE%"
	prefix = "a"
	show_obscured = TRUE

/datum/mob_descriptor/prominent/aristocratic_haughtiness
	name = "Aristocratic Disdain"
	verbage = "%HAVE%"
	prefix = "an"
	show_obscured = TRUE

/datum/mob_descriptor/prominent/ghastly_pale
	name = "Ghastly Pale"
	verbage = "%ARE%"

/datum/mob_descriptor/prominent/elaborate_tattoos
	name = "Elaborate Tattoos"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/ritual_tattoos
	name = "Ritual Tattoos"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/tribal_tattoos
	name = "Tribal Tattoos"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/slave_tattoos
	name = "Slave Tattoos"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/enigmatic_tattoos
	name = "Enigmatic Tattoos"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/mean_look
	name = "Mean Look"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/haughty_atmosphere
	name = "Haughty Mannerisms"
	show_obscured = TRUE
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/untrustworthy
	name = "Untrustworthy"
	show_obscured = TRUE
	verbage = "%APPEAR%"

/datum/mob_descriptor/prominent/ratty_hair
	name = "Ratty Hair"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/predatory_look
	name = "Predatory Look"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/chaste_mannerism
	name = "Chaste Mannerisms"
	show_obscured = TRUE
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/whimsy
	name = "Air of Whimsy"
	verbage = "%HAVE%"
	prefix = "an"
	suffix = "about %HIM%"
	show_obscured = TRUE

/datum/mob_descriptor/prominent/dim_look
	name = "Dim Look"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/keen_look
	name = "Keen Look"
	verbage = "%HAVE%"
	prefix = "a"


/datum/mob_descriptor/prominent/presence_stoic
	name = "Stoic Prescence"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/hands_platters
	name = "Hands like platters"
	show_obscured = TRUE
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/hands_delicate
	name = "Delicate hands"
	show_obscured = TRUE
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/fingers_long
	name = "Long fingers"
	show_obscured = TRUE
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/teeth_fine
	name = "Fine Teeth"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/teeth_rotting
	name = "Rotting Teeth"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/teeth_missing
	name = "Missing Teeth"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/teeth_fine
	name = "Fine Teeth"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/laugh_donkey
	name = "Donkey-like Laugh"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/nose_crooked
	name = "Crooked Nose"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/nose_broken
	name = "Broken Nose"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/nose_button
	name = "Button Nose"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/nose_hawk
	name = "Hawkish Nose"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/nose_aquiline
	name = "Aquiline Nose"
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/neck_bull
	name = "Bull Neck"
	show_obscured = TRUE
	verbage = "%HAVE%"
	prefix = "a"

/datum/mob_descriptor/prominent/hair_perfumed
	name = "Perfumed Hair"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/hair_oiled
	name = "Oiled Hair"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/hair_curly
	name = "Curly Hair"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/hair_coarse
	name = "Coarse Hair"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/hair_thin
	name = "Thin Hair"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/ears_large
	name = "Large Ears"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/promiscuous_mannerisms
	name = "Sensual Manners"
	verbage = "%HAVE%"
	show_obscured = TRUE

/datum/mob_descriptor/prominent/canine_features
	name = "Canine Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/feline_features
	name = "Feline Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/hyaenidae_features
	name = "Hyaenidae Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/equine_features
	name = "Equine Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/bovine_features
	name = "Bovine Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/ursine_features
	name = "Ursine Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/cervine_features
	name = "Cervine Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/lapine_features
	name = "Lapine Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/rodent_features
	name = "Rodent Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/primate_features
	name = "Primate Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/marsupial_features
	name = "Marsupial Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/lizard_features
	name = "Lizard Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/avian_features
	name = "Avian Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/amphibian_features
	name = "Amphibian Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/insectoid_features
	name = "Insectoid Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/marine_features
	name = "Marine Features"
	verbage = "%HAVE%"

/datum/mob_descriptor/prominent/vulpine_features
	name = "Vulpine Features"
	verbage = "%HAVE%"
